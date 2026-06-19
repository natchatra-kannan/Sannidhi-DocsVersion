-- ====================================================================
-- SANNIDHI SUPABASE DATABASE SCHEMA
-- ====================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Profiles Table
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade primary key,
    email text unique not null,
    full_name text not null,
    role text,
    avatar_url text,
    coins_received integer default 0 check (coins_received >= 0),
    coins_sent integer default 0 check (coins_sent >= 0),
    coins_deducted integer default 0 check (coins_deducted >= 0),
    balance integer default 0 check (balance >= 0),
    achievements text[] default '{}',
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on public.profiles
alter table public.profiles enable row level security;

create policy "Allow public read access to profiles" 
    on public.profiles for select 
    using (true);

create policy "Allow users to update their own profile" 
    on public.profiles for update 
    using (auth.uid() = id);

-- Trigger to automatically create profile on sign up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role, avatar_url, coins_received, coins_sent, coins_deducted, balance, achievements)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', 'Sannidhi Member'),
    coalesce(new.raw_user_meta_data->>'role', 'Member'),
    coalesce(new.raw_user_meta_data->>'avatar_url', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=120'),
    100, -- Welcome coins
    0,
    0,
    100,
    array['Welcome aboard!']
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. Teams Table
create table if not exists public.teams (
    id uuid default gen_random_uuid() primary key,
    name text not null unique,
    description text,
    lead_id uuid references public.profiles(id),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.teams enable row level security;

create policy "Allow public read access to teams" 
    on public.teams for select 
    using (true);


-- 3. Team Members Table (Join Table)
create table if not exists public.team_members (
    id uuid default gen_random_uuid() primary key,
    team_id uuid references public.teams(id) on delete cascade not null,
    profile_id uuid references public.profiles(id) on delete cascade not null,
    role text default 'Member',
    is_alumni boolean default false,
    joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(team_id, profile_id)
);

alter table public.team_members enable row level security;

create policy "Allow public read access to team members" 
    on public.team_members for select 
    using (true);


-- 4. Culture Posts Table
create table if not exists public.culture_posts (
    id uuid default gen_random_uuid() primary key,
    author_id uuid references public.profiles(id) on delete set null,
    type text not null check (type in ('gratitude', 'pioneering', 'entrepreneurial', 'growth', 'inclusive', 'excellence')),
    content text not null,
    media_url text,
    is_anonymous boolean default false not null,
    likes_count integer default 0 check (likes_count >= 0),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.culture_posts enable row level security;

create policy "Allow public read access to culture posts" 
    on public.culture_posts for select 
    using (true);

create policy "Allow authenticated users to insert culture posts" 
    on public.culture_posts for insert 
    with check (auth.uid() = author_id);


-- 5. Culture Comments Table
create table if not exists public.culture_comments (
    id uuid default gen_random_uuid() primary key,
    post_id uuid references public.culture_posts(id) on delete cascade not null,
    author_id uuid references public.profiles(id) on delete set null,
    content text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.culture_comments enable row level security;

create policy "Allow public read access to culture comments" 
    on public.culture_comments for select 
    using (true);

create policy "Allow authenticated users to insert culture comments" 
    on public.culture_comments for insert 
    with check (auth.uid() = author_id);


-- 6. Culture Reactions Table (Likes tracking)
create table if not exists public.culture_reactions (
    id uuid default gen_random_uuid() primary key,
    post_id uuid references public.culture_posts(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    type text default 'like' not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(post_id, user_id)
);

alter table public.culture_reactions enable row level security;

create policy "Allow public read access to culture reactions" 
    on public.culture_reactions for select 
    using (true);

create policy "Allow users to handle their own reactions" 
    on public.culture_reactions for insert 
    with check (auth.uid() = user_id);

create policy "Allow users to delete their own reactions" 
    on public.culture_reactions for delete 
    using (auth.uid() = user_id);


-- 7. Meeting Rooms Table
create table if not exists public.meeting_rooms (
    id uuid default gen_random_uuid() primary key,
    name text not null unique,
    capacity integer not null check (capacity > 0),
    location text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.meeting_rooms enable row level security;

create policy "Allow public read access to meeting rooms" 
    on public.meeting_rooms for select 
    using (true);


-- 8. Meeting Room Bookings Table
create table if not exists public.meeting_room_bookings (
    id uuid default gen_random_uuid() primary key,
    room_id uuid references public.meeting_rooms(id) on delete cascade not null,
    booked_by uuid references public.profiles(id) on delete cascade not null,
    title text not null,
    start_time timestamp with time zone not null,
    end_time timestamp with time zone not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    constraint check_times check (start_time < end_time)
);

alter table public.meeting_room_bookings enable row level security;

create policy "Allow public read access to bookings" 
    on public.meeting_room_bookings for select 
    using (true);

create policy "Allow authenticated users to insert bookings" 
    on public.meeting_room_bookings for insert 
    with check (auth.uid() = booked_by);

create policy "Allow users to cancel own bookings" 
    on public.meeting_room_bookings for delete 
    using (auth.uid() = booked_by);


-- 9. Awards Table
create table if not exists public.awards (
    id uuid default gen_random_uuid() primary key,
    title text not null,
    year integer not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.awards enable row level security;

create policy "Allow public read access to awards" 
    on public.awards for select 
    using (true);


-- 10. Award Categories Table
create table if not exists public.award_categories (
    id uuid default gen_random_uuid() primary key,
    award_id uuid references public.awards(id) on delete cascade not null,
    name text not null, -- Sei, Yayum, Ulavu, etc.
    description text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(award_id, name)
);

alter table public.award_categories enable row level security;

create policy "Allow public read access to award categories" 
    on public.award_categories for select 
    using (true);


-- 11. Award Nominations Table
create table if not exists public.award_nominations (
    id uuid default gen_random_uuid() primary key,
    category_id uuid references public.award_categories(id) on delete cascade not null,
    nominee_id uuid references public.profiles(id) on delete cascade not null,
    nominator_id uuid references public.profiles(id) on delete set null not null,
    reason text not null check (length(reason) >= 20),
    votes_count integer default 0,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.award_nominations enable row level security;

create policy "Allow public read access to award nominations" 
    on public.award_nominations for select 
    using (true);

create policy "Allow authenticated users to insert nominations" 
    on public.award_nominations for insert 
    with check (auth.uid() = nominator_id);

create policy "Allow nominators to update draft nominations" 
    on public.award_nominations for update 
    using (auth.uid() = nominator_id);
