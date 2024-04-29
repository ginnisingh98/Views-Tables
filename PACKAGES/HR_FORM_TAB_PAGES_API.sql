--------------------------------------------------------
--  DDL for Package HR_FORM_TAB_PAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TAB_PAGES_API" AUTHID CURRENT_USER as
/* $Header: hrftpapi.pkh 120.0 2005/05/31 00:30:13 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_form_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form tab page in
--              the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                   N Varchar2
--   p_form_canvas_id                  Y Number
--   p_tab_page_name                   Y Varchar2
--   p_display_order                   Y Number
--   p_user_tab_page_name              Y Varchar2
--   p_description                     N Varchar2
--   p_label                           N Varchar2
--   p_navigation_direction            N Varchar2
--   p_visible                         N Varchar2
--   p_information_category            N Varchar2
--   p_information1                    N Varchar2
--   p_information2                    N Varchar2
--   p_information3                    N Varchar2
--   p_information4                    N Varchar2
--   p_information5                    N Varchar2
--   p_information6                    N Varchar2
--   p_information7                    N Varchar2
--   p_information8                    N Varchar2
--   p_information9                    N Varchar2
--   p_information10                   N Varchar2
--   p_information11                   N Varchar2
--   p_information12                   N Varchar2
--   p_information13                   N Varchar2
--   p_information14                   N Varchar2
--   p_information15                   N Varchar2
--   p_information16                   N Varchar2
--   p_information17                   N Varchar2
--   p_information18                   N Varchar2
--   p_information19                   N Varchar2
--   p_information20                   N Varchar2
--   p_information21                   N Varchar2
--   p_information22                   N Varchar2
--   p_information23                   N Varchar2
--   p_information24                   N Varchar2
--   p_information25                   N Varchar2
--   p_information26                   N Varchar2
--   p_information27                   N Varchar2
--   p_information28                   N Varchar2
--   p_information29                   N Varchar2
--   p_information30                   N Varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--    p_form_tab_page_id            Number
--    p_object_version_number       Number
--    p_override_value_warning      Boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_form_tab_page
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_language_code                  in varchar2 default hr_api.userenv_lang
  ,p_form_canvas_id                 in number
  ,p_tab_page_name                  in varchar2
  ,p_display_order                  in number
  ,p_user_tab_page_name             in varchar2
  ,p_description                    in varchar2 default null
  ,p_label                          in varchar2 default null
  ,p_navigation_direction           in varchar2 default null
  ,p_visible                        in number default null
  ,p_visible_override               in number default null
  ,p_information_category           in varchar2 default null
  ,p_information1                   in varchar2 default null
  ,p_information2                   in varchar2 default null
  ,p_information3                   in varchar2 default null
  ,p_information4                   in varchar2 default null
  ,p_information5                   in varchar2 default null
  ,p_information6                   in varchar2 default null
  ,p_information7                   in varchar2 default null
  ,p_information8                   in varchar2 default null
  ,p_information9                   in varchar2 default null
  ,p_information10                  in varchar2 default null
  ,p_information11                  in varchar2 default null
  ,p_information12                  in varchar2 default null
  ,p_information13                  in varchar2 default null
  ,p_information14                  in varchar2 default null
  ,p_information15                  in varchar2 default null
  ,p_information16                  in varchar2 default null
  ,p_information17                  in varchar2 default null
  ,p_information18                  in varchar2 default null
  ,p_information19                  in varchar2 default null
  ,p_information20                  in varchar2 default null
  ,p_information21                  in varchar2 default null
  ,p_information22                  in varchar2 default null
  ,p_information23                  in varchar2 default null
  ,p_information24                  in varchar2 default null
  ,p_information25                  in varchar2 default null
  ,p_information26                  in varchar2 default null
  ,p_information27                  in varchar2 default null
  ,p_information28                  in varchar2 default null
  ,p_information29                  in varchar2 default null
  ,p_information30                  in varchar2 default null
  ,p_form_tab_page_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_override_value_warning           out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_form_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form tab page from
--              the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                        Reqd Type     Description
--   p_form_tab_page_id             Y number
--   p_object_version_number        Y number
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
procedure delete_form_tab_page
  (p_validate                      in boolean  default false
  ,p_form_tab_page_id              in number
  ,p_object_version_number         in number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_form_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a form tab page in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                   N Varchar2
--   p_form_tab_page_id                Y number
--   p_object_version_number           Y number
--   p_tab_page_name                   N Varchar2
--   p_user_tab_page_name              N Varchar2
--   p_description                     N Varchar2
--   p_label                           N Varchar2
--   p_navigation_direction            N Varchar2
--   p_visible                         N Varchar2
--   p_information_category            N Varchar2
--   p_information1                    N Varchar2
--   p_information2                    N Varchar2
--   p_information3                    N Varchar2
--   p_information4                    N Varchar2
--   p_information5                    N Varchar2
--   p_information6                    N Varchar2
--   p_information7                    N Varchar2
--   p_information8                    N Varchar2
--   p_information9                    N Varchar2
--   p_information10                   N Varchar2
--   p_information11                   N Varchar2
--   p_information12                   N Varchar2
--   p_information13                   N Varchar2
--   p_information14                   N Varchar2
--   p_information15                   N Varchar2
--   p_information16                   N Varchar2
--   p_information17                   N Varchar2
--   p_information18                   N Varchar2
--   p_information19                   N Varchar2
--   p_information20                   N Varchar2
--   p_information21                   N Varchar2
--   p_information22                   N Varchar2
--   p_information23                   N Varchar2
--   p_information24                   N Varchar2
--   p_information25                   N Varchar2
--   p_information26                   N Varchar2
--   p_information27                   N Varchar2
--   p_information28                   N Varchar2
--   p_information29                   N Varchar2
--   p_information30                   N Varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--    p_object_version_number       Number
----    p_override_value_warning      Boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_form_tab_page
  (p_validate                       in boolean  default false
  ,p_effective_date                 in date
  ,p_language_code                  in varchar2 default hr_api.userenv_lang
  ,p_form_tab_page_id               in number
  ,p_object_version_number          in out nocopy number
  ,p_tab_page_name                  in varchar2 default hr_api.g_varchar2
  ,p_display_order                  in number default hr_api.g_number
  ,p_user_tab_page_name             in varchar2 default hr_api.g_varchar2
  ,p_description                    in varchar2 default hr_api.g_varchar2
  ,p_label                          in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction           in varchar2 default hr_api.g_varchar2
  ,p_visible                        in number default hr_api.g_number
  ,p_visible_override               in number default hr_api.g_number
  ,p_information_category           in varchar2 default hr_api.g_varchar2
  ,p_information1                   in varchar2 default hr_api.g_varchar2
  ,p_information2                   in varchar2 default hr_api.g_varchar2
  ,p_information3                   in varchar2 default hr_api.g_varchar2
  ,p_information4                   in varchar2 default hr_api.g_varchar2
  ,p_information5                   in varchar2 default hr_api.g_varchar2
  ,p_information6                   in varchar2 default hr_api.g_varchar2
  ,p_information7                   in varchar2 default hr_api.g_varchar2
  ,p_information8                   in varchar2 default hr_api.g_varchar2
  ,p_information9                   in varchar2 default hr_api.g_varchar2
  ,p_information10                  in varchar2 default hr_api.g_varchar2
  ,p_information11                  in varchar2 default hr_api.g_varchar2
  ,p_information12                  in varchar2 default hr_api.g_varchar2
  ,p_information13                  in varchar2 default hr_api.g_varchar2
  ,p_information14                  in varchar2 default hr_api.g_varchar2
  ,p_information15                  in varchar2 default hr_api.g_varchar2
  ,p_information16                  in varchar2 default hr_api.g_varchar2
  ,p_information17                  in varchar2 default hr_api.g_varchar2
  ,p_information18                  in varchar2 default hr_api.g_varchar2
  ,p_information19                  in varchar2 default hr_api.g_varchar2
  ,p_information20                  in varchar2 default hr_api.g_varchar2
  ,p_information21                  in varchar2 default hr_api.g_varchar2
  ,p_information22                  in varchar2 default hr_api.g_varchar2
  ,p_information23                  in varchar2 default hr_api.g_varchar2
  ,p_information24                  in varchar2 default hr_api.g_varchar2
  ,p_information25                  in varchar2 default hr_api.g_varchar2
  ,p_information26                  in varchar2 default hr_api.g_varchar2
  ,p_information27                  in varchar2 default hr_api.g_varchar2
  ,p_information28                  in varchar2 default hr_api.g_varchar2
  ,p_information29                  in varchar2 default hr_api.g_varchar2
  ,p_information30                  in varchar2 default hr_api.g_varchar2
  ,p_override_value_warning           out nocopy boolean
  );
--
end hr_form_tab_pages_api;

 

/
