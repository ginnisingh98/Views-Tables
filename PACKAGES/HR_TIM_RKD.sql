--------------------------------------------------------
--  DDL for Package HR_TIM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIM_RKD" AUTHID CURRENT_USER as
/* $Header: hrtimrhi.pkh 120.0 2005/05/31 03:14:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_item_id             in number
  ,p_object_version_number_o      in number
  ,p_form_template_id_o           in number
  ,p_form_item_id_o               in number
  );
--
end hr_tim_rkd;

 

/
