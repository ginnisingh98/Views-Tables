--------------------------------------------------------
--  DDL for Package Body GMD_VALIDITY_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_VALIDITY_RULES" AS
/* $Header: GMDPRVRB.pls 120.14.12010000.2 2009/11/06 07:14:39 kannavar ship $ */

G_PKG_NAME VARCHAR2(32);
G_default_cost_mthd VARCHAR2(20);
G_cost_source_orgn_id NUMBER(15);
G_cost_source BINARY_INTEGER;

/*======================================================================
--  PROCEDURE :
--   get_validity_rules
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    validity rules based on the input parameters.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_validity_rules (1.0, X_init_msg_list, X_recipe_id, X_item_id,
--                        X_orgn_code, X_product_qty, X_uom, X_recipe_use,
--                        X_total_input, X_total_output, X_status,
--                        X_return_status, X_msg_count, X_msg_data,
--                        X_return_code, X_vr_table);
--
--
--===================================================================== */

PROCEDURE get_validity_rules(p_api_version         IN  NUMBER                           ,
                             p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE      ,
                             p_recipe_no           IN  VARCHAR2 := NULL                 ,
                             p_recipe_version      IN  NUMBER   := NULL                 ,
                             p_recipe_id           IN  NUMBER   := NULL                 ,
                             p_total_input         IN  NUMBER   := NULL                 ,
                             p_total_output        IN  NUMBER   := NULL                 ,
                             p_formula_id          IN  NUMBER   := NULL                 ,
                             p_item_id             IN  NUMBER   := NULL                 ,
                             p_revision            IN  VARCHAR2 := NULL                 ,
                             p_item_no             IN  VARCHAR2 := NULL                 ,
                             p_product_qty         IN  NUMBER   := NULL                 ,
                             p_uom                 IN  VARCHAR2 := NULL                 ,
                             p_recipe_use          IN  VARCHAR2 := NULL                 ,
                             p_orgn_code           IN  VARCHAR2 := NULL                 ,
                             p_organization_id     IN  NUMBER   := NULL                	,
     			     p_least_cost_validity IN  VARCHAR2 := 'F'			,
                             p_start_date          IN  DATE     := NULL                 ,
                             p_end_date            IN  DATE     := NULL                 ,
                             p_status_type         IN  VARCHAR2 := NULL                 ,
                             p_validity_rule_id    IN  NUMBER   := NULL                 ,
                             x_return_status       OUT NOCOPY VARCHAR2                  ,
                             x_msg_count           OUT NOCOPY NUMBER                    ,
                             x_msg_data            OUT NOCOPY VARCHAR2                  ,
                             x_return_code         OUT NOCOPY NUMBER                    ,
                             X_recipe_validity_out OUT NOCOPY recipe_validity_tbl) IS

  --  local Variables
  l_api_name           VARCHAR2(30) := 'get_validity_rules';
  l_api_version        NUMBER       := 1.0;
  i                    NUMBER       := 0;
  l_uom                VARCHAR2(4);

  l_item_uom           VARCHAR2(4);
  l_line_um            VARCHAR2(4);
  l_quantity           NUMBER;
  l_item_qty           NUMBER;
  l_scale_type         NUMBER;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(100);
  l_return_code        VARCHAR2(10);
  l_yield_um           VARCHAR2(4);
  l_formula_id         NUMBER;
  l_formula_output     NUMBER;
  l_formula_input      NUMBER;
  l_total_output       NUMBER;
  l_total_input        NUMBER;
  l_output_ratio       NUMBER;
  l_ingred_prod_ratio  NUMBER;
  l_batchformula_ratio NUMBER;
  l_contributing_qty   NUMBER;

   -- Bug 3818835
   l_qty       NUMBER;
   l_form_qty  NUMBER;
   l_prod_id   NUMBER;
   l_prod_uom  VARCHAR2(4);

   l_uom_class VARCHAR2(25);

  /* Cursor to get data based on recipe ID and input and output qty. */
  CURSOR get_val IS
    SELECT v.*
    FROM   gmd_recipe_validity_rules v, gmd_recipes r, gmd_status s
    WHERE   v.recipe_id = r.recipe_id
           AND v.validity_rule_status = s.status_code
           AND  v.recipe_id = NVL(P_RECIPE_ID, v.recipe_id)
           AND ( r.recipe_no = NVL(p_recipe_no, r.recipe_no) AND r.recipe_version = nvl(p_recipe_version, r.recipe_version) )
           AND r.formula_id = NVL(p_formula_id, r.formula_id)
	   AND ( (p_status_type IS NULL AND  s.status_type IN ( '700', '900'))
				OR (p_status_type IS  NOT NULL AND s.status_type = p_status_type) )
           AND v.recipe_use IN (0,p_recipe_use)
           AND ((v.organization_id = NVL(p_organization_id,v.organization_id))
	   OR (v.organization_id IS NULL) )
           /* Bug 2690833 - Thomas Daniel */
           /* Modified the following start and end date condtions to ensure that the date */
           /* range validation is done properly */
           AND ( (p_start_date IS NULL) or
                 ((start_date) <= (p_start_date) AND
                  (NVL(end_date, p_start_date)) >= (p_start_date)
                 )
               )
           AND ( (p_end_date IS NULL) OR
                  ((NVL(end_date,p_end_date)) >= (P_end_date) AND
                   (start_date) <= (p_end_date))
                )
           AND (p_validity_rule_id IS NULL OR
                 (p_validity_rule_id IS NOT NULL AND v.recipe_validity_rule_id = p_validity_rule_id))
           AND v.delete_mark = 0
     ORDER BY orgn_code,preference, recipe_use, s.status_type ;

  /* Cursor to get data based on item. */
  CURSOR get_val_item(l_quantity NUMBER) IS
    SELECT v.*
    FROM   gmd_recipe_validity_rules v, gmd_recipes_b r, gmd_status_b s,
           mtl_system_items_kfv I, fm_matl_dtl d
    WHERE  v.recipe_id = r.recipe_id
           AND v.validity_rule_status = s.status_code
           AND i.inventory_item_id = v.inventory_item_id
           AND r.owner_organization_id = i.organization_id
           AND (v.inventory_item_id = p_item_id or i.concatenated_segments = p_item_no)
           AND (p_revision IS NULL OR (p_revision IS NOT NULL AND v.revision = p_revision))
	   AND (r.formula_id = NVL(p_formula_id, r.formula_id))
           AND (inv_min_qty <= nvl(l_quantity,inv_min_qty) AND inv_max_qty >= 	nvl(l_quantity,inv_max_qty))
           AND ((p_status_type is NULL)  AND  (s.status_type IN ( '700', '900'))
		OR ( p_status_type is  NOT NULL AND s.status_type = p_status_type))
	   AND v.recipe_use IN (0,p_recipe_use)
	   AND ((v.organization_id = NVL(p_organization_id,v.organization_id))
	        or (v.organization_id IS NULL) )
           AND ( (p_start_date IS NULL) or
	       ((start_date) <= (p_start_date) AND
	       (NVL(end_date, p_start_date)) >= (p_start_date)
	       )
	       )
	   AND ( (p_end_date IS NULL) OR
	      ((NVL(end_date,p_end_date)) >= (P_end_date) AND
	       (start_date) <= (p_end_date))
	       )
	   AND (p_validity_rule_id IS NULL OR
	       (p_validity_rule_id IS NOT NULL AND v.recipe_validity_rule_id =
        	p_validity_rule_id))
	   AND v.delete_mark = 0
	   AND d.formula_id = r.formula_id
	   AND v.inventory_item_id = d.inventory_item_id
           AND (p_revision IS NULL OR (p_revision IS NOT NULL AND d.revision = p_revision))
           AND d.line_type = 1
    ORDER BY orgn_code,preference, recipe_use, s.status_type ;

  l_item_id  NUMBER;

  CURSOR get_item_id(p_item_no VARCHAR2) IS
    SELECT inventory_item_id
    FROM   mtl_system_items_kfv
    WHERE  concatenated_segments = p_item_no;

  -- NPD Conv.
  CURSOR cur_item_uom(p_item_id NUMBER) IS
    SELECT primary_uom_code
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = p_item_id;

  -- NPD Conv.
  CURSOR Cur_std_um (p_uom_class VARCHAR2) IS
    SELECT uom_code
    FROM   mtl_units_of_measure
    WHERE  uom_class = p_uom_class
    AND    base_uom_flag = 'Y';

  -- NPD Conv.
  CURSOR Cur_get_qty(V_item_id NUMBER) IS
    SELECT qty, scale_type, detail_uom
    FROM   fm_matl_dtl
    WHERE  formula_id = l_formula_id
           AND inventory_item_id = V_item_id
           AND line_type = 1
    ORDER BY line_no;


  CURSOR Cur_get_recipe (V_recipe_no VARCHAR2, V_recipe_vers NUMBER) IS
    SELECT recipe_id
    FROM   gmd_recipes_b
    WHERE  recipe_no = V_recipe_no
    AND    recipe_version = V_recipe_vers;

  CURSOR Cur_get_orgn_code IS
    SELECT organization_code
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

  CURSOR Cur_get_VR IS
    SELECT *
    FROM GMD_VAL_RULE_GTMP;

  CURSOR get_form_prod(l_formula_id NUMBER) IS
    SELECT inventory_item_id, qty, detail_uom
    FROM   fm_matl_dtl
    WHERE  formula_id = l_formula_id
           AND line_type = 1
           AND line_no = 1;

  CURSOR Cur_get_formula (V_recipe_id NUMBER) IS
    SELECT formula_id
    FROM   gmd_recipes_b
    WHERE  recipe_id = V_recipe_id;


  /* Exceptions */
  NO_YIELD_TYPE_UM           EXCEPTION;
  GET_FORMULA_ERR            EXCEPTION;
  GET_TOTAL_QTY_ERR          EXCEPTION;
  GET_OUTPUT_RATIO_ERR       EXCEPTION;
  GET_INGREDPROD_RATIO_ERR   EXCEPTION;
  GET_BATCHFORMULA_RATIO_ERR EXCEPTION;
  GET_CONTRIBUTING_QTY_ERR   EXCEPTION;
  GET_INPUT_RATIO_ERR        EXCEPTION;
  ITEM_UOM_CONV_ERR          EXCEPTION;
  UOM_CONVERSION_ERROR       EXCEPTION;
  ITEM_ORGN_MISSING          EXCEPTION;
  ITEM_NOT_FOUND_ERROR       EXCEPTION;
  GET_FORMULA_COST_ERR       EXCEPTION;

  l_recipe_id              NUMBER;
  l_orgn_code		   VARCHAR2(3);
  l_total_cost	   	   NUMBER;
  l_unit_cost		   NUMBER;
  l_return_status	   VARCHAR2(10);
  l_form_id		   NUMBER;

BEGIN
  IF (NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;
  X_return_status := FND_API.G_RET_STS_SUCCESS;

/* Bug No.6346013 - Start */

  /* Delete from this table for any existing data */
  DELETE FROM GMD_VAL_RULE_GTMP;

/* Bug No.6346013 - End */

  -- NPD Convergence. Get FM_YIELD_TYPE profile value for the organization.
  GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id    => p_organization_id,
                                P_parm_name  => 'FM_YIELD_TYPE',
                                P_parm_value => l_uom_class,
				x_return_status => l_return_status);
  /* Get yield type um */
  OPEN Cur_std_um (l_uom_class);
  FETCH Cur_std_um INTO l_yield_um;
  IF (Cur_std_um%NOTFOUND) THEN
    CLOSE Cur_std_um;
    RAISE NO_YIELD_TYPE_UM;
  END IF;
  CLOSE Cur_std_um;

  IF p_recipe_id IS NULL THEN
    IF p_recipe_no IS NOT NULL AND
       p_recipe_version IS NOT NULL THEN
      OPEN Cur_get_recipe (p_recipe_no, p_recipe_version);
      FETCH Cur_get_recipe INTO l_recipe_id;
      CLOSE Cur_get_recipe;
    END IF;
  ELSE
    l_recipe_id := p_recipe_id;
  END IF;

  /* Check for possible ways to get validity rules */
  IF (l_recipe_id IS NOT NULL AND p_total_output IS NOT NULL OR
      l_recipe_id IS NOT NULL AND p_total_input IS NOT NULL) THEN
    /* Get the formula for this recipe */
    OPEN Cur_get_formula (l_recipe_id);
    FETCH Cur_get_formula INTO l_formula_id;
    CLOSE Cur_get_formula;

    -- S.Dulyk 1/8/02 added b/c calculate_total_qty wouldn't use p_uom
    l_uom := p_uom;
    gmd_common_val.calculate_total_qty(formula_id       => l_formula_id,
                                       x_product_qty    => l_formula_output,
                                       x_ingredient_qty => l_formula_input,
                                       x_uom            => l_uom,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data    );
    /*Bug 2962277 - Thomas Daniel */
    /*The return status can be 'Q' from the above call for two reasons either */
    /*the total input qty was not calculatable or the total output qty is not */
    /*calculatable, we need to see the mode in which this procedure was invoked */
    /*to determine if an error should be raised */
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) AND
       (l_return_status <> 'Q') THEN
      RAISE GET_TOTAL_QTY_ERR;
    ELSIF l_return_status = 'Q' THEN
      IF (p_total_output IS NOT NULL) AND
         (l_formula_output IS NULL) THEN
        /*This implies that the system cannot calculate the total output qty and */
        /*the validity rules are being fetched based on total ouput then this should */
        /*be raised as an error */
        FND_MESSAGE.SET_NAME('GMD', 'GMD_ERR_CALC_OUTPUT');
        FND_MESSAGE.SET_TOKEN('UOM', l_uom);
        FND_MSG_PUB.add;
        RAISE GET_TOTAL_QTY_ERR;
      ELSIF (p_total_input IS NOT NULL) AND
         (l_formula_input IS NULL) THEN
        /*This implies that the system cannot calculate the total input qty and */
        /*the validity rules are being fetched based on total input then this should */
        /*be raised as an error */
        FND_MESSAGE.SET_NAME('GMD', 'GMD_ERR_CALC_INPUT');
        FND_MESSAGE.SET_TOKEN('UOM', l_uom);
        FND_MSG_PUB.add;
        RAISE GET_TOTAL_QTY_ERR;
      END IF;
    END IF;


    IF (p_total_output IS NOT NULL) THEN

      /* Try to get validity rules based on recipe ID and total output qty */
      /* Get the ratio of the batch output qty to the ratio of the formula ouput qty */
      gmd_validity_rules.get_output_ratio(p_formula_id     => l_formula_id,
                                                p_batch_output   => p_total_output,
                                                p_yield_um       => l_uom,
                                                p_formula_output => l_formula_output,
                                                x_return_status  => l_return_status,
                                                X_output_ratio   => l_output_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_OUTPUT_RATIO_ERR;
      END IF;
    ELSIF (p_total_input IS NOT NULL) THEN

      /* Get the product to ingredient ratio for the formula */
      gmd_validity_rules.get_ingredprod_ratio(p_formula_id        => l_formula_id,
                                              p_yield_um          => l_uom,
                                              x_return_status     => l_return_status,
                                              X_ingred_prod_ratio => l_ingred_prod_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_INGREDPROD_RATIO_ERR;
      END IF;
      /* Get the ratio of the batch input to the formula input */
      gmd_validity_rules.get_batchformula_ratio(p_formula_id         => l_formula_id,
                                                p_batch_input        => p_total_input,
                                                p_yield_um           => l_uom,
                                                p_formula_input      => l_formula_input,
                                                x_return_status      => l_return_status,
                                                X_batchformula_ratio => l_batchformula_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_BATCHFORMULA_RATIO_ERR;
      END IF;

      /* Get the contributing qty of the formula */
      gmd_validity_rules.get_contributing_qty(p_formula_id          => l_formula_id,
                                              p_recipe_id           => l_recipe_id,
                                              p_batchformula_ratio  => l_batchformula_ratio,
                                              p_yield_um            => l_uom,
                                              x_return_status       => l_return_status,
                                              X_contributing_qty    => l_contributing_qty);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_CONTRIBUTING_QTY_ERR;
      END IF;
      /* Calculate actual contributing qty of formula */
      l_contributing_qty := l_contributing_qty * l_ingred_prod_ratio;

      /* Get the ratio of the product based on contributing qty */
      gmd_validity_rules.get_input_ratio(p_formula_id       => l_formula_id,
                                         p_contributing_qty => l_contributing_qty,
                                         p_yield_um         => l_uom,
                                         p_formula_output   => l_formula_input,
                                         x_return_status    => l_return_status,
                                         X_output_ratio     => l_output_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_INPUT_RATIO_ERR;
      END IF;
    END IF;

    /* Get all the possible validity rules and check if it can be used for this input/output qty */

    FOR get_rec IN get_val LOOP
    BEGIN
      -- NPD Conv.
      IF (p_orgn_code IS NOT NULL OR (p_orgn_code IS NULL AND p_organization_id IS NOT NULL)) THEN

         IF p_orgn_code IS NULL THEN
		OPEN Cur_get_orgn_code;
		FETCH Cur_get_orgn_code INTO l_orgn_code;
		CLOSE Cur_get_orgn_code;
	 ELSE
		l_orgn_code := p_orgn_code;
	 END IF;
	 GMD_API_GRP.check_item_exists (p_formula_id        => l_formula_id
	                               ,p_organization_id   => p_organization_id
	                               ,p_orgn_code         => l_orgn_code
	                               ,x_return_status     => l_return_status
	                               ,p_Production_check  => TRUE);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE ITEM_ORGN_MISSING;
	 END IF;
      END IF;
      -- End NPD Conv.

      OPEN Cur_get_qty(get_rec.inventory_item_id);
      FETCH Cur_get_qty INTO l_item_qty, l_scale_type, l_line_um;
      CLOSE Cur_get_qty;
      IF (l_scale_type = 1) THEN
        l_item_qty := l_item_qty * l_output_ratio;
        IF (l_line_um <> get_rec.detail_uom) THEN

          -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion

          l_item_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                   ,precision      => 5
                                                   ,from_quantity  => l_item_qty
                                                   ,from_unit      => l_line_um
                                                   ,to_unit        => get_rec.detail_uom
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
          IF l_item_qty < 0 THEN
            RAISE UOM_CONVERSION_ERROR;
          END IF;
          /* gmicuom.icuomcv(get_rec.item_id, 0, l_item_qty, l_line_um, get_rec.item_um, l_item_qty); */
        END IF;
        IF (l_item_qty >= get_rec.min_qty AND l_item_qty <= get_rec.max_qty) THEN
          IF p_least_cost_validity = 'T' THEN
            GMD_VALIDITY_RULES.get_formula_cost (p_formula_id => l_formula_id
                                                ,p_requested_qty => l_item_qty
                                                ,p_requested_uom => get_rec.detail_uom
                                                ,p_product_id => get_rec.inventory_item_id
                                                ,p_organization_id   => p_organization_id
                                                ,X_unit_cost => l_unit_cost
                                                ,X_total_cost => l_total_cost
                                                ,X_return_status => l_return_status);
            IF l_return_status <> FND_API.g_ret_sts_success THEN
              RAISE GET_FORMULA_COST_ERR;
            END IF;
          END IF; /* IF p_least_cost_validity = 'T' */
          GMD_VALIDITY_RULES.insert_val_temp_tbl(p_val_rec => get_rec
                                                ,p_unit_cost => l_unit_cost
                                                ,p_total_cost => l_total_cost);
        END IF; /* IF (l_item_qty >= get_rec.min_qty AND l_item_qty <= get_rec.max_qty) */
      END IF; /* IF (l_scale_type = 1) */
     EXCEPTION
       WHEN ITEM_ORGN_MISSING THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
     END;
     END LOOP;
   ELSIF (p_item_id IS NOT NULL or p_item_no IS NOT NULL) THEN

    /* Try to get validity rules based on Item */
    OPEN cur_item_uom(p_item_id);
    FETCH cur_item_uom INTO l_item_uom;
    CLOSE cur_item_uom;

    IF (p_uom <> l_item_uom) THEN
      -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
       l_quantity := ROUND(gmicuom.uom_conversion(p_item_id,0,p_product_qty, p_uom, l_item_uom, 0),9);

 l_quantity := INV_CONVERT.inv_um_convert(item_id        => p_item_id
                                              ,precision      => 5
                                              ,from_quantity  => p_product_qty
                                              ,from_unit      => p_uom
                                              ,to_unit        => l_item_uom
                                              ,from_name      => NULL
                                              ,to_name	      => NULL);

      IF (l_quantity < 0) THEN
        RAISE UOM_CONVERSION_ERROR;
      END IF;
    ELSE
      l_quantity := p_product_qty;
    END IF;

    /* Get item id if it is not passed in */
    IF (p_item_id IS NOT NULL) THEN
    	l_item_id := p_item_id;
    ELSIF (p_item_no IS NOT NULL) THEN
      OPEN get_item_id(p_item_no);
      FETCH get_item_id INTO l_item_id;
        IF get_item_id%NOTFOUND THEN
          CLOSE get_item_id;
          RAISE ITEM_NOT_FOUND_ERROR;
        END IF;
      CLOSE get_item_id;
    ELSE
      RAISE ITEM_NOT_FOUND_ERROR;
    END IF;

    FOR get_rec IN get_val_item(l_quantity) LOOP
    BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* Get the formula for this recipe */
      OPEN Cur_get_formula (get_rec.recipe_id);
      FETCH Cur_get_formula INTO l_formula_id;
      CLOSE Cur_get_formula;

      -- NPD Conv.
      IF (p_orgn_code IS NOT NULL OR (p_orgn_code IS NULL AND p_organization_id IS NOT NULL)) THEN
         IF p_orgn_code IS NULL THEN
		OPEN Cur_get_orgn_code;
		FETCH Cur_get_orgn_code INTO l_orgn_code;
		CLOSE Cur_get_orgn_code;
	 ELSE
		l_orgn_code := p_orgn_code;
	 END IF;
         GMD_API_GRP.check_item_exists (p_formula_id            => l_formula_id
	                               ,p_organization_id       => p_organization_id
	                               ,p_orgn_code             => p_orgn_code
	                               ,x_return_status         => l_return_status
	                               ,p_Production_check      => TRUE);
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        RAISE ITEM_ORGN_MISSING;
	 END IF;
      END IF;
      -- End NPD Conv.

      IF p_least_cost_validity = 'T' THEN
        GMD_VALIDITY_RULES.get_formula_cost (p_formula_id => l_formula_id
                                            ,p_requested_qty => l_quantity
                                            ,p_requested_uom => l_item_uom
                                            ,p_product_id => get_rec.inventory_item_id
                                            ,p_organization_id   => p_organization_id
                                            ,X_unit_cost => l_unit_cost
                                            ,X_total_cost => l_total_cost
                                            ,X_return_status => l_return_status);
        IF l_return_status <> FND_API.g_ret_sts_success THEN
          RAISE GET_FORMULA_COST_ERR;
        END IF;
      END IF; /* IF p_least_cost_validity = 'T' */

      GMD_VALIDITY_RULES.insert_val_temp_tbl(p_val_rec => get_rec
                                            ,p_unit_cost => l_unit_cost
                                            ,p_total_cost => l_total_cost);
    EXCEPTION
      WHEN ITEM_ORGN_MISSING THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;
    END LOOP;

  ELSE
    /* Try to get validity rules based on recipe ID */
    -- Changed IF p_recipe_id NOT NULL to IF l_recipe_id IS NOT NULL as it fails when recipe no and vers
    -- are passed instead of id
    -- Bug 3818835 - Start
    IF l_recipe_id IS NOT NULL THEN

      -- Get the formula attached with the recipe
      OPEN Cur_get_formula (l_recipe_id);
      FETCH Cur_get_formula INTO l_formula_id;
      CLOSE Cur_get_formula;

      -- Get formula product quantity
      OPEN  get_form_prod(l_formula_id);
      FETCH get_form_prod INTO l_prod_id,l_form_qty,l_prod_uom;
      CLOSE get_form_prod;

      /* Bug No.8643350 - START*/
      OPEN cur_item_uom(l_prod_id);
      FETCH cur_item_uom INTO l_item_uom;
      CLOSE cur_item_uom;
     /* Bug No.8643350 - END */

      IF p_product_qty IS NOT NULL THEN -- Add Check to see if Prod Qty. is passed as NULL
        -- check uom conversion here
        -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
        l_quantity := INV_CONVERT.inv_um_convert(item_id        => p_item_id
                                                ,precision      => 5
                                                ,from_quantity  => p_product_qty
                                                ,from_unit      => p_uom
                                                ,to_unit        => l_item_uom
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
        IF (l_quantity < 0) THEN
          RAISE UOM_CONVERSION_ERROR;
        END IF;
      ELSE
        -- NPD Conv. Commented out below logic as ic_plnt_inv table is obsolete after conv.
        /* Bug No.8643350 - Start */
        IF (l_prod_uom <> l_item_uom) THEN
          l_quantity := INV_CONVERT.inv_um_convert(item_id        => l_prod_id
                                                ,precision      => 5
                                                ,from_quantity  => l_form_qty
                                                ,from_unit      => l_prod_uom
                                                ,to_unit        => l_item_uom
                                                ,from_name      => NULL
                                                ,to_name  => NULL);
        IF (l_quantity < 0) THEN
          RAISE UOM_CONVERSION_ERROR;
        END IF;
       ELSE
        l_quantity := l_form_qty;
        END IF;
       /* Bug No.8643350 - END */
      END IF;
    END IF; /* IF l_recipe_id IS NOT NULL THEN */
    -- Bug 3818835 - End

    FOR get_rec IN get_val LOOP
    BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- NPD Conv.
      IF (p_orgn_code IS NOT NULL OR (p_orgn_code IS NULL AND p_organization_id IS NOT NULL)) THEN

         IF p_orgn_code IS NULL THEN
		OPEN Cur_get_orgn_code;
		FETCH Cur_get_orgn_code INTO l_orgn_code;
		CLOSE Cur_get_orgn_code;
	 ELSE
		l_orgn_code := p_orgn_code;
	 END IF;
         GMD_API_GRP.check_item_exists (p_formula_id        => l_formula_id
	                               ,p_organization_id   => NULL
	                               ,p_orgn_code         => l_orgn_code
	                               ,x_return_status     => l_return_status
	                               ,p_Production_check  => TRUE);

	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE ITEM_ORGN_MISSING;
	 END IF;
      END IF;
      -- End NPD Conv.

      -- Bug 3818835
      -- Select validity rule only if qty. is greater than min qty and lesser than max qty of validity rule.
      IF (l_quantity >= get_rec.inv_min_qty AND l_quantity <= get_rec.inv_max_qty) THEN  -- Bug #5211935 inv_min_qty , inv_max_qty instead of min_qty, max_qty

        IF p_least_cost_validity = 'T' THEN
          GMD_VALIDITY_RULES.get_formula_cost (p_formula_id => l_formula_id
                                              ,p_requested_qty => l_quantity
                                              ,p_requested_uom => get_rec.detail_uom
                                              ,p_product_id => get_rec.inventory_item_id
                                              ,p_organization_id   => p_organization_id
                                              ,X_unit_cost => l_unit_cost
                                              ,X_total_cost => l_total_cost
                                              ,X_return_status => l_return_status);
          IF l_return_status <> FND_API.g_ret_sts_success THEN
            RAISE GET_FORMULA_COST_ERR;
          END IF;
        END IF; /* IF p_least_cost_validity = 'T' */

        GMD_VALIDITY_RULES.insert_val_temp_tbl(p_val_rec => get_rec
                                              ,p_unit_cost => l_unit_cost
                                              ,p_total_cost => l_total_cost);

      END IF; /* IF (l_quantity >= get_rec.min_qty AND l_quantity <= get_rec.max_qty) */
    EXCEPTION
      WHEN ITEM_ORGN_MISSING THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;
    END LOOP;
  END IF;

  i := 0;
  FOR l_rec IN Cur_get_VR LOOP
    i := i + 1;
    x_recipe_validity_out(i).recipe_validity_rule_id := l_rec.recipe_validity_rule_id ;
    x_recipe_validity_out(i).recipe_id               := l_rec.recipe_id ;
    x_recipe_validity_out(i).orgn_code               := l_rec.orgn_code ;
    x_recipe_validity_out(i).recipe_use              := l_rec.recipe_use ;
    x_recipe_validity_out(i).preference              := l_rec.preference ;
    x_recipe_validity_out(i).start_date              := l_rec.start_date ;
    x_recipe_validity_out(i).end_date                := l_rec.end_date ;
    x_recipe_validity_out(i).min_qty                 := l_rec.min_qty ;
    x_recipe_validity_out(i).max_qty                 := l_rec.max_qty ;
    x_recipe_validity_out(i).std_qty                 := l_rec.std_qty ;
    x_recipe_validity_out(i).inv_min_qty             := l_rec.inv_min_qty ;
    x_recipe_validity_out(i).inv_max_qty             := l_rec.inv_max_qty ;
    x_recipe_validity_out(i).text_code               := l_rec.text_code ;
    x_recipe_validity_out(i).attribute_category      := l_rec.attribute_category ;
    x_recipe_validity_out(i).attribute1              := l_rec.attribute1 ;
    x_recipe_validity_out(i).attribute2              := l_rec.attribute2 ;
    x_recipe_validity_out(i).attribute3              := l_rec.attribute3 ;
    x_recipe_validity_out(i).attribute4              := l_rec.attribute4 ;
    x_recipe_validity_out(i).attribute5              := l_rec.attribute5 ;
    x_recipe_validity_out(i).attribute6              := l_rec.attribute6 ;
    x_recipe_validity_out(i).attribute7              := l_rec.attribute7 ;
    x_recipe_validity_out(i).attribute8              := l_rec.attribute8 ;
    x_recipe_validity_out(i).attribute9              := l_rec.attribute9 ;
    x_recipe_validity_out(i).attribute10             := l_rec.attribute10 ;
    x_recipe_validity_out(i).attribute11             := l_rec.attribute11;
    x_recipe_validity_out(i).attribute12             := l_rec.attribute12 ;
    x_recipe_validity_out(i).attribute13             := l_rec.attribute13 ;
    x_recipe_validity_out(i).attribute14             := l_rec.attribute14 ;
    x_recipe_validity_out(i).attribute15             := l_rec.attribute15 ;
    x_recipe_validity_out(i).attribute16             := l_rec.attribute16 ;
    x_recipe_validity_out(i).attribute17             := l_rec.attribute17 ;
    x_recipe_validity_out(i).attribute18             := l_rec.attribute18 ;
    x_recipe_validity_out(i).attribute19             := l_rec.attribute19 ;
    x_recipe_validity_out(i).attribute20             := l_rec.attribute20 ;
    x_recipe_validity_out(i).attribute21             := l_rec.attribute21 ;
    x_recipe_validity_out(i).attribute22             := l_rec.attribute22 ;
    x_recipe_validity_out(i).attribute23             := l_rec.attribute23 ;
    x_recipe_validity_out(i).attribute24             := l_rec.attribute24 ;
    x_recipe_validity_out(i).attribute25             := l_rec.attribute25 ;
    x_recipe_validity_out(i).attribute26             := l_rec.attribute26 ;
    x_recipe_validity_out(i).attribute27             := l_rec.attribute27 ;
    x_recipe_validity_out(i).attribute28             := l_rec.attribute28 ;
    x_recipe_validity_out(i).attribute29             := l_rec.attribute29 ;
    x_recipe_validity_out(i).attribute30             := l_rec.attribute30 ;
    x_recipe_validity_out(i).created_by              := l_rec.created_by ;
    x_recipe_validity_out(i).creation_date           := l_rec.creation_date ;
    x_recipe_validity_out(i).last_updated_by         := l_rec.last_updated_by ;
    x_recipe_validity_out(i).last_update_date        := l_rec.last_update_date ;
    x_recipe_validity_out(i).last_update_login       := l_rec.last_update_login ;
    x_recipe_validity_out(i).validity_rule_status    := l_rec.validity_rule_status ;
    x_recipe_validity_out(i).planned_process_loss    := l_rec.planned_process_loss ;
    x_recipe_validity_out(i).organization_id         := l_rec.organization_id ;
    x_recipe_validity_out(i).inventory_item_id       := l_rec.inventory_item_id ;
    x_recipe_validity_out(i).revision                := l_rec.revision ;
    x_recipe_validity_out(i).detail_uom              := l_rec.detail_uom ;
    x_recipe_validity_out(i).unit_cost		 := l_rec.unit_cost ;
    x_recipe_validity_out(i).total_cost		 := l_rec.total_cost ;
  END LOOP;

  IF i > 0 THEN
    X_return_status := Fnd_api.G_ret_sts_success;
  END IF;

  -- standard call to get msge cnt, and if cnt is 1, get mesg info
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
EXCEPTION
  WHEN NO_YIELD_TYPE_UM THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'FM_SCALE_BAD_YIELD_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);
  WHEN GET_FORMULA_COST_ERR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);
  WHEN GET_FORMULA_ERR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);
  WHEN GET_TOTAL_QTY_ERR OR GET_OUTPUT_RATIO_ERR
       OR GET_INGREDPROD_RATIO_ERR OR GET_BATCHFORMULA_RATIO_ERR
       OR GET_CONTRIBUTING_QTY_ERR OR GET_INPUT_RATIO_ERR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);
  WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_validity_rules.uom_conversion_mesg(p_item_id => p_item_id,
                                                   p_from_um => p_uom,
                                                   p_to_um   => l_item_uom);
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

  WHEN OTHERS THEN
      X_return_code   := SQLCODE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
END get_validity_rules;

/*======================================================================
--  PROCEDURE :
--   get_output_ratio
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for determining
--    the output ratio which is the ratio of the batch output
--    to the formula output when a total output qty is used as
--    the criteria for a validity rule.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_output_ratio (X_formula_id, X_batch_output, X_yield_um,
--                      X_formula_output, X_return_status, X_output_ratio);
--
--===================================================================== */
PROCEDURE get_output_ratio(p_formula_id     IN  NUMBER,
                           p_batch_output   IN  NUMBER,
                           p_yield_um       IN  VARCHAR2,
                           p_formula_output IN NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           X_output_ratio   OUT NOCOPY NUMBER) IS
  CURSOR Cur_get_prods IS
    SELECT inventory_item_id, qty, detail_uom, scale_type
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type IN (1,2);

  l_batch_output       NUMBER := 0;
  l_formula_output     NUMBER := 0;
  l_conv_qty           NUMBER := 0;
  l_total_fixed_qty    NUMBER := 0;
  X_item_id            NUMBER;
  X_detail_uom         VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR get_rec IN Cur_get_prods
  LOOP
    IF (get_rec.scale_type = 0) THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN

        -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id     := get_rec.inventory_item_id;
          X_detail_uom := get_rec.detail_uom;
          RAISE UOM_CONVERSION_ERROR;
        END IF;
        l_total_fixed_qty := l_total_fixed_qty + l_conv_qty;
      ELSE
        l_total_fixed_qty := l_total_fixed_qty + get_rec.qty;
      END IF;
    END IF;
  END LOOP;

  l_batch_output   := p_batch_output - l_total_fixed_qty;
  l_formula_output := p_formula_output - l_total_fixed_qty;
  X_output_ratio   := l_batch_output/l_formula_output;

  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_detail_uom,
                                                   p_to_um   => p_yield_um);
END get_output_ratio;

/*======================================================================
--  PROCEDURE :
--   get_ingredprod_ratio
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for determining
--    the ratio of the products to ingredients while trying
--    to determine validity rules based on total input qty.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_ingredprod_ratio (X_formula_id, X_yield_um,
--                          X_ingred_prod_ratio, X_status);
--
--===================================================================== */
PROCEDURE get_ingredprod_ratio(p_formula_id        IN  NUMBER,
                               p_yield_um          IN  VARCHAR2,
                               X_ingred_prod_ratio OUT NOCOPY NUMBER,
                               x_return_status     OUT NOCOPY VARCHAR2) IS
  -- NPD Conv.
  CURSOR Cur_get_details(V_line_type NUMBER) IS
    SELECT inventory_item_id, qty, detail_uom, scale_type, contribute_yield_ind
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = V_line_type;

  l_sum_prods        NUMBER := 0;
  l_sum_ingreds      NUMBER := 0;
  l_conv_qty           NUMBER := 0;
  X_item_id            NUMBER;
  X_detail_uom         VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Get sum of products in yield UM.
  FOR get_rec IN Cur_get_details(1)
  LOOP
    IF (get_rec.detail_uom <> p_yield_um) THEN
      -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
     l_conv_qty := INV_CONVERT.inv_um_convert(item_id        => get_rec.inventory_item_id
                                             ,precision      => 5
                                             ,from_quantity  => get_rec.qty
                                             ,from_unit      => get_rec.detail_uom
                                             ,to_unit        => p_yield_um
                                             ,from_name      => NULL
                                             ,to_name	     => NULL);

      IF (l_conv_qty < 0) THEN
        X_item_id := get_rec.inventory_item_id;
        X_detail_uom := get_rec.detail_uom;
        RAISE UOM_CONVERSION_ERROR;
      END IF;
      l_sum_prods := l_sum_prods + l_conv_qty;
    ELSE
      l_sum_prods := l_sum_prods + get_rec.qty;
    END IF;
  END LOOP;
  --Get sum of ingredients in yield UM contributing to yield.
  FOR get_rec IN Cur_get_details(-1)
  LOOP
    IF (get_rec.contribute_yield_ind = 'Y') THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN
        -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id        => get_rec.inventory_item_id
                                                ,precision      => 5
                                                ,from_quantity  => get_rec.qty
                                                ,from_unit      => get_rec.detail_uom
                                                ,to_unit        => p_yield_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_detail_uom := get_rec.detail_uom;
          RAISE UOM_CONVERSION_ERROR;
        END IF;
        l_sum_ingreds := l_sum_ingreds + l_conv_qty;
      ELSE
        l_sum_ingreds := l_sum_ingreds + get_rec.qty;
      END IF;
    END IF;
  END LOOP;

  --Get ratio and return.
  X_ingred_prod_ratio := l_sum_prods/l_sum_ingreds;
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_detail_uom,
                                                   p_to_um   => p_yield_um);
END get_ingredprod_ratio;

/*======================================================================
--  PROCEDURE :
--   get_batchformula_ratio
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for determining
--    the ratio of the batch input qty to the formula input qty
--    while determining validity rules based on total input qty.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_batchformula_ratio (X_formula_id, X_batch_input, X_yield_um,
--                            X_formula_input, X_batchformula_ratio,
--                            X_status);
--
--===================================================================== */
PROCEDURE get_batchformula_ratio(p_formula_id         IN  NUMBER,
                                 p_batch_input        IN  NUMBER,
                                 p_yield_um           IN  VARCHAR2,
                                 p_formula_input      IN  NUMBER,
                                 X_batchformula_ratio OUT NOCOPY NUMBER,
                                 X_return_status      OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_ingreds IS
    -- NPD Conv.
    SELECT inventory_item_id, qty, detail_uom, scale_type
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = -1;

  CURSOR Cur_get_total_input IS
    SELECT total_input_qty, yield_uom
    FROM   fm_form_mst
    WHERE  formula_id = p_formula_id;
  l_formula_input      NUMBER := 0;
  l_fixed_ingred       NUMBER := 0;
  l_batch_input        NUMBER := 0;
  l_conv_qty           NUMBER := 0;
  X_item_id            NUMBER;
  X_detail_uom         VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR get_rec IN Cur_get_ingreds LOOP
    IF (get_rec.scale_type = 0) THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN

        -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id        => get_rec.inventory_item_id
                                                ,precision      => 5
                                                ,from_quantity  => get_rec.qty
                                                ,from_unit      => get_rec.detail_uom
                                                ,to_unit        => p_yield_um
                                                ,from_name      => NULL
                                                ,to_name	   => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_detail_uom := get_rec.detail_uom;
          RAISE UOM_CONVERSION_ERROR;
        END IF;
        l_fixed_ingred := l_fixed_ingred + l_conv_qty;
      ELSE
        l_fixed_ingred := l_fixed_ingred + get_rec.qty;
      END IF;
    END IF;
  END LOOP;
  l_batch_input        := p_batch_input - l_fixed_ingred;
  l_formula_input      := p_formula_input - l_fixed_ingred;
  X_batchformula_ratio := l_batch_input / l_formula_input;
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_detail_uom,
                                                   p_to_um   => p_yield_um);
END get_batchformula_ratio;

/*======================================================================
--  PROCEDURE :
--   get_contibuting_qty
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for determining
--    the actual contributing qty of the formula.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_contributing_qty (X_formula_id, X_recipe_id,
--                          X_formula_batch_ratio, X_yield_um,
--                          X_formula_input, X_ratio, X_status);
--
--===================================================================== */
PROCEDURE get_contributing_qty(p_formula_id          IN  NUMBER,
                               p_recipe_id           IN  NUMBER,
                               p_batchformula_ratio  IN  NUMBER,
                               p_yield_um            IN  VARCHAR2,
                               X_contributing_qty    OUT NOCOPY NUMBER,
                               X_return_status       OUT NOCOPY VARCHAR2) IS
  -- NPD Conv.
  CURSOR Cur_get_ingreds IS
    SELECT inventory_item_id, qty, detail_uom, scale_type, contribute_yield_ind
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = -1;

  l_conv_qty           NUMBER := 0;
  l_process_loss       NUMBER := 0;
  l_theo_process_loss   NUMBER := 0;
  l_msg_count          Number := 0;
  l_msg_data  Varchar2(240);
  X_item_id            NUMBER;
  X_detail_uom         VARCHAR2(4);
  X_status             VARCHAR2(100);
  l_process_rec        gmd_common_val.process_loss_rec;
  UOM_CONVERSION_ERROR EXCEPTION;
  PROCESS_LOSS_ERR     EXCEPTION;
BEGIN
  x_contributing_qty := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* Loop through ingredients and determine total contributing qty */
  FOR get_rec IN Cur_get_ingreds LOOP
    IF (get_rec.contribute_yield_ind = 'Y') THEN
      /* Convert all ingredient values to yield UM and determine contributing qty */
      IF (get_rec.detail_uom <> p_yield_um) THEN
         -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id        => get_rec.inventory_item_id
                                                ,precision      => 5
                                                ,from_quantity  => get_rec.qty
                                                ,from_unit      => get_rec.detail_uom
                                                ,to_unit        => p_yield_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_detail_uom := get_rec.detail_uom;
          RAISE UOM_CONVERSION_ERROR;
        END IF;
      ELSE
        l_conv_qty := get_rec.qty;
      END IF;
      /* If ingredient scalable multiply by ratio and calculate contributing qty */
      IF (get_rec.scale_type = 1) THEN
        X_contributing_qty := X_contributing_qty + (l_conv_qty * p_batchformula_ratio);
      ELSE
        X_contributing_qty := X_contributing_qty + l_conv_qty;
      END IF;
    END IF;
  END LOOP;
  /* Get process loss for this qty */
  l_process_rec.qty       := X_contributing_qty;
  l_process_rec.recipe_id := p_recipe_id;
  gmd_common_val.calculate_process_loss(process_loss    => l_process_rec,
                                        Entity_type => 'RECIPE' ,
                                        x_recipe_theo_loss => l_theo_process_loss,
                                        x_process_loss  => l_process_loss,
                                        x_return_status => X_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data);

 /* IF (X_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE PROCESS_LOSS_ERR;
  END IF;*/
  /* Shrikant : Added NVL and / 100 in the following equation */
  X_contributing_qty := X_contributing_qty * (100 - NVL(l_process_loss,0))/100;
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_detail_uom,
                                                   p_to_um   => p_yield_um);
END get_contributing_qty;

/*======================================================================
--  PROCEDURE :
--   get_input_ratio
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for determining
--    the actual ratio of product for the total input qty.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_input_ratio (X_formula_id, X_contributing_qty, X_yield_um,
--                     X_formula_output, X_output_ratio, X_status);
--
--===================================================================== */
PROCEDURE get_input_ratio(p_formula_id       IN  NUMBER,
                          p_contributing_qty IN  NUMBER,
                          p_yield_um         IN  VARCHAR2,
                          p_formula_output   IN  NUMBER,
                          X_output_ratio     OUT NOCOPY NUMBER,
                          X_return_status    OUT NOCOPY VARCHAR2) IS
  -- NPD Conv.
  CURSOR Cur_get_prods IS
    SELECT inventory_item_id, qty, detail_uom, scale_type
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = 1;

  l_contributing_qty   NUMBER := 0;
  l_formula_output     NUMBER := 0;
  l_conv_qty           NUMBER := 0;
  l_fixed_prod         NUMBER := 0;
  X_item_id            NUMBER ;
  X_detail_uom            VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  FOR get_rec IN Cur_get_prods LOOP
    IF (get_rec.scale_type = 0) THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN

        -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id        => get_rec.inventory_item_id
                                                ,precision      => 5
                                                ,from_quantity  => get_rec.qty
                                                ,from_unit      => get_rec.detail_uom
                                                ,to_unit        => p_yield_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_detail_uom := get_rec.detail_uom;
          RAISE UOM_CONVERSION_ERROR;
        END IF;
        l_fixed_prod := l_fixed_prod + l_conv_qty;
      ELSE
        l_fixed_prod := l_fixed_prod + get_rec.qty;
      END IF;
    END IF;
  END LOOP;
  l_contributing_qty := p_contributing_qty - l_fixed_prod;
  l_formula_output   := P_formula_output - l_fixed_prod;
  X_output_ratio     := l_contributing_qty / l_formula_output;
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_detail_uom,
                                                   p_to_um   => p_yield_um);
END get_input_ratio;

/*======================================================================
--  PROCEDURE :
--   uom_conversion_mesg
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for showing
--    the the message about uom conversion errors.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    uom_conversion_mesg (X_item_id, X_from_um, X_to_um);
--
--===================================================================== */
PROCEDURE uom_conversion_mesg(p_item_id IN NUMBER,
                              p_from_um IN VARCHAR2,
                              p_to_um   IN VARCHAR2) IS

  -- NPD Conv. Modified cursor to get concatenated segments for the item_id
  CURSOR Cur_get_item IS
    SELECT concatenated_segments
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = p_item_id;
  X_item_no VARCHAR2(32);
BEGIN
  OPEN Cur_get_item;
  FETCH Cur_get_item INTO X_item_no;
  CLOSE Cur_get_item;
  FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
  FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
  FND_MESSAGE.SET_TOKEN('FROM_UOM', p_from_um);
  FND_MESSAGE.SET_TOKEN('TO_UOM', p_to_um);
  FND_MSG_PUB.ADD;
END uom_conversion_mesg;


/*======================================================================
--  PROCEDURE :
--   get_all_validity_rules
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting all the
--    validity rules based on the input parameters.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_all_validity_rules (1.0, X_init_msg_list, X_recipe_id, X_item_id,
--                        X_return_status, X_msg_count, X_msg_data,
--                        X_return_code, X_vr_table);
--
--  HISTORY
--   RajaSekhar  11-Jul-2002 BUG#2436355  Added to get all ( Planning,costing,
--                           prodoction etc) validity rules of all the statuses.
--===================================================================== */
/* Formatted on 2002/07/11 18:01 (RevealNet Formatter v4.4.0) */
PROCEDURE Get_all_validity_rules (
   P_api_version           IN           NUMBER,
   P_init_msg_list         IN           VARCHAR2 := Fnd_api.G_false,
   P_recipe_id             IN           NUMBER   := NULL,
   P_item_id               IN           NUMBER   := NULL,
   p_revision              IN           VARCHAR2 := NULL,
   p_least_cost_validity   IN		VARCHAR2 := 'F',
   X_return_status         OUT NOCOPY   VARCHAR2,
   X_msg_count             OUT NOCOPY   NUMBER,
   X_msg_data              OUT NOCOPY   VARCHAR2,
   X_return_code           OUT NOCOPY   NUMBER,
   X_recipe_validity_out   OUT NOCOPY   Recipe_validity_tbl
)
IS
   --  local Variables
   L_api_name                    VARCHAR2 (30) := 'get_validity_rules';
   L_api_version                 NUMBER := 1.0;
   I                             NUMBER := 0;
   L_msg_count                   NUMBER;
   L_msg_data                    VARCHAR2 (100);
   L_return_status		 VARCHAR2(10);
   L_return_code                 VARCHAR2 (10);

   l_unit_cost		   NUMBER;
   l_total_cost		   NUMBER;
   l_formula_id		   NUMBER;
   l_quantity		   NUMBER;
   l_uom		   VARCHAR2(3);

   --Cursor to get data based on recipe ID
   CURSOR Get_val_recipe   IS
      SELECT   v.*
      FROM Gmd_recipe_validity_rules V, Gmd_recipes R, Gmd_status S
      WHERE V.Recipe_id = R.Recipe_id
      AND V.Validity_rule_status = S.Status_code
      AND V.Recipe_id = NVL (P_recipe_id, V.Recipe_id)
      AND v.delete_mark = 0
      ORDER BY R.Recipe_no,R.Recipe_version, V.Recipe_use,Orgn_code, Preference,S.Status_type;

   --Cursor to get data based on item.

   CURSOR Get_val_item   IS
     SELECT   V.*
     FROM Gmd_recipe_validity_rules V,
          Gmd_recipes R,
          Gmd_status S
     WHERE V.Recipe_id = R.Recipe_id
     AND V.Validity_rule_status = S.Status_code
     AND V.inventory_item_id = P_item_id
     AND (p_revision IS NULL OR (p_revision IS NOT NULL AND v.revision = p_revision))
     AND v.delete_mark = 0
     ORDER BY R.Recipe_no,R.Recipe_version, V.Recipe_use,Orgn_code, Preference,S.Status_type;

  CURSOR Cur_get_VR IS
    SELECT *
    FROM GMD_VAL_RULE_GTMP;

  CURSOR Cur_get_form_id (v_recipe_id NUMBER, V_inventory_item_id NUMBER) IS
    SELECT rcp.formula_id, SUM(qty), MAX(detail_uom)
    FROM gmd_recipes rcp, fm_matl_dtl d
    WHERE rcp.recipe_id = v_recipe_id
    AND   rcp.formula_id = d.formula_id
    AND   d.line_type = 1
    AND   d.inventory_item_id = V_inventory_item_id;

  GET_FORMULA_COST_ERR EXCEPTION;

BEGIN
   IF (NOT Fnd_api.Compatible_api_call ( L_api_version,
                                         P_api_version,
                                         L_api_name,
                                         G_pkg_name ))
   THEN
      RAISE Fnd_api.G_exc_unexpected_error;
   END IF;

   IF (Fnd_api.To_boolean (P_init_msg_list))
   THEN
      Fnd_msg_pub.Initialize;
   END IF;

   X_return_status            := Fnd_api.G_ret_sts_success;

  /* Delete from this table for any existing data */
  DELETE FROM GMD_VAL_RULE_GTMP;

  IF (P_item_id IS NOT NULL)  THEN
    FOR Get_rec IN Get_val_item LOOP
      X_return_status            := Fnd_api.G_ret_sts_success;

      IF p_least_cost_validity = 'T' THEN
        OPEN Cur_get_form_id (get_rec.recipe_id, get_rec.inventory_item_id);
        FETCH Cur_get_form_id INTO l_formula_id, l_quantity, l_uom;
        CLOSE Cur_get_form_id;
        IF (get_rec.organization_id IS NOT NULL) THEN
          GMD_VALIDITY_RULES.get_formula_cost (p_formula_id => l_formula_id
                                              ,p_requested_qty => l_quantity
                                              ,p_requested_uom => l_uom
                                              ,p_product_id => get_rec.inventory_item_id
                                              ,p_organization_id   => get_rec.organization_id
                                              ,X_unit_cost => l_unit_cost
                                              ,X_total_cost => l_total_cost
                                              ,X_return_status => l_return_status);
          IF l_return_status <> FND_API.g_ret_sts_success THEN
            RAISE GET_FORMULA_COST_ERR;
          END IF;
        END IF;
      END IF; /* IF p_least_cost_validity = 'T' */
      GMD_VALIDITY_RULES.insert_val_temp_tbl(p_val_rec => get_rec
                                            ,p_unit_cost => l_unit_cost
                                            ,p_total_cost => l_total_cost);
    END LOOP;
  ELSE
    /* Try to get validity rules based on recipe ID */
    FOR Get_rec IN Get_val_recipe LOOP
      X_return_status            := Fnd_api.G_ret_sts_success;

      IF p_least_cost_validity = 'T' THEN
        OPEN Cur_get_form_id (get_rec.recipe_id, get_rec.inventory_item_id);
        FETCH Cur_get_form_id INTO l_formula_id, l_quantity, l_uom;
        CLOSE Cur_get_form_id;
        IF (get_rec.organization_id IS NOT NULL) THEN
          GMD_VALIDITY_RULES.get_formula_cost (p_formula_id => l_formula_id
                                              ,p_requested_qty => l_quantity
                                              ,p_requested_uom => l_uom
                                              ,p_product_id => get_rec.inventory_item_id
                                              ,p_organization_id   => get_rec.organization_id
                                              ,X_unit_cost => l_unit_cost
                                              ,X_total_cost => l_total_cost
                                              ,X_return_status => l_return_status);
          IF l_return_status <> FND_API.g_ret_sts_success THEN
            RAISE GET_FORMULA_COST_ERR;
          END IF;
        END IF;
      END IF; /* IF p_least_cost_validity = 'T' */
      GMD_VALIDITY_RULES.insert_val_temp_tbl(p_val_rec => get_rec
                                            ,p_unit_cost => l_unit_cost
                                            ,p_total_cost => l_total_cost);
    END LOOP;
  END IF;

  i := 0;
  FOR l_rec IN Cur_get_VR LOOP
    i := i + 1;
    x_recipe_validity_out(i).recipe_validity_rule_id := l_rec.recipe_validity_rule_id ;
    x_recipe_validity_out(i).recipe_id               := l_rec.recipe_id ;
    x_recipe_validity_out(i).orgn_code               := l_rec.orgn_code ;
    x_recipe_validity_out(i).recipe_use              := l_rec.recipe_use ;
    x_recipe_validity_out(i).preference              := l_rec.preference ;
    x_recipe_validity_out(i).start_date              := l_rec.start_date ;
    x_recipe_validity_out(i).end_date                := l_rec.end_date ;
    x_recipe_validity_out(i).min_qty                 := l_rec.min_qty ;
    x_recipe_validity_out(i).max_qty                 := l_rec.max_qty ;
    x_recipe_validity_out(i).std_qty                 := l_rec.std_qty ;
    x_recipe_validity_out(i).inv_min_qty             := l_rec.inv_min_qty ;
    x_recipe_validity_out(i).inv_max_qty             := l_rec.inv_max_qty ;
    x_recipe_validity_out(i).text_code               := l_rec.text_code ;
    x_recipe_validity_out(i).attribute_category      := l_rec.attribute_category ;
    x_recipe_validity_out(i).attribute1              := l_rec.attribute1 ;
    x_recipe_validity_out(i).attribute2              := l_rec.attribute2 ;
    x_recipe_validity_out(i).attribute3              := l_rec.attribute3 ;
    x_recipe_validity_out(i).attribute4              := l_rec.attribute4 ;
    x_recipe_validity_out(i).attribute5              := l_rec.attribute5 ;
    x_recipe_validity_out(i).attribute6              := l_rec.attribute6 ;
    x_recipe_validity_out(i).attribute7              := l_rec.attribute7 ;
    x_recipe_validity_out(i).attribute8              := l_rec.attribute8 ;
    x_recipe_validity_out(i).attribute9              := l_rec.attribute9 ;
    x_recipe_validity_out(i).attribute10             := l_rec.attribute10 ;
    x_recipe_validity_out(i).attribute11             := l_rec.attribute11;
    x_recipe_validity_out(i).attribute12             := l_rec.attribute12 ;
    x_recipe_validity_out(i).attribute13             := l_rec.attribute13 ;
    x_recipe_validity_out(i).attribute14             := l_rec.attribute14 ;
    x_recipe_validity_out(i).attribute15             := l_rec.attribute15 ;
    x_recipe_validity_out(i).attribute16             := l_rec.attribute16 ;
    x_recipe_validity_out(i).attribute17             := l_rec.attribute17 ;
    x_recipe_validity_out(i).attribute18             := l_rec.attribute18 ;
    x_recipe_validity_out(i).attribute19             := l_rec.attribute19 ;
    x_recipe_validity_out(i).attribute20             := l_rec.attribute20 ;
    x_recipe_validity_out(i).attribute21             := l_rec.attribute21 ;
    x_recipe_validity_out(i).attribute22             := l_rec.attribute22 ;
    x_recipe_validity_out(i).attribute23             := l_rec.attribute23 ;
    x_recipe_validity_out(i).attribute24             := l_rec.attribute24 ;
    x_recipe_validity_out(i).attribute25             := l_rec.attribute25 ;
    x_recipe_validity_out(i).attribute26             := l_rec.attribute26 ;
    x_recipe_validity_out(i).attribute27             := l_rec.attribute27 ;
    x_recipe_validity_out(i).attribute28             := l_rec.attribute28 ;
    x_recipe_validity_out(i).attribute29             := l_rec.attribute29 ;
    x_recipe_validity_out(i).attribute30             := l_rec.attribute30 ;
    x_recipe_validity_out(i).created_by              := l_rec.created_by ;
    x_recipe_validity_out(i).creation_date           := l_rec.creation_date ;
    x_recipe_validity_out(i).last_updated_by         := l_rec.last_updated_by ;
    x_recipe_validity_out(i).last_update_date        := l_rec.last_update_date ;
    x_recipe_validity_out(i).last_update_login       := l_rec.last_update_login ;
    x_recipe_validity_out(i).validity_rule_status    := l_rec.validity_rule_status ;
    x_recipe_validity_out(i).planned_process_loss    := l_rec.planned_process_loss ;
    x_recipe_validity_out(i).organization_id         := l_rec.organization_id ;
    x_recipe_validity_out(i).inventory_item_id       := l_rec.inventory_item_id ;
    x_recipe_validity_out(i).revision                := l_rec.revision ;
    x_recipe_validity_out(i).detail_uom              := l_rec.detail_uom ;
    x_recipe_validity_out(i).unit_cost		 := l_rec.unit_cost ;
    x_recipe_validity_out(i).total_cost		 := l_rec.total_cost ;
  END LOOP;

  -- standard call to get msge cnt, and if cnt is 1, get mesg info
  Fnd_msg_pub.Count_and_get (P_count => X_msg_count, P_data => X_msg_data);

EXCEPTION
   WHEN GET_FORMULA_COST_ERR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);
   WHEN Fnd_api.G_exc_error THEN
      X_return_code              := SQLCODE;
      X_return_status            := Fnd_api.G_ret_sts_error;
      Fnd_msg_pub.Count_and_get ( P_count=> X_msg_count,
                                  P_data=> X_msg_data );
   WHEN Fnd_api.G_exc_unexpected_error  THEN
      X_return_code              := SQLCODE;
      X_return_status            := Fnd_api.G_ret_sts_unexp_error;
      Fnd_msg_pub.Count_and_get ( P_count=> X_msg_count,
                                  P_data=> X_msg_data );
   WHEN OTHERS THEN
      X_return_code              := SQLCODE;
      X_return_status            := Fnd_api.G_ret_sts_error;
      Fnd_msg_pub.Count_and_get ( P_count=> X_msg_count,
                                  P_data=> X_msg_data );
END Get_all_validity_rules;

/*======================================================================
--  PROCEDURE :
--   get_validity_scale_factor
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for deriving the validity rule
--    scale factor based on the std qty and the formula product qty.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_validity_scale_factor (p_recipe_id, p_item_id, p_std_qty, p_std_um,
--                               x_scale_factor, x_return_status);
--
--
--===================================================================== */
PROCEDURE get_validity_scale_factor(p_recipe_id           IN  NUMBER ,
                                    p_item_id             IN  NUMBER ,
                                    p_std_qty             IN  NUMBER ,
                                    p_std_um              IN  VARCHAR2 ,
                                    x_scale_factor        OUT NOCOPY NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_product_lines IS
    SELECT qty, detail_uom
    FROM   gmd_recipes_b r, fm_matl_dtl d
    WHERE  r.recipe_id = p_recipe_id
    AND    r.formula_id = d.formula_id
    AND    d.line_type = 1
    AND    d.inventory_item_id = p_item_id;
  l_prod_rec    Cur_get_product_lines%ROWTYPE;
  l_prod_qty    NUMBER DEFAULT 0;
  l_temp_qty    NUMBER;

  ITEM_NOT_FOUND        EXCEPTION;
  UOM_CONVERSION_ERR    EXCEPTION;
BEGIN
  /* Let us initialize the return status to success */
  x_return_status := FND_API.g_ret_sts_success;

  /* Let us fetch the product quantities in the formula for the item passed in */
  OPEN Cur_get_product_lines;
  FETCH Cur_get_product_lines INTO l_prod_rec;
  IF Cur_get_product_lines%NOTFOUND THEN
    CLOSE Cur_get_product_lines;
    RAISE ITEM_NOT_FOUND;
  END IF;
  WHILE Cur_get_product_lines%FOUND
  LOOP
    IF l_prod_rec.detail_uom = p_std_um THEN
      l_prod_qty := l_prod_qty + l_prod_rec.qty;
    ELSE
     -- NPD Conv. Changed the call to INV_CONVERT.inv_um_convert from gmicuom.uom_conversion
     l_temp_qty := INV_CONVERT.inv_um_convert(item_id        => p_item_id
                                             ,precision      => 5
                                             ,from_quantity  => l_prod_rec.qty
                                             ,from_unit      => l_prod_rec.detail_uom
                                             ,to_unit        => p_std_um
                                             ,from_name      => NULL
                                             ,to_name	     => NULL);
      IF l_temp_qty < 0 THEN
        RAISE uom_conversion_err;
      ELSE
        l_prod_qty := l_prod_qty + l_temp_qty;
      END IF;
    END IF; /* IF l_prod_rec.item_um = p_std_um */
    FETCH Cur_get_product_lines INTO l_prod_rec;
  END LOOP; /* WHILE Cur_get_product_lines%FOUND */
  CLOSE Cur_get_product_lines;

  /* OK, now we have the product qty let us evaluate the ratio */
  IF l_prod_qty > 0 THEN
    x_scale_factor := p_std_qty / l_prod_qty;
  ELSE
    x_scale_factor := p_std_qty;
  END IF;
EXCEPTION
  WHEN item_not_found THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN uom_conversion_err THEN
    x_return_status := FND_API.g_ret_sts_error;
    uom_conversion_mesg (p_item_id, l_prod_rec.detail_uom, p_std_um);
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg ('GMD_VALIDITY_RULES', 'GET_VALIDITY_SCALE_FACTOR');
END get_validity_scale_factor;

/*======================================================================
--  PROCEDURE :
--   get_validity_output_factor
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for deriving the validity rule
--    scale factor based on the std qty and the formula product qty.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_validity_output_factor (p_recipe_id, p_item_id, p_std_qty, p_std_um,
--                               x_scale_factor, x_return_status);
--
--
--===================================================================== */
PROCEDURE get_validity_output_factor(p_recipe_id           IN  NUMBER ,
                                     p_item_id             IN  NUMBER ,
                                     p_std_qty             IN  NUMBER ,
                                     p_std_um              IN  VARCHAR2 ,
                                     x_scale_factor        OUT NOCOPY NUMBER,
                                     x_return_status       OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_tot_qty IS
    SELECT f.formula_id, total_output_qty, yield_uom
    FROM   fm_form_mst_b f, gmd_recipes_b r
    WHERE  r.recipe_id = p_recipe_id
    AND    r.formula_id = f.formula_id;

  l_form_rec            Cur_get_tot_qty%ROWTYPE;
  l_total_output_qty    NUMBER;
  l_scaled_output_qty   NUMBER;
  l_ing_qty             NUMBER;
  l_temp_qty            NUMBER;
  l_scale_factor        NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_uom                 mtl_units_of_measure.unit_of_measure%TYPE;

BEGIN
  /* Let us initialize the return status to success */
  x_return_status := FND_API.g_ret_sts_success;

  /* Lets get the scale factor between the validity std qty and the formula product qty */
  gmd_validity_rules.get_validity_scale_factor (p_recipe_id => p_recipe_id
                                                ,p_item_id => p_item_id
                                                ,p_std_qty => p_std_qty
                                                ,p_std_um => p_std_um
                                                ,x_scale_factor => l_scale_factor
                                                ,x_return_status => x_return_status);

  OPEN Cur_get_tot_qty;
  FETCH Cur_get_tot_qty INTO l_form_rec;
  CLOSE Cur_get_tot_qty;

  IF l_form_rec.total_output_qty IS NULL THEN
    /* If the total output qty was not calculated previously let us recalculate it */
    l_uom := p_std_um;
    GMD_COMMON_VAL.Calculate_total_qty(formula_id => l_form_rec.formula_id,
                                        x_product_qty => l_total_output_qty,
                                        x_ingredient_qty => l_ing_qty,
                                        x_uom => l_uom,
                                        x_return_status => x_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data);
  ELSE
    l_total_output_qty := l_form_rec.total_output_qty;
    l_uom := l_form_rec.yield_uom;
  END IF;

  /* Let us now fetch the total output qty based on the factor derived from std qty */
  GMD_COMMON_VAL.Calculate_total_qty(formula_id => l_form_rec.formula_id,
                                      x_product_qty => l_scaled_output_qty,
                                      x_ingredient_qty => l_ing_qty,
                                      x_uom => l_uom,
                                      x_return_status => x_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data => l_msg_data,
                                      p_scale_factor => l_scale_factor,
                                      p_primaries => 'OUTPUTS');

  /* OK, now we have the scaled and the formula total qty let us evaluate the ratio */
  IF l_scaled_output_qty > 0 THEN
    x_scale_factor := l_scaled_output_qty / l_total_output_qty;
  ELSIF l_scaled_output_qty IS NOT NULL THEN
    x_scale_factor := l_scaled_output_qty;
  ELSE
    x_scale_factor := 1;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg ('GMD_VALIDITY_RULES', 'GET_VALIDITY_OUTPUT_FACTOR');
END get_validity_output_factor;

/*=================================================================================
--  PROCEDURE :
--   insert_val_temp_tbl
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for inserting the validity rule to the
--    temp table.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    insert_val_temp_tbl
--
--  HISTORY
--   Thomas Daniel  16-Nov-2005 Created.
--===================================================================== */
PROCEDURE insert_val_temp_tbl (p_val_rec IN GMD_RECIPE_VALIDITY_RULES%ROWTYPE
                              ,p_unit_cost IN NUMBER
                              ,p_total_cost IN NUMBER) IS
BEGIN
  INSERT INTO GMD_VAL_RULE_GTMP(
	recipe_validity_rule_id, recipe_id              , orgn_code              , recipe_use             ,
	preference             , start_date             , end_date               , min_qty                ,
	max_qty                , std_qty                , inv_min_qty            , inv_max_qty            ,
	text_code              , attribute_category     , attribute1             , attribute2             ,
	attribute3             , attribute4             , attribute5             , attribute6             ,
	attribute7             , attribute8             , attribute9             , attribute10            ,
	attribute11            , attribute12            , attribute13            , attribute14            ,
	attribute15            , attribute16            , attribute17            , attribute18            ,
	attribute19            , attribute20            , attribute21            , attribute22            ,
	attribute23            , attribute24            , attribute25            , attribute26            ,
	attribute27            , attribute28            , attribute29            , attribute30            ,
	created_by             , creation_date          , last_updated_by        , last_update_date       ,
	last_update_login      , validity_rule_status   , planned_process_loss   , organization_id        ,
	inventory_item_id      , revision               , detail_uom             , unit_cost		  ,
	total_cost	       , delete_mark)
  VALUES
	(
	p_val_rec.recipe_validity_rule_id, p_val_rec.recipe_id              ,
	p_val_rec.orgn_code              , p_val_rec.recipe_use             ,
	p_val_rec.preference             , p_val_rec.start_date             ,
	p_val_rec.end_date               , p_val_rec.min_qty                ,
	p_val_rec.max_qty                , p_val_rec.std_qty                ,
	p_val_rec.inv_min_qty            , p_val_rec.inv_max_qty            ,
	p_val_rec.text_code              , p_val_rec.attribute_category     ,
	p_val_rec.attribute1             , p_val_rec.attribute2             ,
	p_val_rec.attribute3             , p_val_rec.attribute4             ,
	p_val_rec.attribute5             , p_val_rec.attribute6             ,
	p_val_rec.attribute7             , p_val_rec.attribute8             ,
	p_val_rec.attribute9             , p_val_rec.attribute10            ,
	p_val_rec.attribute11            , p_val_rec.attribute12            ,
	p_val_rec.attribute13            , p_val_rec.attribute14            ,
	p_val_rec.attribute15            , p_val_rec.attribute16            ,
	p_val_rec.attribute17            , p_val_rec.attribute18            ,
	p_val_rec.attribute19            , p_val_rec.attribute20            ,
	p_val_rec.attribute21            , p_val_rec.attribute22            ,
	p_val_rec.attribute23            , p_val_rec.attribute24            ,
	p_val_rec.attribute25            , p_val_rec.attribute26            ,
	p_val_rec.attribute27            , p_val_rec.attribute28            ,
	p_val_rec.attribute29            , p_val_rec.attribute30            ,
	p_val_rec.created_by             , p_val_rec.creation_date          ,
	p_val_rec.last_updated_by        , p_val_rec.last_update_date       ,
	p_val_rec.last_update_login      , p_val_rec.validity_rule_status   ,
	p_val_rec.planned_process_loss   , p_val_rec.organization_id        ,
	p_val_rec.inventory_item_id      , p_val_rec.revision               ,
	p_val_rec.detail_uom             , p_unit_cost		            ,
	p_total_cost		         , p_val_rec.delete_mark);
END insert_val_temp_tbl;


/*=================================================================================
--  PROCEDURE :
--   get_formula_cost
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for scaling the formula appropriately
--    and getting the cost for the formula.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_formula_cost
--
--  HISTORY
--   Thomas Daniel  16-Nov-2005 Created.
--===================================================================== */
PROCEDURE Get_Formula_Cost (
   p_formula_id            IN  NUMBER,
   p_requested_qty         IN  NUMBER,
   p_requested_uom         IN  VARCHAR2,
   p_product_id            IN  NUMBER,
   p_organization_id       IN  NUMBER,
   X_unit_cost             OUT NOCOPY  NUMBER,
   X_total_cost            OUT NOCOPY  NUMBER,
   X_return_status         OUT NOCOPY  VARCHAR2) IS

  CURSOR Cur_get_cost_method (v_orgn_id NUMBER) IS
    SELECT Cost_Type, cost_source
    FROM gmd_tech_parameters_b
    WHERE organization_id = v_orgn_id
    AND Default_cost_parameter = 1;

  CURSOR Cur_get_lines IS
    SELECT *
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
    ORDER BY line_type, line_no;

  l_cost_mthd	VARCHAR2(25);
  l_cost_source NUMBER(15);
  l_product_qty NUMBER := 0;
  l_product_uom VARCHAR2(3);
  l_scale_tab_in  GMD_COMMON_SCALE.scale_tab;
  l_scale_tab_out GMD_COMMON_SCALE.scale_tab;
  l_count  BINARY_INTEGER := 0;
  l_return_status VARCHAR2(1);
  l_return_id BINARY_INTEGER;
  l_cost NUMBER;
  l_ing_cost NUMBER;
  l_ing_qty NUMBER := 0;
  l_organization_id BINARY_INTEGER;
  l_msg_count BINARY_INTEGER;
  l_msg_data VARCHAR2(2000);
  l_cost_component_class_id BINARY_INTEGER;
  l_cost_analysis_code VARCHAR2(20);
  l_rows BINARY_INTEGER;

  SCALE_ERROR	EXCEPTION;
BEGIN
  /* Initialize return status to success */
  X_return_status := FND_API.G_RET_STS_SUCCESS;

  l_organization_id := P_organization_id;

  /* Get the cost source organization for the organization passed in */
  IF G_cost_source_orgn_id IS NULL THEN
    GMD_API_GRP.FETCH_PARM_VALUES(P_orgn_id       => l_organization_id,
                                  P_parm_name     => 'GMD_COST_SOURCE_ORGN',
                                  P_parm_value    => G_cost_source_orgn_id,
				  x_return_status => l_return_status);

  END IF;
  -- Get cost method in cost source orgn

  IF G_default_cost_mthd IS NULL THEN
    OPEN Cur_get_cost_method(l_organization_id);
    FETCH Cur_get_cost_method INTO l_cost_mthd, l_cost_source;
    CLOSE Cur_get_cost_method;
  END IF;

  IF l_cost_mthd IS NULL THEN
    OPEN Cur_get_cost_method(G_cost_source_orgn_id);
    FETCH Cur_get_cost_method INTO G_default_cost_mthd, G_cost_source;
    CLOSE Cur_get_cost_method;
  END IF;

  X_unit_cost := 0;
  X_total_cost := 0;

  FOR l_rec IN Cur_get_lines LOOP
    l_count := l_count + 1;
    l_scale_tab_in(l_count).line_no := l_rec.line_no;
    l_scale_tab_in(l_count).line_type := l_rec.line_type;
    l_scale_tab_in(l_count).inventory_item_id := l_rec.inventory_item_id;
    l_scale_tab_in(l_count).qty := l_rec.qty;
    l_scale_tab_in(l_count).detail_uom := l_rec.detail_uom;
    l_scale_tab_in(l_count).scale_type := l_rec.scale_type;
    l_scale_tab_in(l_count).contribute_yield_ind := l_rec.contribute_yield_ind;
    l_scale_tab_in(l_count).scale_multiple := l_rec.scale_multiple;
    l_scale_tab_in(l_count).scale_rounding_variance := l_rec.scale_rounding_variance;
    l_scale_tab_in(l_count).rounding_direction := l_rec.rounding_direction;
    IF (l_rec.line_type = 1) AND
       (p_product_id = l_rec.inventory_item_id) THEN
      l_product_qty := l_product_qty + l_rec.qty;
      l_product_uom := l_rec.detail_uom;
    END IF;
  END LOOP;

  /* Lets check if we need to scale the formula based on the requested qty */
  IF (l_product_qty <> p_requested_qty) OR
     (p_requested_uom <> l_product_uom) THEN
    GMD_COMMON_SCALE.scale(p_scale_tab => l_scale_tab_in
                          ,p_orgn_id => G_cost_source_orgn_id
                          ,p_scale_factor => p_requested_qty / l_product_qty
                          ,p_primaries => 'PRODUCT'
                          ,x_scale_tab => l_scale_tab_out
                          ,x_return_status => l_return_status);
    IF l_return_status <> FND_API.G_ret_sts_success THEN
      RAISE SCALE_ERROR;
    END IF;
  ELSE
    l_scale_tab_out := l_scale_tab_in;
  END IF;

  -- Now lets loop through the scaled tab and calculate the total cost
  FOR i IN 1..l_scale_tab_out.COUNT LOOP
    -- Get cost for each ingredient
    IF l_scale_tab_out(i).line_type = -1 THEN
      GMD_LCF_FETCH_PKG.load_cost_values (V_orgn_id => l_organization_id
                                         ,V_inv_item_id => l_scale_tab_out(i).inventory_item_id
                                         ,V_cost_type => NVL(l_cost_mthd,G_default_cost_mthd )
                                         ,V_date => SYSDATE
                                         ,V_cost_orgn => NVL(G_cost_source_orgn_id, l_organization_id)
                                         ,V_source => NVL(l_cost_source,G_cost_source)
                                         ,X_value => l_cost);
      IF NVL(l_cost,0) > 0 THEN
        l_ing_cost := NVL(l_ing_cost,0) + NVL(l_cost, 0) * l_scale_tab_out(i).qty;
      END IF;
      l_ing_qty := l_ing_qty + l_scale_tab_out(i).qty;
    END IF;
  END LOOP;
  X_total_cost := l_ing_cost;
  IF l_ing_qty > 0 THEN
    X_unit_cost := l_ing_cost / l_ing_qty;
  END IF;
EXCEPTION
  WHEN SCALE_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END Get_Formula_Cost;


END GMD_VALIDITY_RULES;

/
