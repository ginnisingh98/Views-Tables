--------------------------------------------------------
--  DDL for Package Body GMDOPVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDOPVAL_PUB" AS
/* $Header: GMDPOPVB.pls 120.1 2005/09/29 11:20:45 srsriran noship $ */

/* ====================================================================
  FUNCTION:
    check_duplicate_oprn

  DESCRIPTION:
    This PL/SQL function is responsible for
    checking duplication of operations.

  REQUIREMENTS
    oprn_no and oprn_vers must be non null values.
  SYNOPSIS:
    X_ret := gmdopval_pub.check_duplicate_oprn(poprn_no, poprn_vers, pcalledby_form);

  RETURNS:
       0   Success
      -1   Some required values for procedure are missing.
      -30  GMD_OPRN_EXISTS Duplicate Operation.
 ====================================================================*/
FUNCTION check_duplicate_oprn(poprn_no IN VARCHAR2,
                              poprn_vers IN NUMBER,
                              pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER IS

/*   Local variables.
   ================ */
  l_ret NUMBER := 0;

/*   Cursor Definitions.
   =================== */
  CURSOR Cur_check_dup IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   gmd_operations
                 WHERE  oprn_no = poprn_no
                        AND oprn_vers = poprn_vers);
  duplicate_oprn EXCEPTION;
BEGIN
  IF (poprn_no IS NULL OR poprn_vers IS NULL) THEN
    RETURN -1;
  END IF;
  OPEN Cur_check_dup;
  FETCH Cur_check_dup INTO l_ret;
  IF (Cur_check_dup%FOUND) THEN
    CLOSE Cur_check_dup;
    RAISE duplicate_oprn;
  END IF;
  CLOSE Cur_check_dup;
  RETURN 0;
EXCEPTION
  WHEN duplicate_oprn THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD', 'FM_OPER_CODE_EXISTS');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_OPRN_EXISTS;
    END IF;
END check_duplicate_oprn;

/* ====================================================================
  FUNCTION:
    check_oprn_class

  DESCRIPTION:
    This PL/SQL function is responsible for
    checking that the operation class is valid.

  SYNOPSIS:
    X_ret := gmdopval_pub.check_oprn_class(poprn_class, pcalledby_form);

  RETURNS:
       0   Success
      -1   Some required values for procedure are missing.
      -31  GMD_INV_OPRN_CLASS  Operation class is not valid.
 ==================================================================== */
FUNCTION check_oprn_class(poprn_class IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER IS
/*   Cursor Definitions.
   =================== */
  CURSOR Cur_oprn_class IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   fm_oprn_cls
                 WHERE  oprn_class = poprn_class
                        AND delete_mark = 0);
  invalid_oprn_class EXCEPTION;
  l_ret		   NUMBER;
BEGIN
  IF (poprn_class IS NOT NULL) THEN
    OPEN Cur_oprn_class;
    FETCH Cur_oprn_class INTO l_ret;
    IF (Cur_oprn_class%NOTFOUND) THEN
      CLOSE Cur_oprn_class;
      RAISE invalid_oprn_class;
    END IF;
    CLOSE Cur_oprn_class;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN invalid_oprn_class THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD','FM_INV_OPRN_CLASS');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_INV_OPRN_CLASS;
    END IF;
END check_oprn_class;

/* ====================================================================
  FUNCTION:
    check_activity

  DESCRIPTION:
    This PL/SQL function is responsible for
    checking that the activity is valid.

  SYNOPSIS:
    X_ret := gmdopval_pub.check_activity(pactivity, pcalledby_form);

  REQUIREMENTS
    activity must be a non null value.
  RETURNS:
       0  Success
      -1  Some required values for procedure are missing.
      -32 GMD_ACTV_INVALID Invalid Activity.
 ==================================================================== */
FUNCTION check_activity(pactivity IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER IS
  CURSOR Cur_check_actv IS
    SELECT 1
    FROM   SYS.DUAL
    WHERE EXISTS (SELECT 1
                  FROM   fm_actv_mst
                  WHERE  activity = pactivity
                         AND delete_mark = 0);
  invalid_activity EXCEPTION;
  l_ret		 NUMBER;
BEGIN
  IF (pactivity IS NULL) THEN
    RETURN -1;
  ELSE
    OPEN Cur_check_actv;
    FETCH Cur_check_actv INTO l_ret;
    IF (Cur_check_actv%NOTFOUND) THEN
      CLOSE Cur_check_actv;
      RAISE invalid_activity;
    END IF;
    CLOSE Cur_check_actv;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN invalid_activity THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD','FM_INVACTIVITY');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_ACTV_INVALID;
    END IF;
END check_activity;

/* ====================================================================
  FUNCTION:
    check_resource

  DESCRIPTION:
    This PL/SQL function is responsible for
    checking that the resource is valid.

  SYNOPSIS:
    X_ret := gmdopval_pub.check_resource(presource, pcalledby_form);

  REQUIREMENTS
    resource must be a non null value.

  RETURNS:
       0  Success
      -1  Some required values for procedure are missing.
      -33 GMD_BAD_RESOURCE Invalid resource.
 ==================================================================== */
FUNCTION check_resource(presource IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER IS
  CURSOR Cur_check_rsrc IS
    SELECT 1
    FROM   SYS.DUAL
    WHERE EXISTS (SELECT 1
                  FROM   cr_rsrc_mst
                  WHERE  resources = presource
                         AND delete_mark = 0);
  invalid_resource EXCEPTION;
  l_ret		 NUMBER;
BEGIN
  IF (presource IS NULL) THEN
    RETURN -1;
  ELSE
    OPEN Cur_check_rsrc;
    FETCH Cur_check_rsrc INTO l_ret;
    IF (Cur_check_rsrc%NOTFOUND) THEN
      CLOSE Cur_check_rsrc;
      RAISE invalid_resource;
    END IF;
    CLOSE Cur_check_rsrc;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN invalid_resource THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD','FM_BAD_RESOURCE');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_BAD_RESOURCE;
    END IF;
END check_resource;

/* ====================================================================
  FUNCTION:
    check_cost_cmpnt_cls

  DESCRIPTION:
    This PL/SQL function is responsible for
    checking that the cost component class is a valid value.

  SYNOPSIS:
    X_ret := gmdopval_pub.check_cost_cmpnt_cls(pcost_cmpntcls_code, pcalledby_form);

  REQUIREMENTS
    cost component class must be a non null value.

  RETURNS:
       0  Success
      -1   Some required values for procedure are missing.
      -34 GMD_CMPNT_CLASS_ERR  Invalid cost component class.
 ==================================================================== */
FUNCTION check_cost_cmpnt_cls(pcost_cmpntcls_code IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER IS
/*   Cursor Definitions.
   =================== */
  CURSOR Cur_cost_cmpnt_cls IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   cm_cmpt_mst
                 WHERE  cost_cmpntcls_code = pcost_cmpntcls_code
                        AND delete_mark = 0);
  invalid_cost_cmpnt_cls EXCEPTION;
  l_ret	             NUMBER;
BEGIN
  IF (pcost_cmpntcls_code IS NULL) THEN
    RETURN -1;
  ELSE
    OPEN Cur_cost_cmpnt_cls;
    FETCH Cur_cost_cmpnt_cls INTO l_ret;
    IF (Cur_cost_cmpnt_cls%NOTFOUND) THEN
      CLOSE Cur_cost_cmpnt_cls;
      RAISE invalid_cost_cmpnt_cls;
    END IF;
    CLOSE Cur_cost_cmpnt_cls;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN invalid_cost_cmpnt_cls THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD','FM_BADUSAGEIND');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_CMPNT_CLASS_ERR;
    END IF;
END check_cost_cmpnt_cls;

/* ====================================================================
  FUNCTION:
    check_cost_analysis

  DESCRIPTION:
    This PL/SQL function is responsible for
    checking that the cost analysis code is a valid value.

  SYNOPSIS:
    X_ret := gmdopval_pub.check_cost_analysis(pcost_analysis_code, pcalledby_form);

  RETURNS:
       0   Success
      -1   Some required values for procedure are missing.
      -35  GMD_COST_ANALYSIS_ERR  Invalid Cost analysis code.
 ==================================================================== */
FUNCTION check_cost_analysis(pcost_analysis_code IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER IS
/*   Cursor Definitions.
   =================== */
  CURSOR Cur_analysis_code IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   cm_alys_mst
                 WHERE  cost_analysis_code = pcost_analysis_code
                        AND delete_mark=0);
  invalid_cost_analysis EXCEPTION;
  l_ret	            NUMBER;
BEGIN
  IF (pcost_analysis_code IS NULL) THEN
    RETURN -1;
  ELSE
    OPEN Cur_analysis_code;
    FETCH Cur_analysis_code INTO l_ret;
    IF (Cur_analysis_code%NOTFOUND) THEN
      CLOSE Cur_analysis_code;
      RAISE invalid_cost_analysis;
    END IF;
    CLOSE Cur_analysis_code;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN invalid_cost_analysis THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD','FM_INV_COST_ANALYSIS');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_COST_ANALYSIS_ERR;
    END IF;
END check_cost_analysis;

END GMDOPVAL_PUB;

/
