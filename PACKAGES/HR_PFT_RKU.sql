--------------------------------------------------------
--  DDL for Package HR_PFT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PFT_RKU" AUTHID CURRENT_USER as
/* $Header: hrpftrhi.pkh 120.0 2005/05/31 02:07:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_position_id                  in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end hr_pft_rku;

 

/
