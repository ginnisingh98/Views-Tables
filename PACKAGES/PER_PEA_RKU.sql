--------------------------------------------------------
--  DDL for Package PER_PEA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEA_RKU" AUTHID CURRENT_USER as
/* $Header: pepearhi.pkh 120.0.12010000.2 2008/08/06 09:21:03 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
   p_person_analysis_id            in number,
   p_analysis_criteria_id          in number,
   p_comments                      in varchar2,
   p_date_from                     in date,
   p_date_to                       in date,
   p_id_flex_num                   in number,
   p_request_id                    in number,
   p_program_application_id        in number,
   p_program_id                    in number,
   p_program_update_date           in date,
   p_attribute_category            in varchar2,
   p_attribute1                    in varchar2,
   p_attribute2                    in varchar2,
   p_attribute3                    in varchar2,
   p_attribute4                    in varchar2,
   p_attribute5                    in varchar2,
   p_attribute6                    in varchar2,
   p_attribute7                    in varchar2,
   p_attribute8                    in varchar2,
   p_attribute9                    in varchar2,
   p_attribute10                   in varchar2,
   p_attribute11                   in varchar2,
   p_attribute12                   in varchar2,
   p_attribute13                   in varchar2,
   p_attribute14                   in varchar2,
   p_attribute15                   in varchar2,
   p_attribute16                   in varchar2,
   p_attribute17                   in varchar2,
   p_attribute18                   in varchar2,
   p_attribute19                   in varchar2,
   p_attribute20                   in varchar2,
   p_object_version_number         in number,
   p_business_group_id_o           in number,
   p_analysis_criteria_id_o        in number,
   p_person_id_o                   in number,
   p_comments_o                    in varchar2,
   p_date_from_o                   in date,
   p_date_to_o                     in date,
   p_id_flex_num_o                 in number,
   p_request_id_o                  in number,
   p_program_application_id_o      in number,
   p_program_id_o                  in number,
   p_program_update_date_o         in date,
   p_attribute_category_o          in varchar2,
   p_attribute1_o                  in varchar2,
   p_attribute2_o                  in varchar2,
   p_attribute3_o                  in varchar2,
   p_attribute4_o                  in varchar2,
   p_attribute5_o                  in varchar2,
   p_attribute6_o                  in varchar2,
   p_attribute7_o                  in varchar2,
   p_attribute8_o                  in varchar2,
   p_attribute9_o                  in varchar2,
   p_attribute10_o                 in varchar2,
   p_attribute11_o                 in varchar2,
   p_attribute12_o                 in varchar2,
   p_attribute13_o                 in varchar2,
   p_attribute14_o                 in varchar2,
   p_attribute15_o                 in varchar2,
   p_attribute16_o                 in varchar2,
   p_attribute17_o                 in varchar2,
   p_attribute18_o                 in varchar2,
   p_attribute19_o                 in varchar2,
   p_attribute20_o                 in varchar2,
   p_object_version_number_o       in number
  );
end per_pea_rku;

/
