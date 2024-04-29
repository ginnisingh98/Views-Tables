--------------------------------------------------------
--  DDL for Package Body GMD_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_STATUS_PUB" AS
/* $Header: GMDPSTSB.pls 120.6.12000000.2 2007/02/19 19:14:38 rajreddy ship $ */

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

  /*###############################################################
  # NAME
  #	Validate Operation
  # SYNOPSIS
  #	proc Validate_operation
  # DESCRIPTION
  #     Validates operation if all the resources are attached to
  #     every activity.
  ###############################################################*/
  PROCEDURE validate_operation(oprn_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2)IS

    CURSOR Cur_get_activities(poprn_id NUMBER) IS
      SELECT activity
      FROM   gmd_operation_activities a
      WHERE  NOT EXISTS (select 'X' from gmd_operation_resources r
                         where a.oprn_line_id = r.oprn_line_id)
      AND    a.oprn_id = poprn_id;

    x_count NUMBER;
    x_temp_rec Cur_get_activities%ROWTYPE;
    x_activity LONG;
    x_o_res_act_cnt NUMBER := 0;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FOR oprn_rec IN Cur_get_activities(oprn_id) LOOP
      x_o_res_act_cnt := x_o_res_act_cnt + 1;
      X_activity := x_activity||oprn_rec.activity||', ';
    END LOOP;
    IF (x_o_res_act_cnt > 0) THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_ATTACH_RESOURCES');
      FND_MESSAGE.SET_TOKEN('ACTIVITY',x_activity);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END validate_operation;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   modify_status                                                 */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update of status code  */
  /* is successful.                                                  */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* Shyam   05/30/03     Bug 2985443 Cannot change formula status   */
  /*                      to approved for general use or Lab use for */
  /*                      formulas created with total output qty =0  */
  /* Jeff Baird  02/11/2004  Changed gmd_api_pub to gmd_api_grp.     */
  /* Kalyani 07/03/2006   Bug 5347418 Fetched recipe_use and checked */
  /*                      if items are costing enabled if recipe use */
  /*                      is for costing.                            */
  /* kalyani 08/23/2006   Bug 5394532 Added code for substitution    */
  /* kalyani 09/19/2006   Bug 5534373 Removed code to check if       */
  /*                      product is GME enabled                     */
  /* =============================================================== */
  PROCEDURE modify_status
  ( p_api_version       IN         NUMBER    := 1
  , p_init_msg_list     IN         BOOLEAN   := TRUE
  , p_entity_name       IN         VARCHAR2
  , p_entity_id         IN         NUMBER    := NULL
  , p_entity_no         IN         VARCHAR2  := NULL
  , p_entity_version    IN         NUMBER    := NULL
  , p_to_status         IN         VARCHAR2
  , p_ignore_flag       IN 	   BOOLEAN   := FALSE
  , x_message_count     OUT NOCOPY NUMBER
  , x_message_list      OUT NOCOPY VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name           CONSTANT VARCHAR2(30) := 'MODIFY_STATUS';
  l_mesg_count	       NUMBER;
  l_mesg_data	       VARCHAR2(2000);
  l_return_status      VARCHAR2(1);
  l_entity_id          NUMBER;
  l_entity_no          VARCHAR2(32);
  l_entity_version     NUMBER;
  l_entity_name        VARCHAR2(100);
  l_entity_value       NUMBER;
  l_form_id	       NUMBER;
  l_org_id	       NUMBER;
  l_prod_exec_enabled  VARCHAR2(1);

  l_from_status        gmd_status_b.status_code%TYPE;
  l_from_status_type   gmd_status_b.status_type%TYPE;
  l_from_status_desc   gmd_status.description%TYPE;
  l_to_status_type     gmd_status_b.status_type%TYPE;
  l_to_status_desc     gmd_status.description%TYPE;

  l_target_status      gmd_status_next.target_status%TYPE;
  l_rework_status      gmd_status_next.rework_status%TYPE;
  l_pending_status     gmd_status_next.pending_status%TYPE;
  l_mesg_text          VARCHAR2(1000);

  l_eSignature_status  VARCHAR2(10);
  l_check_vr           NUMBER;
  l_toq                NUMBER;
  l_expr_items_found   NUMBER;

  l_table_name         VARCHAR2(30);

  l_recipe_use         NUMBER; -- Bug 5347418

  /* Cursor section */

  -- Checks if there is a target status for current status */
  CURSOR validate_To_status(vStatus_to   VARCHAR2
                           ,vStatus_from VARCHAR2) IS
    SELECT a.status_type, a.description, b.target_status
    FROM   gmd_status a, gmd_status_next b
    WHERE  a.status_code = vStatus_from
    AND    b.target_status = vStatus_to
    AND    a.status_code = b.current_status;

  CURSOR get_To_status_details(vStatus_to VARCHAR2) IS
    SELECT status_type, description
    FROM   gmd_status
    WHERE  status_code = vStatus_to;

  -- Gets the recipe details and its current status code
  CURSOR get_curr_recipe_status(vRecipe_id  NUMBER
                               ,vRecipe_no  VARCHAR2
                               ,vRecipe_vers NUMBER) IS
    SELECT recipe_id, recipe_no, recipe_version, recipe_status
    FROM   gmd_recipes_b
    WHERE  ((vRecipe_no IS NULL AND vRecipe_vers IS NULL) AND
            (recipe_id = vRecipe_id)) OR
           ((vRecipe_id IS NULL) AND
            (recipe_no = vRecipe_no AND recipe_version = vRecipe_vers));

  -- Gets the formula details and its current status code
  CURSOR get_curr_formula_status(vformula_id  NUMBER
                               ,vformula_no  VARCHAR2
                               ,vformula_vers NUMBER) IS
    SELECT formula_id, formula_no, formula_vers, formula_status
    FROM   fm_form_mst_b
    WHERE  ((vformula_no IS NULL AND vformula_vers IS NULL) AND
            (formula_id = vformula_id)) OR
           ((vformula_id IS NULL) AND
            (formula_no = vformula_no AND formula_vers = vformula_vers));

  -- Gets the routing details and its current status code
  CURSOR get_curr_routing_status(vrouting_id  NUMBER
                                ,vrouting_no  VARCHAR2
                                ,vrouting_vers NUMBER) IS
    SELECT routing_id, routing_no, routing_vers, routing_status
    FROM   gmd_routings_b
    WHERE  ((vrouting_no IS NULL AND vrouting_vers IS NULL) AND
            (routing_id = vrouting_id)) OR
           ((vrouting_id IS NULL) AND
            (routing_no = vrouting_no AND routing_vers = vrouting_vers));

  -- Gets the operation details and its current status code
  CURSOR get_curr_operation_status(voperation_id  NUMBER
                                  ,voperation_no  VARCHAR2
                                  ,voperation_vers NUMBER) IS
    SELECT oprn_id, oprn_no, oprn_vers, operation_status
    FROM   gmd_operations_b
    WHERE  ((voperation_no IS NULL AND voperation_vers IS NULL) AND
            (oprn_id = voperation_id)) OR
           ((voperation_id IS NULL) AND
            (oprn_no = voperation_no AND oprn_vers = voperation_vers));

  -- Gets the validity rule details and its current status code
  -- Bug 5347418 added recipe_use
  CURSOR get_curr_vr_status(vVR_id  NUMBER) IS
    SELECT recipe_validity_rule_id, validity_rule_status, recipe_use
    FROM   gmd_recipe_validity_rules
    WHERE  recipe_validity_rule_id = vVR_id;

  -- Bug 5394532
  -- Gets the substitution details and its current status code
  CURSOR get_curr_subst_status(vSubs_id  NUMBER
                               ,vSubs_no  VARCHAR2
                               ,vSubs_vers NUMBER) IS
    SELECT substitution_id, substitution_name, substitution_version, substitution_status
    FROM   gmd_item_substitution_hdr_b
    WHERE  ((vSubs_no IS NULL AND vSubs_vers IS NULL) AND
            (substitution_id = vSubs_id)) OR
           ((vSubs_id IS NULL) AND
            (substitution_name = vSubs_no AND substitution_version = vSubs_vers));

  -- Gets the formula associated with the val rule
  CURSOR get_vr_dets(vVR_id  NUMBER) IS
    SELECT r.formula_id, vr.organization_id
    FROM   gmd_recipes r, gmd_recipe_validity_rules vr
    WHERE  r.recipe_id = vr.recipe_id
      AND  vr.recipe_validity_rule_id = vVR_id;

    -- Recipe being changed to ON-HOLD - check for less than ON-HOLD and FROZEN
    Cursor check_val_rules_800(vEntity_id NUMBER) IS
     SELECT 1 from sys.dual
     WHERE EXISTS (
     		  SELECT recipe_validity_rule_id
     		  FROM gmd_status s, gmd_recipe_validity_rules  v
     		  WHERE recipe_id = vEntity_id
                    AND v.validity_rule_status = s.status_code
                    AND (to_number(s.status_type) < to_number('800')
                        OR s.status_type = '900') );

    -- Recipe being FROZEN - check for less than ON-HOLD (as on-hold stays on-hold )
    Cursor check_val_rules_900(vEntity_id NUMBER) IS
     SELECT 1 from sys.dual
     WHERE EXISTS (
     		  SELECT recipe_validity_rule_id
     		  FROM gmd_status s, gmd_recipe_validity_rules  v
     		  WHERE recipe_id = vEntity_id
                    AND v.validity_rule_status = s.status_code
                    AND to_number(s.status_type) < to_number('800') );

    -- Recipe being OBSOLETED - thus check for less than obsolete
    Cursor check_val_rules_1000(vEntity_id NUMBER) IS
     SELECT 1 from sys.dual
     WHERE EXISTS (
     		  SELECT recipe_validity_rule_id
     		  FROM gmd_status s, gmd_recipe_validity_rules  v
     		  WHERE recipe_id = vEntity_id
                    AND v.validity_rule_status = s.status_code
                    AND to_number(s.status_type) < to_number('1000') );

    Cursor get_fm_toq(vEntity_id NUMBER) IS
      SELECT SUM(qty)
      FROM fm_matl_dtl
      WHERE formula_id = vEntity_id
      AND   line_type IN (1,2);


  -- Bug 4499534. Cursor to chk if product is process enabled
  CURSOR Cur_chk_prod_exec_enabled (V_val_rule_id NUMBER) IS
     -- Get process ececution enabled setting for the val rule orgn
     -- (Local val rules)
     SELECT i.process_execution_enabled_flag
     FROM   mtl_system_items i, gmd_recipe_validity_rules v
     WHERE  v.recipe_validity_rule_id = V_val_rule_id
       AND  i.inventory_item_id	= v.inventory_item_id
       AND  i.organization_id = v.organization_id
       AND  v.organization_id IS NOT NULL
     UNION
     -- Get process ececution enabled setting for the recipe owning orgn
     -- for Global recipes  (Global val rules)
     SELECT i.process_execution_enabled_flag
     FROM   mtl_system_items i, gmd_recipe_validity_rules v, gmd_recipes_b re
     WHERE  v.recipe_validity_rule_id = V_val_rule_id
       AND  i.inventory_item_id	= v.inventory_item_id
       AND  v.recipe_id = re.recipe_id
       AND  i.organization_id = re.owner_organization_id
       AND  v.organization_id IS NULL;

   CURSOR Cur_experimental_items(V_form_id NUMBER) IS
	SELECT COUNT(f.inventory_item_id)
	  FROM fm_matl_dtl f, mtl_system_items i
	 WHERE f.formula_id = V_form_id
	   AND f.inventory_item_id = i.inventory_item_id
	   AND f.organization_id = i.organization_id
	   AND i.eng_item_flag = 'Y';

    /* Define Exceptions */
    setup_failure                    EXCEPTION;
    status_update_failure            EXCEPTION;
    invalid_version                  EXCEPTION;

      -- defining internal functions
    FUNCTION get_status_meaning(P_status_code IN VARCHAR2)  RETURN VARCHAR2 IS
      CURSOR Cur_get IS
        SELECT meaning
        FROM   gmd_status
        WHERE  status_code = P_status_code;

        l_meaning  gmd_status.meaning%TYPE;
    BEGIN
      OPEN Cur_get;
      FETCH Cur_get INTO l_meaning;
      CLOSE Cur_get;

      Return l_meaning;
    END get_status_meaning;

  BEGIN

    SAVEPOINT modify_status;

    IF l_debug = 'Y' THEN
       gmd_debug.put_line('Begin of modify_status() ');
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Initialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
       gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
       RAISE setup_failure;
    END IF;

    /* Make sure we have call compatibility */
    IF NOT FND_API.compatible_api_call ( GMD_STATUS_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMD_STATUS_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Get the TO status type and description */
    OPEN get_To_status_details(P_to_status);
    FETCH get_To_status_details INTO l_to_status_type, l_to_status_desc;
      IF get_To_status_details%NOTFOUND THEN
         FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
         FND_MESSAGE.SET_TOKEN ('MISSING', FND_MESSAGE.GET);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_error;
         CLOSE get_To_status_details;
         RAISE status_update_failure;
      END IF;
    CLOSE get_To_status_details;

    /* If the P_entity_id value is not passed - then verify if the users have
       passed in the entity_no and entity_version */
    IF (UPPER(P_entity_name) like '%RECIPE%') THEN
        l_entity_name := 'RECIPE';
        OPEN get_curr_recipe_status(p_entity_id
                                   ,P_entity_no
                                   ,p_entity_version);
        FETCH get_curr_recipe_status INTO l_entity_id, l_entity_no,
                                          l_entity_version, l_from_status;
          IF get_curr_recipe_status%NOTFOUND THEN
             FND_MESSAGE.SET_NAME ('GMD', 'GMD_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING', l_entity_name);
             FND_MESSAGE.SET_TOKEN ('ID',P_entity_id);
             FND_MESSAGE.SET_TOKEN ('NO',P_entity_no);
             FND_MESSAGE.SET_TOKEN ('VERS',P_entity_version);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             CLOSE get_curr_recipe_status;
             RAISE status_update_failure;
          END IF;
        CLOSE get_curr_recipe_status;
    ELSIF (UPPER(P_entity_name) like '%FORMULA%') THEN
        l_entity_name := 'FORMULA';
        OPEN get_curr_formula_status(p_entity_id
                                   ,P_entity_no
                                   ,p_entity_version);
        FETCH get_curr_formula_status INTO l_entity_id, l_entity_no,
                                          l_entity_version, l_from_status;
          IF get_curr_formula_status%NOTFOUND THEN
             FND_MESSAGE.SET_NAME ('GMD', 'GMD_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING', l_entity_name);
             FND_MESSAGE.SET_TOKEN ('ID',P_entity_id);
             FND_MESSAGE.SET_TOKEN ('NO',P_entity_no);
             FND_MESSAGE.SET_TOKEN ('VERS',P_entity_version);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             CLOSE get_curr_formula_status;
             RAISE status_update_failure;
          END IF;
        CLOSE get_curr_formula_status;

        -- Bug 2985443 Cannot change of the formula status to approved for general
        -- use or Lab use for formulas created with a total output qty of zero
        IF (l_to_status_type IN (400,700)) THEN

           IF l_debug = 'Y' THEN
              gmd_debug.put_line('For TOQ - P_entity_id  is '||l_entity_id);
           END IF;

           OPEN  get_fm_toq(l_Entity_id);
           FETCH get_fm_toq INTO l_toq;
           CLOSE get_fm_toq;

           IF l_debug = 'Y' THEN
              gmd_debug.put_line('TOQ value is '||l_toq);
           END IF;

           IF (l_toq = 0) THEN
             FND_MESSAGE.SET_NAME('GMD','GMD_TOTAL_OUTPUT_ZERO');
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             RAISE status_update_failure;
           END IF;

	   -- Sriram - Bug 5035818
	   -- If formula To Status is apfgu, chk for experimental items
	   IF l_to_status_type = 700 THEN
	   	OPEN Cur_experimental_items(p_entity_id);
		FETCH Cur_experimental_items INTO l_expr_items_found;
		CLOSE Cur_experimental_items;
		IF l_expr_items_found > 0 THEN
			FND_MESSAGE.SET_NAME('GMD', 'GMD_EXPR_ITEMS_FOUND');
			FND_MSG_PUB.ADD;
			x_return_status := FND_API.g_ret_sts_error;
			RAISE status_update_failure;
		END IF;
	   END IF;

        END IF;

    ELSIF (UPPER(P_entity_name) like '%ROUTING%') THEN
        l_entity_name := 'ROUTING';
        OPEN get_curr_routing_status(p_entity_id
                                   ,P_entity_no
                                   ,p_entity_version);
        FETCH get_curr_routing_status INTO l_entity_id, l_entity_no,
                                          l_entity_version, l_from_status;
          IF get_curr_routing_status%NOTFOUND THEN
             FND_MESSAGE.SET_NAME ('GMD', 'GMD_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING', l_entity_name);
             FND_MESSAGE.SET_TOKEN ('ID',P_entity_id);
             FND_MESSAGE.SET_TOKEN ('NO',P_entity_no);
             FND_MESSAGE.SET_TOKEN ('VERS',P_entity_version);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             CLOSE get_curr_routing_status;
             RAISE status_update_failure;
          END IF;
        CLOSE get_curr_routing_status;
    ELSIF (UPPER(P_entity_name) like '%OPERATION%') THEN
        l_entity_name := 'OPERATION';
        OPEN get_curr_operation_status(p_entity_id
                                      ,P_entity_no
                                      ,p_entity_version);
        FETCH get_curr_operation_status INTO l_entity_id, l_entity_no,
                                             l_entity_version, l_from_status;
          IF get_curr_operation_status%NOTFOUND THEN
             FND_MESSAGE.SET_NAME ('GMD', 'GMD_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING', l_entity_name);
             FND_MESSAGE.SET_TOKEN ('ID',P_entity_id);
             FND_MESSAGE.SET_TOKEN ('NO',P_entity_no);
             FND_MESSAGE.SET_TOKEN ('VERS',P_entity_version);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             CLOSE get_curr_operation_status;
             RAISE status_update_failure;
          END IF;
        CLOSE get_curr_operation_status;

        /* For each Operation, check if its activities, and
           check if there at least one resource attached to the activities.
           If none of the activities for this operation have
           at least one resource then we prevent the change of
           status for this operation to 700 or 400. */
        IF (to_number(l_to_status_type) IN (400,700)) THEN
            validate_operation(l_entity_id, x_return_status);
            IF l_debug = 'Y' THEN
               gmd_debug.put_line('The return status after calling val operation is '||
                   x_return_status);
            END IF;
            IF (x_return_status = FND_API.g_ret_sts_error) THEN
               RAISE status_update_failure;
            END IF;
        END IF;
    ELSIF (UPPER(P_entity_name) like '%VALIDITY%') THEN
        l_entity_name := 'VALIDITY';
        OPEN get_curr_vr_status(p_entity_id);
	-- Bug 53487418 added l_recipe_use
	FETCH get_curr_vr_status INTO l_entity_id, l_from_status, l_recipe_use;
          IF get_curr_vr_status%NOTFOUND THEN
             FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING','P_ENTITY_ID');
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             CLOSE get_curr_vr_status;
             RAISE status_update_failure;
          END IF;
        CLOSE get_curr_vr_status;
	IF (TO_NUMBER(l_to_status_type) IN (400,700)) THEN
                -- Bug# 5331823 Added the validation for Approved for Lab Use also

		-- Get formula id associated with the Val rule
		OPEN get_vr_dets(p_entity_id);
		FETCH get_vr_dets INTO l_form_id, l_org_id;
		CLOSE get_vr_dets;

		-- If not global val rule, chk if formula items are production enabled in
		-- validity rule orgn
		IF l_org_id IS NOT NULL THEN
		   -- Bug 5347418 Validate for prod or costing based on recipe_use
		   IF l_recipe_use IN (0,1) THEN
			GMD_API_GRP.check_item_exists(	p_formula_id	   => l_form_id,
							x_return_status	   => l_return_status,
							p_organization_id  => l_org_id,
							p_production_check => TRUE);

			IF l_return_status <> FND_API.g_ret_sts_success THEN
				FND_MSG_PUB.GET	(p_msg_index     => 1,
						 p_data		 => l_mesg_data,
						 p_encoded	 => 'F',
						 p_msg_index_out => l_mesg_count);
				--FND_MSG_PUB.ADD;
				x_return_status := FND_API.g_ret_sts_error;
				RAISE status_update_failure;
			END IF;
	          ELSIF l_recipe_use = 2 THEN
                        GMD_API_GRP.check_item_exists(	p_formula_id	   => l_form_id,
							x_return_status	   => l_return_status,
							p_organization_id  => l_org_id,
							p_costing_check => TRUE);

			IF l_return_status <> FND_API.g_ret_sts_success THEN
				FND_MSG_PUB.GET	(p_msg_index     => 1,
						 p_data		 => l_mesg_data,
						 p_encoded	 => 'F',
						 p_msg_index_out => l_mesg_count);
				--FND_MSG_PUB.ADD;
				x_return_status := FND_API.g_ret_sts_error;
				RAISE status_update_failure;
			END IF;
		  END IF;

		END IF;

		-- Bug 4499534. Chk if product is process execution enabled
		-- Bug 5534376/5534373 Removed code added for 4499534 as the above code
		-- for check_item_exists check for it.
	END IF;
    -- Bug 5394532
    ELSIF (UPPER(P_entity_name) like '%SUBSTITUTION%') THEN
        l_entity_name := 'SUBSTITUTION';
        OPEN get_curr_subst_status(p_entity_id
                                   ,P_entity_no
                                   ,p_entity_version);
        FETCH get_curr_subst_status INTO l_entity_id, l_entity_no,
                                          l_entity_version, l_from_status;
          IF get_curr_subst_status%NOTFOUND THEN
             FND_MESSAGE.SET_NAME ('GMD', 'GMD_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING', l_entity_name);
             FND_MESSAGE.SET_TOKEN ('ID',P_entity_id);
             FND_MESSAGE.SET_TOKEN ('NO',P_entity_no);
             FND_MESSAGE.SET_TOKEN ('VERS',P_entity_version);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             CLOSE get_curr_subst_status;
             RAISE status_update_failure;
          END IF;
        CLOSE get_curr_subst_status;
    ELSE -- not able to recognize the entity name
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNKNOWN_ENTITY');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME', P_entity_name);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.g_ret_sts_error;
        RAISE status_update_failure;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('The entity details are Entity_name = '||l_entity_name
           ||', Entity Id = '||l_entity_id||', Entity no is '||l_entity_no
           ||', Entity version is '||l_entity_version
           ||' and its status is '||l_from_status);

       gmd_debug.put_line('About to verify if the To status is valid '||
        'the From status is '||l_from_status||' and To status is '||P_to_status);
    END IF;


    /* Validate if this Entity can be modified by this user */
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => P_entity_name
                                        ,Entity_id  => l_entity_id) THEN
       RAISE status_update_failure;
    END IF;

   /* Verify if P_to_status is valid for the current status code */
   IF (P_to_status <> l_from_status) THEN
      OPEN validate_To_status(P_to_status ,l_from_status);
      FETCH validate_To_status INTO l_from_status_type, l_from_status_desc, l_target_status;
        IF validate_To_status%NOTFOUND THEN
           FND_MESSAGE.SET_NAME ('GMD', 'GMD_INV_TARGET_STATUS');
           FND_MESSAGE.SET_TOKEN ('TO_STATUS', l_to_status_desc);
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.g_ret_sts_error;
           CLOSE validate_To_status;
           RAISE status_update_failure;
        END IF;
      CLOSE validate_To_status;
   ELSE
     FND_MESSAGE.SET_NAME ('GMD', 'GMD_STS_SAME');
     FND_MESSAGE.SET_TOKEN ('NAME', P_entity_name);
     FND_MSG_PUB.ADD;
     RETURN;
   END IF;

   IF (l_debug = 'Y') THEN
      gmd_debug.put_line('From status type  = '||l_from_status_type
          ||', From Status desc  = '||l_from_status_desc
          ||' and target status = '||l_target_status);
   END IF;

   /* Check parent status */
   -- Check if entity is already in use before putting it on hold
   -- or obsoleting it.
   IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Checking the Parent status dependency for '||l_entity_name);
   END IF;
   IF (to_number(l_to_status_type) IN (800, 1000)) THEN
      IF (NOT gmd_status_code.check_parent_status(l_entity_name
	  				         ,l_entity_id)) THEN
        SELECT DECODE(l_entity_name,
                      'FORMULA','GMD_FORMULA_INUSE',
                      'RECIPE','GMD_RECIPE_BTCH_DEP',
                      'OPERATION','GMD_OPERATION_INUSE',
                      'ROUTING','GMD_ROUTING_INUSE',
                      'VALIDITY','GMD_VR_BTCH_DEP') INTO l_mesg_text
        FROM sys.dual;

        IF l_entity_name IN ('FORMULA','OPERATION','ROUTING') THEN
          FND_MESSAGE.SET_NAME('GMD',l_mesg_text);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.g_ret_sts_error;
          RAISE status_update_failure;
        ELSIF l_entity_name IN ('RECIPE','VALIDITY') THEN
          IF NOT P_ignore_flag THEN
             FND_MESSAGE.SET_NAME('GMD',l_mesg_text);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.g_ret_sts_error;
             RAISE status_update_failure;
          END IF; -- p_ignore_flag is false
        END IF; -- entity type check
      END IF; -- Checking parent status
   END IF;

   IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Checking the Dependent status, From status = '||l_from_status
      ||' To Status '||p_to_status);
   END IF;

   /* Check Dependent Status */
   SELECT DECODE(l_entity_name,
                 'FORMULA',1,
                 'RECIPE',3,
                 'OPERATION',2,
                 'ROUTING',4,
                 'VALIDITY',5) INTO l_entity_value
     FROM sys.dual;

   IF NOT ( GMD_STATUS_CODE.CHECK_DEPENDENT_STATUS
              (l_entity_value,
               l_entity_id,
               l_from_status,
               P_to_status) ) THEN
      /* if function from stored package returns FALSE, then
      * dependent entities do not have proper status, and this
      * entity's status cannot be changed.  Ex. routing has at
      * least one operation which is not approved.  The function
      * returns TRUE if entity does not have dependents (formula,
      * operation) or if to_status does not require the check
      * (frozen, on-hold, obsolete, some version of New). */
      FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS_DEPEND_NOT_APPROVED');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.g_ret_sts_error;
      RAISE status_update_failure;
   ELSE

     IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Dependent status are valid, about to check if recipes'||
      ' have any VRs , The from status type = '||l_from_status_type);
     END IF;

      -- Only when entity is 'RECIPE'
      IF (l_entity_name = 'RECIPE') THEN
        IF (to_number(l_to_status_type) = 800) THEN
          OPEN check_val_rules_800(l_entity_id) ;
          FETCH check_val_rules_800 into l_check_vr ;
          CLOSE check_val_rules_800 ;
        ELSIF (to_number(l_to_status_type) = 900 ) THEN
          OPEN check_val_rules_900(l_entity_id) ;
          FETCH check_val_rules_900 into l_check_vr ;
          CLOSE check_val_rules_900 ;
        ELSIF (to_number(l_to_status_type) = 1000) THEN
          IF (l_debug = 'Y') THEN
             gmd_debug.put_line('about to derive l_chk_vr, l_entity_id is '||l_entity_id);
          END IF;
          OPEN check_val_rules_1000(l_entity_id) ;
          FETCH check_val_rules_1000 into l_check_vr ;
          CLOSE check_val_rules_1000 ;
        END IF ;

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Dependent status are valid and check VR = '||l_check_vr);
        END IF;

        IF l_check_vr = 1 THEN
          /*ERES Implementation - If approvals are required for the */
          /*status change of the validity rules then the user has to */
          /*do them manually */
          IF GMD_ERES_UTILS.check_recipe_validity_eres (p_recipe_id => l_entity_id
                                                       ,p_to_status => P_to_status) THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_VLDT_APPR_REQD');
            FND_MESSAGE.SET_TOKEN('STATUS', l_to_status_desc);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.g_ret_sts_error;
            RAISE status_update_failure;
          END IF;

          /* Check if the VR for this recipe needs to be updated */
          IF (p_ignore_flag) THEN
             -- Now update the VR according to recipe status change
             IF (to_number(l_to_status_type) = 800) THEN
               -- Change status to ON-HOLD for less than ON-HOLD
               UPDATE gmd_recipe_validity_rules
               SET validity_rule_status = P_to_status
               WHERE recipe_id = l_entity_id
               AND  (to_number(validity_rule_status) < to_number('800') OR
                     to_number(validity_rule_status) between 900 and 999);
             ELSIF (to_number(l_to_status_type) = 900) THEN
               UPDATE gmd_recipe_validity_rules
               SET validity_rule_status = P_to_status
               WHERE recipe_id = l_entity_id
               AND  to_number(validity_rule_status) < to_number('800') ;
             ELSIF (to_number(l_to_status_type) = 1000) THEN
               IF (l_debug = 'Y') THEN
                 gmd_debug.put_line('Ignore flag was true and we are about update VR ');
               END IF;
               UPDATE gmd_recipe_validity_rules
               SET validity_rule_status = P_to_status
               WHERE recipe_id = l_entity_id
               AND  to_number(validity_rule_status) < to_number('1000') ;
             END IF;
          ELSE
            FND_MESSAGE.SET_NAME('GMD', 'GMD_RCP_VR_STATUS');
            FND_MESSAGE.SET_TOKEN('TO_STATUS',P_to_status);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.g_ret_sts_error;
            RAISE status_update_failure;
          END IF; /* if feedback is OK */
        END IF ; /* if validity rules exists , l_check_vr=1 */
      END IF; /* IF (l_entity_name = 'RECIPE') */
   END IF; /* Check Dependent Status */

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_from_status <> P_to_status) THEN
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line('About to get the pending and rework status ');
         END IF;
          /* Added the following code as part of ERES Implementation */
          l_pending_status := GMD_STATUS_CODE.get_pending_status
                              (p_from_status => l_from_status
                              ,p_to_status => P_to_status);

          l_rework_status := GMD_STATUS_CODE.get_rework_status
                             (p_from_status => l_from_status
                             ,p_to_status => P_to_status);

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Pending and Rework status is  '||l_pending_status
                     ||' and '||l_rework_status);

            gmd_debug.put_line('About to impement ERES for '||l_entity_name||
                     ' Entity id is '||l_entity_id||' the To status is '||P_to_status||
                     ' the entity no is '||l_entity_no||' the version is '||l_entity_version);
          END IF;

          IF (l_entity_name = 'FORMULA') THEN

            GMD_ERES_UTILS.update_formula_status
              (p_formula_id => l_entity_id
              ,p_from_status => l_from_status
              ,p_to_status => P_to_status
              ,p_pending_status => l_pending_status
              ,p_rework_status => l_rework_status
              ,p_object_name => l_entity_no
              ,p_object_version => l_entity_version
              ,p_called_from_form  => 'T'
              ,x_return_status => l_eSignature_status);

          ELSIF (l_entity_name = 'RECIPE') THEN

            IF l_debug = 'Y' THEN
              gmd_debug.put_line('In GMD Status Pub - About call ERES Util for update Recipe ');
            END IF;

            GMD_ERES_UTILS.update_recipe_status
              (p_recipe_id => l_entity_id
              ,p_from_status => l_from_status
              ,p_to_status => P_to_status
              ,p_pending_status => l_pending_status
              ,p_rework_status => l_rework_status
              ,p_object_name => l_entity_no
              ,p_object_version => l_entity_version
              ,p_called_from_form  => 'T'
              ,x_return_status => l_eSignature_status);

            IF l_debug = 'Y' THEN
              gmd_debug.put_line('In GMD Status Pub - After call ERES Util for update Recipe ');
            END IF;

          ELSIF(l_entity_name = 'OPERATION') THEN

            GMD_ERES_UTILS.update_operation_status
              (p_oprn_id => l_entity_id
              ,p_from_status => l_from_status
              ,p_to_status => P_to_status
              ,p_pending_status => l_pending_status
              ,p_rework_status => l_rework_status
              ,p_object_name => l_entity_no
              ,p_object_version => l_entity_version
              ,p_called_from_form  => 'T'
              ,x_return_status => l_eSignature_status);

          ELSIF(l_entity_name = 'ROUTING') THEN

            GMD_ERES_UTILS.update_routing_status
              (p_routing_id => l_entity_id
              ,p_from_status => l_from_status
              ,p_to_status => P_to_status
              ,p_pending_status => l_pending_status
              ,p_rework_status => l_rework_status
              ,p_object_name => l_entity_no
              ,p_object_version => l_entity_version
              ,p_called_from_form  => 'T'
              ,x_return_status => l_eSignature_status);

          ELSIF(l_entity_name = 'VALIDITY') THEN

            GMD_ERES_UTILS.update_validity_rule_status
              ( p_validity_rule_id  => l_entity_id
               ,p_from_status	     => l_from_status
	       ,p_to_status	     => P_to_status
	       ,p_pending_status    => l_pending_status
	       ,p_rework_status     => l_rework_status
	       ,p_called_from_form  => 'T'
	       ,x_return_status     => l_eSignature_status);
	  -- Bug 5394532
	  ELSIF (l_entity_name = 'SUBSTITUTION') THEN

            IF l_debug = 'Y' THEN
              gmd_debug.put_line('In GMD Status Pub - About call ERES Util for update substitution ');
            END IF;

            GMD_ERES_UTILS.update_substitution_status
              (p_substitution_id => l_entity_id
              ,p_from_status => l_from_status
              ,p_to_status => P_to_status
              ,p_pending_status => l_pending_status
              ,p_rework_status => l_rework_status
              ,p_called_from_form  => 'T'
              ,x_return_status => l_eSignature_status);

            IF l_debug = 'Y' THEN
              gmd_debug.put_line('In GMD Status Pub - After call ERES Util for update substitution ');
            END IF;
          END IF;

          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('After ERES implementation');
          END IF;

          IF (l_eSignature_status IN ('S','P') ) THEN
            x_return_status := l_eSignature_status;
            -- Commit your changes
            Commit;

            IF (x_return_status = 'P') THEN
              fnd_message.set_name('GMD','GMD_CONC_PEND_STATUS');

              fnd_message.set_token('OBJECT_TYPE',l_entity_name );
              fnd_message.set_token('OBJECT_NAME',l_entity_no );
              fnd_message.set_token('OBJECT_VERSION',l_entity_version);
              fnd_message.set_token('FROM_STATUS',get_status_meaning(l_from_status) );
              fnd_message.set_token('TO_STATUS',get_status_meaning(P_to_status) );
              fnd_message.set_token('PENDING_STATUS',get_status_meaning(l_pending_status) );
            END IF;

          ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE status_update_failure;
          END IF;

      END IF; --IF (l_from_status <> P_to_status)
   END IF;

   fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Status was updated successfullly');
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '
                 ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN status_update_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT modify_status;
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN setup_failure THEN
   	ROLLBACK TO SAVEPOINT modify_status;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
   WHEN app_exception.record_lock_exception THEN
        ROLLBACK TO SAVEPOINT modify_status;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line ('In locked exception section ');
        END IF;
        SELECT DECODE(P_entity_name,
                     'FORMULA','FM_FORM_MST_B',
                     'RECIPE','GMD_RECIPES_B',
                     'OPERATION','GMD_OPERATIONS_B',
                     'ROUTING','GMD_ROUTINGS_B',
                     'VALIDITY','GMD_RECIPE_VALIDITY_RULES') INTO l_table_name
        FROM sys.dual;
        gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                                'TABLE_NAME',l_table_name,
                                'KEY',NVL(p_entity_id, l_entity_id)
                                );
        -- Bug #3437582 (JKB) Changed gmd_api_pub to gmd_api_grp above.
        fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT modify_status;
         fnd_msg_pub.add_exc_msg (gmd_status_pub.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END Modify_status;

END GMD_STATUS_PUB;

/
