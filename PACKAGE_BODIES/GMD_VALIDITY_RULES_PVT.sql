--------------------------------------------------------
--  DDL for Package Body GMD_VALIDITY_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_VALIDITY_RULES_PVT" AS
/* $Header: GMDVRVRB.pls 120.2.12010000.2 2008/11/12 18:10:31 rnalla ship $ */


--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

  /*#####################################################
  # NAME
  #    Determine_Product
  # SYNOPSIS
  #    Proc Determine_Product
  # DESCRIPTION
  #    This procedure validates if the item that is being modified
  #    is a valid product or a co-product
  # HISTORY
  #####################################################*/
  FUNCTION Determine_Product(pRecipe_id NUMBER, pItem_id NUMBER) RETURN BOOLEAN IS
    CURSOR product_cur(vRecipe_id NUMBER, vItem_id NUMBER) IS
      Select 1 from fm_matl_dtl fm
      Where exists (Select 1
                    From   gmd_recipes_b rc
                    Where  fm.formula_id = rc.formula_id
                    And    fm.line_type IN (1,2)
                    And    fm.inventory_item_id = vItem_id -- NPD Conv.
                    And    rc.recipe_id = vRecipe_id);
    l_count NUMBER;
  BEGIN

    OPEN  product_cur(pRecipe_id, pItem_id);
    FETCH product_cur INTO l_count;
      IF (product_cur%NOTFOUND) THEN
        CLOSE product_cur;
        Return FALSE;
      END IF;
    CLOSE product_cur;

    Return TRUE;
  END;

  /*#####################################################
  # NAME
  #    validate_start_date
  # SYNOPSIS
  #    Proc validate_start_date
  # DESCRIPTION
  #    This procedure validates that start date is no earlier
  #    than any routing start date.
  # HISTORY
  #####################################################*/
  PROCEDURE validate_start_date (P_disp_start_date  Date,
                                 P_routing_start_date Date,
                                 x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'validate_start_date' ;
  BEGIN
    x_return_status := 'S';

    IF P_disp_start_date < P_routing_start_date THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_VALIDITY_DATE_IN_ROUT_DATE');
       FND_MSG_PUB.ADD;
       x_return_status := 'E';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END  validate_start_date;

  /*#####################################################
  # NAME
  #    validate_end_date
  # SYNOPSIS
  #    Proc validate_end_date
  # DESCRIPTION
  #    This procedure validates that end date is no later
  #    than any routing end date.
  #    Also validates date entered against sys max date.
  # HISTORY
  #####################################################*/
  PROCEDURE validate_end_date (P_end_date  Date,
                               P_routing_end_date Date,
                               x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'validate_end_date' ;
  BEGIN
    x_return_status := 'S';
    IF (P_end_date IS NOT NULL) AND
       (P_routing_end_date IS NOT NULL) AND
       (P_end_date > P_routing_end_date) THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_VALIDITY_DATE_IN_ROUT_DATE');
       FND_MSG_PUB.ADD;
       x_return_status := 'E';
    END IF;

    -- Routing end date is finite but Vr end date is infinite
    IF (P_routing_end_date IS NOT NULL) AND
       (P_end_date IS NULL) THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_VALIDITY_DATE_IN_ROUT_DATE');
       FND_MSG_PUB.ADD;
       x_return_status := 'E';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END  validate_end_date;


  /*#####################################################
  # NAME
  #    effective_dates
  # SYNOPSIS
  #    Proc effective_dates
  # DESCRIPTION
  #    Validates dates to be within proper ranges.
  # HISTORY
  #####################################################*/
  PROCEDURE effective_dates ( P_start_date DATE,
                              P_end_date DATE,
                              x_return_status OUT NOCOPY VARCHAR2)   IS
    l_api_name  VARCHAR2(100) := 'effective_dates' ;
  BEGIN
    x_return_status := 'S';

    IF (P_end_date IS NOT NULL AND P_start_date IS NOT NULL) THEN
      IF (P_end_date < P_start_date) THEN
        FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
        FND_MSG_PUB.ADD;
        x_return_status := 'E';
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END effective_dates;

/*###################################################################
  # NAME
  #    std_qty
  # SYNOPSIS
  #    proc std_qty
  #    Called from when-val-record trigger
  # DESCRIPTION
  #    Checks for std_qty is in between min_qty and max_qty
  #    Std qty cannot be negative
  #
  ###################################################################*/
  PROCEDURE std_qty(P_std_qty NUMBER,
                    P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'std_qty' ;
  BEGIN
    x_return_status := 'S';
    IF P_std_qty IS NOT NULL THEN
      IF (P_std_qty < P_min_qty
          OR P_std_qty > P_max_qty)
          OR P_std_qty <= 0  THEN
        IF P_std_qty <= 0  THEN
          FND_MESSAGE.SET_NAME('GMD','FM_INV_STD_QTY');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        ELSE
          FND_MESSAGE.SET_NAME('GMD','FM_INV_STD_RANGE');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        END IF;  -- end if std qty is the problem, or the range
      END IF;    -- end if std qty not within range
    END IF;      -- end if std qty is not null
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END std_qty;

  /*#####################################################
  # NAME
  #    max_qty
  # SYNOPSIS
  #    proc max_qty
  #    Called from when-val-record trigger
  # DESCRIPTION
  #    Checks for max_qty is greater than min_qty
  #
  #######################################################*/
  PROCEDURE max_qty(P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name  VARCHAR2(100) := 'max_qty' ;
  BEGIN
    x_return_status := 'S';
    IF P_max_qty IS NOT NULL THEN
      IF (P_max_qty < P_min_qty
           OR P_min_qty < 0) THEN
        IF P_min_qty < 0  THEN
          FND_MESSAGE.SET_NAME('GMD','FM_INV_MIN_QTY');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        ELSE
          FND_MESSAGE.SET_NAME('GMD','FM_INV_MIN_MAX');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
        END IF;       -- end if qty is the problem, or the range
      END IF;         -- IF (P_max_qty < P_min_qty
    END IF;           -- IF P_max_qty IS NOT NULL
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END max_qty;


  /*#####################################################
  # NAME
  #    calc_inv_qtys
  # SYNOPSIS
  #    proc calc_inv_qtys
  #    Parms
  # DESCRIPTION
  #    Checks for item_uom with standard item UOM, if different
  #    Converts the quantity from the initial UOM to the
  #    final UOM.
  #######################################################*/
  PROCEDURE calc_inv_qtys (P_inv_item_um VARCHAR2,
                           P_item_um     VARCHAR2,
                           P_item_id     NUMBER,
                           P_min_qty     NUMBER,
                           P_max_qty     NUMBER,
                           X_inv_min_qty OUT NOCOPY NUMBER,
                           X_inv_max_qty OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2
                           ) IS
    l_api_name  VARCHAR2(100) := 'calc_inv_qtys' ;
  BEGIN
    x_return_status := 'S';

    IF P_inv_item_um = P_item_um THEN
      X_inv_min_qty := P_min_qty;
      X_inv_max_qty := P_max_qty;
    ELSE

     /*########################################################
       # Stored Procedure call made here for the UOM conversion
       # between two different UOM's
       #########################################################*/


      /* NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion */

      X_inv_min_qty := INV_CONVERT.inv_um_convert( item_id       => P_item_id    ,
                                                   precision	 => 5            ,
                                                   from_quantity => P_min_qty    ,
                                                   from_unit     => P_item_um    ,
                                                   to_unit       => P_inv_item_um,
                                                   from_name	 => NULL         ,
                                                   to_name	 => NULL);



      X_inv_max_qty := INV_CONVERT.inv_um_convert( item_id       => P_item_id    ,
                                                   precision	 => 5            ,
                                                   from_quantity => P_max_qty    ,
                                                   from_unit     => P_item_um    ,
                                                   to_unit       => P_inv_item_um,
                                                   from_name	 => NULL         ,
                                                   to_name	 => NULL);


    END IF;
    X_inv_min_qty := ROUND(X_inv_min_qty,5);  --NPD Conv. Round upto 5 digits
    X_inv_max_qty := ROUND(X_inv_max_qty,5);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END calc_inv_qtys;

  /*#####################################################
  # NAME
  #    calculate_process_loss
  # SYNOPSIS
  #    Proc calculate_process_loss
  # DESCRIPTION
  #    derives theoretical and planned process loss
  #####################################################*/
  PROCEDURE calculate_process_loss( V_assign 	IN	NUMBER DEFAULT 1
                                   ,P_vr_id   IN  NUMBER
                                   ,X_TPL      OUT NOCOPY NUMBER
                                   ,X_PPL      OUT NOCOPY NUMBER
                                   ,x_return_status OUT NOCOPY VARCHAR2) IS

    process_loss_rec    GMD_COMMON_VAL.process_loss_rec;
    l_process_loss      GMD_PROCESS_LOSS.process_loss%TYPE;
    l_recipe_theo_loss  GMD_PROCESS_LOSS.process_loss%TYPE;
    x_msg_cnt           NUMBER;
    x_msg_dat           VARCHAR2(2000);

    l_std_qty           gmd_recipe_validity_rules.std_qty%TYPE;
    l_detail_uom        gmd_recipe_validity_rules.detail_uom%TYPE;
    l_item_id           gmd_recipe_validity_rules.inventory_item_id%TYPE;
    l_orgn_code         gmd_recipe_validity_rules.orgn_code%TYPE;

    CURSOR get_other_vr_details(V_vr_id NUMBER) IS
      SELECT std_qty, inventory_item_id, detail_uom, orgn_code
      FROM   gmd_recipe_validity_rules
      WHERE  recipe_validity_rule_id = V_vr_id;

    l_api_name  VARCHAR2(100) := 'calculate_process_loss' ;

  BEGIN
    x_return_status := 'S';

    OPEN  get_other_vr_details(p_vr_id);
    FETCH get_other_vr_details INTO l_std_qty, l_item_id, l_detail_uom, l_orgn_code;
    CLOSE get_other_vr_details;

    process_loss_rec.validity_rule_id := p_vr_id;
    process_loss_rec.qty := l_std_qty;
    process_loss_rec.uom := l_detail_uom;
    process_loss_rec.orgn_code := l_orgn_code;
    process_loss_rec.item_id := l_item_id;

    gmd_common_val.calculate_process_loss(process_loss       => process_loss_rec,
					  Entity_type        => 'VALIDITY',
					  x_recipe_theo_loss => X_TPL,
                                          x_process_loss     => X_PPL,
                                          x_return_status    => x_return_status,
                                          x_msg_count        => X_msg_cnt,
                                          x_msg_data         => X_msg_dat);

    X_TPL := TRUNC(X_TPL,2);
    X_PPL := TRUNC(X_PPL,2);

    IF (V_assign = 1) THEN
      IF X_PPL IS NULL THEN
        X_PPL := X_TPL;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END calculate_process_loss;

  /*#####################################################
  # NAME
  #    check_for_duplicate
  # SYNOPSIS
  #    Proc check_for_duplicate
  #    Parms
  # DESCRIPTION
  #    check duplication of record
  #
  # Bug 4134275 18-NOV-2005 Added one more parameter p_recipe_validity_rule_id
  #                         This is used as the duplicate check should check that the updated record is not going
  #                         to create a duplicate record, i.e. the same details should not match any
  #                         other record(corresponding to p_recipe_validity_rule_id other than this one)
  #####################################################*/
  PROCEDURE check_for_duplicate(p_recipe_validity_rule_id NUMBER        -- 4134275 Added the validity_rule_id condition for duplicate check
                               ,pRecipe_id NUMBER
                               ,pitem_id NUMBER
                               ,pOrgn_code VARCHAR2 DEFAULT NULL
                               -- NPD Conv.
                               ,pOrganization_id NUMBER
                               ,pRecipe_Use NUMBER
                               ,pPreference NUMBER
                               ,pstd_qty NUMBER
                               ,pmin_qty NUMBER
                               ,pmax_qty NUMBER
                               ,pinv_max_qty NUMBER
                               ,pinv_min_qty NUMBER
                               ,pitem_um VARCHAR2
                               ,pValidity_Rule_Status  VARCHAR2
                               ,pstart_date DATE
                               ,pend_date DATE DEFAULT NULL
                               ,pPlanned_process_loss NUMBER DEFAULT NULL
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ) IS

 CURSOR Cur_check_dup_upd IS
      SELECT recipe_validity_rule_id
      FROM   gmd_recipe_validity_rules
      WHERE  recipe_id         = pRecipe_id
       AND inventory_item_id       = pitem_id -- NPD Conv.
       AND ((orgn_code   = pOrgn_code)  OR
           (orgn_code IS NULL AND pOrgn_code IS NULL))
       -- NPD Conv.
       AND ((organization_id   = pOrganization_id)  OR
           (organization_id IS NULL AND pOrganization_id IS NULL))
       AND recipe_use    = pRecipe_Use
       AND preference    = pPreference
       AND std_qty       = pstd_qty
       AND min_qty       = pmin_qty
       AND max_qty       = pmax_qty
       AND inv_max_qty   = pinv_max_qty
       AND inv_min_qty   = pinv_min_qty
       AND detail_uom    = pitem_um

       AND validity_rule_status  = pValidity_Rule_status
       AND ((pPlanned_process_loss IS NULL AND Planned_process_loss IS NULL) OR
            (planned_process_loss = pPlanned_process_loss))
       AND start_date = pstart_date
       AND ((end_date  = pend_date)  OR (end_date is NULL and pend_date is NULL))
       AND  recipe_validity_rule_id <> p_recipe_validity_rule_id;

    l_api_name  VARCHAR2(100) := 'check_for_duplicate' ;
  BEGIN
    x_return_status := 'S';
    FOR VR_dup_rec IN Cur_check_dup_upd LOOP
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                        ||': Duplicate VR id  = '||VR_dup_rec.recipe_validity_rule_id);

      END IF;
      FND_MESSAGE.SET_NAME('GMD','GMD_DUP_VR_EXIST');
      FND_MSG_PUB.ADD;
      x_return_status := 'E';
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END check_for_duplicate;


 /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_validity_rules                                         */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* Kapil M 18-NOV-2005   Bug # 4134275                             */
  /*         Changed the call from fnd_date.CHARDATE_TO_DATE to      */
  /*         fnd_date.CANONICAL_TO_DATE
  /* =============================================================== */
  PROCEDURE update_validity_rules
  ( p_validity_rule_id	IN	    gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE
  , p_update_table	IN	    gmd_validity_rules_pvt.update_tbl_type
  , x_message_count 	OUT NOCOPY  NUMBER
  , x_message_list 	OUT NOCOPY  VARCHAR2
  , x_return_status	OUT NOCOPY  VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_VALIDITY_RULES';
  l_db_date               DATE;
  l_inv_item_um           mtl_units_of_measure.uom_code%TYPE; -- NPD Conv.
  l_tpl                   NUMBER;
  l_fixed_scale           NUMBER;

  -- NPD Conv. Added the following local var's
  l_formula_id            NUMBER;
  l_recp_use              NUMBER;

  /* Define record type that hold the routing data */
  l_old_vr_rec              gmd_recipe_validity_rules%ROWTYPE;

  /* Define Exceptions */
  VR_update_failure                EXCEPTION;
  last_update_date_failure         EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  /* Define cursor section */
  CURSOR get_old_vr_rec(vValidity_rule_id
                        gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE)  IS
     Select *
     From   gmd_recipe_validity_rules
     Where  recipe_validity_rule_id = vValidity_rule_id;

  CURSOR Get_db_last_update_date(vValidity_rule_id
                        gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE)  IS
     Select last_update_date
     From   gmd_recipe_validity_rules
     Where  recipe_validity_rule_id = vValidity_rule_id;

  CURSOR Get_Routing_Details(vValidity_rule_id
                        gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE)  IS
    Select rt.Effective_Start_Date,
           rt.Effective_End_Date
    From   gmd_routings_b rt, gmd_recipes_b rc,
           gmd_recipe_validity_rules vr
    Where  vr.recipe_id = rc.recipe_id AND
           rc.routing_id = rt.routing_id AND
           vr.recipe_validity_rule_id = vValidity_rule_id AND
           rt.delete_mark = 0;

   CURSOR check_fmdtl_fixed_scale(vRecipe_id gmd_recipes_b.recipe_id%TYPE
                                 ,vItem_id   ic_item_mst_b.item_id%TYPE)  IS
     SELECT 1
     FROM   sys.dual
     WHERE  EXISTS (Select d.formula_id
                    From  fm_matl_dtl d, gmd_recipes_b r
                    WHERE r.formula_id = d.formula_id AND
                          r.recipe_id  = vRecipe_id AND
                          d.line_type = 1 AND
                          d.inventory_item_id   = vItem_id AND  -- NPD Conv.
                          d.scale_type = 0);

   CURSOR check_fmhdr_fixed_scale(vRecipe_id gmd_recipes_b.recipe_id%TYPE)  IS
     SELECT 1
     FROM   sys.dual
     WHERE  EXISTS (Select h.formula_id
                    From  fm_form_mst h, gmd_recipes_b r
                    WHERE r.formula_id = h.formula_id AND
                          r.recipe_id  = vRecipe_id AND
                          h.scale_type = 0);

   -- Cursor to fetch recipe use and formula id of the VR
   CURSOR get_recp_dets IS
     SELECT r.formula_id, v.recipe_use
     FROM   gmd_recipes_b r, gmd_recipe_validity_rules v
     WHERE  v.recipe_validity_rule_id = p_validity_rule_id
     AND    v.recipe_id = r.recipe_id;

  BEGIN
    /* Intialize the setup fields */

    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;

    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line(m_pkg_name||'.'||l_api_name
      ||' : About to get the db VR record for VR id = '
      ||p_validity_rule_id);
    END IF;

    /* Get the old routing rec value */
    OPEN  get_old_vr_rec(p_validity_rule_id);
    FETCH get_old_vr_rec INTO l_old_vr_rec;
      IF get_old_vr_rec%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_VR_INVALID');
        FND_MSG_PUB.ADD;
        CLOSE get_old_vr_rec;
        RAISE vr_update_failure;
      END IF;
    CLOSE get_old_vr_rec;

    /* Loop thro' every column in p_update_table table and for each column name
       assign or replace the old value with the table value */
    FOR i IN 1 .. p_update_table.count  LOOP

       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||' : The column to be updated = '
                           ||p_update_table(i).p_col_to_update||' and value = '
                           ||p_update_table(i).p_value);
       END IF;

      -- IF (UPPER(p_update_table(i).p_col_to_update) = 'RECIPE_ID') THEN
      --     l_old_vr_rec.RECIPE_ID := p_update_table(i).p_value;
      -- ELSE

       IF (UPPER(p_update_table(i).p_col_to_update) = 'ORGN_CODE') THEN
           l_old_vr_rec.ORGN_CODE := p_update_table(i).p_value;
       -- NPD Conv.
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ORGANIZATION_ID') THEN
	   l_old_vr_rec.ORGANIZATION_ID  := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'INVENTORY_ITEM_ID') THEN
           l_old_vr_rec.INVENTORY_ITEM_ID := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'REVISION') THEN
           l_old_vr_rec.REVISION := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'DETAIL_UOM') THEN
           l_old_vr_rec.DETAIL_UOM := p_update_table(i).p_value;
       -- End NPD Conv.
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'TEXT_CODE') THEN
           l_old_vr_rec.TEXT_CODE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'RECIPE_USE') THEN
           l_old_vr_rec.RECIPE_USE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'PREFERENCE') THEN
           l_old_vr_rec.PREFERENCE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'START_DATE') THEN
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name||
              ' : Before conversion of Start date - '||
              ' CharDT to Date Format ');
           END IF;
           l_old_vr_rec.START_DATE := FND_DATE.canonical_to_date(p_update_table(i).p_value);
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                                 ||' : After conversion of CharDT to Date '||
                                 ' Start Date = '||l_old_vr_rec.START_DATE);
           END IF;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'END_DATE') THEN
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                       ||' : Before conversion of end date - '
                       ||' CharDT to Date Format '||p_update_table(i).p_value);
           END IF;
           l_old_vr_rec.END_DATE := FND_DATE.canonical_to_date(p_update_table(i).p_value);
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                       ||' : After conversion of CharDT to Date '||
                         ' End Date = '||l_old_vr_rec.END_DATE);
           END IF;

       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'PLANNED_PROCESS_LOSS') THEN
           l_old_vr_rec.PLANNED_PROCESS_LOSS := p_update_table(i).p_value;
--RLNAGARA start B6997624 Added code to update Fixed Process Loss and UOM
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'FIXED_PROCESS_LOSS') THEN
           l_old_vr_rec.FIXED_PROCESS_LOSS := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'FIXED_PROCESS_LOSS_UOM') THEN
           l_old_vr_rec.FIXED_PROCESS_LOSS_UOM := p_update_table(i).p_value;
--RLNAGARA end B6997624
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'STD_QTY') THEN
           l_old_vr_rec.STD_QTY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'MIN_QTY') THEN
           l_old_vr_rec.MIN_QTY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'MAX_QTY') THEN
           l_old_vr_rec.MAX_QTY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK') THEN
           l_old_vr_rec.DELETE_MARK := p_update_table(i).p_value;
           -- Bug #4134275 Kapil M
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATED_BY') THEN
           l_old_vr_rec.LAST_UPDATED_BY := NVL(p_update_table(i).p_value, fnd_global.user_id);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_DATE') THEN
           l_old_vr_rec.LAST_UPDATE_DATE := FND_DATE.canonical_to_date(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_LOGIN') THEN
           l_old_vr_rec.LAST_UPDATE_LOGIN := NVL(p_update_table(i).p_value,gmd_api_grp.login_id);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1') THEN
           l_old_vr_rec.ATTRIBUTE1 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2') THEN
           l_old_vr_rec.ATTRIBUTE2 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3') THEN
           l_old_vr_rec.ATTRIBUTE3 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4') THEN
           l_old_vr_rec.ATTRIBUTE4 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5') THEN
           l_old_vr_rec.ATTRIBUTE5 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6') THEN
           l_old_vr_rec.ATTRIBUTE6 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7') THEN
           l_old_vr_rec.ATTRIBUTE7 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8') THEN
           l_old_vr_rec.ATTRIBUTE8 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9') THEN
           l_old_vr_rec.ATTRIBUTE9 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10') THEN
           l_old_vr_rec.ATTRIBUTE10 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11') THEN
           l_old_vr_rec.ATTRIBUTE11 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12') THEN
           l_old_vr_rec.ATTRIBUTE12 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13') THEN
           l_old_vr_rec.ATTRIBUTE13 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14') THEN
           l_old_vr_rec.ATTRIBUTE14 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15') THEN
           l_old_vr_rec.ATTRIBUTE15 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16') THEN
           l_old_vr_rec.ATTRIBUTE16 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17') THEN
           l_old_vr_rec.ATTRIBUTE17 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18') THEN
           l_old_vr_rec.ATTRIBUTE18 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19') THEN
           l_old_vr_rec.ATTRIBUTE19 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20') THEN
           l_old_vr_rec.ATTRIBUTE20 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21') THEN
           l_old_vr_rec.ATTRIBUTE21 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22') THEN
           l_old_vr_rec.ATTRIBUTE22 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23') THEN
           l_old_vr_rec.ATTRIBUTE23 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24') THEN
           l_old_vr_rec.ATTRIBUTE24 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25') THEN
           l_old_vr_rec.ATTRIBUTE25 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26') THEN
           l_old_vr_rec.ATTRIBUTE26 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27') THEN
           l_old_vr_rec.ATTRIBUTE27 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28') THEN
           l_old_vr_rec.ATTRIBUTE28 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29') THEN
           l_old_vr_rec.ATTRIBUTE29 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30') THEN
           l_old_vr_rec.ATTRIBUTE30 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY') THEN
           l_old_vr_rec.ATTRIBUTE_CATEGORY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'VALIDITY_RULE_STATUS') THEN
         -- Users should be prompted to use change status API
         -- Since Change Status API commits work it cannot be
         -- called from here directly
         FND_MESSAGE.set_name('GMD','GMD_NOT_USE_API_UPD_STATUS');
         FND_MSG_PUB.ADD;
         RAISE vr_update_failure;
       END IF;

       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': '||
                            'Assigned all values - Now performing indv validations ');
       END IF;

       /* Chcek if update is allowed */
       IF NOT GMD_COMMON_VAL.update_allowed('VALIDITY'
                                             ,p_Validity_rule_id
                                             ,UPPER(p_update_table(i).p_col_to_update) ) THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_VR_CANNOT_UPD');
         FND_MSG_PUB.ADD;
         RAISE vr_update_failure;
       END IF;

       /* Compare Dates - if the last update date passed in via the API is less than
          the last update in the db - it indicates someelse has updated this row after this
          row was selected */
       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 1 '||
                            'Comparing last updates to check if there any locking issues ');
       END IF;

       OPEN  Get_db_last_update_date(p_Validity_rule_id);
       FETCH Get_db_last_update_date INTO l_db_date;
         IF Get_db_last_update_date%NOTFOUND THEN
            CLOSE Get_db_last_update_date;
            RAISE vr_update_failure;
         END IF;
       CLOSE Get_db_last_update_date;

       -- Validation are done here
       -- it might have to moved to a PUB layer !!!!
       IF l_old_vr_rec.LAST_UPDATE_DATE < l_db_date THEN
       	  RAISE last_update_date_failure;
       END IF;

       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 2 '||
                            'Start and End Date validation '||l_old_vr_rec.start_date||
                            ' - '||l_old_vr_rec.end_date);
       END IF;

       -- Check if the item being modified is either a product or a by-product
       IF (UPPER(p_update_table(i).p_col_to_update) = 'ITEM_ID') THEN
          IF NOT Determine_Product(l_old_vr_rec.RECIPE_ID, l_old_vr_rec.INVENTORY_ITEM_ID) THEN -- NPD Conv.
             FND_MESSAGE.SET_NAME('GMD', 'GMD_ITEM_IS_PRODUCT');
             FND_MSG_PUB.ADD;
             x_return_status := 'E';
             RAISE vr_update_failure;
          END IF;
       END IF;

       -- Validity rule date validation with routing dates
       IF (UPPER(p_update_table(i).p_col_to_update) IN ('START_DATE','END_DATE')) THEN

         -- Validity rule start and end date validation
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 2c '||
                          'Checking if end date ( '||l_old_vr_rec.end_date||' ) '||
                          ' > '||' start date ( '||l_old_vr_rec.start_date||' ) ');
         END IF;
         -- Comparing Vr start and End dates
         effective_dates ( P_start_date => l_old_vr_rec.start_date,
                           P_end_date => l_old_vr_rec.end_date,
                           x_return_status => x_return_status);

         IF (x_return_status <> 'S') THEN
           RAISE vr_update_failure;
         END IF;

         -- Comparing Vr dates with Routing Dates
         IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 2a0 '||
                            'Comparing Vr dates with Routing Dates ');
         END IF;

         FOR get_routing_rec in Get_Routing_Details(p_validity_rule_id) LOOP
           -- Get the routing start date if applicable
           IF (l_debug = 'Y') THEN
             gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                                ||': The vr start date = '||l_old_vr_rec.start_date
                                ||' rout start date = '||get_routing_rec.effective_start_date);
             gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                                ||': The Vr end date = '||l_old_vr_rec.end_date
                                ||' rout end date = '||get_routing_rec.effective_end_date);
           END IF;

           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 2a '||
                            'Checking if VR start date > Routing start date ');
           END IF;

           validate_start_date (P_disp_start_date  => l_old_vr_rec.start_date,
                                P_routing_start_date => get_routing_rec.effective_start_date,
                                x_return_status => x_return_status);
           IF (x_return_status <> 'S') THEN
             RAISE vr_update_failure;
           END IF;

           -- Get the routing start date if applicable
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 2b '||
                            'Chceking if VR end date < Routing end date ');
           END IF;
           validate_end_date (P_end_date  => l_old_vr_rec.end_date,
                              P_routing_end_date => get_routing_rec.effective_end_date,
                              x_return_status => x_return_status);

           IF (x_return_status <> 'S') THEN
             RAISE vr_update_failure;
           END IF;
         END LOOP;

       END IF; -- When start or end dates are updated

       IF (l_debug = 'Y') THEN
           gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 3 '
                      ||' : About to validate std qty '
                      ||'The min qty <  max qty <  std qty = '
                      ||l_old_vr_rec.min_qty||' - '||l_old_vr_rec.max_qty
                      ||' - '||l_old_vr_rec.std_qty);
         END IF;

       -- Min, MAx and Std qty validation
       IF (UPPER(p_update_table(i).p_col_to_update)
                                  IN ('STD_QTY','MIN_QTY','MAX_QTY')) THEN
         -- Check if scale type at formula header is fixed, if yes then
         -- the qty's fields cannot be updated
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 3 '||
                            'Checking if formula hdr is fixed scaled ');
         END IF;

         OPEN check_fmhdr_fixed_scale(l_old_vr_rec.Recipe_id);
         FETCH check_fmhdr_fixed_scale INTO l_fixed_scale;
         CLOSE check_fmhdr_fixed_scale;

         IF (l_fixed_scale = 1) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_FXD_HDR_FOR_VR');
           FND_MSG_PUB.ADD;
           RAISE vr_update_failure;
         END IF;

         -- Check if scale type at formula dtl for the VR product is fixed, if yes then
         -- the qty's fields cannot be updated
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 3 '||
                            'Checking if formula dtl is fixed scaled ');
         END IF;

         OPEN check_fmdtl_fixed_scale(l_old_vr_rec.Recipe_id, l_old_vr_rec.inventory_item_id); -- NPD Conv.
         FETCH check_fmdtl_fixed_scale INTO l_fixed_scale;
         CLOSE check_fmdtl_fixed_scale;

         IF (l_fixed_scale = 1) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_FXD_HDR_FOR_VR');
           FND_MSG_PUB.ADD;
           RAISE vr_update_failure;
         END IF;
       END IF;
-- Bug 5024092 KapilM
-- Moved the stnd qty and min max qty check out of this loop.
       -- The inv_min and max qty changes only ifthe min or max_qty value is changed
       IF (UPPER(p_update_table(i).p_col_to_update) IN ('MIN_QTY','MAX_QTY')) THEN
         SELECT UNIQUE primary_uom_code
         INTO   l_inv_item_um
         FROM   mtl_system_items
         WHERE  inventory_item_id = l_old_vr_rec.inventory_item_id;

         IF (l_debug = 'Y') THEN
             gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                      ||': Val 4: About to calc inv min/max qty '
                      ||'The min qty, max qty  = '
                      ||l_old_vr_rec.min_qty||' - '||l_old_vr_rec.max_qty);
         END IF;

         calc_inv_qtys (P_inv_item_um   => l_inv_item_um,
                        P_item_um       => l_old_vr_rec.detail_uom,
                        P_item_id       => l_old_vr_rec.inventory_item_id,
                        P_min_qty       => l_old_vr_rec.min_qty,
                        P_max_qty       => l_old_vr_rec.max_qty,
                        X_inv_min_qty   => l_old_vr_rec.inv_min_qty,
                        X_inv_max_qty   => l_old_vr_rec.inv_max_qty,
                        x_return_status => x_return_status);

         IF (x_return_status <> 'S') THEN
           RAISE vr_update_failure;
         END IF;
       END IF;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': About to calc process loss '
                      ||'The min qty, max qty and std qty = '
                      ||l_old_vr_rec.min_qty||' - '||l_old_vr_rec.max_qty
                      ||' - '||l_old_vr_rec.std_qty);
       END IF;

       IF ((UPPER(p_update_table(i).p_col_to_update) = 'STD_QTY') AND
          (UPPER(p_update_table(i).p_col_to_update) <> 'PLANNED_PROCESS_LOSS')) THEN
         calculate_process_loss( V_assign 	=> 1
                                ,P_vr_id    => p_validity_rule_id
                                ,X_TPL      => l_tpl
                                ,X_PPL      => l_old_vr_rec.planned_process_loss
                                ,x_return_status => x_return_status);
         IF (x_return_status <> 'S') THEN
           --Ignore this error, its ok to update VR without Process loss
           x_return_status := 'S';
           --RAISE vr_update_failure;
         END IF;
       END IF;

       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': About to check for duplicates ');
       END IF;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 6: About to check for duplicates '
                      ||'The min qty, max qty and std qty = '
                      ||l_old_vr_rec.min_qty||' - '||l_old_vr_rec.max_qty
                      ||' - '||l_old_vr_rec.std_qty);
       END IF;

       -- Check for duplicate VR
       -- bug 4134275
       check_for_duplicate (    p_recipe_validity_rule_id => p_validity_rule_id
                               ,pRecipe_id              => l_old_vr_rec.recipe_id
                               ,pitem_id                => l_old_vr_rec.inventory_item_id
                               ,pOrgn_code              => l_old_vr_rec.orgn_code
                               -- NPD Conv.
                               ,pOrganization_id        => l_old_vr_rec.organization_id
                               ,pRecipe_Use             => l_old_vr_rec.recipe_use
                               ,pPreference             => l_old_vr_rec.preference
                               ,pstd_qty                => l_old_vr_rec.std_qty
                               ,pmin_qty                => l_old_vr_rec.min_qty
                               ,pmax_qty                => l_old_vr_rec.max_qty
                               ,pinv_max_qty            => l_old_vr_rec.inv_max_qty
                               ,pinv_min_qty            => l_old_vr_rec.inv_min_qty
                               ,pitem_um                => l_old_vr_rec.detail_uom
                               ,pValidity_Rule_status   => l_old_vr_rec.validity_rule_status
                               ,pstart_date             => l_old_vr_rec.start_date
                               ,pend_date               => l_old_vr_rec.end_date
                               ,pplanned_process_loss   => l_old_vr_rec.planned_process_loss
                               ,x_return_status         => x_return_status
                               );

       IF (x_return_status <> 'S') THEN
         RAISE vr_update_failure;
       END IF;

       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                      ||': Before Final update : About to Update Val Rules '
                      ||'The min qty, max qty and std qty = '
                      ||l_old_vr_rec.min_qty||' - '||l_old_vr_rec.max_qty
                      ||' - '||l_old_vr_rec.std_qty);
       END IF;

       -- NPD Conv.
       /* Check if for the updated organization - formula items remain valid */
       IF (UPPER(p_update_table(i).p_col_to_update) IN ('ORGN_CODE','ORGANIZATION_ID')) THEN

       -- Get the formula_id and recipe_use for the VR
       OPEN get_recp_dets;
       FETCH get_recp_dets INTO l_formula_id, l_recp_use;
       CLOSE get_recp_dets;
       -- If recipe_use is for production ( =0), pass production flag as TRUE to check_item_exists
       IF (NVL(l_recp_use,0) = 0) THEN
               GMD_API_GRP.check_item_exists (p_formula_id 	 => l_formula_id,
	                                      x_return_status 	 => x_return_status,
	                                      p_organization_id  => l_old_vr_rec.organization_id,
	                                      p_orgn_code 	 => l_old_vr_rec.orgn_code,
	                                      p_production_check => TRUE);

       ELSE
               GMD_API_GRP.check_item_exists (p_formula_id 	 => l_formula_id,
               	                              x_return_status 	 => x_return_status,
	                                      p_organization_id  => l_old_vr_rec.organization_id,
	                                      p_orgn_code 	 => l_old_vr_rec.orgn_code,
	                                      p_production_check => FALSE);

       END IF;

       IF (x_return_status <> 'S') THEN
           RAISE vr_update_failure;
       END IF;

       END IF;
    END LOOP;

-- Bug 5024092 Kapil M
-- Moved the stnd qty and min max qty check out of above loop.
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': Val 3 '||
                            'Checking if min qty < std qty < max qty ');
         END IF;
         -- Checks if std_qty is between min and max qty


         std_qty(P_std_qty => l_old_vr_rec.std_qty,
                 P_min_qty => l_old_vr_rec.min_qty,
                 P_max_qty => l_old_vr_rec.max_qty,
                 x_return_status => x_return_status);

         IF (x_return_status <> 'S') THEN
           RAISE vr_update_failure;
         END IF;

         IF (l_debug = 'Y') THEN
             gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': About to validate max qty '
                      ||'The min qty, max qty  = '
                      ||l_old_vr_rec.min_qty||' - '||l_old_vr_rec.max_qty);
         END IF;

         -- Min, Max qty validation
         max_qty(P_min_qty => l_old_vr_rec.min_qty,
                 P_max_qty => l_old_vr_rec.max_qty,
                 x_return_status => x_return_status);

         IF (x_return_status <> 'S') THEN
           RAISE vr_update_failure;
         END IF;

       /* Number of times this routine is equal to number of rows in the p_update_table */
       UPDATE  GMD_RECIPE_VALIDITY_RULES
       SET
           recipe_id            = l_old_vr_rec.recipe_id
         , orgn_code            = l_old_vr_rec.orgn_code
         -- NPD Conv.
         , organization_id      = l_old_vr_rec.organization_id
         , inventory_item_id    = l_old_vr_rec.inventory_item_id
         , revision             = l_old_vr_rec.revision
         , detail_uom           = l_old_vr_rec.detail_uom
         -- End NPD Conv.
         , recipe_use           = l_old_vr_rec.recipe_use
         , preference           = l_old_vr_rec.preference
         , start_date           = l_old_vr_rec.start_date
         , end_date             = l_old_vr_rec.end_date
         , min_qty              = l_old_vr_rec.min_qty
         , max_qty              = l_old_vr_rec.max_qty
         , std_qty              = l_old_vr_rec.std_qty
         , inv_min_qty          = l_old_vr_rec.inv_min_qty
         , inv_max_qty          = l_old_vr_rec.inv_max_qty
         , text_code            = l_old_vr_rec.text_code
         , attribute_category   = l_old_vr_rec.attribute_category
         , attribute1           = l_old_vr_rec.attribute1
         , attribute2           = l_old_vr_rec.attribute2
         , attribute3           = l_old_vr_rec.attribute3
         , attribute4           = l_old_vr_rec.attribute4
         , attribute5           = l_old_vr_rec.attribute5
         , attribute6           = l_old_vr_rec.attribute6
         , attribute7           = l_old_vr_rec.attribute7
         , attribute8           = l_old_vr_rec.attribute8
         , attribute9           = l_old_vr_rec.attribute9
         , attribute10          = l_old_vr_rec.attribute10
         , attribute11          = l_old_vr_rec.attribute11
         , attribute12          = l_old_vr_rec.attribute12
         , attribute13          = l_old_vr_rec.attribute13
         , attribute14          = l_old_vr_rec.attribute14
         , attribute15          = l_old_vr_rec.attribute15
         , attribute16          = l_old_vr_rec.attribute16
         , attribute17          = l_old_vr_rec.attribute17
         , attribute18          = l_old_vr_rec.attribute18
         , attribute19          = l_old_vr_rec.attribute19
         , attribute20          = l_old_vr_rec.attribute20
         , attribute21          = l_old_vr_rec.attribute21
         , attribute23          = l_old_vr_rec.attribute23
         , attribute22          = l_old_vr_rec.attribute22
         , attribute24          = l_old_vr_rec.attribute24
         , attribute25          = l_old_vr_rec.attribute25
         , attribute26          = l_old_vr_rec.attribute26
         , attribute27          = l_old_vr_rec.attribute27
         , attribute28          = l_old_vr_rec.attribute28
         , attribute29          = l_old_vr_rec.attribute29
         , attribute30          = l_old_vr_rec.attribute30
         , created_by           = l_old_vr_rec.created_by
         , creation_date        = l_old_vr_rec.creation_date
         , last_updated_by      = l_old_vr_rec.last_updated_by
         , last_update_date     = l_old_vr_rec.last_update_date
         , last_update_login    = l_old_vr_rec.last_update_login
         , delete_mark          = l_old_vr_rec.delete_mark
         , validity_rule_status = l_old_vr_rec.validity_rule_status
         , lab_type             = l_old_vr_rec.lab_type
         , planned_process_loss = l_old_vr_rec.planned_process_loss
	 , fixed_process_loss   = l_old_vr_rec.fixed_process_loss           /* RLNAGARA   Bug6997624 */
	 , fixed_process_loss_uom = l_old_vr_rec.fixed_process_loss_uom     /* RLNAGARA   Bug6997624 */
       where recipe_validity_rule_id = p_validity_rule_id;

       IF (sql%notfound) THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_VR_UPD_NO_ACCESS');
          FND_MSG_PUB.ADD;
          RAISE vr_update_failure;
       END IF;

       IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||': After Update of Val Rules ');
       END IF;

     /* Check if work was done */
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE vr_update_failure;
     END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    /* Get the messgae list and count generated by this API */
    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

     IF (l_debug = 'Y') THEN
        gmd_debug.put_line(m_pkg_name||'.'||l_api_name
                           ||' Completed '||l_api_name
                           ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
     END IF;
  EXCEPTION
    WHEN vr_update_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN last_update_date_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.add_exc_msg (m_pkg_name, l_api_name);
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
  END update_validity_rules;

END GMD_VALIDITY_RULES_PVT;

/
