--------------------------------------------------------
--  DDL for Package Body BOM_BOM_ISETUP_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOM_ISETUP_IMP" AS
/* $Header: BOMBMSTB.pls 120.3.12010000.2 2010/02/03 17:04:00 umajumde ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBMSTB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_BOM_ISETUP_IMP
--
--  NOTES
--
--  HISTORY
--
--  18-NOV-02   M V M P Tilak    Initial Creation
--  26-MAR-03   M V M P Tilak    Modified for XSU utility work-around
--  10-FEB-04   Anupam Jain      Bug# 3349138, avoid redundant migration of
--                               Item Revisions data.
--  23-DEC-05	MYERRAMS	 Added ImplementationDate to bom_bill_of_materials_temp table
--				 Added BasisType to bom_inventory_components_temp table
--				 Bug: 4873339
--  05-MAY-05	MYERRAMS	 Modified the ImplementationDate conversion.
--				 Bug: 5141752
***************************************************************************/

PROCEDURE Import_BOM(P_debug             IN VARCHAR2 := 'N',
                     P_output_dir        IN VARCHAR2 := NULL,
                     P_debug_filename    IN VARCHAR2 := 'BOM_BO_debug.log',
                     P_bom_header_XML    IN CLOB,
--Bug 3349138                     P_bom_revisions_XML IN CLOB,
                     P_bom_inv_comps_XML IN CLOB,
                     P_bom_sub_comps_XML IN CLOB,
                     P_bom_ref_desgs_XML IN CLOB,
                     P_bom_comp_oper_XML IN CLOB,
                     X_return_status     OUT NOCOPY VARCHAR2,
                     X_msg_count         OUT NOCOPY NUMBER,
                     X_G_msg_data        OUT NOCOPY LONG) IS

  l_bom_header_tbl         BOM_BO_PUB.BOM_HEADER_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_HEADER_TBL;
--Bug 3349138  l_bom_revisions_tbl       BOM_BO_PUB.BOM_REVISION_TBL_TYPE
--                                    := BOM_BO_PUB.G_MISS_BOM_REVISION_TBL;
  l_bom_comp_tbl           BOM_BO_PUB.BOM_COMPS_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_COMPONENT_TBL;
  l_bom_ref_desig_tbl      BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_REF_DESIGNATOR_TBL;
  l_bom_sub_comp_tbl       BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_SUB_COMPONENT_TBL;
  l_bom_comp_oper_tbl       BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_COMP_OPS_TBL;
  X_bom_header_tbl         BOM_BO_PUB.BOM_HEADER_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_HEADER_TBL;
  X_bom_revisions_tbl       BOM_BO_PUB.BOM_REVISION_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_REVISION_TBL;
  X_bom_comp_tbl           BOM_BO_PUB.BOM_COMPS_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_COMPONENT_TBL;
  X_bom_ref_desig_tbl      BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_REF_DESIGNATOR_TBL;
  X_bom_sub_comp_tbl       BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_SUB_COMPONENT_TBL;
  X_bom_comp_oper_tbl       BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE
                                    := BOM_BO_PUB.G_MISS_BOM_COMP_OPS_TBL;
/* 090403
  CURSOR bom_updates_CUR IS
    SELECT AssemblyItemName
         , OrganizationCode
         , AlternateCode
         , TableName
         , ColumnName
         , ColumnValue
         , ColumnType
    FROM   bom_routing_updates_temp;
*/

  CURSOR bom_header_temp_CUR IS
    select * from (SELECT tmp.AssemblyItemName        ,
           tmp.OrganizationCode         ,
           tmp.AlternateBomCode        ,
           tmp.CommonAssemblyItemName ,
           tmp.CommonOrganizationCode  ,
           tmp.AssemblyComment          ,
           tmp.AssemblyType             ,
           'UPDATE' TransactionType    ,
           NULL     ReturnStatus       ,
           tmp.AttributeCategory        ,
           tmp.Attribute1                ,
           tmp.Attribute2                ,
           tmp.Attribute3                ,
           tmp.Attribute4                ,
           tmp.Attribute5                ,
           tmp.Attribute6                ,
           tmp.Attribute7                ,
           tmp.Attribute8                ,
           tmp.Attribute9                ,
           tmp.Attribute10               ,
           tmp.Attribute11               ,
           tmp.Attribute12               ,
           tmp.Attribute13               ,
           tmp.Attribute14               ,
           tmp.Attribute15               ,
           tmp.OriginalSystemReference   ,
	   tmp.ImplementationDate	 , --myerrams, bug: 4873339. New Column added for R12.
           NULL   DeleteGroupName        ,
           NULL   DGDescription          ,
           NULL   RowIdentifier
    FROM   bom_bill_of_materials_temp tmp,
           mtl_system_items_kfv item,
           mtl_parameters org
    WHERE  org.organization_code      = tmp.OrganizationCode
    AND    item.concatenated_segments = tmp.AssemblyItemName
    AND    item.organization_id       = org.organization_id
    AND    EXISTS (SELECT 1
                   FROM   bom_bill_of_materials bom
                   WHERE  bom.assembly_item_id         = item.inventory_item_id
                   AND    bom.organization_id          = org.organization_id
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                   AND    bom.common_assembly_item_id is null)
    UNION ALL
    SELECT tmp.AssemblyItemName        ,
           tmp.OrganizationCode         ,
           tmp.AlternateBomCode        ,
           tmp.CommonAssemblyItemName ,
           tmp.CommonOrganizationCode  ,
           tmp.AssemblyComment          ,
           tmp.AssemblyType             ,
           'CREATE'  TransactionType    ,
           NULL      ReturnStatus       ,
           tmp.Attributecategory        ,
           tmp.Attribute1                ,
           tmp.Attribute2                ,
           tmp.Attribute3                ,
           tmp.Attribute4                ,
           tmp.Attribute5                ,
           tmp.Attribute6                ,
           tmp.Attribute7                ,
           tmp.Attribute8                ,
           tmp.Attribute9                ,
           tmp.Attribute10               ,
           tmp.Attribute11               ,
           tmp.Attribute12               ,
           tmp.Attribute13               ,
           tmp.Attribute14               ,
           tmp.Attribute15               ,
           tmp.OriginalSystemReference   ,
	   tmp.ImplementationDate	 , --myerrams, bug: 4873339. New Column added for R12.
           NULL   DeleteGroupName        ,
           NULL   DGDescription          ,
           NULL   RowIdentifier
    FROM   bom_bill_of_materials_temp tmp,
           mtl_system_items_kfv item,
           mtl_parameters org
    WHERE  org.organization_code      = tmp.OrganizationCode
    AND    item.concatenated_segments = tmp.AssemblyItemName
    AND    item.organization_id       = org.organization_id
    AND    NOT EXISTS (SELECT 1
                       FROM   bom_bill_of_materials bom
                       WHERE  bom.assembly_item_id         = item.inventory_item_id
                       AND    bom.organization_id          = org.organization_id
                       AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')))
                       v order by v.CommonAssemblyItemName desc;

  CURSOR bom_comp_CUR IS
    SELECT tmp.OrganizationCode             ,
           tmp.AssemblyItemName            ,
           tmp.StartEffectiveDate          ,
           tmp.DisableDate                  ,
           tmp.OperationSequenceNumber     ,
           tmp.ComponentItemName           ,
           tmp.AlternateBOMCode            ,
           tmp.NewEffectivityDate          ,
           tmp.NewOperationSequenceNumber ,
           tmp.ItemSequenceNumber          ,
           tmp.QuantityPerAssembly         ,
           tmp.PlanningPercent              ,
           tmp.ProjectedYield               ,
           tmp.IncludeInCostRollup        ,
           tmp.WipSupplyType               ,
           tmp.SoBasis                      ,
           tmp.Optional                      ,
           tmp.MutuallyExclusive            ,
           tmp.CheckAtp                     ,
           tmp.ShippingAllowed              ,
           tmp.RequiredToShip              ,
           tmp.RequiredForRevenue          ,
           tmp.IncludeOnShipDocs          ,
           tmp.QuantityRelated              ,
           tmp.SupplySubinventory           ,
           tmp.LocationName                 ,
           tmp.MinimumAllowedQuantity      ,
           tmp.MaximumAllowedQuantity      ,
           tmp.Comments                      ,
           tmp.AttributeCategory            ,
           tmp.Attribute1                    ,
           tmp.Attribute2                    ,
           tmp.Attribute3                    ,
           tmp.Attribute4                    ,
           tmp.Attribute5                    ,
           tmp.Attribute6                    ,
           tmp.Attribute7                    ,
           tmp.Attribute8                    ,
           tmp.Attribute9                    ,
           tmp.Attribute10                   ,
           tmp.Attribute11                   ,
           tmp.Attribute12                   ,
           tmp.Attribute13                   ,
           tmp.Attribute14                   ,
           tmp.Attribute15                   ,
           tmp.FromEndItemUnitNumber         ,
           tmp.NewFromEndItemUnitNumber      ,
           tmp.ToEndItemUnitNumber	     ,
	   tmp.BasisType		     ,	--myerrams, bug: 4873339. New Column added for R12.
           NULL     ReturnStatus             ,
           'UPDATE' TransactionType          ,
           tmp.OriginalSystemReference       ,
           NULL   DeleteGroupName            ,
           NULL   DGDescription              ,
           tmp.EnforceIntRequirements        ,
           NULL AutoRequestMaterial          ,
           NULL RowIdentifier                ,
           tmp.SuggestedVendorName           ,
           tmp.UnitPrice
    FROM   bom_inventory_components_temp tmp
    WHERE  EXISTS (SELECT 1
                   FROM   bom_inventory_components comp,
                          bom_bill_of_materials bom,
                          mtl_system_items_kfv item1,
                          mtl_system_items_kfv item2,
                          mtl_parameters org
                   WHERE  bom.bill_sequence_id        = comp.bill_sequence_id
                   AND    item1.inventory_item_id     = bom.assembly_item_id
                   AND    item1.organization_id       = bom.organization_id
                   AND    org.organization_id         = bom.organization_id
                   AND    item1.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_code       = tmp.OrganizationCode
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                   AND    item2.inventory_item_id     = comp.component_item_id
                   AND    item2.organization_id       = org.organization_id
                   AND    item2.concatenated_segments = tmp.ComponentItemName
                   AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                   AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    bom.common_assembly_item_id is null)
    UNION ALL
    SELECT tmp.OrganizationCode             ,
           tmp.AssemblyItemName            ,
           tmp.StartEffectiveDate          ,
           tmp.DisableDate                  ,
           tmp.OperationSequenceNumber     ,
           tmp.ComponentItemName           ,
           tmp.AlternateBOMCode            ,
           tmp.NewEffectivityDate          ,
           tmp.NewOperationSequenceNumber ,
           tmp.ItemSequenceNumber          ,
           tmp.QuantityPerAssembly         ,
           tmp.PlanningPercent              ,
           tmp.ProjectedYield               ,
           tmp.IncludeInCostRollup        ,
           tmp.WipSupplyType               ,
           tmp.SoBasis                      ,
           tmp.Optional                      ,
           tmp.MutuallyExclusive            ,
           tmp.CheckAtp                     ,
           tmp.ShippingAllowed              ,
           tmp.RequiredToShip              ,
           tmp.RequiredForRevenue          ,
           tmp.IncludeOnShipDocs          ,
           tmp.QuantityRelated              ,
           tmp.SupplySubinventory           ,
           tmp.LocationName                 ,
           tmp.MinimumAllowedQuantity      ,
           tmp.MaximumAllowedQuantity      ,
           tmp.Comments                      ,
           tmp.AttributeCategory            ,
           tmp.Attribute1                    ,
           tmp.Attribute2                    ,
           tmp.Attribute3                    ,
           tmp.Attribute4                    ,
           tmp.Attribute5                    ,
           tmp.Attribute6                    ,
           tmp.Attribute7                    ,
           tmp.Attribute8                    ,
           tmp.Attribute9                    ,
           tmp.Attribute10                   ,
           tmp.Attribute11                   ,
           tmp.Attribute12                   ,
           tmp.Attribute13                   ,
           tmp.Attribute14                   ,
           tmp.Attribute15                   ,
           tmp.FromEndItemUnitNumber     ,
           tmp.NewFromEndItemUnitNumber ,
           tmp.ToEndItemUnitNumber       ,
	   tmp.BasisType		     ,	--myerrams, bug: 4873339. New Column added for R12.
           NULL        ReturnStatus         ,
           'CREATE'    TransactionType      ,
           tmp.OriginalSystemReference     ,
           NULL        DeleteGroupName     ,
           NULL        DGDescription        ,
           tmp.EnforceIntRequirements    ,
           NULL AutoRequestMaterial,
           NULL RowIdentifier,
           tmp.SuggestedVendorName,
           tmp.UnitPrice
    FROM   bom_inventory_components_temp tmp
    WHERE  NOT EXISTS
                  (SELECT 1
                   FROM   bom_inventory_components comp,
                          bom_bill_of_materials bom,
                          mtl_system_items_kfv item1,
                          mtl_system_items_kfv item2,
                          mtl_parameters org
                   WHERE  bom.bill_sequence_id        = comp.bill_sequence_id
                   AND    item1.inventory_item_id     = bom.assembly_item_id
                   AND    item1.organization_id       = bom.organization_id
                   AND    org.organization_id         = bom.organization_id
                   AND    item1.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_code       = tmp.OrganizationCode
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                   AND    item2.inventory_item_id     = comp.component_item_id
                   AND    item2.organization_id       = org.organization_id
                   AND    item2.concatenated_segments = tmp.ComponentItemName
                   AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                   AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS'));

  CURSOR bom_sub_comp_CUR IS
    SELECT tmp.OrganizationCode            ,
           tmp.AssemblyItemName           ,
           tmp.StartEffectiveDate         ,
           tmp.OperationSequenceNumber    ,
           tmp.ComponentItemName          ,
           tmp.AlternateBOMCode           ,
           tmp.SubstituteComponentName    ,
           NULL NewSubstituteComponentName,
           tmp.SubstituteItemQuantity     ,
           tmp.AttributeCategory           ,
           tmp.Attribute1                   ,
           tmp.Attribute2                   ,
           tmp.Attribute3                   ,
           tmp.Attribute4                   ,
           tmp.Attribute5                   ,
           tmp.Attribute6                   ,
           tmp.Attribute7                   ,
           tmp.Attribute8                   ,
           tmp.Attribute9                   ,
           tmp.Attribute10                  ,
           tmp.Attribute11                  ,
           tmp.Attribute12                  ,
           tmp.Attribute13                  ,
           tmp.Attribute14                  ,
           tmp.Attribute15                  ,
           null ProgramId                  ,
           tmp.FromEndItemUnitNumber        ,
           tmp.EnforceIntRequirements       ,
           tmp.OriginalSystemReference      ,
           NULL      ReturnStatus      ,
           'UPDATE'  TransactionType    ,
           NULL RowIdentifier
    FROM   bom_substitute_components_temp tmp
    WHERE  EXISTS (SELECT 1
                   FROM   bom_substitute_components sub,
                          bom_inventory_components comp,
                          bom_bill_of_materials bom,
                          mtl_parameters org,
                          mtl_system_items_kfv item1,
                          mtl_system_items_kfv item2,
                          mtl_system_items_kfv item3
                   WHERE  comp.component_sequence_id = sub.component_sequence_id
                   AND    bom.bill_sequence_id       = comp.bill_sequence_id
                   AND    item1.inventory_item_id    = bom.assembly_item_id
                   AND    item1.organization_id      = bom.organization_id
                   AND    org.organization_id        = bom.organization_Id
                   AND    item1.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_code       = tmp.OrganizationCode
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                   AND    item2.inventory_item_id     = comp.component_item_id
                   AND    item2.organization_id       = org.organization_id
                   AND    item2.concatenated_segments = tmp.ComponentItemName
                   AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                   AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    item3.inventory_item_id     = sub.substitute_component_id
                   AND    item3.organization_id       = org.organization_id
                   AND    item3.concatenated_segments = tmp.SubstituteComponentName
                   AND    bom.common_assembly_item_id is null)
    UNION ALL
    SELECT tmp.OrganizationCode            ,
           tmp.AssemblyItemName           ,
           tmp.StartEffectiveDate         ,
           tmp.OperationSequenceNumber    ,
           tmp.ComponentItemName          ,
           tmp.AlternateBOMCode           ,
           tmp.SubstituteComponentName    ,
           NULL NewSubstituteComponentName,
           tmp.SubstituteItemQuantity     ,
           tmp.AttributeCategory           ,
           tmp.Attribute1                   ,
           tmp.Attribute2                   ,
           tmp.Attribute4                   ,
           tmp.Attribute5                   ,
           tmp.Attribute6                   ,
           tmp.Attribute8                   ,
           tmp.Attribute9                   ,
           tmp.Attribute10                  ,
           tmp.Attribute12                  ,
           tmp.Attribute13                  ,
           tmp.Attribute14                  ,
           tmp.Attribute15                  ,
           tmp.Attribute3                   ,
           tmp.Attribute7                   ,
           tmp.Attribute11                  ,
           null ProgramId                  ,
           tmp.FromEndItemUnitNumber    ,
           tmp.EnforceIntRequirements     ,
           tmp.OriginalSystemReference    ,
           NULL      ReturnStatus      ,
           'CREATE'  TransactionType    ,
           NULL RowIdentifier
    FROM   bom_substitute_components_temp tmp
    WHERE  NOT EXISTS (SELECT 1
                   FROM   bom_substitute_components sub,
                          bom_inventory_components comp,
                          bom_bill_of_materials bom,
                          mtl_parameters org,
                          mtl_system_items_kfv item1,
                          mtl_system_items_kfv item2,
                          mtl_system_items_kfv item3
                   WHERE  comp.component_sequence_id = sub.component_sequence_id
                   AND    bom.bill_sequence_id       = comp.bill_sequence_id
                   AND    item1.inventory_item_id    = bom.assembly_item_id
                   AND    item1.organization_id      = bom.organization_id
                   AND    org.organization_id        = bom.organization_Id
                   AND    item1.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_code       = tmp.OrganizationCode
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                   AND    item2.inventory_item_id     = comp.component_item_id
                   AND    item2.organization_id       = org.organization_id
                   AND    item2.concatenated_segments = tmp.ComponentItemName
                   AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                   AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    item3.inventory_item_id     = sub.substitute_component_id
                   AND    item3.organization_id       = org.organization_id
                   AND    item3.concatenated_segments = tmp.SubstituteComponentName);

  CURSOR bom_ref_desig_CUR IS
    SELECT tmp.OrganizationCode            ,
           tmp.AssemblyItemName           ,
           tmp.StartEffectiveDate         ,
           tmp.OperationSequenceNumber    ,
           tmp.ComponentItemName          ,
           tmp.AlternateBomCode           ,
           tmp.ReferenceDesignatorName    ,
           tmp.RefDesignatorComment       ,
           tmp.AttributeCategory           ,
           tmp.Attribute1                   ,
	   tmp.Attribute2                   ,
	   tmp.Attribute3                   ,
	   tmp.Attribute4                   ,
	   tmp.Attribute5                   ,
	   tmp.Attribute6                   ,
	   tmp.Attribute7                   ,
	   tmp.Attribute8                   ,
	   tmp.Attribute9                   ,
	   tmp.Attribute10                  ,
	   tmp.Attribute11                  ,
	   tmp.Attribute12                  ,
	   tmp.Attribute13                  ,
	   tmp.Attribute14                  ,
	   tmp.Attribute15                  ,
	   tmp.FromEndItemUnitNumber    ,
	   tmp.OriginalSystemReference    ,
	   tmp.NewReferenceDesignator     ,
	   NULL     ReturnStatus           ,
	   'CREATE' TransactionType    ,
           NULL RowIdentifier
    FROM   bom_reference_designators_temp tmp
    WHERE  NOT EXISTS (SELECT 1
                       FROM   bom_reference_designators ref,
                              bom_inventory_components comp,
                              bom_bill_of_materials bom,
                              mtl_parameters org,
                              mtl_system_items_kfv item1,
                              mtl_system_items_kfv item2
                       WHERE  comp.component_sequence_id = ref.component_sequence_id
                       AND    bom.bill_sequence_id       = comp.bill_sequence_id
                       AND    item1.inventory_item_id    = bom.assembly_item_id
                       AND    item1.organization_id      = bom.organization_id
                       AND    item1.concatenated_segments = tmp.AssemblyItemName
                       AND    org.organization_id         = bom.organization_id
                       AND    org.organization_code       = tmp.OrganizationCode
                       AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                       AND    item2.inventory_item_id     = comp.component_item_id
                       AND    item2.organization_id       = org.organization_id
                       AND    item2.concatenated_segments = tmp.ComponentItemName
                       AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                       AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    ref.component_reference_designator = tmp.ReferenceDesignatorName)
    UNION ALL
    SELECT tmp.OrganizationCode            ,
           tmp.AssemblyItemName           ,
           tmp.StartEffectiveDate         ,
           tmp.OperationSequenceNumber    ,
           tmp.ComponentItemName          ,
           tmp.AlternateBomCode           ,
           tmp.ReferenceDesignatorName    ,
           tmp.RefDesignatorComment       ,
           tmp.AttributeCategory           ,
           tmp.Attribute1                   ,
	   tmp.Attribute2                   ,
	   tmp.Attribute3                   ,
	   tmp.Attribute4                   ,
	   tmp.Attribute5                   ,
	   tmp.Attribute6                   ,
	   tmp.Attribute7                   ,
	   tmp.Attribute8                   ,
	   tmp.Attribute9                   ,
	   tmp.Attribute10                  ,
	   tmp.Attribute11                  ,
	   tmp.Attribute12                  ,
	   tmp.Attribute13                  ,
	   tmp.Attribute14                  ,
	   tmp.Attribute15                  ,
	   tmp.FromEndItemUnitNumber    ,
	   tmp.OriginalSystemReference    ,
	   tmp.NewReferenceDesignator     ,
	   NULL      ReturnStatus          ,
	   'UPDATE'  TransactionType    ,
           NULL RowIdentifier
    FROM   bom_reference_designators_temp tmp
    WHERE  EXISTS (SELECT 1
                   FROM   bom_reference_designators ref,
                          bom_inventory_components comp,
                          bom_bill_of_materials bom,
                          mtl_parameters org,
                          mtl_system_items_kfv item1,
                          mtl_system_items_kfv item2
                   WHERE  comp.component_sequence_id = ref.component_sequence_id
                   AND    bom.bill_sequence_id       = comp.bill_sequence_id
                   AND    item1.inventory_item_id    = bom.assembly_item_id
                   AND    item1.organization_id      = bom.organization_id
                   AND    item1.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_id         = bom.organization_id
                   AND    org.organization_code       = tmp.OrganizationCode
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode,'##$$##')
                   AND    item2.inventory_item_id     = comp.component_item_id
                   AND    item2.organization_id       = org.organization_id
                   AND    item2.concatenated_segments = tmp.ComponentItemName
                   AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                   AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    ref.component_reference_designator = tmp.ReferenceDesignatorName
                   AND    bom.common_assembly_item_id is null);

  CURSOR bom_comp_oper_CUR IS
    SELECT tmp.OrganizationCode		,
           tmp.AssemblyItemName		,
           tmp.StartEffectiveDate		,
           tmp.FromEndItemUnitNumber    ,
           tmp.ToEndItemUnitNumber      ,
	   tmp.OperationSequenceNumber	,
	   tmp.AdditionalOperationSeqNum	,
       NULL NewAdditionalOpSeqNum,
	   tmp.ComponentItemName		,
	   tmp.AlternateBOMCode		,
	   tmp.Attributecategory		,
	   tmp.Attribute1        		,
	   tmp.Attribute2        		,
	   tmp.Attribute3        		,
	   tmp.Attribute4        		,
	   tmp.Attribute5        		,
	   tmp.Attribute6        		,
	   tmp.Attribute7        		,
	   tmp.Attribute8        		,
	   tmp.Attribute9        		,
	   tmp.Attribute10       		,
	   tmp.Attribute11       		,
	   tmp.Attribute12       		,
	   tmp.Attribute13       		,
	   tmp.Attribute14       		,
	   tmp.Attribute15       		,
	   NULL     ReturnStatus       ,
	   'CREATE' TransactionType    ,
       NULL RowIdentifier
    FROM   bom_component_operations_temp tmp
    WHERE  NOT EXISTS (SELECT 1
                       FROM   bom_component_operations comp_oper,
                              bom_inventory_components comp,
                              bom_bill_of_materials bom,
                              mtl_parameters org,
                              mtl_system_items_kfv item1,
                              mtl_system_items_kfv item2
                       WHERE  comp.component_sequence_id  = comp_oper.component_sequence_id
                       AND    bom.bill_sequence_id        = comp.bill_sequence_id
                       AND    item1.inventory_item_id     = bom.assembly_item_id
                       AND    item1.organization_id       = bom.organization_id
                       AND    item1.concatenated_segments = tmp.AssemblyItemName
                       AND    org.organization_id         = bom.organization_id
                       AND    org.organization_code       = tmp.OrganizationCode
                       AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode, '##$$##')
                       AND    item2.inventory_item_id     = comp.component_item_id
                       AND    item2.organization_id       = org.organization_id
                       AND    item2.concatenated_segments = tmp.ComponentItemName
                       AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                       AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                       AND    comp_oper.operation_seq_num = tmp.AdditionalOperationSeqNum)
    UNION ALL
    SELECT tmp.OrganizationCode		,
           tmp.AssemblyItemName		,
           tmp.StartEffectiveDate		,
           tmp.FromEndItemUnitNumber    ,
           tmp.ToEndItemUnitNumber      ,
	   tmp.OperationSequenceNumber	,
	   tmp.AdditionalOperationSeqNum	,
       NULL NewAdditionalOpSeqNum,
	   tmp.ComponentItemName		,
	   tmp.AlternateBOMCode		,
	   tmp.Attributecategory		,
	   tmp.Attribute1        		,
	   tmp.Attribute2        		,
	   tmp.Attribute3        		,
	   tmp.Attribute4        		,
	   tmp.Attribute5        		,
	   tmp.Attribute6        		,
	   tmp.Attribute7        		,
	   tmp.Attribute8        		,
	   tmp.Attribute9        		,
	   tmp.Attribute10       		,
	   tmp.Attribute11       		,
	   tmp.Attribute12       		,
	   tmp.Attribute13       		,
	   tmp.Attribute14       		,
	   tmp.Attribute15       		,
	   NULL        ReturnStatus    ,
	   'UPDATE'    TransactionType    ,
       NULL        RowIdentifier
    FROM   bom_component_operations_temp tmp
    WHERE  EXISTS (SELECT 1
                   FROM   bom_component_operations comp_oper,
                          bom_inventory_components comp,
                          bom_bill_of_materials bom,
                          mtl_parameters org,
                          mtl_system_items_kfv item1,
                          mtl_system_items_kfv item2
                   WHERE  comp.component_sequence_id  = comp_oper.component_sequence_id
                   AND    bom.bill_sequence_id        = comp.bill_sequence_id
                   AND    item1.inventory_item_id     = bom.assembly_item_id
                   AND    item1.organization_id       = bom.organization_id
                   AND    item1.concatenated_segments = tmp.AssemblyItemName
                   AND    org.organization_id         = bom.organization_id
                   AND    org.organization_code       = tmp.OrganizationCode
                   AND    NVL(bom.alternate_bom_designator,'##$$##') = NVL(tmp.AlternateBomCode, '##$$##')
                   AND    item2.inventory_item_id     = comp.component_item_id
                   AND    item2.organization_id       = org.organization_id
                   AND    item2.concatenated_segments = tmp.ComponentItemName
                   AND    comp.operation_seq_num      = tmp.OperationSequenceNumber
                   AND    comp.effectivity_date       = TO_DATE(tmp.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS')
                   AND    comp_oper.operation_seq_num = tmp.AdditionalOperationSeqNum
                   AND    bom.common_assembly_item_id is null);

/* Bug 3349138
  CURSOR bom_revisions_CUR IS
    SELECT tmp.AssemblyItemName   ,
           tmp.OrganizationCode    ,
           tmp.Revision	            ,
           tmp.AlternateBomCode   ,
           tmp.Description	    ,
           tmp.StartEffectiveDate ,
           'CREATE' TransactionType,
           NULL     ReturnStatus,
           tmp.AttributeCategory   ,
           tmp.Attribute1           ,
           tmp.Attribute2           ,
           tmp.Attribute3           ,
           tmp.Attribute4           ,
           tmp.Attribute5           ,
           tmp.Attribute6           ,
           tmp.Attribute7           ,
           tmp.Attribute8           ,
           tmp.Attribute9           ,
           tmp.Attribute10          ,
           tmp.Attribute11          ,
           tmp.Attribute12          ,
           tmp.Attribute13          ,
           tmp.Attribute14          ,
           tmp.Attribute15          ,
           tmp.OriginalSystemReference,
           NULL RowIdentifier
    FROM   bom_revisions_temp tmp,
           mtl_parameters org,
           mtl_system_items_kfv item
    WHERE  org.organization_code      = tmp.OrganizationCode
    AND    item.concatenated_segments = tmp.AssemblyItemName
    AND    item.organization_id       = org.organization_id
    AND    tmp.revision              <> org.starting_revision
    AND    NOT EXISTS (SELECT 1
                       FROM   mtl_item_revisions rev
                       WHERE  rev.organization_id   = org.organization_id
                       AND    rev.inventory_item_id = item.inventory_item_id
                       AND    rev.revision          = tmp.revision)
    UNION ALL
    SELECT tmp.AssemblyItemName   ,
     	   tmp.OrganizationCode    ,
	       tmp.Revision	            ,
	       tmp.AlternateBomCode   ,
	   tmp.Description	    ,
	   tmp.StartEffectiveDate ,
           'UPDATE' TransactionType,
           NULL     ReturnStatus   ,
           tmp.AttributeCategory    ,
           tmp.Attribute1           ,
           tmp.Attribute2           ,
           tmp.Attribute3           ,
           tmp.Attribute4           ,
           tmp.Attribute5           ,
           tmp.Attribute6           ,
           tmp.Attribute7           ,
           tmp.Attribute8           ,
           tmp.Attribute9           ,
           tmp.Attribute10          ,
           tmp.Attribute11          ,
           tmp.Attribute12          ,
           tmp.Attribute13          ,
           tmp.Attribute14          ,
           tmp.Attribute15          ,
           tmp.OriginalSystemReference,
           NULL RowIdentifier
    FROM   bom_revisions_temp tmp,
           mtl_parameters org,
           mtl_system_items_kfv item
    WHERE  org.organization_code      = tmp.OrganizationCode
    AND    item.concatenated_segments = tmp.AssemblyItemName
    AND    item.organization_id       = org.organization_id
    AND    tmp.revision              <> org.starting_revision
    AND    EXISTS (SELECT 1
                   FROM   mtl_item_revisions rev
                   WHERE  rev.organization_id   = org.organization_id
                   AND    rev.inventory_item_id = item.inventory_item_id
                   AND    rev.revision          = tmp.revision);
*/
  l_bom_header_rec    bom_header_temp_CUR%ROWTYPE;
--Bug 3349138  l_bom_revisions_rec bom_revisions_CUR%ROWTYPE;
  l_bom_comp_rec      bom_comp_CUR%ROWTYPE;
  l_bom_ref_desig_rec bom_ref_desig_CUR%ROWTYPE;
  l_bom_sub_comp_rec  bom_sub_comp_CUR%ROWTYPE;
  l_bom_comp_oper_rec bom_comp_oper_CUR%ROWTYPE;

  insCtx DBMS_XMLSave.ctxType;
  rows   NUMBER;
  i      NUMBER;

-- Following variables are used for logging messages
  l_error_tbl         ERROR_HANDLER.ERROR_TBL_TYPE;
  l_message           VARCHAR2(2000) := NULL;
  l_entity            VARCHAR2(3)    := NULL;
  l_msg_index         NUMBER;
  l_message_type      VARCHAR2(1);

-- Added for XSU workaround  26/03/03 - TMANDA
  l_assembly_item_name      VARCHAR2(81)   := NULL;
  l_organization_code       VARCHAR2(3)    := NULL;
  l_alternate_bom_code      VARCHAR2(10)   := NULL;
  l_table_name              VARCHAR2(50)   := NULL;
  l_column_name             VARCHAR2(50)   := NULL;
  l_column_value            VARCHAR2(200)  := NULL;
  l_column_type             VARCHAR2(10)   := NULL;
  l_update_stmt             VARCHAR2(1000) := NULL;

BEGIN
  -- Bom Header Record

  IF (P_bom_header_XML IS NOT NULL) THEN
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_BILL_OF_MATERIALS_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'BillOfMaterialsVO');
    -- this inserts the document
    rows   := DBMS_XMLSave.insertXML(insCtx, P_bom_header_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
  END IF;
  -- Bom Revisions Table
/* Bug 3349138  IF (P_bom_revisions_XML IS NOT NULL) THEN
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_REVISIONS_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'BomRevisionsVO');
    -- this inserts the document
    rows := DBMS_XMLSave.insertXML(insCtx, P_bom_revisions_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
  END IF;
*/
  IF (P_bom_inv_comps_XML IS NOT NULL) THEN
    -- Bom Inventory Components
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_INVENTORY_COMPONENTS_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'InventoryComponentsVO');
    -- this inserts the document
    rows := DBMS_XMLSave.insertXML(insCtx, P_bom_inv_comps_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
  END IF;
  IF (P_bom_sub_comps_XML IS NOT NULL) THEN
    -- Bom Substitute Components Table
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_SUBSTITUTE_COMPONENTS_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'SubstituteComponentsVO');
    -- this inserts the document
    rows := DBMS_XMLSave.insertXML(insCtx, P_bom_sub_comps_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
  END IF;
  IF (P_bom_ref_desgs_XML IS NOT NULL) THEN
    -- Bom Reference Designators Table
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_REFERENCE_DESIGNATORS_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'ReferenceDesignatorsVO');
    -- this inserts the document
    rows := DBMS_XMLSave.insertXML(insCtx, P_bom_ref_desgs_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
  END IF;
  IF (P_bom_comp_oper_XML IS NOT NULL) THEN
    -- Bom Component Operations Table
    -- get the context handle
    insCtx := DBMS_XMLSave.newContext('BOM_COMPONENT_OPERATIONS_TEMP');
    DBMS_XMLSave.setIgnoreCase(insCtx, 1);
    DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
    DBMS_XMLSave.setRowTag(insCtx , 'ComponentOperationsVO');
    -- this inserts the document
    rows := DBMS_XMLSave.insertXML(insCtx, P_bom_comp_oper_XML);
    -- this closes the handle
    DBMS_XMLSave.closeContext(insCtx);
  END IF;
/* 090403
  -- update the temp tables for the DATE and floating point NUMBER columns
  OPEN bom_updates_CUR;
  LOOP
    FETCH bom_updates_CUR
    INTO  l_assembly_item_name,
          l_organization_code,
          l_alternate_bom_code,
          l_table_name,
          l_column_name,
          l_column_value,
          l_column_type;

    IF (bom_updates_CUR%NOTFOUND) THEN
      EXIT;
    END IF;

    l_update_stmt :=  'update ' || l_table_name ||
                      ' set ' || l_column_name;

    IF (l_column_type = 'DATE') THEN
       l_update_stmt := l_update_stmt || ' = TO_DATE(:l_column_value, ''YYYY-MM-DD HH24:MI:SS'') ';
    ELSIF (l_column_type = 'NUMBER') THEN
       l_update_stmt := l_update_stmt || ' = TO_NUMBER(:l_column_value) ';
    ELSE
       l_update_stmt := l_update_stmt || ' = :l_column_value ';
    END IF;

    l_update_stmt := l_update_stmt || ' where AssemblyItemName = :l_assembly_item_name '
                                   || ' and OrganizationCode = :l_organization_code ';

    IF (l_alternate_bom_code IS NOT NULL) THEN
      l_update_stmt := l_update_stmt || ' and AlternateBomCode = :l_alternate_bom_code';

      EXECUTE IMMEDIATE l_update_stmt
        USING l_column_value, l_assembly_item_name, l_organization_code, l_alternate_bom_code;
    ELSE
      l_update_stmt := l_update_stmt || ' and AlternateBomCode IS NULL';

      EXECUTE IMMEDIATE l_update_stmt
        USING l_column_value, l_assembly_item_name, l_organization_code;
    END IF;
  END LOOP;
  CLOSE bom_updates_CUR;
  DELETE FROM bom_routing_updates_temp;commit;
 090403
*/
  i := 1;
/*
  OPEN bom_header_temp_CUR;
  LOOP
    FETCH bom_header_temp_CUR INTO l_bom_header_tbl(i);
    IF (bom_header_temp_CUR%NOTFOUND) THEN
      EXIT;
    END IF;
    i := i + 1;
  END LOOP;
  CLOSE bom_header_temp_CUR;
*/

  FOR bom_header_rec IN bom_header_temp_CUR LOOP
    l_bom_header_tbl(i).assembly_item_name            := bom_header_rec.AssemblyItemName;
    l_bom_header_tbl(i).organization_code             := bom_header_rec.OrganizationCode;
    l_bom_header_tbl(i).alternate_bom_code            := bom_header_rec.AlternateBomCode;
    l_bom_header_tbl(i).common_assembly_item_name     := bom_header_rec.CommonAssemblyItemName;
    l_bom_header_tbl(i).common_organization_code      := bom_header_rec.CommonOrganizationCode;
    l_bom_header_tbl(i).assembly_comment              := bom_header_rec.AssemblyComment;
    l_bom_header_tbl(i).assembly_type                 := bom_header_rec.AssemblyType;
    l_bom_header_tbl(i).transaction_type              := bom_header_rec.TransactionType;
    l_bom_header_tbl(i).return_status                 := bom_header_rec.ReturnStatus;
    l_bom_header_tbl(i).attribute_category            := bom_header_rec.AttributeCategory;
    l_bom_header_tbl(i).attribute1                    := bom_header_rec.Attribute1;
    l_bom_header_tbl(i).attribute2                    := bom_header_rec.Attribute2;
    l_bom_header_tbl(i).attribute3                    := bom_header_rec.Attribute3;
    l_bom_header_tbl(i).attribute4                    := bom_header_rec.Attribute4;
    l_bom_header_tbl(i).attribute5                    := bom_header_rec.Attribute5;
    l_bom_header_tbl(i).attribute6                    := bom_header_rec.Attribute6;
    l_bom_header_tbl(i).attribute7                    := bom_header_rec.Attribute7;
    l_bom_header_tbl(i).attribute8                    := bom_header_rec.Attribute8;
    l_bom_header_tbl(i).attribute9                    := bom_header_rec.Attribute9;
    l_bom_header_tbl(i).attribute10                   := bom_header_rec.Attribute10;
    l_bom_header_tbl(i).attribute11                   := bom_header_rec.Attribute11;
    l_bom_header_tbl(i).attribute12                   := bom_header_rec.Attribute12;
    l_bom_header_tbl(i).attribute13                   := bom_header_rec.Attribute13;
    l_bom_header_tbl(i).attribute14                   := bom_header_rec.Attribute14;
    l_bom_header_tbl(i).attribute15                   := bom_header_rec.Attribute15;
    l_bom_header_tbl(i).original_system_reference     := bom_header_rec.OriginalSystemReference;
    --myerrams, bug:4873339
    IF (bom_header_rec.ImplementationDate IS NOT NULL) THEN
    --myerrams, bug:5141752; bom_header_rec.ImplementationDate is of type date. We need not convert that date again.
--	l_bom_header_tbl(i).Bom_Implementation_Date   := TO_DATE(bom_header_rec.ImplementationDate, 'YYYY-MM-DD HH24:MI:SS');
	l_bom_header_tbl(i).Bom_Implementation_Date   := bom_header_rec.ImplementationDate;
    END IF;
    l_bom_header_tbl(i).delete_group_name             := bom_header_rec.DeleteGroupName;
    l_bom_header_tbl(i).dg_description                := bom_header_rec.DGDescription;
    l_bom_header_tbl(i).row_identifier                := bom_header_rec.RowIdentifier;
    i := i + 1;
  END LOOP;
  IF (i = 1) THEN  -- There are no records to be processed. RETURN with Error Message
    FND_MESSAGE.SET_NAME('BOM', 'BOM_SETUP_NO_ROWS');
    FND_MESSAGE.RETRIEVE(X_G_msg_data);
  ELSE
 /* Bug 3349138   IF (P_bom_revisions_XML IS NOT NULL) THEN
* Moved this code above. -TMANDA 26/03/03
      -- Bom Revisions Table
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_REVISIONS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'BomRevisionsVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx, P_bom_revisions_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
*
      i := 1;
      FOR bom_revisions_rec IN bom_revisions_CUR LOOP
        l_bom_revisions_tbl(i).assembly_item_name        := bom_revisions_rec.AssemblyItemName;
        l_bom_revisions_tbl(i).organization_code         := bom_revisions_rec.OrganizationCode;
        l_bom_revisions_tbl(i).revision                  := bom_revisions_rec.Revision;
        l_bom_revisions_tbl(i).alternate_bom_code        := bom_revisions_rec.AlternateBomCode;
        l_bom_revisions_tbl(i).description               := bom_revisions_rec.Description;
        l_bom_revisions_tbl(i).start_effective_date      := TO_DATE(bom_revisions_rec.StartEffectiveDate, 'YYYY-MM-DD HH24:MI:SS');
        l_bom_revisions_tbl(i).transaction_type          := bom_revisions_rec.TransactionType;
        l_bom_revisions_tbl(i).return_status             := bom_revisions_rec.ReturnStatus;
        l_bom_revisions_tbl(i).attribute_category        := bom_revisions_rec.AttributeCategory;
        l_bom_revisions_tbl(i).attribute1                := bom_revisions_rec.Attribute1;
        l_bom_revisions_tbl(i).attribute2                := bom_revisions_rec.Attribute2;
        l_bom_revisions_tbl(i).attribute3                := bom_revisions_rec.Attribute3;
        l_bom_revisions_tbl(i).attribute4                := bom_revisions_rec.Attribute4;
        l_bom_revisions_tbl(i).attribute5                := bom_revisions_rec.Attribute5;
        l_bom_revisions_tbl(i).attribute6                := bom_revisions_rec.Attribute6;
        l_bom_revisions_tbl(i).attribute7                := bom_revisions_rec.Attribute7;
        l_bom_revisions_tbl(i).attribute8                := bom_revisions_rec.Attribute8;
        l_bom_revisions_tbl(i).attribute9                := bom_revisions_rec.Attribute9;
        l_bom_revisions_tbl(i).attribute10               := bom_revisions_rec.Attribute10;
        l_bom_revisions_tbl(i).attribute11               := bom_revisions_rec.Attribute11;
        l_bom_revisions_tbl(i).attribute12               := bom_revisions_rec.Attribute12;
        l_bom_revisions_tbl(i).attribute13               := bom_revisions_rec.Attribute13;
        l_bom_revisions_tbl(i).attribute14               := bom_revisions_rec.Attribute14;
        l_bom_revisions_tbl(i).attribute15               := bom_revisions_rec.Attribute15;
        l_bom_revisions_tbl(i).original_system_reference := bom_revisions_rec.OriginalSystemReference;
        l_bom_revisions_tbl(i).row_identifier            := bom_revisions_rec.RowIdentifier;
        i := i + 1;
      END LOOP;
*/
/*
      OPEN bom_revisions_CUR;
      LOOP
        FETCH bom_revisions_CUR INTO l_bom_revisions_tbl(i);
        IF (bom_revisions_CUR%NOTFOUND) THEN
          EXIT;
        END IF;
        i := i + 1;
      END LOOP;
*/
--    END IF;
    IF (P_bom_inv_comps_XML IS NOT NULL) THEN
/*Moved this code above - TMANDA 26/03/03
      -- Bom Inventory Components
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_INVENTORY_COMPONENTS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'InventoryComponentsVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx, P_bom_inv_comps_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
*/
      i := 1;
/*
      OPEN bom_comp_CUR;
      LOOP
        FETCH bom_comp_CUR INTO l_bom_comp_tbl(i);
        IF (bom_comp_CUR%NOTFOUND) THEN
          EXIT;
        END IF;
        i := i + 1;
      END LOOP;
*/
      FOR bom_comp_rec IN bom_comp_CUR LOOP
        l_bom_comp_tbl(i).organization_code             := bom_comp_rec.OrganizationCode;
        l_bom_comp_tbl(i).assembly_item_name            := bom_comp_rec.AssemblyItemName;
        l_bom_comp_tbl(i).start_effective_date          := TO_DATE(bom_comp_rec.StartEffectiveDate, 'YYYY-MM-DD HH24:MI:SS');
        IF (bom_comp_rec.DisableDate IS NOT NULL) THEN
          l_bom_comp_tbl(i).disable_date                := TO_DATE(bom_comp_rec.DisableDate, 'YYYY-MM-DD HH24:MI:SS');
        END IF;
        l_bom_comp_tbl(i).operation_sequence_number     := bom_comp_rec.OperationSequenceNumber;
        l_bom_comp_tbl(i).component_item_name           := bom_comp_rec.ComponentItemName;
        l_bom_comp_tbl(i).alternate_bom_code            := bom_comp_rec.AlternateBomCode;
        IF (bom_comp_rec.NewEffectivityDate IS NOT NULL) THEN
          l_bom_comp_tbl(i).new_effectivity_date          := TO_DATE(bom_comp_rec.NewEffectivityDate, 'YYYY-MM-DD HH24:MI:SS');
        END IF;
        l_bom_comp_tbl(i).new_operation_sequence_number := bom_comp_rec.NewOperationSequenceNumber;
        l_bom_comp_tbl(i).item_sequence_number          := bom_comp_rec.ItemSequenceNumber;
        l_bom_comp_tbl(i).quantity_per_assembly         := TO_NUMBER(bom_comp_rec.QuantityPerAssembly);
        l_bom_comp_tbl(i).planning_percent              := bom_comp_rec.PlanningPercent;
        l_bom_comp_tbl(i).projected_yield               := TO_NUMBER(bom_comp_rec.ProjectedYield);
        l_bom_comp_tbl(i).include_in_cost_rollup        := bom_comp_rec.IncludeInCostRollup;
        l_bom_comp_tbl(i).wip_supply_type               := bom_comp_rec.WipSupplyType;
        l_bom_comp_tbl(i).so_basis                      := bom_comp_rec.SoBasis;
        l_bom_comp_tbl(i).optional                      := bom_comp_rec.Optional;
        l_bom_comp_tbl(i).mutually_exclusive            := bom_comp_rec.MutuallyExclusive;
        l_bom_comp_tbl(i).check_atp                     := bom_comp_rec.CheckAtp;
        l_bom_comp_tbl(i).shipping_allowed              := bom_comp_rec.ShippingAllowed;
        l_bom_comp_tbl(i).required_to_ship              := bom_comp_rec.RequiredToShip;
        l_bom_comp_tbl(i).required_for_revenue          := bom_comp_rec.RequiredForRevenue;
        l_bom_comp_tbl(i).include_on_ship_docs          := bom_comp_rec.IncludeOnShipDocs;
        l_bom_comp_tbl(i).quantity_related              := bom_comp_rec.QuantityRelated;
        l_bom_comp_tbl(i).supply_subinventory           := bom_comp_rec.SupplySubinventory;
        l_bom_comp_tbl(i).location_name                 := bom_comp_rec.LocationName;
        l_bom_comp_tbl(i).minimum_allowed_quantity      := TO_NUMBER(bom_comp_rec.MinimumAllowedQuantity);
        l_bom_comp_tbl(i).maximum_allowed_quantity      := TO_NUMBER(bom_comp_rec.MaximumAllowedQuantity);
        l_bom_comp_tbl(i).comments                      := bom_comp_rec.Comments;
        l_bom_comp_tbl(i).attribute_category            := bom_comp_rec.AttributeCategory;
        l_bom_comp_tbl(i).attribute1                    := bom_comp_rec.Attribute1;
        l_bom_comp_tbl(i).attribute2                    := bom_comp_rec.Attribute2;
        l_bom_comp_tbl(i).attribute3                    := bom_comp_rec.Attribute3;
        l_bom_comp_tbl(i).attribute4                    := bom_comp_rec.Attribute4;
        l_bom_comp_tbl(i).attribute5                    := bom_comp_rec.Attribute5;
        l_bom_comp_tbl(i).attribute6                    := bom_comp_rec.Attribute6;
        l_bom_comp_tbl(i).attribute7                    := bom_comp_rec.Attribute7;
        l_bom_comp_tbl(i).attribute8                    := bom_comp_rec.Attribute8;
        l_bom_comp_tbl(i).attribute9                    := bom_comp_rec.Attribute9;
        l_bom_comp_tbl(i).attribute10                   := bom_comp_rec.Attribute10;
        l_bom_comp_tbl(i).attribute11                   := bom_comp_rec.Attribute11;
        l_bom_comp_tbl(i).attribute12                   := bom_comp_rec.Attribute12;
        l_bom_comp_tbl(i).attribute13                   := bom_comp_rec.Attribute13;
        l_bom_comp_tbl(i).attribute14                   := bom_comp_rec.Attribute14;
        l_bom_comp_tbl(i).attribute15                   := bom_comp_rec.Attribute15;
        l_bom_comp_tbl(i).from_end_item_unit_number     := bom_comp_rec.FromEndItemUnitNumber;
        l_bom_comp_tbl(i).new_from_end_item_unit_number := bom_comp_rec.NewFromEndItemUnitNumber;
        l_bom_comp_tbl(i).to_end_item_unit_number       := bom_comp_rec.ToEndItemUnitNumber;
        l_bom_comp_tbl(i).return_status                 := bom_comp_rec.ReturnStatus;
        l_bom_comp_tbl(i).transaction_type              := bom_comp_rec.TransactionType;
        l_bom_comp_tbl(i).original_system_reference     := bom_comp_rec.OriginalSystemReference;
        l_bom_comp_tbl(i).delete_group_name             := bom_comp_rec.DeleteGroupName;
        l_bom_comp_tbl(i).dg_description                := bom_comp_rec.DgDescription;
        l_bom_comp_tbl(i).enforce_int_requirements      := bom_comp_rec.EnforceIntRequirements;
        l_bom_comp_tbl(i).auto_request_material         := bom_comp_rec.AutoRequestMaterial;
        l_bom_comp_tbl(i).row_identifier                := bom_comp_rec.RowIdentifier;
        l_bom_comp_tbl(i).suggested_vendor_name         := bom_comp_rec.SuggestedVendorName;
        l_bom_comp_tbl(i).unit_price                    := bom_comp_rec.UnitPrice;
	l_bom_comp_tbl(i).Basis_type	                := bom_comp_rec.BasisType;	--myerrams, bug:4873339
        i := i + 1;
      END LOOP;
    END IF;
    IF (P_bom_sub_comps_XML IS NOT NULL) THEN
/*
      -- Bom Substitute Components Table
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_SUBSTITUTE_COMPONENTS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'SubstituteComponentsVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx, P_bom_sub_comps_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
*/
      i := 1;
/*
      OPEN bom_sub_comp_CUR;
      LOOP
        FETCH bom_sub_comp_CUR INTO l_bom_sub_comp_tbl(i);
        IF (bom_sub_comp_CUR%NOTFOUND) THEN
          EXIT;
        END IF;
        i := i + 1;
      END LOOP;
*/
      FOR bom_sub_rec IN bom_sub_comp_CUR LOOP
        l_bom_sub_comp_tbl(i).organization_code      := bom_sub_rec.OrganizationCode;
        l_bom_sub_comp_tbl(i).assembly_item_name     := bom_sub_rec.AssemblyItemName;
        l_bom_sub_comp_tbl(i).start_effective_date   := TO_DATE(bom_sub_rec.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS');
        l_bom_sub_comp_tbl(i).operation_sequence_number := bom_sub_rec.OperationSequenceNumber;
        l_bom_sub_comp_tbl(i).component_item_name       := bom_sub_rec.ComponentItemName;
        l_bom_sub_comp_tbl(i).alternate_bom_code        := bom_sub_rec.AlternateBomCode;
        l_bom_sub_comp_tbl(i).substitute_component_name := bom_sub_rec.SubstituteComponentName;
        l_bom_sub_comp_tbl(i).new_substitute_component_name := bom_sub_rec.NewSubstituteComponentName;
        l_bom_sub_comp_tbl(i).substitute_item_quantity      := TO_NUMBER(bom_sub_rec.SubstituteItemQuantity);
        l_bom_sub_comp_tbl(i).attribute_category        := bom_sub_rec.AttributeCategory;
        l_bom_sub_comp_tbl(i).attribute1                := bom_sub_rec.Attribute1;
        l_bom_sub_comp_tbl(i).attribute2                := bom_sub_rec.Attribute2;
        l_bom_sub_comp_tbl(i).attribute3                := bom_sub_rec.Attribute3;
        l_bom_sub_comp_tbl(i).attribute4                := bom_sub_rec.Attribute4;
        l_bom_sub_comp_tbl(i).attribute5                := bom_sub_rec.Attribute5;
        l_bom_sub_comp_tbl(i).attribute6                := bom_sub_rec.Attribute6;
        l_bom_sub_comp_tbl(i).attribute7                := bom_sub_rec.Attribute7;
        l_bom_sub_comp_tbl(i).attribute8                := bom_sub_rec.Attribute8;
        l_bom_sub_comp_tbl(i).attribute9                := bom_sub_rec.Attribute9;
        l_bom_sub_comp_tbl(i).attribute10               := bom_sub_rec.Attribute10;
        l_bom_sub_comp_tbl(i).attribute11               := bom_sub_rec.Attribute11;
        l_bom_sub_comp_tbl(i).attribute12               := bom_sub_rec.Attribute12;
        l_bom_sub_comp_tbl(i).attribute13               := bom_sub_rec.Attribute13;
        l_bom_sub_comp_tbl(i).attribute14               := bom_sub_rec.Attribute14;
        l_bom_sub_comp_tbl(i).attribute15               := bom_sub_rec.Attribute15;
        l_bom_sub_comp_tbl(i).program_id                := bom_sub_rec.ProgramId;
        l_bom_sub_comp_tbl(i).from_end_item_unit_number := bom_sub_rec.FromEndItemUnitNumber;
        l_bom_sub_comp_tbl(i).enforce_int_requirements  := bom_sub_rec.EnforceIntRequirements;
        l_bom_sub_comp_tbl(i).original_system_reference := bom_sub_rec.OriginalSystemReference;
        l_bom_sub_comp_tbl(i).return_status             := bom_sub_rec.ReturnStatus;
        l_bom_sub_comp_tbl(i).transaction_type          := bom_sub_rec.TransactionType;
        l_bom_sub_comp_tbl(i).row_identifier            := bom_sub_rec.RowIdentifier;
        i := i + 1;
      END LOOP;
    END IF;
    IF (P_bom_ref_desgs_XML IS NOT NULL) THEN
/*
      -- Bom Reference Designators Table
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_REFERENCE_DESIGNATORS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'ReferenceDesignatorsVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx, P_bom_ref_desgs_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
*/

      i := 1;
/*
      OPEN bom_ref_desig_CUR;
      LOOP
        FETCH bom_ref_desig_CUR INTO l_bom_ref_desig_tbl(i);
        IF (bom_ref_desig_CUR%NOTFOUND) THEN
          EXIT;
        END IF;
        i := i + 1;
      END LOOP;
*/
      FOR bom_ref_desig_rec IN bom_ref_desig_CUR LOOP
        l_bom_ref_desig_tbl(i).organization_code         := bom_ref_desig_rec.OrganizationCode;
        l_bom_ref_desig_tbl(i).assembly_item_name        := bom_ref_desig_rec.AssemblyItemName;
        l_bom_ref_desig_tbl(i).start_effective_date      := TO_DATE(bom_ref_desig_rec.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS');
        l_bom_ref_desig_tbl(i).operation_sequence_number := bom_ref_desig_rec.OperationSequenceNumber;
        l_bom_ref_desig_tbl(i).component_item_name       := bom_ref_desig_rec.ComponentItemName;
        l_bom_ref_desig_tbl(i).alternate_bom_code        := bom_ref_desig_rec.AlternateBomCode;
        l_bom_ref_desig_tbl(i).reference_designator_name := bom_ref_desig_rec.ReferenceDesignatorName;
        l_bom_ref_desig_tbl(i).ref_designator_comment    := bom_ref_desig_rec.RefDesignatorComment;
        l_bom_ref_desig_tbl(i).attribute_category        := bom_ref_desig_rec.AttributeCategory;
        l_bom_ref_desig_tbl(i).attribute1                := bom_ref_desig_rec.Attribute1;
        l_bom_ref_desig_tbl(i).attribute2                := bom_ref_desig_rec.Attribute2;
        l_bom_ref_desig_tbl(i).attribute3                := bom_ref_desig_rec.Attribute3;
        l_bom_ref_desig_tbl(i).attribute4                := bom_ref_desig_rec.Attribute4;
        l_bom_ref_desig_tbl(i).attribute5                := bom_ref_desig_rec.Attribute5;
        l_bom_ref_desig_tbl(i).attribute6                := bom_ref_desig_rec.Attribute6;
        l_bom_ref_desig_tbl(i).attribute7                := bom_ref_desig_rec.Attribute7;
        l_bom_ref_desig_tbl(i).attribute8                := bom_ref_desig_rec.Attribute8;
        l_bom_ref_desig_tbl(i).attribute9                := bom_ref_desig_rec.Attribute9;
        l_bom_ref_desig_tbl(i).attribute10               := bom_ref_desig_rec.Attribute10;
        l_bom_ref_desig_tbl(i).attribute11               := bom_ref_desig_rec.Attribute11;
        l_bom_ref_desig_tbl(i).attribute12               := bom_ref_desig_rec.Attribute12;
        l_bom_ref_desig_tbl(i).attribute13               := bom_ref_desig_rec.Attribute13;
        l_bom_ref_desig_tbl(i).attribute14               := bom_ref_desig_rec.Attribute14;
        l_bom_ref_desig_tbl(i).attribute15               := bom_ref_desig_rec.Attribute15;
        l_bom_ref_desig_tbl(i).from_end_item_unit_number := bom_ref_desig_rec.FromEndItemUnitNumber;
        l_bom_ref_desig_tbl(i).original_system_reference := bom_ref_desig_rec.OriginalSystemReference;
        l_bom_ref_desig_tbl(i).new_reference_designator  := bom_ref_desig_rec.NewReferenceDesignator;
        l_bom_ref_desig_tbl(i).return_status             := bom_ref_desig_rec.ReturnStatus;
        l_bom_ref_desig_tbl(i).transaction_type          := bom_ref_desig_rec.TransactionType;
        l_bom_ref_desig_tbl(i).row_identifier            := bom_ref_desig_rec.RowIdentifier;
        i := i + 1;
      END LOOP;
    END IF;
    IF (P_bom_comp_oper_XML IS NOT NULL) THEN
/*
      -- Bom Component Operations Table
      -- get the context handle
      insCtx := DBMS_XMLSave.newContext('BOM_COMPONENT_OPERATIONS_TEMP');
      DBMS_XMLSave.setIgnoreCase(insCtx, 1);
      DBMS_XMLSave.setDateFormat(insCtx, 'yyyy-MM-dd HH:mm:ss');
      DBMS_XMLSave.setRowTag(insCtx , 'ComponentOperationsVO');
      -- this inserts the document
      rows := DBMS_XMLSave.insertXML(insCtx, P_bom_comp_oper_XML);
      -- this closes the handle
      DBMS_XMLSave.closeContext(insCtx);
*/
      i := 1;
/*
      OPEN bom_comp_oper_CUR;
      LOOP
        FETCH bom_comp_oper_CUR INTO l_bom_comp_oper_tbl(i);
        IF (bom_comp_oper_CUR%NOTFOUND) THEN
          EXIT;
        END IF;
        i := i + 1;
      END LOOP;
*/
      FOR bom_comp_oper_rec IN bom_comp_oper_CUR LOOP
        l_bom_comp_oper_tbl(i).organization_code             := bom_comp_oper_rec.OrganizationCode;
        l_bom_comp_oper_tbl(i).assembly_item_name            := bom_comp_oper_rec.AssemblyItemName;
        l_bom_comp_oper_tbl(i).start_effective_date          := TO_DATE(bom_comp_oper_rec.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS');
        l_bom_comp_oper_tbl(i).from_end_item_unit_number     := bom_comp_oper_rec.FromEndItemUnitNumber;
        l_bom_comp_oper_tbl(i).to_end_item_unit_number       := bom_comp_oper_rec.ToEndItemUnitNumber;
        l_bom_comp_oper_tbl(i).operation_sequence_number     := bom_comp_oper_rec.OperationSequenceNumber;
        l_bom_comp_oper_tbl(i).additional_operation_seq_num  := bom_comp_oper_rec.AdditionalOperationSeqNum;
        l_bom_comp_oper_tbl(i).new_additional_op_seq_num     := bom_comp_oper_rec.NewAdditionalOpSeqNum;
        l_bom_comp_oper_tbl(i).component_item_name           := bom_comp_oper_rec.ComponentItemName;
        l_bom_comp_oper_tbl(i).alternate_bom_code            := bom_comp_oper_rec.AlternateBomCode;
        l_bom_comp_oper_tbl(i).attribute_category            := bom_comp_oper_rec.AttributeCategory;
        l_bom_comp_oper_tbl(i).attribute1                    := bom_comp_oper_rec.Attribute1;
        l_bom_comp_oper_tbl(i).attribute2                    := bom_comp_oper_rec.Attribute2;
        l_bom_comp_oper_tbl(i).attribute3                    := bom_comp_oper_rec.Attribute3;
        l_bom_comp_oper_tbl(i).attribute4                    := bom_comp_oper_rec.Attribute4;
        l_bom_comp_oper_tbl(i).attribute5                    := bom_comp_oper_rec.Attribute5;
        l_bom_comp_oper_tbl(i).attribute6                    := bom_comp_oper_rec.Attribute6;
        l_bom_comp_oper_tbl(i).attribute7                    := bom_comp_oper_rec.Attribute7;
        l_bom_comp_oper_tbl(i).attribute8                    := bom_comp_oper_rec.Attribute8;
        l_bom_comp_oper_tbl(i).attribute9                    := bom_comp_oper_rec.Attribute9;
        l_bom_comp_oper_tbl(i).attribute10                   := bom_comp_oper_rec.Attribute10;
        l_bom_comp_oper_tbl(i).attribute11                   := bom_comp_oper_rec.Attribute11;
        l_bom_comp_oper_tbl(i).attribute12                   := bom_comp_oper_rec.Attribute12;
        l_bom_comp_oper_tbl(i).attribute13                   := bom_comp_oper_rec.Attribute13;
        l_bom_comp_oper_tbl(i).attribute14                   := bom_comp_oper_rec.Attribute14;
        l_bom_comp_oper_tbl(i).attribute15                   := bom_comp_oper_rec.Attribute15;
        l_bom_comp_oper_tbl(i).return_status                 := bom_comp_oper_rec.ReturnStatus;
        l_bom_comp_oper_tbl(i).transaction_type              := bom_comp_oper_rec.TransactionType;
        l_bom_comp_oper_tbl(i).row_identifier                := bom_comp_oper_rec.RowIdentifier;
        i := i + 1;
      END LOOP;
    END IF;

    BOM_GLOBALS.Set_Caller_Type('MIGRATION');
    BOM_BO_PUB.Process_Bom(p_bom_header_tbl         => l_bom_header_tbl,
--Bug 3349138                          p_bom_revision_tbl       => l_bom_revisions_tbl,
                           p_bom_component_tbl      => l_bom_comp_tbl,
                           p_bom_ref_designator_tbl => l_bom_ref_desig_tbl,
                           p_bom_sub_component_tbl  => l_bom_sub_comp_tbl,
                           p_bom_comp_ops_tbl       => l_bom_comp_oper_tbl,
                           x_bom_header_tbl         => X_bom_header_tbl,
                           x_bom_revision_tbl       => X_bom_revisions_tbl,
                           x_bom_component_tbl      => X_bom_comp_tbl,
                           x_bom_ref_designator_tbl => X_bom_ref_desig_tbl,
                           x_bom_sub_component_tbl  => X_bom_sub_comp_tbl,
                           x_bom_comp_ops_tbl       => X_bom_comp_oper_tbl,
                           x_return_status          => X_return_status,
                           x_msg_count              => X_msg_count,
                           p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename);

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
  END IF;
  EXCEPTION
      WHEN OTHERS THEN
       X_G_msg_data := X_G_msg_data || 'In Import_BOM exception' || FND_GLOBAL.NewLine || sqlerrm(sqlcode);

END Import_Bom;

END BOM_BOM_ISETUP_IMP;

/
