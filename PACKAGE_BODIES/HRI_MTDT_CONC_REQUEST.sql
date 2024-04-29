--------------------------------------------------------
--  DDL for Package Body HRI_MTDT_CONC_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_MTDT_CONC_REQUEST" AS
/* $Header: hrimcncr.pkb 120.4 2006/12/01 13:56:36 jtitmas noship $ */

  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(240) INDEX BY VARCHAR2(240);

  g_workforce_owned_tables    g_varchar2_tab_type;
  g_absence_owned_tables      g_varchar2_tab_type;
  g_recruitment_owned_tables  g_varchar2_tab_type;

-- ------------------------------------------------------------
-- Defines which tables will be fully refreshed by area
-- ------------------------------------------------------------
PROCEDURE set_metadata IS

BEGIN

  -- Tables to full refresh in workforce initial load request set
  g_workforce_owned_tables('HRI_CS_SUPH') := 'Y';
  g_workforce_owned_tables('HRI_CS_ORGH_CT') := 'Y';
  g_workforce_owned_tables('HRI_CS_JOBH_CT') := 'Y';
  g_workforce_owned_tables('HRI_CS_JOB_JOB_ROLE_CT') := 'Y';
  g_workforce_owned_tables('HRI_CS_GEO_LOCHR_CT') := 'Y';
  g_workforce_owned_tables('HRI_CS_POW_BAND_CT') := 'Y';
  g_workforce_owned_tables('HRI_CS_PRSNTYP_CT') := 'Y';
  g_workforce_owned_tables('HRI_INV_SPRTN_RSNS') := 'Y';
  g_workforce_owned_tables('HRI_MB_ASGN_EVENTS_CT') := 'Y';
  g_workforce_owned_tables('HRI_CL_WKR_SUP_STATUS_CT') := 'Y';
  g_workforce_owned_tables('HRI_MAP_SUP_WRKFC_ASG') := 'Y';
  g_workforce_owned_tables('HRI_MAP_SUP_WRKFC') := 'Y';
  g_workforce_owned_tables('HRI_MB_WRKFC_EVT_CT') := 'Y';
  g_workforce_owned_tables('HRI_MDS_WRKFC_MNTH_CT') := 'Y';
  g_workforce_owned_tables('HRI_MDS_WRKFC_MGRH_C01_CT') := 'Y';
  g_workforce_owned_tables('HRI_MDS_WRKFC_ORGH_C01_CT') := 'Y';
  g_workforce_owned_tables('HRI_CS_PER_PERSON_CT') := 'Y';

  -- Tables to full refresh in absence initial load request set
  g_absence_owned_tables('HRI_CS_ABSENCE_CT') := 'Y';
  g_absence_owned_tables('HRI_MB_UTL_ABSNC_CT') := 'Y';
  g_absence_owned_tables('HRI_MDP_SUP_ABSNC_OCC_CT') := 'Y';

  -- Tables to full refresh in recruitment initial load request set
  g_recruitment_owned_tables('HRI_MB_REC_CAND_PIPLN_CT') := 'Y';
  g_recruitment_owned_tables('HRI_MB_REC_VACANCT_CT') := 'Y';

END set_metadata;

-- ------------------------------------------------------------
-- Returns whether a table belongs to an area based on
-- the area associated with the page
-- ------------------------------------------------------------
FUNCTION is_table_owned_by_page
  (p_page_name   IN VARCHAR2,
   p_page_type   IN VARCHAR2,
   p_table_name  IN VARCHAR2)
        RETURN VARCHAR2 IS

  l_return_result   VARCHAR2(30);

BEGIN

  -- Trap no data found if no ownership is found
  BEGIN

    -- BI 2006 Subject Area
    IF p_page_type = 'REPORT' THEN

      -- If the page is absence check that area
      IF (p_page_name = 'HRI_ABSENCE_SUBJECTAREA') THEN

        l_return_result := g_absence_owned_tables(p_table_name);

      -- If the page is workforce check that area
      ELSIF (p_page_name = 'HRI_WORKFORCE_SUBJECTAREA') THEN

        l_return_result := g_workforce_owned_tables(p_table_name);

      -- If the page is recruitment check that area
      ELSIF (p_page_name = 'HRI_RECRUITMENT_SUBJECTAREA') THEN

        l_return_result := g_recruitment_owned_tables(p_table_name);

      -- Otherwise no ownership
      ELSE
        l_return_result := 'N';

      END IF;

    -- DBI page type
    ELSE

      -- If the page is absence check that area
      IF (p_page_name = 'HRI_DBI_LINE_MGR_ABS') THEN

        l_return_result := g_absence_owned_tables(p_table_name);

      -- If the page is workforce check that area
      ELSIF (p_page_name = 'HRI_DBI_CHO_HDC' OR
             p_page_name = 'HRI_DBI_CHO_OVR' OR
             p_page_name = 'HRI_DBI_CHO_TRN' OR
             p_page_name = 'HRI_DBI_LINE_MGR_TRN' OR
             p_page_name = 'HRI_DBI_LINE_MGR_WMV' OR
             p_page_name = 'HRI_DBI_LINE_MGR_WMV_C' OR
             p_page_name = 'HRI_DBI_OA_LINE_MGR') THEN

        l_return_result := g_workforce_owned_tables(p_table_name);

      -- Otherwise no ownership
      ELSE
        l_return_result := 'N';

      END IF;

    END IF;

  -- If no data found there is no ownership
  EXCEPTION WHEN OTHERS THEN
    l_return_result := 'N';
  END;

  RETURN l_return_result;

END is_table_owned_by_page;

-- ------------------------------------------------------------
-- Returns whether a table belongs to an area based on
-- whether any page in the list owns the table
-- ------------------------------------------------------------
FUNCTION is_table_owned_by_page
  (p_page_list   IN hri_bpl_conc_admin.page_list_tab_type,
   p_table_name  IN VARCHAR2)
        RETURN VARCHAR2 IS

  l_page_found  VARCHAR2(30);
  l_index       PLS_INTEGER;

BEGIN

  -- Initialize variables
  l_page_found := 'N';

  -- Trap exception if page list is empty
  BEGIN

    -- Loop through the pages in the list
    l_index := p_page_list.FIRST;
    WHILE l_index IS NOT NULL LOOP

      -- Check whether each page owns the table
      IF (is_table_owned_by_page
           (p_page_name  => p_page_list(l_index).page_name,
            p_page_type  => p_page_list(l_index).page_type,
            p_table_name => p_table_name) = 'Y') THEN
        l_page_found := 'Y';
      END IF;

      -- Move to next page in list
      l_index := p_page_list.NEXT(l_index);

    END LOOP;

  EXCEPTION WHEN OTHERS THEN
    null;
  END;

  RETURN l_page_found;

END is_table_owned_by_page;

-- ------------------------------------------------------------
-- Returns whether a table is a core table i.e. shared
-- among different HRI applications e.g. DBI, Discoverer
-- ------------------------------------------------------------
FUNCTION is_core_hri_process
  (p_table_name  IN VARCHAR2)
        RETURN VARCHAR2 IS

BEGIN

  -- Currently only the supervisor hierarchy table
  -- is common between DBI and non-DBI
  IF (p_table_name = 'HRI_CS_SUPH') THEN

    RETURN 'Y';

  END IF;

  RETURN 'N';

END is_core_hri_process;

-- ------------------------------------------------------------
-- Initializes metadata
-- ------------------------------------------------------------
BEGIN

  set_metadata;

END hri_mtdt_conc_request;

/
