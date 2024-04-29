--------------------------------------------------------
--  DDL for Package WMS_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: WMSGLOBS.pls 115.11 2004/05/10 20:20:59 piwong ship $ */

/*----------------------------------------------------------------*
 *  Global constants representing all possible LPN context values
 *----------------------------------------------------------------*/
-- Resides in Inventory
LPN_CONTEXT_INV CONSTANT NUMBER := 1;
-- Resides in WIP
LPN_CONTEXT_WIP CONSTANT NUMBER := 2;
-- Resides in Receiving
LPN_CONTEXT_RCV CONSTANT NUMBER := 3;
-- Issued out of Stores
LPN_CONTEXT_STORES CONSTANT NUMBER := 4;
-- Pre-generated
LPN_CONTEXT_PREGENERATED CONSTANT NUMBER := 5;
-- Resides in intransit
LPN_CONTEXT_INTRANSIT CONSTANT NUMBER := 6;
-- Resides at vendor site
LPN_CONTEXT_VENDOR  CONSTANT NUMBER := 7;
-- Packing context, used as a temporary context value
-- when the user wants to reassociate the LPN with a
-- different license plate number and/or container item ID
LPN_CONTEXT_PACKING CONSTANT NUMBER := 8;
-- Loaded for shipment
LPN_LOADED_FOR_SHIPMENT CONSTANT NUMBER := 9;
-- Prepack of WIP
LPN_PREPACK_FOR_WIP CONSTANT NUMBER := 10;
-- LPN Picked
LPN_CONTEXT_PICKED CONSTANT NUMBER := 11;

-- WMS TASK TYPES
--Picking
g_wms_task_type_pick CONSTANT NUMBER := 1;

--Putaway
g_wms_task_type_putaway CONSTANT NUMBER := 2;

--Cycle Count
g_wms_task_type_cycle_count CONSTANT NUMBER := 3;

--Replenishment
g_wms_task_type_replenish CONSTANT NUMBER := 4;

--Move Order Transfer
g_wms_task_type_moxfer CONSTANT NUMBER := 5;

--Move Order Issue
g_wms_task_type_moissue CONSTANT NUMBER := 6;

--Staging Move
g_wms_task_type_stg_move CONSTANT NUMBER := 7;

--Inspect
g_wms_task_type_inspect CONSTANT NUMBER:=8;
--WMS_TASK_TYPES

g_lpn_controlled_sub     CONSTANT NUMBER := 1;
g_non_lpn_controlled_sub CONSTANT NUMBER := 2;


-- WMS_OPERATION_TYPE

G_OP_TYPE_LOAD CONSTANT NUMBER := 1;
G_OP_TYPE_DROP CONSTANT NUMBER:=2;
G_OP_TYPE_SORT CONSTANT NUMBER:=3;
G_OP_TYPE_CONSOLIDATE CONSTANT NUMBER:=4;
G_OP_TYPE_PACK CONSTANT NUMBER:=5;
G_OP_TYPE_LOAD_SHIP CONSTANT NUMBER:=6;
G_OP_TYPE_SHIP CONSTANT NUMBER:= 7;
G_OP_TYPE_CYCLE_COUNT CONSTANT NUMBER := 8;
G_OP_TYPE_INSPECT CONSTANT NUMBER := 9;
G_OP_TYPE_CROSSDOCK CONSTANT NUMBER:=10;

-- WMS_OPERATION_TYPE


-- WMS_OP_DEST_SELECTION_MODE

G_OP_DEST_PRE_SPECIFIED CONSTANT NUMBER :=1;
G_OP_DEST_API CONSTANT NUMBER := 2;   -- seed API
G_OP_DEST_CUSTOM_API CONSTANT NUMBER := 3;  -- custom API
G_OP_DEST_SYS_SUGGESTED NUMBER :=4;
G_OP_DEST_RULES_ENGINE NUMBER :=5;  -- not currently used, not referred in WMSOPPBB.pls

-- WMS_OP_DEST_SELECTION_MODE



-- WMS_OP_PLAN_INSTANCE_STATUS

G_OP_INS_STAT_PENDING CONSTANT NUMBER :=1;
G_OP_INS_STAT_ACTIVE CONSTANT NUMBER := 2;
G_OP_INS_STAT_COMPLETED CONSTANT NUMBER := 3;
G_OP_INS_STAT_CANCELLED CONSTANT NUMBER := 4;
G_OP_INS_STAT_ABORTED CONSTANT NUMBER:=5;
G_OP_INS_STAT_IN_PROGRESS CONSTANT NUMBER:=6;
G_OP_INS_STAT_ON_HOLD CONSTANT NUMBER:=7;


-- WMS_DROP_LPN_OPTION
G_OP_DROP_LPN_NO_LPN CONSTANT NUMBER :=1;
G_OP_DROP_LPN_OPTIONAL CONSTANT NUMBER := 2;
G_OP_DROP_LPN_MANDATORY CONSTANT NUMBER :=3;

/*Patchset J Enhancements: Added more ATF specific constants*/
--WMS_ACTIVITY_TYPES
G_OP_ACTIVITY_INBOUND CONSTANT NUMBER:=1;
G_OP_ACTIVITY_OUTBOUND CONSTANT NUMBER:=2;
G_OP_ACTIVITY_WAREHOUSING CONSTANT NUMBER:=3;

--WMS_OP_INBOUND_TYPES
G_OP_INBOUND_STANDARD CONSTANT NUMBER:=1;
G_OP_INBOUND_INSPECTION CONSTANT NUMBER:=2;
G_OP_INBOUND_CROSS_DOCK CONSTANT NUMBER:=3;

--WMS_OP_OUTBOUND_TYPES
G_OP_OUTBOUND_STANDARD CONSTANT NUMBER:=1;

/*----------------------------------------------------------------*
 *  Global constants representing all possible picking methodologies
 *----------------------------------------------------------------*/
-- order picking
PICK_METHOD_ORDER  CONSTANT NUMBER := 1;
-- Zone picking
PICK_METHOD_ZONE  CONSTANT NUMBER := 2;
-- wave picking
PICK_METHOD_WAVE  CONSTANT NUMBER := 3;
-- bulk picking
PICK_METHOD_BULK  CONSTANT NUMBER := 4;
-- user defined picking
PICK_METHOD_USER_DEFINED  CONSTANT NUMBER := 99;
/*----------------------------------------------------------------*
 *  Global constants representing all possible bulk picking options
 *----------------------------------------------------------------*/
-- Bulk entire wave
BULK_PICK_ENTIRE_WAVE  CONSTANT NUMBER := 1;
-- bulk picking honors the sub/item flag
BULK_PICK_SUB_ITEM  CONSTANT NUMBER := 2;
-- bulk disabled
BULK_PICK_DISABLED  CONSTANT NUMBER := 3;

--Keep track of which ship confirm method (Direct Ship, LPN Ship, or Desktop)
--So far, only value will be 'DIRECT', which indicates direct ship
g_ship_confirm_method VARCHAR2(10) := NULL;

END wms_globals;

 

/
