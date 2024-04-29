--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_UTIL_SNPSHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_UTIL_SNPSHT" AS
/* $Header: hrioputs.pkb 120.1 2005/09/20 05:12 jrstewar noship $ */

/* Returns whether or not the given manager is classified as */
/* senior on the given date */
FUNCTION is_manager_senior(p_supervisor_id   IN NUMBER,
                           p_effective_date  IN DATE)
           RETURN BOOLEAN IS

  l_count   PLS_INTEGER;

  CURSOR senior_mgr_csr IS
  SELECT 1
  FROM hri_cl_per_snrmgr_ct
  WHERE id = p_supervisor_id
  AND p_effective_date BETWEEN start_date AND end_date;

BEGIN

/* Get a rowcount from the senior manager table */
  OPEN senior_mgr_csr;
  FETCH senior_mgr_csr INTO l_count;
  CLOSE senior_mgr_csr;

  IF (l_count > 0) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

END is_manager_senior;

/* Returns whether to use a snapshot for the given manager and date */
FUNCTION use_wrkfc_snpsht_for_mgr(p_supervisor_id   IN NUMBER,
                                  p_effective_date  IN DATE)
           RETURN BOOLEAN IS

  l_count   PLS_INTEGER;

  CURSOR wrkfc_snapshot_csr IS
  SELECT 1
  FROM hri_cal_snpsht_wrkfc
  WHERE snapshot_date = p_effective_date;

BEGIN

/* If the manager is classified as senior, check whether a snapshot is */
/* available for the given date */
  IF (is_manager_senior(p_supervisor_id  => p_supervisor_id,
                        p_effective_date => p_effective_date)) THEN
    OPEN wrkfc_snapshot_csr;
    FETCH wrkfc_snapshot_csr INTO l_count;
    CLOSE wrkfc_snapshot_csr;

    IF (l_count > 0) THEN
      RETURN TRUE;
    END IF;
  END IF;

  RETURN FALSE;

END use_wrkfc_snpsht_for_mgr;

/* Returns whether to use a snapshot for the given manager and date */
FUNCTION use_wcnt_chg_snpsht_for_mgr(p_supervisor_id   IN NUMBER,
                                     p_effective_date  IN DATE)
           RETURN BOOLEAN IS

  l_count   PLS_INTEGER;

  CURSOR wcnt_chg_snapshot_csr IS
  SELECT 1
  FROM hri_cal_snpsht_wcnt_chg
  WHERE snapshot_date = p_effective_date;

BEGIN

/* If the manager is classified as senior, check whether a snapshot is */
/* available for the given date */
  IF (is_manager_senior(p_supervisor_id  => p_supervisor_id,
                        p_effective_date => p_effective_date)) THEN
    OPEN wcnt_chg_snapshot_csr;
    FETCH wcnt_chg_snapshot_csr INTO l_count;
    CLOSE wcnt_chg_snapshot_csr;

    IF (l_count > 0) THEN
      RETURN TRUE;
    END IF;
  END IF;

  RETURN FALSE;

END use_wcnt_chg_snpsht_for_mgr;

/* Returns whether to use a snapshot for the given manager and date */
FUNCTION use_absnc_snpsht_for_mgr(p_supervisor_id   IN NUMBER,
                                     p_effective_date  IN DATE)
           RETURN BOOLEAN IS

  l_count   PLS_INTEGER;


BEGIN

/* If the manager is classified as senior, check whether a snapshot is */
/* available for the given date */

/* Absence doesn't support Snap Shot MV's 70C baseline */

RETURN FALSE;

END use_absnc_snpsht_for_mgr;

END hri_oltp_pmv_util_snpsht;

/
