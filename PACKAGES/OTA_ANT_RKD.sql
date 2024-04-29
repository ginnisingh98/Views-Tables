--------------------------------------------------------
--  DDL for Package OTA_ANT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ANT_RKD" AUTHID CURRENT_USER as
/* $Header: otantrhi.pkh 120.0 2005/05/29 06:57:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_announcement_id              in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_announcement_title_o         in varchar2
  ,p_announcement_body_o          in varchar2
  );
--
end ota_ant_rkd;

 

/
