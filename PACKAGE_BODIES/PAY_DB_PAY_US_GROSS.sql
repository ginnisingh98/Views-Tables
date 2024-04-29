--------------------------------------------------------
--  DDL for Package Body PAY_DB_PAY_US_GROSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DB_PAY_US_GROSS" as
/* $Header: pypusgrs.pkb 115.1 99/07/17 06:27:07 porting ship $ */
--
--
--  Change List
--  -----------
--  Date        Name          Vers    Bug No    Description
--  ----        ----          ----    ------    -----------
-- 02-MAR-99  J. Moyano       115.1             MLS Changes. Added
--                                              references to _TL tables.
--
--
/*----------------------------------------------------------------------*\
 |  PROCEDURE								|
 |	create_vertex_element_names					|
 |									|
 |  PURPOSE								|
 |	Creates the array (PL*SQL Table) of element names and result	|
 |	name prefixes required by the VERTEX PayrollTax element		|
 |	of the Payroll Run.						|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
--
procedure create_vertex_element_names IS
--
begin
   hr_utility.set_location('pay_db_pay_us_gross.create_vertex_element_names',1);
--
-- Create a table for the VERTEX element names. The name will be suffixed with
-- '_%elname%' to create the actual element name. e.g. 'VERTEX_WORK_bonus'.
-- When creating the Vertex Tax elements; The first element will be the
-- Recurring element and the last one (VERTEX_GROSSUP) is not created.
-- In the case of the grossup elements; The name will be suffixed with
-- '_%elname%' to create the actual element name. e.g. 'VERTEX_WORK_bonus'.
-- The first element (VERTEX_%elname%) will already have been created by the
-- form. The last element will have the Vertex gross-up formula result rule
-- (GROSS_UP_GROSS) and messages associated with it.
--
   g_vtx_elem_tab(1) := 'VERTEX';
   g_vtx_elem_tab(2) := 'VERTEX2';
   g_vtx_elem_tab(3) := 'VERTEX_WORK';
   g_vtx_elem_tab(4) := 'VERTEX_WORK2';
   g_vtx_elem_tab(5) := 'VERTEX_SUI';
   g_vtx_elem_tab(6) := 'VERTEX_HOME';
   g_vtx_elem_tab(7) := 'VERTEX_RESULTS';
   g_vtx_elem_tab(8) := '_GROSSUP';
--
-- Create a table of Input value names. All elements except %elname%_GROSSUP
-- require the first four input values in addition to the 'Pay Value'.
-- Elements number 4-7 also require the Geocode2 input value.
-- Note the list is also used to create the formula result rule for the
-- previous element that feeds the input value
--
   g_vtx_input_value(0) := 'Pay Value';		g_vtx_uom(0) := 'Money';
   g_vtx_input_value(1) := 'Jurisdiction';	g_vtx_uom(1) := 'Character';
   g_vtx_input_value(2) := 'Percentage';	g_vtx_uom(2) := 'Money';
   g_vtx_input_value(3) := 'Calc_Mode';		g_vtx_uom(3) := 'Character';
   g_vtx_input_value(4) := 'Net';		g_vtx_uom(4) := 'Money';
   g_vtx_input_value(5) := 'Geocode2';		g_vtx_uom(5) := 'Character';
--
-- Create a table of result rule names. All elements require the
-- GEN_FAILURE_CODE result rule (type fatal). VERTEX_RESULTS also
-- requires the other 18 'M'essage type result rules.
--
   g_vtx_result_name(0) := 'GEN_FAILURE_CODE';
   g_vtx_result_name(1) := 'GEN_RETURN_CODE';
   g_vtx_result_name(2) := 'FIT_RETURN';
   g_vtx_result_name(3) := 'FSP_RETURN';
   g_vtx_result_name(4) := 'FICA_EE_RETURN';
   g_vtx_result_name(5) := 'FICA_ER_RETURN';
   g_vtx_result_name(6) := 'FUTA_RETURN';
   g_vtx_result_name(7) := 'MEDI_EE_RETURN';
   g_vtx_result_name(8) := 'MEDI_ER_RETURN';
   g_vtx_result_name(9) := 'EIC_RETURN';
   g_vtx_result_name(10) := 'WS_STT_RETURN';
   g_vtx_result_name(11) := 'RS_STT_RETURN';
   g_vtx_result_name(12) := 'SUI_EE_RETURN';
   g_vtx_result_name(13) := 'SUI_ER_RETURN';
   g_vtx_result_name(14) := 'SDI_EE_RETURN';
   g_vtx_result_name(15) := 'SDI_ER_RETURN';
   g_vtx_result_name(16) := 'WK_CITY_RETURN';
   g_vtx_result_name(17) := 'WK_COUNTY_RETURN';
   g_vtx_result_name(18) := 'RS_CITY_RETURN';
   g_vtx_result_name(19) := 'RS_COUNTY_RETURN';
--
   hr_utility.set_location('pay_db_pay_us_gross.create_vertex_element_names',2);
--
end create_vertex_element_names;
--
--
/*----------------------------------------------------------------------*\
 |  PROCEDURE								|
 |	delete_gross_up						|
 |									|
 |  PURPOSE								|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
--
procedure delete_gross_up (
			p_business_group_id	IN NUMBER,
			p_element_name		IN VARCHAR2
			) IS
-- Local Variables
v_element_name		PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
--
CURSOR elements IS
   SELECT	pet.element_name,
		pet.element_type_id,
		processing_priority,
		element_information10,
		element_information12
   FROM		pay_element_types_f pet,
		per_business_groups pbg
   WHERE	pbg.business_group_id + 0 = pet.business_group_id + 0
   AND		pbg.business_group_id + 0 = p_business_group_id
   AND		pet.element_name like v_element_name;
--
begin
--
   hr_utility.set_location('pay_db_pay_us_gross.delete_gross_up', 1);
   v_element_name := 'VERTEX%' || p_element_name;
--
   FOR elem_rec IN elements LOOP
--
      hr_utility.set_location('pay_db_pay_us_gross.delete_gross_up', 2);
      hr_user_init_earn.do_deletions (
				p_business_group_id=>p_business_group_id,
				p_ele_type_id=>elem_rec.element_type_id,
				p_ele_name=>elem_rec.element_name,
				p_ele_priority=>elem_rec.processing_priority,
				p_ele_info_10=>elem_rec.element_information10,
				p_ele_info_12=>elem_rec.element_information12,
				p_del_sess_date=>NULL,
				p_del_val_start_date=>NULL,
				p_del_val_end_date=>NULL
				);
--
   END LOOP;
--
   hr_utility.set_location('pay_db_pay_us_gross.delete_gross_up', 3);
--
end delete_gross_up;
--
--
/*----------------------------------------------------------------------*\
 |  PROCEDURE								|
 |	create_gross_up							|
 |									|
 |  PURPOSE								|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
--
function create_gross_up (
			p_business_group_name   IN VARCHAR2 DEFAULT NULL,
			p_element_name		IN VARCHAR2,
			p_classification	IN VARCHAR2,
			p_reporting_name	IN VARCHAR2,
			p_formula_name		IN VARCHAR2,
			p_priority		IN NUMBER,
                        p_effective_start_date  IN DATE     DEFAULT NULL,
			p_effective_end_date  	IN DATE     DEFAULT NULL
                                ) RETURN NUMBER IS
-- Local Variables
v_element_type_ID	NUMBER;
v_prev_proc_rule_ID	NUMBER;
v_result_rule_ID	NUMBER;
v_formula_ID		NUMBER;
v_element_name		PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
v_input_value_ID	NUMBER;
v_start_date		DATE;
v_end_date		DATE;
v_piv_name		PAY_INPUT_VALUES_F.NAME%TYPE;
--
begin
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 1);
--
-- Find the Business_group_id for the parameter
   IF p_business_group_name is NOT NULL THEN
      SELECT business_group_id
      INTO   g_business_group_ID
      FROM   per_business_groups
      WHERE  upper(name) = upper(p_business_group_name);
   END IF;
--
   IF p_effective_start_date IS NULL THEN
      v_start_date := g_default_start_date;
   ELSE
      v_start_date := p_effective_start_date;
   END IF;
--
   IF p_effective_end_date IS NULL THEN
      v_end_date := g_max_end_date;
   ELSE
      v_end_date := p_effective_end_date;
   END IF;
--
-- Get the Element_type_id and Formula_id for the existing %elname% element
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 2);
--
   SELECT type.element_type_id
   INTO	  v_element_type_id
   FROM	  pay_element_types_f_tl type_tl,
          pay_element_types_f type
   WHERE  type_tl.element_type_id = type.element_type_id
   and    userenv('LANG') = type_tl.language
   AND    nvl(business_group_id, -1) = nvl(g_business_group_ID, -1)
   AND	  type_tl.element_name = p_element_name;
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 3);
--
   SELECT formula_id
   INTO	  v_formula_id
   FROM	  ff_formulas_f ff,
	  ff_formula_types ft
   WHERE  ft.formula_type_name = 'Oracle Payroll'
   AND	  ff.formula_type_id = ft.formula_type_id
   AND	  ff.formula_name = p_formula_name;
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 4);
--
-- Create the chain of Vertex elements ;
-- VERTEX--->VERTEX2--->VERTEX_WORK--->VERTEX_WORK2-->
-- VERTEX_HOME-->VERTEX_SUI-->VERTEX_RESULTS
--
   v_prev_proc_rule_ID := create_linked_elements (
		p_mode=>'Grossup',
		p_element_name=>p_element_name,
		p_element_type_id=>v_element_type_id,
		p_formula_id=>v_formula_id,
		p_priority=>p_priority,
		p_business_group_name=>p_business_group_name,
		p_start_date=>v_start_date,
		p_end_date=>v_end_date
		);
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 5);
--
-- Create the final element '%elname%_GROSSUP'
--
   v_element_name := p_element_name || g_vtx_elem_tab(g_max_elnum);
--
   hr_utility.trace('** Creating Element ' || v_element_name);
--
   v_element_type_ID := pay_db_pay_setup.create_element (
		p_element_name=>v_element_name,
		p_description=>'Gross up element for ' || p_element_name,
		p_reporting_name=>p_reporting_name || '_final',
		p_classification_name=>p_classification,
		p_processing_type=>'N',
		p_mult_entries_allowed=>'Y',
		p_processing_priority=>p_priority + g_max_elnum,
		p_standard_link_flag=>'N',
		p_post_termination_rule=>'Final Close',
		p_indirect_only_flag=>'N',
		p_effective_start_date=>v_start_date,
		p_effective_end_date=>v_end_date,
		p_business_group_name=>p_business_group_name,
		p_legislation_code=>'US'
		);
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 6);
--
-- Get the input_value_id for the 'Pay Value' input value that was created
-- for the '%elname%_GROSSUP' element.
--
   v_piv_name := hr_input_values.get_pay_value_name ('US');
--
   SELECT piv.input_value_id
   INTO   v_input_value_ID
   FROM   pay_input_values_f_tl piv_tl,
          pay_input_values_f piv,
	  pay_element_types_f_tl pet_tl,
          pay_element_types_f pet
   WHERE  piv_tl.input_value_id = piv.input_value_id
   and    pet_tl.element_type_id = pet.element_type_id
   and    userenv('LANG') = piv_tl.language
   and    userenv('LANG') = pet_tl.language
   AND    piv_tl.name = v_piv_name
   AND    nvl(piv.business_group_id, -1) = nvl(g_business_group_ID, -1)
   AND    pet.element_type_id = piv.element_type_id
   AND    pet_tl.element_name = v_element_name;
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up',7);
--
-- Create the Result rule from VERTEX_RESULTS to feed the
-- 'Pay Value' input value.
--
   v_result_rule_id := create_result_rule (
		p_result_name=>'GROSS_UP_GROSS',
		p_stat_proc_id=>v_prev_proc_rule_ID,
		p_input_value_id=>v_input_value_ID,
		p_effective_start_date=>v_start_date,
		p_effective_end_date=>v_end_date
		);
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 8);
--
-- Get the input_value_id for the 'Pay Value' input value that was created
-- for the FIT_GROSSUP_ADJUSTMENT element.
--
   SELECT piv.input_value_id
   INTO   v_input_value_ID
   FROM   pay_input_values_f_tl piv_tl,
          pay_input_values_f piv,
	  pay_element_types_f pet
   WHERE  piv_tl.input_value_id = piv.input_value_id
   and    userenv('LANG') = piv_tl.language
   and    piv_tl.name = v_piv_name
   AND    piv.business_group_id is null
   AND    pet.element_type_id = piv.element_type_id
   AND    pet.element_name = 'FIT_GROSSUP_ADJUSTMENT';
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 10);
--
-- Create the the result rule to feed the FIT_GROSSUP_ADJUSTMENT tax element
--
   v_result_rule_id := create_result_rule (
		p_result_name=>'FIT_GROSSUP_ADJUSTMENT',
		p_stat_proc_id=>v_prev_proc_rule_ID,
		p_input_value_id=>v_input_value_ID,
		p_effective_start_date=>v_start_date,
		p_effective_end_date=>v_end_date
		);
--
   hr_utility.set_location('pay_db_pay_us_gross.create_gross_up', 11);
--
   return v_element_type_ID;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
--
end create_gross_up;
--
--
/*----------------------------------------------------------------------*\
 |  FUNCTION								|
 |	create_linked_elements						|
 |									|
 |  PURPOSE								|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
function create_linked_elements (
			p_mode			VARCHAR2,
			p_element_name		VARCHAR2,
			p_element_type_id	NUMBER,
			p_formula_id		NUMBER,
			p_priority		NUMBER,
			p_business_group_name	VARCHAR2,
			p_start_date		DATE,
			p_end_date		DATE
				) RETURN NUMBER IS
-- Local Variables
v_formula_ID		NUMBER;
v_element_type_ID	NUMBER;
v_element_name		PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
v_priority_incr		NUMBER;
v_classification	VARCHAR2(80);
v_post_termination	VARCHAR2(80);
v_description		VARCHAR2(240);
v_element_num		BINARY_INTEGER;
v_start_elnum		BINARY_INTEGER;
v_prev_proc_rule_ID	NUMBER;
v_result_rule_ID	NUMBER;
v_input_value_ID	NUMBER;
v_linknum		NUMBER;
v_msg_num		NUMBER;
v_processing_priority	NUMBER;
--
begin
   hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 1);
--
   v_formula_ID := p_formula_id;
   v_element_type_ID := p_element_type_id;
--
   IF p_mode = 'Grossup' THEN
      v_priority_incr := 1;
      v_processing_priority := p_priority;
      v_start_elnum := 1;
      v_classification := 'Information';
      v_post_termination := 'Final Close';
      v_description := 'Gross Up program element';
--
-- Get the Status Processing Rule for the previous (GROSSUP) element
--
      SELECT	STATUS_PROCESSING_RULE_ID
      INTO	v_prev_proc_rule_id
      FROM	PAY_STATUS_PROCESSING_RULES_F
      WHERE	ELEMENT_TYPE_ID = v_element_type_ID;
--
      hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 2);
--
   ELSE
      v_priority_incr := 10;
      v_processing_priority := p_priority - v_priority_incr;
      v_start_elnum := 2;
      v_classification := 'Tax Deductions';
      v_post_termination := 'Actual Termination';
      v_description := 'PayrollTax Calculation program VERTEX Element';
--
-- Create a Status Processing Rule for the previous (VERTEX) element
--
      v_prev_proc_rule_id := create_status_proc_rule (
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date,
		p_formula_id=>v_formula_ID,
		p_element_type_id=>v_element_type_ID
		);
--
      hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 3);
--
   END IF;
--
   begin
      FOR v_element_num in v_start_elnum..g_max_elnum - 1 LOOP
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 4);
--
-- Find the formula...
--
--
         SELECT	formula_id
         INTO	v_formula_id
         FROM	ff_formulas_f ff,
	  	ff_formula_types ft
         WHERE	ft.formula_type_name = 'Oracle Payroll'
         AND	ff.formula_type_id = ft.formula_type_id
         AND	ff.formula_name = g_vtx_elem_tab(v_element_num);
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 5);
--
-- Create the element...
--
         IF p_mode = 'Grossup' THEN
            v_element_name := g_vtx_elem_tab(v_element_num)
			|| '_' || p_element_name;
         ELSE
            v_element_name := g_vtx_elem_tab(v_element_num);
         END IF;
--
         hr_utility.trace('** Creating Element ' || v_element_name);
--
         v_element_type_ID := pay_db_pay_setup.create_element (
		p_element_name=>v_element_name,
		p_description=>v_description,
		p_reporting_name=>v_element_name,
		p_classification_name=>v_classification,
		p_processing_type=>'N',
		p_mult_entries_allowed=>'Y',
		p_processing_priority=>v_processing_priority +
					 (v_element_num * v_priority_incr),
		p_standard_link_flag=>'N',
		p_post_termination_rule=>v_post_termination,
		p_indirect_only_flag=>'N',
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date,
		p_business_group_name=>p_business_group_name,
		p_legislation_code=>'US'
		);
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 6);
--
         IF (p_mode = 'Grossup') THEN
--
-- Create the 'Pay Value' input as this is an Information element
--
            v_input_value_ID := pay_db_pay_setup.create_input_value (
		p_element_name=>v_element_name,
		p_uom=>g_vtx_uom(0),
		p_name=>g_vtx_input_value(0),
		p_display_sequence=>1,
		p_generate_db_item_flag=>'N',
		p_business_group_name=>p_business_group_name,
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date
		);
         ELSE
--
-- Delete the entity horizon as it gets recreated on startup data load
--
            hrdyndbi.delete_element_type_dict(
			p_element_type_id=>v_element_type_ID);
         END IF;
--
-- Create the input values and run results
--
         v_linknum := 1;
/*
 * This is not really an infinite loop as the exception NO_DATA_FOUND
 * will be raised if the end of the PL*SQL table has been reached,
 * or the EXIT WHEN condtion is met
 */
         begin
            LOOP
--
               EXIT WHEN (v_linknum = 5) and (v_element_num < 5);
               /* Do not create geocode2 result for first 4 elements */
--
               create_indirect_link (
			p_element_name=>v_element_name,
			p_uom=>g_vtx_uom(v_linknum),
			p_name=>g_vtx_input_value(v_linknum),
			p_display_sequence=>v_linknum + 1,
			p_stat_proc_id=>v_prev_proc_rule_ID,
			p_business_group_name=>p_business_group_name,
			p_effective_start_date=>p_start_date,
			p_effective_end_date=>p_end_date
			);
--
               hr_utility.set_location(
			'pay_db_pay_us_gross.create_linked_elements', 7);
--
               v_linknum := v_linknum + 1;
--
            END LOOP;
--
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  null;
         end;
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 8);
--
-- Create the (fatal) message result for the previous element
--
         v_result_rule_id := create_result_rule (
		p_result_name=>g_vtx_result_name(0),
		p_result_type=>'M',
		p_severity=>'F',
		p_stat_proc_id=>v_prev_proc_rule_ID,
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date
		);
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 9);
--
--
-- Create the Status Processing Rule for the previous element
--
         v_prev_proc_rule_id := create_status_proc_rule (
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date,
		p_formula_id=>v_formula_ID,
		p_element_type_id=>v_element_type_ID
		);
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 10);
--
      END LOOP;
--
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            null;
   end;		-- FOR v_element_num in v_start_elnum..
--
-- The VERTEX_RESULTS element has just been created with its input
-- values and status processing rule. It now needs :
-- 1)   The Fatal Message Result.
-- 2)	the Warning Message results.
--
   hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 11);
--
/* Create the Fatal message result rule */
--
   v_result_rule_id := create_result_rule (
		p_result_name=>g_vtx_result_name(0),
		p_result_type=>'M',
		p_severity=>'F',
		p_stat_proc_id=>v_prev_proc_rule_ID,
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date
		);
--
   v_msg_num := 1;
/*
 * Create the warning message result rules.
 *
 * This is not really an infinite loop as the exception NO_DATA_FOUND
 * will be raised when the end of the PL*SQL table has been reached.
 */
   begin
      LOOP
--
         hr_utility.trace('** Cr. Rslt Rule ' || g_vtx_result_name(v_msg_num));
--
         v_result_rule_ID := pay_db_pay_us_gross.create_result_rule (
		p_result_name=>g_vtx_result_name(v_msg_num),
		p_result_type=>'M',	-- 'M'essage
		p_severity=>'W',	-- 'W'arning
		p_stat_proc_ID=>v_prev_proc_rule_ID,
		p_effective_start_date=>p_start_date,
		p_effective_end_date=>p_end_date
		);
--
         v_msg_num := v_msg_num + 1;
--
         hr_utility.set_location('pay_db_pay_us_gross.create_linked_elements', 12);
--
      END LOOP;
--
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
   end;
--
   return v_prev_proc_rule_id;
--
end create_linked_elements;
--
--
/*----------------------------------------------------------------------*\
 |  PROCEDURE								|
 |	create_indirect_link						|
 |									|
 |  PURPOSE								|
 |	Create an input value on the current element and the result	|
 |	on the previous element, using its status processing rule ID	|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
procedure create_indirect_link (
		p_element_name		VARCHAR2,
		p_uom			VARCHAR2,
		p_name			VARCHAR2,
		p_display_sequence	NUMBER,
		p_stat_proc_id		NUMBER,
		p_business_group_name	VARCHAR2,
		p_effective_start_date	DATE,
		p_effective_end_date	DATE
		) IS
-- Local Variables
v_input_value_ID	NUMBER;
v_result_rule_ID	NUMBER;
--
begin
--
   hr_utility.set_location('pay_db_pay_us_gross.create_indirect_link', 1);
--
   hr_utility.trace('** Creating Input Value ' || p_name);
--
   v_input_value_ID := pay_db_pay_setup.create_input_value (
		p_element_name=>p_element_name,
		p_uom=>p_uom,
		p_name=>p_name,
		p_display_sequence=>p_display_sequence,
		p_generate_db_item_flag=>'N',
		p_business_group_name=>p_business_group_name,
		p_effective_start_date=>p_effective_start_date,
		p_effective_end_date=>p_effective_end_date
		);
--
   hr_utility.set_location('pay_db_pay_us_gross.create_indirect_link', 2);
--
   v_result_rule_id := create_result_rule (
		p_result_name=>p_name,
		p_stat_proc_id=>p_stat_proc_ID,
		p_input_value_id=>v_input_value_ID,
		p_effective_start_date=>p_effective_start_date,
		p_effective_end_date=>p_effective_end_date
		);
--
   hr_utility.set_location('pay_db_pay_us_gross.create_indirect_link', 3);
--
end create_indirect_link;
--
--
/*----------------------------------------------------------------------*\
 |  FUNCTION								|
 |	create_status_proc_rule						|
 |									|
 |  PURPOSE								|
 |	create one row in the PAY_STATUS_PROCESSING_RULES_F table	|
 |	for the VERTEX formula						|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
--
function create_status_proc_rule(
                        p_effective_start_date  IN DATE,
                        p_effective_end_date    IN DATE,
			p_formula_ID            IN NUMBER   DEFAULT NULL,
			p_element_type_ID       IN NUMBER
                                ) RETURN NUMBER IS
-- Local Variables
v_rule_ID		NUMBER;			-- status processing rule ID
--
begin
--
   hr_utility.set_location('pay_db_pay_us_gross.create_status_proc_rule', 1);
-- Create the status_processing_rule_id
--
   SELECT pay_status_processing_rules_s.nextval
   INTO   v_rule_ID
   FROM   sys.dual;
--
   hr_utility.set_location('pay_db_pay_us_gross.create_status_proc_rule', 2);
--
   INSERT INTO PAY_STATUS_PROCESSING_RULES_F
   (
      STATUS_PROCESSING_RULE_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      ELEMENT_TYPE_ID,
      ASSIGNMENT_STATUS_TYPE_ID,
      FORMULA_ID,
      PROCESSING_RULE,
      COMMENT_ID,
      LEGISLATION_SUBGROUP,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE
   )
   select
      v_rule_ID,
      p_effective_start_date,
      p_effective_end_date,
      g_business_group_ID,
      'US',
      p_element_type_ID,
      ASSIGNMENT_STATUS_TYPE_ID,	-- assignment_status_type_id
      p_formula_ID,
      'P',			-- processing rule
      NULL,			-- comment ID
      NULL,			-- legislation subgroup
      g_todays_date,
      -1,
      -1,
      -1,
      g_todays_date
   from   per_assignment_status_types
   where  USER_STATUS = 'Active Assignment';
--
   hr_utility.set_location('pay_db_pay_us_gross.create_status_proc_rule', 3);
--
   return v_rule_ID;
--
end create_status_proc_rule;
--
--
/*----------------------------------------------------------------------*\
 |  FUNCTION								|
 |	create_result_rule						|
 |									|
 |  PURPOSE								|
 |	Creates a formula result rule for a combination of an element,	|
 |	a result name, its type, and an input value. Required by	|
 |	the VERTEX PayrollTax element of the Payroll Run.		|
 |									|
 |  NOTES								|
 |									|
\*----------------------------------------------------------------------*/
--
function create_result_rule(
			p_legislation_code      VARCHAR2 DEFAULT 'US',
			p_result_name		VARCHAR2 ,
			p_result_type		VARCHAR2 DEFAULT 'I',
			p_severity		VARCHAR2 DEFAULT NULL,
			p_stat_proc_ID		NUMBER,
			p_input_value_ID	NUMBER   DEFAULT NULL,
			p_effective_start_date  DATE,
			p_effective_end_date    DATE
			) RETURN number IS
-- Local Variables
v_rule_ID		NUMBER;
--
begin
   hr_utility.set_location('pay_db_pay_us_gross.create_result_rule', 1);
--
-- Select the next sequence number for PAY_FORMULA_RESULT_RULES
   SELECT pay_formula_result_rules_s.nextval
   INTO   v_rule_ID
   FROM   sys.dual;
--
   hr_utility.set_location('pay_db_pay_us_gross.create_result_rule', 2);
--
   hr_utility.trace('** Creating Result Rule ' || p_result_name);
--
-- Now do the INSERT into the PAY_FORMULA_RESULT_RULES_F table
   INSERT INTO pay_formula_result_rules_f
   (
      FORMULA_RESULT_RULE_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      STATUS_PROCESSING_RULE_ID,
      RESULT_NAME,
      RESULT_RULE_TYPE,
      LEGISLATION_SUBGROUP,
      SEVERITY_LEVEL,
      INPUT_VALUE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE
   )
   values
   (
      v_rule_ID,
      p_effective_start_date,
      p_effective_end_date,
      g_business_group_ID,
      p_legislation_code,		-- Legislation Code
      p_stat_proc_ID,		-- Status Processing Rule ID
      upper(p_result_name),
      p_result_type,
      NULL,			-- Legislation Subgroup
      p_severity,
      p_input_value_ID,
      g_todays_date,
      -1,
      -1,
      -1,
      g_todays_date
   );
--
   hr_utility.set_location('pay_db_pay_us_gross.create_result_rule', 3);
--
   return v_rule_ID;
--
end create_result_rule;
--
--
begin	-- Initialization
  hr_utility.set_location('pay_db_pay_us_gross.initialization', 1);
  create_vertex_element_names;
  hr_utility.set_location('pay_db_pay_us_gross.initialization', 2);
end pay_db_pay_us_gross;

/
