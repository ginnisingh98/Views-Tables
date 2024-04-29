--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_CANVAS_INFO" 
/* $Header: hrtcninf.pkb 120.0 2005/05/31 02:58:04 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_form_template_id             hr_form_templates_b.form_template_id%TYPE;
  g_template_canvases            t_template_canvases := t_template_canvases();
  --
  -- Global cursors
  --
  CURSOR csr_template_canvases
    (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
    ,p_form_canvas_id               IN     hr_form_canvases_b.form_canvas_id%TYPE
    )
  IS
    SELECT tcn.template_canvas_id
          ,fcn.canvas_name
          ,fcn.canvas_type
          ,fwn.window_name
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
          ,hr_template_canvases_b tcn
          ,hr_template_windows_b twn
          ,hr_form_windows_b fwn
          ,hr_form_canvases_b fcn
     WHERE cnp.template_canvas_id (+) = tcn.template_canvas_id
       AND tcn.form_canvas_id (+) = p_form_canvas_id
       AND tcn.template_window_id (+) = twn.template_window_id
       AND twn.form_template_id (+) = p_form_template_id
       AND fwn.form_window_id = fcn.form_window_id
       AND fcn.form_canvas_id = p_form_canvas_id
  ORDER BY tcn.template_canvas_id;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< template_canvases >---------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_canvases
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_canvases
IS
  --
  l_template_canvases            t_template_canvases                 := t_template_canvases();
  l_form_canvases                hr_form_canvas_info.t_form_canvases := hr_form_canvas_info.t_form_canvases();
  l_index_number                 NUMBER;
  l_template_canvas              t_template_canvas;
  l_template_canvas_null         t_template_canvas;
--
BEGIN
  --
  IF (p_form_template_id = nvl(g_form_template_id,hr_api.g_number))
  THEN
    --
    -- The template canvases have already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_template_canvases := g_template_canvases;
  --
  ELSE
    --
    -- The identifier is different to the previous call to this function, or
    -- this is the first call to this function.
    --
    l_form_canvases := hr_form_canvas_info.form_canvases
      (p_application_id               => hr_form_template_info.application_id(p_form_template_id)
      ,p_form_id                      => hr_form_template_info.form_id(p_form_template_id)
      );
    l_index_number := l_form_canvases.FIRST;
    WHILE l_index_number IS NOT NULL
    LOOP
      l_template_canvas := l_template_canvas_null;
      OPEN csr_template_canvases
        (p_form_template_id             => p_form_template_id
        ,p_form_canvas_id               => l_form_canvases(l_index_number).form_canvas_id
        );
      FETCH csr_template_canvases INTO l_template_canvas;
      CLOSE csr_template_canvases;
      IF (l_template_canvas.canvas_name IS NULL)
      THEN
        l_template_canvas.canvas_name := l_form_canvases(l_index_number).canvas_name;
        l_template_canvas.canvas_type := l_form_canvases(l_index_number).canvas_type;
      END IF;
      IF (l_template_canvas.template_canvas_id IS NULL)
      THEN
        l_template_canvas.visible := 5;
      END IF;
      l_template_canvases.EXTEND;
      l_template_canvases(l_template_canvases.LAST) := l_template_canvas;
      l_index_number := l_form_canvases.NEXT(l_index_number);
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_form_template_id := p_form_template_id;
    g_template_canvases := l_template_canvases;
  --
  END IF;
  --
  RETURN(l_template_canvases);
--
END template_canvases;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< template_canvases_pst >-------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_canvases_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_canvases_pst
IS
  --
  l_template_canvases_pst        t_template_canvases_pst;
  l_template_canvases            t_template_canvases     := t_template_canvases();
  l_index_number                 NUMBER;
--
BEGIN
  --
  l_template_canvases := template_canvases
    (p_form_template_id             => p_form_template_id
    );
  --
  l_index_number := l_template_canvases.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_template_canvases_pst(l_index_number) := l_template_canvases(l_index_number);
    l_index_number := l_template_canvases.NEXT(l_index_number);
  END LOOP;
  --
  RETURN(l_template_canvases_pst);
--
END template_canvases_pst;
--
END hr_template_canvas_info;

/
