--------------------------------------------------------
--  DDL for Package Body BOM_RTG_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_EXP" AS
/* $Header: BOMREXPB.pls 115.1 2002/12/16 21:13:01 lnarveka noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBREXPB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_EXP
--
--  NOTES
--
--  HISTORY
--
--  06-OCT-02   M V M P Tilak    Initial Creation
***************************************************************************/

G_rtg_header_rec   BOM_RTG_PUB.RTG_HEADER_REC_TYPE;
G_rtg_revision_tbl BOM_RTG_PUB.RTG_REVISION_TBL_TYPE;
G_operation_tbl    BOM_RTG_PUB.OPERATION_TBL_TYPE;
G_op_resource_tbl  BOM_RTG_PUB.OP_RESOURCE_TBL_TYPE;
G_sub_resource_tbl BOM_RTG_PUB.SUB_RESOURCE_TBL_TYPE;
G_op_network_tbl   BOM_RTG_PUB.OP_NETWORK_TBL_TYPE;

PROCEDURE Populate_Header(P_organization_code            IN VARCHAR2,
                          P_organization_id              IN NUMBER,
                          P_assembly_item_name           IN VARCHAR2,
                          P_item_id                      IN NUMBER,
                          P_alternate_routing_designator IN VARCHAR2,
                          X_routing_sequence_id          OUT NOCOPY NUMBER)
IS
  CURSOR Routing_Header_CUR IS
    SELECT   bor.routing_sequence_id,
             bor.routing_type, -- Eng_Routing_Flag
             bor.common_assembly_item_id, --Common_Assembly_Item_Name
             bor.routing_comment,
             bor.completion_subinventory,
             bor.completion_locator_id, -- Completion_Location_Name
	     wl.line_code,
	     bor.cfm_Routing_Flag,
             bor.mixed_model_map_flag,
             bor.priority,
	     bor.total_product_cycle_time, -- Total_Cycle_Time
             bor.ctp_flag,
             bor.attribute_category,
             bor.attribute1,
             bor.attribute2,
             bor.attribute3,
             bor.attribute4,
             bor.attribute5,
             bor.attribute6,
             bor.attribute7,
             bor.attribute8,
             bor.attribute9,
             bor.attribute10,
             bor.attribute11,
             bor.attribute12,
             bor.attribute13,
             bor.attribute14,
             bor.attribute15,
             bor.original_system_reference
	     --, bor.serialization_start_op
	   FROM    bom_operational_routings bor,
             wip_lines wl
	   WHERE   bor.organization_id  = P_organization_id
     AND     bor.assembly_item_id = P_item_id
     AND     NVL(bor.alternate_routing_designator,'##$$##') = NVL(P_alternate_routing_designator,'##$$##')
     AND     wl.line_id(+)        = bor.line_id;

  l_rtg_hdr_rec Routing_Header_CUR%ROWTYPE;
  l_common_assembly_item_name MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
  l_completion_location_name  MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
BEGIN
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Header Entered. ');
  END IF;
  OPEN Routing_Header_CUR;
  FETCH Routing_Header_CUR INTO l_rtg_hdr_rec;
  IF (Routing_Header_CUR%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;
  l_common_assembly_item_name := BOM_RTG_EXP_UTIL.Get_Item_Name(l_rtg_hdr_rec.common_assembly_item_id);
  l_completion_location_name  := BOM_RTG_EXP_UTIL.Get_Location_Name(l_rtg_hdr_rec.completion_locator_id,
                                                                   P_organization_id);
  G_Rtg_Header_Rec.assembly_item_name        := P_assembly_item_name;
  G_Rtg_Header_Rec.organization_code         := P_organization_code;
  G_Rtg_Header_Rec.Alternate_Routing_Code    := P_alternate_routing_designator;
  G_Rtg_Header_Rec.Eng_Routing_Flag          := l_rtg_hdr_rec.routing_type;
  G_Rtg_Header_Rec.common_assembly_item_name := l_common_assembly_item_name;
  G_Rtg_Header_Rec.routing_comment           := l_rtg_hdr_rec.routing_comment;
  G_Rtg_Header_Rec.completion_subinventory   := l_rtg_hdr_rec.completion_subinventory;
  G_Rtg_Header_Rec.completion_location_name  := l_completion_location_name;
  G_Rtg_Header_Rec.line_code                 := l_rtg_hdr_rec.line_code;
  G_Rtg_Header_Rec.cfm_routing_flag          := l_rtg_hdr_rec.cfm_routing_flag;
  G_Rtg_Header_Rec.mixed_model_map_flag      := l_rtg_hdr_rec.mixed_model_map_flag;
  G_Rtg_Header_Rec.priority                  := l_rtg_hdr_rec.priority;
  G_Rtg_Header_Rec.total_cycle_time          := l_rtg_hdr_rec.total_product_cycle_time;
  G_Rtg_Header_Rec.ctp_flag                  := l_rtg_hdr_rec.ctp_flag;
  G_Rtg_Header_Rec.attribute_category        := l_rtg_hdr_rec.attribute_category;
  G_Rtg_Header_Rec.attribute1                := l_rtg_hdr_rec.attribute1;
  G_Rtg_Header_Rec.attribute2                := l_rtg_hdr_rec.attribute2;
  G_Rtg_Header_Rec.attribute3                := l_rtg_hdr_rec.attribute3;
  G_Rtg_Header_Rec.attribute4                := l_rtg_hdr_rec.attribute4;
  G_Rtg_Header_Rec.attribute5                := l_rtg_hdr_rec.attribute5;
  G_Rtg_Header_Rec.attribute6                := l_rtg_hdr_rec.attribute6;
  G_Rtg_Header_Rec.attribute7                := l_rtg_hdr_rec.attribute7;
  G_Rtg_Header_Rec.attribute8                := l_rtg_hdr_rec.attribute8;
  G_Rtg_Header_Rec.attribute9                := l_rtg_hdr_rec.attribute9;
  G_Rtg_Header_Rec.attribute10               := l_rtg_hdr_rec.attribute10;
  G_Rtg_Header_Rec.attribute11               := l_rtg_hdr_rec.attribute11;
  G_Rtg_Header_Rec.attribute12               := l_rtg_hdr_rec.attribute12;
  G_Rtg_Header_Rec.attribute13               := l_rtg_hdr_rec.attribute13;
  G_Rtg_Header_Rec.attribute14               := l_rtg_hdr_rec.attribute14;
  G_Rtg_Header_Rec.attribute15               := l_rtg_hdr_rec.attribute15;
  G_Rtg_Header_Rec.original_system_reference := l_rtg_hdr_rec.original_system_reference;
--  G_Rtg_Header_Rec.Ser_Start_Op_Seq	     := l_rtg_hdr_rec.serialization_start_op;
  X_routing_sequence_id := l_rtg_hdr_rec.routing_sequence_id;

  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Header: One Routing Header record fetched. ');
  END IF;
END Populate_Header;


PROCEDURE Populate_Revision(P_organization_code  IN VARCHAR2,
                            P_organization_id    IN NUMBER,
                            P_assembly_item_name IN VARCHAR2,
                            P_item_id            IN NUMBER,
                            P_alt_rtg_code       IN VARCHAR2) IS
  CURSOR Routing_Revision_CUR IS
    SELECT Process_Revision,
           Effectivity_Date,
           Attribute_category,
           Attribute1,
           Attribute2,
           Attribute3,
           Attribute4,
           Attribute5,
           Attribute6,
           Attribute7,
           Attribute8,
           Attribute9,
           Attribute10,
           Attribute11,
           Attribute12,
           Attribute13,
           Attribute14,
           Attribute15
    FROM   mtl_rtg_item_revisions
    WHERE  inventory_item_id = p_item_id
    AND    organization_id   = p_organization_id;
  i NUMBER := 1;
BEGIN
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Revision entered.');
  END IF;
  FOR revision_rec IN Routing_Revision_CUR LOOP
    G_rtg_revision_tbl(i).assembly_item_name   := P_assembly_item_name;
    G_rtg_revision_tbl(i).organization_code    := P_organization_code;
    G_rtg_revision_tbl(i).alternate_routing_code := P_alt_rtg_code;
    G_rtg_revision_tbl(i).revision             := revision_rec.process_revision;
    G_rtg_revision_tbl(i).start_effective_date := revision_rec.effectivity_date;
    G_rtg_revision_tbl(i).attribute_category   := revision_rec.attribute_category;
    G_rtg_revision_tbl(i).attribute1           := revision_rec.attribute1;
    G_rtg_revision_tbl(i).attribute2           := revision_rec.attribute2;
    G_rtg_revision_tbl(i).attribute3           := revision_rec.attribute3;
    G_rtg_revision_tbl(i).attribute4           := revision_rec.attribute4;
    G_rtg_revision_tbl(i).attribute5           := revision_rec.attribute5;
    G_rtg_revision_tbl(i).attribute6           := revision_rec.attribute6;
    G_rtg_revision_tbl(i).attribute7           := revision_rec.attribute7;
    G_rtg_revision_tbl(i).attribute8           := revision_rec.attribute8;
    G_rtg_revision_tbl(i).attribute9           := revision_rec.attribute9;
    G_rtg_revision_tbl(i).attribute10          := revision_rec.attribute10;
    G_rtg_revision_tbl(i).attribute11          := revision_rec.attribute11;
    G_rtg_revision_tbl(i).attribute12          := revision_rec.attribute12;
    G_rtg_revision_tbl(i).attribute13          := revision_rec.attribute13;
    G_rtg_revision_tbl(i).attribute14          := revision_rec.attribute14;
    G_rtg_revision_tbl(i).attribute15          := revision_rec.attribute15;
    i := i + 1;
  END LOOP;
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Revision: '||to_char(G_rtg_revision_tbl.COUNT)||' Routing Revision record(s) fetched.');
  END IF;
END Populate_Revision;


PROCEDURE Populate_Sub_Oper_Res(P_organization_code         IN VARCHAR2,
                                P_assembly_item_name        IN VARCHAR2,
                                P_alt_rtg_code              IN VARCHAR2,
                                P_operation_sequence_number IN NUMBER,
                                P_operation_type            IN NUMBER,
                                P_effectivity_date          IN DATE,
                                P_operation_sequence_id     IN NUMBER,
                                P_schedule_seq_num          IN NUMBER) IS
  CURSOR Sub_Oper_Res_CUR IS
    SELECT  br.Resource_Code, -- Sub_Resource_Code
            bsor.replacement_group_num, -- Replacement_Group_Number
            ca.Activity,
            bsor.Standard_Rate_Flag,
            bsor.Assigned_Units,
            bsor.Usage_Rate_Or_Amount,
            bsor.Usage_Rate_Or_Amount_Inverse,
            bsor.Basis_Type,
            bsor.Schedule_Flag,
            bsor.Resource_Offset_Percent,
            bsor.Autocharge_Type,
            bsor.Principle_Flag,
            bsor.Attribute_category,
            bsor.Attribute1,
            bsor.Attribute2,
            bsor.Attribute3,
            bsor.Attribute4,
            bsor.Attribute5,
            bsor.Attribute6,
            bsor.Attribute7,
            bsor.Attribute8,
            bsor.Attribute9,
            bsor.Attribute10,
            bsor.Attribute11,
            bsor.Attribute12,
            bsor.Attribute13,
            bsor.Attribute14,
            bsor.Attribute15,
	    bst.setup_Code  -- Setup_Type
    FROM    bom_sub_operation_resources bsor,
            bom_resources br,
            cst_activities ca,
            bom_setup_types bst
    WHERE   bsor.operation_sequence_id = P_operation_sequence_id
    AND     bsor.schedule_seq_num      = P_schedule_seq_num
    AND     br.resource_id             = bsor.resource_id
    AND     ca.activity_id(+)          = bsor.activity_id
    AND     bst.setup_id(+)            = bsor.setup_id;
  i NUMBER;
  j NUMBER := 0;
BEGIN
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Sub_Oper_Res entered.');
    Error_Handler.Write_Debug('Operation Sequence Number: '|| TO_CHAR(P_operation_sequence_number));
    Error_Handler.Write_Debug('Operation Type           : '|| TO_CHAR(P_operation_type));
    Error_Handler.Write_Debug('Effectivity Date         : '|| TO_CHAR(P_effectivity_date));
    Error_Handler.Write_Debug('Schedule Sequence Number : '|| TO_CHAR(P_schedule_seq_num));
    j := G_Sub_Resource_Tbl.COUNT;
  END IF;
  i := G_Sub_Resource_Tbl.LAST + 1;
  IF (i IS NULL) THEN
    i := 1;
  END IF;
  FOR sub_resource_rec IN sub_oper_res_CUR LOOP
    G_sub_resource_tbl(i).assembly_item_name           := P_assembly_item_name;
    G_sub_resource_tbl(i).organization_code            := P_organization_code;
    G_sub_resource_tbl(i).alternate_routing_code       := P_alt_rtg_code;
    G_sub_resource_tbl(i).operation_sequence_number    := P_operation_sequence_number;
    G_sub_resource_tbl(i).operation_type               := P_operation_type;
    G_sub_resource_tbl(i).op_start_effective_date      := P_effectivity_date;
    G_sub_resource_tbl(i).schedule_sequence_number     := P_schedule_seq_num;
    G_sub_resource_tbl(i).sub_resource_code            := sub_resource_rec.resource_code;
    G_sub_resource_tbl(i).replacement_group_number     := sub_resource_rec.replacement_group_num;
    G_sub_resource_tbl(i).activity                     := sub_resource_rec.activity;
    G_sub_resource_tbl(i).standard_rate_flag           := sub_resource_rec.standard_rate_flag;
    G_sub_resource_tbl(i).assigned_units               := sub_resource_rec.assigned_units;
    G_sub_resource_tbl(i).usage_rate_or_amount         := sub_resource_rec.usage_rate_or_amount;
    G_sub_resource_tbl(i).usage_rate_or_amount_inverse := sub_resource_rec.usage_rate_or_amount_inverse;
    G_sub_resource_tbl(i).basis_type                   := sub_resource_rec.basis_type;
    G_sub_resource_tbl(i).schedule_flag                := sub_resource_rec.schedule_flag;
    G_sub_resource_tbl(i).resource_offset_percent      := sub_resource_rec.resource_offset_percent;
    G_sub_resource_tbl(i).autocharge_type              := sub_resource_rec.autocharge_type;
    G_sub_resource_tbl(i).principle_flag               := sub_resource_rec.principle_flag;
    G_sub_resource_tbl(i).attribute_category           := sub_resource_rec.attribute_category;
    G_sub_resource_tbl(i).attribute1                   := sub_resource_rec.attribute1;
    G_sub_resource_tbl(i).attribute2                   := sub_resource_rec.attribute2;
    G_sub_resource_tbl(i).attribute3                   := sub_resource_rec.attribute3;
    G_sub_resource_tbl(i).attribute4                   := sub_resource_rec.attribute4;
    G_sub_resource_tbl(i).attribute5                   := sub_resource_rec.attribute5;
    G_sub_resource_tbl(i).attribute6                   := sub_resource_rec.attribute6;
    G_sub_resource_tbl(i).attribute7                   := sub_resource_rec.attribute7;
    G_sub_resource_tbl(i).attribute8                   := sub_resource_rec.attribute8;
    G_sub_resource_tbl(i).attribute9                   := sub_resource_rec.attribute9;
    G_sub_resource_tbl(i).attribute10                  := sub_resource_rec.attribute10;
    G_sub_resource_tbl(i).attribute11                  := sub_resource_rec.attribute11;
    G_sub_resource_tbl(i).attribute12                  := sub_resource_rec.attribute12;
    G_sub_resource_tbl(i).attribute13                  := sub_resource_rec.attribute13;
    G_sub_resource_tbl(i).attribute14                  := sub_resource_rec.attribute14;
    G_sub_resource_tbl(i).attribute15                  := sub_resource_rec.attribute15;
    G_sub_resource_tbl(i).setup_type                   := sub_resource_rec.setup_code;
    i := i + 1;
  END LOOP;
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Sub_Oper_Res: '||TO_CHAR(G_sub_resource_tbl.COUNT - j)||' record(s) fetched.');
  END IF;
END Populate_Sub_Oper_Res;

PROCEDURE Populate_Oper_Resources(P_organization_code     IN VARCHAR2,
                                  P_assembly_item_name    IN VARCHAR2,
                                  P_alt_rtg_code          IN VARCHAR2,
                                  P_operation_sequence_id IN NUMBER,
                                  P_operation_seq_num     IN NUMBER,
                                  P_operation_type        IN VARCHAR2,
                                  P_effectivity_date      IN DATE) IS
  CURSOR Routing_Oper_Resources_CUR IS
    SELECT bor.Resource_Seq_Num, -- Resource_Sequence_Number
           br.Resource_Code,
           ca.Activity,
           bor.Standard_Rate_Flag,
           bor.Assigned_Units,
           bor.Usage_Rate_Or_amount,
           bor.Usage_Rate_Or_Amount_Inverse,
           bor.Basis_Type,
           bor.Schedule_Flag,
           bor.Resource_Offset_Percent,
           bor.Autocharge_Type,
           bor.Schedule_Seq_Num, -- Schedule_Sequence_Number
           bor.Principle_Flag,
           bor.Attribute_category,
           bor.Attribute1,
           bor.Attribute2,
           bor.Attribute3,
           bor.Attribute4,
           bor.Attribute5,
           bor.Attribute6,
           bor.Attribute7,
           bor.Attribute8,
           bor.Attribute9,
           bor.Attribute10,
           bor.Attribute11,
           bor.Attribute12,
           bor.Attribute13,
           bor.Attribute14,
           bor.Attribute15,
           bst.Setup_Code  --  Setup_Type
    FROM   bom_operation_resources bor,
           bom_resources br,
           cst_activities ca,
           bom_setup_types bst
    WHERE  bor.operation_sequence_id = P_operation_sequence_id
    AND    br.resource_id            = bor.resource_id
    AND    ca.activity_id(+)         = bor.activity_id
    AND    bst.setup_id(+)           = bor.setup_id
    ORDER BY
           bor.schedule_seq_num;
  i NUMBER;
  j NUMBER;
  l_schedule_seq_num NUMBER;
BEGIN
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Oper_Resources entered.');
    Error_Handler.Write_Debug('Operation Sequence Number: '|| TO_CHAR(P_operation_seq_num));
    Error_Handler.Write_Debug('Operation Type           : '|| P_operation_type);
    Error_Handler.Write_Debug('Effectivity Date         : '|| to_char(P_effectivity_date));
    j := G_op_resource_tbl.COUNT;
  END IF;
  i := G_op_resource_tbl.LAST + 1;
  IF (i IS NULL) THEN
    i := 1;
  END IF;
  FOR oper_res_rec IN Routing_oper_resources_CUR LOOP
    G_op_resource_tbl(i).assembly_item_name           := P_assembly_item_name;
    G_op_resource_tbl(i).organization_code            := P_organization_code;
    G_op_resource_tbl(i).alternate_routing_code       := P_alt_rtg_code;
    G_op_resource_tbl(i).operation_sequence_number    := P_operation_seq_num;
    G_op_resource_tbl(i).operation_type               := P_operation_type;
    G_op_resource_tbl(i).op_start_effective_date      := P_effectivity_date;
    G_op_resource_tbl(i).resource_sequence_number     := oper_res_rec.resource_seq_num;
    G_op_resource_tbl(i).resource_code                := oper_res_rec.resource_code;
    G_op_resource_tbl(i).activity                     := oper_res_rec.activity;
    G_op_resource_tbl(i).standard_rate_flag           := oper_res_rec.standard_rate_flag;
    G_op_resource_tbl(i).assigned_units               := oper_res_rec.assigned_units;
    G_op_resource_tbl(i).usage_rate_or_amount         := oper_res_rec.usage_rate_or_amount;
    G_op_resource_tbl(i).usage_rate_or_amount_inverse := oper_res_rec.usage_rate_or_amount_inverse;
    G_op_resource_tbl(i).basis_type                   := oper_res_rec.basis_type;
    G_op_resource_tbl(i).schedule_flag                := oper_res_rec.schedule_flag;
    G_op_resource_tbl(i).resource_offset_percent      := oper_res_rec.resource_offset_percent;
    G_op_resource_tbl(i).autocharge_type              := oper_res_rec.autocharge_type;
    G_op_resource_tbl(i).schedule_sequence_number     := oper_res_rec.schedule_seq_num;
    G_op_resource_tbl(i).principle_flag               := oper_res_rec.principle_flag;
    G_op_resource_tbl(i).attribute_category           := oper_res_rec.attribute_category;
    G_op_resource_tbl(i).attribute1                   := oper_res_rec.attribute1;
    G_op_resource_tbl(i).attribute2                   := oper_res_rec.attribute2;
    G_op_resource_tbl(i).attribute3                   := oper_res_rec.attribute3;
    G_op_resource_tbl(i).attribute4                   := oper_res_rec.attribute4;
    G_op_resource_tbl(i).attribute5                   := oper_res_rec.attribute5;
    G_op_resource_tbl(i).attribute6                   := oper_res_rec.attribute6;
    G_op_resource_tbl(i).attribute7                   := oper_res_rec.attribute7;
    G_op_resource_tbl(i).attribute8                   := oper_res_rec.attribute8;
    G_op_resource_tbl(i).attribute9                   := oper_res_rec.attribute9;
    G_op_resource_tbl(i).attribute10                  := oper_res_rec.attribute10;
    G_op_resource_tbl(i).attribute11                  := oper_res_rec.attribute11;
    G_op_resource_tbl(i).attribute12                  := oper_res_rec.attribute12;
    G_op_resource_tbl(i).attribute13                  := oper_res_rec.attribute13;
    G_op_resource_tbl(i).attribute14                  := oper_res_rec.attribute14;
    G_op_resource_tbl(i).attribute15                  := oper_res_rec.attribute15;
    G_op_resource_tbl(i).setup_type                   := oper_res_rec.setup_code;
    IF (l_schedule_seq_num IS NULL OR
        l_schedule_seq_num <> oper_res_rec.schedule_seq_num) THEN
      l_schedule_seq_num := oper_res_rec.schedule_seq_num;
      Populate_Sub_Oper_Res(P_organization_code => P_organization_code,
                            P_assembly_item_name => P_assembly_item_name,
                            P_alt_rtg_code => P_alt_rtg_code,
                            P_operation_sequence_number => P_operation_seq_num,
                            P_operation_type => P_operation_type,
                            P_effectivity_date => P_effectivity_date,
                            P_operation_sequence_id => P_operation_sequence_id,
                            P_schedule_seq_num => l_schedule_seq_num);
/*
      Populate_Sub_Oper_Res(P_organization_code,
                            P_assembly_item_name,
                            P_alt_rtg_code,
                            P_operation_seq_num,
                            P_operation_type,
                            P_effectivity_date,
                            P_operation_sequence_id,
                            l_schedule_seq_num);
*/
    END IF;
    i := i + 1;
  END LOOP;
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Sub_Oper_Res: '||to_char(g_op_resource_tbl.COUNT - j) ||' record(s) fetched. ');
  END IF;
END Populate_Oper_Resources;

PROCEDURE Populate_Operations(P_organization_code  IN VARCHAR2,
                              P_assembly_item_name IN VARCHAR2,
                              P_routing_seq_id     IN NUMBER,
                              P_alt_rtg_code       IN VARCHAR2) IS
  CURSOR Routing_Operation_CUR IS
    SELECT Operation_Seq_Num,
           operation_sequence_id,
           Operation_Type,
           Effectivity_Date,
           Standard_Operation_Code,
           Department_Code,
           Operation_Lead_Time_Percent,
           Minimum_Transfer_Quantity,
           Count_Point_Type,
           Operation_Description,
           Disable_Date,
           Backflush_Flag,
           Option_Dependent_Flag,
           Reference_Flag,
           Process_Seq_Num,
           Process_Code,
           Line_Op_Seq_Num,
           Line_Op_Code,
           Yield,
           Cumulative_Yield,
           Reverse_Cumulative_Yield,
           Labor_Time_User,
           Machine_Time_User,
           Total_Time_User,
           Net_Planning_Percent,
           Include_In_Rollup,
           Operation_Yield_Enabled,
           Attribute_category,
           Attribute1,
           Attribute2,
           Attribute3,
           Attribute4,
           Attribute5,
           Attribute6,
           Attribute7,
           Attribute8,
           Attribute9,
           Attribute10,
           Attribute11,
           Attribute12,
           Attribute13,
           Attribute14,
           Attribute15,
           Original_System_Reference
	   --,long_description
   FROM    bom_operation_sequences_v
   WHERE   routing_sequence_id = P_routing_seq_id;
  i NUMBER := 1;
  l_op_seq_id  NUMBER;
  l_op_seq_num NUMBER;
  l_op_type    NUMBER;
  l_eff_date   DATE;
BEGIN
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Operations entered.');
  END IF;
  FOR routing_oper_rec IN Routing_Operation_CUR LOOP
    G_operation_tbl(i).assembly_item_name        := P_assembly_item_name;
    G_operation_tbl(i).organization_code         := P_organization_code;
    G_operation_tbl(i).alternate_routing_code    := P_alt_rtg_code;
    G_operation_tbl(i).operation_sequence_number := routing_oper_rec.operation_seq_num;
    G_operation_tbl(i).operation_type            := routing_oper_rec.operation_type;
    G_operation_tbl(i).start_effective_date      := routing_oper_rec.effectivity_date;
    G_operation_tbl(i).standard_operation_code   := routing_oper_rec.standard_operation_code;
    G_operation_tbl(i).department_code           := routing_oper_rec.department_code;
    G_operation_tbl(i).op_lead_time_percent      := routing_oper_rec.operation_lead_time_percent;
    G_operation_tbl(i).minimum_transfer_quantity := routing_oper_rec.minimum_transfer_quantity;
    G_operation_tbl(i).count_point_type          := routing_oper_rec.count_point_type;
    G_operation_tbl(i).operation_description     := routing_oper_rec.operation_description;
    G_operation_tbl(i).disable_date              := routing_oper_rec.disable_date;
    G_operation_tbl(i).backflush_flag            := routing_oper_rec.backflush_flag;
    G_operation_tbl(i).option_dependent_flag     := routing_oper_rec.option_dependent_flag;
    G_operation_tbl(i).reference_flag            := routing_oper_rec.reference_flag;
    G_operation_tbl(i).process_seq_number        := routing_oper_rec.process_seq_num;
    G_operation_tbl(i).process_code              := routing_oper_rec.process_code;
    G_operation_tbl(i).line_op_seq_number        := routing_oper_rec.line_op_seq_num;
    G_operation_tbl(i).line_op_code              := routing_oper_rec.line_op_code;
    G_operation_tbl(i).yield                     := routing_oper_rec.yield;
    G_operation_tbl(i).cumulative_yield          := routing_oper_rec.cumulative_yield;
    G_operation_tbl(i).reverse_cum_yield         := routing_oper_rec.reverse_cumulative_yield;
    G_operation_tbl(i).user_labor_time           := routing_oper_rec.labor_time_user;
    G_operation_tbl(i).user_machine_time         := routing_oper_rec.machine_time_user;
    G_operation_tbl(i).net_planning_percent      := routing_oper_rec.net_planning_percent;
    G_operation_tbl(i).Include_In_Rollup         := routing_oper_rec.Include_In_Rollup;
    G_operation_tbl(i).Op_Yield_Enabled_Flag     := routing_oper_rec.Operation_Yield_Enabled;
    G_operation_tbl(i).attribute_category        := routing_oper_rec.attribute_category;
    G_operation_tbl(i).attribute1                := routing_oper_rec.attribute1;
    G_operation_tbl(i).attribute2                := routing_oper_rec.attribute2;
    G_operation_tbl(i).attribute3                := routing_oper_rec.attribute3;
    G_operation_tbl(i).attribute4                := routing_oper_rec.attribute4;
    G_operation_tbl(i).attribute5                := routing_oper_rec.attribute5;
    G_operation_tbl(i).attribute6                := routing_oper_rec.attribute6;
    G_operation_tbl(i).attribute7                := routing_oper_rec.attribute7;
    G_operation_tbl(i).attribute8                := routing_oper_rec.attribute8;
    G_operation_tbl(i).attribute9                := routing_oper_rec.attribute9;
    G_operation_tbl(i).attribute10               := routing_oper_rec.attribute10;
    G_operation_tbl(i).attribute11               := routing_oper_rec.attribute11;
    G_operation_tbl(i).attribute12               := routing_oper_rec.attribute12;
    G_operation_tbl(i).attribute13               := routing_oper_rec.attribute13;
    G_operation_tbl(i).attribute14               := routing_oper_rec.attribute14;
    G_operation_tbl(i).attribute15               := routing_oper_rec.attribute15;
--    G_operation_tbl(i).long_description		 := routing_oper_rec.long_description;

    l_op_seq_id  := routing_oper_rec.operation_sequence_id;
    l_op_seq_num := routing_oper_rec.operation_seq_num;
    l_op_type    := routing_oper_rec.operation_type;
    l_eff_date   := routing_oper_rec.effectivity_date;
/*
    Populate_Oper_Resources(P_organization_code,
                            P_assembly_item_name,
                            P_alt_rtg_code,
                            l_op_seq_id,
                            l_op_seq_num,
                            l_op_type   ,
                            l_eff_date  );
*/
    Populate_Oper_Resources(P_organization_code => P_organization_code,
                                  P_assembly_item_name => P_assembly_item_name,
                                  P_alt_rtg_code => P_alt_rtg_code,
                                  P_operation_sequence_id => l_op_seq_id,
                                  P_operation_seq_num => l_op_seq_num,
                                  P_operation_type => l_op_type,
                                  P_effectivity_date => l_eff_date);
    i := i + 1;
  END LOOP;
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Operations: '||to_char(G_operation_tbl.COUNT)||' record(s) fetched. ');
  END IF;
END Populate_Operations;

PROCEDURE Populate_Oper_Networks(P_organization_code IN VARCHAR2,
                                 P_assembly_item_name IN VARCHAR2,
                                 P_alternate_routing_code IN VARCHAR2,
                                 P_routing_seq_id     IN NUMBER) IS
  CURSOR Oper_Networks_CUR IS
    SELECT bonv.From_Seq_Num,
	   bos1.X_Coordinate From_X_Coordinate,
	   bos1.Y_Coordinate From_Y_Coordinate,
           bonv.From_Effectivity_Date,
           bonv.To_Seq_Num,
	   bos2.X_Coordinate To_X_Coordinate,
	   bos2.Y_Coordinate To_Y_Coordinate,
           bonv.To_Effectivity_Date,
           bonv.Transition_Type,
           bonv.Planning_Pct,
           bonv.Attribute_category,
           bonv.Attribute1,
           bonv.Attribute2,
           bonv.Attribute3,
           bonv.Attribute4,
           bonv.Attribute5,
           bonv.Attribute6,
           bonv.Attribute7,
           bonv.Attribute8,
           bonv.Attribute9,
           bonv.Attribute10,
           bonv.Attribute11,
           bonv.Attribute12,
           bonv.Attribute13,
           bonv.Attribute14,
           bonv.Attribute15,
           bonv.Original_System_Reference
    FROM   bom_operation_networks_v bonv,
           bom_operation_sequences bos1,
           bom_operation_sequences bos2
    WHERE  bonv.routing_sequence_id   = P_routing_seq_id
    AND    bos1.Operation_Sequence_Id = bonv.From_Op_Seq_Id
    AND    bos2.Operation_Sequence_Id = bonv.To_Op_Seq_Id;
  i NUMBER := 1;
BEGIN
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Oper_Networks entered.');
  END IF;

  FOR oper_networks_rec IN Oper_Networks_CUR LOOP
    G_Op_Network_Tbl(i).assembly_item_name        := P_assembly_item_name;
    G_op_network_tbl(i).organization_code         := P_organization_code;
    G_op_network_tbl(i).alternate_routing_code    := P_alternate_routing_code;
    G_op_network_tbl(i).from_op_seq_number        := oper_networks_rec.from_seq_num;
    G_op_network_tbl(i).from_x_coordinate         := oper_networks_rec.from_x_coordinate;
    G_op_network_tbl(i).from_y_coordinate         := oper_networks_rec.from_y_coordinate;
    G_op_network_tbl(i).from_start_effective_date := oper_networks_rec.from_effectivity_date;
    G_op_network_tbl(i).to_op_seq_number          := oper_networks_rec.to_seq_num;
    G_op_network_tbl(i).to_x_coordinate           := oper_networks_rec.to_x_coordinate;
    G_op_network_tbl(i).to_y_coordinate           := oper_networks_rec.to_y_coordinate;
    G_op_network_tbl(i).to_start_effective_date   := oper_networks_rec.to_effectivity_date;
    G_op_network_tbl(i).connection_type           := oper_networks_rec.transition_type;
    G_op_network_tbl(i).planning_percent          := oper_networks_rec.planning_pct;
    G_op_network_tbl(i).attribute_category        := oper_networks_rec.attribute_category;
    G_op_network_tbl(i).attribute1                := oper_networks_rec.attribute1;
    G_op_network_tbl(i).attribute2                := oper_networks_rec.attribute2;
    G_op_network_tbl(i).attribute3                := oper_networks_rec.attribute3;
    G_op_network_tbl(i).attribute4                := oper_networks_rec.attribute4;
    G_op_network_tbl(i).attribute5                := oper_networks_rec.attribute5;
    G_op_network_tbl(i).attribute6                := oper_networks_rec.attribute6;
    G_op_network_tbl(i).attribute7                := oper_networks_rec.attribute7;
    G_op_network_tbl(i).attribute8                := oper_networks_rec.attribute8;
    G_op_network_tbl(i).attribute9                := oper_networks_rec.attribute9;
    G_op_network_tbl(i).attribute10               := oper_networks_rec.attribute10;
    G_op_network_tbl(i).attribute11               := oper_networks_rec.attribute11;
    G_op_network_tbl(i).attribute12               := oper_networks_rec.attribute12;
    G_op_network_tbl(i).attribute13               := oper_networks_rec.attribute13;
    G_op_network_tbl(i).attribute14               := oper_networks_rec.attribute14;
    G_op_network_tbl(i).attribute15               := oper_networks_rec.attribute15;
    G_op_network_tbl(i).original_system_reference := oper_networks_rec.original_system_reference;
    i := i + 1;
  END LOOP;
  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('PROCEDURE Populate_Oper_Networks: '||to_char(G_op_network_tbl.COUNT)||' record(s) fetched. ');
  END IF;
END Populate_Oper_Networks;

/********************************************************************
* Procedure	: Export_RTG
* Parameters IN	: P_organization_code  : Organization Code
*                 P_assembly_item_name : Assembly Item Name
*		  P_alternate_routing_designator : Alternate Routing Designator
* Parameters OUT: X_rtg_header_rec     : Routing Header Record
*                 X_rtg_revision_tbl   : Table of Routing Revision records
*                 X_operation_tbl      : Table of Routing Operations
*                 X_op_resource_tbl    : Table of Operation Resource Records
*                 X_sub_resource_tbl   : Table of Substitute Operation Resource Records
*                 X_op_network_tbl     : Table of Operation Networks
*********************************************************************/
PROCEDURE Export_RTG
   ( P_init_msg_list                IN  BOOLEAN := FALSE,
     P_organization_code            IN  VARCHAR2,
     P_assembly_item_name           IN  VARCHAR2,
     P_alternate_routing_designator IN  VARCHAR2,
     P_debug                        IN  VARCHAR2 := 'N',
     P_output_dir                   IN  VARCHAR2 := NULL,
     P_debug_filename               IN  VARCHAR2 := 'RTG_EXP_debug.log',
     X_rtg_header_rec               OUT NOCOPY BOM_RTG_PUB.Rtg_Header_Rec_Type,
     X_rtg_revision_tbl             OUT NOCOPY BOM_RTG_PUB.Rtg_Revision_Tbl_Type,
     X_operation_tbl                OUT NOCOPY BOM_RTG_PUB.Operation_Tbl_Type,
     X_op_resource_tbl              OUT NOCOPY BOM_RTG_PUB.Op_Resource_Tbl_Type,
     X_sub_resource_tbl             OUT NOCOPY BOM_RTG_PUB.Sub_Resource_Tbl_Type,
     X_op_network_tbl               OUT NOCOPY BOM_RTG_PUB.Op_Network_Tbl_Type,
     X_return_status                OUT NOCOPY VARCHAR2,
     X_msg_count                    OUT NOCOPY NUMBER
   ) IS
  l_organization_id NUMBER;
  l_routing_seq_id  NUMBER;
  l_Mesg_Token_Tbl  ERROR_HANDLER.Mesg_Token_Tbl_Type;
  l_other_message   VARCHAR2(50);
  l_Token_Tbl       ERROR_HANDLER.Token_Tbl_Type;
  l_Debug_flag      VARCHAR2(1) := p_debug;
  G_EXC_SEV_QUIT_OBJECT EXCEPTION;
  G_EXC_UNEXP_SKIP_OBJECT EXCEPTION;
  l_return_status         VARCHAR2(1);
  l_err_text              VARCHAR2(2000);
  l_item_id               NUMBER;
BEGIN
  G_rtg_header_rec := null;
  G_rtg_revision_tbl.DELETE;
  G_operation_tbl.DELETE;
  G_op_resource_tbl.DELETE;
  G_sub_resource_tbl.DELETE;
  G_op_network_tbl.DELETE;

  -- Initialize the message list if the user has set the
  -- Init Message List parameter
  --
  IF (p_init_msg_list) THEN
    Error_Handler.Initialize;
  END IF;
  IF (l_debug_flag = 'Y') THEN
    IF (trim(p_output_dir) IS NULL OR
        trim(p_output_dir) = '') THEN
      -- If debug is Y then out dir must be specified
      Error_Handler.Add_Error_Token
        (p_Message_text   => 'Debug is set to Y so an output directory' ||
                             ' must be specified. Debug will be turned' ||
                             ' off since no directory is specified',
         p_Mesg_Token_Tbl => l_mesg_token_tbl,
         x_Mesg_Token_Tbl => l_mesg_token_tbl,
         p_Token_Tbl      => l_token_tbl);

      Bom_Rtg_Error_Handler.Log_Error
        (p_rtg_header_rec	=> Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC,
	 p_rtg_revision_tbl	=> Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL,
	 p_operation_tbl	=> Bom_Rtg_Pub.G_MISS_OPERATION_TBL,
         p_op_resource_tbl	=> Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL,
         p_sub_resource_tbl	=> Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL,
         p_op_network_tbl	=> Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL,
	 p_mesg_token_tbl	=> l_mesg_token_tbl,
         p_error_status		=> 'W',
         p_error_scope		=> NULL,
         p_other_message	=> NULL,
         p_other_mesg_appid	=> 'BOM',
         p_other_status		=> NULL,
         p_other_token_tbl	=> Error_Handler.G_MISS_TOKEN_TBL,
         p_entity_index		=> 1,
         p_error_level		=> Error_Handler.G_BO_LEVEL,
         x_rtg_header_rec	=> x_rtg_header_rec,
         x_rtg_revision_tbl	=> x_rtg_revision_tbl,
         x_operation_tbl	=> x_operation_tbl,
         x_op_resource_tbl	=> x_op_resource_tbl,
         x_sub_resource_tbl	=> x_sub_resource_tbl,
         x_op_network_tbl	=> x_op_network_tbl);
/*
      Bom_Rtg_Error_Handler.Log_Error
        (p_mesg_token_tbl   => l_mesg_token_tbl,
         p_error_status     => 'W',
         p_error_level      => Error_Handler.G_BO_LEVEL,
         x_rtg_header_rec   => x_rtg_header_rec,
         x_rtg_revision_tbl => x_rtg_revision_tbl,
         x_operation_tbl    => x_operation_tbl,
         x_op_resource_tbl  => x_op_resource_tbl,
         x_sub_resource_tbl => x_sub_resource_tbl,
         x_op_network_tbl   => x_op_network_tbl);
*/
      l_debug_flag := 'N' ;
    END IF;

    IF (trim(p_debug_filename) IS NULL OR
        trim(p_debug_filename) = '') THEN
      Error_Handler.Add_Error_Token
        (p_Message_text   =>' Debug is set to Y so an output filename' ||
                            ' must be specified. Debug will be turned' ||
                            ' off since no filename is specified',
         p_Mesg_Token_Tbl => l_mesg_token_tbl,
         x_Mesg_Token_Tbl => l_mesg_token_tbl,
         p_Token_Tbl      => l_token_tbl);
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_rtg_header_rec	=> Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC,
	 p_rtg_revision_tbl	=> Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL,
	 p_operation_tbl	=> Bom_Rtg_Pub.G_MISS_OPERATION_TBL,
         p_op_resource_tbl	=> Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL,
         p_sub_resource_tbl	=> Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL,
         p_op_network_tbl	=> Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL,
	 p_mesg_token_tbl       => l_mesg_token_tbl,
         p_error_status         => 'W',
         p_error_scope		=> NULL,
         p_other_message	=> NULL,
         p_other_mesg_appid	=> 'BOM',
         p_other_status		=> NULL,
         p_other_token_tbl	=> Error_Handler.G_MISS_TOKEN_TBL,
         p_entity_index		=> 1,
         p_error_level          => Error_Handler.G_BO_LEVEL,
         x_rtg_header_rec       => x_rtg_header_rec,
         x_rtg_revision_tbl     => x_rtg_revision_tbl,
         x_operation_tbl        => x_operation_tbl,
         x_op_resource_tbl      => x_op_resource_tbl,
         x_sub_resource_tbl     => x_sub_resource_tbl,
         x_op_network_tbl       => x_op_network_tbl);
/*
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_mesg_token_tbl        => l_mesg_token_tbl,
         p_error_status          => 'W',
         p_error_level           => Error_Handler.G_BO_LEVEL,
         x_rtg_header_rec        => x_rtg_header_rec,
         x_rtg_revision_tbl      => x_rtg_revision_tbl,
         x_operation_tbl         => x_operation_tbl,
         x_op_resource_tbl       => x_op_resource_tbl,
         x_sub_resource_tbl      => x_sub_resource_tbl,
         x_op_network_tbl        => x_op_network_tbl);
*/
      l_debug_flag := 'N';
    END IF;

    BOM_Rtg_Globals.Set_Debug(l_debug_flag);

    IF l_debug_flag = 'Y' THEN
      Error_Handler.Open_Debug_Session
        (p_debug_filename     => p_debug_filename,
         p_output_dir         => p_output_dir,
         x_return_status      => l_return_status,
         p_mesg_token_tbl     => l_mesg_token_tbl,
         x_mesg_token_tbl     => l_mesg_token_tbl);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        BOM_Rtg_Globals.Set_Debug('N');
      END IF;
    END IF;
  END IF;

  IF ((P_assembly_item_name IS NULL OR
       P_assembly_item_name = FND_API.G_MISS_CHAR) OR
      (P_organization_code IS NULL OR
       P_organization_code = FND_API.G_MISS_CHAR)) THEN
    l_other_message := 'BOM_ASSY_OR_ORG_MISSING';
    RAISE G_EXC_SEV_QUIT_OBJECT;
  END IF;

  l_organization_id := BOM_RTG_VAL_TO_ID.Organization(p_organization => P_organization_code,
                                                      x_err_text     => l_err_text);
  IF (l_organization_id IS NULL) THEN
    l_other_message := 'BOM_ORG_INVALID';
    l_token_tbl(1).token_name := 'ORG_CODE';
    l_token_tbl(1).token_value := P_organization_code;
    RAISE G_EXC_SEV_QUIT_OBJECT;
  ELSIF (l_organization_id = FND_API.G_MISS_NUM) THEN
    l_other_message := 'BOM_UNEXP_ORG_INVALID';
    RAISE G_EXC_UNEXP_SKIP_OBJECT;
  END IF;
  l_item_id := BOM_RTG_EXP_UTIL.Get_Item_Id(P_assembly_item_name);
  IF (l_item_id IS NULL) THEN
    l_other_message            := 'BOM_ITEM_INVALID';
    l_token_tbl(1).token_name  := 'ITEM_NAME';
    l_token_tbl(1).token_value := P_assembly_item_name;
    RAISE G_EXC_SEV_QUIT_OBJECT;
  ELSIF (l_item_id = FND_API.G_MISS_NUM) THEN
    l_other_message := 'BOM_UNEXP_ITEM_INVALID';
    RAISE G_EXC_UNEXP_SKIP_OBJECT;
  END IF;
/*
  Populate_Header(P_organization_code, l_organization_id, P_assembly_item_name, l_item_id,
                  P_alternate_routing_designator, l_routing_seq_id);
  Populate_Revision(P_organization_code, l_organization_id, P_assembly_item_name, l_item_id,
                    P_alternate_routing_designator);
*/
  Populate_Header(P_organization_code => P_organization_code,
                  P_organization_id => l_organization_id,
                  P_assembly_item_name => P_assembly_item_name,
                  P_item_id => l_item_id,
                  P_alternate_routing_designator => P_alternate_routing_designator,
                  X_routing_sequence_id => l_routing_seq_id);

  Populate_Revision(P_organization_code => P_organization_code,
                    P_organization_id => l_organization_id,
                    P_assembly_item_name => P_assembly_item_name,
                    P_item_id => l_item_id,
                    P_alt_rtg_code => P_alternate_routing_designator);

  IF (l_routing_seq_id IS NOT NULL) THEN
/*
    Populate_Operations(P_organization_code, P_assembly_item_name, l_routing_seq_id,
                        P_alternate_routing_designator);

    Populate_Oper_Networks(P_organization_code, P_assembly_item_name, P_alternate_routing_designator,
                           l_routing_seq_id);
*/
    Populate_Operations(P_organization_code => P_organization_code,
                        P_assembly_item_name => P_assembly_item_name,
                        P_routing_seq_id => l_routing_seq_id,
                        P_alt_rtg_code => P_alternate_routing_designator);
    Populate_Oper_Networks(P_organization_code => P_organization_code,
                           P_assembly_item_name => P_assembly_item_name,
                           P_alternate_routing_code => P_alternate_routing_designator,
                           P_routing_seq_id => l_routing_seq_id);
  END IF;

  IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('The Routing Export BO is passed ');
    Error_Handler.Write_Debug('-----------------------------------------------------') ;
    Error_Handler.Write_Debug('Header Rec - Assembly Item : ' || G_rtg_header_rec.assembly_item_name);
    Error_Handler.Write_Debug('Num of Routing Revisions   : ' || G_rtg_revision_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Operations          : ' || G_operation_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Resources           : ' || G_op_resource_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Substitue Resources : ' || G_sub_resource_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Operation Network   : ' || G_op_network_tbl.COUNT);
    Error_Handler.Write_Debug('-----------------------------------------------------') ;
  END IF;

  X_rtg_header_rec   := G_rtg_header_rec;
  X_rtg_revision_tbl := G_rtg_revision_tbl;
  X_operation_tbl    := G_operation_tbl;
  X_op_resource_tbl  := G_op_resource_tbl;
  X_sub_resource_tbl := G_sub_resource_tbl;
  X_op_network_tbl   := G_op_network_tbl;
  X_return_status    := 'S';
  EXCEPTION
    WHEN G_EXC_SEV_QUIT_OBJECT THEN
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_rtg_header_rec	=> Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC,
	 p_rtg_revision_tbl	=> Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL,
	 p_operation_tbl	=> Bom_Rtg_Pub.G_MISS_OPERATION_TBL,
         p_op_resource_tbl	=> Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL,
         p_sub_resource_tbl	=> Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL,
         p_op_network_tbl	=> Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL,
	 p_Mesg_Token_Tbl       => l_Mesg_Token_Tbl,
         p_error_status         => Error_Handler.G_STATUS_ERROR,
         p_error_level          => Error_Handler.G_BO_LEVEL,
         p_error_scope          => Error_Handler.G_SCOPE_ALL,
         p_other_status         => Error_Handler.G_STATUS_NOT_PICKED,
         p_other_message        => l_other_message,
         p_other_mesg_appid	=> 'BOM',
         p_other_token_tbl      => l_token_tbl,
         p_entity_index		=> 1,
         x_rtg_header_rec       => x_rtg_header_rec,
         x_rtg_revision_tbl     => x_rtg_revision_tbl,
         x_operation_tbl        => x_operation_tbl,
         x_op_resource_tbl      => x_op_resource_tbl,
         x_sub_resource_tbl     => x_sub_resource_tbl,
         x_op_network_tbl       => x_op_network_tbl);
/*
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_Mesg_Token_Tbl        => l_Mesg_Token_Tbl,
         p_error_status          => Error_Handler.G_STATUS_ERROR,
         p_error_level           => Error_Handler.G_BO_LEVEL,
         p_error_scope           => Error_Handler.G_SCOPE_ALL,
         p_other_status          => Error_Handler.G_STATUS_NOT_PICKED,
         p_other_message         => l_other_message,
         p_other_token_tbl       => l_token_tbl,
         x_rtg_header_rec        => x_rtg_header_rec,
         x_rtg_revision_tbl      => x_rtg_revision_tbl,
         x_operation_tbl         => x_operation_tbl,
         x_op_resource_tbl       => x_op_resource_tbl,
         x_sub_resource_tbl      => x_sub_resource_tbl,
         x_op_network_tbl        => x_op_network_tbl);
*/
         x_return_status := Error_Handler.G_STATUS_ERROR;
         x_msg_count     := Error_Handler.Get_Message_Count;
         IF (BOM_RTG_GLOBALS.Get_Debug = 'Y') THEN
           ERROR_HANDLER.Close_Debug_Session;
         END IF;

    WHEN G_EXC_UNEXP_SKIP_OBJECT THEN
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_rtg_header_rec	=> Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC,
	 p_rtg_revision_tbl	=> Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL,
	 p_operation_tbl	=> Bom_Rtg_Pub.G_MISS_OPERATION_TBL,
         p_op_resource_tbl	=> Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL,
         p_sub_resource_tbl	=> Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL,
         p_op_network_tbl	=> Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL,
         p_Mesg_Token_Tbl       => l_Mesg_Token_Tbl,
         p_error_status         => Error_Handler.G_STATUS_UNEXPECTED,
         p_error_scope		=> NULL,
         p_other_mesg_appid	=> 'BOM',
         p_entity_index		=> 1,
         p_error_level          => Error_Handler.G_BO_LEVEL,
         p_other_status         => Error_Handler.G_STATUS_NOT_PICKED,
         p_other_message        => l_other_message,
         p_other_token_tbl      => l_token_tbl,
         x_rtg_header_rec       => x_rtg_header_rec,
         x_rtg_revision_tbl     => x_rtg_revision_tbl,
         x_operation_tbl        => x_operation_tbl,
         x_op_resource_tbl      => x_op_resource_tbl,
         x_sub_resource_tbl     => x_sub_resource_tbl,
         x_op_network_tbl       => x_op_network_tbl);
/*
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_Mesg_Token_Tbl        => l_Mesg_Token_Tbl,
         p_error_status          => Error_Handler.G_STATUS_UNEXPECTED,
         p_error_level           => Error_Handler.G_BO_LEVEL,
         p_other_status          => Error_Handler.G_STATUS_NOT_PICKED,
         p_other_message         => l_other_message,
         p_other_token_tbl       => l_token_tbl,
         x_rtg_header_rec        => x_rtg_header_rec,
         x_rtg_revision_tbl      => x_rtg_revision_tbl,
         x_operation_tbl         => x_operation_tbl,
         x_op_resource_tbl       => x_op_resource_tbl,
         x_sub_resource_tbl      => x_sub_resource_tbl,
         x_op_network_tbl        => x_op_network_tbl);
*/
      x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
      x_msg_count     := Error_Handler.Get_Message_Count;
      IF (Bom_Rtg_Globals.Get_Debug = 'Y') THEN
        ERROR_HANDLER.Close_Debug_Session;
      END IF;
    WHEN no_data_found THEN
      BOM_RTG_ERROR_HANDLER.Log_Error
        (p_rtg_header_rec	=> Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC,
	 p_rtg_revision_tbl	=> Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL,
	 p_operation_tbl	=> Bom_Rtg_Pub.G_MISS_OPERATION_TBL,
         p_op_resource_tbl	=> Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL,
         p_sub_resource_tbl	=> Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL,
         p_op_network_tbl	=> Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL,
	 p_mesg_token_tbl	=> l_mesg_token_tbl,
         p_error_status         => Error_Handler.G_STATUS_ERROR,
         p_other_mesg_appid	=> 'BOM',
         p_other_token_tbl	=> Error_Handler.G_MISS_TOKEN_TBL,
         p_entity_index		=> 1,
         p_error_level          => Error_Handler.G_BO_LEVEL,
         p_error_scope          => Error_Handler.G_SCOPE_ALL,
         p_other_status         => Error_Handler.G_STATUS_NOT_PICKED,
         p_other_message        => 'BOM_EXP_NO_RTG',
         x_rtg_header_rec       => X_rtg_header_rec,
         x_rtg_revision_tbl     => X_rtg_revision_tbl,
         x_operation_tbl        => X_operation_tbl,
         x_op_resource_tbl      => X_op_resource_tbl,
         x_sub_resource_tbl     => X_sub_resource_tbl,
         x_op_network_tbl       => X_op_network_tbl);
/*
      BOM_RTG_ERROR_HANDLER.Log_Error
        ( p_error_status          => Error_Handler.G_STATUS_ERROR,
          p_error_level           => Error_Handler.G_BO_LEVEL,
          p_error_scope           => Error_Handler.G_SCOPE_ALL,
          p_other_status          => Error_Handler.G_STATUS_NOT_PICKED,
          p_other_message         => 'BOM_EXP_NO_RTG',
          x_rtg_header_rec        => X_rtg_header_rec,
          x_rtg_revision_tbl      => X_rtg_revision_tbl,
          x_operation_tbl         => X_operation_tbl,
          x_op_resource_tbl       => X_op_resource_tbl,
          x_sub_resource_tbl      => X_sub_resource_tbl,
          x_op_network_tbl        => X_op_network_tbl);
*/
      X_return_status := Error_Handler.G_STATUS_ERROR;
      X_msg_count     := Error_Handler.Get_Message_Count;
      IF (BOM_RTG_GLOBALS.Get_Debug = 'Y') THEN
        ERROR_HANDLER.Close_Debug_Session;
      END IF;
END Export_RTG;
END BOM_RTG_EXP;

/
