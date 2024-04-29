--------------------------------------------------------
--  DDL for Package OTA_COURSE_PREREQUISITE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COURSE_PREREQUISITE_BK1" AUTHID CURRENT_USER as
/* $Header: otcprapi.pkh 120.1 2006/07/12 10:59:32 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_course_prerequisite_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure create_course_prerequisite_b
  (p_effective_date                 in     date
  ,p_activity_version_id            in     number
  ,p_prerequisite_course_id         in     number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------< create_course_prerequisite_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_course_prerequisite_a
  (p_effective_date                 in     date
  ,p_activity_version_id            in     number
  ,p_prerequisite_course_id         in     number
  ,p_business_group_id              in     number
  ,p_prerequisite_type              in     varchar2
  ,p_enforcement_mode               in     varchar2
  ,p_object_version_number          in     number
  );

end ota_course_prerequisite_bk1 ;

 

/
