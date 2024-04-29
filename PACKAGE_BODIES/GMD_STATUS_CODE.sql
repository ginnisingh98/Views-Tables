--------------------------------------------------------
--  DDL for Package Body GMD_STATUS_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_STATUS_CODE" AS
/* $Header: GMDSTATB.pls 120.1 2005/07/20 23:41:23 kkillams noship $ */

/* Purpose: The package has code used in status management                 */
/*          The package will usually be called from the Change Status form */
/*                                                                         */
/*                                                                         */
/* Check_Dependent_Status  FUNCTION                                        */
/*                                                                         */
/* MODIFICATION HISTORY                                                    */
/* Person      Date      Comments                                          */
/* ---------   ------    ------------------------------------------        */
/* L.Jackson   15Mar2001  Start                                            */

  FUNCTION CHECK_DEPENDENT_STATUS
     ( P_Entity_Type    NUMBER,
       P_Entity_id      NUMBER,
       P_Current_Status VARCHAR2,
       P_To_Status      VARCHAR2)       RETURN BOOLEAN IS

  /* Before the status of a higher entity can be changed, the status of dependent
   * entities must be checked.  Ex.  Before a routing can be changed from new to
   * approved for lab, all of its operations must be at least approved for lab, and
   * none of the operations can be on hold or obsoleted.
   */

  /* This check only applies if entity TO_STATUS is between 200 and 499 or
   *    between 500 and 799.  It does not matter what dependent entities' status
   *    are if higher entity is being changed to Frozen, On-Hold, Obsolete or New
   * This check only applies to routings, recipes and validity rules.
   *
   * Set a local variable to the lowest approval allowed for dependent entities.
   *   ie. if routing is requesting lab approval, all operations must be at least 400,
   *       approved for lab.
   *
   * IF TO_STATUS between 200 and 799 THEN
   *   Start the boolean Dependent_Status_Ok as TRUE.
   *   IF the entity is Routings THEN
   *     select operation_status from gmd_operations_vl where oprn_id is in
   *            (select oprn_id from fm_rout_dtl where routing_id is current routing)
   *     IF any operation_status returned by select is On-hold, Obsolete or less than
   *        the TO_STATUS of the routing, set the boolean to FALSE.
   *   IF the entity is Recipes THEN
   *     select formula_status from fm_form_mst where formula_id is in
   *            (select formula_id from gmd_recipes where recipe_id is current recipe)
   *     select routing_status from fm_rout_hdr where routing_id is in
   *            (select routing_id from gmd_recipes where recipe_id is current recipe)
   *     IF either formula or routing status returned by select is on-hold, obsolete
   *        or less than the TO_STATUS of the recipe, set the boolean to FALSE.
   *   IF the entity is Validity Rules THEN
   *     select recipe_status from gmd_recipes where recipe_id is in
   *            (select recipe_id from gmd_recipe_validity_rules where
   *                   recipe_validity_rule_id is current recipe_validity_rule_id)
   *     IF recipe_status returned by select is on-hold, obsolete or
   *        less than the TO_STATUS of the validity_rule, set the boolean to FALSE.
   * END IF;
   * Return the boolean Dependent_Status_Ok
   */

  TYPE Status_ref_cur IS REF CURSOR;
  Oprn_Status_cur         Status_ref_cur;
  Formula_Status_cur  Status_ref_cur;
  Routing_Status_cur  Status_ref_cur;
  Recipe_Status_cur       Status_ref_cur;

  l_cur_dependent_status  GMD_STATUS.STATUS_CODE%TYPE;
  l_cur_routing_status    GMD_STATUS.STATUS_CODE%TYPE;
  l_lowest_allowed_status GMD_STATUS.STATUS_CODE%TYPE;
  l_routing_defined       FM_ROUT_HDR.ROUTING_ID%TYPE;
  Dependent_Status_OK     BOOLEAN  := TRUE;

  BEGIN
  /*  entity_types: 3=recipe, 4=routing, 5=validity rule*/
  IF  P_entity_type in (3, 4, 5)
    AND  (P_TO_STATUS between 200 and 499
         OR
         P_TO_STATUS between 500 and 799) THEN

    IF P_TO_STATUS between 200 and 499 THEN
      l_lowest_allowed_status := 400;
    ELSE
       /*  P_TO_STATUS between 500 and 799) */
      l_lowest_allowed_status := 700;
    END IF;

    /*  *************** ROUTING ***************** */
    IF  P_entity_type = 4 THEN
             /* if entity is routing, check operations */
      OPEN  Oprn_Status_cur FOR
          Select        o.operation_status
            From        gmd_operations_vl o, fm_rout_dtl r
           Where    o.oprn_id = r.oprn_id
             and    r.routing_id = P_Entity_id;

        /*  Fetch 1st record */
      FETCH Oprn_Status_cur into l_cur_dependent_status;

      WHILE Dependent_Status_OK and Oprn_Status_cur%FOUND LOOP
        IF (l_cur_dependent_status between 800 and 899)
           OR (l_cur_dependent_status between 1000 and 1099)
           OR (l_cur_dependent_status < l_lowest_allowed_status)
           THEN
             Dependent_Status_OK := FALSE;
        ELSE
          FETCH Oprn_Status_cur into l_cur_dependent_status;
        END IF;
      END LOOP;

      CLOSE Oprn_Status_cur;

    /*  *************** RECIPE ***************** */
    ELSIF  P_entity_type = 3 THEN
             /* if entity is recipe, check formula and routing */
      OPEN  Formula_Status_cur FOR
          Select        f.formula_status, g.routing_id
            From        fm_form_mst f, gmd_recipes g
           Where    g.formula_id = f.formula_id
             and    g.recipe_id = P_Entity_id;
      FETCH Formula_Status_cur into l_cur_dependent_status, l_routing_defined;
      IF (l_cur_dependent_status between 800 and 899)
         OR (l_cur_dependent_status between 1000 and 1099)
         OR (l_cur_dependent_status < l_lowest_allowed_status)
         THEN
           Dependent_Status_OK := FALSE;
      END IF;
      CLOSE Formula_Status_cur;

             /* If a routing was defined for recipe, and the formula status is ok,
              * get the routing status */
      IF Dependent_Status_OK  AND l_routing_defined is not NULL THEN
        OPEN  Routing_Status_cur FOR
          Select        r.routing_status
            From        fm_rout_hdr r
           Where    r.routing_id = l_routing_defined;

        FETCH Routing_Status_cur into l_cur_routing_status;
        IF (l_cur_routing_status between 800 and 899)
           OR (l_cur_routing_status between 1000 and 1099)
           OR (l_cur_routing_status < l_lowest_allowed_status)
           THEN
             Dependent_Status_OK := FALSE;
        END IF;
        CLOSE Routing_Status_cur;
      END IF;
               /* end if routing is defined*/

    /*  *************** VALIDITY RULE ***************** */
    ELSIF  P_entity_type = 5 THEN
             /* if entity is validity_rule, check recipe */
      OPEN  Recipe_Status_cur FOR
          Select        g.recipe_status
            From        gmd_recipe_validity_rules vr, gmd_recipes g
           Where    vr.recipe_id = g.recipe_id
             and    vr.recipe_validity_rule_id = P_Entity_id;
      FETCH Recipe_Status_cur into l_cur_dependent_status;
      IF (l_cur_dependent_status between 800 and 899)
         OR (l_cur_dependent_status between 1000 and 1099)
         OR (l_cur_dependent_status < l_lowest_allowed_status)
         THEN
           Dependent_Status_OK := FALSE;
      END IF;
      CLOSE Recipe_Status_cur;

    END IF; /* end if this is routing, recipe or validity rule */
  END IF; /* end if this is a TO_status which needs to be checked */

  /*  *************** VALIDITY RULE STATUS AGAINST RECIPE STATUS ***************** */
  --KKILLAMS, Bug# 3283888: Validating the rule status aganist recipe status if recipe status is 'NEW'
  --Set FALSE to "dependent_status_ok" variable if recipe status is NEW and validate rule status is FROZEN.
  IF (p_entity_type =5) THEN
         OPEN  Recipe_Status_cur FOR
              SELECT    g.recipe_status FROM  gmd_recipe_validity_rules vr, gmd_recipes_b g
                                        WHERE vr.recipe_id               = g.recipe_id
                                        AND   vr.recipe_validity_rule_id = p_Entity_id;
         FETCH recipe_status_cur INTO l_cur_dependent_status;
         CLOSE recipe_status_cur;
         IF (l_cur_dependent_status BETWEEN 100 AND 199) AND
            (p_to_status BETWEEN 900 AND 999) THEN
             Dependent_Status_OK := FALSE;
         END IF;
  END IF;

  RETURN Dependent_Status_OK;
  END Check_Dependent_status;



   /* Before the status of a lower entity can be changed, the status of parent
   * entities must be checked.  Ex.  Before a routing can be obsoleted, a check should be
   * made if the parent ie recipe is approved for general use or frozen or approved for lab use.
   * if it is, the system should not allow the change of status to obsolete unless parent is
     obsoleted. Returns FALSE if one exist otherwise returns TRUE */



  FUNCTION Check_parent_status (pentity_name VARCHAR2,pentity_id NUMBER) RETURN BOOLEAN IS

    CURSOR Cur_Check_Sts(l_recipe_id NUMBER) IS
      SELECT COUNT(*)
      FROM   gmd_recipes r,gmd_recipe_validity_rules v
      WHERE  r.recipe_id = l_recipe_id
         AND r.recipe_id = v.recipe_id
         AND (r.recipe_status BETWEEN 700 AND 799
              OR r.recipe_Status BETWEEN 400 AND 499
              OR r.recipe_Status BETWEEN 900 AND 999)
         AND EXISTS (select 1
                     from   gme_batch_header
                     Where  batch_status IN (1,2,3,-3)
                     AND    recipe_validity_rule_id = v.recipe_validity_rule_id);

   CURSOR Cur_Check_routing_recipe(l_routing_id NUMBER) IS
     SELECT Count(*)
     FROM  gmd_recipes
     WHERE routing_id = l_routing_id
        AND (recipe_status between 700 and 799
           OR recipe_status between 400 and 499
           OR recipe_status between 900 and 999) ;


   CURSOR Cur_Check_oprn_recp(l_oprn_id NUMBER) IS
     SELECT count(*)
     FROM  fm_rout_hdr h,fm_rout_dtl d
      WHERE h.routing_id = d.routing_id
           AND d.oprn_id = l_oprn_id
           AND (h.routing_status between 700 and 799
                OR h.routing_Status between 400 and 499
                OR h.routing_Status between 900 and 999);

   CURSOR Cur_Check_oprn_batch_steps(l_oprn_id NUMBER) IS
     SELECT count(*)
     FROM   gmd_operations_vl o,gme_batch_steps s
      WHERE o.oprn_id = l_oprn_id
            AND o.oprn_id = s.oprn_id
            AND  (o.operation_status  BETWEEN 400 and 499
                  OR o.operation_status BETWEEN 700 AND 799
                  OR o.operation_status BETWEEN 900 AND 999);


   CURSOR Cur_check_form_recipe(l_formula_id NUMBER) IS
     SELECT count(*)
     FROM  gmd_recipes
     WHERE formula_id = l_formula_id
       AND (recipe_status between 700 and 799
            OR recipe_status between 400 and 499
            OR recipe_status between 900 and 999);

   CURSOR Cur_check_valrle_batch(l_validity_rule_id   NUMBER) IS
     SELECT count(*)
     FROM   gme_batch_header
     WHERE recipe_validity_rule_id = l_validity_rule_id
     AND   batch_status IN (1,2,3,-3);

    l_count NUMBER;

  BEGIN
    IF (pentity_name = 'RECIPE') THEN
      OPEN Cur_Check_sts(pentity_id);
      FETCH Cur_Check_sts INTO l_count;
      CLOSE Cur_Check_sts;
      IF (l_count > 0) THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    ELSIF(pentity_name = 'ROUTING') THEN

      OPEN Cur_Check_routing_recipe(pentity_id);
      FETCH Cur_Check_routing_recipe INTO l_count;
      CLOSE Cur_Check_routing_recipe;

      IF (l_count > 0) THEN  -- This routing is used in recipes which are approved for general use.
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;

    ELSIF(pentity_name = 'OPERATION') THEN

      OPEN Cur_Check_oprn_recp(pentity_id);
      FETCH Cur_Check_oprn_recp INTO l_count;
      CLOSE Cur_Check_oprn_recp;
      IF (l_count > 0) THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;

      OPEN Cur_Check_oprn_batch_steps(pentity_id);
      FETCH Cur_check_oprn_batch_steps INTO l_count;
      CLOSE Cur_check_oprn_batch_steps;

      IF (l_count > 0) THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    ELSIF(pentity_name = 'FORMULA') THEN
      OPEN Cur_check_form_recipe(pentity_id);
      FETCH Cur_check_form_recipe INTO l_count;
      CLOSE Cur_check_form_recipe;
      IF (l_count > 0) THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    ELSIF(pentity_name like 'VALIDITY%') THEN
      OPEN Cur_check_valrle_batch(pentity_id);
      FETCH Cur_check_valrle_batch INTO l_count;
      CLOSE Cur_check_valrle_batch;
      IF (l_count > 0) THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    ELSE --bug 4479101
      RETURN(TRUE);
    END IF;
  END check_parent_status;

  FUNCTION GET_REWORK_STATUS(p_from_status VARCHAR2,
                             p_to_status VARCHAR2)
                               RETURN VARCHAR2
  IS
    CURSOR Cur_get_rework IS
      SELECT rework_status
      FROM GMD_STATUS_NEXT
      WHERE current_status = p_from_status
      AND target_status  = p_to_status
      AND pending_status IS NOT NULL;

    l_rework_status  VARCHAR2(30);
  BEGIN
    OPEN Cur_get_rework;
    FETCH Cur_get_rework INTO l_rework_status;
    CLOSE Cur_get_rework;
    RETURN (l_rework_status);

  END get_rework_status;


  FUNCTION GET_PENDING_STATUS(p_from_status VARCHAR2,
                              p_to_status VARCHAR2)
                               RETURN VARCHAR2
  IS
    CURSOR Cur_get_pending IS
      SELECT pending_status
      FROM GMD_STATUS_NEXT
      WHERE current_status = p_from_status
      AND target_status  = p_to_status;

    l_pending_status  VARCHAR2(30);
  BEGIN
    OPEN Cur_get_pending;
    FETCH Cur_get_pending INTO l_pending_status;
    CLOSE Cur_get_pending;
    RETURN (l_pending_status);

  END get_pending_status;

END; -- Package Body GMD_STATUS_CODE

/
