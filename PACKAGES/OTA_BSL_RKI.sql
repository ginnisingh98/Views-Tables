--------------------------------------------------------
--  DDL for Package OTA_BSL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BSL_RKI" AUTHID CURRENT_USER as
/* $Header: otbslrhi.pkh 120.0 2005/05/29 07:04:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_booking_status_type_id       in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_source_lang                  in varchar2
  );
end ota_bsl_rki;

 

/
