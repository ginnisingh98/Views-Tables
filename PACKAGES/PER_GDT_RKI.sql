--------------------------------------------------------
--  DDL for Package PER_GDT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GDT_RKI" AUTHID CURRENT_USER as
/* $Header: pegdtrhi.pkh 120.0 2005/05/31 09:16:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_grade_id                     in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  );
end per_gdt_rki;

 

/
