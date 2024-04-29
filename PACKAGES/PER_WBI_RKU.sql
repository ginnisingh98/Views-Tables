--------------------------------------------------------
--  DDL for Package PER_WBI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WBI_RKU" AUTHID CURRENT_USER as
/* $Header: pewbirhi.pkh 120.0 2005/05/31 23:04:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_workbench_item_code          in varchar2
  ,p_menu_id                      in number
  ,p_workbench_item_sequence      in number
  ,p_workbench_parent_item_code   in varchar2
  ,p_workbench_item_creation_date in date
  ,p_workbench_item_type          in varchar2
  ,p_object_version_number        in number
  ,p_menu_id_o                    in number
  ,p_workbench_item_sequence_o    in number
  ,p_workbench_parent_item_code_o in varchar2
  ,p_workbench_item_creation_da_o in date
  ,p_workbench_item_type_o        in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_wbi_rku;

 

/
