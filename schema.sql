-- ============================================================
-- Gestão de Velocidade · estrutura no Supabase
-- Rode tudo no SQL Editor do seu projeto (uma vez).
-- ============================================================

create table if not exists public.infracoes (
  id                bigint generated always as identity primary key,
  placa             text not null,
  condutor          text,
  base              text,
  pico              integer,
  data              timestamptz not null,   -- usada para "substituir por período"
  data_br           text,                   -- data original "dd/mm/aaaa hh:mm:ss"
  endereco          text,
  latitude          numeric,
  longitude         numeric,
  validade          text,
  pontuacao_perdida integer,
  localizacao       text,
  created_at        timestamptz default now(),
  unique (placa, data)                      -- evita duplicar a mesma infração
);

create index if not exists idx_infracoes_data on public.infracoes (data);
create index if not exists idx_infracoes_base on public.infracoes (base);

-- ---------- Segurança (RLS) ----------
-- Só usuários autenticados (admin logado) podem ler e gravar.
alter table public.infracoes enable row level security;

create policy "auth pode ler"      on public.infracoes for select to authenticated using (true);
create policy "auth pode inserir"  on public.infracoes for insert to authenticated with check (true);
create policy "auth pode atualizar" on public.infracoes for update to authenticated using (true) with check (true);
create policy "auth pode apagar"   on public.infracoes for delete to authenticated using (true);

-- ---------- Tempo real (para o painel atualizar sozinho) ----------
alter publication supabase_realtime add table public.infracoes;
