--------------------------------------------------------
--  DDL for Package OTA_FORUM_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_BK1" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_forum_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_forum_b
  ( p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date
  ,p_end_date_active              in  date
  ,p_message_type_flag            in  varchar2
  ,p_allow_html_flag              in  varchar2
  ,p_allow_attachment_flag        in  varchar2
  ,p_auto_notification_flag       in  varchar2
  ,p_public_flag                  in  varchar2
  ,p_object_version_number        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_forum_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_forum_a
  ( p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date
  ,p_end_date_active              in  date
  ,p_message_type_flag            in  varchar2
  ,p_allow_html_flag              in  varchar2
  ,p_allow_attachment_flag        in  varchar2
  ,p_auto_notification_flag       in  varchar2
  ,p_public_flag                  in  varchar2
  ,p_forum_id                     in  number
  ,p_object_version_number        in  number
  );

end ota_forum_bk1 ;

 

/
