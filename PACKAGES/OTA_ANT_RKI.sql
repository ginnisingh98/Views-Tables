--------------------------------------------------------
--  DDL for Package OTA_ANT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ANT_RKI" AUTHID CURRENT_USER as
/* $Header: otantrhi.pkh 120.0 2005/05/29 06:57:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_announcement_id              in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  );
end ota_ant_rki;

 

/
