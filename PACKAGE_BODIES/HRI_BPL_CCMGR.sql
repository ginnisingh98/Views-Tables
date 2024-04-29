--------------------------------------------------------
--  DDL for Package Body HRI_BPL_CCMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_CCMGR" AS
/* $Header: hribccmgr.pkb 120.0.12000000.2 2007/04/12 12:03:01 smohapat noship $ */

FUNCTION get_ccmgr_id(p_organization_id    IN NUMBER)
     RETURN NUMBER IS

  CURSOR ccmgr_csr IS
  SELECT
   o_mgr.org_information2
  FROM
   hri_cl_org_cc_v cl_cc
  ,hr_organization_information o_mgr
  WHERE o_mgr.org_information_context = 'Organization Name Alias'
  AND cl_cc.ID = o_mgr.organization_id
  AND cl_cc.ID = p_organization_id;

  l_ccmgr_id  NUMBER;

BEGIN

  OPEN ccmgr_csr;
  FETCH ccmgr_csr INTO l_ccmgr_id;
  CLOSE ccmgr_csr;

  IF l_ccmgr_id IS NULL THEN
    l_ccmgr_id := -1;
  END IF;

  RETURN l_ccmgr_id;

EXCEPTION WHEN OTHERS THEN

  IF ccmgr_csr%ISOPEN THEN
    CLOSE ccmgr_csr;
  END IF;

  RETURN -1;

END get_ccmgr_id;

END hri_bpl_ccmgr;

/
