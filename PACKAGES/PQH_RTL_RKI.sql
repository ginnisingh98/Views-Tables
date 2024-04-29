--------------------------------------------------------
--  DDL for Package PQH_RTL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RTL_RKI" AUTHID CURRENT_USER as
/* $Header: pqrtlrhi.pkh 120.0 2005/05/29 02:39:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_rule_set_id                    in number
 ,p_rule_set_name                  in varchar2
 ,p_description			   in varchar2
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
  );
end pqh_rtl_rki;

 

/
