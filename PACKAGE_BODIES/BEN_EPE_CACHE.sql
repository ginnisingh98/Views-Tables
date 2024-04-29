--------------------------------------------------------
--  DDL for Package Body BEN_EPE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPE_CACHE" as
/* $Header: benepech.pkb 120.0 2005/05/28 08:59:01 appldev noship $ */
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
  115.0      07-Aug-00	mhoyes     Created.
  115.1      05-Jan-01  kmahendr   Added parameter per_in_ler_id
  115.2      31-Jan-01  mhoyes   - Added new columns to cache for use with EFC
                                 - Removed STRTD life event restriction.
  115.3      03-Jul-01  tmathers   9i compliance fixes.
  115.4      09-Jul-01  tmathers   9i compliance fixes after test db came back.
  115.5      01-Aug-01  ikasire    added in_pndg_wkflow_flag to epe
  115.6      13-Aug-01  mhoyes   - Added bnft_prvdr_pool_id to type.
                                 - Added EPE_GetEPEDets.
  115.7      13-Sep-01  mhoyes   - EFC tuning.
  115.8      11-Dec-01  mhoyes   - Added get_pilcobjepe_dets.
  115.9      12 Jun 02  mhoyes   - Performance tuning. Split cursors in
                                   get_pilcobjepe_dets.
  115.10     12 Aug 03  pbodla   - Bug 1240957 : Added "order by PTIP_ORDR_NUM,
                                   PLIP_ORDR_NUM, OIPL_ORDR_NUM, PL_ORDR_NUM"
                                   to electable choice selection cursors
                                   (c_instance) - to enable rates with
                                   post enrollment rule calculated properly
  115.11     12-Apr-04  kmahendr - Added three columns to cache.
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_epe_cache.';
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
-- 0 - Always refresh
-- 1 - Initialise cache
-- 2 - Cache hit
--
g_pilepe_instance     g_pilepe_inst_tbl;
g_pilepe_cached       pls_integer := 0;
g_perepe_cached       pls_integer := 0;
g_enbepe_cached       pls_integer := 0;
g_epe_cached          pls_integer := 0;
--
type g_current_row is record
  (per_in_ler_id number
  );
--
g_enbepe_current g_current_row;
g_epe_current    g_current_row;
--
procedure write_pilepe_cache
  (p_person_id     in     number
  ,p_per_in_ler_id in     number
  )
is
  --
  l_elig_per_elctbl_chc_id_va benutils.g_number_table := benutils.g_number_table();
  l_business_group_id_va      benutils.g_number_table := benutils.g_number_table();
  l_person_id_va              benutils.g_number_table := benutils.g_number_table();
  l_ler_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_LF_EVT_OCRD_DT_va         benutils.g_date_table   := benutils.g_date_table();
  l_per_in_ler_stat_cd_va     benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_per_in_ler_id_va          benutils.g_number_table := benutils.g_number_table();
  l_pgm_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_pl_typ_id_va              benutils.g_number_table := benutils.g_number_table();
  l_ptip_id_va                benutils.g_number_table := benutils.g_number_table();
  l_plip_id_va                benutils.g_number_table := benutils.g_number_table();
  l_pl_id_va                  benutils.g_number_table := benutils.g_number_table();
  l_oipl_id_va                benutils.g_number_table := benutils.g_number_table();
  l_oiplip_id_va              benutils.g_number_table := benutils.g_number_table();
  l_opt_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_enrt_perd_id_va           benutils.g_number_table := benutils.g_number_table();
  l_lee_rsn_id_va             benutils.g_number_table := benutils.g_number_table();
  l_enrt_perd_strt_dt_va      benutils.g_date_table   := benutils.g_date_table();
  l_prtt_enrt_rslt_id_va      benutils.g_number_table := benutils.g_number_table();
  l_enrt_cvg_strt_dt_va       benutils.g_date_table   := benutils.g_date_table();
  l_enrt_cvg_strt_dt_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_enrt_cvg_strt_dt_rl_va    benutils.g_number_table := benutils.g_number_table();
  l_yr_perd_id_va             benutils.g_number_table := benutils.g_number_table();
  l_comp_lvl_cd_va            benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_cmbn_plip_id_va           benutils.g_number_table := benutils.g_number_table();
  l_cmbn_ptip_id_va           benutils.g_number_table := benutils.g_number_table();
  l_cmbn_ptip_opt_id_va       benutils.g_number_table := benutils.g_number_table();
  l_dflt_flag_va              benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ctfn_rqd_flag_va          benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_enrt_bnft_id_va           benutils.g_number_table := benutils.g_number_table();
  l_val_va                    benutils.g_number_table := benutils.g_number_table();
  l_acty_ref_perd_cd_va       benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_elctbl_flag_va            benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_object_version_number_va  benutils.g_number_table := benutils.g_number_table();
  l_alws_dpnt_dsgn_flag_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_dsgn_cd_va           benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ler_chg_dpnt_cvg_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_cvg_strt_dt_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_cvg_strt_dt_rl_va    benutils.g_number_table := benutils.g_number_table();
  l_in_pndg_wkflow_flag_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_bnft_prvdr_pool_id_va     benutils.g_number_table := benutils.g_number_table();
  l_elig_flag_va              benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_inelig_rsn_cd_va          benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_fonm_cvg_strt_dt_va       benutils.g_date_table   := benutils.g_date_table();
  --
  l_ele_num                   pls_integer;
  --
  CURSOR c_instance
    (c_person_id     in    number
    ,c_per_in_ler_id in    number
    )
  IS
    SELECT   epe.elig_per_elctbl_chc_id,
             epe.business_group_id,
             pil.person_id,
             pil.ler_id,
             pil.LF_EVT_OCRD_DT,
             pil.per_in_ler_stat_cd,
             epe.per_in_ler_id,
             epe.pgm_id,
             epe.pl_typ_id,
             epe.ptip_id,
             epe.plip_id,
             epe.pl_id,
             epe.oipl_id,
             epe.oiplip_id,
             null opt_id,
             pel.enrt_perd_id,
             pel.lee_rsn_id,
             pel.enrt_perd_strt_dt,
             epe.prtt_enrt_rslt_id,
             epe.enrt_cvg_strt_dt,
             epe.enrt_cvg_strt_dt_cd,
             epe.enrt_cvg_strt_dt_rl,
             epe.yr_perd_id,
             epe.comp_lvl_cd,
             epe.cmbn_plip_id,
             epe.cmbn_ptip_id,
             epe.cmbn_ptip_opt_id,
             epe.dflt_flag,
             epe.ctfn_rqd_flag,
             enb.enrt_bnft_id,
             enb.val,
             pel.acty_ref_perd_cd,
             epe.elctbl_flag,
             epe.object_version_number,
             epe.alws_dpnt_dsgn_flag,
             epe.dpnt_dsgn_cd,
             epe.ler_chg_dpnt_cvg_cd,
             epe.dpnt_cvg_strt_dt_cd,
             epe.dpnt_cvg_strt_dt_rl,
             epe.in_pndg_wkflow_flag,
             epe.bnft_prvdr_pool_id,
             epe.elig_flag,
             epe.inelig_rsn_cd,
             epe.fonm_cvg_strt_dt
/* removed the following as they are explicitly nulled later
   9i compliance.,
             null,
             null,
             null,
             null,
             null,
             null,
             null */
    FROM     ben_elig_per_elctbl_chc epe,
             ben_pil_elctbl_chc_popl pel,
             ben_enrt_bnft enb,
             ben_per_in_ler pil
    WHERE    epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id (+)
    AND      epe.per_in_ler_id = pil.per_in_ler_id
    AND      epe.per_in_ler_id = pel.per_in_ler_id
    AND      epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
    --
    -- Removed for EFC. This cache is intended to support all electable
    -- choice information for all types of life event. It should not be
    -- restricted to started life event electable choices only
    --
/*
    AND      pil.per_in_ler_stat_cd = 'STRTD'
*/
--  added for unrestricted enhancement
    and      pil.per_in_ler_id = c_per_in_ler_id
    AND      pil.person_id     = c_person_id
    order by epe.PTIP_ORDR_NUM, PLIP_ORDR_NUM,
             decode(PL_ORDR_NUM, null, OIPL_ORDR_NUM, PL_ORDR_NUM),
             PL_ORDR_NUM,
             decode(PL_ORDR_NUM, null, null, OIPL_ORDR_NUM);
  --
begin
  --
  l_ele_num := 0;
  --
  open c_instance
    (c_person_id     => p_person_id
    ,c_per_in_ler_id => p_per_in_ler_id
    );
  fetch c_instance BULK COLLECT INTO l_elig_per_elctbl_chc_id_va,
                                     l_business_group_id_va,
                                     l_person_id_va,
                                     l_ler_id_va,
                                     l_LF_EVT_OCRD_DT_va,
                                     l_per_in_ler_stat_cd_va,
                                     l_per_in_ler_id_va,
                                     l_pgm_id_va,
                                     l_pl_typ_id_va,
                                     l_ptip_id_va,
                                     l_plip_id_va,
                                     l_pl_id_va,
                                     l_oipl_id_va,
                                     l_oiplip_id_va,
                                     l_opt_id_va,
                                     l_enrt_perd_id_va,
                                     l_lee_rsn_id_va,
                                     l_enrt_perd_strt_dt_va,
                                     l_prtt_enrt_rslt_id_va,
                                     l_enrt_cvg_strt_dt_va,
                                     l_enrt_cvg_strt_dt_cd_va,
                                     l_enrt_cvg_strt_dt_rl_va,
                                     l_yr_perd_id_va,
                                     l_comp_lvl_cd_va,
                                     l_cmbn_plip_id_va,
                                     l_cmbn_ptip_id_va,
                                     l_cmbn_ptip_opt_id_va,
                                     l_dflt_flag_va,
                                     l_ctfn_rqd_flag_va,
                                     l_enrt_bnft_id_va,
                                     l_val_va,
                                     l_acty_ref_perd_cd_va,
                                     l_elctbl_flag_va,
                                     l_object_version_number_va,
                                     l_alws_dpnt_dsgn_flag_va,
                                     l_dpnt_dsgn_cd_va,
                                     l_ler_chg_dpnt_cvg_cd_va,
                                     l_dpnt_cvg_strt_dt_cd_va,
                                     l_dpnt_cvg_strt_dt_rl_va,
                                     l_in_pndg_wkflow_flag_va,
                                     l_bnft_prvdr_pool_id_va,
                                     l_elig_flag_va,
                                     l_inelig_rsn_cd_va,
                                     l_fonm_cvg_strt_dt_va;
  close c_instance;
  --
  if l_elig_per_elctbl_chc_id_va.count > 0 then
    --
    for i in l_elig_per_elctbl_chc_id_va.first..l_elig_per_elctbl_chc_id_va.last
    loop
      --
      g_pilepe_instance(l_ele_num).elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id_va(i);
      g_pilepe_instance(l_ele_num).business_group_id      := l_business_group_id_va(i);
      g_pilepe_instance(l_ele_num).person_id              := l_person_id_va(i);
      g_pilepe_instance(l_ele_num).ler_id                 := l_ler_id_va(i);
      g_pilepe_instance(l_ele_num).LF_EVT_OCRD_DT         := l_LF_EVT_OCRD_DT_va(i);
      g_pilepe_instance(l_ele_num).per_in_ler_stat_cd     := l_per_in_ler_stat_cd_va(i);
      g_pilepe_instance(l_ele_num).per_in_ler_id          := l_per_in_ler_id_va(i);
      g_pilepe_instance(l_ele_num).pgm_id                 := l_pgm_id_va(i);
      g_pilepe_instance(l_ele_num).pl_typ_id              := l_pl_typ_id_va(i);
      g_pilepe_instance(l_ele_num).ptip_id                := l_ptip_id_va(i);
      g_pilepe_instance(l_ele_num).plip_id                := l_plip_id_va(i);
      g_pilepe_instance(l_ele_num).pl_id                  := l_pl_id_va(i);
      g_pilepe_instance(l_ele_num).oipl_id                := l_oipl_id_va(i);
      g_pilepe_instance(l_ele_num).oiplip_id              := l_oiplip_id_va(i);
      g_pilepe_instance(l_ele_num).opt_id                 := null;
      g_pilepe_instance(l_ele_num).enrt_perd_id           := l_enrt_perd_id_va(i);
      g_pilepe_instance(l_ele_num).lee_rsn_id             := l_lee_rsn_id_va(i);
      g_pilepe_instance(l_ele_num).enrt_perd_strt_dt      := l_enrt_perd_strt_dt_va(i);
      g_pilepe_instance(l_ele_num).prtt_enrt_rslt_id      := l_prtt_enrt_rslt_id_va(i);
      g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt       := l_enrt_cvg_strt_dt_va(i);
      g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt_cd    := l_enrt_cvg_strt_dt_cd_va(i);
      g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt_rl    := l_enrt_cvg_strt_dt_rl_va(i);
      g_pilepe_instance(l_ele_num).yr_perd_id             := l_yr_perd_id_va(i);
      g_pilepe_instance(l_ele_num).comp_lvl_cd            := l_comp_lvl_cd_va(i);
      g_pilepe_instance(l_ele_num).cmbn_plip_id           := l_cmbn_plip_id_va(i);
      g_pilepe_instance(l_ele_num).cmbn_ptip_id           := l_cmbn_ptip_id_va(i);
      g_pilepe_instance(l_ele_num).cmbn_ptip_opt_id       := l_cmbn_ptip_opt_id_va(i);
      g_pilepe_instance(l_ele_num).dflt_flag              := l_dflt_flag_va(i);
      g_pilepe_instance(l_ele_num).ctfn_rqd_flag          := l_ctfn_rqd_flag_va(i);
      g_pilepe_instance(l_ele_num).enrt_bnft_id           := l_enrt_bnft_id_va(i);
      g_pilepe_instance(l_ele_num).val                    := l_val_va(i);
      g_pilepe_instance(l_ele_num).acty_ref_perd_cd       := l_acty_ref_perd_cd_va(i);
      g_pilepe_instance(l_ele_num).elctbl_flag            := l_elctbl_flag_va(i);
      g_pilepe_instance(l_ele_num).object_version_number  := l_object_version_number_va(i);
      g_pilepe_instance(l_ele_num).alws_dpnt_dsgn_flag    := l_alws_dpnt_dsgn_flag_va(i);
      g_pilepe_instance(l_ele_num).dpnt_dsgn_cd           := l_dpnt_dsgn_cd_va(i);
      g_pilepe_instance(l_ele_num).ler_chg_dpnt_cvg_cd    := l_ler_chg_dpnt_cvg_cd_va(i);
      g_pilepe_instance(l_ele_num).dpnt_cvg_strt_dt_cd    := l_dpnt_cvg_strt_dt_cd_va(i);
      g_pilepe_instance(l_ele_num).dpnt_cvg_strt_dt_rl    := l_dpnt_cvg_strt_dt_rl_va(i);
      g_pilepe_instance(l_ele_num).in_pndg_wkflow_flag    := l_in_pndg_wkflow_flag_va(i);
      g_pilepe_instance(l_ele_num).bnft_prvdr_pool_id     := l_bnft_prvdr_pool_id_va(i);
      --
      g_pilepe_instance(l_ele_num).elig_flag              := l_elig_flag_va(i);
      g_pilepe_instance(l_ele_num).inelig_rsn_cd          := l_inelig_rsn_cd_va(i);
      g_pilepe_instance(l_ele_num).fonm_cvg_strt_dt       := l_fonm_cvg_strt_dt_va(i);
      g_pilepe_instance(l_ele_num).prtn_strt_dt           := null;
      g_pilepe_instance(l_ele_num).prtn_ovridn_flag       := null;
      g_pilepe_instance(l_ele_num).prtn_ovridn_thru_dt    := null;
      g_pilepe_instance(l_ele_num).rt_age_val             := null;
      g_pilepe_instance(l_ele_num).rt_los_val             := null;
      g_pilepe_instance(l_ele_num).rt_hrs_wkd_val         := null;
      g_pilepe_instance(l_ele_num).rt_cmbn_age_n_los_val  := null;
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
/*
  for row in c_instance
    (c_person_id     => p_person_id
    ,c_per_in_ler_id => p_per_in_ler_id
    )
  loop
    --
    g_pilepe_instance(l_ele_num).elig_per_elctbl_chc_id  := row.elig_per_elctbl_chc_id;
    g_pilepe_instance(l_ele_num).business_group_id       := row.business_group_id;
    g_pilepe_instance(l_ele_num).person_id               := row.person_id;
    g_pilepe_instance(l_ele_num).ler_id                  := row.ler_id;
    g_pilepe_instance(l_ele_num).LF_EVT_OCRD_DT          := row.LF_EVT_OCRD_DT;
    g_pilepe_instance(l_ele_num).per_in_ler_stat_cd      := row.per_in_ler_stat_cd;
    g_pilepe_instance(l_ele_num).per_in_ler_id           := row.per_in_ler_id;
    g_pilepe_instance(l_ele_num).pgm_id                  := row.pgm_id;
    g_pilepe_instance(l_ele_num).pl_typ_id               := row.pl_typ_id;
    g_pilepe_instance(l_ele_num).ptip_id                 := row.ptip_id;
    g_pilepe_instance(l_ele_num).plip_id                 := row.plip_id;
    g_pilepe_instance(l_ele_num).pl_id                   := row.pl_id;
    g_pilepe_instance(l_ele_num).oipl_id                 := row.oipl_id;
    g_pilepe_instance(l_ele_num).oiplip_id               := row.oiplip_id;
    g_pilepe_instance(l_ele_num).comp_lvl_cd             := row.comp_lvl_cd;
    g_pilepe_instance(l_ele_num).cmbn_plip_id            := row.cmbn_plip_id;
    g_pilepe_instance(l_ele_num).cmbn_ptip_id            := row.cmbn_ptip_id;
    g_pilepe_instance(l_ele_num).cmbn_ptip_opt_id        := row.cmbn_ptip_opt_id;
    g_pilepe_instance(l_ele_num).dflt_flag               := row.dflt_flag;
    g_pilepe_instance(l_ele_num).ctfn_rqd_flag           := row.ctfn_rqd_flag;
    g_pilepe_instance(l_ele_num).prtt_enrt_rslt_id       := row.prtt_enrt_rslt_id;
    g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt        := row.enrt_cvg_strt_dt;
    g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt_cd     := row.enrt_cvg_strt_dt_cd;
    g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt_rl     := row.enrt_cvg_strt_dt_rl;
    g_pilepe_instance(l_ele_num).yr_perd_id              := row.yr_perd_id;
    g_pilepe_instance(l_ele_num).enrt_bnft_id            := row.enrt_bnft_id;
    g_pilepe_instance(l_ele_num).val                     := row.val;
    g_pilepe_instance(l_ele_num).enrt_perd_strt_dt       := row.enrt_perd_strt_dt;
    g_pilepe_instance(l_ele_num).enrt_perd_id            := row.enrt_perd_id;
    g_pilepe_instance(l_ele_num).lee_rsn_id              := row.lee_rsn_id;
    g_pilepe_instance(l_ele_num).acty_ref_perd_cd        := row.acty_ref_perd_cd;
    g_pilepe_instance(l_ele_num).elctbl_flag             := row.elctbl_flag;
    g_pilepe_instance(l_ele_num).object_version_number   := row.object_version_number;
    g_pilepe_instance(l_ele_num).alws_dpnt_dsgn_flag     := row.alws_dpnt_dsgn_flag;
    g_pilepe_instance(l_ele_num).dpnt_dsgn_cd            := row.dpnt_dsgn_cd;
    g_pilepe_instance(l_ele_num).ler_chg_dpnt_cvg_cd     := row.ler_chg_dpnt_cvg_cd;
    g_pilepe_instance(l_ele_num).dpnt_cvg_strt_dt_cd     := row.dpnt_cvg_strt_dt_cd;
    g_pilepe_instance(l_ele_num).dpnt_cvg_strt_dt_rl     := row.dpnt_cvg_strt_dt_rl;
    g_pilepe_instance(l_ele_num).in_pndg_wkflow_flag     := row.in_pndg_wkflow_flag;
    g_pilepe_instance(l_ele_num).bnft_prvdr_pool_id      := row.bnft_prvdr_pool_id;
    --
    g_pilepe_instance(l_ele_num).opt_id                  := null;
    g_pilepe_instance(l_ele_num).prtn_strt_dt            := null;
    g_pilepe_instance(l_ele_num).prtn_ovridn_flag        := null;
    g_pilepe_instance(l_ele_num).prtn_ovridn_thru_dt     := null;
    g_pilepe_instance(l_ele_num).rt_age_val              := null;
    g_pilepe_instance(l_ele_num).rt_los_val              := null;
    g_pilepe_instance(l_ele_num).rt_hrs_wkd_val          := null;
    g_pilepe_instance(l_ele_num).rt_cmbn_age_n_los_val   := null;
    l_ele_num := l_ele_num+1;
    --
  end loop;
*/
  --
  -- Check for no rows found
  --
  if l_ele_num = 0 then
    --
    g_pilepe_instance.delete;
    --
  end if;
  --
end write_pilepe_cache;
--
procedure get_perpilepe_list
  (p_person_id in     number
  ,p_per_in_ler_id  in number
  ,p_inst_set  in out NOCOPY g_pilepe_inst_tbl
  )
is
  --
  l_proc varchar2(72) :=  'get_perpilepe_list';
  --
begin
  --
  -- check comp object type
  --
  if g_pilepe_cached < 2
  then
    --
    -- Write the cache
    --
    write_pilepe_cache
      (p_person_id => p_person_id
      ,p_per_in_ler_id =>p_per_in_ler_id
      );
    --
    if g_pilepe_cached = 1
    then
      --
      g_pilepe_cached := 2;
      --
    end if;
    --
  end if;
  --
  p_inst_set := g_pilepe_instance;
  --
end get_perpilepe_list;
--
procedure write_ENBEPE_cache
  (p_per_in_ler_id in     number
  )
is
  --
  l_proc varchar2(72) :=  'write_ENBEPE_cache';
  --
  l_elig_per_elctbl_chc_id_va benutils.g_number_table := benutils.g_number_table();
  l_business_group_id_va      benutils.g_number_table := benutils.g_number_table();
  l_person_id_va              benutils.g_number_table := benutils.g_number_table();
  l_ler_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_LF_EVT_OCRD_DT_va         benutils.g_date_table   := benutils.g_date_table();
  l_per_in_ler_stat_cd_va     benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_per_in_ler_id_va          benutils.g_number_table := benutils.g_number_table();
  l_pgm_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_pl_typ_id_va              benutils.g_number_table := benutils.g_number_table();
  l_ptip_id_va                benutils.g_number_table := benutils.g_number_table();
  l_plip_id_va                benutils.g_number_table := benutils.g_number_table();
  l_pl_id_va                  benutils.g_number_table := benutils.g_number_table();
  l_oipl_id_va                benutils.g_number_table := benutils.g_number_table();
  l_oiplip_id_va              benutils.g_number_table := benutils.g_number_table();
  l_opt_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_enrt_perd_id_va           benutils.g_number_table := benutils.g_number_table();
  l_lee_rsn_id_va             benutils.g_number_table := benutils.g_number_table();
  l_enrt_perd_strt_dt_va      benutils.g_date_table   := benutils.g_date_table();
  l_prtt_enrt_rslt_id_va      benutils.g_number_table := benutils.g_number_table();
  l_enrt_cvg_strt_dt_va       benutils.g_date_table   := benutils.g_date_table();
  l_enrt_cvg_strt_dt_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_enrt_cvg_strt_dt_rl_va    benutils.g_number_table := benutils.g_number_table();
  l_yr_perd_id_va             benutils.g_number_table := benutils.g_number_table();
  l_comp_lvl_cd_va            benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_cmbn_plip_id_va           benutils.g_number_table := benutils.g_number_table();
  l_cmbn_ptip_id_va           benutils.g_number_table := benutils.g_number_table();
  l_cmbn_ptip_opt_id_va       benutils.g_number_table := benutils.g_number_table();
  l_dflt_flag_va              benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ctfn_rqd_flag_va          benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_enrt_bnft_id_va           benutils.g_number_table := benutils.g_number_table();
  l_val_va                    benutils.g_number_table := benutils.g_number_table();
  l_acty_ref_perd_cd_va       benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_elctbl_flag_va            benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_object_version_number_va  benutils.g_number_table := benutils.g_number_table();
  l_alws_dpnt_dsgn_flag_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_dsgn_cd_va           benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ler_chg_dpnt_cvg_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_cvg_strt_dt_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_cvg_strt_dt_rl_va    benutils.g_number_table := benutils.g_number_table();
  l_in_pndg_wkflow_flag_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_bnft_prvdr_pool_id_va     benutils.g_number_table := benutils.g_number_table();
  l_elig_flag_va              benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_inelig_rsn_cd_va          benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_fonm_cvg_strt_dt_va       benutils.g_date_table   := benutils.g_date_table();

  --
  l_hv              pls_integer;
  --
  CURSOR c_instance
    (c_per_in_ler_id in    number
    )
  IS
    SELECT   epe.elig_per_elctbl_chc_id,
             epe.business_group_id,
             pil.person_id,
             pil.ler_id,
             pil.LF_EVT_OCRD_DT,
             pil.per_in_ler_stat_cd,
             epe.per_in_ler_id,
             epe.pgm_id,
             epe.pl_typ_id,
             epe.ptip_id,
             epe.plip_id,
             epe.pl_id,
             epe.oipl_id,
             epe.oiplip_id,
             null opt_id,
             pel.enrt_perd_id,
             pel.lee_rsn_id,
             pel.enrt_perd_strt_dt,
             epe.prtt_enrt_rslt_id,
             epe.enrt_cvg_strt_dt,
             epe.enrt_cvg_strt_dt_cd,
             epe.enrt_cvg_strt_dt_rl,
             epe.yr_perd_id,
             epe.comp_lvl_cd,
             epe.cmbn_plip_id,
             epe.cmbn_ptip_id,
             epe.cmbn_ptip_opt_id,
             epe.dflt_flag,
             epe.ctfn_rqd_flag,
             enb.enrt_bnft_id,
             enb.val,
             pel.acty_ref_perd_cd,
/* removed the following as they are explicitly nulled later
   9i compliance.,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
*/
             epe.elctbl_flag,
             epe.object_version_number,
             epe.alws_dpnt_dsgn_flag,
             epe.dpnt_dsgn_cd,
             epe.ler_chg_dpnt_cvg_cd,
             epe.dpnt_cvg_strt_dt_cd,
             epe.dpnt_cvg_strt_dt_rl,
             epe.in_pndg_wkflow_flag,
             epe.bnft_prvdr_pool_id,
             epe.elig_flag,
             epe.inelig_rsn_cd,
             epe.fonm_cvg_strt_dt
    FROM     ben_enrt_bnft enb,
             ben_elig_per_elctbl_chc epe,
             ben_pil_elctbl_chc_popl pel,
             ben_per_in_ler pil
    WHERE    enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
    AND      epe.per_in_ler_id = pil.per_in_ler_id
    AND      epe.per_in_ler_id = pel.per_in_ler_id
    AND      epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
    and      pil.per_in_ler_id = c_per_in_ler_id
    order by epe.PTIP_ORDR_NUM, PLIP_ORDR_NUM,
             decode(PL_ORDR_NUM, null, OIPL_ORDR_NUM, PL_ORDR_NUM),
             PL_ORDR_NUM,
             decode(PL_ORDR_NUM, null, null, OIPL_ORDR_NUM);
  --
begin
  --
  open c_instance
    (c_per_in_ler_id => p_per_in_ler_id
    );
  fetch c_instance BULK COLLECT INTO l_elig_per_elctbl_chc_id_va,
                                     l_business_group_id_va,
                                     l_person_id_va,
                                     l_ler_id_va,
                                     l_LF_EVT_OCRD_DT_va,
                                     l_per_in_ler_stat_cd_va,
                                     l_per_in_ler_id_va,
                                     l_pgm_id_va,
                                     l_pl_typ_id_va,
                                     l_ptip_id_va,
                                     l_plip_id_va,
                                     l_pl_id_va,
                                     l_oipl_id_va,
                                     l_oiplip_id_va,
                                     l_opt_id_va,
                                     l_enrt_perd_id_va,
                                     l_lee_rsn_id_va,
                                     l_enrt_perd_strt_dt_va,
                                     l_prtt_enrt_rslt_id_va,
                                     l_enrt_cvg_strt_dt_va,
                                     l_enrt_cvg_strt_dt_cd_va,
                                     l_enrt_cvg_strt_dt_rl_va,
                                     l_yr_perd_id_va,
                                     l_comp_lvl_cd_va,
                                     l_cmbn_plip_id_va,
                                     l_cmbn_ptip_id_va,
                                     l_cmbn_ptip_opt_id_va,
                                     l_dflt_flag_va,
                                     l_ctfn_rqd_flag_va,
                                     l_enrt_bnft_id_va,
                                     l_val_va,
                                     l_acty_ref_perd_cd_va,
                                     l_elctbl_flag_va,
                                     l_object_version_number_va,
                                     l_alws_dpnt_dsgn_flag_va,
                                     l_dpnt_dsgn_cd_va,
                                     l_ler_chg_dpnt_cvg_cd_va,
                                     l_dpnt_cvg_strt_dt_cd_va,
                                     l_dpnt_cvg_strt_dt_rl_va,
                                     l_in_pndg_wkflow_flag_va,
                                     l_bnft_prvdr_pool_id_va,
                                     l_elig_flag_va,
                                     l_inelig_rsn_cd_va,
                                     l_fonm_cvg_strt_dt_va;
  close c_instance;
  --
  if l_enrt_bnft_id_va.count > 0 then
    --
    for i in l_enrt_bnft_id_va.first..l_enrt_bnft_id_va.last
    loop
      --
      l_hv := mod(l_enrt_bnft_id_va(i),ben_hash_utility.get_hash_key);
      --
      while g_enbepe_instance.exists(l_hv)
      loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
      g_enbepe_instance(l_hv).elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id_va(i);
      g_enbepe_instance(l_hv).business_group_id      := l_business_group_id_va(i);
      g_enbepe_instance(l_hv).person_id              := l_person_id_va(i);
      g_enbepe_instance(l_hv).ler_id                 := l_ler_id_va(i);
      g_enbepe_instance(l_hv).LF_EVT_OCRD_DT         := l_LF_EVT_OCRD_DT_va(i);
      g_enbepe_instance(l_hv).per_in_ler_stat_cd     := l_per_in_ler_stat_cd_va(i);
      g_enbepe_instance(l_hv).per_in_ler_id          := l_per_in_ler_id_va(i);
      g_enbepe_instance(l_hv).pgm_id                 := l_pgm_id_va(i);
      g_enbepe_instance(l_hv).pl_typ_id              := l_pl_typ_id_va(i);
      g_enbepe_instance(l_hv).ptip_id                := l_ptip_id_va(i);
      g_enbepe_instance(l_hv).plip_id                := l_plip_id_va(i);
      g_enbepe_instance(l_hv).pl_id                  := l_pl_id_va(i);
      g_enbepe_instance(l_hv).oipl_id                := l_oipl_id_va(i);
      g_enbepe_instance(l_hv).oiplip_id              := l_oiplip_id_va(i);
      g_enbepe_instance(l_hv).opt_id                 := null;
      g_enbepe_instance(l_hv).enrt_perd_id           := l_enrt_perd_id_va(i);
      g_enbepe_instance(l_hv).lee_rsn_id             := l_lee_rsn_id_va(i);
      g_enbepe_instance(l_hv).enrt_perd_strt_dt      := l_enrt_perd_strt_dt_va(i);
      g_enbepe_instance(l_hv).prtt_enrt_rslt_id      := l_prtt_enrt_rslt_id_va(i);
      g_enbepe_instance(l_hv).enrt_cvg_strt_dt       := l_enrt_cvg_strt_dt_va(i);
      g_enbepe_instance(l_hv).enrt_cvg_strt_dt_cd    := l_enrt_cvg_strt_dt_cd_va(i);
      g_enbepe_instance(l_hv).enrt_cvg_strt_dt_rl    := l_enrt_cvg_strt_dt_rl_va(i);
      g_enbepe_instance(l_hv).yr_perd_id             := l_yr_perd_id_va(i);
      g_enbepe_instance(l_hv).comp_lvl_cd            := l_comp_lvl_cd_va(i);
      g_enbepe_instance(l_hv).cmbn_plip_id           := l_cmbn_plip_id_va(i);
      g_enbepe_instance(l_hv).cmbn_ptip_id           := l_cmbn_ptip_id_va(i);
      g_enbepe_instance(l_hv).cmbn_ptip_opt_id       := l_cmbn_ptip_opt_id_va(i);
      g_enbepe_instance(l_hv).dflt_flag              := l_dflt_flag_va(i);
      g_enbepe_instance(l_hv).ctfn_rqd_flag          := l_ctfn_rqd_flag_va(i);
      g_enbepe_instance(l_hv).enrt_bnft_id           := l_enrt_bnft_id_va(i);
      g_enbepe_instance(l_hv).val                    := l_val_va(i);
      g_enbepe_instance(l_hv).acty_ref_perd_cd       := l_acty_ref_perd_cd_va(i);
      g_enbepe_instance(l_hv).elctbl_flag            := l_elctbl_flag_va(i);
      g_enbepe_instance(l_hv).object_version_number  := l_object_version_number_va(i);
      g_enbepe_instance(l_hv).alws_dpnt_dsgn_flag    := l_alws_dpnt_dsgn_flag_va(i);
      g_enbepe_instance(l_hv).dpnt_dsgn_cd           := l_dpnt_dsgn_cd_va(i);
      g_enbepe_instance(l_hv).ler_chg_dpnt_cvg_cd    := l_ler_chg_dpnt_cvg_cd_va(i);
      g_enbepe_instance(l_hv).dpnt_cvg_strt_dt_cd    := l_dpnt_cvg_strt_dt_cd_va(i);
      g_enbepe_instance(l_hv).dpnt_cvg_strt_dt_rl    := l_dpnt_cvg_strt_dt_rl_va(i);
      g_enbepe_instance(l_hv).in_pndg_wkflow_flag    := l_in_pndg_wkflow_flag_va(i);
      g_enbepe_instance(l_hv).bnft_prvdr_pool_id     := l_bnft_prvdr_pool_id_va(i);
      g_enbepe_instance(l_hv).elig_flag              := l_elig_flag_va(i);
      g_enbepe_instance(l_hv).inelig_rsn_cd          := l_inelig_rsn_cd_va(i);
      g_enbepe_instance(l_hv).fonm_cvg_strt_dt       := l_fonm_cvg_strt_dt_va(i);

      --
      g_enbepe_instance(l_hv).prtn_strt_dt           := null;
      g_enbepe_instance(l_hv).prtn_ovridn_flag       := null;
      g_enbepe_instance(l_hv).prtn_ovridn_thru_dt    := null;
      g_enbepe_instance(l_hv).rt_age_val             := null;
      g_enbepe_instance(l_hv).rt_los_val             := null;
      g_enbepe_instance(l_hv).rt_hrs_wkd_val         := null;
      g_enbepe_instance(l_hv).rt_cmbn_age_n_los_val  := null;
      --
    end loop;
    --
  end if;
  --
/*
  for objinst in c_instance
    (c_per_in_ler_id => p_per_in_ler_id
    )
  loop
    --
    l_hv := mod(objinst.enrt_bnft_id,ben_hash_utility.get_hash_key);
    --
    while g_enbepe_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_enbepe_instance(l_hv).elig_per_elctbl_chc_id  := objinst.elig_per_elctbl_chc_id;
    g_enbepe_instance(l_hv).business_group_id       := objinst.business_group_id;
    g_enbepe_instance(l_hv).person_id               := objinst.person_id;
    g_enbepe_instance(l_hv).ler_id                  := objinst.ler_id;
    g_enbepe_instance(l_hv).per_in_ler_id           := objinst.per_in_ler_id;
    g_enbepe_instance(l_hv).LF_EVT_OCRD_DT          := objinst.LF_EVT_OCRD_DT;
    g_enbepe_instance(l_hv).per_in_ler_stat_cd      := objinst.per_in_ler_stat_cd;
    g_enbepe_instance(l_hv).pgm_id                  := objinst.pgm_id;
    g_enbepe_instance(l_hv).pl_typ_id               := objinst.pl_typ_id;
    g_enbepe_instance(l_hv).ptip_id                 := objinst.ptip_id;
    g_enbepe_instance(l_hv).plip_id                 := objinst.plip_id;
    g_enbepe_instance(l_hv).pl_id                   := objinst.pl_id;
    g_enbepe_instance(l_hv).oipl_id                 := objinst.oipl_id;
    g_enbepe_instance(l_hv).oiplip_id               := objinst.oiplip_id;
    g_enbepe_instance(l_hv).comp_lvl_cd             := objinst.comp_lvl_cd;
    g_enbepe_instance(l_hv).cmbn_plip_id            := objinst.cmbn_plip_id;
    g_enbepe_instance(l_hv).cmbn_ptip_id            := objinst.cmbn_ptip_id;
    g_enbepe_instance(l_hv).cmbn_ptip_opt_id        := objinst.cmbn_ptip_opt_id;
    g_enbepe_instance(l_hv).dflt_flag               := objinst.dflt_flag;
    g_enbepe_instance(l_hv).ctfn_rqd_flag           := objinst.ctfn_rqd_flag;
    g_enbepe_instance(l_hv).prtt_enrt_rslt_id       := objinst.prtt_enrt_rslt_id;
    g_enbepe_instance(l_hv).enrt_cvg_strt_dt        := objinst.enrt_cvg_strt_dt;
    g_enbepe_instance(l_hv).enrt_cvg_strt_dt_cd     := objinst.enrt_cvg_strt_dt_cd;
    g_enbepe_instance(l_hv).enrt_cvg_strt_dt_rl     := objinst.enrt_cvg_strt_dt_rl;
    g_enbepe_instance(l_hv).yr_perd_id              := objinst.yr_perd_id;
    g_enbepe_instance(l_hv).enrt_bnft_id            := objinst.enrt_bnft_id;
    g_enbepe_instance(l_hv).val                     := objinst.val;
    g_enbepe_instance(l_hv).enrt_perd_strt_dt       := objinst.enrt_perd_strt_dt;
    g_enbepe_instance(l_hv).enrt_perd_id            := objinst.enrt_perd_id;
    g_enbepe_instance(l_hv).lee_rsn_id              := objinst.lee_rsn_id;
    g_enbepe_instance(l_hv).acty_ref_perd_cd        := objinst.acty_ref_perd_cd;
    g_enbepe_instance(l_hv).elctbl_flag             := objinst.elctbl_flag;
    g_enbepe_instance(l_hv).object_version_number   := objinst.object_version_number;
    g_enbepe_instance(l_hv).alws_dpnt_dsgn_flag     := objinst.alws_dpnt_dsgn_flag;
    g_enbepe_instance(l_hv).dpnt_dsgn_cd            := objinst.dpnt_dsgn_cd;
    g_enbepe_instance(l_hv).ler_chg_dpnt_cvg_cd     := objinst.ler_chg_dpnt_cvg_cd;
    g_enbepe_instance(l_hv).dpnt_cvg_strt_dt_cd     := objinst.dpnt_cvg_strt_dt_cd;
    g_enbepe_instance(l_hv).dpnt_cvg_strt_dt_rl     := objinst.dpnt_cvg_strt_dt_rl;
    g_enbepe_instance(l_hv).in_pndg_wkflow_flag     := objinst.in_pndg_wkflow_flag;
    --
    g_enbepe_instance(l_hv).opt_id                  := null;
    g_enbepe_instance(l_hv).prtn_strt_dt            := null;
    g_enbepe_instance(l_hv).prtn_ovridn_flag        := null;
    g_enbepe_instance(l_hv).prtn_ovridn_thru_dt     := null;
    g_enbepe_instance(l_hv).rt_age_val              := null;
    g_enbepe_instance(l_hv).rt_los_val              := null;
    g_enbepe_instance(l_hv).rt_hrs_wkd_val          := null;
    g_enbepe_instance(l_hv).rt_cmbn_age_n_los_val   := null;
    --
  end loop;
*/
  --
  -- Check for no rows found
  --
  if l_hv is null then
    --
    g_enbepe_instance.delete;
    g_enbepe_current.per_in_ler_id := null;
    --
  else
    --
    g_enbepe_current.per_in_ler_id := p_per_in_ler_id;
    --
  end if;
  --
end write_ENBEPE_cache;
--
procedure ENBEPE_GetEPEDets
  (p_enrt_bnft_id  in     number
  ,p_per_in_ler_id in     number
  ,p_inst_row      in out NOCOPY g_pilepe_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'ENBEPE_GetEPEDets';
  --
  l_hv      pls_integer;
  l_reset   g_pilepe_inst_row;
  --
begin
  --
  -- Check for already cached or a change in current PIL ID
  --
  if nvl(g_enbepe_current.per_in_ler_id,-9999) <> p_per_in_ler_id
    or g_pilepe_cached < 2
  then
    --
    -- Write the cache
    --
    write_ENBEPE_cache
      (p_per_in_ler_id => p_per_in_ler_id
      );
    --
    if g_pilepe_cached = 1
    then
      --
      g_pilepe_cached := 2;
      --
    end if;
    --
  end if;
  --
  -- Get the instance details
  --
  l_hv := mod(p_enrt_bnft_id,ben_hash_utility.get_hash_key);
  --
  if g_enbepe_instance(l_hv).enrt_bnft_id = p_enrt_bnft_id
  then
     -- Matched row
     null;
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    l_hv := l_hv+g_hash_jump;
    while g_enbepe_instance(l_hv).enrt_bnft_id <> p_enrt_bnft_id loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
  end if;
  --
  p_inst_row := g_enbepe_instance(l_hv);
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end ENBEPE_GetEPEDets;
--
procedure write_EPE_cache
  (p_per_in_ler_id in     number
  )
is
  --
  l_proc varchar2(72) :=  'write_EPE_cache';
  --
  l_elig_per_elctbl_chc_id_va benutils.g_number_table := benutils.g_number_table();
  l_business_group_id_va      benutils.g_number_table := benutils.g_number_table();
  l_person_id_va              benutils.g_number_table := benutils.g_number_table();
  l_ler_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_LF_EVT_OCRD_DT_va         benutils.g_date_table   := benutils.g_date_table();
  l_per_in_ler_stat_cd_va     benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_per_in_ler_id_va          benutils.g_number_table := benutils.g_number_table();
  l_pgm_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_pl_typ_id_va              benutils.g_number_table := benutils.g_number_table();
  l_ptip_id_va                benutils.g_number_table := benutils.g_number_table();
  l_plip_id_va                benutils.g_number_table := benutils.g_number_table();
  l_pl_id_va                  benutils.g_number_table := benutils.g_number_table();
  l_oipl_id_va                benutils.g_number_table := benutils.g_number_table();
  l_oiplip_id_va              benutils.g_number_table := benutils.g_number_table();
  l_opt_id_va                 benutils.g_number_table := benutils.g_number_table();
  l_enrt_perd_id_va           benutils.g_number_table := benutils.g_number_table();
  l_lee_rsn_id_va             benutils.g_number_table := benutils.g_number_table();
  l_enrt_perd_strt_dt_va      benutils.g_date_table   := benutils.g_date_table();
  l_prtt_enrt_rslt_id_va      benutils.g_number_table := benutils.g_number_table();
  l_enrt_cvg_strt_dt_va       benutils.g_date_table   := benutils.g_date_table();
  l_enrt_cvg_strt_dt_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_enrt_cvg_strt_dt_rl_va    benutils.g_number_table := benutils.g_number_table();
  l_yr_perd_id_va             benutils.g_number_table := benutils.g_number_table();
  l_comp_lvl_cd_va            benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_cmbn_plip_id_va           benutils.g_number_table := benutils.g_number_table();
  l_cmbn_ptip_id_va           benutils.g_number_table := benutils.g_number_table();
  l_cmbn_ptip_opt_id_va       benutils.g_number_table := benutils.g_number_table();
  l_dflt_flag_va              benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ctfn_rqd_flag_va          benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_enrt_bnft_id_va           benutils.g_number_table := benutils.g_number_table();
  l_val_va                    benutils.g_number_table := benutils.g_number_table();
  l_acty_ref_perd_cd_va       benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_elctbl_flag_va            benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_object_version_number_va  benutils.g_number_table := benutils.g_number_table();
  l_alws_dpnt_dsgn_flag_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_dsgn_cd_va           benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_ler_chg_dpnt_cvg_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_cvg_strt_dt_cd_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_dpnt_cvg_strt_dt_rl_va    benutils.g_number_table := benutils.g_number_table();
  l_in_pndg_wkflow_flag_va    benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_bnft_prvdr_pool_id_va     benutils.g_number_table := benutils.g_number_table();
  l_elig_flag_va              benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_inelig_rsn_cd_va          benutils.g_v2_30_table  := benutils.g_v2_30_table();
  l_fonm_cvg_strt_dt_va       benutils.g_date_table   := benutils.g_date_table();

  --
  l_hv                        pls_integer;
  --
  CURSOR c_instance
    (c_per_in_ler_id in    number
    )
  IS
    SELECT   epe.elig_per_elctbl_chc_id,
             epe.business_group_id,
             pil.person_id,
             pil.ler_id,
             pil.LF_EVT_OCRD_DT,
             pil.per_in_ler_stat_cd,
             epe.per_in_ler_id,
             epe.pgm_id,
             epe.pl_typ_id,
             epe.ptip_id,
             epe.plip_id,
             epe.pl_id,
             epe.oipl_id,
             epe.oiplip_id,
             null opt_id,
             pel.enrt_perd_id,
             pel.lee_rsn_id,
             pel.enrt_perd_strt_dt,
             epe.prtt_enrt_rslt_id,
             epe.enrt_cvg_strt_dt,
             epe.enrt_cvg_strt_dt_cd,
             epe.enrt_cvg_strt_dt_rl,
             epe.yr_perd_id,
             epe.comp_lvl_cd,
             epe.cmbn_plip_id,
             epe.cmbn_ptip_id,
             epe.cmbn_ptip_opt_id,
             epe.dflt_flag,
             epe.ctfn_rqd_flag,
             enb.enrt_bnft_id,
             enb.val,
             pel.acty_ref_perd_cd,
             epe.elctbl_flag,
             epe.object_version_number,
             epe.alws_dpnt_dsgn_flag,
             epe.dpnt_dsgn_cd,
             epe.ler_chg_dpnt_cvg_cd,
             epe.dpnt_cvg_strt_dt_cd,
             epe.dpnt_cvg_strt_dt_rl,
             epe.in_pndg_wkflow_flag,
             epe.bnft_prvdr_pool_id,
             epe.elig_flag,
             epe.inelig_rsn_cd,
             epe.fonm_cvg_strt_dt
    FROM     ben_elig_per_elctbl_chc epe,
             ben_pil_elctbl_chc_popl pel,
             ben_enrt_bnft enb,
             ben_per_in_ler pil
    WHERE    epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id (+)
    AND      epe.per_in_ler_id = pil.per_in_ler_id
    AND      epe.per_in_ler_id = pel.per_in_ler_id
    AND      epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
    and      pil.per_in_ler_id = c_per_in_ler_id
    order by epe.PTIP_ORDR_NUM, PLIP_ORDR_NUM,
             decode(PL_ORDR_NUM, null, OIPL_ORDR_NUM, PL_ORDR_NUM),
             PL_ORDR_NUM,
             decode(PL_ORDR_NUM, null, null, OIPL_ORDR_NUM);
  --
begin
  --
  open c_instance
    (c_per_in_ler_id => p_per_in_ler_id
    );
  fetch c_instance BULK COLLECT INTO l_elig_per_elctbl_chc_id_va,
                                     l_business_group_id_va,
                                     l_person_id_va,
                                     l_ler_id_va,
                                     l_LF_EVT_OCRD_DT_va,
                                     l_per_in_ler_stat_cd_va,
                                     l_per_in_ler_id_va,
                                     l_pgm_id_va,
                                     l_pl_typ_id_va,
                                     l_ptip_id_va,
                                     l_plip_id_va,
                                     l_pl_id_va,
                                     l_oipl_id_va,
                                     l_oiplip_id_va,
                                     l_opt_id_va,
                                     l_enrt_perd_id_va,
                                     l_lee_rsn_id_va,
                                     l_enrt_perd_strt_dt_va,
                                     l_prtt_enrt_rslt_id_va,
                                     l_enrt_cvg_strt_dt_va,
                                     l_enrt_cvg_strt_dt_cd_va,
                                     l_enrt_cvg_strt_dt_rl_va,
                                     l_yr_perd_id_va,
                                     l_comp_lvl_cd_va,
                                     l_cmbn_plip_id_va,
                                     l_cmbn_ptip_id_va,
                                     l_cmbn_ptip_opt_id_va,
                                     l_dflt_flag_va,
                                     l_ctfn_rqd_flag_va,
                                     l_enrt_bnft_id_va,
                                     l_val_va,
                                     l_acty_ref_perd_cd_va,
                                     l_elctbl_flag_va,
                                     l_object_version_number_va,
                                     l_alws_dpnt_dsgn_flag_va,
                                     l_dpnt_dsgn_cd_va,
                                     l_ler_chg_dpnt_cvg_cd_va,
                                     l_dpnt_cvg_strt_dt_cd_va,
                                     l_dpnt_cvg_strt_dt_rl_va,
                                     l_in_pndg_wkflow_flag_va,
                                     l_bnft_prvdr_pool_id_va,
                                     l_elig_flag_va,
                                     l_inelig_rsn_cd_va,
                                     l_fonm_cvg_strt_dt_va;
  close c_instance;
  --
  if l_elig_per_elctbl_chc_id_va.count > 0 then
    --
    for i in l_elig_per_elctbl_chc_id_va.first..l_elig_per_elctbl_chc_id_va.last
    loop
      --
      l_hv := mod(l_elig_per_elctbl_chc_id_va(i),ben_hash_utility.get_hash_key);
      --
      while g_epe_instance.exists(l_hv)
      loop
        --
        l_hv := l_hv+g_hash_jump;
        --
      end loop;
      --
      g_epe_instance(l_hv).elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id_va(i);
      g_epe_instance(l_hv).business_group_id      := l_business_group_id_va(i);
      g_epe_instance(l_hv).person_id              := l_person_id_va(i);
      g_epe_instance(l_hv).ler_id                 := l_ler_id_va(i);
      g_epe_instance(l_hv).LF_EVT_OCRD_DT         := l_LF_EVT_OCRD_DT_va(i);
      g_epe_instance(l_hv).per_in_ler_stat_cd     := l_per_in_ler_stat_cd_va(i);
      g_epe_instance(l_hv).per_in_ler_id          := l_per_in_ler_id_va(i);
      g_epe_instance(l_hv).pgm_id                 := l_pgm_id_va(i);
      g_epe_instance(l_hv).pl_typ_id              := l_pl_typ_id_va(i);
      g_epe_instance(l_hv).ptip_id                := l_ptip_id_va(i);
      g_epe_instance(l_hv).plip_id                := l_plip_id_va(i);
      g_epe_instance(l_hv).pl_id                  := l_pl_id_va(i);
      g_epe_instance(l_hv).oipl_id                := l_oipl_id_va(i);
      g_epe_instance(l_hv).oiplip_id              := l_oiplip_id_va(i);
      g_epe_instance(l_hv).opt_id                 := null;
      g_epe_instance(l_hv).enrt_perd_id           := l_enrt_perd_id_va(i);
      g_epe_instance(l_hv).lee_rsn_id             := l_lee_rsn_id_va(i);
      g_epe_instance(l_hv).enrt_perd_strt_dt      := l_enrt_perd_strt_dt_va(i);
      g_epe_instance(l_hv).prtt_enrt_rslt_id      := l_prtt_enrt_rslt_id_va(i);
      g_epe_instance(l_hv).enrt_cvg_strt_dt       := l_enrt_cvg_strt_dt_va(i);
      g_epe_instance(l_hv).enrt_cvg_strt_dt_cd    := l_enrt_cvg_strt_dt_cd_va(i);
      g_epe_instance(l_hv).enrt_cvg_strt_dt_rl    := l_enrt_cvg_strt_dt_rl_va(i);
      g_epe_instance(l_hv).yr_perd_id             := l_yr_perd_id_va(i);
      g_epe_instance(l_hv).comp_lvl_cd            := l_comp_lvl_cd_va(i);
      g_epe_instance(l_hv).cmbn_plip_id           := l_cmbn_plip_id_va(i);
      g_epe_instance(l_hv).cmbn_ptip_id           := l_cmbn_ptip_id_va(i);
      g_epe_instance(l_hv).cmbn_ptip_opt_id       := l_cmbn_ptip_opt_id_va(i);
      g_epe_instance(l_hv).dflt_flag              := l_dflt_flag_va(i);
      g_epe_instance(l_hv).ctfn_rqd_flag          := l_ctfn_rqd_flag_va(i);
      g_epe_instance(l_hv).enrt_bnft_id           := l_enrt_bnft_id_va(i);
      g_epe_instance(l_hv).val                    := l_val_va(i);
      g_epe_instance(l_hv).acty_ref_perd_cd       := l_acty_ref_perd_cd_va(i);
      g_epe_instance(l_hv).elctbl_flag            := l_elctbl_flag_va(i);
      g_epe_instance(l_hv).object_version_number  := l_object_version_number_va(i);
      g_epe_instance(l_hv).alws_dpnt_dsgn_flag    := l_alws_dpnt_dsgn_flag_va(i);
      g_epe_instance(l_hv).dpnt_dsgn_cd           := l_dpnt_dsgn_cd_va(i);
      g_epe_instance(l_hv).ler_chg_dpnt_cvg_cd    := l_ler_chg_dpnt_cvg_cd_va(i);
      g_epe_instance(l_hv).dpnt_cvg_strt_dt_cd    := l_dpnt_cvg_strt_dt_cd_va(i);
      g_epe_instance(l_hv).dpnt_cvg_strt_dt_rl    := l_dpnt_cvg_strt_dt_rl_va(i);
      g_epe_instance(l_hv).in_pndg_wkflow_flag    := l_in_pndg_wkflow_flag_va(i);
      g_epe_instance(l_hv).bnft_prvdr_pool_id     := l_bnft_prvdr_pool_id_va(i);
      g_epe_instance(l_hv).elig_flag              := l_elig_flag_va(i);
      g_epe_instance(l_hv).inelig_rsn_cd          := l_inelig_rsn_cd_va(i);
      g_epe_instance(l_hv).fonm_cvg_strt_dt       := l_fonm_cvg_strt_dt_va(i);

      --
      g_epe_instance(l_hv).prtn_strt_dt           := null;
      g_epe_instance(l_hv).prtn_ovridn_flag       := null;
      g_epe_instance(l_hv).prtn_ovridn_thru_dt    := null;
      g_epe_instance(l_hv).rt_age_val             := null;
      g_epe_instance(l_hv).rt_los_val             := null;
      g_epe_instance(l_hv).rt_hrs_wkd_val         := null;
      g_epe_instance(l_hv).rt_cmbn_age_n_los_val  := null;
      --
    end loop;
    --
  end if;
  --
/*
  for objinst in c_instance
    (c_per_in_ler_id => p_per_in_ler_id
    )
  loop
    --
    l_hv := mod(objinst.elig_per_elctbl_chc_id,ben_hash_utility.get_hash_key);
    --
    while g_epe_instance.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    g_epe_instance(l_hv).elig_per_elctbl_chc_id  := objinst.elig_per_elctbl_chc_id;
    g_epe_instance(l_hv).business_group_id       := objinst.business_group_id;
    g_epe_instance(l_hv).person_id               := objinst.person_id;
    g_epe_instance(l_hv).ler_id                  := objinst.ler_id;
    g_epe_instance(l_hv).per_in_ler_id           := objinst.per_in_ler_id;
    g_epe_instance(l_hv).LF_EVT_OCRD_DT          := objinst.LF_EVT_OCRD_DT;
    g_epe_instance(l_hv).per_in_ler_stat_cd      := objinst.per_in_ler_stat_cd;
    g_epe_instance(l_hv).pgm_id                  := objinst.pgm_id;
    g_epe_instance(l_hv).pl_typ_id               := objinst.pl_typ_id;
    g_epe_instance(l_hv).ptip_id                 := objinst.ptip_id;
    g_epe_instance(l_hv).plip_id                 := objinst.plip_id;
    g_epe_instance(l_hv).pl_id                   := objinst.pl_id;
    g_epe_instance(l_hv).oipl_id                 := objinst.oipl_id;
    g_epe_instance(l_hv).oiplip_id               := objinst.oiplip_id;
    g_epe_instance(l_hv).comp_lvl_cd             := objinst.comp_lvl_cd;
    g_epe_instance(l_hv).cmbn_plip_id            := objinst.cmbn_plip_id;
    g_epe_instance(l_hv).cmbn_ptip_id            := objinst.cmbn_ptip_id;
    g_epe_instance(l_hv).cmbn_ptip_opt_id        := objinst.cmbn_ptip_opt_id;
    g_epe_instance(l_hv).dflt_flag               := objinst.dflt_flag;
    g_epe_instance(l_hv).ctfn_rqd_flag           := objinst.ctfn_rqd_flag;
    g_epe_instance(l_hv).prtt_enrt_rslt_id       := objinst.prtt_enrt_rslt_id;
    g_epe_instance(l_hv).enrt_cvg_strt_dt        := objinst.enrt_cvg_strt_dt;
    g_epe_instance(l_hv).enrt_cvg_strt_dt_cd     := objinst.enrt_cvg_strt_dt_cd;
    g_epe_instance(l_hv).enrt_cvg_strt_dt_rl     := objinst.enrt_cvg_strt_dt_rl;
    g_epe_instance(l_hv).yr_perd_id              := objinst.yr_perd_id;
    g_epe_instance(l_hv).enrt_bnft_id            := objinst.enrt_bnft_id;
    g_epe_instance(l_hv).val                     := objinst.val;
    g_epe_instance(l_hv).enrt_perd_strt_dt       := objinst.enrt_perd_strt_dt;
    g_epe_instance(l_hv).enrt_perd_id            := objinst.enrt_perd_id;
    g_epe_instance(l_hv).lee_rsn_id              := objinst.lee_rsn_id;
    g_epe_instance(l_hv).acty_ref_perd_cd        := objinst.acty_ref_perd_cd;
    g_epe_instance(l_hv).elctbl_flag             := objinst.elctbl_flag;
    g_epe_instance(l_hv).object_version_number   := objinst.object_version_number;
    g_epe_instance(l_hv).alws_dpnt_dsgn_flag     := objinst.alws_dpnt_dsgn_flag;
    g_epe_instance(l_hv).dpnt_dsgn_cd            := objinst.dpnt_dsgn_cd;
    g_epe_instance(l_hv).ler_chg_dpnt_cvg_cd     := objinst.ler_chg_dpnt_cvg_cd;
    g_epe_instance(l_hv).dpnt_cvg_strt_dt_cd     := objinst.dpnt_cvg_strt_dt_cd;
    g_epe_instance(l_hv).dpnt_cvg_strt_dt_rl     := objinst.dpnt_cvg_strt_dt_rl;
    g_epe_instance(l_hv).in_pndg_wkflow_flag     := objinst.in_pndg_wkflow_flag;
    --
    g_epe_instance(l_hv).opt_id                  := null;
    g_epe_instance(l_hv).prtn_strt_dt            := null;
    g_epe_instance(l_hv).prtn_ovridn_flag        := null;
    g_epe_instance(l_hv).prtn_ovridn_thru_dt     := null;
    g_epe_instance(l_hv).rt_age_val              := null;
    g_epe_instance(l_hv).rt_los_val              := null;
    g_epe_instance(l_hv).rt_hrs_wkd_val          := null;
    g_epe_instance(l_hv).rt_cmbn_age_n_los_val   := null;
    --
  end loop;
*/
  --
  -- Check for no rows found
  --
  if l_hv is null then
    --
    g_epe_instance.delete;
    g_epe_current.per_in_ler_id := null;
    --
  else
    --
    g_epe_current.per_in_ler_id := p_per_in_ler_id;
    --
  end if;
  --
end write_EPE_cache;
--
procedure EPE_GetEPEDets
  (p_elig_per_elctbl_chc_id in     number
  ,p_per_in_ler_id          in     number
  ,p_inst_row               in out NOCOPY g_pilepe_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'EPE_GetEPEDets';
  --
  l_hv      pls_integer;
  l_reset   g_pilepe_inst_row;
  --
begin
  --
  -- Check for already cached or a change in current PIL ID
  --
  if nvl(g_epe_current.per_in_ler_id,-9999) <> p_per_in_ler_id
    or g_epe_cached < 2
  then
    --
    -- When PIL changes then flush current cache
    --
    if nvl(g_epe_current.per_in_ler_id,-9999) <> p_per_in_ler_id
    then
      --
      g_epe_instance.delete;
      g_epe_cached := 1;
      --
    end if;
    --
    -- Write the cache
    --
    write_EPE_cache
      (p_per_in_ler_id => p_per_in_ler_id
      );
    --
    if g_epe_cached = 1
    then
      --
      g_epe_cached := 2;
      --
    end if;
    --
  end if;
  --
  -- Get the instance details
  --
  l_hv := mod(p_elig_per_elctbl_chc_id,ben_hash_utility.get_hash_key);
  --
  if g_epe_instance(l_hv).elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
  then
     -- Matched row
     null;
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    l_hv := l_hv+g_hash_jump;
    while g_epe_instance(l_hv).elig_per_elctbl_chc_id <> p_elig_per_elctbl_chc_id
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
  end if;
  --
  p_inst_row := g_epe_instance(l_hv);
  --
exception
  --
  when no_data_found then
    --
    p_inst_row := l_reset;
    --
end EPE_GetEPEDets;
--
procedure get_pilcobjepe_dets
  (p_per_in_ler_id  in     number
  ,p_pgm_id         in     number
  ,p_pl_id          in     number
  ,p_oipl_id        in     number
  --
  ,p_inst_row	    in out NOCOPY g_pilepe_inst_row
  )
is
  --
  l_proc varchar2(72) :=  'get_pilcobjepe_dets';
  --
  l_inst_row g_pilepe_inst_row;
  --
  CURSOR c_choice_exists_for_option
    (c_per_in_ler_id  number
    ,c_pgm_id         number
    ,c_oipl_id        number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.oipl_id = c_oipl_id
    AND      epe.pgm_id = c_pgm_id
    AND      epe.per_in_ler_id = c_per_in_ler_id;
  --
  CURSOR c_chc_exists_for_plnip_option
    (c_per_in_ler_id  number
    ,c_oipl_id        number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.oipl_id = c_oipl_id
    AND      epe.pgm_id IS NULL
    AND      epe.per_in_ler_id = c_per_in_ler_id;
  --
  CURSOR c_choice_exists_for_plan
    (c_per_in_ler_id number
    ,c_pgm_id        number
    ,c_pl_id         number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.pl_id = c_pl_id
    AND      epe.oipl_id IS NULL
    AND      epe.pgm_id = c_pgm_id
    AND      epe.per_in_ler_id = c_per_in_ler_id;
    --
  CURSOR c_choice_exists_for_plnip
    (c_per_in_ler_id number
    ,c_pl_id         number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.pl_id = c_pl_id
    AND      epe.oipl_id IS NULL
    AND      epe.pgm_id IS NULL
    AND      epe.per_in_ler_id = c_per_in_ler_id;
    --
begin
  --
  if p_oipl_id is null
  then
    --
    if p_pgm_id is not null
    then
      --
      OPEN c_choice_exists_for_plan
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pgm_id         => p_pgm_id
        ,c_pl_id          => p_pl_id
        );
      FETCH c_choice_exists_for_plan INTO l_inst_row.elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_plan;
      --
    else
      --
      OPEN c_choice_exists_for_plnip
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pl_id          => p_pl_id
        );
      FETCH c_choice_exists_for_plnip INTO l_inst_row.elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_plnip;
      --
    end if;
    --
  else
    --
    if p_pgm_id is not null
    then
      --
      OPEN c_choice_exists_for_option
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pgm_id         => p_pgm_id
        ,c_oipl_id        => p_oipl_id
        );
      FETCH c_choice_exists_for_option INTO l_inst_row.elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_option;
      --
    else
      --
      OPEN c_chc_exists_for_plnip_option
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_oipl_id        => p_oipl_id
        );
      FETCH c_chc_exists_for_plnip_option INTO l_inst_row.elig_per_elctbl_chc_id;
      CLOSE c_chc_exists_for_plnip_option;
      --
    end if;
    --
  end if;
  --
  p_inst_row := l_inst_row;
  --
end get_pilcobjepe_dets;
--
procedure init_context_pileperow
is

  l_currepe_row g_pilepe_inst_row;

begin
  --
  ben_epe_cache.g_currepe_row := l_currepe_row;
  --
end init_context_pileperow;
--
procedure init_context_cobj_pileperow
is

  l_currepe_row g_pilepe_inst_row;

begin
  --
  ben_epe_cache.g_currcobjepe_row := l_currepe_row;
  --
end init_context_cobj_pileperow;
--
procedure clear_down_cache
is

begin
  --
  g_pilepe_instance.delete;
  g_pilepe_cached := 1;
  --
  g_enbepe_instance.delete;
  g_enbepe_cached := 1;
  g_enbepe_current.per_in_ler_id := null;
  --
  g_epe_instance.delete;
  g_epe_cached := 1;
  g_epe_current.per_in_ler_id := null;
  --
  init_context_pileperow;
  --
end clear_down_cache;
--
end ben_epe_cache;

/
