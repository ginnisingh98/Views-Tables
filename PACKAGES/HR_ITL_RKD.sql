--------------------------------------------------------
--  DDL for Package HR_ITL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITL_RKD" AUTHID CURRENT_USER as
/* $Header: hritlrhi.pkh 120.0 2005/05/31 00:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_integration_id               in number
  ,p_language                     in varchar2
  ,p_partner_name_o               in varchar2
  ,p_service_name_o               in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hr_itl_rkd;

 

/
