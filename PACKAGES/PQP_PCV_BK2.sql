--------------------------------------------------------
--  DDL for Package PQP_PCV_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_BK2" AUTHID CURRENT_USER as
/* $Header: pqpcvapi.pkh 120.1 2005/10/02 02:45:10 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_configuration_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_configuration_value_b
  (p_configuration_value_id         in     number
  ,p_effective_date                 in     date
  ,p_object_version_number          in     number
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_pcv_attribute_category         in     varchar2
  ,p_pcv_attribute1                 in     varchar2
  ,p_pcv_attribute2                 in     varchar2
  ,p_pcv_attribute3                 in     varchar2
  ,p_pcv_attribute4                 in     varchar2
  ,p_pcv_attribute5                 in     varchar2
  ,p_pcv_attribute6                 in     varchar2
  ,p_pcv_attribute7                 in     varchar2
  ,p_pcv_attribute8                 in     varchar2
  ,p_pcv_attribute9                 in     varchar2
  ,p_pcv_attribute10                in     varchar2
  ,p_pcv_attribute11                in     varchar2
  ,p_pcv_attribute12                in     varchar2
  ,p_pcv_attribute13                in     varchar2
  ,p_pcv_attribute14                in     varchar2
  ,p_pcv_attribute15                in     varchar2
  ,p_pcv_attribute16                in     varchar2
  ,p_pcv_attribute17                in     varchar2
  ,p_pcv_attribute18                in     varchar2
  ,p_pcv_attribute19                in     varchar2
  ,p_pcv_attribute20                in     varchar2
  ,p_pcv_information_category       in     varchar2
  ,p_pcv_information1               in     varchar2
  ,p_pcv_information2               in     varchar2
  ,p_pcv_information3               in     varchar2
  ,p_pcv_information4               in     varchar2
  ,p_pcv_information5               in     varchar2
  ,p_pcv_information6               in     varchar2
  ,p_pcv_information7               in     varchar2
  ,p_pcv_information8               in     varchar2
  ,p_pcv_information9               in     varchar2
  ,p_pcv_information10              in     varchar2
  ,p_pcv_information11              in     varchar2
  ,p_pcv_information12              in     varchar2
  ,p_pcv_information13              in     varchar2
  ,p_pcv_information14              in     varchar2
  ,p_pcv_information15              in     varchar2
  ,p_pcv_information16              in     varchar2
  ,p_pcv_information17              in     varchar2
  ,p_pcv_information18              in     varchar2
  ,p_pcv_information19              in     varchar2
  ,p_pcv_information20              in     varchar2
  ,p_configuration_name             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_configuration_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_configuration_value_a
  (p_configuration_value_id         in     number
  ,p_effective_date                 in     date
  ,p_object_version_number          in     number
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_pcv_attribute_category         in     varchar2
  ,p_pcv_attribute1                 in     varchar2
  ,p_pcv_attribute2                 in     varchar2
  ,p_pcv_attribute3                 in     varchar2
  ,p_pcv_attribute4                 in     varchar2
  ,p_pcv_attribute5                 in     varchar2
  ,p_pcv_attribute6                 in     varchar2
  ,p_pcv_attribute7                 in     varchar2
  ,p_pcv_attribute8                 in     varchar2
  ,p_pcv_attribute9                 in     varchar2
  ,p_pcv_attribute10                in     varchar2
  ,p_pcv_attribute11                in     varchar2
  ,p_pcv_attribute12                in     varchar2
  ,p_pcv_attribute13                in     varchar2
  ,p_pcv_attribute14                in     varchar2
  ,p_pcv_attribute15                in     varchar2
  ,p_pcv_attribute16                in     varchar2
  ,p_pcv_attribute17                in     varchar2
  ,p_pcv_attribute18                in     varchar2
  ,p_pcv_attribute19                in     varchar2
  ,p_pcv_attribute20                in     varchar2
  ,p_pcv_information_category       in     varchar2
  ,p_pcv_information1               in     varchar2
  ,p_pcv_information2               in     varchar2
  ,p_pcv_information3               in     varchar2
  ,p_pcv_information4               in     varchar2
  ,p_pcv_information5               in     varchar2
  ,p_pcv_information6               in     varchar2
  ,p_pcv_information7               in     varchar2
  ,p_pcv_information8               in     varchar2
  ,p_pcv_information9               in     varchar2
  ,p_pcv_information10              in     varchar2
  ,p_pcv_information11              in     varchar2
  ,p_pcv_information12              in     varchar2
  ,p_pcv_information13              in     varchar2
  ,p_pcv_information14              in     varchar2
  ,p_pcv_information15              in     varchar2
  ,p_pcv_information16              in     varchar2
  ,p_pcv_information17              in     varchar2
  ,p_pcv_information18              in     varchar2
  ,p_pcv_information19              in     varchar2
  ,p_pcv_information20              in     varchar2
  ,p_configuration_name             in     varchar2
  );
--
end pqp_pcv_bk2;

 

/
