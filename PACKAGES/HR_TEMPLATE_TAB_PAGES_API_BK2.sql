--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_TAB_PAGES_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_TAB_PAGES_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrttpapi.pkh 120.0 2005/05/31 03:33:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_template_tab_page_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_tab_page_b
  (p_effective_date                  in date
  ,p_language_code                   in varchar2
  ,p_template_canvas_id              in number
  ,p_form_tab_page_id                in number
  ,p_label                           in varchar2
  ,p_navigation_direction            in varchar2
  ,p_visible                         in number
  ,p_information_category            in varchar2
  ,p_information1                    in varchar2
  ,p_information2                    in varchar2
  ,p_information3                    in varchar2
  ,p_information4                    in varchar2
  ,p_information5                    in varchar2
  ,p_information6                    in varchar2
  ,p_information7                    in varchar2
  ,p_information8                    in varchar2
  ,p_information9                    in varchar2
  ,p_information10                   in varchar2
  ,p_information11                   in varchar2
  ,p_information12                   in varchar2
  ,p_information13                   in varchar2
  ,p_information14                   in varchar2
  ,p_information15                   in varchar2
  ,p_information16                   in varchar2
  ,p_information17                   in varchar2
  ,p_information18                   in varchar2
  ,p_information19                   in varchar2
  ,p_information20                   in varchar2
  ,p_information21                   in varchar2
  ,p_information22                   in varchar2
  ,p_information23                   in varchar2
  ,p_information24                   in varchar2
  ,p_information25                   in varchar2
  ,p_information26                   in varchar2
  ,p_information27                   in varchar2
  ,p_information28                   in varchar2
  ,p_information29                   in varchar2
  ,p_information30                   in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_template_tab_page_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_tab_page_a
  (p_effective_date                  in date
  ,p_language_code                   in varchar2
  ,p_template_canvas_id              in number
  ,p_form_tab_page_id                in number
  ,p_label                           in varchar2
  ,p_navigation_direction            in varchar2
  ,p_visible                         in number
  ,p_information_category            in varchar2
  ,p_information1                    in varchar2
  ,p_information2                    in varchar2
  ,p_information3                    in varchar2
  ,p_information4                    in varchar2
  ,p_information5                    in varchar2
  ,p_information6                    in varchar2
  ,p_information7                    in varchar2
  ,p_information8                    in varchar2
  ,p_information9                    in varchar2
  ,p_information10                   in varchar2
  ,p_information11                   in varchar2
  ,p_information12                   in varchar2
  ,p_information13                   in varchar2
  ,p_information14                   in varchar2
  ,p_information15                   in varchar2
  ,p_information16                   in varchar2
  ,p_information17                   in varchar2
  ,p_information18                   in varchar2
  ,p_information19                   in varchar2
  ,p_information20                   in varchar2
  ,p_information21                   in varchar2
  ,p_information22                   in varchar2
  ,p_information23                   in varchar2
  ,p_information24                   in varchar2
  ,p_information25                   in varchar2
  ,p_information26                   in varchar2
  ,p_information27                   in varchar2
  ,p_information28                   in varchar2
  ,p_information29                   in varchar2
  ,p_information30                   in varchar2
  ,p_template_tab_page_id            in number
  ,p_object_version_number           in number
  ,p_override_value_warning          in boolean
  );
--
end hr_template_tab_pages_api_bk2;

 

/
