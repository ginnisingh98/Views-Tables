--------------------------------------------------------
--  DDL for Package Body HR_FORM_WINDOW_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_WINDOW_INFO" 
/* $Header: hrfwninf.pkb 120.0 2005/05/31 00:33:26 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_application_id               fnd_application.application_id%TYPE;
  g_form_id                      fnd_form.form_id%TYPE;
  g_form_windows                 t_form_windows := t_form_windows();
--
-- -----------------------------------------------------------------------------
-- |------------------------------< form_windows >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_windows
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_windows
IS
  --
  CURSOR csr_form_windows
    (p_application_id               IN     fnd_application.application_id%TYPE
    ,p_form_id                      IN     fnd_form.form_id%TYPE
    )
  IS
    SELECT fwn.form_window_id
          ,fwn.window_name
          ,fwn.height
          ,fwn.title
          ,fwn.width
          ,fwn.x_position
          ,fwn.y_position
          ,fwn.information_category
          ,fwn.information1
          ,fwn.information2
          ,fwn.information3
          ,fwn.information4
          ,fwn.information5
          ,fwn.information6
          ,fwn.information7
          ,fwn.information8
          ,fwn.information9
          ,fwn.information10
          ,fwn.information11
          ,fwn.information12
          ,fwn.information13
          ,fwn.information14
          ,fwn.information15
          ,fwn.information16
          ,fwn.information17
          ,fwn.information18
          ,fwn.information19
          ,fwn.information20
          ,fwn.information21
          ,fwn.information22
          ,fwn.information23
          ,fwn.information24
          ,fwn.information25
          ,fwn.information26
          ,fwn.information27
          ,fwn.information28
          ,fwn.information29
          ,fwn.information30
      FROM hr_form_windows fwn
     WHERE fwn.application_id = p_application_id
       AND fwn.form_id = p_form_id;
  --
  l_form_windows                 t_form_windows := t_form_windows();
--
BEGIN
  --
  IF (   p_application_id = nvl(g_application_id,hr_api.g_number)
     AND p_form_id = nvl(g_form_id,hr_api.g_number))
  THEN
    --
    -- The form windows have already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_form_windows := g_form_windows;
  --
  ELSE
    --
    -- The identifiers are different to the previous call to this function, or
    -- this is the first call to this function.
    --
    FOR l_form_window IN csr_form_windows
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      )
    LOOP
      l_form_windows.EXTEND;
      l_form_windows(l_form_windows.LAST) := l_form_window;
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_application_id := p_application_id;
    g_form_id := p_form_id;
    g_form_windows := l_form_windows;
  --
  END IF;
  --
  RETURN(l_form_windows);
--
END form_windows;
--
END hr_form_window_info;

/
