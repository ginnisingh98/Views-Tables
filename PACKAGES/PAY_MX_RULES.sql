--------------------------------------------------------
--  DDL for Package PAY_MX_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_RULES" AUTHID CURRENT_USER AS
/* $Header: pymxrule.pkh 120.3.12000000.1 2007/01/17 22:49:40 appldev noship $*/

   PROCEDURE get_main_tax_unit_id(p_assignment_id   in     number,
                                  p_effective_date  in     date,
                                  p_tax_unit_id  in out nocopy number);

   PROCEDURE get_default_jurisdiction( p_asg_act_id   IN            NUMBER
                                      ,p_ee_id        IN            NUMBER
                                      ,p_jurisdiction IN OUT NOCOPY VARCHAR2);

   FUNCTION  element_template_pre_process( p_rec in PAY_ELE_TMPLT_OBJ )
   RETURN PAY_ELE_TMPLT_OBJ;

   PROCEDURE element_template_post_process( p_element_template_id   in NUMBER );


   PROCEDURE add_custom_xml
       (p_assignment_action_id number,
        p_action_information_category varchar2,
        p_document_type varchar2);

  /****************************************************************************
    Name        : STRIP_SPL_CHARS
    Description : This function converts special characters into equivalent
                  ASCII characters.
  *****************************************************************************/
  FUNCTION STRIP_SPL_CHARS ( P_IN_STRING  IN  VARCHAR2)
  RETURN VARCHAR2;

END pay_mx_rules;


 

/
