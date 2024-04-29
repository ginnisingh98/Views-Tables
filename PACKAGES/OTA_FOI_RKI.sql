--------------------------------------------------------
--  DDL for Package OTA_FOI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FOI_RKI" AUTHID CURRENT_USER as
/* $Header: otfoirhi.pkh 120.0 2005/06/24 07:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_forum_id                     in number
  ,p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_primary_flag                 in varchar2
  ,p_object_version_number        in number
  );
end ota_foi_rki;

 

/
