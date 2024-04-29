--------------------------------------------------------
--  DDL for Package PER_WBT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WBT_RKU" AUTHID CURRENT_USER as
/* $Header: pewbtrhi.pkh 120.1 2006/06/07 23:06:17 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_workbench_item_code          in varchar2
  ,p_language                     in varchar2
  ,p_workbench_item_name          in varchar2
  ,p_workbench_item_description   in varchar2
  ,p_source_lang                  in varchar2
  ,p_workbench_item_name_o        in varchar2
  ,p_workbench_item_description_o in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_wbt_rku;

 

/
