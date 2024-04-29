--------------------------------------------------------
--  DDL for Package Body WSMPPCPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPPCPD" AS
/* $Header: WSMPCPDB.pls 120.5 2006/09/14 05:23:10 sisankar noship $ */

g_org_id    NUMBER  := NULL;

/* ===========================================================================

  PROCEDURE NAME:       insert_bill

=========================================================================== */

PROCEDURE insert_bill (x_rec IN OUT NOCOPY  bom_bill_of_mtls_interface%ROWTYPE,
                       x_assembly_item_name IN VARCHAR2 DEFAULT NULL,
                       x_organization_code IN VARCHAR2 DEFAULT NULL,
                       x_error_code IN OUT NOCOPY NUMBER,
                       x_error_msg IN OUT NOCOPY VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
e_insert_bill       EXCEPTION;
x_process_flag      NUMBER      := 1;

BEGIN

  x_progress := '010';

  /* Verify that the required arguments are being passed in. */
  IF ((x_assembly_item_name is NULL) OR
      (x_organization_code is NULL) OR
      (x_rec.assembly_type is NULL)) THEN
    --(x_rec.bill_sequence_id is NULL))  THEN
    raise e_insert_bill;
  END IF;

  x_progress := '020';

/******* begin delete ******
  This insert is being commented out since we will use
  the BOM Business Object API in 11.i.2 instead
  of the Open Interface

  INSERT INTO BOM_BILL_OF_MTLS_INTERFACE(
            transaction_type,
            assembly_item_id,
            organization_id,
            alternate_bom_designator,
            common_assembly_item_id,
            specific_assembly_comment,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            assembly_type,
            common_bill_sequence_id,
            bill_sequence_id,
            revision,
            common_organization_id,
            process_flag,
            organization_code,
            common_org_code,
            item_number,
            common_item_number
    ) VALUES (
            'CREATE',
            x_rec.assembly_item_id,
            x_rec.organization_id,
            x_rec.alternate_bom_designator,
            x_rec.common_assembly_item_id,
            x_rec.specific_assembly_comment,
            x_rec.attribute_category,
            x_rec.attribute1,
            x_rec.attribute2,
            x_rec.attribute3,
            x_rec.attribute4,
            x_rec.attribute5,
            x_rec.attribute6,
            x_rec.attribute7,
            x_rec.attribute8,
            x_rec.attribute9,
            x_rec.attribute10,
            x_rec.attribute11,
            x_rec.attribute12,
            x_rec.attribute13,
            x_rec.attribute14,
            x_rec.attribute15,
            x_rec.assembly_type,
            x_rec.common_bill_sequence_id,
            x_rec.bill_sequence_id,
            x_rec.revision,
            x_rec.common_organization_id,
            x_process_flag,
            x_rec.organization_code,
            x_rec.common_org_code,
            x_rec.item_number,
            x_rec.common_item_number);
****** end delete ******/

    -- begin add for wsm
    g_bom_header_rec.Transaction_Type   := BOM_Globals.G_OPR_CREATE;
    g_bom_header_rec.Assembly_Item_Name := x_assembly_item_name;
    g_bom_header_rec.Organization_Code := x_organization_code;
    g_bom_header_rec.Alternate_Bom_Code := x_rec.Alternate_Bom_Designator;
    g_bom_header_rec.Common_Assembly_Item_Name := null;
    g_bom_header_rec.Common_Organization_Code := null;
    g_bom_header_rec.Assembly_Comment := x_rec.specific_Assembly_Comment;
    g_bom_header_rec.Assembly_Type := x_rec.Assembly_Type;
    g_bom_header_rec.Attribute_category := x_rec.Attribute_category;
    g_bom_header_rec.Attribute1 := x_rec.Attribute1;
    g_bom_header_rec.Attribute2 := x_rec.Attribute2;
    g_bom_header_rec.Attribute3 := x_rec.Attribute3;
    g_bom_header_rec.Attribute4 := x_rec.Attribute4;
    g_bom_header_rec.Attribute5 := x_rec.Attribute5;
    g_bom_header_rec.Attribute6 := x_rec.Attribute6;
    g_bom_header_rec.Attribute7 := x_rec.Attribute7;
    g_bom_header_rec.Attribute8 := x_rec.Attribute8;
    g_bom_header_rec.Attribute9 := x_rec.Attribute9;
    g_bom_header_rec.Attribute10 := x_rec.Attribute10;
    g_bom_header_rec.Attribute11 := x_rec.Attribute11;
    g_bom_header_rec.Attribute12 := x_rec.Attribute12;
    g_bom_header_rec.Attribute13 := x_rec.Attribute13;
    g_bom_header_rec.Attribute14 := x_rec.Attribute14;
    g_bom_header_rec.Attribute15 := x_rec.Attribute15;
    -- end add for wsm

    x_error_code := 0;

EXCEPTION
    WHEN e_insert_bill THEN
        x_error_code := 1;
        -- x_error_msg  := 'Insufficient arguments to WSMPPCPD.insert_bill';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.insert_bill');
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.insert_bill(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END insert_bill;


/* ===========================================================================

  PROCEDURE NAME:       insert_component

=========================================================================== */

PROCEDURE insert_component (x_rec                IN OUT NOCOPY  bom_inventory_comps_interface%ROWTYPE,
                            x_component_name     IN VARCHAR2 DEFAULT NULL,
                            x_organization_code  IN VARCHAR2 DEFAULT NULL,
                            x_assembly_item_name IN VARCHAR2 DEFAULT NULL,
                            x_supply_locator     IN VARCHAR2 DEFAULT NULL,
                            x_error_code         IN OUT NOCOPY NUMBER,
                            x_error_msg          IN OUT NOCOPY VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
e_insert_component  EXCEPTION;
x_process_flag      NUMBER      := 1;
l_basis_type     number; --LBM enh

BEGIN

    x_progress := '010';

    /* Verify that the required arguments are being passed in. */
    IF ((x_component_name is NULL) OR
        --(x_rec.component_sequence_id is NULL) OR
        (x_organization_code is NULL) OR
        (x_assembly_item_name is NULL) OR
        (x_rec.operation_seq_num is NULL) OR
        (x_rec.effectivity_date is NULL))  THEN
        raise e_insert_component;
    END IF;

    x_progress := '020';
    if x_rec.basis_type = 2 then  --LBM enh
        l_basis_type := 2;
    else
        l_basis_type := null;
    end if;                       --LBM enh

/*  This insert will be commented since we do not want to
    insert into the interface table anymore.  We will use
    the bom bo api with 11.i.2

    INSERT INTO BOM_INVENTORY_COMPS_INTERFACE(
            transaction_type,
            operation_seq_num,
            component_item_id,
            item_num,
            component_quantity,
            component_yield_factor,
            component_remarks,
            effectivity_date,
            disable_date,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            planning_factor,
            quantity_related,
            so_basis,
            optional,
            mutually_exclusive_options,
            include_in_cost_rollup,
            check_atp,
            required_to_ship,
            required_for_revenue,
            include_on_ship_docs,
            low_quantity,
            high_quantity,
            component_sequence_id,
            bill_sequence_id,
            wip_supply_type,
            supply_subinventory,
            supply_locator_id,
            operation_lead_time_percent,
            assembly_item_id,
            alternate_bom_designator,
            organization_id,
            organization_code,
            component_item_number,
            assembly_item_number,
            location_name,
            reference_designator,
            substitute_comp_id,
            substitute_comp_number,
            process_flag
    ) VALUES (
            'CREATE',
            x_rec.operation_seq_num,
            x_rec.component_item_id,
            x_rec.item_num,
            x_rec.component_quantity,
            x_rec.component_yield_factor,
            x_rec.component_remarks,
            x_rec.effectivity_date,
            x_rec.disable_date,
            x_rec.attribute_category,
            x_rec.attribute1,
            x_rec.attribute2,
            x_rec.attribute3,
            x_rec.attribute4,
            x_rec.attribute5,
            x_rec.attribute6,
            x_rec.attribute7,
            x_rec.attribute8,
            x_rec.attribute9,
            x_rec.attribute10,
            x_rec.attribute11,
            x_rec.attribute12,
            x_rec.attribute13,
            x_rec.attribute14,
            x_rec.attribute15,
            x_rec.planning_factor,
            x_rec.quantity_related,
            x_rec.so_basis,
            x_rec.optional,
            x_rec.mutually_exclusive_options,
            x_rec.include_in_cost_rollup,
            x_rec.check_atp,
            x_rec.required_to_ship,
            x_rec.required_for_revenue,
            x_rec.include_on_ship_docs,
            x_rec.low_quantity,
            x_rec.high_quantity,
            x_rec.component_sequence_id,
            x_rec.bill_sequence_id,
            x_rec.wip_supply_type,
            x_rec.supply_subinventory,
            x_rec.supply_locator_id,
            x_rec.operation_lead_time_percent,
            x_rec.assembly_item_id,
            x_rec.alternate_bom_designator,
            x_rec.organization_id,
            x_rec.organization_code,
            x_rec.component_item_number,
            x_rec.assembly_item_number,
            x_rec.location_name,
            x_rec.reference_designator,
            x_rec.substitute_comp_id,
            x_rec.substitute_comp_number,
            x_process_flag);
*/
    g_component_tbl(1).Transaction_Type := BOM_Globals.G_OPR_CREATE;
    --start defaulting
    g_component_tbl(1).item_sequence_number := NULL;
    g_component_tbl(1).Quantity_Related := 2;
    g_component_tbl(1).Check_Atp := NULL;
    g_component_tbl(1).To_End_Item_Unit_Number := NULL;
    g_component_tbl(1).So_Basis := 2;
    g_component_tbl(1).Optional := 2;
    g_component_tbl(1).Mutually_Exclusive := 2;
    g_component_tbl(1).Shipping_Allowed := 2;
    g_component_tbl(1).Required_To_Ship := 2;
    g_component_tbl(1).Required_For_Revenue := 2;
    g_component_tbl(1).Include_On_Ship_Docs := 2;
    g_component_tbl(1).Minimum_Allowed_Quantity := NULL;
    g_component_tbl(1).Maximum_Allowed_Quantity := NULL;
    --end defaulting
    g_component_tbl(1).Organization_Code := x_organization_code;
    g_component_tbl(1).Assembly_Item_Name := x_assembly_item_name;
    g_component_tbl(1).Start_Effective_Date := x_rec.effectivity_date;
    g_component_tbl(1).Disable_Date := x_rec.Disable_Date;
    g_component_tbl(1).Operation_Sequence_Number := x_rec.operation_seq_num;
    g_component_tbl(1).Component_Item_Name := x_component_name;
    g_component_tbl(1).Alternate_BOM_Code := x_rec.alternate_bom_designator;
    g_component_tbl(1).Quantity_Per_Assembly := x_rec.component_quantity;
    g_component_tbl(1).Planning_Percent := x_rec.planning_factor;
    g_component_tbl(1).Projected_Yield := x_rec.component_yield_factor;
    g_component_tbl(1).Include_In_Cost_Rollup := x_rec.include_in_cost_rollup;
    g_component_tbl(1).Wip_Supply_Type := x_rec.wip_supply_type;
    g_component_tbl(1).Supply_Subinventory := x_rec.Supply_Subinventory;
    g_component_tbl(1).Location_Name := x_supply_locator;
    g_component_tbl(1).Comments := x_rec.component_remarks;
    g_component_tbl(1).Attribute_category := x_rec.Attribute_category;
    g_component_tbl(1).Attribute1 := x_rec.Attribute1;
    g_component_tbl(1).Attribute2 := x_rec.Attribute2;
    g_component_tbl(1).Attribute3 := x_rec.Attribute3;
    g_component_tbl(1).Attribute4 := x_rec.Attribute4;
    g_component_tbl(1).Attribute5 := x_rec.Attribute5;
    g_component_tbl(1).Attribute6 := x_rec.Attribute6;
    g_component_tbl(1).Attribute7 := x_rec.Attribute7;
    g_component_tbl(1).Attribute8 := x_rec.Attribute8;
    g_component_tbl(1).Attribute9 := x_rec.Attribute9;
    g_component_tbl(1).Attribute10 := x_rec.Attribute10;
    g_component_tbl(1).Attribute11 := x_rec.Attribute11;
    g_component_tbl(1).Attribute12 := x_rec.Attribute12;
    g_component_tbl(1).Attribute13 := x_rec.Attribute13;
    g_component_tbl(1).Attribute14 := x_rec.Attribute14;
    g_component_tbl(1).Attribute15 := x_rec.Attribute15;
    g_component_tbl(1).basis_type := l_basis_type;  --LBM enh

    x_error_code := 0;

EXCEPTION
    WHEN e_insert_component THEN
        x_error_code := 1;
        --x_error_msg  := 'Insufficient arguments to WSMPPCPD.insert_component';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.insert_component');
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.insert_component(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END insert_component;


/* ===========================================================================

  PROCEDURE NAME:       insert_substitute_component

=========================================================================== */

PROCEDURE insert_substitute_component (
                x_rec                   IN OUT NOCOPY  bom_sub_comps_interface%ROWTYPE,
                x_co_product_name       IN  VARCHAR2,
                x_alternate_designator  IN  VARCHAR2,
                x_component_name        IN  VARCHAR2,
                x_comp_start_eff_date   IN  DATE,
                x_org_code              IN  VARCHAR2,
                x_error_code            IN OUT NOCOPY NUMBER,
                x_error_msg             IN OUT NOCOPY VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
e_insert_substitute EXCEPTION;
e_proc_exception    EXCEPTION;
x_process_flag      NUMBER      := 1;

BEGIN

    x_progress := '010';

    /* Verify that the required arguments are being passed in. */
    IF ((x_rec.substitute_component_id is NULL) OR
        (x_rec.substitute_item_quantity is NULL) OR
        --(x_rec.component_sequence_id is NULL))  THEN -- not required now
        (x_co_product_name is NULL) OR
        (x_component_name is NULL) OR
        (x_comp_start_eff_date is NULL) OR
        (x_org_code is NULL)) THEN

        raise e_insert_substitute;

    END IF;

    x_progress := '020';

    /*  Comment this out since we are using the BOM BO API in Release 11i.2
    INSERT INTO BOM_SUB_COMPS_INTERFACE(
            transaction_type,
            substitute_component_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            substitute_item_quantity,
            component_sequence_id,
            acd_type,
            change_notice,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            bill_sequence_id,
            assembly_item_id,
            alternate_bom_designator,
            organization_id,
            component_item_id,
            operation_seq_num,
            effectivity_date,
            transaction_id,
            process_flag,
            organization_code,
            substitute_comp_number,
            component_item_number,
            assembly_item_number
    ) VALUES (
            'CREATE',
            x_rec.substitute_component_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id,
            x_rec.substitute_item_quantity,
            x_rec.component_sequence_id,
            x_rec.acd_type,
            x_rec.change_notice,
            x_rec.attribute_category,
            x_rec.attribute1,
            x_rec.attribute2,
            x_rec.attribute3,
            x_rec.attribute4,
            x_rec.attribute5,
            x_rec.attribute6,
            x_rec.attribute7,
            x_rec.attribute8,
            x_rec.attribute9,
            x_rec.attribute10,
            x_rec.attribute11,
            x_rec.attribute12,
            x_rec.attribute13,
            x_rec.attribute14,
            x_rec.attribute15,
            x_rec.bill_sequence_id,
            x_rec.assembly_item_id,
            x_rec.alternate_bom_designator,
            x_rec.organization_id,
            x_rec.component_item_id,
            x_rec.operation_seq_num,
            x_rec.effectivity_date,
            x_rec.transaction_id,
            x_process_flag,
            x_rec.organization_code,
            x_rec.substitute_comp_number,
            x_rec.component_item_number,
            x_rec.assembly_item_number);
    */

    -- populate the bom bo api pl/sql table with substitute component data

    g_subs_component_count := g_subs_component_count + 1;

    g_subs_comp_tbl(g_subs_component_count).Transaction_Type
                                        := BOM_Globals.G_OPR_CREATE;
    g_subs_comp_tbl(g_subs_component_count).Organization_Code := x_org_code;
    g_subs_comp_tbl(g_subs_component_count).Assembly_Item_Name
                                        := x_co_product_name;
    g_subs_comp_tbl(g_subs_component_count).Start_Effective_Date
                                        := x_comp_start_eff_date;
    g_subs_comp_tbl(g_subs_component_count).Operation_Sequence_Number := 1;
    g_subs_comp_tbl(g_subs_component_count).Component_Item_Name
                                        := x_component_name;
    g_subs_comp_tbl(g_subs_component_count).Alternate_BOM_Code
                                        := x_alternate_designator;
    g_subs_comp_tbl(g_subs_component_count).Substitute_Component_Name
                        := WSMPCOGI.Get_Item_Name (
                           x_rec.substitute_component_id,
                           x_rec.organization_id,
                           x_error_code,
                           x_error_msg);
    IF x_error_code <> 0 THEN
        raise e_proc_exception;
    END IF;

    g_subs_comp_tbl(g_subs_component_count).Substitute_Item_Quantity
                                        := x_rec.substitute_item_quantity;
    g_subs_comp_tbl(g_subs_component_count).Attribute_category
                                        := x_rec.attribute_category;
    g_subs_comp_tbl(g_subs_component_count).Attribute1 := x_rec.attribute1;
    g_subs_comp_tbl(g_subs_component_count).Attribute2 := x_rec.attribute2;
    g_subs_comp_tbl(g_subs_component_count).Attribute3 := x_rec.attribute3;
    g_subs_comp_tbl(g_subs_component_count).Attribute4 := x_rec.attribute4;
    g_subs_comp_tbl(g_subs_component_count).Attribute5 := x_rec.attribute5;
    g_subs_comp_tbl(g_subs_component_count).Attribute6 := x_rec.attribute6;
    g_subs_comp_tbl(g_subs_component_count).Attribute7 := x_rec.attribute7;
    g_subs_comp_tbl(g_subs_component_count).Attribute8 := x_rec.attribute8;
    g_subs_comp_tbl(g_subs_component_count).Attribute9 := x_rec.attribute9;
    g_subs_comp_tbl(g_subs_component_count).Attribute10 := x_rec.attribute10;
    g_subs_comp_tbl(g_subs_component_count).Attribute11 := x_rec.attribute11;
    g_subs_comp_tbl(g_subs_component_count).Attribute12 := x_rec.attribute12;
    g_subs_comp_tbl(g_subs_component_count).Attribute13 := x_rec.attribute13;
    g_subs_comp_tbl(g_subs_component_count).Attribute14 := x_rec.attribute14;
    g_subs_comp_tbl(g_subs_component_count).Attribute15 := x_rec.attribute15;

    x_error_code := 0;

EXCEPTION
    WHEN e_insert_substitute THEN
        x_error_code := 1;
        --x_error_msg  := 'Insufficient arguments to WSMPPCPD.insert_substitute_component';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.insert_substitute_component');
        x_error_msg := fnd_message.get;

    WHEN e_proc_exception THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.insert_substitute_component('||x_progress||')';

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.insert_substitute_component(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END insert_substitute_component;


/* ===========================================================================
  PROCEDURE NAME:       insert_sub_comps
=========================================================================== */

PROCEDURE insert_sub_comps (x_co_product_group_id   IN  NUMBER,
                            x_co_product_name       IN  VARCHAR2,
                            x_alternate_designator  IN  VARCHAR2,
                            x_component_name        IN  VARCHAR2,
                            x_comp_start_eff_date   IN  DATE,
                            x_org_code              IN  VARCHAR2,
                            x_component_sequence_id IN  NUMBER,
                            x_qty_multiplier        IN  NUMBER,
                            x_error_code            IN OUT NOCOPY  NUMBER,
                            x_error_msg             IN OUT NOCOPY  VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
i               NUMBER;
e_proc_exception    EXCEPTION;
x_rec               bom_sub_comps_interface%ROWTYPE;

CURSOR S IS SELECT *
            FROM   wsm_co_prod_comp_substitutes
            WHERE  co_product_group_id = x_co_product_group_id;

BEGIN

    x_progress := '010';
/*coprod enh p2*/
--    if ((g_subs_rec_set IS NULL) OR (g_subs_rec_set <> 'Y')) then
/*end coprod enh p2*/
    -- Clean out the substitute component pl/sql table for the bom api
    g_subs_comp_tbl.delete;
/*coprod enh p2*/
    g_subs_component_count := 0;
/*end coprod enh p2*/

    FOR S_rec IN S LOOP

        x_rec.substitute_component_id   := S_rec.substitute_component_id;
        x_rec.substitute_item_quantity  := S_rec.substitute_item_quantity;
        x_rec.component_sequence_id     := x_component_sequence_id;
        x_rec.organization_id           := g_org_id;
        x_rec.attribute_category        := S_rec.attribute_category;
        x_rec.attribute1                := S_rec.attribute1;
        x_rec.attribute2                := S_rec.attribute2;
        x_rec.attribute3                := S_rec.attribute3;
        x_rec.attribute4                := S_rec.attribute4;
        x_rec.attribute5                := S_rec.attribute5;
        x_rec.attribute6                := S_rec.attribute6;
        x_rec.attribute7                := S_rec.attribute7;
        x_rec.attribute8                := S_rec.attribute8;
        x_rec.attribute9                := S_rec.attribute9;
        x_rec.attribute10                := S_rec.attribute10;
        x_rec.attribute11                := S_rec.attribute11;
        x_rec.attribute12                := S_rec.attribute12;
        x_rec.attribute13                := S_rec.attribute13;
        x_rec.attribute14                := S_rec.attribute14;
        x_rec.attribute15                := S_rec.attribute15;

        WSMPPCPD.insert_substitute_component (x_rec,
                                          x_co_product_name,
                                          x_alternate_designator,
                                          x_component_name,
                                          x_comp_start_eff_date,
                                          x_org_code,
                                          x_error_code,
                                          x_error_msg);
--        g_subs_rec_set := 'Y';

        IF (x_error_code < 0) THEN
             raise e_proc_exception;
        ELSIF (x_error_code > 0) THEN
             return;
        END IF;

    END LOOP;
--    elsif (g_subs_rec_set = 'Y') then
--      FOR  i in 1..g_subs_component_count LOOP
--          g_subs_comp_tbl(g_subs_component_count).Assembly_Item_Name := x_co_product_name;
--              g_subs_comp_tbl(g_subs_component_count).Alternate_BOM_Code := x_alternate_designator;
--      END LOOP;
--    end if;
    x_error_code := 0;

EXCEPTION
    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.insert_sub_comps('||x_progress||')';

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.insert_sub_comps(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END insert_sub_comps;

/* ===========================================================================

  PROCEDURE NAME:       process_bom_sub_comp

=========================================================================== */

/*Coprod enh p2 rewrote process_bom_sub_comp****************************************
pROCEDURE process_bom_sub_comp (x_co_product_group_id       IN     NUMBER,
                                X_substitute_component_id   IN     NUMBER,
                                X_substitute_comp_id_old    IN     NUMBER,
                                X_process_code              IN     NUMBER,
                                X_org_id                    IN     NUMBER,
                                X_rowid                     IN OUT NOCOPY VARCHAR2,
                                x_last_update_login         NUMBER,
                                x_last_updated_by           NUMBER,
                                x_last_update_date          DATE,
                                x_creation_date             DATE,
                                x_created_by                NUMBER,
                                x_substitute_item_quantity  NUMBER,
                                x_attribute_category        VARCHAR2,
                                x_attribute1                VARCHAR2,
                                x_attribute2                VARCHAR2,
                                x_attribute3                VARCHAR2,
                                x_attribute4                VARCHAR2,
                                x_attribute5                VARCHAR2,
                                x_attribute6                VARCHAR2,
                                x_attribute7                VARCHAR2,
                                x_attribute8                VARCHAR2,
                                x_attribute9                VARCHAR2,
                                x_attribute10               VARCHAR2,
                                x_attribute11               VARCHAR2,
                                x_attribute12               VARCHAR2,
                                x_attribute13               VARCHAR2,
                                x_attribute14               VARCHAR2,
                                x_attribute15               VARCHAR2,
                                x_error_code                IN OUT NOCOPY NUMBER,
                                x_error_msg                 IN OUT NOCOPY VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
e_proc_exception    EXCEPTION;
x_rec               bom_sub_comps_interface%ROWTYPE;

e_comp_exception            EXCEPTION;
e_check_unique_exception    EXCEPTION;
e_check_common              EXCEPTION;
e_sub_comp_not_exists       EXCEPTION;
bom_dupl_comp_err           EXCEPTION;   -- abedajna

x_dummy                     NUMBER      := NULL;
x_co_prod_exists            NUMBER      := NULL;
x_comp_exists               NUMBER      := NULL;
x_component_sequence_id     NUMBER      := NULL;
x_bill_sequence_id          NUMBER      := NULL;
x_sub_rowid                 VARCHAR2(30):= NULL;
x_sub_comp_record           bom_substitute_components%ROWTYPE;
x_skip_sub_delete           NUMBER      := 0;

CURSOR S IS SELECT *
            FROM   wsm_co_prod_comp_substitutes
            WHERE  co_product_group_id = x_co_product_group_id;

CURSOR C (x_comp_seq_id NUMBER) IS SELECT rowid
            FROM   bom_substitute_components
            WHERE  component_sequence_id = x_comp_seq_id
            AND    substitute_component_id = x_substitute_comp_id_old
            FOR UPDATE OF substitute_component_id NOWAIT;

CURSOR C_COPROD IS SELECT component_sequence_id,
           bill_sequence_id
    FROM   wsm_co_products
    WHERE  co_product_group_id = x_co_product_group_id
    And    co_product_id is NOT NULL;

BEGIN

    x_progress := '010';



    IF (x_process_code = 1) THEN

        BEGIN


-- modification begin for perf. tuning.. abedajna 10/12/00
            SELECT 1
            INTO   x_co_prod_exists
            FROM   wsm_co_products
            WHERE  co_product_group_id = x_co_product_group_id
            AND    co_product_id IS NOT NULL;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_co_prod_exists := 0;

            WHEN TOO_MANY_ROWS THEN
                x_co_prod_exists := 1;
-- modification end for perf. tuning.. abedajna 10/12/00
        END;

        x_progress := '020';

        IF (x_co_prod_exists = 0) THEN

                        WSMPCPCS.insert_row (
                        x_rowid,
                        x_co_product_group_id,
                        x_substitute_component_id,
                        x_last_update_login,
                        x_last_updated_by,
                        x_last_update_date,
                        x_creation_date,
                        x_created_by,
                        x_substitute_item_quantity,
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        null,
                        null,
                        null,
                        null);

            x_error_code := 0;
            return;

        END IF;
    END IF;


    x_progress := '030';

    SELECT component_sequence_id,
           bill_sequence_id
    INTO   x_component_sequence_id,
           x_bill_sequence_id
    FROM   wsm_co_products
    WHERE  co_product_group_id = x_co_product_group_id
    And    co_product_id is NOT NULL
    AND    NVL(primary_flag, 'N') = 'Y';

    x_progress := '040';

    BEGIN

        SELECT 1
        INTO   x_comp_exists
        FROM   bom_inventory_components
        WHERE  component_sequence_id = x_component_sequence_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise e_comp_exception;
    END;


    IF (x_process_code = 1) THEN

        x_progress := '050';

        BEGIN



-- modification begin for perf. tuning.. abedajna 10/12/00

            x_dummy := 0;

            SELECT 1
            INTO   x_dummy
            FROM   bom_substitute_components
            WHERE  nvl(acd_type, 1) = 1
            AND    substitute_component_id = x_substitute_component_id
            AND    component_sequence_id = x_component_sequence_id;

            IF x_dummy <> 0 THEN
                RAISE bom_dupl_comp_err;
            END IF;

        EXCEPTION

            WHEN bom_dupl_comp_err THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;

            WHEN NO_DATA_FOUND THEN
                NULL;

            WHEN TOO_MANY_ROWS THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;
-- modification end for perf. tuning.. abedajna 10/12/00

        END;

        x_progress := '060';

        BEGIN

            SELECT 1
            INTO   x_dummy
            FROM   bom_bill_of_materials bbom
            WHERE  bbom.common_bill_sequence_id = x_bill_sequence_id
            AND bbom.organization_id <> x_org_id
            AND NOT EXISTS (
                 SELECT null
                 FROM   mtl_system_items msi
                 WHERE  msi.organization_id = bbom.organization_id
                 AND    msi.inventory_item_id = x_substitute_component_id
                 AND    msi.bom_enabled_flag = 'Y'
                 AND    ((bbom.assembly_type = 1
                          AND msi.eng_item_flag = 'N')
                          OR (bbom.assembly_type = 2)));

            fnd_message.set_name('INV','INV_NOT_VALID');
            fnd_message.set_token('ENTITY','Substitute item', TRUE);
            raise e_check_common;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            null;
        END;

        x_progress := '070';

        bom_sub_comps_pkg.insert_row(x_sub_rowid,
                       x_substitute_component_id,
                       x_last_update_date,
                       x_last_updated_by,
                       x_creation_date,
                       x_created_by,
                       x_last_update_login,
                       x_substitute_item_quantity,
                       x_component_sequence_id,
                       null,
                       null,
                       x_attribute_category,
                       x_attribute1,
                       x_attribute2,
                       x_attribute3,
                       x_attribute4,
                       x_attribute5,
                       x_attribute6,
                       x_attribute7,
                       x_attribute8,
                       x_attribute9,
                       x_attribute10,
                       x_attribute11,
                       x_attribute12,
                       x_attribute13,
                       x_attribute14,
                       x_attribute15);


        WSMPCPCS.insert_row (x_rowid,
                        x_co_product_group_id,
                        x_substitute_component_id,
                        x_last_update_login,
                        x_last_updated_by,
                        x_last_update_date,
                        x_creation_date,
                        x_created_by,
                        x_substitute_item_quantity,
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        null,
                        null,
                        null,
                        null);

        x_error_code := 0;
        return;

    ELSIF (x_process_code = 2) THEN

        IF (x_substitute_component_id <> x_substitute_comp_id_old) THEN


        x_progress := '080';

        BEGIN


            x_dummy := 0;

            SELECT 1
            INTO   x_dummy
            FROM   bom_substitute_components
            WHERE  nvl(acd_type, 1) = 1
            AND    substitute_component_id = x_substitute_component_id
            AND    component_sequence_id = x_component_sequence_id;


            IF x_dummy <> 0 THEN
                RAISE bom_dupl_comp_err;
            END IF;

        EXCEPTION

            WHEN bom_dupl_comp_err THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;

            WHEN NO_DATA_FOUND THEN
                NULL;

            WHEN TOO_MANY_ROWS THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;

-- modification end for perf. tuning.. abedajna 10/12/00
        END;

        x_progress := '090';

        BEGIN

            SELECT 1
            INTO   x_dummy
            FROM   bom_bill_of_materials bbom
            WHERE  bbom.common_bill_sequence_id = x_bill_sequence_id
            AND    bbom.organization_id <> x_org_id
            AND NOT EXISTS
                (SELECT null
                 FROM   mtl_system_items msi
                 WHERE  msi.organization_id = bbom.organization_id
                 AND    msi.inventory_item_id = x_substitute_component_id
                 AND    msi.bom_enabled_flag = 'Y'
                 AND    ((bbom.assembly_type = 1
                         AND msi.eng_item_flag = 'N')
                         OR (bbom.assembly_type = 2)));

           fnd_message.set_name('INV','INV_NOT_VALID');
           fnd_message.set_token('ENTITY','Substitute item', TRUE);
           raise e_check_common;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               null;
           END;
       END IF;


      OPEN C (x_component_sequence_id);
      FETCH C  INTO x_sub_rowid;
        IF (C%NOTFOUND) THEN
          raise e_sub_comp_not_exists;
        END IF;
      CLOSE C;

      x_progress := '100';

      bom_sub_comps_pkg.update_row(x_sub_rowid,
                       x_substitute_component_id,
                       x_last_update_date,
                       x_last_updated_by,
                       x_last_update_login,
                       x_substitute_item_quantity,
                       x_component_sequence_id,
                       null,
                       null,
                       x_attribute_category,
                       x_attribute1,
                       x_attribute2,
                       x_attribute3,
                       x_attribute4,
                       x_attribute5,
                       x_attribute6,
                       x_attribute7,
                       x_attribute8,
                       x_attribute9,
                       x_attribute10,
                       x_attribute11,
                       x_attribute12,
                       x_attribute13,
                       x_attribute14,
                       x_attribute15);

      x_progress := '110';

      WSMPCPCS.update_row(X_rowid,
                       x_co_product_group_id,
                       x_substitute_component_id,
                       x_last_update_login,
                       x_last_updated_by,
                       x_last_update_date,
                       x_substitute_item_quantity,
                       x_attribute_category,
                       x_attribute1,
                       x_attribute2,
                       x_attribute3,
                       x_attribute4,
                       x_attribute5,
                       x_attribute6,
                       x_attribute7,
                       x_attribute8,
                       x_attribute9,
                       x_attribute10,
                       x_attribute11,
                       x_attribute12,
                       x_attribute13,
                       x_attribute14,
                       x_attribute15,
                       null,
                       null,
                       null,
                       null);

    ELSIF (x_process_code = 3) THEN

        x_progress := '120';

        OPEN C (x_component_sequence_id);
        FETCH C INTO x_sub_rowid;
        IF (C%NOTFOUND) THEN
             x_skip_sub_delete := 1;
        END IF;
        CLOSE C;

        IF (x_skip_sub_delete = 0) THEN
            bom_sub_comps_pkg.Delete_Row (x_sub_rowid);
        END IF;

        WSMPCPCS.Delete_Row (x_rowid);

    END IF;

    x_error_code := 0;

EXCEPTION
    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.insert_sub_comps('||x_progress||')';

    WHEN e_comp_exception THEN
        x_error_code := 1;
        fnd_message.set_name('WSM','WSM_MISSING_BOM_COMP');
        x_error_msg  := fnd_message.get;

    WHEN e_check_unique_exception THEN
        x_error_code := 2;
        x_error_msg  := fnd_message.get;

    WHEN e_check_common THEN
        x_error_code := 3;
        x_error_msg  := fnd_message.get;

    WHEN e_sub_comp_not_exists THEN
        x_error_code := 4;
        fnd_message.set_name('WSM','WSM_MISSING_SUBS_COMP');
        x_error_msg := fnd_message.get;

    WHEN app_exceptions.record_lock_exception THEN
        x_error_code := 5;
        fnd_message.set_name('WSM','WSM_SUBS_COMP_LOCK_ERR');
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.process_bom_sub_comp(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END process_bom_sub_comp;
***************************************************************************************************************************/


PROCEDURE process_bom_sub_comp (x_co_product_group_id       IN     NUMBER,
                                x_substitute_component_id   IN     NUMBER,
                                x_substitute_comp_id_old    IN     NUMBER,
                                x_process_code              IN     NUMBER,
                                x_org_id                    IN     NUMBER,
                                x_rowid                     IN OUT NOCOPY VARCHAR2,
                                x_last_update_login         NUMBER,
                                x_last_updated_by           NUMBER,
                                x_last_update_date          DATE,
                                x_creation_date             DATE,
                                x_created_by                NUMBER,
                                x_substitute_item_quantity  NUMBER,
                                x_attribute_category        VARCHAR2,
                                x_attribute1                VARCHAR2,
                                x_attribute2                VARCHAR2,
                                x_attribute3                VARCHAR2,
                                x_attribute4                VARCHAR2,
                                x_attribute5                VARCHAR2,
                                x_attribute6                VARCHAR2,
                                x_attribute7                VARCHAR2,
                                x_attribute8                VARCHAR2,
                                x_attribute9                VARCHAR2,
                                x_attribute10               VARCHAR2,
                                x_attribute11               VARCHAR2,
                                x_attribute12               VARCHAR2,
                                x_attribute13               VARCHAR2,
                                x_attribute14               VARCHAR2,
                                x_attribute15               VARCHAR2,
                                x_basis_type                NUMBER,   --LBM enh
                                x_error_code                IN OUT NOCOPY NUMBER,
                                x_error_msg                 IN OUT NOCOPY VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
e_proc_exception    EXCEPTION;
x_rec               bom_sub_comps_interface%ROWTYPE;

e_comp_exception            EXCEPTION;
e_check_unique_exception    EXCEPTION;
e_check_common              EXCEPTION;
e_sub_comp_not_exists       EXCEPTION;
bom_dupl_comp_err           EXCEPTION;   -- abedajna

x_dummy                     NUMBER      := NULL;
x_co_prod_exists            NUMBER      := NULL;
x_comp_exists               NUMBER      := NULL;
x_component_sequence_id     NUMBER      := NULL;
x_bill_sequence_id          NUMBER      := NULL;
x_sub_rowid                 VARCHAR2(30):= NULL;
x_sub_comp_record           bom_substitute_components%ROWTYPE;
x_skip_sub_delete           NUMBER      := 0;

CURSOR S IS SELECT *
            FROM   wsm_co_prod_comp_substitutes
            WHERE  co_product_group_id = x_co_product_group_id;

CURSOR C (x_comp_seq_id NUMBER) IS SELECT rowid
            FROM   bom_substitute_components
            WHERE  component_sequence_id = x_comp_seq_id
            AND    substitute_component_id = x_substitute_comp_id_old
            FOR UPDATE OF substitute_component_id NOWAIT;

CURSOR C_COPROD IS SELECT component_sequence_id,
           bill_sequence_id
    FROM   wsm_co_products
    WHERE  co_product_group_id = x_co_product_group_id
    And    co_product_id is NOT NULL
    AND component_sequence_id IS NOT NULL;

BEGIN

    x_progress := '010';

    /* Verify if a co-product exists. */

    IF (x_process_code = 1) THEN /* Insert */

        BEGIN

-- modification begin for perf. tuning.. abedajna 10/12/00
            SELECT 1
            INTO   x_co_prod_exists
            FROM   wsm_co_products
            WHERE  co_product_group_id = x_co_product_group_id
            AND    co_product_id IS NOT NULL;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_co_prod_exists := 0;

            WHEN TOO_MANY_ROWS THEN
                x_co_prod_exists := 1;
-- modification end for perf. tuning.. abedajna 10/12/00
        END;

        x_progress := '020';

        IF (x_co_prod_exists = 0) THEN

            /* Insert into wsm_co_prod_comp_substitutes. */
            WSMPCPCS.insert_row (
                        x_rowid,
                        x_co_product_group_id,
                        x_substitute_component_id,
                        x_last_update_login,
                        x_last_updated_by,
                        x_last_update_date,
                        x_creation_date,
                        x_created_by,
                        x_substitute_item_quantity,
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        null,
                        null,
                        null,
                        null,
                        x_basis_type);       --LBM enh

            x_error_code := 0;
            return;

        END IF;
    END IF;

/*
 *  A bill most likely exists for this
 *  co-product relationship. Changes will
 *  have to be performed to both wsm_co_prod_comp_substitutes
 *  as well as bom_component_substitutes.
 */

/*
 *   Obtain the component information from the
 *   primary co-product.
 */
    x_progress := '030';



    /*coprod enh p2 introduced a loop that inserts  the substitutes for all the coproducts*/
FOR rec in C_COPROD LOOP

    /* Verify that the component exists in BOM. */

    x_progress := '040';


    BEGIN

        SELECT 1
        INTO   x_comp_exists
        FROM   bom_inventory_components
        WHERE  component_sequence_id = rec.component_sequence_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise e_comp_exception;
    END;

    IF (x_process_code = 1) THEN /* Insert */

        /* Check for uniqueness in bom_component_substitutes. */

        x_progress := '050';

        BEGIN

-- modification begin for perf. tuning.. abedajna 10/12/00

            x_dummy := 0;

            SELECT 1
            INTO   x_dummy
            FROM   bom_substitute_components
            WHERE  nvl(acd_type, 1) = 1
            AND    substitute_component_id = x_substitute_component_id
            AND    component_sequence_id = rec.component_sequence_id;

            IF x_dummy <> 0 THEN
                RAISE bom_dupl_comp_err;
            END IF;

        EXCEPTION

            WHEN bom_dupl_comp_err THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;

            WHEN NO_DATA_FOUND THEN
                NULL;

            WHEN TOO_MANY_ROWS THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;
-- modification end for perf. tuning.. abedajna 10/12/00

        END;

        /* Perform the check commons processing. */
        x_progress := '060';

        BEGIN

            SELECT 1
            INTO   x_dummy
            FROM   bom_bill_of_materials bbom
            WHERE  bbom.common_bill_sequence_id = rec.bill_sequence_id
            AND bbom.organization_id <> x_org_id
            AND NOT EXISTS (
                 SELECT null
                 FROM   mtl_system_items msi
                 WHERE  msi.organization_id = bbom.organization_id
                 AND    msi.inventory_item_id = x_substitute_component_id
                 AND    msi.bom_enabled_flag = 'Y'
                 AND    ((bbom.assembly_type = 1
                          AND msi.eng_item_flag = 'N')
                          OR (bbom.assembly_type = 2)));

            fnd_message.set_name('INV','INV_NOT_VALID');
            fnd_message.set_token('ENTITY','Substitute item', TRUE);
            raise e_check_common;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            null;
        END;

/*
     Insert into bom_substitute_components followed
     by an insert into wsm_co_prod_comp_substitutes.
*/
        x_progress := '070';
--LBM enh : Per Vani Hymavathi of BOM dev, we do not need to pass basis_type for processing substitute components
-- as Substitute components shall automaticaly inherit the basis type.

        bom_sub_comps_pkg.insert_row(x_sub_rowid,
                       x_substitute_component_id,
                       x_last_update_date,
                       x_last_updated_by,
                       x_creation_date,
                       x_created_by,
                       x_last_update_login,
                       x_substitute_item_quantity,
                       rec.component_sequence_id,
                       null,
                       null,
                       x_attribute_category,
                       x_attribute1,
                       x_attribute2,
                       x_attribute3,
                       x_attribute4,
                       x_attribute5,
                       x_attribute6,
                       x_attribute7,
                       x_attribute8,
                       x_attribute9,
                       x_attribute10,
                       x_attribute11,
                       x_attribute12,
                       x_attribute13,
                       x_attribute14,
                       x_attribute15);

    ELSIF (x_process_code = 2) THEN /* Update */

        IF (x_substitute_component_id <> x_substitute_comp_id_old) THEN

        /* Check that the new substitute component is unique. */

        x_progress := '080';

        BEGIN

    x_dummy := 0;

            SELECT 1
            INTO   x_dummy
            FROM   bom_substitute_components
            WHERE  nvl(acd_type, 1) = 1
            AND    substitute_component_id = x_substitute_component_id
            AND    component_sequence_id =rec.component_sequence_id;


            IF x_dummy <> 0 THEN
                RAISE bom_dupl_comp_err;
            END IF;

        EXCEPTION

            WHEN bom_dupl_comp_err THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;

            WHEN NO_DATA_FOUND THEN
                NULL;

            WHEN TOO_MANY_ROWS THEN
                fnd_message.set_name('BOM','BOM_DUPLICATE_SUB_COMP');
                raise e_check_unique_exception;

-- modification end for perf. tuning.. abedajna 10/12/00
        END;

        /* Perform the check commons processing.*/
        x_progress := '090';

        BEGIN

            SELECT 1
            INTO   x_dummy
            FROM   bom_bill_of_materials bbom
            WHERE  bbom.common_bill_sequence_id = rec.bill_sequence_id
            AND    bbom.organization_id <> x_org_id
            AND NOT EXISTS
                (SELECT null
                 FROM   mtl_system_items msi
                 WHERE  msi.organization_id = bbom.organization_id
                 AND    msi.inventory_item_id = x_substitute_component_id
                 AND    msi.bom_enabled_flag = 'Y'
                 AND    ((bbom.assembly_type = 1
                         AND msi.eng_item_flag = 'N')
                         OR (bbom.assembly_type = 2)));

           fnd_message.set_name('INV','INV_NOT_VALID');
           fnd_message.set_token('ENTITY','Substitute item', TRUE);
           raise e_check_common;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               null;
           END;
       END IF;

       /*
        * Lock record in bom_substitute_components
        * and perform the update.
        */

      OPEN C (rec.component_sequence_id);
      FETCH C  INTO x_sub_rowid;
        IF (C%NOTFOUND) THEN
          raise e_sub_comp_not_exists;
        END IF;
      CLOSE C;

      x_progress := '100';

      bom_sub_comps_pkg.update_row(x_sub_rowid,
                       x_substitute_component_id,
                       x_last_update_date,
                       x_last_updated_by,
                       x_last_update_login,
                       x_substitute_item_quantity,
                       rec.component_sequence_id,
                       null,
                       null,
                       x_attribute_category,
                       x_attribute1,
                       x_attribute2,
                       x_attribute3,
                       x_attribute4,
                       x_attribute5,
                       x_attribute6,
                       x_attribute7,
                       x_attribute8,
                       x_attribute9,
                       x_attribute10,
                       x_attribute11,
                       x_attribute12,
                       x_attribute13,
                       x_attribute14,
                       x_attribute15);



    ELSIF (x_process_code = 3) THEN /* Delete */

        /* Lock record in bom_substitute_components. */
        x_progress := '120';

        OPEN C (rec.component_sequence_id);
        FETCH C INTO x_sub_rowid;
        IF (C%NOTFOUND) THEN
             x_skip_sub_delete := 1;
        END IF;
        CLOSE C;

        IF (x_skip_sub_delete = 0) THEN
            bom_sub_comps_pkg.Delete_Row (x_sub_rowid);
        END IF;

--        WSMPCPCS.Delete_Row (x_rowid);

    END IF;
END LOOP;

    IF (x_process_code=1) then
            WSMPCPCS.insert_row (x_rowid,
                        x_co_product_group_id,
                        x_substitute_component_id,
                        x_last_update_login,
                        x_last_updated_by,
                        x_last_update_date,
                        x_creation_date,
                        x_created_by,
                        x_substitute_item_quantity,
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        null,
                        null,
                        null,
                        null,
                        x_basis_type);    --LBM enh

        x_error_code := 0;
        return;
   ELSIF (x_process_code=2) then
      x_progress := '110';

      WSMPCPCS.update_row(X_rowid,
                       x_co_product_group_id,
                       x_substitute_component_id,
                       x_last_update_login,
                       x_last_updated_by,
                       x_last_update_date,
                       x_substitute_item_quantity,
                       x_attribute_category,
                       x_attribute1,
                       x_attribute2,
                       x_attribute3,
                       x_attribute4,
                       x_attribute5,
                       x_attribute6,
                       x_attribute7,
                       x_attribute8,
                       x_attribute9,
                       x_attribute10,
                       x_attribute11,
                       x_attribute12,
                       x_attribute13,
                       x_attribute14,
                       x_attribute15,
                       null,
                       null,
                       null,
                       null,
                       x_basis_type);   --LBM enh
  ELSIF (x_process_code=3) then
        WSMPCPCS.Delete_Row (x_rowid);
   END IF;
    x_error_code := 0;

EXCEPTION
    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.insert_sub_comps('||x_progress||')';

    WHEN e_comp_exception THEN
        x_error_code := 1;
        fnd_message.set_name('WSM','WSM_MISSING_BOM_COMP');
        x_error_msg  := fnd_message.get;

    WHEN e_check_unique_exception THEN
        x_error_code := 2;
        x_error_msg  := fnd_message.get;

    WHEN e_check_common THEN
        x_error_code := 3;
        x_error_msg  := fnd_message.get;

    WHEN e_sub_comp_not_exists THEN
        x_error_code := 4;
        fnd_message.set_name('WSM','WSM_MISSING_SUBS_COMP');
        x_error_msg := fnd_message.get;

    WHEN app_exceptions.record_lock_exception THEN
        x_error_code := 5;
        fnd_message.set_name('WSM','WSM_SUBS_COMP_LOCK_ERR');
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.process_bom_sub_comp(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END process_bom_sub_comp;


/*===========================================================================
  PROCEDURE NAME:  val_co_product_details
  This is a wrapper routine that in turn calls val_co_product and val_add_to_bill.
  Bug# 1418668. Split the validation portion from procedure process_co_product
  so that co_product form can call this procedure to validate before warning
  the user that he/she is about to change the BOM.
===========================================================================*/

PROCEDURE val_co_product_details(
                             x_process_code     IN     NUMBER,
                             x_rowid            IN     VARCHAR2 DEFAULT NULL,
                             x_co_product_group_id IN  NUMBER   DEFAULT NULL,
                             x_usage            IN     NUMBER   DEFAULT NULL,
                             x_co_product_id    IN     NUMBER   DEFAULT NULL,
                             x_org_id           IN     NUMBER   DEFAULT NULL,
                             x_primary_flag     IN     VARCHAR2 DEFAULT NULL,
                             x_alternate_designator IN OUT NOCOPY VARCHAR2,
                             x_bill_sequence_id IN  OUT NOCOPY NUMBER,
                             x_effectivity_date IN      DATE     DEFAULT NULL,
                             x_disable_date     IN      DATE     DEFAULT NULL,
                             x_bill_insert      IN OUT NOCOPY  BOOLEAN,
                             x_p_bill_insert    IN OUT NOCOPY  BOOLEAN,
                             x_comp_insert      IN OUT NOCOPY  BOOLEAN,
                             x_p_comp_insert    IN OUT NOCOPY  BOOLEAN,
                             x_error_code       IN OUT NOCOPY  NUMBER,
                             x_error_msg        IN OUT NOCOPY  VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;
e_proc_exception         EXCEPTION;

x_quantity               NUMBER      := NULL;
x_existing_bom           NUMBER      := NULL;
x_bom_exists             NUMBER      := 0;
x_comm_bill_seq_id       NUMBER      := NULL;

BEGIN

    x_progress := '010';
    x_bill_insert   := FALSE;
    x_p_bill_insert := FALSE;
    x_comp_insert   := FALSE;
    x_p_comp_insert := FALSE;

    IF (x_process_code IN (1,2)) THEN
        x_quantity := x_usage;
    END IF;

    /* Cache org_id for use in this package. */
    g_org_id := x_org_id;

    /* Bug# 1418668. Commented the following line as the form will call this
       validation routine only if x_process_code=1
       IF (x_process_code = 1) THEN   */

    /*   Validate uniqueness of the co-product..  */

    x_progress := '020';

    WSMPVCPD.val_co_product (x_rowid,
                             x_co_product_group_id,
                             x_co_product_id,
                             x_error_code,
                             x_error_msg);

    IF (x_error_code >= 2) THEN
        return;
    ELSIF (x_error_code <> 0) THEN
        raise e_proc_exception;
    END IF;

    /*
    -- Verify if an alternate designator has been provided.
    -- If an alternate designator has been provided verify if there
    -- is a primary bill. If there is verify if the alternate bill
    -- already exists. If it does then verify whether you can
    -- add to the bill,if not return failure with a
    -- message. If the alternate bill does not exist create an
    -- alternate bill. If the primary does not exist, create the
    -- primary bill as well as the alternate bill. If an alternate
    -- designator has not been provided verify if there is a primary
    -- bill. If there is then verify whether you can add to the bill, if
    -- not, return failure with a message. If the primary bill does not exist
    -- create a primary bill. If this is a primary co-product insert
    -- a component for the bill.
    */

    IF (x_alternate_designator is NULL) THEN

        /* Verify if a primary bill exists. */

        x_progress := '030';

        BEGIN

           SELECT bbom.bill_sequence_id,
                  bbom.common_bill_sequence_id
           INTO   x_existing_bom,
                  x_comm_bill_seq_id
           FROM   bom_bill_of_materials bbom
           WHERE  bbom.assembly_item_id = x_co_product_id
           AND    bbom.organization_id = x_org_id
           AND    bbom.alternate_bom_designator is NULL;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (x_existing_bom is NOT NULL) THEN   /* Primary BOM exists */
            x_bill_sequence_id := x_existing_bom;
            IF (x_primary_flag = 'Y') THEN
                WSMPVCPD.val_add_to_bill (x_co_product_group_id,
                                          x_org_id,
                                          x_co_product_id,
                                          x_comm_bill_seq_id,
                                          x_existing_bom,
                                          x_effectivity_date,
                                          x_disable_date,
                                          x_alternate_designator,
                                          x_error_code,
                                          x_error_msg);

                IF (x_error_code > 0) THEN
                    return;
                ELSIF (x_error_code <> 0) THEN
                    raise e_proc_exception;
                END IF;

                x_comp_insert      := TRUE;
            END IF;
        ELSE         /* Primary BOM does not exist. */

            /* Create a Primary BOM */

            x_alternate_designator := NULL;
            x_bill_insert := TRUE;

            /*
            -- added by Bala.
            -- x_p_bill_insert := TRUE; -- Primary bill should be created.
            -- Later removed by raghu since we want x_bill_insert
            -- and not x_p_bill_insert.  x_p_bill_insert is only
            -- for cases where we are trying to insert an alt
            -- bill and the primary bill does not exist.
            */


            IF (x_primary_flag = 'Y') THEN
                x_comp_insert := TRUE;
            ELSE
                x_comp_insert := FALSE;
            END IF;
        END IF;

    ELSE

        /* Verify if the specified alternate bill exists. */

        BEGIN

            x_progress := '060';

            SELECT bbom.bill_sequence_id,
                   bbom.common_bill_sequence_id
            INTO   x_existing_bom,
                   x_comm_bill_seq_id
            FROM   bom_bill_of_materials bbom
            WHERE  bbom.assembly_item_id = x_co_product_id
            AND    bbom.organization_id  = x_org_id
            AND    bbom.alternate_bom_designator = x_alternate_designator;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (x_existing_bom is NOT NULL) THEN   /* Alternate BOM exists */
            x_bill_sequence_id := x_existing_bom;

            IF (x_primary_flag = 'Y') THEN

                WSMPVCPD.val_add_to_bill (x_co_product_group_id,
                                          x_org_id,
                                          x_co_product_id,
                                          x_comm_bill_seq_id,
                                          x_existing_bom,
                                          x_effectivity_date,
                                          x_disable_date,
                                          x_alternate_designator,
                                          x_error_code,
                                          x_error_msg);

                IF (x_error_code > 0) THEN
                    return;
                ELSIF (x_error_code <> 0) THEN
                    raise e_proc_exception;
                END IF;

                x_comp_insert      := TRUE;

            END IF;

        ELSE     /* Alternate BOM does not exist. */

            /* Verify if a primary bill exists. */

            BEGIN

                x_progress := '080';

-- commented out by abedajna on 10/12/00 for perf. tuning
/*
**              SELECT 1
**              INTO   x_bom_exists
**              FROM   sys.dual
**              WHERE  EXISTS (SELECT 1
**                             FROM   bom_bill_of_materials bbom
**                             WHERE  bbom.assembly_item_id = x_co_product_id
**                             AND    bbom.organization_id = x_org_id
**                             AND    bbom.alternate_bom_designator is NULL);
**          EXCEPTION
**              WHEN NO_DATA_FOUND THEN
**                  NULL;
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

                SELECT 1
                INTO   x_bom_exists
                FROM   bom_bill_of_materials bbom
                WHERE  bbom.assembly_item_id = x_co_product_id
                AND    bbom.organization_id = x_org_id
                AND    bbom.alternate_bom_designator is NULL;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN
                    NULL;

                WHEN TOO_MANY_ROWS THEN
                    x_bom_exists := 1;

-- modification end for perf. tuning.. abedajna 10/12/00

            END;

            IF (x_bom_exists = 1) THEN

                /* Create an alternate bill. */

                x_bill_insert := TRUE;

                IF (x_primary_flag = 'Y') THEN
                    x_comp_insert := TRUE;
                ELSE
                    x_comp_insert := FALSE;
                END IF;

            ELSE

                /* Create a primary bill followed by an alternate bill. */

                x_progress := '090';

                x_p_bill_insert := TRUE;
                x_bill_insert   := TRUE;
                x_p_comp_insert := FALSE;

                IF (x_primary_flag = 'Y') THEN
                    x_comp_insert := TRUE;
                ELSE
                    x_comp_insert := FALSE;
                END IF;
            END IF;

        END IF;

    END IF;

EXCEPTION
    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.val_co_product_details('||x_progress||')'||' - '||substr(sqlerrm,1,200);

     WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.val_co_product_details(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END val_co_product_details;

/*===========================================================================

  PROCEDURE NAME:   process_co_product
  Bug# 1418668. Removed the validation portion from procedure process_co_product
  and created the procedure val_co_product_details so that co_product form can call
  this the procedure to validate before warning the user that he/she is about
  to change the BOM.
===========================================================================*/

PROCEDURE process_co_product(x_process_code     IN     NUMBER,
                             x_rowid            IN     VARCHAR2 DEFAULT NULL,
                             x_co_product_group_id IN  NUMBER   DEFAULT NULL,
                             x_usage            IN     NUMBER   DEFAULT NULL,
                             x_duality_flag     IN     VARCHAR2 DEFAULT NULL,
                             x_planning_factor  IN     NUMBER   DEFAULT NULL,
                             x_component_yield_factor IN NUMBER DEFAULT NULL,
                             x_include_in_cost_rollup IN NUMBER DEFAULT NULL,
                             x_wip_supply_type  IN     NUMBER   DEFAULT NULL,
                             x_supply_subinventory IN  VARCHAR2 DEFAULT NULL,
                             x_supply_locator_id IN    NUMBER   DEFAULT NULL,
                             x_supply_locator    IN    VARCHAR2 DEFAULT NULL,
                             x_component_remarks IN    VARCHAR2 DEFAULT NULL,
                             x_split            IN     NUMBER   DEFAULT NULL,
                             x_created_by       IN     NUMBER   DEFAULT NULL,
                             x_login_id         IN     NUMBER   DEFAULT NULL,
                             x_co_product_id    IN     NUMBER   DEFAULT NULL,
                             x_co_product_name  IN     VARCHAR2 DEFAULT NULL,
                             x_revision         IN     VARCHAR2 DEFAULT NULL,
                             x_org_id           IN     NUMBER   DEFAULT NULL,
                             x_org_code         IN     VARCHAR2 DEFAULT NULL,
                             x_primary_flag     IN     VARCHAR2 DEFAULT NULL,
                             x_alternate_designator IN OUT NOCOPY VARCHAR2,
                             x_component_id     IN     NUMBER   DEFAULT NULL,
                             x_component_name   IN     VARCHAR2 DEFAULT NULL,
                             x_bill_sequence_id IN  OUT NOCOPY NUMBER,
                             x_component_sequence_id IN OUT NOCOPY NUMBER,
                             x_effectivity_date IN     DATE     DEFAULT NULL,
                             x_disable_date     IN     DATE     DEFAULT NULL,
                             x_bill_insert      IN    BOOLEAN DEFAULT FALSE,
                             x_p_bill_insert    IN    BOOLEAN DEFAULT FALSE,
                             x_comp_insert      IN    BOOLEAN DEFAULT FALSE,
                             x_p_comp_insert    IN    BOOLEAN DEFAULT FALSE,
                             x_basis_type       IN       NUMBER   ,    --LBM enh
                             x_coprod_attribute_category VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute1         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute2         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute3         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute4         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute5         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute6         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute7         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute8         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute9         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute10        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute11        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute12        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute13        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute14        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute15        VARCHAR2 DEFAULT NULL,
                             x_comp_attribute_category   VARCHAR2 DEFAULT NULL,
                             x_comp_attribute1           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute2           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute3           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute4           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute5           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute6           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute7           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute8           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute9           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute10          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute11          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute12          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute13          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute14          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute15          VARCHAR2 DEFAULT NULL,
                             x_error_code       IN OUT NOCOPY NUMBER,
                             x_error_msg        IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;
e_proc_exception         EXCEPTION;
e_val_exception          EXCEPTION;
e_alt_val_exception      EXCEPTION;
e_no_bill_seq_exception  EXCEPTION;
e_no_comp_seq_exception  EXCEPTION;

x_p_bill_sequence_id     NUMBER      := NULL;
x_p_component_sequence_id NUMBER     := NULL;
x_quantity               NUMBER      := NULL;
x_existing_bom           NUMBER      := NULL;
x_bom_exists             NUMBER      := 0;
x_alt_bom_exists         NUMBER      := 0;
x_comm_bill_seq_id       NUMBER      := NULL;
x_active_link            NUMBER      := NULL;
x_dummy                  NUMBER      := NULL;
x_rec                    bom_bill_of_mtls_interface%ROWTYPE;
x_rec_comp               bom_inventory_comps_interface%ROWTYPE;
l_err_text               VARCHAR2(200);
--bug 2987645
l_effectivity_date      DATE;
--end bug 2987645

/* Bug# 1418668.  Commented the cursor as it is not used any where
CURSOR C (x_bill_seq_id NUMBER)IS
         SELECT  1
         FROM    sys.dual
         WHERE   EXISTS (SELECT 1
                         FROM   bom_inventory_components bic
                         WHERE  bic.bill_sequence_id = x_bill_seq_id
                         AND    (x_disable_date is NULL
                                 OR (trunc(x_disable_date) > trunc(bic.effectivity_date)))
                         AND    ((trunc(x_effectivity_date) < trunc(bic.disable_date))
                                 OR bic.disable_date is NULL)); */
BEGIN

    x_progress := '010';

    IF (x_process_code IN (1,2)) THEN
        x_quantity := x_usage;
    END IF;

    /* Cache org_id for use in this package. */
    g_org_id := x_org_id;

    IF (x_process_code = 1) THEN

    /* Obtain the sequence ids. */
     --  This part will be commented out since if we are using
     --  the bom bo api,  the sequence ids cannot be passed in
     --  rather we should call these later to obtain the sequence
     --  ids that are created

        /******************************
        IF (x_p_bill_insert) THEN
            WSMPCOGI.get_bill_comp_sequence (x_p_bill_sequence_id,
                                             x_error_code,
                                             x_error_msg);
            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;
        END IF;

        IF (x_p_comp_insert) THEN
            WSMPCOGI.get_bill_comp_sequence (x_p_component_sequence_id,
                                             x_error_code,
                                             x_error_msg);
            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;
        END IF;

        IF (x_bill_insert) THEN
            WSMPCOGI.get_bill_comp_sequence (x_bill_sequence_id,
                                             x_error_code,
                                             x_error_msg);
            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;
        END IF;

        IF (x_comp_insert) THEN
            WSMPCOGI.get_bill_comp_sequence (x_component_sequence_id,
                                             x_error_code,
                                             x_error_msg);
            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;
        END IF;
        ***************************/

        IF (x_p_bill_insert) THEN
            x_rec.assembly_item_id := x_co_product_id;
            x_rec.organization_id  := x_org_id;
            x_rec.assembly_type    := 1  /* Manufacturing */;
            x_rec.alternate_bom_designator  := null;
            x_rec.revision               := x_revision;
            x_rec.attribute_category := x_coprod_attribute_category;
            x_rec.attribute1         := x_coprod_attribute1;
            x_rec.attribute2         := x_coprod_attribute2;
            x_rec.attribute3         := x_coprod_attribute3;
            x_rec.attribute4         := x_coprod_attribute4;
            x_rec.attribute5         := x_coprod_attribute5;
            x_rec.attribute6         := x_coprod_attribute6;
            x_rec.attribute7         := x_coprod_attribute7;
            x_rec.attribute8         := x_coprod_attribute8;
            x_rec.attribute9         := x_coprod_attribute9;
            x_rec.attribute10        := x_coprod_attribute10;
            x_rec.attribute11        := x_coprod_attribute11;
            x_rec.attribute12        := x_coprod_attribute12;
            x_rec.attribute13        := x_coprod_attribute13;
            x_rec.attribute14        := x_coprod_attribute14;
            x_rec.attribute15        := x_coprod_attribute15;

            x_progress := '100';

            WSMPPCPD.insert_bill ( x_rec,
                                   x_co_product_name,
                                   x_org_code,
                                   x_error_code,
                                   x_error_msg);

            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;

            -- now go ahead and call the BOM Business Object API
            -- to insert this primary bill

            WSMPPCPD.call_bom_bo_api (
                p_bom_header_rec  =>  g_bom_header_rec,
                x_error_code      => x_error_code,
                x_error_msg       => x_error_msg );

            IF x_error_code <> 0  THEN
                raise e_proc_exception;
            END IF;

            x_progress := '105';

            -- initialize parameters passed to the bom bo api

            g_bom_header_rec := Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
            g_component_tbl.delete;
            g_component_tbl := Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
            /*coprod enh p2*/
--if ((g_subs_rec_set IS NULL) OR (g_subs_rec_set <> 'Y')) then
            g_subs_comp_tbl.delete;
            g_subs_comp_tbl := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
--  end if;
     /*end coprod enh p2*/

        END IF;


        /*
        if we are creating the bill with the alternate_designator as
        specified in the Co-Products form, then we are better off creating
        the Bill object in its entirety - ie, a Bill Header, Component and
        any substitute component.  What we did in the previous insert was
        just creating a Primary Bill for the sake of being able to create
        the alternate bill (designator) that was specified in the co-products
        form.  So in this case we will not call the bom bo api till the entire
        object has been prepared.
        */

        IF (x_bill_insert) THEN
            x_rec.assembly_item_id := x_co_product_id;
            x_rec.organization_id  := x_org_id;
            x_rec.assembly_type    := 1  /* Manufacturing */;
            x_rec.alternate_bom_designator  := x_alternate_designator;
            x_rec.revision               := x_revision;
            x_rec.attribute_category := x_coprod_attribute_category;
            x_rec.attribute1         := x_coprod_attribute1;
            x_rec.attribute2         := x_coprod_attribute2;
            x_rec.attribute3         := x_coprod_attribute3;
            x_rec.attribute4         := x_coprod_attribute4;
            x_rec.attribute5         := x_coprod_attribute5;
            x_rec.attribute6         := x_coprod_attribute6;
            x_rec.attribute7         := x_coprod_attribute7;
            x_rec.attribute8         := x_coprod_attribute8;
            x_rec.attribute9         := x_coprod_attribute9;
            x_rec.attribute10        := x_coprod_attribute10;
            x_rec.attribute11        := x_coprod_attribute11;
            x_rec.attribute12        := x_coprod_attribute12;
            x_rec.attribute13        := x_coprod_attribute13;
            x_rec.attribute14        := x_coprod_attribute14;
            x_rec.attribute15        := x_coprod_attribute15;

            x_progress := '110';

            WSMPPCPD.insert_bill ( x_rec,
                                   x_co_product_name,
                                   x_org_code,
                                   x_error_code,
                                   x_error_msg);

            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;

        END IF; -- End of x_bill_insert

--bug 2987645
            IF x_effectivity_date < sysdate THEN
                l_effectivity_date := sysdate;
            ELSE
                l_effectivity_date := x_effectivity_date;
            END IF;
--end bug 2987645

        IF (x_comp_insert) THEN

            x_rec_comp.alternate_bom_designator  := x_alternate_designator;
            x_rec_comp.planning_factor           := x_planning_factor;
            x_rec_comp.component_yield_factor    := x_component_yield_factor;
            x_rec_comp.include_in_cost_rollup    := x_include_in_cost_rollup;
            x_rec_comp.wip_supply_type           := x_wip_supply_type;
            x_rec_comp.supply_subinventory       := x_supply_subinventory;
            x_rec_comp.supply_locator_id         := x_supply_locator_id;
            x_rec_comp.component_remarks         := x_component_remarks;
            x_rec_comp.operation_seq_num := 1;
            x_rec_comp.component_item_id := x_component_id;
            x_rec_comp.component_quantity  := x_quantity;
--bug 2987645
--          x_rec_comp.effectivity_date    := x_effectivity_date;
            x_rec_comp.effectivity_date    := l_effectivity_date;
--end bug 2987645
            x_rec_comp.disable_date           := x_disable_date;
            x_rec_comp.assembly_item_id    := x_co_product_id;
            x_rec_comp.process_flag           := 1;
            x_rec_comp.organization_id     := x_org_id;
            x_rec_comp.basis_type          := x_basis_type;   --LBM enh
            x_rec_comp.attribute_category := x_comp_attribute_category;
            x_rec_comp.attribute1         := x_comp_attribute1;
            x_rec_comp.attribute2         := x_comp_attribute2;
            x_rec_comp.attribute3         := x_comp_attribute3;
            x_rec_comp.attribute4         := x_comp_attribute4;
            x_rec_comp.attribute5         := x_comp_attribute5;
            x_rec_comp.attribute6         := x_comp_attribute6;
            x_rec_comp.attribute7         := x_comp_attribute7;
            x_rec_comp.attribute8         := x_comp_attribute8;
            x_rec_comp.attribute9         := x_comp_attribute9;
            x_rec_comp.attribute10        := x_comp_attribute10;
            x_rec_comp.attribute11        := x_comp_attribute11;
            x_rec_comp.attribute12        := x_comp_attribute12;
            x_rec_comp.attribute13        := x_comp_attribute13;
            x_rec_comp.attribute14        := x_comp_attribute14;
            x_rec_comp.attribute15        := x_comp_attribute15;

            x_progress := '120';


            WSMPPCPD.insert_component ( x_rec_comp,
                                        x_component_name,
                                        x_org_code,
                                        x_co_product_name,
                                        x_supply_locator,
                                        x_error_code,
                                        x_error_msg);
            IF (x_error_code <> 0) THEN
                raise e_proc_exception;
            END IF;

            /* Insert substitutes. */

            WSMPPCPD.insert_sub_comps (x_co_product_group_id,
                                       x_co_product_name,
                                       x_alternate_designator,
                                       x_component_name,
--bug 2987645
--                                     x_effectivity_date,
                                       l_effectivity_date,
--end bug 2987645
                                       x_org_code,
                                       x_component_sequence_id,
                                       x_quantity,
                                       x_error_code,
                                       x_error_msg);

            IF (x_error_code < 0) THEN
                raise e_proc_exception;
            ELSIF (x_error_code > 0) THEN
                return;
            END IF;

        END IF; -- End of x_comp_insert

        -- now go ahead and call the BOM Business Object API
        -- to insert the bill header, component and any substitute
        -- components

        x_progress := '123';

        -- Debug code insert by Bala.
        -- Start

        If x_bill_insert AND (x_comp_insert <> TRUE) Then

                WSMPPCPD.call_bom_bo_api (
                p_bom_header_rec  =>  g_bom_header_rec,
                x_error_code => x_error_code,
                x_error_msg  => x_error_msg );

        End If;

        IF x_error_code <> 0  THEN
                raise e_proc_exception;
        END IF;

        x_progress := '124';
        -- If x_bill_insert AND x_comp_insert Then  /* defensive check for bill */
        /*
        ** Line above commented out by Bala, July20th, 2000.
        **
        ** Bug# 1359564 - where there can be a situation where a component
        ** need to be created even if the bill header is not created (but
        ** might already be existing because of ALT_DESIGNATOR being created)
        **
        ** Scenario: No coprod defintion exist for coprodA as primary coprod.
        **
        ** coprod defintion: comp1-ALT1-coprodA.(alt designator is ALT1)
        ** This will create a primary BOM for coprodA with nocomponent.
        ** - ALTBILL for coprodA with ALT1 with component comp1.
        **
        ** Now if you again try to define a coproduct definiton as follows;
        ** comp2-NULL-coprodA (where the alternate designator is NULL).
        ** Now this will findout that the primary bill exists and hence
        ** will not create primary bill (x_bill_insert = FALSE).
        ** But still we need to create the component definiton and hence
        ** we need to check only for x_comp_insert = TRUE and not both.
        **
        ** - Bala BALAKUMAR, July 20th, 2000.
        */

        If x_comp_insert Then  /*Bug#1359654 fix */

                WSMPPCPD.call_bom_bo_api (
                p_bom_header_rec  =>  g_bom_header_rec,
                p_component_tbl  =>  g_component_tbl,
                p_subs_comp_tbl  =>  g_subs_comp_tbl,
                x_error_code => x_error_code,
                x_error_msg  => x_error_msg );

        End If;

        IF x_error_code <> 0  THEN
                raise e_proc_exception;
        END IF;

        -- End of Debug code test.


        -- initialize parameters passed to the bom bo api
        g_bom_header_rec := Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
        g_component_tbl.delete;
        g_component_tbl := Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
/*coprod enh p2*/
--if ((g_subs_rec_set IS NULL) OR (g_subs_rec_set <> 'Y')) then
        g_subs_comp_tbl.delete;
        g_subs_comp_tbl := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
--end if;
/*end coprod enh p2*/

        -- now call a private bom api to obtain the bill_sequence_id and
        -- the component_sequence_id

        x_progress := '125';

        x_bill_sequence_id := BOM_Val_To_Id.Bill_Sequence_Id (
                        p_assembly_item_id => x_co_product_id,
                        p_alternate_bom_code => x_alternate_designator,
                        p_organization_id => x_org_id,
                        x_err_text => l_err_text );

        IF x_bill_sequence_id is NULL THEN
            -- x_error_msg := 'Unable to obtain Bill_Sequence_Id';
            fnd_message.set_name('WSM', 'WSM_NO_BILL_SEQ_ID');
            raise e_no_bill_seq_exception;
        END IF;

        x_progress := '126';

        -- Added By Bala.
        -- Need to be performed only when inserting a component.

        If x_comp_insert Then
                IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        DECLARE
                                l_comp_eff_date DATE;
                        BEGIN
                                select bic.effectivity_date
                                into   l_comp_eff_date
                                from   bom_inventory_components bic,
                                        bom_bill_of_materials bom
                                where  bom.bill_sequence_id = x_bill_sequence_id
                                and    bic.bill_sequence_id = bom.common_bill_sequence_id
                                and    bic.component_item_id = x_component_id
                                and    bic.operation_seq_num = 1;

                                FND_LOG.STRING(FND_LOG.LEVEL_EVENT, 'wsm%',
                                                'component effectivity date = '||to_char(l_comp_eff_date, 'DD-MON-YYYY HH24:MI:SS')||
                                                ' x_component_id = '||x_component_id||
                                                ' l_effectivity_date = '||to_char(l_effectivity_date, 'DD-MON-YYYY HH24:MI:SS')||
                                                ' x_bill_sequence_id = '||x_bill_sequence_id);
                        EXCEPTION
                                WHEN no_data_found THEN
                                        FND_LOG.STRING(FND_LOG.LEVEL_EVENT, 'wsm%',
                                                'no_data_found ');
                                WHEN too_many_rows THEN
                                        null;
                        END;
                END IF;
                x_component_sequence_id := WSMPCOGI.Get_Component_Sequence_Id (
                        p_component_item_id => x_component_id,
                        p_operation_sequence_num => 1,
--bug 2987645
--                      p_effectivity_date => x_effectivity_date,
                        p_effectivity_date => l_effectivity_date,
--end bug 2987645
                        p_bill_sequence_id => x_bill_sequence_id,
                        x_err_text => l_err_text );

                IF x_component_sequence_id is NULL THEN
                        -- x_error_msg := l_err_text ||'- Unable to obtain Component_Sequence_Id';
                        /*
                        x_error_msg := l_err_text ||
                        'comp_id is '|| x_component_id ||
                        '; opseqnum is 1' ||
                        '; effectivity date is '|| x_effectivity_date ||
                        '; from bill seq Id is '|| x_bill_sequence_id ||
                        '; for co-product Id  '|| x_co_product_id ||
                        '; - Unable to obtain Component_Sequence_Id';
                        raise e_proc_exception;
                        */

                        fnd_message.set_name('WSM', 'WSM_NO_COMP_SEQ_ID');
                        raise e_no_comp_seq_exception;
                END IF;

        End If; -- End of getCompseqId if x_comp_insert is True.

        /* Call BOM api to process interface. */

        /*******
           This call will be commented out since we need to use the
           BOM Business Object API for 11.i.2 instead of the Open Interface

        x_progress := '140';

        x_error_code := bompopif.bmopinp_open_interface_process (org_id       => x_org_id,
                                     all_org      => 2,
                                     val_rtg_flag => 2,
                                     val_bom_flag => 1,
                                     pro_rtg_flag => 2,
                                     pro_bom_flag => 1,
                                     del_rec_flag => 1,
                                     prog_appid   => -1,
                                     prog_id      => -1,
                                     request_id   => -1,
                                     user_id      => x_created_by,
                                     login_id     => x_login_id,
                                     err_text     => x_error_msg);

        IF (x_error_code <> 0) THEN
            raise e_proc_exception;
        END IF;

        *******/

    ELSIF (x_process_code = 2) THEN

        /* For Update
           Bill attribute columns are not being updated
           based on discussion with B. Arvindh (02/09/98)
           Update component columns. */

        x_progress := '150';

        /* Lock corresponding component prior to update. */

        WSMPPCPD.lock_component(x_component_sequence_id,
                                x_error_code,
                                x_error_msg);

        IF (x_error_code > 0) THEN
            return;
        ELSIF (x_error_code < 0) THEN
            raise e_proc_exception;
        END IF;

        /*
        ** This is the SQL we have to add the columns
        ** to update the component details on update mode.
        ** Bala
        */

        UPDATE bom_inventory_components
        SET    component_quantity = x_quantity,
               basis_type         = decode(x_basis_type, 2, 2, null),       --LBM enh
               disable_date       = x_disable_date,
               effectivity_date   = x_effectivity_date,
               attribute_category = x_comp_attribute_category,
               attribute1         = x_comp_attribute1,
               attribute2         = x_comp_attribute2,
               attribute3         = x_comp_attribute3,
               attribute4         = x_comp_attribute4,
               attribute5         = x_comp_attribute5,
               attribute6         = x_comp_attribute6,
               attribute7         = x_comp_attribute7,
               attribute8         = x_comp_attribute8,
               attribute9         = x_comp_attribute9,
               attribute10        = x_comp_attribute10,
               attribute11        = x_comp_attribute11,
               attribute12        = x_comp_attribute12,
               attribute13        = x_comp_attribute13,
               attribute14        = x_comp_attribute14,
               attribute15        = x_comp_attribute15
        WHERE  common_component_sequence_id = x_component_sequence_id
		OR     component_sequence_id = x_component_sequence_id;
		/* Modified where clause for bug 5519205.
		   Use OR instead of nvl so that the query is performant. */

    ELSIF (x_process_code = 3) THEN

        /*
        -- For Deletes...
        -- Call routine to update the disable date
        -- for the component on the BOM for the co-product's.
        -- appropriate bill.
        */

        /* Lock corresponding component prior to update. */

        WSMPPCPD.lock_component (x_component_sequence_id,
                                 x_error_code,
                                 x_error_msg);

        IF (x_error_code > 0) THEN
            return;
        ELSIF (x_error_code < 0) THEN
            raise e_proc_exception;
        END IF;

        UPDATE bom_inventory_components
        SET    disable_date = sysdate
        WHERE  component_sequence_id  = x_component_sequence_id;

    END IF;

    /*******  Commenting this out since set_common_bill_new will not do the job

    IF (x_process_code = 1) THEN

        -- Call routine to update the common bill
        -- information.

        x_progress := '160';

        WSMPPCPD.set_common_bill (x_co_product_group_id,
                                  x_org_id,
                                  x_co_product_id,
                                  x_bill_sequence_id,
                                  x_component_sequence_id,
                                  x_primary_flag,
                                  x_error_code,
                                  x_error_msg);
        IF (x_error_code = 2) THEN
            return;
        ELSIF (x_error_code <> 0) THEN
            raise e_proc_exception;
        END IF;
    END IF;
    *******/

  x_error_code := 0;

EXCEPTION

    WHEN e_no_bill_seq_exception THEN
        x_error_code := -901;
        x_error_msg := fnd_message.get;

    WHEN e_no_comp_seq_exception THEN
        x_error_code := -902;
        x_error_msg := fnd_message.get;

     WHEN e_proc_exception  THEN
        --x_error_code := -900; -- removed by raghu since we need the
                                -- error code from call_bom_bo_api
                                -- for error handling
        -- added by Bala.
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.process_co_product('||x_progress||')'||' - '||substr(sqlerrm,1,200);

     WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.process_co_product(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END process_co_product;


/*===========================================================================

  PROCEDURE NAME:       set_common_bill

===========================================================================*/

PROCEDURE set_common_bill ( x_co_product_group_id        IN     NUMBER,
                            x_org_id                     IN     NUMBER,
                            x_co_product_id              IN     NUMBER,
                            x_bill_sequence_id           IN     NUMBER,
                            x_component_sequence_id      IN     NUMBER,
                            x_primary_flag               IN     VARCHAR2,
                            x_error_code                 IN OUT NOCOPY NUMBER,
                            x_error_msg                  IN OUT NOCOPY VARCHAR2) IS

x_progress          VARCHAR2(3) := NULL;
e_set_common_bill   EXCEPTION;
e_components_exist  EXCEPTION;
e_c_bill_exists     EXCEPTION;
e_proc_exception    EXCEPTION;

x_c_org_id          NUMBER      := NULL;
x_c_assembly_id     NUMBER      := NULL;
x_c_bill_seq_id     NUMBER      := NULL;
x_count_comp        NUMBER      := 0;
x_current_comm_bill NUMBER      := NULL;

CURSOR S IS
         SELECT bcp.bill_sequence_id
         FROM   wsm_co_products bcp
         WHERE  bcp.co_product_group_id = x_co_product_group_id
         AND    bcp.bill_sequence_id   <> x_bill_sequence_id
         AND    bcp.co_product_id  is NOT NULL;

BEGIN

    x_progress := '010';

    /*
    -- If this is the bill corresponding
    -- to the primary co-product then update
    -- the other co-product's bills to point
    -- to this bill. Since this processing is done
    -- prior to the insert, the bill information is
    -- obtained from the BOM tables.
    */

    IF (nvl(x_primary_flag, 'N') = 'Y') THEN

        x_c_bill_seq_id := x_bill_sequence_id;
        x_c_org_id      := x_org_id;
        x_c_assembly_id := x_co_product_id;

        FOR S_rec IN S LOOP

            x_progress := '020';

            /*
            -- Verify that there aren't any
            -- components for the bill. */

            SELECT count (1)
            INTO   x_count_comp
            FROM   bom_inventory_components
            WHERE  bill_sequence_id = S_rec.bill_sequence_id;

            IF (x_count_comp = 1) THEN
                raise e_components_exist;
            END IF;

            /* Verify that the component does not
            -- point to any bill other than the bill it is being
            -- updated to point to. */

            BEGIN

                x_progress := '030';

                SELECT bbom.common_bill_sequence_id
                INTO   x_current_comm_bill
                FROM   bom_bill_of_materials bbom
                WHERE  bbom.bill_sequence_id = S_rec.bill_sequence_id
                AND    EXISTS (SELECT 1
                               FROM   wsm_co_products bcp
                               WHERE  bcp.bill_sequence_id = bbom.common_bill_sequence_id
                               AND    (bcp.disable_date is NULL
                                       OR bcp.disable_date > sysdate)
                               AND    bcp.co_product_group_id <> x_co_product_group_id);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;

            IF ((x_current_comm_bill is NOT NULL) AND
                (x_current_comm_bill <> x_c_bill_seq_id)) THEN
              raise e_c_bill_exists;
            END IF;

            x_progress := '040';

            /* -- Lock corresponding bill prior to update. */

            WSMPPCPD.lock_bill (S_rec.bill_sequence_id,
                                x_error_code,
                                x_error_msg);

            IF (x_error_code > 0) THEN
                return;
            ELSIF (x_error_code < 0) THEN
                raise e_proc_exception;
            END IF;

            UPDATE bom_bill_of_materials
            SET    common_assembly_item_id = x_c_assembly_id,
                   common_organization_id  = x_c_org_id,
                   common_bill_sequence_id = x_c_bill_seq_id
            WHERE  bill_sequence_id = S_rec.bill_sequence_id;

        END LOOP;

    ELSE

        /*
        -- Obtain the bill_sequence_id of the
        -- primary co-product and update the current
        -- bill.
        */

        x_progress := '050';

        BEGIN

            SELECT bcp.bill_sequence_id,
                   bcp.organization_id,
                   bcp.co_product_id
            INTO   x_c_bill_seq_id,
                   x_c_org_id,
                   x_c_assembly_id
            FROM   wsm_co_products bcp
            WHERE  bcp.co_product_group_id = x_co_product_group_id
            AND    bcp.primary_flag            = 'Y'
            AND    rownum = 1;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            x_error_code := 0;
            return;
        END;

        /*
        -- Verify that there aren't any
        -- components for the bill.
        */

        x_progress := '060';

        SELECT count(*)
        INTO   x_count_comp
        FROM   bom_inventory_components
        WHERE  bill_sequence_id = x_bill_sequence_id;

        IF (x_count_comp = 1) THEN
            raise e_components_exist;
        END IF;

        /*
        -- Verify that the component does not
        -- point to any bill other than the bill it is being
        -- updated to point to.
        */

        BEGIN

            x_progress := '070';

            SELECT bbom.common_bill_sequence_id
            INTO   x_current_comm_bill
            FROM   bom_bill_of_materials bbom
            WHERE  bbom.bill_sequence_id = x_bill_sequence_id
            AND    EXISTS (SELECT 1
                           FROM   wsm_co_products bcp
                           WHERE  bcp.bill_sequence_id = bbom.common_bill_sequence_id
                           AND    (   bcp.disable_date is NULL
                                   OR bcp.disable_date > sysdate)
                           AND    bcp.co_product_group_id <> x_co_product_group_id);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF ((x_current_comm_bill is NOT NULL) AND
            (x_current_comm_bill <> x_c_bill_seq_id)) THEN
            raise e_c_bill_exists;
        END IF;

        IF (x_current_comm_bill is NULL) THEN
            x_progress := '080';

         /* -- Lock corresponding bill prior to update. */

            WSMPPCPD.lock_bill (x_bill_sequence_id,
                                x_error_code,
                                x_error_msg);

            IF (x_error_code > 0) THEN
                return;
            ELSIF (x_error_code < 0) THEN
                raise e_proc_exception;
            END IF;

            UPDATE bom_bill_of_materials
            SET    common_assembly_item_id = x_c_assembly_id,
                   common_organization_id  = x_c_org_id,
                   common_bill_sequence_id = x_c_bill_seq_id
            WHERE  bill_sequence_id        = x_bill_sequence_id;

        END IF;
    END IF;

    x_error_code := 0;

EXCEPTION
    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.set_common_bill('||x_progress||')';

    WHEN e_c_bill_exists THEN
        x_error_code := 3;
        -- x_error_msg  := 'Cannot update bill. It currently points to another common bill.';
        fnd_message.set_name('WSM', 'WSM_NO_BILL_UPDATE');
        x_error_msg := fnd_message.get;

    WHEN e_components_exist THEN
        x_error_code := 2;
        -- x_error_msg  := 'Components exist on this bill. Cannot set common bill.';
        fnd_message.set_name('WSM', 'WSM_BILL_COMPONENT_EXIST');
        x_error_msg := fnd_message.get;

    WHEN e_set_common_bill THEN
        x_error_code := 1;
        -- x_error_msg  := 'Insufficient arguments to WSMPPCPD.set_common_bill';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.set_common_bill');
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.set_common_bill(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END set_common_bill;

/* ===========================================================================

  PROCEDURE NAME:   delete_component

=========================================================================== */

PROCEDURE delete_component(x_co_product_group_id IN     NUMBER,
                           x_rowid               IN     VARCHAR2,
                           x_error_code          IN OUT NOCOPY NUMBER,
                           x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;
e_proc_exception         EXCEPTION;
e_delete_component       EXCEPTION;

CURSOR C IS
         SELECT rowid
         FROM   wsm_co_prod_comp_substitutes
         WHERE  co_product_group_id = x_co_product_group_id;

CURSOR S IS
         SELECT bcp.co_product_id
         FROM   wsm_co_products bcp
         WHERE  bcp.co_product_group_id = x_co_product_group_id
         AND    bcp.co_product_id is NOT NULL;

BEGIN

    x_progress := '010';

    IF (x_co_product_group_id IS NULL) THEN
        raise e_delete_component;
    END IF;

    /*  -- Delete all the co-products. */

    x_progress := '020';

    FOR S_rec IN S LOOP

        WSMPPCPD.delete_co_product (x_co_product_group_id,
                                    S_rec.co_product_id,
                                    x_error_code,
                                    x_error_msg);

        IF (x_error_code = 5) THEN
            return;
        ELSIF (x_error_code <> 0) THEN
            raise e_proc_exception;
        END IF;
    END LOOP;

    /*  -- Delete all the substitutes. */

    x_progress := '033';

    FOR C_rec IN C LOOP
        WSMPCPCS.delete_row (C_rec.rowid);
    END LOOP;

    x_progress := '040';

    WSMPCPDS.delete_row (x_rowid);

    x_error_code := 0;

EXCEPTION
    WHEN e_delete_component THEN
        x_error_code := 1;
        -- x_error_msg  := 'Insufficient arguments to WSMPPCPD.delete_component';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.delete_component');
        x_error_msg := fnd_message.get;

    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.delete_component('||x_progress||')';

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.delete_component(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END delete_component;


/* ===========================================================================

  PROCEDURE NAME:   delete_co_product

=========================================================================== */

PROCEDURE delete_co_product(x_co_product_group_id IN     NUMBER,
                           x_co_product_id        IN     NUMBER,
                           x_error_code          IN OUT NOCOPY NUMBER,
                           x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;
e_proc_exception         EXCEPTION;
e_delete_co_product      EXCEPTION;
x_component_sequence_id  NUMBER      := NULL;
x_effectivity_date       DATE;
x_rowid                  VARCHAR2(20):= NULL;
x_component_id           NUMBER      := NULL;
x_alternate              VARCHAR2(10):= NULL;
x_bill_sequence_id       NUMBER      := NULL;
x_primary_flag          VARCHAR2(1) := 'N';

BEGIN

    x_progress := '010';

    IF ((x_co_product_group_id IS NULL) OR
        (x_co_product_id IS NULL))  THEN
      raise e_delete_co_product;
    END IF;

    /*  -- Obtain information from wsm_co_products. */

    x_progress := '020';
    /******
    SELECT bcp.component_sequence_id,
           bcp.component_id,
           bcp.effectivity_date,
           bcp.rowid
    INTO   x_component_sequence_id,
           x_component_id,
           x_effectivity_date,
           x_rowid
    FROM   wsm_co_products bcp
    WHERE  bcp.co_product_group_id = x_co_product_group_id
    AND    bcp.co_product_id       = x_co_product_id;
    ******/

    SELECT bcp.component_id,
           bcp.effectivity_date,
           bcp.bill_sequence_id,
           bcp.primary_flag,
           bcp.rowid
    INTO   x_component_id,
           x_effectivity_date,
           x_bill_sequence_id,
           x_primary_flag,
           x_rowid
    FROM   wsm_co_products bcp
    WHERE  bcp.co_product_group_id = x_co_product_group_id
    AND    bcp.co_product_id       = x_co_product_id;

    /*  -- Update bill. */

    x_progress := '030';

    /*******
    -- commented out by Bala on June 23rd, 2000.

    WSMPPCPD.process_co_product (x_process_code     => 3,
                            x_bill_sequence_id => x_bill_sequence_id,
                            x_component_sequence_id => x_component_sequence_id,
                            x_alternate_designator => x_alternate,
                            x_error_code       => x_error_code,
                            x_error_msg        => x_error_msg);

    IF (x_error_code = 5) THEN
        return;
    ELSIF (x_error_code <> 0) THEN
        raise e_proc_exception;
    END IF;
    *******/

    /*
    ** Notes on Delete(ion) of  a co-product.
    ** 1. WE DONOT ALLOW A PRIMARY CO-PRODUCT TO BE DELETED.
    ** 2. WE ALLOW SECONDARY CO-PRODUCTS DELETTION.
    ** 3. WE ALLOW THE WHOLE CO-PRODUCT DEFINTION TO BE DELETED.
    **
    ** Changes as per above;
    ** 1. No changes
    ** 2. We should delete the bom_header for the secondary co-product
    ** when we delete it from the co-product definition because in BOM
    ** Header level, there is nothing like a disable date. However, we
    ** should NOT UPDATE the BOM_INVENTORY_COMPONENTS as it belongs to
    ** the primary co-product bill.
    ** 3. When we delete the whole co-product definition, then we should
    ** delete all the co-product definition as well all the bom headers
    ** corresponding to the co-products and all the bom_inventory_components
    ** corresponding to the primary co-product' bill.
    ** - Bala BALAKUMAR, June 23rd, 2000.
    */

-- Commenting the following code out. Please refer to bug 2816426

/* ***************************************************************************

    WSMPPCPD.lock_bill( x_bill_sequence_id => x_bill_sequence_id
                        , x_error_code => x_error_code
                        , x_error_msg => x_error_msg);

    IF (x_error_code > 0) THEN
        return;
    ELSIF (x_error_code < 0) THEN
        raise e_proc_exception;
    END IF;

    -- Now go ahead and delete the BOM Header.

    x_progress := '031';

    delete bom_bill_of_materials
    where  bill_sequence_id = x_bill_sequence_id;


    ** If the coproduct is a primary co-product (as in deletion
    ** of the complete co-product group definition), then
    ** we need to delete the bom_inventory_components also.


    If NVL(x_primary_flag, 'N') = 'Y' Then

        SELECT bcp.component_sequence_id
        INTO   x_component_sequence_id
        FROM   wsm_co_products bcp
        WHERE  bcp.co_product_group_id = x_co_product_group_id
        AND    bcp.co_product_id      is not NULL
        And     NVL(bcp.primary_flag, 'N') = 'Y';

        x_progress := '032';

        WSMPPCPD.lock_component(x_component_sequence_id,
                                x_error_code,
                                x_error_msg);

        IF (x_error_code > 0) THEN
            return;
        ELSIF (x_error_code < 0) THEN
            raise e_proc_exception;
        END IF;

        x_progress := '033';

        delete bom_inventory_components
        Where  bill_sequence_id = x_bill_sequence_id
        And    component_sequence_id = x_component_sequence_id;


        ** Optionally, the component might have substitute
        ** components and reference designators. Hence, we put
        ** the following code in anonymous block so that
        ** when NO_DATA_FOUND exception is thrown, we don't
        ** have to do anything with it for this particular
        ** delete alone.


        BEGIN
                x_progress := '034';

                delete bom_substitute_components
                Where  component_sequence_id = x_component_sequence_id;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        Null;
        END;

        BEGIN
                x_progress := '035';
                delete bom_reference_designators
                Where  component_sequence_id = x_component_sequence_id;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        Null;
        END;

    End If;
    -- End of code introduced by Bala Balakumar, June 23rd, 2000.

    x_progress := '036';

    WSMPCPSB.delete_substitutes (x_co_product_group_id,
                                 x_co_product_id);


************************************************************************ */

-- End commenting out code for bug 2816426

    x_progress := '040';

    WSMPCPDS.delete_row (x_rowid);

    x_error_code := 0;

EXCEPTION
    WHEN e_delete_co_product THEN
        x_error_code := 1;
        -- x_error_msg  := 'Insufficient arguments to WSMPPCPD.delete_co_product';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.delete_co_product');
        x_error_msg := fnd_message.get;

    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.delete_co_product('||x_progress||')';

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.delete_co_product(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END delete_co_product;


/* ===========================================================================

  PROCEDURE NAME:   update_co_prod_details

=========================================================================== */

PROCEDURE update_co_prod_details(x_co_product_group_id IN     NUMBER,
                                 x_effectivity_date    IN     DATE,
                                 x_disable_date        IN     DATE,
                                 x_usage_rate          IN     NUMBER,
                                 x_inv_usage           IN     NUMBER,
                                 x_duality_flag        IN     VARCHAR2,
                                 x_basis_type          IN     NUMBER,       --LBM enh
                                 x_comp_attribute_category  IN     VARCHAR2,
                                 x_comp_attribute1          IN     VARCHAR2,
                                 x_comp_attribute2          IN     VARCHAR2,
                                 x_comp_attribute3          IN     VARCHAR2,
                                 x_comp_attribute4          IN     VARCHAR2,
                                 x_comp_attribute5          IN     VARCHAR2,
                                 x_comp_attribute6          IN     VARCHAR2,
                                 x_comp_attribute7          IN     VARCHAR2,
                                 x_comp_attribute8          IN     VARCHAR2,
                                 x_comp_attribute9          IN     VARCHAR2,
                                 x_comp_attribute10         IN     VARCHAR2,
                                 x_comp_attribute11         IN     VARCHAR2,
                                 x_comp_attribute12         IN     VARCHAR2,
                                 x_comp_attribute13         IN     VARCHAR2,
                                 x_comp_attribute14         IN     VARCHAR2,
                                 x_comp_attribute15         IN     VARCHAR2,
                                 x_error_code          IN OUT NOCOPY NUMBER,
                                 x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3)  := NULL;
e_proc_exception         EXCEPTION;
e_update_co_prod_details EXCEPTION;
x_alternate              VARCHAR2(10) := NULL;
x_bill_sequence_id       NUMBER       := NULL;
CURSOR S IS
         SELECT bcp.co_product_id,
                bcp.component_sequence_id,
                bcp.split
         FROM   wsm_co_products bcp
         WHERE  bcp.co_product_group_id = x_co_product_group_id
         AND    bcp.co_product_id is NOT NULL;

BEGIN

    x_progress := '010';

    IF (x_co_product_group_id IS NULL)  THEN
        raise e_update_co_prod_details;
    END IF;

    --
    -- Update the corresponding bill.
    --

    FOR S_rec IN S LOOP

        x_progress := '020';

        WSMPPCPD.process_co_product (x_process_code     => 2,
                 x_bill_sequence_id   => x_bill_sequence_id,
                 x_component_sequence_id => S_rec.component_sequence_id,
                 x_alternate_designator  => x_alternate,
                 x_usage                 => x_usage_rate,
                 x_split            => S_rec.split,
                 x_effectivity_date => x_effectivity_date,
                 x_disable_date     => x_disable_date,
                 x_duality_flag     => x_duality_flag,
                 x_basis_type       => x_basis_type,     --LBM enh
                 x_comp_attribute_category => x_comp_attribute_category,
                 x_comp_attribute1  => x_comp_attribute1,
                 x_comp_attribute2  => x_comp_attribute2,
                 x_comp_attribute3  => x_comp_attribute3,
                 x_comp_attribute4  => x_comp_attribute4,
                 x_comp_attribute5  => x_comp_attribute5,
                 x_comp_attribute6  => x_comp_attribute6,
                 x_comp_attribute7  => x_comp_attribute7,
                 x_comp_attribute8  => x_comp_attribute8,
                 x_comp_attribute9  => x_comp_attribute9,
                 x_comp_attribute10 => x_comp_attribute10,
                 x_comp_attribute11 => x_comp_attribute11,
                 x_comp_attribute12 => x_comp_attribute12,
                 x_comp_attribute13 => x_comp_attribute13,
                 x_comp_attribute14 => x_comp_attribute14,
                 x_comp_attribute15 => x_comp_attribute15,
                 x_error_code       => x_error_code,
                 x_error_msg        => x_error_msg);
        IF (x_error_code < 0) THEN
            raise e_proc_exception;
        ELSIF (x_error_code <> 0) THEN
            return;
        END IF;
    END LOOP;

    --
    -- On successful update of the bill update the
    -- co-products.
    --
    x_progress := '030';

    UPDATE wsm_co_products
    SET    effectivity_date = x_effectivity_date,
           disable_date     = x_disable_date,
           usage_rate       = x_usage_rate,
           duality_flag     = x_duality_flag
    WHERE  co_product_group_id = x_co_product_group_id;

    x_error_code := 0;

EXCEPTION
    WHEN e_update_co_prod_details THEN
        x_error_code := 1;
        -- x_error_msg  := 'Insufficient arguments to WSMPPCPD.update_co_prod_details';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.update_co_prod_details');
        x_error_msg := fnd_message.get;

    WHEN e_proc_exception  THEN
        x_error_msg := x_error_msg || ' - ' || 'WSMPPCPD.update_co_prod_details('||x_progress||')';

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.update_co_prod_details(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END update_co_prod_details;


/*===========================================================================

  FUNCTION NAME:        lock_bill

===========================================================================*/

PROCEDURE lock_bill (x_bill_sequence_id       IN       NUMBER,
                     x_error_code             IN OUT NOCOPY   NUMBER,
                     x_error_msg              IN OUT NOCOPY   VARCHAR2)
IS

x_progress  VARCHAR2(3) := '010';

CURSOR C IS SELECT *
            FROM   bom_bill_of_materials
            WHERE  bill_sequence_id = x_bill_sequence_id
            FOR UPDATE OF bill_sequence_id NOWAIT;

BEGIN

    OPEN C;
    CLOSE C;

    x_error_code := 0;

EXCEPTION
    WHEN app_exceptions.record_lock_exception THEN
        x_error_code := 1;
        fnd_message.set_name('WSM','WSM_ASSY_LOCK_ERR');
        x_error_msg  := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.lock_bill(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END lock_bill;

/*===========================================================================

  FUNCTION NAME:        lock_component

===========================================================================*/

PROCEDURE lock_component (x_component_sequence_id      IN       NUMBER,
                          x_error_code                 IN OUT NOCOPY   NUMBER,
                          x_error_msg                  IN OUT NOCOPY   VARCHAR2)
IS

x_progress  VARCHAR2(3) := '010';

CURSOR C IS SELECT *
            FROM   bom_inventory_components
            WHERE  bill_sequence_id = x_component_sequence_id
            FOR UPDATE OF component_sequence_id NOWAIT;

BEGIN

    OPEN C;
    CLOSE C;

    x_error_code := 0;

EXCEPTION
    WHEN app_exceptions.record_lock_exception THEN
         x_error_code := 1;
         fnd_message.set_name('WSM','WSM_COMP_LOCK_ERR');
         x_error_msg  := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.lock_component(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END lock_component;

/*===========================================================================

  PROCEDURE NAME:       call_bom_bo_api

===========================================================================*/

PROCEDURE call_bom_bo_api (
   p_bom_header_rec    IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                Bom_Bo_Pub.G_MISS_BOM_HEADER_REC,
   p_component_tbl     IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL,
   p_subs_comp_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
                                Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL,
   x_error_code        IN OUT NOCOPY   NUMBER,
   x_error_msg         IN OUT NOCOPY   VARCHAR2)
IS

--define local variables
l_bom_header_rec          Bom_Bo_Pub.bom_Head_Rec_Type;
l_bom_revision_tbl        Bom_Bo_Pub.Bom_Revision_Tbl_Type;
l_bom_component_tbl       Bom_Bo_pub.Bom_Comps_Tbl_Type;
l_bom_ref_designator_tbl  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
l_bom_sub_component_tbl   Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_mesg_token_tbl          Error_Handler.Mesg_Token_Tbl_Type;

e_null_param_exception    EXCEPTION;

-- ST Bug fix 5081436
l_full_path               v$parameter.value%TYPE;
l_new_full_path           v$parameter.value%TYPE;
l_file_dir                v$parameter.value%TYPE;
l_debug_flag              VARCHAR2(1);
l_mrp_debug               VARCHAR2(1);
fileHandler               UTL_FILE.FILE_TYPE;
-- ST Bug fix 5081436

BEGIN

    --g_iteration_count := g_iteration_count + 1; -- for debug only

    /*
    ** Introduced by Bala Balakumar to check for Assy Item Id
    ** and Org Id if null or not.
    **
    */

    If p_bom_header_rec.assembly_item_name is NULL
       OR p_bom_header_rec.Organization_Code is NULL Then

        raise e_null_param_exception;
    End If;

    -- End of Debugging Script by Bala on June 21, 2000.

    -- ST : Bug fix 5081436 start
    l_mrp_debug := fnd_profile.value('mrp_debug');
    l_debug_flag := 'N';

    IF l_mrp_debug = 'Y' THEN
            -- Pass on a directory from utl_file_dir
            SELECT value
            INTO   l_full_path
            FROM   v$parameter
            WHERE  name = 'utl_file_dir';

            -- l_full_path contains a list of comma-separated directories
            WHILE(TRUE)
            LOOP
                -- get the first dir in the list
                SELECT trim(substr(l_full_path, 1, decode(instr(l_full_path,',')-1,
                                                          -1, length(l_full_path),
                                                          instr(l_full_path, ',')-1
                                                         )
                                  )
                           )
                INTO  l_file_dir
                FROM  dual;

                -- check if the dir is valid
                BEGIN
                    fileHandler := UTL_FILE.FOPEN(l_file_dir , 'wsmdbg.log', 'w');
                    l_debug_flag := 'Y';
                EXCEPTION
                    WHEN utl_file.invalid_path THEN
                        l_debug_flag := 'N';

                    WHEN utl_file.invalid_operation THEN
                        l_debug_flag := 'N';
                END;

                IF l_debug_flag = 'Y' THEN  -- got a valid directory
                    EXIT;
                END IF;

                -- earlier found dir was not a valid dir
                -- so remove that from the list, and get the new list */
                l_new_full_path := trim(substr(l_full_path, instr(l_full_path, ',')+1, length(l_full_path)));

                -- if the new list has not changed, there are no more valid dirs left
                IF l_full_path = l_new_full_path THEN
                    l_debug_flag := 'N';
                    EXIT;
                END IF;
                l_full_path := l_new_full_path;
           END LOOP;
   END IF;
   -- ST : Bug fix 5081436 end

   Bom_Bo_Pub.Process_Bom (
        p_init_msg_list             =>  TRUE
        , p_bom_header_rec          =>  p_bom_header_rec
        , p_bom_component_tbl       =>  p_component_tbl
        , p_bom_sub_component_tbl   =>  p_subs_comp_tbl
        , x_bom_header_rec          =>  l_bom_header_rec
        , x_bom_revision_tbl        =>  l_bom_revision_tbl
        , x_bom_component_tbl       =>  l_bom_component_tbl
        , x_bom_ref_designator_tbl  =>  l_bom_ref_designator_tbl
        , x_bom_sub_component_tbl   =>  l_bom_sub_component_tbl
        , x_return_status           =>  l_return_status
        , x_msg_count               =>  l_msg_count
        , p_debug                   =>  l_debug_flag  -- ST : Commenting for bug fix 'N'
        , p_output_dir              =>  l_file_dir    -- ST : Commenting for bug fix '/tmp'
        , p_debug_filename          =>  'wsmdbg.log'   -- changed to wsmdbg.log from wsm.log to workaround GSCC error.
    );

    IF l_return_status <> 'S' THEN
        x_error_code := -999;
    ELSE
        x_error_code := 0;
    END IF;

EXCEPTION

    WHEN e_null_param_exception THEN
        x_error_code := -900;
        -- x_error_msg := 'Assembly Item Name or Org Code is NULL in header_rec';
        fnd_message.set_name('WSM', 'WSM_INSUFFICIENT_ARGUMENTS');
        fnd_message.set_token('OBJECT_NAME', 'WSMPPCPD.call_bom_bo_api');
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
        x_error_code := sqlcode;
        x_error_msg  := 'WSMPPCPD.call_bom_bo_api - ' || substr(sqlerrm, 1, 200);
END call_bom_bo_api;

/*===========================================================================

  PROCEDURE NAME:       set_common_bill_new

===========================================================================*/

PROCEDURE set_common_bill_new (
        p_co_product_group_id   IN  NUMBER,
        p_organization_id       IN  NUMBER,
        p_organization_code     IN  VARCHAR2,
        p_alternate_designator  IN  VARCHAR2,
        x_error_code     OUT NOCOPY  NUMBER,
        x_error_msg      OUT NOCOPY  VARCHAR2 )
IS

l_prim_co_prod_id               NUMBER;
l_prim_co_prod_name             VARCHAR2(81); /* 81 as defined in BOM BO API */
l_co_product_name               VARCHAR2(81); /* 81 as defined in BOM BO API */

x_progress                      VARCHAR2(3) := NULL;
e_primary_coprod_exception      EXCEPTION;

/*
** This cursor ensures that the co-products being
** updated for the common bill sequence Id do exist
** in BOM as well and hence it is combined with the
** bom_bill_of_materials table.
** - Bala Balakumar, June 23rd, 2000.
*/

CURSOR C is
SELECT co_product_id, wcp.alternate_designator
FROM   bom_bill_of_materials bbom,
       wsm_co_products wcp
WHERE  wcp.co_product_group_id = p_co_product_group_id
AND    wcp.co_product_id IS NOT NULL
AND    NVL(wcp.primary_flag, 'N') <> 'Y'
AND    bbom.assembly_item_id = wcp.co_product_id
AND    bbom.organization_id = p_organization_id
/*coprod enh p2 .45*/
--AND    nvl(bbom.alternate_bom_designator, '$%&') = nvl(p_alternate_designator, '$%&')
AND    nvl(bbom.alternate_bom_designator, '$%&') = nvl(wcp.alternate_designator, '$%&')
AND nvl(wcp.alternate_designator, '$%&') = (select nvl(wcp1.alternate_designator, '$%&')
                                from wsm_co_products wcp1
                                where wcp1.co_product_group_id=p_co_product_group_id
                                and wcp1.primary_flag='Y')
/*end coprod enh p2 .45*/
AND    bbom.common_bill_sequence_id = wcp.bill_sequence_id;

--commented out by Bala on June 24th, 2000.
--AND bbom.bill_sequence_id = wcp.bill_sequence_id;
-- Above line commented out and uncommented the check with common_bill_seq_id
-- since if the common bill has been already set, the common_bill_seq_id and
-- the bill_seq_id will not be the same and we want only those records which
-- match the condition common_bill_seq_id = bill_seq_id - Raghu.

BEGIN

    /*  This procedure uses the BOM BO API to update the Bill headers
    of the Secondary Co-Products to set the Common Bill Reference.  */

    x_progress := '010';

    -- get the primary co-product details

    Begin

        SELECT co_product_id
        INTO   l_prim_co_prod_id
        FROM   wsm_co_products
        WHERE  co_product_group_id = p_co_product_group_id
        AND    co_product_id IS NOT NULL
        AND    nvl(primary_flag, 'N') = 'Y';


    EXCEPTION
        When TOO_MANY_ROWS Then
                fnd_message.set_name('WSM', 'WSM_NO_PRIMARY_COPRODUCT');
                x_error_code := sqlcode;
                /* Bug# 1790690. Added the following statement so that
                   it raises the exception where there are more than
                   one primary flag is checked */
                raise e_primary_coprod_exception;

        When NO_DATA_FOUND Then
                fnd_message.set_name('WSM', 'WSM_NO_PRIMARY_COPRODUCT');
                x_error_code := sqlcode;
                /* Bug# 1790690. Added the following statement so that
                   it raises the exception when the primary flag
                   is not checked at all*/
                raise e_primary_coprod_exception;
    End;

    x_progress := '020';

    -- get the primary co_product_name
    If  l_prim_co_prod_id is NOT NULL  AND
        p_organization_id is NOT NULL Then

        SELECT substr(concatenated_segments, 1, 80)
        INTO   l_prim_co_prod_name
        FROM   mtl_system_items_kfv
        WHERE  inventory_item_id = l_prim_co_prod_id
        AND    organization_id = p_organization_id;

    Else
        fnd_message.set_name('WSM', 'WSM_NO_PRIMARY_COPRODUCT');
        raise e_primary_coprod_exception;
    End If;

    x_progress := '030';

    FOR c_rec in C LOOP

        -- get the secondary co-product name
        SELECT substr(concatenated_segments, 1, 80)
        INTO   l_co_product_name
        FROM   mtl_system_items_kfv
        WHERE  inventory_item_id = c_rec.co_product_id
        AND    organization_id = p_organization_id;

        x_progress := '035';
        -- prepare the bill header for the business object

        g_bom_header_rec := Bom_Bo_Pub.G_MISS_BOM_HEADER_REC; /* initialize */
        -- now populate the header record before calling the API
        g_bom_header_rec.Transaction_Type       := BOM_Globals.G_OPR_UPDATE;
        g_bom_header_rec.Assembly_Item_Name     := l_co_product_name;
        g_bom_header_rec.Organization_Code := p_organization_code;
/*coproduct enh p2 .45*/
--      g_bom_header_rec.Alternate_Bom_Code := p_alternate_designator;
        g_bom_header_rec.Alternate_Bom_Code := c_rec.alternate_designator;
/*end coproduct enh p2 .45*/
        g_bom_header_rec.Common_Assembly_Item_Name := l_prim_co_prod_name;
        g_bom_header_rec.Common_Organization_Code := p_organization_code;
        -- Added next line for resolution of bug 2682690
        g_bom_header_rec.Assembly_Type := 1;

        -- now go ahead and call the BOM Business Object API
        -- to update this bill

        WSMPPCPD.call_bom_bo_api (
                        p_bom_header_rec  =>  g_bom_header_rec,
                        x_error_code => x_error_code,
                        x_error_msg  => x_error_msg );

        IF x_error_code <> 0 THEN
                return;
        END IF;

    END LOOP;

EXCEPTION

    WHEN e_primary_coprod_exception Then
        x_error_code := -900;
        x_error_msg := fnd_message.get;

    WHEN OTHERS THEN
      x_error_code := sqlcode;
      x_error_msg  := 'WSMPPCPD.set_common_bill_new('||x_progress ||') ' || substr(sqlerrm, 1, 200);

END set_common_bill_new;

END WSMPPCPD;

/
