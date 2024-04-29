--------------------------------------------------------
--  DDL for Package HR_TCN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCN_RKI" AUTHID CURRENT_USER as
/* $Header: hrtcnrhi.pkh 120.0 2005/05/31 02:58:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_canvas_id           in number
  ,p_object_version_number        in number
  ,p_template_window_id           in number
  ,p_form_canvas_id               in number
  );
end hr_tcn_rki;

 

/
