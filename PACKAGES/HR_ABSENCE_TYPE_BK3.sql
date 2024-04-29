--------------------------------------------------------
--  DDL for Package HR_ABSENCE_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ABSENCE_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: peabbapi.pkh 120.4.12010000.1 2008/07/28 03:59:56 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_absence_type_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_absence_type_b
  (p_absence_attendance_type_id    in  number
  ,p_object_version_number         in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_absence_type_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_absence_type_a
  (p_absence_attendance_type_id    in  number
  ,p_object_version_number         in  number
  );
--
end hr_absence_type_bk3;

/
