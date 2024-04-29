--------------------------------------------------------
--  DDL for Package Body BEN_REINSTATE_EPE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REINSTATE_EPE_CACHE" as
/* $Header: berepech.pkb 120.0 2005/05/28 11:38:39 appldev noship $ */
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
  115.0      01-Apr-05	ikasire    Created.
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_reinstate_epe_cache.';
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
g_epe_cached          pls_integer := 0;
--
type g_current_row is record
  (per_in_ler_id number
  );
--
g_epe_current    g_current_row;
--
procedure write_pilepe_cache
  (p_per_in_ler_id in     number
  )
is
  --
   l_alws_dpnt_dsgn_flag_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_approval_status_cd_va            	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_assignment_id_va                 	benutils.g_number_table := benutils.g_number_table();
   l_auto_enrt_flag_va                	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_bnft_prvdr_pool_id_va            	benutils.g_number_table := benutils.g_number_table();
   l_business_group_id_va             	benutils.g_number_table := benutils.g_number_table();
   l_cmbn_plip_id_va                  	benutils.g_number_table := benutils.g_number_table();
   l_cmbn_ptip_id_va                  	benutils.g_number_table := benutils.g_number_table();
   l_cmbn_ptip_opt_id_va              	benutils.g_number_table := benutils.g_number_table();
   l_comp_lvl_cd_va                   	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_crntly_enrd_flag_va              	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_cryfwd_elig_dpnt_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_ctfn_rqd_flag_va                 	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_dflt_flag_va                     	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_dpnt_cvg_strt_dt_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_dpnt_cvg_strt_dt_rl_va           	benutils.g_number_table := benutils.g_number_table();
   l_dpnt_dsgn_cd_va                  	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_elctbl_flag_va                   	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_elig_flag_va                     	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_elig_ovrid_dt_va                 	benutils.g_date_table   := benutils.g_date_table();
   l_elig_ovrid_person_id_va          	benutils.g_number_table := benutils.g_number_table();
   l_elig_per_elctbl_chc_id_va        	benutils.g_number_table := benutils.g_number_table();
   l_enrt_cvg_strt_dt_va              	benutils.g_date_table   := benutils.g_date_table();
   l_enrt_cvg_strt_dt_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_enrt_cvg_strt_dt_rl_va           	benutils.g_number_table := benutils.g_number_table();
   l_erlst_deenrt_dt_va               	benutils.g_date_table   := benutils.g_date_table();
   l_fonm_cvg_strt_dt_va              	benutils.g_date_table   := benutils.g_date_table();
   l_inelig_rsn_cd_va                 	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_interim_epe_id_va	                benutils.g_number_table := benutils.g_number_table();
   l_in_pndg_wkflow_flag_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_ler_chg_dpnt_cvg_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_mgr_ovrid_dt_va                  	benutils.g_date_table   := benutils.g_date_table();
   l_mgr_ovrid_person_id_va           	benutils.g_number_table := benutils.g_number_table();
   l_mndtry_flag_va                   	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_must_enrl_anthr_pl_id_va         	benutils.g_number_table := benutils.g_number_table();
   l_object_version_number_va         	benutils.g_number_table := benutils.g_number_table();
   l_oiplip_id_va                     	benutils.g_number_table := benutils.g_number_table();
   l_oipl_id_va                       	benutils.g_number_table := benutils.g_number_table();
   l_oipl_ordr_num_va                 	benutils.g_number_table := benutils.g_number_table();
   l_per_in_ler_id_va                 	benutils.g_number_table := benutils.g_number_table();
   l_pgm_id_va                        	benutils.g_number_table := benutils.g_number_table();
   l_pil_elctbl_chc_popl_id_va        	benutils.g_number_table := benutils.g_number_table();
   l_plip_id_va                       	benutils.g_number_table := benutils.g_number_table();
   l_plip_ordr_num_va                 	benutils.g_number_table := benutils.g_number_table();
   l_pl_id_va                         	benutils.g_number_table := benutils.g_number_table();
   l_pl_ordr_num_va                   	benutils.g_number_table := benutils.g_number_table();
   l_pl_typ_id_va                     	benutils.g_number_table := benutils.g_number_table();
   l_procg_end_dt_va                  	benutils.g_date_table   := benutils.g_date_table();
   l_prtt_enrt_rslt_id_va             	benutils.g_number_table := benutils.g_number_table();
   l_ptip_id_va                       	benutils.g_number_table := benutils.g_number_table();
   l_ptip_ordr_num_va                 	benutils.g_number_table := benutils.g_number_table();
   l_roll_crs_flag_va                 	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_spcl_rt_oipl_id_va               	benutils.g_number_table := benutils.g_number_table();
   l_spcl_rt_pl_id_va                 	benutils.g_number_table := benutils.g_number_table();
   l_ws_mgr_id_va                     	benutils.g_number_table := benutils.g_number_table();
   l_yr_perd_id_va                    	benutils.g_number_table := benutils.g_number_table();
  --
  l_ele_num                   pls_integer;
  --
  CURSOR c_instance
    ( c_per_in_ler_id in    number)
  IS
    SELECT
             epe.alws_dpnt_dsgn_flag
            ,epe.approval_status_cd
            ,epe.assignment_id
            ,epe.auto_enrt_flag
            ,epe.bnft_prvdr_pool_id
            ,epe.business_group_id
            ,epe.cmbn_plip_id
            ,epe.cmbn_ptip_id
            ,epe.cmbn_ptip_opt_id
            ,epe.comp_lvl_cd
            ,epe.crntly_enrd_flag
            ,epe.cryfwd_elig_dpnt_cd
            ,epe.ctfn_rqd_flag
            ,epe.dflt_flag
            ,epe.dpnt_cvg_strt_dt_cd
            ,epe.dpnt_cvg_strt_dt_rl
            ,epe.dpnt_dsgn_cd
            ,epe.elctbl_flag
            ,epe.elig_flag
            ,epe.elig_ovrid_dt
            ,epe.elig_ovrid_person_id
            ,epe.elig_per_elctbl_chc_id
            ,epe.enrt_cvg_strt_dt
            ,epe.enrt_cvg_strt_dt_cd
            ,epe.enrt_cvg_strt_dt_rl
            ,epe.erlst_deenrt_dt
            ,epe.fonm_cvg_strt_dt
            ,epe.inelig_rsn_cd
            ,epe.interim_elig_per_elctbl_chc_id
            ,epe.in_pndg_wkflow_flag
            ,epe.ler_chg_dpnt_cvg_cd
            ,epe.mgr_ovrid_dt
            ,epe.mgr_ovrid_person_id
            ,epe.mndtry_flag
            ,epe.must_enrl_anthr_pl_id
            ,epe.object_version_number
            ,epe.oiplip_id
            ,epe.oipl_id
            ,epe.oipl_ordr_num
            ,epe.per_in_ler_id
            ,epe.pgm_id
            ,epe.pil_elctbl_chc_popl_id
            ,epe.plip_id
            ,epe.plip_ordr_num
            ,epe.pl_id
            ,epe.pl_ordr_num
            ,epe.pl_typ_id
            ,epe.procg_end_dt
            ,epe.prtt_enrt_rslt_id
            ,epe.ptip_id
            ,epe.ptip_ordr_num
            ,epe.roll_crs_flag
            ,epe.spcl_rt_oipl_id
            ,epe.spcl_rt_pl_id
            ,epe.ws_mgr_id
            ,epe.yr_perd_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.per_in_ler_id = c_per_in_ler_id
    order by epe.PTIP_ORDR_NUM,
             epe.PLIP_ORDR_NUM,
             decode(PL_ORDR_NUM, null, OIPL_ORDR_NUM, PL_ORDR_NUM),
             PL_ORDR_NUM,
             decode(PL_ORDR_NUM, null, null, OIPL_ORDR_NUM);
  --
begin
  --
  l_ele_num := 0;
  --
  open c_instance
    ( c_per_in_ler_id => p_per_in_ler_id
    );
  fetch c_instance BULK COLLECT INTO
                                 l_alws_dpnt_dsgn_flag_va
                                ,l_approval_status_cd_va
                                ,l_assignment_id_va
                                ,l_auto_enrt_flag_va
                                ,l_bnft_prvdr_pool_id_va
                                ,l_business_group_id_va
                                ,l_cmbn_plip_id_va
                                ,l_cmbn_ptip_id_va
                                ,l_cmbn_ptip_opt_id_va
                                ,l_comp_lvl_cd_va
                                ,l_crntly_enrd_flag_va
                                ,l_cryfwd_elig_dpnt_cd_va
                                ,l_ctfn_rqd_flag_va
                                ,l_dflt_flag_va
                                ,l_dpnt_cvg_strt_dt_cd_va
                                ,l_dpnt_cvg_strt_dt_rl_va
                                ,l_dpnt_dsgn_cd_va
                                ,l_elctbl_flag_va
                                ,l_elig_flag_va
                                ,l_elig_ovrid_dt_va
                                ,l_elig_ovrid_person_id_va
                                ,l_elig_per_elctbl_chc_id_va
                                ,l_enrt_cvg_strt_dt_va
                                ,l_enrt_cvg_strt_dt_cd_va
                                ,l_enrt_cvg_strt_dt_rl_va
                                ,l_erlst_deenrt_dt_va
                                ,l_fonm_cvg_strt_dt_va
                                ,l_inelig_rsn_cd_va
                                ,l_interim_epe_id_va
                                ,l_in_pndg_wkflow_flag_va
                                ,l_ler_chg_dpnt_cvg_cd_va
                                ,l_mgr_ovrid_dt_va
                                ,l_mgr_ovrid_person_id_va
                                ,l_mndtry_flag_va
                                ,l_must_enrl_anthr_pl_id_va
                                ,l_object_version_number_va
                                ,l_oiplip_id_va
                                ,l_oipl_id_va
                                ,l_oipl_ordr_num_va
                                ,l_per_in_ler_id_va
                                ,l_pgm_id_va
                                ,l_pil_elctbl_chc_popl_id_va
                                ,l_plip_id_va
                                ,l_plip_ordr_num_va
                                ,l_pl_id_va
                                ,l_pl_ordr_num_va
                                ,l_pl_typ_id_va
                                ,l_procg_end_dt_va
                                ,l_prtt_enrt_rslt_id_va
                                ,l_ptip_id_va
                                ,l_ptip_ordr_num_va
                                ,l_roll_crs_flag_va
                                ,l_spcl_rt_oipl_id_va
                                ,l_spcl_rt_pl_id_va
                                ,l_ws_mgr_id_va
                                ,l_yr_perd_id_va;
  close c_instance;
  --
  if l_elig_per_elctbl_chc_id_va.count > 0 then
    --
    for i in l_elig_per_elctbl_chc_id_va.first..l_elig_per_elctbl_chc_id_va.last
    loop
      --
      g_pilepe_instance(l_ele_num).alws_dpnt_dsgn_flag           	  := l_alws_dpnt_dsgn_flag_va(i);
      g_pilepe_instance(l_ele_num).approval_status_cd            	  := l_approval_status_cd_va(i);
      g_pilepe_instance(l_ele_num).assignment_id                 	  := l_assignment_id_va(i);
      g_pilepe_instance(l_ele_num).auto_enrt_flag                	  := l_auto_enrt_flag_va(i);
      g_pilepe_instance(l_ele_num).bnft_prvdr_pool_id            	  := l_bnft_prvdr_pool_id_va(i);
      g_pilepe_instance(l_ele_num).business_group_id             	  := l_business_group_id_va(i);
      g_pilepe_instance(l_ele_num).cmbn_plip_id                  	  := l_cmbn_plip_id_va(i);
      g_pilepe_instance(l_ele_num).cmbn_ptip_id                  	  := l_cmbn_ptip_id_va(i);
      g_pilepe_instance(l_ele_num).cmbn_ptip_opt_id              	  := l_cmbn_ptip_opt_id_va(i);
      g_pilepe_instance(l_ele_num).comp_lvl_cd                   	  := l_comp_lvl_cd_va(i);
      g_pilepe_instance(l_ele_num).crntly_enrd_flag              	  := l_crntly_enrd_flag_va(i);
      g_pilepe_instance(l_ele_num).cryfwd_elig_dpnt_cd           	  := l_cryfwd_elig_dpnt_cd_va(i);
      g_pilepe_instance(l_ele_num).ctfn_rqd_flag                 	  := l_ctfn_rqd_flag_va(i);
      g_pilepe_instance(l_ele_num).dflt_flag                     	  := l_dflt_flag_va(i);
      g_pilepe_instance(l_ele_num).dpnt_cvg_strt_dt_cd           	  := l_dpnt_cvg_strt_dt_cd_va(i);
      g_pilepe_instance(l_ele_num).dpnt_cvg_strt_dt_rl           	  := l_dpnt_cvg_strt_dt_rl_va(i);
      g_pilepe_instance(l_ele_num).dpnt_dsgn_cd                  	  := l_dpnt_dsgn_cd_va(i);
      g_pilepe_instance(l_ele_num).elctbl_flag                   	  := l_elctbl_flag_va(i);
      g_pilepe_instance(l_ele_num).elig_flag                     	  := l_elig_flag_va(i);
      g_pilepe_instance(l_ele_num).elig_ovrid_dt                 	  := l_elig_ovrid_dt_va(i);
      g_pilepe_instance(l_ele_num).elig_ovrid_person_id          	  := l_elig_ovrid_person_id_va(i);
      g_pilepe_instance(l_ele_num).elig_per_elctbl_chc_id        	  := l_elig_per_elctbl_chc_id_va(i);
      g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt              	  := l_enrt_cvg_strt_dt_va(i);
      g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt_cd           	  := l_enrt_cvg_strt_dt_cd_va(i);
      g_pilepe_instance(l_ele_num).enrt_cvg_strt_dt_rl           	  := l_enrt_cvg_strt_dt_rl_va(i);
      g_pilepe_instance(l_ele_num).erlst_deenrt_dt               	  := l_erlst_deenrt_dt_va(i);
      g_pilepe_instance(l_ele_num).fonm_cvg_strt_dt              	  := l_fonm_cvg_strt_dt_va(i);
      g_pilepe_instance(l_ele_num).inelig_rsn_cd                 	  := l_inelig_rsn_cd_va(i);
      g_pilepe_instance(l_ele_num).interim_elig_per_elctbl_chc_id	  := l_interim_epe_id_va(i);
      g_pilepe_instance(l_ele_num).in_pndg_wkflow_flag           	  := l_in_pndg_wkflow_flag_va(i);
      g_pilepe_instance(l_ele_num).ler_chg_dpnt_cvg_cd           	  := l_ler_chg_dpnt_cvg_cd_va(i);
      g_pilepe_instance(l_ele_num).mgr_ovrid_dt                  	  := l_mgr_ovrid_dt_va(i);
      g_pilepe_instance(l_ele_num).mgr_ovrid_person_id           	  := l_mgr_ovrid_person_id_va(i);
      g_pilepe_instance(l_ele_num).mndtry_flag                   	  := l_mndtry_flag_va(i);
      g_pilepe_instance(l_ele_num).must_enrl_anthr_pl_id         	  := l_must_enrl_anthr_pl_id_va(i);
      g_pilepe_instance(l_ele_num).object_version_number         	  := l_object_version_number_va(i);
      g_pilepe_instance(l_ele_num).oiplip_id                     	  := l_oiplip_id_va(i);
      g_pilepe_instance(l_ele_num).oipl_id                       	  := l_oipl_id_va(i);
      g_pilepe_instance(l_ele_num).oipl_ordr_num                 	  := l_oipl_ordr_num_va(i);
      g_pilepe_instance(l_ele_num).per_in_ler_id                 	  := l_per_in_ler_id_va(i);
      g_pilepe_instance(l_ele_num).pgm_id                        	  := l_pgm_id_va(i);
      g_pilepe_instance(l_ele_num).pil_elctbl_chc_popl_id        	  := l_pil_elctbl_chc_popl_id_va(i);
      g_pilepe_instance(l_ele_num).plip_id                       	  := l_plip_id_va(i);
      g_pilepe_instance(l_ele_num).plip_ordr_num                 	  := l_plip_ordr_num_va(i);
      g_pilepe_instance(l_ele_num).pl_id                         	  := l_pl_id_va(i);
      g_pilepe_instance(l_ele_num).pl_ordr_num                   	  := l_pl_ordr_num_va(i);
      g_pilepe_instance(l_ele_num).pl_typ_id                     	  := l_pl_typ_id_va(i);
      g_pilepe_instance(l_ele_num).procg_end_dt                  	  := l_procg_end_dt_va(i);
      g_pilepe_instance(l_ele_num).prtt_enrt_rslt_id             	  := l_prtt_enrt_rslt_id_va(i);
      g_pilepe_instance(l_ele_num).ptip_id                       	  := l_ptip_id_va(i);
      g_pilepe_instance(l_ele_num).ptip_ordr_num                 	  := l_ptip_ordr_num_va(i);
      g_pilepe_instance(l_ele_num).roll_crs_flag                 	  := l_roll_crs_flag_va(i);
      g_pilepe_instance(l_ele_num).spcl_rt_oipl_id               	  := l_spcl_rt_oipl_id_va(i);
      g_pilepe_instance(l_ele_num).spcl_rt_pl_id                 	  := l_spcl_rt_pl_id_va(i);
      g_pilepe_instance(l_ele_num).ws_mgr_id                     	  := l_ws_mgr_id_va(i);
      g_pilepe_instance(l_ele_num).yr_perd_id                    	  := l_yr_perd_id_va(i);
      --
      l_ele_num := l_ele_num+1;
     --
    end loop;
    --
  end if;
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
  (p_per_in_ler_id  in number
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
      (p_per_in_ler_id =>p_per_in_ler_id
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
procedure write_EPE_cache
  (p_per_in_ler_id in     number
  )
is
  --
  l_proc varchar2(72) :=  'write_EPE_cache';
  --
   l_alws_dpnt_dsgn_flag_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_approval_status_cd_va            	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_assignment_id_va                 	benutils.g_number_table := benutils.g_number_table();
   l_auto_enrt_flag_va                	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_bnft_prvdr_pool_id_va            	benutils.g_number_table := benutils.g_number_table();
   l_business_group_id_va             	benutils.g_number_table := benutils.g_number_table();
   l_cmbn_plip_id_va                  	benutils.g_number_table := benutils.g_number_table();
   l_cmbn_ptip_id_va                  	benutils.g_number_table := benutils.g_number_table();
   l_cmbn_ptip_opt_id_va              	benutils.g_number_table := benutils.g_number_table();
   l_comp_lvl_cd_va                   	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_crntly_enrd_flag_va              	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_cryfwd_elig_dpnt_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_ctfn_rqd_flag_va                 	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_dflt_flag_va                     	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_dpnt_cvg_strt_dt_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_dpnt_cvg_strt_dt_rl_va           	benutils.g_number_table := benutils.g_number_table();
   l_dpnt_dsgn_cd_va                  	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_elctbl_flag_va                   	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_elig_flag_va                     	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_elig_ovrid_dt_va                 	benutils.g_date_table   := benutils.g_date_table();
   l_elig_ovrid_person_id_va          	benutils.g_number_table := benutils.g_number_table();
   l_elig_per_elctbl_chc_id_va        	benutils.g_number_table := benutils.g_number_table();
   l_enrt_cvg_strt_dt_va              	benutils.g_date_table   := benutils.g_date_table();
   l_enrt_cvg_strt_dt_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_enrt_cvg_strt_dt_rl_va           	benutils.g_number_table := benutils.g_number_table();
   l_erlst_deenrt_dt_va               	benutils.g_date_table   := benutils.g_date_table();
   l_fonm_cvg_strt_dt_va              	benutils.g_date_table   := benutils.g_date_table();
   l_inelig_rsn_cd_va                 	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_interim_epe_id_va	                benutils.g_number_table := benutils.g_number_table();
   l_in_pndg_wkflow_flag_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_ler_chg_dpnt_cvg_cd_va           	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_mgr_ovrid_dt_va                  	benutils.g_date_table   := benutils.g_date_table();
   l_mgr_ovrid_person_id_va           	benutils.g_number_table := benutils.g_number_table();
   l_mndtry_flag_va                   	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_must_enrl_anthr_pl_id_va         	benutils.g_number_table := benutils.g_number_table();
   l_object_version_number_va         	benutils.g_number_table := benutils.g_number_table();
   l_oiplip_id_va                     	benutils.g_number_table := benutils.g_number_table();
   l_oipl_id_va                       	benutils.g_number_table := benutils.g_number_table();
   l_oipl_ordr_num_va                 	benutils.g_number_table := benutils.g_number_table();
   l_per_in_ler_id_va                 	benutils.g_number_table := benutils.g_number_table();
   l_pgm_id_va                        	benutils.g_number_table := benutils.g_number_table();
   l_pil_elctbl_chc_popl_id_va        	benutils.g_number_table := benutils.g_number_table();
   l_plip_id_va                       	benutils.g_number_table := benutils.g_number_table();
   l_plip_ordr_num_va                 	benutils.g_number_table := benutils.g_number_table();
   l_pl_id_va                         	benutils.g_number_table := benutils.g_number_table();
   l_pl_ordr_num_va                   	benutils.g_number_table := benutils.g_number_table();
   l_pl_typ_id_va                     	benutils.g_number_table := benutils.g_number_table();
   l_procg_end_dt_va                  	benutils.g_date_table   := benutils.g_date_table();
   l_prtt_enrt_rslt_id_va             	benutils.g_number_table := benutils.g_number_table();
   l_ptip_id_va                       	benutils.g_number_table := benutils.g_number_table();
   l_ptip_ordr_num_va                 	benutils.g_number_table := benutils.g_number_table();
   l_roll_crs_flag_va                 	benutils.g_v2_30_table  := benutils.g_v2_30_table();
   l_spcl_rt_oipl_id_va               	benutils.g_number_table := benutils.g_number_table();
   l_spcl_rt_pl_id_va                 	benutils.g_number_table := benutils.g_number_table();
   l_ws_mgr_id_va                     	benutils.g_number_table := benutils.g_number_table();
   l_yr_perd_id_va                    	benutils.g_number_table := benutils.g_number_table();
   --
   l_hv                        pls_integer;
   --
  CURSOR c_instance
    (c_per_in_ler_id in    number
    )
  IS
    SELECT
             epe.alws_dpnt_dsgn_flag
            ,epe.approval_status_cd
            ,epe.assignment_id
            ,epe.auto_enrt_flag
            ,epe.bnft_prvdr_pool_id
            ,epe.business_group_id
            ,epe.cmbn_plip_id
            ,epe.cmbn_ptip_id
            ,epe.cmbn_ptip_opt_id
            ,epe.comp_lvl_cd
            ,epe.crntly_enrd_flag
            ,epe.cryfwd_elig_dpnt_cd
            ,epe.ctfn_rqd_flag
            ,epe.dflt_flag
            ,epe.dpnt_cvg_strt_dt_cd
            ,epe.dpnt_cvg_strt_dt_rl
            ,epe.dpnt_dsgn_cd
            ,epe.elctbl_flag
            ,epe.elig_flag
            ,epe.elig_ovrid_dt
            ,epe.elig_ovrid_person_id
            ,epe.elig_per_elctbl_chc_id
            ,epe.enrt_cvg_strt_dt
            ,epe.enrt_cvg_strt_dt_cd
            ,epe.enrt_cvg_strt_dt_rl
            ,epe.erlst_deenrt_dt
            ,epe.fonm_cvg_strt_dt
            ,epe.inelig_rsn_cd
            ,epe.interim_elig_per_elctbl_chc_id
            ,epe.in_pndg_wkflow_flag
            ,epe.ler_chg_dpnt_cvg_cd
            ,epe.mgr_ovrid_dt
            ,epe.mgr_ovrid_person_id
            ,epe.mndtry_flag
            ,epe.must_enrl_anthr_pl_id
            ,epe.object_version_number
            ,epe.oiplip_id
            ,epe.oipl_id
            ,epe.oipl_ordr_num
            ,epe.per_in_ler_id
            ,epe.pgm_id
            ,epe.pil_elctbl_chc_popl_id
            ,epe.plip_id
            ,epe.plip_ordr_num
            ,epe.pl_id
            ,epe.pl_ordr_num
            ,epe.pl_typ_id
            ,epe.procg_end_dt
            ,epe.prtt_enrt_rslt_id
            ,epe.ptip_id
            ,epe.ptip_ordr_num
            ,epe.roll_crs_flag
            ,epe.spcl_rt_oipl_id
            ,epe.spcl_rt_pl_id
            ,epe.ws_mgr_id
            ,epe.yr_perd_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.per_in_ler_id = c_per_in_ler_id
    order by epe.PTIP_ORDR_NUM,
             epe.PLIP_ORDR_NUM,
             decode(epe.PL_ORDR_NUM, null, epe.OIPL_ORDR_NUM, epe.PL_ORDR_NUM),
             epe.PL_ORDR_NUM,
             decode(epe.PL_ORDR_NUM, null, null, epe.OIPL_ORDR_NUM);
  --
begin
  --
  open c_instance
    (c_per_in_ler_id => p_per_in_ler_id
    );
  fetch c_instance BULK COLLECT INTO
                                 l_alws_dpnt_dsgn_flag_va
                                ,l_approval_status_cd_va
                                ,l_assignment_id_va
                                ,l_auto_enrt_flag_va
                                ,l_bnft_prvdr_pool_id_va
                                ,l_business_group_id_va
                                ,l_cmbn_plip_id_va
                                ,l_cmbn_ptip_id_va
                                ,l_cmbn_ptip_opt_id_va
                                ,l_comp_lvl_cd_va
                                ,l_crntly_enrd_flag_va
                                ,l_cryfwd_elig_dpnt_cd_va
                                ,l_ctfn_rqd_flag_va
                                ,l_dflt_flag_va
                                ,l_dpnt_cvg_strt_dt_cd_va
                                ,l_dpnt_cvg_strt_dt_rl_va
                                ,l_dpnt_dsgn_cd_va
                                ,l_elctbl_flag_va
                                ,l_elig_flag_va
                                ,l_elig_ovrid_dt_va
                                ,l_elig_ovrid_person_id_va
                                ,l_elig_per_elctbl_chc_id_va
                                ,l_enrt_cvg_strt_dt_va
                                ,l_enrt_cvg_strt_dt_cd_va
                                ,l_enrt_cvg_strt_dt_rl_va
                                ,l_erlst_deenrt_dt_va
                                ,l_fonm_cvg_strt_dt_va
                                ,l_inelig_rsn_cd_va
                                ,l_interim_epe_id_va
                                ,l_in_pndg_wkflow_flag_va
                                ,l_ler_chg_dpnt_cvg_cd_va
                                ,l_mgr_ovrid_dt_va
                                ,l_mgr_ovrid_person_id_va
                                ,l_mndtry_flag_va
                                ,l_must_enrl_anthr_pl_id_va
                                ,l_object_version_number_va
                                ,l_oiplip_id_va
                                ,l_oipl_id_va
                                ,l_oipl_ordr_num_va
                                ,l_per_in_ler_id_va
                                ,l_pgm_id_va
                                ,l_pil_elctbl_chc_popl_id_va
                                ,l_plip_id_va
                                ,l_plip_ordr_num_va
                                ,l_pl_id_va
                                ,l_pl_ordr_num_va
                                ,l_pl_typ_id_va
                                ,l_procg_end_dt_va
                                ,l_prtt_enrt_rslt_id_va
                                ,l_ptip_id_va
                                ,l_ptip_ordr_num_va
                                ,l_roll_crs_flag_va
                                ,l_spcl_rt_oipl_id_va
                                ,l_spcl_rt_pl_id_va
                                ,l_ws_mgr_id_va
                                ,l_yr_perd_id_va;
  --
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
      g_epe_instance(l_hv).alws_dpnt_dsgn_flag           	  := l_alws_dpnt_dsgn_flag_va(i);
      g_epe_instance(l_hv).approval_status_cd            	  := l_approval_status_cd_va(i);
      g_epe_instance(l_hv).assignment_id                 	  := l_assignment_id_va(i);
      g_epe_instance(l_hv).auto_enrt_flag                	  := l_auto_enrt_flag_va(i);
      g_epe_instance(l_hv).bnft_prvdr_pool_id            	  := l_bnft_prvdr_pool_id_va(i);
      g_epe_instance(l_hv).business_group_id             	  := l_business_group_id_va(i);
      g_epe_instance(l_hv).cmbn_plip_id                  	  := l_cmbn_plip_id_va(i);
      g_epe_instance(l_hv).cmbn_ptip_id                  	  := l_cmbn_ptip_id_va(i);
      g_epe_instance(l_hv).cmbn_ptip_opt_id              	  := l_cmbn_ptip_opt_id_va(i);
      g_epe_instance(l_hv).comp_lvl_cd                   	  := l_comp_lvl_cd_va(i);
      g_epe_instance(l_hv).crntly_enrd_flag              	  := l_crntly_enrd_flag_va(i);
      g_epe_instance(l_hv).cryfwd_elig_dpnt_cd           	  := l_cryfwd_elig_dpnt_cd_va(i);
      g_epe_instance(l_hv).ctfn_rqd_flag                 	  := l_ctfn_rqd_flag_va(i);
      g_epe_instance(l_hv).dflt_flag                     	  := l_dflt_flag_va(i);
      g_epe_instance(l_hv).dpnt_cvg_strt_dt_cd           	  := l_dpnt_cvg_strt_dt_cd_va(i);
      g_epe_instance(l_hv).dpnt_cvg_strt_dt_rl           	  := l_dpnt_cvg_strt_dt_rl_va(i);
      g_epe_instance(l_hv).dpnt_dsgn_cd                  	  := l_dpnt_dsgn_cd_va(i);
      g_epe_instance(l_hv).elctbl_flag                   	  := l_elctbl_flag_va(i);
      g_epe_instance(l_hv).elig_flag                     	  := l_elig_flag_va(i);
      g_epe_instance(l_hv).elig_ovrid_dt                 	  := l_elig_ovrid_dt_va(i);
      g_epe_instance(l_hv).elig_ovrid_person_id          	  := l_elig_ovrid_person_id_va(i);
      g_epe_instance(l_hv).elig_per_elctbl_chc_id        	  := l_elig_per_elctbl_chc_id_va(i);
      g_epe_instance(l_hv).enrt_cvg_strt_dt              	  := l_enrt_cvg_strt_dt_va(i);
      g_epe_instance(l_hv).enrt_cvg_strt_dt_cd           	  := l_enrt_cvg_strt_dt_cd_va(i);
      g_epe_instance(l_hv).enrt_cvg_strt_dt_rl           	  := l_enrt_cvg_strt_dt_rl_va(i);
      g_epe_instance(l_hv).erlst_deenrt_dt               	  := l_erlst_deenrt_dt_va(i);
      g_epe_instance(l_hv).fonm_cvg_strt_dt              	  := l_fonm_cvg_strt_dt_va(i);
      g_epe_instance(l_hv).inelig_rsn_cd                 	  := l_inelig_rsn_cd_va(i);
      g_epe_instance(l_hv).interim_elig_per_elctbl_chc_id	  := l_interim_epe_id_va(i);
      g_epe_instance(l_hv).in_pndg_wkflow_flag           	  := l_in_pndg_wkflow_flag_va(i);
      g_epe_instance(l_hv).ler_chg_dpnt_cvg_cd           	  := l_ler_chg_dpnt_cvg_cd_va(i);
      g_epe_instance(l_hv).mgr_ovrid_dt                  	  := l_mgr_ovrid_dt_va(i);
      g_epe_instance(l_hv).mgr_ovrid_person_id           	  := l_mgr_ovrid_person_id_va(i);
      g_epe_instance(l_hv).mndtry_flag                   	  := l_mndtry_flag_va(i);
      g_epe_instance(l_hv).must_enrl_anthr_pl_id         	  := l_must_enrl_anthr_pl_id_va(i);
      g_epe_instance(l_hv).object_version_number         	  := l_object_version_number_va(i);
      g_epe_instance(l_hv).oiplip_id                     	  := l_oiplip_id_va(i);
      g_epe_instance(l_hv).oipl_id                       	  := l_oipl_id_va(i);
      g_epe_instance(l_hv).oipl_ordr_num                 	  := l_oipl_ordr_num_va(i);
      g_epe_instance(l_hv).per_in_ler_id                 	  := l_per_in_ler_id_va(i);
      g_epe_instance(l_hv).pgm_id                        	  := l_pgm_id_va(i);
      g_epe_instance(l_hv).pil_elctbl_chc_popl_id        	  := l_pil_elctbl_chc_popl_id_va(i);
      g_epe_instance(l_hv).plip_id                       	  := l_plip_id_va(i);
      g_epe_instance(l_hv).plip_ordr_num                 	  := l_plip_ordr_num_va(i);
      g_epe_instance(l_hv).pl_id                         	  := l_pl_id_va(i);
      g_epe_instance(l_hv).pl_ordr_num                   	  := l_pl_ordr_num_va(i);
      g_epe_instance(l_hv).pl_typ_id                     	  := l_pl_typ_id_va(i);
      g_epe_instance(l_hv).procg_end_dt                  	  := l_procg_end_dt_va(i);
      g_epe_instance(l_hv).prtt_enrt_rslt_id             	  := l_prtt_enrt_rslt_id_va(i);
      g_epe_instance(l_hv).ptip_id                       	  := l_ptip_id_va(i);
      g_epe_instance(l_hv).ptip_ordr_num                 	  := l_ptip_ordr_num_va(i);
      g_epe_instance(l_hv).roll_crs_flag                 	  := l_roll_crs_flag_va(i);
      g_epe_instance(l_hv).spcl_rt_oipl_id               	  := l_spcl_rt_oipl_id_va(i);
      g_epe_instance(l_hv).spcl_rt_pl_id                 	  := l_spcl_rt_pl_id_va(i);
      g_epe_instance(l_hv).ws_mgr_id                     	  := l_ws_mgr_id_va(i);
      g_epe_instance(l_hv).yr_perd_id                    	  := l_yr_perd_id_va(i);
      --
    end loop;
    --
  end if;
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
procedure init_context_pileperow
is

  l_currepe_row g_pilepe_inst_row;

begin
  --
  ben_reinstate_epe_cache.g_currepe_row := l_currepe_row;
  --
end init_context_pileperow;
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
  l_elig_per_elctbl_chc_id number ;
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
      FETCH c_choice_exists_for_plan INTO l_elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_plan;
      --
    else
      --
      OPEN c_choice_exists_for_plnip
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pl_id          => p_pl_id
        );
      FETCH c_choice_exists_for_plnip INTO l_elig_per_elctbl_chc_id;
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
      FETCH c_choice_exists_for_option INTO l_elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_option;
      --
    else
      --
      OPEN c_chc_exists_for_plnip_option
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_oipl_id        => p_oipl_id
        );
      FETCH c_chc_exists_for_plnip_option INTO l_elig_per_elctbl_chc_id;
      CLOSE c_chc_exists_for_plnip_option;
      --
    end if;
    --
  end if;
  --
  if l_elig_per_elctbl_chc_id is not null then
    --
    EPE_GetEPEDets
    (p_elig_per_elctbl_chc_id =>l_elig_per_elctbl_chc_id
    ,p_per_in_ler_id          =>p_per_in_ler_id
    ,p_inst_row               =>l_inst_row
    );
    --
  end if;
  --
  p_inst_row := l_inst_row;
  --
end get_pilcobjepe_dets;
--
procedure init_context_cobj_pileperow
is

  l_currepe_row g_pilepe_inst_row;

begin
  --
  ben_reinstate_epe_cache.g_currcobjepe_row := l_currepe_row;
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
  g_epe_instance.delete;
  g_epe_cached := 1;
  g_epe_current.per_in_ler_id := null;
  --
  init_context_pileperow;
  --
end clear_down_cache;
--
end ben_reinstate_epe_cache;

/
