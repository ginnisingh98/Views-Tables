--------------------------------------------------------
--  DDL for Package AME_ATL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATL_RKU" AUTHID CURRENT_USER as
/* $Header: amatlrhi.pkh 120.0 2005/09/02 03:50 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_attribute_id                 in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_description_o                in varchar2
  );
--
end ame_atl_rku;

 

/
