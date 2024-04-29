--------------------------------------------------------
--  DDL for Package WMS_OP_DEST_SYS_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OP_DEST_SYS_APIS" AUTHID CURRENT_USER AS
/* $Header: WMSOPDSS.pls 120.3 2005/11/23 02:03:48 gayu noship $*/


--
-- File        : WMSOPDSS.pls
-- Content     : WMS_OP_DEST_SYS_APIS package specification
-- Description : System seeded operation plan destination selection APIs.
-- Notes       :
-- Modified    : 10/01/2002 lezhang created



-- API name    : Get_Loc_For_Delivery
-- Type        : Public
-- Function    :
-- Pre-reqs    :
--
--
-- Parameters  :
--   Output:
--
--   X_Return_status  : API exeution status, differen meaning in different
--                      call mode
--              For locator selection:
--                     'S' : Locator successfully returned.
--                     'E' : Locator is not returned because of application
--                           error.
--                     'U' : Locator is not returned because of unexpected
--                           error.
--
--              For locator validation:
--                     'S' : Locator is valid according to API logic.
--                     'W' : Locator is not valid, and user will be prompt for a warning
--                     'E' : Locator is not valid, and user should not be allowed to continue.
--                     'U' : API execution encountered unexpected error.
--
--
--   X_Message        : Message corresponding to different statuses
--                      and different call mode
--              For locator selection:
--                     'S' : Message that needs to displayed before
--                           displaying the suggested locator.
--                     'E' : Reason why locator is not returned.
--                     'U' : Message for the unexpected error.
--
--              For locator validation:
--                     'S' : No message.
--                     'W' : Reason why locator is invalid.
--                     'E' : Reason why locator is invalid.
--                     'U' : Message for the unexpected error.
--
--
--   X_locator_ID     : Locator returned according to API loc,
--                      only apply to P_Call_Mode of locator selection.
--
--   X_Zone_ID        : Zone returned according to API loc,
--                      only apply to P_Call_Mode of locator selection.
--
--   X_Subinventory_Code : Subinventory code returned according to API loc
--                      only apply to P_Call_Mode of locator selection.
--
--
--   Input:
--
--   P_Call_Mode   : 1. Locator selection 2. Locator validation
--
--   P_Task_Type   : Refer to lookup type WMS_TASK_TYPES
--
--   P_Task_ID     : Primary key for the corresponding task type.
--                   e.g. transaction_temp_id in MMTT for picking task type.
--
--   P_Locator_Id  : The locator needs to be validated according to API logic,
--                   only apply to P_Call_Mode of locator validation,
--
--
-- Version
--   Currently version is 1.0
--

PROCEDURE Get_CONS_Loc_For_Delivery
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   X_locator_ID             OUT nocopy NUMBER,
   X_Zone_ID                OUT nocopy NUMBER,
   X_Subinventory_Code      OUT nocopy  VARCHAR2,
   P_Call_Mode              IN  NUMBER DEFAULT NULL,
   P_Task_Type              IN  NUMBER DEFAULT NULL,
   P_Task_ID                IN  NUMBER DEFAULT NULL,
   P_Locator_Id             IN  NUMBER DEFAULT NULL
   );

PROCEDURE Get_Staging_Loc_For_Delivery
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   X_locator_ID             OUT nocopy NUMBER,
   X_Zone_ID                OUT nocopy NUMBER,
   X_Subinventory_Code      OUT nocopy VARCHAR2,
   P_Call_Mode              IN  NUMBER DEFAULT NULL,
   P_Task_Type              IN  NUMBER DEFAULT NULL,
   P_Task_ID                IN  NUMBER DEFAULT NULL,
   P_Locator_Id             IN  NUMBER DEFAULT NULL,
   p_mol_id                 IN  NUMBER DEFAULT NULL
   );

/***************************************************************
This procedure returns a PJM logical locator for a physical locator
  1. If this locator is the logical locator, do nothing.
  2. If there is a logical locator for the given project/task, return that.
  3. Otherwise, create/return a logical locator.
  ***********************************************/

PROCEDURE create_pjm_locator(x_locator_id IN OUT nocopy NUMBER,
			     p_project_id IN NUMBER,
			     p_task_id IN NUMBER);


PROCEDURE Get_LPN_For_Delivery
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   X_LPN_ID                 OUT nocopy NUMBER,
   P_Task_Type              IN  NUMBER DEFAULT NULL,
   P_Task_ID                IN  NUMBER DEFAULT NULL,
   p_sug_sub                IN  VARCHAR2 DEFAULT NULL,
   p_sug_loc                IN  NUMBER DEFAULT NULL
   );


END wms_op_dest_sys_apis;


 

/
