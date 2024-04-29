--------------------------------------------------------
--  DDL for Package HR_SFT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SFT_RKD" AUTHID CURRENT_USER as
/* $Header: hrsftrhi.pkh 120.0 2005/05/31 02:40:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_source_form_template_id      in number
  ,p_object_version_number_o      in number
  ,p_form_template_id_to_o        in number
  ,p_form_template_id_from_o      in number
  );
--
end hr_sft_rkd;

 

/
