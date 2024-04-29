--------------------------------------------------------
--  DDL for Package PER_CIT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CIT_RKU" AUTHID CURRENT_USER as
/* $Header: pecitrhi.pkh 120.0 2005/05/31 06:43:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_cagr_entitlement_item_id     in number
  ,p_item_name                    in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_item_name_o                  in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_cit_rku;

 

/
