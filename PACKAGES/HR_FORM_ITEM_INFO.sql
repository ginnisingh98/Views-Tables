--------------------------------------------------------
--  DDL for Package HR_FORM_ITEM_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_ITEM_INFO" 
/* $Header: hrfiminf.pkh 115.4 2003/03/10 11:41:58 adhunter ship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_form_item IS RECORD
    (form_item_id                   hr_form_items_b.form_item_id%TYPE
    ,full_item_name                 hr_form_items_b.full_item_name%TYPE
    ,item_type                      hr_form_items_b.item_type%TYPE
    ,canvas_name                    hr_form_canvases_b.canvas_name%TYPE
    ,tab_page_name                  hr_form_tab_pages_b.tab_page_name%TYPE
    ,radio_button_name              hr_form_items_b.radio_button_name%TYPE
    ,alignment                      hr_item_properties_b.alignment%TYPE
    ,bevel                          hr_item_properties_b.bevel%TYPE
    ,case_restriction               hr_item_properties_b.case_restriction%TYPE
    ,default_value                  hr_item_properties_tl.default_value%TYPE
    ,enabled                        hr_item_properties_b.enabled%TYPE
    ,format_mask                    hr_item_properties_b.format_mask%TYPE
    ,height                         hr_item_properties_b.height%TYPE
    ,information_formula_id         hr_item_properties_b.information_formula_id%TYPE
    ,information_parameter_item1    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item2    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item3    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item4    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item5    hr_form_items_b.full_item_name%TYPE
    ,information_prompt             hr_item_properties_tl.information_prompt%TYPE
    ,insert_allowed                 hr_item_properties_b.insert_allowed%TYPE
    ,label                          hr_item_properties_tl.label%TYPE
    ,prompt_alignment_offset        hr_item_properties_b.prompt_alignment_offset%TYPE
    ,prompt_display_style           hr_item_properties_b.prompt_display_style%TYPE
    ,prompt_edge                    hr_item_properties_b.prompt_edge%TYPE
    ,prompt_edge_alignment          hr_item_properties_b.prompt_edge_alignment%TYPE
    ,prompt_edge_offset             hr_item_properties_b.prompt_edge_offset%TYPE
    ,prompt_text                    hr_item_properties_tl.prompt_text%TYPE
    ,prompt_text_alignment          hr_item_properties_b.prompt_text_alignment%TYPE
    ,query_allowed                  hr_item_properties_b.query_allowed%TYPE
    ,required                       hr_item_properties_b.required%TYPE
    ,tooltip_text                   hr_item_properties_tl.tooltip_text%TYPE
    ,update_allowed                 hr_item_properties_b.update_allowed%TYPE
    ,validation_formula_id          hr_item_properties_b.validation_formula_id%TYPE
    ,validation_parameter_item1     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item2     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item3     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item4     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item5     hr_form_items_b.full_item_name%TYPE
    ,visible                        hr_item_properties_b.visible%TYPE
    ,width                          hr_item_properties_b.width%TYPE
    ,x_position                     hr_item_properties_b.x_position%TYPE
    ,y_position                     hr_item_properties_b.y_position%TYPE
    ,information_category           hr_item_properties_b.information_category%TYPE
    ,information1                   hr_item_properties_b.information1%TYPE
    ,information2                   hr_item_properties_b.information2%TYPE
    ,information3                   hr_item_properties_b.information3%TYPE
    ,information4                   hr_item_properties_b.information4%TYPE
    ,information5                   hr_item_properties_b.information5%TYPE
    ,information6                   hr_item_properties_b.information6%TYPE
    ,information7                   hr_item_properties_b.information7%TYPE
    ,information8                   hr_item_properties_b.information8%TYPE
    ,information9                   hr_item_properties_b.information9%TYPE
    ,information10                  hr_item_properties_b.information10%TYPE
    ,information11                  hr_item_properties_b.information11%TYPE
    ,information12                  hr_item_properties_b.information12%TYPE
    ,information13                  hr_item_properties_b.information13%TYPE
    ,information14                  hr_item_properties_b.information14%TYPE
    ,information15                  hr_item_properties_b.information15%TYPE
    ,information16                  hr_item_properties_b.information16%TYPE
    ,information17                  hr_item_properties_b.information17%TYPE
    ,information18                  hr_item_properties_b.information18%TYPE
    ,information19                  hr_item_properties_b.information19%TYPE
    ,information20                  hr_item_properties_b.information20%TYPE
    ,information21                  hr_item_properties_b.information21%TYPE
    ,information22                  hr_item_properties_b.information22%TYPE
    ,information23                  hr_item_properties_b.information23%TYPE
    ,information24                  hr_item_properties_b.information24%TYPE
    ,information25                  hr_item_properties_b.information25%TYPE
    ,information26                  hr_item_properties_b.information26%TYPE
    ,information27                  hr_item_properties_b.information27%TYPE
    ,information28                  hr_item_properties_b.information28%TYPE
    ,information29                  hr_item_properties_b.information29%TYPE
    ,information30                  hr_item_properties_b.information30%TYPE
    );
  TYPE t_form_items IS TABLE OF t_form_item;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< form_items >------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all items for a
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
--   A table containing the details of the form items is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_items
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_items;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< full_item_name >----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the full item name for a form item.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_item_id                 Y number   Form item identifier
--
-- Post Success
--   The full item name of the form item is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION full_item_name
  (p_form_item_id                 IN     hr_form_items_b.form_item_id%TYPE
  )
RETURN hr_form_items_b.full_item_name%TYPE;
--
END hr_form_item_info;

 

/
