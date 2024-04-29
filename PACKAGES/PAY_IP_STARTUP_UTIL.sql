--------------------------------------------------------
--  DDL for Package PAY_IP_STARTUP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IP_STARTUP_UTIL" AUTHID CURRENT_USER as
 /* $Header: pyintstu.pkh 115.8 2002/11/26 14:22:53 jahobbs noship $ */


PROCEDURE insert_ownership(p_key_name 	IN VARCHAR2,
                           p_product_name 	IN VARCHAR2,
               		   p_key_value 	IN VARCHAR2);

FUNCTION check_to_install (p_legislation_code       VARCHAR2) RETURN BOOLEAN;

--PROCEDURE clear_shadow_tables;

PROCEDURE move_to_shadow_tables
		(p_legislation_code IN VARCHAR2,
		 p_install_tax_unit IN VARCHAR2);

FUNCTION create_key_flexfield
		 (p_appl_Short_Name		IN VARCHAR2,
		 p_flex_code			IN VARCHAR2,
                 p_structure_code		IN VARCHAR2,
                 p_structure_title		IN VARCHAR2,
                 p_description			IN VARCHAR2,
                 p_view_name			IN VARCHAR2,
                 p_freeze_flag			IN VARCHAR2,
                 p_enabled_flag			IN VARCHAR2,
                 p_cross_val_flag		IN VARCHAR2,
                 p_freeze_rollup_flag		IN VARCHAR2,
                 p_dynamic_insert_flag		IN VARCHAR2,
                 p_shorthand_enabled_flag	IN VARCHAR2,
                 p_shorthand_prompt		IN VARCHAR2,
                 p_shorthand_length		IN NUMBER) RETURN NUMBER;


PROCEDURE create_leg_rule
		 (p_legislation_code	IN VARCHAR2,
		  p_Rule_Type		IN VARCHAR2,
		  p_Rule_mode		IN VARCHAR2);



PROCEDURE update_shadow_tables
		(p_legislation_code	IN VARCHAR2,
		 p_currency_code	IN VARCHAR2);

PROCEDURE insert_history_table
		(p_legislation_code	IN VARCHAR2);

PROCEDURE move_to_main_tables;

PROCEDURE update_ele_class_tl
		(p_legislation_code	IN VARCHAR2);

PROCEDURE update_bal_type_tl
		(p_legislation_code	IN VARCHAR2);

PROCEDURE create_runtype
		(p_legislation_code	IN VARCHAR2);

PROCEDURE update_run_type_tl
        	(p_legislation_code	IN VARCHAR2);

PROCEDURE setup (p_errbuf			OUT NOCOPY VARCHAR2,
		 p_retcode			OUT NOCOPY NUMBER,
		 p_legislation_code		IN VARCHAR2,
		 p_currency_code		IN VARCHAR2,
		 p_Tax_Year			IN VARCHAR2,
		 p_install_tax_unit		IN VARCHAR2,
                 p_action_parameter_group_id 	IN NUMBER);

end pay_ip_startup_util;


 

/
