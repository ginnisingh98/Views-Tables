--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BK8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BK8" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
-- -----------------------------------------------------------------------
-- |-------------------------< update_previous_job_usage_b >-------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_job_usage_b
  (p_assignment_id                  in  number
  ,p_previous_employer_id           in  number
  ,p_previous_job_id                in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_period_years                   in  number
  ,p_period_months                  in  number
  ,p_period_days                    in  number
  ,p_pju_attribute_category         in  varchar2
  ,p_pju_attribute1                 in  varchar2
  ,p_pju_attribute2                 in  varchar2
  ,p_pju_attribute3                 in  varchar2
  ,p_pju_attribute4                 in  varchar2
  ,p_pju_attribute5                 in  varchar2
  ,p_pju_attribute6                 in  varchar2
  ,p_pju_attribute7                 in  varchar2
  ,p_pju_attribute8                 in  varchar2
  ,p_pju_attribute9                 in  varchar2
  ,p_pju_attribute10                in  varchar2
  ,p_pju_attribute11                in  varchar2
  ,p_pju_attribute12                in  varchar2
  ,p_pju_attribute13                in  varchar2
  ,p_pju_attribute14                in  varchar2
  ,p_pju_attribute15                in  varchar2
  ,p_pju_attribute16                in  varchar2
  ,p_pju_attribute17                in  varchar2
  ,p_pju_attribute18                in  varchar2
  ,p_pju_attribute19                in  varchar2
  ,p_pju_attribute20                in  varchar2
  ,p_pju_information_category       in  varchar2
  ,p_pju_information1               in  varchar2
  ,p_pju_information2               in  varchar2
  ,p_pju_information3               in  varchar2
  ,p_pju_information4               in  varchar2
  ,p_pju_information5               in  varchar2
  ,p_pju_information6               in  varchar2
  ,p_pju_information7               in  varchar2
  ,p_pju_information8               in  varchar2
  ,p_pju_information9               in  varchar2
  ,p_pju_information10              in  varchar2
  ,p_pju_information11              in  varchar2
  ,p_pju_information12              in  varchar2
  ,p_pju_information13              in  varchar2
  ,p_pju_information14              in  varchar2
  ,p_pju_information15              in  varchar2
  ,p_pju_information16              in  varchar2
  ,p_pju_information17              in  varchar2
  ,p_pju_information18              in  varchar2
  ,p_pju_information19              in  varchar2
  ,p_pju_information20              in  varchar2
  ,p_previous_job_usage_id          in  number
  ,p_object_version_number          in  number
  );
--
-- -----------------------------------------------------------------------
-- |------------------------< update_previous_job_usage_a >--------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_job_usage_a
  (p_assignment_id                  in  number
  ,p_previous_employer_id           in  number
  ,p_previous_job_id                in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_period_years                   in  number
  ,p_period_months                  in  number
  ,p_period_days                    in  number
  ,p_pju_attribute_category         in  varchar2
  ,p_pju_attribute1                 in  varchar2
  ,p_pju_attribute2                 in  varchar2
  ,p_pju_attribute3                 in  varchar2
  ,p_pju_attribute4                 in  varchar2
  ,p_pju_attribute5                 in  varchar2
  ,p_pju_attribute6                 in  varchar2
  ,p_pju_attribute7                 in  varchar2
  ,p_pju_attribute8                 in  varchar2
  ,p_pju_attribute9                 in  varchar2
  ,p_pju_attribute10                in  varchar2
  ,p_pju_attribute11                in  varchar2
  ,p_pju_attribute12                in  varchar2
  ,p_pju_attribute13                in  varchar2
  ,p_pju_attribute14                in  varchar2
  ,p_pju_attribute15                in  varchar2
  ,p_pju_attribute16                in  varchar2
  ,p_pju_attribute17                in  varchar2
  ,p_pju_attribute18                in  varchar2
  ,p_pju_attribute19                in  varchar2
  ,p_pju_attribute20                in  varchar2
  ,p_pju_information_category       in  varchar2
  ,p_pju_information1               in  varchar2
  ,p_pju_information2               in  varchar2
  ,p_pju_information3               in  varchar2
  ,p_pju_information4               in  varchar2
  ,p_pju_information5               in  varchar2
  ,p_pju_information6               in  varchar2
  ,p_pju_information7               in  varchar2
  ,p_pju_information8               in  varchar2
  ,p_pju_information9               in  varchar2
  ,p_pju_information10              in  varchar2
  ,p_pju_information11              in  varchar2
  ,p_pju_information12              in  varchar2
  ,p_pju_information13              in  varchar2
  ,p_pju_information14              in  varchar2
  ,p_pju_information15              in  varchar2
  ,p_pju_information16              in  varchar2
  ,p_pju_information17              in  varchar2
  ,p_pju_information18              in  varchar2
  ,p_pju_information19              in  varchar2
  ,p_pju_information20              in  varchar2
  ,p_previous_job_usage_id          in  number
  ,p_object_version_number          in  number
  );
--
end hr_previous_employment_bk8;

/
