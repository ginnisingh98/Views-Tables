--------------------------------------------------------
--  DDL for Package OTA_CHAT_USER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_USER_BK1" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_chat_user_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_chat_user_b
  (p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_login_date                     in  date
  ,p_business_group_id            in  number
  ,p_object_version_number        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_chat_user_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_chat_user_a
  (p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_login_date                     in  date
  ,p_business_group_id            in  number
  ,p_object_version_number        in  number
  );

end ota_chat_user_bk1 ;

 

/
