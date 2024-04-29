--------------------------------------------------------
--  DDL for Package OTA_LP_MEMBER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_MEMBER_BK1" AUTHID CURRENT_USER as
/* $Header: otlpmapi.pkh 120.1 2005/10/02 02:07:38 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_learning_path_member_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_learning_path_member_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_learning_path_id              in     number
  ,p_activity_version_id           in     number
  ,p_course_sequence               in     number
  ,p_duration                      in     number
  ,p_duration_units                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_learning_path_section_id      in     number
  ,p_notify_days_before_target     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_learning_path_member_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_learning_path_member_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_learning_path_id              in     number
  ,p_activity_version_id           in     number
  ,p_course_sequence               in     number
  ,p_duration                      in     number
  ,p_duration_units                in     varchar2
  ,p_learning_path_member_id       in     number
  ,p_object_version_number         in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_learning_path_section_id      in     number
  ,p_notify_days_before_target     in     number
  );
end ota_lp_member_bk1;

 

/
