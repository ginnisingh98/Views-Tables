--------------------------------------------------------
--  DDL for Package PER_PDS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PDS_RKU" AUTHID CURRENT_USER as
/* $Header: pepdsrhi.pkh 120.1 2006/02/21 03:11:57 pdkundu noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_update >----------------------------------|
-- ----------------------------------------------------------------------------
--
--{Start Of Comments}
-- employmt truncated from employment (p_prior_employmt_ssp_paid_to_o)
-- terminat truncated from termination (p_terminat_accepted_person_o)
--
-- This procedure is for the row handler user hook. The package body is generated.
--
--/*
Procedure after_update
  (
   p_period_of_service_id         in number
  ,p_termination_accepted_person  in number
  ,p_date_start                   in date
  ,p_accepted_termination_date    in date
  ,p_actual_termination_date      in date
  ,p_comments                     in varchar2
  ,p_adjusted_svc_date            in date
  ,p_final_process_date           in date
  ,p_last_standard_process_date   in date
  ,p_leaving_reason               in varchar2
  ,p_notified_termination_date    in date
  ,p_projected_termination_date   in date
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_object_version_number        in number
  ,p_prior_employment_ssp_weeks   in number
  ,p_prior_employment_ssp_paid_to in date
  ,p_pds_information_category       in varchar2
  ,p_pds_information1               in varchar2
  ,p_pds_information2               in varchar2
  ,p_pds_information3               in varchar2
  ,p_pds_information4               in varchar2
  ,p_pds_information5               in varchar2
  ,p_pds_information6               in varchar2
  ,p_pds_information7               in varchar2
  ,p_pds_information8               in varchar2
  ,p_pds_information9               in varchar2
  ,p_pds_information10              in varchar2
  ,p_pds_information11              in varchar2
  ,p_pds_information12              in varchar2
  ,p_pds_information13              in varchar2
  ,p_pds_information14              in varchar2
  ,p_pds_information15              in varchar2
  ,p_pds_information16              in varchar2
  ,p_pds_information17              in varchar2
  ,p_pds_information18              in varchar2
  ,p_pds_information19              in varchar2
  ,p_pds_information20              in varchar2
  ,p_pds_information21              in varchar2
  ,p_pds_information22              in varchar2
  ,p_pds_information23              in varchar2
  ,p_pds_information24              in varchar2
  ,p_pds_information25              in varchar2
  ,p_pds_information26              in varchar2
  ,p_pds_information27              in varchar2
  ,p_pds_information28              in varchar2
  ,p_pds_information29              in varchar2
  ,p_pds_information30              in varchar2
  ,p_effective_date               in date
  ,p_business_group_id_o            in number
  ,p_person_id_o                    in number
  ,p_terminat_accepted_person_o     in number
  ,p_date_start_o                   in date
  ,p_accepted_termination_date_o    in date
  ,p_actual_termination_date_o      in date
  ,p_comments_o                     in varchar2
  ,p_adjusted_svc_date_o            in date
  ,p_final_process_date_o           in date
  ,p_last_standard_process_date_o   in date
  ,p_leaving_reason_o               in varchar2
  ,p_notified_termination_date_o    in date
  ,p_projected_termination_date_o   in date
  ,p_request_id_o                   in number
  ,p_program_application_id_o       in number
  ,p_program_id_o                   in number
  ,p_program_update_date_o          in date
  ,p_attribute_category_o           in varchar2
  ,p_attribute1_o                   in varchar2
  ,p_attribute2_o                   in varchar2
  ,p_attribute3_o                   in varchar2
  ,p_attribute4_o                   in varchar2
  ,p_attribute5_o                   in varchar2
  ,p_attribute6_o                   in varchar2
  ,p_attribute7_o                   in varchar2
  ,p_attribute8_o                   in varchar2
  ,p_attribute9_o                   in varchar2
  ,p_attribute10_o                  in varchar2
  ,p_attribute11_o                  in varchar2
  ,p_attribute12_o                  in varchar2
  ,p_attribute13_o                  in varchar2
  ,p_attribute14_o                  in varchar2
  ,p_attribute15_o                  in varchar2
  ,p_attribute16_o                  in varchar2
  ,p_attribute17_o                  in varchar2
  ,p_attribute18_o                  in varchar2
  ,p_attribute19_o                  in varchar2
  ,p_attribute20_o                  in varchar2
  ,p_object_version_number_o        in number
  ,p_prior_employment_ssp_weeks_o   in number
  ,p_prior_employmt_ssp_paid_to_o   in date
  ,p_pds_information_category_o     in varchar2
  ,p_pds_information1_o             in varchar2
  ,p_pds_information2_o             in varchar2
  ,p_pds_information3_o             in varchar2
  ,p_pds_information4_o             in varchar2
  ,p_pds_information5_o             in varchar2
  ,p_pds_information6_o             in varchar2
  ,p_pds_information7_o             in varchar2
  ,p_pds_information8_o             in varchar2
  ,p_pds_information9_o             in varchar2
  ,p_pds_information10_o            in varchar2
  ,p_pds_information11_o            in varchar2
  ,p_pds_information12_o            in varchar2
  ,p_pds_information13_o            in varchar2
  ,p_pds_information14_o            in varchar2
  ,p_pds_information15_o            in varchar2
  ,p_pds_information16_o            in varchar2
  ,p_pds_information17_o            in varchar2
  ,p_pds_information18_o            in varchar2
  ,p_pds_information19_o            in varchar2
  ,p_pds_information20_o            in varchar2
  ,p_pds_information21_o            in varchar2
  ,p_pds_information22_o            in varchar2
  ,p_pds_information23_o            in varchar2
  ,p_pds_information24_o            in varchar2
  ,p_pds_information25_o            in varchar2
  ,p_pds_information26_o            in varchar2
  ,p_pds_information27_o            in varchar2
  ,p_pds_information28_o            in varchar2
  ,p_pds_information29_o            in varchar2
  ,p_pds_information30_o            in varchar2
   );
end per_pds_rku;

 

/
