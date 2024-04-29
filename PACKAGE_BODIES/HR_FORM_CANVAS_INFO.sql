--------------------------------------------------------
--  DDL for Package Body HR_FORM_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_CANVAS_INFO" 
/* $Header: hrfcninf.pkb 120.0 2005/05/31 00:12:57 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_application_id               fnd_application.application_id%TYPE;
  g_form_id                      fnd_form.form_id%TYPE;
  g_form_canvases                t_form_canvases := t_form_canvases();
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_canvases >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_canvases
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_canvases
IS
  --
  CURSOR csr_form_canvases
    (p_application_id               IN     fnd_application.application_id%TYPE
    ,p_form_id                      IN     fnd_form.form_id%TYPE
    )
  IS
    SELECT fcn.form_canvas_id
          ,fcn.canvas_name
          ,fcn.canvas_type
          ,cnp.height
          ,cnp.visible
          ,cnp.width
          ,cnp.x_position
          ,cnp.y_position
          ,cnp.information_category
          ,cnp.information1
          ,cnp.information2
          ,cnp.information3
          ,cnp.information4
          ,cnp.information5
          ,cnp.information6
          ,cnp.information7
          ,cnp.information8
          ,cnp.information9
          ,cnp.information10
          ,cnp.information11
          ,cnp.information12
          ,cnp.information13
          ,cnp.information14
          ,cnp.information15
          ,cnp.information16
          ,cnp.information17
          ,cnp.information18
          ,cnp.information19
          ,cnp.information20
          ,cnp.information21
          ,cnp.information22
          ,cnp.information23
          ,cnp.information24
          ,cnp.information25
          ,cnp.information26
          ,cnp.information27
          ,cnp.information28
          ,cnp.information29
          ,cnp.information30
      FROM hr_canvas_properties cnp
          ,hr_form_canvases_b fcn
          ,hr_form_windows_b fwn
     WHERE cnp.form_canvas_id = fcn.form_canvas_id
       AND fcn.form_window_id = fwn.form_window_id
       AND fwn.application_id = p_application_id
       AND fwn.form_id = p_form_id;
  --
  l_form_canvases                t_form_canvases := t_form_canvases();
--
BEGIN
  --
  IF (   p_application_id = nvl(g_application_id,hr_api.g_number)
     AND p_form_id = nvl(g_form_id,hr_api.g_number))
  THEN
    --
    -- The form canvases have already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_form_canvases := g_form_canvases;
  --
  ELSE
    --
    -- The identifiers are different to the previous call to this function, or
    -- this is the first call to this function.
    --
    FOR l_form_canvas IN csr_form_canvases
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      )
    LOOP
      l_form_canvases.EXTEND;
      l_form_canvases(l_form_canvases.LAST) := l_form_canvas;
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_application_id := p_application_id;
    g_form_id := p_form_id;
    g_form_canvases := l_form_canvases;
  --
  END IF;
  --
  RETURN(l_form_canvases);
--
END form_canvases;
--
END hr_form_canvas_info;

/
