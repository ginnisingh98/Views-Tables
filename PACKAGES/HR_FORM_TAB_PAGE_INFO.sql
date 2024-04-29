--------------------------------------------------------
--  DDL for Package HR_FORM_TAB_PAGE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TAB_PAGE_INFO" 
/* $Header: hrftpinf.pkh 120.0 2005/05/31 00:30:47 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_form_tab_page IS RECORD
    (form_tab_page_id               hr_form_tab_pages_b.form_tab_page_id%TYPE
    ,tab_page_name                  hr_form_tab_pages_b.tab_page_name%TYPE
    ,canvas_name                    hr_form_canvases_b.canvas_name%TYPE
    ,display_order                  hr_form_tab_pages_b.display_order%TYPE
    ,label                          hr_tab_page_properties_tl.label%TYPE
    ,navigation_direction           hr_tab_page_properties_b.navigation_direction%TYPE
    ,visible                        hr_tab_page_properties_b.visible%TYPE
    ,information_category           hr_tab_page_properties_b.information_category%TYPE
    ,information1                   hr_tab_page_properties_b.information1%TYPE
    ,information2                   hr_tab_page_properties_b.information2%TYPE
    ,information3                   hr_tab_page_properties_b.information3%TYPE
    ,information4                   hr_tab_page_properties_b.information4%TYPE
    ,information5                   hr_tab_page_properties_b.information5%TYPE
    ,information6                   hr_tab_page_properties_b.information6%TYPE
    ,information7                   hr_tab_page_properties_b.information7%TYPE
    ,information8                   hr_tab_page_properties_b.information8%TYPE
    ,information9                   hr_tab_page_properties_b.information9%TYPE
    ,information10                  hr_tab_page_properties_b.information10%TYPE
    ,information11                  hr_tab_page_properties_b.information11%TYPE
    ,information12                  hr_tab_page_properties_b.information12%TYPE
    ,information13                  hr_tab_page_properties_b.information13%TYPE
    ,information14                  hr_tab_page_properties_b.information14%TYPE
    ,information15                  hr_tab_page_properties_b.information15%TYPE
    ,information16                  hr_tab_page_properties_b.information16%TYPE
    ,information17                  hr_tab_page_properties_b.information17%TYPE
    ,information18                  hr_tab_page_properties_b.information18%TYPE
    ,information19                  hr_tab_page_properties_b.information19%TYPE
    ,information20                  hr_tab_page_properties_b.information20%TYPE
    ,information21                  hr_tab_page_properties_b.information21%TYPE
    ,information22                  hr_tab_page_properties_b.information22%TYPE
    ,information23                  hr_tab_page_properties_b.information23%TYPE
    ,information24                  hr_tab_page_properties_b.information24%TYPE
    ,information25                  hr_tab_page_properties_b.information25%TYPE
    ,information26                  hr_tab_page_properties_b.information26%TYPE
    ,information27                  hr_tab_page_properties_b.information27%TYPE
    ,information28                  hr_tab_page_properties_b.information28%TYPE
    ,information29                  hr_tab_page_properties_b.information29%TYPE
    ,information30                  hr_tab_page_properties_b.information30%TYPE
    );
  TYPE t_form_tab_pages IS TABLE OF t_form_tab_page;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_tab_pages >----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all tab pages for a
--   form.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_application_id               Y number   Application identifier
--   p_form_id                      Y number   Form identifier
--
-- Post Success
--   A table containing the details of the form tab pages is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_tab_pages
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_tab_pages;
--
END hr_form_tab_page_info;

 

/
