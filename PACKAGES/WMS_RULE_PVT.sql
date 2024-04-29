--------------------------------------------------------
--  DDL for Package WMS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPRS.pls 120.2.12010000.4 2009/07/31 13:22:09 mitgupta ship $ */
--
-- File        : WMSVPPRS.pls
-- Content     : WMS_Rule_PVT package specification
-- Description : WMS rule private API's
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created
-- Modified    : 10/02/02 htnguyen modified
--
-- API name    : Apply
-- Type        : Private
-- Function    : Applies a wms rule to the given transaction
--               or reservation input parameters and creates recommendations
-- Pre-reqs    : Record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
--               identified by parameters p_transaction_temp_id and
--               p_type_code ( base table for the view is
--               MTL_MATERIAL_TRANSACTIONS_TEMP );
--               At least one transaction detail record in
--               WMS_TRX_DETAILS_TMP_V identified by line type code = 1
--               and parameters p_transaction_temp_id and p_type_code
--               ( base tables are MTL_MATERIAL_TRANSACTIONS_TEMP and
--               WMS_TRANSACTIONS_TEMP, respectively );
--               Rule record has to exist in WMS_RULES_B uniquely
--               identified by parameter p_rule_id;
--               If picking, quantity tree has to exist, created through
--               INV_Quantity_Tree_PVT.Create_Tree and uniquely identified
--               by parameter p_tree_id
-- Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_commit               Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   p_rule_id              Identifier of the rule to apply
--   p_type_code            Type code of the rule
--   p_partial_success_allowed_flag
--  			    'Y' or 'N'
--   p_transaction_temp_id  Identifier for the record in view
--  			    wms_strategy_mat_txn_tmp_v that represents
--  			    the request for detailing
--   p_organization_id      Organization identifier
--   p_inventory_item_id    Inventory item identifier
--   p_transaction_uom      Transaction UOM code
--   p_primary_uom          Primary UOM code
--   p_tree_id              Identifier for the quantity tree
--
-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter
--   x_finished             whether the rule has found enough quantity to
--                          find a location that completely satisfy
--                          the requested quantity (value is 'Y' or 'N')
--
-- Version
--   Currently version is 1.0
--
-- Notes       : Calls API's of WMS_Common_PVT and INV_Quantity_Tree_PVT
--               This API must be called internally by
--               WMS_Strategy_PVT.Apply only !
--

--
--  Added by htnguyen for Agilent Performance / invalid package issues
--  which was causing mobile pages to throw "fatal database error"
--  wheneve  any rule is modified, if it is in use.

--  Creating ref cursor  to call picking rules

 TYPE t_pick_rec IS RECORD (
        revision             WMS_TRANSACTIONS_TEMP.REVISION%TYPE,
        lot_number           WMS_TRANSACTIONS_TEMP.LOT_NUMBER%TYPE,
        lot_expiration_date  WMS_TRANSACTIONS_TEMP.LOT_EXPIRATION_DATE%TYPE,
        subinventory_code    WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%TYPE,
        locator_id           WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE,
        cost_group_id        WMS_TRANSACTIONS_TEMP.FROM_COST_GROUP_ID%TYPE,
        uom_code             VARCHAR2(3),
        lpn_id               WMS_TRANSACTIONS_TEMP.LPN_ID%TYPE,
        serial_number        VARCHAR2(30),
        quantity             WMS_TRANSACTIONS_TEMP.PRIMARY_QUANTITY%TYPE,
        secondary_quantity   WMS_TRANSACTIONS_TEMP.SECONDARY_QUANTITY%TYPE,
        grade_code           VARCHAR2(150),
        consist_string       VARCHAR2(1000),
        order_by_string      VARCHAR2(1000)
 );

  v_pick_rec t_pick_rec;
  TYPE Cv_pick_type IS REF CURSOR return v_pick_rec%type;


--- end of ref picking cursor ---

 TYPE t_put_rec IS RECORD (
           subinventory_code   WMS_TRANSACTIONS_TEMP.FROM_SUBINVENTORY_CODE%TYPE,
           locator_id          WMS_TRANSACTIONS_TEMP.FROM_LOCATOR_ID%TYPE,
           project_id          MTL_ITEM_LOCATIONS.PROJECT_ID%TYPE,
           task_id             MTL_ITEM_LOCATIONS.TASK_ID%TYPE
   );

  v_put_rec t_put_rec;
  TYPE Cv_put_type IS REF CURSOR return v_put_rec%type;


----

TYPE Cv_type IS REF CURSOR;

-- Global variable to hold counter values for each rule type which would be used to buffer the counter
-- for a given session

g_rule_list_pick_ctr 	NUMBER;
g_rule_list_put_ctr  	NUMBER;
g_rule_list_op_ctr   	NUMBER;
g_rule_list_task_ctr   	NUMBER;
g_rule_list_label_ctr   NUMBER;

---------------
g_serial_objects_used NUMBER ;
--[ added as a part of lot indiv support ]
g_max_tolerance        NUMBER;
g_min_tolerance        NUMBER;
g_min_qty_to_allocate NUMBER;
g_over_allocation	VARCHAR2(1);

PROCEDURE apply
  (p_api_version                  IN   NUMBER                              ,
   p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status                OUT  NOCOPY VARCHAR2                            ,
   x_msg_count                    OUT  NOCOPY NUMBER 	                           ,
   x_msg_data                     OUT  NOCOPY VARCHAR2                            ,
   p_rule_id                      IN   NUMBER   DEFAULT NULL ,
   p_type_code                    IN   NUMBER   DEFAULT NULL ,
   p_partial_success_allowed_flag IN   VARCHAR2 DEFAULT NULL,
   p_transaction_temp_id          IN   NUMBER   DEFAULT NULL ,
   p_organization_id              IN   NUMBER   DEFAULT NULL ,
   p_inventory_item_id            IN   NUMBER   DEFAULT NULL ,
   p_transaction_uom              IN   VARCHAR2 DEFAULT NULL,
   p_primary_uom                  IN   VARCHAR2 DEFAULT NULL,
   p_secondary_uom                IN   VARCHAR2 DEFAULT NULL,                -- new
   p_grade_code                   IN   VARCHAR2 DEFAULT NULL,                -- new
   p_transaction_type_id          IN   NUMBER   DEFAULT NULL ,
   p_tree_id                      IN   NUMBER   DEFAULT NULL ,
   x_finished                     OUT  NOCOPY VARCHAR2 			   ,
   p_detail_serial                IN   BOOLEAN  DEFAULT FALSE 		   ,
   p_from_serial                  IN   VARCHAR2 DEFAULT NULL 		   ,
   p_to_serial                    IN   VARCHAR2 DEFAULT NULL 		   ,
   p_detail_any_serial            IN   NUMBER   DEFAULT NULL,
   p_unit_volume                  IN   NUMBER   DEFAULT NULL,
   p_volume_uom_code              IN   VARCHAR2 DEFAULT NULL,
   p_unit_weight                  IN   NUMBER   DEFAULT NULL,
   p_weight_uom_code              IN   VARCHAR2 DEFAULT NULL,
   p_base_uom_code                IN   VARCHAR2 DEFAULT NULL,
   p_lpn_id                       IN   NUMBER   DEFAULT NULL,
   p_unit_number                  IN   VARCHAR2   DEFAULT NULL,
   p_simulation_mode              IN   NUMBER   DEFAULT -1,
   p_project_id                   IN   NUMBER   DEFAULT NULL,
   p_task_id                      IN   NUMBER   DEFAULT NULL,
   p_wave_simulation_mode         IN   VARCHAR2 DEFAULT 'N'
  );


-- high volume project
PROCEDURE execute_task_rule(p_rule_id IN NUMBER, p_task_id IN NUMBER, x_return_status OUT NOCOPY NUMBER);
--Added for bug3237702
-- API name    : ApplyDefLoc
-- Type        : Private
-- Function    : Verifies a Putaway location with the given transaction
--               input parameters and creates recommendations
--               This API does not utlize the rules and should only be
--               called when the Inventory Locator is specified on
--               the input transaction and there is no requirement
--               to check capacity.
-- Pre-reqs    :
--
-- Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_commit               Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   p_transaction_temp_id  Identifier for the record in view
--                          wms_strategy_mat_txn_tmp_v that represents
--                          the request for detailing
--   p_organization_id      Organization identifier
--   p_inventory_item_id    Inventory item identifier
--   p_transaction_uom      Transaction UOM code
--   p_primary_uom          Primary UOM code
--   p_project_id           Project associated with transaction
--   p_task_id              Task associated with transaction
--
-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter
--   x_finished             whether the rule has found enough quantity to
--                          find a location that completely satisfy
--                          the requested quantity (value is 'Y' or 'N')
--
-- Version
--   Currently version is 1.0
--
-- Notes       : Calls API's of WMS_Common_PVT
--               This API must be called internally by
--               WMS_Engine_PVT.Create_Suggestions only !
--APPLYDEFLOC

PROCEDURE applydefloc(
   p_api_version                  IN   NUMBER   ,
   p_init_msg_list                IN   VARCHAR2 ,
   p_commit                       IN   VARCHAR2 ,
   p_validation_level             IN   NUMBER   ,
   x_return_status                OUT  NOCOPY VARCHAR2 ,
   x_msg_count                    OUT  NOCOPY NUMBER   ,
   x_msg_data                     OUT  NOCOPY VARCHAR2 ,
   p_transaction_temp_id          IN   NUMBER   ,
   p_organization_id              IN   NUMBER   ,
   p_inventory_item_id            IN   NUMBER   ,
   p_subinventory_code            IN   VARCHAR2 ,
   p_locator_id                   IN   NUMBER   ,
   p_transaction_uom              IN   VARCHAR2 ,
   p_primary_uom                  IN   VARCHAR2 ,
   p_transaction_type_id          IN   NUMBER   ,
   x_finished                     OUT  NOCOPY VARCHAR2 ,
   p_lpn_id                       IN   NUMBER   ,
   p_simulation_mode              IN   NUMBER   ,
   p_project_id                   IN   NUMBER   ,
   p_task_id                      IN   NUMBER
  );
--bug3237702 ends
--
--
-- API name    : CheckSyntax
-- Type        : Private
-- Function    : Checks a wms rule for syntax errors
--               ( called by 'WMS Rules' definition form
--                 during enabling functionality )
-- Pre-reqs    : one record in WMS_RULES_B uniquely identified by parameter
--                p_rule_id
-- Input Parameters  :
--   p_api_version       Standard Input Parameter
--   p_init_msg_list     Standard Input Parameter
--   p_validation_level  Standard Input Parameter
--   p_rule_id           Identifier of the rule to check
--
-- Output Parameters  :
--   x_return_status     Standard Output Parameter
--   x_msg_count         Standard Output Parameter
--   x_msg_data          Standard Output Parameter
--
-- Version     :
--   Current version 1.0
--
-- Notes       : calls API's of WMS_RE_Common_PVT
--
PROCEDURE CheckSyntax
  (p_api_version      IN   NUMBER                                 ,
   p_init_msg_list    IN   VARCHAR2 DEFAULT fnd_api.g_false	  ,
   p_validation_level IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status    OUT  NOCOPY VARCHAR2 				  ,
   x_msg_count        OUT  NOCOPY NUMBER 				  ,
   x_msg_data         OUT  NOCOPY VARCHAR2 				  ,
   p_rule_id          IN   NUMBER   DEFAULT NULL
   );
--
TYPE rule_rec IS RECORD
  (rule_id         wms_rules_vl.rule_id%TYPE DEFAULT NULL          ,
   organization_id wms_rules_vl.organization_id%TYPE DEFAULT NULL	 ,
   type_code       wms_rules_vl.type_code%TYPE DEFAULT NULL	 ,
   name            wms_rules_vl.name%TYPE DEFAULT NULL		 ,
   description     wms_rules_vl.description%TYPE DEFAULT NULL	 ,
   qty_function_parameter_id
                   wms_rules_vl.qty_function_parameter_id%TYPE DEFAULT NULL,
   enabled_flag    wms_rules_vl.enabled_flag%TYPE DEFAULT NULL    ,
   user_defined_flag
                   wms_rules_vl.user_defined_flag%TYPE DEFAULT NULL ,
   attribute_category
                   wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute1      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute2      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute3      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute4      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute5      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute6      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute7      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute8      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute9      wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute10     wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute11     wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute12     wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute13     wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute14     wms_rules_vl.attribute_category%TYPE DEFAULT NULL,
   attribute15     wms_rules_vl.attribute_category%TYPE DEFAULT NULL
  );
--
-- API name    : Find_Rule
-- Type        : Private
-- Function    : find a rule by id
-- Input Parameters  :
--   p_api_version     Standard Input Parameter
--   p_init_msg_list   Standard Input Parameter
--   p_rule_id         Identifier of the rule
--
-- Output Parameters:
--   x_return_status   Standard Output Parameter
--   x_msg_count       Standard Output Parameter
--   x_msg_data        Standard Output Parameter
--   x_found           true if found ; else false
--   x_rule_rec        info of the rule if found

-- Version     :
--   Current version 1.0
--
-- Notes       : calls API's of WMS_RE_Common_PVT
--
PROCEDURE find_rule
  ( p_api_version      IN  NUMBER
   ,p_init_msg_list    IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,x_return_status    OUT NOCOPY VARCHAR2
   ,x_msg_count        OUT NOCOPY NUMBER
   ,x_msg_data         OUT NOCOPY VARCHAR2
   ,p_rule_id          IN  NUMBER
   ,x_found            OUT NOCOPY BOOLEAN
   ,x_rule_rec         OUT NOCOPY rule_rec
   );

PROCEDURE GetPackageName
  (p_rule_id	IN	NUMBER,
   x_package_name OUT NOCOPY VARCHAR2
  );

-- ### Added by Johnson Abraham.
-- ### Until patchset 'I', this used to be a private API.
-- ### Added signature to the Spec to make it a Public API since it is
-- ### also called from the wms_rule_pvt_ext_psetj(WMSOPPAB.pls) in patchset
-- ### 'J'.
Procedure execute_op_rule(
   p_rule_id in number
,  p_task_id in number
,  x_return_status out NOCOPY number
);


PROCEDURE GenerateRulePackage
  (p_api_version      IN   NUMBER                                 ,
   p_init_msg_list    IN   VARCHAR2 DEFAULT fnd_api.g_false	  ,
   p_validation_level IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status    OUT  NOCOPY VARCHAR2 				  ,
   x_msg_count        OUT  NOCOPY NUMBER 				  ,
   x_msg_data         OUT  NOCOPY VARCHAR2 				  ,
   p_rule_id          IN   NUMBER   DEFAULT NULL
   );

--
-- API name    : AssignTTs
-- Type        : Private
-- Function    : Assign task type to records in MMTT
-- Input Parameters  :
--
-- Output Parameters:
-- Version     :
--   Current version 1.0
--
-- Notes       : calls AssignTT(p_task_id NUMBER)
--               for a given MO header
--

PROCEDURE assignTTs
  (p_api_version                  IN   NUMBER                              ,
   p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER 	                           ,
   x_msg_data                     OUT  NOCOPY VARCHAR2                    	   ,
   p_move_order_header_id         IN   NUMBER);


--
-- API name    : AssignTT
-- Type        : Private
-- Function    : Assign task type to a specific record in MMTT
-- Input Parameters  :
--           p_task_id NUMBER
--
-- Output Parameters:
-- Version     :
--   Current version 1.0
--
-- Notes       :
--

PROCEDURE AssignTT(
   p_api_version                  IN   NUMBER                              ,
   p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER 	                           ,
   x_msg_data                     OUT  NOCOPY VARCHAR2                    	   ,
   p_task_id                      IN   NUMBER DEFAULT NULL  );



--
-- API name    : CalcRuleWeight
-- Type        : Private
-- Function    : Calculate initial rule weight based on number of distinct restriction
--               parameters. This is currently the requirement for task type assignment
--
-- Input Parameters  :
--           p_task_id NUMBER
--
-- Output Parameters:
-- Version     :
--   Current version 1.0
--
-- Notes       :
--

PROCEDURE CalcRuleWeight (p_rule_id NUMBER);

--Name: GetConversionRate
--Function: Returns conversion rate between uom and base uom for
--	    given inventory_item_id, or returns default conversion rate
--	    for given UOM.
--

FUNCTION GetConversionRate (p_uom_code VARCHAR2,
			    p_organization_id NUMBER,
			    p_inventory_item_id NUMBER DEFAULT 0)
	RETURN NUMBER;


--===========================================================================================
--
-- API name    : ApplyLabel
-- Type        : Private
-- Function    : Retrieve Label based on Label request
-- Input Parameters  :
--           p_label_request_id  NUMBER
--           p_document_id       NUMBER
--
-- Output Parameters: x_label_format_id
-- Version     :
-- Current version 1.0
--
-- Notes       :
--
-- This procedure retrieves a specific label for a label request in
-- wms_label_requests.
-- This procedure calls the rule package created for Label rules to check
-- which label rule actually matches the label request in question.
--===========================================================================================


PROCEDURE ApplyLabel(
   p_api_version                  IN   NUMBER,
   p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   p_label_request_id             IN   NUMBER,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER,
   x_msg_data                     OUT  NOCOPY VARCHAR2,
   x_label_format_id              OUT   NOCOPY NUMBER,
   x_label_format_name            OUT  NOCOPY VARCHAR2);



/********************************************************************
*  THis api does the mapping between move order type and WMS system task type
*  Input :  p_move_order_type NUMBER
*  Out :  x_wms_sys_task_type NUMBER
*****************************************************************/


PROCEDURE get_WMS_sys_task_type
  (p_move_order_type            IN NUMBER,
   p_transaction_Action_id      IN NUMBER DEFAULT NULL,
   p_transaction_source_type_id IN NUMBER DEFAULT NULL,
   x_wms_sys_task_type          OUT NOCOPY NUMBER);


--compile_all_rule_packages
--Concurrent program for compiling all rules
PROCEDURE compile_all_rule_packages
(  ERRBUF             OUT NOCOPY VARCHAR2
 , RETCODE            OUT NOCOPY NUMBER);


FUNCTION IsRuleDebugOn
    (p_simulation_mode  IN NUMBER)
RETURN BOOLEAN;

--
-- Name        : Rollback_Capacity_Update
-- Function    : Used in Apply for Put Away rules.
--               In Apply, the update_loc_suggested_capacity procedure gets
--               called to update the capacity for a locator.  This
--               procedure is an autonomous transaction, so it issues
--               a commit.  If some sort of error occurs in Apply, we need to
--               undo those changes.  We call revert_loc_suggested_capacity
--               to decrement the suggested capacity field.  The procedure
--               is also a autonomous transaction.  This procedure is
--		 also called from WMS_ENGINE_PVT.
-- Pre-reqs    : cursor has to be parsed and executed already.
-- Notes       : private procedure for internal use only
--
PROCEDURE rollback_capacity_update (
         x_return_status OUT NOCOPY VARCHAR2
        ,x_msg_count     OUT NOCOPY NUMBER
        ,x_msg_data      OUT NOCOPY VARCHAR2
        ,p_organization_id IN NUMBER
        ,p_inventory_item_id IN NUMBER);

 --
 -- API name    : Assign_operation_plans
 -- Type        : Private
 -- Function    : Assign operation_plans to records in MMTT
 -- Input Parameters  :
 --
 -- Output Parameters:
 -- Version     :
 --   Current version 1.0
 --
 -- Notes       : calls AssignTT(p_task_id NUMBER)
 --               for a given MO header
 --

 PROCEDURE assign_operation_plans
   (p_api_version                  IN   NUMBER                              ,
    p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
    p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
    p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
    x_return_status                OUT  NOCOPY VARCHAR2,
    x_msg_count                    OUT  NOCOPY NUMBER 	                           ,
    x_msg_data                     OUT  NOCOPY VARCHAR2                    	   ,
    p_move_order_header_id         IN   NUMBER);


 --
 -- API name    : Assign_operation_plan
 -- Type        : Private
 -- Function    : Assign operation_plan to a specific record in MMTT
 -- Input Parameters  :
 --           p_task_id NUMBER
 --
 -- Output Parameters:
 -- Version     :
 --   Current version 1.0
 --
 -- Notes       :
 --

 PROCEDURE Assign_operation_plan(
    p_api_version                  IN   NUMBER                              ,
    p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
    p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
    p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
    x_return_status                OUT  NOCOPY VARCHAR2,
    x_msg_count                    OUT  NOCOPY NUMBER 	                           ,
    x_msg_data                     OUT  NOCOPY VARCHAR2                    	   ,
    p_task_id                      IN   NUMBER);


 --
 --

  -- J Project
  -- API name    : QuickPick
  -- Type        : Private
  -- Function    : Validates Quantity on Hand and Material Status for the picking Locations
  --               Called for Inventory Moves.
  -- Pre-reqs    : None
  --
  -- Input Parameters  :
  --   p_api_version       Standard Input Parameter
  --   p_init_msg_list     Standard Input Parameter
  --   p_validation_level  Standard Input Parameter
  --   p_rule_id           Identifier of the rule to check
  --
  -- Output Parameters  :
  --   x_return_status     Standard Output Parameter
  --   x_msg_count         Standard Output Parameter
  --   x_msg_data          Standard Output Parameter
  --
  -- Version     :
  --   Current version 1.0
  --
  -- Notes       : calls APPLY() API's of WMS_STRATEGY_PVT

PROCEDURE QuickPick
  (p_api_version                  IN   NUMBER                              ,
   p_init_msg_list                IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_commit                       IN   VARCHAR2 DEFAULT fnd_api.g_false	   ,
   p_validation_level             IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status                OUT  NOCOPY VARCHAR2                            ,
   x_msg_count                    OUT  NOCOPY NUMBER 	                           ,
   x_msg_data                     OUT  NOCOPY VARCHAR2                            ,
   p_type_code                    IN   NUMBER   DEFAULT NULL ,
   p_transaction_temp_id          IN   NUMBER   DEFAULT NULL ,
   p_organization_id              IN   NUMBER   DEFAULT NULL ,
   p_inventory_item_id            IN   NUMBER   DEFAULT NULL ,
   p_transaction_uom              IN   VARCHAR2 DEFAULT NULL,
   p_primary_uom                  IN   VARCHAR2 DEFAULT NULL,
   p_secondary_uom                IN   VARCHAR2 DEFAULT NULL,                  -- new
   p_grade_code                   IN   VARCHAR2 DEFAULT NULL,                  -- new
   p_transaction_type_id          IN   NUMBER   DEFAULT NULL ,
   p_tree_id                      IN   NUMBER   DEFAULT NULL ,
   x_finished                     OUT  NOCOPY VARCHAR2 			   ,
   p_detail_serial                IN   BOOLEAN  DEFAULT FALSE 		   ,
   p_from_serial                  IN   VARCHAR2 DEFAULT NULL 		   ,
   p_to_serial                    IN   VARCHAR2 DEFAULT NULL 		   ,
   p_detail_any_serial            IN   NUMBER   DEFAULT NULL,
   p_unit_volume                  IN   NUMBER   DEFAULT NULL,
   p_volume_uom_code              IN   VARCHAR2 DEFAULT NULL,
   p_unit_weight                  IN   NUMBER   DEFAULT NULL,
   p_weight_uom_code              IN   VARCHAR2 DEFAULT NULL,
   p_base_uom_code                IN   VARCHAR2 DEFAULT NULL,
   p_lpn_id                       IN   NUMBER   DEFAULT NULL,
   p_unit_number                  IN   VARCHAR2   DEFAULT NULL,
   p_simulation_mode              IN   NUMBER   DEFAULT -1,
   p_project_id                   IN   NUMBER   DEFAULT NULL,
   p_task_id                      IN   NUMBER   DEFAULT NULL
  );

  PROCEDURE get_available_inventory(
    p_api_version                  IN            NUMBER
  , p_init_msg_list                IN            VARCHAR2
  , p_commit                       IN            VARCHAR2
  , p_validation_level             IN            NUMBER
  , x_return_status                OUT NOCOPY    VARCHAR2
  , x_msg_count                    OUT NOCOPY    NUMBER
  , x_msg_data                     OUT NOCOPY    VARCHAR2
  , p_rule_id                      IN            NUMBER
  , p_type_code                    IN            NUMBER
  , p_partial_success_allowed_flag IN            VARCHAR2
  , p_transaction_temp_id          IN            NUMBER
  , p_organization_id              IN            NUMBER
  , p_inventory_item_id            IN            NUMBER
  , p_transaction_uom              IN            VARCHAR2
  , p_primary_uom                  IN            VARCHAR2
  , p_transaction_type_id          IN            NUMBER
  , p_tree_id                      IN            NUMBER
  , x_finished                     OUT NOCOPY    VARCHAR2
  , p_detail_serial                IN            BOOLEAN
  , p_from_serial                  IN            VARCHAR2
  , p_to_serial                    IN            VARCHAR2
  , p_detail_any_serial            IN            NUMBER
  , p_unit_volume                  IN            NUMBER
  , p_volume_uom_code              IN            VARCHAR2
  , p_unit_weight                  IN            NUMBER
  , p_weight_uom_code              IN            VARCHAR2
  , p_base_uom_code                IN            VARCHAR2
  , p_lpn_id                       IN            NUMBER
  , p_unit_number                  IN            VARCHAR2
  , p_simulation_mode              IN            NUMBER
  , p_project_id                   IN            NUMBER
  , p_task_id                      IN            NUMBER
  );



END wms_rule_pvt;

/
