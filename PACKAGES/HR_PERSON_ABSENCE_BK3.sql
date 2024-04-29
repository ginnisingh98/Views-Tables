--------------------------------------------------------
--  DDL for Package HR_PERSON_ABSENCE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ABSENCE_BK3" AUTHID CURRENT_USER as
/* $Header: peabsapi.pkh 120.4.12010000.13 2009/10/09 07:46:59 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_absence_b
  (p_absence_attendance_id         in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_absence_a
  (p_absence_attendance_id         in     number
  ,p_object_version_number         in     number
  ,p_person_id                     in     number
  );
--
end hr_person_absence_bk3;

/
