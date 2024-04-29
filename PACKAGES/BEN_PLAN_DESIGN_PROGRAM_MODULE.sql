--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_PROGRAM_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_PROGRAM_MODULE" AUTHID CURRENT_USER as
/* $Header: bepdcpgm.pkh 120.1.12000000.1 2007/01/19 20:49:52 appldev noship $ */
--

g_pdw_allow_dup_rslt  varchar2(30);
g_pdw_no_dup_rslt     varchar2(30) := 'PDW_NO_DUP_RSLT';

--
CURSOR g_table_route(c_parent_table_alias varchar2) is
SELECT table_route_id
  FROM pqh_table_route trt
 WHERE trt.table_alias = c_parent_table_alias;
--

procedure create_program_result
  (
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number
  ,p_pgm_id                         in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in varchar2   default null
  ) ;
--
procedure create_formula_result
  (
   p_validate                       in  number    default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number
  ,p_formula_id                     in  number
  ,p_business_group_id              in  number    default null
  ,p_copy_to_clob                   in  varchar2  default 'N'
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) ;
  --
procedure create_actn_typ_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_effective_date                 in  date
  );
  --
function get_ler_name
  (
   p_ler_id               in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_pgm_name
  (
   p_pgm_id               in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_pl_typ_name
  (
   p_pl_typ_id            in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_pl_name
  (
   p_pl_id                in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_ptip_name
  (
   p_ptip_id              in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_plip_name
  (
   p_plip_id              in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_oipl_name
  (
   p_oipl_id              in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_opt_name
  (
   p_opt_id               in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_regn_name
  (
   p_regn_id              in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_gd_or_svc_typ_name
  (
   p_gd_or_svc_typ_id     in  number
  ) return varchar2;
--

function get_actn_typ_name
  (
   p_actn_typ_id     in  number
  ) return varchar2;
--

function get_formula_name
  (
   p_formula_id       in  number
  ,p_effective_date   in date
  ) return varchar2;
--

function get_organization_name
  (
   p_organization_id       in  number
  ) return varchar2;
--

function get_yr_perd_name
  (
   p_yr_perd_id       in  number
  ) return varchar2;
--

function get_rptg_grp_name
  (
   p_rptg_grp_id     in  number
  ) return varchar2;
--

function get_per_info_chg_cs_ler_name
  (
   p_per_info_chg_cs_ler_id   in  number
  ,p_effective_date           in  date
  ) return varchar2;
--

function get_rltd_per_chg_cs_ler_name
  (
   p_rltd_per_chg_cs_ler_id   in  number
  ,p_effective_date           in  date
  ) return varchar2;
--

function get_oiplip_name
  (
   p_oipl_id              in  number
  ,p_plip_id              in number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_optip_name
  (
   p_opt_id              in  number
  ,p_pl_typ_id           in number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_ptd_lmt_name
  (
   p_ptd_lmt_id           in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_vrbl_rt_prfl_name
  (
   p_vrbl_rt_prfl_id      in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_age_fctr_name
  (
   p_age_fctr_id     in  number
  ) return varchar2;
--

function get_assignment_set_name
  (
   p_assignment_set_id     in  number
  ) return varchar2;
--

function get_benfts_grp_name
  (
   p_benfts_grp_id     in  number
  ) return varchar2;
--

function get_cmbn_age_los_fctr_name
  (
   p_cmbn_age_los_fctr_id     in  number
  ) return varchar2;
--

function get_comp_lvl_fctr_name
  (
   p_comp_lvl_fctr_id     in  number
  ) return varchar2;
--

function get_assignment_sts_type_name
  (
   p_assignment_status_type_id     in  number
  ) return varchar2;
--

function get_grade_name
  (
   p_grade_id     in  number
  ) return varchar2;
--

function get_hrs_wkd_in_perd_fctr_name
  (
   p_hrs_wkd_in_perd_fctr_id     in  number
  ) return varchar2;
--

function get_lbr_mmbr_name
  (
   p_lbr_mmbr_flag     in  varchar2
  ) return varchar2;
--

function get_absence_type_name
  (
   p_absence_attendance_type_id     in  number
  ) return varchar2;
--

function get_los_fctr_name
  (
   p_los_fctr_id     in  number
  ) return varchar2;
--

function get_pct_fl_tm_fctr_name
  (
   p_pct_fl_tm_fctr_id     in  number
  ) return varchar2;
--

function get_person_type_name
  (
   p_person_type_id     in  number
  ) return varchar2;
--

function get_people_group_name
  (
   p_people_group_id     in  number
  ) return varchar2;
--

function get_pstl_zip_rng_name
  (
   p_pstl_zip_rng_id     in  number
  ,p_effective_date      in date
  ) return varchar2;
--

function get_payroll_name
  (
   p_payroll_id          in  number
  ,p_effective_date      in date
  ) return varchar2;
--

function get_pay_basis_name
  (
   p_pay_basis_id          in  number
  ) return varchar2;
--

function get_svc_area_name
  (
   p_svc_area_id          in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_location_name
  (
   p_location_id          in  number
  ) return varchar2;
--

function get_acty_base_rt_name
  (
   p_acty_base_rt_id      in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_eligy_prfl_name
  (
   p_eligy_prfl_id        in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_cbr_quald_bnf_name
  (
   p_ptip_id              in  number
  ,p_pgm_id               in  number
  ,p_effective_date       in  date
  ) return varchar2;
--

function get_job_name
  (
   p_job_id        in  number
  ) return varchar2;
--

function get_sp_clng_step_name
  (
   p_special_ceiling_step_id   in  number
  ,p_effective_date            in date
  ) return varchar2;
--

function get_position_name
  (
   p_position_id        in  number
  ) return varchar2;
--

function get_qual_type_name
  (
   p_qualification_type_id         in  number
  ) return varchar2;
--

function get_dpnt_cvg_eligy_prfl_name
  (
   p_dpnt_cvg_eligy_prfl_id        in  number
  ,p_effective_date                in  date
  ) return varchar2 ;
--

function get_competence_rating_name
  (
   p_competence_id        in  number
  ,p_rating_level_id      in number
  ) return varchar2;
--

function get_hlth_cvg_name
  (
   p_pl_typ_opt_typ_id   in  number
  ,p_oipl_id             in  number
  ,p_effective_date      in  date
  ) return varchar2;
--
function get_eligy_criteria_name
  (
   p_eligy_criteria_id   in  number
  ) return varchar2;
--

function get_exclude_message
  (
   p_excld_flag           in varchar2
  ) return varchar2;
--

end ben_plan_design_program_module;

 

/
