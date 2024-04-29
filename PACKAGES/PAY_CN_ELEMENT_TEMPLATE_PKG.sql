--------------------------------------------------------
--  DDL for Package PAY_CN_ELEMENT_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_ELEMENT_TEMPLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pycneltp.pkh 120.0 2005/05/29 04:00 appldev noship $ */

   TYPE t_form_results_rec IS RECORD
          (result_name      pay_formula_result_rules_f.result_name%TYPE
	  ,result_rule_type pay_formula_result_rules_f.result_rule_type%TYPE
          ,input_value_name pay_input_values_f.name%TYPE
	  ,element_name     pay_element_types_f.element_name%TYPE
	  ,severity_level   pay_formula_result_rules_f.severity_level%TYPE
	  );

   TYPE t_form_results_tab IS TABLE OF t_form_results_rec
     INDEX BY BINARY_INTEGER;

   TYPE t_fr_setup_rec IS RECORD
         (template_name     pay_element_types_f.element_information1%TYPE
	 ,category          VARCHAR2(25)
	 ,formula_name      ff_formulas_f.formula_name%TYPE
	 ,status_rule_id    pay_status_processing_rules_f.status_processing_rule_id%TYPE
	 ,fr_set_index      NUMBER
	 ,fr_count          NUMBER
          );

   TYPE t_results_setup_tab IS TABLE OF t_fr_setup_rec
     INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ELEMENT_TEMPLATE_POST_PROCESS                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to do psot processing for template engines--
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_template_id          NUMBER                       --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE element_template_post_process (p_template_id IN NUMBER);

END pay_cn_element_template_pkg;

 

/
