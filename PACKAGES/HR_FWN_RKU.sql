--------------------------------------------------------
--  DDL for Package HR_FWN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FWN_RKU" AUTHID CURRENT_USER as
/* $Header: hrfwnrhi.pkh 120.0 2005/05/31 00:34:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_form_window_id               in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_window_name                  in varchar2
  ,p_object_version_number_o      in number
  ,p_application_id_o             in number
  ,p_form_id_o                    in number
  ,p_window_name_o                in varchar2
  );
--
end hr_fwn_rku;

 

/
