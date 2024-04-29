--------------------------------------------------------
--  DDL for Package OTA_CHA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHA_RKI" AUTHID CURRENT_USER as
/* $Header: otcharhi.pkh 120.2 2006/03/06 02:26 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_chat_id                      in number
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_public_flag                  in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_start_time_active            in varchar2
  ,p_end_time_active              in VARCHAR2
  ,p_timezone_code                IN VARCHAR2
  );
end ota_cha_rki;

 

/
