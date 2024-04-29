--------------------------------------------------------
--  DDL for Package GMD_COMMON_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COMMON_VAL" AUTHID CURRENT_USER AS
/* $Header: GMDPCOMS.pls 120.7.12010000.3 2009/03/19 18:08:38 plowe ship $ */

   /* Purpose: Validation functions and procedures used by more than one                               */
   /*          part of GMD (Routings, Ops, Formula, QC, Recipes, Lab)                                  */
   /*                                                                                                  */
   /*          Some code common to more than one module can be found in GMA_VALID_GRP                  */
   /*          (ex: validate_um, validate_orgn_code, validate_type)                                    */
   /*                                                                                                  */
   /* check_from_date                                                                                  */
   /* check_date                                                                                       */
   /* check_date_range                                                                                 */
   /* get_customer_id                                                                                  */
   /* customer_exists                                                                                  */
   /* check_project                                                                                    */
   /* check_user_id                                                                                    */
   /* action_code                                                                                      */
   /*                                                                                                  */
   /* MODIFICATION HISTORY                                                                             */
   /* Person      Date       Comments                                                                  */
   /* ---------   ------     ------------------------------------------                                */
   /*             14Nov2000  Created                                                                   */
   /* Subtypes                                                                                         */

   /* ========                                                                                         */

   /* Constants                                                                                        */
   /* =========                                                                                        */
   G_PKG_NAME     CONSTANT VARCHAR2(30) := 'GMD_COMMON_VAL';
--   P_eff_max_date CONSTANT DATE
--           := TO_DATE(FND_PROFILE.VALUE('SY$EFF_MAX_DATE'), 'YYYY/MM/DD HH24:MI:SS');

--   P_eff_min_date CONSTANT DATE
--           := TO_DATE(FND_PROFILE.VALUE('SY$EFF_MIN_DATE'), 'YYYY/MM/DD HH24:MI:SS');
-- Bug #2425875 (JKB) Commented above.


   /* Error Return Code Constants:                                                                     */
   /* ===========================                                                                      */
   GMD_MAX_DATE_ERR          CONSTANT INTEGER := -6;  --Date is greater than system max date.
   GMD_MIN_DATE_ERR          CONSTANT INTEGER := -7;  --Date is less than system min date.
   GMD_TO_FROM_DATE          CONSTANT INTEGER := -8;  --From date is greater than to date.
   GMD_FROM_DATE_REQD        CONSTANT INTEGER := -35; --From date is required.
   FMVAL_CUSTID_ERR          CONSTANT INTEGER := -92205;


   /* define this record for calculating charges */
   /*Bug 2365583 Added a new member def_charge to the record type */
   /* Bug 5258672 Added Max_Capacity_In_Res_UOM */
   TYPE CHARGE_REC IS RECORD (
        RoutingStep_id  NUMBER,
        Max_Capacity    NUMBER,
        capacity_uom    cr_rsrc_mst.capacity_um%TYPE ,
        charge                  INTEGER,
        def_charge     VARCHAR2(1),
        Max_Capacity_In_Res_UOM NUMBER
   );

   TYPE PROCESS_LOSS_REC IS RECORD (
        qty             NUMBER  := 0    ,
        Recipe_id       NUMBER          ,
        Formula_id      NUMBER          ,
        Routing_id      NUMBER		,
        Item_Id		NUMBER		,
        Orgn_Code	VARCHAR2(4)	,
	inventory_item_id NUMBER,
	organization_id   NUMBER,
        Validity_Rule_Id NUMBER		,
        UOM		VARCHAR2(4)
   );

      /*  Define a table type for charges       */
   TYPE charge_tbl IS TABLE OF CHARGE_REC
        INDEX BY BINARY_INTEGER;
   TYPE fm_rout_hdr_tbl IS TABLE OF fm_rout_hdr%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE fm_rout_dtl_tbl IS TABLE OF fm_rout_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE fm_rout_dep_tbl IS TABLE OF fm_rout_dep%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE operation_tbl IS TABLE OF gmd_operations%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE oprn_actv_tbl IS TABLE OF gmd_operation_activities%ROWTYPE INDEX BY BINARY_INTEGER;
   TYPE oprn_rsrc_tbl IS TABLE OF gmd_operation_resources%ROWTYPE INDEX BY BINARY_INTEGER;
   /* Functions and Procedures                                                                         */
   /* ========================                                                                         */
   FUNCTION check_from_date(pfrom_date IN DATE,

                            pcalledby_form IN VARCHAR2) RETURN NUMBER;
   FUNCTION check_date(pdate IN DATE,
                       pcalledby_form IN VARCHAR2) RETURN NUMBER;
   FUNCTION check_date_range(pfrom_date IN DATE,
                             pto_date   IN DATE,
                             pcalledby_form IN VARCHAR2) RETURN NUMBER;
   PROCEDURE get_customer_id(pcustomer_no  IN  VARCHAR2,
                             xcust_id      OUT NOCOPY NUMBER,
			     xsite_id      OUT NOCOPY NUMBER,
			     xorg_id       OUT NOCOPY NUMBER,
                             xreturn_code  OUT NOCOPY NUMBER);

   PROCEDURE customer_exists
                 ( p_api_version      IN NUMBER,
                   p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                   p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                   p_customer_id      IN NUMBER,
		   p_site_id          IN NUMBER,
		   p_org_id           IN NUMBER,
                   p_customer_no      IN VARCHAR2,
                   x_return_status    OUT NOCOPY VARCHAR2,
                   x_msg_count        OUT NOCOPY NUMBER,
                   x_msg_data         OUT NOCOPY VARCHAR2,
                   x_return_code      OUT NOCOPY NUMBER,
                   x_customer_id      OUT NOCOPY NUMBER);


   /* check_user     */
   PROCEDURE check_user_id   (p_api_version      IN NUMBER,
                              p_init_msg_list    IN VARCHAR2,
                              p_commit           IN VARCHAR2,
                              p_validation_level IN NUMBER,
                              p_user_id          IN NUMBER,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              x_return_code      OUT NOCOPY NUMBER);


   PROCEDURE action_code
                 ( p_api_version      IN NUMBER,
                   p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                   p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_NONE,
                   p_action_code      IN VARCHAR2,
                   x_return_status    OUT NOCOPY VARCHAR2,
                   x_msg_count        OUT NOCOPY NUMBER,
                   x_msg_data         OUT NOCOPY VARCHAR2,
                   x_return_code      OUT NOCOPY NUMBER);

   /* Added a few validation and fetch procedures */
   /* Later on to be moved to its appropriate packages */
   PROCEDURE Get_Status
   (    Status_code             IN      GMD_STATUS.Status_code%TYPE     ,
        Meaning                 OUT NOCOPY     GMD_STATUS.Meaning%TYPE         ,
        Description             OUT NOCOPY     GMD_STATUS.Description%TYPE     ,
        x_return_status         OUT NOCOPY     VARCHAR2
   );

   PROCEDURE Calculate_Process_loss
   (    process_loss            IN      process_loss_rec        ,
        Entity_type             IN      VARCHAR2                        ,
        x_recipe_theo_loss      OUT NOCOPY     GMD_PROCESS_LOSS.process_loss%TYPE ,
        x_process_loss          OUT NOCOPY     GMD_PROCESS_LOSS.process_loss%TYPE ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2
   );

   PROCEDURE Calculate_Total_Qty
   (    formula_id              IN      GMD_RECIPES.Formula_id%TYPE     ,
        x_product_qty           OUT NOCOPY     NUMBER                          ,
        x_ingredient_qty        OUT NOCOPY     NUMBER                          ,
        x_uom                   IN OUT NOCOPY VARCHAR2                        ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                	,
        p_scale_factor		IN	NUMBER DEFAULT NULL		,
        p_primaries		IN	VARCHAR2 DEFAULT 'OUTPUTS'
   );

   FUNCTION Get_Routing_Scale_Factor(vRecipe_id  IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     vFormula_id IN NUMBER DEFAULT NULL,
                                     vRouting_Id IN NUMBER DEFAULT NULL
                                     ) RETURN NUMBER;

   PROCEDURE Calculate_Charges
   (    Batch_id                IN      NUMBER         ,
        Recipe_id               IN      NUMBER         ,
        Routing_id              IN      NUMBER         ,
        VR_qty                  IN      NUMBER         ,
        Tolerance               IN      NUMBER         ,
        Orgn_id                 IN      NUMBER         ,
        x_charge_tbl            OUT NOCOPY     charge_tbl     ,
        x_return_status         OUT NOCOPY     VARCHAR2
   );


  PROCEDURE Calculate_Step_Charges
  (     P_recipe_id               IN      NUMBER                      ,
        P_tolerance               IN      NUMBER                      ,
        P_orgn_id                 IN      NUMBER                      ,
        P_step_tbl		  IN	  GMD_AUTO_STEP_CALC.step_rec_tbl,
        x_charge_tbl              OUT NOCOPY     charge_tbl                  ,
        x_return_status           OUT NOCOPY     VARCHAR2
  );

   FUNCTION UPDATE_ALLOWED(Entity     VARCHAR2
                          ,Entity_id  NUMBER
                          ,Update_Column_Name VARCHAR2 Default Null)
        RETURN BOOLEAN;

   FUNCTION VERSION_CONTROL_STATE(Entity VARCHAR2, Entity_id NUMBER)
        RETURN VARCHAR2;


   PROCEDURE Run_status_update( p_errbuf             OUT NOCOPY VARCHAR2,
                                p_retcode            OUT NOCOPY VARCHAR2,
                                pCalendar_code       IN cm_cmpt_dtl.calendar_code%TYPE,
                                pPeriod_code         IN cm_cmpt_dtl.period_code%TYPE,
                                pCost_mthd_code      IN cm_cmpt_dtl.cost_mthd_code%TYPE);

-- KSHUKLA added the procedure to check the formula, item access to the
-- Recipe override org , process loss, and validity rules organizations

  PROCEDURE CHECK_FORMULA_ITEM_ACCESS(pFormula_id IN NUMBER,
                                    pInventory_Item_ID IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
				                            pRevision IN VARCHAR2 DEFAULT NULL);

  -- Kapil ME Auto-Prod  Bug# 5716318
  -- Added the Procedure.
  PROCEDURE Calculate_Total_Product_Qty ( p_formula_id   IN  gmd_recipes.formula_id%TYPE,
                                          x_return_status    OUT NOCOPY VARCHAR2,
                                          x_msg_count        OUT NOCOPY      NUMBER,
                                          x_msg_data         OUT NOCOPY      VARCHAR2);

   /*Added the following procedure in Bug No.7027512 */
  PROCEDURE  Run_status_update(  p_errbuf             OUT NOCOPY VARCHAR2,
                                 p_retcode            OUT NOCOPY VARCHAR2,
                                 pLegal_entity_id   IN number,
                                 pCalendar_code       IN cm_cmpt_dtl.calendar_code%TYPE,
                                 pPeriod_code         IN cm_cmpt_dtl.period_code%TYPE,
                                 pCost_type_id      IN cm_cmpt_dtl.Cost_type_id%TYPE);

END; /* Package Specification GMD_COMMON_VAL*/

/
