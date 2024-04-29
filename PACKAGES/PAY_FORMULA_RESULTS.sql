--------------------------------------------------------
--  DDL for Package PAY_FORMULA_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FORMULA_RESULTS" AUTHID CURRENT_USER AS
/* $Header: pyfrrspr.pkh 120.0 2005/05/29 05:08:33 appldev noship $ */
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
*/
--.
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
) RETURN NUMBER;
--..
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
 ) RETURN NUMBER;
--..
--.
--..
END pay_formula_results;

 

/
