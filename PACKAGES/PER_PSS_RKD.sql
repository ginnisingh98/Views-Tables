--------------------------------------------------------
--  DDL for Package PER_PSS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSS_RKD" AUTHID CURRENT_USER as
/* $Header: pepssrhi.pkh 120.0 2005/05/31 15:35:00 appldev noship $ */
--
-- -----------------------------------------------------------------------
-- |---------------------------< after_delete >--------------------------|
-- -----------------------------------------------------------------------
--
procedure after_delete
 (p_salary_survey_id        in number,
  p_object_version_number_o in number,
  p_survey_name_o           in varchar2,
  p_survey_company_code_o   in varchar2,
  p_identifier_o            in varchar2,
--ras  p_currency_code_o         in varchar2,
  p_survey_type_code_o      in varchar2,
  p_base_region_o           in varchar2,
  p_attribute_category_o    in varchar2,
  p_attribute1_o            in varchar2,
  p_attribute2_o            in varchar2,
  p_attribute3_o            in varchar2,
  p_attribute4_o            in varchar2,
  p_attribute5_o            in varchar2,
  p_attribute6_o            in varchar2,
  p_attribute7_o            in varchar2,
  p_attribute8_o            in varchar2,
  p_attribute9_o            in varchar2,
  p_attribute10_o           in varchar2,
  p_attribute11_o           in varchar2,
  p_attribute12_o           in varchar2,
  p_attribute13_o           in varchar2,
  p_attribute14_o           in varchar2,
  p_attribute15_o           in varchar2,
  p_attribute16_o           in varchar2,
  p_attribute17_o           in varchar2,
  p_attribute18_o           in varchar2,
  p_attribute19_o           in varchar2,
  p_attribute20_o           in varchar2
);

end per_pss_rkd;

 

/
