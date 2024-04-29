--------------------------------------------------------
--  DDL for Package OTA_CHA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHA_RKU" AUTHID CURRENT_USER as
/* $Header: otcharhi.pkh 120.2 2006/03/06 02:26 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  ,p_public_flag_o                in varchar2
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_start_time_active_o          in varchar2
  ,p_end_time_active_o            in VARCHAR2
  ,p_timezone_code_o              IN VARCHAR2
  );
--
end ota_cha_rku;

 

/
