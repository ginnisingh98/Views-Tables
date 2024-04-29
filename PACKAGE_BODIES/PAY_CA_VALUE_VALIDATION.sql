--------------------------------------------------------
--  DDL for Package Body PAY_CA_VALUE_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_VALUE_VALIDATION" AS
/* $Header: pycavvfn.pkb 120.0 2005/05/29 03:53:53 appldev noship $ */
-----------------------------------------------------------------------
-- FUNCTION VALIDATE_WCB_ACCOUNT_NUMBER
-----------------------------------------------------------------------
FUNCTION validate_wcb_account_number(p_business_group_id in number
                                    ,p_account_number    in varchar2)
RETURN VARCHAR2 IS
--
l_valid_value	varchar2(1);
--
-- Cursor to validate WCB Account Number
--
CURSOR validate_wcb_account_number(p_bus_group_id number
                                  ,p_act_number varchar2) IS
SELECT 'S'
from   pay_wci_accounts
where  account_number = p_act_number
and    business_group_id = p_bus_group_id;
--
BEGIN
hr_utility.set_location('validate_wcb_account_number', 10);
--
OPEN  validate_wcb_account_number(p_business_group_id, p_account_number);
FETCH validate_wcb_account_number INTO l_valid_value;
  IF  validate_wcb_account_number%NOTFOUND THEN
    hr_utility.set_location('validate_wcb_account_number', 20);
    l_valid_value := 'E';
  END IF;
CLOSE validate_wcb_account_number;
--
RETURN l_valid_value;
--
END validate_wcb_account_number;
-----------------------------------------------------------------------
-- FUNCTION VALIDATE_WCB_RATE_CODE
-----------------------------------------------------------------------
FUNCTION validate_wcb_rate_code(p_business_group_id in number
                               ,p_rate_code      in varchar2)
RETURN VARCHAR2 is
--
l_valid_value   varchar2(1);
--
-- Cursor to validate WCB Rate Code
--
CURSOR validate_wcb_rate_code(p_bus_group_id number
                                  ,p_code varchar2) IS
SELECT 'S'
from   pay_wci_rates
where  code = p_code
and    business_group_id = p_bus_group_id;
--
BEGIN
hr_utility.set_location('validate_wcb_rate_code', 10);
--
OPEN  validate_wcb_rate_code(p_business_group_id, p_rate_code);
FETCH validate_wcb_rate_code INTO l_valid_value;
  IF  validate_wcb_rate_code%NOTFOUND THEN
    hr_utility.set_location('validate_wcb_rate_code', 20);
    l_valid_value := 'E';
  END IF;
CLOSE validate_wcb_rate_code;
--
RETURN l_valid_value;
--
END validate_wcb_rate_code;
----------------------------------------------------------------------
-- FUNCTION VALIDATE_PMED_ACCOUNT_NUMBER
----------------------------------------------------------------------
FUNCTION validate_pmed_account_number(p_business_group_id in number
                                     ,p_account_number    in varchar2)
RETURN VARCHAR2 IS
--
l_valid_value   varchar2(1);
--
-- Cursor to validate PMED Account Number
--
CURSOR validate_pmed_account_number(p_bus_group_id number
                                   ,p_act_number varchar2) IS
SELECT 'S'
from   pay_ca_pmed_accounts
where  account_number = p_act_number
and    business_group_id = p_bus_group_id;
--
BEGIN
hr_utility.set_location('validate_pmed_account_number', 10);
--
OPEN  validate_pmed_account_number(p_business_group_id, p_account_number);
FETCH validate_pmed_account_number INTO l_valid_value;
  IF  validate_pmed_account_number%NOTFOUND THEN
    hr_utility.set_location('validate_pmed_account_number', 20);
    l_valid_value := 'E';
  END IF;
CLOSE validate_pmed_account_number;
--
RETURN l_valid_value;
--
END validate_pmed_account_number;
--------------------------------------------------------------------
-- FUNCTION VALIDATE_USER_TABLE_NAME
--------------------------------------------------------------------
FUNCTION validate_user_table_name(p_business_group_id in number
                                 ,p_user_table_name   in varchar2)
RETURN VARCHAR2 IS
--
l_valid_value   varchar2(1); -- return variable
--
-- Cursor to validate user table name
--
CURSOR validate_user_table_name(p_bus_group_id number
                               ,p_user_tab_name varchar2) IS
SELECT 'S'
from pay_user_tables put
where put.user_table_name = p_user_tab_name
and (
      (put.business_group_id = p_bus_group_id
       and put.legislation_code is null
      )
     or
      (put.business_group_id is null
       and put.legislation_code ='CA'
      )
    );
--
BEGIN
hr_utility.set_location('validate_user_table_name', 10);
--
OPEN  validate_user_table_name(p_business_group_id, p_user_table_name);
FETCH validate_user_table_name INTO l_valid_value;
  IF  validate_user_table_name%NOTFOUND THEN
    hr_utility.set_location('validate_user_table_name',20);
    l_valid_value := 'E';
  END IF;
CLOSE validate_user_table_name;
--
RETURN l_valid_value;
--
END validate_user_table_name;
--------------------------------------------------------------------
-- VALIDATE_USER_TABLE_COLUMN
--------------------------------------------------------------------
FUNCTION validate_user_table_column(p_business_group_id in number
                                   ,p_user_table_column in varchar2)
RETURN VARCHAR2 IS
--
l_valid_value   varchar2(1);
--
-- Cursor to validate user table column
--
CURSOR validate_user_table_column(p_bus_group_id number
                                 ,p_user_tab_col varchar2) IS
SELECT 'S'
from pay_user_columns puc
where puc.user_column_name = p_user_tab_col
and (
      (puc.business_group_id = p_bus_group_id
       and puc.legislation_code is null
      )
     or
      (puc.business_group_id is null
       and puc.legislation_code ='CA'
      )
    );
--
BEGIN
hr_utility.set_location('validate_user_table_column', 10);
--
OPEN  validate_user_table_column(p_business_group_id, p_user_table_column);
FETCH validate_user_table_column INTO l_valid_value;
  IF  validate_user_table_column%NOTFOUND THEN
    hr_utility.set_location('validate_user_table_column', 20);
    l_valid_value := 'E';
  END IF;
CLOSE validate_user_table_column;
--
RETURN l_valid_value;
--
END validate_user_table_column;
--------------------------------------------------------------------
END pay_ca_value_validation;

/
