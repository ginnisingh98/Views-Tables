--------------------------------------------------------
--  DDL for Package PER_PDS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PDS_RKI" AUTHID CURRENT_USER as
/* $Header: pepdsrhi.pkh 120.1 2006/02/21 03:11:57 pdkundu noship $ */
--
-- ------------------------------------------------------------------------------
-- |---------------------------------< after_insert >-----------------------------|
-- ------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- This procedure is for the row handler user hook. The package body is generated.
--
--
  procedure after_insert
  (
   p_period_of_service_id         in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_date_start                   in date
  ,p_comments                     in varchar2
  ,p_adjusted_svc_date            in date
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
  );
end per_pds_rki;

 

/
