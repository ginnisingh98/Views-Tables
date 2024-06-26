--------------------------------------------------------
--  DDL for Package PER_SSM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSM_RKD" AUTHID CURRENT_USER as
/* $Header: pessmrhi.pkh 120.0 2005/05/31 21:51:12 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure after_delete
  (
  p_object_version_number        in number,
  p_salary_survey_mapping_id     in number,
  p_parent_id_o                  in number,
  p_parent_table_name_o          in varchar2,
  p_salary_survey_line_id_o      in number,
  p_business_group_id_o          in number,
  p_location_id_o                in number,
  p_grade_id_o                   in number,
  p_company_organization_id_o    in number,
  p_company_age_code_o           in varchar2,
  p_attribute_category_o         in varchar2,
  p_attribute1_o                 in varchar2,
  p_attribute2_o                 in varchar2,
  p_attribute3_o                 in varchar2,
  p_attribute4_o                 in varchar2,
  p_attribute5_o                 in varchar2,
  p_attribute6_o                 in varchar2,
  p_attribute7_o                 in varchar2,
  p_attribute8_o                 in varchar2,
  p_attribute9_o                 in varchar2,
  p_attribute10_o                in varchar2,
  p_attribute11_o                in varchar2,
  p_attribute12_o                in varchar2,
  p_attribute13_o                in varchar2,
  p_attribute14_o                in varchar2,
  p_attribute15_o                in varchar2,
  p_attribute16_o                in varchar2,
  p_attribute17_o                in varchar2,
  p_attribute18_o                in varchar2,
  p_attribute19_o                in varchar2,
  p_attribute20_o                in varchar2
  );
--
end per_ssm_rkd;

 

/
