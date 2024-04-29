--------------------------------------------------------
--  DDL for Package HR_FCN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FCN_RKI" AUTHID CURRENT_USER as
/* $Header: hrfcnrhi.pkh 120.0 2005/05/31 00:14:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_form_canvas_id               in number
  ,p_object_version_number        in number
  ,p_form_window_id               in number
  ,p_canvas_name                  in varchar2
  ,p_canvas_type                  in varchar2
  );
end hr_fcn_rki;

 

/
