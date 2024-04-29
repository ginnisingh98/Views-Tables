--------------------------------------------------------
--  DDL for Package Body GMDFMVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDFMVAL_PUB" AS
  /* $Header: GMDPFMVB.pls 120.13.12010000.5 2009/04/20 07:16:57 kannavar ship $ */
  /* ============================================= */
  /* PROCEDURE: */
  /*   get_formula_id */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   retrieving a formula's surrogate key unique number */
  /*   based on the passed in formula number and formula */
  /*   version and formula type. */
  /* */
  /*   Formula Number is returned in the xvalue parameter */
  /*   and xreturn_code is 0 (zero) upon success. Failure */
  /*   returns xvalue as NULL and xreturn_code contains the */
  /*   error code. */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.get_formula_id(pformula_no, */
  /*                                      pversion, */
  /*                                      ptype, */
  /*                                      xvalue, */
  /*                                      xreturn_code); */
  /* */
  /* RETURNS: */
  /*       0 Success */
  /*  -92200 Formula_id not found. */
  /*     < 0 RDBMS error */
  /* =============================================  */

  PROCEDURE get_formula_id(pformula_no  IN VARCHAR2,
                           pversion     IN NUMBER,
                           xvalue       OUT NOCOPY NUMBER,
                           xreturn_code OUT NOCOPY NUMBER) IS

    /* Local variables. */
    /* ================ */
    l_formula_id fm_form_mst.formula_id%TYPE := 0;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR get_id IS
      SELECT formula_id
        FROM fm_form_mst
       WHERE formula_no = UPPER(pformula_no)
         AND formula_vers = pversion;

    /* ================================================ */
  BEGIN

    OPEN get_id;
    FETCH get_id
      INTO l_formula_id;

    IF (get_id%NOTFOUND) THEN
      xvalue       := NULL;
      xreturn_code := FMVAL_FORMID_ERR;
      CLOSE get_id;
      RETURN;
    END IF;

    xvalue       := l_formula_id;
    xreturn_code := 0;
    CLOSE get_id;
    RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN;
  END get_formula_id;

  /* ====================================== */
  /* get_formulaline_id */
  /* This function validates the existence of formulaline_id */
  /* in the database. */
  /* Prior to updates the formulaline_id value */
  /* should exists in the database */
  /* IN  formulaline_id         NUMBER */
  /* OUT NOCOPY return_code             NUMBER */
  /* ==================================================== */
  PROCEDURE get_formulaline_id(pformulaline_id IN NUMBER,
                               xreturn_code    OUT NOCOPY NUMBER) IS

    /* Local variables. */
    /* ================ */
    l_formulaline_id fm_matl_dtl.formulaline_id%TYPE := 0;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR get_formulalineid IS
      SELECT formulaline_id
        FROM fm_matl_dtl
       WHERE formulaline_id = pformulaline_id;

    /* ================================================ */
  BEGIN
    OPEN get_formulalineid;
    FETCH get_formulalineid
      INTO l_formulaline_id;

    IF (get_formulalineid%NOTFOUND) THEN
      xreturn_code := FMVAL_FORMLINEID_ERR;
      CLOSE get_formulalineid;
      RETURN;
    END IF;

    xreturn_code := 0;
    CLOSE get_formulalineid;
    RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN;

  END get_formulaline_id;

  /* ============================================= */
  /* PROCEDURE: */
  /*   get_item_id */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   retrieving an item's surrogate key unique number */
  /*   based on the passed in item number. */
  /* */
  /*   ITEM_ID is returned in the xvalue parameter */
  /*   and xreturn_code is 0 (zero) upon success. Failure */
  /*   returns xvalue as NULL and xreturn_code contains the */
  /*   error code. */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.get_item_id(pitem_no, */
  /*                                   xitem_id, */
  /*                                   xitem_um, */
  /*                                   xreturn_code); */
  /* */
  /* RETURNS: */
  /*       0 Success */
  /*  -92201 Item Number not found. */
  /*  -92202 Item Number is inactive. */
  /*  -92203 Item Number is Experimental. */
  /*     < 0 RDBMS error */
  /* =============================================  */
  PROCEDURE get_item_id(pitem_no           IN VARCHAR2,
                        pinventory_item_id IN NUMBER,
                        porganization_id   IN NUMBER,
                        xitem_id           OUT NOCOPY NUMBER,
                        xitem_um           OUT NOCOPY VARCHAR2,
                        xreturn_code       OUT NOCOPY NUMBER) IS

    /* Local variables. */
    /* ================ */
    l_item_id      mtl_system_items_kfv.inventory_item_id%TYPE := 0;
    l_item_um      mtl_system_items_kfv.primary_uom_code%TYPE := NULL;
    l_enabled_flag mtl_system_items_kfv.enabled_flag%TYPE := 0;

    CURSOR get_id IS
      SELECT inventory_item_id, primary_uom_code, enabled_flag
        FROM mtl_system_items_kfv
       WHERE concatenated_segments = pitem_no
         AND organization_id = porganization_id;

    CURSOR get_it_id IS
      SELECT inventory_item_id, primary_uom_code, enabled_flag
        FROM mtl_system_items
       WHERE inventory_item_id = pinventory_item_id
         AND organization_id = porganization_id;

  BEGIN
    IF (pitem_no IS NOT NULL) THEN
      OPEN get_id;
      FETCH get_id
        INTO l_item_id, l_item_um, l_enabled_flag;
      IF (get_id%NOTFOUND) THEN
        xitem_id     := NULL;
        xitem_um     := NULL;
        xreturn_code := -1;
        CLOSE get_id;
        RETURN;
      END IF;

      IF (l_enabled_flag = 'N') THEN
        xitem_id     := NULL;
        xitem_um     := NULL;
        xreturn_code := -1;
        CLOSE get_id;
        RETURN;
      END IF;

      xitem_id     := l_item_id;
      xitem_um     := l_item_um;
      xreturn_code := 0;
      CLOSE get_id;
      RETURN;
    ELSIF (pinventory_item_id IS NOT NULL) THEN
      OPEN get_it_id;
      FETCH get_it_id
        INTO l_item_id, l_item_um, l_enabled_flag;
      IF (get_it_id%NOTFOUND) THEN
        xitem_id     := NULL;
        xitem_um     := NULL;
        xreturn_code := -1;
        CLOSE get_it_id;
        RETURN;
      END IF;

      IF (l_enabled_flag = 'N') THEN
        xitem_id     := NULL;
        xitem_um     := NULL;
        xreturn_code := -1;
        CLOSE get_it_id;
        RETURN;
      END IF;

      xitem_id     := l_item_id;
      xitem_um     := l_item_um;
      xreturn_code := 0;

      CLOSE get_it_id;
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END get_item_id;

  /* ============================================= */
  /* PROCEDURE: */
  /*   determine_product */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   retrieving a formula's product item_id and the */
  /*   product's inventory (primary) unit of measure */
  /*   based on the passed in formula ID surrogate. */
  /* */
  /*   ITEM_ID and ITEM_UM are returned in the xitem_id and */
  /*   xitem_um parameters respectively. */
  /*   and xreturn_code is 0 (zero) upon success. Failure */
  /*   returns values as NULL and xreturn_code contains the */
  /*   error code. */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.determine_product(formula_id, */
  /*                                       xitem_id, */
  /*                                       xitem_um, */
  /*                                       xreturn_code); */
  /* */
  /* RETURNS: */
  /*       0 Success */
  /*  -92211 Cannot determine product */
  /*  -92212 Cannot determine product's primary UOM */
  /*     < 0 RDBMS error */
  /* =============================================  */
  PROCEDURE determine_product(pformula_id  IN NUMBER,
                              xitem_id     OUT NOCOPY NUMBER,
                              xitem_um     OUT NOCOPY VARCHAR2,
                              xreturn_code OUT NOCOPY NUMBER) IS

    /* Local variables. */
    /* ================ */
    l_item_id mtl_system_items.inventory_item_id%TYPE := 0;
    l_um      mtl_system_items.primary_uom_code%TYPE := NULL;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR get_product IS
      SELECT inventory_item_id
        FROM fm_matl_dtl
       WHERE formula_id = pformula_id
         AND line_type = 1;

    CURSOR get_uom IS
      SELECT primary_uom_code
        FROM mtl_system_items_kfv
       WHERE inventory_item_id = l_item_id;

    /* ================================================ */
  BEGIN

    OPEN get_product;
    FETCH get_product
      INTO l_item_id;
    IF (get_product%NOTFOUND) THEN
      CLOSE get_product;
      xitem_id     := 0;
      xreturn_code := FMVAL_PRODUCT_FIND_ERR;
      RETURN;
    END IF;
    CLOSE get_product;

    OPEN get_uom;
    FETCH get_uom
      INTO l_um;

    IF (get_uom%NOTFOUND) THEN
      CLOSE get_uom;
      xitem_um     := NULL;
      xreturn_code := FMVAL_PRODUCT_INVUOM_ERR;
      RETURN;
    END IF;
    CLOSE get_uom;

    /* Assign our values and return */
    /* ============================ */

    xitem_id     := l_item_id;
    xitem_um     := l_um;
    xreturn_code := 0;
    RETURN;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN;
  END determine_product;

  /* ============================================= */
  /* FUNCTION */
  /*  detail_line_val */
  /*  Parameters passed */
  /*  IN formula_id IN Number */
  /*  line_no In NUMBER */
  /*  line_type IN NUmber */
  /* */
  /*  RETURNS NUMBER */
  /*  0 Success */
  /* */
  /* Description: */
  /*   Validates before inserting detail line into fm_matl_dtl */
  /*   table. */
  /*   If this record that has same formula_id, line_type , */
  /*   and line_no we cannot make an insert. */
  /*   In such cases we return a non zero value. */
  /*   If no record is found we return a zero */
  /*  =============================================== */
  FUNCTION detail_line_val(pformula_id NUMBER,
                           pline_no    NUMBER,
                           pline_type  NUMBER) RETURN NUMBER IS

    /* Local variables. */
    /* ================ */
    l_line_existing NUMBER := 0;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR detail_line_cur IS
      SELECT formula_id
        FROM fm_matl_dtl
       WHERE formula_id = pformula_id
         AND line_type = pline_type
         AND line_no = pline_no;

    /* ================================================ */
  BEGIN
    OPEN detail_line_cur;
    FETCH detail_line_cur
      INTO l_line_existing;

    IF (detail_line_cur%NOTFOUND) THEN
      RETURN 0;
    ELSE
      RETURN FMVAL_DETAILLINE_ERR;
    END IF;

    CLOSE detail_line_cur;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FMVAL_DETAILLINE_ERR;
  END;

  /* ============================================= */
  /* FUNCTION: */
  /*   formula_class_val */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   validating a formula class */
  /*   based on the passed in formula class */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.formula_class_val(pform_class); */
  /* */
  /* RETURNS: */
  /*       0 Success */
  /*  -92206 Formula Class Not Found. */
  /*     < 0 RDBMS error */
  /* =============================================  */
  FUNCTION formula_class_val(pform_class VARCHAR2) RETURN NUMBER IS

    /* Local variables. */
    /* ================ */
    l_form_class_desc fm_form_cls.formula_class_desc%TYPE;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR class_val IS
      SELECT formula_class_desc
        FROM fm_form_cls
       WHERE formula_class = UPPER(pform_class)
         AND delete_mark = 0;

    /* ================================================ */
  BEGIN

    OPEN class_val;
    FETCH class_val
      INTO l_form_class_desc;

    IF (class_val%NOTFOUND) THEN
      CLOSE class_val;
      RETURN FMVAL_CLASS_ERR;
    END IF;

    CLOSE class_val;
    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLCODE;
  END formula_class_val;

  /* ============================================= */
  /* FUNCTION: */
  /*   cost_alloc_val */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   validating a cost allocation */
  /*   based on the passed in cost allocation amount */
  /*   and the line type of the item.  This is available */
  /*   for products only. */
  /*   */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.cost_alloc_val(pcost_alloc, */
  /*                                      pline_type); */
  /* */
  /* RETURNS: */
  /*       0 Success */
  /*  -92208 Line is not a product */
  /*  -92209 Cost Allocation percentage error. */
  /*     < 0 RDBMS error */
  /* =============================================  */
  FUNCTION cost_alloc_val(pcost_alloc NUMBER, pline_type NUMBER)
    RETURN NUMBER IS

    /* ================================================ */
  BEGIN

    IF (pline_type <> 1) THEN
      RETURN FMVAL_COSTALLOC_ERR;
    END IF;

    IF (pcost_alloc < 0 OR pcost_alloc > 100) THEN
      RETURN FMVAL_COSTPCT_ERR;
    END IF;

    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLCODE;
  END cost_alloc_val;

  /* ============================================= */
  /* FUNCTION: */
  /*   type_val */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   validating all formula type columns */
  /* */
  /*   Valid line type are as follows: */
  /*     -1 Ingredient */
  /*      1 Finished good */
  /*      2 ByProduct */

  /*   Valid scale type are as follows: */
  /*     0 - No  Scaling  */
  /*     1 - Yes Item should be scalable */

  /*   Valid phantom types are as follows: */
  /*     0 - Not a phantom */
  /*     1 - automatic phantom replacement */
  /*     2 - manual phantom */
  /* */
  /*   Valid release types are as follows: */
  /*     0 - Automatic */
  /*     1 - Manual */
  /*     2 - Incremental */
  /* */
  /*   Valid formula use types are as follows: */
  /*     0 - Production */
  /*     1 - MRP */
  /*     2 - Costing */
  /*     3 - MSDS (Material Safety Data Sheets) */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.formula_class_val(pcolumn_name, */
  /*                                          pvalue); */
  /* */
  /* RETURNS: */
  /*       0 Success */
  /*  -92207 Formula Class not found. */
  /*     < 0 RDBMS error */
  /* */
  /* HISTORY: */
  /*   P.Raghu  18-AUG-2003  Bug#3090630.           */
  /*            Changed datatype of pvalue parameter*/
  /*            to VARCHAR2 from NUMBER.            */
  /* =============================================  */
  --Begin Bug#3090630 P.Raghu
  --Changed datatype of pvalue parameter to VARCHAR2 from NUMBER.
  FUNCTION type_val(ptype_name VARCHAR2, pvalue VARCHAR2) RETURN NUMBER IS
    --End Bug#3090630

    /* Local variables. */
    /* ================ */
    l_value fnd_lookups.lookup_code%TYPE;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR form_type_val IS
      SELECT unique(lookup_code)
        FROM gem_lookups
       WHERE lookup_type = ptype_name
            --Begin Bug#3090630 P.Raghu
            --Removed TO_CHAR function for pvalue parameter.
         AND lookup_code = pvalue;
    --End Bug#3090630

    /* ================================================ */
  BEGIN

    OPEN form_type_val;
    FETCH form_type_val
      INTO l_value;

    IF (form_type_val%NOTFOUND) THEN
      CLOSE form_type_val;
      RETURN FMVAL_TYPE_ERR;
    END IF;

    CLOSE form_type_val;
    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN SQLCODE;
  END type_val;

  /* ============================================= */
  /* FUNCTION: */
  /*   GMD_EFFECTIVITY_LOCKED_STATUS */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   determining if a cost rollup has been done. */
  /*   If it has, returning a 900 denotes that  */
  /*   effectivity is not subject to change and is locked */
  /*   down.  Otherwise if the rollover indicator in the */
  /*   cm_cmpt_dtl table is zero or does not exist,  */
  /*   allow modification to the effectivity. */

  /* SYNOPSIS: */
  /*   iret := GMD_EFFECTIVITY_LOCKED_STATUS(pfmeff_id); */
  /* */
  /* RETURNS: */
  /*      700 Success (effectivity may be changed) */
  /*      900 Effectivity is locked (update not allowed) */
  /* =============================================  */
  FUNCTION GMD_EFFECTIVITY_LOCKED_STATUS(pfmeff_id NUMBER) RETURN VARCHAR2 IS

    l_status VARCHAR2(32) := '700';
    iret     NUMBER;

    CURSOR locked_val_cur(pfmeff_id NUMBER) IS
      SELECT 1
        FROM sys.dual
       WHERE EXISTS (SELECT 1
                FROM cm_cmpt_dtl
               WHERE fmeff_id = pfmeff_id
                 AND rollover_ind = 1);
  BEGIN
    OPEN locked_val_cur(pfmeff_id);
    FETCH locked_val_cur
      INTO iret;
    IF (locked_val_cur%NOTFOUND) THEN
      l_status := '700';
    ELSE
      l_status := '900';
    END IF;
    CLOSE locked_val_cur;

    RETURN l_status;

  END GMD_EFFECTIVITY_LOCKED_STATUS;

  /* ============================================= */
  /* FUNCTION: */
  /*   locked_effectivity_val */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   determining if a cost rollup has been done. */
  /*   If it has, returning a -92215 denotes that  */
  /*   effectivity is not subject to change and is locked */
  /*   down.  Otherwise if the rollover indicator in the */
  /*   cm_cmpt_dtl table is zero or does not exist,  */
  /*   allow modification to the effectivity. */
  /* */
  /*   This validation is for CHANGES only! */
  /*   */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.locked_effectivity_val(pformula_id); */
  /* */
  /* RETURNS: */
  /*       0 Success (effectivity may be changed) */
  /*  -92213 Effectivity is locked (update not allowed) */
  /*     < 0  error */
  /* =============================================  */
  FUNCTION locked_effectivity_val(pformula_id NUMBER) RETURN NUMBER IS

    /* Local variables. */
    /* ================ */
    l_formula_id NUMBER := 0;

    /* Cursor Definitions. */
    /* =================== */
    CURSOR locked_val IS
      SELECT rcp.formula_id
        FROM gmd_recipe_validity_rules vr,
             gmd_recipes_b             rcp,
             cm_cmpt_dtl               cost
       WHERE rcp.formula_id = pformula_id
         AND vr.recipe_validity_rule_id = cost.fmeff_id
         AND vr.recipe_id = rcp.recipe_id
         AND cost.rollover_ind = 1;

    /* ================================================ */
  BEGIN
    OPEN locked_val;
    FETCH locked_val
      INTO l_formula_id;
    CLOSE locked_val;

    IF (l_formula_id <> 0) THEN
      RETURN FMVAL_LOCKED_EFF;
    ELSE
      RETURN 0;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN SQLCODE;
  END locked_effectivity_val;

  /* ============================================= */
  /* FUNCTION: */
  /*   convertuom_val */
  /* */
  /* DESCRIPTION: */
  /*   This PL/SQL function is responsible for  */
  /*   validating that a unit of measure entered  */
  /*   for a formula line item can be converted to the item's */
  /*   primary unit of measure (UOM) in the event the  */
  /*   formualted UOM of the item is different from */
  /*   the item's primary inventored UOM. */
  /* */
  /* SYNOPSIS: */
  /*   iret := GMDFMVAL_PUB.convertuom_val(pitem_id, */
  /*                                       pfrom_uom, */
  /*                                       pto_uom); */
  /* */
  /*   pitem_id  the item surrogate (unique number). */
  /*   pfrom_uom the formulated uom code you are working on. */
  /*   pto_uom   the items primary inventory unit of measure */
  /* */
  /* RETURNS: */
  /*    0 Success */
  /*   -1 - Package problem. */
  /*   -3 - UM_TYPE and conversion factor for current UOM not found. */
  /*   -4 - UM_TYPE and conversion factor for NEW UOM not found. */
  /*   -5 - Cannot determine INVENTORY UOM for item. */
  /*   -6 - UM_TYPE and conversion factor for INV UOM not found. */
  /*   -7 - Cannot find conversion factor for CURRENT UOM. */
  /*  -10 - Cannot find conversion factor for NEW UOM. */
  /*  -11 - Item_id not passed as a parameter. */
  /*  < 0 RDBMS Oracle Error. */
  /* =============================================  */
  FUNCTION convertuom_val(pitem_id  NUMBER,
                          pfrom_uom VARCHAR2,
                          pto_uom   VARCHAR2) RETURN NUMBER IS

    /* Local variables. */
    /* ================ */
    iret NUMBER := 0;

    /* ================================================ */
  BEGIN
    iret := INV_CONVERT.inv_um_convert(item_id       => pitem_id,
                                       precision     => 5,
                                       from_quantity => 100,
                                       from_unit     => pfrom_uom,
                                       to_unit       => pto_uom,
                                       from_name     => NULL,
                                       to_name       => NULL);
    IF (iret < 0) THEN
      RETURN iret;
    END IF;

    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN
      IF (ss_debug = 1) THEN
        null;
      END IF;

      RETURN SQLCODE;
  END convertuom_val;

  /*  ******************************************************
  Wrapper for getting formula element specifics
  Take the elment name that needs to be returned as in Parameter
  e.g if the pElementName is formulaline it returns all formulaline
  based on the formula_id
  ****************************************************** */

  PROCEDURE get_element(pElement_name IN VARCHAR2,
                        pRecord_in    IN formula_info_in,
                        xTable_out    OUT NOCOPY formula_table_out,
                        xReturn       OUT NOCOPY VARCHAR2) IS

    /* Local variables */
    litem_id      mtl_system_items.inventory_item_id%TYPE;
    litem_um      mtl_system_items.primary_uom_code%TYPE;
    l_return_code NUMBER;
    X_count       NUMBER := 1;

    l_formula_id NUMBER;

    /* Cursor that returns multiple formulas for  */
    /* an item. */
    CURSOR get_fmitem_cur(pitem_id IN NUMBER) IS
      select h.formula_no, h.formula_vers, h.formula_id
        from fm_form_mst h, fm_matl_dtl d
       where d.inventory_item_id = pitem_id
         AND h.formula_id = d.formula_id;

    /* Cursor that returns formulaline_ids for a formula */
    CURSOR get_fmline_cur(pformula_id IN NUMBER) IS
      select formulaline_id
        from fm_matl_dtl
       where formula_id = pformula_id;

    /* Cursor that formula_no and version for a formula_id */
    CURSOR get_formula_no(pformula_id IN NUMBER) IS
      select formula_no, formula_vers
        from fm_form_mst
       where formula_id = pformula_id;

    /* Cursor that gets formula_id when formula_no and vers  */
    /* is passed. */
    CURSOR get_formula_id IS
      select formula_id
        from fm_form_mst
       where formula_no = UPPER(pRecord_in.formula_no)
         and formula_vers = pRecord_in.formula_vers;

    /* Cursor that returns user info */
    CURSOR get_user_id IS
      select user_id from fnd_user where user_name = pRecord_in.user_name;

  BEGIN

    IF (Upper(pElement_name) = 'FORMULA') THEN
      /* User might have the formula_id  */
      /* and might need all other formula details */
      /* for this formula e.g formula_desc */
      IF (pRecord_in.formula_id IS NOT NULL) THEN
        OPEN get_formula_no(pRecord_in.formula_id);
        FETCH get_formula_no
          into xTable_out(1) .formula_no, xTable_out(1) .formula_vers;

        xTable_out(1).formula_id := pRecord_in.formula_id;

        If (get_formula_no%NOTFOUND) THEN
          xReturn := 'E';
        ELSE
          xReturn := 'S';
        END IF;
        CLOSE get_formula_no;
        /* User might provide formula_no and version */
        /* and might need all formula info */
      ELSIF ((pRecord_in.formula_no IS NOT NULL) AND
            (pRecord_in.formula_vers IS NOT NULL)) THEN

        OPEN get_formula_id;
        FETCH get_formula_id
          INTO xTable_out(1) .formula_id;

        xTable_out(1).formula_no := pRecord_in.formula_no;
        xTable_out(1).formula_vers := pRecord_in.formula_vers;

        If (get_formula_id%NOTFOUND) THEN
          xReturn := 'E';
        ELSE
          xReturn := 'S';
        END IF;
        CLOSE get_formula_id;
      END IF;
    END IF;

    IF (pElement_name = 'USER') THEN

      OPEN get_user_id;
      FETCH get_user_id
        INTO xTable_out(1) .user_id;

      IF (get_user_id%NOTFOUND) THEN
        xReturn := 'E';
      ELSE
        xReturn := 'S';
      END IF;
      CLOSE get_user_id;
    END IF;

    IF (pElement_name = 'FORMULALINE') THEN

      /* User passes formula_id info and gets */
      /* the formulaline info */
      IF (pRecord_in.formula_id IS NOT NULL) THEN

        FOR get_fmline_rec IN get_fmline_cur(pRecord_in.formula_id) LOOP
          xTable_out(X_count).formulaline_id := get_fmline_rec.formulaline_id;
          X_count := X_count + 1;
        END LOOP;

        IF (get_fmline_cur%NOTFOUND) THEN
          xReturn := 'E';
        ELSE
          xReturn := 'S';
        END IF;

      END IF;

    END IF; /* End for formulaline condition */

    IF (pElement_name = 'RECIPE') THEN

      /* get the formula_id from gmd_recipes table */
      IF (pRecord_in.Recipe_id IS NOT NULL) THEN
        -- get the formula id

        Select formula_id
          INTO l_formula_id
          From gmd_recipes
         Where recipe_id = pRecord_in.Recipe_id;

        OPEN get_formula_no(l_formula_id);
        FETCH get_formula_no
          INTO xTable_out(1) .formula_no, xTable_out(1) .formula_vers;
        CLOSE get_formula_no;
        xTable_out(1).formula_id := pRecord_in.formula_id;

        -- get the formula line info
        FOR get_fmline_rec IN get_fmline_cur(l_formula_id) LOOP
          xTable_out(X_count).formulaline_id := get_fmline_rec.formulaline_id;
          X_count := X_count + 1;
        END LOOP;

      ELSE
        xReturn := 'E';
      END IF;

    END IF; /* end for recipe clause */

  END get_element;

  /* *************************************************************
  *  Overloaded function that returns the formula header and details
  *  in separate form
  *  Current accepts recipe as the pElement_name
  ****************************************************************/

  PROCEDURE get_element(pElement_name      IN VARCHAR2,
                        pRecord_in         IN formula_info_in,
                        pDate              IN DATE Default Null, --Bug  4479101
                        xFormulaHeader_rec OUT NOCOPY fm_form_mst%ROWTYPE,
                        xFormulaDetail_tbl OUT NOCOPY formula_detail_tbl,
                        xReturn            OUT NOCOPY VARCHAR2) IS

    l_formula_id NUMBER;
    X_count      NUMBER := 1;

    /* Bug 2307820 - Thomas Daniel */
    /* Added order by condition and changed the cursor to return */
    /* the entire row instead of just formulaline ids            */
    /* Cursor that returns formulaline details for a formula */
    CURSOR get_fmline_cur(pformula_id IN NUMBER) IS
      select *
        from fm_matl_dtl
       where formula_id = pformula_id
       order by line_type, line_no;

  BEGIN
    -- Initialize the status
    xReturn := 'S';

    IF (pElement_name = 'RECIPE') THEN

      /* get the formula_id from gmd_recipes table */
      IF (pRecord_in.Recipe_id IS NOT NULL) THEN
        -- get the formula id

        SELECT formula_id
          INTO l_formula_id
          FROM gmd_recipes
         WHERE recipe_id = pRecord_in.Recipe_id;

        -- Call substitute item codeset, Bug  4479101
        get_substitute_items(pFormula_id        => l_formula_id,
                             pDate              => pDate,
                             xFormulaDetail_tbl => xFormulaDetail_tbl);
        FOR formula_rec IN (select *
                              from fm_form_mst
                             where formula_id = l_formula_id) LOOP
          xFormulaHeader_rec := formula_rec;
        END LOOP;
      ELSE
        xReturn := 'E';
      END IF;

    END IF;

  END get_element;

  --Bug 4479101, Item Substitution
  PROCEDURE get_substitute_items(pFormula_id        in NUMBER,
                                 pDate              in DATE Default Null,
                                 xFormulaDetail_tbl OUT NOCOPY formula_detail_tbl) IS

    CURSOR get_fmline_cur(vformula_id IN NUMBER) IS
      select *
        from fm_matl_dtl
       where formula_id = vformula_id
       order by line_type, line_no;

    X_count                   Number := 0;
    xFormulaDetail_output_tbl formula_detail_tbl;
  BEGIN
    -- get the formula line info
    FOR get_fmline_rec IN get_fmline_cur(pformula_id) LOOP
      X_count := X_count + 1;
      IF ((get_fmline_rec.line_type = -1) AND
         ((pDate IS NOT NULL) AND
         (pDate >= get_fmline_rec.ingredient_end_date))) THEN
        get_substitute_line_item(pFormulaline_id    => get_fmline_rec.formulaline_id,
                                 pItem_id           => get_fmline_rec.inventory_item_id,
                                 pQty               => get_fmline_rec.qty,
                                 pUom               => get_fmline_rec.detail_uom,
                                 pScale_multiple    => get_fmline_rec.scale_multiple,
                                 pDate              => pDate,
                                 xFormulaDetail_tbl => xFormulaDetail_output_tbl);

        -- Assign each record of the formula line ouput table
        -- In Sanofi's case this should return only one row
        For j IN 1 .. xFormulaDetail_output_tbl.count Loop
          xFormulaDetail_tbl(X_count) := xFormulaDetail_output_tbl(j);
        End Loop;
      ELSE
        xFormulaDetail_tbl(X_count) := get_fmline_rec;
      END IF;

    END LOOP;
  END get_substitute_items;

  PROCEDURE get_substitute_line_item(pFormulaline_id    in NUMBER,
                                     pItem_id           in Number Default Null,
                                     pQty               in Number Default Null,
                                     pUom               in Varchar2 Default Null,
                                     pScale_multiple    in Number Default Null,
                                     pDate              in DATE,
                                     xFormulaDetail_tbl Out NOCOPY formula_detail_tbl) IS

    CURSOR Cur_retrieve_fmline(vFormulaline_id Number) IS
      SELECT * FROM fm_matl_dtl WHERE formulaline_id = vFormulaline_id;

    CURSOR get_item_substitution(vFormula_id Number, vFormulaline_id Number, vItem_id Number, vDate Date) IS
      SELECT *
        FROM gmd_material_effectivities_vw vw
       WHERE vw.formula_id = vFormula_id
         AND vw.formulaline_id = vFormulaline_id
         AND vw.line_item_id = vItem_id
         AND vw.start_date <= vDate
         AND (vw.end_date IS NULL OR vw.end_date >= vDate)
       ORDER BY vw.preference asc, vw.start_date;

    CURSOR get_replacement_factor(vFormula_id Number, vline_item_id Number, vSubstitute_item_id Number) IS
      SELECT hdr.original_qty,
             dtl.unit_qty,
             hdr.original_uom,
             dtl.detail_uom,
             hdr.replacement_uom_type /* Added dtl.detail_uom 8271618*/
        FROM gmd_formula_substitution    fmsub,
             gmd_item_substitution_hdr_b hdr,
             gmd_item_substitution_dtl   dtl
       Where fmsub.formula_id = vFormula_id
         and fmsub.substitution_id = hdr.substitution_id
         and hdr.substitution_id = dtl.substitution_id
         and hdr.original_inventory_item_id = vLine_Item_id
         and hdr.substitution_status between 700 and 799
         and fmsub.associated_flag = 'Y'
         and dtl.inventory_item_id = vSubstitute_item_id
       Order by hdr.preference asc, hdr.start_date;

    X_count            Number := 1;
    X_SubstituteExists Boolean := False;

    l_batch_scale_factor     NUMBER := 1;
    l_old_replacement_factor NUMBER := 1;
    l_sub_original_qty       NUMBER;
    l_sub_replace_qty        NUMBER;
    l_original_item_uom      VARCHAR2(4);

    get_fmline_rec        fm_matl_dtl%ROWTYPE;
    l_new_qty             NUMBER;
    l_integer_scale_ratio NUMBER := 1;

    l_subst_recs           NUMBER := 0; /* Added in Bug No.7460898 */
    l_subst_item_uom       VARCHAR2(4); /* Bug No.8271618 */
    l_replacement_uom_type NUMBER := 0; /* Bug No.8271618 */
    l_uom                  VARCHAR2(4); /* Bug No.8271618 */

  BEGIN
    -- Considering item substitution for each formula line
    OPEN Cur_retrieve_fmline(pFormulaline_id);
    FETCH Cur_retrieve_fmline
      INTO get_fmline_rec;
    CLOSE Cur_retrieve_fmline;

    -- Initially assign formula line record output table
    -- Data in this table can be manipulated later
    xFormulaDetail_tbl(X_count) := get_fmline_rec;

    -- We consider subtitution only formula line end date
    -- has a end date.  If the end date is NULL it implies that
    -- this ingredient has no substitution list associated to it

    IF ((get_fmline_rec.ingredient_end_date IS NOT NULL) AND
       ((pDate IS NOT NULL) AND
       (pDate >= get_fmline_rec.ingredient_end_date))) THEN

      -- get the substitute item/items info for a specific date (pDate)
      -- since the cursor select is sorted based on preference we
      -- need to process only the top most row.

      FOR get_item_subs_rec IN get_item_substitution(get_fmline_rec.formula_id,
                                                     get_fmline_rec.formulaline_id,
                                                     get_fmline_rec.inventory_item_id,
                                                     pDate) LOOP

        X_SubstituteExists := True;

        -- replace formulaline ingredient with substitute item
        xFormulaDetail_tbl(X_count).inventory_item_id := get_item_subs_rec.item_id;
        xFormulaDetail_tbl(X_count).detail_uom := get_item_subs_rec.replacement_uom;

        -- Bug 4549316 started KSHUKLA
        /* IF NVL(pQty,0) > 0 THEN
        xFormulaDetail_tbl(X_count).qty :=
               get_line_qty (P_line_item_id      => get_item_subs_rec.line_item_id
                ,P_organization_id   => get_item_subs_rec.organization_id
                            ,P_formula_qty       => pQty
                            ,P_formula_uom       => get_item_subs_rec.line_item_uom
                            ,P_replacement_Item  => get_item_subs_rec.item_id
                            ,P_original_item_qty => get_item_subs_rec.sub_original_qty
                            ,P_original_item_uom => get_item_subs_rec.line_item_primary_uom
                            ,P_replace_unit_qty  => get_item_subs_rec.sub_replace_qty
                            ,P_replace_unit_uom  => get_item_subs_rec.substitution_item_uom
                            ,P_replacement_uom   => get_item_subs_rec.replacement_uom);

        l_integer_scale_ratio := xFormulaDetail_tbl(X_count).qty / pQty;

        ELSIF get_fmline_rec.qty > 0 THEN
        xFormulaDetail_tbl(X_count).qty :=
               get_line_qty (P_line_item_id      => get_item_subs_rec.line_item_id
                            ,P_organization_id   => get_item_subs_rec.organization_id
                            ,P_formula_qty       => get_item_subs_rec.line_item_qty
                            ,P_formula_uom       => get_item_subs_rec.line_item_uom
                            ,P_replacement_Item  => get_item_subs_rec.item_id
                            ,P_original_item_qty => get_item_subs_rec.sub_original_qty
                            ,P_original_item_uom => get_item_subs_rec.line_item_primary_uom
                            ,P_replace_unit_qty  => get_item_subs_rec.sub_replace_qty
                            ,P_replace_unit_uom  => get_item_subs_rec.substitution_item_uom
                            ,P_replacement_uom   => get_item_subs_rec.replacement_uom);

        l_integer_scale_ratio := xFormulaDetail_tbl(X_count).qty / get_item_subs_rec.line_item_qty;


        ELSE
          xFormulaDetail_tbl(X_count).qty := 0;

        END IF;   */

        /* Bug No.6667241 - Start */

        IF get_fmline_rec.qty > 0 THEN

          xFormulaDetail_tbl(X_count).qty := get_line_qty(P_line_item_id      => get_item_subs_rec.line_item_id,
                                                          P_organization_id   => get_item_subs_rec.organization_id,
                                                          P_formula_qty       => get_item_subs_rec.line_item_qty,
                                                          P_formula_uom       => get_item_subs_rec.line_item_uom,
                                                          P_replacement_Item  => get_item_subs_rec.item_id,
                                                          P_original_item_qty => get_item_subs_rec.sub_original_qty,
                                                          P_original_item_uom => get_item_subs_rec.line_item_primary_uom,
                                                          P_replace_unit_qty  => get_item_subs_rec.sub_replace_qty,
                                                          P_replace_unit_uom  => get_item_subs_rec.substitution_item_uom,
                                                          P_replacement_uom   => get_item_subs_rec.replacement_uom);

          l_integer_scale_ratio := xFormulaDetail_tbl(X_count)
                                  .qty / get_item_subs_rec.line_item_qty;

        ELSIF NVL(pQty, 0) > 0 THEN
          xFormulaDetail_tbl(X_count).qty := get_line_qty(P_line_item_id      => get_item_subs_rec.line_item_id,
                                                          P_organization_id   => get_item_subs_rec.organization_id,
                                                          P_formula_qty       => pQty,
                                                          P_formula_uom       => get_item_subs_rec.line_item_uom,
                                                          P_replacement_Item  => get_item_subs_rec.item_id,
                                                          P_original_item_qty => get_item_subs_rec.sub_original_qty,
                                                          P_original_item_uom => get_item_subs_rec.line_item_primary_uom,
                                                          P_replace_unit_qty  => get_item_subs_rec.sub_replace_qty,
                                                          P_replace_unit_uom  => get_item_subs_rec.substitution_item_uom,
                                                          P_replacement_uom   => get_item_subs_rec.replacement_uom);

          l_integer_scale_ratio := xFormulaDetail_tbl(X_count).qty / pQty;
        ELSE
          xFormulaDetail_tbl(X_count).qty := 0;

        END IF;

        /* Bug No.6667241 - End */

        IF (xFormulaDetail_tbl(X_count).Scale_multiple IS NOT NULL) THEN
          xFormulaDetail_tbl(X_count).Scale_multiple := xFormulaDetail_tbl(X_count)
                                                       .Scale_multiple *
                                                        l_integer_scale_ratio;
        END IF;

        -- Extended support for batch call
        -- During batch update - batch material line items are chceked
        -- for any potential subtitutes.
        -- Again there are few ways that batch could call this procedure

        -- Possibility 1
        -- Parameter pItem_id that batch passes is the original item
        -- and there is a substitute for this original item

        IF (pItem_id IS NOT NULL) THEN
          IF (get_fmline_rec.inventory_item_id = pItem_id) AND
             (get_fmline_rec.qty > 0) THEN

            -- Get batch scale factor
            -- example -
            -- 1 lb Sugar <=> 10 Pack Neutra Sweet
            -- Formula ingredient => 100 Kg of Sugar

            -- Batch scale factor = batch qty to formula ingredient uom (Kg) /formula qty
            -- Batch scale factor = 500 Kg / 100 kg = 5
            IF (pQty IS NOT NULL) THEN
              l_batch_scale_factor := pQty / get_fmline_rec.qty;
              xFormulaDetail_tbl(X_count).qty := xFormulaDetail_tbl(X_count)
                                                .qty * l_batch_scale_factor;
            END IF;

            -- Possibility 2
            -- Batch passes pItem_id which is same as substitute item so in this
            -- case we pass back batch item details like qty, uom, scale_muliple etc
            -- without any change.
            -- For example -
            -- 1 lb Sugar <=> 10 Pack Neutra Sweet
            -- Batch Passes In pItem_id = Neutra Sweet
            -- Since the substitute item for Sugar (Neutra Sweet)
            -- hasnt changed we pass back details without any change
          ELSIF (get_item_subs_rec.item_id = pItem_id) THEN

            IF (pQty IS NOT NULL) THEN
              xFormulaDetail_tbl(X_count).qty := pQty;
            END IF;
            IF (pUom IS NOT NULL) THEN
              xFormulaDetail_tbl(X_count).detail_uom := pUom;
            END IF;
            IF (pScale_multiple IS NOT NULL) THEN
              xFormulaDetail_tbl(X_count).Scale_multiple := pScale_multiple;
            END IF;

            -- Possibility 3
            -- Batch passes pItem_id which is different from current substitute item
            -- in this case we need to find the ratio of pItem_id (old substitute) qty
            -- to formula original ingredient qty

            -- example -
            -- 1 lb Sugar <=> 10 Pack Neutra Sweet from 05/01/2005 to 05/30/2005
            -- 1 lb Sugar <=> 5 Each Splenda from 04/01/2005 to 04/30/2005
            -- Formula ingredient => 100 Kg of Sugar

            -- Run 1
            -- Batch runs update batch routine on 05/15/2005 (pDate)
            -- It would replace Sugar with Neutra Sweet
            -- After scaling batch qty, the batch details are
            -- Batch Item = Neutra Sweet, qty 10000 (scaled it by 5), Uom = Pack

            -- Run 2
            -- Now Batch runs update batch routine again on 04/15/2005 (pDate)
            -- The actual substitute for sugar is Splenda and not Neutra sweet
            -- Batch Passes In pItem_id = Neutra Sweet, Qty = 10000, Uom = Pack
            -- Batch scale factor = batch qty to formula ingredient uom (Kg) /formula qty
            -- Batch qty to formula ingr in Kg = 10000 * (original qty of Sugar/ unit qty of Neutra )
            -- Batch qty to formula ingr in Kg = 10000 * (1/10) = 1000 lb = 500 Kg
            -- Batch scale factor = 500 Kg / 100 kg = 5
          ELSIF (get_item_subs_rec.item_id <> pItem_id) AND
                (get_fmline_rec.qty > 0) THEN

            -- Step 1 : To find Batch qty in original ingredient uom
            -- if batch qty uom is expressed in terms of substitute uom
            -- i.e replacement_uom_type = 2
            -- then we need to find replacement factor between original
            -- ingredient and batch item (which is the substitute item)
            OPEN get_replacement_factor(vFormula_id         => get_fmline_rec.formula_id,
                                        vline_item_id       => get_fmline_rec.inventory_item_id,
                                        vSubstitute_item_id => pItem_id);
            FETCH get_replacement_factor
              INTO l_sub_original_qty, l_sub_replace_qty, l_original_item_uom, l_subst_item_uom, l_replacement_uom_type;
            CLOSE get_replacement_factor;

            IF ((l_sub_original_qty IS NOT NULL) AND
               (l_sub_original_qty <> 0)) THEN
              l_old_replacement_factor := l_sub_replace_qty /
                                          l_sub_original_qty;
            END IF;

            /* Bug No.8271618 - START */
            IF l_replacement_uom_type = 1 THEN
              l_uom := l_original_item_uom;
            ELSE
              l_uom := l_subst_item_uom;
            END IF;

            /* Bug No.8271618 - END */

            -- Batch qty in terms of original ingredient qty
            l_batch_scale_factor := inv_convert.inv_um_convert(item_id         => pItem_id,
                                                               lot_number      => NULL,
                                                               organization_id => get_fmline_rec.organization_id,
                                                               precision       => 5,
                                                               from_quantity   => --(pQty /
                                                                l_old_replacement_factor,
                                                               from_unit       => l_uom, --l_original_item_uom,
                                                               to_unit         => get_fmline_rec.detail_uom,
                                                               from_name       => NULL,
                                                               to_name         => NULL) /
                                    get_fmline_rec.qty;

            --Step 2 : Find the new qty and its scale multiple
            IF (pQty IS NOT NULL) THEN
              xFormulaDetail_tbl(X_count).qty := xFormulaDetail_tbl(X_count)
                                                .qty * l_batch_scale_factor;

            END IF;
          END IF; -- (get_item_subs_rec.line_item_id = pItem_id)
        END IF; -- pItem_id IS NOT NULL
        EXIT WHEN X_SubstituteExists;
      END LOOP; -- end loop for get_item_substitution

      /* Bug No.8222282 - Start */
      IF (NOT X_SubstituteExists) THEN
        IF get_fmline_rec.inventory_item_id <> pItem_id THEN
          OPEN get_replacement_factor(vFormula_id         => get_fmline_rec.formula_id,
                                      vline_item_id       => get_fmline_rec.inventory_item_id,
                                      vSubstitute_item_id => pItem_id);
          FETCH get_replacement_factor
            INTO l_sub_original_qty, l_sub_replace_qty, l_original_item_uom, l_subst_item_uom, l_replacement_uom_type;
          CLOSE get_replacement_factor;

          IF ((l_sub_original_qty IS NOT NULL) AND
             (l_sub_original_qty <> 0)) THEN
            l_old_replacement_factor := l_sub_replace_qty /
                                        l_sub_original_qty;
          END IF;
          /* Bug No.8271618 - Start */
          IF l_replacement_uom_type <> 1 THEN
            l_uom := l_original_item_uom;
          ELSE
            l_uom := l_subst_item_uom;
          END IF;

          /* Bug No.8271618  - End */
          -- Batch qty in terms of original ingredient qty
          l_batch_scale_factor := inv_convert.inv_um_convert(item_id         => pItem_id,
                                                             lot_number      => NULL,
                                                             organization_id => get_fmline_rec.organization_id,
                                                             precision       => 5,
                                                             from_quantity   => --(pQty /
                                                              l_old_replacement_factor,
                                                             from_unit       => l_uom, --l_original_item_uom,
                                                             to_unit         => get_fmline_rec.detail_uom,
                                                             from_name       => NULL,
                                                             to_name         => NULL);
          -- get_fmline_rec.qty;

          l_batch_scale_factor := l_batch_scale_factor / get_fmline_rec.qty;
          --Step 2 : Find the new qty and its scale multiple
          IF (pQty IS NOT NULL) THEN
            /* xFormulaDetail_tbl(X_count).qty := xFormulaDetail_tbl(X_count)
            .qty * l_batch_scale_factor;*/
            xFormulaDetail_tbl(X_count).qty := pQty / l_batch_scale_factor;

          END IF;

        ELSE

          --Check substitution records for the formulaline_id.
          SELECT count(*)
            INTO l_subst_recs
            FROM gmd_material_effectivities_vw
           WHERE formula_id = get_fmline_rec.formula_id
             AND formulaline_id = get_fmline_rec.formulaline_id;

          IF l_subst_recs <= 1 THEN
            xFormulaDetail_tbl(X_count).item_id := pItem_id;
          END IF;

          IF (pQty IS NOT NULL) THEN
            xFormulaDetail_tbl(X_count).qty := pQty;
          END IF;

          IF (pUom IS NOT NULL) THEN
            xFormulaDetail_tbl(X_count).item_um := pUom;
          END IF;

          IF (pScale_multiple IS NOT NULL) THEN
            xFormulaDetail_tbl(X_count).Scale_multiple := pScale_multiple;
          END IF;

        END IF;
      END IF;

    ELSIF get_fmline_rec.inventory_item_id <> pItem_id THEN

      -- No Substitution exists for this item

      --Check substitution records for the formulaline_id.
      SELECT count(*)
        INTO l_subst_recs
        FROM gmd_material_effectivities_vw
       WHERE formula_id = get_fmline_rec.formula_id
         AND formulaline_id = get_fmline_rec.formulaline_id;

      IF l_subst_recs <= 1 THEN
        xFormulaDetail_tbl(X_count).item_id := pItem_id;
      END IF;

      IF (pQty IS NOT NULL) THEN
        OPEN get_replacement_factor(vFormula_id         => get_fmline_rec.formula_id,
                                    vline_item_id       => get_fmline_rec.inventory_item_id,
                                    vSubstitute_item_id => pItem_id);
        FETCH get_replacement_factor
          INTO l_sub_original_qty, l_sub_replace_qty, l_original_item_uom, l_subst_item_uom, l_replacement_uom_type;
        CLOSE get_replacement_factor;

        IF ((l_sub_original_qty IS NOT NULL) AND (l_sub_original_qty <> 0)) THEN
          l_old_replacement_factor := l_sub_replace_qty /
                                      l_sub_original_qty;
        END IF;
        /* Bug No.8271618  Start */

        IF l_replacement_uom_type <> 1 THEN
          l_uom := l_original_item_uom;
        ELSE
          l_uom := l_subst_item_uom;
        END IF;

        /* Bug No.8271618  - End */
        -- Batch qty in terms of original ingredient qty
        l_batch_scale_factor := inv_convert.inv_um_convert(item_id         => pItem_id,
                                                           lot_number      => NULL,
                                                           organization_id => get_fmline_rec.organization_id,
                                                           precision       => 5,
                                                           from_quantity   => --(pQty /
                                                            l_old_replacement_factor,
                                                           from_unit       => l_uom, --l_original_item_uom,
                                                           to_unit         => get_fmline_rec.detail_uom,
                                                           from_name       => NULL,
                                                           to_name         => NULL);
        -- get_fmline_rec.qty;

        l_batch_scale_factor := l_batch_scale_factor / get_fmline_rec.qty;
        --Step 2 : Find the new qty and its scale multiple
        IF (pQty IS NOT NULL) THEN
          /* xFormulaDetail_tbl(X_count).qty := xFormulaDetail_tbl(X_count)
          .qty * l_batch_scale_factor;*/
          xFormulaDetail_tbl(X_count).qty := pQty / l_batch_scale_factor;

        END IF;
      END IF;
      IF (pUom IS NOT NULL) THEN
        xFormulaDetail_tbl(X_count).item_um := pUom;
      END IF;

      IF (pScale_multiple IS NOT NULL) THEN
        xFormulaDetail_tbl(X_count).Scale_multiple := pScale_multiple;
      END IF;
      /* Bug No.8222282 - End */

      /* Bug No.7460898 - Start (Added the following code based on 11i fixes 6774787 and 7226993  ) */
    ELSE

      -- No Substitution exists for this item

      --Check substitution records for the formulaline_id.
      SELECT count(*)
        INTO l_subst_recs
        FROM gmd_material_effectivities_vw
       WHERE formula_id = get_fmline_rec.formula_id
         AND formulaline_id = get_fmline_rec.formulaline_id;

      IF l_subst_recs <= 1 THEN
        xFormulaDetail_tbl(X_count).item_id := pItem_id;
      END IF;

      IF (pQty IS NOT NULL) THEN
        xFormulaDetail_tbl(X_count).qty := pQty;
      END IF;

      IF (pUom IS NOT NULL) THEN
        xFormulaDetail_tbl(X_count).item_um := pUom;
      END IF;

      IF (pScale_multiple IS NOT NULL) THEN
        xFormulaDetail_tbl(X_count).Scale_multiple := pScale_multiple;
      END IF;

      /* Bug No.7460898 - End */
    END IF; -- when end_date not null

  END get_substitute_line_item;
  -- END BUG 4549316 KSHUKLA

  PROCEDURE Copy_Formula_Substitution_list(pOldFormula_id       NUMBER,
                                           pNewFormula_id       NUMBER,
                                           xReturn_Status       OUT NOCOPY VARCHAR2,
                                           p_create_new_version VARCHAR2 DEFAULT 'N') IS

    -- Bug# 5354649 Kapil M
    -- Bug 5394909  select all except obsoleted substitutions
    CURSOR get_substitution IS
      SELECT fm.*
        FROM gmd_formula_substitution fm
       WHERE formula_id = pOldFormula_id
         AND associated_flag = 'Y'
         AND NOT EXISTS (SELECT 1
                FROM gmd_formula_substitution
               WHERE formula_id = pNewFormula_id)
         AND EXISTS
       (SELECT 1
                FROM gmd_item_substitution_hdr_b subs
               WHERE subs.substitution_id = fm.substitution_id
                 AND (subs.end_date IS NULL OR subs.end_date > SYSDATE)
                 AND (subs.substitution_status between 700 and 799 OR
                     subs.substitution_status between 900 and 999));

    -- Bug 5394532
    CURSOR get_substitution_orgn(c_substitution_id NUMBER) IS
      SELECT owner_organization_id
        FROM gmd_item_substitution_hdr_b im
       WHERE substitution_id = c_substitution_id;

    x_versioning          NUMBER := 0;
    x_new_substitution_id NUMBER;
    X_status              VARCHAR2(10) := 'N';
    x_newformsubs_id      NUMBER;
    l_NewFormula_id       NUMBER;
    -- Bug# 5354649 Kapil M
    x_ret_status VARCHAR2(1);
    -- Bug 5394532
    l_default_subs_status gmd_api_grp.status_rec_type;
    l_orgn_id             NUMBER;
    x_msg_count           NUMBER;
    x_msg_data            VARCHAR2(2000);
  BEGIN
    SAVEPOINT Copy_Formula_Substitution;
    xReturn_Status := 'S';

    -- Bug# 5354649 Kapil M
    -- Handle Item substitution version control
    FOR subs_rec IN get_substitution LOOP
      x_versioning := 0;

      X_status := gmd_common_val.version_control_state('SUBSTITUTION',
                                                       subs_rec.substitution_id);
      IF (X_status = 'Y' OR (X_status = 'O' AND p_create_new_version = 'Y')) THEN
        x_versioning := 1;
      END IF;
      IF x_versioning = 1 THEN
        gmd_version_control.create_substitution(p_substitution_id => subs_rec.substitution_id,
                                                x_substitution_id => x_new_substitution_id);
        -- Bug 5394532
        OPEN get_substitution_orgn(x_new_substitution_id);
        FETCH get_substitution_orgn
          INTO l_orgn_id;
        CLOSE get_substitution_orgn;

        GMD_API_GRP.get_status_details(V_entity_type   => 'SUBSTITUTION',
                                       V_orgn_id       => l_orgn_id,
                                       X_entity_status => l_default_subs_status);

        IF (l_default_subs_status.entity_status <> 100) THEN
          gmd_status_pub.modify_status(p_api_version    => 1,
                                       p_init_msg_list  => TRUE,
                                       p_entity_name    => 'SUBSTITUTION',
                                       p_entity_id      => x_new_substitution_id,
                                       p_entity_no      => NULL,
                                       p_entity_version => NULL,
                                       p_to_status      => l_default_subs_status.entity_status,
                                       p_ignore_flag    => FALSE,
                                       x_message_count  => x_msg_count,
                                       x_message_list   => x_msg_data,
                                       x_return_status  => x_ret_status);
        END IF;
      ELSE
        x_new_substitution_id := subs_rec.substitution_id;
      END IF;
      SELECT gmd_formula_substitution_s.nextval
        INTO x_newformsubs_id
        FROM DUAL;

      -- End of bug# 5354649

      -- Copy all substitution list specific to old formula into
      -- new formula
      INSERT INTO gmd_formula_substitution
        (formula_substitution_id,
         substitution_id,
         formula_id,
         associated_flag,
         created_by,
         creation_date,
         last_updated_by,
         last_update_login,
         last_update_date)
      VALUES
        (x_newformsubs_id,
         x_new_substitution_id,
         pNewFormula_id,
         subs_rec.associated_flag,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.user_id,
         SYSDATE);
      IF (SQL%NOTFOUND) THEN
        xReturn_Status := 'E';
        RAISE no_data_found;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Copy_Formula_Substitution;
      xReturn_Status := 'U';

  END Copy_Formula_Substitution_list;

  FUNCTION get_line_qty(P_line_item_id      in NUMBER,
                        P_organization_id   in NUMBER,
                        P_formula_qty       in NUMBER,
                        P_formula_uom       in VARCHAR2,
                        P_replacement_Item  in NUMBER,
                        P_original_item_qty in NUMBER,
                        P_original_item_uom in VARCHAR2,
                        P_replace_unit_qty  in NUMBER,
                        P_replace_unit_uom  in VARCHAR2,
                        P_replacement_uom   in VARCHAR2) RETURN NUMBER IS
    l_subs_to_original_qty_ratio  NUMBER;
    l_subs_qty_in_replacement_uom NUMBER;
    l_uconv_from_puom_to_fmuom    NUMBER;
  BEGIN
    l_subs_to_original_qty_ratio := (P_replace_unit_qty /
                                    P_original_item_qty);

    l_uconv_from_puom_to_fmuom    := inv_convert.inv_um_convert(item_id         => P_line_item_id,
                                                                lot_number      => NULL,
                                                                organization_id => P_organization_id,
                                                                precision       => 5,
                                                                from_quantity   => P_formula_qty,
                                                                from_unit       => P_formula_uom,
                                                                to_unit         => P_formula_uom,
                                                                from_name       => NULL,
                                                                to_name         => NULL);
    l_subs_qty_in_replacement_uom := l_uconv_from_puom_to_fmuom *
                                     l_subs_to_original_qty_ratio;

    IF (P_original_item_uom = P_replacement_uom) THEN
      RETURN inv_convert.inv_um_convert(item_id         => P_replacement_Item,
                                        lot_number      => NULL,
                                        organization_id => P_organization_id,
                                        precision       => 5,
                                        from_quantity   => l_subs_qty_in_replacement_uom,
                                        from_unit       => P_replace_unit_uom,
                                        to_unit         => P_formula_uom,
                                        from_name       => NULL,
                                        to_name         => NULL);
    ELSE
      RETURN l_subs_qty_in_replacement_uom;
    END IF; -- end if (l_primary_uom != get_item_subs_rec.item_uom)
  END get_line_qty;

  PROCEDURE check_rework_type(pType_value IN VARCHAR2,
                              xReturn     IN OUT NOCOPY VARCHAR2) IS
    iret NUMBER;
    check_type_exception EXCEPTION;
  BEGIN
    /* Use the function type_val to validate the */
    /* field type. Checks if it exists in GEM_LOOKUPS */
    iret := GMDFMVAL_PUB.type_val('REWORK_TYPE', pType_value);

    If (iret <> 0) THEN
      xReturn := 'E';
      RAISE check_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

  EXCEPTION
    when check_type_exception then
      If (p_called_from_forms = 'YES') then
        fnd_message.set_name('GMD', 'FM_INVALID_REWORK_TYPE');
        APP_EXCEPTION.RAISE_EXCEPTION;
      Else
        xReturn := 'E';
      END IF;
  END check_rework_type;

  /*  *******************************************************
  Wrapper for all validation functionality of formula
  insert detail record.
  ****************************************************** */

  PROCEDURE validate_insert_record(P_formula_dtl IN GMD_FORMULA_COMMON_PUB.formula_insert_rec_type,
                                   X_formula_dtl OUT NOCOPY GMD_FORMULA_COMMON_PUB.formula_insert_rec_type,
                                   xReturn       OUT NOCOPY VARCHAR2) IS
    --Cursor Declaration
    CURSOR Cur_get_revision(Vitem_id NUMBER, Vorgn_id NUMBER) IS
      SELECT revision_qty_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = Vitem_id
         AND organization_id = Vorgn_id;
    -- Bug 5350197 Added
    CURSOR Cur_get_serial_control(Vitem_id NUMBER, Vorgn_id NUMBER) IS
      SELECT serial_number_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = Vitem_id
         AND organization_id = Vorgn_id;

    CURSOR Cur_check_revision(Vitem_id NUMBER, Vorgn_id NUMBER, V_revision VARCHAR2) IS
      SELECT 1
        FROM mtl_item_revisions
       WHERE inventory_item_id = Vitem_id
         AND organization_id = Vorgn_id
         AND revision = V_revision;
    --Variable declaration
    l_ret            NUMBER;
    lItem_id         NUMBER;
    l_temp           NUMBER;
    l_revision       NUMBER;
    lItem_um         mtl_system_items.primary_uom_code%type;
    l_serial_control NUMBER; -- Bug 5350197

    --Exceptions
    check_buffer_ind_exception EXCEPTION;
    check_line_no_exception EXCEPTION;
    check_qty_exception EXCEPTION;
    check_cost_alloc_exception EXCEPTION;
    Inv_line_type EXCEPTION;
    Inv_Byprod_Type EXCEPTION;
    check_type_exception EXCEPTION;
    check_rel_type_exception EXCEPTION;
    check_line_type_exception EXCEPTION;
    check_scale_type_exception EXCEPTION;
    check_item_um_exception EXCEPTION;
    check_revision_exception EXCEPTION;
    no_org_access EXCEPTION;
    check_no_revision_exception EXCEPTION;
    check_serial_exception EXCEPTION; -- Bug 5350197

  BEGIN
    X_formula_dtl := P_formula_dtl;
    -- Organization accessiblity check
    if gmd_api_grp.OrgnAccessible(X_formula_dtl.owner_organization_id) = TRUE then
      xReturn := 'S';
    ELSE
      xReturn := 'E';
      RAISE no_org_access;
    END IF;
    --Buffer_ind validation
    IF (X_formula_dtl.line_type = -1) THEN
      IF (NVL(X_formula_dtl.buffer_ind, 0) in (1, 0)) THEN
        xReturn := 'S';
      ELSE
        xReturn := 'E';
        RAISE check_buffer_ind_exception;
      END IF;
    END IF;

    --Line no validation
    IF (X_formula_dtl.line_no IS NULL) THEN
      xReturn := 'E';
      RAISE check_line_no_exception;
    ELSIF (X_formula_dtl.line_no <= 0) THEN
      xReturn := 'E';
      RAISE check_line_no_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Qty Validation
    IF (to_number(X_formula_dtl.qty) < 0) THEN
      xReturn := 'E';
      RAISE check_qty_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Cost Alloc check
    IF (X_formula_dtl.line_type = 1) THEN
      IF (X_formula_dtl.cost_alloc < 0 OR X_formula_dtl.cost_alloc > 100) THEN
        xReturn := 'E';
        RAISE check_cost_alloc_exception;
      ELSE
        xReturn := 'S';
      END IF;
    ELSE
      X_formula_dtl.cost_alloc := NULL;
    END IF;

    --By product type validation
    IF (X_formula_dtl.line_type = 2) THEN
      Xreturn := FND_API.g_ret_sts_success;
      IF X_formula_dtl.by_product_type IS NOT NULL THEN
        --The value for by_product_type is only applicable for byproducts
        IF (X_formula_dtl.line_type <> 2) THEN
          RAISE inv_line_type;
        ELSE
          l_ret := GMDFMVAL_PUB.type_val(ptype_name => 'GMD_BY_PRODUCT_TYPE',
                                         Pvalue     => X_formula_dtl.by_product_type);
          IF l_ret <> 0 THEN
            RAISE Inv_Byprod_Type;
          ELSE
            IF (X_formula_dtl.by_product_type = 'S') THEN
              X_formula_dtl.release_type := 1;
            END IF;
          END IF;
        END IF;
      END IF;
    ELSE
      X_formula_dtl.by_product_type := NULL;
    END IF;

    --Phantom_type validation
    l_ret := GMDFMVAL_PUB.type_val('PHANTOM_TYPE',
                                   X_formula_dtl.phantom_type);

    IF (l_ret <> 0) THEN
      xReturn := 'E';
      RAISE check_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Line Type validation
    IF (X_formula_dtl.line_type IS NULL) THEN
      xReturn := 'E';
      RAISE check_line_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    IF (xReturn = 'S') then
      l_ret := GMDFMVAL_PUB.type_val('LINE_TYPE', X_formula_dtl.line_type);
      IF (l_ret < 0) then
        xReturn := 'E';
        RAISE check_line_type_exception;
      ELSE
        xReturn := 'S';
      END IF;
    END IF;

    --Release Type validation
    l_ret := GMDFMVAL_PUB.type_val('RELEASE_TYPE',
                                   X_formula_dtl.release_type);

    IF (l_ret <> 0) THEN
      xReturn := 'E';
      RAISE check_rel_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Scale Type validation
    l_ret := GMDFMVAL_PUB.type_val('SCALE_TYPE',
                                   X_formula_dtl.scale_type_dtl);

    IF (l_ret <> 0) THEN
      xReturn := 'E';
      RAise check_scale_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Item Uom Validation
    IF (X_formula_dtl.inventory_item_id IS NOT NULL) then
      --Based on the item_id get its primary UOM
      GMDFMVAL_PUB.get_item_id(pitem_no           => X_formula_dtl.Item_no,
                               pinventory_item_id => X_formula_dtl.inventory_item_id,
                               porganization_id   => X_formula_dtl.owner_organization_id,
                               xitem_id           => lItem_id,
                               xitem_um           => lItem_um,
                               xreturn_code       => l_ret);

      /* Inavlid item used */
      IF (X_formula_dtl.detail_uom IS NOT NULL) THEN
        IF (l_ret < 0) THEN
          xReturn := 'E';
        END IF;

        --Based on item_id, primary UOM,formula item UOM check if it can be converted.
        l_ret := INV_CONVERT.inv_um_convert(item_id       => litem_id,
                                            precision     => 5,
                                            from_quantity => 100,
                                            from_unit     => X_formula_dtl.detail_uom,
                                            to_unit       => lItem_um,
                                            from_name     => NULL,
                                            to_name       => NULL);
        IF (l_ret < 0) THEN
          xReturn := 'E';
          Raise check_item_um_exception;
        ELSE
          xReturn := 'S';
        END IF;
      ELSE
        X_formula_dtl.detail_uom := litem_um;
      END IF;
    END IF;

    --Revision Validation
    IF (X_formula_dtl.inventory_item_id IS NOT NULL) then
      -- bug 5350197 Serail control items are not allowed
      OPEN Cur_get_serial_control(X_formula_dtl.inventory_item_id,
                                  X_formula_dtl.owner_organization_id);
      FETCH Cur_get_serial_control
        INTO l_serial_control;
      CLOSE Cur_get_serial_control;
      IF l_serial_control <> 1 THEN
        RAISE check_serial_exception;
      END IF;

      OPEN Cur_get_revision(X_formula_dtl.inventory_item_id,
                            X_formula_dtl.owner_organization_id);
      FETCH Cur_get_revision
        INTO l_revision;
      CLOSE Cur_get_revision;
      IF (l_revision = 2 AND X_formula_dtl.revision IS NOT NULL) THEN
        OPEN Cur_check_revision(X_formula_dtl.inventory_item_id,
                                X_formula_dtl.owner_organization_id,
                                X_formula_dtl.revision);
        FETCH Cur_check_revision
          INTO l_temp;
        IF (Cur_check_revision%NOTFOUND) THEN
          xReturn := 'E';
          RAISE check_revision_exception;
          CLOSE Cur_check_revision;
        END IF;
      ELSIF (l_revision <> 2 AND X_formula_dtl.revision IS NOT NULL) THEN
        xReturn := 'E';
        RAISE check_no_revision_exception;
        CLOSE Cur_check_revision;
      ELSE
        X_formula_dtl.revision := NULL;
      END IF;
    END IF;

  EXCEPTION
    when check_buffer_ind_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_BUFFER_IND');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_line_no_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_LINE_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_qty_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_QTY');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_cost_alloc_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_COST_ALLOC');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when inv_line_type THEN
      Xreturn := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_LINE_BYPROD_TYP');
      FND_MSG_PUB.ADD;
    when inv_byprod_type THEN
      Xreturn := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_BYPROD_TYPE');
      FND_MSG_PUB.ADD;

    when check_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_PHANTOM_TYPE');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_line_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_LINE_TYPE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_rel_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_RELEASE_TYPE');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_scale_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_SCALE_TYPE');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_item_um_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_SCALE_BAD_ITEM_UOM');
      FND_MESSAGE.SET_TOKEN('FROM_UOM', X_formula_dtl.detail_uom);
      FND_MESSAGE.SET_TOKEN('TO_UOM', litem_um);
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MSG_PUB.ADD;

    when check_revision_exception then
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_REVISION');
      FND_MSG_PUB.ADD;
      -- Bug 5350197
    when check_serial_exception then
      Xreturn := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_SERIAL_NOT_ALLOWED');
      FND_MSG_PUB.ADD;

    when check_no_revision_exception then
      FND_MESSAGE.SET_NAME('GMD', 'GMD_SPEC_NOT_REVISION_CTRL');
      FND_MSG_PUB.ADD;

    when no_org_access then
      null;

  END validate_insert_record;

  /*  *******************************************************
  Wrapper for all validation functionality of formula
  update detail record.
  ****************************************************** */

  PROCEDURE validate_update_record(P_formula_dtl IN GMD_FORMULA_COMMON_PUB.formula_update_rec_type,
                                   X_formula_dtl OUT NOCOPY GMD_FORMULA_COMMON_PUB.formula_update_rec_type,
                                   xReturn       OUT NOCOPY VARCHAR2) IS
    --Cursor Declaration
    CURSOR Cur_get_revision(Vitem_id NUMBER, Vorgn_id NUMBER) IS
      SELECT revision_qty_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = Vitem_id
         AND organization_id = Vorgn_id;
    CURSOR Cur_check_revision(Vitem_id NUMBER, Vorgn_id NUMBER, V_revision VARCHAR2) IS
      SELECT 1
        FROM mtl_item_revisions
       WHERE inventory_item_id = Vitem_id
         AND organization_id = Vorgn_id
         AND revision = V_revision;
    --Variable declaration
    l_ret      NUMBER;
    lItem_id   NUMBER;
    l_temp     NUMBER;
    l_revision NUMBER;
    lItem_um   mtl_system_items.primary_uom_code%type;
    --Exceptions
    check_buffer_ind_exception EXCEPTION;
    check_line_no_exception EXCEPTION;
    check_qty_exception EXCEPTION;
    check_cost_alloc_exception EXCEPTION;
    Inv_line_type EXCEPTION;
    Inv_Byprod_Type EXCEPTION;
    check_type_exception EXCEPTION;
    check_rel_type_exception EXCEPTION;
    check_line_type_exception EXCEPTION;
    check_scale_type_exception EXCEPTION;
    check_item_um_exception EXCEPTION;
    check_revision_exception EXCEPTION;
    no_org_access EXCEPTION;
    check_no_revision_exception EXCEPTION;
    -- Added the exception when item is not revision controlled

  BEGIN
    X_formula_dtl := P_formula_dtl;
    -- Organization accessiblity check
    if gmd_api_grp.OrgnAccessible(X_formula_dtl.owner_organization_id) = TRUE then
      xReturn := 'S';
    ELSE
      xReturn := 'E';
      RAISE no_org_access;
    END IF;
    --Buffer_ind validation
    IF (X_formula_dtl.line_type = -1) THEN
      IF (NVL(X_formula_dtl.buffer_ind, 0) in (1, 0)) THEN
        xReturn := 'S';
      ELSE
        xReturn := 'E';
        RAISE check_buffer_ind_exception;
      END IF;
    END IF;

    --Qty Validation
    IF (to_number(X_formula_dtl.qty) < 0) THEN
      xReturn := 'E';
      RAISE check_qty_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Cost Alloc check
    IF (X_formula_dtl.line_type = 1) THEN
      IF (X_formula_dtl.cost_alloc < 0 OR X_formula_dtl.cost_alloc > 100) THEN
        xReturn := 'E';
        RAISE check_cost_alloc_exception;
      ELSE
        xReturn := 'S';
      END IF;
    ELSE
      X_formula_dtl.cost_alloc := NULL;
    END IF;

    --By product type validation
    IF (X_formula_dtl.line_type = 2) THEN
      Xreturn := FND_API.g_ret_sts_success;
      IF X_formula_dtl.by_product_type IS NOT NULL THEN
        --The value for by_product_type is only applicable for byproducts
        IF (X_formula_dtl.line_type <> 2) THEN
          RAISE inv_line_type;
        ELSE
          l_ret := GMDFMVAL_PUB.type_val(ptype_name => 'GMD_BY_PRODUCT_TYPE',
                                         Pvalue     => X_formula_dtl.by_product_type);
          IF l_ret <> 0 THEN
            RAISE Inv_Byprod_Type;
          ELSE
            IF (X_formula_dtl.by_product_type = 'S') THEN
              X_formula_dtl.release_type := 1;
            END IF;
          END IF;
        END IF;
      END IF;
    ELSE
      X_formula_dtl.by_product_type := NULL;
    END IF;

    --Phantom_type validation
    l_ret := GMDFMVAL_PUB.type_val('PHANTOM_TYPE',
                                   X_formula_dtl.phantom_type);

    IF (l_ret <> 0) THEN
      xReturn := 'E';
      RAISE check_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Release Type validation
    l_ret := GMDFMVAL_PUB.type_val('RELEASE_TYPE',
                                   X_formula_dtl.release_type);

    IF (l_ret <> 0) THEN
      xReturn := 'E';
      RAISE check_rel_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Scale Type validation
    l_ret := GMDFMVAL_PUB.type_val('SCALE_TYPE',
                                   X_formula_dtl.scale_type_dtl);

    IF (l_ret <> 0) THEN
      xReturn := 'E';
      RAise check_scale_type_exception;
    ELSE
      xReturn := 'S';
    END IF;

    --Item Uom Validation
    --Based on the item_id get its primary UOM
    GMDFMVAL_PUB.get_item_id(pitem_no           => X_formula_dtl.Item_no,
                             pinventory_item_id => X_formula_dtl.inventory_item_id,
                             porganization_id   => X_formula_dtl.owner_organization_id,
                             xitem_id           => lItem_id,
                             xitem_um           => lItem_um,
                             xreturn_code       => l_ret);

    /* Inavlid item used */
    IF (X_formula_dtl.detail_uom IS NOT NULL) THEN
      IF (l_ret < 0) THEN
        xReturn := 'E';
      END IF;

      --Based on item_id, primary UOM,formula item UOM check if it can be converted.
      l_ret := INV_CONVERT.inv_um_convert(item_id       => litem_id,
                                          precision     => 5,
                                          from_quantity => 100,
                                          from_unit     => X_formula_dtl.detail_uom,
                                          to_unit       => lItem_um,
                                          from_name     => NULL,
                                          to_name       => NULL);
      IF (l_ret < 0) THEN
        xReturn := 'E';
        Raise check_item_um_exception;
      ELSE
        xReturn := 'S';
      END IF;
    ELSE
      X_formula_dtl.detail_uom := litem_um;
    END IF;

    --Revision Validation
    OPEN Cur_get_revision(X_formula_dtl.inventory_item_id,
                          X_formula_dtl.owner_organization_id);
    FETCH Cur_get_revision
      INTO l_revision;
    CLOSE Cur_get_revision;
    IF (l_revision = 2 AND X_formula_dtl.revision IS NOT NULL) THEN
      OPEN Cur_check_revision(X_formula_dtl.inventory_item_id,
                              X_formula_dtl.owner_organization_id,
                              X_formula_dtl.revision);
      FETCH Cur_check_revision
        INTO l_temp;
      IF (Cur_check_revision%NOTFOUND) THEN
        xReturn := 'E';
        RAISE check_revision_exception;
        CLOSE Cur_check_revision;
      END IF;
      -- Bug # 4603056 Kapil M
      -- Added the check if the Item is revision controlled and display message if not.
    ELSIF (l_revision <> 2 AND X_formula_dtl.revision IS NOT NULL) THEN
      xReturn := 'E';
      RAISE check_no_revision_exception;
      CLOSE Cur_check_revision;
    END IF;

  EXCEPTION
    when check_buffer_ind_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_BUFFER_IND');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_line_no_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_LINE_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_qty_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_QTY');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_cost_alloc_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_COST_ALLOC');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when inv_line_type THEN
      Xreturn := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_LINE_BYPROD_TYP');
      FND_MSG_PUB.ADD;
    when inv_byprod_type THEN
      Xreturn := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_BYPROD_TYPE');
      FND_MSG_PUB.ADD;

    when check_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_PHANTOM_TYPE');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_line_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_LINE_TYPE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_rel_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_RELEASE_TYPE');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_scale_type_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVALID_SCALE_TYPE');
      FND_MESSAGE.SET_TOKEN('FORMULA_NO', X_formula_dtl.formula_no);
      FND_MESSAGE.SET_TOKEN('FORMULA_VERS', X_formula_dtl.formula_vers);
      FND_MSG_PUB.ADD;

    when check_item_um_exception then
      FND_MESSAGE.SET_NAME('GMD', 'FM_SCALE_BAD_ITEM_UOM');
      FND_MESSAGE.SET_TOKEN('FROM_UOM', X_formula_dtl.detail_uom);
      FND_MESSAGE.SET_TOKEN('TO_UOM', litem_um);
      FND_MESSAGE.SET_TOKEN('ITEM_NO', X_formula_dtl.item_no);
      FND_MSG_PUB.ADD;

    when check_revision_exception then
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_REVISION');
      FND_MSG_PUB.ADD;

    when check_no_revision_exception then
      FND_MESSAGE.SET_NAME('GMD', 'GMD_SPEC_NOT_REVISION_CTRL');
      FND_MSG_PUB.ADD;

    when no_org_access then
      null;

  END validate_update_record;

  FUNCTION check_expr_items(V_formula_id IN NUMBER) RETURN BOOLEAN IS
    ------------------------------------------------------------------
    --Created by  : Sriram.S
    --Date created: 20-JAN-2004
    --
    --Purpose: Function returns TRUE formula has experied item(s) otherwise
    --         returns FALSE.
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --srsriran    20-FEB-2004     Created w.r.t. bug 3408799
    -------------------------------------------------------------------
    --Cursor fetches 1 if context formula has experied item(s)
    CURSOR cur_check_expr(p_org_id NUMBER) IS
      SELECT 1
        FROM SYS.DUAL
       WHERE EXISTS (SELECT 1
                FROM fm_matl_dtl d, mtl_system_items_b i
               WHERE recipe_enabled_flag = 'Y'
                 AND i.ORGANIZATION_ID = p_org_id
                 AND d.formula_id = V_formula_id
                 AND i.inventory_item_id = d.inventory_item_id
                 AND i.eng_item_flag = 'Y');
    l_orgid NUMBER;
    l_temp  NUMBER;
  BEGIN
    IF (V_formula_id IS NOT NULL) THEN
      -- KSHUKLA added as per as performance bug 4917329
      -- Find out the formula owner organization and narrow down the query
      -- perf
      select owner_organization_id
        into l_orgid
        from fm_form_mst
       where formula_id = V_formula_id;
      -- Cursor Call need to change inorder to take into account
      -- the formula owner org id

      OPEN cur_check_expr(l_orgid);
      FETCH Cur_check_expr
        INTO l_temp;
      IF (cur_check_expr%FOUND) THEN
        CLOSE Cur_check_expr;
        RETURN TRUE;
      ELSE
        CLOSE cur_check_expr;
      END IF; -- IF (Cur_check_expr%FOUND) THEN
    END IF; -- IF (V_formula_id IS NOT NULL) THEN
    RETURN FALSE;
  END check_expr_items;

  FUNCTION output_qty_zero(V_formula_id IN NUMBER) RETURN BOOLEAN IS
    ------------------------------------------------------------------
    --Created by  : Sriram.S
    --Date created: 20-JAN-2004
    --
    --Purpose: Function returns TRUE if sum of out quantity is zero otherwise
    --         returns FALSE.
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --srsriran    20-FEB-2004     Bug 3408799
    -------------------------------------------------------------------
    --Cursor returns the sum of total quantity of a formaula
    CURSOR cur_check_total_output IS
      SELECT SUM(qty)
        FROM fm_matl_dtl
       WHERE formula_id = V_formula_id
         AND line_type > 0;

    l_total_output NUMBER;
  BEGIN
    IF (V_formula_id IS NOT NULL) THEN
      OPEN cur_check_total_output;
      FETCH cur_check_total_output
        INTO l_total_output;
      CLOSE cur_check_total_output;
      IF l_total_output = 0 THEN
        RETURN TRUE;
      END IF; --IF X_total_output = 0 THEN
    END IF; --IF (V_formula_id IS NOT NULL) THEN
    RETURN FALSE;
  END output_qty_zero;

  FUNCTION inactive_items(V_formula_id IN NUMBER) RETURN BOOLEAN IS
    ------------------------------------------------------------------
    --Created by  : Sriram.S
    --Date created: 20-JAN-2004
    --
    --Purpose: Function returns TRUE formula has inactive item(s) otherwise
    --         returns FALSE.
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --srsriran    20-FEB-2004     Bug 3408799
    --Kapil M     06-MAR-2006     Bug 5040915 Changed the query by adding the condition on organization_id
    -------------------------------------------------------------------
    --Cursor fetches 1 if context formula has experied item(s)
    CURSOR cur_check_inactive IS
      SELECT 1
        FROM SYS.DUAL
       WHERE EXISTS (SELECT 1
                FROM fm_matl_dtl d, mtl_system_items_b i
               WHERE d.formula_id = V_formula_id
                 AND i.inventory_item_id = d.inventory_item_id
                 AND i.recipe_enabled_flag = 'N'
                 AND i.organization_id = d.organization_id); -- Bug # 5040915 Kapil M
    X_temp NUMBER;
  BEGIN
    IF (V_formula_id IS NOT NULL) THEN
      OPEN Cur_check_inactive;
      FETCH Cur_check_inactive
        INTO X_temp;
      IF (Cur_check_inactive%FOUND) THEN
        CLOSE Cur_check_inactive;
        RETURN TRUE;
      ELSE
        CLOSE Cur_check_inactive;
      END IF; -- IF (Cur_check_inactive%FOUND) THEN
    END IF; -- IF (V_formula_id IS NOT NULL) THEN
    RETURN FALSE;
  END inactive_items;
END GMDFMVAL_PUB;

/
