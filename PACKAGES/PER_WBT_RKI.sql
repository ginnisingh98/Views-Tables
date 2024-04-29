--------------------------------------------------------
--  DDL for Package PER_WBT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WBT_RKI" AUTHID CURRENT_USER as
/* $Header: pewbtrhi.pkh 120.1 2006/06/07 23:06:17 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_workbench_item_code          in varchar2
  ,p_language                     in varchar2
  ,p_workbench_item_name          in varchar2
  ,p_workbench_item_description   in varchar2
  ,p_source_lang                  in varchar2
  );
end per_wbt_rki;

 

/
