--------------------------------------------------------
--  DDL for Package PER_JOB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_RKI" AUTHID CURRENT_USER as
/* $Header: pejobrhi.pkh 120.0 2005/05/31 10:48:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure after_insert
  (
   p_job_id                       in number,
   p_business_group_id            in number,
   p_job_definition_id            in number,
   p_date_from                    in date,
   p_comments                     in varchar2,
   p_date_to                      in date,
   p_approval_authority           in number,
   p_name                         in varchar2,
   p_request_id                   in number,
   p_program_application_id       in number,
   p_program_id                   in number,
   p_program_update_date          in date,
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
   p_job_information_category     in varchar2,
   p_job_information1             in varchar2,
   p_job_information2             in varchar2,
   p_job_information3             in varchar2,
   p_job_information4             in varchar2,
   p_job_information5             in varchar2,
   p_job_information6             in varchar2,
   p_job_information7             in varchar2,
   p_job_information8             in varchar2,
   p_job_information9             in varchar2,
   p_job_information10            in varchar2,
   p_job_information11            in varchar2,
   p_job_information12            in varchar2,
   p_job_information13            in varchar2,
   p_job_information14            in varchar2,
   p_job_information15            in varchar2,
   p_job_information16            in varchar2,
   p_job_information17            in varchar2,
   p_job_information18            in varchar2,
   p_job_information19            in varchar2,
   p_job_information20            in varchar2,
   p_benchmark_job_flag           in varchar2,
   p_benchmark_job_id             in number,
   p_emp_rights_flag              in varchar2,
   p_job_group_id                 in number,
   p_object_version_number        in number
  );
end per_job_rki;

 

/
