--------------------------------------------------------
--  DDL for Package Body GMD_AUTO_STEP_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_AUTO_STEP_CALC" AS
/* $Header: GMDSTEPB.pls 120.6 2006/08/09 05:39:28 kmotupal noship $ */

/*======================================================================
--  PROCEDURE :
--   calc_step_qty
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for calculating step
--    quantities automatically.  It assumes that check_step_qty_calculatable
--    has already been successfully executed.
--
--  REQUIREMENTS
--    p_parent_id non null value.
--    p_step_tbl  non null value.
--  SYNOPSIS:
--    calc_step_qty (426, X_step_tbl, X_msg_count, X_msg_stack, X_return_status, 0, 0);
--
--  This procedure calls:  LOAD_STEPS
--                         GET_STEP_MATERIAL_LINES
--                         GET_STEP_REC
--                         SORT_STEP_LINES
--
--===================================================================== */
-- Forward declaration of procedure to determine whether the batch has entirely Mass or vol type..
PROCEDURE check_Bch_stp_qty_calculatable (P_check            IN  calculatable_rec_type,
                                        P_ignore_mass_conv OUT NOCOPY BOOLEAN,
                                        P_ignore_vol_conv  OUT NOCOPY BOOLEAN);

PROCEDURE calc_step_qty (P_parent_id	     IN     NUMBER,
                         P_step_tbl          OUT NOCOPY    step_rec_tbl,
                         P_msg_count	     OUT NOCOPY    NUMBER,
                         P_msg_stack	     OUT NOCOPY    VARCHAR2,
                         P_return_status     OUT NOCOPY    VARCHAR2,
                         P_called_from_batch IN     NUMBER DEFAULT 0,
                         P_step_no	     IN	    NUMBER DEFAULT NULL,
                         p_ignore_mass_conv  IN BOOLEAN DEFAULT FALSE,
                         p_ignore_vol_conv   IN BOOLEAN DEFAULT FALSE,
                         p_scale_factor      IN NUMBER DEFAULT NULL,
                         p_process_loss	     IN NUMBER DEFAULT 0,
			 p_organization_id   IN NUMBER) IS
  /* Local variables.
  ==================*/
  X_work_step_tbl		work_step_rec_tbl;
  X_step_rows			NUMBER;
  X_routing_id			NUMBER;
  X_cur_rec		        NUMBER;
  X_step_qty			NUMBER;
  X_step_mass_qty		NUMBER;
  X_step_vol_qty		NUMBER;
  X_cur_mass_qty		NUMBER;
  X_cur_vol_qty			NUMBER;
  X_new_factor			NUMBER;
  X_um_type			mtl_units_of_measure.uom_class%TYPE;
  X_return_status 		VARCHAR2(1);
  X_cur_step_status             NUMBER;

  X_plan_mass_qty		NUMBER;
  X_plan_vol_qty		NUMBER;
  X_actual_mass_qty		NUMBER;
  X_actual_vol_qty		NUMBER;

  X_step_plan_mass_qty		NUMBER;
  X_step_plan_vol_qty		NUMBER;
  X_step_actual_mass_qty	NUMBER;
  X_step_actual_vol_qty		NUMBER;

  /* Added by Shyam */
  X_cur_other_qty              NUMBER := 0;
  X_plan_other_qty             NUMBER := 0;
  X_actual_other_qty           NUMBER := 0;
  X_step_other_qty             NUMBER := 0;

  X_step_plan_other_qty		NUMBER := 0;
  X_step_actual_other_qty	NUMBER := 0;

  X_work_step_qty_tbl		work_step_qty_tbl;
  l_return_status		VARCHAR2(10);

  x_check  gmd_auto_step_calc.calculatable_rec_type;
  x_ignore_mass_conv BOOLEAN DEFAULT FALSE;
  x_ignore_vol_conv BOOLEAN DEFAULT FALSE;

  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_fm_dep_steps (V_step NUMBER) IS
    SELECT dep_routingstep_no, transfer_pct
    FROM   fm_rout_dep
    WHERE  routing_id = X_routing_id
    AND    routingstep_no = V_step;

  CURSOR Cur_get_pm_dep_steps (V_step_id NUMBER) IS
    SELECT batchstep_no, transfer_percent, step_status
    FROM   gme_batch_step_dependencies d, gme_batch_steps s
    WHERE  d.batch_id = P_parent_id
    AND    d.batchstep_id = V_step_id
    AND    s.batchstep_id = d.dep_step_id
    AND    s.batch_id = d.batch_id;

  CURSOR Cur_get_std_factor (V_uom_code VARCHAR2) IS
    SELECT a.conversion_rate, b.uom_class
    FROM   mtl_uom_conversions a, mtl_units_of_measure b
    WHERE  a.uom_code = b.uom_code
           AND a.inventory_item_id = 0
	   AND b.uom_code = V_uom_code;

  CURSOR Cur_get_step_status (V_step_id NUMBER) IS
    SELECT step_status
    FROM   gme_batch_steps
    WHERE  batchstep_id = V_step_id;

  /* Cursor Record.
  =====================*/
  -- None.  Cursor FOR loops are used.

  /* Exceptions.
  ================*/
  MISSING_PARENT_ID        		  EXCEPTION;
  STEPS_UOM_NOT_MASS_VOLUME_TYPE          EXCEPTION;
  LOAD_STEPS_FAILED			  EXCEPTION;
  GET_STEP_MATERIAL_LINES_FAILED          EXCEPTION;
  ERROR_SORTING_STEPS			  EXCEPTION;

BEGIN
  P_return_status := FND_API.G_RET_STS_SUCCESS;
  IF P_parent_id IS NULL THEN
    RAISE MISSING_PARENT_ID;
  END IF;

  GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id      => p_organization_id	,
				P_parm_name     => 'GMD_MASS_UM_TYPE'	,
				P_parm_value    => gmd_auto_step_calc.G_PROFILE_MASS_UM_TYPE	,
				X_return_status => l_return_status	);

  GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id      => p_organization_id	,
				P_parm_name     => 'GMD_VOLUME_UM_TYPE'	,
				P_parm_value    => gmd_auto_step_calc.G_PROFILE_VOLUME_UM_TYPE	,
				X_return_status => l_return_status	);

  /* Load all steps into the PL/SQL table P_step_tbl */
  /* Table is returned with step no filled in; qty and uom fields empty */
  load_steps (P_parent_id, P_called_from_batch, P_step_no, P_step_tbl, X_routing_id, X_return_status);
  IF X_return_status <> P_return_status THEN
    RAISE LOAD_STEPS_FAILED;
  END IF;

  /* Check that all the steps are defined in MASS or VOLUME uom type */
  /* Additional logic added by Shyam */
  /* If all steps are defined of the same type that is not Mass or Volume type then
     that is OK.  */
  /* So all steps can be 1) Either Mass or Volume type OR 2) some other type but the same
     type for all */
  IF NOT step_uom_mass_volume (P_step_tbl) THEN
    RAISE STEPS_UOM_NOT_MASS_VOLUME_TYPE;
  END IF;

-- bug# 5347857
-- If called from batch see if all the step items have same UOM type of mass or vol ..the mass.
   IF P_called_from_batch  = 1 THEN
    x_check.Parent_id := P_parent_id;
   check_Bch_stp_qty_calculatable (P_check  => x_check,
                                        P_ignore_mass_conv => x_ignore_mass_conv,
                                        P_ignore_vol_conv  => x_ignore_vol_conv
					);
   ELSE
     x_ignore_mass_conv := P_ignore_mass_conv;
     x_ignore_vol_conv  :=  P_ignore_vol_conv;
   END IF;

  /* Get all the material lines associated with the steps into the X_work_step_tbl   */
  /* The procedure calls the GMI conversion routing, so the qty's in X_work_step_tbl */
  /* will be converted to std mass and vol.                                          */

  /* Bug#3599182 - Thomas Daniel */
  /* The overloaded step material lines for scaling should only be invoked if the scale factor is not */
  /* equal to 1, changed the checking from NULL to equal to 1 as the recipe fetch pub is passing in   */
  /* a default value of 1 for p_scale_factor */
  IF NVL(P_scale_factor,1) = 1 THEN
    get_step_material_lines (P_parent_id, X_routing_id, P_called_from_batch, P_step_tbl, X_work_step_tbl,
                             X_return_status,x_ignore_mass_conv,x_ignore_vol_conv, p_process_loss);
  ELSE
    get_step_material_lines (P_parent_id, X_routing_id, P_called_from_batch, P_step_tbl, P_scale_factor,
                             X_work_step_tbl, X_return_status,x_ignore_mass_conv,x_ignore_vol_conv, p_process_loss);
  END IF;

  IF X_return_status <> P_return_status THEN
    RAISE GET_STEP_MATERIAL_LINES_FAILED;
  END IF;

  X_step_rows := P_step_tbl.COUNT;
  /* Calculate the step quantities for all the rows in P_step_tbl */
  FOR i IN 1..X_step_rows LOOP
    X_cur_mass_qty := 0;
    X_cur_vol_qty := 0;

    /*Bug 3431385 - Thomas Daniel */
    /*Initialize the other qty variable */
    X_cur_other_qty := 0;

    /* Bug 2314635 - Thomas Daniel */
    /* Changed the following calculations of the step quantities to consider the */
    /* plan and actual quantities for GME */
    X_plan_mass_qty := 0;
    X_plan_vol_qty := 0;
    X_actual_mass_qty := 0;
    X_actual_vol_qty := 0;

    /*Bug 3431385 - Thomas Daniel */
    /*Initialize the other qty variables */
    X_plan_other_qty := 0;
    X_actual_other_qty := 0;

    /* If called from GMD */
    IF P_called_from_batch = 0 THEN

      /* Calculate the quantities transferred from the prior steps */
      FOR X_fm_dep_step_rec IN Cur_get_fm_dep_steps (P_step_tbl(i).step_no) LOOP
        /*    Point X_cur_rec to the row(s) in P_Step_tbl which have data for    */
        /*    previous, dependent step.  Ex. Step 20 flows to step 30.  I have */
        /*    already calculated for step 20.  Now for step 30, pull step 20   */
        /*    data, subtract any product coming out of 20, apply transfer %.   */
        /*    This is the amount going in to step 30.                          */

        X_cur_rec := get_step_rec (X_fm_dep_step_rec.dep_routingstep_no, P_step_tbl);

        IF NOT (G_OTHER_UM_TYPE_EXISTS) THEN
          X_step_mass_qty := P_step_tbl(X_cur_rec).step_mass_qty;
          X_step_vol_qty := P_step_tbl(X_cur_rec).step_vol_qty;

          /* Deduct the products or byproduct quantities leaving the previous step */
          FOR j IN 1..X_work_step_tbl.COUNT LOOP
            IF (X_work_step_tbl(j).line_type <> -1) AND
               (X_work_step_tbl(j).step_no = X_fm_dep_step_rec.dep_routingstep_no) THEN
              X_step_mass_qty := X_step_mass_qty - X_work_step_tbl(j).line_mass_qty;
              X_step_vol_qty := X_step_vol_qty - X_work_step_tbl(j).line_vol_qty;
              IF X_step_mass_qty < 0 THEN
                X_step_mass_qty := 0;
              END IF;
              IF X_step_vol_qty < 0 THEN
                X_step_vol_qty := 0;
              END IF;
            END IF;
          END LOOP; /* FOR j IN 1..X_work_step_tbl.COUNT*/
          X_cur_mass_qty := X_cur_mass_qty +
                             (X_step_mass_qty * X_fm_dep_step_rec.transfer_pct * 0.01);
          X_cur_vol_qty  := X_cur_vol_qty +
                             (X_step_vol_qty * X_fm_dep_step_rec.transfer_pct * 0.01);
        ELSE /* when it is of other um type */
          X_step_other_qty := P_step_tbl(X_cur_rec).step_other_qty;

          /* Deduct the products or byproduct quantities leaving the previous step */
          FOR j IN 1..X_work_step_tbl.COUNT LOOP
            IF (X_work_step_tbl(j).line_type <> -1) AND
               (X_work_step_tbl(j).step_no = X_fm_dep_step_rec.dep_routingstep_no) THEN
              X_step_other_qty := X_step_other_qty - X_work_step_tbl(j).line_other_qty;
              IF X_step_other_qty < 0 THEN
                X_step_other_qty := 0;
              END IF;
            END IF;
          END LOOP; /* FOR j IN 1..X_work_step_tbl.COUNT*/
          X_cur_other_qty := X_cur_other_qty +
                             (X_step_other_qty * X_fm_dep_step_rec.transfer_pct * 0.01);

        END IF; /* Condition that checks for other um type */
      END LOOP; /* Cur_get_fm_dep_steps%FOUND*/

    ELSE /*IF P_called_from_batch = 0*/

      /* Calculate the quantities transferred from the prior steps */
      FOR X_pm_dep_step_rec IN Cur_get_pm_dep_steps (P_step_tbl(i).step_id)LOOP

        X_step_plan_mass_qty := 0;
        X_step_plan_vol_qty := 0;
        X_step_actual_mass_qty := 0;
        X_step_actual_vol_qty := 0;

        -- Added by Shyam
        X_step_plan_other_qty := 0;
        X_step_actual_other_qty := 0;

        IF NOT (G_OTHER_UM_TYPE_EXISTS) THEN
          FOR k in 1..X_work_step_qty_tbl.COUNT LOOP
            IF X_work_step_qty_tbl(k).step_no = X_pm_dep_step_rec.batchstep_no THEN
              X_step_plan_mass_qty := X_work_step_qty_tbl(k).plan_mass_qty;
              X_step_plan_vol_qty  := X_work_step_qty_tbl(k).plan_vol_qty;
              X_step_actual_mass_qty := X_work_step_qty_tbl(k).actual_mass_qty;
              X_step_actual_vol_qty  := X_work_step_qty_tbl(k).actual_vol_qty;
              EXIT;
            END IF;
          END LOOP;

          /* Deduct the products or byproduct quantities leaving the previous step */
          FOR j IN 1..X_work_step_tbl.COUNT LOOP
            IF (X_work_step_tbl(j).step_no = X_pm_dep_step_rec.batchstep_no) THEN
              IF X_work_step_tbl(j).line_type <> -1 THEN
                X_step_plan_mass_qty := X_step_plan_mass_qty - X_work_step_tbl(j).line_mass_qty;
                X_step_plan_vol_qty := X_step_plan_vol_qty - X_work_step_tbl(j).line_vol_qty;
                X_step_actual_mass_qty := X_step_actual_mass_qty - X_work_step_tbl(j).actual_mass_qty;
                X_step_actual_vol_qty := X_step_actual_vol_qty - X_work_step_tbl(j).actual_vol_qty;
              END IF;
            END IF;
          END LOOP; /* FOR j IN 1..X_work_step_tbl.COUNT*/

          IF X_step_plan_mass_qty  > 0 THEN
            X_plan_mass_qty := X_plan_mass_qty +
                             (X_step_plan_mass_qty * X_pm_dep_step_rec.transfer_percent * 0.01);
          END IF;
          IF X_step_plan_vol_qty  > 0 THEN
            X_plan_vol_qty := X_plan_vol_qty +
                              (X_step_plan_vol_qty * X_pm_dep_step_rec.transfer_percent * 0.01);
          END IF;

          /* B2335788 - Thomas Daniel */
          /* Moved the following checking as the transfer quantities need not be calculated only */
          /* for actuals if the parent step is in WIP status, still the planned transfers need to be calculated */
          /* The transfer quantities should not be calculated for WIP step*/
          /* Shikha Nagar B2304515 - reintroduced below code with WIP status         */
          IF X_pm_dep_step_rec.step_status <> 2 THEN
            IF X_step_actual_mass_qty  > 0 THEN
              X_actual_mass_qty := X_actual_mass_qty +
                                (X_step_actual_mass_qty * X_pm_dep_step_rec.transfer_percent * 0.01);
            END IF;
            IF X_step_actual_vol_qty  > 0 THEN
              X_actual_vol_qty := X_actual_vol_qty +
                                (X_step_actual_vol_qty * X_pm_dep_step_rec.transfer_percent * 0.01);
            END IF;
          END IF; /* IF X_pm_dep_step_rec.step_status <> 2 */
        ELSE /* when the um of other um type */
          FOR k in 1..X_work_step_qty_tbl.COUNT LOOP
            IF X_work_step_qty_tbl(k).step_no = X_pm_dep_step_rec.batchstep_no THEN
              X_step_plan_other_qty := X_work_step_qty_tbl(k).plan_other_qty;
              X_step_actual_other_qty := X_work_step_qty_tbl(k).actual_other_qty;
              EXIT;
            END IF;
          END LOOP;

          /* Deduct the products or byproduct quantities leaving the previous step */
          FOR j IN 1..X_work_step_tbl.COUNT LOOP
            IF (X_work_step_tbl(j).step_no = X_pm_dep_step_rec.batchstep_no) THEN
              IF X_work_step_tbl(j).line_type <> -1 THEN
                X_step_plan_other_qty := X_step_plan_other_qty - X_work_step_tbl(j).line_other_qty;
                X_step_actual_other_qty := X_step_actual_other_qty - X_work_step_tbl(j).actual_other_qty;
              END IF;
            END IF;
          END LOOP; /* FOR j IN 1..X_work_step_tbl.COUNT*/

          IF X_step_plan_other_qty  > 0 THEN
            X_plan_other_qty := X_plan_other_qty +
                             (X_step_plan_other_qty * X_pm_dep_step_rec.transfer_percent * 0.01);
          END IF;

          /* B2335788 - Thomas Daniel */
          /* Moved the following checking as the transfer quantities need not be calculated only */
          /* for actuals if the parent step is in WIP status, still the planned transfers need to be calculated */
          /* The transfer quantities should not be calculated for WIP step*/
          /* Shikha Nagar B2304515 - reintroduced below code with WIP status         */
          IF X_pm_dep_step_rec.step_status <> 2 THEN
            IF X_step_actual_other_qty  > 0 THEN
              X_actual_other_qty := X_actual_other_qty +
                                (X_step_actual_other_qty * X_pm_dep_step_rec.transfer_percent * 0.01);
            END IF;
          END IF; /* IF X_pm_dep_step_rec.step_status <> 2 */
        END IF; /* end of other um typ econdition */
      END LOOP; /* Cur_get_pm_dep_steps%FOUND */
    END IF; /*IF P_called_from_batch = 0*/

    /* Add the ingredient quantities that go into the current step */
    FOR j IN 1..X_work_step_tbl.COUNT LOOP
      IF (X_work_step_tbl(j).line_type = -1) AND
         (X_work_step_tbl(j).step_no = P_step_tbl(i).step_no) THEN
        IF p_called_from_batch = 0 THEN
          IF NOT G_OTHER_UM_TYPE_EXISTS THEN /* checking for other um type */
            X_cur_mass_qty := X_cur_mass_qty + X_work_step_tbl(j).line_mass_qty;
            X_cur_vol_qty := X_cur_vol_qty + X_work_step_tbl(j).line_vol_qty;
          ELSE
            X_cur_other_qty := X_cur_other_qty + X_work_step_tbl(j).line_other_qty;
          END IF;
        ELSE /* for batch */
          IF NOT G_OTHER_UM_TYPE_EXISTS THEN /* checking for other um type */
             X_plan_mass_qty := X_plan_mass_qty + X_work_step_tbl(j).line_mass_qty;
             X_plan_vol_qty := X_plan_vol_qty + X_work_step_tbl(j).line_vol_qty;
             X_actual_mass_qty := X_actual_mass_qty + X_work_step_tbl(j).actual_mass_qty;
             X_actual_vol_qty := X_actual_vol_qty + X_work_step_tbl(j).actual_vol_qty;
          ELSE
             X_plan_other_qty := X_plan_other_qty + X_work_step_tbl(j).line_other_qty;
             X_actual_other_qty := X_actual_other_qty + X_work_step_tbl(j).actual_other_qty;
          END IF;
        END IF;
      END IF;
    END LOOP; /* FOR j IN 1..X_work_step_tbl.COUNT*/

    -- Shikha Nagar B2304515 Added check to see batch step status to get
    -- planned or actual qty
    IF p_called_from_batch = 1 THEN
      IF NOT G_OTHER_UM_TYPE_EXISTS THEN /* checking for other um type */
        OPEN Cur_get_step_status(P_step_tbl(i).step_id);
        FETCH Cur_get_step_status INTO X_cur_step_status;
        CLOSE Cur_get_step_status ;

        IF X_cur_step_status > 1 THEN
          X_cur_mass_qty := X_actual_mass_qty;
          X_cur_vol_qty  := X_actual_vol_qty;
        ELSE
          X_cur_mass_qty := X_plan_mass_qty;
          X_cur_vol_qty  := X_plan_vol_qty;
        END IF;
      ELSE /* when the um typ eis other um typ e*/
        OPEN Cur_get_step_status(P_step_tbl(i).step_id);
        FETCH Cur_get_step_status INTO X_cur_step_status;
        CLOSE Cur_get_step_status ;

        IF X_cur_step_status > 1 THEN
          X_cur_other_qty := X_actual_other_qty;
        ELSE
          X_cur_other_qty := X_plan_other_qty;
        END IF;
      END IF; /* condition for um type */
    END IF;

    /* Get the std factor and UOM type for the step qty uom */
    OPEN Cur_get_std_factor (P_step_tbl(i).step_qty_uom);
    FETCH Cur_get_std_factor INTO X_new_factor, X_um_type;
    CLOSE Cur_get_std_factor;

    IF (X_um_type = G_profile_mass_um_type) THEN
      X_step_qty := X_cur_mass_qty * (1 / X_new_factor);
    ELSIF (X_um_type = G_profile_volume_um_type) THEN
      X_step_qty := X_cur_vol_qty * (1 / X_new_factor);
    ELSIF (X_um_type = G_profile_other_um_type) THEN
      X_step_qty := X_cur_other_qty * (1 / X_new_factor);
    END IF; /* IF X_um_type = G_profile_mass_um_type */

    IF NOT G_OTHER_UM_TYPE_EXISTS THEN
      P_step_tbl(i).step_qty      := X_step_qty;
      P_step_tbl(i).step_mass_qty := X_cur_mass_qty;
      P_step_tbl(i).step_mass_uom := G_mass_std_um;
      P_step_tbl(i).step_vol_qty  := X_cur_vol_qty;
      P_step_tbl(i).step_vol_uom  := G_vol_std_um;

      X_work_step_qty_tbl(i).step_no := p_step_tbl(i).step_no;
      X_work_step_qty_tbl(i).plan_mass_qty := X_plan_mass_qty;
      X_work_step_qty_tbl(i).plan_vol_qty := X_plan_vol_qty;
      X_work_step_qty_tbl(i).actual_mass_qty := X_actual_mass_qty;
      X_work_step_qty_tbl(i).actual_vol_qty := X_actual_vol_qty;
    ELSE
      P_step_tbl(i).step_qty      := X_step_qty;
      P_step_tbl(i).step_other_qty := X_cur_other_qty;
      P_step_tbl(i).step_other_uom := G_other_std_um;
      X_work_step_qty_tbl(i).step_no := p_step_tbl(i).step_no;
      X_work_step_qty_tbl(i).plan_other_qty := X_plan_other_qty;
      X_work_step_qty_tbl(i).actual_other_qty := X_actual_other_qty;
    END IF;

  END LOOP; /*FOR i IN 1..X_step_rows*/
  /* Sort the step lines */
  sort_step_lines (P_step_tbl, X_return_status);

  IF X_return_status <> P_return_status THEN
    RAISE ERROR_SORTING_STEPS;
  END IF;

EXCEPTION
  WHEN MISSING_PARENT_ID THEN
     P_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA', 'SY_KEYMISSING');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
  WHEN LOAD_STEPS_FAILED THEN
     P_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
  WHEN STEPS_UOM_NOT_MASS_VOLUME_TYPE THEN
     P_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_STEP_NOT_MASS_VOL_UOM');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
  WHEN GET_STEP_MATERIAL_LINES_FAILED THEN
     P_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
  WHEN ERROR_SORTING_STEPS THEN
     P_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
  WHEN OTHERS THEN
     P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
END calc_step_qty;

/*======================================================================
--  PROCEDURE :
--   load_steps
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for loading steps to the
--    PL/SQL table.
--
--  REQUIREMENTS
--    p_step_tbl  non null value.
--    P_parent_id non null value.
--  SYNOPSIS:
--    load_steps (426, 0, X_step_tbl, X_routing_id, X_return_status);
--
--  HISTORY
--  25Jul2001  L.R.Jackson   Added step_id to the load.  Changed some
--              explicit cursors to Cursor FOR loops.
--              Use _B tables where appropriate.
--  31oct2001  Raju  Added circular reference exception in the exceptions section
--             added message SQLERRM for when OTHERS exception.(bug2077203)
--  22jul2005  changed the step_qty_uom to step_qty_um in Cur_get_pm_process_uom cursor.
--===================================================================== */

PROCEDURE load_steps (P_parent_id         IN NUMBER,
                      P_called_from_batch IN NUMBER,
                      P_step_no	          IN NUMBER,
                      P_step_tbl         OUT NOCOPY step_rec_tbl,
                      P_routing_id       OUT NOCOPY NUMBER,
                      P_return_status    OUT NOCOPY VARCHAR2) IS
  /* Local variables.
  ==================*/

  X_return_status   	VARCHAR2(1);
  X_step_no	        NUMBER;
  X_step_id	        NUMBER;
  X_num_steps	    	NUMBER := 0;
  X_process_qty_um	mtl_units_of_measure.uom_code%TYPE;
  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_routing IS
    SELECT routing_id
    FROM   gmd_recipes_b
    WHERE  recipe_id = P_parent_id;

  /* Gets all step no's that are dependent */
  CURSOR Cur_get_steps IS
    SELECT dep_routingstep_no, max(level)
    FROM   fm_rout_dep
    START WITH ((routing_id = P_routing_id) AND
                ((p_step_no IS NULL) OR (routingstep_no = p_step_no)))
    CONNECT BY routing_id = prior routing_id
    AND    routingstep_no = prior dep_routingstep_no
    GROUP BY dep_routingstep_no
    ORDER BY max(level) desc;

  /* Gets all step no's that are independent */
  CURSOR cur_get_other_steps IS
    SELECT routingstep_no
    FROM   fm_rout_dtl
    WHERE  routing_id = P_routing_id
    AND    routingstep_no NOT IN
           (SELECT dep_routingstep_no
            FROM   fm_rout_dep
            WHERE  routing_id = P_routing_id);

  CURSOR Cur_get_process_uom (V_routingstep_no NUMBER) IS
    SELECT o.process_qty_uom, d.routingstep_id
    FROM   fm_rout_dtl d,
           gmd_operations_b o
    WHERE  d.oprn_id = o.oprn_id
    AND    d.routing_id = P_routing_id
    AND    d.routingstep_no = V_routingstep_no;

  CURSOR Cur_get_pm_routing IS
    SELECT routing_id
    FROM   gme_batch_header
    WHERE  batch_id = P_parent_id;

  CURSOR Cur_get_pm_steps (V_step_id NUMBER) IS
    SELECT d.dep_step_id, max(level)
    FROM   gme_batch_step_dependencies d
    WHERE  d.batch_id = P_parent_id
    START WITH ((d.batch_id = P_parent_id) AND
                ((v_step_id IS NULL) OR (batchstep_id = v_step_id)))
    CONNECT BY d.batch_id = prior d.batch_id
    AND    d.batchstep_id = prior d.dep_step_id
    GROUP BY d.dep_step_id
    ORDER BY max(level) desc;

  CURSOR Cur_get_pm_step_id (V_step_no NUMBER) IS
    SELECT batchstep_id
    FROM   gme_batch_steps
    WHERE  batch_id = P_parent_id
    AND    batchstep_no = V_step_no;

  CURSOR Cur_get_pm_step_no (V_step_id NUMBER) IS
    SELECT batchstep_no
    FROM   gme_batch_steps
    WHERE  batch_id = P_parent_id
    AND    batchstep_id = V_step_id;

  CURSOR Cur_get_pm_other_steps IS
    SELECT batchstep_id, batchstep_no
    FROM   gme_batch_steps s
    WHERE  s.batch_id = P_parent_id
    AND    s.batchstep_id NOT IN
           (SELECT dep_step_id
            FROM   gme_batch_step_dependencies
            WHERE  batch_id = P_parent_id);

  CURSOR Cur_get_pm_process_uom (V_batchstep_no NUMBER) IS
    SELECT STEP_QTY_UM
    FROM   gme_batch_steps
    WHERE  batch_id = P_parent_id
    AND    batchstep_no = V_batchstep_no;

  /* Cursor records.
  =====================*/
  -- Cursor FOR loop used instead

  /* Exceptions.
  =====================*/
   --For bug 2077203
  circular_reference EXCEPTION;
  PRAGMA EXCEPTION_INIT(circular_reference, -01436);

  NO_ROUTING_ASSOCIATED		EXCEPTION;
  ROUTING_DETAILS_MISSING	EXCEPTION;
BEGIN
  P_return_status := FND_API.G_RET_STS_SUCCESS;
  /* If called from GMD */
  IF P_called_from_batch = 0 THEN
    /* Fetch the routing for the recipe passed in from GMD */
    OPEN Cur_get_routing;
    FETCH Cur_get_routing INTO P_routing_id;
    IF Cur_get_routing%NOTFOUND THEN
      RAISE NO_ROUTING_ASSOCIATED;
    END IF;
    CLOSE Cur_get_routing;

    /* Get the routing steps from the dependency table */
    /* Add the steps to the pl/sql table              */
    FOR X_step_rec IN Cur_get_steps LOOP
      X_num_steps := X_num_steps + 1;

      /* Get the step UOM */
      OPEN Cur_get_process_uom (X_step_rec.dep_routingstep_no);
      FETCH Cur_get_process_uom INTO X_process_qty_um, X_step_id;
      CLOSE Cur_get_process_uom;

      P_step_tbl(X_num_steps).step_id       := X_step_id;
      P_step_tbl(X_num_steps).step_no       := X_step_rec.dep_routingstep_no;
      P_step_tbl(X_num_steps).step_qty_uom  := X_process_qty_um;
      P_step_tbl(X_num_steps).step_qty      := 0;
      P_step_tbl(X_num_steps).step_mass_qty := 0;
      P_step_tbl(X_num_steps).step_vol_qty  := 0;
      P_step_tbl(X_num_steps).step_other_qty  := 0;
    END LOOP; /* Cur_get_steps%FOUND */

    /* No dependencies defined get the steps from the routing table */
    /* or get the final steps for the dependent steps               */
    /* If requested for a step then directly associate the table with the step */
    IF P_step_no IS NOT NULL THEN
      /* Get the step UOM */
      OPEN Cur_get_process_uom (P_step_no);
      FETCH Cur_get_process_uom INTO X_process_qty_um, X_step_id;
      CLOSE Cur_get_process_uom;
      X_num_steps := X_num_steps + 1;
      P_step_tbl(X_num_steps).step_id       := X_step_id;
      P_step_tbl(X_num_steps).step_no       := P_step_no;
      P_step_tbl(X_num_steps).step_qty_uom  := X_process_qty_um;
      P_step_tbl(X_num_steps).step_qty      := 0;
      P_step_tbl(X_num_steps).step_mass_qty := 0;
      P_step_tbl(X_num_steps).step_vol_qty  := 0;
      P_step_tbl(X_num_steps).step_other_qty  := 0;
    ELSE
      -- Do not change this open/fetch/close cursor to Cursor FOR because
      -- an exception needs to be raised if no rows are found.
      -- We could get the id from the cur_get_other_steps cursor, but
      -- the process uom cursor is already returning it, so not necessary
      -- to select the value twice.
      OPEN cur_get_other_steps;
      FETCH cur_get_other_steps INTO X_step_no;
      IF cur_get_other_steps%FOUND THEN
        WHILE cur_get_other_steps%FOUND LOOP
          X_num_steps := X_num_steps + 1;

          /* Get the step UOM */
          OPEN Cur_get_process_uom (X_step_no);
          FETCH Cur_get_process_uom INTO X_process_qty_um, X_step_id;
          CLOSE Cur_get_process_uom;

          P_step_tbl(X_num_steps).step_id       := X_step_id;
          P_step_tbl(X_num_steps).step_no       := X_step_no;
          P_step_tbl(X_num_steps).step_qty_uom  := X_process_qty_um;
          P_step_tbl(X_num_steps).step_qty      := 0;
          P_step_tbl(X_num_steps).step_mass_qty := 0;
          P_step_tbl(X_num_steps).step_vol_qty  := 0;
          P_step_tbl(X_num_steps).step_other_qty  := 0;
          FETCH cur_get_other_steps INTO X_step_no;
        END LOOP; /*WHILE cur_get_other_steps%FOUND*/
      ELSE
        RAISE ROUTING_DETAILS_MISSING;
      END IF; /*IF cur_get_other_steps%FOUND*/
      CLOSE cur_get_other_steps;
    END IF; /* IF P_step_no IS NOT NULL */

  -- *****************************  BATCH  *************************
  ELSE
    /* Fetch the routing for the BATCH passed in */
    OPEN Cur_get_pm_routing;
    FETCH Cur_get_pm_routing INTO P_routing_id;
    IF Cur_get_pm_routing%NOTFOUND THEN
      RAISE NO_ROUTING_ASSOCIATED;
    END IF;
    CLOSE Cur_get_pm_routing;

    /* Fetch the batchstep id for the step no passed in */
    IF P_step_no IS NOT NULL THEN
      OPEN Cur_get_pm_step_id (P_step_no);
      FETCH Cur_get_pm_step_id INTO X_step_id;
      CLOSE Cur_get_pm_step_id;
    END IF;

    /* Get the routing steps from the PM dependency table */
    /* Add the steps to the pl/sql table                  */
    FOR X_pm_step_rec IN Cur_get_pm_steps (X_step_id) LOOP
      X_num_steps := X_num_steps + 1;

      /* Get the step no */
      OPEN Cur_get_pm_step_no (X_pm_step_rec.dep_step_id);
      FETCH Cur_get_pm_step_no INTO X_step_no;
      CLOSE Cur_get_pm_step_no;

      /* Get the step UOM */
      OPEN Cur_get_pm_process_uom (X_step_no);
      FETCH Cur_get_pm_process_uom INTO X_process_qty_um;
      CLOSE Cur_get_pm_process_uom;

      P_step_tbl(X_num_steps).step_id := X_pm_step_rec.dep_step_id;
      P_step_tbl(X_num_steps).step_no := X_step_no;
      P_step_tbl(X_num_steps).step_qty_uom := X_process_qty_um;
      P_step_tbl(X_num_steps).step_qty := 0;
      P_step_tbl(X_num_steps).step_mass_qty := 0;
      P_step_tbl(X_num_steps).step_vol_qty := 0;
      P_step_tbl(X_num_steps).step_other_qty  := 0;
    END LOOP; /* WHILE Cur_get_steps%FOUND */

    /* No dependencies defined get the steps from the routing table */
    /* or get the final steps for the dependent steps               */
    /* If requested for a step then directly associate the table with the step */
    IF P_step_no IS NOT NULL THEN
      /* Get the step UOM */
      OPEN Cur_get_pm_process_uom (P_step_no);
      FETCH Cur_get_pm_process_uom INTO X_process_qty_um;
      CLOSE Cur_get_pm_process_uom;
      X_num_steps := X_num_steps + 1;
      P_step_tbl(X_num_steps).step_id := X_step_id;
      P_step_tbl(X_num_steps).step_no := P_step_no;
      P_step_tbl(X_num_steps).step_qty_uom := X_process_qty_um;
      P_step_tbl(X_num_steps).step_qty := 0;
      P_step_tbl(X_num_steps).step_mass_qty := 0;
      P_step_tbl(X_num_steps).step_vol_qty := 0;
      P_step_tbl(X_num_steps).step_other_qty  := 0;
    ELSE
      OPEN Cur_get_pm_other_steps;
      FETCH Cur_get_pm_other_steps INTO X_step_id, X_step_no;
      IF Cur_get_pm_other_steps%FOUND THEN
        WHILE Cur_get_pm_other_steps%FOUND LOOP
          X_num_steps := X_num_steps + 1;

          /* Get the step UOM */
          OPEN Cur_get_pm_process_uom (X_step_no);
          FETCH Cur_get_pm_process_uom INTO X_process_qty_um;
          CLOSE Cur_get_pm_process_uom;

          P_step_tbl(X_num_steps).step_id := X_step_id;
          P_step_tbl(X_num_steps).step_no := X_step_no;
          P_step_tbl(X_num_steps).step_qty_uom := X_process_qty_um;
          P_step_tbl(X_num_steps).step_qty := 0;
          P_step_tbl(X_num_steps).step_mass_qty := 0;
          P_step_tbl(X_num_steps).step_vol_qty := 0;
          P_step_tbl(X_num_steps).step_other_qty  := 0;
          FETCH Cur_get_pm_other_steps INTO X_step_id, X_step_no;
        END LOOP; /*WHILE Cur_get_pm_other_steps%FOUND*/
      ELSE
        RAISE ROUTING_DETAILS_MISSING;
      END IF; /*IF Cur_get_pm_other_steps%FOUND*/
      CLOSE Cur_get_pm_other_steps;
    END IF; /* IF P_step_no IS NOT NULL */
  END IF; /* IF P_called_from_batch = 0 */
EXCEPTION
  WHEN NO_ROUTING_ASSOCIATED THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_AUTO_STEP_QTY_NEEDS_ROUT');
    FND_MSG_PUB.ADD;
  WHEN ROUTING_DETAILS_MISSING THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'FMROUTINGSTEPNOTFOUND');
    FND_MSG_PUB.ADD;
    --Following messages added for bug 2077203
  WHEN CIRCULAR_REFERENCE THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_CIRCULAR_DEPEN_DETECT');
    FND_MSG_PUB.ADD;
  WHEN OTHERS THEN
     P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
     FND_MSG_PUB.ADD;
END load_steps;

/*======================================================================
--  FUNCTION :
--    steps_uom_mass_volume
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for ensuring that every
--    step is defined in MASS or VOLUME.
--
--  REQUIREMENTS
--    p_step_tbl  non null value.
--  SYNOPSIS:
--    X_ret := step_uom_mass_volume (X_step_tbl);
--
--
--===================================================================== */

FUNCTION step_uom_mass_volume (P_step_tbl IN step_rec_tbl)
         RETURN BOOLEAN IS
  /* Local variables.
  ==================*/
  X_um_type	        mtl_units_of_measure.uom_class%TYPE;
  l_previous_um_type	mtl_units_of_measure.uom_class%TYPE;
  X_num_rows	        NUMBER(10);

  l_other_type_cnt      NUMBER := 1;

  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_um_type (V_uom_code VARCHAR2) IS
    SELECT uom_class
    FROM   mtl_units_of_measure
    WHERE  uom_code = V_uom_code;

  CURSOR Cur_get_std_um (V_uom_class VARCHAR2) IS
    SELECT uom_code
    FROM   mtl_units_of_measure
    WHERE  uom_class = V_uom_class;
BEGIN
  X_num_rows := P_step_tbl.COUNT;
  FOR i IN 1..X_num_rows LOOP

    OPEN Cur_get_um_type(P_step_tbl(i).step_qty_uom);
    FETCH Cur_get_um_type INTO X_um_type;
    CLOSE Cur_get_um_type;

    /* Check if the um type fr the current and new step are the same */
    /* Bug#3431385 - Thomas Daniel */
    /* Changed the following code to consider the Mass and Volume UOM profiles */
    /* being NULL */
    IF (G_profile_mass_um_type IS NULL OR X_um_type <> G_profile_mass_um_type) AND
       (G_profile_volume_um_type IS NULL OR X_um_type <> G_profile_volume_um_type) THEN
      IF (X_um_type = l_previous_um_type) THEN
        l_other_type_cnt := l_other_type_cnt + 1;
      END IF;
      l_previous_um_type := X_um_type;
    END IF;

  END LOOP;

  /* If all steps are of the same um type (and not MASS or VOLUME) then it is ok */
  IF (l_previous_um_type IS NOT NULL) THEN -- there is a other um type
    IF (l_other_type_cnt = X_num_rows) THEN -- if all step um type are of the same type
      /* set this as a global profile um type */
      G_PROFILE_OTHER_UM_TYPE := l_previous_um_type;
      /* Get the std um for the other um type */
      OPEN Cur_get_std_um (G_profile_other_um_type);
      FETCH Cur_get_std_um INTO G_OTHER_STD_UM;
      CLOSE Cur_get_std_um;
      /* set this Global variable - it would be used in other procs */
      G_OTHER_UM_TYPE_EXISTS := TRUE;
    ELSE -- mixed um type is not allowed
      -- i.e if there is a other type - all steps should of this um type
      RETURN (FALSE);
    END IF;
  ELSE -- its either mass or volume type um
    /* Populate the global mass and volume std um variables. */
    OPEN Cur_get_std_um (G_profile_mass_um_type);
    FETCH Cur_get_std_um INTO G_mass_std_um;
    CLOSE Cur_get_std_um;

    OPEN Cur_get_std_um (G_profile_volume_um_type);
    FETCH Cur_get_std_um INTO G_vol_std_um;
    CLOSE Cur_get_std_um;
  END IF;

  RETURN (TRUE);
END step_uom_mass_volume;

/*======================================================================
--  PROCEDURE :
--    get_step_material_lines
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for fetching the material
--    lines associated with the steps.
--
--  REQUIREMENTS
--    p_work_step_tbl  non null value.
--  SYNOPSIS:
--    get_step_material_lines (426, 100, 0, X_step_tbl, X_work_step_tbl,
--                             X_return_status);
--
--  This procedure calls GMICUOM.uom_conversion
--
--  HISTORY
--  25Jul2001  L.R.Jackson  Changed cursor to use id instead of step_no.
--                          Use ic_item_mst_b instead of ic_item_mst
--  08FEB2002  Shikha Nagar Changed Cur_get_batch_lines to take scrap_factor
                            into account.
--  08Mar2002  Shrikant Nene Changed the scrap factor calculation
--  05Apr2002  Shikha Nagar B2304515 Changed Cur_get_batch_lines to fetch
                            both planned and actual qty.
                            Also populating actual_mass_qty and actual_vol_qty
                            of x_work_step_tbl.
--===================================================================== */

 PROCEDURE get_step_material_lines (P_parent_id		IN NUMBER,
                                   P_routing_id		IN NUMBER,
                                   P_called_from_batch	IN NUMBER,
                                   P_step_tbl		IN step_rec_tbl,
                                   P_work_step_tbl 	IN OUT NOCOPY work_step_rec_tbl,
                                   P_return_status 	OUT NOCOPY VARCHAR2,
                                   p_ignore_mass_conv   IN BOOLEAN DEFAULT FALSE,
                                   p_ignore_vol_conv    IN BOOLEAN DEFAULT FALSE,
                                   p_process_loss	IN NUMBER DEFAULT 0) IS
  /* Local variables.
  ==================*/
  X_num_rows	NUMBER;
  X_cur_rec	NUMBER DEFAULT 0;
  X_line_qty	NUMBER;
  X_temp_qty	NUMBER;
  X_item_id	NUMBER;
  X_from_uom	mtl_units_of_measure.uom_code%TYPE;
  X_to_uom      mtl_units_of_measure.uom_code%TYPE;
  X_item_no	mtl_system_items_kfv.concatenated_segments%TYPE;

  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_material_lines (V_step_id NUMBER) IS
    -- NPD Conv. Use inventory_iem_id and detail_uom instead of item_id and item_um
    SELECT s.formulaline_id, d.line_type, d.qty, d.detail_uom, d.inventory_item_id, d.scale_type
    FROM   gmd_recipe_step_materials s,
           fm_matl_dtl d
    WHERE  s.recipe_id = P_parent_id
    AND    s.formulaline_id = d.formulaline_id
    AND    s.routingstep_id = V_step_id
    AND    NVL (d.contribute_step_qty_ind, 'Y') = 'Y'
    ORDER BY d.line_type;

  CURSOR Cur_get_batch_lines (V_step_id NUMBER) IS
    SELECT b.material_detail_id batchline_id, d.line_type,
           d.plan_qty,
           (d.actual_qty/(1+scrap_factor)) actual_qty,
           d.dtl_um, d.inventory_item_id
    FROM   gme_batch_step_items b,
           gme_material_details d,
           gme_batch_steps r
    WHERE  b.batch_id = P_parent_id
    AND    b.batchstep_id = r.batchstep_id
    AND    b.material_detail_id = d.material_detail_id
    AND    b.batchstep_id = V_step_id
    AND    NVL (d.contribute_step_qty_ind, 'Y') = 'Y'
    ORDER BY d.line_type;

  -- NPD Conv.
  CURSOR Cur_get_item IS
    SELECT concatenated_segments
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = X_item_id;

  /* Cursor records.
  =====================*/
  -- none.  Cursor FOR loops used.

  /* Exceptions.
  =====================*/
  UOM_CONVERSION_ERROR		EXCEPTION;
  NO_MATERIAL_STEP_ASSOC	EXCEPTION;

BEGIN
  P_work_step_tbl.DELETE;
  P_return_status := FND_API.G_RET_STS_SUCCESS;
  X_num_rows := P_step_tbl.COUNT;
  FOR i IN 1..X_num_rows LOOP

    /* If called from GMD */
    IF P_called_from_batch = 0 THEN
      FOR X_material_rec IN Cur_get_material_lines (P_step_tbl(i).step_id) LOOP
        X_cur_rec := X_cur_rec + 1;
        P_work_step_tbl(X_cur_rec).step_id := P_step_tbl(i).step_id;
        P_work_step_tbl(X_cur_rec).step_no := P_step_tbl(i).step_no;
        P_work_step_tbl(X_cur_rec).line_id := X_material_rec.formulaline_id;
        P_work_step_tbl(X_cur_rec).line_type := X_material_rec.line_type;

        /* If all steps of OTHER um type then you dont have to bother
           about converting line qtys to MASS and VOLUME type um */
        IF NOT (G_OTHER_UM_TYPE_EXISTS) THEN
          X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_material_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_material_rec.qty
                                                   ,from_unit      => X_material_rec.detail_uom
                                                   ,to_unit        => G_mass_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);

          IF X_temp_qty < 0 THEN
            X_item_id := X_material_rec.inventory_item_id;
            X_from_uom := X_material_rec.detail_uom;
            X_to_uom := G_mass_std_um;
            IF (p_ignore_mass_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).line_mass_qty := 0;
            END IF;
          ELSE
              P_work_step_tbl(X_cur_rec).line_mass_qty := X_temp_qty;
              /* Bug 1683702 - Thomas Daniel */
              /* Apply the process loss to the qty for the calculation of the step qty */
              IF X_material_rec.line_type = -1 AND
                 X_material_rec.scale_type = 1 AND
                 p_process_loss > 0 THEN
                P_work_step_tbl(X_cur_rec).line_mass_qty := P_work_step_tbl(X_cur_rec).line_mass_qty *
                                                            100 / (100 - p_process_loss);
              END IF;
          END IF;

          /*Bug#3599182 - Thomas Daniel */
          /*Commented the following IF as we need to proceed with the volume conversion though the mass */
          /*conversion has failed as there is a possibility of all the routing steps and the formula lines */
          /*belong to the same UOM type */
          -- IF (X_temp_qty > 0) THEN
            X_temp_qty := INV_CONVERT.inv_um_convert(item_id       => X_material_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_material_rec.qty
                                                   ,from_unit      => X_material_rec.detail_uom
                                                   ,to_unit        => G_vol_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
            IF X_temp_qty < 0 THEN
              X_item_id := X_material_rec.inventory_item_id;
              X_from_uom := X_material_rec.detail_uom;
              X_to_uom := G_vol_std_um;
              IF (p_ignore_vol_conv = FALSE) THEN
                RAISE UOM_CONVERSION_ERROR;
              ELSE
                P_work_step_tbl(X_cur_rec).line_vol_qty := 0;
              END IF;
            ELSE
              P_work_step_tbl(X_cur_rec).line_vol_qty := X_temp_qty;
              /* Bug 1683702 - Thomas Daniel */
              /* Apply the process loss to the qty for the calculation of the step qty */
              IF X_material_rec.line_type = -1 AND
                 X_material_rec.scale_type = 1 AND
                 p_process_loss > 0 THEN
                P_work_step_tbl(X_cur_rec).line_vol_qty := P_work_step_tbl(X_cur_rec).line_vol_qty *
                                                            100 / (100 - p_process_loss);
              END IF;
            END IF;
          /*Bug#3599182 - Thomas Daniel */
          /*Commented the END IF following IF */
          -- END IF;
        ELSE  /* When only other um type exists */
          /* Added by Shyam - To capture the line qty in the other um types std um */
          X_temp_qty := INV_CONVERT.inv_um_convert(item_id       => X_material_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_material_rec.qty
                                                   ,from_unit      => X_material_rec.detail_uom
                                                   ,to_unit        => G_other_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
          IF X_temp_qty < 0 THEN
            X_item_id := X_material_rec.inventory_item_id;
            X_from_uom := X_material_rec.detail_uom;
            X_to_uom := G_other_std_um;
            IF (p_ignore_mass_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).line_other_qty := 0;
            END IF;
          ELSE
            P_work_step_tbl(X_cur_rec).line_other_qty := X_temp_qty;
            /* Bug 1683702 - Thomas Daniel */
            /* Apply the process loss to the qty for the calculation of the step qty */
            IF X_material_rec.line_type = -1 AND
               X_material_rec.scale_type = 1 AND
               p_process_loss > 0 THEN
              P_work_step_tbl(X_cur_rec).line_other_qty := P_work_step_tbl(X_cur_rec).line_other_qty *
                                                         100 / (100 - p_process_loss);
            END IF;
          END IF;
        END IF; /* Condition that tests if other um type exists */

      END LOOP; /*WHILE Cur_get_material_lines%FOUND*/

    ELSE /*IF P_called_from_batch = 0.  This section used if called from batch */
      FOR X_batch_rec IN Cur_get_batch_lines (P_step_tbl(i).step_id) LOOP
        X_cur_rec := X_cur_rec + 1;
        P_work_step_tbl(X_cur_rec).step_id := P_step_tbl(i).step_id;
        P_work_step_tbl(X_cur_rec).step_no := P_step_tbl(i).step_no;
        P_work_step_tbl(X_cur_rec).line_id := X_batch_rec.batchline_id;
        P_work_step_tbl(X_cur_rec).line_type := X_batch_rec.line_type;

        /* If all steps of OTHER um type then you dont have to bother
           about converting line qtys to MASS and VOLUME type um */
        IF NOT (G_OTHER_UM_TYPE_EXISTS) THEN
          X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_batch_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_batch_rec.plan_qty
                                                   ,from_unit      => X_batch_rec.dtl_um
                                                   ,to_unit        => G_mass_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);

          IF X_temp_qty < 0 THEN
            X_item_id := X_batch_rec.inventory_item_id;
            X_from_uom := X_batch_rec.dtl_um;
            X_to_uom := G_mass_std_um;
            IF(p_ignore_mass_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).line_mass_qty := 0;
            END IF;
          ELSE
            P_work_step_tbl(X_cur_rec).line_mass_qty := X_temp_qty;
          END IF;
          -- Shikha Nagar B2304515
          X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_batch_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_batch_rec.actual_qty
                                                   ,from_unit      => X_batch_rec.dtl_um
                                                   ,to_unit        => G_mass_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
          IF X_temp_qty < 0 THEN
            X_item_id := X_batch_rec.inventory_item_id;
            X_from_uom := X_batch_rec.dtl_um;
            X_to_uom := G_mass_std_um;
            IF(p_ignore_mass_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).actual_mass_qty := 0;
            END IF;
          ELSE
            P_work_step_tbl(X_cur_rec).actual_mass_qty := X_temp_qty;
          END IF;

          X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_batch_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_batch_rec.plan_qty
                                                   ,from_unit      => X_batch_rec.dtl_um
                                                   ,to_unit        => G_vol_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
          IF X_temp_qty < 0 THEN
            X_item_id := X_batch_rec.inventory_item_id;
            X_from_uom := X_batch_rec.dtl_um;
            X_to_uom := G_vol_std_um;
            IF (p_ignore_vol_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).line_vol_qty := 0;
            END IF;
          ELSE
              P_work_step_tbl(X_cur_rec).line_vol_qty := X_temp_qty;
          END IF;

          -- Shikha Nagar B2304515
          X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_batch_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_batch_rec.actual_qty
                                                   ,from_unit      => X_batch_rec.dtl_um
                                                   ,to_unit        => G_vol_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
          IF X_temp_qty < 0 THEN
            X_item_id := X_batch_rec.inventory_item_id;
            X_from_uom := X_batch_rec.dtl_um;
            X_to_uom := G_vol_std_um;
            IF (p_ignore_vol_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).actual_vol_qty := 0;
            END IF;
          ELSE
             P_work_step_tbl(X_cur_rec).actual_vol_qty := X_temp_qty;
          END IF;

         ELSE /* Condition that checks for other type um */
           X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_batch_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_batch_rec.plan_qty
                                                   ,from_unit      => X_batch_rec.dtl_um
                                                   ,to_unit        => G_other_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);

          IF X_temp_qty < 0 THEN
            X_item_id := X_batch_rec.inventory_item_id;
            X_from_uom := X_batch_rec.dtl_um;
            X_to_uom := G_other_std_um;
            IF(p_ignore_mass_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).line_other_qty := 0;
            END IF;
          ELSE
            P_work_step_tbl(X_cur_rec).line_other_qty := X_temp_qty;
          END IF;
          -- Shikha Nagar B2304515
          X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_batch_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => X_batch_rec.actual_qty
                                                   ,from_unit      => X_batch_rec.dtl_um
                                                   ,to_unit        => G_other_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);

          IF X_temp_qty < 0 THEN
            X_item_id := X_batch_rec.inventory_item_id;
            X_from_uom := X_batch_rec.dtl_um;
            X_to_uom := G_other_std_um;
            IF(p_ignore_mass_conv = FALSE) THEN
              RAISE UOM_CONVERSION_ERROR;
            ELSE
              P_work_step_tbl(X_cur_rec).actual_other_qty := 0;
            END IF;
          ELSE
            P_work_step_tbl(X_cur_rec).actual_other_qty := X_temp_qty;
          END IF;
        END IF; /* condition for other type um */
      END LOOP; /*WHILE Cur_get_batch_lines%FOUND*/

    END IF; /*IF P_called_from_batch = 0*/
  END LOOP; /* FOR i IN 1..X_num_rows */
  IF X_cur_rec = 0 THEN
    RAISE NO_MATERIAL_STEP_ASSOC;
  END IF;

EXCEPTION
  WHEN UOM_CONVERSION_ERROR THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    OPEN Cur_get_item;
    FETCH Cur_get_item INTO X_item_no;
    CLOSE Cur_get_item;
    FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
    FND_MESSAGE.SET_TOKEN('FROM_UOM', X_from_uom);
    FND_MESSAGE.SET_TOKEN('TO_UOM', X_to_uom);
    FND_MSG_PUB.ADD;
  WHEN NO_MATERIAL_STEP_ASSOC THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_MATL_STEP_ASSOC');
    FND_MSG_PUB.ADD;
  WHEN OTHERS THEN
    P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD;
END get_step_material_lines;


/* Added by Shyam for GMF */
/*======================================================================
--  PROCEDURE : Overloaded
--    get_step_material_lines
--
--  DESCRIPTION:
--    This PL/SQL overloaded procedure is responsible for fetching the sclaed material
--    lines associated with the steps.
--
--  REQUIREMENTS
--    p_work_step_tbl  non null value.
--    p_scale_factor   not null value.
--  SYNOPSIS:
--    get_step_material_lines (426, 100, 0, X_step_tbl,P_scale_factor, X_work_step_tbl,
--                             X_return_status);
--
--  This procedure calls GMICUOM.uom_conversion
--
--  HISTORY
--  Shyam   05/10/2002  Initial Implementation
======================================================================== */

PROCEDURE get_step_material_lines (P_parent_id		IN NUMBER,
                                   P_routing_id		IN NUMBER,
                                   P_called_from_batch	IN NUMBER,
                                   P_step_tbl		IN step_rec_tbl,
                                   P_scale_factor       IN NUMBER ,
                                   P_work_step_tbl 	IN OUT NOCOPY work_step_rec_tbl,
                                   P_return_status 	OUT NOCOPY VARCHAR2,
                                   p_ignore_mass_conv   IN BOOLEAN DEFAULT FALSE,
                                   p_ignore_vol_conv    IN BOOLEAN DEFAULT FALSE,
                                   p_process_loss	IN NUMBER DEFAULT 0) IS

  /* Local variables.
  ==================*/
  X_num_rows	NUMBER;
  X_cur_rec	NUMBER DEFAULT 0;
  X_line_qty	NUMBER;
  X_temp_qty	NUMBER;
  X_item_id	NUMBER;
  X_from_uom	mtl_units_of_measure.uom_code%TYPE;
  X_to_uom      mtl_units_of_measure.uom_code%TYPE;
  X_item_no	mtl_system_items_kfv.concatenated_segments%TYPE;


  /* Scaling realted variables */
  k                    NUMBER  := 0;
  x_cost_row_cnt       NUMBER  := 0;
  x_cost_return_status VARCHAR2(1);
  p_cost_scale_tab     GMD_COMMON_SCALE.scale_tab;
  x_cost_scale_tab     GMD_COMMON_SCALE.scale_tab;

  /* This table associates the formulaline with the - scaled qtys in x_cost_scale_tab */
  P_formulaline_scale_tab  formulaline_scale_tab;

  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_material_lines (V_step_id NUMBER) IS
    -- NPD Conv. Use inventory_item_id and detail_uom instead of item_id and item_um from fm_matl_dtl
    SELECT s.formulaline_id, d.line_type, d.qty, d.detail_uom, d.inventory_item_id, d.scale_type
    FROM   gmd_recipe_step_materials s,
           fm_matl_dtl d
    WHERE  s.recipe_id = P_parent_id
    AND    s.formulaline_id = d.formulaline_id
    AND    s.routingstep_id = V_step_id
    AND    NVL (d.contribute_step_qty_ind, 'Y') = 'Y'
    ORDER BY d.line_type;

  -- NPD Conv.
  CURSOR Cur_get_item IS
    SELECT concatenated_segments
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = X_item_id;

  /* Get all formulaline information */
  CURSOR Cur_get_formulaline_info  IS
    SELECT d.*
    FROM  fm_matl_dtl d ,
          gmd_recipes_b r
    WHERE r.recipe_id = P_parent_id
      AND r.formula_id = d.formula_id
    ORDER BY d.line_type, d.line_no;

  -- NPD Conv. Get the formula owner orgn id
  CURSOR get_formula_owner_orgn_id IS
    SELECT f.owner_organization_id
    FROM   fm_form_mst f, gmd_recipes r
    WHERE  r.recipe_id = P_parent_id
    AND    f.formula_id = r.formula_id;

 l_orgn_id NUMBER;

  /* Exceptions.
  =====================*/
  UOM_CONVERSION_ERROR		EXCEPTION;
  NO_MATERIAL_STEP_ASSOC	EXCEPTION;
  COST_SCALING_ERROR            EXCEPTION;

BEGIN
  P_work_step_tbl.DELETE;
  P_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Perform the formula scaling first */
  /* Scale the formula using the scale factor */

  /* p_cost_scale_tab holds all formula scaled qtys */
  /* p_formulaline_scale_tab holds all formulaline and its scaled qtys */

  /* Initialize all tables */
  x_cost_scale_tab.DELETE;
  p_cost_scale_tab.DELETE;
  p_formulaline_scale_tab.DELETE;

  FOR X_formulaline_rec IN Cur_get_formulaline_info LOOP

    X_cost_row_cnt := X_cost_row_cnt + 1;
    -- NPD Conv. Use inventory_item_id and detail_uom instead of item_id and item_um
    p_cost_scale_tab(X_cost_row_cnt).line_no                 := X_formulaline_rec.line_no                ;
    p_cost_scale_tab(X_cost_row_cnt).line_type               := X_formulaline_rec.line_type              ;
    p_cost_scale_tab(X_cost_row_cnt).inventory_item_id       := X_formulaline_rec.inventory_item_id                ;
    p_cost_scale_tab(X_cost_row_cnt).qty                     := X_formulaline_rec.qty                    ;
    p_cost_scale_tab(X_cost_row_cnt).detail_uom              := X_formulaline_rec.detail_uom             ;
    p_cost_scale_tab(X_cost_row_cnt).scale_type              := X_formulaline_rec.scale_type             ;
    p_cost_scale_tab(X_cost_row_cnt).contribute_yield_ind    := X_formulaline_rec.contribute_yield_ind   ;
    p_cost_scale_tab(X_cost_row_cnt).scale_multiple          := X_formulaline_rec.scale_multiple         ;
    p_cost_scale_tab(X_cost_row_cnt).scale_rounding_variance := X_formulaline_rec.scale_rounding_variance;
    p_cost_scale_tab(X_cost_row_cnt).rounding_direction      := X_formulaline_rec.rounding_direction     ;
    p_formulaline_scale_tab(X_cost_row_cnt).formulaline_id   := X_formulaline_rec.formulaline_id         ;
  END LOOP;

  -- NPD Conv.
  OPEN get_formula_owner_orgn_id;
  FETCH get_formula_owner_orgn_id INTO l_orgn_id;
  CLOSE get_formula_owner_orgn_id;

  /* Calling the scaling API  */
  gmd_common_scale.scale( p_scale_tab      => p_cost_scale_tab
                          ,p_orgn_id       => l_orgn_id
                          ,p_scale_factor  => P_scale_factor
                          ,p_primaries     => 'OUTPUTS'
                          ,x_scale_tab     => x_cost_scale_tab
                          ,x_return_status => x_cost_return_status
                         );

  IF (x_cost_return_status <> 'S') THEN
     RAISE COST_SCALING_ERROR;
  END IF;

  /* Associate formulaline id with scaled values  */
  FOR i IN 1 .. x_cost_scale_tab.count LOOP
    p_formulaline_scale_tab(i).line_no                 :=  x_cost_scale_tab(i).line_no                ;
    p_formulaline_scale_tab(i).line_type               :=  x_cost_scale_tab(i).line_type              ;
    p_formulaline_scale_tab(i).inventory_item_id       :=  x_cost_scale_tab(i).inventory_item_id      ;
    p_formulaline_scale_tab(i).qty                     :=  x_cost_scale_tab(i).qty                    ;
    p_formulaline_scale_tab(i).detail_uom              :=  x_cost_scale_tab(i).detail_uom                ;
    p_formulaline_scale_tab(i).scale_type              :=  x_cost_scale_tab(i).scale_type             ;
    p_formulaline_scale_tab(i).contribute_yield_ind    :=  x_cost_scale_tab(i).contribute_yield_ind   ;
    p_formulaline_scale_tab(i).scale_multiple          :=  x_cost_scale_tab(i).scale_multiple         ;
    p_formulaline_scale_tab(i).scale_rounding_variance :=  x_cost_scale_tab(i).scale_rounding_variance;
    p_formulaline_scale_tab(i).rounding_direction      :=  x_cost_scale_tab(i).rounding_direction     ;
  END LOOP;

  X_num_rows := P_step_tbl.COUNT;
  FOR i IN 1..X_num_rows LOOP

    /* If called from GMF */
    IF (P_called_from_batch = 0) THEN

      FOR X_material_rec IN Cur_get_material_lines (P_step_tbl(i).step_id) LOOP
        X_cur_rec := X_cur_rec + 1;
        P_work_step_tbl(X_cur_rec).step_id := P_step_tbl(i).step_id;
        P_work_step_tbl(X_cur_rec).step_no := P_step_tbl(i).step_no;
        P_work_step_tbl(X_cur_rec).line_id := X_material_rec.formulaline_id;
        P_work_step_tbl(X_cur_rec).line_type := X_material_rec.line_type;

        FOR k in 1 .. x_cost_scale_tab.count LOOP
          IF (X_material_rec.formulaline_id = p_formulaline_scale_tab(k).formulaline_id) THEN
            /* If all steps of OTHER um type then you dont have to bother
               about converting line qtys to MASS and VOLUME type um */
            IF NOT (G_OTHER_UM_TYPE_EXISTS) THEN
              X_temp_qty := INV_CONVERT.inv_um_convert(item_id     => X_material_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => p_formulaline_scale_tab(k).qty
                                                   ,from_unit      => p_formulaline_scale_tab(k).detail_uom
                                                   ,to_unit        => G_mass_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);

              IF X_temp_qty < 0 THEN
                X_item_id := X_material_rec.inventory_item_id;  -- NPD Conv.
                X_from_uom := X_material_rec.detail_uom;  -- NPD Conv.
                X_to_uom := G_mass_std_um;
                IF (p_ignore_mass_conv = FALSE) THEN
                  RAISE UOM_CONVERSION_ERROR;
                ELSE
                  P_work_step_tbl(X_cur_rec).line_mass_qty := 0;
                END IF;
              ELSE
                P_work_step_tbl(X_cur_rec).line_mass_qty := X_temp_qty;
                /* Bug 1683702 - Thomas Daniel */
                /* Apply the process loss to the qty for the calculation of the step qty */
                IF X_material_rec.line_type = -1 AND
                   X_material_rec.scale_type = 1 AND
                   p_process_loss > 0 THEN
                  P_work_step_tbl(X_cur_rec).line_mass_qty := P_work_step_tbl(X_cur_rec).line_mass_qty *
                                                            100 / (100 - p_process_loss);
                END IF;
              END IF;  /* x_temp_qty > 0 condition */

              /*Bug#3599182 - Thomas Daniel */
              /*Commented the following IF as we need to proceed with the volume conversion though the mass */
              /*conversion has failed as there is a possibility of all the routing steps and the formula lines */
              /*belong to the same UOM type */
              -- IF (X_temp_qty > 0) THEN
                X_temp_qty := INV_CONVERT.inv_um_convert(item_id   => X_material_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => p_formulaline_scale_tab(k).qty
                                                   ,from_unit      => p_formulaline_scale_tab(k).detail_uom
                                                   ,to_unit        => G_vol_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
                IF X_temp_qty < 0 THEN
                  X_item_id := X_material_rec.inventory_item_id;
                  X_from_uom := X_material_rec.detail_uom;
                  X_to_uom := G_vol_std_um;
                  IF (p_ignore_vol_conv = FALSE) THEN
                    RAISE UOM_CONVERSION_ERROR;
                  ELSE
                    P_work_step_tbl(X_cur_rec).line_vol_qty := 0;
                  END IF;
                ELSE
                  P_work_step_tbl(X_cur_rec).line_vol_qty := X_temp_qty;
                  /* Bug 1683702 - Thomas Daniel */
                  /* Apply the process loss to the qty for the calculation of the step qty */
                  IF X_material_rec.line_type = -1 AND
                    X_material_rec.scale_type = 1 AND
                    p_process_loss > 0 THEN
                    P_work_step_tbl(X_cur_rec).line_vol_qty := P_work_step_tbl(X_cur_rec).line_vol_qty *
                                                               100 / (100 - p_process_loss);
                  END IF;
                END IF;
              /*Bug#3599182 - Thomas Daniel */
              /*Commented the ENDIF following IF */
              -- END IF;  /* x_temp_qty > 0 condition */

            ELSE /* When only other um type exists */
              /* Added by Shyam - To capture the line qty in the other um types std um */
              X_temp_qty := INV_CONVERT.inv_um_convert(item_id     => X_material_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => p_formulaline_scale_tab(k).qty
                                                   ,from_unit      => p_formulaline_scale_tab(k).detail_uom
                                                   ,to_unit        => G_other_std_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
              IF X_temp_qty < 0 THEN
                 X_item_id := X_material_rec.inventory_item_id;
                 X_from_uom := X_material_rec.detail_uom;
                 X_to_uom := G_other_std_um;
                 IF (p_ignore_mass_conv = FALSE) THEN
                   RAISE UOM_CONVERSION_ERROR;
                 ELSE
                   P_work_step_tbl(X_cur_rec).line_other_qty := 0;
                 END IF;
              ELSE
                P_work_step_tbl(X_cur_rec).line_other_qty := X_temp_qty;
                /* Bug 1683702 - Thomas Daniel */
                /* Apply the process loss to the qty for the calculation of the step qty */
                IF X_material_rec.line_type = -1 AND
                   X_material_rec.scale_type = 1 AND
                   p_process_loss > 0 THEN
                  P_work_step_tbl(X_cur_rec).line_other_qty := P_work_step_tbl(X_cur_rec).line_other_qty *
                                                              100 / (100 - p_process_loss);
                END IF;
              END IF;
            END IF; /* Condition that tests if other um type exists */

            EXIT; /* because the match in formulaline btw cursor and table type has occured */
         END IF; /* Condition when the formulaine in material_rec is same as that in
                    x_formulaline_scale_tab */
       END LOOP ; /* for the FOR formulaline in x_formulaline_scale_tab */

       /* K needs to be reset to zero */
       k := 0;

     END LOOP; /*For Cur_get_material_lines%FOUND*/
    END IF; /* if p_batch .. condition */
  END LOOP; /* FOR i IN 1..X_num_rows */

  IF X_cur_rec = 0 THEN
    RAISE NO_MATERIAL_STEP_ASSOC;
  END IF;

EXCEPTION
  WHEN UOM_CONVERSION_ERROR THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    OPEN Cur_get_item;
    FETCH Cur_get_item INTO X_item_no;
    CLOSE Cur_get_item;
    FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
    FND_MESSAGE.SET_TOKEN('FROM_UOM', X_from_uom);
    FND_MESSAGE.SET_TOKEN('TO_UOM', X_to_uom);
    FND_MSG_PUB.ADD;
  WHEN NO_MATERIAL_STEP_ASSOC THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_MATL_STEP_ASSOC');
    FND_MSG_PUB.ADD;
  WHEN COST_SCALING_ERROR THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD;
END get_step_material_lines;


/*======================================================================
--  FUNCTION :
--    get_step_rec
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for returning the row number
--    associated with the step.
--  REQUIREMENTS
--    p_step_tbl  non null value.
--  SYNOPSIS:
--    X_rec := get_step_rec (<routingstep_no>, X_step_tbl);
--
--  25Jul2001  L.R.Jackson  Reworked to have only one RETURN, and to
--               use WHILE instead of FOR.
--===================================================================== */

FUNCTION get_step_rec (P_step_no	IN NUMBER,
                       P_step_tbl	IN step_rec_tbl)
         RETURN NUMBER IS

  /* Local variables.
  ==================*/
  X_cur_rec	    NUMBER  := 1;
  X_num_rows    NUMBER  := 0;
  X_done        BOOLEAN := FALSE;

BEGIN
  WHILE (X_cur_rec <= P_step_tbl.COUNT) AND NOT X_done LOOP
    IF P_step_tbl(X_cur_rec).step_no = P_step_no THEN
      X_done := TRUE;
      X_num_rows := X_cur_rec;
    END IF;
    X_cur_rec := X_cur_rec + 1;
  END LOOP;
  RETURN (X_num_rows);
END get_step_rec;


/*======================================================================
--  PROCEDURE :
--    sort_step_lines
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for sorting the step table
--    based on the step no
--  REQUIREMENTS
--    p_step_tbl  non null value.
--  SYNOPSIS:
--    sort_step_lines (X_step_tbl);
--
-- 25Jul2001  L.R.Jackson  Added step_id to list of columns to move.
--              Moved this procedure up with others called by calc_step_qty
--===================================================================== */

PROCEDURE sort_step_lines (P_step_tbl	IN OUT NOCOPY step_rec_tbl,
                           P_return_status OUT NOCOPY VARCHAR2) IS
  /* Local variables.
  ==================*/
  X_step_id		NUMBER;
  X_step_no             NUMBER;
  X_step_qty            NUMBER;
  X_step_qty_uom        sy_uoms_mst.um_code%TYPE;
  X_step_mass_qty       NUMBER;
  X_step_vol_qty        NUMBER;
  X_step_other_qty       NUMBER;
  X_count               NUMBER;
BEGIN
  P_return_status := FND_API.G_RET_STS_SUCCESS;
  X_count := P_step_tbl.COUNT;
  FOR i IN 1..X_count LOOP
    FOR j IN i+1..X_count LOOP
      IF P_step_tbl(i).step_no > P_step_tbl(j).step_no THEN
        X_step_id       := P_step_tbl(i).step_id;
        X_step_no       := P_step_tbl(i).step_no;
        X_step_qty      := P_step_tbl(i).step_qty;
        X_step_qty_uom  := P_step_tbl(i).step_qty_uom;
        X_step_mass_qty := P_step_tbl(i).step_mass_qty;
        X_step_vol_qty  := P_step_tbl(i).step_vol_qty;
        X_step_other_qty  := P_step_tbl(i).step_other_qty;

        P_step_tbl(i).step_id       := P_step_tbl(j).step_id;
        P_step_tbl(i).step_no       := P_step_tbl(j).step_no;
        P_step_tbl(i).step_qty      := P_step_tbl(j).step_qty;
        P_step_tbl(i).step_qty_uom  := P_step_tbl(j).step_qty_uom;
        P_step_tbl(i).step_mass_qty := P_step_tbl(j).step_mass_qty;
        P_step_tbl(i).step_vol_qty  := P_step_tbl(j).step_vol_qty;
        P_step_tbl(i).step_other_qty  := P_step_tbl(j).step_other_qty;

        P_step_tbl(j).step_id       := X_step_id;
        P_step_tbl(j).step_no       := X_step_no;
        P_step_tbl(j).step_qty      := X_step_qty;
        P_step_tbl(j).step_qty_uom  := X_step_qty_uom;
        P_step_tbl(j).step_mass_qty := X_step_mass_qty;
        P_step_tbl(j).step_vol_qty  := X_step_vol_qty;
        P_step_tbl(j).step_other_qty  := X_step_other_qty;

      END IF;
    END LOOP; /* FOR j IN 1..X_count */
  END LOOP; /* FOR i IN 1..X_count */
EXCEPTION
  WHEN OTHERS THEN
     P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.ADD;
END sort_step_lines;


/*======================================================================
--  PROCEDURE :
--    check_step_qty_calculatable
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for checking whether the
--    automatic step quantity calculation can be performed.
--
--  REQUIREMENTS
--    p_parent_id  non null value.
--  SYNOPSIS:
--    check_step_qty_calculatable (426, X_msg_count, X_msg_stack,
--                             X_return_status);
--
--  This procedure calls GMICUOM.uom_conversion
--
--
--===================================================================== */

PROCEDURE check_step_qty_calculatable (P_check            IN  calculatable_rec_type,
    	                               P_msg_count        OUT NOCOPY NUMBER,
                                       P_msg_stack        OUT NOCOPY VARCHAR2,
                                       P_return_status    OUT NOCOPY VARCHAR2,
                                       P_ignore_mass_conv OUT NOCOPY BOOLEAN,
                                       P_ignore_vol_conv  OUT NOCOPY BOOLEAN,
				       P_organization_id  IN  NUMBER) IS
  /* Local variables.
  ==================*/
  X_exists	NUMBER(5);
  X_temp_qty	NUMBER;
  X_item_id	NUMBER;
  X_from_uom	mtl_units_of_measure.uom_code%TYPE;
  X_to_uom      mtl_units_of_measure.uom_code%TYPE;
  X_item_no	mtl_system_items_kfv.concatenated_segments%TYPE;

  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_recipe_details IS
    SELECT formula_id, routing_id
    FROM   gmd_recipes_b
    WHERE  recipe_id = P_check.parent_id;

  CURSOR Cur_get_rout_details (V_routing_id NUMBER) IS
    SELECT 1
    FROM   sys.dual
    WHERE EXISTS (SELECT 1
                  FROM   fm_rout_dtl
                  WHERE  routing_id = V_routing_id);

  -- p_formulaline_id would have a value if this procedure is called
  -- from cascade_del_to_step_mat.  From the formula details form, the delete of
  -- the formula line would not be committed yet.  Process the rest of
  -- the lines, not the line which is being deleted.
  CURSOR Cur_check_matl_lines_assoc (V_formula_id NUMBER) IS
    SELECT 1
    FROM   fm_matl_dtl
    WHERE  formula_id = V_formula_id
    AND    NVL(contribute_step_qty_ind, 'Y') = 'Y'
    AND    formulaline_id NOT IN (SELECT formulaline_id
                                  FROM   gmd_recipe_step_materials
                                  WHERE  recipe_id = P_check.parent_id)
    AND (P_check.formulaline_id IS NULL OR
               formulaline_id <> P_check.formulaline_id)
    ;

  CURSOR Cur_get_material_lines (V_formula_id NUMBER) IS
    SELECT d.qty, d.detail_uom, d.inventory_item_id
    FROM   fm_matl_dtl d
    WHERE  d.formula_id = V_formula_id
      AND    NVL(d.contribute_step_qty_ind, 'Y')  = 'Y'
      AND (P_check.formulaline_id IS NULL OR
                   formulaline_id <> P_check.formulaline_id)
    ;

  CURSOR Cur_get_item IS
    SELECT concatenated_segments
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = X_item_id;

  CURSOR Cur_get_std_um (V_uom_class VARCHAR2) IS
    SELECT uom_code
    FROM   mtl_units_of_measure
    WHERE  uom_class = V_uom_class;

  CURSOR Cur_chk_matrl_umtype(pformula_id NUMBER) IS
    SELECT COUNT(distinct uom_class)
     FROM  fm_matl_dtl d ,mtl_units_of_measure m
     WHERE d.detail_uom = m.uom_code
         AND d.formula_id = pformula_id
         AND NVL(d.contribute_step_qty_ind, 'Y')  = 'Y'
         AND (P_check.formulaline_id IS NULL OR
                   formulaline_id <> P_check.formulaline_id);

  CURSOR Cur_get_mtl_umtype(pformula_id NUMBER) IS
    SELECT distinct m.uom_class
     FROM  fm_matl_dtl d ,mtl_units_of_measure m
     WHERE d.detail_uom = m.uom_code
         AND d.formula_id = pformula_id
         AND NVL(d.contribute_step_qty_ind, 'Y')  = 'Y'
         AND (P_check.formulaline_id IS NULL OR
              formulaline_id <> P_check.formulaline_id);

  CURSOR Cur_check_depstps (prouting_id NUMBER) IS
    SELECT count(*)
    FROM  fm_rout_dtl h,fm_rout_dep d
    WHERE h.routing_id = prouting_id AND
          h.routing_id = d.routing_id;

  CURSOR Cur_get_umtyp_cnt(prouting_id NUMBER) IS
    SELECT count(distinct u.uom_class)
    FROM   fm_rout_dtl d,
           gmd_operations_b o,
           mtl_units_of_measure u
    WHERE  d.oprn_id = o.oprn_id
    AND    d.routing_id = prouting_id
    AND    o.process_qty_uom = u.uom_code;


  CURSOR Cur_get_process_umtyp(prouting_id NUMBER) IS
    SELECT distinct u.uom_class
    FROM   fm_rout_dtl d,
           gmd_operations_b o,
           mtl_units_of_measure u
    WHERE  d.oprn_id = o.oprn_id
    AND    d.routing_id = prouting_id
    AND    o.process_qty_uom = u.uom_code;


  /* Cursor records.
  =====================*/
  X_recipe_details_rec  Cur_get_recipe_details%ROWTYPE;
--  X_material_rec	Cur_get_material_lines%ROWTYPE;
  X_um_type             mtl_units_of_measure.uom_class%TYPE;
  X_count               NUMBER := 0;
  l_return_status	VARCHAR2(10);
  /* Exceptions.
  =====================*/
  NO_MATERIAL_STEP_ASSOC	EXCEPTION;
  NO_ROUTING_ASSOCIATED		EXCEPTION;
  ROUTING_DETAILS_MISSING	EXCEPTION;
  ALL_MTL_LINES_NOT_ASSOC  	EXCEPTION;
  UOM_CONVERSION_ERROR		EXCEPTION;
BEGIN
  P_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  /* If recipe id is null it implies that the material
     step association has not been done */
  IF P_check.parent_id IS NULL THEN
    RAISE NO_MATERIAL_STEP_ASSOC;
  END IF;

  GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id      => p_organization_id	,
				P_parm_name     => 'GMD_MASS_UM_TYPE'	,
				P_parm_value    => gmd_auto_step_calc.G_PROFILE_MASS_UM_TYPE	,
				X_return_status => l_return_status	);

  GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id      => p_organization_id	,
				P_parm_name     => 'GMD_VOLUME_UM_TYPE'	,
				P_parm_value    => gmd_auto_step_calc.G_PROFILE_VOLUME_UM_TYPE	,
				X_return_status => l_return_status	);

  OPEN Cur_get_recipe_details;
  FETCH Cur_get_recipe_details INTO X_recipe_details_rec;
  CLOSE Cur_get_recipe_details;

  /* Check whether a routing is associated with the recipe */
  IF X_recipe_details_rec.routing_id IS NULL THEN
    RAISE NO_ROUTING_ASSOCIATED;
  END IF;

  /* Check whether the routing has steps associated */
  OPEN Cur_get_rout_details (X_recipe_details_rec.routing_id);
  FETCH Cur_get_rout_details INTO X_exists;
  IF Cur_get_rout_details%NOTFOUND THEN
    CLOSE Cur_get_rout_details;
    RAISE ROUTING_DETAILS_MISSING;
  END IF;
  CLOSE Cur_get_rout_details;

  /* Check whether all the material lines where contribute-step-qty_ind = Y
     have been attached to a step */
  OPEN Cur_check_matl_lines_assoc (X_recipe_details_rec.formula_id);
  FETCH Cur_check_matl_lines_assoc INTO X_exists;
  IF Cur_check_matl_lines_assoc%FOUND THEN
    CLOSE Cur_check_matl_lines_assoc;
    RAISE ALL_MTL_LINES_NOT_ASSOC;
  END IF;
  CLOSE Cur_check_matl_lines_assoc;

  /* Populate the global std um variables. */
  OPEN Cur_get_std_um (G_profile_mass_um_type);
  FETCH Cur_get_std_um INTO G_mass_std_um;
  CLOSE Cur_get_std_um;

  OPEN Cur_get_std_um (G_profile_volume_um_type);
  FETCH Cur_get_std_um INTO G_vol_std_um;
  CLOSE Cur_get_std_um;


  -- Check if material lines are define in mass uom or Vol uom.
  -- Bug   2130655
  -- Bug # 2362814 Added by Shyam
  -- If x_count = 1 it is ok.
  OPEN Cur_chk_matrl_umtype(x_recipe_details_rec.formula_id);
  FETCH Cur_chk_matrl_umtype INTO x_count;
  CLOSE Cur_chk_matrl_umtype;

  IF (x_count = 1) THEN
    OPEN Cur_get_mtl_umtype(x_recipe_details_rec.formula_id);
    FETCH Cur_get_mtl_umtype INTO x_um_type;
    CLOSE Cur_get_mtl_umtype;

    IF (x_um_type = G_profile_mass_um_type) THEN
      p_ignore_vol_conv := TRUE;
    ELSIF (x_um_type = G_profile_volume_um_type) THEN
      p_ignore_mass_conv := TRUE;
    END IF;
  ELSIF(x_count > 1) THEN
    p_ignore_mass_conv := FALSE;
    p_ignore_vol_conv  := FALSE;
  END IF;

 IF (x_recipe_details_rec.routing_id IS NOT NULL) THEN
   OPEN Cur_get_umtyp_cnt(x_recipe_details_rec.routing_id);
   FETCH Cur_get_umtyp_cnt INTO x_count;
   CLOSE Cur_get_umtyp_cnt;

   /* if x_count is 1 then it could be MASS or VOL or some OTHER type */
   IF (x_count = 1) THEN
     OPEN Cur_get_process_umtyp(x_recipe_details_rec.routing_id);
     FETCH Cur_get_process_umtyp INTO x_um_type;
     CLOSE Cur_get_process_umtyp;
     IF (x_um_type = G_profile_mass_um_type) THEN
       p_ignore_vol_conv := TRUE;
     ELSIF (x_um_type = G_profile_volume_um_type) THEN
       p_ignore_mass_conv := TRUE;
     ELSE
      /* Get the other UOM type */
       G_PROFILE_OTHER_UM_TYPE := x_um_type;
     END IF;
   ELSIF(x_count > 1) THEN
     p_ignore_mass_conv := FALSE;
     p_ignore_vol_conv  := FALSE;
   END IF;
 END IF;

   -- End Bug 2130655.
   IF (G_PROFILE_OTHER_UM_TYPE IS NOT NULL) THEN
     OPEN Cur_get_std_um (G_PROFILE_OTHER_UM_TYPE);
     FETCH Cur_get_std_um INTO G_other_std_um;
     CLOSE Cur_get_std_um;
   END IF;

   /* Check whether all the material lines checked to be contributing
     to the step qty are convertible to the mass and volume uom types */
   FOR x_material_rec IN Cur_get_material_lines (X_recipe_details_rec.formula_id) LOOP

     IF (G_PROFILE_OTHER_UM_TYPE IS NULL) THEN
       X_temp_qty := INV_CONVERT.inv_um_convert(item_id        => X_material_rec.inventory_item_id
                                               ,precision      => 5
                                               ,from_quantity  => X_material_rec.qty
                                               ,from_unit      => X_material_rec.detail_uom
                                               ,to_unit        => G_mass_std_um
                                               ,from_name      => NULL
                                               ,to_name	       => NULL);
       IF X_temp_qty < 0 THEN
         X_item_id := X_material_rec.inventory_item_id;
         X_from_uom := X_material_rec.detail_uom;
         X_to_uom := G_mass_std_um;
         IF (p_ignore_mass_conv = FALSE) THEN
           RAISE UOM_CONVERSION_ERROR;
         END IF;
       END IF;
       X_temp_qty := INV_CONVERT.inv_um_convert(item_id         => X_material_rec.inventory_item_id
                                               ,precision      => 5
                                               ,from_quantity  => X_material_rec.qty
                                               ,from_unit      => X_material_rec.detail_uom
                                               ,to_unit        => G_vol_std_um
                                               ,from_name      => NULL
                                               ,to_name	       => NULL);

       IF X_temp_qty < 0 THEN
         X_item_id := X_material_rec.inventory_item_id;
         X_from_uom := X_material_rec.detail_uom;
         X_to_uom := G_vol_std_um;
         IF (p_ignore_vol_conv = FALSE) THEN
           RAISE UOM_CONVERSION_ERROR;
         END IF;
       END IF;
     ELSE /* IF the um type is of other type */
       X_temp_qty := INV_CONVERT.inv_um_convert(item_id        => X_material_rec.inventory_item_id
                                               ,precision      => 5
                                               ,from_quantity  => X_material_rec.qty
                                               ,from_unit      => X_material_rec.detail_uom
                                               ,to_unit        => G_other_std_um
                                               ,from_name      => NULL
                                               ,to_name	       => NULL);
       IF X_temp_qty < 0 THEN
         X_item_id := X_material_rec.inventory_item_id;
         X_from_uom := X_material_rec.detail_uom;
         X_to_uom := G_other_std_um;
         RAISE UOM_CONVERSION_ERROR;
       END IF;
     END IF;

   END LOOP;
EXCEPTION
  WHEN NO_ROUTING_ASSOCIATED THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_AUTO_STEP_QTY_NEEDS_ROUT');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                               P_data  => P_msg_stack);
  WHEN ROUTING_DETAILS_MISSING THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'FMROUTINGSTEPNOTFOUND');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                               P_data  => P_msg_stack);
  WHEN  NO_MATERIAL_STEP_ASSOC THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    --  debug line p_return_status := 'Z';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_MATL_STEP_ASSOC');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                               P_data  => P_msg_stack);
  WHEN ALL_MTL_LINES_NOT_ASSOC THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    --  debug line p_return_status := 'Y';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_ALL_MATL_STEP_NOT_ASSOC');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                               P_data  => P_msg_stack);
  WHEN UOM_CONVERSION_ERROR THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    OPEN Cur_get_item;
    FETCH Cur_get_item INTO X_item_no;
    CLOSE Cur_get_item;
    FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
    FND_MESSAGE.SET_TOKEN('FROM_UOM', X_from_uom);
    FND_MESSAGE.SET_TOKEN('TO_UOM', X_to_uom);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
  WHEN OTHERS THEN
     P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_message.set_name('GMD',SQLERRM);
     fnd_msg_pub.add;
     FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                P_data  => P_msg_stack);
END check_step_qty_calculatable;


/*****************************************************
--  PROCEDURE :
--    check_del_from_step_mat
--
--  DESCRIPTION:
--    This PL/SQL procedure accepts a formulaline_id or routingstep_id
--    which is being deleted from the formula material table or routing detail
--    table, respectively.  It returns the recipe id's affected by the deleted,
--
--    This procedure is called by the forms, to tell the user what the scope of
--    their delete is, and to ask if they wish to continue.  If they answer YES,
--    then cascade_del_to_step_mat procedure is called, which does the actual
--    delete from the step/mat assoc table and recalc's step qty's if necessary.
--
--  REQUIREMENTS
--    p_check record  non null value. (recipe, formulaline or routingstep, WHO)
--
--  SYNOPSIS:
--    check_del_from_step_mat (p_check, X_return_status);
--
--  Procedures used:  none

--
--  HISTORY
--  02Aug2001  L.R.Jackson  Bug 1856832.  Created

************************************************************************/
PROCEDURE check_del_from_step_mat(P_check          IN calculatable_rec_type,
                                  P_recipe_tbl     OUT NOCOPY recipe_id_tbl,
                                  P_check_step_mat OUT NOCOPY check_step_mat_type,
                                  P_msg_count      OUT NOCOPY NUMBER,
                                  P_msg_stack      OUT NOCOPY VARCHAR2,
                                  P_return_status  OUT NOCOPY VARCHAR2
                                 )  IS

CURSOR Cur_get_step_mat_recipes (p_formulaline_id NUMBER, p_routingstep_id NUMBER) IS
      SELECT m.recipe_id,
             r.recipe_status
      FROM   gmd_recipe_step_materials m,
             gmd_recipes_b r,
             gmd_status_b s
      WHERE  s.status_code    = r.recipe_status
        AND  r.recipe_id      = m.recipe_id
        AND  ((p_formulaline_id is not null and m.formulaline_id = P_formulaline_id)
               OR
               (p_routingstep_id is not null and m.routingstep_id = P_routingstep_id))
        AND  r.calculate_step_quantity > 0
        AND  s.status_type   <> 1000
        AND  r.delete_mark    = 0;

x_recipe_cntr   NUMBER := 0;

BEGIN
  P_return_status := FND_API.G_RET_STS_SUCCESS;
    -- 1. Get a list of recipes where this formulaline exists in step/mat association,
    --    and where calculate_step_qty flag IS set (ASQC=Yes)
    --    and where delete_mark is NOT set
    --    and the recipe is NOT marked obsolete.
    -- 2. Count the recipes in step/mat rows where this formulaline exists (regardless of ASQC flag).

  FOR get_recipe_id IN cur_get_step_mat_recipes (p_check.formulaline_id, p_check.routingstep_id)
          LOOP
    x_recipe_cntr := x_recipe_cntr + 1;
    p_recipe_tbl(x_recipe_cntr) := get_recipe_id.recipe_id;
  END LOOP;

  P_check_step_mat.ASQC_RECIPES  := x_recipe_cntr;

  SELECT COUNT(unique recipe_id) into P_check_step_mat.STEP_ASSOC_RECIPES
    FROM   gmd_recipe_step_materials
   WHERE  (P_check.formulaline_id is not null AND formulaline_id = P_check.formulaline_id)
             OR
          (p_check.routingstep_id is not null AND routingstep_id = P_check.routingstep_id) ;

EXCEPTION
   WHEN OTHERS THEN
          -- It is OK if no rows are found in step/mat table.
          -- This exception is for database errors
        P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                   P_data  => P_msg_stack);
END check_del_from_step_mat;



/*****************************************************
--  PROCEDURE :
--    cascade_del_to_step_mat
--
--  DESCRIPTION:
--    This PL/SQL procedure accepts a formulaline_id or routingstep_id
--    which is being deleted from the formula material table or routing detail
--    table, respectively.  The formualine_id or routingstep_id is deleted from
--    GMD_RECIPE_STEP_MATERIALS.  Then, if ASQC flag = yes, step qty's are
--    recalculated.
--
--  REQUIREMENTS
--    Calling program must first call check_del_from_step_mat.
--    p_check record  non null value. (recipe, formulaline or routingstep, WHO)
--    If formulaline_id is being deleted, routingstep_id parameter must be null
--
--  SYNOPSIS:
--    cascade_del_to_step_mat (p_check, X_return_status);
--
--  Procedures used:  gmd_auto_step_calc.check_step_qty_calculatable
--                    gmd_auto_step_calc.calc_step_qty
--                    gmd_recipe_detail.recipe_routing_steps
--
--  HISTORY
--  25Jul2001  L.R.Jackson  Bug 1856832.  Created
--  Sukarna Reddy Dt 03/14/02. Bug 2130655. p_ignore_mass_conv
--   and p_ignore_vol_conv will not be passed as parameter.
************************************************************/

PROCEDURE cascade_del_to_step_mat(P_check          IN calculatable_rec_type,
                                  P_recipe_tbl     IN recipe_id_tbl,
                                  P_check_step_mat IN check_step_mat_type,
                                  P_msg_count      OUT NOCOPY NUMBER,
                                  P_msg_stack      OUT NOCOPY VARCHAR2,
                                  P_return_status  OUT NOCOPY VARCHAR2,
                                  P_organization_id IN NUMBER)  IS

x_recipe_cntr       NUMBER := 0;
x_step_cntr         NUMBER := 0;
X_step_tbl	        gmd_auto_step_calc.step_rec_tbl;
X_all_steps_tbl     gmd_recipe_detail.recipe_detail_tbl;
x_flex              gmd_recipe_detail.recipe_flex;
x_update_flex       gmd_recipe_detail.recipe_update_flex;
x_check_out         gmd_auto_step_calc.calculatable_rec_type;
debug_msg           EXCEPTION;    -- used in debugging
x_ignore_mass_conv BOOLEAN;
x_ignore_vol_conv  BOOLEAN;
ALL_MTL_LINES_NOT_ASSOC  	EXCEPTION;

BEGIN
  P_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Calling program should delete from fm_matl_dtl.
    --    DELETE  FROM   fm_matl_dtl WHERE  formulaline_id = P_formulaline_id;
    -- 1. Use gmd_auto_step_calc.check_del_from_step_mat to get a list of recipes where
    --       this formulaline exists in step/mat association,
    --    and where calculate_step_qty flag IS set (ASQC=Yes)
    --    and where delete_mark is NOT set
    --    and the recipe is NOT marked obsolete.
    -- check_del_from_step_mat will also count if there are any step/mat associations which
    --    need to be deleted.
    -- 2. Delete the step/mat rows where this formulaline exists (regardless of ASQC flag).
    -- 3. Recalculate step qty's in the recipes in the list.

    -- debug dbms_output.put_line('Value of v_formulaline_id='||P_check_in.formulaline_id||' **********************************');

  -- If there are any step/mat lines using this formulaline or routingstep, delete them.
  -- Then, if any of the recipes involved need the step qty's re calculated (id's would be in
  --   p_recipe_tbl) then recalc.
  -- By definition, if a routingstep is being deleted and there were step associations, now
  --   there will be items with no association to a step (the step which is being deleted).
  -- ***********************************************************************************
  -- For the next version, check if formulaline's which would go away because a routing step
  -- is deleted actually ARE marked as contributing-to-step-qty.  If not, then asqc can be
  -- recalc'ed.
  IF P_check_step_mat.STEP_ASSOC_RECIPES > 0 THEN
    DELETE FROM   gmd_recipe_step_materials
     WHERE  (P_check.formulaline_id is not null AND formulaline_id = P_check.formulaline_id)
             OR
            (p_check.routingstep_id is not null AND routingstep_id = P_check.routingstep_id) ;


    /* Commented the code below by Shyam */
    /* We need not perform the ASQC recalculation and update the GMD Recipe
       step table because if the ASQC flag is ON then the values are not saved
       in the db or the GMD Recipe Steps table.  Each time the Recipes form
       open if the ASQC flag is ON then it performs the recalculation */

    IF p_check.routingstep_id is not null THEN
       -- save what has been done so far and go to end.  Put message on stack.
       IF (P_check_step_mat.ASQC_RECIPES > 0) THEN
           RAISE ALL_MTL_LINES_NOT_ASSOC;
       ELSE
           DELETE FROM gmd_recipe_routing_steps
           WHERE  (p_check.routingstep_id is not null
                   AND routingstep_id = P_check.routingstep_id);
       END IF;
    END IF;   -- end if routingstep is being deleted.

    /*
    FOR x_recipe_cntr in 1..P_recipe_tbl.COUNT LOOP
        -- debug dbms_output.put_line('call asqc to recalculate here. Give user a message. recipe_id '|| x_recipe_tbl(x_recipe_cntr) );
      x_check_out := p_check;
      x_check_out.parent_id := P_recipe_tbl(x_recipe_cntr);
      gmd_auto_step_calc.check_step_qty_calculatable
                                     (p_check         => x_check_out,
                                      p_msg_count     => P_msg_count,
                                      p_msg_stack     => P_msg_stack,
                                      p_return_status => P_return_status,
                                      P_ignore_mass_conv => x_ignore_mass_conv,
                                      P_ignore_vol_conv => x_ignore_vol_conv,
				      P_organization_id => P_organization_id);

      -- debug dbms_output.put_line('status from calculatable is ' || p_return_status);
      IF p_return_status = 'S' THEN
        gmd_auto_step_calc.calc_step_qty(p_parent_id     => P_recipe_tbl(x_recipe_cntr),
                                         p_step_tbl      => X_step_tbl,
                                         p_msg_count     => P_msg_count,
                                         p_msg_stack     => P_msg_stack,
                                         p_return_status => p_return_status,
					 P_organization_id => P_organization_id);
      END IF;
      -- Check_step_qty_calculatable and Calc_step_qty put their own messages on the stack.

      IF p_return_status = 'S' THEN
        -- debug  dbms_output.put_line('Value of X_step_tbl.COUNT='||X_step_tbl.COUNT);
        -- debug  dbms_output.put_line('After calc Value of p_return_status= *'||p_return_status ||'*');

      -- We are in a loop for every recipe where ASQC=Yes.  If ASQC was succussful,
      --   for each step returned in the step table, put the results in a holding table.
      --   This holding table will be sent to the recipe_details pkg for update (maybe insert)
      --   of the gmd_recipe_routing_steps table.
      -- Counter is only initialized at top of procedure.
        FOR asqc_cntr in 1..X_step_tbl.COUNT LOOP
          x_step_cntr := x_step_cntr + 1;
          X_all_steps_tbl(x_step_cntr).recipe_id         := P_recipe_tbl(x_recipe_cntr);
          X_all_steps_tbl(x_step_cntr).routingstep_id    := X_step_tbl(asqc_cntr).step_id;
          X_all_steps_tbl(x_step_cntr).step_qty          := X_step_tbl(asqc_cntr).step_qty;
          X_all_steps_tbl(x_step_cntr).mass_qty          := X_step_tbl(asqc_cntr).step_mass_qty;
          X_all_steps_tbl(x_step_cntr).mass_ref_uom      := X_step_tbl(asqc_cntr).step_mass_uom;
          X_all_steps_tbl(x_step_cntr).volume_qty        := X_step_tbl(asqc_cntr).step_vol_qty;
          X_all_steps_tbl(x_step_cntr).volume_ref_uom    := X_step_tbl(asqc_cntr).step_vol_uom;
          X_all_steps_tbl(x_step_cntr).creation_date     := P_check.creation_date;
          X_all_steps_tbl(x_step_cntr).created_by        := P_check.created_by;
          X_all_steps_tbl(x_step_cntr).last_update_date  := P_check.last_update_date;
          X_all_steps_tbl(x_step_cntr).last_updated_by   := P_check.last_updated_by;
          X_all_steps_tbl(x_step_cntr).last_update_login := P_check.last_update_login;
        END LOOP;
      END IF;    -- end if return status from calc_step_qty = S
    END LOOP;    -- end loop for each recipe which had the given formulaline or routing
                 --   in the step/material association

    -- After everything has been calculated, update step qty's in gmd_recipe_routing_steps.
    IF p_return_status = 'S' THEN
      gmd_recipe_detail.recipe_routing_steps
                                   (p_api_version        => 1.1,
                                    p_init_msg_list      => 'F',
                                    p_commit             => 'F',
                                    p_called_from_forms  => 'NO',
                                    x_return_status      => p_return_status,
                                    x_msg_count          => P_msg_count,
                                    x_msg_data           => P_msg_stack,
                                    p_recipe_detail_tbl  => X_all_steps_tbl,
                                    p_recipe_insert_flex => x_flex,
                                    p_recipe_update_flex => x_update_flex
                                   );

    END IF;  -- end if calc_step was successful

    */
  END IF;    -- end if there are any recipes affected by the formulaline or routingstep delete

  EXCEPTION
    WHEN debug_msg THEN
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                     P_data  => P_msg_stack);
          -- debug dbms_output.put_line ('in exception ' || p_return_status);

    WHEN ALL_MTL_LINES_NOT_ASSOC THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_ALL_MATL_STEP_NOT_ASSOC');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                               P_data  => P_msg_stack);
    WHEN OTHERS THEN
          -- It is OK if no rows are found in step/mat table.
          -- The 3 procedures called have their own error handling.
        P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_AND_GET (P_count => P_msg_count,
                                   P_data  => P_msg_stack);
  END cascade_del_to_step_mat;


/*****************************************************
--  PROCEDURE :
--    check_Bch_stp_qty_calculatable
--
--  DESCRIPTION:
--    Handles the UOM type conversion
--
--  HISTORY
--  26-06-06  Kapil M  Created the procedure for bug# 5347857.
--  08-08-06  Kapil M  Replaced sy_uoms_mst with mtl_units_of_measure
**************************************************************/

PROCEDURE check_Bch_stp_qty_calculatable (P_check            IN  calculatable_rec_type,
                                        P_ignore_mass_conv OUT NOCOPY BOOLEAN,
                                        P_ignore_vol_conv  OUT NOCOPY BOOLEAN) IS

  /* Cursor Definitions.
  =====================*/
  CURSOR Cur_get_recipe_details IS
    SELECT formula_id, routing_id
    FROM   GME_BATCH_HEADER
    WHERE  BATCH_ID = P_check.parent_id;


  CURSOR Cur_get_std_um (V_um_type VARCHAR2) IS
    SELECT UOM_CODE
    FROM   mtl_units_of_measure
    WHERE  uom_class = V_um_type
    AND BASE_UOM_FLAG = 'Y';

  CURSOR Cur_chk_matrl_umtype(pformula_id NUMBER) IS
    SELECT COUNT(distinct m.uom_class)
     FROM  fm_matl_dtl d ,mtl_units_of_measure m
     WHERE d.DETAIL_UOM = m.uom_code
         AND d.formula_id = pformula_id
         AND NVL(d.contribute_step_qty_ind, 'Y')  = 'Y'
         AND (P_check.formulaline_id IS NULL OR
                   formulaline_id <> P_check.formulaline_id);

  CURSOR Cur_get_mtl_umtype(pformula_id NUMBER) IS
    SELECT distinct m.uom_class
     FROM  fm_matl_dtl d ,mtl_units_of_measure m
     WHERE d.DETAIL_UOM= m.uom_code
         AND d.formula_id = pformula_id
         AND NVL(d.contribute_step_qty_ind, 'Y')  = 'Y'
         AND (P_check.formulaline_id IS NULL OR
              formulaline_id <> P_check.formulaline_id);

  CURSOR Cur_get_umtyp_cnt(prouting_id NUMBER) IS
    SELECT count(distinct u.uom_class)
    FROM   fm_rout_dtl d,
           gmd_operations_b o,
           mtl_units_of_measure u
    WHERE  d.oprn_id = o.oprn_id
    AND    d.routing_id = prouting_id
    AND    o.process_qty_uom = u.uom_code;

  CURSOR Cur_get_process_umtyp(prouting_id NUMBER) IS
    SELECT distinct u.uom_class
    FROM   fm_rout_dtl d,
           gmd_operations_b o,
           mtl_units_of_measure u
    WHERE  d.oprn_id = o.oprn_id
    AND    d.routing_id = prouting_id
    AND    o.process_qty_uom = u.uom_code;


  /* Cursor records.
  =====================*/
  X_recipe_details_rec  Cur_get_recipe_details%ROWTYPE;
  X_um_type             sy_uoms_typ.um_type%TYPE;
  X_count               NUMBER := 0;
  /* Exceptions.
  =====================*/
  NO_MATERIAL_STEP_ASSOC	EXCEPTION;
  NO_ROUTING_ASSOCIATED		EXCEPTION;
BEGIN

  OPEN Cur_get_recipe_details;
  FETCH Cur_get_recipe_details INTO X_recipe_details_rec;
  CLOSE Cur_get_recipe_details;

  /* Check whether all the material lines where contribute-step-qty_ind = Y
     have been attached to a step */

  /* Populate the global std um variables. */
  OPEN Cur_get_std_um (G_profile_mass_um_type);
  FETCH Cur_get_std_um INTO G_mass_std_um;
  CLOSE Cur_get_std_um;

  OPEN Cur_get_std_um (G_profile_volume_um_type);
  FETCH Cur_get_std_um INTO G_vol_std_um;
  CLOSE Cur_get_std_um;

  -- Check if material lines are define in mass uom or Vol uom.
  -- Bug   2130655
  -- Bug # 2362814 Added by Shyam
  -- If x_count = 1 it is ok.
  OPEN Cur_chk_matrl_umtype(x_recipe_details_rec.formula_id);
  FETCH Cur_chk_matrl_umtype INTO x_count;
  CLOSE Cur_chk_matrl_umtype;
  IF (x_count = 1) THEN
    OPEN Cur_get_mtl_umtype(x_recipe_details_rec.formula_id);
    FETCH Cur_get_mtl_umtype INTO x_um_type;
    CLOSE Cur_get_mtl_umtype;
    IF (x_um_type = G_profile_mass_um_type) THEN
      p_ignore_vol_conv := TRUE;
    ELSIF (x_um_type = G_profile_volume_um_type) THEN
      p_ignore_mass_conv := TRUE;
    END IF;
  ELSIF(x_count > 1) THEN
    p_ignore_mass_conv := FALSE;
    p_ignore_vol_conv  := FALSE;
    return;
  END IF;

 IF (x_recipe_details_rec.routing_id IS NOT NULL) THEN
   OPEN Cur_get_umtyp_cnt(x_recipe_details_rec.routing_id);
   FETCH Cur_get_umtyp_cnt INTO x_count;
   CLOSE Cur_get_umtyp_cnt;
   /* if x_count is 1 then it could be MASS or VOL or some OTHER type */
   IF (x_count = 1) THEN
     OPEN Cur_get_process_umtyp(x_recipe_details_rec.routing_id);
     FETCH Cur_get_process_umtyp INTO x_um_type;
     CLOSE Cur_get_process_umtyp;
     IF (x_um_type = G_profile_mass_um_type) THEN
       p_ignore_vol_conv := TRUE;
     ELSIF (x_um_type = G_profile_volume_um_type) THEN
       p_ignore_mass_conv := TRUE;
     ELSE
      /* Get the other UOM type */
       G_PROFILE_OTHER_UM_TYPE := x_um_type;
     END IF;
   ELSIF(x_count > 1) THEN
     p_ignore_mass_conv := FALSE;
     p_ignore_vol_conv  := FALSE;
     return;
   END IF;
 END IF;

   -- End Bug 2130655.
   IF (G_PROFILE_OTHER_UM_TYPE IS NOT NULL) THEN
     OPEN Cur_get_std_um (G_PROFILE_OTHER_UM_TYPE);
     FETCH Cur_get_std_um INTO G_other_std_um;
     CLOSE Cur_get_std_um;
   END IF;


EXCEPTION
  WHEN OTHERS THEN
     p_ignore_mass_conv := FALSE;
     p_ignore_vol_conv  := FALSE;
END check_Bch_stp_qty_calculatable;


END GMD_AUTO_STEP_CALC;

/
