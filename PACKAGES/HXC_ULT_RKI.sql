--------------------------------------------------------
--  DDL for Package HXC_ULT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULT_RKI" AUTHID CURRENT_USER as
/* $Header: hxcultrhi.pkh 120.0 2005/05/29 06:06:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_layout_id                    in number
  ,p_display_layout_name          in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end hxc_ult_rki;

 

/
