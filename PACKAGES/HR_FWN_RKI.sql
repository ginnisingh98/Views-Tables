--------------------------------------------------------
--  DDL for Package HR_FWN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FWN_RKI" AUTHID CURRENT_USER as
/* $Header: hrfwnrhi.pkh 120.0 2005/05/31 00:34:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_window_id               in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_window_name                  in varchar2
  );
end hr_fwn_rki;

 

/
