--------------------------------------------------------
--  DDL for Package Body GMISYUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMISYUM" AS
/* $Header: GMISYUMB.pls 115.3 99/07/16 04:49:14 porting ship  $  */
FUNCTION sy_uom_find(V_uom VARCHAR2, V_um_type IN OUT VARCHAR2, V_std_factor IN OUT NUMBER) RETURN NUMBER IS
/****sy sy_uom_find*************************************************

*  Procedure
*  	sy_uom_find
*
*  Description
* 	This function is responsible for retrieving the um_type and
* 	standard factor from GEMMS given specific unit of measure
* 	code.
*
*  Parameters
* 	V_uom		UOM Code.
* 	V_um_type	Value of UOM TYPE.
* 	V_std_factor 	Value of standard factor.
*
*  Return Values
*  	 1	Success
*  	-1	Failure
*  *****************************************************************/
  CURSOR Cur_uom_fact IS
    SELECT um_type,std_factor
    FROM   sy_uoms_mst
    WHERE  um_code = V_uom
           AND delete_mark = 0;
BEGIN
  OPEN Cur_uom_fact;
  FETCH Cur_uom_fact INTO V_um_type, V_std_factor;
  IF Cur_uom_fact%NOTFOUND THEN
    CLOSE Cur_uom_fact;
    RETURN(-1);
  END IF;
  CLOSE Cur_uom_fact;
  RETURN(1);
END sy_uom_find;
FUNCTION sy_cnv_find(V_item_id NUMBER, V_lot_id NUMBER, V_um_type VARCHAR2, V_cnv_factor IN OUT NUMBER) RETURN NUMBER IS
/****sy sy_cnv_find**************************************

* Procedure
* 	sy_cnv_find
*
* Description
* 	This function is responsible for returning the
*	conversion factor given a valid item_id, lot_id, and um_type.
*
* Parameters
*	V_item_id		- passed in valid item_id
*	V_lot_id		- passed in valid lot_id
*	V_um_type		- passed in valid um_type [ie MASS, VOL]
*	V_cnv_factor		- return variable with factor.
*
* Return Values
* 	 1	Success
* 	-1	Failure
*************************************************************************/
  CURSOR Cur_type_factor IS
    SELECT type_factor
    FROM   ic_item_cnv
    WHERE  item_id = V_item_id
           AND lot_id = V_lot_id
	   AND um_type = V_um_type;
BEGIN
  OPEN Cur_type_factor;
  FETCH Cur_type_factor INTO V_cnv_factor;
  IF Cur_type_factor%NOTFOUND THEN
    CLOSE Cur_type_factor;
    RETURN(-1);
  END IF;
  CLOSE Cur_type_factor;
  RETURN(1);
END sy_cnv_find;
FUNCTION sy_lab_find (V_item_id NUMBER, V_lot_id NUMBER, V_lab_type VARCHAR2, V_cnv_factor IN OUT NUMBER) RETURN NUMBER IS
/****sy sy_lab_find**************************************

* Procedure
* 	sy_lab_find
*
* Description
*
* NOTES:
*	For LAB the lot_id holds the formula_id.  This is critical for
*	the proper selection of the conversion factor.
*
*	Lab type is a passed parameter from the call lm_uomcv. It
*	populates the global variable 'lab_type' which is needed
*	for the select criteria in determining the conversion factor.
*
*	This is because the lab module allows for different
*	conversion factors based on density the standard item conversion
*	table is not used here.
*
* Parameters
* 	none
*
* Return Values
* 	 1	Success
* 	-1	Failure
*************************************************************************/
  X_density VARCHAR2(40);
  CURSOR Cur_num_data IS
    SELECT num_data
    FROM   lm_item_dat
    WHERE  lab_type = V_lab_type
           AND item_id = V_item_id
	   AND formula_id = V_lot_id
           AND tech_parm_name = X_density;
BEGIN
  IF NOT (FND_PROFILE.DEFINED('LM$DENSITY')) THEN
    RETURN(-1);
  END IF;
  X_density := FND_PROFILE.VALUE('LM$DENSITY');
  OPEN Cur_num_data;
  FETCH Cur_num_data INTO V_cnv_factor;
  IF Cur_num_data%NOTFOUND THEN
    CLOSE Cur_num_data;
    RETURN(-1);
  END IF;
  CLOSE Cur_num_data;
  RETURN(1);
END sy_lab_find;
FUNCTION sy_uomcv(V_item_id NUMBER, V_lot_id NUMBER, V_cur_qty NUMBER,
				    V_cur_uom VARCHAR2, V_inv_uom VARCHAR2, V_new_qty IN OUT NUMBER,
				    V_new_uom VARCHAR2, V_perform_lab NUMBER DEFAULT 0,
				    V_density_conv_factor NUMBER DEFAULT 0, V_def_lab VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
/****sy sy_uomcv *****************************************************
*  NAME* 	sy_uomcv -- perform unit of measure conversion from C
*  SYNOPSIS
*  	int sy_uomcv (int, int, double, char *, char *, double *,
*  					  char *, int)
*  	NUMBER		V_item_id	valid item id in GEMMS DB.
*   	NUMBER		V_lot_id	ZERO or valid lot_id in GEMMS DB.
*  	NUMBER		V_cur_qty	current quantity to convert
*  	VARCHAR2 	V_cur_uom	current UOM.
*  	VARCHAR2	V_inv_uom	the items base inventory UOM.
*  							(NOT REQUIRED)
*  	NUMBER 		V_new_qty	pointer to variable to hold new
*  					converted quantity.
*  	VARCHAR2	V_new_uom	pointer to UOM to convert to.
*
*
*  USAGE
*  	sy_uomcv (1, 0, 10.5, 'LB', NULL, new_qty, 'GAL', ) ;
*
*  DESCRIPTION
*  	Fetches inventory unit of measure from database if not given.
*  	Caches unit of measure types and item-specific conversion factors.
*
*  RETURNS
*  	1 = ok
*  	<= 0 = error
*  	ERR_UOM_UNKNOWN 		= unknown error
*  	ERR_UOM_ITEM_CNV 		= error fetching from ic_item_cnv
*  	ERR_UOMS_MST 			= error fetching from sy_uoms_mst
*  	ERR_UOM_CODE_FACTOR 		= item-specific factors found == 0
*  	ERR_UOM_NOCUR 			= no "from" item-specific factor found
*  	ERR_UOM_NONEW 			= no "to" item-specific factor found
*  	ERR_UOM_NOINV 			= no "INV" item-specific factor found
*  	ERR_UOM_STD_FACTOR		= standard factor found == 0
*  	ERR_UOMS_NOT_FOUND 		= type/factor not found
*  	ERR_UOM_ITEM_MST 		= Error fetching from ic_item_mst
* **************************************************************************/
  ERR_UOM_UNKNOWN 	CONSTANT NUMBER := -3350;
  ERR_UOM_ITEM_CNV 	CONSTANT NUMBER := -3351;
  ERR_UOMS_MST 		CONSTANT NUMBER := -3352;
  ERR_UOM_CODE_FACTOR 	CONSTANT NUMBER := -3355;
  ERR_UOM_NOCUR 	CONSTANT NUMBER := -3356;
  ERR_UOM_NONEW 	CONSTANT NUMBER := -3357;
  ERR_UOM_NOINV 	CONSTANT NUMBER := -3358;
  ERR_UOM_STD_FACTOR	CONSTANT NUMBER := -3359;
  ERR_UOMS_NOT_FOUND 	CONSTANT NUMBER := -3361;
  ERR_UOM_ITEM_MST 	CONSTANT NUMBER := -3362;
  ERR_LAB_CNV		CONSTANT NUMBER := -3367;
  CURSOR Cur_inv_uom IS
    SELECT item_um
    FROM   ic_item_mst
    WHERE  item_id = V_item_id;
  X_retvar	NUMBER;
  X_cur_um_type sy_uoms_typ.um_type%TYPE;
  X_new_um_type sy_uoms_typ.um_type%TYPE;
  X_inv_um_type sy_uoms_typ.um_type%TYPE;
  X_cur_cnv_factor NUMBER DEFAULT 1;
  X_new_cnv_factor NUMBER DEFAULT 1;
  X_cur_std_factor NUMBER DEFAULT 0;
  X_new_std_factor NUMBER DEFAULT 0;
  X_inv_std_factor NUMBER DEFAULT 0;
  X_factor	       NUMBER DEFAULT 0;
  X_inv_uom	VARCHAR2(4);
BEGIN
/* ========================================
*   Validate passed parameters and act
*   accordingly.
*   ======================================== */
  IF V_cur_qty = 0 THEN
    V_new_qty := 0;
  END IF;
  IF (V_cur_uom IS NULL) THEN
    RETURN(ERR_UOM_NOCUR);
  END IF;
  IF (V_new_uom IS NULL) THEN
    RETURN(ERR_UOM_NONEW);
  END IF;
/* ==================================
UOMs are the same, this routine
should not have been called so
update the new quantity and return
to caller.
================================== */
  IF (V_cur_uom =  V_new_uom) THEN
    V_new_qty := V_cur_qty;
    Return(1);
  END IF;
  /* ========================================
   Determine um_type and standard factor
   for current uom.
   ======================================== */
  X_retvar := sy_uom_find (V_cur_uom, X_cur_um_type, X_cur_std_factor);
  IF X_retvar <> 1 THEN
    RETURN(ERR_UOM_NOCUR);
  END IF;
  /* ========================================
   Determine um_type and standard factor
   for new uom.
   ========================================  */
  X_retvar := sy_uom_find (V_new_uom, X_new_um_type, X_new_std_factor);
  IF X_retvar <> 1 THEN
    RETURN(ERR_UOM_NONEW);
  END IF;
  /* ========================================
   If the um_types for both current and new
   uom(s) ARE THE SAME, perform calculation
   and return.
   ============================================ */
  IF (X_cur_um_type = X_new_um_type) THEN
    X_factor := (X_cur_std_factor / X_new_std_factor);
    V_new_qty := ROUND(V_cur_qty * X_factor, 9);
    RETURN(1);
  ELSE
    /* ============================================
     If the um_types for both current and new
     uom(s) ARE NOT THE SAME, get the inventory uom
     for the item if it is null.
     ============================================ */
    IF V_inv_uom IS NULL THEN
      OPEN Cur_inv_uom;
      FETCH Cur_inv_uom INTO X_inv_uom;
      IF Cur_inv_uom%NOTFOUND THEN
        CLOSE Cur_inv_uom;
        RETURN(ERR_UOM_ITEM_MST);
      END IF;
      CLOSE Cur_inv_uom;
    ELSE
      X_inv_uom := V_inv_uom;
    END IF;
    /* =========================================
     Get the um_type and standard factor for
     the inventory uom.
     ========================================= */
    X_retvar := sy_uom_find (X_inv_uom, X_inv_um_type, X_inv_std_factor);
    IF X_retvar <> 1 THEN
      RETURN(ERR_UOM_NOINV);
    END IF;
    /* =========================================
     If the um_types for both the inventory
     uom and the current uom ARE NOT THE SAME, get
     the CONVERSION FACTOR for the current
     um_type.
     ========================================= */
    IF (X_cur_um_type <> X_inv_um_type) THEN
      IF (V_perform_lab = 1) THEN
        IF (V_density_conv_factor = 0) THEN
          X_retvar := sy_lab_find(V_item_id, V_lot_id, V_def_lab, X_cur_cnv_factor);
          IF X_retvar <> 1 THEN
            RETURN(ERR_LAB_CNV);
          END IF;
        ELSE
          X_cur_cnv_factor := V_density_conv_factor;
        END IF;
      ELSE
        X_retvar := sy_cnv_find(V_item_id, V_lot_id, X_cur_um_type, X_cur_cnv_factor);
        IF X_retvar <> 1 THEN
        /* ======================================
         BUSINESS RULE - if a specific lot_id
	 * conversion factor is not found, return
	 * the item specific conversion factor.
	 * ====================================== */
          X_retvar := sy_cnv_find(V_item_id, 0, X_cur_um_type, X_cur_cnv_factor);
          IF X_retvar <> 1 THEN
            RETURN(ERR_UOM_ITEM_CNV);
          END IF;
        END IF;
      END IF;
    END IF;
   /* =========================================
     If the um_types for both the inventory
     uom and the new uom ARE NOT THE SAME, get
     the CONVERSION FACTOR for the new
     um_type.
     ========================================= */
    IF (X_new_um_type <> X_inv_um_type) THEN
      IF (V_perform_lab = 1) THEN
        IF (V_density_conv_factor = 0) THEN
          X_retvar := sy_lab_find(V_item_id, V_lot_id, V_def_lab, X_new_cnv_factor);
          IF X_retvar <> 1 THEN
            RETURN(ERR_LAB_CNV);
          END IF;
        ELSE
          X_new_cnv_factor := V_density_conv_factor;
        END IF;
      ELSE
        X_retvar := sy_cnv_find(V_item_id, V_lot_id, X_new_um_type, X_new_cnv_factor);
        IF X_retvar <> 1 THEN
        /* ======================================
	 * BUSINESS RULE - if a specific lot_id
	 * conversion factor is not found, return
	 * the item specific conversion factor.
	 * ====================================== */
          X_retvar := sy_cnv_find(V_item_id, 0, X_new_um_type, X_new_cnv_factor);
          IF X_retvar <> 1 THEN
            RETURN(ERR_UOM_ITEM_CNV);
          END IF;
        END IF;
      END IF;
    END IF;
    /* ==================================================
     OK... Time to perform conversion
     ================================================== */
    X_factor := ((X_cur_std_factor * X_cur_cnv_factor) /
		(X_new_std_factor * X_new_cnv_factor));
    V_new_qty := (V_cur_qty * X_factor);
    RETURN(1);
  END IF;
END sy_uomcv;
END gmisyum;

/
