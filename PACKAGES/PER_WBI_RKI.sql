--------------------------------------------------------
--  DDL for Package PER_WBI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WBI_RKI" AUTHID CURRENT_USER as
/* $Header: pewbirhi.pkh 120.0 2005/05/31 23:04:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_workbench_item_code          in varchar2
  ,p_menu_id                      in number
  ,p_workbench_item_sequence      in number
  ,p_workbench_parent_item_code   in varchar2
  ,p_workbench_item_creation_date in date
  ,p_workbench_item_type          in varchar2
  ,p_object_version_number        in number
  );
end per_wbi_rki;

 

/
