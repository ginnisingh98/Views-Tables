--------------------------------------------------------
--  DDL for Package Body HRI_BPL_SYSTEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_SYSTEM" AS
/* $Header: hribsys.pkb 120.0 2005/10/21 08:23:24 jtitmas noship $ */

  g_full_hr_install    VARCHAR2(5);

-- Populates global with whether system has full HR installation
PROCEDURE cache_hr_install IS

BEGIN

  -- Check the product installation and the HRI profile option
  IF hr_general.chk_product_installed(800) = 'FALSE' OR
     nvl(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N') = 'Y' THEN
    g_full_hr_install := 'N';
  ELSE
    g_full_hr_install := 'Y';
  END IF;

END cache_hr_install;

-- Returns 'N' for a shared HR install and 'Y' for full HR install
FUNCTION is_full_hr_installed RETURN VARCHAR2 IS

BEGIN

  -- Cache global on first run
  IF (g_full_hr_install IS NULL) THEN
    cache_hr_install;
  END IF;

  -- Return result from global
  RETURN g_full_hr_install;

END is_full_hr_installed;

END hri_bpl_system;

/
