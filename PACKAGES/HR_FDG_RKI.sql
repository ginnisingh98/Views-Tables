--------------------------------------------------------
--  DDL for Package HR_FDG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FDG_RKI" AUTHID CURRENT_USER as
/* $Header: hrfdgrhi.pkh 120.0 2005/05/31 00:17:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_data_group_id           in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_data_group_name              in varchar2
  );
end hr_fdg_rki;

 

/
