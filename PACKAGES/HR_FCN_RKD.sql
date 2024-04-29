--------------------------------------------------------
--  DDL for Package HR_FCN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FCN_RKD" AUTHID CURRENT_USER as
/* $Header: hrfcnrhi.pkh 120.0 2005/05/31 00:14:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_canvas_id               in number
  ,p_object_version_number_o      in number
  ,p_form_window_id_o             in number
  ,p_canvas_name_o                in varchar2
  ,p_canvas_type_o                in varchar2
  );
--
end hr_fcn_rkd;

 

/
