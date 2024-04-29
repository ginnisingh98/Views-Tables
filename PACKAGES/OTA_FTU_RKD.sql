--------------------------------------------------------
--  DDL for Package OTA_FTU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FTU_RKD" AUTHID CURRENT_USER as
/* $Header: otfturhi.pkh 120.0 2005/06/24 07:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_forum_thread_id              in number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id_o          in number
  ,p_author_person_id_o           in number
  ,p_author_contact_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ota_ftu_rkd;

 

/
