--------------------------------------------------------
--  DDL for Package OTA_TCC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TCC_RKI" AUTHID CURRENT_USER as
/* $Header: ottccrhi.pkh 120.0 2005/05/29 07:36:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cross_charge_id              in number
  ,p_business_group_id            in number
  ,p_gl_set_of_books_id           in number
  ,p_object_version_number        in number
  ,p_type                         in varchar2
  ,p_from_to                      in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  );
end ota_tcc_rki;

 

/
