--------------------------------------------------------
--  DDL for Package HR_SFT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SFT_RKI" AUTHID CURRENT_USER as
/* $Header: hrsftrhi.pkh 120.0 2005/05/31 02:40:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_source_form_template_id      in number
  ,p_object_version_number        in number
  ,p_form_template_id_to          in number
  ,p_form_template_id_from        in number
  );
end hr_sft_rki;

 

/
