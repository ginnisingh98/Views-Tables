--------------------------------------------------------
--  DDL for Package OTA_OPEN_FC_ENROLLMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OPEN_FC_ENROLLMENT_BK2" as
-- ----------------------------------------------------------------------------
-- |----------------< update_open_fc_enrollment_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_open_fc_enrollment_b
  (  p_effective_date               in     date
    ,p_enrollment_id                in     number
    ,p_business_group_id            in     number
    ,p_forum_id                     in     number
    ,p_person_id                    in     number
    ,p_contact_id                   in     number
    ,p_chat_id                      in     number
    ,p_object_version_number        in   number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_open_fc_enrollment_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_open_fc_enrollment_a
  ( p_effective_date               in     date
    ,p_enrollment_id                in     number
    ,p_business_group_id            in     number
    ,p_forum_id                     in     number
    ,p_person_id                    in     number
    ,p_contact_id                   in     number
    ,p_chat_id                      in     number
    ,p_object_version_number        in   number
  );

end ota_open_fc_enrollment_bk2;

 

/
