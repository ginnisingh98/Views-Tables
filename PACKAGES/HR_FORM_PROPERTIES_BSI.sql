--------------------------------------------------------
--  DDL for Package HR_FORM_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_PROPERTIES_BSI" AUTHID CURRENT_USER as
/* $Header: hrfmpbsi.pkh 115.2 2003/09/24 02:00:16 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_form_property >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process inserts a new form property
--              in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_application_id                  N Number
--      p_form_id                         N Number
--      p_form_template_id                N Number
--      p_help_target                     N varchar2
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_form_property_id             Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_application_id                  in number default null
  ,p_form_id                         in number default null
  ,p_form_template_id                in number default null
  ,p_help_target                     in varchar2 default null
  ,p_information_category            in varchar2 default null
  ,p_information1                    in varchar2 default null
  ,p_information2                    in varchar2 default null
  ,p_information3                    in varchar2 default null
  ,p_information4                    in varchar2 default null
  ,p_information5                    in varchar2 default null
  ,p_information6                    in varchar2 default null
  ,p_information7                    in varchar2 default null
  ,p_information8                    in varchar2 default null
  ,p_information9                    in varchar2 default null
  ,p_information10                   in varchar2 default null
  ,p_information11                   in varchar2 default null
  ,p_information12                   in varchar2 default null
  ,p_information13                   in varchar2 default null
  ,p_information14                   in varchar2 default null
  ,p_information15                   in varchar2 default null
  ,p_information16                   in varchar2 default null
  ,p_information17                   in varchar2 default null
  ,p_information18                   in varchar2 default null
  ,p_information19                   in varchar2 default null
  ,p_information20                   in varchar2 default null
  ,p_information21                   in varchar2 default null
  ,p_information22                   in varchar2 default null
  ,p_information23                   in varchar2 default null
  ,p_information24                   in varchar2 default null
  ,p_information25                   in varchar2 default null
  ,p_information26                   in varchar2 default null
  ,p_information27                   in varchar2 default null
  ,p_information28                   in varchar2 default null
  ,p_information29                   in varchar2 default null
  ,p_information30                   in varchar2 default null
  ,p_form_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_form_property >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process updates a form property in
--              the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_form_property_id                N Number
--      p_application_id                  N Number
--      p_form_id                         N Number
--      p_form_template_id                N Number
--      p_help_target                     N varchar2
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_property_id                in number default null
  ,p_object_version_number           in out nocopy number
  ,p_application_id                  in number default null
  ,p_form_id                         in number default null
  ,p_form_template_id                in number default null
  ,p_help_target                     in varchar2 default hr_api.g_varchar2
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_property >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process deletes a form property from
--              the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_form_property_id                N Number
--      p_application_id                  N Number
--      p_form_id                         N Number
--      p_form_template_id                N Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_form_property
  (p_validate                      in     boolean  default false
  ,p_form_property_id                in number default null
  ,p_object_version_number           in     number
  ,p_application_id                  in number default null
  ,p_form_id                         in number default null
  ,p_form_template_id                in number default null
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_form_property >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a form
--              to a template. Any property may not be copied by specifying
--              the value required in the parameter list.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_application_id                  N Number
--      p_form_id                         N Number
--      p_form_template_id                N Number
--      p_help_target                     N varchar2
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_form_property_id             number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_application_id                  in number
  ,p_form_id                         in number
  ,p_form_template_id                in number
  ,p_help_target                     in varchar2 default hr_api.g_varchar2
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_form_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< copy_form_property  - overload >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a
--              template to another template. Any property may not be copied
--              by specifying the value required in the parameter list.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_form_template_id_to             Y  Number
--      p_form_template_id_from           Y  Number
--      p_help_target                     N varchar2
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_form_property_id             number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_template_id_to             in number
  ,p_form_template_id_from           in number
  ,p_help_target                     in varchar2 default hr_api.g_varchar2
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_form_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_form_properties_bsi;

 

/
