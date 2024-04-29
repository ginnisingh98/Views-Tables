--------------------------------------------------------
--  DDL for Package HR_UCX_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UCX_RKI" AUTHID CURRENT_USER as
/* $Header: hrucxrhi.pkh 120.0 2005/05/31 03:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_ui_context_id                in number
  ,p_ui_context_key               in varchar2
  ,p_user_interface_id            in number
  ,p_label                        in varchar2
  ,p_location                     in varchar2
  ,p_object_version_number        in number
  );
end hr_ucx_rki;

 

/
