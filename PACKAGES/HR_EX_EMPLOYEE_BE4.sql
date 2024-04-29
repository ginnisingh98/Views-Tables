--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_BE4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_BE4" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:16
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure reverse_terminate_employee_a (
p_person_id                    number,
p_actual_termination_date      date,
p_clear_details                varchar2);
end hr_ex_employee_be4;

/
