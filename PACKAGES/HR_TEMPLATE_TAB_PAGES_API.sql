--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_TAB_PAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_TAB_PAGES_API" AUTHID CURRENT_USER as
/* $Header: hrttpapi.pkh 120.0 2005/05/31 03:33:14 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template_tab_page >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template tab page in
--              the HR Schema based on an existing template tab page. It
--              also creates a copy of every object within the copied from
--              template tab page in the new template tab page.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                N    Varchar2
--   p_template_tab page_id_from    Y    Number
--   p_template_canvas_id           Y    Number
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_template_tab_page_id_to      Number
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
procedure copy_template_tab_page
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in varchar2 default hr_api.userenv_lang
  ,p_template_tab_page_id_from     in number
  ,p_template_canvas_id            in number
  ,p_template_tab_page_id_to          out nocopy number
  ,p_object_version_number            out nocopy number
  --,p_override_value_warning           out boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_template_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template tab page in the
--              HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_language_code                   N varchar2
--     p_form_tab_page_id                Y number
--     p_template_canvas_id              Y number
--     p_label                           N varchar2
--     p_navigation_direction            N varchar2
--     p_visible                         N number
--     p_information_category            N varchar2
--     p_information1                    N varchar2
--     p_information2                    N varchar2
--     p_information3                    N varchar2
--     p_information4                    N varchar2
--     p_information5                    N varchar2
--     p_information6                    N varchar2
--     p_information7                    N varchar2
--     p_information8                    N varchar2
--     p_information9                    N varchar2
--     p_information10                   N varchar2
--     p_information11                   N varchar2
--     p_information12                   N varchar2
--     p_information13                   N varchar2
--     p_information14                   N varchar2
--     p_information15                   N varchar2
--     p_information16                   N varchar2
--     p_information17                   N varchar2
--     p_information18                   N varchar2
--     p_information19                   N varchar2
--     p_information20                   N varchar2
--     p_information21                   N varchar2
--     p_information22                   N varchar2
--     p_information23                   N varchar2
--     p_information24                   N varchar2
--     p_information25                   N varchar2
--     p_information26                   N varchar2
--     p_information27                   N varchar2
--     p_information28                   N varchar2
--     p_information29                   N varchar2
--     p_information30                   N varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_template_tab_page_id         Number
--   p_object_version_number        Number
--   p_override_value_warning       Boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_template_tab_page
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_canvas_id              in number
  ,p_form_tab_page_id                in number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction            in varchar2 default hr_api.g_varchar2
  ,p_visible                         in number default hr_api.g_number
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
  ,p_template_tab_page_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_override_value_warning            out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_template_tab_page >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a template tab page from the
--              HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_template_tab_page_id         Y    Number
--   p_object_version_number        Y    Number
--   p_delete_children_flag         N    Varchar2
--
--
-- Post Success:
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
procedure delete_template_tab_page
  (p_validate                      in     boolean  default false
  ,p_template_tab_page_id          in     number
  ,p_object_version_number         in     number
  ,p_delete_children_flag          in     varchar2 default 'N'
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_template_tab_page >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a template tab page in the
--              HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_language_code                   N varchar2
--     p_template_tab_page_id            Y number
--     p_object_version_number           Y number
--     p_label                           N varchar2
--     p_navigation_direction            N varchar2
--     p_visible                         N number
--     p_information_category            N varchar2
--     p_information1                    N varchar2
--     p_information2                    N varchar2
--     p_information3                    N varchar2
--     p_information4                    N varchar2
--     p_information5                    N varchar2
--     p_information6                    N varchar2
--     p_information7                    N varchar2
--     p_information8                    N varchar2
--     p_information9                    N varchar2
--     p_information10                   N varchar2
--     p_information11                   N varchar2
--     p_information12                   N varchar2
--     p_information13                   N varchar2
--     p_information14                   N varchar2
--     p_information15                   N varchar2
--     p_information16                   N varchar2
--     p_information17                   N varchar2
--     p_information18                   N varchar2
--     p_information19                   N varchar2
--     p_information20                   N varchar2
--     p_information21                   N varchar2
--     p_information22                   N varchar2
--     p_information23                   N varchar2
--     p_information24                   N varchar2
--     p_information25                   N varchar2
--     p_information26                   N varchar2
--     p_information27                   N varchar2
--     p_information28                   N varchar2
--     p_information29                   N varchar2
--     p_information30                   N varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_object_version_number        Number
--   p_override_value_warning       Boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_template_tab_page
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_tab_page_id            in number
  ,p_object_version_number           in out nocopy number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction            in varchar2 default hr_api.g_varchar2
  ,p_visible                         in number default hr_api.g_number
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
  ,p_override_value_warning            out nocopy boolean
  );
--
end hr_template_tab_pages_api;

 

/
