--------------------------------------------------------
--  DDL for Package Body PAY_FORMULA_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FORMULA_RESULTS" AS
/* $Header: pyfrrspr.pkb 120.0 2005/05/29 05:08:23 appldev noship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_user_init_dedn
    Filename	: pyusuidt.pkb
    Change List
    -----------
    Date        Name          Vers    Bug No    Description
    ----        ----          ----    ------    -----------
    01-NOV-93   H.Parichabutr  1.0              Created by cutting
                                                procedures from "benchmark"
						package - since benchmark
						is not supported by core.
						Do not know if status proc or
						result rule api exist in any
						other package (i couldn't find
						them if they are).
    01-NOV-93	hparicha	1.1		Updated formula result api
						to accept an element type id
						which can actually be an
						element type id or an
						input value id!  This will
						enable Indirect, Stop, and
						Update Recurring result rules
						to be created.
    30-JAN-01   alogue        115.1  1517903    MLS support of untranslated
                                                "Pay Value" name in
                                                pay_input_values_f.
    28-FEB-05   adkumar       115.2  4199736    Enabled feature for Direct Result
                                                to feed input values other than
						'Pay Value'.

*/
--
 ----------------------------- ins_stat_proc_rule ----------------------------
 --  NAME
 --    ins_stat_proc_rule
 --  DESCRIPTION
 --    Creates a status processing rule for an element.
 --  NOTES
--
 FUNCTION ins_stat_proc_rule
 (
--
   p_business_group_id          NUMBER DEFAULT NULL,
   p_legislation_code           VARCHAR2 DEFAULT NULL,
   p_legislation_subgroup       VARCHAR2 DEFAULT NULL,
   p_effective_start_date       DATE DEFAULT NULL,
   p_effective_end_date         DATE DEFAULT NULL,
--
   p_element_type_id            NUMBER,
   p_assignment_status_type_id  NUMBER DEFAULT NULL,
   p_formula_id                 NUMBER DEFAULT NULL,
--
   p_processing_rule            VARCHAR2
--
) RETURN NUMBER IS
--..
 -- Local constants
 c_end_of_time  CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
--
 -- Local variables
 v_stat_proc_rule_id  NUMBER;
--
 BEGIN
--
   SELECT pay_status_processing_rules_s.nextval
   INTO   v_stat_proc_rule_id
   FROM   sys.dual;
--
   INSERT INTO pay_status_processing_rules_f
   (STATUS_PROCESSING_RULE_ID,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    BUSINESS_GROUP_ID,
    LEGISLATION_CODE,
    ELEMENT_TYPE_ID,
    ASSIGNMENT_STATUS_TYPE_ID,
    FORMULA_ID,
    PROCESSING_RULE,
    LEGISLATION_SUBGROUP,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE)
   VALUES
   (v_stat_proc_rule_id,
    nvl(p_effective_start_date,trunc(sysdate)),
    nvl(p_effective_end_date,c_end_of_time),
    p_business_group_id,
    p_legislation_code,
    p_element_type_id,
    p_assignment_status_type_id,
    p_formula_id,
    p_processing_rule,
    p_legislation_subgroup,
    trunc(sysdate),
    -1,
    -1,
    -1,
    trunc(sysdate));
--
   RETURN v_stat_proc_rule_id;
--
 END ins_stat_proc_rule;
--.
 ----------------------------- ins_form_res_rule ----------------------------
 --  NAME
 --    ins_form_res_rule
 --  DESCRIPTION
 --    Creates a formula result rule for an element..
 --  NOTES
--
 FUNCTION ins_form_res_rule
 (
--
  p_business_group_id          NUMBER DEFAULT NULL,
  p_legislation_code           VARCHAR2 DEFAULT NULL,
  p_legislation_subgroup       VARCHAR2 DEFAULT NULL,
  p_effective_start_date       DATE DEFAULT NULL,
  p_effective_end_date         DATE DEFAULT NULL,
--
  p_status_processing_rule_id  NUMBER,
  p_input_value_id             NUMBER DEFAULT NULL,
--
  p_result_name                VARCHAR2,
  p_result_rule_type           VARCHAR2,
  p_severity_level             VARCHAR2 DEFAULT NULL,
  p_element_type_id	       NUMBER DEFAULT NULL
--
 ) RETURN NUMBER IS
--..
 -- Local constants
 c_end_of_time  CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
--
 -- Local variables
 v_input_value_id  NUMBER;
 v_form_res_rule_id  NUMBER;
--
 BEGIN
--
-- If this is to be a direct result rule, then the input value id on
-- the rule must be set to that for the pay value of the element type.
-- In order to save deriving this before every call, it is derived
-- within this function.
--
-- Bug no. 4199736, Added condition 'and p_input_value_id is null' in If clause
--
   if (p_result_rule_type = 'D' and p_input_value_id is null) then
      SELECT inp.input_value_id
      INTO v_input_value_id
      FROM pay_input_values_f inp,
           pay_status_processing_rules_f spr
      WHERE spr.status_processing_rule_id = p_status_processing_rule_id
      AND   inp.element_type_id = spr.element_type_id
      AND   inp.name = 'Pay Value';
   else
      v_input_value_id := p_input_value_id;
   end if;
--
   SELECT pay_formula_result_rules_s.nextval
   INTO   v_form_res_rule_id
   FROM   sys.dual;
--
   INSERT INTO pay_formula_result_rules_f
   (FORMULA_RESULT_RULE_ID,
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
    CREATION_DATE,
    ELEMENT_TYPE_ID)
   VALUES
   (v_form_res_rule_id,
    nvl(p_effective_start_date,trunc(sysdate)),
    nvl(p_effective_end_date,c_end_of_time),
    p_business_group_id,
    p_legislation_code,
    p_status_processing_rule_id,
    p_result_name,
    p_result_rule_type,
    p_legislation_subgroup,
    p_severity_level,
    v_input_value_id,
    trunc(sysdate),
    -1,
    -1,
    -1,
    trunc(sysdate),
    p_element_type_id);
--
   RETURN v_form_res_rule_id;
--
 END ins_form_res_rule;
--
END pay_formula_results;

/
