--------------------------------------------------------
--  DDL for Package PER_PDS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PDS_RKD" AUTHID CURRENT_USER as
/* $Header: pepdsrhi.pkh 120.1 2006/02/21 03:11:57 pdkundu noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
-- employmt truncated from employment (p_prior_employmt_ssp_paid_to_o)
-- terminat trucated from termination (p_terminat_accepted_person_o)
--
procedure after_delete
  (
   p_period_of_service_id           in number
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
end per_pds_rkd;

 

/
