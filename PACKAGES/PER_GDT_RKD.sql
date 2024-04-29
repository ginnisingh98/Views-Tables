--------------------------------------------------------
--  DDL for Package PER_GDT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GDT_RKD" AUTHID CURRENT_USER as
/* $Header: pegdtrhi.pkh 120.0 2005/05/31 09:16:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_grade_id                     in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end per_gdt_rkd;

 

/
