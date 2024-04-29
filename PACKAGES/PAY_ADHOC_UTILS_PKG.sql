--------------------------------------------------------
--  DDL for Package PAY_ADHOC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ADHOC_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyadcutl.pkh 120.4.12000000.1 2007/01/17 15:15:19 appldev noship $ */
--
 TYPE r_record IS RECORD
        (v_input_name     pay_input_values_f.name%type,
	 v_input_value    varchar2(80),
	 v_element_name   pay_element_types_f.element_name%type,
	 v_classification pay_element_classifications.classification_name%type ,
	 v_recurring      varchar2(1000) );
--
 TYPE v_input_name_value_tab IS TABLE OF r_record INDEX  BY BINARY_INTEGER;
--
 g_input_name_value_tab  v_input_name_value_tab;
--
 g_element_entry_id      NUMBER ;
 g_effective_start_date  DATE   ;
 g_effective_end_date    DATE   ;
--
--Variables for the Assignment Run Balance Details with GRE workbook
--Used in the function get_balance_valid_load_date
--
g_balance_name       pay_balance_types.balance_name%TYPE;
g_attribute_name     pay_bal_attribute_definitions.attribute_name%TYPE;
g_balance_load_date  DATE;
--
FUNCTION decode_OPM_territory ( p_territory_code varchar2,
                                 p_business_group_id number ) RETURN VARCHAR2;

FUNCTION decode_currency_code ( p_currency_code varchar2 ) RETURN VARCHAR2;

FUNCTION decode_event_group   ( p_event_group_id varchar2 ) RETURN VARCHAR2;

FUNCTION decode_element_type ( p_element_type_id varchar2,
                               p_effective_date  date ) RETURN VARCHAR2;

FUNCTION get_bank_details ( p_external_account_id in number ) RETURN VARCHAR2;

FUNCTION get_element_link_status ( p_status  varchar2,
                                   p_link_start_date  date,
                                   p_link_end_date    date,
                                   p_effective_start_date date,
                                   p_effective_end_date   date,
                                   p_effective_date   date
                                  ) RETURN VARCHAR2;

FUNCTION flex_concatenated (app_short_name in varchar2,
                                      flex_name      in varchar2,
                                      flex_context_or_struct   in varchar2,
                                      column_name    in varchar2,
                                      no_of_columns  in varchar2 default null,
                                      flex_type      in varchar2, -- 'DESCRIPTIVE' or 'KEY'
                                      v1  in varchar2 default null,
                                      v2  in varchar2 default null,
                                      v3  in varchar2 default null,
                                      v4  in varchar2 default null,
                                      v5  in varchar2 default null,
                                      v6  in varchar2 default null,
                                      v7  in varchar2 default null,
                                      v8  in varchar2 default null,
                                      v9  in varchar2 default null,
                                      v10 in varchar2 default null,
                                      v11 in varchar2 default null,
                                      v12 in varchar2 default null,
                                      v13 in varchar2 default null,
                                      v14 in varchar2 default null,
                                      v15 in varchar2 default null,
                                      v16 in varchar2 default null,
                                      v17 in varchar2 default null,
                                      v18 in varchar2 default null,
                                      v19 in varchar2 default null,
                                      v20 in varchar2 default null,
                                      v21 in varchar2 default null,
                                      v22 in varchar2 default null,
                                      v23 in varchar2 default null,
                                      v24 in varchar2 default null,
                                      v25 in varchar2 default null,
                                      v26 in varchar2 default null,
                                      v27 in varchar2 default null,
                                      v28 in varchar2 default null,
                                      v29 in varchar2 default null,
                                      v30 in varchar2 default null
                                      ) return varchar2;
--
--
FUNCTION get_prev_salary(p_assignment_id NUMBER,
                         p_start_date    DATE,
			 p_end_date      DATE,
			 p_sal_type      VARCHAR2)  RETURN NUMBER ;
--
--
FUNCTION get_prev_sal_change_date(p_assignment_id NUMBER,
	       		          p_end_date      DATE)  RETURN DATE ;
--
--
FUNCTION get_multiple_sal_change_flag(p_assignment_id NUMBER,
                                      p_start_date    DATE,
                                      p_end_date      DATE) RETURN VARCHAR2 ;

--
--
FUNCTION get_input_name(p_element_entry_id   number,
                        p_sequence           number,
                        p_inputname_or_value varchar2,
                        p_start_date         date,
                        p_end_date           date,
                        p_ele_start_date     date,
                        p_ele_end_date       date) return varchar2;
--
--
FUNCTION check_assignment_in_set(p_assignmentset_name VARCHAR2,
                                 p_assignment_id      NUMBER,
                                 p_business_group_id  NUMBER,
                                 p_payroll_id         NUMBER)
                  RETURN VARCHAR2;
--
--
FUNCTION check_balance_exists(p_defined_balance_id NUMBER,
                              p_business_group_id  NUMBER,
                              p_attribute_name     VARCHAR2)
                 RETURN VARCHAR2 ;
--
--
FUNCTION get_bal_valid_load_date(p_attribute_name       varchar2,
                                 p_balance_name         varchar2,
                                 p_business_group_id    number,
                                 p_database_item_suffix varchar2,
                                 p_defined_balance_id   number DEFAULT NULL)
                 RETURN DATE ;
--
--
g_post_r11i VARCHAR2(1);
--
--
FUNCTION chk_post_r11i RETURN VARCHAR2;
--
--
FUNCTION get_element_name(p_element_entry_id number,
                          p_retro_run_date   date,
                          p_payroll_run_date date)
         RETURN VARCHAR2 ;
--
--
END PAY_ADHOC_UTILS_PKG;

 

/
