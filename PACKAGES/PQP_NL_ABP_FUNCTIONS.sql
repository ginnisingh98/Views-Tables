--------------------------------------------------------
--  DDL for Package PQP_NL_ABP_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_ABP_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pqpnlabp.pkh 120.6 2007/07/03 10:04:17 rsahai noship $ */

  g_proc_name                varchar2(80) := 'pqp_nl_abp_functions.';

-- ----------------------------------------------------------------------------
-- |---------------------< Get_Valid_Start_Date >------------------------------|
-- ----------------------------------------------------------------------------
--
Function GET_VALID_START_DATE(
       p_assignment_id IN NUMBER,
       p_eff_date IN DATE,
       p_error_status OUT NOCOPY CHAR,
       p_error_message OUT NOCOPY VARCHAR2
      )
Return DATE;

-- ----------------------------------------------------------------------------
-- |-------------------------< abp_proration >-------------------------------|
-- ----------------------------------------------------------------------------
--
function abp_proration
  (p_business_group_id      in  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned            in  date
  ,p_assignment_id          in  per_all_assignments_f.assignment_id%TYPE
  ,p_amount                 in  number
  ,p_payroll_period         in  varchar2
  ,p_work_pattern           in  varchar2
  ,p_conversion_rule        in  varchar2
  ,p_prorated_amount        out nocopy number
  ,p_error_message          out nocopy varchar2
  ,p_payroll_period_prorate in varchar2
  ,p_override_pension_days  in NUMBER DEFAULT -9999
  ) return NUMBER;

-- ----------------------------------------------------------------------------
-- |-----------------------< cre_ret_ent_ad >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE cre_ret_ent_ad
           ( p_assignment_extra_info_id_o   IN NUMBER
            ,p_assignment_id_o              IN NUMBER
            ,p_information_type_o           IN VARCHAR2
            ,p_aei_information1_o           IN VARCHAR2
            ,p_aei_information2_o           IN VARCHAR2);
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_pt_row_ins >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_pt_row_ins (  p_org_information_id      IN number
                               ,p_org_information_context IN varchar2
                               ,p_organization_id         IN number
                               ,p_org_information1        IN varchar2
                               ,p_org_information2        IN varchar2
                               ,p_org_information3        IN varchar2
                               ,p_org_information4        IN varchar2 default null
                               ,p_org_information5        IN varchar2 default null
                               ,p_org_information6        IN varchar2 default null
                             );

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_pt_row_upd >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_pt_row_upd (  p_org_information_id      number
                               ,p_org_information_context varchar2
                               ,p_organization_id         number
                               ,p_org_information1        varchar2
                               ,p_org_information2        varchar2
                               ,p_org_information3        varchar2
                               ,p_org_information4        varchar2 default null
                               ,p_org_information5        varchar2 default null
                               ,p_org_information6        varchar2 default null
                               ,p_org_information1_o      varchar2
                               ,p_org_information2_o      varchar2
                               ,p_org_information3_o      varchar2
                               ,p_org_information4_o      varchar2 default null
                               ,p_org_information5_o      varchar2 default null
                               ,p_org_information6_o      varchar2 default null
                             );

PROCEDURE chk_dup_pt_row (  p_org_information_id      number
                               ,p_org_information_context varchar2
                               ,p_organization_id         number
                               ,p_org_information1        varchar2
                               ,p_org_information2        varchar2
                               ,p_org_information3        varchar2
                             );

PROCEDURE gen_dynamic_formula ( p_si_tax_balances  IN  NUMBER
                               ,p_formula_string   OUT NOCOPY varchar2
                             );

-- ----------------------------------------------------------------------------
-- |-------------------< chk_dup_asg_info_row_ins>-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_asg_info_row_ins (p_assignment_extra_info_id IN number
                                   ,p_assignment_id            IN number
                                   ,p_information_type         IN varchar2
                                   ,p_aei_information1         IN varchar2
                                   ,p_aei_information2         IN varchar2
                                   ,p_aei_information3         IN varchar2
                                   ,p_aei_information4         IN varchar2
                                   ,p_aei_information5         IN varchar2
                                   ,p_aei_information6         IN varchar2
                                   ,p_aei_information7         IN varchar2
                                   ,p_aei_information8         IN varchar2
                                   ,p_aei_information9         IN varchar2
                                   ,p_aei_information10        IN varchar2
                                   ,p_aei_information11        IN varchar2
                                   ,p_aei_information12        IN varchar2
                                   ,p_aei_information13        IN varchar2
                                   ,p_aei_information14        IN varchar2
                                   ,p_aei_information15        IN varchar2
                                   ,p_aei_information16        IN varchar2
                                   ,p_aei_information20        IN varchar2
                                   ,p_aei_information21        IN varchar2
                                   ,p_aei_information22        IN varchar2
                                   );

-- ----------------------------------------------------------------------------
-- |-------------------< chk_dup_asg_info_row_upd>-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_asg_info_row_upd (p_assignment_extra_info_id IN number
                                   ,p_assignment_id            IN number
                                   ,p_information_type         IN varchar2
                                   ,p_aei_information1         IN varchar2
                                   ,p_aei_information2         IN varchar2
                                   ,p_aei_information3         IN varchar2
                                   ,p_aei_information4         IN varchar2
                                   ,p_aei_information5         IN varchar2
                                   ,p_aei_information6         IN varchar2
                                   ,p_aei_information7         IN varchar2
                                   ,p_aei_information8         IN varchar2
                                   ,p_aei_information9         IN varchar2
                                   ,p_aei_information10        IN varchar2
                                   ,p_aei_information11        IN varchar2
                                   ,p_aei_information12        IN varchar2
                                   ,p_aei_information13        IN varchar2
                                   ,p_aei_information14        IN varchar2
                                   ,p_aei_information15        IN varchar2
                                   ,p_aei_information16        IN varchar2
                                   ,p_aei_information20        IN varchar2
                                   ,p_aei_information21        IN varchar2
                                   ,p_aei_information22        IN varchar2
                                   ,p_aei_information1_o       IN varchar2
                                   ,p_aei_information2_o       IN varchar2
                                   ,p_aei_information3_o       IN varchar2
                                   ,p_aei_information4_o       IN varchar2
                                   ,p_aei_information5_o        IN varchar2
                                   ,p_aei_information6_o        IN varchar2
                                   ,p_aei_information7_o       IN  varchar2
                                   );

--
-- ------------------------------------------------------------------------
-- |------------------< get_abp_contribution >----------------------------|
-- ------------------------------------------------------------------------
--

FUNCTION  get_abp_contribution
           (p_assignment_id      in  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        in  date
           ,p_business_group_id  in  pqp_pension_types_f.business_group_id%TYPE
           ,p_payroll_action_id  IN  NUMBER
           ,p_pension_sub_cat    in  pqp_pension_types_f.pension_sub_category%TYPE
           ,p_conversion_rule    in  pqp_pension_types_f.threshold_conversion_rule%TYPE
           ,p_basis_method       in  pqp_pension_types_f.pension_basis_calc_method%TYPE
           ,p_ee_contrib_type    out NOCOPY  number
           ,p_ee_contrib_value   out NOCOPY  number
           ,p_er_contrib_type    out NOCOPY  number
           ,p_er_contrib_value   out NOCOPY  number
          )
RETURN number;

--
-- ------------------------------------------------------------------------
-- |------------------< get_participation_date >----------------------------|
-- ------------------------------------------------------------------------
--

FUNCTION  get_participation_date
           (p_assignment_id      in  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        in  date
           ,p_business_group_id  in  pqp_pension_types_f.business_group_id%TYPE
           ,p_pension_type_id    in  pqp_pension_types_f.pension_type_id%TYPE
           ,p_start_date         out NOCOPY date
          )
RETURN number;

--
-- ------------------------------------------------------------------------
-- |------------------< get_assignment_attribute >-------------------------|
-- ------------------------------------------------------------------------
--

FUNCTION  get_assignment_attribute
          (p_assignment_id     in  per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned       in  date
          ,p_business_group_id in  pqp_pension_types_f.business_group_id%TYPE
          ,p_pension_type_id   in  pqp_pension_types_f.pension_type_id%TYPE
          ,p_attrib_name       in  varchar2
          ,p_attrib_value      out NOCOPY varchar2
          ,p_error_message     out NOCOPY varchar2
         )
RETURN number;


--
-- ------------------------------------------------------------------------
-- |------------------< get_participation_org >----------------------------|
-- ------------------------------------------------------------------------
--

PROCEDURE  get_participation_org
           (p_assignment_id      in  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        in  date
           ,p_pension_type_id    in  pqp_pension_types_f.pension_type_id%TYPE
           ,p_asg_or_org         out NOCOPY number
           ,p_org_id             out NOCOPY number
          );

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_pp_row_ins >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_pp_row_ins (  p_org_information_id      IN number
                               ,p_org_information_context IN varchar2
                               ,p_organization_id         IN number
                               ,p_org_information1        IN varchar2
                               ,p_org_information2        IN varchar2
                               ,p_org_information3        IN varchar2
                             );

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_pp_row_upd >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_pp_row_upd (  p_org_information_id      IN number
                               ,p_org_information_context IN varchar2
                               ,p_organization_id         IN number
                               ,p_org_information1        IN varchar2
                               ,p_org_information2        IN varchar2
                               ,p_org_information3        IN varchar2
                               ,p_org_information1_o      IN varchar2
                               ,p_org_information2_o      IN varchar2
                               ,p_org_information3_o      IN varchar2
                             );

--
-- ------------------------------------------------------------------------
-- |------------------< get_absence_adjustment >-------------------------|
-- ------------------------------------------------------------------------
--

FUNCTION  get_absence_adjustment
          (p_assignment_id     in  per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned       in  date
          ,p_business_group_id in  pqp_pension_types_f.business_group_id%TYPE
          ,p_dedn_amt          in  number
          ,p_adjust_amt        out NOCOPY number
          ,p_error_message     out NOCOPY varchar2
         )
RETURN number;

--
-- ------------------------------------------------------------------------
-- |--------------------< get_proration_factor >---------------------------|
-- ------------------------------------------------------------------------
--

FUNCTION  get_proration_factor
          (p_assignment_id     in  per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned       in  date
          ,p_business_group_id in  pqp_pension_types_f.business_group_id%TYPE
          ,p_proration_factor  out NOCOPY number
          ,p_error_message     out NOCOPY varchar2
         )
RETURN number;
--
-- ------------------------------------------------------------------------
-- |--------------------< get_abp_calc_eff_dt >----------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_abp_calc_eff_dt
        (p_date_earned           IN  DATE
        ,p_business_group_id     IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date        OUT NOCOPY DATE
        )
RETURN NUMBER;
--
-- ------------------------------------------------------------------------
-- |--------------------< get_proration_flag >----------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_proration_flag
        (p_date_earned           IN  DATE
        ,p_business_group_id     IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_assignment_action_id  IN  per_all_assignments_f.assignment_id%TYPE
        ,p_element_type_id       IN  pay_element_types_f.element_type_id%TYPE
        ,p_start_date            IN  DATE
        ,p_end_date              IN  DATE
        )
RETURN VARCHAR2;
--
-- ------------------------------------------------------------------------
-- |------------------< get_eoy_bonus_percentage >-------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_eoy_bonus_percentage
        (p_date_earned           IN  DATE
        ,p_business_group_id     IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_eoy_bonus_percentage  OUT NOCOPY NUMBER
        )
RETURN NUMBER;

-------------------------------------------------------------------------------
---------------------------------< upd_chg_evt >-------------------------------
-- ----------------------------------------------------------------------------
-- This procedure updates the change event log registered with a
-- parameter that contains the ABP Reporting date. The date
-- is derived based on the approval of an ABP Pensions Notification.
-- All reporting to ABP for e.g. Rec 05 and other relevant records
-- are done based on this date. This is also to address certification
-- issues that have arised due to retrospective changes to various
-- changes.
--
PROCEDURE upd_chg_evt
   (p_ext_chg_evt_log_id    IN NUMBER
   ,p_chg_evt_cd            IN VARCHAR2
   ,p_chg_eff_dt            IN DATE
   ,p_chg_user_id           IN NUMBER
   ,p_prmtr_01              IN VARCHAR2
   ,p_prmtr_02              IN VARCHAR2
   ,p_prmtr_03              IN VARCHAR2
   ,p_prmtr_04              IN VARCHAR2
   ,p_prmtr_05              IN VARCHAR2
   ,p_prmtr_06              IN VARCHAR2
   ,p_prmtr_07              IN VARCHAR2
   ,p_prmtr_08              IN VARCHAR2
   ,p_prmtr_09              IN VARCHAR2
   ,p_prmtr_10              IN VARCHAR2
   ,p_person_id             IN NUMBER
   ,p_business_group_id     IN NUMBER
   ,p_object_version_number IN NUMBER
   ,p_effective_date        IN DATE
   ,p_chg_actl_dt           IN DATE
   ,p_new_val1              IN VARCHAR2
   ,p_new_val2              IN VARCHAR2
   ,p_new_val3              IN VARCHAR2
   ,p_new_val4              IN VARCHAR2
   ,p_new_val5              IN VARCHAR2
   ,p_new_val6              IN VARCHAR2
   ,p_old_val1              IN VARCHAR2
   ,p_old_val2              IN VARCHAR2
   ,p_old_val3              IN VARCHAR2
   ,p_old_val4              IN VARCHAR2
   ,p_old_val5              IN VARCHAR2
   ,p_old_val6              IN VARCHAR2 ) ;

--
-------------------------------------------------------------------------------
-------------------------< get_abp_late_hire_indicator >-----------------------
-------------------------------------------------------------------------------
--
FUNCTION  get_abp_late_hire_indicator
          (p_payroll_action_id IN NUMBER)

RETURN NUMBER;
--
-------------------------------------------------------------------------------
-------------------------< Get_Retro_Addnal_Amt >------------------------------
-------------------------------------------------------------------------------
--
FUNCTION Get_Retro_Addnl_Amt
       (p_bg_id IN number,
        p_date_earned IN date,
        p_asg_id IN number,
        p_element_type_id IN Number,
        p_payroll_id IN number,
        p_contri_perc IN number,
        p_sick_flag IN varchar2,
        p_dedn_retro_amt out nocopy number,
        p_ee_er_flag in varchar2
       ) Return number;
--

END pqp_nl_abp_functions;

/
