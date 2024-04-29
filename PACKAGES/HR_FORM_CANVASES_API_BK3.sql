--------------------------------------------------------
--  DDL for Package HR_FORM_CANVASES_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_CANVASES_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrfcnapi.pkh 120.0 2005/05/31 00:12:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_form_canvas_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_canvas_b
 (p_effective_date                in     date
 ,p_language_code                 in     varchar2
  ,p_canvas_name                  in     varchar2
  --,p_canvas_type                  in     varchar2
  ,p_user_canvas_name             in     varchar2
  ,p_description                  in     varchar2
  ,p_height                       in     number
  ,p_visible                      in     number
  ,p_width                        in     number
  ,p_x_position                   in     number
  ,p_y_position                   in     number
  ,p_information_category         in     varchar2
  ,p_information1                 in     varchar2
  ,p_information2                 in     varchar2
  ,p_information3                 in     varchar2
  ,p_information4                 in     varchar2
  ,p_information5                 in     varchar2
  ,p_information6                 in     varchar2
  ,p_information7                 in     varchar2
  ,p_information8                 in     varchar2
  ,p_information9                 in     varchar2
  ,p_information10                in     varchar2
  ,p_information11                in     varchar2
  ,p_information12                in     varchar2
  ,p_information13                in     varchar2
  ,p_information14                in     varchar2
  ,p_information15                in     varchar2
  ,p_information16                in     varchar2
  ,p_information17                in     varchar2
  ,p_information18                in     varchar2
  ,p_information19                in     varchar2
  ,p_information20                in     varchar2
  ,p_information21                in     varchar2
  ,p_information22                in     varchar2
  ,p_information23                in     varchar2
  ,p_information24                in     varchar2
  ,p_information25                in     varchar2
  ,p_information26                in     varchar2
  ,p_information27                in     varchar2
  ,p_information28                in     varchar2
  ,p_information29                in     varchar2
  ,p_information30                in     varchar2
  ,p_form_canvas_id               in     number
  ,p_object_version_number        in     number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_form_canvas_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_canvas_a
 (p_effective_date                in     date
 ,p_language_code                 in     varchar2
  ,p_canvas_name                  in     varchar2
  --,p_canvas_type                  in     varchar2
  ,p_user_canvas_name             in     varchar2
  ,p_description                  in     varchar2
  ,p_height                       in     number
  ,p_visible                      in     number
  ,p_width                        in     number
  ,p_x_position                   in     number
  ,p_y_position                   in     number
  ,p_information_category         in     varchar2
  ,p_information1                 in     varchar2
  ,p_information2                 in     varchar2
  ,p_information3                 in     varchar2
  ,p_information4                 in     varchar2
  ,p_information5                 in     varchar2
  ,p_information6                 in     varchar2
  ,p_information7                 in     varchar2
  ,p_information8                 in     varchar2
  ,p_information9                 in     varchar2
  ,p_information10                in     varchar2
  ,p_information11                in     varchar2
  ,p_information12                in     varchar2
  ,p_information13                in     varchar2
  ,p_information14                in     varchar2
  ,p_information15                in     varchar2
  ,p_information16                in     varchar2
  ,p_information17                in     varchar2
  ,p_information18                in     varchar2
  ,p_information19                in     varchar2
  ,p_information20                in     varchar2
  ,p_information21                in     varchar2
  ,p_information22                in     varchar2
  ,p_information23                in     varchar2
  ,p_information24                in     varchar2
  ,p_information25                in     varchar2
  ,p_information26                in     varchar2
  ,p_information27                in     varchar2
  ,p_information28                in     varchar2
  ,p_information29                in     varchar2
  ,p_information30                in     varchar2
  ,p_form_canvas_id               in     number
  ,p_object_version_number        in     number);
--
end hr_form_canvases_api_bk3;

 

/