--------------------------------------------------------
--  DDL for Package HR_NL_ABSENCE_ACTION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ABSENCE_ACTION_BK2" AUTHID CURRENT_USER as
/* $Header: penaaapi.pkh 120.1 2005/10/02 02:18:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_absence_action_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_absence_action_b
  (p_absence_attendance_id         in     number
  ,p_absence_action_id             in     number
  ,p_expected_date                 in     date
  ,p_description                   in     varchar2
  ,p_actual_start_date             in     date
  ,p_actual_end_date               in     date
  ,p_holder                        in     varchar2
  ,p_comments                      in     varchar2
  ,p_document_file_name            in     varchar2
  ,p_object_version_number         in     number
  ,p_enabled                       in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_absence_action_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_absence_action_a
  (p_absence_attendance_id         in     number
  ,p_absence_action_id             in     number
  ,p_expected_date                 in     date
  ,p_description                   in     varchar2
  ,p_actual_start_date             in     date
  ,p_actual_end_date               in     date
  ,p_holder                        in     varchar2
  ,p_comments                      in     varchar2
  ,p_document_file_name            in     varchar2
  ,p_object_version_number         in     number
  ,p_enabled                       in     varchar2
  );
--
end HR_NL_ABSENCE_ACTION_bk2;

 

/
