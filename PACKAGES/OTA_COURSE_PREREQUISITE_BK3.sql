--------------------------------------------------------
--  DDL for Package OTA_COURSE_PREREQUISITE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COURSE_PREREQUISITE_BK3" AUTHID CURRENT_USER as
/* $Header: otcprapi.pkh 120.1 2006/07/12 10:59:32 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_course_prerequisite_b >---------------------|
-- ----------------------------------------------------------------------------
procedure delete_course_prerequisite_b
  (p_activity_version_id                in number
  ,p_prerequisite_course_id             in number
  ,p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_course_prerequisite_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_course_prerequisite_a
  (p_activity_version_id                in number
  ,p_prerequisite_course_id             in number
  ,p_object_version_number              in number
  );
--
end ota_course_prerequisite_bk3;

 

/
