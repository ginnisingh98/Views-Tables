--------------------------------------------------------
--  DDL for Package HR_PUMP_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PUMP_GET" AUTHID CURRENT_USER as
/* $Header: hrdpget.pkh 120.1 2005/07/08 20:09:29 ssattini noship $ */
/*
  Notes:
    The functions declared in this header are designed to be used by
    the Data Pump engine to resolve id values that have to be passed
    to the API modules.  However, most of these functions could also
    be used by any program that might want to do something similar.

    The exceptions to are likely to be the functions where a user
    key value is one of the parameters.
*/

/*
 *  The following functions have been defined in this
 *  header file.

   p_person_id
   p_assignment_id
   p_address_id
   p_supervisor_id
   p_recruiter_id
   p_person_referred_by_id
   p_timecard_approver (i.e. a person_id)
   p_contact_relationship_id
   p_person_type_id
   p_vendor_id
   p_assignment_status_type_id
   p_organization_id
   p_source_organization_id
   p_grade_id
   p_position_id
   p_successor_position_id
   p_relief_position_id
   p_job_id
   p_payroll_id
   p_location_id
   p_pay_basis_id
   p_recruitment_activity_id
   p_vacancy_id
   p_org_payment_method_id
   p_payee_id  (organization)
   p_payee_id  (person)
   p_personal_payment_method_id
   p_set_of_books_id
   p_tax_unit  -- this is p_scl_segment1 for US leg.
   p_work_schedule
   p_eeo_1_establishment  (this is an id)
   p_correspondence_language
   p_contact_person_id
   p_element_entry_id
   p_original_entry_id
   p_element_link_id
   p_cost_allocation_keyflex_id
   p_assignment_action_id
   p_updating_action_id
   p_comment_id
   p_target_entry_id
   p_input_value_id
   p_input_value_id1 .. p_input_value_id_15
   p_rate_id
   p_payee_id (person or organisation)
   p_program_application_id
   p_program_id
   p_request_id
   p_id_flex_num
   p_creator_id
   p_grade_rule_id (using progression point, or grade)
   p_period_of_service_id
   p_spinal_point_id (progression point)
   p_contract_id
   p_collective_agreement_id
   p_cagr_id_flex_num
   p_establishment_id
   p_country
   p_benefit_group_id
   p_start_life_reason_id
   p_end_life_reason_id
 *
 *  The following functions have yet to be defined or the
 *  definition is incomplete in this header file.
 *  This may of course prevent the Meta Mapper being
 *  successfully run against certain API modules until
 *  this work is complete.
 *
 *  Some of the following are likely to prove difficult
 *  to implement.

   p_special_ceiling_step_id
   p_default_code_comb_id
   p_soft_coding_keyflex_id
   p_people_group_id
*/

----------------------- get_collective_agreement_id ------------------------
/*
  NAME
    get_collective_agreement_id
  DESCRIPTION
    Returns a Collective Agreement ID.
  NOTES
    This function returns a collective_agreement_id and is designed for use
    with the Data Pump.
*/
function get_collective_agreement_id
(p_business_group_id in number
,p_cagr_name         in varchar2
,p_effective_date    in date
) return number;
pragma restrict_references (get_collective_agreement_id, WNDS);

-------------------------------- get_contract_id ---------------------------
/*
  NAME
    get_contract_id
  DESCRIPTION
    Returns a Contract ID.
  NOTES
    This function returns a contract_id and is designed for use
    with the Data Pump.
*/
function get_contract_id
(p_contract_user_key in varchar2
) return number;
pragma restrict_references (get_contract_id, WNDS);

------------------------------ get_establishment_id ---------------------------
/*
  NAME
    get_establishment_id
  DESCRIPTION
    Returns an Establishment ID.
  NOTES
    This function returns an establishment_id and is designed for use
    with the Data Pump.
*/
function get_establishment_id
(p_establishment_name in varchar2
,p_location           in varchar2
) return number;
pragma restrict_references (get_establishment_id, WNDS);

--------------------------- get_cagr_id_flex_num ------------------------------
/*
  NAME
    get_cagr_id_flex_num
  DESCRIPTION
    Returns a cagr_id_flex_num.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_cagr_id_flex_num
(p_cagr_id_flex_num_user_key varchar2
) return number;
pragma restrict_references (get_cagr_id_flex_num, WNDS);

------------------------- get_emp_fed_tax_rule_id -------------------------
/*
  NAME
    get_emp_fed_tax_rule_id
  DESCRIPTION
    Returns a federal tax rule ID.
  NOTES
    This function returns a emp_fed_tax_rule_id and is designed for use
    with the Data Pump.
*/
function get_emp_fed_tax_rule_id
(
  p_emp_fed_tax_rule_user_key in varchar2
) return number;
pragma restrict_references (get_emp_fed_tax_rule_id, WNDS);

------------------------- get_emp_state_tax_rule_id -------------------------
/*
  NAME
    get_emp_state_tax_rule_id
  DESCRIPTION
    Returns a state tax rule ID.
  NOTES
    This function returns a emp_state_tax_rule_id and is designed for use
    with the Data Pump.
*/
function get_emp_state_tax_rule_id
(
  p_emp_state_tax_rule_user_key in varchar2
) return number;
pragma restrict_references (get_emp_state_tax_rule_id, WNDS);

------------------------- get_emp_county_tax_rule_id -------------------------
/*
  NAME
    get_emp_county_tax_rule_id
  DESCRIPTION
    Returns a county tax rule ID.
  NOTES
    This function returns a emp_county_tax_rule_id and is designed for use
    with the Data Pump.
*/
function get_emp_county_tax_rule_id
(
  p_emp_county_tax_rule_user_key in varchar2
) return number;
pragma restrict_references (get_emp_county_tax_rule_id, WNDS);

------------------------- get_emp_city_tax_rule_id -------------------------
/*
  NAME
    get_emp_city_tax_rule_id
  DESCRIPTION
    Returns a city tax rule ID.
  NOTES
    This function returns a emp_city_tax_rule_id and is designed for use
    with the Data Pump.
*/
function get_emp_city_tax_rule_id
(
  p_emp_city_tax_rule_user_key in varchar2
) return number;
pragma restrict_references (get_emp_city_tax_rule_id, WNDS);

---------------------------- get_start_life_reason_id -------------------------
/*
  NAME
    get_ get_start_life_reason_id
  DESCRIPTION
    Returns a Start Life Reason ID.
  NOTES
    This function returns a start_life_reason_id and is designed for use
    with the Data Pump.
*/
function get_start_life_reason_id
(p_business_group_id in number
,p_effective_date    in date
,p_start_life_reason in varchar2
) return number;
pragma restrict_references (get_start_life_reason_id, WNDS);

----------------------------- get_end_life_reason_id --------------------------
/*
  NAME
    get_end_life_reason_id
  DESCRIPTION
    Returns an End Life Reason ID.
  NOTES
    This function returns a end_life_reason_id and is designed for use
    with the Data Pump.
*/
function get_end_life_reason_id
(p_business_group_id in number
,p_effective_date    in date
,p_end_life_reason   in varchar2
) return number;
pragma restrict_references (get_end_life_reason_id, WNDS);

------------------------------ get_benefit_group_id ---------------------------
/*
  NAME
    get_benefit_group_id
  DESCRIPTION
    Returns a Benefit Group ID.
  NOTES
    This function returns a benefit_group_id and is designed for use
    with the Data Pump.
*/
function get_benefit_group_id
(p_business_group_id in number
,p_benefit_group     in varchar2
) return number;
pragma restrict_references (get_benefit_group_id, WNDS);

/***** start OAB additions  *****/

/* start USER_KEY additions */

/*
  NAME
    get_ptnl_ler_for_per_id
  DESCRIPTION
    Returns a ptnl_ler_for_per id from supplied user_key
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_ptnl_ler_for_per_id
( p_ptnl_ler_for_per_user_key    in varchar2
) return number;
pragma restrict_references (get_ptnl_ler_for_per_id, WNDS);

-- this appears to be a self ref FK on ben_ptnl_ler_for_per
/* returns a csd_by_ptnl_ler_for_per_id from supplied user_key */
function get_csd_by_ptnl_ler_for_per_id
( p_csd_by_ppl_user_key          in varchar2  -- note abbreviation
) return number;
pragma restrict_references (get_csd_by_ptnl_ler_for_per_id, WNDS);

/* returns a ptnl_ler_for_per object_version_number */
function get_ptnl_ler_for_per_ovn
( p_ptnl_ler_for_per_user_key    in varchar2
) return number;
pragma restrict_references (get_ptnl_ler_for_per_ovn, WNDS);

/* returns a per_in_ler_id from supplied user_key */
function get_per_in_ler_id
( p_per_in_ler_user_key          in varchar2
) return number;
pragma restrict_references (get_per_in_ler_id, WNDS);

/* returns a trgr_table_pk_id from supplied user_key */
function get_trgr_table_pk_id
( p_trgr_table_pk_user_key          in varchar2
) return number;
pragma restrict_references (get_trgr_table_pk_id, WNDS);
--
/* returns a ws_mgr_id from supplied user_key */
function get_ws_mgr_id
( p_ws_mgr_user_key    in varchar2
) return number ;
pragma restrict_references (get_ws_mgr_id, WNDS);
--
/* returns a group_pl_id from supplied user_key */
function get_group_pl_id
( p_group_pl_user_key    in varchar2
) return number ;
pragma restrict_references (get_group_pl_id, WNDS);
--
/* returns a mgr_ovrid_person_id from supplied user_key */
function get_mgr_ovrid_person_id
( p_mgr_ovrid_person_user_key    in varchar2
) return number ;
pragma restrict_references (get_mgr_ovrid_person_id, WNDS);
--
/* returns a bckt_per_in_ler_id from supplied user_key */
function get_bckt_per_in_ler_id
( p_bckt_per_in_ler_user_key  in varchar2
) return number;
pragma restrict_references (get_bckt_per_in_ler_id, WNDS);

/* returns an ended_per_in_ler_id from supplied user_key */
function get_ended_per_in_ler_id
( p_ended_per_in_ler_user_key in varchar2
) return number;
pragma restrict_references (get_ended_per_in_ler_id, WNDS);

/* returns a per_in_ler object_version_number */
function get_per_in_ler_ovn
( p_per_in_ler_user_key          in varchar2
) return number;
pragma restrict_references (get_per_in_ler_ovn, WNDS);

/* returns a prtt_enrt_rslt_id from supplied user_key */
function get_prtt_enrt_rslt_id
( p_prtt_enrt_rslt_user_key      in varchar2
) return number;
pragma restrict_references (get_prtt_enrt_rslt_id, WNDS);

/* returns a rplcs_sspndd_rslt_id from supplied user_key */
function get_rplcs_sspndd_rslt_id
( p_rplcs_sspndd_rslt_user_key   in varchar2
) return number;
pragma restrict_references (get_rplcs_sspndd_rslt_id, WNDS);

/* returns a prtt_enrt_rslt object_version_number */
function get_prtt_enrt_rslt_ovn
( p_prtt_enrt_rslt_user_key      in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_prtt_enrt_rslt_ovn, WNDS);

/* returns a prtt_rt_val_id from supplied user_key */
function get_prtt_rt_val_id
( p_prtt_rt_val_user_key         in varchar2
) return number;
pragma restrict_references (get_prtt_rt_val_id, WNDS);

/* returns a prtt_rt_val object_version_number */
function get_prtt_rt_val_ovn
( p_prtt_rt_val_user_key         in varchar2
) return number;
pragma restrict_references (get_prtt_rt_val_ovn, WNDS);

/* returns a cbr_quald_bnf_id from supplied user_key */
function get_cbr_quald_bnf_id
( p_cbr_quald_bnf_user_key       in varchar2
) return number;
pragma restrict_references (get_cbr_quald_bnf_id, WNDS);

/* returns a cbr_quald_bnf object_version_number */
function get_cbr_quald_bnf_ovn
( p_cbr_quald_bnf_user_key       in varchar2
) return number;
pragma restrict_references (get_cbr_quald_bnf_ovn, WNDS);

/* returns a cbr_per_in_ler_id from supplied user_key */
function get_cbr_per_in_ler_id
( p_cbr_per_in_ler_user_key      in varchar2
) return number;
pragma restrict_references (get_cbr_per_in_ler_id, WNDS);

/* returns a cbr_per_in_ler object_version_number */
function get_cbr_per_in_ler_ovn
( p_cbr_per_in_ler_user_key      in varchar2
) return number;
pragma restrict_references (get_cbr_per_in_ler_ovn, WNDS);

/* returns an elig_cvrd_dpnt_id from supplied user_key */
function get_elig_cvrd_dpnt_id
( p_elig_cvrd_dpnt_user_key      in varchar2
) return number;
pragma restrict_references (get_elig_cvrd_dpnt_id, WNDS);

/* returns an elig_cvrd_dpnt object_version_number */
function get_elig_cvrd_dpnt_ovn
( p_elig_cvrd_dpnt_user_key      in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_elig_cvrd_dpnt_ovn, WNDS);

/* returns a prtt_prem_id from supplied user_key */
function get_prtt_prem_id
( p_prtt_prem_user_key           in varchar2
) return number;
pragma restrict_references (get_prtt_prem_id, WNDS);

/* returns a prtt_prem object_version_number */
function get_prtt_prem_ovn
( p_prtt_prem_user_key           in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_prtt_prem_ovn, WNDS);

/* returns a elig_dpnt_id from supplied user_key */
function get_elig_dpnt_id
( p_elig_dpnt_user_key           in varchar2
) return number;
pragma restrict_references (get_elig_dpnt_id, WNDS);

/* returns a elig_dpnt object_version_number */
function get_elig_dpnt_ovn
( p_elig_dpnt_user_key           in varchar2
) return number;
pragma restrict_references (get_elig_dpnt_ovn, WNDS);

/* returns an elig_per_id from supplied user_key */
function get_elig_per_id
( p_elig_per_user_key            in varchar2
) return number;
pragma restrict_references (get_elig_per_id, WNDS);

/* returns an elig_per object_version_number */
function get_elig_per_ovn
( p_elig_per_user_key            in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_elig_per_ovn, WNDS);

/* returns an elig_per_opt_id from supplied user_key */
function get_elig_per_opt_id
( p_elig_per_opt_user_key        in varchar2
) return number;
pragma restrict_references (get_elig_per_opt_id, WNDS);

/* returns an elig_per_opt object_version_number */
function get_elig_per_opt_ovn
( p_elig_per_opt_user_key        in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_elig_per_opt_ovn, WNDS);

/* returns a pl_bnf_id from supplied user_key */
function get_pl_bnf_id
( p_pl_bnf_user_key              in varchar2
) return number;
pragma restrict_references (get_pl_bnf_id, WNDS);

/* returns a pl_bnf object_version_number */
function get_pl_bnf_ovn
( p_pl_bnf_user_key              in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_pl_bnf_ovn, WNDS);

/* returns an oipl_id from supplied user_key */
function get_oipl_id
( p_oipl_user_key                in varchar2
) return number;
pragma restrict_references (get_oipl_id, WNDS);

/* returns an oipl object_version_number */
function get_oipl_ovn
( p_oipl_user_key                in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_oipl_ovn, WNDS);

/* returns a plip_id from supplied user_key */
function get_plip_id
( p_plip_user_key                in varchar2
) return number;
pragma restrict_references (get_plip_id, WNDS);

/* returns a plip object_version_number */
function get_plip_ovn
( p_plip_user_key                in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_plip_ovn, WNDS);

/* returns a ptip_id from supplied user_key */
function get_ptip_id
( p_ptip_user_key                in varchar2
) return number;
pragma restrict_references (get_ptip_id, WNDS);

/* returns a ptip object_version_number */
function get_ptip_ovn
( p_ptip_user_key                in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_ptip_ovn, WNDS);

/* returns an enrt_rt_id from supplied user_key */
function get_enrt_rt_id
( p_enrt_rt_user_key             in varchar2
) return number;
pragma restrict_references (get_enrt_rt_id, WNDS);

/* returns an enrt_rt object_version_number */
function get_enrt_rt_ovn
( p_enrt_rt_user_key             in varchar2
) return number;
pragma restrict_references (get_enrt_rt_ovn, WNDS);

/* returns an enrt_perd_id from supplied user_key */
function get_enrt_perd_id
( p_enrt_perd_user_key           in varchar2
) return number;
pragma restrict_references (get_enrt_perd_id, WNDS);

/* returns an enrt_perd object_version_number */
function get_enrt_perd_ovn
( p_enrt_perd_user_key           in varchar2
) return number;
pragma restrict_references (get_enrt_perd_ovn, WNDS);

/* returns a prtt_reimbmt_rqst_id from supplied user_key */
function get_prtt_reimbmt_rqst_id
( p_prtt_reimbmt_rqst_user_key   in varchar2
) return number;
pragma restrict_references (get_prtt_reimbmt_rqst_id, WNDS);

/* returns a prtt_reimbmt_rqst object_version_number */
function get_prtt_reimbmt_rqst_ovn
( p_prtt_reimbmt_rqst_user_key   in varchar2,
  p_effective_date               in date
) return number;
pragma restrict_references (get_prtt_reimbmt_rqst_ovn, WNDS);

/* returns an elig_per_elctbl_chc_id from supplied user_key */
function get_elig_per_elctbl_chc_id
( p_elig_per_elctbl_chc_user_key in varchar2
) return number;
pragma restrict_references (get_elig_per_elctbl_chc_id, WNDS);

/* returns an elig_per_elctbl_chc object_version_number */
function get_elig_per_elctbl_chc_ovn
( p_elig_per_elctbl_chc_user_key in varchar2
) return number;
pragma restrict_references (get_elig_per_elctbl_chc_ovn, WNDS);

--
------------------------------ get_benfts_grp_id ---------------------------
/*
  NAME
    get_benfts_grp_id
  DESCRIPTION
    Returns a benefits group ID.
  NOTES
    This function returns a benfts_grp_id and is designed for use with the Data Pump.
*/
function get_benfts_grp_id
( p_business_group_id in number,
  p_benefits_group    in varchar2
) return number;
pragma restrict_references (get_benfts_grp_id, WNDS);
--
/*
  NAME
    get_benfts_grp_ovn
  DESCRIPTION
    Returns a benefits group object version number.
*/
function get_benfts_grp_ovn
( p_business_group_id in number,
  p_benefits_group    in varchar2
) return number;
pragma restrict_references (get_benfts_grp_ovn, WNDS);
--
------------------------------ get_pl_typ_id ---------------------------
/*
  NAME
    get_pl_typ_id
  DESCRIPTION
    Returns a Plan Type ID.
  NOTES
    This function returns a plan_type_id and is designed for use with the Data Pump.
*/
function get_pl_typ_id
( p_business_group_id in number,
  p_plan_type         in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pl_typ_id, WNDS);
--
/*
  NAME
    get_pl_typ_ovn
  DESCRIPTION
    Returns a plan type object version number.
*/
function get_pl_typ_ovn
( p_business_group_id in number,
  p_plan_type         in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pl_typ_ovn, WNDS);
--
------------------------------ get_ler_id ---------------------------
-- Note: WARNING this is overloaded on another get_ler_id that previously existed!
/*
  NAME
    get_ler_id
  DESCRIPTION
    Returns a life event reason ID.
  NOTES
    This function returns a ler_id and is designed for use with the Data Pump.
*/
function get_ler_id
( p_business_group_id in number,
  p_life_event_reason in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_ler_id, WNDS);
--
/*
  NAME
    get_ler_ovn
  DESCRIPTION
    Returns a life event reason object version number.
*/
function get_ler_ovn
( p_business_group_id in number,
  p_life_event_reason in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_ler_ovn, WNDS);
--
------------------------------ get_acty_base_rt_id ---------------------------
/*
  NAME
    get_acty_base_rt_id
  DESCRIPTION
    Returns an acty base rate ID.
  NOTES
    This function returns an acty_base_rt_id and is designed for use with the Data Pump.
*/
function get_acty_base_rt_id
( p_business_group_id in number,
  p_acty_base_rate    in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_acty_base_rt_id , WNDS);
--
/*
  NAME
    get_acty_base_rt_ovn
  DESCRIPTION
    Returns an acty base rate object version number.
*/
function get_acty_base_rt_ovn
( p_business_group_id in number,
  p_acty_base_rate    in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_acty_base_rt_ovn, WNDS);
--
------------------------------ get_actl_prem_id ---------------------------
/*
  NAME
    get_actl_prem_id
  DESCRIPTION
    Returns an actual premium ID.
  NOTES
    This function returns a actl_prem_id and is designed for use with the Data Pump.
*/
function get_actl_prem_id
( p_business_group_id in number,
  p_actual_premium    in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_actl_prem_id, WNDS);
--
/*
  NAME
    get_actl_prem_ovn
  DESCRIPTION
    Returns an actual premium object version number.
*/
function get_actl_prem_ovn
( p_business_group_id in number,
  p_actual_premium    in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_actl_prem_ovn, WNDS);
--
------------------------------ get_comp_lvl_fctr_id ---------------------------
/*
  NAME
    get_comp_lvl_fctr_id
  DESCRIPTION
    Returns a comp level factor ID.
  NOTES
    This function returns a comp_lvl_fctr_id and is designed for use with the Data Pump.
*/
function get_comp_lvl_fctr_id
( p_business_group_id in number,
  p_comp_level_factor in varchar2
) return number;
pragma restrict_references (get_comp_lvl_fctr_id, WNDS);
--
/*
  NAME
    get_comp_lvl_fctr_ovn
  DESCRIPTION
    Returns a comp level factor object version number.
*/
function get_comp_lvl_fctr_ovn
( p_business_group_id in number,
  p_comp_level_factor in varchar2
) return number;
pragma restrict_references (get_comp_lvl_fctr_ovn, WNDS);
--
------------------------------ get_cvg_amt_calc_mthd_id ---------------------------
/*
  NAME
    get_cvg_amt_calc_mthd_id
  DESCRIPTION
    Returns a cvg amt calc ID.
  NOTES
    This function returns a cvg_amt_calc_mthd_id and is designed for use with the Data Pump.
*/
function get_cvg_amt_calc_mthd_id
( p_business_group_id in number,
  p_cvg_amt_calc      in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_cvg_amt_calc_mthd_id , WNDS);
--
/*
  NAME
    get_cvg_amt_calc_mthd_ovn
  DESCRIPTION
    Returns a cvg amt calc object version number.
*/
function get_cvg_amt_calc_mthd_ovn
( p_business_group_id in number,
  p_cvg_amt_calc      in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_cvg_amt_calc_mthd_ovn, WNDS);
--
------------------------------ get_opt_id ---------------------------
/*
  NAME
    get_opt_id
  DESCRIPTION
    Returns an option (definition) ID.
  NOTES
    This function returns a opt_id and is designed for use with the Data Pump.
*/
function get_opt_id
( p_business_group_id in number,
  p_option_definition in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_opt_id, WNDS);
--
/*
  NAME
    get_opt_ovn
  DESCRIPTION
    Returns a option (definition) object version number.
*/
function get_opt_ovn
( p_business_group_id in number,
  p_option_definition in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_opt_ovn, WNDS);
--
------------------------------ get_pl_id ---------------------------
/*
  NAME
    get_pl_id
  DESCRIPTION
    Returns a Plan ID.
  NOTES
    This function returns a pl_id and is designed for use with the Data Pump.
*/
function get_pl_id
( p_business_group_id in number,
  p_plan              in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pl_id , WNDS);
--
/*
  NAME
    get_pl_ovn
  DESCRIPTION
    Returns a plan object version number.
*/
function get_pl_ovn
( p_business_group_id in number,
  p_plan              in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pl_ovn, WNDS);
--
------------------------------ get_pgm_id ---------------------------
/*
  NAME
    get_pgm_id
  DESCRIPTION
    Returns a Program ID.
  NOTES
    This function returns a pgm_id and is designed for use with the Data Pump.
*/
function get_pgm_id
( p_business_group_id in number,
  p_program           in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pgm_id, WNDS);
--
/*
  NAME
    get_pgm_ovn
  DESCRIPTION
    Returns a program object version number.
*/
function get_pgm_ovn
( p_business_group_id in number,
  p_program           in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_pgm_ovn, WNDS);
--
------------------------------ get_element_type_id ---------------------------
/*
  NAME
    get_element_type_id
  DESCRIPTION
    Returns an element_type_id given element_name
*/
function get_element_type_id
( p_business_group_id in number,
--p_legislation_code in varchar2,
  p_element_name    in varchar2,
  p_effective_date    in date
) return number;
pragma restrict_references (get_element_type_id, WNDS);
--
------------------------------ get_currency_code ---------------------------
/*
  NAME
    get_currency_code
  DESCRIPTION
    Returns a currency code given name or code.
*/
/* returns currency_code from fnd_currencies_vl */
function get_currency_code
( p_name_or_code    in varchar2,
  p_effective_date  in date
) return varchar2;
--pragma restrict_references (get_currency_code, WNDS);

/* start HR/PER additional get_xyz routines for BEN */

/* returns a uom code */
function get_uom_code
( p_uom            in varchar2,
  p_effective_date in date
) return varchar2;
--pragma restrict_references (get_uom_code, WNDS);

/* returns a std_prem_uom code */
function get_std_prem_uom_code
( p_std_prem_uom            in varchar2,
  p_effective_date in date
) return varchar2;
--pragma restrict_references (get_std_prem_uom_code, WNDS);

/* returns a comp_ref_uom code */
function get_comp_ref_uom_code
( p_comp_ref_uom            in varchar2,
  p_effective_date in date
) return varchar2;
--pragma restrict_references (get_comp_ref_uom_code, WNDS);

/* returns a rt_comp_ref_uom code */
function get_rt_comp_ref_uom_code
( p_rt_comp_ref_uom            in varchar2,
  p_effective_date in date
) return varchar2;
--pragma restrict_references (get_rt_comp_ref_uom_code, WNDS);

/* returns a amt_dsgd_uom code */
function get_amt_dsgd_uom_code
( p_amt_dsgd_uom            in varchar2,
  p_effective_date in date
) return varchar2;
--pragma restrict_references (get_amt_dsgd_uom_code, WNDS);

/* get_quald_bnf_person_id - requires user key */
function get_quald_bnf_person_id
(  p_quald_bnf_person_user_key in varchar2
) return number;
pragma restrict_references (get_quald_bnf_person_id, WNDS);

/* get_cvrd_emp_person_id - requires user key */
function get_cvrd_emp_person_id
(  p_cvrd_emp_person_user_key in varchar2
) return number;
pragma restrict_references (get_cvrd_emp_person_id, WNDS);

/* get_dpnt_person_id - requires user key */
function get_dpnt_person_id
(  p_dpnt_person_user_key in varchar2
) return number;
pragma restrict_references (get_dpnt_person_id, WNDS);

/* get_bnf_person_id - requires user key */
function get_bnf_person_id
(  p_bnf_person_user_key in varchar2
) return number;
pragma restrict_references (get_bnf_person_id, WNDS);

/* get_ttee_person_id - requires user key */
function get_ttee_person_id
(  p_ttee_person_user_key in varchar2
) return number;
pragma restrict_references (get_ttee_person_id, WNDS);

/**** end OAB additions *******/

------------------------------- get_person_id ---------------------------------
/*
  NAME
    get_person_id
  DESCRIPTION
    Returns a Person ID.
  NOTES
    This function returns a person_id and is designed for use
    with the Data Pump.
*/
function get_person_id
(
   p_person_user_key in varchar2
) return number;
pragma restrict_references (get_person_id, WNDS);

--------------------------- get_contact_person_id -----------------------------
/*
  NAME
    get_contact_person_id
  DESCRIPTION
    Returns a Contact Person ID.
  NOTES
    This function returns a contact_person_id and is designed for use
    with the Data Pump.
*/
function get_contact_person_id
(
   p_contact_person_user_key in varchar2
) return number;
pragma restrict_references (get_contact_person_id, WNDS);

----------------------------- get_assignment_id -------------------------------
/*
  NAME
    get_assignment_id
  DESCRIPTION
    Returns an Assignment ID.
  NOTES
    This function is returns an assignment_id and is designed for use
    with the Data Pump.
*/
function get_assignment_id
(
   p_assignment_user_key in varchar2
) return number;
pragma restrict_references (get_assignment_id, WNDS);

------------------------------- get_address_id --------------------------------
/*
  NAME
    get_address_id
  DESCRIPTION
    Returns an Address ID.
  NOTES
    This function returns an address_id and is designed for use
    with the Data Pump.
*/
function get_address_id
(
   p_address_user_key in varchar2
) return number;
pragma restrict_references (get_address_id, WNDS);

----------------------------- get_supervisor_id -------------------------------
/*
  NAME
    get_supervisor_id
  DESCRIPTION
    Returns a Supervisor ID.
  NOTES
    This function returns a supervisor_id and is designed for use
    with the Data Pump.
*/
function get_supervisor_id
(
   p_supervisor_user_key in varchar2
) return number;
pragma restrict_references (get_supervisor_id, WNDS);

------------------------------ get_recruiter_id -------------------------------
/*
  NAME
    get_recruiter_id
  DESCRIPTION
    Returns a Recruiter ID.
  NOTES
    This function returns a recruiter_id and is designed for use
    with the Data Pump.
*/
function get_recruiter_id
(
   p_recruiter_user_key in varchar2
) return number;
pragma restrict_references (get_recruiter_id, WNDS);

------------------------- get_person_referred_by_id ---------------------------
/*
  NAME
    get_person_referred_by_id
  DESCRIPTION
    Returns a Person Referred By ID.
  NOTES
    This function returns a person_referred_by_id and is designed for use
    with the Data Pump.
*/
function get_person_referred_by_id
(
   p_person_referred_by_user_key in varchar2
) return number;
pragma restrict_references (get_person_referred_by_id, WNDS);

-------------------------- get_timecard_approver_id ---------------------------
/*
  NAME
    get_timecard_approver_id
  DESCRIPTION
    Returns a Person ID for a timecard approver.
  NOTES
    This function returns a person_id, but is used for
    the timecard approver parameter.
*/
function get_timecard_approver_id
(
   p_timecard_approver_user_key in varchar2
) return number;
pragma restrict_references (get_timecard_approver_id, WNDS);

----------------------- get_contact_relationship_id ---------------------------
/*
  NAME
    get_contact_relationship_id
  DESCRIPTION
    Returns a Contact Relationship ID.
  NOTES
    This function returns a contact_relationship_id and is designed for use
    with the Data Pump.
*/
function get_contact_relationship_id
(
   p_contact_user_key   in varchar2,
   p_contactee_user_key in varchar2
) return number;
pragma restrict_references (get_contact_relationship_id, WNDS);

--------------------------- get_element_entry_id -------------------------------
/*
  NAME
    get_element_entry_id
    get_original_entry_id
    get_target_entry_id
  DESCRIPTION
    Functions returning Element Entry ID.
  NOTES
    Added for hr_element_entry_api.create_element_entry support.
*/
function get_element_entry_id
(
   p_element_entry_user_key in varchar2
) return number;
pragma restrict_references (get_element_entry_id, WNDS);
--------------------------- get_original_entry_id ------------------------------
function get_original_entry_id
(
   p_original_entry_user_key in varchar2
) return number;
pragma restrict_references (get_original_entry_id, WNDS);
--------------------------- get_target_entry_id --------------------------------
function get_target_entry_id
(
   p_target_entry_user_key in varchar2
) return number;
pragma restrict_references (get_target_entry_id, WNDS);

---------------------------- get_element_link_id -------------------------------
/*
  NAME
    get_element_link_id
  DESCRIPTION
    Returns an Element Link ID.
  NOTES
    Added for hr_element_entry_api.create_element_entry support.
*/
function get_element_link_id
(
   p_element_link_user_key in varchar2
) return number;
pragma restrict_references (get_element_link_id, WNDS);

--------------------- get_cost_allocation_keyflex_id ---------------------------
/*
  NAME
    get_cost_allocation_keyflex_id
  DESCRIPTION
    Returns a Cost Allocation Keyflex ID.
  NOTES
    Added for hr_element_entry_api.create_element_entry support.
*/
function get_cost_allocation_keyflex_id
(
   p_cost_alloc_keyflex_user_key in varchar2
) return number;
pragma restrict_references (get_cost_allocation_keyflex_id, WNDS);

------------------------------ get_comment_id ----------------------------------
/*
  NAME
    get_comment_id
  DESCRIPTION
    Returns a Comment ID
  NOTES
    Added for hr_element_entry_api.create_element_entry support.
*/
function get_comment_id( p_comment_user_key in varchar2 ) return number;
pragma restrict_references (get_comment_id, WNDS);

------------------------- get_assignment_action_id -----------------------------
/*
  NAME
    get_assignment_action_id
    get_updating_action_id
  DESCRIPTION
    Returns a Pay Assignment Action ID.
  NOTES
    Added for hr_element_entry_api.create_element_entry support.
*/
function get_assignment_action_id( p_assignment_action_user_key in varchar2 )
return number;
pragma restrict_references (get_assignment_action_id, WNDS);
--------------------------- get_updating_action_id -----------------------------
function get_updating_action_id( p_updating_action_user_key in varchar2 )
return number;
pragma restrict_references (get_updating_action_id, WNDS);

----------------------------- get_input_value_id -------------------------------
/*
  NAME
    get_input_value_id
    get_input_value_id1 .. get_input_value_id15
  DESCRIPTION
    Functions returning Input Value ID.
  NOTES
    These functions return input value ids and are designed for use with the
    Data Pump. Added for hr_element_entry_api.create_element_entry support.
*/
function get_input_value_id
(
  p_input_value_name  in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id, WNDS);
--
function get_input_value_id1
(
  p_input_value_name1 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id1, WNDS);
--
function get_input_value_id2
(
  p_input_value_name2 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id2, WNDS);
--
function get_input_value_id3
(
  p_input_value_name3 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id3, WNDS);
--
function get_input_value_id4
(
  p_input_value_name4 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id4, WNDS);
--
function get_input_value_id5
(
  p_input_value_name5 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id5, WNDS);
--
function get_input_value_id6
(
  p_input_value_name6 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id6, WNDS);
--
function get_input_value_id7
(
  p_input_value_name7 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id7, WNDS);
--
function get_input_value_id8
(
  p_input_value_name8 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id8, WNDS);
--
function get_input_value_id9
(
  p_input_value_name9 in varchar2,
  p_element_name      in varchar2,
  p_business_group_id in number,
  p_effective_date    in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id9, WNDS);
--
function get_input_value_id10
(
  p_input_value_name10 in varchar2,
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id10, WNDS);
--
function get_input_value_id11
(
  p_input_value_name11 in varchar2,
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id11, WNDS);
--
function get_input_value_id12
(
  p_input_value_name12 in varchar2,
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id12, WNDS);
--
function get_input_value_id13
(
  p_input_value_name13 in varchar2,
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id13, WNDS);
--
function get_input_value_id14
(
  p_input_value_name14 in varchar2,
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id14, WNDS);
--
function get_input_value_id15
(
  p_input_value_name15 in varchar2,
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date,
  p_language_code     in varchar2
) return number;
pragma restrict_references (get_input_value_id15, WNDS);

-------------------------------- get_rate_id ----------------------------------
/*
  NAME
    get_rate_id
  DESCRIPTION
    Function returning Rate ID.
*/
function get_rate_id
( p_rate_name         in varchar2,
  p_business_group_id in number
) return number;
pragma restrict_references (get_rate_id, WNDS);

----------------------------- get_person_type_id ------------------------------
/*
  NAME
    get_person_type_id
  DESCRIPTION
    Returns a Person Type ID.
  NOTES
    This function returns a person_type_id.
*/
function get_person_type_id
(
   p_user_person_type  in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number;
pragma restrict_references (get_person_type_id, WNDS);

-------------------------------- get_vendor_id --------------------------------
/*
  NAME
    get_vendor_id
  DESCRIPTION
    Returns a Vendor ID.
  NOTES
    This function returns a vendor_id.
*/
function get_vendor_id
(
   p_vendor_name in varchar2
) return number;
pragma restrict_references (get_vendor_id, WNDS);

------------------------ get_assignment_status_type_id ------------------------
/*
  NAME
    get_assignment_status_type_id
  DESCRIPTION
    Returns an Assignment Status Type ID.
  NOTES
    This function returns an assignment_status_type_id.
*/
function get_assignment_status_type_id
(
   p_user_status       in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number;
pragma restrict_references (get_assignment_status_type_id, WNDS);

----------------------------- get_organization_id -----------------------------
/*
  NAME
    get_organization_id
  DESCRIPTION
    Returns an Organization ID.
  NOTES
    This function returns an organization_id.
*/
function get_organization_id
(
   p_organization_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
,  p_language_code     in varchar2
) return number;
pragma restrict_references (get_organization_id, WNDS);

--------------------------- get_establishment_org_id ----------------------------
/*
  NAME
    get_establishment_org_id
  DESCRIPTION
    Returns an Establishment (Organization) ID.
  NOTES
    This function returns an establishment organization_id for the
    assignment APIs.
*/
function get_establishment_org_id
(
   p_establishment_org_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
,  p_language_code     in varchar2
) return number;
pragma restrict_references (get_establishment_org_id, WNDS);

-------------------------- get_source_organization_id -------------------------
/*
  NAME
    get_source_organization_id
  DESCRIPTION
    Returns a Source Organization ID.
  NOTES
    This function returns a source_organization_id.
*/
function get_source_organization_id
(
   p_source_organization_name in varchar2,
   p_business_group_id        in number,
   p_effective_date           in date
,  p_language_code            in varchar2
) return number;
pragma restrict_references (get_source_organization_id, WNDS);

--------------------------------- get_grade_id --------------------------------
/*
  NAME
    get_grade_id
  DESCRIPTION
    Returns a Grade ID.
  NOTES
    This function returns a grade_id.
*/
function get_grade_id
(
   p_grade_name        in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_grade_id, WNDS);

----------------------------- get_entry_grade_id ------------------------------
/*
  NAME
    get_entry_grade_id
  NOTES
    Calls get_grade_id.
*/
function get_entry_grade_id
(
   p_entry_grade_name  in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_entry_grade_id, WNDS);

------------------------------- get_position_id -------------------------------
/*
  NAME
    get_position_id
  DESCRIPTION
    Returns a Position ID.
  NOTES
    This function returns a position_id.
*/
function get_position_id
(
   p_position_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_position_id, WNDS);

------------------------- get_successor_position_id ---------------------------
/*
  NAME
    get_successor_position_id
  DESCRIPTION
    Returns a Successor Position ID.
  NOTES
    This function returns a successor_position_id.
*/
function get_successor_position_id
(
   p_successor_position_name in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
) return number;
pragma restrict_references (get_successor_position_id, WNDS);

------------------------- get_relief_position_id ---------------------------
/*
  NAME
    get_relief_position_id
  DESCRIPTION
    Returns a Relief Position ID.
  NOTES
    This function returns a relief_position_id.
*/
function get_relief_position_id
(
   p_relief_position_name in varchar2,
   p_business_group_id    in number,
   p_effective_date       in date
) return number;
pragma restrict_references (get_relief_position_id, WNDS);

------------------------- get_prior_position_id ---------------------------
/*
  NAME
    get_prior_position_id
  NOTES
    Calls get_position_id.
*/
function get_prior_position_id
(
   p_prior_position_name     in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
) return number;
pragma restrict_references (get_prior_position_id, WNDS);

------------------------- get_supervisor_position_id ---------------------------
/*
  NAME
    get_supervisor_position_id
  NOTES
    Calls get_position_id.
*/
function get_supervisor_position_id
(
   p_supervisor_position_name in varchar2,
   p_business_group_id        in number,
   p_effective_date           in date
) return number;
pragma restrict_references (get_supervisor_position_id, WNDS);

--------------------------------- get_job_id ----------------------------------
/*
  NAME
    get_job_id
  DESCRIPTION
    Returns a Job ID.
  NOTES
    This function returns a job_id.
*/
function get_job_id
(
   p_job_name          in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
) return number;
pragma restrict_references (get_job_id, WNDS);

------------------------------- get_payroll_id --------------------------------
/*
  NAME
    get_payroll_id
  DESCRIPTION
    Returns a Payroll ID.
  NOTES
    This function returns a payroll_id.
*/
function get_payroll_id
(
   p_payroll_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_payroll_id, WNDS);

--------------------------- get_pay_freq_payroll_id ----------------------------
/*
  NAME
    get_pay_freq_payroll_id
  NOTES
    Calls get_payroll_id.
*/
function get_pay_freq_payroll_id
(
   p_pay_freq_payroll_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_pay_freq_payroll_id, WNDS);

------------------------- get_location_id_update --------------------------
/*
  NAME
    get_location_id_update
  DESCRIPTION
    Returns a Location ID.
  NOTES
    Calls get_location_id, but was written to allow the update_location
    APIs to update the location_code.
    The name does not end in _ID so that it's always seeded as a mapping
    function.
*/
function get_location_id_update
(
   p_existing_location_code in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number;
pragma restrict_references (get_location_id_update, WNDS);

------------------------------ get_location_id --------------------------------
/*
  NAME
    get_location_id
  DESCRIPTION
    Returns a Location ID.
  NOTES
    This function returns a location_id.
*/
function get_location_id
(
   p_location_code     in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number;
pragma restrict_references (get_location_id, WNDS);
-----------------------------get_designated_receiver_id -----------------------
/*
  NAME
   get_designated_receiver_id
  DESCRIPTION
   Returns receiver id
*/
function get_designated_receiver_id
(
  p_designated_receiver_name In Varchar2,
  p_business_group_id        In Number,
  p_effective_date           In Date
) return number;
pragma restrict_references (get_designated_receiver_id, WNDS);

------------------------------ get_ship_to_location_id --------------------------------
/*
  NAME
    get_ship_location_id
  DESCRIPTION
    Returns a Location ID.
  NOTES
    This function returns a location_id.
*/
function get_ship_to_location_id
(
   p_ship_to_location_code     in varchar2,
   p_business_group_id in number,
   p_language_code     in varchar2
) return number;
pragma restrict_references (get_ship_to_location_id, WNDS);

------------------------------ get_pay_basis_id -------------------------------
/*
  NAME
    get_pay_basis_id
  DESCRIPTION
    Returns a Pay Basis ID.
  NOTES
    This function returns a pay_basis_id.
*/
function get_pay_basis_id
(
   p_pay_basis_name    in varchar2,
   p_business_group_id in number
) return number;
pragma restrict_references (get_pay_basis_id, WNDS);

------------------------- get_recruitment_activity_id -------------------------
/*
  NAME
    get_recruitment_activity_id
  DESCRIPTION
    Returns a Recruitment Activity ID.
  NOTES
    This function returns a recruitment_activity_id.
*/
function get_recruitment_activity_id
(
   p_recruitment_activity_name in varchar2,
   p_business_group_id         in number,
   p_effective_date            in date
) return number;
pragma restrict_references (get_recruitment_activity_id, WNDS);

-------------------------------- get_vacancy_id -------------------------------
/*
  NAME
    get_vacancy_id
  DESCRIPTION
    Returns a Vacancy ID.
  NOTES
    This function returns a vacancy_id. The user needs to set up the user
    key value.
*/
function get_vacancy_id
(
   p_vacancy_user_key in varchar2
) return number;
pragma restrict_references (get_vacancy_id, WNDS);

-------------------------- get_org_payment_method_id --------------------------
/*
  NAME
    get_org_payment_method_id
  DESCRIPTION
    Returns an Organization Payment Method ID.
  NOTES
    This function returns an org_payment_method_id.
*/
function get_org_payment_method_id
(
   p_org_payment_method_user_key in varchar2
) return number;
pragma restrict_references (get_org_payment_method_id, WNDS);

------------------------------ get_payee_org_id -------------------------------
/*
  NAME
    get_org_payee_id
  DESCRIPTION
    Returns a Payee ID for a payee that is an organization.
  NOTES
    This function returns a payee_id.
*/
function get_payee_org_id
(
   p_payee_organization_name in varchar2,
   p_business_group_id       in number,
   p_effective_date          in date
,  p_language_code           in varchar2
) return number;
pragma restrict_references (get_payee_org_id, WNDS);

----------------------------- get_payee_person_id -----------------------------
/*
  NAME
    get_payee_person_id
  DESCRIPTION
    Returns a Person ID that is a person.
  NOTES
    This function returns a person_id and is designed for use
    with the Data Pump.
*/
function get_payee_person_id
(
   p_payee_person_user_key in varchar2
) return number;
pragma restrict_references (get_payee_person_id, WNDS);

-------------------------------- get_payee_id ----------------------------------
/*
  NAME
    get_payee_id
  DESCRIPTION
    Returns a Payee ID for a payee that is an organization or a person.
*/
function get_payee_id
(
   p_data_pump_always_call in varchar2,
   p_payee_type            in varchar2,
   p_business_group_id     in number,
   p_payee_org             in varchar2 default null,
   p_payee_person_user_key in varchar2 default null,
   p_effective_date        in date
,  p_language_code         in varchar2
) return number;
pragma restrict_references (get_payee_id, WNDS);

----------------------- get_personal_payment_method_id ------------------------
/*
  NAME
    get_personal_payment_method_id
  DESCRIPTION
    Returns a Personal Payment Method ID.
  NOTES
    This function returns a personal_payment_method_id.
*/
function get_personal_payment_method_id
(
   p_personal_pay_method_user_key in varchar2
) return number;
pragma restrict_references (get_personal_payment_method_id, WNDS);

----------------------------- get_set_of_books_id -----------------------------
/*
  NAME
    get_set_of_books_id
  DESCRIPTION
    Returns a Set of Books ID.
  NOTES
    This function returns a set_of_books_id.
*/
function get_set_of_books_id
(
   p_set_of_books_name varchar2
) return number;
pragma restrict_references (get_set_of_books_id, WNDS);

------------------------------- get_tax_unit_id -------------------------------
/*
  NAME
    get_tax_unit_id
  DESCRIPTION
    Returns a Tax Unit ID.
  NOTES
    This function returns a tax_unit_id.
    Return code of varchar2 to match API parameter type.
*/
function get_tax_unit_id
(
   p_tax_unit_name in varchar2,
   p_effective_date in date
) return varchar2;
pragma restrict_references (get_tax_unit_id, WNDS);

------------------------------ get_work_schedule ------------------------------
/*
  NAME
    get_work_schedule
  DESCRIPTION
    Returns a user_column_id for a work schedule.
  NOTES
    This function is used to return a user_column_id when
    used by US API.
*/
function get_work_schedule
(
   p_work_schedule     in varchar2,
   p_organization_name in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
,  p_language_code     in varchar2
) return number;
pragma restrict_references (get_work_schedule, WNDS);

--------------------------- get_eeo_1_establishment ---------------------------
/*
  NAME
    get_eeo_1_establishment
  DESCRIPTION
    Returns a establishment_id.
  NOTES
    <none>
*/
function get_eeo_1_establishment_id
(
   p_eeo_1_establishment in varchar2,
   p_business_group_id   in number,
   p_effective_date      in date
) return number;
pragma restrict_references (get_eeo_1_establishment_id, WNDS);

------------------------- get_correspondence_language -------------------------
/*
  NAME
    get_correspondence_language
  DESCRIPTION
    Returns a language code.
  NOTES
    Uses the FND_LANGUAGES table. If p_correspondance_language cannot be
    matched, it is assumed that the user entered the language code.
*/
function get_correspondence_language
(
   p_correspondence_language varchar2
) return varchar2;
pragma restrict_references (get_correspondence_language, WNDS);

------------------------------ get_id_flex_num ---------------------------------
/*
  NAME
    get_id_flex_num
  DESCRIPTION
    Returns an id_flex_num for a keyflex structure.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_id_flex_num
(
   p_id_flex_num_user_key varchar2
) return number;
pragma restrict_references (get_id_flex_num, WNDS);

----------------------------- get_program_application_id ----------------------
/*
  NAME
    get_program_application_id
  DESCRIPTION
    Returns a Program Application ID.
  NOTES
    Standard who column.
*/
function get_program_application_id return number;
pragma restrict_references (get_program_application_id, WNDS);

--------------------------------- get_program_id ------------------------------
/*
  NAME
    get_program_id
  DESCRIPTION
    Returns a Program ID.
  NOTES
    Standard who column.
*/
function get_program_id return number;
pragma restrict_references (get_program_id, WNDS);

--------------------------------- get_request_id ------------------------------
/*
  NAME
    get_request_id
  DESCRIPTION
    Returns a Request ID.
  NOTES
    Standard who column.
*/
function get_request_id return number;
pragma restrict_references (get_request_id, WNDS);

--------------------------------- get_creator_id ------------------------------
/*
  NAME
    get_creator_id
  DESCRIPTION
    Returns a Creator ID.
  NOTES
    Standard who column.
*/
function get_creator_id return number;
pragma restrict_references (get_creator_id, WNDS);

----------------------------- get_gr_grade_rule_id --------------------------------
/*
  NAME
    get_gr_grade_rule_id
    get_pp_grade_rule_id
  DESCRIPTION
    Functions returning Grade Rule ID.
    get_pp_grade_rule_id uses the progression (spinal) point and pay scale
    (parent spine) name to get the grade_rule_id. get_gr_grade_rule_id uses
    the grade name to get the grade_rule_id.
  NOTES
    get_gr_grade_rule_id is designed for use with the HR GRADE API.
    get_pp_grade_rule_id is designed for use with the HR PAY SCALE API.
*/
function get_gr_grade_rule_id
(
   p_grade_name        in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
pragma restrict_references (get_gr_grade_rule_id, WNDS);
--
function get_pp_grade_rule_id
(
   p_progression_point in varchar2,
   p_pay_scale         in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
pragma restrict_references (get_pp_grade_rule_id, WNDS);

function get_ar_grade_rule_id
(
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
pragma restrict_references (get_pp_grade_rule_id, WNDS);
--------------------------- get_organization_structure_id --------------------------------
/*
  NAME
    get_organization_structure_id
  DESCRIPTION
    Function returning Organization Structure ID
*/
function get_organization_structure_id
(
 p_name in varchar2,
 p_business_group_id in number
)
return number;
pragma restrict_references (get_organization_structure_id, WNDS);

--------------------------- get_org_str_ver_id --------------------------------
/*
  NAME
    get_org_str_ver_id
  DESCRIPTION
    Function returning Organization Structure Version ID
*/
function get_org_str_ver_id
(
 p_business_group_id in number,
 p_organization_structure_id in number,
 p_date_from in date,
 p_version_number in number
)
return number;
pragma restrict_references (get_org_str_ver_id, WNDS);

--------------------------- get_spinal_point_id --------------------------------
/*
  NAME
    get_spinal_point_id
  DESCRIPTION
    Function returning Spinal Point ID.
    get_spinal_point_id uses the progression (spinal) point and pay scale
    (parent spine) name to get the spinal_point_id.
*/
function get_spinal_point_id
(
   p_progression_point in varchar2,
   p_pay_scale         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
pragma restrict_references (get_spinal_point_id, WNDS);

-------------------------------- get_country -----------------------------------
/*
  NAME
    get_country
  DESCRIPTION
    Function returning a territory code when supplied a territory short
    name. If the short name does not match, the code assumes that
    the user supplied the code and returns p_country.
*/
function get_country( p_country in varchar2 ) return varchar2;
pragma restrict_references (get_country, WNDS);

------------------------- get_period_of_service_id -----------------------------
/*
  NAME
    get_at_period_of_service_id
    get_fp_period_of_service_id
    get_ut_period_of_service_id
  DESCRIPTION
    Functions returning Period Of Service ID.
    get_at_period_of_service_id gets the period_of_service_id in the case
    where the actual termination date has not been set.
    get_fp_period_of_service_id gets the period_of_service_id in the case
    where the actual termination date has been set, but the final process
    date has not been set.
    get_ut_period_of_service_id gets the period of service for a effective date
  NOTES
    get_at_period_of_service_id is designed for use with
    hr_ex_employee.actual_termination_emp.
    get_fp_period_of_service_id is designed for use with
    hr_ex_employee.final_process_emp.
    get_ut_period_of_service_id is designed for use with
    hr_ex_employee.update_term_details_emp.
*/
function get_at_period_of_service_id
(
   p_person_user_key in varchar2,
   p_business_group_id in number
)
return number;
pragma restrict_references (get_at_period_of_service_id, WNDS);
function get_fp_period_of_service_id
(
   p_person_user_key in varchar2,
   p_business_group_id in number
)
return number;
pragma restrict_references (get_fp_period_of_service_id, WNDS);

/* Added for 11i,Rvydyana,02-DEC-1999 */
function get_ut_period_of_service_id
(
   p_person_user_key   in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
)
return number;
pragma restrict_references (get_ut_period_of_service_id, WNDS);

------------------------ get_special_ceiling_step_id ---------------------------
/*
  NAME
    get_special_ceiling_step_id
  DESCRIPTION
    Returns an id_flex_num for a keyflex structure.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_special_ceiling_step_id
(
   p_special_ceilin_step_user_key varchar2
) return number;
pragma restrict_references (get_special_ceiling_step_id, WNDS);

---------------------------- get_entry_step_id -------------------------------
/*
  NAME
    get_entry_step_id
  DESCRIPTION
    Returns a Spinal Point Step ID.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_entry_step_id
(
   p_entry_step_user_key in varchar2
) return number;
pragma restrict_references (get_entry_step_id, WNDS);

---------------------------- get_entry_grade_rule_id -------------------------------
/*
  NAME
    get_entry_grade_rule_id
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_entry_grade_rule_id
(
   p_entry_grade_rule_user_key in varchar2
) return number;
pragma restrict_references (get_entry_grade_rule_id, WNDS);

----------------------- get_availability_status_id ---------------------------
/*
  NAME
    get_availability_status_id
  DESCRIPTION
    Function returning Availability Status ID.
*/
function get_availability_status_id
(p_shared_type_name  in   varchar2
,p_system_type_cd    in   varchar2
,p_business_group_id in   number
,p_language_code     in   varchar2
) return number ;
pragma restrict_references (get_availability_status_id, WNDS);

------------------------ get_default_code_comb_id ------------------------------
/*
  NAME
    get_default_code_comb_id
  DESCRIPTION
    Returns the default_code_comb_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_default_code_comb_id
(
   p_default_code_comb_user_key varchar2
) return number;
pragma restrict_references (get_default_code_comb_id, WNDS);

------------------------ get_phone_id -----------------------------------------
/*
  NAME
    get_phone_id
  DESCRIPTION
    Returns the phone_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
/* Added for 11i - Rvydyana - 06-DEC-1999 */
function get_phone_id
(
   p_phone_user_key in varchar2
) return number;
pragma restrict_references (get_phone_id, WNDS);
------------------------ get_job_group_id -----------------------------------------
/*
  NAME
    get_job_group_id
  DESCRIPTION
    Returns the job_group_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_job_group_id
(
   p_job_group_user_key in varchar2
) return number;
pragma restrict_references (get_job_group_id, WNDS);
------------------------ get_loc_id -----------------------------------------
/*
  NAME
    get_loc_id
  DESCRIPTION
  sets p_location_id as a user key
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_loc_id
(
   p_location_user_key in varchar2
) return number;
pragma restrict_references (get_loc_id, WNDS);
------------------------ get_org_structure_id -----------------------------------------
/*
  NAME
    get_org_structure_id
  DESCRIPTION
  sets p_organization_structure_id as a user key
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_org_structure_id
(
   p_org_structure_user_key in varchar2
) return number;
pragma restrict_references (get_org_structure_id, WNDS);
------------------------ get_org_str_version_id -----------------------------------------
/*
  NAME
    get_org_str_version_id
  DESCRIPTION
  sets p_org_structure_version_id as a user key
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_org_str_version_id
(
   p_org_str_version_user_key in varchar2
) return number;
pragma restrict_references (get_org_str_version_id, WNDS);
------------------------ get_org_id -----------------------------------------
/*
  NAME
    get_org_id
  DESCRIPTION
  sets p_organization_id as a user key
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_org_id
(
   p_org_user_key in varchar2
) return number;
pragma restrict_references (get_org_id, WNDS);
------------------------ get_grade_rule_id -----------------------------------------
/*
  NAME
    get_grade_rule_id
  DESCRIPTION
    Returns the grade_rule_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_grade_rule_id
(
   p_grade_rule_user_key in varchar2
) return number;
pragma restrict_references (get_grade_rule_id, WNDS);
------------------------ get_benchmark_job_id -----------------------------------------
/*
  NAME
    get_benchmark_job_id
  DESCRIPTION
    Returns the benchmark_job_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_benchmark_job_id
(
   p_benchmark_job_user_key in varchar2
) return number;
pragma restrict_references (get_benchmark_job_id, WNDS);
------------------------ get_role_id -----------------------------------------
/*
  NAME
    get_role_id
  DESCRIPTION
    Returns the role_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_role_id
(
   p_role_user_key in varchar2
) return number;
pragma restrict_references (get_role_id, WNDS);

------------------------ get_grade_ladder_pgm_id ------------------------------
/*
  NAME
    get_grade_ladder_pgm_id
  DESCRIPTION
    Returns the grade_ladder_pgm_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_grade_ladder_pgm_id
(
   p_grade_ladder_name in varchar2
  ,p_business_group_id in number
  ,p_effective_date    in date
) return number;
pragma restrict_references (get_grade_ladder_pgm_id, WNDS);

------------------------ get_supervisor_assignment_id ------------------------
/*
  NAME
    get_supervisor_assignment_id
  DESCRIPTION
    Returns the supervisor_assignment_id.
  NOTES
    Uses the HR_PUMP_BATCH_LINES_USER_KEY table which the user must seed.
*/
function get_supervisor_assignment_id
(
   p_svr_assignment_user_key in varchar2
) return number;
pragma restrict_references (get_supervisor_assignment_id, WNDS);

/*--------------------- get_parent_spine_id ----------------------------------*/
function get_parent_spine_id
(
   p_parent_spine      in varchar2,
   p_business_group_id in number
)
return number;
/*--------------------- get_ceiling_step_id ----------------------------------*/
function get_ceiling_step_id
(
   p_ceiling_point     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
/*---------------------------------------------------------------------------*/
/*------------------- get object version number functions -------------------*/
/*---------------------------------------------------------------------------*/

---------------------- get_collective_agreement_ovn ------------------------
/*
  NAME
    get_collective_agreement_ovn
  DESCRIPTION
    Returns a Collective Agreement object version number.
*/
function get_collective_agreement_ovn
(p_business_group_id in number
,p_cagr_name         in varchar2
,p_effective_date    in date
) return number;
pragma restrict_references (get_collective_agreement_ovn, WNDS);

------------------------------- get_contract_ovn ---------------------------
/*
  NAME
    get_contract_ovn
  DESCRIPTION
    Returns a Contract object version number.
*/
function get_contract_ovn
(p_contract_user_key in varchar2
,p_effective_date    in date
) return number;
pragma restrict_references (get_contract_ovn, WNDS);

----------------------------- get_establishment_ovn ---------------------------
/*
  NAME
    get_establishment_ovn
  DESCRIPTION
    Returns an Establishment object version number.
*/
function get_establishment_ovn
(p_establishment_name in varchar2
,p_location           in varchar2
) return number;
pragma restrict_references (get_establishment_ovn, WNDS);

----------------------- get_us_emp_fed_tax_rule_ovn --------------------------
/*
  NAME
    get_us_emp_fed_tax_rule_ovn
  DESCRIPTION
    Returns a tax rule Object Version Number.
  NOTES
    This returns an object version number for a tax rule that has
    been created via the Data Pump engine.
*/
function get_us_emp_fed_tax_rule_ovn
(
   p_emp_fed_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;
pragma restrict_references (get_us_emp_fed_tax_rule_ovn, WNDS);


----------------------- get_us_emp_state_tax_rule_ovn --------------------------
/*
  NAME
    get_us_emp_state_tax_rule_ovn
  DESCRIPTION
    Returns a tax rule Object Version Number.
  NOTES
    This returns an object version number for a tax rule that has
    been created via the Data Pump engine.
*/
function get_us_emp_state_tax_rule_ovn
(
   p_emp_state_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;
pragma restrict_references (get_us_emp_state_tax_rule_ovn, WNDS);

----------------------- get_us_emp_county_tax_rule_ovn --------------------------
/*
  NAME
    get_us_emp_county_tax_rule_ovn
  DESCRIPTION
    Returns a tax rule Object Version Number.
  NOTES
    This returns an object version number for a tax rule that has
    been created via the Data Pump engine.
*/
function get_us_emp_county_tax_rule_ovn
(
   p_emp_county_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;
pragma restrict_references (get_us_emp_county_tax_rule_ovn, WNDS);

----------------------- get_us_emp_city_tax_rule_ovn --------------------------
/*
  NAME
    get_us_emp_city_tax_rule_ovn
  DESCRIPTION
    Returns a tax rule Object Version Number.
  NOTES
    This returns an object version number for a tax rule that has
    been created via the Data Pump engine.
*/
function get_us_emp_city_tax_rule_ovn
(
   p_emp_city_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;
pragma restrict_references (get_us_emp_city_tax_rule_ovn, WNDS);

--------------------------------- get_per_ovn ---------------------------------
/*
  NAME
    get_per_ovn
  DESCRIPTION
    Returns a Person Object Version Number.
  NOTES
    This returns an object version number for a person that has
    been created via the Data Pump engine.
*/
function get_per_ovn
(
   p_person_user_key in varchar2,
   p_effective_date  in date
) return number;
pragma restrict_references (get_per_ovn, WNDS);

--------------------------------- get_asg_ovn ---------------------------------
/*
  NAME
    get_asg_ovn
  DESCRIPTION
    Returns an Assignment Object Version Number.
  NOTES
    This returns an object version number for an assignment that has
    been created via the Data Pump engine.
*/
function get_asg_ovn
(
   p_assignment_user_key in varchar2,
   p_effective_date      in date
) return number;
pragma restrict_references (get_asg_ovn, WNDS);

--------------------------------- get_adr_ovn ---------------------------------
/*
  NAME
    get_adr_ovn
  DESCRIPTION
    Returns an Address Object Version Number.
  NOTES
    This returns an object version number for an address that has
    been created via the Data Pump engine.
*/
function get_adr_ovn
(
   p_address_user_key in varchar2,
   p_effective_date   in date
) return number;
pragma restrict_references (get_adr_ovn, WNDS);

--------------------------------- get_loc_ovn ---------------------------------
/*
  NAME
    get_loc_ovn
  DESCRIPTION
    Returns a Location Object Version Number.
  NOTES
    Returns an object version number for a location.
    This function can be used outside the data pump.
*/
function get_loc_ovn
(
   p_location_code in varchar2
) return number;
pragma restrict_references (get_loc_ovn, WNDS);

--------------------------------- get_org_str_ovn ------------------------------
/*
  NAME
    get_org_str_ovn
  DESCRIPTION
    Returns an Organization Structure  Object Version Number.
  NOTES
    Returns an object version number for an organization strucutre.
    This function can be used outside the data pump.
*/
function get_org_str_ovn
(
   p_name in varchar2,
   p_business_group_id in number
) return number;
pragma restrict_references (get_org_str_ovn, WNDS);

--------------------------------- get_org_str_ver_ovn ------------------------------
/*
  NAME
    get_org_str_ver_ovn
  DESCRIPTION
    Returns an Organization Structure Version Object Version Number.
  NOTES
    Returns an object version number for an organization strucutre version.
    This function can be used outside the data pump.
*/
function get_org_str_ver_ovn
(
   p_business_group_id in number,
    p_organization_structure_id in number,
   p_date_from in date,
   p_version_number in number
) return number;
pragma restrict_references (get_org_str_ver_ovn, WNDS);
--------------------------------- get_org_ovn ------------------------------
/*
  NAME
    get_org_ovn
  DESCRIPTION
    Returns an Organization Object Version Number.
  NOTES
    Returns an object version number for an organization.
    This function can be used outside the data pump.
*/
function get_org_ovn
(
   p_business_group_id in number,
   p_organization_name in varchar2,
   p_language_code in varchar2
) return number;
pragma restrict_references (get_org_ovn, WNDS);
--------------------------------- get_job_ovn ---------------------------------
/*
  NAME
    get_job_ovn
  DESCRIPTION
    Returns a Job Object Version Number.
  NOTES
    Returns an object version number for a job.
    This function can be used outside the data pump.
*/
function get_job_ovn
(
   p_job_name          in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
) return number;
pragma restrict_references (get_job_ovn, WNDS);

--------------------------------- get_position_definition_id ---------------------------------
/*
  NAME
    get_pos_ovn
  DESCRIPTION
    Returns a Position Object Version Number.
  NOTES
    Returns an object version number for a position.
    This function can be used outside the data pump.
*/
function get_position_definition_id
(
   p_position_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_position_definition_id, WNDS);
--------------------------------- get_pos_ovn ---------------------------------
/*
  NAME
    get_pos_ovn
  DESCRIPTION
    Returns a Position Object Version Number.
  NOTES
    Returns an object version number for a position.
    This function can be used outside the data pump.
*/
function get_pos_ovn
(
   p_position_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
pragma restrict_references (get_pos_ovn, WNDS);

-------------------------------- get_ppm_ovn ----------------------------------
/*
  NAME
    get_ppm_ovn
  DESCRIPTION
    Returns a Personal Payment Method Object Version Number.
  NOTES
    This function returns a person payment method ovn.
*/
function get_ppm_ovn
(
   p_personal_pay_method_user_key in varchar2,
   p_effective_date               in date
) return number;
pragma restrict_references (get_ppm_ovn, WNDS);

--------------------------- get_element_entry_ovn ------------------------------
/*
  NAME
    get_element_entry_ovn
  DESCRIPTION
    Functions returning Element Entry Object Version Number.
*/
function get_element_entry_ovn
(
   p_element_entry_user_key in varchar2,
   p_effective_date         in date
) return number;
pragma restrict_references (get_element_entry_ovn, WNDS);

---------------------------- get_grade_rule_ovn --------------------------------
/*
  NAME
    get_gr_grade_rule_ovn
    get_pp_grade_rule_ovn
  DESCRIPTION
    Functions returning Grade Rule Object Version Number.
    get_pp_grade_rule_id uses the progression (spinal) point and pay scale
    (parent spine) name to get the grade rule object version number.
    get_gr_grade_rule_id uses the grade name to get the object version number.
  NOTES
    get_gr_grade_rule_id is designed for use with the HR GRADE API.
    get_pp_grade_rule_id is designed for use with the HR PAY SCALE API.
*/
function get_gr_grade_rule_ovn
(
   p_grade_name        in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
pragma restrict_references (get_gr_grade_rule_ovn, WNDS);
--
function get_pp_grade_rule_ovn
(
   p_progression_point in varchar2,
   p_pay_scale         in varchar2,
   p_rate_name         in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
return number;
pragma restrict_references (get_pp_grade_rule_ovn, WNDS);

------------------------- get_period_of_service_ovn-----------------------------
/*
  NAME
    get_at_period_of_service_ovn
    get_fp_period_of_service_ovn
    get_ut_period_of_service_ovn
  DESCRIPTION
    Functions returning Period Of Service Object Version Number.
    get_at_period_of_service_id gets the period_of_service object version
    number in the case where the actual termination date has not been set.
    get_at_period_of_service_id gets the period_of_service object version
    number in the case where the actual termination date has been set, but
    the final process date has not been set.
    get_ut_period_of_service_id gets the period_of_service object version
    number for a period_of_service_id for a effective date
  NOTES
    get_at_period_of_service_ovn is designed for use with
    hr_ex_employee.actual_termination_emp.
    get_fp_period_of_service_ovn is designed for use with
    hr_ex_employee.final_process_emp.
    get_ut_period_of_service_ovn is designed for use with
    hr_ex_employee.update_term_details_emp.
*/
function get_at_period_of_service_ovn
(
   p_person_user_key in varchar2,
   p_business_group_id in number
)
return number;
pragma restrict_references (get_at_period_of_service_ovn, WNDS);
function get_fp_period_of_service_ovn
(
   p_person_user_key in varchar2,
   p_business_group_id in number
)
return number;
pragma restrict_references (get_fp_period_of_service_ovn, WNDS);

/* Added for 11i,Rvydyana,02-DEC-1999 */
function get_ut_period_of_service_ovn
(
   p_person_user_key   in varchar2,
   p_effective_date    in date,
   p_business_group_id in number
)
return number;
pragma restrict_references (get_ut_period_of_service_ovn, WNDS);

/* This function is used to derive the phone ovn for a phone user key */
/* Added for 11i,Rvydyana,06-DEC-1999 */
function get_phn_ovn
(
   p_phone_user_key in varchar2
) return number;
pragma restrict_references (get_phn_ovn, WNDS);
--
/* This function is used to derive the job group ovn for a job group user key */
function get_jgr_ovn
(
   p_job_group_user_key in varchar2
   ) return number;
   pragma restrict_references (get_jgr_ovn, WNDS);
--
/* This function is used to derive the role ovn for a role user key */
function get_rol_ovn
(
   p_role_user_key in varchar2
   ) return number;
   pragma restrict_references (get_rol_ovn, WNDS);

/*-------------- returns a pay scale object version number --------------------*/
function get_pay_scale_ovn
(
   p_pay_scale          in varchar2,
   p_business_group_id in number
) return number;
/*-------------- returns a preogresion point object version number ------------*/
function get_progression_point_ovn
(
   p_point              in varchar2,
   p_business_group_id  in number
) return number;
/*-------------- returns a grade scale object version number ------------*/
function get_grade_scale_ovn
(
   p_grade              in varchar2,
   p_pay_scale          in varchar2,
   p_effective_date     in date,
   p_business_group_id  in number
) return number;
/*-------------- returns a grade step object version number ------------*/
function get_grade_step_ovn
(
   p_point              in varchar2,
   p_sequence           in number,
   p_effective_date     in date,
   p_business_group_id  in number
) return number;

/*---------------------------------------------------------------------------*/
/*----------------------- other special get functions -----------------------*/
/*---------------------------------------------------------------------------*/

------------------------------ get_change_reason ------------------------------
/*
  NAME
    get_change_reason
  DESCRIPTION
    Returns the lookup code for change reason.
  NOTES
    This function is used to get the change reason lookup code
    because the lookup type is dependent on the type of
    assignment.  Therefore, need to pass the assignment
    parameter information as well.
    If the change reason cannot be matched as a lookup meaning
    the code assumes that the user entered the lookup code
    directly.
*/
function get_change_reason
(
   p_change_reason       in varchar2,
   p_assignment_user_key in varchar2,
   p_effective_date      in date,
   p_language_code       in varchar2
) return varchar2;
--pragma restrict_references (get_change_reason, WNDS);

------------------------------- get_lookup_code -------------------------------
/*
  NAME
    get_lookup_code
  DESCRIPTION
    Returns the lookup code for a lookup type and meaning. If it cannot
    match the meaning, it will assume that p_meaning_or_code holds the
    lookup code and return p_meaning_or_code.
  NOTES
    This function designed to be called from the wrapper
    functions.
*/
function get_lookup_code
(
   p_meaning_or_code in varchar2,
   p_lookup_type     in varchar2,
   p_effective_date  in date     default null,
   p_language_code   in varchar2 default null
) return varchar2;
--pragma restrict_references (get_lookup_code, WNDS);

--------------------------------- gl ----------------------------------------
/*
   NAME
     gl
   DESCRIPTION
     Shortened name to save space for get_lookup_code call in wrapper
     functions.
 */
function gl
(
   p_meaning_or_code in varchar2,
   p_lookup_type     in varchar2,
   p_effective_date  in date     default null,
   p_language_code   in varchar2 default null
) return varchar2;
/* return people_group_id */
function get_people_group_id
(
   p_people_group_user_name in varchar2,
   p_effective_date    in date
) return number;
/* return absence_attendance_type_id */
function get_absence_attendance_type_id
(
   p_aat_user_name     in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
) return number;
/* return SOFT_CODING_KEYFLEX_ID */
function GET_SOFT_CODING_KEYFLEX_ID
(
   p_con_seg_user_name     in varchar2,
   p_effective_date    in date
) return number;
--pragma restrict_references (gl, WNDS);
/* return pk_id for ben_prtt_rt_val table*/
function get_pk_id
(
   p_pk_name           in varchar2
) return number

;


/*  Bug 3275173 --get object version number -----------*/
function  get_fed_tax_rule_ovn
(
   p_emp_fed_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;


--
-- Bug 3783381 -- get object versionn number for state, county and city
--

function  get_state_tax_rule_ovn
(
   p_emp_state_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;
--
function  get_county_tax_rule_ovn
(
   p_emp_county_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;
--
function  get_city_tax_rule_ovn
(
   p_emp_city_tax_rule_user_key in varchar2,
   p_effective_date            in date
) return number;

--
--
--


-- -------------------------------------------------------------------------
-- --------------------< get_cpn_ovn >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_cpn_ovn
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_cpn_ovn , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_competence_id >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_competence_id
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_competence_id , WNDS);
-- -------------------------------------------------------------------------
-- ------------< get_parent_comp_element_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_parent_comp_element_id
RETURN BINARY_INTEGER;
-- -------------------------------------------------------------------------
-- ----------------< get_qualification_type_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_qualification_type_id
  (p_data_pump_always_call      IN varchar2
  ,p_qualification_type_name    IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_qualification_type_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_cpo_ovn >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_cpo_ovn
  (p_data_pump_always_call      IN varchar2
  ,p_outcome_name               IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_cpo_ovn , WNDS);
-- -------------------------------------------------------------------------
-- -------------------------< get_outcome_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_outcome_id
  (p_data_pump_always_call IN varchar2
  ,p_outcome_name          IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_outcome_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_eqt_ovn >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_eqt_ovn
  (p_data_pump_always_call      IN varchar2
  ,p_qualification_type_name    IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_eqt_ovn , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_ceo_ovn >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_ceo_ovn
  (p_data_pump_always_call      IN varchar2
  ,p_element_outcome_name       IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_ceo_ovn , WNDS);
-- -------------------------------------------------------------------------
-- ------------------< get_competence_element_id >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_competence_element_id
  (p_data_pump_always_call    IN varchar2
  ,p_competence_name          IN VARCHAR2
  ,p_person_user_key          IN VARCHAR2
  ,p_business_group_id        IN NUMBER
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_competence_element_id , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_cost_flex_stru_num >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the cost flex structure num
--
FUNCTION get_cost_flex_stru_num
  (p_data_pump_always_call IN varchar2
  ,p_cost_flex_stru_code   IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_cost_flex_stru_num , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_grade_flex_stru_num >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the grade flex structure num
--
FUNCTION get_grade_flex_stru_num
  (p_data_pump_always_call IN varchar2
  ,p_grade_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_grade_flex_stru_num , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_job_flex_stru_num >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the job flex structure num
--
FUNCTION get_job_flex_stru_num
  (p_data_pump_always_call IN varchar2
  ,p_job_flex_stru_code    IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_job_flex_stru_num , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_position_flex_stru_num >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the position flex structure num
--
FUNCTION get_position_flex_stru_num
  (p_data_pump_always_call    IN varchar2
  ,p_position_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_position_flex_stru_num , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_group_flex_stru_num >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the people group flex structure num
--
FUNCTION get_group_flex_stru_num
  (p_data_pump_always_call IN varchar2
  ,p_group_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_group_flex_stru_num , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_competence_flex_stru_num >---------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the competence flex structure num
--
FUNCTION get_competence_flex_stru_num
  (p_data_pump_always_call      IN varchar2
  ,p_competence_flex_stru_code  IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_competence_flex_stru_num , WNDS);
--
-- -------------------------------------------------------------------------
-- -------------------------< get_sec_group_id >----------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the security group id
--
FUNCTION get_sec_group_id
  (p_data_pump_always_call IN varchar2
  ,p_security_group_name   IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_sec_group_id , WNDS);
--
-- -------------------------------------------------------------------------
-- ------------------< get_security_profile_id >---------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the security_profile_id
--
FUNCTION get_security_profile_id
  (p_data_pump_always_call IN VARCHAR2
  ,p_security_profile_name IN VARCHAR2
  ,p_business_group_id     IN NUMBER
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_security_profile_id , WNDS);
--
--
-- -------------------------------------------------------------------------
-- --------------------< get_parent_organization_id >-----------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the organization_id
--
function get_parent_organization_id
  ( p_parent_organization_name in varchar2,
    p_business_group_id in number,
    p_effective_date    in date,
    p_language_code     in varchar2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_parent_organization_id , WNDS);
--
-- -------------------------------------------------------------------------
-- ---------------------< get_child_organization_id >-----------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the organization_id.
--
function get_child_organization_id
  ( p_child_organization_name in varchar2,
    p_business_group_id in number,
    p_effective_date    in date,
    p_language_code     in varchar2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_child_organization_id , WNDS);
--
-- -------------------------------------------------------------------------
-- ---------------------< get_person_extra_info_id >------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the person_extra_info_id.
--
function get_person_extra_info_id
(
   p_person_extra_info_user_key in varchar2
) return number;
pragma restrict_references (get_person_extra_info_id, WNDS);
--
-- -------------------------------------------------------------------------
-- ---------------------< get_person_extra_info_ovn >-----------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the ovn for person_extra_info_id.
--
function get_person_extra_info_ovn
( p_person_extra_info_user_key    in varchar2
) return number;
pragma restrict_references (get_person_extra_info_ovn, WNDS);


--
------------------------- GET_EMP_FED_TAX_INF_ID -------------------------
/*
  NAME
    GET_EMP_FED_TAX_INF_ID
  DESCRIPTION
    Returns a Canada federal tax Inf ID.
  NOTES
    This function returns a Canada GET_EMP_FED_TAX_INF_ID and is designed for use
    with the Data Pump.
*/
function GET_EMP_FED_TAX_INF_ID
(
  P_EMP_FED_TAX_INF_USER_KEY in varchar2
) return number;
pragma restrict_references (GET_EMP_FED_TAX_INF_ID, WNDS);

----------------------- GET_CA_EMP_FEDTAX_INF_OVN --------------------------
/*
  NAME
    GET_CA_EMP_FEDTAX_INF_OVN
  DESCRIPTION
    Returns a tax rule Object Version Number.
  NOTES
    This returns an object version number for Canada Emp Fed tax Inf that has
    been created via the Data Pump engine.
*/
function GET_CA_EMP_FEDTAX_INF_OVN
(
   P_EMP_FED_TAX_INF_USER_KEY in varchar2,
   p_effective_date            in date
) return number;
pragma restrict_references (GET_CA_EMP_FEDTAX_INF_OVN, WNDS);


--
------------------------- GET_EMP_PROVINCE_TAX_INF_ID -------------------------
/*
  NAME
    GET_EMP_PROVINCE_TAX_INF_ID
  DESCRIPTION
    Returns a Canada Employee Province tax Inf ID.
  NOTES
    This function returns a Canada GET_EMP_PROVINCE_TAX_INF_ID and is designed
	for use with the Data Pump.
*/
function GET_EMP_PROVINCE_TAX_INF_ID
(
  P_EMP_PROV_TAX_INF_USER_KEY in varchar2
) return number;
pragma restrict_references (GET_EMP_PROVINCE_TAX_INF_ID, WNDS);


----------------------- GET_CA_EMP_PRVTAX_INF_OVN --------------------------
/*
  NAME
    GET_CA_EMP_PRVTAX_INF_OVN
  DESCRIPTION
    Returns a Canada Emp Province tax Inf Object Version Number.
  NOTES
    This returns an object version number for Canada Emp Province tax Inf that has
    been created via the Data Pump engine.
*/
function GET_CA_EMP_PRVTAX_INF_OVN
(
   P_EMP_PROV_TAX_INF_USER_KEY in varchar2,
   p_effective_date                in date
) return number;
pragma restrict_references (GET_CA_EMP_PRVTAX_INF_OVN, WNDS);

end hr_pump_get;

 

/
