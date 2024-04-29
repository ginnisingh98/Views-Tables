--------------------------------------------------------
--  DDL for Package Body BOM_BOM_COPYORG_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOM_COPYORG_IMP" AS
/* $Header: BOMBOCPB.pls 120.2.12000000.2 2007/02/26 11:35:32 myerrams ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBOCPB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_BOM_COPYORG_IMP
--
--  NOTES
--
--  HISTORY
--
--  05-JUN-06  Mohan Yerramsetty  Bug# 5142847, Initial Creation.
--                                This package has PL/SQL logic of Copying
--				  BOMs. It doesn't use Exporting to XML,
--				  Importing from XML Logic. This will fetch
--				  all Boms from source organization and
--				  pass all the records to Bom Interface.
--				  Bom Interface will do the copying.
--  03-JUL-06  Mohan Yerramsetty  Added ImplementationDate to bom_bill_of_materials_temp table
--				  Added BasisType to bom_inventory_components_temp table
--				  Bug: 5174575
--  11-NOV-06  Mohan Yerramsetty  Modified the code to delete the successfully processed
--				  records after the call to BOM_BO_PUB.Process_Bom to reduce
--				  the memory consumed by the process. Bug: 5654718
--  21-FEB-07  Mohan Yerramsetty  Bug# 5592181, Modified the code to delete
--                                unnecessary Log messages and to modify the logic of
--				  returning the value of ReturnStatus.
***************************************************************************/
/* myerrams, Bug: 5142847 */
  G_PKG_NAME		   CONSTANT	VARCHAR2(50) := 'BOM_BOM_COPYORG_IMP';
  g_fnd_debug		   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
  G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'copyboms.plsql.' || G_PKG_NAME || '.';
  g_api_name CONSTANT	   VARCHAR2(30) := 'Import_BOM';
  g_X_return_status	   VARCHAR2(10);		--myerrams, Bug: 5592181
  g_status_set		   BOOLEAN	:= FALSE;	--myerrams, Bug: 5592181


PROCEDURE CALL_PROCESS_BOM(P_debug             IN VARCHAR2,
                     P_output_dir        IN VARCHAR2,
                     P_debug_filename    IN VARCHAR2,
                     p_bom_header_tbl    IN BOM_BO_PUB.BOM_HEADER_TBL_TYPE ,
                     p_bom_component_tbl      IN BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     p_bom_ref_designator_tbl IN BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     p_bom_sub_component_tbl  IN BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     p_bom_comp_ops_tbl       IN BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_bom_header_tbl    IN OUT NOCOPY BOM_BO_PUB.BOM_HEADER_TBL_TYPE ,
                     X_bom_revisions_tbl IN OUT NOCOPY BOM_BO_PUB.Bom_Revision_Tbl_Type,
                     X_bom_comp_tbl      IN OUT NOCOPY BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     X_bom_ref_desig_tbl IN OUT NOCOPY BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     X_bom_sub_comp_tbl  IN OUT NOCOPY BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     X_bom_comp_oper_tbl IN OUT NOCOPY BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_return_status     IN OUT NOCOPY VARCHAR2,	--myerrams, Bug: 5592181
                     X_G_msg_data        OUT NOCOPY LONG,
                     X_msg_count         OUT NOCOPY NUMBER
);

PROCEDURE Import_BOM(P_debug             IN VARCHAR2 := 'N',
                     P_output_dir        IN VARCHAR2 := NULL,
                     P_debug_filename    IN VARCHAR2 := 'BOM_BO_debug.log',
		     p_model_org_id	 NUMBER,
		     p_target_orgcode	 VARCHAR2,
                     X_return_status     OUT NOCOPY VARCHAR2,
                     X_msg_count         OUT NOCOPY NUMBER,
                     X_G_msg_data        OUT NOCOPY LONG,
		     p_bomthreshold	 IN VARCHAR2 ) IS

  l_bom_header_tbl         BOM_BO_PUB.BOM_HEADER_TBL_TYPE ;
  l_bom_comp_tbl           BOM_BO_PUB.BOM_COMPS_TBL_TYPE;
  l_bom_header_tbl_rec     BOM_BO_PUB.Bom_Head_Rec_Type ;
  l_bom_comp_tbl_rec       BOM_BO_PUB.Bom_Comps_Rec_Type ;
  l_bom_ref_desig_tbl      BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE;
  l_bom_sub_comp_tbl       BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE;
  l_bom_comp_oper_tbl      BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE;
  X_bom_header_tbl         BOM_BO_PUB.BOM_HEADER_TBL_TYPE ;
  X_bom_revisions_tbl      BOM_BO_PUB.BOM_REVISION_TBL_TYPE;
  X_bom_comp_tbl           BOM_BO_PUB.BOM_COMPS_TBL_TYPE;
  X_bom_ref_desig_tbl      BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE;
  X_bom_sub_comp_tbl       BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE;
  X_bom_comp_oper_tbl      BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE;
/* myerrams, Bug: 5142847; End; */

  CURSOR bom_header_temp_CUR IS
  SELECT bom.BILL_SEQUENCE_ID		BILL_SEQUENCE_ID,	--myerrams, Bug: 5142847
       item1.concatenated_segments	AssemblyItemName,
       p_target_orgcode			OrganizationCode,
       bom.alternate_bom_designator	AlternateBomCode,
       item2.concatenated_segments	CommonAssemblyItemName,
       org2.organization_code		CommonOrganizationCode,
       bom.specific_assembly_comment	AssemblyComment,
       bom.assembly_type		AssemblyType,
       'CREATE'				TransactionType,
       NULL				ReturnStatus,
       bom.attribute_category		AttributeCategory,
       bom.attribute1			Attribute1,
       bom.attribute2			Attribute2,
       bom.attribute3			Attribute3,
       bom.attribute4			Attribute4,
       bom.attribute5			Attribute5,
       bom.attribute6			Attribute6,
       bom.attribute7			Attribute7,
       bom.attribute8			Attribute8,
       bom.attribute9			Attribute9,
       bom.attribute10			Attribute10,
       bom.attribute11			Attribute11,
       bom.attribute12			Attribute12,
       bom.attribute13			Attribute13,
       bom.attribute14			Attribute14,
       bom.attribute15			Attribute15,
       bom.original_system_reference	OriginalSystemReference,
       NULL				DeleteGroupName,
       NULL				DGDescription,
       NULL				RowIdentifier,
       to_char(bom.implementation_date,'YYYY-MM-DD HH24:MI:SS')	ImplementationDate	--Bug: 5174575: New attribute added for R12
FROM   bom_bill_of_materials bom,
       mtl_system_items_kfv item1,
       mtl_parameters org1,
       mtl_parameters org2,
       mtl_system_items_kfv item2
WHERE  org1.organization_id       = bom.organization_id
AND    item1.organization_id      = bom.organization_id
AND    item1.inventory_item_id    = bom.assembly_item_id
AND    org2.organization_id(+)    = bom.common_organization_id
AND    item2.organization_id(+)   = bom.common_organization_id
AND    item2.inventory_item_id(+) = bom.common_assembly_item_id
AND    bom.organization_id        = p_model_org_id
Order by bom.alternate_bom_designator desc, bom.assembly_item_id;	--myerrams, Bug: 5142847

--myerrams, Bug: 5142847  CURSOR bom_comp_CUR IS
  CURSOR bom_comp_CUR (BILL_SEQUENCE_ID_VAR IN NUMBER) IS
SELECT comp.COMPONENT_SEQUENCE_ID	COMPONENT_SEQUENCE_ID,	--myerrams, Bug: 5142847
       p_target_orgcode			OrganizationCode,
       item1.concatenated_segments 	AssemblyItemName,
       TO_CHAR(comp.effectivity_date,'YYYY-MM-DD HH24:MI:SS') StartEffectiveDate,
       TO_CHAR(comp.disable_date, 'YYYY-MM-DD HH24:MI:SS') DisableDate,
       comp.operation_seq_num 		OperationSequenceNumber,
       item2.concatenated_segments 	ComponentItemName,
       bom.alternate_bom_designator 	AlternateBOMCode,
       null 				NewEffectivityDate,
       null 				NewOperationSequenceNumber,
       item_num 			ItemSequenceNumber,
       comp.component_quantity 		QuantityPerAssembly,
       comp.planning_factor 		PlanningPercent,
       comp.component_yield_factor 	ProjectedYield,
       comp.include_in_cost_rollup	IncludeInCostRollup,
       comp.wip_supply_type		WipSupplyType,
       comp.so_basis			SoBasis,
       comp.optional			Optional,
       comp.mutually_exclusive_options  MutuallyExclusive,
       comp.check_atp			CheckAtp,
       comp.shipping_allowed		ShippingAllowed,
       comp.required_to_ship		RequiredToShip,
       comp.required_for_revenue	RequiredForRevenue,
       comp.include_on_ship_docs	IncludeOnShipDocs,
       comp.quantity_related		QuantityRelated,
       comp.supply_subinventory		SupplySubinventory,
       null 				LocationName,
       comp.low_quantity 		MinimumAllowedQuantity,
       comp.high_quantity 		MaximumAllowedQuantity,
       comp.component_remarks 		Comments,
       comp.attribute_category		AttributeCategory,
       comp.attribute1			Attribute1,
       comp.attribute2			Attribute2,
       comp.attribute3			Attribute3,
       comp.attribute4			Attribute4,
       comp.attribute5			Attribute5,
       comp.attribute6			Attribute6,
       comp.attribute7			Attribute7,
       comp.attribute8			Attribute8,
       comp.attribute9			Attribute9,
       comp.attribute10			Attribute10,
       comp.attribute11			Attribute11,
       comp.attribute12			Attribute12,
       comp.attribute13			Attribute13,
       comp.attribute14			Attribute14,
       comp.attribute15			Attribute15,
       comp.from_end_item_unit_number	FromEndItemUnitNumber,
       null 				 NewFromEndItemUnitNumber,
       comp.to_end_item_unit_number	ToEndItemUnitNumber,
       NULL				ReturnStatus,
       'CREATE' 			TransactionType,
       comp.original_system_reference	OriginalSystemReference,
       NULL				DeleteGroupName,
       NULL				DGDescription,
       comp.enforce_int_requirements	EnforceIntRequirements,
       NULL 				AutoRequestMaterial,
       NULL 				RowIdentifier,
       comp.suggested_vendor_name	SuggestedVendorName,
       comp.unit_price			UnitPrice,
       comp.basis_type			BasisType	--Bug: 5174575: New attribute added for R12
FROM   bom_inventory_components comp,
       mtl_system_items_kfv item1,
       mtl_parameters org,
       bom_bill_of_materials bom,
       mtl_system_items_kfv item2
WHERE  bom.bill_sequence_id    = comp.bill_sequence_id
AND    org.organization_id     = bom.organization_id
AND    item1.organization_id   = bom.organization_id
AND    item1.inventory_item_id = bom.assembly_item_id
AND    item2.organization_id   = bom.organization_id
AND    item2.inventory_item_id = comp.component_item_id
AND    bom.organization_id     = p_model_org_id
and    comp.BILL_SEQUENCE_ID = BILL_SEQUENCE_ID_VAR;	--myerrams, Bug: 5142847

--myerrams, Bug: 5142847  CURSOR bom_sub_comp_CUR IS
  CURSOR bom_sub_comp_CUR (COMPONENT_SEQUENCE_ID_VAR IN NUMBER) IS
SELECT p_target_orgcode			OrganizationCode,
       item1.concatenated_segments 	AssemblyItemName,
       TO_CHAR(comp.effectivity_date, 'YYYY-MM-DD HH24:MI:SS') StartEffectiveDate,
       comp.operation_seq_num 		OperationSequenceNumber,
       item3.concatenated_segments 	ComponentItemName,
       bom.alternate_bom_designator 	AlternateBomCode,
       item2.concatenated_segments 	SubstituteComponentName,
       NULL 				NewSubstituteComponentName,
       sub.substitute_item_quantity	SubstituteItemQuantity,
       sub.attribute_category		AttributeCategory,
       sub.attribute1			Attribute1,
       sub.attribute2			Attribute2,
       sub.attribute3			Attribute3,
       sub.attribute4			Attribute4,
       sub.attribute5			Attribute5,
       sub.attribute6			Attribute6,
       sub.attribute7			Attribute7,
       sub.attribute8			Attribute8,
       sub.attribute9			Attribute9,
       sub.attribute10			Attribute10,
       sub.attribute11			Attribute11,
       sub.attribute12			Attribute12,
       sub.attribute13			Attribute13,
       sub.attribute14			Attribute14,
       sub.attribute15			Attribute15,
       null				ProgramId,
       null 				FromEndItemUnitNumber,
       sub.enforce_int_requirements	EnforceIntRequirements,
       sub.original_system_reference	OriginalSystemReference,
       NULL      			ReturnStatus,
       'CREATE'				TransactionType,
       NULL 				RowIdentifier
FROM   bom_substitute_components sub,
       mtl_system_items_kfv item1,
       mtl_parameters org,
       bom_bill_of_materials bom,
       bom_inventory_components comp,
       mtl_system_items_kfv item2,
       mtl_system_items_kfv item3
WHERE  comp.component_sequence_id = sub.component_sequence_id
AND    bom.bill_sequence_id       = comp.bill_sequence_id
AND    org.organization_id        = bom.organization_id
AND    item1.inventory_item_id    = bom.assembly_item_id
AND    item1.organization_id      = bom.organization_id
AND    item2.inventory_item_id    = sub.substitute_component_id
AND    item2.organization_id      = bom.organization_id
AND    item3.organization_id      = bom.organization_id
AND    item3.inventory_item_id    = comp.component_item_id
AND    bom.organization_id 	  = p_model_org_id
AND    sub.COMPONENT_SEQUENCE_ID = COMPONENT_SEQUENCE_ID_VAR;	--myerrams, Bug: 5142847

--myerrams, Bug: 5142847  CURSOR bom_ref_desig_CUR IS
  CURSOR bom_ref_desig_CUR (COMPONENT_SEQUENCE_ID_VAR IN NUMBER) IS
SELECT p_target_orgcode			OrganizationCode,
       item1.concatenated_segments 	AssemblyItemName,
       TO_CHAR(comp.effectivity_date, 'YYYY-MM-DD HH24:MI:SS') StartEffectiveDate,
       comp.operation_seq_num 		OperationSequenceNumber,
       item2.concatenated_segments 	ComponentItemName,
       bom.alternate_bom_designator 	AlternateBomCode,
       ref.component_reference_designator ReferenceDesignatorName,
       ref.ref_designator_comment	RefDesignatorComment,
       ref.attribute_category		AttributeCategory,
       ref.attribute1			Attribute1,
       ref.attribute2			Attribute2,
       ref.attribute3			Attribute3,
       ref.attribute4			Attribute4,
       ref.attribute5			Attribute5,
       ref.attribute6			Attribute6,
       ref.attribute7			Attribute7,
       ref.attribute8			Attribute8,
       ref.attribute9			Attribute9,
       ref.attribute10			Attribute10,
       ref.attribute11			Attribute11,
       ref.attribute12			Attribute12,
       ref.attribute13			Attribute13,
       ref.attribute14			Attribute14,
       ref.attribute15			Attribute15,
       null 				FromEndItemUnitNumber,
       ref.original_system_reference	OriginalSystemReference,
       null 				NewReferenceDesignator,
       NULL     			ReturnStatus,
       'CREATE' 			TransactionType,
       NULL 				RowIdentifier
FROM   bom_reference_designators ref,
       mtl_system_items_kfv item1,
       mtl_parameters org,
       bom_inventory_components comp,
       mtl_system_items_kfv item2,
       bom_bill_of_materials bom
WHERE  comp.component_sequence_id = ref.component_sequence_id
AND    bom.bill_sequence_id       = comp.bill_sequence_id
AND    org.organization_id        = bom.organization_id
AND    item1.organization_id      = bom.organization_id
AND    item1.inventory_item_id    = bom.assembly_item_id
AND    item2.organization_id      = bom.organization_id
AND    item2.inventory_item_id    = comp.component_item_id
AND    bom.organization_id 	  = p_model_org_id
AND    ref.COMPONENT_SEQUENCE_ID = COMPONENT_SEQUENCE_ID_VAR;	--myerrams, Bug: 5142847

--myerrams, Bug: 5142847  CURSOR bom_comp_oper_CUR IS
  CURSOR bom_comp_oper_CUR (BILL_SEQUENCE_ID_VAR IN NUMBER, COMPONENT_SEQUENCE_ID_VAR IN NUMBER) IS
SELECT p_target_orgcode			OrganizationCode,
       item1.concatenated_segments 	AssemblyItemName,
       to_char(comp.effectivity_date,'YYYY-MM-DD HH24:MI:SS') StartEffectiveDate,
       null 				FromEndItemUnitNumber,
       null 				ToEndItemUnitNumber,
       comp.operation_seq_num		OperationSequenceNumber,
       comp_oper.operation_seq_num	AdditionalOperationSeqNum,
       NULL 				NewAdditionalOpSeqNum,
       item2.concatenated_segments 	ComponentItemName,
       bom.alternate_bom_designator 	AlternateBOMCode,
       comp_oper.attribute_category	Attributecategory,
       comp_oper.attribute1		Attribute1,
       comp_oper.attribute2		Attribute2,
       comp_oper.attribute3		Attribute3,
       comp_oper.attribute4		Attribute4,
       comp_oper.attribute5		Attribute5,
       comp_oper.attribute6		Attribute6,
       comp_oper.attribute7		Attribute7,
       comp_oper.attribute8		Attribute8,
       comp_oper.attribute9		Attribute9,
       comp_oper.attribute10		Attribute10,
       comp_oper.attribute11		Attribute11,
       comp_oper.attribute12		Attribute12,
       comp_oper.attribute13		Attribute13,
       comp_oper.attribute14		Attribute14,
       comp_oper.attribute15		Attribute15,
       NULL     			ReturnStatus,
       'CREATE' 			TransactionType,
       NULL 				RowIdentifier
FROM   bom_component_operations comp_oper,
       mtl_system_items_kfv item1,
       mtl_parameters org,
       bom_inventory_components comp,
       mtl_system_items_kfv item2,
       bom_bill_of_materials bom
WHERE  comp.component_sequence_id = comp_oper.component_sequence_id
AND    bom.bill_sequence_id       = comp.bill_sequence_id
AND    org.organization_id        = bom.organization_id
AND    item1.organization_id      = bom.organization_id
AND    item1.inventory_item_id    = bom.assembly_item_id
AND    item2.organization_id      = bom.organization_id
AND    item2.inventory_item_id    = comp.component_item_id
AND    bom.organization_id 	  = p_model_org_id
AND    comp_oper.COMPONENT_SEQUENCE_ID = COMPONENT_SEQUENCE_ID_VAR
AND    comp_oper.BILL_SEQUENCE_ID = BILL_SEQUENCE_ID_VAR;		--myerrams, Bug: 5142847


/* myerrams, Bug: 5142847; Following Variables are used for looping through the Header and its related entities */
  i				NUMBER;
  j				NUMBER;
  k				NUMBER;
  l				NUMBER;
  m				NUMBER;

  l_threshold_count		NUMBER;
  l_threshold_value		NUMBER;
  l_submit_flag			BOOLEAN;
  l_BILL_SEQUENCE_ID		NUMBER;
  l_COMPONENT_SEQUENCE_ID	NUMBER;


/* Following variables are used for logging messages */
  l_message			VARCHAR2(2000) := NULL;
  l_entity			VARCHAR2(3)    := NULL;
  l_msg_index			NUMBER;
  l_message_type		VARCHAR2(1);

BEGIN
/*myerrams, to make sure that Return Status is not null when the model org doesn't have any Boms to copy*/
X_return_status := 'S';
--myerrams, Bug: 5142847; Default the Threshold value to 10,000 in case if it is null
  IF p_bomthreshold IS NOT NULL THEN
	l_threshold_value := TO_NUMBER(p_bomthreshold);
  ELSE
	l_threshold_value := 10000;
  END IF;
  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || g_api_name || '.begin'
                  , NULL);
  END IF;

/* myerrams, Bug: 5142847; Initialize all the count variables */
  i := 1;
  j := 1;
  k := 1;
  l := 1;
  m := 1;

  l_threshold_count := 1;
  l_submit_flag := FALSE;

  FOR bom_header_rec IN bom_header_temp_CUR LOOP
    l_BILL_SEQUENCE_ID				      := bom_header_rec.BILL_SEQUENCE_ID; --myerrams, Bug: 5142847
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
    l_bom_header_tbl(i).delete_group_name             := bom_header_rec.DeleteGroupName;
    l_bom_header_tbl(i).dg_description                := bom_header_rec.DGDescription;
    l_bom_header_tbl(i).row_identifier                := bom_header_rec.RowIdentifier;
    --Bug: 5174575: New attribute added for R12
    IF (bom_header_rec.ImplementationDate IS NOT NULL) THEN
      l_bom_header_tbl(i).Bom_Implementation_Date     := TO_DATE(bom_header_rec.ImplementationDate, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

/* myerrams, Bug: 5142847; Check out if the threshold has reached*/
    l_threshold_count := l_threshold_count + 1;
    IF l_threshold_count >= l_threshold_value then
	l_submit_flag := TRUE;
    END IF;
  l_bom_header_tbl_rec := l_bom_header_tbl(i);

      FOR bom_comp_rec IN bom_comp_CUR (l_BILL_SEQUENCE_ID) LOOP
	l_COMPONENT_SEQUENCE_ID				:= bom_comp_rec.COMPONENT_SEQUENCE_ID;
        l_bom_comp_tbl(j).organization_code             := bom_comp_rec.OrganizationCode;
        l_bom_comp_tbl(j).assembly_item_name            := bom_comp_rec.AssemblyItemName;
        l_bom_comp_tbl(j).start_effective_date          := TO_DATE(bom_comp_rec.StartEffectiveDate, 'YYYY-MM-DD HH24:MI:SS');
        IF (bom_comp_rec.DisableDate IS NOT NULL) THEN
          l_bom_comp_tbl(j).disable_date                := TO_DATE(bom_comp_rec.DisableDate, 'YYYY-MM-DD HH24:MI:SS');
        END IF;
        l_bom_comp_tbl(j).operation_sequence_number     := bom_comp_rec.OperationSequenceNumber;
        l_bom_comp_tbl(j).component_item_name           := bom_comp_rec.ComponentItemName;
        l_bom_comp_tbl(j).alternate_bom_code            := bom_comp_rec.AlternateBomCode;
        IF (bom_comp_rec.NewEffectivityDate IS NOT NULL) THEN
          l_bom_comp_tbl(j).new_effectivity_date          := TO_DATE(bom_comp_rec.NewEffectivityDate, 'YYYY-MM-DD HH24:MI:SS');
        END IF;
        l_bom_comp_tbl(j).new_operation_sequence_number := bom_comp_rec.NewOperationSequenceNumber;
        l_bom_comp_tbl(j).item_sequence_number          := bom_comp_rec.ItemSequenceNumber;
        l_bom_comp_tbl(j).quantity_per_assembly         := TO_NUMBER(bom_comp_rec.QuantityPerAssembly);
        l_bom_comp_tbl(j).planning_percent              := bom_comp_rec.PlanningPercent;
        l_bom_comp_tbl(j).projected_yield               := TO_NUMBER(bom_comp_rec.ProjectedYield);
        l_bom_comp_tbl(j).include_in_cost_rollup        := bom_comp_rec.IncludeInCostRollup;
        l_bom_comp_tbl(j).wip_supply_type               := bom_comp_rec.WipSupplyType;
        l_bom_comp_tbl(j).so_basis                      := bom_comp_rec.SoBasis;
        l_bom_comp_tbl(j).optional                      := bom_comp_rec.Optional;
        l_bom_comp_tbl(j).mutually_exclusive            := bom_comp_rec.MutuallyExclusive;
        l_bom_comp_tbl(j).check_atp                     := bom_comp_rec.CheckAtp;
        l_bom_comp_tbl(j).shipping_allowed              := bom_comp_rec.ShippingAllowed;
        l_bom_comp_tbl(j).required_to_ship              := bom_comp_rec.RequiredToShip;
        l_bom_comp_tbl(j).required_for_revenue          := bom_comp_rec.RequiredForRevenue;
        l_bom_comp_tbl(j).include_on_ship_docs          := bom_comp_rec.IncludeOnShipDocs;
        l_bom_comp_tbl(j).quantity_related              := bom_comp_rec.QuantityRelated;
        l_bom_comp_tbl(j).supply_subinventory           := bom_comp_rec.SupplySubinventory;
        l_bom_comp_tbl(j).location_name                 := bom_comp_rec.LocationName;
        l_bom_comp_tbl(j).minimum_allowed_quantity      := TO_NUMBER(bom_comp_rec.MinimumAllowedQuantity);
        l_bom_comp_tbl(j).maximum_allowed_quantity      := TO_NUMBER(bom_comp_rec.MaximumAllowedQuantity);
        l_bom_comp_tbl(j).comments                      := bom_comp_rec.Comments;
        l_bom_comp_tbl(j).attribute_category            := bom_comp_rec.AttributeCategory;
        l_bom_comp_tbl(j).attribute1                    := bom_comp_rec.Attribute1;
        l_bom_comp_tbl(j).attribute2                    := bom_comp_rec.Attribute2;
        l_bom_comp_tbl(j).attribute3                    := bom_comp_rec.Attribute3;
        l_bom_comp_tbl(j).attribute4                    := bom_comp_rec.Attribute4;
        l_bom_comp_tbl(j).attribute5                    := bom_comp_rec.Attribute5;
        l_bom_comp_tbl(j).attribute6                    := bom_comp_rec.Attribute6;
        l_bom_comp_tbl(j).attribute7                    := bom_comp_rec.Attribute7;
        l_bom_comp_tbl(j).attribute8                    := bom_comp_rec.Attribute8;
        l_bom_comp_tbl(j).attribute9                    := bom_comp_rec.Attribute9;
        l_bom_comp_tbl(j).attribute10                   := bom_comp_rec.Attribute10;
        l_bom_comp_tbl(j).attribute11                   := bom_comp_rec.Attribute11;
        l_bom_comp_tbl(j).attribute12                   := bom_comp_rec.Attribute12;
        l_bom_comp_tbl(j).attribute13                   := bom_comp_rec.Attribute13;
        l_bom_comp_tbl(j).attribute14                   := bom_comp_rec.Attribute14;
        l_bom_comp_tbl(j).attribute15                   := bom_comp_rec.Attribute15;
        l_bom_comp_tbl(j).from_end_item_unit_number     := bom_comp_rec.FromEndItemUnitNumber;
        l_bom_comp_tbl(j).new_from_end_item_unit_number := bom_comp_rec.NewFromEndItemUnitNumber;
        l_bom_comp_tbl(j).to_end_item_unit_number       := bom_comp_rec.ToEndItemUnitNumber;
        l_bom_comp_tbl(j).return_status                 := bom_comp_rec.ReturnStatus;
        l_bom_comp_tbl(j).transaction_type              := bom_comp_rec.TransactionType;
        l_bom_comp_tbl(j).original_system_reference     := bom_comp_rec.OriginalSystemReference;
        l_bom_comp_tbl(j).delete_group_name             := bom_comp_rec.DeleteGroupName;
        l_bom_comp_tbl(j).dg_description                := bom_comp_rec.DgDescription;
        l_bom_comp_tbl(j).enforce_int_requirements      := bom_comp_rec.EnforceIntRequirements;
        l_bom_comp_tbl(j).auto_request_material         := bom_comp_rec.AutoRequestMaterial;
        l_bom_comp_tbl(j).row_identifier                := bom_comp_rec.RowIdentifier;
        l_bom_comp_tbl(j).suggested_vendor_name         := bom_comp_rec.SuggestedVendorName;
        l_bom_comp_tbl(j).unit_price                    := bom_comp_rec.UnitPrice;
        l_bom_comp_tbl(j).basis_type                    := bom_comp_rec.BasisType;	--Bug: 5174575: New attribute added for R12

/* myerrams, Bug: 5142847; Check out if the threshold has reached*/
    l_threshold_count := l_threshold_count + 1;
    IF l_threshold_count >= l_threshold_value then
	l_submit_flag := TRUE;
    END IF;

    l_bom_comp_tbl_rec := l_bom_comp_tbl(j);
    FOR bom_sub_rec IN bom_sub_comp_CUR (l_COMPONENT_SEQUENCE_ID) LOOP
      ----------------------------------------------------------------------------------------------------------------------------------
         /* If the number of records are more than equal to 10,000 */
         IF l_submit_flag = TRUE THEN
              CALL_PROCESS_BOM (p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename,
                           p_bom_header_tbl         => l_bom_header_tbl,
                           p_bom_component_tbl      => l_bom_comp_tbl,
                           p_bom_ref_designator_tbl => l_bom_ref_desig_tbl,
                           p_bom_sub_component_tbl  => l_bom_sub_comp_tbl,
                           p_bom_comp_ops_tbl       => l_bom_comp_oper_tbl,
                           X_bom_header_tbl         => X_bom_header_tbl,
                           X_bom_revisions_tbl      => X_bom_revisions_tbl,
                           X_bom_comp_tbl           => X_bom_comp_tbl,
                           X_bom_ref_desig_tbl      => X_bom_ref_desig_tbl,
                           X_bom_sub_comp_tbl       => X_bom_sub_comp_tbl,
                           X_bom_comp_oper_tbl      => X_bom_comp_oper_tbl,
                           x_return_status          => X_return_status,
                           x_g_msg_data      => X_G_msg_data,
                           x_msg_count              => X_msg_count);

               l_bom_header_tbl.DELETE;
               l_bom_comp_tbl.DELETE;
               l_bom_ref_desig_tbl.DELETE;
               l_bom_sub_comp_tbl.DELETE;
               l_bom_comp_oper_tbl.DELETE;
               i := 1;
               j := 1;
               k := 1;
               l := 1;
              m := 1;
              l_threshold_count := 1;
              l_submit_flag := FALSE;

              l_bom_comp_tbl(1) := l_bom_comp_tbl_rec;
              l_bom_header_tbl(1) := l_bom_header_tbl_rec;
              l_bom_header_tbl(1).transaction_type := 'UPDATE';
              l_bom_comp_tbl(1) .transaction_type := 'UPDATE';

   END IF; --END l_submit_flag condition
   -----------------------------------------------------------------------------------------------------------
        l_bom_sub_comp_tbl(k).organization_code      := bom_sub_rec.OrganizationCode;
        l_bom_sub_comp_tbl(k).assembly_item_name     := bom_sub_rec.AssemblyItemName;
        l_bom_sub_comp_tbl(k).start_effective_date   := TO_DATE(bom_sub_rec.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS');
        l_bom_sub_comp_tbl(k).operation_sequence_number := bom_sub_rec.OperationSequenceNumber;
        l_bom_sub_comp_tbl(k).component_item_name       := bom_sub_rec.ComponentItemName;
        l_bom_sub_comp_tbl(k).alternate_bom_code        := bom_sub_rec.AlternateBomCode;
        l_bom_sub_comp_tbl(k).substitute_component_name := bom_sub_rec.SubstituteComponentName;
        l_bom_sub_comp_tbl(k).new_substitute_component_name := bom_sub_rec.NewSubstituteComponentName;
        l_bom_sub_comp_tbl(k).substitute_item_quantity      := TO_NUMBER(bom_sub_rec.SubstituteItemQuantity);
        l_bom_sub_comp_tbl(k).attribute_category        := bom_sub_rec.AttributeCategory;
        l_bom_sub_comp_tbl(k).attribute1                := bom_sub_rec.Attribute1;
        l_bom_sub_comp_tbl(k).attribute2                := bom_sub_rec.Attribute2;
        l_bom_sub_comp_tbl(k).attribute3                := bom_sub_rec.Attribute3;
        l_bom_sub_comp_tbl(k).attribute4                := bom_sub_rec.Attribute4;
        l_bom_sub_comp_tbl(k).attribute5                := bom_sub_rec.Attribute5;
        l_bom_sub_comp_tbl(k).attribute6                := bom_sub_rec.Attribute6;
        l_bom_sub_comp_tbl(k).attribute7                := bom_sub_rec.Attribute7;
        l_bom_sub_comp_tbl(k).attribute8                := bom_sub_rec.Attribute8;
        l_bom_sub_comp_tbl(k).attribute9                := bom_sub_rec.Attribute9;
        l_bom_sub_comp_tbl(k).attribute10               := bom_sub_rec.Attribute10;
        l_bom_sub_comp_tbl(k).attribute11               := bom_sub_rec.Attribute11;
        l_bom_sub_comp_tbl(k).attribute12               := bom_sub_rec.Attribute12;
        l_bom_sub_comp_tbl(k).attribute13               := bom_sub_rec.Attribute13;
        l_bom_sub_comp_tbl(k).attribute14               := bom_sub_rec.Attribute14;
        l_bom_sub_comp_tbl(k).attribute15               := bom_sub_rec.Attribute15;
        l_bom_sub_comp_tbl(k).program_id                := bom_sub_rec.ProgramId;
        l_bom_sub_comp_tbl(k).from_end_item_unit_number := bom_sub_rec.FromEndItemUnitNumber;
        l_bom_sub_comp_tbl(k).enforce_int_requirements  := bom_sub_rec.EnforceIntRequirements;
        l_bom_sub_comp_tbl(k).original_system_reference := bom_sub_rec.OriginalSystemReference;
        l_bom_sub_comp_tbl(k).return_status             := bom_sub_rec.ReturnStatus;
        l_bom_sub_comp_tbl(k).transaction_type          := bom_sub_rec.TransactionType;
        l_bom_sub_comp_tbl(k).row_identifier            := bom_sub_rec.RowIdentifier;

/* myerrams, Bug: 5142847; Check out if the threshold has reached*/
    l_threshold_count := l_threshold_count + 1;
    IF l_threshold_count >= l_threshold_value then
	l_submit_flag := TRUE;
    END IF;

     k := k + 1;
    END LOOP; --bom_sub_rec loop

      FOR bom_ref_desig_rec IN bom_ref_desig_CUR(l_COMPONENT_SEQUENCE_ID) LOOP
      ----------------------------------------------------------------------------------------------------------------------------------
         /* If the number of records are more than equal to 10,000 */
         IF l_submit_flag = TRUE THEN
              CALL_PROCESS_BOM (p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename,
                           p_bom_header_tbl         => l_bom_header_tbl,
                           p_bom_component_tbl      => l_bom_comp_tbl,
                           p_bom_ref_designator_tbl => l_bom_ref_desig_tbl,
                           p_bom_sub_component_tbl  => l_bom_sub_comp_tbl,
                           p_bom_comp_ops_tbl       => l_bom_comp_oper_tbl,
                           X_bom_header_tbl         => X_bom_header_tbl,
                           X_bom_revisions_tbl      => X_bom_revisions_tbl,
                           X_bom_comp_tbl           => X_bom_comp_tbl,
                           X_bom_ref_desig_tbl      => X_bom_ref_desig_tbl,
                           X_bom_sub_comp_tbl       => X_bom_sub_comp_tbl,
                           X_bom_comp_oper_tbl      => X_bom_comp_oper_tbl,
                           x_return_status          => X_return_status,
                           x_g_msg_data      => X_G_msg_data,
                           x_msg_count              => X_msg_count);

               l_bom_header_tbl.DELETE;
               l_bom_comp_tbl.DELETE;
               l_bom_ref_desig_tbl.DELETE;
               l_bom_sub_comp_tbl.DELETE;
               l_bom_comp_oper_tbl.DELETE;
               i := 1;
               j := 1;
               k := 1;
               l := 1;
              m := 1;
              l_threshold_count := 1;
              l_submit_flag := FALSE;

              l_bom_comp_tbl(1) := l_bom_comp_tbl_rec;
              l_bom_header_tbl(1) := l_bom_header_tbl_rec;
              l_bom_header_tbl(1).transaction_type := 'UPDATE';
              l_bom_comp_tbl(1) .transaction_type := 'UPDATE';

   END IF; --END l_submit_flag condition
   -----------------------------------------------------------------------------------------------------------
        l_bom_ref_desig_tbl(l).organization_code         := bom_ref_desig_rec.OrganizationCode;
        l_bom_ref_desig_tbl(l).assembly_item_name        := bom_ref_desig_rec.AssemblyItemName;
        l_bom_ref_desig_tbl(l).start_effective_date      := TO_DATE(bom_ref_desig_rec.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS');
        l_bom_ref_desig_tbl(l).operation_sequence_number := bom_ref_desig_rec.OperationSequenceNumber;
        l_bom_ref_desig_tbl(l).component_item_name       := bom_ref_desig_rec.ComponentItemName;
        l_bom_ref_desig_tbl(l).alternate_bom_code        := bom_ref_desig_rec.AlternateBomCode;
        l_bom_ref_desig_tbl(l).reference_designator_name := bom_ref_desig_rec.ReferenceDesignatorName;
        l_bom_ref_desig_tbl(l).ref_designator_comment    := bom_ref_desig_rec.RefDesignatorComment;
        l_bom_ref_desig_tbl(l).attribute_category        := bom_ref_desig_rec.AttributeCategory;
        l_bom_ref_desig_tbl(l).attribute1                := bom_ref_desig_rec.Attribute1;
        l_bom_ref_desig_tbl(l).attribute2                := bom_ref_desig_rec.Attribute2;
        l_bom_ref_desig_tbl(l).attribute3                := bom_ref_desig_rec.Attribute3;
        l_bom_ref_desig_tbl(l).attribute4                := bom_ref_desig_rec.Attribute4;
        l_bom_ref_desig_tbl(l).attribute5                := bom_ref_desig_rec.Attribute5;
        l_bom_ref_desig_tbl(l).attribute6                := bom_ref_desig_rec.Attribute6;
        l_bom_ref_desig_tbl(l).attribute7                := bom_ref_desig_rec.Attribute7;
        l_bom_ref_desig_tbl(l).attribute8                := bom_ref_desig_rec.Attribute8;
        l_bom_ref_desig_tbl(l).attribute9                := bom_ref_desig_rec.Attribute9;
        l_bom_ref_desig_tbl(l).attribute10               := bom_ref_desig_rec.Attribute10;
        l_bom_ref_desig_tbl(l).attribute11               := bom_ref_desig_rec.Attribute11;
        l_bom_ref_desig_tbl(l).attribute12               := bom_ref_desig_rec.Attribute12;
        l_bom_ref_desig_tbl(l).attribute13               := bom_ref_desig_rec.Attribute13;
        l_bom_ref_desig_tbl(l).attribute14               := bom_ref_desig_rec.Attribute14;
        l_bom_ref_desig_tbl(l).attribute15               := bom_ref_desig_rec.Attribute15;
        l_bom_ref_desig_tbl(l).from_end_item_unit_number := bom_ref_desig_rec.FromEndItemUnitNumber;
        l_bom_ref_desig_tbl(l).original_system_reference := bom_ref_desig_rec.OriginalSystemReference;
        l_bom_ref_desig_tbl(l).new_reference_designator  := bom_ref_desig_rec.NewReferenceDesignator;
        l_bom_ref_desig_tbl(l).return_status             := bom_ref_desig_rec.ReturnStatus;
        l_bom_ref_desig_tbl(l).transaction_type          := bom_ref_desig_rec.TransactionType;
        l_bom_ref_desig_tbl(l).row_identifier            := bom_ref_desig_rec.RowIdentifier;


/* myerrams, Bug: 5142847; Check out if the threshold has reached*/
    l_threshold_count := l_threshold_count + 1;
    IF l_threshold_count >= l_threshold_value then
	l_submit_flag := TRUE;
    END IF;

   l := l + 1;
  END LOOP; --bom_ref_desig_rec loop

      FOR bom_comp_oper_rec IN bom_comp_oper_CUR(l_BILL_SEQUENCE_ID, l_COMPONENT_SEQUENCE_ID) LOOP
      ----------------------------------------------------------------------------------------------------------------------------------
         /* If the number of records are more than equal to 10,000 */
         IF l_submit_flag = TRUE THEN
              CALL_PROCESS_BOM (p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename,
                           p_bom_header_tbl         => l_bom_header_tbl,
                           p_bom_component_tbl      => l_bom_comp_tbl,
                           p_bom_ref_designator_tbl => l_bom_ref_desig_tbl,
                           p_bom_sub_component_tbl  => l_bom_sub_comp_tbl,
                           p_bom_comp_ops_tbl       => l_bom_comp_oper_tbl,
                           X_bom_header_tbl         => X_bom_header_tbl,
                           X_bom_revisions_tbl      => X_bom_revisions_tbl,
                           X_bom_comp_tbl           => X_bom_comp_tbl,
                           X_bom_ref_desig_tbl      => X_bom_ref_desig_tbl,
                           X_bom_sub_comp_tbl       => X_bom_sub_comp_tbl,
                           X_bom_comp_oper_tbl      => X_bom_comp_oper_tbl,
                           x_return_status          => X_return_status,
                           x_g_msg_data      => X_G_msg_data,
                           x_msg_count              => X_msg_count);

               l_bom_header_tbl.DELETE;
               l_bom_comp_tbl.DELETE;
               l_bom_ref_desig_tbl.DELETE;
               l_bom_sub_comp_tbl.DELETE;
               l_bom_comp_oper_tbl.DELETE;
               i := 1;
               j := 1;
               k := 1;
               l := 1;
              m := 1;
              l_threshold_count := 1;
              l_submit_flag := FALSE;

              l_bom_comp_tbl(1) := l_bom_comp_tbl_rec;
              l_bom_header_tbl(1) := l_bom_header_tbl_rec;
              l_bom_header_tbl(1).transaction_type := 'UPDATE';
              l_bom_comp_tbl(1) .transaction_type := 'UPDATE';

   END IF; --END l_submit_flag condition
   -----------------------------------------------------------------------------------------------------------
        l_bom_comp_oper_tbl(m).organization_code             := bom_comp_oper_rec.OrganizationCode;
        l_bom_comp_oper_tbl(m).assembly_item_name            := bom_comp_oper_rec.AssemblyItemName;
        l_bom_comp_oper_tbl(m).start_effective_date          := TO_DATE(bom_comp_oper_rec.StartEffectiveDate,'YYYY-MM-DD HH24:MI:SS');
        l_bom_comp_oper_tbl(m).from_end_item_unit_number     := bom_comp_oper_rec.FromEndItemUnitNumber;
        l_bom_comp_oper_tbl(m).to_end_item_unit_number       := bom_comp_oper_rec.ToEndItemUnitNumber;
        l_bom_comp_oper_tbl(m).operation_sequence_number     := bom_comp_oper_rec.OperationSequenceNumber;
        l_bom_comp_oper_tbl(m).additional_operation_seq_num  := bom_comp_oper_rec.AdditionalOperationSeqNum;
        l_bom_comp_oper_tbl(m).new_additional_op_seq_num     := bom_comp_oper_rec.NewAdditionalOpSeqNum;
        l_bom_comp_oper_tbl(m).component_item_name           := bom_comp_oper_rec.ComponentItemName;
        l_bom_comp_oper_tbl(m).alternate_bom_code            := bom_comp_oper_rec.AlternateBomCode;
        l_bom_comp_oper_tbl(m).attribute_category            := bom_comp_oper_rec.AttributeCategory;
        l_bom_comp_oper_tbl(m).attribute1                    := bom_comp_oper_rec.Attribute1;
        l_bom_comp_oper_tbl(m).attribute2                    := bom_comp_oper_rec.Attribute2;
        l_bom_comp_oper_tbl(m).attribute3                    := bom_comp_oper_rec.Attribute3;
        l_bom_comp_oper_tbl(m).attribute4                    := bom_comp_oper_rec.Attribute4;
        l_bom_comp_oper_tbl(m).attribute5                    := bom_comp_oper_rec.Attribute5;
        l_bom_comp_oper_tbl(m).attribute6                    := bom_comp_oper_rec.Attribute6;
        l_bom_comp_oper_tbl(m).attribute7                    := bom_comp_oper_rec.Attribute7;
        l_bom_comp_oper_tbl(m).attribute8                    := bom_comp_oper_rec.Attribute8;
        l_bom_comp_oper_tbl(m).attribute9                    := bom_comp_oper_rec.Attribute9;
        l_bom_comp_oper_tbl(m).attribute10                   := bom_comp_oper_rec.Attribute10;
        l_bom_comp_oper_tbl(m).attribute11                   := bom_comp_oper_rec.Attribute11;
        l_bom_comp_oper_tbl(m).attribute12                   := bom_comp_oper_rec.Attribute12;
        l_bom_comp_oper_tbl(m).attribute13                   := bom_comp_oper_rec.Attribute13;
        l_bom_comp_oper_tbl(m).attribute14                   := bom_comp_oper_rec.Attribute14;
        l_bom_comp_oper_tbl(m).attribute15                   := bom_comp_oper_rec.Attribute15;
        l_bom_comp_oper_tbl(m).return_status                 := bom_comp_oper_rec.ReturnStatus;
        l_bom_comp_oper_tbl(m).transaction_type              := bom_comp_oper_rec.TransactionType;
        l_bom_comp_oper_tbl(m).row_identifier                := bom_comp_oper_rec.RowIdentifier;


/* myerrams, Bug: 5142847; Check out if the threshold has reached*/
    l_threshold_count := l_threshold_count + 1;
    IF l_threshold_count >= l_threshold_value then
	l_submit_flag := TRUE;
    END IF;

    m := m + 1;
  END LOOP; --bom_comp_oper_rec loop

      j := j + 1; --Bom Components count.
      END LOOP; --bom_comp_CUR loop

/* If the number of records are more than equal to 10,000 */
 IF l_submit_flag = TRUE THEN

              CALL_PROCESS_BOM (p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename,
                           p_bom_header_tbl         => l_bom_header_tbl,
                           p_bom_component_tbl      => l_bom_comp_tbl,
                           p_bom_ref_designator_tbl => l_bom_ref_desig_tbl,
                           p_bom_sub_component_tbl  => l_bom_sub_comp_tbl,
                           p_bom_comp_ops_tbl       => l_bom_comp_oper_tbl,
                           X_bom_header_tbl         => X_bom_header_tbl,
                           X_bom_revisions_tbl      => X_bom_revisions_tbl,
                           X_bom_comp_tbl           => X_bom_comp_tbl,
                           X_bom_ref_desig_tbl      => X_bom_ref_desig_tbl,
                           X_bom_sub_comp_tbl       => X_bom_sub_comp_tbl,
                           X_bom_comp_oper_tbl      => X_bom_comp_oper_tbl,
                           x_return_status          => X_return_status,
                           x_g_msg_data      => X_G_msg_data,
                           x_msg_count              => X_msg_count);

               l_bom_header_tbl.DELETE;
               l_bom_comp_tbl.DELETE;
               l_bom_ref_desig_tbl.DELETE;
               l_bom_sub_comp_tbl.DELETE;
               l_bom_comp_oper_tbl.DELETE;

               i := 1;
               j := 1;
               k := 1;
               l := 1;
              m := 1;
              l_threshold_count := 1;
              l_submit_flag := FALSE;

  ELSE
  i := i + 1;	-- If the threshold is not yet reached, continue adding more headers and dependent entities.
  END IF; --END l_submit_flag condition

END LOOP; --bom_header_rec loop

/* If there are any Headers pending processing after the Header loop is closed, process those records here */
IF l_submit_flag = FALSE and l_threshold_count > 1 THEN

              CALL_PROCESS_BOM (p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename,
                           p_bom_header_tbl         => l_bom_header_tbl,
                           p_bom_component_tbl      => l_bom_comp_tbl,
                           p_bom_ref_designator_tbl => l_bom_ref_desig_tbl,
                           p_bom_sub_component_tbl  => l_bom_sub_comp_tbl,
                           p_bom_comp_ops_tbl       => l_bom_comp_oper_tbl,
                           X_bom_header_tbl         => X_bom_header_tbl,
                           X_bom_revisions_tbl      => X_bom_revisions_tbl,
                           X_bom_comp_tbl           => X_bom_comp_tbl,
                           X_bom_ref_desig_tbl      => X_bom_ref_desig_tbl,
                           X_bom_sub_comp_tbl       => X_bom_sub_comp_tbl,
                           X_bom_comp_oper_tbl      => X_bom_comp_oper_tbl,
                           x_return_status          => X_return_status,
                           x_g_msg_data      => X_G_msg_data,
                           x_msg_count              => X_msg_count);
               l_bom_header_tbl.DELETE;
               l_bom_comp_tbl.DELETE;
               l_bom_ref_desig_tbl.DELETE;
               l_bom_sub_comp_tbl.DELETE;
               l_bom_comp_oper_tbl.DELETE;


END IF;	--END l_submit_flag condition

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || g_api_name
                  , 'End of method Import_BOM');
  END IF;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || g_api_name || '.end'
                  , NULL);
  END IF;

 EXCEPTION
      WHEN OTHERS THEN
        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
        THEN
         FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                  , G_MODULE_PREFIX || g_api_name
                  , SQLCODE||'  :  '||SQLERRM);
        END IF;
        X_G_msg_data :=     SQLCODE||'  :  '||SQLERRM;
        X_return_status     := 'E';
--debug_log('UEXP Error:'|| X_G_msg_data);


END Import_Bom;



PROCEDURE CALL_PROCESS_BOM(P_debug             IN VARCHAR2,
                     P_output_dir        IN VARCHAR2,
                     P_debug_filename    IN VARCHAR2,
                     p_bom_header_tbl    IN BOM_BO_PUB.BOM_HEADER_TBL_TYPE ,
                     p_bom_component_tbl      IN BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     p_bom_ref_designator_tbl IN BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     p_bom_sub_component_tbl  IN BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     p_bom_comp_ops_tbl       IN BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_bom_header_tbl    IN OUT NOCOPY BOM_BO_PUB.BOM_HEADER_TBL_TYPE ,
                     X_bom_revisions_tbl IN OUT NOCOPY BOM_BO_PUB.Bom_Revision_Tbl_Type,
                     X_bom_comp_tbl      IN OUT NOCOPY BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     X_bom_ref_desig_tbl IN OUT NOCOPY BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     X_bom_sub_comp_tbl  IN OUT NOCOPY BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     X_bom_comp_oper_tbl IN OUT NOCOPY BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_return_status     IN OUT NOCOPY VARCHAR2,	--myerrams, Bug: 5592181
                     X_G_msg_data        OUT NOCOPY LONG,
                     X_msg_count         OUT NOCOPY NUMBER
) IS

/* Following variables are used for logging messages */
  l_message			VARCHAR2(2000) := NULL;
  l_entity			VARCHAR2(3)    := NULL;
  l_msg_index			NUMBER;
  l_message_type		VARCHAR2(1);

BEGIN
  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || g_api_name
                  , 'Before Calling  BOM_BO_PUB.Process_Bom()');
  END IF;

    BOM_GLOBALS.Set_Caller_Type('MIGRATION');
    BOM_BO_PUB.Process_Bom(p_bom_header_tbl         => p_bom_header_tbl,
                           p_bom_component_tbl      => p_bom_component_tbl,
                           p_bom_ref_designator_tbl => p_bom_ref_designator_tbl ,
                           p_bom_sub_component_tbl  => p_bom_sub_component_tbl  ,
                           p_bom_comp_ops_tbl       => p_bom_comp_ops_tbl,
                           x_bom_header_tbl         => X_bom_header_tbl,
                           x_bom_revision_tbl       => X_bom_revisions_tbl,
                           x_bom_component_tbl      => X_bom_comp_tbl,
                           x_bom_ref_designator_tbl => X_bom_ref_desig_tbl,
                           x_bom_sub_component_tbl  => X_bom_sub_comp_tbl,
                           x_bom_comp_ops_tbl       => X_bom_comp_oper_tbl,
                           x_return_status          => g_X_return_status,	--myerrams, Bug: 5592181
                           x_msg_count              => X_msg_count,
                           p_debug                  => P_debug,
                           p_output_dir             => P_output_dir,
                           p_debug_filename         => P_debug_filename);
--myerrams, Bug:5654718
  X_bom_header_tbl.DELETE;
  X_bom_revisions_tbl.DELETE;
  X_bom_comp_tbl.DELETE;
  X_bom_ref_desig_tbl.DELETE;
  X_bom_sub_comp_tbl.DELETE;
  X_bom_comp_oper_tbl.DELETE;

  commit;

	IF g_fnd_debug = 'Y' AND
        FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
	THEN
        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_PREFIX || g_api_name
                  , 'Current Call Return Status of BOM_BO_PUB.Process_Bom: g_X_return_status:'|| g_X_return_status);
        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_PREFIX || g_api_name
                  , 'Previous Call Return Status of BOM_BO_PUB.Process_Bom: X_return_status:'|| X_return_status);
        END IF;

	IF (g_X_return_status <> 'S' and g_status_set = FALSE) THEN
	   X_return_status := g_X_return_status;
	   g_status_set := TRUE;
	END IF;

	IF (g_X_return_status = 'U' and X_return_status <> 'U') THEN
	   X_return_status := g_X_return_status;
	END IF;

    FOR i IN 1..X_msg_count LOOP
    BEGIN

      ERROR_HANDLER.Get_Message(x_entity_index => l_msg_index,
                                x_entity_id    => l_entity,
                                x_message_text => l_message,
                                x_message_type => l_message_type);
      X_G_msg_data := TO_CHAR(l_msg_index) || ': '||l_entity ||': '|| l_message_type ||': '||l_message;

      IF g_fnd_debug = 'Y' AND
        FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
        FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                  , G_MODULE_PREFIX || g_api_name
                  , 'Error messages from BOM_BO_PUB.Process_Bom:'|| X_G_msg_data);
        END IF;

    END;
    END LOOP;

  IF g_fnd_debug = 'Y' AND
     FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
  THEN
    FND_LOG.string( FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || g_api_name
                  , 'After Calling  BOM_BO_PUB.Process_Bom()');
  END IF;
/* Reset all the PL/SQL tables and counters*/

END CALL_PROCESS_BOM;

END BOM_BOM_COPYORG_IMP;

/
