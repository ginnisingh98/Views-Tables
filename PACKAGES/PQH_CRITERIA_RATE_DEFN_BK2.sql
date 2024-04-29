--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_DEFN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_DEFN_BK2" AUTHID CURRENT_USER as
/* $Header: pqcrdapi.pkh 120.6 2006/03/14 11:28:41 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_criteria_rate_defn_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_criteria_rate_defn_b
  (p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_business_group_id             in     number
  ,p_short_name		           in     varchar2
  ,p_uom                           in     varchar2
  ,p_currency_code		   in     varchar2
  ,p_reference_period_cd           in     varchar2
  ,p_define_max_rate_flag          in	  varchar2
  ,p_define_min_rate_flag          in	  varchar2
  ,p_define_mid_rate_flag          in	  varchar2
  ,p_define_std_rate_flag          in	  varchar2
  ,p_rate_calc_cd		   in     varchar2
  ,p_rate_calc_rule		   in     number
  ,p_preferential_rate_cd          in	  varchar2
  ,p_preferential_rate_rule        in 	  number
  ,p_rounding_cd                   in     varchar2
  ,p_rounding_rule		   in     number
  ,p_legislation_code 	           in     varchar2
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
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_criteria_rate_defn_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_criteria_rate_defn_a
  (p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_business_group_id             in     number
  ,p_short_name		           in     varchar2
  ,p_uom                           in     varchar2
  ,p_currency_code		   in     varchar2
  ,p_reference_period_cd           in     varchar2
  ,p_define_max_rate_flag          in	  varchar2
  ,p_define_min_rate_flag          in	  varchar2
  ,p_define_mid_rate_flag          in	  varchar2
  ,p_define_std_rate_flag          in	  varchar2
  ,p_rate_calc_cd		   in     varchar2
  ,p_rate_calc_rule		   in     number
  ,p_preferential_rate_cd          in	  varchar2
  ,p_preferential_rate_rule        in 	  number
  ,p_rounding_cd                   in     varchar2
  ,p_rounding_rule		   in     number
  ,p_legislation_code 	           in     varchar2
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
  ,p_object_version_number         in     number
  );
--
end pqh_criteria_rate_defn_bk2;

 

/
