--------------------------------------------------------
--  DDL for Package OTA_TMT_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TMT_API_BK1" AUTHID CURRENT_USER as
/* $Header: ottmtapi.pkh 120.1 2005/10/02 02:08:25 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_measure_b >------------------------------|
-- ----------------------------------------------------------------------------
procedure create_measure_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_code           in     varchar2
  ,p_unit                          in     varchar2
  ,p_budget_level                  in     varchar2
  ,p_cost_level                    in     varchar2
  ,p_many_budget_values_flag       in     varchar2
  ,p_reporting_sequence            in     number
  ,p_item_type_usage_id            in     number
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_measure_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_measure_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_code           in     varchar2
  ,p_unit                          in     varchar2
  ,p_budget_level                  in     varchar2
  ,p_cost_level                    in     varchar2
  ,p_many_budget_values_flag       in     varchar2
  ,p_reporting_sequence            in     number
  ,p_item_type_usage_id            in     number
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
  ,p_tp_measurement_type_id        in     number
  ,p_object_version_number         in     number
  );
end ota_tmt_api_BK1;

 

/
