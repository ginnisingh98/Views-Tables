--------------------------------------------------------
--  DDL for Package Body GMD_FETCH_VALIDITY_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FETCH_VALIDITY_RULES" AS
/* $Header: GMDPVRFB.pls 120.3 2006/11/21 16:43:54 txdaniel ship $ */

G_PKG_NAME VARCHAR2(32);

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
--                        X_orgn_id, X_product_qty, X_uom, X_recipe_use,
--                        X_total_input, X_total_output, X_status,
--                        X_return_status, X_msg_count, X_msg_data,
--                        X_return_code, X_vr_table);
--
--
--===================================================================== */
PROCEDURE get_validity_rules(p_api_version         IN  NUMBER,
                             p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                             p_recipe_id           IN  NUMBER,
                             p_item_id             IN  NUMBER   := NULL,
                             p_organization_id     IN  NUMBER   := NULL,
                             p_product_qty         IN  NUMBER   := NULL,
                             p_uom                 IN  VARCHAR2 := NULL,
                             p_recipe_use          IN  VARCHAR2 := NULL,
                             p_total_input         IN  NUMBER,
                             p_total_output        IN  NUMBER,
                             p_status              IN  VARCHAR2 := NULL,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER,
                             x_msg_data            OUT NOCOPY VARCHAR2,
                             x_return_code         OUT NOCOPY NUMBER,
                             X_recipe_validity_out OUT NOCOPY recipe_validity_tbl) IS

  --  local Variables
  l_api_name           VARCHAR2(30) := 'get_validity_rules';
  l_api_version        NUMBER       := 1.0;
  i                    NUMBER       := 0;

  l_item_uom           VARCHAR2(4);
  l_line_um            VARCHAR2(4);
  l_quantity           NUMBER;
  l_item_qty           NUMBER;
  l_scale_type         NUMBER;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(240);
  l_return_code        NUMBER;
  l_return_status      VARCHAR2(10);
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
  l_yield_type         VARCHAR2(25);
  l_return_stat        VARCHAR2(10);

  --Cursor to get data based on recipe ID and input and output qty.
  CURSOR get_val(v_orgn_id NUMBER) IS
    SELECT recipe_validity_rule_id, recipe_id , organization_id, inventory_item_id ,revision, recipe_use,
           preference, start_date, end_date , min_qty, max_qty , std_qty, detail_uom,
           inv_min_qty, inv_max_qty, delete_mark, validity_rule_status
    FROM   gmd_recipe_validity_rules
    WHERE  recipe_id = p_recipe_id
           AND ((validity_rule_status BETWEEN 700 AND 799) OR (validity_rule_status BETWEEN 400 AND 499) )
           AND (p_recipe_use IS NULL OR recipe_use = p_recipe_use)
           AND ( organization_id = v_orgn_id OR v_orgn_id IS NULL)
           AND (TRUNC(SYSDATE) BETWEEN TRUNC(start_date) AND nvl(TRUNC(end_date),SYSDATE+1))
    ORDER BY preference;

  --Cursor to get data based on item.
  CURSOR get_val_item(v_orgn_id NUMBER, l_quantity NUMBER) IS
    SELECT recipe_validity_rule_id, recipe_id , organization_id, inventory_item_id ,revision, recipe_use,
           preference, start_date, end_date , min_qty, max_qty , std_qty, detail_uom,
           inv_min_qty, inv_max_qty, delete_mark, validity_rule_status
    FROM   gmd_recipe_validity_rules
    WHERE  (inventory_item_id = p_item_id)
           AND ((validity_rule_status BETWEEN 700 AND 799) OR (validity_rule_status BETWEEN 400 AND 499 ))
           AND (inv_min_qty <= l_quantity AND inv_max_qty >= l_quantity )
           AND ((organization_id = v_orgn_id) OR (v_orgn_id IS NULL))
           AND ((recipe_use = p_recipe_use) OR (p_recipe_use IS NULL))
    ORDER BY preference;

  CURSOR cur_item_uom(p_item_id NUMBER) IS
    SELECT primary_uom_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_item_id;

  CURSOR Cur_std_um (v_yield_type VARCHAR2 ) IS
    SELECT uom_code
    FROM   mtl_units_of_measure
    WHERE  uom_class = v_yield_type
    AND    base_uom_flag = 'Y';

  CURSOR Cur_get_qty(V_item_id NUMBER) IS
    SELECT qty, scale_type, detail_uom
    FROM   fm_matl_dtl
    WHERE  formula_id = l_formula_id
           AND inventory_item_id = V_item_id
           AND line_type = 1
    ORDER BY line_no;

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
BEGIN
  IF (NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;
  X_return_status := FND_API.G_RET_STS_SUCCESS;

-- FND_PROFILE.VALUE_SPECIFIC('FM_YIELD_TYPE',FND_GLOBAL.USER_ID);
GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => p_organization_id	,
				P_parm_name     => 'FM_YIELD_TYPE'	,
				P_parm_value    => l_yield_type		,
				X_return_status => l_return_stat	);

  /* Get yield type um */
  OPEN Cur_std_um(l_yield_type);
  FETCH Cur_std_um INTO l_yield_um;
  IF (Cur_std_um%NOTFOUND) THEN
    CLOSE Cur_std_um;
    RAISE NO_YIELD_TYPE_UM;
  END IF;
  CLOSE Cur_std_um;
  /* Check for possible ways to get validity rules */
  IF (p_recipe_id IS NOT NULL AND p_total_output IS NOT NULL OR
      p_recipe_id IS NOT NULL AND p_total_input IS NOT NULL) THEN
    /* Get the formula for this recipe */
    gmd_recipe_fetch_pub.get_formula_id(p_api_version    => p_api_version,
                                        p_init_msg_list  => p_init_msg_list,
	  	       			p_recipe_no      => NULL,
	 				p_recipe_version => NULL,
                                        p_recipe_id      => p_recipe_id,
                                        x_return_status  => l_return_status,
                                        x_msg_count      => l_msg_count,
					x_msg_data       => l_msg_data,
                                        x_return_code    => l_return_code,
                                        x_formula_id     => l_formula_id);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE GET_FORMULA_ERR;
    END IF;
    gmd_common_val.calculate_total_qty(formula_id       => l_formula_id,
                                       x_product_qty    => l_formula_output,
                                       x_ingredient_qty => l_formula_input,
				       x_uom		=> l_yield_um,
                                       x_return_status  => l_return_status,
 				       X_MSG_COUNT      => l_msg_count,
 				       X_MSG_DATA       => l_msg_data       );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE GET_TOTAL_QTY_ERR;
    END IF;
    IF (p_total_output IS NOT NULL) THEN
      /* Convert total output qty to standard UOM of FM_YIELD_TYPE */
      IF (p_uom <> l_yield_um) THEN
        -- l_total_output := gmicuom.uom_conversion(0, 0, p_total_output, p_uom, l_yield_um, 0);
        l_total_output := INV_CONVERT.inv_um_convert(item_id        => 0
                                                   ,precision       => 5
                                                   ,from_quantity   => p_total_output
                                                   ,from_unit       => p_uom
                                                   ,to_unit         => l_yield_um
                                                   ,from_name       => NULL
                                                   ,to_name	    => NULL);
      ELSE
        l_total_output := p_total_output;
      END IF;

      /* Try to get validity rules based on recipe ID and total output qty */
      /* Get the ratio of the batch output qty to the ratio of the formula ouput qty */
      gmd_fetch_validity_rules.get_output_ratio(p_formula_id     => l_formula_id,
                                                p_batch_output   => l_total_output,
                                                p_yield_um       => l_yield_um,
                                                p_formula_output => l_formula_output,
                                                x_return_status  => l_return_status,
                                                X_output_ratio   => l_output_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_OUTPUT_RATIO_ERR;
      END IF;
    ELSIF (p_total_input IS NOT NULL) THEN
      /* Try to get validity rules based on recipe ID and total input qty */

      /* Convert total input qty to standard UOM of FM_YIELD_TYPE */
      IF (p_uom <> l_yield_um) THEN
        -- l_total_input := gmicuom.uom_conversion(0, 0, p_total_input, p_uom, l_yield_um, 0);
        l_total_input := INV_CONVERT.inv_um_convert(item_id        => 0
                                                   ,precision      => 5
                                                   ,from_quantity  => p_total_input
                                                   ,from_unit      => p_uom
                                                   ,to_unit        => l_yield_um
                                                   ,from_name      => NULL
                                                   ,to_name	   => NULL);
      ELSE
        l_total_input := p_total_input;
      END IF;

      /* Get the product to ingredient ratio for the formula */
      gmd_fetch_validity_rules.get_ingredprod_ratio(p_formula_id        => l_formula_id,
                                                    p_yield_um          => l_yield_um,
                                                    x_return_status     => l_return_status,
                                                    X_ingred_prod_ratio => l_ingred_prod_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_INGREDPROD_RATIO_ERR;
      END IF;
      /* Get the ratio of the batch input to the formula input */
      gmd_fetch_validity_rules.get_batchformula_ratio(p_formula_id         => l_formula_id,
                                                      p_batch_input        => l_total_input,
                                                      p_yield_um           => l_yield_um,
                                                      p_formula_input      => l_formula_input,
                                                      x_return_status      => l_return_status,
                                                      X_batchformula_ratio => l_batchformula_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_BATCHFORMULA_RATIO_ERR;
      END IF;

      /* Get the contributing qty of the formula */
      gmd_fetch_validity_rules.get_contributing_qty(p_formula_id          => l_formula_id,
                                                    p_recipe_id           => p_recipe_id,
                                                    p_batchformula_ratio  => l_batchformula_ratio,
                                                    p_yield_um            => l_yield_um,
                                                    x_return_status       => l_return_status,
                                                    X_contributing_qty    => l_contributing_qty);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_CONTRIBUTING_QTY_ERR;
      END IF;
      /* Calculate actual contributing qty of formula */
      l_contributing_qty := l_contributing_qty * l_ingred_prod_ratio;

      /* Get the ratio of the product based on contributing qty */
      gmd_fetch_validity_rules.get_input_ratio(p_formula_id       => l_formula_id,
                                               p_contributing_qty => l_contributing_qty,
                                               p_yield_um         => l_yield_um,
                                               p_formula_output   => l_formula_output,
                                               x_return_status    => l_return_status,
                                               X_output_ratio     => l_output_ratio);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE GET_INPUT_RATIO_ERR;
      END IF;
    END IF;

    /* Get all the possible validity rules and check if it can be used for this input/output qty */
    FOR get_rec IN get_val(p_organization_id) LOOP
      OPEN Cur_get_qty(get_rec.inventory_item_id);
      FETCH Cur_get_qty INTO l_item_qty, l_scale_type, l_line_um;
      CLOSE Cur_get_qty;
      IF (l_scale_type = 1) THEN
        l_item_qty := l_item_qty * l_output_ratio;
        IF (l_line_um <> get_rec.detail_uom) THEN

             l_item_qty := INV_CONVERT.inv_um_convert(item_id        => get_rec.inventory_item_id
                                                     ,precision      => 5
                                                     ,from_quantity  => l_item_qty
                                                     ,from_unit      => l_line_um
                                                     ,to_unit        => get_rec.detail_uom
                                                     ,from_name      => NULL
                                                     ,to_name	     => NULL);

        END IF;
        IF (l_item_qty >= get_rec.min_qty AND l_item_qty <= get_rec.max_qty) THEN
          i := i + 1;
          x_recipe_validity_out(i).recipe_validity_rule_id := get_rec.recipe_validity_rule_id;
          x_recipe_validity_out(i).recipe_id               := get_rec.recipe_id;
          x_recipe_validity_out(i).inventory_item_id       := get_rec.inventory_item_id;
          x_recipe_validity_out(i).revision                := get_rec.revision;
          x_recipe_validity_out(i).recipe_use              := get_rec.recipe_use;
          x_recipe_validity_out(i).std_qty                 := get_rec.std_qty;
          x_recipe_validity_out(i).organization_id         := get_rec.organization_id;
          x_recipe_validity_out(i).preference              := get_rec.preference ;
          x_recipe_validity_out(i).start_date              := get_rec.start_date;
          x_recipe_validity_out(i).end_date                := get_rec.end_date;
          x_recipe_validity_out(i).min_qty                 := get_rec.min_qty;
          x_recipe_validity_out(i).max_qty                 := get_rec.max_qty;
          x_recipe_validity_out(i).std_qty                 := get_rec.std_qty;
          x_recipe_validity_out(i).detail_uom              := get_rec.detail_uom;
          x_recipe_validity_out(i).inv_min_qty             := get_rec.inv_min_qty;
          x_recipe_validity_out(i).inv_max_qty             := get_rec.inv_max_qty;
          x_recipe_validity_out(i).validity_rule_status    := get_rec.validity_rule_status;
        END IF;
      END IF;
    END LOOP;
  ELSIF (p_recipe_id IS NOT NULL) THEN
    /* Try to get validity rules based on recipe ID */
    FOR get_rec IN get_val(p_organization_id) LOOP
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      i := i + 1;
      x_recipe_validity_out(i).recipe_validity_rule_id := get_rec.recipe_validity_rule_id;
      x_recipe_validity_out(i).recipe_id               := get_rec.recipe_id;
      x_recipe_validity_out(i).inventory_item_id       := get_rec.inventory_item_id;
      x_recipe_validity_out(i).revision                := get_rec.revision;
      x_recipe_validity_out(i).recipe_use              := get_rec.recipe_use;
      x_recipe_validity_out(i).std_qty                 := get_rec.std_qty;
      x_recipe_validity_out(i).organization_id         := get_rec.organization_id;
      x_recipe_validity_out(i).preference              := get_rec.preference;
      x_recipe_validity_out(i).start_date              := get_rec.start_date;
      x_recipe_validity_out(i).end_date                := get_rec.end_date;
      x_recipe_validity_out(i).min_qty                 := get_rec.min_qty;
      x_recipe_validity_out(i).max_qty                 := get_rec.max_qty;
      x_recipe_validity_out(i).std_qty                 := get_rec.std_qty;
      x_recipe_validity_out(i).detail_uom              := get_rec.detail_uom;
      x_recipe_validity_out(i).inv_min_qty             := get_rec.inv_min_qty;
      x_recipe_validity_out(i).inv_max_qty             := get_rec.inv_max_qty;
      x_recipe_validity_out(i).validity_rule_status    := get_rec.validity_rule_status;
    END LOOP;
  ELSIF (p_item_id IS NOT NULL) THEN
    /* Try to get validity rules based on Item */
    OPEN cur_item_uom(p_item_id);
    FETCH cur_item_uom INTO l_item_uom;
    CLOSE cur_item_uom;
    IF (p_uom <> l_item_uom) THEN
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
    FOR get_rec IN get_val_item(p_organization_id, l_quantity) LOOP
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      i := i + 1;
      x_recipe_validity_out(i).recipe_validity_rule_id := get_rec.recipe_validity_rule_id;
      x_recipe_validity_out(i).recipe_id               := get_rec.recipe_id;
      x_recipe_validity_out(i).inventory_item_id       := get_rec.inventory_item_id;
      x_recipe_validity_out(i).revision                := get_rec.revision;
      x_recipe_validity_out(i).recipe_use              := get_rec.recipe_use;
      x_recipe_validity_out(i).std_qty                 := get_rec.std_qty;
      x_recipe_validity_out(i).organization_id         := get_rec.organization_id;
      x_recipe_validity_out(i).preference              := get_rec.preference;
      x_recipe_validity_out(i).start_date              := get_rec.start_date;
      x_recipe_validity_out(i).end_date                := get_rec.end_date;
      x_recipe_validity_out(i).min_qty                 := get_rec.min_qty;
      x_recipe_validity_out(i).max_qty                 := get_rec.max_qty;
      x_recipe_validity_out(i).std_qty                 := get_rec.std_qty;
      x_recipe_validity_out(i).detail_uom              := get_rec.detail_uom;
      x_recipe_validity_out(i).inv_min_qty             := get_rec.inv_min_qty;
      x_recipe_validity_out(i).inv_max_qty             := get_rec.inv_max_qty;
      x_recipe_validity_out(i).validity_rule_status    := get_rec.validity_rule_status;
    END LOOP;
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
      gmd_fetch_validity_rules.uom_conversion_mesg(p_item_id => p_item_id,
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
  l_conv_qty           NUMBER;
  l_total_fixed_qty    NUMBER := 0;
  X_item_id            NUMBER;
  X_item_um            VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR get_rec IN Cur_get_prods LOOP
    IF (get_rec.scale_type = 0) THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_item_um := get_rec.detail_uom;
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
      gmd_fetch_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_item_um,
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
  CURSOR Cur_get_details(V_line_type NUMBER) IS
    SELECT inventory_item_id, qty, detail_uom, scale_type, contribute_yield_ind
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = V_line_type;
  l_sum_prods	     NUMBER := 0;
  l_sum_ingreds	     NUMBER := 0;
  l_conv_qty           NUMBER := 0;
  X_item_id            NUMBER;
  X_item_um            VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Get sum of products in yield UM.
  FOR get_rec IN Cur_get_details(1) LOOP
    IF (get_rec.detail_uom <> p_yield_um) THEN
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
      IF (l_conv_qty < 0) THEN
        X_item_id := get_rec.inventory_item_id;
        X_item_um := get_rec.detail_uom;
        RAISE UOM_CONVERSION_ERROR;
      END IF;
      l_sum_prods := l_sum_prods + l_conv_qty;
    ELSE
      l_sum_prods := l_sum_prods + get_rec.qty;
    END IF;
  END LOOP;
  --Get sum of ingredients in yield UM contributing to yield.
  FOR get_rec IN Cur_get_details(-1) LOOP
    IF (get_rec.contribute_yield_ind = 'Y') THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_item_um := get_rec.detail_uom;
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
      gmd_fetch_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_item_um,
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
  X_item_um            VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR get_rec IN Cur_get_ingreds LOOP
    IF (get_rec.scale_type = 0) THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_item_um := get_rec.detail_uom;
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
      gmd_fetch_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_item_um,
                                                   p_to_um   => p_yield_um);
END get_batchformula_ratio;

/*======================================================================
--  PROCEDURE :
--   get_contributing_qty
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
--  Shyam  06/05/01  Modified call to process loss calc
--===================================================================== */
PROCEDURE get_contributing_qty(p_formula_id          IN  NUMBER,
                               p_recipe_id           IN  NUMBER,
                               p_batchformula_ratio  IN  NUMBER,
                               p_yield_um            IN  VARCHAR2,
                               X_contributing_qty    OUT NOCOPY NUMBER,
                               X_return_status       OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_ingreds IS
    SELECT inventory_item_id, qty, detail_uom, scale_type, contribute_yield_ind
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = -1;
  l_conv_qty           NUMBER := 0;
  l_process_loss       NUMBER := 0;
  X_item_id            NUMBER;
  X_item_um            VARCHAR2(4);
  X_status             VARCHAR2(100);
  l_process_rec        gmd_common_val.process_loss_rec;
  l_recipe_theo_loss   NUMBER := 0;
  l_msg_data   varchar2(240);
  l_msg_count number := 0;
  UOM_CONVERSION_ERROR EXCEPTION;
  PROCESS_LOSS_ERR     EXCEPTION;
BEGIN
  -- Initialize variable to 0.
  X_contributing_qty := 0;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* Loop through ingredients and determine total contributing qty */
  FOR get_rec IN Cur_get_ingreds LOOP
    IF (get_rec.contribute_yield_ind = 'Y') THEN
      /* Convert all ingredient values to yield UM and determine contributing qty */
      IF (get_rec.detail_uom <> p_yield_um) THEN
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_item_um := get_rec.detail_uom;
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
  gmd_common_val.calculate_process_loss(process_loss       => l_process_rec,
                                        Entity_type        => 'RECIPE',
                                        x_process_loss     => l_process_loss,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data,
                                        x_return_status    => X_status,
 					X_RECIPE_THEO_LOSS => l_recipe_theo_loss);

  IF (X_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE PROCESS_LOSS_ERR;
  END IF;
  X_contributing_qty := X_contributing_qty * (100 - l_process_loss);
  EXCEPTION
    WHEN UOM_CONVERSION_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      gmd_fetch_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_item_um,
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
--    get_contributing_qty (X_formula_id, X_contributing_qty, X_yield_um,
--                          X_formula_output, X_output_ratio, X_status);
--
--===================================================================== */
PROCEDURE get_input_ratio(p_formula_id       IN  NUMBER,
                          p_contributing_qty IN  NUMBER,
                          p_yield_um         IN  VARCHAR2,
                          p_formula_output   IN  NUMBER,
                          X_output_ratio     OUT NOCOPY NUMBER,
                          X_return_status    OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_prods IS
    SELECT inventory_item_id, qty, detail_uom, scale_type
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
           AND line_type = 1;
  l_contributing_qty   NUMBER := 0;
  l_formula_output     NUMBER := 0;
  l_conv_qty           NUMBER := 0;
  l_fixed_prod         NUMBER := 0;
  X_item_id            NUMBER;
  X_item_um            VARCHAR2(4);
  UOM_CONVERSION_ERROR EXCEPTION;
BEGIN
  FOR get_rec IN Cur_get_prods LOOP
    IF (get_rec.scale_type = 0) THEN
      IF (get_rec.detail_uom <> p_yield_um) THEN
        l_conv_qty := INV_CONVERT.inv_um_convert(item_id         => get_rec.inventory_item_id
                                                ,precision       => 5
                                                ,from_quantity   => get_rec.qty
                                                ,from_unit       => get_rec.detail_uom
                                                ,to_unit         => p_yield_um
                                                ,from_name       => NULL
                                                ,to_name	 => NULL);
        IF (l_conv_qty < 0) THEN
          X_item_id := get_rec.inventory_item_id;
          X_item_um := get_rec.detail_uom;
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
      gmd_fetch_validity_rules.uom_conversion_mesg(p_item_id => X_item_id,
                                                   p_from_um => X_item_um,
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

END gmd_fetch_validity_rules;

/
