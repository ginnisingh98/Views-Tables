--------------------------------------------------------
--  DDL for Package HR_FORM_CANVASES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_CANVASES_API" AUTHID CURRENT_USER as
/* $Header: hrfcnapi.pkh 120.0 2005/05/31 00:12:37 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_canvas >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This business process inserts a new form canvas in the HR Schema.
--
-- Prerequisites:
--  N/A
--
-- In Parameters:
-- Name                      Reqd    Type       Description
--
-- p_validate                  Y     boolean
-- p_effective_date            Y     date
-- p_language_code             N     default
-- p_form_window_id            Y     number
-- p_canvas_name               Y     varchar2
-- p_canvas_type               Y     varchar2
-- p_user_canvas_name          Y     varchar2
-- p_description               N     varchar2
-- p_height                    N     number
-- p_visible                   N     number
-- p_width                     N     number
-- p_x_position                N     number
-- p_y_position                N     number
-- p_information_category      N     varchar2
-- p_information1              N     varchar2
-- p_information2              N     varchar2
-- p_information3              N     varchar2
-- p_information4              N     varchar2
-- p_information5              N     varchar2
-- p_information6              N     varchar2
-- p_information7              N     varchar2
-- p_information8              N     varchar2
-- p_information9              N     varchar2
-- p_information10             N     varchar2
-- p_information11             N     varchar2
-- p_information12             N     varchar2
-- p_information13             N     varchar2
-- p_information14             N     varchar2
-- p_information15             N     varchar2
-- p_information16             N     varchar2
-- p_information17             N     varchar2
-- p_information18             N     varchar2
-- p_information19             N     varchar2
-- p_information20             N     varchar2
-- p_information21             N     varchar2
-- p_information22             N     varchar2
-- p_information23             N     varchar2
-- p_information24             N     varchar2
-- p_information25             N     varchar2
-- p_information26             N     varchar2
-- p_information27             N     varchar2
-- p_information28             N     varchar2
-- p_information29             N     varchar2
-- p_information30             N     varchar2
--
--
-- Post Success:
--
--
-- Name                           Type     Description
-- p_form_canvas_id               number
-- p_object_version_number        number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_form_canvas
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2 default hr_api.userenv_lang
  ,p_form_window_id               in     number
  ,p_canvas_name                  in     varchar2
  ,p_canvas_type                  in     varchar2
  ,p_user_canvas_name             in     varchar2
  ,p_description                  in     varchar2 default null
  ,p_height                       in     number default null
  ,p_visible                      in     number default null
  ,p_width                        in     number default null
  ,p_x_position                   in     number default null
  ,p_y_position                   in     number default null
  ,p_information_category         in     varchar2 default null
  ,p_information1                 in     varchar2 default null
  ,p_information2                 in     varchar2 default null
  ,p_information3                 in     varchar2 default null
  ,p_information4                 in     varchar2 default null
  ,p_information5                 in     varchar2 default null
  ,p_information6                 in     varchar2 default null
  ,p_information7                 in     varchar2 default null
  ,p_information8                 in     varchar2 default null
  ,p_information9                 in     varchar2 default null
  ,p_information10                in     varchar2 default null
  ,p_information11                in     varchar2 default null
  ,p_information12                in     varchar2 default null
  ,p_information13                in     varchar2 default null
  ,p_information14                in     varchar2 default null
  ,p_information15                in     varchar2 default null
  ,p_information16                in     varchar2 default null
  ,p_information17                in     varchar2 default null
  ,p_information18                in     varchar2 default null
  ,p_information19                in     varchar2 default null
  ,p_information20                in     varchar2 default null
  ,p_information21                in     varchar2 default null
  ,p_information22                in     varchar2 default null
  ,p_information23                in     varchar2 default null
  ,p_information24                in     varchar2 default null
  ,p_information25                in     varchar2 default null
  ,p_information26                in     varchar2 default null
  ,p_information27                in     varchar2 default null
  ,p_information28                in     varchar2 default null
  ,p_information29                in     varchar2 default null
  ,p_information30                in     varchar2 default null
  ,p_form_canvas_id               out nocopy    number
  ,p_object_version_number        out nocopy    number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_canvas >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form canvas from the HR Schema.
--
--
-- Prerequisites: N/A
--
--
-- In Parameters:
-- Name                           Reqd Type     Description
-- p_form_canvas_id                Y   number
-- p_object_version_number         Y   number
--
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
procedure delete_form_canvas
  (p_validate                      in     boolean  default false
   ,p_form_canvas_id               in     number
   ,p_object_version_number        in     number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_form_canvas >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a form canvas in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd  Type     Description
--
-- p_language_code                N     varchar2
-- p_form_canvas_id               Y     number
-- p_object_version_number        Y     number
-- p_canvas_name                  N     varchar2
-- p_canvas_type                  N     varchar2
-- p_user_canvas_name             N     varchar2
-- p_description                  N     varchar2
-- p_height                       N     number
-- p_visible                      N     number
-- p_width                        N     number
-- p_x_position                   N     number
-- p_y_position                   N     number
-- p_information_category         N     varchar2
-- p_information1                 N     varchar2
-- p_information2                 N     varchar2
-- p_information3                 N     varchar2
-- p_information4                 N     varchar2
-- p_information5                 N     varchar2
-- p_information6                 N     varchar2
-- p_information7                 N     varchar2
-- p_information8                 N     varchar2
-- p_information9                 N     varchar2
-- p_information10                N     varchar2
-- p_information11                N     varchar2
-- p_information12                N     varchar2
-- p_information13                N     varchar2
-- p_information14                N     varchar2
-- p_information15                N     varchar2
-- p_information16                N     varchar2
-- p_information17                N     varchar2
-- p_information18                N     varchar2
-- p_information19                N     varchar2
-- p_information20                N     varchar2
-- p_information21                N     varchar2
-- p_information22                N     varchar2
-- p_information23                N     varchar2
-- p_information24                N     varchar2
-- p_information25                N     varchar2
-- p_information26                N     varchar2
-- p_information27                N     varchar2
-- p_information28                N     varchar2
-- p_information29                N     varchar2
-- p_information30                N     varchar2
--
--
-- Post Success:
--
--
-- Name                         Type     Description
-- p_object_version_number      number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_form_canvas
    (p_validate                     in     boolean  default false
    ,p_effective_date               in     date
    ,p_language_code               in     varchar2 default hr_api.userenv_lang
    ,p_form_canvas_id               in     number
    ,p_object_version_number        in out nocopy number
    ,p_canvas_name                  in     varchar2 default hr_api.g_varchar2
    --,p_canvas_type                  in     varchar2 default hr_api.g_varchar2
    ,p_user_canvas_name             in     varchar2 default hr_api.g_varchar2
    ,p_description                  in     varchar2 default hr_api.g_varchar2
    ,p_height                       in     number   default hr_api.g_number
    ,p_visible                      in     number   default hr_api.g_number
    ,p_width                        in     number   default hr_api.g_number
    ,p_x_position                   in     number   default hr_api.g_number
    ,p_y_position                   in     number   default hr_api.g_number
    ,p_information_category         in     varchar2 default hr_api.g_varchar2
    ,p_information1                 in     varchar2 default hr_api.g_varchar2
    ,p_information2                 in     varchar2 default hr_api.g_varchar2
    ,p_information3                 in     varchar2 default hr_api.g_varchar2
    ,p_information4                 in     varchar2 default hr_api.g_varchar2
    ,p_information5                 in     varchar2 default hr_api.g_varchar2
    ,p_information6                 in     varchar2 default hr_api.g_varchar2
    ,p_information7                 in     varchar2 default hr_api.g_varchar2
    ,p_information8                 in     varchar2 default hr_api.g_varchar2
    ,p_information9                 in     varchar2 default hr_api.g_varchar2
    ,p_information10                in     varchar2 default hr_api.g_varchar2
    ,p_information11                in     varchar2 default hr_api.g_varchar2
    ,p_information12                in     varchar2 default hr_api.g_varchar2
    ,p_information13                in     varchar2 default hr_api.g_varchar2
    ,p_information14                in     varchar2 default hr_api.g_varchar2
    ,p_information15                in     varchar2 default hr_api.g_varchar2
    ,p_information16                in     varchar2 default hr_api.g_varchar2
    ,p_information17                in     varchar2 default hr_api.g_varchar2
    ,p_information18                in     varchar2 default hr_api.g_varchar2
    ,p_information19                in     varchar2 default hr_api.g_varchar2
    ,p_information20                in     varchar2 default hr_api.g_varchar2
    ,p_information21                in     varchar2 default hr_api.g_varchar2
    ,p_information22                in     varchar2 default hr_api.g_varchar2
    ,p_information23                in     varchar2 default hr_api.g_varchar2
    ,p_information24                in     varchar2 default hr_api.g_varchar2
    ,p_information25                in     varchar2 default hr_api.g_varchar2
    ,p_information26                in     varchar2 default hr_api.g_varchar2
    ,p_information27                in     varchar2 default hr_api.g_varchar2
    ,p_information28                in     varchar2 default hr_api.g_varchar2
    ,p_information29                in     varchar2 default hr_api.g_varchar2
    ,p_information30                in     varchar2 default hr_api.g_varchar2);
--
end hr_form_canvases_api;

 

/
