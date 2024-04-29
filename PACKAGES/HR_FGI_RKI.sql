--------------------------------------------------------
--  DDL for Package HR_FGI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FGI_RKI" AUTHID CURRENT_USER as
/* $Header: hrfgirhi.pkh 120.0 2005/05/31 00:19:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_data_group_item_id      in number
  ,p_object_version_number        in number
  ,p_form_data_group_id           in number
  ,p_form_item_id                 in number
  );
end hr_fgi_rki;

 

/
