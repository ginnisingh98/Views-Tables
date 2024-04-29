--------------------------------------------------------
--  DDL for Package Body HR_FORM_TAB_PAGE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_TAB_PAGE_INFO" 
/* $Header: hrftpinf.pkb 120.0 2005/05/31 00:30:35 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_application_id               fnd_application.application_id%TYPE;
  g_form_id                      fnd_form.form_id%TYPE;
  g_form_tab_pages               t_form_tab_pages := t_form_tab_pages();
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_tab_pages >----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_tab_pages
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_tab_pages
IS
  --
  CURSOR csr_form_tab_pages
    (p_application_id               IN     fnd_application.application_id%TYPE
    ,p_form_id                      IN     fnd_form.form_id%TYPE
    )
  IS
    SELECT ftp.form_tab_page_id
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
          ,hr_form_tab_pages_b ftp
          ,hr_form_canvases_b fcn
          ,hr_form_windows_b fwn
     WHERE tpt.language = userenv('LANG')
       AND tpt.tab_page_property_id = tpp.tab_page_property_id
       AND tpp.form_tab_page_id = ftp.form_tab_page_id
       AND ftp.form_canvas_id = fcn.form_canvas_id
       AND fcn.form_window_id = fwn.form_window_id
       AND fwn.application_id = p_application_id
       AND fwn.form_id = p_form_id;
  --
  l_form_tab_pages               t_form_tab_pages := t_form_tab_pages();
--
BEGIN
  --
  IF (   p_application_id = nvl(g_application_id,hr_api.g_number)
     AND p_form_id = nvl(g_form_id,hr_api.g_number))
  THEN
    --
    -- The form tab_pages have already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_form_tab_pages := g_form_tab_pages;
  --
  ELSE
    --
    -- The identifiers are different to the previous call to this function, or
    -- this is the first call to this function.
    --
    FOR l_form_tab_page IN csr_form_tab_pages
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      )
    LOOP
      l_form_tab_pages.EXTEND;
      l_form_tab_pages(l_form_tab_pages.LAST) := l_form_tab_page;
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_application_id := p_application_id;
    g_form_id := p_form_id;
    g_form_tab_pages := l_form_tab_pages;
  --
  END IF;
  --
  RETURN(l_form_tab_pages);
--
END form_tab_pages;
--
END hr_form_tab_page_info;

/
