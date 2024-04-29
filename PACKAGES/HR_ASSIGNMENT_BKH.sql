--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BKH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BKH" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< final_process_cwk_asg_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_cwk_asg_b
  (p_assignment_id                 in     number
  ,p_object_version_number         in     number
  ,p_final_process_date            in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< final_process_cwk_asg_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_cwk_asg_a
  (p_assignment_id                 in     number
  ,p_object_version_number         in     number
  ,p_final_process_date            in     date
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_org_now_no_manager_warning    in     boolean
  ,p_asg_future_changes_warning    in     boolean
  ,p_entries_changed_warning       in     varchar2
  );
end hr_assignment_bkh;

/
