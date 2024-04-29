--------------------------------------------------------
--  DDL for Package OTA_FRM_NOTIF_SUBSCRIBER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_NOTIF_SUBSCRIBER_BK1" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_frm_notif_subscriber_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_frm_notif_subscriber_b
    (p_effective_date               in     date
   ,p_business_group_id              in     number
   ,p_forum_id                          in  number
   ,p_person_id                         in  number
   ,p_contact_id                        in  number
   ,p_object_version_number             in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_frm_notif_subscriber_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_frm_notif_subscriber_a
    (p_effective_date               in     date
   ,p_business_group_id              in     number
   ,p_forum_id                          in  number
   ,p_person_id                         in  number
   ,p_contact_id                        in  number
   ,p_object_version_number             in  number
  );

end ota_frm_notif_subscriber_bk1 ;

 

/
