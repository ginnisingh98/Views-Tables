--------------------------------------------------------
--  DDL for Package Body BEN_PD_RATE_AND_CVG_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PD_RATE_AND_CVG_MODULE" as
/* $Header: bepdcrtc.pkb 120.9 2006/02/28 03:30:36 rgajula noship $ */
--
g_package  varchar2(33) := '  ben_pd_rate_and_cvg_module.';
procedure create_rate_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source vapro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in number
  --
  ,p_opt_id                         in number     default null
  --
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;

        --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
           pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     --
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
   ---------------------------------------------------------------
   -- START OF BEN_ACTY_BASE_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_abr_from_parent(c_pgm_id           number,
                            c_ptip_id          number,
                            c_plip_id          number,
                            c_pl_id            number,
                            c_oipl_id          number,
                            c_oiplip_id        number,
                            c_cmbn_plip_id     number,
                            c_cmbn_ptip_id     number,
                            c_cmbn_ptip_opt_id number,
                            --
                            c_opt_id           number
                            --
                            ) is
   select distinct acty_base_rt_id
   from BEN_ACTY_BASE_RT_F
   where  (c_pgm_id           is not null and c_pgm_id           = pgm_id) or
          (c_ptip_id          is not null and c_ptip_id          = ptip_id) or
          (c_plip_id          is not null and c_plip_id          = plip_id) or
          (c_pl_id            is not null and c_pl_id            = pl_id ) or
          (c_oiplip_id        is not null and c_oiplip_id        = oiplip_id) or
          (c_oipl_id          is not null and c_oipl_id          = oipl_id) or
          (c_cmbn_plip_id     is not null and c_cmbn_plip_id     = cmbn_plip_id) or
          (c_cmbn_ptip_id     is not null and c_cmbn_ptip_id     = cmbn_ptip_id) or
          (c_cmbn_ptip_opt_id is not null and c_cmbn_ptip_opt_id = cmbn_ptip_opt_id) or
          --
          (c_opt_id           is not null and c_opt_id           = opt_id);
          --
          --
   cursor c_abr(c_acty_base_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2) is
   select  abr.*
   from BEN_ACTY_BASE_RT_F abr
   where  abr.acty_base_rt_id = c_acty_base_rt_id
     -- and abr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTY_BASE_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_acty_base_rt_id
         -- and information4 = abr.business_group_id
           and information2 = abr.effective_start_date
           and information3 = abr.effective_end_date);
    l_acty_base_rt_id                 number(15);
    l_out_abr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name1(p_id in number,p_date in date) is
     select pet.element_name element_name
     from pay_element_types_f pet
     where  (pet.business_group_id is null
            or pet.business_group_id = p_business_group_id)
       and pet.element_type_id = p_id
       and p_date between nvl(pet.effective_start_date,p_date)
       and nvl(pet.effective_end_date,p_date) ;

     cursor c_element_type_start_date(c_element_type_id number) is
     select min(effective_start_date) effective_start_date
     from pay_element_types_f
     where element_type_id = c_element_type_id;

    cursor c_get_mapping_name2(p_id in number, p_id1 in number, p_date in date) is
     select piv.name name
     from pay_input_values_f piv
     where  ( piv.business_group_id is null or piv.business_group_id = p_business_group_id )
     and   piv.element_type_id = p_id1
     and p_date between piv.effective_start_date and
         piv.effective_end_date
     and  piv.input_value_id = p_id;

     cursor c_input_value_start_date(c_input_value_id number) is
     select min(effective_start_date) effective_start_date
     from pay_input_values_f
     where input_value_id = c_input_value_id;

    -- PDW

    cursor c_pl_from_plip(c_plip_id  number) is
    select pl_id
    from ben_plip_f cpp
    where cpp.plip_id = c_plip_id
    and rownum = 1;

    cursor c_pl_from_oipl(c_oipl_id  number) is
    select pl_id
    from ben_oipl_f cop
    where cop.oipl_id = c_oipl_id
    and rownum = 1;

    cursor c_pl_from_oiplip(c_oiplip_id number) is
    select cpp.pl_id
    from ben_oiplip_f opp,
         ben_plip_f   cpp
    where opp.oiplip_id = c_oiplip_id
    and   cpp.plip_id = opp.plip_id
    and   rownum = 1;

    l_pl_id  ben_pl_f.pl_id%type;

    -- PDW

    --
    l_mapping_id         number;
    l_mapping_name       varchar2(600);
    l_mapping_id1        number;
    l_mapping_name1      varchar2(600);
    l_mapping_column_name1 pqh_attributes.attribute_name%type;
    l_mapping_column_name2 pqh_attributes.attribute_name%type;

    l_input_value_name          pay_input_values_f.name%type;

    l_abr_acty_base_rt_esd      ben_acty_base_rt_f.effective_start_date%type;

    l_element_type_start_date   pay_element_types_f.effective_start_date%type;
    l_input_value_start_date    pay_input_values_f.effective_start_date%type;

   ---------------------------------------------------------------
   -- END OF BEN_ACTY_BASE_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTY_RT_PYMT_SCHED_F ----------------------
   ---------------------------------------------------------------
   cursor c_apf_from_parent(c_ACTY_BASE_RT_ID number) is
   select  acty_rt_pymt_sched_id
   from BEN_ACTY_RT_PYMT_SCHED_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_apf(c_acty_rt_pymt_sched_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  apf.*
   from BEN_ACTY_RT_PYMT_SCHED_F apf
   where  apf.acty_rt_pymt_sched_id = c_acty_rt_pymt_sched_id
     --and apf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( --l_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTY_RT_PYMT_SCHED_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_acty_rt_pymt_sched_id
         --and information4 = apf.business_group_id
           and information2 = apf.effective_start_date
           and information3 = apf.effective_end_date);
    l_acty_rt_pymt_sched_id                 number(15);
    l_out_apf_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTY_RT_PYMT_SCHED_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PYMT_SCHED_PY_FREQ ----------------------
   ---------------------------------------------------------------
   cursor c_psq_from_parent(c_ACTY_RT_PYMT_SCHED_ID number) is
   select  pymt_sched_py_freq_id
   from BEN_PYMT_SCHED_PY_FREQ
   where  ACTY_RT_PYMT_SCHED_ID = c_ACTY_RT_PYMT_SCHED_ID ;
   --
   cursor c_psq(c_pymt_sched_py_freq_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  psq.*
   from BEN_PYMT_SCHED_PY_FREQ psq
   where  psq.pymt_sched_py_freq_id = c_pymt_sched_py_freq_id
     --and psq.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( --c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PYMT_SCHED_PY_FREQ'
         and cpe.table_alias = c_table_alias
         and information1 = c_pymt_sched_py_freq_id
         --and information4 = psq.business_group_id
        );
    l_pymt_sched_py_freq_id                 number(15);
    l_out_psq_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PYMT_SCHED_PY_FREQ ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTL_PREM_F ----------------------
   ---------------------------------------------------------------
   cursor c_apr_from_parent(c_ACTY_BASE_RT_ID number) is
   select distinct actl_prem_id
   from BEN_ACTY_BASE_RT_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_apr(c_actl_prem_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  apr.*
   from BEN_ACTL_PREM_F apr
   where  apr.actl_prem_id = c_actl_prem_id
     -- and apr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTL_PREM_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_actl_prem_id
         -- and information4 = apr.business_group_id
           and information2 = apr.effective_start_date
           and information3 = apr.effective_end_date);
    l_actl_prem_id                 number(15);
    l_out_apr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTL_PREM_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTY_RT_PTD_LMT_F ----------------------
   ---------------------------------------------------------------
   cursor c_apl_from_parent(c_ACTY_BASE_RT_ID number) is
   select  acty_rt_ptd_lmt_id
   from BEN_ACTY_RT_PTD_LMT_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_apl(c_acty_rt_ptd_lmt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  apl.*
   from BEN_ACTY_RT_PTD_LMT_F apl
   where  apl.acty_rt_ptd_lmt_id = c_acty_rt_ptd_lmt_id
     -- and apl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTY_RT_PTD_LMT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_acty_rt_ptd_lmt_id
         -- and information4 = apl.business_group_id
           and information2 = apl.effective_start_date
           and information3 = apl.effective_end_date);
    l_acty_rt_ptd_lmt_id                 number(15);
    l_out_apl_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTY_RT_PTD_LMT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTY_VRBL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_avr_from_parent(c_ACTY_BASE_RT_ID number) is
   select distinct acty_vrbl_rt_id
   from BEN_ACTY_VRBL_RT_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_avr(c_acty_vrbl_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar ) is
   select  avr.*
   from BEN_ACTY_VRBL_RT_F avr
   where  avr.acty_vrbl_rt_id = c_acty_vrbl_rt_id
     -- and avr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTY_VRBL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_acty_vrbl_rt_id
         -- and information4 = avr.business_group_id
           and information2 = avr.effective_start_date
           and information3 = avr.effective_end_date);
   --
   cursor c_avr_drp(c_acty_vrbl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information262 vrbl_rt_prfl_id
     from ben_copy_entity_results cpe
          -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     -- and trt.where_clause = 'BEN_ACTY_VRBL_RT_F'
     and cpe.table_alias = c_table_alias
     and information1 = c_acty_vrbl_rt_id
     -- and information4 = p_business_group_id
    ;
   --
    l_acty_vrbl_rt_id                 number(15);
    l_out_avr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTY_VRBL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_MTCHG_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_mtr_from_parent(c_ACTY_BASE_RT_ID number) is
   select  mtchg_rt_id
   from BEN_MTCHG_RT_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_mtr(c_mtchg_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  mtr.*
   from BEN_MTCHG_RT_F mtr
   where  mtr.mtchg_rt_id = c_mtchg_rt_id
     -- and mtr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
        --  and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_MTCHG_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_mtchg_rt_id
         -- and information4 = mtr.business_group_id
           and information2 = mtr.effective_start_date
           and information3 = mtr.effective_end_date);
    l_mtchg_rt_id                 number(15);
    l_out_mtr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_MTCHG_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
   ---------------------------------------------------------------
   cursor c_pmr_from_parent(c_ACTY_BASE_RT_ID number) is
   select  prtl_mo_rt_prtn_val_id
   from BEN_PRTL_MO_RT_PRTN_VAL_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_pmr(c_prtl_mo_rt_prtn_val_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  pmr.*
   from BEN_PRTL_MO_RT_PRTN_VAL_F pmr
   where  pmr.prtl_mo_rt_prtn_val_id = c_prtl_mo_rt_prtn_val_id
     -- and pmr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PRTL_MO_RT_PRTN_VAL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_prtl_mo_rt_prtn_val_id
         -- and information4 = pmr.business_group_id
           and information2 = pmr.effective_start_date
           and information3 = pmr.effective_end_date);
    l_prtl_mo_rt_prtn_val_id                 number(15);
    l_out_pmr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PTD_LMT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pdl_from_parent(c_ACTY_RT_PTD_LMT_ID number) is
   select  ptd_lmt_id
   from BEN_ACTY_RT_PTD_LMT_F
   where  ACTY_RT_PTD_LMT_ID = c_ACTY_RT_PTD_LMT_ID ;
   --
   cursor c_pdl(c_ptd_lmt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pdl.*
   from BEN_PTD_LMT_F pdl
   where  pdl.ptd_lmt_id = c_ptd_lmt_id
     -- and pdl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PTD_LMT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ptd_lmt_id
         -- and information4 = pdl.business_group_id
           and information2 = pdl.effective_start_date
           and information3 = pdl.effective_end_date);
    l_ptd_lmt_id                 number(15);
    l_out_pdl_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PTD_LMT_F ----------------------
   ---------------------------------------------------------------
    ---------------------------------------------------------------
   -- START OF BEN_EXTRA_INPUT_VALUES ----------------------
   ---------------------------------------------------------------
   cursor c_eiv_from_parent(c_ACTY_BASE_RT_ID number) is
   select  extra_input_value_id
   from BEN_EXTRA_INPUT_VALUES
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_eiv(c_extra_input_value_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  eiv.*
   from BEN_EXTRA_INPUT_VALUES eiv
   where  eiv.extra_input_value_id = c_extra_input_value_id
     -- and eiv.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_EXTRA_INPUT_VALUES'
         and cpe.table_alias = c_table_alias
         and information1 = c_extra_input_value_id
         -- and information4 = eiv.business_group_id
         );

   cursor c_element_type_id(c_acty_base_rt_id in number,
                            c_copy_entity_txn_id in number,
                            c_table_alias varchar2) is
   select cpe.information174 element_type_id
   from   ben_copy_entity_results cpe
          -- pqh_table_route tre
   where  cpe.information1 = c_acty_base_rt_id
   and    cpe.copy_entity_txn_id = c_copy_entity_txn_id
   -- and    cpe.table_route_id = tre.table_route_id
   and    cpe.table_alias = c_table_alias
   order by cpe.information3 desc;

   l_extra_input_value_id                 number(15);
   l_out_eiv_result_id   number(15);
   l_element_type_id_for_eiv   number;
   ---------------------------------------------------------------
   -- END OF BEN_EXTRA_INPUT_VALUES ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTY_BASE_RT_CTFN_F ----------------------
   ---------------------------------------------------------------
   cursor c_abc_from_parent(c_ACTY_BASE_RT_ID number) is
   select  acty_base_rt_ctfn_id
   from BEN_ACTY_BASE_RT_CTFN_F
   where  ACTY_BASE_RT_ID = c_ACTY_BASE_RT_ID ;
   --
   cursor c_abc(c_acty_base_rt_ctfn_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2) is
   select  abc.*
   from BEN_ACTY_BASE_RT_CTFN_F abc
   where  abc.acty_base_rt_ctfn_id = c_acty_base_rt_ctfn_id
     -- and abc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTY_BASE_RT_CTFN_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_acty_base_rt_ctfn_id
         -- and information4 = abc.business_group_id
           and information2 = abc.effective_start_date
           and information3 = abc.effective_end_date);
    l_acty_base_rt_ctfn_id                 number(15);
    l_out_abc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTY_BASE_RT_CTFN_F ----------------------
   ---------------------------------------------------------------

     cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
     select null
     from ben_copy_entity_results cpe
          -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and cpe.table_alias = c_table_alias
     and information1 = c_pk_id;

     l_dummy                     varchar2(1);

     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);

     TYPE rt_ref_csr_typ IS REF CURSOR;
     c_parent_rec   rt_ref_csr_typ;
     l_parent_rec   Ben_Acty_base_rt_F%ROWTYPE;
     l_parent_acty_base_rt_id number;
     l_Sql          Varchar2(2000) := NULL;
     l_Bind_Value   Ben_Pgm_F.Pgm_Id%TYPE := NULL;

  begin
    l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_ACTY_BASE_RT_F ----------------------
     ---------------------------------------------------------------
   If p_pgm_id is NOT NULL then

      l_sql := 'select distinct acty_base_rt_id
      from BEN_ACTY_BASE_RT_F
     where  pgm_id = :Pgm_Id';

      l_Bind_Value := p_Pgm_Id;

   Elsif p_ptip_id is NOT NULL then

       l_sql := 'select distinct acty_base_rt_id
       from BEN_ACTY_BASE_RT_F
       where  ptip_id  = :Ptip_id';

       l_Bind_Value := p_Ptip_id;

   Elsif p_plip_id is NOT NULL then

       l_Sql := 'select distinct acty_base_rt_id
       from BEN_ACTY_BASE_RT_F
       where plip_id = :plip_id';

       l_Bind_Value := p_plip_id;

   Elsif p_pl_id is NOT NULL then

        l_sql := 'select distinct acty_base_rt_id
        from   BEN_ACTY_BASE_RT_F
        where  pl_id = :pl_Id';

	l_Bind_Value := p_pl_Id;

   Elsif p_oipl_id is NOT NULL then

   	l_sql := 'select distinct acty_base_rt_id
        from   BEN_ACTY_BASE_RT_F
        where  oipl_id = :oipl_id';

	l_Bind_Value := p_oipl_id;

   Elsif p_oiplip_id is NOT NULL then

          l_sql := 'select distinct acty_base_rt_id
           from BEN_ACTY_BASE_RT_F
          where oiplip_id = :oiplip_id';

	   l_Bind_Value := p_oiplip_id;

   Elsif p_cmbn_plip_id is NOT NULL then

          l_sql := 'select distinct acty_base_rt_id
           from BEN_ACTY_BASE_RT_F
          where cmbn_plip_id = :cmbn_plip_id';

	   l_Bind_Value := p_cmbn_plip_id;

   Elsif p_cmbn_ptip_id is NOT NULL then

          l_sql := 'select distinct acty_base_rt_id
           from BEN_ACTY_BASE_RT_F
          where cmbn_ptip_id = :cmbn_ptip_id';

	   l_Bind_Value := p_cmbn_ptip_id;

   Elsif  p_cmbn_ptip_opt_id is NOT NULL Then

          l_sql := 'select distinct acty_base_rt_id
           from BEN_ACTY_BASE_RT_F
          where cmbn_ptip_opt_id = :cmbn_ptip_opt_id';

	  l_Bind_Value :=  p_cmbn_ptip_opt_id;

  Elsif p_opt_id is NOT NULL then


         l_sql := 'select distinct acty_base_rt_id
           from BEN_ACTY_BASE_RT_F
          where opt_id = :opt_id';

	  l_Bind_Value := p_opt_id;

  Else

        Return;

  End If;
     --


  /*   for l_parent_rec  in c_abr_from_parent(p_pgm_id,p_ptip_id,p_plip_id,p_pl_id,p_oipl_id,
                            p_oiplip_id,p_cmbn_plip_id,p_cmbn_ptip_id,p_cmbn_ptip_opt_id,
                            p_opt_id ) loop */

        --
	If l_sql is Null Then
	   return;
        end If;

	OPEN c_parent_rec FOR l_sql Using l_Bind_Value;
	Loop

	Fetch c_Parent_rec into l_parent_acty_base_rt_id;

        If c_Parent_Rec%NOTFOUND Then
           Close c_Parent_Rec;
	   Exit;

	End If;

	l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_acty_base_rt_id := l_parent_acty_base_rt_id ;
        --
        l_abr_acty_base_rt_esd := null;
        for l_abr_rec in c_abr(l_parent_acty_base_rt_id,l_mirror_src_entity_result_id,'ABR' ) loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('ABR');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_abr_rec.name; --'Intersection';
          --
          if p_effective_date between l_abr_rec.effective_start_date
             and l_abr_rec.effective_end_date then
           --
             l_result_type_cd := 'DISPLAY';
          else
             l_result_type_cd := 'NO DISPLAY';
          end if;
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;

          --
          -- To store effective_start_date of element_type
          -- and input_value for Mapping - Bug 2958658
          --
          l_element_type_start_date := null;
          if l_abr_rec.element_type_id is not null then
            open c_element_type_start_date(l_abr_rec.element_type_id);
            fetch c_element_type_start_date into l_element_type_start_date;
            close c_element_type_start_date;
           end if;

          l_input_value_start_date := null;
          if l_abr_rec.input_value_id is not null then
            open c_input_value_start_date(l_abr_rec.input_value_id);
            fetch c_input_value_start_date into l_input_value_start_date;
            close c_input_value_start_date;
          end if;

          --
          -- pabodla : MAPPING DATA : Store the mapping column information.
          --

          l_mapping_name := null;
          l_mapping_id   := null;
          l_mapping_name1:= null;
          l_mapping_id1  := null;
          --
          -- Get the defined balance name to display on mapping page.
          --
          open c_get_mapping_name1(l_abr_rec.element_type_id,
                                   NVL(l_element_type_start_date,p_effective_date));
          fetch c_get_mapping_name1 into l_mapping_name;
          close c_get_mapping_name1;
          --
          l_mapping_id   := l_abr_rec.element_type_id;


          open c_get_mapping_name2(l_abr_rec.input_value_id, l_abr_rec.element_type_id,
                                   NVL(l_input_value_start_date,p_effective_date));
          fetch c_get_mapping_name2 into l_mapping_name1;
          close c_get_mapping_name2;
          --
          l_mapping_id1  := l_abr_rec.input_value_id;
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
          -- PDW
          -- Store pl_id in information283

            l_pl_id := null;
            if l_abr_rec.pl_id is not null then
              l_pl_id := l_abr_rec.pl_id;

            elsif l_abr_rec.plip_id is not null then
              open c_pl_from_plip(l_abr_rec.plip_id);
              fetch c_pl_from_plip into l_pl_id;
              close c_pl_from_plip;

            elsif l_abr_rec.oipl_id is not null then
              open c_pl_from_oipl(l_abr_rec.oipl_id);
              fetch c_pl_from_oipl into l_pl_id;
              close c_pl_from_oipl;

            elsif l_abr_rec.oiplip_id is not null then
              open c_pl_from_oiplip(l_abr_rec.oiplip_id);
              fetch c_pl_from_oiplip into l_pl_id;
              close c_pl_from_oiplip;

            end if;

          -- PDW

          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => p_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'ABR',
            p_information1     => l_abr_rec.acty_base_rt_id,
            p_information2     => l_abr_rec.EFFECTIVE_START_DATE,
            p_information3     => l_abr_rec.EFFECTIVE_END_DATE,
            p_information4     => l_abr_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information111     => l_abr_rec.abr_attribute1,
            p_information120     => l_abr_rec.abr_attribute10,
            p_information121     => l_abr_rec.abr_attribute11,
            p_information122     => l_abr_rec.abr_attribute12,
            p_information123     => l_abr_rec.abr_attribute13,
            p_information124     => l_abr_rec.abr_attribute14,
            p_information125     => l_abr_rec.abr_attribute15,
            p_information126     => l_abr_rec.abr_attribute16,
            p_information127     => l_abr_rec.abr_attribute17,
            p_information128     => l_abr_rec.abr_attribute18,
            p_information129     => l_abr_rec.abr_attribute19,
            p_information112     => l_abr_rec.abr_attribute2,
            p_information130     => l_abr_rec.abr_attribute20,
            p_information131     => l_abr_rec.abr_attribute21,
            p_information132     => l_abr_rec.abr_attribute22,
            p_information133     => l_abr_rec.abr_attribute23,
            p_information134     => l_abr_rec.abr_attribute24,
            p_information135     => l_abr_rec.abr_attribute25,
            p_information136     => l_abr_rec.abr_attribute26,
            p_information137     => l_abr_rec.abr_attribute27,
            p_information138     => l_abr_rec.abr_attribute28,
            p_information139     => l_abr_rec.abr_attribute29,
            p_information113     => l_abr_rec.abr_attribute3,
            p_information140     => l_abr_rec.abr_attribute30,
            p_information114     => l_abr_rec.abr_attribute4,
            p_information115     => l_abr_rec.abr_attribute5,
            p_information116     => l_abr_rec.abr_attribute6,
            p_information117     => l_abr_rec.abr_attribute7,
            p_information118     => l_abr_rec.abr_attribute8,
            p_information119     => l_abr_rec.abr_attribute9,
            p_information110     => l_abr_rec.abr_attribute_category,
            p_information27     => l_abr_rec.abv_mx_elcn_val_alwd_flag,
            p_information250     => l_abr_rec.actl_prem_id,
            p_information17     => l_abr_rec.acty_base_rt_stat_cd,
            p_information49     => l_abr_rec.acty_typ_cd,
            p_information11     => l_abr_rec.alws_chg_cd,
            p_information298     => l_abr_rec.ann_mn_elcn_val,
            p_information299     => l_abr_rec.ann_mx_elcn_val,
            p_information23     => l_abr_rec.asmt_to_use_cd,
            p_information26     => l_abr_rec.asn_on_enrt_flag,
            p_information28     => l_abr_rec.blw_mn_elcn_alwd_flag,
            p_information51     => l_abr_rec.bnft_rt_typ_cd,
            p_information273     => l_abr_rec.clm_comp_lvl_fctr_id,
            p_information239     => l_abr_rec.cmbn_plip_id,
            p_information236     => l_abr_rec.cmbn_ptip_id,
            p_information249     => l_abr_rec.cmbn_ptip_opt_id,
            p_information254     => l_abr_rec.comp_lvl_fctr_id,
            p_information247     => l_abr_rec.opt_id,
            p_information262     => l_abr_rec.cost_allocation_keyflex_id,
            p_information24     => l_abr_rec.det_pl_ytd_cntrs_cd,
            p_information39     => l_abr_rec.dflt_flag,
            p_information297     => l_abr_rec.dflt_val,
            p_information29     => l_abr_rec.dsply_on_enrt_flag,
            p_information12     => l_abr_rec.ele_entry_val_cd,
            p_information45     => l_abr_rec.ele_rqd_flag,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information44     => l_abr_rec.entr_ann_val_flag,
            p_information41     => l_abr_rec.entr_val_at_enrt_flag,
            p_information141     => l_abr_rec.frgn_erg_ded_ident,
            p_information185     => l_abr_rec.frgn_erg_ded_name,
            p_information19     => l_abr_rec.frgn_erg_ded_typ_cd,
            p_information296     => l_abr_rec.incrmt_elcn_val,
            p_information263     => l_abr_rec.input_va_calc_rl,
            -- Data for MAPPING columns.
            p_information177    => l_mapping_name1,
            p_information178    => l_mapping_id1,
            -- END other product Mapping columns.
            p_information268     => l_abr_rec.lwr_lmt_calc_rl,
            p_information300     => l_abr_rec.lwr_lmt_val,
            p_information293     => l_abr_rec.mn_elcn_val,
            p_information294     => l_abr_rec.mx_elcn_val,
            p_information170     => l_abr_rec.name,
            p_information14     => l_abr_rec.nnmntry_uom,
            p_information42     => l_abr_rec.no_mn_elcn_val_dfnd_flag,
            p_information40     => l_abr_rec.no_mx_elcn_val_dfnd_flag,
            p_information36     => l_abr_rec.no_std_rt_used_flag,
            p_information258     => l_abr_rec.oipl_id,
            p_information227     => l_abr_rec.oiplip_id,
            p_information46     => l_abr_rec.one_ann_pymt_cd,
            p_information43     => l_abr_rec.only_one_bal_typ_alwd_flag,
            p_information264     => l_abr_rec.ordr_num,
            p_information267     => l_abr_rec.parnt_acty_base_rt_id,
            p_information53     => l_abr_rec.parnt_chld_cd,
            p_information266     => l_abr_rec.pay_rate_grade_rule_id,
            p_information260     => l_abr_rec.pgm_id,
            p_information261     => l_abr_rec.pl_id,
            p_information256     => l_abr_rec.plip_id,
            p_information35     => l_abr_rec.prdct_flx_cr_when_elig_flag,
            p_information34     => l_abr_rec.proc_each_pp_dflt_flag,
            p_information18     => l_abr_rec.procg_src_cd,
            p_information47     => l_abr_rec.prort_mn_ann_elcn_val_cd,
            p_information274     => l_abr_rec.prort_mn_ann_elcn_val_rl,
            p_information48     => l_abr_rec.prort_mx_ann_elcn_val_cd,
            p_information275     => l_abr_rec.prort_mx_ann_elcn_val_rl,
            p_information16     => l_abr_rec.prtl_mo_det_mthd_cd,
            p_information281     => l_abr_rec.prtl_mo_det_mthd_rl,
            p_information20     => l_abr_rec.prtl_mo_eff_dt_det_cd,
            p_information280     => l_abr_rec.prtl_mo_eff_dt_det_rl,
            p_information272     => l_abr_rec.ptd_comp_lvl_fctr_id,
            p_information259     => l_abr_rec.ptip_id,
            p_information13     => l_abr_rec.rcrrg_cd,
            p_information15     => l_abr_rec.rndg_cd,
            p_information279     => l_abr_rec.rndg_rl,
            p_information54     => l_abr_rec.rt_mlt_cd,
            p_information50     => l_abr_rec.rt_typ_cd,
            p_information21     => l_abr_rec.rt_usg_cd,
            p_information22     => l_abr_rec.subj_to_imptd_incm_flag,
            p_information55     => l_abr_rec.sub_acty_typ_cd,
            p_information257     => l_abr_rec.ttl_comp_lvl_fctr_id,
            p_information52     => l_abr_rec.tx_typ_cd,
            p_information269     => l_abr_rec.upr_lmt_calc_rl,
            p_information301     => l_abr_rec.upr_lmt_val,
            p_information30     => l_abr_rec.use_calc_acty_bs_rt_flag,
            p_information25     => l_abr_rec.use_to_calc_net_flx_cr_flag,
            p_information31     => l_abr_rec.uses_ded_sched_flag,
            p_information37     => l_abr_rec.uses_pymt_sched_flag,
            p_information32     => l_abr_rec.uses_varbl_rt_flag,
            p_information295     => l_abr_rec.val,
            p_information282     => l_abr_rec.val_calc_rl,
            p_information38     => l_abr_rec.val_ovrid_alwd_flag,
            p_information271     => l_abr_rec.vstg_for_acty_rt_id,
            p_information33     => l_abr_rec.vstg_sched_apls_flag,
            p_information270     => l_abr_rec.wsh_rl_dy_mo_num,
            p_information283     => l_pl_id,
            p_INFORMATION186	 => l_abr_rec.MAPPING_TABLE_NAME,   /* Bug 4169120 : Rate By Criteria */
            p_INFORMATION284     => l_abr_rec.MAPPING_TABLE_PK_ID,  /* Bug 4169120 : Rate By Criteria */
            p_INFORMATION285     => l_abr_rec.MN_MX_ELCN_RL,        /* Bug 4169044 : Min/Max Rule */
            p_INFORMATION286     => l_abr_rec.RATE_PERIODIZATION_RL, /* Bug 3700087 : Rate Periodization Rule */
            p_INFORMATION56      => l_abr_rec.RATE_PERIODIZATION_CD, /* Bug 3700087 : Rate Periodization Code */
            p_INFORMATION302      => l_abr_rec.CONTEXT_PGM_ID, /* Bug 4725928 */
            p_INFORMATION303      => l_abr_rec.CONTEXT_PL_ID, /* Bug 4725928 */
            p_INFORMATION304      => l_abr_rec.CONTEXT_OPT_ID, /* Bug 4725928 */
	    p_INFORMATION287      => l_abr_rec.ELEMENT_DET_RL ,        /* Bug 4926267 : CWB Multiple currency  */
	    p_INFORMATION57       => l_abr_rec.CURRENCY_DET_CD,        /* Bug 4926267 : CWB Multiple currency  */
            p_INFORMATION221      => l_abr_rec.ABR_SEQ_NUM,            /* Absenses Enhancement */
            p_information166      => l_element_type_start_date,
            p_information306     => l_input_value_start_date,
            p_information265    => l_abr_rec.object_version_number,
           --
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_abr_result_id is null then
              l_out_abr_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_abr_result_id := l_copy_entity_result_id;
            end if;
            --
            --
            -- To pass as effective date while creating the
            -- non date-tracked child records
            if l_abr_acty_base_rt_esd is null then
              l_abr_acty_base_rt_esd := l_abr_rec.EFFECTIVE_START_DATE;
            end if;

             ---------------------------------------------------------------
             ------------------ RATE_PERIODIZATION_RL  ---------------------
             ---------------------------------------------------------------
             --
             -- Bug 3700087 : Rate Periodization Rule
             --
             if l_abr_rec.RATE_PERIODIZATION_RL is not null
             then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.RATE_PERIODIZATION_RL
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );
                --
             end if;
             --
             ---------------------------------------------------------------
             ----------------------- MN_MX_ELCN_RL  ------------------------
             ---------------------------------------------------------------
             --
             -- Bug 4169044 : Min/Max Rule
             --
             if l_abr_rec.MN_MX_ELCN_RL is not null
             then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.MN_MX_ELCN_RL
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );
                --
             end if;
             --
             ---------------------------------------------------------------
             -- Copy Lower Limit Calculation Rules if any  (LWR_LMT_CALC_rl
             ---------------------------------------------------------------
             if l_abr_rec.lwr_lmt_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.lwr_lmt_calc_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
             end if;

             ---------------------------------------------------------------
             -- PRORT_MN_ANN_ELCN_VAL_RL  -----------------
             ---------------------------------------------------------------

             if l_abr_rec.prort_mn_ann_elcn_val_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.prort_mn_ann_elcn_val_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
             end if;


             ---------------------------------------------------------------
             -- PRORT_MX_ANN_ELCN_VAL_RL -----------------
             ---------------------------------------------------------------

             if l_abr_rec.prort_mx_ann_elcn_val_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.prort_mx_ann_elcn_val_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
             end if;


             ---------------------------------------------------------------
             -- PRTL_MO_DET_MTHD_RL -----------------
             ---------------------------------------------------------------


             if l_abr_rec.prtl_mo_det_mthd_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.prtl_mo_det_mthd_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
              end if;


             ---------------------------------------------------------------
             -- PRTL_MO_EFF_DT_DET_RL -----------------
             ---------------------------------------------------------------

             if l_abr_rec.prtl_mo_eff_dt_det_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.prtl_mo_eff_dt_det_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
             end if;

             ---------------------------------------------------------------
             -- RNDG_RL -----------------
             ---------------------------------------------------------------

             if l_abr_rec.rndg_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.rndg_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
             end if;

             ---------------------------------------------------------------
             -- Copy Upper Limit Calculation Rules if any (UPR_LMT_CALC_rl
             ---------------------------------------------------------------

             if l_abr_rec.upr_lmt_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.upr_lmt_calc_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
              end if;

              ---------------------------------------------------------------
              -- Copy Value Rules if any (VAL_CALC_rl -----------------
              ---------------------------------------------------------------

             if l_abr_rec.val_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.val_calc_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
              end if;

              ---------------------------------------------------------------
              -- Copy Value Rules if any (input_va_calc_rl -----------------
              ---------------------------------------------------------------

             if l_abr_rec.input_va_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.input_va_calc_rl
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
              end if;

	      ---------------------------------------------------------------
             ----------------------- ELEMENT_DET_RL  ------------------------
             ---------------------------------------------------------------
             --
             --  Bug 4926267 : CWB Multiple currency
             --
             if l_abr_rec.ELEMENT_DET_RL is not null
             then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_abr_rec.ELEMENT_DET_RL
                ,p_business_group_id              =>  l_abr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );
                --
             end if;

              ---------------------------------------------------------------
              --  COMP_LVL_FCTR -----------------
              ---------------------------------------------------------------

              if l_abr_rec.comp_lvl_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_abr_rec.comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;

              if l_abr_rec.ttl_comp_lvl_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_abr_rec.ttl_comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;

              if l_abr_rec.clm_comp_lvl_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_abr_rec.clm_comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;

              if l_abr_rec.ptd_comp_lvl_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_abr_rec.ptd_comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;

         end loop;

     ---------------------------------------------------------------
     -- START OF BEN_ACTY_RT_PYMT_SCHED_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_apf_from_parent(l_ACTY_BASE_RT_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_abr_result_id ;
        --
        l_acty_rt_pymt_sched_id := l_parent_rec.acty_rt_pymt_sched_id ;
        --
        for l_apf_rec in c_apf(l_parent_rec.acty_rt_pymt_sched_id,l_mirror_src_entity_result_id,'APF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('APF');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  :=  hr_general.decode_lookup('BEN_PYMT_SCHED',l_apf_rec.pymt_sched_cd); --'Intersection';
          --
          if p_effective_date between l_apf_rec.effective_start_date
             and l_apf_rec.effective_end_date then
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
	    P_TABLE_ALIAS                    => 'APF',
            p_information1     => l_apf_rec.acty_rt_pymt_sched_id,
            p_information2     => l_apf_rec.EFFECTIVE_START_DATE,
            p_information3     => l_apf_rec.EFFECTIVE_END_DATE,
            p_information4     => l_apf_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information253     => l_apf_rec.acty_base_rt_id,
            p_information111     => l_apf_rec.apf_attribute1,
            p_information120     => l_apf_rec.apf_attribute10,
            p_information121     => l_apf_rec.apf_attribute11,
            p_information122     => l_apf_rec.apf_attribute12,
            p_information123     => l_apf_rec.apf_attribute13,
            p_information124     => l_apf_rec.apf_attribute14,
            p_information125     => l_apf_rec.apf_attribute15,
            p_information126     => l_apf_rec.apf_attribute16,
            p_information127     => l_apf_rec.apf_attribute17,
            p_information128     => l_apf_rec.apf_attribute18,
            p_information129     => l_apf_rec.apf_attribute19,
            p_information112     => l_apf_rec.apf_attribute2,
            p_information130     => l_apf_rec.apf_attribute20,
            p_information131     => l_apf_rec.apf_attribute21,
            p_information132     => l_apf_rec.apf_attribute22,
            p_information133     => l_apf_rec.apf_attribute23,
            p_information134     => l_apf_rec.apf_attribute24,
            p_information135     => l_apf_rec.apf_attribute25,
            p_information136     => l_apf_rec.apf_attribute26,
            p_information137     => l_apf_rec.apf_attribute27,
            p_information138     => l_apf_rec.apf_attribute28,
            p_information139     => l_apf_rec.apf_attribute29,
            p_information113     => l_apf_rec.apf_attribute3,
            p_information140     => l_apf_rec.apf_attribute30,
            p_information114     => l_apf_rec.apf_attribute4,
            p_information115     => l_apf_rec.apf_attribute5,
            p_information116     => l_apf_rec.apf_attribute6,
            p_information117     => l_apf_rec.apf_attribute7,
            p_information118     => l_apf_rec.apf_attribute8,
            p_information119     => l_apf_rec.apf_attribute9,
            p_information110     => l_apf_rec.apf_attribute_category,
            p_information11     => l_apf_rec.pymt_sched_cd,
            p_information257     => l_apf_rec.pymt_sched_rl,
            p_information265    => l_apf_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_apf_result_id is null then
              l_out_apf_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_apf_result_id := l_copy_entity_result_id ;
            end if;
            --
             ---------------------------------------------------------------
             -- PYMT_SCHED_RL --
             ---------------------------------------------------------------
             --
             if l_apf_rec.pymt_sched_rl is not null then
               --
               ben_plan_design_program_module.create_formula_result
               (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_apf_rec.pymt_sched_rl
                ,p_business_group_id              =>  l_apf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );
                --
           end if;
           --
      end loop;
     --
     end loop;

    ---------------------------------------------------------------
     -- END OF BEN_ACTY_RT_PYMT_SCHED_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PYMT_SCHED_PY_FREQ ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_psq_from_parent(l_ACTY_RT_PYMT_SCHED_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_apf_result_id ;
        --
        l_pymt_sched_py_freq_id := l_parent_rec.pymt_sched_py_freq_id ;
        --
        for l_psq_rec in c_psq(l_parent_rec.pymt_sched_py_freq_id,l_mirror_src_entity_result_id,'PSQ') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('PSQ');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := hr_general.decode_lookup('BEN_FREQ',l_psq_rec.py_freq_cd); --'Intersection';
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
	    P_TABLE_ALIAS                    => 'PSQ',
            p_information1     => l_psq_rec.pymt_sched_py_freq_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_psq_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information257     => l_psq_rec.acty_rt_pymt_sched_id,
            p_information12     => l_psq_rec.dflt_flag,
            p_information111     => l_psq_rec.psq_attribute1,
            p_information120     => l_psq_rec.psq_attribute10,
            p_information121     => l_psq_rec.psq_attribute11,
            p_information122     => l_psq_rec.psq_attribute12,
            p_information123     => l_psq_rec.psq_attribute13,
            p_information124     => l_psq_rec.psq_attribute14,
            p_information125     => l_psq_rec.psq_attribute15,
            p_information126     => l_psq_rec.psq_attribute16,
            p_information127     => l_psq_rec.psq_attribute17,
            p_information128     => l_psq_rec.psq_attribute18,
            p_information129     => l_psq_rec.psq_attribute19,
            p_information112     => l_psq_rec.psq_attribute2,
            p_information130     => l_psq_rec.psq_attribute20,
            p_information131     => l_psq_rec.psq_attribute21,
            p_information132     => l_psq_rec.psq_attribute22,
            p_information133     => l_psq_rec.psq_attribute23,
            p_information134     => l_psq_rec.psq_attribute24,
            p_information135     => l_psq_rec.psq_attribute25,
            p_information136     => l_psq_rec.psq_attribute26,
            p_information137     => l_psq_rec.psq_attribute27,
            p_information138     => l_psq_rec.psq_attribute28,
            p_information139     => l_psq_rec.psq_attribute29,
            p_information113     => l_psq_rec.psq_attribute3,
            p_information140     => l_psq_rec.psq_attribute30,
            p_information114     => l_psq_rec.psq_attribute4,
            p_information115     => l_psq_rec.psq_attribute5,
            p_information116     => l_psq_rec.psq_attribute6,
            p_information117     => l_psq_rec.psq_attribute7,
            p_information118     => l_psq_rec.psq_attribute8,
            p_information119     => l_psq_rec.psq_attribute9,
            p_information110     => l_psq_rec.psq_attribute_category,
            p_information11     => l_psq_rec.py_freq_cd,
            p_information265    => l_psq_rec.object_version_number,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_psq_result_id is null then
              l_out_psq_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_psq_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_PYMT_SCHED_PY_FREQ ----------------------
    ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_ACTL_PREM_F ----------------------
        ---------------------------------------------------------------
        --
        /*
        **  NOT REQUIRED here as Premium Data will get copied with the Plan
        **  or Option to which they are attached - handled by create_premium_results call
        */

        ---------------------------------------------------------------
        -- START OF BEN_ACTY_RT_PTD_LMT_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_apl_from_parent(l_ACTY_BASE_RT_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_abr_result_id ;

           --
           l_acty_rt_ptd_lmt_id := l_parent_rec.acty_rt_ptd_lmt_id ;
           --
           for l_apl_rec in c_apl(l_parent_rec.acty_rt_ptd_lmt_id,l_mirror_src_entity_result_id,'APL1') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('APL1');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_ptd_lmt_name(l_apl_rec.ptd_lmt_id,p_effective_date);
                                --'Intersection';
             --
             if p_effective_date between l_apl_rec.effective_start_date
                and l_apl_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'APL1',
               p_information1     => l_apl_rec.acty_rt_ptd_lmt_id,
               p_information2     => l_apl_rec.EFFECTIVE_START_DATE,
               p_information3     => l_apl_rec.EFFECTIVE_END_DATE,
               p_information4     => l_apl_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information253     => l_apl_rec.acty_base_rt_id,
            p_information111     => l_apl_rec.apl_attribute1,
            p_information120     => l_apl_rec.apl_attribute10,
            p_information121     => l_apl_rec.apl_attribute11,
            p_information122     => l_apl_rec.apl_attribute12,
            p_information123     => l_apl_rec.apl_attribute13,
            p_information124     => l_apl_rec.apl_attribute14,
            p_information125     => l_apl_rec.apl_attribute15,
            p_information126     => l_apl_rec.apl_attribute16,
            p_information127     => l_apl_rec.apl_attribute17,
            p_information128     => l_apl_rec.apl_attribute18,
            p_information129     => l_apl_rec.apl_attribute19,
            p_information112     => l_apl_rec.apl_attribute2,
            p_information130     => l_apl_rec.apl_attribute20,
            p_information131     => l_apl_rec.apl_attribute21,
            p_information132     => l_apl_rec.apl_attribute22,
            p_information133     => l_apl_rec.apl_attribute23,
            p_information134     => l_apl_rec.apl_attribute24,
            p_information135     => l_apl_rec.apl_attribute25,
            p_information136     => l_apl_rec.apl_attribute26,
            p_information137     => l_apl_rec.apl_attribute27,
            p_information138     => l_apl_rec.apl_attribute28,
            p_information139     => l_apl_rec.apl_attribute29,
            p_information113     => l_apl_rec.apl_attribute3,
            p_information140     => l_apl_rec.apl_attribute30,
            p_information114     => l_apl_rec.apl_attribute4,
            p_information115     => l_apl_rec.apl_attribute5,
            p_information116     => l_apl_rec.apl_attribute6,
            p_information117     => l_apl_rec.apl_attribute7,
            p_information118     => l_apl_rec.apl_attribute8,
            p_information119     => l_apl_rec.apl_attribute9,
            p_information110     => l_apl_rec.apl_attribute_category,
            p_information257     => l_apl_rec.ptd_lmt_id,
            p_information265     => l_apl_rec.object_version_number,
           --

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_apl_result_id is null then
                 l_out_apl_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_apl_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;
            --
           ---------------------------------------------------------------
           -- START OF BEN_PTD_LMT_F ----------------------
           ---------------------------------------------------------------
           --
           for l_parent_rec  in c_pdl_from_parent(l_ACTY_RT_PTD_LMT_ID) loop
              --
              l_mirror_src_entity_result_id := l_out_apl_result_id ;

              --
              l_ptd_lmt_id := l_parent_rec.ptd_lmt_id ;
              --
              if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
                open c_object_exists(l_ptd_lmt_id,'PDL');
                fetch c_object_exists into l_dummy;
                if c_object_exists%found then
                  close c_object_exists;
                  exit;
                end if;
                close c_object_exists;
              end if;

              for l_pdl_rec in c_pdl(l_parent_rec.ptd_lmt_id,l_mirror_src_entity_result_id,'PDL') loop
                --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('PDL');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := l_pdl_rec.name; --'Intersection';
                --
                if p_effective_date between l_pdl_rec.effective_start_date
                   and l_pdl_rec.effective_end_date then
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
		  P_TABLE_ALIAS                    => 'PDL',
                  p_information1     => l_pdl_rec.ptd_lmt_id,
                  p_information2     => l_pdl_rec.EFFECTIVE_START_DATE,
                  p_information3     => l_pdl_rec.EFFECTIVE_END_DATE,
                  p_information4     => l_pdl_rec.business_group_id,
                  p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information260     => l_pdl_rec.balance_type_id,
            p_information254     => l_pdl_rec.comp_lvl_fctr_id,
            p_information11     => l_pdl_rec.lmt_det_cd,
            p_information293     => l_pdl_rec.mx_comp_to_cnsdr,
            p_information295     => l_pdl_rec.mx_pct_val,
            p_information294     => l_pdl_rec.mx_val,
            p_information170     => l_pdl_rec.name,
            p_information111     => l_pdl_rec.pdl_attribute1,
            p_information120     => l_pdl_rec.pdl_attribute10,
            p_information121     => l_pdl_rec.pdl_attribute11,
            p_information122     => l_pdl_rec.pdl_attribute12,
            p_information123     => l_pdl_rec.pdl_attribute13,
            p_information124     => l_pdl_rec.pdl_attribute14,
            p_information125     => l_pdl_rec.pdl_attribute15,
            p_information126     => l_pdl_rec.pdl_attribute16,
            p_information127     => l_pdl_rec.pdl_attribute17,
            p_information128     => l_pdl_rec.pdl_attribute18,
            p_information129     => l_pdl_rec.pdl_attribute19,
            p_information112     => l_pdl_rec.pdl_attribute2,
            p_information130     => l_pdl_rec.pdl_attribute20,
            p_information131     => l_pdl_rec.pdl_attribute21,
            p_information132     => l_pdl_rec.pdl_attribute22,
            p_information133     => l_pdl_rec.pdl_attribute23,
            p_information134     => l_pdl_rec.pdl_attribute24,
            p_information135     => l_pdl_rec.pdl_attribute25,
            p_information136     => l_pdl_rec.pdl_attribute26,
            p_information137     => l_pdl_rec.pdl_attribute27,
            p_information138     => l_pdl_rec.pdl_attribute28,
            p_information139     => l_pdl_rec.pdl_attribute29,
            p_information113     => l_pdl_rec.pdl_attribute3,
            p_information140     => l_pdl_rec.pdl_attribute30,
            p_information114     => l_pdl_rec.pdl_attribute4,
            p_information115     => l_pdl_rec.pdl_attribute5,
            p_information116     => l_pdl_rec.pdl_attribute6,
            p_information117     => l_pdl_rec.pdl_attribute7,
            p_information118     => l_pdl_rec.pdl_attribute8,
            p_information119     => l_pdl_rec.pdl_attribute9,
            p_information110     => l_pdl_rec.pdl_attribute_category,
            p_information261     => l_pdl_rec.ptd_lmt_calc_rl,
            p_information265     => l_pdl_rec.object_version_number,

                  p_object_version_number          => l_object_version_number,
                  p_effective_date                 => p_effective_date       );
                  --

                  if l_out_pdl_result_id is null then
                    l_out_pdl_result_id := l_copy_entity_result_id;
                  end if;

                  if l_result_type_cd = 'DISPLAY' then
                     l_out_pdl_result_id := l_copy_entity_result_id ;
                  end if;
                  --

                  -- Copy Fast Formulas if any are attached to any column --
                  ---------------------------------------------------------------
                  -- PTD_LMT_CALC_RL -----------------
                  ---------------------------------------------------------------

                  if l_pdl_rec.ptd_lmt_calc_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_pdl_rec.ptd_lmt_calc_rl
                      ,p_business_group_id              =>  l_pdl_rec.business_group_id
                      ,p_number_of_copies               =>  l_number_of_copies
                      ,p_object_version_number          =>  l_object_version_number
                      ,p_effective_date                 =>  p_effective_date
                      );

                      --
                  end if;

                  ---------------------------------------------------------------
                  --  COMP_LVL_FCTR -----------------
                  ---------------------------------------------------------------

                  if l_pdl_rec.comp_lvl_fctr_id is not null then
                  --
                     create_drpar_results
                     (
                       p_validate                      => p_validate
                      ,p_copy_entity_result_id         => l_copy_entity_result_id
                      ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                      ,p_comp_lvl_fctr_id              => l_pdl_rec.comp_lvl_fctr_id
                      ,p_hrs_wkd_in_perd_fctr_id       => null
                      ,p_los_fctr_id                   => null
                      ,p_pct_fl_tm_fctr_id             => null
                      ,p_age_fctr_id                   => null
                      ,p_cmbn_age_los_fctr_id          => null
                      ,p_business_group_id             => p_business_group_id
                      ,p_number_of_copies              => p_number_of_copies
                      ,p_object_version_number         => l_object_version_number
                      ,p_effective_date                => p_effective_date
                     );
                  --
                  end if;

               end loop;
               --
             end loop;
          ---------------------------------------------------------------
          -- END OF BEN_PTD_LMT_F ----------------------
          ---------------------------------------------------------------
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_ACTY_RT_PTD_LMT_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_ACTY_VRBL_RT_F ----------------------
        ---------------------------------------------------------------
        --
        hr_utility.set_location('c_avr_from_parent l_ACTY_BASE_RT_ID'||l_ACTY_BASE_RT_ID,100);
        for l_parent_rec  in c_avr_from_parent(l_ACTY_BASE_RT_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_abr_result_id ;
           --
           l_acty_vrbl_rt_id := l_parent_rec.acty_vrbl_rt_id ;
           --
           for l_avr_rec in c_avr(l_parent_rec.acty_vrbl_rt_id,l_mirror_src_entity_result_id,'AVR') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('AVR');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_vrbl_rt_prfl_name(l_avr_rec.vrbl_rt_prfl_id,
                                                                                     p_effective_date); --'Intersection';
             --
             if p_effective_date between l_avr_rec.effective_start_date
                and l_avr_rec.effective_end_date then
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
               p_parent_entity_result_id        => null, -- Hide BEN_ACTY_VRBL_RT_F for HGrid
               p_number_of_copies               => l_number_of_copies,
               p_table_route_id                 => l_table_route_id,
	       P_TABLE_ALIAS                    => 'AVR',
               p_information1     => l_avr_rec.acty_vrbl_rt_id,
               p_information2     => l_avr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_avr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_avr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information253     => l_avr_rec.acty_base_rt_id,
            p_information111     => l_avr_rec.avr_attribute1,
            p_information120     => l_avr_rec.avr_attribute10,
            p_information121     => l_avr_rec.avr_attribute11,
            p_information122     => l_avr_rec.avr_attribute12,
            p_information123     => l_avr_rec.avr_attribute13,
            p_information124     => l_avr_rec.avr_attribute14,
            p_information125     => l_avr_rec.avr_attribute15,
            p_information126     => l_avr_rec.avr_attribute16,
            p_information127     => l_avr_rec.avr_attribute17,
            p_information128     => l_avr_rec.avr_attribute18,
            p_information129     => l_avr_rec.avr_attribute19,
            p_information112     => l_avr_rec.avr_attribute2,
            p_information130     => l_avr_rec.avr_attribute20,
            p_information131     => l_avr_rec.avr_attribute21,
            p_information132     => l_avr_rec.avr_attribute22,
            p_information133     => l_avr_rec.avr_attribute23,
            p_information134     => l_avr_rec.avr_attribute24,
            p_information135     => l_avr_rec.avr_attribute25,
            p_information136     => l_avr_rec.avr_attribute26,
            p_information137     => l_avr_rec.avr_attribute27,
            p_information138     => l_avr_rec.avr_attribute28,
            p_information139     => l_avr_rec.avr_attribute29,
            p_information113     => l_avr_rec.avr_attribute3,
            p_information140     => l_avr_rec.avr_attribute30,
            p_information114     => l_avr_rec.avr_attribute4,
            p_information115     => l_avr_rec.avr_attribute5,
            p_information116     => l_avr_rec.avr_attribute6,
            p_information117     => l_avr_rec.avr_attribute7,
            p_information118     => l_avr_rec.avr_attribute8,
            p_information119     => l_avr_rec.avr_attribute9,
            p_information110     => l_avr_rec.avr_attribute_category,
            p_information260     => l_avr_rec.ordr_num,
            p_information262     => l_avr_rec.vrbl_rt_prfl_id,
            p_information265     => l_avr_rec.object_version_number,
               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_avr_result_id is null then
                 l_out_avr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_avr_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;

            for l_avr_rec in c_avr_drp(l_parent_rec.acty_vrbl_rt_id,l_mirror_src_entity_result_id,'AVR') loop
              -----------------------------------------------------------------------------------------
              -- Call to VAPRO
              -----------------------------------------------------------------------------------------
              hr_utility.set_location('l_avr_rec.vrbl_rt_prfl_id '||l_avr_rec.vrbl_rt_prfl_id,100);
              create_vapro_results
                (
                 p_validate                    => p_validate
                ,p_copy_entity_result_id       => l_out_avr_result_id
                ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                ,p_vrbl_rt_prfl_id             => l_avr_rec.vrbl_rt_prfl_id
                ,p_business_group_id           => p_business_group_id
                ,p_number_of_copies            => p_number_of_copies
                ,p_object_version_number       => p_object_version_number
                ,p_effective_date              => p_effective_date
                ,p_parent_entity_result_id     => l_out_abr_result_id
                ) ;
            end loop;
            --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_ACTY_VRBL_RT_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_MTCHG_RT_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_mtr_from_parent(l_ACTY_BASE_RT_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_abr_result_id ;
           --
           l_mtchg_rt_id := l_parent_rec.mtchg_rt_id ;
           --
           for l_mtr_rec in c_mtr(l_parent_rec.mtchg_rt_id,l_mirror_src_entity_result_id,'MTR') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('MTR');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := l_mtr_rec.from_pct_val ||' - '|| l_mtr_rec.to_pct_val; --'Intersection';
             --
             if p_effective_date between l_mtr_rec.effective_start_date
                and l_mtr_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'MTR',
               p_information1     => l_mtr_rec.mtchg_rt_id,
               p_information2     => l_mtr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_mtr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_mtr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information253     => l_mtr_rec.acty_base_rt_id,
            p_information13     => l_mtr_rec.cntnu_mtch_aftr_mx_rl_flag,
            p_information254     => l_mtr_rec.comp_lvl_fctr_id,
            p_information293     => l_mtr_rec.from_pct_val,
            p_information299     => l_mtr_rec.mn_mtch_amt,
            p_information261     => l_mtr_rec.mtchg_rt_calc_rl,
            p_information111     => l_mtr_rec.mtr_attribute1,
            p_information120     => l_mtr_rec.mtr_attribute10,
            p_information121     => l_mtr_rec.mtr_attribute11,
            p_information122     => l_mtr_rec.mtr_attribute12,
            p_information123     => l_mtr_rec.mtr_attribute13,
            p_information124     => l_mtr_rec.mtr_attribute14,
            p_information125     => l_mtr_rec.mtr_attribute15,
            p_information126     => l_mtr_rec.mtr_attribute16,
            p_information127     => l_mtr_rec.mtr_attribute17,
            p_information128     => l_mtr_rec.mtr_attribute18,
            p_information129     => l_mtr_rec.mtr_attribute19,
            p_information112     => l_mtr_rec.mtr_attribute2,
            p_information130     => l_mtr_rec.mtr_attribute20,
            p_information131     => l_mtr_rec.mtr_attribute21,
            p_information132     => l_mtr_rec.mtr_attribute22,
            p_information133     => l_mtr_rec.mtr_attribute23,
            p_information134     => l_mtr_rec.mtr_attribute24,
            p_information135     => l_mtr_rec.mtr_attribute25,
            p_information136     => l_mtr_rec.mtr_attribute26,
            p_information137     => l_mtr_rec.mtr_attribute27,
            p_information138     => l_mtr_rec.mtr_attribute28,
            p_information139     => l_mtr_rec.mtr_attribute29,
            p_information113     => l_mtr_rec.mtr_attribute3,
            p_information140     => l_mtr_rec.mtr_attribute30,
            p_information114     => l_mtr_rec.mtr_attribute4,
            p_information115     => l_mtr_rec.mtr_attribute5,
            p_information116     => l_mtr_rec.mtr_attribute6,
            p_information117     => l_mtr_rec.mtr_attribute7,
            p_information118     => l_mtr_rec.mtr_attribute8,
            p_information119     => l_mtr_rec.mtr_attribute9,
            p_information110     => l_mtr_rec.mtr_attribute_category,
            p_information296     => l_mtr_rec.mx_amt_of_py_num,
            p_information298     => l_mtr_rec.mx_mtch_amt,
            p_information297     => l_mtr_rec.mx_pct_of_py_num,
            p_information14     => l_mtr_rec.no_mx_amt_of_py_num_flag,
            p_information11     => l_mtr_rec.no_mx_mtch_amt_flag,
            p_information12     => l_mtr_rec.no_mx_pct_of_py_num_flag,
            p_information257     => l_mtr_rec.ordr_num,
            p_information295     => l_mtr_rec.pct_val,
            p_information294     => l_mtr_rec.to_pct_val,
            p_information265     => l_mtr_rec.object_version_number,

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_mtr_result_id is null then
                 l_out_mtr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_mtr_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- MTCHG_RT_CALC_RL -----------------
               ---------------------------------------------------------------

               if l_mtr_rec.mtchg_rt_calc_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_mtr_rec.mtchg_rt_calc_rl
                      ,p_business_group_id              =>  l_mtr_rec.business_group_id
                      ,p_number_of_copies               =>  l_number_of_copies
                      ,p_object_version_number          =>  l_object_version_number
                      ,p_effective_date                 =>  p_effective_date
                      );

                      --
               end if;


               ---------------------------------------------------------------
               --  COMP_LVL_FCTR -----------------
               ---------------------------------------------------------------

               if l_mtr_rec.comp_lvl_fctr_id is not null then
               --
                     create_drpar_results
                     (
                       p_validate                      => p_validate
                      ,p_copy_entity_result_id         => l_copy_entity_result_id
                      ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                      ,p_comp_lvl_fctr_id              => l_mtr_rec.comp_lvl_fctr_id
                      ,p_hrs_wkd_in_perd_fctr_id       => null
                      ,p_los_fctr_id                   => null
                      ,p_pct_fl_tm_fctr_id             => null
                      ,p_age_fctr_id                   => null
                      ,p_cmbn_age_los_fctr_id          => null
                      ,p_business_group_id             => p_business_group_id
                      ,p_number_of_copies              => p_number_of_copies
                      ,p_object_version_number         => l_object_version_number
                      ,p_effective_date                => p_effective_date
                     );
               --
               end if;

            end loop;
            --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_MTCHG_RT_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_pmr_from_parent(l_ACTY_BASE_RT_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_abr_result_id ;
           --
           l_prtl_mo_rt_prtn_val_id := l_parent_rec.prtl_mo_rt_prtn_val_id ;
           --
           for l_pmr_rec in c_pmr(l_parent_rec.prtl_mo_rt_prtn_val_id,l_mirror_src_entity_result_id,'PMRPV') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('PMRPV');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := l_pmr_rec.from_dy_mo_num ||' - '||l_pmr_rec.to_dy_mo_num ;
             if l_pmr_rec.pct_val is not null then
               l_information5 := l_information5 ||' '||l_pmr_rec.pct_val||'%';
             end if;
             -- 'Intersection';
             --
             if p_effective_date between l_pmr_rec.effective_start_date
                and l_pmr_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'PMRPV',
               p_information1     => l_pmr_rec.prtl_mo_rt_prtn_val_id,
               p_information2     => l_pmr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_pmr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_pmr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information250     => l_pmr_rec.actl_prem_id,
            p_information253     => l_pmr_rec.acty_base_rt_id,
            p_information238     => l_pmr_rec.cvg_amt_calc_mthd_id,
            p_information261     => l_pmr_rec.from_dy_mo_num,
            p_information293     => l_pmr_rec.pct_val,
            p_information111     => l_pmr_rec.pmrpv_attribute1,
            p_information120     => l_pmr_rec.pmrpv_attribute10,
            p_information121     => l_pmr_rec.pmrpv_attribute11,
            p_information122     => l_pmr_rec.pmrpv_attribute12,
            p_information123     => l_pmr_rec.pmrpv_attribute13,
            p_information124     => l_pmr_rec.pmrpv_attribute14,
            p_information125     => l_pmr_rec.pmrpv_attribute15,
            p_information126     => l_pmr_rec.pmrpv_attribute16,
            p_information127     => l_pmr_rec.pmrpv_attribute17,
            p_information128     => l_pmr_rec.pmrpv_attribute18,
            p_information129     => l_pmr_rec.pmrpv_attribute19,
            p_information112     => l_pmr_rec.pmrpv_attribute2,
            p_information130     => l_pmr_rec.pmrpv_attribute20,
            p_information131     => l_pmr_rec.pmrpv_attribute21,
            p_information132     => l_pmr_rec.pmrpv_attribute22,
            p_information133     => l_pmr_rec.pmrpv_attribute23,
            p_information134     => l_pmr_rec.pmrpv_attribute24,
            p_information135     => l_pmr_rec.pmrpv_attribute25,
            p_information136     => l_pmr_rec.pmrpv_attribute26,
            p_information137     => l_pmr_rec.pmrpv_attribute27,
            p_information138     => l_pmr_rec.pmrpv_attribute28,
            p_information139     => l_pmr_rec.pmrpv_attribute29,
            p_information113     => l_pmr_rec.pmrpv_attribute3,
            p_information140     => l_pmr_rec.pmrpv_attribute30,
            p_information114     => l_pmr_rec.pmrpv_attribute4,
            p_information115     => l_pmr_rec.pmrpv_attribute5,
            p_information116     => l_pmr_rec.pmrpv_attribute6,
            p_information117     => l_pmr_rec.pmrpv_attribute7,
            p_information118     => l_pmr_rec.pmrpv_attribute8,
            p_information119     => l_pmr_rec.pmrpv_attribute9,
            p_information110     => l_pmr_rec.pmrpv_attribute_category,
            p_information263     => l_pmr_rec.prtl_mo_prortn_rl,
            p_information11     => l_pmr_rec.rndg_cd,
            p_information262     => l_pmr_rec.rndg_rl,
            p_information12     => l_pmr_rec.strt_r_stp_cvg_cd,
            p_information260     => l_pmr_rec.to_dy_mo_num,
            p_information265    => l_pmr_rec.object_version_number,
	   --
           -- Bug No 4440138 Added mappings for PRORATE_BY_DAY_TO_MON_FLAG and NUM_DAYS_MONTH
	   --
            p_information13     => l_pmr_rec.PRORATE_BY_DAY_TO_MON_FLAG,
            p_information266    => l_pmr_rec.NUM_DAYS_MONTH,
	   -- End Bug No 4440138
	   --
               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_pmr_result_id is null then
                 l_out_pmr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_pmr_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- PRTL_MO_PRORTN_RL -----------------
               ---------------------------------------------------------------

               if l_pmr_rec.prtl_mo_prortn_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_pmr_rec.prtl_mo_prortn_rl
                      ,p_business_group_id              =>  l_pmr_rec.business_group_id
                      ,p_number_of_copies               =>  l_number_of_copies
                      ,p_object_version_number          =>  l_object_version_number
                      ,p_effective_date                 =>  p_effective_date
                      );

                      --
               end if;



               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- RNDG_RL -----------------
               ---------------------------------------------------------------

               if l_pmr_rec.rndg_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_pmr_rec.rndg_rl
                      ,p_business_group_id              =>  l_pmr_rec.business_group_id
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
       -- END OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
       ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_EXTRA_INPUT_VALUES ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_eiv_from_parent(l_ACTY_BASE_RT_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_abr_result_id ;
        --
        l_extra_input_value_id := l_parent_rec.extra_input_value_id ;
        --
        for l_eiv_rec in c_eiv(l_parent_rec.extra_input_value_id,l_mirror_src_entity_result_id,'EIV') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('EIV');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --

          open c_element_type_id(l_eiv_rec.acty_base_rt_id,
                                 p_copy_entity_txn_id,'ABR');
          fetch c_element_type_id into l_element_type_id_for_eiv;
          close c_element_type_id;

          l_input_value_name := null;

          open c_get_mapping_name2(l_eiv_rec.input_value_id, l_element_type_id_for_eiv,p_effective_date);
          fetch c_get_mapping_name2 into l_input_value_name;
          close c_get_mapping_name2;

          l_information5  := l_input_value_name; --'Intersection';
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
	    P_TABLE_ALIAS                    => 'EIV',
            p_information1     => l_eiv_rec.extra_input_value_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_eiv_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information10     =>  l_abr_acty_base_rt_esd,
            p_information253     => l_eiv_rec.acty_base_rt_id,
            p_information111     => l_eiv_rec.eiv_attribute1,
            p_information120     => l_eiv_rec.eiv_attribute10,
            p_information121     => l_eiv_rec.eiv_attribute11,
            p_information122     => l_eiv_rec.eiv_attribute12,
            p_information123     => l_eiv_rec.eiv_attribute13,
            p_information124     => l_eiv_rec.eiv_attribute14,
            p_information125     => l_eiv_rec.eiv_attribute15,
            p_information126     => l_eiv_rec.eiv_attribute16,
            p_information127     => l_eiv_rec.eiv_attribute17,
            p_information128     => l_eiv_rec.eiv_attribute18,
            p_information129     => l_eiv_rec.eiv_attribute19,
            p_information112     => l_eiv_rec.eiv_attribute2,
            p_information130     => l_eiv_rec.eiv_attribute20,
            p_information131     => l_eiv_rec.eiv_attribute21,
            p_information132     => l_eiv_rec.eiv_attribute22,
            p_information133     => l_eiv_rec.eiv_attribute23,
            p_information134     => l_eiv_rec.eiv_attribute24,
            p_information135     => l_eiv_rec.eiv_attribute25,
            p_information136     => l_eiv_rec.eiv_attribute26,
            p_information137     => l_eiv_rec.eiv_attribute27,
            p_information138     => l_eiv_rec.eiv_attribute28,
            p_information139     => l_eiv_rec.eiv_attribute29,
            p_information113     => l_eiv_rec.eiv_attribute3,
            p_information140     => l_eiv_rec.eiv_attribute30,
            p_information114     => l_eiv_rec.eiv_attribute4,
            p_information115     => l_eiv_rec.eiv_attribute5,
            p_information116     => l_eiv_rec.eiv_attribute6,
            p_information117     => l_eiv_rec.eiv_attribute7,
            p_information118     => l_eiv_rec.eiv_attribute8,
            p_information119     => l_eiv_rec.eiv_attribute9,
            p_information110     => l_eiv_rec.eiv_attribute_category,
            p_information260     => l_eiv_rec.extra_input_value_id,
            p_information185     => l_eiv_rec.input_text,
            p_information261     => l_eiv_rec.input_value_id,
            p_information186     => l_eiv_rec.return_var_name,
            p_information11     => l_eiv_rec.upd_when_ele_ended_cd,
            p_information265    => l_eiv_rec.object_version_number,

            p_information173    => l_input_value_name,
            p_information174    => l_eiv_rec.input_value_id,
            --
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_eiv_result_id is null then
              l_out_eiv_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_eiv_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
      end loop;
      ---------------------------------------------------------------
      -- END OF BEN_EXTRA_INPUT_VALUES ----------------------
      ---------------------------------------------------------------
      ---------------------------------------------------------------
      -- START OF BEN_ACTY_BASE_RT_CTFN_F ----------------------
      ---------------------------------------------------------------
      --
      for l_parent_rec  in c_abc_from_parent(l_ACTY_BASE_RT_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_abr_result_id ;
        --
        l_acty_base_rt_ctfn_id := l_parent_rec.acty_base_rt_ctfn_id ;
        --
        for l_abc_rec in c_abc(l_parent_rec.acty_base_rt_ctfn_id,l_mirror_src_entity_result_id,'ABC') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('ABC');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := hr_general.decode_lookup('BEN_ENRT_CTFN_TYP',l_abc_rec.enrt_ctfn_typ_cd);
                             --'Intersection';
          --
          if p_effective_date between l_abc_rec.effective_start_date
             and l_abc_rec.effective_end_date then
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
	    P_TABLE_ALIAS                    => 'ABC',
            p_information1     => l_abc_rec.acty_base_rt_ctfn_id,
            p_information2     => l_abc_rec.EFFECTIVE_START_DATE,
            p_information3     => l_abc_rec.EFFECTIVE_END_DATE,
            p_information4     => l_abc_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information111     => l_abc_rec.abc_attribute1,
            p_information120     => l_abc_rec.abc_attribute10,
            p_information121     => l_abc_rec.abc_attribute11,
            p_information122     => l_abc_rec.abc_attribute12,
            p_information123     => l_abc_rec.abc_attribute13,
            p_information124     => l_abc_rec.abc_attribute14,
            p_information125     => l_abc_rec.abc_attribute15,
            p_information126     => l_abc_rec.abc_attribute16,
            p_information127     => l_abc_rec.abc_attribute17,
            p_information128     => l_abc_rec.abc_attribute18,
            p_information129     => l_abc_rec.abc_attribute19,
            p_information112     => l_abc_rec.abc_attribute2,
            p_information130     => l_abc_rec.abc_attribute20,
            p_information131     => l_abc_rec.abc_attribute21,
            p_information132     => l_abc_rec.abc_attribute22,
            p_information133     => l_abc_rec.abc_attribute23,
            p_information134     => l_abc_rec.abc_attribute24,
            p_information135     => l_abc_rec.abc_attribute25,
            p_information136     => l_abc_rec.abc_attribute26,
            p_information137     => l_abc_rec.abc_attribute27,
            p_information138     => l_abc_rec.abc_attribute28,
            p_information139     => l_abc_rec.abc_attribute29,
            p_information113     => l_abc_rec.abc_attribute3,
            p_information140     => l_abc_rec.abc_attribute30,
            p_information114     => l_abc_rec.abc_attribute4,
            p_information115     => l_abc_rec.abc_attribute5,
            p_information116     => l_abc_rec.abc_attribute6,
            p_information117     => l_abc_rec.abc_attribute7,
            p_information118     => l_abc_rec.abc_attribute8,
            p_information119     => l_abc_rec.abc_attribute9,
            p_information110     => l_abc_rec.abc_attribute_category,
            p_information253     => l_abc_rec.acty_base_rt_id,
            p_information260     => l_abc_rec.ctfn_rqd_when_rl,
            p_information11     => l_abc_rec.enrt_ctfn_typ_cd,
            p_information12     => l_abc_rec.rqd_flag,
            p_information265    => l_abc_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_abc_result_id is null then
              l_out_abc_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_abc_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas if any are attached to any column --
            ---------------------------------------------------------------
            -- CTFN_RQD_WHEN_RL -----------------
            ---------------------------------------------------------------

            if l_abc_rec.ctfn_rqd_when_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_abc_rec.ctfn_rqd_when_rl
                      ,p_business_group_id              =>  l_abc_rec.business_group_id
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
      -- END OF BEN_ACTY_BASE_RT_CTFN_F ----------------------
      ---------------------------------------------------------------
      --
    end loop;
    ---------------------------------------------------------------
    -- END OF BEN_ACTY_BASE_RT_F ----------------------
    ---------------------------------------------------------------
  end create_rate_results;
  --
  procedure create_coverage_results
    (
     p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Source Elpro
    ,p_copy_entity_txn_id             in  number    default null
    ,p_plip_id                        in  number    default null
    ,p_pl_id                          in  number    default null
    ,p_oipl_id                        in  number    default null
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in number
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
          pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_CVG_AMT_CALC_MTHD_F ----------------------
   ---------------------------------------------------------------
   cursor c_ccm_from_parent( c_pl_id number,c_plip_id number, c_oipl_id number ) is
   select distinct cvg_amt_calc_mthd_id
   from BEN_CVG_AMT_CALC_MTHD_F
   where  (c_pl_id is not null and pl_id = c_pl_id) or
          (c_plip_id is not null and c_plip_id = plip_id) or
          (c_oipl_id is not null and c_oipl_id = oipl_id)  ;
   --
   cursor c_ccm(c_cvg_amt_calc_mthd_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  ccm.*
   from BEN_CVG_AMT_CALC_MTHD_F ccm
   where  ccm.cvg_amt_calc_mthd_id = c_cvg_amt_calc_mthd_id
     -- and ccm.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CVG_AMT_CALC_MTHD_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_cvg_amt_calc_mthd_id
         -- and information4 = ccm.business_group_id
           and information2 = ccm.effective_start_date
           and information3 = ccm.effective_end_date);
    l_cvg_amt_calc_mthd_id                 number(15);
    l_out_ccm_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CVG_AMT_CALC_MTHD_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_BNFT_VRBL_RT_RL_F ----------------------
   ---------------------------------------------------------------
   cursor c_brr_from_parent(c_CVG_AMT_CALC_MTHD_ID number) is
   select  bnft_vrbl_rt_rl_id
   from BEN_BNFT_VRBL_RT_RL_F
   where  CVG_AMT_CALC_MTHD_ID = c_CVG_AMT_CALC_MTHD_ID ;
   --
   cursor c_brr(c_bnft_vrbl_rt_rl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  brr.*
   from BEN_BNFT_VRBL_RT_RL_F brr
   where  brr.bnft_vrbl_rt_rl_id = c_bnft_vrbl_rt_rl_id
     -- and brr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
       --  and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BNFT_VRBL_RT_RL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_bnft_vrbl_rt_rl_id
         -- and information4 = brr.business_group_id
           and information2 = brr.effective_start_date
           and information3 = brr.effective_end_date);
    l_bnft_vrbl_rt_rl_id                 number(15);
    l_out_brr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BNFT_VRBL_RT_RL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_BNFT_VRBL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_bvr_from_parent(c_CVG_AMT_CALC_MTHD_ID number) is
   select distinct bnft_vrbl_rt_id
   from BEN_BNFT_VRBL_RT_F
   where  CVG_AMT_CALC_MTHD_ID = c_CVG_AMT_CALC_MTHD_ID ;
   --
   cursor c_bvr(c_bnft_vrbl_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  bvr.*
   from BEN_BNFT_VRBL_RT_F bvr
   where  bvr.bnft_vrbl_rt_id = c_bnft_vrbl_rt_id
     -- and bvr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BNFT_VRBL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_bnft_vrbl_rt_id
         -- and information4 = bvr.business_group_id
           and information2 = bvr.effective_start_date
           and information3 = bvr.effective_end_date);
    --
   cursor c_bvr_drp(c_bnft_vrbl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information262 vrbl_rt_prfl_id
     from ben_copy_entity_results cpe
          -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     -- and trt.where_clause = 'BEN_BNFT_VRBL_RT_F'
     and cpe.table_alias = c_table_alias
     and information1 = c_bnft_vrbl_rt_id
     -- and information4 = p_business_group_id
    ;
   --

    l_bnft_vrbl_rt_id                 number(15);
    l_out_bvr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BNFT_VRBL_RT_F ----------------------
   ---------------------------------------------------------------
    begin
     l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_CVG_AMT_CALC_MTHD_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_ccm_from_parent(p_pl_id,p_plip_id,p_oipl_id) loop
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_cvg_amt_calc_mthd_id := l_parent_rec.cvg_amt_calc_mthd_id ;
        --
        for l_ccm_rec in c_ccm(l_parent_rec.cvg_amt_calc_mthd_id,l_mirror_src_entity_result_id,'CCM') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CCM');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_ccm_rec.name; --'Intersection';
          --
          if p_effective_date between l_ccm_rec.effective_start_date
             and l_ccm_rec.effective_end_date then
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
            p_parent_entity_result_id        => p_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'CCM',
            p_information1     => l_ccm_rec.cvg_amt_calc_mthd_id,
            p_information2     => l_ccm_rec.EFFECTIVE_START_DATE,
            p_information3     => l_ccm_rec.EFFECTIVE_END_DATE,
            p_information4     => l_ccm_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information19     => l_ccm_rec.bndry_perd_cd,
            p_information20     => l_ccm_rec.bnft_typ_cd,
            p_information111     => l_ccm_rec.ccm_attribute1,
            p_information120     => l_ccm_rec.ccm_attribute10,
            p_information121     => l_ccm_rec.ccm_attribute11,
            p_information122     => l_ccm_rec.ccm_attribute12,
            p_information123     => l_ccm_rec.ccm_attribute13,
            p_information124     => l_ccm_rec.ccm_attribute14,
            p_information125     => l_ccm_rec.ccm_attribute15,
            p_information126     => l_ccm_rec.ccm_attribute16,
            p_information127     => l_ccm_rec.ccm_attribute17,
            p_information128     => l_ccm_rec.ccm_attribute18,
            p_information129     => l_ccm_rec.ccm_attribute19,
            p_information112     => l_ccm_rec.ccm_attribute2,
            p_information130     => l_ccm_rec.ccm_attribute20,
            p_information131     => l_ccm_rec.ccm_attribute21,
            p_information132     => l_ccm_rec.ccm_attribute22,
            p_information133     => l_ccm_rec.ccm_attribute23,
            p_information134     => l_ccm_rec.ccm_attribute24,
            p_information135     => l_ccm_rec.ccm_attribute25,
            p_information136     => l_ccm_rec.ccm_attribute26,
            p_information137     => l_ccm_rec.ccm_attribute27,
            p_information138     => l_ccm_rec.ccm_attribute28,
            p_information139     => l_ccm_rec.ccm_attribute29,
            p_information113     => l_ccm_rec.ccm_attribute3,
            p_information140     => l_ccm_rec.ccm_attribute30,
            p_information114     => l_ccm_rec.ccm_attribute4,
            p_information115     => l_ccm_rec.ccm_attribute5,
            p_information116     => l_ccm_rec.ccm_attribute6,
            p_information117     => l_ccm_rec.ccm_attribute7,
            p_information118     => l_ccm_rec.ccm_attribute8,
            p_information119     => l_ccm_rec.ccm_attribute9,
            p_information110     => l_ccm_rec.ccm_attribute_category,
            p_information254     => l_ccm_rec.comp_lvl_fctr_id,
            p_information21     => l_ccm_rec.cvg_mlt_cd,
            p_information15     => l_ccm_rec.dflt_flag,
            p_information299     => l_ccm_rec.dflt_val,
            p_information14     => l_ccm_rec.entr_val_at_enrt_flag,
            p_information295     => l_ccm_rec.incrmt_val,
            p_information257     => l_ccm_rec.lwr_lmt_calc_rl,
            p_information293     => l_ccm_rec.lwr_lmt_val,
            p_information297     => l_ccm_rec.mn_val,
            p_information296     => l_ccm_rec.mx_val,
            p_information170     => l_ccm_rec.name,
            p_information18     => l_ccm_rec.nnmntry_uom,
            p_information12     => l_ccm_rec.no_mn_val_dfnd_flag,
            p_information11     => l_ccm_rec.no_mx_val_dfnd_flag,
            p_information258     => l_ccm_rec.oipl_id,
            p_information261     => l_ccm_rec.pl_id,
            p_information256     => l_ccm_rec.plip_id,
            p_information16     => l_ccm_rec.rndg_cd,
            p_information264     => l_ccm_rec.rndg_rl,
            p_information22     => l_ccm_rec.rt_typ_cd,
            p_information17     => l_ccm_rec.uom,
            p_information259     => l_ccm_rec.upr_lmt_calc_rl,
            p_information294     => l_ccm_rec.upr_lmt_val,
            p_information298     => l_ccm_rec.val,
            p_information266     => l_ccm_rec.val_calc_rl,
            p_information13     => l_ccm_rec.val_ovrid_alwd_flag,
            p_information265    => l_ccm_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_ccm_result_id is null then
              l_out_ccm_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_ccm_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas also if they are attached to any Columns -----
            ---------------------------------------------------------------
            --  LWR_LMT_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_ccm_rec.lwr_lmt_calc_rl is not null then
            --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ccm_rec.lwr_lmt_calc_rl
                ,p_business_group_id              =>  l_ccm_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

            --
            end if;

            ---------------------------------------------------------------
            --  RNDG_RL -----------------
            ---------------------------------------------------------------

            if l_ccm_rec.rndg_rl is not null then
            --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ccm_rec.rndg_rl
                ,p_business_group_id              =>  l_ccm_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

            --
            end if;

            ---------------------------------------------------------------
            --  UPR_LMT_CALC_RL  -----------------
            ---------------------------------------------------------------

            if l_ccm_rec.upr_lmt_calc_rl is not null then
            --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ccm_rec.upr_lmt_calc_rl
                ,p_business_group_id              =>  l_ccm_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

            --
            end if;

            ---------------------------------------------------------------
            --  VAL_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_ccm_rec.val_calc_rl is not null then
            --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_ccm_rec.val_calc_rl
                ,p_business_group_id              =>  l_ccm_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

            --
            end if;

            ---------------------------------------------------------------
            --  COMP_LVL_FCTR -----------------
            ---------------------------------------------------------------

            if l_ccm_rec.comp_lvl_fctr_id is not null then
            --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_ccm_rec.comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
            --
            end if;

         end loop;
         --
        ---------------------------------------------------------------
        -- START OF BEN_BNFT_VRBL_RT_RL_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_brr_from_parent(l_CVG_AMT_CALC_MTHD_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_ccm_result_id ;

           --
           l_bnft_vrbl_rt_rl_id := l_parent_rec.bnft_vrbl_rt_rl_id ;
           --
           for l_brr_rec in c_brr(l_parent_rec.bnft_vrbl_rt_rl_id,l_mirror_src_entity_result_id,'BRR') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('BRR');
               fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_formula_name(l_brr_rec.formula_id,p_effective_date);
                                --'Intersection';
             --
             if p_effective_date between l_brr_rec.effective_start_date
                and l_brr_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'BRR',
               p_information1     => l_brr_rec.bnft_vrbl_rt_rl_id,
               p_information2     => l_brr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_brr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_brr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_brr_rec.brr_attribute1,
            p_information120     => l_brr_rec.brr_attribute10,
            p_information121     => l_brr_rec.brr_attribute11,
            p_information122     => l_brr_rec.brr_attribute12,
            p_information123     => l_brr_rec.brr_attribute13,
            p_information124     => l_brr_rec.brr_attribute14,
            p_information125     => l_brr_rec.brr_attribute15,
            p_information126     => l_brr_rec.brr_attribute16,
            p_information127     => l_brr_rec.brr_attribute17,
            p_information128     => l_brr_rec.brr_attribute18,
            p_information129     => l_brr_rec.brr_attribute19,
            p_information112     => l_brr_rec.brr_attribute2,
            p_information130     => l_brr_rec.brr_attribute20,
            p_information131     => l_brr_rec.brr_attribute21,
            p_information132     => l_brr_rec.brr_attribute22,
            p_information133     => l_brr_rec.brr_attribute23,
            p_information134     => l_brr_rec.brr_attribute24,
            p_information135     => l_brr_rec.brr_attribute25,
            p_information136     => l_brr_rec.brr_attribute26,
            p_information137     => l_brr_rec.brr_attribute27,
            p_information138     => l_brr_rec.brr_attribute28,
            p_information139     => l_brr_rec.brr_attribute29,
            p_information113     => l_brr_rec.brr_attribute3,
            p_information140     => l_brr_rec.brr_attribute30,
            p_information114     => l_brr_rec.brr_attribute4,
            p_information115     => l_brr_rec.brr_attribute5,
            p_information116     => l_brr_rec.brr_attribute6,
            p_information117     => l_brr_rec.brr_attribute7,
            p_information118     => l_brr_rec.brr_attribute8,
            p_information119     => l_brr_rec.brr_attribute9,
            p_information110     => l_brr_rec.brr_attribute_category,
            p_information238     => l_brr_rec.cvg_amt_calc_mthd_id,
            p_information251     => l_brr_rec.formula_id,
            p_information260     => l_brr_rec.ordr_to_aply_num,
            p_information265     => l_brr_rec.object_version_number,

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_brr_result_id is null then
                 l_out_brr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_brr_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               --  FORMULA_ID -----------------
               ---------------------------------------------------------------

               if l_brr_rec.formula_id is not null then
                   --
                   ben_plan_design_program_module.create_formula_result
                   (
                    p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_brr_rec.formula_id
                   ,p_business_group_id              =>  l_brr_rec.business_group_id
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
       -- END OF BEN_BNFT_VRBL_RT_RL_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_BNFT_VRBL_RT_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_bvr_from_parent(l_CVG_AMT_CALC_MTHD_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_ccm_result_id ;
           --
           l_bnft_vrbl_rt_id := l_parent_rec.bnft_vrbl_rt_id ;
           --
           for l_bvr_rec in c_bvr(l_parent_rec.bnft_vrbl_rt_id,l_mirror_src_entity_result_id,'BVR1') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('BVR1');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_vrbl_rt_prfl_name(l_bvr_rec.vrbl_rt_prfl_id
                                                                                    ,p_effective_date); --'Intersection';
             --
             if p_effective_date between l_bvr_rec.effective_start_date
                and l_bvr_rec.effective_end_date then
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
               p_parent_entity_result_id        => null, -- Hide BEN_BNFT_VRBL_RT_F for HGrid
               p_number_of_copies               => l_number_of_copies,
               p_table_route_id                 => l_table_route_id,
	       P_TABLE_ALIAS                    => 'BVR1',
               p_information1     => l_bvr_rec.bnft_vrbl_rt_id,
               p_information2     => l_bvr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_bvr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_bvr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information111     => l_bvr_rec.bvr_attribute1,
            p_information120     => l_bvr_rec.bvr_attribute10,
            p_information121     => l_bvr_rec.bvr_attribute11,
            p_information122     => l_bvr_rec.bvr_attribute12,
            p_information123     => l_bvr_rec.bvr_attribute13,
            p_information124     => l_bvr_rec.bvr_attribute14,
            p_information125     => l_bvr_rec.bvr_attribute15,
            p_information126     => l_bvr_rec.bvr_attribute16,
            p_information127     => l_bvr_rec.bvr_attribute17,
            p_information128     => l_bvr_rec.bvr_attribute18,
            p_information129     => l_bvr_rec.bvr_attribute19,
            p_information112     => l_bvr_rec.bvr_attribute2,
            p_information130     => l_bvr_rec.bvr_attribute20,
            p_information131     => l_bvr_rec.bvr_attribute21,
            p_information132     => l_bvr_rec.bvr_attribute22,
            p_information133     => l_bvr_rec.bvr_attribute23,
            p_information134     => l_bvr_rec.bvr_attribute24,
            p_information135     => l_bvr_rec.bvr_attribute25,
            p_information136     => l_bvr_rec.bvr_attribute26,
            p_information137     => l_bvr_rec.bvr_attribute27,
            p_information138     => l_bvr_rec.bvr_attribute28,
            p_information139     => l_bvr_rec.bvr_attribute29,
            p_information113     => l_bvr_rec.bvr_attribute3,
            p_information140     => l_bvr_rec.bvr_attribute30,
            p_information114     => l_bvr_rec.bvr_attribute4,
            p_information115     => l_bvr_rec.bvr_attribute5,
            p_information116     => l_bvr_rec.bvr_attribute6,
            p_information117     => l_bvr_rec.bvr_attribute7,
            p_information118     => l_bvr_rec.bvr_attribute8,
            p_information119     => l_bvr_rec.bvr_attribute9,
            p_information110     => l_bvr_rec.bvr_attribute_category,
            p_information238     => l_bvr_rec.cvg_amt_calc_mthd_id,
            p_information260     => l_bvr_rec.ordr_num,
            p_information262     => l_bvr_rec.vrbl_rt_prfl_id,
            p_information265     => l_bvr_rec.object_version_number,

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_bvr_result_id is null then
                 l_out_bvr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_bvr_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;
            hr_utility.set_location('l_parent_rec.bnft_vrbl_rt_id  '|| l_parent_rec.bnft_vrbl_rt_id,100);
            hr_utility.set_location('l_mirror_src_entity_result_id  '|| l_mirror_src_entity_result_id,100);
            for l_bvr_rec in c_bvr_drp(l_parent_rec.bnft_vrbl_rt_id,l_mirror_src_entity_result_id,'BVR1') loop
              -----------------------------------------------------------------------------------------
              -- Call to VAPRO
              -----------------------------------------------------------------------------------------
              hr_utility.set_location('l_bvr_rec ',100);
              create_vapro_results
                (
                 p_validate                    => p_validate
                ,p_copy_entity_result_id       => l_out_bvr_result_id
                ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                ,p_vrbl_rt_prfl_id             => l_bvr_rec.vrbl_rt_prfl_id
                ,p_business_group_id           => p_business_group_id
                ,p_number_of_copies            => p_number_of_copies
                ,p_object_version_number       => p_object_version_number
                ,p_effective_date              => p_effective_date
                ,p_parent_entity_result_id     => l_out_ccm_result_id
                ) ;
            end loop;
            --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_BNFT_VRBL_RT_F ----------------------
       ---------------------------------------------------------------
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_CVG_AMT_CALC_MTHD_F ----------------------
    ---------------------------------------------------------------
    end create_coverage_results ;
  --
  procedure create_premium_results
    (
      p_validate                       in  number    default 0 -- false
     ,p_copy_entity_result_id          in  number
     ,p_copy_entity_txn_id             in  number    default null
     ,p_pl_id                          in  number    default null
     ,p_oipl_id                        in  number    default null
     ,p_business_group_id              in  number    default null
     ,p_number_of_copies               in  number    default 0
     ,p_object_version_number          out nocopy number
     ,p_effective_date                 in  date
     ,p_parent_entity_result_id        in  number
     ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
          pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     --
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_ACTL_PREM_F ----------------------
   ---------------------------------------------------------------
   cursor c_apr_from_parent(c_pl_id number,c_oipl_id number) is
   select distinct actl_prem_id
   from BEN_ACTL_PREM_F
   where  (c_pl_id is not null and pl_id = c_pl_id ) or
          (c_oipl_id is not null and oipl_id = c_oipl_id) ;
   --
   cursor c_apr(c_actl_prem_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  apr.*
   from BEN_ACTL_PREM_F apr
   where  apr.actl_prem_id = c_actl_prem_id
     -- and apr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTL_PREM_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_actl_prem_id
         -- and information4 = apr.business_group_id
           and information2 = apr.effective_start_date
           and information3 = apr.effective_end_date);
    --
    l_actl_prem_id                 number(15);
    l_out_apr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTL_PREM_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
   ---------------------------------------------------------------
   cursor c_pmr_from_parent(c_ACTL_PREM_ID number) is
   select  prtl_mo_rt_prtn_val_id
   from BEN_PRTL_MO_RT_PRTN_VAL_F
   where  ACTL_PREM_ID = c_ACTL_PREM_ID;
   --
   cursor c_pmr(c_prtl_mo_rt_prtn_val_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  pmr.*
   from BEN_PRTL_MO_RT_PRTN_VAL_F pmr
   where  pmr.prtl_mo_rt_prtn_val_id = c_prtl_mo_rt_prtn_val_id
     -- and pmr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PRTL_MO_RT_PRTN_VAL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_prtl_mo_rt_prtn_val_id
         -- and information4 = pmr.business_group_id
           and information2 = pmr.effective_start_date
           and information3 = pmr.effective_end_date);
    l_prtl_mo_rt_prtn_val_id                 number(15);
    l_out_pmr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTL_PREM_VRBL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_apv_from_parent(c_ACTL_PREM_ID number) is
   select distinct actl_prem_vrbl_rt_id
   from BEN_ACTL_PREM_VRBL_RT_F
   where  ACTL_PREM_ID = c_ACTL_PREM_ID ;
   --
   cursor c_apv(c_actl_prem_vrbl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  apv.*
   from BEN_ACTL_PREM_VRBL_RT_F apv
   where  apv.actl_prem_vrbl_rt_id = c_actl_prem_vrbl_rt_id
     -- and apv.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTL_PREM_VRBL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_actl_prem_vrbl_rt_id
         -- and information4 = apv.business_group_id
           and information2 = apv.effective_start_date
           and information3 = apv.effective_end_date);
   --
   cursor c_apv_dpr(c_actl_prem_vrbl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information262 vrbl_rt_prfl_id
     from ben_copy_entity_results cpe
          -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     -- and trt.where_clause = 'BEN_ACTL_PREM_VRBL_RT_F'
     and cpe.table_alias = c_table_alias
     and information1 = c_actl_prem_vrbl_rt_id
     -- and information4 = p_business_group_id
    ;
   --

    l_actl_prem_vrbl_rt_id                 number(15);
    l_out_apv_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTL_PREM_VRBL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ACTL_PREM_VRBL_RT_RL_F ----------------------
   ---------------------------------------------------------------
   cursor c_ava_from_parent(c_ACTL_PREM_ID number) is
   select  actl_prem_vrbl_rt_rl_id
   from BEN_ACTL_PREM_VRBL_RT_RL_F
   where  ACTL_PREM_ID = c_ACTL_PREM_ID ;
   --
   cursor c_ava(c_actl_prem_vrbl_rt_rl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  ava.*
   from BEN_ACTL_PREM_VRBL_RT_RL_F ava
   where  ava.actl_prem_vrbl_rt_rl_id = c_actl_prem_vrbl_rt_rl_id
     -- and ava.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACTL_PREM_VRBL_RT_RL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_actl_prem_vrbl_rt_rl_id
         -- and information4 = ava.business_group_id
           and information2 = ava.effective_start_date
           and information3 = ava.effective_end_date);
    l_actl_prem_vrbl_rt_rl_id                 number(15);
    l_out_ava_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACTL_PREM_VRBL_RT_RL_F ----------------------
   ---------------------------------------------------------------
    begin
     l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_ACTL_PREM_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_apr_from_parent(p_pl_id,p_oipl_id) loop
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_actl_prem_id := l_parent_rec.actl_prem_id ;
        --
        for l_apr_rec in c_apr(l_parent_rec.actl_prem_id,l_mirror_src_entity_result_id,'APR') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('APR');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_apr_rec.name; --'Intersection';
          --
          if p_effective_date between l_apr_rec.effective_start_date
             and l_apr_rec.effective_end_date then
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
            p_parent_entity_result_id        => p_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'APR',
            p_information1     => l_apr_rec.actl_prem_id,
            p_information2     => l_apr_rec.EFFECTIVE_START_DATE,
            p_information3     => l_apr_rec.EFFECTIVE_END_DATE,
            p_information4     => l_apr_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information22     => l_apr_rec.actl_prem_typ_cd,
            p_information11     => l_apr_rec.acty_ref_perd_cd,
            p_information111     => l_apr_rec.apr_attribute1,
            p_information120     => l_apr_rec.apr_attribute10,
            p_information121     => l_apr_rec.apr_attribute11,
            p_information122     => l_apr_rec.apr_attribute12,
            p_information123     => l_apr_rec.apr_attribute13,
            p_information124     => l_apr_rec.apr_attribute14,
            p_information125     => l_apr_rec.apr_attribute15,
            p_information126     => l_apr_rec.apr_attribute16,
            p_information127     => l_apr_rec.apr_attribute17,
            p_information128     => l_apr_rec.apr_attribute18,
            p_information129     => l_apr_rec.apr_attribute19,
            p_information112     => l_apr_rec.apr_attribute2,
            p_information130     => l_apr_rec.apr_attribute20,
            p_information131     => l_apr_rec.apr_attribute21,
            p_information132     => l_apr_rec.apr_attribute22,
            p_information133     => l_apr_rec.apr_attribute23,
            p_information134     => l_apr_rec.apr_attribute24,
            p_information135     => l_apr_rec.apr_attribute25,
            p_information136     => l_apr_rec.apr_attribute26,
            p_information137     => l_apr_rec.apr_attribute27,
            p_information138     => l_apr_rec.apr_attribute28,
            p_information139     => l_apr_rec.apr_attribute29,
            p_information113     => l_apr_rec.apr_attribute3,
            p_information140     => l_apr_rec.apr_attribute30,
            p_information114     => l_apr_rec.apr_attribute4,
            p_information115     => l_apr_rec.apr_attribute5,
            p_information116     => l_apr_rec.apr_attribute6,
            p_information117     => l_apr_rec.apr_attribute7,
            p_information118     => l_apr_rec.apr_attribute8,
            p_information119     => l_apr_rec.apr_attribute9,
            p_information110     => l_apr_rec.apr_attribute_category,
            p_information16     => l_apr_rec.bnft_rt_typ_cd,
            p_information254     => l_apr_rec.comp_lvl_fctr_id,
            p_information270     => l_apr_rec.cost_allocation_keyflex_id,
            p_information13     => l_apr_rec.cr_lkbk_crnt_py_only_flag,
            p_information24     => l_apr_rec.cr_lkbk_uom,
            p_information293     => l_apr_rec.cr_lkbk_val,
            p_information268     => l_apr_rec.lwr_lmt_calc_rl,
            p_information295     => l_apr_rec.lwr_lmt_val,
            p_information17     => l_apr_rec.mlt_cd,
            p_information170     => l_apr_rec.name,
            p_information258     => l_apr_rec.oipl_id,
            p_information252     => l_apr_rec.organization_id,
            p_information261     => l_apr_rec.pl_id,
            p_information18     => l_apr_rec.prdct_cd,
            p_information20     => l_apr_rec.prem_asnmt_cd,
            p_information21     => l_apr_rec.prem_asnmt_lvl_cd,
            p_information23     => l_apr_rec.prem_pyr_cd,
            p_information25     => l_apr_rec.prsptv_r_rtsptv_cd,
            p_information14     => l_apr_rec.prtl_mo_det_mthd_cd,
            p_information263     => l_apr_rec.prtl_mo_det_mthd_rl,
            p_information19     => l_apr_rec.rndg_cd,
            p_information264     => l_apr_rec.rndg_rl,
            p_information15     => l_apr_rec.rt_typ_cd,
            p_information12     => l_apr_rec.uom,
            p_information267     => l_apr_rec.upr_lmt_calc_rl,
            p_information294     => l_apr_rec.upr_lmt_val,
            p_information287     => l_apr_rec.val,
            p_information266     => l_apr_rec.val_calc_rl,
            p_information269     => l_apr_rec.vrbl_rt_add_on_calc_rl,
            p_information257     => l_apr_rec.wsh_rl_dy_mo_num,
            p_information265     => l_apr_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_apr_result_id is null then
              l_out_apr_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_apr_result_id := l_copy_entity_result_id ;
            end if;
            --

            ---------------------------------------------------------------
            -- LWR_LMT_CALC_RL --
            ---------------------------------------------------------------
            --
            if l_apr_rec.lwr_lmt_calc_rl is not null then
            --
              ben_plan_design_program_module.create_formula_result
              (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_apr_rec.lwr_lmt_calc_rl
                ,p_business_group_id              =>  l_apr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
               );

             --
             end if;
             --

             ---------------------------------------------------------------
             -- PRTL_MO_DET_MTHD_RL --
             ---------------------------------------------------------------
             --
             if l_apr_rec.prtl_mo_det_mthd_rl is not null then
             --
               ben_plan_design_program_module.create_formula_result
               (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_apr_rec.prtl_mo_det_mthd_rl
                ,p_business_group_id              =>  l_apr_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
               );
             --
             end if;
             --

             ---------------------------------------------------------------
             -- RNDG_RL --
             ---------------------------------------------------------------
             --
             if l_apr_rec.rndg_rl is not null then
             --
               ben_plan_design_program_module.create_formula_result
               (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_apr_rec.rndg_rl
                 ,p_business_group_id              =>  l_apr_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
               );
             --
             end if;
             --

             ---------------------------------------------------------------
             -- UPR_LMT_CALC_RL --
             ---------------------------------------------------------------
             --
             if l_apr_rec.upr_lmt_calc_rl is not null then
             --
               ben_plan_design_program_module.create_formula_result
               (
                  p_validate                       =>  0
                 ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                 ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                 ,p_formula_id                     =>  l_apr_rec.upr_lmt_calc_rl
                 ,p_business_group_id              =>  l_apr_rec.business_group_id
                 ,p_number_of_copies               =>  l_number_of_copies
                 ,p_object_version_number          =>  l_object_version_number
                 ,p_effective_date                 =>  p_effective_date
               );
             --
             end if;
             --

             ---------------------------------------------------------------
             -- VAL_CALC_RL      --
             ---------------------------------------------------------------
             --
               if l_apr_rec.val_calc_rl is not null then
               --
                  ben_plan_design_program_module.create_formula_result
                  (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_apr_rec.val_calc_rl
                    ,p_business_group_id              =>  l_apr_rec.business_group_id
                    ,p_number_of_copies               =>  l_number_of_copies
                    ,p_object_version_number          =>  l_object_version_number
                    ,p_effective_date                 =>  p_effective_date
                   );
                --
                end if;
                --

             ---------------------------------------------------------------
             -- VRBL_RT_ADD_ON_CALC_RL   --
             ---------------------------------------------------------------
             --
               if l_apr_rec.vrbl_rt_add_on_calc_rl is not null then
               --
                 ben_plan_design_program_module.create_formula_result
                 (
                    p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_apr_rec.vrbl_rt_add_on_calc_rl
                   ,p_business_group_id              =>  l_apr_rec.business_group_id
                   ,p_number_of_copies               =>  l_number_of_copies
                   ,p_object_version_number          =>  l_object_version_number
                   ,p_effective_date                 =>  p_effective_date
                  );
               --
               end if;
               --
              ---------------------------------------------------------------
              --  COMP_LVL_FCTR -----------------
              ---------------------------------------------------------------

              if l_apr_rec.comp_lvl_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_apr_rec.comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;

         end loop;
         --

        ---------------------------------------------------------------
        -- START OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_pmr_from_parent(l_ACTL_PREM_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_apr_result_id ;
           --
           l_prtl_mo_rt_prtn_val_id := l_parent_rec.prtl_mo_rt_prtn_val_id ;
           --
           for l_pmr_rec in c_pmr(l_parent_rec.prtl_mo_rt_prtn_val_id,l_mirror_src_entity_result_id,'PMRPV') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('PMRPV');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := l_pmr_rec.from_dy_mo_num ||' - '||l_pmr_rec.to_dy_mo_num ;
             if l_pmr_rec.pct_val is not null then
               l_information5 := l_information5 ||' '||l_pmr_rec.pct_val||'%';
             end if;
             -- 'Intersection';
             --
             if p_effective_date between l_pmr_rec.effective_start_date
                and l_pmr_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'PMRPV',
               p_information1     => l_pmr_rec.prtl_mo_rt_prtn_val_id,
               p_information2     => l_pmr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_pmr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_pmr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid


            p_information250     => l_pmr_rec.actl_prem_id,
            p_information253     => l_pmr_rec.acty_base_rt_id,
            p_information238     => l_pmr_rec.cvg_amt_calc_mthd_id,
            p_information261     => l_pmr_rec.from_dy_mo_num,
            p_information293     => l_pmr_rec.pct_val,
            p_information111     => l_pmr_rec.pmrpv_attribute1,
            p_information120     => l_pmr_rec.pmrpv_attribute10,
            p_information121     => l_pmr_rec.pmrpv_attribute11,
            p_information122     => l_pmr_rec.pmrpv_attribute12,
            p_information123     => l_pmr_rec.pmrpv_attribute13,
            p_information124     => l_pmr_rec.pmrpv_attribute14,
            p_information125     => l_pmr_rec.pmrpv_attribute15,
            p_information126     => l_pmr_rec.pmrpv_attribute16,
            p_information127     => l_pmr_rec.pmrpv_attribute17,
            p_information128     => l_pmr_rec.pmrpv_attribute18,
            p_information129     => l_pmr_rec.pmrpv_attribute19,
            p_information112     => l_pmr_rec.pmrpv_attribute2,
            p_information130     => l_pmr_rec.pmrpv_attribute20,
            p_information131     => l_pmr_rec.pmrpv_attribute21,
            p_information132     => l_pmr_rec.pmrpv_attribute22,
            p_information133     => l_pmr_rec.pmrpv_attribute23,
            p_information134     => l_pmr_rec.pmrpv_attribute24,
            p_information135     => l_pmr_rec.pmrpv_attribute25,
            p_information136     => l_pmr_rec.pmrpv_attribute26,
            p_information137     => l_pmr_rec.pmrpv_attribute27,
            p_information138     => l_pmr_rec.pmrpv_attribute28,
            p_information139     => l_pmr_rec.pmrpv_attribute29,
            p_information113     => l_pmr_rec.pmrpv_attribute3,
            p_information140     => l_pmr_rec.pmrpv_attribute30,
            p_information114     => l_pmr_rec.pmrpv_attribute4,
            p_information115     => l_pmr_rec.pmrpv_attribute5,
            p_information116     => l_pmr_rec.pmrpv_attribute6,
            p_information117     => l_pmr_rec.pmrpv_attribute7,
            p_information118     => l_pmr_rec.pmrpv_attribute8,
            p_information119     => l_pmr_rec.pmrpv_attribute9,
            p_information110     => l_pmr_rec.pmrpv_attribute_category,
            p_information263     => l_pmr_rec.prtl_mo_prortn_rl,
            p_information11     => l_pmr_rec.rndg_cd,
            p_information262     => l_pmr_rec.rndg_rl,
            p_information12     => l_pmr_rec.strt_r_stp_cvg_cd,
            p_information260     => l_pmr_rec.to_dy_mo_num,
            p_information265    => l_pmr_rec.object_version_number,
           --
           -- Bug No 4440138 Added mappings for PRORATE_BY_DAY_TO_MON_FLAG and NUM_DAYS_MONTH
	   --
            p_information13     => l_pmr_rec.PRORATE_BY_DAY_TO_MON_FLAG,
            p_information266    => l_pmr_rec.NUM_DAYS_MONTH,
	   -- End Bug No 4440138
	   --
               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_pmr_result_id is null then
                 l_out_pmr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_pmr_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- PRTL_MO_PRORTN_RL -----------------
               ---------------------------------------------------------------

               if l_pmr_rec.prtl_mo_prortn_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_pmr_rec.prtl_mo_prortn_rl
                      ,p_business_group_id              =>  l_pmr_rec.business_group_id
                      ,p_number_of_copies               =>  l_number_of_copies
                      ,p_object_version_number          =>  l_object_version_number
                      ,p_effective_date                 =>  p_effective_date
                      );

                      --
               end if;



               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- RNDG_RL -----------------
               ---------------------------------------------------------------

               if l_pmr_rec.rndg_rl is not null then
                      --
                      ben_plan_design_program_module.create_formula_result
                      (
                       p_validate                       =>  0
                      ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                      ,p_formula_id                     =>  l_pmr_rec.rndg_rl
                      ,p_business_group_id              =>  l_pmr_rec.business_group_id
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
       -- END OF BEN_PRTL_MO_RT_PRTN_VAL_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_ACTL_PREM_VRBL_RT_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_apv_from_parent(l_ACTL_PREM_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_apr_result_id ;
           --
           l_actl_prem_vrbl_rt_id := l_parent_rec.actl_prem_vrbl_rt_id ;
           --
           for l_apv_rec in c_apv(l_parent_rec.actl_prem_vrbl_rt_id,l_mirror_src_entity_result_id,'APV') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('APV');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_vrbl_rt_prfl_name(l_apv_rec.vrbl_rt_prfl_id
                                                                                     ,p_effective_date); --'Intersection';
             --
             if p_effective_date between l_apv_rec.effective_start_date
                and l_apv_rec.effective_end_date then
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
               p_parent_entity_result_id        => null, -- Hide BEN_ACTL_PREM_VRBL_RT_F for HGrid
               p_number_of_copies               => l_number_of_copies,
               p_table_route_id                 => l_table_route_id,
	       P_TABLE_ALIAS                    => 'APV',
               p_information1     => l_apv_rec.actl_prem_vrbl_rt_id,
               p_information2     => l_apv_rec.EFFECTIVE_START_DATE,
               p_information3     => l_apv_rec.EFFECTIVE_END_DATE,
               p_information4     => l_apv_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information250     => l_apv_rec.actl_prem_id,
            p_information111     => l_apv_rec.apv_attribute1,
            p_information120     => l_apv_rec.apv_attribute10,
            p_information121     => l_apv_rec.apv_attribute11,
            p_information122     => l_apv_rec.apv_attribute12,
            p_information123     => l_apv_rec.apv_attribute13,
            p_information124     => l_apv_rec.apv_attribute14,
            p_information125     => l_apv_rec.apv_attribute15,
            p_information126     => l_apv_rec.apv_attribute16,
            p_information127     => l_apv_rec.apv_attribute17,
            p_information128     => l_apv_rec.apv_attribute18,
            p_information129     => l_apv_rec.apv_attribute19,
            p_information112     => l_apv_rec.apv_attribute2,
            p_information130     => l_apv_rec.apv_attribute20,
            p_information131     => l_apv_rec.apv_attribute21,
            p_information132     => l_apv_rec.apv_attribute22,
            p_information133     => l_apv_rec.apv_attribute23,
            p_information134     => l_apv_rec.apv_attribute24,
            p_information135     => l_apv_rec.apv_attribute25,
            p_information136     => l_apv_rec.apv_attribute26,
            p_information137     => l_apv_rec.apv_attribute27,
            p_information138     => l_apv_rec.apv_attribute28,
            p_information139     => l_apv_rec.apv_attribute29,
            p_information113     => l_apv_rec.apv_attribute3,
            p_information140     => l_apv_rec.apv_attribute30,
            p_information114     => l_apv_rec.apv_attribute4,
            p_information115     => l_apv_rec.apv_attribute5,
            p_information116     => l_apv_rec.apv_attribute6,
            p_information117     => l_apv_rec.apv_attribute7,
            p_information118     => l_apv_rec.apv_attribute8,
            p_information119     => l_apv_rec.apv_attribute9,
            p_information110     => l_apv_rec.apv_attribute_category,
            p_information260     => l_apv_rec.ordr_num,
            p_information262     => l_apv_rec.vrbl_rt_prfl_id,
            p_information265     => l_apv_rec.object_version_number,

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_apv_result_id is null then
                 l_out_apv_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_apv_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;
            hr_utility.set_location('l_parent_rec.actl_prem_vrbl_rt_id  '|| l_parent_rec.actl_prem_vrbl_rt_id,100);
            hr_utility.set_location('l_mirror_src_entity_result_id  '|| l_mirror_src_entity_result_id,100);
            for l_apv_rec in c_apv_dpr(l_parent_rec.actl_prem_vrbl_rt_id,l_mirror_src_entity_result_id,'APV') loop
              -----------------------------------------------------------------------------------------
              -- Call to VAPRO
              -----------------------------------------------------------------------------------------
              hr_utility.set_location('l_apv_rec ',100);
              create_vapro_results
                (
                 p_validate                    => p_validate
                ,p_copy_entity_result_id       => l_out_apv_result_id
                ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                ,p_vrbl_rt_prfl_id             => l_apv_rec.vrbl_rt_prfl_id
                ,p_business_group_id           => p_business_group_id
                ,p_number_of_copies            => p_number_of_copies
                ,p_object_version_number       => p_object_version_number
                ,p_effective_date              => p_effective_date
                ,p_parent_entity_result_id     => l_out_apr_result_id
                ) ;
            end loop;
            --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_ACTL_PREM_VRBL_RT_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_ACTL_PREM_VRBL_RT_RL_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_ava_from_parent(l_ACTL_PREM_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_apr_result_id ;

           --
           l_actl_prem_vrbl_rt_rl_id := l_parent_rec.actl_prem_vrbl_rt_rl_id ;
           --
           for l_ava_rec in c_ava(l_parent_rec.actl_prem_vrbl_rt_rl_id,l_mirror_src_entity_result_id,'AVA') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('AVA');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_formula_name(l_ava_rec.formula_id,p_effective_date);
                                --'Intersection';
             --
             if p_effective_date between l_ava_rec.effective_start_date
                and l_ava_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'AVA',
               p_information1     => l_ava_rec.actl_prem_vrbl_rt_rl_id,
               p_information2     => l_ava_rec.EFFECTIVE_START_DATE,
               p_information3     => l_ava_rec.EFFECTIVE_END_DATE,
               p_information4     => l_ava_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information250     => l_ava_rec.actl_prem_id,
            p_information111     => l_ava_rec.ava_attribute1,
            p_information120     => l_ava_rec.ava_attribute10,
            p_information121     => l_ava_rec.ava_attribute11,
            p_information122     => l_ava_rec.ava_attribute12,
            p_information123     => l_ava_rec.ava_attribute13,
            p_information124     => l_ava_rec.ava_attribute14,
            p_information125     => l_ava_rec.ava_attribute15,
            p_information126     => l_ava_rec.ava_attribute16,
            p_information127     => l_ava_rec.ava_attribute17,
            p_information128     => l_ava_rec.ava_attribute18,
            p_information129     => l_ava_rec.ava_attribute19,
            p_information112     => l_ava_rec.ava_attribute2,
            p_information130     => l_ava_rec.ava_attribute20,
            p_information131     => l_ava_rec.ava_attribute21,
            p_information132     => l_ava_rec.ava_attribute22,
            p_information133     => l_ava_rec.ava_attribute23,
            p_information134     => l_ava_rec.ava_attribute24,
            p_information135     => l_ava_rec.ava_attribute25,
            p_information136     => l_ava_rec.ava_attribute26,
            p_information137     => l_ava_rec.ava_attribute27,
            p_information138     => l_ava_rec.ava_attribute28,
            p_information139     => l_ava_rec.ava_attribute29,
            p_information113     => l_ava_rec.ava_attribute3,
            p_information140     => l_ava_rec.ava_attribute30,
            p_information114     => l_ava_rec.ava_attribute4,
            p_information115     => l_ava_rec.ava_attribute5,
            p_information116     => l_ava_rec.ava_attribute6,
            p_information117     => l_ava_rec.ava_attribute7,
            p_information118     => l_ava_rec.ava_attribute8,
            p_information119     => l_ava_rec.ava_attribute9,
            p_information110     => l_ava_rec.ava_attribute_category,
            p_information251     => l_ava_rec.formula_id,
            p_information260     => l_ava_rec.ordr_to_aply_num,
            p_information11     => l_ava_rec.rt_trtmt_cd,
            p_information265    => l_ava_rec.object_version_number,

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_ava_result_id is null then
                 l_out_ava_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_ava_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- Copy Fast Formulas if any are attached to any column --
               ---------------------------------------------------------------
               -- FORMULA_ID -----------------
               ---------------------------------------------------------------

               if l_ava_rec.formula_id is not null then
                   --
                   ben_plan_design_program_module.create_formula_result
                   (
                    p_validate                       =>  0
                   ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                   ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                   ,p_formula_id                     =>  l_ava_rec.formula_id
                   ,p_business_group_id              =>  l_ava_rec.business_group_id
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
       -- END OF BEN_ACTL_PREM_VRBL_RT_RL_F ----------------------
       ---------------------------------------------------------------
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_ACTL_PREM_F ----------------------
    ---------------------------------------------------------------
      null;
    end create_premium_results ;
  --
  procedure create_drpar_results
    (
     p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Source Elpro
    ,p_copy_entity_txn_id             in  number    default null
    ,p_comp_lvl_fctr_id               in  number    default null
    ,p_hrs_wkd_in_perd_fctr_id        in  number    default null
    ,p_los_fctr_id                    in  number    default null
    ,p_pct_fl_tm_fctr_id              in  number    default null
    ,p_age_fctr_id                    in  number    default null
    ,p_cmbn_age_los_fctr_id           in  number    default null
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_no_dup_rslt                    in varchar2   default null
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_drpar_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
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
            -- pqh_table_route trt
     where  cpe.information1= c_parent_pk_id
     and    cpe.copy_entity_txn_id = c_copy_entity_txn_id
     --and    cpe.table_route_id = trt.table_route_id
     and    cpe.table_alias = c_parent_table_alias;
     -- and    trt.from_clause = 'OAB'
     -- and    trt.where_clause = upper(c_parent_table_name);

     l_bnb_bnfts_bal_esd ben_bnfts_bal_f.effective_start_date%type;

     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);

   ---------------------------------------------------------------
   -- START OF BEN_AGE_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_agf(c_age_fctr_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  agf.*
   from BEN_AGE_FCTR agf
   where  agf.age_fctr_id = c_age_fctr_id
     -- and agf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_AGE_FCTR'
         and cpe.table_alias = c_table_alias
         and information1 = c_age_fctr_id
         -- and information4 = agf.business_group_id
        );
    l_age_fctr_id                 number(15);
    l_out_agf_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_AGE_FCTR ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CMBN_AGE_LOS_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_cla(c_cmbn_age_los_fctr_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  cla.*
   from BEN_CMBN_AGE_LOS_FCTR cla
   where  cla.cmbn_age_los_fctr_id = c_cmbn_age_los_fctr_id
     -- and cla.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CMBN_AGE_LOS_FCTR'
         and cpe.table_alias = c_table_alias
         and information1 = c_cmbn_age_los_fctr_id
         -- and information4 = cla.business_group_id
        );

    l_cmbn_age_los_fctr_id                 number(15);
    l_out_cla_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CMBN_AGE_LOS_FCTR ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_COMP_LVL_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_clf(c_comp_lvl_fctr_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  clf.*
   from BEN_COMP_LVL_FCTR clf
   where  clf.comp_lvl_fctr_id = c_comp_lvl_fctr_id
     -- and clf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_COMP_LVL_FCTR'
         and cpe.table_alias = c_table_alias
         and information1 = c_comp_lvl_fctr_id
         -- and information4 = clf.business_group_id
        );
   l_comp_lvl_fctr_id                 number(15);
   l_out_clf_result_id   number(15);
   --
   cursor c_clf_drp(c_comp_lvl_fctr_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information225 bnfts_bal_id
     from ben_copy_entity_results cpe
          -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     -- and trt.where_clause = 'BEN_COMP_LVL_FCTR'
     and cpe.table_alias = c_table_alias
     and information1 = c_comp_lvl_fctr_id
     -- and information4 = p_business_group_id
    ;
   ---------------------------------------------------------------
   -- END OF BEN_COMP_LVL_FCTR ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_HRS_WKD_IN_PERD_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_hwf(c_hrs_wkd_in_perd_fctr_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  hwf.*
   from BEN_HRS_WKD_IN_PERD_FCTR hwf
   where  hwf.hrs_wkd_in_perd_fctr_id = c_hrs_wkd_in_perd_fctr_id
     -- and hwf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_HRS_WKD_IN_PERD_FCTR'
         and cpe.table_alias = c_table_alias
         and information1 = c_hrs_wkd_in_perd_fctr_id
         -- and information4 = hwf.business_group_id
        );
   --
   l_hrs_wkd_in_perd_fctr_id                 number(15);
   l_out_hwf_result_id   number(15);
   --
   cursor c_hwf_drp(c_hrs_wkd_in_perd_fctr_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information225 bnfts_bal_id
     from ben_copy_entity_results cpe
          -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and mirror_src_entity_result_id = c_mirror_src_entity_result_id
     -- and trt.where_clause = 'BEN_HRS_WKD_IN_PERD_FCTR'
     and cpe.table_alias = c_table_alias
     and information1 = c_hrs_wkd_in_perd_fctr_id
     -- and information4 = p_business_group_id
    ;
   ---------------------------------------------------------------
   -- END OF BEN_HRS_WKD_IN_PERD_FCTR ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LOS_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_lsf(c_los_fctr_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  lsf.*
   from BEN_LOS_FCTR lsf
   where  lsf.los_fctr_id = c_los_fctr_id
     -- and lsf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LOS_FCTR'
         and cpe.table_alias = c_table_alias
         and information1 = c_los_fctr_id
         -- and information4 = lsf.business_group_id
        );
    l_los_fctr_id                 number(15);
    l_out_lsf_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LOS_FCTR ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PCT_FL_TM_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_pff(c_pct_fl_tm_fctr_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  pff.*
   from BEN_PCT_FL_TM_FCTR pff
   where  pff.pct_fl_tm_fctr_id = c_pct_fl_tm_fctr_id
     -- and pff.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PCT_FL_TM_FCTR'
         and cpe.table_alias = c_table_alias
         and information1 = c_pct_fl_tm_fctr_id
         -- and information4 = pff.business_group_id
        );
    l_pct_fl_tm_fctr_id                 number(15);
    l_out_pff_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PCT_FL_TM_FCTR ----------------------
   ---------------------------------------------------------------
   cursor c_get_defined_bal_name (p_defined_balance_id number) is
      select  pbt.balance_name||' - '||pbd.dimension_name dsp_name
             -- pdb.defined_balance_id defined_balance_id
      from pay_balance_types pbt,
           pay_balance_dimensions pbd,
           pay_defined_balances pdb
      where nvl(pdb.business_group_id, p_business_group_id) = p_business_group_id
        and pdb.balance_type_id = pbt.balance_type_id
        and pdb.balance_dimension_id = pbd.balance_dimension_id
        and pdb.defined_balance_id = p_defined_balance_id ;
   --
   l_mapping_defined_balance_id  number;
   l_mapping_defined_balance_name varchar2(600);
   l_mapping_column_name1 pqh_attributes.attribute_name%type;
   l_mapping_column_name2 pqh_attributes.attribute_name%type;
   l_information172       varchar2(300);
   --
   /*
-- added by sgoyal
    l_mapping_id         number;
    l_mapping_name       varchar2(600);
    l_mapping_id1        number;
    l_mapping_name1      varchar2(600);
-- end addition
   */

    cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
         -- pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
    -- and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

   begin
     hr_utility.set_location('Start create_drpar_results',100);
     l_number_of_copies := p_number_of_copies ;

      if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
     end if;

     if p_age_fctr_id is not null then

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_age_fctr_id,'AGF');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;
     ---------------------------------------------------------------
     -- START OF BEN_AGE_FCTR ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_age_fctr_id :=  p_age_fctr_id ;
        --
        for l_agf_rec in c_agf(p_age_fctr_id,l_mirror_src_entity_result_id,'AGF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('AGF');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_agf_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
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
	    P_TABLE_ALIAS                    => 'AGF',
            p_information1     => l_agf_rec.age_fctr_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_agf_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information262     => l_agf_rec.age_calc_rl,
            p_information16     => l_agf_rec.age_det_cd,
            p_information261     => l_agf_rec.age_det_rl,
            p_information14     => l_agf_rec.age_to_use_cd,
            p_information15     => l_agf_rec.age_uom,
            p_information111     => l_agf_rec.agf_attribute1,
            p_information120     => l_agf_rec.agf_attribute10,
            p_information121     => l_agf_rec.agf_attribute11,
            p_information122     => l_agf_rec.agf_attribute12,
            p_information123     => l_agf_rec.agf_attribute13,
            p_information124     => l_agf_rec.agf_attribute14,
            p_information125     => l_agf_rec.agf_attribute15,
            p_information126     => l_agf_rec.agf_attribute16,
            p_information127     => l_agf_rec.agf_attribute17,
            p_information128     => l_agf_rec.agf_attribute18,
            p_information129     => l_agf_rec.agf_attribute19,
            p_information112     => l_agf_rec.agf_attribute2,
            p_information130     => l_agf_rec.agf_attribute20,
            p_information131     => l_agf_rec.agf_attribute21,
            p_information132     => l_agf_rec.agf_attribute22,
            p_information133     => l_agf_rec.agf_attribute23,
            p_information134     => l_agf_rec.agf_attribute24,
            p_information135     => l_agf_rec.agf_attribute25,
            p_information136     => l_agf_rec.agf_attribute26,
            p_information137     => l_agf_rec.agf_attribute27,
            p_information138     => l_agf_rec.agf_attribute28,
            p_information139     => l_agf_rec.agf_attribute29,
            p_information113     => l_agf_rec.agf_attribute3,
            p_information140     => l_agf_rec.agf_attribute30,
            p_information114     => l_agf_rec.agf_attribute4,
            p_information115     => l_agf_rec.agf_attribute5,
            p_information116     => l_agf_rec.agf_attribute6,
            p_information117     => l_agf_rec.agf_attribute7,
            p_information118     => l_agf_rec.agf_attribute8,
            p_information119     => l_agf_rec.agf_attribute9,
            p_information110     => l_agf_rec.agf_attribute_category,
            p_information294     => l_agf_rec.mn_age_num,
            p_information293     => l_agf_rec.mx_age_num,
            p_information170     => l_agf_rec.name,
            p_information11     => l_agf_rec.no_mn_age_flag,
            p_information12     => l_agf_rec.no_mx_age_flag,
            p_information13     => l_agf_rec.rndg_cd,
            p_information257     => l_agf_rec.rndg_rl,
            p_information265    => l_agf_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_agf_result_id is null then
              l_out_agf_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_agf_result_id := l_copy_entity_result_id ;
            end if;
            --

            ------------------------------------------------------------
            --   AGE_CALC_RL                                             ---------------------
            ------------------------------------------------------------
            --
                        if l_agf_rec.age_calc_rl is not null then
                            --
                                ben_plan_design_program_module.create_formula_result
                                (
                                 p_validate                       =>  0
                                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                ,p_formula_id                     =>  l_agf_rec.age_calc_rl
                                ,p_business_group_id              =>  l_agf_rec.business_group_id
                                ,p_number_of_copies               =>  l_number_of_copies
                                ,p_object_version_number          =>  l_object_version_number
                                ,p_effective_date                 =>  p_effective_date
                                );
                             --
                      end if;
                      --

                      ------------------------------------------------------------
                        --   AGE_DET_RL --------------------------------------------
                        ------------------------------------------------------------
                        --
                        if l_agf_rec.age_det_rl is not null then
                            --
                                ben_plan_design_program_module.create_formula_result
                                (
                                 p_validate                       =>  0
                                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                ,p_formula_id                     =>  l_agf_rec.age_det_rl
                                ,p_business_group_id              =>  l_agf_rec.business_group_id
                                ,p_number_of_copies               =>  l_number_of_copies
                                ,p_object_version_number          =>  l_object_version_number
                                ,p_effective_date                 =>  p_effective_date
                                );
                             --
                        end if;
                      --

                      ------------------------------------------------------------
                        --   RNDG_RL    --------------------------------------------
                        ------------------------------------------------------------
                        --
                        if l_agf_rec.rndg_rl is not null then
                            --
                                ben_plan_design_program_module.create_formula_result
                                (
                                 p_validate                       =>  0
                                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                ,p_formula_id                     =>  l_agf_rec.rndg_rl
                                ,p_business_group_id              =>  l_agf_rec.business_group_id
                                ,p_number_of_copies               =>  l_number_of_copies
                                ,p_object_version_number          =>  l_object_version_number
                                ,p_effective_date                 =>  p_effective_date
                                );
                             --
                        end if;
                      --

         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_AGE_FCTR ----------------------
    ---------------------------------------------------------------
    end if;
    if p_cmbn_age_los_fctr_id is not null then

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_cmbn_age_los_fctr_id,'CLA');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;
     ---------------------------------------------------------------
     -- START OF BEN_CMBN_AGE_LOS_FCTR ----------------------
     ---------------------------------------------------------------
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_cmbn_age_los_fctr_id := p_cmbn_age_los_fctr_id ;
        --
        for l_cla_rec in c_cla(p_cmbn_age_los_fctr_id,l_mirror_src_entity_result_id,'CLA') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CLA');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_cla_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
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
	    P_TABLE_ALIAS                    => 'CLA',
            p_information1     => l_cla_rec.cmbn_age_los_fctr_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_cla_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information246     => l_cla_rec.age_fctr_id,
            p_information111     => l_cla_rec.cla_attribute1,
            p_information120     => l_cla_rec.cla_attribute10,
            p_information121     => l_cla_rec.cla_attribute11,
            p_information122     => l_cla_rec.cla_attribute12,
            p_information123     => l_cla_rec.cla_attribute13,
            p_information124     => l_cla_rec.cla_attribute14,
            p_information125     => l_cla_rec.cla_attribute15,
            p_information126     => l_cla_rec.cla_attribute16,
            p_information127     => l_cla_rec.cla_attribute17,
            p_information128     => l_cla_rec.cla_attribute18,
            p_information129     => l_cla_rec.cla_attribute19,
            p_information112     => l_cla_rec.cla_attribute2,
            p_information130     => l_cla_rec.cla_attribute20,
            p_information131     => l_cla_rec.cla_attribute21,
            p_information132     => l_cla_rec.cla_attribute22,
            p_information133     => l_cla_rec.cla_attribute23,
            p_information134     => l_cla_rec.cla_attribute24,
            p_information135     => l_cla_rec.cla_attribute25,
            p_information136     => l_cla_rec.cla_attribute26,
            p_information137     => l_cla_rec.cla_attribute27,
            p_information138     => l_cla_rec.cla_attribute28,
            p_information139     => l_cla_rec.cla_attribute29,
            p_information113     => l_cla_rec.cla_attribute3,
            p_information140     => l_cla_rec.cla_attribute30,
            p_information114     => l_cla_rec.cla_attribute4,
            p_information115     => l_cla_rec.cla_attribute5,
            p_information116     => l_cla_rec.cla_attribute6,
            p_information117     => l_cla_rec.cla_attribute7,
            p_information118     => l_cla_rec.cla_attribute8,
            p_information119     => l_cla_rec.cla_attribute9,
            p_information110     => l_cla_rec.cla_attribute_category,
            p_information294     => l_cla_rec.cmbnd_max_val,
            p_information293     => l_cla_rec.cmbnd_min_val,
            p_information243     => l_cla_rec.los_fctr_id,
            p_information170     => l_cla_rec.name,
            p_information260     => l_cla_rec.ordr_num,
            p_information265     => l_cla_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_cla_result_id is null then
              l_out_cla_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_cla_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Bug 2884982 - Copy Age factor and Los factor rows
            -- when copying Combined Age Los factor
            if l_cla_rec.los_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => l_cla_rec.los_fctr_id
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;

              if l_cla_rec.age_fctr_id is not null then
              --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => l_cla_rec.age_fctr_id
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
              end if;
         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_CMBN_AGE_LOS_FCTR ----------------------
    ---------------------------------------------------------------
    end if;
    if p_comp_lvl_fctr_id is not null then

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_comp_lvl_fctr_id,'CLF');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;
     ---------------------------------------------------------------
     -- START OF BEN_COMP_LVL_FCTR ----------------------
     ---------------------------------------------------------------
     --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_comp_lvl_fctr_id := p_comp_lvl_fctr_id ;
        --
        for l_clf_rec in c_clf(p_comp_lvl_fctr_id,l_mirror_src_entity_result_id,'CLF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CLF');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_clf_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;
          --
          -- MAPPING DATA : Store the mapping column information.
          --
          l_mapping_defined_balance_name := null;
          l_mapping_defined_balance_id   := null;
          if l_clf_rec.defined_balance_id is not null then
             --
             -- Get the defined balance name to display on mapping page.
             --
             open c_get_defined_bal_name(l_clf_rec.defined_balance_id);
             fetch c_get_defined_bal_name into l_mapping_defined_balance_name;
             close c_get_defined_bal_name;
             --
             l_mapping_defined_balance_id   := l_clf_rec.defined_balance_id;
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

          --
          -- To pass parent record's effective_start_date
          -- as p_effective_date while creating the
          -- non date-tracked child records

          l_bnb_bnfts_bal_esd := null;

          if l_clf_rec.bnfts_bal_id is not null then
            open c_parent_esd(l_clf_rec.bnfts_bal_id,'BNB',p_copy_entity_txn_id);
            fetch c_parent_esd into l_bnb_bnfts_bal_esd;
            close c_parent_esd;
          end if;
            --
          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_mirror_src_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'CLF',
            p_information1     => l_clf_rec.comp_lvl_fctr_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_clf_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information10     => l_bnb_bnfts_bal_esd,
            p_information225     => l_clf_rec.bnfts_bal_id,
            p_information111     => l_clf_rec.clf_attribute1,
            p_information120     => l_clf_rec.clf_attribute10,
            p_information121     => l_clf_rec.clf_attribute11,
            p_information122     => l_clf_rec.clf_attribute12,
            p_information123     => l_clf_rec.clf_attribute13,
            p_information124     => l_clf_rec.clf_attribute14,
            p_information125     => l_clf_rec.clf_attribute15,
            p_information126     => l_clf_rec.clf_attribute16,
            p_information127     => l_clf_rec.clf_attribute17,
            p_information128     => l_clf_rec.clf_attribute18,
            p_information129     => l_clf_rec.clf_attribute19,
            p_information112     => l_clf_rec.clf_attribute2,
            p_information130     => l_clf_rec.clf_attribute20,
            p_information131     => l_clf_rec.clf_attribute21,
            p_information132     => l_clf_rec.clf_attribute22,
            p_information133     => l_clf_rec.clf_attribute23,
            p_information134     => l_clf_rec.clf_attribute24,
            p_information135     => l_clf_rec.clf_attribute25,
            p_information136     => l_clf_rec.clf_attribute26,
            p_information137     => l_clf_rec.clf_attribute27,
            p_information138     => l_clf_rec.clf_attribute28,
            p_information139     => l_clf_rec.clf_attribute29,
            p_information113     => l_clf_rec.clf_attribute3,
            p_information140     => l_clf_rec.clf_attribute30,
            p_information114     => l_clf_rec.clf_attribute4,
            p_information115     => l_clf_rec.clf_attribute5,
            p_information116     => l_clf_rec.clf_attribute6,
            p_information117     => l_clf_rec.clf_attribute7,
            p_information118     => l_clf_rec.clf_attribute8,
            p_information119     => l_clf_rec.clf_attribute9,
            p_information110     => l_clf_rec.clf_attribute_category,
            p_information11     => l_clf_rec.comp_alt_val_to_use_cd,
            p_information262     => l_clf_rec.comp_calc_rl,
            p_information18     => l_clf_rec.comp_lvl_det_cd,
            p_information257     => l_clf_rec.comp_lvl_det_rl,
            p_information15     => l_clf_rec.comp_lvl_uom,
            p_information16     => l_clf_rec.comp_src_cd,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_defined_balance_name,
            p_information174    => l_mapping_defined_balance_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information294     => l_clf_rec.mn_comp_val,
            p_information293     => l_clf_rec.mx_comp_val,
            p_information170     => l_clf_rec.name,
            p_information13     => l_clf_rec.no_mn_comp_flag,
            p_information12     => l_clf_rec.no_mx_comp_flag,
            p_information14     => l_clf_rec.rndg_cd,
            p_information258     => l_clf_rec.rndg_rl,
            p_information17     => l_clf_rec.sttd_sal_prdcty_cd,
            p_information166    => NULL,  -- No ESD for Defined Balance
            p_information265    => l_clf_rec.object_version_number,
	    p_INFORMATION20      => l_clf_rec.proration_flag,
	    p_INFORMATION21	 => l_clf_rec.start_day_mo,
	    p_INFORMATION22	 => l_clf_rec.end_day_mo,
	    p_INFORMATION23      => l_clf_rec.start_year,
	    p_INFORMATION24      => l_clf_rec.end_year,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_clf_result_id is null then
              l_out_clf_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_clf_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- If there are any Fast Formulas attached to any Columns
            -- copy them also
            -------------------------------------------------------
            -- COMP_CALC_RL ----------
            -------------------------------------------------------
            --
                        if l_clf_rec.comp_calc_rl is not null then
                            --
                                ben_plan_design_program_module.create_formula_result
                                (
                                 p_validate                       =>  0
                                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                ,p_formula_id                     =>  l_clf_rec.comp_calc_rl
                                ,p_business_group_id              =>  l_clf_rec.business_group_id
                                ,p_number_of_copies               =>  l_number_of_copies
                                ,p_object_version_number          =>  l_object_version_number
                                ,p_effective_date                 =>  p_effective_date
                                );
                             --
                        end if;
                --

            -------------------------------------------------------
                        -- COMP_LVL_DET_RL
                        -------------------------------------------------------
                        --
                        if l_clf_rec.comp_lvl_det_rl is not null then
                            --
                                ben_plan_design_program_module.create_formula_result
                                (
                                 p_validate                       =>  0
                                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                ,p_formula_id                     =>  l_clf_rec.comp_lvl_det_rl
                                ,p_business_group_id              =>  l_clf_rec.business_group_id
                                ,p_number_of_copies               =>  l_number_of_copies
                                ,p_object_version_number          =>  l_object_version_number
                                ,p_effective_date                 =>  p_effective_date
                                );
                             --
                        end if;
                --

                        -------------------------------------------------------
                        -- RNDG_RL
                        -------------------------------------------------------
                        --
                        if l_clf_rec.rndg_rl is not null then
                            --
                                ben_plan_design_program_module.create_formula_result
                                (
                                 p_validate                       =>  0
                                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                ,p_formula_id                     =>  l_clf_rec.rndg_rl
                                ,p_business_group_id              =>  l_clf_rec.business_group_id
                                ,p_number_of_copies               =>  l_number_of_copies
                                ,p_object_version_number          =>  l_object_version_number
                                ,p_effective_date                 =>  p_effective_date
                                );
                             --
                        end if;
                --

         end loop;
         --
         for l_clf_rec in c_clf_drp(p_comp_lvl_fctr_id,l_mirror_src_entity_result_id,'CLF') loop
                ben_pd_rate_and_cvg_module.create_bnft_bal_results
                   (
                    p_validate                     => p_validate
                   ,p_copy_entity_result_id        => l_out_clf_result_id
                   ,p_copy_entity_txn_id           => p_copy_entity_txn_id
                   ,p_bnfts_bal_id                 => l_clf_rec.bnfts_bal_id
                   ,p_business_group_id            => p_business_group_id
                   ,p_number_of_copies             => p_number_of_copies
                   ,p_object_version_number        => l_object_version_number
                   ,p_effective_date               => p_effective_date
                   );
         end loop;
    ---------------------------------------------------------------
    -- END OF BEN_COMP_LVL_FCTR ----------------------
    ---------------------------------------------------------------
    end if;
    --
    if p_hrs_wkd_in_perd_fctr_id is not null then

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_hrs_wkd_in_perd_fctr_id,'HWF');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;
     ---------------------------------------------------------------
     -- START OF BEN_HRS_WKD_IN_PERD_FCTR ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_hrs_wkd_in_perd_fctr_id := p_hrs_wkd_in_perd_fctr_id ;
        --
        for l_hwf_rec in c_hwf(p_hrs_wkd_in_perd_fctr_id,
                               l_mirror_src_entity_result_id,'HWF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('HWF');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_hwf_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;
          --
          if l_hwf_rec.defined_balance_id is not null then
             --
             -- Get the defined balance name to display on mapping page.
             --
             open c_get_defined_bal_name(l_hwf_rec.defined_balance_id);
             fetch c_get_defined_bal_name into l_mapping_defined_balance_name;
             close c_get_defined_bal_name;
             --
             l_mapping_defined_balance_id   := l_hwf_rec.defined_balance_id;
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

          --
          -- To pass parent record's effective_start_date
          -- as p_effective_date while creating the
          -- non date-tracked child records

          l_bnb_bnfts_bal_esd := null;

          if l_hwf_rec.bnfts_bal_id is not null then
            open c_parent_esd(l_hwf_rec.bnfts_bal_id,'BNB',p_copy_entity_txn_id);
            fetch c_parent_esd into l_bnb_bnfts_bal_esd;
            close c_parent_esd;
          end if;

          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_mirror_src_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'HWF',
            p_information1     => l_hwf_rec.hrs_wkd_in_perd_fctr_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_hwf_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information10     => l_bnb_bnfts_bal_esd,
            p_information225     => l_hwf_rec.bnfts_bal_id,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_defined_balance_name,
            p_information174    => l_mapping_defined_balance_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information18     => l_hwf_rec.hrs_alt_val_to_use_cd,
            p_information13     => l_hwf_rec.hrs_src_cd,
            p_information17     => l_hwf_rec.hrs_wkd_bndry_perd_cd,
            p_information257     => l_hwf_rec.hrs_wkd_calc_rl,
            p_information15     => l_hwf_rec.hrs_wkd_det_cd,
            p_information258     => l_hwf_rec.hrs_wkd_det_rl,
            p_information111     => l_hwf_rec.hwf_attribute1,
            p_information120     => l_hwf_rec.hwf_attribute10,
            p_information121     => l_hwf_rec.hwf_attribute11,
            p_information122     => l_hwf_rec.hwf_attribute12,
            p_information123     => l_hwf_rec.hwf_attribute13,
            p_information124     => l_hwf_rec.hwf_attribute14,
            p_information125     => l_hwf_rec.hwf_attribute15,
            p_information126     => l_hwf_rec.hwf_attribute16,
            p_information127     => l_hwf_rec.hwf_attribute17,
            p_information128     => l_hwf_rec.hwf_attribute18,
            p_information129     => l_hwf_rec.hwf_attribute19,
            p_information112     => l_hwf_rec.hwf_attribute2,
            p_information130     => l_hwf_rec.hwf_attribute20,
            p_information131     => l_hwf_rec.hwf_attribute21,
            p_information132     => l_hwf_rec.hwf_attribute22,
            p_information133     => l_hwf_rec.hwf_attribute23,
            p_information134     => l_hwf_rec.hwf_attribute24,
            p_information135     => l_hwf_rec.hwf_attribute25,
            p_information136     => l_hwf_rec.hwf_attribute26,
            p_information137     => l_hwf_rec.hwf_attribute27,
            p_information138     => l_hwf_rec.hwf_attribute28,
            p_information139     => l_hwf_rec.hwf_attribute29,
            p_information113     => l_hwf_rec.hwf_attribute3,
            p_information140     => l_hwf_rec.hwf_attribute30,
            p_information114     => l_hwf_rec.hwf_attribute4,
            p_information115     => l_hwf_rec.hwf_attribute5,
            p_information116     => l_hwf_rec.hwf_attribute6,
            p_information117     => l_hwf_rec.hwf_attribute7,
            p_information118     => l_hwf_rec.hwf_attribute8,
            p_information119     => l_hwf_rec.hwf_attribute9,
            p_information110     => l_hwf_rec.hwf_attribute_category,
            p_information293     => l_hwf_rec.mn_hrs_num,
            p_information294     => l_hwf_rec.mx_hrs_num,
            p_information170     => l_hwf_rec.name,
            p_information11     => l_hwf_rec.no_mn_hrs_wkd_flag,
            p_information19     => l_hwf_rec.no_mx_hrs_wkd_flag,
            p_information16     => l_hwf_rec.once_r_cntug_cd,
            p_information12     => l_hwf_rec.pyrl_freq_cd,
            p_information14     => l_hwf_rec.rndg_cd,
            p_information259     => l_hwf_rec.rndg_rl,
            p_information166    => NULL,  -- No ESD for Defined Balance
            p_information265    => l_hwf_rec.object_version_number,
           --

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_hwf_result_id is null then
              l_out_hwf_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_hwf_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas also if they are attached to any columns --


            ---------------------------------------------------------------
            -- HRS_WKD_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_hwf_rec.hrs_wkd_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_hwf_rec.hrs_wkd_calc_rl
                ,p_business_group_id              =>  l_hwf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- HRS_WKD_DET_RL -----------------
            ---------------------------------------------------------------

            if l_hwf_rec.hrs_wkd_det_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_hwf_rec.hrs_wkd_det_rl
                ,p_business_group_id              =>  l_hwf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- RNDG_RL -----------------
            ---------------------------------------------------------------
            if l_hwf_rec.rndg_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_hwf_rec.rndg_rl
                ,p_business_group_id              =>  l_hwf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

         end loop;
         --
         for l_hwf_rec in c_hwf_drp(p_hrs_wkd_in_perd_fctr_id,l_mirror_src_entity_result_id,'HWF') loop
                ben_pd_rate_and_cvg_module.create_bnft_bal_results
                   (
                    p_validate                     => p_validate
                   ,p_copy_entity_result_id        => l_out_hwf_result_id
                   ,p_copy_entity_txn_id           => p_copy_entity_txn_id
                   ,p_bnfts_bal_id                 => l_hwf_rec.bnfts_bal_id
                   ,p_business_group_id            => p_business_group_id
                   ,p_number_of_copies             => p_number_of_copies
                   ,p_object_version_number        => l_object_version_number
                   ,p_effective_date               => p_effective_date
                   );
         end loop;
    ---------------------------------------------------------------
    -- END OF BEN_HRS_WKD_IN_PERD_FCTR ----------------------
    ---------------------------------------------------------------
    end if;
    --
    if p_los_fctr_id is not null then

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_los_fctr_id,'LSF');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;
     ---------------------------------------------------------------
     -- START OF BEN_LOS_FCTR ----------------------
     ---------------------------------------------------------------
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_los_fctr_id := p_los_fctr_id ;
        --
        for l_lsf_rec in c_lsf(p_los_fctr_id,l_mirror_src_entity_result_id,'LSF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('LSF');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_lsf_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
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
	    P_TABLE_ALIAS                    => 'LSF',
            p_information1     => l_lsf_rec.los_fctr_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_lsf_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information18     => l_lsf_rec.hrs_alt_val_to_use_cd,
            p_information19     => l_lsf_rec.los_alt_val_to_use_cd,
            p_information263     => l_lsf_rec.los_calc_rl,
            p_information15     => l_lsf_rec.los_det_cd,
            p_information257     => l_lsf_rec.los_det_rl,
            p_information14     => l_lsf_rec.los_dt_to_use_cd,
            p_information258     => l_lsf_rec.los_dt_to_use_rl,
            p_information17     => l_lsf_rec.los_uom,
            p_information111     => l_lsf_rec.lsf_attribute1,
            p_information120     => l_lsf_rec.lsf_attribute10,
            p_information121     => l_lsf_rec.lsf_attribute11,
            p_information122     => l_lsf_rec.lsf_attribute12,
            p_information123     => l_lsf_rec.lsf_attribute13,
            p_information124     => l_lsf_rec.lsf_attribute14,
            p_information125     => l_lsf_rec.lsf_attribute15,
            p_information126     => l_lsf_rec.lsf_attribute16,
            p_information127     => l_lsf_rec.lsf_attribute17,
            p_information128     => l_lsf_rec.lsf_attribute18,
            p_information129     => l_lsf_rec.lsf_attribute19,
            p_information112     => l_lsf_rec.lsf_attribute2,
            p_information130     => l_lsf_rec.lsf_attribute20,
            p_information131     => l_lsf_rec.lsf_attribute21,
            p_information132     => l_lsf_rec.lsf_attribute22,
            p_information133     => l_lsf_rec.lsf_attribute23,
            p_information134     => l_lsf_rec.lsf_attribute24,
            p_information135     => l_lsf_rec.lsf_attribute25,
            p_information136     => l_lsf_rec.lsf_attribute26,
            p_information137     => l_lsf_rec.lsf_attribute27,
            p_information138     => l_lsf_rec.lsf_attribute28,
            p_information139     => l_lsf_rec.lsf_attribute29,
            p_information113     => l_lsf_rec.lsf_attribute3,
            p_information140     => l_lsf_rec.lsf_attribute30,
            p_information114     => l_lsf_rec.lsf_attribute4,
            p_information115     => l_lsf_rec.lsf_attribute5,
            p_information116     => l_lsf_rec.lsf_attribute6,
            p_information117     => l_lsf_rec.lsf_attribute7,
            p_information118     => l_lsf_rec.lsf_attribute8,
            p_information119     => l_lsf_rec.lsf_attribute9,
            p_information110     => l_lsf_rec.lsf_attribute_category,
            p_information293     => l_lsf_rec.mn_los_num,
            p_information294     => l_lsf_rec.mx_los_num,
            p_information170     => l_lsf_rec.name,
            p_information13     => l_lsf_rec.no_mn_los_num_apls_flag,
            p_information12     => l_lsf_rec.no_mx_los_num_apls_flag,
            p_information16     => l_lsf_rec.rndg_cd,
            p_information259     => l_lsf_rec.rndg_rl,
            p_information11     => l_lsf_rec.use_overid_svc_dt_flag,
            p_information265    => l_lsf_rec.object_version_number,
           --

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_lsf_result_id is null then
              l_out_lsf_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_lsf_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas if they are attached to any column

            ---------------------------------------------------------------
            -- LOS_CALC_RL ------
            ---------------------------------------------------------------
            if l_lsf_rec.los_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lsf_rec.los_calc_rl
                ,p_business_group_id              =>  l_lsf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- LOS_DET_RL ------
            ---------------------------------------------------------------
            if l_lsf_rec.los_det_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lsf_rec.los_det_rl
                ,p_business_group_id              =>  l_lsf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;


            ---------------------------------------------------------------
            -- LOS_DT_TO_USE_RL ------
            ---------------------------------------------------------------
            if l_lsf_rec.los_dt_to_use_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lsf_rec.los_dt_to_use_rl
                ,p_business_group_id              =>  l_lsf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- RNDG_RL ------
            ---------------------------------------------------------------
            if l_lsf_rec.rndg_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_lsf_rec.rndg_rl
                ,p_business_group_id              =>  l_lsf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_LOS_FCTR ----------------------
    ---------------------------------------------------------------
    end if;
    if p_pct_fl_tm_fctr_id is not null then

        if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
          open c_object_exists(p_pct_fl_tm_fctr_id,'PFF');
          fetch c_object_exists into l_dummy;
          if c_object_exists%found then
            close c_object_exists;
            return;
          end if;
          close c_object_exists;
        end if;
     ---------------------------------------------------------------
     -- START OF BEN_PCT_FL_TM_FCTR ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_pct_fl_tm_fctr_id := p_pct_fl_tm_fctr_id ;
        --
        for l_pff_rec in c_pff(p_pct_fl_tm_fctr_id,l_mirror_src_entity_result_id,'PFF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('PFF');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_pff_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
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
	    P_TABLE_ALIAS                    => 'PFF',
            p_information1     => l_pff_rec.pct_fl_tm_fctr_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_pff_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information294     => l_pff_rec.mn_pct_val,
            p_information293     => l_pff_rec.mx_pct_val,
            p_information218     => l_pff_rec.name,
            p_information11     => l_pff_rec.no_mn_pct_val_flag,
            p_information12     => l_pff_rec.no_mx_pct_val_flag,
            p_information111     => l_pff_rec.pff_attribute1,
            p_information120     => l_pff_rec.pff_attribute10,
            p_information121     => l_pff_rec.pff_attribute11,
            p_information122     => l_pff_rec.pff_attribute12,
            p_information123     => l_pff_rec.pff_attribute13,
            p_information124     => l_pff_rec.pff_attribute14,
            p_information125     => l_pff_rec.pff_attribute15,
            p_information126     => l_pff_rec.pff_attribute16,
            p_information127     => l_pff_rec.pff_attribute17,
            p_information128     => l_pff_rec.pff_attribute18,
            p_information129     => l_pff_rec.pff_attribute19,
            p_information112     => l_pff_rec.pff_attribute2,
            p_information130     => l_pff_rec.pff_attribute20,
            p_information131     => l_pff_rec.pff_attribute21,
            p_information132     => l_pff_rec.pff_attribute22,
            p_information133     => l_pff_rec.pff_attribute23,
            p_information134     => l_pff_rec.pff_attribute24,
            p_information135     => l_pff_rec.pff_attribute25,
            p_information136     => l_pff_rec.pff_attribute26,
            p_information137     => l_pff_rec.pff_attribute27,
            p_information138     => l_pff_rec.pff_attribute28,
            p_information139     => l_pff_rec.pff_attribute29,
            p_information113     => l_pff_rec.pff_attribute3,
            p_information140     => l_pff_rec.pff_attribute30,
            p_information114     => l_pff_rec.pff_attribute4,
            p_information115     => l_pff_rec.pff_attribute5,
            p_information116     => l_pff_rec.pff_attribute6,
            p_information117     => l_pff_rec.pff_attribute7,
            p_information118     => l_pff_rec.pff_attribute8,
            p_information119     => l_pff_rec.pff_attribute9,
            p_information110     => l_pff_rec.pff_attribute_category,
            p_information15     => l_pff_rec.rndg_cd,
            p_information257     => l_pff_rec.rndg_rl,
            p_information13     => l_pff_rec.use_prmry_asnt_only_flag,
            p_information14     => l_pff_rec.use_sum_of_all_asnts_flag,
            p_information265    => l_pff_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_pff_result_id is null then
              l_out_pff_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_pff_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas if any
            ---------------------------------------------------------------
            -- RNDG_RL -----------------
            ---------------------------------------------------------------

            if l_pff_rec.rndg_rl is not null then
            --
            ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0
            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
            ,p_formula_id                     =>  l_pff_rec.rndg_rl
            ,p_business_group_id              =>  l_pff_rec.business_group_id
            ,p_number_of_copies               =>  l_number_of_copies
            ,p_object_version_number          =>  l_object_version_number
            ,p_effective_date                 =>  p_effective_date
            );

            --
            end if;


         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_PCT_FL_TM_FCTR ----------------------
    ---------------------------------------------------------------
    end if;
    hr_utility.set_location('end create_drpar_results',100);
   end create_drpar_results ;
  --

  procedure create_vrb_rt_elg_prf_results
    (
     p_validate                       in  number    default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number    default null
    ,p_vrbl_rt_prfl_id                in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_vrb_rt_elg_prf_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    ---------------------------------------------------------------
    -- START OF BEN_VRBL_RT_ELIG_PRFL_F ----------------------
    ---------------------------------------------------------------
    cursor c_vep_from_parent(c_VRBL_RT_PRFL_ID number) is
    select  distinct vrbl_rt_elig_prfl_id
    from BEN_VRBL_RT_ELIG_PRFL_F
    where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
    --
    cursor c_vep(c_vrbl_rt_elig_prfl_id number,c_mirror_src_entity_result_id number,
                 c_table_alias varchar2 ) is
    select  vep.*
    from BEN_VRBL_RT_ELIG_PRFL_F vep
    where  vep.vrbl_rt_elig_prfl_id = c_vrbl_rt_elig_prfl_id
     -- and vep.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_VRBL_RT_ELIG_PRFL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_vrbl_rt_elig_prfl_id
         -- and information4 = vep.business_group_id
         and information2 = vep.effective_start_date
         and information3 = vep.effective_end_date
        );

      --
      -- Bug : 3752407 : Global cursor g_table_route will now be used
      -- Cursor to get table_route_id
      --
      -- cursor c_table_route(c_parent_table_alias varchar2) is
      -- select table_route_id
      -- from pqh_table_route trt
      -- where trt.table_alias = c_parent_table_alias;
      -- trt.from_clause = 'OAB'
      -- and   trt.where_clause = upper(c_parent_table_name) ;

      l_vrbl_rt_elig_prfl_id                 number(15);
      l_out_vep_result_id   number(15);

      cursor c_elp_from_parent(c_VRBL_RT_ELIG_PRFL_ID number) is
      select  distinct eligy_prfl_id
      from BEN_VRBL_RT_ELIG_PRFL_F
      where VRBL_RT_ELIG_PRFL_ID = c_VRBL_RT_ELIG_PRFL_ID;

     ---------------------------------------------------------------
     -- END OF BEN_VRBL_RT_ELIG_PRFL_F ----------------------
     ---------------------------------------------------------------

     l_mirror_src_entity_result_id number(15);
     l_table_route_id              number(15);
     l_result_type_cd              varchar2(30);
     l_information5                ben_copy_entity_results.information5%type;
     l_number_of_copies            number(15);

     l_mndtry_flag                 ben_vrbl_rt_elig_prfl_f.mndtry_flag%type;

    --ENH Avoid duplicate ELPRO's
     l_mirror_g_pdw_allow_dup_rslt varchar2(30);

--Bug 5059695
     l_dummy_g_pdw_allow_dup_rslt varchar2(30);
--End Bug 5059695

    begin
      l_number_of_copies := p_number_of_copies ;

          -- Bug 5059695 : Fetch the transaction category
	if(ben_plan_design_elpro_module.g_copy_entity_txn_id <> p_copy_entity_txn_id) then

	   ben_plan_design_elpro_module.g_copy_entity_txn_id := p_copy_entity_txn_id;

	       open ben_plan_design_elpro_module.g_trasaction_categories(p_copy_entity_txn_id) ;
		fetch  ben_plan_design_elpro_module.g_trasaction_categories into ben_plan_design_elpro_module.g_trasaction_category;
	       close ben_plan_design_elpro_module.g_trasaction_categories;

	end if;
--End Bug 5059695
     ---------------------------------------------------------------
     -- START OF BEN_VRBL_RT_ELIG_PRFL_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_vep_from_parent(p_VRBL_RT_PRFL_ID) loop
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_vrbl_rt_elig_prfl_id := l_parent_rec.vrbl_rt_elig_prfl_id ;
        --
        for l_vep_rec in c_vep(l_parent_rec.vrbl_rt_elig_prfl_id,l_mirror_src_entity_result_id,'VEP') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('VEP');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := ben_plan_design_program_module.get_eligy_prfl_name(l_vep_rec.eligy_prfl_id
                                                                               ,p_effective_date); --'Intersection';
          --
          if p_effective_date between l_vep_rec.effective_start_date
             and l_vep_rec.effective_end_date then
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
            p_parent_entity_result_id        =>  NULL, -- Hide for HGrid
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'VEP',
            p_information1       => l_vep_rec.vrbl_rt_elig_prfl_id,
            p_information2       => l_vep_rec.EFFECTIVE_START_DATE,
            p_information3       => l_vep_rec.EFFECTIVE_END_DATE,
            p_information4       => l_vep_rec.business_group_id,
            p_information5       => l_information5,
            p_information263     => l_vep_rec.eligy_prfl_id,
            p_information11      => l_vep_rec.mndtry_flag,
            p_information111     => l_vep_rec.vep_attribute1,
            p_information120     => l_vep_rec.vep_attribute10,
            p_information121     => l_vep_rec.vep_attribute11,
            p_information122     => l_vep_rec.vep_attribute12,
            p_information123     => l_vep_rec.vep_attribute13,
            p_information124     => l_vep_rec.vep_attribute14,
            p_information125     => l_vep_rec.vep_attribute15,
            p_information126     => l_vep_rec.vep_attribute16,
            p_information127     => l_vep_rec.vep_attribute17,
            p_information128     => l_vep_rec.vep_attribute18,
            p_information129     => l_vep_rec.vep_attribute19,
            p_information112     => l_vep_rec.vep_attribute2,
            p_information130     => l_vep_rec.vep_attribute20,
            p_information131     => l_vep_rec.vep_attribute21,
            p_information132     => l_vep_rec.vep_attribute22,
            p_information133     => l_vep_rec.vep_attribute23,
            p_information134     => l_vep_rec.vep_attribute24,
            p_information135     => l_vep_rec.vep_attribute25,
            p_information136     => l_vep_rec.vep_attribute26,
            p_information137     => l_vep_rec.vep_attribute27,
            p_information138     => l_vep_rec.vep_attribute28,
            p_information139     => l_vep_rec.vep_attribute29,
            p_information113     => l_vep_rec.vep_attribute3,
            p_information140     => l_vep_rec.vep_attribute30,
            p_information114     => l_vep_rec.vep_attribute4,
            p_information115     => l_vep_rec.vep_attribute5,
            p_information116     => l_vep_rec.vep_attribute6,
            p_information117     => l_vep_rec.vep_attribute7,
            p_information118     => l_vep_rec.vep_attribute8,
            p_information119     => l_vep_rec.vep_attribute9,
            p_information110     => l_vep_rec.vep_attribute_category,
            p_information262     => l_vep_rec.vrbl_rt_prfl_id,
            p_information265     => l_vep_rec.object_version_number,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_vep_result_id is null then
              l_out_vep_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_vep_result_id := l_copy_entity_result_id ;
               l_mndtry_flag       := l_vep_rec.mndtry_flag;
            end if;
            --
         end loop;
         --

 	 l_mirror_g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_allow_dup_rslt;

         -- Create Eligibility Profiles and Criteria

  -- Bug 5059695
	    if(ben_plan_design_elpro_module.g_trasaction_category = 'PQHGSP') then
	        l_dummy_g_pdw_allow_dup_rslt := null;
	    else
	       l_dummy_g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
	    end if;
-- End Bug 5059695

         for l_parent_rec  in c_elp_from_parent(l_vrbl_rt_elig_prfl_id) loop
           ben_plan_design_elpro_module.create_elig_prfl_results
           (
             p_validate                       => p_validate
            ,p_mirror_src_entity_result_id    => l_out_vep_result_id
            ,p_parent_entity_result_id        => p_copy_entity_result_id -- Result id of Vapro
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_eligy_prfl_id                  => l_parent_rec.eligy_prfl_id
            ,p_mndtry_flag                    => l_mndtry_flag
            ,p_business_group_id              => p_business_group_id
            ,p_number_of_copies               => p_number_of_copies
            ,p_object_version_number          => l_object_version_number
            ,p_effective_date                 => p_effective_date
	    ,p_no_dup_rslt		      => l_dummy_g_pdw_allow_dup_rslt
           );
	   -- ENH Avoid duplicates in Eligibility Profiles
   	   --Passed the value PDW_NO_DUP_RSLT to create_elig_prfl_results so that
	   --no duplicate results are created

         end loop;
	 ben_plan_design_program_module.g_pdw_allow_dup_rslt := l_mirror_g_pdw_allow_dup_rslt;
	 -- ENH Avoid duplicates in Eligibility Profiles
	 --reset the global allow dup results

       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_VRBL_RT_ELIG_PRFL_F ----------------------
    ---------------------------------------------------------------

  end ;

  procedure create_vapro_results
    (
     p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Source vapro
    ,p_copy_entity_txn_id             in  number    default null
    ,p_vrbl_rt_prfl_id                in  number    default null
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in varchar2    default null
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
     l_mapping_id         number;
     l_mapping_name       varchar2(600);
     l_mapping_id1        number;
     l_mapping_name1      varchar2(600);
    l_mapping_column_name1 pqh_attributes.attribute_name%type;
    l_mapping_column_name2 pqh_attributes.attribute_name%type;

   ---------------------------------------------------------------
   -- START OF BEN_VRBL_RT_PRFL_F ----------------------
   ---------------------------------------------------------------
   cursor c_vpf(c_vrbl_rt_prfl_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  vpf.*
   from BEN_VRBL_RT_PRFL_F vpf
   where  vpf.vrbl_rt_prfl_id = c_vrbl_rt_prfl_id
     -- and vpf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_VRBL_RT_PRFL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_vrbl_rt_prfl_id
         -- and information4 = vpf.business_group_id
           and information2 = vpf.effective_start_date
           and information3 = vpf.effective_end_date);
    l_vrbl_rt_prfl_id                 number(15);
    l_out_vpf_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_VRBL_RT_PRFL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_AGE_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_art_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct age_rt_id
   from BEN_AGE_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_art(c_age_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  art.*
   from BEN_AGE_RT_F art
   where  art.age_rt_id = c_age_rt_id
     -- and art.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_AGE_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_age_rt_id
         -- and information4 = art.business_group_id
           and information2 = art.effective_start_date
           and information3 = art.effective_end_date);
    l_age_rt_id                 number(15);
    l_out_art_result_id   number(15);
   --
   cursor c_art_drp(c_age_rt_id number,c_mirror_src_entity_result_id number,
                    c_table_alias varchar2 ) is
   select distinct cpe.information246 age_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_AGE_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_age_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_AGE_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ASNT_SET_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_asr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  asnt_set_rt_id
   from BEN_ASNT_SET_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_asr(c_asnt_set_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  asr.*
   from BEN_ASNT_SET_RT_F asr
   where  asr.asnt_set_rt_id = c_asnt_set_rt_id
     -- and asr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ASNT_SET_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_asnt_set_rt_id
         -- and information4 = asr.business_group_id
           and information2 = asr.effective_start_date
           and information3 = asr.effective_end_date);
    l_asnt_set_rt_id                 number(15);
    l_out_asr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name3(p_id in number) is
      select assignment_set_name
      from hr_assignment_sets
      where business_group_id = p_business_group_id
        and assignment_set_id = p_id;
    --
   ---------------------------------------------------------------
   -- END OF BEN_ASNT_SET_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_BENFTS_GRP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_brg_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct benfts_grp_rt_id
   from BEN_BENFTS_GRP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_brg(c_benfts_grp_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  brg.*
   from BEN_BENFTS_GRP_RT_F brg
   where  brg.benfts_grp_rt_id = c_benfts_grp_rt_id
     -- and brg.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BENFTS_GRP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_benfts_grp_rt_id
         -- and information4 = brg.business_group_id
           and information2 = brg.effective_start_date
           and information3 = brg.effective_end_date);
    l_benfts_grp_rt_id                 number(15);
    l_out_brg_result_id   number(15);
   --
   cursor c_brg_bg(c_benfts_grp_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information222 benfts_grp_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_BENFTS_GRP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_benfts_grp_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_BENFTS_GRP_RT_F ----------------------
   ---------------------------------------------------------------

   ---------------------------------------------------------------
   -- START OF BEN_BRGNG_UNIT_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_bur_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  brgng_unit_rt_id
   from BEN_BRGNG_UNIT_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_bur(c_brgng_unit_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  bur.*
   from BEN_BRGNG_UNIT_RT_F bur
   where  bur.brgng_unit_rt_id = c_brgng_unit_rt_id
     -- and bur.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BRGNG_UNIT_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_brgng_unit_rt_id
         -- and information4 = bur.business_group_id
           and information2 = bur.effective_start_date
           and information3 = bur.effective_end_date);
    l_brgng_unit_rt_id                 number(15);
    l_out_bur_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BRGNG_UNIT_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CMBN_AGE_LOS_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_cmr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct cmbn_age_los_rt_id
   from BEN_CMBN_AGE_LOS_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_cmr(c_cmbn_age_los_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  cmr.*
   from BEN_CMBN_AGE_LOS_RT_F cmr
   where  cmr.cmbn_age_los_rt_id = c_cmbn_age_los_rt_id
     -- and cmr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CMBN_AGE_LOS_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_cmbn_age_los_rt_id
         -- and information4 = cmr.business_group_id
           and information2 = cmr.effective_start_date
           and information3 = cmr.effective_end_date);
    l_cmbn_age_los_rt_id                 number(15);
    l_out_cmr_result_id   number(15);
   --
   cursor c_cmr_drp(c_cmbn_age_los_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information223 cmbn_age_los_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_CMBN_AGE_LOS_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_cmbn_age_los_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_CMBN_AGE_LOS_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_COMP_LVL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_clr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct comp_lvl_rt_id
   from BEN_COMP_LVL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_clr(c_comp_lvl_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  clr.*
   from BEN_COMP_LVL_RT_F clr
   where  clr.comp_lvl_rt_id = c_comp_lvl_rt_id
     -- and clr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_COMP_LVL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_comp_lvl_rt_id
         -- and information4 = clr.business_group_id
           and information2 = clr.effective_start_date
           and information3 = clr.effective_end_date);
    l_comp_lvl_rt_id                 number(15);
    l_out_clr_result_id   number(15);
   --
   cursor c_clr_drp(c_comp_lvl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information254 comp_lvl_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_COMP_LVL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_comp_lvl_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_COMP_LVL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSBLD_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_dbr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  dsbld_rt_id
   from BEN_DSBLD_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_dbr(c_dsbld_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  dbr.*
   from BEN_DSBLD_RT_F dbr
   where  dbr.dsbld_rt_id = c_dsbld_rt_id
     -- and dbr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSBLD_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsbld_rt_id
         -- and information4 = dbr.business_group_id
           and information2 = dbr.effective_start_date
           and information3 = dbr.effective_end_date);
    l_dsbld_rt_id                 number(15);
    l_out_dbr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DSBLD_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_EE_STAT_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_esr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  ee_stat_rt_id
   from BEN_EE_STAT_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_esr(c_ee_stat_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  esr.*
   from BEN_EE_STAT_RT_F esr
   where  esr.ee_stat_rt_id = c_ee_stat_rt_id
     -- and esr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_EE_STAT_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ee_stat_rt_id
         -- and information4 = esr.business_group_id
           and information2 = esr.effective_start_date
           and information3 = esr.effective_end_date);
    l_ee_stat_rt_id                 number(15);
    l_out_esr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name4(p_id in number) is
      select nvl(atl.user_status, stl.user_status) dsp_meaning
      from per_assignment_status_types s,
           per_ass_status_type_amends a ,
           per_business_groups bus ,
           per_assignment_status_types_tl stl ,
           per_ass_status_type_amends_tl atl
      where a.assignment_status_type_id (+) = s.assignment_status_type_id
        and a.business_group_id (+) = p_business_group_id
        and nvl(s.business_group_id, p_business_group_id) = p_business_group_id
        and nvl(s.legislation_code, bus.legislation_code) = bus.legislation_code
        -- and bus.business_group_id = p_business_group_id
        and bus.business_group_id = nvl(s.business_group_id, p_business_group_id)
        and s.assignment_status_type_id = p_id
        and nvl(a.active_flag, s.active_flag) = 'Y'
        and atl.ass_status_type_amend_id (+) = a.ass_status_type_amend_id
        and atl.language (+) = userenv('LANG')
        and stl.assignment_status_type_id = s.assignment_status_type_id
        and stl.language  = userenv('LANG');
    --
   ---------------------------------------------------------------
   -- END OF BEN_EE_STAT_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_FL_TM_PT_TM_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ftr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  fl_tm_pt_tm_rt_id
   from BEN_FL_TM_PT_TM_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_ftr(c_fl_tm_pt_tm_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  ftr.*
   from BEN_FL_TM_PT_TM_RT_F ftr
   where  ftr.fl_tm_pt_tm_rt_id = c_fl_tm_pt_tm_rt_id
     -- and ftr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_FL_TM_PT_TM_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_fl_tm_pt_tm_rt_id
         -- and information4 = ftr.business_group_id
           and information2 = ftr.effective_start_date
           and information3 = ftr.effective_end_date);

    l_fl_tm_pt_tm_rt_id                 number(15);
    l_out_ftr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_FL_TM_PT_TM_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_GNDR_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_gnr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  gndr_rt_id
   from BEN_GNDR_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_gnr(c_gndr_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  gnr.*
   from BEN_GNDR_RT_F gnr
   where  gnr.gndr_rt_id = c_gndr_rt_id
     -- and gnr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_GNDR_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_gndr_rt_id
         -- and information4 = gnr.business_group_id
           and information2 = gnr.effective_start_date
           and information3 = gnr.effective_end_date);
    l_gndr_rt_id                 number(15);
    l_out_gnr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_GNDR_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_GRADE_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_grr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  grade_rt_id
   from BEN_GRADE_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_grr(c_grade_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  grr.*
   from BEN_GRADE_RT_F grr
   where  grr.grade_rt_id = c_grade_rt_id
     -- and grr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_GRADE_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_grade_rt_id
         -- and information4 = grr.business_group_id
           and information2 = grr.effective_start_date
           and information3 = grr.effective_end_date);
    l_grade_rt_id                 number(15);
    l_out_grr_result_id   number(15);
    --
    cursor c_get_mapping_name5(p_id in number,p_date in date) is
      select gra.name dsp_name
      from per_grades_vl gra
      where business_group_id  = p_business_group_id
        and gra.grade_id = p_id
        and p_date between date_from and nvl(date_to, p_date) ;
    --

    cursor c_grade_start_date(c_grade_id number) is
    select date_from
    from per_grades
    where grade_id = c_grade_id;

    l_grade_start_date  per_grades.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_GRADE_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_HRLY_SLRD_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_hsr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  hrly_slrd_rt_id
   from BEN_HRLY_SLRD_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_hsr(c_hrly_slrd_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  hsr.*
   from BEN_HRLY_SLRD_RT_F hsr
   where  hsr.hrly_slrd_rt_id = c_hrly_slrd_rt_id
     -- and hsr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_HRLY_SLRD_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_hrly_slrd_rt_id
         -- and information4 = hsr.business_group_id
           and information2 = hsr.effective_start_date
           and information3 = hsr.effective_end_date);
    l_hrly_slrd_rt_id                 number(15);
    l_out_hsr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_HRLY_SLRD_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_HRS_WKD_IN_PERD_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_hwr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct hrs_wkd_in_perd_rt_id
   from BEN_HRS_WKD_IN_PERD_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_hwr(c_hrs_wkd_in_perd_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  hwr.*
   from BEN_HRS_WKD_IN_PERD_RT_F hwr
   where  hwr.hrs_wkd_in_perd_rt_id = c_hrs_wkd_in_perd_rt_id
     -- and hwr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_HRS_WKD_IN_PERD_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_hrs_wkd_in_perd_rt_id
         -- and information4 = hwr.business_group_id
           and information2 = hwr.effective_start_date
           and information3 = hwr.effective_end_date);
    l_hrs_wkd_in_perd_rt_id                 number(15);
    l_out_hwr_result_id   number(15);
   --
   cursor c_hwr_drp(c_hrs_wkd_in_perd_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information224 hrs_wkd_in_perd_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_HRS_WKD_IN_PERD_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_hrs_wkd_in_perd_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_HRS_WKD_IN_PERD_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LBR_MMBR_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lmm_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  lbr_mmbr_rt_id
   from BEN_LBR_MMBR_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_lmm(c_lbr_mmbr_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  lmm.*
   from BEN_LBR_MMBR_RT_F lmm
   where  lmm.lbr_mmbr_rt_id = c_lbr_mmbr_rt_id
     -- and lmm.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LBR_MMBR_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_lbr_mmbr_rt_id
         -- and information4 = lmm.business_group_id
           and information2 = lmm.effective_start_date
           and information3 = lmm.effective_end_date);
    l_lbr_mmbr_rt_id                 number(15);
    l_out_lmm_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LBR_MMBR_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LGL_ENTY_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ler_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  lgl_enty_rt_id
   from BEN_LGL_ENTY_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_ler(c_lgl_enty_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  ler.*
   from BEN_LGL_ENTY_RT_F ler
   where  ler.lgl_enty_rt_id = c_lgl_enty_rt_id
     -- and ler.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LGL_ENTY_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_lgl_enty_rt_id
         -- and information4 = ler.business_group_id
           and information2 = ler.effective_start_date
           and information3 = ler.effective_end_date);
    l_lgl_enty_rt_id                 number(15);
    l_out_ler_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name6(p_id in number,p_date in date) is
      select hou.name dsp_name
      from hr_organization_units_v hou ,
           hr_organization_information hoi
      where business_group_id  = p_business_group_id
        and hou.organization_id = p_id
        and p_date between date_from and nvl(date_to, p_date)
        and hou.organization_id = hoi.organization_id
        and hoi.org_information2 = 'Y'
        and hoi.org_information1 = 'HR_LEGAL'
        and hoi.org_information_context || '' ='CLASS' ;

   cursor c_organization_start_date(c_organization_id number) is
   select date_from
   from hr_all_organization_units
   where organization_id = c_organization_id;

   l_organization_start_date  hr_all_organization_units.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_LGL_ENTY_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LOA_RSN_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lar_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  loa_rsn_rt_id
   from BEN_LOA_RSN_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_lar(c_loa_rsn_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  lar.*
   from BEN_LOA_RSN_RT_F lar
   where  lar.loa_rsn_rt_id = c_loa_rsn_rt_id
     -- and lar.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LOA_RSN_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_loa_rsn_rt_id
         -- and information4 = lar.business_group_id
           and information2 = lar.effective_start_date
           and information3 = lar.effective_end_date);
    l_loa_rsn_rt_id                 number(15);
    l_out_lar_result_id   number(15);
--PADMAJA
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name7(p_id in number,p_date in date) is
      select abt.name
      from per_absence_attendance_types abt
      where abt.business_group_id = p_business_group_id
        and abt.absence_attendance_type_id  = p_id
        and  p_date between abt.date_effective
        and nvl(abt.date_end, p_date);
    --

    cursor c_get_mapping_name8(p_id in number,p_id1 in number,p_date in date) is
      select hl.meaning name
      from per_abs_attendance_reasons abr,
           hr_leg_lookups hl
      where abr.business_group_id = p_business_group_id
        and abr.absence_attendance_type_id = p_id
        and abr.abs_attendance_reason_id = p_id1
        and abr.name = hl.lookup_code
        and hl.lookup_type = 'ABSENCE_REASON'
        and hl.enabled_flag = 'Y'
        and p_date between
        nvl(hl.start_date_active, p_date)
        and nvl(hl.end_date_active, p_date);
     --

     cursor c_absence_type_start_date(c_absence_attendance_type_id number) is
     select date_effective
     from per_absence_attendance_types
     where absence_attendance_type_id = c_absence_attendance_type_id;

     l_absence_type_start_date per_absence_attendance_types.date_effective%type;
   ---------------------------------------------------------------
   -- END OF BEN_LOA_RSN_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LOS_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lsr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct los_rt_id
   from BEN_LOS_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_lsr(c_los_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  lsr.*
   from BEN_LOS_RT_F lsr
   where  lsr.los_rt_id = c_los_rt_id
     -- and lsr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LOS_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_los_rt_id
         -- and information4 = lsr.business_group_id
           and information2 = lsr.effective_start_date
           and information3 = lsr.effective_end_date);
    l_los_rt_id                 number(15);
    l_out_lsr_result_id   number(15);
   --
   cursor c_lsr_drp(c_los_rt_id number,c_mirror_src_entity_result_id number,
                    c_table_alias varchar2 ) is
   select distinct cpe.information243 los_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_LOS_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_los_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_LOS_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_LVG_RSN_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_lrn_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  lvg_rsn_rt_id
   from BEN_LVG_RSN_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_lrn(c_lvg_rsn_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  lrn.*
   from BEN_LVG_RSN_RT_F lrn
   where  lrn.lvg_rsn_rt_id = c_lvg_rsn_rt_id
     -- and lrn.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_LVG_RSN_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_lvg_rsn_rt_id
         -- and information4 = lrn.business_group_id
           and information2 = lrn.effective_start_date
           and information3 = lrn.effective_end_date);
    l_lvg_rsn_rt_id                 number(15);
    l_out_lrn_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_LVG_RSN_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ORG_UNIT_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_our_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  org_unit_rt_id
   from BEN_ORG_UNIT_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_our(c_org_unit_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  our.*
   from BEN_ORG_UNIT_RT_F our
   where  our.org_unit_rt_id = c_org_unit_rt_id
     -- and our.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ORG_UNIT_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_org_unit_rt_id
         -- and information4 = our.business_group_id
           and information2 = our.effective_start_date
           and information3 = our.effective_end_date);
--PADMAJA

    --
    -- pabodla : mapping data - Bug 2716749
    --
    cursor c_get_mapping_name9(p_id in number,p_date in date) is
           select name
           from hr_all_organization_units_vl
           where business_group_id = business_group_id
             and organization_id = p_id
             and internal_external_flag = 'INT'
             and p_date between nvl(date_from, p_date)
                   and nvl(date_to, p_date)
             order by name;
    --
    l_org_unit_rt_id                 number(15);
    l_out_our_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ORG_UNIT_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PCT_FL_TM_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pfr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct pct_fl_tm_rt_id
   from BEN_PCT_FL_TM_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pfr(c_pct_fl_tm_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pfr.*
   from BEN_PCT_FL_TM_RT_F pfr
   where  pfr.pct_fl_tm_rt_id = c_pct_fl_tm_rt_id
     -- and pfr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PCT_FL_TM_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pct_fl_tm_rt_id
         -- and information4 = pfr.business_group_id
           and information2 = pfr.effective_start_date
           and information3 = pfr.effective_end_date);
    l_pct_fl_tm_rt_id                 number(15);
    l_out_pfr_result_id   number(15);
   --
   cursor c_pfr_drp(c_pct_fl_tm_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information233 pct_fl_tm_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_PCT_FL_TM_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pct_fl_tm_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_PCT_FL_TM_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PER_TYP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ptr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  per_typ_rt_id
   from BEN_PER_TYP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_ptr(c_per_typ_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  ptr.*
   from BEN_PER_TYP_RT_F ptr
   where  ptr.per_typ_rt_id = c_per_typ_rt_id
     -- and ptr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PER_TYP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_per_typ_rt_id
         -- and information4 = ptr.business_group_id
           and information2 = ptr.effective_start_date
           and information3 = ptr.effective_end_date);
    l_per_typ_rt_id                 number(15);
    l_out_ptr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_person_type_name(p_person_typ_id in number) is
      select ptl.user_person_type
      from per_person_types ppt,
         hr_leg_lookups hrlkup,
         per_person_types_tl ptl
    where active_flag = 'Y'
      -- and business_group_id = p_business_group_id
      and hrlkup.lookup_type = 'PERSON_TYPE'
      and hrlkup.lookup_code =  ppt.system_person_type
      and ppt.active_flag = 'Y'
      and ppt.person_type_id = p_person_typ_id
      and ppt.person_type_id = ptl.person_type_id
      and ptl.language = userenv('LANG');
    --
    l_mapping_person_type_id   number;
    l_mapping_person_type_name varchar2(600);
   --
   ---------------------------------------------------------------
   -- END OF BEN_PER_TYP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_POE_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_prt_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  poe_rt_id
   from BEN_POE_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_prt(c_poe_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  prt.*
   from BEN_POE_RT_F prt
   where  prt.poe_rt_id = c_poe_rt_id
     -- and prt.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_POE_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_poe_rt_id
         -- and information4 = prt.business_group_id
           and information2 = prt.effective_start_date
           and information3 = prt.effective_end_date);
    l_poe_rt_id                 number(15);
    l_out_prt_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_POE_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PPL_GRP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pgr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  ppl_grp_rt_id
   from BEN_PPL_GRP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pgr(c_ppl_grp_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pgr.*
   from BEN_PPL_GRP_RT_F pgr
   where  pgr.ppl_grp_rt_id = c_ppl_grp_rt_id
     -- and pgr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PPL_GRP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ppl_grp_rt_id
         -- and information4 = pgr.business_group_id
           and information2 = pgr.effective_start_date
           and information3 = pgr.effective_end_date);
    l_ppl_grp_rt_id                 number(15);
    l_out_pgr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PPL_GRP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PSTL_ZIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pzr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct pstl_zip_rt_id
   from BEN_PSTL_ZIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pzr(c_pstl_zip_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pzr.*
   from BEN_PSTL_ZIP_RT_F pzr
   where  pzr.pstl_zip_rt_id = c_pstl_zip_rt_id
     -- and pzr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PSTL_ZIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pstl_zip_rt_id
         -- and information4 = pzr.business_group_id
           and information2 = pzr.effective_start_date
           and information3 = pzr.effective_end_date);
    l_pstl_zip_rt_id                 number(15);
    l_out_pzr_result_id   number(15);
   --
   cursor c_pzr_pstl(c_pstl_zip_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information245 pstl_zip_rng_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_PSTL_ZIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pstl_zip_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_PSTL_ZIP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PYRL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pr__from_parent(c_VRBL_RT_PRFL_ID number) is
   select  pyrl_rt_id
   from BEN_PYRL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pr_(c_pyrl_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pr_.*
   from BEN_PYRL_RT_F pr_
   where  pr_.pyrl_rt_id = c_pyrl_rt_id
     -- and pr_.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PYRL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pyrl_rt_id
         -- and information4 = pr_.business_group_id
           and information2 = pr_.effective_start_date
           and information3 = pr_.effective_end_date);
    l_pyrl_rt_id                 number(15);
    l_out_pr__result_id   number(15);
    --
    cursor c_get_mapping_name12(p_id in number,p_date in date) is
      select prl.payroll_name dsp_payroll_name
      from pay_all_payrolls_f prl
      where prl.business_group_id  = p_business_group_id
        and prl.payroll_id = p_id
        and p_date between prl.effective_start_date and prl.effective_end_date ;
    --

    cursor c_payroll_start_date(c_payroll_id number) is
    select min(effective_start_date) effective_start_date
    from pay_all_payrolls_f
    where payroll_id = c_payroll_id;

    l_payroll_start_date pay_all_payrolls_f.effective_start_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_PYRL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PY_BSS_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pbr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  py_bss_rt_id
   from BEN_PY_BSS_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pbr(c_py_bss_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pbr.*
   from BEN_PY_BSS_RT_F pbr
   where  pbr.py_bss_rt_id = c_py_bss_rt_id
     -- and pbr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PY_BSS_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_py_bss_rt_id
         -- and information4 = pbr.business_group_id
           and information2 = pbr.effective_start_date
           and information3 = pbr.effective_end_date);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name13(p_id in number) is
     select name from per_pay_bases
     where business_group_id = p_business_group_id
       and pay_basis_id = p_id;

    l_py_bss_rt_id                 number(15);
    l_out_pbr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PY_BSS_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_SCHEDD_HRS_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_shr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  schedd_hrs_rt_id
   from BEN_SCHEDD_HRS_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_shr(c_schedd_hrs_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  shr.*
   from BEN_SCHEDD_HRS_RT_F shr
   where  shr.schedd_hrs_rt_id = c_schedd_hrs_rt_id
     -- and shr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_SCHEDD_HRS_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_schedd_hrs_rt_id
         -- and information4 = shr.business_group_id
           and information2 = shr.effective_start_date
           and information3 = shr.effective_end_date);
    l_schedd_hrs_rt_id                 number(15);
    l_out_shr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_SCHEDD_HRS_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_SVC_AREA_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_sar_from_parent(c_VRBL_RT_PRFL_ID number) is
   select distinct svc_area_rt_id
   from BEN_SVC_AREA_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_sar(c_svc_area_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  sar.*
   from BEN_SVC_AREA_RT_F sar
   where  sar.svc_area_rt_id = c_svc_area_rt_id
     -- and sar.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_SVC_AREA_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_svc_area_rt_id
         -- and information4 = sar.business_group_id
           and information2 = sar.effective_start_date
           and information3 = sar.effective_end_date);
    l_svc_area_rt_id                 number(15);
    l_out_sar_result_id   number(15);
   --
   cursor c_sar_srv(c_svc_area_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information241   svc_area_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_SVC_AREA_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_svc_area_rt_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_SVC_AREA_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_TBCO_USE_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_tur_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  tbco_use_rt_id
   from BEN_TBCO_USE_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_tur(c_tbco_use_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  tur.*
   from BEN_TBCO_USE_RT_F tur
   where  tur.tbco_use_rt_id = c_tbco_use_rt_id
     -- and tur.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_TBCO_USE_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_tbco_use_rt_id
         -- and information4 = tur.business_group_id
           and information2 = tur.effective_start_date
           and information3 = tur.effective_end_date);
    l_tbco_use_rt_id                 number(15);
    l_out_tur_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_TBCO_USE_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_TTL_CVG_VOL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_tcv_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  ttl_cvg_vol_rt_id
   from BEN_TTL_CVG_VOL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_tcv(c_ttl_cvg_vol_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  tcv.*
   from BEN_TTL_CVG_VOL_RT_F tcv
   where  tcv.ttl_cvg_vol_rt_id = c_ttl_cvg_vol_rt_id
     -- and tcv.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_TTL_CVG_VOL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ttl_cvg_vol_rt_id
         -- and information4 = tcv.business_group_id
           and information2 = tcv.effective_start_date
           and information3 = tcv.effective_end_date);
    l_ttl_cvg_vol_rt_id                 number(15);
    l_out_tcv_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_TTL_CVG_VOL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_TTL_PRTT_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ttp_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  ttl_prtt_rt_id
   from BEN_TTL_PRTT_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_ttp(c_ttl_prtt_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  ttp.*
   from BEN_TTL_PRTT_RT_F ttp
   where  ttp.ttl_prtt_rt_id = c_ttl_prtt_rt_id
     -- and ttp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_TTL_PRTT_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_ttl_prtt_rt_id
         -- and information4 = ttp.business_group_id
           and information2 = ttp.effective_start_date
           and information3 = ttp.effective_end_date);
    l_ttl_prtt_rt_id                 number(15);
    l_out_ttp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_TTL_PRTT_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_VRBL_MTCHG_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_vmr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  vrbl_mtchg_rt_id
   from BEN_VRBL_MTCHG_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_vmr(c_vrbl_mtchg_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  vmr.*
   from BEN_VRBL_MTCHG_RT_F vmr
   where  vmr.vrbl_mtchg_rt_id = c_vrbl_mtchg_rt_id
     -- and vmr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_VRBL_MTCHG_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_vrbl_mtchg_rt_id
         -- and information4 = vmr.business_group_id
           and information2 = vmr.effective_start_date
           and information3 = vmr.effective_end_date);
    l_vrbl_mtchg_rt_id                 number(15);
    l_out_vmr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_VRBL_MTCHG_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_VRBL_RT_PRFL_RL_F ----------------------
   ---------------------------------------------------------------
   cursor c_vpr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  vrbl_rt_prfl_rl_id
   from BEN_VRBL_RT_PRFL_RL_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_vpr(c_vrbl_rt_prfl_rl_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  vpr.*
   from BEN_VRBL_RT_PRFL_RL_F vpr
   where  vpr.vrbl_rt_prfl_rl_id = c_vrbl_rt_prfl_rl_id
     -- and vpr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_VRBL_RT_PRFL_RL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_vrbl_rt_prfl_rl_id
         -- and information4 = vpr.business_group_id
           and information2 = vpr.effective_start_date
           and information3 = vpr.effective_end_date);
    l_vrbl_rt_prfl_rl_id                 number(15);
    l_out_vpr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_VRBL_RT_PRFL_RL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_WK_LOC_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_wlr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  wk_loc_rt_id
   from BEN_WK_LOC_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_wlr(c_wk_loc_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  wlr.*
   from BEN_WK_LOC_RT_F wlr
   where  wlr.wk_loc_rt_id = c_wk_loc_rt_id
     -- and wlr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_WK_LOC_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_wk_loc_rt_id
         -- and information4 = wlr.business_group_id
           and information2 = wlr.effective_start_date
           and information3 = wlr.effective_end_date);
    l_wk_loc_rt_id                 number(15);
    l_out_wlr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name10(p_id in number,p_date in date) is
      select loc.location_code dsp_location_code
      from hr_locations loc
      where loc.location_id = p_id
        and p_date <= nvl( loc.inactive_date, p_date);

    cursor c_location_inactive_date(c_location_id number) is
    select inactive_date
    from hr_locations
    where location_id = c_location_id;

    l_location_inactive_date hr_locations.inactive_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_WK_LOC_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_COMPTNCY_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_cty_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  comptncy_rt_id
   from BEN_COMPTNCY_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_cty(c_comptncy_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  cty.*
   from BEN_COMPTNCY_RT_F cty
   where  cty.comptncy_rt_id = c_comptncy_rt_id
     -- and cty.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_COMPTNCY_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_comptncy_rt_id
         -- and information4 = cty.business_group_id
           and information2 = cty.effective_start_date
           and information3 = cty.effective_end_date);
    l_comptncy_rt_id                 number(15);
    l_out_cty_result_id   number(15);
    --
    cursor c_get_mapping_name16(p_COMPETENCE_ID number,p_date date) is
    select name
      from per_competences_vl
     where COMPETENCE_ID = p_COMPETENCE_ID
       and p_date
           between  Date_from  and nvl(Date_to, p_date);
    --
    cursor c_get_mapping_name17(p_rating_level_id number,
                                p_business_group_id number
                               ) is
     select rtl.name name
     from per_rating_levels_vl rtl
     where nvl(rtl.business_group_id, p_business_group_id) = p_business_group_id     and   rtl.rating_level_id = p_rating_level_id;
   --
   cursor c_competence_start_date(c_competence_id number) is
   select date_from
   from per_competences
   where competence_id = c_competence_id;

   l_competence_start_date  per_competences.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_COMPTNCY_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_JOB_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_jrt_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  job_rt_id
   from BEN_JOB_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_jrt(c_job_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  jrt.*
   from BEN_JOB_RT_F jrt
   where  jrt.job_rt_id = c_job_rt_id
     -- and jrt.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_JOB_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_job_rt_id
         -- and information4 = jrt.business_group_id
           and information2 = jrt.effective_start_date
           and information3 = jrt.effective_end_date);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name11(p_id in number,p_date in date) is
      select name
      from per_jobs_vl
      where business_group_id = p_business_group_id
        and job_id = p_id
        and p_date between date_from and nvl(date_to,p_date);

    --
    --

     cursor c_job_start_date(c_job_id number) is
     select date_from
     from per_jobs
     where job_id = c_job_id;

    l_job_rt_id                 number(15);
    l_out_jrt_result_id   number(15);
    l_job_start_date      per_jobs.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_JOB_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PSTN_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pst_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  pstn_rt_id
   from BEN_PSTN_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pst(c_pstn_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  pst.*
   from BEN_PSTN_RT_F pst
   where  pst.pstn_rt_id = c_pstn_rt_id
     -- and pst.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PSTN_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pstn_rt_id
         -- and information4 = pst.business_group_id
           and information2 = pst.effective_start_date
           and information3 = pst.effective_end_date);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name14(p_id in number) is
       select name
       from per_positions
       where business_group_id = p_business_group_id
         and position_id = p_id;

     cursor c_position_start_date(c_position_id number) is
     select date_effective
     from per_positions
     where position_id = c_position_id;

    l_pstn_rt_id                 number(15);
    l_out_pst_result_id   number(15);
    l_position_start_date per_positions.date_effective%type;
   ---------------------------------------------------------------
   -- END OF BEN_PSTN_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_QUAL_TITL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_qtr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  qual_titl_rt_id
   from BEN_QUAL_TITL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_qtr(c_qual_titl_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  qtr.*
   from BEN_QUAL_TITL_RT_F qtr
   where  qtr.qual_titl_rt_id = c_qual_titl_rt_id
     --and qtr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_QUAL_TITL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_qual_titl_rt_id
         -- and information4 = qtr.business_group_id
           and information2 = qtr.effective_start_date
           and information3 = qtr.effective_end_date);
   --
   -- pabodla : mapping data
   --
   cursor c_get_mapping_name15(p_id in number) is
      select name
      from per_qualification_types_vl
      where qualification_type_id  = p_id;

    l_qual_titl_rt_id                 number(15);
    l_out_qtr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_QUAL_TITL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CBR_QUALD_BNF_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_cqr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  cbr_quald_bnf_rt_id
   from BEN_CBR_QUALD_BNF_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_cqr(c_cbr_quald_bnf_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  cqr.*
   from BEN_CBR_QUALD_BNF_RT_F cqr
   where  cqr.cbr_quald_bnf_rt_id = c_cbr_quald_bnf_rt_id
     --and cqr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CBR_QUALD_BNF_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_cbr_quald_bnf_rt_id
         -- and information4 = cqr.business_group_id
           and information2 = cqr.effective_start_date
           and information3 = cqr.effective_end_date);
    l_cbr_quald_bnf_rt_id                 number(15);
    l_out_cqr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CBR_QUALD_BNF_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CNTNG_PRTN_PRFL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_cpn_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  cntng_prtn_prfl_rt_id
   from BEN_CNTNG_PRTN_PRFL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_cpn(c_cntng_prtn_prfl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  cpn.*
   from BEN_CNTNG_PRTN_PRFL_RT_F cpn
   where  cpn.cntng_prtn_prfl_rt_id = c_cntng_prtn_prfl_rt_id
     --and cpn.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CNTNG_PRTN_PRFL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_cntng_prtn_prfl_rt_id
         -- and information4 = cpn.business_group_id
           and information2 = cpn.effective_start_date
           and information3 = cpn.effective_end_date);
    l_cntng_prtn_prfl_rt_id                 number(15);
    l_out_cpn_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CNTNG_PRTN_PRFL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVRD_OTHR_PL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_dcl_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  dpnt_cvrd_othr_pl_rt_id
   from BEN_DPNT_CVRD_OTHR_PL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_dcl(c_dpnt_cvrd_othr_pl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  dcl.*
   from BEN_DPNT_CVRD_OTHR_PL_RT_F dcl
   where  dcl.dpnt_cvrd_othr_pl_rt_id = c_dpnt_cvrd_othr_pl_rt_id
     --and dcl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVRD_OTHR_PL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvrd_othr_pl_rt_id
         -- and information4 = dcl.business_group_id
           and information2 = dcl.effective_start_date
           and information3 = dcl.effective_end_date);
    l_dpnt_cvrd_othr_pl_rt_id                 number(15);
    l_out_dcl_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVRD_OTHR_PL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVRD_PLIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_dcp_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  dpnt_cvrd_plip_rt_id
   from BEN_DPNT_CVRD_PLIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_dcp(c_dpnt_cvrd_plip_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  dcp.*
   from BEN_DPNT_CVRD_PLIP_RT_F dcp
   where  dcp.dpnt_cvrd_plip_rt_id = c_dpnt_cvrd_plip_rt_id
     --and dcp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVRD_PLIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvrd_plip_rt_id
         -- and information4 = dcp.business_group_id
           and information2 = dcp.effective_start_date
           and information3 = dcp.effective_end_date);
    l_dpnt_cvrd_plip_rt_id                 number(15);
    l_out_dcp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVRD_PLIP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVRD_OTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_dco_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  dpnt_cvrd_othr_ptip_rt_id
   from BEN_DPNT_CVRD_OTHR_PTIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_dco(c_dpnt_cvrd_othr_ptip_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  dco.*
   from BEN_DPNT_CVRD_OTHR_PTIP_RT_F dco
   where  dco.dpnt_cvrd_othr_ptip_rt_id = c_dpnt_cvrd_othr_ptip_rt_id
     --and dco.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVRD_OTHR_PTIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvrd_othr_ptip_rt_id
         -- and information4 = dco.business_group_id
           and information2 = dco.effective_start_date
           and information3 = dco.effective_end_date);
    l_dpnt_cvrd_othr_ptip_rt_id                 number(15);
    l_out_dco_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVRD_OTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVRD_OTHR_PGM_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_dop_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  dpnt_cvrd_othr_pgm_rt_id
   from BEN_DPNT_CVRD_OTHR_PGM_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_dop(c_dpnt_cvrd_othr_pgm_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  dop.*
   from BEN_DPNT_CVRD_OTHR_PGM_RT_F dop
   where  dop.dpnt_cvrd_othr_pgm_rt_id = c_dpnt_cvrd_othr_pgm_rt_id
     --and dop.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVRD_OTHR_PGM_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvrd_othr_pgm_rt_id
         -- and information4 = dop.business_group_id
           and information2 = dop.effective_start_date
           and information3 = dop.effective_end_date);
    l_dpnt_cvrd_othr_pgm_rt_id                 number(15);
    l_out_dop_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVRD_OTHR_PGM_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PRTT_ANTHR_PL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_pap_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  prtt_anthr_pl_rt_id
   from BEN_PRTT_ANTHR_PL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_pap(c_prtt_anthr_pl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  pap.*
   from BEN_PRTT_ANTHR_PL_RT_F pap
   where  pap.prtt_anthr_pl_rt_id = c_prtt_anthr_pl_rt_id
     --and pap.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PRTT_ANTHR_PL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_prtt_anthr_pl_rt_id
         -- and information4 = pap.business_group_id
           and information2 = pap.effective_start_date
           and information3 = pap.effective_end_date);
    l_prtt_anthr_pl_rt_id                 number(15);
    l_out_pap_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PRTT_ANTHR_PL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ENRLD_ANTHR_OIPL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_eao_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  enrld_anthr_oipl_rt_id
   from BEN_ENRLD_ANTHR_OIPL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_eao(c_enrld_anthr_oipl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  eao.*
   from BEN_ENRLD_ANTHR_OIPL_RT_F eao
   where  eao.enrld_anthr_oipl_rt_id = c_enrld_anthr_oipl_rt_id
     --and eao.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ENRLD_ANTHR_OIPL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_enrld_anthr_oipl_rt_id
         -- and information4 = eao.business_group_id
           and information2 = eao.effective_start_date
           and information3 = eao.effective_end_date);
    l_enrld_anthr_oipl_rt_id                 number(15);
    l_out_eao_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ENRLD_ANTHR_OIPL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ENRLD_ANTHR_PL_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_enl_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  enrld_anthr_pl_rt_id
   from BEN_ENRLD_ANTHR_PL_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_enl(c_enrld_anthr_pl_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  enl.*
   from BEN_ENRLD_ANTHR_PL_RT_F enl
   where  enl.enrld_anthr_pl_rt_id = c_enrld_anthr_pl_rt_id
     --and enl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ENRLD_ANTHR_PL_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_enrld_anthr_pl_rt_id
         -- and information4 = enl.business_group_id
           and information2 = enl.effective_start_date
           and information3 = enl.effective_end_date);
    l_enrld_anthr_pl_rt_id                 number(15);
    l_out_enl_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ENRLD_ANTHR_PL_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ENRLD_ANTHR_PLIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ear_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  enrld_anthr_plip_rt_id
   from BEN_ENRLD_ANTHR_PLIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_ear(c_enrld_anthr_plip_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  ear.*
   from BEN_ENRLD_ANTHR_PLIP_RT_F ear
   where  ear.enrld_anthr_plip_rt_id = c_enrld_anthr_plip_rt_id
     --and ear.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ENRLD_ANTHR_PLIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_enrld_anthr_plip_rt_id
         -- and information4 = ear.business_group_id
           and information2 = ear.effective_start_date
           and information3 = ear.effective_end_date);
    l_enrld_anthr_plip_rt_id                 number(15);
    l_out_ear_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ENRLD_ANTHR_PLIP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ENRLD_ANTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_ent_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  enrld_anthr_ptip_rt_id
   from BEN_ENRLD_ANTHR_PTIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_ent(c_enrld_anthr_ptip_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  ent.*
   from BEN_ENRLD_ANTHR_PTIP_RT_F ent
   where  ent.enrld_anthr_ptip_rt_id = c_enrld_anthr_ptip_rt_id
     --and ent.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ENRLD_ANTHR_PTIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_enrld_anthr_ptip_rt_id
         -- and information4 = ent.business_group_id
           and information2 = ent.effective_start_date
           and information3 = ent.effective_end_date);
    l_enrld_anthr_ptip_rt_id                 number(15);
    l_out_ent_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ENRLD_ANTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ENRLD_ANTHR_PGM_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_epm_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  enrld_anthr_pgm_rt_id
   from BEN_ENRLD_ANTHR_PGM_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_epm(c_enrld_anthr_pgm_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  epm.*
   from BEN_ENRLD_ANTHR_PGM_RT_F epm
   where  epm.enrld_anthr_pgm_rt_id = c_enrld_anthr_pgm_rt_id
     --and epm.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ENRLD_ANTHR_PGM_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_enrld_anthr_pgm_rt_id
         -- and information4 = epm.business_group_id
           and information2 = epm.effective_start_date
           and information3 = epm.effective_end_date);
    l_enrld_anthr_pgm_rt_id                 number(15);
    l_out_epm_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ENRLD_ANTHR_PGM_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_NO_OTHR_CVG_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_noc_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  no_othr_cvg_rt_id
   from BEN_NO_OTHR_CVG_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_noc(c_no_othr_cvg_rt_id number,c_mirror_src_entity_result_id number,                c_table_alias varchar2 ) is
   select  noc.*
   from BEN_NO_OTHR_CVG_RT_F noc
   where  noc.no_othr_cvg_rt_id = c_no_othr_cvg_rt_id
     --and noc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_NO_OTHR_CVG_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_no_othr_cvg_rt_id
         -- and information4 = noc.business_group_id
           and information2 = noc.effective_start_date
           and information3 = noc.effective_end_date);
    l_no_othr_cvg_rt_id                 number(15);
    l_out_noc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_NO_OTHR_CVG_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_OPTD_MDCR_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_omr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  optd_mdcr_rt_id
   from BEN_OPTD_MDCR_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_omr(c_optd_mdcr_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  omr.*
   from BEN_OPTD_MDCR_RT_F omr
   where  omr.optd_mdcr_rt_id = c_optd_mdcr_rt_id
     --and omr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_OPTD_MDCR_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_optd_mdcr_rt_id
         -- and information4 = omr.business_group_id
           and information2 = omr.effective_start_date
           and information3 = omr.effective_end_date);
    l_optd_mdcr_rt_id                 number(15);
    l_out_omr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_OPTD_MDCR_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_OTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_dot_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  dpnt_othr_ptip_rt_id
   from BEN_DPNT_OTHR_PTIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_dot(c_dpnt_othr_ptip_rt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  dot.*
   from BEN_DPNT_OTHR_PTIP_RT_F dot
   where  dot.dpnt_othr_ptip_rt_id = c_dpnt_othr_ptip_rt_id
     --and dot.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_OTHR_PTIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_othr_ptip_rt_id
         -- and information4 = dot.business_group_id
           and information2 = dot.effective_start_date
           and information3 = dot.effective_end_date);
    l_dpnt_othr_ptip_rt_id                 number(15);
    l_out_dot_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_OTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_PERF_RTNG_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_prr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  perf_rtng_rt_id
   from BEN_PERF_RTNG_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_prr(c_perf_rtng_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  prr.*
   from BEN_PERF_RTNG_RT_F prr
   where  prr.perf_rtng_rt_id = c_perf_rtng_rt_id
     --and prr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PERF_RTNG_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_perf_rtng_rt_id
         -- and information4 = prr.business_group_id
           and information2 = prr.effective_start_date
           and information3 = prr.effective_end_date);
    l_perf_rtng_rt_id                 number(15);
    l_out_prr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PERF_RTNG_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_QUA_IN_GR_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_qig_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  qua_in_gr_rt_id
   from BEN_QUA_IN_GR_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_qig(c_qua_in_gr_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  qig.*
   from BEN_QUA_IN_GR_RT_F qig
   where  qig.qua_in_gr_rt_id = c_qua_in_gr_rt_id
     --and qig.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_QUA_IN_GR_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_qua_in_gr_rt_id
         -- and information4 = qig.business_group_id
           and information2 = qig.effective_start_date
           and information3 = qig.effective_end_date);
    l_qua_in_gr_rt_id                 number(15);
    l_out_qig_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_QUA_IN_GR_RT_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_OTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------
   cursor c_opr_from_parent(c_VRBL_RT_PRFL_ID number) is
   select  othr_ptip_rt_id
   from BEN_OTHR_PTIP_RT_F
   where  VRBL_RT_PRFL_ID = c_VRBL_RT_PRFL_ID ;
   --
   cursor c_opr(c_othr_ptip_rt_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  opr.*
   from BEN_OTHR_PTIP_RT_F opr
   where  opr.othr_ptip_rt_id = c_othr_ptip_rt_id
     --and opr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_OTHR_PTIP_RT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_othr_ptip_rt_id
         -- and information4 = opr.business_group_id
           and information2 = opr.effective_start_date
           and information3 = opr.effective_end_date);
    l_othr_ptip_rt_id                 number(15);
    l_out_opr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_OTHR_PTIP_RT_F ----------------------
   ---------------------------------------------------------------

   cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
         -- pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
    -- and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);
  begin

     if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
     end if;

     if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       open c_object_exists(p_vrbl_rt_prfl_id,'VPF');
       fetch c_object_exists into l_dummy;
       if c_object_exists%found then
         close c_object_exists;
         return;
       end if;
       close c_object_exists;
     end if;

     l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_VRBL_RT_PRFL_F ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        l_vrbl_rt_prfl_id := p_vrbl_rt_prfl_id ;
        --
        hr_utility.set_location('l_vrbl_rt_prfl_id'||l_vrbl_rt_prfl_id,100);
        for l_vpf_rec in c_vpf(l_vrbl_rt_prfl_id,l_mirror_src_entity_result_id,'VPF') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('VPF');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_vpf_rec.name; --'Intersection';
          --
          if p_effective_date between l_vpf_rec.effective_start_date
             and l_vpf_rec.effective_end_date then
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
            p_parent_entity_result_id        => p_parent_entity_result_id, -- To hide intermediate level in Hgrid
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'VPF',
            p_information1     => l_vpf_rec.vrbl_rt_prfl_id,
            p_information2     => l_vpf_rec.EFFECTIVE_START_DATE,
            p_information3     => l_vpf_rec.EFFECTIVE_END_DATE,
            p_information4     => l_vpf_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information67     => l_vpf_rec.acty_ref_perd_cd,
            p_information72     => l_vpf_rec.acty_typ_cd,
            p_information76     => l_vpf_rec.alwys_cnt_all_prtts_flag,
            p_information75     => l_vpf_rec.alwys_sum_all_cvg_flag,
            p_information297     => l_vpf_rec.ann_mn_elcn_val,
            p_information298     => l_vpf_rec.ann_mx_elcn_val,
            p_information71     => l_vpf_rec.asmt_to_use_cd,
            p_information74     => l_vpf_rec.bnft_rt_typ_cd,
            p_information254     => l_vpf_rec.comp_lvl_fctr_id,
            p_information300     => l_vpf_rec.dflt_elcn_val,
            p_information299     => l_vpf_rec.incrmnt_elcn_val,
            p_information260     => l_vpf_rec.lwr_lmt_calc_rl,
            p_information295     => l_vpf_rec.lwr_lmt_val,
            p_information68     => l_vpf_rec.mlt_cd,
            p_information302     => l_vpf_rec.mn_elcn_val,
            p_information301     => l_vpf_rec.mx_elcn_val,
            p_information170     => l_vpf_rec.name,
            p_information69     => l_vpf_rec.no_mn_elcn_val_dfnd_flag,
            p_information70     => l_vpf_rec.no_mx_elcn_val_dfnd_flag,
            p_information258     => l_vpf_rec.oipl_id,
            p_information261     => l_vpf_rec.pl_id,
            p_information228     => l_vpf_rec.pl_typ_opt_typ_id,
            p_information79     => l_vpf_rec.rndg_cd,
            p_information269     => l_vpf_rec.rndg_rl,
            p_information38     => l_vpf_rec.rt_age_flag,
            p_information45     => l_vpf_rec.rt_asnt_set_flag,
            p_information35     => l_vpf_rec.rt_benfts_grp_flag,
            p_information37     => l_vpf_rec.rt_brgng_unit_flag,
            p_information24     => l_vpf_rec.rt_cbr_quald_bnf_flag,
            p_information54     => l_vpf_rec.rt_cmbn_age_los_flag,
            p_information23     => l_vpf_rec.rt_cntng_prtn_prfl_flag,
            p_information47     => l_vpf_rec.rt_comp_lvl_flag,
            p_information25     => l_vpf_rec.rt_comptncy_flag,
            p_information11     => l_vpf_rec.rt_dpnt_cvrd_pgm_flag,
            p_information82     => l_vpf_rec.rt_dpnt_cvrd_pl_flag,
            p_information29     => l_vpf_rec.rt_dpnt_cvrd_plip_flag,
            p_information30     => l_vpf_rec.rt_dpnt_cvrd_ptip_flag,
            p_information20     => l_vpf_rec.rt_dpnt_othr_ptip_flag,
            p_information58     => l_vpf_rec.rt_dsbld_flag,
            p_information42     => l_vpf_rec.rt_ee_stat_flag,
            p_information12     => l_vpf_rec.rt_enrld_oipl_flag,
            p_information16     => l_vpf_rec.rt_enrld_pgm_flag,
            p_information13     => l_vpf_rec.rt_enrld_pl_flag,
            p_information14     => l_vpf_rec.rt_enrld_plip_flag,
            p_information15     => l_vpf_rec.rt_enrld_ptip_flag,
            p_information41     => l_vpf_rec.rt_fl_tm_pt_tm_flag,
            p_information63     => l_vpf_rec.rt_gndr_flag,
            p_information43     => l_vpf_rec.rt_grd_flag,
            p_information59     => l_vpf_rec.rt_hlth_cvg_flag,
            p_information31     => l_vpf_rec.rt_hrly_slrd_flag,
            p_information46     => l_vpf_rec.rt_hrs_wkd_flag,
            p_information80     => l_vpf_rec.rt_job_flag,
            p_information33     => l_vpf_rec.rt_lbr_mmbr_flag,
            p_information34     => l_vpf_rec.rt_lgl_enty_flag,
            p_information49     => l_vpf_rec.rt_loa_rsn_flag,
            p_information39     => l_vpf_rec.rt_los_flag,
            p_information27     => l_vpf_rec.rt_lvg_rsn_flag,
            p_information19     => l_vpf_rec.rt_no_othr_cvg_flag,
            p_information26     => l_vpf_rec.rt_optd_mdcr_flag,
            p_information48     => l_vpf_rec.rt_org_unit_flag,
            p_information18     => l_vpf_rec.rt_othr_ptip_flag,
            p_information44     => l_vpf_rec.rt_pct_fl_tm_flag,
            p_information40     => l_vpf_rec.rt_per_typ_flag,
            p_information21     => l_vpf_rec.rt_perf_rtng_flag,
            p_information60     => l_vpf_rec.rt_poe_flag,
            p_information57     => l_vpf_rec.rt_ppl_grp_flag,
            p_information53     => l_vpf_rec.rt_prfl_rl_flag,
            p_information17     => l_vpf_rec.rt_prtt_anthr_pl_flag,
            p_information55     => l_vpf_rec.rt_prtt_pl_flag,
            p_information32     => l_vpf_rec.rt_pstl_cd_flag,
            p_information28     => l_vpf_rec.rt_pstn_flag,
            p_information52     => l_vpf_rec.rt_py_bss_flag,
            p_information50     => l_vpf_rec.rt_pyrl_flag,
            p_information22     => l_vpf_rec.rt_qua_in_gr_flag,
            p_information81     => l_vpf_rec.rt_qual_titl_flag,
            p_information51     => l_vpf_rec.rt_schedd_hrs_flag,
            p_information56     => l_vpf_rec.rt_svc_area_flag,
            p_information64     => l_vpf_rec.rt_tbco_use_flag,
            p_information61     => l_vpf_rec.rt_ttl_cvg_vol_flag,
            p_information62     => l_vpf_rec.rt_ttl_prtt_flag,
            p_information73     => l_vpf_rec.rt_typ_cd,
            p_information36     => l_vpf_rec.rt_wk_loc_flag,
            p_information65     => l_vpf_rec.tx_typ_cd,
            p_information293     => l_vpf_rec.ultmt_lwr_lmt,
            p_information259     => l_vpf_rec.ultmt_lwr_lmt_calc_rl,
            p_information294     => l_vpf_rec.ultmt_upr_lmt,
            p_information257     => l_vpf_rec.ultmt_upr_lmt_calc_rl,
            p_information263     => l_vpf_rec.upr_lmt_calc_rl,
            p_information296     => l_vpf_rec.upr_lmt_val,
            p_information303     => l_vpf_rec.val,
            p_information268     => l_vpf_rec.val_calc_rl,
            p_information111     => l_vpf_rec.vpf_attribute1,
            p_information120     => l_vpf_rec.vpf_attribute10,
            p_information121     => l_vpf_rec.vpf_attribute11,
            p_information122     => l_vpf_rec.vpf_attribute12,
            p_information123     => l_vpf_rec.vpf_attribute13,
            p_information124     => l_vpf_rec.vpf_attribute14,
            p_information125     => l_vpf_rec.vpf_attribute15,
            p_information126     => l_vpf_rec.vpf_attribute16,
            p_information127     => l_vpf_rec.vpf_attribute17,
            p_information128     => l_vpf_rec.vpf_attribute18,
            p_information129     => l_vpf_rec.vpf_attribute19,
            p_information112     => l_vpf_rec.vpf_attribute2,
            p_information130     => l_vpf_rec.vpf_attribute20,
            p_information131     => l_vpf_rec.vpf_attribute21,
            p_information132     => l_vpf_rec.vpf_attribute22,
            p_information133     => l_vpf_rec.vpf_attribute23,
            p_information134     => l_vpf_rec.vpf_attribute24,
            p_information135     => l_vpf_rec.vpf_attribute25,
            p_information136     => l_vpf_rec.vpf_attribute26,
            p_information137     => l_vpf_rec.vpf_attribute27,
            p_information138     => l_vpf_rec.vpf_attribute28,
            p_information139     => l_vpf_rec.vpf_attribute29,
            p_information113     => l_vpf_rec.vpf_attribute3,
            p_information140     => l_vpf_rec.vpf_attribute30,
            p_information114     => l_vpf_rec.vpf_attribute4,
            p_information115     => l_vpf_rec.vpf_attribute5,
            p_information116     => l_vpf_rec.vpf_attribute6,
            p_information117     => l_vpf_rec.vpf_attribute7,
            p_information118     => l_vpf_rec.vpf_attribute8,
            p_information119     => l_vpf_rec.vpf_attribute9,
            p_information110     => l_vpf_rec.vpf_attribute_category,
            p_information77     => l_vpf_rec.vrbl_rt_prfl_stat_cd,
            p_information66     => l_vpf_rec.vrbl_rt_trtmt_cd,
            p_information78     => l_vpf_rec.vrbl_usg_cd,
            p_information83     => l_vpf_rec.rt_elig_prfl_flag,
            p_information265    => l_vpf_rec.object_version_number,
           --

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_vpf_result_id is null then
              l_out_vpf_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_vpf_result_id := l_copy_entity_result_id ;
            end if;
            --

            -- Copy Fast Formulas if any are attached to any column --
            ---------------------------------------------------------------
            -- LWR_LMT_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.lwr_lmt_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_vpf_rec.lwr_lmt_calc_rl
                ,p_business_group_id              =>  l_vpf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- RNDG_RL -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.rndg_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_vpf_rec.rndg_rl
                ,p_business_group_id              =>  l_vpf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- ULTMT_LWR_LMT_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.ultmt_lwr_lmt_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_vpf_rec.ultmt_lwr_lmt_calc_rl
                ,p_business_group_id              =>  l_vpf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- ULTMT_UPR_LMT_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.ultmt_upr_lmt_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_vpf_rec.ultmt_upr_lmt_calc_rl
                ,p_business_group_id              =>  l_vpf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            -- UPR_LMT_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.upr_lmt_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_vpf_rec.upr_lmt_calc_rl
                ,p_business_group_id              =>  l_vpf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;


            ---------------------------------------------------------------
            -- VAL_CALC_RL -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.val_calc_rl is not null then
                --
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  0
                ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  l_vpf_rec.val_calc_rl
                ,p_business_group_id              =>  l_vpf_rec.business_group_id
                ,p_number_of_copies               =>  l_number_of_copies
                ,p_object_version_number          =>  l_object_version_number
                ,p_effective_date                 =>  p_effective_date
                );

                --
            end if;

            ---------------------------------------------------------------
            --  COMP_LVL_FCTR -----------------
            ---------------------------------------------------------------

            if l_vpf_rec.comp_lvl_fctr_id is not null then
            --
                create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_vpf_rec.comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
            --
            end if;

         end loop;
         --

         -- Create Variable Rate Eligibility Profile results
         create_vrb_rt_elg_prf_results
         (
           p_validate                       =>  p_validate
          ,p_copy_entity_result_id          =>  l_out_vpf_result_id
          ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
          ,p_vrbl_rt_prfl_id                =>  l_vrbl_rt_prfl_id
          ,p_business_group_id              =>  p_business_group_id
          ,p_number_of_copies               =>  p_number_of_copies
          ,p_object_version_number          =>  l_object_version_number
          ,p_effective_date                 =>  p_effective_date
         );

         --
         ---------------------------------------------------------------
         -- START OF BEN_AGE_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_art_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_age_rt_id := l_parent_rec.age_rt_id ;
            --
            for l_art_rec in c_art(l_parent_rec.age_rt_id,l_mirror_src_entity_result_id,'ART') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('ART');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_age_fctr_name(l_art_rec.age_fctr_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_art_rec.excld_flag);
                                  --'Intersection';
              --
              if p_effective_date between l_art_rec.effective_start_date
                 and l_art_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'ART',
                p_information1     => l_art_rec.age_rt_id,
                p_information2     => l_art_rec.EFFECTIVE_START_DATE,
                p_information3     => l_art_rec.EFFECTIVE_END_DATE,
                p_information4     => l_art_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information246     => l_art_rec.age_fctr_id,
            p_information111     => l_art_rec.art_attribute1,
            p_information120     => l_art_rec.art_attribute10,
            p_information121     => l_art_rec.art_attribute11,
            p_information122     => l_art_rec.art_attribute12,
            p_information123     => l_art_rec.art_attribute13,
            p_information124     => l_art_rec.art_attribute14,
            p_information125     => l_art_rec.art_attribute15,
            p_information126     => l_art_rec.art_attribute16,
            p_information127     => l_art_rec.art_attribute17,
            p_information128     => l_art_rec.art_attribute18,
            p_information129     => l_art_rec.art_attribute19,
            p_information112     => l_art_rec.art_attribute2,
            p_information130     => l_art_rec.art_attribute20,
            p_information131     => l_art_rec.art_attribute21,
            p_information132     => l_art_rec.art_attribute22,
            p_information133     => l_art_rec.art_attribute23,
            p_information134     => l_art_rec.art_attribute24,
            p_information135     => l_art_rec.art_attribute25,
            p_information136     => l_art_rec.art_attribute26,
            p_information137     => l_art_rec.art_attribute27,
            p_information138     => l_art_rec.art_attribute28,
            p_information139     => l_art_rec.art_attribute29,
            p_information113     => l_art_rec.art_attribute3,
            p_information140     => l_art_rec.art_attribute30,
            p_information114     => l_art_rec.art_attribute4,
            p_information115     => l_art_rec.art_attribute5,
            p_information116     => l_art_rec.art_attribute6,
            p_information117     => l_art_rec.art_attribute7,
            p_information118     => l_art_rec.art_attribute8,
            p_information119     => l_art_rec.art_attribute9,
            p_information110     => l_art_rec.art_attribute_category,
            p_information11     => l_art_rec.excld_flag,
            p_information260     => l_art_rec.ordr_num,
            p_information262     => l_art_rec.vrbl_rt_prfl_id,
            p_information265     => l_art_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_art_result_id is null then
                 l_out_art_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_art_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
             for l_art_rec in c_art_drp(l_parent_rec.age_rt_id,l_mirror_src_entity_result_id,'ART') loop
               create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_out_art_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => l_art_rec.age_fctr_id
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_AGE_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_ASNT_SET_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_ASNT_SET_RT_F ',100);
         --
         for l_parent_rec  in c_asr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_asnt_set_rt_id := l_parent_rec.asnt_set_rt_id ;
            hr_utility.set_location('l_asnt_set_rt_id '||l_asnt_set_rt_id,100);
            --
            for l_asr_rec in c_asr(l_parent_rec.asnt_set_rt_id,l_mirror_src_entity_result_id,'ASR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('ASR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_assignment_set_name(l_asr_rec.assignment_set_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_asr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_asr_rec.effective_start_date
                 and l_asr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the defined balance name to display on mapping page.
              --
              open c_get_mapping_name3(l_asr_rec.assignment_set_id);
              fetch c_get_mapping_name3 into l_mapping_name;
              close c_get_mapping_name3;
              --
              l_mapping_id   := l_asr_rec.assignment_set_id;
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
              hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
              hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'ASR',
                p_information1     => l_asr_rec.asnt_set_rt_id,
                p_information2     => l_asr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_asr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_asr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information111     => l_asr_rec.asr_attribute1,
            p_information120     => l_asr_rec.asr_attribute10,
            p_information121     => l_asr_rec.asr_attribute11,
            p_information122     => l_asr_rec.asr_attribute12,
            p_information123     => l_asr_rec.asr_attribute13,
            p_information124     => l_asr_rec.asr_attribute14,
            p_information125     => l_asr_rec.asr_attribute15,
            p_information126     => l_asr_rec.asr_attribute16,
            p_information127     => l_asr_rec.asr_attribute17,
            p_information128     => l_asr_rec.asr_attribute18,
            p_information129     => l_asr_rec.asr_attribute19,
            p_information112     => l_asr_rec.asr_attribute2,
            p_information130     => l_asr_rec.asr_attribute20,
            p_information131     => l_asr_rec.asr_attribute21,
            p_information132     => l_asr_rec.asr_attribute22,
            p_information133     => l_asr_rec.asr_attribute23,
            p_information134     => l_asr_rec.asr_attribute24,
            p_information135     => l_asr_rec.asr_attribute25,
            p_information136     => l_asr_rec.asr_attribute26,
            p_information137     => l_asr_rec.asr_attribute27,
            p_information138     => l_asr_rec.asr_attribute28,
            p_information139     => l_asr_rec.asr_attribute29,
            p_information113     => l_asr_rec.asr_attribute3,
            p_information140     => l_asr_rec.asr_attribute30,
            p_information114     => l_asr_rec.asr_attribute4,
            p_information115     => l_asr_rec.asr_attribute5,
            p_information116     => l_asr_rec.asr_attribute6,
            p_information117     => l_asr_rec.asr_attribute7,
            p_information118     => l_asr_rec.asr_attribute8,
            p_information119     => l_asr_rec.asr_attribute9,
            p_information110     => l_asr_rec.asr_attribute_category,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information11     => l_asr_rec.excld_flag,
            p_information257     => l_asr_rec.ordr_num,
            p_information262     => l_asr_rec.vrbl_rt_prfl_id,
            p_information166    => NULL, -- No ESD for Assignment Set
            p_information265    => l_asr_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_asr_result_id is null then
                  l_out_asr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_asr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_ASNT_SET_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_ASNT_SET_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_BENFTS_GRP_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_brg_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_benfts_grp_rt_id := l_parent_rec.benfts_grp_rt_id ;
            --
            for l_brg_rec in c_brg(l_parent_rec.benfts_grp_rt_id,l_mirror_src_entity_result_id,'BRG') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('BRG');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_benfts_grp_name(l_brg_rec.benfts_grp_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_brg_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_brg_rec.effective_start_date
                 and l_brg_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'BRG',
                p_information1     => l_brg_rec.benfts_grp_rt_id,
                p_information2     => l_brg_rec.EFFECTIVE_START_DATE,
                p_information3     => l_brg_rec.EFFECTIVE_END_DATE,
                p_information4     => l_brg_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information222     => l_brg_rec.benfts_grp_id,
            p_information111     => l_brg_rec.brg_attribute1,
            p_information120     => l_brg_rec.brg_attribute10,
            p_information121     => l_brg_rec.brg_attribute11,
            p_information122     => l_brg_rec.brg_attribute12,
            p_information123     => l_brg_rec.brg_attribute13,
            p_information124     => l_brg_rec.brg_attribute14,
            p_information125     => l_brg_rec.brg_attribute15,
            p_information126     => l_brg_rec.brg_attribute16,
            p_information127     => l_brg_rec.brg_attribute17,
            p_information128     => l_brg_rec.brg_attribute18,
            p_information129     => l_brg_rec.brg_attribute19,
            p_information112     => l_brg_rec.brg_attribute2,
            p_information130     => l_brg_rec.brg_attribute20,
            p_information131     => l_brg_rec.brg_attribute21,
            p_information132     => l_brg_rec.brg_attribute22,
            p_information133     => l_brg_rec.brg_attribute23,
            p_information134     => l_brg_rec.brg_attribute24,
            p_information135     => l_brg_rec.brg_attribute25,
            p_information136     => l_brg_rec.brg_attribute26,
            p_information137     => l_brg_rec.brg_attribute27,
            p_information138     => l_brg_rec.brg_attribute28,
            p_information139     => l_brg_rec.brg_attribute29,
            p_information113     => l_brg_rec.brg_attribute3,
            p_information140     => l_brg_rec.brg_attribute30,
            p_information114     => l_brg_rec.brg_attribute4,
            p_information115     => l_brg_rec.brg_attribute5,
            p_information116     => l_brg_rec.brg_attribute6,
            p_information117     => l_brg_rec.brg_attribute7,
            p_information118     => l_brg_rec.brg_attribute8,
            p_information119     => l_brg_rec.brg_attribute9,
            p_information110     => l_brg_rec.brg_attribute_category,
            p_information11     => l_brg_rec.excld_flag,
            p_information257     => l_brg_rec.ordr_num,
            p_information262     => l_brg_rec.vrbl_rt_prfl_id,
            p_information265     => l_brg_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_brg_result_id is null then
                  l_out_brg_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_brg_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
             for l_brg_rec in c_brg_bg(l_parent_rec.benfts_grp_rt_id,l_mirror_src_entity_result_id,'BRG') loop
                ben_pd_rate_and_cvg_module.create_bnft_group_results
                   (
                    p_validate                     => p_validate
                   ,p_copy_entity_result_id        => l_out_brg_result_id
                   ,p_copy_entity_txn_id           => p_copy_entity_txn_id
                   ,p_benfts_grp_id                => l_brg_rec.benfts_grp_id
                   ,p_business_group_id            => p_business_group_id
                   ,p_number_of_copies             => p_number_of_copies
                   ,p_object_version_number        => l_object_version_number
                   ,p_effective_date               => p_effective_date
                   );
             end loop;
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_BENFTS_GRP_RT_F ----------------------
        ---------------------------------------------------------------

        ---------------------------------------------------------------
        -- START OF BEN_BRGNG_UNIT_RT_F ----------------------
        ---------------------------------------------------------------
        --
         for l_parent_rec  in c_bur_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_brgng_unit_rt_id := l_parent_rec.brgng_unit_rt_id ;
            --
            for l_bur_rec in c_bur(l_parent_rec.brgng_unit_rt_id,l_mirror_src_entity_result_id,'BUR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('BUR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('BARGAINING_UNIT_CODE',l_bur_rec.brgng_unit_cd)
                                 || ben_plan_design_program_module.get_exclude_message(l_bur_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_bur_rec.effective_start_date
                 and l_bur_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'BUR',
                p_information1     => l_bur_rec.brgng_unit_rt_id,
                p_information2     => l_bur_rec.EFFECTIVE_START_DATE,
                p_information3     => l_bur_rec.EFFECTIVE_END_DATE,
                p_information4     => l_bur_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_bur_rec.brgng_unit_cd,
            p_information111     => l_bur_rec.bur_attribute1,
            p_information120     => l_bur_rec.bur_attribute10,
            p_information121     => l_bur_rec.bur_attribute11,
            p_information122     => l_bur_rec.bur_attribute12,
            p_information123     => l_bur_rec.bur_attribute13,
            p_information124     => l_bur_rec.bur_attribute14,
            p_information125     => l_bur_rec.bur_attribute15,
            p_information126     => l_bur_rec.bur_attribute16,
            p_information127     => l_bur_rec.bur_attribute17,
            p_information128     => l_bur_rec.bur_attribute18,
            p_information129     => l_bur_rec.bur_attribute19,
            p_information112     => l_bur_rec.bur_attribute2,
            p_information130     => l_bur_rec.bur_attribute20,
            p_information131     => l_bur_rec.bur_attribute21,
            p_information132     => l_bur_rec.bur_attribute22,
            p_information133     => l_bur_rec.bur_attribute23,
            p_information134     => l_bur_rec.bur_attribute24,
            p_information135     => l_bur_rec.bur_attribute25,
            p_information136     => l_bur_rec.bur_attribute26,
            p_information137     => l_bur_rec.bur_attribute27,
            p_information138     => l_bur_rec.bur_attribute28,
            p_information139     => l_bur_rec.bur_attribute29,
            p_information113     => l_bur_rec.bur_attribute3,
            p_information140     => l_bur_rec.bur_attribute30,
            p_information114     => l_bur_rec.bur_attribute4,
            p_information115     => l_bur_rec.bur_attribute5,
            p_information116     => l_bur_rec.bur_attribute6,
            p_information117     => l_bur_rec.bur_attribute7,
            p_information118     => l_bur_rec.bur_attribute8,
            p_information119     => l_bur_rec.bur_attribute9,
            p_information110     => l_bur_rec.bur_attribute_category,
            p_information11     => l_bur_rec.excld_flag,
            p_information260     => l_bur_rec.ordr_num,
            p_information262     => l_bur_rec.vrbl_rt_prfl_id,
            p_information265     => l_bur_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_bur_result_id is null then
                  l_out_bur_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_bur_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_BRGNG_UNIT_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_CMBN_AGE_LOS_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_cmr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_cmbn_age_los_rt_id := l_parent_rec.cmbn_age_los_rt_id ;
            --
            for l_cmr_rec in c_cmr(l_parent_rec.cmbn_age_los_rt_id,l_mirror_src_entity_result_id,'CMR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('CMR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_cmbn_age_los_fctr_name(l_cmr_rec.cmbn_age_los_fctr_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_cmr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_cmr_rec.effective_start_date
                 and l_cmr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'CMR',
                p_information1     => l_cmr_rec.cmbn_age_los_rt_id,
                p_information2     => l_cmr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_cmr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_cmr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information223     => l_cmr_rec.cmbn_age_los_fctr_id,
            p_information111     => l_cmr_rec.cmr_attribute1,
            p_information120     => l_cmr_rec.cmr_attribute10,
            p_information121     => l_cmr_rec.cmr_attribute11,
            p_information122     => l_cmr_rec.cmr_attribute12,
            p_information123     => l_cmr_rec.cmr_attribute13,
            p_information124     => l_cmr_rec.cmr_attribute14,
            p_information125     => l_cmr_rec.cmr_attribute15,
            p_information126     => l_cmr_rec.cmr_attribute16,
            p_information127     => l_cmr_rec.cmr_attribute17,
            p_information128     => l_cmr_rec.cmr_attribute18,
            p_information129     => l_cmr_rec.cmr_attribute19,
            p_information112     => l_cmr_rec.cmr_attribute2,
            p_information130     => l_cmr_rec.cmr_attribute20,
            p_information131     => l_cmr_rec.cmr_attribute21,
            p_information132     => l_cmr_rec.cmr_attribute22,
            p_information133     => l_cmr_rec.cmr_attribute23,
            p_information134     => l_cmr_rec.cmr_attribute24,
            p_information135     => l_cmr_rec.cmr_attribute25,
            p_information136     => l_cmr_rec.cmr_attribute26,
            p_information137     => l_cmr_rec.cmr_attribute27,
            p_information138     => l_cmr_rec.cmr_attribute28,
            p_information139     => l_cmr_rec.cmr_attribute29,
            p_information113     => l_cmr_rec.cmr_attribute3,
            p_information140     => l_cmr_rec.cmr_attribute30,
            p_information114     => l_cmr_rec.cmr_attribute4,
            p_information115     => l_cmr_rec.cmr_attribute5,
            p_information116     => l_cmr_rec.cmr_attribute6,
            p_information117     => l_cmr_rec.cmr_attribute7,
            p_information118     => l_cmr_rec.cmr_attribute8,
            p_information119     => l_cmr_rec.cmr_attribute9,
            p_information110     => l_cmr_rec.cmr_attribute_category,
            p_information11     => l_cmr_rec.excld_flag,
            p_information257     => l_cmr_rec.ordr_num,
            p_information262     => l_cmr_rec.vrbl_rt_prfl_id,
            p_information265     => l_cmr_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_cmr_result_id is null then
                  l_out_cmr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_cmr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
            for l_cmr_rec in c_cmr_drp(l_parent_rec.cmbn_age_los_rt_id,l_mirror_src_entity_result_id,'CMR') loop
               create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_out_cmr_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => l_cmr_rec.cmbn_age_los_fctr_id
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
             end loop;
           end loop;
         hr_utility.set_location('END OF BEN_CMBN_AGE_LOS_RT_F',100);
        ---------------------------------------------------------------
        -- END OF BEN_CMBN_AGE_LOS_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_COMP_LVL_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_COMP_LVL_RT_F',100);
         for l_parent_rec  in c_clr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_comp_lvl_rt_id := l_parent_rec.comp_lvl_rt_id ;
            --
            hr_utility.set_location('l_comp_lvl_rt_id '||l_comp_lvl_rt_id,100);
            for l_clr_rec in c_clr(l_parent_rec.comp_lvl_rt_id,l_mirror_src_entity_result_id,'CLR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('CLR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_comp_lvl_fctr_name(l_clr_rec.comp_lvl_fctr_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_clr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_clr_rec.effective_start_date
                 and l_clr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'CLR',
                p_information1     => l_clr_rec.comp_lvl_rt_id,
                p_information2     => l_clr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_clr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_clr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information111     => l_clr_rec.clr_attribute1,
            p_information120     => l_clr_rec.clr_attribute10,
            p_information121     => l_clr_rec.clr_attribute11,
            p_information122     => l_clr_rec.clr_attribute12,
            p_information123     => l_clr_rec.clr_attribute13,
            p_information124     => l_clr_rec.clr_attribute14,
            p_information125     => l_clr_rec.clr_attribute15,
            p_information126     => l_clr_rec.clr_attribute16,
            p_information127     => l_clr_rec.clr_attribute17,
            p_information128     => l_clr_rec.clr_attribute18,
            p_information129     => l_clr_rec.clr_attribute19,
            p_information112     => l_clr_rec.clr_attribute2,
            p_information130     => l_clr_rec.clr_attribute20,
            p_information131     => l_clr_rec.clr_attribute21,
            p_information132     => l_clr_rec.clr_attribute22,
            p_information133     => l_clr_rec.clr_attribute23,
            p_information134     => l_clr_rec.clr_attribute24,
            p_information135     => l_clr_rec.clr_attribute25,
            p_information136     => l_clr_rec.clr_attribute26,
            p_information137     => l_clr_rec.clr_attribute27,
            p_information138     => l_clr_rec.clr_attribute28,
            p_information139     => l_clr_rec.clr_attribute29,
            p_information113     => l_clr_rec.clr_attribute3,
            p_information140     => l_clr_rec.clr_attribute30,
            p_information114     => l_clr_rec.clr_attribute4,
            p_information115     => l_clr_rec.clr_attribute5,
            p_information116     => l_clr_rec.clr_attribute6,
            p_information117     => l_clr_rec.clr_attribute7,
            p_information118     => l_clr_rec.clr_attribute8,
            p_information119     => l_clr_rec.clr_attribute9,
            p_information110     => l_clr_rec.clr_attribute_category,
            p_information254     => l_clr_rec.comp_lvl_fctr_id,
            p_information11     => l_clr_rec.excld_flag,
            p_information260     => l_clr_rec.ordr_num,
            p_information262     => l_clr_rec.vrbl_rt_prfl_id,
            p_information265     => l_clr_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_clr_result_id is null then
                  l_out_clr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_clr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
            hr_utility.set_location('     l_parent_rec.comp_lvl_rt_id '||l_parent_rec.comp_lvl_rt_id,100);
            for l_clr_rec in c_clr_drp(l_parent_rec.comp_lvl_rt_id,l_mirror_src_entity_result_id,'CLR') loop
               create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_out_clr_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_clr_rec.comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
             end loop;
           end loop;
         hr_utility.set_location('END OF BEN_COMP_LVL_RT_F',100);
        ---------------------------------------------------------------
        -- END OF BEN_COMP_LVL_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_DSBLD_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_dbr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_dsbld_rt_id := l_parent_rec.dsbld_rt_id ;
            --
            for l_dbr_rec in c_dbr(l_parent_rec.dsbld_rt_id,l_mirror_src_entity_result_id,'DBR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('DBR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('REGISTERED_DISABLED',l_dbr_rec.dsbld_cd)
                                 || ben_plan_design_program_module.get_exclude_message(l_dbr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_dbr_rec.effective_start_date
                 and l_dbr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'DBR',
                p_information1     => l_dbr_rec.dsbld_rt_id,
                p_information2     => l_dbr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_dbr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_dbr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information111     => l_dbr_rec.dbr_attribute1,
            p_information120     => l_dbr_rec.dbr_attribute10,
            p_information121     => l_dbr_rec.dbr_attribute11,
            p_information122     => l_dbr_rec.dbr_attribute12,
            p_information123     => l_dbr_rec.dbr_attribute13,
            p_information124     => l_dbr_rec.dbr_attribute14,
            p_information125     => l_dbr_rec.dbr_attribute15,
            p_information126     => l_dbr_rec.dbr_attribute16,
            p_information127     => l_dbr_rec.dbr_attribute17,
            p_information128     => l_dbr_rec.dbr_attribute18,
            p_information129     => l_dbr_rec.dbr_attribute19,
            p_information112     => l_dbr_rec.dbr_attribute2,
            p_information130     => l_dbr_rec.dbr_attribute20,
            p_information131     => l_dbr_rec.dbr_attribute21,
            p_information132     => l_dbr_rec.dbr_attribute22,
            p_information133     => l_dbr_rec.dbr_attribute23,
            p_information134     => l_dbr_rec.dbr_attribute24,
            p_information135     => l_dbr_rec.dbr_attribute25,
            p_information136     => l_dbr_rec.dbr_attribute26,
            p_information137     => l_dbr_rec.dbr_attribute27,
            p_information138     => l_dbr_rec.dbr_attribute28,
            p_information139     => l_dbr_rec.dbr_attribute29,
            p_information113     => l_dbr_rec.dbr_attribute3,
            p_information140     => l_dbr_rec.dbr_attribute30,
            p_information114     => l_dbr_rec.dbr_attribute4,
            p_information115     => l_dbr_rec.dbr_attribute5,
            p_information116     => l_dbr_rec.dbr_attribute6,
            p_information117     => l_dbr_rec.dbr_attribute7,
            p_information118     => l_dbr_rec.dbr_attribute8,
            p_information119     => l_dbr_rec.dbr_attribute9,
            p_information110     => l_dbr_rec.dbr_attribute_category,
            p_information11     => l_dbr_rec.dsbld_cd,
            p_information12     => l_dbr_rec.excld_flag,
            p_information260     => l_dbr_rec.ordr_num,
            p_information262     => l_dbr_rec.vrbl_rt_prfl_id,
            p_information265     => l_dbr_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_dbr_result_id is null then
                  l_out_dbr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_dbr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_DSBLD_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_EE_STAT_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_EE_STAT_RT_F',100);
         for l_parent_rec  in c_esr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_ee_stat_rt_id := l_parent_rec.ee_stat_rt_id ;
            --
            for l_esr_rec in c_esr(l_parent_rec.ee_stat_rt_id,l_mirror_src_entity_result_id,'ESR') loop
              --
              hr_utility.set_location('l_parent_rec.ee_stat_rt_id '||l_parent_rec.ee_stat_rt_id,100);
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('ESR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_assignment_sts_type_name(l_esr_rec.assignment_status_type_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_esr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_esr_rec.effective_start_date
                 and l_esr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;

              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the defined balance name to display on mapping page.
              --
              open c_get_mapping_name4(l_esr_rec.assignment_status_type_id);
              fetch c_get_mapping_name4 into l_mapping_name;
              close c_get_mapping_name4;
              --
              l_mapping_id   := l_esr_rec.assignment_status_type_id;
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
              hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
              hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
              --
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'ESR',
                p_information1     => l_esr_rec.ee_stat_rt_id,
                p_information2     => l_esr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_esr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_esr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_esr_rec.esr_attribute1,
            p_information120     => l_esr_rec.esr_attribute10,
            p_information121     => l_esr_rec.esr_attribute11,
            p_information122     => l_esr_rec.esr_attribute12,
            p_information123     => l_esr_rec.esr_attribute13,
            p_information124     => l_esr_rec.esr_attribute14,
            p_information125     => l_esr_rec.esr_attribute15,
            p_information126     => l_esr_rec.esr_attribute16,
            p_information127     => l_esr_rec.esr_attribute17,
            p_information128     => l_esr_rec.esr_attribute18,
            p_information129     => l_esr_rec.esr_attribute19,
            p_information112     => l_esr_rec.esr_attribute2,
            p_information130     => l_esr_rec.esr_attribute20,
            p_information131     => l_esr_rec.esr_attribute21,
            p_information132     => l_esr_rec.esr_attribute22,
            p_information133     => l_esr_rec.esr_attribute23,
            p_information134     => l_esr_rec.esr_attribute24,
            p_information135     => l_esr_rec.esr_attribute25,
            p_information136     => l_esr_rec.esr_attribute26,
            p_information137     => l_esr_rec.esr_attribute27,
            p_information138     => l_esr_rec.esr_attribute28,
            p_information139     => l_esr_rec.esr_attribute29,
            p_information113     => l_esr_rec.esr_attribute3,
            p_information140     => l_esr_rec.esr_attribute30,
            p_information114     => l_esr_rec.esr_attribute4,
            p_information115     => l_esr_rec.esr_attribute5,
            p_information116     => l_esr_rec.esr_attribute6,
            p_information117     => l_esr_rec.esr_attribute7,
            p_information118     => l_esr_rec.esr_attribute8,
            p_information119     => l_esr_rec.esr_attribute9,
            p_information110     => l_esr_rec.esr_attribute_category,
            p_information11     => l_esr_rec.excld_flag,
            p_information257     => l_esr_rec.ordr_num,
            p_information262     => l_esr_rec.vrbl_rt_prfl_id,
            p_information166     => NULL, -- No ESD for Assignment Status
            p_information265    => l_esr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_esr_result_id is null then
                  l_out_esr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_esr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_EE_STAT_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_EE_STAT_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_FL_TM_PT_TM_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_ftr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_fl_tm_pt_tm_rt_id := l_parent_rec.fl_tm_pt_tm_rt_id ;
            --
            for l_ftr_rec in c_ftr(l_parent_rec.fl_tm_pt_tm_rt_id,l_mirror_src_entity_result_id,'FTR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('FTR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('EMP_CAT',l_ftr_rec.fl_tm_pt_tm_cd)
                                 || ben_plan_design_program_module.get_exclude_message(l_ftr_rec.excld_flag); --'Intersection';
              --
              if p_effective_date between l_ftr_rec.effective_start_date
                 and l_ftr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'FTR',
                p_information1     => l_ftr_rec.fl_tm_pt_tm_rt_id,
                p_information2     => l_ftr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_ftr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_ftr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_ftr_rec.excld_flag,
            p_information12     => l_ftr_rec.fl_tm_pt_tm_cd,
            p_information111     => l_ftr_rec.ftr_attribute1,
            p_information120     => l_ftr_rec.ftr_attribute10,
            p_information121     => l_ftr_rec.ftr_attribute11,
            p_information122     => l_ftr_rec.ftr_attribute12,
            p_information123     => l_ftr_rec.ftr_attribute13,
            p_information124     => l_ftr_rec.ftr_attribute14,
            p_information125     => l_ftr_rec.ftr_attribute15,
            p_information126     => l_ftr_rec.ftr_attribute16,
            p_information127     => l_ftr_rec.ftr_attribute17,
            p_information128     => l_ftr_rec.ftr_attribute18,
            p_information129     => l_ftr_rec.ftr_attribute19,
            p_information112     => l_ftr_rec.ftr_attribute2,
            p_information130     => l_ftr_rec.ftr_attribute20,
            p_information131     => l_ftr_rec.ftr_attribute21,
            p_information132     => l_ftr_rec.ftr_attribute22,
            p_information133     => l_ftr_rec.ftr_attribute23,
            p_information134     => l_ftr_rec.ftr_attribute24,
            p_information135     => l_ftr_rec.ftr_attribute25,
            p_information136     => l_ftr_rec.ftr_attribute26,
            p_information137     => l_ftr_rec.ftr_attribute27,
            p_information138     => l_ftr_rec.ftr_attribute28,
            p_information139     => l_ftr_rec.ftr_attribute29,
            p_information113     => l_ftr_rec.ftr_attribute3,
            p_information140     => l_ftr_rec.ftr_attribute30,
            p_information114     => l_ftr_rec.ftr_attribute4,
            p_information115     => l_ftr_rec.ftr_attribute5,
            p_information116     => l_ftr_rec.ftr_attribute6,
            p_information117     => l_ftr_rec.ftr_attribute7,
            p_information118     => l_ftr_rec.ftr_attribute8,
            p_information119     => l_ftr_rec.ftr_attribute9,
            p_information110     => l_ftr_rec.ftr_attribute_category,
            p_information260     => l_ftr_rec.ordr_num,
            p_information262     => l_ftr_rec.vrbl_rt_prfl_id,
            p_information265     => l_ftr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_ftr_result_id is null then
                  l_out_ftr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_ftr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_FL_TM_PT_TM_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_GNDR_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_gnr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_gndr_rt_id := l_parent_rec.gndr_rt_id ;
            --
            for l_gnr_rec in c_gnr(l_parent_rec.gndr_rt_id,l_mirror_src_entity_result_id,'GNR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('GNR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('BEN_GNDR',l_gnr_rec.gndr_cd)
                                 || ben_plan_design_program_module.get_exclude_message(l_gnr_rec.excld_flag); --'Intersection';
              --
              if p_effective_date between l_gnr_rec.effective_start_date
                 and l_gnr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'GNR',
                p_information1     => l_gnr_rec.gndr_rt_id,
                p_information2     => l_gnr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_gnr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_gnr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_gnr_rec.excld_flag,
            p_information11     => l_gnr_rec.gndr_cd,
            p_information111     => l_gnr_rec.gnr_attribute1,
            p_information120     => l_gnr_rec.gnr_attribute10,
            p_information121     => l_gnr_rec.gnr_attribute11,
            p_information122     => l_gnr_rec.gnr_attribute12,
            p_information123     => l_gnr_rec.gnr_attribute13,
            p_information124     => l_gnr_rec.gnr_attribute14,
            p_information125     => l_gnr_rec.gnr_attribute15,
            p_information126     => l_gnr_rec.gnr_attribute16,
            p_information127     => l_gnr_rec.gnr_attribute17,
            p_information128     => l_gnr_rec.gnr_attribute18,
            p_information129     => l_gnr_rec.gnr_attribute19,
            p_information112     => l_gnr_rec.gnr_attribute2,
            p_information130     => l_gnr_rec.gnr_attribute20,
            p_information131     => l_gnr_rec.gnr_attribute21,
            p_information132     => l_gnr_rec.gnr_attribute22,
            p_information133     => l_gnr_rec.gnr_attribute23,
            p_information134     => l_gnr_rec.gnr_attribute24,
            p_information135     => l_gnr_rec.gnr_attribute25,
            p_information136     => l_gnr_rec.gnr_attribute26,
            p_information137     => l_gnr_rec.gnr_attribute27,
            p_information138     => l_gnr_rec.gnr_attribute28,
            p_information139     => l_gnr_rec.gnr_attribute29,
            p_information113     => l_gnr_rec.gnr_attribute3,
            p_information140     => l_gnr_rec.gnr_attribute30,
            p_information114     => l_gnr_rec.gnr_attribute4,
            p_information115     => l_gnr_rec.gnr_attribute5,
            p_information116     => l_gnr_rec.gnr_attribute6,
            p_information117     => l_gnr_rec.gnr_attribute7,
            p_information118     => l_gnr_rec.gnr_attribute8,
            p_information119     => l_gnr_rec.gnr_attribute9,
            p_information110     => l_gnr_rec.gnr_attribute_category,
            p_information257     => l_gnr_rec.ordr_num,
            p_information262     => l_gnr_rec.vrbl_rt_prfl_id,
            p_information265     => l_gnr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_gnr_result_id is null then
                  l_out_gnr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_gnr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_GNDR_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_GRADE_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_GRADE_RT_F',100);
         for l_parent_rec  in c_grr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_grade_rt_id := l_parent_rec.grade_rt_id ;
            --
            hr_utility.set_location('l_grade_rt_id '||l_grade_rt_id,100);
            for l_grr_rec in c_grr(l_parent_rec.grade_rt_id,l_mirror_src_entity_result_id,'GRR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('GRR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_grade_name(l_grr_rec.grade_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_grr_rec.excld_flag); --'Intersection';
              --
              if p_effective_date between l_grr_rec.effective_start_date
                 and l_grr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;

              -- To store effective_start_date of grade
              -- for Mapping - Bug 2958658
              --
              l_grade_start_date := null;
              if l_grr_rec.grade_id is not null then
                open c_grade_start_date(l_grr_rec.grade_id);
                fetch c_grade_start_date into l_grade_start_date;
                close c_grade_start_date;
              end if;

              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the grade name to display on mapping page.
              --
              open c_get_mapping_name5(l_grr_rec.grade_id,NVL(l_grade_start_date,p_effective_date));
              fetch c_get_mapping_name5 into l_mapping_name;
              close c_get_mapping_name5;
              --
              l_mapping_id   := l_grr_rec.grade_id;
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
              hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
              hr_utility.set_location('l_mapping_name '||l_mapping_name,100);

              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'GRR',
                p_information1     => l_grr_rec.grade_rt_id,
                p_information2     => l_grr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_grr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_grr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information11     => l_grr_rec.excld_flag,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_grr_rec.grr_attribute1,
            p_information120     => l_grr_rec.grr_attribute10,
            p_information121     => l_grr_rec.grr_attribute11,
            p_information122     => l_grr_rec.grr_attribute12,
            p_information123     => l_grr_rec.grr_attribute13,
            p_information124     => l_grr_rec.grr_attribute14,
            p_information125     => l_grr_rec.grr_attribute15,
            p_information126     => l_grr_rec.grr_attribute16,
            p_information127     => l_grr_rec.grr_attribute17,
            p_information128     => l_grr_rec.grr_attribute18,
            p_information129     => l_grr_rec.grr_attribute19,
            p_information112     => l_grr_rec.grr_attribute2,
            p_information130     => l_grr_rec.grr_attribute20,
            p_information131     => l_grr_rec.grr_attribute21,
            p_information132     => l_grr_rec.grr_attribute22,
            p_information133     => l_grr_rec.grr_attribute23,
            p_information134     => l_grr_rec.grr_attribute24,
            p_information135     => l_grr_rec.grr_attribute25,
            p_information136     => l_grr_rec.grr_attribute26,
            p_information137     => l_grr_rec.grr_attribute27,
            p_information138     => l_grr_rec.grr_attribute28,
            p_information139     => l_grr_rec.grr_attribute29,
            p_information113     => l_grr_rec.grr_attribute3,
            p_information140     => l_grr_rec.grr_attribute30,
            p_information114     => l_grr_rec.grr_attribute4,
            p_information115     => l_grr_rec.grr_attribute5,
            p_information116     => l_grr_rec.grr_attribute6,
            p_information117     => l_grr_rec.grr_attribute7,
            p_information118     => l_grr_rec.grr_attribute8,
            p_information119     => l_grr_rec.grr_attribute9,
            p_information110     => l_grr_rec.grr_attribute_category,
            p_information260     => l_grr_rec.ordr_num,
            p_information262     => l_grr_rec.vrbl_rt_prfl_id,
            p_information166     => l_grade_start_date,
            p_information265     => l_grr_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_grr_result_id is null then
                  l_out_grr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_grr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_GRADE_RT_F',100);
        ---------------------------------------------------------------
        -- END OF BEN_GRADE_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_HRLY_SLRD_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_hsr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_hrly_slrd_rt_id := l_parent_rec.hrly_slrd_rt_id ;
            --
            for l_hsr_rec in c_hsr(l_parent_rec.hrly_slrd_rt_id,l_mirror_src_entity_result_id,'HSR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('HSR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('HOURLY_SALARIED_CODE',l_hsr_rec.hrly_slrd_cd)
                                 || ben_plan_design_program_module.get_exclude_message(l_hsr_rec.excld_flag); --'Intersection';
              --
              if p_effective_date between l_hsr_rec.effective_start_date
                 and l_hsr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'HSR',
                p_information1     => l_hsr_rec.hrly_slrd_rt_id,
                p_information2     => l_hsr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_hsr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_hsr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_hsr_rec.excld_flag,
            p_information12     => l_hsr_rec.hrly_slrd_cd,
            p_information111     => l_hsr_rec.hsr_attribute1,
            p_information120     => l_hsr_rec.hsr_attribute10,
            p_information121     => l_hsr_rec.hsr_attribute11,
            p_information122     => l_hsr_rec.hsr_attribute12,
            p_information123     => l_hsr_rec.hsr_attribute13,
            p_information124     => l_hsr_rec.hsr_attribute14,
            p_information125     => l_hsr_rec.hsr_attribute15,
            p_information126     => l_hsr_rec.hsr_attribute16,
            p_information127     => l_hsr_rec.hsr_attribute17,
            p_information128     => l_hsr_rec.hsr_attribute18,
            p_information129     => l_hsr_rec.hsr_attribute19,
            p_information112     => l_hsr_rec.hsr_attribute2,
            p_information130     => l_hsr_rec.hsr_attribute20,
            p_information131     => l_hsr_rec.hsr_attribute21,
            p_information132     => l_hsr_rec.hsr_attribute22,
            p_information133     => l_hsr_rec.hsr_attribute23,
            p_information134     => l_hsr_rec.hsr_attribute24,
            p_information135     => l_hsr_rec.hsr_attribute25,
            p_information136     => l_hsr_rec.hsr_attribute26,
            p_information137     => l_hsr_rec.hsr_attribute27,
            p_information138     => l_hsr_rec.hsr_attribute28,
            p_information139     => l_hsr_rec.hsr_attribute29,
            p_information113     => l_hsr_rec.hsr_attribute3,
            p_information140     => l_hsr_rec.hsr_attribute30,
            p_information114     => l_hsr_rec.hsr_attribute4,
            p_information115     => l_hsr_rec.hsr_attribute5,
            p_information116     => l_hsr_rec.hsr_attribute6,
            p_information117     => l_hsr_rec.hsr_attribute7,
            p_information118     => l_hsr_rec.hsr_attribute8,
            p_information119     => l_hsr_rec.hsr_attribute9,
            p_information110     => l_hsr_rec.hsr_attribute_category,
            p_information257     => l_hsr_rec.ordr_num,
            p_information262     => l_hsr_rec.vrbl_rt_prfl_id,
            p_information265     => l_hsr_rec.object_version_number,

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_hsr_result_id is null then
                  l_out_hsr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_hsr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_HRLY_SLRD_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_HRS_WKD_IN_PERD_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_HRS_WKD_IN_PERD_RT_F ',100);
         for l_parent_rec  in c_hwr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_hrs_wkd_in_perd_rt_id := l_parent_rec.hrs_wkd_in_perd_rt_id ;
            --
            hr_utility.set_location('l_hrs_wkd_in_perd_rt_id '||l_hrs_wkd_in_perd_rt_id,100);
            for l_hwr_rec in c_hwr(l_parent_rec.hrs_wkd_in_perd_rt_id,l_mirror_src_entity_result_id,'HWR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('HWR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_hrs_wkd_in_perd_fctr_name(l_hwr_rec.hrs_wkd_in_perd_fctr_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_hwr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_hwr_rec.effective_start_date
                 and l_hwr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'HWR',
                p_information1     => l_hwr_rec.hrs_wkd_in_perd_rt_id,
                p_information2     => l_hwr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_hwr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_hwr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_hwr_rec.excld_flag,
            p_information224     => l_hwr_rec.hrs_wkd_in_perd_fctr_id,
            p_information111     => l_hwr_rec.hwr_attribute1,
            p_information120     => l_hwr_rec.hwr_attribute10,
            p_information121     => l_hwr_rec.hwr_attribute11,
            p_information122     => l_hwr_rec.hwr_attribute12,
            p_information123     => l_hwr_rec.hwr_attribute13,
            p_information124     => l_hwr_rec.hwr_attribute14,
            p_information125     => l_hwr_rec.hwr_attribute15,
            p_information126     => l_hwr_rec.hwr_attribute16,
            p_information127     => l_hwr_rec.hwr_attribute17,
            p_information128     => l_hwr_rec.hwr_attribute18,
            p_information129     => l_hwr_rec.hwr_attribute19,
            p_information112     => l_hwr_rec.hwr_attribute2,
            p_information130     => l_hwr_rec.hwr_attribute20,
            p_information131     => l_hwr_rec.hwr_attribute21,
            p_information132     => l_hwr_rec.hwr_attribute22,
            p_information133     => l_hwr_rec.hwr_attribute23,
            p_information134     => l_hwr_rec.hwr_attribute24,
            p_information135     => l_hwr_rec.hwr_attribute25,
            p_information136     => l_hwr_rec.hwr_attribute26,
            p_information137     => l_hwr_rec.hwr_attribute27,
            p_information138     => l_hwr_rec.hwr_attribute28,
            p_information139     => l_hwr_rec.hwr_attribute29,
            p_information113     => l_hwr_rec.hwr_attribute3,
            p_information140     => l_hwr_rec.hwr_attribute30,
            p_information114     => l_hwr_rec.hwr_attribute4,
            p_information115     => l_hwr_rec.hwr_attribute5,
            p_information116     => l_hwr_rec.hwr_attribute6,
            p_information117     => l_hwr_rec.hwr_attribute7,
            p_information118     => l_hwr_rec.hwr_attribute8,
            p_information119     => l_hwr_rec.hwr_attribute9,
            p_information110     => l_hwr_rec.hwr_attribute_category,
            p_information260     => l_hwr_rec.ordr_num,
            p_information262     => l_hwr_rec.vrbl_rt_prfl_id,
            p_information265     => l_hwr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_hwr_result_id is null then
                  l_out_hwr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_hwr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
            for l_hwr_rec in c_hwr_drp(l_parent_rec.hrs_wkd_in_perd_rt_id,l_mirror_src_entity_result_id,'HWR') loop
            hr_utility.set_location('l_parent_rec.hrs_wkd_in_perd_rt_id '||l_parent_rec.hrs_wkd_in_perd_rt_id,100);
               create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_out_hwr_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => l_hwr_rec.hrs_wkd_in_perd_fctr_id
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
             end loop;
           end loop;
         hr_utility.set_location('END OF BEN_HRS_WKD_IN_PERD_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_HRS_WKD_IN_PERD_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_LBR_MMBR_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_lmm_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_lbr_mmbr_rt_id := l_parent_rec.lbr_mmbr_rt_id ;
            --
            for l_lmm_rec in c_lmm(l_parent_rec.lbr_mmbr_rt_id,l_mirror_src_entity_result_id,'LMM') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('LMM');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_lbr_mmbr_name(l_lmm_rec.lbr_mmbr_flag)
                                 || ben_plan_design_program_module.get_exclude_message(l_lmm_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_lmm_rec.effective_start_date
                 and l_lmm_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'LMM',
                p_information1     => l_lmm_rec.lbr_mmbr_rt_id,
                p_information2     => l_lmm_rec.EFFECTIVE_START_DATE,
                p_information3     => l_lmm_rec.EFFECTIVE_END_DATE,
                p_information4     => l_lmm_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_lmm_rec.excld_flag,
            p_information11     => l_lmm_rec.lbr_mmbr_flag,
            p_information111     => l_lmm_rec.lmm_attribute1,
            p_information120     => l_lmm_rec.lmm_attribute10,
            p_information121     => l_lmm_rec.lmm_attribute11,
            p_information122     => l_lmm_rec.lmm_attribute12,
            p_information123     => l_lmm_rec.lmm_attribute13,
            p_information124     => l_lmm_rec.lmm_attribute14,
            p_information125     => l_lmm_rec.lmm_attribute15,
            p_information126     => l_lmm_rec.lmm_attribute16,
            p_information127     => l_lmm_rec.lmm_attribute17,
            p_information128     => l_lmm_rec.lmm_attribute18,
            p_information129     => l_lmm_rec.lmm_attribute19,
            p_information112     => l_lmm_rec.lmm_attribute2,
            p_information130     => l_lmm_rec.lmm_attribute20,
            p_information131     => l_lmm_rec.lmm_attribute21,
            p_information132     => l_lmm_rec.lmm_attribute22,
            p_information133     => l_lmm_rec.lmm_attribute23,
            p_information134     => l_lmm_rec.lmm_attribute24,
            p_information135     => l_lmm_rec.lmm_attribute25,
            p_information136     => l_lmm_rec.lmm_attribute26,
            p_information137     => l_lmm_rec.lmm_attribute27,
            p_information138     => l_lmm_rec.lmm_attribute28,
            p_information139     => l_lmm_rec.lmm_attribute29,
            p_information113     => l_lmm_rec.lmm_attribute3,
            p_information140     => l_lmm_rec.lmm_attribute30,
            p_information114     => l_lmm_rec.lmm_attribute4,
            p_information115     => l_lmm_rec.lmm_attribute5,
            p_information116     => l_lmm_rec.lmm_attribute6,
            p_information117     => l_lmm_rec.lmm_attribute7,
            p_information118     => l_lmm_rec.lmm_attribute8,
            p_information119     => l_lmm_rec.lmm_attribute9,
            p_information110     => l_lmm_rec.lmm_attribute_category,
            p_information257     => l_lmm_rec.ordr_num,
            p_information262     => l_lmm_rec.vrbl_rt_prfl_id,
            p_information265     => l_lmm_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_lmm_result_id is null then
                  l_out_lmm_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_lmm_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_LBR_MMBR_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_LGL_ENTY_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_LGL_ENTY_RT_F ',100);
         for l_parent_rec  in c_ler_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_lgl_enty_rt_id := l_parent_rec.lgl_enty_rt_id ;
            --
            hr_utility.set_location('l_lgl_enty_rt_id '||l_lgl_enty_rt_id,100);
            for l_ler_rec in c_ler(l_parent_rec.lgl_enty_rt_id,l_mirror_src_entity_result_id,'LER1') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('LER1');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_organization_name(l_ler_rec.organization_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_ler_rec.excld_flag);
                                 --'Intersection';
              --
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

              -- To store effective_start_date of organization
              -- for Mapping - Bug 2958658
              --
              l_organization_start_date := null;
              if l_ler_rec.organization_id is not null then
                open c_organization_start_date(l_ler_rec.organization_id);
                fetch c_organization_start_date into l_organization_start_date;
                close c_organization_start_date;
              end if;

              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the defined balance name to display on mapping page.
              --
              open c_get_mapping_name6(l_ler_rec.organization_id,
                                       NVL(l_organization_start_date,p_effective_date));
              fetch c_get_mapping_name6 into l_mapping_name;
              close c_get_mapping_name6;
              --
              l_mapping_id   := l_ler_rec.organization_id;
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
              hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
              hr_utility.set_location('l_mapping_name '||l_mapping_name,100);

              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'LER1',
                p_information1     => l_ler_rec.lgl_enty_rt_id,
                p_information2     => l_ler_rec.EFFECTIVE_START_DATE,
                p_information3     => l_ler_rec.EFFECTIVE_END_DATE,
                p_information4     => l_ler_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_ler_rec.excld_flag,
            p_information111     => l_ler_rec.ler1_attribute1,
            p_information120     => l_ler_rec.ler1_attribute10,
            p_information121     => l_ler_rec.ler1_attribute11,
            p_information122     => l_ler_rec.ler1_attribute12,
            p_information123     => l_ler_rec.ler1_attribute13,
            p_information124     => l_ler_rec.ler1_attribute14,
            p_information125     => l_ler_rec.ler1_attribute15,
            p_information126     => l_ler_rec.ler1_attribute16,
            p_information127     => l_ler_rec.ler1_attribute17,
            p_information128     => l_ler_rec.ler1_attribute18,
            p_information129     => l_ler_rec.ler1_attribute19,
            p_information112     => l_ler_rec.ler1_attribute2,
            p_information130     => l_ler_rec.ler1_attribute20,
            p_information131     => l_ler_rec.ler1_attribute21,
            p_information132     => l_ler_rec.ler1_attribute22,
            p_information133     => l_ler_rec.ler1_attribute23,
            p_information134     => l_ler_rec.ler1_attribute24,
            p_information135     => l_ler_rec.ler1_attribute25,
            p_information136     => l_ler_rec.ler1_attribute26,
            p_information137     => l_ler_rec.ler1_attribute27,
            p_information138     => l_ler_rec.ler1_attribute28,
            p_information139     => l_ler_rec.ler1_attribute29,
            p_information113     => l_ler_rec.ler1_attribute3,
            p_information140     => l_ler_rec.ler1_attribute30,
            p_information114     => l_ler_rec.ler1_attribute4,
            p_information115     => l_ler_rec.ler1_attribute5,
            p_information116     => l_ler_rec.ler1_attribute6,
            p_information117     => l_ler_rec.ler1_attribute7,
            p_information118     => l_ler_rec.ler1_attribute8,
            p_information119     => l_ler_rec.ler1_attribute9,
            p_information110     => l_ler_rec.ler1_attribute_category,
            p_information257     => l_ler_rec.ordr_num,
            p_information252     => l_ler_rec.organization_id,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information262     => l_ler_rec.vrbl_rt_prfl_id,
            p_information166     => l_organization_start_date,
            p_information265     => l_ler_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_ler_result_id is null then
                  l_out_ler_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_ler_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_LGL_ENTY_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_LGL_ENTY_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_LOA_RSN_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_LOA_RSN_RT_F ',100);
         for l_parent_rec  in c_lar_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_loa_rsn_rt_id := l_parent_rec.loa_rsn_rt_id ;
            --
            hr_utility.set_location('l_loa_rsn_rt_id '||l_loa_rsn_rt_id,100);
            for l_lar_rec in c_lar(l_parent_rec.loa_rsn_rt_id,l_mirror_src_entity_result_id,'LAR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('LAR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_absence_type_name(l_lar_rec.absence_attendance_type_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_lar_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_lar_rec.effective_start_date
                 and l_lar_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;

              -- To store effective_start_date of absence_type
              -- and absence_reason for Mapping - Bug 2958658
              --
              l_absence_type_start_date := null;
              if l_lar_rec.absence_attendance_type_id is not null then
                open c_absence_type_start_date(l_lar_rec.absence_attendance_type_id);
                fetch c_absence_type_start_date into l_absence_type_start_date;
                close c_absence_type_start_date;
              end if;

--PADMAJA
              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --
              l_mapping_name := null;
              l_mapping_id   := null;
              l_mapping_name1:= null;
              l_mapping_id1  := null;
              --
              -- Get the absence attendance name to display on mapping page.
              --
              -- 9999 needs review
              open c_get_mapping_name7(l_lar_rec.absence_attendance_type_id,
                                       NVL(l_absence_type_start_date,p_effective_date));
              fetch c_get_mapping_name7 into l_mapping_name;
              close c_get_mapping_name7;
              --
              l_mapping_id   := l_lar_rec.absence_attendance_type_id;
              --

              open c_get_mapping_name8(l_lar_rec.absence_attendance_type_id,
                                       l_lar_rec.abs_attendance_reason_id,
                                       NVL(l_absence_type_start_date,p_effective_date));
              fetch c_get_mapping_name8 into l_mapping_name1;
              close c_get_mapping_name8;
              --
              l_mapping_id1   := l_lar_rec.abs_attendance_reason_id;
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
              hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
              hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
              hr_utility.set_location('l_mapping_id1 '||l_mapping_id1,100);
              hr_utility.set_location('l_mapping_name1 '||l_mapping_name1,100);
              --

              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'LAR',
                p_information1     => l_lar_rec.loa_rsn_rt_id,
                p_information2     => l_lar_rec.EFFECTIVE_START_DATE,
                p_information3     => l_lar_rec.EFFECTIVE_END_DATE,
                p_information4     => l_lar_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            -- Data for MAPPING columns.
            p_information177    => l_mapping_name1,
            p_information178    => l_mapping_id1,
            -- END other product Mapping columns.
            p_information11     => l_lar_rec.excld_flag,
            p_information111     => l_lar_rec.lar_attribute1,
            p_information120     => l_lar_rec.lar_attribute10,
            p_information121     => l_lar_rec.lar_attribute11,
            p_information122     => l_lar_rec.lar_attribute12,
            p_information123     => l_lar_rec.lar_attribute13,
            p_information124     => l_lar_rec.lar_attribute14,
            p_information125     => l_lar_rec.lar_attribute15,
            p_information126     => l_lar_rec.lar_attribute16,
            p_information127     => l_lar_rec.lar_attribute17,
            p_information128     => l_lar_rec.lar_attribute18,
            p_information129     => l_lar_rec.lar_attribute19,
            p_information112     => l_lar_rec.lar_attribute2,
            p_information130     => l_lar_rec.lar_attribute20,
            p_information131     => l_lar_rec.lar_attribute21,
            p_information132     => l_lar_rec.lar_attribute22,
            p_information133     => l_lar_rec.lar_attribute23,
            p_information134     => l_lar_rec.lar_attribute24,
            p_information135     => l_lar_rec.lar_attribute25,
            p_information136     => l_lar_rec.lar_attribute26,
            p_information137     => l_lar_rec.lar_attribute27,
            p_information138     => l_lar_rec.lar_attribute28,
            p_information139     => l_lar_rec.lar_attribute29,
            p_information113     => l_lar_rec.lar_attribute3,
            p_information140     => l_lar_rec.lar_attribute30,
            p_information114     => l_lar_rec.lar_attribute4,
            p_information115     => l_lar_rec.lar_attribute5,
            p_information116     => l_lar_rec.lar_attribute6,
            p_information117     => l_lar_rec.lar_attribute7,
            p_information118     => l_lar_rec.lar_attribute8,
            p_information119     => l_lar_rec.lar_attribute9,
            p_information110     => l_lar_rec.lar_attribute_category,
            p_information12     => l_lar_rec.loa_rsn_cd,
            p_information260     => l_lar_rec.ordr_num,
            p_information262     => l_lar_rec.vrbl_rt_prfl_id,
            p_information166     => l_absence_type_start_date,
            p_information306     => l_absence_type_start_date,
            p_information265     => l_lar_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_lar_result_id is null then
                  l_out_lar_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_lar_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_LOA_RSN_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_LOA_RSN_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_LOS_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_lsr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_los_rt_id := l_parent_rec.los_rt_id ;
            --
            for l_lsr_rec in c_lsr(l_parent_rec.los_rt_id,l_mirror_src_entity_result_id,'LSR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('LSR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_los_fctr_name(l_lsr_rec.los_fctr_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_lsr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_lsr_rec.effective_start_date
                 and l_lsr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'LSR',
                p_information1     => l_lsr_rec.los_rt_id,
                p_information2     => l_lsr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_lsr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_lsr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information11     => l_lsr_rec.excld_flag,
            p_information243     => l_lsr_rec.los_fctr_id,
            p_information111     => l_lsr_rec.lsr_attribute1,
            p_information120     => l_lsr_rec.lsr_attribute10,
            p_information121     => l_lsr_rec.lsr_attribute11,
            p_information122     => l_lsr_rec.lsr_attribute12,
            p_information123     => l_lsr_rec.lsr_attribute13,
            p_information124     => l_lsr_rec.lsr_attribute14,
            p_information125     => l_lsr_rec.lsr_attribute15,
            p_information126     => l_lsr_rec.lsr_attribute16,
            p_information127     => l_lsr_rec.lsr_attribute17,
            p_information128     => l_lsr_rec.lsr_attribute18,
            p_information129     => l_lsr_rec.lsr_attribute19,
            p_information112     => l_lsr_rec.lsr_attribute2,
            p_information130     => l_lsr_rec.lsr_attribute20,
            p_information131     => l_lsr_rec.lsr_attribute21,
            p_information132     => l_lsr_rec.lsr_attribute22,
            p_information133     => l_lsr_rec.lsr_attribute23,
            p_information134     => l_lsr_rec.lsr_attribute24,
            p_information135     => l_lsr_rec.lsr_attribute25,
            p_information136     => l_lsr_rec.lsr_attribute26,
            p_information137     => l_lsr_rec.lsr_attribute27,
            p_information138     => l_lsr_rec.lsr_attribute28,
            p_information139     => l_lsr_rec.lsr_attribute29,
            p_information113     => l_lsr_rec.lsr_attribute3,
            p_information140     => l_lsr_rec.lsr_attribute30,
            p_information114     => l_lsr_rec.lsr_attribute4,
            p_information115     => l_lsr_rec.lsr_attribute5,
            p_information116     => l_lsr_rec.lsr_attribute6,
            p_information117     => l_lsr_rec.lsr_attribute7,
            p_information118     => l_lsr_rec.lsr_attribute8,
            p_information119     => l_lsr_rec.lsr_attribute9,
            p_information110     => l_lsr_rec.lsr_attribute_category,
            p_information260     => l_lsr_rec.ordr_num,
            p_information262     => l_lsr_rec.vrbl_rt_prfl_id,
            p_information265     => l_lsr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_lsr_result_id is null then
                  l_out_lsr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_lsr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
            for l_lsr_rec in c_lsr_drp(l_parent_rec.los_rt_id,l_mirror_src_entity_result_id,'LSR') loop
            hr_utility.set_location('l_parent_rec.los_rt_id '||l_parent_rec.los_rt_id,100);
               create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_out_lsr_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => l_lsr_rec.los_fctr_id
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
             end loop;
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_LOS_RT_F ----------------------
        ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_LVG_RSN_RT_F ----------------------
        ---------------------------------------------------------------
          --
          for l_parent_rec  in c_lrn_from_parent(l_VRBL_RT_PRFL_ID) loop
             --
             l_mirror_src_entity_result_id := l_out_vpf_result_id ;
             --
             l_lvg_rsn_rt_id := l_parent_rec.lvg_rsn_rt_id ;
             --
             for l_lrn_rec in c_lrn(l_parent_rec.lvg_rsn_rt_id,l_mirror_src_entity_result_id,'LRN') loop
               --
               l_table_route_id := null ;
               open ben_plan_design_program_module.g_table_route('LRN');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
               close ben_plan_design_program_module.g_table_route ;
               --
               l_information5  := hr_general.decode_lookup('LEAV_REAS',l_lrn_rec.lvg_rsn_cd)
                                  || ben_plan_design_program_module.get_exclude_message(l_lrn_rec.excld_flag);
               --
               if p_effective_date between l_lrn_rec.effective_start_date
                  and l_lrn_rec.effective_end_date then
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
		 P_TABLE_ALIAS                    => 'LRN',
                 p_information1     => l_lrn_rec.lvg_rsn_rt_id,
                 p_information2     => l_lrn_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_lrn_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_lrn_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_lrn_rec.excld_flag,
            p_information111     => l_lrn_rec.lrn_attribute1,
            p_information120     => l_lrn_rec.lrn_attribute10,
            p_information121     => l_lrn_rec.lrn_attribute11,
            p_information122     => l_lrn_rec.lrn_attribute12,
            p_information123     => l_lrn_rec.lrn_attribute13,
            p_information124     => l_lrn_rec.lrn_attribute14,
            p_information125     => l_lrn_rec.lrn_attribute15,
            p_information126     => l_lrn_rec.lrn_attribute16,
            p_information127     => l_lrn_rec.lrn_attribute17,
            p_information128     => l_lrn_rec.lrn_attribute18,
            p_information129     => l_lrn_rec.lrn_attribute19,
            p_information112     => l_lrn_rec.lrn_attribute2,
            p_information130     => l_lrn_rec.lrn_attribute20,
            p_information131     => l_lrn_rec.lrn_attribute21,
            p_information132     => l_lrn_rec.lrn_attribute22,
            p_information133     => l_lrn_rec.lrn_attribute23,
            p_information134     => l_lrn_rec.lrn_attribute24,
            p_information135     => l_lrn_rec.lrn_attribute25,
            p_information136     => l_lrn_rec.lrn_attribute26,
            p_information137     => l_lrn_rec.lrn_attribute27,
            p_information138     => l_lrn_rec.lrn_attribute28,
            p_information139     => l_lrn_rec.lrn_attribute29,
            p_information113     => l_lrn_rec.lrn_attribute3,
            p_information140     => l_lrn_rec.lrn_attribute30,
            p_information114     => l_lrn_rec.lrn_attribute4,
            p_information115     => l_lrn_rec.lrn_attribute5,
            p_information116     => l_lrn_rec.lrn_attribute6,
            p_information117     => l_lrn_rec.lrn_attribute7,
            p_information118     => l_lrn_rec.lrn_attribute8,
            p_information119     => l_lrn_rec.lrn_attribute9,
            p_information110     => l_lrn_rec.lrn_attribute_category,
            p_information11     => l_lrn_rec.lvg_rsn_cd,
            p_information257     => l_lrn_rec.ordr_num,
            p_information262     => l_lrn_rec.vrbl_rt_prfl_id,
            p_information265     => l_lrn_rec.object_version_number,
           --

                 p_object_version_number          => l_object_version_number,
                 p_effective_date                 => p_effective_date       );
                 --

                 if l_out_lrn_result_id is null then
                   l_out_lrn_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                    l_out_lrn_result_id := l_copy_entity_result_id ;
                 end if;
                 --
              end loop;
              --
            end loop;
         ---------------------------------------------------------------
         -- END OF BEN_LVG_RSN_RT_F ----------------------
         ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_ORG_UNIT_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_ORG_UNIT_RT_F',100);
         for l_parent_rec  in c_our_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_org_unit_rt_id := l_parent_rec.org_unit_rt_id ;
            --
            hr_utility.set_location('l_org_unit_rt_id '||l_org_unit_rt_id,100);
            for l_our_rec in c_our(l_parent_rec.org_unit_rt_id,l_mirror_src_entity_result_id,'OUR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('OUR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_organization_name(l_our_rec.organization_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_our_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_our_rec.effective_start_date
                 and l_our_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;

              -- To store effective_start_date of organization
              -- for Mapping - Bug 2958658
              --
              l_organization_start_date := null;
              if l_our_rec.organization_id is not null then
                open c_organization_start_date(l_our_rec.organization_id);
                fetch c_organization_start_date into l_organization_start_date;
                close c_organization_start_date;
              end if;

              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the defined balance name to display on mapping page.
              --
              open c_get_mapping_name9(l_our_rec.organization_id,
                                       NVL(l_organization_start_date,p_effective_date));
              fetch c_get_mapping_name9 into l_mapping_name;
              close c_get_mapping_name9;
              --
              l_mapping_id   := l_our_rec.organization_id;
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
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'OUR',
                p_information1     => l_our_rec.org_unit_rt_id,
                p_information2     => l_our_rec.EFFECTIVE_START_DATE,
                p_information3     => l_our_rec.EFFECTIVE_END_DATE,
                p_information4     => l_our_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_our_rec.excld_flag,
            p_information260     => l_our_rec.ordr_num,
            p_information252     => l_our_rec.organization_id,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_our_rec.our_attribute1,
            p_information120     => l_our_rec.our_attribute10,
            p_information121     => l_our_rec.our_attribute11,
            p_information122     => l_our_rec.our_attribute12,
            p_information123     => l_our_rec.our_attribute13,
            p_information124     => l_our_rec.our_attribute14,
            p_information125     => l_our_rec.our_attribute15,
            p_information126     => l_our_rec.our_attribute16,
            p_information127     => l_our_rec.our_attribute17,
            p_information128     => l_our_rec.our_attribute18,
            p_information129     => l_our_rec.our_attribute19,
            p_information112     => l_our_rec.our_attribute2,
            p_information130     => l_our_rec.our_attribute20,
            p_information131     => l_our_rec.our_attribute21,
            p_information132     => l_our_rec.our_attribute22,
            p_information133     => l_our_rec.our_attribute23,
            p_information134     => l_our_rec.our_attribute24,
            p_information135     => l_our_rec.our_attribute25,
            p_information136     => l_our_rec.our_attribute26,
            p_information137     => l_our_rec.our_attribute27,
            p_information138     => l_our_rec.our_attribute28,
            p_information139     => l_our_rec.our_attribute29,
            p_information113     => l_our_rec.our_attribute3,
            p_information140     => l_our_rec.our_attribute30,
            p_information114     => l_our_rec.our_attribute4,
            p_information115     => l_our_rec.our_attribute5,
            p_information116     => l_our_rec.our_attribute6,
            p_information117     => l_our_rec.our_attribute7,
            p_information118     => l_our_rec.our_attribute8,
            p_information119     => l_our_rec.our_attribute9,
            p_information110     => l_our_rec.our_attribute_category,
            p_information262     => l_our_rec.vrbl_rt_prfl_id,
            p_information166     => l_organization_start_date,
            p_information265     => l_our_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_our_result_id is null then
                  l_out_our_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_our_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_ORG_UNIT_RT_F',100);
        ---------------------------------------------------------------
        -- END OF BEN_ORG_UNIT_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PCT_FL_TM_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_pfr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_pct_fl_tm_rt_id := l_parent_rec.pct_fl_tm_rt_id ;
            --
            for l_pfr_rec in c_pfr(l_parent_rec.pct_fl_tm_rt_id,l_mirror_src_entity_result_id,'PFR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PFR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_pct_fl_tm_fctr_name(l_pfr_rec.pct_fl_tm_fctr_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_pfr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_pfr_rec.effective_start_date
                 and l_pfr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'PFR',
                p_information1     => l_pfr_rec.pct_fl_tm_rt_id,
                p_information2     => l_pfr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_pfr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_pfr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pfr_rec.excld_flag,
            p_information257     => l_pfr_rec.ordr_num,
            p_information233     => l_pfr_rec.pct_fl_tm_fctr_id,
            p_information111     => l_pfr_rec.pfr_attribute1,
            p_information120     => l_pfr_rec.pfr_attribute10,
            p_information121     => l_pfr_rec.pfr_attribute11,
            p_information122     => l_pfr_rec.pfr_attribute12,
            p_information123     => l_pfr_rec.pfr_attribute13,
            p_information124     => l_pfr_rec.pfr_attribute14,
            p_information125     => l_pfr_rec.pfr_attribute15,
            p_information126     => l_pfr_rec.pfr_attribute16,
            p_information127     => l_pfr_rec.pfr_attribute17,
            p_information128     => l_pfr_rec.pfr_attribute18,
            p_information129     => l_pfr_rec.pfr_attribute19,
            p_information112     => l_pfr_rec.pfr_attribute2,
            p_information130     => l_pfr_rec.pfr_attribute20,
            p_information131     => l_pfr_rec.pfr_attribute21,
            p_information132     => l_pfr_rec.pfr_attribute22,
            p_information133     => l_pfr_rec.pfr_attribute23,
            p_information134     => l_pfr_rec.pfr_attribute24,
            p_information135     => l_pfr_rec.pfr_attribute25,
            p_information136     => l_pfr_rec.pfr_attribute26,
            p_information137     => l_pfr_rec.pfr_attribute27,
            p_information138     => l_pfr_rec.pfr_attribute28,
            p_information139     => l_pfr_rec.pfr_attribute29,
            p_information113     => l_pfr_rec.pfr_attribute3,
            p_information140     => l_pfr_rec.pfr_attribute30,
            p_information114     => l_pfr_rec.pfr_attribute4,
            p_information115     => l_pfr_rec.pfr_attribute5,
            p_information116     => l_pfr_rec.pfr_attribute6,
            p_information117     => l_pfr_rec.pfr_attribute7,
            p_information118     => l_pfr_rec.pfr_attribute8,
            p_information119     => l_pfr_rec.pfr_attribute9,
            p_information110     => l_pfr_rec.pfr_attribute_category,
            p_information262     => l_pfr_rec.vrbl_rt_prfl_id,
            p_information265     => l_pfr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_pfr_result_id is null then
                  l_out_pfr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_pfr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
            for l_pfr_rec in c_pfr_drp(l_parent_rec.pct_fl_tm_rt_id,l_mirror_src_entity_result_id,'PFR') loop
               create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_out_pfr_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => null
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => l_pfr_rec.pct_fl_tm_fctr_id
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
             end loop;
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_PCT_FL_TM_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PER_TYP_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_PER_TYP_RT_F ',100);
         for l_parent_rec  in c_ptr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_per_typ_rt_id := l_parent_rec.per_typ_rt_id ;
            --
            hr_utility.set_location('l_per_typ_rt_id '||l_per_typ_rt_id,100);
            for l_ptr_rec in c_ptr(l_parent_rec.per_typ_rt_id,l_mirror_src_entity_result_id,'PTR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PTR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_person_type_name(l_ptr_rec.person_type_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_ptr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_ptr_rec.effective_start_date
                 and l_ptr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
--PADMAJA
              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --
              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the person_type name to display on mapping page.
              --
              open c_get_person_type_name(l_ptr_rec.person_type_id);
              fetch c_get_person_type_name into l_mapping_name;
              close c_get_person_type_name;
              --
              l_mapping_id   := l_ptr_rec.person_type_id;
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

              hr_utility.set_location('l_parent_rec.per_typ_rt_id '||l_parent_rec.per_typ_rt_id,100);
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'PTR',
                p_information1     => l_ptr_rec.per_typ_rt_id,
                p_information2     => l_ptr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_ptr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_ptr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_ptr_rec.excld_flag,
            p_information257     => l_ptr_rec.ordr_num,
            p_information12     => l_ptr_rec.per_typ_cd,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_ptr_rec.ptr_attribute1,
            p_information120     => l_ptr_rec.ptr_attribute10,
            p_information121     => l_ptr_rec.ptr_attribute11,
            p_information122     => l_ptr_rec.ptr_attribute12,
            p_information123     => l_ptr_rec.ptr_attribute13,
            p_information124     => l_ptr_rec.ptr_attribute14,
            p_information125     => l_ptr_rec.ptr_attribute15,
            p_information126     => l_ptr_rec.ptr_attribute16,
            p_information127     => l_ptr_rec.ptr_attribute17,
            p_information128     => l_ptr_rec.ptr_attribute18,
            p_information129     => l_ptr_rec.ptr_attribute19,
            p_information112     => l_ptr_rec.ptr_attribute2,
            p_information130     => l_ptr_rec.ptr_attribute20,
            p_information131     => l_ptr_rec.ptr_attribute21,
            p_information132     => l_ptr_rec.ptr_attribute22,
            p_information133     => l_ptr_rec.ptr_attribute23,
            p_information134     => l_ptr_rec.ptr_attribute24,
            p_information135     => l_ptr_rec.ptr_attribute25,
            p_information136     => l_ptr_rec.ptr_attribute26,
            p_information137     => l_ptr_rec.ptr_attribute27,
            p_information138     => l_ptr_rec.ptr_attribute28,
            p_information139     => l_ptr_rec.ptr_attribute29,
            p_information113     => l_ptr_rec.ptr_attribute3,
            p_information140     => l_ptr_rec.ptr_attribute30,
            p_information114     => l_ptr_rec.ptr_attribute4,
            p_information115     => l_ptr_rec.ptr_attribute5,
            p_information116     => l_ptr_rec.ptr_attribute6,
            p_information117     => l_ptr_rec.ptr_attribute7,
            p_information118     => l_ptr_rec.ptr_attribute8,
            p_information119     => l_ptr_rec.ptr_attribute9,
            p_information110     => l_ptr_rec.ptr_attribute_category,
            p_information262     => l_ptr_rec.vrbl_rt_prfl_id,
            p_information166     => NULL, -- No ESD for Person Type
            p_information265     => l_ptr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_ptr_result_id is null then
                  l_out_ptr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_ptr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_PER_TYP_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_PER_TYP_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_POE_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_prt_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_poe_rt_id := l_parent_rec.poe_rt_id ;
            --
            for l_prt_rec in c_prt(l_parent_rec.poe_rt_id,l_mirror_src_entity_result_id,'PRT') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PRT');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_prt_rec.mn_poe_num ||' - '|| l_prt_rec.mx_poe_num ||
                                 ' ' || hr_general.decode_lookup('BEN_NNMNTRY_UOM',l_prt_rec.poe_nnmntry_uom);
                                 --'Intersection';
              --
              if p_effective_date between l_prt_rec.effective_start_date
                 and l_prt_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'PRT',
                p_information1     => l_prt_rec.poe_rt_id,
                p_information2     => l_prt_rec.EFFECTIVE_START_DATE,
                p_information3     => l_prt_rec.EFFECTIVE_END_DATE,
                p_information4     => l_prt_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information15     => l_prt_rec.cbr_dsblty_apls_flag,
            p_information260     => l_prt_rec.mn_poe_num,
            p_information261     => l_prt_rec.mx_poe_num,
            p_information13     => l_prt_rec.no_mn_poe_flag,
            p_information14     => l_prt_rec.no_mx_poe_flag,
            p_information12     => l_prt_rec.poe_nnmntry_uom,
            p_information111     => l_prt_rec.prt_attribute1,
            p_information120     => l_prt_rec.prt_attribute10,
            p_information121     => l_prt_rec.prt_attribute11,
            p_information122     => l_prt_rec.prt_attribute12,
            p_information123     => l_prt_rec.prt_attribute13,
            p_information124     => l_prt_rec.prt_attribute14,
            p_information125     => l_prt_rec.prt_attribute15,
            p_information126     => l_prt_rec.prt_attribute16,
            p_information127     => l_prt_rec.prt_attribute17,
            p_information128     => l_prt_rec.prt_attribute18,
            p_information129     => l_prt_rec.prt_attribute19,
            p_information112     => l_prt_rec.prt_attribute2,
            p_information130     => l_prt_rec.prt_attribute20,
            p_information131     => l_prt_rec.prt_attribute21,
            p_information132     => l_prt_rec.prt_attribute22,
            p_information133     => l_prt_rec.prt_attribute23,
            p_information134     => l_prt_rec.prt_attribute24,
            p_information135     => l_prt_rec.prt_attribute25,
            p_information136     => l_prt_rec.prt_attribute26,
            p_information137     => l_prt_rec.prt_attribute27,
            p_information138     => l_prt_rec.prt_attribute28,
            p_information139     => l_prt_rec.prt_attribute29,
            p_information113     => l_prt_rec.prt_attribute3,
            p_information140     => l_prt_rec.prt_attribute30,
            p_information114     => l_prt_rec.prt_attribute4,
            p_information115     => l_prt_rec.prt_attribute5,
            p_information116     => l_prt_rec.prt_attribute6,
            p_information117     => l_prt_rec.prt_attribute7,
            p_information118     => l_prt_rec.prt_attribute8,
            p_information119     => l_prt_rec.prt_attribute9,
            p_information110     => l_prt_rec.prt_attribute_category,
            p_information11     => l_prt_rec.rndg_cd,
            p_information263     => l_prt_rec.rndg_rl,
            p_information262     => l_prt_rec.vrbl_rt_prfl_id,
            p_information265     => l_prt_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_prt_result_id is null then
                  l_out_prt_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_prt_result_id := l_copy_entity_result_id ;
                end if;
                --

                -- Copy Fast Formulas If they are attached to any column --
                ---------------------------------------------------------------
                -- RNDG_RL  -----------------
                ---------------------------------------------------------------

                if l_prt_rec.rndg_rl is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_prt_rec.rndg_rl
                    ,p_business_group_id              =>  l_prt_rec.business_group_id
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
        -- END OF BEN_POE_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PPL_GRP_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_pgr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_ppl_grp_rt_id := l_parent_rec.ppl_grp_rt_id ;
            --
            for l_pgr_rec in c_pgr(l_parent_rec.ppl_grp_rt_id,l_mirror_src_entity_result_id,'PGR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PGR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_people_group_name(l_pgr_rec.people_group_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_pgr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_pgr_rec.effective_start_date
                 and l_pgr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'PGR',
                p_information1     => l_pgr_rec.ppl_grp_rt_id,
                p_information2     => l_pgr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_pgr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_pgr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pgr_rec.excld_flag,
            p_information261     => l_pgr_rec.ordr_num,
            p_information257     => l_pgr_rec.people_group_id,
            p_information111     => l_pgr_rec.pgr_attribute1,
            p_information120     => l_pgr_rec.pgr_attribute10,
            p_information121     => l_pgr_rec.pgr_attribute11,
            p_information122     => l_pgr_rec.pgr_attribute12,
            p_information123     => l_pgr_rec.pgr_attribute13,
            p_information124     => l_pgr_rec.pgr_attribute14,
            p_information125     => l_pgr_rec.pgr_attribute15,
            p_information126     => l_pgr_rec.pgr_attribute16,
            p_information127     => l_pgr_rec.pgr_attribute17,
            p_information128     => l_pgr_rec.pgr_attribute18,
            p_information129     => l_pgr_rec.pgr_attribute19,
            p_information112     => l_pgr_rec.pgr_attribute2,
            p_information130     => l_pgr_rec.pgr_attribute20,
            p_information131     => l_pgr_rec.pgr_attribute21,
            p_information132     => l_pgr_rec.pgr_attribute22,
            p_information133     => l_pgr_rec.pgr_attribute23,
            p_information134     => l_pgr_rec.pgr_attribute24,
            p_information135     => l_pgr_rec.pgr_attribute25,
            p_information136     => l_pgr_rec.pgr_attribute26,
            p_information137     => l_pgr_rec.pgr_attribute27,
            p_information138     => l_pgr_rec.pgr_attribute28,
            p_information139     => l_pgr_rec.pgr_attribute29,
            p_information113     => l_pgr_rec.pgr_attribute3,
            p_information140     => l_pgr_rec.pgr_attribute30,
            p_information114     => l_pgr_rec.pgr_attribute4,
            p_information115     => l_pgr_rec.pgr_attribute5,
            p_information116     => l_pgr_rec.pgr_attribute6,
            p_information117     => l_pgr_rec.pgr_attribute7,
            p_information118     => l_pgr_rec.pgr_attribute8,
            p_information119     => l_pgr_rec.pgr_attribute9,
            p_information110     => l_pgr_rec.pgr_attribute_category,
            p_information262     => l_pgr_rec.vrbl_rt_prfl_id,
            p_information265     => l_pgr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_pgr_result_id is null then
                  l_out_pgr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_pgr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_PPL_GRP_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PSTL_ZIP_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_pzr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_pstl_zip_rt_id := l_parent_rec.pstl_zip_rt_id ;
            --
            for l_pzr_rec in c_pzr(l_parent_rec.pstl_zip_rt_id,l_mirror_src_entity_result_id,'PZR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PZR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_pstl_zip_rng_name(l_pzr_rec.pstl_zip_rng_id
                                                                                    ,p_effective_date)
                                 || ben_plan_design_program_module.get_exclude_message(l_pzr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_pzr_rec.effective_start_date
                 and l_pzr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'PZR',
                p_information1     => l_pzr_rec.pstl_zip_rt_id,
                p_information2     => l_pzr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_pzr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_pzr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pzr_rec.excld_flag,
            p_information260     => l_pzr_rec.ordr_num,
            p_information245     => l_pzr_rec.pstl_zip_rng_id,
            p_information111     => l_pzr_rec.pzr_attribute1,
            p_information120     => l_pzr_rec.pzr_attribute10,
            p_information121     => l_pzr_rec.pzr_attribute11,
            p_information122     => l_pzr_rec.pzr_attribute12,
            p_information123     => l_pzr_rec.pzr_attribute13,
            p_information124     => l_pzr_rec.pzr_attribute14,
            p_information125     => l_pzr_rec.pzr_attribute15,
            p_information126     => l_pzr_rec.pzr_attribute16,
            p_information127     => l_pzr_rec.pzr_attribute17,
            p_information128     => l_pzr_rec.pzr_attribute18,
            p_information129     => l_pzr_rec.pzr_attribute19,
            p_information112     => l_pzr_rec.pzr_attribute2,
            p_information130     => l_pzr_rec.pzr_attribute20,
            p_information131     => l_pzr_rec.pzr_attribute21,
            p_information132     => l_pzr_rec.pzr_attribute22,
            p_information133     => l_pzr_rec.pzr_attribute23,
            p_information134     => l_pzr_rec.pzr_attribute24,
            p_information135     => l_pzr_rec.pzr_attribute25,
            p_information136     => l_pzr_rec.pzr_attribute26,
            p_information137     => l_pzr_rec.pzr_attribute27,
            p_information138     => l_pzr_rec.pzr_attribute28,
            p_information139     => l_pzr_rec.pzr_attribute29,
            p_information113     => l_pzr_rec.pzr_attribute3,
            p_information140     => l_pzr_rec.pzr_attribute30,
            p_information114     => l_pzr_rec.pzr_attribute4,
            p_information115     => l_pzr_rec.pzr_attribute5,
            p_information116     => l_pzr_rec.pzr_attribute6,
            p_information117     => l_pzr_rec.pzr_attribute7,
            p_information118     => l_pzr_rec.pzr_attribute8,
            p_information119     => l_pzr_rec.pzr_attribute9,
            p_information110     => l_pzr_rec.pzr_attribute_category,
            p_information262     => l_pzr_rec.vrbl_rt_prfl_id,
            p_information265     => l_pzr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_pzr_result_id is null then
                  l_out_pzr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_pzr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
              for l_pzr_rec in c_pzr_pstl(l_parent_rec.pstl_zip_rt_id,l_mirror_src_entity_result_id,'PZR') loop
                 create_postal_results
                   (
                    p_validate                    => p_validate
                   ,p_copy_entity_result_id       => l_out_pzr_result_id
                   ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                   ,p_pstl_zip_rng_id             => l_pzr_rec.pstl_zip_rng_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_number_of_copies           => p_number_of_copies
                   ,p_object_version_number       => l_object_version_number
                   ,p_effective_date              => p_effective_date
                   ) ;
              end loop;
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_PSTL_ZIP_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PYRL_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_PYRL_RT_F',100);
         for l_parent_rec  in c_pr__from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_pyrl_rt_id := l_parent_rec.pyrl_rt_id ;
            --
            hr_utility.set_location('l_pyrl_rt_id '||l_pyrl_rt_id,100);
            for l_pr__rec in c_pr_(l_parent_rec.pyrl_rt_id,l_mirror_src_entity_result_id,'PR_') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PR_');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_payroll_name(l_pr__rec.payroll_id
                                                                                 ,p_effective_date)
                                 || ben_plan_design_program_module.get_exclude_message(l_pr__rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_pr__rec.effective_start_date
                 and l_pr__rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;

              -- To store effective_start_date of payroll
              -- for Mapping - Bug 2958658
              --
              l_payroll_start_date := null;
              if l_pr__rec.payroll_id is not null then
                open c_payroll_start_date(l_pr__rec.payroll_id);
                fetch c_payroll_start_date into l_payroll_start_date;
                close c_payroll_start_date;
              end if;

              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the payroll name to display on mapping page.
              --
              open c_get_mapping_name12(l_pr__rec.payroll_id,
                                        NVL(l_payroll_start_date,p_effective_date));
              fetch c_get_mapping_name12 into l_mapping_name;
              close c_get_mapping_name12;
              --
              l_mapping_id   := l_pr__rec.payroll_id;
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
              hr_utility.set_location('l_parent_rec.pyrl_rt_id '||l_parent_rec.pyrl_rt_id,100);
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'PR_',
                p_information1     => l_pr__rec.pyrl_rt_id,
                p_information2     => l_pr__rec.EFFECTIVE_START_DATE,
                p_information3     => l_pr__rec.EFFECTIVE_END_DATE,
                p_information4     => l_pr__rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pr__rec.excld_flag,
            p_information260     => l_pr__rec.ordr_num,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_pr__rec.pr_attribute1,
            p_information120     => l_pr__rec.pr_attribute10,
            p_information121     => l_pr__rec.pr_attribute11,
            p_information122     => l_pr__rec.pr_attribute12,
            p_information123     => l_pr__rec.pr_attribute13,
            p_information124     => l_pr__rec.pr_attribute14,
            p_information125     => l_pr__rec.pr_attribute15,
            p_information126     => l_pr__rec.pr_attribute16,
            p_information127     => l_pr__rec.pr_attribute17,
            p_information128     => l_pr__rec.pr_attribute18,
            p_information129     => l_pr__rec.pr_attribute19,
            p_information112     => l_pr__rec.pr_attribute2,
            p_information130     => l_pr__rec.pr_attribute20,
            p_information131     => l_pr__rec.pr_attribute21,
            p_information132     => l_pr__rec.pr_attribute22,
            p_information133     => l_pr__rec.pr_attribute23,
            p_information134     => l_pr__rec.pr_attribute24,
            p_information135     => l_pr__rec.pr_attribute25,
            p_information136     => l_pr__rec.pr_attribute26,
            p_information137     => l_pr__rec.pr_attribute27,
            p_information138     => l_pr__rec.pr_attribute28,
            p_information139     => l_pr__rec.pr_attribute29,
            p_information113     => l_pr__rec.pr_attribute3,
            p_information140     => l_pr__rec.pr_attribute30,
            p_information114     => l_pr__rec.pr_attribute4,
            p_information115     => l_pr__rec.pr_attribute5,
            p_information116     => l_pr__rec.pr_attribute6,
            p_information117     => l_pr__rec.pr_attribute7,
            p_information118     => l_pr__rec.pr_attribute8,
            p_information119     => l_pr__rec.pr_attribute9,
            p_information110     => l_pr__rec.pr_attribute_category,
            p_information262     => l_pr__rec.vrbl_rt_prfl_id,
            p_information166     => l_payroll_start_date,
            p_information265     => l_pr__rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_pr__result_id is null then
                 l_out_pr__result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_pr__result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_PYRL_RT_F',100);
        ---------------------------------------------------------------
        -- END OF BEN_PYRL_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_PY_BSS_RT_F ----------------------
         ---------------------------------------------------------------
         --
         hr_utility.set_location('START OF BEN_PY_BSS_RT_F ',100);
         for l_parent_rec  in c_pbr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_py_bss_rt_id := l_parent_rec.py_bss_rt_id ;
            --
            hr_utility.set_location('l_py_bss_rt_id '||l_py_bss_rt_id,100);
            for l_pbr_rec in c_pbr(l_parent_rec.py_bss_rt_id,l_mirror_src_entity_result_id,'PBR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('PBR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_pay_basis_name(l_pbr_rec.pay_basis_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_pbr_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_pbr_rec.effective_start_date
                 and l_pbr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
--PADMAJA
              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the pay_basis name to display on mapping page.
              --
              open c_get_mapping_name13(l_pbr_rec.pay_basis_id);
              fetch c_get_mapping_name13 into l_mapping_name;
              close c_get_mapping_name13;
              --
              l_mapping_id   := l_pbr_rec.pay_basis_id;
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
              hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
              hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
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
		P_TABLE_ALIAS                    => 'PBR',
                p_information1     => l_pbr_rec.py_bss_rt_id,
                p_information2     => l_pbr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_pbr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_pbr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pbr_rec.excld_flag,
            p_information257     => l_pbr_rec.ordr_num,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_pbr_rec.pbr_attribute1,
            p_information120     => l_pbr_rec.pbr_attribute10,
            p_information121     => l_pbr_rec.pbr_attribute11,
            p_information122     => l_pbr_rec.pbr_attribute12,
            p_information123     => l_pbr_rec.pbr_attribute13,
            p_information124     => l_pbr_rec.pbr_attribute14,
            p_information125     => l_pbr_rec.pbr_attribute15,
            p_information126     => l_pbr_rec.pbr_attribute16,
            p_information127     => l_pbr_rec.pbr_attribute17,
            p_information128     => l_pbr_rec.pbr_attribute18,
            p_information129     => l_pbr_rec.pbr_attribute19,
            p_information112     => l_pbr_rec.pbr_attribute2,
            p_information130     => l_pbr_rec.pbr_attribute20,
            p_information131     => l_pbr_rec.pbr_attribute21,
            p_information132     => l_pbr_rec.pbr_attribute22,
            p_information133     => l_pbr_rec.pbr_attribute23,
            p_information134     => l_pbr_rec.pbr_attribute24,
            p_information135     => l_pbr_rec.pbr_attribute25,
            p_information136     => l_pbr_rec.pbr_attribute26,
            p_information137     => l_pbr_rec.pbr_attribute27,
            p_information138     => l_pbr_rec.pbr_attribute28,
            p_information139     => l_pbr_rec.pbr_attribute29,
            p_information113     => l_pbr_rec.pbr_attribute3,
            p_information140     => l_pbr_rec.pbr_attribute30,
            p_information114     => l_pbr_rec.pbr_attribute4,
            p_information115     => l_pbr_rec.pbr_attribute5,
            p_information116     => l_pbr_rec.pbr_attribute6,
            p_information117     => l_pbr_rec.pbr_attribute7,
            p_information118     => l_pbr_rec.pbr_attribute8,
            p_information119     => l_pbr_rec.pbr_attribute9,
            p_information110     => l_pbr_rec.pbr_attribute_category,
            p_information262     => l_pbr_rec.vrbl_rt_prfl_id,
            p_information166     => NULL,  -- No ESD for Pay Basis
            p_information265     => l_pbr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_pbr_result_id is null then
                  l_out_pbr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_pbr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
         hr_utility.set_location('END OF BEN_PY_BSS_RT_F ',100);
        ---------------------------------------------------------------
        -- END OF BEN_PY_BSS_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_SCHEDD_HRS_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_shr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_schedd_hrs_rt_id := l_parent_rec.schedd_hrs_rt_id ;
            --
            for l_shr_rec in c_shr(l_parent_rec.schedd_hrs_rt_id,l_mirror_src_entity_result_id,'SHR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('SHR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_shr_rec.hrs_num ||' - ' || l_shr_rec.max_hrs_num ||' '||
                                 hr_general.decode_lookup('FREQUENCY',l_shr_rec.freq_cd)
                                 || ben_plan_design_program_module.get_exclude_message(l_shr_rec.excld_flag); --'Intersection';
              --
              if p_effective_date between l_shr_rec.effective_start_date
                 and l_shr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'SHR',
                p_information1     => l_shr_rec.schedd_hrs_rt_id,
                p_information2     => l_shr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_shr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_shr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_shr_rec.determination_cd,
            p_information259     => l_shr_rec.determination_rl,
            p_information13     => l_shr_rec.excld_flag,
            p_information14     => l_shr_rec.freq_cd,
            p_information288     => l_shr_rec.hrs_num,
            p_information287     => l_shr_rec.max_hrs_num,
            p_information260     => l_shr_rec.ordr_num,
            p_information11     => l_shr_rec.rounding_cd,
            p_information257     => l_shr_rec.rounding_rl,
            p_information258     => l_shr_rec.schedd_hrs_rl,
            p_information111     => l_shr_rec.shr_attribute1,
            p_information120     => l_shr_rec.shr_attribute10,
            p_information121     => l_shr_rec.shr_attribute11,
            p_information122     => l_shr_rec.shr_attribute12,
            p_information123     => l_shr_rec.shr_attribute13,
            p_information124     => l_shr_rec.shr_attribute14,
            p_information125     => l_shr_rec.shr_attribute15,
            p_information126     => l_shr_rec.shr_attribute16,
            p_information127     => l_shr_rec.shr_attribute17,
            p_information128     => l_shr_rec.shr_attribute18,
            p_information129     => l_shr_rec.shr_attribute19,
            p_information112     => l_shr_rec.shr_attribute2,
            p_information130     => l_shr_rec.shr_attribute20,
            p_information131     => l_shr_rec.shr_attribute21,
            p_information132     => l_shr_rec.shr_attribute22,
            p_information133     => l_shr_rec.shr_attribute23,
            p_information134     => l_shr_rec.shr_attribute24,
            p_information135     => l_shr_rec.shr_attribute25,
            p_information136     => l_shr_rec.shr_attribute26,
            p_information137     => l_shr_rec.shr_attribute27,
            p_information138     => l_shr_rec.shr_attribute28,
            p_information139     => l_shr_rec.shr_attribute29,
            p_information113     => l_shr_rec.shr_attribute3,
            p_information140     => l_shr_rec.shr_attribute30,
            p_information114     => l_shr_rec.shr_attribute4,
            p_information115     => l_shr_rec.shr_attribute5,
            p_information116     => l_shr_rec.shr_attribute6,
            p_information117     => l_shr_rec.shr_attribute7,
            p_information118     => l_shr_rec.shr_attribute8,
            p_information119     => l_shr_rec.shr_attribute9,
            p_information110     => l_shr_rec.shr_attribute_category,
            p_information262     => l_shr_rec.vrbl_rt_prfl_id,
            p_information265     => l_shr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_shr_result_id is null then
                  l_out_shr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_shr_result_id := l_copy_entity_result_id ;
                end if;
                --

               ---------------------------------------------------------------
               -- DETERMINATION_RL --
               ---------------------------------------------------------------
               --
               if l_shr_rec.determination_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_shr_rec.determination_rl
                                    ,p_business_group_id              =>  l_shr_rec.business_group_id
                                    ,p_number_of_copies               =>  l_number_of_copies
                                    ,p_object_version_number          =>  l_object_version_number
                                    ,p_effective_date                 =>  p_effective_date
                                    );

                                    --
               end if;
               --

               ---------------------------------------------------------------
               -- ROUNDING_RL --
               ---------------------------------------------------------------
               --
               if l_shr_rec.rounding_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_shr_rec.rounding_rl
                                    ,p_business_group_id              =>  l_shr_rec.business_group_id
                                    ,p_number_of_copies               =>  l_number_of_copies
                                    ,p_object_version_number          =>  l_object_version_number
                                    ,p_effective_date                 =>  p_effective_date
                                    );

                                    --
               end if;
               ---------------------------------------------------------------
               -- SCHEDD_HRS_RL --
               ---------------------------------------------------------------
               --
               if l_shr_rec.schedd_hrs_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_shr_rec.schedd_hrs_rl
                                    ,p_business_group_id              =>  l_shr_rec.business_group_id
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
        -- END OF BEN_SCHEDD_HRS_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_SVC_AREA_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_sar_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;
            --
            l_svc_area_rt_id := l_parent_rec.svc_area_rt_id ;
            --
            for l_sar_rec in c_sar(l_parent_rec.svc_area_rt_id,l_mirror_src_entity_result_id,'SAR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('SAR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_svc_area_name(l_sar_rec.svc_area_id
                                                                                  ,p_effective_date)
                                 || ben_plan_design_program_module.get_exclude_message(l_sar_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_sar_rec.effective_start_date
                 and l_sar_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'SAR',
                p_information1     => l_sar_rec.svc_area_rt_id,
                p_information2     => l_sar_rec.EFFECTIVE_START_DATE,
                p_information3     => l_sar_rec.EFFECTIVE_END_DATE,
                p_information4     => l_sar_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_sar_rec.excld_flag,
            p_information259     => l_sar_rec.ordr_num,
            p_information111     => l_sar_rec.sar_attribute1,
            p_information120     => l_sar_rec.sar_attribute10,
            p_information121     => l_sar_rec.sar_attribute11,
            p_information122     => l_sar_rec.sar_attribute12,
            p_information123     => l_sar_rec.sar_attribute13,
            p_information124     => l_sar_rec.sar_attribute14,
            p_information125     => l_sar_rec.sar_attribute15,
            p_information126     => l_sar_rec.sar_attribute16,
            p_information127     => l_sar_rec.sar_attribute17,
            p_information128     => l_sar_rec.sar_attribute18,
            p_information129     => l_sar_rec.sar_attribute19,
            p_information112     => l_sar_rec.sar_attribute2,
            p_information130     => l_sar_rec.sar_attribute20,
            p_information131     => l_sar_rec.sar_attribute21,
            p_information132     => l_sar_rec.sar_attribute22,
            p_information133     => l_sar_rec.sar_attribute23,
            p_information134     => l_sar_rec.sar_attribute24,
            p_information135     => l_sar_rec.sar_attribute25,
            p_information136     => l_sar_rec.sar_attribute26,
            p_information137     => l_sar_rec.sar_attribute27,
            p_information138     => l_sar_rec.sar_attribute28,
            p_information139     => l_sar_rec.sar_attribute29,
            p_information113     => l_sar_rec.sar_attribute3,
            p_information140     => l_sar_rec.sar_attribute30,
            p_information114     => l_sar_rec.sar_attribute4,
            p_information115     => l_sar_rec.sar_attribute5,
            p_information116     => l_sar_rec.sar_attribute6,
            p_information117     => l_sar_rec.sar_attribute7,
            p_information118     => l_sar_rec.sar_attribute8,
            p_information119     => l_sar_rec.sar_attribute9,
            p_information110     => l_sar_rec.sar_attribute_category,
            p_information241     => l_sar_rec.svc_area_id,
            p_information262     => l_sar_rec.vrbl_rt_prfl_id,
            p_information265     => l_sar_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_sar_result_id is null then
                  l_out_sar_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_sar_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
             for l_sar_rec in c_sar_srv(l_parent_rec.svc_area_rt_id,l_mirror_src_entity_result_id,'SAR') loop
                   ben_pd_rate_and_cvg_module.create_service_results
                      (
                       p_validate                => p_validate
                      ,p_copy_entity_result_id   => l_out_sar_result_id
                      ,p_copy_entity_txn_id      => p_copy_entity_txn_id
                      ,p_svc_area_id             => l_sar_rec.svc_area_id
                      ,p_business_group_id       => p_business_group_id
                      ,p_number_of_copies        => p_number_of_copies
                      ,p_object_version_number   => l_object_version_number
                      ,p_effective_date          => p_effective_date
                      );
             end loop;
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_SVC_AREA_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_TBCO_USE_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_tur_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_tbco_use_rt_id := l_parent_rec.tbco_use_rt_id ;
            --
            for l_tur_rec in c_tur(l_parent_rec.tbco_use_rt_id,l_mirror_src_entity_result_id,'TUR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('TUR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('TOBACCO_USER',l_tur_rec.uses_tbco_flag)
                                 || ben_plan_design_program_module.get_exclude_message(l_tur_rec.excld_flag);
                                 --Intersection';
              --
              if p_effective_date between l_tur_rec.effective_start_date
                 and l_tur_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'TUR',
                p_information1     => l_tur_rec.tbco_use_rt_id,
                p_information2     => l_tur_rec.EFFECTIVE_START_DATE,
                p_information3     => l_tur_rec.EFFECTIVE_END_DATE,
                p_information4     => l_tur_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_tur_rec.excld_flag,
            p_information257     => l_tur_rec.ordr_num,
            p_information111     => l_tur_rec.tur_attribute1,
            p_information120     => l_tur_rec.tur_attribute10,
            p_information121     => l_tur_rec.tur_attribute11,
            p_information122     => l_tur_rec.tur_attribute12,
            p_information123     => l_tur_rec.tur_attribute13,
            p_information124     => l_tur_rec.tur_attribute14,
            p_information125     => l_tur_rec.tur_attribute15,
            p_information126     => l_tur_rec.tur_attribute16,
            p_information127     => l_tur_rec.tur_attribute17,
            p_information128     => l_tur_rec.tur_attribute18,
            p_information129     => l_tur_rec.tur_attribute19,
            p_information112     => l_tur_rec.tur_attribute2,
            p_information130     => l_tur_rec.tur_attribute20,
            p_information131     => l_tur_rec.tur_attribute21,
            p_information132     => l_tur_rec.tur_attribute22,
            p_information133     => l_tur_rec.tur_attribute23,
            p_information134     => l_tur_rec.tur_attribute24,
            p_information135     => l_tur_rec.tur_attribute25,
            p_information136     => l_tur_rec.tur_attribute26,
            p_information137     => l_tur_rec.tur_attribute27,
            p_information138     => l_tur_rec.tur_attribute28,
            p_information139     => l_tur_rec.tur_attribute29,
            p_information113     => l_tur_rec.tur_attribute3,
            p_information140     => l_tur_rec.tur_attribute30,
            p_information114     => l_tur_rec.tur_attribute4,
            p_information115     => l_tur_rec.tur_attribute5,
            p_information116     => l_tur_rec.tur_attribute6,
            p_information117     => l_tur_rec.tur_attribute7,
            p_information118     => l_tur_rec.tur_attribute8,
            p_information119     => l_tur_rec.tur_attribute9,
            p_information110     => l_tur_rec.tur_attribute_category,
            p_information12     => l_tur_rec.uses_tbco_flag,
            p_information262     => l_tur_rec.vrbl_rt_prfl_id,
            p_information265     => l_tur_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_tur_result_id is null then
                  l_out_tur_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_tur_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_TBCO_USE_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_TTL_CVG_VOL_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_tcv_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_ttl_cvg_vol_rt_id := l_parent_rec.ttl_cvg_vol_rt_id ;
            --
            for l_tcv_rec in c_tcv(l_parent_rec.ttl_cvg_vol_rt_id,l_mirror_src_entity_result_id,'TCV') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('TCV');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_tcv_rec.mn_cvg_vol_amt || ' - ' ||l_tcv_rec.mx_cvg_vol_amt
                                 || ben_plan_design_program_module.get_exclude_message(l_tcv_rec.excld_flag);
                                --'Intersection';
              --
              if p_effective_date between l_tcv_rec.effective_start_date
                 and l_tcv_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'TCV',
                p_information1     => l_tcv_rec.ttl_cvg_vol_rt_id,
                p_information2     => l_tcv_rec.EFFECTIVE_START_DATE,
                p_information3     => l_tcv_rec.EFFECTIVE_END_DATE,
                p_information4     => l_tcv_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information14     => l_tcv_rec.cvg_vol_det_cd,
            p_information261     => l_tcv_rec.cvg_vol_det_rl,
            p_information11     => l_tcv_rec.excld_flag,
            p_information293     => l_tcv_rec.mn_cvg_vol_amt,
            p_information294     => l_tcv_rec.mx_cvg_vol_amt,
            p_information12     => l_tcv_rec.no_mn_cvg_vol_amt_apls_flag,
            p_information13     => l_tcv_rec.no_mx_cvg_vol_amt_apls_flag,
            p_information260     => l_tcv_rec.ordr_num,
            p_information111     => l_tcv_rec.tcv_attribute1,
            p_information120     => l_tcv_rec.tcv_attribute10,
            p_information121     => l_tcv_rec.tcv_attribute11,
            p_information122     => l_tcv_rec.tcv_attribute12,
            p_information123     => l_tcv_rec.tcv_attribute13,
            p_information124     => l_tcv_rec.tcv_attribute14,
            p_information125     => l_tcv_rec.tcv_attribute15,
            p_information126     => l_tcv_rec.tcv_attribute16,
            p_information127     => l_tcv_rec.tcv_attribute17,
            p_information128     => l_tcv_rec.tcv_attribute18,
            p_information129     => l_tcv_rec.tcv_attribute19,
            p_information112     => l_tcv_rec.tcv_attribute2,
            p_information130     => l_tcv_rec.tcv_attribute20,
            p_information131     => l_tcv_rec.tcv_attribute21,
            p_information132     => l_tcv_rec.tcv_attribute22,
            p_information133     => l_tcv_rec.tcv_attribute23,
            p_information134     => l_tcv_rec.tcv_attribute24,
            p_information135     => l_tcv_rec.tcv_attribute25,
            p_information136     => l_tcv_rec.tcv_attribute26,
            p_information137     => l_tcv_rec.tcv_attribute27,
            p_information138     => l_tcv_rec.tcv_attribute28,
            p_information139     => l_tcv_rec.tcv_attribute29,
            p_information113     => l_tcv_rec.tcv_attribute3,
            p_information140     => l_tcv_rec.tcv_attribute30,
            p_information114     => l_tcv_rec.tcv_attribute4,
            p_information115     => l_tcv_rec.tcv_attribute5,
            p_information116     => l_tcv_rec.tcv_attribute6,
            p_information117     => l_tcv_rec.tcv_attribute7,
            p_information118     => l_tcv_rec.tcv_attribute8,
            p_information119     => l_tcv_rec.tcv_attribute9,
            p_information110     => l_tcv_rec.tcv_attribute_category,
            p_information262     => l_tcv_rec.vrbl_rt_prfl_id,
            p_information265     => l_tcv_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_tcv_result_id is null then
                  l_out_tcv_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_tcv_result_id := l_copy_entity_result_id ;
                end if;
                --
                -- Copy Fast Formulas if any are attached to any column --

                ---------------------------------------------------------------
                -- CVG_VOL_DET_RL -----------------
                ---------------------------------------------------------------

                if l_tcv_rec.cvg_vol_det_rl is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_tcv_rec.cvg_vol_det_rl
                    ,p_business_group_id              =>  l_tcv_rec.business_group_id
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
        -- END OF BEN_TTL_CVG_VOL_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_TTL_PRTT_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_ttp_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_ttl_prtt_rt_id := l_parent_rec.ttl_prtt_rt_id ;
            --
            for l_ttp_rec in c_ttp(l_parent_rec.ttl_prtt_rt_id,l_mirror_src_entity_result_id,'TTP') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('TTP');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_ttp_rec.mn_prtt_num ||' - '||l_ttp_rec.mx_prtt_num
                                 || ben_plan_design_program_module.get_exclude_message(l_ttp_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_ttp_rec.effective_start_date
                 and l_ttp_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'TTP',
                p_information1     => l_ttp_rec.ttl_prtt_rt_id,
                p_information2     => l_ttp_rec.EFFECTIVE_START_DATE,
                p_information3     => l_ttp_rec.EFFECTIVE_END_DATE,
                p_information4     => l_ttp_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_ttp_rec.excld_flag,
            p_information261     => l_ttp_rec.mn_prtt_num,
            p_information263     => l_ttp_rec.mx_prtt_num,
            p_information12     => l_ttp_rec.no_mn_prtt_num_apls_flag,
            p_information13     => l_ttp_rec.no_mx_prtt_num_apls_flag,
            p_information260     => l_ttp_rec.ordr_num,
            p_information14     => l_ttp_rec.prtt_det_cd,
            p_information264     => l_ttp_rec.prtt_det_rl,
            p_information111     => l_ttp_rec.ttp_attribute1,
            p_information120     => l_ttp_rec.ttp_attribute10,
            p_information121     => l_ttp_rec.ttp_attribute11,
            p_information122     => l_ttp_rec.ttp_attribute12,
            p_information123     => l_ttp_rec.ttp_attribute13,
            p_information124     => l_ttp_rec.ttp_attribute14,
            p_information125     => l_ttp_rec.ttp_attribute15,
            p_information126     => l_ttp_rec.ttp_attribute16,
            p_information127     => l_ttp_rec.ttp_attribute17,
            p_information128     => l_ttp_rec.ttp_attribute18,
            p_information129     => l_ttp_rec.ttp_attribute19,
            p_information112     => l_ttp_rec.ttp_attribute2,
            p_information130     => l_ttp_rec.ttp_attribute20,
            p_information131     => l_ttp_rec.ttp_attribute21,
            p_information132     => l_ttp_rec.ttp_attribute22,
            p_information133     => l_ttp_rec.ttp_attribute23,
            p_information134     => l_ttp_rec.ttp_attribute24,
            p_information135     => l_ttp_rec.ttp_attribute25,
            p_information136     => l_ttp_rec.ttp_attribute26,
            p_information137     => l_ttp_rec.ttp_attribute27,
            p_information138     => l_ttp_rec.ttp_attribute28,
            p_information139     => l_ttp_rec.ttp_attribute29,
            p_information113     => l_ttp_rec.ttp_attribute3,
            p_information140     => l_ttp_rec.ttp_attribute30,
            p_information114     => l_ttp_rec.ttp_attribute4,
            p_information115     => l_ttp_rec.ttp_attribute5,
            p_information116     => l_ttp_rec.ttp_attribute6,
            p_information117     => l_ttp_rec.ttp_attribute7,
            p_information118     => l_ttp_rec.ttp_attribute8,
            p_information119     => l_ttp_rec.ttp_attribute9,
            p_information110     => l_ttp_rec.ttp_attribute_category,
            p_information262     => l_ttp_rec.vrbl_rt_prfl_id,
            p_information265     => l_ttp_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_ttp_result_id is null then
                  l_out_ttp_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_ttp_result_id := l_copy_entity_result_id ;
                end if;
                --

                -- Copy Fast Formulas if they are attached to any column --
                ---------------------------------------------------------------
                -- PRTT_DET_RL -----------------
                ---------------------------------------------------------------

                if l_ttp_rec.prtt_det_rl is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_ttp_rec.prtt_det_rl
                    ,p_business_group_id              =>  l_ttp_rec.business_group_id
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
        -- END OF BEN_TTL_PRTT_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_VRBL_MTCHG_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_vmr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_vrbl_mtchg_rt_id := l_parent_rec.vrbl_mtchg_rt_id ;
            --
            for l_vmr_rec in c_vmr(l_parent_rec.vrbl_mtchg_rt_id,l_mirror_src_entity_result_id,'VMR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('VMR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_vmr_rec.from_pct_val ||' - '|| l_vmr_rec.to_pct_val; --'Intersection';
              --
              if p_effective_date between l_vmr_rec.effective_start_date
                 and l_vmr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'VMR',
                p_information1     => l_vmr_rec.vrbl_mtchg_rt_id,
                p_information2     => l_vmr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_vmr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_vmr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_vmr_rec.cntnu_mtch_aftr_max_rl_flag,
            p_information287     => l_vmr_rec.from_pct_val,
            p_information295     => l_vmr_rec.mn_mtch_amt,
            p_information261     => l_vmr_rec.mtchg_rt_calc_rl,
            p_information294     => l_vmr_rec.mx_amt_of_py_num,
            p_information293     => l_vmr_rec.mx_mtch_amt,
            p_information289     => l_vmr_rec.mx_pct_of_py_num,
            p_information14     => l_vmr_rec.no_mx_amt_of_py_num_flag,
            p_information11     => l_vmr_rec.no_mx_mtch_amt_flag,
            p_information13     => l_vmr_rec.no_mx_pct_of_py_num_flag,
            p_information257     => l_vmr_rec.ordr_num,
            p_information290     => l_vmr_rec.pct_val,
            p_information288     => l_vmr_rec.to_pct_val,
            p_information111     => l_vmr_rec.vmr_attribute1,
            p_information120     => l_vmr_rec.vmr_attribute10,
            p_information121     => l_vmr_rec.vmr_attribute11,
            p_information122     => l_vmr_rec.vmr_attribute12,
            p_information123     => l_vmr_rec.vmr_attribute13,
            p_information124     => l_vmr_rec.vmr_attribute14,
            p_information125     => l_vmr_rec.vmr_attribute15,
            p_information126     => l_vmr_rec.vmr_attribute16,
            p_information127     => l_vmr_rec.vmr_attribute17,
            p_information128     => l_vmr_rec.vmr_attribute18,
            p_information129     => l_vmr_rec.vmr_attribute19,
            p_information112     => l_vmr_rec.vmr_attribute2,
            p_information130     => l_vmr_rec.vmr_attribute20,
            p_information131     => l_vmr_rec.vmr_attribute21,
            p_information132     => l_vmr_rec.vmr_attribute22,
            p_information133     => l_vmr_rec.vmr_attribute23,
            p_information134     => l_vmr_rec.vmr_attribute24,
            p_information135     => l_vmr_rec.vmr_attribute25,
            p_information136     => l_vmr_rec.vmr_attribute26,
            p_information137     => l_vmr_rec.vmr_attribute27,
            p_information138     => l_vmr_rec.vmr_attribute28,
            p_information139     => l_vmr_rec.vmr_attribute29,
            p_information113     => l_vmr_rec.vmr_attribute3,
            p_information140     => l_vmr_rec.vmr_attribute30,
            p_information114     => l_vmr_rec.vmr_attribute4,
            p_information115     => l_vmr_rec.vmr_attribute5,
            p_information116     => l_vmr_rec.vmr_attribute6,
            p_information117     => l_vmr_rec.vmr_attribute7,
            p_information118     => l_vmr_rec.vmr_attribute8,
            p_information119     => l_vmr_rec.vmr_attribute9,
            p_information110     => l_vmr_rec.vmr_attribute_category,
            p_information262     => l_vmr_rec.vrbl_rt_prfl_id,
            p_information265     => l_vmr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_vmr_result_id is null then
                  l_out_vmr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_vmr_result_id := l_copy_entity_result_id ;
                end if;
                --

                -- Copy Fast Formulas if any are attached to any column --
                ---------------------------------------------------------------
                -- MTCHG_RT_CALC_RL -----------------
                ---------------------------------------------------------------

                if l_vmr_rec.mtchg_rt_calc_rl is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_vmr_rec.mtchg_rt_calc_rl
                    ,p_business_group_id              =>  l_vmr_rec.business_group_id
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
        -- END OF BEN_VRBL_MTCHG_RT_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_VRBL_RT_PRFL_RL_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_vpr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_vrbl_rt_prfl_rl_id := l_parent_rec.vrbl_rt_prfl_rl_id ;
            --
            for l_vpr_rec in c_vpr(l_parent_rec.vrbl_rt_prfl_rl_id,l_mirror_src_entity_result_id,'VPR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('VPR');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_formula_name(l_vpr_rec.formula_id,p_effective_date);
                                  --'Intersection';
              --
              if p_effective_date between l_vpr_rec.effective_start_date
                 and l_vpr_rec.effective_end_date then
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
		P_TABLE_ALIAS                    => 'VPR',
                p_information1     => l_vpr_rec.vrbl_rt_prfl_rl_id,
                p_information2     => l_vpr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_vpr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_vpr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_vpr_rec.drvbl_fctr_apls_flag,
            p_information251     => l_vpr_rec.formula_id,
            p_information260     => l_vpr_rec.ordr_to_aply_num,
            p_information111     => l_vpr_rec.vpr_attribute1,
            p_information120     => l_vpr_rec.vpr_attribute10,
            p_information121     => l_vpr_rec.vpr_attribute11,
            p_information122     => l_vpr_rec.vpr_attribute12,
            p_information123     => l_vpr_rec.vpr_attribute13,
            p_information124     => l_vpr_rec.vpr_attribute14,
            p_information125     => l_vpr_rec.vpr_attribute15,
            p_information126     => l_vpr_rec.vpr_attribute16,
            p_information127     => l_vpr_rec.vpr_attribute17,
            p_information128     => l_vpr_rec.vpr_attribute18,
            p_information129     => l_vpr_rec.vpr_attribute19,
            p_information112     => l_vpr_rec.vpr_attribute2,
            p_information130     => l_vpr_rec.vpr_attribute20,
            p_information131     => l_vpr_rec.vpr_attribute21,
            p_information132     => l_vpr_rec.vpr_attribute22,
            p_information133     => l_vpr_rec.vpr_attribute23,
            p_information134     => l_vpr_rec.vpr_attribute24,
            p_information135     => l_vpr_rec.vpr_attribute25,
            p_information136     => l_vpr_rec.vpr_attribute26,
            p_information137     => l_vpr_rec.vpr_attribute27,
            p_information138     => l_vpr_rec.vpr_attribute28,
            p_information139     => l_vpr_rec.vpr_attribute29,
            p_information113     => l_vpr_rec.vpr_attribute3,
            p_information140     => l_vpr_rec.vpr_attribute30,
            p_information114     => l_vpr_rec.vpr_attribute4,
            p_information115     => l_vpr_rec.vpr_attribute5,
            p_information116     => l_vpr_rec.vpr_attribute6,
            p_information117     => l_vpr_rec.vpr_attribute7,
            p_information118     => l_vpr_rec.vpr_attribute8,
            p_information119     => l_vpr_rec.vpr_attribute9,
            p_information110     => l_vpr_rec.vpr_attribute_category,
            p_information262     => l_vpr_rec.vrbl_rt_prfl_id,
            p_information265     => l_vpr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_vpr_result_id is null then
                  l_out_vpr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_vpr_result_id := l_copy_entity_result_id ;
                end if;
                --

                -- Copy Fast Formulas if any are attached to any column --
                ---------------------------------------------------------------
                -- FORMULA_ID -----------------
                ---------------------------------------------------------------

                if l_vpr_rec.formula_id is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_vpr_rec.formula_id
                    ,p_business_group_id              =>  l_vpr_rec.business_group_id
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
        -- END OF BEN_VRBL_RT_PRFL_RL_F ----------------------
        ---------------------------------------------------------------
         ---------------------------------------------------------------
         -- START OF BEN_WK_LOC_RT_F ----------------------
         ---------------------------------------------------------------
         --
         for l_parent_rec  in c_wlr_from_parent(l_VRBL_RT_PRFL_ID) loop
            --
            l_mirror_src_entity_result_id := l_out_vpf_result_id ;

            --
            l_wk_loc_rt_id := l_parent_rec.wk_loc_rt_id ;
            --
            for l_wlr_rec in c_wlr(l_parent_rec.wk_loc_rt_id,l_mirror_src_entity_result_id,'WLR') loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('WLR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := ben_plan_design_program_module.get_location_name(l_wlr_rec.location_id)
                                 || ben_plan_design_program_module.get_exclude_message(l_wlr_rec.excld_flag);
                                 -- 'Intersection';
              --
              if p_effective_date between l_wlr_rec.effective_start_date
                 and l_wlr_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;

              -- To store effective_start_date of location
              -- for Mapping - Bug 2958658
              --
              l_location_inactive_date := null;
              if l_wlr_rec.location_id is not null then
                open c_location_inactive_date(l_wlr_rec.location_id);
                fetch c_location_inactive_date into l_location_inactive_date;
                close c_location_inactive_date;
              end if;

              --
              -- pabodla : MAPPING DATA : Store the mapping column information.
              --

              l_mapping_name := null;
              l_mapping_id   := null;
              --
              -- Get the location name to display on mapping page.
              --
              open c_get_mapping_name10(l_wlr_rec.location_id,
                                        NVL(l_location_inactive_date,p_effective_date));
              fetch c_get_mapping_name10 into l_mapping_name;
              close c_get_mapping_name10;
              --
              l_mapping_id   := l_wlr_rec.location_id;
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
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'WLR',
                p_information1     => l_wlr_rec.wk_loc_rt_id,
                p_information2     => l_wlr_rec.EFFECTIVE_START_DATE,
                p_information3     => l_wlr_rec.EFFECTIVE_END_DATE,
                p_information4     => l_wlr_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_wlr_rec.excld_flag,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information260     => l_wlr_rec.ordr_num,
            p_information262     => l_wlr_rec.vrbl_rt_prfl_id,
            p_information111     => l_wlr_rec.wlr_attribute1,
            p_information120     => l_wlr_rec.wlr_attribute10,
            p_information121     => l_wlr_rec.wlr_attribute11,
            p_information122     => l_wlr_rec.wlr_attribute12,
            p_information123     => l_wlr_rec.wlr_attribute13,
            p_information124     => l_wlr_rec.wlr_attribute14,
            p_information125     => l_wlr_rec.wlr_attribute15,
            p_information126     => l_wlr_rec.wlr_attribute16,
            p_information127     => l_wlr_rec.wlr_attribute17,
            p_information128     => l_wlr_rec.wlr_attribute18,
            p_information129     => l_wlr_rec.wlr_attribute19,
            p_information112     => l_wlr_rec.wlr_attribute2,
            p_information130     => l_wlr_rec.wlr_attribute20,
            p_information131     => l_wlr_rec.wlr_attribute21,
            p_information132     => l_wlr_rec.wlr_attribute22,
            p_information133     => l_wlr_rec.wlr_attribute23,
            p_information134     => l_wlr_rec.wlr_attribute24,
            p_information135     => l_wlr_rec.wlr_attribute25,
            p_information136     => l_wlr_rec.wlr_attribute26,
            p_information137     => l_wlr_rec.wlr_attribute27,
            p_information138     => l_wlr_rec.wlr_attribute28,
            p_information139     => l_wlr_rec.wlr_attribute29,
            p_information113     => l_wlr_rec.wlr_attribute3,
            p_information140     => l_wlr_rec.wlr_attribute30,
            p_information114     => l_wlr_rec.wlr_attribute4,
            p_information115     => l_wlr_rec.wlr_attribute5,
            p_information116     => l_wlr_rec.wlr_attribute6,
            p_information117     => l_wlr_rec.wlr_attribute7,
            p_information118     => l_wlr_rec.wlr_attribute8,
            p_information119     => l_wlr_rec.wlr_attribute9,
            p_information110     => l_wlr_rec.wlr_attribute_category,
            p_information166     => l_location_inactive_date,
            p_information265     => l_wlr_rec.object_version_number,
           --

                p_object_version_number          => l_object_version_number,
                p_effective_date                 => p_effective_date       );
                --

                if l_out_wlr_result_id is null then
                  l_out_wlr_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_wlr_result_id := l_copy_entity_result_id ;
                end if;
                --
             end loop;
             --
           end loop;
        ---------------------------------------------------------------
        -- END OF BEN_WK_LOC_RT_F ----------------------
        ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_COMPTNCY_RT_F ----------------------
        ---------------------------------------------------------------
        --
        hr_utility.set_location('START OF BEN_COMPTNCY_RT_F',100);
        for l_parent_rec  in c_cty_from_parent(l_VRBL_RT_PRFL_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_vpf_result_id ;

           --
           l_comptncy_rt_id := l_parent_rec.comptncy_rt_id ;
           --
           for l_cty_rec in c_cty(l_parent_rec.comptncy_rt_id,l_mirror_src_entity_result_id,'CTY') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('CTY');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_competence_rating_name
                                (l_cty_rec.competence_id
                                ,l_cty_rec.rating_level_id)
                                || ben_plan_design_program_module.get_exclude_message(l_cty_rec.excld_flag);
                                -- 'Intersection';
             --
             if p_effective_date between l_cty_rec.effective_start_date
                and l_cty_rec.effective_end_date then
              --
                l_result_type_cd := 'DISPLAY';
             else
                l_result_type_cd := 'NO DISPLAY';
             end if;
             --

             -- To store effective_start_date of competence
             -- for Mapping - Bug 2958658
             --
             l_competence_start_date := null;
             if l_cty_rec.competence_id is not null then
               open c_competence_start_date(l_cty_rec.competence_id);
               fetch c_competence_start_date into l_competence_start_date;
               close c_competence_start_date;
             end if;

             --
             -- pabodla : MAPPING DATA : Store the mapping column information.
             --
             l_mapping_name := null;
             l_mapping_id   := null;
             l_mapping_name1:= null;
             l_mapping_id1  := null;
             --
             -- Get the competence and Rating name to display on mapping page.
             --
             -- 9999 needs review
             open c_get_mapping_name16(l_cty_rec.competence_id,
                                       NVL(l_competence_start_date,p_effective_date));
             fetch c_get_mapping_name16 into l_mapping_name;
             close c_get_mapping_name16;
             --
             l_mapping_id   := l_cty_rec.competence_id;
             --
             open c_get_mapping_name17(l_cty_rec.rating_level_id,
                                       p_business_group_id);
             fetch c_get_mapping_name17 into l_mapping_name1;
             close c_get_mapping_name17;
             --
             l_mapping_id1   := l_cty_rec.rating_level_id;
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
             hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
             hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
             hr_utility.set_location('l_mapping_id1 '||l_mapping_id1,100);
             hr_utility.set_location('l_mapping_name1 '||l_mapping_name1,100);
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
	       P_TABLE_ALIAS                    => 'CTY',
               p_information1     => l_cty_rec.comptncy_rt_id,
               p_information2     => l_cty_rec.EFFECTIVE_START_DATE,
               p_information3     => l_cty_rec.EFFECTIVE_END_DATE,
               p_information4     => l_cty_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_cty_rec.cty_attribute1,
            p_information120     => l_cty_rec.cty_attribute10,
            p_information121     => l_cty_rec.cty_attribute11,
            p_information122     => l_cty_rec.cty_attribute12,
            p_information123     => l_cty_rec.cty_attribute13,
            p_information124     => l_cty_rec.cty_attribute14,
            p_information125     => l_cty_rec.cty_attribute15,
            p_information126     => l_cty_rec.cty_attribute16,
            p_information127     => l_cty_rec.cty_attribute17,
            p_information128     => l_cty_rec.cty_attribute18,
            p_information129     => l_cty_rec.cty_attribute19,
            p_information112     => l_cty_rec.cty_attribute2,
            p_information130     => l_cty_rec.cty_attribute20,
            p_information131     => l_cty_rec.cty_attribute21,
            p_information132     => l_cty_rec.cty_attribute22,
            p_information133     => l_cty_rec.cty_attribute23,
            p_information134     => l_cty_rec.cty_attribute24,
            p_information135     => l_cty_rec.cty_attribute25,
            p_information136     => l_cty_rec.cty_attribute26,
            p_information137     => l_cty_rec.cty_attribute27,
            p_information138     => l_cty_rec.cty_attribute28,
            p_information139     => l_cty_rec.cty_attribute29,
            p_information113     => l_cty_rec.cty_attribute3,
            p_information140     => l_cty_rec.cty_attribute30,
            p_information114     => l_cty_rec.cty_attribute4,
            p_information115     => l_cty_rec.cty_attribute5,
            p_information116     => l_cty_rec.cty_attribute6,
            p_information117     => l_cty_rec.cty_attribute7,
            p_information118     => l_cty_rec.cty_attribute8,
            p_information119     => l_cty_rec.cty_attribute9,
            p_information110     => l_cty_rec.cty_attribute_category,
            p_information11     => l_cty_rec.excld_flag,
            p_information260     => l_cty_rec.ordr_num,
            -- Data for MAPPING columns.
            p_information177    => l_mapping_name1,
            p_information178    => l_mapping_id1,
            -- END other product Mapping columns.
            p_information262     => l_cty_rec.vrbl_rt_prfl_id,
            p_information166     => l_competence_start_date,
            p_information306     => NULL,  -- No ESD for Rating Level
            p_information265    => l_cty_rec.object_version_number,
           --

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_cty_result_id is null then
                 l_out_cty_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_cty_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;
            --
          end loop;
       hr_utility.set_location('END  OF BEN_COMPTNCY_RT_F',100);
       ---------------------------------------------------------------
       -- END OF BEN_COMPTNCY_RT_F ----------------------
       ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_JOB_RT_F ----------------------
       ---------------------------------------------------------------
       --
       hr_utility.set_location('START OF BEN_JOB_RT_F',100);
       for l_parent_rec  in c_jrt_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;

          --
          l_job_rt_id := l_parent_rec.job_rt_id ;
          --
          for l_jrt_rec in c_jrt(l_parent_rec.job_rt_id,l_mirror_src_entity_result_id,'JRT') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('JRT');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_job_name(l_jrt_rec.job_id)
                               || ben_plan_design_program_module.get_exclude_message(l_jrt_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_jrt_rec.effective_start_date
               and l_jrt_rec.effective_end_date then
             --
               l_result_type_cd := 'DISPLAY';
            else
               l_result_type_cd := 'NO DISPLAY';
            end if;
              --

            -- To store effective_start_date of job
            -- for Mapping - Bug 2958658
            --
            l_job_start_date := null;
            if l_jrt_rec.job_id is not null then
              open c_job_start_date(l_jrt_rec.job_id);
              fetch c_job_start_date into l_job_start_date;
              close c_job_start_date;
            end if;

            --
            l_mapping_name := null;
            l_mapping_id   := null;
            --
            -- Get the Job name to display on mapping page.
            --
            open c_get_mapping_name11(l_jrt_rec.job_id,
                                      NVL(l_job_start_date,p_effective_date));
            fetch c_get_mapping_name11 into l_mapping_name;
            close c_get_mapping_name11;
            --
            l_mapping_id   := l_jrt_rec.job_id;
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
            hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
            hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
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
	      P_TABLE_ALIAS                    => 'JRT',
              p_information1     => l_jrt_rec.job_rt_id,
              p_information2     => l_jrt_rec.EFFECTIVE_START_DATE,
              p_information3     => l_jrt_rec.EFFECTIVE_END_DATE,
              p_information4     => l_jrt_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_jrt_rec.excld_flag,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information226     => l_jrt_rec.job_id,
            p_information111     => l_jrt_rec.jrt_attribute1,
            p_information120     => l_jrt_rec.jrt_attribute10,
            p_information121     => l_jrt_rec.jrt_attribute11,
            p_information122     => l_jrt_rec.jrt_attribute12,
            p_information123     => l_jrt_rec.jrt_attribute13,
            p_information124     => l_jrt_rec.jrt_attribute14,
            p_information125     => l_jrt_rec.jrt_attribute15,
            p_information126     => l_jrt_rec.jrt_attribute16,
            p_information127     => l_jrt_rec.jrt_attribute17,
            p_information128     => l_jrt_rec.jrt_attribute18,
            p_information129     => l_jrt_rec.jrt_attribute19,
            p_information112     => l_jrt_rec.jrt_attribute2,
            p_information130     => l_jrt_rec.jrt_attribute20,
            p_information131     => l_jrt_rec.jrt_attribute21,
            p_information132     => l_jrt_rec.jrt_attribute22,
            p_information133     => l_jrt_rec.jrt_attribute23,
            p_information134     => l_jrt_rec.jrt_attribute24,
            p_information135     => l_jrt_rec.jrt_attribute25,
            p_information136     => l_jrt_rec.jrt_attribute26,
            p_information137     => l_jrt_rec.jrt_attribute27,
            p_information138     => l_jrt_rec.jrt_attribute28,
            p_information139     => l_jrt_rec.jrt_attribute29,
            p_information113     => l_jrt_rec.jrt_attribute3,
            p_information140     => l_jrt_rec.jrt_attribute30,
            p_information114     => l_jrt_rec.jrt_attribute4,
            p_information115     => l_jrt_rec.jrt_attribute5,
            p_information116     => l_jrt_rec.jrt_attribute6,
            p_information117     => l_jrt_rec.jrt_attribute7,
            p_information118     => l_jrt_rec.jrt_attribute8,
            p_information119     => l_jrt_rec.jrt_attribute9,
            p_information110     => l_jrt_rec.jrt_attribute_category,
            p_information257     => l_jrt_rec.ordr_num,
            p_information262     => l_jrt_rec.vrbl_rt_prfl_id,
            p_information166     => l_job_start_date,
            p_information265     => l_jrt_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_jrt_result_id is null then
                l_out_jrt_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_jrt_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
       hr_utility.set_location('END OF BEN_JOB_RT_F',100);
      ---------------------------------------------------------------
      -- END OF BEN_JOB_RT_F ----------------------
      ---------------------------------------------------------------

      ---------------------------------------------------------------
      -- START OF BEN_PSTN_RT_F ----------------------
      ---------------------------------------------------------------
      --
      hr_utility.set_location('START OF BEN_PSTN_RT_F ',100);
      for l_parent_rec  in c_pst_from_parent(l_VRBL_RT_PRFL_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_vpf_result_id ;

         --
         l_pstn_rt_id := l_parent_rec.pstn_rt_id ;
         --
         for l_pst_rec in c_pst(l_parent_rec.pstn_rt_id,l_mirror_src_entity_result_id,'PST') loop
           --
           l_table_route_id := null ;
           open ben_plan_design_program_module.g_table_route('PST');
           fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
           close ben_plan_design_program_module.g_table_route ;
           --
           l_information5  := ben_plan_design_program_module.get_position_name(l_pst_rec.position_id)
                              || ben_plan_design_program_module.get_exclude_message(l_pst_rec.excld_flag);
                              --'Intersection';
           --
           if p_effective_date between l_pst_rec.effective_start_date
              and l_pst_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           --
           -- pabodla : MAPPING DATA : Store the mapping column information.
           --

           l_mapping_name := null;
           l_mapping_id   := null;
           --
           -- Get the position name to display on mapping page.
           --
           open c_get_mapping_name14(l_pst_rec.position_id);
           fetch c_get_mapping_name14 into l_mapping_name;
           close c_get_mapping_name14;
           --
           l_mapping_id   := l_pst_rec.position_id;
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
           hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
           hr_utility.set_location('l_mapping_name '||l_mapping_name,100);

           -- To store effective_start_date of position
           -- for Mapping - Bug 2958658
           --
           l_position_start_date := null;
           if l_pst_rec.position_id is not null then
             open c_position_start_date(l_pst_rec.position_id);
             fetch c_position_start_date into l_position_start_date;
             close c_position_start_date;
           end if;

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
	     P_TABLE_ALIAS                    => 'PST',
             p_information1     => l_pst_rec.pstn_rt_id,
             p_information2     => l_pst_rec.EFFECTIVE_START_DATE,
             p_information3     => l_pst_rec.EFFECTIVE_END_DATE,
             p_information4     => l_pst_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pst_rec.excld_flag,
            p_information257     => l_pst_rec.ordr_num,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information111     => l_pst_rec.pst_attribute1,
            p_information120     => l_pst_rec.pst_attribute10,
            p_information121     => l_pst_rec.pst_attribute11,
            p_information122     => l_pst_rec.pst_attribute12,
            p_information123     => l_pst_rec.pst_attribute13,
            p_information124     => l_pst_rec.pst_attribute14,
            p_information125     => l_pst_rec.pst_attribute15,
            p_information126     => l_pst_rec.pst_attribute16,
            p_information127     => l_pst_rec.pst_attribute17,
            p_information128     => l_pst_rec.pst_attribute18,
            p_information129     => l_pst_rec.pst_attribute19,
            p_information112     => l_pst_rec.pst_attribute2,
            p_information130     => l_pst_rec.pst_attribute20,
            p_information131     => l_pst_rec.pst_attribute21,
            p_information132     => l_pst_rec.pst_attribute22,
            p_information133     => l_pst_rec.pst_attribute23,
            p_information134     => l_pst_rec.pst_attribute24,
            p_information135     => l_pst_rec.pst_attribute25,
            p_information136     => l_pst_rec.pst_attribute26,
            p_information137     => l_pst_rec.pst_attribute27,
            p_information138     => l_pst_rec.pst_attribute28,
            p_information139     => l_pst_rec.pst_attribute29,
            p_information113     => l_pst_rec.pst_attribute3,
            p_information140     => l_pst_rec.pst_attribute30,
            p_information114     => l_pst_rec.pst_attribute4,
            p_information115     => l_pst_rec.pst_attribute5,
            p_information116     => l_pst_rec.pst_attribute6,
            p_information117     => l_pst_rec.pst_attribute7,
            p_information118     => l_pst_rec.pst_attribute8,
            p_information119     => l_pst_rec.pst_attribute9,
            p_information110     => l_pst_rec.pst_attribute_category,
            p_information262     => l_pst_rec.vrbl_rt_prfl_id,
            p_information166     => l_position_start_date,
            p_information265     => l_pst_rec.object_version_number,
           --

             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

            if l_out_pst_result_id is null then
              l_out_pst_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
                l_out_pst_result_id := l_copy_entity_result_id ;
             end if;
             --
          end loop;
          --
        end loop;
      hr_utility.set_location('END OF BEN_PSTN_RT_F ',100);
     ---------------------------------------------------------------
     -- END OF BEN_PSTN_RT_F ----------------------
     ---------------------------------------------------------------
      ---------------------------------------------------------------
      -- START OF BEN_QUAL_TITL_RT_F ----------------------
      ---------------------------------------------------------------
      --
      hr_utility.set_location('START OF BEN_QUAL_TITL_RT_F ',100);
      for l_parent_rec  in c_qtr_from_parent(l_VRBL_RT_PRFL_ID) loop
         --
         l_mirror_src_entity_result_id := l_out_vpf_result_id ;

         --
         l_qual_titl_rt_id := l_parent_rec.qual_titl_rt_id ;
         --
         for l_qtr_rec in c_qtr(l_parent_rec.qual_titl_rt_id,l_mirror_src_entity_result_id,'QTR') loop
           --
           l_table_route_id := null ;
           open ben_plan_design_program_module.g_table_route('QTR');
           fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
           close ben_plan_design_program_module.g_table_route ;
           --
           l_information5  := ben_plan_design_program_module.get_qual_type_name(l_qtr_rec.qualification_type_id)
                              || ben_plan_design_program_module.get_exclude_message(l_qtr_rec.excld_flag);
                              --'Intersection';
           --
           if p_effective_date between l_qtr_rec.effective_start_date
              and l_qtr_rec.effective_end_date then
            --
              l_result_type_cd := 'DISPLAY';
           else
              l_result_type_cd := 'NO DISPLAY';
           end if;
             --
           --
           -- pabodla : MAPPING DATA : Store the mapping column information.
           --

           l_mapping_name := null;
           l_mapping_id   := null;
           --
           -- Get the qualification_type name to display on mapping page.
           --
           open c_get_mapping_name15(l_qtr_rec.qualification_type_id);
           fetch c_get_mapping_name15 into l_mapping_name;
           close c_get_mapping_name15;
           --
           l_mapping_id   := l_qtr_rec.qualification_type_id;
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
           hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
           hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
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
	     P_TABLE_ALIAS                    => 'QTR',
             p_information1     => l_qtr_rec.qual_titl_rt_id,
             p_information2     => l_qtr_rec.EFFECTIVE_START_DATE,
             p_information3     => l_qtr_rec.EFFECTIVE_END_DATE,
             p_information4     => l_qtr_rec.business_group_id,
             p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_qtr_rec.excld_flag,
            p_information260     => l_qtr_rec.ordr_num,
            p_information111     => l_qtr_rec.qtr_attribute1,
            p_information120     => l_qtr_rec.qtr_attribute10,
            p_information121     => l_qtr_rec.qtr_attribute11,
            p_information122     => l_qtr_rec.qtr_attribute12,
            p_information123     => l_qtr_rec.qtr_attribute13,
            p_information124     => l_qtr_rec.qtr_attribute14,
            p_information125     => l_qtr_rec.qtr_attribute15,
            p_information126     => l_qtr_rec.qtr_attribute16,
            p_information127     => l_qtr_rec.qtr_attribute17,
            p_information128     => l_qtr_rec.qtr_attribute18,
            p_information129     => l_qtr_rec.qtr_attribute19,
            p_information112     => l_qtr_rec.qtr_attribute2,
            p_information130     => l_qtr_rec.qtr_attribute20,
            p_information131     => l_qtr_rec.qtr_attribute21,
            p_information132     => l_qtr_rec.qtr_attribute22,
            p_information133     => l_qtr_rec.qtr_attribute23,
            p_information134     => l_qtr_rec.qtr_attribute24,
            p_information135     => l_qtr_rec.qtr_attribute25,
            p_information136     => l_qtr_rec.qtr_attribute26,
            p_information137     => l_qtr_rec.qtr_attribute27,
            p_information138     => l_qtr_rec.qtr_attribute28,
            p_information139     => l_qtr_rec.qtr_attribute29,
            p_information113     => l_qtr_rec.qtr_attribute3,
            p_information140     => l_qtr_rec.qtr_attribute30,
            p_information114     => l_qtr_rec.qtr_attribute4,
            p_information115     => l_qtr_rec.qtr_attribute5,
            p_information116     => l_qtr_rec.qtr_attribute6,
            p_information117     => l_qtr_rec.qtr_attribute7,
            p_information118     => l_qtr_rec.qtr_attribute8,
            p_information119     => l_qtr_rec.qtr_attribute9,
            p_information110     => l_qtr_rec.qtr_attribute_category,
            -- Data for MAPPING columns.
            p_information173    => l_mapping_name,
            p_information174    => l_mapping_id,
            p_information181    => l_mapping_column_name1,
            p_information182    => l_mapping_column_name2,
            -- END other product Mapping columns.
            p_information141     => l_qtr_rec.title,
            p_information262     => l_qtr_rec.vrbl_rt_prfl_id,
            p_information166     => NULL,  -- No ESD for Qualification Type
            p_information265     => l_qtr_rec.object_version_number,
           --

             p_object_version_number          => l_object_version_number,
             p_effective_date                 => p_effective_date       );
             --

             if l_out_qtr_result_id is null then
               l_out_qtr_result_id := l_copy_entity_result_id;
             end if;

             if l_result_type_cd = 'DISPLAY' then
                l_out_qtr_result_id := l_copy_entity_result_id ;
             end if;
             --
          end loop;
          --
        end loop;
      hr_utility.set_location('END OF BEN_QUAL_TITL_RT_F ',100);
     ---------------------------------------------------------------
     -- END OF BEN_QUAL_TITL_RT_F ----------------------
     ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_CBR_QUALD_BNF_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_cqr_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_cbr_quald_bnf_rt_id := l_parent_rec.cbr_quald_bnf_rt_id ;
          --
          for l_cqr_rec in c_cqr(l_parent_rec.cbr_quald_bnf_rt_id,l_mirror_src_entity_result_id,'CQR') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('CQR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_cbr_quald_bnf_name(l_cqr_rec.ptip_id
                                                                                    ,l_cqr_rec.pgm_id
                                                                                    ,p_effective_date);
                               --'Intersection';
            --
            if p_effective_date between l_cqr_rec.effective_start_date
               and l_cqr_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'CQR',
              p_information1     => l_cqr_rec.cbr_quald_bnf_rt_id,
              p_information2     => l_cqr_rec.EFFECTIVE_START_DATE,
              p_information3     => l_cqr_rec.EFFECTIVE_END_DATE,
              p_information4     => l_cqr_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cqr_rec.cqr_attribute1,
            p_information120     => l_cqr_rec.cqr_attribute10,
            p_information121     => l_cqr_rec.cqr_attribute11,
            p_information122     => l_cqr_rec.cqr_attribute12,
            p_information123     => l_cqr_rec.cqr_attribute13,
            p_information124     => l_cqr_rec.cqr_attribute14,
            p_information125     => l_cqr_rec.cqr_attribute15,
            p_information126     => l_cqr_rec.cqr_attribute16,
            p_information127     => l_cqr_rec.cqr_attribute17,
            p_information128     => l_cqr_rec.cqr_attribute18,
            p_information129     => l_cqr_rec.cqr_attribute19,
            p_information112     => l_cqr_rec.cqr_attribute2,
            p_information130     => l_cqr_rec.cqr_attribute20,
            p_information131     => l_cqr_rec.cqr_attribute21,
            p_information132     => l_cqr_rec.cqr_attribute22,
            p_information133     => l_cqr_rec.cqr_attribute23,
            p_information134     => l_cqr_rec.cqr_attribute24,
            p_information135     => l_cqr_rec.cqr_attribute25,
            p_information136     => l_cqr_rec.cqr_attribute26,
            p_information137     => l_cqr_rec.cqr_attribute27,
            p_information138     => l_cqr_rec.cqr_attribute28,
            p_information139     => l_cqr_rec.cqr_attribute29,
            p_information113     => l_cqr_rec.cqr_attribute3,
            p_information140     => l_cqr_rec.cqr_attribute30,
            p_information114     => l_cqr_rec.cqr_attribute4,
            p_information115     => l_cqr_rec.cqr_attribute5,
            p_information116     => l_cqr_rec.cqr_attribute6,
            p_information117     => l_cqr_rec.cqr_attribute7,
            p_information118     => l_cqr_rec.cqr_attribute8,
            p_information119     => l_cqr_rec.cqr_attribute9,
            p_information110     => l_cqr_rec.cqr_attribute_category,
            p_information257     => l_cqr_rec.ordr_num,
            p_information260     => l_cqr_rec.pgm_id,
            p_information259     => l_cqr_rec.ptip_id,
            p_information11     => l_cqr_rec.quald_bnf_flag,
            p_information262     => l_cqr_rec.vrbl_rt_prfl_id,
            p_information265     => l_cqr_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_cqr_result_id is null then
                l_out_cqr_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_cqr_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_CBR_QUALD_BNF_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_CNTNG_PRTN_PRFL_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_cpn_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_cntng_prtn_prfl_rt_id := l_parent_rec.cntng_prtn_prfl_rt_id ;
          --
          for l_cpn_rec in c_cpn(l_parent_rec.cntng_prtn_prfl_rt_id,l_mirror_src_entity_result_id,'CPN') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('CPN');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := l_cpn_rec.pymt_must_be_rcvd_num ||' '||
                               hr_general.decode_lookup('BEN_TM_UOM', l_cpn_rec.pymt_must_be_rcvd_uom);
                               --'Intersection';

            if p_effective_date between l_cpn_rec.effective_start_date
               and l_cpn_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'CPN',
              p_information1     => l_cpn_rec.cntng_prtn_prfl_rt_id,
              p_information2     => l_cpn_rec.EFFECTIVE_START_DATE,
              p_information3     => l_cpn_rec.EFFECTIVE_END_DATE,
              p_information4     => l_cpn_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cpn_rec.cpn_attribute1,
            p_information120     => l_cpn_rec.cpn_attribute10,
            p_information121     => l_cpn_rec.cpn_attribute11,
            p_information122     => l_cpn_rec.cpn_attribute12,
            p_information123     => l_cpn_rec.cpn_attribute13,
            p_information124     => l_cpn_rec.cpn_attribute14,
            p_information125     => l_cpn_rec.cpn_attribute15,
            p_information126     => l_cpn_rec.cpn_attribute16,
            p_information127     => l_cpn_rec.cpn_attribute17,
            p_information128     => l_cpn_rec.cpn_attribute18,
            p_information129     => l_cpn_rec.cpn_attribute19,
            p_information112     => l_cpn_rec.cpn_attribute2,
            p_information130     => l_cpn_rec.cpn_attribute20,
            p_information131     => l_cpn_rec.cpn_attribute21,
            p_information132     => l_cpn_rec.cpn_attribute22,
            p_information133     => l_cpn_rec.cpn_attribute23,
            p_information134     => l_cpn_rec.cpn_attribute24,
            p_information135     => l_cpn_rec.cpn_attribute25,
            p_information136     => l_cpn_rec.cpn_attribute26,
            p_information137     => l_cpn_rec.cpn_attribute27,
            p_information138     => l_cpn_rec.cpn_attribute28,
            p_information139     => l_cpn_rec.cpn_attribute29,
            p_information113     => l_cpn_rec.cpn_attribute3,
            p_information140     => l_cpn_rec.cpn_attribute30,
            p_information114     => l_cpn_rec.cpn_attribute4,
            p_information115     => l_cpn_rec.cpn_attribute5,
            p_information116     => l_cpn_rec.cpn_attribute6,
            p_information117     => l_cpn_rec.cpn_attribute7,
            p_information118     => l_cpn_rec.cpn_attribute8,
            p_information119     => l_cpn_rec.cpn_attribute9,
            p_information110     => l_cpn_rec.cpn_attribute_category,
            p_information170     => l_cpn_rec.name,
            p_information260     => l_cpn_rec.pymt_must_be_rcvd_num,
            p_information261     => l_cpn_rec.pymt_must_be_rcvd_rl,
            p_information11     => l_cpn_rec.pymt_must_be_rcvd_uom,
            p_information262     => l_cpn_rec.vrbl_rt_prfl_id,
            p_information265    => l_cpn_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_cpn_result_id is null then
                l_out_cpn_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_cpn_result_id := l_copy_entity_result_id ;
              end if;
              --
              -- Copy Fast Formulas if any are attached to any column --
              ---------------------------------------------------------------
              -- PYMT_MUST_BE_RCVD_RL -----------------
              ---------------------------------------------------------------

              if l_cpn_rec.pymt_must_be_rcvd_rl is not null then
                    --
                    ben_plan_design_program_module.create_formula_result
                    (
                     p_validate                       =>  0
                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                    ,p_formula_id                     =>  l_cpn_rec.pymt_must_be_rcvd_rl
                    ,p_business_group_id              =>  l_cpn_rec.business_group_id
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
      -- END OF BEN_CNTNG_PRTN_PRFL_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_DPNT_CVRD_OTHR_PL_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_dcl_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_dpnt_cvrd_othr_pl_rt_id := l_parent_rec.dpnt_cvrd_othr_pl_rt_id ;
          --
          for l_dcl_rec in c_dcl(l_parent_rec.dpnt_cvrd_othr_pl_rt_id,l_mirror_src_entity_result_id,'DCL') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('DCL');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_pl_name(l_dcl_rec.pl_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_dcl_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_dcl_rec.effective_start_date
               and l_dcl_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'DCL',
              p_information1     => l_dcl_rec.dpnt_cvrd_othr_pl_rt_id,
              p_information2     => l_dcl_rec.EFFECTIVE_START_DATE,
              p_information3     => l_dcl_rec.EFFECTIVE_END_DATE,
              p_information4     => l_dcl_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information12     => l_dcl_rec.cvg_det_dt_cd,
            p_information111     => l_dcl_rec.dcl_attribute1,
            p_information120     => l_dcl_rec.dcl_attribute10,
            p_information121     => l_dcl_rec.dcl_attribute11,
            p_information122     => l_dcl_rec.dcl_attribute12,
            p_information123     => l_dcl_rec.dcl_attribute13,
            p_information124     => l_dcl_rec.dcl_attribute14,
            p_information125     => l_dcl_rec.dcl_attribute15,
            p_information126     => l_dcl_rec.dcl_attribute16,
            p_information127     => l_dcl_rec.dcl_attribute17,
            p_information128     => l_dcl_rec.dcl_attribute18,
            p_information129     => l_dcl_rec.dcl_attribute19,
            p_information112     => l_dcl_rec.dcl_attribute2,
            p_information130     => l_dcl_rec.dcl_attribute20,
            p_information131     => l_dcl_rec.dcl_attribute21,
            p_information132     => l_dcl_rec.dcl_attribute22,
            p_information133     => l_dcl_rec.dcl_attribute23,
            p_information134     => l_dcl_rec.dcl_attribute24,
            p_information135     => l_dcl_rec.dcl_attribute25,
            p_information136     => l_dcl_rec.dcl_attribute26,
            p_information137     => l_dcl_rec.dcl_attribute27,
            p_information138     => l_dcl_rec.dcl_attribute28,
            p_information139     => l_dcl_rec.dcl_attribute29,
            p_information113     => l_dcl_rec.dcl_attribute3,
            p_information140     => l_dcl_rec.dcl_attribute30,
            p_information114     => l_dcl_rec.dcl_attribute4,
            p_information115     => l_dcl_rec.dcl_attribute5,
            p_information116     => l_dcl_rec.dcl_attribute6,
            p_information117     => l_dcl_rec.dcl_attribute7,
            p_information118     => l_dcl_rec.dcl_attribute8,
            p_information119     => l_dcl_rec.dcl_attribute9,
            p_information110     => l_dcl_rec.dcl_attribute_category,
            p_information11     => l_dcl_rec.excld_flag,
            p_information257     => l_dcl_rec.ordr_num,
            p_information261     => l_dcl_rec.pl_id,
            p_information262     => l_dcl_rec.vrbl_rt_prfl_id,
            p_information265     => l_dcl_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_dcl_result_id is null then
                 l_out_dcl_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_dcl_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_DPNT_CVRD_OTHR_PL_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_DPNT_CVRD_PLIP_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_dcp_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_dpnt_cvrd_plip_rt_id := l_parent_rec.dpnt_cvrd_plip_rt_id ;
          --
          for l_dcp_rec in c_dcp(l_parent_rec.dpnt_cvrd_plip_rt_id,l_mirror_src_entity_result_id,'DCP') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('DCP');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_plip_name(l_dcp_rec.plip_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_dcp_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_dcp_rec.effective_start_date
               and l_dcp_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'DCP',
              p_information1     => l_dcp_rec.dpnt_cvrd_plip_rt_id,
              p_information2     => l_dcp_rec.EFFECTIVE_START_DATE,
              p_information3     => l_dcp_rec.EFFECTIVE_END_DATE,
              p_information4     => l_dcp_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_dcp_rec.dcp_attribute1,
            p_information120     => l_dcp_rec.dcp_attribute10,
            p_information121     => l_dcp_rec.dcp_attribute11,
            p_information122     => l_dcp_rec.dcp_attribute12,
            p_information123     => l_dcp_rec.dcp_attribute13,
            p_information124     => l_dcp_rec.dcp_attribute14,
            p_information125     => l_dcp_rec.dcp_attribute15,
            p_information126     => l_dcp_rec.dcp_attribute16,
            p_information127     => l_dcp_rec.dcp_attribute17,
            p_information128     => l_dcp_rec.dcp_attribute18,
            p_information129     => l_dcp_rec.dcp_attribute19,
            p_information112     => l_dcp_rec.dcp_attribute2,
            p_information130     => l_dcp_rec.dcp_attribute20,
            p_information131     => l_dcp_rec.dcp_attribute21,
            p_information132     => l_dcp_rec.dcp_attribute22,
            p_information133     => l_dcp_rec.dcp_attribute23,
            p_information134     => l_dcp_rec.dcp_attribute24,
            p_information135     => l_dcp_rec.dcp_attribute25,
            p_information136     => l_dcp_rec.dcp_attribute26,
            p_information137     => l_dcp_rec.dcp_attribute27,
            p_information138     => l_dcp_rec.dcp_attribute28,
            p_information139     => l_dcp_rec.dcp_attribute29,
            p_information113     => l_dcp_rec.dcp_attribute3,
            p_information140     => l_dcp_rec.dcp_attribute30,
            p_information114     => l_dcp_rec.dcp_attribute4,
            p_information115     => l_dcp_rec.dcp_attribute5,
            p_information116     => l_dcp_rec.dcp_attribute6,
            p_information117     => l_dcp_rec.dcp_attribute7,
            p_information118     => l_dcp_rec.dcp_attribute8,
            p_information119     => l_dcp_rec.dcp_attribute9,
            p_information110     => l_dcp_rec.dcp_attribute_category,
            p_information11     => l_dcp_rec.enrl_det_dt_cd,
            p_information12     => l_dcp_rec.excld_flag,
            p_information260     => l_dcp_rec.ordr_num,
            p_information256     => l_dcp_rec.plip_id,
            p_information262     => l_dcp_rec.vrbl_rt_prfl_id,
            p_information265     => l_dcp_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_dcp_result_id is null then
                l_out_dcp_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_dcp_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_DPNT_CVRD_PLIP_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_DPNT_CVRD_OTHR_PTIP_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_dco_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_dpnt_cvrd_othr_ptip_rt_id := l_parent_rec.dpnt_cvrd_othr_ptip_rt_id ;
          --
          for l_dco_rec in c_dco(l_parent_rec.dpnt_cvrd_othr_ptip_rt_id,l_mirror_src_entity_result_id,'DCO') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('DCO');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_ptip_name(l_dco_rec.ptip_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_dco_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_dco_rec.effective_start_date
               and l_dco_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'DCO',
              p_information1     => l_dco_rec.dpnt_cvrd_othr_ptip_rt_id,
              p_information2     => l_dco_rec.EFFECTIVE_START_DATE,
              p_information3     => l_dco_rec.EFFECTIVE_END_DATE,
              p_information4     => l_dco_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_dco_rec.dco_attribute1,
            p_information120     => l_dco_rec.dco_attribute10,
            p_information121     => l_dco_rec.dco_attribute11,
            p_information122     => l_dco_rec.dco_attribute12,
            p_information123     => l_dco_rec.dco_attribute13,
            p_information124     => l_dco_rec.dco_attribute14,
            p_information125     => l_dco_rec.dco_attribute15,
            p_information126     => l_dco_rec.dco_attribute16,
            p_information127     => l_dco_rec.dco_attribute17,
            p_information128     => l_dco_rec.dco_attribute18,
            p_information129     => l_dco_rec.dco_attribute19,
            p_information112     => l_dco_rec.dco_attribute2,
            p_information130     => l_dco_rec.dco_attribute20,
            p_information131     => l_dco_rec.dco_attribute21,
            p_information132     => l_dco_rec.dco_attribute22,
            p_information133     => l_dco_rec.dco_attribute23,
            p_information134     => l_dco_rec.dco_attribute24,
            p_information135     => l_dco_rec.dco_attribute25,
            p_information136     => l_dco_rec.dco_attribute26,
            p_information137     => l_dco_rec.dco_attribute27,
            p_information138     => l_dco_rec.dco_attribute28,
            p_information139     => l_dco_rec.dco_attribute29,
            p_information113     => l_dco_rec.dco_attribute3,
            p_information140     => l_dco_rec.dco_attribute30,
            p_information114     => l_dco_rec.dco_attribute4,
            p_information115     => l_dco_rec.dco_attribute5,
            p_information116     => l_dco_rec.dco_attribute6,
            p_information117     => l_dco_rec.dco_attribute7,
            p_information118     => l_dco_rec.dco_attribute8,
            p_information119     => l_dco_rec.dco_attribute9,
            p_information110     => l_dco_rec.dco_attribute_category,
            p_information13     => l_dco_rec.enrl_det_dt_cd,
            p_information11     => l_dco_rec.excld_flag,
            p_information12     => l_dco_rec.only_pls_subj_cobra_flag,
            p_information261     => l_dco_rec.ordr_num,
            p_information259     => l_dco_rec.ptip_id,
            p_information262     => l_dco_rec.vrbl_rt_prfl_id,
            p_information265     => l_dco_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_dco_result_id is null then
                l_out_dco_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_dco_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_DPNT_CVRD_OTHR_PTIP_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_DPNT_CVRD_OTHR_PGM_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_dop_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_dpnt_cvrd_othr_pgm_rt_id := l_parent_rec.dpnt_cvrd_othr_pgm_rt_id ;
          --
          for l_dop_rec in c_dop(l_parent_rec.dpnt_cvrd_othr_pgm_rt_id,l_mirror_src_entity_result_id,'DOP') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('DOP');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_pgm_name(l_dop_rec.pgm_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_dop_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_dop_rec.effective_start_date
               and l_dop_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'DOP',
              p_information1     => l_dop_rec.dpnt_cvrd_othr_pgm_rt_id,
              p_information2     => l_dop_rec.EFFECTIVE_START_DATE,
              p_information3     => l_dop_rec.EFFECTIVE_END_DATE,
              p_information4     => l_dop_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_dop_rec.dop_attribute1,
            p_information120     => l_dop_rec.dop_attribute10,
            p_information121     => l_dop_rec.dop_attribute11,
            p_information122     => l_dop_rec.dop_attribute12,
            p_information123     => l_dop_rec.dop_attribute13,
            p_information124     => l_dop_rec.dop_attribute14,
            p_information125     => l_dop_rec.dop_attribute15,
            p_information126     => l_dop_rec.dop_attribute16,
            p_information127     => l_dop_rec.dop_attribute17,
            p_information128     => l_dop_rec.dop_attribute18,
            p_information129     => l_dop_rec.dop_attribute19,
            p_information112     => l_dop_rec.dop_attribute2,
            p_information130     => l_dop_rec.dop_attribute20,
            p_information131     => l_dop_rec.dop_attribute21,
            p_information132     => l_dop_rec.dop_attribute22,
            p_information133     => l_dop_rec.dop_attribute23,
            p_information134     => l_dop_rec.dop_attribute24,
            p_information135     => l_dop_rec.dop_attribute25,
            p_information136     => l_dop_rec.dop_attribute26,
            p_information137     => l_dop_rec.dop_attribute27,
            p_information138     => l_dop_rec.dop_attribute28,
            p_information139     => l_dop_rec.dop_attribute29,
            p_information113     => l_dop_rec.dop_attribute3,
            p_information140     => l_dop_rec.dop_attribute30,
            p_information114     => l_dop_rec.dop_attribute4,
            p_information115     => l_dop_rec.dop_attribute5,
            p_information116     => l_dop_rec.dop_attribute6,
            p_information117     => l_dop_rec.dop_attribute7,
            p_information118     => l_dop_rec.dop_attribute8,
            p_information119     => l_dop_rec.dop_attribute9,
            p_information110     => l_dop_rec.dop_attribute_category,
            p_information13     => l_dop_rec.enrl_det_dt_cd,
            p_information11     => l_dop_rec.excld_flag,
            p_information12     => l_dop_rec.only_pls_subj_cobra_flag,
            p_information261     => l_dop_rec.ordr_num,
            p_information260     => l_dop_rec.pgm_id,
            p_information262     => l_dop_rec.vrbl_rt_prfl_id,
            p_information265     => l_dop_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_dop_result_id is null then
                l_out_dop_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_dop_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_DPNT_CVRD_OTHR_PGM_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_PRTT_ANTHR_PL_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_pap_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_prtt_anthr_pl_rt_id := l_parent_rec.prtt_anthr_pl_rt_id ;
          --
          for l_pap_rec in c_pap(l_parent_rec.prtt_anthr_pl_rt_id,l_mirror_src_entity_result_id,'PAP') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PAP');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_pl_name(l_pap_rec.pl_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_pap_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_pap_rec.effective_start_date
               and l_pap_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'PAP',
              p_information1     => l_pap_rec.prtt_anthr_pl_rt_id,
              p_information2     => l_pap_rec.EFFECTIVE_START_DATE,
              p_information3     => l_pap_rec.EFFECTIVE_END_DATE,
              p_information4     => l_pap_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_pap_rec.excld_flag,
            p_information260     => l_pap_rec.ordr_num,
            p_information111     => l_pap_rec.pap_attribute1,
            p_information120     => l_pap_rec.pap_attribute10,
            p_information121     => l_pap_rec.pap_attribute11,
            p_information122     => l_pap_rec.pap_attribute12,
            p_information123     => l_pap_rec.pap_attribute13,
            p_information124     => l_pap_rec.pap_attribute14,
            p_information125     => l_pap_rec.pap_attribute15,
            p_information126     => l_pap_rec.pap_attribute16,
            p_information127     => l_pap_rec.pap_attribute17,
            p_information128     => l_pap_rec.pap_attribute18,
            p_information129     => l_pap_rec.pap_attribute19,
            p_information112     => l_pap_rec.pap_attribute2,
            p_information130     => l_pap_rec.pap_attribute20,
            p_information131     => l_pap_rec.pap_attribute21,
            p_information132     => l_pap_rec.pap_attribute22,
            p_information133     => l_pap_rec.pap_attribute23,
            p_information134     => l_pap_rec.pap_attribute24,
            p_information135     => l_pap_rec.pap_attribute25,
            p_information136     => l_pap_rec.pap_attribute26,
            p_information137     => l_pap_rec.pap_attribute27,
            p_information138     => l_pap_rec.pap_attribute28,
            p_information139     => l_pap_rec.pap_attribute29,
            p_information113     => l_pap_rec.pap_attribute3,
            p_information140     => l_pap_rec.pap_attribute30,
            p_information114     => l_pap_rec.pap_attribute4,
            p_information115     => l_pap_rec.pap_attribute5,
            p_information116     => l_pap_rec.pap_attribute6,
            p_information117     => l_pap_rec.pap_attribute7,
            p_information118     => l_pap_rec.pap_attribute8,
            p_information119     => l_pap_rec.pap_attribute9,
            p_information110     => l_pap_rec.pap_attribute_category,
            p_information261     => l_pap_rec.pl_id,
            p_information262     => l_pap_rec.vrbl_rt_prfl_id,
            p_information265     => l_pap_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_pap_result_id is null then
                l_out_pap_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_pap_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_PRTT_ANTHR_PL_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_ENRLD_ANTHR_OIPL_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_eao_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_enrld_anthr_oipl_rt_id := l_parent_rec.enrld_anthr_oipl_rt_id ;
          --
          for l_eao_rec in c_eao(l_parent_rec.enrld_anthr_oipl_rt_id,l_mirror_src_entity_result_id,'EAO') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('EAO');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_oipl_name(l_eao_rec.oipl_id
                                                                           ,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_eao_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_eao_rec.effective_start_date
               and l_eao_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'EAO',
              p_information1     => l_eao_rec.enrld_anthr_oipl_rt_id,
              p_information2     => l_eao_rec.EFFECTIVE_START_DATE,
              p_information3     => l_eao_rec.EFFECTIVE_END_DATE,
              p_information4     => l_eao_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_eao_rec.eao_attribute1,
            p_information120     => l_eao_rec.eao_attribute10,
            p_information121     => l_eao_rec.eao_attribute11,
            p_information122     => l_eao_rec.eao_attribute12,
            p_information123     => l_eao_rec.eao_attribute13,
            p_information124     => l_eao_rec.eao_attribute14,
            p_information125     => l_eao_rec.eao_attribute15,
            p_information126     => l_eao_rec.eao_attribute16,
            p_information127     => l_eao_rec.eao_attribute17,
            p_information128     => l_eao_rec.eao_attribute18,
            p_information129     => l_eao_rec.eao_attribute19,
            p_information112     => l_eao_rec.eao_attribute2,
            p_information130     => l_eao_rec.eao_attribute20,
            p_information131     => l_eao_rec.eao_attribute21,
            p_information132     => l_eao_rec.eao_attribute22,
            p_information133     => l_eao_rec.eao_attribute23,
            p_information134     => l_eao_rec.eao_attribute24,
            p_information135     => l_eao_rec.eao_attribute25,
            p_information136     => l_eao_rec.eao_attribute26,
            p_information137     => l_eao_rec.eao_attribute27,
            p_information138     => l_eao_rec.eao_attribute28,
            p_information139     => l_eao_rec.eao_attribute29,
            p_information113     => l_eao_rec.eao_attribute3,
            p_information140     => l_eao_rec.eao_attribute30,
            p_information114     => l_eao_rec.eao_attribute4,
            p_information115     => l_eao_rec.eao_attribute5,
            p_information116     => l_eao_rec.eao_attribute6,
            p_information117     => l_eao_rec.eao_attribute7,
            p_information118     => l_eao_rec.eao_attribute8,
            p_information119     => l_eao_rec.eao_attribute9,
            p_information110     => l_eao_rec.eao_attribute_category,
            p_information12     => l_eao_rec.enrl_det_dt_cd,
            p_information11     => l_eao_rec.excld_flag,
            p_information258     => l_eao_rec.oipl_id,
            p_information261     => l_eao_rec.ordr_num,
            p_information262     => l_eao_rec.vrbl_rt_prfl_id,
            p_information265     => l_eao_rec.object_version_number,
           --
              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_eao_result_id is null then
                l_out_eao_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_eao_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_ENRLD_ANTHR_OIPL_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_ENRLD_ANTHR_PL_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_enl_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_enrld_anthr_pl_rt_id := l_parent_rec.enrld_anthr_pl_rt_id ;
          --
          for l_enl_rec in c_enl(l_parent_rec.enrld_anthr_pl_rt_id,l_mirror_src_entity_result_id,'ENL') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('ENL');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_pl_name(l_enl_rec.pl_id
                                                                         ,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_enl_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_enl_rec.effective_start_date
               and l_enl_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'ENL',
              p_information1     => l_enl_rec.enrld_anthr_pl_rt_id,
              p_information2     => l_enl_rec.EFFECTIVE_START_DATE,
              p_information3     => l_enl_rec.EFFECTIVE_END_DATE,
              p_information4     => l_enl_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_enl_rec.enl_attribute1,
            p_information120     => l_enl_rec.enl_attribute10,
            p_information121     => l_enl_rec.enl_attribute11,
            p_information122     => l_enl_rec.enl_attribute12,
            p_information123     => l_enl_rec.enl_attribute13,
            p_information124     => l_enl_rec.enl_attribute14,
            p_information125     => l_enl_rec.enl_attribute15,
            p_information126     => l_enl_rec.enl_attribute16,
            p_information127     => l_enl_rec.enl_attribute17,
            p_information128     => l_enl_rec.enl_attribute18,
            p_information129     => l_enl_rec.enl_attribute19,
            p_information112     => l_enl_rec.enl_attribute2,
            p_information130     => l_enl_rec.enl_attribute20,
            p_information131     => l_enl_rec.enl_attribute21,
            p_information132     => l_enl_rec.enl_attribute22,
            p_information133     => l_enl_rec.enl_attribute23,
            p_information134     => l_enl_rec.enl_attribute24,
            p_information135     => l_enl_rec.enl_attribute25,
            p_information136     => l_enl_rec.enl_attribute26,
            p_information137     => l_enl_rec.enl_attribute27,
            p_information138     => l_enl_rec.enl_attribute28,
            p_information139     => l_enl_rec.enl_attribute29,
            p_information113     => l_enl_rec.enl_attribute3,
            p_information140     => l_enl_rec.enl_attribute30,
            p_information114     => l_enl_rec.enl_attribute4,
            p_information115     => l_enl_rec.enl_attribute5,
            p_information116     => l_enl_rec.enl_attribute6,
            p_information117     => l_enl_rec.enl_attribute7,
            p_information118     => l_enl_rec.enl_attribute8,
            p_information119     => l_enl_rec.enl_attribute9,
            p_information110     => l_enl_rec.enl_attribute_category,
            p_information12     => l_enl_rec.enrl_det_dt_cd,
            p_information11     => l_enl_rec.excld_flag,
            p_information260     => l_enl_rec.ordr_num,
            p_information261     => l_enl_rec.pl_id,
            p_information262     => l_enl_rec.vrbl_rt_prfl_id,
            p_information265     => l_enl_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_enl_result_id is null then
                l_out_enl_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_enl_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_ENRLD_ANTHR_PL_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_ENRLD_ANTHR_PLIP_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_ear_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_enrld_anthr_plip_rt_id := l_parent_rec.enrld_anthr_plip_rt_id ;
          --
          for l_ear_rec in c_ear(l_parent_rec.enrld_anthr_plip_rt_id,l_mirror_src_entity_result_id,'EAR') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('EAR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_plip_name(l_ear_rec.plip_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_ear_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_ear_rec.effective_start_date
               and l_ear_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'EAR',
              p_information1     => l_ear_rec.enrld_anthr_plip_rt_id,
              p_information2     => l_ear_rec.EFFECTIVE_START_DATE,
              p_information3     => l_ear_rec.EFFECTIVE_END_DATE,
              p_information4     => l_ear_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_ear_rec.ear_attribute1,
            p_information120     => l_ear_rec.ear_attribute10,
            p_information121     => l_ear_rec.ear_attribute11,
            p_information122     => l_ear_rec.ear_attribute12,
            p_information123     => l_ear_rec.ear_attribute13,
            p_information124     => l_ear_rec.ear_attribute14,
            p_information125     => l_ear_rec.ear_attribute15,
            p_information126     => l_ear_rec.ear_attribute16,
            p_information127     => l_ear_rec.ear_attribute17,
            p_information128     => l_ear_rec.ear_attribute18,
            p_information129     => l_ear_rec.ear_attribute19,
            p_information112     => l_ear_rec.ear_attribute2,
            p_information130     => l_ear_rec.ear_attribute20,
            p_information131     => l_ear_rec.ear_attribute21,
            p_information132     => l_ear_rec.ear_attribute22,
            p_information133     => l_ear_rec.ear_attribute23,
            p_information134     => l_ear_rec.ear_attribute24,
            p_information135     => l_ear_rec.ear_attribute25,
            p_information136     => l_ear_rec.ear_attribute26,
            p_information137     => l_ear_rec.ear_attribute27,
            p_information138     => l_ear_rec.ear_attribute28,
            p_information139     => l_ear_rec.ear_attribute29,
            p_information113     => l_ear_rec.ear_attribute3,
            p_information140     => l_ear_rec.ear_attribute30,
            p_information114     => l_ear_rec.ear_attribute4,
            p_information115     => l_ear_rec.ear_attribute5,
            p_information116     => l_ear_rec.ear_attribute6,
            p_information117     => l_ear_rec.ear_attribute7,
            p_information118     => l_ear_rec.ear_attribute8,
            p_information119     => l_ear_rec.ear_attribute9,
            p_information110     => l_ear_rec.ear_attribute_category,
            p_information11     => l_ear_rec.enrl_det_dt_cd,
            p_information12     => l_ear_rec.excld_flag,
            p_information257     => l_ear_rec.ordr_num,
            p_information256     => l_ear_rec.plip_id,
            p_information262     => l_ear_rec.vrbl_rt_prfl_id,
            p_information265     => l_ear_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_ear_result_id is null then
                l_out_ear_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_ear_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_ENRLD_ANTHR_PLIP_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_ENRLD_ANTHR_PTIP_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_ent_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_enrld_anthr_ptip_rt_id := l_parent_rec.enrld_anthr_ptip_rt_id ;
          --
          for l_ent_rec in c_ent(l_parent_rec.enrld_anthr_ptip_rt_id,l_mirror_src_entity_result_id,'ENT') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('ENT');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_ptip_name(l_ent_rec.ptip_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_ent_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_ent_rec.effective_start_date
               and l_ent_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'ENT',
              p_information1     => l_ent_rec.enrld_anthr_ptip_rt_id,
              p_information2     => l_ent_rec.EFFECTIVE_START_DATE,
              p_information3     => l_ent_rec.EFFECTIVE_END_DATE,
              p_information4     => l_ent_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information11     => l_ent_rec.enrl_det_dt_cd,
            p_information111     => l_ent_rec.ent_attribute1,
            p_information120     => l_ent_rec.ent_attribute10,
            p_information121     => l_ent_rec.ent_attribute11,
            p_information122     => l_ent_rec.ent_attribute12,
            p_information123     => l_ent_rec.ent_attribute13,
            p_information124     => l_ent_rec.ent_attribute14,
            p_information125     => l_ent_rec.ent_attribute15,
            p_information126     => l_ent_rec.ent_attribute16,
            p_information127     => l_ent_rec.ent_attribute17,
            p_information128     => l_ent_rec.ent_attribute18,
            p_information129     => l_ent_rec.ent_attribute19,
            p_information112     => l_ent_rec.ent_attribute2,
            p_information130     => l_ent_rec.ent_attribute20,
            p_information131     => l_ent_rec.ent_attribute21,
            p_information132     => l_ent_rec.ent_attribute22,
            p_information133     => l_ent_rec.ent_attribute23,
            p_information134     => l_ent_rec.ent_attribute24,
            p_information135     => l_ent_rec.ent_attribute25,
            p_information136     => l_ent_rec.ent_attribute26,
            p_information137     => l_ent_rec.ent_attribute27,
            p_information138     => l_ent_rec.ent_attribute28,
            p_information139     => l_ent_rec.ent_attribute29,
            p_information113     => l_ent_rec.ent_attribute3,
            p_information140     => l_ent_rec.ent_attribute30,
            p_information114     => l_ent_rec.ent_attribute4,
            p_information115     => l_ent_rec.ent_attribute5,
            p_information116     => l_ent_rec.ent_attribute6,
            p_information117     => l_ent_rec.ent_attribute7,
            p_information118     => l_ent_rec.ent_attribute8,
            p_information119     => l_ent_rec.ent_attribute9,
            p_information110     => l_ent_rec.ent_attribute_category,
            p_information12     => l_ent_rec.excld_flag,
            p_information13     => l_ent_rec.only_pls_subj_cobra_flag,
            p_information261     => l_ent_rec.ordr_num,
            p_information259     => l_ent_rec.ptip_id,
            p_information262     => l_ent_rec.vrbl_rt_prfl_id,
            p_information265     => l_ent_rec.object_version_number,

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_ent_result_id is null then
                l_out_ent_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_ent_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_ENRLD_ANTHR_PTIP_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_ENRLD_ANTHR_PGM_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_epm_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_enrld_anthr_pgm_rt_id := l_parent_rec.enrld_anthr_pgm_rt_id ;
          --
          for l_epm_rec in c_epm(l_parent_rec.enrld_anthr_pgm_rt_id,l_mirror_src_entity_result_id,'EPM') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('EPM');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_pgm_name(l_epm_rec.pgm_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_epm_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_epm_rec.effective_start_date
               and l_epm_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'EPM',
              p_information1     => l_epm_rec.enrld_anthr_pgm_rt_id,
              p_information2     => l_epm_rec.EFFECTIVE_START_DATE,
              p_information3     => l_epm_rec.EFFECTIVE_END_DATE,
              p_information4     => l_epm_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information12     => l_epm_rec.enrl_det_dt_cd,
            p_information111     => l_epm_rec.epm_attribute1,
            p_information120     => l_epm_rec.epm_attribute10,
            p_information121     => l_epm_rec.epm_attribute11,
            p_information122     => l_epm_rec.epm_attribute12,
            p_information123     => l_epm_rec.epm_attribute13,
            p_information124     => l_epm_rec.epm_attribute14,
            p_information125     => l_epm_rec.epm_attribute15,
            p_information126     => l_epm_rec.epm_attribute16,
            p_information127     => l_epm_rec.epm_attribute17,
            p_information128     => l_epm_rec.epm_attribute18,
            p_information129     => l_epm_rec.epm_attribute19,
            p_information112     => l_epm_rec.epm_attribute2,
            p_information130     => l_epm_rec.epm_attribute20,
            p_information131     => l_epm_rec.epm_attribute21,
            p_information132     => l_epm_rec.epm_attribute22,
            p_information133     => l_epm_rec.epm_attribute23,
            p_information134     => l_epm_rec.epm_attribute24,
            p_information135     => l_epm_rec.epm_attribute25,
            p_information136     => l_epm_rec.epm_attribute26,
            p_information137     => l_epm_rec.epm_attribute27,
            p_information138     => l_epm_rec.epm_attribute28,
            p_information139     => l_epm_rec.epm_attribute29,
            p_information113     => l_epm_rec.epm_attribute3,
            p_information140     => l_epm_rec.epm_attribute30,
            p_information114     => l_epm_rec.epm_attribute4,
            p_information115     => l_epm_rec.epm_attribute5,
            p_information116     => l_epm_rec.epm_attribute6,
            p_information117     => l_epm_rec.epm_attribute7,
            p_information118     => l_epm_rec.epm_attribute8,
            p_information119     => l_epm_rec.epm_attribute9,
            p_information110     => l_epm_rec.epm_attribute_category,
            p_information11     => l_epm_rec.excld_flag,
            p_information257     => l_epm_rec.ordr_num,
            p_information260     => l_epm_rec.pgm_id,
            p_information262     => l_epm_rec.vrbl_rt_prfl_id,
            p_information265     => l_epm_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_epm_result_id is null then
                l_out_epm_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_epm_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_ENRLD_ANTHR_PGM_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_NO_OTHR_CVG_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_noc_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_no_othr_cvg_rt_id := l_parent_rec.no_othr_cvg_rt_id ;
          --
          for l_noc_rec in c_noc(l_parent_rec.no_othr_cvg_rt_id,l_mirror_src_entity_result_id,'NOC') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('NOC');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := hr_general.decode_lookup('YES_NO',l_noc_rec.coord_ben_no_cvg_flag);
                               --'Intersection';
            --
            if p_effective_date between l_noc_rec.effective_start_date
               and l_noc_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'NOC',
              p_information1     => l_noc_rec.no_othr_cvg_rt_id,
              p_information2     => l_noc_rec.EFFECTIVE_START_DATE,
              p_information3     => l_noc_rec.EFFECTIVE_END_DATE,
              p_information4     => l_noc_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_noc_rec.coord_ben_no_cvg_flag,
            p_information111     => l_noc_rec.noc_attribute1,
            p_information120     => l_noc_rec.noc_attribute10,
            p_information121     => l_noc_rec.noc_attribute11,
            p_information122     => l_noc_rec.noc_attribute12,
            p_information123     => l_noc_rec.noc_attribute13,
            p_information124     => l_noc_rec.noc_attribute14,
            p_information125     => l_noc_rec.noc_attribute15,
            p_information126     => l_noc_rec.noc_attribute16,
            p_information127     => l_noc_rec.noc_attribute17,
            p_information128     => l_noc_rec.noc_attribute18,
            p_information129     => l_noc_rec.noc_attribute19,
            p_information112     => l_noc_rec.noc_attribute2,
            p_information130     => l_noc_rec.noc_attribute20,
            p_information131     => l_noc_rec.noc_attribute21,
            p_information132     => l_noc_rec.noc_attribute22,
            p_information133     => l_noc_rec.noc_attribute23,
            p_information134     => l_noc_rec.noc_attribute24,
            p_information135     => l_noc_rec.noc_attribute25,
            p_information136     => l_noc_rec.noc_attribute26,
            p_information137     => l_noc_rec.noc_attribute27,
            p_information138     => l_noc_rec.noc_attribute28,
            p_information139     => l_noc_rec.noc_attribute29,
            p_information113     => l_noc_rec.noc_attribute3,
            p_information140     => l_noc_rec.noc_attribute30,
            p_information114     => l_noc_rec.noc_attribute4,
            p_information115     => l_noc_rec.noc_attribute5,
            p_information116     => l_noc_rec.noc_attribute6,
            p_information117     => l_noc_rec.noc_attribute7,
            p_information118     => l_noc_rec.noc_attribute8,
            p_information119     => l_noc_rec.noc_attribute9,
            p_information110     => l_noc_rec.noc_attribute_category,
            p_information262     => l_noc_rec.vrbl_rt_prfl_id,
            p_information265     => l_noc_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_noc_result_id is null then
                l_out_noc_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_noc_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_NO_OTHR_CVG_RT_F ----------------------
      ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_OPTD_MDCR_RT_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_omr_from_parent(l_VRBL_RT_PRFL_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_vpf_result_id ;
        --
        l_optd_mdcr_rt_id := l_parent_rec.optd_mdcr_rt_id ;
        --
        for l_omr_rec in c_omr(l_parent_rec.optd_mdcr_rt_id,l_mirror_src_entity_result_id,'OMR') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('OMR');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := hr_general.decode_lookup('YES_NO',l_omr_rec.optd_mdcr_flag)
                             || ben_plan_design_program_module.get_exclude_message(l_omr_rec.exlcd_flag);
          --
          if p_effective_date between l_omr_rec.effective_start_date
             and l_omr_rec.effective_end_date then
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
	    P_TABLE_ALIAS                    => 'OMR',
            p_information1     => l_omr_rec.optd_mdcr_rt_id,
            p_information2     => l_omr_rec.EFFECTIVE_START_DATE,
            p_information3     => l_omr_rec.EFFECTIVE_END_DATE,
            p_information4     => l_omr_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_omr_rec.exlcd_flag,
            p_information111     => l_omr_rec.omr_attribute1,
            p_information120     => l_omr_rec.omr_attribute10,
            p_information121     => l_omr_rec.omr_attribute11,
            p_information122     => l_omr_rec.omr_attribute12,
            p_information123     => l_omr_rec.omr_attribute13,
            p_information124     => l_omr_rec.omr_attribute14,
            p_information125     => l_omr_rec.omr_attribute15,
            p_information126     => l_omr_rec.omr_attribute16,
            p_information127     => l_omr_rec.omr_attribute17,
            p_information128     => l_omr_rec.omr_attribute18,
            p_information129     => l_omr_rec.omr_attribute19,
            p_information112     => l_omr_rec.omr_attribute2,
            p_information130     => l_omr_rec.omr_attribute20,
            p_information131     => l_omr_rec.omr_attribute21,
            p_information132     => l_omr_rec.omr_attribute22,
            p_information133     => l_omr_rec.omr_attribute23,
            p_information134     => l_omr_rec.omr_attribute24,
            p_information135     => l_omr_rec.omr_attribute25,
            p_information136     => l_omr_rec.omr_attribute26,
            p_information137     => l_omr_rec.omr_attribute27,
            p_information138     => l_omr_rec.omr_attribute28,
            p_information139     => l_omr_rec.omr_attribute29,
            p_information113     => l_omr_rec.omr_attribute3,
            p_information140     => l_omr_rec.omr_attribute30,
            p_information114     => l_omr_rec.omr_attribute4,
            p_information115     => l_omr_rec.omr_attribute5,
            p_information116     => l_omr_rec.omr_attribute6,
            p_information117     => l_omr_rec.omr_attribute7,
            p_information118     => l_omr_rec.omr_attribute8,
            p_information119     => l_omr_rec.omr_attribute9,
            p_information110     => l_omr_rec.omr_attribute_category,
            p_information11     => l_omr_rec.optd_mdcr_flag,
            p_information262     => l_omr_rec.vrbl_rt_prfl_id,
            p_information265     => l_omr_rec.object_version_number,
           --

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_omr_result_id is null then
              l_out_omr_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_omr_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_OPTD_MDCR_RT_F ----------------------
    ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_DPNT_OTHR_PTIP_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_dot_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_dpnt_othr_ptip_rt_id := l_parent_rec.dpnt_othr_ptip_rt_id ;
          --
          for l_dot_rec in c_dot(l_parent_rec.dpnt_othr_ptip_rt_id,l_mirror_src_entity_result_id,'DOT') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('DOT');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_ptip_name(l_dot_rec.ptip_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_dot_rec.excld_flag);
            --
            if p_effective_date between l_dot_rec.effective_start_date
               and l_dot_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'DOT',
              p_information1     => l_dot_rec.dpnt_othr_ptip_rt_id,
              p_information2     => l_dot_rec.EFFECTIVE_START_DATE,
              p_information3     => l_dot_rec.EFFECTIVE_END_DATE,
              p_information4     => l_dot_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_dot_rec.dot_attribute1,
            p_information120     => l_dot_rec.dot_attribute10,
            p_information121     => l_dot_rec.dot_attribute11,
            p_information122     => l_dot_rec.dot_attribute12,
            p_information123     => l_dot_rec.dot_attribute13,
            p_information124     => l_dot_rec.dot_attribute14,
            p_information125     => l_dot_rec.dot_attribute15,
            p_information126     => l_dot_rec.dot_attribute16,
            p_information127     => l_dot_rec.dot_attribute17,
            p_information128     => l_dot_rec.dot_attribute18,
            p_information129     => l_dot_rec.dot_attribute19,
            p_information112     => l_dot_rec.dot_attribute2,
            p_information130     => l_dot_rec.dot_attribute20,
            p_information131     => l_dot_rec.dot_attribute21,
            p_information132     => l_dot_rec.dot_attribute22,
            p_information133     => l_dot_rec.dot_attribute23,
            p_information134     => l_dot_rec.dot_attribute24,
            p_information135     => l_dot_rec.dot_attribute25,
            p_information136     => l_dot_rec.dot_attribute26,
            p_information137     => l_dot_rec.dot_attribute27,
            p_information138     => l_dot_rec.dot_attribute28,
            p_information139     => l_dot_rec.dot_attribute29,
            p_information113     => l_dot_rec.dot_attribute3,
            p_information140     => l_dot_rec.dot_attribute30,
            p_information114     => l_dot_rec.dot_attribute4,
            p_information115     => l_dot_rec.dot_attribute5,
            p_information116     => l_dot_rec.dot_attribute6,
            p_information117     => l_dot_rec.dot_attribute7,
            p_information118     => l_dot_rec.dot_attribute8,
            p_information119     => l_dot_rec.dot_attribute9,
            p_information110     => l_dot_rec.dot_attribute_category,
            p_information11     => l_dot_rec.excld_flag,
            p_information261     => l_dot_rec.ordr_num,
            p_information259     => l_dot_rec.ptip_id,
            p_information262     => l_dot_rec.vrbl_rt_prfl_id,
            p_information265     => l_dot_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_dot_result_id is null then
                l_out_dot_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_dot_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_DPNT_OTHR_PTIP_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_PERF_RTNG_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_prr_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_perf_rtng_rt_id := l_parent_rec.perf_rtng_rt_id ;
          --
          for l_prr_rec in c_prr(l_parent_rec.perf_rtng_rt_id,l_mirror_src_entity_result_id,'PRR') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('PRR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := hr_general.decode_lookup('EMP_INTERVIEW_TYPE',l_prr_rec.event_type)
                               ||' - '||hr_general.decode_lookup('PERFORMANCE_RATING',l_prr_rec.perf_rtng_cd)
                               || ben_plan_design_program_module.get_exclude_message(l_prr_rec.excld_flag);
                                 --'Intersection';
            --
            if p_effective_date between l_prr_rec.effective_start_date
               and l_prr_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'PRR',
              p_information1     => l_prr_rec.perf_rtng_rt_id,
              p_information2     => l_prr_rec.EFFECTIVE_START_DATE,
              p_information3     => l_prr_rec.EFFECTIVE_END_DATE,
              p_information4     => l_prr_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information13     => l_prr_rec.event_type,
            p_information11     => l_prr_rec.excld_flag,
            p_information257     => l_prr_rec.ordr_num,
            p_information12     => l_prr_rec.perf_rtng_cd,
            p_information111     => l_prr_rec.prr_attribute1,
            p_information120     => l_prr_rec.prr_attribute10,
            p_information121     => l_prr_rec.prr_attribute11,
            p_information122     => l_prr_rec.prr_attribute12,
            p_information123     => l_prr_rec.prr_attribute13,
            p_information124     => l_prr_rec.prr_attribute14,
            p_information125     => l_prr_rec.prr_attribute15,
            p_information126     => l_prr_rec.prr_attribute16,
            p_information127     => l_prr_rec.prr_attribute17,
            p_information128     => l_prr_rec.prr_attribute18,
            p_information129     => l_prr_rec.prr_attribute19,
            p_information112     => l_prr_rec.prr_attribute2,
            p_information130     => l_prr_rec.prr_attribute20,
            p_information131     => l_prr_rec.prr_attribute21,
            p_information132     => l_prr_rec.prr_attribute22,
            p_information133     => l_prr_rec.prr_attribute23,
            p_information134     => l_prr_rec.prr_attribute24,
            p_information135     => l_prr_rec.prr_attribute25,
            p_information136     => l_prr_rec.prr_attribute26,
            p_information137     => l_prr_rec.prr_attribute27,
            p_information138     => l_prr_rec.prr_attribute28,
            p_information139     => l_prr_rec.prr_attribute29,
            p_information113     => l_prr_rec.prr_attribute3,
            p_information140     => l_prr_rec.prr_attribute30,
            p_information114     => l_prr_rec.prr_attribute4,
            p_information115     => l_prr_rec.prr_attribute5,
            p_information116     => l_prr_rec.prr_attribute6,
            p_information117     => l_prr_rec.prr_attribute7,
            p_information118     => l_prr_rec.prr_attribute8,
            p_information119     => l_prr_rec.prr_attribute9,
            p_information110     => l_prr_rec.prr_attribute_category,
            p_information262     => l_prr_rec.vrbl_rt_prfl_id,
            p_information265     => l_prr_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_prr_result_id is null then
                l_out_prr_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_prr_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_PERF_RTNG_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_QUA_IN_GR_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_qig_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_qua_in_gr_rt_id := l_parent_rec.qua_in_gr_rt_id ;
          --
          for l_qig_rec in c_qig(l_parent_rec.qua_in_gr_rt_id,l_mirror_src_entity_result_id,'QIG') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('QIG');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := hr_general.decode_lookup('BEN_CWB_QUAR_IN_GRD',l_qig_rec.quar_in_grade_cd)
                               || ben_plan_design_program_module.get_exclude_message(l_qig_rec.excld_flag);
                               -- 'Intersection';
            --
            if p_effective_date between l_qig_rec.effective_start_date
               and l_qig_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'QIG',
              p_information1     => l_qig_rec.qua_in_gr_rt_id,
              p_information2     => l_qig_rec.EFFECTIVE_START_DATE,
              p_information3     => l_qig_rec.EFFECTIVE_END_DATE,
              p_information4     => l_qig_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information12     => l_qig_rec.excld_flag,
            p_information257     => l_qig_rec.ordr_num,
            p_information111     => l_qig_rec.qig_attribute1,
            p_information120     => l_qig_rec.qig_attribute10,
            p_information121     => l_qig_rec.qig_attribute11,
            p_information122     => l_qig_rec.qig_attribute12,
            p_information123     => l_qig_rec.qig_attribute13,
            p_information124     => l_qig_rec.qig_attribute14,
            p_information125     => l_qig_rec.qig_attribute15,
            p_information126     => l_qig_rec.qig_attribute16,
            p_information127     => l_qig_rec.qig_attribute17,
            p_information128     => l_qig_rec.qig_attribute18,
            p_information129     => l_qig_rec.qig_attribute19,
            p_information112     => l_qig_rec.qig_attribute2,
            p_information130     => l_qig_rec.qig_attribute20,
            p_information131     => l_qig_rec.qig_attribute21,
            p_information132     => l_qig_rec.qig_attribute22,
            p_information133     => l_qig_rec.qig_attribute23,
            p_information134     => l_qig_rec.qig_attribute24,
            p_information135     => l_qig_rec.qig_attribute25,
            p_information136     => l_qig_rec.qig_attribute26,
            p_information137     => l_qig_rec.qig_attribute27,
            p_information138     => l_qig_rec.qig_attribute28,
            p_information139     => l_qig_rec.qig_attribute29,
            p_information113     => l_qig_rec.qig_attribute3,
            p_information140     => l_qig_rec.qig_attribute30,
            p_information114     => l_qig_rec.qig_attribute4,
            p_information115     => l_qig_rec.qig_attribute5,
            p_information116     => l_qig_rec.qig_attribute6,
            p_information117     => l_qig_rec.qig_attribute7,
            p_information118     => l_qig_rec.qig_attribute8,
            p_information119     => l_qig_rec.qig_attribute9,
            p_information110     => l_qig_rec.qig_attribute_category,
            p_information11     => l_qig_rec.quar_in_grade_cd,
            p_information262     => l_qig_rec.vrbl_rt_prfl_id,
            p_information265     => l_qig_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_qig_result_id is null then
                l_out_qig_result_id := l_copy_entity_result_id;
              end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_qig_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_QUA_IN_GR_RT_F ----------------------
      ---------------------------------------------------------------
       ---------------------------------------------------------------
       -- START OF BEN_OTHR_PTIP_RT_F ----------------------
       ---------------------------------------------------------------
       --
       for l_parent_rec  in c_opr_from_parent(l_VRBL_RT_PRFL_ID) loop
          --
          l_mirror_src_entity_result_id := l_out_vpf_result_id ;
          --
          l_othr_ptip_rt_id := l_parent_rec.othr_ptip_rt_id ;
          --
          for l_opr_rec in c_opr(l_parent_rec.othr_ptip_rt_id,l_mirror_src_entity_result_id,'OPR') loop
            --
            l_table_route_id := null ;
            open ben_plan_design_program_module.g_table_route('OPR');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
            close ben_plan_design_program_module.g_table_route ;
            --
            l_information5  := ben_plan_design_program_module.get_ptip_name(l_opr_rec.ptip_id,p_effective_date)
                               || ben_plan_design_program_module.get_exclude_message(l_opr_rec.excld_flag);
                               --'Intersection';
            --
            if p_effective_date between l_opr_rec.effective_start_date
               and l_opr_rec.effective_end_date then
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
	      P_TABLE_ALIAS                    => 'OPR',
              p_information1     => l_opr_rec.othr_ptip_rt_id,
              p_information2     => l_opr_rec.EFFECTIVE_START_DATE,
              p_information3     => l_opr_rec.EFFECTIVE_END_DATE,
              p_information4     => l_opr_rec.business_group_id,
              p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information11     => l_opr_rec.excld_flag,
            p_information12     => l_opr_rec.only_pls_subj_cobra_flag,
            p_information111     => l_opr_rec.opr_attribute1,
            p_information120     => l_opr_rec.opr_attribute10,
            p_information121     => l_opr_rec.opr_attribute11,
            p_information122     => l_opr_rec.opr_attribute12,
            p_information123     => l_opr_rec.opr_attribute13,
            p_information124     => l_opr_rec.opr_attribute14,
            p_information125     => l_opr_rec.opr_attribute15,
            p_information126     => l_opr_rec.opr_attribute16,
            p_information127     => l_opr_rec.opr_attribute17,
            p_information128     => l_opr_rec.opr_attribute18,
            p_information129     => l_opr_rec.opr_attribute19,
            p_information112     => l_opr_rec.opr_attribute2,
            p_information130     => l_opr_rec.opr_attribute20,
            p_information131     => l_opr_rec.opr_attribute21,
            p_information132     => l_opr_rec.opr_attribute22,
            p_information133     => l_opr_rec.opr_attribute23,
            p_information134     => l_opr_rec.opr_attribute24,
            p_information135     => l_opr_rec.opr_attribute25,
            p_information136     => l_opr_rec.opr_attribute26,
            p_information137     => l_opr_rec.opr_attribute27,
            p_information138     => l_opr_rec.opr_attribute28,
            p_information139     => l_opr_rec.opr_attribute29,
            p_information113     => l_opr_rec.opr_attribute3,
            p_information140     => l_opr_rec.opr_attribute30,
            p_information114     => l_opr_rec.opr_attribute4,
            p_information115     => l_opr_rec.opr_attribute5,
            p_information116     => l_opr_rec.opr_attribute6,
            p_information117     => l_opr_rec.opr_attribute7,
            p_information118     => l_opr_rec.opr_attribute8,
            p_information119     => l_opr_rec.opr_attribute9,
            p_information110     => l_opr_rec.opr_attribute_category,
            p_information257     => l_opr_rec.ordr_num,
            p_information259     => l_opr_rec.ptip_id,
            p_information262     => l_opr_rec.vrbl_rt_prfl_id,
            p_information265     => l_opr_rec.object_version_number,
           --

              p_object_version_number          => l_object_version_number,
              p_effective_date                 => p_effective_date       );
              --

              if l_out_opr_result_id is null then
                 l_out_opr_result_id := l_copy_entity_result_id;
               end if;

              if l_result_type_cd = 'DISPLAY' then
                 l_out_opr_result_id := l_copy_entity_result_id ;
              end if;
              --
           end loop;
           --
         end loop;
      ---------------------------------------------------------------
      -- END OF BEN_OTHR_PTIP_RT_F ----------------------
      ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- END OF BEN_VRBL_RT_PRFL_F ----------------------
     ---------------------------------------------------------------
         hr_utility.set_location(' end create_vapro_results  ',100);
   end create_vapro_results;
  --
  procedure create_bnft_pool_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_BNFT_PRVDR_POOL_F ----------------------
   ---------------------------------------------------------------
   cursor c_bpp_from_parent( c_pgm_id number,c_ptip_id number,c_plip_id number, c_oiplip_id number,
                            c_cmbn_plip_id number, c_cmbn_ptip_id number,
                            c_cmbn_ptip_opt_id number ) is
   select  bnft_prvdr_pool_id
   from BEN_BNFT_PRVDR_POOL_F
   where  (c_pgm_id is not null     and c_pgm_id           = pgm_id
           and ptip_id is null      and plip_id is null
           and oiplip_id is null    and cmbn_plip_id is null
           and cmbn_ptip_id is null and cmbn_ptip_opt_id is null
           ) or
          (c_ptip_id          is not null and c_ptip_id          = ptip_id) or
          (c_plip_id          is not null and c_plip_id          = plip_id) or
          (c_oiplip_id        is not null and c_oiplip_id        = oiplip_id) or
          (c_cmbn_plip_id     is not null and c_cmbn_plip_id     = cmbn_plip_id) or
          (c_cmbn_ptip_id     is not null and c_cmbn_ptip_id     = cmbn_ptip_id) or
          (c_cmbn_ptip_opt_id is not null and c_cmbn_ptip_opt_id = cmbn_ptip_opt_id ) ;
   --
   cursor c_bpp(c_bnft_prvdr_pool_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  bpp.*
   from BEN_BNFT_PRVDR_POOL_F bpp
   where  bpp.bnft_prvdr_pool_id = c_bnft_prvdr_pool_id
     --and bpp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BNFT_PRVDR_POOL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_bnft_prvdr_pool_id
         -- and information4 = bpp.business_group_id
           and information2 = bpp.effective_start_date
           and information3 = bpp.effective_end_date);
    l_bnft_prvdr_pool_id                 number(15);
    l_out_bpp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BNFT_PRVDR_POOL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_APLCN_TO_BNFT_POOL_F ----------------------
   ---------------------------------------------------------------
   cursor c_abp_from_parent(c_BNFT_PRVDR_POOL_ID number) is
   select  aplcn_to_bnft_pool_id
   from BEN_APLCN_TO_BNFT_POOL_F
   where  BNFT_PRVDR_POOL_ID = c_BNFT_PRVDR_POOL_ID ;
   --
   cursor c_abp(c_aplcn_to_bnft_pool_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  abp.*
   from BEN_APLCN_TO_BNFT_POOL_F abp
   where  abp.aplcn_to_bnft_pool_id = c_aplcn_to_bnft_pool_id
     --and abp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_APLCN_TO_BNFT_POOL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_aplcn_to_bnft_pool_id
         -- and information4 = abp.business_group_id
           and information2 = abp.effective_start_date
           and information3 = abp.effective_end_date);
    l_aplcn_to_bnft_pool_id                 number(15);
    l_out_abp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_APLCN_TO_BNFT_POOL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_BNFT_POOL_RLOVR_RQMT_F ----------------------
   ---------------------------------------------------------------
   cursor c_bpr_from_parent(c_BNFT_PRVDR_POOL_ID number) is
   select  bnft_pool_rlovr_rqmt_id
   from BEN_BNFT_POOL_RLOVR_RQMT_F
   where  BNFT_PRVDR_POOL_ID = c_BNFT_PRVDR_POOL_ID ;
   --
   cursor c_bpr(c_bnft_pool_rlovr_rqmt_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  bpr.*
   from BEN_BNFT_POOL_RLOVR_RQMT_F bpr
   where  bpr.bnft_pool_rlovr_rqmt_id = c_bnft_pool_rlovr_rqmt_id
     --and bpr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BNFT_POOL_RLOVR_RQMT_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_bnft_pool_rlovr_rqmt_id
         -- and information4 = bpr.business_group_id
           and information2 = bpr.effective_start_date
           and information3 = bpr.effective_end_date);
    l_bnft_pool_rlovr_rqmt_id                 number(15);
    l_out_bpr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BNFT_POOL_RLOVR_RQMT_F ----------------------
   ---------------------------------------------------------------
 begin
   l_number_of_copies := p_number_of_copies ;
   --
     ---------------------------------------------------------------
     -- START OF BEN_BNFT_PRVDR_POOL_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_bpp_from_parent(p_pgm_id,p_ptip_id,p_plip_id,
                            p_oiplip_id,p_cmbn_plip_id,p_cmbn_ptip_id,p_cmbn_ptip_opt_id) loop
      --
      l_mirror_src_entity_result_id := p_copy_entity_result_id ;

      --
      l_bnft_prvdr_pool_id := l_parent_rec.bnft_prvdr_pool_id ;
      --
      for l_bpp_rec in c_bpp(l_parent_rec.bnft_prvdr_pool_id,l_mirror_src_entity_result_id,'BPP') loop
      --

          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('BPP');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_bpp_rec.name; --'Intersection';
          --
          if p_effective_date between l_bpp_rec.effective_start_date
             and l_bpp_rec.effective_end_date then
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
            p_parent_entity_result_id        => p_parent_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'BPP',
            p_information1     => l_bpp_rec.bnft_prvdr_pool_id,
            p_information2     => l_bpp_rec.EFFECTIVE_START_DATE,
            p_information3     => l_bpp_rec.EFFECTIVE_END_DATE,
            p_information4     => l_bpp_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information16     => l_bpp_rec.alws_ngtv_crs_flag,
            p_information25     => l_bpp_rec.auto_alct_excs_flag,
            p_information111     => l_bpp_rec.bpp_attribute1,
            p_information120     => l_bpp_rec.bpp_attribute10,
            p_information121     => l_bpp_rec.bpp_attribute11,
            p_information122     => l_bpp_rec.bpp_attribute12,
            p_information123     => l_bpp_rec.bpp_attribute13,
            p_information124     => l_bpp_rec.bpp_attribute14,
            p_information125     => l_bpp_rec.bpp_attribute15,
            p_information126     => l_bpp_rec.bpp_attribute16,
            p_information127     => l_bpp_rec.bpp_attribute17,
            p_information128     => l_bpp_rec.bpp_attribute18,
            p_information129     => l_bpp_rec.bpp_attribute19,
            p_information112     => l_bpp_rec.bpp_attribute2,
            p_information130     => l_bpp_rec.bpp_attribute20,
            p_information131     => l_bpp_rec.bpp_attribute21,
            p_information132     => l_bpp_rec.bpp_attribute22,
            p_information133     => l_bpp_rec.bpp_attribute23,
            p_information134     => l_bpp_rec.bpp_attribute24,
            p_information135     => l_bpp_rec.bpp_attribute25,
            p_information136     => l_bpp_rec.bpp_attribute26,
            p_information137     => l_bpp_rec.bpp_attribute27,
            p_information138     => l_bpp_rec.bpp_attribute28,
            p_information139     => l_bpp_rec.bpp_attribute29,
            p_information113     => l_bpp_rec.bpp_attribute3,
            p_information140     => l_bpp_rec.bpp_attribute30,
            p_information114     => l_bpp_rec.bpp_attribute4,
            p_information115     => l_bpp_rec.bpp_attribute5,
            p_information116     => l_bpp_rec.bpp_attribute6,
            p_information117     => l_bpp_rec.bpp_attribute7,
            p_information118     => l_bpp_rec.bpp_attribute8,
            p_information119     => l_bpp_rec.bpp_attribute9,
            p_information110     => l_bpp_rec.bpp_attribute_category,
            p_information239     => l_bpp_rec.cmbn_plip_id,
            p_information236     => l_bpp_rec.cmbn_ptip_id,
            p_information249     => l_bpp_rec.cmbn_ptip_opt_id,
            p_information254     => l_bpp_rec.comp_lvl_fctr_id,
            p_information13     => l_bpp_rec.dflt_excs_trtmt_cd,
            p_information262     => l_bpp_rec.dflt_excs_trtmt_rl,
            p_information19     => l_bpp_rec.excs_alwys_fftd_flag,
            p_information15     => l_bpp_rec.excs_trtmt_cd,
            p_information263     => l_bpp_rec.mn_dstrbl_pct_num,
            p_information293     => l_bpp_rec.mn_dstrbl_val,
            p_information296     => l_bpp_rec.mx_dfcit_pct_comp_num,
            p_information295     => l_bpp_rec.mx_dfcit_pct_pool_crs_num,
            p_information264     => l_bpp_rec.mx_dstrbl_pct_num,
            p_information294     => l_bpp_rec.mx_dstrbl_val,
            p_information170     => l_bpp_rec.name,
            p_information21     => l_bpp_rec.no_mn_dstrbl_pct_flag,
            p_information22     => l_bpp_rec.no_mn_dstrbl_val_flag,
            p_information23     => l_bpp_rec.no_mx_dstrbl_pct_flag,
            p_information24     => l_bpp_rec.no_mx_dstrbl_val_flag,
            p_information227     => l_bpp_rec.oiplip_id,
            p_information11     => l_bpp_rec.pct_rndg_cd,
            p_information266     => l_bpp_rec.pct_rndg_rl,
            p_information260     => l_bpp_rec.pgm_id,
            p_information18     => l_bpp_rec.pgm_pool_flag,
            p_information256     => l_bpp_rec.plip_id,
            p_information259     => l_bpp_rec.ptip_id,
            p_information14     => l_bpp_rec.rlovr_rstrcn_cd,
            p_information20     => l_bpp_rec.use_for_pgm_pool_flag,
            p_information17     => l_bpp_rec.uses_net_crs_mthd_flag,
            p_information12     => l_bpp_rec.val_rndg_cd,
            p_information267     => l_bpp_rec.val_rndg_rl,
            p_information265    => l_bpp_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_bpp_result_id is null then
              l_out_bpp_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_bpp_result_id := l_copy_entity_result_id ;
            end if;
            --

            if l_bpp_rec.comp_lvl_fctr_id is not null then
              --
              create_drpar_results
                 (
                   p_validate                      => p_validate
                  ,p_copy_entity_result_id         => l_copy_entity_result_id
                  ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                  ,p_comp_lvl_fctr_id              => l_bpp_rec.comp_lvl_fctr_id
                  ,p_hrs_wkd_in_perd_fctr_id       => null
                  ,p_los_fctr_id                   => null
                  ,p_pct_fl_tm_fctr_id             => null
                  ,p_age_fctr_id                   => null
                  ,p_cmbn_age_los_fctr_id          => null
                  ,p_business_group_id             => p_business_group_id
                  ,p_number_of_copies              => p_number_of_copies
                  ,p_object_version_number         => l_object_version_number
                  ,p_effective_date                => p_effective_date
                 );
              --
            end if;


           -- If there are any Fast formulas attached to any columns copy the formulas
           -- also

           ---------------------------------------------------------------
                     -- DFLT_EXCS_TRTMT_RL --
                     ---------------------------------------------------------------
                     --
                     if l_bpp_rec.dflt_excs_trtmt_rl is not null then
                            --
                            ben_plan_design_program_module.create_formula_result
                            (
                             p_validate                       =>  0
                            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                            ,p_formula_id                     =>  l_bpp_rec.dflt_excs_trtmt_rl
                            ,p_business_group_id              =>  l_bpp_rec.business_group_id
                            ,p_number_of_copies               =>  l_number_of_copies
                            ,p_object_version_number          =>  l_object_version_number
                            ,p_effective_date                 =>  p_effective_date
                            );

                            --
                     end if;
           --

           ---------------------------------------------------------------
                     -- PCT_RNDG_RL --
                     ---------------------------------------------------------------
                     --
                     if l_bpp_rec.pct_rndg_rl is not null then
                            --
                            ben_plan_design_program_module.create_formula_result
                            (
                             p_validate                       =>  0
                            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                            ,p_formula_id                     =>  l_bpp_rec.pct_rndg_rl
                            ,p_business_group_id              =>  l_bpp_rec.business_group_id
                            ,p_number_of_copies               =>  l_number_of_copies
                            ,p_object_version_number          =>  l_object_version_number
                            ,p_effective_date                 =>  p_effective_date
                            );

                            --
                     end if;
           --

           ---------------------------------------------------------------
                     -- VAL_RNDG_RL --
                     ---------------------------------------------------------------
                     --
                     if l_bpp_rec.val_rndg_rl is not null then
                            --
                            ben_plan_design_program_module.create_formula_result
                            (
                             p_validate                       =>  0
                            ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                            ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                            ,p_formula_id                     =>  l_bpp_rec.val_rndg_rl
                            ,p_business_group_id              =>  l_bpp_rec.business_group_id
                            ,p_number_of_copies               =>  l_number_of_copies
                            ,p_object_version_number          =>  l_object_version_number
                            ,p_effective_date                 =>  p_effective_date
                            );

                            --
                     end if;
           --
      end loop;
         --
        ---------------------------------------------------------------
        -- START OF BEN_APLCN_TO_BNFT_POOL_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_abp_from_parent(l_BNFT_PRVDR_POOL_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_bpp_result_id ;

           --
           l_aplcn_to_bnft_pool_id := l_parent_rec.aplcn_to_bnft_pool_id ;
           --
           for l_abp_rec in c_abp(l_parent_rec.aplcn_to_bnft_pool_id,l_mirror_src_entity_result_id,'ABP') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('ABP');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_acty_base_rt_name(l_abp_rec.acty_base_rt_id
                                                                                     ,p_effective_date); --'Intersection';
             --
             if p_effective_date between l_abp_rec.effective_start_date
                and l_abp_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'ABP',
               p_information1     => l_abp_rec.aplcn_to_bnft_pool_id,
               p_information2     => l_abp_rec.EFFECTIVE_START_DATE,
               p_information3     => l_abp_rec.EFFECTIVE_END_DATE,
               p_information4     => l_abp_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_abp_rec.abp_attribute1,
            p_information120     => l_abp_rec.abp_attribute10,
            p_information121     => l_abp_rec.abp_attribute11,
            p_information122     => l_abp_rec.abp_attribute12,
            p_information123     => l_abp_rec.abp_attribute13,
            p_information124     => l_abp_rec.abp_attribute14,
            p_information125     => l_abp_rec.abp_attribute15,
            p_information126     => l_abp_rec.abp_attribute16,
            p_information127     => l_abp_rec.abp_attribute17,
            p_information128     => l_abp_rec.abp_attribute18,
            p_information129     => l_abp_rec.abp_attribute19,
            p_information112     => l_abp_rec.abp_attribute2,
            p_information130     => l_abp_rec.abp_attribute20,
            p_information131     => l_abp_rec.abp_attribute21,
            p_information132     => l_abp_rec.abp_attribute22,
            p_information133     => l_abp_rec.abp_attribute23,
            p_information134     => l_abp_rec.abp_attribute24,
            p_information135     => l_abp_rec.abp_attribute25,
            p_information136     => l_abp_rec.abp_attribute26,
            p_information137     => l_abp_rec.abp_attribute27,
            p_information138     => l_abp_rec.abp_attribute28,
            p_information139     => l_abp_rec.abp_attribute29,
            p_information113     => l_abp_rec.abp_attribute3,
            p_information140     => l_abp_rec.abp_attribute30,
            p_information114     => l_abp_rec.abp_attribute4,
            p_information115     => l_abp_rec.abp_attribute5,
            p_information116     => l_abp_rec.abp_attribute6,
            p_information117     => l_abp_rec.abp_attribute7,
            p_information118     => l_abp_rec.abp_attribute8,
            p_information119     => l_abp_rec.abp_attribute9,
            p_information110     => l_abp_rec.abp_attribute_category,
            p_information253     => l_abp_rec.acty_base_rt_id,
            p_information235     => l_abp_rec.bnft_prvdr_pool_id,
            p_information265     => l_abp_rec.object_version_number,
               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_abp_result_id is null then
                 l_out_abp_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_abp_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;
            --
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_APLCN_TO_BNFT_POOL_F ----------------------
       ---------------------------------------------------------------
        ---------------------------------------------------------------
        -- START OF BEN_BNFT_POOL_RLOVR_RQMT_F ----------------------
        ---------------------------------------------------------------
        --
        for l_parent_rec  in c_bpr_from_parent(l_BNFT_PRVDR_POOL_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_bpp_result_id ;

           --
           l_bnft_pool_rlovr_rqmt_id := l_parent_rec.bnft_pool_rlovr_rqmt_id ;
           --
           for l_bpr_rec in c_bpr(l_parent_rec.bnft_pool_rlovr_rqmt_id,l_mirror_src_entity_result_id,'BPR1') loop
             --
             l_table_route_id := null ;
             open ben_plan_design_program_module.g_table_route('BPR1');
             fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
             close ben_plan_design_program_module.g_table_route ;
             --
             l_information5  := ben_plan_design_program_module.get_acty_base_rt_name(l_bpr_rec.acty_base_rt_id
                                                                                     ,p_effective_date); --'Intersection';
             --
             if p_effective_date between l_bpr_rec.effective_start_date
                and l_bpr_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'BPR1',
               p_information1     => l_bpr_rec.bnft_pool_rlovr_rqmt_id,
               p_information2     => l_bpr_rec.EFFECTIVE_START_DATE,
               p_information3     => l_bpr_rec.EFFECTIVE_END_DATE,
               p_information4     => l_bpr_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information253     => l_bpr_rec.acty_base_rt_id,
            p_information235     => l_bpr_rec.bnft_prvdr_pool_id,
            p_information111     => l_bpr_rec.bpr_attribute1,
            p_information120     => l_bpr_rec.bpr_attribute10,
            p_information121     => l_bpr_rec.bpr_attribute11,
            p_information122     => l_bpr_rec.bpr_attribute12,
            p_information123     => l_bpr_rec.bpr_attribute13,
            p_information124     => l_bpr_rec.bpr_attribute14,
            p_information125     => l_bpr_rec.bpr_attribute15,
            p_information126     => l_bpr_rec.bpr_attribute16,
            p_information127     => l_bpr_rec.bpr_attribute17,
            p_information128     => l_bpr_rec.bpr_attribute18,
            p_information129     => l_bpr_rec.bpr_attribute19,
            p_information112     => l_bpr_rec.bpr_attribute2,
            p_information130     => l_bpr_rec.bpr_attribute20,
            p_information131     => l_bpr_rec.bpr_attribute21,
            p_information132     => l_bpr_rec.bpr_attribute22,
            p_information133     => l_bpr_rec.bpr_attribute23,
            p_information134     => l_bpr_rec.bpr_attribute24,
            p_information135     => l_bpr_rec.bpr_attribute25,
            p_information136     => l_bpr_rec.bpr_attribute26,
            p_information137     => l_bpr_rec.bpr_attribute27,
            p_information138     => l_bpr_rec.bpr_attribute28,
            p_information139     => l_bpr_rec.bpr_attribute29,
            p_information113     => l_bpr_rec.bpr_attribute3,
            p_information140     => l_bpr_rec.bpr_attribute30,
            p_information114     => l_bpr_rec.bpr_attribute4,
            p_information115     => l_bpr_rec.bpr_attribute5,
            p_information116     => l_bpr_rec.bpr_attribute6,
            p_information117     => l_bpr_rec.bpr_attribute7,
            p_information118     => l_bpr_rec.bpr_attribute8,
            p_information119     => l_bpr_rec.bpr_attribute9,
            p_information110     => l_bpr_rec.bpr_attribute_category,
            p_information11     => l_bpr_rec.crs_rlovr_procg_cd,
            p_information258     => l_bpr_rec.mn_rlovr_pct_num,
            p_information293     => l_bpr_rec.mn_rlovr_val,
            p_information261     => l_bpr_rec.mx_pct_ttl_crs_cn_roll_num,
            p_information270     => l_bpr_rec.mx_rchd_dflt_ordr_num,
            p_information259     => l_bpr_rec.mx_rlovr_pct_num,
            p_information294     => l_bpr_rec.mx_rlovr_val,
            p_information12     => l_bpr_rec.no_mn_rlovr_pct_dfnd_flag,
            p_information14     => l_bpr_rec.no_mn_rlovr_val_dfnd_flag,
            p_information13     => l_bpr_rec.no_mx_rlovr_pct_dfnd_flag,
            p_information15     => l_bpr_rec.no_mx_rlovr_val_dfnd_flag,
            p_information257     => l_bpr_rec.pct_rlovr_incrmt_num,
            p_information17     => l_bpr_rec.pct_rndg_cd,
            p_information263     => l_bpr_rec.pct_rndg_rl,
            p_information260     => l_bpr_rec.prtt_elig_rlovr_rl,
            p_information268     => l_bpr_rec.rlovr_val_incrmt_num,
            p_information269     => l_bpr_rec.rlovr_val_rl,
            p_information16     => l_bpr_rec.val_rndg_cd,
            p_information262     => l_bpr_rec.val_rndg_rl,
            p_information265    => l_bpr_rec.object_version_number,

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_bpr_result_id is null then
                 l_out_bpr_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_bpr_result_id := l_copy_entity_result_id ;
               end if;
               --

               -- If a Fast formula exists for any columns the copy Fast Formula Data also

               ---------------------------------------------------------------
                             -- PCT_RNDG_RL --
                             ---------------------------------------------------------------
                             --
                             if l_bpr_rec.pct_rndg_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_bpr_rec.pct_rndg_rl
                                    ,p_business_group_id              =>  l_bpr_rec.business_group_id
                                    ,p_number_of_copies               =>  l_number_of_copies
                                    ,p_object_version_number          =>  l_object_version_number
                                    ,p_effective_date                 =>  p_effective_date
                                    );

                                    --
                             end if;
               --

               ---------------------------------------------------------------
                             -- PRTT_ELIG_RLOVR_RL --
                             ---------------------------------------------------------------
                             --
                             if l_bpr_rec.prtt_elig_rlovr_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_bpr_rec.prtt_elig_rlovr_rl
                                    ,p_business_group_id              =>  l_bpr_rec.business_group_id
                                    ,p_number_of_copies               =>  l_number_of_copies
                                    ,p_object_version_number          =>  l_object_version_number
                                    ,p_effective_date                 =>  p_effective_date
                                    );

                                    --
                             end if;
                             --

               ---------------------------------------------------------------
                             -- RLOVR_VAL_RL --
                             ---------------------------------------------------------------
                             --
                             if l_bpr_rec.rlovr_val_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_bpr_rec.rlovr_val_rl
                                    ,p_business_group_id              =>  l_bpr_rec.business_group_id
                                    ,p_number_of_copies               =>  l_number_of_copies
                                    ,p_object_version_number          =>  l_object_version_number
                                    ,p_effective_date                 =>  p_effective_date
                                    );

                                    --
                             end if;
                             --
                             ---------------------------------------------------------------
                             -- VAL_RNDG_RL --
                             ---------------------------------------------------------------
                             --
                             if l_bpr_rec.val_rndg_rl is not null then
                                    --
                                    ben_plan_design_program_module.create_formula_result
                                    (
                                     p_validate                       =>  0
                                    ,p_copy_entity_result_id          =>  l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                                    ,p_formula_id                     =>  l_bpr_rec.val_rndg_rl
                                    ,p_business_group_id              =>  l_bpr_rec.business_group_id
                                    ,p_number_of_copies               =>  l_number_of_copies
                                    ,p_object_version_number          =>  l_object_version_number
                                    ,p_effective_date                 =>  p_effective_date
                                    );

                                    --
                             end if;
                             --

            end loop;
            --
          end loop;

       ---------------------------------------------------------------
       -- END OF BEN_BNFT_POOL_RLOVR_RQMT_F ----------------------
       ---------------------------------------------------------------
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_BNFT_PRVDR_POOL_F ----------------------
    ---------------------------------------------------------------
   --
 end ;
 --
 procedure create_service_results
   (
    p_validate                       in  number     default 0 -- false
   ,p_copy_entity_result_id          in  number    -- Source Elpro
   ,p_copy_entity_txn_id             in  number    default null
   ,p_svc_area_id                    in  number
   ,p_business_group_id              in  number    default null
   ,p_number_of_copies               in  number    default 0
   ,p_object_version_number          out nocopy number
   ,p_effective_date                 in  date
   ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_SVC_AREA_F ----------------------
   ---------------------------------------------------------------
   cursor c_sva(c_svc_area_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  sva.*
   from BEN_SVC_AREA_F sva
   where  sva.svc_area_id = c_svc_area_id
     --and sva.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_SVC_AREA_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_svc_area_id
         -- and information4 = sva.business_group_id
           and information2 = sva.effective_start_date
           and information3 = sva.effective_end_date);
    l_svc_area_id                 number(15);
    l_out_sva_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_SVC_AREA_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_SVC_AREA_PSTL_ZIP_RNG_F ----------------------
   ---------------------------------------------------------------
   cursor c_saz_from_parent(c_SVC_AREA_ID number) is
   select distinct svc_area_pstl_zip_rng_id
   from BEN_SVC_AREA_PSTL_ZIP_RNG_F
   where  SVC_AREA_ID = c_SVC_AREA_ID ;
   --
   cursor c_saz(c_svc_area_pstl_zip_rng_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select  saz.*
   from BEN_SVC_AREA_PSTL_ZIP_RNG_F saz
   where  saz.svc_area_pstl_zip_rng_id = c_svc_area_pstl_zip_rng_id
     --and saz.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_SVC_AREA_PSTL_ZIP_RNG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_svc_area_pstl_zip_rng_id
         -- and information4 = saz.business_group_id
           and information2 = saz.effective_start_date
           and information3 = saz.effective_end_date);
    l_svc_area_pstl_zip_rng_id                 number(15);
    l_out_saz_result_id   number(15);
   --
   cursor c_saz_pstl(c_svc_area_pstl_zip_rng_id number,c_mirror_src_entity_result_id number,c_table_alias varchar2 ) is
   select distinct cpe.information245 pstl_zip_rng_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_SVC_AREA_PSTL_ZIP_RNG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_svc_area_pstl_zip_rng_id
         -- and information4 = p_business_group_id
        ;

   ---------------------------------------------------------------
   -- END OF BEN_SVC_AREA_PSTL_ZIP_RNG_F ----------------------
   ---------------------------------------------------------------

    cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
         -- pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
    -- and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

  begin

     if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       open c_object_exists(p_svc_area_id,'SVA');
       fetch c_object_exists into l_dummy;
       if c_object_exists%found then
         close c_object_exists;
         return;
       end if;
       close c_object_exists;
     end if;

     l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_SVC_AREA_F ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_svc_area_id := p_svc_area_id ;
        --
        for l_sva_rec in c_sva(l_svc_area_id,l_mirror_src_entity_result_id,'SVA') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('SVA');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_sva_rec.name; --'Intersection';
          --
          if p_effective_date between l_sva_rec.effective_start_date
             and l_sva_rec.effective_end_date then
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
	    P_TABLE_ALIAS                    => 'SVA',
            p_information1     => l_sva_rec.svc_area_id,
            p_information2     => l_sva_rec.EFFECTIVE_START_DATE,
            p_information3     => l_sva_rec.EFFECTIVE_END_DATE,
            p_information4     => l_sva_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information170     => l_sva_rec.name,
            p_information141     => l_sva_rec.org_unit_prdct,
            p_information111     => l_sva_rec.sva_attribute1,
            p_information120     => l_sva_rec.sva_attribute10,
            p_information121     => l_sva_rec.sva_attribute11,
            p_information122     => l_sva_rec.sva_attribute12,
            p_information123     => l_sva_rec.sva_attribute13,
            p_information124     => l_sva_rec.sva_attribute14,
            p_information125     => l_sva_rec.sva_attribute15,
            p_information126     => l_sva_rec.sva_attribute16,
            p_information127     => l_sva_rec.sva_attribute17,
            p_information128     => l_sva_rec.sva_attribute18,
            p_information129     => l_sva_rec.sva_attribute19,
            p_information112     => l_sva_rec.sva_attribute2,
            p_information130     => l_sva_rec.sva_attribute20,
            p_information131     => l_sva_rec.sva_attribute21,
            p_information132     => l_sva_rec.sva_attribute22,
            p_information133     => l_sva_rec.sva_attribute23,
            p_information134     => l_sva_rec.sva_attribute24,
            p_information135     => l_sva_rec.sva_attribute25,
            p_information136     => l_sva_rec.sva_attribute26,
            p_information137     => l_sva_rec.sva_attribute27,
            p_information138     => l_sva_rec.sva_attribute28,
            p_information139     => l_sva_rec.sva_attribute29,
            p_information113     => l_sva_rec.sva_attribute3,
            p_information140     => l_sva_rec.sva_attribute30,
            p_information114     => l_sva_rec.sva_attribute4,
            p_information115     => l_sva_rec.sva_attribute5,
            p_information116     => l_sva_rec.sva_attribute6,
            p_information117     => l_sva_rec.sva_attribute7,
            p_information118     => l_sva_rec.sva_attribute8,
            p_information119     => l_sva_rec.sva_attribute9,
            p_information110     => l_sva_rec.sva_attribute_category,
            p_information265     => l_sva_rec.object_version_number,
           --

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_sva_result_id is null then
              l_out_sva_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_sva_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
        ---------------------------------------------------------------
        -- START OF BEN_SVC_AREA_PSTL_ZIP_RNG_F ----------------------
        ---------------------------------------------------------------
        -- Bug - 4241267 - moved code outside of loop
        l_table_route_id := null ;
        open ben_plan_design_program_module.g_table_route('SAZ');
        fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
        close ben_plan_design_program_module.g_table_route ;
        --

        for l_parent_rec  in c_saz_from_parent(l_SVC_AREA_ID) loop
           --
           l_mirror_src_entity_result_id := l_out_sva_result_id ;

           --
           l_svc_area_pstl_zip_rng_id := l_parent_rec.svc_area_pstl_zip_rng_id ;
           --
           for l_saz_rec in c_saz(l_parent_rec.svc_area_pstl_zip_rng_id,l_mirror_src_entity_result_id,'SAZ') loop
             --
             l_information5  := ben_plan_design_program_module.get_pstl_zip_rng_name(l_saz_rec.pstl_zip_rng_id
                                                                                     ,p_effective_date); --'Intersection';
             --
             if p_effective_date between l_saz_rec.effective_start_date
                and l_saz_rec.effective_end_date then
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
	       P_TABLE_ALIAS                    => 'SAZ',
               p_information1     => l_saz_rec.svc_area_pstl_zip_rng_id,
               p_information2     => l_saz_rec.EFFECTIVE_START_DATE,
               p_information3     => l_saz_rec.EFFECTIVE_END_DATE,
               p_information4     => l_saz_rec.business_group_id,
               p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information245     => l_saz_rec.pstl_zip_rng_id,
            p_information111     => l_saz_rec.saz_attribute1,
            p_information120     => l_saz_rec.saz_attribute10,
            p_information121     => l_saz_rec.saz_attribute11,
            p_information122     => l_saz_rec.saz_attribute12,
            p_information123     => l_saz_rec.saz_attribute13,
            p_information124     => l_saz_rec.saz_attribute14,
            p_information125     => l_saz_rec.saz_attribute15,
            p_information126     => l_saz_rec.saz_attribute16,
            p_information127     => l_saz_rec.saz_attribute17,
            p_information128     => l_saz_rec.saz_attribute18,
            p_information129     => l_saz_rec.saz_attribute19,
            p_information112     => l_saz_rec.saz_attribute2,
            p_information130     => l_saz_rec.saz_attribute20,
            p_information131     => l_saz_rec.saz_attribute21,
            p_information132     => l_saz_rec.saz_attribute22,
            p_information133     => l_saz_rec.saz_attribute23,
            p_information134     => l_saz_rec.saz_attribute24,
            p_information135     => l_saz_rec.saz_attribute25,
            p_information136     => l_saz_rec.saz_attribute26,
            p_information137     => l_saz_rec.saz_attribute27,
            p_information138     => l_saz_rec.saz_attribute28,
            p_information139     => l_saz_rec.saz_attribute29,
            p_information113     => l_saz_rec.saz_attribute3,
            p_information140     => l_saz_rec.saz_attribute30,
            p_information114     => l_saz_rec.saz_attribute4,
            p_information115     => l_saz_rec.saz_attribute5,
            p_information116     => l_saz_rec.saz_attribute6,
            p_information117     => l_saz_rec.saz_attribute7,
            p_information118     => l_saz_rec.saz_attribute8,
            p_information119     => l_saz_rec.saz_attribute9,
            p_information110     => l_saz_rec.saz_attribute_category,
            p_information241     => l_saz_rec.svc_area_id,
            p_information265     => l_saz_rec.object_version_number,
           --

               p_object_version_number          => l_object_version_number,
               p_effective_date                 => p_effective_date       );
               --

               if l_out_saz_result_id is null then
                 l_out_saz_result_id := l_copy_entity_result_id;
               end if;

               if l_result_type_cd = 'DISPLAY' then
                  l_out_saz_result_id := l_copy_entity_result_id ;
               end if;
               --
            end loop;
            --
              for l_saz_rec in c_saz_pstl(l_parent_rec.svc_area_pstl_zip_rng_id,l_mirror_src_entity_result_id,'SAZ') loop
                 create_postal_results
                   (
                    p_validate                    => p_validate
                   ,p_copy_entity_result_id       => l_out_saz_result_id
                   ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                   ,p_pstl_zip_rng_id             => l_saz_rec.pstl_zip_rng_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_number_of_copies            => p_number_of_copies
                   ,p_object_version_number       => l_object_version_number
                   ,p_effective_date              => p_effective_date
                   ) ;
              end loop;
          end loop;
       ---------------------------------------------------------------
       -- END OF BEN_SVC_AREA_PSTL_ZIP_RNG_F ----------------------
       ---------------------------------------------------------------
    ---------------------------------------------------------------
    -- END OF BEN_SVC_AREA_F ----------------------
    ---------------------------------------------------------------
  end create_service_results ;
--
procedure create_postal_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pstl_zip_rng_id                in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_PSTL_ZIP_RNG_F ----------------------
   ---------------------------------------------------------------
   cursor c_rzr(c_pstl_zip_rng_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  rzr.*
   from BEN_PSTL_ZIP_RNG_F rzr
   where  rzr.pstl_zip_rng_id = c_pstl_zip_rng_id
     --and rzr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PSTL_ZIP_RNG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_pstl_zip_rng_id
         -- and information4 = rzr.business_group_id
           and information2 = rzr.effective_start_date
           and information3 = rzr.effective_end_date);
    l_pstl_zip_rng_id                 number(15);
    l_out_rzr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_PSTL_ZIP_RNG_F ----------------------
   ---------------------------------------------------------------
    cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
    select null
    from ben_copy_entity_results cpe
         -- pqh_table_route trt
    where copy_entity_txn_id = p_copy_entity_txn_id
    -- and trt.table_route_id = cpe.table_route_id
    and cpe.table_alias = c_table_alias
    and information1 = c_pk_id;

   l_dummy                     varchar2(1);

 begin

     if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       open c_object_exists(p_pstl_zip_rng_id,'RZR');
       fetch c_object_exists into l_dummy;
       if c_object_exists%found then
         close c_object_exists;
         return;
       end if;
       close c_object_exists;
     end if;

     l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_PSTL_ZIP_RNG_F ----------------------
     ---------------------------------------------------------------
     -- bug 4241267 - moved code outside of loop
        l_table_route_id := null ;
        open ben_plan_design_program_module.g_table_route('RZR');
        fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
        close ben_plan_design_program_module.g_table_route ;
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_pstl_zip_rng_id := p_pstl_zip_rng_id ;
        --
        for l_rzr_rec in c_rzr(p_pstl_zip_rng_id,l_mirror_src_entity_result_id,'RZR') loop
          --
          l_information5  := l_rzr_rec.from_value ||' - '||l_rzr_rec.to_value; --'Intersection';
          --
          if p_effective_date between l_rzr_rec.effective_start_date
             and l_rzr_rec.effective_end_date then
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
	    P_TABLE_ALIAS                    => 'RZR',
            p_information1     => l_rzr_rec.pstl_zip_rng_id,
            p_information2     => l_rzr_rec.EFFECTIVE_START_DATE,
            p_information3     => l_rzr_rec.EFFECTIVE_END_DATE,
            p_information4     => l_rzr_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid

            p_information142     => l_rzr_rec.from_value,
            p_information111     => l_rzr_rec.rzr_attribute1,
            p_information120     => l_rzr_rec.rzr_attribute10,
            p_information121     => l_rzr_rec.rzr_attribute11,
            p_information122     => l_rzr_rec.rzr_attribute12,
            p_information123     => l_rzr_rec.rzr_attribute13,
            p_information124     => l_rzr_rec.rzr_attribute14,
            p_information125     => l_rzr_rec.rzr_attribute15,
            p_information126     => l_rzr_rec.rzr_attribute16,
            p_information127     => l_rzr_rec.rzr_attribute17,
            p_information128     => l_rzr_rec.rzr_attribute18,
            p_information129     => l_rzr_rec.rzr_attribute19,
            p_information112     => l_rzr_rec.rzr_attribute2,
            p_information130     => l_rzr_rec.rzr_attribute20,
            p_information131     => l_rzr_rec.rzr_attribute21,
            p_information132     => l_rzr_rec.rzr_attribute22,
            p_information133     => l_rzr_rec.rzr_attribute23,
            p_information134     => l_rzr_rec.rzr_attribute24,
            p_information135     => l_rzr_rec.rzr_attribute25,
            p_information136     => l_rzr_rec.rzr_attribute26,
            p_information137     => l_rzr_rec.rzr_attribute27,
            p_information138     => l_rzr_rec.rzr_attribute28,
            p_information139     => l_rzr_rec.rzr_attribute29,
            p_information113     => l_rzr_rec.rzr_attribute3,
            p_information140     => l_rzr_rec.rzr_attribute30,
            p_information114     => l_rzr_rec.rzr_attribute4,
            p_information115     => l_rzr_rec.rzr_attribute5,
            p_information116     => l_rzr_rec.rzr_attribute6,
            p_information117     => l_rzr_rec.rzr_attribute7,
            p_information118     => l_rzr_rec.rzr_attribute8,
            p_information119     => l_rzr_rec.rzr_attribute9,
            p_information110     => l_rzr_rec.rzr_attribute_category,
            p_information141     => l_rzr_rec.to_value,
            p_information265     => l_rzr_rec.object_version_number,
           --

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_rzr_result_id is null then
              l_out_rzr_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_rzr_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_PSTL_ZIP_RNG_F ----------------------
    ---------------------------------------------------------------
 end create_postal_results ;
 --
 procedure create_bnft_bal_results
    (
     p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Source Elpro
    ,p_copy_entity_txn_id             in  number    default null
    ,p_bnfts_bal_id                   in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_BNFTS_BAL_F ----------------------
   ---------------------------------------------------------------
   cursor c_bnb(c_bnfts_bal_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  bnb.*
   from BEN_BNFTS_BAL_F bnb
   where  bnb.bnfts_bal_id = c_bnfts_bal_id
     --and bnb.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BNFTS_BAL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_bnfts_bal_id
         -- and information4 = bnb.business_group_id
           and information2 = bnb.effective_start_date
           and information3 = bnb.effective_end_date);
    l_bnfts_bal_id                 number(15);
    l_out_bnb_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BNFTS_BAL_F ----------------------
   ---------------------------------------------------------------
      cursor c_object_exists(c_pk_id                number,
                             c_table_alias          varchar2) is
      select null
      from ben_copy_entity_results cpe
         -- pqh_table_route trt
      where copy_entity_txn_id = p_copy_entity_txn_id
      -- and trt.table_route_id = cpe.table_route_id
      and cpe.table_alias = c_table_alias
      and information1 = c_pk_id;

     l_dummy                     varchar2(1);

    begin

      if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       open c_object_exists(p_bnfts_bal_id,'BNB');
       fetch c_object_exists into l_dummy;
       if c_object_exists%found then
         close c_object_exists;
         return;
       end if;
       close c_object_exists;
     end if;

      l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_BNFTS_BAL_F ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_bnfts_bal_id := p_bnfts_bal_id ;
        --
        for l_bnb_rec in c_bnb(p_bnfts_bal_id,l_mirror_src_entity_result_id,'BNB') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('BNB');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_bnb_rec.name; --'Intersection';
          --
          if p_effective_date between l_bnb_rec.effective_start_date
             and l_bnb_rec.effective_end_date then
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
	    P_TABLE_ALIAS                    => 'BNB',
            p_information1     => l_bnb_rec.bnfts_bal_id,
            p_information2     => l_bnb_rec.EFFECTIVE_START_DATE,
            p_information3     => l_bnb_rec.EFFECTIVE_END_DATE,
            p_information4     => l_bnb_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_bnb_rec.bnb_attribute1,
            p_information120     => l_bnb_rec.bnb_attribute10,
            p_information121     => l_bnb_rec.bnb_attribute11,
            p_information122     => l_bnb_rec.bnb_attribute12,
            p_information123     => l_bnb_rec.bnb_attribute13,
            p_information124     => l_bnb_rec.bnb_attribute14,
            p_information125     => l_bnb_rec.bnb_attribute15,
            p_information126     => l_bnb_rec.bnb_attribute16,
            p_information127     => l_bnb_rec.bnb_attribute17,
            p_information128     => l_bnb_rec.bnb_attribute18,
            p_information129     => l_bnb_rec.bnb_attribute19,
            p_information112     => l_bnb_rec.bnb_attribute2,
            p_information130     => l_bnb_rec.bnb_attribute20,
            p_information131     => l_bnb_rec.bnb_attribute21,
            p_information132     => l_bnb_rec.bnb_attribute22,
            p_information133     => l_bnb_rec.bnb_attribute23,
            p_information134     => l_bnb_rec.bnb_attribute24,
            p_information135     => l_bnb_rec.bnb_attribute25,
            p_information136     => l_bnb_rec.bnb_attribute26,
            p_information137     => l_bnb_rec.bnb_attribute27,
            p_information138     => l_bnb_rec.bnb_attribute28,
            p_information139     => l_bnb_rec.bnb_attribute29,
            p_information113     => l_bnb_rec.bnb_attribute3,
            p_information140     => l_bnb_rec.bnb_attribute30,
            p_information114     => l_bnb_rec.bnb_attribute4,
            p_information115     => l_bnb_rec.bnb_attribute5,
            p_information116     => l_bnb_rec.bnb_attribute6,
            p_information117     => l_bnb_rec.bnb_attribute7,
            p_information118     => l_bnb_rec.bnb_attribute8,
            p_information119     => l_bnb_rec.bnb_attribute9,
            p_information110     => l_bnb_rec.bnb_attribute_category,
            p_information185     => l_bnb_rec.bnfts_bal_desc,
            p_information11     => l_bnb_rec.bnfts_bal_usg_cd,
            p_information170     => l_bnb_rec.name,
            p_information13     => l_bnb_rec.nnmntry_uom,
            p_information12     => l_bnb_rec.uom,
            p_information265    => l_bnb_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_bnb_result_id is null then
              l_out_bnb_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_bnb_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_BNFTS_BAL_F ----------------------
    ---------------------------------------------------------------
    end create_bnft_bal_results ;
 --
 procedure create_bnft_group_results
    (
     p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Source Elpro
    ,p_copy_entity_txn_id             in  number    default null
    ,p_benfts_grp_id                  in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_rate_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_BENFTS_GRP ----------------------
   ---------------------------------------------------------------
   cursor c_bng(c_benfts_grp_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  bng.*
   from BEN_BENFTS_GRP bng
   where  bng.benfts_grp_id = c_benfts_grp_id
     --and bng.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_BENFTS_GRP'
         and cpe.table_alias = c_table_alias
         and information1 = c_benfts_grp_id
         -- and information4 = bng.business_group_id
        );
    l_benfts_grp_id                 number(15);
    l_out_bng_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_BENFTS_GRP ----------------------
   ---------------------------------------------------------------
      cursor c_object_exists(c_pk_id                number,
                          c_table_alias          varchar2) is
      select null
      from ben_copy_entity_results cpe
           -- pqh_table_route trt
      where copy_entity_txn_id = p_copy_entity_txn_id
      -- and trt.table_route_id = cpe.table_route_id
      and cpe.table_alias = c_table_alias
      and information1 = c_pk_id;

      l_dummy                     varchar2(1);
    begin
      if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
        open c_object_exists(p_benfts_grp_id,'BNG');
        fetch c_object_exists into l_dummy;
        if c_object_exists%found then
          close c_object_exists;
          return;
        end if;
        close c_object_exists;
      end if;

      l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_BENFTS_GRP ----------------------
     ---------------------------------------------------------------
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_benfts_grp_id := p_benfts_grp_id ;
        --
        for l_bng_rec in c_bng(p_benfts_grp_id,l_mirror_src_entity_result_id,'BNG') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('BNG');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_bng_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
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
	    P_TABLE_ALIAS                    => 'BNG',
            p_information1     => l_bng_rec.benfts_grp_id,
            p_information2     => null,
            p_information3     => null,
            p_information4     => l_bng_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_bng_rec.bng_attribute1,
            p_information120     => l_bng_rec.bng_attribute10,
            p_information121     => l_bng_rec.bng_attribute11,
            p_information122     => l_bng_rec.bng_attribute12,
            p_information123     => l_bng_rec.bng_attribute13,
            p_information124     => l_bng_rec.bng_attribute14,
            p_information125     => l_bng_rec.bng_attribute15,
            p_information126     => l_bng_rec.bng_attribute16,
            p_information127     => l_bng_rec.bng_attribute17,
            p_information128     => l_bng_rec.bng_attribute18,
            p_information129     => l_bng_rec.bng_attribute19,
            p_information112     => l_bng_rec.bng_attribute2,
            p_information130     => l_bng_rec.bng_attribute20,
            p_information131     => l_bng_rec.bng_attribute21,
            p_information132     => l_bng_rec.bng_attribute22,
            p_information133     => l_bng_rec.bng_attribute23,
            p_information134     => l_bng_rec.bng_attribute24,
            p_information135     => l_bng_rec.bng_attribute25,
            p_information136     => l_bng_rec.bng_attribute26,
            p_information137     => l_bng_rec.bng_attribute27,
            p_information138     => l_bng_rec.bng_attribute28,
            p_information139     => l_bng_rec.bng_attribute29,
            p_information113     => l_bng_rec.bng_attribute3,
            p_information140     => l_bng_rec.bng_attribute30,
            p_information114     => l_bng_rec.bng_attribute4,
            p_information115     => l_bng_rec.bng_attribute5,
            p_information116     => l_bng_rec.bng_attribute6,
            p_information117     => l_bng_rec.bng_attribute7,
            p_information118     => l_bng_rec.bng_attribute8,
            p_information119     => l_bng_rec.bng_attribute9,
            p_information110     => l_bng_rec.bng_attribute_category,
            p_information185     => l_bng_rec.bng_desc,
            p_information170     => l_bng_rec.name,
            p_information265     => l_bng_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_bng_result_id is null then
              l_out_bng_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_bng_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
    ---------------------------------------------------------------
    -- END OF BEN_BENFTS_GRP ----------------------
    ---------------------------------------------------------------
    end ;
--
procedure create_acrs_ptip_cvg_results
    (
     p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Source Elpro
    ,p_copy_entity_txn_id             in  number    default null
    ,p_pgm_id                         in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_acrs_ptip_cvg_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    cursor c_parent_result(c_parent_pk_id number,
                        c_parent_table_name varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe,
        pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     and   cpe.table_route_id = trt.table_route_id
     and   trt.from_clause = 'OAB'
     and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where trt.table_alias = c_parent_table_alias;
     -- trt.from_clause = 'OAB'
     -- and   trt.where_clause = upper(c_parent_table_name) ;
     ---
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
   ---------------------------------------------------------------
   -- START OF BEN_ACRS_PTIP_CVG_F----------------------
   ---------------------------------------------------------------

   cursor c_apc_from_parent(c_PGM_ID number) is
   select  DISTINCT acrs_ptip_cvg_id
   from BEN_ACRS_PTIP_CVG_F
   where  PGM_ID = c_PGM_ID;

   cursor c_apc(c_acrs_ptip_cvg_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  apc.*
   from BEN_ACRS_PTIP_CVG_F apc
   where  apc.acrs_ptip_cvg_id = c_acrs_ptip_cvg_id
     --and apc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ACRS_PTIP_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_acrs_ptip_cvg_id
         -- and information4 = apc.business_group_id
        );
    l_acrs_ptip_cvg_id                 number(15);
    l_out_apc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ACRS_PTIP_CVG_F----------------------
   ---------------------------------------------------------------
    begin
      l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_ACRS_PTIP_CVG_F----------------------
     ---------------------------------------------------------------

      for l_parent_rec  in c_apc_from_parent(p_pgm_id) loop
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_acrs_ptip_cvg_id := l_parent_rec.acrs_ptip_cvg_id ;
        --
        for l_apc_rec in c_apc(l_parent_rec.acrs_ptip_cvg_id,l_mirror_src_entity_result_id,'ACP') loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('ACP');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := l_apc_rec.name; --'Intersection';
          --
          l_result_type_cd := 'DISPLAY';
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
	    P_TABLE_ALIAS                    => 'ACP',
            p_information1     => l_apc_rec.acrs_ptip_cvg_id,
            p_information2     => l_apc_rec.EFFECTIVE_START_DATE,
            p_information3     => l_apc_rec.EFFECTIVE_END_DATE,
            p_information4     => l_apc_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_INFORMATION111     => l_apc_rec.APC_ATTRIBUTE1,
            p_INFORMATION120     => l_apc_rec.APC_ATTRIBUTE10,
            p_INFORMATION121     => l_apc_rec.APC_ATTRIBUTE11,
            p_INFORMATION122     => l_apc_rec.APC_ATTRIBUTE12,
            p_INFORMATION123     => l_apc_rec.APC_ATTRIBUTE13,
            p_INFORMATION124     => l_apc_rec.APC_ATTRIBUTE14,
            p_INFORMATION125     => l_apc_rec.APC_ATTRIBUTE15,
            p_INFORMATION126     => l_apc_rec.APC_ATTRIBUTE16,
            p_INFORMATION127     => l_apc_rec.APC_ATTRIBUTE17,
            p_INFORMATION128     => l_apc_rec.APC_ATTRIBUTE18,
            p_INFORMATION129     => l_apc_rec.APC_ATTRIBUTE19,
            p_INFORMATION112     => l_apc_rec.APC_ATTRIBUTE2,
            p_INFORMATION130     => l_apc_rec.APC_ATTRIBUTE20,
            p_INFORMATION131     => l_apc_rec.APC_ATTRIBUTE21,
            p_INFORMATION132     => l_apc_rec.APC_ATTRIBUTE22,
            p_INFORMATION133     => l_apc_rec.APC_ATTRIBUTE23,
            p_INFORMATION134     => l_apc_rec.APC_ATTRIBUTE24,
            p_INFORMATION135     => l_apc_rec.APC_ATTRIBUTE25,
            p_INFORMATION136     => l_apc_rec.APC_ATTRIBUTE26,
            p_INFORMATION137     => l_apc_rec.APC_ATTRIBUTE27,
            p_INFORMATION138     => l_apc_rec.APC_ATTRIBUTE28,
            p_INFORMATION139     => l_apc_rec.APC_ATTRIBUTE29,
            p_INFORMATION113     => l_apc_rec.APC_ATTRIBUTE3,
            p_INFORMATION140     => l_apc_rec.APC_ATTRIBUTE30,
            p_INFORMATION114     => l_apc_rec.APC_ATTRIBUTE4,
            p_INFORMATION115     => l_apc_rec.APC_ATTRIBUTE5,
            p_INFORMATION116     => l_apc_rec.APC_ATTRIBUTE6,
            p_INFORMATION117     => l_apc_rec.APC_ATTRIBUTE7,
            p_INFORMATION118     => l_apc_rec.APC_ATTRIBUTE8,
            p_INFORMATION119     => l_apc_rec.APC_ATTRIBUTE9,
            p_INFORMATION110     => l_apc_rec.APC_ATTRIBUTE_CATEGORY,
            p_INFORMATION294     => l_apc_rec.MN_CVG_ALWD_AMT,
            p_INFORMATION293     => l_apc_rec.MX_CVG_ALWD_AMT,
            p_INFORMATION170     => l_apc_rec.NAME,
            p_INFORMATION260     => l_apc_rec.PGM_ID,
            p_information265     => l_apc_rec.object_version_number,

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_apc_result_id is null then
              l_out_apc_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_apc_result_id := l_copy_entity_result_id ;
            end if;
            --
         end loop;
         --
       end loop;
       --
    ---------------------------------------------------------------
    -- END OF BEN_ACRS_PTIP_CVG_F----------------------
    ---------------------------------------------------------------
    end create_acrs_ptip_cvg_results;

end ben_pd_rate_and_cvg_module;

/
