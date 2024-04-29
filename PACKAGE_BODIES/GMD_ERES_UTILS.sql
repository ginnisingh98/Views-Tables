--------------------------------------------------------
--  DDL for Package Body GMD_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ERES_UTILS" AS
/* $Header: GMDERESB.pls 120.8.12000000.2 2007/02/13 12:17:16 kmotupal ship $ */


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

/*======================================================================
--  PROCEDURE :
--   get_operation_no
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    operation no for a given operation id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_operation_no (100, p_oprn_no);
--
--===================================================================== */
PROCEDURE get_operation_no(P_oprn_id IN NUMBER, P_oprn_no OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_operation IS
     SELECT oprn_no
     FROM   gmd_operations
     WHERE  oprn_id = P_oprn_id;
BEGIN
  OPEN Cur_get_operation;
  FETCH Cur_get_operation INTO P_oprn_no;
  CLOSE Cur_get_operation;
END get_operation_no;

/*======================================================================
--  PROCEDURE :
--   get_operation_vers
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    operation version for a given operation id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_operation_no (100, p_oprn_vers);
--
--===================================================================== */
PROCEDURE get_operation_vers(P_oprn_id IN NUMBER,P_oprn_vers OUT NOCOPY NUMBER) IS
  CURSOR Cur_get_operation IS
     SELECT oprn_vers
     FROM   gmd_operations
     WHERE  oprn_id = P_oprn_id;
BEGIN
  OPEN Cur_get_operation;
  FETCH Cur_get_operation INTO P_oprn_vers;
  CLOSE Cur_get_operation;
END get_operation_vers;

/*======================================================================
--  PROCEDURE :
--   get_formula_no
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    formula no for a given formula id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_formula_no (100, p_formula_no);
--
--===================================================================== */
PROCEDURE get_formula_no(P_formula_id IN NUMBER, P_formula_no OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_formula IS
     SELECT formula_no
     FROM   fm_form_mst_b
     WHERE  formula_id = P_formula_id;
BEGIN
  OPEN Cur_get_formula;
  FETCH Cur_get_formula INTO P_formula_no;
  CLOSE Cur_get_formula;
END get_formula_no;

/*======================================================================
--  PROCEDURE :
--   get_formula_vers
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    formula version for a given formula id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_formula_vers (100, p_formula_vers);
--
--===================================================================== */
PROCEDURE get_formula_vers(P_formula_id IN NUMBER,P_formula_vers OUT NOCOPY NUMBER) IS
  CURSOR Cur_get_formula IS
     SELECT formula_vers
     FROM   fm_form_mst_b
     WHERE  formula_id = P_formula_id;
BEGIN
  OPEN Cur_get_formula;
  FETCH Cur_get_formula INTO P_formula_vers;
  CLOSE Cur_get_formula;
END get_formula_vers;


/*======================================================================
--  PROCEDURE :
--   get_formula_desc
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    formula desc for a given formula id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_formula_desc (100, p_formula_desc);
--
--===================================================================== */
PROCEDURE get_formula_desc(P_formula_id IN NUMBER, P_formula_desc OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_formula_desc IS
     SELECT formula_desc1
     FROM   fm_form_mst
     WHERE  formula_id = P_formula_id;
BEGIN
  OPEN Cur_get_formula_desc;
  FETCH Cur_get_formula_desc INTO P_formula_desc;
  CLOSE Cur_get_formula_desc;
END get_formula_desc;

/*======================================================================
--  PROCEDURE :
--   get_recipe_no
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    recipe no for a given recipe id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_recipe_no (100, p_recipe_no);
--
--===================================================================== */
PROCEDURE get_recipe_no(P_recipe_id IN NUMBER, P_recipe_no OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_recipe IS
     SELECT recipe_no
     FROM   gmd_recipes_b
     WHERE  recipe_id = P_recipe_id;
BEGIN
  OPEN Cur_get_recipe;
  FETCH Cur_get_recipe INTO P_recipe_no;
  CLOSE Cur_get_recipe;
END get_recipe_no;

/*======================================================================
--  PROCEDURE :
--   get_recipe_version
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    recipe version for a given recipe id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_recipe_version (100, p_recipe_version);
--
--===================================================================== */
PROCEDURE get_recipe_version (P_recipe_id IN NUMBER,P_recipe_version OUT NOCOPY NUMBER) IS
  CURSOR Cur_get_recipe IS
     SELECT recipe_version
     FROM   gmd_recipes_b
     WHERE  recipe_id = P_recipe_id;
BEGIN
  OPEN Cur_get_recipe;
  FETCH Cur_get_recipe INTO P_recipe_version;
  CLOSE Cur_get_recipe;
END get_recipe_version;

/*======================================================================
--  PROCEDURE :
--   get_routing_no
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    routing no for a given routing id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_routing_no (100, p_routing_no);
--
--===================================================================== */
PROCEDURE get_routing_no(P_routing_id IN NUMBER, P_routing_no OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_routing IS
     SELECT routing_no
     FROM   gmd_routings_b
     WHERE  routing_id = P_routing_id;
BEGIN
  OPEN Cur_get_routing;
  FETCH Cur_get_routing INTO P_routing_no;
  CLOSE Cur_get_routing;
END get_routing_no;

/*======================================================================
--  PROCEDURE :
--   get_routing_vers
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    routing version for a given routing id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_routing_vers (100, p_routing_vers);
--
--===================================================================== */
PROCEDURE get_routing_vers (P_routing_id IN NUMBER,P_routing_vers OUT NOCOPY NUMBER) IS
  CURSOR Cur_get_routing IS
     SELECT routing_vers
     FROM   gmd_routings_b
     WHERE  routing_id = P_routing_id;
BEGIN
  OPEN Cur_get_routing;
  FETCH Cur_get_routing INTO P_routing_vers;
  CLOSE Cur_get_routing;
END get_routing_vers;


/*======================================================================
--  PROCEDURE :
--   get_line_type_desc
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    description of the line type for a given formula line id
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_line_type_desc (100, p_line_type_desc);
--
--===================================================================== */
PROCEDURE get_line_type_desc (P_formulaline_id IN NUMBER, P_line_type_desc OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_meaning IS
     SELECT meaning
     FROM   gem_lookups g, fm_matl_dtl d
     WHERE  formulaline_id = P_formulaline_id
     AND    lookup_type = 'LINE_TYPE'
     AND    lookup_code = d.line_type;
BEGIN
  OPEN Cur_get_meaning;
  FETCH Cur_get_meaning INTO P_line_type_desc;
  CLOSE Cur_get_meaning;
END get_line_type_desc;

/*======================================================================
--  PROCEDURE :
--   get_status_meaning
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    meaning for a given status code.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_status_meaning (100, p_meaning);
--
--===================================================================== */
PROCEDURE get_status_meaning(P_status_code IN NUMBER, P_meaning OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get IS
     SELECT meaning
     FROM   gmd_status
     WHERE  status_code = P_status_code;
BEGIN
  OPEN Cur_get;
  FETCH Cur_get INTO P_meaning;
  CLOSE Cur_get;
END get_status_meaning;

/*======================================================================
--  PROCEDURE :
--   get_process_qty_um
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    process qty uom for a given operation id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_process_qty_um (100, p_prc_qty_um);
--  Krishna 10-Feb-2005 Used new column PROCESS_QTY_UOM for the UOM code.
--===================================================================== */
PROCEDURE get_process_qty_um(P_oprn_id IN NUMBER,P_prc_qty_um OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_qty_um IS
     SELECT process_qty_uom
     FROM   gmd_operations
     WHERE  oprn_id = P_oprn_id;
BEGIN
  OPEN Cur_get_qty_um;
  FETCH Cur_get_qty_um INTO P_prc_qty_um;
  CLOSE Cur_get_qty_um;
END get_process_qty_um;

/*======================================================================
--  PROCEDURE :
--   get_activity_desc
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    description for a given activity.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_activity_desc ('SET-UP', p_activity_desc);
--
--===================================================================== */
PROCEDURE get_activity_desc(p_activity IN VARCHAR2, p_activity_desc OUT NOCOPY VARCHAR2) IS
 CURSOR get_activity_desc IS
  SELECT activity_desc
  FROM  fm_actv_mst
  where activity = p_activity;
BEGIN
   open get_activity_desc;
   fetch get_activity_desc INTO p_activity_desc;
   close get_activity_desc;
END get_activity_desc;

/*======================================================================
--  PROCEDURE :
--   get_resource_desc
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    description for a given resource
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_resource_desc ('LABOUR', p_resource_desc);
--
--===================================================================== */
PROCEDURE get_resource_desc(p_resource IN VARCHAR2, p_resource_desc OUT NOCOPY VARCHAR2) IS
Cursor get_resource_desc IS
 SELECT resource_desc
 from cr_rsrc_mst
 where resources = p_resource;
BEGIN
  open get_resource_desc;
  fetch get_resource_desc into p_resource_desc;
  close get_resource_desc;
END get_resource_desc;

/*======================================================================
--  PROCEDURE :
--   get_proc_param_desc
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    description for a given process parameter.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_routing_no (100, x_parameter_desc);
--
--===================================================================== */
PROCEDURE get_proc_param_desc(p_parameter_id IN NUMBER, x_parameter_desc OUT NOCOPY VARCHAR2) IS
BEGIN
  GMD_RECIPE_FETCH_PUB.get_proc_param_desc (p_parameter_id => p_parameter_id
                                           ,x_parameter_desc => x_parameter_desc);
END get_proc_param_desc;

/*======================================================================
--  PROCEDURE :
--   get_proc_param_units
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    units for a given process parameter.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_proc_param_units (100, X_units);
--
--===================================================================== */
PROCEDURE get_proc_param_units(p_parameter_id IN NUMBER, x_units OUT NOCOPY VARCHAR2) IS
BEGIN
  GMD_RECIPE_FETCH_PUB.get_proc_param_units (p_parameter_id => p_parameter_id
                                            ,x_units => x_units);
END get_proc_param_units;

/*======================================================================
--  PROCEDURE :
--   set_formula_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the formula status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    formula, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_formula_status (100, 400, 700, 'PENDING');
--  G.Kelly     07-May-04 B3604554 Added code in procedure set_formula_status for checking
--                                 for Recipe Generation Automatically
--===================================================================== */
PROCEDURE set_formula_status(p_formula_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2,
                             p_signature_status IN VARCHAR2) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;

  /* Declare variables, cursors for recipe generation */
  l_orgn_code           VARCHAR2(4);
  x_return_status       VARCHAR2(1);
  x_recipe_version      NUMBER;
  x_recipe_no           VARCHAR2(32);


BEGIN
  IF p_signature_status = 'SUCCESS' THEN
    UPDATE fm_form_mst_b
    SET    formula_status = p_to_status
    WHERE  formula_id = p_formula_id;
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE fm_form_mst_b
      SET formula_status  = l_pending_status
      WHERE formula_id    = p_formula_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE fm_form_mst_b
      SET formula_status  = l_rework_status
      WHERE formula_id    = p_formula_id;
    END IF;
  END IF;

END set_formula_status;

 -- Bug number 4479101
PROCEDURE set_substitution_status (P_substitution_id  IN NUMBER
                                  ,p_from_status      IN VARCHAR2
                                  ,p_to_status        IN VARCHAR2
                                  ,p_signature_status IN VARCHAR2 DEFAULT NULL)AS
l_pending_status  VARCHAR2(80);
l_rework_status   VARCHAR2(80);
l_derive_end_date DATE;
BEGIN
  IF p_signature_status = 'SUCCESS' THEN

    UPDATE GMD_ITEM_SUBSTITUTION_HDR_B
    SET    substitution_status  = p_to_status
    WHERE  substitution_id = p_substitution_id;
    UPDATE GMD_FORMULA_SUBSTITUTION SET Associated_flag ='Y'
                                    WHERE substitution_id = P_substitution_id;

    GMD_API_GRP.update_end_date (p_substitution_id);

  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                          ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
    UPDATE GMD_ITEM_SUBSTITUTION_HDR_B
    SET    substitution_status  = l_pending_status
    WHERE  substitution_id = p_substitution_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
    UPDATE GMD_ITEM_SUBSTITUTION_HDR_B
    SET    substitution_status  = l_rework_status
    WHERE  substitution_id = p_substitution_id;
    END IF;
  END IF;
END set_substitution_status;

/*======================================================================
--  PROCEDURE :
--   set_formulation_spec_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the formulation sepc status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    formulation spec, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_formulation_spec_status (100, 400, 700, 'PENDING');
--===================================================================== */
PROCEDURE set_formulation_spec_status(p_formulation_spec_id IN NUMBER,
                                      p_from_status IN VARCHAR2,
                                      p_to_status IN VARCHAR2,
                                      p_signature_status IN VARCHAR2) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;
BEGIN

  IF p_signature_status = 'SUCCESS' THEN
    UPDATE gmd_formulation_specs
    SET    spec_status = p_to_status
    WHERE  formulation_spec_id = p_formulation_spec_id;
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                          ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_formulation_specs
      SET spec_status  = l_pending_status
      WHERE formulation_spec_id = p_formulation_spec_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_formulation_specs
      SET spec_status  = l_rework_status
      WHERE formulation_spec_id = p_formulation_spec_id;
    END IF;
  END IF;
END set_formulation_spec_status;

/*======================================================================
--  PROCEDURE :
--   set_operation_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the operation status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    operation, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_operation_status (100, 400, 700, 'PENDING');
--
--===================================================================== */
PROCEDURE set_operation_status(p_oprn_id IN NUMBER,
                               p_from_status IN VARCHAR2,
                               p_to_status IN VARCHAR2,
                               p_signature_status IN VARCHAR2) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;
BEGIN
  IF p_signature_status = 'SUCCESS' THEN
    UPDATE gmd_operations_b
    SET    operation_status = p_to_status
    WHERE  oprn_id = p_oprn_id;
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_operations_b
      SET operation_status  = l_pending_status
      WHERE oprn_id    = p_oprn_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_operations_b
      SET operation_status  = l_rework_status
      WHERE oprn_id    = p_oprn_id;
    END IF;
  END IF;

END set_operation_status;

/*======================================================================
--  PROCEDURE :
--   set_routing_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the routing status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    routing, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_routing_status (100, 400, 700, 'PENDING');
--
--===================================================================== */
PROCEDURE set_routing_status(p_routing_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2,
                             p_signature_status IN VARCHAR2) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;
BEGIN
  IF p_signature_status = 'SUCCESS' THEN
    UPDATE gmd_routings_b
    SET    routing_status = p_to_status
    WHERE  routing_id = p_routing_id;
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_routings_b
      SET routing_status  = l_pending_status
      WHERE routing_id    = p_routing_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_routings_b
      SET routing_status  = l_rework_status
      WHERE routing_id    = p_routing_id;
    END IF;
  END IF;

END set_routing_status;

/*======================================================================
--  PROCEDURE :
--   set_recipe_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the recipe status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    recipe, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_recipe_status (100, 400, 700, 'PENDING');
--
--===================================================================== */
PROCEDURE set_recipe_status(p_recipe_id IN NUMBER,
                            p_from_status IN VARCHAR2,
                            p_to_status IN VARCHAR2,
                            p_signature_status IN VARCHAR2,
                            p_create_validity IN NUMBER) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;

  CURSOR Cur_get_formula_details IS
    SELECT r.owner_organization_id, r.formula_id, r.recipe_no, r.recipe_version
    FROM   gmd_recipes_b r, fm_form_mst_b f
    WHERE  r.recipe_id = p_recipe_id
    AND    r.formula_id = f.formula_id;
  LocalFormRecord               Cur_get_formula_details%ROWTYPE;

  CURSOR Cur_auto_recipe_enable (V_orgn_id NUMBER) IS
    SELECT   recipe_use_prod, recipe_use_plan, recipe_use_cost, recipe_use_reg, recipe_use_tech, managing_validity_rules
    FROM     gmd_recipe_generation
    WHERE    (organization_id = V_orgn_id
              OR organization_id IS NULL)
    ORDER BY orgn_code;
  LocalEnableRecord     Cur_auto_recipe_enable%ROWTYPE;
  l_return_status       VARCHAR2(1);
BEGIN
  IF p_signature_status = 'SUCCESS' THEN
    UPDATE gmd_recipes_b
    SET    recipe_status = p_to_status
    WHERE  recipe_id = p_recipe_id;

    /* If validity rule has to be created based on the recipe approval and recipe generation setup */
    IF p_create_validity = 1 THEN
      OPEN Cur_get_formula_details;
      FETCH Cur_get_formula_details INTO LocalFormRecord;
      CLOSE Cur_get_formula_details;

      OPEN Cur_auto_recipe_enable(LocalFormRecord.owner_organization_id);
      FETCH Cur_auto_recipe_enable INTO LocalEnableRecord;
      CLOSE Cur_auto_recipe_enable;

      GMD_RECIPE_GENERATE.create_validity_rule_set(p_recipe_id       => p_recipe_id,
                                                   p_recipe_no       => LocalFormRecord.recipe_no,
                                                   p_recipe_version  => LocalFormRecord.recipe_version,
                                                   p_formula_id      => LocalFormRecord.formula_id,
                                                   p_orgn_id         => LocalFormRecord.owner_organization_id,
                                                   p_recipe_use_prod => LocalEnableRecord.recipe_use_prod,
                                                   p_recipe_use_plan => LocalEnableRecord.recipe_use_plan,
                                                   p_recipe_use_cost => LocalEnableRecord.recipe_use_cost,
                                                   p_recipe_use_reg  => LocalEnableRecord.recipe_use_reg,
                                                   p_recipe_use_tech => LocalEnableRecord.recipe_use_tech,
                                                   p_manage_validity_rules => LocalEnableRecord.managing_validity_rules,
                                                   p_event_signed    => FALSE,
                                                   x_return_status   => l_return_status);
    END IF; /* IF p_create_validity = 1 */
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_recipes_b
      SET recipe_status  = l_pending_status
      WHERE recipe_id    = p_recipe_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_recipes_b
      SET recipe_status  = l_rework_status
      WHERE recipe_id    = p_recipe_id;
    END IF;
  END IF;

END set_recipe_status;

/*======================================================================
--  PROCEDURE :
--   set_validity_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the validity status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    recipe validity rule, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_validity_status (100, 400, 700, 'PENDING');
--
--===================================================================== */
PROCEDURE set_validity_status(p_validity_rule_id IN NUMBER,
                              p_from_status IN VARCHAR2,
                              p_to_status IN VARCHAR2,
                              p_signature_status IN VARCHAR2) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;
BEGIN
  IF p_signature_status = 'SUCCESS' THEN
    UPDATE gmd_recipe_validity_rules
    SET    validity_rule_status = p_to_status
    WHERE  recipe_validity_rule_id = p_validity_rule_id;
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_recipe_validity_rules
      SET validity_rule_status  = l_pending_status
      WHERE recipe_validity_rule_id    = p_validity_rule_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_recipe_validity_rules
      SET validity_rule_status  = l_rework_status
      WHERE recipe_validity_rule_id    = p_validity_rule_id;
    END IF;
  END IF;

END set_validity_status;

/*======================================================================
--  PROCEDURE :
--   set_auto_recipe_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the formula status
--    to a given status based on the status of the signature.
--   (This is called from GMD_ERES_POST_OPERATION API for the ERES approval of a
--    formula, also from the change status form after the event is raised.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_formula_status (100, 400, 700, 'PENDING');
-- kkillams 01-DEC-2004 set_auto_recipe_status procedure signature is changed  w.r.t. 4004501
--===================================================================== */
PROCEDURE set_auto_recipe_status(p_formula_id       IN NUMBER,
                                 p_orgn_id          IN NUMBER,
                                 p_from_status      IN VARCHAR2,
                                 p_to_status        IN VARCHAR2,
                                 p_signature_status IN VARCHAR2) IS
  l_pending_status      gmd_status.status_code%TYPE;
  l_rework_status       gmd_status.status_code%TYPE;
  l_return_status       VARCHAR2(1);
  l_recipe_no           VARCHAR2(100);
  l_recipe_version      NUMBER(5);
BEGIN
  IF p_signature_status = 'SUCCESS' THEN
    UPDATE fm_form_mst_b
    SET    formula_status = p_to_status
    WHERE  formula_id = p_formula_id;
    gmd_recipe_generate.recipe_generate (p_orgn_id        => p_orgn_id
                                        ,p_formula_id     => p_formula_id
                                        ,X_return_status  => l_return_status
                                        ,X_recipe_no      => l_recipe_no
                                        ,X_recipe_version => l_recipe_version
                                        ,p_event_signed   => TRUE);
  ELSIF p_signature_status = 'PENDING' THEN
    l_pending_status := GMD_STATUS_CODE.get_pending_status(p_from_status => p_from_status
                                                          ,p_to_status => p_to_status);
    IF l_pending_status IS NOT NULL THEN
      UPDATE fm_form_mst_b
      SET formula_status  = l_pending_status
      WHERE formula_id    = p_formula_id;
    END IF;
  ELSIF p_signature_status IN ('REJECTED','TIMEDOUT') THEN
    l_rework_status := GMD_STATUS_CODE.get_rework_status(p_from_status => p_from_status
                                                        ,p_to_status => p_to_status);
    IF l_rework_status IS NOT NULL THEN
      UPDATE fm_form_mst_b
      SET formula_status  = l_rework_status
      WHERE formula_id    = p_formula_id;
    END IF;
  END IF;
END set_auto_recipe_status;

/*======================================================================
--  PROCEDURE :
--   check_recipe_validity_eres
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for checking if approvals
--    are required for the validity rules associated with a recipe, to be
--    moved to a particular status.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    check_recipe_validity_eres (100, 400);
--
--===================================================================== */
FUNCTION check_recipe_validity_eres (p_recipe_id IN NUMBER,
                                    p_to_status IN VARCHAR2)
RETURN BOOLEAN IS
  CURSOR Cur_get_validity IS
    SELECT recipe_validity_rule_id
    FROM   gmd_recipe_validity_rules
    WHERE  recipe_id = p_recipe_id
    AND    validity_rule_status < p_to_status;
  l_recipe_validity_rule_id  NUMBER;
  l_status  BOOLEAN;
BEGIN
  Savepoint check_vr_required;
  OPEN Cur_get_validity;
  FETCH Cur_get_validity INTO l_recipe_validity_rule_id;
  WHILE Cur_get_validity%FOUND LOOP
    UPDATE gmd_recipe_validity_rules
    SET validity_rule_status = p_to_status
    WHERE recipe_validity_rule_id = l_recipe_validity_rule_id;
    GMA_STANDARD.psig_required (p_event => 'oracle.apps.gmd.validity.sts'
                               ,p_event_key => l_recipe_validity_rule_id
                               ,p_status => l_status);
    IF l_status THEN
      ROLLBACK to Savepoint check_vr_required;
      CLOSE Cur_get_validity;
      RETURN TRUE;
    END IF;
    FETCH Cur_get_validity INTO l_recipe_validity_rule_id;
  END LOOP;
  ROLLBACK to Savepoint check_vr_required;
  CLOSE Cur_get_validity;
  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK to Savepoint check_vr_required;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
    FND_MSG_PUB.ADD;
    RETURN TRUE;
END check_recipe_validity_eres;

/*======================================================================
--  PROCEDURE :
--   esig_required
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for returning back to the
--    calling routine if esignatures are enabled for moving to a particular
--    status.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    esig_required ('oracle.apps.gmd.operation.sts', 100, 400);
--
--===================================================================== */
FUNCTION esig_required (p_event IN VARCHAR2,
                        p_event_key IN VARCHAR2,
                        p_to_status IN VARCHAR2)
RETURN BOOLEAN IS
  l_status  BOOLEAN;
BEGIN
  GMA_STANDARD.psig_required (p_event => p_event
                             ,p_event_key => p_event_key
                             ,p_status => l_status);
  IF l_status THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END esig_required;

  /*###############################################################
  # NAME
  #     update_formula_status
  # SYNOPSIS
  #     update_formula_status
  # DESCRIPTION
  #    Performs update of the formula status and the raise of event
  ###############################################################*/

  PROCEDURE update_formula_status ( p_formula_id        IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN      VARCHAR2,
                                    x_return_status        OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_desc IS
      SELECT meaning
       FROM  gem_lookups
       WHERE lookup_type = 'GMD_SRCH_RPLCE_CRIT_TYPE'
         AND lookup_code = 'FORMULA';

    CURSOR Cur_get_status_desc (pstatus VARCHAR2) IS
      SELECT description
      FROM   gmd_status
      WHERE  status_code = pstatus;

    l_replace_type_desc         VARCHAR2(240);
    l_user_key_label            VARCHAR2(2000);
    l_object_type               VARCHAR2(240);
    l_from_status_desc          VARCHAR2(240);
    l_to_status_desc            VARCHAR2(240);
    l_version_lbl               VARCHAR2(2000);
    l_text                      VARCHAR2(4000);
    l_user_id                   NUMBER := FND_GLOBAL.USER_ID;
    l_status                    VARCHAR2(2000);
    l_esig_reqd                 BOOLEAN;
    l_erec_reqd                 BOOLEAN;

    PENDING_STATUS_ERR  EXCEPTION;
    REWORK_STATUS_ERR   EXCEPTION;

    --Sriram.S Bug# 3497522 31-MAR-2004
    --Declared a new exception to be raised for Update failure due to View access restriction
    STATUS_UPDATE_FAILURE EXCEPTION;
    --Local variables
    l_access_type_ind              VARCHAR2(10);
    l_owner_organization_id         NUMBER(15);
    --New cursor to get the organization to which the formula belongs.
    CURSOR get_orgn_code( CP_FORMULA_ID FM_FORM_MST_B.FORMULA_ID%TYPE) IS
        SELECT OWNER_ORGANIZATION_ID
        FROM FM_FORM_MST_B
        WHERE FORMULA_ID = CP_FORMULA_ID;
    --End of Declaration for Bug# 3497522

  BEGIN
    SAVEPOINT update_formula;
    X_return_status := FND_API.g_ret_sts_success;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_FORMULA');
    l_object_type := FND_MESSAGE.GET;

    SELECT 'x'
    INTO l_text
    FROM  fm_form_mst
    WHERE formula_id  = p_formula_id
    FOR UPDATE OF formula_status nowait;

    UPDATE fm_form_mst
    SET   formula_status = p_to_status,
    last_update_date = sysdate,
    last_updated_by = l_user_id
    WHERE  formula_id = p_formula_id;

    --Sriram.S Bug# 3497522 31-MAR-2004
    --Checked if Update of Status is not performed because of View Restriction
    IF (SQL%ROWCOUNT = 0) THEN

        OPEN  get_orgn_code(p_formula_id);
        FETCH get_orgn_code INTO l_owner_organization_id;
        CLOSE get_orgn_code;
        --Get the access type of the formula
        l_access_type_ind := GMD_API_GRP.GET_FORMULA_ACCESS_TYPE(p_formula_id            => p_formula_id,
                                                                 p_owner_organization_id => l_owner_organization_id);
        IF (l_access_type_ind ='V') THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_FORM_UPD_NO_ACCESS');
                FND_MSG_PUB.ADD;
                RAISE STATUS_UPDATE_FAILURE;
        END IF;

   END IF;
   -- End of Bug# 3497522

    GMA_STANDARD.PSIG_REQUIRED (p_event => 'oracle.apps.gmd.formula.sts'
                               ,p_event_key => p_formula_id
                               ,p_status => l_esig_reqd);

    GMA_STANDARD.EREC_REQUIRED (p_event => 'oracle.apps.gmd.formula.sts'
                               ,p_event_key => p_formula_id
                               ,p_status => l_erec_reqd);

    IF (l_esig_reqd OR l_erec_reqd) THEN

      IF (l_esig_reqd) THEN
        OPEN Cur_get_status_desc (p_from_status);
        FETCH Cur_get_status_desc INTO l_from_status_desc;
        CLOSE Cur_get_status_desc;

        OPEN Cur_get_status_desc (p_to_status);
        FETCH Cur_get_status_desc INTO l_to_status_desc;
        CLOSE Cur_get_status_desc;

        IF p_pending_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_PEND_STAT_REQD');
          RAISE PENDING_STATUS_ERR;
        END IF;
        IF p_rework_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_REWK_STAT_REQD');
          RAISE REWORK_STATUS_ERR;
        END IF;
      END IF; /* IF (l_esig_reqd) */

    END IF; /* IF (l_esig_reqd OR l_erec_reqd) */

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_FORM_USR_LBL');
    l_user_key_label := FND_MESSAGE.GET;
    GMD_EDR_STANDARD.raise_event (p_event_name => 'oracle.apps.gmd.formula.sts'
                    ,p_event_key => p_formula_id
                    ,p_parameter_name1 => 'DEFERRED'
                    ,p_parameter_value1 => 'Y'
                    ,p_parameter_name2 => 'POST_OPERATION_API'
                    ,p_parameter_value2 =>'GMD_ERES_POST_OPERATION.set_formula_status('||
                                           p_formula_id||', '||
                                           p_from_status||', '||
                                           p_to_status||');'
                    ,p_parameter_name3 => 'PSIG_USER_KEY_LABEL'
                    ,p_parameter_value3 =>l_user_key_label
                    ,p_parameter_name4 => 'PSIG_USER_KEY_VALUE'
                    ,p_parameter_value4 => p_object_name||', '||p_object_version
                    ,p_parameter_name5 => '#WF_SOURCE_APPLICATION_TYPE'
                    ,p_parameter_value5 =>'DB'
                    ,p_parameter_name6 => '#WF_SIGN_REQUESTER'
                    ,p_parameter_value6 =>FND_GLOBAL.user_name
                    ,p_parameter_name7 =>'PSIG_TRANSACTION_AUDIT_ID'
                    ,p_parameter_value7=>-1);

    IF l_esig_reqd  THEN
      X_return_status := 'P';
      UPDATE fm_form_mst
      SET formula_status = p_pending_status
      WHERE formula_id = p_formula_id;
      IF p_called_from_form = 'F' THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_ERES_PEND_STAT_UPD');
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_to_status_desc);
        FND_FILE.PUT(FND_FILE.LOG,
        FND_MESSAGE.GET||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
                       ||' :'||p_object_version||')');
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /* IF l_esig_reqd */

  EXCEPTION
    WHEN PENDING_STATUS_ERR OR
         REWORK_STATUS_ERR THEN
      ROLLBACK TO SAVEPOINT update_formula;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_TOKEN('FROM_STATUS', SUBSTR(l_from_status_desc,1, 80));
      FND_MESSAGE.SET_TOKEN('TO_STATUS', SUBSTR(l_to_status_desc, 1, 80));
      l_text := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_VERSION');
      l_version_lbl := FND_MESSAGE.GET;
      l_text := l_text||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
                      ||' :'||p_object_version||')';
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG, l_text);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MESSAGE.SET_NAME ('FND', 'FND_GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('MESSAGE', l_text);
        FND_MSG_PUB.add;
      END IF;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK TO SAVEPOINT update_formula;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - locked exception section ');
      END IF;
      gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                              'TABLE_NAME',
                              'FM_FORM_MST_B',
                              'RECORD',
                              'FORMULA_NO : FORMULA_VERS = ',
                              'KEY',
                              p_object_name||':'||p_object_version
                              );

   --Sriram.S Bug# 3497522 31-MAR-2004
   --Added this Exception for Update failure due to View access
   WHEN STATUS_UPDATE_FAILURE THEN
      ROLLBACK TO SAVEPOINT update_formula;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - Status update failure section');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_formula;
      X_return_status := FND_API.g_ret_sts_unexp_error;
      OPEN Cur_get_desc;
      FETCH Cur_get_desc INTO l_replace_type_desc;
      CLOSE Cur_get_desc;

      FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS');
      l_status := FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');
      FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',l_replace_type_desc);
      FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',l_status);
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME',p_object_name);
      FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',l_object_type);
      FND_MESSAGE.SET_TOKEN('OBJECT_VERS',p_object_version);
      FND_MESSAGE.SET_TOKEN('ERRMSG',SQLERRM);
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MSG_PUB.add;
      END IF;
  END update_formula_status;


  /*###############################################################
  # NAME
  #     update_operation_status
  # SYNOPSIS
  #     update_operation_status
  # DESCRIPTION
  #    Performs update of the operation status and the raise of event
  ###############################################################*/

  PROCEDURE update_operation_status(p_oprn_id           IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN      VARCHAR2,
                                    x_return_status        OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_desc IS
      SELECT meaning
       FROM  gem_lookups
       WHERE lookup_type = 'GMD_SRCH_RPLCE_CRIT_TYPE'
         AND lookup_code = 'OPERATION';

    CURSOR Cur_get_status_desc (pstatus VARCHAR2) IS
      SELECT description
      FROM   gmd_status
      WHERE  status_code = pstatus;

    l_replace_type_desc         VARCHAR2(240);
    l_user_key_label            VARCHAR2(2000);
    l_object_type               VARCHAR2(240);
    l_from_status_desc          VARCHAR2(240);
    l_to_status_desc            VARCHAR2(240);
    l_version_lbl               VARCHAR2(2000);
    l_text                      VARCHAR2(4000);
    l_user_id                   NUMBER := FND_GLOBAL.USER_ID;
    l_status                    VARCHAR2(2000);
    l_esig_reqd                 BOOLEAN;
    l_erec_reqd                 BOOLEAN;

    PENDING_STATUS_ERR  EXCEPTION;
    REWORK_STATUS_ERR   EXCEPTION;
  BEGIN
    SAVEPOINT update_operation;
    X_return_status := FND_API.g_ret_sts_success;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_OPERATION');
    l_object_type := FND_MESSAGE.GET;

    SELECT 'x'
    INTO l_text
    FROM  gmd_operations_b
    WHERE oprn_id  = p_oprn_id
    FOR UPDATE OF operation_status nowait;

    UPDATE gmd_operations_b
    SET   operation_status = p_to_status,
    last_update_date = sysdate,
    last_updated_by = l_user_id
    WHERE  oprn_id = p_oprn_id;

    GMA_STANDARD.PSIG_REQUIRED (p_event => 'oracle.apps.gmd.operation.sts'
                               ,p_event_key => p_oprn_id
                               ,p_status => l_esig_reqd);

    GMA_STANDARD.EREC_REQUIRED (p_event => 'oracle.apps.gmd.operation.sts'
                               ,p_event_key => p_oprn_id
                               ,p_status => l_erec_reqd);

    IF (l_esig_reqd OR l_erec_reqd) THEN

      IF (l_esig_reqd) THEN
        OPEN Cur_get_status_desc (p_from_status);
        FETCH Cur_get_status_desc INTO l_from_status_desc;
        CLOSE Cur_get_status_desc;

        OPEN Cur_get_status_desc (p_to_status);
        FETCH Cur_get_status_desc INTO l_to_status_desc;
        CLOSE Cur_get_status_desc;

        IF p_pending_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_PEND_STAT_REQD');
          RAISE PENDING_STATUS_ERR;
        END IF;
        IF p_rework_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_REWK_STAT_REQD');
          RAISE REWORK_STATUS_ERR;
        END IF;
      END IF; /* IF (l_esig_reqd) */

    END IF; /* IF (l_esig_reqd OR l_erec_reqd) */

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_OPER_USR_LBL');
    l_user_key_label := FND_MESSAGE.GET;

    GMD_EDR_STANDARD.raise_event (p_event_name => 'oracle.apps.gmd.operation.sts'
                    ,p_event_key => p_oprn_id
                    ,p_parameter_name1 => 'DEFERRED'
                    ,p_parameter_value1 => 'Y'
                    ,p_parameter_name2 => 'POST_OPERATION_API'
                    ,p_parameter_value2 =>'GMD_ERES_POST_OPERATION.set_operation_status('||
                                           p_oprn_id||', '||
                                           p_from_status||', '||
                                           p_to_status||');'
                    ,p_parameter_name3 => 'PSIG_USER_KEY_LABEL'
                    ,p_parameter_value3 =>l_user_key_label
                    ,p_parameter_name4 => 'PSIG_USER_KEY_VALUE'
                    ,p_parameter_value4 => p_object_name||', '||p_object_version
                    ,p_parameter_name5 => '#WF_SOURCE_APPLICATION_TYPE'
                    ,p_parameter_value5 =>'DB'
                    ,p_parameter_name6 => '#WF_SIGN_REQUESTER'
                    ,p_parameter_value6 =>FND_GLOBAL.user_name
                    ,p_parameter_name7 =>'PSIG_TRANSACTION_AUDIT_ID'
                    ,p_parameter_value7=>-1);

    IF l_esig_reqd  THEN
      X_return_status := 'P';

      UPDATE gmd_operations_b
      SET operation_status = p_pending_status
      WHERE oprn_id = p_oprn_id;

      IF p_called_from_form = 'F' THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_ERES_PEND_STAT_UPD');
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_to_status_desc);
        FND_FILE.PUT(FND_FILE.LOG,
        FND_MESSAGE.GET||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
        ||' :'||p_object_version||')');
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /* IF l_esig_reqd */
  EXCEPTION
    WHEN PENDING_STATUS_ERR OR
         REWORK_STATUS_ERR THEN
      ROLLBACK TO SAVEPOINT update_operation;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_TOKEN('FROM_STATUS', SUBSTR(l_from_status_desc,1, 80));
      FND_MESSAGE.SET_TOKEN('TO_STATUS', SUBSTR(l_to_status_desc, 1, 80));
      l_text := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_VERSION');
      l_version_lbl := FND_MESSAGE.GET;
      l_text := l_text||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
      ||' :'||p_object_version||')';
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG, l_text);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MESSAGE.SET_NAME ('FND', 'FND_GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('MESSAGE', l_text);
        FND_MSG_PUB.add;
      END IF;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK TO SAVEPOINT update_operation;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - locked exception section ');
      END IF;
      gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                              'TABLE_NAME',
                              'GMD_OPERATIONS_B',
                              'RECORD',
                              'OPRN_NO : OPRN_VERS = ',
                              'KEY',
                              p_object_name||':'||p_object_version
                              );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_operation;
      X_return_status := FND_API.g_ret_sts_unexp_error;
      OPEN Cur_get_desc;
      FETCH Cur_get_desc INTO l_replace_type_desc;
      CLOSE Cur_get_desc;

      FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS');
      l_status := FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');
      FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',l_replace_type_desc);
      FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',l_status);
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME',p_object_name);
      FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',l_object_type);
      FND_MESSAGE.SET_TOKEN('OBJECT_VERS',p_object_version);
      FND_MESSAGE.SET_TOKEN('ERRMSG',SQLERRM);
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MSG_PUB.add;
      END IF;
  END update_operation_status;

  /*###############################################################
  # NAME
  #     update_routing_status
  # SYNOPSIS
  #     update_routing_status
  # DESCRIPTION
  #    Performs update of the routing status and the raise of event
  ###############################################################*/

  PROCEDURE update_routing_status ( p_routing_id        IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN      VARCHAR2,
                                    x_return_status        OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_desc IS
      SELECT meaning
       FROM  gem_lookups
       WHERE lookup_type = 'GMD_SRCH_RPLCE_CRIT_TYPE'
         AND lookup_code = 'ROUTING';

    CURSOR Cur_get_status_desc (pstatus VARCHAR2) IS
      SELECT description
      FROM   gmd_status
      WHERE  status_code = pstatus;

    l_replace_type_desc         VARCHAR2(240);
    l_user_key_label            VARCHAR2(2000);
    l_object_type               VARCHAR2(240);
    l_from_status_desc          VARCHAR2(240);
    l_to_status_desc            VARCHAR2(240);
    l_version_lbl               VARCHAR2(2000);
    l_text                      VARCHAR2(4000);
    l_user_id                   NUMBER := FND_GLOBAL.USER_ID;
    l_status                    VARCHAR2(2000);
    l_esig_reqd                 BOOLEAN;
    l_erec_reqd                 BOOLEAN;
    PENDING_STATUS_ERR  EXCEPTION;
    REWORK_STATUS_ERR   EXCEPTION;
  BEGIN
    SAVEPOINT update_routing;
    X_return_status := FND_API.g_ret_sts_success;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING');
    l_object_type := FND_MESSAGE.GET;

    SELECT 'x'
    INTO l_text
    FROM  gmd_routings_b
    WHERE routing_id  = p_routing_id
    FOR UPDATE OF routing_status nowait;

    UPDATE gmd_routings_b
    SET   routing_status = p_to_status,
    last_update_date = sysdate,
    last_updated_by = l_user_id
    WHERE  routing_id = p_routing_id;

    GMA_STANDARD.PSIG_REQUIRED (p_event => 'oracle.apps.gmd.routing.sts'
                               ,p_event_key => p_routing_id
                               ,p_status => l_esig_reqd);

    GMA_STANDARD.EREC_REQUIRED (p_event => 'oracle.apps.gmd.routing.sts'
                               ,p_event_key => p_routing_id
                               ,p_status => l_erec_reqd);

    IF (l_esig_reqd OR l_erec_reqd) THEN

      IF (l_esig_reqd) THEN
        OPEN Cur_get_status_desc (p_from_status);
        FETCH Cur_get_status_desc INTO l_from_status_desc;
        CLOSE Cur_get_status_desc;

        OPEN Cur_get_status_desc (p_to_status);
        FETCH Cur_get_status_desc INTO l_to_status_desc;
        CLOSE Cur_get_status_desc;

        IF p_pending_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_PEND_STAT_REQD');
          RAISE PENDING_STATUS_ERR;
        END IF;
        IF p_rework_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_REWK_STAT_REQD');
          RAISE REWORK_STATUS_ERR;
        END IF;
      END IF; /* IF (l_esig_reqd) */

    END IF; /* IF (l_esig_reqd OR l_erec_reqd) */

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_ROUT_USR_LBL');
    l_user_key_label := FND_MESSAGE.GET;
    GMD_EDR_STANDARD.raise_event (p_event_name => 'oracle.apps.gmd.routing.sts'
                    ,p_event_key => p_routing_id
                    ,p_parameter_name1 => 'DEFERRED'
                    ,p_parameter_value1 => 'Y'
                    ,p_parameter_name2 => 'POST_OPERATION_API'
                    ,p_parameter_value2 =>'GMD_ERES_POST_OPERATION.set_routing_status('||
                                           p_routing_id||', '||
                                           p_from_status||', '||
                                           p_to_status||');'
                    ,p_parameter_name3 => 'PSIG_USER_KEY_LABEL'
                    ,p_parameter_value3 =>l_user_key_label
                    ,p_parameter_name4 => 'PSIG_USER_KEY_VALUE'
                    ,p_parameter_value4 => p_object_name||', '||p_object_version
                    ,p_parameter_name5 => '#WF_SOURCE_APPLICATION_TYPE'
                    ,p_parameter_value5 =>'DB'
                    ,p_parameter_name6 => '#WF_SIGN_REQUESTER'
                    ,p_parameter_value6 =>FND_GLOBAL.user_name
                    ,p_parameter_name7 =>'PSIG_TRANSACTION_AUDIT_ID'
                    ,p_parameter_value7=>-1);
    IF l_esig_reqd  THEN
      X_return_status := 'P';
      UPDATE gmd_routings_b
      SET routing_status = p_pending_status
      WHERE routing_id = p_routing_id;
      IF p_called_from_form = 'F' THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_ERES_PEND_STAT_UPD');
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_to_status_desc);
        FND_FILE.PUT(FND_FILE.LOG,
        FND_MESSAGE.GET||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
        ||' :'||p_object_version||')');
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /* IF l_esig_reqd */
  EXCEPTION
    WHEN PENDING_STATUS_ERR OR
         REWORK_STATUS_ERR THEN
      ROLLBACK TO SAVEPOINT update_routing;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_TOKEN('FROM_STATUS', SUBSTR(l_from_status_desc,1, 80));
      FND_MESSAGE.SET_TOKEN('TO_STATUS', SUBSTR(l_to_status_desc, 1, 80));
      l_text := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_VERSION');
      l_version_lbl := FND_MESSAGE.GET;
      l_text := l_text||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
      ||' :'||p_object_version||')';
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG, l_text);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MESSAGE.SET_NAME ('FND', 'FND_GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('MESSAGE', l_text);
        FND_MSG_PUB.add;
      END IF;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK TO SAVEPOINT update_routing;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - locked exception section ');
      END IF;
      gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                              'TABLE_NAME',
                              'GMD_ROUTINGS_B',
                              'RECORD',
                              'ROUTING_NO : ROUTING_VERS = ',
                              'KEY',
                              p_object_name||':'||p_object_version
                              );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_routing;
      X_return_status := FND_API.g_ret_sts_unexp_error;
      OPEN Cur_get_desc;
      FETCH Cur_get_desc INTO l_replace_type_desc;
      CLOSE Cur_get_desc;

      FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS');
      l_status := FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');
      FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',l_replace_type_desc);
      FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',l_status);
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME',p_object_name);
      FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',l_object_type);
      FND_MESSAGE.SET_TOKEN('OBJECT_VERS',p_object_version);
      FND_MESSAGE.SET_TOKEN('ERRMSG',SQLERRM);
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MSG_PUB.add;
      END IF;
  END update_routing_status;

  /*###############################################################
  # NAME
  #     update_recipe_status
  # SYNOPSIS
  #     update_recipe_status
  # DESCRIPTION
  #    Performs update of the recipe status and the raise of event
  ###############################################################*/

  PROCEDURE update_recipe_status  ( p_recipe_id         IN         VARCHAR2,
                                    p_from_status       IN        VARCHAR2,
                                    p_to_status                IN        VARCHAR2,
                                    p_pending_status        IN        VARCHAR2,
                                    p_rework_status        IN        VARCHAR2,
                                    p_object_name        IN        VARCHAR2,
                                    p_object_version        IN        NUMBER,
                                    p_called_from_form  IN      VARCHAR2,
                                    x_return_status        OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_desc IS
      SELECT meaning
       FROM  gem_lookups
       WHERE lookup_type = 'GMD_SRCH_RPLCE_CRIT_TYPE'
         AND lookup_code = 'RECIPE';

    CURSOR Cur_get_status_desc (pstatus VARCHAR2) IS
      SELECT description
      FROM   gmd_status
      WHERE  status_code = pstatus;

    CURSOR Cur_get_status_type (pstatus VARCHAR2) IS
      SELECT status_type, description
      FROM   gmd_status
      WHERE  status_code = pstatus;

    l_replace_type_desc         VARCHAR2(240);
    l_user_key_label            VARCHAR2(2000);
    l_object_type               VARCHAR2(240);
    l_from_status_desc          VARCHAR2(240);
    l_to_status_desc            VARCHAR2(240);
    l_version_lbl               VARCHAR2(2000);
    l_text                      VARCHAR2(4000);
    l_user_id                   NUMBER := FND_GLOBAL.USER_ID;
    l_status                    VARCHAR2(2000);
    l_esig_reqd                 BOOLEAN;
    l_erec_reqd                 BOOLEAN;
    l_status_type               GMD_STATUS.status_type%TYPE;
    l_post_operation_api        VARCHAR2(4000);

    PENDING_STATUS_ERR  EXCEPTION;
    REWORK_STATUS_ERR   EXCEPTION;
    VR_ERES_REQ         EXCEPTION;
  BEGIN
    SAVEPOINT update_recipe;
    X_return_status := FND_API.g_ret_sts_success;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_RECIPE');
    l_object_type := FND_MESSAGE.GET;

    /* Get the sttaus type */
    OPEN Cur_get_status_type (p_to_status);
    FETCH Cur_get_status_type INTO l_status_type, l_to_status_desc;
      IF Cur_get_status_type%NOTFOUND THEN
         l_status_type := p_to_status;
         CLOSE Cur_get_status_type;
      END IF;
    CLOSE Cur_get_status_type;

    IF (l_debug= 'Y') THEN
      gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
       'The to status type = '||l_status_type);
    END IF;

    /* Bug # 2353561 - Shyam Sitaram  */
    /*ERES Implementation - If approvals are required for the */
    /*status change of the validity rules then the user has to */
    /*do them manually */
    IF (l_status_type IN ('800','900','1000') )  THEN
      IF GMD_ERES_UTILS.check_recipe_validity_eres (p_recipe_id
                                                   ,p_to_status) THEN
         IF (l_debug= 'Y') THEN
           gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
            'VR eres sig is required and it has be done manually ');
         END IF;

         RAISE VR_ERES_REQ;
      ELSE
         /* Based on the recipe status condition - update the Vr status */
         IF l_status_type = '800' THEN
           -- Change status to ON-HOLD for less than ON-HOLD
           UPDATE gmd_recipe_validity_rules
           SET validity_rule_status = p_to_status
           WHERE recipe_id = p_recipe_id
           AND  (to_number(validity_rule_status) < to_number('800') OR
                 to_number(validity_rule_status) between 900 and 999);
         ELSIF l_status_type = '900' THEN
           UPDATE gmd_recipe_validity_rules
           SET validity_rule_status = p_to_status
           WHERE recipe_id = p_recipe_id
           AND  to_number(validity_rule_status) < to_number('800') ;
         ELSIF l_status_type = '1000' THEN
           UPDATE gmd_recipe_validity_rules
           SET validity_rule_status = p_to_status
           WHERE recipe_id = p_recipe_id
           AND  to_number(validity_rule_status) < to_number('1000') ;
         END IF;
      END IF;
    END IF;

    IF (l_debug= 'Y') THEN
      gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
       'About to lock this recipe '||p_recipe_id);
    END IF;

    SELECT 'x'
    INTO l_text
    FROM  gmd_recipes_b
    WHERE recipe_id  = p_recipe_id
    FOR UPDATE OF recipe_status nowait;

    IF (l_debug= 'Y') THEN
      gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
       'About to update recipe with  status = '||p_to_status);
    END IF;

    UPDATE gmd_recipes_b
    SET   recipe_status = p_to_status,
    last_update_date = sysdate,
    last_updated_by = l_user_id
    WHERE  recipe_id = p_recipe_id;

    GMA_STANDARD.PSIG_REQUIRED (p_event => 'oracle.apps.gmd.recipe.sts'
                               ,p_event_key => p_recipe_id
                               ,p_status => l_esig_reqd);

    GMA_STANDARD.EREC_REQUIRED (p_event => 'oracle.apps.gmd.recipe.sts'
                               ,p_event_key => p_recipe_id
                               ,p_status => l_erec_reqd);

    IF (l_debug= 'Y') THEN
      gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
       'Checks if recipe esig is req ');
    END IF;

    IF (l_esig_reqd OR l_erec_reqd) THEN

      IF (l_esig_reqd) THEN

        IF (l_debug= 'Y') THEN
          gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
           'Esig is req with pending sts = '|| p_pending_status);
        END IF;

        OPEN Cur_get_status_desc (p_from_status);
        FETCH Cur_get_status_desc INTO l_from_status_desc;
        CLOSE Cur_get_status_desc;

        OPEN Cur_get_status_desc (p_to_status);
        FETCH Cur_get_status_desc INTO l_to_status_desc;
        CLOSE Cur_get_status_desc;

        IF p_pending_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_PEND_STAT_REQD');
          RAISE PENDING_STATUS_ERR;
        END IF;
        IF p_rework_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_REWK_STAT_REQD');
          RAISE REWORK_STATUS_ERR;
        END IF;
      END IF; /* IF (l_esig_reqd) */

    END IF; /* IF (l_esig_reqd OR l_erec_reqd) */

      IF (l_debug= 'Y') THEN
        gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
          'Raising Esig event ');
      END IF;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_RECP_USR_LBL');
    l_user_key_label := FND_MESSAGE.GET;
    l_post_operation_api := 'GMD_ERES_POST_OPERATION.set_recipe_status('||
                                           p_recipe_id||', '||
                                           p_from_status||', '||
                                           p_to_status;
    IF GMD_RECIPE_GENERATE.create_validity THEN
      l_post_operation_api := l_post_operation_api||', '||1;
    END IF;
    l_post_operation_api := l_post_operation_api||');';
    GMD_EDR_STANDARD.raise_event (p_event_name => 'oracle.apps.gmd.recipe.sts'
                    ,p_event_key => p_recipe_id
                    ,p_parameter_name1 => 'DEFERRED'
                    ,p_parameter_value1 => 'Y'
                    ,p_parameter_name2 => 'POST_OPERATION_API'
                    ,p_parameter_value2 => l_post_operation_api
                    ,p_parameter_name3 => 'PSIG_USER_KEY_LABEL'
                    ,p_parameter_value3 =>l_user_key_label
                    ,p_parameter_name4 => 'PSIG_USER_KEY_VALUE'
                    ,p_parameter_value4 => p_object_name||', '||p_object_version
                    ,p_parameter_name5 => '#WF_SOURCE_APPLICATION_TYPE'
                    ,p_parameter_value5 =>'DB'
                    ,p_parameter_name6 => '#WF_SIGN_REQUESTER'
                    ,p_parameter_value6 =>FND_GLOBAL.user_name
                    ,p_parameter_name7 =>'PSIG_TRANSACTION_AUDIT_ID'
                    ,p_parameter_value7=>-1);

    IF (l_debug= 'Y') THEN
    gmd_debug.put_line('In GMD_ERES_UTILS.update_receip_status : '||
     'After Raise Esig event ');
    END IF;

    IF l_esig_reqd  THEN
      X_return_status := 'P';
      UPDATE gmd_recipes_b
      SET recipe_status = p_pending_status
      WHERE recipe_id = p_recipe_id;
      IF p_called_from_form = 'F' THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_ERES_PEND_STAT_UPD');
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_to_status_desc);
        FND_FILE.PUT(FND_FILE.LOG,
        FND_MESSAGE.GET||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
        ||' :'||p_object_version||')');
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /* IF l_esig_reqd */
  EXCEPTION
    WHEN PENDING_STATUS_ERR OR
         REWORK_STATUS_ERR THEN
      ROLLBACK TO SAVEPOINT update_recipe;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_TOKEN('FROM_STATUS', SUBSTR(l_from_status_desc,1, 80));
      FND_MESSAGE.SET_TOKEN('TO_STATUS', SUBSTR(l_to_status_desc, 1, 80));
      l_text := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_VERSION');
      l_version_lbl := FND_MESSAGE.GET;
      l_text := l_text||' ( '||l_object_type||' :'||p_object_name||' '||l_version_lbl
      ||' :'||p_object_version||')';
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG, l_text);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MESSAGE.SET_NAME ('FND', 'FND_GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('MESSAGE', l_text);
        FND_MSG_PUB.add;
      END IF;
    WHEN VR_ERES_REQ THEN
      ROLLBACK TO SAVEPOINT update_recipe;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_VLDT_APPR_REQD');
      FND_MESSAGE.SET_TOKEN('STATUS', l_to_status_desc);
      l_text := FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');
      FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',l_replace_type_desc);
      FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',l_status);
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME',p_object_name);
      FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',l_object_type);
      FND_MESSAGE.SET_TOKEN('OBJECT_VERS',p_object_version);
      FND_MESSAGE.SET_TOKEN('ERRMSG',l_text);
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MSG_PUB.add;
      END IF;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK TO SAVEPOINT update_recipe;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - locked exception section ');
      END IF;
      gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                              'TABLE_NAME',
                              'GMD_RECIPES_B',
                              'RECORD',
                              'RECIPE_NO : RECIPE_VERSION = ',
                              'KEY',
                              p_object_name||':'||p_object_version
                              );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_recipe;
      X_return_status := FND_API.g_ret_sts_unexp_error;
      OPEN Cur_get_desc;
      FETCH Cur_get_desc INTO l_replace_type_desc;
      CLOSE Cur_get_desc;

      FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS');
      l_status := FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('GMD','GMD_CONC_UPDATE_OBJECT_FAILED');
      FND_MESSAGE.SET_TOKEN('REPLACE_TYPE',l_replace_type_desc);
      FND_MESSAGE.SET_TOKEN('REPLACE_VALUE',l_status);
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME',p_object_name);
      FND_MESSAGE.SET_TOKEN('OBJECT_TYPE',l_object_type);
      FND_MESSAGE.SET_TOKEN('OBJECT_VERS',p_object_version);
      FND_MESSAGE.SET_TOKEN('ERRMSG',SQLERRM);
      IF p_called_from_form = 'F' THEN
        FND_FILE.PUT(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
        FND_MSG_PUB.add;
      END IF;
    END update_recipe_status;

  /*###############################################################
  # NAME
  #     update_validity_rule_status
  # SYNOPSIS
  #     update_validity_rule_status
  # DESCRIPTION
  #    Performs update of the validity status and the raise of event
  ###############################################################*/
  PROCEDURE update_validity_rule_status ( p_validity_rule_id IN VARCHAR2,
                                        p_from_status        IN        VARCHAR2,
                                        p_to_status             IN        VARCHAR2,
                                        p_pending_status     IN        VARCHAR2,
                                        p_rework_status             IN        VARCHAR2,
                                        p_called_from_form   IN        VARCHAR2 DEFAULT 'F',
                                        x_return_status             OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_status_desc (pstatus VARCHAR2) IS
      SELECT description
      FROM   gmd_status
      WHERE  status_code = pstatus;

    CURSOR Cur_get_recipe_info(vVR_id NUMBER) IS
      SELECT a.recipe_no, a.recipe_version, b.recipe_use
      FROM   gmd_recipes_b a, gmd_recipe_validity_rules b
      WHERE  a.recipe_id = b.recipe_id
      AND    b.recipe_validity_rule_id = vVr_id;

    /* Get the recipe use lookup meaning */
    CURSOR Cur_get_lookup_meaning(vlookup_code NUMBER) IS
      SELECT meaning
      FROM   gem_lookups
      WHERE  lookup_type = 'GMD_FORMULA_USE'
      AND    lookup_code = vlookup_code;

    l_replace_type_desc         VARCHAR2(240);
    l_user_key_label            VARCHAR2(2000);
    l_object_type               VARCHAR2(240);
    l_from_status_desc          VARCHAR2(240);
    l_to_status_desc            VARCHAR2(240);
    l_version_lbl               VARCHAR2(2000);
    l_text                      VARCHAR2(4000);
    l_user_id                   NUMBER := FND_GLOBAL.USER_ID;
    l_status                    VARCHAR2(2000);
    l_esig_reqd                 BOOLEAN;
    l_erec_reqd                 BOOLEAN;

    l_recipe_no                 gmd_recipes_b.recipe_no%TYPE;
    l_recipe_version            gmd_recipes_b.recipe_version%TYPE;
    l_recipe_use_code           NUMBER;
    l_recipe_use_meaning        VARCHAR2(100);

    l_user_key_value            VARCHAR2(2000) := '';
    l_api_name                  VARCHAR2(100)  := 'UPDATE_VALIDITY_RULE_STATUS';

    PENDING_STATUS_ERR  EXCEPTION;
    REWORK_STATUS_ERR   EXCEPTION;
    RECIPE_IS_INVALID   EXCEPTION;
  BEGIN
    SAVEPOINT update_validity;
    X_return_status := FND_API.g_ret_sts_success;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_VALIDITY');
    l_object_type := FND_MESSAGE.GET;

    SELECT 'x'
    INTO l_text
    FROM  gmd_recipe_validity_rules
    WHERE recipe_validity_rule_id = P_validity_rule_id
    FOR UPDATE OF validity_rule_status nowait;

    UPDATE gmd_recipe_validity_rules
    SET    validity_rule_status = p_to_status,
           last_update_date = sysdate,
           last_updated_by = l_user_id
    WHERE  recipe_validity_rule_id = P_validity_rule_id;

    GMA_STANDARD.PSIG_REQUIRED (p_event => 'oracle.apps.gmd.validity.sts'
                               ,p_event_key => P_validity_rule_id
                               ,p_status => l_esig_reqd);

    GMA_STANDARD.EREC_REQUIRED (p_event => 'oracle.apps.gmd.validity.sts'
                               ,p_event_key => P_validity_rule_id
                               ,p_status => l_erec_reqd);

    IF (l_esig_reqd OR l_erec_reqd) THEN

      IF (l_esig_reqd) THEN
        OPEN Cur_get_status_desc (p_from_status);
        FETCH Cur_get_status_desc INTO l_from_status_desc;
        CLOSE Cur_get_status_desc;

        OPEN Cur_get_status_desc (p_to_status);
        FETCH Cur_get_status_desc INTO l_to_status_desc;
        CLOSE Cur_get_status_desc;

        IF p_pending_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_PEND_STAT_REQD');
          RAISE PENDING_STATUS_ERR;
        END IF;
        IF p_rework_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_REWK_STAT_REQD');
          RAISE REWORK_STATUS_ERR;
        END IF;
      END IF; /* IF (l_esig_reqd) */
    END IF; /* IF (l_esig_reqd OR l_erec_reqd) */

    OPEN Cur_get_recipe_info(P_validity_rule_id);
    FETCH Cur_get_recipe_info INTO l_recipe_no, l_recipe_version, l_recipe_use_code;
      IF Cur_get_recipe_info%NOTFOUND THEN
         CLOSE Cur_get_recipe_info;
         RAISE RECIPE_IS_INVALID;
      ELSE
        /* Get the recipe use meaning */
        OPEN  Cur_get_lookup_meaning(l_recipe_use_code);
        FETCH Cur_get_lookup_meaning INTO l_recipe_use_meaning;
          IF Cur_get_lookup_meaning%NOTFOUND THEN
             CLOSE Cur_get_lookup_meaning;
             l_recipe_use_meaning := '';
          END IF;
        CLOSE Cur_get_lookup_meaning;
        l_user_key_value := l_recipe_no||', '||l_recipe_version||', '||l_recipe_use_meaning;
      END IF;
    CLOSE Cur_get_recipe_info;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_VLD_USR_LBL');
    l_user_key_label := FND_MESSAGE.GET;
    GMD_EDR_STANDARD.raise_event (p_event_name => 'oracle.apps.gmd.validity.sts'
                    ,p_event_key => P_validity_rule_id
                    ,p_parameter_name1 => 'DEFERRED'
                    ,p_parameter_value1 => 'Y'
                    ,p_parameter_name2 => 'POST_OPERATION_API'
                    ,p_parameter_value2 =>'GMD_ERES_POST_OPERATION.set_validity_status('||
                                           P_validity_rule_id||', '||
                                           p_from_status||', '||
                                           p_to_status||');'
                    ,p_parameter_name3 => 'PSIG_USER_KEY_LABEL'
                    ,p_parameter_value3 =>l_user_key_label
                    ,p_parameter_name4 => 'PSIG_USER_KEY_VALUE'
                    ,p_parameter_value4 =>l_user_key_value
                    ,p_parameter_name5 => '#WF_SOURCE_APPLICATION_TYPE'
                    ,p_parameter_value5 =>'DB'
                    ,p_parameter_name6 => '#WF_SIGN_REQUESTER'
                    ,p_parameter_value6 =>FND_GLOBAL.user_name
                    ,p_parameter_name7 =>'PSIG_TRANSACTION_AUDIT_ID'
                    ,p_parameter_value7=>-1);
    IF l_esig_reqd  THEN
      X_return_status := 'P';
      UPDATE gmd_recipe_validity_rules
      SET validity_rule_status = p_pending_status
      WHERE recipe_validity_rule_id = P_validity_rule_id;

      IF p_called_from_form = 'F' THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_ERES_PEND_STAT_UPD');
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_to_status_desc);
        FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /* IF l_esig_reqd */
  EXCEPTION
    WHEN PENDING_STATUS_ERR OR
         REWORK_STATUS_ERR THEN
      ROLLBACK TO SAVEPOINT update_validity;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_TOKEN('FROM_STATUS', SUBSTR(l_from_status_desc,1, 80));
      FND_MESSAGE.SET_TOKEN('TO_STATUS', SUBSTR(l_to_status_desc, 1, 80));

      l_text := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME ('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', l_text);
      FND_MSG_PUB.add;
    WHEN RECIPE_IS_INVALID THEN
       ROLLBACK TO SAVEPOINT update_validity;
       X_return_status := FND_API.g_ret_sts_error;
       FND_MESSAGE.SET_NAME ('GMD', 'GMD_RECIPE_INFO');
       FND_MSG_PUB.ADD;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK TO SAVEPOINT update_validity;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - locked exception section ');
      END IF;
      gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                              'TABLE_NAME',
                              'GMD_RECIPE_VALIDITY_RULES',
                              'RECORD',
                              'RECIPE_VALIDITY_RULE_ID = ',
                              'KEY',
                              P_validity_rule_id
                              );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_validity;
      X_return_status := FND_API.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg ('GMD_ERES_UTILS', l_api_name);
  END update_validity_rule_status;

/*###############################################################
  # NAME
  #     update_substitution_status
  # SYNOPSIS
  #     update_substitution_status
  # DESCRIPTION
  #    Procdure will update the substitution status based on the default status
  #    and raise the event if required.
  #    Added the procedure for bug#5394532.
  ###############################################################*/

PROCEDURE update_substitution_status (p_substitution_id IN NUMBER,
                                      p_from_status        IN        VARCHAR2,
                                      p_to_status             IN        VARCHAR2,
                                      p_pending_status     IN        VARCHAR2,
                                      p_rework_status             IN        VARCHAR2,
                                      p_called_from_form   IN        VARCHAR2 DEFAULT 'F',
                                      x_return_status             OUT NOCOPY VARCHAR2) IS

    CURSOR Cur_get_status_desc (pstatus VARCHAR2) IS
      SELECT description
      FROM   gmd_status
      WHERE  status_code = pstatus;


    CURSOR Cur_subs_details IS
     SELECT owner_organization_id,
            substitution_name,
	    substitution_version
       FROM gmd_item_substitution_hdr
      WHERE substitution_id = p_substitution_id;

    l_subs_details  Cur_subs_details%rowtype;
    l_esig_reqd		BOOLEAN;
    l_erec_reqd 	BOOLEAN;
    l_user_key_label	VARCHAR2(2000);
    l_text              VARCHAR2(1);
    l_from_status_desc          VARCHAR2(240);
    l_to_status_desc            VARCHAR2(240);
    l_api_name                  VARCHAR2(100)  := 'UPDATE_SUBSTITUTION_STATUS';

    PENDING_STATUS_ERR  EXCEPTION;
    REWORK_STATUS_ERR   EXCEPTION;

  BEGIN
    SAVEPOINT update_substitution;
    X_return_status := FND_API.g_ret_sts_success;

    SELECT 'x'
      INTO l_text
      FROM  gmd_item_substitution_hdr_b
      WHERE substitution_id = p_substitution_id
      FOR UPDATE OF substitution_status nowait;

    UPDATE gmd_item_substitution_hdr_b
      SET    substitution_status = p_to_status,
             last_update_date = sysdate,
             last_updated_by = fnd_global.user_id
      WHERE  substitution_id = p_substitution_id;

    GMA_STANDARD.PSIG_REQUIRED (p_event => 'oracle.apps.gmd.itemsub.sts'
                                 ,p_event_key => p_substitution_id
                                 ,p_status => l_esig_reqd);

    GMA_STANDARD.EREC_REQUIRED (p_event => 'oracle.apps.gmd.itemsub.sts'
                                 ,p_event_key => p_substitution_id
                                 ,p_status => l_erec_reqd);

    IF (l_esig_reqd OR l_erec_reqd) THEN
      IF (l_esig_reqd) THEN
        OPEN Cur_get_status_desc (p_from_status);
        FETCH Cur_get_status_desc INTO l_from_status_desc;
        CLOSE Cur_get_status_desc;

        OPEN Cur_get_status_desc (p_to_status);
        FETCH Cur_get_status_desc INTO l_to_status_desc;
        CLOSE Cur_get_status_desc;

        IF p_pending_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_PEND_STAT_REQD');
          RAISE PENDING_STATUS_ERR;
        END IF;
        IF p_rework_status IS NULL THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_REWK_STAT_REQD');
          RAISE REWORK_STATUS_ERR;
        END IF;
      END IF; /* IF (l_esig_reqd) */
    END IF; /* IF (l_esig_reqd OR l_erec_reqd) */

    OPEN Cur_subs_details;
    FETCH Cur_subs_details INTO l_subs_details;
    CLOSE Cur_subs_details;

    FND_MESSAGE.SET_NAME('GMD', 'GMD_ERES_SUBSTITUTION_USR_LBL');
    l_user_key_label := FND_MESSAGE.GET;

    GMD_EDR_STANDARD.raise_event (p_event_name => 'oracle.apps.gmd.itemsub.sts'
  		                    ,p_event_key => p_substitution_id
                		    ,p_parameter_name1 => 'DEFERRED'
		                    ,p_parameter_value1 => 'Y'
                		    ,p_parameter_name2 => 'POST_OPERATION_API'
		                    ,p_parameter_value2 =>'GMD_ERES_POST_OPERATION.set_substition_status('||
                                     p_substitution_id||', '||
                                     p_from_status||', '||
                                     p_to_status||');'
		                    ,p_parameter_name3 => 'PSIG_USER_KEY_LABEL'
                		    ,p_parameter_value3 =>l_user_key_label
		                    ,p_parameter_name4 => 'PSIG_USER_KEY_VALUE'
                		    ,p_parameter_value4 => l_subs_details.substitution_name||', '||l_subs_details.substitution_version
		                    ,p_parameter_name5 => '#WF_SOURCE_APPLICATION_TYPE'
                		    ,p_parameter_value5 =>'DB'
		                    ,p_parameter_name6 => '#WF_SIGN_REQUESTER'
		                    ,p_parameter_value6 =>FND_GLOBAL.user_name
		                    ,p_parameter_name7 =>'PSIG_TRANSACTION_AUDIT_ID'
		                    ,p_parameter_value7=>-1);

    IF l_esig_reqd  THEN
      X_return_status := 'P';
      UPDATE gmd_item_substitution_hdr_b
        SET substitution_status = p_pending_status
        WHERE  substitution_id = p_substitution_id;

      IF p_called_from_form = 'F' THEN
        FND_MESSAGE.SET_NAME('GMD','GMD_ERES_PEND_STAT_UPD');
        FND_MESSAGE.SET_TOKEN('TO_STATUS', l_to_status_desc);
        FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
    END IF; /* IF l_esig_reqd */
  EXCEPTION
    WHEN PENDING_STATUS_ERR OR
         REWORK_STATUS_ERR THEN
      ROLLBACK TO SAVEPOINT update_substitution;
      X_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.SET_TOKEN('FROM_STATUS', SUBSTR(l_from_status_desc,1, 80));
      FND_MESSAGE.SET_TOKEN('TO_STATUS', SUBSTR(l_to_status_desc, 1, 80));

      l_text := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME ('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', l_text);
      FND_MSG_PUB.add;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK TO SAVEPOINT update_substitution;
      X_return_status := FND_API.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line ('In GMDERESB.pls - locked exception section ');
      END IF;
      gmd_api_grp.log_message('GMD_RECORD_LOCKED',
                              'TABLE_NAME',
                              'GMD_ITEM_SUBSTITUTION_HDR_B',
                              'RECORD',
                              'SUBSTITUTION_ID = ',
                              'KEY',
                              P_substitution_id
                              );
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT update_substitution;
      X_return_status := FND_API.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg ('GMD_ERES_UTILS', l_api_name);


  END update_substitution_status;

  /*###############################################################
  # NAME
  #     get_recipe_details
  # SYNOPSIS
  #     get_recipe_details
  # DESCRIPTION
  #    Procdure will fetch the recipe info based on the formula
  ###############################################################*/

  PROCEDURE get_recipe_details (
  	P_formula_id    	IN         NUMBER,
        P_recipe_no        	OUT NOCOPY VARCHAR2,
        P_recipe_vers        	OUT NOCOPY NUMBER,
        P_recipe_desc        	OUT NOCOPY VARCHAR2,
        P_recipe_status        	OUT NOCOPY VARCHAR2,
        P_recipe_type           OUT NOCOPY NUMBER )
  IS
    	X_recipe_tbl           GMD_RECIPE_HEADER.recipe_hdr;
    	X_recipe_flex          GMD_RECIPE_HEADER.flex;
    	l_return_status        VARCHAR2(1);
  BEGIN
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	gmd_api_grp.retrieve_recipe (
    		p_formula_id    => p_formula_id,
                l_recipe_tbl    => X_recipe_tbl,
                l_recipe_flex   => X_recipe_flex,
                x_return_status => l_return_status);

    	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       		p_recipe_no          := X_recipe_tbl.recipe_no;
       		p_recipe_vers        := X_recipe_tbl.recipe_version;
       		p_recipe_desc        := X_recipe_tbl.recipe_description;
       		p_recipe_status      := X_recipe_tbl.recipe_status;
       		p_recipe_type        := X_recipe_tbl.recipe_type;
    	END IF;
  END get_recipe_details;

  /*###############################################################
  # NAME
  #     get_validity_details
  # SYNOPSIS
  #     get_validity_details
  # DESCRIPTION
  #    Procdure will fetch the validity rule info based on the formula
  #    10-Feb-2005  Krishna
  #         Added additional parameters p_orgn_id, p_revision
  ###############################################################*/

 PROCEDURE get_validity_details (
  	P_formula_id           IN         NUMBER,
  	p_orgn_id              OUT NOCOPY NUMBER, -- Krishna NPD Conv
  	P_item_id              OUT NOCOPY NUMBER,
  	--p_revision             OUT NOCOPY NUMBER, -- Krishna NPD Conv
  	p_revision             OUT NOCOPY VARCHAR2,
  	P_item_um              OUT NOCOPY VARCHAR2,
  	P_min_qty              OUT NOCOPY NUMBER,
  	P_max_qty              OUT NOCOPY NUMBER,
  	P_std_qty              OUT NOCOPY NUMBER,
  	P_inv_min_qty          OUT NOCOPY NUMBER,
  	P_inv_max_qty          OUT NOCOPY NUMBER,
  	P_min_eff_date         OUT NOCOPY DATE,
  	P_max_eff_date         OUT NOCOPY DATE,
  	P_recipe_use           OUT NOCOPY VARCHAR2,
  	P_preference           OUT NOCOPY NUMBER,
  	P_validity_rule_status OUT NOCOPY VARCHAR2)
 IS
    	X_recipe_vr 		GMD_RECIPE_DETAIL.recipe_vr;
    	X_vr_flex   		GMD_RECIPE_DETAIL.flex;

    	l_return_status 	VARCHAR2(1);
    	l_recipe_use   		VARCHAR2(2000);
    	l_recipe_use_temp 	VARCHAR2(40);

    	CURSOR Cur_recipe_use(V_lookup_code VARCHAR2) IS
      		SELECT meaning
      		FROM   gem_lookups
      		WHERE  lookup_type = 'GMD_FORMULA_USE'
      		and    lookup_code = V_lookup_code;

 BEGIN
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	gmd_api_grp.retrieve_vr (
    		p_formula_id    => p_formula_id,
                l_recipe_vr_tbl => X_recipe_vr,
                l_vr_flex       => X_vr_flex,
                x_return_status => l_return_status );

    	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      		p_item_id               := X_recipe_vr.inventory_item_id;
      		p_revision              := X_recipe_vr.revision; --  NPD Conv
      		p_orgn_id               := X_recipe_vr.organization_id; --  NPD Conv
      		p_item_um               := X_recipe_vr.detail_uom;
      		p_min_qty               := X_recipe_vr.min_qty;
      		p_max_qty               := X_recipe_vr.max_qty;
      		p_std_qty               := X_recipe_vr.std_qty;
      		p_inv_min_qty           := X_recipe_vr.inv_min_qty;
      		p_inv_max_qty           := X_recipe_vr.inv_max_qty;
      		p_min_eff_date          := X_recipe_vr.start_date;
      		p_max_eff_date          := X_recipe_vr.end_date;
      		l_recipe_use_temp       := SUBSTR(X_recipe_vr.recipe_use, 1,1);

      		IF l_recipe_use_temp = 1 THEN
      		        OPEN CUR_recipe_use (0);
        		FETCH Cur_recipe_use INTO l_recipe_use_temp;
        		CLOSE Cur_recipe_use;
        		l_recipe_use := l_recipe_use_temp;
      		END IF;

      		l_recipe_use_temp       := SUBSTR(X_recipe_vr.recipe_use, 2,1);

      		IF l_recipe_use_temp = 1 THEN
        		OPEN CUR_recipe_use (1);
        		FETCH Cur_recipe_use INTO l_recipe_use_temp;
        		CLOSE Cur_recipe_use;

        		IF l_recipe_use IS NOT NULL THEN
        	  		l_recipe_use := l_recipe_use||',';
        		END IF;
        		l_recipe_use := l_recipe_use||l_recipe_use_temp;
      		END IF;

      		l_recipe_use_temp       := SUBSTR(X_recipe_vr.recipe_use, 3,1);

      		IF l_recipe_use_temp = 1 THEN
        		OPEN CUR_recipe_use (2);
        		FETCH Cur_recipe_use INTO l_recipe_use_temp;
        		CLOSE Cur_recipe_use;

        		IF l_recipe_use IS NOT NULL THEN
          			l_recipe_use := l_recipe_use||',';
        		END IF;

        		l_recipe_use := l_recipe_use||l_recipe_use_temp;
      		END IF;

      		l_recipe_use_temp       := SUBSTR(X_recipe_vr.recipe_use, 4,1);

      		IF l_recipe_use_temp = 1 THEN
      			OPEN CUR_recipe_use (3);
        		FETCH Cur_recipe_use INTO l_recipe_use_temp;
        		CLOSE Cur_recipe_use;

        		IF l_recipe_use IS NOT NULL THEN
          			l_recipe_use := l_recipe_use||',';
        		END IF;
        		l_recipe_use := l_recipe_use||l_recipe_use_temp;
      		END IF;

      		l_recipe_use_temp       := SUBSTR(X_recipe_vr.recipe_use, 5,1);

      		IF l_recipe_use_temp = 1 THEN
      	  		OPEN CUR_recipe_use (4);
        		FETCH Cur_recipe_use INTO l_recipe_use_temp;
        		CLOSE Cur_recipe_use;

        		IF l_recipe_use IS NOT NULL THEN
          			l_recipe_use := l_recipe_use||',';
        		END IF;
        		l_recipe_use := l_recipe_use||l_recipe_use_temp;
      		END IF;

      		p_recipe_use            := l_recipe_use;
      		p_preference            := X_recipe_vr.preference;
      		p_validity_rule_status  := X_recipe_vr.validity_rule_status;
    	END IF;
 END get_validity_details;

  /*###############################################################
  # NAME
  #     GET_ITEM_NO_DESC
  # SYNOPSIS
  #     GET_ITEM_NO_DESC(l_item_id, l_orgn_code, l_item_no, l_item_desc);
  # DESCRIPTION
  #    Procdure will fetch the item no, description based on organization_id, item_id
  ###############################################################*/

PROCEDURE get_item_no_desc   (
    pitem_id          IN NUMBER,
    porgn_id          IN NUMBER,
    pitem_no          OUT NOCOPY VARCHAR2,
    pitem_desc          OUT NOCOPY VARCHAR2 )IS
  CURSOR get_item_no_desc IS
    SELECT concatenated_segments, description
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = pitem_id
     AND organization_id = porgn_id;
  BEGIN
    OPEN get_item_no_desc;
    FETCH get_item_no_desc
     INTO pitem_no, pitem_desc;
    IF (get_item_no_desc%NOTFOUND) THEN
        pitem_no := ' ';
        pitem_desc := ' ';
    END IF;
    CLOSE get_item_no_desc;
  END get_item_no_desc;

  /*###############################################################
  # NAME
  #     GET_ORGANIZATION_CODE
  # SYNOPSIS
  #     GET_ORGANIZATION_CODE(1381,l_orgn_code);
  # DESCRIPTION
  #    Procdure will fetch the organization code based on organization_id
  ###############################################################*/

PROCEDURE get_organization_code
(p_orgn_id IN NUMBER,
 p_orgn_code OUT NOCOPY VARCHAR2) IS
 CURSOR Cur_get_orgn_code IS
  SELECT organization_code
  FROM   ORG_ORGANIZATION_DEFINITIONS
  WHERE  organization_id = p_orgn_id;
 BEGIN  OPEN Cur_get_orgn_code;
 FETCH Cur_get_orgn_code
  INTO p_orgn_code;
 CLOSE Cur_get_orgn_code;
END get_organization_code;

 /*###############################################################
 # NAME
 #      GET_LOOKUP_VALUE
 # SYNOPSIS
 #      GET_LOOKUP_VALUE(l_lookup_type, l_lookup_code, l_meaning);
 # DESCRIPTION
 #    Procdure will fetch the item no, description based on organization_id, item_id
 ###############################################################*/

PROCEDURE get_lookup_value (
 plookup_type       IN VARCHAR2,
 plookup_code       IN VARCHAR2,
 pmeaning           OUT NOCOPY VARCHAR2) IS

CURSOR get_lookup IS
  SELECT meaning
  FROM fnd_lookup_values_vl
  WHERE  lookup_type = plookup_type  and
         lookup_code = plookup_code;

BEGIN
  OPEN get_lookup;
  FETCH get_lookup into pmeaning;
  IF (get_lookup%NOTFOUND) THEN
     pmeaning := ' ';
  END IF;
  CLOSE get_lookup;

END get_lookup_value;

/*======================================================================
--  PROCEDURE :
--   get_tech_parm_name
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    technical parameter name and unit code for a given tech_parm_id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_tech_parm_name (100, P_tech_parm_name,P_unit_code);
--
--===================================================================== */
PROCEDURE get_tech_parm_name(P_tech_parm_id IN NUMBER, P_tech_parm_name OUT NOCOPY VARCHAR2,
                             P_unit_code OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_param IS
     SELECT tech_parm_name, lm_unit_code
     FROM   gmd_tech_parameters_b
     WHERE  tech_parm_id = P_tech_parm_id;
BEGIN
  OPEN Cur_get_param;
  FETCH Cur_get_param INTO P_tech_parm_name,P_unit_code;
  CLOSE Cur_get_param;
END get_tech_parm_name;

/*======================================================================
--  PROCEDURE :
--   get_category_name
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    category name for a given category_id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_category_name (100, p_category_name);
--
--===================================================================== */
PROCEDURE get_category_name(P_category_id IN NUMBER, P_category_name OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_category IS
     SELECT concatenated_segments
     FROM   mtl_categories_kfv
     WHERE  category_id = P_category_id;
BEGIN
  OPEN Cur_get_category;
  FETCH Cur_get_category INTO P_category_name;
  CLOSE Cur_get_category;
END get_category_name;

/*======================================================================
--  PROCEDURE :
--   get_category_set_name
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    category set name for a given category_set_id.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_category_set_name (100, p_category_set_name);
--
--===================================================================== */
PROCEDURE get_category_set_name(P_category_set_id IN NUMBER, P_category_set_name OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_category_set IS
     SELECT category_set_name
     FROM   mtl_category_sets
     WHERE  category_set_id = P_category_set_id;
BEGIN
  OPEN Cur_get_category_set;
  FETCH Cur_get_category_set INTO P_category_set_name;
  CLOSE Cur_get_category_set;
END get_category_set_name;


/*======================================================================
--  PROCEDURE :
--   get_formula_line_no
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    formula_line_no corresponding to formula_line_id
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_formula_line_no (100, P_formulaline_no);
--
--===================================================================== */
PROCEDURE get_formula_line_no(P_formulaline_id IN NUMBER,P_formulaline_no OUT NOCOPY NUMBER) IS
  CURSOR Cur_get_lineno IS
     SELECT LINE_NO
     FROM fm_matl_dtl
     WHERE formulaline_id = P_formulaline_id;
BEGIN
  OPEN Cur_get_lineno;
  FETCH Cur_get_lineno INTO P_formulaline_no;
  CLOSE Cur_get_lineno;
END get_formula_line_no;


/*======================================================================
--  PROCEDURE :
--   get_routing_details_eres
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    Routing Details for Auto Recipe ERES
--
--  HISTORY
--      Kapil M 03-JAN-07   Created for Bug# 5458666
--
--===================================================================== */
PROCEDURE get_routing_details_eres (
	           	P_doc_id      	IN  	   VARCHAR2,
                P_routing_no        	OUT NOCOPY VARCHAR2,
                P_routing_vers        	OUT NOCOPY NUMBER,
                P_routing_desc        	OUT NOCOPY VARCHAR2,
                P_routing_status        	OUT NOCOPY VARCHAR2,
                P_enhancd_PI_ind            OUT NOCOPY VARCHAR2  )IS

    p_routing_id NUMBER;
    CURSOR Cur_get_routing_details(V_routing_id NUMBER) IS
        SELECT ROUTING_NO, ROUTING_VERS ,ROUTING_DESC , b.MEANING
        FROM gmd_routings_vl a , gmd_status b
        WHERE a.routing_id = V_routing_id
        AND a.routing_status = b.status_code;

    CURSOR Cur_get_value (vLookup_code VARCHAR2) IS
        SELECT MEANING
        FROM GEM_LOOKUPS
        WHERE LOOKUP_TYPE = 'GME_YES'
        AND LOOKUP_CODE = vLookup_code;

l_temp_id       VARCHAR2(240);

BEGIN
        -- Get the routing_id from the document_id
    l_temp_id := substr(P_doc_id,instr(P_doc_id,'$')+1,length(P_doc_id));
    P_enhancd_PI_ind :=substr(l_temp_id,instr(l_temp_id,'$')+1,length(l_temp_id));
    p_routing_id := substr(l_temp_id,1,instr(l_temp_id,'$')-1);

    IF p_routing_id IS NOT NULL THEN
     OPEN Cur_get_routing_details(p_routing_id);
     FETCH Cur_get_routing_details INTO P_routing_no, P_routing_vers ,P_routing_desc , P_routing_status;
     CLOSE Cur_get_routing_details;

      IF (P_enhancd_PI_ind = NULL) THEN
        P_enhancd_PI_ind := 'N';
      END IF;
    ELSE
        P_enhancd_PI_ind := 'N';
    END IF;

        OPEN Cur_get_value (P_enhancd_PI_ind);
        FETCH Cur_get_value INTO P_enhancd_PI_ind;
        CLOSE Cur_get_value;
END get_routing_details_eres;

/*======================================================================
--  PROCEDURE :
--   get_yes_no_value
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    Yes/No value for Y/N Flags
--
--  HISTORY
--      Kapil M 12-FEB-07   Created for Bug# 5716318
--                          Used for Calculate Product Qty flag
--
--===================================================================== */
PROCEDURE get_yes_no_value (
                      plookup_code       IN VARCHAR2,
                      pmeaning           OUT NOCOPY VARCHAR2) IS

  CURSOR get_lookup IS
    SELECT meaning
    FROM fnd_lookup_values_vl
    WHERE  lookup_type = 'GME_YES'  and
           lookup_code = plookup_code;

  BEGIN
   OPEN get_lookup;
   FETCH get_lookup into pmeaning;
    IF (get_lookup%NOTFOUND) THEN
       pmeaning := ' ';
    END IF;
   CLOSE get_lookup;

END get_yes_no_value ;

end GMD_ERES_UTILS;

/
