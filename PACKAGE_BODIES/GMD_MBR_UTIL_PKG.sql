--------------------------------------------------------
--  DDL for Package Body GMD_MBR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_MBR_UTIL_PKG" AS
/* $Header: GMDMBRUB.pls 120.3 2006/10/02 21:15:41 srpuri noship $ */

   PROCEDURE GET_ACTIVITY_FACTOR(p_RECIPE_ID number,
                                 p_ROUTINGSTEP_ID number,
                                 p_OPRN_LINE_ID number,
                                 p_DOCUMENT_id VARCHAR2,
                                 p_Default_factor number,
                                 x_org_specific_factor OUT NOCOPY NUMBER) AS
    CURSOR CUR_GET_ACTIVITY_FACTOR IS
      SELECT activity_factor
      FROM   gmd_recipe_orgn_activities
      WHERE RECIPE_ID       = P_RECIPE_ID
        AND ROUTINGSTEP_ID  = P_ROUTINGSTEP_ID
        AND OPRN_LINE_ID    = P_OPRN_LINE_ID
        AND ORGANIZATION_ID = substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1,
                                     decode(instrb(P_DOCUMENT_ID,'-',1,2),0,
                                            length(substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1)),
                                            instrb(P_DOCUMENT_ID,'-',1,2)-(instrb(P_DOCUMENT_ID,'-',1,1)+1)));
  BEGIN
     OPEN CUR_GET_ACTIVITY_FACTOR;
     FETCH CUR_GET_ACTIVITY_FACTOR INTO x_org_specific_factor;
     IF CUR_GET_ACTIVITY_FACTOR%NOTFOUND THEN
       x_org_specific_factor := p_Default_factor;
     END IF;
     CLOSE CUR_GET_ACTIVITY_FACTOR;
  END GET_ACTIVITY_FACTOR;


  PROCEDURE GET_RECIPE_RSRC_ORGN_OVERRIDES(
                                 P_RECIPE_ID           number
                                ,P_ROUTINGSTEP_ID      number
                                ,P_OPRN_LINE_ID        number
                                ,P_RESOURCES           VARCHAR2
                                ,P_PROCESS_UOM         VARCHAR2
                                ,P_USAGE_UM            VARCHAR2
                                ,P_RESOURCE_USAGE      number
                                ,P_PROCESS_QTY         number
                                ,P_DOCUMENT_ID         VARCHAR2
                                ,P_MIN_CAPACITY        number
                                ,P_MAX_CAPACITY        number
                                ,P_CAPACITY_UM         VARCHAR2
                                ,x_PROCESS_UOM         OUT NOCOPY VARCHAR2
                                ,x_USAGE_UM            OUT NOCOPY VARCHAR2
                                ,x_RESOURCE_USAGE      OUT NOCOPY VARCHAR2
                                ,x_PROCESS_QTY         OUT NOCOPY number
                                ,x_MIN_CAPACITY        OUT NOCOPY number
                                ,x_MAX_CAPACITY        OUT NOCOPY number
                                ,x_CAPACITY_UM         OUT NOCOPY VARCHAR2) IS
     CURSOR CUR_GET_RSRC_OVERRIDES IS
       SELECT MIN_CAPACITY
             ,MAX_CAPACITY
             ,PROCESS_UM
             ,USAGE_UOM
             ,RESOURCE_USAGE
             ,PROCESS_QTY
       FROM gmd_recipe_orgn_resources
       WHERE
             ORGANIZATION_ID = substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1,
                                     decode(instrb(P_DOCUMENT_ID,'-',1,2),0,
                                            length(substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1)),
                                            instrb(P_DOCUMENT_ID,'-',1,2)-(instrb(P_DOCUMENT_ID,'-',1,1)+1)))
         AND RECIPE_ID       = P_RECIPE_ID
         AND ROUTINGSTEP_ID  = P_ROUTINGSTEP_ID
         AND OPRN_LINE_ID    = P_OPRN_LINE_ID
         AND RESOURCES       = P_RESOURCES ;

    CURSOR CUR_GET_RSRC_ORG_DEF IS
    SELECT
           MIN_CAPACITY
          ,MAX_CAPACITY
          ,CAPACITY_UM
    FROM CR_RSRC_DTL
    WHERE  RESOURCES  = P_RESOURCES
      AND  ORGANIZATION_ID = substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1,
                                     decode(instrb(P_DOCUMENT_ID,'-',1,2),0,
                                            length(substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1)),
                                            instrb(P_DOCUMENT_ID,'-',1,2)-(instrb(P_DOCUMENT_ID,'-',1,1)+1)));

  BEGIN
    OPEN CUR_GET_RSRC_OVERRIDES;
    FETCH CUR_GET_RSRC_OVERRIDES into
                                 x_MIN_CAPACITY
                                ,x_MAX_CAPACITY
                                ,x_PROCESS_UOM
                                ,x_USAGE_UM
                                ,x_RESOURCE_USAGE
                                ,x_PROCESS_QTY;
    IF CUR_GET_RSRC_OVERRIDES%NOTFOUND THEN
       OPEN CUR_GET_RSRC_ORG_DEF;
       FETCH CUR_GET_RSRC_ORG_DEF INTO x_MIN_CAPACITY,x_MAX_CAPACITY,x_CAPACITY_UM;
       IF CUR_GET_RSRC_ORG_DEF%NOTFOUND THEN
         x_MIN_CAPACITY   := P_MIN_CAPACITY;
         x_MAX_CAPACITY   := P_MAX_CAPACITY;
         x_PROCESS_UOM    := P_PROCESS_UOM;
         x_USAGE_UM       := P_USAGE_UM;
         x_RESOURCE_USAGE := P_RESOURCE_USAGE;
         x_PROCESS_QTY    := P_PROCESS_QTY;
         x_CAPACITY_UM    := P_CAPACITY_UM;
       ELSE
         x_PROCESS_UOM    := P_PROCESS_UOM;
         x_USAGE_UM       := P_USAGE_UM;
         x_RESOURCE_USAGE := P_RESOURCE_USAGE;
       END IF;
       CLOSE CUR_GET_RSRC_ORG_DEF;
    ELSE
      x_CAPACITY_UM    := P_CAPACITY_UM;
    END IF;
    CLOSE CUR_GET_RSRC_OVERRIDES;
  END GET_RECIPE_RSRC_ORGN_OVERRIDES;

  FUNCTION GET_SAMPLING_PLAN(P_INVENTORY_ITEM_ID IN NUMBER
                               ,P_GRADE_CODE IN VARCHAR2
                               ,P_ORGANIZATION_ID IN VARCHAR2
                               ,P_BATCH_ID IN VARCHAR2
                               ,P_RECIPE_ID IN VARCHAR2
                               ,P_RECIPE_NO IN VARCHAR2
                               ,P_RECIPE_VERSION IN VARCHAR2
                               ,P_FORMULA_ID IN VARCHAR2
                               ,P_FORMULALINE_ID IN VARCHAR2
                               ,P_FORMULA_NO IN VARCHAR2
                               ,P_FORMULA_VERS IN VARCHAR2
                               ,P_ROUTING_ID IN VARCHAR2
                               ,P_ROUTING_NO IN VARCHAR2
                               ,P_ROUTING_VERS IN VARCHAR2
                               ,P_STEP_ID IN VARCHAR2
                               ,P_STEP_NO IN VARCHAR2
                               ,P_OPRN_ID IN VARCHAR2
                               ,P_OPRN_NO IN VARCHAR2
                               ,P_OPRN_VERS IN VARCHAR2
                               ,P_CHARGE IN VARCHAR2
                               ,P_DATE_EFFECTIVE IN DATE
                               ,P_EXACT_MATCH IN VARCHAR2
                               ,P_LOT_NUMBER IN VARCHAR2
                               ,P_FIND_SPEC_WITH_STEP IN VARCHAR2) RETURN NUMBER IS

   ret_value BOOLEAN;
   p_wip_spec_rec GMD_SPEC_MATCH_GRP.WIP_SPEC_REC_TYPE;
   x_return_status VARCHAR2(4000);
   x_message_data VARCHAR2(4000);
   l_spec_id     NUMBER := null;
   l_spec_vr_id  NUMBER := null;
   l_smpl_plan_id number := null;
   CURSOR get_sampling_plan_id is
    SELECT SAMPLING_PLAN_ID
    from  gmd_wip_spec_vrs
    WHERE SPEC_VR_ID = l_spec_vr_id;
   CURSOR get_item_revison IS
     SELECT REVISION
     from fm_matl_dtl
     where FORMULALINE_ID = P_FORMULALINE_ID;
BEGIN
  p_wip_spec_rec.INVENTORY_ITEM_ID    := P_INVENTORY_ITEM_ID;
  p_wip_spec_rec.GRADE_CODE           := P_GRADE_CODE;
  p_wip_spec_rec.ORGANIZATION_ID      := P_ORGANIZATION_ID;
  p_wip_spec_rec.BATCH_ID             := P_BATCH_ID;
  p_wip_spec_rec.RECIPE_ID            := P_RECIPE_ID;
  p_wip_spec_rec.RECIPE_NO            := P_RECIPE_NO;
  p_wip_spec_rec.RECIPE_VERSION       := P_RECIPE_VERSION;
  p_wip_spec_rec.FORMULA_ID           := P_FORMULA_ID;
  p_wip_spec_rec.FORMULALINE_ID       := P_FORMULALINE_ID;
  p_wip_spec_rec.FORMULA_NO           := P_FORMULA_NO;
  p_wip_spec_rec.FORMULA_VERS         := P_FORMULA_VERS;
  p_wip_spec_rec.ROUTING_ID           := P_ROUTING_ID;
  p_wip_spec_rec.ROUTING_NO           := P_ROUTING_NO;
  p_wip_spec_rec.ROUTING_VERS         := P_ROUTING_VERS;
  p_wip_spec_rec.STEP_ID              := P_STEP_ID;
  p_wip_spec_rec.STEP_NO              := P_STEP_NO;
  p_wip_spec_rec.OPRN_ID              := P_OPRN_ID;
  p_wip_spec_rec.OPRN_NO              := P_OPRN_NO;
  p_wip_spec_rec.OPRN_VERS            := P_OPRN_VERS;
  p_wip_spec_rec.CHARGE               := P_CHARGE;
  p_wip_spec_rec.DATE_EFFECTIVE       := NVL(P_DATE_EFFECTIVE,SYSDATE);
  p_wip_spec_rec.EXACT_MATCH          := P_EXACT_MATCH;
  p_wip_spec_rec.LOT_NUMBER           := P_LOT_NUMBER;
  p_wip_spec_rec.FIND_SPEC_WITH_STEP  := P_FIND_SPEC_WITH_STEP;
  open get_item_revison;
  fetch get_item_revison into p_wip_spec_rec.revision;
  close get_item_revison;
  ret_value := gmd_spec_match_grp.find_wip_spec(p_wip_spec_rec,l_spec_id,l_spec_vr_id,x_return_status,x_message_data);
  IF  RET_VALUE
  THEN
    OPEN get_sampling_plan_id;
    FETCH get_sampling_plan_id INTO l_smpl_plan_id;
    CLOSE get_sampling_plan_id;
    RETURN l_smpl_plan_id;
  ELSE
   l_spec_id := null;
   l_spec_vr_id := null;
   RETURN null;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_spec_id := null;
    l_spec_vr_id := null;
    RETURN  null;
END GET_SAMPLING_PLAN;



  PROCEDURE Get_ORGN_Process_parameters(p_RECIPE_ID number,
                                        p_ROUTINGSTEP_ID number,
                                        p_OPRN_LINE_ID number,
                                        p_resource VARCHAR2,
                                        p_DOCUMENT_id VARCHAR2,
                                        P_PARAMETER_ID Number,
                                        P_TARGET_VALUE   VARCHAR2,
                                        P_MINIMUM_VALUE  Number,
                                        P_MAXIMUM_VALUE  Number,
                                        X_TARGET_VALUE   OUT NOCOPY VARCHAR2,
                                        X_MINIMUM_VALUE  OUT NOCOPY Number,
                                        X_MAXIMUM_VALUE  OUT NOCOPY Number,
                                        X_PARAMETER_NAME OUT NOCOPY VARCHAR2) IS
   CURSOR Get_Process_param_overrides IS
    SELECT TARGET_VALUE,MINIMUM_VALUE,MAXIMUM_VALUE
    FROM   	gmd_recipe_process_parameters
    WHERE    recipe_id = p_recipe_id
      AND    organization_id = substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1,
                                     decode(instrb(P_DOCUMENT_ID,'-',1,2),0,
                                            length(substrb(P_DOCUMENT_ID,instrb(P_DOCUMENT_ID,'-',1,1)+1)),
                                            instrb(P_DOCUMENT_ID,'-',1,2)-(instrb(P_DOCUMENT_ID,'-',1,1)+1)))
      AND    routingstep_id = p_ROUTINGSTEP_ID
      AND    oprn_line_id = p_OPRN_LINE_ID
      AND    resources = p_resource
      AND    parameter_id = P_PARAMETER_ID ;

   CURSOR GET_PARAMETER_NAME IS
     SELECT PARAMETER_NAME
     FROM GMP_PROCESS_PARAMETERS
     WHERE PARAMETER_ID = P_PARAMETER_ID;
   BEGIN
     open Get_Process_param_overrides;
     FETCH Get_Process_param_overrides INTO X_TARGET_VALUE,X_MINIMUM_VALUE,X_MAXIMUM_VALUE;
     IF Get_Process_param_overrides%NOTFOUND THEN
       X_TARGET_VALUE  :=  P_TARGET_VALUE;
       X_MINIMUM_VALUE :=  P_MINIMUM_VALUE ;
       X_MAXIMUM_VALUE :=  P_MAXIMUM_VALUE ;
     END IF;
     CLOSE Get_Process_param_overrides;
     OPEN GET_PARAMETER_NAME;
     FETCH GET_PARAMETER_NAME INTO X_PARAMETER_NAME;
     CLOSE GET_PARAMETER_NAME;
   END Get_ORGN_Process_parameters;

   Function Get_Step_qty (p_RECIPE_ID       number,
                         p_ROUTINGSTEP_ID  number,
                         p_step_qty        number) return number IS
   BEGIN
     return p_step_qty;
   END;

END GMD_MBR_UTIL_PKG;

/
