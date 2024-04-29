--------------------------------------------------------
--  DDL for Package OTA_BJS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BJS_RKI" AUTHID CURRENT_USER as
/* $Header: otbjsrhi.pkh 120.0 2005/05/29 07:03:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_booking_justification_id     in number
  ,p_priority_level               in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end ota_bjs_rki;

 

/
