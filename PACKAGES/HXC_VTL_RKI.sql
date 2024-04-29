--------------------------------------------------------
--  DDL for Package HXC_VTL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_VTL_RKI" AUTHID CURRENT_USER as
/* $Header: hxcvtlrhi.pkh 120.0 2005/05/29 06:07:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_alias_value_id               in number
  ,p_alias_value_name             in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end hxc_vtl_rki;

 

/
