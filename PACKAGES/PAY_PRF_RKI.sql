--------------------------------------------------------
--  DDL for Package PAY_PRF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRF_RKI" AUTHID CURRENT_USER as
/* $Header: pyprfrhi.pkh 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_range_table_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_range_table_number           in number
  ,p_row_value_uom                in varchar2
  ,p_period_frequency             in varchar2
  ,p_earnings_type                in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_last_updated_login           in number
  ,p_created_date                 in date
  ,p_object_version_number        in number
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
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_ran_information_category     in varchar2
  ,p_ran_information1             in varchar2
  ,p_ran_information2             in varchar2
  ,p_ran_information3             in varchar2
  ,p_ran_information4             in varchar2
  ,p_ran_information5             in varchar2
  ,p_ran_information6             in varchar2
  ,p_ran_information7             in varchar2
  ,p_ran_information8             in varchar2
  ,p_ran_information9             in varchar2
  ,p_ran_information10            in varchar2
  ,p_ran_information11            in varchar2
  ,p_ran_information12            in varchar2
  ,p_ran_information13            in varchar2
  ,p_ran_information14            in varchar2
  ,p_ran_information15            in varchar2
  ,p_ran_information16            in varchar2
  ,p_ran_information17            in varchar2
  ,p_ran_information18            in varchar2
  ,p_ran_information19            in varchar2
  ,p_ran_information20            in varchar2
  ,p_ran_information21            in varchar2
  ,p_ran_information22            in varchar2
  ,p_ran_information23            in varchar2
  ,p_ran_information24            in varchar2
  ,p_ran_information25            in varchar2
  ,p_ran_information26            in varchar2
  ,p_ran_information27            in varchar2
  ,p_ran_information28            in varchar2
  ,p_ran_information29            in varchar2
  ,p_ran_information30            in varchar2
  );
end pay_prf_rki;

 

/
