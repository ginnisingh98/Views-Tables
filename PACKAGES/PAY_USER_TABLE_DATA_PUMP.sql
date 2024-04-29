--------------------------------------------------------
--  DDL for Package PAY_USER_TABLE_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLE_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pyputdpm.pkh 115.0 2003/10/29 20:50 scchakra noship $ */
--
------------------------------ get_user_table_id ------------------------------
--
function get_user_table_id
  (p_user_table_user_key in varchar2)
return number;
--
------------------------------ get_user_table_ovn -----------------------------
--
Function get_user_table_ovn
  (p_user_table_user_key  in varchar2)
return number;
--
------------------------------ get_user_column_id -----------------------------
--
function get_user_column_id
  (p_user_column_user_key  in varchar2)
return number;
--
-------------------------------- get_formula_id -------------------------------
--
function get_formula_id
   (p_formula_name      in varchar2,
    p_business_group_id in  number
   )
return number;
--
------------------------------ get_user_column_ovn ----------------------------
--
Function get_user_column_ovn
  (p_user_column_user_key  in varchar2
  )
return number;
--
----------------------------- get_user_row_id ---------------------------------
--
function get_user_row_id
  (p_user_row_user_key in varchar2)
return number;
--
------------------------------- get_user_row_ovn ------------------------------
--
Function get_user_row_ovn
  (p_user_row_user_key  in varchar2
  ,p_effective_date     in date
  )
return number;
--
------------------------- get_user_column_instance_id -------------------------
--
function get_user_column_instance_id
  (p_user_column_user_key  in varchar2
  ,p_business_group_id in number
  ,p_user_row_user_key in varchar2
  ,p_effective_date    in date
  )
return number;
--
------------------------ get_user_column_instance_ovn -------------------------
--
function get_user_column_instance_ovn
  (p_user_column_user_key  in varchar2
  ,p_business_group_id in number
  ,p_user_row_user_key in varchar2
  ,p_effective_date    in date
  )
return number;
--
END pay_user_table_data_pump;

 

/
