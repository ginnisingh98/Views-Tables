--------------------------------------------------------
--  DDL for Package OTA_FNS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FNS_RKI" AUTHID CURRENT_USER as
/* $Header: otfnsrhi.pkh 120.0 2005/06/24 07:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_forum_id                     in number
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  );
end ota_fns_rki;

 

/
