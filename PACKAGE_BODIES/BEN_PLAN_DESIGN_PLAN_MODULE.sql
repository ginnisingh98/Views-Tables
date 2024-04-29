--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_PLAN_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_PLAN_MODULE" as
/* $Header: bepdcpln.pkb 120.5 2006/12/04 09:49:35 vborkar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_plan_design_plan_module.';
--
-- This procedure is used to create a row for each of the comp objects
-- selected by the end user on search page into
-- pqh_copy_entity_txn table.
-- This procedure should also copy all the child table data into
-- above table as well.
--

procedure create_plan_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_plip_id                        in  number    default null
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
  l_proc varchar2(72) := g_package||'create_copy_entity_result';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
   --

  cursor c_pln_from_parent(c_PLIP_ID number,c_pl_id number ) is
   select  distinct pln.pl_id,
           null  Information8
   from BEN_PLIP_F plip,
        BEN_PL_F PLN
   where ( C_PLIP_ID is not null and plip.PLIP_ID = C_PLIP_ID )
   and   plip.pl_id=pln.pl_id
   union
   select  distinct pln.pl_id,
           'PLNIP' Information8
   from BEN_PL_F PLN
   where ( C_PL_ID is not null and pln.PL_ID = C_PL_ID);

/*
   cursor c_pln_from_parent(c_PLIP_ID number,c_pl_id number ) is
   select  pln.pl_id,
           ptp.name pl_typ_name,
           hl.meaning Plan_Usage,
           null  Information8
   from BEN_PLIP_F plip,
        BEN_PL_F PLN,
        ben_pl_typ_f ptp,
        hr_lookups hl
   where ( C_PLIP_ID is not null and plip.PLIP_ID = C_PLIP_ID )
   and   plip.pl_id=pln.pl_id
   and   pln.pl_typ_id = ptp.pl_typ_id
   and   pln.pl_cd = hl.lookup_code
   and   hl.lookup_type = 'BEN_PL'
   union
   select  pln.pl_id,
           ptp.name pl_typ_name,
           hl.meaning Plan_Usage,
           'PLNIP' Information8
   from BEN_PL_F PLN,
        ben_pl_typ_f ptp,
        hr_lookups hl
   where ( C_PL_ID is not null and pln.PL_ID = C_PL_ID )
   and   pln.pl_typ_id = ptp.pl_typ_id
   and   pln.pl_cd = hl.lookup_code
   and   hl.lookup_type = 'BEN_PL' ;
  */
   --
   cursor c_pln(c_pl_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  pln.*
   from BEN_PL_F pln
   where  pln.pl_id = c_pl_id
     -- and pln.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--         	  ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_id
           -- and information4 = pln.business_group_id
           and information2 = pln.effective_start_date
           and information3 = pln.effective_end_date
     );

   l_cv_result_type_cd   varchar2(30) :=  'DISPLAY' ;
   --
   -- Cursor to get mirror_src_entity_result_id
   cursor c_parent_result(c_parent_pk_id number,
                        -- c_parent_table_name varchar2,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
   select copy_entity_result_id mirror_src_entity_result_id
   from ben_copy_entity_results cpe
--        ,pqh_table_route trt
   where cpe.information1= c_parent_pk_id
   and   cpe.result_type_cd = l_cv_result_type_cd
   and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and   cpe.table_route_id = trt.table_route_id
   -- and   trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name)
   and   cpe.table_alias = c_parent_table_alias ;
   ---

   cursor c_parent_result1(c_parent_pk_id number,
                           c_parent_table_alias varchar2,
                           c_copy_entity_txn_id number) is
   select min(copy_entity_result_id) mirror_src_entity_result_id
   from ben_copy_entity_results cpe
 --       ,pqh_table_route trt
   where cpe.information1= c_parent_pk_id
   and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and   cpe.table_route_id = trt.table_route_id
   and   cpe.table_alias = c_parent_table_alias ;

   --
   -- Bug : 3752407 : Global cursor g_table_route will now be used
   --
   -- Cursor to get table_route_id
   -- cursor c_table_route(c_parent_table_alias varchar2)is
   -- select table_route_id
   -- from pqh_table_route trt
   -- where  trt.table_alias = c_parent_table_alias;
   -- trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name) ;
   ---

   -- Cursor to get parent record's effective_start_date
   -- to be stored for non date-tracked child records
   cursor c_parent_esd(c_parent_pk_id number,
                       -- c_parent_table_name varchar2,
                       c_parent_table_alias varchar2,
                       c_copy_entity_txn_id number) is
   select min(cpe.information2) min_esd
   from   ben_copy_entity_results cpe
--          ,pqh_table_route trt
   where  cpe.information1= c_parent_pk_id
   and    cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and    cpe.table_route_id = trt.table_route_id
   -- and    trt.from_clause = 'OAB'
   -- and    trt.where_clause = upper(c_parent_table_name);
   and    cpe.table_alias = c_parent_table_alias;

   --
   --Mapping for CWB Group_pl_id
   --
   cursor c_grp_pl_name (p_group_pl_id in number) is
   select name group_pl_name
   from ben_pl_f
   where pl_id = p_group_pl_id
     and p_effective_date between effective_start_date and effective_end_date;

   l_mapping_id         number;
   l_mapping_name       varchar2(600);
   l_mapping_column_name1 pqh_attributes.attribute_name%type;
   l_mapping_column_name2 pqh_attributes.attribute_name%type;

   -- Mapping end for CWB

   l_pln_esd ben_pl_f.effective_start_date%type;

   ---------------------------------------------------------------
   -- START OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------
   cursor c_ptp_from_parent(c_PL_ID number) is
   select  pl_typ_id
   from BEN_PL_F
   where  PL_ID = c_PL_ID ;
   --

   l_pl_typ_id                 number(15);
   l_out_ptp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------
   cursor c_vgs_from_parent(c_PL_ID number) is
   select  pl_gd_or_svc_id
   from BEN_PL_GD_OR_SVC_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_vgs(c_pl_gd_or_svc_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  vgs.*
   from BEN_PL_GD_OR_SVC_F vgs
   where  vgs.pl_gd_or_svc_id = c_pl_gd_or_svc_id
     -- and vgs.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_GD_OR_SVC_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_gd_or_svc_id
           -- and information4 = vgs.business_group_id
           and information2 = vgs.effective_start_date
           and information3 = vgs.effective_end_date
     );

   l_out_vgs_result_id   number(15);
   --
---------------------------------------------------------------
-- START OF BEN_CWB_WKSHT_GRP ----------------------
---------------------------------------------------------------
   cursor c_cwg_from_parent(c_PL_ID number) is
   select  cwb_wksht_grp_id
   from BEN_CWB_WKSHT_GRP
   where  PL_ID = c_PL_ID ;
   --
   cursor c_cwg(c_cwb_wksht_grp_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  cwg.*
   from BEN_CWB_WKSHT_GRP cwg
   where  cwg.cwb_wksht_grp_id = c_cwb_wksht_grp_id
     and cwg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( --c_mirror_src_entity_result_id is null or
               c_mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CWB_WKSHT_GRP'
         and cpe.table_alias = c_table_alias
         and information1 = c_cwb_wksht_grp_id
         --and information4 = cwg.business_group_id
        );

cursor c_cri(c_cwb_wksht_grp_id number, c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
select cri.*
from BEN_CUSTOM_REGION_ITEMS cri
where cri.custom_key = to_char(c_cwb_wksht_grp_id)
  and cri.custom_type like 'Cwb%PG'
  and not exists (
	select /*+  */ null
         from ben_copy_entity_results cpe
         where copy_entity_txn_id = p_copy_entity_txn_id
         and (c_mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         and cpe.table_alias = c_table_alias
         and information1 = c_cwb_wksht_grp_id
        );

    l_cwb_wksht_grp_id                 number(15);
    l_cri_information5              ben_copy_entity_results.information5%type;
    l_cri_result_type_cd            varchar2(30);
    l_out_cri_result_id   number(15);
    l_out_cwg_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_CWB_WKSHT_GRP ----------------------
---------------------------------------------------------------

---------------------------------------------------------------
-- START OF BEN_VALD_RLSHP_FOR_REIMB_F ----------------------
---------------------------------------------------------------
   cursor c_vrp_from_parent(c_PL_ID number) is
   select  vald_rlshp_for_reimb_id
   from BEN_VALD_RLSHP_FOR_REIMB_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_vrp(c_vald_rlshp_for_reimb_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  vrp.*
   from BEN_VALD_RLSHP_FOR_REIMB_F vrp
   where  vrp.vald_rlshp_for_reimb_id = c_vald_rlshp_for_reimb_id
     -- and vrp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause ='BEN_VALD_RLSHP_FOR_REIMB_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_vald_rlshp_for_reimb_id
           -- and information4 = vrp.business_group_id
           and information2 = vrp.effective_start_date
           and information3 = vrp.effective_end_date
     );

    l_out_vrp_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_VALD_RLSHP_FOR_REIMB_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_WV_PRTN_RSN_PL_F ----------------------
---------------------------------------------------------------
   cursor c_wpn_from_parent(c_PL_ID number) is
   select  wv_prtn_rsn_pl_id
   from BEN_WV_PRTN_RSN_PL_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_wpn(c_wv_prtn_rsn_pl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  wpn.*
   from BEN_WV_PRTN_RSN_PL_F wpn
   where  wpn.wv_prtn_rsn_pl_id = c_wv_prtn_rsn_pl_id
     -- and wpn.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_WV_PRTN_RSN_PL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_wv_prtn_rsn_pl_id
           -- and information4 = wpn.business_group_id
           and information2 = wpn.effective_start_date
           and information3 = wpn.effective_end_date
     );

    l_out_wpn_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_WV_PRTN_RSN_PL_F ----------------------
---------------------------------------------------------------

---------------------------------------------------------------
-- START OF BEN_BNFT_RSTRN_CTFN_F ----------------------
---------------------------------------------------------------
   cursor c_brc_from_parent(c_PL_ID number) is
   select  bnft_rstrn_ctfn_id
   from BEN_BNFT_RSTRN_CTFN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_brc(c_bnft_rstrn_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  brc.*
   from BEN_BNFT_RSTRN_CTFN_F brc
   where  brc.bnft_rstrn_ctfn_id = c_bnft_rstrn_ctfn_id
     -- and brc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_BNFT_RSTRN_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_bnft_rstrn_ctfn_id
           -- and information4 = brc.business_group_id
           and information2 = brc.effective_start_date
           and information3 = brc.effective_end_date
     );

    l_out_brc_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_BNFT_RSTRN_CTFN_F ----------------------
---------------------------------------------------------------
   ---
---------------------------------------------------------------
-- START OF BEN_LER_BNFT_RSTRN_F ----------------------
---------------------------------------------------------------
   cursor c_lbr_from_parent(c_PL_ID number) is
   select distinct ler_bnft_rstrn_id
   from BEN_LER_BNFT_RSTRN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_lbr(c_ler_bnft_rstrn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lbr.*
   from BEN_LER_BNFT_RSTRN_F lbr
   where  lbr.ler_bnft_rstrn_id = c_ler_bnft_rstrn_id
     -- and lbr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_BNFT_RSTRN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_bnft_rstrn_id
           -- and information4 = lbr.business_group_id
           and information2 = lbr.effective_start_date
           and information3 = lbr.effective_end_date
     );
   cursor c_lbr_drp(c_ler_bnft_rstrn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LER_BNFT_RSTRN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_bnft_rstrn_id
         -- and information4 = p_business_group_id
        ;
  l_out_lbr_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_LER_BNFT_RSTRN_F ----------------------
---------------------------------------------------------------
   ---
---------------------------------------------------------------
-- START OF BEN_ENRT_CTFN_F ----------------------
---------------------------------------------------------------
   cursor c_ecf_from_parent(c_PL_ID number) is
   select  enrt_ctfn_id
   from BEN_ENRT_CTFN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_ecf(c_enrt_ctfn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  ecf.*
   from BEN_ENRT_CTFN_F ecf
   where  ecf.enrt_ctfn_id = c_enrt_ctfn_id
     -- and ecf.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_ENRT_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_enrt_ctfn_id
           -- and information4 = ecf.business_group_id
           and information2 = ecf.effective_start_date
           and information3 = ecf.effective_end_date
     );

    l_out_ecf_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_ENRT_CTFN_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_LER_CHG_DPNT_CVG_F ----------------------
---------------------------------------------------------------
   cursor c_ldc_from_parent(c_PL_ID number) is
   select distinct ler_chg_dpnt_cvg_id
   from BEN_LER_CHG_DPNT_CVG_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_ldc(c_ler_chg_dpnt_cvg_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  ldc.*
   from BEN_LER_CHG_DPNT_CVG_F ldc
   where  ldc.ler_chg_dpnt_cvg_id = c_ler_chg_dpnt_cvg_id
     -- and ldc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_CHG_DPNT_CVG_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_chg_dpnt_cvg_id
           -- and information4 = ldc.business_group_id
           and information2 = ldc.effective_start_date
           and information3 = ldc.effective_end_date
     );
   cursor c_ldc_drp(c_ler_chg_dpnt_cvg_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LER_CHG_DPNT_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_chg_dpnt_cvg_id
         -- and information4 = p_business_group_id
        ;

    l_out_ldc_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_LER_CHG_DPNT_CVG_F ----------------------
---------------------------------------------------------------
   ---
---------------------------------------------------------------
-- START OF BEN_LER_CHG_PL_NIP_ENRT_F ----------------------
---------------------------------------------------------------
   cursor c_lpe_from_parent(c_PL_ID number) is
   select distinct ler_chg_pl_nip_enrt_id
   from BEN_LER_CHG_PL_NIP_ENRT_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_lpe(c_ler_chg_pl_nip_enrt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lpe.*
   from BEN_LER_CHG_PL_NIP_ENRT_F lpe
   where  lpe.ler_chg_pl_nip_enrt_id = c_ler_chg_pl_nip_enrt_id
     -- and lpe.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_CHG_PL_NIP_ENRT_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_chg_pl_nip_enrt_id
           -- and information4 = lpe.business_group_id
           and information2 = lpe.effective_start_date
           and information3 = lpe.effective_end_date
     );
   cursor c_lpe_drp(c_ler_chg_pl_nip_enrt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id   = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LER_CHG_PL_NIP_ENRT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_chg_pl_nip_enrt_id
         -- and information4 = p_business_group_id
        ;

   l_out_lpe_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_LER_CHG_PL_NIP_ENRT_F ----------------------
---------------------------------------------------------------
   ---
---------------------------------------------------------------
-- START OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
---------------------------------------------------------------
   cursor c_lre_from_parent(c_PL_ID number) is
   select distinct ler_rqrs_enrt_ctfn_id
   from BEN_LER_RQRS_ENRT_CTFN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_lre(c_ler_rqrs_enrt_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lre.*
   from BEN_LER_RQRS_ENRT_CTFN_F lre
   where  lre.ler_rqrs_enrt_ctfn_id = c_ler_rqrs_enrt_ctfn_id
     -- and lre.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_RQRS_ENRT_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_rqrs_enrt_ctfn_id
           -- and information4 = lre.business_group_id
           and information2 = lre.effective_start_date
           and information3 = lre.effective_end_date
     );
   cursor c_lre_drp(c_ler_rqrs_enrt_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LER_RQRS_ENRT_CTFN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_rqrs_enrt_ctfn_id
         -- and information4 = p_business_group_id
        ;

   l_out_lre_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_PL_PCP ----------------------
---------------------------------------------------------------
   cursor c_pcp_from_parent(c_PL_ID number) is
   select  pl_pcp_id
   from BEN_PL_PCP
   where  PL_ID = c_PL_ID ;
   --
   cursor c_pcp(c_pl_pcp_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  pcp.*
   from BEN_PL_PCP pcp
   where  pcp.pl_pcp_id = c_pl_pcp_id
     -- and pcp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_PCP'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_pcp_id
           -- and information4 = pcp.business_group_id
    );

   l_out_pcp_result_id number(15);
---------------------------------------------------------------
-- END OF BEN_PL_PCP ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_PL_PCP_TYP ----------------------
---------------------------------------------------------------
   cursor c_pty_from_parent(c_PL_PCP_ID number) is
   select  pl_pcp_typ_id
   from BEN_PL_PCP_TYP
   where  PL_PCP_ID = c_PL_PCP_ID ;
   --
   cursor c_pty(c_pl_pcp_typ_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  pty.*
   from BEN_PL_PCP_TYP pty
   where  pty.pl_pcp_typ_id = c_pl_pcp_typ_id
     -- and pty.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_PCP_TYP'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_pcp_typ_id
         -- and information4 = pty.business_group_id
        );
    l_pl_pcp_typ_id                 number(15);
    l_out_pty_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_PL_PCP_TYP ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_PL_BNF_CTFN_F ----------------------
---------------------------------------------------------------
   cursor c_pcx_from_parent(c_PL_ID number) is
   select  pl_bnf_ctfn_id
   from BEN_PL_BNF_CTFN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_pcx(c_pl_bnf_ctfn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  pcx.*
   from BEN_PL_BNF_CTFN_F pcx
   where  pcx.pl_bnf_ctfn_id = c_pl_bnf_ctfn_id
     -- and pcx.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_BNF_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_bnf_ctfn_id
           -- and information4 = pcx.business_group_id
           and information2 = pcx.effective_start_date
           and information3 = pcx.effective_end_date
     );

   l_out_pcx_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_PL_BNF_CTFN_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_PL_DPNT_CVG_CTFN_F ----------------------
---------------------------------------------------------------
   cursor c_pnd_from_parent(c_PL_ID number) is
   select  pl_dpnt_cvg_ctfn_id
   from BEN_PL_DPNT_CVG_CTFN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_pnd(c_pl_dpnt_cvg_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  pnd.*
   from BEN_PL_DPNT_CVG_CTFN_F pnd
   where  pnd.pl_dpnt_cvg_ctfn_id = c_pl_dpnt_cvg_ctfn_id
     -- and pnd.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_DPNT_CVG_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_dpnt_cvg_ctfn_id
           -- and information4 = pnd.business_group_id
           and information2 = pnd.effective_start_date
           and information3 = pnd.effective_end_date
     );

   l_out_pnd_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_PL_DPNT_CVG_CTFN_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
---------------------------------------------------------------
   cursor c_peo_from_parent(c_PL_ID number) is
   select  elig_to_prte_rsn_id
   from BEN_ELIG_TO_PRTE_RSN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_peo(c_elig_to_prte_rsn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  peo.*
   from BEN_ELIG_TO_PRTE_RSN_F peo
   where  peo.elig_to_prte_rsn_id = c_elig_to_prte_rsn_id
     -- and peo.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_ELIG_TO_PRTE_RSN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_elig_to_prte_rsn_id
           -- and information4 = peo.business_group_id
           and information2 = peo.effective_start_date
           and information3 = peo.effective_end_date
     );

    l_out_peo_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_GD_OR_SVC_TYP ----------------------
---------------------------------------------------------------
   cursor c_gos_from_parent(c_PL_GD_OR_SVC_ID number) is
   select  gd_or_svc_typ_id
   from BEN_PL_GD_OR_SVC_F
   where  PL_GD_OR_SVC_ID = c_PL_GD_OR_SVC_ID ;
   --
   cursor c_gos(c_gd_or_svc_typ_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  gos.*
   from BEN_GD_OR_SVC_TYP gos
   where  gos.gd_or_svc_typ_id = c_gd_or_svc_typ_id
     -- and gos.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_GD_OR_SVC_TYP'
           and cpe.table_alias = c_table_alias
           and information1 = c_gd_or_svc_typ_id
           -- and information4 = gos.business_group_id
    );

    l_out_gos_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_GD_OR_SVC_TYP ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_PL_GD_R_SVC_CTFN_F ----------------------
---------------------------------------------------------------
   cursor c_pct_from_parent(c_PL_GD_OR_SVC_ID number) is
   select  pl_gd_r_svc_ctfn_id
   from BEN_PL_GD_R_SVC_CTFN_F
   where  PL_GD_OR_SVC_ID = c_PL_GD_OR_SVC_ID ;
   --
   cursor c_pct(c_pl_gd_r_svc_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  pct.*
   from BEN_PL_GD_R_SVC_CTFN_F pct
   where  pct.pl_gd_r_svc_ctfn_id = c_pl_gd_r_svc_ctfn_id
     -- and pct.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_GD_R_SVC_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_gd_r_svc_ctfn_id
           -- and information4 = pct.business_group_id
           and information2 = pct.effective_start_date
           and information3 = pct.effective_end_date
     );

    l_out_pct_result_id   number(15);
---------------------------------------------------------------
-- END OF BEN_PL_GD_R_SVC_CTFN_F ----------------------
---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_PL_REGN_F ----------------------
  ---------------------------------------------------------------
   cursor c_prg_from_parent(c_PL_ID number) is
   select  pl_regn_id
   from BEN_PL_REGN_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_prg(c_pl_regn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  prg.*
   from BEN_PL_REGN_F prg
   where  prg.pl_regn_id = c_pl_regn_id
     -- and prg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PL_REGN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_pl_regn_id
           -- and information4 = prg.business_group_id
           and information2 = prg.effective_start_date
           and information3 = prg.effective_end_date
     );
    l_out_prg_result_id      number ;
  ---------------------------------------------------------------
  -- END OF BEN_PL_REGN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_REGN_F ----------------------
  ---------------------------------------------------------------
   cursor c_reg_from_parent(c_PL_REGN_ID number) is
   select  regn_id
   from BEN_PL_REGN_F
   where  PL_REGN_ID = c_PL_REGN_ID ;
   --
   cursor c_reg(c_regn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  reg.*
   from BEN_REGN_F reg
   where  reg.regn_id = c_regn_id
     -- and reg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_REGN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_regn_id
           -- and information4 = reg.business_group_id
           and information2 = reg.effective_start_date
           and information3 = reg.effective_end_date
     );

     l_out_reg_result_id   number(15);
 ---------------------------------------------------------------
  -- END OF BEN_REGN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_RPTG_GRP ----------------------
  ---------------------------------------------------------------
   cursor c_bnr_from_parent(c_PL_REGN_ID number) is
   select  rptg_grp_id
   from BEN_PL_REGN_F
   where  PL_REGN_ID = c_PL_REGN_ID ;
   --
   cursor c_bnr(c_rptg_grp_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  bnr.*
   from BEN_RPTG_GRP bnr
   where  bnr.rptg_grp_id = c_rptg_grp_id
     -- and bnr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_RPTG_GRP'
           and cpe.table_alias = c_table_alias
           and information1 = c_rptg_grp_id
           -- and information4 = bnr.business_group_id
     );
  l_out_bnr_result_id   number(15);
  ---------------------------------------------------------------
  -- END OF BEN_RPTG_GRP ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_WV_PRTN_RSN_CTFN_PL_F ----------------------
  ---------------------------------------------------------------
   cursor c_wcn_from_parent(c_WV_PRTN_RSN_PL_ID number) is
   select  wv_prtn_rsn_ctfn_pl_id
   from BEN_WV_PRTN_RSN_CTFN_PL_F
   where  WV_PRTN_RSN_PL_ID = c_WV_PRTN_RSN_PL_ID ;
   --
   cursor c_wcn(c_wv_prtn_rsn_ctfn_pl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  wcn.*
   from BEN_WV_PRTN_RSN_CTFN_PL_F wcn
   where  wcn.wv_prtn_rsn_ctfn_pl_id = c_wv_prtn_rsn_ctfn_pl_id
     -- and wcn.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_WV_PRTN_RSN_CTFN_PL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_wv_prtn_rsn_ctfn_pl_id
           -- and information4 = wcn.business_group_id
           and information2 = wcn.effective_start_date
           and information3 = wcn.effective_end_date
     );

    l_out_wcn_result_id   number(15);
  ---------------------------------------------------------------
  -- END OF BEN_WV_PRTN_RSN_CTFN_PL_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_BNFT_RSTRN_CTFN_F ----------------------
  ---------------------------------------------------------------
   cursor c_lbc_from_parent(c_LER_BNFT_RSTRN_ID number) is
   select  ler_bnft_rstrn_ctfn_id
   from BEN_LER_BNFT_RSTRN_CTFN_F
   where  LER_BNFT_RSTRN_ID = c_LER_BNFT_RSTRN_ID ;
   --
   cursor c_lbc(c_ler_bnft_rstrn_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lbc.*
   from BEN_LER_BNFT_RSTRN_CTFN_F lbc
   where  lbc.ler_bnft_rstrn_ctfn_id = c_ler_bnft_rstrn_ctfn_id
     -- and lbc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_BNFT_RSTRN_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_bnft_rstrn_ctfn_id
           -- and information4 = lbc.business_group_id
           and information2 = lbc.effective_start_date
           and information3 = lbc.effective_end_date
     );

    l_out_lbc_result_id   number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_BNFT_RSTRN_CTFN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_ENRT_CTFN_F ----------------------
  ---------------------------------------------------------------
   cursor c_lnc_from_parent(c_LER_RQRS_ENRT_CTFN_ID number) is
   select  ler_enrt_ctfn_id
   from BEN_LER_ENRT_CTFN_F
   where  LER_RQRS_ENRT_CTFN_ID = c_LER_RQRS_ENRT_CTFN_ID ;
   --
   cursor c_lnc(c_ler_enrt_ctfn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  lnc.*
   from BEN_LER_ENRT_CTFN_F lnc
   where  lnc.ler_enrt_ctfn_id = c_ler_enrt_ctfn_id
     -- and lnc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_ENRT_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_enrt_ctfn_id
           -- and information4 = lnc.business_group_id
           and information2 = lnc.effective_start_date
           and information3 = lnc.effective_end_date
     );

    l_out_lnc_result_id   number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_ENRT_CTFN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
   cursor c_lcc_from_parent(c_LER_CHG_DPNT_CVG_ID number) is
   select  ler_chg_dpnt_cvg_ctfn_id
   from BEN_LER_CHG_DPNT_CVG_CTFN_F
   where  LER_CHG_DPNT_CVG_ID = c_LER_CHG_DPNT_CVG_ID ;
   --
   cursor c_lcc(c_ler_chg_dpnt_cvg_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lcc.*
   from BEN_LER_CHG_DPNT_CVG_CTFN_F lcc
   where  lcc.ler_chg_dpnt_cvg_ctfn_id = c_ler_chg_dpnt_cvg_ctfn_id
     -- and lcc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              ,pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_CHG_DPNT_CVG_CTFN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_chg_dpnt_cvg_ctfn_id
           -- and information4 = lcc.business_group_id
           and information2 = lcc.effective_start_date
           and information3 = lcc.effective_end_date
     );

    l_out_lcc_result_id   number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_CHG_DPNT_CVG_CTFN_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_DSGN_RQMT_F ----------------------
  ---------------------------------------------------------------
   cursor c_ddr3_from_parent(c_PL_ID number) is
   select  dsgn_rqmt_id
   from BEN_DSGN_RQMT_F
   where  PL_ID = c_PL_ID ;
   --
   cursor c_ddr3(c_dsgn_rqmt_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  ddr.*
   from BEN_DSGN_RQMT_F ddr
   where  ddr.dsgn_rqmt_id = c_dsgn_rqmt_id
     -- and ddr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGN_RQMT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgn_rqmt_id
         -- and information4 = ddr.business_group_id
           and information2 = ddr.effective_start_date
           and information3 = ddr.effective_end_date
        );

   l_ddr3_dsgn_rqmt_esd ben_dsgn_rqmt_f.effective_start_date%type;

   ---------------------------------------------------------------
   -- END OF BEN_DSGN_RQMT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
   ---------------------------------------------------------------
   cursor c_drr3_from_parent(c_DSGN_RQMT_ID number) is
   select  dsgn_rqmt_rlshp_typ_id
   from BEN_DSGN_RQMT_RLSHP_TYP
   where  DSGN_RQMT_ID = c_DSGN_RQMT_ID ;
   --
   cursor c_drr3(c_dsgn_rqmt_rlshp_typ_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  drr.*
   from BEN_DSGN_RQMT_RLSHP_TYP drr
   where  drr.dsgn_rqmt_rlshp_typ_id = c_dsgn_rqmt_rlshp_typ_id
     -- and drr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGN_RQMT_RLSHP_TYP'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgn_rqmt_rlshp_typ_id
         -- and information4 = drr.business_group_id
        );

   ---------------------------------------------------------------
   -- END OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_OIPL_F ----------------------
   ---------------------------------------------------------------
   cursor c_cop1_from_parent(c_PL_ID number) is
   select  distinct oipl_id
   from BEN_OIPL_F
   where  PL_ID = c_PL_ID ;
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_REGN_F ----------------------
   ---------------------------------------------------------------
   cursor c_prg1_from_parent(c_RPTG_GRP_ID number) is
   select  pl_regn_id
   from BEN_PL_REGN_F
   where  RPTG_GRP_ID = c_RPTG_GRP_ID ;
   --
   cursor c_prg1(c_pl_regn_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  prg.*
   from BEN_PL_REGN_F prg
   where  prg.pl_regn_id = c_pl_regn_id
     -- and prg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_REGN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_regn_id
         -- and information4 = prg.business_group_id
           and information2 = prg.effective_start_date
           and information3 = prg.effective_end_date
        );

   l_out_prg1_result_id      number ;
   ---------------------------------------------------------------
   -- END OF BEN_PL_REGN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_REGY_BOD_F ----------------------
   ---------------------------------------------------------------
   cursor c_prb_from_parent(c_RPTG_GRP_ID number) is
   select  pl_regy_bod_id
   from BEN_PL_REGY_BOD_F
   where  RPTG_GRP_ID = c_RPTG_GRP_ID ;
   --
   cursor c_prb(c_pl_regy_bod_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  prb.*
   from BEN_PL_REGY_BOD_F prb
   where  prb.pl_regy_bod_id = c_pl_regy_bod_id
     -- and prb.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_REGY_BOD_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_regy_bod_id
         -- and information4 = prb.business_group_id
           and information2 = prb.effective_start_date
           and information3 = prb.effective_end_date
        );
    l_pl_regy_bod_id                 number(15);
    l_out_prb_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_REGY_BOD_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_REGY_PRP_F ----------------------
   ---------------------------------------------------------------
   cursor c_prp_from_parent(c_PL_REGY_BOD_ID number) is
   select  pl_regy_prps_id
   from BEN_PL_REGY_PRP_F
   where  PL_REGY_BOD_ID = c_PL_REGY_BOD_ID ;
   --
   cursor c_prp(c_pl_regy_prps_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  prp.*
   from BEN_PL_REGY_PRP_F prp
   where  prp.pl_regy_prps_id = c_pl_regy_prps_id
     -- and prp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_REGY_PRP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_regy_prps_id
         -- and information4 = prp.business_group_id
           and information2 = prp.effective_start_date
           and information3 = prp.effective_end_date
        );
    l_pl_regy_prps_id                 number(15);
    l_out_prp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_REGY_PRP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_POPL_RPTG_GRP_F ----------------------
   ---------------------------------------------------------------
   cursor c_rgr1_from_parent(c_RPTG_GRP_ID number) is
   select  popl_rptg_grp_id
   from BEN_POPL_RPTG_GRP_F
   where  RPTG_GRP_ID = c_RPTG_GRP_ID ;
   --
   cursor c_rgr1(c_popl_rptg_grp_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  rgr.*
   from BEN_POPL_RPTG_GRP_F rgr
   where  rgr.popl_rptg_grp_id = c_popl_rptg_grp_id
     -- and rgr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_POPL_RPTG_GRP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_popl_rptg_grp_id
         -- and information4 = rgr.business_group_id
           and information2 = rgr.effective_start_date
           and information3 = rgr.effective_end_date
        );
    l_popl_rptg_grp_id                 number(15);
   ---------------------------------------------------------------
   -- END OF BEN_POPL_RPTG_GRP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_REGN_F ----------------------
   ---------------------------------------------------------------
   cursor c_reg1_from_parent(c_PL_REGN_ID number) is
   select  regn_id
   from BEN_PL_REGN_F
   where  PL_REGN_ID = c_PL_REGN_ID ;
   --
   cursor c_reg1(c_regn_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  reg.*
   from BEN_REGN_F reg
   where  reg.regn_id = c_regn_id
     -- and reg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
---              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_REGN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_regn_id
         -- and information4 = reg.business_group_id
           and information2 = reg.effective_start_date
           and information3 = reg.effective_end_date
        );
    l_out_reg1_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_REGN_F ----------------------
   ---------------------------------------------------------------

   cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
--    and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

   l_table_route_id            number(15);
   l_mirror_src_entity_result_id number(15);
   l_result_type_cd            varchar2(30);
   l_information5              ben_copy_entity_results.information5%type;
   l_regn_name                 ben_regn_f.name%type;
   --
   l_pl_id                     number(15);
   l_popl_yr_perd_id           number(15);
   l_yr_perd_id                number(15);
   l_wthn_yr_perd_id           number(15);
   l_popl_org_id               number(15);
   l_popl_org_role_id          number(15);
   l_pl_gd_or_svc_id           number(15);
   l_gd_or_svc_typ_id          number(15);
   l_pl_gd_r_svc_ctfn_id       number(15);
   l_number_of_copies          number(15);
   l_pl_regn_id                number(15);
   l_pl_regn_id1               number(15);
   l_regn_id                   number(15);
   l_rptg_grp_id               number(15);
   l_wv_prtn_rsn_ctfn_pl_id    number(15);
   l_wv_prtn_rsn_pl_id         number(15);
   l_ler_bnft_rstrn_ctfn_id    number(15);
   l_ler_bnft_rstrn_id         number(15);
   l_ler_enrt_ctfn_id          number(15);
   l_ler_rqrs_enrt_ctfn_id     number(15);
   l_ler_chg_dpnt_cvg_ctfn_id  number(15);
   l_ler_chg_dpnt_cvg_id       number(15);
   l_child_exists              boolean default false ;
   l_vald_rlshp_for_reimb_id   number(15);
   l_bnft_rstrn_ctfn_id        number(15);
   l_enrt_ctfn_id              number(15);
   l_ler_chg_pl_nip_enrt_id    number(15);
   l_pl_pcp_id                 number(15);
   l_pl_bnf_ctfn_id            number(15);
   l_pl_dpnt_cvg_ctfn_id       number(15);
   l_elig_to_prte_rsn_id       number(15);
   --
   --
   l_out_cpp_result_id         number(15);
   l_out_pln_result_id         number(15);
   l_out_pln_cpp_result_id     number(15);
   l_parent_entity_result_id   number(15);
   --
   L_DSGN_RQMT_ID              number(15);
   L_OUT_DDR_RESULT_ID         number(15);
   L_DSGN_RQMT_RLSHP_TYP_ID    number(15);
   L_OUT_DRR_RESULT_ID         number(15);
   --
   l_pl_typ_name               ben_pl_typ_f.name%type;
   l_pl_usage                  hr_lookups.meaning%type;
   l_group_pl_id              number (15);
begin
   --
   --
   l_number_of_copies := p_number_of_copies ;
   --

   for l_parent_rec  in c_pln_from_parent(p_PLIP_ID,p_pl_id) loop
   --
   --
     l_pl_id := l_parent_rec.pl_id ;
     --

     if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
     else
       ben_plan_design_program_module.g_pdw_allow_dup_rslt := null;
     end if;

     if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       open c_object_exists(l_pl_id,'PLN');
       fetch c_object_exists into l_dummy;
       if c_object_exists%found then
         close c_object_exists;
         return;
       end if;
       close c_object_exists;
     end if;

     l_mirror_src_entity_result_id := null ;

     if p_plip_id is not null then
       open c_parent_result(P_PLIP_ID,'CPP',p_copy_entity_txn_id);
       fetch c_parent_result into l_mirror_src_entity_result_id ;

       if c_parent_result%notfound  then

         -- If PLIP does not exist as of process effective date
         -- then fetch the PLIP result record with min copy_entity_result_id

         open c_parent_result1(P_PLIP_ID,'CPP',p_copy_entity_txn_id);
         fetch c_parent_result1 into l_mirror_src_entity_result_id ;
         close c_parent_result1;
       end if;

       close c_parent_result ;

       l_out_cpp_result_id := l_mirror_src_entity_result_id; -- Added for HGrid Hierarchy
     end if;
     --
     l_pln_esd := null;
     --

     for l_pln_rec in c_pln(l_parent_rec.pl_id,l_mirror_src_entity_result_id,
                            'PLN') loop
       --
       savepoint create_copy_entity_result;
       --
       l_table_route_id := null ;
       open ben_plan_design_program_module.g_table_route('PLN');
       fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
       close ben_plan_design_program_module.g_table_route ;
       --
       l_information5  := l_pln_rec.name; --'Intersection';
       --
       l_pl_typ_name := ben_plan_design_program_module.get_pl_typ_name(l_pln_rec.pl_typ_id,p_effective_date);
       l_pl_usage    := hr_general.decode_lookup('BEN_PL',l_pln_rec.pl_cd);
       --
       if p_effective_date between l_pln_rec.effective_start_date
           and l_pln_rec.effective_end_date then
           --
           l_result_type_cd := 'DISPLAY';
       else
           l_result_type_cd := 'NO DISPLAY';
       end if;
       --
       -- mapping for CWB plan
       --
       -- Bug 4665663 - Map only if it is not a Group Plan
       --
       l_group_pl_id := NULL;

       if (l_pln_rec.group_pl_id IS NOT NULL and
                  l_pln_rec.pl_id <> l_pln_rec.group_pl_id) then
           --
           open c_grp_pl_name(l_pln_rec.group_pl_id);
           fetch c_grp_pl_name into l_mapping_name;
           close c_grp_pl_name;
           --
           l_group_pl_id := l_pln_rec.group_pl_id; -- 4665663
           --
           --To set user friendly labels on the mapping page
           --
           l_mapping_column_name1 := null;
           l_mapping_column_name2 :=null;
           BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                      l_mapping_column_name1,
                                      l_mapping_column_name2,
                                      p_copy_entity_txn_id);
           --
        end if;
        --
       l_copy_entity_result_id := null;
       l_object_version_number := null;
       ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id           => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => null, -- Hide BEN_PL_F for HGrid
            p_number_of_copies               => l_number_of_copies,
            p_table_alias					 => 'PLN',
            p_table_route_id                 => l_table_route_id,
            p_information1     => l_pln_rec.pl_id,
            p_information2     => l_pln_rec.EFFECTIVE_START_DATE,
            p_information3     => l_pln_rec.EFFECTIVE_END_DATE,
            p_information4     => l_pln_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information6     => l_pl_typ_name,
            p_information7     => l_pl_usage,
            p_information8     => l_parent_rec.information8,
            p_information250     => l_pln_rec.actl_prem_id,
            p_information36     => l_pln_rec.alws_qdro_flag,
            p_information37     => l_pln_rec.alws_qmcso_flag,
            p_information51     => l_pln_rec.alws_reimbmts_flag,
            p_information24     => l_pln_rec.alws_tmpry_id_crd_flag,
            p_information52     => l_pln_rec.alws_unrstrctd_enrt_flag,
            p_information281     => l_pln_rec.auto_enrt_mthd_rl,
            p_information101     => l_pln_rec.bndry_perd_cd,
            p_information53     => l_pln_rec.bnf_addl_instn_txt_alwd_flag,
            p_information54     => l_pln_rec.bnf_adrs_rqd_flag,
            p_information56     => l_pln_rec.bnf_cntngt_bnfs_alwd_flag,
            p_information55     => l_pln_rec.bnf_ctfn_rqd_flag,
            p_information82     => l_pln_rec.bnf_dflt_bnf_cd,
            p_information66     => l_pln_rec.bnf_dob_rqd_flag,
            p_information60     => l_pln_rec.bnf_dsge_mnr_ttee_rqd_flag,
            p_information89     => l_pln_rec.bnf_dsgn_cd,
            p_information302     => l_pln_rec.bnf_incrmt_amt,
            p_information57     => l_pln_rec.bnf_legv_id_rqd_flag,
            p_information58     => l_pln_rec.bnf_may_dsgt_org_flag,
            p_information303     => l_pln_rec.bnf_mn_dsgntbl_amt,
            p_information290     => l_pln_rec.bnf_mn_dsgntbl_pct_val,
            p_information83     => l_pln_rec.bnf_pct_amt_alwd_cd,
            p_information293     => l_pln_rec.bnf_pct_incrmt_val,
            p_information59     => l_pln_rec.bnf_qdro_rl_apls_flag,
            p_information77     => l_pln_rec.bnft_or_option_rstrctn_cd,
            p_information235     => l_pln_rec.bnft_prvdr_pool_id,
            p_information84     => l_pln_rec.cmpr_clms_to_cvg_or_bal_cd,
            p_information285     => l_pln_rec.cobra_pymt_due_dy_num,
            p_information287     => l_pln_rec.cost_alloc_keyflex_1_id,
            p_information288     => l_pln_rec.cost_alloc_keyflex_2_id,
            p_information263     => l_pln_rec.cr_dstr_bnft_prvdr_pool_id,
            p_information68     => l_pln_rec.cvg_incr_r_decr_only_cd,
            p_information91     => l_pln_rec.dflt_to_asn_pndg_ctfn_cd,
            p_information272     => l_pln_rec.dflt_to_asn_pndg_ctfn_rl,
            p_information30     => l_pln_rec.dpnt_adrs_rqd_flag,
            p_information29     => l_pln_rec.dpnt_cvd_by_othr_apls_flag,
            p_information85     => l_pln_rec.dpnt_cvg_end_dt_cd,
            p_information258     => l_pln_rec.dpnt_cvg_end_dt_rl,
            p_information86     => l_pln_rec.dpnt_cvg_strt_dt_cd,
            p_information259     => l_pln_rec.dpnt_cvg_strt_dt_rl,
            p_information32     => l_pln_rec.dpnt_dob_rqd_flag,
            p_information87     => l_pln_rec.dpnt_dsgn_cd,
            p_information31     => l_pln_rec.dpnt_leg_id_rqd_flag,
            p_information27     => l_pln_rec.dpnt_no_ctfn_rqd_flag,
            p_information25     => l_pln_rec.drvbl_dpnt_elig_flag,
            p_information33     => l_pln_rec.drvbl_fctr_apls_rts_flag,
            p_information26     => l_pln_rec.drvbl_fctr_prtn_elig_flag,
            p_information34     => l_pln_rec.elig_apls_flag,
            p_information17     => l_pln_rec.enrt_cd,
            p_information21     => l_pln_rec.enrt_cvg_end_dt_cd,
            p_information260     => l_pln_rec.enrt_cvg_end_dt_rl,
            p_information20     => l_pln_rec.enrt_cvg_strt_dt_cd,
            p_information262     => l_pln_rec.enrt_cvg_strt_dt_rl,
            p_information92     => l_pln_rec.enrt_mthd_cd,
            p_information39     => l_pln_rec.enrt_pl_opt_flag,
            p_information274     => l_pln_rec.enrt_rl,
            p_information40     => l_pln_rec.frfs_aply_flag,
            p_information96     => l_pln_rec.frfs_cntr_det_cd,
            p_information97     => l_pln_rec.frfs_distr_det_cd,
            p_information13     => l_pln_rec.frfs_distr_mthd_cd,
            p_information257     => l_pln_rec.frfs_distr_mthd_rl,
            p_information304     => l_pln_rec.frfs_mx_cryfwd_val,
            p_information100     => l_pln_rec.frfs_portion_det_cd,
            p_information99     => l_pln_rec.frfs_val_det_cd,
            p_information95     => l_pln_rec.function_code,
             -- tilak cwb pl copy fix
            p_information160    => l_pln_rec.group_pl_id,
            -- Data for MAPPING columns.
            p_information173     => l_mapping_name,
            p_information174     => l_group_pl_id,
            p_information181     => l_mapping_column_name1,
            p_information182     => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information47     => l_pln_rec.hc_pl_subj_hcfa_aprvl_flag,
            p_information15     => l_pln_rec.hc_svc_typ_cd,
            p_information38     => l_pln_rec.hghly_cmpd_rl_apls_flag,
            p_information73     => l_pln_rec.imptd_incm_calc_cd,
            p_information306     => l_pln_rec.incptn_dt,
            p_information50     => l_pln_rec.invk_dcln_prtn_pl_flag,
            p_information49     => l_pln_rec.invk_flx_cr_pl_flag,
            p_information142     => l_pln_rec.ivr_ident,
            p_information141     => l_pln_rec.mapping_table_name,
            p_information294     => l_pln_rec.mapping_table_pk_id,
            p_information28     => l_pln_rec.may_enrl_pl_n_oipl_flag,
            p_information296     => l_pln_rec.mn_cvg_alwd_amt,
            p_information283     => l_pln_rec.mn_cvg_rl,
            p_information300     => l_pln_rec.mn_cvg_rqd_amt,
            p_information269     => l_pln_rec.mn_opts_rqd_num,
            p_information299     => l_pln_rec.mx_cvg_alwd_amt,
            p_information297     => l_pln_rec.mx_cvg_incr_alwd_amt,
            p_information298     => l_pln_rec.mx_cvg_incr_wcf_alwd_amt,
            p_information271     => l_pln_rec.mx_cvg_mlt_incr_num,
            p_information273     => l_pln_rec.mx_cvg_mlt_incr_wcf_num,
            p_information284     => l_pln_rec.mx_cvg_rl,
            p_information295     => l_pln_rec.mx_cvg_wcfn_amt,
            p_information267     => l_pln_rec.mx_cvg_wcfn_mlt_num,
            p_information270     => l_pln_rec.mx_opts_alwd_num,
            p_information80     => l_pln_rec.mx_wtg_dt_to_use_cd,
            p_information275     => l_pln_rec.mx_wtg_dt_to_use_rl,
            p_information79     => l_pln_rec.mx_wtg_perd_prte_uom,
            p_information289     => l_pln_rec.mx_wtg_perd_prte_val,
            p_information282     => l_pln_rec.mx_wtg_perd_rl,
            p_information170     => l_pln_rec.name,
            p_information16     => l_pln_rec.nip_acty_ref_perd_cd,
            p_information88     => l_pln_rec.nip_dflt_enrt_cd,
            p_information286     => l_pln_rec.nip_dflt_enrt_det_rl,
            p_information12     => l_pln_rec.nip_dflt_flag,
            p_information22     => l_pln_rec.nip_enrt_info_rt_freq_cd,
            p_information81     => l_pln_rec.nip_pl_uom,
            p_information61     => l_pln_rec.no_mn_cvg_amt_apls_flag,
            p_information63     => l_pln_rec.no_mn_cvg_incr_apls_flag,
            p_information65     => l_pln_rec.no_mn_opts_num_apls_flag,
            p_information62     => l_pln_rec.no_mx_cvg_amt_apls_flag,
            p_information64     => l_pln_rec.no_mx_cvg_incr_apls_flag,
            p_information35     => l_pln_rec.no_mx_opts_num_apls_flag,
            p_information266     => l_pln_rec.ordr_num,
            p_information78     => l_pln_rec.pcp_cd,
            p_information76     => l_pln_rec.per_cvrd_cd,
            p_information67     => l_pln_rec.pl_cd,
            p_information19     => l_pln_rec.pl_stat_cd,
            p_information248     => l_pln_rec.pl_typ_id,
            p_information14     => l_pln_rec.pl_yr_not_applcbl_flag,
            p_information111     => l_pln_rec.pln_attribute1,
            p_information120     => l_pln_rec.pln_attribute10,
            p_information121     => l_pln_rec.pln_attribute11,
            p_information122     => l_pln_rec.pln_attribute12,
            p_information123     => l_pln_rec.pln_attribute13,
            p_information124     => l_pln_rec.pln_attribute14,
            p_information125     => l_pln_rec.pln_attribute15,
            p_information126     => l_pln_rec.pln_attribute16,
            p_information127     => l_pln_rec.pln_attribute17,
            p_information128     => l_pln_rec.pln_attribute18,
            p_information129     => l_pln_rec.pln_attribute19,
            p_information112     => l_pln_rec.pln_attribute2,
            p_information130     => l_pln_rec.pln_attribute20,
            p_information131     => l_pln_rec.pln_attribute21,
            p_information132     => l_pln_rec.pln_attribute22,
            p_information133     => l_pln_rec.pln_attribute23,
            p_information134     => l_pln_rec.pln_attribute24,
            p_information135     => l_pln_rec.pln_attribute25,
            p_information136     => l_pln_rec.pln_attribute26,
            p_information137     => l_pln_rec.pln_attribute27,
            p_information138     => l_pln_rec.pln_attribute28,
            p_information139     => l_pln_rec.pln_attribute29,
            p_information113     => l_pln_rec.pln_attribute3,
            p_information140     => l_pln_rec.pln_attribute30,
            p_information114     => l_pln_rec.pln_attribute4,
            p_information115     => l_pln_rec.pln_attribute5,
            p_information116     => l_pln_rec.pln_attribute6,
            p_information117     => l_pln_rec.pln_attribute7,
            p_information118     => l_pln_rec.pln_attribute8,
            p_information119     => l_pln_rec.pln_attribute9,
            p_information110     => l_pln_rec.pln_attribute_category,
            p_information280     => l_pln_rec.pln_mn_cvg_alwd_amt,
            p_information98     => l_pln_rec.post_to_gl_flag,
            p_information279     => l_pln_rec.postelcn_edit_rl,
            p_information90     => l_pln_rec.prmry_fndg_mthd_cd,
            p_information18     => l_pln_rec.prort_prtl_yr_cvg_rstrn_cd,
            p_information268     => l_pln_rec.prort_prtl_yr_cvg_rstrn_rl,
            p_information46     => l_pln_rec.prtn_elig_ovrid_alwd_flag,
            p_information276     => l_pln_rec.rqd_perd_enrt_nenrt_rl,
            p_information69     => l_pln_rec.rqd_perd_enrt_nenrt_uom,
            p_information301     => l_pln_rec.rqd_perd_enrt_nenrt_val,
            p_information74     => l_pln_rec.rt_end_dt_cd,
            p_information277     => l_pln_rec.rt_end_dt_rl,
            p_information75     => l_pln_rec.rt_strt_dt_cd,
            p_information278     => l_pln_rec.rt_strt_dt_rl,
            p_information93     => l_pln_rec.short_code,
            p_information94     => l_pln_rec.short_name,
            p_information70     => l_pln_rec.subj_to_imptd_incm_cd,
            p_information71     => l_pln_rec.subj_to_imptd_incm_typ_cd,
            p_information41     => l_pln_rec.svgs_pl_flag,
            p_information42     => l_pln_rec.trk_inelig_per_flag,
            p_information72     => l_pln_rec.unsspnd_enrt_cd,
            p_information185     => l_pln_rec.url_ref_name,
            p_information43     => l_pln_rec.use_all_asnts_elig_flag,
            p_information44     => l_pln_rec.use_all_asnts_for_rt_flag,
            p_information23     => l_pln_rec.vrfy_fmly_mmbr_cd,
            p_information264     => l_pln_rec.vrfy_fmly_mmbr_rl,
            p_information45     => l_pln_rec.vstg_apls_flag,
            p_information48     => l_pln_rec.wvbl_flag,
            p_INFORMATION198    => l_pln_rec.SUSP_IF_CTFN_NOT_PRVD_FLAG,
            p_INFORMATION197    => l_pln_rec.CTFN_DETERMINE_CD,
            p_INFORMATION196    => l_pln_rec.SUSP_IF_DPNT_SSN_NT_PRV_CD,
            p_INFORMATION190    => l_pln_rec.SUSP_IF_DPNT_DOB_NT_PRV_CD,
            p_INFORMATION191    => l_pln_rec.SUSP_IF_DPNT_ADR_NT_PRV_CD,
            p_INFORMATION192    => l_pln_rec.SUSP_IF_CTFN_NOT_DPNT_FLAG,
            p_INFORMATION193    => l_pln_rec.DPNT_CTFN_DETERMINE_CD,
            p_INFORMATION194    => l_pln_rec.SUSP_IF_BNF_SSN_NT_PRV_CD,
            p_INFORMATION195    => l_pln_rec.SUSP_IF_BNF_DOB_NT_PRV_CD,
            p_INFORMATION104    => l_pln_rec.BNF_CTFN_DETERMINE_CD,
            p_INFORMATION105    => l_pln_rec.SUSP_IF_CTFN_NOT_BNF_FLAG,
            p_INFORMATION106    => l_pln_rec.SUSP_IF_BNF_ADR_NT_PRV_CD,
            p_information107    => l_pln_rec.legislation_code,              /* Bug 3939490 */
            p_information108    => l_pln_rec.legislation_subgroup,          /* Bug 3939490 */
            p_information109    => l_pln_rec.use_csd_rsd_prccng_cd,         /* Bug 3939490 */
            p_information265    => l_pln_rec.object_version_number,

            p_object_version_number  => l_object_version_number,
            p_effective_date         => p_effective_date       );
            --

            if l_out_pln_result_id is null then
              l_out_pln_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' and  p_number_of_copies = 1 then
              -- ------------------------------------------------------------------------

              -- For Plans in Program, BEN_PL_F will be hidden in the HGrid
              -- All children of BEN_PL_F will have the copy_entity_result_id of
              -- BEN_PLIP_F as their parent_entity_result_id

              -- For Plans Not in Program or when Plan is the Top Node in the HGrid
              -- BEN_PL_F will be displayed
              -- All children of BEN_PL_F will have the copy_entity_result_id of
              -- BEN_PL_F as their parent_entity_result_id

              --
              -- All children of BEN_PL_F will have the copy_entity_result_id of
              -- BEN_PL_F as their mirror_src_entity_result_id
              --

              l_out_pln_result_id := l_copy_entity_result_id;     -- Copy_entity_result_id of Ben_Pl_f

              if p_pl_id is not null then                         -- Plan is Top Node
                l_out_pln_cpp_result_id := l_out_pln_result_id;   -- Copy_entity_result_id of Ben_Pl_f
              else                          -- Plan in Program
                l_out_pln_cpp_result_id := l_out_cpp_result_id;   -- Copy_entity_result_id of Ben_Plip_f
              end if;

              -- ------------------------------------------------------------------------
            end if;
            --

            -- To pass as effective date while creating the
            -- non date-tracked child records
            if l_pln_esd is null then
              l_pln_esd := l_pln_rec.EFFECTIVE_START_DATE;
            end if;

			if (l_pln_rec.auto_enrt_mthd_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.auto_enrt_mthd_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.dflt_to_asn_pndg_ctfn_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.dflt_to_asn_pndg_ctfn_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.dpnt_cvg_end_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.dpnt_cvg_end_dt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.dpnt_cvg_strt_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.dpnt_cvg_strt_dt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.enrt_cvg_end_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.enrt_cvg_end_dt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.enrt_cvg_strt_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.enrt_cvg_strt_dt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.enrt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.enrt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.frfs_distr_mthd_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.frfs_distr_mthd_rl
					,p_business_group_id        => l_pln_rec.frfs_distr_mthd_rl
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.mn_cvg_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.mn_cvg_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.mx_cvg_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.mx_cvg_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.mx_wtg_dt_to_use_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.mx_wtg_dt_to_use_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.mx_wtg_perd_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.mx_wtg_perd_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.nip_dflt_enrt_det_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.nip_dflt_enrt_det_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.postelcn_edit_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.postelcn_edit_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.prort_prtl_yr_cvg_rstrn_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.prort_prtl_yr_cvg_rstrn_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.rqd_perd_enrt_nenrt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.rqd_perd_enrt_nenrt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.rt_end_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.rt_end_dt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.rt_strt_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.rt_strt_dt_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_pln_rec.vrfy_fmly_mmbr_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_pln_rec.vrfy_fmly_mmbr_rl
					,p_business_group_id        => l_pln_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;


       end loop ;
       --
       if p_number_of_copies = 1 then

         if l_out_pln_result_id is null then -- Plan created earlier with number_copies as 0
          --
           open c_parent_result(l_pl_id,'PLN',p_copy_entity_txn_id);
           fetch c_parent_result into l_out_pln_result_id ;

           if c_parent_result%notfound  then
             -- If PLN does not exist as of process effective date
             -- then fetch the PLN result record with min copy_entity_result_id

             open c_parent_result1(l_pl_id,'PLN',p_copy_entity_txn_id);
             fetch c_parent_result1 into l_out_pln_result_id ;
             close c_parent_result1;
           end if;
           close c_parent_result;

           if p_pl_id is not null then                         -- Plan is Top Node
             l_out_pln_cpp_result_id := l_out_pln_result_id;   -- Copy_entity_result_id of Ben_Pl_f
           else                          -- Plan in Program
             l_out_pln_cpp_result_id := l_out_cpp_result_id;   -- Copy_entity_result_id of Ben_Plip_f
           end if;

           -- To pass as effective date while creating the
           -- non date-tracked child records
           open c_parent_esd(p_pl_id,'PLN',p_copy_entity_txn_id);
           fetch c_parent_esd into l_pln_esd;
           close c_parent_esd;

         end if;

         l_mirror_src_entity_result_id :=  l_out_pln_result_id;  -- Copy_entity_result_id of Ben_Pl_f
         l_parent_entity_result_id :=    l_out_pln_cpp_result_id;

         -- ------------------------------------------------------------------------
         -- Eligibility Profiles
         -- ------------------------------------------------------------------------
         ben_plan_design_elpro_module.create_elpro_results
            (
              p_validate                     => p_validate
             ,p_copy_entity_result_id        => l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id           => p_copy_entity_txn_id
             ,p_pgm_id                       => null
             ,p_ptip_id                      => null
             ,p_plip_id                      => null
             ,p_pl_id                        => l_pl_id
             ,p_oipl_id                      => null
             ,p_business_group_id            => p_business_group_id
             ,p_number_of_copies             => p_number_of_copies
             ,p_object_version_number        => l_object_version_number
             ,p_effective_date               => p_effective_date
             ,p_parent_entity_result_id      => l_parent_entity_result_id
            );
           -- ------------------------------------------------------------------------
           -- Dependent Eligibility Profiles
           -- ------------------------------------------------------------------------
           ben_plan_design_elpro_module.create_dep_elpro_result
              (
                  p_validate                   => p_validate
                 ,p_copy_entity_result_id      => l_mirror_src_entity_result_id
                 ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                 ,p_pgm_id                     => null
                 ,p_ptip_id                    => null
                 ,p_pl_id                      => l_pl_id
                 ,p_business_group_id          => p_business_group_id
                 ,p_number_of_copies           => p_number_of_copies
                 ,p_object_version_number      => l_object_version_number
                 ,p_effective_date             => p_effective_date
                 ,p_parent_entity_result_id    => l_parent_entity_result_id
               );
           -- ------------------------------------------------------------------------
           -- Standard Rates ,Flex Credits at Plan level
           -- ------------------------------------------------------------------------
           ben_pd_rate_and_cvg_module.create_rate_results
                (
                  p_validate                   => p_validate
                 ,p_copy_entity_result_id      => l_mirror_src_entity_result_id
                 ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                 ,p_pgm_id                     => null
                 ,p_ptip_id                    => null
                 ,p_plip_id                    => null
                 ,p_pl_id                      => l_pl_id
                 ,p_oipl_id                    => null
                 ,p_oiplip_id                  => null
                 ,p_cmbn_plip_id               => null
                 ,p_cmbn_ptip_id               => null
                 ,p_cmbn_ptip_opt_id           => null
                 ,p_business_group_id          => p_business_group_id
                 ,p_number_of_copies           => p_number_of_copies
                 ,p_object_version_number      => l_object_version_number
                 ,p_effective_date             => p_effective_date
                 ,p_parent_entity_result_id    => l_parent_entity_result_id
                 ) ;

            -- ------------------------------------------------------------------------
            -- Coverage Calculations - Plan Level
            -- ------------------------------------------------------------------------

            ben_pd_rate_and_cvg_module.create_coverage_results
            (
              p_validate                   => p_validate
             ,p_copy_entity_result_id      => l_mirror_src_entity_result_id
             ,p_copy_entity_txn_id         => p_copy_entity_txn_id
             ,p_plip_id                    => null
             ,p_pl_id                      => l_pl_id
             ,p_oipl_id                    => null
             ,p_business_group_id          => p_business_group_id
             ,p_number_of_copies           => p_number_of_copies
             ,p_object_version_number      => l_object_version_number
             ,p_effective_date             => p_effective_date
             ,p_parent_entity_result_id    => l_parent_entity_result_id
           ) ;

           -- ------------------------------------------------------------------------
           -- Actual Premiums - Plan Level
           -- ------------------------------------------------------------------------

            ben_pd_rate_and_cvg_module.create_premium_results
            (
               p_validate                => p_validate
              ,p_copy_entity_result_id   => l_mirror_src_entity_result_id
              ,p_copy_entity_txn_id      => p_copy_entity_txn_id
              ,p_pl_id                   => l_pl_id
              ,p_oipl_id                 => null
              ,p_business_group_id       => p_business_group_id
              ,p_number_of_copies        => p_number_of_copies
              ,p_object_version_number   => l_object_version_number
              ,p_effective_date          => p_effective_date
              ,p_parent_entity_result_id => l_parent_entity_result_id
           ) ;


         -- ------------------------------------------------------------------------
         -- POPL Genenation call
         -- ------------------------------------------------------------------------
         -- ------------------------------------------------------------------------
         --
         create_popl_result
           (
             p_validate                     => p_validate
            ,p_copy_entity_result_id        => l_mirror_src_entity_result_id
            ,p_copy_entity_txn_id           => p_copy_entity_txn_id
            ,p_pgm_id                       => null
            ,p_pl_id                        => l_pl_id
            ,p_business_group_id            => p_business_group_id
            ,p_number_of_copies             => p_number_of_copies
            ,p_object_version_number        => l_object_version_number
            ,p_effective_date               => p_effective_date
            ,p_parent_entity_result_id      => l_parent_entity_result_id
           );
     ---------------------------------------------------------------
     -- START OF BEN_CWB_WKSHT_GRP ----------------------
     ---------------------------------------------------------------
     --

     for l_parent_rec  in c_cwg_from_parent(l_PL_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_pln_result_id ;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;
        --
        l_cwb_wksht_grp_id := l_parent_rec.cwb_wksht_grp_id ;
        --
        for l_cwg_rec in c_cwg(l_parent_rec.cwb_wksht_grp_id,l_mirror_src_entity_result_id,'CWG') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CWG');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_cwg_rec.label;
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
            p_parent_entity_result_id        => l_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_alias					 => 'CWG',
            p_table_route_id                 => l_table_route_id,
            p_information1     => l_cwg_rec.cwb_wksht_grp_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_cwg_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cwg_rec.cwg_attribute1,
            p_information120     => l_cwg_rec.cwg_attribute10,
            p_information121     => l_cwg_rec.cwg_attribute11,
            p_information122     => l_cwg_rec.cwg_attribute12,
            p_information123     => l_cwg_rec.cwg_attribute13,
            p_information124     => l_cwg_rec.cwg_attribute14,
            p_information125     => l_cwg_rec.cwg_attribute15,
            p_information126     => l_cwg_rec.cwg_attribute16,
            p_information127     => l_cwg_rec.cwg_attribute17,
            p_information128     => l_cwg_rec.cwg_attribute18,
            p_information129     => l_cwg_rec.cwg_attribute19,
            p_information112     => l_cwg_rec.cwg_attribute2,
            p_information130     => l_cwg_rec.cwg_attribute20,
            p_information131     => l_cwg_rec.cwg_attribute21,
            p_information132     => l_cwg_rec.cwg_attribute22,
            p_information133     => l_cwg_rec.cwg_attribute23,
            p_information134     => l_cwg_rec.cwg_attribute24,
            p_information135     => l_cwg_rec.cwg_attribute25,
            p_information136     => l_cwg_rec.cwg_attribute26,
            p_information137     => l_cwg_rec.cwg_attribute27,
            p_information138     => l_cwg_rec.cwg_attribute28,
            p_information139     => l_cwg_rec.cwg_attribute29,
            p_information113     => l_cwg_rec.cwg_attribute3,
            p_information140     => l_cwg_rec.cwg_attribute30,
            p_information114     => l_cwg_rec.cwg_attribute4,
            p_information115     => l_cwg_rec.cwg_attribute5,
            p_information116     => l_cwg_rec.cwg_attribute6,
            p_information117     => l_cwg_rec.cwg_attribute7,
            p_information118     => l_cwg_rec.cwg_attribute8,
            p_information119     => l_cwg_rec.cwg_attribute9,
            p_information110     => l_cwg_rec.cwg_attribute_category,
            p_information141     => l_cwg_rec.label,
            p_information260     => l_cwg_rec.ordr_num,
            p_information261     => l_cwg_rec.pl_id,
            p_information11     => l_cwg_rec.wksht_grp_cd,
            p_information12     => l_cwg_rec.hidden_cd,
            p_information13     => l_cwg_rec.status_cd,
            p_information265    => l_cwg_rec.object_version_number,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

	    if l_out_cwg_result_id is null then
              l_out_cwg_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_cwg_result_id := l_copy_entity_result_id ;
            end if;
            --
-- RKG CWB Plan Personalization


	l_mirror_src_entity_result_id := l_copy_entity_result_id ;
	l_parent_entity_result_id := l_copy_entity_result_id;

	    --
	  for l_cri_rec in c_cri(l_parent_rec.cwb_wksht_grp_id,l_mirror_src_entity_result_id,'CRI') loop
          --

          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CRI');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_cri_information5  := l_cri_rec.label;
          --
	  --Bug 5018205 DO NOT Display personalizations if the Label is NULL
	  if l_cri_information5 is null then
	     l_cri_result_type_cd := 'NODISPLAY';
	  else
	     l_cri_result_type_cd := 'DISPLAY';
	  end if;
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;

          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id           => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_cri_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_alias			 => 'CRI',
            p_table_route_id                 => l_table_route_id,
            p_information1     => null,
            p_information2     => null,
            p_information3     => null,
            p_information4     => null,
            p_information5     => l_cri_information5 , -- 9999 put name for h-grid
	    p_information11	=>l_cri_rec.region_code,
	    p_information12	=>l_cri_rec.custom_key,
	    p_information13	=>l_cri_rec.custom_type,
	    p_information14	=>l_cri_rec.item_name,
	    p_information15	=>l_cri_rec.display_flag,
	    p_information16	=>l_cri_rec.update_attr,
	    p_information17	=>l_cri_rec.monetary,
    	    p_information141	=>l_cri_rec.label,
	    p_information265	=>l_cri_rec.object_version_number,
	    p_information266	=>l_cri_rec.ordr_num,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_cri_result_id is null then
              l_out_cri_result_id := l_copy_entity_result_id;
            end if;

            if l_cri_result_type_cd = 'DISPLAY' then
               l_out_cri_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
	    --
-- RKG CWB Plan Personalization


         end loop;
         --
       end loop;

    ---------------------------------------------------------------
    -- END OF BEN_CWB_WKSHT_GRP ----------------------
    ---------------------------------------------------------------

     ---------------------------------------------------------------
     -- START OF BEN_PL_TYP_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_ptp_from_parent(l_PL_ID) loop
       create_pl_typ_result
       ( p_validate                       => p_validate
        ,p_copy_entity_result_id          => l_out_pln_result_id
        ,p_copy_entity_txn_id             => p_copy_entity_txn_id
        ,p_pl_typ_id                      => l_parent_rec.pl_typ_id
        ,p_business_group_id              => p_business_group_id
        ,p_number_of_copies               => p_number_of_copies
        ,p_object_version_number          => l_object_version_number
        ,p_effective_date                 => p_effective_date
        ,p_parent_entity_result_id        => l_out_pln_cpp_result_id
       );
     end loop;
    ---------------------------------------------------------------
    -- END OF BEN_PL_TYP_F ----------------------
    ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PL_REGN_F ----------------------
         ---------------------------------------------------------------
          --
          for l_parent_rec  in c_prg_from_parent(l_PL_ID) loop
          --
            l_mirror_src_entity_result_id := l_out_pln_result_id;
            l_parent_entity_result_id := l_out_pln_cpp_result_id;

            l_pl_regn_id := l_parent_rec.pl_regn_id ;

            if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
              open c_object_exists(l_pl_regn_id,'PRG');
              fetch c_object_exists into l_dummy;
              if c_object_exists%found then
                close c_object_exists;
                exit;
              end if;
              close c_object_exists;
            end if;

            --
            for l_prg_rec in c_prg(l_parent_rec.pl_regn_id,l_mirror_src_entity_result_id,'PRG') loop
            --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('PRG');
               fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
                --
              l_information5  := ben_plan_design_program_module.get_regn_name(l_prg_rec.regn_id,p_effective_date); --'Intersection';
                --
                if p_effective_date between l_prg_rec.effective_start_date
                    and l_prg_rec.effective_end_date then
                    --
                    l_result_type_cd := 'DISPLAY';
                else
                    l_result_type_cd := 'NO DISPLAY';
                end if;

                /* NOT REQUIRED AS create_REG_rows will handle this
                --
                -- Store the Regulation name in information185
                -- Records for Regulations (BEN_REGN_F) will not created in the Target Business Group
                -- The copy process will try and map the Regulation name to the ones existing in the
                -- Target Business Group and if a match is found, then that Regulation Id will be used
                -- for creating Plan Regulation (BEN_PL_REGN) records.

                l_regn_name :=  ben_plan_design_program_module.get_regn_name(l_prg_rec.regn_id,l_prg_rec.effective_start_date);
                --
                */

                l_copy_entity_result_id := null;
                l_object_version_number := null;
                ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id           => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_parent_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_alias					 => 'PRG',
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_prg_rec.pl_regn_id,
                     p_information2     => l_prg_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_prg_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_prg_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information259     => l_prg_rec.cntr_nndscrn_rl,
                     p_information260     => l_prg_rec.cvg_nndscrn_rl,
                     p_information262     => l_prg_rec.five_pct_ownr_rl,
                     p_information257     => l_prg_rec.hghly_compd_det_rl,
                     p_information258     => l_prg_rec.key_ee_det_rl,
                     p_information261     => l_prg_rec.pl_id,
                     p_information111     => l_prg_rec.prg_attribute1,
                     p_information120     => l_prg_rec.prg_attribute10,
                     p_information121     => l_prg_rec.prg_attribute11,
                     p_information122     => l_prg_rec.prg_attribute12,
                     p_information123     => l_prg_rec.prg_attribute13,
                     p_information124     => l_prg_rec.prg_attribute14,
                     p_information125     => l_prg_rec.prg_attribute15,
                     p_information126     => l_prg_rec.prg_attribute16,
                     p_information127     => l_prg_rec.prg_attribute17,
                     p_information128     => l_prg_rec.prg_attribute18,
                     p_information129     => l_prg_rec.prg_attribute19,
                     p_information112     => l_prg_rec.prg_attribute2,
                     p_information130     => l_prg_rec.prg_attribute20,
                     p_information131     => l_prg_rec.prg_attribute21,
                     p_information132     => l_prg_rec.prg_attribute22,
                     p_information133     => l_prg_rec.prg_attribute23,
                     p_information134     => l_prg_rec.prg_attribute24,
                     p_information135     => l_prg_rec.prg_attribute25,
                     p_information136     => l_prg_rec.prg_attribute26,
                     p_information137     => l_prg_rec.prg_attribute27,
                     p_information138     => l_prg_rec.prg_attribute28,
                     p_information139     => l_prg_rec.prg_attribute29,
                     p_information113     => l_prg_rec.prg_attribute3,
                     p_information140     => l_prg_rec.prg_attribute30,
                     p_information114     => l_prg_rec.prg_attribute4,
                     p_information115     => l_prg_rec.prg_attribute5,
                     p_information116     => l_prg_rec.prg_attribute6,
                     p_information117     => l_prg_rec.prg_attribute7,
                     p_information118     => l_prg_rec.prg_attribute8,
                     p_information119     => l_prg_rec.prg_attribute9,
                     p_information110     => l_prg_rec.prg_attribute_category,
                     p_information231     => l_prg_rec.regn_id,
                     p_information11      => l_prg_rec.regy_pl_typ_cd,
                     p_information242     => l_prg_rec.rptg_grp_id,
                     -- p_information185     => l_regn_name, -- NOT REQUIRED AS create_REG_rows will handle this
                     p_information265     => l_prg_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
              --

                     if l_out_prg_result_id is null then
                       l_out_prg_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                       l_out_prg_result_id := l_copy_entity_result_id ;
                     end if;

                      if (l_prg_rec.cntr_nndscrn_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_prg_rec.cntr_nndscrn_rl
								,p_business_group_id        => l_prg_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_prg_rec.cvg_nndscrn_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_prg_rec.cvg_nndscrn_rl
								,p_business_group_id        => l_prg_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_prg_rec.five_pct_ownr_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_prg_rec.five_pct_ownr_rl
								,p_business_group_id        => l_prg_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_prg_rec.hghly_compd_det_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_prg_rec.hghly_compd_det_rl
								,p_business_group_id        => l_prg_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_prg_rec.key_ee_det_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_prg_rec.key_ee_det_rl
								,p_business_group_id        => l_prg_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;
				--
              end loop;

        ---------------------------------------------------------------
        -- START OF BEN_REGN_F ----------------------
        ---------------------------------------------------------------
         --
         for l_parent_rec  in c_reg_from_parent(l_PL_REGN_ID) loop
         --
           l_mirror_src_entity_result_id := l_out_prg_result_id;

           l_regn_id := l_parent_rec.regn_id ;

           if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
             open c_object_exists(l_regn_id,'REG');
             fetch c_object_exists into l_dummy;
             if c_object_exists%found then
               close c_object_exists;
               exit;
             end if;
             close c_object_exists;
           end if;
           --
           for l_reg_rec in c_reg(l_parent_rec.regn_id,l_mirror_src_entity_result_id,'REG') loop
           --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('REG');
               fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
               --
               l_information5  := l_reg_rec.name; --'Intersection';
               --
               l_regn_id := l_reg_rec.regn_id ;
               if p_effective_date between l_reg_rec.effective_start_date
                   and l_reg_rec.effective_end_date then
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
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					 => 'REG',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_reg_rec.regn_id,
                    p_information2     => l_reg_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_reg_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_reg_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information170     => l_reg_rec.name,
                    p_information252     => l_reg_rec.organization_id,
                    p_information111     => l_reg_rec.reg_attribute1,
                    p_information120     => l_reg_rec.reg_attribute10,
                    p_information121     => l_reg_rec.reg_attribute11,
                    p_information122     => l_reg_rec.reg_attribute12,
                    p_information123     => l_reg_rec.reg_attribute13,
                    p_information124     => l_reg_rec.reg_attribute14,
                    p_information125     => l_reg_rec.reg_attribute15,
                    p_information126     => l_reg_rec.reg_attribute16,
                    p_information127     => l_reg_rec.reg_attribute17,
                    p_information128     => l_reg_rec.reg_attribute18,
                    p_information129     => l_reg_rec.reg_attribute19,
                    p_information112     => l_reg_rec.reg_attribute2,
                    p_information130     => l_reg_rec.reg_attribute20,
                    p_information131     => l_reg_rec.reg_attribute21,
                    p_information132     => l_reg_rec.reg_attribute22,
                    p_information133     => l_reg_rec.reg_attribute23,
                    p_information134     => l_reg_rec.reg_attribute24,
                    p_information135     => l_reg_rec.reg_attribute25,
                    p_information136     => l_reg_rec.reg_attribute26,
                    p_information137     => l_reg_rec.reg_attribute27,
                    p_information138     => l_reg_rec.reg_attribute28,
                    p_information139     => l_reg_rec.reg_attribute29,
                    p_information113     => l_reg_rec.reg_attribute3,
                    p_information140     => l_reg_rec.reg_attribute30,
                    p_information114     => l_reg_rec.reg_attribute4,
                    p_information115     => l_reg_rec.reg_attribute5,
                    p_information116     => l_reg_rec.reg_attribute6,
                    p_information117     => l_reg_rec.reg_attribute7,
                    p_information118     => l_reg_rec.reg_attribute8,
                    p_information119     => l_reg_rec.reg_attribute9,
                    p_information110     => l_reg_rec.reg_attribute_category,
                    p_information185     => l_reg_rec.sttry_citn_name,
                    p_information265     => l_reg_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
             --

               if l_out_reg_result_id is null then
                 l_out_reg_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                 l_out_reg_result_id := l_copy_entity_result_id ;
               end if;

             end loop;
           --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_REGN_F ----------------------
        ---------------------------------------------------------------
            --
       ---------------------------------------------------------------
       -- START OF BEN_RPTG_GRP ----------------------
       ---------------------------------------------------------------
        --
        for l_parent_rec  in c_bnr_from_parent(l_PL_REGN_ID) loop
        --

          l_mirror_src_entity_result_id := l_out_prg_result_id ;

          l_rptg_grp_id := l_parent_rec.rptg_grp_id ;

          if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
            open c_object_exists(l_rptg_grp_id,'BNR');
            fetch c_object_exists into l_dummy;
            if c_object_exists%found then
              close c_object_exists;
              exit;
            end if;
            close c_object_exists;
          end if;

          --
          for l_bnr_rec in c_bnr(l_parent_rec.rptg_grp_id,l_mirror_src_entity_result_id,'BNR') loop
          --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('BNR');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_bnr_rec.name; --'Intersection';
              --
              l_rptg_grp_id := l_bnr_rec.rptg_grp_id ;
              l_result_type_cd := 'DISPLAY';
              --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id           => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_alias					 => 'BNR',
                   p_table_route_id                 => l_table_route_id,
                   p_information1     => l_bnr_rec.rptg_grp_id,
                   p_information2     => null,
                   p_information3     => null,
                   p_information4     => l_bnr_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
                   p_information111     => l_bnr_rec.bnr_attribute1,
                   p_information120     => l_bnr_rec.bnr_attribute10,
                   p_information121     => l_bnr_rec.bnr_attribute11,
                   p_information122     => l_bnr_rec.bnr_attribute12,
                   p_information123     => l_bnr_rec.bnr_attribute13,
                   p_information124     => l_bnr_rec.bnr_attribute14,
                   p_information125     => l_bnr_rec.bnr_attribute15,
                   p_information126     => l_bnr_rec.bnr_attribute16,
                   p_information127     => l_bnr_rec.bnr_attribute17,
                   p_information128     => l_bnr_rec.bnr_attribute18,
                   p_information129     => l_bnr_rec.bnr_attribute19,
                   p_information112     => l_bnr_rec.bnr_attribute2,
                   p_information130     => l_bnr_rec.bnr_attribute20,
                   p_information131     => l_bnr_rec.bnr_attribute21,
                   p_information132     => l_bnr_rec.bnr_attribute22,
                   p_information133     => l_bnr_rec.bnr_attribute23,
                   p_information134     => l_bnr_rec.bnr_attribute24,
                   p_information135     => l_bnr_rec.bnr_attribute25,
                   p_information136     => l_bnr_rec.bnr_attribute26,
                   p_information137     => l_bnr_rec.bnr_attribute27,
                   p_information138     => l_bnr_rec.bnr_attribute28,
                   p_information139     => l_bnr_rec.bnr_attribute29,
                   p_information113     => l_bnr_rec.bnr_attribute3,
                   p_information140     => l_bnr_rec.bnr_attribute30,
                   p_information114     => l_bnr_rec.bnr_attribute4,
                   p_information115     => l_bnr_rec.bnr_attribute5,
                   p_information116     => l_bnr_rec.bnr_attribute6,
                   p_information117     => l_bnr_rec.bnr_attribute7,
                   p_information118     => l_bnr_rec.bnr_attribute8,
                   p_information119     => l_bnr_rec.bnr_attribute9,
                   p_information110     => l_bnr_rec.bnr_attribute_category,
                   p_information11     => l_bnr_rec.function_code,
                   p_information12     => l_bnr_rec.legislation_code,
                   p_information170     => l_bnr_rec.name,
                   p_information185     => l_bnr_rec.rpg_desc,
                   p_information13     => l_bnr_rec.rptg_prps_cd,
                   p_information265    => l_bnr_rec.object_version_number,
                   p_object_version_number          => l_object_version_number,
                   p_effective_date                 => p_effective_date       );
               --

               if l_out_bnr_result_id is null then
                 l_out_bnr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                 l_out_bnr_result_id := l_copy_entity_result_id ;
               end if;

            end loop;

               ---------------------------------------------------------------
               -- START OF BEN_PL_REGN_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_prg1_from_parent(l_RPTG_GRP_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_bnr_result_id ;
                  --
                  l_pl_regn_id1 := l_parent_rec.pl_regn_id ;

                  if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
                    open c_object_exists(l_pl_regn_id1,'PRG');
                    fetch c_object_exists into l_dummy;
                    if c_object_exists%found then
                      close c_object_exists;
                      exit;
                    end if;
                    close c_object_exists;
                  end if;

                  --
                  for l_prg_rec in c_prg1(l_parent_rec.pl_regn_id,l_mirror_src_entity_result_id,'PRG') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('PRG');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := ben_plan_design_program_module.get_regn_name(l_prg_rec.regn_id,
                                                              p_effective_date);
                    --
                    if p_effective_date between l_prg_rec.effective_start_date
                       and l_prg_rec.effective_end_date then
                     --
                       l_result_type_cd := 'DISPLAY';
                    else
                       l_result_type_cd := 'NO DISPLAY';
                    end if;

                    /* NOT REQUIRED AS create_REG_rows will handle this
                    --
                    -- Store the Regulation name in information185
                    -- Records for Regulations (BEN_REGN_F) will not created in the Target Business Group
                    -- The copy process will try and map the Regulation name to the ones existing in the
                    -- Target Business Group and if a match is found, then that Regulation Id will be used
                    -- for creating Plan Regulation (BEN_PL_REGN) records.

                    l_regn_name :=  ben_plan_design_program_module.get_regn_name(l_prg_rec.regn_id,l_prg_rec.effective_start_date);
                    --
                    */

                    l_copy_entity_result_id := null;
                    l_object_version_number := null;
                    ben_copy_entity_results_api.create_copy_entity_results(
                      p_copy_entity_result_id           => l_copy_entity_result_id,
                      p_copy_entity_txn_id             => p_copy_entity_txn_id,
                      p_result_type_cd                 => l_result_type_cd,
                      p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'PRG',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_prg_rec.pl_regn_id,
                      p_information2     => l_prg_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_prg_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_prg_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information259     => l_prg_rec.cntr_nndscrn_rl,
                      p_information260     => l_prg_rec.cvg_nndscrn_rl,
                      p_information262     => l_prg_rec.five_pct_ownr_rl,
                      p_information257     => l_prg_rec.hghly_compd_det_rl,
                      p_information258     => l_prg_rec.key_ee_det_rl,
                      p_information261     => l_prg_rec.pl_id,
                      p_information111     => l_prg_rec.prg_attribute1,
                      p_information120     => l_prg_rec.prg_attribute10,
                      p_information121     => l_prg_rec.prg_attribute11,
                      p_information122     => l_prg_rec.prg_attribute12,
                      p_information123     => l_prg_rec.prg_attribute13,
                      p_information124     => l_prg_rec.prg_attribute14,
                      p_information125     => l_prg_rec.prg_attribute15,
                      p_information126     => l_prg_rec.prg_attribute16,
                      p_information127     => l_prg_rec.prg_attribute17,
                      p_information128     => l_prg_rec.prg_attribute18,
                      p_information129     => l_prg_rec.prg_attribute19,
                      p_information112     => l_prg_rec.prg_attribute2,
                      p_information130     => l_prg_rec.prg_attribute20,
                      p_information131     => l_prg_rec.prg_attribute21,
                      p_information132     => l_prg_rec.prg_attribute22,
                      p_information133     => l_prg_rec.prg_attribute23,
                      p_information134     => l_prg_rec.prg_attribute24,
                      p_information135     => l_prg_rec.prg_attribute25,
                      p_information136     => l_prg_rec.prg_attribute26,
                      p_information137     => l_prg_rec.prg_attribute27,
                      p_information138     => l_prg_rec.prg_attribute28,
                      p_information139     => l_prg_rec.prg_attribute29,
                      p_information113     => l_prg_rec.prg_attribute3,
                      p_information140     => l_prg_rec.prg_attribute30,
                      p_information114     => l_prg_rec.prg_attribute4,
                      p_information115     => l_prg_rec.prg_attribute5,
                      p_information116     => l_prg_rec.prg_attribute6,
                      p_information117     => l_prg_rec.prg_attribute7,
                      p_information118     => l_prg_rec.prg_attribute8,
                      p_information119     => l_prg_rec.prg_attribute9,
                      p_information110     => l_prg_rec.prg_attribute_category,
                      p_information231     => l_prg_rec.regn_id,
                      p_information11     => l_prg_rec.regy_pl_typ_cd,
                      p_information242     => l_prg_rec.rptg_grp_id,
                      -- p_information185     => l_regn_name, -- NOT REQUIRED AS create_REG_rows will handle this
                      p_information265     => l_prg_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_prg1_result_id is null then
                        l_out_prg1_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_prg1_result_id := l_copy_entity_result_id ;
                      end if;
                      --
                   end loop;
                   --
                   ---------------------------------------------------------------
                   -- START OF BEN_REGN_F ----------------------
                   ---------------------------------------------------------------
                   --
                   for l_parent_rec  in c_reg_from_parent(l_PL_REGN_ID1) loop
                      --
                      l_mirror_src_entity_result_id := l_out_prg1_result_id ;
                      --
                      l_regn_id := l_parent_rec.regn_id ;

                      if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
                        open c_object_exists(l_regn_id,'REG');
                        fetch c_object_exists into l_dummy;
                        if c_object_exists%found then
                          close c_object_exists;
                          exit;
                        end if;
                        close c_object_exists;
                      end if;
                      --
                      for l_reg_rec in c_reg(l_parent_rec.regn_id,l_mirror_src_entity_result_id,'REG') loop
                        --
                        l_table_route_id := null ;
                        open ben_plan_design_program_module.g_table_route('REG');
                          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                        close ben_plan_design_program_module.g_table_route ;
                        --
                        l_information5  := l_reg_rec.name ;
                        --
                        if p_effective_date between l_reg_rec.effective_start_date
                           and l_reg_rec.effective_end_date then
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
                          p_table_alias					 => 'REG',
                          p_table_route_id                 => l_table_route_id,
                          p_information1     => l_reg_rec.regn_id,
                          p_information2     => l_reg_rec.EFFECTIVE_START_DATE,
                          p_information3     => l_reg_rec.EFFECTIVE_END_DATE,
                          p_information4     => l_reg_rec.business_group_id,
                          p_information5     => l_information5 , -- 9999 put name for h-grid
                          p_information170     => l_reg_rec.name,
                          p_information252     => l_reg_rec.organization_id,
                          p_information111     => l_reg_rec.reg_attribute1,
                          p_information120     => l_reg_rec.reg_attribute10,
                          p_information121     => l_reg_rec.reg_attribute11,
                          p_information122     => l_reg_rec.reg_attribute12,
                          p_information123     => l_reg_rec.reg_attribute13,
                          p_information124     => l_reg_rec.reg_attribute14,
                          p_information125     => l_reg_rec.reg_attribute15,
                          p_information126     => l_reg_rec.reg_attribute16,
                          p_information127     => l_reg_rec.reg_attribute17,
                          p_information128     => l_reg_rec.reg_attribute18,
                          p_information129     => l_reg_rec.reg_attribute19,
                          p_information112     => l_reg_rec.reg_attribute2,
                          p_information130     => l_reg_rec.reg_attribute20,
                          p_information131     => l_reg_rec.reg_attribute21,
                          p_information132     => l_reg_rec.reg_attribute22,
                          p_information133     => l_reg_rec.reg_attribute23,
                          p_information134     => l_reg_rec.reg_attribute24,
                          p_information135     => l_reg_rec.reg_attribute25,
                          p_information136     => l_reg_rec.reg_attribute26,
                          p_information137     => l_reg_rec.reg_attribute27,
                          p_information138     => l_reg_rec.reg_attribute28,
                          p_information139     => l_reg_rec.reg_attribute29,
                          p_information113     => l_reg_rec.reg_attribute3,
                          p_information140     => l_reg_rec.reg_attribute30,
                          p_information114     => l_reg_rec.reg_attribute4,
                          p_information115     => l_reg_rec.reg_attribute5,
                          p_information116     => l_reg_rec.reg_attribute6,
                          p_information117     => l_reg_rec.reg_attribute7,
                          p_information118     => l_reg_rec.reg_attribute8,
                          p_information119     => l_reg_rec.reg_attribute9,
                          p_information110     => l_reg_rec.reg_attribute_category,
                          p_information185     => l_reg_rec.sttry_citn_name,
                          p_information265     => l_reg_rec.object_version_number,
                          p_object_version_number          => l_object_version_number,
                          p_effective_date                 => p_effective_date       );
                          --

                          if l_out_reg1_result_id is null then
                            l_out_reg1_result_id := l_copy_entity_result_id;
                          end if;

                          if l_result_type_cd = 'DISPLAY' then
                             l_out_reg1_result_id := l_copy_entity_result_id ;
                          end if;
                          --
                       end loop;
                       --
                     end loop;
                  ---------------------------------------------------------------
                  -- END OF BEN_REGN_F ----------------------
                  ---------------------------------------------------------------
                 end loop;
              ---------------------------------------------------------------
              -- END OF BEN_PL_REGN_F ----------------------
              ---------------------------------------------------------------
               ---------------------------------------------------------------
               -- START OF BEN_PL_REGY_BOD_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_prb_from_parent(l_RPTG_GRP_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_bnr_result_id ;
                  --
                  l_pl_regy_bod_id := l_parent_rec.pl_regy_bod_id ;
                  --
                  for l_prb_rec in c_prb(l_parent_rec.pl_regy_bod_id,l_mirror_src_entity_result_id,'PRB') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('PRB');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := l_prb_rec.regy_pl_name ;
                    --
                    if p_effective_date between l_prb_rec.effective_start_date
                       and l_prb_rec.effective_end_date then
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
                      p_table_alias					 => 'PRB',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_prb_rec.pl_regy_bod_id,
                      p_information2     => l_prb_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_prb_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_prb_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information306     => l_prb_rec.aprvd_trmn_dt,
                      p_information252     => l_prb_rec.organization_id,
                      p_information261     => l_prb_rec.pl_id,
                      p_information111     => l_prb_rec.prb_attribute1,
                      p_information120     => l_prb_rec.prb_attribute10,
                      p_information121     => l_prb_rec.prb_attribute11,
                      p_information122     => l_prb_rec.prb_attribute12,
                      p_information123     => l_prb_rec.prb_attribute13,
                      p_information124     => l_prb_rec.prb_attribute14,
                      p_information125     => l_prb_rec.prb_attribute15,
                      p_information126     => l_prb_rec.prb_attribute16,
                      p_information127     => l_prb_rec.prb_attribute17,
                      p_information128     => l_prb_rec.prb_attribute18,
                      p_information129     => l_prb_rec.prb_attribute19,
                      p_information112     => l_prb_rec.prb_attribute2,
                      p_information130     => l_prb_rec.prb_attribute20,
                      p_information131     => l_prb_rec.prb_attribute21,
                      p_information132     => l_prb_rec.prb_attribute22,
                      p_information133     => l_prb_rec.prb_attribute23,
                      p_information134     => l_prb_rec.prb_attribute24,
                      p_information135     => l_prb_rec.prb_attribute25,
                      p_information136     => l_prb_rec.prb_attribute26,
                      p_information137     => l_prb_rec.prb_attribute27,
                      p_information138     => l_prb_rec.prb_attribute28,
                      p_information139     => l_prb_rec.prb_attribute29,
                      p_information113     => l_prb_rec.prb_attribute3,
                      p_information140     => l_prb_rec.prb_attribute30,
                      p_information114     => l_prb_rec.prb_attribute4,
                      p_information115     => l_prb_rec.prb_attribute5,
                      p_information116     => l_prb_rec.prb_attribute6,
                      p_information117     => l_prb_rec.prb_attribute7,
                      p_information118     => l_prb_rec.prb_attribute8,
                      p_information119     => l_prb_rec.prb_attribute9,
                      p_information110     => l_prb_rec.prb_attribute_category,
                      p_information309     => l_prb_rec.quald_dt,
                      p_information11      => l_prb_rec.quald_flag,
                      p_information185     => l_prb_rec.regy_pl_name,
                      p_information242     => l_prb_rec.rptg_grp_id,
                      p_information265     => l_prb_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_prb_result_id is null then
                        l_out_prb_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_prb_result_id := l_copy_entity_result_id ;
                      end if;
                      --
                   end loop;
                   --
                   ---------------------------------------------------------------
                   -- START OF BEN_PL_REGY_PRP_F ----------------------
                   ---------------------------------------------------------------
                   --
                   for l_parent_rec  in c_prp_from_parent(l_PL_REGY_BOD_ID) loop
                      --
                      l_mirror_src_entity_result_id := l_out_prb_result_id ;
                      --
                      l_pl_regy_prps_id := l_parent_rec.pl_regy_prps_id ;
                      --
                      for l_prp_rec in c_prp(l_parent_rec.pl_regy_prps_id,l_mirror_src_entity_result_id,'PRP') loop
                        --
                        l_table_route_id := null ;
                        open ben_plan_design_program_module.g_table_route('PRP');
                          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                        close ben_plan_design_program_module.g_table_route ;
                        --
                        l_information5  := hr_general.decode_lookup('BEN_REGY_PRPS',l_prp_rec.pl_regy_prps_cd);
                        --
                        if p_effective_date between l_prp_rec.effective_start_date
                           and l_prp_rec.effective_end_date then
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
                          p_table_alias					 => 'PRP',
                          p_table_route_id                 => l_table_route_id,
                          p_information1     => l_prp_rec.pl_regy_prps_id,
                          p_information2     => l_prp_rec.EFFECTIVE_START_DATE,
                          p_information3     => l_prp_rec.EFFECTIVE_END_DATE,
                          p_information4     => l_prp_rec.business_group_id,
                          p_information5     => l_information5 , -- 9999 put name for h-grid
                          p_information258     => l_prp_rec.pl_regy_bod_id,
                          p_information11     => l_prp_rec.pl_regy_prps_cd,
                          p_information257     => l_prp_rec.pl_regy_prps_id,
                          p_information111     => l_prp_rec.prp_attribute1,
                          p_information120     => l_prp_rec.prp_attribute10,
                          p_information121     => l_prp_rec.prp_attribute11,
                          p_information122     => l_prp_rec.prp_attribute12,
                          p_information123     => l_prp_rec.prp_attribute13,
                          p_information124     => l_prp_rec.prp_attribute14,
                          p_information125     => l_prp_rec.prp_attribute15,
                          p_information126     => l_prp_rec.prp_attribute16,
                          p_information127     => l_prp_rec.prp_attribute17,
                          p_information128     => l_prp_rec.prp_attribute18,
                          p_information129     => l_prp_rec.prp_attribute19,
                          p_information112     => l_prp_rec.prp_attribute2,
                          p_information130     => l_prp_rec.prp_attribute20,
                          p_information131     => l_prp_rec.prp_attribute21,
                          p_information132     => l_prp_rec.prp_attribute22,
                          p_information133     => l_prp_rec.prp_attribute23,
                          p_information134     => l_prp_rec.prp_attribute24,
                          p_information135     => l_prp_rec.prp_attribute25,
                          p_information136     => l_prp_rec.prp_attribute26,
                          p_information137     => l_prp_rec.prp_attribute27,
                          p_information138     => l_prp_rec.prp_attribute28,
                          p_information139     => l_prp_rec.prp_attribute29,
                          p_information113     => l_prp_rec.prp_attribute3,
                          p_information140     => l_prp_rec.prp_attribute30,
                          p_information114     => l_prp_rec.prp_attribute4,
                          p_information115     => l_prp_rec.prp_attribute5,
                          p_information116     => l_prp_rec.prp_attribute6,
                          p_information117     => l_prp_rec.prp_attribute7,
                          p_information118     => l_prp_rec.prp_attribute8,
                          p_information119     => l_prp_rec.prp_attribute9,
                          p_information110     => l_prp_rec.prp_attribute_category,
                          p_information265     => l_prp_rec.object_version_number,
                          p_object_version_number          => l_object_version_number,
                          p_effective_date                 => p_effective_date       );
                          --

                          if l_out_prp_result_id is null then
                            l_out_prp_result_id := l_copy_entity_result_id;
                          end if;

                          if l_result_type_cd = 'DISPLAY' then
                             l_out_prp_result_id := l_copy_entity_result_id ;
                          end if;
                          --
                       end loop;
                       --
                     end loop;
                  ---------------------------------------------------------------
                  -- END OF BEN_PL_REGY_PRP_F ----------------------
                  ---------------------------------------------------------------
                 end loop;
              ---------------------------------------------------------------
              -- END OF BEN_PL_REGY_BOD_F ----------------------
              ---------------------------------------------------------------
               ---------------------------------------------------------------
               -- START OF BEN_POPL_RPTG_GRP_F ----------------------
               ---------------------------------------------------------------
               --
               /* NOT REQUIRED HERE

               */
              ---------------------------------------------------------------
              -- END OF BEN_POPL_RPTG_GRP_F ----------------------
              ---------------------------------------------------------------
          --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_RPTG_GRP ----------------------
       ---------------------------------------------------------------
       end loop;
       ---------------------------------------------------------------
       -- END OF BEN_PL_REGN_F ----------------------
       ---------------------------------------------------------------
       -- ------------------------------------------------------------------------
       -- BEN_PL_GD_SVC_F
       -- -------------------------------------------------------------------------
       --
       for l_parent_rec  in c_vgs_from_parent(L_PL_ID) loop
       --
         l_mirror_src_entity_result_id := l_out_pln_result_id;
         l_parent_entity_result_id := l_out_pln_cpp_result_id;

         l_pl_gd_or_svc_id           := l_parent_rec.pl_gd_or_svc_id ;

         --
         for l_vgs_rec in c_vgs(l_parent_rec.pl_gd_or_svc_id,l_mirror_src_entity_result_id,'VGS') loop
         --
           l_table_route_id := null ;
           open ben_plan_design_program_module.g_table_route('VGS');
           fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
           close ben_plan_design_program_module.g_table_route ;
           --
           l_information5 := ben_plan_design_program_module.get_gd_or_svc_typ_name(l_vgs_rec.gd_or_svc_typ_id); --'Intersection'
           --
           if p_effective_date between l_vgs_rec.effective_start_date
               and l_vgs_rec.effective_end_date then
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
                p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_parent_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_alias					 => 'VGS',
                p_table_route_id                 => l_table_route_id,
                p_information1     => l_vgs_rec.pl_gd_or_svc_id,
                p_information2     => l_vgs_rec.EFFECTIVE_START_DATE,
                p_information3     => l_vgs_rec.EFFECTIVE_END_DATE,
                p_information4     => l_vgs_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
                p_information13     => l_vgs_rec.alw_rcrrg_clms_flag,
                p_information262     => l_vgs_rec.gd_or_svc_typ_id,
                p_information12     => l_vgs_rec.gd_or_svc_usg_cd,
                p_information11     => l_vgs_rec.gd_svc_recd_basis_cd,
                p_information306     => l_vgs_rec.gd_svc_recd_basis_dt,
                p_information257     => l_vgs_rec.gd_svc_recd_basis_mo,
                p_information261     => l_vgs_rec.pl_id,
                p_information111     => l_vgs_rec.vgs_attribute1,
                p_information120     => l_vgs_rec.vgs_attribute10,
                p_information121     => l_vgs_rec.vgs_attribute11,
                p_information122     => l_vgs_rec.vgs_attribute12,
                p_information123     => l_vgs_rec.vgs_attribute13,
                p_information124     => l_vgs_rec.vgs_attribute14,
                p_information125     => l_vgs_rec.vgs_attribute15,
                p_information126     => l_vgs_rec.vgs_attribute16,
                p_information127     => l_vgs_rec.vgs_attribute17,
                p_information128     => l_vgs_rec.vgs_attribute18,
                p_information129     => l_vgs_rec.vgs_attribute19,
                p_information112     => l_vgs_rec.vgs_attribute2,
                p_information130     => l_vgs_rec.vgs_attribute20,
                p_information131     => l_vgs_rec.vgs_attribute21,
                p_information132     => l_vgs_rec.vgs_attribute22,
                p_information133     => l_vgs_rec.vgs_attribute23,
                p_information134     => l_vgs_rec.vgs_attribute24,
                p_information135     => l_vgs_rec.vgs_attribute25,
                p_information136     => l_vgs_rec.vgs_attribute26,
                p_information137     => l_vgs_rec.vgs_attribute27,
                p_information138     => l_vgs_rec.vgs_attribute28,
                p_information139     => l_vgs_rec.vgs_attribute29,
                p_information113     => l_vgs_rec.vgs_attribute3,
                p_information140     => l_vgs_rec.vgs_attribute30,
                p_information114     => l_vgs_rec.vgs_attribute4,
                p_information115     => l_vgs_rec.vgs_attribute5,
                p_information116     => l_vgs_rec.vgs_attribute6,
                p_information117     => l_vgs_rec.vgs_attribute7,
                p_information118     => l_vgs_rec.vgs_attribute8,
                p_information119     => l_vgs_rec.vgs_attribute9,
                p_information110     => l_vgs_rec.vgs_attribute_category,
                p_information265     => l_vgs_rec.object_version_number,
                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
         --

           if l_out_vgs_result_id is null then
             l_out_vgs_result_id := l_copy_entity_result_id;
           end if;

           if l_result_type_cd = 'DISPLAY' then
             l_out_vgs_result_id := l_copy_entity_result_id ;
           end if;

         end loop;

          ---------------------------------------------------------------
          -- START OF BEN_GD_OR_SVC_TYP ----------------------
          ---------------------------------------------------------------
           --
           for l_parent_rec  in c_gos_from_parent(l_PL_GD_OR_SVC_ID) loop
           --
             l_mirror_src_entity_result_id := l_out_vgs_result_id;

             l_gd_or_svc_typ_id :=  l_parent_rec.gd_or_svc_typ_id ;

             if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
               open c_object_exists(l_gd_or_svc_typ_id,'GOS');
               fetch c_object_exists into l_dummy;
               if c_object_exists%found then
                 close c_object_exists;
                 exit;
               end if;
               close c_object_exists;
             end if;

             --
             for l_gos_rec in c_gos(l_parent_rec.gd_or_svc_typ_id,l_mirror_src_entity_result_id,'GOS') loop
             --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('GOS');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := l_gos_rec.name; --'Intersection';
                 --
                 l_gd_or_svc_typ_id := l_gos_rec.gd_or_svc_typ_id ;
                 l_result_type_cd := 'DISPLAY';
                 --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                      p_copy_entity_result_id           => l_copy_entity_result_id,
                      p_copy_entity_txn_id             => p_copy_entity_txn_id,
                      p_result_type_cd                 => l_result_type_cd,
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'GOS',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_gos_rec.gd_or_svc_typ_id,
                      p_information2     => null,
                      p_information3     => null,
                      p_information4     => l_gos_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information185     => l_gos_rec.description,
                      p_information111     => l_gos_rec.gos_attribute1,
                      p_information120     => l_gos_rec.gos_attribute10,
                      p_information121     => l_gos_rec.gos_attribute11,
                      p_information122     => l_gos_rec.gos_attribute12,
                      p_information123     => l_gos_rec.gos_attribute13,
                      p_information124     => l_gos_rec.gos_attribute14,
                      p_information125     => l_gos_rec.gos_attribute15,
                      p_information126     => l_gos_rec.gos_attribute16,
                      p_information127     => l_gos_rec.gos_attribute17,
                      p_information128     => l_gos_rec.gos_attribute18,
                      p_information129     => l_gos_rec.gos_attribute19,
                      p_information112     => l_gos_rec.gos_attribute2,
                      p_information130     => l_gos_rec.gos_attribute20,
                      p_information131     => l_gos_rec.gos_attribute21,
                      p_information132     => l_gos_rec.gos_attribute22,
                      p_information133     => l_gos_rec.gos_attribute23,
                      p_information134     => l_gos_rec.gos_attribute24,
                      p_information135     => l_gos_rec.gos_attribute25,
                      p_information136     => l_gos_rec.gos_attribute26,
                      p_information137     => l_gos_rec.gos_attribute27,
                      p_information138     => l_gos_rec.gos_attribute28,
                      p_information139     => l_gos_rec.gos_attribute29,
                      p_information113     => l_gos_rec.gos_attribute3,
                      p_information140     => l_gos_rec.gos_attribute30,
                      p_information114     => l_gos_rec.gos_attribute4,
                      p_information115     => l_gos_rec.gos_attribute5,
                      p_information116     => l_gos_rec.gos_attribute6,
                      p_information117     => l_gos_rec.gos_attribute7,
                      p_information118     => l_gos_rec.gos_attribute8,
                      p_information119     => l_gos_rec.gos_attribute9,
                      p_information110     => l_gos_rec.gos_attribute_category,
                      p_information170     => l_gos_rec.name,
                      p_information11     => l_gos_rec.typ_cd,
                      p_information265    => l_gos_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
               --

                 if l_out_gos_result_id is null then
                   l_out_gos_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_gos_result_id := l_copy_entity_result_id ;
                 end if;

               end loop;
             --
             end loop;
          ---------------------------------------------------------------
          -- END OF BEN_GD_OR_SVC_TYP ----------------------
          ---------------------------------------------------------------
          ---------------------------------------------------------------
          -- START OF BEN_PL_GD_R_SVC_CTFN_F ----------------------
          ---------------------------------------------------------------
           --
           for l_parent_rec  in c_pct_from_parent(l_PL_GD_OR_SVC_ID) loop
           --
             l_mirror_src_entity_result_id := l_out_vgs_result_id;

             l_pl_gd_r_svc_ctfn_id := l_parent_rec.pl_gd_r_svc_ctfn_id ;
             --
             for l_pct_rec in c_pct(l_parent_rec.pl_gd_r_svc_ctfn_id,l_mirror_src_entity_result_id,'PCT') loop
             --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('PCT');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5 := hr_general.decode_lookup('BEN_REIMBMT_CTFN_TYP',l_pct_rec.rmbmt_ctfn_typ_cd); --'Intersection
                 --
                 l_pl_gd_r_svc_ctfn_id := l_pct_rec.pl_gd_r_svc_ctfn_id ;
                 if p_effective_date between l_pct_rec.effective_start_date
                     and l_pct_rec.effective_end_date then
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
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'PCT',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_pct_rec.pl_gd_r_svc_ctfn_id,
                      p_information2     => l_pct_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_pct_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_pct_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information257     => l_pct_rec.ctfn_rqd_when_rl,
                      p_information14     => l_pct_rec.lack_ctfn_deny_rmbmt_flag,
                      p_information259     => l_pct_rec.lack_ctfn_deny_rmbmt_rl,
                      p_information111     => l_pct_rec.pct_attribute1,
                      p_information120     => l_pct_rec.pct_attribute10,
                      p_information121     => l_pct_rec.pct_attribute11,
                      p_information122     => l_pct_rec.pct_attribute12,
                      p_information123     => l_pct_rec.pct_attribute13,
                      p_information124     => l_pct_rec.pct_attribute14,
                      p_information125     => l_pct_rec.pct_attribute15,
                      p_information126     => l_pct_rec.pct_attribute16,
                      p_information127     => l_pct_rec.pct_attribute17,
                      p_information128     => l_pct_rec.pct_attribute18,
                      p_information129     => l_pct_rec.pct_attribute19,
                      p_information112     => l_pct_rec.pct_attribute2,
                      p_information130     => l_pct_rec.pct_attribute20,
                      p_information131     => l_pct_rec.pct_attribute21,
                      p_information132     => l_pct_rec.pct_attribute22,
                      p_information133     => l_pct_rec.pct_attribute23,
                      p_information134     => l_pct_rec.pct_attribute24,
                      p_information135     => l_pct_rec.pct_attribute25,
                      p_information136     => l_pct_rec.pct_attribute26,
                      p_information137     => l_pct_rec.pct_attribute27,
                      p_information138     => l_pct_rec.pct_attribute28,
                      p_information139     => l_pct_rec.pct_attribute29,
                      p_information113     => l_pct_rec.pct_attribute3,
                      p_information140     => l_pct_rec.pct_attribute30,
                      p_information114     => l_pct_rec.pct_attribute4,
                      p_information115     => l_pct_rec.pct_attribute5,
                      p_information116     => l_pct_rec.pct_attribute6,
                      p_information117     => l_pct_rec.pct_attribute7,
                      p_information118     => l_pct_rec.pct_attribute8,
                      p_information119     => l_pct_rec.pct_attribute9,
                      p_information110     => l_pct_rec.pct_attribute_category,
                      p_information13     => l_pct_rec.pfd_flag,
                      p_information258     => l_pct_rec.pl_gd_or_svc_id,
                      p_information12     => l_pct_rec.rmbmt_ctfn_typ_cd,
                      p_information11     => l_pct_rec.rqd_flag,
                      p_information265    => l_pct_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                   --

                   if l_out_pct_result_id is null then
                     l_out_pct_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                     l_out_pct_result_id := l_copy_entity_result_id ;
                   end if;

                      if (l_pct_rec.ctfn_rqd_when_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_pct_rec.ctfn_rqd_when_rl
								,p_business_group_id        => l_pct_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_pct_rec.lack_ctfn_deny_rmbmt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_pct_rec.lack_ctfn_deny_rmbmt_rl
								,p_business_group_id        => l_pct_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

				 --
               end loop;
             --
             end loop;
       ---------------------------------------------------------------
       -- END OF BEN_PL_GD_R_SVC_CTFN_F ----------------------
       ---------------------------------------------------------------
       end loop;

	 ---------------------------------------------------------------
	 -- START OF BEN_VALD_RLSHP_FOR_REIMB_F ----------------------
	 ---------------------------------------------------------------
	 --
	 for l_parent_rec  in c_vrp_from_parent(l_PL_ID) loop
	 --
           l_mirror_src_entity_result_id := l_out_pln_result_id;
           l_parent_entity_result_id := l_out_pln_cpp_result_id;

           l_vald_rlshp_for_reimb_id := l_parent_rec.vald_rlshp_for_reimb_id ;
	     --
	     for l_vrp_rec in c_vrp(l_parent_rec.vald_rlshp_for_reimb_id,l_mirror_src_entity_result_id,'VRP') loop
	     --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('VRP');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5 := hr_general.decode_lookup('CONTACT',l_vrp_rec.rlshp_typ_cd); --'Intersection
             --
	       if p_effective_date between l_vrp_rec.effective_start_date
	           and l_vrp_rec.effective_end_date then
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
                  p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                  p_parent_entity_result_id        => l_parent_entity_result_id,
	            p_number_of_copies               => l_number_of_copies,
	            p_table_alias					 => 'VRP',
                  p_table_route_id                 => l_table_route_id,
	            p_information1     => l_vrp_rec.vald_rlshp_for_reimb_id,
	            p_information2     => l_vrp_rec.EFFECTIVE_START_DATE,
	            p_information3     => l_vrp_rec.EFFECTIVE_END_DATE,
	            p_information4     => l_vrp_rec.business_group_id,
	            p_information5     => l_information5 , -- 9999 put name for h-grid
	            p_information261     => l_vrp_rec.pl_id,
	            p_information11     => l_vrp_rec.rlshp_typ_cd,
	            p_information111     => l_vrp_rec.vrp_attribute1,
	            p_information120     => l_vrp_rec.vrp_attribute10,
	            p_information121     => l_vrp_rec.vrp_attribute11,
	            p_information122     => l_vrp_rec.vrp_attribute12,
	            p_information123     => l_vrp_rec.vrp_attribute13,
	            p_information124     => l_vrp_rec.vrp_attribute14,
	            p_information125     => l_vrp_rec.vrp_attribute15,
	            p_information126     => l_vrp_rec.vrp_attribute16,
	            p_information127     => l_vrp_rec.vrp_attribute17,
	            p_information128     => l_vrp_rec.vrp_attribute18,
	            p_information129     => l_vrp_rec.vrp_attribute19,
	            p_information112     => l_vrp_rec.vrp_attribute2,
	            p_information130     => l_vrp_rec.vrp_attribute20,
	            p_information131     => l_vrp_rec.vrp_attribute21,
	            p_information132     => l_vrp_rec.vrp_attribute22,
	            p_information133     => l_vrp_rec.vrp_attribute23,
	            p_information134     => l_vrp_rec.vrp_attribute24,
	            p_information135     => l_vrp_rec.vrp_attribute25,
	            p_information136     => l_vrp_rec.vrp_attribute26,
	            p_information137     => l_vrp_rec.vrp_attribute27,
	            p_information138     => l_vrp_rec.vrp_attribute28,
	            p_information139     => l_vrp_rec.vrp_attribute29,
	            p_information113     => l_vrp_rec.vrp_attribute3,
	            p_information140     => l_vrp_rec.vrp_attribute30,
	            p_information114     => l_vrp_rec.vrp_attribute4,
	            p_information115     => l_vrp_rec.vrp_attribute5,
	            p_information116     => l_vrp_rec.vrp_attribute6,
	            p_information117     => l_vrp_rec.vrp_attribute7,
	            p_information118     => l_vrp_rec.vrp_attribute8,
	            p_information119     => l_vrp_rec.vrp_attribute9,
	            p_information110     => l_vrp_rec.vrp_attribute_category,
                    p_information265     => l_vrp_rec.object_version_number,
	            p_object_version_number          => l_object_version_number,
	            p_effective_date                 => p_effective_date       );
	     --

                  if l_out_vrp_result_id is null then
                   l_out_vrp_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_vrp_result_id := l_copy_entity_result_id ;
                 end if;
	     end loop;
	   --
	   end loop;
	---------------------------------------------------------------
	-- END OF BEN_VALD_RLSHP_FOR_REIMB_F ----------------------
	---------------------------------------------------------------

	---------------------------------------------------------------
	-- START OF BEN_WV_PRTN_RSN_PL_F ----------------------
	---------------------------------------------------------------
	   --
	   --
	   for l_parent_rec  in c_wpn_from_parent(l_PL_ID) loop
	   --
           l_mirror_src_entity_result_id := l_out_pln_result_id;
           l_parent_entity_result_id := l_out_pln_cpp_result_id;

           l_wv_prtn_rsn_pl_id := l_parent_rec.wv_prtn_rsn_pl_id ;
	     --
	     for l_wpn_rec in c_wpn(l_parent_rec.wv_prtn_rsn_pl_id,l_mirror_src_entity_result_id,'WPN') loop
	     --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('WPN');
        	  fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5 := hr_general.decode_lookup('BEN_WV_PRTN_RSN',l_wpn_rec.wv_prtn_rsn_cd); --'Intersection';
              --
              l_wv_prtn_rsn_pl_id := l_wpn_rec.wv_prtn_rsn_pl_id ;
              --
              if p_effective_date between l_wpn_rec.effective_start_date
    	           and l_wpn_rec.effective_end_date then
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
		      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                  p_parent_entity_result_id        => l_parent_entity_result_id,
	            p_number_of_copies               => l_number_of_copies,
	            p_table_alias					 => 'WPN',
                  p_table_route_id                 => l_table_route_id,
	            p_information1     => l_wpn_rec.wv_prtn_rsn_pl_id,
	            p_information2     => l_wpn_rec.EFFECTIVE_START_DATE,
	            p_information3     => l_wpn_rec.EFFECTIVE_END_DATE,
	            p_information4     => l_wpn_rec.business_group_id,
	            p_information5     => l_information5 , -- 9999 put name for h-grid
	            p_information11     => l_wpn_rec.dflt_flag,
	            p_information261     => l_wpn_rec.pl_id,
	            p_information111     => l_wpn_rec.wpn_attribute1,
	            p_information120     => l_wpn_rec.wpn_attribute10,
	            p_information121     => l_wpn_rec.wpn_attribute11,
	            p_information122     => l_wpn_rec.wpn_attribute12,
	            p_information123     => l_wpn_rec.wpn_attribute13,
	            p_information124     => l_wpn_rec.wpn_attribute14,
	            p_information125     => l_wpn_rec.wpn_attribute15,
	            p_information126     => l_wpn_rec.wpn_attribute16,
	            p_information127     => l_wpn_rec.wpn_attribute17,
	            p_information128     => l_wpn_rec.wpn_attribute18,
	            p_information129     => l_wpn_rec.wpn_attribute19,
	            p_information112     => l_wpn_rec.wpn_attribute2,
	            p_information130     => l_wpn_rec.wpn_attribute20,
	            p_information131     => l_wpn_rec.wpn_attribute21,
	            p_information132     => l_wpn_rec.wpn_attribute22,
	            p_information133     => l_wpn_rec.wpn_attribute23,
	            p_information134     => l_wpn_rec.wpn_attribute24,
	            p_information135     => l_wpn_rec.wpn_attribute25,
	            p_information136     => l_wpn_rec.wpn_attribute26,
	            p_information137     => l_wpn_rec.wpn_attribute27,
	            p_information138     => l_wpn_rec.wpn_attribute28,
	            p_information139     => l_wpn_rec.wpn_attribute29,
	            p_information113     => l_wpn_rec.wpn_attribute3,
	            p_information140     => l_wpn_rec.wpn_attribute30,
	            p_information114     => l_wpn_rec.wpn_attribute4,
	            p_information115     => l_wpn_rec.wpn_attribute5,
	            p_information116     => l_wpn_rec.wpn_attribute6,
	            p_information117     => l_wpn_rec.wpn_attribute7,
	            p_information118     => l_wpn_rec.wpn_attribute8,
	            p_information119     => l_wpn_rec.wpn_attribute9,
	            p_information110     => l_wpn_rec.wpn_attribute_category,
	            p_information12     => l_wpn_rec.wv_prtn_rsn_cd,
                    p_information265    => l_wpn_rec.object_version_number,
	            p_object_version_number          => l_object_version_number,
	            p_effective_date                 => p_effective_date       );
	    --

                  if l_out_wpn_result_id is null then
                   l_out_wpn_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_wpn_result_id := l_copy_entity_result_id ;
                 end if;

	    end loop;
	    --
         ---------------------------------------------------------------
         -- START OF BEN_WV_PRTN_RSN_CTFN_PL_F ----------------------
         ---------------------------------------------------------------
          --
          for l_parent_rec  in c_wcn_from_parent(l_WV_PRTN_RSN_PL_ID) loop
          --
            l_mirror_src_entity_result_id := l_out_wpn_result_id ;

            l_wv_prtn_rsn_ctfn_pl_id := l_parent_rec.wv_prtn_rsn_ctfn_pl_id ;
            --
            for l_wcn_rec in c_wcn(l_parent_rec.wv_prtn_rsn_ctfn_pl_id,l_mirror_src_entity_result_id,'WCN') loop
            --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('WCN');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := hr_general.decode_lookup('BEN_WV_PRTN_CTFN_TYP',l_wcn_rec.wv_prtn_ctfn_typ_cd); --'Intersection';
                --
                l_wv_prtn_rsn_ctfn_pl_id := l_wcn_rec.wv_prtn_rsn_ctfn_pl_id ;
                if p_effective_date between l_wcn_rec.effective_start_date
                    and l_wcn_rec.effective_end_date then
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
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_alias					 => 'WCN',
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_wcn_rec.wv_prtn_rsn_ctfn_pl_id,
                     p_information2     => l_wcn_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_wcn_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_wcn_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information261     => l_wcn_rec.ctfn_rqd_when_rl,
                     p_information12     => l_wcn_rec.lack_ctfn_sspnd_wvr_flag,
                     p_information11     => l_wcn_rec.pfd_flag,
                     p_information13     => l_wcn_rec.rqd_flag,
                     p_information111     => l_wcn_rec.wcn_attribute1,
                     p_information120     => l_wcn_rec.wcn_attribute10,
                     p_information121     => l_wcn_rec.wcn_attribute11,
                     p_information122     => l_wcn_rec.wcn_attribute12,
                     p_information123     => l_wcn_rec.wcn_attribute13,
                     p_information124     => l_wcn_rec.wcn_attribute14,
                     p_information125     => l_wcn_rec.wcn_attribute15,
                     p_information126     => l_wcn_rec.wcn_attribute16,
                     p_information127     => l_wcn_rec.wcn_attribute17,
                     p_information128     => l_wcn_rec.wcn_attribute18,
                     p_information129     => l_wcn_rec.wcn_attribute19,
                     p_information112     => l_wcn_rec.wcn_attribute2,
                     p_information130     => l_wcn_rec.wcn_attribute20,
                     p_information131     => l_wcn_rec.wcn_attribute21,
                     p_information132     => l_wcn_rec.wcn_attribute22,
                     p_information133     => l_wcn_rec.wcn_attribute23,
                     p_information134     => l_wcn_rec.wcn_attribute24,
                     p_information135     => l_wcn_rec.wcn_attribute25,
                     p_information136     => l_wcn_rec.wcn_attribute26,
                     p_information137     => l_wcn_rec.wcn_attribute27,
                     p_information138     => l_wcn_rec.wcn_attribute28,
                     p_information139     => l_wcn_rec.wcn_attribute29,
                     p_information113     => l_wcn_rec.wcn_attribute3,
                     p_information140     => l_wcn_rec.wcn_attribute30,
                     p_information114     => l_wcn_rec.wcn_attribute4,
                     p_information115     => l_wcn_rec.wcn_attribute5,
                     p_information116     => l_wcn_rec.wcn_attribute6,
                     p_information117     => l_wcn_rec.wcn_attribute7,
                     p_information118     => l_wcn_rec.wcn_attribute8,
                     p_information119     => l_wcn_rec.wcn_attribute9,
                     p_information110     => l_wcn_rec.wcn_attribute_category,
                     p_information14     => l_wcn_rec.wv_prtn_ctfn_typ_cd,
                     p_information257     => l_wcn_rec.wv_prtn_rsn_pl_id,
                     p_information265    => l_wcn_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
              --

                     if l_out_wcn_result_id is null then
                       l_out_wcn_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                       l_out_wcn_result_id := l_copy_entity_result_id ;
                     end if;

					  if (l_wcn_rec.ctfn_rqd_when_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_wcn_rec.ctfn_rqd_when_rl
								,p_business_group_id        => l_wcn_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

              --
              end loop;
            --
            end loop;
         ---------------------------------------------------------------
         -- END OF BEN_WV_PRTN_RSN_CTFN_PL_F ----------------------
         ---------------------------------------------------------------
	   end loop;
	---------------------------------------------------------------
	-- END OF BEN_WV_PRTN_RSN_PL_F ----------------------
	---------------------------------------------------------------

     ---------------------------------------------------------------
     -- START OF BEN_BNFT_RSTRN_CTFN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_brc_from_parent(l_PL_ID) loop
      --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_bnft_rstrn_ctfn_id := l_parent_rec.bnft_rstrn_ctfn_id ;
        --
        for l_brc_rec in c_brc(l_parent_rec.bnft_rstrn_ctfn_id,l_mirror_src_entity_result_id,'BRC') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('BRC');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_brc_rec.enrt_ctfn_typ_cd); --'Intersection';
            --
            if p_effective_date between l_brc_rec.effective_start_date
                and l_brc_rec.effective_end_date then
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'BRC',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_brc_rec.bnft_rstrn_ctfn_id,
                 p_information2     => l_brc_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_brc_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_brc_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information111     => l_brc_rec.brc_attribute1,
                 p_information120     => l_brc_rec.brc_attribute10,
                 p_information121     => l_brc_rec.brc_attribute11,
                 p_information122     => l_brc_rec.brc_attribute12,
                 p_information123     => l_brc_rec.brc_attribute13,
                 p_information124     => l_brc_rec.brc_attribute14,
                 p_information125     => l_brc_rec.brc_attribute15,
                 p_information126     => l_brc_rec.brc_attribute16,
                 p_information127     => l_brc_rec.brc_attribute17,
                 p_information128     => l_brc_rec.brc_attribute18,
                 p_information129     => l_brc_rec.brc_attribute19,
                 p_information112     => l_brc_rec.brc_attribute2,
                 p_information130     => l_brc_rec.brc_attribute20,
                 p_information131     => l_brc_rec.brc_attribute21,
                 p_information132     => l_brc_rec.brc_attribute22,
                 p_information133     => l_brc_rec.brc_attribute23,
                 p_information134     => l_brc_rec.brc_attribute24,
                 p_information135     => l_brc_rec.brc_attribute25,
                 p_information136     => l_brc_rec.brc_attribute26,
                 p_information137     => l_brc_rec.brc_attribute27,
                 p_information138     => l_brc_rec.brc_attribute28,
                 p_information139     => l_brc_rec.brc_attribute29,
                 p_information113     => l_brc_rec.brc_attribute3,
                 p_information140     => l_brc_rec.brc_attribute30,
                 p_information114     => l_brc_rec.brc_attribute4,
                 p_information115     => l_brc_rec.brc_attribute5,
                 p_information116     => l_brc_rec.brc_attribute6,
                 p_information117     => l_brc_rec.brc_attribute7,
                 p_information118     => l_brc_rec.brc_attribute8,
                 p_information119     => l_brc_rec.brc_attribute9,
                 p_information110     => l_brc_rec.brc_attribute_category,
                 p_information257     => l_brc_rec.ctfn_rqd_when_rl,
                 p_information12     => l_brc_rec.enrt_ctfn_typ_cd,
                 p_information261     => l_brc_rec.pl_id,
                 p_information11     => l_brc_rec.rqd_flag,
                 p_information265     => l_brc_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                 if l_out_brc_result_id is null then
                   l_out_brc_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_brc_result_id := l_copy_entity_result_id ;
                 end if;

     			 if (l_brc_rec.ctfn_rqd_when_rl is not null) then
	 			   ben_plan_design_program_module.create_formula_result(
	 					p_validate                       => p_validate
	 					,p_copy_entity_result_id  => l_copy_entity_result_id
	 					,p_copy_entity_txn_id      => p_copy_entity_txn_id
	 					,p_formula_id                  => l_brc_rec.ctfn_rqd_when_rl
	 					,p_business_group_id        => l_brc_rec.business_group_id
	 					,p_number_of_copies         =>  l_number_of_copies
	 					,p_object_version_number  => l_object_version_number
	 					,p_effective_date             => p_effective_date);
	 			end if;
	 		--
     	    end loop;
          --

      end loop;
     ---------------------------------------------------------------
     -- END OF BEN_BNFT_RSTRN_CTFN_F ----------------------
     ---------------------------------------------------------------

     ---------------------------------------------------------------
     -- START OF BEN_LER_BNFT_RSTRN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_lbr_from_parent(l_PL_ID) loop
      --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_ler_bnft_rstrn_id := l_parent_rec.ler_bnft_rstrn_id ;
        --
        for l_lbr_rec in c_lbr(l_parent_rec.ler_bnft_rstrn_id,l_mirror_src_entity_result_id,'LBR') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('LBR');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_ler_name(l_lbr_rec.ler_id,p_effective_date); --'Intersection';
            --
            l_ler_bnft_rstrn_id := l_lbr_rec.ler_bnft_rstrn_id ;
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
                 p_copy_entity_result_id           => l_copy_entity_result_id,
                 p_copy_entity_txn_id             => p_copy_entity_txn_id,
                 p_result_type_cd                 => l_result_type_cd,
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'LBR',
                 p_table_route_id                 => l_table_route_id,
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
                 p_information14      => l_lbr_rec.no_mn_cvg_incr_apls_flag,
                 p_information15      => l_lbr_rec.no_mx_cvg_amt_apls_flag,
                 p_information16      => l_lbr_rec.no_mx_cvg_incr_apls_flag,
                 p_information261     => l_lbr_rec.pl_id,
                 p_information256     => l_lbr_rec.plip_id,
                 p_information13      => l_lbr_rec.unsspnd_enrt_cd,
                 p_INFORMATION198     => l_lbr_rec.SUSP_IF_CTFN_NOT_PRVD_FLAG,
                 p_INFORMATION197     => l_lbr_rec.CTFN_DETERMINE_CD,
                 p_information265     => l_lbr_rec.object_version_number,
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
			  if (l_lbr_rec.dflt_to_asn_pndg_ctfn_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_lbr_rec.dflt_to_asn_pndg_ctfn_rl
						,p_business_group_id        =>  l_lbr_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

			  if (l_lbr_rec.mn_cvg_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_lbr_rec.mn_cvg_rl
						,p_business_group_id        => l_lbr_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

			  if (l_lbr_rec.mx_cvg_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_lbr_rec.mx_cvg_rl
						,p_business_group_id        => l_lbr_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

            --
          end loop;
          --
          for l_lbr_rec in c_lbr_drp(l_parent_rec.ler_bnft_rstrn_id,l_mirror_src_entity_result_id,'LBR') loop
            --
            create_ler_result (
                 p_validate                       => p_validate
                ,p_copy_entity_result_id          => l_out_lbr_result_id
                ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                ,p_ler_id                         => l_lbr_rec.ler_id
                ,p_business_group_id              => p_business_group_id
                ,p_number_of_copies             => p_number_of_copies
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => p_effective_date
                );
            --
          end loop;
          ---------------------------------------------------------------
          -- START OF BEN_LER_BNFT_RSTRN_CTFN_F ----------------------
          ---------------------------------------------------------------
          --
          for l_parent_rec  in c_lbc_from_parent(l_LER_BNFT_RSTRN_ID) loop
          --
              l_mirror_src_entity_result_id := l_out_lbr_result_id;

              l_ler_bnft_rstrn_ctfn_id := l_parent_rec.ler_bnft_rstrn_ctfn_id ;
              --
              for l_lbc_rec in c_lbc(l_parent_rec.ler_bnft_rstrn_ctfn_id,l_mirror_src_entity_result_id,'LBC') loop
              --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('LBC');
                  fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_lbc_rec.enrt_ctfn_typ_cd); --'Intersection';
                  --
                  l_ler_bnft_rstrn_ctfn_id := l_lbc_rec.ler_bnft_rstrn_ctfn_id ;
                  if p_effective_date between l_lbc_rec.effective_start_date
                      and l_lbc_rec.effective_end_date then
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
                       p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                       p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                       p_number_of_copies               => l_number_of_copies,
                       p_table_alias					 => 'LBC',
                       p_table_route_id                 => l_table_route_id,
                       p_information1     => l_lbc_rec.ler_bnft_rstrn_ctfn_id,
                       p_information2     => l_lbc_rec.EFFECTIVE_START_DATE,
                       p_information3     => l_lbc_rec.EFFECTIVE_END_DATE,
                       p_information4     => l_lbc_rec.business_group_id,
                       p_information5     => l_information5 , -- 9999 put name for h-grid
                      	p_information261     => l_lbc_rec.ctfn_rqd_when_rl,
                      	p_information12      => l_lbc_rec.enrt_ctfn_typ_cd,
                      	p_information111     => l_lbc_rec.lbc_attribute1,
                      	p_information120     => l_lbc_rec.lbc_attribute10,
                      	p_information121     => l_lbc_rec.lbc_attribute11,
                      	p_information122     => l_lbc_rec.lbc_attribute12,
                      	p_information123     => l_lbc_rec.lbc_attribute13,
                      	p_information124     => l_lbc_rec.lbc_attribute14,
                      	p_information125     => l_lbc_rec.lbc_attribute15,
                      	p_information126     => l_lbc_rec.lbc_attribute16,
                      	p_information127     => l_lbc_rec.lbc_attribute17,
                      	p_information128     => l_lbc_rec.lbc_attribute18,
                      	p_information129     => l_lbc_rec.lbc_attribute19,
                      	p_information112     => l_lbc_rec.lbc_attribute2,
                      	p_information130     => l_lbc_rec.lbc_attribute20,
                      	p_information131     => l_lbc_rec.lbc_attribute21,
                      	p_information132     => l_lbc_rec.lbc_attribute22,
                      	p_information133     => l_lbc_rec.lbc_attribute23,
                      	p_information134     => l_lbc_rec.lbc_attribute24,
                      	p_information135     => l_lbc_rec.lbc_attribute25,
                      	p_information136     => l_lbc_rec.lbc_attribute26,
                      	p_information137     => l_lbc_rec.lbc_attribute27,
                      	p_information138     => l_lbc_rec.lbc_attribute28,
                      	p_information139     => l_lbc_rec.lbc_attribute29,
                      	p_information113     => l_lbc_rec.lbc_attribute3,
                      	p_information140     => l_lbc_rec.lbc_attribute30,
                      	p_information114     => l_lbc_rec.lbc_attribute4,
                      	p_information115     => l_lbc_rec.lbc_attribute5,
                      	p_information116     => l_lbc_rec.lbc_attribute6,
                      	p_information117     => l_lbc_rec.lbc_attribute7,
                      	p_information118     => l_lbc_rec.lbc_attribute8,
                      	p_information119     => l_lbc_rec.lbc_attribute9,
                      	p_information110     => l_lbc_rec.lbc_attribute_category,
                      	p_information257     => l_lbc_rec.ler_bnft_rstrn_id,
                      	p_information11      => l_lbc_rec.rqd_flag,
                        p_information265     => l_lbc_rec.object_version_number,
                       p_object_version_number          => l_object_version_number,
                       p_effective_date                 => p_effective_date       );
                --

                       if l_out_lbc_result_id is null then
                         l_out_lbc_result_id := l_copy_entity_result_id;
                       end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_lbc_result_id := l_copy_entity_result_id ;
                      end if;

                      if (l_lbc_rec.ctfn_rqd_when_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  =>  l_lbc_rec.ctfn_rqd_when_rl
								,p_business_group_id        =>  l_lbc_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                --
                end loop;
              --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_LER_BNFT_RSTRN_CTFN_F ----------------------
           ---------------------------------------------------------------
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_LER_BNFT_RSTRN_F ----------------------
     ---------------------------------------------------------------

     ---------------------------------------------------------------
     -- START OF BEN_ENRT_CTFN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_ecf_from_parent(l_PL_ID) loop
      --

        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_enrt_ctfn_id := l_parent_rec.enrt_ctfn_id ;
        --
        for l_ecf_rec in c_ecf(l_parent_rec.enrt_ctfn_id,l_mirror_src_entity_result_id,'ECF') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('ECF');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_ecf_rec.enrt_ctfn_typ_cd); --'Intersection';
            --
            if p_effective_date between l_ecf_rec.effective_start_date
                and l_ecf_rec.effective_end_date then
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'EFC',
                  p_table_route_id                 => l_table_route_id,
                 p_information1     => l_ecf_rec.enrt_ctfn_id,
                 p_information2     => l_ecf_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_ecf_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_ecf_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information262     => l_ecf_rec.ctfn_rqd_when_rl,
                 p_information111     => l_ecf_rec.ecf_attribute1,
                 p_information120     => l_ecf_rec.ecf_attribute10,
                 p_information121     => l_ecf_rec.ecf_attribute11,
                 p_information122     => l_ecf_rec.ecf_attribute12,
                 p_information123     => l_ecf_rec.ecf_attribute13,
                 p_information124     => l_ecf_rec.ecf_attribute14,
                 p_information125     => l_ecf_rec.ecf_attribute15,
                 p_information126     => l_ecf_rec.ecf_attribute16,
                 p_information127     => l_ecf_rec.ecf_attribute17,
                 p_information128     => l_ecf_rec.ecf_attribute18,
                 p_information129     => l_ecf_rec.ecf_attribute19,
                 p_information112     => l_ecf_rec.ecf_attribute2,
                 p_information130     => l_ecf_rec.ecf_attribute20,
                 p_information131     => l_ecf_rec.ecf_attribute21,
                 p_information132     => l_ecf_rec.ecf_attribute22,
                 p_information133     => l_ecf_rec.ecf_attribute23,
                 p_information134     => l_ecf_rec.ecf_attribute24,
                 p_information135     => l_ecf_rec.ecf_attribute25,
                 p_information136     => l_ecf_rec.ecf_attribute26,
                 p_information137     => l_ecf_rec.ecf_attribute27,
                 p_information138     => l_ecf_rec.ecf_attribute28,
                 p_information139     => l_ecf_rec.ecf_attribute29,
                 p_information113     => l_ecf_rec.ecf_attribute3,
                 p_information140     => l_ecf_rec.ecf_attribute30,
                 p_information114     => l_ecf_rec.ecf_attribute4,
                 p_information115     => l_ecf_rec.ecf_attribute5,
                 p_information116     => l_ecf_rec.ecf_attribute6,
                 p_information117     => l_ecf_rec.ecf_attribute7,
                 p_information118     => l_ecf_rec.ecf_attribute8,
                 p_information119     => l_ecf_rec.ecf_attribute9,
                 p_information110     => l_ecf_rec.ecf_attribute_category,
                 p_information11     => l_ecf_rec.enrt_ctfn_typ_cd,
                 p_information258     => l_ecf_rec.oipl_id,
                 p_information261     => l_ecf_rec.pl_id,
                 p_information256     => l_ecf_rec.plip_id,
                 p_information12     => l_ecf_rec.rqd_flag,
                 p_information265     => l_ecf_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                 if l_out_ecf_result_id is null then
                   l_out_ecf_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_ecf_result_id := l_copy_entity_result_id ;
                 end if;

				  if (l_ecf_rec.ctfn_rqd_when_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_ecf_rec.ctfn_rqd_when_rl
							,p_business_group_id        => l_ecf_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;
          --

          end loop;
        --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_ENRT_CTFN_F ----------------------
     ---------------------------------------------------------------

     ---------------------------------------------------------------
     -- START OF BEN_LER_CHG_DPNT_CVG_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_ldc_from_parent(l_PL_ID) loop
      --

        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_ler_chg_dpnt_cvg_id := l_parent_rec.ler_chg_dpnt_cvg_id ;
        --
        for l_ldc_rec in c_ldc(l_parent_rec.ler_chg_dpnt_cvg_id,l_mirror_src_entity_result_id,'LDC') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('LDC');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_ler_name(l_ldc_rec.ler_id,p_effective_date); --'Intersection'
            --
            l_ler_chg_dpnt_cvg_id := l_ldc_rec.ler_chg_dpnt_cvg_id;
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'LDC',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_ldc_rec.ler_chg_dpnt_cvg_id,
                 p_information2     => l_ldc_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_ldc_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_ldc_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information11      => l_ldc_rec.add_rmv_cvg_cd,
                 p_information12      => l_ldc_rec.cvg_eff_end_cd,
                 p_information263     => l_ldc_rec.cvg_eff_end_rl,
                 p_information13      => l_ldc_rec.cvg_eff_strt_cd,
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
                 p_information14      => l_ldc_rec.ler_chg_dpnt_cvg_cd,
                 p_information258     => l_ldc_rec.ler_chg_dpnt_cvg_rl,
                 p_information257     => l_ldc_rec.ler_id,
                 p_information260     => l_ldc_rec.pgm_id,
                 p_information261     => l_ldc_rec.pl_id,
                 p_information259     => l_ldc_rec.ptip_id,
                 p_INFORMATION198     => l_ldc_rec.SUSP_IF_CTFN_NOT_PRVD_FLAG,
                 p_INFORMATION197     => l_ldc_rec.CTFN_DETERMINE_CD,
                 p_information265     => l_ldc_rec.object_version_number,
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
            --
          end loop;
          --
          for l_ldc_rec in c_ldc_drp(l_parent_rec.ler_chg_dpnt_cvg_id,l_mirror_src_entity_result_id,'LDC') loop
            create_ler_result (
                 p_validate                       => p_validate
                ,p_copy_entity_result_id          => l_out_ldc_result_id
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
           for l_parent_rec  in c_lcc_from_parent(l_LER_CHG_DPNT_CVG_ID) loop
           --
             l_mirror_src_entity_result_id := l_out_ldc_result_id;

             l_ler_chg_dpnt_cvg_ctfn_id := l_parent_rec.ler_chg_dpnt_cvg_ctfn_id ;
             --
             for l_lcc_rec in c_lcc(l_parent_rec.ler_chg_dpnt_cvg_ctfn_id,l_mirror_src_entity_result_id,'LCC') loop
             --
                l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('LCC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('BEN_DPNT_CVG_CTFN_TYP',l_lcc_rec.dpnt_cvg_ctfn_typ_cd); --'Intersection';
                 --
                 l_ler_chg_dpnt_cvg_ctfn_id := l_lcc_rec.ler_chg_dpnt_cvg_ctfn_id ;
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
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'LCC',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_lcc_rec.ler_chg_dpnt_cvg_ctfn_id,
                      p_information2     => l_lcc_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_lcc_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_lcc_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information261     => l_lcc_rec.ctfn_rqd_when_rl,
                      p_information12      => l_lcc_rec.dpnt_cvg_ctfn_typ_cd,
                      p_information13      => l_lcc_rec.lack_ctfn_sspnd_enrt_flag,
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
                      p_information14      => l_lcc_rec.rlshp_typ_cd,
                      p_information11      => l_lcc_rec.rqd_flag,
                      p_information265     => l_lcc_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
               --

                      if l_out_lcc_result_id is null then
                        l_out_lcc_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_lcc_result_id := l_copy_entity_result_id ;
                      end if;

                      if (l_lcc_rec.ctfn_rqd_when_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  =>  l_lcc_rec.ctfn_rqd_when_rl
								,p_business_group_id        =>  l_lcc_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;


               --
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
     -- START OF BEN_LER_CHG_PL_NIP_ENRT_F ----------------------
     ---------------------------------------------------------------
     --
     --
     for l_parent_rec  in c_lpe_from_parent(l_PL_ID) loop
     --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_ler_chg_pl_nip_enrt_id := l_parent_rec.ler_chg_pl_nip_enrt_id ;
        --
        for l_lpe_rec in c_lpe(l_parent_rec.ler_chg_pl_nip_enrt_id,l_mirror_src_entity_result_id,'LPE') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('LPE');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_ler_name(l_lpe_rec.ler_id,p_effective_date); --'Intersection';
            --
            if p_effective_date between l_lpe_rec.effective_start_date
                and l_lpe_rec.effective_end_date then
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
	 	     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'LPE',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_lpe_rec.ler_chg_pl_nip_enrt_id,
                 p_information2     => l_lpe_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_lpe_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_lpe_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information258     => l_lpe_rec.auto_enrt_mthd_rl,
                 p_information12     => l_lpe_rec.crnt_enrt_prclds_chg_flag,
                 p_information16     => l_lpe_rec.dflt_enrt_cd,
                 p_information263     => l_lpe_rec.dflt_enrt_rl,
                 p_information13     => l_lpe_rec.dflt_flag,
                 p_information17     => l_lpe_rec.enrt_cd,
                 p_information15     => l_lpe_rec.enrt_mthd_cd,
                 p_information264     => l_lpe_rec.enrt_rl,
                 p_information257     => l_lpe_rec.ler_id,
                 p_information111     => l_lpe_rec.lpe_attribute1,
                 p_information120     => l_lpe_rec.lpe_attribute10,
                 p_information121     => l_lpe_rec.lpe_attribute11,
                 p_information122     => l_lpe_rec.lpe_attribute12,
                 p_information123     => l_lpe_rec.lpe_attribute13,
                 p_information124     => l_lpe_rec.lpe_attribute14,
                 p_information125     => l_lpe_rec.lpe_attribute15,
                 p_information126     => l_lpe_rec.lpe_attribute16,
                 p_information127     => l_lpe_rec.lpe_attribute17,
                 p_information128     => l_lpe_rec.lpe_attribute18,
                 p_information129     => l_lpe_rec.lpe_attribute19,
                 p_information112     => l_lpe_rec.lpe_attribute2,
                 p_information130     => l_lpe_rec.lpe_attribute20,
                 p_information131     => l_lpe_rec.lpe_attribute21,
                 p_information132     => l_lpe_rec.lpe_attribute22,
                 p_information133     => l_lpe_rec.lpe_attribute23,
                 p_information134     => l_lpe_rec.lpe_attribute24,
                 p_information135     => l_lpe_rec.lpe_attribute25,
                 p_information136     => l_lpe_rec.lpe_attribute26,
                 p_information137     => l_lpe_rec.lpe_attribute27,
                 p_information138     => l_lpe_rec.lpe_attribute28,
                 p_information139     => l_lpe_rec.lpe_attribute29,
                 p_information113     => l_lpe_rec.lpe_attribute3,
                 p_information140     => l_lpe_rec.lpe_attribute30,
                 p_information114     => l_lpe_rec.lpe_attribute4,
                 p_information115     => l_lpe_rec.lpe_attribute5,
                 p_information116     => l_lpe_rec.lpe_attribute6,
                 p_information117     => l_lpe_rec.lpe_attribute7,
                 p_information118     => l_lpe_rec.lpe_attribute8,
                 p_information119     => l_lpe_rec.lpe_attribute9,
                 p_information110     => l_lpe_rec.lpe_attribute_category,
                 p_information261     => l_lpe_rec.pl_id,
                 p_information14     => l_lpe_rec.stl_elig_cant_chg_flag,
                 p_information11     => l_lpe_rec.tco_chg_enrt_cd,
                 p_information265     => l_lpe_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
               --
                if l_out_lpe_result_id is null then
                  l_out_lpe_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                  l_out_lpe_result_id := l_copy_entity_result_id ;
                end if;
               --
				  if (l_lpe_rec.auto_enrt_mthd_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_lpe_rec.auto_enrt_mthd_rl
							,p_business_group_id        => l_lpe_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_lpe_rec.dflt_enrt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_lpe_rec.dflt_enrt_rl
							,p_business_group_id        => l_lpe_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_lpe_rec.enrt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_lpe_rec.enrt_rl
							,p_business_group_id        => l_lpe_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

          --
          end loop;
          --
          for l_lpe_rec in c_lpe_drp(l_parent_rec.ler_chg_pl_nip_enrt_id,l_mirror_src_entity_result_id,'LPE') loop
                create_ler_result (
                      p_validate                       => p_validate
                     ,p_copy_entity_result_id          => l_out_lpe_result_id
                     ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                     ,p_ler_id                         => l_lpe_rec.ler_id
                     ,p_business_group_id              => p_business_group_id
                     ,p_number_of_copies               => p_number_of_copies
                     ,p_object_version_number          => l_object_version_number
                     ,p_effective_date                 => p_effective_date
                     );
          end loop;
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_LER_CHG_PL_NIP_ENRT_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_lre_from_parent(l_PL_ID) loop
      --

        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_ler_rqrs_enrt_ctfn_id := l_parent_rec.ler_rqrs_enrt_ctfn_id ;
        --
        for l_lre_rec in c_lre(l_parent_rec.ler_rqrs_enrt_ctfn_id,l_mirror_src_entity_result_id,'LRE') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('LRE');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_ler_name(l_lre_rec.ler_id,p_effective_date); --'Intersection';
            --
            if p_effective_date between l_lre_rec.effective_start_date
                and l_lre_rec.effective_end_date then
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
	 	     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'LRE',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_lre_rec.ler_rqrs_enrt_ctfn_id,
                 p_information2     => l_lre_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_lre_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_lre_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information263     => l_lre_rec.ctfn_rqd_when_rl,
                 p_information11     => l_lre_rec.excld_flag,
                 p_information257     => l_lre_rec.ler_id,
                 p_information111     => l_lre_rec.lre_attribute1,
                 p_information120     => l_lre_rec.lre_attribute10,
                 p_information121     => l_lre_rec.lre_attribute11,
                 p_information122     => l_lre_rec.lre_attribute12,
                 p_information123     => l_lre_rec.lre_attribute13,
                 p_information124     => l_lre_rec.lre_attribute14,
                 p_information125     => l_lre_rec.lre_attribute15,
                 p_information126     => l_lre_rec.lre_attribute16,
                 p_information127     => l_lre_rec.lre_attribute17,
                 p_information128     => l_lre_rec.lre_attribute18,
                 p_information129     => l_lre_rec.lre_attribute19,
                 p_information112     => l_lre_rec.lre_attribute2,
                 p_information130     => l_lre_rec.lre_attribute20,
                 p_information131     => l_lre_rec.lre_attribute21,
                 p_information132     => l_lre_rec.lre_attribute22,
                 p_information133     => l_lre_rec.lre_attribute23,
                 p_information134     => l_lre_rec.lre_attribute24,
                 p_information135     => l_lre_rec.lre_attribute25,
                 p_information136     => l_lre_rec.lre_attribute26,
                 p_information137     => l_lre_rec.lre_attribute27,
                 p_information138     => l_lre_rec.lre_attribute28,
                 p_information139     => l_lre_rec.lre_attribute29,
                 p_information113     => l_lre_rec.lre_attribute3,
                 p_information140     => l_lre_rec.lre_attribute30,
                 p_information114     => l_lre_rec.lre_attribute4,
                 p_information115     => l_lre_rec.lre_attribute5,
                 p_information116     => l_lre_rec.lre_attribute6,
                 p_information117     => l_lre_rec.lre_attribute7,
                 p_information118     => l_lre_rec.lre_attribute8,
                 p_information119     => l_lre_rec.lre_attribute9,
                 p_information110     => l_lre_rec.lre_attribute_category,
                 p_information258     => l_lre_rec.oipl_id,
                 p_information261     => l_lre_rec.pl_id,
                 p_information256     => l_lre_rec.plip_id,
                 p_INFORMATION198     => l_lre_rec.SUSP_IF_CTFN_NOT_PRVD_FLAG,
                 p_INFORMATION197     => l_lre_rec.CTFN_DETERMINE_CD,
                 p_information265     => l_lre_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
                 --
                 --
                if l_out_lre_result_id is null then
                   l_out_lre_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                  l_out_lre_result_id := l_copy_entity_result_id ;
                end if;
                 --
				  if (l_lre_rec.ctfn_rqd_when_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_lre_rec.ctfn_rqd_when_rl
							,p_business_group_id        => l_lre_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

          --
          end loop;
          for l_lre_rec in c_lre_drp(l_parent_rec.ler_rqrs_enrt_ctfn_id,l_mirror_src_entity_result_id,'LRE') loop
                   create_ler_result (
                      p_validate                       => p_validate
                     ,p_copy_entity_result_id          => l_out_lre_result_id
                     ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                     ,p_ler_id                         => l_lre_rec.ler_id
                     ,p_business_group_id              => p_business_group_id
                     ,p_number_of_copies               => p_number_of_copies
                     ,p_object_version_number          => l_object_version_number
                     ,p_effective_date                 => p_effective_date
                     );
          end loop;
          --
          ---------------------------------------------------------------
          -- START OF BEN_LER_ENRT_CTFN_F ----------------------
          ---------------------------------------------------------------
          --
          for l_parent_rec  in c_lnc_from_parent(l_LER_RQRS_ENRT_CTFN_ID) loop
          --
             l_mirror_src_entity_result_id := l_out_lre_result_id ;

             l_ler_enrt_ctfn_id := l_parent_rec.ler_enrt_ctfn_id ;
             --
             for l_lnc_rec in c_lnc(l_parent_rec.ler_enrt_ctfn_id,l_mirror_src_entity_result_id,'LNC') loop
             --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('LNC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_lnc_rec.enrt_ctfn_typ_cd); --'Intersection';
                 --
                 l_ler_enrt_ctfn_id := l_lnc_rec.ler_enrt_ctfn_id ;
                 if p_effective_date between l_lnc_rec.effective_start_date
                     and l_lnc_rec.effective_end_date then
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
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'LNC',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_lnc_rec.ler_enrt_ctfn_id,
                      p_information2     => l_lnc_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_lnc_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_lnc_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information258     => l_lnc_rec.ctfn_rqd_when_rl,
                      p_information12     => l_lnc_rec.enrt_ctfn_typ_cd,
                      p_information257     => l_lnc_rec.ler_rqrs_enrt_ctfn_id,
                      p_information111     => l_lnc_rec.lnc_attribute1,
                      p_information120     => l_lnc_rec.lnc_attribute10,
                      p_information121     => l_lnc_rec.lnc_attribute11,
                      p_information122     => l_lnc_rec.lnc_attribute12,
                      p_information123     => l_lnc_rec.lnc_attribute13,
                      p_information124     => l_lnc_rec.lnc_attribute14,
                      p_information125     => l_lnc_rec.lnc_attribute15,
                      p_information126     => l_lnc_rec.lnc_attribute16,
                      p_information127     => l_lnc_rec.lnc_attribute17,
                      p_information128     => l_lnc_rec.lnc_attribute18,
                      p_information129     => l_lnc_rec.lnc_attribute19,
                      p_information112     => l_lnc_rec.lnc_attribute2,
                      p_information130     => l_lnc_rec.lnc_attribute20,
                      p_information131     => l_lnc_rec.lnc_attribute21,
                      p_information132     => l_lnc_rec.lnc_attribute22,
                      p_information133     => l_lnc_rec.lnc_attribute23,
                      p_information134     => l_lnc_rec.lnc_attribute24,
                      p_information135     => l_lnc_rec.lnc_attribute25,
                      p_information136     => l_lnc_rec.lnc_attribute26,
                      p_information137     => l_lnc_rec.lnc_attribute27,
                      p_information138     => l_lnc_rec.lnc_attribute28,
                      p_information139     => l_lnc_rec.lnc_attribute29,
                      p_information113     => l_lnc_rec.lnc_attribute3,
                      p_information140     => l_lnc_rec.lnc_attribute30,
                      p_information114     => l_lnc_rec.lnc_attribute4,
                      p_information115     => l_lnc_rec.lnc_attribute5,
                      p_information116     => l_lnc_rec.lnc_attribute6,
                      p_information117     => l_lnc_rec.lnc_attribute7,
                      p_information118     => l_lnc_rec.lnc_attribute8,
                      p_information119     => l_lnc_rec.lnc_attribute9,
                      p_information110     => l_lnc_rec.lnc_attribute_category,
                      p_information11     => l_lnc_rec.rqd_flag,
                      p_information265     => l_lnc_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_lnc_result_id is null then
                        l_out_lnc_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_lnc_result_id := l_copy_entity_result_id ;
                      end if;
					  if (l_lnc_rec.ctfn_rqd_when_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_lnc_rec.ctfn_rqd_when_rl
								,p_business_group_id        => l_lnc_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

               --
               end loop;
             --
             end loop;
          ---------------------------------------------------------------
          -- END OF BEN_LER_ENRT_CTFN_F ----------------------
          ---------------------------------------------------------------
      end loop;
     ---------------------------------------------------------------
     -- END OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PL_PCP ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_pcp_from_parent(l_PL_ID) loop
      --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_pl_pcp_id := l_parent_rec.pl_pcp_id ;
        --
        for l_pcp_rec in c_pcp(l_parent_rec.pl_pcp_id,l_mirror_src_entity_result_id,'PCP') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PCP');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := fnd_message.get_string('BEN','BEN_93292_PDC_PCP_DSGN_CD') ||' - '||
                              hr_general.decode_lookup('BEN_PCP_DSGN',l_pcp_rec.pcp_dsgn_cd) ||' - '||
                              fnd_message.get_string('BEN','BEN_93293_PDC_PCP_DPNT_DSGN_CD') ||' - '||
                              hr_general.decode_lookup('BEN_PCP_DSGN',l_pcp_rec.pcp_dpnt_dsgn_cd); --'Intersection
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
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'PCP',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_pcp_rec.pl_pcp_id,
                 p_information2     => null,
                 p_information3     => null,
                 p_information4     => l_pcp_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information10     => l_pln_esd,
                 p_information111     => l_pcp_rec.pcp_attribute1,
                 p_information120     => l_pcp_rec.pcp_attribute10,
                 p_information121     => l_pcp_rec.pcp_attribute11,
                 p_information122     => l_pcp_rec.pcp_attribute12,
                 p_information123     => l_pcp_rec.pcp_attribute13,
                 p_information124     => l_pcp_rec.pcp_attribute14,
                 p_information125     => l_pcp_rec.pcp_attribute15,
                 p_information126     => l_pcp_rec.pcp_attribute16,
                 p_information127     => l_pcp_rec.pcp_attribute17,
                 p_information128     => l_pcp_rec.pcp_attribute18,
                 p_information129     => l_pcp_rec.pcp_attribute19,
                 p_information112     => l_pcp_rec.pcp_attribute2,
                 p_information130     => l_pcp_rec.pcp_attribute20,
                 p_information131     => l_pcp_rec.pcp_attribute21,
                 p_information132     => l_pcp_rec.pcp_attribute22,
                 p_information133     => l_pcp_rec.pcp_attribute23,
                 p_information134     => l_pcp_rec.pcp_attribute24,
                 p_information135     => l_pcp_rec.pcp_attribute25,
                 p_information136     => l_pcp_rec.pcp_attribute26,
                 p_information137     => l_pcp_rec.pcp_attribute27,
                 p_information138     => l_pcp_rec.pcp_attribute28,
                 p_information139     => l_pcp_rec.pcp_attribute29,
                 p_information113     => l_pcp_rec.pcp_attribute3,
                 p_information140     => l_pcp_rec.pcp_attribute30,
                 p_information114     => l_pcp_rec.pcp_attribute4,
                 p_information115     => l_pcp_rec.pcp_attribute5,
                 p_information116     => l_pcp_rec.pcp_attribute6,
                 p_information117     => l_pcp_rec.pcp_attribute7,
                 p_information118     => l_pcp_rec.pcp_attribute8,
                 p_information119     => l_pcp_rec.pcp_attribute9,
                 p_information110     => l_pcp_rec.pcp_attribute_category,
                 p_information15     => l_pcp_rec.pcp_can_keep_flag,
                 p_information13     => l_pcp_rec.pcp_dpnt_dsgn_cd,
                 p_information12     => l_pcp_rec.pcp_dsgn_cd,
                 p_information294     => l_pcp_rec.pcp_num_chgs,
                 p_information18     => l_pcp_rec.pcp_num_chgs_uom,
                 p_information293     => l_pcp_rec.pcp_radius,
                 p_information16     => l_pcp_rec.pcp_radius_uom,
                 p_information17     => l_pcp_rec.pcp_radius_warn_flag,
                 p_information14     => l_pcp_rec.pcp_rpstry_flag,
                 p_information11     => l_pcp_rec.pcp_strt_dt_cd,
                 p_information261     => l_pcp_rec.pl_id,
                 p_information265     => l_pcp_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
            --

            if l_out_pcp_result_id is null then
              l_out_pcp_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
              l_out_pcp_result_id := l_copy_entity_result_id ;
            end if;
            --

          end loop;
        --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PL_PCP ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PL_PCP_TYP ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_pty_from_parent(l_PL_PCP_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_pcp_result_id ;
        --
        l_pl_pcp_typ_id := l_parent_rec.pl_pcp_typ_id ;
        --
        for l_pty_rec in c_pty(l_parent_rec.pl_pcp_typ_id,l_mirror_src_entity_result_id,'PTY') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('PTY');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := hr_general.decode_lookup('BEN_PCP_SPCLTY',l_pty_rec.pcp_typ_cd); --'Intersection
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
            p_table_alias					 => 'PTY',
            p_table_route_id                 => l_table_route_id,
            p_information1     => l_pty_rec.pl_pcp_typ_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_pty_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information12     => l_pty_rec.gndr_alwd_cd,
            p_information294     => l_pty_rec.max_age,
            p_information293     => l_pty_rec.min_age,
            p_information11     => l_pty_rec.pcp_typ_cd,
            p_information257     => l_pty_rec.pl_pcp_id,
            p_information111     => l_pty_rec.pty_attribute1,
            p_information120     => l_pty_rec.pty_attribute10,
            p_information121     => l_pty_rec.pty_attribute11,
            p_information122     => l_pty_rec.pty_attribute12,
            p_information123     => l_pty_rec.pty_attribute13,
            p_information124     => l_pty_rec.pty_attribute14,
            p_information125     => l_pty_rec.pty_attribute15,
            p_information126     => l_pty_rec.pty_attribute16,
            p_information127     => l_pty_rec.pty_attribute17,
            p_information128     => l_pty_rec.pty_attribute18,
            p_information129     => l_pty_rec.pty_attribute19,
            p_information112     => l_pty_rec.pty_attribute2,
            p_information130     => l_pty_rec.pty_attribute20,
            p_information131     => l_pty_rec.pty_attribute21,
            p_information132     => l_pty_rec.pty_attribute22,
            p_information133     => l_pty_rec.pty_attribute23,
            p_information134     => l_pty_rec.pty_attribute24,
            p_information135     => l_pty_rec.pty_attribute25,
            p_information136     => l_pty_rec.pty_attribute26,
            p_information137     => l_pty_rec.pty_attribute27,
            p_information138     => l_pty_rec.pty_attribute28,
            p_information139     => l_pty_rec.pty_attribute29,
            p_information113     => l_pty_rec.pty_attribute3,
            p_information140     => l_pty_rec.pty_attribute30,
            p_information114     => l_pty_rec.pty_attribute4,
            p_information115     => l_pty_rec.pty_attribute5,
            p_information116     => l_pty_rec.pty_attribute6,
            p_information117     => l_pty_rec.pty_attribute7,
            p_information118     => l_pty_rec.pty_attribute8,
            p_information119     => l_pty_rec.pty_attribute9,
            p_information110     => l_pty_rec.pty_attribute_category,
            p_information265     => l_pty_rec.object_version_number,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_pty_result_id is null then
              l_out_pty_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_pty_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
       end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PL_PCP_TYP ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PL_BNF_CTFN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_pcx_from_parent(l_PL_ID) loop
      --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_pl_bnf_ctfn_id := l_parent_rec.pl_bnf_ctfn_id ;
        --
        for l_pcx_rec in c_pcx(l_parent_rec.pl_bnf_ctfn_id,l_mirror_src_entity_result_id,'PCX') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PCX');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := hr_general.decode_lookup('BEN_BNF_CTFN_TYP',l_pcx_rec.bnf_ctfn_typ_cd); --'Intersection
            --
            if p_effective_date between l_pcx_rec.effective_start_date
                and l_pcx_rec.effective_end_date then
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'PCX',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_pcx_rec.pl_bnf_ctfn_id,
                 p_information2     => l_pcx_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_pcx_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_pcx_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information11     => l_pcx_rec.bnf_ctfn_typ_cd,
                 p_information15     => l_pcx_rec.bnf_typ_cd,
                 p_information260     => l_pcx_rec.ctfn_rqd_when_rl,
                 p_information12     => l_pcx_rec.lack_ctfn_sspnd_enrt_flag,
                 p_information111     => l_pcx_rec.pcx_attribute1,
                 p_information120     => l_pcx_rec.pcx_attribute10,
                 p_information121     => l_pcx_rec.pcx_attribute11,
                 p_information122     => l_pcx_rec.pcx_attribute12,
                 p_information123     => l_pcx_rec.pcx_attribute13,
                 p_information124     => l_pcx_rec.pcx_attribute14,
                 p_information125     => l_pcx_rec.pcx_attribute15,
                 p_information126     => l_pcx_rec.pcx_attribute16,
                 p_information127     => l_pcx_rec.pcx_attribute17,
                 p_information128     => l_pcx_rec.pcx_attribute18,
                 p_information129     => l_pcx_rec.pcx_attribute19,
                 p_information112     => l_pcx_rec.pcx_attribute2,
                 p_information130     => l_pcx_rec.pcx_attribute20,
                 p_information131     => l_pcx_rec.pcx_attribute21,
                 p_information132     => l_pcx_rec.pcx_attribute22,
                 p_information133     => l_pcx_rec.pcx_attribute23,
                 p_information134     => l_pcx_rec.pcx_attribute24,
                 p_information135     => l_pcx_rec.pcx_attribute25,
                 p_information136     => l_pcx_rec.pcx_attribute26,
                 p_information137     => l_pcx_rec.pcx_attribute27,
                 p_information138     => l_pcx_rec.pcx_attribute28,
                 p_information139     => l_pcx_rec.pcx_attribute29,
                 p_information113     => l_pcx_rec.pcx_attribute3,
                 p_information140     => l_pcx_rec.pcx_attribute30,
                 p_information114     => l_pcx_rec.pcx_attribute4,
                 p_information115     => l_pcx_rec.pcx_attribute5,
                 p_information116     => l_pcx_rec.pcx_attribute6,
                 p_information117     => l_pcx_rec.pcx_attribute7,
                 p_information118     => l_pcx_rec.pcx_attribute8,
                 p_information119     => l_pcx_rec.pcx_attribute9,
                 p_information110     => l_pcx_rec.pcx_attribute_category,
                 p_information13     => l_pcx_rec.pfd_flag,
                 p_information261     => l_pcx_rec.pl_id,
                 p_information16     => l_pcx_rec.rlshp_typ_cd,
                 p_information14     => l_pcx_rec.rqd_flag,
                 p_information265     => l_pcx_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                 if l_out_pcx_result_id is null then
                   l_out_pcx_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_pcx_result_id := l_copy_entity_result_id ;
                 end if;
				  if (l_pcx_rec.ctfn_rqd_when_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_pcx_rec.ctfn_rqd_when_rl
							,p_business_group_id        => l_pcx_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

          --
          end loop;
        --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PL_BNF_CTFN_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PL_DPNT_CVG_CTFN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_pnd_from_parent(l_PL_ID) loop
      --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_pl_dpnt_cvg_ctfn_id := l_parent_rec.pl_dpnt_cvg_ctfn_id ;
        --
        for l_pnd_rec in c_pnd(l_parent_rec.pl_dpnt_cvg_ctfn_id,l_mirror_src_entity_result_id,'PND') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PND');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := hr_general.decode_lookup('BEN_DPNT_CVG_CTFN_TYP',l_pnd_rec.dpnt_cvg_ctfn_typ_cd); --'Intersection
            --
            if p_effective_date between l_pnd_rec.effective_start_date
                and l_pnd_rec.effective_end_date then
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
	         p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'PND',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_pnd_rec.pl_dpnt_cvg_ctfn_id,
                 p_information2     => l_pnd_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_pnd_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_pnd_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information257     => l_pnd_rec.ctfn_rqd_when_rl,
                 p_information13     => l_pnd_rec.dpnt_cvg_ctfn_typ_cd,
                 p_information12     => l_pnd_rec.lack_ctfn_sspnd_enrt_flag,
                 p_information11     => l_pnd_rec.pfd_flag,
                 p_information261     => l_pnd_rec.pl_id,
                 p_information111     => l_pnd_rec.pnd_attribute1,
                 p_information120     => l_pnd_rec.pnd_attribute10,
                 p_information121     => l_pnd_rec.pnd_attribute11,
                 p_information122     => l_pnd_rec.pnd_attribute12,
                 p_information123     => l_pnd_rec.pnd_attribute13,
                 p_information124     => l_pnd_rec.pnd_attribute14,
                 p_information125     => l_pnd_rec.pnd_attribute15,
                 p_information126     => l_pnd_rec.pnd_attribute16,
                 p_information127     => l_pnd_rec.pnd_attribute17,
                 p_information128     => l_pnd_rec.pnd_attribute18,
                 p_information129     => l_pnd_rec.pnd_attribute19,
                 p_information112     => l_pnd_rec.pnd_attribute2,
                 p_information130     => l_pnd_rec.pnd_attribute20,
                 p_information131     => l_pnd_rec.pnd_attribute21,
                 p_information132     => l_pnd_rec.pnd_attribute22,
                 p_information133     => l_pnd_rec.pnd_attribute23,
                 p_information134     => l_pnd_rec.pnd_attribute24,
                 p_information135     => l_pnd_rec.pnd_attribute25,
                 p_information136     => l_pnd_rec.pnd_attribute26,
                 p_information137     => l_pnd_rec.pnd_attribute27,
                 p_information138     => l_pnd_rec.pnd_attribute28,
                 p_information139     => l_pnd_rec.pnd_attribute29,
                 p_information113     => l_pnd_rec.pnd_attribute3,
                 p_information140     => l_pnd_rec.pnd_attribute30,
                 p_information114     => l_pnd_rec.pnd_attribute4,
                 p_information115     => l_pnd_rec.pnd_attribute5,
                 p_information116     => l_pnd_rec.pnd_attribute6,
                 p_information117     => l_pnd_rec.pnd_attribute7,
                 p_information118     => l_pnd_rec.pnd_attribute8,
                 p_information119     => l_pnd_rec.pnd_attribute9,
                 p_information110     => l_pnd_rec.pnd_attribute_category,
                 p_information15     => l_pnd_rec.rlshp_typ_cd,
                 p_information14     => l_pnd_rec.rqd_flag,
                 p_information265     => l_pnd_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                 if l_out_pnd_result_id is null then
                   l_out_pnd_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_pnd_result_id := l_copy_entity_result_id ;
                 end if;

				  if (l_pnd_rec.ctfn_rqd_when_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_pnd_rec.ctfn_rqd_when_rl
							,p_business_group_id        => l_pnd_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

          --
          end loop;
        --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PL_DPNT_CVG_CTFN_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_peo_from_parent(l_PL_ID) loop
      --
        l_mirror_src_entity_result_id := l_out_pln_result_id;
        l_parent_entity_result_id := l_out_pln_cpp_result_id;

        l_elig_to_prte_rsn_id := l_parent_rec.elig_to_prte_rsn_id ;
        --
        for l_peo_rec in c_peo(l_parent_rec.elig_to_prte_rsn_id,l_mirror_src_entity_result_id,'PEO') loop
        --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PEO');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_ler_name(l_peo_rec.ler_id,p_effective_date); --'Intersection';
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					 => 'PEO',
                 p_table_route_id                 => l_table_route_id,
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
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                 if l_out_peo_result_id is null then
                   l_out_peo_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_peo_result_id := l_copy_entity_result_id ;
                 end if;

				  if (l_peo_rec.mx_poe_det_dt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  =>  l_peo_rec.mx_poe_det_dt_rl
							,p_business_group_id        =>  l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_peo_rec.mx_poe_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  =>  l_peo_rec.mx_poe_rl
							,p_business_group_id        =>  l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_peo_rec.prtn_eff_end_dt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_peo_rec.prtn_eff_end_dt_rl
							,p_business_group_id        => l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_peo_rec.prtn_eff_strt_dt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_peo_rec.prtn_eff_strt_dt_rl
							,p_business_group_id        =>  l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_peo_rec.vrfy_fmly_mmbr_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_peo_rec.vrfy_fmly_mmbr_rl
							,p_business_group_id        => l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_peo_rec.wait_perd_dt_to_use_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  =>  l_peo_rec.wait_perd_dt_to_use_rl
							,p_business_group_id        =>  l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_peo_rec.wait_perd_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_peo_rec.wait_perd_rl
							,p_business_group_id        => l_peo_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
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
        -- START OF BEN_DSGN_RQMT_F ----------------------
        ---------------------------------------------------------------
          --
          for l_parent_rec  in c_ddr3_from_parent(l_PL_ID) loop
          --
            l_mirror_src_entity_result_id := l_out_pln_result_id;
            l_parent_entity_result_id := l_out_pln_cpp_result_id;

            --
            l_dsgn_rqmt_id := l_parent_rec.dsgn_rqmt_id ;
            --
            l_ddr3_dsgn_rqmt_esd := null;
            --
            for l_ddr_rec in c_ddr3(l_parent_rec.dsgn_rqmt_id,l_mirror_src_entity_result_id,'DDR') loop
            --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('DDR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('BEN_GRP_RLSHP',l_ddr_rec.grp_rlshp_cd); --'Intersection';
              --
              if p_effective_date between l_ddr_rec.effective_start_date
              and l_ddr_rec.effective_end_date then
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
                    p_parent_entity_result_id        => l_parent_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					 => 'DDR',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_ddr_rec.dsgn_rqmt_id,
                    p_information2     => l_ddr_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_ddr_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_ddr_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information13     => l_ddr_rec.cvr_all_elig_flag,
                    p_information111     => l_ddr_rec.ddr_attribute1,
                    p_information120     => l_ddr_rec.ddr_attribute10,
                    p_information121     => l_ddr_rec.ddr_attribute11,
                    p_information122     => l_ddr_rec.ddr_attribute12,
                    p_information123     => l_ddr_rec.ddr_attribute13,
                    p_information124     => l_ddr_rec.ddr_attribute14,
                    p_information125     => l_ddr_rec.ddr_attribute15,
                    p_information126     => l_ddr_rec.ddr_attribute16,
                    p_information127     => l_ddr_rec.ddr_attribute17,
                    p_information128     => l_ddr_rec.ddr_attribute18,
                    p_information129     => l_ddr_rec.ddr_attribute19,
                    p_information112     => l_ddr_rec.ddr_attribute2,
                    p_information130     => l_ddr_rec.ddr_attribute20,
                    p_information131     => l_ddr_rec.ddr_attribute21,
                    p_information132     => l_ddr_rec.ddr_attribute22,
                    p_information133     => l_ddr_rec.ddr_attribute23,
                    p_information134     => l_ddr_rec.ddr_attribute24,
                    p_information135     => l_ddr_rec.ddr_attribute25,
                    p_information136     => l_ddr_rec.ddr_attribute26,
                    p_information137     => l_ddr_rec.ddr_attribute27,
                    p_information138     => l_ddr_rec.ddr_attribute28,
                    p_information139     => l_ddr_rec.ddr_attribute29,
                    p_information113     => l_ddr_rec.ddr_attribute3,
                    p_information140     => l_ddr_rec.ddr_attribute30,
                    p_information114     => l_ddr_rec.ddr_attribute4,
                    p_information115     => l_ddr_rec.ddr_attribute5,
                    p_information116     => l_ddr_rec.ddr_attribute6,
                    p_information117     => l_ddr_rec.ddr_attribute7,
                    p_information118     => l_ddr_rec.ddr_attribute8,
                    p_information119     => l_ddr_rec.ddr_attribute9,
                    p_information110     => l_ddr_rec.ddr_attribute_category,
                    p_information15     => l_ddr_rec.dsgn_typ_cd,
                    p_information14     => l_ddr_rec.grp_rlshp_cd,
                    p_information262     => l_ddr_rec.mn_dpnts_rqd_num,
                    p_information263     => l_ddr_rec.mx_dpnts_alwd_num,
                    p_information11     => l_ddr_rec.no_mn_num_dfnd_flag,
                    p_information12     => l_ddr_rec.no_mx_num_dfnd_flag,
                    p_information258     => l_ddr_rec.oipl_id,
                    p_information247     => l_ddr_rec.opt_id,
                    p_information261     => l_ddr_rec.pl_id,
                    p_information265     => l_ddr_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_ddr_result_id is null then
                      l_out_ddr_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_ddr_result_id := l_copy_entity_result_id ;
                    end if;
                    --

                    -- To pass as effective date while creating the
                    -- non date-tracked child records
                    if l_ddr3_dsgn_rqmt_esd is null then
                      l_ddr3_dsgn_rqmt_esd := l_ddr_rec.EFFECTIVE_START_DATE;
                    end if;

             end loop;
             --
             ---------------------------------------------------------------
             -- START OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_drr3_from_parent(l_DSGN_RQMT_ID) loop
                --
                l_mirror_src_entity_result_id := l_out_ddr_result_id ;

                --
                l_dsgn_rqmt_rlshp_typ_id := l_parent_rec.dsgn_rqmt_rlshp_typ_id ;
                --
                for l_drr_rec in c_drr3(l_parent_rec.dsgn_rqmt_rlshp_typ_id,l_mirror_src_entity_result_id,'DRR') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('DRR');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := hr_general.decode_lookup('CONTACT',l_drr_rec.rlshp_typ_cd); --'Intersection';
                  --
                  l_result_type_cd := 'DISPLAY';
                    --
                  l_copy_entity_result_id := null;
                  l_object_version_number := null;
                  ben_copy_entity_results_api.create_copy_entity_results(
                    p_copy_entity_result_id           => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					 => 'DRR',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_drr_rec.dsgn_rqmt_rlshp_typ_id,
                    p_information2     => null,
                    p_information3     => null,
                    p_information4     => l_drr_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information10     => l_ddr3_dsgn_rqmt_esd,
                    p_information111     => l_drr_rec.drr_attribute1,
                    p_information120     => l_drr_rec.drr_attribute10,
                    p_information121     => l_drr_rec.drr_attribute11,
                    p_information122     => l_drr_rec.drr_attribute12,
                    p_information123     => l_drr_rec.drr_attribute13,
                    p_information124     => l_drr_rec.drr_attribute14,
                    p_information125     => l_drr_rec.drr_attribute15,
                    p_information126     => l_drr_rec.drr_attribute16,
                    p_information127     => l_drr_rec.drr_attribute17,
                    p_information128     => l_drr_rec.drr_attribute18,
                    p_information129     => l_drr_rec.drr_attribute19,
                    p_information112     => l_drr_rec.drr_attribute2,
                    p_information130     => l_drr_rec.drr_attribute20,
                    p_information131     => l_drr_rec.drr_attribute21,
                    p_information132     => l_drr_rec.drr_attribute22,
                    p_information133     => l_drr_rec.drr_attribute23,
                    p_information134     => l_drr_rec.drr_attribute24,
                    p_information135     => l_drr_rec.drr_attribute25,
                    p_information136     => l_drr_rec.drr_attribute26,
                    p_information137     => l_drr_rec.drr_attribute27,
                    p_information138     => l_drr_rec.drr_attribute28,
                    p_information139     => l_drr_rec.drr_attribute29,
                    p_information113     => l_drr_rec.drr_attribute3,
                    p_information140     => l_drr_rec.drr_attribute30,
                    p_information114     => l_drr_rec.drr_attribute4,
                    p_information115     => l_drr_rec.drr_attribute5,
                    p_information116     => l_drr_rec.drr_attribute6,
                    p_information117     => l_drr_rec.drr_attribute7,
                    p_information118     => l_drr_rec.drr_attribute8,
                    p_information119     => l_drr_rec.drr_attribute9,
                    p_information110     => l_drr_rec.drr_attribute_category,
                    p_information260     => l_drr_rec.dsgn_rqmt_id,
                    p_information11     => l_drr_rec.rlshp_typ_cd,
                    p_information265     => l_drr_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_drr_result_id is null then
                      l_out_drr_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_drr_result_id := l_copy_entity_result_id ;
                    end if;
                    --
                 end loop;
                 --
             end loop;
          ---------------------------------------------------------------
          -- END OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
          ---------------------------------------------------------------
          end loop;
        ---------------------------------------------------------------
        -- END OF BEN_DSGN_RQMT_F ----------------------
        ---------------------------------------------------------------
        for l_parent_rec  in c_cop1_from_parent(l_PL_ID) loop
          --
          create_oipl_result
            (  p_validate                =>p_validate
              ,p_copy_entity_result_id   =>l_out_pln_result_id
              ,p_copy_entity_txn_id      =>p_copy_entity_txn_id
              ,p_oipl_id                 =>l_parent_rec.oipl_id
              ,p_business_group_id       =>p_business_group_id
              ,p_number_of_copies        =>l_number_of_copies
              ,p_object_version_number   =>p_object_version_number
              ,p_effective_date          =>p_effective_date
              ,p_parent_entity_result_id =>l_out_pln_cpp_result_id
              ,p_no_dup_rslt             =>p_no_dup_rslt
            );
          --
        end loop;
        --
     end if;
   --
   end loop;
  --
  -- Return the copy_entity_result_id of Plan row
  p_copy_entity_result_id := l_out_pln_result_id;

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Business Group id, effective_date's can't be null
  -- pl_id or pgm_id must be supplied.
  --
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end create_plan_result;
--
-- Overloaded create_plan_result for Plan Design Wizard
-- This has been overloaded to allow copying Plans to staging area
-- without setting information8 to PLNIP
--
procedure create_plan_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  ,p_plan_in_program                in varchar2
  )
is
  l_copy_entity_result_id number;
  l_object_version_number number;
begin

     ben_plan_design_plan_module.create_plan_result
       (p_validate                       => p_validate
       ,p_copy_entity_result_id          => l_copy_entity_result_id
       ,p_copy_entity_txn_id             => p_copy_entity_txn_id
       ,p_pl_id                          => p_pl_id
       ,p_plip_id                        => p_plip_id
       ,p_business_group_id              => p_business_group_id
       ,p_number_of_copies               => p_number_of_copies
       ,p_object_version_number          => l_object_version_number
       ,p_effective_date                 => p_effective_date
       ,p_no_dup_rslt                    => p_no_dup_rslt
        );

    if p_plan_in_program = 'Y' then
      update ben_copy_entity_results
      set information8 = NULL
      where information1 = p_pl_id
      and copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'PLN';
    end if;

    -- Set out variables
    p_copy_entity_result_id := l_copy_entity_result_id;
    p_object_version_number := l_object_version_number;

end create_plan_result;

procedure create_popl_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ) is

  l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
  l_proc varchar2(72) := g_package||'create_popl_result';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
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
--        pqh_table_route trt
   where cpe.information1= c_parent_pk_id
   and   cpe.result_type_cd = l_cv_result_type_cd
   and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and   cpe.table_route_id = trt.table_route_id
   -- and   trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name) ;
   and cpe.table_alias = c_parent_table_alias;
   ---

   --
   -- Bug : 3752407 : Global cursor g_table_route will now be used
   --
   -- Cursor to get table_route_id
   -- cursor c_table_route(c_parent_table_alias varchar2) is
   -- select table_route_id
   -- from pqh_table_route trt
   -- where trt.table_alias = c_parent_table_alias;
   -- trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name) ;
   ---
   ---
---------------------------------------------------------------
-- START OF BEN_POPL_ACTN_TYP_F ----------------------
---------------------------------------------------------------
   cursor c_pat_from_parent(c_PL_ID number, c_PGM_ID number ) is
   select  popl_actn_typ_id
   from BEN_POPL_ACTN_TYP_F
   -- where  PL_ID = c_PL_ID ;
   where ( c_PL_ID is not null and c_PL_ID = PL_ID ) or
         ( c_PGM_ID is not null and c_PGM_ID = PGM_ID);
   --
   cursor c_pat(c_popl_actn_typ_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  pat.*
   from BEN_POPL_ACTN_TYP_F pat
   where  pat.popl_actn_typ_id = c_popl_actn_typ_id
     -- and pat.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_POPL_ACTN_TYP_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_popl_actn_typ_id
           -- and information4 = pat.business_group_id
           and information2 = pat.effective_start_date
           and information3 = pat.effective_end_date
     );
   l_out_pat_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_POPL_ACTN_TYP_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_POPL_ENRT_TYP_CYCL_F ----------------------
---------------------------------------------------------------
   cursor c_pet_from_parent(c_PL_ID number, c_PGM_ID number ) is
   select  distinct popl_enrt_typ_cycl_id
   from BEN_POPL_ENRT_TYP_CYCL_F
   where ( c_PL_ID is not null and c_PL_ID = PL_ID ) or
         ( c_PGM_ID is not null and c_PGM_ID = PGM_ID);
   --
   cursor c_pet(c_popl_enrt_typ_cycl_id number ,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  pet.*
   from BEN_POPL_ENRT_TYP_CYCL_F pet
   where  pet.popl_enrt_typ_cycl_id = c_popl_enrt_typ_cycl_id
     -- and pet.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_POPL_ENRT_TYP_CYCL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_popl_enrt_typ_cycl_id
           -- and information4 = pet.business_group_id
           and information2 = pet.effective_start_date
           and information3 = pet.effective_end_date
     );
   l_pet_popl_enrt_typ_cycl_esd ben_popl_enrt_typ_cycl_f.effective_start_date%type;
   l_out_pet_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_POPL_ENRT_TYP_CYCL_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_POPL_ORG_F ----------------------
---------------------------------------------------------------
   cursor c_cpo_from_parent(c_PL_ID number, c_PGM_ID number ) is
   select  popl_org_id
   from BEN_POPL_ORG_F
   --where  PL_ID = c_PL_ID ;
   where ( c_PL_ID is not null and c_PL_ID = PL_ID ) or
         ( c_PGM_ID is not null and c_PGM_ID = PGM_ID);
   --
   cursor c_cpo(c_popl_org_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  cpo.*
   from BEN_POPL_ORG_F cpo
   where  cpo.popl_org_id = c_popl_org_id
     -- and cpo.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause =  'BEN_POPL_ORG_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_popl_org_id
           -- and information4 = cpo.business_group_id
           and information2 = cpo.effective_start_date
           and information3 = cpo.effective_end_date
     );
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name2(p_id in number,p_date in date) is
    select org.name
    from hr_organization_units org
    where business_group_id = p_business_group_id
      and organization_id = p_id
      and  p_date  between  Date_from
          and nvl(Date_to, p_date) ;

   l_out_cpo_result_id  number(15);

   cursor c_organization_start_date(c_organization_id number) is
   select date_from
   from hr_all_organization_units
   where organization_id = c_organization_id;

   l_organization_start_date  hr_all_organization_units.date_from%type;
---------------------------------------------------------------
-- END OF BEN_POPL_ORG_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_POPL_YR_PERD ----------------------
---------------------------------------------------------------
   cursor c_cpy_from_parent(c_PL_ID number, c_PGM_ID number ) is
   select  popl_yr_perd_id
   from BEN_POPL_YR_PERD
   --where  PL_ID = c_PL_ID ;
   where ( c_PL_ID is not null and c_PL_ID = PL_ID ) or
         ( c_PGM_ID is not null and c_PGM_ID = PGM_ID);
   --
   cursor c_cpy(c_popl_yr_perd_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  cpy.*
   from BEN_POPL_YR_PERD cpy
   where  cpy.popl_yr_perd_id = c_popl_yr_perd_id
     -- and cpy.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_POPL_YR_PERD'
           and cpe.table_alias = c_table_alias
           and information1 = c_popl_yr_perd_id
           -- and information4 = cpy.business_group_id
       );
    l_out_cpy_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_POPL_YR_PERD ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_POPL_RPTG_GRP_F ----------------------
---------------------------------------------------------------
   cursor c_rgr_from_parent(c_PL_ID number, c_PGM_ID number ) is
   select  popl_rptg_grp_id
   from BEN_POPL_RPTG_GRP_F
   -- where  PL_ID = c_PL_ID ;
   where ( c_PL_ID is not null and c_PL_ID = PL_ID ) or
         ( c_PGM_ID is not null and c_PGM_ID = PGM_ID);
   --
   cursor c_rgr(c_popl_rptg_grp_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  rgr.*
   from BEN_POPL_RPTG_GRP_F rgr
   where  rgr.popl_rptg_grp_id = c_popl_rptg_grp_id
     -- and rgr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
              --pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_POPL_RPTG_GRP_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_popl_rptg_grp_id
           -- and information4 = rgr.business_group_id
           and information2 = rgr.effective_start_date
           and information3 = rgr.effective_end_date
     );
    l_out_rgr_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_POPL_RPTG_GRP_F ----------------------
---------------------------------------------------------------
   ---
---------------------------------------------------------------
-- START OF BEN_YR_PERD ----------------------
---------------------------------------------------------------
   cursor c_yrp_from_parent(c_POPL_YR_PERD_ID number) is
   select  distinct yr_perd_id
   from BEN_POPL_YR_PERD
   where  POPL_YR_PERD_ID = c_POPL_YR_PERD_ID ;
   --
---------------------------------------------------------------
-- END OF BEN_YR_PERD ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_POPL_ORG_ROLE_F ----------------------
---------------------------------------------------------------
   cursor c_cpr_from_parent(c_POPL_ORG_ID number) is
   select  popl_org_role_id
   from BEN_POPL_ORG_ROLE_F
   where  POPL_ORG_ID = c_POPL_ORG_ID ;
   --
   cursor c_cpr(c_popl_org_role_id number ,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  cpr.*
   from BEN_POPL_ORG_ROLE_F cpr
   where  cpr.popl_org_role_id = c_popl_org_role_id
     -- and cpr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_POPL_ORG_ROLE_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_popl_org_role_id
           -- and information4 = cpr.business_group_id
           and information2 = cpr.effective_start_date
           and information3 = cpr.effective_end_date
     );
     l_out_cpr_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_POPL_ORG_ROLE_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_RPTG_GRP ----------------------
---------------------------------------------------------------
   cursor c_bnr_from_parent(c_POPL_RPTG_GRP_ID number) is
   select  rptg_grp_id
   from BEN_POPL_RPTG_GRP_F
   where  POPL_RPTG_GRP_ID = c_POPL_RPTG_GRP_ID ;
   --
   cursor c_bnr(c_rptg_grp_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  bnr.*
   from BEN_RPTG_GRP bnr
   where  bnr.rptg_grp_id = c_rptg_grp_id
     -- and bnr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_RPTG_GRP'
           and cpe.table_alias = c_table_alias
           and information1 = c_rptg_grp_id
           -- and information4 = bnr.business_group_id
     );
     l_out_bnr_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_RPTG_GRP ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_LEE_RSN_F ----------------------
---------------------------------------------------------------
   cursor c_len_from_parent(c_POPL_ENRT_TYP_CYCL_ID number) is
   select distinct lee_rsn_id
   from BEN_LEE_RSN_F
   where  POPL_ENRT_TYP_CYCL_ID = c_POPL_ENRT_TYP_CYCL_ID ;
   --
   cursor c_len(c_lee_rsn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  len.*
   from BEN_LEE_RSN_F len
   where  len.lee_rsn_id = c_lee_rsn_id
     -- and len.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LEE_RSN_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_lee_rsn_id
           -- and information4 = len.business_group_id
           and information2 = len.effective_start_date
           and information3 = len.effective_end_date
     );
   cursor c_len_drp(c_lee_rsn_id number,c_mirror_src_entity_result_id number,
                    c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe,
              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LEE_RSN_F'
         and trt.table_alias = c_table_alias
         and information1 = c_lee_rsn_id
         -- and information4 = p_business_group_id
        ;
    l_out_len_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_LEE_RSN_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_ENRT_PERD ----------------------
---------------------------------------------------------------
   cursor c_enp_from_parent(c_POPL_ENRT_TYP_CYCL_ID number) is
   select  enrt_perd_id
   from BEN_ENRT_PERD
   where  POPL_ENRT_TYP_CYCL_ID = c_POPL_ENRT_TYP_CYCL_ID ;
   --
   cursor c_enp(c_enrt_perd_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  enp.*
   from BEN_ENRT_PERD enp
   where  enp.enrt_perd_id = c_enrt_perd_id
     -- and enp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_ENRT_PERD'
           and cpe.table_alias = c_table_alias
           and information1 = c_enrt_perd_id
           -- and information4 = enp.business_group_id
    );
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name(p_id in number,p_date in date) is
      select pos.NAME name
      from PER_POSITION_STRUCTURES pos,
           PER_POS_STRUCTURE_VERSIONS pov
      where pos.business_group_id = p_business_group_id
        and POS_STRUCTURE_VERSION_ID = p_id
        and pos.POSITION_STRUCTURE_ID = pov.POSITION_STRUCTURE_ID
        and p_date between nvl(POV.DATE_FROM, p_date)
                                 and nvl(POV.DATE_TO, p_date);
    --

    cursor c_pos_structure_start_date(c_pos_structure_version_id number) is
    select date_from
    from per_pos_structure_versions
    where pos_structure_version_id = c_pos_structure_version_id;

    l_pos_structure_start_date per_pos_structure_versions.date_from%type;
    l_mapping_id         number;
    l_mapping_name       varchar2(600);
    l_mapping_column_name1 pqh_attributes.attribute_name%type;
    l_mapping_column_name2 pqh_attributes.attribute_name%type;
    l_information172     varchar2(600);
    l_out_enp_result_id  number(15);
    --
---------------------------------------------------------------
-- END OF BEN_ENRT_PERD ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_YR_PERD ----------------------
---------------------------------------------------------------
   cursor c_yrp1_from_parent(c_ENRT_PERD_ID number) is
   select  distinct yr_perd_id
   from BEN_ENRT_PERD
   where  ENRT_PERD_ID = c_ENRT_PERD_ID ;
   --
---------------------------------------------------------------
-- END OF BEN_YR_PERD ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_ENRT_PERD_FOR_PL_F ----------------------
---------------------------------------------------------------
   cursor c_erp_from_parent(c_ENRT_PERD_ID number, c_pgm_id number) is
   select  ERP.enrt_perd_for_pl_id
   from BEN_ENRT_PERD_FOR_PL_F ERP
   where  ENRT_PERD_ID = c_ENRT_PERD_ID
     and  exists (select null
                  from ben_plip_f plip
                  where plip.pl_id =  ERP.pl_id
                    and plip.pgm_id = c_pgm_id
                    and ERP.effective_start_date between
                        plip.effective_start_date and plip.effective_end_date);
   --
   cursor c_erp(c_enrt_perd_for_pl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  erp.*
   from BEN_ENRT_PERD_FOR_PL_F erp
   where  erp.enrt_perd_for_pl_id = c_enrt_perd_for_pl_id
     -- and erp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_ENRT_PERD_FOR_PL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_enrt_perd_for_pl_id
           -- and information4 = erp.business_group_id
           and information2 = erp.effective_start_date
           and information3 = erp.effective_end_date
     );
     l_out_erp_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_ENRT_PERD_FOR_PL_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_SCHEDD_ENRT_RL_F ----------------------
---------------------------------------------------------------
   cursor c_ser_from_parent(c_ENRT_PERD_ID number) is
   select  schedd_enrt_rl_id
   from BEN_SCHEDD_ENRT_RL_F
   where  ENRT_PERD_ID = c_ENRT_PERD_ID ;
   --
   cursor c_ser(c_schedd_enrt_rl_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  ser.*
   from BEN_SCHEDD_ENRT_RL_F ser
   where  ser.schedd_enrt_rl_id = c_schedd_enrt_rl_id
     -- and ser.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_SCHEDD_ENRT_RL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_schedd_enrt_rl_id
           -- and information4 = ser.business_group_id
           and information2 = ser.effective_start_date
           and information3 = ser.effective_end_date
     );
     l_out_ser_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_SCHEDD_ENRT_RL_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_LEE_RSN_RL_F ----------------------
---------------------------------------------------------------
   cursor c_lrr_from_parent(c_LEE_RSN_ID number) is
   select  lee_rsn_rl_id
   from BEN_LEE_RSN_RL_F
   where  LEE_RSN_ID = c_LEE_RSN_ID ;
   --
   cursor c_lrr(c_lee_rsn_rl_id number,c_mirror_src_entity_result_id number,
               c_table_alias varchar2) is
   select  lrr.*
   from BEN_LEE_RSN_RL_F lrr
   where  lrr.lee_rsn_rl_id = c_lee_rsn_rl_id
     -- and lrr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LEE_RSN_RL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_lee_rsn_rl_id
           -- and information4 = lrr.business_group_id
           and information2 = lrr.effective_start_date
           and information3 = lrr.effective_end_date
     );
     l_out_lrr_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_LEE_RSN_RL_F ----------------------
---------------------------------------------------------------
---------------------------------------------------------------
-- START OF BEN_ENRT_PERD_FOR_PL_F ----------------------
---------------------------------------------------------------
   cursor c_erp1_from_parent(c_LEE_RSN_ID number, c_pgm_id number) is
   select  enrt_perd_for_pl_id
   from BEN_ENRT_PERD_FOR_PL_F ERP
   where  LEE_RSN_ID = c_LEE_RSN_ID
     and  exists (select null
                  from ben_plip_f plip
                  where plip.pl_id =  ERP.pl_id
                    and plip.pgm_id = c_pgm_id
                    and ERP.effective_start_date between
                        plip.effective_start_date and plip.effective_end_date);
   --
   cursor c_erp1(c_enrt_perd_for_pl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  erp.*
   from BEN_ENRT_PERD_FOR_PL_F erp
   where  erp.enrt_perd_for_pl_id = c_enrt_perd_for_pl_id
     -- and erp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_ENRT_PERD_FOR_PL_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_enrt_perd_for_pl_id
           -- and information4 = erp.business_group_id
           and information2 = erp.effective_start_date
           and information3 = erp.effective_end_date
     );

     l_out_erp1_result_id  number(15);
---------------------------------------------------------------
-- END OF BEN_ENRT_PERD_FOR_PL_F ----------------------
---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_ACTN_TYP ----------------------
  ---------------------------------------------------------------
   cursor c_eat_from_parent(c_POPL_ACTN_TYP_ID number) is
   select  actn_typ_id
   from BEN_POPL_ACTN_TYP_F
   where  POPL_ACTN_TYP_ID = c_POPL_ACTN_TYP_ID ;
   --
   cursor c_eat(c_actn_typ_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  eat.*
   from BEN_ACTN_TYP eat
   where  eat.actn_typ_id = c_actn_typ_id
     -- and eat.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_ACTN_TYP'
           and cpe.table_alias = c_table_alias
           and information1 = c_actn_typ_id
           -- and information4 = eat.business_group_id
     );
     l_out_eat_result_id  number(15);
  ---------------------------------------------------------------
  -- END OF BEN_ACTN_TYP ----------------------
  ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_REGN_F ----------------------
   ---------------------------------------------------------------
   cursor c_prg_from_parent(c_RPTG_GRP_ID number) is
   select  pl_regn_id
   from BEN_PL_REGN_F
   where  RPTG_GRP_ID = c_RPTG_GRP_ID ;
   --
   cursor c_prg(c_pl_regn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  prg.*
   from BEN_PL_REGN_F prg
   where  prg.pl_regn_id = c_pl_regn_id
     -- and prg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_REGN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_regn_id
         -- and information4 = prg.business_group_id
           and information2 = prg.effective_start_date
           and information3 = prg.effective_end_date
        );
    l_pl_regn_id                 number(15);
    l_out_prg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_REGN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_REGY_BOD_F ----------------------
   ---------------------------------------------------------------
   cursor c_prb_from_parent(c_RPTG_GRP_ID number) is
   select  pl_regy_bod_id
   from BEN_PL_REGY_BOD_F
   where  RPTG_GRP_ID = c_RPTG_GRP_ID ;
   --
   cursor c_prb(c_pl_regy_bod_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  prb.*
   from BEN_PL_REGY_BOD_F prb
   where  prb.pl_regy_bod_id = c_pl_regy_bod_id
     -- and prb.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_REGY_BOD_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_regy_bod_id
         -- and information4 = prb.business_group_id
           and information2 = prb.effective_start_date
           and information3 = prb.effective_end_date
        );
    l_pl_regy_bod_id                 number(15);
    l_out_prb_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_REGY_BOD_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_REGY_PRP_F ----------------------
   ---------------------------------------------------------------
   cursor c_prp_from_parent(c_PL_REGY_BOD_ID number) is
   select  pl_regy_prps_id
   from BEN_PL_REGY_PRP_F
   where  PL_REGY_BOD_ID = c_PL_REGY_BOD_ID ;
   --
   cursor c_prp(c_pl_regy_prps_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  prp.*
   from BEN_PL_REGY_PRP_F prp
   where  prp.pl_regy_prps_id = c_pl_regy_prps_id
     -- and prp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_REGY_PRP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_regy_prps_id
         -- and information4 = prp.business_group_id
           and information2 = prp.effective_start_date
           and information3 = prp.effective_end_date
        );
    l_pl_regy_prps_id                 number(15);
    l_out_prp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_REGY_PRP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_POPL_RPTG_GRP_F ----------------------
   ---------------------------------------------------------------
   cursor c_rgr1_from_parent(c_RPTG_GRP_ID number) is
   select  popl_rptg_grp_id
   from BEN_POPL_RPTG_GRP_F
   where  RPTG_GRP_ID = c_RPTG_GRP_ID ;
   --
   cursor c_rgr1(c_popl_rptg_grp_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  rgr.*
   from BEN_POPL_RPTG_GRP_F rgr
   where  rgr.popl_rptg_grp_id = c_popl_rptg_grp_id
     -- and rgr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_POPL_RPTG_GRP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_popl_rptg_grp_id
         -- and information4 = rgr.business_group_id
           and information2 = rgr.effective_start_date
           and information3 = rgr.effective_end_date
        );
   ---------------------------------------------------------------
   -- END OF BEN_POPL_RPTG_GRP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_REGN_F ----------------------
   ---------------------------------------------------------------
   cursor c_reg_from_parent(c_PL_REGN_ID number) is
   select  regn_id
   from BEN_PL_REGN_F
   where PL_REGN_ID = c_PL_REGN_ID ;
   --
   cursor c_reg(c_regn_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  reg.*
   from BEN_REGN_F reg
   where  reg.regn_id = c_regn_id
     -- and reg.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_REGN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_regn_id
         -- and information4 = reg.business_group_id
           and information2 = reg.effective_start_date
           and information3 = reg.effective_end_date
        );
    l_regn_id                 number(15);
    l_out_reg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_REGN_F ----------------------
   ---------------------------------------------------------------

   cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
--    and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

   l_table_route_id            number(15);
   l_mirror_src_entity_result_id number(15):= p_copy_entity_result_id;
   l_result_type_cd            varchar2(30);
   l_information5              ben_copy_entity_results.information5%type;
   l_regn_name                 ben_regn_f.name%type;
   --
   l_pl_id                     number(15);
   l_popl_yr_perd_id           number(15);
   l_yr_perd_id                number(15);
   l_wthn_yr_perd_id           number(15);
   l_yr_perd_id1               number(15);
   l_wthn_yr_perd_id1          number(15);
   l_popl_org_id               number(15);
   l_popl_org_role_id          number(15);
   l_pl_gd_or_svc_id           number(15);
   l_gd_or_svc_typ_id          number(15);
   l_pl_gd_r_svc_ctfn_id       number(15);
   l_rptg_grp_id               number(15);
   l_popl_rptg_grp_id          number(15);
   l_number_of_copies          number(15);
   l_popl_enrt_typ_cycl_id     number(15);
   l_enrt_perd_id              number(15);
   l_lee_rsn_id                number(15);
   l_schedd_enrt_rl_id         number(15);
   l_enrt_perd_for_pl_id       number(15);
   l_enrt_perd_for_pl_id1      number(15);
   l_lee_rsn_rl_id             number(15);
   l_actn_typ_id               number(15);
   l_popl_actn_typ_id          number(15);

   l_parent_entity_result_id   number(15);
begin
   --
   --
   l_number_of_copies := p_number_of_copies ;

   --
   ---------------------------------------------------------------
   -- START OF BEN_POPL_ACTN_TYP_F ----------------------
   ---------------------------------------------------------------
   --
   --
   for l_parent_rec  in c_pat_from_parent(p_pl_id,p_pgm_id) loop
   --
   --
      l_mirror_src_entity_result_id := p_copy_entity_result_id ;
      l_parent_entity_result_id := p_parent_entity_result_id ;
      l_popl_actn_typ_id := l_parent_rec.popl_actn_typ_id;

      for l_pat_rec in c_pat(l_parent_rec.popl_actn_typ_id,l_mirror_src_entity_result_id,'PAT') loop
      --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PAT');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_actn_typ_name(l_pat_rec.actn_typ_id); --'Intersection;
            --
            --
            if p_effective_date between l_pat_rec.effective_start_date
                and l_pat_rec.effective_end_date then
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
		 p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_table_alias					  => 'PAT',
                 p_number_of_copies               => l_number_of_copies,
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_pat_rec.popl_actn_typ_id,
                 p_information2     => l_pat_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_pat_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_pat_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
		 p_information11     => l_pat_rec.actn_typ_due_dt_cd,
		 p_information262     => l_pat_rec.actn_typ_due_dt_rl,
		 p_information221     => l_pat_rec.actn_typ_id,
		 p_information111     => l_pat_rec.pat_attribute1,
		 p_information120     => l_pat_rec.pat_attribute10,
		 p_information121     => l_pat_rec.pat_attribute11,
		 p_information122     => l_pat_rec.pat_attribute12,
		 p_information123     => l_pat_rec.pat_attribute13,
		 p_information124     => l_pat_rec.pat_attribute14,
		 p_information125     => l_pat_rec.pat_attribute15,
		 p_information126     => l_pat_rec.pat_attribute16,
		 p_information127     => l_pat_rec.pat_attribute17,
		 p_information128     => l_pat_rec.pat_attribute18,
		 p_information129     => l_pat_rec.pat_attribute19,
		 p_information112     => l_pat_rec.pat_attribute2,
		 p_information130     => l_pat_rec.pat_attribute20,
		 p_information131     => l_pat_rec.pat_attribute21,
		 p_information132     => l_pat_rec.pat_attribute22,
		 p_information133     => l_pat_rec.pat_attribute23,
		 p_information134     => l_pat_rec.pat_attribute24,
		 p_information135     => l_pat_rec.pat_attribute25,
		 p_information136     => l_pat_rec.pat_attribute26,
		 p_information137     => l_pat_rec.pat_attribute27,
		 p_information138     => l_pat_rec.pat_attribute28,
		 p_information139     => l_pat_rec.pat_attribute29,
		 p_information113     => l_pat_rec.pat_attribute3,
		 p_information140     => l_pat_rec.pat_attribute30,
		 p_information114     => l_pat_rec.pat_attribute4,
		 p_information115     => l_pat_rec.pat_attribute5,
		 p_information116     => l_pat_rec.pat_attribute6,
		 p_information117     => l_pat_rec.pat_attribute7,
		 p_information118     => l_pat_rec.pat_attribute8,
		 p_information119     => l_pat_rec.pat_attribute9,
		 p_information110     => l_pat_rec.pat_attribute_category,
		 p_information260     => l_pat_rec.pgm_id,
		 p_information261     => l_pat_rec.pl_id,
                 p_information265     => l_pat_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

          if l_out_pat_result_id is null then
            l_out_pat_result_id := l_copy_entity_result_id;
          end if;

          if l_result_type_cd = 'DISPLAY' then
            l_out_pat_result_id := l_copy_entity_result_id ;
          end if;

				  if (l_pat_rec.actn_typ_due_dt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_pat_rec.actn_typ_due_dt_rl
							,p_business_group_id        => l_pat_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

          --
          end loop;
        --
          ---------------------------------------------------------------
          -- START OF BEN_ACTN_TYP ----------------------
          ---------------------------------------------------------------
           --
           for l_parent_rec  in c_eat_from_parent(l_POPL_ACTN_TYP_ID) loop
           --
             l_mirror_src_entity_result_id := l_out_pat_result_id ;

             l_actn_typ_id := l_parent_rec.actn_typ_id ;

             if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
               open c_object_exists(l_actn_typ_id,'EAT');
               fetch c_object_exists into l_dummy;
               if c_object_exists%found then
                 close c_object_exists;
                 exit;
               end if;
               close c_object_exists;
             end if;
             --
             for l_eat_rec in c_eat(l_parent_rec.actn_typ_id,l_mirror_src_entity_result_id,'EAT') loop
             --
             --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('EAT');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := l_eat_rec.name; --'Intersection';
                 --
                 l_result_type_cd := 'DISPLAY';
                 --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                      p_copy_entity_result_id          => l_copy_entity_result_id,
                      p_copy_entity_txn_id             => p_copy_entity_txn_id,
                      p_result_type_cd                 => l_result_type_cd,
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					  => 'EAT',
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
		      p_object_version_number          => l_object_version_number,
	              p_effective_date                 => p_effective_date       );
               --

               --

                  if l_out_eat_result_id is null then
                   l_out_eat_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_eat_result_id := l_copy_entity_result_id ;
                 end if;

               end loop;
             --
             end loop;
          ---------------------------------------------------------------
          -- END OF BEN_ACTN_TYP ----------------------
          ---------------------------------------------------------------
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_POPL_ACTN_TYP_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_POPL_ENRT_TYP_CYCL_F ----------------------
     ---------------------------------------------------------------
      --
      for l_parent_rec  in c_pet_from_parent(p_pl_id,p_pgm_id) loop
      --
      --
        l_pet_popl_enrt_typ_cycl_esd := null;
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        l_parent_entity_result_id := p_parent_entity_result_id ;
        --
        l_popl_enrt_typ_cycl_id := l_parent_rec.popl_enrt_typ_cycl_id ;
        --
        for l_pet_rec in c_pet(l_parent_rec.popl_enrt_typ_cycl_id,l_mirror_src_entity_result_id,'PET') loop
        --
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PET');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := hr_general.decode_lookup('BEN_ENRT_TYP_CYCL',l_pet_rec.enrt_typ_cycl_cd); --'Intersection';
            if p_effective_date between l_pet_rec.effective_start_date
                and l_pet_rec.effective_end_date then
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_table_alias					  => 'PET',
                 p_number_of_copies               => l_number_of_copies,
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_pet_rec.popl_enrt_typ_cycl_id,
                 p_information2     => l_pet_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_pet_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_pet_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information11     => l_pet_rec.enrt_typ_cycl_cd,
                 p_information111     => l_pet_rec.pet_attribute1,
                 p_information120     => l_pet_rec.pet_attribute10,
                 p_information121     => l_pet_rec.pet_attribute11,
                 p_information122     => l_pet_rec.pet_attribute12,
                 p_information123     => l_pet_rec.pet_attribute13,
                 p_information124     => l_pet_rec.pet_attribute14,
                 p_information125     => l_pet_rec.pet_attribute15,
                 p_information126     => l_pet_rec.pet_attribute16,
                 p_information127     => l_pet_rec.pet_attribute17,
                 p_information128     => l_pet_rec.pet_attribute18,
                 p_information129     => l_pet_rec.pet_attribute19,
                 p_information112     => l_pet_rec.pet_attribute2,
                 p_information130     => l_pet_rec.pet_attribute20,
                 p_information131     => l_pet_rec.pet_attribute21,
                 p_information132     => l_pet_rec.pet_attribute22,
                 p_information133     => l_pet_rec.pet_attribute23,
                 p_information134     => l_pet_rec.pet_attribute24,
                 p_information135     => l_pet_rec.pet_attribute25,
                 p_information136     => l_pet_rec.pet_attribute26,
                 p_information137     => l_pet_rec.pet_attribute27,
                 p_information138     => l_pet_rec.pet_attribute28,
                 p_information139     => l_pet_rec.pet_attribute29,
                 p_information113     => l_pet_rec.pet_attribute3,
                 p_information140     => l_pet_rec.pet_attribute30,
                 p_information114     => l_pet_rec.pet_attribute4,
                 p_information115     => l_pet_rec.pet_attribute5,
                 p_information116     => l_pet_rec.pet_attribute6,
                 p_information117     => l_pet_rec.pet_attribute7,
                 p_information118     => l_pet_rec.pet_attribute8,
                 p_information119     => l_pet_rec.pet_attribute9,
                 p_information110     => l_pet_rec.pet_attribute_category,
                 p_information260     => l_pet_rec.pgm_id,
                 p_information261     => l_pet_rec.pl_id,
                 p_information265     => l_pet_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
                 --

                 if l_out_pet_result_id is null then
                   l_out_pet_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_pet_result_id := l_copy_entity_result_id ;
                 end if;


                 -- To pass as effective date while creating the
                 -- non date-tracked child records
                 if l_pet_popl_enrt_typ_cycl_esd is null then
                   l_pet_popl_enrt_typ_cycl_esd := l_pet_rec.EFFECTIVE_START_DATE;
                 end if;
          end loop;

        ---------------------------------------------------------------
        -- START OF BEN_ENRT_PERD ----------------------
        ---------------------------------------------------------------
         --
         for l_parent_rec  in c_enp_from_parent(l_POPL_ENRT_TYP_CYCL_ID) loop
         --
           l_mirror_src_entity_result_id := l_out_pet_result_id ;

           l_enrt_perd_id := l_parent_rec.enrt_perd_id ;
           --
           for l_enp_rec in c_enp(l_parent_rec.enrt_perd_id,l_mirror_src_entity_result_id,'ENP') loop
           --
           --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('ENP');
               fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
               --
               l_information5  := TO_CHAR(l_enp_rec.strt_dt,'DD-Mon-YYYY')||' -  '||
                                  TO_CHAR(l_enp_rec.end_dt,'DD-Mon-YYYY'); --'Intersection';
               --
               l_result_type_cd := 'DISPLAY';
               --
               l_copy_entity_result_id := null;
               l_object_version_number := null;

               -- To store effective_start_date of position_structure_version
               -- for Mapping - Bug 2958658
               --
               l_pos_structure_start_date := null;
               if l_enp_rec.pos_structure_version_id is not null then
                 open c_pos_structure_start_date(l_enp_rec.pos_structure_version_id);
                 fetch c_pos_structure_start_date into l_pos_structure_start_date;
                 close c_pos_structure_start_date;
               end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name(l_enp_rec.pos_structure_version_id,
                                           NVL(l_pos_structure_start_date,p_effective_date));
                   fetch c_get_mapping_name into l_mapping_name;
                   close c_get_mapping_name;
                   --
                   l_mapping_id   := l_enp_rec.pos_structure_version_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                              l_mapping_column_name1,
                                              l_mapping_column_name2,
                                              p_copy_entity_txn_id);
                   --

               ben_copy_entity_results_api.create_copy_entity_results(
                    p_copy_entity_result_id           => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
					p_table_alias					  => 'ENP',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_enp_rec.enrt_perd_id,
                    p_information2     => null,
                    p_information3     => null,
                    p_information4     => l_enp_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information10      => l_pet_popl_enrt_typ_cycl_esd,
                    p_information306     => l_enp_rec.asg_updt_eff_date,
                    p_information316     => l_enp_rec.asnd_lf_evt_dt,
                    p_information11      => l_enp_rec.auto_distr_flag,
                    p_information308     => l_enp_rec.bdgt_upd_end_dt,
                    p_information309     => l_enp_rec.bdgt_upd_strt_dt,
                    p_information16      => l_enp_rec.cls_enrt_dt_to_use_cd,
                    -- tilak cwb pl copy fix
                    p_information24      => l_enp_rec.approval_mode_cd,
                    p_information310     => l_enp_rec.data_freeze_date,
                    p_information268     => l_enp_rec.hrchy_ame_app_id,
                    p_information25      => l_enp_rec.hrchy_ame_trn_cd,
                    p_information267     => l_enp_rec.hrchy_rl,
                    p_information23      => l_enp_rec.sal_chg_reason_cd,
                    --
                    p_information312     => l_enp_rec.dflt_enrt_dt,
                    p_information12      => l_enp_rec.dflt_ws_acc_cd,
                    p_information13      => l_enp_rec.emp_interview_type_cd,
                    p_information317     => l_enp_rec.end_dt,
                    p_information111     => l_enp_rec.enp_attribute1,
                    p_information120     => l_enp_rec.enp_attribute10,
                    p_information121     => l_enp_rec.enp_attribute11,
                    p_information122     => l_enp_rec.enp_attribute12,
                    p_information123     => l_enp_rec.enp_attribute13,
                    p_information124     => l_enp_rec.enp_attribute14,
                    p_information125     => l_enp_rec.enp_attribute15,
                    p_information126     => l_enp_rec.enp_attribute16,
                    p_information127     => l_enp_rec.enp_attribute17,
                    p_information128     => l_enp_rec.enp_attribute18,
                    p_information129     => l_enp_rec.enp_attribute19,
                    p_information112     => l_enp_rec.enp_attribute2,
                    p_information130     => l_enp_rec.enp_attribute20,
                    p_information131     => l_enp_rec.enp_attribute21,
                    p_information132     => l_enp_rec.enp_attribute22,
                    p_information133     => l_enp_rec.enp_attribute23,
                    p_information134     => l_enp_rec.enp_attribute24,
                    p_information135     => l_enp_rec.enp_attribute25,
                    p_information136     => l_enp_rec.enp_attribute26,
                    p_information137     => l_enp_rec.enp_attribute27,
                    p_information138     => l_enp_rec.enp_attribute28,
                    p_information139     => l_enp_rec.enp_attribute29,
                    p_information113     => l_enp_rec.enp_attribute3,
                    p_information140     => l_enp_rec.enp_attribute30,
                    p_information114     => l_enp_rec.enp_attribute4,
                    p_information115     => l_enp_rec.enp_attribute5,
                    p_information116     => l_enp_rec.enp_attribute6,
                    p_information117     => l_enp_rec.enp_attribute7,
                    p_information118     => l_enp_rec.enp_attribute8,
                    p_information119     => l_enp_rec.enp_attribute9,
                    p_information110     => l_enp_rec.enp_attribute_category,
                    p_information314     => l_enp_rec.enrt_cvg_end_dt,
                    p_information18      => l_enp_rec.enrt_cvg_end_dt_cd,
                    p_information263     => l_enp_rec.enrt_cvg_end_dt_rl,
                    p_information313     => l_enp_rec.enrt_cvg_strt_dt,
                    p_information17      => l_enp_rec.enrt_cvg_strt_dt_cd,
                    p_information262     => l_enp_rec.enrt_cvg_strt_dt_rl,
                    p_information14      => l_enp_rec.hrchy_to_use_cd,
                    p_information257     => l_enp_rec.ler_id,
                    p_information307     => l_enp_rec.perf_revw_strt_dt,
                    p_information232     => l_enp_rec.popl_enrt_typ_cycl_id,
                    -- Data for MAPPING columns.
                    p_information173     => l_mapping_name,
                    p_information174     => l_mapping_id,
                    p_information181     => l_mapping_column_name1,
                    p_information182     => l_mapping_column_name2,
                    -- END other product Mapping columns.
                    p_information315     => l_enp_rec.procg_end_dt,
                    p_information15      => l_enp_rec.prsvr_bdgt_cd,
                    p_information20      => l_enp_rec.rt_end_dt_cd,
                    p_information264     => l_enp_rec.rt_end_dt_rl,
                    p_information19      => l_enp_rec.rt_strt_dt_cd,
                    p_information261     => l_enp_rec.rt_strt_dt_rl,
                    p_information318     => l_enp_rec.strt_dt,
                    p_information21      => l_enp_rec.uses_bdgt_flag,
                    p_information319     => l_enp_rec.ws_upd_end_dt,
                    p_information320     => l_enp_rec.ws_upd_strt_dt,
                    p_information266     => l_enp_rec.wthn_yr_perd_id,
                    p_information240     => l_enp_rec.yr_perd_id,
                    p_information22      => l_enp_rec.enrt_perd_det_ovrlp_bckdt_cd,
                    p_information166     => l_pos_structure_start_date,
                    p_information265     => l_enp_rec.object_version_number,
		    --Added two cols reinstate_cd,reinstate_ovrdn_cd
		    p_information26		=> l_enp_rec.reinstate_cd,
		    p_information27		=> l_enp_rec.reinstate_ovrdn_cd,
		    --
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_enp_result_id is null then
                      l_out_enp_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                      l_out_enp_result_id := l_copy_entity_result_id ;
                    end if;

              if (l_enp_rec.ler_id is not null) then
                   ben_plan_design_plan_module.create_ler_result (
                       p_validate                       => p_validate
                      ,p_copy_entity_result_id          => l_copy_entity_result_id
                      ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                      ,p_ler_id                         => l_enp_rec.ler_id
                      ,p_business_group_id              => l_enp_rec.business_group_id
                      ,p_number_of_copies               => l_number_of_copies
                      ,p_object_version_number          => l_object_version_number
                      ,p_effective_date                 => p_effective_date
                      );
              end if;
              --
	      if (l_enp_rec.enrt_cvg_strt_dt_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  => l_enp_rec.enrt_cvg_strt_dt_rl
			,p_business_group_id        => l_enp_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
	      end if;
              --
	      if (l_enp_rec.hrchy_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  => l_enp_rec.hrchy_rl
			,p_business_group_id        => l_enp_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
	      end if;

              if (l_enp_rec.enrt_cvg_end_dt_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  =>  l_enp_rec.enrt_cvg_end_dt_rl
			,p_business_group_id        =>  l_enp_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
              end if;

              if (l_enp_rec.rt_end_dt_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  => l_enp_rec.rt_end_dt_rl
			,p_business_group_id        => l_enp_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
              end if;

              if (l_enp_rec.rt_strt_dt_rl is not null) then
		   ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  =>  l_enp_rec.rt_strt_dt_rl
			,p_business_group_id        =>  l_enp_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
	      end if;

             --
             end loop;
           --
             ---------------------------------------------------------------
             -- START OF BEN_YR_PERD ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_yrp1_from_parent(l_ENRT_PERD_ID) loop
              --
                create_yr_perd_result
                (p_validate                       => p_validate
                ,p_copy_entity_result_id          => l_out_enp_result_id
                ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                ,p_yr_perd_id                     => l_parent_rec.yr_perd_id
                ,p_business_group_id              => p_business_group_id
                ,p_number_of_copies               => p_number_of_copies
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => p_effective_date
                ,p_parent_entity_result_id        => l_out_enp_result_id
                );
              end loop;
              --
             ---------------------------------------------------------------
             -- END OF BEN_YR_PERD ----------------------
             ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ENRT_PERD_FOR_PL_F ----------------------
            ---------------------------------------------------------------
             --
             for l_parent_rec  in c_erp_from_parent(l_ENRT_PERD_ID, p_pgm_id) loop
             --
               l_mirror_src_entity_result_id := l_out_enp_result_id ;

               l_enrt_perd_for_pl_id := l_parent_rec.enrt_perd_for_pl_id ;
               --
               for l_erp_rec in c_erp(l_parent_rec.enrt_perd_for_pl_id,l_mirror_src_entity_result_id,'ERP') loop
               --
               --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ERP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pl_name(l_erp_rec.pl_id,p_effective_date);--'Intersection'
                   --
                   if p_effective_date between l_erp_rec.effective_start_date
                       and l_erp_rec.effective_end_date then
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
                        p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                        p_number_of_copies               => l_number_of_copies,
                        p_table_alias					  => 'ERP',
                        p_table_route_id                 => l_table_route_id,
                        p_information1     => l_erp_rec.enrt_perd_for_pl_id,
                        p_information2     => l_erp_rec.EFFECTIVE_START_DATE,
                        p_information3     => l_erp_rec.EFFECTIVE_END_DATE,
                        p_information4     => l_erp_rec.business_group_id,
                        p_information5     => l_information5 , -- 9999 put name for h-grid
                        p_information12     => l_erp_rec.enrt_cvg_end_dt_cd,
                        p_information262     => l_erp_rec.enrt_cvg_end_dt_rl,
                        p_information11     => l_erp_rec.enrt_cvg_strt_dt_cd,
                        p_information260     => l_erp_rec.enrt_cvg_strt_dt_rl,
                        p_information244     => l_erp_rec.enrt_perd_id,
                        p_information111     => l_erp_rec.erp_attribute1,
                        p_information120     => l_erp_rec.erp_attribute10,
                        p_information121     => l_erp_rec.erp_attribute11,
                        p_information122     => l_erp_rec.erp_attribute12,
                        p_information123     => l_erp_rec.erp_attribute13,
                        p_information124     => l_erp_rec.erp_attribute14,
                        p_information125     => l_erp_rec.erp_attribute15,
                        p_information126     => l_erp_rec.erp_attribute16,
                        p_information127     => l_erp_rec.erp_attribute17,
                        p_information128     => l_erp_rec.erp_attribute18,
                        p_information129     => l_erp_rec.erp_attribute19,
                        p_information112     => l_erp_rec.erp_attribute2,
                        p_information130     => l_erp_rec.erp_attribute20,
                        p_information131     => l_erp_rec.erp_attribute21,
                        p_information132     => l_erp_rec.erp_attribute22,
                        p_information133     => l_erp_rec.erp_attribute23,
                        p_information134     => l_erp_rec.erp_attribute24,
                        p_information135     => l_erp_rec.erp_attribute25,
                        p_information136     => l_erp_rec.erp_attribute26,
                        p_information137     => l_erp_rec.erp_attribute27,
                        p_information138     => l_erp_rec.erp_attribute28,
                        p_information139     => l_erp_rec.erp_attribute29,
                        p_information113     => l_erp_rec.erp_attribute3,
                        p_information140     => l_erp_rec.erp_attribute30,
                        p_information114     => l_erp_rec.erp_attribute4,
                        p_information115     => l_erp_rec.erp_attribute5,
                        p_information116     => l_erp_rec.erp_attribute6,
                        p_information117     => l_erp_rec.erp_attribute7,
                        p_information118     => l_erp_rec.erp_attribute8,
                        p_information119     => l_erp_rec.erp_attribute9,
                        p_information110     => l_erp_rec.erp_attribute_category,
                        p_information234     => l_erp_rec.lee_rsn_id,
                        p_information261     => l_erp_rec.pl_id,
                        p_information14     => l_erp_rec.rt_end_dt_cd,
                        p_information264     => l_erp_rec.rt_end_dt_rl,
                        p_information13     => l_erp_rec.rt_strt_dt_cd,
                        p_information263     => l_erp_rec.rt_strt_dt_rl,
                        p_information265     => l_erp_rec.object_version_number,
                        p_object_version_number          => l_object_version_number,
                        p_effective_date                 => p_effective_date       );
                 --

                        if l_out_erp_result_id is null then
                          l_out_erp_result_id := l_copy_entity_result_id;
                        end if;

                        if l_result_type_cd = 'DISPLAY' then
                          l_out_erp_result_id := l_copy_entity_result_id ;
                        end if;

                      if (l_erp_rec.enrt_cvg_strt_dt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  =>  l_erp_rec.enrt_cvg_strt_dt_rl
								,p_business_group_id        => l_erp_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_erp_rec.enrt_cvg_end_dt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_erp_rec.enrt_cvg_end_dt_rl
								,p_business_group_id        => l_erp_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_erp_rec.rt_end_dt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_erp_rec.rt_end_dt_rl
								,p_business_group_id        => l_erp_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                      if (l_erp_rec.rt_strt_dt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_erp_rec.rt_strt_dt_rl
								,p_business_group_id        => l_erp_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                 --
                 end loop;
               --
               end loop;
            ---------------------------------------------------------------
            -- END OF BEN_ENRT_PERD_FOR_PL_F ----------------------
            ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_SCHEDD_ENRT_RL_F ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ser_from_parent(l_ENRT_PERD_ID) loop
              --
                l_mirror_src_entity_result_id := l_out_enp_result_id ;

                l_schedd_enrt_rl_id := l_parent_rec.schedd_enrt_rl_id ;
                --
                for l_ser_rec in c_ser(l_parent_rec.schedd_enrt_rl_id,l_mirror_src_entity_result_id,'SER') loop
                --
                --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('SER');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := ben_plan_design_program_module.get_formula_name(l_ser_rec.formula_id,p_effective_date); --'Intersection';
                    --
                    if p_effective_date between l_ser_rec.effective_start_date
                        and l_ser_rec.effective_end_date then
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
                         p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                         p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                         p_number_of_copies               => l_number_of_copies,
                         p_table_alias					  => 'SER',
                         p_table_route_id                 => l_table_route_id,
                         p_information1     => l_ser_rec.schedd_enrt_rl_id,
                         p_information2     => l_ser_rec.EFFECTIVE_START_DATE,
                         p_information3     => l_ser_rec.EFFECTIVE_END_DATE,
                         p_information4     => l_ser_rec.business_group_id,
                         p_information5     => l_information5 , -- 9999 put name for h-grid
                         p_information244     => l_ser_rec.enrt_perd_id,
                         p_information251     => l_ser_rec.formula_id,
                         p_information260     => l_ser_rec.ordr_to_aply_num,
                         p_information111     => l_ser_rec.ser_attribute1,
                         p_information120     => l_ser_rec.ser_attribute10,
                         p_information121     => l_ser_rec.ser_attribute11,
                         p_information122     => l_ser_rec.ser_attribute12,
                         p_information123     => l_ser_rec.ser_attribute13,
                         p_information124     => l_ser_rec.ser_attribute14,
                         p_information125     => l_ser_rec.ser_attribute15,
                         p_information126     => l_ser_rec.ser_attribute16,
                         p_information127     => l_ser_rec.ser_attribute17,
                         p_information128     => l_ser_rec.ser_attribute18,
                         p_information129     => l_ser_rec.ser_attribute19,
                         p_information112     => l_ser_rec.ser_attribute2,
                         p_information130     => l_ser_rec.ser_attribute20,
                         p_information131     => l_ser_rec.ser_attribute21,
                         p_information132     => l_ser_rec.ser_attribute22,
                         p_information133     => l_ser_rec.ser_attribute23,
                         p_information134     => l_ser_rec.ser_attribute24,
                         p_information135     => l_ser_rec.ser_attribute25,
                         p_information136     => l_ser_rec.ser_attribute26,
                         p_information137     => l_ser_rec.ser_attribute27,
                         p_information138     => l_ser_rec.ser_attribute28,
                         p_information139     => l_ser_rec.ser_attribute29,
                         p_information113     => l_ser_rec.ser_attribute3,
                         p_information140     => l_ser_rec.ser_attribute30,
                         p_information114     => l_ser_rec.ser_attribute4,
                         p_information115     => l_ser_rec.ser_attribute5,
                         p_information116     => l_ser_rec.ser_attribute6,
                         p_information117     => l_ser_rec.ser_attribute7,
                         p_information118     => l_ser_rec.ser_attribute8,
                         p_information119     => l_ser_rec.ser_attribute9,
                         p_information110     => l_ser_rec.ser_attribute_category,
                         p_information265     => l_ser_rec.object_version_number,
                         p_object_version_number          => l_object_version_number,
                         p_effective_date                 => p_effective_date       );
                  --

                         if l_out_ser_result_id is null then
                          l_out_ser_result_id := l_copy_entity_result_id;
                        end if;

                        if l_result_type_cd = 'DISPLAY' then
                          l_out_ser_result_id := l_copy_entity_result_id ;
                        end if;

                      if (l_ser_rec.formula_id is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_ser_rec.formula_id
								,p_business_group_id        => l_ser_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                  --
                  end loop;
                --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_SCHEDD_ENRT_RL_F ----------------------
             ---------------------------------------------------------------
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_ENRT_PERD ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_LEE_RSN_F ----------------------
         ---------------------------------------------------------------
          --
          for l_parent_rec  in c_len_from_parent(l_POPL_ENRT_TYP_CYCL_ID) loop
          --
            l_mirror_src_entity_result_id := l_out_pet_result_id ;

            l_lee_rsn_id := l_parent_rec.lee_rsn_id ;
            --
            for l_len_rec in c_len(l_parent_rec.lee_rsn_id,l_mirror_src_entity_result_id,'LEN') loop
            --
            --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('LEN');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := ben_plan_design_program_module.get_ler_name(l_len_rec.ler_id,p_effective_date); --'Intersection';
                --
                if p_effective_date between l_len_rec.effective_start_date
                    and l_len_rec.effective_end_date then
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
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_alias					  => 'LEN',
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_len_rec.lee_rsn_id,
                     p_information2     => l_len_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_len_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_len_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information260     => l_len_rec.addl_procg_dys_num,
                     p_information11     => l_len_rec.cls_enrt_dt_to_use_cd,
                     p_information258     => l_len_rec.dys_aftr_end_to_dflt_num,
                     p_information262     => l_len_rec.dys_no_enrl_cant_enrl_num,
                     p_information261     => l_len_rec.dys_no_enrl_not_elig_num,
                     p_information12     => l_len_rec.enrt_cvg_end_dt_cd,
                     p_information266     => l_len_rec.enrt_cvg_end_dt_rl,
                     p_information13     => l_len_rec.enrt_cvg_strt_dt_cd,
                     p_information267     => l_len_rec.enrt_cvg_strt_dt_rl,
                     p_information15     => l_len_rec.enrt_perd_end_dt_cd,
                     p_information268     => l_len_rec.enrt_perd_end_dt_rl,
                     p_information14     => l_len_rec.enrt_perd_strt_dt_cd,
                     p_information259     => l_len_rec.enrt_perd_strt_dt_rl,
                     p_information111     => l_len_rec.len_attribute1,
                     p_information120     => l_len_rec.len_attribute10,
                     p_information121     => l_len_rec.len_attribute11,
                     p_information122     => l_len_rec.len_attribute12,
                     p_information123     => l_len_rec.len_attribute13,
                     p_information124     => l_len_rec.len_attribute14,
                     p_information125     => l_len_rec.len_attribute15,
                     p_information126     => l_len_rec.len_attribute16,
                     p_information127     => l_len_rec.len_attribute17,
                     p_information128     => l_len_rec.len_attribute18,
                     p_information129     => l_len_rec.len_attribute19,
                     p_information112     => l_len_rec.len_attribute2,
                     p_information130     => l_len_rec.len_attribute20,
                     p_information131     => l_len_rec.len_attribute21,
                     p_information132     => l_len_rec.len_attribute22,
                     p_information133     => l_len_rec.len_attribute23,
                     p_information134     => l_len_rec.len_attribute24,
                     p_information135     => l_len_rec.len_attribute25,
                     p_information136     => l_len_rec.len_attribute26,
                     p_information137     => l_len_rec.len_attribute27,
                     p_information138     => l_len_rec.len_attribute28,
                     p_information139     => l_len_rec.len_attribute29,
                     p_information113     => l_len_rec.len_attribute3,
                     p_information140     => l_len_rec.len_attribute30,
                     p_information114     => l_len_rec.len_attribute4,
                     p_information115     => l_len_rec.len_attribute5,
                     p_information116     => l_len_rec.len_attribute6,
                     p_information117     => l_len_rec.len_attribute7,
                     p_information118     => l_len_rec.len_attribute8,
                     p_information119     => l_len_rec.len_attribute9,
                     p_information110     => l_len_rec.len_attribute_category,
                     p_information257     => l_len_rec.ler_id,
                     p_information232     => l_len_rec.popl_enrt_typ_cycl_id,
                     p_information16     => l_len_rec.rt_end_dt_cd,
                     p_information263     => l_len_rec.rt_end_dt_rl,
                     p_information17     => l_len_rec.rt_strt_dt_cd,
                     p_information264     => l_len_rec.rt_strt_dt_rl,
                     p_information18      => l_len_rec.enrt_perd_det_ovrlp_bckdt_cd,
                     p_information265     => l_len_rec.object_version_number,
		     --Two new cols added reinstate_cd, reinstate_ovrdn_cd
		     p_information19		=> l_len_rec.reinstate_cd,
     		     p_information20		=> l_len_rec.reinstate_ovrdn_cd,
		     p_information271		=> l_len_rec.ENRT_PERD_STRT_DAYS,
     		     p_information272		=> l_len_rec.ENRT_PERD_END_DAYS,
                     --
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                --

                if l_out_len_result_id is null then
                  l_out_len_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                  l_out_len_result_id := l_copy_entity_result_id ;
                end if;
				--

				 if (l_len_rec.enrt_cvg_end_dt_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_len_rec.enrt_cvg_end_dt_rl
						,p_business_group_id        => l_len_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

				 if (l_len_rec.enrt_cvg_strt_dt_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_len_rec.enrt_cvg_strt_dt_rl
						,p_business_group_id        => l_len_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

				 if (l_len_rec.enrt_perd_end_dt_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_len_rec.enrt_perd_end_dt_rl
						,p_business_group_id        => l_len_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

				 if (l_len_rec.enrt_perd_strt_dt_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_len_rec.enrt_perd_strt_dt_rl
						,p_business_group_id        => l_len_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;

				 if (l_len_rec.rt_end_dt_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_len_rec.rt_end_dt_rl
						,p_business_group_id        => l_len_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;
				 if (l_len_rec.rt_strt_dt_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
						p_validate                       => p_validate
						,p_copy_entity_result_id  => l_copy_entity_result_id
						,p_copy_entity_txn_id      => p_copy_entity_txn_id
						,p_formula_id                  => l_len_rec.rt_strt_dt_rl
						,p_business_group_id        => l_len_rec.business_group_id
						,p_number_of_copies         =>  l_number_of_copies
						,p_object_version_number  => l_object_version_number
						,p_effective_date             => p_effective_date);
				end if;



                --
              end loop;
            --
              for l_len_rec in c_len_drp(l_parent_rec.lee_rsn_id,l_mirror_src_entity_result_id,'LEN') loop
                   create_ler_result (
                      p_validate                       => p_validate
                     ,p_copy_entity_result_id          => l_out_len_result_id
                     ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                     ,p_ler_id                         => l_len_rec.ler_id
                     ,p_business_group_id              => p_business_group_id
                     ,p_number_of_copies               => p_number_of_copies
                     ,p_object_version_number          => l_object_version_number
                     ,p_effective_date                 => p_effective_date
                     );
              end loop;
             ---------------------------------------------------------------
             -- START OF BEN_ENRT_PERD_FOR_PL_F ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_erp1_from_parent(l_LEE_RSN_ID, p_pgm_id) loop
              --
                l_mirror_src_entity_result_id := l_out_len_result_id ;

                l_enrt_perd_for_pl_id1 := l_parent_rec.enrt_perd_for_pl_id ;
                --
                for l_erp_rec in c_erp1(l_parent_rec.enrt_perd_for_pl_id,l_mirror_src_entity_result_id,'ERP') loop
                --
                --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('ERP');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := ben_plan_design_program_module.get_pl_name(l_erp_rec.pl_id,p_effective_date);--'Intersection';
                    --
                    if p_effective_date between l_erp_rec.effective_start_date
                        and l_erp_rec.effective_end_date then
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
                         p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                         p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                         p_number_of_copies               => l_number_of_copies,
                         p_table_alias					  => 'ERP',
                         p_table_route_id                 => l_table_route_id,
                         p_information1     => l_erp_rec.enrt_perd_for_pl_id,
                         p_information2     => l_erp_rec.EFFECTIVE_START_DATE,
                         p_information3     => l_erp_rec.EFFECTIVE_END_DATE,
                         p_information4     => l_erp_rec.business_group_id,
                         p_information5     => l_information5 , -- 9999 put name for h-grid
                         p_information12     => l_erp_rec.enrt_cvg_end_dt_cd,
                         p_information262     => l_erp_rec.enrt_cvg_end_dt_rl,
                         p_information11     => l_erp_rec.enrt_cvg_strt_dt_cd,
                         p_information260     => l_erp_rec.enrt_cvg_strt_dt_rl,
                         p_information244     => l_erp_rec.enrt_perd_id,
                         p_information111     => l_erp_rec.erp_attribute1,
                         p_information120     => l_erp_rec.erp_attribute10,
                         p_information121     => l_erp_rec.erp_attribute11,
                         p_information122     => l_erp_rec.erp_attribute12,
                         p_information123     => l_erp_rec.erp_attribute13,
                         p_information124     => l_erp_rec.erp_attribute14,
                         p_information125     => l_erp_rec.erp_attribute15,
                         p_information126     => l_erp_rec.erp_attribute16,
                         p_information127     => l_erp_rec.erp_attribute17,
                         p_information128     => l_erp_rec.erp_attribute18,
                         p_information129     => l_erp_rec.erp_attribute19,
                         p_information112     => l_erp_rec.erp_attribute2,
                         p_information130     => l_erp_rec.erp_attribute20,
                         p_information131     => l_erp_rec.erp_attribute21,
                         p_information132     => l_erp_rec.erp_attribute22,
                         p_information133     => l_erp_rec.erp_attribute23,
                         p_information134     => l_erp_rec.erp_attribute24,
                         p_information135     => l_erp_rec.erp_attribute25,
                         p_information136     => l_erp_rec.erp_attribute26,
                         p_information137     => l_erp_rec.erp_attribute27,
                         p_information138     => l_erp_rec.erp_attribute28,
                         p_information139     => l_erp_rec.erp_attribute29,
                         p_information113     => l_erp_rec.erp_attribute3,
                         p_information140     => l_erp_rec.erp_attribute30,
                         p_information114     => l_erp_rec.erp_attribute4,
                         p_information115     => l_erp_rec.erp_attribute5,
                         p_information116     => l_erp_rec.erp_attribute6,
                         p_information117     => l_erp_rec.erp_attribute7,
                         p_information118     => l_erp_rec.erp_attribute8,
                         p_information119     => l_erp_rec.erp_attribute9,
                         p_information110     => l_erp_rec.erp_attribute_category,
                         p_information234     => l_erp_rec.lee_rsn_id,
                         p_information261     => l_erp_rec.pl_id,
                         p_information14     => l_erp_rec.rt_end_dt_cd,
                         p_information264     => l_erp_rec.rt_end_dt_rl,
                         p_information13     => l_erp_rec.rt_strt_dt_cd,
                         p_information263     => l_erp_rec.rt_strt_dt_rl,
                         p_information265     => l_erp_rec.object_version_number,
                         p_object_version_number          => l_object_version_number,
                         p_effective_date                 => p_effective_date       );
                  --

                         if l_out_erp1_result_id is null then
                           l_out_erp1_result_id := l_copy_entity_result_id;
                         end if;

                         if l_result_type_cd = 'DISPLAY' then
                           l_out_erp1_result_id := l_copy_entity_result_id ;
                         end if;

                  end loop;
                --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ENRT_PERD_FOR_PL_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_LEE_RSN_RL_F ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_lrr_from_parent(l_LEE_RSN_ID) loop
              --
                l_mirror_src_entity_result_id := l_out_len_result_id ;

                l_lee_rsn_rl_id := l_parent_rec.lee_rsn_rl_id ;
                --
                for l_lrr_rec in c_lrr(l_parent_rec.lee_rsn_rl_id,l_mirror_src_entity_result_id,'LRR') loop
                --
                --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('LRR');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := ben_plan_design_program_module.get_formula_name(l_lrr_rec.formula_id,p_effective_date);
                                      --'Intersection';
                    --
                    if p_effective_date between l_lrr_rec.effective_start_date
                        and l_lrr_rec.effective_end_date then
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
                         p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                         p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                         p_number_of_copies               => l_number_of_copies,
                         p_table_alias					  => 'LRR',
                         p_table_route_id                 => l_table_route_id,
                         p_information1     => l_lrr_rec.lee_rsn_rl_id,
                         p_information2     => l_lrr_rec.EFFECTIVE_START_DATE,
                         p_information3     => l_lrr_rec.EFFECTIVE_END_DATE,
                         p_information4     => l_lrr_rec.business_group_id,
                         p_information5     => l_information5 , -- 9999 put name for h-grid
                         p_information251     => l_lrr_rec.formula_id,
                         p_information234     => l_lrr_rec.lee_rsn_id,
                         p_information111     => l_lrr_rec.lrr_attribute1,
                         p_information120     => l_lrr_rec.lrr_attribute10,
                         p_information121     => l_lrr_rec.lrr_attribute11,
                         p_information122     => l_lrr_rec.lrr_attribute12,
                         p_information123     => l_lrr_rec.lrr_attribute13,
                         p_information124     => l_lrr_rec.lrr_attribute14,
                         p_information125     => l_lrr_rec.lrr_attribute15,
                         p_information126     => l_lrr_rec.lrr_attribute16,
                         p_information127     => l_lrr_rec.lrr_attribute17,
                         p_information128     => l_lrr_rec.lrr_attribute18,
                         p_information129     => l_lrr_rec.lrr_attribute19,
                         p_information112     => l_lrr_rec.lrr_attribute2,
                         p_information130     => l_lrr_rec.lrr_attribute20,
                         p_information131     => l_lrr_rec.lrr_attribute21,
                         p_information132     => l_lrr_rec.lrr_attribute22,
                         p_information133     => l_lrr_rec.lrr_attribute23,
                         p_information134     => l_lrr_rec.lrr_attribute24,
                         p_information135     => l_lrr_rec.lrr_attribute25,
                         p_information136     => l_lrr_rec.lrr_attribute26,
                         p_information137     => l_lrr_rec.lrr_attribute27,
                         p_information138     => l_lrr_rec.lrr_attribute28,
                         p_information139     => l_lrr_rec.lrr_attribute29,
                         p_information113     => l_lrr_rec.lrr_attribute3,
                         p_information140     => l_lrr_rec.lrr_attribute30,
                         p_information114     => l_lrr_rec.lrr_attribute4,
                         p_information115     => l_lrr_rec.lrr_attribute5,
                         p_information116     => l_lrr_rec.lrr_attribute6,
                         p_information117     => l_lrr_rec.lrr_attribute7,
                         p_information118     => l_lrr_rec.lrr_attribute8,
                         p_information119     => l_lrr_rec.lrr_attribute9,
                         p_information110     => l_lrr_rec.lrr_attribute_category,
                         p_information260     => l_lrr_rec.ordr_to_aply_num,
                         p_information265     => l_lrr_rec.object_version_number,
                         p_object_version_number          => l_object_version_number,
                         p_effective_date                 => p_effective_date       );
                  --

                      if l_out_lrr_result_id is null then
                        l_out_lrr_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_lrr_result_id := l_copy_entity_result_id ;
                      end if;

                      if (l_lrr_rec.formula_id is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_lrr_rec.formula_id
								,p_business_group_id        => l_lrr_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                  --
                  end loop;
                --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_LEE_RSN_RL_F ----------------------
             ---------------------------------------------------------------
            end loop;
         ---------------------------------------------------------------
         -- END OF BEN_LEE_RSN_F ----------------------
         ---------------------------------------------------------------
        --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_POPL_ENRT_TYP_CYCL_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_POPL_ORG_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_cpo_from_parent(p_pl_id,p_pgm_id) loop
      --
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        l_parent_entity_result_id := p_parent_entity_result_id ;
        l_popl_org_id := l_parent_rec.popl_org_id ;

        for l_cpo_rec in c_cpo(l_parent_rec.popl_org_id,l_mirror_src_entity_result_id,'CPO') loop
        --
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('CPO');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_organization_name(l_cpo_rec.organization_id);--'Intersection'
            --
            --
            if p_effective_date between l_cpo_rec.effective_start_date
                and l_cpo_rec.effective_end_date then
                --
                l_result_type_cd := 'DISPLAY';
            else
                l_result_type_cd := 'NO DISPLAY';
            end if;

            -- To store effective_start_date of organization
            -- for Mapping - Bug 2958658
            --
            l_organization_start_date := null;
            if l_cpo_rec.organization_id is not null then
              open c_organization_start_date(l_cpo_rec.organization_id);
              fetch c_organization_start_date into l_organization_start_date;
              close c_organization_start_date;
            end if;

            --
            -- pabodla : MAPPING DATA : Store the mapping column information.
            --

            l_mapping_name := null;
            l_mapping_id   := null;
            --
            -- Get the organization name to display on mapping page.
            --
            open c_get_mapping_name2(l_cpo_rec.organization_id,
                                     NVL(l_organization_start_date,p_effective_date));
            fetch c_get_mapping_name2 into l_mapping_name;
            close c_get_mapping_name2;
            --
            l_mapping_id   := l_cpo_rec.organization_id;
            --
            hr_utility.set_location('l_mapping_id/organization_id '||l_mapping_id,100);
            hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
            --
            --To set user friendly labels on the mapping page
            --
            l_mapping_column_name1 := null;
            l_mapping_column_name2 :=null;
            BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                       l_mapping_column_name1,
                                       l_mapping_column_name2,
                                       p_copy_entity_txn_id);
            --

            l_copy_entity_result_id := null;
            l_object_version_number := null;
            ben_copy_entity_results_api.create_copy_entity_results(
                 p_copy_entity_result_id           => l_copy_entity_result_id,
                 p_copy_entity_txn_id             => p_copy_entity_txn_id,
                 p_result_type_cd                 => l_result_type_cd,
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					  => 'CPO',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_cpo_rec.popl_org_id,
                 p_information2     => l_cpo_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_cpo_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_cpo_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information111     => l_cpo_rec.cpo_attribute1,
                 p_information120     => l_cpo_rec.cpo_attribute10,
                 p_information121     => l_cpo_rec.cpo_attribute11,
                 p_information122     => l_cpo_rec.cpo_attribute12,
                 p_information123     => l_cpo_rec.cpo_attribute13,
                 p_information124     => l_cpo_rec.cpo_attribute14,
                 p_information125     => l_cpo_rec.cpo_attribute15,
                 p_information126     => l_cpo_rec.cpo_attribute16,
                 p_information127     => l_cpo_rec.cpo_attribute17,
                 p_information128     => l_cpo_rec.cpo_attribute18,
                 p_information129     => l_cpo_rec.cpo_attribute19,
                 p_information112     => l_cpo_rec.cpo_attribute2,
                 p_information130     => l_cpo_rec.cpo_attribute20,
                 p_information131     => l_cpo_rec.cpo_attribute21,
                 p_information132     => l_cpo_rec.cpo_attribute22,
                 p_information133     => l_cpo_rec.cpo_attribute23,
                 p_information134     => l_cpo_rec.cpo_attribute24,
                 p_information135     => l_cpo_rec.cpo_attribute25,
                 p_information136     => l_cpo_rec.cpo_attribute26,
                 p_information137     => l_cpo_rec.cpo_attribute27,
                 p_information138     => l_cpo_rec.cpo_attribute28,
                 p_information139     => l_cpo_rec.cpo_attribute29,
                 p_information113     => l_cpo_rec.cpo_attribute3,
                 p_information140     => l_cpo_rec.cpo_attribute30,
                 p_information114     => l_cpo_rec.cpo_attribute4,
                 p_information115     => l_cpo_rec.cpo_attribute5,
                 p_information116     => l_cpo_rec.cpo_attribute6,
                 p_information117     => l_cpo_rec.cpo_attribute7,
                 p_information118     => l_cpo_rec.cpo_attribute8,
                 p_information119     => l_cpo_rec.cpo_attribute9,
                 p_information110     => l_cpo_rec.cpo_attribute_category,
                 p_information257     => l_cpo_rec.cstmr_num,
                 p_information252     => l_cpo_rec.organization_id,
                 -- Data for MAPPING columns.
                 p_information173    => l_mapping_name,
                 p_information174    => l_mapping_id,
                 p_information181    => l_mapping_column_name1,
                 p_information182    => l_mapping_column_name2,
                 -- END other product Mapping columns.
                 p_information258     => l_cpo_rec.person_id,
                 p_information260     => l_cpo_rec.pgm_id,
                 p_information261     => l_cpo_rec.pl_id,
                 p_information141     => l_cpo_rec.plcy_r_grp,
                 p_information166     => l_organization_start_date,
                 p_information265     => l_cpo_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                 if l_out_cpo_result_id is null then
                  l_out_cpo_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                  l_out_cpo_result_id := l_copy_entity_result_id ;
                end if;

          end loop;
        --
          ---------------------------------------------------------------
          -- START OF BEN_POPL_ORG_ROLE_F ----------------------
          ---------------------------------------------------------------
           --
           for l_parent_rec  in c_cpr_from_parent(l_POPL_ORG_ID) loop
           --
             l_mirror_src_entity_result_id := l_out_cpo_result_id ;

             l_popl_org_role_id := l_parent_rec.popl_org_role_id ;
             --
             for l_cpr_rec in c_cpr(l_parent_rec.popl_org_role_id,l_mirror_src_entity_result_id,'CPR') loop
             --
             --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('CPR');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := l_cpr_rec.name; --'Intersection';
                 --
                 if p_effective_date between l_cpr_rec.effective_start_date
                     and l_cpr_rec.effective_end_date then
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
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					  => 'CPR',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_cpr_rec.popl_org_role_id,
                      p_information2     => l_cpr_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_cpr_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_cpr_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information111     => l_cpr_rec.cpr_attribute1,
                      p_information120     => l_cpr_rec.cpr_attribute10,
                      p_information121     => l_cpr_rec.cpr_attribute11,
                      p_information122     => l_cpr_rec.cpr_attribute12,
                      p_information123     => l_cpr_rec.cpr_attribute13,
                      p_information124     => l_cpr_rec.cpr_attribute14,
                      p_information125     => l_cpr_rec.cpr_attribute15,
                      p_information126     => l_cpr_rec.cpr_attribute16,
                      p_information127     => l_cpr_rec.cpr_attribute17,
                      p_information128     => l_cpr_rec.cpr_attribute18,
                      p_information129     => l_cpr_rec.cpr_attribute19,
                      p_information112     => l_cpr_rec.cpr_attribute2,
                      p_information130     => l_cpr_rec.cpr_attribute20,
                      p_information131     => l_cpr_rec.cpr_attribute21,
                      p_information132     => l_cpr_rec.cpr_attribute22,
                      p_information133     => l_cpr_rec.cpr_attribute23,
                      p_information134     => l_cpr_rec.cpr_attribute24,
                      p_information135     => l_cpr_rec.cpr_attribute25,
                      p_information136     => l_cpr_rec.cpr_attribute26,
                      p_information137     => l_cpr_rec.cpr_attribute27,
                      p_information138     => l_cpr_rec.cpr_attribute28,
                      p_information139     => l_cpr_rec.cpr_attribute29,
                      p_information113     => l_cpr_rec.cpr_attribute3,
                      p_information140     => l_cpr_rec.cpr_attribute30,
                      p_information114     => l_cpr_rec.cpr_attribute4,
                      p_information115     => l_cpr_rec.cpr_attribute5,
                      p_information116     => l_cpr_rec.cpr_attribute6,
                      p_information117     => l_cpr_rec.cpr_attribute7,
                      p_information118     => l_cpr_rec.cpr_attribute8,
                      p_information119     => l_cpr_rec.cpr_attribute9,
                      p_information110     => l_cpr_rec.cpr_attribute_category,
                      p_information170     => l_cpr_rec.name,
                      p_information11     => l_cpr_rec.org_role_typ_cd,
                      p_information260     => l_cpr_rec.popl_org_id,
                      p_information265     => l_cpr_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
               --

                      if l_out_cpr_result_id is null then
                        l_out_cpr_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_cpr_result_id := l_copy_entity_result_id ;
                      end if;
               end loop;
             --
             end loop;
          ---------------------------------------------------------------
          -- END OF BEN_POPL_ORG_ROLE_F ----------------------
          ---------------------------------------------------------------
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_POPL_ORG_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_POPL_YR_PERD ----------------------
     ---------------------------------------------------------------
      --
      for l_parent_rec  in c_cpy_from_parent(p_pl_id,p_pgm_id) loop
      --
      --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        l_parent_entity_result_id := p_parent_entity_result_id ;
        l_popl_yr_perd_id  := l_parent_rec.popl_yr_perd_id ;

        for l_cpy_rec in c_cpy(l_parent_rec.popl_yr_perd_id,l_mirror_src_entity_result_id,'CPY') loop
        --
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('CPY');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_yr_perd_name(l_cpy_rec.yr_perd_id); --'Intersection'
            --
            l_result_type_cd := 'DISPLAY';
            --
            l_copy_entity_result_id := null;
            l_object_version_number := null;
            ben_copy_entity_results_api.create_copy_entity_results(
                 p_copy_entity_result_id           => l_copy_entity_result_id,
                 p_copy_entity_txn_id             => p_copy_entity_txn_id,
                 p_result_type_cd                 => l_result_type_cd,
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					  => 'CPY',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_cpy_rec.popl_yr_perd_id,
                 p_information2     => null,
                 p_information3     => null,
                 p_information4     => l_cpy_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information308     => l_cpy_rec.acpt_clm_rqsts_thru_dt,
                 p_information111     => l_cpy_rec.cpy_attribute1,
                 p_information120     => l_cpy_rec.cpy_attribute10,
                 p_information121     => l_cpy_rec.cpy_attribute11,
                 p_information122     => l_cpy_rec.cpy_attribute12,
                 p_information123     => l_cpy_rec.cpy_attribute13,
                 p_information124     => l_cpy_rec.cpy_attribute14,
                 p_information125     => l_cpy_rec.cpy_attribute15,
                 p_information126     => l_cpy_rec.cpy_attribute16,
                 p_information127     => l_cpy_rec.cpy_attribute17,
                 p_information128     => l_cpy_rec.cpy_attribute18,
                 p_information129     => l_cpy_rec.cpy_attribute19,
                 p_information112     => l_cpy_rec.cpy_attribute2,
                 p_information130     => l_cpy_rec.cpy_attribute20,
                 p_information131     => l_cpy_rec.cpy_attribute21,
                 p_information132     => l_cpy_rec.cpy_attribute22,
                 p_information133     => l_cpy_rec.cpy_attribute23,
                 p_information134     => l_cpy_rec.cpy_attribute24,
                 p_information135     => l_cpy_rec.cpy_attribute25,
                 p_information136     => l_cpy_rec.cpy_attribute26,
                 p_information137     => l_cpy_rec.cpy_attribute27,
                 p_information138     => l_cpy_rec.cpy_attribute28,
                 p_information139     => l_cpy_rec.cpy_attribute29,
                 p_information113     => l_cpy_rec.cpy_attribute3,
                 p_information140     => l_cpy_rec.cpy_attribute30,
                 p_information114     => l_cpy_rec.cpy_attribute4,
                 p_information115     => l_cpy_rec.cpy_attribute5,
                 p_information116     => l_cpy_rec.cpy_attribute6,
                 p_information117     => l_cpy_rec.cpy_attribute7,
                 p_information118     => l_cpy_rec.cpy_attribute8,
                 p_information119     => l_cpy_rec.cpy_attribute9,
                 p_information110     => l_cpy_rec.cpy_attribute_category,
                 p_information262     => l_cpy_rec.ordr_num,
                 p_information260     => l_cpy_rec.pgm_id,
                 p_information261     => l_cpy_rec.pl_id,
                 p_information309     => l_cpy_rec.py_clms_thru_dt,
                 p_information240     => l_cpy_rec.yr_perd_id,
                 p_information265     => l_cpy_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
            --

                 if l_out_cpy_result_id is null then
                  l_out_cpy_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                  l_out_cpy_result_id := l_copy_entity_result_id ;
                end if;

            end loop ;

         ---------------------------------------------------------------
         -- START OF BEN_YR_PERD ----------------------
         ---------------------------------------------------------------
          --
          --
          for l_parent_rec  in c_yrp_from_parent(l_POPL_YR_PERD_ID) loop
          --
            create_yr_perd_result
                (p_validate                       => p_validate
                ,p_copy_entity_result_id          => l_out_cpy_result_id
                ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                ,p_yr_perd_id                     => l_parent_rec.yr_perd_id
                ,p_business_group_id              => p_business_group_id
                ,p_number_of_copies               => p_number_of_copies
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => p_effective_date
                ,p_parent_entity_result_id        => l_out_cpy_result_id
                );
          end loop;
         ---------------------------------------------------------------
         -- END OF BEN_YR_PERD ----------------------
         ---------------------------------------------------------------
        --
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_POPL_YR_PERD ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_POPL_RPTG_GRP_F ----------------------
     ---------------------------------------------------------------
      --
      --
      for l_parent_rec  in c_rgr_from_parent(p_pl_id,p_pgm_id) loop
      --
      --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        l_parent_entity_result_id := p_parent_entity_result_id ;
        l_popl_rptg_grp_id          := l_parent_rec.popl_rptg_grp_id ;

        for l_rgr_rec in c_rgr(l_parent_rec.popl_rptg_grp_id,l_mirror_src_entity_result_id,'RGR') loop
        --
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('RGR');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5 := ben_plan_design_program_module.get_rptg_grp_name(l_rgr_rec.rptg_grp_id); --'Intersection';
            --
            if p_effective_date between l_rgr_rec.effective_start_date
                and l_rgr_rec.effective_end_date then
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
		     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					  => 'RGR',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_rgr_rec.popl_rptg_grp_id,
                 p_information2     => l_rgr_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_rgr_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_rgr_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information260     => l_rgr_rec.pgm_id,
                 p_information261     => l_rgr_rec.pl_id,
                 p_information111     => l_rgr_rec.rgr_attribute1,
                 p_information120     => l_rgr_rec.rgr_attribute10,
                 p_information121     => l_rgr_rec.rgr_attribute11,
                 p_information122     => l_rgr_rec.rgr_attribute12,
                 p_information123     => l_rgr_rec.rgr_attribute13,
                 p_information124     => l_rgr_rec.rgr_attribute14,
                 p_information125     => l_rgr_rec.rgr_attribute15,
                 p_information126     => l_rgr_rec.rgr_attribute16,
                 p_information127     => l_rgr_rec.rgr_attribute17,
                 p_information128     => l_rgr_rec.rgr_attribute18,
                 p_information129     => l_rgr_rec.rgr_attribute19,
                 p_information112     => l_rgr_rec.rgr_attribute2,
                 p_information130     => l_rgr_rec.rgr_attribute20,
                 p_information131     => l_rgr_rec.rgr_attribute21,
                 p_information132     => l_rgr_rec.rgr_attribute22,
                 p_information133     => l_rgr_rec.rgr_attribute23,
                 p_information134     => l_rgr_rec.rgr_attribute24,
                 p_information135     => l_rgr_rec.rgr_attribute25,
                 p_information136     => l_rgr_rec.rgr_attribute26,
                 p_information137     => l_rgr_rec.rgr_attribute27,
                 p_information138     => l_rgr_rec.rgr_attribute28,
                 p_information139     => l_rgr_rec.rgr_attribute29,
                 p_information113     => l_rgr_rec.rgr_attribute3,
                 p_information140     => l_rgr_rec.rgr_attribute30,
                 p_information114     => l_rgr_rec.rgr_attribute4,
                 p_information115     => l_rgr_rec.rgr_attribute5,
                 p_information116     => l_rgr_rec.rgr_attribute6,
                 p_information117     => l_rgr_rec.rgr_attribute7,
                 p_information118     => l_rgr_rec.rgr_attribute8,
                 p_information119     => l_rgr_rec.rgr_attribute9,
                 p_information110     => l_rgr_rec.rgr_attribute_category,
                 p_information242     => l_rgr_rec.rptg_grp_id,
                 p_information265     => l_rgr_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
          --

                  if l_out_rgr_result_id is null then
                    l_out_rgr_result_id := l_copy_entity_result_id;
                  end if;

                  if l_result_type_cd = 'DISPLAY' then
                    l_out_rgr_result_id := l_copy_entity_result_id ;
                  end if;
        end loop;
        --
        ---------------------------------------------------------------
        -- START OF BEN_RPTG_GRP ----------------------
        ---------------------------------------------------------------
         --
         for l_parent_rec  in c_bnr_from_parent(l_POPL_RPTG_GRP_ID) loop
         --
           l_mirror_src_entity_result_id := l_out_rgr_result_id ;

           l_rptg_grp_id := l_parent_rec.rptg_grp_id ;

           if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
             open c_object_exists(l_rptg_grp_id,'BNR');
             fetch c_object_exists into l_dummy;
             if c_object_exists%found then
               close c_object_exists;
               exit;
             end if;
             close c_object_exists;
           end if;

           --
           for l_bnr_rec in c_bnr(l_parent_rec.rptg_grp_id,l_mirror_src_entity_result_id,'BNR') loop
           --
           --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('BNR');
               fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
               --
               l_information5  := l_bnr_rec.name; --'Intersection';
               --
               l_result_type_cd := 'DISPLAY';
               --
               l_copy_entity_result_id := null;
               l_object_version_number := null;
               ben_copy_entity_results_api.create_copy_entity_results(
                    p_copy_entity_result_id           => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					  => 'BNR',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_bnr_rec.rptg_grp_id,
                    p_information2     => null,
                    p_information3     => null,
                    p_information4     => l_bnr_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information111     => l_bnr_rec.bnr_attribute1,
                    p_information120     => l_bnr_rec.bnr_attribute10,
                    p_information121     => l_bnr_rec.bnr_attribute11,
                    p_information122     => l_bnr_rec.bnr_attribute12,
                    p_information123     => l_bnr_rec.bnr_attribute13,
                    p_information124     => l_bnr_rec.bnr_attribute14,
                    p_information125     => l_bnr_rec.bnr_attribute15,
                    p_information126     => l_bnr_rec.bnr_attribute16,
                    p_information127     => l_bnr_rec.bnr_attribute17,
                    p_information128     => l_bnr_rec.bnr_attribute18,
                    p_information129     => l_bnr_rec.bnr_attribute19,
                    p_information112     => l_bnr_rec.bnr_attribute2,
                    p_information130     => l_bnr_rec.bnr_attribute20,
                    p_information131     => l_bnr_rec.bnr_attribute21,
                    p_information132     => l_bnr_rec.bnr_attribute22,
                    p_information133     => l_bnr_rec.bnr_attribute23,
                    p_information134     => l_bnr_rec.bnr_attribute24,
                    p_information135     => l_bnr_rec.bnr_attribute25,
                    p_information136     => l_bnr_rec.bnr_attribute26,
                    p_information137     => l_bnr_rec.bnr_attribute27,
                    p_information138     => l_bnr_rec.bnr_attribute28,
                    p_information139     => l_bnr_rec.bnr_attribute29,
                    p_information113     => l_bnr_rec.bnr_attribute3,
                    p_information140     => l_bnr_rec.bnr_attribute30,
                    p_information114     => l_bnr_rec.bnr_attribute4,
                    p_information115     => l_bnr_rec.bnr_attribute5,
                    p_information116     => l_bnr_rec.bnr_attribute6,
                    p_information117     => l_bnr_rec.bnr_attribute7,
                    p_information118     => l_bnr_rec.bnr_attribute8,
                    p_information119     => l_bnr_rec.bnr_attribute9,
                    p_information110     => l_bnr_rec.bnr_attribute_category,
                    p_information11     => l_bnr_rec.function_code,
                    p_information12     => l_bnr_rec.legislation_code,
                    p_information170     => l_bnr_rec.name,
                    p_information185     => l_bnr_rec.rpg_desc,
                    p_information13     => l_bnr_rec.rptg_prps_cd,
                    p_information265     => l_bnr_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
             --
                  if l_out_bnr_result_id is null then
                    l_out_bnr_result_id := l_copy_entity_result_id;
                  end if;

                  if l_result_type_cd = 'DISPLAY' then
                    l_out_bnr_result_id := l_copy_entity_result_id ;
                  end if;

             end loop;
           --
               ---------------------------------------------------------------
               -- START OF BEN_PL_REGN_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_prg_from_parent(l_RPTG_GRP_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_bnr_result_id ;
                  --
                  l_pl_regn_id := l_parent_rec.pl_regn_id ;

                  if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
                    open c_object_exists(l_pl_regn_id,'PRG');
                    fetch c_object_exists into l_dummy;
                    if c_object_exists%found then
                      close c_object_exists;
                      exit;
                    end if;
                    close c_object_exists;
                  end if;

                  --
                  for l_prg_rec in c_prg(l_parent_rec.pl_regn_id,l_mirror_src_entity_result_id,'PRG') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('PRG');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := ben_plan_design_program_module.get_regn_name(l_prg_rec.regn_id,
                                                              p_effective_date );
                    --
                    if p_effective_date between l_prg_rec.effective_start_date
                       and l_prg_rec.effective_end_date then
                     --
                       l_result_type_cd := 'DISPLAY';
                    else
                       l_result_type_cd := 'NO DISPLAY';
                    end if;

                    /* NOT REQUIRED AS create_REG_rows will handle this
                    --
                    --
                    -- Store the Regulation name in information185
                    -- Records for Regulations (BEN_REGN_F) will not created in the Target Business Group
                    -- The copy process will try and map the Regulation name to the ones existing in the
                    -- Target Business Group and if a match is found, then that Regulation Id will be used
                    -- for creating Plan Regulation (BEN_PL_REGN) records.

                    l_regn_name :=  ben_plan_design_program_module.get_regn_name(l_prg_rec.regn_id,l_prg_rec.effective_start_date);
                    --
                    */

                    l_copy_entity_result_id := null;
                    l_object_version_number := null;
                    ben_copy_entity_results_api.create_copy_entity_results(
                      p_copy_entity_result_id           => l_copy_entity_result_id,
                      p_copy_entity_txn_id             => p_copy_entity_txn_id,
                      p_result_type_cd                 => l_result_type_cd,
                      p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					  => 'PRG',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_prg_rec.pl_regn_id,
                      p_information2     => l_prg_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_prg_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_prg_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information259     => l_prg_rec.cntr_nndscrn_rl,
                      p_information260     => l_prg_rec.cvg_nndscrn_rl,
                      p_information262     => l_prg_rec.five_pct_ownr_rl,
                      p_information257     => l_prg_rec.hghly_compd_det_rl,
                      p_information258     => l_prg_rec.key_ee_det_rl,
                      p_information261     => l_prg_rec.pl_id,
                      p_information111     => l_prg_rec.prg_attribute1,
                      p_information120     => l_prg_rec.prg_attribute10,
                      p_information121     => l_prg_rec.prg_attribute11,
                      p_information122     => l_prg_rec.prg_attribute12,
                      p_information123     => l_prg_rec.prg_attribute13,
                      p_information124     => l_prg_rec.prg_attribute14,
                      p_information125     => l_prg_rec.prg_attribute15,
                      p_information126     => l_prg_rec.prg_attribute16,
                      p_information127     => l_prg_rec.prg_attribute17,
                      p_information128     => l_prg_rec.prg_attribute18,
                      p_information129     => l_prg_rec.prg_attribute19,
                      p_information112     => l_prg_rec.prg_attribute2,
                      p_information130     => l_prg_rec.prg_attribute20,
                      p_information131     => l_prg_rec.prg_attribute21,
                      p_information132     => l_prg_rec.prg_attribute22,
                      p_information133     => l_prg_rec.prg_attribute23,
                      p_information134     => l_prg_rec.prg_attribute24,
                      p_information135     => l_prg_rec.prg_attribute25,
                      p_information136     => l_prg_rec.prg_attribute26,
                      p_information137     => l_prg_rec.prg_attribute27,
                      p_information138     => l_prg_rec.prg_attribute28,
                      p_information139     => l_prg_rec.prg_attribute29,
                      p_information113     => l_prg_rec.prg_attribute3,
                      p_information140     => l_prg_rec.prg_attribute30,
                      p_information114     => l_prg_rec.prg_attribute4,
                      p_information115     => l_prg_rec.prg_attribute5,
                      p_information116     => l_prg_rec.prg_attribute6,
                      p_information117     => l_prg_rec.prg_attribute7,
                      p_information118     => l_prg_rec.prg_attribute8,
                      p_information119     => l_prg_rec.prg_attribute9,
                      p_information110     => l_prg_rec.prg_attribute_category,
                      p_information231     => l_prg_rec.regn_id,
                      p_information11     => l_prg_rec.regy_pl_typ_cd,
                      p_information242     => l_prg_rec.rptg_grp_id,
                      -- p_information185     => l_regn_name, -- NOT REQUIRED AS create_REG_rows will handle this

                      p_information265     => l_prg_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_prg_result_id is null then
                        l_out_prg_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_prg_result_id := l_copy_entity_result_id ;
                      end if;
                      --
                   end loop;
                   --
                   ---------------------------------------------------------------
                   -- START OF BEN_REGN_F ----------------------
                   ---------------------------------------------------------------
                   --
                   for l_parent_rec  in c_reg_from_parent(l_PL_REGN_ID) loop
                      --
                      l_mirror_src_entity_result_id := l_out_prg_result_id ;
                      --
                      l_regn_id := l_parent_rec.regn_id ;

                      if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
                        open c_object_exists(l_regn_id,'REG');
                        fetch c_object_exists into l_dummy;
                        if c_object_exists%found then
                          close c_object_exists;
                          exit;
                        end if;
                        close c_object_exists;
                      end if;
                      --
                      for l_reg_rec in c_reg(l_parent_rec.regn_id,l_mirror_src_entity_result_id,'REG') loop
                        --
                        l_table_route_id := null ;
                        open ben_plan_design_program_module.g_table_route('REG');
                          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                        close ben_plan_design_program_module.g_table_route ;
                        --
                        l_information5  := l_reg_rec.name ;
                        --
                        if p_effective_date between l_reg_rec.effective_start_date
                           and l_reg_rec.effective_end_date then
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
                          p_table_alias					  => 'REG',
                          p_table_route_id                 => l_table_route_id,
                          p_information1     => l_reg_rec.regn_id,
                          p_information2     => l_reg_rec.EFFECTIVE_START_DATE,
                          p_information3     => l_reg_rec.EFFECTIVE_END_DATE,
                          p_information4     => l_reg_rec.business_group_id,
                          p_information5     => l_information5 , -- 9999 put name for h-grid
                          p_information170     => l_reg_rec.name,
                          p_information252     => l_reg_rec.organization_id,
                          p_information111     => l_reg_rec.reg_attribute1,
                          p_information120     => l_reg_rec.reg_attribute10,
                          p_information121     => l_reg_rec.reg_attribute11,
                          p_information122     => l_reg_rec.reg_attribute12,
                          p_information123     => l_reg_rec.reg_attribute13,
                          p_information124     => l_reg_rec.reg_attribute14,
                          p_information125     => l_reg_rec.reg_attribute15,
                          p_information126     => l_reg_rec.reg_attribute16,
                          p_information127     => l_reg_rec.reg_attribute17,
                          p_information128     => l_reg_rec.reg_attribute18,
                          p_information129     => l_reg_rec.reg_attribute19,
                          p_information112     => l_reg_rec.reg_attribute2,
                          p_information130     => l_reg_rec.reg_attribute20,
                          p_information131     => l_reg_rec.reg_attribute21,
                          p_information132     => l_reg_rec.reg_attribute22,
                          p_information133     => l_reg_rec.reg_attribute23,
                          p_information134     => l_reg_rec.reg_attribute24,
                          p_information135     => l_reg_rec.reg_attribute25,
                          p_information136     => l_reg_rec.reg_attribute26,
                          p_information137     => l_reg_rec.reg_attribute27,
                          p_information138     => l_reg_rec.reg_attribute28,
                          p_information139     => l_reg_rec.reg_attribute29,
                          p_information113     => l_reg_rec.reg_attribute3,
                          p_information140     => l_reg_rec.reg_attribute30,
                          p_information114     => l_reg_rec.reg_attribute4,
                          p_information115     => l_reg_rec.reg_attribute5,
                          p_information116     => l_reg_rec.reg_attribute6,
                          p_information117     => l_reg_rec.reg_attribute7,
                          p_information118     => l_reg_rec.reg_attribute8,
                          p_information119     => l_reg_rec.reg_attribute9,
                          p_information110     => l_reg_rec.reg_attribute_category,
                          p_information185     => l_reg_rec.sttry_citn_name,
                          p_information265     => l_reg_rec.object_version_number,
                          p_object_version_number          => l_object_version_number,
                          p_effective_date                 => p_effective_date       );
                          --

                          if l_out_reg_result_id is null then
                            l_out_reg_result_id := l_copy_entity_result_id;
                          end if;

                          if l_result_type_cd = 'DISPLAY' then
                             l_out_reg_result_id := l_copy_entity_result_id ;
                          end if;
                          --
                       end loop;
                       --
                     end loop;
                  ---------------------------------------------------------------
                  -- END OF BEN_REGN_F ----------------------
                  ---------------------------------------------------------------
                 end loop;
              ---------------------------------------------------------------
              -- END OF BEN_PL_REGN_F ----------------------
              ---------------------------------------------------------------
               ---------------------------------------------------------------
               -- START OF BEN_PL_REGY_BOD_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_prb_from_parent(l_RPTG_GRP_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_bnr_result_id ;
                  --
                  l_pl_regy_bod_id := l_parent_rec.pl_regy_bod_id ;
                  --
                  for l_prb_rec in c_prb(l_parent_rec.pl_regy_bod_id,l_mirror_src_entity_result_id,'PRB') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('PRB');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := l_prb_rec.regy_pl_name ;
                    --
                    if p_effective_date between l_prb_rec.effective_start_date
                       and l_prb_rec.effective_end_date then
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
                      p_table_alias					  => 'PRB',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_prb_rec.pl_regy_bod_id,
                      p_information2     => l_prb_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_prb_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_prb_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information306     => l_prb_rec.aprvd_trmn_dt,
                      p_information252     => l_prb_rec.organization_id,
                      p_information261     => l_prb_rec.pl_id,
                      p_information111     => l_prb_rec.prb_attribute1,
                      p_information120     => l_prb_rec.prb_attribute10,
                      p_information121     => l_prb_rec.prb_attribute11,
                      p_information122     => l_prb_rec.prb_attribute12,
                      p_information123     => l_prb_rec.prb_attribute13,
                      p_information124     => l_prb_rec.prb_attribute14,
                      p_information125     => l_prb_rec.prb_attribute15,
                      p_information126     => l_prb_rec.prb_attribute16,
                      p_information127     => l_prb_rec.prb_attribute17,
                      p_information128     => l_prb_rec.prb_attribute18,
                      p_information129     => l_prb_rec.prb_attribute19,
                      p_information112     => l_prb_rec.prb_attribute2,
                      p_information130     => l_prb_rec.prb_attribute20,
                      p_information131     => l_prb_rec.prb_attribute21,
                      p_information132     => l_prb_rec.prb_attribute22,
                      p_information133     => l_prb_rec.prb_attribute23,
                      p_information134     => l_prb_rec.prb_attribute24,
                      p_information135     => l_prb_rec.prb_attribute25,
                      p_information136     => l_prb_rec.prb_attribute26,
                      p_information137     => l_prb_rec.prb_attribute27,
                      p_information138     => l_prb_rec.prb_attribute28,
                      p_information139     => l_prb_rec.prb_attribute29,
                      p_information113     => l_prb_rec.prb_attribute3,
                      p_information140     => l_prb_rec.prb_attribute30,
                      p_information114     => l_prb_rec.prb_attribute4,
                      p_information115     => l_prb_rec.prb_attribute5,
                      p_information116     => l_prb_rec.prb_attribute6,
                      p_information117     => l_prb_rec.prb_attribute7,
                      p_information118     => l_prb_rec.prb_attribute8,
                      p_information119     => l_prb_rec.prb_attribute9,
                      p_information110     => l_prb_rec.prb_attribute_category,
                      p_information309     => l_prb_rec.quald_dt,
                      p_information11     => l_prb_rec.quald_flag,
                      p_information185     => l_prb_rec.regy_pl_name,
                      p_information242     => l_prb_rec.rptg_grp_id,
                      p_information265     => l_prb_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_prb_result_id is null then
                        l_out_prb_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_prb_result_id := l_copy_entity_result_id ;
                      end if;
                      --
                   end loop;
                   --
                   ---------------------------------------------------------------
                   -- START OF BEN_PL_REGY_PRP_F ----------------------
                   ---------------------------------------------------------------
                   --
                   for l_parent_rec  in c_prp_from_parent(l_PL_REGY_BOD_ID) loop
                      --
                      l_mirror_src_entity_result_id := l_out_prb_result_id ;
                      --
                      l_pl_regy_prps_id := l_parent_rec.pl_regy_prps_id ;
                      --
                      for l_prp_rec in c_prp(l_parent_rec.pl_regy_prps_id,l_mirror_src_entity_result_id,'PRP') loop
                        --
                        l_table_route_id := null ;
                        open ben_plan_design_program_module.g_table_route('PRP');
                          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                        close ben_plan_design_program_module.g_table_route ;
                        --
                        l_information5  := hr_general.decode_lookup('BEN_REGY_PRPS',l_prp_rec.pl_regy_prps_cd);
                        --
                        if p_effective_date between l_prp_rec.effective_start_date
                           and l_prp_rec.effective_end_date then
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
                          p_table_alias					  => 'PRP',
                          p_table_route_id                 => l_table_route_id,
                          p_information1     => l_prp_rec.pl_regy_prps_id,
                          p_information2     => l_prp_rec.EFFECTIVE_START_DATE,
                          p_information3     => l_prp_rec.EFFECTIVE_END_DATE,
                          p_information4     => l_prp_rec.business_group_id,
                          p_information5     => l_information5 , -- 9999 put name for h-grid
                          p_information258     => l_prp_rec.pl_regy_bod_id,
                          p_information11     => l_prp_rec.pl_regy_prps_cd,
                          p_information257     => l_prp_rec.pl_regy_prps_id,
                          p_information111     => l_prp_rec.prp_attribute1,
                          p_information120     => l_prp_rec.prp_attribute10,
                          p_information121     => l_prp_rec.prp_attribute11,
                          p_information122     => l_prp_rec.prp_attribute12,
                          p_information123     => l_prp_rec.prp_attribute13,
                          p_information124     => l_prp_rec.prp_attribute14,
                          p_information125     => l_prp_rec.prp_attribute15,
                          p_information126     => l_prp_rec.prp_attribute16,
                          p_information127     => l_prp_rec.prp_attribute17,
                          p_information128     => l_prp_rec.prp_attribute18,
                          p_information129     => l_prp_rec.prp_attribute19,
                          p_information112     => l_prp_rec.prp_attribute2,
                          p_information130     => l_prp_rec.prp_attribute20,
                          p_information131     => l_prp_rec.prp_attribute21,
                          p_information132     => l_prp_rec.prp_attribute22,
                          p_information133     => l_prp_rec.prp_attribute23,
                          p_information134     => l_prp_rec.prp_attribute24,
                          p_information135     => l_prp_rec.prp_attribute25,
                          p_information136     => l_prp_rec.prp_attribute26,
                          p_information137     => l_prp_rec.prp_attribute27,
                          p_information138     => l_prp_rec.prp_attribute28,
                          p_information139     => l_prp_rec.prp_attribute29,
                          p_information113     => l_prp_rec.prp_attribute3,
                          p_information140     => l_prp_rec.prp_attribute30,
                          p_information114     => l_prp_rec.prp_attribute4,
                          p_information115     => l_prp_rec.prp_attribute5,
                          p_information116     => l_prp_rec.prp_attribute6,
                          p_information117     => l_prp_rec.prp_attribute7,
                          p_information118     => l_prp_rec.prp_attribute8,
                          p_information119     => l_prp_rec.prp_attribute9,
                          p_information110     => l_prp_rec.prp_attribute_category,
                          p_information265     => l_prp_rec.object_version_number,
                          p_object_version_number          => l_object_version_number,
                          p_effective_date                 => p_effective_date       );
                          --

                          if l_out_prp_result_id is null then
                            l_out_prp_result_id := l_copy_entity_result_id;
                          end if;

                          if l_result_type_cd = 'DISPLAY' then
                             l_out_prp_result_id := l_copy_entity_result_id ;
                          end if;
                          --
                       end loop;
                       --
                     end loop;
                  ---------------------------------------------------------------
                  -- END OF BEN_PL_REGY_PRP_F ----------------------
                  ---------------------------------------------------------------
                 end loop;
              ---------------------------------------------------------------
              -- END OF BEN_PL_REGY_BOD_F ----------------------
              ---------------------------------------------------------------
               ---------------------------------------------------------------
               -- START OF BEN_POPL_RPTG_GRP_F ----------------------
               ---------------------------------------------------------------
               --
               /* NOT REQUIRED HERE
              */
              ---------------------------------------------------------------
              -- END OF BEN_POPL_RPTG_GRP_F ----------------------
              ---------------------------------------------------------------
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_RPTG_GRP ----------------------
        ---------------------------------------------------------------
        end loop;
     ---------------------------------------------------------------
     -- END OF BEN_POPL_RPTG_GRP_F ----------------------
     ---------------------------------------------------------------
   --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Business Group id, effective_date's can't be null
  -- pl_id or pgm_id must be supplied.
  --
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end create_popl_result ;
--
procedure create_ler_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in  varchar2  default null
  ) is
  --
  l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ler_result';
  l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
  --
   --
   -- Bug : 3752407 : Global cursor g_table_route will now be used
   --
   -- Cursor to get table_route_id
   -- cursor c_table_route(c_parent_table_alias varchar2) is
   -- select table_route_id
   -- from pqh_table_route trt
   -- where trt.table_alias = c_parent_table_alias;
   -- trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name) ;
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
--        pqh_table_route trt
   where cpe.information1= c_parent_pk_id
   and   cpe.result_type_cd = l_cv_result_type_cd
   and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
--   and   cpe.table_route_id = trt.table_route_id
   -- and   trt.from_clause = 'OAB'
   -- and   trt.where_clause = upper(c_parent_table_name) ;
   and   cpe.table_alias = c_parent_table_alias;
   ---
  ---------------------------------------------------------------
  -- START OF BEN_LER_F ----------------------
  ---------------------------------------------------------------
   cursor c_ler(c_ler_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  ler.*
   from BEN_LER_F ler
   where  ler.ler_id = c_ler_id
     -- and ler.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_id
           -- and information4 = ler.business_group_id
           and information2 = ler.effective_start_date
           and information3 = ler.effective_end_date
     );
  ---------------------------------------------------------------
  -- END OF BEN_LER_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_CSS_RLTD_PER_PER_IN_LER_F ----------------------
  ---------------------------------------------------------------
   cursor c_csr_from_parent(c_LER_ID number) is
   select  css_rltd_per_per_in_ler_id
   from BEN_CSS_RLTD_PER_PER_IN_LER_F
   where  LER_ID = c_LER_ID ;
   --
   cursor c_csr(c_css_rltd_per_per_in_ler_id number ,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  csr.*
   from BEN_CSS_RLTD_PER_PER_IN_LER_F csr
   where  csr.css_rltd_per_per_in_ler_id = c_css_rltd_per_per_in_ler_id
     -- and csr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_CSS_RLTD_PER_PER_IN_LER_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_css_rltd_per_per_in_ler_id
           -- and information4 = csr.business_group_id
           and information2 = csr.effective_start_date
           and information3 = csr.effective_end_date
     );
     l_out_csr_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_CSS_RLTD_PER_PER_IN_LER_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_PER_INFO_CS_LER_F ----------------------
  ---------------------------------------------------------------
   cursor c_lpl_from_parent(c_LER_ID number) is
   select  ler_per_info_cs_ler_id
   from BEN_LER_PER_INFO_CS_LER_F
   where  LER_ID = c_LER_ID
     and  ( exists ( select 'x'
                   from ben_ler_f
                   where LER_ID = c_LER_ID
                     and typ_cd = 'ABS')  OR
            nvl(p_no_dup_rslt, 'X') = 'Y');  -- For plan design wizard copy lpl also
   --
   cursor c_lpl(c_ler_per_info_cs_ler_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lpl.*
   from BEN_LER_PER_INFO_CS_LER_F lpl
   where  lpl.ler_per_info_cs_ler_id = c_ler_per_info_cs_ler_id
     -- and lpl.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_PER_INFO_CS_LER_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_per_info_cs_ler_id
           -- and information4 = lpl.business_group_id
           and information2 = lpl.effective_start_date
           and information3 = lpl.effective_end_date
     );
     l_out_lpl_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_PER_INFO_CS_LER_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_LER_RLTD_PER_CS_LER_F ----------------------
  ---------------------------------------------------------------
   cursor c_lrc_from_parent(c_LER_ID number) is
   select  ler_rltd_per_cs_ler_id
   from BEN_LER_RLTD_PER_CS_LER_F
   where  LER_ID = c_LER_ID ;
   --
   cursor c_lrc(c_ler_rltd_per_cs_ler_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lrc.*
   from BEN_LER_RLTD_PER_CS_LER_F lrc
   where  lrc.ler_rltd_per_cs_ler_id = c_ler_rltd_per_cs_ler_id
     -- and lrc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_LER_RLTD_PER_CS_LER_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_ler_rltd_per_cs_ler_id
           -- and information4 = lrc.business_group_id
           and information2 = lrc.effective_start_date
           and information3 = lrc.effective_end_date
     );
     l_out_lrc_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_LER_RLTD_PER_CS_LER_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_PER_INFO_CHG_CS_LER_F ----------------------
  ---------------------------------------------------------------
   cursor c_psl_from_parent(c_LER_PER_INFO_CS_LER_ID number) is
   select  psl.per_info_chg_cs_ler_id
   from BEN_LER_PER_INFO_CS_LER_F lpl,
        BEN_PER_INFO_CHG_CS_LER_F psl
   where  LER_PER_INFO_CS_LER_ID = c_LER_PER_INFO_CS_LER_ID
     and psl.PER_INFO_CHG_CS_LER_id = lpl.PER_INFO_CHG_CS_LER_id
     and  source_table = 'PER_ABSENCE_ATTENDANCES';
   --
   cursor c_psl(c_per_info_chg_cs_ler_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  psl.*
   from BEN_PER_INFO_CHG_CS_LER_F psl
   where  psl.per_info_chg_cs_ler_id = c_per_info_chg_cs_ler_id
     -- and psl.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_PER_INFO_CHG_CS_LER_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_per_info_chg_cs_ler_id
           -- and information4 = psl.business_group_id
           and information2 = psl.effective_start_date
           and information3 = psl.effective_end_date
     );
    --
    cursor c_abs_reason(cv_lookup_code in varchar2, cv_effective_date in date) is
    SELECT distinct hl.meaning
    FROM hr_lookups hl,
         per_abs_attendance_reasons abs
    WHERE hl.lookup_type = 'ABSENCE_REASON'
      AND hl.lookup_code = abs.name
      AND hl.lookup_code = cv_lookup_code
      AND hl.enabled_flag = 'Y'
      AND abs.business_group_id = p_business_group_id
      AND cv_effective_date between nvl(start_date_active,cv_effective_date)
      and nvl(end_date_active,cv_effective_date);
    --
    cursor c_abs_type(cv_val in varchar2) is
    SELECT distinct name
    from PER_ABSENCE_ATTENDANCE_TYPES
    WHERE business_group_id = p_business_group_id
      and to_char(absence_attendance_type_id) = cv_val;
    --
    l_abs_old_name varchar2(600);
    l_abs_new_name varchar2(600);
    l_out_psl_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_PER_INFO_CHG_CS_LER_F ----------------------
  ---------------------------------------------------------------
  ---------------------------------------------------------------
  -- START OF BEN_RLTD_PER_CHG_CS_LER_F ----------------------
  ---------------------------------------------------------------
   cursor c_rcl_from_parent(c_LER_RLTD_PER_CS_LER_ID number) is
   select  rltd_per_chg_cs_ler_id
   from BEN_LER_RLTD_PER_CS_LER_F
   where  LER_RLTD_PER_CS_LER_ID = c_LER_RLTD_PER_CS_LER_ID ;
   --
   cursor c_rcl(c_rltd_per_chg_cs_ler_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  rcl.*
   from BEN_RLTD_PER_CHG_CS_LER_F rcl
   where  rcl.rltd_per_chg_cs_ler_id = c_rltd_per_chg_cs_ler_id
     -- and rcl.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_RLTD_PER_CHG_CS_LER_F'
           and cpe.table_alias = c_table_alias
           and information1 = c_rltd_per_chg_cs_ler_id
           -- and information4 = rcl.business_group_id
           and information2 = rcl.effective_start_date
           and information3 = rcl.effective_end_date
     );
     l_out_rcl_result_id number(15);
  ---------------------------------------------------------------
  -- END OF BEN_RLTD_PER_CHG_CS_LER_F ----------------------
  ---------------------------------------------------------------

  cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
--    and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

  l_dummy                     varchar2(1);

  l_table_route_id                number(15);
  l_mirror_src_entity_result_id     number(15);
  l_result_type_cd                varchar2(30);
  l_information5                  ben_copy_entity_results.information5%type;
  l_ler_id                        number(15);
  l_number_of_copies              number(15);
  l_css_rltd_per_per_in_ler_id    number(15);
  l_ler_per_info_cs_ler_id        number(15);
  l_ler_rltd_per_cs_ler_id        number(15);
  l_per_info_chg_cs_ler_id        number(15);
  l_rltd_per_chg_cs_ler_id        number(15);
  l_out_src_result_id             number(15);
begin

  if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
    ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
  end if;

  if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
    open c_object_exists(p_ler_id,'LER');
    fetch c_object_exists into l_dummy;
    if c_object_exists%found then
      close c_object_exists;
      return;
    end if;
    close c_object_exists;
  end if;

  --
  l_number_of_copies := p_number_of_copies ;

  --
  ---------------------------------------------------------------
  -- START OF BEN_LER_F ----------------------
  ---------------------------------------------------------------
  --
  l_mirror_src_entity_result_id := p_copy_entity_result_id;
  --
  for l_ler_rec in c_ler(p_ler_id,l_mirror_src_entity_result_id,'LER') loop
   --
   --
       l_table_route_id := null ;
       open ben_plan_design_program_module.g_table_route('LER');
       fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
       close ben_plan_design_program_module.g_table_route ;
       --
       l_information5  := l_ler_rec.name; --'Intersection';
       --
       l_ler_id := l_ler_rec.ler_id ;
       if p_effective_date between l_ler_rec.effective_start_date
           and l_ler_rec.effective_end_date then
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
            p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_mirror_src_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_alias					 => 'LER',
            p_table_route_id                 => l_table_route_id,
            p_information1     => l_ler_rec.ler_id,
            p_information2     => l_ler_rec.EFFECTIVE_START_DATE,
            p_information3     => l_ler_rec.EFFECTIVE_END_DATE,
            p_information4     => l_ler_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information22     => l_ler_rec.ck_rltd_per_elig_flag,
            p_information23     => l_ler_rec.cm_aply_flag,
            p_information219     => l_ler_rec.desc_txt,
            p_information111     => l_ler_rec.ler_attribute1,
            p_information120     => l_ler_rec.ler_attribute10,
            p_information121     => l_ler_rec.ler_attribute11,
            p_information122     => l_ler_rec.ler_attribute12,
            p_information123     => l_ler_rec.ler_attribute13,
            p_information124     => l_ler_rec.ler_attribute14,
            p_information125     => l_ler_rec.ler_attribute15,
            p_information126     => l_ler_rec.ler_attribute16,
            p_information127     => l_ler_rec.ler_attribute17,
            p_information128     => l_ler_rec.ler_attribute18,
            p_information129     => l_ler_rec.ler_attribute19,
            p_information112     => l_ler_rec.ler_attribute2,
            p_information130     => l_ler_rec.ler_attribute20,
            p_information131     => l_ler_rec.ler_attribute21,
            p_information132     => l_ler_rec.ler_attribute22,
            p_information133     => l_ler_rec.ler_attribute23,
            p_information134     => l_ler_rec.ler_attribute24,
            p_information135     => l_ler_rec.ler_attribute25,
            p_information136     => l_ler_rec.ler_attribute26,
            p_information137     => l_ler_rec.ler_attribute27,
            p_information138     => l_ler_rec.ler_attribute28,
            p_information139     => l_ler_rec.ler_attribute29,
            p_information113     => l_ler_rec.ler_attribute3,
            p_information140     => l_ler_rec.ler_attribute30,
            p_information114     => l_ler_rec.ler_attribute4,
            p_information115     => l_ler_rec.ler_attribute5,
            p_information116     => l_ler_rec.ler_attribute6,
            p_information117     => l_ler_rec.ler_attribute7,
            p_information118     => l_ler_rec.ler_attribute8,
            p_information119     => l_ler_rec.ler_attribute9,
            p_information110     => l_ler_rec.ler_attribute_category,
            p_information261     => l_ler_rec.ler_eval_rl,
            p_information15      => l_ler_rec.ler_stat_cd,
            p_information13      => l_ler_rec.lf_evt_oper_cd,
            p_information170     => l_ler_rec.name,
            p_information21      => l_ler_rec.ocrd_dt_det_cd,
            p_information24      => l_ler_rec.ovridg_le_flag,
            p_information17      => l_ler_rec.ptnl_ler_trtmt_cd,
            p_information25      => l_ler_rec.qualg_evt_flag,
            p_information26      => l_ler_rec.ss_pcp_disp_cd, --4301332
            p_information11      => l_ler_rec.short_code,
            p_information12      => l_ler_rec.short_name,
            p_information14      => l_ler_rec.slctbl_slf_svc_cd,
            p_information263     => l_ler_rec.tmlns_dys_num,
            p_information20      => l_ler_rec.tmlns_eval_cd,
            p_information19      => l_ler_rec.tmlns_perd_cd,
            p_information262     => l_ler_rec.tmlns_perd_rl,
            p_information16      => l_ler_rec.typ_cd,
            p_information18      => l_ler_rec.whn_to_prcs_cd,
            p_information265     => l_ler_rec.object_version_number,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
   --

            if l_out_src_result_id is null then
              l_out_src_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
		  -- ------------------------------------------------------------------------
		  l_out_src_result_id := l_copy_entity_result_id ;
		  -- ------------------------------------------------------------------------
		end if;
	--
			if (l_ler_rec.ler_eval_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_ler_rec.ler_eval_rl
					,p_business_group_id        => l_ler_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			if (l_ler_rec.tmlns_perd_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_ler_rec.tmlns_perd_rl
					,p_business_group_id        => l_ler_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

	--
   end loop;
   ---------------------------------------------------------------
   -- END OF BEN_LER_F ----------------------
   ---------------------------------------------------------------
         /* -- START NOTIMPLEMENTED
         ---------------------------------------------------------------
         -- START OF BEN_CSS_RLTD_PER_PER_IN_LER_F ----------------------
         ---------------------------------------------------------------
       --
       for l_parent_rec  in c_csr_from_parent(l_LER_ID) loop
       --
            l_mirror_src_entity_result_id := l_out_src_result_id ;

            l_css_rltd_per_per_in_ler_id := l_parent_rec.css_rltd_per_per_in_ler_id ;
            --
            for l_csr_rec in c_csr(l_parent_rec.css_rltd_per_per_in_ler_id,l_mirror_src_entity_result_id,'CSR') loop
            --
            --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('CSR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := ben_plan_design_program_module.get_ler_name(l_csr_rec.rsltg_ler_id,p_effective_date); --'Intersection';
                --
                l_css_rltd_per_per_in_ler_id := l_csr_rec.css_rltd_per_per_in_ler_id ;
                if p_effective_date between l_csr_rec.effective_start_date
                    and l_csr_rec.effective_end_date then
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
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_csr_rec.css_rltd_per_per_in_ler_id,
                     p_information2     => l_csr_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_csr_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_csr_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information111     => l_csr_rec.csr_attribute1,
                     p_information120     => l_csr_rec.csr_attribute10,
                     p_information121     => l_csr_rec.csr_attribute11,
                     p_information122     => l_csr_rec.csr_attribute12,
                     p_information123     => l_csr_rec.csr_attribute13,
                     p_information124     => l_csr_rec.csr_attribute14,
                     p_information125     => l_csr_rec.csr_attribute15,
                     p_information126     => l_csr_rec.csr_attribute16,
                     p_information127     => l_csr_rec.csr_attribute17,
                     p_information128     => l_csr_rec.csr_attribute18,
                     p_information129     => l_csr_rec.csr_attribute19,
                     p_information112     => l_csr_rec.csr_attribute2,
                     p_information130     => l_csr_rec.csr_attribute20,
                     p_information131     => l_csr_rec.csr_attribute21,
                     p_information132     => l_csr_rec.csr_attribute22,
                     p_information133     => l_csr_rec.csr_attribute23,
                     p_information134     => l_csr_rec.csr_attribute24,
                     p_information135     => l_csr_rec.csr_attribute25,
                     p_information136     => l_csr_rec.csr_attribute26,
                     p_information137     => l_csr_rec.csr_attribute27,
                     p_information138     => l_csr_rec.csr_attribute28,
                     p_information139     => l_csr_rec.csr_attribute29,
                     p_information113     => l_csr_rec.csr_attribute3,
                     p_information140     => l_csr_rec.csr_attribute30,
                     p_information114     => l_csr_rec.csr_attribute4,
                     p_information115     => l_csr_rec.csr_attribute5,
                     p_information116     => l_csr_rec.csr_attribute6,
                     p_information117     => l_csr_rec.csr_attribute7,
                     p_information118     => l_csr_rec.csr_attribute8,
                     p_information119     => l_csr_rec.csr_attribute9,
                     p_information110     => l_csr_rec.csr_attribute_category,
                     p_information257     => l_csr_rec.ler_id,
                     p_information261     => l_csr_rec.ordr_to_prcs_num,
                     p_information262     => l_csr_rec.rsltg_ler_id,
                     p_information265     => l_csr_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
              --

                     if l_out_csr_result_id is null then
                       l_out_csr_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                       l_out_csr_result_id := l_copy_entity_result_id ;
                     end if;
              end loop;
            --
            end loop;
         ---------------------------------------------------------------
         -- END OF BEN_CSS_RLTD_PER_PER_IN_LER_F ----------------------
         ---------------------------------------------------------------
*/
         -- NOTIMPLEMENTED
         ---------------------------------------------------------------
         -- START OF BEN_LER_PER_INFO_CS_LER_F ----------------------
         ---------------------------------------------------------------
            --
         for l_parent_rec  in c_lpl_from_parent(l_LER_ID) loop
         --
           l_mirror_src_entity_result_id := l_out_src_result_id ;

           l_ler_per_info_cs_ler_id := l_parent_rec.ler_per_info_cs_ler_id ;
           --
           for l_lpl_rec in c_lpl(l_parent_rec.ler_per_info_cs_ler_id,l_mirror_src_entity_result_id,'LPL') loop
           --
           --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('LPL');
               fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := ben_plan_design_program_module.get_per_info_chg_cs_ler_name(l_lpl_rec.per_info_chg_cs_ler_id,
                                                   p_effective_date); --'Intersection';
                --
                if p_effective_date between l_lpl_rec.effective_start_date
                    and l_lpl_rec.effective_end_date then
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
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_alias					 => 'LPL',
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_lpl_rec.ler_per_info_cs_ler_id,
                     p_information2     => l_lpl_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_lpl_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_lpl_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information257     => l_lpl_rec.ler_id,
                     p_information262     => l_lpl_rec.ler_per_info_cs_ler_rl,
                     p_information111     => l_lpl_rec.lpl_attribute1,
                     p_information120     => l_lpl_rec.lpl_attribute10,
                     p_information121     => l_lpl_rec.lpl_attribute11,
                     p_information122     => l_lpl_rec.lpl_attribute12,
                     p_information123     => l_lpl_rec.lpl_attribute13,
                     p_information124     => l_lpl_rec.lpl_attribute14,
                     p_information125     => l_lpl_rec.lpl_attribute15,
                     p_information126     => l_lpl_rec.lpl_attribute16,
                     p_information127     => l_lpl_rec.lpl_attribute17,
                     p_information128     => l_lpl_rec.lpl_attribute18,
                     p_information129     => l_lpl_rec.lpl_attribute19,
                     p_information112     => l_lpl_rec.lpl_attribute2,
                     p_information130     => l_lpl_rec.lpl_attribute20,
                     p_information131     => l_lpl_rec.lpl_attribute21,
                     p_information132     => l_lpl_rec.lpl_attribute22,
                     p_information133     => l_lpl_rec.lpl_attribute23,
                     p_information134     => l_lpl_rec.lpl_attribute24,
                     p_information135     => l_lpl_rec.lpl_attribute25,
                     p_information136     => l_lpl_rec.lpl_attribute26,
                     p_information137     => l_lpl_rec.lpl_attribute27,
                     p_information138     => l_lpl_rec.lpl_attribute28,
                     p_information139     => l_lpl_rec.lpl_attribute29,
                     p_information113     => l_lpl_rec.lpl_attribute3,
                     p_information140     => l_lpl_rec.lpl_attribute30,
                     p_information114     => l_lpl_rec.lpl_attribute4,
                     p_information115     => l_lpl_rec.lpl_attribute5,
                     p_information116     => l_lpl_rec.lpl_attribute6,
                     p_information117     => l_lpl_rec.lpl_attribute7,
                     p_information118     => l_lpl_rec.lpl_attribute8,
                     p_information119     => l_lpl_rec.lpl_attribute9,
                     p_information110     => l_lpl_rec.lpl_attribute_category,
                     p_information258     => l_lpl_rec.per_info_chg_cs_ler_id,
                     p_information265     => l_lpl_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
              --

                      if l_out_lpl_result_id is null then
                        l_out_lpl_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_lpl_result_id := l_copy_entity_result_id ;
                      end if;

                      if (l_lpl_rec.ler_per_info_cs_ler_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_lpl_rec.ler_per_info_cs_ler_rl
								,p_business_group_id        => l_lpl_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

              --
            end loop;
            --
               ---------------------------------------------------------------
               -- START OF BEN_PER_INFO_CHG_CS_LER_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_psl_from_parent(l_LER_PER_INFO_CS_LER_ID) loop
               --
                 l_mirror_src_entity_result_id := l_out_lpl_result_id ;

                 l_per_info_chg_cs_ler_id := l_parent_rec.per_info_chg_cs_ler_id ;
                 --
                 for l_psl_rec in c_psl(l_parent_rec.per_info_chg_cs_ler_id,l_mirror_src_entity_result_id,'PSL') loop
                 --
                 --
                     l_table_route_id := null ;
                     open ben_plan_design_program_module.g_table_route('PSL');
                     fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                     close ben_plan_design_program_module.g_table_route ;
                      --
                      l_information5  := SUBSTR(l_psl_rec.name,1,255); --'Intersection';
                      --

                      if p_effective_date between l_psl_rec.effective_start_date
                          and l_psl_rec.effective_end_date then
                          --
                          l_result_type_cd := 'DISPLAY';
                      else
                          l_result_type_cd := 'NO DISPLAY';
                      end if;
                      --
                      -- For absences seeded plan design
                      --
                      l_abs_old_name := null;
                      l_abs_new_name := null;
                      --
                      if l_psl_rec.source_table = 'PER_ABSENCE_ATTENDANCES' then
                         --
                         if l_psl_rec.source_column = 'ABSENCE_ATTENDANCE_TYPE_ID' then
                            --
                            if l_psl_rec.old_val not in ('OABANY', 'NULL') then
                               open c_abs_type(l_psl_rec.old_val);
                               fetch c_abs_type into l_abs_old_name;
                               close c_abs_type;
                            end if;
                            --
                            if l_psl_rec.new_val not in ('OABANY', 'NULL') then
                               open c_abs_type(l_psl_rec.new_val);
                               fetch c_abs_type into l_abs_new_name;
                               close c_abs_type;
                            end if;
                            --
                         elsif l_psl_rec.source_column = 'ABS_ATTENDANCE_REASON_ID' then
                            --
                            if l_psl_rec.old_val not in ('OABANY', 'NULL') then
                               open c_abs_reason(l_psl_rec.old_val, p_effective_date);
                               fetch c_abs_reason into l_abs_old_name;
                               close c_abs_reason;
                            end if;
                            --
                            if l_psl_rec.new_val not in ('OABANY', 'NULL') then
                               open c_abs_reason(l_psl_rec.new_val,p_effective_date );
                               fetch c_abs_reason into l_abs_new_name;
                               close c_abs_reason;
                            end if;
                            --
                         end if;
                         --
                      end if;
                      --
                      l_copy_entity_result_id := null;
                      l_object_version_number := null;
                      ben_copy_entity_results_api.create_copy_entity_results(
                           p_copy_entity_result_id           => l_copy_entity_result_id,
                           p_copy_entity_txn_id             => p_copy_entity_txn_id,
                           p_result_type_cd                 => l_result_type_cd,
                           p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                           p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                           p_number_of_copies               => l_number_of_copies,
                           p_table_alias					 => 'PSL',
                           p_table_route_id                 => l_table_route_id,
                           p_information1     => l_psl_rec.per_info_chg_cs_ler_id,
                           p_information2     => l_psl_rec.EFFECTIVE_START_DATE,
                           p_information3     => l_psl_rec.EFFECTIVE_END_DATE,
                           p_information4     => l_psl_rec.business_group_id,
                           p_information5     => l_information5 , -- 9999 put name for h-grid
                           --
                           -- Bug No: 3907710
                           --
                           p_information11    => l_psl_rec.rule_overrides_flag,
                           --
                           p_information218     => l_psl_rec.name,
                           p_information186     => l_psl_rec.new_val,
                           p_information185     => l_psl_rec.old_val,
                           p_information260     => l_psl_rec.per_info_chg_cs_ler_rl,
                           p_information111     => l_psl_rec.psl_attribute1,
                           p_information120     => l_psl_rec.psl_attribute10,
                           p_information121     => l_psl_rec.psl_attribute11,
                           p_information122     => l_psl_rec.psl_attribute12,
                           p_information123     => l_psl_rec.psl_attribute13,
                           p_information124     => l_psl_rec.psl_attribute14,
                           p_information125     => l_psl_rec.psl_attribute15,
                           p_information126     => l_psl_rec.psl_attribute16,
                           p_information127     => l_psl_rec.psl_attribute17,
                           p_information128     => l_psl_rec.psl_attribute18,
                           p_information129     => l_psl_rec.psl_attribute19,
                           p_information112     => l_psl_rec.psl_attribute2,
                           p_information130     => l_psl_rec.psl_attribute20,
                           p_information131     => l_psl_rec.psl_attribute21,
                           p_information132     => l_psl_rec.psl_attribute22,
                           p_information133     => l_psl_rec.psl_attribute23,
                           p_information134     => l_psl_rec.psl_attribute24,
                           p_information135     => l_psl_rec.psl_attribute25,
                           p_information136     => l_psl_rec.psl_attribute26,
                           p_information137     => l_psl_rec.psl_attribute27,
                           p_information138     => l_psl_rec.psl_attribute28,
                           p_information139     => l_psl_rec.psl_attribute29,
                           p_information113     => l_psl_rec.psl_attribute3,
                           p_information140     => l_psl_rec.psl_attribute30,
                           p_information114     => l_psl_rec.psl_attribute4,
                           p_information115     => l_psl_rec.psl_attribute5,
                           p_information116     => l_psl_rec.psl_attribute6,
                           p_information117     => l_psl_rec.psl_attribute7,
                           p_information118     => l_psl_rec.psl_attribute8,
                           p_information119     => l_psl_rec.psl_attribute9,
                           p_information110     => l_psl_rec.psl_attribute_category,
                           p_information141     => l_psl_rec.source_column,
                           p_information142     => l_psl_rec.source_table,
                           p_information219     => l_psl_rec.whatif_lbl_txt,
                           p_information187     => l_abs_new_name,
                           p_information188     => l_abs_old_name,
                           p_information265     => l_psl_rec.object_version_number,
                           p_object_version_number          => l_object_version_number,
                           p_effective_date                 => p_effective_date       );
                    --

                        if l_out_psl_result_id is null then
                          l_out_psl_result_id := l_copy_entity_result_id;
                        end if;

                        if l_result_type_cd = 'DISPLAY' then
                          l_out_psl_result_id := l_copy_entity_result_id ;
                        end if;

				if (l_psl_rec.per_info_chg_cs_ler_rl is not null) then
				   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_psl_rec.per_info_chg_cs_ler_rl
					,p_business_group_id        => l_psl_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
				end if;
				--
                    end loop;
                  --
                  end loop;
               ---------------------------------------------------------------
               -- END OF BEN_PER_INFO_CHG_CS_LER_F ----------------------
               ---------------------------------------------------------------
            end loop;
         ---------------------------------------------------------------
         -- END OF BEN_LER_PER_INFO_CS_LER_F ----------------------
         ---------------------------------------------------------------
         /* -- NOTIMPLEMENTED
         ---------------------------------------------------------------
         -- START OF BEN_LER_RLTD_PER_CS_LER_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_lrc_from_parent(l_LER_ID) loop
         --
            l_mirror_src_entity_result_id := l_out_src_result_id ;

            l_ler_rltd_per_cs_ler_id := l_parent_rec.ler_rltd_per_cs_ler_id ;
            --
            for l_lrc_rec in c_lrc(l_parent_rec.ler_rltd_per_cs_ler_id,l_mirror_src_entity_result_id,'LRC') loop
            --
            --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('LRC');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := SUBSTR(
                                     ben_plan_design_program_module.get_rltd_per_chg_cs_ler_name(
                                     l_lrc_rec.rltd_per_chg_cs_ler_id,
                                     p_effective_date),1,255); --'Intersection';
                --
                l_ler_rltd_per_cs_ler_id := l_lrc_rec.ler_rltd_per_cs_ler_id ;
                if p_effective_date between l_lrc_rec.effective_start_date
                    and l_lrc_rec.effective_end_date then
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
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_lrc_rec.ler_rltd_per_cs_ler_id,
                     p_information2     => l_lrc_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_lrc_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_lrc_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
		     p_information257     => l_lrc_rec.ler_id,
		     p_information262     => l_lrc_rec.ler_rltd_per_cs_chg_rl,
		     p_information111     => l_lrc_rec.lrc_attribute1,
                     p_information120     => l_lrc_rec.lrc_attribute10,
                     p_information121     => l_lrc_rec.lrc_attribute11,
                     p_information122     => l_lrc_rec.lrc_attribute12,
                     p_information123     => l_lrc_rec.lrc_attribute13,
                     p_information124     => l_lrc_rec.lrc_attribute14,
                     p_information125     => l_lrc_rec.lrc_attribute15,
                     p_information126     => l_lrc_rec.lrc_attribute16,
                     p_information127     => l_lrc_rec.lrc_attribute17,
                     p_information128     => l_lrc_rec.lrc_attribute18,
                     p_information129     => l_lrc_rec.lrc_attribute19,
                     p_information112     => l_lrc_rec.lrc_attribute2,
                     p_information130     => l_lrc_rec.lrc_attribute20,
                     p_information131     => l_lrc_rec.lrc_attribute21,
                     p_information132     => l_lrc_rec.lrc_attribute22,
                     p_information133     => l_lrc_rec.lrc_attribute23,
                     p_information134     => l_lrc_rec.lrc_attribute24,
                     p_information135     => l_lrc_rec.lrc_attribute25,
                     p_information136     => l_lrc_rec.lrc_attribute26,
                     p_information137     => l_lrc_rec.lrc_attribute27,
                     p_information138     => l_lrc_rec.lrc_attribute28,
                     p_information139     => l_lrc_rec.lrc_attribute29,
                     p_information113     => l_lrc_rec.lrc_attribute3,
                     p_information140     => l_lrc_rec.lrc_attribute30,
                     p_information114     => l_lrc_rec.lrc_attribute4,
                     p_information115     => l_lrc_rec.lrc_attribute5,
                     p_information116     => l_lrc_rec.lrc_attribute6,
                     p_information117     => l_lrc_rec.lrc_attribute7,
                     p_information118     => l_lrc_rec.lrc_attribute8,
                     p_information119     => l_lrc_rec.lrc_attribute9,
                     p_information110     => l_lrc_rec.lrc_attribute_category,
                     p_information258     => l_lrc_rec.rltd_per_chg_cs_ler_id,
                     p_information265     => l_lrc_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
              --

                     if l_out_lrc_result_id is null then
                       l_out_lrc_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                       l_out_lrc_result_id := l_copy_entity_result_id ;
                     end if;

                      if (l_lrc_rec.ler_rltd_per_cs_chg_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  => l_lrc_rec.ler_rltd_per_cs_chg_rl
								,p_business_group_id        => l_lrc_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;


              --
              end loop;
            --
             ---------------------------------------------------------------
             -- START OF BEN_RLTD_PER_CHG_CS_LER_F ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_rcl_from_parent(l_LER_RLTD_PER_CS_LER_ID) loop
              --
                l_mirror_src_entity_result_id := l_out_lrc_result_id ;

                l_rltd_per_chg_cs_ler_id := l_parent_rec.rltd_per_chg_cs_ler_id ;
                --
                for l_rcl_rec in c_rcl(l_parent_rec.rltd_per_chg_cs_ler_id,l_mirror_src_entity_result_id,'RCL') loop
                --
                --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('RCL');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := SUBSTR(l_rcl_rec.name,1,255); --'Intersection';
                   --

                    if p_effective_date between l_rcl_rec.effective_start_date
                        and l_rcl_rec.effective_end_date then
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
                         p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                         p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                         p_number_of_copies               => l_number_of_copies,
                         p_table_route_id                 => l_table_route_id,
                         p_information1     => l_rcl_rec.rltd_per_chg_cs_ler_id,
                         p_information2     => l_rcl_rec.EFFECTIVE_START_DATE,
                         p_information3     => l_rcl_rec.EFFECTIVE_END_DATE,
                         p_information4     => l_rcl_rec.business_group_id,
                         p_information5     => l_information5 , -- 9999 put name for h-grid
                         --
                         -- Bug No: 3907710
                         --
                         p_information11    => l_rcl_rec.rule_overrides_flag,
                         --
                         p_information218     => l_rcl_rec.name,
                         p_information186     => l_rcl_rec.new_val,
                         p_information185     => l_rcl_rec.old_val,
                         p_information111     => l_rcl_rec.rcl_attribute1,
                         p_information120     => l_rcl_rec.rcl_attribute10,
                         p_information121     => l_rcl_rec.rcl_attribute11,
                         p_information122     => l_rcl_rec.rcl_attribute12,
                         p_information123     => l_rcl_rec.rcl_attribute13,
                         p_information124     => l_rcl_rec.rcl_attribute14,
                         p_information125     => l_rcl_rec.rcl_attribute15,
                         p_information126     => l_rcl_rec.rcl_attribute16,
                         p_information127     => l_rcl_rec.rcl_attribute17,
                         p_information128     => l_rcl_rec.rcl_attribute18,
                         p_information129     => l_rcl_rec.rcl_attribute19,
                         p_information112     => l_rcl_rec.rcl_attribute2,
                         p_information130     => l_rcl_rec.rcl_attribute20,
                         p_information131     => l_rcl_rec.rcl_attribute21,
                         p_information132     => l_rcl_rec.rcl_attribute22,
                         p_information133     => l_rcl_rec.rcl_attribute23,
                         p_information134     => l_rcl_rec.rcl_attribute24,
                         p_information135     => l_rcl_rec.rcl_attribute25,
                         p_information136     => l_rcl_rec.rcl_attribute26,
                         p_information137     => l_rcl_rec.rcl_attribute27,
                         p_information138     => l_rcl_rec.rcl_attribute28,
                         p_information139     => l_rcl_rec.rcl_attribute29,
                         p_information113     => l_rcl_rec.rcl_attribute3,
                         p_information140     => l_rcl_rec.rcl_attribute30,
                         p_information114     => l_rcl_rec.rcl_attribute4,
                         p_information115     => l_rcl_rec.rcl_attribute5,
                         p_information116     => l_rcl_rec.rcl_attribute6,
                         p_information117     => l_rcl_rec.rcl_attribute7,
                         p_information118     => l_rcl_rec.rcl_attribute8,
                         p_information119     => l_rcl_rec.rcl_attribute9,
                         p_information110     => l_rcl_rec.rcl_attribute_category,
                         p_information260     => l_rcl_rec.rltd_per_chg_cs_ler_rl,
                         p_information141     => l_rcl_rec.source_column,
                         p_information142     => l_rcl_rec.source_table,
                         p_information219     => l_rcl_rec.whatif_lbl_txt,
                         p_information265     => l_rcl_rec.object_version_number,
                         p_object_version_number          => l_object_version_number,
                         p_effective_date                 => p_effective_date       );
                  --

                      if l_out_rcl_result_id is null then
                        l_out_rcl_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                        l_out_rcl_result_id := l_copy_entity_result_id ;
                      end if;

                      if (l_rcl_rec.rltd_per_chg_cs_ler_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
				p_validate                => p_validate
				,p_copy_entity_result_id  => l_copy_entity_result_id
				,p_copy_entity_txn_id     => p_copy_entity_txn_id
				,p_formula_id             => l_rcl_rec.rltd_per_chg_cs_ler_rl
				,p_business_group_id      => l_rcl_rec.business_group_id
				,p_number_of_copies       => l_number_of_copies
				,p_object_version_number  => l_object_version_number
				,p_effective_date         => p_effective_date);
			end if;
                  --
                  end loop;
                --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_RLTD_PER_CHG_CS_LER_F ----------------------
             ---------------------------------------------------------------
            end loop;
         ---------------------------------------------------------------
         -- END OF BEN_LER_RLTD_PER_CS_LER_F ----------------------
         ---------------------------------------------------------------
         -- End NOTIMPLEMENTED
         */
end;
--
procedure create_oipl_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_oipl_id                        in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in varchar2   default null
    ) is
    --
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_popl_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_result_type_cd   varchar2(30) :=  'DISPLAY' ;
    -- Cursor to get mirror_src_entity_result_id
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
    select copy_entity_result_id mirror_src_entity_result_id
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where cpe.information1        = c_parent_pk_id
    and   cpe.result_type_cd      = l_result_type_cd
    and   cpe.copy_entity_txn_id  = c_copy_entity_txn_id
--    and   cpe.table_route_id      = trt.table_route_id
    and   cpe.table_alias         = c_parent_table_alias;
    --
    -- Cursor to get table_route_id
    --
    -- Bug : 3752407 : Global cursor g_table_route will now be used
    --
    -- cursor c_table_route(c_parent_table_alias varchar2) is
    -- select table_route_id
    -- from pqh_table_route trt
    -- where trt.table_alias         = c_parent_table_alias;
    --
   ---------------------------------------------------------------
   -- START OF BEN_OIPL_F ----------------------
   ---------------------------------------------------------------
   cursor c_cop1(c_oipl_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  cop.*
   from BEN_OIPL_F cop
   where  cop.oipl_id = c_oipl_id
     -- and cop.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_OIPL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_oipl_id
         -- and information4 = cop.business_group_id
           and information2 = cop.effective_start_date
           and information3 = cop.effective_end_date
        );
    l_oipl_id                 number(15);
    l_out_cop_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_OIPL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSGN_RQMT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ddr1_from_parent(c_OIPL_ID number) is
   select  dsgn_rqmt_id
   from BEN_DSGN_RQMT_F
   where  OIPL_ID = c_OIPL_ID ;
   --
   cursor c_ddr1(c_dsgn_rqmt_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  ddr.*
   from BEN_DSGN_RQMT_F ddr
   where  ddr.dsgn_rqmt_id = c_dsgn_rqmt_id
     -- and ddr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGN_RQMT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgn_rqmt_id
         -- and information4 = ddr.business_group_id
           and information2 = ddr.effective_start_date
           and information3 = ddr.effective_end_date
        );
    l_dsgn_rqmt_id                 number(15);
    l_out_ddr_result_id   number(15);
    l_ddr1_dsgn_rqmt_esd ben_dsgn_rqmt_f.effective_start_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_DSGN_RQMT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
   ---------------------------------------------------------------
   cursor c_drr1_from_parent(c_DSGN_RQMT_ID number) is
   select  dsgn_rqmt_rlshp_typ_id
   from BEN_DSGN_RQMT_RLSHP_TYP
   where  DSGN_RQMT_ID = c_DSGN_RQMT_ID ;
   --
   cursor c_drr1(c_dsgn_rqmt_rlshp_typ_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  drr.*
   from BEN_DSGN_RQMT_RLSHP_TYP drr
   where  drr.dsgn_rqmt_rlshp_typ_id = c_dsgn_rqmt_rlshp_typ_id
     -- and drr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGN_RQMT_RLSHP_TYP'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgn_rqmt_rlshp_typ_id
         -- and information4 = drr.business_group_id
        );
    l_dsgn_rqmt_rlshp_typ_id                 number(15);
    l_out_drr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   cursor c_peo1_from_parent(c_OIPL_ID number) is
   select  elig_to_prte_rsn_id
   from BEN_ELIG_TO_PRTE_RSN_F
   where  OIPL_ID = c_OIPL_ID ;
   --
   cursor c_peo1(c_elig_to_prte_rsn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  peo.*
   from BEN_ELIG_TO_PRTE_RSN_F peo
   where  peo.elig_to_prte_rsn_id = c_elig_to_prte_rsn_id
     -- and peo.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_TO_PRTE_RSN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_to_prte_rsn_id
         -- and information4 = peo.business_group_id
           and information2 = peo.effective_start_date
           and information3 = peo.effective_end_date
        );
    l_out_peo_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_CHG_OIPL_ENRT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lop_from_parent(c_OIPL_ID number) is
   select distinct ler_chg_oipl_enrt_id
   from BEN_LER_CHG_OIPL_ENRT_F
   where  OIPL_ID = c_OIPL_ID ;
   --
   cursor c_lop(c_ler_chg_oipl_enrt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lop.*
   from BEN_LER_CHG_OIPL_ENRT_F lop
   where  lop.ler_chg_oipl_enrt_id = c_ler_chg_oipl_enrt_id
     -- and lop.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LER_CHG_OIPL_ENRT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_chg_oipl_enrt_id
         -- and information4 = lop.business_group_id
           and information2 = lop.effective_start_date
           and information3 = lop.effective_end_date
        );
    l_ler_chg_oipl_enrt_id                 number(15);
    l_out_lop_result_id   number(15);
   cursor c_lop_drp(c_ler_chg_oipl_enrt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id   = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LER_CHG_OIPL_ENRT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_chg_oipl_enrt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_LER_CHG_OIPL_ENRT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ENRT_CTFN_F ----------------------
   ---------------------------------------------------------------
   cursor c_ecf1_from_parent(c_OIPL_ID number) is
   select  enrt_ctfn_id
   from BEN_ENRT_CTFN_F
   where  OIPL_ID = c_OIPL_ID ;
   --
   cursor c_ecf1(c_enrt_ctfn_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  ecf.*
   from BEN_ENRT_CTFN_F ecf
   where  ecf.enrt_ctfn_id = c_enrt_ctfn_id
     -- and ecf.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ENRT_CTFN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_enrt_ctfn_id
         -- and information4 = ecf.business_group_id
           and information2 = ecf.effective_start_date
           and information3 = ecf.effective_end_date
        );
    l_out_ecf_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ENRT_CTFN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
   ---------------------------------------------------------------
   cursor c_lre1_from_parent(c_OIPL_ID number) is
   select distinct ler_rqrs_enrt_ctfn_id
   from BEN_LER_RQRS_ENRT_CTFN_F
   where  OIPL_ID = c_OIPL_ID ;
   --
   cursor c_lre1(c_ler_rqrs_enrt_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  lre.*
   from BEN_LER_RQRS_ENRT_CTFN_F lre
   where  lre.ler_rqrs_enrt_ctfn_id = c_ler_rqrs_enrt_ctfn_id
     -- and lre.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LER_RQRS_ENRT_CTFN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_rqrs_enrt_ctfn_id
         -- and information4 = lre.business_group_id
           and information2 = lre.effective_start_date
           and information3 = lre.effective_end_date
        );
    l_out_lre_result_id   number(15);
   cursor c_lre1_drp(c_ler_rqrs_enrt_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select distinct cpe.information257 ler_id
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LER_RQRS_ENRT_CTFN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_rqrs_enrt_ctfn_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LER_ENRT_CTFN_F ----------------------
   ---------------------------------------------------------------
   cursor c_lnc1_from_parent(c_LER_RQRS_ENRT_CTFN_ID number) is
   select  ler_enrt_ctfn_id
   from BEN_LER_ENRT_CTFN_F
   where  LER_RQRS_ENRT_CTFN_ID = c_LER_RQRS_ENRT_CTFN_ID ;
   --
   cursor c_lnc1(c_ler_enrt_ctfn_id number,c_mirror_src_entity_result_id number,                 c_table_alias varchar2) is
   select  lnc.*
   from BEN_LER_ENRT_CTFN_F lnc
   where  lnc.ler_enrt_ctfn_id = c_ler_enrt_ctfn_id
     -- and lnc.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LER_ENRT_CTFN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ler_enrt_ctfn_id
         -- and information4 = lnc.business_group_id
           and information2 = lnc.effective_start_date
           and information3 = lnc.effective_end_date
        );
    l_out_lnc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LER_ENRT_CTFN_F ----------------------
   ---------------------------------------------------------------

   cursor c_opt1_from_parent(c_OIPL_ID number) is
   select  distinct opt_id
   from BEN_OIPL_F
   where  OIPL_ID = c_OIPL_ID ;

   l_mirror_src_entity_result_id    number;
   l_parent_entity_result_id        number;
   l_table_route_id                 number;
   l_information5                   ben_copy_entity_results.information5%TYPE;
   l_number_of_copies               number := p_number_of_copies ;
   --
   L_ELIG_TO_PRTE_RSN_ID            number;

   L_LER_RQRS_ENRT_CTFN_ID          number;
   L_ENRT_CTFN_ID                   number;
   L_LER_ENRT_CTFN_ID               number;
   L_PL_TYP_ID                      number;
   L_OUT_PTP_RESULT_ID              number;
   --
begin
  --
        ---------------------------------------------------------------
        -- START OF BEN_OIPL_F ----------------------
        ---------------------------------------------------------------

             l_mirror_src_entity_result_id := p_copy_entity_result_id;
             l_parent_entity_result_id := p_parent_entity_result_id;

             l_oipl_id := p_oipl_id ;
             --
             for l_cop_rec in c_cop1(l_oipl_id,l_mirror_src_entity_result_id,'COP') loop
               --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('COP');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
               --
               l_information5  := ben_plan_design_program_module.get_opt_name(l_cop_rec.opt_id,p_effective_date); --'Intersection';
               --
               if p_effective_date between l_cop_rec.effective_start_date
                  and l_cop_rec.effective_end_date then
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
                 p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_parent_entity_result_id,
                 p_number_of_copies               => l_number_of_copies,
                 p_table_alias					  => 'COP',
                 p_table_route_id                 => l_table_route_id,
                 p_information1     => l_cop_rec.oipl_id,
                 p_information2     => l_cop_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_cop_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_cop_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
                 p_information250     => l_cop_rec.actl_prem_id,
                 p_information25     => l_cop_rec.auto_enrt_flag,
                 p_information264     => l_cop_rec.auto_enrt_mthd_rl,
                 p_information111     => l_cop_rec.cop_attribute1,
                 p_information120     => l_cop_rec.cop_attribute10,
                 p_information121     => l_cop_rec.cop_attribute11,
                 p_information122     => l_cop_rec.cop_attribute12,
                 p_information123     => l_cop_rec.cop_attribute13,
                 p_information124     => l_cop_rec.cop_attribute14,
                 p_information125     => l_cop_rec.cop_attribute15,
                 p_information126     => l_cop_rec.cop_attribute16,
                 p_information127     => l_cop_rec.cop_attribute17,
                 p_information128     => l_cop_rec.cop_attribute18,
                 p_information129     => l_cop_rec.cop_attribute19,
                 p_information112     => l_cop_rec.cop_attribute2,
                 p_information130     => l_cop_rec.cop_attribute20,
                 p_information131     => l_cop_rec.cop_attribute21,
                 p_information132     => l_cop_rec.cop_attribute22,
                 p_information133     => l_cop_rec.cop_attribute23,
                 p_information134     => l_cop_rec.cop_attribute24,
                 p_information135     => l_cop_rec.cop_attribute25,
                 p_information136     => l_cop_rec.cop_attribute26,
                 p_information137     => l_cop_rec.cop_attribute27,
                 p_information138     => l_cop_rec.cop_attribute28,
                 p_information139     => l_cop_rec.cop_attribute29,
                 p_information113     => l_cop_rec.cop_attribute3,
                 p_information140     => l_cop_rec.cop_attribute30,
                 p_information114     => l_cop_rec.cop_attribute4,
                 p_information115     => l_cop_rec.cop_attribute5,
                 p_information116     => l_cop_rec.cop_attribute6,
                 p_information117     => l_cop_rec.cop_attribute7,
                 p_information118     => l_cop_rec.cop_attribute8,
                 p_information119     => l_cop_rec.cop_attribute9,
                 p_information110     => l_cop_rec.cop_attribute_category,
                 p_information26     => l_cop_rec.dflt_enrt_cd,
                 p_information266     => l_cop_rec.dflt_enrt_det_rl,
                 p_information18     => l_cop_rec.dflt_flag,
                 p_information24     => l_cop_rec.drvbl_fctr_apls_rts_flag,
                 p_information22     => l_cop_rec.drvbl_fctr_prtn_elig_flag,
                 p_information20     => l_cop_rec.elig_apls_flag,
                 p_information14     => l_cop_rec.enrt_cd,
                 p_information257     => l_cop_rec.enrt_rl,
                 p_information13     => l_cop_rec.hidden_flag,
                 p_information141     => l_cop_rec.ivr_ident,
                 p_information17     => l_cop_rec.mndtry_flag,
                 p_information268     => l_cop_rec.mndtry_rl,
                 p_information19     => l_cop_rec.oipl_stat_cd,
                 p_information247     => l_cop_rec.opt_id,
                 p_information263     => l_cop_rec.ordr_num,
                 p_information16     => l_cop_rec.pcp_dpnt_dsgn_cd,
                 p_information15     => l_cop_rec.pcp_dsgn_cd,
                 p_information27     => l_cop_rec.per_cvrd_cd,
                 p_information261     => l_cop_rec.pl_id,
                 p_information269     => l_cop_rec.postelcn_edit_rl,
                 p_information23     => l_cop_rec.prtn_elig_ovrid_alwd_flag,
                 p_information267     => l_cop_rec.rqd_perd_enrt_nenrt_rl,
                 p_information29     => l_cop_rec.rqd_perd_enrt_nenrt_uom,
                 p_information293     => l_cop_rec.rqd_perd_enrt_nenrt_val,
                 p_information11     => l_cop_rec.short_code,
                 p_information12     => l_cop_rec.short_name,
                 p_information21     => l_cop_rec.trk_inelig_per_flag,
                 p_information185     => l_cop_rec.url_ref_name,
                 p_information28     => l_cop_rec.vrfy_fmly_mmbr_cd,
                 p_information270     => l_cop_rec.vrfy_fmly_mmbr_rl,
                 p_INFORMATION198     => l_cop_rec.SUSP_IF_CTFN_NOT_PRVD_FLAG,
                 p_INFORMATION197     => l_cop_rec.CTFN_DETERMINE_CD,
                 p_information265     => l_cop_rec.object_version_number,
                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
                 --

                 if l_out_cop_result_id is null then
                   l_out_cop_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                    l_out_cop_result_id := l_copy_entity_result_id ;
                 end if;
                 --
				  if (l_cop_rec.auto_enrt_mthd_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.auto_enrt_mthd_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_cop_rec.dflt_enrt_det_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.dflt_enrt_det_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_cop_rec.enrt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.enrt_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_cop_rec.mndtry_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.mndtry_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_cop_rec.postelcn_edit_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.postelcn_edit_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_cop_rec.rqd_perd_enrt_nenrt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.rqd_perd_enrt_nenrt_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

				  if (l_cop_rec.vrfy_fmly_mmbr_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_cop_rec.vrfy_fmly_mmbr_rl
							,p_business_group_id        => l_cop_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

                 --
              end loop;

              -- Create children of OIPL only
              -- if OIPL is created
              --
              if l_out_cop_result_id is not null then

              -- ------------------------------------------------------------------------
              -- Eligibility Profiles
              -- ------------------------------------------------------------------------
              ben_plan_design_elpro_module.create_elpro_results
                 (
                   p_validate                     => p_validate
                  ,p_copy_entity_result_id        => l_out_cop_result_id
                  ,p_copy_entity_txn_id           => p_copy_entity_txn_id
                  ,p_pgm_id                       => null
                  ,p_ptip_id                      => null
                  ,p_plip_id                      => null
                  ,p_pl_id                        => null
                  ,p_oipl_id                      => l_oipl_id
                  ,p_business_group_id            => p_business_group_id
                  ,p_number_of_copies             => p_number_of_copies
                  ,p_object_version_number        => l_object_version_number
                  ,p_effective_date               => p_effective_date
                  ,p_parent_entity_result_id      => l_out_cop_result_id
                 );
              --
              -- ------------------------------------------------------------------------
              -- Standard Rates ,Flex Credits at Oipl level
              -- ------------------------------------------------------------------------
              ben_pd_rate_and_cvg_module.create_rate_results
                (
                  p_validate                   => p_validate
                 ,p_copy_entity_result_id      => l_out_cop_result_id
                 ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                 ,p_pgm_id                     => null
                 ,p_ptip_id                    => null
                 ,p_plip_id                    => null
                 ,p_pl_id                      => null
                 ,p_oipl_id                    => l_oipl_id
                 ,p_oiplip_id                  => null
                 ,p_cmbn_plip_id               => null
                 ,p_cmbn_ptip_id               => null
                 ,p_cmbn_ptip_opt_id           => null
                 ,p_business_group_id          => p_business_group_id
                 ,p_number_of_copies             => p_number_of_copies
                 ,p_object_version_number      => l_object_version_number
                 ,p_effective_date             => p_effective_date
                 ,p_parent_entity_result_id      => l_out_cop_result_id
                 ) ;

              -- ------------------------------------------------------------------------
              -- Coverage Calculations OIPL Level
              -- ------------------------------------------------------------------------

              ben_pd_rate_and_cvg_module.create_coverage_results
                (
                  p_validate                   => p_validate
                 ,p_copy_entity_result_id      => l_out_cop_result_id
                 ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                 ,p_plip_id                    => null
                 ,p_pl_id                      => null
                 ,p_oipl_id                    => l_oipl_id
                 ,p_business_group_id          => p_business_group_id
                 ,p_number_of_copies           => p_number_of_copies
                 ,p_object_version_number      => l_object_version_number
                 ,p_effective_date             => p_effective_date
                 ,p_parent_entity_result_id    => l_out_cop_result_id
               ) ;

              -- ------------------------------------------------------------------------
              -- Actual Premiums - OIPL Level
              -- ------------------------------------------------------------------------

              ben_pd_rate_and_cvg_module.create_premium_results
              (
                 p_validate                => p_validate
                ,p_copy_entity_result_id   => l_out_cop_result_id
                ,p_copy_entity_txn_id      => p_copy_entity_txn_id
                ,p_pl_id                   => null
                ,p_oipl_id                 => l_oipl_id
                ,p_business_group_id       => p_business_group_id
                ,p_number_of_copies        => p_number_of_copies
                ,p_object_version_number   => l_object_version_number
                ,p_effective_date          => p_effective_date
                ,p_parent_entity_result_id => l_out_cop_result_id
             ) ;

             ---------------------------------------------------------------
             -- START OF BEN_DSGN_RQMT_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_ddr1_from_parent(l_OIPL_ID) loop
                --
                l_mirror_src_entity_result_id := l_out_cop_result_id ;

                --
                l_dsgn_rqmt_id := l_parent_rec.dsgn_rqmt_id ;
                --
                --
                l_ddr1_dsgn_rqmt_esd := null;
                --
                for l_ddr_rec in c_ddr1(l_parent_rec.dsgn_rqmt_id,l_mirror_src_entity_result_id,'DDR') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('DDR');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := hr_general.decode_lookup('BEN_GRP_RLSHP',l_ddr_rec.grp_rlshp_cd); --'Intersection';
                  --
                  if p_effective_date between l_ddr_rec.effective_start_date
                     and l_ddr_rec.effective_end_date then
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
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					  => 'DDR',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_ddr_rec.dsgn_rqmt_id,
                    p_information2     => l_ddr_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_ddr_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_ddr_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information13     => l_ddr_rec.cvr_all_elig_flag,
                    p_information111     => l_ddr_rec.ddr_attribute1,
                    p_information120     => l_ddr_rec.ddr_attribute10,
                    p_information121     => l_ddr_rec.ddr_attribute11,
                    p_information122     => l_ddr_rec.ddr_attribute12,
                    p_information123     => l_ddr_rec.ddr_attribute13,
                    p_information124     => l_ddr_rec.ddr_attribute14,
                    p_information125     => l_ddr_rec.ddr_attribute15,
                    p_information126     => l_ddr_rec.ddr_attribute16,
                    p_information127     => l_ddr_rec.ddr_attribute17,
                    p_information128     => l_ddr_rec.ddr_attribute18,
                    p_information129     => l_ddr_rec.ddr_attribute19,
                    p_information112     => l_ddr_rec.ddr_attribute2,
                    p_information130     => l_ddr_rec.ddr_attribute20,
                    p_information131     => l_ddr_rec.ddr_attribute21,
                    p_information132     => l_ddr_rec.ddr_attribute22,
                    p_information133     => l_ddr_rec.ddr_attribute23,
                    p_information134     => l_ddr_rec.ddr_attribute24,
                    p_information135     => l_ddr_rec.ddr_attribute25,
                    p_information136     => l_ddr_rec.ddr_attribute26,
                    p_information137     => l_ddr_rec.ddr_attribute27,
                    p_information138     => l_ddr_rec.ddr_attribute28,
                    p_information139     => l_ddr_rec.ddr_attribute29,
                    p_information113     => l_ddr_rec.ddr_attribute3,
                    p_information140     => l_ddr_rec.ddr_attribute30,
                    p_information114     => l_ddr_rec.ddr_attribute4,
                    p_information115     => l_ddr_rec.ddr_attribute5,
                    p_information116     => l_ddr_rec.ddr_attribute6,
                    p_information117     => l_ddr_rec.ddr_attribute7,
                    p_information118     => l_ddr_rec.ddr_attribute8,
                    p_information119     => l_ddr_rec.ddr_attribute9,
                    p_information110     => l_ddr_rec.ddr_attribute_category,
                    p_information15     => l_ddr_rec.dsgn_typ_cd,
                    p_information14     => l_ddr_rec.grp_rlshp_cd,
                    p_information262     => l_ddr_rec.mn_dpnts_rqd_num,
                    p_information263     => l_ddr_rec.mx_dpnts_alwd_num,
                    p_information11     => l_ddr_rec.no_mn_num_dfnd_flag,
                    p_information12     => l_ddr_rec.no_mx_num_dfnd_flag,
                    p_information258     => l_ddr_rec.oipl_id,
                    p_information247     => l_ddr_rec.opt_id,
                    p_information261     => l_ddr_rec.pl_id,
                    p_information265     => l_ddr_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_ddr_result_id is null then
                      l_out_ddr_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_ddr_result_id := l_copy_entity_result_id ;
                    end if;
                    --

                    -- To pass as effective date while creating the
                    -- non date-tracked child records
                    if l_ddr1_dsgn_rqmt_esd is null then
                      l_ddr1_dsgn_rqmt_esd := l_ddr_rec.EFFECTIVE_START_DATE;
                    end if;

                 end loop;
                 --
             ---------------------------------------------------------------
             -- START OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_drr1_from_parent(l_DSGN_RQMT_ID) loop
                --
                l_mirror_src_entity_result_id := l_out_ddr_result_id ;

                --
                l_dsgn_rqmt_rlshp_typ_id := l_parent_rec.dsgn_rqmt_rlshp_typ_id ;
                --
                for l_drr_rec in c_drr1(l_parent_rec.dsgn_rqmt_rlshp_typ_id,l_mirror_src_entity_result_id,'DRR') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('DRR');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := hr_general.decode_lookup('CONTACT',l_drr_rec.rlshp_typ_cd); --'Intersection';
                  --
                  l_result_type_cd := 'DISPLAY';
                    --
                  l_copy_entity_result_id := null;
                  l_object_version_number := null;
                  ben_copy_entity_results_api.create_copy_entity_results(
                    p_copy_entity_result_id           => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					  => 'DRR',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_drr_rec.dsgn_rqmt_rlshp_typ_id,
                    p_information2     => null,
                    p_information3     => null,
                    p_information4     => l_drr_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information10     => l_ddr1_dsgn_rqmt_esd,
                    p_information111     => l_drr_rec.drr_attribute1,
                    p_information120     => l_drr_rec.drr_attribute10,
                    p_information121     => l_drr_rec.drr_attribute11,
                    p_information122     => l_drr_rec.drr_attribute12,
                    p_information123     => l_drr_rec.drr_attribute13,
                    p_information124     => l_drr_rec.drr_attribute14,
                    p_information125     => l_drr_rec.drr_attribute15,
                    p_information126     => l_drr_rec.drr_attribute16,
                    p_information127     => l_drr_rec.drr_attribute17,
                    p_information128     => l_drr_rec.drr_attribute18,
                    p_information129     => l_drr_rec.drr_attribute19,
                    p_information112     => l_drr_rec.drr_attribute2,
                    p_information130     => l_drr_rec.drr_attribute20,
                    p_information131     => l_drr_rec.drr_attribute21,
                    p_information132     => l_drr_rec.drr_attribute22,
                    p_information133     => l_drr_rec.drr_attribute23,
                    p_information134     => l_drr_rec.drr_attribute24,
                    p_information135     => l_drr_rec.drr_attribute25,
                    p_information136     => l_drr_rec.drr_attribute26,
                    p_information137     => l_drr_rec.drr_attribute27,
                    p_information138     => l_drr_rec.drr_attribute28,
                    p_information139     => l_drr_rec.drr_attribute29,
                    p_information113     => l_drr_rec.drr_attribute3,
                    p_information140     => l_drr_rec.drr_attribute30,
                    p_information114     => l_drr_rec.drr_attribute4,
                    p_information115     => l_drr_rec.drr_attribute5,
                    p_information116     => l_drr_rec.drr_attribute6,
                    p_information117     => l_drr_rec.drr_attribute7,
                    p_information118     => l_drr_rec.drr_attribute8,
                    p_information119     => l_drr_rec.drr_attribute9,
                    p_information110     => l_drr_rec.drr_attribute_category,
                    p_information260     => l_drr_rec.dsgn_rqmt_id,
                    p_information11     => l_drr_rec.rlshp_typ_cd,
                    p_information265     => l_drr_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_drr_result_id is null then
                      l_out_drr_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_drr_result_id := l_copy_entity_result_id ;
                    end if;
                    --
                 end loop;
                 --
               end loop;
               ---------------------------------------------------------------
               -- END OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
               ---------------------------------------------------------------
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_DSGN_RQMT_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_ELIG_TO_PRTE_RSN_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_peo1_from_parent(l_OIPL_ID) loop
                --
                l_mirror_src_entity_result_id := l_out_cop_result_id ;

                --
                l_elig_to_prte_rsn_id := l_parent_rec.elig_to_prte_rsn_id ;
                --
                for l_peo_rec in c_peo1(l_parent_rec.elig_to_prte_rsn_id,l_mirror_src_entity_result_id,'PEO') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('PEO');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := ben_plan_design_program_module.get_ler_name(l_peo_rec.ler_id,p_effective_date); --'Intersection';
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
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					  => 'PEO',
                    p_table_route_id                 => l_table_route_id,
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
                    p_information12      => l_peo_rec.prtn_eff_end_dt_cd,
                    p_information266     => l_peo_rec.prtn_eff_end_dt_rl,
                    p_information11      => l_peo_rec.prtn_eff_strt_dt_cd,
                    p_information264     => l_peo_rec.prtn_eff_strt_dt_rl,
                    p_information19      => l_peo_rec.prtn_ovridbl_flag,
                    p_information259     => l_peo_rec.ptip_id,
                    p_information18      => l_peo_rec.vrfy_fmly_mmbr_cd,
                    p_information273     => l_peo_rec.vrfy_fmly_mmbr_rl,
                    p_information14      => l_peo_rec.wait_perd_dt_to_use_cd,
                    p_information268     => l_peo_rec.wait_perd_dt_to_use_rl,
                    p_information271     => l_peo_rec.wait_perd_rl,
                    p_information13      => l_peo_rec.wait_perd_uom,
	              p_information267     => l_peo_rec.wait_perd_val,
                    p_information265     => l_peo_rec.object_version_number,
	              p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_peo_result_id is null then
                     l_out_peo_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_peo_result_id := l_copy_entity_result_id ;
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
             -- START OF BEN_LER_CHG_OIPL_ENRT_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_lop_from_parent(l_OIPL_ID) loop
             --
               l_mirror_src_entity_result_id := l_out_cop_result_id ;
               --
               l_ler_chg_oipl_enrt_id := l_parent_rec.ler_chg_oipl_enrt_id ;
               --
               for l_lop_rec in c_lop(l_parent_rec.ler_chg_oipl_enrt_id,l_mirror_src_entity_result_id,'LOP') loop
               --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('LOP');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := ben_plan_design_program_module.get_ler_name(l_lop_rec.ler_id,p_effective_date); --'Intersection';
                 --
                 if p_effective_date between l_lop_rec.effective_start_date
                 and l_lop_rec.effective_end_date then
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
                   p_table_alias					  => 'LOP',
                   p_table_route_id                 => l_table_route_id,
                   p_information1     => l_lop_rec.ler_chg_oipl_enrt_id,
                   p_information2     => l_lop_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_lop_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_lop_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
                   p_information14     => l_lop_rec.auto_enrt_flag,
                   p_information262     => l_lop_rec.auto_enrt_mthd_rl,
                   p_information11     => l_lop_rec.crnt_enrt_prclds_chg_flag,
                   p_information16     => l_lop_rec.dflt_enrt_cd,
                   p_information264     => l_lop_rec.dflt_enrt_rl,
                   p_information12     => l_lop_rec.dflt_flag,
                   p_information15     => l_lop_rec.enrt_cd,
                   p_information263     => l_lop_rec.enrt_rl,
                   p_information257     => l_lop_rec.ler_id,
                   p_information111     => l_lop_rec.lop_attribute1,
                   p_information120     => l_lop_rec.lop_attribute10,
                   p_information121     => l_lop_rec.lop_attribute11,
                   p_information122     => l_lop_rec.lop_attribute12,
                   p_information123     => l_lop_rec.lop_attribute13,
                   p_information124     => l_lop_rec.lop_attribute14,
                   p_information125     => l_lop_rec.lop_attribute15,
                   p_information126     => l_lop_rec.lop_attribute16,
                   p_information127     => l_lop_rec.lop_attribute17,
                   p_information128     => l_lop_rec.lop_attribute18,
                   p_information129     => l_lop_rec.lop_attribute19,
                   p_information112     => l_lop_rec.lop_attribute2,
                   p_information130     => l_lop_rec.lop_attribute20,
                   p_information131     => l_lop_rec.lop_attribute21,
                   p_information132     => l_lop_rec.lop_attribute22,
                   p_information133     => l_lop_rec.lop_attribute23,
                   p_information134     => l_lop_rec.lop_attribute24,
                   p_information135     => l_lop_rec.lop_attribute25,
                   p_information136     => l_lop_rec.lop_attribute26,
                   p_information137     => l_lop_rec.lop_attribute27,
                   p_information138     => l_lop_rec.lop_attribute28,
                   p_information139     => l_lop_rec.lop_attribute29,
                   p_information113     => l_lop_rec.lop_attribute3,
                   p_information140     => l_lop_rec.lop_attribute30,
                   p_information114     => l_lop_rec.lop_attribute4,
                   p_information115     => l_lop_rec.lop_attribute5,
                   p_information116     => l_lop_rec.lop_attribute6,
                   p_information117     => l_lop_rec.lop_attribute7,
                   p_information118     => l_lop_rec.lop_attribute8,
                   p_information119     => l_lop_rec.lop_attribute9,
                   p_information110     => l_lop_rec.lop_attribute_category,
                   p_information258     => l_lop_rec.oipl_id,
                   p_information13     => l_lop_rec.stl_elig_cant_chg_flag,
                   p_information265     => l_lop_rec.object_version_number,
                   p_object_version_number          => l_object_version_number,
                   p_effective_date                 => p_effective_date       );
                 --

                 if l_out_lop_result_id is null then
                   l_out_lop_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_lop_result_id := l_copy_entity_result_id ;
                 end if;
                 --
                 -- Copy Fast Formulas if any are attached to any column --
                 ---------------------------------------------------------------
                 --  AUTO_ENRT_MTHD_RL -----------------
                 ---------------------------------------------------------------

                 if to_char(l_lop_rec.auto_enrt_mthd_rl) is not null then
                 --
                   ben_plan_design_program_module.create_formula_result
                   (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_lop_rec.auto_enrt_mthd_rl
                    ,p_business_group_id              =>  l_lop_rec.business_group_id
                    ,p_number_of_copies               =>  l_number_of_copies
                    ,p_object_version_number          =>  l_object_version_number
                    ,p_effective_date                 =>  p_effective_date
                 );
                 --
                 end if;

                 ---------------------------------------------------------------
                 --  DFLT_ENRT__RL -----------------
                 ---------------------------------------------------------------

                 if to_char(l_lop_rec.dflt_enrt_rl) is not null then
                 --
                  ben_plan_design_program_module.create_formula_result
                  (
                    p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_lop_rec.dflt_enrt_rl
                   ,p_business_group_id              =>  l_lop_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                 );
                 --
                 end if;

                ---------------------------------------------------------------
                --  ENRT__RL -----------------
                ---------------------------------------------------------------

                if to_char(l_lop_rec.enrt_rl) is not null then
                --
                 ben_plan_design_program_module.create_formula_result
                 (
                   p_validate                       =>  0
                  ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                  ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                  ,p_formula_id                     =>  l_lop_rec.enrt_rl
                  ,p_business_group_id              =>  l_lop_rec.business_group_id
                  ,p_number_of_copies               =>  l_number_of_copies
                  ,p_object_version_number          =>  l_object_version_number
                  ,p_effective_date                 =>  p_effective_date
                 );
                --
                end if;

               end loop;
               --
               for l_lop_rec in c_lop_drp(l_parent_rec.ler_chg_oipl_enrt_id,l_mirror_src_entity_result_id,'LOP') loop
                   create_ler_result (
                      p_validate                       => p_validate
                     ,p_copy_entity_result_id          => l_out_lop_result_id
                     ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                     ,p_ler_id                         => l_lop_rec.ler_id
                     ,p_business_group_id              => p_business_group_id
                     ,p_number_of_copies               => p_number_of_copies
                     ,p_object_version_number          => l_object_version_number
                     ,p_effective_date                 => p_effective_date
                     );
               end loop;
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_LER_CHG_OIPL_ENRT_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_ENRT_CTFN_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_ecf1_from_parent(l_OIPL_ID) loop
                --
                l_mirror_src_entity_result_id := l_out_cop_result_id ;

                --
                l_enrt_ctfn_id := l_parent_rec.enrt_ctfn_id ;
                --
                for l_ecf_rec in c_ecf1(l_parent_rec.enrt_ctfn_id,l_mirror_src_entity_result_id,'ECF') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('ECF');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_ecf_rec.enrt_ctfn_typ_cd); --'Intersection'
                  --
                  if p_effective_date between l_ecf_rec.effective_start_date
                     and l_ecf_rec.effective_end_date then
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
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_table_alias					  => 'ECF',
                    p_number_of_copies               => l_number_of_copies,
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_ecf_rec.enrt_ctfn_id,
                    p_information2     => l_ecf_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_ecf_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_ecf_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information262     => l_ecf_rec.ctfn_rqd_when_rl,
                    p_information111     => l_ecf_rec.ecf_attribute1,
                    p_information120     => l_ecf_rec.ecf_attribute10,
                    p_information121     => l_ecf_rec.ecf_attribute11,
                    p_information122     => l_ecf_rec.ecf_attribute12,
                    p_information123     => l_ecf_rec.ecf_attribute13,
                    p_information124     => l_ecf_rec.ecf_attribute14,
                    p_information125     => l_ecf_rec.ecf_attribute15,
                    p_information126     => l_ecf_rec.ecf_attribute16,
                    p_information127     => l_ecf_rec.ecf_attribute17,
                    p_information128     => l_ecf_rec.ecf_attribute18,
                    p_information129     => l_ecf_rec.ecf_attribute19,
                    p_information112     => l_ecf_rec.ecf_attribute2,
                    p_information130     => l_ecf_rec.ecf_attribute20,
                    p_information131     => l_ecf_rec.ecf_attribute21,
                    p_information132     => l_ecf_rec.ecf_attribute22,
                    p_information133     => l_ecf_rec.ecf_attribute23,
                    p_information134     => l_ecf_rec.ecf_attribute24,
                    p_information135     => l_ecf_rec.ecf_attribute25,
                    p_information136     => l_ecf_rec.ecf_attribute26,
                    p_information137     => l_ecf_rec.ecf_attribute27,
                    p_information138     => l_ecf_rec.ecf_attribute28,
                    p_information139     => l_ecf_rec.ecf_attribute29,
                    p_information113     => l_ecf_rec.ecf_attribute3,
                    p_information140     => l_ecf_rec.ecf_attribute30,
                    p_information114     => l_ecf_rec.ecf_attribute4,
                    p_information115     => l_ecf_rec.ecf_attribute5,
                    p_information116     => l_ecf_rec.ecf_attribute6,
                    p_information117     => l_ecf_rec.ecf_attribute7,
                    p_information118     => l_ecf_rec.ecf_attribute8,
                    p_information119     => l_ecf_rec.ecf_attribute9,
                    p_information110     => l_ecf_rec.ecf_attribute_category,
                    p_information11     => l_ecf_rec.enrt_ctfn_typ_cd,
                    p_information258     => l_ecf_rec.oipl_id,
                    p_information261     => l_ecf_rec.pl_id,
                    p_information256     => l_ecf_rec.plip_id,
                    p_information12     => l_ecf_rec.rqd_flag,
                    p_information265     => l_ecf_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_ecf_result_id is null then
                      l_out_ecf_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_ecf_result_id := l_copy_entity_result_id ;
                    end if;
                    --
                 end loop;
             --
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ENRT_CTFN_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_lre1_from_parent(l_OIPL_ID) loop
                --
                l_mirror_src_entity_result_id := l_out_cop_result_id ;

                --
                l_ler_rqrs_enrt_ctfn_id := l_parent_rec.ler_rqrs_enrt_ctfn_id ;
                --
                for l_lre_rec in c_lre1(l_parent_rec.ler_rqrs_enrt_ctfn_id,l_mirror_src_entity_result_id,'LRE') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('LRE');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := ben_plan_design_program_module.get_ler_name(l_lre_rec.ler_id,p_effective_date); --'Intersection';
                  --
                  if p_effective_date between l_lre_rec.effective_start_date
                     and l_lre_rec.effective_end_date then
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
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					  => 'LRE',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_lre_rec.ler_rqrs_enrt_ctfn_id,
                    p_information2     => l_lre_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_lre_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_lre_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information263     => l_lre_rec.ctfn_rqd_when_rl,
                    p_information11     => l_lre_rec.excld_flag,
                    p_information257     => l_lre_rec.ler_id,
                    p_information111     => l_lre_rec.lre_attribute1,
                    p_information120     => l_lre_rec.lre_attribute10,
                    p_information121     => l_lre_rec.lre_attribute11,
                    p_information122     => l_lre_rec.lre_attribute12,
                    p_information123     => l_lre_rec.lre_attribute13,
                    p_information124     => l_lre_rec.lre_attribute14,
                    p_information125     => l_lre_rec.lre_attribute15,
                    p_information126     => l_lre_rec.lre_attribute16,
                    p_information127     => l_lre_rec.lre_attribute17,
                    p_information128     => l_lre_rec.lre_attribute18,
                    p_information129     => l_lre_rec.lre_attribute19,
                    p_information112     => l_lre_rec.lre_attribute2,
                    p_information130     => l_lre_rec.lre_attribute20,
                    p_information131     => l_lre_rec.lre_attribute21,
                    p_information132     => l_lre_rec.lre_attribute22,
                    p_information133     => l_lre_rec.lre_attribute23,
                    p_information134     => l_lre_rec.lre_attribute24,
                    p_information135     => l_lre_rec.lre_attribute25,
                    p_information136     => l_lre_rec.lre_attribute26,
                    p_information137     => l_lre_rec.lre_attribute27,
                    p_information138     => l_lre_rec.lre_attribute28,
                    p_information139     => l_lre_rec.lre_attribute29,
                    p_information113     => l_lre_rec.lre_attribute3,
                    p_information140     => l_lre_rec.lre_attribute30,
                    p_information114     => l_lre_rec.lre_attribute4,
                    p_information115     => l_lre_rec.lre_attribute5,
                    p_information116     => l_lre_rec.lre_attribute6,
                    p_information117     => l_lre_rec.lre_attribute7,
                    p_information118     => l_lre_rec.lre_attribute8,
                    p_information119     => l_lre_rec.lre_attribute9,
                    p_information110     => l_lre_rec.lre_attribute_category,
                    p_information258     => l_lre_rec.oipl_id,
                    p_information261     => l_lre_rec.pl_id,
                    p_information256     => l_lre_rec.plip_id,
                    p_INFORMATION198     => l_lre_rec.SUSP_IF_CTFN_NOT_PRVD_FLAG,  /* Bug 4089500 */
                    p_INFORMATION197     => l_lre_rec.CTFN_DETERMINE_CD,           /* Bug 4089500 */
                    p_information265     => l_lre_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_lre_result_id is null then
                      l_out_lre_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_lre_result_id := l_copy_entity_result_id ;
                    end if;
                    --
                 end loop;
                 --
                 for l_lre_rec in c_lre1_drp(l_parent_rec.ler_rqrs_enrt_ctfn_id,l_mirror_src_entity_result_id,'LRE') loop
                   ben_plan_design_plan_module.create_ler_result (
                            p_validate                       => p_validate
                           ,p_copy_entity_result_id          => l_out_lre_result_id
                           ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                           ,p_ler_id                         => l_lre_rec.ler_id
                           ,p_business_group_id              => p_business_group_id
                           ,p_number_of_copies             => p_number_of_copies
                           ,p_object_version_number          => l_object_version_number
                           ,p_effective_date                 => p_effective_date
                           );
                 end loop ;

              ---------------------------------------------------------------
              -- START OF BEN_LER_ENRT_CTFN_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_lnc1_from_parent(l_LER_RQRS_ENRT_CTFN_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_lre_result_id ;

                 --
                 l_ler_enrt_ctfn_id := l_parent_rec.ler_enrt_ctfn_id ;
                 --
                 for l_lnc_rec in c_lnc1(l_parent_rec.ler_enrt_ctfn_id,l_mirror_src_entity_result_id,'LNC') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('LNC');
                     fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_lnc_rec.enrt_ctfn_typ_cd); --'Intersection'
                   --
                   if p_effective_date between l_lnc_rec.effective_start_date
                      and l_lnc_rec.effective_end_date then
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
                     p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_alias					  => 'LNC',
                     p_table_route_id                 => l_table_route_id,
                     p_information1     => l_lnc_rec.ler_enrt_ctfn_id,
                     p_information2     => l_lnc_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_lnc_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_lnc_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information258     => l_lnc_rec.ctfn_rqd_when_rl,
                     p_information12     => l_lnc_rec.enrt_ctfn_typ_cd,
                     p_information257     => l_lnc_rec.ler_rqrs_enrt_ctfn_id,
                     p_information111     => l_lnc_rec.lnc_attribute1,
                     p_information120     => l_lnc_rec.lnc_attribute10,
                     p_information121     => l_lnc_rec.lnc_attribute11,
                     p_information122     => l_lnc_rec.lnc_attribute12,
                     p_information123     => l_lnc_rec.lnc_attribute13,
                     p_information124     => l_lnc_rec.lnc_attribute14,
                     p_information125     => l_lnc_rec.lnc_attribute15,
                     p_information126     => l_lnc_rec.lnc_attribute16,
                     p_information127     => l_lnc_rec.lnc_attribute17,
                     p_information128     => l_lnc_rec.lnc_attribute18,
                     p_information129     => l_lnc_rec.lnc_attribute19,
                     p_information112     => l_lnc_rec.lnc_attribute2,
                     p_information130     => l_lnc_rec.lnc_attribute20,
                     p_information131     => l_lnc_rec.lnc_attribute21,
                     p_information132     => l_lnc_rec.lnc_attribute22,
                     p_information133     => l_lnc_rec.lnc_attribute23,
                     p_information134     => l_lnc_rec.lnc_attribute24,
                     p_information135     => l_lnc_rec.lnc_attribute25,
                     p_information136     => l_lnc_rec.lnc_attribute26,
                     p_information137     => l_lnc_rec.lnc_attribute27,
                     p_information138     => l_lnc_rec.lnc_attribute28,
                     p_information139     => l_lnc_rec.lnc_attribute29,
                     p_information113     => l_lnc_rec.lnc_attribute3,
                     p_information140     => l_lnc_rec.lnc_attribute30,
                     p_information114     => l_lnc_rec.lnc_attribute4,
                     p_information115     => l_lnc_rec.lnc_attribute5,
                     p_information116     => l_lnc_rec.lnc_attribute6,
                     p_information117     => l_lnc_rec.lnc_attribute7,
                     p_information118     => l_lnc_rec.lnc_attribute8,
                     p_information119     => l_lnc_rec.lnc_attribute9,
                     p_information110     => l_lnc_rec.lnc_attribute_category,
                     p_information11     => l_lnc_rec.rqd_flag,
                     p_information265     => l_lnc_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                     --

                     if l_out_lnc_result_id is null then
                        l_out_lnc_result_id := l_copy_entity_result_id;
                      end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_lnc_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_LER_ENRT_CTFN_F ----------------------
             ---------------------------------------------------------------
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_LER_RQRS_ENRT_CTFN_F ----------------------
             ---------------------------------------------------------------

             for l_parent_rec  in c_opt1_from_parent(l_OIPL_ID) loop
               create_opt_result
               ( p_validate                       => p_validate
                ,p_copy_entity_result_id          => l_out_cop_result_id
                ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                ,p_opt_id                         => l_parent_rec.opt_id
                ,p_business_group_id              => p_business_group_id
                ,p_number_of_copies               => p_number_of_copies
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => p_effective_date
                ,p_parent_entity_result_id        => l_out_cop_result_id
                ,p_no_dup_rslt                    => p_no_dup_rslt
                );
             end loop;

         end if;
         ---------------------------------------------------------------
         -- END OF BEN_OIPL_F ----------------------
         ---------------------------------------------------------------
  --
end create_oipl_result ;
--
procedure create_opt_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_opt_id                         in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
    ) is
    --
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_popl_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_result_type_cd   varchar2(30) :=  'DISPLAY' ;
    -- Cursor to get mirror_src_entity_result_id
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
    select copy_entity_result_id mirror_src_entity_result_id
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where cpe.information1        = c_parent_pk_id
    and   cpe.result_type_cd      = l_result_type_cd
    and   cpe.copy_entity_txn_id  = c_copy_entity_txn_id
--    and   cpe.table_route_id      = trt.table_route_id
    and   cpe.table_alias         = c_parent_table_alias;
    --
    --
    -- Bug : 3752407 : Global cursor g_table_route will now be used
    -- Cursor to get table_route_id
    --
    -- cursor c_table_route(c_parent_table_alias varchar2) is
    -- select table_route_id
    -- from pqh_table_route trt
    -- where trt.table_alias         = c_parent_table_alias;
    --
   ---------------------------------------------------------------
   -- START OF BEN_OPT_F ----------------------
   ---------------------------------------------------------------
   cursor c_opt1(c_opt_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  opt.*
   from BEN_OPT_F opt
   where  opt.opt_id = c_opt_id
     -- and opt.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_OPT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_opt_id
         -- and information4 = opt.business_group_id
           and information2 = opt.effective_start_date
           and information3 = opt.effective_end_date
        );

   --
   --Mapping for CWB Group_pl_id
   --
   cursor c_grp_opt_name (p_group_opt_id in number) is
   select name group_opt_name
   from ben_opt_f
   where opt_id = p_group_opt_id
     and p_effective_date between effective_start_date and effective_end_date;

   l_mapping_id         number;
   l_mapping_name       varchar2(600);
   l_mapping_column_name1 pqh_attributes.attribute_name%type;
   l_mapping_column_name2 pqh_attributes.attribute_name%type;

   -- Mapping end for CWB

    l_opt_id                 number(15);
    l_out_opt_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_OPT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSGN_RQMT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ddr2_from_parent(c_OPT_ID number) is
   select  dsgn_rqmt_id
   from BEN_DSGN_RQMT_F
   where  OPT_ID = c_OPT_ID ;
   --
   cursor c_ddr2(c_dsgn_rqmt_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2) is
   select  ddr.*
   from BEN_DSGN_RQMT_F ddr
   where  ddr.dsgn_rqmt_id = c_dsgn_rqmt_id
     -- and ddr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGN_RQMT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgn_rqmt_id
         -- and information4 = ddr.business_group_id
           and information2 = ddr.effective_start_date
           and information3 = ddr.effective_end_date
        );

   l_ddr2_dsgn_rqmt_esd ben_dsgn_rqmt_f.effective_start_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_DSGN_RQMT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_TYP_OPT_TYP_F ----------------------
   ---------------------------------------------------------------
   cursor c_pon1_from_parent(c_OPT_ID number) is
   select  pl_typ_opt_typ_id
   from BEN_PL_TYP_OPT_TYP_F
   where  OPT_ID = c_OPT_ID ;
   --
   cursor c_pon1(c_pl_typ_opt_typ_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  pon.*
   from BEN_PL_TYP_OPT_TYP_F pon
   where  pon.pl_typ_opt_typ_id = c_pl_typ_opt_typ_id
     -- and pon.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_TYP_OPT_TYP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_typ_opt_typ_id
         -- and information4 = pon.business_group_id
           and information2 = pon.effective_start_date
           and information3 = pon.effective_end_date
        );
    l_pl_typ_opt_typ_id                 number(15);
    l_out_pon_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_TYP_OPT_TYP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
   ---------------------------------------------------------------
   cursor c_drr2_from_parent(c_DSGN_RQMT_ID number) is
   select  dsgn_rqmt_rlshp_typ_id
   from BEN_DSGN_RQMT_RLSHP_TYP
   where  DSGN_RQMT_ID = c_DSGN_RQMT_ID ;
   --
   cursor c_drr2(c_dsgn_rqmt_rlshp_typ_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  drr.*
   from BEN_DSGN_RQMT_RLSHP_TYP drr
   where  drr.dsgn_rqmt_rlshp_typ_id = c_dsgn_rqmt_rlshp_typ_id
     -- and drr.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGN_RQMT_RLSHP_TYP'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgn_rqmt_rlshp_typ_id
         -- and information4 = drr.business_group_id
        );
   ---------------------------------------------------------------
   -- END OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------
   cursor c_ptp1_from_parent(c_PL_TYP_OPT_TYP_ID number) is
   select  distinct pl_typ_id
   from BEN_PL_TYP_OPT_TYP_F
   where  PL_TYP_OPT_TYP_ID = c_PL_TYP_OPT_TYP_ID ;
   --
   ---------------------------------------------------------------
   -- END OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------

   cursor c_opt_exists(c_opt_id               number,
                       c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
--    and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_opt_id;

   l_dummy                          varchar2(1);

   l_mirror_src_entity_result_id    number(15);
   l_parent_entity_result_id        number(15);
   l_table_route_id                 number(15);
   l_information5                   ben_copy_entity_results.information5%TYPE;
   l_number_of_copies               number := p_number_of_copies ;
   --
   L_ELIG_TO_PRTE_RSN_ID            number(15);

   L_LER_RQRS_ENRT_CTFN_ID          number(15);
   L_ENRT_CTFN_ID                   number(15);
   L_LER_ENRT_CTFN_ID               number(15);
   L_PL_TYP_ID                      number(15);
   L_OUT_PTP_RESULT_ID              number(15);
   --
   L_DSGN_RQMT_ID                   number(15);
   L_OUT_DDR_RESULT_ID              number(15);
   L_DSGN_RQMT_RLSHP_TYP_ID         number(15);
   L_OUT_DRR_RESULT_ID              number(15);
   l_group_opt_id                   NUMBER(15);

begin
  --
        ---------------------------------------------------------------
        -- START OF BEN_OPT_F ----------------------
        ---------------------------------------------------------------

             if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
               ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
             end if;

             if p_no_dup_rslt = 'Y' OR
                ben_plan_design_program_module.g_pdw_allow_dup_rslt =
                  ben_plan_design_program_module.g_pdw_no_dup_rslt then
               open c_opt_exists(p_opt_id,'OPT');
               fetch c_opt_exists into l_dummy;
               if c_opt_exists%found then
                 close c_opt_exists;
                 return;
               end if;
               close c_opt_exists;
             end if;

             l_mirror_src_entity_result_id := p_copy_entity_result_id;
             l_parent_entity_result_id := p_parent_entity_result_id;

                l_opt_id := p_opt_id ;
                --
                for l_opt_rec in c_opt1(l_opt_id,l_mirror_src_entity_result_id,'OPT') loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('OPT');
                    fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := l_opt_rec.name; --'Intersection';
                  --
                  if p_effective_date between l_opt_rec.effective_start_date
                     and l_opt_rec.effective_end_date then
                   --
                     l_result_type_cd := 'DISPLAY';
                  else
                     l_result_type_cd := 'NO DISPLAY';
                  end if;
                  --
                  -- mapping for CWB plan
                  --
                  -- Bug 4665663 - Map only if it is not a Group Option
                  l_group_opt_id := NULL;
                  --
                  if (l_opt_rec.group_opt_id IS NOT NULL and
                          l_opt_rec.opt_id <> l_opt_rec.group_opt_id) then
                    --
                    open c_grp_opt_name(l_opt_rec.group_opt_id);
                    fetch c_grp_opt_name into l_mapping_name;
                    close c_grp_opt_name;
                    --
                    l_group_opt_id := l_opt_rec.group_opt_id; -- 4665663
                    --
                    --To set user friendly labels on the mapping page
                    --
                    l_mapping_column_name1 := null;
                    l_mapping_column_name2 :=null;
                    BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                  l_mapping_column_name1,
                                  l_mapping_column_name2,
                                  p_copy_entity_txn_id);
                  --
                  end if;
                  --
                  l_copy_entity_result_id := null;
                  l_object_version_number := null;
                  --
                  ben_copy_entity_results_api.create_copy_entity_results(
                    p_copy_entity_result_id           => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => null, -- Hide BEN_OPT_F for HGrid
                    p_number_of_copies               => l_number_of_copies,
                    p_table_alias					 => 'OPT',
                    p_table_route_id                 => l_table_route_id,
                    p_information1     => l_opt_rec.opt_id,
                    p_information2     => l_opt_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_opt_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_opt_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
                    p_information249     => l_opt_rec.cmbn_ptip_opt_id,
                    p_information13      => l_opt_rec.component_reason,
                    -- tilak cwb pl copy fix
                    p_information264     => l_opt_rec.group_opt_id,
                    -- Data for MAPPING columns.
                    p_information173     => l_mapping_name,
                    p_information174     => l_group_opt_id,
                    p_information181     => l_mapping_column_name1,
                    p_information182     => l_mapping_column_name2,
                    -- END other product Mapping columns.
                    p_information14      => l_opt_rec.invk_wv_opt_flag,
                    p_information141     => l_opt_rec.mapping_table_name,
                    p_information257     => l_opt_rec.mapping_table_pk_id,
                    p_information170     => l_opt_rec.name,
                    p_information111     => l_opt_rec.opt_attribute1,
                    p_information120     => l_opt_rec.opt_attribute10,
                    p_information121     => l_opt_rec.opt_attribute11,
                    p_information122     => l_opt_rec.opt_attribute12,
                    p_information123     => l_opt_rec.opt_attribute13,
                    p_information124     => l_opt_rec.opt_attribute14,
                    p_information125     => l_opt_rec.opt_attribute15,
                    p_information126     => l_opt_rec.opt_attribute16,
                    p_information127     => l_opt_rec.opt_attribute17,
                    p_information128     => l_opt_rec.opt_attribute18,
                    p_information129     => l_opt_rec.opt_attribute19,
                    p_information112     => l_opt_rec.opt_attribute2,
                    p_information130     => l_opt_rec.opt_attribute20,
                    p_information131     => l_opt_rec.opt_attribute21,
                    p_information132     => l_opt_rec.opt_attribute22,
                    p_information133     => l_opt_rec.opt_attribute23,
                    p_information134     => l_opt_rec.opt_attribute24,
                    p_information135     => l_opt_rec.opt_attribute25,
                    p_information136     => l_opt_rec.opt_attribute26,
                    p_information137     => l_opt_rec.opt_attribute27,
                    p_information138     => l_opt_rec.opt_attribute28,
                    p_information139     => l_opt_rec.opt_attribute29,
                    p_information113     => l_opt_rec.opt_attribute3,
                    p_information140     => l_opt_rec.opt_attribute30,
                    p_information114     => l_opt_rec.opt_attribute4,
                    p_information115     => l_opt_rec.opt_attribute5,
                    p_information116     => l_opt_rec.opt_attribute6,
                    p_information117     => l_opt_rec.opt_attribute7,
                    p_information118     => l_opt_rec.opt_attribute8,
                    p_information119     => l_opt_rec.opt_attribute9,
                    p_information110     => l_opt_rec.opt_attribute_category,
                    p_information258     => l_opt_rec.rqd_perd_enrt_nenrt_rl,
                    p_information15      => l_opt_rec.rqd_perd_enrt_nenrt_uom,
                    p_information259     => l_opt_rec.rqd_perd_enrt_nenrt_val,
                    p_information11      => l_opt_rec.short_code,
                    p_information12      => l_opt_rec.short_name,
                    p_information16      => l_opt_rec.legislation_code,          /* Bug 3939490 */
                    p_information17      => l_opt_rec.legislation_subgroup,      /* Bug 3939490 */
                    p_information265     => l_opt_rec.object_version_number,
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date       );
                    --

                    if l_out_opt_result_id is null then
                      l_out_opt_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_opt_result_id := l_copy_entity_result_id ;
                    end if;
                    --
                    if (l_opt_rec.rqd_perd_enrt_nenrt_rl is not null) then
		      ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id         => l_copy_entity_result_id
			,p_copy_entity_txn_id            => p_copy_entity_txn_id
			,p_formula_id                    => l_opt_rec.rqd_perd_enrt_nenrt_rl
			,p_business_group_id             => l_opt_rec.business_group_id
			,p_number_of_copies              => l_number_of_copies
			,p_object_version_number         => l_object_version_number
			,p_effective_date                => p_effective_date);
	   	    end if;

              end loop;

              -- Create children of OPT only
              -- if OPT is created
              --
              if l_out_opt_result_id is not null then

               --
               -- ------------------------------------------------------------------------
               -- Standard Rates ,Flex Credits at Option level
               -- ------------------------------------------------------------------------
                ben_pd_rate_and_cvg_module.create_rate_results
                (
                  p_validate                   => p_validate
                 ,p_copy_entity_result_id      => l_out_opt_result_id
                 ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                 ,p_pgm_id                     => null
                 ,p_ptip_id                    => null
                 ,p_plip_id                    => null
                 ,p_pl_id                      => null
                 ,p_oipl_id                    => null
                 ,p_oiplip_id                  => null
                 ,p_cmbn_plip_id               => null
                 ,p_cmbn_ptip_id               => null
                 ,p_cmbn_ptip_opt_id           => null
                 ,p_business_group_id          => p_business_group_id
                 ,p_number_of_copies           => l_number_of_copies
                 ,p_object_version_number      => l_object_version_number
                 ,p_effective_date             => p_effective_date
                 ,p_parent_entity_result_id    => l_parent_entity_result_id
                  --
                 ,p_opt_id                     => l_opt_id
                  --
                  ) ;
               --
               ---------------------------------------------------------------
               -- START OF BEN_DSGN_RQMT_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_ddr2_from_parent(l_OPT_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_opt_result_id ;

                  --
                  l_dsgn_rqmt_id := l_parent_rec.dsgn_rqmt_id ;
                  --
                  l_ddr2_dsgn_rqmt_esd := null;
                  --
                  for l_ddr_rec in c_ddr2(l_parent_rec.dsgn_rqmt_id,l_mirror_src_entity_result_id,'DDR') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('DDR');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := hr_general.decode_lookup('BEN_GRP_RLSHP',l_ddr_rec.grp_rlshp_cd); --'Intersection';
                    --
                    if p_effective_date between l_ddr_rec.effective_start_date
                       and l_ddr_rec.effective_end_date then
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
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_parent_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'DDR',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_ddr_rec.dsgn_rqmt_id,
                      p_information2     => l_ddr_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_ddr_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_ddr_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information13     => l_ddr_rec.cvr_all_elig_flag,
                      p_information111     => l_ddr_rec.ddr_attribute1,
                      p_information120     => l_ddr_rec.ddr_attribute10,
                      p_information121     => l_ddr_rec.ddr_attribute11,
                      p_information122     => l_ddr_rec.ddr_attribute12,
                      p_information123     => l_ddr_rec.ddr_attribute13,
                      p_information124     => l_ddr_rec.ddr_attribute14,
                      p_information125     => l_ddr_rec.ddr_attribute15,
                      p_information126     => l_ddr_rec.ddr_attribute16,
                      p_information127     => l_ddr_rec.ddr_attribute17,
                      p_information128     => l_ddr_rec.ddr_attribute18,
                      p_information129     => l_ddr_rec.ddr_attribute19,
                      p_information112     => l_ddr_rec.ddr_attribute2,
                      p_information130     => l_ddr_rec.ddr_attribute20,
                      p_information131     => l_ddr_rec.ddr_attribute21,
                      p_information132     => l_ddr_rec.ddr_attribute22,
                      p_information133     => l_ddr_rec.ddr_attribute23,
                      p_information134     => l_ddr_rec.ddr_attribute24,
                      p_information135     => l_ddr_rec.ddr_attribute25,
                      p_information136     => l_ddr_rec.ddr_attribute26,
                      p_information137     => l_ddr_rec.ddr_attribute27,
                      p_information138     => l_ddr_rec.ddr_attribute28,
                      p_information139     => l_ddr_rec.ddr_attribute29,
                      p_information113     => l_ddr_rec.ddr_attribute3,
                      p_information140     => l_ddr_rec.ddr_attribute30,
                      p_information114     => l_ddr_rec.ddr_attribute4,
                      p_information115     => l_ddr_rec.ddr_attribute5,
                      p_information116     => l_ddr_rec.ddr_attribute6,
                      p_information117     => l_ddr_rec.ddr_attribute7,
                      p_information118     => l_ddr_rec.ddr_attribute8,
                      p_information119     => l_ddr_rec.ddr_attribute9,
                      p_information110     => l_ddr_rec.ddr_attribute_category,
                      p_information15     => l_ddr_rec.dsgn_typ_cd,
                      p_information14     => l_ddr_rec.grp_rlshp_cd,
                      p_information262     => l_ddr_rec.mn_dpnts_rqd_num,
                      p_information263     => l_ddr_rec.mx_dpnts_alwd_num,
                      p_information11     => l_ddr_rec.no_mn_num_dfnd_flag,
                      p_information12     => l_ddr_rec.no_mx_num_dfnd_flag,
                      p_information258     => l_ddr_rec.oipl_id,
                      p_information247     => l_ddr_rec.opt_id,
                      p_information261     => l_ddr_rec.pl_id,
                      p_information265     => l_ddr_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_ddr_result_id is null then
                        l_out_ddr_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_ddr_result_id := l_copy_entity_result_id ;
                      end if;
                      --

                      -- To pass as effective date while creating the
                      -- non date-tracked child records
                      if l_ddr2_dsgn_rqmt_esd is null then
                        l_ddr2_dsgn_rqmt_esd := l_ddr_rec.EFFECTIVE_START_DATE;
                      end if;

                   end loop;
                   --
               ---------------------------------------------------------------
               -- START OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_drr2_from_parent(l_DSGN_RQMT_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_ddr_result_id ;

                  --
                  l_dsgn_rqmt_rlshp_typ_id := l_parent_rec.dsgn_rqmt_rlshp_typ_id ;
                  --
                  for l_drr_rec in c_drr2(l_parent_rec.dsgn_rqmt_rlshp_typ_id,l_mirror_src_entity_result_id,'DRR') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('DRR');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := hr_general.decode_lookup('CONTACT',l_drr_rec.rlshp_typ_cd); --'Intersection';
                    --
                    l_result_type_cd := 'DISPLAY';
                      --
                    l_copy_entity_result_id := null;
                    l_object_version_number := null;
                    ben_copy_entity_results_api.create_copy_entity_results(
                      p_copy_entity_result_id           => l_copy_entity_result_id,
                      p_copy_entity_txn_id             => p_copy_entity_txn_id,
                      p_result_type_cd                 => l_result_type_cd,
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'DRR',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_drr_rec.dsgn_rqmt_rlshp_typ_id,
                      p_information2     => null,
                      p_information3     => null,
                      p_information4     => l_drr_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information10     => l_ddr2_dsgn_rqmt_esd,
                      p_information111     => l_drr_rec.drr_attribute1,
                      p_information120     => l_drr_rec.drr_attribute10,
                      p_information121     => l_drr_rec.drr_attribute11,
                      p_information122     => l_drr_rec.drr_attribute12,
                      p_information123     => l_drr_rec.drr_attribute13,
                      p_information124     => l_drr_rec.drr_attribute14,
                      p_information125     => l_drr_rec.drr_attribute15,
                      p_information126     => l_drr_rec.drr_attribute16,
                      p_information127     => l_drr_rec.drr_attribute17,
                      p_information128     => l_drr_rec.drr_attribute18,
                      p_information129     => l_drr_rec.drr_attribute19,
                      p_information112     => l_drr_rec.drr_attribute2,
                      p_information130     => l_drr_rec.drr_attribute20,
                      p_information131     => l_drr_rec.drr_attribute21,
                      p_information132     => l_drr_rec.drr_attribute22,
                      p_information133     => l_drr_rec.drr_attribute23,
                      p_information134     => l_drr_rec.drr_attribute24,
                      p_information135     => l_drr_rec.drr_attribute25,
                      p_information136     => l_drr_rec.drr_attribute26,
                      p_information137     => l_drr_rec.drr_attribute27,
                      p_information138     => l_drr_rec.drr_attribute28,
                      p_information139     => l_drr_rec.drr_attribute29,
                      p_information113     => l_drr_rec.drr_attribute3,
                      p_information140     => l_drr_rec.drr_attribute30,
                      p_information114     => l_drr_rec.drr_attribute4,
                      p_information115     => l_drr_rec.drr_attribute5,
                      p_information116     => l_drr_rec.drr_attribute6,
                      p_information117     => l_drr_rec.drr_attribute7,
                      p_information118     => l_drr_rec.drr_attribute8,
                      p_information119     => l_drr_rec.drr_attribute9,
                      p_information110     => l_drr_rec.drr_attribute_category,
                      p_information260     => l_drr_rec.dsgn_rqmt_id,
                      p_information11     => l_drr_rec.rlshp_typ_cd,
                      p_information265     => l_drr_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_drr_result_id is null then
                        l_out_drr_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_drr_result_id := l_copy_entity_result_id ;
                      end if;
                      --
                   end loop;
                   --
                 end loop;
               ---------------------------------------------------------------
               -- END OF BEN_DSGN_RQMT_RLSHP_TYP ----------------------
               ---------------------------------------------------------------
               end loop;
               ---------------------------------------------------------------
               -- END OF BEN_DSGN_RQMT_F ----------------------
               ---------------------------------------------------------------
               ---------------------------------------------------------------
               -- START OF BEN_PL_TYP_OPT_TYP_F ----------------------
               ---------------------------------------------------------------
               --
               for l_parent_rec  in c_pon1_from_parent(l_OPT_ID) loop
                  --
                  l_mirror_src_entity_result_id := l_out_opt_result_id ;


                  --
                  l_pl_typ_opt_typ_id := l_parent_rec.pl_typ_opt_typ_id ;
                  --
                  for l_pon_rec in c_pon1(l_parent_rec.pl_typ_opt_typ_id,l_mirror_src_entity_result_id,'PON') loop
                    --
                    l_table_route_id := null ;
                    open ben_plan_design_program_module.g_table_route('PON');
                      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                    close ben_plan_design_program_module.g_table_route ;
                    --
                    l_information5  := hr_general.decode_lookup('BEN_OPT_TYP',l_pon_rec.pl_typ_opt_typ_cd); --'Intersection';
                    --
                    if p_effective_date between l_pon_rec.effective_start_date
                       and l_pon_rec.effective_end_date then
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
                      p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
                      p_parent_entity_result_id        => l_parent_entity_result_id,
                      p_number_of_copies               => l_number_of_copies,
                      p_table_alias					 => 'PON',
                      p_table_route_id                 => l_table_route_id,
                      p_information1     => l_pon_rec.pl_typ_opt_typ_id,
                      p_information2     => l_pon_rec.EFFECTIVE_START_DATE,
                      p_information3     => l_pon_rec.EFFECTIVE_END_DATE,
                      p_information4     => l_pon_rec.business_group_id,
                      p_information5     => l_information5 , -- 9999 put name for h-grid
                      p_information247     => l_pon_rec.opt_id,
                      p_information248     => l_pon_rec.pl_typ_id,
                      p_information11     => l_pon_rec.pl_typ_opt_typ_cd,
                      p_information111     => l_pon_rec.pon_attribute1,
                      p_information120     => l_pon_rec.pon_attribute10,
                      p_information121     => l_pon_rec.pon_attribute11,
                      p_information122     => l_pon_rec.pon_attribute12,
                      p_information123     => l_pon_rec.pon_attribute13,
                      p_information124     => l_pon_rec.pon_attribute14,
                      p_information125     => l_pon_rec.pon_attribute15,
                      p_information126     => l_pon_rec.pon_attribute16,
                      p_information127     => l_pon_rec.pon_attribute17,
                      p_information128     => l_pon_rec.pon_attribute18,
                      p_information129     => l_pon_rec.pon_attribute19,
                      p_information112     => l_pon_rec.pon_attribute2,
                      p_information130     => l_pon_rec.pon_attribute20,
                      p_information131     => l_pon_rec.pon_attribute21,
                      p_information132     => l_pon_rec.pon_attribute22,
                      p_information133     => l_pon_rec.pon_attribute23,
                      p_information134     => l_pon_rec.pon_attribute24,
                      p_information135     => l_pon_rec.pon_attribute25,
                      p_information136     => l_pon_rec.pon_attribute26,
                      p_information137     => l_pon_rec.pon_attribute27,
                      p_information138     => l_pon_rec.pon_attribute28,
                      p_information139     => l_pon_rec.pon_attribute29,
                      p_information113     => l_pon_rec.pon_attribute3,
                      p_information140     => l_pon_rec.pon_attribute30,
                      p_information114     => l_pon_rec.pon_attribute4,
                      p_information115     => l_pon_rec.pon_attribute5,
                      p_information116     => l_pon_rec.pon_attribute6,
                      p_information117     => l_pon_rec.pon_attribute7,
                      p_information118     => l_pon_rec.pon_attribute8,
                      p_information119     => l_pon_rec.pon_attribute9,
            	        p_information110     => l_pon_rec.pon_attribute_category,
                      p_information265     => l_pon_rec.object_version_number,
                      p_object_version_number          => l_object_version_number,
                      p_effective_date                 => p_effective_date       );
                      --

                      if l_out_pon_result_id is null then
                        l_out_pon_result_id := l_copy_entity_result_id;
                      end if;

                      if l_result_type_cd = 'DISPLAY' then
                         l_out_pon_result_id := l_copy_entity_result_id ;
                      end if;
                      --
                   end loop;
                   --
                      ---------------------------------------------------------------
                      -- START OF BEN_PL_TYP_F ----------------------
                      ---------------------------------------------------------------
                      --
                      for l_parent_rec  in c_ptp1_from_parent(l_PL_TYP_OPT_TYP_ID) loop
                        create_pl_typ_result
                        ( p_validate                  => p_validate
                        ,p_copy_entity_result_id      => l_out_pon_result_id
                        ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                        ,p_pl_typ_id                  => l_parent_rec.pl_typ_id
                        ,p_business_group_id          => p_business_group_id
                        ,p_number_of_copies           => p_number_of_copies
                        ,p_object_version_number      => l_object_version_number
                        ,p_effective_date             => p_effective_date
                        ,p_parent_entity_result_id    => l_out_pon_result_id
                        );
                      end loop;
                     ---------------------------------------------------------------
                     -- END OF BEN_PL_TYP_F ----------------------
                     ---------------------------------------------------------------
                 end loop;
              ---------------------------------------------------------------
              -- END OF BEN_PL_TYP_OPT_TYP_F ----------------------
              ---------------------------------------------------------------

            end if;
            ---------------------------------------------------------------
            -- END OF BEN_OPT_F ----------------------
            ---------------------------------------------------------------
  --
end create_opt_result ;
--
procedure create_pl_typ_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_pl_typ_id                      in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
    ) is
    --
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_pl_typ_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_result_type_cd   varchar2(30) :=  'DISPLAY' ;
    -- Cursor to get mirror_src_entity_result_id
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
    select copy_entity_result_id mirror_src_entity_result_id
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where cpe.information1        = c_parent_pk_id
    and   cpe.result_type_cd      = l_result_type_cd
    and   cpe.copy_entity_txn_id  = c_copy_entity_txn_id
--    and   cpe.table_route_id      = trt.table_route_id
    and   cpe.table_alias         = c_parent_table_alias;
    --
    -- Bug : 3752407 : Global cursor g_table_route will now be used
    -- Cursor to get table_route_id
    --
    -- cursor c_table_route(c_parent_table_alias varchar2) is
    -- select table_route_id
    -- from pqh_table_route trt
    -- where trt.table_alias         = c_parent_table_alias;
    --
   ---------------------------------------------------------------
   -- START OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------
   cursor c_ptp(c_pl_typ_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  ptp.*
   from BEN_PL_TYP_F ptp
   where  ptp.pl_typ_id = c_pl_typ_id
     -- and ptp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--         and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PL_TYP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pl_typ_id
         -- and information4 = ptp.business_group_id
           and information2 = ptp.effective_start_date
           and information3 = ptp.effective_end_date
        );

   l_pl_typ_id                 number(15);
   l_out_ptp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PL_TYP_F ----------------------
   ---------------------------------------------------------------

   cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
--    and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

   l_mirror_src_entity_result_id    number(15);
   l_parent_entity_result_id        number(15);
   l_table_route_id                 number(15);
   l_information5                   ben_copy_entity_results.information5%TYPE;
   l_number_of_copies               number := p_number_of_copies ;
   --

begin
  --
      ---------------------------------------------------------------
      -- START OF BEN_PL_TYP_F ----------------------
      ---------------------------------------------------------------
      --
      --
        if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
        end if;

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_pl_typ_id,'PTP');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;

        l_mirror_src_entity_result_id := p_copy_entity_result_id;
        l_parent_entity_result_id := p_parent_entity_result_id;

        --
        l_pl_typ_id := p_pl_typ_id ;
        --
        for l_ptp_rec in c_ptp(p_pl_typ_id,l_mirror_src_entity_result_id,'PTP') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('PTP');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_ptp_rec.name;
          --
          if p_effective_date between l_ptp_rec.effective_start_date
             and l_ptp_rec.effective_end_date then
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
            p_parent_entity_result_id        => l_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_alias					 => 'PTP',
            p_table_route_id                 => l_table_route_id,
            p_information1     => l_ptp_rec.pl_typ_id,
            p_information2     => l_ptp_rec.EFFECTIVE_START_DATE,
            p_information3     => l_ptp_rec.EFFECTIVE_END_DATE,
            p_information4     => l_ptp_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information16     => l_ptp_rec.comp_typ_cd,
            p_information141     => l_ptp_rec.ivr_ident,
            p_information261     => l_ptp_rec.mn_enrl_rqd_num,
            p_information260     => l_ptp_rec.mx_enrl_alwd_num,
            p_information170     => l_ptp_rec.name,
            p_information14     => l_ptp_rec.no_mn_enrl_num_dfnd_flag,
            p_information13     => l_ptp_rec.no_mx_enrl_num_dfnd_flag,
            p_information15     => l_ptp_rec.opt_dsply_fmt_cd,
            p_information18     => l_ptp_rec.opt_typ_cd,
            p_information17     => l_ptp_rec.pl_typ_stat_cd,
            p_information111     => l_ptp_rec.ptp_attribute1,
            p_information120     => l_ptp_rec.ptp_attribute10,
            p_information121     => l_ptp_rec.ptp_attribute11,
            p_information122     => l_ptp_rec.ptp_attribute12,
            p_information123     => l_ptp_rec.ptp_attribute13,
            p_information124     => l_ptp_rec.ptp_attribute14,
            p_information125     => l_ptp_rec.ptp_attribute15,
            p_information126     => l_ptp_rec.ptp_attribute16,
            p_information127     => l_ptp_rec.ptp_attribute17,
            p_information128     => l_ptp_rec.ptp_attribute18,
            p_information129     => l_ptp_rec.ptp_attribute19,
            p_information112     => l_ptp_rec.ptp_attribute2,
            p_information130     => l_ptp_rec.ptp_attribute20,
            p_information131     => l_ptp_rec.ptp_attribute21,
            p_information132     => l_ptp_rec.ptp_attribute22,
            p_information133     => l_ptp_rec.ptp_attribute23,
            p_information134     => l_ptp_rec.ptp_attribute24,
            p_information135     => l_ptp_rec.ptp_attribute25,
            p_information136     => l_ptp_rec.ptp_attribute26,
            p_information137     => l_ptp_rec.ptp_attribute27,
            p_information138     => l_ptp_rec.ptp_attribute28,
            p_information139     => l_ptp_rec.ptp_attribute29,
            p_information113     => l_ptp_rec.ptp_attribute3,
            p_information140     => l_ptp_rec.ptp_attribute30,
            p_information114     => l_ptp_rec.ptp_attribute4,
            p_information115     => l_ptp_rec.ptp_attribute5,
            p_information116     => l_ptp_rec.ptp_attribute6,
            p_information117     => l_ptp_rec.ptp_attribute7,
            p_information118     => l_ptp_rec.ptp_attribute8,
            p_information119     => l_ptp_rec.ptp_attribute9,
            p_information110     => l_ptp_rec.ptp_attribute_category,
            p_information11     => l_ptp_rec.short_code,
            p_information12     => l_ptp_rec.short_name,
            p_information265    => l_ptp_rec.object_version_number,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_ptp_result_id is null then
              l_out_ptp_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_ptp_result_id := l_copy_entity_result_id ;
            end if;
            --
        end loop;
        --
    ---------------------------------------------------------------
    -- END OF BEN_PL_TYP_F ----------------------
    ---------------------------------------------------------------
  --
end create_pl_typ_result ;
--
procedure create_yr_perd_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_yr_perd_id                     in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
    ) is
    --
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_yr_perd_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_result_type_cd   varchar2(30) :=  'DISPLAY' ;
    -- Cursor to get mirror_src_entity_result_id
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
    select copy_entity_result_id mirror_src_entity_result_id
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where cpe.information1        = c_parent_pk_id
    and   cpe.result_type_cd      = l_result_type_cd
    and   cpe.copy_entity_txn_id  = c_copy_entity_txn_id
--    and   cpe.table_route_id      = trt.table_route_id
    and   cpe.table_alias         = c_parent_table_alias;
    --
    -- Bug : 3752407 : Global cursor g_table_route will now be used
    -- Cursor to get table_route_id
    --
    -- cursor c_table_route(c_parent_table_alias varchar2) is
    -- select table_route_id
    -- from pqh_table_route trt
    -- where trt.table_alias         = c_parent_table_alias;
    --
   ---------------------------------------------------------------
   -- START OF BEN_YR_PERD ----------------------
   ---------------------------------------------------------------

   cursor c_yrp(c_yr_perd_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  yrp.*
   from BEN_YR_PERD yrp
   where  yrp.yr_perd_id = c_yr_perd_id
     -- and yrp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_YR_PERD'
           and cpe.table_alias = c_table_alias
           and information1 = c_yr_perd_id
           -- and information4 = yrp.business_group_id
    );
    l_out_yrp_result_id  number(15);
    ---------------------------------------------------------------
    -- END OF BEN_YR_PERD ----------------------
    ---------------------------------------------------------------
    ---
    ---------------------------------------------------------------
    -- START OF BEN_WTHN_YR_PERD ----------------------
    ---------------------------------------------------------------
    cursor c_wyp_from_parent(c_YR_PERD_ID number) is
    select  wthn_yr_perd_id
    from BEN_WTHN_YR_PERD
    where  YR_PERD_ID = c_YR_PERD_ID ;
    --
    cursor c_wyp(c_wthn_yr_perd_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
    select  wyp.*
    from BEN_WTHN_YR_PERD wyp
    where  wyp.wthn_yr_perd_id = c_wthn_yr_perd_id
     -- and wyp.business_group_id = p_business_group_id
     and not exists (
         select /*+  */ null
         from ben_copy_entity_results cpe
--              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
--           and trt.table_route_id = cpe.table_route_id
           and ( -- c_mirror_src_entity_result_id is null or
                 mirror_src_entity_result_id = c_mirror_src_entity_result_id )
           -- and trt.where_clause = 'BEN_WTHN_YR_PERD'
           and cpe.table_alias = c_table_alias
           and information1 = c_wthn_yr_perd_id
           -- and information4 = wyp.business_group_id
     );
     l_out_wyp_result_id  number(15);
    ---------------------------------------------------------------
    -- END OF BEN_WTHN_YR_PERD ----------------------
    ---------------------------------------------------------------

    l_yr_perd_id                number(15);
    l_wthn_yr_perd_id           number(15);

    cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
--         pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
--    and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

   l_mirror_src_entity_result_id    number(15);
   l_parent_entity_result_id        number(15);
   l_table_route_id                 number(15);
   l_information5                   ben_copy_entity_results.information5%TYPE;
   l_number_of_copies               number := p_number_of_copies ;
   --

begin
  --
  ---------------------------------------------------------------
  -- START OF BEN_YR_PERD ----------------------
  ---------------------------------------------------------------

    if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
      ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
    end if;

    l_mirror_src_entity_result_id := p_copy_entity_result_id ;

    l_yr_perd_id := p_yr_perd_id ;

    if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
      open c_object_exists(l_yr_perd_id,'YRP');
      fetch c_object_exists into l_dummy;
      if c_object_exists%found then
        close c_object_exists;
        return;
      end if;
      close c_object_exists;
    end if;

    --
    for l_yrp_rec in c_yrp(l_yr_perd_id,l_mirror_src_entity_result_id,'YRP') loop
    --
    --
      l_table_route_id := null ;
      open ben_plan_design_program_module.g_table_route('YRP');
      fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
      close ben_plan_design_program_module.g_table_route ;
      --
      l_information5  := TO_CHAR(l_yrp_rec.start_date,'DD-Mon-YYYY')||' -  '||
                         TO_CHAR(l_yrp_rec.end_date,'DD-Mon-YYYY'); --'Intersection';
      --

      l_result_type_cd := 'DISPLAY';
      --
      l_copy_entity_result_id := null;
      l_object_version_number := null;
      ben_copy_entity_results_api.create_copy_entity_results(
        p_copy_entity_result_id           => l_copy_entity_result_id,
        p_copy_entity_txn_id             => p_copy_entity_txn_id,
        p_result_type_cd                 => l_result_type_cd,
        p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
        p_parent_entity_result_id        => l_mirror_src_entity_result_id,
        p_number_of_copies               => l_number_of_copies,
        p_table_alias					 => 'YRP',
        p_table_route_id                 => l_table_route_id,
        p_information1     => l_yrp_rec.yr_perd_id,
        p_information2     => null,
        p_information3     => null,
        p_information4     => l_yrp_rec.business_group_id,
        p_information5     => l_information5 , -- 9999 put name for h-grid
        p_information308     => l_yrp_rec.end_date,
        p_information311     => l_yrp_rec.lmtn_yr_end_dt,
        p_information310     => l_yrp_rec.lmtn_yr_strt_dt,
        p_information11     => l_yrp_rec.perd_tm_uom_cd,
        p_information12     => l_yrp_rec.perd_typ_cd,
        p_information260     => l_yrp_rec.perds_in_yr_num,
        p_information309     => l_yrp_rec.start_date,
        p_information111     => l_yrp_rec.yrp_attribute1,
        p_information120     => l_yrp_rec.yrp_attribute10,
        p_information121     => l_yrp_rec.yrp_attribute11,
        p_information122     => l_yrp_rec.yrp_attribute12,
        p_information123     => l_yrp_rec.yrp_attribute13,
        p_information124     => l_yrp_rec.yrp_attribute14,
        p_information125     => l_yrp_rec.yrp_attribute15,
        p_information126     => l_yrp_rec.yrp_attribute16,
        p_information127     => l_yrp_rec.yrp_attribute17,
        p_information128     => l_yrp_rec.yrp_attribute18,
        p_information129     => l_yrp_rec.yrp_attribute19,
        p_information112     => l_yrp_rec.yrp_attribute2,
        p_information130     => l_yrp_rec.yrp_attribute20,
        p_information131     => l_yrp_rec.yrp_attribute21,
        p_information132     => l_yrp_rec.yrp_attribute22,
        p_information133     => l_yrp_rec.yrp_attribute23,
        p_information134     => l_yrp_rec.yrp_attribute24,
        p_information135     => l_yrp_rec.yrp_attribute25,
        p_information136     => l_yrp_rec.yrp_attribute26,
        p_information137     => l_yrp_rec.yrp_attribute27,
        p_information138     => l_yrp_rec.yrp_attribute28,
        p_information139     => l_yrp_rec.yrp_attribute29,
        p_information113     => l_yrp_rec.yrp_attribute3,
        p_information140     => l_yrp_rec.yrp_attribute30,
        p_information114     => l_yrp_rec.yrp_attribute4,
        p_information115     => l_yrp_rec.yrp_attribute5,
        p_information116     => l_yrp_rec.yrp_attribute6,
        p_information117     => l_yrp_rec.yrp_attribute7,
        p_information118     => l_yrp_rec.yrp_attribute8,
        p_information119     => l_yrp_rec.yrp_attribute9,
        p_information110     => l_yrp_rec.yrp_attribute_category,
        p_information265     => l_yrp_rec.object_version_number,
        p_object_version_number          => l_object_version_number,
        p_effective_date                 => p_effective_date       );
        --

      if l_out_yrp_result_id is null then
        l_out_yrp_result_id := l_copy_entity_result_id;
      end if;

      if l_result_type_cd = 'DISPLAY' then
        l_out_yrp_result_id := l_copy_entity_result_id ;
      end if;
    end loop;
    --
    -- Create within year period only if year period row
    -- has been created
    --

    if l_out_yrp_result_id is not null then
    --
     ---------------------------------------------------------------
     -- START OF BEN_WTHN_YR_PERD ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_wyp_from_parent(l_YR_PERD_ID) loop
     --
      l_mirror_src_entity_result_id := l_out_yrp_result_id ;

      l_wthn_yr_perd_id := l_parent_rec.wthn_yr_perd_id ;
      --
      for l_wyp_rec in c_wyp(l_parent_rec.wthn_yr_perd_id,l_mirror_src_entity_result_id,'WYP') loop
      --
      --
        l_table_route_id := null ;
        open ben_plan_design_program_module.g_table_route('WYP');
        fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
        close ben_plan_design_program_module.g_table_route ;
        --
        l_information5  := TO_CHAR(l_wyp_rec.strt_mo) || '/' || TO_CHAR(l_wyp_rec.strt_day)|| ' - ' ||
                           TO_CHAR(l_wyp_rec.end_mo) || '/' || TO_CHAR(l_wyp_rec.end_day); --'Intersection';
        --
        l_result_type_cd := 'DISPLAY';
        --
        l_copy_entity_result_id := null;
        l_object_version_number := null;
        ben_copy_entity_results_api.create_copy_entity_results(
          p_copy_entity_result_id           => l_copy_entity_result_id,
          p_copy_entity_txn_id             => p_copy_entity_txn_id,
          p_result_type_cd                 => l_result_type_cd,
          p_mirror_src_entity_result_id        => l_mirror_src_entity_result_id,
          p_parent_entity_result_id        => l_mirror_src_entity_result_id,
          p_number_of_copies               => l_number_of_copies,
          p_table_alias					 => 'WYP',
          p_table_route_id                 => l_table_route_id,
          p_information1     => l_wyp_rec.wthn_yr_perd_id,
          p_information2     => null,
          p_information3     => null,
          p_information4     => l_wyp_rec.business_group_id,
          p_information5     => l_information5 , -- 9999 put name for h-grid
          p_information294     => l_wyp_rec.end_day,
          p_information296     => l_wyp_rec.end_mo,
          p_information293     => l_wyp_rec.strt_day,
          p_information295     => l_wyp_rec.strt_mo,
          p_information11     => l_wyp_rec.tm_uom,
          p_information111     => l_wyp_rec.wyp_attribute1,
          p_information120     => l_wyp_rec.wyp_attribute10,
          p_information121     => l_wyp_rec.wyp_attribute11,
          p_information122     => l_wyp_rec.wyp_attribute12,
          p_information123     => l_wyp_rec.wyp_attribute13,
          p_information124     => l_wyp_rec.wyp_attribute14,
          p_information125     => l_wyp_rec.wyp_attribute15,
          p_information126     => l_wyp_rec.wyp_attribute16,
          p_information127     => l_wyp_rec.wyp_attribute17,
          p_information128     => l_wyp_rec.wyp_attribute18,
          p_information129     => l_wyp_rec.wyp_attribute19,
          p_information112     => l_wyp_rec.wyp_attribute2,
          p_information130     => l_wyp_rec.wyp_attribute20,
          p_information131     => l_wyp_rec.wyp_attribute21,
          p_information132     => l_wyp_rec.wyp_attribute22,
          p_information133     => l_wyp_rec.wyp_attribute23,
          p_information134     => l_wyp_rec.wyp_attribute24,
          p_information135     => l_wyp_rec.wyp_attribute25,
          p_information136     => l_wyp_rec.wyp_attribute26,
          p_information137     => l_wyp_rec.wyp_attribute27,
          p_information138     => l_wyp_rec.wyp_attribute28,
          p_information139     => l_wyp_rec.wyp_attribute29,
          p_information113     => l_wyp_rec.wyp_attribute3,
          p_information140     => l_wyp_rec.wyp_attribute30,
          p_information114     => l_wyp_rec.wyp_attribute4,
          p_information115     => l_wyp_rec.wyp_attribute5,
          p_information116     => l_wyp_rec.wyp_attribute6,
          p_information117     => l_wyp_rec.wyp_attribute7,
          p_information118     => l_wyp_rec.wyp_attribute8,
          p_information119     => l_wyp_rec.wyp_attribute9,
          p_information110     => l_wyp_rec.wyp_attribute_category,
          p_information240     => l_wyp_rec.yr_perd_id,
          p_information265     => l_wyp_rec.object_version_number,
          p_object_version_number          => l_object_version_number,
          p_effective_date                 => p_effective_date       );
          --

        if l_out_wyp_result_id is null then
          l_out_wyp_result_id := l_copy_entity_result_id;
        end if;

        if l_result_type_cd = 'DISPLAY' then
          l_out_wyp_result_id := l_copy_entity_result_id ;
        end if;
      end loop;
      --
     end loop;
     ---------------------------------------------------------------
     -- END OF BEN_WTHN_YR_PERD ----------------------
     ---------------------------------------------------------------
    end if;
  ---------------------------------------------------------------
  -- END OF BEN_YR_PERD ----------------------
  ---------------------------------------------------------------

  --
end create_yr_perd_result ;

end ben_plan_design_plan_module;

/
