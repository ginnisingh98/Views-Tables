--------------------------------------------------------
--  DDL for Package PAY_CA_VALUE_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_VALUE_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: pycavvfn.pkh 120.0 2005/05/29 03:54:01 appldev noship $ */


FUNCTION validate_wcb_account_number(p_business_group_id in number
                                    ,p_account_number    in varchar2)
RETURN VARCHAR2;
--
FUNCTION validate_wcb_rate_code(p_business_group_id in number
                               ,p_rate_code      in varchar2)
RETURN VARCHAR2;
--
FUNCTION validate_pmed_account_number(p_business_group_id in number
                                     ,p_account_number    in varchar2)
RETURN VARCHAR2;
--
FUNCTION validate_user_table_name(p_business_group_id in number
                                 ,p_user_table_name   in varchar2)
RETURN VARCHAR2;
--
FUNCTION validate_user_table_column(p_business_group_id in number
                                   ,p_user_table_column in varchar2)
RETURN VARCHAR2;
--
END pay_ca_value_validation;

 

/
