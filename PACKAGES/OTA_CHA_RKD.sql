--------------------------------------------------------
--  DDL for Package OTA_CHA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHA_RKD" AUTHID CURRENT_USER as
/* $Header: otcharhi.pkh 120.2 2006/03/06 02:26 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_chat_id                      in number
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
end ota_cha_rkd;

 

/
