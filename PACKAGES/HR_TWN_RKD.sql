--------------------------------------------------------
--  DDL for Package HR_TWN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TWN_RKD" AUTHID CURRENT_USER as
/* $Header: hrtwnrhi.pkh 120.0 2005/05/31 03:35:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_window_id           in number
  ,p_object_version_number_o      in number
  ,p_form_template_id_o           in number
  ,p_form_window_id_o             in number
  );
--
end hr_twn_rkd;

 

/
