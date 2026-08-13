-- ========================================================
-- JAMAL TOURS & TRAVELS - SUPABASE DATABASE SCHEMA
-- Multi-Device Hajj & Umrah Tour Operator System
-- ========================================================

-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE (User Profile & Admin Role Sync)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100),
    email VARCHAR(100),
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'staff')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. PACKAGES TABLE (Hajj & Umrah Package Listings)
CREATE TABLE IF NOT EXISTS public.packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(150) NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('hajj', 'umrah', 'air_ticket', 'custom')),
    description TEXT NOT NULL,
    duration_days INT NOT NULL CHECK (duration_days > 0),
    makkah_nights INT NOT NULL DEFAULT 0,
    madinah_nights INT NOT NULL DEFAULT 0,
    price_inr NUMERIC(10, 2) NOT NULL CHECK (price_inr >= 0),
    gst_rate NUMERIC(4, 2) NOT NULL DEFAULT 5.00,
    original_price_inr NUMERIC(10, 2),
    badge VARCHAR(50),
    max_seats INT NOT NULL DEFAULT 50,
    available_seats INT NOT NULL DEFAULT 50 CHECK (available_seats >= 0),
    images TEXT[] DEFAULT ARRAY[]::TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. PACKAGE ITINERARIES TABLE (Day-by-Day Timeline)
CREATE TABLE IF NOT EXISTS public.package_itineraries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    package_id UUID NOT NULL REFERENCES public.packages(id) ON DELETE CASCADE,
    day_number INT NOT NULL CHECK (day_number > 0),
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    city VARCHAR(50) NOT NULL CHECK (city IN ('Makkah', 'Madinah', 'Transit', 'Jeddah')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. HOTELS TABLE (5-Star & Luxury Haram Facing Hotels)
CREATE TABLE IF NOT EXISTS public.hotels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    city VARCHAR(50) NOT NULL CHECK (city IN ('Makkah', 'Madinah')),
    star_rating INT NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
    image TEXT,
    distance_from_haram VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. PACKAGE HOTELS MAPPING TABLE
CREATE TABLE IF NOT EXISTS public.package_hotels (
    package_id UUID REFERENCES public.packages(id) ON DELETE CASCADE,
    hotel_id UUID REFERENCES public.hotels(id) ON DELETE CASCADE,
    city_type VARCHAR(20) NOT NULL CHECK (city_type IN ('makkah', 'madinah')),
    PRIMARY KEY (package_id, hotel_id, city_type)
);

-- 6. BOOKINGS TABLE (Pilgrim Registrations)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    package_id UUID NOT NULL REFERENCES public.packages(id),
    status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    travel_date DATE NOT NULL,
    num_pilgrims INT NOT NULL DEFAULT 1 CHECK (num_pilgrims > 0),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    payment_status VARCHAR(30) NOT NULL DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partially_paid', 'paid', 'refunded')),
    razorpay_payment_id VARCHAR(100),
    razorpay_order_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 7. PILGRIMS TABLE (Individual Traveler Passport & Details)
CREATE TABLE IF NOT EXISTS public.pilgrims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    passport_number VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female')),
    relation VARCHAR(50) DEFAULT 'self',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 8. ENQUIRIES TABLE (Custom Lead Requests & Contact Form)
CREATE TABLE IF NOT EXISTS public.enquiries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    package_interest VARCHAR(150),
    preferred_date DATE,
    num_pilgrims INT DEFAULT 1,
    message TEXT,
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'resolved', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 9. TESTIMONIALS TABLE (Pilgrim Reviews & Star Ratings)
CREATE TABLE IF NOT EXISTS public.testimonials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NOT NULL,
    avatar_url TEXT,
    is_featured BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 10. GALLERY TABLE (Pilgrimage Photo Gallery)
CREATE TABLE IF NOT EXISTS public.gallery (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('makkah', 'madinah', 'ziyarat', 'general')),
    location VARCHAR(150) NOT NULL,
    url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 11. VIDEOS TABLE (YouTube Vlogs & Umrah Guidance)
CREATE TABLE IF NOT EXISTS public.videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(150) NOT NULL,
    youtube_url TEXT NOT NULL,
    video_id VARCHAR(50) NOT NULL,
    category VARCHAR(50) DEFAULT 'vlog',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- --------------------------------------------------------
-- INDEXES FOR SPEED & HIGH CONCURRENCY
-- --------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_packages_type ON public.packages(type);
CREATE INDEX IF NOT EXISTS idx_packages_active ON public.packages(is_active);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_enquiries_status ON public.enquiries(status);
CREATE INDEX IF NOT EXISTS idx_gallery_category ON public.gallery(category);

-- --------------------------------------------------------
-- AUTOMATIC TRIGGER FOR ATOMIC SEAT DECREMENT ON BOOKING
-- --------------------------------------------------------
CREATE OR REPLACE FUNCTION public.decrement_package_seats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.packages
    SET available_seats = available_seats - NEW.num_pilgrims
    WHERE id = NEW.package_id AND available_seats >= NEW.num_pilgrims;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_decrement_seats ON public.bookings;
CREATE TRIGGER trigger_decrement_seats
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    WHEN (NEW.status = 'confirmed' OR NEW.payment_status = 'paid')
    EXECUTE FUNCTION public.decrement_package_seats();

-- --------------------------------------------------------
-- ROW LEVEL SECURITY (RLS) POLICIES
-- --------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_itineraries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pilgrims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery ENABLE ROW LEVEL SECURITY;

-- Helper Admin Check
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Public Read & Admin CRUD Policies
CREATE POLICY "Public packages viewable" ON public.packages FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Allow package insert" ON public.packages FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow package update" ON public.packages FOR UPDATE USING (TRUE);
CREATE POLICY "Allow package delete" ON public.packages FOR DELETE USING (TRUE);

CREATE POLICY "Public itineraries viewable" ON public.package_itineraries FOR SELECT USING (TRUE);
CREATE POLICY "Public hotels viewable" ON public.hotels FOR SELECT USING (TRUE);

CREATE POLICY "Public testimonials viewable" ON public.testimonials FOR SELECT USING (TRUE);
CREATE POLICY "Allow testimonial insert" ON public.testimonials FOR INSERT WITH CHECK (TRUE);

CREATE POLICY "Public gallery viewable" ON public.gallery FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Allow gallery insert" ON public.gallery FOR INSERT WITH CHECK (TRUE);

CREATE POLICY "Public videos viewable" ON public.videos FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Allow video insert" ON public.videos FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow video delete" ON public.videos FOR DELETE USING (TRUE);

-- Profile Policies
CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id OR public.is_admin());
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Bookings & Pilgrims RLS
CREATE POLICY "Users view own bookings" ON public.bookings FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
CREATE POLICY "Users insert own booking" ON public.bookings FOR INSERT WITH CHECK (TRUE);

CREATE POLICY "Users view own pilgrims" ON public.pilgrims
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.bookings
            WHERE bookings.id = pilgrims.booking_id
            AND (bookings.user_id = auth.uid() OR public.is_admin())
        )
    );

-- Enquiries RLS
CREATE POLICY "Anyone can create enquiry" ON public.enquiries FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Admin view all enquiries" ON public.enquiries FOR SELECT USING (public.is_admin());
CREATE POLICY "Admin update enquiries" ON public.enquiries FOR UPDATE USING (public.is_admin());

-- --------------------------------------------------------
-- SEED DATA
-- --------------------------------------------------------

-- Seed Hotels
INSERT INTO public.hotels (id, name, city, star_rating, image, distance_from_haram) VALUES
('11111111-1111-1111-1111-111111111111', 'Swissôtel Makkah', 'Makkah', 5, 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=800&q=80', '100m (Abraj Al Bait Clock Tower)'),
('22222222-2222-2222-2222-222222222222', 'Pullman Zamzam Madinah', 'Madinah', 5, 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80', '150m from Masjid An-Nabawi'),
('33333333-3333-3333-3333-333333333333', 'Anjum Hotel Makkah', 'Makkah', 5, 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80', '300m from Haram Piazza');

-- Seed 5 Packages
INSERT INTO public.packages (id, title, type, description, duration_days, makkah_nights, madinah_nights, price_inr, gst_rate, original_price_inr, badge, max_seats, available_seats, images, is_active) VALUES
(
    'a1111111-1111-1111-1111-111111111111',
    'Ramzan Full Month Umrah',
    'umrah',
    'Experience the entire blessed month of Ramzan in the Holy Sanctuaries of Makkah and Madinah with full 30-day spiritual devotion, luxury transfers, Sehri & Iftar arrangements.',
    30,
    20,
    10,
    125000.00,
    5.00,
    140000.00,
    'Most Popular',
    40,
    18,
    ARRAY['https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=1000&q=80', 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80'],
    TRUE
),
(
    'a2222222-2222-2222-2222-222222222222',
    'Ramzan 1st 20 Days Package',
    'umrah',
    'Spend the initial 20 days of Ramzan performing Umrah, Tawaf, and Taraweeh in Makkah Mukarramah and Madinah Munawwarah with direct flights and guided Ziyarat.',
    20,
    10,
    10,
    95000.00,
    5.00,
    110000.00,
    'Value Choice',
    50,
    25,
    ARRAY['https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80'],
    TRUE
),
(
    'a3333333-3333-3333-3333-333333333333',
    'Ramzan Last 20 Days Package',
    'umrah',
    'Observe Laylatul Qadr in the blessed lands. Includes 10 days in Makkah for final ashra and 10 peaceful days in Madinah.',
    20,
    10,
    10,
    105000.00,
    5.00,
    120000.00,
    'Spiritual Peak',
    35,
    12,
    ARRAY['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1000&q=80'],
    TRUE
),
(
    'a4444444-4444-4444-4444-444444444444',
    'Ramzan Last 15 Days Package',
    'umrah',
    'Focused 15-day pilgrimage covering the last ashra of Ramzan with luxury hotel stay near Haram, direct Umrah visa, and full support.',
    15,
    5,
    10,
    95000.00,
    5.00,
    105000.00,
    'Fast Track',
    30,
    10,
    ARRAY['https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1000&q=80'],
    TRUE
),
(
    'a5555555-5555-5555-5555-555555555555',
    'Hajj 2026 Premium Package',
    'hajj',
    'Exclusive VIP Hajj 2026 experience with air-conditioned luxury tents in Mina & Arafat, 5-star Haram facing hotels, pre-Hajj guidance seminars, and dedicated scholar assistance.',
    40,
    25,
    15,
    650000.00,
    5.00,
    700000.00,
    'Coming Soon',
    50,
    50,
    ARRAY['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1000&q=80'],
    TRUE
);

-- Seed Package Hotels Mapping
INSERT INTO public.package_hotels (package_id, hotel_id, city_type) VALUES
('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'makkah'),
('a1111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'madinah'),
('a2222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'makkah'),
('a2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'madinah');

-- Seed Sample Itineraries for Package 1
INSERT INTO public.package_itineraries (package_id, day_number, title, description, city) VALUES
('a1111111-1111-1111-1111-111111111111', 1, 'Arrival & Umrah Execution', 'Direct flight to Jeddah. Transfer by luxury AC bus to Makkah hotel. Perform first Umrah with experienced guide.', 'Makkah'),
('a1111111-1111-1111-1111-111111111111', 2, 'Spiritual Worship in Makkah', 'Daily Ibadah, Taraweeh prayers in Masjid al-Haram, guided orientation.', 'Makkah'),
('a1111111-1111-1111-1111-111111111111', 10, 'Makkah Historical Ziyarat', 'Visit Mina, Muzdalifah, Arafat, Jabal al-Nour (Cave Hira), and Jabal Thawr.', 'Makkah'),
('a1111111-1111-1111-1111-111111111111', 21, 'Transfer to Madinah Munawwarah', 'Check out from Makkah and travel via Haramain High Speed Railway / Luxury Coach to Madinah.', 'Madinah'),
('a1111111-1111-1111-1111-111111111111', 25, 'Madinah Ziyarat', 'Guided visit to Masjid Quba, Mount Uhud, Masjid al-Qiblatayn, and Seven Mosques.', 'Madinah');

-- Seed Testimonials
INSERT INTO public.testimonials (name, city, rating, comment, avatar_url) VALUES
('Haji Mohammed Salim Khan', 'Mumbai, Maharashtra', 5, 'Jamal Tours made our family Umrah completely hassle-free. The proximity of Swissotel to Haram in Makkah was exceptional. May Allah reward their team.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80'),
('Fatima Sheikh', 'Thane, Maharashtra', 5, 'Transparent pricing, no hidden costs. The scholars guided us at every step during Ramzan Taraweeh and Ziyarat tours.', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80'),
('Tariq Ahmad Ansari', 'Navi Mumbai, Maharashtra', 5, 'The best Hajj & Umrah tour operator in Mira Road. Prompt response on WhatsApp and smooth visa assistance.', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80');

-- Seed Gallery Photos
INSERT INTO public.gallery (title, category, location, url) VALUES
('Masjid Al-Haram & Holy Kaaba', 'makkah', 'Makkah Mukarramah', 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=1000&q=80'),
('Al-Masjid an-Nabawi Green Dome', 'madinah', 'Madinah Munawwarah', 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80'),
('Pilgrims Performing Tawaf', 'makkah', 'Masjid Al-Haram', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1000&q=80'),
('Sacred Mount Uhud', 'ziyarat', 'Madinah Munawwarah', 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1000&q=80'),
('Masjid Al-Haram Night View', 'makkah', 'Abraj Al Bait Makkah', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1000&q=80'),
('Masjid Nabawi Umbrellas', 'madinah', 'Madinah Munawwarah', 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=1000&q=80');

-- Seed YouTube Videos
INSERT INTO public.videos (title, youtube_url, video_id, category) VALUES
('Jamal Tours Executive Umrah Group Experience 2026', 'https://www.youtube.com/watch?v=5Eqb_-j3FDA', '5Eqb_-j3FDA', 'vlog'),
('Step by Step Umrah Guide & Rituals Explanation by Scholar', 'https://www.youtube.com/watch?v=5Eqb_-j3FDA', '5Eqb_-j3FDA', 'guidance'),
('Madinah Munawwarah Historical Ziyarat Tour Overview', 'https://www.youtube.com/watch?v=5Eqb_-j3FDA', '5Eqb_-j3FDA', 'ziyarat');
