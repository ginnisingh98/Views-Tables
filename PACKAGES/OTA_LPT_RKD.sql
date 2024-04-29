--------------------------------------------------------
--  DDL for Package OTA_LPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPT_RKD" AUTHID CURRENT_USER as
/* $Header: otlptrhi.pkh 120.0 2005/05/29 07:24:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_learning_path_id             in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_objectives_o                 in varchar2
  ,p_purpose_o                    in varchar2
  ,p_keywords_o                   in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_lpt_rkd;

 

/
