--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BKG" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< interview2_apl_asg_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure interview2_apl_asg_b
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in     number
  ,p_assignment_status_type_id    in     number
  ,p_change_reason                in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< interview2_apl_asg_a >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure interview2_apl_asg_a
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in     number
  ,p_assignment_status_type_id    in     number
  ,p_change_reason                in     varchar2
  ,p_effective_start_date         in     date
  ,p_effective_end_date           in     date
  );
end hr_assignment_bkg;

/
