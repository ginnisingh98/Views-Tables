--------------------------------------------------------
--  DDL for Package HR_TDG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TDG_RKI" AUTHID CURRENT_USER as
/* $Header: hrtdgrhi.pkh 120.0 2005/05/31 03:05:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_data_group_id       in number
  ,p_object_version_number        in number
  ,p_form_template_id             in number
  ,p_form_data_group_id           in number
  );
end hr_tdg_rki;

 

/
