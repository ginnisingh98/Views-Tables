--------------------------------------------------------
--  DDL for Package Body BOM_RTG_COPYORG_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_COPYORG_IMP" AS
/* $Header: BOMRTCPB.pls 120.0.12010000.3 2012/01/06 17:48:16 umajumde ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRTSTB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_COPYORG_IMP
--
--  NOTES
--
--  HISTORY
--
--  06-OCT-06  Mohan Yerramsetty  Bug# 5493353, Initial Creation.
--                                This package has PL/SQL logic of Copying
--				  Routings. It doesn't use Exporting to XML,
--				  Importing from XML Logic. This will fetch
--				  all Routings from source organization and
--				  pass all the records to Routing Interface API.
--				  Routing Interface API will do the copying.
--  13-DEC-06  Mohan Yerramsetty  Bug# 5493353, Modified the code to delete
--                                the successfully processed records after
--				  the call to BOM_RTG_PUB.Process_RTG to
--				  reduce the memory consumed by the process.
***************************************************************************/

--=============================================
-- CONSTANTS
--=============================================
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'bom.plsql.BOM_RTG_COPYORG_IMP.';
g_api_name	CONSTANT VARCHAR2(30) := 'IMPORT_ROUTING';

--=============================================
-- GLOBAL VARIABLES
--=============================================
g_fnd_debug	VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');


PROCEDURE IMPORT_ROUTING(P_debug              IN  VARCHAR2 := 'N',
                         P_output_dir         IN  VARCHAR2 := NULL,
                         P_debug_filename     IN  VARCHAR2 := 'BOM_BO_debug.log',
  			 p_model_org_id	      IN  NUMBER,
			 p_target_orgcode     IN  VARCHAR2,
                         X_return_status      OUT NOCOPY VARCHAR2,
                         X_msg_count          OUT NOCOPY NUMBER,
                         X_G_msg_data         OUT NOCOPY LONG) IS

  TYPE Rtg_Header_Tbl_Type IS TABLE OF Bom_Rtg_Pub.Rtg_Header_Rec_Type
  INDEX BY BINARY_INTEGER ;
  l_rtg_header_tbl	Rtg_Header_Tbl_Type;

  l_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type;
  l_rtg_revision_tbl  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type;
  l_operation_tbl     Bom_Rtg_Pub.Operation_Tbl_Type;
  l_op_resource_tbl   Bom_Rtg_Pub.Op_Resource_Tbl_Type;
  l_sub_resource_tbl  Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
  l_op_network_tbl    Bom_Rtg_Pub.Op_Network_Tbl_Type;

  x_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type;
  x_rtg_revision_tbl  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type;
  x_operation_tbl     Bom_Rtg_Pub.Operation_Tbl_Type;
  x_op_resource_tbl   Bom_Rtg_Pub.Op_Resource_Tbl_Type;
  x_sub_resource_tbl  Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
  x_op_network_tbl    Bom_Rtg_Pub.Op_Network_Tbl_Type;


---------------------------------Operational Routings Cursor-----------------------------------------------

  CURSOR rtg_hdr_CUR IS
    SELECT  item1.concatenated_segments       Assembly_Item_Name,
            p_target_orgcode                  Organization_Code,                --myerrams, Select the Target Org code into the cursor
            bor.alternate_routing_designator  Alternate_Routing_Code,
            DECODE(bor.routing_type, 1, 2, 2, 1, NULL)  Eng_Routing_Flag,
            item2.concatenated_segments       Common_Assembly_Item_Name,
            bor.routing_comment               Routing_Comment,
            bor.completion_subinventory       Completion_Subinventory,
            locators.concatenated_segments    Completion_Location_Name,
            wl.line_code                      Line_Code,
            bor.cfm_Routing_Flag              CFM_Routing_Flag,
            bor.mixed_model_map_flag          Mixed_Model_Map_Flag,
            bor.priority                      Priority,
            bor.total_product_cycle_time      Total_Cycle_Time,
            bor.ctp_flag                      CTP_Flag,
            bor.attribute_category            Attribute_category,
            bor.attribute1                    Attribute1,
            bor.attribute2                    Attribute2,
            bor.attribute3                    Attribute3,
            bor.attribute4                    Attribute4,
            bor.attribute5                    Attribute5,
            bor.attribute6                    Attribute6,
            bor.attribute7                    Attribute7,
            bor.attribute8                    Attribute8,
            bor.attribute9                    Attribute9,
            bor.attribute10                   Attribute10,
            bor.attribute11                   Attribute11,
            bor.attribute12                   Attribute12,
            bor.attribute13                   Attribute13,
            bor.attribute14                   Attribute14,
            bor.attribute15                   Attribute15,
            bor.original_system_reference     Original_System_Reference,
            'CREATE'                          Transaction_Type,
            NULL                              Return_Status,
            NULL                              Delete_Group_Name,
            NULL                              DG_Description,
            NULL                              ser_start_op_seq,
            NULL                              row_identifier
    FROM    bom_operational_routings bor,
            wip_lines wl,
            mtl_parameters org,
            mtl_system_items_kfv item1,
            mtl_system_items_kfv item2,
            mtl_item_locations_kfv locators
    WHERE   wl.line_id(+)                     = bor.line_id
    AND     org.organization_id               = bor.organization_id
    AND     item1.organization_id             = bor.organization_id
    AND     item1.inventory_item_id           = bor.assembly_item_id
    AND     item2.inventory_item_id(+)        = bor.common_assembly_item_id
    AND     item2.organization_id(+)          = bor.organization_id
    AND     locators.inventory_location_id(+) = bor.completion_locator_id
    AND     locators.organization_id      (+) = bor.organization_id
    AND     bor.organization_id               = p_model_org_id                  --myerrams, Filter Records based on Model Org Id
    --Order by bor.alternate_routing_designator desc, bor.assembly_item_id;	--myerrams, To copy Alternate Routings at the end.
    Order by decode(trim(alternate_routing_designator),null,'0','1')||decode(routing_sequence_id,common_routing_sequence_id,'1','2');
/* Modifying the order by clause Bug 6923784*/
---------------------------------Routing Revisions Cursor-----------------------------------------------

  CURSOR rtg_rev_CUR(P_assembly_item_name     VARCHAR2
                     ) IS
    SELECT item.concatenated_segments   Assembly_Item_Name,
           p_target_orgcode             Organization_Code,
           NULL                         Alternate_Routing_Code,
           rev.Process_Revision         Revision,
           rev.Effectivity_Date         Start_Effective_Date,
           rev.Attribute_category       Attribute_category,
           rev.Attribute1               Attribute1,
           rev.Attribute2               Attribute2,
           rev.Attribute3               Attribute3,
           rev.Attribute4               Attribute4,
           rev.Attribute5               Attribute5,
           rev.Attribute6               Attribute6,
           rev.Attribute7               Attribute7,
           rev.Attribute8               Attribute8,
           rev.Attribute9               Attribute9,
           rev.Attribute10              Attribute10,
           rev.Attribute11              Attribute11,
           rev.Attribute12              Attribute12,
           rev.Attribute13              Attribute13,
           rev.Attribute14              Attribute14,
           rev.Attribute15              Attribute15,
           NULL				Original_System_Reference,
           'CREATE'                     Transaction_Type,
           NULL                         Return_Status,
           NULL                         Row_Identifier
    FROM   mtl_rtg_item_revisions rev,
           mtl_parameters org,
           mtl_system_items_kfv item
    WHERE  org.organization_id = rev.organization_id
    AND    item.organization_id = rev.organization_id
    AND    item.inventory_item_id = rev.inventory_item_id
    AND    item.concatenated_segments = P_assembly_item_name
    AND    org.organization_id      =   p_model_org_id;                         --myerrams, Filter Records based on Model Org Id


---------------------------------Operation Sequences Cursor-----------------------------------------------

  CURSOR rtg_op_CUR(P_assembly_item_name     VARCHAR2,
                    P_alternate_routing_code VARCHAR2) IS
    SELECT item.concatenated_segments         Assembly_Item_Name,
           p_target_orgcode                   Organization_Code,
           rtg.alternate_routing_designator   Alternate_Routing_Code,
           op_seq.Operation_Seq_Num           Operation_Sequence_Number,
           op_seq.Operation_Type              Operation_Type,
           op_seq.Effectivity_Date            Start_Effective_Date,
           NULL				      New_Operation_Sequence_Number,
	   NULL				      New_Start_Effective_Date,
           op_seq.Standard_Operation_Code     Standard_Operation_Code,
           op_seq.Department_Code             Department_Code,
           op_seq.Operation_Lead_Time_Percent Op_Lead_Time_Percent,
           op_seq.Minimum_Transfer_Quantity   Minimum_Transfer_Quantity,
           op_seq.Count_Point_Type            Count_Point_Type,
           op_seq.Operation_Description       Operation_Description,
           op_seq.Disable_Date                Disable_Date,
           op_seq.Backflush_Flag              Backflush_Flag,
           op_seq.Option_Dependent_Flag       Option_Dependent_Flag,
           op_seq.Reference_Flag              Reference_Flag,
           op_seq.Process_Seq_Num             Process_Seq_Number,
           op_seq.Process_Code                Process_Code,
           op_seq.Line_Op_Seq_Num             Line_Op_Seq_Number,
           op_seq.Line_Op_Code                Line_Op_Code,
           op_seq.Yield                       Yield,
           op_seq.Cumulative_Yield            Cumulative_Yield,
           op_seq.Reverse_Cumulative_Yield    Reverse_CUM_Yield,
           op_seq.Labor_Time_User             User_Labor_Time,
           op_seq.Machine_Time_User           User_Machine_Time,
           op_seq.Net_Planning_Percent        Net_Planning_Percent,
           op_seq.Include_In_Rollup           Include_In_Rollup,
           op_seq.Operation_Yield_Enabled     Op_Yield_Enabled_Flag,
           op_seq.SHUTDOWN_TYPE               Shutdown_Type,
           op_seq.Attribute_category          Attribute_category,
           op_seq.Attribute1                  Attribute1,
           op_seq.Attribute2                  Attribute2,
           op_seq.Attribute3                  Attribute3,
           op_seq.Attribute4                  Attribute4,
           op_seq.Attribute5                  Attribute5,
           op_seq.Attribute6                  Attribute6,
           op_seq.Attribute7                  Attribute7,
           op_seq.Attribute8                  Attribute8,
           op_seq.Attribute9                  Attribute9,
           op_seq.Attribute10                 Attribute10,
           op_seq.Attribute11                 Attribute11,
           op_seq.Attribute12                 Attribute12,
           op_seq.Attribute13                 Attribute13,
           op_seq.Attribute14                 Attribute14,
           op_seq.Attribute15                 Attribute15,
           op_seq.Original_System_Reference   Original_System_Reference,
           'CREATE'                           Transaction_Type,
           NULL                               Return_Status,
           NULL                               Delete_Group_Name,
           NULL                               DG_Description,
           NULL                               Long_Description,
           NULL                               Row_Identifier
   FROM    bom_operation_sequences_v op_seq,
           bom_operational_routings rtg,
           mtl_parameters org,
           mtl_system_items_kfv item
   WHERE   rtg.routing_sequence_id = op_seq.routing_sequence_id
   AND     org.organization_id     = rtg.organization_id
   AND     item.organization_id    = rtg.organization_id
   AND     item.inventory_item_id  = rtg.assembly_item_id
   AND     item.concatenated_segments    = P_assembly_item_name
   AND     NVL(rtg.alternate_routing_designator,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
   AND     org.Organization_id     = p_model_org_id;                            --myerrams, Filter Records based on Model Org Id


---------------------------------Operation Resources Cursor-----------------------------------------------

  CURSOR rtg_op_res_CUR (P_assembly_item_name     VARCHAR2,
                         P_alternate_routing_code VARCHAR2) IS
    SELECT item.concatenated_segments       Assembly_Item_Name,
           p_target_orgcode                 Organization_Code,
           rtg.alternate_routing_designator Alternate_Routing_Code,
           op_seq.operation_seq_num         Operation_Sequence_Number,
           op_seq.operation_type            Operation_Type,
           op_seq.effectivity_date          Op_Start_Effective_Date,
           bor.Resource_Seq_Num             Resource_Sequence_Number,
           br.Resource_Code                 Resource_Code,
           ca.Activity                      Activity,
           bor.Standard_Rate_Flag           Standard_Rate_Flag,
           bor.Assigned_Units               Assigned_Units,
           bor.Usage_Rate_Or_amount         Usage_Rate_Or_Amount,
           bor.Usage_Rate_Or_Amount_Inverse Usage_Rate_Or_Amount_Inverse,
           bor.Basis_Type                   Basis_Type,
           bor.Schedule_Flag                Schedule_Flag,
           bor.Resource_Offset_Percent      Resource_Offset_Percent,
           bor.Autocharge_Type              Autocharge_Type,
           bor.Substitute_Group_Num         Substitute_Group_Number,
           bor.Schedule_Seq_Num             Schedule_Sequence_Number,
           bor.Principle_Flag               Principle_Flag,
           bor.Attribute_category           Attribute_category,
           bor.Attribute1                   Attribute1,
           bor.Attribute2                   Attribute2,
           bor.Attribute3                   Attribute3,
           bor.Attribute4                   Attribute4,
           bor.Attribute5                   Attribute5,
           bor.Attribute6                   Attribute6,
           bor.Attribute7                   Attribute7,
           bor.Attribute8                   Attribute8,
           bor.Attribute9                   Attribute9,
           bor.Attribute10                  Attribute10,
           bor.Attribute11                  Attribute11,
           bor.Attribute12                  Attribute12,
           bor.Attribute13                  Attribute13,
           bor.Attribute14                  Attribute14,
           bor.Attribute15                  Attribute15,
           NULL				    Original_System_Reference,
           'CREATE'                         Transaction_Type,
           NULL                             Return_Status,
           bst.Setup_Code                   Setup_Type,
           NULL                             Row_Identifier
    FROM   bom_operation_resources bor,
           bom_resources br,
           cst_activities ca,
           bom_setup_types bst,
           bom_operation_sequences op_seq,
           bom_operational_routings rtg,
           mtl_system_items_kfv item,
           mtl_parameters org
    WHERE  op_seq.operation_sequence_id = bor.operation_sequence_id
    AND    rtg.routing_sequence_id      = op_seq.routing_sequence_id
    AND    org.organization_id          = rtg.organization_id
    AND    item.organization_id         = rtg.organization_id
    AND    item.inventory_item_id       = rtg.assembly_item_id
    AND    br.resource_id               = bor.resource_id
    AND    ca.activity_id(+)            = bor.activity_id
    AND    bst.setup_id(+)              = bor.setup_id
    AND    item.concatenated_segments   = P_assembly_item_name
    AND    NVL(rtg.alternate_routing_designator,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    org.Organization_id     = p_model_org_id;                            --myerrams, Filter Records based on Model Org Id


---------------------------------Substitute Operation Resources Cursor-----------------------------------------------

  CURSOR rtg_sub_op_res_CUR(P_assembly_item_name     VARCHAR2,
                            P_alternate_routing_code VARCHAR2) IS
    SELECT  item.concatenated_segments        Assembly_Item_Name,
            p_target_orgcode                  Organization_Code,
            rtg.alternate_routing_designator  Alternate_Routing_Code,
            op_seq.operation_seq_num          Operation_Sequence_Number,
            op_seq.operation_type             Operation_Type,
            op_seq.effectivity_date           Op_Start_Effective_Date,
            br.Resource_Code                  Sub_Resource_Code,
            null                              New_Sub_Resource_Code,
            bsor.substitute_group_num         Substitute_Group_Number,
            bsor.schedule_seq_num             Schedule_Sequence_Number,
            bsor.replacement_group_num        Replacement_Group_Number,
            TO_NUMBER(NULL)                   New_Replacement_Group_Number,
            ca.Activity                       Activity,
            bsor.Standard_Rate_Flag           Standard_Rate_Flag,
            bsor.Assigned_Units               Assigned_Units,
            bsor.Usage_Rate_Or_Amount         Usage_Rate_Or_Amount,
            bsor.Usage_Rate_Or_Amount_Inverse Usage_Rate_Or_Amount_Inverse,
            bsor.Basis_Type                   Basis_Type,
            TO_NUMBER(NULL)                   New_Basis_Type,
            bsor.Schedule_Flag                Schedule_Flag,
            TO_NUMBER(NULL)                   New_Schedule_Flag, --bug 13563553
            bsor.Resource_Offset_Percent      Resource_Offset_Percent,
            bsor.Autocharge_Type              Autocharge_Type,
            bsor.Principle_Flag               Principle_Flag,
            bsor.Attribute_category           Attribute_category,
            bsor.Attribute1                   Attribute1,
            bsor.Attribute2                   Attribute2,
            bsor.Attribute3                   Attribute3,
            bsor.Attribute4                   Attribute4,
            bsor.Attribute5                   Attribute5,
            bsor.Attribute6                   Attribute6,
            bsor.Attribute7                   Attribute7,
            bsor.Attribute8                   Attribute8,
            bsor.Attribute9                   Attribute9,
            bsor.Attribute10                  Attribute10,
            bsor.Attribute11                  Attribute11,
            bsor.Attribute12                  Attribute12,
            bsor.Attribute13                  Attribute13,
            bsor.Attribute14                  Attribute14,
            bsor.Attribute15                  Attribute15,
            bsor.original_system_reference    Original_System_Reference,
            'CREATE'                          Transaction_Type,
            NULL                              Return_Status,
            bst.setup_Code                    Setup_Type,
            NULL                              Row_Identifier
    FROM    bom_sub_operation_resources bsor,
            mtl_system_items_kfv item,
            mtl_parameters org,
            bom_operational_routings rtg,
            bom_operation_sequences op_seq,
            bom_resources br,
            cst_activities ca,
            bom_setup_types bst
    WHERE   op_seq.operation_sequence_id = bsor.operation_sequence_id
    AND     rtg.routing_sequence_id      = op_seq.routing_sequence_id
    AND     org.organization_id          = rtg.organization_id
    AND     item.organization_id         = rtg.organization_id
    AND     item.inventory_item_id       = rtg.assembly_item_id
    AND     br.resource_id               = bsor.resource_id
    AND     ca.activity_id(+)            = bsor.activity_id
    AND     bst.setup_id(+)              = bsor.setup_id
    AND    item.concatenated_segments   = P_assembly_item_name
    AND    NVL(rtg.alternate_routing_designator,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    org.Organization_id     = p_model_org_id;                            --myerrams, Filter Records based on Model Org Id


---------------------------------Operation Networks Cursor-----------------------------------------------

-- BOM_OPERATION_NETWORKS
--      From_Op_Seq_Id
--      To_Op_Seq_Id

  CURSOR rtg_op_networks_CUR(P_assembly_item_name     VARCHAR2,
                             P_alternate_routing_code VARCHAR2) IS
    SELECT item.concatenated_segments         Assembly_Item_Name,
           p_target_orgcode                   Organization_Code,
           rtg.alternate_routing_designator   Alternate_Routing_Code,
           bonv.operation_type                Operation_Type,
           bonv.From_Seq_Num                  From_Op_Seq_Number,
           bos1.X_Coordinate                  From_X_Coordinate,
           bos1.Y_Coordinate                  From_Y_Coordinate,
           bonv.From_Effectivity_Date         From_Start_Effective_Date,
           bonv.To_Seq_Num                    To_Op_Seq_Number,
           bos2.X_Coordinate                  To_X_Coordinate,
           bos2.Y_Coordinate                  To_Y_Coordinate,
           bonv.To_Effectivity_Date           To_Start_Effective_Date,
           null                               New_From_Op_Seq_Number,
           null                               New_From_Start_Effective_Date,
           null                               New_To_Op_Seq_Number,
           null                               New_To_Start_Effective_Date,
           bonv.Transition_Type               Connection_Type,
           bonv.Planning_Pct                  Planning_Percent,
           bonv.Attribute_category            Attribute_category,
           bonv.Attribute1                    Attribute1,
           bonv.Attribute2                    Attribute2,
           bonv.Attribute3                    Attribute3,
           bonv.Attribute4                    Attribute4,
           bonv.Attribute5                    Attribute5,
           bonv.Attribute6                    Attribute6,
           bonv.Attribute7                    Attribute7,
           bonv.Attribute8                    Attribute8,
           bonv.Attribute9                    Attribute9,
           bonv.Attribute10                   Attribute10,
           bonv.Attribute11                   Attribute11,
           bonv.Attribute12                   Attribute12,
           bonv.Attribute13                   Attribute13,
           bonv.Attribute14                   Attribute14,
           bonv.Attribute15                   Attribute15,
           bonv.Original_System_Reference     Original_System_Reference,
           'CREATE'                           Transaction_Type,
           NULL                               Return_Status,
           NULL                               Row_Identifier
    FROM   bom_operation_networks_v bonv,
           bom_operation_sequences bos1,
           bom_operation_sequences bos2,
           bom_operational_routings rtg,
           mtl_system_items_kfv item,
           mtl_parameters org
    WHERE  rtg.routing_sequence_id    = bonv.routing_sequence_id
    AND    bos1.Operation_Sequence_Id = bonv.From_Op_Seq_Id
    AND    bos2.Operation_Sequence_Id = bonv.To_Op_Seq_Id
    AND    org.organization_id        = rtg.organization_id
    AND    item.organization_id       = rtg.organization_id
    AND    item.inventory_item_id     = rtg.assembly_item_id
    AND    item.concatenated_segments   = P_assembly_item_name
    AND    NVL(rtg.alternate_routing_designator,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    org.Organization_id     = p_model_org_id;                            --myerrams, Filter Records based on Model Org Id

---------------------------------End of Cursors Definitions-----------------------------------------------

  i NUMBER;
-- Following variables are used for logging messages
  l_message		VARCHAR2(2000) := NULL;
  l_entity		VARCHAR2(3)    := NULL;
  l_msg_index		NUMBER;
  l_message_type	VARCHAR2(1);

--myerrams, Following Variables are used for passing the Return Status to CopyLoader and to Log Assembly Item Name
  l_X_return_status	VARCHAR2(10);
  l_status_set		BOOLEAN := FALSE;
  l_Assembly_Item_Name  VARCHAR2(100);

--myerrams, Following Variables are used for Looping Logic
  l_hdr_cnt		NUMBER := 0;
  l_counter             NUMBER := 1;
  l_max_batch_size 	NUMBER := 200;
  l_min_index		NUMBER;
  l_max_index		NUMBER;

BEGIN

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || g_api_name || '.begin'
                  , NULL);
  END IF;

  /*myerrams, to make sure that Return Status is not null when the model org doesn't have any Routings to copy*/
  x_return_status := 'S';

--myerrams, To get the number of routings in Model org.
    SELECT COUNT(*)
    INTO   l_hdr_cnt
    FROM    bom_operational_routings bor,
            wip_lines wl,
            mtl_parameters org,
            mtl_system_items_kfv item1,
            mtl_system_items_kfv item2,
            mtl_item_locations_kfv locators
    WHERE   wl.line_id(+)                     = bor.line_id
    AND     org.organization_id               = bor.organization_id
    AND     item1.organization_id             = bor.organization_id
    AND     item1.inventory_item_id           = bor.assembly_item_id
    AND     item2.inventory_item_id(+)        = bor.common_assembly_item_id
    AND     item2.organization_id(+)          = bor.organization_id
    AND     locators.inventory_location_id(+) = bor.completion_locator_id
    AND     locators.organization_id      (+) = bor.organization_id
    AND     bor.organization_id               = p_model_org_id;

    l_min_index := 1;

    IF l_hdr_cnt > l_max_batch_size
    THEN
      l_max_index := l_max_batch_size;
    ELSE
      l_max_index := l_hdr_cnt;
    END IF;

  -- Routing Header Record
   l_rtg_header_tbl.DELETE;

   OPEN rtg_hdr_CUR;
   LOOP
   FETCH rtg_hdr_CUR BULK COLLECT INTO l_rtg_header_tbl LIMIT l_max_batch_size;
   l_counter := 1;


   FOR l_Idx IN l_min_index..l_max_index
   LOOP
     l_rtg_header_rec := l_rtg_header_tbl(l_counter);
     l_Assembly_Item_Name := l_rtg_header_rec.Assembly_Item_Name;

     l_rtg_revision_tbl.DELETE;
     l_operation_tbl.DELETE;
     l_op_resource_tbl.DELETE;
     l_sub_resource_tbl.DELETE;
     l_op_network_tbl.DELETE;

     OPEN rtg_rev_CUR(l_rtg_header_rec.Assembly_Item_Name);
     i := 1;
     LOOP
       FETCH rtg_rev_CUR INTO l_rtg_revision_tbl(i);
       IF (rtg_rev_CUR%NOTFOUND) THEN
         EXIT;
       END IF;
       i := i + 1;
     END LOOP;
     CLOSE rtg_rev_CUR;

     OPEN rtg_op_CUR(l_rtg_header_rec.Assembly_Item_Name,
                     l_rtg_header_rec.Alternate_Routing_Code);
     i := 1;
     LOOP
       FETCH rtg_op_CUR INTO l_operation_tbl(i);
       IF (rtg_op_CUR%NOTFOUND) THEN
         EXIT;
       END IF;
       i := i + 1;
     END LOOP;
     CLOSE rtg_op_CUR;

     OPEN rtg_op_res_CUR(l_rtg_header_rec.Assembly_Item_Name,
                         l_rtg_header_rec.Alternate_Routing_Code);
     i := 1;
     LOOP
       FETCH rtg_op_res_CUR INTO l_op_resource_tbl(i);
       IF (rtg_op_res_CUR%NOTFOUND) THEN
         EXIT;
       END IF;
       i := i + 1;
     END LOOP;
     CLOSE rtg_op_res_CUR;
     OPEN rtg_sub_op_res_CUR(l_rtg_header_rec.Assembly_Item_Name,
                             l_rtg_header_rec.Alternate_Routing_Code);
     i := 1;
     LOOP
       FETCH rtg_sub_op_res_CUR INTO l_sub_resource_tbl(i);
       IF (rtg_sub_op_res_CUR%NOTFOUND) THEN
         EXIT;
       END IF;
       i := i + 1;
     END LOOP;
     CLOSE rtg_sub_op_res_CUR;

     OPEN rtg_op_networks_CUR(l_rtg_header_rec.Assembly_Item_Name,
                              l_rtg_header_rec.Alternate_Routing_Code);
     i := 1;
     LOOP
       FETCH rtg_op_networks_CUR INTO l_op_network_tbl(i);
       IF (rtg_op_networks_CUR%NOTFOUND) THEN
         EXIT;
       END IF;
       i := i + 1;
     END LOOP;
     CLOSE rtg_op_networks_CUR;
     BOM_GLOBALS.Set_Caller_Type('MIGRATION');
     ERROR_HANDLER.Initialize;
     BOM_RTG_PUB.Process_RTG(p_rtg_header_rec   => l_rtg_header_rec
                           , p_rtg_revision_tbl => l_rtg_revision_tbl
                           , p_operation_tbl    => l_operation_tbl
                           , p_op_resource_tbl  => l_op_resource_tbl
                           , p_sub_resource_tbl => l_sub_resource_tbl
                           , p_op_network_tbl   => l_op_network_tbl
                           , p_debug            => P_debug
                           , p_output_dir       => P_output_dir
                           , p_debug_filename   => P_debug_filename
                           , x_rtg_header_rec   => X_rtg_header_rec
                           , x_rtg_revision_tbl => X_rtg_revision_tbl
                           , x_operation_tbl    => X_operation_tbl
                           , x_op_resource_tbl  => X_op_resource_tbl
                           , x_sub_resource_tbl => X_sub_resource_tbl
                           , x_op_network_tbl   => X_op_network_tbl
                           , x_return_status    => l_X_return_status
                           , x_msg_count        => X_msg_count);

--myerrams, Bug: 5493353; Delete the successfully processed records after the
--call to BOM_RTG_PUB.Process_RTG to reduce the memory consumed by the process
X_rtg_revision_tbl.DELETE;
X_operation_tbl.DELETE;
X_op_resource_tbl.DELETE;
X_sub_resource_tbl.DELETE;
X_op_network_tbl.DELETE;

commit;

IF (l_X_return_status <> 'S' and l_status_set = FALSE) THEN
   X_return_status := l_X_return_status;
   l_status_set := TRUE;
END IF;

IF (l_X_return_status = 'U' and X_return_status <> 'U') THEN
   X_return_status := l_X_return_status;
END IF;

     FOR i IN 1..X_msg_count LOOP
     BEGIN
       ERROR_HANDLER.Get_Message(x_entity_index => l_msg_index,
                                 x_entity_id    => l_entity,
                                 x_message_text => l_message,
                                 x_message_type => l_message_type);

       IF g_fnd_debug = 'Y' AND
	FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
	FND_LOG.string( FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || g_api_name
                  , TO_CHAR(l_msg_index) || ': '||l_entity ||': '|| l_message_type ||': '||l_message);
       END IF;

     EXCEPTION
       WHEN OTHERS THEN

        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
         FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                  , G_MODULE_PREFIX || g_api_name
                  , SQLCODE||'  :  '||SQLERRM || ' Item: ' || l_Assembly_Item_Name);
        END IF;

	X_G_msg_data	:= X_G_msg_data || FND_GLOBAL.NewLine || SQLCODE ||'  :  ' || SQLERRM || FND_GLOBAL.NewLine || ' Item: ' || l_Assembly_Item_Name ;
        X_return_status := 'U';

	EXIT;
     END;
     END LOOP;	--Close X_msg_count LOOP

     IF(X_msg_count > 0 ) THEN

       IF g_fnd_debug = 'Y' AND
	FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
       THEN
	FND_LOG.string( FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || g_api_name
                  ,  'X_return_status for Item:' || l_Assembly_Item_Name || ' is: ' || l_X_return_status);
       END IF;

     END IF;

     l_counter := l_counter + 1;
     END LOOP; --Close l_min_index..l_max_index LOOP

      l_min_index := l_max_index + 1;
      IF l_hdr_cnt > (l_max_index + l_max_batch_size)
      THEN
        l_max_index := l_max_index + l_max_batch_size;
      ELSE
        l_max_index := l_hdr_cnt;
      END IF;

        EXIT WHEN rtg_hdr_CUR%NOTFOUND;
        END LOOP;
      CLOSE rtg_hdr_CUR;

   IF (l_hdr_cnt = 0) THEN  -- There are no records to be processed. RETURN with Error Message
     FND_MESSAGE.SET_NAME('BOM', 'BOM_SETUP_NO_ROWS');
     FND_MESSAGE.RETRIEVE(X_G_msg_data);
   END IF;

  X_G_msg_data := X_G_msg_data || FND_GLOBAL.NewLine || 'Log messages are logged in FND LOG with Module name: bom.plsql.BOM_RTG_COPYORG_IMP.';

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || g_api_name || '.end'
                  , NULL);
  END IF;

END Import_Routing;

END BOM_RTG_COPYORG_IMP;

/
