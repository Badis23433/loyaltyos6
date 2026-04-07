-- LoyaltyOS v4 compatibility patch for Version test 5.1
-- Run after migration_v3.sql

alter table merchants add column if not exists pts_min integer default 1;
alter table merchants add column if not exists pts_max integer default 5000;

alter table clients add column if not exists active boolean default true;
alter table clients add column if not exists total_points_earned integer default 0;
alter table clients add column if not exists created_at timestamptz default now();

update clients
set total_points_earned = greatest(coalesce(total_points_earned, 0), coalesce(points, 0))
where coalesce(total_points_earned, 0) < coalesce(points, 0);

update clients
set created_at = coalesce(created_at, join_date, now())
where created_at is null;

update merchants
set pts_min = coalesce(pts_min, 1),
    pts_max = coalesce(pts_max, 5000);
