--------------------------------------------------------
--  DDL for Package PAY_US_VERTEX_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_VERTEX_INTERFACE" AUTHID CURRENT_USER as
/* $Header: payusvertexetusg.pkh 120.0.12000000.1 2007/01/17 14:56:07 appldev noship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        :
    Filename	: payusvertexetusg.pkh
    Description : This Package contains Procedures and Funbction required for
                  managing lement_type_usages for VERTEX and US_TAX_VERTEX
                  elements
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    12-DEC-2004 ppanda          115.0           Initial Version
    02-FEB-2005 ppanda          115.1   4155064 Modified various procedure and
                                                function to support Business
                                                Group


*/
-- This procedure makes entry into pay_element_types_usages_f
-- depending on the Run_Type and Element details passed to it.
  PROCEDURE create_ele_tp_usg ( p_element_type_id      in number
                               ,p_run_type_id          in number
                               ,p_element_name         in varchar2
                               ,p_run_type_name        in varchar2
                               ,p_inclusion_flag       in varchar2
                               ,p_effective_date       in date
                               ,p_legislation_code     in varchar2
                               ,p_business_group_id    in number
                              );
--
-- This procedure removes entries from the pay_element_type_usages_f
-- for an element and run types  used for processing vertex elements
--
  PROCEDURE delete_ele_type_usages (p_element_name      in varchar2,
                                    p_business_group_id in number);
--
-- This function determines whether Payroll Run exist for the given
-- Business group or Not.
--
  FUNCTION payroll_run_exist (p_business_group_id in number
                             )Return varchar2;
-- This function used to determine the current Tax Interface used to Calculate
-- the TAX
  FUNCTION Current_Tax_Interface (p_lookup_code       in varchar2,
                                  p_business_group_id in number)
           Return varchar2;

-- This function determines whether element_type is excluded for processing
-- in Payroll or Not
-- If this function returns 'Y' it means input element is excluded
-- ELSIF the return value is 'N', Element is included in Payroll process
--
  FUNCTION vertex_eletype_usage_exist (p_element_name      varchar2,
                                       p_business_group_id number)
           Return varchar2;


-- This procedure Excudes the TAX Element from processing depending on
-- customer selection
-- IF Customer selection is  STANDARD interface
--       New Tax Element US_TAX_VERTEX will be excluded
-- ELSIF Customer selection is ENHANCED interface
--       Old Tax Element VERTEX will be excluded
  PROCEDURE select_tax_interface(errbuf              OUT nocopy VARCHAR2,
                                 retcode             OUT nocopy NUMBER,
                                 p_business_group_id IN         NUMBER,
                                 p_vertex_interface  IN         VARCHAR2);


END pay_us_vertex_interface;

 

/
