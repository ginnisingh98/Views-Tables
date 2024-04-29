--------------------------------------------------------
--  DDL for Package OTA_LEARNING_PATH_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LEARNING_PATH_BK1" AUTHID CURRENT_USER as
/* $Header: otlpsapi.pkh 120.3 2005/11/07 03:26:28 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_learning_path_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_learning_path_b
  (  p_effective_date               in date,
  p_validate                     in boolean,
  p_path_name                    in varchar2,
  p_business_group_id            in number,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_start_date_active            in date,
  p_end_date_active              in date,
  p_description                  in varchar2,
  p_objectives                   in varchar2,
  p_keywords                     in varchar2,
  p_purpose                      in varchar2,
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
  p_path_source_code             in varchar2 ,
  p_source_function_code         in varchar2 ,
  p_assignment_id                in number   ,
  p_source_id                    in number   ,
  p_notify_days_before_target    in number   ,
  p_person_id                    in number   ,
  p_contact_id                   in number   ,
  p_display_to_learner_flag      in varchar2 ,
  p_public_flag                  in varchar2
  ,p_competency_update_level        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_learning_path_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_learning_path_a
  (p_effective_date               in date,
  p_validate                     in boolean,
  p_path_name                    in varchar2,
  p_business_group_id            in number,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_start_date_active            in date,
  p_end_date_active              in date,
  p_description                  in varchar2,
  p_objectives                   in varchar2,
  p_keywords                     in varchar2,
  p_purpose                      in varchar2,
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
  p_path_source_code             in varchar2 ,
  p_source_function_code         in varchar2 ,
  p_assignment_id                in number   ,
  p_source_id                    in number   ,
  p_notify_days_before_target    in number   ,
  p_person_id                    in number   ,
  p_contact_id                   in number   ,
  p_display_to_learner_flag      in varchar2 ,
  p_public_flag                  in varchar2
  ,p_competency_update_level        in     varchar2
  );

end ota_learning_path_bk1 ;

 

/
