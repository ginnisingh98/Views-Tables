--------------------------------------------------------
--  DDL for Package PAY_IN_ETW_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_ETW_STRUCT" AUTHID CURRENT_USER AS
/* $Header: pyinetst.pkh 120.0.12010000.1 2008/07/27 22:53:18 appldev ship $ */
   g_package    CONSTANT VARCHAR2(20) := 'pay_in_etw_struct.';
--------------------------------------------------------------------------
-- TYPE Definitions used in ETW
--------------------------------------------------------------------------

   TYPE t_input_values_rec IS RECORD
          (input_value_name     pay_input_values_f.name%TYPE
          ,input_value_id       pay_input_values_f.input_value_id%TYPE
          ,uom                  pay_input_values_f.uom%TYPE
          ,mandatory_flag       pay_input_values_f.mandatory_flag%TYPE
          ,lookup_type          pay_input_values_f.lookup_type%TYPE
          ,default_value        pay_input_values_f.default_value%TYPE
	  ,def_value_column     pay_shadow_input_values.default_value_column%type
          ,min_value            pay_input_values_f.min_value%TYPE
          ,warn_or_error        pay_input_values_f.warning_or_error%TYPE
          ,balance_name         pay_balance_types.balance_name%TYPE
          ,exclusion_tag        VARCHAR2(10)
          );

   TYPE t_input_values_tab IS TABLE OF t_input_values_rec
     INDEX BY BINARY_INTEGER;

   TYPE t_formula_results_rec IS RECORD
          (result_name      pay_formula_result_rules_f.result_name%TYPE
          ,result_rule_type pay_formula_result_rules_f.result_rule_type%TYPE
          ,input_value_name pay_input_values_f.name%TYPE
          ,element_name     pay_element_types_f.element_name%TYPE
          ,severity_level   pay_formula_result_rules_f.severity_level%TYPE
          ,exclusion_tag    VARCHAR2(10)
           );

   TYPE t_formula_results_tab IS TABLE OF t_formula_results_rec
     INDEX BY BINARY_INTEGER;

   TYPE t_formula_setup_rec IS RECORD
         (formula_name      ff_formulas_f.formula_name%TYPE
         ,status_rule_id    pay_status_processing_rules_f.status_processing_rule_id%TYPE
	 ,formula_id        ff_formulas_f.formula_id%TYPE
	 ,description       ff_formulas_f.description%TYPE
         ,frs_setup         t_formula_results_tab
          );

   TYPE t_formula_setup_tab IS TABLE OF t_formula_setup_rec
     INDEX BY BINARY_INTEGER;

   TYPE t_user_formula_rec IS RECORD
         (name               VARCHAR2(15)
         ,text               VARCHAR2(10000)
         );

   TYPE t_user_formula_tab IS TABLE OF t_user_formula_rec
      INDEX BY BINARY_INTEGER;

   TYPE t_excl_rules_rec IS RECORD
         (ff_column          pay_template_exclusion_rules.flexfield_column%TYPE
         ,value              pay_template_exclusion_rules.exclusion_value%TYPE
         ,descr              pay_template_exclusion_rules.description%TYPE
         ,rule_id            pay_template_exclusion_rules.exclusion_rule_id%TYPE
         ,tag                VARCHAR2(10)
         );

   TYPE t_excl_rules_tab IS TABLE OF t_excl_rules_rec
     INDEX BY BINARY_INTEGER;

   TYPE t_balance_feeds_rec IS RECORD
         (balance_name       pay_balance_types.balance_name%TYPE
         ,iv_name            pay_input_values_f.name%TYPE
         ,scale              pay_balance_feeds_f.scale%TYPE
         ,exclusion_tag      VARCHAR2(10)
         );

   TYPE t_balance_feeds_tab IS TABLE OF t_balance_feeds_rec
     INDEX BY BINARY_INTEGER;

   TYPE t_add_elmt_setup_rec IS RECORD
         (element_name      pay_element_types_f.element_name%TYPE
         ,classification    pay_element_classifications.classification_name%TYPE
         ,exclusion_tag     VARCHAR2(10)
         ,priority          pay_shadow_element_types.relative_processing_priority%TYPE
         ,element_id        pay_shadow_element_types.element_type_id%TYPE
         ,iv_setup          t_input_values_tab
         ,bf_setup          t_balance_feeds_tab
         ,uf_setup          t_formula_setup_rec
         );

   TYPE t_add_elmt_setup_tab IS TABLE OF t_add_elmt_setup_rec
      INDEX BY BINARY_INTEGER;

   TYPE t_template_setup_rec IS RECORD
         (template_name     pay_element_templates.template_name%TYPE
         ,category          pay_element_classifications.classification_name%TYPE
         ,priority          pay_element_types_f.processing_priority%TYPE
         ,template_id       pay_element_templates.template_id%TYPE
         ,base_element_id   pay_element_types_f.element_type_id%TYPE
         ,er_setup          t_excl_rules_tab
         ,uf_setup          t_formula_setup_rec
         ,iv_setup          t_input_values_tab
         ,bf_setup          t_balance_feeds_tab
         ,sf_setup          t_formula_setup_rec
         ,ae_setup          t_add_elmt_setup_tab
         );

   TYPE t_template_setup_tab IS TABLE OF t_template_setup_rec
     INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
-- Global/Public Variables required in ETW
--------------------------------------------------------------------------
   g_template_obj     t_template_setup_tab;
   g_formula_obj      t_user_formula_tab;
   g_max_length       CONSTANT NUMBER := 50;
   g_template_type    CONSTANT VARCHAR2(1) := 'T';
   g_legislation_code CONSTANT VARCHAR2(2) := 'IN';
   g_currency_code    CONSTANT VARCHAR2(3) := 'INR';

--------------------------------------------------------------------------
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the templates for ETW       --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
   PROCEDURE init_code ;

--------------------------------------------------------------------------
-- Name           : INIT_FORMULA                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the user-formula texts      --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
   PROCEDURE init_formula;

END pay_in_etw_struct;

/
