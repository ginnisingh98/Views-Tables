--------------------------------------------------------
--  DDL for Package PER_JOB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_RKD" AUTHID CURRENT_USER as
/* $Header: pejobrhi.pkh 120.0 2005/05/31 10:48:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure after_delete
  (
   p_job_id                       in number,
   p_business_group_id_o          in number,
   p_job_definition_id_o          in number,
   p_date_from_o                  in date,
   p_comments_o                   in varchar2,
   p_date_to_o                    in date,
   p_approval_authority_o         in number,
   p_name_o                       in varchar2,
   p_request_id_o                 in number,
   p_program_application_id_o     in number,
   p_program_id_o                 in number,
   p_program_update_date_o        in date,
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
   p_attribute20_o                in varchar2,
   p_job_information_category_o   in varchar2,
   p_job_information1_o           in varchar2,
   p_job_information2_o           in varchar2,
   p_job_information3_o           in varchar2,
   p_job_information4_o           in varchar2,
   p_job_information5_o           in varchar2,
   p_job_information6_o           in varchar2,
   p_job_information7_o           in varchar2,
   p_job_information8_o           in varchar2,
   p_job_information9_o           in varchar2,
   p_job_information10_o          in varchar2,
   p_job_information11_o          in varchar2,
   p_job_information12_o          in varchar2,
   p_job_information13_o          in varchar2,
   p_job_information14_o          in varchar2,
   p_job_information15_o          in varchar2,
   p_job_information16_o          in varchar2,
   p_job_information17_o          in varchar2,
   p_job_information18_o          in varchar2,
   p_job_information19_o          in varchar2,
   p_job_information20_o          in varchar2,
   p_benchmark_job_flag_o         in varchar2,
   p_benchmark_job_id_o           in number,
   p_emp_rights_flag_o            in varchar2,
   p_job_group_id_o               in number,
   p_object_version_number_o      in number
  );
end per_job_rkd;

 

/
