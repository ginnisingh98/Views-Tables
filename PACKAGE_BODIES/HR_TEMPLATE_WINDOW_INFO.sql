--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_WINDOW_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_WINDOW_INFO" 
/* $Header: hrtwninf.pkb 120.0 2005/05/31 03:35:04 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_form_template_id             hr_form_templates_b.form_template_id%TYPE;
  g_template_windows             t_template_windows := t_template_windows();
  --
  -- Global cursors
  --
  CURSOR csr_template_windows
    (p_application_id               IN     hr_form_templates_b.application_id%TYPE
    ,p_form_id                      IN     hr_form_templates_b.form_id%TYPE
    ,p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
    )
  IS
    SELECT twn.template_window_id
          ,fwn.window_name
          ,wnp.height
          ,wpt.title
          ,wnp.width
          ,wnp.x_position
          ,wnp.y_position
          ,wnp.information_category
          ,wnp.information1
          ,wnp.information2
          ,wnp.information3
          ,wnp.information4
          ,wnp.information5
          ,wnp.information6
          ,wnp.information7
          ,wnp.information8
          ,wnp.information9
          ,wnp.information10
          ,wnp.information11
          ,wnp.information12
          ,wnp.information13
          ,wnp.information14
          ,wnp.information15
          ,wnp.information16
          ,wnp.information17
          ,wnp.information18
          ,wnp.information19
          ,wnp.information20
          ,wnp.information21
          ,wnp.information22
          ,wnp.information23
          ,wnp.information24
          ,wnp.information25
          ,wnp.information26
          ,wnp.information27
          ,wnp.information28
          ,wnp.information29
          ,wnp.information30
      FROM hr_window_properties_tl wpt
          ,hr_window_properties_b wnp
          ,hr_template_windows_b twn
          ,hr_form_windows_b fwn
     WHERE wpt.language (+) = userenv('LANG')
       AND wpt.window_property_id (+) = wnp.window_property_id
       AND wnp.template_window_id (+) = twn.template_window_id
       AND twn.form_window_id (+) = fwn.form_window_id
       AND twn.form_template_id (+) = p_form_template_id
       AND fwn.form_id = p_form_id
       AND fwn.application_id = p_application_id;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< template_windows >---------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_windows
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_windows
IS
  --
  l_template_windows             t_template_windows                 := t_template_windows();
--
BEGIN
  --
  IF (p_form_template_id = nvl(g_form_template_id,hr_api.g_number))
  THEN
    --
    -- The template windows have already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_template_windows := g_template_windows;
  --
  ELSE
    --
    -- The identifier is different to the previous call to this function, or
    -- this is the first call to this function.
    --
    FOR l_template_window IN csr_template_windows
      (p_application_id               => hr_form_template_info.application_id(p_form_template_id)
      ,p_form_id                      => hr_form_template_info.form_id(p_form_template_id)
      ,p_form_template_id             => p_form_template_id
      )
    LOOP
      l_template_windows.EXTEND;
      l_template_windows(l_template_windows.LAST) := l_template_window;
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_form_template_id := p_form_template_id;
    g_template_windows := l_template_windows;
  --
  END IF;
  --
  RETURN(l_template_windows);
--
END template_windows;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< template_windows_pst >-------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_windows_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_windows_pst
IS
  --
  l_template_windows_pst         t_template_windows_pst;
  l_template_windows             t_template_windows     := t_template_windows();
  l_index_number                 NUMBER;
--
BEGIN
  --
  l_template_windows := template_windows
    (p_form_template_id             => p_form_template_id
    );
  --
  l_index_number := l_template_windows.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_template_windows_pst(l_index_number) := l_template_windows(l_index_number);
    l_index_number := l_template_windows.NEXT(l_index_number);
  END LOOP;
  --
  RETURN(l_template_windows_pst);
--
END template_windows_pst;
--
END hr_template_window_info;

/
