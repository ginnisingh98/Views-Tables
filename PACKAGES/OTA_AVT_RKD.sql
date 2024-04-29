--------------------------------------------------------
--  DDL for Package OTA_AVT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_AVT_RKD" AUTHID CURRENT_USER as
/* $Header: otavtrhi.pkh 120.0 2005/05/29 07:02:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_activity_version_id          in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_version_name_o               in varchar2
  ,p_description_o                in varchar2
  ,p_intended_audience_o          in varchar2
  ,p_objectives_o                 in varchar2
  ,p_keywords_o                     in varchar2
  );
--
end ota_avt_rkd;

 

/
