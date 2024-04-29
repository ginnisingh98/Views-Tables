--------------------------------------------------------
--  DDL for Package OTA_BSL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BSL_RKD" AUTHID CURRENT_USER as
/* $Header: otbslrhi.pkh 120.0 2005/05/29 07:04:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_booking_status_type_id       in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_bsl_rkd;

 

/
