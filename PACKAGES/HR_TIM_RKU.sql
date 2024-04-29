--------------------------------------------------------
--  DDL for Package HR_TIM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIM_RKU" AUTHID CURRENT_USER as
/* $Header: hrtimrhi.pkh 120.0 2005/05/31 03:14:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_template_item_id             in number
  ,p_object_version_number        in number
  ,p_form_template_id             in number
  ,p_form_item_id                 in number
  ,p_object_version_number_o      in number
  ,p_form_template_id_o           in number
  ,p_form_item_id_o               in number
  );
--
end hr_tim_rku;

 

/
