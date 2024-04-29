--------------------------------------------------------
--  DDL for Package OTA_CHAT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_BK2" as
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_CHAT_B >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_chat_b
  (
  p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date
  ,p_end_date_active              in  date
  ,p_start_time_active            in  varchar2
  ,p_end_time_active              in  VARCHAR2
  ,p_timezone_code                IN  VARCHAR2
  ,p_public_flag                  in  varchar2
  ,p_chat_id                      in  number
  ,p_object_version_number        in  number);
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_CHAT_A >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_chat_a
  (
   p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date
  ,p_end_date_active              in  date
  ,p_start_time_active            in  varchar2
  ,p_end_time_active              in  VARCHAR2
  ,p_timezone_code                IN  VARCHAR2
  ,p_public_flag                  in  varchar2
  ,p_chat_id                      in  number
  ,p_object_version_number        in number);
--

end ota_chat_bk2;
--

 

/
