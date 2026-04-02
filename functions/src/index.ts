import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

const db = admin.firestore();

// ── onRatingWritten ────────────────────────────────────────────────────────
//
// Triggered whenever a rating document is created, updated, or deleted.
// Recalculates avgRating and totalRatings on the parent product document.

export const onRatingWritten = functions.firestore
  .document("ratings/{ratingId}")
  .onWrite(async (change, context) => {
    // Determine the productId from either the before or after snapshot
    const beforeData = change.before.exists
      ? (change.before.data() as admin.firestore.DocumentData)
      : null;
    const afterData = change.after.exists
      ? (change.after.data() as admin.firestore.DocumentData)
      : null;

    const productId: string | undefined =
      afterData?.productId ?? beforeData?.productId;

    if (!productId) {
      functions.logger.warn("onRatingWritten: no productId found", context.params);
      return null;
    }

    const productRef = db.collection("products").doc(productId);

    // Aggregate all ratings for this product
    const ratingsSnap = await db
      .collection("ratings")
      .where("productId", "==", productId)
      .get();

    const totalRatings = ratingsSnap.size;

    let scoreSum = 0;
    ratingsSnap.forEach((doc) => {
      const data = doc.data();
      if (typeof data.score === "number") {
        scoreSum += data.score;
      }
    });

    const avgRating = totalRatings > 0 ? scoreSum / totalRatings : 0;

    await productRef.update({
      totalRatings,
      avgRating: parseFloat(avgRating.toFixed(2)),
    });

    functions.logger.info(
      `Updated product ${productId}: totalRatings=${totalRatings}, avgRating=${avgRating.toFixed(2)}`
    );

    return null;
  });

// ── onRatingLikeWritten ────────────────────────────────────────────────────
//
// Triggered whenever a rating document is created, updated, or deleted.
// Recalculates totalLikes and totalDislikes on the parent product document.

export const onRatingLikeWritten = functions.firestore
  .document("ratings/{ratingId}")
  .onWrite(async (change, context) => {
    const beforeData = change.before.exists
      ? (change.before.data() as admin.firestore.DocumentData)
      : null;
    const afterData = change.after.exists
      ? (change.after.data() as admin.firestore.DocumentData)
      : null;

    const productId: string | undefined =
      afterData?.productId ?? beforeData?.productId;

    if (!productId) {
      return null;
    }

    // Only proceed if the `liked` field changed (or doc was deleted/created)
    const beforeLiked = beforeData?.liked;
    const afterLiked = afterData?.liked;
    const docDeleted = !change.after.exists;
    const docCreated = !change.before.exists;

    if (!docDeleted && !docCreated && beforeLiked === afterLiked) {
      // liked field didn't change — nothing to recount
      return null;
    }

    const productRef = db.collection("products").doc(productId);

    // Re-aggregate like/dislike counts
    const ratingsSnap = await db
      .collection("ratings")
      .where("productId", "==", productId)
      .get();

    let totalLikes = 0;
    let totalDislikes = 0;

    ratingsSnap.forEach((doc) => {
      const data = doc.data();
      if (data.liked === true) totalLikes++;
      else if (data.liked === false) totalDislikes++;
    });

    await productRef.update({ totalLikes, totalDislikes });

    functions.logger.info(
      `Updated product ${productId}: totalLikes=${totalLikes}, totalDislikes=${totalDislikes}`
    );

    return null;
  });

// ── onUserCreated ──────────────────────────────────────────────────────────
//
// Creates a Firestore user document when a new Firebase Auth user signs up.
// This is a safety net; the Flutter app also creates the document.

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const userRef = db.collection("users").doc(user.uid);
  const doc = await userRef.get();

  if (doc.exists) {
    functions.logger.info(`User doc already exists for ${user.uid}`);
    return null;
  }

  await userRef.set({
    id: user.uid,
    displayName: user.displayName ?? "User",
    email: user.email ?? "",
    avatarUrl: user.photoURL ?? null,
    authProvider: user.providerData?.[0]?.providerId?.includes("google")
      ? "google"
      : user.providerData?.[0]?.providerId?.includes("apple")
      ? "apple"
      : "email",
    likedProducts: [],
    dislikedProducts: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isActive: true,
  });

  functions.logger.info(`Created user document for ${user.uid}`);
  return null;
});
