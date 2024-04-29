--------------------------------------------------------
--  DDL for Package Body GMD_LABUOM_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LABUOM_CALCULATE_PKG" as
 /*$Header: GMDSUOMB.pls 120.1 2005/10/26 12:47 rajreddy noship $ */

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

        plab_id    Organization_id

        pcnv_factor  Conversion factor for density passed
                     by the user.  NOT REQUIRED!
      RETURNS:
      >=0 - SUCCESS
       -1 - Package problem.
       -2 - Lab Type not passed for LAB conversion.
       -3 - UOM_CLASS and conversion factor for current UOM not found.
       -4 - UOM_CLASS and conversion factor for NEW UOM not found.
       -5 - Cannot determine INVENTORY UOM for item.
       -6 - UOM_CLASS and conversion factor for INV UOM not found.
       -7 - Cannot find conversion factor for CURRENT UOM.
       -8 - LAB CONVERSION - LM$DENSITY variable not found.
       -9 - LAB CONVERSION - conversion factor not found.
      -10 - Cannot find conversion factor for NEW UOM.
      -11 - Item_id not passed as a parameter.
      ============================================================== */

  FUNCTION uom_conversion(pitem_id     NUMBER,
                          pformula_id  NUMBER,
                          plot_number VARCHAR2,
                          pcur_qty     NUMBER,
                          pcur_uom     VARCHAR2,
                          pnew_uom     VARCHAR2,
                          patomic      NUMBER,
                          plab_id      NUMBER,
                          pcnv_factor  NUMBER DEFAULT 0) RETURN NUMBER IS

    -- Variable Declarations
    l_item_invum_code   mtl_units_of_measure.uom_code%TYPE;
    l_cur_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_new_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_cur_um_type       mtl_uom_classes.uom_class%TYPE;
    l_new_um_type       mtl_uom_classes.uom_class%TYPE;
    l_inv_um_type       mtl_uom_classes.uom_class%TYPE;
    l_cur_uom_factor    mtl_uom_conversions.conversion_rate%TYPE;
    l_cur_conv_factor   mtl_uom_conversions.conversion_rate%TYPE;
    l_new_uom_factor    mtl_uom_conversions.conversion_rate%TYPE;
    l_new_conv_factor   mtl_uom_conversions.conversion_rate%TYPE;
    l_inv_uom_factor    mtl_uom_conversions.conversion_rate%TYPE;
    l_lab_conv_factor   lm_item_dat.num_data%TYPE;
    l_parm_name         lm_item_dat.tech_parm_name%TYPE;
    l_factor            NUMBER;
    l_new_qty           NUMBER;
    l_item_no           mtl_system_items_kfv.concatenated_segments%type;
    l_inventory_item_id mtl_system_items.inventory_item_id%type;
    var1                NUMBER;
    l_factor_len 	NUMBER;
    l_factorrev_len	NUMBER;
    /* Cursor Definitions
    ==================*/
    CURSOR get_uom_type(Vum_code mtl_units_of_measure.uom_code%TYPE,
                        Vinventory_item_id  mtl_system_items.inventory_item_id%type) IS
      SELECT 1, uomc.uom_class um_type, uomc.conversion_rate std_factor
      FROM   mtl_uom_conversions uomc, mtl_units_of_measure uom
      WHERE  uom.uom_code             = Vum_code
      AND    uomc.uom_code          = uom.uom_code
      AND    uomc.inventory_item_id = Vinventory_item_id
      UNION
      SELECT 2, b.uom_class, a.conversion_rate
      FROM   mtl_uom_conversions a, mtl_units_of_measure b
      WHERE  a.uom_code = b.uom_code
      AND    b.uom_code = Vum_code
      ORDER by 1;

    CURSOR get_inv_uom(v_item_id mtl_system_items.inventory_item_id%type) IS
      SELECT primary_uom_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = v_item_id;

    CURSOR get_lab_conv_factor(v_lab_type   NUMBER,
                               v_lot_number  mtl_lot_numbers.lot_number%type,
                               v_item_id    mtl_system_items.inventory_item_id%type,
                       	       v_formula_id lm_item_dat.formula_id%TYPE,
                               v_parm_name  lm_item_dat.tech_parm_name%TYPE) IS
      SELECT num_data
      FROM   gmd_technical_data_vl
      WHERE  organization_id = v_lab_type
      AND    inventory_item_id  = v_item_id
      AND    lot_number  = v_lot_number
      AND    formula_id = v_formula_id
      AND    tech_parm_name = v_parm_name;

    CURSOR get_item_no (Vitem_id mtl_system_items.inventory_item_id%type) IS
       SELECT concatenated_segments
       FROM   mtl_system_items_kfv
       WHERE  inventory_item_id = Vitem_id;
    CURSOR Cur_get_um_type (V_uom_code VARCHAR2) IS
      SELECT uom_class
      FROM   mtl_units_of_measure
      WHERE  uom_code = V_uom_code;

    l_curr_uom_type	VARCHAR2(30);
    l_new_uom_type	VARCHAR2(30);
    X_return_status	VARCHAR2(1);
    l_mass_uom_type	VARCHAR2(30);
    l_vol_uom_type	VARCHAR2(30);
  BEGIN
    gmd_api_grp.fetch_parm_values(P_orgn_id       => plab_id,
                                  P_parm_name     => 'GMD_MASS_UM_TYPE',
                                  P_parm_value    => l_mass_uom_type,
                                  X_return_status => X_return_status);
    IF (X_return_status <> 'S') THEN
      NULL;
    END IF;

    gmd_api_grp.fetch_parm_values(P_orgn_id       => plab_id,
                                  P_parm_name     => 'GMD_VOLUME_UM_TYPE',
                                  P_parm_value    => l_vol_uom_type,
                                  X_return_status => X_return_status);
    IF (X_return_status <> 'S') THEN
      NULL;
    END IF;

    OPEN Cur_get_um_type (pcur_uom);
    FETCH Cur_get_um_type INTO l_curr_uom_type;
    CLOSE Cur_get_um_type;

    OPEN Cur_get_um_type (pnew_uom);
    FETCH Cur_get_um_type INTO l_new_uom_type;
    CLOSE Cur_get_um_type;

    IF (NVL(pcnv_factor,0) > 0 AND (l_curr_uom_type IN (l_mass_uom_type, l_vol_uom_type)
                               AND l_new_uom_type IN (l_mass_uom_type, l_vol_uom_type))) THEN
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

      IF(plab_id IS NULL) THEN
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

      OPEN get_item_no(pitem_id);
      FETCH get_item_no INTO l_item_no;
      CLOSE get_item_no;

      /* ===================================
      Step One - determine the uom_class
      and standard factor for the current
      unit of measure.
      ===================================*/
      OPEN get_uom_type(l_cur_uom_code, pitem_id);
      FETCH get_uom_type INTO var1, l_cur_um_type, l_cur_uom_factor;
      IF(get_uom_type%NOTFOUND) THEN
        CLOSE get_uom_type;
        RETURN UOM_CUR_UOMTYPE_ERR;
      END IF;
      CLOSE get_uom_type;

      /* ==================================
      Step TWO - determine the uom_class
      and standard factor for the new
      unit of measure.
      ==================================*/
      OPEN get_uom_type(l_new_uom_code, pitem_id);
      FETCH get_uom_type INTO var1, l_new_um_type, l_new_uom_factor;
      IF(get_uom_type%NOTFOUND) THEN
        CLOSE get_uom_type;
        RETURN UOM_NEW_UOMTYPE_ERR;
      END IF;
      CLOSE get_uom_type;

      /*Rounding problem corrected by changing the order of operations in uom_conversion.*/
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
      uom class an conversion factor.
      =========================================*/
      IF(l_cur_um_type <> l_new_um_type) THEN
        OPEN get_inv_uom(pitem_id);
        FETCH get_inv_uom INTO l_item_invum_code;
        IF(get_inv_uom%NOTFOUND) THEN
          CLOSE get_inv_uom;
          RETURN UOM_INVUOM_ERR;
        END IF;
        CLOSE get_inv_uom;

        OPEN get_uom_type(l_item_invum_code, pitem_id);
        FETCH get_uom_type INTO var1, l_inv_um_type, l_inv_uom_factor;
        IF(get_uom_type%NOTFOUND) THEN
          CLOSE get_uom_type;
          RETURN UOM_INV_UOMTYPE_ERR;
        END IF;
        CLOSE get_uom_type;
      END IF;

      /* ==============================================
      Step FIVE - If the uom classes for the current
      and the inventory uoms are NOT THE SAME,
      we need the CONVERSION factors for both the
      current and new uoms so that we can convert
      to the items primary uom.
      ==============================================*/
      IF(l_cur_um_type <> l_inv_um_type) THEN
        IF(pcnv_factor <> 0) THEN
          l_cur_conv_factor := pcnv_factor;
        ELSE
          OPEN get_lab_conv_factor(plab_id,plot_number, pitem_id, pformula_id,l_parm_name);
          FETCH get_lab_conv_factor INTO l_cur_conv_factor;
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
      Step SEVEN - If the uom classes are NOT THE SAME,
      we need the CONVERSION factors for both the
      current and new uoms so that we can convert
      to the items primary uom.
      ==============================================*/
      IF(l_inv_um_type <> l_new_um_type) THEN
        IF(pcnv_factor <> 0) THEN
          l_new_conv_factor := pcnv_factor;
        ELSE
          OPEN get_lab_conv_factor(plab_id, plot_number, pitem_id, pformula_id,l_parm_name);
          FETCH get_lab_conv_factor INTO l_new_conv_factor;
          IF(get_lab_conv_factor%NOTFOUND) THEN
            CLOSE get_lab_conv_factor;
            RETURN UOM_LAB_CONV_ERR;
          END IF;
          CLOSE get_lab_conv_factor;
        END IF;
      ELSIF(l_inv_um_type = l_new_um_type) THEN
        l_new_conv_factor := new_factor_default;
      END IF;

      /* Rounding problem corrected by changing the order of operations in uom_conversion.*/
      l_new_qty  := ((pcur_qty * l_cur_uom_factor * l_cur_conv_factor) /
                    (l_new_uom_factor * l_new_conv_factor));
      IF(patomic = 1) THEN
        l_new_qty := ROUND(l_new_qty);
      END IF;
    ELSE
      l_new_qty := INV_CONVERT.INV_UM_CONVERT (item_id 	       => pitem_id,
                                               lot_number      => plot_number,
                                               organization_id => plab_id,
                                               precision       => 5,
                                               from_quantity   => pcur_qty,
                                               from_unit       => pcur_uom,
                                               to_unit         => pnew_uom,
                                               from_name       => NULL,
                                               to_name	       => NULL);
    END IF;
    RETURN l_new_qty;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN SQLCODE;
    END uom_conversion;

END GMD_LABUOM_CALCULATE_PKG;

/
