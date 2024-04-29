--------------------------------------------------------
--  DDL for Package Body HRI_BPL_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_TERMINATION" AS
/* $Header: hribterm.pkb 120.1 2005/07/29 02:54:32 jtitmas noship $ */
--
-- Varchar2 table type with varchar2 indexing.
--
TYPE g_index_by_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
--
-- Global Varchar2 table type with varchar2 indexing to store employee
-- separation reason. It gets assigned in the function is_vol_sep.
--
g_cache_emp_sep_resns_tab g_index_by_varchar2_tab_type;
--
-- ----------------------------------------------------------------------------
-- Returns separation category classification of leaving reason
-- ----------------------------------------------------------------------------
--
FUNCTION get_separation_category(p_leaving_reason   IN VARCHAR2)
    RETURN VARCHAR2 IS
  --
  -- Local variable to hold the termination type to return
  --
  l_separation_category   VARCHAR2(30);
  --
  -- Cursor to find out the termination type for a particular leaving reason
  --
  CURSOR sep_cat_csr IS
  SELECT separation_category_code
  FROM   hri_cs_sepcr_v
  WHERE  separation_reason_code = p_leaving_reason;
--
BEGIN
  --
  -- If no leaving reason is passed in return 'NA_EDW'
  --
  IF (p_leaving_reason IS NULL) THEN
  --
    l_separation_category := 'NA_EDW';
  --
  ELSE
  --
    BEGIN
      --
      -- If the value for this particular leaving reason is not cached in the
      -- global pl/sql table, then NO_DATA_FOUND Exception will be raised and
      -- the control will pass to the Exception section
      --
      l_separation_category := g_cache_emp_sep_resns_tab(p_leaving_reason);
      --
    EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- When the value for a particular leaving reason is not cached in the
      -- global table, the control comes here
      -- The cursor is opened and the termination type for this leaving reason
      -- is loaded in the global table
      --
      OPEN sep_cat_csr;
      FETCH sep_cat_csr INTO l_separation_category;
      CLOSE sep_cat_csr;
      --
      -- Update cache
      --
      g_cache_emp_sep_resns_tab(p_leaving_reason) := l_separation_category;
      --
    END;
  --
  END IF;
  --
  RETURN(l_separation_category);
  --
--
-- When an exception is raised, the cursor is closed and the exception is passed
-- out of this block and it is handled in the collect procedure where an entry
-- of this is made in the concurrent log
--
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF sep_cat_csr%ISOPEN THEN
      --
      CLOSE sep_cat_csr;
      --
    END IF;
    --
    RAISE;
    --
END get_separation_category;

END hri_bpl_termination;

/
