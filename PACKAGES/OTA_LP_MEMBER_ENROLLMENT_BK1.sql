--------------------------------------------------------
--  DDL for Package OTA_LP_MEMBER_ENROLLMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_MEMBER_ENROLLMENT_BK1" AUTHID CURRENT_USER as
/* $Header: otlmeapi.pkh 120.1.12010000.3 2009/05/27 13:15:43 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_lp_member_enrollment_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_lp_member_enrollment_b
  (  p_effective_date               in date,
  p_validate                     in boolean,
  p_lp_enrollment_id             in number,
  p_business_group_id            in number,
  p_learning_path_section_id     in number,
  p_learning_path_member_id      in number,
  p_member_status_code                in varchar2,
  p_completion_target_date       in date,
  p_completion_date               in date,
  p_attribute_category           in varchar2 ,
  p_attribute1                   in varchar2 ,
  p_attribute2                   in varchar2 ,
  p_attribute3                   in varchar2 ,
  p_attribute4                   in varchar2 ,
  p_attribute5                   in varchar2 ,
  p_attribute6                   in varchar2 ,
  p_attribute7                   in varchar2 ,
  p_attribute8                   in varchar2 ,
  p_attribute9                   in varchar2 ,
  p_attribute10                  in varchar2 ,
  p_attribute11                  in varchar2 ,
  p_attribute12                  in varchar2 ,
  p_attribute13                  in varchar2 ,
  p_attribute14                  in varchar2 ,
  p_attribute15                  in varchar2 ,
  p_attribute16                  in varchar2 ,
  p_attribute17                  in varchar2 ,
  p_attribute18                  in varchar2 ,
  p_attribute19                  in varchar2 ,
  p_attribute20                  in varchar2 ,
  p_attribute21                  in varchar2 ,
  p_attribute22                  in varchar2 ,
  p_attribute23                  in varchar2 ,
  p_attribute24                  in varchar2 ,
  p_attribute25                  in varchar2 ,
  p_attribute26                  in varchar2 ,
  p_attribute27                  in varchar2 ,
  p_attribute28                  in varchar2 ,
  p_attribute29                  in varchar2 ,
  p_attribute30                  in varchar2,
  p_creator_person_id            in number  ,
  p_event_id                     in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_lp_member_enrollment_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_lp_member_enrollment_a
  (p_effective_date               in date,
  p_validate                     in boolean,
  p_lp_enrollment_id             in number,
  p_business_group_id            in number,
  p_learning_path_section_id     in number,
  p_learning_path_member_id      in number,
  p_member_status_code                in varchar2,
  p_completion_target_date       in date,
  p_completion_date               in date,
  p_attribute_category           in varchar2 ,
  p_attribute1                   in varchar2 ,
  p_attribute2                   in varchar2 ,
  p_attribute3                   in varchar2 ,
  p_attribute4                   in varchar2 ,
  p_attribute5                   in varchar2 ,
  p_attribute6                   in varchar2 ,
  p_attribute7                   in varchar2 ,
  p_attribute8                   in varchar2 ,
  p_attribute9                   in varchar2 ,
  p_attribute10                  in varchar2 ,
  p_attribute11                  in varchar2 ,
  p_attribute12                  in varchar2 ,
  p_attribute13                  in varchar2 ,
  p_attribute14                  in varchar2 ,
  p_attribute15                  in varchar2 ,
  p_attribute16                  in varchar2 ,
  p_attribute17                  in varchar2 ,
  p_attribute18                  in varchar2 ,
  p_attribute19                  in varchar2 ,
  p_attribute20                  in varchar2 ,
  p_attribute21                  in varchar2 ,
  p_attribute22                  in varchar2 ,
  p_attribute23                  in varchar2 ,
  p_attribute24                  in varchar2 ,
  p_attribute25                  in varchar2 ,
  p_attribute26                  in varchar2 ,
  p_attribute27                  in varchar2 ,
  p_attribute28                  in varchar2 ,
  p_attribute29                  in varchar2 ,
  p_attribute30                  in varchar2 ,
  p_creator_person_id            in number   ,
  p_event_id                     in number
  );

end ota_lp_member_enrollment_bk1 ;

/
