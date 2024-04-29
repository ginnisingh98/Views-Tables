--------------------------------------------------------
--  DDL for Package GMD_MBR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_MBR_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDMBRUS.pls 120.2 2005/08/21 20:04 srpuri noship $ */
/***********************************************************************************
** If you are planning to use routine form this package in other places
**  then make sure it satisfies your requirement. If you are changing any parameters
**  data types make sure gmo MBR map in sync with this package code.
************************************************************************************/

/**********************************************************************************
**  This Procedure is to retrieve Organization specific Activity overrides
**  for a recipe for MBR XML Gateway Map.
** IN Parameters:
**     p_RECIPE_ID          number   -- Recipe ID
**     p_ROUTINGSTEP_ID     number
**     p_OPRN_LINE_ID       number
**     p_DOCUMENT_id        VARCHAR2 -- Document id is one of following
**                                    combination
**                                    RecipeID-OraginizationID-ValidityRuleID
**                                    RecipeID-OraginizationID
**     p_Default_factor     number  -- Acitvity Factor
** OUT Parameter
**      x_org_specific_factor OUT NUMBER -- This Org Specific Activity Factor
**                                          if no org specific Activity Factor
**                                          is defined then p_Default_factor value
**                                          will be passed as Activity Factor
***********************************************************************************/

   PROCEDURE GET_ACTIVITY_FACTOR(p_RECIPE_ID number,
                                 p_ROUTINGSTEP_ID number,
                                 p_OPRN_LINE_ID number,
                                 p_DOCUMENT_id VARCHAR2,
                                 p_Default_factor number,
                                 x_org_specific_factor OUT NOCOPY NUMBER);

/**********************************************************************************
 ** This Procedure is to retrieve Organization specific Resource Overrides for MBR
 ** XML Gateway Map. If No Org Specific Overrides are defined then this procedure
 ** returns values passed in as out values
 ** IN Parameters:
 **      P_RECIPE_ID          number
 **      P_ROUTINGSTEP_ID     number
 **      P_OPRN_LINE_ID       number
 **      P_RESOURCES          VARCHAR2
 **      P_PROCESS_UOM        VARCHAR2
 **      P_USAGE_UM           VARCHAR2
 **      P_RESOURCE_USAGE     number
 **      P_PROCESS_QTY        number
 **      P_DOCUMENT_ID        VARCHAR2-- Document id is one of following
 **                                    combination
 **                                    RecipeID-OraginizationID-ValidityRuleID
 **                                    RecipeID-OraginizationID
 **      P_MIN_CAPACITY       number
 **      P_MAX_CAPACITY       number
 ** OUT Parameters
 **      x_PROCESS_UOM    OUT VARCHAR2
 **      x_USAGE_UM       OUT VARCHAR2
 **      x_RESOURCE_USAGE OUT VARCHAR2
 **      x_PROCESS_QTY    OUT number
 **      x_MIN_CAPACITY   OUT number
 **      x_MAX_CAPACITY   OUT number)
 ***********************************************************************************/

   PROCEDURE GET_RECIPE_RSRC_ORGN_OVERRIDES(
                                 P_RECIPE_ID          number
                                ,P_ROUTINGSTEP_ID     number
                                ,P_OPRN_LINE_ID       number
                                ,P_RESOURCES          VARCHAR2
                                ,P_PROCESS_UOM        VARCHAR2
                                ,P_USAGE_UM           VARCHAR2
                                ,P_RESOURCE_USAGE     number
                                ,P_PROCESS_QTY        number
                                ,P_DOCUMENT_ID        VARCHAR2
                                ,P_MIN_CAPACITY       number
                                ,P_MAX_CAPACITY       number
                                ,P_CAPACITY_UM        VARCHAR2
                                ,x_PROCESS_UOM    OUT NOCOPY VARCHAR2
                                ,x_USAGE_UM       OUT NOCOPY VARCHAR2
                                ,x_RESOURCE_USAGE OUT NOCOPY VARCHAR2
                                ,x_PROCESS_QTY    OUT NOCOPY number
                                ,x_MIN_CAPACITY   OUT NOCOPY number
                                ,x_MAX_CAPACITY   OUT NOCOPY number
                                ,x_CAPACITY_UM    OUT NOCOPY VARCHAR2);

/**********************************************************************************
 **    This Function is a Returns Sampling Plan ID for the given input parameters
 **  IN Parameters
 **    P_INVENTORY_ITEM_ID   IN NUMBER
 **    P_GRADE_CODE          IN VARCHAR2
 **    P_ORGANIZATION_ID     IN VARCHAR2
 **    P_BATCH_ID            IN VARCHAR2
 **    P_RECIPE_ID           IN VARCHAR2
 **    P_RECIPE_NO           IN VARCHAR2
 **    P_RECIPE_VERSION      IN VARCHAR2
 **    P_FORMULA_ID          IN VARCHAR2
 **    P_FORMULALINE_ID      IN VARCHAR2
 **    P_FORMULA_NO          IN VARCHAR2
 **    P_FORMULA_VERS        IN VARCHAR2
 **    P_ROUTING_ID          IN VARCHAR2
 **    P_ROUTING_NO          IN VARCHAR2
 **    P_ROUTING_VERS        IN VARCHAR2
 **    P_STEP_ID             IN VARCHAR2
 **    P_STEP_NO             IN VARCHAR2
 **    P_OPRN_ID             IN VARCHAR2
 **    P_OPRN_NO             IN VARCHAR2
 **    P_OPRN_VERS           IN VARCHAR2
 **    P_CHARGE              IN VARCHAR2
 **    P_DATE_EFFECTIVE      IN DATE
 **    P_EXACT_MATCH         IN VARCHAR2
 **    P_LOT_NUMBER          IN VARCHAR2
 **    P_FIND_SPEC_WITH_STEP IN VARCHAR2)
 **  OUT Parameter
 **     This functional call returns sampling plan Id
 ***********************************************************************************/

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
                               ,P_FIND_SPEC_WITH_STEP IN VARCHAR2) RETURN NUMBER;

/**********************************************************************************
 ** This Procedure is to retrieve org specific Process Parameter Overrides for
 ** MBR XML Gateway Map. If No Org Specific Overrides are defined then this procedure
 ** returns values passed in as out values
 ** IN Parameters
 **      p_RECIPE_ID          number,
 **      p_ROUTINGSTEP_ID     number,
 **      p_OPRN_LINE_ID       number,
 **      p_resource           VARCHAR2,
 **      p_DOCUMENT_id        VARCHAR2 -- Document id is one of following
 **                                    combination
 **                                    RecipeID-OraginizationID-ValidityRuleID
 **                                    RecipeID-OraginizationID
 **      P_PARAMETER_ID       Number,
 **      P_TARGET_VALUE       VARCHAR2,
 **      P_MINIMUM_VALUE      Number,
 **      P_MAXIMUM_VALUE      Number,
 **
 ** OUT Parameters
 **
 **      X_TARGET_VALUE   OUT VARCHAR2,
 **      X_MINIMUM_VALUE  OUT Number,
 **      X_MAXIMUM_VALUE  OUT Number
 **
 **
 ***********************************************************************************/

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
                                        X_PARAMETER_NAME OUT NOCOPY VARCHAR2);

/**********************************************************************************
 **  This function returns calculated step qty if ASQC flag is on for the recipe.
 **  Otherwise it returns passed in step Qty
 **  IN Parameters
 **       p_RECIPE_ID       number
 **       p_ROUTINGSTEP_ID  number
 **       p_step_qty        number
 **
 **  OUT Parameters
 **    This function returns calculated step qty if ASQC is on
 **
 ***********************************************************************************/

  Function Get_Step_qty (p_RECIPE_ID       number,
                         p_ROUTINGSTEP_ID  number,
                         p_step_qty        number) return number;

END GMD_MBR_UTIL_PKG;

 

/
