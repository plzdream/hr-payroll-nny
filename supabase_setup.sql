-- Run this once in Supabase → SQL Editor
create table if not exists payroll_data (
  id text primary key,
  state jsonb not null,
  updated_at timestamptz default now()
);

alter table payroll_data enable row level security;

create policy "public read" on payroll_data for select using (true);
create policy "public insert" on payroll_data for insert with check (true);
create policy "public update" on payroll_data for update using (true);
