--------------------------------------------------------
--  DDL for Package OTA_TPC_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPC_API_BK1" AUTHID CURRENT_USER as
/* $Header: ottpcapi.pkh 120.1 2005/10/02 02:08:30 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cost_b >---------------------------------|
-- ----------------------------------------------------------------------------
procedure create_cost_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_type_id        in     number
  ,p_training_plan_id              in     number
  ,p_amount                        in     number
  ,p_booking_id                    in     number
  ,p_event_id                      in     number
  ,p_currency_code                 in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_information_category          in     varchar2
  ,p_tp_cost_information1          in     varchar2
  ,p_tp_cost_information2          in     varchar2
  ,p_tp_cost_information3          in     varchar2
  ,p_tp_cost_information4          in     varchar2
  ,p_tp_cost_information5          in     varchar2
  ,p_tp_cost_information6          in     varchar2
  ,p_tp_cost_information7          in     varchar2
  ,p_tp_cost_information8          in     varchar2
  ,p_tp_cost_information9          in     varchar2
  ,p_tp_cost_information10         in     varchar2
  ,p_tp_cost_information11         in     varchar2
  ,p_tp_cost_information12         in     varchar2
  ,p_tp_cost_information13         in     varchar2
  ,p_tp_cost_information14         in     varchar2
  ,p_tp_cost_information15         in     varchar2
  ,p_tp_cost_information16         in     varchar2
  ,p_tp_cost_information17         in     varchar2
  ,p_tp_cost_information18         in     varchar2
  ,p_tp_cost_information19         in     varchar2
  ,p_tp_cost_information20         in     varchar2
  ,p_tp_cost_information21         in     varchar2
  ,p_tp_cost_information22         in     varchar2
  ,p_tp_cost_information23         in     varchar2
  ,p_tp_cost_information24         in     varchar2
  ,p_tp_cost_information25         in     varchar2
  ,p_tp_cost_information26         in     varchar2
  ,p_tp_cost_information27         in     varchar2
  ,p_tp_cost_information28         in     varchar2
  ,p_tp_cost_information29         in     varchar2
  ,p_tp_cost_information30         in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cost_a >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cost_a
  (p_effective_date                in     date
  ,p_training_plan_cost_id         in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_tp_measurement_type_id        in     number
  ,p_training_plan_id              in     number
  ,p_amount                        in     number
  ,p_booking_id                    in     number
  ,p_event_id                      in     number
  ,p_currency_code                 in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_information_category          in     varchar2
  ,p_tp_cost_information1          in     varchar2
  ,p_tp_cost_information2          in     varchar2
  ,p_tp_cost_information3          in     varchar2
  ,p_tp_cost_information4          in     varchar2
  ,p_tp_cost_information5          in     varchar2
  ,p_tp_cost_information6          in     varchar2
  ,p_tp_cost_information7          in     varchar2
  ,p_tp_cost_information8          in     varchar2
  ,p_tp_cost_information9          in     varchar2
  ,p_tp_cost_information10         in     varchar2
  ,p_tp_cost_information11         in     varchar2
  ,p_tp_cost_information12         in     varchar2
  ,p_tp_cost_information13         in     varchar2
  ,p_tp_cost_information14         in     varchar2
  ,p_tp_cost_information15         in     varchar2
  ,p_tp_cost_information16         in     varchar2
  ,p_tp_cost_information17         in     varchar2
  ,p_tp_cost_information18         in     varchar2
  ,p_tp_cost_information19         in     varchar2
  ,p_tp_cost_information20         in     varchar2
  ,p_tp_cost_information21         in     varchar2
  ,p_tp_cost_information22         in     varchar2
  ,p_tp_cost_information23         in     varchar2
  ,p_tp_cost_information24         in     varchar2
  ,p_tp_cost_information25         in     varchar2
  ,p_tp_cost_information26         in     varchar2
  ,p_tp_cost_information27         in     varchar2
  ,p_tp_cost_information28         in     varchar2
  ,p_tp_cost_information29         in     varchar2
  ,p_tp_cost_information30         in     varchar2
  );
end ota_tpc_api_BK1;

 

/
