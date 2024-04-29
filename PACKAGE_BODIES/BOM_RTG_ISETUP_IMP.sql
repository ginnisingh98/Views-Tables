--------------------------------------------------------
--  DDL for Package Body BOM_RTG_ISETUP_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_ISETUP_IMP" AS
/* $Header: BOMRTSTB.pls 120.3.12010000.2 2011/12/06 10:42:01 rambkond ship $ */
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
--      Body of package BOM_RTG_ISETUP_IMP
--
--  NOTES
--
--  HISTORY
--
--  18-NOV-02   M V M P Tilak    Initial Creation
--  05-DEC-03   M V M P Tilak    Modified for substitute_group_num changes
                                 dones to the Routing Business Object API
                                 as well as the Routing form modifications.
                                 schedule_sequence_number is no more a
                                 mandatory field in the table.
                                 Added this new column substitutegroupnumber
                                 in the temp tables and using that in the
                                 corr. cursors.
--  20-JUL-04   M V M P Tilak    Modified the cursor rtg_sub_op_res_CUR
                                 for bug#3776173.
***************************************************************************/

PROCEDURE IMPORT_ROUTING(P_debug              IN  VARCHAR2 := 'N',
                         P_output_dir         IN  VARCHAR2 := NULL,
                         P_debug_filename     IN  VARCHAR2 := 'BOM_BO_debug.log',
                         P_rtg_hdr_XML        IN  CLOB,
                         P_rtg_rev_XML        IN  CLOB,
                         P_rtg_op_XML         IN  CLOB,
                         P_rtg_op_res_XML     IN  CLOB,
                         P_rtg_sub_op_res_XML IN  CLOB,
                         P_rtg_op_network_XML IN  CLOB,
                         X_return_status      OUT NOCOPY VARCHAR2,
                         X_msg_count          OUT NOCOPY NUMBER,
                         X_G_msg_data         OUT NOCOPY LONG) IS

  insCtx  DBMS_XMLSave.ctxType;
  rows    NUMBER;
  ename_v VARCHAR2(20);

  l_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type
                          :=  Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC;
  l_rtg_revision_tbl  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL;
  l_operation_tbl     Bom_Rtg_Pub.Operation_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_OPERATION_TBL;
  l_op_resource_tbl   Bom_Rtg_Pub.Op_Resource_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL;
  l_sub_resource_tbl  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL;
  l_op_network_tbl    Bom_Rtg_Pub.Op_Network_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL;
  x_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type
                          :=  Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC;
  x_rtg_revision_tbl  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
                          :=Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL;
  x_operation_tbl     Bom_Rtg_Pub.Operation_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_OPERATION_TBL;
  x_op_resource_tbl   Bom_Rtg_Pub.Op_Resource_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL;
  x_sub_resource_tbl  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL;
  x_op_network_tbl    Bom_Rtg_Pub.Op_Network_Tbl_Type
                          :=  Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL;

  CURSOR rtg_hdr_CUR IS
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.EngRoutingFlag
         , tmp.CommonAssemblyItemName
         , tmp.RoutingComment
         , tmp.CompletionSubinventory
         , tmp.CompletionLocationName
         , tmp.LineCode
         , tmp.CFMRoutingFlag
         , tmp.MixedModelMapFlag
         , tmp.Priority
         , TO_NUMBER(tmp.TotalCycleTime)
         , tmp.CTPFlag
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'CREATE' Transaction_Type
         , NULL     Return_Status
         , NULL Delete_Group_Name
         , NULL DG_Description
         , NULL ser_start_op_seq
         , NULL row_identifier
    FROM   bom_routing_header_temp tmp,
           mtl_parameters org,
           mtl_system_items_kfv item
    WHERE  org.organization_code      = tmp.OrganizationCode
    AND    item.organization_id       = org.organization_id
    AND    item.concatenated_segments = tmp.AssemblyItemName
    AND    NOT EXISTS (SELECT 1
                       FROM   bom_operational_routings rtg
                       WHERE  rtg.assembly_item_id                          = item.inventory_item_id
                       AND    rtg.organization_id                           = item.organization_id
                       AND    NVL(rtg.alternate_routing_designator,'$$##$$') = NVL(tmp.AlternateRoutingCode,'$$##$$'))
    UNION ALL
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.EngRoutingFlag
         , tmp.CommonAssemblyItemName
         , tmp.RoutingComment
         , tmp.CompletionSubinventory
         , tmp.CompletionLocationName
         , tmp.LineCode
         , tmp.CFMRoutingFlag
         , tmp.MixedModelMapFlag
         , tmp.Priority
         , TO_NUMBER(tmp.TotalCycleTime)
         , tmp.CTPFlag
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'UPDATE' Transaction_Type
         , NULL Return_Status
         , NULL Delete_Group_Name
         , NULL DG_Description
         , NULL ser_start_op_seq
         , NULL row_identifier
    FROM   bom_routing_header_temp tmp,
           mtl_parameters org,
           mtl_system_items_kfv item
    WHERE  org.organization_code      = tmp.OrganizationCode
    AND    item.organization_id       = org.organization_id
    AND    item.concatenated_segments = tmp.AssemblyItemName
    AND    EXISTS (SELECT 1
                   FROM   bom_operational_routings rtg
                   WHERE  rtg.assembly_item_id             = item.inventory_item_id
                   AND    rtg.organization_id              = item.organization_id
                   AND    NVL(rtg.alternate_routing_designator,'$$##$$') = NVL(tmp.AlternateRoutingCode,'$$##$$'));

  CURSOR rtg_rev_CUR(P_assembly_item_name     VARCHAR2,
                     P_organization_code      VARCHAR2) IS
    SELECT  tmp.AssemblyItemName
          , tmp.OrganizationCode
          , NULL Alternate_Routing_Code
          , tmp.Revision
          , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
          , tmp.AttributeCategory
          , tmp.Attribute1
          , tmp.Attribute2
          , tmp.Attribute3
          , tmp.Attribute4
          , tmp.Attribute5
          , tmp.Attribute6
          , tmp.Attribute7
          , tmp.Attribute8
          , tmp.Attribute9
          , tmp.Attribute10
          , tmp.Attribute11
          , tmp.Attribute12
          , tmp.Attribute13
          , tmp.Attribute14
          , tmp.Attribute15
          , tmp.OriginalSystemReference
          , 'CREATE' transaction_type
          , NULL  return_status
          , NULL  row_identifier
    FROM  bom_rtg_revisions_temp tmp,
          mtl_parameters org,
          mtl_system_items_kfv item
    WHERE org.organization_code      = tmp.OrganizationCode
    AND   item.organization_id       = org.organization_id
    AND   item.concatenated_segments = tmp.AssemblyItemName
    AND   tmp.AssemblyItemName       = P_assembly_item_name
    AND   tmp.OrganizationCode       = P_organization_code
    AND   NOT EXISTS (SELECT 1
                      FROM   mtl_rtg_item_revisions rev
                      WHERE  rev.organization_id   = item.organization_id
                      AND    rev.inventory_item_id = item.inventory_item_id
                      AND    rev.process_revision  = tmp.revision)
    UNION ALL
    SELECT  tmp.AssemblyItemName
          , tmp.OrganizationCode
          , NULL Alternate_Routing_Code
          , tmp.Revision
          , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
          , tmp.AttributeCategory
          , tmp.Attribute1
          , tmp.Attribute2
          , tmp.Attribute3
          , tmp.Attribute4
          , tmp.Attribute5
          , tmp.Attribute6
          , tmp.Attribute7
          , tmp.Attribute8
          , tmp.Attribute9
          , tmp.Attribute10
          , tmp.Attribute11
          , tmp.Attribute12
          , tmp.Attribute13
          , tmp.Attribute14
          , tmp.Attribute15
          , tmp.OriginalSystemReference
          , 'UPDATE' transaction_type
          , NULL return_status
          , NULL row_identifier
    FROM  bom_rtg_revisions_temp tmp,
          mtl_parameters org,
          mtl_system_items_kfv item
    WHERE org.organization_code      = tmp.OrganizationCode
    AND   item.organization_id       = org.organization_id
    AND   item.concatenated_segments = tmp.AssemblyItemName
    AND   tmp.AssemblyItemName       = P_assembly_item_name
    AND   tmp.OrganizationCode       = P_organization_code
    AND   EXISTS (SELECT 1
                  FROM   mtl_rtg_item_revisions rev
                  WHERE  rev.organization_id   = item.organization_id
                  AND    rev.inventory_item_id = item.inventory_item_id
                  AND    rev.process_revision  = tmp.revision);

  CURSOR rtg_op_CUR(P_assembly_item_name     VARCHAR2,
                    P_organization_code      VARCHAR2,
                    P_alternate_routing_code VARCHAR2) IS
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.OperationSequenceNumber
         , tmp.OperationType
         , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.NewOperationSequenceNumber
         , TO_DATE(tmp.NewStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.StandardOperationCode
         , tmp.DepartmentCode
         , TO_NUMBER(tmp.OpLeadTimePercent)
         , TO_NUMBER(tmp.MinimumTransferQuantity)
         , tmp.CountPointType
         , tmp.OperationDescription
         , TO_DATE(tmp.DisableDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.BackflushFlag
         , tmp.OptionDependentFlag
         , tmp.ReferenceFlag
         , tmp.ProcessSeqNumber
         , tmp.ProcessCode
         , tmp.LineOpSeqNumber
         , tmp.LineOpCode
         , tmp.Yield
         , tmp.CumulativeYield
         , TO_NUMBER(tmp.ReverseCUMYield)
         , tmp.UserLaborTime
         , tmp.UserMachineTime
         , tmp.NetPlanningPercent
         , tmp.IncludeInRollup
         , tmp.OpYieldEnabledFlag
         , tmp.ShutdownType
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'UPDATE' Transaction_Type
         , NULL     Return_Status
         , NULL     Delete_Group_Name
         , NULL     DG_Description
         , NULL long_description
         , NULL row_identifier
    FROM   bom_routing_operations_temp tmp
    WHERE  tmp.AssemblyItemName       = P_assembly_item_name
    AND    tmp.OrganizationCode       = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    EXISTS (SELECT 1
                   FROM   BOM_OPERATION_SEQUENCES oper,
                          bom_operational_routings rtg,
                          mtl_parameters org,
                          mtl_system_items_kfv item
                   WHERE  rtg.routing_sequence_id = oper.routing_sequence_id
                   AND    item.inventory_item_id  = rtg.assembly_item_id
                   AND    item.organization_id    = rtg.organization_id
                   AND    item.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_id        = rtg.organization_id
                   AND    org.organization_code      = tmp.OrganizationCode
                   AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode, '##$$##')
                   AND    oper.operation_seq_num   = tmp.OperationSequenceNumber
                   AND    oper.operation_type      = tmp.OperationType
                   AND    oper.effectivity_date    = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    rtg.common_assembly_item_id is null)
    UNION ALL
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.OperationSequenceNumber
         , tmp.OperationType
         , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.NewOperationSequenceNumber
         , TO_DATE(tmp.NewStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.StandardOperationCode
         , tmp.DepartmentCode
         , TO_NUMBER(tmp.OpLeadTimePercent)
         , TO_NUMBER(tmp.MinimumTransferQuantity)
         , tmp.CountPointType
         , tmp.OperationDescription
         , TO_DATE(tmp.DisableDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.BackflushFlag
         , tmp.OptionDependentFlag
         , tmp.ReferenceFlag
         , tmp.ProcessSeqNumber
         , tmp.ProcessCode
         , tmp.LineOpSeqNumber
         , tmp.LineOpCode
         , tmp.Yield
         , tmp.CumulativeYield
         , TO_NUMBER(tmp.ReverseCUMYield)
         , tmp.UserLaborTime
         , tmp.UserMachineTime
         , tmp.NetPlanningPercent
         , tmp.IncludeInRollup
         , tmp.OpYieldEnabledFlag
         , tmp.ShutdownType
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'CREATE' Transaction_Type
         , NULL     Return_Status
         , NULL     Delete_Group_Name
         , NULL     DG_Description
         , NULL long_description
         , NULL row_identifier
    FROM   bom_routing_operations_temp tmp
    WHERE  tmp.AssemblyItemName       = P_assembly_item_name
    AND    tmp.OrganizationCode       = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    NOT EXISTS (SELECT 1
                   FROM   BOM_OPERATION_SEQUENCES oper,
                          bom_operational_routings rtg,
                          mtl_parameters org,
                          mtl_system_items_kfv item
                   WHERE  rtg.routing_sequence_id = oper.routing_sequence_id
                   AND    item.inventory_item_id  = rtg.assembly_item_id
                   AND    item.organization_id    = rtg.organization_id
                   AND    item.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_id        = rtg.organization_id
                   AND    org.organization_code      = tmp.OrganizationCode
                   AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode, '##$$##')
                   AND    oper.operation_seq_num   = tmp.OperationSequenceNumber
                   AND    oper.operation_type      = tmp.OperationType
                   AND    oper.effectivity_date    = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS'));

  CURSOR rtg_op_res_CUR (P_assembly_item_name     VARCHAR2,
                         P_organization_code      VARCHAR2,
                         P_alternate_routing_code VARCHAR2) IS
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.OperationSequenceNumber
         , tmp.OperationType
         , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.ResourceSequenceNumber
         , tmp.ResourceCode
         , tmp.Activity
         , tmp.StandardRateFlag
         , TO_NUMBER(tmp.AssignedUnits)
         , TO_NUMBER(tmp.UsageRateOrAmount)
         , TO_NUMBER(tmp.UsageRateOrAmountInverse)
         , tmp.BasisType
         , tmp.ScheduleFlag
         , TO_NUMBER(tmp.ResourceOffsetPercent)
         , tmp.AutochargeType
         , TO_NUMBER(tmp.SubstituteGroupNumber)
         , TO_NUMBER(tmp.ScheduleSequenceNumber)
         , tmp.PrincipleFlag
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'CREATE'
         , NULL
         , tmp.SetupType
         , NULL row_identifier
    FROM   bom_rtg_oper_res_temp tmp
    WHERE  tmp.AssemblyItemName  = P_assembly_item_name
    AND    tmp.OrganizationCode  = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    NOT EXISTS (SELECT 1
                       FROM   BOM_OPERATION_RESOURCES oper_res,
                              bom_operation_sequences oper,
                              bom_operational_routings rtg,
                              mtl_parameters org,
                              mtl_system_items_kfv item
                       WHERE  oper.operation_sequence_id = oper_res.operation_sequence_id
                       AND    rtg.routing_sequence_id    = oper.routing_sequence_id
                       AND    item.inventory_item_id     = rtg.assembly_item_id
                       AND    item.organization_id       = rtg.organization_id
                       AND    item.concatenated_segments = tmp.AssemblyItemName
                       AND    org.organization_id        = rtg.organization_id
                       AND    org.organization_code      = tmp.OrganizationCode
                       AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode, '##$$##')
                       AND    oper.operation_seq_num     = tmp.OperationSequenceNumber
                       AND    oper.operation_type        = tmp.OperationType
                       AND    oper.effectivity_date      = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    oper_res.resource_seq_num  = tmp.ResourceSequenceNumber)
    UNION ALL
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.OperationSequenceNumber
         , tmp.OperationType
         , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.ResourceSequenceNumber
         , tmp.ResourceCode
         , tmp.Activity
         , tmp.StandardRateFlag
         , TO_NUMBER(tmp.AssignedUnits)
         , TO_NUMBER(tmp.UsageRateOrAmount)
         , TO_NUMBER(tmp.UsageRateOrAmountInverse)
         , tmp.BasisType
         , tmp.ScheduleFlag
         , TO_NUMBER(tmp.ResourceOffsetPercent)
         , tmp.AutochargeType
         , TO_NUMBER(tmp.SubstituteGroupNumber)
         , TO_NUMBER(tmp.ScheduleSequenceNumber)
         , tmp.PrincipleFlag
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'UPDATE'
         , NULL
         , tmp.SetupType
         , NULL row_identifier
    FROM   bom_rtg_oper_res_temp tmp
    WHERE  tmp.AssemblyItemName  = P_assembly_item_name
    AND    tmp.OrganizationCode  = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    EXISTS (SELECT 1
                       FROM   BOM_OPERATION_RESOURCES oper_res,
                              bom_operation_sequences oper,
                              bom_operational_routings rtg,
                              mtl_parameters org,
                              mtl_system_items_kfv item
                       WHERE  oper.operation_sequence_id = oper_res.operation_sequence_id
                       AND    rtg.routing_sequence_id    = oper.routing_sequence_id
                       AND    item.inventory_item_id     = rtg.assembly_item_id
                       AND    item.organization_id       = rtg.organization_id
                       AND    item.concatenated_segments = tmp.AssemblyItemName
                       AND    org.organization_id        = rtg.organization_id
                       AND    org.organization_code      = tmp.OrganizationCode
                       AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode, '##$$##')
                       AND    oper.operation_seq_num     = tmp.OperationSequenceNumber
                       AND    oper.operation_type        = tmp.OperationType
                       AND    oper.effectivity_date      = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    oper_res.resource_seq_num  = tmp.ResourceSequenceNumber
                       AND    rtg.common_assembly_item_id is null);

  CURSOR rtg_sub_op_res_CUR(P_assembly_item_name     VARCHAR2,
                            P_organization_code      VARCHAR2,
                            P_alternate_routing_code VARCHAR2) IS
    SELECT    tmp.AssemblyItemName
            , tmp.OrganizationCode
            , tmp.AlternateRoutingCode
            , tmp.OperationSequenceNumber
            , tmp.OperationType
            , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
            , tmp.SubResourceCode
            , tmp.NewSubResourceCode
            , TO_NUMBER(tmp.SubstituteGroupNumber)
            , TO_NUMBER(tmp.ScheduleSequenceNumber)
            , tmp.ReplacementGroupNumber
--Added the following line for bug3776173 START
            , TO_NUMBER(NULL) NewReplacementGroupNumber
--Bug3776173 END
            , tmp.Activity
            , tmp.StandardRateFlag
            , TO_NUMBER(tmp.AssignedUnits)
            , TO_NUMBER(tmp.UsageRateOrAmount)
            , TO_NUMBER(tmp.UsageRateOrAmountInverse)
            , tmp.BasisType
            , TO_NUMBER(NULL) NewBasisType /* Added for 4689856 */
            , tmp.ScheduleFlag
            , TO_NUMBER(NULL) NewScheduleFlag /* Added for bug 13005178 */
            , TO_NUMBER(tmp.ResourceOffsetPercent)
            , tmp.AutochargeType
            , tmp.PrincipleFlag
            , tmp.Attributecategory
            , tmp.Attribute1
            , tmp.Attribute2
            , tmp.Attribute3
            , tmp.Attribute4
            , tmp.Attribute5
            , tmp.Attribute6
            , tmp.Attribute7
            , tmp.Attribute8
            , tmp.Attribute9
            , tmp.Attribute10
            , tmp.Attribute11
            , tmp.Attribute12
            , tmp.Attribute13
            , tmp.Attribute14
            , tmp.Attribute15
            , tmp.OriginalSystemReference
            , 'UPDATE'
            , NULL
            , tmp.SetupType
            , NULL row_identifier
    FROM   bom_sub_oper_resources_temp tmp
    WHERE  tmp.AssemblyItemName             = P_assembly_item_name
    AND    tmp.OrganizationCode             = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    EXISTS (SELECT 1
                   FROM   BOM_SUB_OPERATION_RESOURCES sub_oper,
                          bom_operational_routings rtg,
                          BOM_OPERATION_SEQUENCES oper,
                          mtl_parameters org,
                          mtl_system_items_kfv item
                   WHERE  oper.operation_sequence_id = sub_oper.operation_sequence_id
                   AND    rtg.routing_sequence_id    = oper.routing_sequence_id
                   AND    item.inventory_item_id     = rtg.assembly_item_id
                   AND    item.organization_id       = rtg.organization_id
                   AND    item.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_id        = rtg.organization_id
                   AND    org.organization_code      = tmp.OrganizationCode
                   AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode, '##$$##')
                   AND    oper.operation_seq_num     = tmp.OperationSequenceNumber
                   AND    oper.operation_type        = tmp.OperationType
                   AND    oper.effectivity_date      = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    NVL(sub_oper.schedule_seq_num,-99999)  = NVL(tmp.ScheduleSequenceNumber,-99999)
                   AND    sub_oper.substitute_group_num  = tmp.SubstituteGroupNumber
                   AND    rtg.common_assembly_item_id is null)
    UNION ALL
    SELECT    tmp.AssemblyItemName
            , tmp.OrganizationCode
            , tmp.AlternateRoutingCode
            , tmp.OperationSequenceNumber
            , tmp.OperationType
            , TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
            , tmp.SubResourceCode
            , tmp.NewSubResourceCode
            , TO_NUMBER(tmp.SubstituteGroupNumber)
            , TO_NUMBER(tmp.ScheduleSequenceNumber)
            , TO_NUMBER(tmp.ReplacementGroupNumber)
--Added the following line for Bug3776173 START
            , TO_NUMBER(NULL) NewReplacementGroupNumber
--Bug3776173 END
            , tmp.Activity
            , tmp.StandardRateFlag
            , TO_NUMBER(tmp.AssignedUnits)
            , TO_NUMBER(tmp.UsageRateOrAmount)
            , TO_NUMBER(tmp.UsageRateOrAmountInverse)
            , tmp.BasisType
            , TO_NUMBER(NULL) NewBasisType /* Added for 4689856 */
            , tmp.ScheduleFlag
            , TO_NUMBER(NULL) NewScheduleFlag /* Added for bug 13005178 */
            , TO_NUMBER(tmp.ResourceOffsetPercent)
            , tmp.AutochargeType
            , tmp.PrincipleFlag
            , tmp.Attributecategory
            , tmp.Attribute1
            , tmp.Attribute2
            , tmp.Attribute3
            , tmp.Attribute4
            , tmp.Attribute5
            , tmp.Attribute6
            , tmp.Attribute7
            , tmp.Attribute8
            , tmp.Attribute9
            , tmp.Attribute10
            , tmp.Attribute11
            , tmp.Attribute12
            , tmp.Attribute13
            , tmp.Attribute14
            , tmp.Attribute15
            , tmp.OriginalSystemReference
            , 'CREATE'
            , NULL
            , tmp.SetupType
            , NULL row_identifier
    FROM   bom_sub_oper_resources_temp tmp
    WHERE  tmp.AssemblyItemName             = P_assembly_item_name
    AND    tmp.OrganizationCode             = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    NOT EXISTS (SELECT 1
                   FROM   BOM_SUB_OPERATION_RESOURCES sub_oper,
                          bom_operational_routings rtg,
                          BOM_OPERATION_SEQUENCES oper,
                          mtl_parameters org,
                          mtl_system_items_kfv item
                   WHERE  oper.operation_sequence_id = sub_oper.operation_sequence_id
                   AND    rtg.routing_sequence_id    = oper.routing_sequence_id
                   AND    item.inventory_item_id     = rtg.assembly_item_id
                   AND    item.organization_id       = rtg.organization_id
                   AND    item.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_id        = rtg.organization_id
                   AND    org.organization_code      = tmp.OrganizationCode
                   AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode, '##$$##')
                   AND    oper.operation_seq_num     = tmp.OperationSequenceNumber
                   AND    oper.operation_type        = tmp.OperationType
                   AND    oper.effectivity_date      = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    NVL(sub_oper.schedule_seq_num,-99999)  = NVL(tmp.ScheduleSequenceNumber,-99999)
                   AND    sub_oper.substitute_group_num  = tmp.SubstituteGroupNumber);

-- BOM_OPERATION_NETWORKS
--      From_Op_Seq_Id
--      To_Op_Seq_Id

  CURSOR rtg_op_networks_CUR(P_assembly_item_name     VARCHAR2,
                             P_organization_code      VARCHAR2,
                             P_alternate_routing_code VARCHAR2) IS
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.OperationType
         , tmp.FromOpSeqNumber
         , tmp.FromXCoordinate
         , tmp.FromYCoordinate
         , TO_DATE(tmp.FromStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.ToOpSeqNumber
         , tmp.ToXCoordinate
         , tmp.ToYCoordinate
         , TO_DATE(tmp.ToStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.NewFromOpSeqNumber
         , TO_DATE(tmp.NewFromStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.NewToOpSeqNumber
         , TO_DATE(tmp.NewToStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.ConnectionType
         , TO_NUMBER(tmp.PlanningPercent)
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'CREATE' transaction_type
         , NULL return_status
         , NULL row_identifier
    FROM   bom_oper_networks_temp tmp
    WHERE  tmp.AssemblyItemName             = P_assembly_item_name
    AND    tmp.OrganizationCode             = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    NOT EXISTS (SELECT 1
                       FROM   bom_operation_networks op_network,
                              bom_operational_routings rtg,
                              bom_operation_sequences oper1,
                              bom_operation_sequences oper2,
                              mtl_parameters org,
                              mtl_system_items_kfv item
                       WHERE  op_network.from_op_seq_id = oper1.operation_sequence_id
                       AND    op_network.to_op_seq_id   = oper2.operation_sequence_id
                       AND    item.inventory_item_id    = rtg.assembly_item_id
                       AND    item.organization_id      = rtg.organization_id
                       AND    item.concatenated_segments = tmp.AssemblyItemName
                       AND    org.organization_id        = rtg.organization_id
                       AND    org.organization_code      = tmp.OrganizationCode
                       AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode,'##$$##')
                       AND    oper1.routing_sequence_id  = rtg.routing_sequence_id
                       AND    oper1.operation_seq_num    = tmp.FromOpSeqNumber
                       AND    oper1.operation_type       = tmp.OperationType
                       AND    oper1.effectivity_date     = TO_DATE(tmp.FromStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    oper2.routing_sequence_id  = rtg.routing_sequence_id
                       AND    oper2.operation_seq_num    = tmp.ToOpSeqNumber
                       AND    oper2.operation_type       = tmp.OperationType
                       AND    oper2.effectivity_date     = TO_DATE(tmp.ToStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS'))
    UNION ALL
    SELECT tmp.AssemblyItemName
         , tmp.OrganizationCode
         , tmp.AlternateRoutingCode
         , tmp.OperationType
         , tmp.FromOpSeqNumber
         , tmp.FromXCoordinate
         , tmp.FromYCoordinate
         , TO_DATE(tmp.FromStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.ToOpSeqNumber
         , tmp.ToXCoordinate
         , tmp.ToYCoordinate
         , TO_DATE(tmp.ToStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.NewFromOpSeqNumber
         , TO_DATE(tmp.NewFromStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.NewToOpSeqNumber
         , TO_DATE(tmp.NewToStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
         , tmp.ConnectionType
         , TO_NUMBER(tmp.PlanningPercent)
         , tmp.Attributecategory
         , tmp.Attribute1
         , tmp.Attribute2
         , tmp.Attribute3
         , tmp.Attribute4
         , tmp.Attribute5
         , tmp.Attribute6
         , tmp.Attribute7
         , tmp.Attribute8
         , tmp.Attribute9
         , tmp.Attribute10
         , tmp.Attribute11
         , tmp.Attribute12
         , tmp.Attribute13
         , tmp.Attribute14
         , tmp.Attribute15
         , tmp.OriginalSystemReference
         , 'UPDATE' transaction_type
         , NULL  return_status
         , NULL row_identifier
    FROM   bom_oper_networks_temp tmp
    WHERE  tmp.AssemblyItemName             = P_assembly_item_name
    AND    tmp.OrganizationCode             = P_organization_code
    AND    NVL(tmp.AlternateRoutingCode,'$$##$$') = NVL(P_alternate_routing_code,'$$##$$')
    AND    EXISTS (SELECT 1
                       FROM   bom_operation_networks op_network,
                              bom_operational_routings rtg,
                              bom_operation_sequences oper1,
                              bom_operation_sequences oper2,
                              mtl_parameters org,
                              mtl_system_items_kfv item
                       WHERE  op_network.from_op_seq_id = oper1.operation_sequence_id
                       AND    op_network.to_op_seq_id   = oper2.operation_sequence_id
                       AND    item.inventory_item_id    = rtg.assembly_item_id
                       AND    item.organization_id      = rtg.organization_id
                       AND    item.concatenated_segments = tmp.AssemblyItemName
                       AND    org.organization_id        = rtg.organization_id
                       AND    org.organization_code      = tmp.OrganizationCode
                       AND    NVL(rtg.alternate_routing_designator, '##$$##') = NVL(tmp.AlternateRoutingCode,'##$$##')
                       AND    oper1.routing_sequence_id  = rtg.routing_sequence_id
                       AND    oper1.operation_seq_num    = tmp.FromOpSeqNumber
                       AND    oper1.operation_type       = tmp.OperationType
                       AND    oper1.effectivity_date     = TO_DATE(tmp.FromStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    oper2.routing_sequence_id  = rtg.routing_sequence_id
                       AND    oper2.operation_seq_num    = tmp.ToOpSeqNumber
                       AND    oper2.operation_type       = tmp.OperationType
                       AND    oper2.effectivity_date     = TO_DATE(tmp.ToStartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    rtg.common_assembly_item_id is null);
  i NUMBER;
-- Following variables are used for logging messages
  l_error_tbl         ERROR_HANDLER.ERROR_TBL_TYPE;
  l_message           VARCHAR2(2000) := NULL;
  l_entity            VARCHAR2(3)    := NULL;
  l_msg_index         NUMBER;
  l_message_type      VARCHAR2(1);
  hdr_cnt             NUMBER := 0;

BEGIN
  -- Routing Header Record

  IF (p_rtg_hdr_XML IS NULL) THEN
    FND_MESSAGE.SET_NAME('BOM', 'BOM_SETUP_NO_ROWS');
    FND_MESSAGE.RETRIEVE(X_G_msg_data);
  ELSE
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_ROUTING_HEADER_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'OperationalRoutingsVO');
    -- this inserts the document
    rows := DBMS_XMLSave.insertXML(insCtx,P_rtg_hdr_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
    -- Routing Revisions Table
    IF (P_rtg_rev_XML IS NOT NULL) THEN
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_RTG_REVISIONS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'RoutingRevisionsVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx,P_rtg_rev_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
    END IF;

    -- Routing Operations Table
    IF (P_rtg_op_XML IS NOT NULL) THEN
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_ROUTING_OPERATIONS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'OperationSequencesVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx,P_rtg_op_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
    END IF;

    -- Routing Operation Resources Table
    IF (P_rtg_op_res_XML IS NOT NULL) THEN
      -- get the context handle
     insCtx := DBMS_XMLSave.newContext('BOM_RTG_OPER_RES_TEMP');
     DBMS_XMLSave.setIgnoreCase(insCtx, 1);
     DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
     DBMS_XMLSave.setRowTag(insCtx , 'OperationResourcesVO');
     -- this inserts the document
     rows := DBMS_XMLSave.insertXML(insCtx,P_rtg_op_res_XML);
     -- this closes the handle
     DBMS_XMLSave.closeContext(insCtx);
   END IF;

   -- Routing Substitute Operation Resources Table
   IF (p_rtg_sub_op_res_XML IS NOT NULL) THEN
     -- get the context handle
     insCtx := DBMS_XMLSave.newContext('BOM_SUB_OPER_RESOURCES_TEMP');
     DBMS_XMLSave.setIgnoreCase(insCtx, 1);
     DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
     DBMS_XMLSave.setRowTag(insCtx , 'SubstituteOperationResourcesVO');
     -- this inserts the document
     rows := DBMS_XMLSave.insertXML(insCtx,P_rtg_sub_op_res_XML);
     -- this closes the handle
     DBMS_XMLSave.closeContext(insCtx);
   END IF;

   -- Routing Operation Networks Table
   IF (P_rtg_op_network_XML IS NOT NULL) THEN
     -- get the context handle
     insCtx := DBMS_XMLSave.newContext('BOM_OPER_NETWORKS_TEMP');
     DBMS_XMLSave.setIgnoreCase(insCtx, 1);
     DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
     DBMS_XMLSave.setRowTag(insCtx , 'OperationNetworksVO');
     -- this inserts the document
     rows := DBMS_XMLSave.insertXML(insCtx,P_rtg_op_network_XML);
     -- this closes the handle
     DBMS_XMLSave.closeContext(insCtx);
   END IF;

   OPEN rtg_hdr_CUR;
   LOOP
     FETCH rtg_hdr_CUR INTO l_rtg_header_rec;
     IF (rtg_hdr_CUR%NOTFOUND) THEN
       EXIT;
     END IF;
     hdr_cnt := hdr_cnt + 1;

     l_rtg_revision_tbl.DELETE;
     l_operation_tbl.DELETE;
     l_op_resource_tbl.DELETE;
     l_sub_resource_tbl.DELETE;
     l_op_network_tbl.DELETE;

     OPEN rtg_rev_CUR(l_rtg_header_rec.Assembly_Item_Name,
                      l_rtg_header_rec.Organization_Code);
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
                     l_rtg_header_rec.Organization_Code,
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
                         l_rtg_header_rec.Organization_Code,
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
                             l_rtg_header_rec.Organization_Code,
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
                              l_rtg_header_rec.Organization_Code,
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
                           , x_return_status    => X_return_status
                           , x_msg_count        => X_msg_count);

     FOR i IN 1..X_msg_count LOOP
     BEGIN
       ERROR_HANDLER.Get_Message(x_entity_index => l_msg_index,
                                 x_entity_id    => l_entity,
                                 x_message_text => l_message,
                                 x_message_type => l_message_type);
       X_G_msg_data := X_G_msg_data || FND_GLOBAL.NewLine || FND_GLOBAL.NewLine || TO_CHAR(l_msg_index) || ': '||l_entity ||': '|| l_message_type ||': '||l_message;
     EXCEPTION
       WHEN OTHERS THEN
         EXIT;
     END;
     END LOOP;
   END LOOP;
   IF (hdr_cnt = 0) THEN  -- There are no records to be processed. RETURN with Error Message
     FND_MESSAGE.SET_NAME('BOM', 'BOM_SETUP_NO_ROWS');
     FND_MESSAGE.RETRIEVE(X_G_msg_data);
   END IF;
 END IF;
END Import_Routing;

END BOM_RTG_ISETUP_IMP;

/
