--------------------------------------------------------
--  DDL for Package Body BOM_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BO_PUB" AS
/* $Header: BOMBBOMB.pls 120.1 2005/08/24 05:08:14 vhymavat noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBBOMB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_BO_Pub
--
--  NOTES
--
--  HISTORY
--
--  09-JUL-99   Rahul Chitko    Initial Creation
--  11-AUG-99 Rahul Chitko  Added Code for Procedure Process_Bom and
--          other local procedures used within it.
--  20-AUG-01   Refai Farook    One To Many support changes
--
--  25-SEP-01   Refai Farook    Mass changes for unit effectivity support changes
--                              Affected procs. are conv_ecocomp_to_bomcomp and
--                              conv_bomcomp_to_ecocomp
--  22-NOV-02  Vani Hymavathi   modified to include the new column Row_Identifier
***************************************************************************/

  /*****************************************************************
  * Procedure : Convert_BomComp_To_EcoComp
  * Parameters IN : Bom Component Exposed Column Record
  *     Bom_Component Unexposed Column Record
  * Parameters OUT: Eco Component Exposed Column Record
  *     Eco Component Unexposed Column Record
  * Purpose : This procedure will simply take the BOM component
  *     record and copy its values into the ECO component
  *     record. Since the record definitions of ECO and BOM
  *     records is different, this has to done on a field
  *     by field basis.
  ******************************************************************/
        PROCEDURE Convert_BomComp_To_EcoComp
        (  p_bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type :=
          Bom_bo_Pub.G_MISS_BOM_COMPONENT_REC
         , p_bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMP_UNEXP_REC
         , x_rev_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
         , x_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
         )
  IS
  BEGIN
                x_rev_component_rec.eco_name := NULL;
                x_rev_component_rec.organization_code :=
                                p_bom_component_rec.organization_code;
                x_rev_component_rec.revised_item_name :=
                                p_bom_component_rec.assembly_item_name;
                x_rev_component_rec.new_revised_item_revision := NULL;
                x_rev_component_rec.start_effective_date :=
                                p_bom_component_rec.start_Effective_date;
                x_rev_component_rec.new_effectivity_date :=
                                p_bom_component_rec.new_effectivity_date;
                x_rev_component_rec.disable_date :=
                                p_bom_component_rec.disable_date;
                x_rev_component_rec.operation_sequence_number :=
                                p_bom_component_rec.operation_sequence_number;
                x_rev_component_rec.component_item_name :=
                                p_bom_component_rec.component_item_name;
                x_rev_component_rec.alternate_bom_code :=
                                p_bom_component_rec.alternate_bom_code;
                x_rev_component_rec.acd_type := NULL;
                x_rev_component_rec.old_effectivity_date := NULL;
                x_rev_component_rec.old_operation_sequence_number := NULL;
                x_rev_component_rec.new_operation_sequence_number :=
                        p_bom_component_rec.new_operation_sequence_number;
                x_rev_component_rec.item_sequence_number :=
                                p_bom_component_rec.item_sequence_number;
                x_rev_component_rec.basis_type:=
                                p_bom_component_rec.basis_type;
                x_rev_component_rec.quantity_per_assembly :=
                                p_bom_component_rec.quantity_per_assembly;
                x_rev_component_rec.inverse_quantity :=
                                p_bom_component_rec.inverse_quantity;
                x_rev_component_rec.Planning_Percent :=
                                p_bom_component_rec.Planning_Percent;
                x_rev_component_rec.projected_yield :=
                                p_bom_component_rec.projected_yield;
                x_rev_component_rec.include_in_cost_rollup :=
                                p_bom_component_rec.include_in_cost_rollup;
                x_rev_component_rec.wip_supply_type :=
                                p_bom_component_rec.wip_supply_type;
                x_rev_component_rec.so_basis :=
                                p_bom_component_rec.so_basis;
                x_rev_component_rec.optional :=
                                p_bom_component_rec.optional;
                x_rev_component_rec.mutually_exclusive :=
                                p_bom_component_rec.mutually_exclusive;
                x_rev_component_rec.check_atp :=
                                p_bom_component_rec.check_atp;
                x_rev_component_rec.shipping_allowed :=
                                p_bom_component_rec.shipping_allowed;
                x_rev_component_rec.required_to_ship :=
                                p_bom_component_rec.required_to_ship;
                x_rev_component_rec.required_for_revenue :=
                                p_bom_component_rec.required_for_revenue;
                x_rev_component_rec.include_on_ship_docs :=
                                p_bom_component_rec.include_on_ship_docs;
                x_rev_component_rec.quantity_related :=
                                p_bom_component_rec.quantity_related;
                x_rev_component_rec.supply_subinventory :=
                                p_bom_component_rec.supply_subinventory;
                x_rev_component_rec.location_name :=
                                p_bom_component_rec.location_name;
                x_rev_component_rec.minimum_allowed_quantity :=
                                p_bom_component_rec.minimum_allowed_quantity;
                x_rev_component_rec.maximum_allowed_quantity :=
                                p_bom_component_rec.maximum_allowed_quantity;
                x_rev_component_rec.comments :=
                                p_bom_component_rec.comments;
                x_rev_component_rec.attribute_category :=
                                p_bom_component_rec.attribute_category;
                x_rev_component_rec.attribute1 :=
                                p_bom_component_rec.attribute1;
                x_rev_component_rec.attribute2 :=
                                p_bom_component_rec.attribute2;
                x_rev_component_rec.attribute3 :=
                                p_bom_component_rec.attribute3;
                x_rev_component_rec.attribute4 :=
                                p_bom_component_rec.attribute4;
                x_rev_component_rec.attribute5 :=
                                p_bom_component_rec.attribute5;
                x_rev_component_rec.attribute6 :=
                                p_bom_component_rec.attribute6;
                x_rev_component_rec.attribute7 :=
                                p_bom_component_rec.attribute7;
                x_rev_component_rec.attribute8 :=
                                p_bom_component_rec.attribute8;
                x_rev_component_rec.attribute9 :=
                                p_bom_component_rec.attribute9;
                x_rev_component_rec.attribute10 :=
                                p_bom_component_rec.attribute10;
                x_rev_component_rec.attribute11 :=
                                p_bom_component_rec.attribute11;
                x_rev_component_rec.attribute12 :=
                                p_bom_component_rec.attribute12;
                x_rev_component_rec.attribute13 :=
                                p_bom_component_rec.attribute13;
                x_rev_component_rec.attribute14 :=
                                p_bom_component_rec.attribute14;
                x_rev_component_rec.attribute15 :=
                                p_bom_component_rec.attribute15;
                x_rev_component_rec.original_system_reference :=
                                p_bom_component_Rec.original_system_reference;
                x_rev_component_rec.transaction_type :=
                                p_bom_component_rec.transaction_type;
                x_rev_component_rec.return_status :=
                                p_bom_component_rec.return_status;

    x_rev_component_rec.From_End_Item_Unit_Number := p_bom_component_rec.From_End_Item_Unit_Number;
                x_rev_component_rec.To_End_Item_Unit_Number := p_bom_component_rec.To_End_Item_Unit_Number;
    x_rev_component_rec.New_From_End_Item_Unit_Number := p_bom_component_rec.New_From_End_Item_Unit_Number;
                x_rev_component_rec.New_Routing_Revision    := NULL ; -- Added by MK on 11/02/00
    x_rev_component_rec.Enforce_Int_Requirements := p_bom_component_rec.Enforce_Int_Requirements;
    x_rev_component_rec.Row_Identifier := p_bom_component_rec.Row_Identifier;    --added by vhymavat
    x_rev_component_rec.auto_request_material :=
          p_bom_component_rec.auto_request_material; -- Added in 11.5.9 by ADEY

                x_rev_component_rec.Suggested_Vendor_Name :=
                                p_bom_component_rec.Suggested_Vendor_Name; --- Deepu
/*
                x_rev_component_rec.Purchasing_Category :=
                                p_bom_component_rec.Purchasing_Category; --- Deepu
                x_rev_component_rec.Purchasing_Category_Id :=
                                p_bom_component_rec.Purchasing_Category_Id; --- Deepu
*/
    x_rev_component_rec.Unit_Price :=
                                p_bom_component_rec.Unit_Price; --- Deepu

                --
                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record
                --
                x_rev_comp_unexp_rec.organization_id :=
                                p_bom_comp_unexp_rec.organization_id;
                x_rev_comp_unexp_rec.component_item_id :=
                                p_bom_comp_unexp_rec.component_item_id;
                x_rev_comp_unexp_rec.component_sequence_id :=
                                p_bom_comp_unexp_rec.component_sequence_id;
                x_rev_comp_unexp_rec.revised_item_id :=
                                p_bom_comp_unexp_rec.assembly_item_id;
                x_rev_comp_unexp_rec.bill_sequence_id :=
                                p_bom_comp_unexp_rec.bill_sequence_id;
                x_rev_comp_unexp_rec.pick_components :=
                                p_bom_comp_unexp_rec.pick_components;
                x_rev_comp_unexp_rec.supply_locator_id :=
                                p_bom_comp_unexp_rec.supply_locator_id;
                x_rev_comp_unexp_rec.bom_item_type :=
                                p_bom_comp_unexp_rec.bom_item_type;
    x_rev_comp_unexp_rec.revised_item_sequence_id := NULL;

                x_rev_comp_unexp_rec.Delete_Group_Name :=
                                p_bom_component_rec.Delete_Group_Name ; -- Added in 1155
                x_rev_comp_unexp_rec.DG_Description    :=
                                p_bom_component_rec.DG_Description ;    -- Added in 1155
                x_rev_comp_unexp_rec.DG_Sequence_Id    :=
                                p_bom_comp_unexp_rec.DG_Sequence_Id ;   -- Added in 1155
    x_rev_comp_unexp_rec.Enforce_Int_Requirements_Code := p_bom_comp_unexp_rec.Enforce_Int_Requirements_Code;

                x_rev_comp_unexp_rec.Rowid   :=
                                p_bom_comp_unexp_rec.Rowid ;

                x_rev_comp_unexp_rec.bom_implementation_date   :=
                                p_bom_comp_unexp_rec.bom_implementation_date;

    x_rev_comp_unexp_rec.Vendor_Id :=
                                p_bom_comp_unexp_rec.Vendor_Id; --- Deepu
                x_rev_comp_unexp_rec.Common_Component_Sequence_Id   :=
                                p_bom_comp_unexp_rec.Common_Component_Sequence_Id;


  END Convert_BomComp_To_EcoComp;

        /*****************************************************************
        * Procedure     : Convert_EcoComp_To_BomComp
        * Parameters IN : Eco Component Exposed Column Record
        *                 Eco Component Unexposed Column Record
        * Parameters IN : Bom Component Exposed Column Record
        *                 Bom_Component Unexposed Column Record
        * Purpose       : This procedure will simply take the Eco component
        *                 record and copy its values into the Bom component
        *                 record. Since the record definitions of ECO and BOM
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        PROCEDURE Convert_EcoComp_To_BomComp
        (  p_rev_component_rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type :=
            Bom_Bo_Pub.G_MISS_REV_COMPONENT_REC
         , p_rev_comp_unexp_rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
            Bom_Bo_Pub.G_MISS_REV_COMP_UNEXP_REC
         , x_bom_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
         , x_bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         )
  IS
  BEGIN
                x_bom_component_rec.organization_code :=
                                p_rev_component_rec.organization_code;
                x_bom_component_rec.assembly_item_name :=
                                p_rev_component_rec.revised_item_name;
                x_bom_component_rec.start_effective_date :=
                                p_rev_component_rec.start_Effective_date;
                x_bom_component_rec.new_effectivity_date :=
                                p_rev_component_rec.new_effectivity_date;
                x_bom_component_rec.disable_date :=
                                p_rev_component_rec.disable_date;
                x_bom_component_rec.operation_sequence_number :=
                                p_rev_component_rec.operation_sequence_number;
                x_bom_component_rec.component_item_name :=
                                p_rev_component_rec.component_item_name;
                x_bom_component_rec.alternate_bom_code :=
                                p_rev_component_rec.alternate_bom_code;
                x_bom_component_rec.new_operation_sequence_number :=
                        p_rev_component_rec.new_operation_sequence_number;
                x_bom_component_rec.item_sequence_number :=
                                p_rev_component_rec.item_sequence_number;
                x_bom_component_rec.basis_type:=
                                p_rev_component_rec.basis_type;
                x_bom_component_rec.quantity_per_assembly :=
                                p_rev_component_rec.quantity_per_assembly;
                x_bom_component_rec.inverse_quantity :=
                                p_rev_component_rec.inverse_quantity;
                x_bom_component_rec.Planning_Percent :=
                                p_rev_component_rec.Planning_Percent;
                x_bom_component_rec.projected_yield :=
                                p_rev_component_rec.projected_yield;
                x_bom_component_rec.include_in_cost_rollup :=
                                p_rev_component_rec.include_in_cost_rollup;
                x_bom_component_rec.wip_supply_type :=
                                p_rev_component_rec.wip_supply_type;
                x_bom_component_rec.so_basis :=
                                p_rev_component_rec.so_basis;
                x_bom_component_rec.optional :=
                                p_rev_component_rec.optional;
                x_bom_component_rec.mutually_exclusive :=
                                p_rev_component_rec.mutually_exclusive;
                x_bom_component_rec.check_atp :=
                                p_rev_component_rec.check_atp;
                x_bom_component_rec.shipping_allowed :=
                                p_rev_component_rec.shipping_allowed;
                x_bom_component_rec.required_to_ship :=
                                p_rev_component_rec.required_to_ship;
                x_bom_component_rec.required_for_revenue :=
                                p_rev_component_rec.required_for_revenue;
                x_bom_component_rec.include_on_ship_docs :=
                                p_rev_component_rec.include_on_ship_docs;
                x_bom_component_rec.quantity_related :=
                                p_rev_component_rec.quantity_related;
                x_bom_component_rec.supply_subinventory :=
                                p_rev_component_rec.supply_subinventory;
                x_bom_component_rec.location_name :=
                                p_rev_component_rec.location_name;
                x_bom_component_rec.minimum_allowed_quantity :=
                                p_rev_component_rec.minimum_allowed_quantity;
                x_bom_component_rec.maximum_allowed_quantity :=
                                p_rev_component_rec.maximum_allowed_quantity;
                x_bom_component_rec.comments :=
                                p_rev_component_rec.comments;
                x_bom_component_rec.From_End_Item_Unit_Number := p_rev_component_rec.From_End_Item_Unit_Number;
                x_bom_component_rec.To_End_Item_Unit_Number := p_rev_component_rec.To_End_Item_Unit_Number;
                x_bom_component_rec.New_From_End_Item_Unit_Number := p_rev_component_rec.New_From_End_Item_Unit_Number;
                x_bom_component_rec.Enforce_Int_Requirements := p_rev_component_rec.Enforce_Int_Requirements;
    x_bom_component_rec.Row_Identifier:= p_rev_component_rec.Row_Identifier;  --added by vhymavat

                x_bom_component_rec.attribute_category :=
                                p_rev_component_rec.attribute_category;
                x_bom_component_rec.attribute1 :=
                                p_rev_component_rec.attribute1;
                x_bom_component_rec.attribute2 :=
                                p_rev_component_rec.attribute2;
                x_bom_component_rec.attribute3 :=
                                p_rev_component_rec.attribute3;
                x_bom_component_rec.attribute4 :=
                                p_rev_component_rec.attribute4;
                x_bom_component_rec.attribute5 :=
                                p_rev_component_rec.attribute5;
                x_bom_component_rec.attribute6 :=
                                p_rev_component_rec.attribute6;
                x_bom_component_rec.attribute7 :=
                                p_rev_component_rec.attribute7;
                x_bom_component_rec.attribute8 :=
                                p_rev_component_rec.attribute8;
                x_bom_component_rec.attribute9 :=
                                p_rev_component_rec.attribute9;
                x_bom_component_rec.attribute10 :=
                                p_rev_component_rec.attribute10;
                x_bom_component_rec.attribute11 :=
                                p_rev_component_rec.attribute11;
                x_bom_component_rec.attribute12 :=
                                p_rev_component_rec.attribute12;
                x_bom_component_rec.attribute13 :=
                                p_rev_component_rec.attribute13;
                x_bom_component_rec.attribute14 :=
                                p_rev_component_rec.attribute14;
                x_bom_component_rec.attribute15 :=
                                p_rev_component_rec.attribute15;
                x_bom_component_rec.original_system_reference :=
                                p_rev_component_Rec.original_system_reference;
                x_bom_component_rec.transaction_type :=
                                p_rev_component_rec.transaction_type;
                x_bom_component_rec.return_status :=
                                p_rev_component_rec.return_status;

                x_bom_component_rec.Delete_Group_Name :=
                                p_rev_comp_unexp_rec.Delete_Group_Name ; -- Added in 1155
                x_bom_component_rec.DG_Description    :=
                                p_rev_comp_unexp_rec.DG_Description ;    -- Added in 1155
    x_bom_component_rec.auto_request_material    :=
          p_rev_component_rec.auto_request_material ;    -- Added in 11.5.9 by ADEY

    x_bom_component_rec.Suggested_Vendor_Name :=
                                p_rev_component_rec.Suggested_Vendor_Name; --- Deepu
/*
    x_bom_component_rec.Purchasing_Category :=
                                p_rev_component_rec.Purchasing_Category; --- Deepu
                x_bom_component_rec.Purchasing_Category_Id :=
                                p_rev_component_rec.Purchasing_Category_Id; --- Deepu
*/
    x_bom_component_rec.Unit_Price :=
                                p_rev_component_rec.Unit_Price; --- Deepu


                --
                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record
                --
    x_bom_comp_unexp_rec.assembly_item_id :=
                                p_rev_comp_unexp_rec.revised_item_id;
                x_bom_comp_unexp_rec.organization_id :=
                                p_rev_comp_unexp_rec.organization_id;
                x_bom_comp_unexp_rec.component_item_id :=
                                p_rev_comp_unexp_rec.component_item_id;
                x_bom_comp_unexp_rec.component_sequence_id :=
                                p_rev_comp_unexp_rec.component_sequence_id;
                x_bom_comp_unexp_rec.bill_sequence_id :=
                                p_rev_comp_unexp_rec.bill_sequence_id;
                x_bom_comp_unexp_rec.pick_components :=
                                p_rev_comp_unexp_rec.pick_components;
                x_bom_comp_unexp_rec.supply_locator_id :=
                                p_rev_comp_unexp_rec.supply_locator_id;
                x_bom_comp_unexp_rec.bom_item_type :=
                                p_rev_comp_unexp_rec.bom_item_type;

                x_bom_comp_unexp_rec.DG_Sequence_Id  :=
                                p_rev_comp_unexp_rec.DG_Sequence_Id ;   -- Added in 1155
                x_bom_comp_unexp_rec.Enforce_Int_Requirements_Code  := p_rev_comp_unexp_rec.Enforce_Int_Requirements_Code;

                x_bom_comp_unexp_rec.Rowid  :=
                                p_rev_comp_unexp_rec.Rowid;

                x_bom_comp_unexp_rec.bom_implementation_date  :=
                                p_rev_comp_unexp_rec.bom_implementation_date;

    x_bom_comp_unexp_rec.Vendor_Id :=
                                p_rev_comp_unexp_rec.Vendor_Id; --- Deepu
                x_bom_comp_unexp_rec.Common_Component_Sequence_Id  :=
                                p_rev_comp_unexp_rec.Common_Component_Sequence_Id;

  END Convert_EcoComp_To_BomComp;

  PROCEDURE Convert_BomDesg_To_EcoDesg
        (  p_bom_ref_designator_rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_REC
         , p_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_BOM_REF_DESG_UNEXP_REC
         , x_ref_designator_rec     IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
         , x_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
         )
  IS
  BEGIN
    x_ref_designator_rec.eco_name := NULL;
    x_ref_designator_rec.revised_item_name :=
      p_bom_ref_designator_rec.assembly_item_name;
    x_ref_designator_rec.start_effective_date :=
      p_bom_ref_designator_rec.start_effective_date;
    x_ref_designator_rec.new_revised_item_revision := NULL;
    x_ref_designator_rec.operation_sequence_number :=
      p_bom_ref_designator_rec.operation_sequence_number;
    x_ref_designator_rec.component_item_name :=
      p_bom_ref_designator_rec.component_item_name;
    x_ref_designator_rec.Alternate_Bom_Code :=
      p_bom_ref_designator_rec.Alternate_Bom_Code;
    x_ref_designator_rec.Reference_Designator_Name :=
      p_bom_ref_designator_rec.Reference_Designator_Name;
    x_ref_designator_rec.ACD_Type := NULL;
    x_ref_designator_rec.Ref_Designator_Comment :=
      p_bom_ref_designator_rec.Ref_Designator_Comment;
    x_ref_designator_rec.Attribute_category :=
      p_bom_ref_designator_rec.Attribute_category;
    x_ref_designator_rec.Attribute1 :=
      p_bom_ref_designator_rec.Attribute1;
    x_ref_designator_rec.Attribute2 :=
      p_bom_ref_designator_rec.Attribute2;
    x_ref_designator_rec.Attribute3 :=
      p_bom_ref_designator_rec.Attribute3;
    x_ref_designator_rec.Attribute4 :=
      p_bom_ref_designator_rec.Attribute4;
    x_ref_designator_rec.Attribute5 :=
      p_bom_ref_designator_rec.Attribute5;
    x_ref_designator_rec.Attribute6 :=
      p_bom_ref_designator_rec.Attribute6;
    x_ref_designator_rec.Attribute7 :=
      p_bom_ref_designator_rec.Attribute7;
    x_ref_designator_rec.Attribute8 :=
      p_bom_ref_designator_rec.Attribute8;
    x_ref_designator_rec.Attribute9 :=
      p_bom_ref_designator_rec.Attribute9;
    x_ref_designator_rec.Attribute10 :=
      p_bom_ref_designator_rec.Attribute10;
    x_ref_designator_rec.Attribute11 :=
      p_bom_ref_designator_rec.Attribute11;
    x_ref_designator_rec.Attribute12 :=
      p_bom_ref_designator_rec.Attribute12;
    x_ref_designator_rec.Attribute13 :=
      p_bom_ref_designator_rec.Attribute13;
    x_ref_designator_rec.Attribute14 :=
      p_bom_ref_designator_rec.Attribute14;
    x_ref_designator_rec.Attribute15 :=
      p_bom_ref_designator_rec.Attribute15;
    x_ref_designator_rec.Original_System_Reference :=
      p_bom_ref_designator_rec.Original_System_Reference;
    x_ref_designator_rec.New_Reference_Designator :=
      p_bom_ref_designator_rec.New_Reference_Designator;
    x_ref_designator_rec.Return_Status :=
      p_bom_ref_designator_rec.Return_Status;
    x_ref_designator_rec.Transaction_Type  :=
      p_bom_ref_designator_rec.Transaction_Type;
                x_ref_designator_rec.New_Routing_Revision      := NULL ; -- Added by MK on 11/02/00
                x_ref_designator_rec.From_End_Item_Unit_Number :=
        p_bom_ref_designator_rec.From_End_Item_Unit_Number;
    x_ref_designator_rec.Row_Identifier:=
                               p_bom_ref_designator_rec.Row_Identifier;--added by vhyavat
    --
    -- Convert the unexposed record well.
    --
    x_ref_desg_unexp_rec.organization_id :=
      p_bom_ref_desg_unexp_rec.organization_id;
    x_ref_desg_unexp_rec.component_item_id :=
      p_bom_ref_desg_unexp_rec.component_item_id;
    x_ref_desg_unexp_rec.Component_Sequence_Id :=
      p_bom_ref_desg_unexp_rec.component_sequence_id;
    x_ref_desg_unexp_rec.Revised_Item_Id :=
      p_bom_ref_desg_unexp_rec.assembly_item_id;
    x_ref_desg_unexp_rec.bill_sequence_id :=
      p_bom_ref_desg_unexp_rec.bill_sequence_id;
  END Convert_BomDesg_To_EcoDesg;

        PROCEDURE Convert_EcoDesg_To_BomDesg
        (  p_ref_designator_rec     IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
         , p_ref_desg_unexp_rec     IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_REF_DESG_UNEXP_REC
         , x_bom_ref_designator_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
         , x_bom_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
         )
  IS
  BEGIN
                x_bom_ref_designator_rec.assembly_item_name :=
                        p_ref_designator_rec.revised_item_name;
                x_bom_ref_designator_rec.start_effective_date :=
                        p_ref_designator_rec.start_effective_date;
                x_bom_ref_designator_rec.operation_sequence_number :=
                        p_ref_designator_rec.operation_sequence_number;
                x_bom_ref_designator_rec.component_item_name :=
                        p_ref_designator_rec.component_item_name;
                x_bom_ref_designator_rec.Alternate_Bom_Code :=
                        p_ref_designator_rec.Alternate_Bom_Code;
                x_bom_ref_designator_rec.Reference_Designator_Name :=
                        p_ref_designator_rec.Reference_Designator_Name;
                x_bom_ref_designator_rec.Ref_Designator_Comment :=
                        p_ref_designator_rec.Ref_Designator_Comment;
                x_bom_ref_designator_rec.Attribute_category :=
                        p_ref_designator_rec.Attribute_category;
                x_bom_ref_designator_rec.Attribute1 :=
                        p_ref_designator_rec.Attribute1;
                x_bom_ref_designator_rec.Attribute2 :=
                        p_ref_designator_rec.Attribute2;
                x_bom_ref_designator_rec.Attribute3 :=
                        p_ref_designator_rec.Attribute3;
                x_bom_ref_designator_rec.Attribute4 :=
                        p_ref_designator_rec.Attribute4;
                x_bom_ref_designator_rec.Attribute5 :=
                        p_ref_designator_rec.Attribute5;
                x_bom_ref_designator_rec.Attribute6 :=
                        p_ref_designator_rec.Attribute6;
                x_bom_ref_designator_rec.Attribute7 :=
                        p_ref_designator_rec.Attribute7;
                x_bom_ref_designator_rec.Attribute8 :=
                        p_ref_designator_rec.Attribute8;
                x_bom_ref_designator_rec.Attribute9 :=
                        p_ref_designator_rec.Attribute9;
                x_bom_ref_designator_rec.Attribute10 :=
                        p_ref_designator_rec.Attribute10;
                x_bom_ref_designator_rec.Attribute11 :=
                        p_ref_designator_rec.Attribute11;
                x_bom_ref_designator_rec.Attribute12 :=
                        p_ref_designator_rec.Attribute12;
                x_bom_ref_designator_rec.Attribute13 :=
                        p_ref_designator_rec.Attribute13;
                x_bom_ref_designator_rec.Attribute14 :=
                        p_ref_designator_rec.Attribute14;
                x_bom_ref_designator_rec.Attribute15 :=
                        p_ref_designator_rec.Attribute15;
    x_bom_ref_designator_rec.From_End_Item_Unit_Number :=
                                p_ref_designator_rec.From_End_Item_Unit_Number;

                x_bom_ref_designator_rec.Original_System_Reference :=
                        p_ref_designator_rec.Original_System_Reference;
                x_bom_ref_designator_rec.New_Reference_Designator :=
                        p_ref_designator_rec.New_Reference_Designator;
                x_bom_ref_designator_rec.Return_Status :=
                        p_ref_designator_rec.Return_Status;
                x_bom_ref_designator_rec.Transaction_Type  :=
                        p_ref_designator_rec.Transaction_Type;
                x_bom_ref_designator_rec.Row_Identifier:=
                         p_ref_designator_rec.Row_Identifier;

                --
                -- Convert the unexposed record well.
                --
                x_bom_ref_desg_unexp_rec.organization_id :=
                        p_ref_desg_unexp_rec.organization_id;
                x_bom_ref_desg_unexp_rec.component_item_id :=
                        p_ref_desg_unexp_rec.component_item_id;
                x_bom_ref_desg_unexp_rec.Component_Sequence_Id :=
                        p_ref_desg_unexp_rec.component_sequence_id;
                x_bom_ref_desg_unexp_rec.assembly_item_id :=
                        p_ref_desg_unexp_rec.Revised_Item_Id;
                x_bom_ref_desg_unexp_rec.bill_sequence_id :=
                        p_ref_desg_unexp_rec.bill_sequence_id;

  END Convert_EcoDesg_To_BomDesg;

        PROCEDURE Convert_BomSComp_To_EcoSComp
        (  p_bom_sub_component_rec  IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_REC
         , p_bom_sub_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_BOM_SUB_COMP_UNEXP_REC
         , x_sub_component_rec      IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
         , x_sub_comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
         )
  IS
  BEGIN
    x_sub_component_rec.eco_name := NULL;
    x_sub_component_rec.organization_code :=
      p_bom_sub_component_rec.organization_code;
    x_sub_component_rec.revised_item_name :=
      p_bom_sub_component_rec.assembly_item_name;
    x_sub_component_rec.start_effective_date :=
      p_bom_sub_component_rec.start_effective_date;
    x_sub_component_rec.new_revised_item_revision := null;
    x_sub_component_rec.operation_sequence_number :=
      p_bom_sub_component_rec.operation_sequence_number;
    x_sub_component_rec.component_item_name :=
      p_bom_sub_component_rec.component_item_name;
    x_sub_component_rec.alternate_bom_code :=
      p_bom_sub_component_rec.alternate_bom_code;
    x_sub_component_rec.substitute_component_name :=
      p_bom_sub_component_rec.substitute_component_name;
    x_sub_component_rec.new_substitute_component_name :=
      p_bom_sub_component_rec.new_substitute_component_name;
    x_sub_component_rec.acd_type :=  NULL;
    x_sub_component_rec.substitute_item_quantity :=
                        p_bom_sub_component_rec.substitute_item_quantity;
                x_sub_component_rec.Attribute_category :=
                        p_bom_sub_component_rec.Attribute_category;
                x_sub_component_rec.Attribute1 :=
                        p_bom_sub_component_rec.Attribute1;
                x_sub_component_rec.Attribute2 :=
                        p_bom_sub_component_rec.Attribute2;
                x_sub_component_rec.Attribute3 :=
                        p_bom_sub_component_rec.Attribute3;
                x_sub_component_rec.Attribute4 :=
                        p_bom_sub_component_rec.Attribute4;
                x_sub_component_rec.Attribute5 :=
                        p_bom_sub_component_rec.Attribute5;
                x_sub_component_rec.Attribute6 :=
                        p_bom_sub_component_rec.Attribute6;
                x_sub_component_rec.Attribute7 :=
                        p_bom_sub_component_rec.Attribute7;
                x_sub_component_rec.Attribute8 :=
                        p_bom_sub_component_rec.Attribute8;
                x_sub_component_rec.Attribute9 :=
                        p_bom_sub_component_rec.Attribute9;
                x_sub_component_rec.Attribute10 :=
                        p_bom_sub_component_rec.Attribute10;
                x_sub_component_rec.Attribute11 :=
                        p_bom_sub_component_rec.Attribute11;
                x_sub_component_rec.Attribute12 :=
                        p_bom_sub_component_rec.Attribute12;
                x_sub_component_rec.Attribute13 :=
                        p_bom_sub_component_rec.Attribute13;
                x_sub_component_rec.Attribute14 :=
                        p_bom_sub_component_rec.Attribute14;
                x_sub_component_rec.Attribute15 :=
                        p_bom_sub_component_rec.Attribute15;
                x_sub_component_rec.Original_System_Reference :=
                        p_bom_sub_component_rec.Original_System_Reference;
                x_sub_component_rec.Return_Status :=
                        p_bom_sub_component_rec.Return_Status;
                x_sub_component_rec.Transaction_Type  :=
                        p_bom_sub_component_rec.Transaction_Type;
                x_sub_component_rec.New_Routing_Revision      := NULL ; -- Added by MK on 11/02/00
                x_sub_component_rec.From_End_Item_Unit_Number :=
      p_bom_sub_component_rec.From_End_Item_Unit_Number;
                x_sub_component_rec.Enforce_Int_Requirements :=
      p_bom_sub_component_rec.Enforce_Int_Requirements;
               x_sub_component_rec.Row_Identifier:=
                     p_bom_sub_component_rec.Row_Identifier;
               x_sub_component_rec.Inverse_Quantity:=
                     p_bom_sub_component_rec.Inverse_Quantity;

    --
    -- Also store the Unexposed record columns
    --
    x_sub_comp_unexp_rec.organization_id :=
      p_bom_sub_comp_unexp_rec.organization_id;
    x_sub_comp_unexp_rec.component_item_id :=
      p_bom_sub_comp_unexp_rec.component_item_id;
    x_sub_comp_unexp_rec.component_sequence_id :=
      p_bom_sub_comp_unexp_rec.component_sequence_id;
    x_sub_Comp_unexp_rec.revised_item_id :=
      p_bom_sub_comp_unexp_rec.assembly_item_id;
    x_sub_comp_unexp_rec.substitute_component_id :=
      p_bom_sub_comp_unexp_rec.substitute_component_id;
    x_sub_comp_unexp_rec.new_substitute_component_id :=
      p_bom_sub_comp_unexp_rec.new_substitute_component_id;
    x_sub_comp_unexp_rec.bill_sequence_id :=
      p_bom_sub_comp_unexp_rec.bill_sequence_id;
    x_sub_comp_unexp_rec.Enforce_Int_Requirements_Code :=
      p_bom_sub_comp_unexp_rec.Enforce_Int_Requirements_Code;

  END Convert_BomSComp_To_EcoSComp;

        PROCEDURE Convert_EcoSComp_To_BomSComp
        (  p_sub_component_rec      IN  Bom_Bo_Pub.Sub_Component_Rec_Type
                                    := Bom_Bo_Pub.G_MISS_SUB_COMPONENT_REC
         , p_sub_comp_unexp_rec     IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
                                    := Bom_bo_Pub.G_MISS_SUB_COMP_UNEXP_REC
         , x_bom_sub_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
         , x_bom_sub_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
        )
  IS
  BEGIN
                x_bom_sub_component_rec.organization_code :=
                        p_sub_component_rec.organization_code;
                x_bom_sub_component_rec.assembly_item_name :=
                        p_sub_component_rec.revised_item_name;
                x_bom_sub_component_rec.start_effective_date :=
                        p_sub_component_rec.start_effective_date;
                x_bom_sub_component_rec.operation_sequence_number :=
                        p_sub_component_rec.operation_sequence_number;
                x_bom_sub_component_rec.component_item_name :=
                        p_sub_component_rec.component_item_name;
                x_bom_sub_component_rec.alternate_bom_code :=
                        p_sub_component_rec.alternate_bom_code;
                x_bom_sub_component_rec.substitute_component_name :=
                        p_sub_component_rec.substitute_component_name;
                x_bom_sub_component_rec.new_substitute_component_name :=
                        p_sub_component_rec.new_substitute_component_name;
    x_bom_sub_component_rec.substitute_item_quantity :=
      p_sub_component_rec.substitute_item_quantity;
                x_bom_sub_component_rec.Attribute_category :=
                        p_sub_component_rec.Attribute_category;
                x_bom_sub_component_rec.Attribute1 :=
                        p_sub_component_rec.Attribute1;
                x_bom_sub_component_rec.Attribute2 :=
                        p_sub_component_rec.Attribute2;
                x_bom_sub_component_rec.Attribute3 :=
                        p_sub_component_rec.Attribute3;
                x_bom_sub_component_rec.Attribute4 :=
                        p_sub_component_rec.Attribute4;
                x_bom_sub_component_rec.Attribute5 :=
                        p_sub_component_rec.Attribute5;
                x_bom_sub_component_rec.Attribute6 :=
                        p_sub_component_rec.Attribute6;
                x_bom_sub_component_rec.Attribute7 :=
                        p_sub_component_rec.Attribute7;
                x_bom_sub_component_rec.Attribute8 :=
                        p_sub_component_rec.Attribute8;
                x_bom_sub_component_rec.Attribute9 :=
                        p_sub_component_rec.Attribute9;
                x_bom_sub_component_rec.Attribute10 :=
                        p_sub_component_rec.Attribute10;
                x_bom_sub_component_rec.Attribute11 :=
                        p_sub_component_rec.Attribute11;
                x_bom_sub_component_rec.Attribute12 :=
                        p_sub_component_rec.Attribute12;
                x_bom_sub_component_rec.Attribute13 :=
                        p_sub_component_rec.Attribute13;
                x_bom_sub_component_rec.Attribute14 :=
                        p_sub_component_rec.Attribute14;
                x_bom_sub_component_rec.Attribute15 :=
                        p_sub_component_rec.Attribute15;
                x_bom_sub_component_rec.From_End_Item_Unit_Number :=
                        p_sub_component_rec.From_End_Item_Unit_Number;
                x_bom_sub_component_rec.Enforce_Int_Requirements :=
                        p_sub_component_rec.Enforce_Int_Requirements;
                x_bom_sub_component_rec.Original_System_Reference :=
                        p_sub_component_rec.Original_System_Reference;
                x_bom_sub_component_rec.Return_Status :=
                        p_sub_component_rec.Return_Status;
                x_bom_sub_component_rec.Transaction_Type  :=
                        p_sub_component_rec.Transaction_Type;
                 x_bom_sub_component_rec.Row_Identifier:=
                       p_sub_component_rec.Row_Identifier;-- added by vhymavat
                 x_bom_sub_component_rec.Inverse_Quantity:=
                       p_sub_component_rec.Inverse_Quantity;

                --
                -- Also store the Unexposed record columns
                --
                x_bom_sub_comp_unexp_rec.organization_id :=
                        p_sub_comp_unexp_rec.organization_id;
                x_bom_sub_comp_unexp_rec.component_item_id :=
                        p_sub_comp_unexp_rec.component_item_id;
                x_bom_sub_comp_unexp_rec.component_sequence_id :=
                        p_sub_comp_unexp_rec.component_sequence_id;
                x_bom_sub_Comp_unexp_rec.assembly_item_id :=
                        p_sub_comp_unexp_rec.revised_item_id;
                x_bom_sub_comp_unexp_rec.substitute_component_id :=
                        p_sub_comp_unexp_rec.substitute_component_id;
                x_bom_sub_comp_unexp_rec.new_substitute_component_id :=
                        p_sub_comp_unexp_rec.new_substitute_component_id;
                x_bom_sub_comp_unexp_rec.bill_sequence_id :=
                        p_sub_comp_unexp_rec.bill_sequence_id;
                x_bom_sub_comp_unexp_rec.Enforce_Int_Requirements_Code :=
                        p_sub_comp_unexp_rec.Enforce_Int_Requirements_Code;

  END Convert_EcoSComp_To_BomSComp;


  FUNCTION Does_Rev_Have_Same_Bom
  ( p_bom_revision_tbl        IN Bom_Bo_Pub.Bom_Revision_Tbl_Type
  , p_assembly_item_name       IN VARCHAR2
  , p_organization_code       IN VARCHAR2
  ) RETURN BOOLEAN
  IS
    table_index     NUMBER;
    record_count        NUMBER;
  BEGIN
        record_count := p_bom_revision_tbl.COUNT;

        FOR table_index IN 1..record_count
        LOOP
            IF NVL(p_bom_revision_tbl(table_index).assembly_item_name,
         FND_API.G_MISS_CHAR) <>
               NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
               OR
                 NVL(p_bom_revision_tbl(table_index).organization_code,
         FND_API.G_MISS_CHAR) <>
               NVL(p_organization_code, FND_API.G_MISS_CHAR)
          THEN
              RETURN FALSE;
          END IF;
        END LOOP;

        RETURN TRUE;
  END Does_Rev_Have_Same_Bom;


  FUNCTION Does_Comp_Have_Same_Bom
  ( p_bom_component_tbl       IN BOM_BO_PUB.Bom_Comps_Tbl_Type
  , p_assembly_item_name       IN VARCHAR2
  , p_organization_code       IN VARCHAR2
  ) RETURN BOOLEAN
  IS
    table_index     NUMBER;
    record_count        NUMBER;
  BEGIN
        record_count := p_bom_component_tbl.COUNT;

        FOR table_index IN 1..record_count
        LOOP
          IF NVL(p_bom_component_tbl(table_index).assembly_item_name, FND_API.G_MISS_CHAR) <>
            NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
            OR
            NVL(p_bom_component_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
            NVL(p_organization_code, FND_API.G_MISS_CHAR)
          THEN
              RETURN FALSE;
          END IF;
        END LOOP;

        RETURN TRUE;
  END Does_Comp_Have_Same_Bom;


  FUNCTION Does_Desg_Have_Same_Bom
  ( p_bom_ref_designator_tbl   IN BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type
  , p_assembly_item_name       IN VARCHAR2
  , p_organization_code       IN VARCHAR2
  ) RETURN BOOLEAN
  IS
    table_index     NUMBER;
    record_count        NUMBER;
  BEGIN
        record_count := p_bom_ref_designator_tbl.COUNT;

        FOR table_index IN 1..record_count
        LOOP
          IF NVL(p_bom_ref_designator_tbl(table_index).assembly_item_name, FND_API.G_MISS_CHAR) <>
            NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
            OR
            NVL(p_bom_ref_designator_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
                NVL(p_organization_code, FND_API.G_MISS_CHAR)
          THEN
              RETURN FALSE;
          END IF;
        END LOOP;

        RETURN TRUE;
  END Does_Desg_Have_Same_Bom;


  FUNCTION Does_SComp_Have_Same_Bom
  ( p_bom_sub_component_tbl    IN BOM_BO_PUB.Bom_Sub_Component_Tbl_Type
  , p_assembly_item_name       IN VARCHAR2
  , p_organization_code       IN VARCHAR2
  ) RETURN BOOLEAN
  IS
    table_index     NUMBER;
    record_count        NUMBER;
  BEGIN
        record_count := p_bom_sub_component_tbl.COUNT;

if Bom_Globals.Get_Debug = 'Y' THEN
  Error_Handler.write_debug('Substitute comps check for same BOM ' ||
          p_assembly_item_name ||
          ' org ' ||
          p_organization_code  || ' processing records ' || p_bom_sub_component_tbl.COUNT);
end if;
        FOR table_index IN 1..record_count
        LOOP
          IF NVL(p_bom_sub_component_tbl(table_index).assembly_item_name, FND_API.G_MISS_CHAR) <>
            NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
            OR
            NVL(p_bom_sub_component_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
                NVL(p_organization_code, FND_API.G_MISS_CHAR)
          THEN
              RETURN FALSE;
          END IF;
        END LOOP;

        RETURN TRUE;
  END Does_SComp_Have_Same_Bom;


  FUNCTION Does_CmpOps_Have_Same_Bom
  ( p_bom_comp_ops_tbl    IN BOM_BO_PUB.Bom_Comp_Ops_Tbl_Type
  , p_assembly_item_name  IN VARCHAR2
  , p_organization_code   IN VARCHAR2
  ) RETURN BOOLEAN
  IS
    table_index     NUMBER;
    record_count        NUMBER;
  BEGIN
        record_count := p_bom_comp_ops_tbl.COUNT;

if Bom_Globals.Get_Debug = 'Y' THEN
  Error_Handler.write_debug('Component Operations check for same BOM ' ||
          p_assembly_item_name ||
          ' org ' ||
          p_organization_code  || ' processing records ' || record_count);
end if;
        FOR table_index IN 1..record_count
        LOOP
          IF NVL(p_bom_comp_ops_tbl(table_index).assembly_item_name, FND_API.G_MISS_CHAR) <>
            NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
            OR
            NVL(p_bom_comp_ops_tbl(table_index).organization_code, FND_API.G_MISS_CHAR) <>
                NVL(p_organization_code, FND_API.G_MISS_CHAR)
          THEN
              RETURN FALSE;
          END IF;
        END LOOP;

        RETURN TRUE;
  END Does_CmpOps_Have_Same_Bom;


  /******************************************************************
  * Procedure : Check_Records_In_Same_BOM
  * Parameters IN :
  *
  *
  *
  *
  *******************************************************************/
  FUNCTION Check_Records_In_Same_BOM
        (  p_bom_header_rec     IN  Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl       IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type
   , p_bom_component_tbl      IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_designator_tbl IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl  IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl       IN  Bom_Bo_Pub.Bom_Comp_ops_Tbl_Type
         , x_assembly_item_name     IN OUT NOCOPY VARCHAR2
   , x_organization_code      IN OUT NOCOPY VARCHAR2
        )
  RETURN BOOLEAN
  IS
    l_organization_code VARCHAR2(3);
    l_assembly_item_name  VARCHAR2(240);
    record_count    NUMBER;
  BEGIN
    IF (p_bom_header_rec.assembly_item_name IS NOT NULL AND
              p_bom_header_rec.assembly_item_name <> FND_API.G_MISS_CHAR)
              OR
              (p_bom_header_rec.organization_code IS NOT NULL AND
               p_bom_header_rec.organization_code <> FND_API.G_MISS_CHAR)
    THEN
            l_assembly_item_name :=
          p_bom_header_rec.assembly_item_name;
            l_organization_code :=
          p_bom_header_rec.organization_code;
      x_assembly_item_name :=
          p_bom_header_rec.assembly_item_name;
      x_organization_code :=
          p_bom_header_rec.organization_code;

      IF NOT Does_Rev_Have_Same_Bom
                  ( p_bom_revision_tbl => p_bom_revision_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_Comp_Have_Same_Bom
                  ( p_bom_component_tbl => p_bom_component_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_Desg_Have_Same_Bom
                  ( p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_SComp_Have_Same_Bom
                  ( p_bom_sub_component_tbl => p_bom_sub_component_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_CmpOps_Have_Same_Bom
                  ( p_bom_comp_ops_tbl => p_bom_comp_ops_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            RETURN TRUE;

        END IF; -- If Bom Header record Exists Ends

        record_count := p_bom_revision_tbl.COUNT;
        IF record_count <> 0
        THEN
            l_assembly_item_name :=
        p_bom_revision_tbl(1).assembly_item_name;
            l_organization_code :=
        p_bom_revision_tbl(1).organization_code;
            x_assembly_item_name :=
        p_bom_revision_tbl(1).assembly_item_name;
            x_organization_code :=
        p_bom_revision_tbl(1).organization_code;

            IF record_count > 1
            THEN
                  IF NOT Does_Rev_Have_Same_Bom
                    ( p_bom_revision_tbl => p_bom_revision_tbl
                    , p_assembly_item_name => l_assembly_item_name
                    , p_organization_code => l_organization_code
                    )
                  THEN
                  RETURN FALSE;
                  END IF;
            END IF;

            IF NOT Does_Comp_Have_Same_Bom
                  ( p_bom_component_tbl => p_bom_component_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_Desg_Have_Same_Bom
                  ( p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_SComp_Have_Same_Bom
                  ( p_bom_sub_component_tbl => p_bom_sub_component_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;


            IF NOT Does_CmpOps_Have_Same_Bom
                  ( p_bom_comp_ops_tbl => p_bom_comp_ops_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            RETURN TRUE;
        END IF; -- If Revision Table is Not Empty Ends

        record_count := p_bom_component_tbl.COUNT;
        IF record_count <> 0
        THEN
            l_assembly_item_name :=
        p_bom_component_tbl(1).assembly_item_name;
            l_organization_code :=
        p_bom_component_tbl(1).organization_code;
            x_assembly_item_name :=
        p_bom_component_tbl(1).assembly_item_name;
            x_organization_code :=
        p_bom_component_tbl(1).organization_code;

            IF record_count > 1
            THEN
              IF NOT Does_Comp_Have_Same_Bom
                    ( p_bom_component_tbl => p_bom_component_tbl
                    , p_assembly_item_name => l_assembly_item_name
                    , p_organization_code => l_organization_code
                    )
              THEN
                  RETURN FALSE;
                  END IF;
            END IF;

            IF NOT Does_Desg_Have_Same_Bom
                  ( p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            IF NOT Does_SComp_Have_Same_Bom
                  ( p_bom_sub_component_tbl => p_bom_sub_component_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;


            IF NOT Does_CmpOps_Have_Same_Bom
                  ( p_bom_comp_ops_tbl => p_bom_comp_ops_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            RETURN TRUE;
        END IF; -- If Bom Component Table is not Empty Ends

        record_count := p_bom_ref_designator_tbl.COUNT;
        IF record_count <> 0
        THEN
            l_assembly_item_name :=
        p_bom_ref_designator_tbl(1).assembly_item_name;
            l_organization_code :=
        p_bom_ref_designator_tbl(1).organization_code;
            x_assembly_item_name :=
        p_bom_ref_designator_tbl(1).assembly_item_name;
            x_organization_code :=
        p_bom_ref_designator_tbl(1).organization_code;

            IF record_count > 1
            THEN
                  IF NOT Does_Desg_Have_Same_Bom
                    ( p_bom_ref_designator_tbl =>
            p_bom_ref_designator_tbl
                    , p_assembly_item_name => l_assembly_item_name
                    , p_organization_code => l_organization_code
                    )
                  THEN
                  RETURN FALSE;
                  END IF;
            END IF;

            IF NOT Does_SComp_Have_Same_Bom
                  ( p_bom_sub_component_tbl => p_bom_sub_component_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;


            IF NOT Does_CmpOps_Have_Same_Bom
                  ( p_bom_comp_ops_tbl => p_bom_comp_ops_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            RETURN TRUE;
        END IF; -- If reference Desingator Table is not Empty Ends

                record_count := p_bom_sub_component_tbl.COUNT;

        IF record_count <> 0
        THEN
            l_assembly_item_name :=
        p_bom_sub_component_tbl(1).assembly_item_name;
            l_organization_code :=
        p_bom_sub_component_tbl(1).organization_code;
            x_assembly_item_name :=
        p_bom_sub_component_tbl(1).assembly_item_name;
            x_organization_code :=
        p_bom_sub_component_tbl(1).organization_code;

            IF record_count > 1
            THEN
                  IF NOT Does_SComp_Have_Same_Bom
                    ( p_bom_sub_component_tbl =>
            p_bom_sub_component_tbl
                    , p_assembly_item_name => l_assembly_item_name
                    , p_organization_code => l_organization_code
                    )
                  THEN
                  RETURN FALSE;
                  END IF;
            END IF;


            IF NOT Does_CmpOps_Have_Same_Bom
                  ( p_bom_comp_ops_tbl => p_bom_comp_ops_tbl
                  , p_assembly_item_name => l_assembly_item_name
                  , p_organization_code => l_organization_code
                  )
            THEN
                RETURN FALSE;
            END IF;

            RETURN TRUE;
        END IF;  -- If Substitut Component Table is not Empty Ends

                record_count := p_bom_comp_ops_tbl.COUNT;

        IF record_count <> 0
        THEN
            l_assembly_item_name :=
        p_bom_comp_ops_tbl(1).assembly_item_name;
            l_organization_code :=
        p_bom_comp_ops_tbl(1).organization_code;
            x_assembly_item_name :=
        p_bom_comp_ops_tbl(1).assembly_item_name;
            x_organization_code :=
        p_bom_comp_ops_tbl(1).organization_code;

            IF record_count > 1
            THEN
                  IF NOT Does_CmpOps_Have_Same_Bom
                    ( p_bom_comp_ops_tbl =>
            p_bom_comp_ops_tbl
                    , p_assembly_item_name => l_assembly_item_name
                    , p_organization_code => l_organization_code
                    )
                  THEN
                  RETURN FALSE;
                  END IF;
            END IF;

            RETURN TRUE;
        END IF;  -- Component Operations Table

        -- If nothing to process then return TRUE.
        --
        RETURN TRUE;

  END Check_Records_In_Same_BOM;

  /********************************************************************
  * Procedure : Process_Bom
  * Parameters IN : Bom Header exposed column record
  *     Bom Inventorty Component exposed column table
  *     Bom Item Revision Exposed Column Table
  *     Substitute Component Exposed Column table
  *     Reference Designator Exposed column table
  *     Component Operations Exposed column table
  * Parameters OUT: Bom Header Exposed Column Record
  *     Bom Inventory Components exposed column table
  *     Bom Item Revision Exposed Column Table
        *                 Substitute Component Exposed Column table
        *                 Reference Designator Exposed column table
  *     Component Operations Exposed column table
  * Purpose : This procedure is the driving procedure of the BOM
  *     business Obect. It will verify the integrity of the
  *     business object and will call the private API which
  *     further drive the business object to perform business
  *     logic validations.
  *********************************************************************/
  PROCEDURE Process_Bom
  (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
   , p_api_version_number      IN  NUMBER := 1.0
   , p_init_msg_list       IN  BOOLEAN := FALSE
   , p_bom_header_rec      IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
          Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
   , p_bom_revision_tbl      IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
   , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
   , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type
            := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
   , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
            := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
         , p_bom_comp_ops_tbl        IN Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type :=
                                       Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
   , x_bom_header_rec      IN OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
   , x_bom_revision_tbl      IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
   , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
   , x_bom_ref_designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
   , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , x_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
   , x_return_status           IN OUT NOCOPY VARCHAR2
   , x_msg_count               IN OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
         , p_write_err_to_inttable   IN  VARCHAR2 := 'N'
         , p_write_err_to_conclog    IN  VARCHAR2 := 'N'
         , p_write_err_to_debugfile  IN  VARCHAR2 := 'N'
   )
  IS
    G_EXC_SEV_QUIT_OBJECT       EXCEPTION;
    G_EXC_UNEXP_SKIP_OBJECT     EXCEPTION;

    l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_other_message   VARCHAR2(50);
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;
    l_err_text            VARCHAR2(2000);
    l_return_status   VARCHAR2(1);

    l_assembly_item_name  VARCHAR2(240);
    l_organization_code     VARCHAR2(3);
    l_organization_id       NUMBER;
    l_bom_header_rec        Bom_Bo_Pub.Bom_Head_Rec_Type := p_bom_header_rec;
    l_bom_revision_tbl      Bom_Bo_Pub.Bom_Revision_Tbl_Type;
    l_bom_component_tbl     Bom_Bo_Pub.Bom_Comps_Tbl_Type;
    l_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
    l_bom_sub_component_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
    l_bom_comp_ops_tbl      Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;
    l_Debug_flag    VARCHAR2(1) := p_debug;
  BEGIN

                --
                -- Set Business Object Idenfier in the System Information
                -- record.
                --
                Bom_Globals.Set_Bo_Identifier
                            (p_bo_identifier    =>  p_bo_identifier);

                --
                -- Initialize the message list if the user has set the
                -- Init Message List parameter
                --
                IF p_init_msg_list
                THEN
                        Error_Handler.Initialize;
                END IF;


        IF l_debug_flag = 'Y'
            THEN

          IF trim(p_output_dir) IS NULL OR
             trim(p_output_dir) = ''
          THEN
        -- If debug is Y then out dir must be
        -- specified

              Error_Handler.Add_Error_Token
                          (  p_Message_text       =>
           'Debug is set to Y so an output directory' ||
           ' must be specified. Debug will be turned' ||
           ' off since no directory is specified'
                          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , p_Token_Tbl          => l_token_tbl
                          );

                   Error_Handler.Log_Error
                         ( p_bom_header_rec      => p_bom_header_rec
                               , p_bom_revision_tbl => p_bom_revision_tbl
                         , p_bom_component_tbl => p_bom_component_tbl
                         , p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
                         , p_bom_sub_component_tbl => p_bom_sub_component_tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_error_status => 'W'
                         , p_error_level => Error_Handler.G_BO_LEVEL
                         , x_bom_header_rec      => l_bom_header_rec
                         , x_bom_revision_tbl    => l_bom_revision_tbl
                         , x_bom_component_tbl   => l_bom_component_tbl
                         , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                         , x_bom_sub_component_tbl => l_bom_sub_component_tbl
                         );
            l_debug_flag := 'N';

          END IF;

          IF trim(p_debug_filename) IS NULL OR
             trim(p_debug_filename) = ''
          THEN

                                Error_Handler.Add_Error_Token
                                (  p_Message_text       =>
                                   'Debug is set to Y so an output filename' ||
                                   ' must be specified. Debug will be turned' ||
                                   ' off since no filename is specified'
                                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                                , p_Token_Tbl          => l_token_tbl
                                );

                               Error_Handler.Log_Error
                               ( p_bom_header_rec      => p_bom_header_rec
                               , p_bom_revision_tbl => p_bom_revision_tbl
                               , p_bom_component_tbl => p_bom_component_tbl
                               , p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
                               , p_bom_sub_component_tbl => p_bom_sub_component_tbl
                               , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                               , p_error_status => 'W'
                               , p_error_level => Error_Handler.G_BO_LEVEL
                               , x_bom_header_rec      => l_bom_header_rec
                               , x_bom_revision_tbl    => l_bom_revision_tbl
                               , x_bom_component_tbl   => l_bom_component_tbl
                               , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                               , x_bom_sub_component_tbl => l_bom_sub_component_tbl
                               );
                              l_debug_flag := 'N';

          END IF;

                BOM_Globals.Set_Debug(l_debug_flag);

          IF l_debug_flag = 'Y'
          THEN
                  Error_Handler.Open_Debug_Session
                  (  p_debug_filename     => p_debug_filename
                   , p_output_dir         => p_output_dir
                   , x_return_status      => l_return_status
                   , p_mesg_token_tbl     => l_mesg_token_tbl
                   , x_mesg_token_tbl     => l_mesg_token_tbl
                   );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                        BOM_Globals.Set_Debug('N');
                  END IF;
          END IF;
            END IF;


    IF bom_globals.get_debug = 'Y' THEN error_handler.write_debug('The BO as passed '); end if;
    IF bom_globals.get_debug = 'Y' THEN error_handler.write_debug('Header Rec: ' || p_bom_header_rec.assembly_item_name); end if;
    IF bom_globals.get_debug = 'Y' THEN error_handler.write_debug('Num of Components: ' || p_bom_component_tbl.COUNT); end if;
    IF (p_bom_component_tbl.COUNT > 0)  THEN
            IF bom_globals.get_debug = 'Y' then
        Error_Handler.Write_Debug('Assembly key in Component: ' || p_bom_component_tbl(1).assembly_item_name);
      END IF;
    end if;

    IF bom_globals.get_debug = 'Y' then error_handler.write_debug('Num of Substitute: ' || p_bom_sub_component_tbl.COUNT); END IF;
    IF bom_globals.get_debug = 'Y' then error_handler.write_debug('Num of Ref. Desgs: ' || p_bom_ref_designator_tbl.COUNT); END IF;

    --
    -- Verify if all the entity record(s) belong to the same
    -- business object
    --

if p_bom_sub_component_tbl.COUNT <> 0
then
  if bom_globals.get_debug = 'Y'
  then
    for xx in 1..p_bom_sub_component_tbl.COUNT
    loop
      error_handler.write_debug('Substitute Component: ' || p_bom_sub_component_tbl(xx).substitute_component_name || ' Assembly ' || p_bom_sub_component_tbl(xx).assembly_item_name
             || ' Organization ' || p_bom_sub_component_tbl(xx).organization_code);

    end loop;
  end if;
end if;
    IF NOT Check_Records_In_Same_BOM
       (  p_bom_header_rec    => p_bom_header_rec
        , p_bom_revision_tbl  => p_bom_revision_tbl
        , p_bom_component_tbl => p_bom_component_tbl
        , p_bom_ref_designator_tbl  => p_bom_ref_designator_tbl
        , p_bom_sub_component_tbl => p_bom_sub_component_tbl
        , p_bom_comp_ops_tbl  => p_bom_comp_ops_tbl
        , x_assembly_item_name  => l_assembly_item_name
        , x_organization_code => l_organization_code
        )
    THEN
            l_other_message := 'BOM_MUST_BE_IN_SAME_BOM';
      RAISE G_EXC_SEV_QUIT_OBJECT;
        END IF;

        IF (l_assembly_item_name IS NULL OR
              l_assembly_item_name = FND_API.G_MISS_CHAR)
              OR
              (l_organization_code IS NULL OR
               l_organization_code = FND_API.G_MISS_CHAR)
        THEN
            l_other_message := 'BOM_ASSY_OR_ORG_MISSING';
            RAISE G_EXC_SEV_QUIT_OBJECT;
        END IF;


    l_organization_id := Bom_Val_To_Id.Organization
                   (  p_organization => l_organization_code
                    , x_err_text => l_err_text
                   );

        IF l_organization_id IS NULL
        THEN
      l_other_message := 'BOM_ORG_INVALID';
      l_token_tbl(1).token_name := 'ORG_CODE';
      l_token_tbl(1).token_value := l_organization_code;
      RAISE G_EXC_SEV_QUIT_OBJECT;

        ELSIF l_organization_id = FND_API.G_MISS_NUM
        THEN
      l_other_message := 'BOM_UNEXP_ORG_INVALID';
            RAISE G_EXC_UNEXP_SKIP_OBJECT;
        END IF;


    --
    -- Set Organization Id in the System Information record.
    --
        Bom_Globals.Set_Org_Id( p_org_id  => l_organization_id);

    --
    -- Set Application Id in the appication context and set the
    -- fine-grained security policy on bom_alternate_designators
    -- table. This is currently applicable only if the application
    -- calling this BO is EAM
    --
  Bom_Set_Context.set_application_id;

    --
    -- Call the Private API for performing further business
    -- rules validation
    --

    --
    -- set the implementation date based on the alternate designator and the
    -- create unimplemented structures flag set at the structure type level.
    --
    BEGIN
       IF(l_bom_header_rec.alternate_bom_code IS NULL)
       THEN
           select decode(enable_unimplemented_boms,'Y',null, sysdate)
             into l_bom_header_rec.BOM_Implementation_Date
             from bom_structure_types_b stype,
                  bom_alternate_designators alt
            where alt.alternate_designator_code IS NULL
              and stype.structure_type_id = alt.structure_type_id;
     ELSE
           select decode(enable_unimplemented_boms,'Y',null, sysdate)
             into l_bom_header_rec.BOM_Implementation_Date
             from bom_structure_types_b stype,
                  bom_alternate_designators alt
            where alt.alternate_designator_code = l_bom_header_rec.alternate_bom_code
              and organization_id = l_organization_id
              and stype.structure_type_id = alt.structure_type_id;
     END IF;
    EXCEPTION -- bug 3481464
    WHEN NO_DATA_FOUND THEN
-- The control can come here only when the caller is from a form in EAM responsibility
-- The security policy will be set for EAM and the above queries would throw this
-- exception, which will be handled as below. 'Asset BOM' is a seeded structure type.
       IF(l_bom_header_rec.alternate_bom_code IS NULL)
       THEN
           select decode(enable_unimplemented_boms,'Y',null, sysdate)
             into l_bom_header_rec.BOM_Implementation_Date
             from bom_structure_types_b stype
            where stype.structure_type_name = 'Asset BOM';
       ELSE
-- The control should not come here when the alternate is not null. The query above should
-- not throw a no_data_found exception. If it throws, then there is something else which is wrong
           l_bom_header_rec.BOM_Implementation_Date := null;
       END IF;
    END;

    Bom_Bo_Pvt.Process_Bom
    (   p_api_version_number     => p_api_version_number
    ,   x_return_status          => l_return_status
    ,   x_msg_count              => x_msg_count
    ,   p_bom_header_rec         => l_bom_header_rec
    ,   p_bom_revision_tbl       => p_bom_revision_tbl
    ,   p_bom_component_tbl      => p_bom_component_tbl
    ,   p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
    ,   p_bom_sub_component_tbl  => p_bom_sub_component_tbl
    ,   p_bom_comp_ops_tbl       => p_bom_comp_ops_tbl
    ,   x_bom_header_rec         => x_bom_header_rec
    ,   x_bom_revision_tbl       => x_bom_revision_tbl
    ,   x_bom_component_tbl      => x_bom_component_tbl
    ,   x_bom_ref_designator_tbl => x_bom_ref_designator_tbl
    ,   x_bom_sub_component_tbl  => x_bom_sub_component_tbl
    ,   x_bom_comp_ops_tbl       => x_bom_comp_ops_tbl
    );

    Bom_Globals.Set_Org_Id( p_org_id  => NULL);
    Bom_Globals.Set_Eco_Name( p_eco_name  => NULL);

          IF l_return_status <> 'S'
    THEN
    -- Call Error Handler

      l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
      l_token_tbl(1).token_value := l_assembly_item_name;
      l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
      l_token_tbl(2).token_value := l_organization_code;

            Error_Handler.Log_Error
                ( p_error_status  => l_return_status
                , p_error_scope   => Error_Handler.G_SCOPE_ALL
                , p_error_level   => Error_Handler.G_BO_LEVEL
                , p_other_message   => 'BOM_ERROR_BUSINESS_OBJECT'
                , p_other_status  => l_return_status
                , p_other_token_tbl   => l_token_tbl
                , x_bom_header_rec  => l_bom_header_rec
                , x_bom_revision_tbl  => l_bom_revision_tbl
                , x_bom_component_tbl   => l_bom_component_tbl
                , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                , x_bom_sub_component_tbl => l_bom_sub_component_tbl
                );
    END IF;

    x_return_status := l_return_status;
          x_msg_count := Error_Handler.Get_Message_Count;

    IF p_write_err_to_inttable = 'Y'
    THEN
      Error_Handler.Write_To_InterfaceTable;
    END IF;

    IF p_write_err_to_conclog = 'Y'
    THEN
      Error_Handler.Write_To_ConcurrentLog;
    END IF;

    IF Bom_Globals.Get_Debug = 'Y' AND p_write_err_to_debugfile = 'Y'
    THEN
                  Error_Handler.Write_To_DebugFile;
                  Error_Handler.Close_Debug_Session;
          END IF;


      EXCEPTION
        WHEN G_EXC_SEV_QUIT_OBJECT THEN

        -- Call Error Handler

          Error_Handler.Log_Error
              ( p_bom_header_rec  => p_bom_header_rec
    , p_bom_revision_tbl => p_bom_revision_tbl
    , p_bom_component_tbl => p_bom_component_tbl
    , p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
    , p_bom_sub_component_tbl => p_bom_sub_component_tbl
    , p_error_status => Error_Handler.G_STATUS_ERROR
    , p_error_scope => Error_Handler.G_SCOPE_ALL
    , p_error_level => Error_Handler.G_BO_LEVEL
                , p_other_message => l_other_message
                , p_other_status => Error_Handler.G_STATUS_ERROR
                , p_other_token_tbl => l_token_tbl
    , x_bom_header_rec      => l_bom_header_rec
                , x_bom_revision_tbl    => l_bom_revision_tbl
                , x_bom_component_tbl   => l_bom_component_tbl
                , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                , x_bom_sub_component_tbl => l_bom_sub_component_tbl
    );

          x_return_status := Error_Handler.G_STATUS_ERROR;
          x_msg_count := Error_Handler.Get_Message_Count;
                IF Bom_Globals.Get_Debug = 'Y'
                THEN
                  Error_Handler.Dump_Message_List;
                        Error_Handler.Close_Debug_Session;
                END IF;

        WHEN G_EXC_UNEXP_SKIP_OBJECT THEN

        -- Call Error Handler

          Error_Handler.Log_Error
    ( p_bom_header_rec      => p_bom_header_rec
                , p_bom_revision_tbl => p_bom_revision_tbl
                , p_bom_component_tbl => p_bom_component_tbl
                , p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
                , p_bom_sub_component_tbl => p_bom_sub_component_tbl
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_error_status => Error_Handler.G_STATUS_UNEXPECTED
                , p_error_level => Error_Handler.G_BO_LEVEL
                , p_other_status => Error_Handler.G_STATUS_NOT_PICKED
                , p_other_message => l_other_message
                , p_other_token_tbl => l_token_tbl
                , x_bom_header_rec      => l_bom_header_rec
                , x_bom_revision_tbl    => l_bom_revision_tbl
                , x_bom_component_tbl   => l_bom_component_tbl
                , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
                , x_bom_sub_component_tbl => l_bom_sub_component_tbl
                );

          x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
          x_msg_count := Error_Handler.Get_Message_Count;
                IF Bom_Globals.Get_Debug = 'Y'
                THEN
                  Error_Handler.Dump_Message_List;
                        Error_Handler.Close_Debug_Session;
                END IF;

  END Process_Bom;

  /********************************************************************
  * Procedure : Process_Bom
  * Parameters IN : Bom Header exposed column record
  *     Bom Inventorty Component exposed column table
  *     Bom Item Revision Exposed Column Table
  *     Substitute Component Exposed Column table
  *     Reference Designator Exposed column table
  * Parameters OUT: Bom Header Exposed Column Record
  *     Bom Inventory Components exposed column table
  *     Bom Item Revision Exposed Column Table
        *                 Substitute Component Exposed Column table
        *                 Reference Designator Exposed column table
  * Purpose : This procedure is the driving procedure of the BOM
  *     business Obect. It will verify the integrity of the
  *     business object and will call the private API which
  *     further drive the business object to perform business
  *     logic validations. (This is an overloaded procedure)
  *********************************************************************/
  PROCEDURE Process_Bom
  (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
   , p_api_version_number      IN  NUMBER := 1.0
   , p_init_msg_list       IN  BOOLEAN := FALSE
   , p_bom_header_rec      IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
          Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
   , p_bom_revision_tbl      IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
   , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
   , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type
            := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
   , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
            := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
   , x_bom_header_rec      IN OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
   , x_bom_revision_tbl      IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
   , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
   , x_bom_ref_designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
   , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
   , x_return_status           IN OUT NOCOPY VARCHAR2
   , x_msg_count               IN OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
         , p_write_err_to_inttable   IN  VARCHAR2 := 'N'
         , p_write_err_to_conclog    IN  VARCHAR2 := 'N'
         , p_write_err_to_debugfile  IN  VARCHAR2 := 'N'
   )
        IS
           x_bom_comp_ops_tbl  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;
        BEGIN

     Process_Bom
     (  p_bo_identifier          => p_bo_identifier
      , p_api_version_number     => p_api_version_number
      , p_init_msg_list        => p_init_msg_list
      , p_bom_header_rec         => p_bom_header_rec
      , p_bom_revision_tbl       => p_bom_revision_tbl
      , p_bom_component_tbl      => p_bom_component_tbl
      , p_bom_ref_designator_tbl => p_bom_ref_designator_tbl
      , p_bom_sub_component_tbl  => p_bom_sub_component_tbl
            , p_bom_comp_ops_tbl       => Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
      , x_bom_header_rec         => x_bom_header_rec
      , x_bom_revision_tbl       => x_bom_revision_tbl
      , x_bom_component_tbl      => x_bom_component_tbl
      , x_bom_ref_designator_tbl => x_bom_ref_designator_tbl
      , x_bom_sub_component_tbl  => x_bom_sub_component_tbl
            , x_bom_comp_ops_tbl       => x_bom_comp_ops_tbl
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
            , p_debug                  => p_debug
            , p_output_dir             => p_output_dir
            , p_debug_filename         => p_debug_filename
            , p_write_err_to_inttable  => p_write_err_to_inttable
            , p_write_err_to_conclog   => p_write_err_to_conclog
            , p_write_err_to_debugfile => p_write_err_to_debugfile
     );
        END;


        /********************************************************************
        * Procedure     : Process_Bom
        * Parameters IN :
        * Parameters OUT:
        * Purpose       : To process multiple business objects and to interact
  *     with the JAVA layer
        *********************************************************************/

  /*

        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'EBOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bomheaders_tbl          IN  BOMHeadersTable
         , p_bomrevisions_tbl        IN  BOMRevisionsTable
         , p_bomcomponents_tbl       IN  BOMComponentsTable
         , p_bomrefdesignators_tbl   IN  BOMRefDesignatorsTable
         , p_bomsubcomponents_tbl    IN  BOMSubComponentsTable
         , p_bomcompoperations_tbl   IN  BOMCompOperationsTable
         , x_bomheaders_tbl          IN OUT NOCOPY BOMHeadersTable
         , x_bomrevisions_tbl        IN OUT NOCOPY BOMRevisionsTable
         , x_bomcomponents_tbl       IN OUT NOCOPY BOMComponentsTable
         , x_bomrefdesignators_tbl   IN OUT NOCOPY BOMRefDesignatorsTable
         , x_bomsubcomponents_tbl    IN OUT NOCOPY BOMSubComponentsTable
         , x_bomcompoperations_tbl   IN OUT NOCOPY BOMCompOperationsTable
         , x_process_return_status   IN OUT NOCOPY VARCHAR2
   , x_process_error_msg       IN OUT NOCOPY VARCHAR2
         , x_bo_return_status        IN OUT NOCOPY VARCHAR2
         , x_bo_msg_count            IN OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
         , p_write_err_to_inttable   IN  VARCHAR2 := 'N'
         , p_write_err_to_conclog    IN  VARCHAR2 := 'N'
         , p_write_err_to_debugfile  IN  VARCHAR2 := 'N'
         ) IS

    l_bomlist_tbl             BOMListTable;

    -- Local variables for the IN parameters

          l_bomheaders_tbl          BOMHeadersTable        := p_bomheaders_tbl;
          l_bomrevisions_tbl        BOMRevisionsTable      := p_bomrevisions_tbl;
          l_bomcomponents_tbl       BOMComponentsTable     := p_bomcomponents_tbl;
          l_bomrefdesignators_tbl   BOMRefDesignatorsTable := p_bomrefdesignators_tbl;
          l_bomsubcomponents_tbl    BOMSubComponentsTable  := p_bomsubcomponents_tbl;
          l_bomcompoperations_tbl   BOMCompOperationsTable := p_bomcompoperations_tbl;


    -- BOM BO input parameters

          l_bom_header_rec         Bom_Bo_Pub.Bom_Head_Rec_Type;
          l_bom_revision_tbl       Bom_Bo_Pub.Bom_Revision_Tbl_Type;
          l_bom_component_tbl      Bom_Bo_Pub.Bom_Comps_Tbl_Type;
          l_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
          l_bom_sub_component_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
          l_bom_comp_ops_tbl       Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;

    -- Input records count

    l_listcount           NUMBER;
    l_hdrcount            NUMBER;
    l_revcount    NUMBER;
    l_compcount   NUMBER;
    l_refdescount   NUMBER;
    l_subcompcount  NUMBER;
    l_compopscount  NUMBER;


    -- Processed records count

    l_phdrcount   NUMBER;
    l_prevcount   NUMBER;
    l_pcompcount    NUMBER;
    l_prefdescount  NUMBER;
    l_psubcompcount NUMBER;
    l_pcompopscount NUMBER;

    -- Status and message variables

    l_bo_return_status        VARCHAR2(1);
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER := 0;
      l_previous_msg_count      NUMBER := 0;

    i               NUMBER; -- Used as counter variable

    -- Business Object Identifier variables

    l_assembly_item_name VARCHAR2(2000);
    l_organization_code  VARCHAR2(3);
    l_alternate_bom_code VARCHAR2(10);

    l_more_data        BOOLEAN := TRUE;

  BEGIN


      -- Business Object process status: If multiple business objects are
            -- processed during this call, then the status will be 'S' if all of them
            -- are successful or the status will be 'E' or 'U which depends on the status
            -- of the last errored out BO

      l_bo_return_status := 'S';


      -- Calculate the input count

      IF l_bomheaders_tbl IS NOT NULL
      THEN
        l_hdrcount  := l_bomheaders_tbl.COUNT;
      ELSE
        l_hdrcount  := 0;
      END IF;

      IF l_bomrevisions_tbl IS NOT NULL
      THEN
        l_revcount    := l_bomrevisions_tbl.COUNT;
      ELSE
        l_revcount    := 0;
      END IF;

      IF l_bomcomponents_tbl IS NOT NULL
      THEN
        l_compcount   := l_bomcomponents_tbl.COUNT;
      ELSE
        l_compcount   := 0;
      END IF;

      IF l_bomrefdesignators_tbl IS NOT NULL
      THEN
        l_refdescount   := l_bomrefdesignators_tbl.COUNT;
      ELSE
        l_refdescount   := 0;
      END IF;

      IF l_bomsubcomponents_tbl IS NOT NULL
      THEN
        l_subcompcount    := l_bomsubcomponents_tbl.COUNT;
      ELSE
        l_subcompcount    := 0;
      END IF;

      IF l_bomcompoperations_tbl IS NOT NULL
      THEN
        l_compopscount    := l_bomcompoperations_tbl.COUNT;
      ELSE
        l_compopscount    := 0;
      END IF;

      -- Group the data by each business object


      WHILE (l_more_data)
      LOOP

        -- Initialize all the variables for each business object

              l_bom_header_rec         := Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
              l_bom_revision_tbl       := Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL;
              l_bom_component_tbl      := Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
              l_bom_ref_designator_tbl := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL;
              l_bom_sub_component_tbl  := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
              l_bom_comp_ops_tbl       := Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL;


        l_assembly_item_name := NULL;
              l_organization_code  := NULL;
        l_alternate_bom_code := NULL;

        l_return_status := 'S';
        l_msg_count     := 0;

        -- Header : Convert from OBJECT type to RECORD type

        IF l_hdrcount <> 0 THEN

          FOR hdrRec IN 1..l_hdrcount
          LOOP
            IF l_bomheaders_tbl(hdrRec).return_status IS NULL OR
               l_bomheaders_tbl(hdrRec).return_status = FND_API.G_MISS_CHAR
      THEN
        l_assembly_item_name := l_bomheaders_tbl(hdrRec).assembly_item_name;
                    l_organization_code  := l_bomheaders_tbl(hdrRec).organization_code;
        l_alternate_bom_code := l_bomheaders_tbl(hdrRec).alternate_bom_code;

          l_bom_header_rec.Assembly_item_name      :=
          l_bomheaders_tbl(hdrRec).Assembly_item_name;
          l_bom_header_rec.Organization_Code       :=
          l_bomheaders_tbl(hdrRec).Organization_Code;
              l_bom_header_rec.Alternate_Bom_Code      :=
          l_bomheaders_tbl(hdrRec).Alternate_Bom_Code;
              l_bom_header_rec.Common_Assembly_Item_Name :=
          l_bomheaders_tbl(hdrRec).Common_Assembly_Item_Name;
              l_bom_header_rec.Assembly_Comment     :=
          l_bomheaders_tbl(hdrRec).Assembly_Comment;
              l_bom_header_rec.Assembly_Type      :=
          l_bomheaders_tbl(hdrRec).Assembly_Type;
              l_bom_header_rec.Transaction_Type     :=
          l_bomheaders_tbl(hdrRec).Transaction_Type;
              l_bom_header_rec.Return_Status            :=
          l_bomheaders_tbl(hdrRec).Return_Status;
              l_bom_header_rec.Attribute_category     :=
          l_bomheaders_tbl(hdrRec).Attribute_category;
              l_bom_header_rec.Attribute1  :=
          l_bomheaders_tbl(hdrRec).Attribute1;
                    l_bom_header_rec.Attribute2  :=
          l_bomheaders_tbl(hdrRec).Attribute2;
                    l_bom_header_rec.Attribute3 :=
          l_bomheaders_tbl(hdrRec).Attribute3;
                    l_bom_header_rec.Attribute4  :=
          l_bomheaders_tbl(hdrRec).Attribute4;
              l_bom_header_rec.Attribute5  :=
          l_bomheaders_tbl(hdrRec).Attribute5 ;
              l_bom_header_rec.Attribute6  :=
          l_bomheaders_tbl(hdrRec).Attribute6;
              l_bom_header_rec.Attribute7  :=
          l_bomheaders_tbl(hdrRec).Attribute7;
              l_bom_header_rec.Attribute8  :=
          l_bomheaders_tbl(hdrRec).Attribute8;
              l_bom_header_rec.Attribute9  :=
          l_bomheaders_tbl(hdrRec).Attribute9;
              l_bom_header_rec.Attribute10 :=
          l_bomheaders_tbl(hdrRec).Attribute10;
              l_bom_header_rec.Attribute11 :=
          l_bomheaders_tbl(hdrRec).Attribute11;
              l_bom_header_rec.Attribute12 :=
          l_bomheaders_tbl(hdrRec).Attribute12;
              l_bom_header_rec.Attribute13 :=
          l_bomheaders_tbl(hdrRec).Attribute13;
              l_bom_header_rec.Attribute14 :=
          l_bomheaders_tbl(hdrRec).Attribute14;
              l_bom_header_rec.Attribute15 :=
          l_bomheaders_tbl(hdrRec).Attribute15;
              l_bom_header_rec.Original_System_Reference  :=
          l_bomheaders_tbl(hdrRec).Original_System_Reference;
              l_bom_header_rec.Delete_Group_Name      :=
          l_bomheaders_tbl(hdrRec).Delete_Group_Name;
              l_bom_header_rec.DG_Description      :=
          l_bomheaders_tbl(hdrRec).DG_Description;
              l_bom_header_rec.Delete_Group_Name      :=
          l_bomheaders_tbl(hdrRec).Delete_Group_Name;

        -- Delete the record that has been already converted

        l_bomheaders_tbl.DELETE(hdrRec);

        -- Assign a not null value to the return status to avoid this record from being
        -- processed next time

        l_bomheaders_tbl(hdrRec).return_status := 'P';

        Exit;
      END IF;
    END LOOP;
        END IF; --  Header Record ends


        -- Item Revisions : Group the business object data from item revisions and
        -- convert them from OBJECT type to RECORD type

        IF l_revcount <> 0 THEN

    i := 0;

          FOR revRec IN 1..l_revcount
          LOOP

            IF l_bomrevisions_tbl(revRec).return_status IS NULL OR
               l_bomrevisions_tbl(revRec).return_status = FND_API.G_MISS_CHAR
      THEN

        IF (l_assembly_item_name IS NULL) OR
                       (l_assembly_item_name IS NOT NULL AND
            l_bomrevisions_tbl(revRec).assembly_item_name = l_assembly_item_name AND
                        l_bomrevisions_tbl(revRec).organization_code = l_organization_code AND
            l_bomrevisions_tbl(revRec).alternate_bom_code = l_alternate_bom_code)
        THEN

          IF l_assembly_item_name IS NULL
          THEN
            l_assembly_item_name := l_bomrevisions_tbl(revRec).assembly_item_name;
                        l_organization_code  := l_bomrevisions_tbl(revRec).organization_code;
            l_alternate_bom_code := l_bomrevisions_tbl(revRec).alternate_bom_code;
          END IF;

          i := i+ 1;

          l_bom_revision_tbl(i).Organization_Code     :=
          l_bomrevisions_tbl(revRec).Organization_Code ;
          l_bom_revision_tbl(i).Assembly_Item_Name     :=
          l_bomrevisions_tbl(revRec).Assembly_Item_Name ;
          l_bom_revision_tbl(i).Alternate_BOM_Code   :=
          l_bomrevisions_tbl(revRec).Alternate_BOM_Code;
          l_bom_revision_tbl(i).Revision  :=
          l_bomrevisions_tbl(revRec).Revision;
          l_bom_revision_tbl(i).Start_Effective_Date  :=
          l_bomrevisions_tbl(revRec).Start_Effective_Date;
          l_bom_revision_tbl(i).Description  :=
          l_bomrevisions_tbl(revRec).Description;
          l_bom_revision_tbl(i).Attribute_category     :=
          l_bomrevisions_tbl(revRec).Attribute_category;
          l_bom_revision_tbl(i).Attribute1  :=
          l_bomrevisions_tbl(revRec).Attribute1;
          l_bom_revision_tbl(i).Attribute2  :=
          l_bomrevisions_tbl(revRec).Attribute2;
          l_bom_revision_tbl(i).Attribute3  :=
          l_bomrevisions_tbl(revRec).Attribute3;
          l_bom_revision_tbl(i).Attribute4  :=
          l_bomrevisions_tbl(revRec).Attribute4;
          l_bom_revision_tbl(i).Attribute5  :=
          l_bomrevisions_tbl(revRec).Attribute5;
          l_bom_revision_tbl(i).Attribute6  :=
          l_bomrevisions_tbl(revRec).Attribute6;
          l_bom_revision_tbl(i).Attribute7  :=
          l_bomrevisions_tbl(revRec).Attribute7;
          l_bom_revision_tbl(i).Attribute8  :=
          l_bomrevisions_tbl(revRec).Attribute8;
          l_bom_revision_tbl(i).Attribute9  :=
          l_bomrevisions_tbl(revRec).Attribute9;
          l_bom_revision_tbl(i).Attribute10 :=
          l_bomrevisions_tbl(revRec).Attribute10;
          l_bom_revision_tbl(i).Attribute11 :=
          l_bomrevisions_tbl(revRec).Attribute11;
          l_bom_revision_tbl(i).Attribute12 :=
          l_bomrevisions_tbl(revRec).Attribute12;
          l_bom_revision_tbl(i).Attribute13 :=
          l_bomrevisions_tbl(revRec).Attribute13;
          l_bom_revision_tbl(i).Attribute14 :=
          l_bomrevisions_tbl(revRec).Attribute14;
          l_bom_revision_tbl(i).Attribute15 :=
          l_bomrevisions_tbl(revRec).Attribute15;
          l_bom_revision_tbl(i).Return_Status     :=
          l_bomrevisions_tbl(revRec).Return_Status;
          l_bom_revision_tbl(i).Transaction_Type     :=
          l_bomrevisions_tbl(revRec).Transaction_Type;
          l_bom_revision_tbl(i).Original_System_Reference     :=
          l_bomrevisions_tbl(revRec).Original_System_Reference;

          -- Delete the record that has been already converted

          l_bomrevisions_tbl.DELETE(revRec);

          -- Assign a not null value to the return status to avoid this record from being
          -- processed next time

          l_bomrevisions_tbl(revRec).return_status := 'P';

        END IF;
      END IF;
          END LOOP;
        END IF;  -- Revision Table ends


        -- Component : Group the business object data from components and
        --             convert them from OBJECT type to RECORD type


        IF l_compcount <> 0 THEN

    i := 0;

          FOR compRec IN 1..l_compcount
          LOOP

            IF l_bomcomponents_tbl(compRec).return_status IS NULL OR
               l_bomcomponents_tbl(compRec).return_status = FND_API.G_MISS_CHAR
      THEN

        IF (l_assembly_item_name IS NULL) OR
                       (l_assembly_item_name IS NOT NULL AND
            l_bomcomponents_tbl(compRec).assembly_item_name = l_assembly_item_name AND
                        l_bomcomponents_tbl(compRec).organization_code = l_organization_code AND
            l_bomcomponents_tbl(compRec).alternate_bom_code = l_alternate_bom_code)
        THEN

          IF l_assembly_item_name IS NULL
          THEN
            l_assembly_item_name := l_bomcomponents_tbl(compRec).assembly_item_name;
                        l_organization_code  := l_bomcomponents_tbl(compRec).organization_code;
            l_alternate_bom_code := l_bomcomponents_tbl(compRec).alternate_bom_code;
          END IF;

          i := i+ 1;

          l_bom_component_tbl(i).Organization_Code     :=
          l_bomcomponents_tbl(compRec).Organization_Code ;
          l_bom_component_tbl(i).Assembly_Item_Name     :=
          l_bomcomponents_tbl(compRec).Assembly_Item_Name ;
          l_bom_component_tbl(i).Start_Effective_Date  :=
          l_bomcomponents_tbl(compRec).Start_Effective_Date;
          l_bom_component_tbl(i).Disable_Date     :=
          l_bomcomponents_tbl(compRec).Disable_Date;
          l_bom_component_tbl(i).Operation_Sequence_Number    :=
          l_bomcomponents_tbl(compRec).Operation_Sequence_Number;
          l_bom_component_tbl(i).Component_Item_Name   :=
          l_bomcomponents_tbl(compRec).Component_Item_Name;
          l_bom_component_tbl(i).Alternate_BOM_Code   :=
          l_bomcomponents_tbl(compRec).Alternate_BOM_Code;
          l_bom_component_tbl(i).New_Effectivity_Date  :=
          l_bomcomponents_tbl(compRec).New_Effectivity_Date;
          l_bom_component_tbl(i).New_Operation_Sequence_Number   :=
          l_bomcomponents_tbl(compRec).New_Operation_Sequence_Number;
          l_bom_component_tbl(i).Item_Sequence_Number   :=
          l_bomcomponents_tbl(compRec).Item_Sequence_Number;
          l_bom_component_tbl(i).Basis_Type:=
          l_bomcomponents_tbl(compRec).Basis_Type;
          l_bom_component_tbl(i).Quantity_Per_Assembly  :=
          l_bomcomponents_tbl(compRec).Quantity_Per_Assembly;
          l_bom_component_tbl(i).Inverse_Quantity  :=
          l_bomcomponents_tbl(compRec).Inverse_Quantity;
          l_bom_component_tbl(i).Planning_Percent  :=
          l_bomcomponents_tbl(compRec).Planning_Percent;
          l_bom_component_tbl(i).Projected_Yield     :=
          l_bomcomponents_tbl(compRec).Projected_Yield;
          l_bom_component_tbl(i).Include_In_Cost_Rollup :=
          l_bomcomponents_tbl(compRec).Include_In_Cost_Rollup;
          l_bom_component_tbl(i).Wip_Supply_Type     :=
          l_bomcomponents_tbl(compRec).Wip_Supply_Type;
          l_bom_component_tbl(i).So_Basis     :=
          l_bomcomponents_tbl(compRec).So_Basis;
          l_bom_component_tbl(i).Optional     :=
          l_bomcomponents_tbl(compRec).Optional;
          l_bom_component_tbl(i).Mutually_Exclusive     :=
          l_bomcomponents_tbl(compRec).Mutually_Exclusive;
          l_bom_component_tbl(i).Check_Atp     :=
          l_bomcomponents_tbl(compRec).Check_Atp;
          l_bom_component_tbl(i).Shipping_Allowed     :=
          l_bomcomponents_tbl(compRec).Shipping_Allowed;
          l_bom_component_tbl(i).Required_To_Ship     :=
          l_bomcomponents_tbl(compRec).Required_To_Ship;
          l_bom_component_tbl(i).Required_For_Revenue  :=
          l_bomcomponents_tbl(compRec).Required_For_Revenue;
          l_bom_component_tbl(i).Include_On_Ship_Docs  :=
          l_bomcomponents_tbl(compRec).Include_On_Ship_Docs;
          l_bom_component_tbl(i).Quantity_Related     :=
          l_bomcomponents_tbl(compRec).Quantity_Related;
          l_bom_component_tbl(i).Supply_Subinventory   :=
          l_bomcomponents_tbl(compRec).Supply_Subinventory;
          l_bom_component_tbl(i).Location_Name     :=
          l_bomcomponents_tbl(compRec).Location_Name;
          l_bom_component_tbl(i).Minimum_Allowed_Quantity :=
          l_bomcomponents_tbl(compRec).Minimum_Allowed_Quantity;
          l_bom_component_tbl(i).Maximum_Allowed_Quantity     :=
          l_bomcomponents_tbl(compRec).Maximum_Allowed_Quantity;
          l_bom_component_tbl(i).Comments     :=
          l_bomcomponents_tbl(compRec).Comments;
          l_bom_component_tbl(i).Attribute_category     :=
          l_bomcomponents_tbl(compRec).Attribute_category;
          l_bom_component_tbl(i).Attribute1  :=
          l_bomcomponents_tbl(compRec).Attribute1;
          l_bom_component_tbl(i).Attribute2  :=
          l_bomcomponents_tbl(compRec).Attribute2;
          l_bom_component_tbl(i).Attribute3  :=
          l_bomcomponents_tbl(compRec).Attribute3;
          l_bom_component_tbl(i).Attribute4  :=
          l_bomcomponents_tbl(compRec).Attribute4;
          l_bom_component_tbl(i).Attribute5  :=
          l_bomcomponents_tbl(compRec).Attribute5;
          l_bom_component_tbl(i).Attribute6  :=
          l_bomcomponents_tbl(compRec).Attribute6;
          l_bom_component_tbl(i).Attribute7  :=
          l_bomcomponents_tbl(compRec).Attribute7;
          l_bom_component_tbl(i).Attribute8  :=
          l_bomcomponents_tbl(compRec).Attribute8;
          l_bom_component_tbl(i).Attribute9  :=
          l_bomcomponents_tbl(compRec).Attribute9;
          l_bom_component_tbl(i).Attribute10 :=
          l_bomcomponents_tbl(compRec).Attribute10;
          l_bom_component_tbl(i).Attribute11 :=
          l_bomcomponents_tbl(compRec).Attribute11;
          l_bom_component_tbl(i).Attribute12 :=
          l_bomcomponents_tbl(compRec).Attribute12;
          l_bom_component_tbl(i).Attribute13 :=
          l_bomcomponents_tbl(compRec).Attribute13;
          l_bom_component_tbl(i).Attribute14 :=
          l_bomcomponents_tbl(compRec).Attribute14;
          l_bom_component_tbl(i).Attribute15 :=
          l_bomcomponents_tbl(compRec).Attribute15;
          l_bom_component_tbl(i).From_End_Item_Unit_Number    :=
          l_bomcomponents_tbl(compRec).From_End_Item_Unit_Number;
          l_bom_component_tbl(i).New_From_End_Item_Unit_Number    :=
          l_bomcomponents_tbl(compRec).New_From_End_Item_Unit_Number;
          l_bom_component_tbl(i).To_End_Item_Unit_Number     :=
          l_bomcomponents_tbl(compRec).To_End_Item_Unit_Number;
          l_bom_component_tbl(i).Return_Status     :=
          l_bomcomponents_tbl(compRec).Return_Status;
          l_bom_component_tbl(i).Transaction_Type     :=
          l_bomcomponents_tbl(compRec).Transaction_Type;
          l_bom_component_tbl(i).Original_System_Reference     :=
          l_bomcomponents_tbl(compRec).Original_System_Reference;
          l_bom_component_tbl(i).Delete_Group_Name     :=
          l_bomcomponents_tbl(compRec).Delete_Group_Name;
          l_bom_component_tbl(i).DG_Description     :=
          l_bomcomponents_tbl(compRec).DG_Description;
          l_bom_component_tbl(i).Enforce_Int_Requirements    :=
          l_bomcomponents_tbl(compRec).Enforce_Int_Requirements;

          -- Delete the record that has been already converted

          l_bomcomponents_tbl.DELETE(compRec);

          -- Assign a not null value to the return status to avoid this record from being
          -- processed next time

          l_bomcomponents_tbl(compRec).return_status := 'P';

        END IF;
      END IF;
          END LOOP;
        END IF; -- Component Table ends


        -- Substitute Component : Group the business object data from substitute components and
        -- convert them from OBJECT type to RECORD type


        IF l_subcompcount <> 0 THEN

    i := 0;

          FOR scompRec IN 1..l_subcompcount
          LOOP

            IF l_bomsubcomponents_tbl(scompRec).return_status IS NULL OR
               l_bomsubcomponents_tbl(scompRec).return_status = FND_API.G_MISS_CHAR
      THEN

        IF (l_assembly_item_name IS NULL) OR
                       (l_assembly_item_name IS NOT NULL AND
            l_bomsubcomponents_tbl(scompRec).assembly_item_name = l_assembly_item_name AND
                        l_bomsubcomponents_tbl(scompRec).organization_code = l_organization_code AND
            l_bomsubcomponents_tbl(scompRec).alternate_bom_code = l_alternate_bom_code)
        THEN

          IF l_assembly_item_name IS NULL
          THEN
            l_assembly_item_name := l_bomsubcomponents_tbl(scompRec).assembly_item_name;
                        l_organization_code  := l_bomsubcomponents_tbl(scompRec).organization_code;
            l_alternate_bom_code := l_bomsubcomponents_tbl(scompRec).alternate_bom_code;
          END IF;

          i := i+ 1;

          l_bom_sub_component_tbl(i).Organization_Code     :=
          l_bomsubcomponents_tbl(scompRec).Organization_Code ;
          l_bom_sub_component_tbl(i).Assembly_Item_Name     :=
          l_bomsubcomponents_tbl(scompRec).Assembly_Item_Name ;
          l_bom_sub_component_tbl(i).Start_Effective_Date  :=
          l_bomsubcomponents_tbl(scompRec).Start_Effective_Date;
          l_bom_sub_component_tbl(i).Operation_Sequence_Number    :=
          l_bomsubcomponents_tbl(scompRec).Operation_Sequence_Number;
          l_bom_sub_component_tbl(i).Component_Item_Name   :=
          l_bomsubcomponents_tbl(scompRec).Component_Item_Name;
          l_bom_sub_component_tbl(i).Alternate_BOM_Code   :=
          l_bomsubcomponents_tbl(scompRec).Alternate_BOM_Code;
          l_bom_sub_component_tbl(i).Substitute_Component_Name   :=
          l_bomsubcomponents_tbl(scompRec).Substitute_Component_Name;
          l_bom_sub_component_tbl(i).Substitute_Item_Quantity  :=
          l_bomsubcomponents_tbl(scompRec).Substitute_Item_Quantity;
          l_bom_sub_component_tbl(i).Attribute_category     :=
          l_bomsubcomponents_tbl(scompRec).Attribute_category;
          l_bom_sub_component_tbl(i).Attribute1  :=
          l_bomsubcomponents_tbl(scompRec).Attribute1;
          l_bom_sub_component_tbl(i).Attribute2  :=
          l_bomsubcomponents_tbl(scompRec).Attribute2;
          l_bom_sub_component_tbl(i).Attribute3  :=
          l_bomsubcomponents_tbl(scompRec).Attribute3;
          l_bom_sub_component_tbl(i).Attribute4  :=
          l_bomsubcomponents_tbl(scompRec).Attribute4;
          l_bom_sub_component_tbl(i).Attribute5  :=
          l_bomsubcomponents_tbl(scompRec).Attribute5;
          l_bom_sub_component_tbl(i).Attribute6  :=
          l_bomsubcomponents_tbl(scompRec).Attribute6;
          l_bom_sub_component_tbl(i).Attribute7  :=
          l_bomsubcomponents_tbl(scompRec).Attribute7;
          l_bom_sub_component_tbl(i).Attribute8  :=
          l_bomsubcomponents_tbl(scompRec).Attribute8;
          l_bom_sub_component_tbl(i).Attribute9  :=
          l_bomsubcomponents_tbl(scompRec).Attribute9;
          l_bom_sub_component_tbl(i).Attribute10 :=
          l_bomsubcomponents_tbl(scompRec).Attribute10;
          l_bom_sub_component_tbl(i).Attribute11 :=
          l_bomsubcomponents_tbl(scompRec).Attribute11;
          l_bom_sub_component_tbl(i).Attribute12 :=
          l_bomsubcomponents_tbl(scompRec).Attribute12;
          l_bom_sub_component_tbl(i).Attribute13 :=
          l_bomsubcomponents_tbl(scompRec).Attribute13;
          l_bom_sub_component_tbl(i).Attribute14 :=
          l_bomsubcomponents_tbl(scompRec).Attribute14;
          l_bom_sub_component_tbl(i).Attribute15 :=
          l_bomsubcomponents_tbl(scompRec).Attribute15;
          l_bom_sub_component_tbl(i).From_End_Item_Unit_Number    :=
          l_bomsubcomponents_tbl(scompRec).From_End_Item_Unit_Number;
          l_bom_sub_component_tbl(i).Return_Status     :=
          l_bomsubcomponents_tbl(scompRec).Return_Status;
          l_bom_sub_component_tbl(i).Transaction_Type     :=
          l_bomsubcomponents_tbl(scompRec).Transaction_Type;
          l_bom_sub_component_tbl(i).Original_System_Reference     :=
          l_bomsubcomponents_tbl(scompRec).Original_System_Reference;
          l_bom_sub_component_tbl(i).Enforce_Int_Requirements    :=
          l_bomsubcomponents_tbl(scompRec).Enforce_Int_Requirements;

          -- Delete the record that has been already converted

          l_bomsubcomponents_tbl.DELETE(scompRec);

          -- Assign a not null value to the return status to avoid this record from being
          -- processed next time

          l_bomsubcomponents_tbl(scompRec).return_status := 'P';

        END IF;
      END IF;
          END LOOP;
        END IF; -- Substitute Component Table ends


        -- Reference Designator : Group the business object data from reference designators and
        -- convert them from OBJECT type to RECORD type


        IF l_refdescount <> 0 THEN

    i := 0;

          FOR rdesRec IN 1..l_refdescount
          LOOP

            IF l_bomrefdesignators_tbl(rdesRec).return_status IS NULL OR
               l_bomrefdesignators_tbl(rdesRec).return_status = FND_API.G_MISS_CHAR
      THEN

        IF (l_assembly_item_name IS NULL) OR
                       (l_assembly_item_name IS NOT NULL AND
            l_bomrefdesignators_tbl(rdesRec).assembly_item_name = l_assembly_item_name AND
                        l_bomrefdesignators_tbl(rdesRec).organization_code = l_organization_code AND
            l_bomrefdesignators_tbl(rdesRec).alternate_bom_code = l_alternate_bom_code)
        THEN

          IF l_assembly_item_name IS NULL
          THEN
            l_assembly_item_name := l_bomrefdesignators_tbl(rdesRec).assembly_item_name;
                        l_organization_code  := l_bomrefdesignators_tbl(rdesRec).organization_code;
            l_alternate_bom_code := l_bomrefdesignators_tbl(rdesRec).alternate_bom_code;
          END IF;

          i := i+ 1;

          l_bom_ref_designator_tbl(i).Organization_Code     :=
          l_bomrefdesignators_tbl(rdesRec).Organization_Code ;
          l_bom_ref_designator_tbl(i).Assembly_Item_Name     :=
          l_bomrefdesignators_tbl(rdesRec).Assembly_Item_Name ;
          l_bom_ref_designator_tbl(i).Start_Effective_Date  :=
          l_bomrefdesignators_tbl(rdesRec).Start_Effective_Date;
          l_bom_ref_designator_tbl(i).Operation_Sequence_Number    :=
          l_bomrefdesignators_tbl(rdesRec).Operation_Sequence_Number;
          l_bom_ref_designator_tbl(i).Component_Item_Name   :=
          l_bomrefdesignators_tbl(rdesRec).Component_Item_Name;
          l_bom_ref_designator_tbl(i).Alternate_BOM_Code   :=
          l_bomrefdesignators_tbl(rdesRec).Alternate_BOM_Code;
          l_bom_ref_designator_tbl(i).Reference_Designator_Name   :=
          l_bomrefdesignators_tbl(rdesRec).Reference_Designator_Name;
          l_bom_ref_designator_tbl(i).Ref_Designator_Comment  :=
          l_bomrefdesignators_tbl(rdesRec).Ref_Designator_Comment;
          l_bom_ref_designator_tbl(i).Attribute_category     :=
          l_bomrefdesignators_tbl(rdesRec).Attribute_category;
          l_bom_ref_designator_tbl(i).Attribute1  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute1;
          l_bom_ref_designator_tbl(i).Attribute2  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute2;
          l_bom_ref_designator_tbl(i).Attribute3  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute3;
          l_bom_ref_designator_tbl(i).Attribute4  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute4;
          l_bom_ref_designator_tbl(i).Attribute5  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute5;
          l_bom_ref_designator_tbl(i).Attribute6  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute6;
          l_bom_ref_designator_tbl(i).Attribute7  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute7;
          l_bom_ref_designator_tbl(i).Attribute8  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute8;
          l_bom_ref_designator_tbl(i).Attribute9  :=
          l_bomrefdesignators_tbl(rdesRec).Attribute9;
          l_bom_ref_designator_tbl(i).Attribute10 :=
          l_bomrefdesignators_tbl(rdesRec).Attribute10;
          l_bom_ref_designator_tbl(i).Attribute11 :=
          l_bomrefdesignators_tbl(rdesRec).Attribute11;
          l_bom_ref_designator_tbl(i).Attribute12 :=
          l_bomrefdesignators_tbl(rdesRec).Attribute12;
          l_bom_ref_designator_tbl(i).Attribute13 :=
          l_bomrefdesignators_tbl(rdesRec).Attribute13;
          l_bom_ref_designator_tbl(i).Attribute14 :=
          l_bomrefdesignators_tbl(rdesRec).Attribute14;
          l_bom_ref_designator_tbl(i).Attribute15 :=
          l_bomrefdesignators_tbl(rdesRec).Attribute15;
          l_bom_ref_designator_tbl(i).From_End_Item_Unit_Number    :=
          l_bomrefdesignators_tbl(rdesRec).From_End_Item_Unit_Number;
          l_bom_ref_designator_tbl(i).New_Reference_Designator    :=
          l_bomrefdesignators_tbl(rdesRec).New_Reference_Designator;
          l_bom_ref_designator_tbl(i).Return_Status     :=
          l_bomrefdesignators_tbl(rdesRec).Return_Status;
          l_bom_ref_designator_tbl(i).Transaction_Type     :=
          l_bomrefdesignators_tbl(rdesRec).Transaction_Type;
          l_bom_ref_designator_tbl(i).Original_System_Reference     :=
          l_bomrefdesignators_tbl(rdesRec).Original_System_Reference;

          -- Delete the record that has been already converted

          l_bomrefdesignators_tbl.DELETE(rdesRec);

          -- Assign a not null value to the return status to avoid this record from being
          -- processed next time

          l_bomrefdesignators_tbl(rdesRec).return_status := 'P';

        END IF;
      END IF;
          END LOOP;
        END IF; -- Reference Designator Table ends


        -- Component Operations : Group the business object data from component operations and
        -- convert them from OBJECT type to RECORD type


        IF l_compopscount <> 0 THEN

    i := 0;

          FOR copsRec IN 1..l_compopscount
          LOOP

            IF l_bomcompoperations_tbl(copsRec).return_status IS NULL OR
               l_bomcompoperations_tbl(copsRec).return_status = FND_API.G_MISS_CHAR
      THEN

        IF (l_assembly_item_name IS NULL) OR
                       (l_assembly_item_name IS NOT NULL AND
            l_bomcompoperations_tbl(copsRec).assembly_item_name = l_assembly_item_name AND
                        l_bomcompoperations_tbl(copsRec).organization_code = l_organization_code AND
            l_bomcompoperations_tbl(copsRec).alternate_bom_code = l_alternate_bom_code)
        THEN

          IF l_assembly_item_name IS NULL
          THEN
            l_assembly_item_name := l_bomcompoperations_tbl(copsRec).assembly_item_name;
                        l_organization_code  := l_bomcompoperations_tbl(copsRec).organization_code;
            l_alternate_bom_code := l_bomcompoperations_tbl(copsRec).alternate_bom_code;
          END IF;

          i := i+ 1;

          l_bom_comp_ops_tbl(i).Organization_Code     :=
          l_bomcompoperations_tbl(copsRec).Organization_Code ;
          l_bom_comp_ops_tbl(i).Assembly_Item_Name     :=
          l_bomcompoperations_tbl(copsRec).Assembly_Item_Name ;
          l_bom_comp_ops_tbl(i).Start_Effective_Date  :=
          l_bomcompoperations_tbl(copsRec).Start_Effective_Date;
          l_bom_comp_ops_tbl(i).From_End_Item_Unit_Number    :=
          l_bomcompoperations_tbl(copsRec).From_End_Item_Unit_Number;
          l_bom_comp_ops_tbl(i).To_End_Item_Unit_Number    :=
          l_bomcompoperations_tbl(copsRec).To_End_Item_Unit_Number;
          l_bom_comp_ops_tbl(i).Operation_Sequence_Number    :=
          l_bomcompoperations_tbl(copsRec).Operation_Sequence_Number;
          l_bom_comp_ops_tbl(i).Component_Item_Name   :=
          l_bomcompoperations_tbl(copsRec).Component_Item_Name;
          l_bom_comp_ops_tbl(i).Additional_Operation_Seq_Num    :=
          l_bomcompoperations_tbl(copsRec).Additional_Operation_Seq_Num;
          l_bom_comp_ops_tbl(i).Alternate_BOM_Code   :=
          l_bomcompoperations_tbl(copsRec).Alternate_BOM_Code;
          l_bom_comp_ops_tbl(i).Attribute_category     :=
          l_bomcompoperations_tbl(copsRec).Attribute_category;
          l_bom_comp_ops_tbl(i).Attribute1  :=
          l_bomcompoperations_tbl(copsRec).Attribute1;
          l_bom_comp_ops_tbl(i).Attribute2  :=
          l_bomcompoperations_tbl(copsRec).Attribute2;
          l_bom_comp_ops_tbl(i).Attribute3  :=
          l_bomcompoperations_tbl(copsRec).Attribute3;
          l_bom_comp_ops_tbl(i).Attribute4  :=
          l_bomcompoperations_tbl(copsRec).Attribute4;
          l_bom_comp_ops_tbl(i).Attribute5  :=
          l_bomcompoperations_tbl(copsRec).Attribute5;
          l_bom_comp_ops_tbl(i).Attribute6  :=
          l_bomcompoperations_tbl(copsRec).Attribute6;
          l_bom_comp_ops_tbl(i).Attribute7  :=
          l_bomcompoperations_tbl(copsRec).Attribute7;
          l_bom_comp_ops_tbl(i).Attribute8  :=
          l_bomcompoperations_tbl(copsRec).Attribute8;
          l_bom_comp_ops_tbl(i).Attribute9  :=
          l_bomcompoperations_tbl(copsRec).Attribute9;
          l_bom_comp_ops_tbl(i).Attribute10 :=
          l_bomcompoperations_tbl(copsRec).Attribute10;
          l_bom_comp_ops_tbl(i).Attribute11 :=
          l_bomcompoperations_tbl(copsRec).Attribute11;
          l_bom_comp_ops_tbl(i).Attribute12 :=
          l_bomcompoperations_tbl(copsRec).Attribute12;
          l_bom_comp_ops_tbl(i).Attribute13 :=
          l_bomcompoperations_tbl(copsRec).Attribute13;
          l_bom_comp_ops_tbl(i).Attribute14 :=
          l_bomcompoperations_tbl(copsRec).Attribute14;
          l_bom_comp_ops_tbl(i).Attribute15 :=
          l_bomcompoperations_tbl(copsRec).Attribute15;
          l_bom_comp_ops_tbl(i).Return_Status     :=
          l_bomcompoperations_tbl(copsRec).Return_Status;
          l_bom_comp_ops_tbl(i).Transaction_Type     :=
          l_bomcompoperations_tbl(copsRec).Transaction_Type;

          -- Delete the record that has been already converted to free up memory space

          l_bomcompoperations_tbl.DELETE(copsRec);

          -- Assign a not null value to the return status to avoid this record from being
          -- processed next time

          l_bomcompoperations_tbl(copsRec).return_status := 'P';

        END IF;
      END IF;
          END LOOP;
        END IF;  -- Component Operations Table ends

        -- Complete the process when there is no more data

        IF l_assembly_item_name IS NULL
        THEN
    l_more_data := FALSE;
    Exit; -- Exit from the WHILE Loop
        END IF;

        -- Call the Process_BOM procedure

              Process_Bom
              (  p_bo_identifier          => p_bo_identifier
              , p_api_version_number     => p_api_version_number
              , p_init_msg_list          => p_init_msg_list
              , p_bom_header_rec         => l_bom_header_rec
              , p_bom_revision_tbl       => l_bom_revision_tbl
              , p_bom_component_tbl      => l_bom_component_tbl
              , p_bom_ref_designator_tbl => l_bom_ref_designator_tbl
              , p_bom_sub_component_tbl  => l_bom_sub_component_tbl
              , p_bom_comp_ops_tbl       => l_bom_comp_ops_tbl
              , x_bom_header_rec         => l_bom_header_rec
              , x_bom_revision_tbl       => l_bom_revision_tbl
              , x_bom_component_tbl      => l_bom_component_tbl
              , x_bom_ref_designator_tbl => l_bom_ref_designator_tbl
              , x_bom_sub_component_tbl  => l_bom_sub_component_tbl
              , x_bom_comp_ops_tbl       => l_bom_comp_ops_tbl
              , x_return_status          => l_return_status
              , x_msg_count              => l_msg_count
              , p_debug                  => p_debug
              , p_output_dir             => p_output_dir
              , p_debug_filename         => p_debug_filename
              );


        -- Count of the error messages for the current business object

        l_previous_msg_count := l_msg_count - l_previous_msg_count;

        -- Store the business object details in the internal BOM list

        IF l_bomlist_tbl IS NULL
        THEN
    l_bomlist_tbl := BOMListTable(null);
        END IF;

        l_listcount := l_bomlist_tbl.COUNT + 1;

              l_bomlist_tbl(l_listcount).assembly_item_name  := l_assembly_item_name;
              l_bomlist_tbl(l_listcount).organization_code   := l_organization_code;
              l_bomlist_tbl(l_listcount).alternate_bom_code  := l_alternate_bom_code;
              l_bomlist_tbl(l_listcount).return_status       := l_return_status;
              l_bomlist_tbl(l_listcount).mesg_count          := l_previous_msg_count;

        -- Status of the whole process

        IF l_return_status <> 'S' THEN
    l_bo_return_status := l_return_status;
        END IF;

        -- Header : Convert from REC type to OBJECT type

        -- Initialize the header tbl by calling the constructor

        IF x_bomheaders_tbl IS NULL
        THEN
          x_bomheaders_tbl := BOMHeadersTable(null);
        END IF;

        l_phdrcount := x_bomheaders_tbl.COUNT + 1;

        IF l_bom_header_rec.assembly_item_name IS NOT NULL THEN
          x_bomheaders_tbl(l_phdrcount).Assembly_item_name      :=
          l_bom_header_rec.Assembly_item_name;
          x_bomheaders_tbl(l_phdrcount).Organization_Code      :=
          l_bom_header_rec.Organization_Code;
              x_bomheaders_tbl(l_phdrcount).Alternate_Bom_Code       :=
          l_bom_header_rec.Alternate_Bom_Code;
              x_bomheaders_tbl(l_phdrcount).Common_Assembly_Item_Name :=
          l_bom_header_rec.Common_Assembly_Item_Name;
              x_bomheaders_tbl(l_phdrcount).Assembly_Comment      :=
          l_bom_header_rec.Assembly_Comment;
              x_bomheaders_tbl(l_phdrcount).Assembly_Type     :=
          l_bom_header_rec.Assembly_Type;
              x_bomheaders_tbl(l_phdrcount).Transaction_Type      :=
          l_bom_header_rec.Transaction_Type;
              x_bomheaders_tbl(l_phdrcount).Return_Status            :=
          l_bom_header_rec.Return_Status;
              x_bomheaders_tbl(l_phdrcount).Attribute_category      :=
          l_bom_header_rec.Attribute_category;
              x_bomheaders_tbl(l_phdrcount).Attribute1  :=
          l_bom_header_rec.Attribute1;
                    x_bomheaders_tbl(l_phdrcount).Attribute2  :=
          l_bom_header_rec.Attribute2;
                    x_bomheaders_tbl(l_phdrcount).Attribute3 :=
          l_bom_header_rec.Attribute3;
                    x_bomheaders_tbl(l_phdrcount).Attribute4  :=
          l_bom_header_rec.Attribute4;
              x_bomheaders_tbl(l_phdrcount).Attribute5  :=
          l_bom_header_rec.Attribute5 ;
              x_bomheaders_tbl(l_phdrcount).Attribute6  :=
          l_bom_header_rec.Attribute6;
              x_bomheaders_tbl(l_phdrcount).Attribute7  :=
          l_bom_header_rec.Attribute7;
              x_bomheaders_tbl(l_phdrcount).Attribute8  :=
          l_bom_header_rec.Attribute8;
              x_bomheaders_tbl(l_phdrcount).Attribute9  :=
          l_bom_header_rec.Attribute9;
              x_bomheaders_tbl(l_phdrcount).Attribute10 :=
          l_bom_header_rec.Attribute10;
              x_bomheaders_tbl(l_phdrcount).Attribute11 :=
          l_bom_header_rec.Attribute11;
              x_bomheaders_tbl(l_phdrcount).Attribute12 :=
          l_bom_header_rec.Attribute12;
              x_bomheaders_tbl(l_phdrcount).Attribute13 :=
          l_bom_header_rec.Attribute13;
              x_bomheaders_tbl(l_phdrcount).Attribute14 :=
          l_bom_header_rec.Attribute14;
              x_bomheaders_tbl(l_phdrcount).Attribute15 :=
          l_bom_header_rec.Attribute15;
              x_bomheaders_tbl(l_phdrcount).Original_System_Reference  :=
          l_bom_header_rec.Original_System_Reference;
              x_bomheaders_tbl(l_phdrcount).Delete_Group_Name     :=
          l_bom_header_rec.Delete_Group_Name;
              x_bomheaders_tbl(l_phdrcount).DG_Description       :=
          l_bom_header_rec.DG_Description;
              x_bomheaders_tbl(l_phdrcount).Delete_Group_Name     :=
          l_bom_header_rec.Delete_Group_Name;
        END IF; --  Header Record ends


              -- Revisions: Convert from RECORD type to OBJECT type

              IF x_bomrevisions_tbl IS NULL
              THEN
                x_bomrevisions_tbl := BOMRevisionsTable(null);
              END IF;

              l_prevcount := x_bomrevisions_tbl.COUNT;

              IF l_bom_revision_tbl.COUNT <> 0 THEN

                i := l_prevcount;

                FOR revRec IN 1..l_bom_revision_tbl.COUNT
                LOOP

                      i := i + 1;

          x_bomrevisions_tbl(i).Organization_Code     :=
          l_bom_revision_tbl(revRec).Organization_Code ;
          x_bomrevisions_tbl(i).Assembly_Item_Name     :=
          l_bom_revision_tbl(revRec).Assembly_Item_Name ;
          x_bomrevisions_tbl(i).Alternate_BOM_Code   :=
          l_bom_revision_tbl(revRec).Alternate_BOM_Code;
          x_bomrevisions_tbl(i).Revision  :=
          l_bom_revision_tbl(revRec).Revision;
          x_bomrevisions_tbl(i).Start_Effective_Date  :=
          l_bom_revision_tbl(revRec).Start_Effective_Date;
          x_bomrevisions_tbl(i).Description  :=
          l_bom_revision_tbl(revRec).Description;
          x_bomrevisions_tbl(i).Attribute_category     :=
          l_bom_revision_tbl(revRec).Attribute_category;
          x_bomrevisions_tbl(i).Attribute1  :=
          l_bom_revision_tbl(revRec).Attribute1;
          x_bomrevisions_tbl(i).Attribute2  :=
          l_bom_revision_tbl(revRec).Attribute2;
          x_bomrevisions_tbl(i).Attribute3  :=
          l_bom_revision_tbl(revRec).Attribute3;
          x_bomrevisions_tbl(i).Attribute4  :=
          l_bom_revision_tbl(revRec).Attribute4;
          x_bomrevisions_tbl(i).Attribute5  :=
          l_bom_revision_tbl(revRec).Attribute5;
          x_bomrevisions_tbl(i).Attribute6  :=
          l_bom_revision_tbl(revRec).Attribute6;
          x_bomrevisions_tbl(i).Attribute7  :=
          l_bom_revision_tbl(revRec).Attribute7;
          x_bomrevisions_tbl(i).Attribute8  :=
          l_bom_revision_tbl(revRec).Attribute8;
          x_bomrevisions_tbl(i).Attribute9  :=
          l_bom_revision_tbl(revRec).Attribute9;
          x_bomrevisions_tbl(i).Attribute10 :=
          l_bom_revision_tbl(revRec).Attribute10;
          x_bomrevisions_tbl(i).Attribute11 :=
          l_bom_revision_tbl(revRec).Attribute11;
          x_bomrevisions_tbl(i).Attribute12 :=
          l_bom_revision_tbl(revRec).Attribute12;
          x_bomrevisions_tbl(i).Attribute13 :=
          l_bom_revision_tbl(revRec).Attribute13;
          x_bomrevisions_tbl(i).Attribute14 :=
          l_bom_revision_tbl(revRec).Attribute14;
          x_bomrevisions_tbl(i).Attribute15 :=
          l_bom_revision_tbl(revRec).Attribute15;
          x_bomrevisions_tbl(i).Return_Status     :=
          l_bom_revision_tbl(revRec).Return_Status;
          x_bomrevisions_tbl(i).Transaction_Type     :=
          l_bom_revision_tbl(revRec).Transaction_Type;
          x_bomrevisions_tbl(i).Original_System_Reference     :=
          l_bom_revision_tbl(revRec).Original_System_Reference;

                END LOOP;
        END IF; -- Revision Record ends


        -- Components: Convert from RECORD type to OBJECT type


        IF x_bomcomponents_tbl IS NULL
        THEN
          x_bomcomponents_tbl := BOMComponentsTable(null);
        END IF;


        l_pcompcount := x_bomcomponents_tbl.COUNT;


        IF l_bom_component_tbl.COUNT <> 0 THEN

    i := l_pcompcount;

          FOR compRec IN 1..l_bom_component_tbl.COUNT
          LOOP

          i := i + 1;

          x_bomcomponents_tbl(i).Organization_Code     :=
          l_bom_component_tbl(compRec).Organization_Code ;
          x_bomcomponents_tbl(i).Assembly_Item_Name     :=
          l_bom_component_tbl(compRec).Assembly_Item_Name ;
          x_bomcomponents_tbl(i).Start_Effective_Date  :=
          l_bom_component_tbl(compRec).Start_Effective_Date;
          x_bomcomponents_tbl(i).Disable_Date     :=
          l_bom_component_tbl(compRec).Disable_Date;
          x_bomcomponents_tbl(i).Operation_Sequence_Number    :=
          l_bom_component_tbl(compRec).Operation_Sequence_Number;
          x_bomcomponents_tbl(i).Component_Item_Name   :=
          l_bom_component_tbl(compRec).Component_Item_Name;
          x_bomcomponents_tbl(i).Alternate_BOM_Code   :=
          l_bom_component_tbl(compRec).Alternate_BOM_Code;
          x_bomcomponents_tbl(i).New_Effectivity_Date  :=
          l_bom_component_tbl(compRec).New_Effectivity_Date;
          x_bomcomponents_tbl(i).New_Operation_Sequence_Number   :=
          l_bom_component_tbl(compRec).New_Operation_Sequence_Number;
          x_bomcomponents_tbl(i).Item_Sequence_Number   :=
          l_bom_component_tbl(compRec).Item_Sequence_Number;
          x_bomcomponents_tbl(i).Basis_Type:=
          l_bom_component_tbl(compRec).Basis_Type;
          x_bomcomponents_tbl(i).Quantity_Per_Assembly  :=
          l_bom_component_tbl(compRec).Quantity_Per_Assembly;
          x_bomcomponents_tbl(i).Inverse_Quantity  :=
          l_bom_component_tbl(compRec).Inverse_Quantity;
          x_bomcomponents_tbl(i).Planning_Percent  :=
          l_bom_component_tbl(compRec).Planning_Percent;
          x_bomcomponents_tbl(i).Projected_Yield     :=
          l_bom_component_tbl(compRec).Projected_Yield;
          x_bomcomponents_tbl(i).Include_In_Cost_Rollup :=
          l_bom_component_tbl(compRec).Include_In_Cost_Rollup;
          x_bomcomponents_tbl(i).Wip_Supply_Type     :=
          l_bom_component_tbl(compRec).Wip_Supply_Type;
          x_bomcomponents_tbl(i).So_Basis     :=
          l_bom_component_tbl(compRec).So_Basis;
          x_bomcomponents_tbl(i).Optional     :=
          l_bom_component_tbl(compRec).Optional;
          x_bomcomponents_tbl(i).Mutually_Exclusive     :=
          l_bom_component_tbl(compRec).Mutually_Exclusive;
          x_bomcomponents_tbl(i).Check_Atp     :=
          l_bom_component_tbl(compRec).Check_Atp;
          x_bomcomponents_tbl(i).Shipping_Allowed     :=
          l_bom_component_tbl(compRec).Shipping_Allowed;
          x_bomcomponents_tbl(i).Required_To_Ship     :=
          l_bom_component_tbl(compRec).Required_To_Ship;
          x_bomcomponents_tbl(i).Required_For_Revenue  :=
          l_bom_component_tbl(compRec).Required_For_Revenue;
          x_bomcomponents_tbl(i).Include_On_Ship_Docs  :=
          l_bom_component_tbl(compRec).Include_On_Ship_Docs;
          x_bomcomponents_tbl(i).Quantity_Related     :=
          l_bom_component_tbl(compRec).Quantity_Related;
          x_bomcomponents_tbl(i).Supply_Subinventory   :=
          l_bom_component_tbl(compRec).Supply_Subinventory;
          x_bomcomponents_tbl(i).Location_Name     :=
          l_bom_component_tbl(compRec).Location_Name;
          x_bomcomponents_tbl(i).Minimum_Allowed_Quantity :=
          l_bom_component_tbl(compRec).Minimum_Allowed_Quantity;
          x_bomcomponents_tbl(i).Maximum_Allowed_Quantity     :=
          l_bom_component_tbl(compRec).Maximum_Allowed_Quantity;
          x_bomcomponents_tbl(i).Comments     :=
          l_bom_component_tbl(compRec).Comments;
          x_bomcomponents_tbl(i).Attribute_category     :=
          l_bom_component_tbl(compRec).Attribute_category;
          x_bomcomponents_tbl(i).Attribute1  :=
          l_bom_component_tbl(compRec).Attribute1;
          x_bomcomponents_tbl(i).Attribute2  :=
          l_bom_component_tbl(compRec).Attribute2;
          x_bomcomponents_tbl(i).Attribute3  :=
          l_bom_component_tbl(compRec).Attribute3;
          x_bomcomponents_tbl(i).Attribute4  :=
          l_bom_component_tbl(compRec).Attribute4;
          x_bomcomponents_tbl(i).Attribute5  :=
          l_bom_component_tbl(compRec).Attribute5;
          x_bomcomponents_tbl(i).Attribute6  :=
          l_bom_component_tbl(compRec).Attribute6;
          x_bomcomponents_tbl(i).Attribute7  :=
          l_bom_component_tbl(compRec).Attribute7;
          x_bomcomponents_tbl(i).Attribute8  :=
          l_bom_component_tbl(compRec).Attribute8;
          x_bomcomponents_tbl(i).Attribute9  :=
          l_bom_component_tbl(compRec).Attribute9;
          x_bomcomponents_tbl(i).Attribute10 :=
          l_bom_component_tbl(compRec).Attribute10;
          x_bomcomponents_tbl(i).Attribute11 :=
          l_bom_component_tbl(compRec).Attribute11;
          x_bomcomponents_tbl(i).Attribute12 :=
          l_bom_component_tbl(compRec).Attribute12;
          x_bomcomponents_tbl(i).Attribute13 :=
          l_bom_component_tbl(compRec).Attribute13;
          x_bomcomponents_tbl(i).Attribute14 :=
          l_bom_component_tbl(compRec).Attribute14;
          x_bomcomponents_tbl(i).Attribute15 :=
          l_bom_component_tbl(compRec).Attribute15;
          x_bomcomponents_tbl(i).From_End_Item_Unit_Number    :=
          l_bom_component_tbl(compRec).From_End_Item_Unit_Number;
          x_bomcomponents_tbl(i).New_From_End_Item_Unit_Number    :=
          l_bom_component_tbl(compRec).New_From_End_Item_Unit_Number;
          x_bomcomponents_tbl(i).To_End_Item_Unit_Number     :=
          l_bom_component_tbl(compRec).To_End_Item_Unit_Number;
          x_bomcomponents_tbl(i).Return_Status     :=
          l_bom_component_tbl(compRec).Return_Status;
          x_bomcomponents_tbl(i).Transaction_Type     :=
          l_bom_component_tbl(compRec).Transaction_Type;
          x_bomcomponents_tbl(i).Original_System_Reference     :=
          l_bom_component_tbl(compRec).Original_System_Reference;
          x_bomcomponents_tbl(i).Delete_Group_Name     :=
          l_bom_component_tbl(compRec).Delete_Group_Name;
          x_bomcomponents_tbl(i).DG_Description     :=
          l_bom_component_tbl(compRec).DG_Description;
          x_bomcomponents_tbl(i).Enforce_Int_Requirements    :=
          l_bom_component_tbl(compRec).Enforce_Int_Requirements;
          END LOOP;
        END IF; -- Components

        i := 0;

              -- Substitute Components: Convert from RECORD type to OBJECT type

              IF x_bomsubcomponents_tbl IS NULL
              THEN
                x_bomsubcomponents_tbl := BOMSubComponentsTable(null);
              END IF;


              l_psubcompcount := x_bomsubcomponents_tbl.COUNT;


              IF l_bom_sub_component_tbl.COUNT <> 0 THEN

                i := l_psubcompcount;

                FOR scompRec IN 1..l_bom_sub_component_tbl.COUNT
                LOOP

                      i := i + 1;

          x_bomsubcomponents_tbl(i).Organization_Code     :=
          l_bom_sub_component_tbl(scompRec).Organization_Code ;
          x_bomsubcomponents_tbl(i).Assembly_Item_Name     :=
          l_bom_sub_component_tbl(scompRec).Assembly_Item_Name ;
          x_bomsubcomponents_tbl(i).Start_Effective_Date  :=
          l_bom_sub_component_tbl(scompRec).Start_Effective_Date;
          x_bomsubcomponents_tbl(i).Operation_Sequence_Number    :=
          l_bom_sub_component_tbl(scompRec).Operation_Sequence_Number;
          x_bomsubcomponents_tbl(i).Component_Item_Name   :=
          l_bom_sub_component_tbl(scompRec).Component_Item_Name;
          x_bomsubcomponents_tbl(i).Alternate_BOM_Code   :=
          l_bom_sub_component_tbl(scompRec).Alternate_BOM_Code;
          x_bomsubcomponents_tbl(i).Substitute_Component_Name   :=
          l_bom_sub_component_tbl(scompRec).Substitute_Component_Name;
          x_bomsubcomponents_tbl(i).Substitute_Item_Quantity  :=
          l_bom_sub_component_tbl(scompRec).Substitute_Item_Quantity;
          x_bomsubcomponents_tbl(i).Attribute_category     :=
          l_bom_sub_component_tbl(scompRec).Attribute_category;
          x_bomsubcomponents_tbl(i).Attribute1  :=
          l_bom_sub_component_tbl(scompRec).Attribute1;
          x_bomsubcomponents_tbl(i).Attribute2  :=
          l_bom_sub_component_tbl(scompRec).Attribute2;
          x_bomsubcomponents_tbl(i).Attribute3  :=
          l_bom_sub_component_tbl(scompRec).Attribute3;
          x_bomsubcomponents_tbl(i).Attribute4  :=
          l_bom_sub_component_tbl(scompRec).Attribute4;
          x_bomsubcomponents_tbl(i).Attribute5  :=
          l_bom_sub_component_tbl(scompRec).Attribute5;
          x_bomsubcomponents_tbl(i).Attribute6  :=
          l_bom_sub_component_tbl(scompRec).Attribute6;
          x_bomsubcomponents_tbl(i).Attribute7  :=
          l_bom_sub_component_tbl(scompRec).Attribute7;
          x_bomsubcomponents_tbl(i).Attribute8  :=
          l_bom_sub_component_tbl(scompRec).Attribute8;
          x_bomsubcomponents_tbl(i).Attribute9  :=
          l_bom_sub_component_tbl(scompRec).Attribute9;
          x_bomsubcomponents_tbl(i).Attribute10 :=
          l_bom_sub_component_tbl(scompRec).Attribute10;
          x_bomsubcomponents_tbl(i).Attribute11 :=
          l_bom_sub_component_tbl(scompRec).Attribute11;
          x_bomsubcomponents_tbl(i).Attribute12 :=
          l_bom_sub_component_tbl(scompRec).Attribute12;
          x_bomsubcomponents_tbl(i).Attribute13 :=
          l_bom_sub_component_tbl(scompRec).Attribute13;
          x_bomsubcomponents_tbl(i).Attribute14 :=
          l_bom_sub_component_tbl(scompRec).Attribute14;
          x_bomsubcomponents_tbl(i).Attribute15 :=
          l_bom_sub_component_tbl(scompRec).Attribute15;
          x_bomsubcomponents_tbl(i).From_End_Item_Unit_Number    :=
          l_bom_sub_component_tbl(scompRec).From_End_Item_Unit_Number;
          x_bomsubcomponents_tbl(i).Return_Status     :=
          l_bom_sub_component_tbl(scompRec).Return_Status;
          x_bomsubcomponents_tbl(i).Transaction_Type     :=
          l_bom_sub_component_tbl(scompRec).Transaction_Type;
          x_bomsubcomponents_tbl(i).Original_System_Reference     :=
          l_bom_sub_component_tbl(scompRec).Original_System_Reference;
          x_bomsubcomponents_tbl(i).Enforce_Int_Requirements    :=
          l_bom_sub_component_tbl(scompRec).Enforce_Int_Requirements;
                END LOOP;

              END IF; -- Substitute Components

        i := 0;

              -- Reference Designators: Convert from RECORD type to OBJECT type

              IF x_bomrefdesignators_tbl IS NULL
              THEN
                x_bomrefdesignators_tbl := BOMRefDesignatorsTable(null);
              END IF;


              l_prefdescount := x_bomrefdesignators_tbl.COUNT;


              IF l_bom_ref_designator_tbl.COUNT <> 0 THEN

                i := l_prefdescount;

                FOR rdesRec IN 1..l_bom_ref_designator_tbl.COUNT
                LOOP

                      i := i + 1;

          x_bomrefdesignators_tbl(i).Organization_Code     :=
          l_bom_ref_designator_tbl(rdesRec).Organization_Code ;
          x_bomrefdesignators_tbl(i).Assembly_Item_Name     :=
          l_bom_ref_designator_tbl(rdesRec).Assembly_Item_Name ;
          x_bomrefdesignators_tbl(i).Start_Effective_Date  :=
          l_bom_ref_designator_tbl(rdesRec).Start_Effective_Date;
          x_bomrefdesignators_tbl(i).Operation_Sequence_Number    :=
          l_bom_ref_designator_tbl(rdesRec).Operation_Sequence_Number;
          x_bomrefdesignators_tbl(i).Component_Item_Name   :=
          l_bom_ref_designator_tbl(rdesRec).Component_Item_Name;
          x_bomrefdesignators_tbl(i).Alternate_BOM_Code   :=
          l_bom_ref_designator_tbl(rdesRec).Alternate_BOM_Code;
          x_bomrefdesignators_tbl(i).Reference_Designator_Name   :=
          l_bom_ref_designator_tbl(rdesRec).Reference_Designator_Name;
          x_bomrefdesignators_tbl(i).Ref_Designator_Comment  :=
          l_bom_ref_designator_tbl(rdesRec).Ref_Designator_Comment;
          x_bomrefdesignators_tbl(i).Attribute_category     :=
          l_bom_ref_designator_tbl(rdesRec).Attribute_category;
          x_bomrefdesignators_tbl(i).Attribute1  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute1;
          x_bomrefdesignators_tbl(i).Attribute2  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute2;
          x_bomrefdesignators_tbl(i).Attribute3  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute3;
          x_bomrefdesignators_tbl(i).Attribute4  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute4;
          x_bomrefdesignators_tbl(i).Attribute5  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute5;
          x_bomrefdesignators_tbl(i).Attribute6  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute6;
          x_bomrefdesignators_tbl(i).Attribute7  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute7;
          x_bomrefdesignators_tbl(i).Attribute8  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute8;
          x_bomrefdesignators_tbl(i).Attribute9  :=
          l_bom_ref_designator_tbl(rdesRec).Attribute9;
          x_bomrefdesignators_tbl(i).Attribute10 :=
          l_bom_ref_designator_tbl(rdesRec).Attribute10;
          x_bomrefdesignators_tbl(i).Attribute11 :=
          l_bom_ref_designator_tbl(rdesRec).Attribute11;
          x_bomrefdesignators_tbl(i).Attribute12 :=
          l_bom_ref_designator_tbl(rdesRec).Attribute12;
          x_bomrefdesignators_tbl(i).Attribute13 :=
          l_bom_ref_designator_tbl(rdesRec).Attribute13;
          x_bomrefdesignators_tbl(i).Attribute14 :=
          l_bom_ref_designator_tbl(rdesRec).Attribute14;
          x_bomrefdesignators_tbl(i).Attribute15 :=
          l_bom_ref_designator_tbl(rdesRec).Attribute15;
          x_bomrefdesignators_tbl(i).From_End_Item_Unit_Number    :=
          l_bom_ref_designator_tbl(rdesRec).From_End_Item_Unit_Number;
          x_bomrefdesignators_tbl(i).New_Reference_Designator    :=
          l_bom_ref_designator_tbl(rdesRec).New_Reference_Designator;
          x_bomrefdesignators_tbl(i).Return_Status     :=
          l_bom_ref_designator_tbl(rdesRec).Return_Status;
          x_bomrefdesignators_tbl(i).Transaction_Type     :=
          l_bom_ref_designator_tbl(rdesRec).Transaction_Type;
          x_bomrefdesignators_tbl(i).Original_System_Reference     :=
          l_bom_ref_designator_tbl(rdesRec).Original_System_Reference;
                END LOOP;
        END IF; -- Ref Designators

              i := 0;

              -- Component Operations: Convert from RECORD type to OBJECT type

              IF x_bomcompoperations_tbl IS NULL
              THEN
                x_bomcompoperations_tbl := BOMCompOperationsTable(null);
              END IF;


              l_pcompopscount := x_bomcompoperations_tbl.COUNT;


              IF l_bom_comp_ops_tbl.COUNT <> 0 THEN

                i := l_pcompopscount;

                FOR copsRec IN 1..l_bom_comp_ops_tbl.COUNT
                LOOP

                      i := i + 1;

          x_bomcompoperations_tbl(i).Organization_Code     :=
          l_bom_comp_ops_tbl(copsRec).Organization_Code ;
          x_bomcompoperations_tbl(i).Assembly_Item_Name     :=
          l_bom_comp_ops_tbl(copsRec).Assembly_Item_Name ;
          x_bomcompoperations_tbl(i).Start_Effective_Date  :=
          l_bom_comp_ops_tbl(copsRec).Start_Effective_Date;
          x_bomcompoperations_tbl(i).From_End_Item_Unit_Number    :=
          l_bom_comp_ops_tbl(copsRec).From_End_Item_Unit_Number;
          x_bomcompoperations_tbl(i).To_End_Item_Unit_Number    :=
          l_bom_comp_ops_tbl(copsRec).To_End_Item_Unit_Number;
          x_bomcompoperations_tbl(i).Operation_Sequence_Number    :=
          l_bom_comp_ops_tbl(copsRec).Operation_Sequence_Number;
          x_bomcompoperations_tbl(i).Component_Item_Name   :=
          l_bom_comp_ops_tbl(copsRec).Component_Item_Name;
          x_bomcompoperations_tbl(i).Additional_Operation_Seq_Num    :=
          l_bom_comp_ops_tbl(copsRec).Additional_Operation_Seq_Num;
          x_bomcompoperations_tbl(i).Alternate_BOM_Code   :=
          l_bom_comp_ops_tbl(copsRec).Alternate_BOM_Code;
          x_bomcompoperations_tbl(i).Attribute_category     :=
          l_bom_comp_ops_tbl(copsRec).Attribute_category;
          x_bomcompoperations_tbl(i).Attribute1  :=
          l_bom_comp_ops_tbl(copsRec).Attribute1;
          x_bomcompoperations_tbl(i).Attribute2  :=
          l_bom_comp_ops_tbl(copsRec).Attribute2;
          x_bomcompoperations_tbl(i).Attribute3  :=
          l_bom_comp_ops_tbl(copsRec).Attribute3;
          x_bomcompoperations_tbl(i).Attribute4  :=
          l_bom_comp_ops_tbl(copsRec).Attribute4;
          x_bomcompoperations_tbl(i).Attribute5  :=
          l_bom_comp_ops_tbl(copsRec).Attribute5;
          x_bomcompoperations_tbl(i).Attribute6  :=
          l_bom_comp_ops_tbl(copsRec).Attribute6;
          x_bomcompoperations_tbl(i).Attribute7  :=
          l_bom_comp_ops_tbl(copsRec).Attribute7;
          x_bomcompoperations_tbl(i).Attribute8  :=
          l_bom_comp_ops_tbl(copsRec).Attribute8;
          x_bomcompoperations_tbl(i).Attribute9  :=
          l_bom_comp_ops_tbl(copsRec).Attribute9;
          x_bomcompoperations_tbl(i).Attribute10 :=
          l_bom_comp_ops_tbl(copsRec).Attribute10;
          x_bomcompoperations_tbl(i).Attribute11 :=
          l_bom_comp_ops_tbl(copsRec).Attribute11;
          x_bomcompoperations_tbl(i).Attribute12 :=
          l_bom_comp_ops_tbl(copsRec).Attribute12;
          x_bomcompoperations_tbl(i).Attribute13 :=
          l_bom_comp_ops_tbl(copsRec).Attribute13;
          x_bomcompoperations_tbl(i).Attribute14 :=
          l_bom_comp_ops_tbl(copsRec).Attribute14;
          x_bomcompoperations_tbl(i).Attribute15 :=
          l_bom_comp_ops_tbl(copsRec).Attribute15;
          x_bomcompoperations_tbl(i).Return_Status     :=
          l_bom_comp_ops_tbl(copsRec).Return_Status;
          x_bomcompoperations_tbl(i).Transaction_Type     :=
          l_bom_comp_ops_tbl(copsRec).Transaction_Type;

                END LOOP;

        END IF; -- Component Operations

      END LOOP; -- End of WHILE Loop

      -- Assign the OUT variables

      x_bo_return_status        := l_bo_return_status;
      x_bo_msg_count            := l_msg_count;

      x_process_return_status   := 'S';
      x_process_error_msg       := '';

      EXCEPTION WHEN OTHERS
      THEN
        x_process_return_status := 'U';
              x_process_error_msg := 'Unexpected Error in Process_EBOM : ' ||to_char(SQLCODE)||' / '||SQLERRM;

  END; -- Process BOM for multiple BOMS

  */


  /********************************************************************
  * Procedure : Process_Bom (for iSetup)
  * Parameters IN : Bom Header exposed column table
  *     Bom Item Revision Exposed Column Table
  *     Bom Inventorty Component exposed column table
  *     Substitute Component Exposed Column table
  *     Reference Designator Exposed column table
  *     Component Operations Exposed column table
  * Parameters OUT: Bom Header Exposed Column Table
  *     Bom Inventory Components exposed column table
  *     Bom Item Revision Exposed Column Table
        *                 Substitute Component Exposed Column table
        *                 Reference Designator Exposed column table
  *     Component Operations Exposed column table
  * Purpose : This procedure is a wrapper on existing Process_BOM
        *                 procedure. This new procedure accepts a table of Bom
  *     headers and calls the existing Process_BOM for each
  *     record. This is to support the new Export_BOM that
        *                 returns a table of Bom Header records.
  *********************************************************************/
  PROCEDURE Process_Bom
  (  P_bo_identifier           IN  VARCHAR2 := 'BOM'
   , P_api_version_number      IN  NUMBER := 1.0
   , P_init_msg_list           IN  BOOLEAN := FALSE
   , P_bom_header_tbl          IN  Bom_Bo_Pub.Bom_Header_tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_HEADER_TBL
   , P_bom_revision_tbl      IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
   , P_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
   , P_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type
            := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
   , P_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
            := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
     , P_bom_comp_ops_tbl        IN Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type :=
                                       Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
   , X_bom_header_tbl      IN OUT NOCOPY Bom_Bo_Pub.bom_Header_Tbl_Type
   , X_bom_revision_tbl      IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
   , X_bom_component_tbl       IN OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
   , X_bom_ref_designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
   , X_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
   , X_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
   , X_return_status           IN OUT NOCOPY VARCHAR2
   , X_msg_count               IN OUT NOCOPY NUMBER
         , P_debug                   IN  VARCHAR2 := 'N'
         , P_output_dir              IN  VARCHAR2 := NULL
         , P_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
   )
        IS
          l_bom_header_rec             BOM_BO_PUB.Bom_Head_Rec_Type;
          l_bom_revision_tbl           BOM_BO_PUB.Bom_Revision_Tbl_Type;
          l_bom_component_tbl          BOM_BO_PUB.Bom_Comps_Tbl_Type;
          l_bom_ref_designator_tbl     BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
          l_bom_sub_component_tbl      BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
          l_bom_comp_ops_tbl           BOM_BO_PUB.Bom_Comp_ops_Tbl_Type;
          l_bom_header_rec_out         BOM_BO_PUB.Bom_Head_Rec_Type;
          l_bom_revision_tbl_out       BOM_BO_PUB.Bom_Revision_Tbl_Type;
          l_bom_component_tbl_out      BOM_BO_PUB.Bom_Comps_Tbl_Type;
          l_bom_ref_designator_tbl_out BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
          l_bom_sub_component_tbl_out  BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
          l_bom_comp_ops_tbl_out       BOM_BO_PUB.Bom_Comp_ops_Tbl_Type;
          k NUMBER;
          l NUMBER;
          o NUMBER;
          q NUMBER;
          r NUMBER;
          l_cnt NUMBER;
          no_header_record EXCEPTION;
          l_other_message  VARCHAR2(50);
        BEGIN
/*
          IF (P_bom_header_tbl IS NULL) THEN
            l_other_message := 'BOM_NO_HEADER_RECORD';
            RAISE no_header_record;
          END IF;
*/
        IF (P_bom_header_tbl.COUNT <= 0 AND
            P_bom_revision_tbl.COUNT <= 0) THEN
            l_other_message := 'BOM_NO_HEADER_RECORD';
            RAISE no_header_record;
        ELSIF (P_bom_header_tbl.COUNT <= 0) THEN
--Call to existing Process_BOM that accepts only one record of Bom_Headers per call
            Process_Bom(P_bo_identifier          => p_bo_identifier,
                        P_api_version_number     => p_api_version_number,
                        P_init_msg_list          => p_init_msg_list,
                        P_bom_header_rec         => l_bom_header_rec,
                        P_bom_revision_tbl       => P_bom_revision_tbl,
                        P_bom_component_tbl      => l_bom_component_tbl,
                        P_bom_ref_designator_tbl => l_bom_ref_designator_tbl,
                        P_bom_sub_component_tbl  => l_bom_sub_component_tbl,
                        P_bom_comp_ops_tbl       => l_bom_comp_ops_tbl,
                        X_bom_header_rec         => l_bom_header_rec_out,
                        X_bom_revision_tbl       => l_bom_revision_tbl_out,
                        X_bom_component_tbl      => l_bom_component_tbl_out,
                        X_bom_ref_designator_tbl => l_bom_ref_designator_tbl_out,
                        X_bom_sub_component_tbl  => l_bom_sub_component_tbl_out,
                        X_bom_comp_ops_tbl       => l_bom_comp_ops_tbl_out,
                        X_return_status          => X_return_status,
                        X_msg_count              => X_msg_count,
                        P_debug                  => P_debug,
                        P_output_dir             => P_output_dir,
                        P_debug_filename         => P_debug_filename);
        ELSE
          FOR i IN P_bom_header_tbl.FIRST..P_bom_header_tbl.LAST LOOP
            l_bom_header_rec := P_bom_header_tbl(i);
            l_bom_revision_tbl.DELETE;
            k := 1;
            IF (P_bom_revision_tbl.COUNT > 0) THEN
              FOR j IN P_bom_revision_tbl.FIRST..P_bom_revision_tbl.LAST LOOP
                IF (P_bom_revision_tbl(j).organization_code  = P_bom_header_tbl(i).organization_code AND
                    P_bom_revision_tbl(j).assembly_item_name = P_bom_header_tbl(i).assembly_item_name AND
                    NVL(P_bom_revision_tbl(k).alternate_bom_code, '##$$##') = NVL(P_bom_header_tbl(i).alternate_bom_code,'##$$##')) THEN
                  l_bom_revision_tbl(k) := P_bom_revision_tbl(j);
                  k := k + 1;
                END IF;
              END LOOP;
            END IF;
            l_bom_component_tbl.DELETE;
            l_bom_ref_designator_tbl.DELETE;
            l_bom_sub_component_tbl.DELETE;
            l_bom_comp_ops_tbl.DELETE;
            l := 1;
            o := 1;
            q := 1;
            r := 1;
            IF (P_bom_component_tbl.COUNT > 0) THEN
              FOR m IN P_bom_component_tbl.FIRST..P_bom_component_tbl.LAST LOOP
                IF (P_bom_component_tbl(m).organization_code = P_bom_header_tbl(i).organization_code AND
                    P_bom_component_tbl(m).assembly_item_name = P_bom_header_tbl(i).assembly_item_name AND
                    NVL(P_bom_component_tbl(m).alternate_bom_code, '##$$##') = NVL(P_bom_header_tbl(i).alternate_bom_code,'##$$##')) THEN
                  l_bom_component_tbl(l) := P_bom_component_tbl(m);
                  l := l + 1;
                END IF;
              END LOOP;
            END IF;
            IF (P_bom_ref_designator_tbl.COUNT > 0) THEN
              FOR a IN P_bom_ref_designator_tbl.FIRST..P_bom_ref_designator_tbl.LAST LOOP
                IF (P_bom_ref_designator_tbl(a).organization_code         = P_bom_header_tbl(i).organization_code AND
                    P_bom_ref_designator_tbl(a).assembly_item_name        = P_bom_header_tbl(i).assembly_item_name AND
                    NVL(P_bom_ref_designator_tbl(a).alternate_bom_code, '##$$##') = NVL(P_bom_header_tbl(i).alternate_bom_code,'##$$##'))  THEN
                  l_bom_ref_designator_tbl(o) := P_bom_ref_designator_tbl(a);
                  o := o + 1;
                END IF;
              END LOOP;
            END IF;
            IF (P_bom_sub_component_tbl.COUNT > 0) THEN
              FOR a IN P_bom_sub_component_tbl.FIRST..P_bom_sub_component_tbl.LAST LOOP
                IF (P_bom_sub_component_tbl(a).organization_code         = P_bom_header_tbl(i).organization_code AND
                    P_bom_sub_component_tbl(a).assembly_item_name        = P_bom_header_tbl(i).assembly_item_name AND
                    NVL(P_bom_sub_component_tbl(a).alternate_bom_code, '##$$##') = NVL(P_bom_header_tbl(i).alternate_bom_code,'##$$##')) THEN
                  l_bom_sub_component_tbl(q) := P_bom_sub_component_tbl(a);
                  q := q + 1;
                END IF;
              END LOOP;
            END IF;
            IF (P_bom_comp_ops_tbl.COUNT > 0) THEN
              FOR a IN P_bom_comp_ops_tbl.FIRST..P_bom_comp_ops_tbl.LAST LOOP
                IF (P_bom_comp_ops_tbl(a).organization_code         = P_bom_header_tbl(i).organization_code AND
                    P_bom_comp_ops_tbl(a).assembly_item_name        = P_bom_header_tbl(i).assembly_item_name AND
                    NVL(P_bom_comp_ops_tbl(a).alternate_bom_code, '##$$##') = NVL(P_bom_header_tbl(i).alternate_bom_code,'##$$##')) THEN
                  l_bom_comp_ops_tbl(r) := P_bom_comp_ops_tbl(a);
                  r := r + 1;
                END IF;
              END LOOP;
            END IF;
--Call to existing Process_BOM that accepts only one record of Bom_Headers per call
            Process_Bom(P_bo_identifier          => p_bo_identifier,
                        P_api_version_number     => p_api_version_number,
                        P_init_msg_list          => p_init_msg_list,
                        P_bom_header_rec         => l_bom_header_rec,
                        P_bom_revision_tbl       => l_bom_revision_tbl,
                        P_bom_component_tbl      => l_bom_component_tbl,
                        P_bom_ref_designator_tbl => l_bom_ref_designator_tbl,
                        P_bom_sub_component_tbl  => l_bom_sub_component_tbl,
                        P_bom_comp_ops_tbl       => l_bom_comp_ops_tbl,
                        X_bom_header_rec         => l_bom_header_rec_out,
                        X_bom_revision_tbl       => l_bom_revision_tbl_out,
                        X_bom_component_tbl      => l_bom_component_tbl_out,
                        X_bom_ref_designator_tbl => l_bom_ref_designator_tbl_out,
                        X_bom_sub_component_tbl  => l_bom_sub_component_tbl_out,
                        X_bom_comp_ops_tbl       => l_bom_comp_ops_tbl_out,
                        X_return_status          => X_return_status,
                        X_msg_count              => X_msg_count,
                        P_debug                  => P_debug,
                        P_output_dir             => P_output_dir,
                        P_debug_filename         => P_debug_filename);
            IF (X_return_status = 'S') THEN
              l_cnt := NULL;
              l_cnt := X_bom_header_tbl.LAST + 1;
              IF (l_cnt IS NULL) THEN
                l_cnt := 1;
              END IF;
              X_bom_header_tbl(l_cnt) := l_bom_header_rec_out;

              l_cnt := NULL;
              l_cnt := X_bom_revision_tbl.LAST + 1;
              IF (l_cnt IS NULL) THEN
                l_cnt := 1;
              END IF;
              IF (l_bom_revision_tbl_out.COUNT > 0) THEN
                FOR a IN l_bom_revision_tbl_out.FIRST..l_bom_revision_tbl_out.LAST LOOP
                  X_bom_revision_tbl(l_cnt) := l_bom_revision_tbl_out(a);
                  l_cnt := l_cnt + 1;
                END LOOP;
              END IF;

              l_cnt := NULL;
              l_cnt := X_bom_component_tbl.LAST + 1;
              IF (l_cnt IS NULL) THEN
                l_cnt := 1;
              END IF;
              IF (l_bom_component_tbl_out.COUNT > 0) THEN
                FOR a IN l_bom_component_tbl_out.FIRST..l_bom_component_tbl_out.LAST LOOP
                  X_bom_component_tbl(l_cnt) := l_bom_component_tbl_out(a);
                  l_cnt := l_cnt + 1;
                END LOOP;
              END IF;

              l_cnt := NULL;
              l_cnt := X_bom_ref_designator_tbl.LAST + 1;
              IF (l_cnt IS NULL) THEN
                l_cnt := 1;
              END IF;
              IF (l_bom_ref_designator_tbl_out.COUNT > 0) THEN
                FOR a IN l_bom_ref_designator_tbl_out.FIRST..l_bom_ref_designator_tbl_out.LAST LOOP
                  X_bom_ref_designator_tbl(l_cnt) := l_bom_ref_designator_tbl_out(a);
                  l_cnt := l_cnt + 1;
                END LOOP;
              END IF;

              l_cnt := NULL;
              l_cnt := X_bom_sub_component_tbl.LAST + 1;
              IF (l_cnt IS NULL) THEN
                l_cnt := 1;
              END IF;
              IF (l_bom_sub_component_tbl_out.COUNT > 0) THEN
                FOR a IN l_bom_sub_component_tbl_out.FIRST..l_bom_sub_component_tbl_out.LAST LOOP
                  X_bom_sub_component_tbl(l_cnt) := l_bom_sub_component_tbl_out(a);
                  l_cnt := l_cnt + 1;
                END LOOP;
              END IF;

              l_cnt := NULL;
              l_cnt := X_bom_comp_ops_tbl.LAST + 1;
              IF (l_cnt IS NULL) THEN
                l_cnt := 1;
              END IF;
              IF (l_bom_comp_ops_tbl_out.COUNT > 0) THEN
                FOR a IN l_bom_comp_ops_tbl_out.FIRST..l_bom_comp_ops_tbl_out.LAST LOOP
                  X_bom_comp_ops_tbl(l_cnt) := l_bom_comp_ops_tbl_out(a);
                  l_cnt := l_cnt + 1;
                END LOOP;
              END IF;
            END IF;
          END LOOP;
        END IF;
          EXCEPTION
            WHEN no_header_record THEN
              Error_Handler.Log_Error
                (P_error_status           => Error_Handler.G_STATUS_ERROR,
                 P_error_scope            => Error_Handler.G_SCOPE_ALL,
                 P_error_level            => Error_Handler.G_BO_LEVEL,
                 P_other_message          => l_other_message,
                 P_other_status           => Error_Handler.G_STATUS_ERROR,
                 X_bom_header_rec         => l_bom_header_rec,
                 X_bom_revision_tbl       => l_bom_revision_tbl,
                 X_bom_component_tbl      => l_bom_component_tbl,
                 X_bom_ref_designator_tbl => l_bom_ref_designator_tbl,
                 X_bom_sub_component_tbl  => l_bom_sub_component_tbl);
               X_return_status := Error_Handler.G_STATUS_ERROR;
               X_msg_count     := Error_Handler.Get_Message_Count;
        END;


  /*****************************************************************
  * Procedure : Process_BOM
  * Parameters IN : Component Item Name
  *                 Organization Code
  *                 Assembly Item Name
  *                 Alternate BOM Code
  *                 Effectivity Start Date
  *                 Disable Date
  *                 Implementation Date
  *                 Debug Flag
  *                 Debug File Name
  *                 Output Directory for Debug File
  * Parameters OUT: Error Message
  *     Eco Component Unexposed Column Record
  * Purpose : This procedure will simply is a convenient Method
  *           that adds a component to a BOM.  This internaly
  *           Calls the BOM Business Object API
  ******************************************************************/
PROCEDURE Process_BOM
        (
           p_Component_Item_Name        IN  VARCHAR2
         , p_Organization_Code          IN  VARCHAR2
         , p_Assembly_Item_Name         IN  VARCHAR2
         , p_Alternate_Bom_Code         IN  VARCHAR2
         , p_Quantity_Per_Assembly      IN  NUMBER := 1
         , p_Start_Effective_Date       IN  DATE := SYSDATE
         , p_Disable_Date               IN  DATE := NULL
         , p_Implementation_Date        IN  DATE := SYSDATE
         , p_Debug      IN  VARCHAR2 := 'N'
         , p_Debug_FileName   IN  VARCHAR2 := NULL
         , p_Output_Dir     IN  VARCHAR2 := NULL
         , x_error_message    OUT NOCOPY VARCHAR2
         )
   IS
    l_bom_header_rec     Bom_Bo_Pub.Bom_Head_Rec_Type :=
        Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
    l_bom_component_tbl  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
        Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
    l_bom_revision_tbl        Bom_Bo_Pub.Bom_Revision_Tbl_Type;
    l_bom_ref_designator_tbl  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
    l_bom_sub_component_tbl   Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
    l_bom_comp_ops_tbl        Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;
    l_return_status   VARCHAR2(1);
    l_msg_count   NUMBER;

    l_message_text varchar2(2000);
    l_entity_index number;
    l_Implementation_Date  date;
    l_entity_id varchar2(30);
    l_message_type varchar2(1);
   BEGIN
    /* Create the header row */
    l_bom_header_rec.assembly_item_name := p_Assembly_Item_Name;
    l_bom_header_rec.organization_code  := p_Organization_Code;
    l_bom_header_rec.BOM_Implementation_Date := SYSDATE;
    l_bom_header_rec.transaction_type := 'SYNC';

    /* Create the component row with bare minimum attributes */

--If there is no Primary Create a Primary Bill
    if (p_Alternate_Bom_Code is not null) then

      l_bom_header_rec.alternate_bom_code := null;

      select decode(enable_unimplemented_boms,'Y',null, sysdate)
      into l_bom_header_rec.BOM_Implementation_Date
      from bom_structure_types_b stype,
           bom_alternate_designators alt
     where alt.alternate_designator_code IS NULL
       and stype.structure_type_id = alt.structure_type_id;


      Bom_Bo_Pub.Process_Bom
          (  p_bo_identifier           => 'BOM'
           , p_api_version_number      => 1.0
           , p_init_msg_list           => TRUE
           , p_bom_header_rec          => l_bom_header_rec
           , x_bom_header_rec          => l_bom_header_rec
           , x_bom_revision_tbl        => l_bom_revision_tbl
           , x_bom_component_tbl       => l_bom_component_tbl
           , x_bom_ref_designator_tbl  => l_bom_ref_designator_tbl
           , x_bom_sub_component_tbl   => l_bom_sub_component_tbl
           , x_bom_comp_ops_tbl        => l_bom_comp_ops_tbl
           , x_return_status           => l_return_status
           , x_msg_count               => l_msg_count
           , p_debug                   => p_Debug
           , p_output_dir              => p_Output_Dir
           , p_debug_filename          => p_Debug_FileName
           );
    end if;

    error_handler.close_debug_session;

    if (p_Alternate_Bom_Code is NULL) then
      select decode(enable_unimplemented_boms,'Y',null, sysdate)
        into l_bom_header_rec.BOM_Implementation_Date
        from bom_structure_types_b stype,
             bom_alternate_designators alt
       where
             alt.alternate_designator_code is NULL
         and alt.organization_id = -1
         and stype.structure_type_id = alt.structure_type_id;
    else
      select decode(enable_unimplemented_boms,'Y',null, sysdate)
        into l_bom_header_rec.BOM_Implementation_Date
        from bom_structure_types_b stype,
             bom_alternate_designators alt,
       org_organization_definitions org
       where alt.alternate_designator_code = p_Alternate_Bom_Code
         and alt.organization_id = org.organization_id
         and org.organization_code = p_Organization_Code
         and stype.structure_type_id = alt.structure_type_id;
     end if;

    l_bom_header_rec.assembly_item_name := p_Assembly_Item_Name;
    l_bom_header_rec.organization_code  := p_Organization_Code;
    l_bom_header_rec.transaction_type := 'SYNC';
    l_bom_header_rec.alternate_bom_code := p_Alternate_Bom_Code;
    l_bom_header_rec.return_status := null;

    l_bom_component_tbl(1).component_item_name := p_Component_Item_name;
    l_bom_component_tbl(1).assembly_item_name  := p_Assembly_Item_Name;
    l_bom_component_tbl(1).Organization_Code   := p_Organization_Code;
    l_bom_component_tbl(1).Start_Effective_Date := p_Start_Effective_Date; --SYSDATE;
    l_bom_component_tbl(1).Disable_Date    := p_Disable_Date;
    l_bom_component_tbl(1).Quantity_Per_Assembly := p_Quantity_Per_Assembly;
    l_bom_component_tbl(1).operation_sequence_number := 1;
    l_bom_component_tbl(1).transaction_type := 'SYNC';
    l_bom_component_tbl(1).alternate_bom_code := p_Alternate_Bom_Code;
    l_bom_component_tbl(1).return_status := null;


    /* Call the Business object with just the header and component entities */
    Bom_Bo_Pub.Process_Bom
          (  p_bo_identifier           => 'BOM'
           , p_api_version_number      => 1.0
           , p_init_msg_list           => TRUE
           , p_bom_header_rec          => l_bom_header_rec
           , p_bom_component_tbl       => l_bom_component_tbl
           , x_bom_header_rec          => l_bom_header_rec
           , x_bom_revision_tbl        => l_bom_revision_tbl
           , x_bom_component_tbl       => l_bom_component_tbl
           , x_bom_ref_designator_tbl  => l_bom_ref_designator_tbl
           , x_bom_sub_component_tbl   => l_bom_sub_component_tbl
           , x_bom_comp_ops_tbl        => l_bom_comp_ops_tbl
           , x_return_status           => l_return_status
           , x_msg_count               => l_msg_count
           , p_debug                   => p_Debug
           , p_output_dir              => p_Output_Dir
           , p_debug_filename          => p_Alternate_Bom_Code || '-'||p_Debug_FileName
           );

-- Call the Error handler
   if (l_msg_count > 0) then
     Error_Handler.Get_Message
          (  x_message_text        => l_message_text
           , x_entity_index        => l_entity_index
           , x_entity_id           => l_entity_id
           , x_message_type        => l_message_type
           );
   end if;


   if (l_message_type = 'E') then
     x_error_message := l_message_text;
   end if;


   END Process_BOM;

  /********************************************************************
        * Procedure     : Process_Bom
        * Parameters IN : Bom Product Header exposed column Record
        *                 Bom Inventorty Component exposed column table
        * Purpose       : This procedure is a wrapper on existing Process_BOM
        *                 procedure. This new procedure accepts a record of Bom
        *                 headers for product family Bills and a table for
        *                 product family components. It then calls  the existing
        *                 Process_BOM Procedure after populating all the
        *                 component data with the default values.
        *********************************************************************/
        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Product_Rec_Type
         , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Product_Mem_Tab_Type
   , x_bom_header_rec          OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
   , x_bom_component_tbl       OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
  )
  IS


        -- Local variables for the IN parameters

          l_input_bomheader_rec          Bom_Bo_Pub.Bom_Product_Rec_Type        := p_bom_header_rec;
          l_input_bomcomponents_tbl      Bom_Bo_Pub.Bom_Product_Mem_Tab_Type    := p_bom_component_tbl;

        -- BOM BO input parameters
          l_bom_header_rec             BOM_BO_PUB.Bom_Head_Rec_Type;
          l_bom_component_tbl          BOM_BO_PUB.Bom_Comps_Tbl_Type;
          x_bom_revision_tbl_out       BOM_BO_PUB.Bom_Revision_Tbl_Type;
    x_bom_ref_designator_tbl_out BOM_BO_PUB.Bom_Ref_Designator_Tbl_Type;
          x_bom_sub_component_tbl_out  BOM_BO_PUB.Bom_Sub_Component_Tbl_Type;
          x_bom_comp_ops_tbl_out       BOM_BO_PUB.Bom_Comp_ops_Tbl_Type;

          l_other_message       VARCHAR2(50);
          l_compcount           NUMBER;
    l_Token_Tbl           Error_Handler.Token_Tbl_Type;
          i     NUMBER := 1;

        BEGIN

          IF (l_input_bomheader_rec.assembly_item_name IS NOT NULL AND
              l_input_bomheader_rec.assembly_item_name <> FND_API.G_MISS_CHAR)
              OR
             (l_input_bomheader_rec.organization_code IS NOT NULL AND
              l_input_bomheader_rec.organization_code <> FND_API.G_MISS_CHAR)
          THEN
           l_bom_header_rec.Assembly_item_name := l_input_bomheader_rec.Assembly_item_name ;
           l_bom_header_rec.Organization_Code := l_input_bomheader_rec.Organization_Code;
           l_bom_header_rec.Alternate_Bom_Code := NULL;
           l_bom_header_rec.Common_Assembly_Item_Name := NULL;
           l_bom_header_rec.Common_Organization_Code := NULL;
           l_bom_header_rec.Assembly_Comment := NULL;
           l_bom_header_rec.Assembly_Type:= 1;
           l_bom_header_rec.Transaction_Type := l_input_bomheader_rec.Transaction_Type;
           l_bom_header_rec.Attribute_category := l_input_bomheader_rec.Attribute_category;
           l_bom_header_rec.Attribute1 := l_input_bomheader_rec.Attribute1;
           l_bom_header_rec.Attribute2 := l_input_bomheader_rec.Attribute2;
           l_bom_header_rec.Attribute3 := l_input_bomheader_rec.Attribute3;
           l_bom_header_rec.Attribute4 := l_input_bomheader_rec.Attribute4;
           l_bom_header_rec.Attribute5 := l_input_bomheader_rec.Attribute5 ;
           l_bom_header_rec.Attribute6 := l_input_bomheader_rec.Attribute6;
           l_bom_header_rec.Attribute7 := l_input_bomheader_rec.Attribute7;
           l_bom_header_rec.Attribute8 := l_input_bomheader_rec.Attribute8;
     l_bom_header_rec.Attribute9 := l_input_bomheader_rec.Attribute9;
           l_bom_header_rec.Attribute10 := l_input_bomheader_rec.Attribute10;
           l_bom_header_rec.Attribute11 := l_input_bomheader_rec.Attribute11;
           l_bom_header_rec.Attribute12 := l_input_bomheader_rec.Attribute12;
           l_bom_header_rec.Attribute13 := l_input_bomheader_rec.Attribute13;
           l_bom_header_rec.Attribute14 := l_input_bomheader_rec.Attribute14;
           l_bom_header_rec.Attribute15 := l_input_bomheader_rec.Attribute15;
           l_bom_header_rec.Delete_Group_Name := l_input_bomheader_rec.Delete_Group_Name;
           l_bom_header_rec.DG_Description := l_input_bomheader_rec.DG_Description;

          END IF;

  IF (l_bom_header_rec.Transaction_Type = BOM_Globals.G_OPR_UPDATE) Then
              l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
              l_token_tbl(1).token_value := l_bom_header_rec.assembly_item_name;
              l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
              l_token_tbl(2).token_value := l_bom_header_rec.organization_code ;

              x_return_status := 'E';
              Error_Handler.Log_Error
              ( p_error_status        => x_return_status
              , p_error_scope         => Error_Handler.G_SCOPE_ALL
              , p_error_level         => Error_Handler.G_BO_LEVEL
              , p_other_message       => 'BOM_ERROR_BUSINESS_OBJECT'
              , p_other_status        => x_return_status
              , p_other_token_tbl     => l_token_tbl
              , x_bom_header_rec      => l_bom_header_rec
              , x_bom_revision_tbl    => x_bom_revision_tbl_out
              , x_bom_component_tbl   => l_bom_component_tbl
              , x_bom_ref_designator_tbl => x_bom_ref_designator_tbl_out
              , x_bom_sub_component_tbl => x_bom_sub_component_tbl_out
              );
                x_msg_count := Error_Handler.Get_Message_Count;
          IF bom_globals.get_debug = 'Y' then
      Error_Handler.Write_Debug('Cannot have transaction type of UPDATE for product family Bills');
    END IF;
         ELSE
          IF l_input_bomcomponents_tbl IS NOT NULL THEN
              l_compcount         := l_input_bomcomponents_tbl.COUNT;
          ELSE
              l_compcount         := 0;
          END IF;

          IF (l_compcount > 0) THEN
                FOR compRec in 1.. l_compcount
                LOOP
                  IF l_input_bomcomponents_tbl(compRec).return_status IS NULL OR
                     l_input_bomcomponents_tbl(compRec).return_status = FND_API.G_MISS_CHAR
                  THEN
                      l_bom_component_tbl(compRec).Organization_Code     :=
                                        l_input_bomcomponents_tbl(compRec).Organization_Code ;
                      l_bom_component_tbl(compRec).Assembly_Item_Name     :=
                                        l_input_bomcomponents_tbl(compRec).Assembly_Item_Name ;
                      l_bom_component_tbl(compRec).Start_Effective_Date  :=
          l_input_bomcomponents_tbl(compRec).Start_Effective_Date;
          l_bom_component_tbl(compRec).Disable_Date     :=
                                        l_input_bomcomponents_tbl(compRec).Disable_Date;
                      l_bom_component_tbl(compRec).Operation_Sequence_Number    := 1; -- Default
                      l_bom_component_tbl(compRec).Component_Item_Name   :=
                                        l_input_bomcomponents_tbl(compRec).Component_Item_Name;
                      l_bom_component_tbl(compRec).Alternate_BOM_Code   := Null; -- Default
                      l_bom_component_tbl(compRec).New_Effectivity_Date  :=
                                        l_input_bomcomponents_tbl(compRec).New_Effectivity_Date;
                      l_bom_component_tbl(compRec).New_Operation_Sequence_Number   := 1 ; -- Default
                      l_bom_component_tbl(compRec).Item_Sequence_Number   := NULL ; -- Default
                      l_bom_component_tbl(compRec).Basis_Type := NULL ; -- Default
                      l_bom_component_tbl(compRec).Quantity_Per_Assembly  := 1 ; -- Default
                      l_bom_component_tbl(compRec).Planning_Percent  :=
                                        nvl(l_input_bomcomponents_tbl(compRec).Planning_Percent,100);
                      l_bom_component_tbl(compRec).Projected_Yield     := 1 ; -- Default
                      l_bom_component_tbl(compRec).Include_In_Cost_Rollup := NULL;
                      l_bom_component_tbl(compRec).Wip_Supply_Type     := NULL;
                      l_bom_component_tbl(compRec).So_Basis     := 2; --Default
                      l_bom_component_tbl(compRec).Optional     := 2; -- Default
                      l_bom_component_tbl(compRec).Mutually_Exclusive     := 2; -- Default
                      l_bom_component_tbl(compRec).Check_Atp     :=   NULL; -- Default
                      l_bom_component_tbl(compRec).Shipping_Allowed     :=    NULL;
                      l_bom_component_tbl(compRec).Required_To_Ship     :=    2; -- Default
                      l_bom_component_tbl(compRec).Required_For_Revenue  := 2; -- Default
                      l_bom_component_tbl(compRec).Include_On_Ship_Docs  := 2; -- Default
                      l_bom_component_tbl(compRec).Quantity_Related     := 2; -- Default
                      l_bom_component_tbl(compRec).Supply_Subinventory   := NULL;
                      l_bom_component_tbl(compRec).Location_Name     := NULL;
                      l_bom_component_tbl(compRec).Minimum_Allowed_Quantity := NULL;
                      l_bom_component_tbl(compRec).Maximum_Allowed_Quantity     := NULL;
                      l_bom_component_tbl(compRec).Comments     :=
                                        l_input_bomcomponents_tbl(compRec).Comments;
                      l_bom_component_tbl(compRec).Attribute_category     :=
                                        l_input_bomcomponents_tbl(compRec).Attribute_category;
          l_bom_component_tbl(compRec).Attribute1  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute1;
                      l_bom_component_tbl(compRec).Attribute2  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute2;
                      l_bom_component_tbl(compRec).Attribute3  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute3;
                      l_bom_component_tbl(compRec).Attribute4  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute4;
                      l_bom_component_tbl(compRec).Attribute5  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute5;
                      l_bom_component_tbl(compRec).Attribute6  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute6;
                      l_bom_component_tbl(compRec).Attribute7  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute7;
                      l_bom_component_tbl(compRec).Attribute8  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute8;
                      l_bom_component_tbl(compRec).Attribute9  :=
                                        l_input_bomcomponents_tbl(compRec).Attribute9;
                      l_bom_component_tbl(compRec).Attribute10 :=
                                        l_input_bomcomponents_tbl(compRec).Attribute10;
                      l_bom_component_tbl(compRec).Attribute11 :=
                                        l_input_bomcomponents_tbl(compRec).Attribute11;
                      l_bom_component_tbl(compRec).Attribute12 :=
                                        l_input_bomcomponents_tbl(compRec).Attribute12;
                      l_bom_component_tbl(compRec).Attribute13 :=
                                        l_input_bomcomponents_tbl(compRec).Attribute13;
                      l_bom_component_tbl(compRec).Attribute14 :=
                                        l_input_bomcomponents_tbl(compRec).Attribute14;
                      l_bom_component_tbl(compRec).Attribute15 :=
                                        l_input_bomcomponents_tbl(compRec).Attribute15;
                      l_bom_component_tbl(compRec).From_End_Item_Unit_Number    := NULL;
                      l_bom_component_tbl(compRec).New_From_End_Item_Unit_Number    := NULL;
                      l_bom_component_tbl(compRec).To_End_Item_Unit_Number     := NULL;
                      l_bom_component_tbl(compRec).Return_Status     := '';
          l_bom_component_tbl(compRec).Transaction_Type     :=
                                        l_input_bomcomponents_tbl(compRec).Transaction_Type;
                      l_bom_component_tbl(compRec).Original_System_Reference     := NULL;
                      l_bom_component_tbl(compRec).Delete_Group_Name     :=
                                        l_input_bomcomponents_tbl(compRec).Delete_Group_Name;
                      l_bom_component_tbl(compRec).DG_Description     :=
                                        l_input_bomcomponents_tbl(compRec).DG_Description;
                      l_bom_component_tbl(compRec).Enforce_Int_Requirements    := NULL;

                  END IF;
                END LOOP;
          END IF;

                --Call to existing Process_BOM
            Process_Bom(P_bo_identifier          => p_bo_identifier,
                        P_api_version_number     => p_api_version_number,
                        P_init_msg_list          => p_init_msg_list,
                        P_bom_header_rec         => l_bom_header_rec,
                        P_bom_revision_tbl       => G_MISS_BOM_REVISION_TBL,
                        P_bom_component_tbl      => l_bom_component_tbl,
                        P_bom_ref_designator_tbl => G_MISS_BOM_REF_DESIGNATOR_TBL,
                        P_bom_sub_component_tbl  => G_MISS_BOM_SUB_COMPONENT_TBL,
                        P_bom_comp_ops_tbl       => G_MISS_BOM_COMP_OPS_TBL,
                        X_bom_header_rec         => x_bom_header_rec,
                        X_bom_revision_tbl       => x_bom_revision_tbl_out,
                        X_bom_component_tbl      => x_bom_component_tbl,
                        X_bom_ref_designator_tbl => x_bom_ref_designator_tbl_out,
      X_bom_sub_component_tbl  => x_bom_sub_component_tbl_out,
                        X_bom_comp_ops_tbl       => x_bom_comp_ops_tbl_out,
                        X_return_status          => X_return_status,
                        X_msg_count              => X_msg_count,
                        P_debug                  => P_debug,
                        P_output_dir             => P_output_dir,
                        P_debug_filename         => P_debug_filename);
   END IF;
        END;
END Bom_Bo_Pub;

/
