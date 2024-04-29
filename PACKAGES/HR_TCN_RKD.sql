--------------------------------------------------------
--  DDL for Package HR_TCN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCN_RKD" AUTHID CURRENT_USER as
/* $Header: hrtcnrhi.pkh 120.0 2005/05/31 02:58:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_canvas_id           in number
  ,p_object_version_number_o      in number
  ,p_template_window_id_o         in number
  ,p_form_canvas_id_o             in number
  );
--
end hr_tcn_rkd;

 

/
