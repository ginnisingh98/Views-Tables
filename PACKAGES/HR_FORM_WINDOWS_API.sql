--------------------------------------------------------
--  DDL for Package HR_FORM_WINDOWS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_WINDOWS_API" AUTHID CURRENT_USER as
/* $Header: hrfwnapi.pkh 120.0 2005/05/31 00:33:05 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_window >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form window in the
--              HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                        Reqd Type     Description
--     p_language_code                N Varchar2
--     p_application_id               Y Number
--     p_form_id                      Y Number
--     p_window_name                  Y Varchar2
--     p_user_window_name             Y Varchar2
--     p_description                  N Varchar2
--     p_height                       N Number
--     p_title                        N Number
--     p_width                        N Number
--     p_x_position                   N Number
--     p_y_position                   N Number
--     p_information_category         N Varchar2
--     p_information1                 N Varchar2
--     p_information2                 N Varchar2
--     p_information3                 N Varchar2
--     p_information4                 N Varchar2
--     p_information5                 N Varchar2
--     p_information6                 N Varchar2
--     p_information7                 N Varchar2
--     p_information8                 N Varchar2
--     p_information9                 N Varchar2
--     p_information10                N Varchar2
--     p_information11                N Varchar2
--     p_information12                N Varchar2
--     p_information13                N Varchar2
--     p_information14                N Varchar2
--     p_information15                N Varchar2
--     p_information16                N Varchar2
--     p_information17                N Varchar2
--     p_information18                N Varchar2
--     p_information19                N Varchar2
--     p_information20                N Varchar2
--     p_information21                N Varchar2
--     p_information22                N Varchar2
--     p_information23                N Varchar2
--     p_information24                N Varchar2
--     p_information25                N Varchar2
--     p_information26                N Varchar2
--     p_information27                N Varchar2
--     p_information28                N Varchar2
--     p_information29                N Varchar2
--     p_information30                N Varchar2
--
-- Post Success:
--
--
--   Name                           Type     Description
--
--   p_form_window_id               Number
--   p_object_version_number        Number
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_form_window
  (p_validate                    in     boolean  default false
  ,p_effective_date              in     date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  ,p_application_id              in number
  ,p_form_id                     in number
  ,p_window_name                 in varchar2
  ,p_user_window_name            in varchar2
  ,p_description                 in varchar2 default null
  ,p_height                      in number default null
  ,p_title                       in varchar2 default null
  ,p_width                       in number default null
  ,p_x_position                  in number default null
  ,p_y_position                  in number default null
  ,p_information_category        in varchar2 default null
  ,p_information1                in varchar2 default null
  ,p_information2                in varchar2 default null
  ,p_information3                in varchar2 default null
  ,p_information4                in varchar2 default null
  ,p_information5                in varchar2 default null
  ,p_information6                in varchar2 default null
  ,p_information7                in varchar2 default null
  ,p_information8                in varchar2 default null
  ,p_information9                in varchar2 default null
  ,p_information10               in varchar2 default null
  ,p_information11               in varchar2 default null
  ,p_information12               in varchar2 default null
  ,p_information13               in varchar2 default null
  ,p_information14               in varchar2 default null
  ,p_information15               in varchar2 default null
  ,p_information16               in varchar2 default null
  ,p_information17               in varchar2 default null
  ,p_information18               in varchar2 default null
  ,p_information19               in varchar2 default null
  ,p_information20               in varchar2 default null
  ,p_information21               in varchar2 default null
  ,p_information22               in varchar2 default null
  ,p_information23               in varchar2 default null
  ,p_information24               in varchar2 default null
  ,p_information25               in varchar2 default null
  ,p_information26               in varchar2 default null
  ,p_information27               in varchar2 default null
  ,p_information28               in varchar2 default null
  ,p_information29               in varchar2 default null
  ,p_information30               in varchar2 default null
  ,p_form_window_id                out nocopy number
  ,p_object_version_number         out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_window >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form window from the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_form_window_id               Y    Number
--   p_object_version_number        Y    Number
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
procedure delete_form_window
  (p_validate                      in boolean  default false
  ,p_form_window_id                in number
  ,p_object_version_number         in number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_form_window >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a form window in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                        Reqd Type     Description
--     p_language_code                N Varchar2
--     p_form_window_id               Y  Number
--     p_window_name                  Y Varchar2
--     p_user_window_name             Y Varchar2
--     p_description                  N Varchar2
--     p_height                       N Number
--     p_title                        N Number
--     p_width                        N Number
--     p_x_position                   N Number
--     p_y_position                   N Number
--     p_information_category         N Varchar2
--     p_information1                 N Varchar2
--     p_information2                 N Varchar2
--     p_information3                 N Varchar2
--     p_information4                 N Varchar2
--     p_information5                 N Varchar2
--     p_information6                 N Varchar2
--     p_information7                 N Varchar2
--     p_information8                 N Varchar2
--     p_information9                 N Varchar2
--     p_information10                N Varchar2
--     p_information11                N Varchar2
--     p_information12                N Varchar2
--     p_information13                N Varchar2
--     p_information14                N Varchar2
--     p_information15                N Varchar2
--     p_information16                N Varchar2
--     p_information17                N Varchar2
--     p_information18                N Varchar2
--     p_information19                N Varchar2
--     p_information20                N Varchar2
--     p_information21                N Varchar2
--     p_information22                N Varchar2
--     p_information23                N Varchar2
--     p_information24                N Varchar2
--     p_information25                N Varchar2
--     p_information26                N Varchar2
--     p_information27                N Varchar2
--     p_information28                N Varchar2
--     p_information29                N Varchar2
--     p_information30                N Varchar2
--
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
procedure update_form_window
  (p_validate                    in     boolean  default false
  ,p_effective_date              in     date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  --,p_application_id              in number default hr_api.g_number
  --,p_form_id                     in number default hr_api.g_number
  ,p_form_window_id              in number
  ,p_object_version_number       in out nocopy number
  ,p_window_name                 in varchar2  default hr_api.g_varchar2
  ,p_user_window_name            in varchar2 default hr_api.g_varchar2
  ,p_description                 in varchar2 default hr_api.g_varchar2
  ,p_height                      in number default hr_api.g_number
  ,p_title                       in varchar2 default hr_api.g_varchar2
  ,p_width                       in number default hr_api.g_number
  ,p_x_position                  in number default hr_api.g_number
  ,p_y_position                  in number default hr_api.g_number
  ,p_information_category        in varchar2 default hr_api.g_varchar2
  ,p_information1                in varchar2 default hr_api.g_varchar2
  ,p_information2                in varchar2 default hr_api.g_varchar2
  ,p_information3                in varchar2 default hr_api.g_varchar2
  ,p_information4                in varchar2 default hr_api.g_varchar2
  ,p_information5                in varchar2 default hr_api.g_varchar2
  ,p_information6                in varchar2 default hr_api.g_varchar2
  ,p_information7                in varchar2 default hr_api.g_varchar2
  ,p_information8                in varchar2 default hr_api.g_varchar2
  ,p_information9                in varchar2 default hr_api.g_varchar2
  ,p_information10               in varchar2 default hr_api.g_varchar2
  ,p_information11               in varchar2 default hr_api.g_varchar2
  ,p_information12               in varchar2 default hr_api.g_varchar2
  ,p_information13               in varchar2 default hr_api.g_varchar2
  ,p_information14               in varchar2 default hr_api.g_varchar2
  ,p_information15               in varchar2 default hr_api.g_varchar2
  ,p_information16               in varchar2 default hr_api.g_varchar2
  ,p_information17               in varchar2 default hr_api.g_varchar2
  ,p_information18               in varchar2 default hr_api.g_varchar2
  ,p_information19               in varchar2 default hr_api.g_varchar2
  ,p_information20               in varchar2 default hr_api.g_varchar2
  ,p_information21               in varchar2 default hr_api.g_varchar2
  ,p_information22               in varchar2 default hr_api.g_varchar2
  ,p_information23               in varchar2 default hr_api.g_varchar2
  ,p_information24               in varchar2 default hr_api.g_varchar2
  ,p_information25               in varchar2 default hr_api.g_varchar2
  ,p_information26               in varchar2 default hr_api.g_varchar2
  ,p_information27               in varchar2 default hr_api.g_varchar2
  ,p_information28               in varchar2 default hr_api.g_varchar2
  ,p_information29               in varchar2 default hr_api.g_varchar2
  ,p_information30               in varchar2 default hr_api.g_varchar2
  );
--
end hr_form_windows_api;

 

/
