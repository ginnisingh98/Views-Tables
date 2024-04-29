--------------------------------------------------------
--  DDL for Package Body GMICUOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMICUOM" AS
/* $Header: gmicuomb.pls 115.17 2003/04/07 22:15:57 adeshmuk ship $ */
  /* =============================================
  PROCEDURE:
  icuomcv

  DESCRIPTION:
  This PL/SQL procedure is responsible for
  calling the unit of measure function contained
  in this package and handling all error messaging
  centrally.

  SYNOPSIS:
  GMICUOM.icuomcv(pitem_id, plot_id, pcur_qty,
  pcur_uom, pnew_uom);

  ============================================= */
  PROCEDURE icuomcv(pitem_id     NUMBER,
                    plot_id      NUMBER,
                    pcur_qty     NUMBER,
                    pcur_uom     VARCHAR2,
                    pnew_uom     VARCHAR2,
                    onew_qty OUT NOCOPY NUMBER) IS

    /* Local variable initialization and
    declarations.
    ================================= */
    l_iret     NUMBER       := -1;
    l_atomic   NUMBER       :=  0;
    l_neg_flag NUMBER       :=  0;
    l_cur_qty  NUMBER       :=  0;

    BEGIN

      IF(pcur_qty < 0) THEN
        l_cur_qty := (pcur_qty * -1);
        l_neg_flag := 1;
      ELSE
        l_cur_qty := pcur_qty;
      END IF;

      l_iret := GMICUOM.uom_conversion(pitem_id,
                  plot_id, l_cur_qty, pcur_uom, pnew_uom,
                  l_atomic);

      IF(l_iret >= 0) THEN
        IF(l_neg_flag = 1) THEN
          onew_qty := (l_iret * -1);
        ELSE
          onew_qty := l_iret;
        END IF;
      ELSIF (l_iret = -1) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -3) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -4) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -5) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
        FND_MESSAGE.set_token('FROMUOM',pcur_uom);
        FND_MESSAGE.set_token('TOUOM',pnew_uom);
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -6) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -7) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -10) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
        FND_MESSAGE.set_token('FROMUOM',pcur_uom);
        FND_MESSAGE.set_token('TOUOM',pnew_uom);
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -11) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret < -11) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
        APP_EXCEPTION.raise_exception;

      END IF;

    END icuomcv;
  /* =============================================
  PROCEDURE:
  icuomcvl              LAB MGT ONLY!

  DESCRIPTION:
  This PL/SQL procedure is responsible for
  calling the unit of measure function contained
  in this package and handling all error messaging
  centrally.

  SYNOPSIS:
  GMICUOM.icuomcvl(pitem_id, plot_id, pcur_qty,
  pcur_uom, pnew_uom, pnew_qty,
  plab_type, pcnv_factor);

================================================
WJ Harris III 19-NOV-98 R11.0 resynch
Modified function uom_conversion for LAB.
Modified procedure icuomcvl for LAB.
Added parameter pcnv_factor to both to comply
with Sierra Atlantic changes for Laboratory Mgt.
  ============================================= */
  PROCEDURE icuomcvl(pitem_id     NUMBER,
                     pformula_id  NUMBER,
                     pcur_qty     NUMBER,
                     pcur_uom     VARCHAR2,
                     pnew_uom     VARCHAR2,
                     plab_type    VARCHAR2,
                     pcnv_factor  NUMBER,
                     onew_qty OUT NOCOPY NUMBER) IS

    /* Local variable initialization and
    declarations.
    ================================= */
    l_iret     NUMBER       := -1;
    l_atomic   NUMBER       :=  0;
    l_neg_flag NUMBER       :=  0;
    l_cur_qty  NUMBER       :=  0;

    BEGIN

      IF(pcur_qty < 0) THEN
        l_cur_qty := (pcur_qty * -1);
        l_neg_flag := 1;
      ELSE
        l_cur_qty := pcur_qty;
      END IF;

      l_iret := GMICUOM.uom_conversion(pitem_id,
                  pformula_id, l_cur_qty, pcur_uom, pnew_uom,
                  l_atomic, plab_type, pcnv_factor);

      IF(l_iret >= 0) THEN
        IF(l_neg_flag = 1) THEN
          onew_qty := (l_iret * -1);
        ELSE
          onew_qty := l_iret;
        END IF;
      ELSIF (l_iret = -1) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -2) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_LABTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -3) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -4) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -5) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -6) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -7) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -8) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_LMDENSITY_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -9) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_LABFACTOR_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -10) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
        FND_MESSAGE.set_token('FROMUOM',pcur_uom);
        FND_MESSAGE.set_token('TOUOM',pnew_uom);
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -11) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret < -11) THEN
        FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
        APP_EXCEPTION.raise_exception;

      END IF;

    END icuomcvl;
  /* =============================================
      FUNCTION:
        uom_conversion      OVERLOADED FUNCTION!

      DESCRIPTION:
        This PL/SQL function is responsible for
        calculating and returning the converted
        quantity of an item in the unit of measure
        specified.

        The uom_conversion function ASSUMES POSITIVE NUMBERS ONLY!
        ALL CALLERS MUST DEAL WITH NEGATIVE NUMBERS PRIOR TO
        CALLING THIS FUNCTION!

      PARAMETERS:
        pitem_id     The surrogate key of the item number

        plot_id      The surrogate key for the lot number/
                     sublot of the item number being converted.
                     ALLOWS ZERO if performing a LAB conversion.

        pcur_qty     The current quantity to convert.

        pcur_uom     The current unit of measure to convert from.

        pnew_uom     The unit of measure to convert to.

        patomic      Flag to determine if decimal percision is
                     required as part of the conversion.
                       0 = No, provide full precision.
                       1 = Yes, provide integer ONLY!

      SPECIAL NOTES:

      RETURNS:
      >=0 - SUCCESS
       -1 - Package problem.
       -3 - UM_TYPE and conversion factor for current UOM not found.
       -4 - UM_TYPE and conversion factor for NEW UOM not found.
       -5 - Cannot determine INVENTORY UOM for item.
       -6 - UM_TYPE and conversion factor for INV UOM not found.
       -7 - Cannot find conversion factor for CURRENT UOM.
      -10 - Cannot find conversion factor for NEW UOM.
      -11 - Item_id not passed as a parameter.

      HISTORY
      Jalaj Srivastava Bug 1713699  05-APR-2001
      Apps provides item specific intra class conversion.
      we need to use them if it exists for a item.

      G. Muratore      Bug 2236392  15-APR-2002
      Rounding problem corrected by changing the order of operations
      in uom_conversion.  The code no longer derives the factor and
      then applies.  It does the full calculation in one step.

		A. Mundhe		  Bug 2844068  07-APR-2003
	   Modified the uom_conversion function to use more - precise type
	   factor or type factorrev and to calculate the new qty accordingly.
      ============================================================== */
  FUNCTION uom_conversion(pitem_id    NUMBER,
                          plot_id     NUMBER,
                          pcur_qty    NUMBER ,
                          pcur_uom    VARCHAR2,
                          pnew_uom    VARCHAR2,
                          patomic     NUMBER)
                          RETURN NUMBER IS
    /* Variable Declarations
    ===================== */
    l_item_invum_code   uomcode_type;
    l_cur_uom_code      uomcode_type;
    l_new_uom_code      uomcode_type;
    l_cur_um_type       sy_uoms_typ.um_type%TYPE;
    l_new_um_type       sy_uoms_typ.um_type%TYPE;
    l_inv_um_type       sy_uoms_typ.um_type%TYPE;
    l_cur_uom_factor    ic_item_cnv.type_factor%TYPE;
    l_cur_conv_factor   ic_item_cnv.type_factor%TYPE;
    l_cur_conv_factorrev   ic_item_cnv.type_factor%TYPE;  /*  Bug 2844068 */
    l_new_uom_factor    ic_item_cnv.type_factor%TYPE;
    l_new_conv_factor   ic_item_cnv.type_factor%TYPE;
    l_new_conv_factorrev   ic_item_cnv.type_factor%TYPE;  /*  Bug 2844068 */
    l_inv_uom_factor    ic_item_cnv.type_factor%TYPE;
    l_lab_conv_factor   lm_item_dat.num_data%TYPE;
    l_parm_name         lm_item_dat.tech_parm_name%TYPE;
    l_factor            NUMBER;
    l_new_qty           NUMBER;
    l_item_no           ic_item_mst.item_no%type;
    l_inventory_item_id mtl_system_items.inventory_item_id%type;
    var1                NUMBER;

    /*  Bug 2844068 */
	 l_factor_len 			NUMBER;
	 l_factorrev_len		NUMBER;

    /* Cursor Definitions
    ==================*/
    CURSOR get_uom_type(Vum_code uomcode_type,
                        Vinventory_item_id  mtl_system_items.inventory_item_id%type) IS
      SELECT 1, uomc.uom_class um_type, uomc.conversion_rate std_factor
      FROM   mtl_uom_conversions uomc, mtl_units_of_measure uom, sy_uoms_mst sy
      WHERE  sy.um_code             = Vum_code
      AND    uom.unit_of_measure    = sy.unit_of_measure
      AND    uomc.uom_code          = uom.uom_code
      AND    uomc.inventory_item_id = Vinventory_item_id
      AND    (   (uomc.disable_date IS NULL)
              OR (uomc.disable_date > sysdate) )
      UNION
      SELECT 2, um_type, std_factor
      FROM   sy_uoms_mst
      WHERE  um_code = Vum_code
      AND    delete_mark = 0
      ORDER by 1;


    CURSOR get_inv_uom(v_item_id itm_surg_type) IS
      SELECT item_um
      FROM   ic_item_mst
      WHERE  item_id = v_item_id;

    /*  Bug 2844068 */
    /*  Added type_factorrev to the query */
    CURSOR get_conversion_factor(v_item_id itm_surg_type,
                               v_lot_id    lot_surg_type,
                               v_um_type sy_uoms_typ.um_type%TYPE) IS
      SELECT type_factor, type_factorrev
      FROM   ic_item_cnv
      WHERE  item_id = v_item_id
      AND    lot_id  = v_lot_id
      AND    delete_mark = 0
      AND    um_type = v_um_type;

    CURSOR get_item_no (Vitem_id ic_item_mst.item_id%type) IS
       SELECT item_no
       FROM   ic_item_mst
       WHERE  item_id = Vitem_id;

    CURSOR get_inventory_item_id(Vitem_no ic_item_mst.item_no%type) IS
       SELECT inventory_item_id
       FROM   mtl_system_items
       WHERE  segment1= Vitem_no
       AND    rownum  = 1;
    /* ================================================*/
    BEGIN

      l_cur_uom_code    := pcur_uom;
      l_new_uom_code    := pnew_uom;
      l_item_invum_code := NULL;
      l_cur_um_type     := NULL;
      l_new_um_type     := NULL;
      l_inv_um_type     := NULL;
      l_cur_uom_factor  := 0;
      l_cur_conv_factor := 0;
      l_cur_conv_factorrev := 0;  /* Bug 2844068 */
      l_new_uom_factor  := 0;
      l_new_conv_factor := 0;
      l_new_conv_factorrev := 0;  /* Bug 2844068 */
      l_inv_uom_factor  := 0;
      l_factor          := 0;
      l_new_qty         := 0;

      /* ===================================
      ENFORCE PARAMETER LAWS!
      ===================================*/
      IF(pitem_id IS NULL) THEN
        RETURN UOM_NOITEM_ERR;
      END IF;

      /* ===================================
      OK ... if the passed units of
      measure are the same, then there is
      nothing to do!
      ===================================*/
      IF(pcur_uom = pnew_uom) THEN
        l_new_qty := pcur_qty;
        RETURN l_new_qty;
      END IF;
      /*====================================
         Jalaj Srivastava Bug 1713699
         We need opm item no and inventory item
           id in order to get specific
           item conversions.
        ===================================*/
       OPEN get_item_no(pitem_id);
       FETCH get_item_no INTO l_item_no;
       CLOSE get_item_no;

       OPEN get_inventory_item_id(l_item_no);
       FETCH get_inventory_item_id INTO l_inventory_item_id;
       CLOSE get_inventory_item_id;

      /* ===================================
      Step One - determine the um_type
      and standard factor for the current
      unit of measure.
      ===================================*/
      OPEN get_uom_type(l_cur_uom_code, l_inventory_item_id);
      FETCH get_uom_type INTO
        var1, l_cur_um_type, l_cur_uom_factor;

      IF(get_uom_type%NOTFOUND) THEN

        CLOSE get_uom_type;
        RETURN UOM_CUR_UOMTYPE_ERR;
      END IF;


      CLOSE get_uom_type;

      /* ==================================
      Step TWO - determine the um_type
      and standard factor for the new
      unit of measure.
      ==================================*/
      OPEN get_uom_type(l_new_uom_code, l_inventory_item_id);
      FETCH get_uom_type INTO
        var1, l_new_um_type, l_new_uom_factor;

      IF(get_uom_type%NOTFOUND) THEN

        CLOSE get_uom_type;
        RETURN UOM_NEW_UOMTYPE_ERR;
      END IF;


      CLOSE get_uom_type;

      /* =========================================
      Step Three - If the unit of measure types
      are the SAME, perform calculation cause
      we are done!
      ========================================= */
      /*
      IF(l_cur_um_type = l_new_um_type) THEN
        l_factor  := (l_cur_uom_factor / l_new_uom_factor);
        IF(patomic = 1) THEN
          l_new_qty := ROUND(pcur_qty * l_factor);
        ELSE
          l_new_qty := (pcur_qty * l_factor);
        END IF;

        RETURN l_new_qty;
      END IF;
      */

      /* Bug 2236392  Rounding problem corrected by
      changing the order of operations in uom_conversion.
      Old code commented out above.                       */
      IF(l_cur_um_type = l_new_um_type) THEN
        l_new_qty  := (pcur_qty * l_cur_uom_factor / l_new_uom_factor);

        IF(patomic = 1) THEN
          l_new_qty := ROUND(l_new_qty);
        END IF;

        RETURN l_new_qty;
      END IF;


      /* =========================================
      Step Four - If the unit of measure types
      are NOT THE SAME, get the item's inventory
      uom type an conversion factor.
      ========================================= */
      IF(l_cur_um_type <> l_new_um_type) THEN
        OPEN get_inv_uom(pitem_id);
        FETCH get_inv_uom INTO
          l_item_invum_code;

        IF(get_inv_uom%NOTFOUND) THEN

          CLOSE get_inv_uom;
          RETURN UOM_INVUOM_ERR;
        END IF;
        CLOSE get_inv_uom;

        OPEN get_uom_type(l_item_invum_code, l_inventory_item_id);
        FETCH get_uom_type INTO
          var1, l_inv_um_type, l_inv_uom_factor;

        IF(get_uom_type%NOTFOUND) THEN

          CLOSE get_uom_type;
          RETURN UOM_INV_UOMTYPE_ERR;
        END IF;

        CLOSE get_uom_type;

      END IF;

      /* ==============================================
      Step FIVE - If the uom types for the current
      and the inventory uoms are NOT THE SAME,
      we need the CONVERSION factors for both the
      current and new uoms so that we can convert
      to the items primary uom.
      ============================================== */

      /* Bug 2844068 */
      /* Fetch type_factorrev from the cursor */
      IF(l_cur_um_type <> l_inv_um_type) THEN
        OPEN get_conversion_factor(pitem_id, plot_id, l_cur_um_type);
        FETCH get_conversion_factor INTO
          l_cur_conv_factor, l_cur_conv_factorrev;

        IF(get_conversion_factor%NOTFOUND) THEN
          /* =======================================
          We have to check for an ITEM SPECIFIC
          conversion factor if one does not exist
          for the lot.
          ======================================= */
          CLOSE get_conversion_factor;

          /* Bug 2844068 */
          /* Fetch type_factorrev from the cursor */
          OPEN get_conversion_factor(pitem_id, default_lot,
                                     l_cur_um_type);
          FETCH get_conversion_factor INTO
            l_cur_conv_factor, l_cur_conv_factorrev;

          IF(get_conversion_factor%NOTFOUND) THEN
            CLOSE get_conversion_factor;
            RETURN UOM_CUR_CONV_ERR;
          END IF;
        END IF;
        CLOSE get_conversion_factor;
      ELSIF(l_cur_um_type = l_inv_um_type) THEN
        l_cur_conv_factor := cur_factor_default;
        /* Bug 2844068 */
        l_cur_conv_factorrev := cur_factor_default;
      END IF;

      /* ==============================================
      Step SEVEN - If the uom types are NOT THE SAME,
      we need the CONVERSION factors for both the
      current and new uoms so that we can convert
      to the items primary uom.
      ==============================================*/

      IF(l_inv_um_type <> l_new_um_type) THEN
        /* Bug 2844068 */
        /* Fetch type_factorrev from the cursor */
        OPEN get_conversion_factor(pitem_id, plot_id, l_new_um_type);
        FETCH get_conversion_factor INTO
          l_new_conv_factor, l_new_conv_factorrev;

        IF(get_conversion_factor%NOTFOUND) THEN
          /* =======================================
          We have to check for an ITEM SPECIFIC
          conversion factor if one does not exist
          for the lot.
          =======================================*/
          CLOSE get_conversion_factor;

          OPEN get_conversion_factor(pitem_id, default_lot,
                                     l_new_um_type);
          /* Bug 2844068 */
          /* Fetch type_factorrev from the cursor */
          FETCH get_conversion_factor INTO
            l_new_conv_factor, l_new_conv_factorrev;

          IF(get_conversion_factor%NOTFOUND) THEN
            CLOSE get_conversion_factor;
            RETURN  UOM_NEW_CONV_ERR;
          END IF;
        END IF;
        CLOSE get_conversion_factor;

      ELSIF(l_inv_um_type = l_new_um_type) THEN
        l_new_conv_factor := new_factor_default;
        /* Bug 2844068 */
        l_new_conv_factorrev := new_factor_default;
      END IF;

      /* ======================================
      Conversion Please .... Thank you very
      much!!!
      ======================================*/
      /*
      l_factor  := ((l_cur_uom_factor * l_cur_conv_factor) /
                    (l_new_uom_factor * l_new_conv_factor));
      IF(patomic = 1) THEN
        l_new_qty := ROUND(pcur_qty * l_factor);
      ELSE
        l_new_qty := (pcur_qty * l_factor);
      END IF;

      RETURN l_new_qty;
      */

      /* Bug 2236392  Rounding problem corrected by
      changing the order of operations in uom_conversion.
      Old code commented out above.                       */

      /* Bug 2844068 */
      /* Calculate the number of decimal places in type factor and type factorrev.
         Use the factor with less number of decimal places and calcualte the new qty
         accordingly. */

      l_factor_len := length(TO_CHAR(l_new_conv_factor - floor(l_new_conv_factor)))-1;
      l_factorrev_len := length(TO_CHAR(l_new_conv_factorrev - floor(l_new_conv_factorrev)))-1;

      IF (l_factor_len  < l_factorrev_len) THEN
      	l_new_qty := ((pcur_qty * l_cur_uom_factor * l_cur_conv_factor) /
                    (l_new_uom_factor * l_new_conv_factor));
		ELSE
			l_new_qty := ((pcur_qty * l_cur_uom_factor * l_cur_conv_factor * l_new_conv_factorrev) /
                    (l_new_uom_factor));
		END IF;

      IF(patomic = 1) THEN
        l_new_qty := ROUND(l_new_qty);
      END IF;

      RETURN l_new_qty;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END uom_conversion;
  /* =============================================
      FUNCTION:
      uom_conversion         OVERLOADED FUNCTION
                                   LAB ONLY!

      DESCRIPTION:
        This PL/SQL function is responsible for
        calculating and returning the converted
        quantity of an item in the unit of measure
        specified.

        The uom_conversion function ASSUMES POSITIVE NUMBERS ONLY!
        ALL CALLERS MUST DEAL WITH NEGATIVE NUMBERS PRIOR TO
        CALLING THIS FUNCTION!

      PARAMETERS:
        pitem_id     The surrogate key of the item number

        pformula_id  The surrogate key for the formula/version
                     being converted.  ALLOWS ZERO if performing
                     a regular conversion. FOR LAB MGT ONLY!

        pcur_qty     The current quantity to convert.

        pcur_uom     The current unit of measure to convert from.

        pnew_uom     The unit of measure to convert to.

        patomic      Flag to determine if decimal percision is
                     required as part of the conversion.
                       0 = No, provide full precision.
                       1 = Yes, provide integer ONLY!

        plab_type    The technical parameter group name.
                     IT IS REQUIRED.

        pcnv_factor  Conversion factor for density passed
                     by the user.  NOT REQUIRED!

      SPECIAL NOTES:
        Added new parameter pcnv_factor to coincide with
        Sierra Atlantic changes for lab UOM conversions.  This
        allows the user to perform conversions based on user
        entry for the value of conversion factor instead of
        getting the value from the database.

      RETURNS:
      >=0 - SUCCESS
       -1 - Package problem.
       -2 - Lab Type not passed for LAB conversion.
       -3 - UM_TYPE and conversion factor for current UOM not found.
       -4 - UM_TYPE and conversion factor for NEW UOM not found.
       -5 - Cannot determine INVENTORY UOM for item.
       -6 - UM_TYPE and conversion factor for INV UOM not found.
       -7 - Cannot find conversion factor for CURRENT UOM.
       -8 - LAB CONVERSION - LM$DENSITY variable not found.
       -9 - LAB CONVERSION - conversion factor not found.
      -10 - Cannot find conversion factor for NEW UOM.
      -11 - Item_id not passed as a parameter.

      HISTORY:
      WJ Harris III  19-NOV-98  resynch
      Added pcnv_factor parameter for laboratory management to
      coincide with Sierra Atlantic modifications approved by
      Karen Theel.  These were not communicated or approved by
      anyone else.
      Jalaj Srivastava Bug 1713699  05-APR-2001
      Apps provides item specific intra class conversion.
      we need to use them if it exists for a item.

      G. Muratore      Bug 2236392  15-APR-2002
      Rounding problem corrected by changing the order of operations
      in uom_conversion.  The code no longer derives the factor and
      then applies.  It does the full calculation in one step.

      ============================================================== */
  FUNCTION uom_conversion(pitem_id    NUMBER,
                          pformula_id NUMBER,
                          pcur_qty    NUMBER,
                          pcur_uom    VARCHAR2,
                          pnew_uom    VARCHAR2,
                          patomic     NUMBER,
                          plab_type   VARCHAR2,
                          pcnv_factor NUMBER DEFAULT 0)
                          RETURN NUMBER IS
    /* Variable Declarations
    =====================*/
    l_item_invum_code uomcode_type;
    l_cur_uom_code    uomcode_type;
    l_new_uom_code    uomcode_type;
    l_cur_um_type     sy_uoms_typ.um_type%TYPE;
    l_new_um_type     sy_uoms_typ.um_type%TYPE;
    l_inv_um_type     sy_uoms_typ.um_type%TYPE;
    l_cur_uom_factor  ic_item_cnv.type_factor%TYPE;
    l_cur_conv_factor ic_item_cnv.type_factor%TYPE;
    l_new_uom_factor  ic_item_cnv.type_factor%TYPE;
    l_new_conv_factor ic_item_cnv.type_factor%TYPE;
    l_inv_uom_factor  ic_item_cnv.type_factor%TYPE;
    l_lab_conv_factor lm_item_dat.num_data%TYPE;
    l_parm_name       lm_item_dat.tech_parm_name%TYPE;
    l_factor          NUMBER;
    l_new_qty         NUMBER;
    l_item_no           ic_item_mst.item_no%type;
    l_inventory_item_id mtl_system_items.inventory_item_id%type;
    var1                NUMBER;

    /* Cursor Definitions
    ==================*/
    CURSOR get_uom_type(Vum_code uomcode_type,
                        Vinventory_item_id  mtl_system_items.inventory_item_id%type) IS
      SELECT 1, uomc.uom_class um_type, uomc.conversion_rate std_factor
      FROM   mtl_uom_conversions uomc, mtl_units_of_measure uom, sy_uoms_mst sy
      WHERE  sy.um_code             = Vum_code
      AND    uom.unit_of_measure    = sy.unit_of_measure
      AND    uomc.uom_code          = uom.uom_code
      AND    uomc.inventory_item_id = Vinventory_item_id
      UNION
      SELECT 2, um_type, std_factor
      FROM   sy_uoms_mst
      WHERE  um_code = Vum_code
      AND    delete_mark = 0
      ORDER by 1;

    CURSOR get_inv_uom(v_item_id itm_surg_type) IS
      SELECT item_um
      FROM   ic_item_mst
      WHERE  item_id = v_item_id;

    CURSOR get_conversion_factor(v_item_id itm_surg_type,
                               v_lot_id    lot_surg_type,
                               v_um_type sy_uoms_typ.um_type%TYPE) IS
      SELECT type_factor
      FROM   ic_item_cnv
      WHERE  item_id = v_item_id
      AND    lot_id  = v_lot_id
      AND    delete_mark = 0
      AND    um_type = v_um_type;

    CURSOR get_lab_conv_factor(v_lab_type lab_type,
                       v_item_id    itm_surg_type,
                       v_formula_id form_surg_type,
                       v_parm_name  lm_item_dat.tech_parm_name%TYPE) IS
      SELECT num_data
      FROM   lm_item_dat
      WHERE  orgn_code = v_lab_type
      AND    item_id  = v_item_id
      AND    formula_id = v_formula_id
      AND    tech_parm_name = v_parm_name
      AND    delete_mark = 0;

    CURSOR get_item_no (Vitem_id ic_item_mst.item_id%type) IS
       SELECT item_no
       FROM   ic_item_mst
       WHERE  item_id = Vitem_id;

    CURSOR get_inventory_item_id(Vitem_no ic_item_mst.item_no%type) IS
       SELECT inventory_item_id
       FROM   mtl_system_items
       WHERE  segment1= Vitem_no
       AND    rownum  = 1;

    /* ================================================*/
    BEGIN

      l_cur_uom_code    := pcur_uom;
      l_new_uom_code    := pnew_uom;
      l_item_invum_code := NULL;
      l_cur_um_type     := NULL;
      l_new_um_type     := NULL;
      l_inv_um_type     := NULL;
      l_cur_uom_factor  := 0;
      l_cur_conv_factor := 0;
      l_new_uom_factor  := 0;
      l_new_conv_factor := 0;
      l_inv_uom_factor  := 0;
      l_factor          := 0;
      l_new_qty         := 0;

      /* ===================================
      ENFORCE PARAMETER LAWS!
      ===================================*/
      IF(pitem_id IS NULL OR pitem_id = 0) THEN
        RETURN UOM_NOITEM_ERR;
      END IF;

      IF(plab_type IS NULL) THEN
        RETURN UOM_LAB_TYPE_ERR;
      END IF;

      /* First we must get the SYSTEMS density parameter
      NAME.  If we do not have one bail dude .... there
      is a setup error!
      =================================================*/
      l_parm_name := FND_PROFILE.value('LM$DENSITY');

      IF(l_parm_name IS NULL) THEN
      RETURN UOM_LAB_CONST_ERR;
      END IF;
      /* ===================================
      OK ... if the passed units of
      measure are the same, then there is
      nothing to do!
      ===================================*/
      IF(pcur_uom = pnew_uom) THEN
        l_new_qty := pcur_qty;
        RETURN l_new_qty;
      END IF;

       /*====================================
         Jalaj Srivastava Bug 1713699
         We need to get the item no and
         inventory item id in order to  get
         specific item conversions.
        ===================================*/
       OPEN get_item_no(pitem_id);
       FETCH get_item_no INTO l_item_no;
       CLOSE get_item_no;

       OPEN get_inventory_item_id(l_item_no);
       FETCH get_inventory_item_id INTO l_inventory_item_id;
       CLOSE get_inventory_item_id;


      /* ===================================
      Step One - determine the um_type
      and standard factor for the current
      unit of measure.
      ===================================*/
      OPEN get_uom_type(l_cur_uom_code, l_inventory_item_id);
      FETCH get_uom_type INTO
        var1, l_cur_um_type, l_cur_uom_factor;

      IF(get_uom_type%NOTFOUND) THEN
        CLOSE get_uom_type;
        RETURN UOM_CUR_UOMTYPE_ERR;
      END IF;

      CLOSE get_uom_type;

      /* ==================================
      Step TWO - determine the um_type
      and standard factor for the new
      unit of measure.
      ==================================*/
      OPEN get_uom_type(l_new_uom_code, l_inventory_item_id);
      FETCH get_uom_type INTO
        var1, l_new_um_type, l_new_uom_factor;

      IF(get_uom_type%NOTFOUND) THEN

        CLOSE get_uom_type;
        RETURN UOM_NEW_UOMTYPE_ERR;
      END IF;

      CLOSE get_uom_type;

      /* =========================================
      Step Three - If the unit of measure types
      are the SAME, perform calculation cause
      we are done!
      =========================================*/
      /*
      IF(l_cur_um_type = l_new_um_type) THEN
        l_factor  := (l_cur_uom_factor / l_new_uom_factor);
        IF(patomic = 1) THEN
          l_new_qty := ROUND(pcur_qty * l_factor);
        ELSE
          l_new_qty := (pcur_qty * l_factor);
        END IF;


        RETURN l_new_qty;
      END IF;
      */

      /* Bug 2236392  Rounding problem corrected by
      changing the order of operations in uom_conversion.
      Old code commented out above.                       */
      IF(l_cur_um_type = l_new_um_type) THEN
        l_new_qty  := (pcur_qty * l_cur_uom_factor / l_new_uom_factor);

        IF(patomic = 1) THEN
          l_new_qty := ROUND(l_new_qty);
        END IF;

        RETURN l_new_qty;
      END IF;


      /* =========================================
      Step Four - If the unit of measure types
      are NOT THE SAME, get the item's inventory
      uom type an conversion factor.
      =========================================*/
      IF(l_cur_um_type <> l_new_um_type) THEN
        OPEN get_inv_uom(pitem_id);
        FETCH get_inv_uom INTO
          l_item_invum_code;

        IF(get_inv_uom%NOTFOUND) THEN

          CLOSE get_inv_uom;
          RETURN UOM_INVUOM_ERR;
        END IF;
        CLOSE get_inv_uom;

        OPEN get_uom_type(l_item_invum_code, l_inventory_item_id);
        FETCH get_uom_type INTO
          var1, l_inv_um_type, l_inv_uom_factor;

        IF(get_uom_type%NOTFOUND) THEN

          CLOSE get_uom_type;
          RETURN UOM_INV_UOMTYPE_ERR;
        END IF;

        CLOSE get_uom_type;

      END IF;

      /* ==============================================
      Step FIVE - If the uom types for the current
      and the inventory uoms are NOT THE SAME,
      we need the CONVERSION factors for both the
      current and new uoms so that we can convert
      to the items primary uom.
      ==============================================*/
      IF(l_cur_um_type <> l_inv_um_type) THEN
        /* ===========================================
        let's get the lab conversion factor
        shall we ?!  If the user has passed a
        conversion factor to use, then use it.
        Otherwise ..... lets get it from the database.
        ==============================================*/
        IF(pcnv_factor <> 0) THEN
          l_cur_conv_factor := pcnv_factor;
        ELSE
          OPEN get_lab_conv_factor(plab_type, pitem_id, pformula_id,
                                   l_parm_name);
          FETCH get_lab_conv_factor INTO
            l_cur_conv_factor;

          IF(get_lab_conv_factor%NOTFOUND) THEN
            CLOSE get_lab_conv_factor;
            RETURN UOM_LAB_CONV_ERR;
          END IF;
          CLOSE get_lab_conv_factor;
        END IF;
      ELSIF(l_cur_um_type = l_inv_um_type) THEN
        l_cur_conv_factor := cur_factor_default;
      END IF;

      /* ==============================================
      Step SEVEN - If the uom types are NOT THE SAME,
      we need the CONVERSION factors for both the
      current and new uoms so that we can convert
      to the items primary uom.
      ==============================================*/
      IF(l_inv_um_type <> l_new_um_type) THEN
        /* ===========================================
        Let's get the lab conversion factor
        shall we ?!  If the user has passed a
        conversion factor to use, then use it.
        Otherwise ..... lets get it from the database.
        ===========================================*/
        IF(pcnv_factor <> 0) THEN
          l_new_conv_factor := pcnv_factor;
        ELSE
          OPEN get_lab_conv_factor(plab_type, pitem_id, pformula_id,
                                   l_parm_name);
          FETCH get_lab_conv_factor INTO
            l_new_conv_factor;

          IF(get_lab_conv_factor%NOTFOUND) THEN
            CLOSE get_lab_conv_factor;
            RETURN UOM_LAB_CONV_ERR;
          END IF;
          CLOSE get_lab_conv_factor;
        END IF;
      ELSIF(l_inv_um_type = l_new_um_type) THEN
        l_new_conv_factor := new_factor_default;
      END IF;

      /* ======================================
      Conversion Please .... Thank you very
      much!!!
      ======================================*/
      /*
      l_factor  := ((l_cur_uom_factor * l_cur_conv_factor) /
                    (l_new_uom_factor * l_new_conv_factor));
      IF(patomic = 1) THEN
        l_new_qty := ROUND(pcur_qty * l_factor);
      ELSE
        l_new_qty := (pcur_qty * l_factor);
      END IF;


      RETURN l_new_qty;
      */

      /* Bug 2236392  Rounding problem corrected by
      changing the order of operations in uom_conversion.
      Old code commented out above.                       */
      l_new_qty  := ((pcur_qty * l_cur_uom_factor * l_cur_conv_factor) /
                    (l_new_uom_factor * l_new_conv_factor));

      IF(patomic = 1) THEN
        l_new_qty := ROUND(l_new_qty);
      END IF;

      RETURN l_new_qty;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END uom_conversion;
  /* =============================================
      FUNCTION:
        i2uom_cv

      DESCRIPTION:
        This PL/SQL function is responsible for
        calculating and returning the converted
        quantity of an item in the unit of measure
        specified from within a select statement for I2.

      PARAMETERS:
        pitem_id     The surrogate key of the item number

        plot_id      The surrogate key for the lot number/
                     sublot of the item number being converted.
                     ALLOWS ZERO if performing a LAB conversion.

        pcur_qty     The current quantity to convert.

        pcur_uom     The current unit of measure to convert from.

        pnew_uom     The unit of measure to convert to.

      SPECIAL NOTES:

      RETURNS:
        0 - SUCCESS
       -1 - Package problem.
       -3 - UM_TYPE and conversion factor for current UOM not found.
       -4 - UM_TYPE and conversion factor for NEW UOM not found.
       -5 - Cannot determine INVENTORY UOM for item.
       -6 - UM_TYPE and conversion factor for INV UOM not found.
       -7 - Cannot find conversion factor for CURRENT UOM.
      -10 - Cannot find conversion factor for NEW UOM.
      ============================================================== */
  FUNCTION i2uom_cv(pitem_id    NUMBER,
                    plot_id     NUMBER,
                    pcur_uom    VARCHAR2,
                    pcur_qty    NUMBER ,
                    pnew_uom    VARCHAR2)
                    RETURN NUMBER IS

    /* Variable Declarations
    =====================*/
    l_iret       NUMBER := -1;
    l_atomic     NUMBER :=  0;

    BEGIN

      l_iret := GMICUOM.uom_conversion(pitem_id, plot_id,
                  pcur_qty, pcur_uom, pnew_uom, l_atomic);

      IF(l_iret <= 0) THEN
        RETURN 0;
      ELSE
        RETURN l_iret;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
      RETURN SQLCODE;

    END i2uom_cv;


  END;

/
