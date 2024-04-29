--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_PROGRAM_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_PROGRAM_MODULE" as
/* $Header: bepdcpgm.pkb 120.7.12000000.2 2007/07/03 07:16:57 rgajula noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_plan_design_program_module.';
--
-- This procedure is used to create a row for each of the comp objects
-- selected by the end user on search page into
-- pqh_copy_entity_txn table.
-- This procedure should also copy all the child table data into
-- above table as well.
--
procedure create_program_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number
  ,p_pgm_id                         in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
  l_proc varchar2(72) := g_package||'create_program_result';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
  l_pgm_id              number(15) default p_pgm_id ;
  --
  l_cv_result_type_cd   varchar2(30) :=  'DISPLAY' ;
   --
   -- Cursor to get mirror_src_entity_result_id
   cursor c_parent_result(c_parent_pk_id number,
                    -- c_parent_table_name varchar2,
                    c_parent_table_alias varchar2,
                    c_copy_entity_txn_id number) is
   select copy_entity_result_id mirror_src_entity_result_id
   from ben_copy_entity_results cpe
--    ,pqh_table_route trt
   where cpe.information1= c_parent_pk_id
   and   cpe.result_type_cd = l_cv_result_type_cd
   and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and   cpe.table_route_id = trt.table_route_id
   -- and   trt.from_clause = 'OAB'
   --and   trt.where_clause = upper(c_parent_table_name) ;
   and   cpe.table_alias    = c_parent_table_alias ;
   ---
   --
   -- Bug : 3752407 : Global cursor g_table_route will now be used
   --
   -- Cursor to get table_route_id
   -- cursor c_table_route(c_parent_table_name varchar2) is
   -- cursor c_table_route(c_parent_table_alias varchar2) is
   -- select table_route_id
   -- from pqh_table_route trt
   -- where -- trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name) ;
   -- trt.table_alias = c_parent_table_alias ;
   --
   -- Bug : 3752407
   --

  ---------------------------------------------------------------
  -- START OF BEN_PGM_F ----------------------
  ---------------------------------------------------------------

   cursor c_pgm_from_parent(c_PGM_ID number) is
   select  distinct pgm_id
   from BEN_PGM_F
   where  PGM_ID = c_PGM_ID ;

   --
   cursor c_pgm(c_pgm_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  pgm.*
   from BEN_PGM_F pgm
   where  pgm.pgm_id = c_pgm_id
   --and pgm.business_group_id = p_business_group_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
--ggnanagu          ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and ( c_mirror_src_entity_result_id is null or
             mirror_src_entity_result_id = c_mirror_src_entity_result_id )
       and cpe.table_alias  = c_table_alias
       and information1 = c_pgm_id
       and information2 = pgm.effective_start_date
       and information3 = pgm.effective_end_date
     );
     l_out_pgm_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_PGM_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_CHG_DPNT_CVG_F ----------------------
  ---------------------------------------------------------------
   cursor c_ldc_from_parent(c_PGM_ID number) is
   select distinct ler_chg_dpnt_cvg_id
   from BEN_LER_CHG_DPNT_CVG_F
   where  PGM_ID = c_PGM_ID ;
   --
   cursor c_ldc(c_ler_chg_dpnt_cvg_id number ,c_mirror_src_entity_result_id number,
                                              c_table_alias varchar2 ) is
   select  ldc.*
   from BEN_LER_CHG_DPNT_CVG_F ldc
   where  ldc.ler_chg_dpnt_cvg_id = c_ler_chg_dpnt_cvg_id
   --and ldc.business_group_id = p_business_group_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results  cpe
--          ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and mirror_src_entity_result_id = c_mirror_src_entity_result_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_ler_chg_dpnt_cvg_id
       and information2 = ldc.effective_start_date
       and information3 = ldc.effective_end_date
    );
   l_ler_chg_dpnt_cvg_id              number(15);
   --
   cursor c_ldc_drp(c_ler_chg_dpnt_cvg_id number ,c_mirror_src_entity_result_id number,
                    c_table_alias varchar2 ) is
   select distinct cpe.information257 ler_id
     from ben_copy_entity_results cpe
--          ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_dpnt_cvg_id
    ;
    l_out_ldc_result_id number(15);

  ---------------------------------------------------------------
  -- END OF BEN_LER_CHG_DPNT_CVG_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_CHG_PGM_ENRT_F ----------------------
  ---------------------------------------------------------------
   cursor c_lge_from_parent(c_PGM_ID number) is
   select distinct ler_chg_pgm_enrt_id
   from BEN_LER_CHG_PGM_ENRT_F
   where  PGM_ID = c_PGM_ID ;
   --
   cursor c_lge(c_ler_chg_pgm_enrt_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  lge.*
   from BEN_LER_CHG_PGM_ENRT_F lge
   where  lge.ler_chg_pgm_enrt_id = c_ler_chg_pgm_enrt_id
   --and lge.business_group_id = p_business_group_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
--          ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and mirror_src_entity_result_id = c_mirror_src_entity_result_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_ler_chg_pgm_enrt_id
       and information2 = lge.effective_start_date
       and information3 = lge.effective_end_date
    );
   l_ler_chg_pgm_enrt_id              number(15);
   --
   cursor c_lge_drp(c_ler_chg_pgm_enrt_id number ,c_mirror_src_entity_result_id number,
                    c_table_alias varchar2 ) is
   select distinct cpe.information257 ler_id
     from ben_copy_entity_results cpe
--          ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     -- and trt.where_clause = 'BEN_LER_CHG_PGM_ENRT_F'
     and cpe.table_alias = c_table_alias
     and information1 = c_ler_chg_pgm_enrt_id
     -- and information4 = p_business_group_id
    ;
    l_out_lge_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_CHG_PGM_ENRT_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
  ---------------------------------------------------------------
   cursor c_peo_from_parent(c_PGM_ID number) is
   select  elig_to_prte_rsn_id
   from BEN_ELIG_TO_PRTE_RSN_F
   where  PGM_ID = c_PGM_ID ;
   --
   cursor c_peo(c_elig_to_prte_rsn_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  peo.*
   from BEN_ELIG_TO_PRTE_RSN_F peo
   where  peo.elig_to_prte_rsn_id = c_elig_to_prte_rsn_id
   --and peo.business_group_id = p_business_group_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and mirror_src_entity_result_id = c_mirror_src_entity_result_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_elig_to_prte_rsn_id
       and information2 = peo.effective_start_date
       and information3 = peo.effective_end_date
    );
   l_elig_to_prte_rsn_id              number(15);
   l_out_peo_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_PGM_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
   cursor c_pgc_from_parent(c_PGM_ID number) is
   select  pgm_dpnt_cvg_ctfn_id
   from BEN_PGM_DPNT_CVG_CTFN_F
   where  PGM_ID = c_PGM_ID ;
   --
   cursor c_pgc(c_pgm_dpnt_cvg_ctfn_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  pgc.*
   from BEN_PGM_DPNT_CVG_CTFN_F pgc
   where  pgc.pgm_dpnt_cvg_ctfn_id = c_pgm_dpnt_cvg_ctfn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and mirror_src_entity_result_id = c_mirror_src_entity_result_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_pgm_dpnt_cvg_ctfn_id
       and information2 = pgc.effective_start_date
       and information3 = pgc.effective_end_date
    );
   l_pgm_dpnt_cvg_ctfn_id              number(15);
   l_out_pgc_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_PGM_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
   cursor c_lcc_from_parent(c_LER_CHG_DPNT_CVG_ID number) is
   select  ler_chg_dpnt_cvg_ctfn_id
   from BEN_LER_CHG_DPNT_CVG_CTFN_F
   where  LER_CHG_DPNT_CVG_ID = c_LER_CHG_DPNT_CVG_ID ;
   --
   cursor c_lcc(c_ler_chg_dpnt_cvg_ctfn_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  lcc.*
   from BEN_LER_CHG_DPNT_CVG_CTFN_F lcc
   where  lcc.ler_chg_dpnt_cvg_ctfn_id = c_ler_chg_dpnt_cvg_ctfn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and mirror_src_entity_result_id = c_mirror_src_entity_result_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_ler_chg_dpnt_cvg_ctfn_id
       and information2 = lcc.effective_start_date
       and information3 = lcc.effective_end_date
    );
   l_ler_chg_dpnt_cvg_ctfn_id              number(15);
   l_out_lcc_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_PLIP_F ----------------------
  ---------------------------------------------------------------
   cursor c_cpp_from_parent(c_PGM_ID number) is
   select distinct plip_id
   from BEN_PLIP_F
   where  PGM_ID = c_PGM_ID ;
   --
   cursor c_cpp(c_plip_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  cpp.*
   from BEN_PLIP_F cpp
   where  cpp.plip_id = c_plip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_plip_id
       and information2 = cpp.effective_start_date
       and information3 = cpp.effective_end_date
    );
   l_plip_id              number(15);
   l_out_cpp_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_PLIP_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_PTIP_F ----------------------
  ---------------------------------------------------------------
   cursor c_ctp_from_parent(c_PGM_ID number) is
   select  distinct ptip_id
   from BEN_PTIP_F
   where  PGM_ID = c_PGM_ID ;
   --
   cursor c_ctp(c_ptip_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  ctp.*
   from BEN_PTIP_F ctp
   where  ctp.ptip_id = c_ptip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--       and trt.table_route_id = cpe.table_route_id
       and mirror_src_entity_result_id = c_mirror_src_entity_result_id
       and cpe.table_alias  = c_table_alias
       and information1 = c_ptip_id
       and information2 = ctp.effective_start_date
       and information3 = ctp.effective_end_date
    );
   l_ptip_id              number(15);
   l_out_ctp_result_id number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   cursor c_peo1_from_parent(c_PTIP_ID number) is
   select  elig_to_prte_rsn_id
   from BEN_ELIG_TO_PRTE_RSN_F
   where  PTIP_ID = c_PTIP_ID ;
   --
   cursor c_peo1(c_elig_to_prte_rsn_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2  ) is
   select  peo.*
   from BEN_ELIG_TO_PRTE_RSN_F peo
   where  peo.elig_to_prte_rsn_id = c_elig_to_prte_rsn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_elig_to_prte_rsn_id
       and information2 = peo.effective_start_date
       and information3 = peo.effective_end_date
    );
   l_elig_to_prte_rsn_id1   number(15);
   l_out_peo1_result_id      number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_DPNT_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_ldc1_from_parent(c_PTIP_ID number) is
   select distinct ler_chg_dpnt_cvg_id
   from BEN_LER_CHG_DPNT_CVG_F
   where  PTIP_ID = c_PTIP_ID ;
   --
   cursor c_ldc1(c_ler_chg_dpnt_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  ldc.*
   from BEN_LER_CHG_DPNT_CVG_F ldc
   where  ldc.ler_chg_dpnt_cvg_id = c_ler_chg_dpnt_cvg_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_dpnt_cvg_id
       and information2 = ldc.effective_start_date
       and information3 = ldc.effective_end_date
    );
   --
   cursor c_ldc1_drp(c_ler_chg_dpnt_cvg_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_dpnt_cvg_id
    ;
    l_out_ldc1_result_id number(15);
    l_ler_chg_dpnt_cvg_id1 number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LER_CHG_DPNT_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_PTIP_ENRT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lct1_from_parent(c_PTIP_ID number) is
   select distinct ler_chg_ptip_enrt_id
   from BEN_LER_CHG_PTIP_ENRT_F
   where  PTIP_ID = c_PTIP_ID ;
   --
   cursor c_lct1(c_ler_chg_ptip_enrt_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  lct.*
   from BEN_LER_CHG_PTIP_ENRT_F lct
   where  lct.ler_chg_ptip_enrt_id = c_ler_chg_ptip_enrt_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_ptip_enrt_id
       and information2 = lct.effective_start_date
       and information3 = lct.effective_end_date
    );
   l_ler_chg_ptip_enrt_id                 number(15);

   cursor c_lct1_drp(c_ler_chg_ptip_enrt_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
     from ben_copy_entity_results cpe
--          ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_ptip_enrt_id
    ;
   l_out_lct_result_id number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LER_CHG_PTIP_ENRT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PTIP_DPNT_CVG_CTFN_F ----------------------
   ---------------------------------------------------------------
   cursor c_pyd1_from_parent(c_PTIP_ID number) is
   select  ptip_dpnt_cvg_ctfn_id
   from BEN_PTIP_DPNT_CVG_CTFN_F
   where  PTIP_ID = c_PTIP_ID ;
   --
   cursor c_pyd1(c_ptip_dpnt_cvg_ctfn_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  pyd.*
   from BEN_PTIP_DPNT_CVG_CTFN_F pyd
   where  pyd.ptip_dpnt_cvg_ctfn_id = c_ptip_dpnt_cvg_ctfn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ptip_dpnt_cvg_ctfn_id
       and information2 = pyd.effective_start_date
       and information3 = pyd.effective_end_date
    );
   l_ptip_dpnt_cvg_ctfn_id                 number(15);
   l_out_pyd_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PTIP_DPNT_CVG_CTFN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_WV_PRTN_RSN_PTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_wpt1_from_parent(c_PTIP_ID number) is
   select  wv_prtn_rsn_ptip_id
   from BEN_WV_PRTN_RSN_PTIP_F
   where  PTIP_ID = c_PTIP_ID ;
   --
   cursor c_wpt1(c_wv_prtn_rsn_ptip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  wpt.*
   from BEN_WV_PRTN_RSN_PTIP_F wpt
   where  wpt.wv_prtn_rsn_ptip_id = c_wv_prtn_rsn_ptip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_wv_prtn_rsn_ptip_id
       and information2 = wpt.effective_start_date
       and information3 = wpt.effective_end_date
    );
   l_wv_prtn_rsn_ptip_id                 number(15);
   l_out_wpt_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_WV_PRTN_RSN_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_WV_PRTN_RSN_CTFN_PTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_wct1_from_parent(c_WV_PRTN_RSN_PTIP_ID number) is
   select  wv_prtn_rsn_ctfn_ptip_id
   from BEN_WV_PRTN_RSN_CTFN_PTIP_F
   where  WV_PRTN_RSN_PTIP_ID = c_WV_PRTN_RSN_PTIP_ID ;
   --
   cursor c_wct1(c_wv_prtn_rsn_ctfn_ptip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  wct.*
   from BEN_WV_PRTN_RSN_CTFN_PTIP_F wct
   where  wct.wv_prtn_rsn_ctfn_ptip_id = c_wv_prtn_rsn_ctfn_ptip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
     --     ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_wv_prtn_rsn_ctfn_ptip_id
       and information2 = wct.effective_start_date
       and information3 = wct.effective_end_date
    );
   l_wv_prtn_rsn_ctfn_ptip_id                 number(15);
   l_out_wct_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_WV_PRTN_RSN_CTFN_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
   ---------------------------------------------------------------
   cursor c_lcc1_from_parent(c_LER_CHG_DPNT_CVG_ID number) is
   select  ler_chg_dpnt_cvg_ctfn_id
   from BEN_LER_CHG_DPNT_CVG_CTFN_F
   where  LER_CHG_DPNT_CVG_ID = c_LER_CHG_DPNT_CVG_ID ;
   --
   cursor c_lcc1(c_ler_chg_dpnt_cvg_ctfn_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  lcc.*
   from BEN_LER_CHG_DPNT_CVG_CTFN_F lcc
   where  lcc.ler_chg_dpnt_cvg_ctfn_id = c_ler_chg_dpnt_cvg_ctfn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_dpnt_cvg_ctfn_id
       and information2 = lcc.effective_start_date
       and information3 = lcc.effective_end_date
    );

   l_ler_chg_dpnt_cvg_ctfn_id1 number;
   l_out_lcc1_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   cursor c_peo2_from_parent(c_PLIP_ID number) is
   select  elig_to_prte_rsn_id
   from BEN_ELIG_TO_PRTE_RSN_F
   where  PLIP_ID = c_PLIP_ID ;
   --
   cursor c_peo2(c_elig_to_prte_rsn_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  peo.*
   from BEN_ELIG_TO_PRTE_RSN_F peo
   where  peo.elig_to_prte_rsn_id = c_elig_to_prte_rsn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_elig_to_prte_rsn_id
       and information2 = peo.effective_start_date
       and information3 = peo.effective_end_date
   );
   l_elig_to_prte_rsn_id2   number(15);
   l_out_peo2_result_id     number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_BNFT_RSTRN_F ----------------------
   ---------------------------------------------------------------
   cursor c_lbr1_from_parent(c_PLIP_ID number) is
   select  ler_bnft_rstrn_id
   from BEN_LER_BNFT_RSTRN_F
   where  PLIP_ID = c_PLIP_ID ;
   --
   cursor c_lbr1(c_ler_bnft_rstrn_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  lbr.*
   from BEN_LER_BNFT_RSTRN_F lbr
   where  lbr.ler_bnft_rstrn_id = c_ler_bnft_rstrn_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_bnft_rstrn_id
     and information2 = lbr.effective_start_date
     and information3 = lbr.effective_end_date
   );
   l_ler_bnft_rstrn_id                 number(15);
   l_out_lbr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LER_BNFT_RSTRN_F ----------------------
   ---------------------------------------------------------------
    ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_PLIP_ENRT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lpr_from_parent(c_PLIP_ID number) is
   select distinct ler_chg_plip_enrt_id
   from BEN_LER_CHG_PLIP_ENRT_F
   where  PLIP_ID = c_PLIP_ID ;
   --
   cursor c_lpr(c_ler_chg_plip_enrt_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  lpr.*
   from BEN_LER_CHG_PLIP_ENRT_F lpr
   where  lpr.ler_chg_plip_enrt_id = c_ler_chg_plip_enrt_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
     --    and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         and cpe.table_alias  = c_table_alias
         and information1 = c_ler_chg_plip_enrt_id
           and information2 = lpr.effective_start_date
           and information3 = lpr.effective_end_date
        );
    l_ler_chg_plip_enrt_id                 number(15);
    l_out_lpr_result_id   number(15);
   --
   cursor c_lpr_drp(c_ler_chg_plip_enrt_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_ler_chg_plip_enrt_id
    ;
   ---------------------------------------------------------------
   -- END OF BEN_LER_CHG_PLIP_ENRT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CMBN_PLIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_cpl1_from_parent(c_PGM_ID number) is
   select distinct cp.cmbn_plip_id
   from  ben_cmbn_plip_f cp
   where cp.pgm_id = c_pgm_id;

   --
   cursor c_cpl1(c_cmbn_plip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  cpl.*
   from BEN_CMBN_PLIP_F cpl
   where  cpl.cmbn_plip_id = c_cmbn_plip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_cmbn_plip_id
     and information2 = cpl.effective_start_date
     and information3 = cpl.effective_end_date
    );
   l_cmbn_plip_id                 number(15);
   l_out_cpl_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CMBN_PLIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CMBN_PTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_cbp1_from_parent(c_PGM_ID number) is
   select distinct cp.cmbn_ptip_id
   from ben_cmbn_ptip_f cp
   where cp.pgm_id = c_pgm_id;

   --
   cursor c_cbp1(c_cmbn_ptip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  cbp.*
   from BEN_CMBN_PTIP_F cbp
   where  cbp.cmbn_ptip_id = c_cmbn_ptip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_cmbn_ptip_id
     and information2 = cbp.effective_start_date
     and information3 = cbp.effective_end_date
    );
   l_cmbn_ptip_id                 number(15);
   l_out_cbp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CMBN_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CMBN_PTIP_OPT_F ----------------------
   ---------------------------------------------------------------
   cursor c_cpt1_from_parent(c_PGM_ID number) is
   select distinct cp.cmbn_ptip_opt_id
   from ben_cmbn_ptip_opt_f cp
   where cp.pgm_id = c_pgm_id;
   --
   cursor c_cpt1(c_cmbn_ptip_opt_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  cpt.*
   from BEN_CMBN_PTIP_OPT_F cpt
   where  cpt.cmbn_ptip_opt_id = c_cmbn_ptip_opt_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_cmbn_ptip_opt_id
     and information2 = cpt.effective_start_date
     and information3 = cpt.effective_end_date
    );
   l_cmbn_ptip_opt_id                 number(15);
   l_out_cpt_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CMBN_PTIP_OPT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_OIPLIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_opp1_from_parent(c_PGM_ID number, c_table_alias varchar2 ) is
   select oiplip.oiplip_id,cpe_oipl.copy_entity_result_id
   from ben_oiplip_f oiplip,
        ben_plip_f plip,
        ben_copy_entity_results cpe_oipl,
        ben_copy_entity_results cpe_pl,
        ben_copy_entity_results cpe_plip
        -- ,pqh_table_route trt
   where plip.plip_id = oiplip.plip_id
   and plip.pgm_id = c_pgm_id
   and oiplip.oipl_id = cpe_oipl.information1
--   and cpe_oipl.table_route_id = trt.table_route_id
   and cpe_oipl.table_alias  = c_table_alias
   and cpe_oipl.copy_entity_txn_id = p_copy_entity_txn_id
   and cpe_oipl.mirror_src_entity_result_id = cpe_pl.copy_entity_result_id
   and cpe_oipl.copy_entity_txn_id = cpe_pl.copy_entity_txn_id
   and cpe_pl.mirror_src_entity_result_id = cpe_plip.copy_entity_result_id
   and cpe_pl.copy_entity_txn_id = cpe_plip.copy_entity_txn_id
   and cpe_plip.information1 = oiplip.plip_id;

   --
   cursor c_opp1(c_oiplip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  opp.*
   from BEN_OIPLIP_F opp
   where  opp.oiplip_id = c_oiplip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_oiplip_id
       and information2 = opp.effective_start_date
       and information3 = opp.effective_end_date
    );
   l_oiplip_id                 number(15);
   l_out_opp_result_id   number(15);
   --------------------------------------------------------------
   -- END OF BEN_OIPLIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_OPTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_otp1_from_parent(c_PGM_ID number,c_table_alias varchar2 ) is
   select optip.optip_id,cpe.copy_entity_result_id
   from ben_optip_f optip,
        ben_ptip_f ptip,
        ben_copy_entity_results cpe
        -- ,pqh_table_route trt
   where ptip.ptip_id = optip.ptip_id
   and ptip.pgm_id = c_pgm_id
   and optip.opt_id = cpe.information1
--   and cpe.table_route_id = trt.table_route_id
   and cpe.table_alias  = c_table_alias
   and cpe.copy_entity_txn_id = p_copy_entity_txn_id ;
   --
   cursor c_otp1(c_optip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  otp.*
   from BEN_OPTIP_F otp
   where  otp.optip_id = c_optip_id
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
  --   and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_optip_id
       and information2 = otp.effective_start_date
       and information3 = otp.effective_end_date
    );
   l_optip_id                 number(15);
   l_out_otp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_OPTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------
   cursor c_ptp_from_parent(c_PTIP_ID number) is
   select  distinct pl_typ_id
   from BEN_PTIP_F
   where  PTIP_ID = c_PTIP_ID ;
   --
   l_pl_typ_id                 number(15);
   l_out_ptp_result_id         number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------
   -- Added to Fetch Lookup Meaning for Program Type
   cursor c_lookup_meaning(c_lookup_code in varchar2,c_lookup_type in varchar2) is
   select hl.meaning
   from   hr_lookups hl
   where  hl.lookup_code = c_lookup_code
   and    hl.lookup_type = c_lookup_type;

   l_program_type_meaning      hr_lookups.meaning%type;

   cursor c_object_exists(c_pk_id                number,
                         c_table_alias          varchar2) is
   select null
   from ben_copy_entity_results cpe
        -- ,pqh_table_route trt
   where copy_entity_txn_id = p_copy_entity_txn_id
--   and trt.table_route_id = cpe.table_route_id
   and cpe.table_alias = c_table_alias
   and information1 = c_pk_id;

   l_dummy                        varchar2(1);

   l_table_route_id            number(15);
   l_mirror_src_entity_result_id number(15);
   l_result_type_cd            varchar2(30);
   l_information5              ben_copy_entity_results.information5%type;
   l_number_of_copies          number(15);
   l_child_exists              boolean default false ;

   begin
   --
   --
   l_number_of_copies := p_number_of_copies ;

   if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
     ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
   else
     ben_plan_design_program_module.g_pdw_allow_dup_rslt := NULL;
   end if;

   if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
     open c_object_exists(p_pgm_id,'PGM');
     fetch c_object_exists into l_dummy;
     if c_object_exists%found then
       close c_object_exists;
       return;
     end if;
     close c_object_exists;
   end if;

   --
   ---------------------------------------------------------------
   -- START OF BEN_PGM_F ----------------------
   ---------------------------------------------------------------
    l_mirror_src_entity_result_id := null ;
   --
   for l_pgm_rec in c_pgm(p_pgm_id,l_mirror_src_entity_result_id,'PGM' ) loop
   --
    l_mirror_src_entity_result_id := null ;

    --
    l_table_route_id := null ;
    open g_table_route('PGM');
      fetch g_table_route into l_table_route_id ;
    close g_table_route ;
    --
    l_information5  := l_pgm_rec.name; --'Intersection';
    --
    l_pgm_id := l_pgm_rec.pgm_id ;
    if p_effective_date between l_pgm_rec.effective_start_date
       and l_pgm_rec.effective_end_date then
       --
       l_result_type_cd := 'DISPLAY';
    else
       l_result_type_cd := 'NO DISPLAY';
    end if;
    --
    l_copy_entity_result_id := null;
    l_object_version_number := null;

    -- Begin: Fetch Lookup Meaning for Program Type

    l_program_type_meaning := null ;
    open c_lookup_meaning(l_pgm_rec.pgm_typ_cd,'BEN_PGM_TYP');
    fetch c_lookup_meaning into l_program_type_meaning;
    close c_lookup_meaning;

    -- End: Fetch Lookup Meaning for Program Type

    ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => null,
        p_parent_entity_result_id        => null,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                   => 'PGM',
        p_information1     => l_pgm_rec.pgm_id,
        p_information2     => l_pgm_rec.EFFECTIVE_START_DATE,
        p_information3     => l_pgm_rec.EFFECTIVE_END_DATE,
        p_information4     => l_pgm_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
        p_information6     => l_program_type_meaning , -- Lookup Meaning for Program Type
        p_information8     => 'PGM',
            p_information41     => l_pgm_rec.acty_ref_perd_cd,
            p_information36     => l_pgm_rec.alws_unrstrctd_enrt_flag,
            p_information272     => l_pgm_rec.auto_enrt_mthd_rl,
            p_information30     => l_pgm_rec.coord_cvg_for_all_pls_flg,
            p_information257     => l_pgm_rec.dflt_element_type_id,
            p_information258     => l_pgm_rec.dflt_input_value_id,
            p_information13     => l_pgm_rec.dflt_pgm_flag,
            p_information14     => l_pgm_rec.dflt_step_cd,
            p_information259     => l_pgm_rec.dflt_step_rl,
            p_information21     => l_pgm_rec.dpnt_adrs_rqd_flag,
            p_information43     => l_pgm_rec.dpnt_cvg_end_dt_cd,
            p_information269     => l_pgm_rec.dpnt_cvg_end_dt_rl,
            p_information44     => l_pgm_rec.dpnt_cvg_strt_dt_cd,
            p_information268     => l_pgm_rec.dpnt_cvg_strt_dt_rl,
            p_information23     => l_pgm_rec.dpnt_dob_rqd_flag,
            p_information40     => l_pgm_rec.dpnt_dsgn_cd,
            p_information37     => l_pgm_rec.dpnt_dsgn_lvl_cd,
            p_information31     => l_pgm_rec.dpnt_dsgn_no_ctfn_rqd_flag,
            p_information25     => l_pgm_rec.dpnt_legv_id_rqd_flag,
            p_information34     => l_pgm_rec.drvbl_fctr_apls_rts_flag,
            p_information32     => l_pgm_rec.drvbl_fctr_dpnt_elig_flag,
            p_information33     => l_pgm_rec.drvbl_fctr_prtn_elig_flag,
            p_information26     => l_pgm_rec.elig_apls_flag,
            p_information51     => l_pgm_rec.enrt_cd,
            p_information42     => l_pgm_rec.enrt_cvg_end_dt_cd,
            p_information266     => l_pgm_rec.enrt_cvg_end_dt_rl,
            p_information45     => l_pgm_rec.enrt_cvg_strt_dt_cd,
            p_information267     => l_pgm_rec.enrt_cvg_strt_dt_rl,
            p_information46     => l_pgm_rec.enrt_info_rt_freq_cd,
            p_information52     => l_pgm_rec.enrt_mthd_cd,
            p_information273     => l_pgm_rec.enrt_rl,
            p_information141     => l_pgm_rec.ivr_ident,
            p_information287     => l_pgm_rec.mx_dpnt_pct_prtt_lf_amt,
            p_information288     => l_pgm_rec.mx_sps_pct_prtt_lf_amt,
            p_information170     => l_pgm_rec.name,
            p_information20     => l_pgm_rec.per_cvrd_cd,
            p_information111     => l_pgm_rec.pgm_attribute1,
            p_information120     => l_pgm_rec.pgm_attribute10,
            p_information121     => l_pgm_rec.pgm_attribute11,
            p_information122     => l_pgm_rec.pgm_attribute12,
            p_information123     => l_pgm_rec.pgm_attribute13,
            p_information124     => l_pgm_rec.pgm_attribute14,
            p_information125     => l_pgm_rec.pgm_attribute15,
            p_information126     => l_pgm_rec.pgm_attribute16,
            p_information127     => l_pgm_rec.pgm_attribute17,
            p_information128     => l_pgm_rec.pgm_attribute18,
            p_information129     => l_pgm_rec.pgm_attribute19,
            p_information112     => l_pgm_rec.pgm_attribute2,
            p_information130     => l_pgm_rec.pgm_attribute20,
            p_information131     => l_pgm_rec.pgm_attribute21,
            p_information132     => l_pgm_rec.pgm_attribute22,
            p_information133     => l_pgm_rec.pgm_attribute23,
            p_information134     => l_pgm_rec.pgm_attribute24,
            p_information135     => l_pgm_rec.pgm_attribute25,
            p_information136     => l_pgm_rec.pgm_attribute26,
            p_information137     => l_pgm_rec.pgm_attribute27,
            p_information138     => l_pgm_rec.pgm_attribute28,
            p_information139     => l_pgm_rec.pgm_attribute29,
            p_information113     => l_pgm_rec.pgm_attribute3,
            p_information140     => l_pgm_rec.pgm_attribute30,
            p_information114     => l_pgm_rec.pgm_attribute4,
            p_information115     => l_pgm_rec.pgm_attribute5,
            p_information116     => l_pgm_rec.pgm_attribute6,
            p_information117     => l_pgm_rec.pgm_attribute7,
            p_information118     => l_pgm_rec.pgm_attribute8,
            p_information119     => l_pgm_rec.pgm_attribute9,
            p_information110     => l_pgm_rec.pgm_attribute_category,
            p_information219     => l_pgm_rec.pgm_desc,
            p_information49     => l_pgm_rec.pgm_grp_cd,
            p_information22     => l_pgm_rec.pgm_prvds_no_auto_enrt_flag,
            p_information24     => l_pgm_rec.pgm_prvds_no_dflt_enrt_flag,
            p_information38     => l_pgm_rec.pgm_stat_cd,
            p_information39     => l_pgm_rec.pgm_typ_cd,
            p_information50     => l_pgm_rec.pgm_uom,
            p_information29     => l_pgm_rec.pgm_use_all_asnts_elig_flag,
            p_information53     => l_pgm_rec.poe_lvl_cd,
            p_information28     => l_pgm_rec.prtn_elig_ovrid_alwd_flag,
            p_information48     => l_pgm_rec.rt_end_dt_cd,
            p_information271     => l_pgm_rec.rt_end_dt_rl,
            p_information47     => l_pgm_rec.rt_strt_dt_cd,
            p_information270     => l_pgm_rec.rt_strt_dt_rl,
            p_information15     => l_pgm_rec.scores_calc_mthd_cd,
            p_information261     => l_pgm_rec.scores_calc_rl,
            p_information11     => l_pgm_rec.short_code,
            p_information12     => l_pgm_rec.short_name,
            p_information35     => l_pgm_rec.trk_inelig_per_flag,
            p_information16     => l_pgm_rec.update_salary_cd,
            p_information185     => l_pgm_rec.url_ref_name,
            p_information17     => l_pgm_rec.use_multi_pay_rates_flag,
            p_information18     => l_pgm_rec.use_prog_points_flag,
            p_information19     => l_pgm_rec.use_scores_cd,
            p_information27     => l_pgm_rec.uses_all_asmts_for_rts_flag,
            p_information54     => l_pgm_rec.vrfy_fmly_mmbr_cd,
            p_information274     => l_pgm_rec.vrfy_fmly_mmbr_rl,
            -- GSP
            p_information69     => l_pgm_rec.use_variable_rates_flag,
            p_information70     => l_pgm_rec.salary_calc_mthd_cd,
            p_information72     => l_pgm_rec.gsp_allow_override_flag,
            p_information293    => l_pgm_rec.salary_calc_mthd_rl,

            p_INFORMATION196    => l_pgm_rec.SUSP_IF_DPNT_SSN_NT_PRV_CD,
            p_INFORMATION190    => l_pgm_rec.SUSP_IF_DPNT_DOB_NT_PRV_CD,
            p_INFORMATION191    => l_pgm_rec.SUSP_IF_DPNT_ADR_NT_PRV_CD,
            p_INFORMATION192    => l_pgm_rec.SUSP_IF_CTFN_NOT_DPNT_FLAG,
            p_INFORMATION193    => l_pgm_rec.DPNT_CTFN_DETERMINE_CD,
            p_information265    => l_pgm_rec.object_version_number,
           --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
         --

         if l_out_pgm_result_id is null then
           l_out_pgm_result_id := l_copy_entity_result_id;
         end if;

         if l_result_type_cd = 'DISPLAY' then
           l_out_pgm_result_id := l_copy_entity_result_id ;
         end if;

         -- Copy Fast Formulas if any are attached to any column --

         ---------------------------------------------------------------
         -- SALARY_CALC_MTHD_RL -----------------
         ---------------------------------------------------------------

         if to_char(l_pgm_rec.salary_calc_mthd_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_pgm_rec.salary_calc_mthd_rl
                 ,p_business_group_id              =>  l_pgm_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
         end if;

         ---------------------------------------------------------------
         -- DFLT_STEP_RL -----------------
         ---------------------------------------------------------------

         if to_char(l_pgm_rec.Dflt_step_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_pgm_rec.Dflt_step_rl
                 ,p_business_group_id              =>  l_pgm_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
         end if;

         ---------------------------------------------------------------
         -- SCORES_CALC_RL -----------------
         ---------------------------------------------------------------

         if to_char(l_pgm_rec.Scores_calc_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_pgm_rec.Scores_calc_rl
                 ,p_business_group_id              =>  l_pgm_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
         end if;

         ---------------------------------------------------------------
         -- AUTO_ENRT_MTHD_RL -----------------
         ---------------------------------------------------------------

         if to_char(l_pgm_rec.auto_enrt_mthd_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_pgm_rec.auto_enrt_mthd_rl
                 ,p_business_group_id              =>  l_pgm_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
         end if;

         ---------------------------------------------------------------
         -- DPNT_CVG_END_DT_RL -----------------
         ---------------------------------------------------------------

          if to_char(l_pgm_rec.dpnt_cvg_end_dt_rl) is not null then
              --
              ben_plan_design_program_module.create_formula_result
              (
               p_validate                       =>  0
              ,p_copy_entity_result_id          =>  l_copy_entity_result_id
              ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
              ,p_formula_id                     =>  l_pgm_rec.dpnt_cvg_end_dt_rl
              ,p_business_group_id              =>  l_pgm_rec.business_group_id
              ,p_number_of_copies               =>  l_number_of_copies
              ,p_object_version_number          =>  l_object_version_number
              ,p_effective_date                 =>  p_effective_date
              );

              --
          end if;

          ---------------------------------------------------------------
          -- DPNT_CVG_STRT_DT_RL -----------------
          ---------------------------------------------------------------

          if to_char(l_pgm_rec.dpnt_cvg_strt_dt_rl) is not null then
               --
               ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_pgm_rec.dpnt_cvg_strt_dt_rl
                ,p_business_group_id              =>  l_pgm_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

               --
          end if;

          ---------------------------------------------------------------
          -- ENRT_CVG_END_DT_RL -----------------
          ---------------------------------------------------------------

          if to_char(l_pgm_rec.enrt_cvg_end_dt_rl) is not null then
             --
             ben_plan_design_program_module.create_formula_result
              (
               p_validate                       =>  0
              ,p_copy_entity_result_id          =>  l_copy_entity_result_id
              ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
              ,p_formula_id                     =>  l_pgm_rec.enrt_cvg_end_dt_rl
              ,p_business_group_id              =>  l_pgm_rec.business_group_id
              ,p_number_of_copies               =>  l_number_of_copies
              ,p_object_version_number          =>  l_object_version_number
              ,p_effective_date                 =>  p_effective_date
              );

             --
          end if;

          ---------------------------------------------------------------
          -- ENRT_CVG_STRT_DT_RL -----------------
          ---------------------------------------------------------------

          if to_char(l_pgm_rec.enrt_cvg_strt_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_pgm_rec.enrt_cvg_strt_dt_rl
                 ,p_business_group_id              =>  l_pgm_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                --
          end if;

          ---------------------------------------------------------------
          -- ENRT_RL -----------------
          ---------------------------------------------------------------

          if to_char(l_pgm_rec.enrt_rl) is not null then
            --
            ben_plan_design_program_module.create_formula_result
             (
              p_validate                       =>  0
             ,p_copy_entity_result_id          =>  l_copy_entity_result_id
             ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
             ,p_formula_id                     =>  l_pgm_rec.enrt_rl
             ,p_business_group_id              =>  l_pgm_rec.business_group_id
             ,p_number_of_copies               =>  l_number_of_copies
             ,p_object_version_number          =>  l_object_version_number
             ,p_effective_date                 =>  p_effective_date
             );

            --
          end if;

          ---------------------------------------------------------------
          -- RT_END_DT_RL -----------------
          ---------------------------------------------------------------

          if to_char(l_pgm_rec.rt_end_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_pgm_rec.rt_end_dt_rl
                 ,p_business_group_id              =>  l_pgm_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                --
          end if;

          ---------------------------------------------------------------
          -- RT_STRT_DT_RL -----------------
          ---------------------------------------------------------------

          if to_char(l_pgm_rec.rt_strt_dt_rl) is not null then
                  --
                  ben_plan_design_program_module.create_formula_result
                   (
                    p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_pgm_rec.rt_strt_dt_rl
                   ,p_business_group_id              =>  l_pgm_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                   );

                  --
          end if;

         ---------------------------------------------------------------
         -- VRFY_FMLY_MMBR_RL -----------------
         ---------------------------------------------------------------

         if to_char(l_pgm_rec.vrfy_fmly_mmbr_rl) is not null then
              --
              ben_plan_design_program_module.create_formula_result
               (
                p_validate                       =>  0
               ,p_copy_entity_result_id          =>  l_copy_entity_result_id
               ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
               ,p_formula_id                     =>  l_pgm_rec.vrfy_fmly_mmbr_rl
               ,p_business_group_id              =>  l_pgm_rec.business_group_id
               ,p_number_of_copies               =>  l_number_of_copies
               ,p_object_version_number          =>  l_object_version_number
               ,p_effective_date                 =>  p_effective_date
               );

              --
         end if;

 end loop;
  ---------------------------------------------------------------
  -- END OF BEN_PGM_F ----------------------
  ---------------------------------------------------------------
  --

  if p_number_of_copies = 1 then

      if l_out_pgm_result_id is null then
        --
        -- Program created earlier with number_copies as 0
        --
        open c_parent_result(p_pgm_id,'PGM',p_copy_entity_txn_id);
        fetch c_parent_result into l_out_pgm_result_id ;
        close c_parent_result;
      end if;


          -- ------------------------------------------------------------------------
          -- POPL Genenation call
          -- ------------------------------------------------------------------------
          l_mirror_src_entity_result_id := l_out_pgm_result_id;

          --
          ben_plan_design_plan_module.create_popl_result
            (
              p_validate                     => p_validate
             ,p_copy_entity_result_id        => l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id           => p_copy_entity_txn_id
             ,p_pgm_id                       => p_pgm_id
             ,p_pl_id                        => null
             ,p_business_group_id            => p_business_group_id
             ,p_number_of_copies             => p_number_of_copies
             ,p_object_version_number        => l_object_version_number
             ,p_effective_date               => p_effective_date
             ,p_parent_entity_result_id      => l_mirror_src_entity_result_id
            );
          -- ------------------------------------------------------------------------
          -- Eligibility Profiles
          -- ------------------------------------------------------------------------
          ben_plan_design_elpro_module.create_elpro_results
            (
              p_validate                     => p_validate
             ,p_copy_entity_result_id        => l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id           => p_copy_entity_txn_id
             ,p_pgm_id                       => p_pgm_id
             ,p_ptip_id                      => null
             ,p_plip_id                      => null
             ,p_pl_id                        => null
             ,p_oipl_id                      => null
             ,p_business_group_id            => p_business_group_id
             ,p_number_of_copies             => p_number_of_copies
             ,p_object_version_number        => l_object_version_number
             ,p_effective_date               => p_effective_date
             ,p_parent_entity_result_id      => l_mirror_src_entity_result_id
            );
          -- ------------------------------------------------------------------------
          -- Dependent Eligibility Profiles
          -- ------------------------------------------------------------------------
          ben_plan_design_elpro_module.create_dep_elpro_result
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => p_pgm_id
             ,p_ptip_id                    => null
             ,p_pl_id                      => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_mirror_src_entity_result_id
            );
            -- ------------------------------------------------------------------------
            -- Standard Rates ,Flex Credits at Program level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => p_pgm_id
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_pl_id                      => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_mirror_src_entity_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools  Program Level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => p_pgm_id
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_mirror_src_entity_result_id
             ) ;

            -- ------------------------------------------------------------------------
            -- Coverage Across Plan Types
            -- ------------------------------------------------------------------------
            ben_pd_rate_and_cvg_module.create_acrs_ptip_cvg_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => p_pgm_id
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ) ;


   ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_DPNT_CVG_F ----------------------
   ---------------------------------------------------------------
   --
   for l_parent_rec  in c_ldc_from_parent(l_PGM_ID) loop
   --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    l_ler_chg_dpnt_cvg_id := l_parent_rec.ler_chg_dpnt_cvg_id ;
    --
    for l_ldc_rec in c_ldc(l_parent_rec.ler_chg_dpnt_cvg_id,l_mirror_src_entity_result_id,'LDC' ) loop
    --
    --
      l_table_route_id := null ;
      open g_table_route('LDC');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := get_ler_name(l_ldc_rec.ler_id,p_effective_date); --'Intersection';
      --

      if p_effective_date between l_ldc_rec.effective_start_date
      and l_ldc_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
      --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                   => 'LDC',
        p_information1     => l_ldc_rec.ler_chg_dpnt_cvg_id,
        p_information2     => l_ldc_rec.EFFECTIVE_START_DATE,
        p_information3     => l_ldc_rec.EFFECTIVE_END_DATE,
        p_information4     => l_ldc_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information11     => l_ldc_rec.add_rmv_cvg_cd,
            p_information12     => l_ldc_rec.cvg_eff_end_cd,
            p_information263     => l_ldc_rec.cvg_eff_end_rl,
            p_information13     => l_ldc_rec.cvg_eff_strt_cd,
            p_information262     => l_ldc_rec.cvg_eff_strt_rl,
            p_information111     => l_ldc_rec.ldc_attribute1,
            p_information120     => l_ldc_rec.ldc_attribute10,
            p_information121     => l_ldc_rec.ldc_attribute11,
            p_information122     => l_ldc_rec.ldc_attribute12,
            p_information123     => l_ldc_rec.ldc_attribute13,
            p_information124     => l_ldc_rec.ldc_attribute14,
            p_information125     => l_ldc_rec.ldc_attribute15,
            p_information126     => l_ldc_rec.ldc_attribute16,
            p_information127     => l_ldc_rec.ldc_attribute17,
            p_information128     => l_ldc_rec.ldc_attribute18,
            p_information129     => l_ldc_rec.ldc_attribute19,
            p_information112     => l_ldc_rec.ldc_attribute2,
            p_information130     => l_ldc_rec.ldc_attribute20,
            p_information131     => l_ldc_rec.ldc_attribute21,
            p_information132     => l_ldc_rec.ldc_attribute22,
            p_information133     => l_ldc_rec.ldc_attribute23,
            p_information134     => l_ldc_rec.ldc_attribute24,
            p_information135     => l_ldc_rec.ldc_attribute25,
            p_information136     => l_ldc_rec.ldc_attribute26,
            p_information137     => l_ldc_rec.ldc_attribute27,
            p_information138     => l_ldc_rec.ldc_attribute28,
            p_information139     => l_ldc_rec.ldc_attribute29,
            p_information113     => l_ldc_rec.ldc_attribute3,
            p_information140     => l_ldc_rec.ldc_attribute30,
            p_information114     => l_ldc_rec.ldc_attribute4,
            p_information115     => l_ldc_rec.ldc_attribute5,
            p_information116     => l_ldc_rec.ldc_attribute6,
            p_information117     => l_ldc_rec.ldc_attribute7,
            p_information118     => l_ldc_rec.ldc_attribute8,
            p_information119     => l_ldc_rec.ldc_attribute9,
            p_information110     => l_ldc_rec.ldc_attribute_category,
            p_information14     => l_ldc_rec.ler_chg_dpnt_cvg_cd,
            p_information258     => l_ldc_rec.ler_chg_dpnt_cvg_rl,
            p_information257     => l_ldc_rec.ler_id,
            p_information260     => l_ldc_rec.pgm_id,
            p_information261     => l_ldc_rec.pl_id,
            p_information259     => l_ldc_rec.ptip_id,
            p_information198     => l_ldc_rec.susp_if_ctfn_not_prvd_flag,
            p_information197     => l_ldc_rec.ctfn_determine_cd,
            p_information265     => l_ldc_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
 --

        if l_out_ldc_result_id is null then
          l_out_ldc_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_ldc_result_id := l_copy_entity_result_id ;
        end if;
        --


--Start Bug 6162249
	  if (l_ldc_rec.cvg_eff_end_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
				p_validate                       => p_validate
				,p_copy_entity_result_id  => l_copy_entity_result_id
				,p_copy_entity_txn_id      => p_copy_entity_txn_id
				,p_formula_id                  =>  l_ldc_rec.cvg_eff_end_rl
				,p_business_group_id        =>  l_ldc_rec.business_group_id
				,p_number_of_copies         =>  l_number_of_copies
				,p_object_version_number  => l_object_version_number
				,p_effective_date             => p_effective_date);
		end if;

	  if (l_ldc_rec.cvg_eff_strt_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
				p_validate                       => p_validate
				,p_copy_entity_result_id  => l_copy_entity_result_id
				,p_copy_entity_txn_id      => p_copy_entity_txn_id
				,p_formula_id                  =>  l_ldc_rec.cvg_eff_strt_rl
				,p_business_group_id        =>  l_ldc_rec.business_group_id
				,p_number_of_copies         =>  l_number_of_copies
				,p_object_version_number  => l_object_version_number
				,p_effective_date             => p_effective_date);
		end if;

	  if (l_ldc_rec.ler_chg_dpnt_cvg_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
				p_validate                       => p_validate
				,p_copy_entity_result_id  => l_copy_entity_result_id
				,p_copy_entity_txn_id      => p_copy_entity_txn_id
				,p_formula_id                  =>  l_ldc_rec.ler_chg_dpnt_cvg_rl
				,p_business_group_id        =>  l_ldc_rec.business_group_id
				,p_number_of_copies         =>  l_number_of_copies
				,p_object_version_number  => l_object_version_number
				,p_effective_date             => p_effective_date);
		end if;

--End Bug 6162249



   end loop;
   --
   for l_ldc_rec in c_ldc_drp(l_parent_rec.ler_chg_dpnt_cvg_id,l_mirror_src_entity_result_id,'LDC' ) loop
    --
    ben_plan_design_plan_module.create_ler_result (
             p_validate                       => p_validate
            ,p_copy_entity_result_id          => l_out_ldc_result_id
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_ler_id                         => l_ldc_rec.ler_id
            ,p_business_group_id              => p_business_group_id
            ,p_number_of_copies               => p_number_of_copies
            ,p_object_version_number          => l_object_version_number
            ,p_effective_date                 => p_effective_date
            );
    end loop ;
    ---------------------------------------------------------------
    -- START OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
    ---------------------------------------------------------------
    --
    for l_parent_rec  in c_lcc_from_parent(l_LER_CHG_DPNT_CVG_ID) loop
    --
         l_mirror_src_entity_result_id := l_out_ldc_result_id ;

         l_ler_chg_dpnt_cvg_ctfn_id :=l_parent_rec.ler_chg_dpnt_cvg_ctfn_id ;
      --
      for l_lcc_rec in c_lcc(l_parent_rec.ler_chg_dpnt_cvg_ctfn_id,l_mirror_src_entity_result_id,'LCC' ) loop
      --
         --
         l_table_route_id := null ;
         open g_table_route('LCC');
           fetch g_table_route into l_table_route_id ;
         close g_table_route ;
         --
         l_information5  := hr_general.decode_lookup('BEN_DPNT_CVG_CTFN_TYP',l_lcc_rec.dpnt_cvg_ctfn_typ_cd); --'Intersection';
         --

         if p_effective_date between l_lcc_rec.effective_start_date
            and l_lcc_rec.effective_end_date then
            --
            l_result_type_cd := 'DISPLAY';
         else
            l_result_type_cd := 'NO DISPLAY';
         end if;
         --
         l_copy_entity_result_id := null;
         l_object_version_number := null;
         ben_copy_entity_results_api.create_copy_entity_results(
             p_copy_entity_result_id           => l_copy_entity_result_id,
             p_copy_entity_txn_id             => p_copy_entity_txn_id,
             p_result_type_cd                 => l_result_type_cd,
             p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
             p_parent_entity_result_id        => l_mirror_src_entity_result_id,
             p_number_of_copies               => l_number_of_copies,
             p_table_route_id                 => l_table_route_id,
             p_table_alias                   => 'LCC',
             p_information1     => l_lcc_rec.ler_chg_dpnt_cvg_ctfn_id,
             p_information2     => l_lcc_rec.EFFECTIVE_START_DATE,
             p_information3     => l_lcc_rec.EFFECTIVE_END_DATE,
             p_information4     => l_lcc_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information261     => l_lcc_rec.ctfn_rqd_when_rl,
            p_information12     => l_lcc_rec.dpnt_cvg_ctfn_typ_cd,
            p_information13     => l_lcc_rec.lack_ctfn_sspnd_enrt_flag,
            p_information111     => l_lcc_rec.lcc_attribute1,
            p_information120     => l_lcc_rec.lcc_attribute10,
            p_information121     => l_lcc_rec.lcc_attribute11,
            p_information122     => l_lcc_rec.lcc_attribute12,
            p_information123     => l_lcc_rec.lcc_attribute13,
            p_information124     => l_lcc_rec.lcc_attribute14,
            p_information125     => l_lcc_rec.lcc_attribute15,
            p_information126     => l_lcc_rec.lcc_attribute16,
            p_information127     => l_lcc_rec.lcc_attribute17,
            p_information128     => l_lcc_rec.lcc_attribute18,
            p_information129     => l_lcc_rec.lcc_attribute19,
            p_information112     => l_lcc_rec.lcc_attribute2,
            p_information130     => l_lcc_rec.lcc_attribute20,
            p_information131     => l_lcc_rec.lcc_attribute21,
            p_information132     => l_lcc_rec.lcc_attribute22,
            p_information133     => l_lcc_rec.lcc_attribute23,
            p_information134     => l_lcc_rec.lcc_attribute24,
            p_information135     => l_lcc_rec.lcc_attribute25,
            p_information136     => l_lcc_rec.lcc_attribute26,
            p_information137     => l_lcc_rec.lcc_attribute27,
            p_information138     => l_lcc_rec.lcc_attribute28,
            p_information139     => l_lcc_rec.lcc_attribute29,
            p_information113     => l_lcc_rec.lcc_attribute3,
            p_information140     => l_lcc_rec.lcc_attribute30,
            p_information114     => l_lcc_rec.lcc_attribute4,
            p_information115     => l_lcc_rec.lcc_attribute5,
            p_information116     => l_lcc_rec.lcc_attribute6,
            p_information117     => l_lcc_rec.lcc_attribute7,
            p_information118     => l_lcc_rec.lcc_attribute8,
            p_information119     => l_lcc_rec.lcc_attribute9,
            p_information110     => l_lcc_rec.lcc_attribute_category,
            p_information260     => l_lcc_rec.ler_chg_dpnt_cvg_id,
            p_information14     => l_lcc_rec.rlshp_typ_cd,
            p_information11     => l_lcc_rec.rqd_flag,
            p_information265    => l_lcc_rec.object_version_number,
            --
             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
      --

            if l_out_lcc_result_id is null then
              l_out_lcc_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_lcc_result_id := l_copy_entity_result_id ;
            end if;

      -- Copy Fast Formulas if any are attached to any column --
      ---------------------------------------------------------------
      -- CTFN_RQD_WHEN_RL  -----------------
      ---------------------------------------------------------------

         if to_char(l_lcc_rec.ctfn_rqd_when_rl) is not null then
             --
             ben_plan_design_program_module.create_formula_result
             (
              p_validate                       =>  0
             ,p_copy_entity_result_id          =>  l_copy_entity_result_id
             ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
             ,p_formula_id                     =>  l_lcc_rec.ctfn_rqd_when_rl
             ,p_business_group_id              =>  l_lcc_rec.business_group_id
             ,p_number_of_copies               =>  l_number_of_copies
             ,p_object_version_number          =>  l_object_version_number
             ,p_effective_date                 =>  p_effective_date
             );

             --
         end if;
      end loop;
    --
    end loop;
   ---------------------------------------------------------------
   -- END OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
   ---------------------------------------------------------------
   end loop;
  ---------------------------------------------------------------
  -- END OF BEN_LER_CHG_DPNT_CVG_F ----------------------
  ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_PGM_ENRT_F ----------------------
   ---------------------------------------------------------------
   --
   for l_parent_rec  in c_lge_from_parent(l_PGM_ID) loop
   --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    l_ler_chg_pgm_enrt_id := l_parent_rec.ler_chg_pgm_enrt_id ;
    --
    for l_lge_rec in c_lge(l_parent_rec.ler_chg_pgm_enrt_id,l_mirror_src_entity_result_id,'LGE' ) loop
    --
    --
      l_table_route_id := null ;
      open g_table_route('LGE');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := get_ler_name(l_lge_rec.ler_id,p_effective_date); --'Intersection';
      --

      if p_effective_date between l_lge_rec.effective_start_date
      and l_lge_rec.effective_end_date then
       --
        l_result_type_cd := 'DISPLAY';
      else
        l_result_type_cd := 'NO DISPLAY';
      end if;
      --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                   => 'LGE',
        p_information1     => l_lge_rec.ler_chg_pgm_enrt_id,
        p_information2     => l_lge_rec.EFFECTIVE_START_DATE,
        p_information3     => l_lge_rec.EFFECTIVE_END_DATE,
        p_information4     => l_lge_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information262     => l_lge_rec.auto_enrt_mthd_rl,
            p_information11     => l_lge_rec.crnt_enrt_prclds_chg_flag,
            p_information13     => l_lge_rec.dflt_enrt_cd,
            p_information263     => l_lge_rec.dflt_enrt_rl,
            p_information14     => l_lge_rec.enrt_cd,
            p_information15     => l_lge_rec.enrt_mthd_cd,
            p_information264     => l_lge_rec.enrt_rl,
            p_information257     => l_lge_rec.ler_id,

            p_information111     => l_lge_rec.lge_attribute1,
            p_information120     => l_lge_rec.lge_attribute10,
            p_information121     => l_lge_rec.lge_attribute11,
            p_information122     => l_lge_rec.lge_attribute12,
            p_information123     => l_lge_rec.lge_attribute13,
            p_information124     => l_lge_rec.lge_attribute14,
            p_information125     => l_lge_rec.lge_attribute15,
            p_information126     => l_lge_rec.lge_attribute16,
            p_information127     => l_lge_rec.lge_attribute17,
            p_information128     => l_lge_rec.lge_attribute18,
            p_information129     => l_lge_rec.lge_attribute19,
            p_information112     => l_lge_rec.lge_attribute2,
            p_information130     => l_lge_rec.lge_attribute20,
            p_information131     => l_lge_rec.lge_attribute21,
            p_information132     => l_lge_rec.lge_attribute22,
            p_information133     => l_lge_rec.lge_attribute23,
            p_information134     => l_lge_rec.lge_attribute24,
            p_information135     => l_lge_rec.lge_attribute25,
            p_information136     => l_lge_rec.lge_attribute26,
            p_information137     => l_lge_rec.lge_attribute27,
            p_information138     => l_lge_rec.lge_attribute28,
            p_information139     => l_lge_rec.lge_attribute29,
            p_information113     => l_lge_rec.lge_attribute3,
            p_information140     => l_lge_rec.lge_attribute30,
            p_information114     => l_lge_rec.lge_attribute4,
            p_information115     => l_lge_rec.lge_attribute5,
            p_information116     => l_lge_rec.lge_attribute6,
            p_information117     => l_lge_rec.lge_attribute7,
            p_information118     => l_lge_rec.lge_attribute8,
            p_information119     => l_lge_rec.lge_attribute9,
            p_information110     => l_lge_rec.lge_attribute_category,

            p_information260     => l_lge_rec.pgm_id,
            p_information12     => l_lge_rec.stl_elig_cant_chg_flag,
            p_information265    => l_lge_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_lge_result_id is null then
          l_out_lge_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
          l_out_lge_result_id := l_copy_entity_result_id ;
        end if;
        --

        -- Copy Fast Formulas if any are attached to any column --
        ---------------------------------------------------------------
        -- AUTO_ENRT_MTHD_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_lge_rec.auto_enrt_mthd_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lge_rec.auto_enrt_mthd_rl
                ,p_business_group_id              =>  l_lge_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;
        ---------------------------------------------------------------
        -- DFLT_ENRT_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_lge_rec.dflt_enrt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lge_rec.dflt_enrt_rl
                ,p_business_group_id              =>  l_lge_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_lge_rec.enrt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lge_rec.enrt_rl
                ,p_business_group_id              =>  l_lge_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

    end loop;
    --
    for l_lge_rec in c_lge_drp(l_parent_rec.ler_chg_pgm_enrt_id,l_mirror_src_entity_result_id,'LGE' ) loop
          ben_plan_design_plan_module.create_ler_result (
             p_validate                       => p_validate
            ,p_copy_entity_result_id          => l_out_lge_result_id
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_ler_id                         => l_lge_rec.ler_id
            ,p_business_group_id              => p_business_group_id
            ,p_number_of_copies               => p_number_of_copies
            ,p_object_version_number          => l_object_version_number
            ,p_effective_date                 => p_effective_date
            );
   end loop;
   --
   end loop;
  ---------------------------------------------------------------
  -- END OF BEN_LER_CHG_PGM_ENRT_F ----------------------
  ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   --
   for l_parent_rec  in c_peo_from_parent(l_PGM_ID) loop
   --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    l_elig_to_prte_rsn_id := l_parent_rec.elig_to_prte_rsn_id ;
    --
    for l_peo_rec in c_peo(l_parent_rec.elig_to_prte_rsn_id,l_mirror_src_entity_result_id,'PEO' ) loop
    --
    --
      l_table_route_id := null ;
      open g_table_route('PEO');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := get_ler_name(l_peo_rec.ler_id,p_effective_date); --'Intersection';
      --

      if p_effective_date between l_peo_rec.effective_start_date
      and l_peo_rec.effective_end_date then
      --
        l_result_type_cd := 'DISPLAY';
      else
        l_result_type_cd := 'NO DISPLAY';
      end if;
      --
     l_copy_entity_result_id := null;
     l_object_version_number := null;
     ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                 => 'PEO',
        p_information1     => l_peo_rec.elig_to_prte_rsn_id,
        p_information2     => l_peo_rec.EFFECTIVE_START_DATE,
        p_information3     => l_peo_rec.EFFECTIVE_END_DATE,
        p_information4     => l_peo_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information21     => l_peo_rec.elig_inelig_cd,
            p_information20     => l_peo_rec.ignr_prtn_ovrid_flag,
            p_information257     => l_peo_rec.ler_id,
            p_information17     => l_peo_rec.mx_poe_apls_cd,
            p_information16     => l_peo_rec.mx_poe_det_dt_cd,
            p_information272     => l_peo_rec.mx_poe_det_dt_rl,
            p_information270     => l_peo_rec.mx_poe_rl,
            p_information15     => l_peo_rec.mx_poe_uom,
            p_information269     => l_peo_rec.mx_poe_val,
            p_information258     => l_peo_rec.oipl_id,
            p_information111     => l_peo_rec.peo_attribute1,
            p_information120     => l_peo_rec.peo_attribute10,
            p_information121     => l_peo_rec.peo_attribute11,
            p_information122     => l_peo_rec.peo_attribute12,
            p_information123     => l_peo_rec.peo_attribute13,
            p_information124     => l_peo_rec.peo_attribute14,
            p_information125     => l_peo_rec.peo_attribute15,
            p_information126     => l_peo_rec.peo_attribute16,
            p_information127     => l_peo_rec.peo_attribute17,
            p_information128     => l_peo_rec.peo_attribute18,
            p_information129     => l_peo_rec.peo_attribute19,
            p_information112     => l_peo_rec.peo_attribute2,
            p_information130     => l_peo_rec.peo_attribute20,
            p_information131     => l_peo_rec.peo_attribute21,
            p_information132     => l_peo_rec.peo_attribute22,
            p_information133     => l_peo_rec.peo_attribute23,
            p_information134     => l_peo_rec.peo_attribute24,
            p_information135     => l_peo_rec.peo_attribute25,
            p_information136     => l_peo_rec.peo_attribute26,
            p_information137     => l_peo_rec.peo_attribute27,
            p_information138     => l_peo_rec.peo_attribute28,
            p_information139     => l_peo_rec.peo_attribute29,
            p_information113     => l_peo_rec.peo_attribute3,
            p_information140     => l_peo_rec.peo_attribute30,
            p_information114     => l_peo_rec.peo_attribute4,
            p_information115     => l_peo_rec.peo_attribute5,
            p_information116     => l_peo_rec.peo_attribute6,
            p_information117     => l_peo_rec.peo_attribute7,
            p_information118     => l_peo_rec.peo_attribute8,
            p_information119     => l_peo_rec.peo_attribute9,
            p_information110     => l_peo_rec.peo_attribute_category,
            p_information260     => l_peo_rec.pgm_id,
            p_information261     => l_peo_rec.pl_id,
            p_information256     => l_peo_rec.plip_id,
            p_information12     => l_peo_rec.prtn_eff_end_dt_cd,
            p_information266     => l_peo_rec.prtn_eff_end_dt_rl,
            p_information11     => l_peo_rec.prtn_eff_strt_dt_cd,
            p_information264     => l_peo_rec.prtn_eff_strt_dt_rl,
            p_information19     => l_peo_rec.prtn_ovridbl_flag,
            p_information259     => l_peo_rec.ptip_id,
            p_information18     => l_peo_rec.vrfy_fmly_mmbr_cd,
            p_information273     => l_peo_rec.vrfy_fmly_mmbr_rl,
            p_information14     => l_peo_rec.wait_perd_dt_to_use_cd,
            p_information268     => l_peo_rec.wait_perd_dt_to_use_rl,
            p_information271     => l_peo_rec.wait_perd_rl,
            p_information13     => l_peo_rec.wait_perd_uom,
            p_information267     => l_peo_rec.wait_perd_val,
            p_information265     => l_peo_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
 --

        if l_out_peo_result_id is null then
          l_out_peo_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
          l_out_peo_result_id := l_copy_entity_result_id ;
        end if;

 -- Copy Fast Formulas if any are attached to any column --
 ---------------------------------------------------------------
 -- MX_POE_DET_DT_RL  -----------------
 ---------------------------------------------------------------

 if to_char(l_peo_rec.mx_poe_det_dt_rl) is not null then
         --
         ben_plan_design_program_module.create_formula_result
         (
          p_validate                       =>  0
         ,p_copy_entity_result_id          =>  l_copy_entity_result_id
         ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
         ,p_formula_id                     =>  l_peo_rec.mx_poe_det_dt_rl
         ,p_business_group_id              =>  l_peo_rec.business_group_id
         ,p_number_of_copies               =>  l_number_of_copies
         ,p_object_version_number          =>  l_object_version_number
         ,p_effective_date                 =>  p_effective_date
         );

         --
 end if;

  ---------------------------------------------------------------
  -- MX_POE_RL  -----------------
  ---------------------------------------------------------------

  if to_char(l_peo_rec.mx_poe_rl) is not null then
          --
          ben_plan_design_program_module.create_formula_result
          (
           p_validate                       =>  0
          ,p_copy_entity_result_id          =>  l_copy_entity_result_id
          ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
          ,p_formula_id                     =>  l_peo_rec.mx_poe_rl
          ,p_business_group_id              =>  l_peo_rec.business_group_id
          ,p_number_of_copies               =>  l_number_of_copies
          ,p_object_version_number          =>  l_object_version_number
          ,p_effective_date                 =>  p_effective_date
          );

          --
 end if;

 ---------------------------------------------------------------
 -- PRTN_EFF_END_DT_RL  -----------------
 ---------------------------------------------------------------

   if to_char(l_peo_rec.prtn_eff_end_dt_rl) is not null then
           --
           ben_plan_design_program_module.create_formula_result
           (
            p_validate                       =>  0
           ,p_copy_entity_result_id          =>  l_copy_entity_result_id
           ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
           ,p_formula_id                     =>  l_peo_rec.prtn_eff_end_dt_rl
           ,p_business_group_id              =>  l_peo_rec.business_group_id
           ,p_number_of_copies               =>  l_number_of_copies
           ,p_object_version_number          =>  l_object_version_number
           ,p_effective_date                 =>  p_effective_date
           );

           --
  end if;

  ---------------------------------------------------------------
  -- PRTN_EFF_STRT_DT_RL  -----------------
  ---------------------------------------------------------------

   if to_char(l_peo_rec.prtn_eff_strt_dt_rl) is not null then
            --
            ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0
            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
            ,p_formula_id                     =>  l_peo_rec.prtn_eff_strt_dt_rl
            ,p_business_group_id              =>  l_peo_rec.business_group_id
            ,p_number_of_copies               =>  l_number_of_copies
            ,p_object_version_number          =>  l_object_version_number
            ,p_effective_date                 =>  p_effective_date
            );

            --
   end if;

  ---------------------------------------------------------------
  -- VRFY_FMLY_MMBR_RL -----------------
  ---------------------------------------------------------------

   if to_char(l_peo_rec.vrfy_fmly_mmbr_rl) is not null then
            --
            ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0
            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
            ,p_formula_id                     =>  l_peo_rec.vrfy_fmly_mmbr_rl
            ,p_business_group_id              =>  l_peo_rec.business_group_id
            ,p_number_of_copies               =>  l_number_of_copies
            ,p_object_version_number          =>  l_object_version_number
            ,p_effective_date                 =>  p_effective_date
            );

            --
   end if;

  ---------------------------------------------------------------
  -- WAIT_PERD_DT_TO_USE_RL -----------------
  ---------------------------------------------------------------

   if to_char(l_peo_rec.wait_perd_dt_to_use_rl) is not null then
            --
            ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0
            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
            ,p_formula_id                     =>  l_peo_rec.wait_perd_dt_to_use_rl
            ,p_business_group_id              =>  l_peo_rec.business_group_id
            ,p_number_of_copies               =>  l_number_of_copies
            ,p_object_version_number          =>  l_object_version_number
            ,p_effective_date                 =>  p_effective_date
            );

            --
   end if;

   ---------------------------------------------------------------
   -- WAIT_PERD_RL -----------------
   ---------------------------------------------------------------

     if to_char(l_peo_rec.wait_perd_rl) is not null then
             --
             ben_plan_design_program_module.create_formula_result
             (
              p_validate                       =>  0
             ,p_copy_entity_result_id          =>  l_copy_entity_result_id
             ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
             ,p_formula_id                     =>  l_peo_rec.wait_perd_rl
             ,p_business_group_id              =>  l_peo_rec.business_group_id
             ,p_number_of_copies               =>  l_number_of_copies
             ,p_object_version_number          =>  l_object_version_number
             ,p_effective_date                 =>  p_effective_date
             );
            --
     end if;
            ben_plan_design_plan_module.create_ler_result (
               p_validate                       => p_validate
              ,p_copy_entity_result_id          => l_copy_entity_result_id
              ,p_copy_entity_txn_id             => p_copy_entity_txn_id
              ,p_ler_id                         => l_peo_rec.ler_id
              ,p_business_group_id              => p_business_group_id
              ,p_number_of_copies               => l_number_of_copies
              ,p_object_version_number          => l_object_version_number
              ,p_effective_date                 => p_effective_date
              );
            --
     end loop;
     --

   end loop;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PGM_DPNT_CVG_CTFN_F ----------------------
   ---------------------------------------------------------------
   --
   for l_parent_rec  in c_pgc_from_parent(l_PGM_ID) loop
   --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    l_pgm_dpnt_cvg_ctfn_id := l_parent_rec.pgm_dpnt_cvg_ctfn_id ;
    --
    for l_pgc_rec in c_pgc(l_parent_rec.pgm_dpnt_cvg_ctfn_id,l_mirror_src_entity_result_id,'PGC' ) loop
    --
    --
      l_table_route_id := null ;
      open g_table_route('PGC');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := hr_general.decode_lookup('BEN_DPNT_CVG_CTFN_TYP',l_pgc_rec.dpnt_cvg_ctfn_typ_cd); --'Intersection';
      --

      if p_effective_date between l_pgc_rec.effective_start_date
      and l_pgc_rec.effective_end_date then
      --
        l_result_type_cd := 'DISPLAY';
      else
        l_result_type_cd := 'NO DISPLAY';
      end if;
      --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                 => 'PGC',
        p_information1     => l_pgc_rec.pgm_dpnt_cvg_ctfn_id,
        p_information2     => l_pgc_rec.EFFECTIVE_START_DATE,
        p_information3     => l_pgc_rec.EFFECTIVE_END_DATE,
        p_information4     => l_pgc_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information261     => l_pgc_rec.ctfn_rqd_when_rl,
            p_information13     => l_pgc_rec.dpnt_cvg_ctfn_typ_cd,
            p_information11     => l_pgc_rec.lack_ctfn_sspnd_enrt_flag,
            p_information12     => l_pgc_rec.pfd_flag,
            p_information111     => l_pgc_rec.pgc_attribute1,
            p_information120     => l_pgc_rec.pgc_attribute10,
            p_information121     => l_pgc_rec.pgc_attribute11,
            p_information122     => l_pgc_rec.pgc_attribute12,
            p_information123     => l_pgc_rec.pgc_attribute13,
            p_information124     => l_pgc_rec.pgc_attribute14,
            p_information125     => l_pgc_rec.pgc_attribute15,
            p_information126     => l_pgc_rec.pgc_attribute16,
            p_information127     => l_pgc_rec.pgc_attribute17,
            p_information128     => l_pgc_rec.pgc_attribute18,
            p_information129     => l_pgc_rec.pgc_attribute19,
            p_information112     => l_pgc_rec.pgc_attribute2,
            p_information130     => l_pgc_rec.pgc_attribute20,
            p_information131     => l_pgc_rec.pgc_attribute21,
            p_information132     => l_pgc_rec.pgc_attribute22,
            p_information133     => l_pgc_rec.pgc_attribute23,
            p_information134     => l_pgc_rec.pgc_attribute24,
            p_information135     => l_pgc_rec.pgc_attribute25,
            p_information136     => l_pgc_rec.pgc_attribute26,
            p_information137     => l_pgc_rec.pgc_attribute27,
            p_information138     => l_pgc_rec.pgc_attribute28,
            p_information139     => l_pgc_rec.pgc_attribute29,
            p_information113     => l_pgc_rec.pgc_attribute3,
            p_information140     => l_pgc_rec.pgc_attribute30,
            p_information114     => l_pgc_rec.pgc_attribute4,
            p_information115     => l_pgc_rec.pgc_attribute5,
            p_information116     => l_pgc_rec.pgc_attribute6,
            p_information117     => l_pgc_rec.pgc_attribute7,
            p_information118     => l_pgc_rec.pgc_attribute8,
            p_information119     => l_pgc_rec.pgc_attribute9,
            p_information110     => l_pgc_rec.pgc_attribute_category,
            p_information260     => l_pgc_rec.pgm_id,
            p_information15     => l_pgc_rec.rlshp_typ_cd,
            p_information14     => l_pgc_rec.rqd_flag,
            p_information265    => l_pgc_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
     --

        if l_out_pgc_result_id is null then
          l_out_pgc_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
          l_out_pgc_result_id := l_copy_entity_result_id ;
        end if;

     -- Copy Fast Formulas if any are attached to any column --
     ---------------------------------------------------------------
     -- CTFN_RQD_WHEN_RL -----------------
     ---------------------------------------------------------------

       if to_char(l_pgc_rec.ctfn_rqd_when_rl) is not null then
             --
             ben_plan_design_program_module.create_formula_result
             (
              p_validate                       =>  0
             ,p_copy_entity_result_id          =>  l_copy_entity_result_id
             ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
             ,p_formula_id                     =>  l_pgc_rec.ctfn_rqd_when_rl
             ,p_business_group_id              =>  l_pgc_rec.business_group_id
             ,p_number_of_copies               =>  l_number_of_copies
             ,p_object_version_number          =>  l_object_version_number
             ,p_effective_date                 =>  p_effective_date
             );

             --
       end if;

     end loop;
   --
   end loop;
  ---------------------------------------------------------------
  -- END OF BEN_PGM_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PTIP_F ----------------------
   ---------------------------------------------------------------
   --
   for l_parent_rec  in c_ctp_from_parent(l_PGM_ID) loop
   --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    l_ptip_id := l_parent_rec.ptip_id ;
    --
    for l_ctp_rec in c_ctp(l_parent_rec.ptip_id,l_mirror_src_entity_result_id,'CTP' ) loop
    --
    --
      l_table_route_id := null ;
      open g_table_route('CTP');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := get_pl_typ_name(l_ctp_rec.pl_typ_id,p_effective_date); --'Intersection';
      --

      if p_effective_date between l_ctp_rec.effective_start_date
      and l_ctp_rec.effective_end_date then
      --
        l_result_type_cd := 'DISPLAY';
      else
        l_result_type_cd := 'NO DISPLAY';
      end if;
      --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                 => 'CTP',
        p_information1     => l_ctp_rec.ptip_id,
        p_information2     => l_ctp_rec.EFFECTIVE_START_DATE,
        p_information3     => l_ctp_rec.EFFECTIVE_END_DATE,
        p_information4     => l_ctp_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information274     => l_ctp_rec.acrs_ptip_cvg_id,
            p_information275     => l_ctp_rec.auto_enrt_mthd_rl,
            p_information236     => l_ctp_rec.cmbn_ptip_id,
            p_information249     => l_ctp_rec.cmbn_ptip_opt_id,
            p_information15     => l_ctp_rec.coord_cvg_for_all_pls_flag,
            p_information20     => l_ctp_rec.crs_this_pl_typ_only_flag,
            p_information111     => l_ctp_rec.ctp_attribute1,
            p_information120     => l_ctp_rec.ctp_attribute10,
            p_information121     => l_ctp_rec.ctp_attribute11,
            p_information122     => l_ctp_rec.ctp_attribute12,
            p_information123     => l_ctp_rec.ctp_attribute13,
            p_information124     => l_ctp_rec.ctp_attribute14,
            p_information125     => l_ctp_rec.ctp_attribute15,
            p_information126     => l_ctp_rec.ctp_attribute16,
            p_information127     => l_ctp_rec.ctp_attribute17,
            p_information128     => l_ctp_rec.ctp_attribute18,
            p_information129     => l_ctp_rec.ctp_attribute19,
            p_information112     => l_ctp_rec.ctp_attribute2,
            p_information130     => l_ctp_rec.ctp_attribute20,
            p_information131     => l_ctp_rec.ctp_attribute21,
            p_information132     => l_ctp_rec.ctp_attribute22,
            p_information133     => l_ctp_rec.ctp_attribute23,
            p_information134     => l_ctp_rec.ctp_attribute24,
            p_information135     => l_ctp_rec.ctp_attribute25,
            p_information136     => l_ctp_rec.ctp_attribute26,
            p_information137     => l_ctp_rec.ctp_attribute27,
            p_information138     => l_ctp_rec.ctp_attribute28,
            p_information139     => l_ctp_rec.ctp_attribute29,
            p_information113     => l_ctp_rec.ctp_attribute3,
            p_information140     => l_ctp_rec.ctp_attribute30,
            p_information114     => l_ctp_rec.ctp_attribute4,
            p_information115     => l_ctp_rec.ctp_attribute5,
            p_information116     => l_ctp_rec.ctp_attribute6,
            p_information117     => l_ctp_rec.ctp_attribute7,
            p_information118     => l_ctp_rec.ctp_attribute8,
            p_information119     => l_ctp_rec.ctp_attribute9,
            p_information110     => l_ctp_rec.ctp_attribute_category,
            p_information45     => l_ctp_rec.dflt_enrt_cd,
            p_information277     => l_ctp_rec.dflt_enrt_det_rl,
            p_information17     => l_ctp_rec.dpnt_adrs_rqd_flag,
            p_information36     => l_ctp_rec.dpnt_cvg_end_dt_cd,
            p_information263     => l_ctp_rec.dpnt_cvg_end_dt_rl,
            p_information16     => l_ctp_rec.dpnt_cvg_no_ctfn_rqd_flag,
            p_information35     => l_ctp_rec.dpnt_cvg_strt_dt_cd,
            p_information262     => l_ctp_rec.dpnt_cvg_strt_dt_rl,
            p_information19     => l_ctp_rec.dpnt_dob_rqd_flag,
            p_information34     => l_ctp_rec.dpnt_dsgn_cd,
            p_information18     => l_ctp_rec.dpnt_legv_id_rqd_flag,
            p_information29     => l_ctp_rec.drvbl_fctr_apls_rts_flag,
            p_information30     => l_ctp_rec.drvbl_fctr_prtn_elig_flag,
            p_information24     => l_ctp_rec.drvd_fctr_dpnt_cvg_flag,
            p_information31     => l_ctp_rec.elig_apls_flag,
            p_information44     => l_ctp_rec.enrt_cd,
            p_information40     => l_ctp_rec.enrt_cvg_end_dt_cd,
            p_information271     => l_ctp_rec.enrt_cvg_end_dt_rl,
            p_information39     => l_ctp_rec.enrt_cvg_strt_dt_cd,
            p_information270     => l_ctp_rec.enrt_cvg_strt_dt_rl,
            p_information43     => l_ctp_rec.enrt_mthd_cd,
            p_information276     => l_ctp_rec.enrt_rl,
            p_information141     => l_ctp_rec.ivr_ident,
            p_information266     => l_ctp_rec.mn_enrd_rqd_ovrid_num,
            p_information293     => l_ctp_rec.mx_cvg_alwd_amt,
            p_information267     => l_ctp_rec.mx_enrd_alwd_ovrid_num,
            p_information25     => l_ctp_rec.no_mn_pl_typ_overid_flag,
            p_information21     => l_ctp_rec.no_mx_pl_typ_ovrid_flag,
            p_information268     => l_ctp_rec.ordr_num,
            p_information11     => l_ctp_rec.per_cvrd_cd,
            p_information260     => l_ctp_rec.pgm_id,
            p_information248     => l_ctp_rec.pl_typ_id,
            p_information264     => l_ctp_rec.postelcn_edit_rl,
            p_information32     => l_ctp_rec.prtn_elig_ovrid_alwd_flag,
            p_information22     => l_ctp_rec.prvds_cr_flag,
            p_information14     => l_ctp_rec.ptip_stat_cd,
            p_information38     => l_ctp_rec.rqd_enrt_perd_tco_cd,
            p_information269     => l_ctp_rec.rqd_perd_enrt_nenrt_rl,
            p_information37     => l_ctp_rec.rqd_perd_enrt_nenrt_tm_uom,
            p_information287     => l_ctp_rec.rqd_perd_enrt_nenrt_val,
            p_information42     => l_ctp_rec.rt_end_dt_cd,
            p_information273     => l_ctp_rec.rt_end_dt_rl,
            p_information41     => l_ctp_rec.rt_strt_dt_cd,
            p_information272     => l_ctp_rec.rt_strt_dt_rl,
            p_information27     => l_ctp_rec.sbj_to_dpnt_lf_ins_mx_flag,
            p_information26     => l_ctp_rec.sbj_to_sps_lf_ins_mx_flag,
            p_information12     => l_ctp_rec.short_code,
            p_information13     => l_ctp_rec.short_name,
            p_information33     => l_ctp_rec.trk_inelig_per_flag,
            p_information185     => l_ctp_rec.url_ref_name,
            p_information28     => l_ctp_rec.use_to_sum_ee_lf_ins_flag,
            p_information46     => l_ctp_rec.vrfy_fmly_mmbr_cd,
            p_information278     => l_ctp_rec.vrfy_fmly_mmbr_rl,
            p_information23     => l_ctp_rec.wvbl_flag,
            p_INFORMATION196    => l_ctp_rec.SUSP_IF_DPNT_SSN_NT_PRV_CD,
            p_INFORMATION190    => l_ctp_rec.SUSP_IF_DPNT_DOB_NT_PRV_CD,
            p_INFORMATION191    => l_ctp_rec.SUSP_IF_DPNT_ADR_NT_PRV_CD,
            p_INFORMATION192    => l_ctp_rec.SUSP_IF_CTFN_NOT_DPNT_FLAG,
            p_INFORMATION193    => l_ctp_rec.DPNT_CTFN_DETERMINE_CD,
            p_information265    => l_ctp_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );


        if l_out_ctp_result_id is null then
          l_out_ctp_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_ctp_result_id := l_copy_entity_result_id ;
        end if;
        -- Copy Fast Formulas if any are attached to any column --
        ---------------------------------------------------------------
        -- AUTO_ENRT_MTHD_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.auto_enrt_mthd_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ctp_rec.auto_enrt_mthd_rl
                ,p_business_group_id              =>  l_ctp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- DFLT_ENRT_DET_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.dflt_enrt_det_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ctp_rec.dflt_enrt_det_rl
                ,p_business_group_id              =>  l_ctp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- DPNT_CVG_END_DT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.dpnt_cvg_end_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ctp_rec.dpnt_cvg_end_dt_rl
                ,p_business_group_id              =>  l_ctp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- DPNT_CVG_STRT_DT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.dpnt_cvg_strt_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ctp_rec.dpnt_cvg_strt_dt_rl
                ,p_business_group_id              =>  l_ctp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_CVG_END_DT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.enrt_cvg_end_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ctp_rec.enrt_cvg_end_dt_rl
                ,p_business_group_id              =>  l_ctp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_CVG_STRT_DT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.enrt_cvg_strt_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ctp_rec.enrt_cvg_strt_dt_rl
                ,p_business_group_id              =>  l_ctp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.enrt_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_ctp_rec.enrt_rl
                 ,p_business_group_id              =>  l_ctp_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
        end if;

        ---------------------------------------------------------------
        -- POSTELCN_EDIT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.postelcn_edit_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_ctp_rec.postelcn_edit_rl
                 ,p_business_group_id              =>  l_ctp_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
        end if;

        ---------------------------------------------------------------
        -- RQD_PERD_ENRT_NENRT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.rqd_perd_enrt_nenrt_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_ctp_rec.rqd_perd_enrt_nenrt_rl
                 ,p_business_group_id              =>  l_ctp_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
        end if;
        ---------------------------------------------------------------
        -- RT_END_DT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.rt_end_dt_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_ctp_rec.rt_end_dt_rl
                 ,p_business_group_id              =>  l_ctp_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
        end if;

        ---------------------------------------------------------------
        -- RT_STRT_DT_RL  -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.rt_strt_dt_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_ctp_rec.rt_strt_dt_rl
                 ,p_business_group_id              =>  l_ctp_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
        end if;

        ---------------------------------------------------------------
        -- VRFY_FMLY_MMBR_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_ctp_rec.vrfy_fmly_mmbr_rl) is not null then
                 --
                 ben_plan_design_program_module.create_formula_result
                 (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_ctp_rec.vrfy_fmly_mmbr_rl
                 ,p_business_group_id              =>  l_ctp_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
                 );

                 --
        end if;
     end loop;
         -- ------------------------------------------------------------------------
         -- Eligibility Profiles
         -- ------------------------------------------------------------------------
         ben_plan_design_elpro_module.create_elpro_results
            (
              p_validate                     => p_validate
             ,p_copy_entity_result_id        => l_out_ctp_result_id
             ,p_copy_entity_txn_id           => p_copy_entity_txn_id
             ,p_pgm_id                       => null
             ,p_ptip_id                      => l_ptip_id
             ,p_plip_id                      => null
             ,p_pl_id                        => null
             ,p_oipl_id                      => null
             ,p_business_group_id            => p_business_group_id
             ,p_number_of_copies             => p_number_of_copies
             ,p_object_version_number        => l_object_version_number
             ,p_effective_date               => p_effective_date
             ,p_parent_entity_result_id      => l_out_ctp_result_id
            );
          -- ------------------------------------------------------------------------
          -- Dependent Eligibility Profiles
          -- ------------------------------------------------------------------------

          ben_plan_design_elpro_module.create_dep_elpro_result
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_ctp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => l_ptip_id
             ,p_pl_id                      => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_ctp_result_id
            );
            -- ------------------------------------------------------------------------
            -- Standard Rates ,Flex Credits at Ptip level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_ctp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => l_ptip_id
             ,p_plip_id                    => null
             ,p_pl_id                      => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_ctp_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools  Ptip Level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_out_ctp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => l_ptip_id
             ,p_plip_id                    => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_ctp_result_id
             ) ;

      ---------------------------------------------------------------
      -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
      ---------------------------------------------------------------
      --
      ---------------------------------------------------------------
      -- START OF BEN_PL_TYP_F ----------------------
      ---------------------------------------------------------------
      --
      for l_parent_rec  in c_ptp_from_parent(l_PTIP_ID) loop
        ben_plan_design_plan_module.create_pl_typ_result
        (p_validate                       => p_validate
        ,p_copy_entity_result_id          => l_out_ctp_result_id
        ,p_copy_entity_txn_id             => p_copy_entity_txn_id
        ,p_pl_typ_id                      => l_parent_rec.pl_typ_id
        ,p_business_group_id              => p_business_group_id
        ,p_number_of_copies               => p_number_of_copies
        ,p_object_version_number          => l_object_version_number
        ,p_effective_date                 => p_effective_date
        ,p_parent_entity_result_id        => NULL -- Hide PTP for HGrid
        );
      end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PL_TYP_F ----------------------
     ---------------------------------------------------------------
      for l_parent_rec  in c_peo1_from_parent(l_PTIP_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_ctp_result_id ;
         --
         l_elig_to_prte_rsn_id1 := l_parent_rec.elig_to_prte_rsn_id ;
         --
         for l_peo_rec in c_peo1(l_parent_rec.elig_to_prte_rsn_id,l_mirror_src_entity_result_id,'PEO') loop
           --
           l_table_route_id := null ;
           open g_table_route('PEO');
             fetch g_table_route into l_table_route_id ;
           close g_table_route ;
           --
           l_information5  := get_ler_name(l_peo_rec.ler_id,p_effective_date); --'Intersection';
           --
           if p_effective_date between l_peo_rec.effective_start_date
              and l_peo_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           l_copy_entity_result_id := null;
           l_object_version_number := null;
           ben_copy_entity_results_api.create_copy_entity_results(
             p_copy_entity_result_id           => l_copy_entity_result_id,
             p_copy_entity_txn_id             => p_copy_entity_txn_id,
             p_result_type_cd                 => l_result_type_cd,
             p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
             p_parent_entity_result_id        => l_mirror_src_entity_result_id,
             p_number_of_copies               => l_number_of_copies,
             p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'PEO',
             p_information1     => l_peo_rec.elig_to_prte_rsn_id,
             p_information2     => l_peo_rec.EFFECTIVE_START_DATE,
             p_information3     => l_peo_rec.EFFECTIVE_END_DATE,
             p_information4     => l_peo_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information21     => l_peo_rec.elig_inelig_cd,
            p_information20     => l_peo_rec.ignr_prtn_ovrid_flag,
            p_information257     => l_peo_rec.ler_id,
            p_information17     => l_peo_rec.mx_poe_apls_cd,
            p_information16     => l_peo_rec.mx_poe_det_dt_cd,
            p_information272     => l_peo_rec.mx_poe_det_dt_rl,
            p_information270     => l_peo_rec.mx_poe_rl,
            p_information15     => l_peo_rec.mx_poe_uom,
            p_information269     => l_peo_rec.mx_poe_val,
            p_information258     => l_peo_rec.oipl_id,
            p_information111     => l_peo_rec.peo_attribute1,
            p_information120     => l_peo_rec.peo_attribute10,
            p_information121     => l_peo_rec.peo_attribute11,
            p_information122     => l_peo_rec.peo_attribute12,
            p_information123     => l_peo_rec.peo_attribute13,
            p_information124     => l_peo_rec.peo_attribute14,
            p_information125     => l_peo_rec.peo_attribute15,
            p_information126     => l_peo_rec.peo_attribute16,
            p_information127     => l_peo_rec.peo_attribute17,
            p_information128     => l_peo_rec.peo_attribute18,
            p_information129     => l_peo_rec.peo_attribute19,
            p_information112     => l_peo_rec.peo_attribute2,
            p_information130     => l_peo_rec.peo_attribute20,
            p_information131     => l_peo_rec.peo_attribute21,
            p_information132     => l_peo_rec.peo_attribute22,
            p_information133     => l_peo_rec.peo_attribute23,
            p_information134     => l_peo_rec.peo_attribute24,
            p_information135     => l_peo_rec.peo_attribute25,
            p_information136     => l_peo_rec.peo_attribute26,
            p_information137     => l_peo_rec.peo_attribute27,
            p_information138     => l_peo_rec.peo_attribute28,
            p_information139     => l_peo_rec.peo_attribute29,
            p_information113     => l_peo_rec.peo_attribute3,
            p_information140     => l_peo_rec.peo_attribute30,
            p_information114     => l_peo_rec.peo_attribute4,
            p_information115     => l_peo_rec.peo_attribute5,
            p_information116     => l_peo_rec.peo_attribute6,
            p_information117     => l_peo_rec.peo_attribute7,
            p_information118     => l_peo_rec.peo_attribute8,
            p_information119     => l_peo_rec.peo_attribute9,
            p_information110     => l_peo_rec.peo_attribute_category,
            p_information260     => l_peo_rec.pgm_id,
            p_information261     => l_peo_rec.pl_id,
            p_information256     => l_peo_rec.plip_id,
            p_information12     => l_peo_rec.prtn_eff_end_dt_cd,
            p_information266     => l_peo_rec.prtn_eff_end_dt_rl,
            p_information11     => l_peo_rec.prtn_eff_strt_dt_cd,
            p_information264     => l_peo_rec.prtn_eff_strt_dt_rl,
            p_information19     => l_peo_rec.prtn_ovridbl_flag,
            p_information259     => l_peo_rec.ptip_id,
            p_information18     => l_peo_rec.vrfy_fmly_mmbr_cd,
            p_information273     => l_peo_rec.vrfy_fmly_mmbr_rl,
            p_information14     => l_peo_rec.wait_perd_dt_to_use_cd,
            p_information268     => l_peo_rec.wait_perd_dt_to_use_rl,
            p_information271     => l_peo_rec.wait_perd_rl,
            p_information13     => l_peo_rec.wait_perd_uom,
            p_information267     => l_peo_rec.wait_perd_val,
            p_information265    => l_peo_rec.object_version_number,
            --
             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

             if l_out_peo1_result_id is null then
               l_out_peo1_result_id := l_copy_entity_result_id;
             end if;

             if l_result_type_cd = 'DISPLAY' then
                l_out_peo1_result_id := l_copy_entity_result_id ;
             end if;
             --

             -- Copy Fast Formulas if any are attached to any column --
             ---------------------------------------------------------------
             -- MX_POE_DET_DT_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_peo_rec.mx_poe_det_dt_rl) is not null then
               --
               ben_plan_design_program_module.create_formula_result
               (
                 p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_peo_rec.mx_poe_det_dt_rl
                 ,p_business_group_id              =>  l_peo_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
               );

               --
             end if;

             ---------------------------------------------------------------
             -- MX_POE_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_peo_rec.mx_poe_rl) is not null then
                  --
                  ben_plan_design_program_module.create_formula_result
                    (
                      p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_peo_rec.mx_poe_rl
                      ,p_business_group_id              =>  l_peo_rec.business_group_id
                      ,p_number_of_copies               =>  l_number_of_copies
                      ,p_object_version_number          =>  l_object_version_number
                      ,p_effective_date                 =>  p_effective_date
                    );
                  --
             end if;

             ---------------------------------------------------------------
             -- PRTN_EFF_END_DT_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_peo_rec.prtn_eff_end_dt_rl) is not null then
                  --
                  ben_plan_design_program_module.create_formula_result
                   (
                        p_validate                       =>  0
                        ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                        ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                        ,p_formula_id                     =>  l_peo_rec.prtn_eff_end_dt_rl
                        ,p_business_group_id              =>  l_peo_rec.business_group_id
                        ,p_number_of_copies               =>  l_number_of_copies
                        ,p_object_version_number          =>  l_object_version_number
                        ,p_effective_date                 =>  p_effective_date
                   );
                  --
             end if;

             ---------------------------------------------------------------
             -- PRTN_EFF_STRT_DT_RL   -----------------
             ---------------------------------------------------------------

             if to_char(l_peo_rec.prtn_eff_strt_dt_rl) is not null then
                  --
                  ben_plan_design_program_module.create_formula_result
                  (
                  p_validate                       =>  0
                  ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                  ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                  ,p_formula_id                     =>  l_peo_rec.prtn_eff_strt_dt_rl
                  ,p_business_group_id              =>  l_peo_rec.business_group_id
                  ,p_number_of_copies               =>  l_number_of_copies
                  ,p_object_version_number          =>  l_object_version_number
                  ,p_effective_date                 =>  p_effective_date
                  );
                  --
              end if;

              ---------------------------------------------------------------
              -- VRFY_FMLY_MMBR_RL  -----------------
              ---------------------------------------------------------------

              if to_char(l_peo_rec.vrfy_fmly_mmbr_rl) is not null then
                   --
                   ben_plan_design_program_module.create_formula_result
                   (
                   p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_peo_rec.vrfy_fmly_mmbr_rl
                   ,p_business_group_id              =>  l_peo_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                   );
                   --
              end if;

              ---------------------------------------------------------------
              -- WAIT_PERD_DT_TO_USE_RL  -----------------
              ---------------------------------------------------------------

              if to_char(l_peo_rec.wait_perd_dt_to_use_rl) is not null then
                   --
                   ben_plan_design_program_module.create_formula_result
                   (
                   p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_peo_rec.wait_perd_dt_to_use_rl
                   ,p_business_group_id              =>  l_peo_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                   );
                   --
              end if;

              ---------------------------------------------------------------
              -- WAIT_PERD_RL  -----------------
              ---------------------------------------------------------------

              if to_char(l_peo_rec.wait_perd_rl) is not null then
                   --
                   ben_plan_design_program_module.create_formula_result
                   (
                   p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_peo_rec.wait_perd_rl
                   ,p_business_group_id              =>  l_peo_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                   );
                   --
              end if;
            --
            ben_plan_design_plan_module.create_ler_result (
               p_validate                       => p_validate
              ,p_copy_entity_result_id          => l_copy_entity_result_id
              ,p_copy_entity_txn_id             => p_copy_entity_txn_id
              ,p_ler_id                         => l_peo_rec.ler_id
              ,p_business_group_id              => p_business_group_id
              ,p_number_of_copies               => l_number_of_copies
              ,p_object_version_number          => l_object_version_number
              ,p_effective_date                 => p_effective_date
              );
            --
          end loop;
          --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
     ---------------------------------------------------------------
      ---------------------------------------------------------------
      -- START OF BEN_LER_CHG_DPNT_CVG_F ----------------------
      ---------------------------------------------------------------
      --
      for l_parent_rec  in c_ldc1_from_parent(l_PTIP_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_ctp_result_id ;
         --
         l_ler_chg_dpnt_cvg_id1 := l_parent_rec.ler_chg_dpnt_cvg_id ;
         --
         for l_ldc_rec in c_ldc1(l_parent_rec.ler_chg_dpnt_cvg_id,l_mirror_src_entity_result_id,'LDC' ) loop
           --
           l_table_route_id := null ;
           open g_table_route('LDC');
             fetch g_table_route into l_table_route_id ;
           close g_table_route ;
           --
           l_information5  := get_ler_name(l_ldc_rec.ler_id,p_effective_date); --'Intersection';
           --
           if p_effective_date between l_ldc_rec.effective_start_date
              and l_ldc_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           l_copy_entity_result_id := null;
           l_object_version_number := null;
           ben_copy_entity_results_api.create_copy_entity_results(
             p_copy_entity_result_id           => l_copy_entity_result_id,
             p_copy_entity_txn_id             => p_copy_entity_txn_id,
             p_result_type_cd                 => l_result_type_cd,
             p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
             p_parent_entity_result_id        => l_mirror_src_entity_result_id,
             p_number_of_copies               => l_number_of_copies,
             p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'LDC',
             p_information1     => l_ldc_rec.ler_chg_dpnt_cvg_id,
             p_information2     => l_ldc_rec.EFFECTIVE_START_DATE,
             p_information3     => l_ldc_rec.EFFECTIVE_END_DATE,
             p_information4     => l_ldc_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information11     => l_ldc_rec.add_rmv_cvg_cd,
            p_information12     => l_ldc_rec.cvg_eff_end_cd,
            p_information263     => l_ldc_rec.cvg_eff_end_rl,
            p_information13     => l_ldc_rec.cvg_eff_strt_cd,
            p_information262     => l_ldc_rec.cvg_eff_strt_rl,
            p_information111     => l_ldc_rec.ldc_attribute1,
            p_information120     => l_ldc_rec.ldc_attribute10,
            p_information121     => l_ldc_rec.ldc_attribute11,
            p_information122     => l_ldc_rec.ldc_attribute12,
            p_information123     => l_ldc_rec.ldc_attribute13,
            p_information124     => l_ldc_rec.ldc_attribute14,
            p_information125     => l_ldc_rec.ldc_attribute15,
            p_information126     => l_ldc_rec.ldc_attribute16,
            p_information127     => l_ldc_rec.ldc_attribute17,
            p_information128     => l_ldc_rec.ldc_attribute18,
            p_information129     => l_ldc_rec.ldc_attribute19,
            p_information112     => l_ldc_rec.ldc_attribute2,
            p_information130     => l_ldc_rec.ldc_attribute20,
            p_information131     => l_ldc_rec.ldc_attribute21,
            p_information132     => l_ldc_rec.ldc_attribute22,
            p_information133     => l_ldc_rec.ldc_attribute23,
            p_information134     => l_ldc_rec.ldc_attribute24,
            p_information135     => l_ldc_rec.ldc_attribute25,
            p_information136     => l_ldc_rec.ldc_attribute26,
            p_information137     => l_ldc_rec.ldc_attribute27,
            p_information138     => l_ldc_rec.ldc_attribute28,
            p_information139     => l_ldc_rec.ldc_attribute29,
            p_information113     => l_ldc_rec.ldc_attribute3,
            p_information140     => l_ldc_rec.ldc_attribute30,
            p_information114     => l_ldc_rec.ldc_attribute4,
            p_information115     => l_ldc_rec.ldc_attribute5,
            p_information116     => l_ldc_rec.ldc_attribute6,
            p_information117     => l_ldc_rec.ldc_attribute7,
            p_information118     => l_ldc_rec.ldc_attribute8,
            p_information119     => l_ldc_rec.ldc_attribute9,
            p_information110     => l_ldc_rec.ldc_attribute_category,
            p_information14     => l_ldc_rec.ler_chg_dpnt_cvg_cd,
            p_information258     => l_ldc_rec.ler_chg_dpnt_cvg_rl,
            p_information257     => l_ldc_rec.ler_id,
            p_information260     => l_ldc_rec.pgm_id,
            p_information261     => l_ldc_rec.pl_id,
            p_information259     => l_ldc_rec.ptip_id,
            p_information265     => l_ldc_rec.object_version_number,
            --
             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

             if l_out_ldc1_result_id is null then
               l_out_ldc1_result_id := l_copy_entity_result_id;
             end if;

             if l_result_type_cd = 'DISPLAY' then
                l_out_ldc1_result_id := l_copy_entity_result_id ;
             end if;
             --

             -- Copy Fast Formulas if any are attached to any column --
             ---------------------------------------------------------------
             --   CVG_EFF_END_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_ldc_rec.cvg_eff_end_rl) is not null then
                     --
                     ben_plan_design_program_module.create_formula_result
                     (
                      p_validate                       =>  0
                     ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                     ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                     ,p_formula_id                     =>  l_ldc_rec.cvg_eff_end_rl
                     ,p_business_group_id              =>  l_ldc_rec.business_group_id
                     ,p_number_of_copies               =>  l_number_of_copies
                     ,p_object_version_number          =>  l_object_version_number
                     ,p_effective_date                 =>  p_effective_date
                     );

                     --
             end if;

             ---------------------------------------------------------------
             --   CVG_EFF_STRT_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_ldc_rec.cvg_eff_strt_rl) is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_ldc_rec.cvg_eff_strt_rl
                    ,p_business_group_id              =>  l_ldc_rec.business_group_id
                    ,p_number_of_copies               =>  l_number_of_copies
                    ,p_object_version_number          =>  l_object_version_number
                    ,p_effective_date                 =>  p_effective_date
                    );

                    --
             end if;

             ---------------------------------------------------------------
             --   LER_CHG_DPNT_CVG_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_ldc_rec.ler_chg_dpnt_cvg_rl) is not null then
                  --
                  ben_plan_design_program_module.create_formula_result
                  (
                   p_validate                       =>  0
                  ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                  ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                  ,p_formula_id                     =>  l_ldc_rec.ler_chg_dpnt_cvg_rl
                  ,p_business_group_id              =>  l_ldc_rec.business_group_id
                  ,p_number_of_copies               =>  l_number_of_copies
                  ,p_object_version_number          =>  l_object_version_number
                  ,p_effective_date                 =>  p_effective_date
                  );

                  --
             end if;
          end loop;

          for l_ldc_rec in c_ldc1_drp(l_parent_rec.ler_chg_dpnt_cvg_id,l_mirror_src_entity_result_id,'LDC' ) loop
            ben_plan_design_plan_module.create_ler_result (
               p_validate                       => p_validate
              ,p_copy_entity_result_id          => l_out_ldc1_result_id
              ,p_copy_entity_txn_id             => p_copy_entity_txn_id
              ,p_ler_id                         => l_ldc_rec.ler_id
              ,p_business_group_id              => p_business_group_id
              ,p_number_of_copies               => p_number_of_copies
              ,p_object_version_number          => l_object_version_number
              ,p_effective_date                 => p_effective_date
              );
          end loop;
         ---------------------------------------------------------------
         -- START OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_lcc1_from_parent(l_LER_CHG_DPNT_CVG_ID1) loop
            --
            l_mirror_src_entity_result_id := l_out_ldc1_result_id ;

            --
            l_ler_chg_dpnt_cvg_ctfn_id1 := l_parent_rec.ler_chg_dpnt_cvg_ctfn_id ;
            --
            for l_lcc_rec in c_lcc1(l_parent_rec.ler_chg_dpnt_cvg_ctfn_id,l_mirror_src_entity_result_id,'LCC' ) loop
              --
              l_table_route_id := null ;
              open g_table_route('LCC');
                fetch g_table_route into l_table_route_id ;
              close g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('BEN_DPNT_CVG_CTFN_TYP',l_lcc_rec.dpnt_cvg_ctfn_typ_cd); --'Intersection';
              --
              if p_effective_date between l_lcc_rec.effective_start_date
                 and l_lcc_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id           => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'LCC',
                p_information1     => l_lcc_rec.ler_chg_dpnt_cvg_ctfn_id,
                p_information2     => l_lcc_rec.EFFECTIVE_START_DATE,
                p_information3     => l_lcc_rec.EFFECTIVE_END_DATE,
                p_information4     => l_lcc_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information261     => l_lcc_rec.ctfn_rqd_when_rl,
            p_information12     => l_lcc_rec.dpnt_cvg_ctfn_typ_cd,
            p_information13     => l_lcc_rec.lack_ctfn_sspnd_enrt_flag,
            p_information111     => l_lcc_rec.lcc_attribute1,
            p_information120     => l_lcc_rec.lcc_attribute10,
            p_information121     => l_lcc_rec.lcc_attribute11,
            p_information122     => l_lcc_rec.lcc_attribute12,
            p_information123     => l_lcc_rec.lcc_attribute13,
            p_information124     => l_lcc_rec.lcc_attribute14,
            p_information125     => l_lcc_rec.lcc_attribute15,
            p_information126     => l_lcc_rec.lcc_attribute16,
            p_information127     => l_lcc_rec.lcc_attribute17,
            p_information128     => l_lcc_rec.lcc_attribute18,
            p_information129     => l_lcc_rec.lcc_attribute19,
            p_information112     => l_lcc_rec.lcc_attribute2,
            p_information130     => l_lcc_rec.lcc_attribute20,
            p_information131     => l_lcc_rec.lcc_attribute21,
            p_information132     => l_lcc_rec.lcc_attribute22,
            p_information133     => l_lcc_rec.lcc_attribute23,
            p_information134     => l_lcc_rec.lcc_attribute24,
            p_information135     => l_lcc_rec.lcc_attribute25,
            p_information136     => l_lcc_rec.lcc_attribute26,
            p_information137     => l_lcc_rec.lcc_attribute27,
            p_information138     => l_lcc_rec.lcc_attribute28,
            p_information139     => l_lcc_rec.lcc_attribute29,
            p_information113     => l_lcc_rec.lcc_attribute3,
            p_information140     => l_lcc_rec.lcc_attribute30,
            p_information114     => l_lcc_rec.lcc_attribute4,
            p_information115     => l_lcc_rec.lcc_attribute5,
            p_information116     => l_lcc_rec.lcc_attribute6,
            p_information117     => l_lcc_rec.lcc_attribute7,
            p_information118     => l_lcc_rec.lcc_attribute8,
            p_information119     => l_lcc_rec.lcc_attribute9,
            p_information110     => l_lcc_rec.lcc_attribute_category,
            p_information260     => l_lcc_rec.ler_chg_dpnt_cvg_id,
            p_information14     => l_lcc_rec.rlshp_typ_cd,
            p_information11     => l_lcc_rec.rqd_flag,
            p_information265    => l_lcc_rec.object_version_number,
            --
                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_lcc1_result_id is null then
                  l_out_lcc1_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_lcc1_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
        ---------------------------------------------------------------
          --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_LER_CHG_DPNT_CVG_F ----------------------
     ---------------------------------------------------------------
      ---------------------------------------------------------------
      -- START OF BEN_LER_CHG_PTIP_ENRT_F ----------------------
      ---------------------------------------------------------------
      --
      for l_parent_rec  in c_lct1_from_parent(l_PTIP_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_ctp_result_id ;
         --
         l_ler_chg_ptip_enrt_id := l_parent_rec.ler_chg_ptip_enrt_id ;
         --
         for l_lct_rec in c_lct1(l_parent_rec.ler_chg_ptip_enrt_id,l_mirror_src_entity_result_id,'LCT' ) loop
           --
           l_table_route_id := null ;
           open g_table_route('LCT');
             fetch g_table_route into l_table_route_id ;
           close g_table_route ;
           --
           l_information5  := get_ler_name(l_lct_rec.ler_id,p_effective_date); --'Intersection';
           --
           if p_effective_date between l_lct_rec.effective_start_date
              and l_lct_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           l_copy_entity_result_id := null;
           l_object_version_number := null;
           ben_copy_entity_results_api.create_copy_entity_results(
             p_copy_entity_result_id           => l_copy_entity_result_id,
             p_copy_entity_txn_id             => p_copy_entity_txn_id,
             p_result_type_cd                 => l_result_type_cd,
             p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
             p_parent_entity_result_id        => l_mirror_src_entity_result_id,
             p_number_of_copies               => l_number_of_copies,
             p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'LCT',
             p_information1     => l_lct_rec.ler_chg_ptip_enrt_id,
             p_information2     => l_lct_rec.EFFECTIVE_START_DATE,
             p_information3     => l_lct_rec.EFFECTIVE_END_DATE,
             p_information4     => l_lct_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information18     => l_lct_rec.crnt_enrt_prclds_chg_flag,
            p_information12     => l_lct_rec.dflt_enrt_cd,
            p_information13     => l_lct_rec.dflt_enrt_rl,
            p_information11     => l_lct_rec.dflt_flag,
            p_information14     => l_lct_rec.enrt_cd,
            p_information15     => l_lct_rec.enrt_mthd_cd,
            p_information16     => l_lct_rec.enrt_rl,
            p_information111     => l_lct_rec.lct_attribute1,
            p_information120     => l_lct_rec.lct_attribute10,
            p_information121     => l_lct_rec.lct_attribute11,
            p_information122     => l_lct_rec.lct_attribute12,
            p_information123     => l_lct_rec.lct_attribute13,
            p_information124     => l_lct_rec.lct_attribute14,
            p_information125     => l_lct_rec.lct_attribute15,
            p_information126     => l_lct_rec.lct_attribute16,
            p_information127     => l_lct_rec.lct_attribute17,
            p_information128     => l_lct_rec.lct_attribute18,
            p_information129     => l_lct_rec.lct_attribute19,
            p_information112     => l_lct_rec.lct_attribute2,
            p_information130     => l_lct_rec.lct_attribute20,
            p_information131     => l_lct_rec.lct_attribute21,
            p_information132     => l_lct_rec.lct_attribute22,
            p_information133     => l_lct_rec.lct_attribute23,
            p_information134     => l_lct_rec.lct_attribute24,
            p_information135     => l_lct_rec.lct_attribute25,
            p_information136     => l_lct_rec.lct_attribute26,
            p_information137     => l_lct_rec.lct_attribute27,
            p_information138     => l_lct_rec.lct_attribute28,
            p_information139     => l_lct_rec.lct_attribute29,
            p_information113     => l_lct_rec.lct_attribute3,
            p_information140     => l_lct_rec.lct_attribute30,
            p_information114     => l_lct_rec.lct_attribute4,
            p_information115     => l_lct_rec.lct_attribute5,
            p_information116     => l_lct_rec.lct_attribute6,
            p_information117     => l_lct_rec.lct_attribute7,
            p_information118     => l_lct_rec.lct_attribute8,
            p_information119     => l_lct_rec.lct_attribute9,
            p_information110     => l_lct_rec.lct_attribute_category,
            p_information257     => l_lct_rec.ler_id,
            p_information259     => l_lct_rec.ptip_id,
            p_information19     => l_lct_rec.stl_elig_cant_chg_flag,
            p_information17     => l_lct_rec.tco_chg_enrt_cd,
            p_information265    => l_lct_rec.object_version_number,
            --
             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

             if l_out_lct_result_id is null then
               l_out_lct_result_id := l_copy_entity_result_id;
             end if;

             if l_result_type_cd = 'DISPLAY' then
                l_out_lct_result_id := l_copy_entity_result_id ;
             end if;
             --

             -- Copy Fast Formulas if any are attached to any column --
             ---------------------------------------------------------------
             -- DFLT_ENRT_RL -----------------
             ---------------------------------------------------------------

             if l_lct_rec.dflt_enrt_rl is not null then
                     --
                     ben_plan_design_program_module.create_formula_result
                     (
                      p_validate                       =>  0
                     ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                     ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                     ,p_formula_id                     =>  l_lct_rec.dflt_enrt_rl
                     ,p_business_group_id              =>  l_lct_rec.business_group_id
                     ,p_number_of_copies               =>  l_number_of_copies
                     ,p_object_version_number          =>  l_object_version_number
                     ,p_effective_date                 =>  p_effective_date
                     );

                     --
             end if;

             ---------------------------------------------------------------
             -- ENRT_RL -----------------
             ---------------------------------------------------------------

             if l_lct_rec.enrt_rl is not null then
                   --
                   ben_plan_design_program_module.create_formula_result
                   (
                    p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_lct_rec.enrt_rl
                   ,p_business_group_id              =>  l_lct_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                   );

                   --
             end if;

          end loop;
          for l_lct_rec in c_lct1_drp(l_parent_rec.ler_chg_ptip_enrt_id,l_mirror_src_entity_result_id,'LCT' ) loop
            ben_plan_design_plan_module.create_ler_result (
                     p_validate                       => p_validate
                    ,p_copy_entity_result_id          => l_out_lct_result_id
                    ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                    ,p_ler_id                         => l_lct_rec.ler_id
                    ,p_business_group_id              => p_business_group_id
                    ,p_number_of_copies               => p_number_of_copies
                    ,p_object_version_number          => l_object_version_number
                    ,p_effective_date                 => p_effective_date
                    );
          end loop;
          --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_LER_CHG_PTIP_ENRT_F ----------------------
     ---------------------------------------------------------------
      ---------------------------------------------------------------
      -- START OF BEN_PTIP_DPNT_CVG_CTFN_F ----------------------
      ---------------------------------------------------------------
      --
      for l_parent_rec  in c_pyd1_from_parent(l_PTIP_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_ctp_result_id ;

         --
         l_ptip_dpnt_cvg_ctfn_id := l_parent_rec.ptip_dpnt_cvg_ctfn_id ;
         --
         for l_pyd_rec in c_pyd1(l_parent_rec.ptip_dpnt_cvg_ctfn_id,l_mirror_src_entity_result_id,'PYD' ) loop
           --
           l_table_route_id := null ;
           open g_table_route('PYD');
             fetch g_table_route into l_table_route_id ;
           close g_table_route ;
           --
           l_information5  := hr_general.decode_lookup('BEN_DPNT_CVG_CTFN_TYP',l_pyd_rec.dpnt_cvg_ctfn_typ_cd); --'Intersection';
           --
           if p_effective_date between l_pyd_rec.effective_start_date
              and l_pyd_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           l_copy_entity_result_id := null;
           l_object_version_number := null;
           ben_copy_entity_results_api.create_copy_entity_results(
             p_copy_entity_result_id           => l_copy_entity_result_id,
             p_copy_entity_txn_id             => p_copy_entity_txn_id,
             p_result_type_cd                 => l_result_type_cd,
             p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
             p_parent_entity_result_id        => l_mirror_src_entity_result_id,
             p_number_of_copies               => l_number_of_copies,
             p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'PYD',
             p_information1     => l_pyd_rec.ptip_dpnt_cvg_ctfn_id,
             p_information2     => l_pyd_rec.EFFECTIVE_START_DATE,
             p_information3     => l_pyd_rec.EFFECTIVE_END_DATE,
             p_information4     => l_pyd_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information257     => l_pyd_rec.ctfn_rqd_when_rl,
            p_information13     => l_pyd_rec.dpnt_cvg_ctfn_typ_cd,
            p_information12     => l_pyd_rec.lack_ctfn_sspnd_enrt_flag,
            p_information11     => l_pyd_rec.pfd_flag,
            p_information259     => l_pyd_rec.ptip_id,
            p_information111     => l_pyd_rec.pyd_attribute1,
            p_information120     => l_pyd_rec.pyd_attribute10,
            p_information121     => l_pyd_rec.pyd_attribute11,
            p_information122     => l_pyd_rec.pyd_attribute12,
            p_information123     => l_pyd_rec.pyd_attribute13,
            p_information124     => l_pyd_rec.pyd_attribute14,
            p_information125     => l_pyd_rec.pyd_attribute15,
            p_information126     => l_pyd_rec.pyd_attribute16,
            p_information127     => l_pyd_rec.pyd_attribute17,
            p_information128     => l_pyd_rec.pyd_attribute18,
            p_information129     => l_pyd_rec.pyd_attribute19,
            p_information112     => l_pyd_rec.pyd_attribute2,
            p_information130     => l_pyd_rec.pyd_attribute20,
            p_information131     => l_pyd_rec.pyd_attribute21,
            p_information132     => l_pyd_rec.pyd_attribute22,
            p_information133     => l_pyd_rec.pyd_attribute23,
            p_information134     => l_pyd_rec.pyd_attribute24,
            p_information135     => l_pyd_rec.pyd_attribute25,
            p_information136     => l_pyd_rec.pyd_attribute26,
            p_information137     => l_pyd_rec.pyd_attribute27,
            p_information138     => l_pyd_rec.pyd_attribute28,
            p_information139     => l_pyd_rec.pyd_attribute29,
            p_information113     => l_pyd_rec.pyd_attribute3,
            p_information140     => l_pyd_rec.pyd_attribute30,
            p_information114     => l_pyd_rec.pyd_attribute4,
            p_information115     => l_pyd_rec.pyd_attribute5,
            p_information116     => l_pyd_rec.pyd_attribute6,
            p_information117     => l_pyd_rec.pyd_attribute7,
            p_information118     => l_pyd_rec.pyd_attribute8,
            p_information119     => l_pyd_rec.pyd_attribute9,
            p_information110     => l_pyd_rec.pyd_attribute_category,
            p_information15     => l_pyd_rec.rlshp_typ_cd,
            p_information14     => l_pyd_rec.rqd_flag,
            p_information265    => l_pyd_rec.object_version_number,
            --
             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

             if l_out_pyd_result_id is null then
              l_out_pyd_result_id := l_copy_entity_result_id;
            end if;

             if l_result_type_cd = 'DISPLAY' then
                l_out_pyd_result_id := l_copy_entity_result_id ;
             end if;
             --

             -- Copy Fast Formulas if any are attached to any column --
             ---------------------------------------------------------------
             --  CTFN_RQD_WHEN_RL -----------------
             ---------------------------------------------------------------

             if to_char(l_pyd_rec.ctfn_rqd_when_rl) is not null then
                     --
                     ben_plan_design_program_module.create_formula_result
                     (
                      p_validate                       =>  0
                     ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                     ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                     ,p_formula_id                     =>  l_pyd_rec.ctfn_rqd_when_rl
                     ,p_business_group_id              =>  l_pyd_rec.business_group_id
                     ,p_number_of_copies               =>  l_number_of_copies
                     ,p_object_version_number          =>  l_object_version_number
                     ,p_effective_date                 =>  p_effective_date
                     );

                     --
             end if;

          end loop;
          --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PTIP_DPNT_CVG_CTFN_F ----------------------
     ---------------------------------------------------------------
      ---------------------------------------------------------------
      -- START OF BEN_WV_PRTN_RSN_PTIP_F ----------------------
      ---------------------------------------------------------------
      --
      for l_parent_rec  in c_wpt1_from_parent(l_PTIP_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_ctp_result_id ;

         --
         l_wv_prtn_rsn_ptip_id := l_parent_rec.wv_prtn_rsn_ptip_id ;
         --
         for l_wpt_rec in c_wpt1(l_parent_rec.wv_prtn_rsn_ptip_id,l_mirror_src_entity_result_id,'WPT' ) loop
           --
           l_table_route_id := null ;
           open g_table_route('WPT');
             fetch g_table_route into l_table_route_id ;
           close g_table_route ;
           --
           l_information5  := hr_general.decode_lookup('BEN_WV_PRTN_RSN',l_wpt_rec.wv_prtn_rsn_cd); --'Intersection';
           --
           if p_effective_date between l_wpt_rec.effective_start_date
              and l_wpt_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           l_copy_entity_result_id := null;
           l_object_version_number := null;
           ben_copy_entity_results_api.create_copy_entity_results(
             p_copy_entity_result_id          => l_copy_entity_result_id,
             p_copy_entity_txn_id             => p_copy_entity_txn_id,
             p_result_type_cd                 => l_result_type_cd,
             p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
             p_parent_entity_result_id        => l_mirror_src_entity_result_id,
             p_number_of_copies               => l_number_of_copies,
             p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'WPT',
             p_information1     => l_wpt_rec.wv_prtn_rsn_ptip_id,
             p_information2     => l_wpt_rec.EFFECTIVE_START_DATE,
             p_information3     => l_wpt_rec.EFFECTIVE_END_DATE,
             p_information4     => l_wpt_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information11     => l_wpt_rec.dflt_flag,
            p_information259     => l_wpt_rec.ptip_id,
            p_information111     => l_wpt_rec.wpt_attribute1,
            p_information120     => l_wpt_rec.wpt_attribute10,
            p_information121     => l_wpt_rec.wpt_attribute11,
            p_information122     => l_wpt_rec.wpt_attribute12,
            p_information123     => l_wpt_rec.wpt_attribute13,
            p_information124     => l_wpt_rec.wpt_attribute14,
            p_information125     => l_wpt_rec.wpt_attribute15,
            p_information126     => l_wpt_rec.wpt_attribute16,
            p_information127     => l_wpt_rec.wpt_attribute17,
            p_information128     => l_wpt_rec.wpt_attribute18,
            p_information129     => l_wpt_rec.wpt_attribute19,
            p_information112     => l_wpt_rec.wpt_attribute2,
            p_information130     => l_wpt_rec.wpt_attribute20,
            p_information131     => l_wpt_rec.wpt_attribute21,
            p_information132     => l_wpt_rec.wpt_attribute22,
            p_information133     => l_wpt_rec.wpt_attribute23,
            p_information134     => l_wpt_rec.wpt_attribute24,
            p_information135     => l_wpt_rec.wpt_attribute25,
            p_information136     => l_wpt_rec.wpt_attribute26,
            p_information137     => l_wpt_rec.wpt_attribute27,
            p_information138     => l_wpt_rec.wpt_attribute28,
            p_information139     => l_wpt_rec.wpt_attribute29,
            p_information113     => l_wpt_rec.wpt_attribute3,
            p_information140     => l_wpt_rec.wpt_attribute30,
            p_information114     => l_wpt_rec.wpt_attribute4,
            p_information115     => l_wpt_rec.wpt_attribute5,
            p_information116     => l_wpt_rec.wpt_attribute6,
            p_information117     => l_wpt_rec.wpt_attribute7,
            p_information118     => l_wpt_rec.wpt_attribute8,
            p_information119     => l_wpt_rec.wpt_attribute9,
            p_information110     => l_wpt_rec.wpt_attribute_category,
            p_information12     => l_wpt_rec.wv_prtn_rsn_cd,
            p_information265    => l_wpt_rec.object_version_number,
            --
             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

             if l_out_wpt_result_id is null then
               l_out_wpt_result_id := l_copy_entity_result_id;
             end if;

             if l_result_type_cd = 'DISPLAY' then
                l_out_wpt_result_id := l_copy_entity_result_id ;
             end if;
             --
          end loop;
        ---------------------------------------------------------------
        -- START OF BEN_WV_PRTN_RSN_CTFN_PTIP_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_wct1_from_parent(l_WV_PRTN_RSN_PTIP_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_wpt_result_id ;

           --
           l_wv_prtn_rsn_ctfn_ptip_id := l_parent_rec.wv_prtn_rsn_ctfn_ptip_id ;
           --
           for l_wct_rec in c_wct1(l_parent_rec.wv_prtn_rsn_ctfn_ptip_id,l_mirror_src_entity_result_id,'WCT') loop
             --
             l_table_route_id := null ;
             open g_table_route('WCT');
               fetch g_table_route into l_table_route_id ;
             close g_table_route ;
             --
             l_information5  := hr_general.decode_lookup('BEN_WV_PRTN_CTFN_TYP',l_wct_rec.wv_prtn_ctfn_typ_cd); --'Intersection';
             --
             if p_effective_date between l_wct_rec.effective_start_date
                and l_wct_rec.effective_end_date then
              --
                l_result_type_cd := 'DISPLAY';
             else
                l_result_type_cd := 'NO DISPLAY';
             end if;
               --
             l_copy_entity_result_id := null;
             l_object_version_number := null;
             ben_copy_entity_results_api.create_copy_entity_results(
               p_copy_entity_result_id           => l_copy_entity_result_id,
               p_copy_entity_txn_id             => p_copy_entity_txn_id,
               p_result_type_cd                 => l_result_type_cd,
               p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
               p_parent_entity_result_id        => l_mirror_src_entity_result_id,
               p_number_of_copies               => l_number_of_copies,
               p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'WCT',
               p_information1     => l_wct_rec.wv_prtn_rsn_ctfn_ptip_id,
               p_information2     => l_wct_rec.EFFECTIVE_START_DATE,
               p_information3     => l_wct_rec.EFFECTIVE_END_DATE,
               p_information4     => l_wct_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information258     => l_wct_rec.ctfn_rqd_when_rl,
            p_information11     => l_wct_rec.lack_ctfn_sspnd_wvr_flag,
            p_information13     => l_wct_rec.pfd_flag,
            p_information12     => l_wct_rec.rqd_flag,
            p_information111     => l_wct_rec.wct_attribute1,
            p_information120     => l_wct_rec.wct_attribute10,
            p_information121     => l_wct_rec.wct_attribute11,
            p_information122     => l_wct_rec.wct_attribute12,
            p_information123     => l_wct_rec.wct_attribute13,
            p_information124     => l_wct_rec.wct_attribute14,
            p_information125     => l_wct_rec.wct_attribute15,
            p_information126     => l_wct_rec.wct_attribute16,
            p_information127     => l_wct_rec.wct_attribute17,
            p_information128     => l_wct_rec.wct_attribute18,
            p_information129     => l_wct_rec.wct_attribute19,
            p_information112     => l_wct_rec.wct_attribute2,
            p_information130     => l_wct_rec.wct_attribute20,
            p_information131     => l_wct_rec.wct_attribute21,
            p_information132     => l_wct_rec.wct_attribute22,
            p_information133     => l_wct_rec.wct_attribute23,
            p_information134     => l_wct_rec.wct_attribute24,
            p_information135     => l_wct_rec.wct_attribute25,
            p_information136     => l_wct_rec.wct_attribute26,
            p_information137     => l_wct_rec.wct_attribute27,
            p_information138     => l_wct_rec.wct_attribute28,
            p_information139     => l_wct_rec.wct_attribute29,
            p_information113     => l_wct_rec.wct_attribute3,
            p_information140     => l_wct_rec.wct_attribute30,
            p_information114     => l_wct_rec.wct_attribute4,
            p_information115     => l_wct_rec.wct_attribute5,
            p_information116     => l_wct_rec.wct_attribute6,
            p_information117     => l_wct_rec.wct_attribute7,
            p_information118     => l_wct_rec.wct_attribute8,
            p_information119     => l_wct_rec.wct_attribute9,
            p_information110     => l_wct_rec.wct_attribute_category,
            p_information15     => l_wct_rec.wv_prtn_ctfn_cd,
            p_information14     => l_wct_rec.wv_prtn_ctfn_typ_cd,
            p_information257     => l_wct_rec.wv_prtn_rsn_ptip_id,
            p_information265    => l_wct_rec.object_version_number,
            --
               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_wct_result_id is null then
                 l_out_wct_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_wct_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- CTFN_RQD_WHEN_RL -----------------
               ---------------------------------------------------------------

               if to_char(l_wct_rec.ctfn_rqd_when_rl) is not null then
                       --
                       ben_plan_design_program_module.create_formula_result
                       (
                        p_validate                       =>  0
                       ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                       ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                       ,p_formula_id                     =>  l_wct_rec.ctfn_rqd_when_rl
                       ,p_business_group_id              =>  l_wct_rec.business_group_id
                       ,p_number_of_copies               =>  l_number_of_copies
                       ,p_object_version_number          =>  l_object_version_number
                       ,p_effective_date                 =>  p_effective_date
                       );

                       --
               end if;

            end loop;
            --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_WV_PRTN_RSN_CTFN_PTIP_F ----------------------
       ---------------------------------------------------------------
          --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_WV_PRTN_RSN_PTIP_F ----------------------
     ---------------------------------------------------------------
   --
   end loop;
   ---------------------------------------------------------------
   -- END OF BEN_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PLIP_F ----------------------
   ---------------------------------------------------------------
   --
   for l_parent_rec  in c_cpp_from_parent(l_PGM_ID) loop
     --
     l_plip_id := l_parent_rec.plip_id ;
     l_mirror_src_entity_result_id := l_out_pgm_result_id ;

     --
     for l_cpp_rec in c_cpp(l_parent_rec.plip_id,l_mirror_src_entity_result_id,'CPP') loop
     --
     --
       l_table_route_id := null ;
       open g_table_route('CPP');
       fetch g_table_route into l_table_route_id ;
       close g_table_route ;
       --
       l_information5  := get_pl_name(l_cpp_rec.pl_id,p_effective_date); --'Intersection';
       --

       if p_effective_date between l_cpp_rec.effective_start_date
       and l_cpp_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
       else
         l_result_type_cd := 'NO DISPLAY';
       end if;
       --
       l_copy_entity_result_id := null;
       l_object_version_number := null;
       ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'CPP',
        p_information1     => l_cpp_rec.plip_id,
        p_information2     => l_cpp_rec.EFFECTIVE_START_DATE,
        p_information3     => l_cpp_rec.EFFECTIVE_END_DATE,
        p_information4     => l_cpp_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information15     => l_cpp_rec.alws_unrstrctd_enrt_flag,
            p_information266     => l_cpp_rec.auto_enrt_mthd_rl,
            p_information36     => l_cpp_rec.bnft_or_option_rstrctn_cd,
            p_information239     => l_cpp_rec.cmbn_plip_id,
            p_information111     => l_cpp_rec.cpp_attribute1,
            p_information120     => l_cpp_rec.cpp_attribute10,
            p_information121     => l_cpp_rec.cpp_attribute11,
            p_information122     => l_cpp_rec.cpp_attribute12,
            p_information123     => l_cpp_rec.cpp_attribute13,
            p_information124     => l_cpp_rec.cpp_attribute14,
            p_information125     => l_cpp_rec.cpp_attribute15,
            p_information126     => l_cpp_rec.cpp_attribute16,
            p_information127     => l_cpp_rec.cpp_attribute17,
            p_information128     => l_cpp_rec.cpp_attribute18,
            p_information129     => l_cpp_rec.cpp_attribute19,
            p_information112     => l_cpp_rec.cpp_attribute2,
            p_information130     => l_cpp_rec.cpp_attribute20,
            p_information131     => l_cpp_rec.cpp_attribute21,
            p_information132     => l_cpp_rec.cpp_attribute22,
            p_information133     => l_cpp_rec.cpp_attribute23,
            p_information134     => l_cpp_rec.cpp_attribute24,
            p_information135     => l_cpp_rec.cpp_attribute25,
            p_information136     => l_cpp_rec.cpp_attribute26,
            p_information137     => l_cpp_rec.cpp_attribute27,
            p_information138     => l_cpp_rec.cpp_attribute28,
            p_information139     => l_cpp_rec.cpp_attribute29,
            p_information113     => l_cpp_rec.cpp_attribute3,
            p_information140     => l_cpp_rec.cpp_attribute30,
            p_information114     => l_cpp_rec.cpp_attribute4,
            p_information115     => l_cpp_rec.cpp_attribute5,
            p_information116     => l_cpp_rec.cpp_attribute6,
            p_information117     => l_cpp_rec.cpp_attribute7,
            p_information118     => l_cpp_rec.cpp_attribute8,
            p_information119     => l_cpp_rec.cpp_attribute9,
            p_information110     => l_cpp_rec.cpp_attribute_category,
            p_information28     => l_cpp_rec.cvg_incr_r_decr_only_cd,
            p_information21     => l_cpp_rec.dflt_enrt_cd,
            p_information264     => l_cpp_rec.dflt_enrt_det_rl,
            p_information13     => l_cpp_rec.dflt_flag,
            p_information29     => l_cpp_rec.dflt_to_asn_pndg_ctfn_cd,
            p_information272     => l_cpp_rec.dflt_to_asn_pndg_ctfn_rl,
            p_information16     => l_cpp_rec.drvbl_fctr_apls_rts_flag,
            p_information17     => l_cpp_rec.drvbl_fctr_prtn_elig_flag,
            p_information18     => l_cpp_rec.elig_apls_flag,
            p_information22     => l_cpp_rec.enrt_cd,
            p_information25     => l_cpp_rec.enrt_cvg_end_dt_cd,
            p_information269     => l_cpp_rec.enrt_cvg_end_dt_rl,
            p_information24     => l_cpp_rec.enrt_cvg_strt_dt_cd,
            p_information268     => l_cpp_rec.enrt_cvg_strt_dt_rl,
            p_information23     => l_cpp_rec.enrt_mthd_cd,
            p_information267     => l_cpp_rec.enrt_rl,
            p_information141     => l_cpp_rec.ivr_ident,
            p_information293     => l_cpp_rec.mn_cvg_amt,
            p_information273     => l_cpp_rec.mn_cvg_rl,
            p_information294     => l_cpp_rec.mx_cvg_alwd_amt,
            p_information295     => l_cpp_rec.mx_cvg_incr_alwd_amt,
            p_information296     => l_cpp_rec.mx_cvg_incr_wcf_alwd_amt,
            p_information274     => l_cpp_rec.mx_cvg_mlt_incr_num,
            p_information275     => l_cpp_rec.mx_cvg_mlt_incr_wcf_num,
            p_information276     => l_cpp_rec.mx_cvg_rl,
            p_information297     => l_cpp_rec.mx_cvg_wcfn_amt,
            p_information277     => l_cpp_rec.mx_cvg_wcfn_mlt_num,
            p_information30     => l_cpp_rec.no_mn_cvg_amt_apls_flag,
            p_information31     => l_cpp_rec.no_mn_cvg_incr_apls_flag,
            p_information32     => l_cpp_rec.no_mx_cvg_amt_apls_flag,
            p_information33     => l_cpp_rec.no_mx_cvg_incr_apls_flag,
            p_information263     => l_cpp_rec.ordr_num,
            p_information38     => l_cpp_rec.per_cvrd_cd,
            p_information260     => l_cpp_rec.pgm_id,
            p_information261     => l_cpp_rec.pl_id,
            p_information14     => l_cpp_rec.plip_stat_cd,
            p_information257     => l_cpp_rec.postelcn_edit_rl,
            p_information35     => l_cpp_rec.prort_prtl_yr_cvg_rstrn_cd,
            p_information278     => l_cpp_rec.prort_prtl_yr_cvg_rstrn_rl,
            p_information19     => l_cpp_rec.prtn_elig_ovrid_alwd_flag,
            p_information27     => l_cpp_rec.rt_end_dt_cd,
            p_information271     => l_cpp_rec.rt_end_dt_rl,
            p_information26     => l_cpp_rec.rt_strt_dt_cd,
            p_information270     => l_cpp_rec.rt_strt_dt_rl,
            p_information11     => l_cpp_rec.short_code,
            p_information12     => l_cpp_rec.short_name,
            p_information20     => l_cpp_rec.trk_inelig_per_flag,
            p_information34     => l_cpp_rec.unsspnd_enrt_cd,
            p_information185     => l_cpp_rec.url_ref_name,
            p_information37     => l_cpp_rec.vrfy_fmly_mmbr_cd,
            p_information279     => l_cpp_rec.vrfy_fmly_mmbr_rl,
            p_information265    => l_cpp_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_cpp_result_id is null then
          l_out_cpp_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
          l_out_cpp_result_id := l_copy_entity_result_id ;
        end if;

        -- Copy Fast Formulas if any are attached to any column --
        ---------------------------------------------------------------
        -- AUTO_ENRT_MTHD_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.auto_enrt_mthd_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.auto_enrt_mthd_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;


        ---------------------------------------------------------------
        -- DFLT_ENRT_DET_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.dflt_enrt_det_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.dflt_enrt_det_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- DFLT_TO_ASN_PNDG_CTFN_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.dflt_to_asn_pndg_ctfn_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.dflt_to_asn_pndg_ctfn_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_CVG_END_DT_RL-----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.enrt_cvg_end_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.enrt_cvg_end_dt_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_CVG_STRT_DT_RL-----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.enrt_cvg_strt_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.enrt_cvg_strt_dt_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- ENRT_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.enrt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.enrt_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- MN_CVG_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.mn_cvg_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.mn_cvg_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- MX_CVG_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.mx_cvg_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.mx_cvg_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;


        ---------------------------------------------------------------
        -- POSTELCN_EDIT_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.postelcn_edit_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.postelcn_edit_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- PRORT_PRTL_YR_CVG_RSTRN_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.prort_prtl_yr_cvg_rstrn_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.prort_prtl_yr_cvg_rstrn_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- RT_END_DT_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.rt_end_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.rt_end_dt_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- RT_STRT_DT_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.rt_strt_dt_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.rt_strt_dt_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;

        ---------------------------------------------------------------
        -- VRFY_FMLY_MMBR_RL -----------------
        ---------------------------------------------------------------

        if to_char(l_cpp_rec.vrfy_fmly_mmbr_rl) is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_cpp_rec.vrfy_fmly_mmbr_rl
                ,p_business_group_id              =>  l_cpp_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
        end if;
   --
   end loop;
   --
   hr_utility.set_location('l_copy_entity_result_id '||l_copy_entity_result_id,20);
   hr_utility.set_location('p_copy_entity_txn_id    '||p_copy_entity_txn_id,20);
   hr_utility.set_location('l_parent_rec.plip_id    '||l_parent_rec.plip_id,20);
   hr_utility.set_location('p_business_group_id     '||p_business_group_id,20);
       -- ------------------------------------------------------------------------
       -- Eligibility Profiles
       -- ------------------------------------------------------------------------
          ben_plan_design_elpro_module.create_elpro_results
          (
              p_validate                     => p_validate
             ,p_copy_entity_result_id        => l_out_cpp_result_id
             ,p_copy_entity_txn_id           => p_copy_entity_txn_id
             ,p_pgm_id                       => null
             ,p_ptip_id                      => null
             ,p_plip_id                      => l_plip_id
             ,p_pl_id                        => null
             ,p_oipl_id                      => null
             ,p_business_group_id            => p_business_group_id
             ,p_number_of_copies             => p_number_of_copies
             ,p_object_version_number        => l_object_version_number
             ,p_effective_date               => p_effective_date
             ,p_parent_entity_result_id      => l_out_cpp_result_id
          );
         --
            -- ------------------------------------------------------------------------
            -- Standard Rates ,Flex Credits at Plip level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_cpp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => l_plip_id
             ,p_pl_id                      => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cpp_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools  Plip Level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_out_cpp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => l_plip_id
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cpp_result_id
             ) ;

            -- ------------------------------------------------------------------------
            -- Coverage Calculations PLIP Level
            -- ------------------------------------------------------------------------

            ben_pd_rate_and_cvg_module.create_coverage_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_cpp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_plip_id                    => l_plip_id
             ,p_pl_id                      => null
             ,p_oipl_id                    => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cpp_result_id
           ) ;

         ---------------------------------------------------------------
         -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_peo2_from_parent(l_PLIP_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_cpp_result_id ;
            --
            l_elig_to_prte_rsn_id2 := l_parent_rec.elig_to_prte_rsn_id ;
            --
            for l_peo_rec in c_peo2(l_parent_rec.elig_to_prte_rsn_id,l_mirror_src_entity_result_id,'PEO' ) loop
              --
              l_table_route_id := null ;
              open g_table_route('PEO');
                fetch g_table_route into l_table_route_id ;
              close g_table_route ;
              --
              l_information5  := get_ler_name(l_peo_rec.ler_id,p_effective_date); --'Intersection';
              --
              if p_effective_date between l_peo_rec.effective_start_date
                 and l_peo_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
                p_table_alias                    => 'PEO',
                p_information1     => l_peo_rec.elig_to_prte_rsn_id,
                p_information2     => l_peo_rec.EFFECTIVE_START_DATE,
                p_information3     => l_peo_rec.EFFECTIVE_END_DATE,
                p_information4     => l_peo_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information21     => l_peo_rec.elig_inelig_cd,
            p_information20     => l_peo_rec.ignr_prtn_ovrid_flag,
            p_information257     => l_peo_rec.ler_id,
            p_information17     => l_peo_rec.mx_poe_apls_cd,
            p_information16     => l_peo_rec.mx_poe_det_dt_cd,
            p_information272     => l_peo_rec.mx_poe_det_dt_rl,
            p_information270     => l_peo_rec.mx_poe_rl,
            p_information15     => l_peo_rec.mx_poe_uom,
            p_information269     => l_peo_rec.mx_poe_val,
            p_information258     => l_peo_rec.oipl_id,
            p_information111     => l_peo_rec.peo_attribute1,
            p_information120     => l_peo_rec.peo_attribute10,
            p_information121     => l_peo_rec.peo_attribute11,
            p_information122     => l_peo_rec.peo_attribute12,
            p_information123     => l_peo_rec.peo_attribute13,
            p_information124     => l_peo_rec.peo_attribute14,
            p_information125     => l_peo_rec.peo_attribute15,
            p_information126     => l_peo_rec.peo_attribute16,
            p_information127     => l_peo_rec.peo_attribute17,
            p_information128     => l_peo_rec.peo_attribute18,
            p_information129     => l_peo_rec.peo_attribute19,
            p_information112     => l_peo_rec.peo_attribute2,
            p_information130     => l_peo_rec.peo_attribute20,
            p_information131     => l_peo_rec.peo_attribute21,
            p_information132     => l_peo_rec.peo_attribute22,
            p_information133     => l_peo_rec.peo_attribute23,
            p_information134     => l_peo_rec.peo_attribute24,
            p_information135     => l_peo_rec.peo_attribute25,
            p_information136     => l_peo_rec.peo_attribute26,
            p_information137     => l_peo_rec.peo_attribute27,
            p_information138     => l_peo_rec.peo_attribute28,
            p_information139     => l_peo_rec.peo_attribute29,
            p_information113     => l_peo_rec.peo_attribute3,
            p_information140     => l_peo_rec.peo_attribute30,
            p_information114     => l_peo_rec.peo_attribute4,
            p_information115     => l_peo_rec.peo_attribute5,
            p_information116     => l_peo_rec.peo_attribute6,
            p_information117     => l_peo_rec.peo_attribute7,
            p_information118     => l_peo_rec.peo_attribute8,
            p_information119     => l_peo_rec.peo_attribute9,
            p_information110     => l_peo_rec.peo_attribute_category,
            p_information260     => l_peo_rec.pgm_id,
            p_information261     => l_peo_rec.pl_id,
            p_information256     => l_peo_rec.plip_id,
            p_information12     => l_peo_rec.prtn_eff_end_dt_cd,
            p_information266     => l_peo_rec.prtn_eff_end_dt_rl,
            p_information11     => l_peo_rec.prtn_eff_strt_dt_cd,
            p_information264     => l_peo_rec.prtn_eff_strt_dt_rl,
            p_information19     => l_peo_rec.prtn_ovridbl_flag,
            p_information259     => l_peo_rec.ptip_id,
            p_information18     => l_peo_rec.vrfy_fmly_mmbr_cd,
            p_information273     => l_peo_rec.vrfy_fmly_mmbr_rl,
            p_information14     => l_peo_rec.wait_perd_dt_to_use_cd,
            p_information268     => l_peo_rec.wait_perd_dt_to_use_rl,
            p_information271     => l_peo_rec.wait_perd_rl,
            p_information13     => l_peo_rec.wait_perd_uom,
            p_information267     => l_peo_rec.wait_perd_val,
            p_information265    => l_peo_rec.object_version_number,
            --
                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_peo2_result_id is null then
                  l_out_peo2_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_peo2_result_id := l_copy_entity_result_id ;
                end if;
                --

                -- Copy Fast Formulas if any are attached to any column --
                 ---------------------------------------------------------------
                 -- MX_POE_DET_DT_RL  -----------------
                 ---------------------------------------------------------------

                 if to_char(l_peo_rec.mx_poe_det_dt_rl) is not null then
                         --
                         ben_plan_design_program_module.create_formula_result
                         (
                          p_validate                       =>  0
                         ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                         ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                         ,p_formula_id                     =>  l_peo_rec.mx_poe_det_dt_rl
                         ,p_business_group_id              =>  l_peo_rec.business_group_id
                         ,p_number_of_copies               =>  l_number_of_copies
                         ,p_object_version_number          =>  l_object_version_number
                         ,p_effective_date                 =>  p_effective_date
                         );

                         --
                 end if;

                  ---------------------------------------------------------------
                  -- MX_POE_RL  -----------------
                  ---------------------------------------------------------------

                  if to_char(l_peo_rec.mx_poe_rl) is not null then
                          --
                          ben_plan_design_program_module.create_formula_result
                          (
                           p_validate                       =>  0
                          ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                          ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                          ,p_formula_id                     =>  l_peo_rec.mx_poe_rl
                          ,p_business_group_id              =>  l_peo_rec.business_group_id
                          ,p_number_of_copies               =>  l_number_of_copies
                          ,p_object_version_number          =>  l_object_version_number
                          ,p_effective_date                 =>  p_effective_date
                          );

                          --
                 end if;

                 ---------------------------------------------------------------
                 -- PRTN_EFF_END_DT_RL  -----------------
                 ---------------------------------------------------------------

                   if to_char(l_peo_rec.prtn_eff_end_dt_rl) is not null then
                           --
                           ben_plan_design_program_module.create_formula_result
                           (
                            p_validate                       =>  0
                           ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                           ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                           ,p_formula_id                     =>  l_peo_rec.prtn_eff_end_dt_rl
                           ,p_business_group_id              =>  l_peo_rec.business_group_id
                           ,p_number_of_copies               =>  l_number_of_copies
                           ,p_object_version_number          =>  l_object_version_number
                           ,p_effective_date                 =>  p_effective_date
                           );

                           --
                  end if;

                  ---------------------------------------------------------------
                  -- PRTN_EFF_STRT_DT_RL  -----------------
                  ---------------------------------------------------------------

                   if to_char(l_peo_rec.prtn_eff_strt_dt_rl) is not null then
                            --
                            ben_plan_design_program_module.create_formula_result
                            (
                             p_validate                       =>  0
                            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                            ,p_formula_id                     =>  l_peo_rec.prtn_eff_strt_dt_rl
                            ,p_business_group_id              =>  l_peo_rec.business_group_id
                            ,p_number_of_copies               =>  l_number_of_copies
                            ,p_object_version_number          =>  l_object_version_number
                            ,p_effective_date                 =>  p_effective_date
                            );

                            --
                   end if;

                  ---------------------------------------------------------------
                  -- VRFY_FMLY_MMBR_RL -----------------
                  ---------------------------------------------------------------

                   if to_char(l_peo_rec.vrfy_fmly_mmbr_rl) is not null then
                            --
                            ben_plan_design_program_module.create_formula_result
                            (
                             p_validate                       =>  0
                            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                            ,p_formula_id                     =>  l_peo_rec.vrfy_fmly_mmbr_rl
                            ,p_business_group_id              =>  l_peo_rec.business_group_id
                            ,p_number_of_copies               =>  l_number_of_copies
                            ,p_object_version_number          =>  l_object_version_number
                            ,p_effective_date                 =>  p_effective_date
                            );

                            --
                   end if;

                  ---------------------------------------------------------------
                  -- WAIT_PERD_DT_TO_USE_RL -----------------
                  ---------------------------------------------------------------

                   if to_char(l_peo_rec.wait_perd_dt_to_use_rl) is not null then
                            --
                            ben_plan_design_program_module.create_formula_result
                            (
                             p_validate                       =>  0
                            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                            ,p_formula_id                     =>  l_peo_rec.wait_perd_dt_to_use_rl
                            ,p_business_group_id              =>  l_peo_rec.business_group_id
                            ,p_number_of_copies               =>  l_number_of_copies
                            ,p_object_version_number          =>  l_object_version_number
                            ,p_effective_date                 =>  p_effective_date
                            );

                            --
                   end if;

                   ---------------------------------------------------------------
                   -- WAIT_PERD_RL -----------------
                   ---------------------------------------------------------------

                   if to_char(l_peo_rec.wait_perd_rl) is not null then
                             --
                             ben_plan_design_program_module.create_formula_result
                             (
                              p_validate                       =>  0
                             ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                             ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                             ,p_formula_id                     =>  l_peo_rec.wait_perd_rl
                             ,p_business_group_id              =>  l_peo_rec.business_group_id
                             ,p_number_of_copies               =>  l_number_of_copies
                             ,p_object_version_number          =>  l_object_version_number
                             ,p_effective_date                 =>  p_effective_date
                             );

                             --
                   end if;
                   --
                   ben_plan_design_plan_module.create_ler_result (
                      p_validate                       => p_validate
                      ,p_copy_entity_result_id          => l_copy_entity_result_id
                      ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                      ,p_ler_id                         => l_peo_rec.ler_id
                      ,p_business_group_id              => p_business_group_id
                      ,p_number_of_copies               => l_number_of_copies
                      ,p_object_version_number          => l_object_version_number
                      ,p_effective_date                 => p_effective_date
                      );
                   --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_LER_BNFT_RSTRN_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_lbr1_from_parent(l_PLIP_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_cpp_result_id ;
            --
            l_ler_bnft_rstrn_id := l_parent_rec.ler_bnft_rstrn_id ;
            --
            for l_lbr_rec in c_lbr1(l_parent_rec.ler_bnft_rstrn_id,l_mirror_src_entity_result_id,'LBR' ) loop
              --
              l_table_route_id := null ;
              open g_table_route('LBR');
                fetch g_table_route into l_table_route_id ;
              close g_table_route ;
              --
              l_information5  := get_ler_name(l_lbr_rec.ler_id,p_effective_date); --'Intersection';
              --
              if p_effective_date between l_lbr_rec.effective_start_date
                 and l_lbr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'LBR',
                p_information1     => l_lbr_rec.ler_bnft_rstrn_id,
                p_information2     => l_lbr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_lbr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_lbr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information12     => l_lbr_rec.cvg_incr_r_decr_only_cd,
            p_information11     => l_lbr_rec.dflt_to_asn_pndg_ctfn_cd,
            p_information262     => l_lbr_rec.dflt_to_asn_pndg_ctfn_rl,
            p_information111     => l_lbr_rec.lbr_attribute1,
            p_information120     => l_lbr_rec.lbr_attribute10,
            p_information121     => l_lbr_rec.lbr_attribute11,
            p_information122     => l_lbr_rec.lbr_attribute12,
            p_information123     => l_lbr_rec.lbr_attribute13,
            p_information124     => l_lbr_rec.lbr_attribute14,
            p_information125     => l_lbr_rec.lbr_attribute15,
            p_information126     => l_lbr_rec.lbr_attribute16,
            p_information127     => l_lbr_rec.lbr_attribute17,
            p_information128     => l_lbr_rec.lbr_attribute18,
            p_information129     => l_lbr_rec.lbr_attribute19,
            p_information112     => l_lbr_rec.lbr_attribute2,
            p_information130     => l_lbr_rec.lbr_attribute20,
            p_information131     => l_lbr_rec.lbr_attribute21,
            p_information132     => l_lbr_rec.lbr_attribute22,
            p_information133     => l_lbr_rec.lbr_attribute23,
            p_information134     => l_lbr_rec.lbr_attribute24,
            p_information135     => l_lbr_rec.lbr_attribute25,
            p_information136     => l_lbr_rec.lbr_attribute26,
            p_information137     => l_lbr_rec.lbr_attribute27,
            p_information138     => l_lbr_rec.lbr_attribute28,
            p_information139     => l_lbr_rec.lbr_attribute29,
            p_information113     => l_lbr_rec.lbr_attribute3,
            p_information140     => l_lbr_rec.lbr_attribute30,
            p_information114     => l_lbr_rec.lbr_attribute4,
            p_information115     => l_lbr_rec.lbr_attribute5,
            p_information116     => l_lbr_rec.lbr_attribute6,
            p_information117     => l_lbr_rec.lbr_attribute7,
            p_information118     => l_lbr_rec.lbr_attribute8,
            p_information119     => l_lbr_rec.lbr_attribute9,
            p_information110     => l_lbr_rec.lbr_attribute_category,
            p_information257     => l_lbr_rec.ler_id,
            p_information297     => l_lbr_rec.mn_cvg_amt,
            p_information268     => l_lbr_rec.mn_cvg_rl,
            p_information295     => l_lbr_rec.mx_cvg_alwd_amt,
            p_information294     => l_lbr_rec.mx_cvg_incr_alwd_amt,
            p_information293     => l_lbr_rec.mx_cvg_incr_wcf_alwd_amt,
            p_information263     => l_lbr_rec.mx_cvg_mlt_incr_num,
            p_information264     => l_lbr_rec.mx_cvg_mlt_incr_wcf_num,
            p_information266     => l_lbr_rec.mx_cvg_rl,
            p_information296     => l_lbr_rec.mx_cvg_wcfn_amt,
            p_information267     => l_lbr_rec.mx_cvg_wcfn_mlt_num,
            p_information14     => l_lbr_rec.no_mn_cvg_incr_apls_flag,
            p_information15     => l_lbr_rec.no_mx_cvg_amt_apls_flag,
            p_information16     => l_lbr_rec.no_mx_cvg_incr_apls_flag,
            p_information261     => l_lbr_rec.pl_id,
            p_information256     => l_lbr_rec.plip_id,
            p_information13     => l_lbr_rec.unsspnd_enrt_cd,
            p_information265    => l_lbr_rec.object_version_number,
            --
                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_lbr_result_id is null then
                  l_out_lbr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_lbr_result_id := l_copy_entity_result_id ;
                end if;
                --

                -- Copy Fast Formulas if any are attached to any column --
                ---------------------------------------------------------------
                --  DFLT_TO_ASN_PNDG_CTFN_RL -----------------
                ---------------------------------------------------------------

                if to_char(l_lbr_rec.dflt_to_asn_pndg_ctfn_rl) is not null then
                        --
                        ben_plan_design_program_module.create_formula_result
                        (
                         p_validate                       =>  0
                        ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                        ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                        ,p_formula_id                     =>  l_lbr_rec.dflt_to_asn_pndg_ctfn_rl
                        ,p_business_group_id              =>  l_lbr_rec.business_group_id
                        ,p_number_of_copies               =>  l_number_of_copies
                        ,p_object_version_number          =>  l_object_version_number
                        ,p_effective_date                 =>  p_effective_date
                        );

                        --
                end if;
                ---------------------------------------------------------------
                --  MN_CVG_RL -----------------
                ---------------------------------------------------------------

                if to_char(l_lbr_rec.mn_cvg_rl) is not null then
                        --
                        ben_plan_design_program_module.create_formula_result
                        (
                         p_validate                       =>  0
                        ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                        ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                        ,p_formula_id                     =>  l_lbr_rec.mn_cvg_rl
                        ,p_business_group_id              =>  l_lbr_rec.business_group_id
                        ,p_number_of_copies               =>  l_number_of_copies
                        ,p_object_version_number          =>  l_object_version_number
                        ,p_effective_date                 =>  p_effective_date
                        );

                        --
                end if;
                ---------------------------------------------------------------
                --  MX_CVG_RL -----------------
                ---------------------------------------------------------------

                if to_char(l_lbr_rec.mx_cvg_rl) is not null then
                        --
                        ben_plan_design_program_module.create_formula_result
                        (
                         p_validate                       =>  0
                        ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                        ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                        ,p_formula_id                     =>  l_lbr_rec.mx_cvg_rl
                        ,p_business_group_id              =>  l_lbr_rec.business_group_id
                        ,p_number_of_copies               =>  l_number_of_copies
                        ,p_object_version_number          =>  l_object_version_number
                        ,p_effective_date                 =>  p_effective_date
                        );

                        --
                end if;


             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_LER_BNFT_RSTRN_F ----------------------
        ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_LER_CHG_PLIP_ENRT_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_lpr_from_parent(l_PLIP_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_cpp_result_id ;
          --
          l_ler_chg_plip_enrt_id := l_parent_rec.ler_chg_plip_enrt_id ;
          --
          for l_lpr_rec in c_lpr(l_parent_rec.ler_chg_plip_enrt_id,l_mirror_src_entity_result_id,'LPR1') loop
          --
            l_table_route_id := null ;
            open g_table_route('LPR1');
            fetch g_table_route into l_table_route_id ;
            close g_table_route ;
            --
            l_information5  := get_ler_name(l_lpr_rec.ler_id,p_effective_date); --'Intersection';
            --
            if p_effective_date between l_lpr_rec.effective_start_date
             and l_lpr_rec.effective_end_date then
             --
              l_result_type_cd := 'DISPLAY';
            else
              l_result_type_cd := 'NO DISPLAY';
            end if;
            --
            l_copy_entity_result_id := null;
            l_object_version_number := null;
            ben_copy_entity_results_api.create_copy_entity_results(
              p_copy_entity_result_id           => l_copy_entity_result_id,
              p_copy_entity_txn_id             => p_copy_entity_txn_id,
              p_result_type_cd                 => l_result_type_cd,
              p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
              p_parent_entity_result_id      => l_mirror_src_entity_result_id,
              p_number_of_copies               => l_number_of_copies,
              p_table_route_id                 => l_table_route_id,
             p_table_alias                    => 'LPR1',
              p_information1     => l_lpr_rec.ler_chg_plip_enrt_id,
              p_information2     => l_lpr_rec.EFFECTIVE_START_DATE,
              p_information3     => l_lpr_rec.EFFECTIVE_END_DATE,
              p_information4     => l_lpr_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information262     => l_lpr_rec.auto_enrt_mthd_rl,
            p_information12     => l_lpr_rec.crnt_enrt_prclds_chg_flag,
            p_information15     => l_lpr_rec.dflt_enrt_cd,
            p_information263     => l_lpr_rec.dflt_enrt_rl,
            p_information13     => l_lpr_rec.dflt_flag,
            p_information16     => l_lpr_rec.enrt_cd,
            p_information17     => l_lpr_rec.enrt_mthd_cd,
            p_information258     => l_lpr_rec.enrt_rl,
            p_information257     => l_lpr_rec.ler_id,
            p_information111     => l_lpr_rec.lpr_attribute1,
            p_information120     => l_lpr_rec.lpr_attribute10,
            p_information121     => l_lpr_rec.lpr_attribute11,
            p_information122     => l_lpr_rec.lpr_attribute12,
            p_information123     => l_lpr_rec.lpr_attribute13,
            p_information124     => l_lpr_rec.lpr_attribute14,
            p_information125     => l_lpr_rec.lpr_attribute15,
            p_information126     => l_lpr_rec.lpr_attribute16,
            p_information127     => l_lpr_rec.lpr_attribute17,
            p_information128     => l_lpr_rec.lpr_attribute18,
            p_information129     => l_lpr_rec.lpr_attribute19,
            p_information112     => l_lpr_rec.lpr_attribute2,
            p_information130     => l_lpr_rec.lpr_attribute20,
            p_information131     => l_lpr_rec.lpr_attribute21,
            p_information132     => l_lpr_rec.lpr_attribute22,
            p_information133     => l_lpr_rec.lpr_attribute23,
            p_information134     => l_lpr_rec.lpr_attribute24,
            p_information135     => l_lpr_rec.lpr_attribute25,
            p_information136     => l_lpr_rec.lpr_attribute26,
            p_information137     => l_lpr_rec.lpr_attribute27,
            p_information138     => l_lpr_rec.lpr_attribute28,
            p_information139     => l_lpr_rec.lpr_attribute29,
            p_information113     => l_lpr_rec.lpr_attribute3,
            p_information140     => l_lpr_rec.lpr_attribute30,
            p_information114     => l_lpr_rec.lpr_attribute4,
            p_information115     => l_lpr_rec.lpr_attribute5,
            p_information116     => l_lpr_rec.lpr_attribute6,
            p_information117     => l_lpr_rec.lpr_attribute7,
            p_information118     => l_lpr_rec.lpr_attribute8,
            p_information119     => l_lpr_rec.lpr_attribute9,
            p_information110     => l_lpr_rec.lpr_attribute_category,
            p_information256     => l_lpr_rec.plip_id,
            p_information14     => l_lpr_rec.stl_elig_cant_chg_flag,
            p_information11     => l_lpr_rec.tco_chg_enrt_cd,
            p_information265    => l_lpr_rec.object_version_number,
            --
              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

            if l_out_lpr_result_id is null then
              l_out_lpr_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_lpr_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas if any are attached to any column --
            ---------------------------------------------------------------
            --  AUTO_ENRT_MTHD_RL -----------------
            ---------------------------------------------------------------

            if to_char(l_lpr_rec.auto_enrt_mthd_rl) is not null then
            --
              ben_plan_design_program_module.create_formula_result
              (
                p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lpr_rec.auto_enrt_mthd_rl
                ,p_business_group_id              =>  l_lpr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
               );
             --
             end if;

            ---------------------------------------------------------------
            --  DFLT_ENRT__RL -----------------
            ---------------------------------------------------------------

            if to_char(l_lpr_rec.dflt_enrt_rl) is not null then
            --
              ben_plan_design_program_module.create_formula_result
              (
                p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lpr_rec.dflt_enrt_rl
                ,p_business_group_id              =>  l_lpr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
               );
             --
             end if;

             ---------------------------------------------------------------
            --  ENRT__RL -----------------
            ---------------------------------------------------------------

            if to_char(l_lpr_rec.enrt_rl) is not null then
            --
              ben_plan_design_program_module.create_formula_result
              (
                p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lpr_rec.enrt_rl
                ,p_business_group_id              =>  l_lpr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
               );
             --
             end if;

          end loop;
          --
          for l_lpr_rec in c_lpr_drp(l_parent_rec.ler_chg_plip_enrt_id,l_mirror_src_entity_result_id,'LPR1') loop
            ben_plan_design_plan_module.create_ler_result (
                     p_validate                       => p_validate
                    ,p_copy_entity_result_id          => l_out_lpr_result_id
                    ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                    ,p_ler_id                         => l_lpr_rec.ler_id
                    ,p_business_group_id              => p_business_group_id
                    ,p_number_of_copies               => p_number_of_copies
                    ,p_object_version_number          => l_object_version_number
                    ,p_effective_date                 => p_effective_date
                    );
          end loop;
          --
        end loop;
        ---------------------------------------------------------------
        -- END OF BEN_LER_CHG_PLIP_ENRT_F ----------------------
        ---------------------------------------------------------------
        -- ------------------------------------------------------------------------
        -- Plans
        -- ------------------------------------------------------------------------
         ben_plan_design_plan_module.create_plan_result
         (p_copy_entity_result_id          => l_copy_entity_result_id
         ,p_copy_entity_txn_id             => p_copy_entity_txn_id
         ,p_pl_id                          => null
         ,p_plip_id                        => l_parent_rec.plip_id
         ,p_business_group_id              => p_business_group_id
         ,p_number_of_copies               => p_number_of_copies
         ,p_object_version_number          => l_object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_no_dup_rslt                    => p_no_dup_rslt
         ) ;
         l_copy_entity_result_id := null ;
         l_object_version_number := null ;
        --
  end loop;

   ---------------------------------------------------------------
   -- END OF BEN_PLIP_F ----------------------
   ---------------------------------------------------------------

  ---------------------------------------------------------------
  -- START OF BEN_CMBN_PLIP_F ----------------------
  ---------------------------------------------------------------
  --
  for l_parent_rec  in c_cpl1_from_parent(l_PGM_ID) loop
    --
    l_mirror_src_entity_result_id := l_out_pgm_result_id;

    --
    l_cmbn_plip_id := l_parent_rec.cmbn_plip_id ;
    --
    for l_cpl_rec in c_cpl1(l_parent_rec.cmbn_plip_id,l_mirror_src_entity_result_id,'CPL' ) loop
      --
      l_table_route_id := null ;
      open g_table_route('CPL');
        fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := l_cpl_rec.name; --'Intersection';
      --
      if p_effective_date between l_cpl_rec.effective_start_date
         and l_cpl_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
        --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id          => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                    => 'CPL',
        p_information1     => l_cpl_rec.cmbn_plip_id,
        p_information2     => l_cpl_rec.EFFECTIVE_START_DATE,
        p_information3     => l_cpl_rec.EFFECTIVE_END_DATE,
        p_information4     => l_cpl_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cpl_rec.cpl_attribute1,
            p_information120     => l_cpl_rec.cpl_attribute10,
            p_information121     => l_cpl_rec.cpl_attribute11,
            p_information122     => l_cpl_rec.cpl_attribute12,
            p_information123     => l_cpl_rec.cpl_attribute13,
            p_information124     => l_cpl_rec.cpl_attribute14,
            p_information125     => l_cpl_rec.cpl_attribute15,
            p_information126     => l_cpl_rec.cpl_attribute16,
            p_information127     => l_cpl_rec.cpl_attribute17,
            p_information128     => l_cpl_rec.cpl_attribute18,
            p_information129     => l_cpl_rec.cpl_attribute19,
            p_information112     => l_cpl_rec.cpl_attribute2,
            p_information130     => l_cpl_rec.cpl_attribute20,
            p_information131     => l_cpl_rec.cpl_attribute21,
            p_information132     => l_cpl_rec.cpl_attribute22,
            p_information133     => l_cpl_rec.cpl_attribute23,
            p_information134     => l_cpl_rec.cpl_attribute24,
            p_information135     => l_cpl_rec.cpl_attribute25,
            p_information136     => l_cpl_rec.cpl_attribute26,
            p_information137     => l_cpl_rec.cpl_attribute27,
            p_information138     => l_cpl_rec.cpl_attribute28,
            p_information139     => l_cpl_rec.cpl_attribute29,
            p_information113     => l_cpl_rec.cpl_attribute3,
            p_information140     => l_cpl_rec.cpl_attribute30,
            p_information114     => l_cpl_rec.cpl_attribute4,
            p_information115     => l_cpl_rec.cpl_attribute5,
            p_information116     => l_cpl_rec.cpl_attribute6,
            p_information117     => l_cpl_rec.cpl_attribute7,
            p_information118     => l_cpl_rec.cpl_attribute8,
            p_information119     => l_cpl_rec.cpl_attribute9,
            p_information110     => l_cpl_rec.cpl_attribute_category,
            p_information170     => l_cpl_rec.name,
            p_information260     => l_cpl_rec.pgm_id,
            p_information265     => l_cpl_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_cpl_result_id is null then
          l_out_cpl_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_cpl_result_id := l_copy_entity_result_id ;
        end if;
        --
     end loop;
     --
          -- ------------------------------------------------------------------------
          -- Standard Rates ,Flex Credits at BEN_CMBN_PLIP_F level
          -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_cpl_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_pl_id                      => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => l_cmbn_plip_id
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cpl_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools  BEN_CMBN_PLIP_F level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_out_cpl_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => l_cmbn_plip_id
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies             => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cpl_result_id
             ) ;
          --
   end loop;
---------------------------------------------------------------
-- END OF BEN_CMBN_PLIP_F ----------------------
---------------------------------------------------------------
 ---------------------------------------------------------------
 -- START OF BEN_CMBN_PTIP_F ----------------------
 ---------------------------------------------------------------
 --
   for l_parent_rec  in c_cbp1_from_parent(l_PGM_ID) loop
    --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    --
    l_cmbn_ptip_id := l_parent_rec.cmbn_ptip_id ;
    --
    for l_cbp_rec in c_cbp1(l_parent_rec.cmbn_ptip_id,l_mirror_src_entity_result_id,'CBP' ) loop
      --
      l_table_route_id := null ;
      open g_table_route('CBP');
        fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := l_cbp_rec.name; --'Intersection';
      --
      if p_effective_date between l_cbp_rec.effective_start_date
         and l_cbp_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
        --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                    => 'CBP',
        p_information1     => l_cbp_rec.cmbn_ptip_id,
        p_information2     => l_cbp_rec.EFFECTIVE_START_DATE,
        p_information3     => l_cbp_rec.EFFECTIVE_END_DATE,
        p_information4     => l_cbp_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cbp_rec.cbp_attribute1,
            p_information120     => l_cbp_rec.cbp_attribute10,
            p_information121     => l_cbp_rec.cbp_attribute11,
            p_information122     => l_cbp_rec.cbp_attribute12,
            p_information123     => l_cbp_rec.cbp_attribute13,
            p_information124     => l_cbp_rec.cbp_attribute14,
            p_information125     => l_cbp_rec.cbp_attribute15,
            p_information126     => l_cbp_rec.cbp_attribute16,
            p_information127     => l_cbp_rec.cbp_attribute17,
            p_information128     => l_cbp_rec.cbp_attribute18,
            p_information129     => l_cbp_rec.cbp_attribute19,
            p_information112     => l_cbp_rec.cbp_attribute2,
            p_information130     => l_cbp_rec.cbp_attribute20,
            p_information131     => l_cbp_rec.cbp_attribute21,
            p_information132     => l_cbp_rec.cbp_attribute22,
            p_information133     => l_cbp_rec.cbp_attribute23,
            p_information134     => l_cbp_rec.cbp_attribute24,
            p_information135     => l_cbp_rec.cbp_attribute25,
            p_information136     => l_cbp_rec.cbp_attribute26,
            p_information137     => l_cbp_rec.cbp_attribute27,
            p_information138     => l_cbp_rec.cbp_attribute28,
            p_information139     => l_cbp_rec.cbp_attribute29,
            p_information113     => l_cbp_rec.cbp_attribute3,
            p_information140     => l_cbp_rec.cbp_attribute30,
            p_information114     => l_cbp_rec.cbp_attribute4,
            p_information115     => l_cbp_rec.cbp_attribute5,
            p_information116     => l_cbp_rec.cbp_attribute6,
            p_information117     => l_cbp_rec.cbp_attribute7,
            p_information118     => l_cbp_rec.cbp_attribute8,
            p_information119     => l_cbp_rec.cbp_attribute9,
            p_information110     => l_cbp_rec.cbp_attribute_category,
            p_information170     => l_cbp_rec.name,
            p_information260     => l_cbp_rec.pgm_id,
            p_information265     => l_cbp_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_cbp_result_id is null then
          l_out_cbp_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_cbp_result_id := l_copy_entity_result_id ;
        end if;
        --
     end loop;
     --
          -- ------------------------------------------------------------------------
          -- Standard Rates ,Flex Credits at BEN_CMBN_PTIP_F level
          -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_cbp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_pl_id                      => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => l_cmbn_ptip_id
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id   => l_out_cbp_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools BEN_CMBN_PTIP_F level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_out_cbp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => l_cmbn_ptip_id
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cbp_result_id
             ) ;

   end loop;
---------------------------------------------------------------
-- END OF BEN_CMBN_PTIP_F ----------------------
---------------------------------------------------------------
 ---------------------------------------------------------------
 -- START OF BEN_CMBN_PTIP_OPT_F ----------------------
 ---------------------------------------------------------------
 --
 for l_parent_rec  in c_cpt1_from_parent(l_PGM_ID) loop
    --
    l_mirror_src_entity_result_id := l_out_pgm_result_id ;

    --
    l_cmbn_ptip_opt_id := l_parent_rec.cmbn_ptip_opt_id ;
    --
    for l_cpt_rec in c_cpt1(l_parent_rec.cmbn_ptip_opt_id,l_mirror_src_entity_result_id,'CPT' ) loop
      --
      l_table_route_id := null ;
      open g_table_route('CPT');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := l_cpt_rec.name; --'Intersection';
      --
      if p_effective_date between l_cpt_rec.effective_start_date
         and l_cpt_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
        --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id          => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                    => 'CPT',
        p_information1     => l_cpt_rec.cmbn_ptip_opt_id,
        p_information2     => l_cpt_rec.EFFECTIVE_START_DATE,
        p_information3     => l_cpt_rec.EFFECTIVE_END_DATE,
        p_information4     => l_cpt_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cpt_rec.cpt_attribute1,
            p_information120     => l_cpt_rec.cpt_attribute10,
            p_information121     => l_cpt_rec.cpt_attribute11,
            p_information122     => l_cpt_rec.cpt_attribute12,
            p_information123     => l_cpt_rec.cpt_attribute13,
            p_information124     => l_cpt_rec.cpt_attribute14,
            p_information125     => l_cpt_rec.cpt_attribute15,
            p_information126     => l_cpt_rec.cpt_attribute16,
            p_information127     => l_cpt_rec.cpt_attribute17,
            p_information128     => l_cpt_rec.cpt_attribute18,
            p_information129     => l_cpt_rec.cpt_attribute19,
            p_information112     => l_cpt_rec.cpt_attribute2,
            p_information130     => l_cpt_rec.cpt_attribute20,
            p_information131     => l_cpt_rec.cpt_attribute21,
            p_information132     => l_cpt_rec.cpt_attribute22,
            p_information133     => l_cpt_rec.cpt_attribute23,
            p_information134     => l_cpt_rec.cpt_attribute24,
            p_information135     => l_cpt_rec.cpt_attribute25,
            p_information136     => l_cpt_rec.cpt_attribute26,
            p_information137     => l_cpt_rec.cpt_attribute27,
            p_information138     => l_cpt_rec.cpt_attribute28,
            p_information139     => l_cpt_rec.cpt_attribute29,
            p_information113     => l_cpt_rec.cpt_attribute3,
            p_information140     => l_cpt_rec.cpt_attribute30,
            p_information114     => l_cpt_rec.cpt_attribute4,
            p_information115     => l_cpt_rec.cpt_attribute5,
            p_information116     => l_cpt_rec.cpt_attribute6,
            p_information117     => l_cpt_rec.cpt_attribute7,
            p_information118     => l_cpt_rec.cpt_attribute8,
            p_information119     => l_cpt_rec.cpt_attribute9,
            p_information110     => l_cpt_rec.cpt_attribute_category,
            p_information170     => l_cpt_rec.name,
            p_information247     => l_cpt_rec.opt_id,
            p_information260     => l_cpt_rec.pgm_id,
            p_information259     => l_cpt_rec.ptip_id,
            p_information265     => l_cpt_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_cpt_result_id is null then
          l_out_cpt_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_cpt_result_id := l_copy_entity_result_id ;
        end if;
        --
     end loop;
     --
            -- ------------------------------------------------------------------------
            -- Standard Rates ,Flex Credits at BEN_CMBN_PTIP_OPT_F level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_cpt_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_pl_id                      => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => l_cmbn_ptip_opt_id
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id   => l_out_cpt_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools  BEN_CMBN_PTIP_OPT_F level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_out_cpt_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_oiplip_id                  => null
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => l_cmbn_ptip_opt_id
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_cpt_result_id
             ) ;

   end loop;
---------------------------------------------------------------
-- END OF BEN_CMBN_PTIP_OPT_F ----------------------
---------------------------------------------------------------
 ---------------------------------------------------------------
 -- START OF BEN_OIPLIP_F ----------------------
 ---------------------------------------------------------------
 --
 for l_parent_rec  in c_opp1_from_parent(l_PGM_ID,'COP' ) loop
    --
    l_mirror_src_entity_result_id := l_parent_rec.copy_entity_result_id ;

    --
    l_oiplip_id := l_parent_rec.oiplip_id ;
    --
    for l_opp_rec in c_opp1(l_parent_rec.oiplip_id,l_parent_rec.copy_entity_result_id,'OPP' ) loop
      --
      l_table_route_id := null ;
      open g_table_route('OPP');
        fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := get_oiplip_name(l_opp_rec.oipl_id,l_opp_rec.plip_id,p_effective_date); --'Intersection';
      --
      if p_effective_date between l_opp_rec.effective_start_date
         and l_opp_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
        --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id          => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                    => 'OPP',
        p_information1     => l_opp_rec.oiplip_id,
        p_information2     => l_opp_rec.EFFECTIVE_START_DATE,
        p_information3     => l_opp_rec.EFFECTIVE_END_DATE,
        p_information4     => l_opp_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information258     => l_opp_rec.oipl_id,
            p_information111     => l_opp_rec.opp_attribute1,
            p_information120     => l_opp_rec.opp_attribute10,
            p_information121     => l_opp_rec.opp_attribute11,
            p_information122     => l_opp_rec.opp_attribute12,
            p_information123     => l_opp_rec.opp_attribute13,
            p_information124     => l_opp_rec.opp_attribute14,
            p_information125     => l_opp_rec.opp_attribute15,
            p_information126     => l_opp_rec.opp_attribute16,
            p_information127     => l_opp_rec.opp_attribute17,
            p_information128     => l_opp_rec.opp_attribute18,
            p_information129     => l_opp_rec.opp_attribute19,
            p_information112     => l_opp_rec.opp_attribute2,
            p_information130     => l_opp_rec.opp_attribute20,
            p_information131     => l_opp_rec.opp_attribute21,
            p_information132     => l_opp_rec.opp_attribute22,
            p_information133     => l_opp_rec.opp_attribute23,
            p_information134     => l_opp_rec.opp_attribute24,
            p_information135     => l_opp_rec.opp_attribute25,
            p_information136     => l_opp_rec.opp_attribute26,
            p_information137     => l_opp_rec.opp_attribute27,
            p_information138     => l_opp_rec.opp_attribute28,
            p_information139     => l_opp_rec.opp_attribute29,
            p_information113     => l_opp_rec.opp_attribute3,
            p_information140     => l_opp_rec.opp_attribute30,
            p_information114     => l_opp_rec.opp_attribute4,
            p_information115     => l_opp_rec.opp_attribute5,
            p_information116     => l_opp_rec.opp_attribute6,
            p_information117     => l_opp_rec.opp_attribute7,
            p_information118     => l_opp_rec.opp_attribute8,
            p_information119     => l_opp_rec.opp_attribute9,
            p_information110     => l_opp_rec.opp_attribute_category,
            p_information256     => l_opp_rec.plip_id,
            p_information265     => l_opp_rec.object_version_number,
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_opp_result_id is null then
          l_out_opp_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_opp_result_id := l_copy_entity_result_id ;
        end if;
        --
     end loop;
     --
            -- ------------------------------------------------------------------------
            -- Standard Rates ,Flex Credits at OiPlip level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_rate_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_out_opp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_pl_id                      => null
             ,p_oiplip_id                  => l_oiplip_id
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_opp_result_id
             ) ;
            -- ------------------------------------------------------------------------
            -- Benefit Pools  Oiplip Level
            -- ------------------------------------------------------------------------
          ben_pd_rate_and_cvg_module.create_bnft_pool_results
            (
              p_validate                   =>p_validate
             ,p_copy_entity_result_id      =>l_out_opp_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_pgm_id                     => null
             ,p_ptip_id                    => null
             ,p_plip_id                    => null
             ,p_oiplip_id                  => l_oiplip_id
             ,p_cmbn_plip_id               => null
             ,p_cmbn_ptip_id               => null
             ,p_cmbn_ptip_opt_id           => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_out_opp_result_id
             ) ;

   end loop;
---------------------------------------------------------------
-- END OF BEN_OIPLIP_F ----------------------
---------------------------------------------------------------
/* NOT REQUIRED FOR COPY
 -- Only required for Rows Copied count in Log
 -- To be uncommented after create_OTP_rows is fixed
 ---------------------------------------------------------------
 -- START OF BEN_OPTIP_F ----------------------
 ---------------------------------------------------------------
 --
 for l_parent_rec  in c_otp1_from_parent(l_PGM_ID,'OPT') loop
    --
    l_mirror_src_entity_result_id := l_parent_rec.copy_entity_result_id ;

    --
    l_optip_id := l_parent_rec.optip_id ;
    --
    for l_otp_rec in c_otp1(l_parent_rec.optip_id,l_parent_rec.copy_entity_result_id,'OTP' ) loop
      --
      l_table_route_id := null ;
      open g_table_route('OTP');
        fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5  := get_optip_name(l_otp_rec.opt_id,l_otp_rec.pl_typ_id,p_effective_date); --'Intersection';
      --
      if p_effective_date between l_otp_rec.effective_start_date
         and l_otp_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
        --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id          => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_table_alias                    => 'OTP',
        p_information1     => l_otp_rec.optip_id,
        p_information2     => l_otp_rec.EFFECTIVE_START_DATE,
        p_information3     => l_otp_rec.EFFECTIVE_END_DATE,
        p_information4     => l_otp_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
*/
/*
            p_information249     => l_otp_rec.cmbn_ptip_opt_id,
            p_information247     => l_otp_rec.opt_id,
            p_information111     => l_otp_rec.otp_attribute1,
            p_information120     => l_otp_rec.otp_attribute10,
            p_information121     => l_otp_rec.otp_attribute11,
            p_information122     => l_otp_rec.otp_attribute12,
            p_information123     => l_otp_rec.otp_attribute13,
            p_information124     => l_otp_rec.otp_attribute14,
            p_information125     => l_otp_rec.otp_attribute15,
            p_information126     => l_otp_rec.otp_attribute16,
            p_information127     => l_otp_rec.otp_attribute17,
            p_information128     => l_otp_rec.otp_attribute18,
            p_information129     => l_otp_rec.otp_attribute19,
            p_information112     => l_otp_rec.otp_attribute2,
            p_information130     => l_otp_rec.otp_attribute20,
            p_information131     => l_otp_rec.otp_attribute21,
            p_information132     => l_otp_rec.otp_attribute22,
            p_information133     => l_otp_rec.otp_attribute23,
            p_information134     => l_otp_rec.otp_attribute24,
            p_information135     => l_otp_rec.otp_attribute25,
            p_information136     => l_otp_rec.otp_attribute26,
            p_information137     => l_otp_rec.otp_attribute27,
            p_information138     => l_otp_rec.otp_attribute28,
            p_information139     => l_otp_rec.otp_attribute29,
            p_information113     => l_otp_rec.otp_attribute3,
            p_information140     => l_otp_rec.otp_attribute30,
            p_information114     => l_otp_rec.otp_attribute4,
            p_information115     => l_otp_rec.otp_attribute5,
            p_information116     => l_otp_rec.otp_attribute6,
            p_information117     => l_otp_rec.otp_attribute7,
            p_information118     => l_otp_rec.otp_attribute8,
            p_information119     => l_otp_rec.otp_attribute9,
            p_information110     => l_otp_rec.otp_attribute_category,
            p_information260     => l_otp_rec.pgm_id,
            p_information248     => l_otp_rec.pl_typ_id,
            p_information259     => l_otp_rec.ptip_id,
            p_information265     => l_otp_rec.object_version_number,
*/
/*
            --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

        if l_out_otp_result_id is null then
          l_out_otp_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_otp_result_id := l_copy_entity_result_id ;
        end if;
        --
     end loop;
     --
   end loop;
*/
---------------------------------------------------------------
-- END OF BEN_OPTIP_F ----------------------
---------------------------------------------------------------
  end if;
end  create_program_result ;
--
procedure create_formula_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number
  ,p_formula_id                     in  number
  ,p_business_group_id              in  number    default null
  ,p_copy_to_clob                   in  varchar2  default 'N'
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
  l_proc varchar2(72) := g_package||'create_formula_result';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
  --
  l_cv_result_type_cd   varchar2(30) :=  'DISPLAY' ;
   --
   -- Bug : 3752407 : Global cursor g_table_route will now be used
   --
   -- Cursor to get table_route_id
   -- cursor c_table_route(c_parent_table_name varchar2) is
   -- cursor c_table_route(c_parent_table_alias varchar2) is
   -- select table_route_id
   -- from pqh_table_route trt
   -- where trt.table_alias = c_parent_table_alias ;
   --
   -- Cursor to get mirror_src_entity_result_id
   cursor c_parent_result(c_parent_pk_id number,
                    c_parent_table_alias  varchar2,
                    c_copy_entity_txn_id number) is
   select copy_entity_result_id mirror_src_entity_result_id
   from ben_copy_entity_results cpe
    -- ,pqh_table_route trt
   where cpe.information1= c_parent_pk_id
   and   cpe.result_type_cd = l_cv_result_type_cd
   and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and   cpe.table_route_id = trt.table_route_id
   and   cpe.table_alias = c_parent_table_alias ;
   ---
   ---------------------------------------------------------------
   -- START OF FF_FORMULAS_F ----------------------
   ---------------------------------------------------------------
   -- We get the only the formula
   cursor c_fff(c_formula_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  fff.*,fff.formula_text ff_text,ft.formula_type_name formula_type_name
   from FF_FORMULAS_F fff,FF_FORMULA_TYPES ft
   where  fff.formula_id = c_formula_id
   and fff.formula_type_id = ft.formula_type_id
   and ( fff.business_group_id = p_business_group_id or fff.business_group_id is null )
   and not exists (
     select /* */ null
     from ben_copy_entity_results cpe
          -- ,pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
--     and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     and cpe.table_alias  = c_table_alias
     and information1 = c_FORMULA_ID
       and information2 = fff.effective_start_date
       and information3 = fff.effective_end_date
    );
   l_FORMULA_ID                 number(15);
   l_out_fff_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF FF_FORMULAS_F ----------------------
   ---------------------------------------------------------------

  cursor c_object_exists(c_pk_id                number,
                         c_table_alias          varchar2) is
  select null
  from ben_copy_entity_results cpe
       -- ,pqh_table_route trt
  where copy_entity_txn_id = p_copy_entity_txn_id
--  and trt.table_route_id = cpe.table_route_id
  and cpe.table_alias = c_table_alias
  and information1 = c_pk_id;

  l_dummy                        varchar2(1);

  l_table_route_id                number(15);
  l_mirror_src_entity_result_id     number(15);
  l_result_type_cd                varchar2(30);
  l_information5                  ben_copy_entity_results.information5%type;
  l_ler_id                        number(15);
  l_number_of_copies              number(15);

  l_ff_formula_text_clob			clob;
  l_ff_formula_text_long			long;
  l_copy_to_clob		varchar2(10);

  --Bug 4945193 Cursor to retreive the transaction category
     cursor c_trasaction_categories is
	select ptc.short_name
	from PQH_COPY_ENTITY_TXNS pcet,
	     PQH_TRANSACTION_CATEGORIES ptc
	where pcet.COPY_ENTITY_TXN_ID= p_copy_entity_txn_id
	and ptc.TRANSACTION_CATEGORY_ID = pcet.TRANSACTION_CATEGORY_ID;

	l_trasaction_category     PQH_TRANSACTION_CATEGORIES.SHORT_NAME%type;
-- End Bug 4945193

  begin
  --
  l_number_of_copies := p_number_of_copies ;
    --
  --Bug 4945193 Set the p_copy_to_clob to 'Y' is the transaction category
  -- is GSP/PDW
     open c_trasaction_categories ;
     fetch  c_trasaction_categories into l_trasaction_category;
     close c_trasaction_categories;

   if p_copy_to_clob = 'Y' or l_trasaction_category in ('PQHGSP','BEN_PDCRWZ') then
	l_copy_to_clob := 'Y';
   end if;
--End Bug 4945193

 ---------------------------------------------------------------
 -- START OF FF_FORMULAS_F ----------------------
 ---------------------------------------------------------------
    --
    l_mirror_src_entity_result_id := p_copy_entity_result_id ;
    --
    l_FORMULA_ID := p_formula_id ;
    --
    if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
      open c_object_exists(l_FORMULA_ID,'FFF');
      fetch c_object_exists into l_dummy;
      if c_object_exists%found then
        close c_object_exists;
        return;
      end if;
      close c_object_exists;
    end if;

    for l_fff_rec in c_fff(l_FORMULA_ID,l_mirror_src_entity_result_id,'FFF' ) loop
      --
      l_table_route_id := null ;
      open g_table_route('FFF');
      fetch g_table_route into l_table_route_id ;
      close g_table_route ;
      --
      l_information5 := l_fff_rec.formula_name; -- 'Intersection';
      --
      if p_effective_date between l_fff_rec.effective_start_date
         and l_fff_rec.effective_end_date then
       --
         l_result_type_cd := 'DISPLAY';
      else
         l_result_type_cd := 'NO DISPLAY';
      end if;
        --
      l_copy_entity_result_id := null;
      l_object_version_number := null;

      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id          => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_route_id                 => l_table_route_id,
        p_information1     => l_fff_rec.FORMULA_ID,
        p_information2     => l_fff_rec.EFFECTIVE_START_DATE,
        p_information3     => l_fff_rec.EFFECTIVE_END_DATE,
        p_information4     => l_fff_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information12     => l_fff_rec.compile_flag,
            p_information151     => l_fff_rec.description,
            p_information112     => l_fff_rec.formula_name,
            p_information323     => l_fff_rec.ff_text,
            p_information160     => l_fff_rec.formula_type_id,
            p_information113     => l_fff_rec.formula_type_name,
            p_information13     => l_fff_rec.legislation_code,
            p_information11     => l_fff_rec.sticky_flag,
        --
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --


		if l_copy_to_clob = 'Y' then
			-- RKG Placeholder for copying formula text to clob column


		select fff.formula_text into l_ff_formula_text_long from
		  ff_formulas_f fff
		where fff.formula_id =  l_fff_rec.FORMULA_ID
		and   fff.effective_start_Date = l_fff_rec.EFFECTIVE_START_DATE
		and fff.effective_end_date = l_fff_rec.EFFECTIVE_END_DATE
		and fff.business_Group_id = l_fff_rec.business_group_id;

		l_ff_formula_text_clob := RTrim(to_char(l_ff_formula_text_long));

		update ben_copy_entity_results cped
		set cped.INFORMATION325 = l_ff_formula_text_clob
		where cped.COPY_ENTITY_RESULT_ID = l_copy_entity_result_id
		and cped.copy_entity_txn_id = p_copy_entity_txn_id;


			-- RKG End Placeholder
		end if;


        if l_out_fff_result_id is null then
          l_out_fff_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
           l_out_fff_result_id := l_copy_entity_result_id ;
        end if;
        --
     end loop;
     --
---------------------------------------------------------------
-- END OF FF_FORMULAS_F ----------------------
---------------------------------------------------------------
end create_formula_result;
--
procedure create_actn_typ_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_effective_date                 in  date
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_actn_typ_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_cv_result_type_cd   varchar2(30) :=  'DISPLAY' ;
    --
    cursor c_parent_result(c_parent_pk_id number,
                     --   c_parent_table_name varchar2,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe
        -- ,pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = l_cv_result_type_cd
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--     and   cpe.table_route_id = trt.table_route_id
     and   cpe.table_alias = c_parent_table_alias ;
     ---
     --
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     --
     -- Cursor to get table_route_id
     -- cursor c_table_route(c_parent_table_name varchar2) is
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_ACTN_TYP ----------------------
   ---------------------------------------------------------------
   cursor c_eat(c_mirror_src_entity_result_id number ,
                c_table_alias varchar2) is
   select  eat.*
   from BEN_ACTN_TYP eat
   where  eat.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and cpe.table_alias  = c_table_alias
         and information1 = eat.actn_typ_id
        );
    l_actn_typ_id                 number(15);
    l_out_eat_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTN_TYP ----------------------
   ---------------------------------------------------------------
 begin
     ---------------------------------------------------------------
     -- START OF BEN_ACTN_TYP ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := null ; -- Hide in HGrid
        l_number_of_copies := p_number_of_copies;
        --
        l_table_route_id := null ;
        open g_table_route('EAT');
        fetch g_table_route into l_table_route_id ;
        close g_table_route ;

        for l_eat_rec in c_eat(l_mirror_src_entity_result_id,'EAT' ) loop
        --
          --
          l_information5  := l_eat_rec.name;
          --
          l_result_type_cd := 'DISPLAY';
          --
          l_copy_entity_result_id := null;
          l_object_version_number := null;
          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id           => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id      => l_mirror_src_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
            p_information1     => l_eat_rec.actn_typ_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_eat_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information185     => l_eat_rec.description,
            p_information111     => l_eat_rec.eat_attribute1,
            p_information120     => l_eat_rec.eat_attribute10,
            p_information121     => l_eat_rec.eat_attribute11,
            p_information122     => l_eat_rec.eat_attribute12,
            p_information123     => l_eat_rec.eat_attribute13,
            p_information124     => l_eat_rec.eat_attribute14,
            p_information125     => l_eat_rec.eat_attribute15,
            p_information126     => l_eat_rec.eat_attribute16,
            p_information127     => l_eat_rec.eat_attribute17,
            p_information128     => l_eat_rec.eat_attribute18,
            p_information129     => l_eat_rec.eat_attribute19,
            p_information112     => l_eat_rec.eat_attribute2,
            p_information130     => l_eat_rec.eat_attribute20,
            p_information131     => l_eat_rec.eat_attribute21,
            p_information132     => l_eat_rec.eat_attribute22,
            p_information133     => l_eat_rec.eat_attribute23,
            p_information134     => l_eat_rec.eat_attribute24,
            p_information135     => l_eat_rec.eat_attribute25,
            p_information136     => l_eat_rec.eat_attribute26,
            p_information137     => l_eat_rec.eat_attribute27,
            p_information138     => l_eat_rec.eat_attribute28,
            p_information139     => l_eat_rec.eat_attribute29,
            p_information113     => l_eat_rec.eat_attribute3,
            p_information140     => l_eat_rec.eat_attribute30,
            p_information114     => l_eat_rec.eat_attribute4,
            p_information115     => l_eat_rec.eat_attribute5,
            p_information116     => l_eat_rec.eat_attribute6,
            p_information117     => l_eat_rec.eat_attribute7,
            p_information118     => l_eat_rec.eat_attribute8,
            p_information119     => l_eat_rec.eat_attribute9,
            p_information110     => l_eat_rec.eat_attribute_category,
            p_information170     => l_eat_rec.name,
            p_information11     => l_eat_rec.type_cd,
            p_information265     => l_eat_rec.object_version_number,
            --
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_eat_result_id is null then
              l_out_eat_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_eat_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
    ---------------------------------------------------------------
    -- END OF BEN_ACTN_TYP ----------------------
    ---------------------------------------------------------------
 end create_actn_typ_result ;
---------------------------------------------------------------
-- START OF INTERSECTION NAME FUNCTIONS ----------------------
---------------------------------------------------------------

function get_ler_name
  (
   p_ler_id               in  number
  ,p_effective_date       in  date
  ) return varchar2 is

   cursor c_ler_name is
   select ler.name
   from   ben_ler_f ler
   where  ler.ler_id = p_ler_id
   and    p_effective_date between ler.effective_start_date
   and    ler.effective_end_date;

  l_ler_name ben_ler_f.name%type := null;

begin
  open c_ler_name;
  fetch c_ler_name into l_ler_name;
  close c_ler_name;

  return l_ler_name;
end get_ler_name;
--

function get_pgm_name
  (
   p_pgm_id               in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_pgm_name ben_pgm_f.name%type := null;

  cursor c_pgm_name is
  select pgm.name
  from   ben_pgm_f pgm
  where  pgm.pgm_id = p_pgm_id
  and    p_effective_date between pgm.effective_start_date
  and    pgm.effective_end_date;

begin
  open c_pgm_name;
  fetch c_pgm_name into l_pgm_name;
  close c_pgm_name;

  return l_pgm_name;
end get_pgm_name;
--

function get_pl_typ_name
  (
   p_pl_typ_id            in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_pl_typ_name ben_pl_typ_f.name%type := null;

  cursor c_pl_typ_name is
  select ptp.name
  from   ben_pl_typ_f ptp
  where  ptp.pl_typ_id = p_pl_typ_id
  and    p_effective_date between ptp.effective_start_date
  and    ptp.effective_end_date;

begin
  open c_pl_typ_name;
  fetch c_pl_typ_name into l_pl_typ_name;
  close c_pl_typ_name;

  return l_pl_typ_name;
end get_pl_typ_name;
--

function get_pl_name
  (
   p_pl_id                in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_pl_name ben_pl_f.name%type := null;

  cursor c_pl_name is
  select pln.name
  from   ben_pl_f pln
  where  pln.pl_id = p_pl_id
  and    p_effective_date between pln.effective_start_date
  and    pln.effective_end_date;

begin
  open c_pl_name;
  fetch c_pl_name into l_pl_name;
  close c_pl_name;

  return l_pl_name;
end get_pl_name;
--

function get_ptip_name
  (
   p_ptip_id              in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  cursor c_ptip is
  select pgm_id,pl_typ_id
  from   ben_ptip_f ctp
  where ctp.ptip_id = p_ptip_id
  and   p_effective_date between ctp.effective_start_date
        and ctp.effective_end_date;

  l_pgm_id     ben_pgm_f.pgm_id%type;
  l_pl_typ_id  ben_pl_typ_f.pl_typ_id%type;
  l_ptip_name  varchar2(500);

begin

  open c_ptip;
  fetch c_ptip into l_pgm_id, l_pl_typ_id;
  close c_ptip;

  l_ptip_name := get_pgm_name(l_pgm_id,p_effective_date) ||' - '||
                 get_pl_typ_name(l_pl_typ_id,p_effective_date);

  return l_ptip_name;
end get_ptip_name;
--

function get_plip_name
  (
   p_plip_id              in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  cursor c_plip is
  select pgm_id,pl_id
  from   ben_plip_f cpp
  where cpp.plip_id = p_plip_id
  and   p_effective_date between cpp.effective_start_date
        and cpp.effective_end_date;

  l_pgm_id ben_pgm_f.pgm_id%type;
  l_pl_id  ben_pl_f.pl_id%type;
  l_plip_name varchar2(500);

begin

  open c_plip;
  fetch c_plip into l_pgm_id, l_pl_id;
  close c_plip;

  l_plip_name := get_pgm_name(l_pgm_id,p_effective_date) ||' - '||
                 get_pl_name(l_pl_id,p_effective_date);

  return l_plip_name;
end get_plip_name;
--

function get_oipl_name
  (
   p_oipl_id              in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  cursor c_oipl is
  select opt_id,pl_id
  from   ben_oipl_f cop
  where cop.oipl_id = p_oipl_id
  and   p_effective_date between cop.effective_start_date
        and cop.effective_end_date;

  l_opt_id ben_opt_f.opt_id%type;
  l_pl_id  ben_pl_f.pl_id%type;
  l_oipl_name varchar2(500);

begin

  open c_oipl;
  fetch c_oipl into l_opt_id, l_pl_id;
  close c_oipl;

  l_oipl_name := get_pl_name(l_pl_id,p_effective_date) ||' - '||
                 get_opt_name(l_opt_id,p_effective_date);

  return l_oipl_name;
end get_oipl_name;
--

function get_opt_name
  (
   p_opt_id               in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_opt_name ben_opt_f.name%type := null;

  cursor c_opt_name is
  select opt.name
  from   ben_opt_f opt
  where  opt.opt_id = p_opt_id
  and    p_effective_date between opt.effective_start_date
  and    opt.effective_end_date;

begin
  open c_opt_name;
  fetch c_opt_name into l_opt_name;
  close c_opt_name;

  return l_opt_name;
end get_opt_name;
--

function get_regn_name
  (
   p_regn_id              in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_regn_name ben_regn_f.name%type := null;

  cursor c_regn_name is
  select reg.name
  from   ben_regn_f reg
  where  reg.regn_id = p_regn_id
  and    p_effective_date between reg.effective_start_date
  and    reg.effective_end_date;

begin
  open c_regn_name;
  fetch c_regn_name into l_regn_name;
  close c_regn_name;

  return l_regn_name;
end get_regn_name;
--

function get_gd_or_svc_typ_name
  (
   p_gd_or_svc_typ_id     in  number
  ) return varchar2 is

  l_gd_or_svc_typ_name ben_gd_or_svc_typ.name%type := null;

  cursor c_gd_or_svc_typ_name is
  select gos.name
  from   ben_gd_or_svc_typ gos
  where  gos.gd_or_svc_typ_id = p_gd_or_svc_typ_id;

begin
  open c_gd_or_svc_typ_name;
  fetch c_gd_or_svc_typ_name into l_gd_or_svc_typ_name;
  close c_gd_or_svc_typ_name;

  return l_gd_or_svc_typ_name;
end get_gd_or_svc_typ_name;
--

function get_actn_typ_name
  (
   p_actn_typ_id     in  number
  ) return varchar2 is

  l_actn_typ_name ben_actn_typ.name%type := null;

  cursor c_actn_typ_name is
  select eat.name
  from   ben_actn_typ eat
  where  eat.actn_typ_id = p_actn_typ_id;

begin
  open c_actn_typ_name;
  fetch c_actn_typ_name into l_actn_typ_name;
  close c_actn_typ_name;

  return l_actn_typ_name;
end get_actn_typ_name;
--

function get_formula_name
  (
   p_formula_id       in  number
  ,p_effective_date   in date
  ) return varchar2 is

  l_formula_name ff_formulas_f.formula_name%type := null;

  cursor c_formula_name is
  select ff.formula_name
  from   ff_formulas_f ff
  where  ff.formula_id = p_formula_id
  and    p_effective_date between ff.effective_start_date
  and    ff.effective_end_date;
begin
  open c_formula_name;
  fetch c_formula_name into l_formula_name;
  close c_formula_name;

  return l_formula_name;
end get_formula_name;
--

function get_organization_name
  (
   p_organization_id       in  number
  ) return varchar2 is

  l_organization_name hr_all_organization_units_vl.name%type := null;

  cursor c_organization_name is
  select org.name
  from   hr_all_organization_units_vl org
  where  org.organization_id = p_organization_id;

begin
  open c_organization_name;
  fetch c_organization_name into l_organization_name;
  close c_organization_name;

  return l_organization_name;
end get_organization_name;
--

function get_yr_perd_name
  (
   p_yr_perd_id       in  number
  ) return varchar2 is

  l_yr_perd_name varchar2(50) := null;

  cursor c_yr_perd_name is
  select TO_CHAR(yrp.start_date,'DD-Mon-YYYY')||' -  '||
         TO_CHAR(yrp.end_date,'DD-Mon-YYYY')
  from   ben_yr_perd yrp
  where  yrp.yr_perd_id = p_yr_perd_id;

begin
  open c_yr_perd_name;
  fetch c_yr_perd_name into l_yr_perd_name;
  close c_yr_perd_name;

  return l_yr_perd_name;
end get_yr_perd_name;
--

function get_rptg_grp_name
  (
   p_rptg_grp_id     in  number
  ) return varchar2 is

  l_rptg_grp_name ben_rptg_grp.name%type := null;

  cursor c_rptg_grp_name is
  select bnr.name
  from   ben_rptg_grp bnr
  where  bnr.rptg_grp_id = p_rptg_grp_id;

begin
  open c_rptg_grp_name;
  fetch c_rptg_grp_name into l_rptg_grp_name;
  close c_rptg_grp_name;

  return l_rptg_grp_name;
end get_rptg_grp_name;
--

function get_per_info_chg_cs_ler_name
  (
   p_per_info_chg_cs_ler_id   in  number
  ,p_effective_date           in  date
  ) return varchar2 is

  l_per_info_chg_cs_ler_name ben_per_info_chg_cs_ler_f.name%type := null;

  cursor c_per_info_chg_cs_ler_name is
  select psl.name
  from   ben_per_info_chg_cs_ler_f psl
  where  psl.per_info_chg_cs_ler_id = p_per_info_chg_cs_ler_id
  and    p_effective_date between psl.effective_start_date
  and    psl.effective_end_date;

begin
  open c_per_info_chg_cs_ler_name;
  fetch c_per_info_chg_cs_ler_name into l_per_info_chg_cs_ler_name;
  close c_per_info_chg_cs_ler_name;

  return l_per_info_chg_cs_ler_name;
end get_per_info_chg_cs_ler_name;
--

function get_rltd_per_chg_cs_ler_name
  (
   p_rltd_per_chg_cs_ler_id   in  number
  ,p_effective_date           in  date
  ) return varchar2 is

  l_rltd_per_chg_cs_ler_name ben_rltd_per_chg_cs_ler_f.name%type := null;

  cursor c_rltd_per_chg_cs_ler_name is
  select rcl.name
  from   ben_rltd_per_chg_cs_ler_f rcl
  where  rcl.rltd_per_chg_cs_ler_id = p_rltd_per_chg_cs_ler_id
  and    p_effective_date between rcl.effective_start_date
  and    rcl.effective_end_date;

begin
  open c_rltd_per_chg_cs_ler_name;
  fetch c_rltd_per_chg_cs_ler_name into l_rltd_per_chg_cs_ler_name;
  close c_rltd_per_chg_cs_ler_name;

  return l_rltd_per_chg_cs_ler_name;
end get_rltd_per_chg_cs_ler_name;
--

function get_oiplip_name
  (
   p_oipl_id              in  number
  ,p_plip_id              in number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_oipl_name varchar2(500) := null;

begin

  l_oipl_name := get_oipl_name(p_oipl_id,p_effective_date);
  return l_oipl_name;

end get_oiplip_name;
--

function get_optip_name
  (
   p_opt_id              in  number
  ,p_pl_typ_id           in number
  ,p_effective_date      in  date
  ) return varchar2 is

  l_pl_typ_name ben_pl_typ_f.name%type;
  l_opt_name    ben_opt_f.name%type;

begin
  l_opt_name := get_opt_name(p_opt_id,p_effective_date);
  l_pl_typ_name := get_pl_typ_name(p_pl_typ_id,p_effective_date);

  return l_pl_typ_name ||' - '||l_opt_name;

end get_optip_name;
--

function get_ptd_lmt_name
  (
   p_ptd_lmt_id           in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_ptd_lmt_name ben_ptd_lmt_f.name%type := null;

  cursor c_ptd_lmt_name is
  select pdl.name
  from   ben_ptd_lmt_f pdl
  where  pdl.ptd_lmt_id = p_ptd_lmt_id
  and    p_effective_date between pdl.effective_start_date
  and    pdl.effective_end_date;

begin
  open c_ptd_lmt_name;
  fetch c_ptd_lmt_name into l_ptd_lmt_name;
  close c_ptd_lmt_name;

  return l_ptd_lmt_name;
end get_ptd_lmt_name;
--

function get_vrbl_rt_prfl_name
  (
   p_vrbl_rt_prfl_id      in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_vrbl_rt_prfl_name ben_vrbl_rt_prfl_f.name%type := null;

  cursor c_vrbl_rt_prfl_name is
  select vpf.name
  from   ben_vrbl_rt_prfl_f vpf
  where  vpf.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
  and    p_effective_date between vpf.effective_start_date
  and    vpf.effective_end_date;

begin
  open c_vrbl_rt_prfl_name;
  fetch c_vrbl_rt_prfl_name into l_vrbl_rt_prfl_name;
  close c_vrbl_rt_prfl_name;

  return l_vrbl_rt_prfl_name;
end get_vrbl_rt_prfl_name;
--

function get_age_fctr_name
  (
   p_age_fctr_id     in  number
  ) return varchar2 is

  l_age_fctr_name ben_age_fctr.name%type := null;

  cursor c_age_fctr_name is
  select agf.name
  from   ben_age_fctr agf
  where  agf.age_fctr_id = p_age_fctr_id;

begin
  open c_age_fctr_name;
  fetch c_age_fctr_name into l_age_fctr_name;
  close c_age_fctr_name;

  return l_age_fctr_name;
end get_age_fctr_name;
--

function get_assignment_set_name
  (
   p_assignment_set_id     in  number
  ) return varchar2 is

  l_assignment_set_name hr_assignment_sets.assignment_set_name%type := null;

  cursor c_assignment_set_name is
  select ast.assignment_set_name
  from   hr_assignment_sets ast
  where  ast.assignment_set_id = p_assignment_set_id;

begin
  open c_assignment_set_name;
  fetch c_assignment_set_name into l_assignment_set_name;
  close c_assignment_set_name;

  return l_assignment_set_name;
end get_assignment_set_name;
--

function get_benfts_grp_name
  (
   p_benfts_grp_id     in  number
  ) return varchar2 is

  l_benfts_grp_name ben_benfts_grp.name%type := null;

  cursor c_benfts_grp_name is
  select bng.name
  from   ben_benfts_grp bng
  where  bng.benfts_grp_id = p_benfts_grp_id;

begin
  open c_benfts_grp_name;
  fetch c_benfts_grp_name into l_benfts_grp_name;
  close c_benfts_grp_name;

  return l_benfts_grp_name;
end get_benfts_grp_name;
--

function get_cmbn_age_los_fctr_name
  (
   p_cmbn_age_los_fctr_id     in  number
  ) return varchar2 is

  l_cmbn_age_los_fctr_name ben_cmbn_age_los_fctr.name%type := null;

  cursor c_cmbn_age_los_fctr_name is
  select cla.name
  from   ben_cmbn_age_los_fctr cla
  where  cla.cmbn_age_los_fctr_id = p_cmbn_age_los_fctr_id;

begin
  open c_cmbn_age_los_fctr_name;
  fetch c_cmbn_age_los_fctr_name into l_cmbn_age_los_fctr_name;
  close c_cmbn_age_los_fctr_name;

  return l_cmbn_age_los_fctr_name;
end get_cmbn_age_los_fctr_name;
--

function get_comp_lvl_fctr_name
  (
   p_comp_lvl_fctr_id     in  number
  ) return varchar2 is

  l_comp_lvl_fctr_name ben_comp_lvl_fctr.name%type := null;

  cursor c_comp_lvl_fctr_name is
  select clf.name
  from   ben_comp_lvl_fctr clf
  where  clf.comp_lvl_fctr_id = p_comp_lvl_fctr_id;

begin
  open c_comp_lvl_fctr_name;
  fetch c_comp_lvl_fctr_name into l_comp_lvl_fctr_name;
  close c_comp_lvl_fctr_name;

  return l_comp_lvl_fctr_name;
end get_comp_lvl_fctr_name;
--
--BUG 4156088
--
function get_assignment_sts_type_name
  (
   p_assignment_status_type_id     in  number
  ) return varchar2 is
  --
  l_assignment_status_type_name per_assignment_status_types_tl.user_status%type := null;
  --
  cursor c_assignment_status_type_name is
  select nvl(atl.user_status,stl.user_status) user_status
  from   per_assignment_status_types s,
         per_ass_status_type_amends a ,
         per_assignment_status_types_tl stl,
         per_ass_status_type_amends_tl atl
  where  s.assignment_status_type_id = p_assignment_status_type_id
  and    a.assignment_status_type_id (+) = s.assignment_status_type_id
  and    s.active_flag = 'Y'
  and    a.active_flag(+) = 'Y'
  and    atl.ass_status_type_amend_id (+) = a.ass_status_type_amend_id
  and    atl.language (+) = userenv('LANG')
  and    stl.assignment_status_type_id = s.assignment_status_type_id
  and    stl.language  = userenv('LANG');
  --
begin
  open c_assignment_status_type_name;
  fetch c_assignment_status_type_name into l_assignment_status_type_name;
  close c_assignment_status_type_name;

  return l_assignment_status_type_name;
end get_assignment_sts_type_name;
--

function get_grade_name
  (
   p_grade_id     in  number
  ) return varchar2 is

  l_grade_name per_grades_vl.name%type := null;

  cursor c_grade_name is
  select grd.name
  from   per_grades_vl grd
  where  grd.grade_id = p_grade_id;

begin
  open c_grade_name;
  fetch c_grade_name into l_grade_name;
  close c_grade_name;

  return l_grade_name;
end get_grade_name;
--

function get_hrs_wkd_in_perd_fctr_name
  (
   p_hrs_wkd_in_perd_fctr_id     in  number
  ) return varchar2 is

  l_hrs_wkd_in_perd_fctr_name ben_hrs_wkd_in_perd_fctr.name%type := null;

  cursor c_hrs_wkd_in_perd_fctr_name is
  select hwf.name
  from   ben_hrs_wkd_in_perd_fctr hwf
  where  hwf.hrs_wkd_in_perd_fctr_id = p_hrs_wkd_in_perd_fctr_id;

begin
  open c_hrs_wkd_in_perd_fctr_name;
  fetch c_hrs_wkd_in_perd_fctr_name into l_hrs_wkd_in_perd_fctr_name;
  close c_hrs_wkd_in_perd_fctr_name;

  return l_hrs_wkd_in_perd_fctr_name;
end get_hrs_wkd_in_perd_fctr_name;
--

function get_lbr_mmbr_name
  (
   p_lbr_mmbr_flag     in  varchar2
  ) return varchar2 is

  l_lbr_mmbr_name hr_lookups.meaning%type;

begin

  l_lbr_mmbr_name := hr_general.decode_lookup('YES_NO',p_lbr_mmbr_flag);

  return l_lbr_mmbr_name;

end get_lbr_mmbr_name;
--

function get_absence_type_name
  (
   p_absence_attendance_type_id     in  number
  ) return varchar2 is

  l_absence_type_name per_absence_attendance_types.name%type := null;

  cursor c_absence_type_name is
  select aat.name
  from   per_absence_attendance_types aat
  where  aat.absence_attendance_type_id = p_absence_attendance_type_id;

begin
  open c_absence_type_name;
  fetch c_absence_type_name into l_absence_type_name;
  close c_absence_type_name;

  return l_absence_type_name;
end get_absence_type_name;
--

function get_los_fctr_name
  (
   p_los_fctr_id     in  number
  ) return varchar2 is

  l_los_fctr_name ben_los_fctr.name%type := null;

  cursor c_los_fctr_name is
  select lsf.name
  from   ben_los_fctr lsf
  where  lsf.los_fctr_id = p_los_fctr_id;

begin
  open c_los_fctr_name;
  fetch c_los_fctr_name into l_los_fctr_name;
  close c_los_fctr_name;

  return l_los_fctr_name;
end get_los_fctr_name;
--

function get_pct_fl_tm_fctr_name
  (
   p_pct_fl_tm_fctr_id     in  number
  ) return varchar2 is

  l_pct_fl_tm_fctr_name ben_pct_fl_tm_fctr.name%type := null;

  cursor c_pct_fl_tm_fctr_name is
  select pff.name
  from   ben_pct_fl_tm_fctr pff
  where  pff.pct_fl_tm_fctr_id = p_pct_fl_tm_fctr_id;

begin
  open c_pct_fl_tm_fctr_name;
  fetch c_pct_fl_tm_fctr_name into l_pct_fl_tm_fctr_name;
  close c_pct_fl_tm_fctr_name;

  return l_pct_fl_tm_fctr_name;
end get_pct_fl_tm_fctr_name;
--

function get_person_type_name
  (
   p_person_type_id     in  number
  ) return varchar2 is

  l_person_type_name per_person_types_tl.user_person_type%type := null;

  cursor c_person_type_name is
  select pty.user_person_type
  from   per_person_types_tl pty
  where  pty.person_type_id = p_person_type_id
  and    pty.language = userenv('LANG');

begin
  open c_person_type_name;
  fetch c_person_type_name into l_person_type_name;
  close c_person_type_name;

  return l_person_type_name;
end get_person_type_name;
--

function get_people_group_name
  (
   p_people_group_id     in  number
  ) return varchar2 is

  l_people_group_name pay_people_groups.group_name%type := null;

  cursor c_people_group_name is
  select nvl(ppg.group_name,segment1) name
  from   pay_people_groups ppg
  where  ppg.people_group_id = p_people_group_id;

begin
  open c_people_group_name;
  fetch c_people_group_name into l_people_group_name;
  close c_people_group_name;

  return l_people_group_name;
end get_people_group_name;
--

function get_pstl_zip_rng_name
  (
   p_pstl_zip_rng_id     in  number
  ,p_effective_date      in date
  ) return varchar2 is

  l_pstl_zip_rng_name varchar2(200):= null;

  cursor c_pstl_zip_rng_name is
  select rzr.from_value ||' - '||rzr.to_value
  from   ben_pstl_zip_rng_f rzr
  where  rzr.pstl_zip_rng_id = p_pstl_zip_rng_id
  and    p_effective_date between rzr.effective_start_date
  and    rzr.effective_end_date;

begin
  open c_pstl_zip_rng_name;
  fetch c_pstl_zip_rng_name into l_pstl_zip_rng_name;
  close c_pstl_zip_rng_name;

  return l_pstl_zip_rng_name;
end get_pstl_zip_rng_name;
--

function get_payroll_name
  (
   p_payroll_id          in  number
  ,p_effective_date      in date
  ) return varchar2 is

  l_payroll_name pay_all_payrolls_f.payroll_name%type := null;

  cursor c_payroll_name is
  select prl.payroll_name
  from   pay_all_payrolls_f prl
  where  prl.payroll_id = p_payroll_id
  and    p_effective_date between prl.effective_start_date
  and    prl.effective_end_date;

begin
  open c_payroll_name;
  fetch c_payroll_name into l_payroll_name;
  close c_payroll_name;

  return l_payroll_name;
end get_payroll_name;
--

function get_pay_basis_name
  (
   p_pay_basis_id          in  number
  ) return varchar2 is

  l_pay_basis_name per_pay_bases.name%type := null;

  cursor c_pay_basis_name is
  select pba.name
  from   per_pay_bases pba
  where  pba.pay_basis_id = p_pay_basis_id;

begin
  open c_pay_basis_name;
  fetch c_pay_basis_name into l_pay_basis_name;
  close c_pay_basis_name;

  return l_pay_basis_name;
end get_pay_basis_name;
--

function get_svc_area_name
  (
   p_svc_area_id          in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_svc_area_name ben_svc_area_f.name%type := null;

  cursor c_svc_area_name is
  select sva.name
  from   ben_svc_area_f sva
  where  sva.svc_area_id = p_svc_area_id
  and    p_effective_date between sva.effective_start_date
  and    sva.effective_end_date;

begin
  open c_svc_area_name;
  fetch c_svc_area_name into l_svc_area_name;
  close c_svc_area_name;

  return l_svc_area_name;
end get_svc_area_name;
--

function get_location_name
  (
   p_location_id          in  number
  ) return varchar2 is

  l_location_name hr_locations.location_code%type := null;

  cursor c_location_name is
  select loc.location_code
  from   hr_locations loc
  where  loc.location_id = p_location_id;

begin
  open c_location_name;
  fetch c_location_name into l_location_name;
  close c_location_name;

  return l_location_name;
end get_location_name;
--

function get_acty_base_rt_name
  (
   p_acty_base_rt_id      in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_acty_base_rt_name ben_acty_base_rt_f.name%type := null;

  cursor c_acty_base_rt_name is
  select abr.name
  from   ben_acty_base_rt_f abr
  where  abr.acty_base_rt_id = p_acty_base_rt_id
  and    p_effective_date between abr.effective_start_date
  and    abr.effective_end_date;

begin
  open c_acty_base_rt_name;
  fetch c_acty_base_rt_name into l_acty_base_rt_name;
  close c_acty_base_rt_name;

  return l_acty_base_rt_name;
end get_acty_base_rt_name;
--

function get_eligy_prfl_name
  (
   p_eligy_prfl_id        in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_eligy_prfl_name ben_eligy_prfl_f.name%type := null;

  cursor c_eligy_prfl_name is
  select elp.name
  from   ben_eligy_prfl_f elp
  where  elp.eligy_prfl_id = p_eligy_prfl_id
  and    p_effective_date between elp.effective_start_date
  and    elp.effective_end_date;

begin
  open c_eligy_prfl_name;
  fetch c_eligy_prfl_name into l_eligy_prfl_name;
  close c_eligy_prfl_name;

  return l_eligy_prfl_name;
end get_eligy_prfl_name;
--

function get_cbr_quald_bnf_name
  (
   p_ptip_id              in  number
  ,p_pgm_id               in  number
  ,p_effective_date       in  date
  ) return varchar2 is

  l_name      varchar2(500) := null;

begin

  if p_ptip_id is not null then
    l_name := get_ptip_name(p_ptip_id,p_effective_date);

  elsif p_pgm_id is not null then
     l_name := get_pgm_name(p_pgm_id,p_effective_date);

  end if;
  return l_name;
end get_cbr_quald_bnf_name;
--

function get_job_name
  (
   p_job_id        in  number
  ) return varchar2 is

  l_job_name per_jobs_vl.name%type := null;

  cursor c_job_name is
  select job.name
  from   per_jobs_vl job
  where  job.job_id = p_job_id;

begin
  open c_job_name;
  fetch c_job_name into l_job_name;
  close c_job_name;

  return l_job_name;
end get_job_name;
--

function get_sp_clng_step_name
  (
   p_special_ceiling_step_id   in  number
  ,p_effective_date            in date
  ) return varchar2 is

  l_sp_clng_step_name   varchar2(800) := null;

  cursor c_sp_clng_step_name is
  select a.name ||b.name ||c.spinal_point name
  from per_grades_vl a, per_parent_spines b, per_spinal_points c,
       per_spinal_point_steps_f d, per_grade_spines e
  where d.step_id = p_special_ceiling_step_id
  and   d.spinal_point_id = c.spinal_point_id
  and   d.grade_spine_id  = e.grade_spine_id
  and   e.grade_id  = a.grade_id
  and   e.parent_spine_id = b.parent_spine_id
  and   p_effective_date between d.effective_start_date
        and d.effective_end_date;

begin
  open c_sp_clng_step_name;
  fetch c_sp_clng_step_name into l_sp_clng_step_name;
  close c_sp_clng_step_name;

  return l_sp_clng_step_name;
end get_sp_clng_step_name;
--

function get_position_name
  (
   p_position_id        in  number
  ) return varchar2 is

  l_position_name per_positions.name%type := null;

  cursor c_position_name is
  select pos.name
  from   per_positions pos
  where  pos.position_id = p_position_id;

begin
  open c_position_name;
  fetch c_position_name into l_position_name;
  close c_position_name;

  return l_position_name;
end get_position_name;
--

function get_qual_type_name
  (
   p_qualification_type_id         in  number
  ) return varchar2 is

  l_qual_type_name per_qualification_types_vl.name%type := null;

  cursor c_qual_type_name is
  select pqt.name
  from   per_qualification_types_vl pqt
  where  pqt.qualification_type_id = p_qualification_type_id;

begin
  open c_qual_type_name;
  fetch c_qual_type_name into l_qual_type_name;
  close c_qual_type_name;

  return l_qual_type_name;
end get_qual_type_name;
--

function get_dpnt_cvg_eligy_prfl_name
  (
   p_dpnt_cvg_eligy_prfl_id        in  number
  ,p_effective_date                in  date
  ) return varchar2 is

  l_dpnt_cvg_eligy_prfl_name ben_dpnt_cvg_eligy_prfl_f.name%type := null;

  cursor c_dpnt_cvg_eligy_prfl_name is
  select dce.name
  from   ben_dpnt_cvg_eligy_prfl_f dce
  where  dce.dpnt_cvg_eligy_prfl_id = p_dpnt_cvg_eligy_prfl_id
  and    p_effective_date between dce.effective_start_date
  and    dce.effective_end_date;

begin
  open c_dpnt_cvg_eligy_prfl_name;
  fetch c_dpnt_cvg_eligy_prfl_name into l_dpnt_cvg_eligy_prfl_name;
  close c_dpnt_cvg_eligy_prfl_name;

  return l_dpnt_cvg_eligy_prfl_name;
end get_dpnt_cvg_eligy_prfl_name;
--
function get_competence_rating_name
  (
   p_competence_id        in  number
  ,p_rating_level_id      in number
  ) return varchar2 is

  l_competence_name per_competences_vl.name%type := null;
  l_rating_level_name per_rating_levels_vl.name%type := null;

  cursor c_competence_name is
  select pco.name
  from   per_competences_vl pco
  where  pco.competence_id = p_competence_id;

  cursor c_rating_level_name is
  select rtl.name
  from   per_rating_levels_vl rtl
  where  rtl.rating_level_id = p_rating_level_id;
begin
  open c_competence_name;
  fetch c_competence_name into l_competence_name;
  close c_competence_name;

  open c_rating_level_name;
  fetch c_rating_level_name into l_rating_level_name;
  close c_rating_level_name;

  return l_competence_name ||' - '||l_rating_level_name;
end get_competence_rating_name;
--

function get_hlth_cvg_name
  (
   p_pl_typ_opt_typ_id   in  number
  ,p_oipl_id             in  number
  ,p_effective_date      in  date
  ) return varchar2 is

  cursor c_pl_typ_opt_typ is
  select pon.pl_typ_id
        ,pon.opt_id
  from   ben_pl_typ_opt_typ_f pon
  where  pon.pl_typ_opt_typ_id = p_pl_typ_opt_typ_id
  and    p_effective_date between pon.effective_start_date
  and    pon.effective_end_date;

  cursor c_oipl is
  select pl_id
  from ben_oipl_f cop
  where cop.oipl_id = p_oipl_id
  and   p_effective_date between cop.effective_start_date
  and   cop.effective_end_date;

  l_pl_typ_name ben_pl_typ_f.name%type;
  l_opt_name    ben_opt_f.name%type;
  l_pl_name     ben_pl_f.name%type;
  l_pl_typ_id   ben_pl_typ_f.pl_typ_id%type;
  l_opt_id      ben_opt_f.opt_id%type;
  l_pl_id       ben_pl_f.pl_id%type;

begin

  open c_pl_typ_opt_typ;
  fetch c_pl_typ_opt_typ into l_pl_typ_id, l_opt_id;
  close c_pl_typ_opt_typ;

  open c_oipl;
  fetch c_oipl into l_pl_id;
  close c_oipl;

  l_opt_name := get_opt_name(l_opt_id,p_effective_date);
  l_pl_typ_name := get_pl_typ_name(l_pl_typ_id,p_effective_date);
  l_pl_name := get_pl_name(l_pl_id,p_effective_date);

  return l_pl_typ_name ||' - '||l_opt_name ||' - '||l_pl_name;

end get_hlth_cvg_name;
--
-- Bug 4169120 : Rate By Criteria
--
function get_eligy_criteria_name
          (
           p_eligy_criteria_id   in  number
          ) return varchar2 is
  --
  cursor c_egl is
     select egl.name
       from ben_eligy_criteria egl
      where egl.eligy_criteria_id = p_eligy_criteria_id;
  --
  l_eligy_criteria_name       varchar2(240);
  --
begin
  --
  open c_egl;
    --
    fetch c_egl into l_eligy_criteria_name;
    --
  close c_egl;
  --
  return l_eligy_criteria_name;
  --
end;
--

function get_exclude_message
  (
   p_excld_flag in varchar2
  ) return varchar2 is
  l_exclude_message fnd_new_messages.message_text%type := null;
begin

  if p_excld_flag = 'Y' then
   l_exclude_message := fnd_message.get_string('BEN','BEN_93294_PDC_EXCLUDE_FLAG');
  end if;

  return l_exclude_message;
end get_exclude_message;

---------------------------------------------------------------
-- END OF INTERSECTION NAME FUNCTIONS ----------------------
---------------------------------------------------------------
end ben_plan_design_program_module;

/
