--------------------------------------------------------
--  DDL for Package PER_CIT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CIT_RKI" AUTHID CURRENT_USER as
/* $Header: pecitrhi.pkh 120.0 2005/05/31 06:43:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_cagr_entitlement_item_id     in number
  ,p_item_name                    in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end per_cit_rki;

 

/
