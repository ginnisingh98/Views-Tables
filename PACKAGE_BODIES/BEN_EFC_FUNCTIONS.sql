--------------------------------------------------------
--  DDL for Package Body BEN_EFC_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_FUNCTIONS" as
/* $Header: beefcfnc.pkb 115.13 2002/12/31 23:58:28 mmudigon noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      07-Jan-01	mhoyes     Created.
  115.1      31-Jan-01	mhoyes     Added more functions.
  115.2      06-Apr-01	mhoyes     Enhanced for Patchset D.
  115.3      12-Jul-01	mhoyes     Enhanced for Patchset E.
  115.6      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.7      13-Aug-01	mhoyes     Enhanced for Patchset E+ patch.
  115.8      27-Aug-01	mhoyes     Enhanced for July EFC patch.
  115.9      13-Sep-01	mhoyes     Enhanced for July EFC patch.
  115.10     26-Sep-01	mhoyes     Enhanced for Patchset G.
  115.11     26-Sep-01	mhoyes     Enhanced for Patchset G.
  115.13     30-Dec-02  mmudigon   NOCOPY
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_efc_functions.';
--
g_curr_pil_id number;
--
procedure setup_workers
  (p_component_name    in     varchar2
  ,p_sub_step          in     varchar2
  ,p_table_name        in     varchar2
  ,p_worker_id         in     number
  ,p_total_workers     in     number
  --
  ,p_business_group_id in     number default null
  --
  ,p_chunk                out nocopy varchar2
  ,p_status               out nocopy varchar2
  ,p_action_id            out nocopy number
  ,p_pk1                  out nocopy number
  ,p_efc_worker_id        out nocopy number
  )
is

  l_proc           varchar2(1000) := 'setup_workers';

  l_chunk          NUMBER;
  l_action_id      NUMBER;
  l_bg             NUMBER;
  l_component_id   NUMBER;

  l_status         varchar2(100);

  l_pk2char        varchar2(100) := '';
  l_pk3char        varchar2(100) := '';
  l_pk4char        varchar2(100) := '';
  l_pk5char        varchar2(100) := '';
  --
  CURSOR csr_fetch_details
    (c_bgp_id in number
    )
  IS
    SELECT act.efc_action_id,
           act.business_group_id
    FROM hr_efc_actions act
    WHERE act.efc_action_status = 'P'
    AND   act.efc_action_type = 'C'
    and   act.business_group_id = c_bgp_id;

begin
  --
  -- switch off who triggers
  --
  hr_general.g_data_migrator_mode := 'Y';
  --
  -- Get the details for this particular actions
  -- e.g. action_id, bg_id and chunk size
  --
  --   Check if we know the business group that we are dealing with
  --
  if p_business_group_id is null then
    --
    hr_efc_info.get_action_details
      (l_action_id
      ,l_bg
      ,p_chunk
      );
    --
  else
    --
    open csr_fetch_details
      (c_bgp_id => p_business_group_id
      );
    fetch csr_fetch_details into l_action_id, l_bg;
    close csr_fetch_details;
    --
    p_chunk := hr_efc_info.get_chunk;
    --
  end if;
  --
  -- Validate that conversion started with correct no. of total workers
  --
  hr_efc_info.validate_total_workers
    (p_action_id      => l_action_id
    ,p_component_name => p_component_name
    ,p_sub_step       => p_sub_step
    ,p_step           => 'C_RECAL'
    ,p_total_workers  => p_total_workers
    );
  --
  -- First processor only - insert a row into the HR_EFC_PROCESS_COMPONENTS
  -- table (procedure includes locking so that only 1 row is inserted)
  --
  hr_efc_info.insert_or_select_comp_row
    (p_action_id              => l_action_id
    ,p_process_component_name => p_component_name
    ,p_table_name             => p_table_name
    ,p_total_workers          => p_total_workers
    ,p_worker_id              => p_worker_id
    ,p_step                   => 'C_RECAL'
    ,p_sub_step               => p_sub_step
    ,p_process_component_id   => l_component_id
    );
  --
  -- Call procedure to check if this worker has already started (will detect
  -- if this worker has been restarted).
  --
  hr_efc_info.insert_or_select_worker_row
    (p_efc_worker_id          => p_efc_worker_id
    ,p_status                 => p_status
    ,p_process_component_id   => l_component_id
    ,p_process_component_name => p_component_name
    ,p_action_id              => l_action_id
    ,p_worker_number          => p_worker_id
    ,p_pk1                    => p_pk1
    ,p_pk2                    => l_pk2char
    ,p_pk3                    => l_pk3char
    ,p_pk4                    => l_pk4char
    ,p_pk5                    => l_pk5char
    );
  --
  -- Set out parameters
  --
  p_action_id := l_action_id;
  --
end setup_workers;
--
procedure maintain_chunks
  (p_row_count     in out nocopy number
  ,p_pk1           in     number
  ,p_chunk_size    in     number
  ,p_efc_worker_id in     number
  )
is

  l_proc           varchar2(1000) := 'maintain_chunks';

begin
  --
  -- Update the count for sake of chunk size
  --
  p_row_count := p_row_count + 1;
  --
  -- Check whether or not we wish to commit
  --
  IF (p_row_count >= p_chunk_size) THEN
     --
     -- Update worker table
     hr_efc_info.update_worker_row
       (p_efc_worker_id => p_efc_worker_id
       ,p_pk1           => p_pk1
       );
     -- Reset the counter.
     p_row_count := 0;
     -- Commit details
     COMMIT;
  END IF;
  --
end maintain_chunks;
--
procedure conv_check
  (p_table_name      in     varchar2
  ,p_efctable_name   in     varchar2
  ,p_tabwhere_clause in     varchar2 default null
  --
  ,p_bgp_id          in     number   default null
  ,p_action_id       in     number   default null
  --
  ,p_table_sql       in     varchar2 default null
  ,p_efctable_sql    in     varchar2 default null
  --
  ,p_tabrow_count       out nocopy number
  ,p_conv_count         out nocopy number
  ,p_unconv_count       out nocopy number
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  c_conv_count        cur_type;
  --
  l_proc              varchar2(1000) := 'conv_check';
  --
  l_sql_str           long;
  --
  l_conv_count        number;
  l_tabrow_count      pls_integer;
  --
  l_business_group_id number;
  --
begin
  --
  if p_action_id is not null then
    --
    select business_group_id
    into l_business_group_id
    from hr_efc_actions
    where efc_action_id = p_action_id;
    --
  elsif p_bgp_id is not null then
    --
    l_business_group_id := p_bgp_id;
    --
  end if;
  --
  if p_table_sql is not null
  then
    --
    open c_conv_count FOR p_table_sql;
    FETCH c_conv_count INTO l_tabrow_count;
    CLOSE c_conv_count;
    --
  elsif p_table_name is not null then
    --
    l_sql_str := 'select count(*) '
                 ||' from '||p_table_name
                 ||' where business_group_id is not null ';
    --
    if l_business_group_id is not null then
      --
      l_sql_str := l_sql_str||' and business_group_id = '||l_business_group_id;
      --
    end if;
    --
    if p_tabwhere_clause is not null then
      --
      l_sql_str := l_sql_str||' and '||p_tabwhere_clause;
      --
    end if;
    --
    open c_conv_count FOR l_sql_str;
    FETCH c_conv_count INTO l_tabrow_count;
    CLOSE c_conv_count;
    --
  end if;
  --
  if p_efctable_sql is not null
    and p_action_id is not null
  then
    --
    open c_conv_count FOR p_efctable_sql;
    FETCH c_conv_count INTO l_conv_count;
    CLOSE c_conv_count;
    --
  elsif p_efctable_name is not null
    and p_action_id is not null
  then
    --
    l_sql_str := 'select count(*) '
                 ||' from '||p_efctable_name
                 ||' where efc_action_id = '||p_action_id;
    --
    open c_conv_count FOR l_sql_str;
    FETCH c_conv_count INTO l_conv_count;
    CLOSE c_conv_count;
    --
  end if;
  --
  p_tabrow_count := l_tabrow_count;
  p_conv_count   := l_conv_count;
  p_unconv_count := l_tabrow_count-l_conv_count;
  --
end conv_check;
--
procedure EPEorENB_InitCounts
is
  --
  l_proc           varchar2(1000) := 'EPEorENB_InitCounts';
  --
begin
  --
  g_epe_count        := 0;
  g_enb_count        := 0;
  g_epeenbnull_count := 0;
  g_noepedets_count  := 0;
  g_noenbdets_count  := 0;
  --
end EPEorENB_InitCounts;
--
procedure EPEorENB_GetEPEDets
  (p_elig_per_elctbl_chc_id in     number default null
  ,p_enrt_bnft_id           in     number default null
  --
  ,p_currepe_row               out nocopy ben_epe_cache.g_pilepe_inst_row
  )
is
  --
  l_proc           varchar2(1000) := 'EPEorENB_GetEPEDets';
  --
  cursor c_epedets
    (c_epe_id in number
    )
  is
    select pil.lf_evt_ocrd_dt,
           pil.person_id,
           pil.per_in_ler_id,
           pil.business_group_id,
           pil.ler_id,
           pil.per_in_ler_stat_cd
    from BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_per_in_ler pil,
         per_all_people_f per
    where pil.per_in_ler_id = epe.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_id = c_epe_id
    and   per.person_id = pil.person_id
    and   pil.lf_evt_ocrd_dt
      between per.effective_start_date and per.effective_end_date;
  --
  l_epedets         c_epedets%rowtype;
  --
  cursor c_enbdets
    (c_enb_id in number
    )
  is
    select pil.lf_evt_ocrd_dt,
           pil.person_id,
           pil.per_in_ler_id,
           pil.business_group_id,
           pil.ler_id,
           pil.per_in_ler_stat_cd,
           enb.val
    from ben_enrt_bnft enb,
         BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_per_in_ler pil,
         per_all_people_f per
    where enb.ELIG_PER_ELCTBL_CHC_id = epe.ELIG_PER_ELCTBL_CHC_id
    and   pil.per_in_ler_id = epe.per_in_ler_id
    and   enb.enrt_bnft_id = c_enb_id
    and   per.person_id = pil.person_id
    and   pil.lf_evt_ocrd_dt
      between per.effective_start_date and per.effective_end_date;
  --
  l_enbdets           c_enbdets%rowtype;
  --
  l_currepe_set       ben_epe_cache.g_pilepe_inst_tbl;
  --
  l_currepe_row       ben_epe_cache.g_pilepe_inst_row;
  --
  l_business_group_id number;
  l_lf_evt_ocrd_dt    date;
  l_person_id         number;
  l_per_in_ler_id     number;
  --
begin
  --
  if p_elig_per_elctbl_chc_id is not null
  then
    --
    open c_epedets
      (c_epe_id => p_elig_per_elctbl_chc_id
      );
    fetch c_epedets into l_epedets;
    close c_epedets;
    --
    l_business_group_id  := l_epedets.business_group_id;
    l_lf_evt_ocrd_dt     := l_epedets.lf_evt_ocrd_dt;
    l_person_id          := l_epedets.person_id;
    ben_epe_cache.EPE_GetEPEDets
      (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
      ,p_per_in_ler_id          => l_epedets.per_in_ler_id
      ,p_inst_row               => l_currepe_row
      );
    --
  elsif p_enrt_bnft_id is not null then
    --
    open c_enbdets
      (c_enb_id => p_enrt_bnft_id
      );
    fetch c_enbdets into l_enbdets;
    close c_enbdets;
    --
    l_business_group_id := l_enbdets.business_group_id;
    l_lf_evt_ocrd_dt    := l_enbdets.lf_evt_ocrd_dt;
    l_person_id         := l_enbdets.person_id;
    l_per_in_ler_id     := l_enbdets.per_in_ler_id;
    --
    -- Get the EPE details
    --
    ben_epe_cache.ENBEPE_GetEPEDets
      (p_enrt_bnft_id  => p_enrt_bnft_id
      ,p_per_in_ler_id => l_enbdets.per_in_ler_id
      ,p_inst_row      => l_currepe_row
      );
    --
  end if;
  --
  p_currepe_row := l_currepe_row;
  --
end EPEorENB_GetEPEDets;
--
procedure CompObject_ChkAttachDF
  (p_coent_scode  in     varchar2
  ,p_compobj_id   in     number default null
  --
  ,p_counts          out nocopy g_attach_df_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  c_df_count       cur_type;
  --
  l_proc           varchar2(1000) := 'CompObject_ChkAttachDF';
  --
  l_sql_str        long;
  --
  l_count          pls_integer;
  --
  l_cocol_name     varchar2(100);
  --
begin
  --
  if p_coent_scode = 'COP' then
    --
    l_cocol_name := 'oipl_id';
    --
  elsif p_coent_scode = 'CPP' then
    --
    l_cocol_name := 'plip_id';
    --
  elsif p_coent_scode = 'PLN' then
    --
    l_cocol_name := 'pl_id';
    --
  elsif p_coent_scode = 'CTP' then
    --
    l_cocol_name := 'ptip_id';
    --
  elsif p_coent_scode = 'PGM' then
    --
    l_cocol_name := 'pgm_id';
    --
  end if;
  --
  l_sql_str := 'select count(*) '
               ||' from BEN_PRTN_ELIG_F tab '
               ||' where tab.'||l_cocol_name||' = :id ';
  --
  open c_df_count FOR l_sql_str using p_compobj_id;
  FETCH c_df_count INTO l_count;
  CLOSE c_df_count;
  --
  p_counts.epa_count := l_count;
  --
  if l_count = 0 then
    --
    l_sql_str := 'select count(*) '
                 ||' from ben_acty_base_rt_f tab '
                 ||' where tab.'||l_cocol_name||' = :id ';
    --
    open c_df_count FOR l_sql_str using p_compobj_id;
    FETCH c_df_count INTO l_count;
    CLOSE c_df_count;
    --
    p_counts.abr_count := l_count;
    --
    if l_count = 0 then
      --
      -- Only relevant for plans and oipls
      --
      if p_coent_scode in('COP','PLN') then
        --
        l_sql_str := 'select count(*) '
                     ||' from ben_actl_prem_f tab '
                     ||' where tab.'||l_cocol_name||' = :id ';
        --
        open c_df_count FOR l_sql_str using p_compobj_id;
        FETCH c_df_count INTO l_count;
        CLOSE c_df_count;
        --
        p_counts.apr_count := l_count;
        --
      end if;
      --
      if l_count = 0 then
        --
        l_sql_str := 'select count(*) '
                     ||' from ben_cvg_amt_calc_mthd_f tab '
                     ||' where tab.'||l_cocol_name||' = :id ';
        --
        open c_df_count FOR l_sql_str using p_compobj_id;
        FETCH c_df_count INTO l_count;
        CLOSE c_df_count;
        --
        p_counts.ccm_count := l_count;
        --
        if l_count = 0 then
          --
          p_counts.noattdf_count := 0;
          --
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
  --
end CompObject_ChkAttachDF;
--
procedure BGP_WriteEFCAction
  (p_bgp_id        in     number
  --
  ,p_efc_action_id    out nocopy number
  )
is
  --
  l_proc           varchar2(1000) := 'BGP_WriteEFCAction';
  --
  CURSOR csr_check_action_exists
    (c_bgp_id in number
    )
  IS
   SELECT 'Y'
     FROM hr_efc_actions
    WHERE efc_action_status = 'P'
    and   business_group_id = c_bgp_id;
  --
  CURSOR csr_fetch_id
  IS
    SELECT hr_efc_actions_s.nextval
    FROM dual;
  --
  CURSOR csr_get_sequence
    (c_bg IN number
    )
  IS
    SELECT max(action_sequence)
    FROM hr_efc_actions
    WHERE business_group_id = c_bg;
  --
  CURSOR csr_find_lowest_phase
  IS
    SELECT to_number(substr(lok.lookup_code,2)) action_num
    FROM hr_lookups lok
    WHERE lok.lookup_type = 'EFC_PROGRESS_STATUS'
    AND substr(lok.lookup_code,1,1) = 'C'
    ORDER BY lok.lookup_code;
  --
  l_exists  varchar2(1);
  l_id      number;
  l_max     number;
  l_low     number := 99999999;
  --
BEGIN
  --
  OPEN csr_check_action_exists
    (c_bgp_id => p_bgp_id
    );
  FETCH csr_check_action_exists INTO l_exists;
  IF csr_check_action_exists%NOTFOUND THEN
     -- Fetch pk
     OPEN csr_fetch_id;
     FETCH csr_fetch_id INTO l_id;
     CLOSE csr_fetch_id;
     -- Fetch sequence
     OPEN csr_get_sequence(p_bgp_id);
     FETCH csr_get_sequence INTO l_max;
     CLOSE csr_get_sequence;
     --
     FOR c1 IN csr_find_lowest_phase LOOP
         IF l_low > c1.action_num THEN
            l_low := c1.action_num;
         END IF;
     END LOOP;
     --
     IF l_max IS NULL THEN
        l_max := 1;
     ELSE
        l_max := l_max +1;
     END IF;
     --
     INSERT INTO hr_efc_actions
                  (efc_action_id
                  ,efc_action_type
                  ,efc_action_status
                  ,efc_progress_status
                  ,business_group_id
                  ,action_sequence
                  ,start_date
                  ,finish_date
                  ,matching_efc_action_id
                  ,last_update_date
                  ,last_updated_by
                  ,last_update_login
                  ,created_by
                  ,creation_date
                  )
     VALUES
       (l_id
       ,'C'
       ,'P'
       ,'C' || to_char(l_low)
       ,p_bgp_id
       ,l_max
       ,sysdate
       ,null
       ,null
       ,sysdate
       ,-1
       ,-1
       ,-1
       ,sysdate
       );
     --
  END IF;
  CLOSE csr_check_action_exists;
  --
  COMMIT;
  --
  p_efc_action_id := l_id;
  --
END BGP_WriteEFCAction;
--
procedure BGP_SetupEFCAction
  (p_bgp_id        in     number
  --
  ,p_efc_action_id    out nocopy number
  )
is
  --
  l_proc           varchar2(1000) := 'BGP_SetupEFCAction';
  --
  l_efc_action_id  number;
  --
  CURSOR c_getprevbgpactid
    (c_bgp_id in number
    )
  IS
    select efc.efc_action_id
    from hr_efc_actions efc
    where efc.business_group_id = c_bgp_id;
  --
BEGIN
  --
  -- Get the previous action id for the bgp id
  --
  open c_getprevbgpactid
    (c_bgp_id => p_bgp_id
    );
  fetch c_getprevbgpactid into l_efc_action_id;
  if c_getprevbgpactid%found then
    --
    -- Remove action information for the business group
    --
    delete from BEN_ENRT_RT_EFC
    where EFC_ACTION_ID = l_efc_action_id;
    --
    delete from ben_prtt_rt_val_efc
    where EFC_ACTION_ID = l_efc_action_id;
    --
    delete from PAY_ELEMENT_ENTRY_VALUES_F_efc
    where EFC_ACTION_ID = l_efc_action_id;
    --
    delete from HR_EFC_WORKER_AUDITS
    where exists (select efc_worker_id
       from HR_EFC_WORKERS
       where efc_action_id = l_efc_action_id);
    --
    delete from HR_EFC_WORKERS
    where efc_action_id = l_efc_action_id;
    --
    delete from HR_EFC_PROCESS_COMPONENTS
    where efc_action_id = l_efc_action_id;
    --
    delete from HR_EFC_ROUNDING_ERRORS
    where efc_action_id = l_efc_action_id;
    --
    delete from hr_efc_actions
    where efc_action_id = l_efc_action_id;
    --
    commit;
    --
  end if;
  close c_getprevbgpactid;
  --
  -- Simulate a conversion for each business group
  --
  -- Write an EFC action for the BGP
  --
  ben_efc_functions.BGP_WriteEFCAction
    (p_bgp_id        => p_bgp_id
    --
    ,p_efc_action_id => p_efc_action_id
    );
  --
END BGP_SetupEFCAction;
--
/*
procedure BGP_GetEFCActDetails
  (p_bgp_id      in     number
  --
  ,p_efcact_dets    out nocopy gc_currefcact%rowtype
  )
is
  --
  l_proc           varchar2(1000) := 'BGP_GetEFCActDetails';
  --

  --
BEGIN
  --
  open gc_currefcact
    (c_bgp_id => p_bgp_id
    );
  fetch gc_currefcact into p_efcact_dets;
  close gc_currefcact;
  --
END BGP_GetEFCActDetails;
--
*/
function CurrCode_IsNCU
  (p_curr_code   in     varchar2
  )
return boolean
is
  --
  l_proc varchar2(1000) := 'CurrCode_IsNCU';
  --
  cursor c_ncu
    (c_curr_code varchar2
    )
  is
    select 1
    from hr_ncu_currencies
    where currency_code = c_curr_code;
  --
  l_ncu c_ncu%rowtype;
  --
BEGIN
  --
  open c_ncu
    (c_curr_code => p_curr_code
    );
  fetch c_ncu into l_ncu;
  if c_ncu%notfound then
    --
    return FALSE;
    --
  else
    --
    return TRUE;
    --
  end if;
  close c_ncu;
  --
END CurrCode_IsNCU;
--
function UOM_IsCurrency
  (p_uom   in     varchar2
  )
return boolean
is
  --
  l_proc varchar2(1000) := 'UOM_IsCurrency';
  --
  cursor c_currency
    (c_uom varchar2
    )
  is
    select 1
    from fnd_currencies
    where currency_code = c_uom;
  --
  l_currency c_currency%rowtype;
  --
BEGIN
  --
  open c_currency
    (c_uom => p_uom
    );
  fetch c_currency into l_currency;
  if c_currency%notfound then
    --
    return FALSE;
    --
  else
    --
    return TRUE;
    --
  end if;
  close c_currency;
  --
END UOM_IsCurrency;
--
procedure CompObject_GetParUom
  (p_pgm_id      in     number
  ,p_ptip_id     in     number
  ,p_pl_id       in     number
  ,p_plip_id     in     number
  ,p_oipl_id     in     number
  ,p_oiplip_id   in     number
  ,p_eff_date    in     date
  --
  ,p_paruom         out nocopy varchar2
  ,p_faterr_code    out nocopy varchar2
  ,p_faterr_type    out nocopy varchar2
  )
is
  --
  l_proc varchar2(1000) := 'CompObject_GetParUom';
  --
  l_par_pgm_id  number;
  l_par_pl_id   number;
  --
  cursor c_pgmdets
    (c_pgm_id   number
    ,c_eff_date date
    )
  is
    select pgm.pgm_uom
    from ben_pgm_f pgm
    where pgm.pgm_id = c_pgm_id
    and   c_eff_date
      between pgm.effective_start_date and pgm.effective_end_date;
  --
  l_pgmdets      c_pgmdets%rowtype;
  --
  cursor c_plnipdets
    (c_pln_id   number
    ,c_eff_date date
    )
  is
    select pln.nip_pl_uom
    from ben_pl_f pln
    where pln.pl_id = c_pln_id
    and   c_eff_date
      between pln.effective_start_date and pln.effective_end_date;
  --
  l_plnipdets   c_plnipdets%rowtype;
  --
BEGIN
  --
  l_par_pgm_id := ben_global_functions.get_par_pgm_id
                    (p_pgm_id
                    ,p_ptip_id
                    ,p_pl_id
                    ,p_plip_id
                    ,p_oipl_id
                    ,p_oiplip_id
                    );
  --
  if l_par_pgm_id is null then
    --
    l_par_pl_id := ben_global_functions.get_par_plnip_id
                     (p_pl_id
                     ,p_oipl_id
                     );
    --
  end if;
  --
  if l_par_pgm_id is not null
  then
    --
    open c_pgmdets
      (c_pgm_id   => l_par_pgm_id
      ,c_eff_date => p_eff_date
      );
    fetch c_pgmdets into l_pgmdets;
    if c_pgmdets%notfound then
      --
      p_faterr_code := 'NOPRVABRPGM';
      p_faterr_type := 'DATACORRUPT';
      --
    end if;
    close c_pgmdets;
    --
    p_paruom := l_pgmdets.pgm_uom;
    --
  elsif l_par_pgm_id is null
    and l_par_pl_id is not null
  then
    --
    open c_plnipdets
      (c_pln_id   => l_par_pl_id
      ,c_eff_date => p_eff_date
      );
    fetch c_plnipdets into l_plnipdets;
    if c_plnipdets%notfound then
      --
      p_faterr_code := 'NOPRVABRPLNIP';
      p_faterr_type := 'DATACORRUPT';
      --
    end if;
    close c_plnipdets;
    --
    p_paruom := l_plnipdets.nip_pl_uom;
    --
  end if;
  --
END CompObject_GetParUom;
--
end ben_efc_functions;

/
