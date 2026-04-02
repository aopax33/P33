import React, { useEffect, useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Grid,
  CircularProgress,
  Alert,
  Divider,
  Chip,
} from '@mui/material';
import PeopleIcon from '@mui/icons-material/People';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import StarIcon from '@mui/icons-material/Star';
import CategoryIcon from '@mui/icons-material/Category';
import PendingIcon from '@mui/icons-material/Pending';
import { collection, getCountFromServer, query, where } from 'firebase/firestore';
import { db } from '../firebase';

interface Stats {
  users: number;
  products: number;
  ratings: number;
  categories: number;
  pendingCategories: number;
  pendingProducts: number;
}

export default function DashboardScreen() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [users, products, ratings, categories, pendingCats, pendingProds] =
          await Promise.all([
            getCountFromServer(collection(db, 'users')),
            getCountFromServer(
              query(collection(db, 'products'), where('isVisible', '==', true))
            ),
            getCountFromServer(collection(db, 'ratings')),
            getCountFromServer(
              query(
                collection(db, 'categories'),
                where('status', '==', 'approved')
              )
            ),
            getCountFromServer(
              query(
                collection(db, 'categories'),
                where('status', '==', 'pending')
              )
            ),
            getCountFromServer(
              query(collection(db, 'products'), where('isVisible', '==', false))
            ),
          ]);

        setStats({
          users: users.data().count,
          products: products.data().count,
          ratings: ratings.data().count,
          categories: categories.data().count,
          pendingCategories: pendingCats.data().count,
          pendingProducts: pendingProds.data().count,
        });
      } catch (err) {
        setError('Failed to load statistics. Check Firestore permissions.');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" pt={8}>
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return <Alert severity="error">{error}</Alert>;
  }

  const statCards = [
    {
      label: 'Total Users',
      value: stats!.users,
      icon: <PeopleIcon sx={{ fontSize: 40, color: '#1976D2' }} />,
      color: '#E3F2FD',
    },
    {
      label: 'Visible Products',
      value: stats!.products,
      icon: <Inventory2Icon sx={{ fontSize: 40, color: '#2E7D32' }} />,
      color: '#E8F5E9',
    },
    {
      label: 'Total Ratings',
      value: stats!.ratings,
      icon: <StarIcon sx={{ fontSize: 40, color: '#F57F17' }} />,
      color: '#FFF8E1',
    },
    {
      label: 'Approved Categories',
      value: stats!.categories,
      icon: <CategoryIcon sx={{ fontSize: 40, color: '#6A1B9A' }} />,
      color: '#F3E5F5',
    },
  ];

  return (
    <Box>
      <Typography variant="h4" fontWeight="bold" mb={1}>
        Dashboard
      </Typography>
      <Typography variant="body1" color="text.secondary" mb={3}>
        Overview of ShelfRate platform activity
      </Typography>

      {/* Alert badges */}
      {(stats!.pendingCategories > 0 || stats!.pendingProducts > 0) && (
        <Box sx={{ mb: 3, display: 'flex', gap: 2, flexWrap: 'wrap' }}>
          {stats!.pendingCategories > 0 && (
            <Chip
              icon={<PendingIcon />}
              label={`${stats!.pendingCategories} category suggestions pending review`}
              color="warning"
              variant="outlined"
            />
          )}
          {stats!.pendingProducts > 0 && (
            <Chip
              icon={<PendingIcon />}
              label={`${stats!.pendingProducts} products hidden`}
              color="error"
              variant="outlined"
            />
          )}
        </Box>
      )}

      {/* Stat cards */}
      <Grid container spacing={3} mb={4}>
        {statCards.map((card) => (
          <Grid item xs={12} sm={6} md={3} key={card.label}>
            <Card sx={{ borderRadius: 3, height: '100%' }}>
              <CardContent
                sx={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 2,
                  p: 3,
                  bgcolor: card.color,
                }}
              >
                {card.icon}
                <Box>
                  <Typography variant="h4" fontWeight="bold">
                    {card.value.toLocaleString()}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {card.label}
                  </Typography>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Divider sx={{ mb: 3 }} />

      {/* Quick links */}
      <Typography variant="h6" fontWeight="bold" mb={2}>
        Quick Actions
      </Typography>
      <Grid container spacing={2}>
        {[
          { label: 'Moderate Products', path: '/products', desc: 'Review and show/hide products' },
          { label: 'Approve Categories', path: '/categories', desc: 'Review pending category suggestions' },
          { label: 'Review Photos', path: '/photos', desc: 'Moderate user-uploaded photos' },
          { label: 'Manage Users', path: '/users', desc: 'View and deactivate users' },
        ].map((item) => (
          <Grid item xs={12} sm={6} key={item.label}>
            <Card
              sx={{
                borderRadius: 2,
                cursor: 'pointer',
                transition: 'transform 0.15s',
                '&:hover': { transform: 'translateY(-2px)', boxShadow: 4 },
              }}
              onClick={() => (window.location.href = item.path)}
            >
              <CardContent>
                <Typography variant="subtitle1" fontWeight="bold">
                  {item.label}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {item.desc}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Box>
  );
}
