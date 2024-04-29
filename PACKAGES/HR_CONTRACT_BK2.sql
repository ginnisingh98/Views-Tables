--------------------------------------------------------
--  DDL for Package HR_CONTRACT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTRACT_BK2" AUTHID CURRENT_USER as
/* $Header: hrctcapi.pkh 120.1 2005/10/02 02:01:33 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_contract_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_contract_b
  (
   p_contract_id                    in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_person_id                      in  number
  ,p_reference                      in  varchar2
  ,p_type                           in  varchar2
  ,p_status                         in  varchar2
  ,p_status_reason                  in  varchar2
  ,p_doc_status                     in  varchar2
  ,p_doc_status_change_date         in  date
  ,p_description                    in  varchar2
  ,p_duration                       in  number
  ,p_duration_units                 in  varchar2
  ,p_contractual_job_title          in  varchar2
  ,p_parties                        in  varchar2
  ,p_start_reason                   in  varchar2
  ,p_end_reason                     in  varchar2
  ,p_number_of_extensions           in  number
  ,p_extension_reason               in  varchar2
  ,p_extension_period               in  number
  ,p_extension_period_units         in  varchar2
  ,p_ctr_information_category       in  varchar2
  ,p_ctr_information1               in  varchar2
  ,p_ctr_information2               in  varchar2
  ,p_ctr_information3               in  varchar2
  ,p_ctr_information4               in  varchar2
  ,p_ctr_information5               in  varchar2
  ,p_ctr_information6               in  varchar2
  ,p_ctr_information7               in  varchar2
  ,p_ctr_information8               in  varchar2
  ,p_ctr_information9               in  varchar2
  ,p_ctr_information10              in  varchar2
  ,p_ctr_information11              in  varchar2
  ,p_ctr_information12              in  varchar2
  ,p_ctr_information13              in  varchar2
  ,p_ctr_information14              in  varchar2
  ,p_ctr_information15              in  varchar2
  ,p_ctr_information16              in  varchar2
  ,p_ctr_information17              in  varchar2
  ,p_ctr_information18              in  varchar2
  ,p_ctr_information19              in  varchar2
  ,p_ctr_information20              in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_contract_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_contract_a
  (
   p_contract_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_person_id                      in  number
  ,p_reference                      in  varchar2
  ,p_type                           in  varchar2
  ,p_status                         in  varchar2
  ,p_status_reason                  in  varchar2
  ,p_doc_status                     in  varchar2
  ,p_doc_status_change_date         in  date
  ,p_description                    in  varchar2
  ,p_duration                       in  number
  ,p_duration_units                 in  varchar2
  ,p_contractual_job_title          in  varchar2
  ,p_parties                        in  varchar2
  ,p_start_reason                   in  varchar2
  ,p_end_reason                     in  varchar2
  ,p_number_of_extensions           in  number
  ,p_extension_reason               in  varchar2
  ,p_extension_period               in  number
  ,p_extension_period_units         in  varchar2
  ,p_ctr_information_category       in  varchar2
  ,p_ctr_information1               in  varchar2
  ,p_ctr_information2               in  varchar2
  ,p_ctr_information3               in  varchar2
  ,p_ctr_information4               in  varchar2
  ,p_ctr_information5               in  varchar2
  ,p_ctr_information6               in  varchar2
  ,p_ctr_information7               in  varchar2
  ,p_ctr_information8               in  varchar2
  ,p_ctr_information9               in  varchar2
  ,p_ctr_information10              in  varchar2
  ,p_ctr_information11              in  varchar2
  ,p_ctr_information12              in  varchar2
  ,p_ctr_information13              in  varchar2
  ,p_ctr_information14              in  varchar2
  ,p_ctr_information15              in  varchar2
  ,p_ctr_information16              in  varchar2
  ,p_ctr_information17              in  varchar2
  ,p_ctr_information18              in  varchar2
  ,p_ctr_information19              in  varchar2
  ,p_ctr_information20              in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end hr_contract_bk2;

 

/
