--------------------------------------------------------
--  DDL for Package Body GMI_VALID_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_VALID_GRP" AS
-- $Header: GMIGVALB.pls 115.4 99/08/23 07:38:20 porting shi $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--|  FILE NAME                                                               |
--|       GMIGVALB.pls                                                       |
--|                                                                          |
--|  PACKAGE NAME                                                            |
--|       GMI_VALID_GRP                                                      |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This package defines all validation functions that are used by the |
--|       Inventory APIs.                                                    |
--|                                                                          |
--|  CONTENTS                                                                |
--|       Validate_item_existance                                            |
--|       Validate_dualum_ind                                                |
--|       Validate_item_um2                                                  |
--|       Validate_deviation                                                 |
--|       Validate_deviation                                                 |
--|       Validate_lot_ctl                                                   |
--|       Validate_lot_indivisible                                           |
--|       Validate_sublot_ctl                                                |
--|       Validate_loct_ctl                                                  |
--|       Validate_noninv_ind                                                |
--|       Validate_match_type                                                |
--|       Validate_inactive_ind                                              |
--|       Validate_inv_type                                                  |
--|       Validate_shelf_life                                                |
--|       Validate_retest_interval                                           |
--|       Validate_item_abccode                                              |
--|       Validate_gl_class                                                  |
--|       Validate_inv_class                                                 |
--|       Validate_sales_class                                               |
--|       Validate_ship_class                                                |
--|       Validate_frt_class                                                 |
--|       Validate_price_class                                               |
--|       Validate_storage_class                                             |
--|       Validate_purch_class                                               |
--|       Validate_tax_class                                                 |
--|       Validate_customs_class                                             |
--|       Validate_alloc_class                                               |
--|       Validate_planning_class                                            |
--|       Validate_itemcost_class                                            |
--|       Validate_cost_mthd_code                                            |
--|       Validate_grade_ctl                                                 |
--|       Validate_status_ctl                                                |
--|       Validate_qc_grade                                                  |
--|       Validate_lot_status                                                |
--|       Validate_qchold_res_code                                           |
--|       Validate_expaction_code                                            |
--|       Validate_expaction_interval                                        |
--|       Validate_experimental_ind                                          |
--|       Validate_seq_dpnd_class                                            |
--|       Validate_commodity_code                                            |
--|       Validate_ic_matr_days                                              |
--|       Validate_ic_hold_days                                              |
--|       Validate_Strength                                                  |
--|       Validate_origination_type                                          |
--|       Validate_shipvendor_no                                             |
--|       Validate_lot_no                                                    |
--|       Validate_location                                                  |
--|       Validate_item_cnv                                                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|       16/AUG/99  Bug 965832(1)Errors on status_ctl/lot status combina -  |
--|                  tions                                                   |
--|       20/AUG/99  Bug 951828 Change GMS package Calls to GMA              |
--|                  H.Verdding                                              |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_item_existance                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validate whther item exists on ic_item_mst                         |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the parameter passed exists           |
--|       on ic_item_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_no IN Item Number                                           |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Item_id - if the item exists on ic_item_mst                        |
--|       0       - if the item does not exist on ic_item_mst                |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_item_existance
( p_item_no IN ic_item_mst.item_no%TYPE
)
RETURN NUMBER
IS
l_item_id ic_item_mst.item_id%TYPE;
CURSOR ic_item_mst_c1 IS
SELECT
  item_id
FROM
  ic_item_mst
WHERE
  item_no = p_item_no;

BEGIN

OPEN  ic_item_mst_c1;
FETCH ic_item_mst_c1 INTO l_item_id;
IF (ic_item_mst_c1%NOTFOUND)
THEN
  CLOSE ic_item_mst_c1;
  RETURN 0;
ELSE
  CLOSE ic_item_mst_c1;
  RETURN l_item_id;
END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_item_existance;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_dualum_ind                                                |
--|  USAGE                                                                   |
--|       Validates dual UoM indicator to be in the range [0,3]              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the parameter passed is in            |
--|       the range [0,3]                                                    |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_dualum_ind IN Dual Unit Of Measure Indicator                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If the parameter is in the required range                  |
--|       FALSE - If the parameter is not in the required range              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments


FUNCTION Validate_dualum_ind
( p_dualum_ind  IN ic_item_mst.dualum_ind%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                     , 3
                                     , p_dualum_ind
                                    );
END Validate_dualum_ind;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_item_um2                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates secondary Unit Of Measure                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the secondary Unit Of Measure         |
--|       is valid                                                           |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_dualum_ind IN Dual UoM Indicator                                 |
--|       p_item_um2   IN Secondary UoM                                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If the secondary UoM is valid                              |
--|       FALSE - If the secondary UoM is not valid                          |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_item_um2
(  p_dualum_ind IN ic_item_mst.dualum_ind%TYPE
 , p_item_um2   IN ic_item_mst.item_um2%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_item_um2 = ' ' OR p_item_um2 IS NULL)
  THEN
    IF (p_dualum_ind = 0)
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSE
    RETURN GMA_VALID_GRP.Validate_um(p_item_um2);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_item_um2;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_deviation                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates deviation factor (_lo or _hi)                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates the deviation factor. If dualum_ind = 0    |
--|       then must be 0 else must be a positive value                       |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_dualum_ind    IN Dual UoM Indicator                              |
--|       p_deviation_ind IN Deviation Factor Indicator                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If the deviation factor is valid                           |
--|       FALSE - If the deviation factor is not valid                       |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_deviation
(  p_dualum_ind IN ic_item_mst.dualum_ind%TYPE
 , p_deviation  IN ic_item_mst.deviation_hi%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_dualum_ind = 0 AND p_deviation <> 0)
  THEN
    RETURN FALSE;
  ELSIF (p_deviation < 0)
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END Validate_deviation;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_ctl                                                   |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot_ctl flag to be either 0 or 1                         |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the parameter passed is               |
--|       either 0 or 1                                                      |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_lot_ctl IN Lot Control Indicator                                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If the control indicator is either 0 or 1                  |
--|       FALSE - If the control indicator is not equal to 0 or 1            |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_lot_ctl
( p_lot_ctl IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                     , 1
                                     , p_lot_ctl
                                    );

END Validate_lot_ctl;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_indivisible                                           |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot indivisible flag                                     |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates the lot indivisible flag.                  |
--|       If lot_ctl = 0 then must be 0 else be either 0 or 1                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_lot_ctl         IN NUMBER - Lot Control Indicator                |
--|       p_lot_indivisible IN NUMBER - Lot Indivisible Indicator            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If lot indivisible contains a valid value                  |
--|       FALSE - If lot indivisible contains an invalid value               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_lot_indivisible
(  p_lot_ctl         IN ic_item_mst.lot_ctl%TYPE
 , p_lot_indivisible IN ic_item_mst.lot_indivisible%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_lot_ctl = 0 AND p_lot_indivisible <> 0)
  THEN
    RETURN FALSE;
  ELSE
    RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                       , 1
                                       , p_lot_indivisible
                                      );
  END IF;

END Validate_lot_indivisible;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_sublot_ctl                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates sublot_ctl flag                                          |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates the sublot_ctl flag.                       |
--|       If lot_ctl = 0 then must be either 0 or 1                          |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_lot_ctl    IN NUMBER - Lot Control Indicator                     |
--|       p_sublot_ctl IN NUMBER - Sub-Lot Control Indicator                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Sub-lot contains a valid value                          |
--|       FALSE - If Sub-lot contains an invalid value                       |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_sublot_ctl
(  p_lot_ctl    IN ic_item_mst.lot_ctl%TYPE
 , p_sublot_ctl IN ic_item_mst.sublot_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_lot_ctl = 0 AND p_sublot_ctl <> 0)
  THEN
    RETURN FALSE;
  ELSE
    RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                       , 1
                                       , p_sublot_ctl
                                      );
  END IF;

END Validate_sublot_ctl;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_loct_ctl                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates loct_ctl flag                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates the loct_ctl flag must be 0, 1 or 2        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_loct_ctl IN NUMBER - Location Control Indicator                  |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Location Control contains a valid value                 |
--|       FALSE - If Location Control conatins an invalid value              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_loct_ctl
(p_loct_ctl IN ic_item_mst.loct_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                     , 2
                                     , p_loct_ctl
                                    );

END Validate_loct_ctl;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_noninv_ind                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates non inventory indicator                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the noninv_ind flag must be           |
--|       0 or 1 and 0 if lot_ctl = 0                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_noninv_ind IN NUMBER - Non Inventory Indicator                   |
--|       p_lot_ctl    IN NUMBER - Lot Control Indicator                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Non Inventory Indicator contains a valid value          |
--|       FALSE - If Non Inventory Indicator contains an invalid value       |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_noninv_ind
(  p_noninv_ind IN ic_item_mst.noninv_ind%TYPE
 , p_lot_ctl    IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_lot_ctl = 1 and p_noninv_ind <> 0)
  THEN
    RETURN FALSE;
  ELSE
    RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                       , 1
                                       , p_noninv_ind
                                      );
  END IF;

END Validate_noninv_ind;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_match_type                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates match_type flag                                          |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the match_type flag is 1,2 or 3       |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_match_type IN NUMBER - Match Type Indicator                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Match Type indicator contains a valid value             |
--|       FALSE - If Match Type indicator contains an invalid value          |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_match_type
( p_match_type IN ic_item_mst.match_type%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  RETURN GMA_VALID_GRP.NumRangeCheck(  1
                                     , 3
                                     , p_match_type
                                    );

END Validate_match_type;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_incative_ind                                              |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates inactive_ind flag                                        |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the inactive_ind flag is 0 or 1       |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_inactive_ind IN NUMBER - Inactive Indicator                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Inactive Indicator contains a valid value               |
--|       FALSE - If Inactive Indicator contains an invalid value            |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_inactive_ind
( p_inactive_ind IN ic_item_mst.inactive_ind%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                     , 1
                                     , p_inactive_ind
                                    );

END Validate_inactive_ind;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_inv_type                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates inv_type which must exist on ic_invn_typ if non blank    |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the inventory type exists on          |
--|       ic_invn_typ                                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_inv_type IN NUMBER - Inventory Type                              |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Inventory Type is valid                                 |
--|       FALSE - If Inventory Type is invalid                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_inv_type
( p_inv_type IN ic_item_mst.inv_type%TYPE
)
RETURN BOOLEAN
IS
l_inv_type ic_item_mst.inv_type%TYPE;
CURSOR ic_invn_typ_c1 IS
SELECT
  inv_type
FROM
  ic_invn_typ
WHERE
    ic_invn_typ.inv_type    = p_inv_type
AND ic_invn_typ.delete_mark = 0;

BEGIN

  OPEN ic_invn_typ_c1;
  FETCH ic_invn_typ_c1 INTO l_inv_type;
  IF (ic_invn_typ_c1%NOTFOUND)
  THEN
    CLOSE ic_invn_typ_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_invn_typ_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_inv_type;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_shelf_life                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates shelf_life flag                                          |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the shelf life flag is not negative   |
--|       and equal to 0 if grade_ctl = 0                                    |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_shelf_life IN NUMBER - Shelf Life                                |
--|       p_grade_ctl  IN NUMBER - Grade Control Indicator                   |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Shelf Life contains a valid value                       |
--|       FALSE - If Shelf Life contains an invalid value                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_shelf_life
(  p_shelf_life IN ic_item_mst.shelf_life%TYPE
 , p_grade_ctl  IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_grade_ctl = 0 and p_shelf_life <> 0)
  THEN
    RETURN FALSE;
  ELSIF (p_shelf_life < 0 OR p_shelf_life > 9999)
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END Validate_shelf_life;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_retest_interval                                           |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates retest_interval flag                                     |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the retest interval flag is not       |
--|       negative and equal to 0 if grade_ctl = 0                           |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_retest_interval IN NUMBER - Retest Interval Indicator            |
--|       p_grade_ctl       IN NUMBER - Grade Control Indicator              |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Retest Interval contains a valid value                  |
--|       FALSE - If Retest Interval contains an invalid value               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_retest_interval
(  p_retest_interval IN ic_item_mst.retest_interval%TYPE
 , p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_grade_ctl = 0 and p_retest_interval <> 0)
  THEN
    RETURN FALSE;
  ELSIF (p_retest_interval < 0 OR p_retest_interval > 9999)
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END Validate_retest_interval;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_item_abc_code                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates item_abccode                                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the item ABC code exists              |
--|       on ic_rank_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_abccode IN VARCHAR2(4) - Item ABC Code                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item ABC Code contains a valid value                    |
--|       FALSE - If Item ABC Code contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_item_abccode
( p_item_abccode IN ic_item_mst.item_abccode%TYPE
)
RETURN BOOLEAN
IS
l_item_abccode ic_item_mst.item_abccode%TYPE;
CURSOR ic_rank_mst_c1 IS
SELECT
  abc_code
FROM
  ic_rank_mst
WHERE
    ic_rank_mst.abc_code    = p_item_abccode
AND ic_rank_mst.delete_mark = 0;

BEGIN

  IF (p_item_abccode = ' ' OR p_item_abccode IS NULL)
  THEN
    RETURN TRUE;
  ELSE
    OPEN ic_rank_mst_c1;
    FETCH ic_rank_mst_c1 INTO l_item_abccode;
    IF (ic_rank_mst_c1%NOTFOUND)
    THEN
      CLOSE ic_rank_mst_c1;
      RETURN FALSE;
    ELSE
      CLOSE ic_rank_mst_c1;
      RETURN TRUE;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_item_abccode;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_gl_class                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates gl_class                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the GL Class code exists              |
--|       on ic_gled_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_gl_class IN VARCHAR2(8) - GL Class                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If GL Class Code contains a valid value                    |
--|       FALSE - If GL Class Code contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_gl_class
( p_gl_class IN ic_item_mst.gl_class%TYPE
)
RETURN BOOLEAN
IS
l_gl_class ic_item_mst.gl_class%TYPE;
CURSOR ic_gled_cls_c1 IS
SELECT
  icgl_class
FROM
  ic_gled_cls
WHERE
    ic_gled_cls.icgl_class  = p_gl_class
AND ic_gled_cls.delete_mark = 0;

BEGIN

  OPEN ic_gled_cls_c1;
  FETCH ic_gled_cls_c1 INTO l_gl_class;
  IF (ic_gled_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_gled_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_gled_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_gl_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_inv_class                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates inv_class                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Inventory Class exists            |
--|       on ic_invn_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_inv_class IN VARCHAR2(8) - Inventory Class                       |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Inventory Class contains a valid value                  |
--|       FALSE - If Inventory Class contains an invalid value               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_inv_class
( p_inv_class IN ic_item_mst.inv_class%TYPE
)
RETURN BOOLEAN
IS
l_inv_class ic_item_mst.inv_class%TYPE;
CURSOR ic_invn_cls_c1 IS
SELECT
  icinv_class
FROM
  ic_invn_cls
WHERE
    ic_invn_cls.icinv_class = p_inv_class
AND ic_invn_cls.delete_mark = 0;

BEGIN

  OPEN ic_invn_cls_c1;
  FETCH ic_invn_cls_c1 INTO l_inv_class;
  IF (ic_invn_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_invn_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_invn_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_inv_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_sales_class                                               |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates sales_class                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Sales Class exists                |
--|       on ic_sale_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_sales_class IN VARCHAR2(8) - Sales Class                         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Sales Class contains a valid value                      |
--|       FALSE - If Sales Class contains an invalid value                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_sales_class
( p_sales_class IN ic_item_mst.sales_class%TYPE
)
RETURN BOOLEAN
IS
l_sales_class ic_item_mst.sales_class%TYPE;
CURSOR ic_sale_cls_c1 IS
SELECT
  icsales_class
FROM
  ic_sale_cls
WHERE
    ic_sale_cls.icsales_class = p_sales_class
AND ic_sale_cls.delete_mark   = 0;

BEGIN

  OPEN ic_sale_cls_c1;
  FETCH ic_sale_cls_c1 INTO l_sales_class;
  IF (ic_sale_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_sale_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_sale_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_sales_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_ship_class                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates ship_class                                               |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Ship Class exists                 |
--|       on ic_ship_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_ship_class IN VARCHAR2(8) - Ship Class                           |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Ship Class contains a valid value                       |
--|       FALSE - If Ship Class contains an invalid value                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_ship_class
( p_ship_class IN ic_item_mst.ship_class%TYPE
)
RETURN BOOLEAN
IS
l_ship_class ic_item_mst.ship_class%TYPE;
CURSOR ic_ship_cls_c1 IS
SELECT
  icship_class
FROM
  ic_ship_cls
WHERE
    ic_ship_cls.icship_class = p_ship_class
AND ic_ship_cls.delete_mark  = 0;

BEGIN

  OPEN ic_ship_cls_c1;
  FETCH ic_ship_cls_c1 INTO l_ship_class;
  IF (ic_ship_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_ship_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_ship_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_ship_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_frt_class                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates frt_class                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Freight Class exists              |
--|       on ic_frgt_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_frgt_class IN VARCHAR2(8) - Freight Class                        |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Freight Class contains a valid value                    |
--|       FALSE - If Freight Class contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_frt_class
( p_frt_class IN ic_item_mst.frt_class%TYPE
)
RETURN BOOLEAN
IS
l_frt_class ic_item_mst.frt_class%TYPE;
CURSOR ic_frgt_cls_c1 IS
SELECT
  icfrt_class
FROM
  ic_frgt_cls
WHERE
    ic_frgt_cls.icfrt_class = p_frt_class
AND ic_frgt_cls.delete_mark = 0;

BEGIN

  OPEN ic_frgt_cls_c1;
  FETCH ic_frgt_cls_c1 INTO l_frt_class;
  IF (ic_frgt_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_frgt_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_frgt_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_frt_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_price_class                                               |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates price_class                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Price Class exists                |
--|       on ic_prce_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_price_class IN VARCHAR2(8) - Price Class                         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Price Class contains a valid value                      |
--|       FALSE - If Price Class contains an invalid value                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_price_class
( p_price_class IN ic_item_mst.price_class%TYPE
)
RETURN BOOLEAN
IS
l_price_class ic_item_mst.price_class%TYPE;
CURSOR ic_prce_cls_c1 IS
SELECT
  icprice_class
FROM
  ic_prce_cls
WHERE
    ic_prce_cls.icprice_class = p_price_class
AND ic_prce_cls.delete_mark   = 0;

BEGIN

  OPEN ic_prce_cls_c1;
  FETCH ic_prce_cls_c1 INTO l_price_class;
  IF (ic_prce_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_prce_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_prce_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_price_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_storage_class                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates storage_class                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Storage Class exists              |
--|       on ic_stor_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_storage_class IN VARCHAR2(8) - Storage Class                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Storage Class contains a valid value                    |
--|       FALSE - If Storage Class contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_storage_class
( p_storage_class IN ic_item_mst.storage_class%TYPE
)
RETURN BOOLEAN
IS
l_storage_class ic_item_mst.storage_class%TYPE;
CURSOR ic_stor_cls_c1 IS
SELECT
  icstorage_class
FROM
  ic_stor_cls
WHERE
    ic_stor_cls.icstorage_class = p_storage_class
AND ic_stor_cls.delete_mark     = 0;

BEGIN

  OPEN ic_stor_cls_c1;
  FETCH ic_stor_cls_c1 INTO l_storage_class;
  IF (ic_stor_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_stor_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_stor_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_storage_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_purch_class                                               |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates purch_class                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Purchase Class exists             |
--|       on ic_prch_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_purch_class IN VARCHAR2(8) - Purchase Class                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Purchase Class contains a valid value                   |
--|       FALSE - If Purchase Class contains an invalid value                |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_purch_class
( p_purch_class IN ic_item_mst.purch_class%TYPE
)
RETURN BOOLEAN
IS
l_purch_class ic_item_mst.purch_class%TYPE;
CURSOR ic_prch_cls_c1 IS
SELECT
  icpurch_class
FROM
  ic_prch_cls
WHERE
    ic_prch_cls.icpurch_class = p_purch_class
AND ic_prch_cls.delete_mark   = 0;

BEGIN

  OPEN ic_prch_cls_c1;
  FETCH ic_prch_cls_c1 INTO l_purch_class;
  IF (ic_prch_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_prch_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_prch_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_purch_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_tax_class                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates tax_class                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Tax Class exists                  |
--|       on ic_taxn_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_tax_class IN VARCHAR2(8) - Tax Class                             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Tax Class contains a valid value                        |
--|       FALSE - If Tax Class contains an invalid value                     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_tax_class
( p_tax_class IN ic_item_mst.tax_class%TYPE
)
RETURN BOOLEAN
IS
l_tax_class ic_item_mst.tax_class%TYPE;
CURSOR ic_taxn_cls_c1 IS
SELECT
  ictax_class
FROM
  ic_taxn_cls
WHERE
    ic_taxn_cls.ictax_class = p_tax_class
AND ic_taxn_cls.delete_mark = 0;

BEGIN

  OPEN ic_taxn_cls_c1;
  FETCH ic_taxn_cls_c1 INTO l_tax_class;
  IF (ic_taxn_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_taxn_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_taxn_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_tax_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_custom_class                                              |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates custom_class                                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Custom Class exists               |
--|       on ic_ctms_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_customs_class IN VARCHAR2(8) - Customs Class                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Customs Class contains a valid value                    |
--|       FALSE - If Customs Class contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_customs_class
( p_customs_class IN ic_item_mst.customs_class%TYPE
)
RETURN BOOLEAN
IS
l_customs_class ic_item_mst.customs_class%TYPE;
CURSOR ic_ctms_cls_c1 IS
SELECT
  iccustoms_class
FROM
  ic_ctms_cls
WHERE
    ic_ctms_cls.iccustoms_class = p_customs_class
AND ic_ctms_cls.delete_mark     = 0;

BEGIN

  OPEN ic_ctms_cls_c1;
  FETCH ic_ctms_cls_c1 INTO l_customs_class;
  IF (ic_ctms_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_ctms_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_ctms_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_customs_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_alloc_class                                               |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates alloc_class                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Allocation Class exists           |
--|       on ic_allc_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_alloc_class IN VARCHAR2(8) - Allocation Clas                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Allocation Class contains a valid value                 |
--|       FALSE - If Allocation Class contains an invalid value              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_alloc_class
( p_alloc_class IN ic_item_mst.alloc_class%TYPE
)
RETURN BOOLEAN
IS
l_alloc_class ic_item_mst.alloc_class%TYPE;
CURSOR ic_allc_cls_c1 IS
SELECT
  alloc_class
FROM
  ic_allc_cls
WHERE
    ic_allc_cls.alloc_class = p_alloc_class
AND ic_allc_cls.delete_mark = 0;

BEGIN

  OPEN ic_allc_cls_c1;
  FETCH ic_allc_cls_c1 INTO l_alloc_class;
  IF (ic_allc_cls_c1%NOTFOUND)
  THEN
    CLOSE ic_allc_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_allc_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_alloc_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_planning_class                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates planning_class                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Planning Class exists             |
--|       on ic_plng_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_planning_class IN VARCHAR2(8) - Planning Class                   |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Planning Class contains a valid value                   |
--|       FALSE - If Planning Class contains an invalid value                |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_planning_class
( p_planning_class IN ic_item_mst.planning_class%TYPE
)
RETURN BOOLEAN
IS
l_planning_class ic_item_mst.planning_class%TYPE;
CURSOR ps_plng_cls_c1 IS
SELECT
  planning_class
FROM
  ps_plng_cls
WHERE
    ps_plng_cls.planning_class = p_planning_class
AND ps_plng_cls.delete_mark    = 0;

BEGIN

  OPEN ps_plng_cls_c1;
  FETCH ps_plng_cls_c1 INTO l_planning_class;
  IF (ps_plng_cls_c1%NOTFOUND)
  THEN
    CLOSE ps_plng_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ps_plng_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_planning_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_itemcost_class                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates itemcost_class                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item Cost Class exists            |
--|       on ic_cost_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_itemcost_class class IN VARCHAR2(8) - Item Cost Class            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item Cost Class contains a valid value                  |
--|       FALSE - If Item Cost Class contains an invalid value               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_itemcost_class
( p_itemcost_class IN ic_item_mst.itemcost_class%TYPE
)
RETURN BOOLEAN
IS
l_itemcost_class ic_item_mst.itemcost_class%TYPE;
CURSOR ic_cost_cls_c1 IS
SELECT
  itemcost_class
FROM
  ic_cost_cls
WHERE
    ic_cost_cls.itemcost_class = p_itemcost_class
AND ic_cost_cls.delete_mark    = 0;

BEGIN

  OPEN ic_cost_cls_c1;
  FETCH ic_cost_cls_c1 INTO l_itemcost_class;
  IF (ic_cost_cls_c1%NOTFOUND) THEN
    CLOSE ic_cost_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_cost_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_itemcost_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_cost_mthd_code                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates cost_mthd_code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the cost Method Code exists           |
--|       on cm_mthd_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_cost_mthd_code IN VARCHAR2(4) - Cost Method Code                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Cost Method contains a valid value                      |
--|       FALSE - If Cost Method contains an invalid value                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_cost_mthd_code
( p_cost_mthd_code IN ic_item_mst.cost_mthd_code%TYPE
)
RETURN BOOLEAN
IS
l_cost_mthd_code ic_item_mst.cost_mthd_code%TYPE;
CURSOR cm_mthd_mst_c1 IS
SELECT
  cost_mthd_code
FROM
  cm_mthd_mst
WHERE
    cm_mthd_mst.cost_mthd_code = p_cost_mthd_code
AND cm_mthd_mst.delete_mark    = 0;

BEGIN

  OPEN cm_mthd_mst_c1;
  FETCH cm_mthd_mst_c1 INTO l_cost_mthd_code;
  IF (cm_mthd_mst_c1%NOTFOUND)
  THEN
    CLOSE cm_mthd_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE cm_mthd_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_cost_mthd_code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_grade_ctl                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates grade_ctl                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Grade Control must be either 0 or 1   |
--|       and equal to 0 if lot_ctl = 0                                      |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_grade_ctl IN NUMBER - Grade Control Indicator                    |
--|       p_lot_ctl   IN NUMBER - Lot Control Indicator                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Grade Control contains a valid value                    |
--|       FALSE - If Grade Control contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_grade_ctl
(  p_grade_ctl IN ic_item_mst.grade_ctl%TYPE
 , p_lot_ctl   IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_lot_ctl = 0 and p_grade_ctl <> 0)
  THEN
    RETURN FALSE;
  ELSE
    RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                       , 1
                                       , p_grade_ctl
                                      );
  END IF;

END Validate_grade_ctl;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_status_ctl                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates status_ctl                                               |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Status Control must be either 0 or 1  |
--|       and equal to 0 if lot_ctl = 0                                      |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_status_ctl IN NUMBER - Status Control Indicator                  |
--|       p_lot_ctl    IN NUMBER - Lot Control Indicator                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Status Control contains a valid value                   |
--|       FALSE - If Status Control contains an invalid value                |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_status_ctl
(  p_status_ctl IN ic_item_mst.status_ctl%TYPE
 , p_lot_ctl    IN ic_item_mst.lot_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN
--B965832(1) Allow for status_ctl = NULL
  IF (p_lot_ctl = 0 and ((p_status_ctl <> 0) and (p_status_ctl IS NOT NULL)))
  THEN
    RETURN FALSE;
  ELSE
    RETURN GMA_VALID_GRP.NumRangeCheck(  0
	                               , 2
                                       , p_status_ctl
                                      );
  END IF;

END Validate_status_ctl;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_qc_grade                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates qc_grade                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that QC Grqde exists on qc_grad_mst        |
--|       and is not blank if grade_ctl = 1                                  |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_qc_grade  IN VARCHAR2(4) - QC Grade Code                         |
--|       p_grade_ctl IN NUMBER      - Grade Control Indicator               |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If QC Grade contains a valid value                         |
--|       FALSE - If QC Grade contains an invalid value                      |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_qc_grade
(   p_qc_grade  IN ic_item_mst.qc_grade%TYPE
  , p_grade_ctl IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN
IS
l_qc_grade ic_item_mst.qc_grade%TYPE;
CURSOR qc_grad_mst_c1 IS
SELECT
  qc_grade
FROM
  qc_grad_mst
WHERE
    qc_grad_mst.qc_grade    = p_qc_grade
AND qc_grad_mst.delete_mark = 0;

BEGIN

  IF (p_grade_ctl = 0)
  THEN
--B965832(1) If grade_ctl=0, then set qc_grade to null
     l_qc_grade := '';
     RETURN TRUE;
--B965832(1) End
  ELSIF (p_qc_grade = ' ' OR p_qc_grade IS NULL)
  THEN
    RETURN FALSE;
  END IF;

  OPEN qc_grad_mst_c1;
  FETCH qc_grad_mst_c1 INTO l_qc_grade;
  IF (qc_grad_mst_c1%NOTFOUND)
  THEN
    CLOSE qc_grad_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE qc_grad_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_qc_grade;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_status                                                |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot_status                                               |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Lot Status exists on ic_lots_sts      |
--|       and is not blank if status_ctl = 1                                 |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_lot_status IN VARCHAR2(4) - Lot Status Code                      |
--|       p_status_ctl IN NUMBER      - Lot Status Indicator                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Lot Status contains a valid value                       |
--|       FALSE - If Lot Status contains an invalid value                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_lot_status
(  p_lot_status IN ic_item_mst.lot_status%TYPE
 , p_status_ctl IN ic_item_mst.status_ctl%TYPE
)
RETURN BOOLEAN
IS
l_lot_status ic_item_mst.lot_status%TYPE;
CURSOR ic_lots_sts_c1 IS
SELECT
  lot_status
FROM
  ic_lots_sts
WHERE
    ic_lots_sts.lot_status  = p_lot_status
AND ic_lots_sts.delete_mark = 0;

BEGIN

  IF (p_status_ctl = 0)
  THEN
--B965832 Make sure that lot_status is set to null if status_ctl=0
      l_lot_status := '';
      RETURN TRUE;
  ELSIF (p_lot_status = ' ' OR p_lot_status IS NULL)
  THEN
    RETURN FALSE;
  END IF;

  OPEN ic_lots_sts_c1;
  FETCH ic_lots_sts_c1 INTO l_lot_status;
  IF (ic_lots_sts_c1%NOTFOUND)
  THEN
    CLOSE ic_lots_sts_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_lots_sts_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_lot_status;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_qchold_res_code                                           |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates qchold_res_code                                          |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that QC Hold Reason Code exists on         |
--|       qc_hres_mst                                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_qchold_res_code IN VARCHAR2(4) - QC Hold reason Code             |
--|       p_grade_ctl       IN NUMBER      - Lot Status Indicator            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If QC Hold Reason Code contains a valid value              |
--|       FALSE - If QC Hold reason Code contains an invalid value           |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_qchold_res_code
(  p_qchold_res_code IN ic_item_mst.qchold_res_code%TYPE
 , p_grade_ctl       IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN
IS
l_qchold_res_code ic_item_mst.qchold_res_code%TYPE;
CURSOR qc_hres_mst_c1 IS
SELECT
  qchold_res_code
FROM
  qc_hres_mst
WHERE
    qc_hres_mst.qchold_res_code = p_qchold_res_code
AND qc_hres_mst.delete_mark     = 0;

BEGIN

  IF (p_qchold_res_code = ' ' OR p_qchold_res_code IS NULL)
  THEN
    RETURN TRUE;
  ELSIF (p_grade_ctl = 0)
  THEN
    RETURN FALSE;
  END IF;

  OPEN qc_hres_mst_c1;

  FETCH qc_hres_mst_c1 INTO l_qchold_res_code;

  IF (qc_hres_mst_c1%NOTFOUND)
  THEN
    CLOSE qc_hres_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE qc_hres_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_qchold_res_code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_expaction_code                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates expaction_code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Expiration Code exists on             |
--|       qc_actn_mst                                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_expaction_code IN VARCHAR2(4) - Expiration Code                  |
--|       p_grade_ctl      IN NUMBER      - Lot Status Indicator             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Expiration Code contains a valid value                  |
--|       FALSE - If Expiration Code contains an invalid value               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_expaction_code
(  p_expaction_code IN ic_item_mst.expaction_code%TYPE
 , p_grade_ctl      IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN
IS
l_expaction_code ic_item_mst.expaction_code%TYPE;
CURSOR qc_actn_mst_c1 IS
SELECT
  action_code
FROM
  qc_actn_mst
WHERE
    qc_actn_mst.action_code = p_expaction_code
AND qc_actn_mst.delete_mark = 0;

BEGIN

  IF (p_expaction_code = ' ' OR p_expaction_code IS NULL)
  THEN
    RETURN TRUE;
  ELSIF (p_grade_ctl = 0)
  THEN
    RETURN FALSE;
  END IF;

  OPEN qc_actn_mst_c1;

  FETCH qc_actn_mst_c1 INTO l_expaction_code;

  IF (qc_actn_mst_c1%NOTFOUND)
  THEN
    CLOSE qc_actn_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE qc_actn_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_expaction_code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_expaction_interval                                        |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates expaction_interval                                       |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Expiration Interval is not negative   |
--|       and not greater than 9999                                          |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_expaction_interval IN NUMBER - Expiration Code                   |
--|       p_grade_ctl          IN NUMBER      - Lot Status Indicator         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Expiration Interval is positive or zero                 |
--|       FALSE - If Expiration Interval is negative or > 9999               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_expaction_interval
(  p_expaction_interval IN ic_item_mst.expaction_interval%TYPE
 , p_grade_ctl          IN ic_item_mst.grade_ctl%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_expaction_interval = 0)
  THEN
    RETURN TRUE;
  ELSIF (p_grade_ctl = 0)
  THEN
    RETURN FALSE;
  END IF;

  IF (p_expaction_interval < 0 OR p_expaction_interval > 9999)
  THEN
    RETURN FALSE;
  END IF;

END Validate_expaction_interval;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_experimental_ind                                          |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates experimental_ind                                         |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Experimental Indicator is either      |
--|       0 or 1                                                             |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_experimental_ind IN NUMBER - Expiration Code                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Experimental Indicator contains a valid value           |
--|       FALSE - If Experimental Indicator contains an invalid value        |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_experimental_ind
( p_experimental_ind IN ic_item_mst.experimental_ind%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  RETURN GMA_VALID_GRP.NumRangeCheck(  0
                                     , 1
                                     , p_experimental_ind
                                    );

END Validate_experimental_ind;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_seq_dpnd_class                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates seq_dpnd_class                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Sequence Dependent Class exists       |
--|       on cr_sqdt_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_seq_dpnd_class IN VARCHAR2(8) - Sequence Dependent Class         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Sequence Dependent Class contains a valid value         |
--|       FALSE - If Sequence Dependent Class contains an invalid value      |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_seq_dpnd_class
( p_seq_dpnd_class IN ic_item_mst.seq_dpnd_class%TYPE
)
RETURN BOOLEAN
IS
l_seq_dpnd_class ic_item_mst.seq_dpnd_class%TYPE;
CURSOR cr_sqdt_cls_c1 IS
SELECT
  seq_dpnd_class
FROM
  cr_sqdt_cls
WHERE
    cr_sqdt_cls.seq_dpnd_class = p_seq_dpnd_class
AND cr_sqdt_cls.delete_mark    = 0;

BEGIN

  OPEN cr_sqdt_cls_c1;
  FETCH cr_sqdt_cls_c1 INTO l_seq_dpnd_class;
  IF (cr_sqdt_cls_c1%NOTFOUND)
  THEN
    CLOSE cr_sqdt_cls_c1;
    RETURN FALSE;
  ELSE
    CLOSE cr_sqdt_cls_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_seq_dpnd_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_commodity_code                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates commodity_code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Commodity Code exists on              |
--|       ic_comd_cds and it is non blank if SY$INTRASTAT = 1                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_commodity_code IN VARCHAR2(9)  - Commodity Code                  |
--|       p_sy$intrast     IN VARCHAR2(40) - Intrastat Indicator             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Commodity Code contains a valid value                   |
--|       FALSE - If commodity Code contains an invalid value                |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_commodity_code
(  p_commodity_code IN ic_item_mst.commodity_code%TYPE
 , p_sy$intrastat   IN VARCHAR2
)
RETURN BOOLEAN
IS
l_commodity_code ic_item_mst.commodity_code%TYPE;
CURSOR ic_comd_cds_c1 IS
SELECT
  commodity_code
FROM
  ic_comd_cds
WHERE
    ic_comd_cds.commodity_code = p_commodity_code
AND ic_comd_cds.delete_mark    = 0;

BEGIN

  IF (p_commodity_code = ' ' OR p_commodity_code IS NULL) AND
     (p_sy$intrastat <> 1)
  THEN
    RETURN TRUE;
  ELSIF (p_commodity_code = ' ' OR p_commodity_code IS NULL) AND
         (p_sy$intrastat = 1)
  THEN
    RETURN FALSE;
  END IF;

  OPEN ic_comd_cds_c1;
  FETCH ic_comd_cds_c1 INTO l_commodity_code;
  IF (ic_comd_cds_c1%NOTFOUND)
  THEN
    CLOSE ic_comd_cds_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_comd_cds_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_commodity_code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_ic_matr_days                                              |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates ic_matr_days                                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Mature days is not a negative value   |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_ic_matr_days IN NUMBER - Mature days                             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Mature Days is greater or equal to zero                 |
--|       FALSE - If Mature days is negative                                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_ic_matr_days
( p_ic_matr_days IN ic_item_cpg.ic_matr_days%TYPE
)
RETURN BOOLEAN
IS
l_ic_matr_days  ic_item_cpg.ic_matr_days%TYPE;
BEGIN

  l_ic_matr_days  := p_ic_matr_days;
  RETURN GMA_VALID_GRP.NumRangeCheck( 0, 99999, l_ic_matr_days);

END Validate_ic_matr_days;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_ic_hold_days                                              |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates ic_holr_days                                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Hold days is not a negative value     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_ic_hold_days IN NUMBER - Hold days                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Hold Days is greater or equal to zero                   |
--|       FALSE - If Hold days is negative                                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_ic_hold_days
( p_ic_hold_days IN ic_item_cpg.ic_hold_days%TYPE
)
RETURN BOOLEAN
IS
l_ic_hold_days  ic_item_cpg.ic_hold_days%TYPE;
BEGIN

  l_ic_hold_days  := p_ic_hold_days;
  RETURN GMA_VALID_GRP.NumRangeCheck( 0, 99999, l_ic_hold_days);

END Validate_ic_hold_days;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Strength                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates strength                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Strength is not a negative value      |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_strength IN NUMBER - Strength                                    |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Strength is greater or equal to zero                    |
--|       FALSE - If Strength is negative                                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_Strength
( p_strength IN ic_lots_mst.strength%TYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_strength < 0)
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END Validate_strength;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_origination_type                                          |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates origination_type                                         |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Origination Type exists on            |
--|       gem_lookups                                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_origination_type IN NUMBER - Origination Type                    |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Origination Type contains a valid value                 |
--|       FALSE - If Origination Type contains an invalid value              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_origination_type
( p_origination_type IN ic_lots_mst.origination_type%TYPE
)
RETURN BOOLEAN
IS
l_origination_type ic_lots_mst.origination_type%TYPE;
CURSOR gem_lookups_c1 IS
SELECT
  lookup_type
FROM
  gem_lookups
WHERE
  lookup_type   = 'ORIGINATION_TYPE'
AND lookup_code = p_origination_type;

BEGIN

  OPEN gem_lookups_c1;
  FETCH gem_lookups_c1 INTO l_origination_type;
  IF (gem_lookups_c1%NOTFOUND)
  THEN
    CLOSE gem_lookups_c1;
    RETURN FALSE;
  ELSE
    CLOSE gem_lookups_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_origination_type;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_shipvendor_no                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates shipvendor_no                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that Vendor exists on po_vend_mst          |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_shipvendor_no IN VARCHAR2(32) - Ship Vendor Code                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Ship Vendor Code contains a valid value                 |
--|       FALSE - If Ship Vendor Code contains an invalid value              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_shipvendor_no
( p_shipvendor_no IN po_vend_mst.vendor_no%TYPE
)
RETURN NUMBER
IS
l_shipvendor_no po_vend_mst.vendor_no%TYPE;
l_shipvendor_id ic_lots_mst.shipvend_id%TYPE;

CURSOR po_vend_mst_c1 IS
SELECT
  vendor_no
, vendor_id
FROM
  po_vend_mst
WHERE
    vendor_no   = p_shipvendor_no
AND delete_mark = 0;

BEGIN

  IF (p_shipvendor_no = ' ' OR p_shipvendor_no IS NULL)
  THEN
    RETURN 0;
  ELSE
    OPEN po_vend_mst_c1;
    FETCH po_vend_mst_c1 INTO l_shipvendor_no, l_shipvendor_id;
    IF (po_vend_mst_c1%NOTFOUND)
    THEN
      CLOSE po_vend_mst_c1;
      RETURN 0;
    ELSE
      CLOSE po_vend_mst_c1;
      RETURN l_shipvendor_id;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_shipvendor_no;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_no                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Lot and Sub-Lot numbers against item number              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item/Lot/Sublot combination       |
--|       exists                                                             |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_no    IN VARCHAR2(32) - Item Number                         |
--|       p_lot_no     IN VARCHAR2(32) - Lot Number                          |
--|       p_sublot_no  IN VARCHAR2(32) - Sub-Lot Number                      |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item/lot/sublot is a valid combination                  |
--|       FALSE - If Item/lot/sublot is not a valid combination              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_lot_No
(  p_item_no   IN ic_item_mst.item_no%TYPE
 , p_lot_no    IN ic_lots_mst.lot_no%TYPE
 , p_sublot_no IN ic_lots_mst.sublot_no%TYPE
)
RETURN BOOLEAN
IS
l_item_id   ic_item_mst.item_id%TYPE;
l_item_no   ic_item_mst.item_no%TYPE;
l_lot_no    ic_lots_mst.lot_no%TYPE;
l_sublot_no ic_lots_mst.sublot_no%TYPE;

CURSOR ic_lots_mst_c1 IS
SELECT
  a.item_no
, a.item_id
, b.lot_no
, b.sublot_no
FROM
  ic_item_mst a
, ic_lots_mst b
WHERE
    p_item_no     = a.item_no
AND a.item_id     = b.item_id
AND p_lot_no      = b.lot_no
AND p_sublot_no   = b.sublot_no
AND b.delete_mark = 0;

BEGIN

  OPEN ic_lots_mst_c1;
  FETCH ic_lots_mst_c1 INTO l_item_no, l_item_id, l_lot_no, l_sublot_no;
  IF (ic_lots_mst_c1%NOTFOUND)
  THEN
    CLOSE ic_lots_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_lots_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_lot_no;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_location                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Location                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates whether or not a location is required for  |
--|       an item/warehouse. If required then validates the location if      |
--|       required                                                           |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_loct_ctl IN NUMBER       - Item Location Control Indicator  |
--|       p_whse_loct_ctl IN NUMBER       - Warehouse Location Control Ind   |
--|       p_whse_code     IN VARCHAR2(4)  - Warehouse Code                   |
--|       p_location      IN VARCHAR2(16) - Location Code                    |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Location Code contains a valid value                    |
--|       FALSE - If Location Code contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_Location
(  p_item_loct_ctl IN ic_item_mst.loct_ctl%TYPE
 , p_whse_loct_ctl IN ic_whse_mst.loct_ctl%TYPE
 , p_whse_code     IN ic_whse_mst.whse_code%TYPE
 , p_location      IN ic_loct_mst.location%TYPE
)
RETURN BOOLEAN
IS
l_loct_ctl         NUMBER;
l_location         ic_loct_mst.location%TYPE;
CURSOR ic_loct_mst_c1 IS
SELECT
  location
FROM
  ic_loct_mst
WHERE
    whse_code   = p_whse_code
AND location    = p_location
AND delete_mark = 0;

BEGIN

-- determine location control for item / whse combination
  l_loct_ctl := p_item_loct_ctl * p_whse_loct_ctl;

-- location not required
  IF (l_loct_ctl = 0)
  THEN
    IF (p_location <> ' ' AND p_location IS NOT NULL)
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END IF;

-- location required but not validated
  IF (l_loct_ctl > 1)
  THEN
    IF (p_location = ' ' OR p_location IS NULL)
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END IF;

-- validated location required
  OPEN ic_loct_mst_c1;
  FETCH ic_loct_mst_c1 INTO l_location;
  IF (ic_loct_mst_c1%NOTFOUND)
  THEN
    CLOSE ic_loct_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_loct_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Location;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_item_cnv                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Item / Lot conversion exists                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the combination of parameters passed  |
--|       exists on ic_item_cnv                                              |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_no   IN VARCHAR2(32) - Item Number                          |
--|       p_lot_no    IN VARCHAR2(32) - Lot Number                           |
--|       p_sublot_no IN VARCHAR2(32) - Sub-Lot Number                       |
--|       p_um_type   IN VARCHAR2(4)  - UoM Type                             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item/Lot/Sublot conversion exists                       |
--|       FALSE - If Item/Lot/Sublot conversion does not exist               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
FUNCTION Validate_item_cnv
(  p_item_no   IN ic_item_mst.item_no%TYPE
 , p_lot_no    IN ic_lots_mst.lot_no%TYPE
 , p_sublot_no IN ic_lots_mst.sublot_no%TYPE
 , p_um_type   IN ic_item_cnv.um_type%TYPE
)
RETURN BOOLEAN
IS
l_item_no ic_item_mst.item_no%TYPE;

CURSOR ic_item_cnv_c1 IS
SELECT
  a.item_no
FROM
  ic_item_mst a
, ic_lots_mst b
, ic_item_cnv c
WHERE
    p_item_no     = a.item_no
AND a.item_id     = b.item_id
AND p_lot_no      = b.lot_no
AND p_sublot_no   = b.sublot_no
AND b.delete_mark = 0
AND c.item_id     = a.item_id
AND c.lot_id      = b.lot_id
AND c.um_type     = p_um_type;

BEGIN

  OPEN ic_item_cnv_c1;
  FETCH ic_item_cnv_c1 INTO l_item_no;
  IF (ic_item_cnv_c1%NOTFOUND)
  THEN
    CLOSE ic_item_cnv_c1;
    RETURN FALSE;
  ELSE
    CLOSE ic_item_cnv_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_item_cnv;

END GMI_VALID_GRP;

/
