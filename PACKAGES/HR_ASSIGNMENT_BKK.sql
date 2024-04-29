--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BKK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BKK" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_cwk_asg_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_cwk_asg_b
  (p_assignment_id                 in     number
  ,p_object_version_number         in     number
  ,p_actual_termination_date       in     date
  ,p_assignment_status_type_id     in     number
  ,p_business_group_id             in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_cwk_asg_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_cwk_asg_a
  (p_assignment_id                 in     number
  ,p_object_version_number         in     number
  ,p_actual_termination_date       in     date
  ,p_assignment_status_type_id     in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_asg_future_changes_warning    in     boolean
  ,p_entries_changed_warning       in     varchar2
  ,p_pay_proposal_warning          in     boolean
  ,p_business_group_id             in     number
  );
end hr_assignment_bkk;

/
