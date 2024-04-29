--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_TAB_PAGE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_TAB_PAGE_INFO" 
/* $Header: hrttpinf.pkb 120.0 2005/05/31 03:33:42 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_form_template_id             hr_form_templates_b.form_template_id%TYPE;
  g_template_tab_pages           t_template_tab_pages := t_template_tab_pages();
  --
  -- Global cursors
  --
  CURSOR csr_template_tab_pages
    (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
    ,p_form_tab_page_id             IN     hr_form_tab_pages_b.form_tab_page_id%TYPE
    )
  IS
    SELECT ttp.template_tab_page_id
          ,ftp.tab_page_name
          ,fcn.canvas_name
          ,ftp.display_order
          ,tpt.label
          ,tpp.navigation_direction
          ,tpp.visible
          ,tpp.information_category
          ,tpp.information1
          ,tpp.information2
          ,tpp.information3
          ,tpp.information4
          ,tpp.information5
          ,tpp.information6
          ,tpp.information7
          ,tpp.information8
          ,tpp.information9
          ,tpp.information10
          ,tpp.information11
          ,tpp.information12
          ,tpp.information13
          ,tpp.information14
          ,tpp.information15
          ,tpp.information16
          ,tpp.information17
          ,tpp.information18
          ,tpp.information19
          ,tpp.information20
          ,tpp.information21
          ,tpp.information22
          ,tpp.information23
          ,tpp.information24
          ,tpp.information25
          ,tpp.information26
          ,tpp.information27
          ,tpp.information28
          ,tpp.information29
          ,tpp.information30
      FROM hr_tab_page_properties_tl tpt
          ,hr_tab_page_properties_b tpp
          ,hr_template_tab_pages_b ttp
          ,hr_template_canvases_b tcn
          ,hr_template_windows_b twn
          ,hr_form_canvases_b fcn
          ,hr_form_tab_pages_b ftp
     WHERE tpt.language (+) = userenv('LANG')
       AND tpt.tab_page_property_id (+) = tpp.tab_page_property_id
       AND tpp.template_tab_page_id (+) = ttp.template_tab_page_id
       AND ttp.form_tab_page_id (+) = p_form_tab_page_id
       AND ttp.template_canvas_id (+) = tcn.template_canvas_id
       AND tcn.template_window_id (+) = twn.template_window_id
       AND twn.form_template_id (+) = p_form_template_id
       AND fcn.form_canvas_id = ftp.form_canvas_id
       AND ftp.form_tab_page_id = p_form_tab_page_id
  ORDER BY ttp.template_tab_page_id;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< template_tab_pages >--------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_tab_pages
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_tab_pages
IS
  --
  l_template_tab_pages           t_template_tab_pages                   := t_template_tab_pages();
  l_form_tab_pages               hr_form_tab_page_info.t_form_tab_pages := hr_form_tab_page_info.t_form_tab_pages();
  l_index_number                 NUMBER;
  l_template_tab_page            t_template_tab_page;
  l_template_tab_page_null       t_template_tab_page;
--
BEGIN
  --
  IF (p_form_template_id = nvl(g_form_template_id,hr_api.g_number))
  THEN
    --
    -- The template tab pages have already been found with a previous call to
    -- this function. Just return the global variable.
    --
    l_template_tab_pages := g_template_tab_pages;
  --
  ELSE
    --
    -- The identifier is different to the previous call to this function, or
    -- this is the first call to this function.
    --
    l_form_tab_pages := hr_form_tab_page_info.form_tab_pages
      (p_application_id               => hr_form_template_info.application_id(p_form_template_id)
      ,p_form_id                      => hr_form_template_info.form_id(p_form_template_id)
      );
    l_index_number := l_form_tab_pages.FIRST;
    WHILE l_index_number IS NOT NULL
    LOOP
      l_template_tab_page := l_template_tab_page_null;
      OPEN csr_template_tab_pages
        (p_form_template_id             => p_form_template_id
        ,p_form_tab_page_id             => l_form_tab_pages(l_index_number).form_tab_page_id
        );
      FETCH csr_template_tab_pages INTO l_template_tab_page;
      CLOSE csr_template_tab_pages;
      IF (l_template_tab_page.tab_page_name IS NULL)
      THEN
        l_template_tab_page.tab_page_name := l_form_tab_pages(l_index_number).tab_page_name;
        l_template_tab_page.canvas_name := l_form_tab_pages(l_index_number).canvas_name;
      END IF;
      IF (l_template_tab_page.template_tab_page_id IS NULL)
      THEN
        l_template_tab_page.visible := 5;
      END IF;
      l_template_tab_pages.EXTEND;
      l_template_tab_pages(l_template_tab_pages.LAST) := l_template_tab_page;
      l_index_number := l_form_tab_pages.NEXT(l_index_number);
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_form_template_id := p_form_template_id;
    g_template_tab_pages := l_template_tab_pages;
  --
  END IF;
  --
  RETURN(l_template_tab_pages);
--
END template_tab_pages;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< template_tab_pages_pst >------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_tab_pages_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_tab_pages_pst
IS
  --
  l_template_tab_pages_pst       t_template_tab_pages_pst;
  l_template_tab_pages           t_template_tab_pages     := t_template_tab_pages();
  l_index_number                 NUMBER;
--
BEGIN
  --
  l_template_tab_pages := template_tab_pages
    (p_form_template_id             => p_form_template_id
    );
  --
  l_index_number := l_template_tab_pages.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_template_tab_pages_pst(l_index_number) := l_template_tab_pages(l_index_number);
    l_index_number := l_template_tab_pages.NEXT(l_index_number);
  END LOOP;
  --
  RETURN(l_template_tab_pages_pst);
--
END template_tab_pages_pst;
--
END hr_template_tab_page_info;

/
