--------------------------------------------------------
--  DDL for Package OTA_FMS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FMS_RKD" AUTHID CURRENT_USER as
/* $Header: otfmsrhi.pkh 120.0 2005/06/24 07:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_forum_message_id             in number
  ,p_forum_id_o                   in number
  ,p_forum_thread_id_o            in number
  ,p_business_group_id_o          in number
  ,p_message_body_o               in varchar2
  ,p_parent_message_id_o          in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_target_person_id_o           in number
  ,p_target_contact_id_o          in number
  ,p_message_scope_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_fms_rkd;

 

/
