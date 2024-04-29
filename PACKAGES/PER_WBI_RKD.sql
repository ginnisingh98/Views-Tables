--------------------------------------------------------
--  DDL for Package PER_WBI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WBI_RKD" AUTHID CURRENT_USER as
/* $Header: pewbirhi.pkh 120.0 2005/05/31 23:04:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_workbench_item_code          in varchar2
  ,p_menu_id_o                    in number
  ,p_workbench_item_sequence_o    in number
  ,p_workbench_parent_item_code_o in varchar2
  ,p_workbench_item_creation_da_o in date
  ,p_workbench_item_type_o        in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_wbi_rkd;

 

/
