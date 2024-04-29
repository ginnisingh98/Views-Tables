--------------------------------------------------------
--  DDL for Package PER_PEA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEA_RKD" AUTHID CURRENT_USER as
/* $Header: pepearhi.pkh 120.0.12010000.2 2008/08/06 09:21:03 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
   p_person_analysis_id            in number,
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
end per_pea_rkd;

/
