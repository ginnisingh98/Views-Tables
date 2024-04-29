--------------------------------------------------------
--  DDL for Package PAY_KR_FF_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_FF_FUNCTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pykrfffc.pkh 120.10.12010000.20 2009/12/09 07:06:09 vaisriva ship $ */
--------------------------------------------------------------------------------
function get_legislative_parameter(
	p_payroll_action_id	in number,
	p_parameter_name	in varchar2,
	p_default_value		in varchar2 default 'NULL',
	p_flash_cache		in varchar2 default 'N') return varchar2;
--------------------------------------------------------------------------------
function set_message_name(
	p_application_short_name	in varchar2,
	p_message_name			in varchar2) return number;
--------------------------------------------------------------------------------
function set_message_token(
	p_token_name	in varchar2,
	p_token_value	in varchar2) return number;
--------------------------------------------------------------------------------
function get_message return varchar2;
--------------------------------------------------------------------------------
procedure ni_component(
	p_national_identifier	in         varchar2,
	p_sex			out NOCOPY varchar2,
	p_date_of_birth		out NOCOPY date);
--------------------------------------------------------------------------------
function ni_sex(p_national_identifier in varchar2) return varchar2;
--------------------------------------------------------------------------------
function ni_date_of_birth(p_national_identifier in varchar2) return date;
--------------------------------------------------------------------------------
-- Bug 3172960
function ni_nationality(p_national_identifier in varchar2) return varchar2;
--------------------------------------------------------------------------------
-- Bug 3172960
function ni_nationality(p_assignment_id 	in number,
			p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function eoy_age(
	p_date_of_birth		in date,
	p_effective_date	in date) return number;
--------------------------------------------------------------------------------
function dpnt_spouse_flag(p_contact_type in varchar2,
   		 	  p_kr_cont_type in varchar2) return varchar2;
--------------------------------------------------------------------------------
function aged_dpnt_flag(
	p_contact_type		in varchar2,
	p_kr_cont_type		in varchar2,  -- Bug 7661820
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function adult_dpnt_flag(
	p_contact_type		in varchar2,
	p_kr_cont_type		in varchar2,  -- Bug 7661820
	p_national_identifier	in varchar2,
	p_effective_date	in date,
	p_disabled_flag         in varchar2,
        p_age_exception_flag    in varchar2) return varchar2;
--------------------------------------------------------------------------------
function underaged_dpnt_flag(
	p_contact_type		in varchar2,
	p_kr_cont_type		in varchar2,  -- Bug 7661820
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function aged_flag(
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function super_aged_flag(
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function disabled_flag(
	p_person_id		in number,
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function child_flag(
	p_national_identifier	in varchar2,
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
-- National Pension Exception Reason (Formula Function)
-- Bug 2815425
--------------------------------------------------------------------------------
function get_np_exception_flag (
        p_date_earned         IN DATE
        ,p_business_group_id  IN NUMBER
        ,p_assignment_id      IN NUMBER ) return varchar2;
--------------------------------------------------------------------------------
/* Bug 6784288 */
function addtl_child_flag(
	p_contact_type		in varchar2,
	p_national_identifier	in varchar2,
	p_cont_information4 	in varchar2,	-- Bug 7615517
	p_cont_information11	in varchar2,	-- Bug 7615517
	p_cont_information15	in varchar2,	-- Bug 7661820
	p_effective_date	in date) return varchar2;
--------------------------------------------------------------------------------
function get_dependent_info(
	p_assignment_id 		in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number) return number;
--------------------------------------------------------------------------------
/* Bug 6705170 : Function get_dependent_info() has been overloaded
                 to fetch the New Born/Adopted Child count         */
--------------------------------------------------------------------------------
function get_dependent_info(
	p_assignment_id 		in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number,
	p_num_of_super_ageds		out NOCOPY number,
	p_num_of_new_born_adopted       out NOCOPY number,
	p_num_of_addtl_child            out NOCOPY number) return number;             /* Bug 6784288 */
--------------------------------------------------------------------------------
-- Bug 3172960
function get_dependent_info(
	p_assignment_id 		in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number,
	p_num_of_super_ageds		out NOCOPY number,
	p_num_of_addtl_child            out NOCOPY number) return number;    /* Bug 6784288 */
--------------------------------------------------------------------------------
-- Bug 3172960
function get_dependent_info(
	p_assignment_id 		in         number,
	p_date_earned			in         date,
	p_non_resident_flag		in         varchar2,
	p_dpnt_spouse_flag		out NOCOPY varchar2,
	p_num_of_aged_dpnts		out NOCOPY number,
	p_num_of_adult_dpnts		out NOCOPY number,
	p_num_of_underaged_dpnts	out NOCOPY number,
	p_num_of_dpnts			out NOCOPY number,
	p_num_of_ageds			out NOCOPY number,
	p_num_of_disableds		out NOCOPY number,
	p_female_ee_flag		out NOCOPY varchar2,
	p_num_of_children		out NOCOPY number,
	p_num_of_super_ageds		out NOCOPY number) return number;
--------------------------------------------------------------------------------
 -- Employment Insurance Exception Reasons in payroll deduction
 -- Bug 2833174
--------------------------------------------------------------------------------
function get_ei_loss_exception_codes(
       p_date_earned       	 in          date
      ,p_business_group_id 	 in          number
      ,p_assignment_id      	 in          number
      ,p_loss_ineligible_flag    out nocopy  varchar2
      ,p_exception_flag    	 out nocopy  varchar2
      ,p_exception_type   	 out nocopy  varchar2
      ,p_overlapped_ex_flag      out nocopy  varchar2
      ) return number;
--------------------------------------------------------------------------------
 -- Bug 4674552
 function is_exempted_dependent(
	p_cont_type		  in	per_contact_relationships.contact_type%type,
	p_kr_cont_typ		  in 	per_contact_relationships.cont_information11%type,  -- Bug 7661820
 	p_ni			  in	per_people_f.national_identifier%type,
	p_itax_dpnt_flag	  in	per_contact_relationships.cont_information2%type,
	p_addl_tax_exem_flag	  in	per_contact_relationships.cont_information3%type,
	p_addl_disabled_flag	  in	per_contact_relationships.cont_information4%type,
	p_addl_exem_flag_child	  in	per_contact_relationships.cont_information7%type,
	p_age_ckh_exp_flag	  in	per_contact_relationships.cont_information8%type,
	p_eff_date		  in	pay_payroll_actions.effective_date%type,
        p_ins_prem_exem_incl_flag in    per_contact_relationships.cont_information10%type, -- Bug 4931542
        p_med_exp_exem_incl_flag  in    per_contact_relationships.cont_information12%type, -- Bug 4931542
        p_edu_exp_exem_incl_flag  in    per_contact_relationships.cont_information13%type, -- Bug 4931542
        p_card_exp_exem_incl_flag in    per_contact_relationships.cont_information14%type,  -- Bug 4931542
        p_contact_extra_info_id   in    per_contact_extra_info_f.contact_extra_info_id%type -- Bug 5879106
 ) return varchar2 ;
--------------------------------------------------------------------------------
function dpnt_eligible_for_basic_exem(
	p_cont_type		in	per_contact_relationships.contact_type%type,
	p_kr_cont_typ		in 	per_contact_relationships.cont_information11%type,  -- Bug 7661820
	p_ni			in 	per_people_f.national_identifier%type,
	p_itax_dpnt_flag	in	per_contact_relationships.cont_information2%type,
	p_addl_disabled_flag	in	per_contact_relationships.cont_information4%type,
	p_age_ckh_exp_flag	in	per_contact_relationships.cont_information8%type,
	p_eff_date		in	pay_payroll_actions.effective_date%type
) return varchar2 ;
--------------------------------------------------------------------------------
function dpnt_addl_child_exempted(
        p_addl_child_exem     in varchar2,
        p_ni                  in varchar2,
        p_eff_date            in date
) return varchar2;
--------------------------------------------------------------------------------
-- procedure get_double_exem_amt
procedure get_double_exem_amt(p_assignment_id in per_assignments_f.assignment_id%type,
                          p_effective_year in varchar2,
			  p_double_exm_amt out nocopy number);
--
-----------------------------------------------------------------------------------
-- Bug 6849941: New Validation Checks for Credit Card Fields on the Income Tax Form
-----------------------------------------------------------------------------------
Function enable_credit_card(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         date) return varchar2;
--
-----------------------------------------------------------------------------------
-- Bug 7164589: Long Term Treatment Insurance Premium
-- Bug 7228788: Added a new input parameter to the function for the Input Value Name
-----------------------------------------------------------------------------------
FUNCTION get_long_term_ins_skip_flag(
	p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
       ,p_input_value_name	in	varchar2
) RETURN VARCHAR2;
--
----------------------------------------------------------------------------------------------------
-- Bug 7361372: FUNCTION chk_id_format() checks if the argument1 is in the same format as argument2.
--              If not then an error is raised. Else the same string as argument1 is returned.
----------------------------------------------------------------------------------------------------
FUNCTION chk_id_format(
	p_chk_string		IN VARCHAR2,
	p_format_string		IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------------------
-- Bug 7142612: Validation Checks for Donation Fields on the Income Tax Form
-----------------------------------------------------------------------------------
Function enable_donation_fields(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         date) return varchar2;
--
-----------------------------------------------------------------------------------
-- Bug 7526435 FUNCTION validate_bus_reg_num() checks the validation logic for provider reg.
--             no. of medical service provider and returns false if reg.no validation fails
------------------------------------------------------------------------------------------------
FUNCTION validate_bus_reg_num(
	p_national_identifier IN VARCHAR2) RETURN VARCHAR2;
--
------------------------------------------------------------------------------------------------
-- Bug 7676136: Function to get the Value of the Globals
------------------------------------------------------------------------------------------------
function get_globalvalue(
	p_glbvar in varchar2,
	p_process_date in date) return number;
--
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--  Bug 8341054: Gets the Flag for Input Value of an Element
------------------------------------------------------------------------------------------------
FUNCTION get_element_input_value(
	p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
       ,p_input_value_name	in	varchar2
       ,p_element_name          in      varchar2
) RETURN VARCHAR2;
--
------------------------------------------------------------------------------------------------
--  Bug 8341054: Gets the Flag for Input Value of an Element
------------------------------------------------------------------------------------------------
FUNCTION get_element_input_value_y(
	p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
       ,p_input_value_name	in	varchar2
       ,p_element_name          in      varchar2
) RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
--  Bug 8466662: Gets the Run Result Value for an Input Value of Type Money
------------------------------------------------------------------------------------------------
FUNCTION get_element_rr_value(
	p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
       ,p_input_value_name	in	varchar2
       ,p_element_name          in      varchar2
) RETURN number;
--
------------------------------------------------------------------------------------------------
--  Bug 8466662: Gets the Run Result Value for an Input Value of Type Date
------------------------------------------------------------------------------------------------
FUNCTION get_element_rr_date_value(
	p_assignment_action_id 	in 	pay_assignment_actions.assignment_action_id%type
       ,p_input_value_name	in	varchar2
       ,p_element_name          in      varchar2
) RETURN date;
--
------------------------------------------------------------------------------------------------
--  Bug 8466662: This function will be called from the TAX formula to fetch the individual
--               Calculated Taxes. Based on the value for the input p_class it will return
--       	 the calculated tax values
-- 		 (p_class = 1 => individual calculated tax for each working place irrespective
-- 		 of their eligiblity for the Post tax deduction.
--		 p_class = 2 => individual calculated tax values for all the eligible working
--		 places.
-----------------------------------------------------------------------------------------------
function SepPayPostTax( p_assignment_id 	  in   number,
                        p_business_group_id       in   number,
                        p_date_earned	 	  in   date,
			p_assignment_action_id    in   number,
                        p_total_taxable_earnings  in   number,  -- TOTAL_TAXABLE_EARNINGS_ASG_RUN
                        p_nst_taxable_earnings    in   number,  -- SP_SEP_ALW_ASG_RUN
                        p_wkpd_int_sep_pay        in   number,
                        p_sep_pay_income_exem_rate in  number,
                        p_class                   in   number,
                        p_sep_cal_mode            in  varchar2,
                        p_sep_lump_sum_amount	  in   number,
                        p_emp_eligibility_flag    in   varchar2,
                        p_st_emp_hire_date	  in   date,
                        p_st_emp_leaving_date	  in   date,
                        p_nst_emp_hire_date	  in   date,
                        p_nst_emp_leaving_date	  in   date,
			p_sep_max_post_tax_deduc  in   number,
                        p_amount_expected         in   number,
			p_personal_contribution   in   number,
			p_pension_exemption       in   number,
			p_principal_interest      in   number,
			p_nst_amount_expected     in   number,
			p_prev_sep_lump_sum_amt   in   number,
                        p_nst_sep_calc_tax        out NOCOPY number,
                        p_sep_calc_tax            out NOCOPY number,
			p_st_max_lim		  out NOCOPY number,
			p_nst_max_lim		  out NOCOPY number
                        ) return number;
-----------------------------------------------------------------------------------------------
-- Bug 8466662: This function simulates the Statutory Separation Pay Process and returns the
--    		Statutory Calculated Tax value.
------------------------------------------------------------------------------------------------
function SepPayTaxCalc(
                       p_service_period           in number,
		       p_overlap_period	  	  in number,
                       p_taxable_earnings 	  in number,
                       p_sep_taxable_earnings 	  in number,
                       p_receivable_sep_pay 	  in number,
                       p_sep_tax_conversion_reqd  in varchar2,
                       p_business_group_id        in number,
                       p_effective_date           in date,
                       p_sep_pay_income_exem_rate in number) return number;
-----------------------------------------------------------------------------------------------
-- Bug 8466662: This procedure simulates the Non-Statutory Separation Pay Process and returns the
--    		Statutory and Non-Statutory Calculated Tax values.
------------------------------------------------------------------------------------------------
Procedure NonStatTaxCalc(
                        p_service_period          in   number,
                        p_nst_service_period      in   number,
                        p_st_overlap_period	  in   number,
                        p_nst_overlap_period	  in   number,
                        p_sep_taxable_earnings    in   number,
                        p_taxable_earnings        in   number,
                        p_nst_taxable_earnings    in   number,
                        p_wkpd_int_sep_pay        in   number,
                        p_sep_tax_conversion_reqd in   varchar2,
                        p_receivable_sep_pay      in   number,
                        p_effective_date          in   date,
                        p_business_group_id       in   number,
                        p_sep_pay_income_exem_rate in  number,
                        l_nst_sep_calc_tax        out NOCOPY number,
                        l_sep_calc_tax            out NOCOPY number,
			p_nst_receivable_sep_pay   in   number,
			p_nst_sep_taxable_earnings in   number);
------------------------------------------------------------------------------------------------
-- Bug 8644512:This function returns the correct lookup code as per NTS guidelines depending
--  on the year
------------------------------------------------------------------------------------------------
function get_cont_lookup_code (p_lookup_code  in varchar2,
				p_target_year in number) return varchar2;
------------------------------------------------------------------------------------------------
-- Bug 9079450: Function to return the lookup meaning for the dependent education expense region
------------------------------------------------------------------------------------------------
function decode_lookup(
			p_effective_date	in	varchar2,
			p_code			in	varchar2) return varchar2;
------------------------------------------------------------------------------------------------
end pay_kr_ff_functions_pkg;

/
