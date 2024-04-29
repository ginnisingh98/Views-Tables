--------------------------------------------------------
--  DDL for Package HR_UCX_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UCX_RKU" AUTHID CURRENT_USER as
/* $Header: hrucxrhi.pkh 120.0 2005/05/31 03:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_ui_context_id                in number
  ,p_ui_context_key               in varchar2
  ,p_user_interface_id            in number
  ,p_label                        in varchar2
  ,p_location                     in varchar2
  ,p_object_version_number        in number
  ,p_ui_context_key_o             in varchar2
  ,p_user_interface_id_o          in number
  ,p_label_o                      in varchar2
  ,p_location_o                   in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_ucx_rku;

 

/
