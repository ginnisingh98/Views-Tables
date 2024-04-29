--------------------------------------------------------
--  DDL for Package HR_TWN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TWN_RKI" AUTHID CURRENT_USER as
/* $Header: hrtwnrhi.pkh 120.0 2005/05/31 03:35:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_window_id           in number
  ,p_object_version_number        in number
  ,p_form_template_id             in number
  ,p_form_window_id               in number
  );
end hr_twn_rki;

 

/
