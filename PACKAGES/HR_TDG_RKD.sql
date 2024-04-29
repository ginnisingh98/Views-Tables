--------------------------------------------------------
--  DDL for Package HR_TDG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TDG_RKD" AUTHID CURRENT_USER as
/* $Header: hrtdgrhi.pkh 120.0 2005/05/31 03:05:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_data_group_id       in number
  ,p_object_version_number_o      in number
  ,p_form_template_id_o           in number
  ,p_form_data_group_id_o         in number
  );
--
end hr_tdg_rkd;

 

/
