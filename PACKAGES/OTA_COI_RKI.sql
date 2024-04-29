--------------------------------------------------------
--  DDL for Package OTA_COI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COI_RKI" AUTHID CURRENT_USER as
/* $Header: otcoirhi.pkh 120.0 2005/06/24 07:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_chat_id                      in number
  ,p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_primary_flag                 in varchar2
  ,p_object_version_number        in number
  );
end ota_coi_rki;

 

/
