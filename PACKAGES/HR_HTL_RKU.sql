--------------------------------------------------------
--  DDL for Package HR_HTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HTL_RKU" AUTHID CURRENT_USER as
/* $Header: hrhtlrhi.pkh 120.0 2005/05/31 00:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_hierarchy_id              in number
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hr_htl_rku;

 

/
