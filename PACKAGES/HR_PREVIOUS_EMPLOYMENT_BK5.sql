--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BK5" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
-- -----------------------------------------------------------------------
-- |-------------------------< update_previous_job_b >-------------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_job_b
  (p_effective_date                 in     date
  ,p_previous_job_id                in     number
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_period_years                   in     number
  ,p_period_months                  in     number
  ,p_period_days                    in     number
  ,p_job_name                       in     varchar2
  ,p_employment_category            in     varchar2
  ,p_description                    in     varchar2
  ,p_all_assignments                in     varchar2
  ,p_pjo_attribute_category         in     varchar2
  ,p_pjo_attribute1                 in     varchar2
  ,p_pjo_attribute2                 in     varchar2
  ,p_pjo_attribute3                 in     varchar2
  ,p_pjo_attribute4                 in     varchar2
  ,p_pjo_attribute5                 in     varchar2
  ,p_pjo_attribute6                 in     varchar2
  ,p_pjo_attribute7                 in     varchar2
  ,p_pjo_attribute8                 in     varchar2
  ,p_pjo_attribute9                 in     varchar2
  ,p_pjo_attribute10                in     varchar2
  ,p_pjo_attribute11                in     varchar2
  ,p_pjo_attribute12                in     varchar2
  ,p_pjo_attribute13                in     varchar2
  ,p_pjo_attribute14                in     varchar2
  ,p_pjo_attribute15                in     varchar2
  ,p_pjo_attribute16                in     varchar2
  ,p_pjo_attribute17                in     varchar2
  ,p_pjo_attribute18                in     varchar2
  ,p_pjo_attribute19                in     varchar2
  ,p_pjo_attribute20                in     varchar2
  ,p_pjo_attribute21                in     varchar2
  ,p_pjo_attribute22                in     varchar2
  ,p_pjo_attribute23                in     varchar2
  ,p_pjo_attribute24                in     varchar2
  ,p_pjo_attribute25                in     varchar2
  ,p_pjo_attribute26                in     varchar2
  ,p_pjo_attribute27                in     varchar2
  ,p_pjo_attribute28                in     varchar2
  ,p_pjo_attribute29                in     varchar2
  ,p_pjo_attribute30                in     varchar2
  ,p_pjo_information_category       in     varchar2
  ,p_pjo_information1               in     varchar2
  ,p_pjo_information2               in     varchar2
  ,p_pjo_information3               in     varchar2
  ,p_pjo_information4               in     varchar2
  ,p_pjo_information5               in     varchar2
  ,p_pjo_information6               in     varchar2
  ,p_pjo_information7               in     varchar2
  ,p_pjo_information8               in     varchar2
  ,p_pjo_information9               in     varchar2
  ,p_pjo_information10              in     varchar2
  ,p_pjo_information11              in     varchar2
  ,p_pjo_information12              in     varchar2
  ,p_pjo_information13              in     varchar2
  ,p_pjo_information14              in     varchar2
  ,p_pjo_information15              in     varchar2
  ,p_pjo_information16              in     varchar2
  ,p_pjo_information17              in     varchar2
  ,p_pjo_information18              in     varchar2
  ,p_pjo_information19              in     varchar2
  ,p_pjo_information20              in     varchar2
  ,p_pjo_information21              in     varchar2
  ,p_pjo_information22              in     varchar2
  ,p_pjo_information23              in     varchar2
  ,p_pjo_information24              in     varchar2
  ,p_pjo_information25              in     varchar2
  ,p_pjo_information26              in     varchar2
  ,p_pjo_information27              in     varchar2
  ,p_pjo_information28              in     varchar2
  ,p_pjo_information29              in     varchar2
  ,p_pjo_information30              in     varchar2
  ,p_object_version_number          in     number
  );
--
-- -----------------------------------------------------------------------
-- |-------------------------< update_previous_job_a >-------------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_job_a
  (p_effective_date                 in     date
  ,p_previous_job_id                in     number
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_period_years                   in     number
  ,p_period_months                  in     number
  ,p_period_days                    in     number
  ,p_job_name                       in     varchar2
  ,p_employment_category            in     varchar2
  ,p_description                    in     varchar2
  ,p_all_assignments                in     varchar2
  ,p_pjo_attribute_category         in     varchar2
  ,p_pjo_attribute1                 in     varchar2
  ,p_pjo_attribute2                 in     varchar2
  ,p_pjo_attribute3                 in     varchar2
  ,p_pjo_attribute4                 in     varchar2
  ,p_pjo_attribute5                 in     varchar2
  ,p_pjo_attribute6                 in     varchar2
  ,p_pjo_attribute7                 in     varchar2
  ,p_pjo_attribute8                 in     varchar2
  ,p_pjo_attribute9                 in     varchar2
  ,p_pjo_attribute10                in     varchar2
  ,p_pjo_attribute11                in     varchar2
  ,p_pjo_attribute12                in     varchar2
  ,p_pjo_attribute13                in     varchar2
  ,p_pjo_attribute14                in     varchar2
  ,p_pjo_attribute15                in     varchar2
  ,p_pjo_attribute16                in     varchar2
  ,p_pjo_attribute17                in     varchar2
  ,p_pjo_attribute18                in     varchar2
  ,p_pjo_attribute19                in     varchar2
  ,p_pjo_attribute20                in     varchar2
  ,p_pjo_attribute21                in     varchar2
  ,p_pjo_attribute22                in     varchar2
  ,p_pjo_attribute23                in     varchar2
  ,p_pjo_attribute24                in     varchar2
  ,p_pjo_attribute25                in     varchar2
  ,p_pjo_attribute26                in     varchar2
  ,p_pjo_attribute27                in     varchar2
  ,p_pjo_attribute28                in     varchar2
  ,p_pjo_attribute29                in     varchar2
  ,p_pjo_attribute30                in     varchar2
  ,p_pjo_information_category       in     varchar2
  ,p_pjo_information1               in     varchar2
  ,p_pjo_information2               in     varchar2
  ,p_pjo_information3               in     varchar2
  ,p_pjo_information4               in     varchar2
  ,p_pjo_information5               in     varchar2
  ,p_pjo_information6               in     varchar2
  ,p_pjo_information7               in     varchar2
  ,p_pjo_information8               in     varchar2
  ,p_pjo_information9               in     varchar2
  ,p_pjo_information10              in     varchar2
  ,p_pjo_information11              in     varchar2
  ,p_pjo_information12              in     varchar2
  ,p_pjo_information13              in     varchar2
  ,p_pjo_information14              in     varchar2
  ,p_pjo_information15              in     varchar2
  ,p_pjo_information16              in     varchar2
  ,p_pjo_information17              in     varchar2
  ,p_pjo_information18              in     varchar2
  ,p_pjo_information19              in     varchar2
  ,p_pjo_information20              in     varchar2
  ,p_pjo_information21              in     varchar2
  ,p_pjo_information22              in     varchar2
  ,p_pjo_information23              in     varchar2
  ,p_pjo_information24              in     varchar2
  ,p_pjo_information25              in     varchar2
  ,p_pjo_information26              in     varchar2
  ,p_pjo_information27              in     varchar2
  ,p_pjo_information28              in     varchar2
  ,p_pjo_information29              in     varchar2
  ,p_pjo_information30              in     varchar2
  ,p_object_version_number          in     number
  );
--
end hr_previous_employment_bk5;

/
