--------------------------------------------------------
--  DDL for Package HR_ITL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITL_RKU" AUTHID CURRENT_USER as
/* $Header: hritlrhi.pkh 120.0 2005/05/31 00:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_integration_id               in number
  ,p_partner_name                 in varchar2
  ,p_service_name                 in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_partner_name_o               in varchar2
  ,p_service_name_o               in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hr_itl_rku;

 

/
