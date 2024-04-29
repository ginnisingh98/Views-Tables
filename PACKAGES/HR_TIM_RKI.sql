--------------------------------------------------------
--  DDL for Package HR_TIM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIM_RKI" AUTHID CURRENT_USER as
/* $Header: hrtimrhi.pkh 120.0 2005/05/31 03:14:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_item_id             in number
  ,p_object_version_number        in number
  ,p_form_template_id             in number
  ,p_form_item_id                 in number
  );
end hr_tim_rki;

 

/
