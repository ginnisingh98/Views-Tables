--------------------------------------------------------
--  DDL for Package OTA_BJT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BJT_RKU" AUTHID CURRENT_USER as
/* $Header: otbjtrhi.pkh 120.0 2005/05/29 07:03:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_booking_justification_id     in number
  ,p_justification_text           in varchar2
  ,p_source_lang                  in varchar2
  ,p_language                     in varchar2
  ,p_justification_text_o         in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_bjt_rku;

 

/
