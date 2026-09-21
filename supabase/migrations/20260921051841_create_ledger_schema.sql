-- 가계부 스키마
--
-- 이 파일은 원격 Supabase 프로젝트에 적용된 마이그레이션과 같은 내용입니다.
-- (version 20260921051841 / create_ledger_schema)
--
-- 주의: 아래 RLS 정책은 로그인 없이 익명으로 읽고 쓰는 구성을 의도한 것입니다.
-- 앱이 공개 주소(GitHub Pages)에 배포돼 있으므로, 주소를 아는 사람은 누구나
-- 내역을 보고 고칠 수 있습니다. 실제 금융 데이터를 넣는다면 Supabase Auth를
-- 붙이고 정책을 auth.uid() 기준으로 바꿔야 합니다.

-- 거래 내역
create table public.transactions (
  id          bigint generated always as identity primary key,
  date        date        not null,
  type        text        not null check (type in ('income', 'expense')),
  segment     text        not null default '미지정',
  category    text        not null default '기타',
  memo        text        not null default '',
  amount      bigint      not null check (amount > 0),
  fixed       boolean     not null default false,
  created_at  timestamptz not null default now()
);

-- 목록은 항상 최신 날짜부터 읽습니다.
create index transactions_date_idx on public.transactions (date desc, id desc);

-- 예산 · 결제수단 설정 (단일 행)
create table public.settings (
  id            smallint    primary key default 1 check (id = 1),
  segments      jsonb       not null default '[]'::jsonb,
  budgets       jsonb       not null default '{}'::jsonb,
  budget_total  bigint      not null default 0,
  saving_target bigint      not null default 0,
  updated_at    timestamptz not null default now()
);

insert into public.settings (id, segments)
values (1, '["카드값(신용)","현금","네이버포인트","체크카드","계좌이체/자동이체","간편결제","상품권/기프티콘"]'::jsonb);

-- RLS: 로그인 없이 공개 접근
alter table public.transactions enable row level security;
alter table public.settings     enable row level security;

create policy "anon_select_transactions" on public.transactions for select to anon, authenticated using (true);
create policy "anon_insert_transactions" on public.transactions for insert to anon, authenticated with check (true);
create policy "anon_update_transactions" on public.transactions for update to anon, authenticated using (true) with check (true);
create policy "anon_delete_transactions" on public.transactions for delete to anon, authenticated using (true);

create policy "anon_select_settings" on public.settings for select to anon, authenticated using (true);
create policy "anon_insert_settings" on public.settings for insert to anon, authenticated with check (true);
create policy "anon_update_settings" on public.settings for update to anon, authenticated using (true) with check (true);

-- 여러 기기에서 동시에 보고 있을 때 자동 반영
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.settings;
