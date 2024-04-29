--------------------------------------------------------
--  DDL for Package PY_FR_ADDITIONAL_ELEMENT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_FR_ADDITIONAL_ELEMENT_RULES" AUTHID CURRENT_USER AS
/* $Header: pyfreliv.pkh 120.0 2005/05/29 05:02:15 appldev noship $ */
       FUNCTION create_input_value
                (p_element_name              	IN varchar2
                ,p_input_value_name          	IN varchar2
                ,p_uom_code                  	IN varchar2
                ,p_bg_name                   	IN varchar2
                ,p_element_type_id           	IN number
                ,p_primary_classification_id 	IN number
                ,p_business_group_id         	IN number
                ,p_legislation_code          	IN varchar2
                ,p_classification_type       	IN varchar2
                ,p_sequence                  	IN number
                ,p_base_name                    IN varchar2 default null)
        RETURN number;

        PROCEDURE create_extra_elements
                (p_effective_date 		IN date
                ,p_accrual_plan_id	        IN number
                ,p_accrual_plan_name            IN varchar2
                ,p_accrual_plan_element_type_id IN number
                ,p_business_group_id            IN number
                ,p_pto_input_value_id           IN number
                ,p_accrual_category             IN varchar2);

END py_fr_additional_element_rules;

 

/
