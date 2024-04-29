--------------------------------------------------------
--  DDL for Package Body PAY_GB_EOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EOY_ARCHIVE" AS
/* $Header: pygbeoya.pkb 120.22.12010000.4 2009/07/01 09:13:29 pbalu ship $ */
--
------------------------------- GLOBALS -------------------------------------
--
g_package    CONSTANT VARCHAR2(20):= 'pay_gb_eoy_archive.';
--  Globals populated by archinit procedure or action_creation proc
g_payroll_action_id         pay_payroll_actions.payroll_action_id%TYPE;
g_start_year                DATE;
g_end_year                  DATE;
g_business_group_id         hr_organization_units.business_group_id%TYPE;
g_permit_number             VARCHAR2(12);
g_tax_district_reference    VARCHAR2(3);
g_asg_set_id              hr_assignment_sets.assignment_set_id%type;
g_context_id                number;
g_tax_reference_number      VARCHAR2(10); --4011263: length 10 chars
g_nia_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nia_id                    pay_defined_balances.defined_balance_id%TYPE;
g_nia_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nia_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nia_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nia_uap_id                pay_defined_balances.defined_balance_id%TYPE; -- 8357870
g_nia_auel_id               pay_defined_balances.defined_balance_id%TYPE; --EOY 07/08
g_nia_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_nib_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nib_id                    pay_defined_balances.defined_balance_id%TYPE;
g_nib_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nib_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nib_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nib_uap_id                pay_defined_balances.defined_balance_id%TYPE; -- 8357870
g_nib_auel_id               pay_defined_balances.defined_balance_id%TYPE; --EOY 07/08
g_nib_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_nic_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nic_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nic_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nic_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nic_uap_id                pay_defined_balances.defined_balance_id%TYPE; -- 8357870
g_nic_auel_id               pay_defined_balances.defined_balance_id%TYPE;  --EOY 07/08
g_nic_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_nic_ers_rebate_id         pay_defined_balances.defined_balance_id%TYPE;
g_nid_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nid_id                    pay_defined_balances.defined_balance_id%TYPE;
g_nid_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nid_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nid_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nid_uap_id                pay_defined_balances.defined_balance_id%TYPE;  -- 8357870
g_nid_auel_id               pay_defined_balances.defined_balance_id%TYPE;  --EOY 07/08
g_nid_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_nid_ers_rebate_id         pay_defined_balances.defined_balance_id%TYPE;
g_nid_ees_rebate_id         pay_defined_balances.defined_balance_id%TYPE;
g_nid_rebate_emp_id         pay_defined_balances.defined_balance_id%TYPE;
g_nie_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nie_id                    pay_defined_balances.defined_balance_id%TYPE;
g_nie_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nie_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nie_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nie_uap_id                pay_defined_balances.defined_balance_id%TYPE; -- 8357870
g_nie_auel_id               pay_defined_balances.defined_balance_id%TYPE; --EOY 07/08
g_nie_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_nie_ers_rebate_id         pay_defined_balances.defined_balance_id%TYPE;
g_nif_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nif_ees_rebate_id         pay_defined_balances.defined_balance_id%TYPE;
g_nig_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nis_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nij_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nij_id                    pay_defined_balances.defined_balance_id%TYPE;
g_nij_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nij_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nij_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nij_uap_id                pay_defined_balances.defined_balance_id%TYPE; -- 8357870
g_nij_auel_id               pay_defined_balances.defined_balance_id%TYPE; --EOY 07/08
g_nij_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_nil_able_id               pay_defined_balances.defined_balance_id%TYPE;
g_nil_id                    pay_defined_balances.defined_balance_id%TYPE;
g_nil_tot_id                pay_defined_balances.defined_balance_id%TYPE;
g_nil_lel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nil_uel_id                pay_defined_balances.defined_balance_id%TYPE;
g_nil_uap_id                pay_defined_balances.defined_balance_id%TYPE; -- 8357870
g_nil_auel_id               pay_defined_balances.defined_balance_id%TYPE;  --EOY 07/08
g_nil_et_id                 pay_defined_balances.defined_balance_id%TYPE;
g_ssp_id                    pay_defined_balances.defined_balance_id%TYPE;
g_smp_id                    pay_defined_balances.defined_balance_id%TYPE;
g_sap_id                    pay_defined_balances.defined_balance_id%TYPE;
g_spp_adopt_id              pay_defined_balances.defined_balance_id%TYPE;
g_spp_birth_id              pay_defined_balances.defined_balance_id%TYPE;
g_gross_id                  pay_defined_balances.defined_balance_id%TYPE;
g_notional_id               pay_defined_balances.defined_balance_id%TYPE;
g_paye_id                   pay_defined_balances.defined_balance_id%TYPE;
g_super_id                  pay_defined_balances.defined_balance_id%TYPE;
g_widow_id                  pay_defined_balances.defined_balance_id%TYPE;
g_student_loan_id           pay_defined_balances.defined_balance_id%TYPE;
g_taxable_id                pay_defined_balances.defined_balance_id%TYPE;
g_ni_arrears_id             pay_defined_balances.defined_balance_id%TYPE;
g_paye_details_id           pay_element_types_f.element_type_id%TYPE;
g_paye_element_id           pay_element_types_f.element_type_id%TYPE;
g_ni_id                     pay_element_types_f.element_type_id%TYPE;
g_category_input_id         pay_input_values_f.input_value_id%TYPE;
g_scon_input_id             pay_input_values_f.input_value_id%TYPE;
g_process_type_id           pay_input_values_f.input_value_id%TYPE;
--
g_address_line1_eid             ff_user_entities.user_entity_id%TYPE;
g_address_line2_eid             ff_user_entities.user_entity_id%TYPE;
g_address_line3_eid             ff_user_entities.user_entity_id%TYPE;
g_country_eid                   ff_user_entities.user_entity_id%TYPE; -- 4011263
g_assignment_number_eid         ff_user_entities.user_entity_id%TYPE;
g_county_eid                    ff_user_entities.user_entity_id%TYPE;
g_date_of_birth_eid             ff_user_entities.user_entity_id%TYPE;
g_director_indicator_eid        ff_user_entities.user_entity_id%TYPE;
g_effective_end_date_eid        ff_user_entities.user_entity_id%TYPE;
g_effective_start_date_eid      ff_user_entities.user_entity_id%TYPE;
g_eoy_primary_flag_eid          ff_user_entities.user_entity_id%TYPE;
g_expense_check_to_address_eid  ff_user_entities.user_entity_id%TYPE;
g_first_name_eid                ff_user_entities.user_entity_id%TYPE;
g_gross_pay_eid                 ff_user_entities.user_entity_id%TYPE;
g_notional_pay_eid              ff_user_entities.user_entity_id%TYPE;
g_last_asg_action_id_eid        ff_user_entities.user_entity_id%TYPE;
g_last_effective_date_eid       ff_user_entities.user_entity_id%TYPE;
g_last_multi_asg_eid            ff_user_entities.user_entity_id%TYPE;
g_aggregated_paye_flag_eid      ff_user_entities.user_entity_id%TYPE;
g_last_name_eid                 ff_user_entities.user_entity_id%TYPE;
g_location_id_eid               ff_user_entities.user_entity_id%TYPE;
g_max_period_number_eid         ff_user_entities.user_entity_id%TYPE;
g_middle_name_eid               ff_user_entities.user_entity_id%TYPE;
g_multiple_asg_flag_eid         ff_user_entities.user_entity_id%TYPE;
g_ni_number_eid                 ff_user_entities.user_entity_id%TYPE;
g_ni_able_et_eid                ff_user_entities.user_entity_id%TYPE;
g_ni_able_lel_eid               ff_user_entities.user_entity_id%TYPE;
g_ni_able_uel_eid               ff_user_entities.user_entity_id%TYPE;
g_ni_able_uap_eid               ff_user_entities.user_entity_id%TYPE; -- 8357870
g_ni_able_auel_eid              ff_user_entities.user_entity_id%TYPE;  --EOY 07/08
g_ni_earnings_eid               ff_user_entities.user_entity_id%TYPE;
g_ni_ees_contribution_eid       ff_user_entities.user_entity_id%TYPE;
g_ni_ers_rebate_eid             ff_user_entities.user_entity_id%TYPE;
g_ni_ees_rebate_eid             ff_user_entities.user_entity_id%TYPE;
g_ni_scon_ees_rebate_eid        ff_user_entities.user_entity_id%TYPE;
g_ni_scon_able_et_eid           ff_user_entities.user_entity_id%TYPE;
g_ni_scon_able_lel_eid          ff_user_entities.user_entity_id%TYPE;
g_ni_scon_able_uel_eid          ff_user_entities.user_entity_id%TYPE;
g_ni_scon_able_uap_eid          ff_user_entities.user_entity_id%TYPE; -- 8357870
g_ni_scon_able_auel_eid         ff_user_entities.user_entity_id%TYPE; --EOY 07/08
g_ni_scon_earnings_eid          ff_user_entities.user_entity_id%TYPE;
g_ni_scon_ees_contribution_eid  ff_user_entities.user_entity_id%TYPE;
g_ni_scon_ers_rebate_eid        ff_user_entities.user_entity_id%TYPE;
g_ni_scon_tot_contribution_eid  ff_user_entities.user_entity_id%TYPE;
g_ni_tot_contribution_eid       ff_user_entities.user_entity_id%TYPE;
g_ni_refund_eid                 ff_user_entities.user_entity_id%TYPE;
g_ni_scon_refund_eid            ff_user_entities.user_entity_id%TYPE;
g_organization_id_eid           ff_user_entities.user_entity_id%TYPE;
g_payroll_end_year_eid          ff_user_entities.user_entity_id%TYPE;
g_payroll_id_eid                ff_user_entities.user_entity_id%TYPE;
g_payroll_period_type_eid       ff_user_entities.user_entity_id%TYPE;
g_payroll_start_year_eid        ff_user_entities.user_entity_id%TYPE;
g_pensioner_indicator_eid       ff_user_entities.user_entity_id%TYPE;
g_people_group_id_eid           ff_user_entities.user_entity_id%TYPE;
g_permit_number_eid             ff_user_entities.user_entity_id%TYPE;
g_person_id_eid                 ff_user_entities.user_entity_id%TYPE;
g_postal_code_eid               ff_user_entities.user_entity_id%TYPE;
g_prev_tax_paid_eid             ff_user_entities.user_entity_id%TYPE;
g_prev_taxable_pay_eid          ff_user_entities.user_entity_id%TYPE;
g_sex_eid                       ff_user_entities.user_entity_id%TYPE;
g_smp_eid                       ff_user_entities.user_entity_id%TYPE;
g_ssp_eid                       ff_user_entities.user_entity_id%TYPE;
g_sap_eid                       ff_user_entities.user_entity_id%TYPE;
g_spp_adopt_eid                 ff_user_entities.user_entity_id%TYPE;
g_spp_birth_eid                 ff_user_entities.user_entity_id%TYPE;
g_start_of_emp_eid              ff_user_entities.user_entity_id%TYPE;
g_superannuation_paid_eid       ff_user_entities.user_entity_id%TYPE;
g_superannuation_refund_eid     ff_user_entities.user_entity_id%TYPE;
g_tax_dist_ref_eid              ff_user_entities.user_entity_id%TYPE;
g_tax_code_eid                  ff_user_entities.user_entity_id%TYPE;
g_tax_paid_eid                  ff_user_entities.user_entity_id%TYPE;
g_tax_ref_eid                   ff_user_entities.user_entity_id%TYPE;
g_tax_ref_transfer_eid          ff_user_entities.user_entity_id%TYPE;
g_tax_refund_eid                ff_user_entities.user_entity_id%TYPE;
g_tax_run_result_id_eid         ff_user_entities.user_entity_id%TYPE;
g_taxable_pay_eid               ff_user_entities.user_entity_id%TYPE;
g_termination_date_eid          ff_user_entities.user_entity_id%TYPE;
g_termination_type_eid          ff_user_entities.user_entity_id%TYPE;
g_title_eid                     ff_user_entities.user_entity_id%TYPE;
g_town_or_city_eid              ff_user_entities.user_entity_id%TYPE;
g_w1_m1_indicator_eid           ff_user_entities.user_entity_id%TYPE;
g_week_53_indicator_eid         ff_user_entities.user_entity_id%TYPE;
g_widows_and_orphans_eid        ff_user_entities.user_entity_id%TYPE;
g_student_loans_eid             ff_user_entities.user_entity_id%TYPE;
g_assignment_message_eid        ff_user_entities.user_entity_id%TYPE;
g_ni_arrears_eid                ff_user_entities.user_entity_id%TYPE;
g_reportable_ni_eid             ff_user_entities.user_entity_id%TYPE;
g_agg_active_start_eid          ff_user_entities.user_entity_id%TYPE;
g_agg_active_end_eid            ff_user_entities.user_entity_id%TYPE;
--
-- start/end year cache globals initialised in cache_archive_value:
g_min_start_year                DATE;
g_max_end_year                  DATE;
g_output_header                 BOOLEAN := TRUE;
g_err_count                     NUMBER;
g_warn_count                    NUMBER;
g_paye_archive                  BOOLEAN := TRUE; -- Bug 6761725
--
-- Globals populated by archive_code.archive_agg_values for
-- Aggregated PAYE
TYPE g_agg_values_rec IS RECORD
   (smp           NUMBER(15)   := 0,
    ssp           NUMBER(15)   := 0,
    sap           NUMBER(15)   := 0,
    spp_adopt     NUMBER(15)   := 0,
    spp_birth     NUMBER(15)   := 0,
    gross_pay     NUMBER(15)   := 0,
    notional      NUMBER(15)   := 0,
    paye          NUMBER(15)   := 0,
    superann      NUMBER(15)   := 0,
    widows        NUMBER(15)   := 0,
    taxable       NUMBER(15)   := 0,
    student_ln    NUMBER(15)   := 0,
    ni_arrears    NUMBER(15)   := 0,
    paye_eff_date DATE         := hr_general.start_of_time,
    tax_code      VARCHAR2(10) := NULL,
    tax_basis     VARCHAR(1)   := NULL,
    pay_previous  NUMBER(15)   := 0,
    tax_previous  NUMBER(15)   := 0,
    week_53       VARCHAR2(1)  := NULL);
--
--  Globals populated by archive_code.archive_ni_values procedure for
--     Multiple Assignment Logic
-- table types:
TYPE g_ni_values_rec IS RECORD
  (ni_cat        VARCHAR2(1),
   tot_contribs  NUMBER(15) := 0,
   earnings      NUMBER(15) := 0,
   ees_contribs  NUMBER(15) := 0,
   ni_able_lel   NUMBER(15) := 0,
   ni_able_et    NUMBER(15) := 0,
   ni_able_uel   NUMBER(15) := 0,
   ni_able_uap   NUMBER(15) := 0, -- 8357870
   ni_able_auel  NUMBER(15) := 0, --EOY 07/08
   ers_rebate    NUMBER(15) := 0,
   ees_rebate    NUMBER(15) := 0,
   ni_refund     VARCHAR2(1),
   scon          VARCHAR2(15));
TYPE g_ni_values_typ IS TABLE OF g_ni_values_rec
  INDEX BY binary_integer;
TYPE g_asg_actions_typ IS TABLE OF
  pay_assignment_actions.assignment_action_id%TYPE
  INDEX BY binary_integer;
TYPE g_date_table_typ IS TABLE OF DATE
  INDEX BY binary_integer;
TYPE g_period_table_typ IS TABLE OF VARCHAR2(30)
  INDEX BY binary_integer;
TYPE g_tax_ref_table_typ IS TABLE OF VARCHAR2(10) -- 4011263
  INDEX BY binary_integer;
TYPE g_max_per_table_typ IS TABLE OF NUMBER
  INDEX BY binary_integer;
TYPE g_no_fisc_yr_typ   IS TABLE OF
  per_time_period_types.number_per_fiscal_year%TYPE
  INDEX BY binary_integer;
TYPE g_tax_dist_table_typ IS TABLE OF VARCHAR2(3)
  INDEX BY binary_integer;
TYPE g_permit_no_table_typ IS TABLE OF VARCHAR2(12)
  INDEX BY binary_integer;
TYPE g_cached_varchar_typ IS TABLE OF VARCHAR2(30)
  INDEX BY binary_integer;
-- PL/SQL tables:
g_agg_balance_totals       g_agg_values_rec;
g_zero_balance_totals      g_agg_values_rec;
g_ni_balance_totals        g_ni_values_typ;
g_empty_ni_balance_totals  g_ni_values_typ;
g_asg_actions              g_asg_actions_typ;
g_empty_asg_actions        g_asg_actions_typ;
--PL/SQL tables for cached payroll info
g_pay_start_yr_tab         g_date_table_typ;
g_pay_end_yr_tab           g_date_table_typ;
g_pay_max_per_no_tab       g_max_per_table_typ;
g_pay_period_typ_tab       g_period_table_typ;
g_pay_tax_ref_tab          g_tax_ref_table_typ;
g_pay_tax_dist_tab         g_tax_dist_table_typ;
g_no_per_fiscal_yr         g_no_fisc_yr_typ;
--
-- csr_assign cache tables
--
g_payroll_end_yr_tab       g_cached_varchar_typ;
g_payroll_start_yr_tab     g_cached_varchar_typ;
g_payroll_tax_ref_tab      g_tax_ref_table_typ;
g_payroll_tax_dist_tab     g_tax_dist_table_typ;
g_payroll_permit_no_tab    g_permit_no_table_typ;
-- variables:
-- 1st two are initialised by the archinit procedure
g_masg_person_id           per_all_assignments_f.person_id%TYPE;
-- added g_masg_period_of_service_id to fix bug 3784871
g_masg_period_of_service_id per_all_assignments_f.period_of_service_id%TYPE;
g_masg_active_start         per_all_assignments_f.effective_start_date%TYPE;
g_masg_active_end           per_all_assignments_f.effective_end_date%TYPE;
g_masg_tax_ref_num         VARCHAR2(10); -- 4011263: length 10 chars
g_max_gross_pay            NUMBER(15) := NULL;
g_primary_action           pay_assignment_actions.assignment_action_id%TYPE;
g_min_assignment_id        per_all_assignments_f.assignment_id%TYPE;
g_has_non_extracted_masgs  BOOLEAN := FALSE;
g_num_actions              binary_integer:=0;
--
------------------------------- FUNCTIONS -----------------------------------
--
FUNCTION get_nearest_scon(p_element_entry_id       IN NUMBER ,
                          p_assignment_action_id   IN NUMBER,
                          p_category               IN VARCHAR2 ,
                          p_effective_date         IN DATE)
                          RETURN VARCHAR2
-- This function searches for a SCON number to associate with the SCON balance
-- Balance initialization creates run results prior to the NI row that records
-- the SCON number. So find a row for the same category after the effective
-- date of the owning payroll action.
-- Priority is next latest SCON input with the same Category
-- down to next latest SCON input regardless of Category
IS
  cursor get_rrv_scon (c_assignment_action_id number,
                       c_element_entry_id     number) is
  --
  -- Select the SCON number from the Run Result Values table,
  -- it is possible for the element entry value to have a NULL
  -- SCON while the Run Result still holds a valid SCON.
  --
  select prrv.result_value
  from pay_run_result_values prrv,
       pay_run_results prr
  where prr.source_id = c_element_entry_id
  and   prr.element_type_id = g_ni_id
  and   prr.assignment_action_id = c_assignment_action_id
  and   prrv.run_result_id = prr.run_result_id
  and   prrv.input_value_id = g_scon_input_id;
--
  cursor get_scon IS
  -- best match is if the category on the entry matches the balance category
  -- as a workarround users may have entered scon against a different
  -- category. So if no category matches just get the nearest scon value
  --
  SELECT  scon.screen_entry_value
  FROM
    pay_element_entry_values_f  scon,
    pay_element_entry_values_f  cat
  WHERE scon.element_entry_id = p_element_entry_id
  AND   cat.element_entry_id  = p_element_entry_id
  AND   cat.effective_start_date = scon.effective_start_date
  AND   cat.effective_end_date   = scon.effective_end_date
  AND   scon.input_value_id +0   = g_scon_input_id
  AND   cat.input_value_id +0    = g_category_input_id
  AND   scon.screen_entry_value IS NOT NULL
  ORDER BY decode(cat.screen_entry_value,p_category,0,1),
           ABS(p_effective_date - scon.effective_end_date);
  --
  l_scon    VARCHAR2(9):= NULL;
BEGIN
  --dbms_output.put_line('NI ID='||g_ni_id||' EE ID='||p_element_entry_id||' SCON IV='||g_scon_input_id||' CAT IV='||g_category_input_id);

  /* 4502181- IF globals are null, query them here -- Required by the Tax Payments Listing report */
  IF G_NI_ID IS NULL THEN
      SELECT element_type_id
        INTO   g_ni_id
        FROM   pay_element_types_f
        WHERE  element_name = 'NI'
          AND  p_effective_date BETWEEN effective_start_date AND effective_end_date;
        --
        SELECT input_value_id
        INTO   g_category_input_id
        FROM   pay_input_values_f
        WHERE  name = 'Category'
          AND  element_type_id = g_ni_id
          AND  p_effective_date BETWEEN effective_start_date AND effective_end_date;
        --
        SELECT input_value_id
        INTO   g_scon_input_id
        FROM   pay_input_values_f
        WHERE  name = 'SCON'
          AND  element_type_id = g_ni_id
          AND  p_effective_date BETWEEN effective_start_date AND effective_end_date;
  END IF;

  BEGIN
    OPEN get_scon;
    FETCH get_scon INTO l_scon;
    CLOSE get_scon;
  EXCEPTION
    WHEN no_data_found THEN
      l_scon := NULL;
  END;

  --
  -- If the scon is not on the EEV, use the
  -- second cursor to look at the Run Result Value.
  --
  IF l_scon is null then
    open get_rrv_scon(p_assignment_action_id, p_element_entry_id);
    fetch get_rrv_scon into l_scon;
    if get_rrv_scon%notfound then
       l_scon := NULL;
    end if;
    close get_rrv_scon;
  END IF;
  --
  RETURN l_scon;
END get_nearest_scon;
--
FUNCTION canonical_to_date(p_chardate   IN VARCHAR2)
                           RETURN DATE
-- Cover on the fnd_date function, but with exception handling
IS
  l_return_date   DATE;
BEGIN
  l_return_date := fnd_date.canonical_to_date(p_chardate);
  RETURN l_return_date;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END canonical_to_date;
--
FUNCTION canonical_to_number(p_charnum   IN VARCHAR2)
                             RETURN NUMBER
-- Cover on the fnd_number function, but with exception handling
IS
  l_return_num NUMBER;
BEGIN
  l_return_num := fnd_number.canonical_to_number(p_charnum);
  RETURN l_return_num;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END canonical_to_number;
--
FUNCTION get_arch_str(p_action_id        IN NUMBER,
                      p_user_entity_id   IN NUMBER,
                      p_context_value1   IN VARCHAR2 DEFAULT NULL,
                      p_context_value2   IN VARCHAR2 DEFAULT NULL,
                      p_context_value3   IN VARCHAR2 DEFAULT NULL)
                      RETURN VARCHAR2
-- Pure Public Function which returns a value from the archive, given
-- the action id (ff_archive_items.context1), user entity id and up to
-- three additional contexts.  No validation is performed on the input
-- parameters.  If a matching item does not exist, null is returned.
-- The additional context parameters must be populated in order.
IS
  l_arch_value ff_archive_items.value%type;
BEGIN
  -- use implicit cursors so that too_many_rows can easily be detected
  IF p_context_value3 IS NOT NULL THEN
    SELECT fai.VALUE
      INTO l_arch_value
      FROM ff_archive_item_contexts aic1,
           ff_archive_item_contexts aic2,
           ff_archive_item_contexts aic3,
           ff_archive_items         fai
      WHERE fai.context1         = p_action_id
      AND   fai.user_entity_id   = p_user_entity_id
      AND   aic1.archive_item_id = fai.archive_item_id
      AND   aic1.sequence_no     = 1
      AND   aic1.context         = p_context_value1
      AND   aic2.archive_item_id = fai.archive_item_id
      AND   aic2.sequence_no     = 2
      AND   aic2.context         = p_context_value2
      AND   aic3.archive_item_id = fai.archive_item_id
      AND   aic3.sequence_no     = 3
      AND   aic3.context         = p_context_value3;
  ELSIF p_context_value2 IS NOT NULL THEN
    SELECT fai.VALUE
      INTO l_arch_value
      FROM ff_archive_items         fai,
           ff_archive_item_contexts aic1,
           ff_archive_item_contexts aic2
      WHERE fai.context1         = p_action_id
      AND   fai.user_entity_id   = p_user_entity_id
      AND   aic1.archive_item_id = fai.archive_item_id
      AND   aic1.sequence_no     = 1
      AND   aic1.context         = p_context_value1
      AND   aic2.archive_item_id = fai.archive_item_id
      AND   aic2.sequence_no     = 2
      AND   aic2.context         = p_context_value2;
  ELSIF p_context_value1 IS NOT NULL THEN
    SELECT fai.VALUE
      INTO l_arch_value
      FROM ff_archive_item_contexts aic1,
           ff_archive_items         fai
      WHERE fai.context1         = p_action_id
      AND   fai.user_entity_id   = p_user_entity_id
      AND   aic1.archive_item_id = fai.archive_item_id
      AND   aic1.sequence_no     = 1
      AND   aic1.context         = p_context_value1;
  ELSE
    SELECT fai.VALUE
      INTO l_arch_value
      FROM ff_archive_items        fai
     WHERE fai.context1         = p_action_id
       AND fai.user_entity_id   = p_user_entity_id;
  END IF;
  RETURN l_arch_value;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_arch_str;
--
FUNCTION get_arch_str(p_action_id        IN NUMBER,
                      p_user_entity_name IN VARCHAR2,
                      p_context_value1   IN VARCHAR2 DEFAULT NULL,
                      p_context_value2   IN VARCHAR2 DEFAULT NULL,
                      p_context_value3   IN VARCHAR2 DEFAULT NULL)
                      RETURN VARCHAR2
-- Overloaded Pure Public Function which returns a value from the archive,
-- given the action id (ff_archive_items.context1), user entity name and up to
-- two additional contexts.  No validation is performed on the input
-- parameters.  If a matching item does not exist, null is returned.
-- The additional context parameters must be populated in order.
IS
  l_user_entity_id  ff_user_entities.user_entity_id%type;
  l_arch_value      ff_archive_items.value%type;
BEGIN
  SELECT fue.user_entity_id
    INTO l_user_entity_id
    FROM ff_user_entities  fue
   WHERE fue.user_entity_name = p_user_entity_name
     AND fue.legislation_code= 'GB';
  --
  l_arch_value := pay_gb_eoy_archive.get_arch_str(p_action_id,
                                                  l_user_entity_id,
                                                  p_context_value1,
                                                  p_context_value2,
                                                  p_context_value3);
  RETURN l_arch_value;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_arch_str;
--
FUNCTION get_arch_num(p_action_id        IN NUMBER,
                      p_user_entity_name IN VARCHAR2,
                      p_context_value1   IN VARCHAR2 DEFAULT NULL,
                      p_context_value2   IN VARCHAR2 DEFAULT NULL,
                      p_context_value3   IN VARCHAR2 DEFAULT NULL)
                      RETURN NUMBER
-- Pure Public Function which returns a value from the archive
-- using get_arch_str, then formats it to a number
-- This could not be achieved by overloading get_arch_str as the views
-- wouldn't know which return data type was required.
IS
BEGIN
  RETURN to_number(get_arch_str(p_action_id,
                                p_user_entity_name,
                                p_context_value1,
                                p_context_value2,
                                p_context_value3));
END get_arch_num;
--
FUNCTION get_arch_date(p_action_id        IN NUMBER,
                       p_user_entity_name IN VARCHAR2,
                       p_context_value1   IN VARCHAR2 DEFAULT NULL,
                       p_context_value2   IN VARCHAR2 DEFAULT NULL,
                       p_context_value3   IN VARCHAR2 DEFAULT NULL)
                       RETURN DATE
-- Pure Public Function which returns a value from the archive
-- using get_arch_str, then formats it to a date
-- This could not be achieved by overloading get_arch_str as the views
-- wouldn't know which return data type was required.
IS
BEGIN
  RETURN fnd_date.canonical_to_date(get_arch_str(p_action_id,
                              p_user_entity_name,
                              p_context_value1,
                              p_context_value2,
                              p_context_value3));
END get_arch_date;
--
FUNCTION get_parameter(p_parameter_string IN VARCHAR2,
                       p_token            IN VARCHAR2,
                       p_segment_number   IN NUMBER DEFAULT NULL)
                       RETURN VARCHAR2
-- Pure Public Function which returns a specific legislative parameter,
-- given a string of parameters and a token.
-- Optional segment_number parameter indicates which segment of the parameter
-- to return where the parameter contains segments separated by colons
--   eg. SORT_OPTIONS=segment1:segment2:segment3
-- Now caters for spaces in parameter values (so can be used to retrieve
-- canonical dates) where the parameter is delimited with pipe chars
--   eg.  |START_DATE=1999/04/06 00:00:00|
IS
  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
BEGIN
  l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  end if;
  IF l_start_pos <> 0 THEN
    l_start_pos := l_start_pos + length(p_token||'=');
    l_parameter := substr(p_parameter_string,
                          l_start_pos,
                          instr(p_parameter_string||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
    IF p_segment_number IS NOT NULL THEN
      l_parameter := ':'||l_parameter||':';
      l_parameter := substr(l_parameter,
                            instr(l_parameter,':',1,p_segment_number)+1,
                            instr(l_parameter,':',1,p_segment_number+1) -1
                            - instr(l_parameter,':',1,p_segment_number));
    END IF;
  END IF;
  RETURN l_parameter;
END get_parameter;
--
-----------------------------------------------------------------------------
-- PROCEDURE:   cache_archive_value
-- DESCRIPTION: Stores all relevant payroll-level information from the
--              archive tables to cached plsql tables for performance.
--              Values are then retrieved using get_cached_value. Cannot
--              merge the two functions due to pragma restrict_references
--              WNPS violation.
-----------------------------------------------------------------------------
--
PROCEDURE cache_archive_value(p_payroll_action_id   IN NUMBER,
                              p_end_yr_ueid         IN NUMBER,
                              p_start_yr_ueid       IN NUMBER,
                              p_tax_ref_ueid        IN NUMBER,
                              p_tax_dist_ueid       IN NUMBER,
                              p_permit_ueid         IN NUMBER) IS
--
  l_archive_value VARCHAR2(30);
  cursor get_payroll_id(c_payroll_action_id number,
                        c_user_entity_id number) is
  select to_number(faic.context) payroll_id
  from ff_archive_items fai,
       ff_archive_item_contexts faic
  where fai.context1 = c_payroll_action_id
  and   fai.user_entity_id = c_user_entity_id
  and   fai.archive_item_id = faic.archive_item_id
  and   faic.sequence_no = 1;
--
BEGIN
   --
   -- Default start/end year globals
   g_min_start_year      := hr_general.end_of_time;
   g_max_end_year        := hr_general.start_of_time;
   --
   FOR payroll_rec in get_payroll_id(p_payroll_action_id,p_permit_ueid) LOOP
   --
      g_payroll_end_yr_tab(payroll_rec.payroll_id) :=
      pay_gb_eoy_archive.get_arch_str(p_action_id =>      p_payroll_action_id,
                                      p_user_entity_id => p_end_yr_ueid,
                                      p_context_value1 => payroll_rec.payroll_id);
      g_payroll_start_yr_tab(payroll_rec.payroll_id) :=
      pay_gb_eoy_archive.get_arch_str(p_action_id =>      p_payroll_action_id,
                                      p_user_entity_id => p_start_yr_ueid,
                                      p_context_value1 => payroll_rec.payroll_id);
      g_payroll_tax_ref_tab(payroll_rec.payroll_id) :=
      pay_gb_eoy_archive.get_arch_str(p_action_id =>      p_payroll_action_id,
                                      p_user_entity_id => p_tax_ref_ueid,
                                      p_context_value1 => payroll_rec.payroll_id);
      g_payroll_tax_dist_tab(payroll_rec.payroll_id) :=
      pay_gb_eoy_archive.get_arch_str(p_action_id =>      p_payroll_action_id,
                                      p_user_entity_id => p_tax_dist_ueid,
                                      p_context_value1 => payroll_rec.payroll_id);
      g_payroll_permit_no_tab(payroll_rec.payroll_id) :=
      pay_gb_eoy_archive.get_arch_str(p_action_id =>      p_payroll_action_id,
                                      p_user_entity_id => p_permit_ueid,
                                      p_context_value1 => payroll_rec.payroll_id);
      g_min_start_year :=
        least(g_min_start_year,
              nvl(fnd_date.canonical_to_date
                     (g_payroll_start_yr_tab(payroll_rec.payroll_id)),
                     g_min_start_year));
      g_max_end_year :=
        greatest(g_max_end_year,
              nvl(fnd_date.canonical_to_date
                     (g_payroll_end_yr_tab(payroll_rec.payroll_id)),
                      g_max_end_year));
   END LOOP;
   --
--
END cache_archive_value;
--
-----------------------------------------------------------------------------
-- FUNCTION:    get_cached_value
-- DESCRIPTION: This function returns a value
--              of an archive object given a payroll_action_id, payroll_id
--              and user_entity_id. WNDS WNPS set.
-----------------------------------------------------------------------------
--
FUNCTION get_cached_value(p_payroll_action_id    IN NUMBER,
                          p_user_entity_name     IN VARCHAR2,
                          p_payroll_id           IN NUMBER)
RETURN VARCHAR2 IS
--
  l_return_value     varchar2(30);
--
BEGIN
--
  BEGIN
    --
    if p_user_entity_name = 'X_END_YEAR' then
       l_return_value := g_payroll_end_yr_tab(p_payroll_id);
    elsif p_user_entity_name = 'X_START_YEAR' then
       l_return_value := g_payroll_start_yr_tab(p_payroll_id);
    elsif p_user_entity_name = 'X_TAX_REFERENCE_NUMBER' then
       l_return_value := g_payroll_tax_ref_tab(p_payroll_id);
    elsif p_user_entity_name = 'X_TAX_DISTRICT_REFERENCE' then
       l_return_value := g_payroll_tax_dist_tab(p_payroll_id);
    elsif p_user_entity_name = 'X_PERMIT_NUMBER' then
       l_return_value := g_payroll_permit_no_tab(p_payroll_id);
    end if;
  --
  EXCEPTION when others then
  --
  --RAISE; -- Initialisation in cache_archive_value must have failed.
  --
    l_return_value :=
      pay_gb_eoy_archive.get_arch_str
        (p_action_id        => p_payroll_action_id,
         p_user_entity_name => p_user_entity_name,
         p_context_value1   => to_char(p_payroll_id));
  --
  END;
--
RETURN l_return_value;
--
END get_cached_value;
--
-----------------------------------------------------------------------------
-- FUNCTION:    get_agg_active_start
-- DESCRIPTION: This function returns the earliest start date of the
--              active aggregated assignments on the same PAYE ref.
--              WNDS WNPS set.
-----------------------------------------------------------------------------
FUNCTION get_agg_active_start(p_asg_id   IN NUMBER,
                              p_tax_ref  IN VARCHAR2,
                              p_proll_eff_date IN DATE)
RETURN DATE IS
   l_min_active       per_all_assignments_f.effective_start_date%TYPE;
   l_person_id        per_all_people_f.person_id%TYPE;
   l_pos_id           per_all_assignments_f.period_of_service_id%TYPE;
   l_new_min_active   per_all_assignments_f.effective_start_date%TYPE;
   l_term_and_xfer    VARCHAR2(1);
   l_old_paye_ref     hr_soft_coding_keyflex.segment1%TYPE;
   l_another_active_asg_xfer VARCHAR2(1);
   --
   -- cursor to get max effective_start date on the given PAYE Ref
   -- for given assignment on or before the given date
   CURSOR get_first_active_start IS
   SELECT max(paaf.effective_start_date) first_st_date, max(person_id) person_id
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref
   AND    paaf.effective_start_date <= p_proll_eff_date;
   --
   -- cursor to find the first day of the assignment on the given paye ref
   -- regardless of the status, this is to be used only when assignment has
   -- never been active on the given PAYE Ref therefore get_first_active_start
   -- will not be able to return first Active/Susp Status date
   CURSOR get_first_start IS
   SELECT max(paaf.effective_start_date) first_st_date, max(person_id) person_id, max(period_of_service_id) pos_id
   FROM   per_all_assignments_f paaf,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref
   AND    paaf.effective_start_date <= p_proll_eff_date;
   --
   -- Cursor to check whether the assignment was active on a different PAYE Ref
   -- a day before it was transferred to another PAYE Ref
   CURSOR is_term_and_xfer IS
   SELECT 'Y' term_and_xfer, flex.segment1 old_paye_ref
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 <> p_tax_ref
   AND    l_min_active-1 BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date;
   --
   -- Cursor to check if there was another assignment of the employee
   -- transferred from/to same PAYE Refs on the same day as the given
   -- assignment but remained active before and after the transfer
   CURSOR is_another_active_asg_xfer IS
   SELECT 'Y'
   FROM   per_all_assignments_f paaf1,
          per_assignment_status_types past1,
          pay_all_payrolls_f papf1,
          hr_soft_coding_keyflex flex1
   WHERE  paaf1.period_of_service_id = l_pos_id
   AND    paaf1.assignment_id <> p_asg_id
   AND    l_min_active BETWEEN paaf1.effective_start_date
                       AND paaf1.effective_end_date
   AND    paaf1.assignment_status_type_id = past1.assignment_status_type_id
   AND    past1.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf1.payroll_id = papf1.payroll_id
   AND    p_proll_eff_date BETWEEN papf1.effective_start_date and papf1.effective_end_date
   AND    papf1.soft_coding_keyflex_id = flex1.soft_coding_keyflex_id
   AND    flex1.segment1 = p_tax_ref
   AND    EXISTS ( SELECT 1
                   FROM   per_all_assignments_f paaf2,
                          per_assignment_status_types past2,
                          pay_all_payrolls_f papf2,
                          hr_soft_coding_keyflex flex2
                  WHERE   paaf2.assignment_id = paaf1.assignment_id
                  AND     l_min_active-1 BETWEEN paaf2.effective_start_date
                                         AND paaf2.effective_end_date
                  AND    paaf2.assignment_status_type_id = past2.assignment_status_type_id
                  AND    past2.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
                  AND    paaf2.payroll_id = papf2.payroll_id
                  AND    p_proll_eff_date BETWEEN papf2.effective_start_date and papf2.effective_end_date
                  AND    papf2.soft_coding_keyflex_id = flex2.soft_coding_keyflex_id
                  AND    flex2.segment1 = l_old_paye_ref);
   --
   -- cursor to get first effective_start_date across all active or suspended
   -- assignments of the person on a given tax ref as at a given date
   CURSOR get_agg_min_start_date IS
   SELECT min(paaf.effective_start_date) min_active
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.person_id = l_person_id
   AND    (l_min_active-1) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref;
   --
   l_proc   VARCHAR2(100) := 'pay_gb_eoy_archive.get_agg_active_start';
BEGIN
   -- Get first active or suspended status start date for the assignment
   OPEN  get_first_active_start;
   FETCH get_first_active_start INTO l_min_active, l_person_id;
   -- Bug 5909829: If assignment has never been active on this PAYE Ref
   -- on or before the p_effective_date then check if it has been
   -- transferred from another PAYE Ref along with at least on another
   -- PAYE Ref
   IF l_min_active IS NULL and l_person_id IS NULL THEN
      -- The assignment has never been active on the given
      -- PAYE Ref before the given date therefore
      -- get first day on the PAYE Ref regardless of the status
      -- on or before the given date
      OPEN get_first_start;
      FETCH get_first_start INTO l_min_active, l_person_id, l_pos_id;
      IF get_first_start%FOUND THEN
         -- Check if this assignment has been terminated and
         -- transferred to the current PAYE Ref on the same day
         -- i.e., it is active on another PAYE Ref a day before
         -- transfer
         OPEN is_term_and_xfer;
         FETCH is_term_and_xfer INTO l_term_and_xfer, l_old_paye_ref;
         IF is_term_and_xfer%FOUND THEN
            -- check whether there is another active assignment
            -- of the employee transferred along with the given
            -- assignment on the same day
            OPEN is_another_active_asg_xfer;
            FETCH is_another_active_asg_xfer INTO l_another_active_asg_xfer;
            IF is_another_active_asg_xfer%FOUND THEN
               -- given assignment is transferred and terminated on the
               -- same day but another assignment of the employee remained
               -- active with same transfer (from/to PAYE Refs)
               -- and on the same day therefore it is
               -- continuation of same employment hence continue to find
               -- start of this continuous active period of employment
               l_min_active := l_min_active;
            ELSE
               -- given assignment is transferred and terminated on the
               -- same day but there is NO other assignment of the employee
               -- that remained active with same transfer (from/to PAYE Refs)
               -- on the same day therefore it is NOT
               -- continuation of same employment
               l_min_active := NULL;
            END IF;
         END IF; -- is_term_and_xfer
         CLOSE is_term_and_xfer;
      END IF; -- get_first_start
      CLOSE get_first_start;
   END IF; -- l_min_active and l_person_id are null
   --

   CLOSE get_first_active_start;
   --
   IF l_min_active IS NULL THEN
      --modified format for bug fix 4991467
      RETURN fnd_date.canonical_to_date('0001/01/01 00:00:00');
   END IF;
   -- check if any of the other assignments of this employee
   -- that were active before this assignment
   LOOP
      l_new_min_active := NULL;
      --
      OPEN  get_agg_min_start_date;
      FETCH get_agg_min_start_date INTO l_new_min_active;
      CLOSE get_agg_min_start_date;
      --
      IF l_new_min_active IS NOT NULL THEN
         -- new earlier start date found, continue to loop
         -- through to look for earlier active start date amongst aggregated
         -- assignments
         l_min_active := l_new_min_active;
      ELSE
         -- there is no earlier active start date amongst aggregated asgs
         -- hence return earliest active start date found so far
         RETURN l_min_active;
      END IF;
   END LOOP;
END get_agg_active_start;
--
-----------------------------------------------------------------------------
-- FUNCTION:    get_agg_active_end
-- DESCRIPTION: This function returns the earliest start date of the
--              active aggregated assignments on the same PAYE ref.
--              WNDS WNPS set.
-----------------------------------------------------------------------------
FUNCTION get_agg_active_end(p_asg_id    IN NUMBER,
                              p_tax_ref IN VARCHAR2,
                              p_proll_eff_date IN DATE)
RETURN DATE IS
   l_min_active       per_all_assignments_f.effective_start_date%TYPE;
   l_max_active       per_all_assignments_f.effective_start_date%TYPE;
   l_person_id        per_all_people_f.person_id%TYPE;
   l_pos_id           per_all_assignments_f.period_of_service_id%TYPE;
   l_new_max_active   per_all_assignments_f.effective_start_date%TYPE;
   l_term_and_xfer    VARCHAR2(1);
   l_old_paye_ref     hr_soft_coding_keyflex.segment1%TYPE;
   l_another_active_asg_xfer VARCHAR2(1);
   --
   -- cursor to get max effective_end_date on the given PAYE Ref
   -- for given assignment
   CURSOR get_last_active_end IS
   SELECT max(paaf.effective_end_date) last_end_date, max(person_id) person_id
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref
   AND    paaf.effective_start_date <= p_proll_eff_date;
   --
   -- cursor to find the first day of the assignment on the given paye ref
   -- regardless of the status, this is to be used only when assignment has
   -- never been active on the given PAYE Ref therefore get_first_active_start
   -- will not be able to return first Active/Susp Status date
   CURSOR get_first_start IS
   SELECT max(paaf.effective_start_date) first_st_date, max(person_id) person_id, max(period_of_service_id) pos_id
   FROM   per_all_assignments_f paaf,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref
   AND    paaf.effective_start_date <= p_proll_eff_date;
   --
   -- Cursor to check whether the assignment was active on a different PAYE Ref
   -- a day before it was transferred to another PAYE Ref
   CURSOR is_term_and_xfer IS
   SELECT 'Y' term_and_xfer, flex.segment1 old_paye_ref
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 <> p_tax_ref
   AND    l_min_active-1 BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date;
   --
   -- Cursor to check if there was another assignment of the employee
   -- transferred from/to same PAYE Refs on the same day as the given
   -- assignment but remained active before and after the transfer
   CURSOR is_another_active_asg_xfer IS
   SELECT 'Y'
   FROM   per_all_assignments_f paaf1,
          per_assignment_status_types past1,
          pay_all_payrolls_f papf1,
          hr_soft_coding_keyflex flex1
   WHERE  paaf1.period_of_service_id = l_pos_id
   AND    paaf1.assignment_id <> p_asg_id
   AND    l_min_active BETWEEN paaf1.effective_start_date
                       AND paaf1.effective_end_date
   AND    paaf1.assignment_status_type_id = past1.assignment_status_type_id
   AND    past1.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf1.payroll_id = papf1.payroll_id
   AND    p_proll_eff_date BETWEEN papf1.effective_start_date and papf1.effective_end_date
   AND    papf1.soft_coding_keyflex_id = flex1.soft_coding_keyflex_id
   AND    flex1.segment1 = p_tax_ref
   AND    EXISTS ( SELECT 1
                   FROM   per_all_assignments_f paaf2,
                          per_assignment_status_types past2,
                          pay_all_payrolls_f papf2,
                          hr_soft_coding_keyflex flex2
                  WHERE   paaf2.assignment_id = paaf1.assignment_id
                  AND     l_min_active-1 BETWEEN paaf2.effective_start_date
                                         AND paaf2.effective_end_date
                  AND    paaf2.assignment_status_type_id = past2.assignment_status_type_id
                  AND    past2.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
                  AND    paaf2.payroll_id = papf2.payroll_id
                  AND    p_proll_eff_date BETWEEN papf2.effective_start_date and papf2.effective_end_date
                  AND    papf2.soft_coding_keyflex_id = flex2.soft_coding_keyflex_id
                  AND    flex2.segment1 = l_old_paye_ref);
   --
   -- cursor to get latest effective_end_date across all active or suspended
   -- assignments of the person on a given tax ref as at a given date
   CURSOR get_agg_max_end_date IS
   SELECT max(paaf.effective_end_date) max_active
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.person_id = l_person_id
   AND    (l_max_active+1) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    p_proll_eff_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref;
   --
   l_proc   VARCHAR2(100) := 'pay_gb_eoy_archive.get_agg_active_end';
BEGIN
   -- Get first active or suspended status start date for the assignment
   OPEN  get_last_active_end;
   FETCH get_last_active_end INTO l_max_active, l_person_id;
   -- Bug 5909829: If assignment has never been active on this PAYE Ref
   -- on or before the p_effective_date then check if it has been
   -- transferred from another PAYE Ref along with at least on another
   -- PAYE Ref
   IF l_max_active IS NULL and l_person_id IS NULL THEN
      -- The assignment has never been active on the given
      -- PAYE Ref before the given date therefore
      -- get first day on the PAYE Ref regardless of the status
      -- on or before the given date
      OPEN get_first_start;
      FETCH get_first_start INTO l_min_active, l_person_id, l_pos_id;
      IF get_first_start%FOUND THEN
         -- Check if this assignment has been terminated and
         -- transferred to the current PAYE Ref on the same day
         -- i.e., it is active on another PAYE Ref a day before
         -- transfer
         OPEN is_term_and_xfer;
         FETCH is_term_and_xfer INTO l_term_and_xfer, l_old_paye_ref;
         IF is_term_and_xfer%FOUND THEN
            -- check whether there is another active assignment
            -- of the employee transferred along with the given
            -- assignment on the same day
            OPEN is_another_active_asg_xfer;
            FETCH is_another_active_asg_xfer INTO l_another_active_asg_xfer;
            IF is_another_active_asg_xfer%FOUND THEN
               -- given assignment is transferred and terminated on the
               -- same day but another assignment of the employee remained
               -- active with same transfer (from/to PAYE Refs)
               -- and on the same day therefore it is
               -- continuation of same employment hence continue to find
               -- end of this continuous active period of employment
               l_max_active := l_min_active;
            ELSE
               -- given assignment is transferred and terminated on the
               -- same day but there is NO other assignment of the employee
               -- that remained active with same transfer (from/to PAYE Refs)
               -- on the same day therefore it is NOT
               -- continuation of same employment
               l_max_active := NULL;
            END IF;
         END IF; -- is_term_and_xfer
         CLOSE is_term_and_xfer;
      END IF; -- get_first_start
      CLOSE get_first_start;
   END IF; -- l_max_active and l_person_id are null
   --
   CLOSE get_last_active_end;
   --
   IF l_max_active IS NULL THEN
      --modified format for bug fix 4991467
      RETURN fnd_date.canonical_to_date('4712/12/31 00:00:00');
   END IF;
   --
   -- check if any of the other assignments of
   -- this employee that were active after this assignment
   LOOP
      l_new_max_active := NULL;
      --
      OPEN  get_agg_max_end_date;
      FETCH get_agg_max_end_date INTO l_new_max_active;
      CLOSE get_agg_max_end_date;
      --
      IF l_new_max_active IS NOT NULL THEN
         -- new latest end date found, continue to loop
         -- through to look for later active end date amongst aggregated
         -- assignments
         l_max_active := l_new_max_active;
      ELSE
         -- there is no later active end date amongst aggregated asgs
         -- hence return latest active ebd date found so far
         RETURN l_max_active;
      END IF;
   END LOOP;
END get_agg_active_end;
--
------------------------------- PROCEDURES ---------------------------------
--
PROCEDURE write_output_header IS
BEGIN
   --
   hr_utility.set_location('pay_gb_eoy_archive.write_output_header', 10);
   fnd_file.put_line(fnd_file.output, rpad(' ', 41)||
          'End Of Year Process - Errors and Warnings Report'||
          rpad(' ', 30)||fnd_date.date_to_displaydate(sysdate));
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, rpad(' ', 20)||
          'Request Id: '||fnd_global.conc_request_id);
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output,  rpad('Assignment', 14) || ' ' ||
          rpad(' ', 30) || ' ' || rpad('Error or', 10) || ' ' ||
          rpad(' ', 75));
   fnd_file.put_line(fnd_file.output,  rpad('Number', 14) || ' ' ||
          rpad('Full Name', 30) || ' ' || rpad('Warning', 10) || ' ' ||
          rpad('Message', 75));
   fnd_file.put_line(fnd_file.output,  rpad('-', 14, '-') || ' ' ||
          rpad('-', 30, '-') || ' ' || rpad('-', 10, '-') || ' ' ||
          rpad('-', 75, '-'));
   g_output_header := FALSE;
   hr_utility.set_location('pay_gb_eoy_archive.write_output_header', 100);
END write_output_header;
--
FUNCTION write_output(p_assignment_number IN VARCHAR2,
                       p_full_name IN VARCHAR2,
                       p_message_type IN VARCHAR2,
                       p_message IN VARCHAR2) RETURN NUMBER IS
--
   l_err_warn VARCHAR2(10);
   l_message  VARCHAR2(250);
BEGIN
   --
   hr_utility.set_location('pay_gb_eoy_archive.write_output', 1);
   hr_utility.trace('p_assignment_number='||p_assignment_number);
   hr_utility.trace('p_full_name='||p_full_name);
   hr_utility.trace('p_message_type='||p_message_type);
   hr_utility.trace('p_message='||p_message);
   --
   -- strip ':' from the error message
   l_message := ltrim(p_message, ':');
   --
   IF g_output_header THEN
      write_output_header;
   END IF;
   hr_utility.set_location('pay_gb_eoy_archive.write_output', 30);
   IF p_message_type = 'E' THEN
      l_err_warn := 'Error';
      fnd_file.put_line(fnd_file.log, 'An error encountered when processing assignment '||p_assignment_number||', please check output file for more details.');
      g_err_count := nvl(g_err_count, 0) + 1;
   ELSE
      l_err_warn := 'Warning';
      g_warn_count := nvl(g_warn_count, 0) + 1;
   END IF;
   --
   hr_utility.set_location('pay_gb_eoy_archive.write_output', 40);
   fnd_file.put_line(fnd_file.output, rpad(p_assignment_number, 14)||' '||
          rpad(p_full_name, 30)||' '||rpad(l_err_warn,10)||' '||
          rpad(l_message,75));
   --
   hr_utility.set_location('pay_gb_eoy_archive.write_output', 50);
   IF length(l_message) > 75 THEN
      fnd_file.put_line(fnd_file.output, rpad(' ', 57)||
                          rpad(substr(l_message,76),75));
   END IF;
   --
   hr_utility.set_location('pay_gb_eoy_archive.write_output', 100);
   return 0;
END write_output;
--
FUNCTION write_output_footer RETURN NUMBER IS
BEGIN
   hr_utility.set_location('pay_gb_eoy_archive.write_output_header', 1);
   --
   IF g_output_header THEN
      write_output_header;
   END IF;
   --
   hr_utility.set_location('pay_gb_eoy_archive.write_output_header', 10);
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, rpad(' ', 20)||
          'Total Number of Errors   = '||nvl(g_err_count,0));
   fnd_file.put_line(fnd_file.output, rpad(' ', 20)||
          'Total Number of Warnings = '||nvl(g_warn_count,0));
   hr_utility.set_location('pay_gb_eoy_archive.write_output_header', 100);
   return 0;
END write_output_footer;
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2)
-- public procedure which archives the payroll information, then returns a
-- varchar2 defining a SQL Statement to select all the people that may be
-- eligible for Year End reporting.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
IS
  --
  l_proc             CONSTANT VARCHAR2(32):= g_package||'range_cursor';
  -- vars for constructing the sqlstr
  l_range_cursor              VARCHAR2(4000):= NULL;
  l_parameter_match           VARCHAR2(500) := NULL;
  -- vars for constructing an error message:
  l_payroll_action_message    VARCHAR(240);
  -- vars for holding SRS Parameters:
  l_start_year                DATE;
  l_end_year                  DATE;
  l_business_group_id         hr_organization_units.business_group_id%TYPE;
  l_permit_number             VARCHAR2(12);
  l_tax_district_reference    VARCHAR2(3);  -- error check will ensure numeric
  l_tax_reference_number      VARCHAR2(10); -- 4011263: length 10 chars
  l_test_indicator            varchar2(1);  -- 5909829 EOY to store test indicator value
  l_unique_test_id            varchar2(50); -- 5909829 EOY to store unique test id value
  -- vars for returns from the API:
  l_archive_item_id           ff_archive_items.archive_item_id%TYPE;
  l_ovn                       NUMBER;
  l_some_warning              BOOLEAN;
  -- vars for holding payroll data:
  l_payroll_start_year        DATE;
  l_payroll_end_year          DATE;
  l_payroll_period_type       VARCHAR2(30);
  l_payroll_max_period_number NUMBER;
  l_dummy                     NUMBER;
  -- User Entity IDs
  l_payroll_id_eid                 ff_user_entities.user_entity_id%TYPE;
  l_permit_number_eid              ff_user_entities.user_entity_id%TYPE;
  l_payroll_name_eid               ff_user_entities.user_entity_id%TYPE;
  l_tax_district_reference_eid     ff_user_entities.user_entity_id%TYPE;
  l_tax_reference_eid              ff_user_entities.user_entity_id%TYPE;
  l_tax_district_name_eid          ff_user_entities.user_entity_id%TYPE;
  l_employers_name_eid             ff_user_entities.user_entity_id%TYPE;
  l_employers_address_line_eid     ff_user_entities.user_entity_id%TYPE;
  l_econ_eid                       ff_user_entities.user_entity_id%TYPE;

/* Start 4011263
  l_smp_recovered_eid              ff_user_entities.user_entity_id%TYPE;
  l_sap_recovered_eid              ff_user_entities.user_entity_id%TYPE;
  l_spp_recovered_eid              ff_user_entities.user_entity_id%TYPE;
  l_ssp_recovered_eid              ff_user_entities.user_entity_id%TYPE;
  l_smp_compensation_eid           ff_user_entities.user_entity_id%TYPE;
  l_sap_compensation_eid           ff_user_entities.user_entity_id%TYPE;
  l_spp_compensation_eid           ff_user_entities.user_entity_id%TYPE;
   End 4011263 */

  l_payroll_start_year_eid         ff_user_entities.user_entity_id%TYPE;
  l_payroll_end_year_eid           ff_user_entities.user_entity_id%TYPE;
  l_payroll_period_type_eid        ff_user_entities.user_entity_id%TYPE;
  l_max_period_number_eid          ff_user_entities.user_entity_id%TYPE;
  l_payroll_action_message_eid     ff_user_entities.user_entity_id%TYPE;
  -- exceptions
  tax_dist_ref_error    EXCEPTION; -- raised when l_tax_district_reference
                                   -- has incorrect format
  inconsis_ref_error    EXCEPTION; -- raised when a payroll has more than
                                   -- PAYE Ref in the tax year
  test_indicator_error  EXCEPTION; -- raised when Test indicaor is Yes
			           -- and no Unique Test ID BUG 5909829 EOY
  --
  -- Start of BUG 5909829 EOY Changed the cursor to fetch test indicator and
  -- unique test id values
  --
  -- Start of BUG 5671777-5
  -- Changed start date of the EOY process to reflect start of the current tax year
  -- so need to add 12 months to the start date.
  --
  cursor csr_parameter_info(p_pact_id NUMBER) IS
  SELECT
     to_date('06/04/'||to_char(start_date,'YYYY'),'dd/mm/yyyy')
  -- add_months(to_date('06/04/'||to_char(start_date,'YYYY'),'dd/mm/yyyy'),12)
  -- End of BUG 5671777-5
     start_year,
    effective_date end_year,
    business_group_id,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'PERMIT'),1,12) permit,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TAX_REF'),1,3) tax_dist,
    substr(ltrim(substr(pay_gb_eoy_archive.get_parameter(
    legislative_parameters,'TAX_REF'),4,11),'/'),1,10) tax_ref,  -- 4011263: tax ref can be 10 chars long
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TEST'),1,1) test_indicator,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'UNIQUE_TEST_ID'),1,8) unique_test_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_pact_id;
  --
  -- End of BUG 5909829 EOY
  --
  cursor csr_payrolls(p_bg_id NUMBER, p_end_year DATE) IS
  -- dont pick up null permits
  SELECT
    p.payroll_id                         payroll_id,
    substr(flex.segment10,1,12)          permit_number,
    p.payroll_name                       payroll_name,
    substr(flex.segment1,1,3)            tax_district_reference,
    substr(ltrim(substr(org_information1,4,11),'/') ,1,10)  tax_reference,
    flex.segment1                        emp_paye_ref,
    substr(org.org_information2 ,1,40)   tax_district_name,
    substr(ltrim(org.org_information3),1,36)    employers_name, -- 4011263: added ltrim
    substr(ltrim(org.org_information4),1,60)    employers_address_line, -- 4011263: added ltrim
    substr(nvl(flex.segment14,org.org_information7),1,9)    econ
/* Start 4011263
    ,
    flex.segment11 * 100                 smp_recovered,
    flex.segment12 * 100                 smp_compensation,
    flex.segment13 * 100                 ssp_recovered,
    flex.segment15 * 100                 sap_recovered,
    flex.segment16 * 100                 sap_compensation,
    flex.segment17 * 100                 spp_recovered,
    flex.segment18 * 100                 spp_compensation
   End 4011263 */
  FROM  pay_all_payrolls_f p,
    hr_soft_coding_keyflex flex,
    hr_organization_information org
  WHERE p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
    AND org.org_information_context = 'Tax Details References'
    AND org.org_information1 = flex.segment1
    AND NVL(org.org_information10,'UK') = 'UK'
    AND flex.segment10 IS NOT NULL
    AND p.business_group_id = p_bg_id
    AND org.organization_id = p_bg_id
    AND p_end_year BETWEEN p.effective_start_date
                       AND p.effective_end_date;
  --
  l_payroll_name pay_all_payrolls_f.payroll_name%TYPE;
  --
  -- cursor to find a different PAYE Ref within a tax year on a given payroll
  CURSOR csr_another_paye_ref(p_payroll_id NUMBER,
                              p_end_year DATE,
                              p_paye_ref VARCHAR2) IS
  SELECT flex.segment1
  FROM   pay_all_payrolls_f p,
         hr_soft_coding_keyflex flex
  WHERE  p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id(+)
  AND    p.payroll_id = p_payroll_id
  AND    p.effective_start_date <= hr_gbbal.span_end(p_end_year)
  AND    p.effective_end_date >= hr_gbbal.span_start(p_end_year)
  AND    nvl(flex.segment1, 'XYZ') <> nvl(p_paye_ref, 'ABC');
  --
  l_another_paye_ref hr_soft_coding_keyflex.segment1%TYPE;
  --
  cursor csr_payroll_year (p_payroll_id NUMBER,
                             p_start_year DATE,
                             p_end_year   DATE) IS
  SELECT
    min(start_date)  start_year,
    max(end_date)    end_year,
    max(period_type) period_type,
    max(period_num)  max_period_number
  FROM  per_time_periods ptp
  WHERE ptp.payroll_id = p_payroll_id
    AND ptp.regular_payment_date BETWEEN p_start_year
                                     AND p_end_year;
  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
    FROM   ff_user_entities
   WHERE  user_entity_name = p_entity_name
     AND  legislation_code = 'GB'
     AND  business_group_id IS NULL;
  --
  --
  PROCEDURE setup_entity_ids IS
  --
  BEGIN
/* Start 4011263
    OPEN csr_user_entity('X_SSP_RECOVERED');
    FETCH csr_user_entity INTO l_ssp_recovered_eid;
    CLOSE csr_user_entity;

    OPEN csr_user_entity('X_SMP_COMPENSATION');
    FETCH csr_user_entity INTO l_smp_compensation_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SMP_RECOVERED');
    FETCH csr_user_entity INTO l_smp_recovered_eid;
    CLOSE csr_user_entity;

    OPEN csr_user_entity('X_SAP_COMPENSATION');
    FETCH csr_user_entity INTO l_sap_compensation_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SAP_RECOVERED');
    FETCH csr_user_entity INTO l_sap_recovered_eid;
    CLOSE csr_user_entity;


    OPEN csr_user_entity('X_SPP_COMPENSATION');
    FETCH csr_user_entity INTO l_spp_compensation_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SPP_RECOVERED');
    FETCH csr_user_entity INTO l_spp_recovered_eid;
    CLOSE csr_user_entity;
   End 4011263 */

    OPEN csr_user_entity('X_ECON');
    FETCH csr_user_entity INTO l_econ_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EMPLOYERS_ADDRESS_LINE');
    FETCH csr_user_entity INTO l_employers_address_line_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EMPLOYERS_NAME');
    FETCH csr_user_entity INTO l_employers_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_DISTRICT_NAME');
    FETCH csr_user_entity INTO l_tax_district_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REFERENCE_NUMBER');
    FETCH csr_user_entity INTO l_tax_reference_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_DISTRICT_REFERENCE');
    FETCH csr_user_entity INTO l_tax_district_reference_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PAYROLL_NAME');
    FETCH csr_user_entity INTO l_payroll_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERMIT_NUMBER');
    FETCH csr_user_entity INTO l_permit_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_MAX_PERIOD_NUMBER');
    FETCH csr_user_entity INTO l_max_period_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERIOD_TYPE');
    FETCH csr_user_entity INTO l_payroll_period_type_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_END_YEAR');
    FETCH csr_user_entity INTO l_payroll_end_year_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_START_YEAR');
    FETCH csr_user_entity INTO l_payroll_start_year_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PAYROLL_ACTION_MESSAGE');
    FETCH csr_user_entity INTO l_payroll_action_message_eid;
    CLOSE csr_user_entity;
  END setup_entity_ids;
  --
  PROCEDURE archive_payroll_info(p_payroll_action_id NUMBER,
                                 p_payroll_id NUMBER,
                                 p_user_entity_id NUMBER,
                                 p_value VARCHAR2) IS
  BEGIN
    ff_archive_api.create_archive_item
      (p_archive_item_id  => l_archive_item_id,
       p_user_entity_id   => p_user_entity_id,
       p_archive_value    => p_value,
       p_archive_type     => 'PA',
       p_action_id        => p_payroll_action_id,
       p_legislation_code => 'GB',
       p_object_version_number => l_ovn,
       p_context_name1    => 'PAYROLL_ID',
       p_context1         => p_payroll_id,
       p_some_warning     => l_some_warning);
  END archive_payroll_info;
  --
BEGIN
  BEGIN
    hr_utility.set_location('Entering: '||l_proc,1);
    --
    setup_entity_ids;
    --
    -- Find payroll action parameters
    --
    --Start BUG 5909829 EOY
    OPEN csr_parameter_info(pactid);
    FETCH csr_parameter_info INTO l_start_year,
                                  l_end_year,
                                  l_business_group_id,
                                  l_permit_number,
                                  l_tax_district_reference,
                                  l_tax_reference_number,
                                  l_test_indicator,
                                  l_unique_test_id;

    CLOSE csr_parameter_info;


    -- Unique Test ID is mandatory if EDI Test indicator is Yes

    IF (l_test_indicator = 'Y' AND l_unique_test_id IS NULL) THEN
        fnd_file.put_line (fnd_file.LOG,'You must provide a Unique Test ID if the EDI Test Indicator is Yes.');
         RAISE test_indicator_error;
    END IF;

    -- End BUG 5909829 EOY

    BEGIN -- ensure tax district reference is numeric (if supplied)
      IF to_number(l_tax_district_reference) < 0 THEN
        RAISE value_error;
      END IF;
    EXCEPTION
      WHEN value_error THEN
        RAISE tax_dist_ref_error;
    END;
    hr_utility.set_location(l_proc,10);
    --
    l_payroll_name := NULL;
    -- Extract Payroll info
    FOR rec_payroll IN csr_payrolls(l_business_group_id,
                                    l_end_year)
    LOOP
      hr_utility.set_location(l_proc||' '||rec_payroll.payroll_name,20);
      l_payroll_name := rec_payroll.payroll_name;
      -- find payroll year info
      OPEN csr_payroll_year (rec_payroll.payroll_id,l_start_year,l_end_year);
      FETCH csr_payroll_year INTO   l_payroll_start_year,
                                    l_payroll_end_year,
                                    l_payroll_period_type,
                                    l_payroll_max_period_number;
      CLOSE csr_payroll_year;
      --
      l_another_paye_ref := NULL;
      OPEN csr_another_paye_ref(rec_payroll.payroll_id,
                                l_end_year,
                                rec_payroll.emp_paye_ref);
      FETCH csr_another_paye_ref INTO l_another_paye_ref;
      IF csr_another_paye_ref%FOUND THEN
         hr_utility.trace('After csr_another_paye_ref, l_another_paye_ref='||
                             l_another_paye_ref);
         CLOSE csr_another_paye_ref;
         RAISE inconsis_ref_error;
      ELSE
         CLOSE csr_another_paye_ref;
         hr_utility.trace('No other paye ref found on the payroll.');
      END IF;
      --
      -- Call API to archive Data via cover procedure
/* Start 4011263
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_ssp_recovered_eid,rec_payroll.ssp_recovered);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_smp_compensation_eid,
                           rec_payroll.smp_compensation);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_smp_recovered_eid,
                           rec_payroll.smp_recovered);
--
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_sap_compensation_eid,
                           rec_payroll.sap_compensation);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_sap_recovered_eid,
                           rec_payroll.sap_recovered);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_spp_compensation_eid,
                           rec_payroll.spp_compensation);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_spp_recovered_eid,
                           rec_payroll.spp_recovered);
   End 4011263 */
--

      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_econ_eid,rec_payroll.econ);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_employers_address_line_eid,
                           rec_payroll.employers_address_line);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_employers_name_eid,
                           rec_payroll.employers_name);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_tax_district_name_eid,
                           rec_payroll.tax_district_name);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_tax_reference_eid,
                           rec_payroll.tax_reference);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_tax_district_reference_eid,
                           rec_payroll.tax_district_reference);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_payroll_name_eid,
                           rec_payroll.payroll_name);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_permit_number_eid,
                           rec_payroll.permit_number);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_max_period_number_eid,
                           l_payroll_max_period_number);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_payroll_period_type_eid,
                           l_payroll_period_type);
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_payroll_end_year_eid,
                           fnd_date.date_to_canonical(l_payroll_end_year));
      archive_payroll_info(pactid, rec_payroll.payroll_id,
                           l_payroll_start_year_eid,
                           fnd_date.date_to_canonical(l_payroll_start_year));
    END LOOP;
  EXCEPTION
    -- Propagate error through by means of the X_PAYROLL_ACTION_MESSAGE UE.
    -- Start of BUG 5909829 EOY
    --
    WHEN test_indicator_error THEN
      l_payroll_action_message :=
        'You must provide a Unique Test ID if the EDI Test Indicator is Yes.';
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => l_payroll_action_message_eid,
         p_archive_value    => l_payroll_action_message,
         p_archive_type     => 'PA',
         p_action_id        => pactid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
     RAISE;  -- reraise the error
     --
     -- End of BUG 5909829 EOY
     --
    WHEN tax_dist_ref_error THEN
      l_payroll_action_message :=
        'Invalid Format for Tax District Reference: Must be three numerics';
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => l_payroll_action_message_eid,
         p_archive_value    => l_payroll_action_message,
         p_archive_type     => 'PA',
         p_action_id        => pactid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
      RAISE;  -- reraise the error
    --
    WHEN inconsis_ref_error THEN
      l_payroll_action_message :=
        'More than one PAYE Ref found on payroll '||l_payroll_name||
        ' in the tax year.';
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => l_payroll_action_message_eid,
         p_archive_value    => l_payroll_action_message,
         p_archive_type     => 'PA',
         p_action_id        => pactid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
      --
      l_dummy := write_output(p_assignment_number => NULL,
                       p_full_name => NULL,
                       p_message_type => 'E',
                       p_message => l_payroll_action_message);

      RAISE;  -- reraise the error
    --
    WHEN OTHERS THEN
      -- Write to the conc logfile, and try to archive err msg.
      fnd_file.put_line(fnd_file.log, substr(sqlerrm(sqlcode),1,80));
      l_payroll_action_message := substr('Payroll Extract failed with: '||
                                         sqlerrm(sqlcode),1,240);
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => l_payroll_action_message_eid,
         p_archive_value    => l_payroll_action_message,
         p_archive_type     => 'PA',
         p_action_id        => pactid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
      RAISE;  -- reraise the error
      --
  END; -- Payroll Extract
  --
  -- return range cursor
  --
  -- select all people in the BG, filter out non appropriate ones in
  -- action_creation procedure.
  hr_utility.set_location(l_proc,30);
  -- sqlstr must contain one and only one entry of :payroll_action_id
  -- it must be ordered by person_id
  --
  sqlstr := 'SELECT DISTINCT person_id
    FROM  per_all_people_f ppf,
          pay_payroll_actions ppa
    WHERE ppa.payroll_action_id = :payroll_action_id
    AND   ppa.business_group_id +0= ppf.business_group_id
    ORDER BY ppf.person_id';
  hr_utility.set_location('Leaving:  '||l_proc,40);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location(' Leaving: '||l_proc,50);
    fnd_file.put_line(fnd_file.log,
        substr('Error in rangecode '||sqlerrm(sqlcode),1,80));
    -- Return cursor that selects no rows
    sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
END range_cursor;
--
--
PROCEDURE action_creation(pactid IN NUMBER,
                          stperson IN NUMBER,
                          endperson IN NUMBER,
                          chunk IN NUMBER) IS
  --
  l_proc             CONSTANT VARCHAR2(35):= g_package||'action_creation';
  --
  l_actid                  pay_assignment_actions.assignment_action_id%TYPE;
  -- vars for returns from the API:
  l_archive_item_id           ff_archive_items.archive_item_id%TYPE;
  l_ovn                       NUMBER;
  l_some_warning              BOOLEAN;
  --
  l_start_year_date        DATE;
  --
  l_payroll_start_date      DATE;
  l_payroll_end_date        DATE;
  l_process_asg             BOOLEAN;
  --
  cursor csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'PERMIT'),1,12) permit,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TAX_REF'),1,3) tax_dist,
    substr(ltrim(substr(pay_gb_eoy_archive.get_parameter(
        legislative_parameters,'TAX_REF'),4,11),'/'),1,10) tax_ref, --4011263
    effective_date end_year,
    business_group_id,
    ltrim(substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'ASG_SET'),1,80)) asg_set
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
    FROM   ff_user_entities
   WHERE  user_entity_name = p_entity_name
     AND  legislation_code = 'GB'
     AND  business_group_id IS NULL;
  --
  cursor csr_context_id(c_context_name in varchar2) is
  select context_id
  from ff_contexts
  where context_name = c_context_name;
  --
  cursor csr_sub_asg ( p_asg_rowid              varchar2,
                      p_start_date             date,
                      p_end_date               date,
                      pactid                   number,
                      p_start_year_eid         number,
                      p_payroll_end_year_eid   number
                     ) is
  SELECT 1 valid_asg
  FROM   per_all_assignments_f paf
  WHERE  paf.rowid = chartorowid(p_asg_rowid)
  AND    paf.effective_end_date >= p_start_date
  AND    paf.effective_start_date <= p_end_date
  AND NOT EXISTS (select 1
     from  per_all_assignments_f paf2
     where paf2.assignment_id = paf.assignment_id
       AND    paf2.effective_end_date > paf.effective_end_date
       AND    paf2.effective_end_date >=
                      fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str
                      (pactid, p_start_year_eid,to_char(paf2.payroll_id)))
       AND    paf2.effective_start_date <=
                 fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str
                      (pactid, p_payroll_end_year_eid, to_char(paf2.payroll_id))));
--
  cursor csr_assignments ( p_min_start_year_date        DATE,
                          p_max_end_year_date          DATE,
                          p_end_date               DATE,
                          p_bg_id                  NUMBER,
                          p_permit                 VARCHAR2,
                          p_tax_dist_ref           VARCHAR2,
                          p_tax_ref                VARCHAR2,
                          p_start_year_eid         NUMBER,
                          p_end_year_eid   NUMBER,
                          p_asg_set_id     NUMBER
                         ) IS
  -- select all the assignments for a particular permit
  -- note we only want the last date effective row - the permit on the
  -- payroll for this dictates where it is reported even if the assignment
  -- has been on more than one payroll in the year. The exception to this
  -- is where tax district/reference transfers have occurred
  -- find the latest assignment row this payroll year
  -- add any assignment rows that are for tax reference changes
  -- pick up latest effective end date and latest payroll
  -- don't pick up null permits (such payroll would not have been archived)
  -- and if ni y is not reportable only pick up
  -- current year assignments
  -- after transfer
  -- Select using less stringent criteria then validate the
  -- rows before archiving. Performance issue with functions in where clause.
  -- Add Ordered Index Hints for CBO issue.
  -- added p_asg_set_id and usage of hr_assignment_sets (and _amendments) tables
  SELECT /*+ ORDERED INDEX (asg PER_ASSIGNMENTS_F_N12,
                            ppf PAY_PAYROLLS_F_PK,
                            flex HR_SOFT_CODING_KEYFLEX_PK,
                            org HR_ORGANIZATION_INFORMATIO_FK1,
                            per PER_PEOPLE_F_PK)
             USE_NL(asg,ppf,flex,org,per) */
    asg.assignment_id,
    asg.effective_start_date,
    asg.effective_end_date,
    asg.person_id,
    asg.period_of_service_id, -- added for bug 3784871
    pay_gb_eoy_archive.get_agg_active_start(asg.assignment_id, flex.segment1, p_end_date) agg_active_start,
    pay_gb_eoy_archive.get_agg_active_end(asg.assignment_id, flex.segment1, p_end_date) agg_active_end,
    asg.payroll_id,
    substr(ltrim(substr(org_information1,4,11),'/') ,1,10) tax_ref, -- 4011263
    decode(per.per_information9,'Y','Y',NULL) multiple_asg_flag,
    rowidtochar(asg.ROWID) charrowid,
    'N' tax_ref_xfer
  FROM  per_all_assignments_f       asg,
        pay_all_payrolls_f              ppf,
        hr_soft_coding_keyflex      flex,
        hr_organization_information org,
        per_all_people_f            per
  WHERE asg.person_id BETWEEN stperson AND endperson
    AND asg.business_group_id +0 = p_bg_id
    AND asg.effective_end_date >= p_min_start_year_date
    AND asg.effective_start_date <= p_max_end_year_date
    AND asg.payroll_id = ppf.payroll_id
    AND asg.period_of_service_id is not null
    AND p_end_date BETWEEN ppf.effective_start_date
                       AND ppf.effective_end_date
    AND ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
    AND org.organization_id +0 = p_bg_id
    AND org.org_information_context =
                 'Tax Details References'||decode(flex.segment1,'','','')
    AND org.org_information1 = flex.segment1
    AND nvl(org.org_information10,'UK') = 'UK'
    AND nvl(p_permit,substr(flex.segment10,1,12)) =
                                      substr(flex.segment10,1,12)
    AND nvl(p_tax_dist_ref, substr(flex.segment1,1,3)) =
                                      substr(flex.segment1,1,3)
    AND nvl(p_tax_ref, substr(ltrim(substr(org_information1,4,11),'/') ,1,10))
                   = substr(ltrim(substr(org_information1,4,11),'/') ,1,10)
    AND per.person_id = asg.person_id
    AND p_end_date BETWEEN per.effective_start_date
                       AND per.effective_end_date
    AND (p_asg_set_id IS NULL -- don't check for assignment set in this case
         OR EXISTS (SELECT 1 FROM hr_assignment_sets has1
                    WHERE has1.assignment_set_id = p_asg_set_id
                    AND has1.business_group_id = asg.business_group_id
                    AND nvl(has1.payroll_id, asg.payroll_id) = asg.payroll_id
                    AND (NOT EXISTS (SELECT 1 -- chk no amendmts
                                     FROM hr_assignment_set_amendments hasa1
                                     WHERE hasa1.assignment_set_id =
                                               has1.assignment_set_id)
                         OR EXISTS (SELECT 1 -- chk include amendmts
                                    FROM hr_assignment_set_amendments hasa2
                                    WHERE hasa2.assignment_set_id =
                                               has1.assignment_set_id
                                    AND hasa2.assignment_id = asg.assignment_id
                                    AND nvl(hasa2.include_or_exclude,'I') = 'I')
                         OR (NOT EXISTS (SELECT 1 --chk no exlude amendmts
                                    FROM hr_assignment_set_amendments hasa3
                                    WHERE hasa3.assignment_set_id =
                                               has1.assignment_set_id
                                    AND hasa3.assignment_id = asg.assignment_id
                                    AND nvl(hasa3.include_or_exclude,'I') = 'E')
                             AND NOT EXISTS (SELECT 1 --and chk no Inc amendmts
                                    FROM hr_assignment_set_amendments hasa4
                                    WHERE hasa4.assignment_set_id =
                                               has1.assignment_set_id
                                    AND nvl(hasa4.include_or_exclude,'I') = 'I')                             ) -- end checking exclude amendmts
                         ) -- done checking amendments
                    ) -- done asg set check when not null
           ) -- end of asg set check
  UNION
  SELECT /*+ ORDERED INDEX (PASS PER_ASSIGNMENTS_F_N12,
                            ASS PER_ASSIGNMENTS_F_PK,
                            NROLL PAY_PAYROLLS_F_PK,
                            FLEX HR_SOFT_CODING_KEYFLEX_PK,
                            PROLL PAY_PAYROLLS_F_PK,
                            pflex HR_SOFT_CODING_KEYFLEX_PK,
                            per PER_PEOPLE_F_PK)
             USE_NL(PASS,ASS,NROLL,FLEX,PROLL,pflex,per) */
    pass.assignment_id,
    pass.effective_start_date,
    pass.effective_end_date,
    pass.person_id,
    pass.period_of_service_id, -- added for bug 3784871
    pay_gb_eoy_archive.get_agg_active_start(pass.assignment_id, pflex.segment1, p_end_date) agg_active_start,
    pay_gb_eoy_archive.get_agg_active_end(pass.assignment_id, pflex.segment1, p_end_date) agg_active_end,
    pass.payroll_id,
    substr(ltrim(substr(pflex.segment1,4,11),'/') ,1,10) tax_ref, -- 4011263
    decode(per.per_information9,'Y','Y',NULL) multiple_asg_flag,
    rowidtochar(pass.rowid) charrowid,
    'Y' tax_ref_xfer
  FROM
           per_all_people_f  per
          ,per_all_assignments_f      PASS
          ,per_all_assignments_f  ASS
          ,pay_all_payrolls_f         NROLL
          ,hr_soft_coding_keyflex FLEX
          ,pay_all_payrolls_f         PROLL
          ,hr_soft_coding_keyflex pflex
  WHERE  NROLL.payroll_id = ASS.payroll_id
  AND    ASS.effective_start_date between
                  NROLL.effective_start_date and NROLL.effective_end_date
  AND    NROLL.soft_coding_keyflex_id = FLEX.soft_coding_keyflex_id
  AND    ASS.assignment_id = PASS.assignment_id
  AND    ASS.period_of_service_id is not null
  AND    PASS.effective_end_date = (ASS.effective_start_date - 1)
  AND    PROLL.payroll_id = PASS.payroll_id
  AND    PER.person_id BETWEEN stperson AND endperson
  AND    pass.business_group_id +0 = p_bg_id
  AND    pass.effective_end_date >= p_min_start_year_date
  AND    pass.effective_start_date <= p_max_end_year_date
  AND    ASS.effective_start_date between
                  PROLL.effective_start_date AND PROLL.effective_end_date
  AND    PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
  AND    ASS.payroll_id <> PASS.payroll_id
  AND    FLEX.segment1 <> PFLEX.segment1
  AND    nvl(p_permit,substr(pflex.segment10,1,12)) =
                                      substr(pflex.segment10,1,12)
  AND    nvl(p_tax_dist_ref, substr(pflex.segment1,1,3)) =
                                      substr(pflex.segment1,1,3)
  AND    nvl(p_tax_ref, substr(ltrim(substr(pflex.segment1,4,11),'/') ,1,10))
                   = substr(ltrim(substr(pflex.segment1,4,11),'/') ,1,10)
  AND    per.person_id = pass.person_id
  AND    p_end_date  BETWEEN per.effective_start_date
                         AND per.effective_end_date
    AND (p_asg_set_id IS NULL -- don't check for assignment set in this case
         OR EXISTS (SELECT 1 FROM hr_assignment_sets has1
                    WHERE has1.assignment_set_id = p_asg_set_id
                    AND has1.business_group_id = pass.business_group_id
                    AND nvl(has1.payroll_id, pass.payroll_id) = pass.payroll_id
                    AND (NOT EXISTS (SELECT 1 -- chk no amendmts
                                     FROM hr_assignment_set_amendments hasa1
                                     WHERE hasa1.assignment_set_id =
                                               has1.assignment_set_id)
                         OR EXISTS (SELECT 1 -- chk include amendmts
                                    FROM hr_assignment_set_amendments hasa2
                                    WHERE hasa2.assignment_set_id =
                                               has1.assignment_set_id
                                    AND hasa2.assignment_id = pass.assignment_id
                                    AND nvl(hasa2.include_or_exclude,'I') = 'I')
                         OR (NOT EXISTS (SELECT 1 --chk no exlude amendmts
                                    FROM hr_assignment_set_amendments hasa3
                                    WHERE hasa3.assignment_set_id =
                                               has1.assignment_set_id
                                    AND hasa3.assignment_id = pass.assignment_id
                                    AND nvl(hasa3.include_or_exclude,'I') = 'E')
                             AND NOT EXISTS (SELECT 1 --and chk no Inc amendmts
                                    FROM hr_assignment_set_amendments hasa4
                                    WHERE hasa4.assignment_set_id =
                                               has1.assignment_set_id
                                    AND nvl(hasa4.include_or_exclude,'I') = 'I')
                             ) -- end checking exclude amendmts
                         ) -- done checking amendments
                    ) -- done asg set check when not null
           ) -- end of asg set check
  ORDER BY 4,5,6,7,8,1,3 desc;
  --
  rec_assignment csr_assignments%ROWTYPE;
  rec_prev_asg   csr_assignments%ROWTYPE;
  --
BEGIN
  IF chunk = 1 THEN
    NULL;
    --hr_utility.trace_on(NULL,'EOY_CHUNK1');
  END IF;
  --hr_utility.trace_on(NULL,'RMEOYAC');
  hr_utility.set_location('Entering: '||l_proc,1);
  -- Setup info and ids if new session.
  -- DO NOT set g_payroll_action_id here as archinit() may stop working
  IF g_context_id IS NULL THEN
    OPEN csr_parameter_info(pactid);
    FETCH csr_parameter_info INTO g_permit_number,
                                  g_tax_district_reference,
                                  g_tax_reference_number,
                                  g_end_year,
                                  g_business_group_id,
                                  g_asg_set_id;
    CLOSE csr_parameter_info;
    --
    OPEN csr_user_entity('X_START_YEAR');
    FETCH csr_user_entity INTO g_payroll_start_year_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_END_YEAR');
    FETCH csr_user_entity INTO g_payroll_end_year_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERMIT_NUMBER');
    FETCH csr_user_entity INTO g_permit_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_DISTRICT_REFERENCE');
    FETCH csr_user_entity INTO g_tax_dist_ref_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REFERENCE_NUMBER');
    FETCH csr_user_entity INTO g_tax_ref_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LAST_MULTI_ASG_PER_PERSON_TAX_REF');
    FETCH csr_user_entity INTO g_last_multi_asg_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EFFECTIVE_END_DATE');
    FETCH csr_user_entity INTO g_effective_end_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REF_TRANSFER');
    FETCH csr_user_entity INTO g_tax_ref_transfer_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_AGG_ACTIVE_START');
    FETCH csr_user_entity INTO g_agg_active_start_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_AGG_ACTIVE_END');
    FETCH csr_user_entity INTO g_agg_active_end_eid;
    CLOSE csr_user_entity;
    --
    OPEN  csr_context_id('PAYROLL_ID');
    FETCH csr_context_id INTO g_context_id;
    CLOSE csr_context_id;
    --
    hr_utility.set_location(l_proc,10);
    --
    cache_archive_value(p_payroll_action_id => pactid,
                        p_end_yr_ueid       => g_payroll_end_year_eid,
                        p_start_yr_ueid     => g_payroll_start_year_eid,
                        p_tax_ref_ueid      => g_tax_ref_eid,
                        p_tax_dist_ueid     => g_tax_dist_ref_eid,
                        p_permit_ueid       => g_permit_number_eid);
    --
  END IF; -- g_context_id IS NULL
  hr_utility.set_location(l_proc,13);
  --
  -- set asg backup details to unlikely values before loop.
  rec_prev_asg.assignment_id      := hr_api.g_number;
  rec_prev_asg.effective_end_date := hr_api.g_date;
  -- loop through assignments
  OPEN csr_assignments ( g_min_start_year,
                        g_max_end_year,
                        g_end_year,
                        g_business_group_id,
                        g_permit_number,
                        g_tax_district_reference,
                        g_tax_reference_number,
                        g_payroll_start_year_eid,
                        g_payroll_end_year_eid,
                        g_asg_set_id);
  LOOP
    FETCH csr_assignments INTO rec_assignment;
    hr_utility.trace(l_proc||' Fetched assignment_id='||
         rec_assignment.assignment_id||', g_asg_set_id='||g_asg_set_id);
    l_process_asg := FALSE;
    l_payroll_start_date :=
         fnd_date.canonical_to_date(pay_gb_eoy_archive.get_cached_value
                              (pactid,'X_START_YEAR',
                               to_char(rec_assignment.payroll_id)));
    hr_utility.trace(l_proc||' l_payroll_start_date='||fnd_date.date_to_displaydate(l_payroll_start_date));
    l_payroll_end_date :=
         fnd_date.canonical_to_date(pay_gb_eoy_archive.get_cached_value
                          (pactid,'X_END_YEAR',
                           to_char(rec_assignment.payroll_id)));
    hr_utility.trace(l_proc||' l_payroll_end_date='||fnd_date.date_to_displaydate(l_payroll_end_date));
    hr_utility.trace(l_proc||' tax_ref_xfer='||rec_assignment.tax_ref_xfer);
    IF nvl(rec_assignment.tax_ref_xfer,' ') = 'N' AND csr_assignments%FOUND
    THEN
      hr_utility.trace(l_proc||' opening cursor csr_sub_asg.');
      for asgrec in csr_sub_asg( rec_assignment.charrowid,
                                l_payroll_start_date,
                                l_payroll_end_date,
                                pactid,
                                g_payroll_start_year_eid,
                                g_payroll_end_year_eid
                                ) loop
        hr_utility.trace(l_proc||' In the loop for cursor csr_sub_asg.');
        l_process_asg := TRUE;
      end loop;
    ELSIF nvl(rec_assignment.tax_ref_xfer,' ') = 'Y' AND csr_assignments%FOUND
    THEN
      hr_utility.trace(l_proc||' tax ref xfer=Y and found record by csr_assignments cursor.');
      hr_utility.trace(l_proc||' rec_assignment.effective_end_date='||fnd_date.date_to_displaydate(rec_assignment.effective_end_date));
      hr_utility.trace(l_proc||' rec_assignment.effective_start_date='||fnd_date.date_to_displaydate(rec_assignment.effective_start_date));
      IF rec_assignment.effective_end_date >= l_payroll_start_date
        AND rec_assignment.effective_start_date <= l_payroll_end_date
      THEN
        l_process_asg := TRUE;
      END IF;
    ELSE
      -- will come here if csr_assignments%NOTFOUND
      l_process_asg := TRUE;
    end if;
    hr_utility.trace(l_proc||' rec_assignment.person_id='||rec_assignment.person_id);
    hr_utility.trace(l_proc||' rec_prev_asg.person_id='||rec_prev_asg.person_id);
    hr_utility.trace(l_proc||' rec_assignment.period_of_service_id='||rec_assignment.period_of_service_id);
    hr_utility.trace(l_proc||' rec_prev_asg.period_of_service_id='||rec_prev_asg.period_of_service_id);
    hr_utility.trace(l_proc||' rec_assignment.agg_active_start='||fnd_date.date_to_displaydate(rec_assignment.agg_active_start));
    hr_utility.trace(l_proc||' rec_prev_asg.agg_active_start='||fnd_date.date_to_displaydate(rec_prev_asg.agg_active_start));
    hr_utility.trace(l_proc||' rec_assignment.agg_active_end='||fnd_date.date_to_displaydate(rec_assignment.agg_active_end));
    hr_utility.trace(l_proc||' rec_prev_asg.agg_active_end='||fnd_date.date_to_displaydate(rec_prev_asg.agg_active_end));
    hr_utility.trace(l_proc||' rec_assignment.tax_ref='||rec_assignment.tax_ref);
    hr_utility.trace(l_proc||' rec_prev_asg.tax_ref='||rec_prev_asg.tax_ref);
    IF (csr_assignments%NOTFOUND
        OR rec_assignment.person_id <> rec_prev_asg.person_id
        OR rec_assignment.period_of_service_id <> rec_prev_asg.period_of_service_id -- Added to fix bug 3784871
        OR rec_assignment.agg_active_start <> rec_prev_asg.agg_active_start
        OR rec_assignment.agg_active_end <> rec_prev_asg.agg_active_end
        OR rec_assignment.tax_ref   <> rec_prev_asg.tax_ref)
      AND csr_assignments%rowcount > 0
      AND rec_prev_asg.multiple_asg_flag = 'Y'
      AND l_process_asg
      -- If the person or Tax ref has changed or the last row has been
      -- fetched, and the last action created was for a multi-asg person
      -- and this
    THEN
      -- archive the X_LAST_MULTI_ASG_PER_PERSON_TAX_REF DBI against
      -- the last action created to indicate that it was the last asg
      -- for that person/tax ref group.
      -- first row will not come here due to null trap with
      -- rec_prev_asg.multiple_asg_flag
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => g_last_multi_asg_eid,
         p_archive_value    => 'Y',
         p_archive_type     => 'AAC',
         p_action_id        => l_actid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
    END IF;
    EXIT WHEN csr_assignments%NOTFOUND;
    hr_utility.set_location(l_proc,15);
    hr_utility.trace(l_proc||' rec_assignment.assignment_id='||rec_assignment.assignment_id);
    hr_utility.trace(l_proc||' rec_prev_asg.assignment_id='||rec_prev_asg.assignment_id);
    hr_utility.trace(l_proc||' rec_assignment.effective_end_date='||fnd_date.date_to_displaydate(rec_assignment.effective_end_date));
    hr_utility.trace(l_proc||' rec_prev_asg.effective_end_date='||fnd_date.date_to_displaydate(rec_prev_asg.effective_end_date));
    IF (rec_assignment.assignment_id <> rec_prev_asg.assignment_id
      OR rec_assignment.effective_end_date <> rec_prev_asg.effective_end_date)
      AND l_process_asg
      -- if the current row is the first row
      -- or is not the same as the previous one
      --  (ignoring tax_ref_xfer) as the 2nd part of union may bring back
      -- duplicates
    THEN
      hr_utility.set_location(l_proc,20);
      -- insert an action
      SELECT pay_assignment_actions_s.nextval
        INTO l_actid
        FROM dual;
      --
      hr_nonrun_asact.insact(l_actid,rec_assignment.assignment_id,
                             pactid,chunk,NULL);
      -- archive the effective end date
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => g_effective_end_date_eid,
         p_archive_value    => fnd_date.date_to_canonical
                                (rec_assignment.effective_end_date),
         p_archive_type     => 'AAC',
         p_action_id        => l_actid,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
      -- If tax_ref_xfer is Y, archive the X_TAX_REF_TRANSFER DBI
      IF rec_assignment.tax_ref_xfer = 'Y' THEN
        ff_archive_api.create_archive_item
          (p_archive_item_id  => l_archive_item_id,
           p_user_entity_id   => g_tax_ref_transfer_eid,
           p_archive_value    => 'Y',
           p_archive_type     => 'AAC',
           p_action_id        => l_actid,
           p_legislation_code => 'GB',
           p_object_version_number => l_ovn,
           p_some_warning     => l_some_warning);
      END IF;
      -- If multiple assignments aggregated then archive first and last active
      -- or suspended status start and end dates amongst aggregated asgs
      IF rec_assignment.multiple_asg_flag = 'Y' THEN
        ff_archive_api.create_archive_item
          (p_archive_item_id  => l_archive_item_id,
           p_user_entity_id   => g_agg_active_start_eid,
           p_archive_value    => fnd_date.date_to_canonical(rec_assignment.agg_active_start),
           p_archive_type     => 'AAC',
           p_action_id        => l_actid,
           p_legislation_code => 'GB',
           p_object_version_number => l_ovn,
           p_some_warning     => l_some_warning);
           --
        ff_archive_api.create_archive_item
          (p_archive_item_id  => l_archive_item_id,
           p_user_entity_id   => g_agg_active_end_eid,
           p_archive_value    => fnd_date.date_to_canonical(rec_assignment.agg_active_end),
           p_archive_type     => 'AAC',
           p_action_id        => l_actid,
           p_legislation_code => 'GB',
           p_object_version_number => l_ovn,
           p_some_warning     => l_some_warning);
           --
      END IF;
      -- Backup the current row.
      rec_prev_asg := rec_assignment;
    END IF; -- not duplicate
  END LOOP;
  CLOSE csr_assignments;
--  hr_utility.trace_off;
  hr_utility.set_location('Leaving:  '||l_proc,40);
END action_creation;
--
--
PROCEDURE archinit(p_payroll_action_id IN NUMBER) IS
  --
  l_proc             CONSTANT VARCHAR2(35):= g_package||'archinit';
  --
  l_payroll_start_year        DATE;
  l_payroll_end_year          DATE;
  l_payroll_period_type       VARCHAR2(30);
  l_payroll_max_period_number NUMBER;
  l_payroll_tax_ref           VARCHAR2(10);
  l_payroll_tax_dist          VARCHAR2(10);
  l_payroll_id            pay_all_payrolls_f.payroll_id%TYPE;
  l_number_per_fiscal_yr      NUMBER;
  --
  -- get the defined balance id for specified balance and dimension
  cursor get_defined_balance_id
    (p_balance_name VARCHAR2, p_dimension_name VARCHAR2) IS
  SELECT defined_balance_id
    FROM pay_defined_balances db,
         pay_balance_types    b,
         pay_balance_dimensions d
    WHERE b.balance_name = p_balance_name
    AND   d.dimension_name = p_dimension_name
    AND   db.balance_type_id = b.balance_type_id
    AND   db.balance_dimension_id = d.balance_dimension_id;
  --
  -- Start of BUG 5671777-5
  -- Changed start date of the EOY process to reflect start of the current tax year
  -- so need to add 12 months to the start date.
  --
  cursor csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT
     to_date('06/04/'||to_char(start_date,'YYYY'),'dd/mm/yyyy')
  -- add_months(to_date('06/04/'||to_char(start_date,'YYYY'),'dd/mm/yyyy'),12)
  -- End of BUG 5671777-5
         start_year,
    effective_date end_year,
    business_group_id,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'PERMIT'),1,12) permit,
    substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TAX_REF'),1,3) tax_dist,
    substr(ltrim(substr(pay_gb_eoy_archive.get_parameter(
        legislative_parameters,'TAX_REF'),4,11),'/'),1,10) tax_ref --4011263
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  cursor csr_user_entity(p_entity_name VARCHAR2) IS
  SELECT user_entity_id
    FROM   ff_user_entities
   WHERE  user_entity_name = p_entity_name
     AND  legislation_code = 'GB'
     AND  business_group_id IS NULL;
  --
  cursor csr_period_type_info(p_period_type VARCHAR2) IS
  SELECT ptpt.number_per_fiscal_year
  FROM  per_time_period_types ptpt
  WHERE p_period_type  = ptpt.period_type;
  --
  cursor csr_payroll_info(p_pactid NUMBER) IS
  SELECT
    to_number(aic.context) payroll_id,
    fnd_date.canonical_to_date(fai.VALUE) start_year,
    fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str(fai.context1,
      g_payroll_end_year_eid,
      aic.context)) end_year,
    pay_gb_eoy_archive.get_arch_str(fai.context1,g_payroll_period_type_eid,
                                    aic.context) period_type,
    to_number(pay_gb_eoy_archive.get_arch_str(fai.context1,
      g_max_period_number_eid, aic.context)) max_period_number,
    pay_gb_eoy_archive.get_arch_str(fai.context1,g_tax_ref_eid,
                                    aic.context) tax_ref,
    pay_gb_eoy_archive.get_arch_str(fai.context1,g_tax_dist_ref_eid,
                                    aic.context) tax_dist
  FROM  ff_archive_item_contexts aic,  /* payrolls */
        ff_archive_items         fai,  /* X_START_YEAR */
        ff_user_entities         fue,
        pay_payroll_actions      pact
  WHERE pact.report_type       = 'EOY'
    AND pact.report_qualifier  = 'GB'
    AND pact.action_type       = 'X'
    AND pact.payroll_action_id = fai.context1
    AND fue.user_entity_name   = 'X_START_YEAR'
    AND fue.legislation_code   = 'GB'
    AND fue.business_group_id  IS NULL
    AND fue.user_entity_id     = fai.user_entity_id
    AND aic.archive_item_id    = fai.archive_item_id
    AND aic.sequence_no        = 1
    AND pact.payroll_action_id = p_pactid;
  --
  CURSOR get_retry_actions IS
  SELECT act.assignment_action_id, act.action_status
  FROM pay_assignment_actions act
  WHERE act.payroll_action_id = p_payroll_action_id
  AND   act.action_status = 'M';
  --
  CURSOR get_agg_non_retry_actions(p_asg_act_id NUMBER) IS
  SELECT act2.assignment_action_id, asg2.assignment_number, asg1.assignment_number retry_asg_number, pap.full_name, act2.action_status
  FROM   pay_assignment_actions act1,
         pay_assignment_actions act2,
         per_all_assignments_f asg1,
         per_all_assignments_f asg2,
         per_all_people_f pap
  WHERE  act1.assignment_action_id = p_asg_act_id
  AND    act1.assignment_id = asg1.assignment_id
  AND    asg1.person_id = pap.person_id
  AND    g_end_year between pap.effective_start_date and pap.effective_end_date
  AND    pap.person_id = asg2.person_id
  AND    asg2.assignment_id = act2.assignment_id
  AND    act2.payroll_action_id = act1.payroll_action_id
  AND    asg2.assignment_id <> asg1.assignment_id
  AND    (pap.per_information10 = 'Y'    -- Agg PAYE
          OR pap.per_information9 = 'Y') -- NI Muti Asg
  AND    act2.action_status <> 'M';
  --
  l_agg_non_retry_err_flag VARCHAR2(1) := 'N';
  --
  l_dummy NUMBER := 0;
BEGIN
 -- hr_utility.trace_on(NULL,'ARCHINIT');
  hr_utility.set_location('Entering: '||l_proc,1);
  --
  IF g_payroll_action_id IS NULL
  OR g_payroll_action_id <> p_payroll_action_id THEN
    g_payroll_action_id := p_payroll_action_id;
    g_masg_person_id   := nvl(g_masg_person_id,hr_api.g_number);
    g_masg_period_of_service_id := nvl(g_masg_period_of_service_id, hr_api.g_number); -- Bug 3784871
    g_masg_active_start := nvl(g_masg_active_start, hr_api.g_sot);
    g_masg_active_end := nvl(g_masg_active_end, hr_api.g_eot);
    g_masg_tax_ref_num := nvl(g_masg_tax_ref_num,
                              substr(hr_api.g_varchar2,1,10)); -- 4011263: substr to 10 chars
    --      set up the statutory start and end year
    OPEN csr_parameter_info(p_payroll_action_id);
    FETCH csr_parameter_info INTO g_start_year,
                                  g_end_year,
                                  g_business_group_id,
                                  g_permit_number,
                                  g_tax_district_reference,
                                  g_tax_reference_number;
    CLOSE csr_parameter_info;
    --
    l_agg_non_retry_err_flag := 'N';
    FOR retry_actions_rec IN get_retry_actions LOOP
    --
       hr_utility.trace(l_proc||': retry action id='||
                retry_actions_rec.assignment_action_id);
       hr_utility.trace(l_proc||': retry action status='||
                retry_actions_rec.action_status);
       --
       FOR non_retry_act_rec IN get_agg_non_retry_actions(retry_actions_rec.assignment_action_id) LOOP
          --
          hr_utility.trace(l_proc||': non_retry_act_rec.assignment_action_id='||
                       non_retry_act_rec.assignment_action_id);
          hr_utility.trace(l_proc||': non_retry_act_rec.assignment_number='||
                       non_retry_act_rec.assignment_number);
          hr_utility.trace(l_proc||': non_retry_act_rec.retry_asg_number='||
                       non_retry_act_rec.retry_asg_number);
          hr_utility.trace(l_proc||': non_retry_act_rec.full_name='||
                       non_retry_act_rec.full_name);
          l_agg_non_retry_err_flag := 'Y';
          l_dummy := write_output(p_assignment_number => non_retry_act_rec.retry_asg_number,
                       p_full_name => non_retry_act_rec.full_name,
                       p_message_type => 'E',
                       p_message => 'Assignment action '||non_retry_act_rec.assignment_action_id||' for the aggrgated assignment '||non_retry_act_rec.assignment_number||' must be marked for retry.');
         END LOOP;
    END LOOP;
    --
    hr_utility.trace(l_proc||' After get_agg_non_retry_actions, l_agg_non_retry_err_flag='||l_agg_non_retry_err_flag);
    --
    IF l_agg_non_retry_err_flag = 'Y' THEN
       --  Raise the error and stop processing the assignments marked for retry
       -- because aggregated assignment(s) has(have) not been marked for retry.
       app_exception.raise_exception;
    END IF;
    --      find the defined balance id's for balance / dimension combos
    OPEN get_defined_balance_id('NI A Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_able_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI A Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI A Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI A Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI A Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI A Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 begin
    OPEN get_defined_balance_id('NI A Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 end
    OPEN get_defined_balance_id('NI A Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nia_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI B Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_able_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI B Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI B Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI B Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI B Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI B Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 begin
    OPEN get_defined_balance_id('NI B Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 end
    OPEN get_defined_balance_id('NI B Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nib_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI C Employer','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI C Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI C Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI C Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN get_defined_balance_id('NI C Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 End
    OPEN get_defined_balance_id('NI C Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI C Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_able_id;
    CLOSE get_defined_balance_id;
    --
    -- Fix for Bug 1976152, added the below stmt to fetch the balance id
    -- for the balance NI C Employers Rebate
    OPEN get_defined_balance_id('NI C Ers Rebate','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nic_ers_rebate_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_able_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI D Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN get_defined_balance_id('NI D Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 End
    OPEN get_defined_balance_id('NI D Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Ers Rebate','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_ers_rebate_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Ees Rebate','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_ees_rebate_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI D Rebate to Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nid_rebate_emp_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI E Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_able_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI E Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI E Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI E Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI E Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI E Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN get_defined_balance_id('NI E Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 End
    OPEN get_defined_balance_id('NI E Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI E Ers Rebate','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nie_ers_rebate_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI F Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nif_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI F Ees Rebate','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nif_ees_rebate_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI G Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nig_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI S Employer','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nis_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI J Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_able_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI J Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI J Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI J Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI J Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI J Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN get_defined_balance_id('NI J Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 End
    OPEN get_defined_balance_id('NI J Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nij_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI L Able','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_able_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI L Employee','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI L Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_tot_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI L Able LEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_lel_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI L Able UEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_uel_id;
    CLOSE get_defined_balance_id;
    -- 8357870 begin
    OPEN get_defined_balance_id('NI L Able UAP','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_uap_id;
    CLOSE get_defined_balance_id;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN get_defined_balance_id('NI L Able AUEL','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_auel_id;
    CLOSE get_defined_balance_id;
    --EOY 07/08 End
    OPEN get_defined_balance_id('NI L Able ET','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_nil_et_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('SSP Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_ssp_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('SMP Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_smp_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('SAP Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_sap_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('SPP Adoption Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_spp_adopt_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('SPP Birth Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_spp_birth_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('Gross Pay','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_gross_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('Notional Pay','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_notional_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('PAYE','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_paye_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('Superannuation Total','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_super_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('Widows and Orphans','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_widow_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('Student Loan','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_student_loan_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('Taxable Pay','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_taxable_id;
    CLOSE get_defined_balance_id;
    --
    OPEN get_defined_balance_id('NI Arrears','_ASG_TD_YTD');
    FETCH get_defined_balance_id INTO g_ni_arrears_id;
    CLOSE get_defined_balance_id;
    --
    SELECT element_type_id
    INTO   g_paye_details_id
    FROM   pay_element_types_f
    WHERE  element_name = 'PAYE Details'
      AND  g_end_year BETWEEN effective_start_date AND effective_end_date;
    --
    SELECT element_type_id
    INTO   g_paye_element_id
    FROM   pay_element_types_f
    WHERE  element_name = 'PAYE'
      AND  g_end_year BETWEEN effective_start_date AND effective_end_date;
    --
    SELECT element_type_id
    INTO   g_ni_id
    FROM   pay_element_types_f
    WHERE  element_name = 'NI'
      AND  g_end_year BETWEEN effective_start_date AND effective_end_date;
    --
    SELECT input_value_id
    INTO   g_category_input_id
    FROM   pay_input_values_f
    WHERE  name = 'Category'
      AND  element_type_id = g_ni_id
      AND  g_end_year BETWEEN effective_start_date AND effective_end_date;
    --
    SELECT input_value_id
    INTO   g_process_type_id
    FROM   pay_input_values_f
    WHERE  name = 'Process Type'
      AND  element_type_id = g_ni_id
      AND  g_end_year BETWEEN effective_start_date AND effective_end_date;
    --
    SELECT input_value_id
    INTO   g_scon_input_id
    FROM   pay_input_values_f
    WHERE  name = 'SCON'
      AND  element_type_id = g_ni_id
      AND  g_end_year BETWEEN effective_start_date AND effective_end_date;
    --
    -- Get User Entity IDs
    -- Assignment and value entities
    OPEN csr_user_entity('X_ADDRESS_LINE1');
    FETCH csr_user_entity INTO g_address_line1_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ADDRESS_LINE2');
    FETCH csr_user_entity INTO g_address_line2_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ADDRESS_LINE3');
    FETCH csr_user_entity INTO g_address_line3_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ASSIGNMENT_NUMBER');
    FETCH csr_user_entity INTO g_assignment_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_COUNTY');
    FETCH csr_user_entity INTO g_county_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_COUNTRY'); -- 4011263
    FETCH csr_user_entity INTO g_country_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_DATE_OF_BIRTH');
    FETCH csr_user_entity INTO g_date_of_birth_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_DIRECTOR_INDICATOR');
    FETCH csr_user_entity INTO g_director_indicator_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EFFECTIVE_END_DATE');
    FETCH csr_user_entity INTO g_effective_end_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EFFECTIVE_START_DATE');
    FETCH csr_user_entity INTO g_effective_start_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EOY_PRIMARY_FLAG');
    FETCH csr_user_entity INTO g_eoy_primary_flag_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_EXPENSE_CHECK_SEND_TO_ADDRESS');
    FETCH csr_user_entity INTO g_expense_check_to_address_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_FIRST_NAME');
    FETCH csr_user_entity INTO g_first_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_GROSS_PAY');
    FETCH csr_user_entity INTO g_gross_pay_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NOTIONAL_PAY');
    FETCH csr_user_entity INTO g_notional_pay_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LAST_ASG_ACTION_ID');
    FETCH csr_user_entity INTO g_last_asg_action_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LAST_EFFECTIVE_DATE');
    FETCH csr_user_entity INTO g_last_effective_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LAST_MULTI_ASG_PER_PERSON_TAX_REF');
    FETCH csr_user_entity INTO g_last_multi_asg_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_AGGREGATED_PAYE_FLAG');
    FETCH csr_user_entity INTO g_aggregated_paye_flag_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LAST_NAME');
    FETCH csr_user_entity INTO g_last_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_LOCATION_ID');
    FETCH csr_user_entity INTO g_location_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_MIDDLE_NAME');
    FETCH csr_user_entity INTO g_middle_name_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_MULTIPLE_ASG_FLAG');
    FETCH csr_user_entity INTO g_multiple_asg_flag_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NATIONAL_INSURANCE_NUMBER');
    FETCH csr_user_entity INTO g_ni_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_ABLE_ET');
    FETCH csr_user_entity INTO g_ni_able_et_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_ABLE_LEL');
    FETCH csr_user_entity INTO g_ni_able_lel_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_ABLE_UEL');
    FETCH csr_user_entity INTO g_ni_able_uel_eid;
    CLOSE csr_user_entity;
    -- 8357870 begin
    OPEN csr_user_entity('X_NI_ABLE_UAP');
    FETCH csr_user_entity INTO g_ni_able_uap_eid;
    CLOSE csr_user_entity;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN csr_user_entity('X_NI_ABLE_AUEL');
    FETCH csr_user_entity INTO g_ni_able_auel_eid;
    CLOSE csr_user_entity;
    --EOY 07/08 End
    OPEN csr_user_entity('X_NI_EARNINGS');
    FETCH csr_user_entity INTO g_ni_earnings_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_EMPLOYEES_CONTRIBUTIONS');
    FETCH csr_user_entity INTO g_ni_ees_contribution_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_EMPLOYERS_REBATE');
    FETCH csr_user_entity INTO g_ni_ers_rebate_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_EMPLOYEES_REBATE');
    FETCH csr_user_entity INTO g_ni_ees_rebate_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_EMPLOYEES_REBATE');
    FETCH csr_user_entity INTO g_ni_scon_ees_rebate_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_ABLE_ET');
    FETCH csr_user_entity INTO g_ni_scon_able_et_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_ABLE_LEL');
    FETCH csr_user_entity INTO g_ni_scon_able_lel_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_ABLE_UEL');
    FETCH csr_user_entity INTO g_ni_scon_able_uel_eid;
    CLOSE csr_user_entity;
    -- 8357870 begin
    OPEN csr_user_entity('X_NI_SCON_ABLE_UAP');
    FETCH csr_user_entity INTO g_ni_scon_able_uap_eid;
    CLOSE csr_user_entity;
    -- 8357870 end
    --EOY 07/08 Begin
    OPEN csr_user_entity('X_NI_SCON_ABLE_AUEL');
    FETCH csr_user_entity INTO g_ni_scon_able_auel_eid;
    CLOSE csr_user_entity;
    --EOY 07/08 End
    OPEN csr_user_entity('X_NI_SCON_EARNINGS');
    FETCH csr_user_entity INTO g_ni_scon_earnings_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_EMPLOYEES_CONTRIBUTIONS');
    FETCH csr_user_entity INTO g_ni_scon_ees_contribution_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_EMPLOYERS_REBATE');
    FETCH csr_user_entity INTO g_ni_scon_ers_rebate_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_TOTAL_CONTRIBUTIONS');
    FETCH csr_user_entity INTO g_ni_scon_tot_contribution_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_TOTAL_CONTRIBUTIONS');
    FETCH csr_user_entity INTO g_ni_tot_contribution_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_REFUND');
    FETCH csr_user_entity INTO g_ni_refund_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_SCON_REFUND');
    FETCH csr_user_entity INTO g_ni_scon_refund_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ORGANIZATION_ID');
    FETCH csr_user_entity INTO g_organization_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PAYROLL_ID');
    FETCH csr_user_entity INTO g_payroll_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PENSIONER_INDICATOR');
    FETCH csr_user_entity INTO g_pensioner_indicator_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PEOPLE_GROUP_ID');
    FETCH csr_user_entity INTO g_people_group_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERSON_ID');
    FETCH csr_user_entity INTO g_person_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_POSTAL_CODE');
    FETCH csr_user_entity INTO g_postal_code_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PREVIOUS_TAX_PAID');
    FETCH csr_user_entity INTO g_prev_tax_paid_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PREVIOUS_TAXABLE_PAY');
    FETCH csr_user_entity INTO g_prev_taxable_pay_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SEX');
    FETCH csr_user_entity INTO g_sex_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SMP');
    FETCH csr_user_entity INTO g_smp_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SSP');
    FETCH csr_user_entity INTO g_ssp_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SAP');
    FETCH csr_user_entity INTO g_sap_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SPP_ADOPT');
    FETCH csr_user_entity INTO g_spp_adopt_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SPP_BIRTH');
    FETCH csr_user_entity INTO g_spp_birth_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_START_OF_EMP');
    FETCH csr_user_entity INTO g_start_of_emp_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SUPERANNUATION_PAID');
    FETCH csr_user_entity INTO g_superannuation_paid_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_SUPERANNUATION_REFUND');
    FETCH csr_user_entity INTO g_superannuation_refund_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_CODE');
    FETCH csr_user_entity INTO g_tax_code_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_PAID');
    FETCH csr_user_entity INTO g_tax_paid_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REF_TRANSFER');
    FETCH csr_user_entity INTO g_tax_ref_transfer_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REFUND');
    FETCH csr_user_entity INTO g_tax_refund_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_RUN_RESULT_ID');
    FETCH csr_user_entity INTO g_tax_run_result_id_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAXABLE_PAY');
    FETCH csr_user_entity INTO g_taxable_pay_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TERMINATION_DATE');
    FETCH csr_user_entity INTO g_termination_date_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TERMINATION_TYPE');
    FETCH csr_user_entity INTO g_termination_type_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TITLE');
    FETCH csr_user_entity INTO g_title_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TOWN_OR_CITY');
    FETCH csr_user_entity INTO g_town_or_city_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_W1_M1_INDICATOR');
    FETCH csr_user_entity INTO g_w1_m1_indicator_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_WEEK_53_INDICATOR');
    FETCH csr_user_entity INTO g_week_53_indicator_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_WIDOWS_AND_ORPHANS');
    FETCH csr_user_entity INTO g_widows_and_orphans_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_STUDENT_LOANS');
    FETCH csr_user_entity INTO g_student_loans_eid;
    CLOSE csr_user_entity;
    -- Payroll Entities
    OPEN csr_user_entity('X_TAX_DISTRICT_REFERENCE');
    FETCH csr_user_entity INTO g_tax_dist_ref_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_TAX_REFERENCE_NUMBER');
    FETCH csr_user_entity INTO g_tax_ref_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERMIT_NUMBER');
    FETCH csr_user_entity INTO g_permit_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_MAX_PERIOD_NUMBER');
    FETCH csr_user_entity INTO g_max_period_number_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_PERIOD_TYPE');
    FETCH csr_user_entity INTO g_payroll_period_type_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_END_YEAR');
    FETCH csr_user_entity INTO g_payroll_end_year_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_START_YEAR');
    FETCH csr_user_entity INTO g_payroll_start_year_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_ASSIGNMENT_MESSAGE');
    FETCH csr_user_entity INTO g_assignment_message_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_NI_ARREARS');
    FETCH csr_user_entity INTO g_ni_arrears_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_REPORTABLE_NI');
    FETCH csr_user_entity INTO g_reportable_ni_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_AGG_ACTIVE_START');
    FETCH csr_user_entity INTO g_agg_active_start_eid;
    CLOSE csr_user_entity;
    OPEN csr_user_entity('X_AGG_ACTIVE_END');
    FETCH csr_user_entity INTO g_agg_active_end_eid;
    CLOSE csr_user_entity;
    --
     FOR pay_info IN csr_payroll_info(g_payroll_action_id) LOOP
       --
       l_payroll_id                := pay_info.payroll_id;
       l_payroll_start_year        := pay_info.start_year;
       l_payroll_end_year          := pay_info.end_year;
       l_payroll_period_type       := pay_info.period_type;
       l_payroll_max_period_number := pay_info.max_period_number;
       l_payroll_tax_ref           := pay_info.tax_ref;
       l_payroll_tax_dist          := pay_info.tax_dist;
       --
       -- Initialise period info for this payroll ID.
       --
       OPEN csr_period_type_info(l_payroll_period_type);
       FETCH csr_period_type_info INTO  l_number_per_fiscal_yr;
       CLOSE csr_period_type_info;
       --
       -- Assign to cache tables
       --
       g_no_per_fiscal_yr(l_payroll_id)      := l_number_per_fiscal_yr;
       --
       g_pay_start_yr_tab(l_payroll_id)      := l_payroll_start_year;
       g_pay_end_yr_tab(l_payroll_id)        := l_payroll_end_year;
       g_pay_period_typ_tab(l_payroll_id)    := l_payroll_period_type;
       g_pay_max_per_no_tab(l_payroll_id)    := l_payroll_max_period_number;
       g_pay_tax_ref_tab(l_payroll_id)       := l_payroll_tax_ref;
       g_pay_tax_dist_tab(l_payroll_id)      := l_payroll_tax_dist;
       --
       -- Assign the max and min payroll dates for asg level csr use
       --
       g_min_start_year := least(g_min_start_year,
                              nvl(l_payroll_start_year,g_min_start_year));
       g_max_end_year := greatest(g_max_end_year,
                              nvl(l_payroll_end_year,g_max_end_year));
       --
     END LOOP;
     --
  END IF;
  hr_utility.set_location(' Leaving: '||l_proc,100);
END archinit;
--
--
PROCEDURE archive_code(p_assactid IN NUMBER, p_effective_date IN DATE) IS
  --
  l_proc             CONSTANT VARCHAR2(35):= g_package||'archive_code';
  -- vars for returns from the API:
  l_archive_item_id           ff_archive_items.archive_item_id%TYPE;
  l_ovn                       NUMBER;
  l_some_warning              BOOLEAN;
  --
  l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
  l_effective_end_date  DATE;
  l_adj_eff_end_date    DATE;
  l_tax_ref_transfer    VARCHAR(1);
  l_termination_type    VARCHAR(1);
  --
  l_payroll_start_year        DATE;
  l_payroll_end_year          DATE;
  l_payroll_period_type       VARCHAR2(30);
  l_payroll_max_period_number NUMBER;
  l_payroll_tax_ref           VARCHAR2(10);
  l_payroll_tax_dist          VARCHAR2(3);
  --
  l_payroll_id            pay_all_payrolls_f.payroll_id%TYPE;
  l_assignment_number     per_all_assignments_f.assignment_number%TYPE;
  l_person_id             per_all_people_f.person_id%TYPE;
  l_organization_id       hr_organization_units.organization_id%TYPE;
  l_location_id           per_all_assignments_f.location_id%TYPE;
  l_people_group_id       per_all_assignments_f.people_group_id%TYPE;
  l_period_of_service_id  per_all_assignments_f.period_of_service_id%TYPE;
  l_agg_active_start      per_all_assignments_f.effective_start_date%TYPE;
  l_agg_active_end        per_all_assignments_f.effective_end_date%TYPE;
  l_active_start          per_all_assignments_f.effective_start_date%TYPE;
  l_active_end            per_all_assignments_f.effective_end_date%TYPE;
  --
  l_effective_start_date  DATE;
  l_final_process_date    DATE;
  --
  l_termination_date      DATE;
  l_actual_termination_date DATE;
  l_last_std_process_Date DATE;
  l_date_of_manual_p45_issue DATE;
  l_p45_issued            VARCHAR2(1);
  l_p45_issue_date        DATE;
  l_p45_action_id         NUMBER;
  l_p45_action_seq        NUMBER;
  l_p45_agg_asg_id        NUMBER;
  l_p45_final_pay_date    DATE;
  --
  l_last_asg_action_id    pay_assignment_actions.assignment_action_id%TYPE;
  l_last_effective_date   DATE;
  --
  l_paye_eff_date         DATE;
  l_paye_details_eff_date DATE;
  --
  --
  l_last_name                 per_all_people_f.last_name%TYPE;
  l_first_name                per_all_people_f.first_name%TYPE;
  l_middle_name               per_all_people_f.middle_names%TYPE;
  l_date_of_birth             DATE;
  l_title                     per_all_people_f.title%TYPE;
  l_expense_check_to_address  per_all_people_f.expense_check_send_to_address%TYPE;
  l_ni_number                 per_all_people_f.national_identifier%TYPE;
  l_sex                       per_all_people_f.sex%TYPE;
  l_pensioner_indicator       VARCHAR2(1);
  l_aggregated_paye_flag      VARCHAR2(1);
  l_multiple_asg_flag         VARCHAR2(1);
  --
  l_director_indicator        VARCHAR2(1);
  --
  l_start_of_emp              DATE;
  --
  l_address_line1             per_addresses.address_line1%type;
  l_address_line2             per_addresses.address_line2%type;
  l_address_line3             per_addresses.address_line3%type;
  l_town_or_city              VARCHAR2(30);
  l_county                    VARCHAR2(27);
  l_country_name              fnd_territories_tl.territory_short_name%type;
  l_country                   per_addresses.country%type;
  l_postal_code               VARCHAR2(8);
  --
  l_ni_tot                    NUMBER:= 0;
  l_ni_ees                    NUMBER:= 0;
  l_ni_able                   NUMBER:= 0;
  l_ni_able_lel               NUMBER:= 0;
  l_ni_able_uel               NUMBER:= 0;
  l_ni_able_uap               NUMBER:= 0; -- 8357870
  l_ni_able_auel              NUMBER:= 0; --EOY 07/08
  l_ni_able_et                NUMBER:= 0;
  l_ers_rebate                NUMBER;
  l_ees_rebate                NUMBER;
  l_rebate_emp                NUMBER;
  l_ni_cat                    VARCHAR2(1);
  l_ni_refund_flag            VARCHAR2(1);
  l_scon                      VARCHAR2(9);
  l_smp                       NUMBER(15):=0;
  l_ssp                       NUMBER(15):=0;
  l_sap                       NUMBER(15):=0;
  l_spp_adopt                 NUMBER(15):=0;
  l_spp_birth                 NUMBER(15):=0;
  l_gross                     NUMBER(15):=0;
  l_notional                  NUMBER(15):=0;
  l_paye                      NUMBER(15):=0;
  l_super                     NUMBER(15):=0;
  l_widow                     NUMBER(15):=0;
  l_taxable                   NUMBER(15):=0;
  l_student_loan              NUMBER(15):=0;
  --
  l_count_values              NUMBER(15):=0;
  l_dummy                     NUMBER(1);
  l_index1                    binary_integer;
  l_index2                    binary_integer;
  --
  l_tax_run_result_id         pay_run_results.run_result_id%TYPE;
  l_tax_paye_run_result_id    pay_run_results.run_result_id%TYPE;
  --
  l_tax_code                  VARCHAR2(10);
  l_w1_m1_indicator           VARCHAR2(1);
  l_previous_taxable_pay      NUMBER(15);
  l_previous_tax_paid         NUMBER(15);
  l_week_53_indicator         VARCHAR2(1);
  l_week_53_start             DATE;
  l_number_per_fiscal_yr      NUMBER;
  l_assignment_message        VARCHAR2(80);
  l_action_type               pay_payroll_actions.action_type%TYPE;
  l_ni_arrears                NUMBER(15):=0;
  l_reportable_ni_archived    BOOLEAN := FALSE;

  -- Start of Bug 6271548
  -- local variables to store NI total and able balances
  l_nia_tot                    NUMBER(15) :=0;
  l_nia_able                   NUMBER(15) :=0;
  l_nib_tot                    NUMBER(15) :=0;
  l_nib_able                   NUMBER(15) :=0;
  l_nic_tot                    NUMBER(15) :=0;
  l_nic_able                   NUMBER(15) :=0;
  l_nid_tot                    NUMBER(15) :=0;
  l_nid_able                   NUMBER(15) :=0;
  l_nie_tot                    NUMBER(15) :=0;
  l_nie_able                   NUMBER(15) :=0;
  l_nij_tot                    NUMBER(15) :=0;
  l_nij_able                   NUMBER(15) :=0;
  l_nil_tot                    NUMBER(15) :=0;
  l_nil_able                   NUMBER(15) :=0;
  -- End of Bug 6271548

-- Modifications for the bug 8452959 Start
    lv_assignment_id            per_all_assignments_f.assignment_id%TYPE;
    lv_payroll_id               pay_all_payrolls_f.payroll_id%TYPE;
    lv_count                    NUMBER;
-- Modifications for the bug 8452959 End


  ASG_ACTION_ERROR            EXCEPTION;
  --
  cursor csr_asg_act_info(p_asgactid NUMBER) IS
  SELECT act.assignment_id,
    fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str
       (act.assignment_action_id,
        g_effective_end_date_eid)) end_date,
    nvl(pay_gb_eoy_archive.get_arch_str(act.assignment_action_id,
      g_tax_ref_transfer_eid),'N') tax_ref_transfer,
    nvl(fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str
       (act.assignment_action_id,
        g_agg_active_start_eid)), hr_api.g_sot) agg_active_start,
    nvl(fnd_date.canonical_to_date(pay_gb_eoy_archive.get_arch_str
       (act.assignment_action_id,
        g_agg_active_end_eid)), hr_api.g_eot) agg_active_end
  FROM  pay_assignment_actions act
  WHERE act.assignment_action_id = p_asgactid;
  --
   CURSOR get_asg_active_range(p_asg_id NUMBER, p_tax_ref VARCHAR2) IS
   SELECT min(paaf.effective_start_date) min_active, max(paaf.effective_end_date) max_active
   FROM   per_all_assignments_f paaf,
          per_assignment_status_types past,
          pay_all_payrolls_f papf,
          hr_soft_coding_keyflex flex
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.assignment_status_type_id = past.assignment_status_type_id
   AND    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   AND    paaf.payroll_id = papf.payroll_id
   AND    paaf.effective_start_date BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = p_tax_ref;
   --
  -- Bug fix for 3699865 - this cursor will retrieve the final process date of the assignment
  cursor csr_asg_last_process_date(p_assid NUMBER) IS
  SELECT distinct greatest(ppos.final_process_date,ppos.last_standard_process_date)
  FROM   per_all_assignments_f  paaf,
         per_periods_of_service ppos
  WHERE  paaf.assignment_id = p_assid
  AND    paaf.period_of_service_id = ppos.period_of_service_id;
  --
  cursor csr_basic_asg_info (p_assid NUMBER, p_eff_end_date DATE) IS
  SELECT  ass.payroll_id,
          ass.assignment_number,
          ass.person_id,
          ass.organization_id,
          ass.location_id,
          ass.people_group_id,
          ass.period_of_service_id
  FROM  per_all_assignments_f        ass
  WHERE ass.assignment_id      = p_assid
  AND   ass.effective_end_date = p_eff_end_date;
  --
  -- 1778139. The asg may have been terminated during the
  -- eoy run. find the latest asg before the archived end date
  --
  cursor csr_basic_inf_term (p_assid NUMBER, p_eff_end_date DATE) IS
  SELECT  ass.effective_end_date,
          ass.payroll_id,
          ass.assignment_number,
          ass.person_id,
          ass.organization_id,
          ass.location_id,
          ass.people_group_id,
          ass.period_of_service_id
  FROM  per_all_assignments_f        ass
  WHERE ass.assignment_id      = p_assid
  AND   ass.effective_end_date < p_eff_end_date
  ORDER BY ass.effective_end_date desc;

  --
  -- 1778139. The asg may have had a new update previous to its
  -- end date, which deletes future changes. Get the current row.
  --
  cursor csr_basic_inf_current(p_assid NUMBER, p_eff_end_date DATE) IS
  SELECT  ass.effective_end_date,
          ass.payroll_id,
          ass.assignment_number,
          ass.person_id,
          ass.organization_id,
          ass.location_id,
          ass.people_group_id,
          ass.period_of_service_id
  FROM  per_all_assignments_f        ass
  WHERE ass.assignment_id      = p_assid
  AND   p_eff_end_date BETWEEN
           ass.effective_start_date AND ass.effective_end_date;
  --
  cursor csr_asg_start(p_asg_id NUMBER, p_asg_end DATE,
                       p_start_year DATE, p_end_year DATE) IS
  SELECT max(ass.effective_start_date)
  FROM per_all_assignments_f  ass
      ,pay_all_payrolls_f         nroll
      ,hr_soft_coding_keyflex flex
      ,per_all_assignments_f      pass
      ,pay_all_payrolls_f         proll
      ,hr_soft_coding_keyflex pflex
  WHERE ass.assignment_id = p_asg_id
  AND   ass.effective_start_date < p_asg_end
  AND   nroll.payroll_id = ass.payroll_id
  AND   ass.effective_start_date BETWEEN
          nroll.effective_start_date AND nroll.effective_end_date
  AND   nroll.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
  AND   ass.assignment_id = pass.assignment_id
  AND   pass.effective_end_date = (ass.effective_start_date - 1)
  AND   pass.effective_end_date >=
          fnd_date.canonical_to_date(pay_gb_eoy_archive.get_cached_value
            (g_payroll_action_id, 'X_START_YEAR', to_char(pass.payroll_id)))
  AND   pass.effective_start_date <=
          fnd_date.canonical_to_date(pay_gb_eoy_archive.get_cached_value
            (g_payroll_action_id, 'X_END_YEAR', to_char(pass.payroll_id)))
  AND   proll.payroll_id = pass.payroll_id
  AND   pass.payroll_id <> ass.payroll_id
  AND   ass.effective_start_date BETWEEN
          proll.effective_start_date AND proll.effective_end_date
  AND   proll.soft_coding_keyflex_id = pflex.soft_coding_keyflex_id
  AND   flex.segment1 <> pflex.segment1;
  --
  cursor csr_termination(p_service_id NUMBER, p_asg_end DATE) IS
  SELECT actual_termination_date , last_standard_process_date, 'L' termination_type
  FROM   per_periods_of_service pos
  WHERE  pos.period_of_service_id = p_service_id
  AND    pos.actual_termination_date IS NOT NULL
  AND    pos.actual_termination_date
               <= least(p_asg_end,g_end_year);
  --
  CURSOR get_week_53_start(p_payroll_id NUMBER) IS
  SELECT start_date
  FROM   per_time_periods ptp
  WHERE  payroll_id = p_payroll_id
  AND    regular_payment_date BETWEEN g_start_year AND g_end_year
  AND    period_num = l_payroll_max_period_number;
  --
  -- Now checks the time period from the action against the
  -- statutory start and end date for the year.
  -- 2166991. Retrieve further action types, with the addition of
  -- reVersal types, include actions that have been reversed
  -- due to Master Actions not being interlocked (removed
  -- interlock subquery). NB you cannot reverse a payrun
  -- after an EOY run, (business rule).
  --
  cursor csr_last_action(p_asgid NUMBER, p_asg_start DATE,
                         p_asg_end DATE, p_start_year DATE,
                         p_end_year DATE, p_tax_ref_xfer VARCHAR2) IS
            SELECT /*+ USE_NL(paa, pact, ptp) */
                    to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                              paa.assignment_action_id),16)),
            max(pact.effective_date) effective_date
            FROM    pay_assignment_actions paa,
                    pay_payroll_actions    pact,
                    per_time_periods ptp
            WHERE   paa.assignment_id = p_asgid
            AND     paa.payroll_action_id = pact.payroll_action_id
            AND     pact.time_period_id = ptp.time_period_id
            AND     pact.action_type IN ('Q','R','B','I','V')
            AND     paa.action_status = 'C'
            -- Added decode below for 4318185
            AND     pact.effective_date <= decode(p_tax_ref_xfer, 'Y', p_asg_end, pact.effective_date)
            AND     ptp.regular_payment_date
                  BETWEEN nvl(p_asg_start, p_start_year) AND p_end_year;
  --
  -- Retrieve action type info from assignment ation
  --
  cursor csr_action_details(p_assignment_action_id NUMBER) IS
  SELECT pact.action_type
  from pay_payroll_actions pact,
       pay_assignment_actions act
  where act.assignment_action_id = p_assignment_action_id
  and act.payroll_action_id = pact.payroll_action_id;
  --
  cursor csr_person_info(p_person_id NUMBER) IS
  SELECT substr(last_name, 1,35) last_name,
         substr(first_name, 1,35) first_name,
         substr(middle_names,1,35) middle_names,
         date_of_birth,  title,
         substr(expense_check_send_to_address,1,1) expense_check_send_to_address,
         substr(national_identifier,1,9) national_identifier,
         substr(sex,1,1) sex ,
         decode(substr(per_information4,1,1),'Y','P',' ') pensioner_indicator,
         decode(per_information10,'Y','Y',NULL) agg_paye_flag,
         decode(per_information9,'Y','Y',NULL) multiple_asg_flag -- MII
  FROM  per_all_people_f per
  WHERE per.person_id = p_person_id
    AND g_end_year BETWEEN per.effective_start_date
                       AND per.effective_end_date;
  --
  cursor csr_director(p_person_id NUMBER) IS
  SELECT 'D'
  FROM dual
  WHERE EXISTS (SELECT '1'
                FROM per_all_people_f per
                WHERE p_person_id           = per.person_id
                  AND per.effective_start_date    <= g_end_year
                  AND per.effective_end_date      >= g_start_year
                  AND substr(per_information2,1,1) = 'Y')
 AND EXISTS (SELECT '1'
             FROM pay_run_result_values prrv
             WHERE input_value_id = g_process_type_id
             AND result_value in ('DY', 'DN', 'DP', 'DR', 'PY')
             AND run_result_id = (SELECT to_number(substr(max(lpad(to_char(act.action_sequence),15,'0')|| lpad(to_char(prr.run_result_id),19,'0')),16))
                  FROM pay_payroll_Actions pact,
                  pay_assignment_actions act,
                  per_all_assignments_f paf,
                  pay_run_results prr
                  WHERE pact.payroll_Action_id = act.payroll_Action_id
                  AND pact.effective_date BETWEEN g_start_year and g_end_year
                  AND act.action_status = 'C'
                  AND act.assignment_id = paf.assignment_id
                  AND paf.person_id = p_person_id
                  AND paf.effective_start_date <= g_end_year
                  AND paf.effective_end_date >=  g_start_year
                  AND act.assignment_action_id = prr.assignment_action_id
                  AND prr.element_type_id = g_ni_id
                  AND pact.action_type IN ('Q', 'R', 'B', 'I')
                  AND prr.status in ('P', 'PA')));
  --
  cursor csr_addresses(p_person_id NUMBER) IS
  SELECT ltrim(rtrim(pad.address_line1)) address_line1,
         ltrim(rtrim(pad.address_line2)) address_line2,
         ltrim(rtrim(pad.address_line3)) address_line3,
         ltrim(rtrim(pad.town_or_city)) town_or_city,
         substr(l.meaning,1,27) county,
         substr(pad.postal_code,1,8),
         country
  FROM   per_addresses pad,
         hr_lookups l
  WHERE  pad.person_id = p_person_id
  AND    pad.primary_flag = 'Y'
  AND    l.lookup_type(+) = 'GB_COUNTY'
  AND    l.lookup_code(+) = pad.region_1
  AND    sysdate BETWEEN nvl(pad.date_from, sysdate)
                     AND nvl(pad.date_to,   sysdate);
  --
  cursor csr_country_name(p_country_code VARCHAR2) IS
  SELECT substr(ftt.territory_short_name, 1, 35) country -- 4011263
  FROM   fnd_territories_tl ftt
  WHERE  ftt.territory_code = p_country_code
  AND    ftt.language = userenv('LANG');
  --
  -- fetch the scon balances for NI F, NI G and/or NI S
  cursor csr_get_scon_bal(cp_l_asg_id NUMBER, cp_scon_inp_val NUMBER,
                          cp_cat_inp_val NUMBER, cp_element_type NUMBER) IS
    SELECT /*+ RULE */
    substr(bal.balance_name,4,1) cat_code,
    substr(hr_general.decode_lookup('GB_SCON',
      decode(substr(bal.balance_name,4,1),
             'F',nvl(max(decode(ev_cat.screen_entry_value,
                                'F',ev_scon.screen_entry_value)),
                 pay_gb_eoy_archive.get_nearest_scon(
                 max(ev_scon.element_entry_id), cp_l_asg_id,
                     'F',max(pact.effective_date))),
             'G',nvl(max(decode(ev_cat.screen_entry_value,
                                'G',ev_scon.screen_entry_value)),
                 pay_gb_eoy_archive.get_nearest_scon(
                 max(ev_scon.element_entry_id), cp_l_asg_id,
                     'G',max(pact.effective_date))),
             'S',nvl(max(decode(ev_cat.screen_entry_value,
                                'S',ev_scon.screen_entry_value)),
                 pay_gb_eoy_archive.get_nearest_scon(
                 max(ev_scon.element_entry_id), cp_l_asg_id,
                     'S',max(pact.effective_date))),
             NULL)),1,9) scon,
    100*nvl(sum(decode(substr(bal.balance_name,6),'Able',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            able,
    100*nvl(sum(decode(substr(bal.balance_name,6),'Total',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            total,
    100*nvl(sum(decode(substr(bal.balance_name,6),'Employee',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            employee,
       --
       -- Bug Fix 678573 Start
       --
    100*nvl(sum(decode(substr(bal.balance_name,6),'Employer',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            employer,
       --
       -- Bug Fix 678573 End
       --
    100*nvl(sum(decode(substr(bal.balance_name,6),'Able ET',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            able_et,
    100*nvl(sum(decode(substr(bal.balance_name,6),'Able LEL',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            able_lel,
    100*nvl(sum(decode(substr(bal.balance_name,6),'Able UEL',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            able_uel,
    -- 8357870 begin
    100*nvl(sum(decode(substr(bal.balance_name,6),'Able UAP',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            able_uap,
    -- 8357870 end
    --EOY 07/08 Begin
    100*nvl(sum(decode(substr(bal.balance_name,6),'Able AUEL',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            able_auel,
    -- EOY 07/08 End
    100*nvl(sum(decode(substr(bal.balance_name,6),'Ers Rebate',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            ers_rebate,
    -- Note Ees Rebate only for F category, but zero
    -- retrieved in all other cases.
    100*nvl(sum(decode(substr(bal.balance_name,6),'Ees Rebate',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            ees_rebate,
    100*nvl(sum(decode(substr(bal.balance_name,6),'Rebate to Employee',
      fnd_number.canonical_to_number(target.result_value) * feed.scale,0)),0)
            rebate_emp
  FROM  pay_balance_feeds_f      feed
       ,pay_balance_types        bal
       ,pay_run_result_values    target
       ,pay_run_results          rr
       ,pay_element_entry_values_f ev_scon
       ,pay_element_entry_values_f ev_cat
       ,pay_element_entries_f    e_ni
       ,pay_element_links_f      el_ni
       ,pay_payroll_actions      pact
       ,pay_assignment_actions   assact
       ,pay_payroll_actions      bact
       ,per_time_periods         bptp
       ,per_time_periods         pptp
       ,pay_assignment_actions   bal_assact
  WHERE  bal_assact.assignment_action_id = cp_l_asg_id
  AND    bal_assact.payroll_action_id = bact.payroll_action_id
  AND    feed.balance_type_id    = bal.balance_type_id
  AND    bal.balance_name        LIKE 'NI%'
  AND    substr(bal.balance_name,4,1) IN ('F','G','S')
  AND    feed.input_value_id     = target.input_value_id
  AND    target.run_result_id    = rr.run_result_id
  AND    nvl(target.result_value,'0') <> '0'
  AND    rr.assignment_action_id = assact.assignment_action_id
  AND    e_ni.assignment_id      = bal_assact.assignment_id
  AND    ev_scon.input_value_id  +
             decode(ev_scon.element_entry_id,NULL,0,0) = cp_scon_inp_val
  AND    ev_scon.element_entry_id = e_ni.element_entry_id
  AND    ev_cat.input_value_id  +
             decode(ev_cat.element_entry_id,NULL,0,0) = cp_cat_inp_val
  AND    ev_cat.element_entry_id = e_ni.element_entry_id
  AND    el_ni.element_link_id    = e_ni.element_link_id
  AND    el_ni.element_type_id    = cp_element_type
  AND    pact.effective_date BETWEEN
                e_ni.effective_start_date AND e_ni.effective_end_date
  AND    pact.effective_date BETWEEN
                el_ni.effective_start_date AND el_ni.effective_end_date
  AND    pact.effective_date BETWEEN
                ev_scon.effective_start_date AND ev_scon.effective_end_date
  AND    pact.effective_date BETWEEN
                ev_cat.effective_start_date AND ev_cat.effective_end_date
  AND    assact.payroll_action_id = pact.payroll_action_id
  AND    pact.effective_date BETWEEN
                feed.effective_start_date AND feed.effective_end_date
  AND    rr.status IN ('P','PA')
  AND    bptp.time_period_id = bact.time_period_id
  AND    pptp.time_period_id = pact.time_period_id
  AND    pptp.regular_payment_date >= /* fin year start */
               ( to_date('06-04-' || to_char( to_number(
                 to_char( bptp.regular_payment_date,'YYYY'))
          +  decode(sign( bptp.regular_payment_date - to_date('06-04-'
              || to_char(bptp.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY'))
  AND    pact.effective_date >=
       /* find the latest td payroll transfer date - compare each of the */
       /* assignment rows with its predecessor looking for the payroll   */
       /* that had a different tax district at that date */
        ( SELECT nvl(max(ass.effective_start_date),
          to_date('01-01-0001','DD-MM-YYYY'))
          FROM per_all_assignments_f  ass
              ,pay_all_payrolls_f         nroll
              ,hr_soft_coding_keyflex flex
              ,per_all_assignments_f  pass  /* previous assignment */
              ,pay_all_payrolls_f         proll
              ,hr_soft_coding_keyflex pflex
          WHERE ass.assignment_id = bal_assact.assignment_id
            AND nroll.payroll_id = ass.payroll_id
            AND ass.effective_start_date BETWEEN
                      nroll.effective_start_date AND nroll.effective_end_date
            AND nroll.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
            AND ass.assignment_id = pass.assignment_id
            AND pass.effective_end_date = (ass.effective_start_date - 1)
            AND ass.effective_start_date <= bact.effective_date
            AND proll.payroll_id = pass.payroll_id
            AND ass.effective_start_date BETWEEN
                      proll.effective_start_date AND proll.effective_end_date
            AND proll.soft_coding_keyflex_id = pflex.soft_coding_keyflex_id
            AND ass.payroll_id <> pass.payroll_id
            AND flex.segment1 <> pflex.segment1)
  AND    assact.action_sequence <= bal_assact.action_sequence
  AND    assact.assignment_id = bal_assact.assignment_id
  GROUP BY ev_scon.screen_entry_value, substr(bal.balance_name,4,1)
  ORDER BY ev_scon.screen_entry_value, substr(bal.balance_name,4,1);
  --
  cursor csr_current_cat(p_asgid NUMBER, l_asg_end DATE,
                         p_end_year DATE) IS
  SELECT  v.screen_entry_value ni_cat,
          substr(hr_general.decode_lookup('GB_SCON',scon.screen_entry_value)
                 ,1,9) ni_scon
  FROM    pay_element_entries_f e,
          pay_element_entry_values_f v,
          pay_element_entry_values_f  scon,
          pay_element_links_f link
  WHERE   e.assignment_id = p_asgid
    AND   v.input_value_id + 0 = g_category_input_id
    AND   v.effective_start_date = scon.effective_start_date
    AND   v.effective_end_date   = scon.effective_end_date
    AND   v.element_entry_id = scon.element_entry_id
    AND   scon.input_value_id + 0  = g_scon_input_id
    AND   link.element_type_id = g_ni_id
    AND   e.element_link_id = link.element_link_id
    AND   e.element_entry_id = v.element_entry_id
    AND   least(l_asg_end,p_end_year)
            BETWEEN link.effective_start_date AND link.effective_end_date
    AND   least(l_asg_end,p_end_year)
            BETWEEN e.effective_start_date AND e.effective_end_date
    AND   least(l_asg_end,p_end_year)
            BETWEEN v.effective_start_date AND v.effective_end_date
    AND   least(l_asg_end,p_end_year)
            BETWEEN scon.effective_start_date AND scon.effective_end_date;
  --
  cursor csr_tax_last_run(p_last_asg_action_id NUMBER) IS
  SELECT  to_number(substr(max(source_type||lpad(to_char(run_result_id), 19, '0')),2)) -- gets indirect results if present else gets entry results
  FROM    pay_run_results r
  WHERE   r.element_type_id = g_paye_details_id
    AND   r.status IN ('P', 'PA')
    AND   r.assignment_action_id = p_last_asg_action_id;
  --
  cursor csr_tax_last_paye_run(p_last_asg_action_id NUMBER) IS
  SELECT  to_number(substr(max(source_type||lpad(to_char(run_result_id), 19, '0')),2)) -- gets indirect results if present else gets entry results
  FROM    pay_run_results r
  WHERE   r.element_type_id = g_paye_element_id
    AND   r.status IN ('P', 'PA', 'O') -- add overridden for SR 4310794.996
    AND   r.assignment_action_id = p_last_asg_action_id;
  --
  cursor csr_tax_latest_run(p_assignment_id NUMBER,
                            p_asg_last_eff_date DATE) IS
  -- bug 889323 ensure the last action included PAYE Details result
  -- bug 1236784 ignore reversal/reversed runs
SELECT /*+ ORDERED INDEX (assact2 PAY_ASSIGNMENT_ACTIONS_N51,
                          pact PAY_PAYROLL_ACTIONS_PK,
                          r2 PAY_RUN_RESULTS_N50)
           USE_NL(assact2, pact, r2) */
           to_number(substr(max(lpad(to_char(assact2.action_sequence),15,'0')
                ||r2.source_type||
                lpad(to_char(r2.run_result_id),19,'0')),17)) rr_id,
           fnd_date.canonical_to_date(substr(max(lpad(to_char(assact2.action_sequence),15,'0')||
                 fnd_date.date_to_canonical(pact.effective_date)),16)) eff_date
           FROM    pay_assignment_actions assact2,
                   pay_payroll_actions pact,
                   pay_run_results r2
           WHERE   assact2.assignment_id = p_assignment_id
           AND     r2.element_type_id+0 = g_paye_details_id
           AND     r2.assignment_action_id = assact2.assignment_action_id
           AND     r2.status IN ('P', 'PA')
           AND     pact.payroll_action_id = assact2.payroll_action_id
           AND     pact.action_type IN ( 'Q','R','B','I')
           AND     assact2.action_status = 'C'
           AND     pact.effective_date BETWEEN
                   g_start_year AND g_end_year
/* Bug 4278570       fnd_date.canonical_to_date
                       (pay_gb_eoy_archive.get_arch_str(
                        g_payroll_action_id,
                        g_payroll_start_year_eid,
                        to_char(pact.payroll_id)))
                   AND fnd_date.canonical_to_date
                         (pay_gb_eoy_archive.get_arch_str(
                          g_payroll_action_id,
                          g_payroll_end_year_eid,
                          to_char(pact.payroll_id)))
*/
          AND     pact.effective_date <= p_asg_last_eff_date
           AND NOT EXISTS(
              SELECT '1'
              FROM  pay_action_interlocks pai,
                    pay_assignment_actions assact3,
                    pay_payroll_actions pact3
              WHERE   pai.locked_action_id = assact2.assignment_action_id
              AND     pai.locking_action_id = assact3.assignment_action_id
              AND     pact3.payroll_action_id = assact3.payroll_action_id
              AND     pact3.action_type = 'V'
              AND     assact3.action_status = 'C');
  --
  cursor csr_tax_latest_paye_run(p_assignment_id NUMBER,
                            p_asg_last_eff_date DATE) IS
SELECT /*+ ORDERED INDEX (assact2 PAY_ASSIGNMENT_ACTIONS_N51,
                          pact PAY_PAYROLL_ACTIONS_PK,
                          r2 PAY_RUN_RESULTS_N50)
           USE_NL(assact2, pact, r2) */
           to_number(substr(max(lpad(to_char(assact2.action_sequence),15,'0')
                 ||r2.source_type||
                 lpad(to_char(r2.run_result_id),19,'0')),17)) rr_id,
           fnd_date.canonical_to_date(substr(max(lpad(to_char(assact2.action_sequence),15,'0')||
                 fnd_date.date_to_canonical(pact.effective_date)),16)) eff_date
--           to_number(substr(max(lpad(assact2.action_sequence,15,'0')||
--                             r2.run_result_id),16))
           FROM    pay_assignment_actions assact2,
                   pay_payroll_actions pact,
                   pay_run_results r2
           WHERE   assact2.assignment_id = p_assignment_id
           AND     r2.element_type_id+0 = g_paye_element_id
           AND     r2.assignment_action_id = assact2.assignment_action_id
           AND     r2.status IN ('P', 'PA', 'O') -- add overridden for SR 4310794.996
           AND     pact.payroll_action_id = assact2.payroll_action_id
           AND     pact.action_type IN ( 'Q','R','B','I')
           AND     assact2.action_status = 'C'
           AND     pact.effective_date BETWEEN
                   g_start_year AND g_end_year
/* Bug 4278570       fnd_date.canonical_to_date
                       (pay_gb_eoy_archive.get_arch_str(
                        g_payroll_action_id,
                        g_payroll_start_year_eid,
                        to_char(pact.payroll_id)))
                   AND fnd_date.canonical_to_date
                         (pay_gb_eoy_archive.get_arch_str(
                          g_payroll_action_id,
                          g_payroll_end_year_eid,
                          to_char(pact.payroll_id)))
*/
          AND     pact.effective_date <= p_asg_last_eff_date
           AND NOT EXISTS(
              SELECT '1'
              FROM  pay_action_interlocks pai,
                    pay_assignment_actions assact3,
                    pay_payroll_actions pact3
              WHERE   pai.locked_action_id = assact2.assignment_action_id
              AND     pai.locking_action_id = assact3.assignment_action_id
              AND     pact3.payroll_action_id = assact3.payroll_action_id
              AND     pact3.action_type = 'V'
              AND     assact3.action_status = 'C');
  --
  cursor csr_tax_details_entry(p_assignment_id NUMBER,
                               p_asg_end DATE, p_end_year DATE,
                               p_update_recurring VARCHAR2) IS
  SELECT  max(decode(iv.name,'Tax Code',screen_entry_value,NULL)) tax_code,
          max(decode(iv.name,'Tax Basis',screen_entry_value,NULL)) tax_basis,
          100 * max(decode(iv.name,'Pay Previous',
                  fnd_number.canonical_to_number(screen_entry_value),NULL))
                                                                pay_previous,
          100 * max(decode(iv.name,'Tax Previous',
                  fnd_number.canonical_to_number(screen_entry_value),NULL))
                                                                tax_previous
  FROM  pay_element_entries_f e,
        pay_element_entry_values_f v,
        pay_input_values_f iv,
        pay_element_links_f link
  WHERE e.assignment_id = p_assignment_id
  AND   link.element_type_id = g_paye_details_id
  AND   e.element_link_id = link.element_link_id
  AND   e.element_entry_id = v.element_entry_id
  AND   iv.input_value_id = v.input_value_id
  AND   (e.updating_action_id IS NOT NULL OR p_update_recurring = 'N')
  AND   least(p_asg_end,p_end_year)
          BETWEEN link.effective_start_date AND link.effective_end_date
  AND   least(p_asg_end,p_end_year)
          BETWEEN e.effective_start_date AND e.effective_end_date
  AND   least(p_asg_end,p_end_year)
          BETWEEN iv.effective_start_date AND iv.effective_end_date
  AND   least(p_asg_end,p_end_year)
          BETWEEN v.effective_start_date AND v.effective_end_date;
  --
  cursor csr_tax_details_result(p_tax_run_result_id NUMBER) IS
  SELECT  max(decode(name,'Tax Code',result_value,NULL)) tax_code,
          max(decode(name,'Tax Basis',result_value,NULL)) tax_basis,
          100 * to_number(max(decode(name,'Pay Previous',
                  fnd_number.canonical_to_number(result_value),NULL)))
                                                                pay_previous,
          100 * to_number(max(decode(name,'Tax Previous',
                  fnd_number.canonical_to_number(result_value),NULL)))
                                                                tax_previous
  FROM pay_input_values_f v,
       pay_run_result_values rrv
  WHERE rrv.run_result_id = p_tax_run_result_id
    AND v.input_value_id = rrv.input_value_id
    AND v.element_type_id = g_paye_details_id;
  --
  cursor csr_tax_paye_result(p_tax_run_result_id NUMBER) IS
  SELECT  max(decode(name,'Tax Code',result_value,NULL)) tax_code,
          max(decode(name,'Tax Basis',result_value,NULL)) tax_basis,
          100 * to_number(max(decode(name,'Pay Previous',
                  fnd_number.canonical_to_number(result_value),NULL)))
                                                                pay_previous,
          100 * to_number(max(decode(name,'Tax Previous',
                  fnd_number.canonical_to_number(result_value),NULL)))
                                                                tax_previous
  FROM pay_input_values_f v,
       pay_run_result_values rrv
  WHERE rrv.run_result_id = p_tax_run_result_id
    AND v.input_value_id = rrv.input_value_id
    AND v.element_type_id = g_paye_element_id;
  --
  CURSOR csr_get_invalid_multiple_asg(p_person_id  NUMBER,
                                  p_payroll_id NUMBER,
                                  p_year_start DATE,
                                  p_year_end   DATE,
                                  p_tax_ref    VARCHAR2) IS
  -- fetch any asg for the person within the same tax reference
  -- but on a payroll with a different (or null) permit.
  SELECT 1
  FROM  per_all_assignments_f asg
  WHERE asg.person_id = p_person_id
  AND   asg.effective_start_date < p_year_end
  AND   asg.effective_end_date >= p_year_start
  AND   asg.payroll_id <> p_payroll_id
  AND   p_tax_ref = pay_gb_eoy_archive.get_cached_value(
                      g_payroll_action_id,'X_TAX_REFERENCE_NUMBER',
                      to_char(asg.payroll_id))
  AND   g_permit_number <> nvl(pay_gb_eoy_archive.get_cached_value(
                             g_payroll_action_id,'X_PERMIT_NUMBER',
                             to_char(asg.payroll_id)),'?');
  --
  -- Start of BUG 5671777-1
  --
  -- fetch final payment date for the give assignment action using
  -- X_P45_FINAL_PAYMENT_ACTION user entity
  --
  CURSOR csr_get_final_payment_date(c_asg_action_id NUMBER) IS
  SELECT ppa.effective_date
  FROM   ff_user_entities fue,
         ff_archive_items fai,
         pay_assignment_actions paa,
         pay_payroll_actions ppa
  WHERE  fue.user_entity_name = 'X_P45_FINAL_PAYMENT_ACTION'
  AND    fue.user_entity_id = fai.user_entity_id
  AND    fai.context1 = c_asg_action_id
  AND    fai.value = paa.assignment_action_id
  AND    paa.payroll_action_id = ppa.payroll_action_id;

  --
  -- End of BUG 5671777-1
  --
-- Modifications for the bug 8452959 Start

cursor get_old_tax_ref_cnt(lv_assignment_id number,
                           lv_payroll_id number,
                           lv_tax_ref varchar)
is
select count(*)
from per_all_assignments_f paaf,
     pay_all_payrolls_f papf,
     hr_soft_coding_keyflex flex
where paaf.assignment_id = lv_assignment_id
and paaf.payroll_id = lv_payroll_id
and paaf.effective_start_date < l_active_start
and paaf.payroll_id = papf.payroll_id
and papf.effective_start_date < g_start_year
and papf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
and flex.segment1 = lv_tax_ref;

-- Modifications for the bug 8452959 End


  PROCEDURE archive_asg_info(p_user_entity_id NUMBER,
                             p_value VARCHAR2,
                             p_actid          NUMBER DEFAULT NULL) IS
    l_proc             CONSTANT VARCHAR2(40):= g_package||'archive_asg_info';
  BEGIN
    IF p_value IS NOT NULL THEN
      hr_utility.set_location(l_proc||' '||p_user_entity_id,10);
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => p_user_entity_id,
         p_archive_value    => p_value,
         p_action_id        => nvl(p_actid,p_assactid),
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
    END IF;
  END archive_asg_info;
  --
  PROCEDURE archive_ni_value(p_user_entity_id NUMBER,
                             p_value          VARCHAR2,
                             p_reportable     NUMBER,
                             p_ni_cat         VARCHAR2,
                             p_scon           VARCHAR2 DEFAULT NULL,
                             p_actid          NUMBER DEFAULT NULL) IS
  -- Procedure used to archive an individual NI balance value for a given
  -- NI Category and (where necessary) SCON.
  --
  -- The p_reportable parameter indicates that the value is reportable ie.
  -- to be included in the P35 tape submission.  This is necessary for
  -- Multiple Assignment processing to indicate whether a set of values is
  -- for a single (non-multi) asg, a person level total (against the
  -- primary assignment) or a value which contributes to a person level
  -- total (aka a source balance).  The values view will display this flag
  -- using the char code used in the previous EoY implementation.
  -- The expected values are as follows:
  --
  --    p_reportable  View returns  Meaning
  --    ------------  ------------  ----------------------------------------
  --               0  N             Not reportable - source balance
  --               1  Y             Reportable - non-multi asg value
  --               2  M             Reportable - multi asg person level Tot
  --
  -- This is called from the archive_ni_values procedure and part III of
  -- the Multiple Assignment Logic.  Calls to this
  -- procedure should not be made from any other places unless the Multiple
  -- Assignment Logic contained within the two above procedures is to be
  -- by-passed.
  -- p_actid may be given to archive the value against a different assignment
  -- action to that currently being processed.  This is utilised by the
  -- Multiple Assignment Logic Pt. III
  BEGIN
    hr_utility.trace('Entering pay_gb_eoy_archive.archive_ni_values');
    hr_utility.trace('p_user_entity_id='||p_user_entity_id);
    hr_utility.trace('p_value='||p_value);
    hr_utility.trace('p_reportable='||p_reportable);
    hr_utility.trace('p_ni_cat='||p_ni_cat);
    hr_utility.trace('p_scon='||p_scon);
    hr_utility.trace('p_actid='||p_actid);
    hr_utility.trace('p_assactid='||p_assactid);
    IF p_value IS NOT NULL THEN
      IF p_scon IS NOT NULL THEN
        ff_archive_api.create_archive_item
          (p_archive_item_id  => l_archive_item_id,
           p_user_entity_id   => p_user_entity_id,
           p_archive_value    => p_value,
           p_action_id        => nvl(p_actid,p_assactid),
           p_legislation_code => 'GB',
           p_object_version_number => l_ovn,
           p_context_name1    => 'TAX_UNIT_ID',
           p_context1         => to_char(p_reportable),
           p_context_name2    => 'TAX_GROUP',
           p_context2         => p_ni_cat,
           p_context_name3    => 'SOURCE_TEXT',
           p_context3         => p_scon,
           p_some_warning     => l_some_warning);
      ELSE
        ff_archive_api.create_archive_item
          (p_archive_item_id  => l_archive_item_id,
           p_user_entity_id   => p_user_entity_id,
           p_archive_value    => p_value,
           p_action_id        => nvl(p_actid,p_assactid),
           p_legislation_code => 'GB',
           p_object_version_number => l_ovn,
           p_context_name1    => 'TAX_UNIT_ID',
           p_context1         => to_char(p_reportable),
           p_context_name2    => 'TAX_GROUP',
           p_context2         => p_ni_cat,
           p_some_warning     => l_some_warning);
      END IF;
      --
      -- Set l_reportable_ni_archived variable to indicate
      -- a reportable non zero NI value has been archived, this will
      -- be used to archive X_REPORTABLE_NI flag to help decide whether
      -- the assignment should be reported on P14 or reconciliation
      -- report
      IF p_user_entity_id NOT IN (g_ni_scon_refund_eid, g_ni_refund_eid) THEN -- to ensure p_value is number, Bugs 4918852, 4907567
         IF p_reportable > 0 and p_value <> 0 THEN
            l_reportable_ni_archived := TRUE;
         END IF;
      END IF;
    END IF;
  END archive_ni_value;
  --
  PROCEDURE empty_masg_cache IS
  BEGIN
    g_masg_person_id          := hr_api.g_number;
    g_masg_period_of_service_id := hr_api.g_number; -- Bug 3784871
    g_masg_active_start       := hr_api.g_sot;
    g_masg_active_end         := hr_api.g_eot;
    g_masg_tax_ref_num        := substr(hr_api.g_varchar2,1,10); -- 4011263
    g_max_gross_pay           := NULL;
    g_primary_action          := NULL;
    g_min_assignment_id       := NULL;
    g_ni_balance_totals       := g_empty_ni_balance_totals;
    g_agg_balance_totals      := g_zero_balance_totals;
    g_asg_actions             := g_empty_asg_actions;
    g_num_actions             := 0;
    g_has_non_extracted_masgs := false;
  END empty_masg_cache;
  ------------------------------------------------------------------
  -- PROCEDURE store_agg_values
  -- Store a set of balance values, for the Aggregated PAYE
  -- Assignments in the global table. The table is emptied
  -- by empty_masg_cache after MA processing.
  -- This is in step with NI Multi Asg Logic Part II
  ------------------------------------------------------------------
  PROCEDURE store_agg_values(p_smp        NUMBER DEFAULT NULL,
                             p_ssp        NUMBER DEFAULT NULL,
                             p_sap        NUMBER DEFAULT NULL,
                             p_spp_adopt  NUMBER DEFAULT NULL,
                             p_spp_birth  NUMBER DEFAULT NULL,
                             p_gross      NUMBER DEFAULT NULL,
                             p_notional   NUMBER DEFAULT NULL,
                             p_paye       NUMBER DEFAULT NULL,
                             p_super      NUMBER DEFAULT NULL,
                             p_widow      NUMBER DEFAULT NULL,
                             p_taxable    NUMBER DEFAULT NULL,
                             p_student_ln NUMBER DEFAULT NULL,
                             p_tax_credit NUMBER DEFAULT NULL,
                             p_ni_arrears NUMBER DEFAULT NULL) IS
  --
  l_proc    CONSTANT VARCHAR2(40):= g_package||'archive_agg_values';
  --
  BEGIN
    --
    hr_utility.set_location(l_proc,10);
    BEGIN
       g_agg_balance_totals.smp :=
                  g_agg_balance_totals.smp + nvl(p_smp,0);
       g_agg_balance_totals.ssp :=
                  g_agg_balance_totals.ssp + nvl(p_ssp,0);
       g_agg_balance_totals.sap :=
                  g_agg_balance_totals.sap + nvl(p_sap,0);
       g_agg_balance_totals.spp_adopt :=
                  g_agg_balance_totals.spp_adopt + nvl(p_spp_adopt,0);
       g_agg_balance_totals.spp_birth :=
                  g_agg_balance_totals.spp_birth + nvl(p_spp_birth,0);
       g_agg_balance_totals.gross_pay :=
                  g_agg_balance_totals.gross_pay + nvl(p_gross,0);
       g_agg_balance_totals.notional :=
                  g_agg_balance_totals.notional + nvl(p_notional,0);
       g_agg_balance_totals.paye :=
                  g_agg_balance_totals.paye + nvl(p_paye,0);
       g_agg_balance_totals.superann :=
                  g_agg_balance_totals.superann + nvl(p_super,0);
       g_agg_balance_totals.widows :=
                  g_agg_balance_totals.widows + nvl(p_widow,0);
       g_agg_balance_totals.taxable :=
                  g_agg_balance_totals.taxable + nvl(p_taxable,0);
       g_agg_balance_totals.student_ln :=
                  g_agg_balance_totals.student_ln + nvl(p_student_ln,0);
       g_agg_balance_totals.ni_arrears :=
                  g_agg_balance_totals.ni_arrears + nvl(p_ni_arrears,0);
       hr_utility.set_location(l_proc,20);
    EXCEPTION WHEN NO_DATA_FOUND THEN
       hr_utility.set_location(l_proc,30);
       -- The PLSQL table is empty so first row.
       g_agg_balance_totals.smp := nvl(p_smp,0);
       g_agg_balance_totals.ssp := nvl(p_ssp,0);
       g_agg_balance_totals.sap := nvl(p_sap,0);
       g_agg_balance_totals.spp_adopt := nvl(p_spp_adopt,0);
       g_agg_balance_totals.spp_birth := nvl(p_spp_birth,0);
       g_agg_balance_totals.gross_pay := nvl(p_gross,0);
       g_agg_balance_totals.notional := nvl(p_notional,0);
       g_agg_balance_totals.paye := nvl(p_paye,0);
       g_agg_balance_totals.superann := nvl(p_super,0);
       g_agg_balance_totals.widows := nvl(p_widow,0);
       g_agg_balance_totals.taxable := nvl(p_taxable,0);
       g_agg_balance_totals.student_ln := nvl(p_student_ln,0);
       g_agg_balance_totals.ni_arrears := nvl(p_ni_arrears,0);
    END; -- store balance values in global table.
    --
    hr_utility.set_location(l_proc,40);
  --
  END store_agg_values;
  ------------------------------------------------------------------------
  PROCEDURE archive_ni_values(p_ni_cat        VARCHAR2,
                              p_tot_contribs  NUMBER,
                              p_earnings      NUMBER DEFAULT NULL,
                              p_ees_contribs  NUMBER DEFAULT NULL,
                              p_ni_able_lel   NUMBER DEFAULT NULL,
                              p_ni_able_et    NUMBER DEFAULT NULL,
                              p_ni_able_uel   NUMBER DEFAULT NULL,
                              p_ni_able_uap   NUMBER DEFAULT NULL, -- 8357870
			      p_ni_able_auel  NUMBER DEFAULT NULL, -- EOY 07/08
                              p_ers_rebate    NUMBER DEFAULT NULL,
                              p_ees_rebate    NUMBER DEFAULT NULL,
                              p_scon          VARCHAR2 DEFAULT NULL) IS
  -- Procedure used to archive a 'row' of balance values for a given
  -- NI Category and (where necessary) SCON.
  -- It archives the values individually by calling archive_ni_value.
  --
  -- This procedure performs NI Multiple Assignment Logic (Pt. II)
  -- which will archive a reportable set of values if the asg is a single asg.
  -- If the the asg is a multi-asg, a non-reportable set of values will be
  -- archived and the values added to those in the cache (these are later
  -- archived against the primary asg in Pt. III)
    --
    l_proc             CONSTANT VARCHAR2(40):= g_package||'archive_ni_values';
    --
    l_report_values          NUMBER(1);
    l_refund_flag            VARCHAR2(1);
    l_index1                 binary_integer;
    --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc,1);
    --
    IF l_multiple_asg_flag = 'Y' THEN
      -- Do Multiple Assignment Logic Part II
      --
      -- values are to be archived as non-reportable:
      l_report_values := 0;
      --
      -- marker balance issue - from 06-APR-2000 not valid to only report
      -- category where total contributions are not zero.
      -- Removed previous total contribs check.
      -- Add the balances for this assignment to the NI balances
      -- (per NI category) for the person in the NI Balance Totals table
      --
      hr_utility.set_location(l_proc,10);
      -- Find appropriate row in NI values table:
        BEGIN
          l_index1:=0;
          LOOP
            l_index1 := l_index1 + 1;
            EXIT WHEN g_ni_balance_totals(l_index1).ni_cat = p_ni_cat
              AND nvl(g_ni_balance_totals(l_index1).scon,'NONE')
                                                    = nvl(p_scon,'NONE');
          END LOOP;
          -- Add balances to those in table:
          hr_utility.set_location(l_proc||' '||l_index1,15);
          g_ni_balance_totals(l_index1).tot_contribs :=
            g_ni_balance_totals(l_index1).tot_contribs + nvl(p_tot_contribs,0);
          g_ni_balance_totals(l_index1).earnings :=
            g_ni_balance_totals(l_index1).earnings + nvl(p_earnings,0);
          g_ni_balance_totals(l_index1).ees_contribs :=
            g_ni_balance_totals(l_index1).ees_contribs + nvl(p_ees_contribs,0);
          g_ni_balance_totals(l_index1).ni_able_lel :=
            g_ni_balance_totals(l_index1).ni_able_lel + nvl(p_ni_able_lel,0);
          g_ni_balance_totals(l_index1).ni_able_et :=
            g_ni_balance_totals(l_index1).ni_able_et + nvl(p_ni_able_et,0);
          g_ni_balance_totals(l_index1).ni_able_uel :=
            g_ni_balance_totals(l_index1).ni_able_uel + nvl(p_ni_able_uel,0);
          -- 8357870 begin
          g_ni_balance_totals(l_index1).ni_able_uap :=
            g_ni_balance_totals(l_index1).ni_able_uap + nvl(p_ni_able_uap,0);
          -- 8357870 end
          -- EOY 07/08 Begin
          g_ni_balance_totals(l_index1).ni_able_auel :=
            g_ni_balance_totals(l_index1).ni_able_auel + nvl(p_ni_able_auel,0);
          -- EOY 07/08 End
          g_ni_balance_totals(l_index1).ers_rebate :=
            g_ni_balance_totals(l_index1).ers_rebate + nvl(p_ers_rebate,0);
          g_ni_balance_totals(l_index1).ees_rebate :=
            g_ni_balance_totals(l_index1).ees_rebate + nvl(p_ees_rebate,0);
        EXCEPTION WHEN no_data_found THEN
          -- row not found, insert new one:
          hr_utility.set_location(l_proc||' '||l_index1,20);
          g_ni_balance_totals(l_index1).ni_cat       := p_ni_cat;
          g_ni_balance_totals(l_index1).scon         := p_scon;
          g_ni_balance_totals(l_index1).tot_contribs := nvl(p_tot_contribs,0);
          g_ni_balance_totals(l_index1).earnings     := nvl(p_earnings,0);
          g_ni_balance_totals(l_index1).ees_contribs := nvl(p_ees_contribs,0);
          g_ni_balance_totals(l_index1).ni_able_lel  := nvl(p_ni_able_lel,0);
          g_ni_balance_totals(l_index1).ni_able_et   := nvl(p_ni_able_et,0);
          g_ni_balance_totals(l_index1).ni_able_uel  := nvl(p_ni_able_uel,0);
          g_ni_balance_totals(l_index1).ni_able_uap  := nvl(p_ni_able_uap,0); -- 8357870
	  g_ni_balance_totals(l_index1).ni_able_auel := nvl(p_ni_able_auel,0); --EOY 07/08
          g_ni_balance_totals(l_index1).ers_rebate   := nvl(p_ers_rebate,0);
          g_ni_balance_totals(l_index1).ees_rebate   := nvl(p_ees_rebate,0);
        END; -- Find appropriate row in NI values table
      --
    ELSE
      -- not a multi-asg so values are to be archived as reportable.
      l_report_values := 1;
    END IF;  -- End of Multiple Assignment Logic Part II
    --
    -- Archive the values:
    -- Nb.  Need to archive the Total Contributions item (even if 0) as the
    -- values view relies on this item being in the archive in order
    -- for a row to be returned (it uses this item to obtain the
    -- contexts of reportable, NI Cat and (if necessary) SCON.
    --
    -- EOY 2004, archive a value of R in the ni_refund or
    -- ni_scon_refund DBI, if the Total Contributions
    -- are negative.
    --
    IF p_tot_contribs < 0 then
       l_refund_flag := 'R';
    ELSE
       l_refund_flag := '';
    END IF;
    --
    IF p_scon IS NOT NULL THEN
      hr_utility.set_location(l_proc,30);
      archive_ni_value(g_ni_scon_earnings_eid,p_earnings,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_ees_contribution_eid,p_ees_contribs,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_tot_contribution_eid,p_tot_contribs,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_able_et_eid,p_ni_able_et,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_able_uel_eid,p_ni_able_uel,
                       l_report_values,p_ni_cat,p_scon);
      -- 8357870 Begin
      archive_ni_value(g_ni_scon_able_uap_eid,p_ni_able_uap,
                       l_report_values,p_ni_cat,p_scon);
      -- 8357870 End
      --EOY 07/08 Begin
      archive_ni_value(g_ni_scon_able_auel_eid,p_ni_able_auel,
                       l_report_values,p_ni_cat,p_scon);
      --EOY 07/08 End
      archive_ni_value(g_ni_scon_able_lel_eid,p_ni_able_lel,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_ers_rebate_eid,p_ers_rebate,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_ees_rebate_eid,p_ees_rebate,
                       l_report_values,p_ni_cat,p_scon);
      archive_ni_value(g_ni_scon_refund_eid, l_refund_flag,
                       l_report_values,p_ni_cat,p_scon);
    ELSE
      hr_utility.set_location(l_proc,40);
      archive_ni_value(g_ni_earnings_eid,p_earnings,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_ees_contribution_eid,p_ees_contribs,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_tot_contribution_eid,p_tot_contribs,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_able_et_eid,p_ni_able_et,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_able_uel_eid,p_ni_able_uel,
                       l_report_values,p_ni_cat);
      -- 8357870 Begin
      archive_ni_value(g_ni_able_uap_eid,p_ni_able_uap,
                       l_report_values,p_ni_cat);
      -- 8357870 end
      --EOY 07/08 Begin
      archive_ni_value(g_ni_able_auel_eid,p_ni_able_auel,
                       l_report_values,p_ni_cat);
      --EOY 07/08 End
      archive_ni_value(g_ni_able_lel_eid,p_ni_able_lel,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_ers_rebate_eid,p_ers_rebate,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_ees_rebate_eid,p_ees_rebate,
                       l_report_values,p_ni_cat);
      archive_ni_value(g_ni_refund_eid, l_refund_flag,
                       l_report_values,p_ni_cat);
    END IF;
    hr_utility.set_location(' Leaving: '||l_proc,100);
  END archive_ni_values;
  --
  PROCEDURE remove_null_address_lines(p_address_line1 IN OUT NOCOPY VARCHAR2,
                                      p_address_line2 IN OUT NOCOPY VARCHAR2,
                                      p_address_line3 IN OUT NOCOPY VARCHAR2,
                                      p_address_line4 IN OUT NOCOPY VARCHAR2)
  IS
     --
     TYPE t_lines IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
     l_lines t_lines;
     l_dummy VARCHAR2(1000);
     l_proc  VARCHAR2(100) := 'pay_gb_eoy_archive.remove_null_address_lines';
     --
  BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     hr_utility.trace('p_address_line1='||p_address_line1);
     hr_utility.trace('p_address_line2='||p_address_line2);
     hr_utility.trace('p_address_line3='||p_address_line3);
     hr_utility.trace('p_address_line4='||p_address_line4);
     --
     l_lines(1) := p_address_line1;
     l_lines(2) := p_address_line2;
     l_lines(3) := p_address_line3;
     l_lines(4) := p_address_line4;
     --
     FOR i IN 1..3 LOOP
        FOR j IN 1..(4-i) LOOP
           IF l_lines(j) IS NULL and l_lines(j+1) IS NOT NULL THEN
              l_lines(j) := l_lines(j+1);
              l_lines(j+1) := NULL;
           END IF;
        END LOOP;
     END LOOP;
     --
     hr_utility.set_location(l_proc,10);
     --
     p_address_line1 := l_lines(1);
     p_address_line2 := l_lines(2);
     p_address_line3 := l_lines(3);
     p_address_line4 := l_lines(4);
     --
     hr_utility.set_location('Leaving: '||l_proc,20);
     hr_utility.trace('p_address_line1='||p_address_line1);
     hr_utility.trace('p_address_line2='||p_address_line2);
     hr_utility.trace('p_address_line3='||p_address_line3);
     hr_utility.trace('p_address_line4='||p_address_line4);
  END;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_proc,1);
  hr_utility.trace('p_assactid='||p_assactid);
  -- Get the AAC level info.
  OPEN csr_asg_act_info(p_assactid);
  FETCH csr_asg_act_info INTO l_assignment_id,
                              l_effective_end_date,
                              l_tax_ref_transfer,
                              l_agg_active_start,
                              l_agg_active_end;
  CLOSE csr_asg_act_info;
  hr_utility.trace('After csr_asg_act_info, l_assignment_id='||l_assignment_id);
  hr_utility.trace('l_effective_end_date='||fnd_date.date_to_displaydate(l_effective_end_date));
  hr_utility.trace('l_tax_ref_transfer='||l_tax_ref_transfer);
  hr_utility.trace('l_agg_active_start='||fnd_date.date_to_displaydate(l_agg_active_start));
  hr_utility.trace('l_agg_active_end='||fnd_date.date_to_displaydate(l_agg_active_end));
  -- Bug fix for 3699865 - get the final process date
  OPEN csr_asg_last_process_date(l_assignment_id);
  FETCH csr_asg_last_process_date INTO l_final_process_date;
  CLOSE csr_asg_last_process_date;
  hr_utility.trace('After csr_asg_last_process_date, l_final_process_date='||fnd_date.date_to_displaydate(l_final_process_date));
  IF l_final_process_date is not null
     and nvl(l_tax_ref_transfer, 'N') = 'N'
     and l_final_process_date < l_effective_end_date THEN
    -- added extra conditions above for 5199746, so that final process date
    -- is used to retrieve person/asg details and balances only when
    -- asg has not been transferred to another PAYE Ref before termination and
    -- the final process date is earlier than the assignment's end date on
    -- the PAYE Ref at the time of action creation
    l_effective_end_date := l_final_process_date;
  END IF;

  -- Get basic Asg info.
  OPEN csr_basic_asg_info (l_assignment_id, l_effective_end_date);
  FETCH csr_basic_asg_info INTO l_payroll_id,
                            l_assignment_number,
                            l_person_id,
                            l_organization_id,
                            l_location_id,
                            l_people_group_id,
                            l_period_of_service_id;
  CLOSE csr_basic_asg_info;
  --
  hr_utility.trace('After csr_basic_asg_info, l_payroll_id='||l_payroll_id);
  hr_utility.trace('l_assignment_number='||l_assignment_number);
  hr_utility.trace('l_assignment_number='||l_assignment_number);
  hr_utility.trace('l_person_id='||l_person_id);
  hr_utility.trace('l_person_id='||l_person_id);
  hr_utility.trace('l_organization_id='||l_organization_id);
  hr_utility.trace('l_location_id='||l_location_id);
  hr_utility.trace('l_people_group_id='||l_people_group_id);
  hr_utility.trace('l_period_of_service_id='||l_period_of_service_id);
  --
    IF l_assignment_number is null then
    --
    hr_utility.trace('Assignment has been updated or terminated');
    -- 1.The direct match asg and end date has not been found,
    --   Check whether there are any asgs current at this date,
    --   and use the adjusted end date.
    --
    OPEN csr_basic_inf_current(l_assignment_id, l_effective_end_date);
    FETCH csr_basic_inf_current INTO l_adj_eff_end_date,
                                     l_payroll_id,
                                     l_assignment_number,
                                     l_person_id,
                                     l_organization_id,
                                     l_location_id,
                                     l_people_group_id,
                                     l_period_of_service_id;
    IF csr_basic_inf_current%FOUND then
       -- Set the eff end to the one of the current row
       l_effective_end_date := l_adj_eff_end_date;
       hr_utility.trace('After csr_basic_inf_current, l_adj_eff_end_date='||fnd_date.date_to_displaydate(l_adj_eff_end_date));
       hr_utility.trace('l_payroll_id='||l_payroll_id);
       hr_utility.trace('l_assignment_number='||l_assignment_number);
       hr_utility.trace('l_person_id='||l_person_id);
       hr_utility.trace('l_organization_id='||l_organization_id);
       hr_utility.trace('l_location_id='||l_location_id);
       hr_utility.trace('l_people_group_id='||l_people_group_id);
       hr_utility.trace('l_period_of_service_id='||l_period_of_service_id);
       hr_utility.trace('ASSIGNMENT UPDATED: '||to_char(l_assignment_id));
       hr_utility.trace('End date used: '||to_char(l_adj_eff_end_date));
       l_assignment_message :=
           'The Assignment has been updated during this process';
       archive_asg_info(g_assignment_message_eid, l_assignment_message);
    END IF;
    CLOSE csr_basic_inf_current;
    --
    IF l_assignment_number is null then  -- Still not matched.
       --
       -- 2.Check whether this has been terminated and use the
       --   terminated End Date:
       --
       open csr_basic_inf_term(l_assignment_id, l_effective_end_date);
       FETCH csr_basic_inf_term INTO l_adj_eff_end_date,
                                     l_payroll_id,
                                     l_assignment_number,
                                     l_person_id,
                                     l_organization_id,
                                     l_location_id,
                                     l_people_group_id,
                                     l_period_of_service_id;
       IF csr_basic_inf_term%FOUND then
          -- Set the eff end to the adjusted one from the
          -- terminated assignment.
          l_effective_end_date := l_adj_eff_end_date;
/*          hr_utility.trace('After csr_basic_inf_term, l_adj_eff_end_date='||fnd_date.date_to_displaydate(l_adj_eff_end_date));
          hr_utility.trace('l_payroll_id='||l_payroll_id);
          hr_utility.trace('l_assignment_number='||l_assignment_number);
          hr_utility.trace('l_person_id='||l_person_id);
          hr_utility.trace('l_organization_id='||l_organization_id);
          hr_utility.trace('l_location_id='||l_location_id);
          hr_utility.trace('l_people_group_id='||l_people_group_id);
          hr_utility.trace('l_period_of_service_id='||l_period_of_service_id); */
          hr_utility.trace('TERMINATION: '||to_char(l_assignment_id));
          hr_utility.trace('End date used: '||to_char(l_adj_eff_end_date));
          l_assignment_message :=
              'The Assignment has been Terminated during this process';
             archive_asg_info(g_assignment_message_eid, l_assignment_message);
       ELSE
          -- Both cursors not found, so archive a default error msg.
          -- This should never be raised but placed to trap error where
          -- the asg has been somehow purged.
          hr_utility.trace('ASG NOT FOUND: '||to_char(l_assignment_id));
          l_assignment_message :=
             'ERROR: Assignment Cannot be found from archived info';
          archive_asg_info(g_assignment_message_eid, l_assignment_message);
       END IF;
       CLOSE csr_basic_inf_term;
    --
    ELSE
       -- Assignment number is not null
       IF l_payroll_id IS NULL THEN
          -- Payroll is null
          l_assignment_message :=
             'ERROR: Payroll not found on the assignment as at '||fnd_date.date_to_canonical(l_effective_end_date);
          archive_asg_info(g_assignment_message_eid, l_assignment_message);
       END IF;
    END IF;
  ELSE
     -- Assignment number is not null
     IF l_payroll_id IS NULL THEN
        -- Payroll is null
        l_assignment_message :=
           'ERROR: Payroll not found on the assignment as at '||fnd_date.date_to_canonical(l_effective_end_date);
        archive_asg_info(g_assignment_message_eid, l_assignment_message);
     END IF;
  --
  END IF;
  --
  IF l_payroll_id IS NULL THEN
     hr_utility.trace('l_assignment_message='||l_assignment_message);
     fnd_file.put_line(fnd_file.log, 'Error encountered while processing assignment action '||p_assactid);
     fnd_file.put_line(fnd_file.log, l_assignment_message);
     l_dummy := write_output(p_assignment_number => l_assignment_number,
                       p_full_name => l_last_name||', '||l_first_name,
                       p_message_type => 'E',
                       p_message => 'Assignment action '||p_assactid||' encountered '||l_assignment_message);
     RAISE ASG_ACTION_ERROR;
  END IF;
  --
  -- Fetch Payroll info into table structure to the local vars from
  -- the current plsql tab vals.
  --
  BEGIN
  --
     l_payroll_start_year        := g_pay_start_yr_tab(l_payroll_id);
     l_payroll_end_year          := g_pay_end_yr_tab(l_payroll_id);
     l_payroll_period_type       := g_pay_period_typ_tab(l_payroll_id);
     l_payroll_max_period_number := g_pay_max_per_no_tab(l_payroll_id);
     l_payroll_tax_ref           := g_pay_tax_ref_tab(l_payroll_id);
     l_payroll_tax_dist          := g_pay_tax_dist_tab(l_payroll_id);
     --
     l_number_per_fiscal_yr      := g_no_per_fiscal_yr(l_payroll_id);
     hr_utility.trace('Payroll Info Cached previously for: '||to_char(l_payroll_id));
  --
  END;
  --
  -- Get asg Start date
  hr_utility.trace('Calling csr_asg_start');
  hr_utility.trace('With: '||to_char(l_assignment_id)||','||to_char(l_effective_end_date)||','||to_char(l_payroll_start_year)||','||to_char(l_payroll_end_year));
  OPEN csr_asg_start(l_assignment_id, l_effective_end_date,
                     l_payroll_start_year, l_payroll_end_year);
  FETCH csr_asg_start INTO l_effective_start_date;
  CLOSE csr_asg_start;
  hr_utility.trace('After csr_asg_start, l_effective_start_date='||fnd_date.date_to_displaydate(l_effective_start_date));
  --
  hr_utility.trace('Action type: '||l_action_type);
  --
  -- Get basic person info
  OPEN csr_person_info(l_person_id);
  FETCH csr_person_info INTO  l_last_name,
                              l_first_name,
                              l_middle_name,
                              l_date_of_birth,
                              l_title,
                              l_expense_check_to_address,
                              l_ni_number,
                              l_sex,
                              l_pensioner_indicator,
                              l_aggregated_paye_flag,
                              l_multiple_asg_flag;
  CLOSE csr_person_info;
  hr_utility.trace('After csr_person_info, l_last_name='||l_last_name);
  hr_utility.trace('l_first_name='||l_first_name);
  hr_utility.trace('l_middle_name='||l_middle_name);
  hr_utility.trace('l_date_of_birth='||fnd_date.date_to_displaydate(l_date_of_birth));
  hr_utility.trace('l_title='||l_title);
  hr_utility.trace('l_expense_check_to_address='||l_expense_check_to_address);
  hr_utility.trace('l_ni_number='||l_ni_number);
  hr_utility.trace('l_sex='||l_sex);
  hr_utility.trace('l_pensioner_indicator='||l_pensioner_indicator);
  hr_utility.trace('l_aggregated_paye_flag='||l_aggregated_paye_flag);
  hr_utility.trace('l_multiple_asg_flag='||l_multiple_asg_flag);
  --
  hr_utility.trace('Before get_asg_active_range, l_payroll_tax_ref='||l_payroll_tax_ref);
  hr_utility.trace('l_payroll_tax_dist='||l_payroll_tax_dist);
  hr_utility.trace('l_assignment_id='||l_assignment_id);
  OPEN get_asg_active_range(l_assignment_id, l_payroll_tax_dist||'/'||l_payroll_tax_ref);
  FETCH get_asg_active_range INTO l_active_start, l_active_end;
  CLOSE get_asg_active_range;
  hr_utility.trace('After get_asg_active_range.');
  hr_utility.trace('l_active_start='||fnd_date.date_to_displaydate(l_active_start));
  hr_utility.trace('l_active_end='||fnd_date.date_to_displaydate(l_active_end));
  --
  -- set termination type and date.
  IF l_tax_ref_transfer = 'N' THEN
    --
    hr_utility.set_location(l_proc,10);
    -- not a tax reference transfer.
    OPEN csr_termination(l_period_of_service_id,
                         l_effective_end_date);
    FETCH csr_termination INTO l_actual_termination_date,
                               l_last_std_process_date,
                               l_termination_type;
    CLOSE csr_termination;
    hr_utility.trace('After csr_termination, l_actual_termination_date='||fnd_date.date_to_displaydate(l_actual_termination_date));
    hr_utility.trace('l_last_std_process_date='||fnd_date.date_to_displaydate(l_last_std_process_date));
    hr_utility.trace('l_termination_type='||l_termination_type);
    IF l_multiple_asg_flag = 'Y' THEN
       -- for multiple assignment check if aggregated active end date
       -- is before the actual termination date and EOY, if yes then set
       -- termination date to aggregated active end date
       IF l_agg_active_end < least(nvl(l_actual_termination_date, hr_general.end_of_time), g_end_year) THEN
          l_termination_date := l_agg_active_end;
       END IF;
    ELSE
       -- for non aggregated assignments check if this assignments
       -- active end date is before the actual termination date and EOY, if
       -- yes then set termination date to this assignment's active
       -- end date
       IF l_active_end < least(nvl(l_actual_termination_date, hr_general.end_of_time), g_end_year) THEN
          l_termination_date := l_active_end;
       END IF;
    END IF;
    --
    IF l_termination_date IS NOT NULL THEN
       -- assignment ended before the actual termination and EOY hence
       -- leave termination date as the last active status date
       NULL;
    ELSIF l_termination_date IS NULL AND l_actual_termination_date IS NOT NULL THEN
       -- assignment active end date same as actual termination hence set
       -- termination date to actual termination date, this is employee
       -- termination
       l_termination_date := l_actual_termination_date;
       -- since its a employee termination, make further checks
       IF nvl(l_last_std_process_date, g_end_year+1) <= g_end_year THEN
          -- Employee has been terminated and last_std process is before
          -- the end of current tax year, do nothing here, leave
          -- l_termination_date as actual_termination date to report on
          -- P14 EDI and to ensure P60 is not generated
          NULL;
          hr_utility.trace('Employee terminated and last std process before EOY.');
       ELSE
          -- Employee has been terminated but last_std_process_date is
          -- after current tax year hence need to check if P45 has been
          -- issued, if yes then leave l_termination_date as actual
          -- termination date else ensire l_termination_date is null
          -- so that P60 can be generated
          l_date_of_manual_p45_issue := NULL;
          l_date_of_manual_p45_issue := pay_p45_pkg.get_p45_eit_manual_issue_dt(l_assignment_id);
          hr_utility.trace('After get_p45_eit_manual_issue_dt, manual issue date='||fnd_date.date_to_displaydate(l_date_of_manual_p45_issue));
          --
          IF l_date_of_manual_p45_issue IS NOT NULL
             AND l_date_of_manual_p45_issue <= g_end_year THEN
             -- manual P45 issued in current tax year hence leave
             -- l_termination_date as actual termination date to report
             -- on p14 EDI and to ensure P60 is not generated
             NULL;
          ELSIF l_date_of_manual_p45_issue IS NOT NULL THEN
             -- manual p45 issued after EOY hence don't archive acual
             -- termination date so that p60 can be generated for current
             -- tax year
             l_termination_date := NULL;
          ELSE
             l_p45_issue_date := NULL;
             -- Check when was P45 issued
             pay_p45_pkg.get_p45_asg_action_id(l_assignment_id,
                                               l_p45_action_id,
                                               l_p45_issue_date,
                                               l_p45_action_seq);
             hr_utility.trace('After get_p45_asg_action_id, l_p45_issue_date='||fnd_date.date_to_displaydate(l_p45_issue_date));
             hr_utility.trace('l_p45_action_id='||l_p45_action_id);

             IF l_p45_issue_date IS NULL THEN
                pay_p45_pkg.get_p45_agg_asg_action_id(l_assignment_id,
                                                    l_p45_agg_asg_id,
                                                    l_p45_final_pay_date,
                                                    l_p45_issue_date,
                                                    l_p45_action_id);
                hr_utility.trace('After get_p45_agg_asg_action_id, l_p45_issue_date='||fnd_date.date_to_displaydate(l_p45_issue_date));

             END IF;

	     -- Start of BUG 5671777-1
             --
             -- fetch final payment date for the aggregated p45 assignment action id
             --
             IF l_p45_issue_date IS NOT NULL THEN
                open csr_get_final_payment_date(l_p45_action_id);
                fetch csr_get_final_payment_date into l_p45_final_pay_date;
                close csr_get_final_payment_date;
              END IF;
              -- End of BUG 5671777-1
              --
	      -- Changed l_p45_issue_date to l_p45_final_pay_date BUG 5671777-1
	      --
		  IF nvl(nvl(l_p45_final_pay_date,l_p45_issue_date),g_end_year+1) <= g_end_year THEN
                --IF nvl(l_p45_issue_date, g_end_year+1) <= g_end_year THEN
                -- p45 has been issued before the end of tax year hence
                -- leave l_termination_date as actual_termination_date to
                -- report on p14 EDI and to ensure P60 is not generated
                NULL;
                hr_utility.trace('P45 has been issued before the EOY.');
             ELSE
                -- p45 has not been issued before EOY hence don't archive
                -- actual termination date so that p60 can be generated,
                -- set l_termination_date to NULL
                l_termination_date := NULL;
             END IF;
          END IF; -- l_date_of_manual_p45_issue IS (NOT) NULL
       END IF; -- l_last_std_process_date IS (NOT) in the current tax year
    END IF; -- Termination date (NOT) NULL
  ELSE
    hr_utility.set_location(l_proc,20);
    -- asg is tax ref transfer
    l_termination_type := 'R';
    l_termination_date := l_effective_end_date;
  END IF;
  --
  -- get last action this year, using stat dates.
  --
  hr_utility.trace('Calling csr_last_action');
  hr_utility.trace('With asg: '|| to_char(l_assignment_id));
  hr_utility.trace('Eff start: '|| to_char(l_effective_start_date));
  hr_utility.trace('Eff end: '|| to_char(l_effective_end_date));
  hr_utility.trace('Start Yr: '||to_char(g_start_year));
  hr_utility.trace('End Yr: '||to_char(g_end_year));
  hr_utility.trace('Tax Ref Xfer: '||l_tax_ref_transfer);
  OPEN csr_last_action(l_assignment_id, l_effective_start_date,
                       l_effective_end_date, g_start_year,
                       g_end_year, l_tax_ref_transfer);
  FETCH csr_last_action INTO  l_last_asg_action_id,
                              l_last_effective_date;
  CLOSE csr_last_action;
  hr_utility.trace('After csr_last_action, l_last_asg_action_id='||l_last_asg_action_id);
  hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
  --
  IF l_last_asg_action_id IS NOT NULL THEN
     OPEN csr_action_details(l_last_asg_action_id);
     FETCH csr_action_details into l_action_type;
     CLOSE csr_action_details;
     hr_utility.trace('After csr_action_details, l_action_type='||l_action_type);
  END IF;
  --
  -- Get Non-NI balances and codes used to determine whether to further
  -- process the asg.
  IF l_last_asg_action_id IS NOT NULL THEN
     /* IF l_sex = 'F' THEN  rerstored as a part of 2987008
                            was earlier commented out for 2003,
                           And now commented out again for 2005, BUG 4011263 */
      l_smp   := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_smp_id);
     /* END IF; */
    l_notional := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_notional_id);
    l_ssp   := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_ssp_id);
    --
    -- 3 Defined Balance checks, can remove these after April 03.
    --
    if g_sap_id is not null then
      l_sap   := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_sap_id);
    end if;
    --
    if g_spp_adopt_id is not null then
      l_spp_adopt :=
           100 * hr_dirbal.get_balance(l_last_asg_action_id,g_spp_adopt_id);
    end if;
    --
    if g_spp_birth_id is not null then
      l_spp_birth :=
           100 * hr_dirbal.get_balance(l_last_asg_action_id,g_spp_birth_id);
    end if;
    --
    -- Gross Pay includes Notional Pay balance
    --
    l_gross := (100 * hr_dirbal.get_balance(l_last_asg_action_id,g_gross_id)) +
                               l_notional;
    l_super := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_super_id);
    l_taxable := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                             g_taxable_id);
    l_student_loan := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                  g_student_loan_id);
    --
    l_ni_arrears := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                             g_ni_arrears_id);
    --
    -- Start of Bug 6271548
    -- fetch PAYE balance for checking whether this assignment reported in
    -- the P35 report or not
    l_paye  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_paye_id);

    -- fetch previous_taxable_pay,previous_tax_paid balances -- Bug 6271548
    --
    IF l_action_type <> 'V' THEN
      -- get paye element's run result id from last run
      hr_utility.trace('Before csr_tax_last_paye_run, l_last_asg_action_id='||l_last_asg_action_id);
      OPEN csr_tax_last_paye_run(l_last_asg_action_id);
      FETCH csr_tax_last_paye_run INTO l_tax_paye_run_result_id;
      hr_utility.trace('After csr_tax_last_paye_run, l_tax_paye_run_result_id='||l_tax_paye_run_result_id);
      IF l_tax_paye_run_result_id IS NULL THEN
         -- if paye was not calculated in last run then
         -- get the latest run in which it was
         hr_utility.trace('Before csr_tax_last_paye_run, l_assignment_id='||l_assignment_id);
         hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
         OPEN csr_tax_latest_paye_run(l_assignment_id, l_last_effective_date);
         FETCH csr_tax_latest_paye_run INTO l_tax_paye_run_result_id, l_paye_eff_date;
         hr_utility.trace('After csr_tax_last_paye_run, l_tax_paye_run_result_id='||l_tax_paye_run_result_id);
         hr_utility.trace('l_paye_eff_date='||fnd_date.date_to_displaydate(l_paye_eff_date));
         CLOSE csr_tax_latest_paye_run;
      ELSE
         -- PAYE run result found hence effective date for paye details is
         -- date of last assignment action
         l_paye_eff_date := l_last_effective_date;
         hr_utility.trace('l_paye_eff_date='||fnd_date.date_to_displaydate(l_paye_eff_date));
      END IF;
      CLOSE csr_tax_last_paye_run;
      -- most people will have had paye calculated on the last run.
      -- Pick these up
      hr_utility.trace('Before csr_tax_last_run, l_last_asg_action_id='||l_last_asg_action_id);
      OPEN csr_tax_last_run(l_last_asg_action_id);
      FETCH csr_tax_last_run INTO l_tax_run_result_id;
      hr_utility.trace('After csr_tax_last_run, l_tax_run_result_id='||l_tax_run_result_id);
      IF l_tax_run_result_id IS NULL THEN
        -- find the latest update
        hr_utility.trace('calling csr_tax_latest_run, non reversal');
         hr_utility.trace('Before csr_tax_latest_run, l_assignment_id='||l_assignment_id);
         hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
        OPEN csr_tax_latest_run(l_assignment_id, l_last_effective_date);
        FETCH csr_tax_latest_run INTO l_tax_run_result_id, l_paye_details_eff_date;
         hr_utility.trace('After csr_tax_latest_run, l_tax_run_result_id='||l_tax_run_result_id);
         hr_utility.trace('l_paye_details_eff_date='||fnd_date.date_to_displaydate(l_paye_details_eff_date));
        CLOSE csr_tax_latest_run;
      ELSE
        l_paye_details_eff_date := l_last_effective_date;
        hr_utility.trace('l_paye_details_eff_date='||fnd_date.date_to_displaydate(l_paye_details_eff_date));
      END IF;
      CLOSE csr_tax_last_run;
    ELSE
      -- find the latest update, as reversal action
        hr_utility.trace('calling csr_tax_latest_run, reversal');
        hr_utility.trace('Before csr_tax_latest_run, l_assignment_id='||l_assignment_id);
       hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
        OPEN csr_tax_latest_run(l_assignment_id, l_last_effective_date);
        FETCH csr_tax_latest_run INTO l_tax_run_result_id, l_paye_details_eff_date;
        CLOSE csr_tax_latest_run;
        hr_utility.trace('After csr_tax_latest_run, l_tax_run_result_id='||l_tax_run_result_id);
        hr_utility.trace('l_paye_details_eff_date='||fnd_date.date_to_displaydate(l_paye_details_eff_date));
        --
        OPEN csr_tax_latest_paye_run(l_assignment_id, l_last_effective_date);
        FETCH csr_tax_latest_paye_run INTO l_tax_paye_run_result_id, l_paye_eff_date;
        CLOSE csr_tax_latest_paye_run;
        hr_utility.trace('After csr_tax_latest_paye_run, l_tax_paye_run_result_id='||l_tax_paye_run_result_id);
        hr_utility.trace('l_paye_eff_date='||fnd_date.date_to_displaydate(l_paye_eff_date));
    END IF;
    --
    archive_asg_info(g_tax_run_result_id_eid, nvl(l_tax_paye_run_result_id, l_tax_run_result_id));
    --
    -- Get tax code.
    -- First try PAYE element run results because PAYE details
    -- element run result may not be the same as the one effective on
    -- regular payment date of a payroll with positive
    -- offset
    OPEN csr_tax_paye_result(l_tax_paye_run_result_id);
    FETCH csr_tax_paye_result INTO l_tax_code, l_w1_m1_indicator,
                                    l_previous_taxable_pay,
                                    l_previous_tax_paid;
    hr_utility.trace('After csr_tax_paye_result, l_tax_code='||l_tax_code);
    hr_utility.trace('l_w1_m1_indicator='||l_w1_m1_indicator);
    hr_utility.trace('l_previous_taxable_pay='||to_char(l_previous_taxable_pay));
    hr_utility.trace('l_previous_tax_paid='||to_char(l_previous_tax_paid));
    IF l_tax_code IS NULL THEN
       -- Get the details from the element entry on the added criteria that
       -- there exists an updating action id on the element_entry.  In other
       -- words, an entry achieved using an Update Recurring rule.
       -- Nb. both cursors used here select max(...) so a row is returned
       -- even if no tax details found.
       --
       OPEN csr_tax_details_entry(l_assignment_id, l_effective_end_date,
                               l_payroll_end_year, 'Y');
       FETCH csr_tax_details_entry INTO  l_tax_code, l_w1_m1_indicator,
                                      l_previous_taxable_pay,
                                      l_previous_tax_paid;
       hr_utility.set_location(l_proc||' '||l_tax_code||' '||
                               l_w1_m1_indicator,52);
       IF l_tax_code IS NULL THEN
         -- no update recurring, so retrieve the details from the run result.
         OPEN csr_tax_details_result(l_tax_run_result_id);
         FETCH csr_tax_details_result INTO l_tax_code, l_w1_m1_indicator,
                                       l_previous_taxable_pay,
                                       l_previous_tax_paid;
         hr_utility.set_location(l_proc||' '||l_tax_code||' '||
                                 l_w1_m1_indicator,54);
         IF l_tax_code IS NULL THEN
           -- If there is still no tax code, use the element entry query
           -- without the update recurring criteria.
           CLOSE csr_tax_details_entry;
           OPEN csr_tax_details_entry(l_assignment_id, l_effective_end_date,
                                      l_payroll_end_year, 'N');
           FETCH csr_tax_details_entry INTO  l_tax_code, l_w1_m1_indicator,
                                             l_previous_taxable_pay,
                                             l_previous_tax_paid;
           hr_utility.set_location(l_proc||' '||l_tax_code||' '||
                                   l_w1_m1_indicator,56);
           IF l_tax_code IS NOT NULL THEN
            IF l_aggregated_paye_flag = 'Y' THEN
               hr_utility.trace('This is an aggregated assignment.');
               --
               if l_w1_m1_indicator = 'C' then
                  l_w1_m1_indicator := ' ';
               else
                  hr_utility.trace('No of periods per year = '||g_no_per_fiscal_yr(l_payroll_id));
                  if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
                     l_w1_m1_indicator := 'M';
                  else
                     l_w1_m1_indicator := 'W';
                  end if;
               end if;
               hr_utility.trace('Aggregated tax code found so far='||g_agg_balance_totals.tax_code);
               hr_utility.trace('g_agg_balance_totals.paye_eff_date = '||fnd_date.date_to_displaydate(g_agg_balance_totals.paye_eff_date));
               -- this tax code is from the PAYE Details Entry, since it is an
               -- aggregated assignment therefore check if we already have a
               -- a tax code from a previously processed assignment of this employee
               IF g_agg_balance_totals.tax_code is NULL THEN
                  hr_utility.trace('Aggregated tax code found so far is NULL hence store '||l_tax_code||' as the aggregated tax code');
                  -- No tax code found on other assignments so far therefore store
                  -- tax code found on element entry of this assignment,
                  -- this value will be archived against the primary eoy action later
                  g_agg_balance_totals.tax_code := l_tax_code;
                  g_agg_balance_totals.tax_basis := l_w1_m1_indicator;
                  g_agg_balance_totals.pay_previous := l_previous_taxable_pay;
                  g_agg_balance_totals.tax_previous := l_previous_tax_paid;
                  g_agg_balance_totals.paye_eff_date := fnd_date.canonical_to_date('0001/01/01 00:00:00');
               END IF;
               --
               IF nvl(g_agg_balance_totals.week_53, ' ') = ' ' THEN
                  g_agg_balance_totals.week_53 := l_week_53_indicator;
               END IF;
            END IF; -- aggregated PAYE flag = Y
           END IF; -- tax code found on PAYE Details entry
         ELSE -- tax code found on PAYE Details Result
            IF l_aggregated_paye_flag = 'Y' THEN
               --
               if l_w1_m1_indicator = 'C' then
                  l_w1_m1_indicator := ' ';
               else
                  if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
                     l_w1_m1_indicator := 'M';
                  else
                     l_w1_m1_indicator := 'W';
                  end if;
               end if;
               -- this is aggregated assignment hence check whether this is the
               -- latest run result so far
               IF l_paye_details_eff_date >
                            g_agg_balance_totals.paye_eff_date THEN
                  -- this is the latest paye run results amongst aggregated
                  -- assignment, store values in the table to archive
                  -- against the primary eoy action later
                  g_agg_balance_totals.tax_code := l_tax_code;
                  g_agg_balance_totals.tax_basis := l_w1_m1_indicator;
                  g_agg_balance_totals.pay_previous := l_previous_taxable_pay;
                  g_agg_balance_totals.tax_previous := l_previous_tax_paid;
                  g_agg_balance_totals.paye_eff_date := l_paye_details_eff_date;
               END IF;
               --
               IF nvl(g_agg_balance_totals.week_53, ' ') = ' ' THEN
                  g_agg_balance_totals.week_53 := l_week_53_indicator;
               END IF;
            END IF; -- aggregated PAYE flag = Y
         END IF; -- null or nor null tax code in pay details resluts
         CLOSE csr_tax_details_result;
       END IF; -- tax code null on update recurring PAYE Details entry
       CLOSE csr_tax_details_entry;
       --
    ELSE -- tax code found on PAYE Reun Result
       IF l_aggregated_paye_flag = 'Y' THEN
          --
          if l_w1_m1_indicator = 'C' then
             l_w1_m1_indicator := ' ';
          else
             if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
                l_w1_m1_indicator := 'M';
             else
                l_w1_m1_indicator := 'W';
             end if;
          end if;
          -- this is aggregated assignment hence check whether this is the
          -- latest run result so far
          IF l_paye_eff_date > g_agg_balance_totals.paye_eff_date THEN
             -- these are the latest paye run results amongst aggregated
             -- assignment, store them in the table to archive
             -- against the primary eoy action later
             g_agg_balance_totals.tax_code := l_tax_code;
             g_agg_balance_totals.tax_basis := l_w1_m1_indicator;
             g_agg_balance_totals.pay_previous := l_previous_taxable_pay;
             g_agg_balance_totals.tax_previous := l_previous_tax_paid;
             g_agg_balance_totals.paye_eff_date := l_paye_eff_date;
          END IF;
          --
          IF nvl(g_agg_balance_totals.week_53, ' ') = ' ' THEN
             g_agg_balance_totals.week_53 := l_week_53_indicator;
          END IF;
       END IF; -- aggregated PAYE flag = 'Y'
    END IF; --found/not found tax code on PAYE reun result
    CLOSE csr_tax_paye_result;

    -- fetch NI x Total/Able balances for checking whether this assignment
    -- reported in the P35 report or not. -- Bug 6271548

    hr_utility.trace('fetching NI x Total/Able balances');
    -- NI A
    l_nia_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nia_tot_id);
    l_nia_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nia_able_id);

    -- NI B
    l_nib_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id, g_nib_tot_id);
    l_nib_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                 g_nib_able_id);

    -- NI C
    l_nic_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nic_tot_id);
    l_nic_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                 g_nic_able_id);

    -- NI D
    l_nid_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nid_tot_id);
    l_nid_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nid_able_id);

    -- NI E
    l_nie_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_tot_id);
    l_nie_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
						g_nie_able_id);

    -- NI J
    l_nij_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nij_tot_id);
    l_nij_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nij_able_id);

    -- NI L
    l_nil_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nil_tot_id);
    l_nil_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nil_able_id);

    -- NI F,G,S
    hr_utility.trace('fetching NI x Total/Able balances for F,G,S category');
    DECLARE
    l_sum_ni_tot      NUMBER:= 0;
    l_sum_ni_able     NUMBER:= 0;
    l_ni_ers          NUMBER:= 0;

    BEGIN
        OPEN csr_get_scon_bal(l_last_asg_action_id,g_scon_input_id,
                                  g_category_input_id, g_ni_id);
        LOOP
        FETCH csr_get_scon_bal INTO l_ni_cat, l_scon, l_ni_able,
                                    l_ni_tot, l_ni_ees, l_ni_ers,
                                    l_ni_able_et,l_ni_able_lel,l_ni_able_uel,
                                    l_ni_able_uap, -- 8357870
				    --EOY 07/08 Begin
                                    l_ni_able_auel,
                                    --EOY 07/08 End
				    l_ers_rebate,
                                    l_ees_rebate, l_rebate_emp;
         EXIT WHEN csr_get_scon_bal%notfound;

         l_sum_ni_tot      := l_sum_ni_tot      + l_ni_tot;
         l_sum_ni_able     := l_sum_ni_able     + l_ni_able;

         END LOOP;
         CLOSE csr_get_scon_bal;

    l_ni_tot  := l_sum_ni_tot;
    l_ni_able := l_sum_ni_able;
    END;

     hr_utility.trace('l_ni_tot '||l_ni_tot);
     hr_utility.trace('l_ni_able '||l_ni_able );
  END IF;

  -- added additional conditions to check whether this assignment
  -- reported in the P35 report or not.

 /* IF l_last_asg_action_id IS NULL OR -- Do not process this assignment
     (l_termination_date < l_payroll_start_year AND
        l_gross = 0 AND l_taxable = 0 AND l_ssp = 0 AND l_smp = 0 AND
        l_student_loan = 0 AND
        l_super >= 0 AND l_ni_tot = 0 AND l_ni_able = 0)*/

    IF l_last_asg_action_id IS NULL OR -- Do not process this assignment
     ( l_termination_date < l_payroll_start_year AND l_taxable = 0 AND
       l_paye =0 AND l_previous_taxable_pay = 0 AND l_previous_tax_paid =0
       AND l_super = 0 AND l_ssp = 0 AND l_smp = 0 AND l_sap =0 AND
        l_spp_adopt = 0 AND l_spp_birth = 0 AND l_student_loan <= 0 AND l_ni_arrears = 0
        AND (l_nia_tot = 0 AND l_nia_able = 0 AND l_nib_tot = 0 AND l_nib_able = 0 AND
        l_nic_tot = 0 AND l_nic_able = 0 AND l_nid_tot = 0 AND l_nid_able = 0 AND
        l_nie_tot = 0 AND l_nie_able = 0 AND l_nij_tot = 0 AND l_nij_able = 0 AND
        l_nil_tot = 0 AND l_nil_able = 0 AND l_ni_tot = 0 AND l_ni_able = 0 ))
  -- End of Bug 6271548
  THEN
    hr_utility.trace('Do Not Process asg any further');
    -- Do not process this assignment any further and don't archive
    -- info extracted so far
    NULL;
  ELSE
    hr_utility.set_location(l_proc,30);
    -- archive info extracted so far
    archive_asg_info(g_termination_type_eid,l_termination_type);
    archive_asg_info(g_payroll_id_eid,l_payroll_id);
    archive_asg_info(g_assignment_number_eid,l_assignment_number);
    archive_asg_info(g_person_id_eid,l_person_id);
    archive_asg_info(g_organization_id_eid,l_organization_id);
    archive_asg_info(g_location_id_eid,l_location_id);
    archive_asg_info(g_people_group_id_eid,l_people_group_id);
    archive_asg_info(g_effective_start_date_eid,
                     fnd_date.date_to_canonical(l_effective_start_date));
    archive_asg_info(g_termination_date_eid,
                     fnd_date.date_to_canonical(l_termination_date));
    archive_asg_info(g_last_asg_action_id_eid,l_last_asg_action_id);
    archive_asg_info(g_last_effective_date_eid,
                     fnd_date.date_to_canonical(l_last_effective_date));
    --
    -- Now fetch more asg info.
    --
    IF l_multiple_asg_flag = 'Y' THEN
      -- Do Multiple Assignment Logic Part I
      --
      IF g_masg_person_id <> l_person_id
        OR g_masg_period_of_service_id <> l_period_of_service_id -- Bug 3784871
        OR g_masg_active_start <> l_agg_active_start
        OR g_masg_active_end <> l_agg_active_end
        OR g_masg_tax_ref_num <> l_payroll_tax_ref
      THEN
        -- 1st assignment to be processed for this person/tax ref.
        empty_masg_cache;
	-- Bug 6761725 Assigning the false value to global for archiving the tax code details
	g_paye_archive := FALSE;
        -- Prime the cache:
        g_masg_person_id   := l_person_id;
        g_masg_period_of_service_id   := l_period_of_service_id; -- Bug 3784871
        g_masg_active_start := l_agg_active_start;
        g_masg_active_end := l_agg_active_end;
        g_masg_tax_ref_num := l_payroll_tax_ref;
        IF g_permit_number IS NOT NULL THEN
          -- a permit was specified through SRS.
          --
          hr_utility.set_location(l_proc,35);
          -- Check that this person does not have assignments in
          -- different permits:
          hr_utility.trace('Calling csr_get_invalid_multiple_asg');
          OPEN csr_get_invalid_multiple_asg(l_person_id, l_payroll_id,
                                            l_payroll_start_year,
                                            l_payroll_end_year,
                                            l_payroll_tax_ref);
          FETCH csr_get_invalid_multiple_asg INTO l_dummy;
          IF csr_get_invalid_multiple_asg%FOUND THEN
            g_has_non_extracted_masgs := true;
          END IF;
          CLOSE csr_get_invalid_multiple_asg;
        END IF;  -- 1st asg
      END IF;
      IF g_has_non_extracted_masgs THEN
        -- error the assignment
        hr_utility.set_message(801, 'PAY_78000_MULTIPLE_PERMIT_ASG');
        hr_utility.raise_error;
      END IF;
    END IF;   -- End of Multiple Assignment Logic Part I
    --
    OPEN csr_director(l_person_id);
    FETCH csr_director INTO l_director_indicator;
    CLOSE csr_director;
---

    --
    IF l_multiple_asg_flag = 'Y' THEN
       IF l_agg_active_start BETWEEN g_start_year AND g_end_year THEN
          l_start_of_emp := l_agg_active_start;
       ELSE
          l_start_of_emp := NULL;
       END IF;
    ELSE
-- Modifications for the bug 8452959 Start

      IF l_active_start BETWEEN g_start_year AND g_end_year THEN
	lv_count := 0;
        OPEN get_old_tax_ref_cnt(l_assignment_id,l_payroll_id,l_payroll_tax_dist||'/'||l_payroll_tax_ref);
        FETCH get_old_tax_ref_cnt INTO lv_count;
        CLOSE get_old_tax_ref_cnt;

        IF lv_count = 0 THEN
          l_start_of_emp := l_active_start;
        END IF;

-- Modifications for the bug 8452959 End
       ELSE
          l_start_of_emp := NULL;
       END IF;
    END IF;
    --
    OPEN csr_addresses(l_person_id);
    FETCH csr_addresses INTO  l_address_line1,
                              l_address_line2,
                              l_address_line3,
                              l_town_or_city,
                              l_county,
                              l_postal_code,
                              l_country; -- 4011263
    CLOSE csr_addresses;
    --
    /* 4752018 - Push null address lines to the end */
    remove_null_address_lines(p_address_line1 => l_address_line1,
                              p_address_line2 => l_address_line2,
                              p_address_line3 => l_address_line3,
                              p_address_line4 => l_town_or_city);
    --
    OPEN csr_country_name(l_country);
    FETCH csr_country_name INTO l_country_name;
    CLOSE csr_country_name;
    --
    hr_utility.set_location(l_proc,40);
    --
    -- Archive more asg info.
    hr_utility.trace('Archiving more info');
    archive_asg_info(g_last_name_eid,l_last_name);
    archive_asg_info(g_first_name_eid,l_first_name);
    archive_asg_info(g_middle_name_eid,l_middle_name);
    archive_asg_info(g_date_of_birth_eid,
                     fnd_date.date_to_canonical(l_date_of_birth));
    archive_asg_info(g_title_eid,l_title);
    archive_asg_info(g_expense_check_to_address_eid,
                     l_expense_check_to_address);
    archive_asg_info(g_ni_number_eid,l_ni_number);
    archive_asg_info(g_sex_eid,l_sex);
    archive_asg_info(g_pensioner_indicator_eid,l_pensioner_indicator);
    archive_asg_info(g_multiple_asg_flag_eid,l_multiple_asg_flag);
    archive_asg_info(g_aggregated_paye_flag_eid, l_aggregated_paye_flag);
    archive_asg_info(g_director_indicator_eid,l_director_indicator);
    archive_asg_info(g_start_of_emp_eid,
                     fnd_date.date_to_canonical(l_start_of_emp));
    archive_asg_info(g_address_line1_eid,l_address_line1);
    archive_asg_info(g_address_line2_eid,l_address_line2);
    archive_asg_info(g_address_line3_eid,l_address_line3);
    archive_asg_info(g_town_or_city_eid,l_town_or_city);
    archive_asg_info(g_county_eid,l_county);
    archive_asg_info(g_country_eid,l_country_name); -- 4011263
    archive_asg_info(g_postal_code_eid,l_postal_code);
    --
    hr_utility.trace('End of archiving person and address info');
    -- Get more Non-NI balances and codes
    l_paye  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_paye_id);
    l_widow := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_widow_id);
    hr_utility.set_location(l_proc,50);
    hr_utility.trace('l_paye='||l_paye||', g_paye_id='||g_paye_id);
    IF nvl(l_aggregated_paye_flag,'N') <> 'Y' THEN
       -- Not Aggregated PAYE, so archive all values as prior to
       -- introduction of agg PAYE.
       hr_utility.trace('Not Aggregated PAYE, archive at asg level');
       /* IF l_sex = 'F' Then rerstored as a part of 2987008
                        was earlier commented out for 2003,
                      And now commented out again for 2005, BUG 4011263 */
         archive_asg_info(g_smp_eid,l_smp);
       /* END IF; */
       archive_asg_info(g_ssp_eid,l_ssp);
       archive_asg_info(g_sap_eid,l_sap);
       archive_asg_info(g_spp_adopt_eid, l_spp_adopt);
       archive_asg_info(g_spp_birth_eid, l_spp_birth);
       archive_asg_info(g_gross_pay_eid,l_gross);
       archive_asg_info(g_notional_pay_eid,l_notional);
       archive_asg_info(g_tax_paid_eid,ABS(l_paye));
       archive_asg_info(g_superannuation_paid_eid,ABS(l_super));
       archive_asg_info(g_widows_and_orphans_eid,l_widow);
       archive_asg_info(g_taxable_pay_eid,l_taxable);
       archive_asg_info(g_student_loans_eid,l_student_loan);
       archive_asg_info(g_ni_arrears_eid,l_ni_arrears);
       IF l_paye < 0 THEN
         archive_asg_info(g_tax_refund_eid,'R');
       END IF;
       IF l_super < 0 THEN
         archive_asg_info(g_superannuation_refund_eid,'R');
       END IF;
    ELSE
       -- Aggregated PAYE, so call store_agg_values to sum up values.
       store_agg_values(p_smp        => l_smp,
                        p_ssp        => l_ssp,
                        p_sap        => l_sap,
                        p_spp_adopt  => l_spp_adopt,
                        p_spp_birth  => l_spp_birth,
                        p_gross      => l_gross,
                        p_notional   => l_notional,
                        p_paye       => l_paye,
                        p_super      => l_super,
                        p_widow      => l_widow,
                        p_taxable    => l_taxable,
                        p_student_ln => l_student_loan,
                        p_ni_arrears => l_ni_arrears);
      --
    END IF;
    --
    -- Set up w1_m1 and wk_53 indicators.
    --
    if l_payroll_max_period_number in (53,54,56) then
       OPEN get_week_53_start(l_payroll_id);
       FETCH get_week_53_start INTO l_week_53_start;
       CLOSE get_week_53_start;
       --
       hr_utility.trace('After get_week_53_start, l_week_53_start='||
                       fnd_date.date_to_displaydate(l_week_53_start));
       IF nvl(l_week_53_start, hr_general.end_of_time) <= l_active_end THEN
          l_week_53_indicator := substr(to_char(l_payroll_max_period_number),2,1);
       END IF;
    else
       l_week_53_indicator := ' ';
    end if;
    --
    hr_utility.trace('Before getting paye details from run results.');
    hr_utility.trace('l_action_type='||l_action_type);
    --
    -- 2166991: Check the Action type, if reversal then the
    -- csr_tax_last_run cannot be used, call csr_tax_latest_run.
    -- Separate clause for V types for performance.
    --
    -- Start of Bug 6271548 Commented out below code due to previous_taxable_pay
    -- previous_tax_paid balances already fetched.
    -- Bug 6761725
    -- Archiving the tax code details depending on the global g_paye_archive
    IF g_paye_archive = FALSE THEN
    IF l_action_type <> 'V' THEN
      -- get paye element's run result id from last run
      hr_utility.trace('Before csr_tax_last_paye_run, l_last_asg_action_id='||l_last_asg_action_id);
      OPEN csr_tax_last_paye_run(l_last_asg_action_id);
      FETCH csr_tax_last_paye_run INTO l_tax_paye_run_result_id;
      hr_utility.trace('After csr_tax_last_paye_run, l_tax_paye_run_result_id='||l_tax_paye_run_result_id);
      IF l_tax_paye_run_result_id IS NULL THEN
         -- if paye was not calculated in last run then
         -- get the latest run in which it was
         hr_utility.trace('Before csr_tax_last_paye_run, l_assignment_id='||l_assignment_id);
         hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
         OPEN csr_tax_latest_paye_run(l_assignment_id, l_last_effective_date);
         FETCH csr_tax_latest_paye_run INTO l_tax_paye_run_result_id, l_paye_eff_date;
         hr_utility.trace('After csr_tax_last_paye_run, l_tax_paye_run_result_id='||l_tax_paye_run_result_id);
         hr_utility.trace('l_paye_eff_date='||fnd_date.date_to_displaydate(l_paye_eff_date));
         CLOSE csr_tax_latest_paye_run;
      ELSE
         -- PAYE run result found hence effective date for paye details is
         -- date of last assignment action
         l_paye_eff_date := l_last_effective_date;
         hr_utility.trace('l_paye_eff_date='||fnd_date.date_to_displaydate(l_paye_eff_date));
      END IF;
      CLOSE csr_tax_last_paye_run;
      -- most people will have had paye calculated on the last run.
      -- Pick these up
      hr_utility.trace('Before csr_tax_last_run, l_last_asg_action_id='||l_last_asg_action_id);
      OPEN csr_tax_last_run(l_last_asg_action_id);
      FETCH csr_tax_last_run INTO l_tax_run_result_id;
      hr_utility.trace('After csr_tax_last_run, l_tax_run_result_id='||l_tax_run_result_id);
      IF l_tax_run_result_id IS NULL THEN
        -- find the latest update
        hr_utility.trace('calling csr_tax_latest_run, non reversal');
         hr_utility.trace('Before csr_tax_latest_run, l_assignment_id='||l_assignment_id);
         hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
        OPEN csr_tax_latest_run(l_assignment_id, l_last_effective_date);
        FETCH csr_tax_latest_run INTO l_tax_run_result_id, l_paye_details_eff_date;
         hr_utility.trace('After csr_tax_latest_run, l_tax_run_result_id='||l_tax_run_result_id);
         hr_utility.trace('l_paye_details_eff_date='||fnd_date.date_to_displaydate(l_paye_details_eff_date));
        CLOSE csr_tax_latest_run;
      ELSE
        l_paye_details_eff_date := l_last_effective_date;
        hr_utility.trace('l_paye_details_eff_date='||fnd_date.date_to_displaydate(l_paye_details_eff_date));
      END IF;
      CLOSE csr_tax_last_run;
    ELSE
      -- find the latest update, as reversal action
        hr_utility.trace('calling csr_tax_latest_run, reversal');
        hr_utility.trace('Before csr_tax_latest_run, l_assignment_id='||l_assignment_id);
       hr_utility.trace('l_last_effective_date='||fnd_date.date_to_displaydate(l_last_effective_date));
        OPEN csr_tax_latest_run(l_assignment_id, l_last_effective_date);
        FETCH csr_tax_latest_run INTO l_tax_run_result_id, l_paye_details_eff_date;
        CLOSE csr_tax_latest_run;
        hr_utility.trace('After csr_tax_latest_run, l_tax_run_result_id='||l_tax_run_result_id);
        hr_utility.trace('l_paye_details_eff_date='||fnd_date.date_to_displaydate(l_paye_details_eff_date));
        --
        OPEN csr_tax_latest_paye_run(l_assignment_id, l_last_effective_date);
        FETCH csr_tax_latest_paye_run INTO l_tax_paye_run_result_id, l_paye_eff_date;
        CLOSE csr_tax_latest_paye_run;
        hr_utility.trace('After csr_tax_latest_paye_run, l_tax_paye_run_result_id='||l_tax_paye_run_result_id);
        hr_utility.trace('l_paye_eff_date='||fnd_date.date_to_displaydate(l_paye_eff_date));
    END IF;
    --
    --
    -- archive_asg_info(g_tax_run_result_id_eid, nvl(l_tax_paye_run_result_id, l_tax_run_result_id));
    --
    -- Get tax code.
    -- First try PAYE element run results because PAYE details
    -- element run result may not be the same as the one effective on
    -- regular payment date of a payroll with positive
    -- offset
    OPEN csr_tax_paye_result(l_tax_paye_run_result_id);
    FETCH csr_tax_paye_result INTO l_tax_code, l_w1_m1_indicator,
                                    l_previous_taxable_pay,
                                    l_previous_tax_paid;
    hr_utility.trace('After csr_tax_paye_result, l_tax_code='||l_tax_code);
    hr_utility.trace('l_w1_m1_indicator='||l_w1_m1_indicator);
    hr_utility.trace('l_previous_taxable_pay='||to_char(l_previous_taxable_pay));
    hr_utility.trace('l_previous_tax_paid='||to_char(l_previous_tax_paid));
    IF l_tax_code IS NULL THEN
       -- Get the details from the element entry on the added criteria that
       -- there exists an updating action id on the element_entry.  In other
       -- words, an entry achieved using an Update Recurring rule.
       -- Nb. both cursors used here select max(...) so a row is returned
       -- even if no tax details found.
       --
       OPEN csr_tax_details_entry(l_assignment_id, l_effective_end_date,
                               l_payroll_end_year, 'Y');
       FETCH csr_tax_details_entry INTO  l_tax_code, l_w1_m1_indicator,
                                      l_previous_taxable_pay,
                                      l_previous_tax_paid;
       hr_utility.set_location(l_proc||' '||l_tax_code||' '||
                               l_w1_m1_indicator,52);
       IF l_tax_code IS NULL THEN
         -- no update recurring, so retrieve the details from the run result.
         OPEN csr_tax_details_result(l_tax_run_result_id);
         FETCH csr_tax_details_result INTO l_tax_code, l_w1_m1_indicator,
                                       l_previous_taxable_pay,
                                       l_previous_tax_paid;
         hr_utility.set_location(l_proc||' '||l_tax_code||' '||
                                 l_w1_m1_indicator,54);
         IF l_tax_code IS NULL THEN
           -- If there is still no tax code, use the element entry query
           -- without the update recurring criteria.
           CLOSE csr_tax_details_entry;
           OPEN csr_tax_details_entry(l_assignment_id, l_effective_end_date,
                                      l_payroll_end_year, 'N');
           FETCH csr_tax_details_entry INTO  l_tax_code, l_w1_m1_indicator,
                                             l_previous_taxable_pay,
                                             l_previous_tax_paid;
           hr_utility.set_location(l_proc||' '||l_tax_code||' '||
                                   l_w1_m1_indicator,56);
           IF l_tax_code IS NOT NULL THEN
            IF l_aggregated_paye_flag = 'Y' THEN
               hr_utility.trace('This is an aggregated assignment.');
               --
               if l_w1_m1_indicator = 'C' then
                  l_w1_m1_indicator := ' ';
               else
                  hr_utility.trace('No of periods per year = '||g_no_per_fiscal_yr(l_payroll_id));
                  if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
                     l_w1_m1_indicator := 'M';
                  else
                     l_w1_m1_indicator := 'W';
                  end if;
               end if;
               hr_utility.trace('Aggregated tax code found so far='||g_agg_balance_totals.tax_code);
               hr_utility.trace('g_agg_balance_totals.paye_eff_date = '||fnd_date.date_to_displaydate(g_agg_balance_totals.paye_eff_date));
               -- this tax code is from the PAYE Details Entry, since it is an
               -- aggregated assignment therefore check if we already have a
               -- a tax code from a previously processed assignment of this employee
               IF g_agg_balance_totals.tax_code is NULL THEN
                  hr_utility.trace('Aggregated tax code found so far is NULL hence store '||l_tax_code||' as the aggregated tax code');
                  -- No tax code found on other assignments so far therefore store
                  -- tax code found on element entry of this assignment,
                  -- this value will be archived against the primary eoy action later
                  g_agg_balance_totals.tax_code := l_tax_code;
                  g_agg_balance_totals.tax_basis := l_w1_m1_indicator;
                  g_agg_balance_totals.pay_previous := l_previous_taxable_pay;
                  g_agg_balance_totals.tax_previous := l_previous_tax_paid;
                  g_agg_balance_totals.paye_eff_date := fnd_date.canonical_to_date('0001/01/01 00:00:00');
               END IF;
               --
               IF nvl(g_agg_balance_totals.week_53, ' ') = ' ' THEN
                  g_agg_balance_totals.week_53 := l_week_53_indicator;
               END IF;
            END IF; -- aggregated PAYE flag = Y
           END IF; -- tax code found on PAYE Details entry
         ELSE -- tax code found on PAYE Details Result
            IF l_aggregated_paye_flag = 'Y' THEN
               --
               if l_w1_m1_indicator = 'C' then
                  l_w1_m1_indicator := ' ';
               else
                  if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
                     l_w1_m1_indicator := 'M';
                  else
                     l_w1_m1_indicator := 'W';
                  end if;
               end if;
               -- this is aggregated assignment hence check whether this is the
               -- latest run result so far
               IF l_paye_details_eff_date >
                            g_agg_balance_totals.paye_eff_date THEN
                  -- this is the latest paye run results amongst aggregated
                  -- assignment, store values in the table to archive
                  -- against the primary eoy action later
                  g_agg_balance_totals.tax_code := l_tax_code;
                  g_agg_balance_totals.tax_basis := l_w1_m1_indicator;
                  g_agg_balance_totals.pay_previous := l_previous_taxable_pay;
                  g_agg_balance_totals.tax_previous := l_previous_tax_paid;
                  g_agg_balance_totals.paye_eff_date := l_paye_details_eff_date;
               END IF;
               --
               IF nvl(g_agg_balance_totals.week_53, ' ') = ' ' THEN
                  g_agg_balance_totals.week_53 := l_week_53_indicator;
               END IF;
            END IF; -- aggregated PAYE flag = Y
         END IF; -- null or nor null tax code in pay details resluts
         CLOSE csr_tax_details_result;
       END IF; -- tax code null on update recurring PAYE Details entry
       CLOSE csr_tax_details_entry;
       --
    ELSE -- tax code found on PAYE Reun Result
       IF l_aggregated_paye_flag = 'Y' THEN
          --
          if l_w1_m1_indicator = 'C' then
             l_w1_m1_indicator := ' ';
          else
             if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
                l_w1_m1_indicator := 'M';
             else
                l_w1_m1_indicator := 'W';
             end if;
          end if;
          -- this is aggregated assignment hence check whether this is the
          -- latest run result so far
          IF l_paye_eff_date > g_agg_balance_totals.paye_eff_date THEN
             -- these are the latest paye run results amongst aggregated
             -- assignment, store them in the table to archive
             -- against the primary eoy action later
             g_agg_balance_totals.tax_code := l_tax_code;
             g_agg_balance_totals.tax_basis := l_w1_m1_indicator;
             g_agg_balance_totals.pay_previous := l_previous_taxable_pay;
             g_agg_balance_totals.tax_previous := l_previous_tax_paid;
             g_agg_balance_totals.paye_eff_date := l_paye_eff_date;
          END IF;
          --
          IF nvl(g_agg_balance_totals.week_53, ' ') = ' ' THEN
             g_agg_balance_totals.week_53 := l_week_53_indicator;
          END IF;
       END IF; -- aggregated PAYE flag = 'Y'
    END IF; --found/not found tax code on PAYE reun result
    CLOSE csr_tax_paye_result;
    --
    g_paye_archive := TRUE;
    END IF;
    -- End of Bug 6271548
    hr_utility.set_location(l_proc,60);
    /**************************************/
    /* assigned blank space to l_tax_code */
    /**************************************/
    if (l_tax_code IS NULL) then
         l_tax_code := ' ';
    else
         l_tax_code := ltrim(l_tax_code);
    end if;
    IF nvl(l_aggregated_paye_flag, 'N') <> 'Y' THEN
       -- archive these values for assignment that are not aggregated for PAYE,
       -- values stored in the global table will be archived against the
       -- eoy primary action for aggregated assignments later
       archive_asg_info(g_tax_code_eid,l_tax_code);
       archive_asg_info(g_prev_taxable_pay_eid,l_previous_taxable_pay);
       archive_asg_info(g_prev_tax_paid_eid,l_previous_tax_paid);
       --
       if l_w1_m1_indicator = 'C' then
          l_w1_m1_indicator := ' ';
       else
          if g_no_per_fiscal_yr(l_payroll_id) in (1,2,4,6,12,24) then
             l_w1_m1_indicator := 'M';
          else
             l_w1_m1_indicator := 'W';
          end if;
       end if;
       --
       archive_asg_info(g_week_53_indicator_eid,l_week_53_indicator);
       archive_asg_info(g_w1_m1_indicator_eid,l_w1_m1_indicator);
    END IF;

    -- Start of Bug 6271548 commented out fetching NI x total and able balances
    -- due to already fetch

    -- Get NI balances
    -- NI A
   /* l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nia_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nia_able_id); */
    IF nvl(l_nia_tot,0) <> 0 or nvl(l_nia_able,0) <> 0 THEN
 -- IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
      hr_utility.set_location(l_proc,70);

      l_ni_ees  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nia_id);
      l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nia_lel_id);
      l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nia_uel_id);
      -- 8357870 Begin
      l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nia_uap_id);
      -- 8357870 End
      --EOY 07/08 Begin
      l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nia_auel_id);
      --EOY 07/08 End
      l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nia_et_id);
      /* EOY 07/08 Begin
      archive_ni_values('A', l_nia_tot, l_nia_able, l_ni_ees, l_ni_able_lel,
                             l_ni_able_et, l_ni_able_uel);  */
      archive_ni_values('A', l_nia_tot, l_nia_able, l_ni_ees, l_ni_able_lel,
                             l_ni_able_et, l_ni_able_uel,l_ni_able_uap, l_ni_able_auel);  -- 8357870 added UAP
      /* EOY 07/08 End */
      l_count_values := l_count_values +1;
    END IF;
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL;  -- 8357870
    l_ni_able_auel := NULL; --EOY 07/08 Begin
    l_ni_able_et  := NULL;
    -- NI B
    /* IF l_sex = 'F' THEN -- Cat B is for Females only Bug 4011263, EOY 2005*/
   /* l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                              g_nib_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                 g_nib_able_id);*/
      IF nvl(l_nib_tot,0) <> 0 or nvl(l_nib_able,0) <> 0 THEN
   -- IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
        hr_utility.set_location(l_proc,80);
        l_ni_ees  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                 g_nib_id);
        l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nib_lel_id);
        l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nib_uel_id);
        -- 8357870 begin
        l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nib_uap_id);
        -- 8357870 end
        --EOY 07/08 Begin
        l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nib_auel_id);
        --EOY 07/08 End
        l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nib_et_id);
        /* EOY 07/08 Begin
        archive_ni_values('B', l_nib_tot, l_nib_able, l_ni_ees, l_ni_able_lel,
                               l_ni_able_et, l_ni_able_uel); */
        archive_ni_values('B', l_nib_tot, l_nib_able, l_ni_ees, l_ni_able_lel,
                               l_ni_able_et, l_ni_able_uel,l_ni_able_uap, l_ni_able_auel); -- 8357870
        /* EOY 07/08 End */
        l_count_values := l_count_values +1;
      END IF;
    /*END IF; -- l_sex = 'F'*/
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL;  -- 8357870
    l_ni_able_auel := NULL; -- EOY 07/08
    l_ni_able_et  := NULL;
    l_ers_rebate  := NULL;
    -- NI C
   /*l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nic_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                 g_nic_able_id);*/
    IF nvl(l_nic_tot,0) <> 0 or nvl(l_nic_able,0) <> 0 THEN
 -- IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
      hr_utility.set_location(l_proc,90);
      --archive_ni_values('C', l_ni_tot);
-- Bug Fix 1976152, commented the above stmt, and included the below code
-- to get the balance for NI C Employers Rebate and modified the call to
-- archive_ni_values procedure
      l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nic_lel_id);
      l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                    g_nic_uel_id);
      -- 8357870 begin
      l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                    g_nic_uap_id);
      -- 8357870 end
      --EOY 07/08 Begin
      l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                    g_nic_auel_id);
      --EOY 07/08 End
      l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                     g_nic_et_id);
      l_ers_rebate := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nic_ers_rebate_id);
      /* EOY 07/08 Begin
      archive_ni_values(p_ni_cat => 'C',
                        p_tot_contribs => l_nic_tot,
                        p_earnings => l_nic_able,
                        p_ni_able_lel => l_ni_able_lel,
                        p_ni_able_et  => l_ni_able_et,
                        p_ni_able_uel => l_ni_able_uel,
                        p_ers_rebate => l_ers_rebate);  */
      archive_ni_values(p_ni_cat => 'C',
                        p_tot_contribs => l_nic_tot,
                        p_earnings => l_nic_able,
                        p_ni_able_lel => l_ni_able_lel,
                        p_ni_able_et  => l_ni_able_et,
                        p_ni_able_uel => l_ni_able_uel,
                        p_ni_able_uap => l_ni_able_uap, -- 8357870
                        p_ni_able_auel => l_ni_able_auel,
                        p_ers_rebate => l_ers_rebate);
     --EOY 07/08 End
-- End of fix Bug 1976152
      l_count_values := l_count_values +1;
    END IF;
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL; -- 8357870
    l_ni_able_auel := NULL;  --EOY 07/08
    l_ni_able_et  := NULL;
    l_ers_rebate  := NULL;
    l_rebate_emp  := NULL;
    -- NI D
   /*l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nid_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nid_able_id);*/
    IF nvl(l_nid_tot,0) <> 0 or nvl(l_nid_able,0) <> 0 THEN
 -- IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
      hr_utility.set_location(l_proc,100);
      l_ni_ees  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nid_id);
      l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_lel_id);
      l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_uel_id);
      -- 8357870 begin
      l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_uap_id);
      -- 8357870 end
      --EOY 07/08 Begin
      l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_auel_id);
      --EOY 07/08 End
      l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_et_id);
      l_ers_rebate  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_ers_rebate_id);
      l_ees_rebate  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_ees_rebate_id);
      l_rebate_emp  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nid_rebate_emp_id);
      /*EOY 07/08 Begin
      archive_ni_values('D', l_nid_tot, l_nid_able, l_ni_ees, l_ni_able_lel,
                        l_ni_able_et, l_ni_able_uel,l_ers_rebate + l_ees_rebate - l_rebate_emp,
                        l_rebate_emp);   */
      archive_ni_values('D', l_nid_tot, l_nid_able, l_ni_ees, l_ni_able_lel,
                        l_ni_able_et, l_ni_able_uel,l_ni_able_uap, l_ni_able_auel,l_ers_rebate + l_ees_rebate - l_rebate_emp,
                        l_rebate_emp);  -- 8357870 added UAP
      --EOY 07/08 End
      l_count_values := l_count_values +1;
    END IF;
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL; -- 8357870
    l_ni_able_auel := NULL; --EOY 07/08
    l_ni_able_et  := NULL;
    l_ers_rebate  := NULL;
    l_ees_rebate  := NULL;
    -- NI E
    /* IF l_sex = 'F' THEN -- Cat E is for Females only Bug 4011263, EOY 2005*/
   /*l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_able_id);*/
    IF nvl(l_nie_tot,0) <> 0 or nvl(l_nie_able,0) <> 0 THEN
    --  IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
        hr_utility.set_location(l_proc,110);
        l_ni_ees  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_id);
        l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_lel_id);
        l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_uel_id);
        l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_uap_id);  -- 8357870
	--EOY 07/08 Begin
        l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_auel_id);
        --EOY 07/08 End
        l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_et_id);
        l_ers_rebate  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nie_ers_rebate_id);
	/*EOY 07/08 Begin
        archive_ni_values('E', l_nie_tot, l_nie_able, l_ni_ees, l_ni_able_lel,l_ni_able_et, l_ni_able_uel,l_ers_rebate);*/
        archive_ni_values('E', l_nie_tot, l_nie_able, l_ni_ees, l_ni_able_lel,l_ni_able_et, l_ni_able_uel, l_ni_able_uap, l_ni_able_auel, l_ers_rebate); -- 8357870
        --EOY 07/08 End
        l_count_values := l_count_values +1;
      END IF;
    /* END IF; -- l_sex = 'F' */
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL;   -- 8357870
    l_ni_able_auel := NULL;  --EOY 07/08
    l_ni_able_et  := NULL;
    l_ers_rebate  := NULL;
    l_ees_rebate  := NULL;
    l_rebate_emp  := NULL;
   -- NI J
  /*l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nij_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nij_able_id);*/
    IF nvl(l_nij_tot,0) <> 0 or nvl(l_nij_able,0) <> 0 THEN
 -- IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
      hr_utility.set_location(l_proc,130);
      l_ni_ees  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nij_id);
      l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nij_lel_id);
      l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nij_uel_id);
      l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nij_uap_id);  -- 8357870
      --EOY 07/08 Begin
      l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nij_auel_id);
      --EOY 07/08 End
      l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nij_et_id);
      /* EOY 07/08 Begin
      archive_ni_values('J', l_nij_tot, l_nij_able, l_ni_ees, l_ni_able_lel,
                             l_ni_able_et, l_ni_able_uel); */
      archive_ni_values('J', l_nij_tot, l_nij_able, l_ni_ees, l_ni_able_lel,
                             l_ni_able_et, l_ni_able_uel, l_ni_able_uap, l_ni_able_auel); -- 8357870 added UAP
      --EOY 07/08 End
      l_count_values := l_count_values +1;
    END IF;
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL;  -- 8357870
    l_ni_able_auel := NULL; -- EOY 07/08
    l_ni_able_et  := NULL;

-- NI L
  /*l_ni_tot := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nil_tot_id);
    l_ni_able := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                               g_nil_able_id);*/
    IF nvl(l_nil_tot,0) <> 0 or nvl(l_nil_able,0) <> 0 THEN
 -- IF nvl(l_ni_tot,0) <> 0 or nvl(l_ni_able,0) <> 0 THEN
      hr_utility.set_location(l_proc,140);
      l_ni_ees  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,g_nil_id);
      l_ni_able_lel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nil_lel_id);
      l_ni_able_uel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nil_uel_id);
      l_ni_able_uap := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nil_uap_id); -- 8357870
      --EOY 07/08 Begin
      l_ni_able_auel := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nil_auel_id);
      --EOY 07/08 End
      l_ni_able_et  := 100 * hr_dirbal.get_balance(l_last_asg_action_id,
                                                   g_nil_et_id);
      /*EOY 07/08 Begin
      archive_ni_values('L', l_nil_tot, l_nil_able, l_ni_ees, l_ni_able_lel,
                             l_ni_able_et, l_ni_able_uel);  */
      archive_ni_values('L', l_nil_tot, l_nil_able, l_ni_ees, l_ni_able_lel,
                             l_ni_able_et, l_ni_able_uel, l_ni_able_uap, l_ni_able_auel); -- 8357870 added UAP
      --EOY 07/08 End
      l_count_values := l_count_values +1;
    END IF;
    l_ni_tot      := NULL;
    l_ni_ees      := NULL;
    l_ni_able     := NULL;
    l_ni_able_lel := NULL;
    l_ni_able_uel := NULL;
    l_ni_able_uap := NULL;   -- 8357870
    l_ni_able_auel := NULL;  --EOY 07/08
    l_ni_able_et  := NULL;

    -- End of Bug 6271548

    -- populate NI F, NI G and/or NI S values
    -- sum the NI F/G/S Total Balances
/* 4221300: remove call to hr_gbbal.ni_category_exists_in_year
    IF HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(l_last_asg_action_id,'F') = 1
       OR HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(l_last_asg_action_id,'G') = 1
       OR HR_GBBAL.NI_CATEGORY_EXISTS_IN_YEAR(l_last_asg_action_id,'S') = 1
       THEN
4221300 */
      -- F/G/S Total(s) exist(s)
      hr_utility.set_location(l_proc,120);
      -- open cursor and populate year end values
      DECLARE
        l_sum_ni_tot      NUMBER:= 0;
        l_sum_ni_ees      NUMBER:= 0;
        l_sum_ni_able     NUMBER:= 0;
        l_sum_ni_able_lel NUMBER:= 0;
        l_sum_ni_able_uel NUMBER:= 0;
        l_sum_ni_able_uap NUMBER:= 0;   -- 8357870
	l_sum_ni_able_auel NUMBER:= 0;  --EOY 07/08
        l_sum_ni_able_et  NUMBER:= 0;
        l_sum_ers_rebate  NUMBER:= 0;
        l_sum_ees_rebate  NUMBER:= 0;
        l_sum_rebate_emp  NUMBER:= 0;
        l_ni_ers          NUMBER:= 0;
        l_store_cat       VARCHAR2(1):=NULL;
        l_store_scon      VARCHAR2(9):=NULL;
      BEGIN
        OPEN csr_get_scon_bal(l_last_asg_action_id,g_scon_input_id,
                              g_category_input_id, g_ni_id);
        LOOP
          FETCH csr_get_scon_bal INTO l_ni_cat, l_scon, l_ni_able,
                                  l_ni_tot, l_ni_ees, l_ni_ers,
                                  l_ni_able_et,
                                  l_ni_able_lel, l_ni_able_uel,
                                  l_ni_able_uap, -- 8357870
				  --EOY 07/08 Begin
                                  l_ni_able_auel,
                                  --EOY 07/08 End
                                  l_ers_rebate, l_ees_rebate, l_rebate_emp;
          IF (csr_get_scon_bal%notfound
              OR l_ni_cat <> l_store_cat
              OR l_store_scon <> l_scon)
          AND csr_get_scon_bal%rowcount > 0 THEN
            -- first row will not come here due to null trap with cat and scon
            -- write values from store
            hr_utility.trace('l_sum_ni_tot='||l_sum_ni_tot);
            hr_utility.trace('l_sum_ni_able='||l_sum_ni_able);
            -- Add following IF condition for 4221300
            IF (nvl(l_sum_ni_tot,0) <> 0 or nvl(l_sum_ni_able,0) <> 0) THEN
               archive_ni_values(l_store_cat, l_sum_ni_tot, l_sum_ni_able,
                                 l_sum_ni_ees, l_sum_ni_able_lel,
                                 l_sum_ni_able_et, l_sum_ni_able_uel,
                                 l_sum_ni_able_uap, -- 8357870
				 --EOY 07/08 Begin
                                 l_sum_ni_able_auel,
                                 --EOY 07/08 End
                                 l_sum_ers_rebate + l_sum_ees_rebate - l_sum_rebate_emp, l_sum_rebate_emp, l_store_scon);
               l_count_values := l_count_values +1;
            END IF; -- Bug 4221300
            --
            EXIT WHEN csr_get_scon_bal%notfound;
            -- reset totalling variables
            l_sum_ni_tot      := 0;
            l_sum_ni_ees      := 0;
            l_sum_ni_able     := 0;
            l_sum_ni_able_lel := 0;
            l_sum_ni_able_uel := 0;
            l_sum_ni_able_uap := 0; -- 8357870
	    l_sum_ni_able_auel := 0; --EOY 07/08
            l_sum_ni_able_et  := 0;
            l_sum_ers_rebate  := 0;
            l_sum_ees_rebate  := 0;
            l_sum_rebate_emp  := 0;
          END IF;
          EXIT WHEN csr_get_scon_bal%notfound;
          -- add values to backup;
/* Bug 4169542: Process NI Cat S like other cats:
          IF l_ni_cat = 'S' THEN
            l_sum_ni_tot      := l_sum_ni_tot      + l_ni_ers;
-- Bug# 1794175,added the following stmt so that l_sum_ers_rebate value
-- passed on to archive_ni_values procedure, earlier the value was being passed as zero
            l_sum_ers_rebate  := l_sum_ers_rebate  + l_ers_rebate;
         ELSE
*/
            l_sum_ni_tot      := l_sum_ni_tot      + l_ni_tot;
            l_sum_ni_ees      := l_sum_ni_ees      + l_ni_ees;
            l_sum_ni_able     := l_sum_ni_able     + l_ni_able;
            l_sum_ni_able_lel := l_sum_ni_able_lel + l_ni_able_lel;
            l_sum_ni_able_uel := l_sum_ni_able_uel + l_ni_able_uel;
            l_sum_ni_able_uap := l_sum_ni_able_uap + l_ni_able_uap;  -- 8357870
	    l_sum_ni_able_auel := l_sum_ni_able_auel + l_ni_able_auel; --EOY 07/08
            l_sum_ni_able_et  := l_sum_ni_able_et  + l_ni_able_et;
            l_sum_ers_rebate  := l_sum_ers_rebate  + l_ers_rebate;
            l_sum_ees_rebate  := l_sum_ees_rebate  + l_ees_rebate;
            l_sum_rebate_emp  := l_sum_rebate_emp + l_rebate_emp;
/* Bug 4169542: Process NI Cat S like other cats: remove End IF
          END IF;
*/
          --store new cat and scon
          l_store_cat  := l_ni_cat;
          l_store_scon := l_scon;
        END LOOP;
        CLOSE csr_get_scon_bal;
      END;
-- Bug 4221300    END IF; -- F/G/S Total(s) exist(s)

    --
    -- If no NI values were archived, archive the current category.
    IF l_count_values = 0 THEN
      OPEN csr_current_cat(l_assignment_id, l_effective_end_date,
                           l_payroll_end_year);
      FETCH csr_current_cat INTO l_ni_cat, l_scon;
      IF csr_current_cat%found THEN
        hr_utility.set_location(l_proc,160);
        archive_ni_values(p_ni_cat       => l_ni_cat,
                          p_tot_contribs => 0,
                          p_scon         => l_scon);
      ELSE
        archive_ni_values('X',0);
      END IF;
      CLOSE csr_current_cat;
    END IF;
    --
    IF l_multiple_asg_flag = 'Y' THEN
      -- Do Multiple Assignment Logic Part III
      -- If Aggregated PAYE flag is set, use the first assignment ID
      -- in the sequence, this is the rule for AggPAYE. nvl the
      -- assignment ID with the max number for the field.
      IF nvl(l_aggregated_paye_flag,'N') = 'Y' THEN
         hr_utility.set_location(l_proc,162);
         IF l_assignment_id < nvl(g_min_assignment_id,999999999) THEN
            hr_utility.set_location(l_proc,163);
            g_primary_action := p_assactid;
            g_min_assignment_id := l_assignment_id;
         END IF;
      ELSE
         -- The largest gross pay dictates the Primary Assignment
         -- where there is Aggregated NI only.
         -- Bug 2040738. >= rather than >, incase the gross pay for all multi
         -- assignments is zero.
         -- Bug 6084523: if the first assignment of the employee has negative
         -- gross pay then it should still initialize the g_primary_action
         -- therefore amended IF condition below to initialle when
         -- g_max_gross_pay is null, i.e., first assignment of the emp
           IF nvl(l_gross,0) >= g_max_gross_pay
                 OR g_max_gross_pay is null THEN
             -- store new max gross pay and asg act id
             hr_utility.set_location(l_proc,165);
             g_primary_action := p_assactid;
             g_max_gross_pay  := nvl(l_gross,0);
           END IF;
      END IF;
      -- store this action in g_asg_actions
      g_num_actions := g_num_actions +1;
      g_asg_actions(g_num_actions) := p_assactid;
    END IF; -- End of Multiple Assignment Logic Part III
  END IF; -- if no NI Y and no last action
  --
  IF l_multiple_asg_flag = 'Y' AND g_num_actions > 0
    -- If this is a multiple asg and at least 1 of the persons asgs was
    -- processed..
  THEN
    -- Do Multiple Assignment Logic Part IV
    -- Bug 1261138 - split MA logic III into III and IV to ensure that
    -- pl/sql tbl is flushed to DB even if last asg was not processed, but
    -- only if at least one asg was processed
    IF pay_gb_eoy_archive.get_arch_str(p_assactid,
                                       g_last_multi_asg_eid) = 'Y'
    THEN
      -- This is the last asg for the person in this tax ref
      -- archive the primary assignment flag against the primary action
      hr_utility.set_location(l_proc,170);
      ff_archive_api.create_archive_item
        (p_archive_item_id  => l_archive_item_id,
         p_user_entity_id   => g_eoy_primary_flag_eid,
         p_archive_value    => 'Y',
         p_action_id        => g_primary_action,
         p_legislation_code => 'GB',
         p_object_version_number => l_ovn,
         p_some_warning     => l_some_warning);
      --
      -- Loop through actions:
      BEGIN
        l_index1:=0;
        LOOP -- actions
          l_index1 := l_index1 + 1;
          hr_utility.set_location(l_proc||' '||g_asg_actions(l_index1),180);
          IF g_asg_actions(l_index1) = g_primary_action THEN
            -- This is the Primary action so Archive Balance values.
            -- Firstly the Aggregated PAYE values if necessary.
            IF nvl(l_aggregated_paye_flag,'N') = 'Y' then
              BEGIN
                 hr_utility.set_location(l_proc,181);
                 -- Get all values from the global table.
                  /* IF l_sex = 'F' THEN rerstored as a part of 2987008
                                     was earlier commented out for 2003,
                      And Commented out again for EOY 2005, Bug 4011263 */
                   archive_asg_info(g_smp_eid,g_agg_balance_totals.smp,
                                    g_primary_action);
                 /* END IF; */
                 --
                 archive_asg_info(g_ssp_eid,g_agg_balance_totals.ssp,
                                  g_primary_action);
                 archive_asg_info(g_sap_eid,g_agg_balance_totals.sap,
                                  g_primary_action);
                 archive_asg_info(g_spp_adopt_eid,
                        g_agg_balance_totals.spp_adopt,g_primary_action);
                 archive_asg_info(g_spp_birth_eid,
                        g_agg_balance_totals.spp_birth,g_primary_action);
                 archive_asg_info(g_gross_pay_eid,
                        g_agg_balance_totals.gross_pay,g_primary_action);
                 archive_asg_info(g_notional_pay_eid,
                        g_agg_balance_totals.notional,g_primary_action);
                 archive_asg_info(g_tax_paid_eid,
                        ABS(g_agg_balance_totals.paye),g_primary_action);
                 archive_asg_info(g_superannuation_paid_eid,
                        ABS(g_agg_balance_totals.superann),g_primary_action);
                 archive_asg_info(g_widows_and_orphans_eid,
                        g_agg_balance_totals.widows,g_primary_action);
                 archive_asg_info(g_taxable_pay_eid,
                        g_agg_balance_totals.taxable,g_primary_action);
                 archive_asg_info(g_student_loans_eid,
                        g_agg_balance_totals.student_ln,g_primary_action);
                 archive_asg_info(g_ni_arrears_eid,
                        g_agg_balance_totals.ni_arrears,g_primary_action);
                 archive_asg_info(g_tax_code_eid,
                        g_agg_balance_totals.tax_code, g_primary_action);
                 archive_asg_info(g_prev_taxable_pay_eid,
                        g_agg_balance_totals.pay_previous, g_primary_action);
                 archive_asg_info(g_prev_tax_paid_eid,
                        g_agg_balance_totals.tax_previous, g_primary_action);
                 archive_asg_info(g_w1_m1_indicator_eid,
                        g_agg_balance_totals.tax_basis, g_primary_action);
                 archive_asg_info(g_week_53_indicator_eid,
                        g_agg_balance_totals.week_53, g_primary_action);
                 --
                 IF g_agg_balance_totals.paye < 0 THEN
                    archive_asg_info(g_tax_refund_eid,'R',g_primary_action);
                 END IF;
                 --
                 IF g_agg_balance_totals.superann < 0 THEN
                    archive_asg_info(g_superannuation_refund_eid,'R',g_primary_action);
                 END IF;
                 hr_utility.set_location(l_proc,182);
              --
              EXCEPTION WHEN NO_DATA_FOUND THEN
                 NULL; -- All values archived
              END; -- Agg PAYE Block
            END IF; -- Agg PAYE Flag
            --
            -- Archive the NI totals from the cache against this action:
            BEGIN
              l_index2:=0;
              LOOP -- values
                l_index2 := l_index2 + 1;
                 -- EOY 2004. If the Total Contribution for each category is
                 -- negative, archive a refund flag.
                if g_ni_balance_totals(l_index2).tot_contribs < 0 then
                   l_ni_refund_flag := 'R';
                else
                   l_ni_refund_flag := '';
                end if;
                IF g_ni_balance_totals(l_index2).scon IS NOT NULL THEN
                  hr_utility.set_location(l_proc||' '||
                                 g_ni_balance_totals(l_index2).ni_cat||' '||
                                 g_ni_balance_totals(l_index2).scon,190);
                  archive_ni_value(g_ni_scon_earnings_eid,
                    g_ni_balance_totals(l_index2).earnings,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_ees_contribution_eid,
                    g_ni_balance_totals(l_index2).ees_contribs,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_tot_contribution_eid,
                    g_ni_balance_totals(l_index2).tot_contribs,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_able_et_eid,
                    g_ni_balance_totals(l_index2).ni_able_et,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_able_uel_eid,
                    g_ni_balance_totals(l_index2).ni_able_uel,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  -- 8357870 begin
		  archive_ni_value(g_ni_scon_able_uap_eid,
		    g_ni_balance_totals(l_index2).ni_able_uap,2,
		    g_ni_balance_totals(l_index2).ni_cat,
		    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  -- 8357870 end
		  --EOY 07/08 Begin
                  archive_ni_value(g_ni_scon_able_auel_eid,
                    g_ni_balance_totals(l_index2).ni_able_auel,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  --EOY 07/08 End
                  archive_ni_value(g_ni_scon_able_lel_eid,
                    g_ni_balance_totals(l_index2).ni_able_lel,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_ers_rebate_eid,
                    g_ni_balance_totals(l_index2).ers_rebate,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_ees_rebate_eid,
                    g_ni_balance_totals(l_index2).ees_rebate,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                  archive_ni_value(g_ni_scon_refund_eid,
                    l_ni_refund_flag,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                ELSE
                  hr_utility.set_location(l_proc||' '||
                                 g_ni_balance_totals(l_index2).ni_cat,200);
                  archive_ni_value(g_ni_earnings_eid,
                    g_ni_balance_totals(l_index2).earnings,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_ees_contribution_eid,
                    g_ni_balance_totals(l_index2).ees_contribs,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_tot_contribution_eid,
                    g_ni_balance_totals(l_index2).tot_contribs,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_able_et_eid,
                    g_ni_balance_totals(l_index2).ni_able_et,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_able_uel_eid,
                    g_ni_balance_totals(l_index2).ni_able_uel,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
		   -- 8357870 Begin
		  archive_ni_value(g_ni_able_uap_eid,
		    g_ni_balance_totals(l_index2).ni_able_uap,2,
		    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                   -- 8357870 End
		--EOY 07/08 Begin
                  archive_ni_value(g_ni_able_auel_eid,
                    g_ni_balance_totals(l_index2).ni_able_auel,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  --EOY 07/08 End
                  archive_ni_value(g_ni_able_lel_eid,
                    g_ni_balance_totals(l_index2).ni_able_lel,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_ers_rebate_eid,
                    g_ni_balance_totals(l_index2).ers_rebate,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_ees_rebate_eid,
                    g_ni_balance_totals(l_index2).ees_rebate,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    p_actid => g_primary_action);
                  archive_ni_value(g_ni_refund_eid,
                    l_ni_refund_flag,2,
                    g_ni_balance_totals(l_index2).ni_cat,
                    g_ni_balance_totals(l_index2).scon,
                    g_primary_action);
                END IF; -- scon is null
              END LOOP; -- values
              EXCEPTION WHEN no_data_found THEN
                -- all NI values archived
                NULL;
            END; -- NI values block
          ELSE
            hr_utility.set_location(l_proc,210);
            -- not primary action, so archive reportable cat X 'row'.
            -- Need to archive the Total Contributions item as 0 as the
            -- values view relies on this item being in the archive in order
            -- for a row to be returned (it uses this item to obtain the
            -- contexts of reportable, NI Cat and (if necessary) SCON.
            archive_ni_value(g_ni_tot_contribution_eid,'0',1,'X',
                             p_actid => g_asg_actions(l_index1));
          END IF; -- primary action
        END LOOP; -- actions
      EXCEPTION WHEN no_data_found THEN
        -- all actions processed
        NULL;
      END; -- action block
      --
      IF l_reportable_ni_archived THEN
         hr_utility.trace('Reportable NI values archived against primary action='||g_primary_action);
         archive_asg_info(g_reportable_ni_eid, 'Y', g_primary_action);
      END IF;
      --
      empty_masg_cache;
    END IF; -- l_last_multi_asg
  ELSE -- End of Multiple Assignment Logic Part IV
    -- This is not an employee with aggregated multiple assignments
    IF l_reportable_ni_archived THEN
       hr_utility.trace('Reportable NI values archived against current action='||p_assactid);
       archive_asg_info(g_reportable_ni_eid, 'Y');
    END IF;
  END IF;
  --
  hr_utility.set_location(' Leaving: '||l_proc,220);
EXCEPTION
   WHEN ASG_ACTION_ERROR THEN
      hr_utility.trace('ASG_ACTION_ERROR exception raised.');
      hr_utility.set_location(' Leaving: '||l_proc,230);
      raise;
   WHEN others THEN --Added for bug 7326591
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Erroneous Assignment ID ' || l_assignment_id);
     hr_utility.set_location(' Exception at : '||l_proc,235);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception at : ' || l_proc);
     raise;

END archive_code;
--
PROCEDURE extract_item_report_format(p_user_entity_name    in   varchar2,
                                     p_archive_type        in   varchar2) IS
-- This procedure inserts the necessary data into the
-- PAY_REPORT_FORMAT_ITEMS_F table FOR EXTRACT ARCHIVE ITEMS ONLY.
-- This distinction must be made as the procedure contains hard-
-- coded data, only relevant for extract items, ie those DBI/
-- User Entities starting 'X_'. Do not use this utility for
-- entering other data into these tables.
-- The Datetracking is 'handled' in this case by entering
-- start of time and end of time for all records. Again, this
-- is specific to Extract Items.
  --
  cursor csr_get_user_entity_id(c_user_entity_name VARCHAR2) IS
  SELECT user_entity_id
  FROM   ff_user_entities
  WHERE  user_entity_name = c_user_entity_name;
  --
  l_user_entity_id      NUMBER;
  invalid_archive_type  EXCEPTION;
  --
BEGIN
  --
  hr_utility.trace('Extract Item: '||p_user_entity_name);
  -- Retrieve user entity ID, also validates the entity.
  --
  OPEN csr_get_user_entity_id(p_user_entity_name);
  FETCH csr_get_user_entity_id INTO l_user_entity_id;
  IF csr_get_user_entity_id%notfound THEN
    RAISE no_data_found;
  END IF;
  --
  -- Validate the Archive Type
  --
  IF p_archive_type NOT IN ('AAP','PA','AAC') THEN
    RAISE invalid_archive_type;
  END IF;
  --
  -- Parameters validated, insert the two rows into PAY_REPORT_FORMAT_ITEMS_F,
  -- ensuring the inserts are re-runnable.
  --
  BEGIN
    -- 1. Report category F
    --
    INSERT INTO pay_report_format_items_f
      (report_type,
       report_qualifier,
       report_category,
       user_entity_id,
       effective_start_date,
       effective_end_date,
       archive_type,
       updatable_flag,
       display_sequence)
    SELECT
      'EOY',
      'GB',
      'F',
      l_user_entity_id,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      p_archive_type,
      'N',
      NULL
    FROM sys.dual WHERE NOT EXISTS
        (SELECT 1 FROM pay_report_format_items_f
         WHERE report_type = 'EOY'
         AND report_qualifier = 'GB'
         AND user_entity_id = l_user_entity_id
         AND report_category = 'F');
    --
    -- 2. Report category P
    --
    INSERT INTO pay_report_format_items_f
      (report_type,
       report_qualifier,
       report_category,
       user_entity_id,
       effective_start_date,
       effective_end_date,
       archive_type,
       updatable_flag,
       display_sequence)
    SELECT
      'EOY',
      'GB',
      'P',
      l_user_entity_id,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      p_archive_type,
      'N',
      NULL
    FROM sys.dual WHERE NOT EXISTS
          (SELECT 1 FROM pay_report_format_items_f
           WHERE report_type = 'EOY'
           AND report_qualifier = 'GB'
           AND user_entity_id = l_user_entity_id
           AND report_category = 'P');
  END;
  --
EXCEPTION
  WHEN invalid_archive_type THEN
    hr_utility.set_message(800, 'FF_34958_INVALID_ARCHIVE_TYPE');
    hr_utility.raise_error;
    --
END extract_item_report_format;
--
END pay_gb_eoy_archive;

/
