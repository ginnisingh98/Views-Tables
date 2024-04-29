--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BKA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BKA" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
--
-- -----------------------------------------------------------------------
-- |-------------------------< create_prev_job_extra_info_b >------------|
-- -----------------------------------------------------------------------
--
procedure create_prev_job_extra_info_b
  (p_previous_job_id                in  number
  ,p_information_type               in  varchar2
  ,p_pji_attribute_category         in  varchar2
  ,p_pji_attribute1                 in  varchar2
  ,p_pji_attribute2                 in  varchar2
  ,p_pji_attribute3                 in  varchar2
  ,p_pji_attribute4                 in  varchar2
  ,p_pji_attribute5                 in  varchar2
  ,p_pji_attribute6                 in  varchar2
  ,p_pji_attribute7                 in  varchar2
  ,p_pji_attribute8                 in  varchar2
  ,p_pji_attribute9                 in  varchar2
  ,p_pji_attribute10                in  varchar2
  ,p_pji_attribute11                in  varchar2
  ,p_pji_attribute12                in  varchar2
  ,p_pji_attribute13                in  varchar2
  ,p_pji_attribute14                in  varchar2
  ,p_pji_attribute15                in  varchar2
  ,p_pji_attribute16                in  varchar2
  ,p_pji_attribute17                in  varchar2
  ,p_pji_attribute18                in  varchar2
  ,p_pji_attribute19                in  varchar2
  ,p_pji_attribute20                in  varchar2
  ,p_pji_attribute21                in  varchar2
  ,p_pji_attribute22                in  varchar2
  ,p_pji_attribute23                in  varchar2
  ,p_pji_attribute24                in  varchar2
  ,p_pji_attribute25                in  varchar2
  ,p_pji_attribute26                in  varchar2
  ,p_pji_attribute27                in  varchar2
  ,p_pji_attribute28                in  varchar2
  ,p_pji_attribute29                in  varchar2
  ,p_pji_attribute30                in  varchar2
  ,p_pji_information_category       in  varchar2
  ,p_pji_information1               in  varchar2
  ,p_pji_information2               in  varchar2
  ,p_pji_information3               in  varchar2
  ,p_pji_information4               in  varchar2
  ,p_pji_information5               in  varchar2
  ,p_pji_information6               in  varchar2
  ,p_pji_information7               in  varchar2
  ,p_pji_information8               in  varchar2
  ,p_pji_information9               in  varchar2
  ,p_pji_information10              in  varchar2
  ,p_pji_information11              in  varchar2
  ,p_pji_information12              in  varchar2
  ,p_pji_information13              in  varchar2
  ,p_pji_information14              in  varchar2
  ,p_pji_information15              in  varchar2
  ,p_pji_information16              in  varchar2
  ,p_pji_information17              in  varchar2
  ,p_pji_information18              in  varchar2
  ,p_pji_information19              in  varchar2
  ,p_pji_information20              in  varchar2
  ,p_pji_information21              in  varchar2
  ,p_pji_information22              in  varchar2
  ,p_pji_information23              in  varchar2
  ,p_pji_information24              in  varchar2
  ,p_pji_information25              in  varchar2
  ,p_pji_information26              in  varchar2
  ,p_pji_information27              in  varchar2
  ,p_pji_information28              in  varchar2
  ,p_pji_information29              in  varchar2
  ,p_pji_information30              in  varchar2
  ,p_object_version_number          in  number
  );
--
-- -----------------------------------------------------------------------
-- |-------------------------< create_prev_job_extra_info_a >------------|
-- -----------------------------------------------------------------------
--
procedure create_prev_job_extra_info_a
  (p_previous_job_extra_info_id     in  number
  ,p_previous_job_id                in  number
  ,p_information_type               in  varchar2
  ,p_pji_attribute_category         in  varchar2
  ,p_pji_attribute1                 in  varchar2
  ,p_pji_attribute2                 in  varchar2
  ,p_pji_attribute3                 in  varchar2
  ,p_pji_attribute4                 in  varchar2
  ,p_pji_attribute5                 in  varchar2
  ,p_pji_attribute6                 in  varchar2
  ,p_pji_attribute7                 in  varchar2
  ,p_pji_attribute8                 in  varchar2
  ,p_pji_attribute9                 in  varchar2
  ,p_pji_attribute10                in  varchar2
  ,p_pji_attribute11                in  varchar2
  ,p_pji_attribute12                in  varchar2
  ,p_pji_attribute13                in  varchar2
  ,p_pji_attribute14                in  varchar2
  ,p_pji_attribute15                in  varchar2
  ,p_pji_attribute16                in  varchar2
  ,p_pji_attribute17                in  varchar2
  ,p_pji_attribute18                in  varchar2
  ,p_pji_attribute19                in  varchar2
  ,p_pji_attribute20                in  varchar2
  ,p_pji_attribute21                in  varchar2
  ,p_pji_attribute22                in  varchar2
  ,p_pji_attribute23                in  varchar2
  ,p_pji_attribute24                in  varchar2
  ,p_pji_attribute25                in  varchar2
  ,p_pji_attribute26                in  varchar2
  ,p_pji_attribute27                in  varchar2
  ,p_pji_attribute28                in  varchar2
  ,p_pji_attribute29                in  varchar2
  ,p_pji_attribute30                in  varchar2
  ,p_pji_information_category       in  varchar2
  ,p_pji_information1               in  varchar2
  ,p_pji_information2               in  varchar2
  ,p_pji_information3               in  varchar2
  ,p_pji_information4               in  varchar2
  ,p_pji_information5               in  varchar2
  ,p_pji_information6               in  varchar2
  ,p_pji_information7               in  varchar2
  ,p_pji_information8               in  varchar2
  ,p_pji_information9               in  varchar2
  ,p_pji_information10              in  varchar2
  ,p_pji_information11              in  varchar2
  ,p_pji_information12              in  varchar2
  ,p_pji_information13              in  varchar2
  ,p_pji_information14              in  varchar2
  ,p_pji_information15              in  varchar2
  ,p_pji_information16              in  varchar2
  ,p_pji_information17              in  varchar2
  ,p_pji_information18              in  varchar2
  ,p_pji_information19              in  varchar2
  ,p_pji_information20              in  varchar2
  ,p_pji_information21              in  varchar2
  ,p_pji_information22              in  varchar2
  ,p_pji_information23              in  varchar2
  ,p_pji_information24              in  varchar2
  ,p_pji_information25              in  varchar2
  ,p_pji_information26              in  varchar2
  ,p_pji_information27              in  varchar2
  ,p_pji_information28              in  varchar2
  ,p_pji_information29              in  varchar2
  ,p_pji_information30              in  varchar2
  ,p_object_version_number          in  number
  );
--
end hr_previous_employment_bka;

/
