--------------------------------------------------------
--  DDL for Package HR_FORM_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TEMPLATES_API" AUTHID CURRENT_USER as
/* $Header: hrtmpapi.pkh 120.0 2005/05/31 03:20:53 appldev noship $ */
-- Global Variable definition
g_session_mode varchar2(30) := 'CUSTOMER_DATA';
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description: This business process inserts a new form template in the
--              HR Schema based on an existing template. It also creates a
--              copy of every object within the copied from template in the
--              new template.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_language_code                   N Varchar2
--     p_form_template_id_from           Y Number
--     p_template_name                   N Varchar2
--     p_user_template_name              N Varchar2
--     p_enabled_flag                    N Varchar2
--     p_description                     N Varchar2
--     p_legislation_code                N Varchar2
--     p_attribute_category              N Varchar2
--     p_attribute1                      N Varchar2
--     p_attribute2                      N Varchar2
--     p_attribute3                      N Varchar2
--     p_attribute4                      N Varchar2
--     p_attribute5                      N Varchar2
--     p_attribute6                      N Varchar2
--     p_attribute7                      N Varchar2
--     p_attribute8                      N Varchar2
--     p_attribute9                      N Varchar2
--     p_attribute10                     N Varchar2
--     p_attribute11                     N Varchar2
--     p_attribute12                     N Varchar2
--     p_attribute13                     N Varchar2
--     p_attribute14                     N Varchar2
--     p_attribute15                     N Varchar2
--     p_attribute16                     N Varchar2
--     p_attribute17                     N Varchar2
--     p_attribute18                     N Varchar2
--     p_attribute19                     N Varchar2
--     p_attribute20                     N Varchar2
--     p_attribute21                     N Varchar2
--     p_attribute22                     N Varchar2
--     p_attribute23                     N Varchar2
--     p_attribute24                     N Varchar2
--     p_attribute25                     N Varchar2
--     p_attribute26                     N Varchar2
--     p_attribute27                     N Varchar2
--     p_attribute28                     N Varchar2
--     p_attribute29                     N Varchar2
--     p_attribute30                     N Varchar2
--
-- Post Success:
--
--     Name                           Type     Description
--     p_form_template_id_to          Number
--     p_object_version_number        Number
--
-- Post Failure:
--
--
-- {Start Of Comments}
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure copy_template
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_form_template_id_from        in number
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  --,p_template_name                in varchar2 default hr_api.g_varchar2
  ,p_template_name                in varchar2
  ,p_user_template_name           in varchar2 default hr_api.g_varchar2
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_enabled_flag                 in varchar2 default hr_api.g_varchar2
  ,p_legislation_code             in varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in varchar2 default hr_api.g_varchar2
  ,p_form_template_id_to            out nocopy number
  ,p_object_version_number          out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_template >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form template
--              in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_language_code                   N Varchar2
--     p_application_id                  Y Number
--     p_form_id                         Y Number
--     p_template_name                   Y Varchar2
--     p_enabled_flag                    Y Varchar2
--     p_user_template_name              Y Varchar2
--     p_description                     N Varchar2
--     p_legislation_code                N Varchar2
--     p_attribute_category              N Varchar2
--     p_attribute1                      N Varchar2
--     p_attribute2                      N Varchar2
--     p_attribute3                      N Varchar2
--     p_attribute4                      N Varchar2
--     p_attribute5                      N Varchar2
--     p_attribute6                      N Varchar2
--     p_attribute7                      N Varchar2
--     p_attribute8                      N Varchar2
--     p_attribute9                      N Varchar2
--     p_attribute10                     N Varchar2
--     p_attribute11                     N Varchar2
--     p_attribute12                     N Varchar2
--     p_attribute13                     N Varchar2
--     p_attribute14                     N Varchar2
--     p_attribute15                     N Varchar2
--     p_attribute16                     N Varchar2
--     p_attribute17                     N Varchar2
--     p_attribute18                     N Varchar2
--     p_attribute19                     N Varchar2
--     p_attribute20                     N Varchar2
--     p_attribute21                     N Varchar2
--     p_attribute22                     N Varchar2
--     p_attribute23                     N Varchar2
--     p_attribute24                     N Varchar2
--     p_attribute25                     N Varchar2
--     p_attribute26                     N Varchar2
--     p_attribute27                     N Varchar2
--     p_attribute28                     N Varchar2
--     p_attribute29                     N Varchar2
--     p_attribute30                     N Varchar2
--     p_help_target                     N Varchar2
--     p_information_category            N Varchar2
--     p_information1                    N Varchar2
--     p_information2                    N Varchar2
--     p_information3                    N Varchar2
--     p_information4                    N Varchar2
--     p_information5                    N Varchar2
--     p_information6                    N Varchar2
--     p_information7                    N Varchar2
--     p_information8                    N Varchar2
--     p_information9                    N Varchar2
--     p_information10                   N Varchar2
--     p_information11                   N Varchar2
--     p_information12                   N Varchar2
--     p_information13                   N Varchar2
--     p_information14                   N Varchar2
--     p_information15                   N Varchar2
--     p_information16                   N Varchar2
--     p_information17                   N Varchar2
--     p_information18                   N Varchar2
--     p_information19                   N Varchar2
--     p_information20                   N Varchar2
--     p_information21                   N Varchar2
--     p_information22                   N Varchar2
--     p_information23                   N Varchar2
--     p_information24                   N Varchar2
--     p_information25                   N Varchar2
--     p_information26                   N Varchar2
--     p_information27                   N Varchar2
--     p_information28                   N Varchar2
--     p_information29                   N Varchar2
--     p_information30                   N Varchar2
--
--
-- Post Success:
--
--     Name                           Type     Description
--     p_form_template_id             Number
--     p_object_version_number        Number
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_template
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_template_name                in varchar2
  ,p_enabled_flag                 in varchar2
  ,p_user_template_name           in varchar2
  ,p_description                  in varchar2 default null
  ,p_legislation_code             in varchar2 default null
  ,p_attribute_category           in varchar2 default null
  ,p_attribute1                   in varchar2 default null
  ,p_attribute2                   in varchar2 default null
  ,p_attribute3                   in varchar2 default null
  ,p_attribute4                   in varchar2 default null
  ,p_attribute5                   in varchar2 default null
  ,p_attribute6                   in varchar2 default null
  ,p_attribute7                   in varchar2 default null
  ,p_attribute8                   in varchar2 default null
  ,p_attribute9                   in varchar2 default null
  ,p_attribute10                  in varchar2 default null
  ,p_attribute11                  in varchar2 default null
  ,p_attribute12                  in varchar2 default null
  ,p_attribute13                  in varchar2 default null
  ,p_attribute14                  in varchar2 default null
  ,p_attribute15                  in varchar2 default null
  ,p_attribute16                  in varchar2 default null
  ,p_attribute17                  in varchar2 default null
  ,p_attribute18                  in varchar2 default null
  ,p_attribute19                  in varchar2 default null
  ,p_attribute20                  in varchar2 default null
  ,p_attribute21                  in varchar2 default null
  ,p_attribute22                  in varchar2 default null
  ,p_attribute23                  in varchar2 default null
  ,p_attribute24                  in varchar2 default null
  ,p_attribute25                  in varchar2 default null
  ,p_attribute26                  in varchar2 default null
  ,p_attribute27                  in varchar2 default null
  ,p_attribute28                  in varchar2 default null
  ,p_attribute29                  in varchar2 default null
  ,p_attribute30                  in varchar2 default null
  ,p_help_target                  in varchar2 default hr_api.g_varchar2
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ,p_form_template_id                out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_template >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form template from
--              the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--
--     p_form_template_id             Y    Number
--     p_object_version_number        Y    Number
--     p_delete_children_flag         N    Varchar2
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
--   Internal.
--
-- {End Of Comments}
--
procedure delete_template
  (p_validate                      in boolean  default false
  ,p_form_template_id              in number
  ,p_object_version_number         in number
  ,p_delete_children_flag          in varchar2 default 'N'
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_session_mode procedures>------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: These business support process sets the type of session the
--              user is running. May be either a seed data or customer data
--              session.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
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
--   Internal.
--
-- {End Of Comments}
--
procedure set_seed_data_session_mode;
--
procedure set_customer_data_session_mode;
--
function seed_data_session_mode
return boolean;
--
procedure assert_seed_data_session_mode;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_template >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a form template in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_language_code                   N Varchar2
--     p_form_template_id                Y Number
--     p_object_version_number           Y Number
--     p_template_name                   N Varchar2
--     p_enabled_flag                    N Varchar2
--     p_user_template_name              N Varchar2
--     p_description                     N Varchar2
--     p_legislation_code                N Varchar2
--     p_attribute_category              N Varchar2
--     p_attribute1                      N Varchar2
--     p_attribute2                      N Varchar2
--     p_attribute3                      N Varchar2
--     p_attribute4                      N Varchar2
--     p_attribute5                      N Varchar2
--     p_attribute6                      N Varchar2
--     p_attribute7                      N Varchar2
--     p_attribute8                      N Varchar2
--     p_attribute9                      N Varchar2
--     p_attribute10                     N Varchar2
--     p_attribute11                     N Varchar2
--     p_attribute12                     N Varchar2
--     p_attribute13                     N Varchar2
--     p_attribute14                     N Varchar2
--     p_attribute15                     N Varchar2
--     p_attribute16                     N Varchar2
--     p_attribute17                     N Varchar2
--     p_attribute18                     N Varchar2
--     p_attribute19                     N Varchar2
--     p_attribute20                     N Varchar2
--     p_attribute21                     N Varchar2
--     p_attribute22                     N Varchar2
--     p_attribute23                     N Varchar2
--     p_attribute24                     N Varchar2
--     p_attribute25                     N Varchar2
--     p_attribute26                     N Varchar2
--     p_attribute27                     N Varchar2
--     p_attribute28                     N Varchar2
--     p_attribute29                     N Varchar2
--     p_attribute30                     N Varchar2
--     p_help_target                     N Varchar2
--     p_information_category            N Varchar2
--     p_information1                    N Varchar2
--     p_information2                    N Varchar2
--     p_information3                    N Varchar2
--     p_information4                    N Varchar2
--     p_information5                    N Varchar2
--     p_information6                    N Varchar2
--     p_information7                    N Varchar2
--     p_information8                    N Varchar2
--     p_information9                    N Varchar2
--     p_information10                   N Varchar2
--     p_information11                   N Varchar2
--     p_information12                   N Varchar2
--     p_information13                   N Varchar2
--     p_information14                   N Varchar2
--     p_information15                   N Varchar2
--     p_information16                   N Varchar2
--     p_information17                   N Varchar2
--     p_information18                   N Varchar2
--     p_information19                   N Varchar2
--     p_information20                   N Varchar2
--     p_information21                   N Varchar2
--     p_information22                   N Varchar2
--     p_information23                   N Varchar2
--     p_information24                   N Varchar2
--     p_information25                   N Varchar2
--     p_information26                   N Varchar2
--     p_information27                   N Varchar2
--     p_information28                   N Varchar2
--     p_information29                   N Varchar2
--     p_information30                   N Varchar2
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_object_version_number        Number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_template
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in out nocopy number
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  ,p_template_name                in varchar2 default hr_api.g_varchar2
  ,p_enabled_flag                 in varchar2 default hr_api.g_varchar2
  ,p_user_template_name           in varchar2 default hr_api.g_varchar2
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_legislation_code             in varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in varchar2 default hr_api.g_varchar2
  ,p_help_target                  in varchar2 default hr_api.g_varchar2
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  );
--
end hr_form_templates_api;

 

/
