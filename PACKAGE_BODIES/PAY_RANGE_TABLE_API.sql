--------------------------------------------------------
--  DDL for Package Body PAY_RANGE_TABLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RANGE_TABLE_API" as
/* $Header: pyprfapi.pkb 120.0 2005/05/29 07:48:44 appldev noship $ */

procedure create_range_table
(
 p_EFFECTIVE_START_DATE                    in DATE default NULL
,p_EFFECTIVE_END_DATE                      in DATE default NULL
,p_RANGE_TABLE_NUMBER                      in NUMBER default NULL
,p_ROW_VALUE_UOM                           in VARCHAR2 default NULL
,p_PERIOD_FREQUENCY                        in VARCHAR2 default NULL
,p_EARNINGS_TYPE                           in VARCHAR2 default NULL
,p_BUSINESS_GROUP_ID                       in NUMBER default NULL
,p_LEGISLATION_CODE                        in VARCHAR2 default NULL
,p_ATTRIBUTE_CATEGORY                      in VARCHAR2 default NULL
,p_ATTRIBUTE1                              in VARCHAR2 default NULL
,p_ATTRIBUTE2                              in VARCHAR2 default NULL
,p_ATTRIBUTE3                              in VARCHAR2 default NULL
,p_ATTRIBUTE4                              in VARCHAR2 default NULL
,p_ATTRIBUTE5                              in VARCHAR2 default NULL
,p_ATTRIBUTE6                              in VARCHAR2 default NULL
,p_ATTRIBUTE7                              in VARCHAR2 default NULL
,p_ATTRIBUTE8                              in VARCHAR2 default NULL
,p_ATTRIBUTE9                              in VARCHAR2 default NULL
,p_ATTRIBUTE10                             in VARCHAR2 default NULL
,p_ATTRIBUTE11                             in VARCHAR2 default NULL
,p_ATTRIBUTE12                             in VARCHAR2 default NULL
,p_ATTRIBUTE13                             in VARCHAR2 default NULL
,p_ATTRIBUTE14                             in VARCHAR2 default NULL
,p_ATTRIBUTE15                             in VARCHAR2 default NULL
,p_ATTRIBUTE16                             in VARCHAR2 default NULL
,p_ATTRIBUTE17                             in VARCHAR2 default NULL
,p_ATTRIBUTE18                             in VARCHAR2 default NULL
,p_ATTRIBUTE19                             in VARCHAR2 default NULL
,p_ATTRIBUTE20                             in VARCHAR2 default NULL
,p_ATTRIBUTE21                             in VARCHAR2 default NULL
,p_ATTRIBUTE22                             in VARCHAR2 default NULL
,p_ATTRIBUTE23                             in VARCHAR2 default NULL
,p_ATTRIBUTE24                             in VARCHAR2 default NULL
,p_ATTRIBUTE25                             in VARCHAR2 default NULL
,p_ATTRIBUTE26                             in VARCHAR2 default NULL
,p_ATTRIBUTE27                             in VARCHAR2 default NULL
,p_ATTRIBUTE28                             in VARCHAR2 default NULL
,p_ATTRIBUTE29                             in VARCHAR2 default NULL
,p_ATTRIBUTE30                             in VARCHAR2 default NULL
,p_RAN_INFORMATION_CATEGORY                in VARCHAR2 default NULL
,p_RAN_INFORMATION1                        in VARCHAR2 default NULL
,p_RAN_INFORMATION2                        in VARCHAR2 default NULL
,p_RAN_INFORMATION3                        in VARCHAR2 default NULL
,p_RAN_INFORMATION4                        in VARCHAR2 default NULL
,p_RAN_INFORMATION5                        in VARCHAR2 default NULL
,p_RAN_INFORMATION6                        in VARCHAR2 default NULL
,p_RAN_INFORMATION7                        in VARCHAR2 default NULL
,p_RAN_INFORMATION8                        in VARCHAR2 default NULL
,p_RAN_INFORMATION9                        in VARCHAR2 default NULL
,p_RAN_INFORMATION10                       in VARCHAR2 default NULL
,p_RAN_INFORMATION11                       in VARCHAR2 default NULL
,p_RAN_INFORMATION12                       in VARCHAR2 default NULL
,p_RAN_INFORMATION13                       in VARCHAR2 default NULL
,p_RAN_INFORMATION14                       in VARCHAR2 default NULL
,p_RAN_INFORMATION15                       in VARCHAR2 default NULL
,p_RAN_INFORMATION16                       in VARCHAR2 default NULL
,p_RAN_INFORMATION17                       in VARCHAR2 default NULL
,p_RAN_INFORMATION18                       in VARCHAR2 default NULL
,p_RAN_INFORMATION19                       in VARCHAR2 default NULL
,p_RAN_INFORMATION20                       in VARCHAR2 default NULL
,p_RAN_INFORMATION21                       in VARCHAR2 default NULL
,p_RAN_INFORMATION22                       in VARCHAR2 default NULL
,p_RAN_INFORMATION23                       in VARCHAR2 default NULL
,p_RAN_INFORMATION24                       in VARCHAR2 default NULL
,p_RAN_INFORMATION25                       in VARCHAR2 default NULL
,p_RAN_INFORMATION26                       in VARCHAR2 default NULL
,p_RAN_INFORMATION27                       in VARCHAR2 default NULL
,p_RAN_INFORMATION28                       in VARCHAR2 default NULL
,p_RAN_INFORMATION29                       in VARCHAR2 default NULL
,p_RAN_INFORMATION30                       in VARCHAR2 default NULL
,p_object_version_number                   OUT  nocopy number
,p_range_table_id                          OUT  nocopy number
)

IS

  l_object_version_number   number;
  l_range_table_id          number;
  l_legislation_code        varchar2(2);


Cursor Sel_Bus Is
   select inf.org_information9
       from hr_organization_information hoi
         , hr_organization_information inf
     where hoi.organization_id = p_BUSINESS_GROUP_ID
       and hoi.org_information_context||'' = 'CLASS'
       and hoi.org_information1 = 'HR_BG'
       and hoi.org_information2 = 'Y'
       and inf.organization_id = hoi.organization_id
       and inf.org_information_context || '' = 'Business Group Information';

Cursor Sel_leg is
  select distinct h.legislation_code
     from HR_LEGISLATION_INSTALLATIONS h
        where h.legislation_code = p_legislation_code
          and h.status = 'I';


 BEGIN

  l_object_version_number := 1;

  --
--Check for the Effective start date and End Date
--
IF p_effective_start_date > p_effective_end_date THEN
       fnd_message.set_name('PAY','PAY_NO_DATE_INVALID');
       fnd_message.raise_error;
END IF;

/*

--
--Check for the Validity if Legislation Code
--
if p_legislation_code is NOT NULL then
  Open Sel_leg;
  fetch Sel_leg Into l_legislation_code;

   if Sel_leg%notfound then
    Close Sel_leg;
    fnd_message.set_name('PAY', 'PAY_NO_API_LEG_CODE_INVALID');
    fnd_message.raise_error;
   else
    Close Sel_leg;
   end if;
end if;

--
--Check for the validity of Business Group ID and Legislation code Match.
--
if p_BUSINESS_GROUP_ID is NOT NULL then

  Open Sel_Bus;
  fetch Sel_Bus Into l_legislation_code;

   if Sel_Bus%notfound then
    Close Sel_Bus;
    fnd_message.set_name('PAY', 'HR_7208_API_BUS_GRP_INVALID');
    fnd_message.raise_error;
   else
    Close Sel_Bus;
   end if;

   if l_legislation_code <> p_legislation_code then
      fnd_message.set_name('PAY', 'PAY_NO_LEG_CODE_BG_MISMATCH');
      fnd_message.raise_error;
   end if;

end if;

 */

pay_prf_ins.ins
(
 p_EFFECTIVE_START_DATE                => p_EFFECTIVE_START_DATE
,p_EFFECTIVE_END_DATE                  => p_EFFECTIVE_END_DATE
,p_RANGE_TABLE_NUMBER                  => p_RANGE_TABLE_NUMBER
,p_ROW_VALUE_UOM                       => p_ROW_VALUE_UOM
,p_PERIOD_FREQUENCY                    => p_PERIOD_FREQUENCY
,p_EARNINGS_TYPE                       => p_EARNINGS_TYPE
,p_BUSINESS_GROUP_ID                   => p_BUSINESS_GROUP_ID
,p_LEGISLATION_CODE                    => p_LEGISLATION_CODE
,p_ATTRIBUTE_CATEGORY                  => p_ATTRIBUTE_CATEGORY
,p_ATTRIBUTE1                          => p_ATTRIBUTE1
,p_ATTRIBUTE2                          => p_ATTRIBUTE2
,p_ATTRIBUTE3                          => p_ATTRIBUTE3
,p_ATTRIBUTE4                          => p_ATTRIBUTE4
,p_ATTRIBUTE5                          => p_ATTRIBUTE5
,p_ATTRIBUTE6                          => p_ATTRIBUTE6
,p_ATTRIBUTE7                          => p_ATTRIBUTE7
,p_ATTRIBUTE8                          => p_ATTRIBUTE8
,p_ATTRIBUTE9                          => p_ATTRIBUTE9
,p_ATTRIBUTE10                         => p_ATTRIBUTE10
,p_ATTRIBUTE11                         => p_ATTRIBUTE11
,p_ATTRIBUTE12                         => p_ATTRIBUTE12
,p_ATTRIBUTE13                         => p_ATTRIBUTE13
,p_ATTRIBUTE14                         => p_ATTRIBUTE14
,p_ATTRIBUTE15                         => p_ATTRIBUTE15
,p_ATTRIBUTE16                         => p_ATTRIBUTE16
,p_ATTRIBUTE17                         => p_ATTRIBUTE17
,p_ATTRIBUTE18                         => p_ATTRIBUTE18
,p_ATTRIBUTE19                         => p_ATTRIBUTE19
,p_ATTRIBUTE20                         => p_ATTRIBUTE20
,p_ATTRIBUTE21                         => p_ATTRIBUTE21
,p_ATTRIBUTE22                         => p_ATTRIBUTE22
,p_ATTRIBUTE23                         => p_ATTRIBUTE23
,p_ATTRIBUTE24                         => p_ATTRIBUTE24
,p_ATTRIBUTE25                         => p_ATTRIBUTE25
,p_ATTRIBUTE26                         => p_ATTRIBUTE26
,p_ATTRIBUTE27                         => p_ATTRIBUTE27
,p_ATTRIBUTE28                         => p_ATTRIBUTE28
,p_ATTRIBUTE29                         => p_ATTRIBUTE29
,p_ATTRIBUTE30                         => p_ATTRIBUTE30
,p_RAN_INFORMATION_CATEGORY            => p_RAN_INFORMATION_CATEGORY
,p_RAN_INFORMATION1                    => p_RAN_INFORMATION1
,p_RAN_INFORMATION2                    => p_RAN_INFORMATION2
,p_RAN_INFORMATION3                    => p_RAN_INFORMATION3
,p_RAN_INFORMATION4                    => p_RAN_INFORMATION4
,p_RAN_INFORMATION5                    => p_RAN_INFORMATION5
,p_RAN_INFORMATION6                    => p_RAN_INFORMATION6
,p_RAN_INFORMATION7                    => p_RAN_INFORMATION7
,p_RAN_INFORMATION8                    => p_RAN_INFORMATION8
,p_RAN_INFORMATION9                    => p_RAN_INFORMATION9
,p_RAN_INFORMATION10                   => p_RAN_INFORMATION10
,p_RAN_INFORMATION11                   => p_RAN_INFORMATION11
,p_RAN_INFORMATION12                   => p_RAN_INFORMATION12
,p_RAN_INFORMATION13                   => p_RAN_INFORMATION13
,p_RAN_INFORMATION14                   => p_RAN_INFORMATION14
,p_RAN_INFORMATION15                   => p_RAN_INFORMATION15
,p_RAN_INFORMATION16                   => p_RAN_INFORMATION16
,p_RAN_INFORMATION17                   => p_RAN_INFORMATION17
,p_RAN_INFORMATION18                   => p_RAN_INFORMATION18
,p_RAN_INFORMATION19                   => p_RAN_INFORMATION19
,p_RAN_INFORMATION20                   => p_RAN_INFORMATION20
,p_RAN_INFORMATION21                   => p_RAN_INFORMATION21
,p_RAN_INFORMATION22                   => p_RAN_INFORMATION22
,p_RAN_INFORMATION23                   => p_RAN_INFORMATION23
,p_RAN_INFORMATION24                   => p_RAN_INFORMATION24
,p_RAN_INFORMATION25                   => p_RAN_INFORMATION25
,p_RAN_INFORMATION26                   => p_RAN_INFORMATION26
,p_RAN_INFORMATION27                   => p_RAN_INFORMATION27
,p_RAN_INFORMATION28                   => p_RAN_INFORMATION28
,p_RAN_INFORMATION29                   => p_RAN_INFORMATION29
,p_RAN_INFORMATION30                   => p_RAN_INFORMATION30
,p_RANGE_TABLE_ID                      => l_range_table_id
,p_object_version_number               => l_object_version_number
);


  p_object_version_number   := l_object_version_number;
  p_RANGE_TABLE_ID          := l_range_table_id;


end create_range_table;


procedure update_range_table
(  p_range_table_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_range_table_number           in     number    default hr_api.g_number
  ,p_period_frequency             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
  ,p_row_value_uom                in     varchar2  default hr_api.g_varchar2
  ,p_earnings_type                in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_last_updated_login           in     number    default hr_api.g_number
  ,p_created_date                 in     date      default hr_api.g_date
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_ran_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_ran_information1             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information2             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information3             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information4             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information5             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information6             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information7             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information8             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information9             in     varchar2  default hr_api.g_varchar2
  ,p_ran_information10            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information11            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information12            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information13            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information14            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information15            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information16            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information17            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information18            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information19            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information20            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information21            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information22            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information23            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information24            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information25            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information26            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information27            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information28            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information29            in     varchar2  default hr_api.g_varchar2
  ,p_ran_information30            in     varchar2  default hr_api.g_varchar2
  )

 IS

  l_object_version_number   number;
  l_legislation_code        varchar2(2);


Cursor Sel_Bus Is
   select inf.org_information9
       from hr_organization_information hoi
         , hr_organization_information inf
     where hoi.organization_id = p_BUSINESS_GROUP_ID
       and hoi.org_information_context||'' = 'CLASS'
       and hoi.org_information1 = 'HR_BG'
       and hoi.org_information2 = 'Y'
       and inf.organization_id = hoi.organization_id
       and inf.org_information_context || '' = 'Business Group Information';

Cursor Sel_leg is
  select distinct h.legislation_code
     from HR_LEGISLATION_INSTALLATIONS h
        where h.legislation_code = p_legislation_code
          and h.status = 'I';

BEGIN

l_object_version_number := p_object_version_number;

--
--Check for the Effective start date and End Date
--
IF p_effective_start_date > p_effective_end_date THEN
       fnd_message.set_name('PAY','PAY_NO_DATE_INVALID');
       fnd_message.raise_error;
END IF;

/*
--
--Check for the Validity if Legislation Code
--
if p_legislation_code is NOT NULL or p_legislation_code <>hr_api.g_varchar2 then
  Open Sel_leg;
  fetch Sel_leg Into l_legislation_code;

   if Sel_leg%notfound then
    Close Sel_leg;
    fnd_message.set_name('PAY', 'PAY_NO_API_LEG_CODE_INVALID');
    fnd_message.raise_error;
   else
    Close Sel_leg;
   end if;
end if;

--
--Check for the validity of Business Group ID and Legislation code Match.
--
if p_BUSINESS_GROUP_ID is NOT NULL or p_BUSINESS_GROUP_ID <>hr_api.g_number then

  Open Sel_Bus;
  fetch Sel_Bus Into l_legislation_code;

   if Sel_Bus%notfound then
    Close Sel_Bus;
    fnd_message.set_name('PAY', 'API_BUS_GRP_INVALID');
    fnd_message.raise_error;
   else
    Close Sel_Bus;
   end if;

   if l_legislation_code <> p_legislation_code then
      fnd_message.set_name('PAY', 'PAY_NO_LEG_CODE_BG_MISMATCH');
      fnd_message.raise_error;
   end if;

end if;

*/

pay_prf_upd.upd
(p_RANGE_TABLE_ID                      => p_range_table_id
,p_EFFECTIVE_START_DATE                => p_EFFECTIVE_START_DATE
,p_EFFECTIVE_END_DATE                  => p_EFFECTIVE_END_DATE
,p_RANGE_TABLE_NUMBER                  => p_RANGE_TABLE_NUMBER
,p_ROW_VALUE_UOM                       => p_ROW_VALUE_UOM
,p_PERIOD_FREQUENCY                    => p_PERIOD_FREQUENCY
,p_EARNINGS_TYPE                       => p_EARNINGS_TYPE
,p_BUSINESS_GROUP_ID                   => p_BUSINESS_GROUP_ID
,p_LEGISLATION_CODE                    => p_LEGISLATION_CODE
,p_ATTRIBUTE_CATEGORY                  => p_ATTRIBUTE_CATEGORY
,p_ATTRIBUTE1                          => p_ATTRIBUTE1
,p_ATTRIBUTE2                          => p_ATTRIBUTE2
,p_ATTRIBUTE3                          => p_ATTRIBUTE3
,p_ATTRIBUTE4                          => p_ATTRIBUTE4
,p_ATTRIBUTE5                          => p_ATTRIBUTE5
,p_ATTRIBUTE6                          => p_ATTRIBUTE6
,p_ATTRIBUTE7                          => p_ATTRIBUTE7
,p_ATTRIBUTE8                          => p_ATTRIBUTE8
,p_ATTRIBUTE9                          => p_ATTRIBUTE9
,p_ATTRIBUTE10                         => p_ATTRIBUTE10
,p_ATTRIBUTE11                         => p_ATTRIBUTE11
,p_ATTRIBUTE12                         => p_ATTRIBUTE12
,p_ATTRIBUTE13                         => p_ATTRIBUTE13
,p_ATTRIBUTE14                         => p_ATTRIBUTE14
,p_ATTRIBUTE15                         => p_ATTRIBUTE15
,p_ATTRIBUTE16                         => p_ATTRIBUTE16
,p_ATTRIBUTE17                         => p_ATTRIBUTE17
,p_ATTRIBUTE18                         => p_ATTRIBUTE18
,p_ATTRIBUTE19                         => p_ATTRIBUTE19
,p_ATTRIBUTE20                         => p_ATTRIBUTE20
,p_ATTRIBUTE21                         => p_ATTRIBUTE21
,p_ATTRIBUTE22                         => p_ATTRIBUTE22
,p_ATTRIBUTE23                         => p_ATTRIBUTE23
,p_ATTRIBUTE24                         => p_ATTRIBUTE24
,p_ATTRIBUTE25                         => p_ATTRIBUTE25
,p_ATTRIBUTE26                         => p_ATTRIBUTE26
,p_ATTRIBUTE27                         => p_ATTRIBUTE27
,p_ATTRIBUTE28                         => p_ATTRIBUTE28
,p_ATTRIBUTE29                         => p_ATTRIBUTE29
,p_ATTRIBUTE30                         => p_ATTRIBUTE30
,p_RAN_INFORMATION_CATEGORY            => p_RAN_INFORMATION_CATEGORY
,p_RAN_INFORMATION1                    => p_RAN_INFORMATION1
,p_RAN_INFORMATION2                    => p_RAN_INFORMATION2
,p_RAN_INFORMATION3                    => p_RAN_INFORMATION3
,p_RAN_INFORMATION4                    => p_RAN_INFORMATION4
,p_RAN_INFORMATION5                    => p_RAN_INFORMATION5
,p_RAN_INFORMATION6                    => p_RAN_INFORMATION6
,p_RAN_INFORMATION7                    => p_RAN_INFORMATION7
,p_RAN_INFORMATION8                    => p_RAN_INFORMATION8
,p_RAN_INFORMATION9                    => p_RAN_INFORMATION9
,p_RAN_INFORMATION10                   => p_RAN_INFORMATION10
,p_RAN_INFORMATION11                   => p_RAN_INFORMATION11
,p_RAN_INFORMATION12                   => p_RAN_INFORMATION12
,p_RAN_INFORMATION13                   => p_RAN_INFORMATION13
,p_RAN_INFORMATION14                   => p_RAN_INFORMATION14
,p_RAN_INFORMATION15                   => p_RAN_INFORMATION15
,p_RAN_INFORMATION16                   => p_RAN_INFORMATION16
,p_RAN_INFORMATION17                   => p_RAN_INFORMATION17
,p_RAN_INFORMATION18                   => p_RAN_INFORMATION18
,p_RAN_INFORMATION19                   => p_RAN_INFORMATION19
,p_RAN_INFORMATION20                   => p_RAN_INFORMATION20
,p_RAN_INFORMATION21                   => p_RAN_INFORMATION21
,p_RAN_INFORMATION22                   => p_RAN_INFORMATION22
,p_RAN_INFORMATION23                   => p_RAN_INFORMATION23
,p_RAN_INFORMATION24                   => p_RAN_INFORMATION24
,p_RAN_INFORMATION25                   => p_RAN_INFORMATION25
,p_RAN_INFORMATION26                   => p_RAN_INFORMATION26
,p_RAN_INFORMATION27                   => p_RAN_INFORMATION27
,p_RAN_INFORMATION28                   => p_RAN_INFORMATION28
,p_RAN_INFORMATION29                   => p_RAN_INFORMATION29
,p_RAN_INFORMATION30                   => p_RAN_INFORMATION30
,p_object_version_number               => l_object_version_number
);



p_object_version_number   := l_object_version_number;

end update_range_table;



procedure delete_range_table
 ( p_range_table_id                       in     number
  ,p_object_version_number                in     number
  )

IS


BEGIN


pay_prf_del.del
(
 p_range_table_id                      => p_range_table_id
,p_OBJECT_VERSION_NUMBER               => p_object_version_number
);


end delete_range_table;

END pay_range_table_api;

/
