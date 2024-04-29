--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_BK4" AUTHID CURRENT_USER as
/* $Header: peexeapi.pkh 120.4.12010000.2 2009/04/30 10:46:10 dparthas ship $ */
--
-- ----------------------------------------------------------------------
-- |----------------< reverse_terminate_employee_b >-----------------------|
-- ----------------------------------------------------------------------
--
procedure reverse_terminate_employee_b
  (  p_person_id               in number
    ,p_actual_termination_date in date
    ,p_clear_details           in varchar2
  );
--
-- ----------------------------------------------------------------------
-- |----------------< reverse_terminate_employee_a >-----------------------|
-- ----------------------------------------------------------------------
--
procedure reverse_terminate_employee_a
  (  p_person_id               in number
    ,p_actual_termination_date in date
    ,p_clear_details           in varchar2
  );
end hr_ex_employee_bk4;

/
