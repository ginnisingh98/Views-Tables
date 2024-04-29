--------------------------------------------------------
--  DDL for Package HR_DTY_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DTY_RKU" AUTHID CURRENT_USER as
/* $Header: hrdtyrhi.pkh 120.0 2005/05/30 23:55:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_document_type_id             in number
  ,p_category_code                in varchar2
  ,p_sub_category_code            in varchar2
  ,p_active_inactive_flag         in varchar2
  ,p_multiple_occurences_flag     in varchar2
  ,p_legislation_code             in varchar2
  ,p_authorization_required       in varchar2
  ,p_warning_period               in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_category_code_o              in varchar2
  ,p_sub_category_code_o          in varchar2
  ,p_active_inactive_flag_o       in varchar2
  ,p_multiple_occurences_flag_o   in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_authorization_required_o     in varchar2
  ,p_warning_period_o             in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end hr_dty_rku;

 

/
