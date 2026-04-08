-- Supabase Database Schema for Ecommerce
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users table (extends Supabase Auth)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. User Roles table
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 3. Products table
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  category TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 4. Orders table
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  total_amount DECIMAL(10,2) NOT NULL,
  shipping_address TEXT NOT NULL,
  contact_phone TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- 5. Order Items table
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON public.order_items(product_id);

-- Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- RLS Policies for user_roles table
CREATE POLICY "Users can view roles" ON public.user_roles
  FOR SELECT USING (auth.uid() = user_id);

-- RLS Policies for products table  
CREATE POLICY "Anyone can view active products" ON public.products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage products" ON public.products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- RLS Policies for orders table
CREATE POLICY "Users can view own orders" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all orders" ON public.orders
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can create orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can update orders" ON public.orders
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- RLS Policies for order_items table
CREATE POLICY "Users can view own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders WHERE id = order_id AND user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can create order items" ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.orders WHERE id = order_id AND user_id = auth.uid())
  );

CREATE POLICY "Admins can update order items" ON public.order_items
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- Seed grocery products
INSERT INTO public.products (name, description, price, stock, category, image_url) VALUES
('Fresh Organic Bananas', 'Premium quality organic bananas, rich in potassium and natural sweetness', 45.00, 100, 'Fruits', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400'),
('Red Tomatoes', 'Fresh and juicy red tomatoes, perfect for salads and cooking', 35.00, 80, 'Vegetables', 'https://images.unsplash.com/photo-1546470427-227c7369a9b9?w=400'),
('Crispy Green Apples', 'Crisp and sweet green apples, naturally grown', 89.00, 60, 'Fruits', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400'),
('Fresh Spinach', 'Organic spinach leaves, rich in iron and vitamins', 25.00, 50, 'Vegetables', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400'),
('Dairy Milk', 'Pure and fresh dairy milk, 1 liter pack', 45.00, 120, 'Dairy', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400'),
('Farm Fresh Eggs', 'Dozen eggs from free-range farms', 60.00, 75, 'Dairy', 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400'),
('Whole Wheat Bread', 'Freshly baked whole wheat bread', 35.00, 40, 'Bakery', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400'),
('Greek Yogurt', 'Creamy Greek yogurt, high protein content', 55.00, 65, 'Dairy', 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400'),
('Orange Juice', 'Freshly squeezed orange juice, no preservatives', 79.00, 45, 'Beverages', 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400'),
('Potato Chips', 'Crunchy and tasty potato chips, family pack', 30.00, 100, 'Snacks', 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400'),
('Green Chillies', 'Fresh green chillies, perfect for Indian cooking', 20.00, 70, 'Vegetables', 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400'),
('Sweet Corn', 'Fresh sweet corn, naturally sweet and delicious', 25.00, 55, 'Vegetables', 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400'),
('Fresh Pomegranate', 'Juicy pomegranate seeds, rich in antioxidants', 120.00, 40, 'Fruits', 'https://images.unsplash.com/photo-1541344999736-4a98982f342e?w=400'),
('Onions', 'Fresh yellow onions, essential for every kitchen', 30.00, 200, 'Vegetables', 'https://images.unsplash.com/photo-1594263545717-0a9490187096?w=400'),
('Garlic', 'Premium quality garlic, aromatic and flavorful', 40.00, 150, 'Vegetables', 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2f85?w=400'),
('Fresh Ginger', 'Aromatic ginger roots, great for immunity', 35.00, 80, 'Vegetables', 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400'),
('Coconut Oil', 'Pure coconut oil for cooking and hair care', 150.00, 35, 'Grocery', 'https://images.unsplash.com/photo-1589984662646-e7b2e4962f18?w=400'),
('Basmati Rice', 'Premium quality basmati rice, 5kg pack', 450.00, 45, 'Grocery', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'),
('Toor Dal', 'Split pigeon pea lentils, protein rich', 120.00, 60, 'Grocery', 'https://images.unsplash.com/photo-1515543904323-de27c9fa4f20?w=400'),
('Sugar', 'Fine quality sugar, 1kg pack', 45.00, 90, 'Grocery', 'https://images.unsplash.com/photo-1588832657487-8f4d3b4d2c2c?w=400'),
('Salt', 'Premium iodized salt, 1kg pack', 25.00, 150, 'Grocery', 'https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=400'),
('Instant Coffee', 'Smooth and aromatic instant coffee', 250.00, 40, 'Beverages', 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400'),
('Green Tea', 'Natural green tea bags, antioxidant rich', 150.00, 55, 'Beverages', 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400'),
('Butter', 'Premium quality butter, 500g pack', 180.00, 35, 'Dairy', 'https://images.unsplash.com/photo-1589985270958-bf087b4c9e9c?w=400'),
('Paneer', 'Fresh cottage cheese, high protein', 220.00, 30, 'Dairy', 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400'),
('Chicken Breast', 'Boneless chicken breast, farm raised', 350.00, 25, 'Meat', 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400'),
('Fresh Fish', 'Freshwater fish, cleaned and ready to cook', 280.00, 20, 'Fish', 'https://images.unsplash.com/photo-1535400255456-bb5a8d96da66?w=400'),
('Chocolate Biscuits', 'Crunchy chocolate biscuits, family pack', 35.00, 85, 'Snacks', 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400'),
('Oats', 'Rolled oats for healthy breakfast', 85.00, 50, 'Grocery', 'https://images.unsplash.com/photo-1585238341267-1bc2afc6c81c?w=400'),
('Peanut Butter', 'Creamy peanut butter, high protein', 199.00, 40, 'Grocery', 'https://images.unsplash.com/photo-1600189020946-7f68b1f07192?w=400');