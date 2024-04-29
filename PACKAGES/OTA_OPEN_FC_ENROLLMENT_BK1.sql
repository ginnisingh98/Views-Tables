--------------------------------------------------------
--  DDL for Package OTA_OPEN_FC_ENROLLMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OPEN_FC_ENROLLMENT_BK1" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_open_fc_enrollment_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_open_fc_enrollment_b
  (  p_effective_date               in     date
    ,p_business_group_id              in     number
    ,p_forum_id                       in     number
    ,p_person_id                      in     number
    ,p_contact_id                     in     number
    ,p_chat_id                        in     number
    ,p_object_version_number           in    number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_open_fc_enrollment_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_open_fc_enrollment_a
  ( p_effective_date               in     date
    ,p_business_group_id              in     number
    ,p_forum_id                       in     number
    ,p_person_id                      in     number
    ,p_contact_id                     in     number
    ,p_chat_id                        in     number
    ,p_enrollment_id                     in  number
    ,p_object_version_number             in  number
  );

end ota_open_fc_enrollment_bk1 ;

 

/
