--------------------------------------------------------
--  DDL for Package PER_PJU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJU_RKI" AUTHID CURRENT_USER as
/* $Header: pepjurhi.pkh 120.0 2005/05/31 14:24:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_previous_job_usage_id        in number
  ,p_assignment_id                in number
  ,p_previous_employer_id         in number
  ,p_previous_job_id              in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_period_years                 in number
  ,p_period_months                in number
  ,p_period_days                  in number
  ,p_pju_attribute_category       in varchar2
  ,p_pju_attribute1               in varchar2
  ,p_pju_attribute2               in varchar2
  ,p_pju_attribute3               in varchar2
  ,p_pju_attribute4               in varchar2
  ,p_pju_attribute5               in varchar2
  ,p_pju_attribute6               in varchar2
  ,p_pju_attribute7               in varchar2
  ,p_pju_attribute8               in varchar2
  ,p_pju_attribute9               in varchar2
  ,p_pju_attribute10              in varchar2
  ,p_pju_attribute11              in varchar2
  ,p_pju_attribute12              in varchar2
  ,p_pju_attribute13              in varchar2
  ,p_pju_attribute14              in varchar2
  ,p_pju_attribute15              in varchar2
  ,p_pju_attribute16              in varchar2
  ,p_pju_attribute17              in varchar2
  ,p_pju_attribute18              in varchar2
  ,p_pju_attribute19              in varchar2
  ,p_pju_attribute20              in varchar2
  ,p_pju_information_category     in varchar2
  ,p_pju_information1             in varchar2
  ,p_pju_information2             in varchar2
  ,p_pju_information3             in varchar2
  ,p_pju_information4             in varchar2
  ,p_pju_information5             in varchar2
  ,p_pju_information6             in varchar2
  ,p_pju_information7             in varchar2
  ,p_pju_information8             in varchar2
  ,p_pju_information9             in varchar2
  ,p_pju_information10            in varchar2
  ,p_pju_information11            in varchar2
  ,p_pju_information12            in varchar2
  ,p_pju_information13            in varchar2
  ,p_pju_information14            in varchar2
  ,p_pju_information15            in varchar2
  ,p_pju_information16            in varchar2
  ,p_pju_information17            in varchar2
  ,p_pju_information18            in varchar2
  ,p_pju_information19            in varchar2
  ,p_pju_information20            in varchar2
  ,p_object_version_number        in number
  );
end per_pju_rki;

 

/
