--------------------------------------------------------
--  DDL for Package Body HR_FORM_ITEM_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_ITEM_INFO" 
/* $Header: hrfiminf.pkb 115.4 2003/03/11 16:11:50 adhunter ship $ */
AS
  --
  -- Global variables
  --
  g_application_id               fnd_application.application_id%TYPE;
  g_form_id                      fnd_form.form_id%TYPE;
  g_form_items                   t_form_items := t_form_items();
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< form_items >------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_items
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_items
IS
  --
  CURSOR csr_form_items
    (p_application_id               IN     fnd_application.application_id%TYPE
    ,p_form_id                      IN     fnd_form.form_id%TYPE
    )
  IS
    SELECT fim.form_item_id
          ,fim.full_item_name
          ,fim.item_type
          ,fcn.canvas_name
          ,ftp.tab_page_name
          ,fim.radio_button_name
          ,itp.alignment
          ,itp.bevel
          ,itp.case_restriction
          ,itptl.default_value
          ,itp.enabled
          ,itp.format_mask
          ,itp.height
          ,itp.information_formula_id
          ,fim.full_item_name           information_parameter_item1 --placeholder value only
          ,fim.full_item_name           information_parameter_item2 --placeholder value only
          ,fim.full_item_name           information_parameter_item3 --placeholder value only
          ,fim.full_item_name           information_parameter_item4 --placeholder value only
          ,fim.full_item_name           information_parameter_item5 --placeholder value only
--          ,ip1.full_item_name information_parameter_item1
--          ,ip2.full_item_name information_parameter_item2
--          ,ip3.full_item_name information_parameter_item3
--          ,ip4.full_item_name information_parameter_item4
--          ,ip5.full_item_name information_parameter_item5
          ,itptl.information_prompt
          ,itp.insert_allowed
          ,itptl.label
          ,itp.prompt_alignment_offset
          ,itp.prompt_display_style
          ,itp.prompt_edge
          ,itp.prompt_edge_alignment
          ,itp.prompt_edge_offset
          ,itptl.prompt_text
          ,itp.prompt_text_alignment
          ,itp.query_allowed
          ,itp.required
          ,itptl.tooltip_text
          ,itp.update_allowed
          ,itp.validation_formula_id
          ,fim.full_item_name           validation_parameter_item1 --placeholder value only
          ,fim.full_item_name           validation_parameter_item2 --placeholder value only
          ,fim.full_item_name           validation_parameter_item3 --placeholder value only
          ,fim.full_item_name           validation_parameter_item4 --placeholder value only
          ,fim.full_item_name           validation_parameter_item5 --placeholder value only
--          ,vp1.full_item_name validation_parameter_item1
--          ,vp2.full_item_name validation_parameter_item2
--          ,vp3.full_item_name validation_parameter_item3
--          ,vp4.full_item_name validation_parameter_item4
--          ,vp5.full_item_name validation_parameter_item5
          ,itp.visible
          ,itp.width
          ,itp.x_position
          ,itp.y_position
          ,itp.information_category
          ,itp.information1
          ,itp.information2
          ,itp.information3
          ,itp.information4
          ,itp.information5
          ,itp.information6
          ,itp.information7
          ,itp.information8
          ,itp.information9
          ,itp.information10
          ,itp.information11
          ,itp.information12
          ,itp.information13
          ,itp.information14
          ,itp.information15
          ,itp.information16
          ,itp.information17
          ,itp.information18
          ,itp.information19
          ,itp.information20
          ,itp.information21
          ,itp.information22
          ,itp.information23
          ,itp.information24
          ,itp.information25
          ,itp.information26
          ,itp.information27
          ,itp.information28
          ,itp.information29
          ,itp.information30
      FROM
--           hr_form_items_b vp5
--          ,hr_form_items_b vp4
--          ,hr_form_items_b vp3
--          ,hr_form_items_b vp2
--          ,hr_form_items_b vp1
--          ,hr_form_items_b ip5
--          ,hr_form_items_b ip4
--          ,hr_form_items_b ip3
--          ,hr_form_items_b ip2
--          ,hr_form_items_b ip1
           hr_form_tab_pages_b ftp
          ,hr_form_canvases_b fcn
          ,hr_form_items_b fim
          ,hr_item_properties_b itp
          ,hr_item_properties_tl itptl
     WHERE
--           vp5.form_item_id (+) = fim.validation_parameter_item_id5
--       AND vp4.form_item_id (+) = fim.validation_parameter_item_id4
--       AND vp3.form_item_id (+) = fim.validation_parameter_item_id3
--       AND vp2.form_item_id (+) = fim.validation_parameter_item_id2
--       AND vp1.form_item_id (+) = fim.validation_parameter_item_id1
--       AND ip5.form_item_id (+) = fim.information_parameter_item_id5
--       AND ip4.form_item_id (+) = fim.information_parameter_item_id4
--       AND ip3.form_item_id (+) = fim.information_parameter_item_id3
--       AND ip2.form_item_id (+) = fim.information_parameter_item_id2
--       AND ip1.form_item_id (+) = fim.information_parameter_item_id1
           itp.form_item_id (+) = fim.form_item_id
       AND itptl.item_property_id (+) = itp.item_property_id
       AND itptl.language (+) = userenv('LANG')
       AND ftp.form_tab_page_id (+) = fim.form_tab_page_id
       AND fcn.form_canvas_id = fim.form_canvas_id
       AND fim.application_id = p_application_id
       AND fim.form_id = p_form_id;

  --
  l_form_items                   t_form_items := t_form_items();
  --
  CURSOR csr_info_param_items(p_form_item_id number) IS
    SELECT fi1.full_item_name
          ,fi2.full_item_name
          ,fi3.full_item_name
          ,fi4.full_item_name
          ,fi5.full_item_name
     FROM hr_item_properties_b ip
         ,hr_form_items_b fi1
         ,hr_form_items_b fi2
         ,hr_form_items_b fi3
         ,hr_form_items_b fi4
         ,hr_form_items_b fi5
    WHERE ip.form_item_id = p_form_item_id
      AND fi1.form_item_id (+) = ip.information_parameter_item_id1
      AND fi2.form_item_id (+) = ip.information_parameter_item_id2
      AND fi3.form_item_id (+) = ip.information_parameter_item_id3
      AND fi4.form_item_id (+) = ip.information_parameter_item_id4
      AND fi5.form_item_id (+) = ip.information_parameter_item_id5;
   --
  CURSOR csr_valid_param_items(p_form_item_id number) IS
    SELECT fi1.full_item_name
          ,fi2.full_item_name
          ,fi3.full_item_name
          ,fi4.full_item_name
          ,fi5.full_item_name
     FROM hr_item_properties_b ip
         ,hr_form_items_b fi1
         ,hr_form_items_b fi2
         ,hr_form_items_b fi3
         ,hr_form_items_b fi4
         ,hr_form_items_b fi5
    WHERE ip.form_item_id = p_form_item_id
      AND fi1.form_item_id (+) = ip.validation_parameter_item_id1
      AND fi2.form_item_id (+) = ip.validation_parameter_item_id2
      AND fi3.form_item_id (+) = ip.validation_parameter_item_id3
      AND fi4.form_item_id (+) = ip.validation_parameter_item_id4
      AND fi5.form_item_id (+) = ip.validation_parameter_item_id5;
--
BEGIN
  --
  IF (   p_application_id = nvl(g_application_id,hr_api.g_number)
     AND p_form_id = nvl(g_form_id,hr_api.g_number))
  THEN
    --
    -- The form items have already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_form_items := g_form_items;
  --
  ELSE
    --
    -- The identifiers are different to the previous call to this function, or
    -- this is the first call to this function.
    --
    FOR l_form_item IN csr_form_items
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      )
    LOOP
      l_form_items.EXTEND;
      --
      --added for 2832094: only retrieve the parameters if there is a formula
      --
      if l_form_item.information_formula_id is not null then
        open csr_info_param_items(l_form_item.form_item_id);
        fetch csr_info_param_items into l_form_item.information_parameter_item1
                                       ,l_form_item.information_parameter_item2
                                       ,l_form_item.information_parameter_item3
                                       ,l_form_item.information_parameter_item4
                                       ,l_form_item.information_parameter_item5;
        close csr_info_param_items;
      else
        l_form_item.information_parameter_item1:=null;
        l_form_item.information_parameter_item2:=null;
        l_form_item.information_parameter_item3:=null;
        l_form_item.information_parameter_item4:=null;
        l_form_item.information_parameter_item5:=null;
      end if;
      if l_form_item.validation_formula_id is not null then
        open csr_valid_param_items(l_form_item.form_item_id);
        fetch csr_valid_param_items into l_form_item.validation_parameter_item1
                                       ,l_form_item.validation_parameter_item2
                                       ,l_form_item.validation_parameter_item3
                                       ,l_form_item.validation_parameter_item4
                                       ,l_form_item.validation_parameter_item5;
        close csr_valid_param_items;
      else
        l_form_item.validation_parameter_item1:=null;
        l_form_item.validation_parameter_item2:=null;
        l_form_item.validation_parameter_item3:=null;
        l_form_item.validation_parameter_item4:=null;
        l_form_item.validation_parameter_item5:=null;
      end if;
      --
      l_form_items(l_form_items.LAST) := l_form_item;
      --
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_application_id := p_application_id;
    g_form_id := p_form_id;
    g_form_items := l_form_items;
  --
  END IF;
  --
  RETURN(l_form_items);
--
END form_items;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< full_item_name >----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION full_item_name
  (p_form_item_id                 IN     hr_form_items_b.form_item_id%TYPE
  )
RETURN hr_form_items_b.full_item_name%TYPE
IS
  --
  CURSOR csr_form_items
    (p_form_item_id                  IN     hr_form_items_b.form_item_id%TYPE
    )
  IS
    SELECT fim.full_item_name
      FROM hr_form_items_b fim
     WHERE fim.form_item_id = p_form_item_id;
  l_form_item                    csr_form_items%ROWTYPE;
--
BEGIN
  --
  IF (p_form_item_id IS NULL)
  THEN
    NULL;
  ELSE
    OPEN csr_form_items
      (p_form_item_id => p_form_item_id
      );
    FETCH csr_form_items INTO l_form_item;
    CLOSE csr_form_items;
  END IF;
  RETURN(l_form_item.full_item_name);
--
END full_item_name;
--
END hr_form_item_info;

/
