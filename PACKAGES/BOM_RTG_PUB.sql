--------------------------------------------------------
--  DDL for Package BOM_RTG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMBRTGS.pls 120.5.12010000.11 2015/06/09 10:19:22 nlingamp ship $ */
/*#
 * APIs in this package are used to create, update or delete single or multiple
 * Routings and any of its child entities. In addition, a number of utility
 * procedures that convert Routing child entities to and from Bill of Materials
 * child entities are provided. <BR> A Routing is composed of its header and
 * optionally, a number of related child entities: routing revisions, operations, operation
 * resources, substitute operation resources and operation networks. <BR>
 * First, user creates the routing header for an Item. After creating
 * the Header, user adds or updates or deletes operations and their child entities such as
 * operation resources, substitute operation resources etc.
 * This API can be used for processing a single or multiple business entities(Routing and its child entities)
 * per call. The entities that needs to be processed should belong to the same Routing. How to use this is
 * explained below through examples.<BR>
 * Example 1 : To Create a new Routing entity.(Routing Header, Operation, Operation Resource etc).
 *<li>1.The user should Initialize the Error_Handler so that errors can be logged and retrieved.</li>
 *<li>2.The user populates the Record Type for each entity like Routing Header that needs to be processed.</li>
 *<li>3.The record should be created with attribute values as explained in the record type description below.</li>
 *<li>For example populate the Routing Header record by giving values as follows Routing_Header.transaction_type = 'CREATE'</li>
 *<li>4.Then Process_Rtg procedure in this package is called with already created record types as paramters.</li>
 *<li>This procedure processes the records and registers errors in the pl/sql error table, which can be
 * extracted using Error_Hanlder.get_message procedure.</li>
 *<li>5.If the Return Status is S then the process has completed sucessfully else error is logged by the Error_Handler.</li>
 *<li>6.Upon Successful completion the user should commit the data.</li>
 *
 * Example-2 To Update the value of an attribute.
 *<li>1.If the user wants to update the user unique index attributes like Operation Sequence Number for Operation Record Type,
 * he should give the existing value to pick up the corrrect record and new value to change.</li>
 *<li>rtg_operation.Operation_Sequence_Number = 10</li>
 *<li>rtg_operation.New_Operation_Sequence_Number = 20</li>
 *<li>2.If the user wants to update non-user unique indexes then only the new value is required.</li>
 *<li>rtg_operation.Operation_Description = 'New Description'</li><BR>
 *
 * ----------------------
 *  Routing Header Record
 * ----------------------
 *<code><pre>
 * TYPE Rtg_Header_Rec_Type IS RECORD
 * (
 *   Assembly_Item_Name         VARCHAR2(240)
 * , Organization_Code          VARCHAR2(3)
 * , Alternate_Routing_Code     VARCHAR2(10)
 * , Eng_Routing_Flag           NUMBER
 * , Common_Assembly_Item_Name  VARCHAR2(240)
 * , Routing_Comment            VARCHAR2(240)
 * , Completion_Subinventory    VARCHAR2(10)
 * , Completion_Location_Name   VARCHAR2(81)
 * , Line_Code                  VARCHAR2(10)
 * , CFM_Routing_Flag           NUMBER
 * , Mixed_Model_Map_Flag       NUMBER
 * , Priority                   NUMBER
 * , Total_Cycle_Time           NUMBER
 * , CTP_Flag                   NUMBER
 * , Attribute_category         VARCHAR2(30)
 * , Attribute1                 VARCHAR2(150)
 * , Attribute2                 VARCHAR2(150)
 * , Attribute3                 VARCHAR2(150)
 * , Attribute4                 VARCHAR2(150)
 * , Attribute5                 VARCHAR2(150)
 * , Attribute6                 VARCHAR2(150)
 * , Attribute7                 VARCHAR2(150)
 * , Attribute8                 VARCHAR2(150)
 * , Attribute9                 VARCHAR2(150)
 * , Attribute10                VARCHAR2(150)
 * , Attribute11                VARCHAR2(150)
 * , Attribute12                VARCHAR2(150)
 * , Attribute13                VARCHAR2(150)
 * , Attribute14                VARCHAR2(150)
 * , Attribute15                VARCHAR2(150)
 * , Original_System_Reference  VARCHAR2(50)
 * , Transaction_Type           VARCHAR2(30)
 * , Return_Status              VARCHAR2(1)
 * , Delete_Group_Name          VARCHAR2(10)
 * , DG_Description             VARCHAR2(240)
 * , Ser_Start_Op_Seq           NUMBER
 * , Row_Identifier             NUMBER
 * ) ;
 *</pre></code>
 *
 * ------------------------------
 *       Parameteres
 * ------------------------------
 *
 *<pre>
 * Assembly_item_name        -- User friendly name of the Item for which the Routing Header is created.
 * Organization_Code         -- Organization Code in which the Item is defined.
 * Alternate_Routing_Code    -- Routing name to be given. If null value is given, then the Routing is Primary.
 * Eng_Routing_Flag          -- For Manufacturing Routing, Eng_Routing_Flag=1. For Engineering Routing, Eng_Routing_Flag=2.
 * Common_Assembly_Item_Name -- Assembly Item name of common routing.
 * Routing_Comment           -- Comment describing the Routing.
 * Completion_Subinventory   -- Destination Subinventory for the Assembly.
 * Completion_Location_Name  -- Destination Location for the Assembly.
 * Line_Code                 -- User friendly name of a Line from WIP Lines used in Flow Manufacturing.
 * CFM_Routing_Flag          -- Flag indicating whether the routing is Continous flow or traditional routing.
 * Mixed_Model_Map_Flag      -- Flag indicating whether to use this routing in Mixed Model Map calculation. (1=Yes, 2=No)
 * Priority                  -- Priority
 * Total_Cycle_Time          -- Total time that an assembly takes along the primary path in the operation network, calculated by Flow Manufacturing.
 * CTP_Flag                  -- Flag indicating capacity must be checked when item is ordered. (1=Yes, 2=No)
 * Attribute_category        -- Descriptive flexfield structure defining column
 * Attribute 1 to 15         -- Descriptive flexfield segments
 * Original_System_Reference -- Original system that data for the current record has come from.
 * Transaction_Type          -- Defined below
 * Return_Status             -- The Routing Header creation status, whether successful or error
 * Delete_Group_Name         -- Delete group name for the entity type you are deleting
 * DG_Description            -- A meaningful description of the delete group
 * Ser_Start_Op_Seq          -- Serialization Starting Operation Sequence Number for standard routings
 * Row_Identifier            -- A unique identifier value for the entity record.
 *</pre>
 *
 *
 * -------------------------------
 *    Routing Revision Record
 * -------------------------------
 *
 *<code><pre>
 * TYPE Rtg_Revision_Rec_Type  IS  RECORD
 * (
 *   Assembly_Item_Name         VARCHAR2(240)
 * , Organization_Code          VARCHAR2(3)
 * , Alternate_Routing_Code     VARCHAR2(10)
 * , Revision                   VARCHAR2(3)
 * , Start_Effective_Date       DATE
 * , Attribute_category         VARCHAR2(30)
 * , Attribute1                 VARCHAR2(150)
 * , Attribute2                 VARCHAR2(150)
 * , Attribute3                 VARCHAR2(150)
 * , Attribute4                 VARCHAR2(150)
 * , Attribute5                 VARCHAR2(150)
 * , Attribute6                 VARCHAR2(150)
 * , Attribute7                 VARCHAR2(150)
 * , Attribute8                 VARCHAR2(150)
 * , Attribute9                 VARCHAR2(150)
 * , Attribute10                VARCHAR2(150)
 * , Attribute11                VARCHAR2(150)
 * , Attribute12                VARCHAR2(150)
 * , Attribute13                VARCHAR2(150)
 * , Attribute14                VARCHAR2(150)
 * , Attribute15                VARCHAR2(150)
 * , Original_System_Reference  VARCHAR2(50)
 * , Transaction_Type           VARCHAR2(30)
 * , Return_Status              VARCHAR2(1)
 * , Row_Identifier             NUMBER
 * )
 *</pre></code>
 *
 * -----------------------
 *     Parameters
 * -----------------------
 *
 *<pre>
 * Assembly_item_name           -- User friendly name of the Item for which the Routing is created.
 * Organization_Code            -- Organization Code in which the Item is defined.
 * Alternate_Routing_Code       -- Routing name, if null then Primary.
 * Revision                     -- Routing Revision internal name
 * Start_Effective_Date         -- Start Effectivity Date for the operation
 * Attribute_category           -- Descriptive flexfield structure defining column
 * Attribute 1 to 15            -- Descriptive flexfield segments
 * Original_System_Reference    -- Original system that data for the current record has come from.
 * Transaction_Type             -- Defined below
 * Return_Status                -- The Routing Header creation status, whether successful or error
 * Row_Identifier               -- A unique identifier value for the entity record.
 *</pre>
 *
 * ----------------------------------
 *   Routing Operation Record
 * ----------------------------------
 *
 *<code><pre>
 * TYPE Operation_Rec_Type   IS RECORD
 * (
 *   Assembly_Item_Name         VARCHAR2(240)
 * , Organization_Code          VARCHAR2(3)
 * , Alternate_Routing_Code     VARCHAR2(10)
 * , Operation_Sequence_Number  NUMBER
 * , Operation_Type             NUMBER
 * , Start_Effective_Date       DATE
 * , New_Operation_Sequence_Number NUMBER
 * , New_Start_Effective_Date   DATE
 * , Standard_Operation_Code    VARCHAR2(4)
 * , Department_Code            VARCHAR2(10)
 * , Op_Lead_Time_Percent       NUMBER
 * , Minimum_Transfer_Quantity  NUMBER
 * , Count_Point_Type           NUMBER
 * , Operation_Description      VARCHAR2(240)
 * , Disable_Date               DATE
 * , Backflush_Flag             NUMBER
 * , Option_Dependent_Flag      NUMBER
 * , Reference_Flag             NUMBER
 * , Process_Seq_Number         NUMBER
 * , Process_Code               VARCHAR2(4)
 * , Line_Op_Seq_Number         NUMBER
 * , Line_Op_Code               VARCHAR2(4)
 * , Yield                      NUMBER
 * , Cumulative_Yield           NUMBER
 * , Reverse_CUM_Yield          NUMBER
 * , User_Labor_Time            NUMBER
 * , User_Machine_Time          NUMBER
 * , Net_Planning_Percent       NUMBER
 * , Include_In_Rollup          NUMBER
 * , Op_Yield_Enabled_Flag      NUMBER
 * , Shutdown_Type              VARCHAR2(30)
 * , Attribute_category         VARCHAR2(30)
 * , Attribute1                 VARCHAR2(150)
 * , Attribute2                 VARCHAR2(150)
 * , Attribute3                 VARCHAR2(150)
 * , Attribute4                 VARCHAR2(150)
 * , Attribute5                 VARCHAR2(150)
 * , Attribute6                 VARCHAR2(150)
 * , Attribute7                 VARCHAR2(150)
 * , Attribute8                 VARCHAR2(150)
 * , Attribute9                 VARCHAR2(150)
 * , Attribute10                VARCHAR2(150)
 * , Attribute11                VARCHAR2(150)
 * , Attribute12                VARCHAR2(150)
 * , Attribute13                VARCHAR2(150)
 * , Attribute14                VARCHAR2(150)
 * , Attribute15                VARCHAR2(150)
 * , Original_System_Reference  VARCHAR2(50)
 * , Transaction_Type           VARCHAR2(30)
 * , Return_Status              VARCHAR2(1)
 * , Delete_Group_Name          VARCHAR2(10)
 * , DG_Description             VARCHAR2(240)
 * , Long_Description           VARCHAR2(4000)
 * , Row_Identifier             NUMBER
 * );
 *</pre></code>
 *
 * -----------------------------
 *       Parameters
 * -----------------------------
 *
 *<pre>
 * Assembly_item_name           -- User friendly name of the Item for which the Routing is created.
 * Organization_Code            -- Organization Code in which the Item is defined.
 * Alternate_Routing_Code       -- Routing name, if null then Primary.
 * Operation_Sequence_Number    -- Routing Operation Sequence Number
 * Operation_Type               -- Process, Line Operation or Event
 * Start_Effective_Date         -- Start Effectivity Date for the operation
 * New_Operation_Sequence_Number -- New Operation Sequence Number when existing Operation Sequence Number to be changed.
 * New_Start_Effective_Date     -- New Start Effectivity Date
 * Standard_Operation_Code      -- User friendly name of Standard Operation
 * Department_Code              -- User friendly name of Department where the Operation is defined.
 * Op_Lead_Time_Percent         -- Indicates the amount of overlap this operation's lead time has with the parent's lead time
 * Minimum_Transfer_Quantity    -- Minimum Operation transfer quantity
 * Count_Point_Type             -- 1=Yes - autocharge; 2=No - autocharge; 3=No - direct charge.
 * Operation_Description        -- Meaningful description for the Operation
 * Disable_Date                 -- The disable date after which the Operation will not be active
 * Backflush_Flag               -- Indicates whether the Operation requires backflushing (1=Yes, 2=No)
 * Option_Dependent_Flag        -- Indicates whether to use this Operation in all configuration routings, even if no components of the configuration are used in this Operation (1=Yes, 2=No)
 * Reference_Flag               -- If the Standard Operation is referenced or copied then the operation can not be updated. (1=Yes, 2=No)
 * Process_Seq_Number           -- Operation Sequence Number of parent process (applies only to events)
 * Process_Code                 -- Operation Sequence Code of parent process (applies only to events)
 * Line_Op_Seq_Number           -- Operation Sequence Number of the parent line operation
 * Line_Op_Code                 -- Operation Sequence Code of the parent line operation
 * Yield                        -- Process yield at this Operation
 * Cumulative_Yield             -- Cumulative process yield from begining of routing to this operation
 * Reverse_CUM_Yield            -- Cumulative process yield from end of routing to comparable operation
 * User_Labor_Time              -- User calculated run time attributable to labor
 * User_Machine_Time            -- User calculated run time attributable to machines
 * Net_Planning_Percent         -- Cumulative planning percents derived from the operation network
 * Include_In_Rollup            -- Indicates whether operation yield is to be considered in cost rollup (1=Yes, 2=No)
 * Op_Yield_Enabled_Flag        -- Indicates whether operation yield is to be considered during costing (1=Yes, 2=No)
 * Shutdown_Type                -- Shutdown type
 * Attribute_category           -- Descriptive flexfield structure defining column
 * Attribute 1 to 15            -- Descriptive flexfield segments
 * Original_System_Reference    -- Original system that data for the current record has come from.
 * Transaction_Type             -- Defined below
 * Return_Status                -- The Routing Operation creation status, whether successful or error
 * Delete_Group_Name            -- Delete group name for the entity type you are deleting
 * DG_Description               -- A meaningful description of the delete group
 * Long_Description             -- Long Description for Operation
 * Row_Identifier               -- A unique identifier value for the entity record.
 *</pre>
 *
 * ---------------------------------
 *   Operation Resource Record
 * ---------------------------------
 *
 *<code><pre>
 * TYPE Op_Resource_Rec_Type IS RECORD
 * (
 *   Assembly_Item_Name         VARCHAR2(240)
 * , Organization_Code          VARCHAR2(3)
 * , Alternate_Routing_Code     VARCHAR2(10)
 * , Operation_Sequence_Number  NUMBER
 * , Operation_Type             NUMBER
 * , Op_Start_Effective_Date    DATE
 * , Resource_Sequence_Number   NUMBER
 * , Resource_Code              VARCHAR2(10)
 * , Activity                   VARCHAR2(10)
 * , Standard_Rate_Flag         NUMBER
 * , Assigned_Units             NUMBER
 * , Usage_Rate_Or_Amount       NUMBER
 * , Usage_Rate_Or_Amount_Inverse NUMBER
 * , Basis_Type                 NUMBER
 * , Schedule_Flag              NUMBER
 * , Resource_Offset_Percent    NUMBER
 * , Autocharge_Type            NUMBER
 * , Substitute_Group_Number    NUMBER
 * , Schedule_Sequence_Number   NUMBER
 * , Principle_Flag             NUMBER
 * , Attribute_category         VARCHAR2(30)
 * , Attribute1                 VARCHAR2(150)
 * , Attribute2                 VARCHAR2(150)
 * , Attribute3                 VARCHAR2(150)
 * , Attribute4                 VARCHAR2(150)
 * , Attribute5                 VARCHAR2(150)
 * , Attribute6                 VARCHAR2(150)
 * , Attribute7                 VARCHAR2(150)
 * , Attribute8                 VARCHAR2(150)
 * , Attribute9                 VARCHAR2(150)
 * , Attribute10                VARCHAR2(150)
 * , Attribute11                VARCHAR2(150)
 * , Attribute12                VARCHAR2(150)
 * , Attribute13                VARCHAR2(150)
 * , Attribute14                VARCHAR2(150)
 * , Attribute15                VARCHAR2(150)
 * , Original_System_Reference  VARCHAR2(50)
 * , Transaction_Type           VARCHAR2(30)
 * , Return_Status              VARCHAR2(1)
 * , Setup_Type                 VARCHAR2(30)
 * , Row_Identifier             NUMBER
 * )
 *</pre></code>
 *
 * -----------------------
 *      Parameters
 * -----------------------
 *
 *<pre>
 * Assembly_item_name           -- User friendly name of the Item for which the Routing is created.
 * Organization_Code            -- Organization Code in which the Item is defined.
 * Alternate_Routing_Code       -- Routing name, if null then Primary.
 * Operation_Sequence_Number    -- Routing Operation Sequence Number
 * Operation_Type               -- Process, Line Operation or Event
 * Op_Start_Effective_Date      -- Start Effectivity Date for the operation
 * Resource_Sequence_Number     -- Resource Sequence Number to identify a resource in the Operation
 * Resource_Code                -- User friendly name of the Resource
 * Activity                     -- An activity to perform when the Resource is used.
 * Standard_Rate_Flag           -- Indicate whether to use standard rate for shopfloor transactions (1=Yes, 2=No)
 * Assigned_Units               -- Resource Units assigned to the Operation
 * Usage_Rate_Or_Amount         -- Resource usage rate
 * Usage_Rate_Or_Amount_Inverse -- Resource usage rate inverse
 * Basis_Type                   -- Basis type identifier
 * Schedule_Flag                -- Schedule the resource (1=Yes, 2=No, 3=Prior, 4=Next)
 * Resource_Offset_Percent      -- Resource offset percent from the start of the routing
 * Autocharge_Type              -- Autocharge type for shopfloor moves (1=WIP move, 2=Manual, 3=PO receipt, 4=PO move)
 * Substitute_Group_Number      -- Substitute Group Number
 * Schedule_Sequence_Number     -- Scheduling Sequence Number
 * Principle_Flag               -- Principle Flag
 * Attribute_category           -- Descriptive flexfield structure defining column
 * Attribute 1 to 15            -- Descriptive flexfield segments
 * Original_System_Reference    -- Original system that data for the current record has come from.
 * Transaction_Type             -- Defined Below
 * Return_Status                -- Process Status, whether successful or error
 * Setup_Type                   -- Setup Type
 * Row_Identifier               -- A unique identifier value for the entity record.
 *</pre>
 *
 * ------------------------------------------
 *    Substitute Operation Resource Record
 * ------------------------------------------
 *
 *<code><pre>
 * TYPE Sub_Resource_Rec_Type IS RECORD
 * (
 *   Assembly_Item_Name         VARCHAR2(240)
 * , Organization_Code          VARCHAR2(3)
 * , Alternate_Routing_Code     VARCHAR2(10)
 * , Operation_Sequence_Number  NUMBER
 * , Operation_Type             NUMBER
 * , Op_Start_Effective_Date    DATE
 * , Sub_Resource_Code          VARCHAR2(10)
 * , New_Sub_Resource_Code      VARCHAR2(10)
 * , Substitute_Group_Number    NUMBER
 * , Schedule_Sequence_Number   NUMBER
 * , Replacement_Group_Number   NUMBER
 * , New_Replacement_Group_Number NUMBER
 * , Activity                   VARCHAR2(10)
 * , Standard_Rate_Flag         NUMBER
 * , Assigned_Units             NUMBER
 * , Usage_Rate_Or_Amount       NUMBER
 * , Usage_Rate_Or_Amount_Inverse NUMBER
 * , Basis_Type                 NUMBER
 * , New_Basis_Type             NUMBER
 * , Schedule_Flag              NUMBER
 * , Resource_Offset_Percent    NUMBER
 * , Autocharge_Type            NUMBER
 * , Principle_Flag             NUMBER
 * , Attribute_category         VARCHAR2(30)
 * , Attribute1                 VARCHAR2(150)
 * , Attribute2                 VARCHAR2(150)
 * , Attribute3                 VARCHAR2(150)
 * , Attribute4                 VARCHAR2(150)
 * , Attribute5                 VARCHAR2(150)
 * , Attribute6                 VARCHAR2(150)
 * , Attribute7                 VARCHAR2(150)
 * , Attribute8                 VARCHAR2(150)
 * , Attribute9                 VARCHAR2(150)
 * , Attribute10                VARCHAR2(150)
 * , Attribute11                VARCHAR2(150)
 * , Attribute12                VARCHAR2(150)
 * , Attribute13                VARCHAR2(150)
 * , Attribute14                VARCHAR2(150)
 * , Attribute15                VARCHAR2(150)
 * , Original_System_Reference  VARCHAR2(50)
 * , Transaction_Type           VARCHAR2(30)
 * , Return_Status              VARCHAR2(1)
 * , Setup_Type                 VARCHAR2(30)
 * , Row_Identifier             NUMBER
 * )
 *</pre></code>
 *
 * -----------------------
 *     Parameters
 * -----------------------
 *
 *<pre>
 * Most of the parameters hold the same meaning as explained in Operation Resource record types. Those which are specific to
 * this record type are
 * Sub_Resource_Code            -- User friendly name of the Substitute Resource
 * New_Sub_Resource_Code        -- User friendly name of the new Substitute Resource when existing Substitute Resource needs to be changed
 * Replacement_Group_Number     -- Number to group the Substitute Resources
 * New_Replacement_Group_Number -- New Replacement Group when existing Replacement Group Number needs to be changed
 * New_Basis_Type               -- New Basis Type for updating existing Basis Type
 *</pre>
 *
 * ------------------------------------------
 *    Operation Network Record
 * ------------------------------------------
 *
 *<code><pre>
 * TYPE Op_Network_Rec_Type IS RECORD
 * (
 *   Assembly_Item_Name         VARCHAR2(240)
 * , Organization_Code          VARCHAR2(3)
 * , Alternate_Routing_Code     VARCHAR2(10)
 * , Operation_Type             NUMBER
 * , From_Op_Seq_Number         NUMBER
 * , From_X_Coordinate          NUMBER
 * , From_Y_Coordinate          NUMBER
 * , From_Start_Effective_Date  DATE
 * , To_Op_Seq_Number           NUMBER
 * , To_X_Coordinate            NUMBER
 * , To_Y_Coordinate            NUMBER
 * , To_Start_Effective_Date    DATE
 * , New_From_Op_Seq_Number     NUMBER
 * , New_From_Start_Effective_Date DATE
 * , New_To_Op_Seq_Number       NUMBER
 * , New_To_Start_Effective_Date DATE
 * , Connection_Type            NUMBER
 * , Planning_Percent           NUMBER
 * , Attribute_category         VARCHAR2(30)
 * , Attribute1                 VARCHAR2(150)
 * , Attribute2                 VARCHAR2(150)
 * , Attribute3                 VARCHAR2(150)
 * , Attribute4                 VARCHAR2(150)
 * , Attribute5                 VARCHAR2(150)
 * , Attribute6                 VARCHAR2(150)
 * , Attribute7                 VARCHAR2(150)
 * , Attribute8                 VARCHAR2(150)
 * , Attribute9                 VARCHAR2(150)
 * , Attribute10                VARCHAR2(150)
 * , Attribute11                VARCHAR2(150)
 * , Attribute12                VARCHAR2(150)
 * , Attribute13                VARCHAR2(150)
 * , Attribute14                VARCHAR2(150)
 * , Attribute15                VARCHAR2(150)
 * , Original_System_Reference  VARCHAR2(50)
 * , Transaction_Type           VARCHAR2(30)
 * , Return_Status              VARCHAR2(1)
 * , Row_Identifier             NUMBER
 *</pre></code>
 *
 * -----------------------
 *     Parameters
 * -----------------------
 *
 *<pre>
 * Assembly_item_name             -- User friendly name of the Item for which the Routing is created.
 * Organization_Code              -- Organization Code in which the Item is defined.
 * Alternate_Routing_Code         -- Routing name, if null then Primary.
 * Operation_Type                 -- Process, Line Operation or Event
 * From_Op_Seq_Number             -- From Operation Sequence Number for the Network
 * From_X_Coordinate              -- X Co-ordinate for From Operation
 * From_Y_Coordinate              -- Y Co-ordinate for From Operation
 * From_Start_Effective_Date      -- Effectivity Date for From Operation
 * To_Op_Seq_Number               -- To Operation Sequence Number for the Network
 * To_X_Coordinate                -- X Co-ordinate for To Operation
 * To_Y_Coordinate                -- Y Co-ordinate for To Operation
 * To_Start_Effective_Date        -- Effectivity Date for To Operation
 * New_From_Op_Seq_Number         -- New From Operation Sequence Number for changing existing From Operation Sequence Number
 * New_From_Start_Effective_Date  -- New From Effectivity Date for changing existing From Effectivity Date
 * New_To_Op_Seq_Number           -- New To Operation Sequence Number for changing existing To Operation Sequence Number
 * New_To_Start_Effective_Date    -- New To Effectivity Date for changing existing To Effectivity Date
 * Connection_Type                -- Connection Type
 * Planning_Percent               -- Planning Percent
 * Original_System_Reference      -- Original system that data for the current record has come from.
 * Transaction_Type               -- Defined Below
 * Return_Status                  -- Process Status, whether successful or error
 * Row_Identifier                 -- A unique identifier value for the entity record.
 *</pre>
 *
 * Every entity that needs to be processed must have 'Transaction Type'.
 * Valid Transaction Types are CREATE, UPDATE, DELETE and SYNC.
 * The SYNC Transaction Type can be used when the requirement is:
 * 1.Create an entity, if it does not exist.
 * 2.Update the entity with the given values, if it exists.
 *
 * @rep:scope public
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Create, Update or Delete Routing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */

/***************************************************************************
--
--  Copyright (c) 2000, 2015 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBRTGS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Rtg_Pub
--
--  NOTES
--
--  HISTORY
--
--   02-AUG-00  Biao Zhang         Initial Creation
--   08-AUG-00  Masanori Kimziuka  Modify and Add Conversion, Control_Rec_Type
--
***************************************************************************/

--
-- Routing Header exposed record definition
--

TYPE Rtg_Header_Rec_Type IS RECORD
   (
     Assembly_Item_Name         VARCHAR2(240)   -- bug 2947642
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Eng_Routing_Flag           NUMBER
   , Common_Assembly_Item_Name  VARCHAR2(240) -- bug 2947642
   , Routing_Comment            VARCHAR2(240)
   , Completion_Subinventory    VARCHAR2(10)
   , Completion_Location_Name   VARCHAR2(81)
   , Line_Code                  VARCHAR2(10)
   , CFM_Routing_Flag           NUMBER
   , Mixed_Model_Map_Flag       NUMBER
   , Priority                   NUMBER
   , Total_Cycle_Time           NUMBER
   , CTP_Flag                   NUMBER
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Delete_Group_Name          VARCHAR2(10)
   , DG_Description             VARCHAR2(240)
   , Ser_Start_Op_Seq		NUMBER -- Added for SSOS
   , Row_Identifier		NUMBER -- Added for Open Interface API
   ) ;
--
-- Routing Unexposed Record definition
--
   TYPE Rtg_Header_Unexposed_Rec_Type IS  RECORD
   (
     Routing_Sequence_Id          NUMBER
   , Assembly_Item_Id             NUMBER
   , Organization_Id              NUMBER
   , Routing_Type                 NUMBER
   , Common_Assembly_Item_Id      NUMBER
   , Common_Routing_Sequence_Id   NUMBER
   , Completion_Locator_Id        NUMBER
   , Line_Id                      NUMBER
   , DG_Sequence_Id               NUMBER
   , DG_Description               VARCHAR2(240)
   , DG_New                       BOOLEAN
   );

--
-- Routing_Revision exposed record definition
--

   TYPE Rtg_Revision_Rec_Type  IS  RECORD
   (
     Assembly_Item_Name         VARCHAR2(240) -- bug 2947642
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Revision                   VARCHAR2(3)
   , Start_Effective_Date       DATE
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Row_Identifier		NUMBER -- Added for Open Interface API
   ) ;

    TYPE Rtg_Revision_Tbl_Type IS TABLE OF Rtg_Revision_Rec_Type
    INDEX BY BINARY_INTEGER ;

--
-- Routing_Revison Unexposed Column Record
--

   TYPE Rtg_Rev_Unexposed_Rec_Type IS RECORD
   (
     Routing_Sequence_Id  NUMBER
   , Assembly_Item_Id     NUMBER
   , Organization_Id      NUMBER
   , Implementation_Date  DATE
   , Change_Notice        VARCHAR2(10)
   ) ;

-- ECO Uses a different record structure for Operation Seqeunces,
-- Operation Resources and Sub Operation Resources than what BOM Routing
-- uses. So their two control record definition


TYPE Control_Rec_Type IS RECORD
    ( controlled_operation  BOOLEAN
    , check_existence       BOOLEAN
    , attribute_defaulting  BOOLEAN
    , entity_defaulting     BOOLEAN
    , entity_validation     BOOLEAN
    , process_entity        VARCHAR2(30)
    , write_to_db           BOOLEAN
    , last_updated_by       NUMBER
    , last_update_login     NUMBER
    , caller_type           VARCHAR2(10)
                        -- Set to 'FORM' if a FORM calls the program
    , validation_controller VARCHAR2(30)
                        -- The name a field that requires specific validation
    , require_item_rev  NUMBER
    , unit_controlled_item  BOOLEAN
    );

    G_Default_Control_Rec  Control_Rec_Type ;

--
-- Routing Operation exposed Column Record
--

   TYPE Operation_Rec_Type   IS RECORD
   (
     Assembly_Item_Name         VARCHAR2(240) -- bug 2947642
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Start_Effective_Date       DATE
   , New_Operation_Sequence_Number NUMBER
   , New_Start_Effective_Date   DATE
   , Standard_Operation_Code    VARCHAR2(4)
   , Department_Code            VARCHAR2(10)
   , Op_Lead_Time_Percent       NUMBER
   , Minimum_Transfer_Quantity  NUMBER
   , Count_Point_Type           NUMBER
   , Operation_Description      VARCHAR2(240)
   , Disable_Date               DATE
   , Backflush_Flag             NUMBER
   , Option_Dependent_Flag      NUMBER
   , Reference_Flag             NUMBER
   , Process_Seq_Number         NUMBER
   , Process_Code               VARCHAR2(4)
   , Line_Op_Seq_Number         NUMBER
   , Line_Op_Code               VARCHAR2(4)
   , Yield                      NUMBER
   , Cumulative_Yield           NUMBER
   , Reverse_CUM_Yield          NUMBER
   , User_Labor_Time            NUMBER
   , User_Machine_Time          NUMBER
   , Net_Planning_Percent       NUMBER
   , Include_In_Rollup          NUMBER
   , Op_Yield_Enabled_Flag      NUMBER
   , Shutdown_Type              VARCHAR2(30)
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Delete_Group_Name          VARCHAR2(10)
   , DG_Description             VARCHAR2(240)
   , Long_Description		VARCHAR2(4000) -- added for long description
   , Row_Identifier		NUMBER -- Added for Open Interface API
   /* Check_Skill has been commented out for bug 21155692 since it resulted in two invalid packages.
   Moreover this change is not required to fix the bug 13979762. We might have to add this column later
   under this record type, when we are going to enable check_skill for BMCOIN/API. */
   --, Check_Skill		NUMBER   --added for bug 13979762
      );
    TYPE Operation_Tbl_Type IS TABLE OF Operation_Rec_Type
    INDEX BY BINARY_INTEGER ;

--
-- Rouitng Operation Unexposed Column Record
--

   TYPE Op_Unexposed_Rec_Type    IS RECORD
   (
     Operation_Sequence_Id   NUMBER
   , Routing_Sequence_Id     NUMBER
   , Assembly_Item_Id        NUMBER
   , Organization_Id         NUMBER
   , Standard_Operation_Id   NUMBER
   , Department_Id           NUMBER
   , Process_Op_Seq_Id       NUMBER
   , Line_Op_Seq_Id          NUMBER
   , User_Elapsed_Time       NUMBER
   , DG_Sequence_Id          NUMBER
   , DG_Description          VARCHAR2(240)
   , DG_New                  BOOLEAN
   , Lowest_acceptable_yield NUMBER -- Added for MES Enhancement
   , Use_org_settings	     NUMBER
   , Queue_mandatory_flag    NUMBER
   , Run_mandatory_flag      NUMBER
   , To_move_mandatory_flag  NUMBER
   , Show_next_op_by_default NUMBER
   , Show_scrap_code         NUMBER
   , Show_lot_attrib	     NUMBER
   , Track_multiple_res_usage_dates NUMBER -- End of MES Changes
   /* Added for bug 21155295 to retain the value of check skill of routing operation after operation update suing API */
   , Check_Skill	     NUMBER
   ) ;


--
-- Revised Operation exposed Column Record
--

   TYPE Rev_Operation_Rec_Type   IS RECORD
   (
     Eco_Name                   VARCHAR2(10)
   , Organization_Code          VARCHAR2(3)
   , Revised_Item_Name          VARCHAR2(240) -- bug 2947642
   , New_Revised_Item_Revision  VARCHAR2(3)
   , From_End_Item_Unit_Number  VARCHAR2(30)
   , New_Routing_Revision       VARCHAR2(3)
   , ACD_Type                   NUMBER
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Start_Effective_Date       DATE
   , New_Operation_Sequence_Number NUMBER
   , Old_Operation_Sequence_Number NUMBER
   , Old_Start_Effective_Date   DATE
   , Standard_Operation_Code    VARCHAR2(4)
   , Department_Code            VARCHAR2(10)
   , Op_Lead_Time_Percent       NUMBER
   , Minimum_Transfer_Quantity  NUMBER
   , Count_Point_Type           NUMBER
   , Operation_Description      VARCHAR2(240)
   , Disable_Date               DATE
   , Backflush_Flag             NUMBER
   , Option_Dependent_Flag      NUMBER
   , Reference_Flag             NUMBER
   , Yield                      NUMBER
   , Cumulative_Yield           NUMBER
   , Cancel_Comments            VARCHAR2(240)
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   /* Check_Skill has been commented out for bug 21155295 since
      it will be used as un-exposed column. */
   --, Check_Skill		NUMBER  --added for bug 13979762
   ) ;

    TYPE Rev_Operation_Tbl_Type IS TABLE OF Rev_Operation_Rec_Type
    INDEX BY BINARY_INTEGER ;

--
-- Revised Operation Unexposed Column Record
--

   TYPE Rev_Op_Unexposed_Rec_Type    IS RECORD
   (
     Revised_Item_Sequence_Id    NUMBER
   , Operation_Sequence_Id       NUMBER
   , Old_Operation_Sequence_Id   NUMBER
   , Routing_Sequence_Id         NUMBER
   , Revised_Item_Id             NUMBER
   , Organization_Id             NUMBER
   , Standard_Operation_Id       NUMBER
   , Department_Id               NUMBER
   /* added for bug 21155295 since check_skill will be used as un-exposed column */
   , Check_Skill		 NUMBER
   ) ;

--
-- Common Operation exposed Column Record
--

   TYPE Com_Operation_Rec_Type   IS RECORD
   (
     Eco_Name                   VARCHAR2(10)
   , Organization_Code          VARCHAR2(3)
   , Revised_Item_Name          VARCHAR2(240) -- bug 2947642
   , New_revised_Item_Revision  VARCHAR2(3)
   , From_End_Item_Unit_Number  VARCHAR2(30)
   , New_Routing_Revision       VARCHAR2(3)
   , ACD_Type                   NUMBER
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Start_Effective_Date       DATE
   , New_Operation_Sequence_Number NUMBER
   , New_Start_Effective_Date   DATE
   , Old_Operation_Sequence_Number NUMBER
   , Old_Start_Effective_Date   DATE
   , Standard_Operation_Code    VARCHAR2(4)
   , Department_Code            VARCHAR2(10)
   , Op_Lead_Time_Percent       NUMBER
   , Minimum_Transfer_Quantity  NUMBER
   , Count_Point_Type           NUMBER
   , Operation_Description      VARCHAR2(240)
   , Disable_Date               DATE
   , Backflush_Flag             NUMBER
   , Option_Dependent_Flag      NUMBER
   , Reference_Flag             NUMBER
   , Process_Seq_Number         NUMBER
   , Process_Code               VARCHAR2(4)
   , Line_Op_Seq_Number         NUMBER
   , Line_Op_Code               VARCHAR2(4)
   , Yield                      NUMBER
   , Cumulative_Yield           NUMBER
   , Reverse_CUM_Yield          NUMBER
   -- , Calculated_Labor_Time      NUMBER
   -- , Calculated_Machine_Time    NUMBER
   -- , Calculated_Elapsed_Time    NUMBER
   , User_Labor_Time            NUMBER
   , User_Machine_Time          NUMBER
   -- , User_Elapsed_Time          NUMBER
   , Net_Planning_Percent       NUMBER
   , Include_In_Rollup          NUMBER
   , Op_Yield_Enabled_Flag      NUMBER
   , Cancel_Comments            VARCHAR2(240)
     -- Added Shutdown_Type for eAM changes by MK on 04/10/2001
   , Shutdown_Type              VARCHAR2(30)
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Delete_Group_Name          VARCHAR2(10)
   , DG_Description             VARCHAR2(240)
   , Long_Description		VARCHAR2(4000) -- added for long description
   /* Commented check_skill for bug 21155295 since it will used as un-exposed column. */
   --, Check_Skill		NUMBER  --added for bug 13979762
   ) ;

    TYPE  Com_Operation_Tbl_Type IS TABLE OF Rev_Operation_Rec_Type
    INDEX BY BINARY_INTEGER ;

--
-- Common Operation Unexposed Column Record
--

   TYPE Com_Op_Unexposed_Rec_Type    IS RECORD
   (
     Revised_Item_Sequence_Id    NUMBER
   , Operation_Sequence_Id       NUMBER
   , Old_Operation_Sequence_Id   NUMBER
   , Routing_Sequence_Id         NUMBER
   , Revised_Item_Id             NUMBER
   , Organization_Id             NUMBER
   , Standard_Operation_Id       NUMBER
   , Department_Id               NUMBER
   , Process_Op_Seq_Id           NUMBER
   , Line_Op_Seq_Id              NUMBER
   , User_Elapsed_Time           NUMBER
   , DG_Sequence_Id              NUMBER
   , DG_Description              VARCHAR2(240)
   , DG_New                      BOOLEAN
   , Lowest_acceptable_yield     NUMBER -- Added for MES Enhancement
   , Use_org_settings	         NUMBER
   , Queue_mandatory_flag        NUMBER
   , Run_mandatory_flag          NUMBER
   , To_move_mandatory_flag      NUMBER
   , Show_next_op_by_default     NUMBER
   , Show_scrap_code             NUMBER
   , Show_lot_attrib	         NUMBER
   , Track_multiple_res_usage_dates NUMBER -- End of MES Changes
   /* added for bug 21155295 since check_skill will be used as un-exposed column */
   , Check_Skill		 NUMBER
   ) ;


--
--  Operation Resource record type
--

   TYPE Op_Resource_Rec_Type IS RECORD
   (
     Assembly_Item_Name         VARCHAR2(240) -- bug 2947642
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Op_Start_Effective_Date    DATE
   , ACD_TYPE                   NUMBER --14286614
   , ECO_NAME                   VARCHAR2(10)   --14286614
   , Resource_Sequence_Number   NUMBER
   , Resource_Code              VARCHAR2(10)
   , Activity                   VARCHAR2(10)
   , Standard_Rate_Flag         NUMBER
   , Assigned_Units             NUMBER
   , Usage_Rate_Or_Amount       NUMBER
   , Usage_Rate_Or_Amount_Inverse   NUMBER
   , Basis_Type                 NUMBER
   , Schedule_Flag              NUMBER
   , Resource_Offset_Percent    NUMBER
   , Autocharge_Type            NUMBER
   , Substitute_Group_Number    NUMBER  --added in RBO following changes for 11510
   , Schedule_Sequence_Number   NUMBER
   , Principle_Flag             NUMBER
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Setup_Type                 VARCHAR2(30)
   , Row_Identifier		NUMBER -- Added for Open Interface API
   ) ;

   TYPE Op_Resource_Tbl_Type IS  TABLE  OF Op_Resource_Rec_Type
                INDEX BY BINARY_INTEGER;

--
--  Operation resource Unexposed Column Record
--

   TYPE Op_Res_Unexposed_Rec_Type IS RECORD
   (
     Operation_Sequence_Id   NUMBER
   , Routing_Sequence_Id     NUMBER
   , Assembly_Item_Id        NUMBER
   , Organization_Id         NUMBER
   , Substitute_Group_Number NUMBER
   , Resource_Id             NUMBER
   , Activity_Id             NUMBER
   , Setup_Id                NUMBER
    );


--
--  Revised Operation Resource record type
--

   TYPE Rev_Op_Resource_Rec_Type IS RECORD
   (
     Eco_Name                   VARCHAR2(10)
   , Organization_Code          VARCHAR2(3)
   , Revised_Item_Name          VARCHAR2(240) -- bug 2947642
   , New_Revised_Item_Revision  VARCHAR2(3)
   , From_End_Item_Unit_Number  VARCHAR2(30)   -- Added by MK on 11/02/00
   , New_Routing_Revision       VARCHAR2(3)    -- Added by MK on 11/02/00
   , ACD_Type                   NUMBER
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Op_Start_Effective_Date    DATE
   , Resource_Sequence_Number   NUMBER
   , Resource_Code              VARCHAR2(10)
   , Activity                   VARCHAR2(10)
   , Standard_Rate_Flag         NUMBER
   , Assigned_Units             NUMBER
   , Usage_Rate_Or_Amount       NUMBER
   , Usage_Rate_Or_Amount_Inverse   NUMBER
   , Basis_Type                 NUMBER
   , Schedule_Flag              NUMBER
   , Resource_Offset_Percent    NUMBER
   , Autocharge_Type            NUMBER
   , Substitute_Group_Number    NUMBER
   , Schedule_Sequence_Number   NUMBER
   , Principle_Flag             NUMBER
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Setup_Type                 VARCHAR2(30)
   ) ;

   TYPE Rev_Op_Resource_Tbl_Type IS  TABLE  OF Rev_Op_Resource_Rec_Type
   INDEX BY BINARY_INTEGER;

--
--  Revised Operation Resource Unexposed Column Record
--

   TYPE Rev_Op_Res_Unexposed_Rec_Type IS RECORD
   (
     Revised_Item_Sequence_Id NUMBER
   , Operation_Sequence_Id    NUMBER
   , Routing_Sequence_Id      NUMBER
   , Revised_Item_Id          NUMBER
   , Organization_Id          NUMBER
   , Substitute_Group_Number  NUMBER
   , Resource_Id              NUMBER
   , Activity_Id              NUMBER
   , Setup_Id                 NUMBER
   ) ;


--
--  Substitute Operation Resource type
--

   TYPE Sub_Resource_Rec_Type IS RECORD
   (
     Assembly_Item_Name         VARCHAR2(240) -- bug 2947642
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Op_Start_Effective_Date    DATE
   , Sub_Resource_Code          VARCHAR2(10)
   , New_Sub_Resource_Code      VARCHAR2(10)
   , Substitute_Group_Number    NUMBER
   , Schedule_Sequence_Number   NUMBER
   , Replacement_Group_Number   NUMBER
   , New_Replacement_Group_Number NUMBER -- bug 3741570
   , Activity                   VARCHAR2(10)
   , Standard_Rate_Flag         NUMBER
   , Assigned_Units             NUMBER
   , Usage_Rate_Or_Amount       NUMBER
   , Usage_Rate_Or_Amount_Inverse   NUMBER
   , Basis_Type                 NUMBER
   , New_Basis_Type             NUMBER /* Added for bug 4689856 */
   , Schedule_Flag              NUMBER
   , New_Schedule_Flag          NUMBER   /* Added for bug 13005178 */
   , Resource_Offset_Percent    NUMBER
   , Autocharge_Type            NUMBER
   , Principle_Flag             NUMBER
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Setup_Type                 VARCHAR2(30)
   , Row_Identifier		NUMBER -- Added for Open Interface API
   ) ;


   TYPE Sub_Resource_Tbl_Type IS TABLE OF Sub_Resource_Rec_Type
   INDEX BY BINARY_INTEGER ;

--
--   Substitute Operation Resource Unexposed Column Record
--

   TYPE Sub_Res_Unexposed_Rec_Type IS RECORD
   (
     Operation_Sequence_Id      NUMBER
   , Routing_Sequence_Id        NUMBER
   , Substitute_Group_Number    NUMBER
   , Assembly_Item_Id           NUMBER
   , Organization_Id            NUMBER
   , Resource_Id                NUMBER
   , New_Resource_Id            NUMBER
   , Activity_Id                NUMBER
   , Setup_Id                 NUMBER
   );



--
--  Revised Substitute Operation Resource type
--

   TYPE Rev_Sub_Resource_Rec_Type IS RECORD
   (
     Eco_Name                   VARCHAR2(10)
   , Organization_Code          VARCHAR2(3)
   , Revised_Item_Name          VARCHAR2(240) -- bug 2947642
   , New_Revised_Item_Revision  VARCHAR2(3)
   , From_End_Item_Unit_Number  VARCHAR2(30)   -- Added by MK on 11/02/00
   , New_Routing_Revision       VARCHAR2(3)    -- Added by MK on 11/02/00
   , ACD_Type                   NUMBER
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Sequence_Number  NUMBER
   , Operation_Type             NUMBER
   , Op_Start_Effective_Date    DATE
   , Sub_Resource_Code          VARCHAR2(10)
   , New_Sub_Resource_Code      VARCHAR2(10)
   , Substitute_Group_Number    NUMBER
   , Schedule_Sequence_Number   NUMBER
   , Replacement_Group_Number   NUMBER
   , New_Replacement_Group_Number NUMBER -- bug 3741570
   , Activity                   VARCHAR2(10)
   , Standard_Rate_Flag         NUMBER
   , Assigned_Units             NUMBER
   , Usage_Rate_Or_Amount       NUMBER
   , Usage_Rate_Or_Amount_Inverse   NUMBER
   , Basis_Type                 NUMBER
   , New_Basis_Type             NUMBER /* Added for bug 4689856 */
   , Schedule_Flag              NUMBER
   , New_Schedule_Flag          NUMBER   /* Added for bug 13005178 */
   , Resource_Offset_Percent    NUMBER
   , Autocharge_Type            NUMBER
   , Principle_Flag             NUMBER
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Setup_Type                 VARCHAR2(30)
   ) ;


   TYPE Rev_Sub_Resource_Tbl_Type IS TABLE OF Rev_Sub_Resource_Rec_Type
   INDEX BY BINARY_INTEGER ;

--
--   Rev Substitute Operation Resource Unexposed Column Record
--

   TYPE Rev_Sub_Res_Unexposed_Rec_Type IS RECORD
   (
     Revised_Item_Sequence_Id   NUMBER
   , Operation_Sequence_Id      NUMBER
   , Routing_Sequence_Id        NUMBER
   , Substitute_Group_Number    NUMBER
   , Revised_Item_Id            NUMBER
   , Organization_Id            NUMBER
   , Resource_Id                NUMBER
   , New_Resource_Id            NUMBER
   , Activity_Id                NUMBER
   , Setup_Id                 NUMBER
   ) ;

--
-- Operation Network Record definition
--
   TYPE Op_Network_Rec_Type IS RECORD
   (
     Assembly_Item_Name         VARCHAR2(240) -- bug 2947642
   , Organization_Code          VARCHAR2(3)
   , Alternate_Routing_Code     VARCHAR2(10)
   , Operation_Type             NUMBER
   , From_Op_Seq_Number         NUMBER
   , From_X_Coordinate          NUMBER
   , From_Y_Coordinate          NUMBER
   , From_Start_Effective_Date  DATE
   , To_Op_Seq_Number           NUMBER
   , To_X_Coordinate            NUMBER
   , To_Y_Coordinate            NUMBER
   , To_Start_Effective_Date    DATE
   , New_From_Op_Seq_Number     NUMBER
   , New_From_Start_Effective_Date  DATE
   , New_To_Op_Seq_Number           NUMBER
   , New_To_Start_Effective_Date    DATE
   , Connection_Type            NUMBER
   , Planning_Percent           NUMBER
   , Attribute_category         VARCHAR2(30)
   , Attribute1                 VARCHAR2(150)
   , Attribute2                 VARCHAR2(150)
   , Attribute3                 VARCHAR2(150)
   , Attribute4                 VARCHAR2(150)
   , Attribute5                 VARCHAR2(150)
   , Attribute6                 VARCHAR2(150)
   , Attribute7                 VARCHAR2(150)
   , Attribute8                 VARCHAR2(150)
   , Attribute9                 VARCHAR2(150)
   , Attribute10                VARCHAR2(150)
   , Attribute11                VARCHAR2(150)
   , Attribute12                VARCHAR2(150)
   , Attribute13                VARCHAR2(150)
   , Attribute14                VARCHAR2(150)
   , Attribute15                VARCHAR2(150)
   , Original_System_Reference  VARCHAR2(50)
   , Transaction_Type           VARCHAR2(30)
   , Return_Status              VARCHAR2(1)
   , Row_Identifier		NUMBER -- Added for Open Interface API
   ) ;

     TYPE Op_Network_Tbl_Type IS TABLE OF Op_Network_Rec_Type
     INDEX BY BINARY_INTEGER;

--
-- Operation_Network Unexposed Record Definition
--

   TYPE Op_Network_Unexposed_Rec_Type IS RECORD
   (
     From_Op_Seq_Id       NUMBER
   , To_Op_Seq_Id         NUMBER
   , New_From_Op_Seq_Id   NUMBER
   , New_To_Op_Seq_Id     NUMBER
   , Routing_Sequence_Id  NUMBER
   , CFM_Routing_Flag     VARCHAR2(1)
   , Assembly_Item_Id     NUMBER
   , Organization_Id      NUMBER
   ) ;


--
-- Missing Records for RTG BO
--
   G_MISS_RTG_HEADER_REC         Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
   G_MISS_RTG_REVISION_REC       Bom_Rtg_Pub.Rtg_Revision_Rec_Type ;
   G_MISS_OPERATION_REC          Bom_Rtg_Pub.Operation_Rec_Type ;
   G_MISS_OP_RESOURCE_REC        Bom_Rtg_Pub.Op_Resource_Rec_Type ;
   G_MISS_SUB_RESOURCE_REC       Bom_Rtg_Pub.Sub_Resource_Rec_Type ;
   G_MISS_OP_NETWORK_REC         Bom_Rtg_Pub.Op_Network_Rec_Type ;

   G_MISS_RTG_HEADER_UNEXP_REC   Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type ;
   G_MISS_RTG_REV_UNEXP_REC      Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type ;
   G_MISS_OP_UNEXP_REC           Bom_Rtg_Pub.Op_Unexposed_Rec_Type ;
   G_MISS_OP_RES_UNEXP_REC       Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type ;

   G_MISS_SUB_RES_UNEXP_REC      Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type ;
   G_MISS_OP_NETWORK_UNEXP_REC   Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type ;

   G_MISS_RTG_REVISION_TBL       Bom_Rtg_Pub.Rtg_Revision_Tbl_Type  ;
   G_MISS_OPERATION_TBL          Bom_Rtg_Pub.Operation_Tbl_Type;
   G_MISS_OP_RESOURCE_TBL        Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
   G_MISS_SUB_RESOURCE_TBL       Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
   G_MISS_OP_NETWORK_TBL         Bom_Rtg_Pub.Op_Network_Tbl_Type;

--
-- Missing Records for ENG BO
--

   G_MISS_REV_OPERATION_REC          Bom_Rtg_Pub.Rev_Operation_Rec_Type ;
   G_MISS_REV_OP_RESOURCE_REC        Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
   G_MISS_REV_SUB_RESOURCE_REC       Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type ;

   G_MISS_REV_OP_UNEXP_REC           Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;
   G_MISS_REV_OP_RES_UNEXP_REC       Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
   G_MISS_REV_SUB_RES_UNEXP_REC      Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;

   G_MISS_REV_OPERATION_TBL          Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
   G_MISS_REV_OP_RESOURCE_TBL        Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type ;
   G_MISS_REV_SUB_RESOURCE_TBL       Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;


--
-- Missing Records for ENG BO
--

   G_MISS_COM_OPERATION_REC          Bom_Rtg_Pub.Com_Operation_Rec_Type ;
   G_MISS_COM_OP_UNEXP_REC           Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type ;
   G_MISS_COM_OPERATION_TBL          Bom_Rtg_Pub.Com_Operation_Tbl_Type;


--
-- Conversion from Routing BO Entity to Eco BO Entity
-- Conversion from Eco BO Entity to Routing BO Entity
--

   -- Operation Entity

   -- From Routing To Common
/*#
 * This procedure converts a Routing Operation into a Common Operation.
 *
 * @param p_rtg_operation_rec IN Routing Operation to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type}
 * @param p_rtg_op_unexp_rec IN Routing Operation unexposed record.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 * @param x_com_operation_rec IN OUT NOCOPY Converted Common Operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type}
 * @param x_com_op_unexp_rec IN OUT NOCOPY Additional fields for converted Common Operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Routing Operation into Common Operation
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_RtgOp_To_ComOp
   (
     p_rtg_operation_rec  IN  Bom_Rtg_Pub.Operation_Rec_Type
   , p_rtg_op_unexp_rec   IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
   , x_com_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
   , x_com_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
   ) ;

   -- From Common To Routing
/*#
 * This procedure converts a Common Operation into a Routing Operation.
 *
 * @param p_com_operation_rec IN Common Operation to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type}
 * @param p_com_op_unexp_rec IN Additional fields for Common Operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_rtg_operation_rec IN OUT NOCOPY Converted Routing Operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Operation_Rec_Type}
 * @param x_rtg_op_unexp_rec IN OUT NOCOPY Additional fields for converted Routing Operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Common Operation into Routing Operation
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_ComOp_To_RtgOp
   (
     p_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
   , p_com_op_unexp_rec IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
   , x_rtg_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
   , x_rtg_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
   ) ;

   -- From Eco To Common
/*#
 * This procedure converts a revised operation into a common operation.
 *
 * @param p_rev_operation_rec IN Revised operation to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type}
 * @param p_rev_op_unexp_rec IN Additional fields for revised operation to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 * @param x_com_operation_rec IN OUT NOCOPY Converted common operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type}
 * @param x_com_op_unexp_rec IN OUT NOCOPY Additional fields for converted common operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Revised Operation into Common Operation
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_EcoOp_To_ComOp
   (
     p_rev_operation_rec  IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
   , p_rev_op_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
   , x_com_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
   , x_com_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
   ) ;


   -- From Common To Eco
/*#
 * This procedure converts a common operation into a revised operation.
 *
 * @param p_com_operation_rec IN Common operation to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Operation_Rec_Type}
 * @param p_com_op_unexp_rec IN Additional fields for common operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type}
 * @param x_rev_operation_rec IN OUT NOCOPY Converted Revised operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Operation_Rec_Type}
 * @param x_rev_op_unexp_rec IN OUT NOCOPY Additional fields for converted revised operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Common Operation into Revised Operation
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_ComOp_To_EcoOp
   (
     p_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
   , p_com_op_unexp_rec   IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
   , x_rev_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
   , x_rev_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
   ) ;


   -- Operation Resource Entity

/*#
 * This procedure converts a routing operation resource into a revised operation resource.
 *
 * @param p_rtg_op_resource_rec IN Routing operation resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param p_rtg_op_res_unexp_rec IN Additional fields for routing operation resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 * @param x_rev_op_resource_rec IN OUT NOCOPY Converted revised operation resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
 * @param x_rev_op_res_unexp_rec IN OUT NOCOPY Additional fields for converted revised operation resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Routing Operation Resource into Revised Operation Resource
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_RtgRes_To_EcoRes
   (
     p_rtg_op_resource_rec  IN Bom_Rtg_Pub.Op_Resource_Rec_Type
   , p_rtg_op_res_unexp_rec IN Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
   , x_rev_op_resource_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
   , x_rev_op_res_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
   ) ;

/*#
 * This procedure converts a revised operation resource into a routing operation resource.
 *
 * @param p_rev_op_resource_rec IN Revised operation resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type}
 * @param p_rev_op_res_unexp_rec IN Additional fields for revised operation resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type}
 * @param x_rtg_op_resource_rec IN OUT NOCOPY Converted Routing operation resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Resource_Rec_Type}
 * @param x_rtg_op_res_unexp_rec IN OUT NOCOPY Additional fields for converted routing operation.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Revised Operation Resource into Routing Operation Resource
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_EcoRes_To_RtgRes
   (
     p_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
   , p_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
   , x_rtg_op_resource_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
   , x_rtg_op_res_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
    ) ;

    -- Sub Operation Resource Entity

/*#
 * This procedure converts a routing substitute resource into a revised substitute resource.
 *
 * @param p_rtg_sub_resource_rec IN Routing substitute resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param p_rtg_sub_res_unexp_rec IN Additional fields for routing substitute resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 * @param x_rev_sub_resource_rec IN OUT NOCOPY Converted revised substitute resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param x_rev_sub_res_unexp_rec IN OUT NOCOPY Additional fields for converted revised substitute resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Routing Substitute Resource into Revised Substitute Resource
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_RtgSubRes_To_EcoSubRes
   (
     p_rtg_sub_resource_rec    IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
   , p_rtg_sub_res_unexp_rec   IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
   , x_rev_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
   , x_rev_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
   ) ;

/*#
 * This procedure converts a revised substitute resource into a routing substitute resource.
 *
 * @param p_rev_sub_resource_rec IN Revised substitute resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type}
 * @param p_rev_sub_res_unexp_rec IN Additional fields for revised substitute resource to be converted.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type}
 * @param x_rtg_sub_resource_rec IN OUT NOCOPY Converted Routing substitute resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Resource_Rec_Type}
 * @param x_rtg_sub_res_unexp_rec IN OUT NOCOPY Additional fields for converted routing substitute resource.
 * @rep:paraminfo {@rep:innertype Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type}
 *
 * @rep:displayname Convert Revised Substitute Resource into Routing Substitute Resource
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Convert_EcoSubRes_To_RtgSubRes
   (
     p_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
   , p_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
   , x_rtg_sub_resource_rec  IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
   , x_rtg_sub_res_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
   ) ;



/*#
 * This procedure is used to create, update or delete a routing
 * and its child entities:routing revisions, operations, operation
 * resources, substitute operation resources and operation networks.
 * Each of the records contained in one of the tables
 * passed as a parameter contains a <code>TRANSACTION_TYPE</code> field, which
 * indicates the operation to be performed on the record, as follows:
 * <UL>
 * <LI><code><B>TRANSACTION_TYPE = 'CREATE'</B></code> for record creation</LI>
 * <LI><code><B>TRANSACTION_TYPE = 'UPDATE'</B></code> for record update</LI>
 * <LI><code><B>TRANSACTION_TYPE = 'DELETE'</B></code> for record deletion</LI>
 * </UL>
 *
 * @param p_bo_identifier IN Business Object identifier. Possible values are RTG and ECO.
 * @param p_api_version_number IN API version number.
 * @param p_init_msg_list IN Use TRUE if you want to initialize the FND_MSG_PUB
 * package's message stack on calling the procedure.
 * @param p_rtg_header_rec IN Manufacturing routing header, corresponding to the
 * business object instance.
 * @param p_rtg_revision_tbl IN Manufacturing routing revisions.
 * @param p_operation_tbl IN Manufacturing routing operations.
 * @param p_op_resource_tbl IN Manufacturing routing operation resources.
 * @param p_sub_resource_tbl IN Manufacturing routing substitute operation
 * resources.
 * @param p_op_network_tbl IN Manufacturing routing operation networks.
 * @param x_rtg_header_rec IN OUT NOCOPY Resulting manufacturing routing header.
 * @param x_rtg_revision_tbl IN OUT NOCOPY Resulting manufacturing routing revisions.
 * @param x_operation_tbl IN OUT NOCOPY Resulting manufacturing routing operations.
 * @param x_op_resource_tbl IN OUT NOCOPY Resulting manufacturing routing operation resources.
 * @param x_sub_resource_tbl IN OUT NOCOPY Resulting manufacturing routing substitute operation
 * resources.
 * @param x_op_network_tbl IN OUT NOCOPY Resulting manufacturing routing operation networks.
 * @param x_return_status IN OUT NOCOPY Return status: 'S' for success, 'E' for error, 'U' for
 * unexpected error.
 * @param x_msg_count IN OUT NOCOPY Number of messages produced by the API.
 * @param p_debug IN Debuggin is enabled or not
 * @param p_output_dir IN Path of the debug output directory
 * @param p_debug_filename IN File name of the debug file
 *
 * @rep:displayname Process Routing
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */
   PROCEDURE Process_Rtg
   ( p_bo_identifier           IN  VARCHAR2 := 'RTG'
   , p_api_version_number      IN  NUMBER := 1.0
   , p_init_msg_list           IN  BOOLEAN := FALSE
   , p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
                                        :=Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
   , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
                                        :=Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
   , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OPERATION_TBL
   , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
   , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
                                       :=  Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
   , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
   , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
   , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
   , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
   , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
   , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
   , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
   , x_return_status           IN OUT NOCOPY VARCHAR2
   , x_msg_count               IN OUT NOCOPY NUMBER
   , p_debug                   IN  VARCHAR2 := 'N'
   , p_output_dir              IN  VARCHAR2 := NULL
   , p_debug_filename          IN  VARCHAR2 := 'RTG_BO_debug.log'
   ) ;

END Bom_Rtg_Pub ;

/
