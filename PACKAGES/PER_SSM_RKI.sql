--------------------------------------------------------
--  DDL for Package PER_SSM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SSM_RKI" AUTHID CURRENT_USER as
/* $Header: pessmrhi.pkh 120.0 2005/05/31 21:51:12 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
Procedure after_insert
  (
  p_object_version_number        in number,
  p_salary_survey_mapping_id     in number,
  p_parent_id                    in number,
  p_parent_table_name            in varchar2,
  p_salary_survey_line_id        in number,
  p_business_group_id            in number,
  p_location_id                  in number,
  p_grade_id                     in number,
  p_company_organization_id      in number,
  p_company_age_code             in varchar2,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_effective_date		 in date
  );
--
end per_ssm_rki;

 

/
