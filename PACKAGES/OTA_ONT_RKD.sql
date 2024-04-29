--------------------------------------------------------
--  DDL for Package OTA_ONT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ONT_RKD" AUTHID CURRENT_USER as
/* $Header: otontrhi.pkh 120.0 2005/05/29 07:30:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_offering_id                  in number
  ,p_language                     in varchar2
  ,p_offering_name_o              in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_ont_rkd;

 

/
