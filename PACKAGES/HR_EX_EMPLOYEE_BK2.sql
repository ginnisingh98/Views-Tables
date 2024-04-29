--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_BK2" AUTHID CURRENT_USER as
/* $Header: peexeapi.pkh 120.4.12010000.2 2009/04/30 10:46:10 dparthas ship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< final_process_emp_b >-------------------------|
-- ---------------------------------------------------------------------
--
procedure final_process_emp_b
  (p_period_of_service_id          in     number
  ,p_object_version_number         in     number
  ,p_final_process_date            in     date
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< final_process_emp_a >-------------------------|
-- ----------------------------------------------------------------------
--
procedure final_process_emp_a
  (p_period_of_service_id          in   number
  ,p_object_version_number         in   number
  ,p_final_process_date            in   date
  ,p_org_now_no_manager_warning    in   boolean
  ,p_asg_future_changes_warning    in   boolean
  ,p_entries_changed_warning       in   varchar2
  );
end hr_ex_employee_bk2;

/
