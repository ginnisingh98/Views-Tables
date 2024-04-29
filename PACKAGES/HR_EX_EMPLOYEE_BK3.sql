--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_BK3" AUTHID CURRENT_USER as
/* $Header: peexeapi.pkh 120.4.12010000.2 2009/04/30 10:46:10 dparthas ship $ */
--
-- ----------------------------------------------------------------------
-- |----------------< update_term_details_emp_b >-----------------------|
-- ----------------------------------------------------------------------
--
procedure update_term_details_emp_b
  (p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in     number
  ,p_termination_accepted_person   in     number
  ,p_accepted_termination_date     in     date
  ,p_comments                      in     varchar2
  ,p_leaving_reason                in     varchar2
  ,p_notified_termination_date     in     date
  ,p_projected_termination_date    in     date
  );
--
-- ----------------------------------------------------------------------
-- |----------------< update_term_details_emp_a >-----------------------|
-- ----------------------------------------------------------------------
--
procedure update_term_details_emp_a
  (p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in     number
  ,p_termination_accepted_person   in     number
  ,p_accepted_termination_date     in     date
  ,p_comments                      in     varchar2
  ,p_leaving_reason                in     varchar2
  ,p_notified_termination_date     in     date
  ,p_projected_termination_date    in     date
  );
end hr_ex_employee_bk3;

/
