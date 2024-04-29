--------------------------------------------------------
--  DDL for Package Body ENG_LAUNCH_ECO_OI_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_LAUNCH_ECO_OI_PK" AS
/*  $Header: ENCOINB.pls 120.7.12010000.8 2019/04/01 13:57:03 nlingamp ship $ */


---------------
--
-- Global variables
--

g_ECO_ifce_key          VARCHAR2(30) := NULL;
g_revised_item_ifce_key VARCHAR2(30) := NULL;
g_revised_comp_ifce_key VARCHAR2(30) := NULL;

g_ECO_exists            BOOLEAN := FALSE;
g_revised_items_exist   BOOLEAN := FALSE;
g_revised_comps_exist   BOOLEAN := FALSE;

g_all_org               NUMBER;
g_org_id                NUMBER;


---------------
--
-- Global data structures
--

-- ifce arrays. An entry in each of these consists of all distinct ifce keys in interface tables

TYPE ECO_ifce_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE item_ifce_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE comp_ifce_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

g_ECO_ifce_group_tbl            ECO_ifce_type;
g_item_ifce_group_tbl           item_ifce_type;
g_comp_ifce_group_tbl           comp_ifce_type;

-- record structures with ifce keys

g_encoin_rev_item_tbl           Encoin_Revised_Item_Tbl_Type;
g_encoin_rev_comp_tbl           Encoin_Rev_Component_Tbl_Type;
g_encoin_ref_des_tbl            Encoin_Ref_Designator_Tbl_Type;
g_encoin_sub_comp_tbl           Encoin_Sub_Component_Tbl_Type;

-- record structures without ifce keys.
-- rev comps structures have parent rev items index keys
-- ref desgs and sub comps have parent rev comps and grand parent rev items ifce keys

g_public_eco_rec                ENG_Eco_PUB.Eco_Rec_Type;
g_public_out_eco_rec            ENG_Eco_PUB.Eco_Rec_Type;
g_public_rev_tbl                ENG_Eco_PUB.Eco_Revision_Tbl_Type;
g_public_out_rev_tbl            ENG_Eco_PUB.Eco_Revision_Tbl_Type;
g_public_rev_item_tbl           ENG_Eco_PUB.Revised_Item_Tbl_Type;
g_public_out_rev_item_tbl       ENG_Eco_PUB.Revised_Item_Tbl_Type;
g_public_lines_tbl          ENG_Eco_PUB.Change_Line_Tbl_Type;
g_public_out_lines_tbl      ENG_Eco_PUB.Change_Line_Tbl_Type;
g_public_rev_comp_tbl           Bom_Bo_PUB.Rev_Component_Tbl_Type;
g_public_out_rev_comp_tbl       Bom_Bo_PUB.Rev_Component_Tbl_Type;
g_public_ref_des_tbl            Bom_Bo_PUB.Ref_Designator_Tbl_Type;
g_public_out_ref_des_tbl        Bom_Bo_PUB.Ref_Designator_Tbl_Type;
g_public_sub_comp_tbl           Bom_Bo_PUB.Sub_Component_Tbl_Type;
g_public_out_sub_comp_tbl       Bom_Bo_PUB.Sub_Component_Tbl_Type;
g_public_rev_operation_tbl         Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
g_public_rev_op_res_tbl       Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
g_public_rev_sub_res_tbl      Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;
g_public_out_rev_operation_tbl         Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
g_public_out_rev_op_res_tbl       Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
g_public_out_rev_sub_res_tbl      Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;


---------------
--
-- Global Cursors Definitions
--

    -- Get ECO headers

    CURSOR GetEco IS
      SELECT attribute7, attribute8, attribute9, attribute10, attribute11,
             attribute12, attribute13, attribute14, attribute15, request_id,
             program_application_id, program_id, program_update_date,
             approval_status_type, approval_date, approval_list_id,
             change_order_type_id, responsible_organization_id,
             approval_request_date, requestor_user_name, assignee_name,
             change_notice, organization_id, last_update_date, last_updated_by,
             creation_date, created_by, last_update_login, description,
             status_type, initiation_date, implementation_date,
             cancellation_date, cancellation_comments, priority_code,
             reason_code, estimated_eng_cost, estimated_mfg_cost, requestor_id,
             attribute_category, attribute1, attribute2, attribute3,
             attribute4, attribute5, attribute6, process_flag,
             transaction_id, APPROVAL_LIST_NAME, CHANGE_ORDER_TYPE,
             change_mgmt_type_name, project_name, task_number, ORGANIZATION_CODE,
             RESPONSIBLE_ORG_CODE, transaction_type, ENG_CHANGES_IFCE_KEY, change_name ,status_name, --Bug 2908248
             pk1_name ,pk2_name , pk3_name ,plm_or_erp_change --11.5.10
             , Approval_status_name -- bug 3587304
             ,ORGANIZATION_HIERARCHY  -- 4967902
             , employee_number -- 4402842
             , source_type_name
             , source_name
             , need_by_date
             , eco_department_name
        FROM eng_eng_changes_interface
       WHERE process_flag = 1
         AND (g_all_org = 1
              OR
             (g_all_org = 2 AND organization_id = g_org_id));

    -- Get Revision with current ECO Header's ifce key

    CURSOR GetRevWithCurrECOifce IS
      SELECT attribute11, attribute12, attribute13, attribute14,
             attribute15, program_application_id, program_id, program_update_date,
             request_id, revision_id, change_notice, organization_id, revision,
             last_update_date, last_updated_by, creation_date,created_by,
             last_update_login, comments,attribute_category, attribute1,
             attribute2, attribute3, attribute4, attribute5, attribute6,
             attribute7, attribute8, attribute9, attribute10, new_revision,
             process_flag, transaction_id,transaction_type, ORGANIZATION_CODE,
             eng_changes_ifce_key
        FROM eng_eco_revisions_interface
       WHERE eng_changes_ifce_key = g_ECO_ifce_key
         AND process_flag = 1
              AND (g_all_org = 1
                   OR
                   (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more ECO headers.
    -- Group ECO revisions by ECO Header ifce values

    CURSOR GetRevWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM eng_eco_revisions_interface
       WHERE process_flag = 1
              AND (g_all_org = 1
                   OR
                   (g_all_org = 2 AND organization_id = g_org_id));

    -- Get all other ECO Revisions

    CURSOR GetRev IS
      SELECT attribute11, attribute12, attribute13, attribute14,
             attribute15, program_application_id, program_id, program_update_date,
             request_id, revision_id, change_notice, organization_id, revision,
             last_update_date, last_updated_by, creation_date,created_by,
             last_update_login, comments,attribute_category, attribute1,
             attribute2, attribute3, attribute4, attribute5, attribute6,
             attribute7, attribute8, attribute9, attribute10, new_revision,
             process_flag, transaction_id,transaction_type, ORGANIZATION_CODE,
             eng_changes_ifce_key, eng_eco_revisions_ifce_key
        FROM eng_eco_revisions_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get revised items with the current ECO Header's ifce key
   ---11.5.10 adding following columns and ordering by parent_revised_item_name
    -- parent_revised_item_name
    -- parent_alternate_name

    CURSOR GetItemWithCurrECOifce IS
      SELECT  change_notice             ,
        organization_id           ,
        revised_item_id           ,
        last_update_date          ,
        last_updated_by           ,
        creation_date             ,
        created_by                ,
        last_update_login         ,
        implementation_date       ,
        cancellation_date         ,
        cancel_comments           ,
        disposition_type          ,
        new_item_revision         ,
        early_schedule_date       ,
        attribute_category        ,
        attribute2                ,
        attribute3                ,
        attribute4                ,
        attribute5                ,
        attribute7                ,
        attribute8                ,
        attribute9                ,
        attribute11               ,
        attribute12               ,
        attribute13               ,
        attribute14               ,
        attribute15               ,
        status_type               ,
        scheduled_date            ,
        bill_sequence_id          ,
        mrp_active                ,
        request_id                ,
        program_application_id    ,
        program_id                ,
        program_update_date       ,
        update_wip                ,
        use_up                    ,
        use_up_item_id            ,
        revised_item_sequence_id  ,
        use_up_plan_name          ,
        descriptive_text          ,
        auto_implement_date       ,
        attribute1                ,
        attribute6                ,
        attribute10               ,
        requestor_id              ,
        comments                  ,
        process_flag              ,
        transaction_id            ,
        organization_code         ,
        revised_item_number       ,
        new_rtg_revision          ,
        use_up_item_number        ,
        alternate_bom_designator  ,
        transaction_type          ,
        ENG_REVISED_ITEMS_IFCE_KEY,
        eng_changes_ifce_key      ,
        parent_revised_item_name  ,
        parent_alternate_name     ,
        updated_item_revision     ,
        New_scheduled_date     -- Bug 3432944
        ,
        from_item_revision -- 11.5.10E
        ,
        new_revision_label        ,
        New_Revised_Item_Rev_Desc ,
        new_revision_reason       ,
        from_end_item_unit_number
        /*Bug 6377841*/
FROM    eng_revised_items_interface
WHERE   eng_changes_ifce_key = g_ECO_ifce_key
    AND process_flag         = 1
    AND (g_all_org           = 1
     OR (g_all_org           = 2
    AND organization_id      = g_org_id))
ORDER BY parent_revised_item_name desc ;

    -- Called when there are no more ECO headers.
    -- Group revised items by ECO Header ifce values

    CURSOR GetItemWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM eng_revised_items_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get all other revised items

    CURSOR GetItem
IS
        SELECT  change_notice             ,
                organization_id           ,
                revised_item_id           ,
                last_update_date          ,
                last_updated_by           ,
                creation_date             ,
                created_by                ,
                last_update_login         ,
                implementation_date       ,
                cancellation_date         ,
                cancel_comments           ,
                disposition_type          ,
                new_item_revision         ,
                early_schedule_date       ,
                attribute_category        ,
                attribute2                ,
                attribute3                ,
                attribute4                ,
                attribute5                ,
                attribute7                ,
                attribute8                ,
                attribute9                ,
                attribute11               ,
                attribute12               ,
                attribute13               ,
                attribute14               ,
                attribute15               ,
                status_type               ,
                scheduled_date            ,
                bill_sequence_id          ,
                mrp_active                ,
                request_id                ,
                program_application_id    ,
                program_id                ,
                program_update_date       ,
                update_wip                ,
                use_up                    ,
                use_up_item_id            ,
                revised_item_sequence_id  ,
                use_up_plan_name          ,
                descriptive_text          ,
                auto_implement_date       ,
                attribute1                ,
                attribute6                ,
                attribute10               ,
                requestor_id              ,
                comments                  ,
                process_flag              ,
                transaction_id            ,
                organization_code         ,
                revised_item_number       ,
                new_rtg_revision          ,
                use_up_item_number        ,
                alternate_bom_designator  ,
                transaction_type          ,
                ENG_REVISED_ITEMS_IFCE_KEY,
                eng_changes_ifce_key      ,
                parent_revised_item_name  ,
                parent_alternate_name     ,
                updated_item_revision     ,
                New_scheduled_date    -- Bug 3432944
                ,
                from_item_revision -- 11.5.10E
                ,
                new_revision_label        ,
                New_Revised_Item_Rev_Desc ,
                new_revision_reason       ,
                from_end_item_unit_number
                /*Bug 6377841*/
        FROM    eng_revised_items_interface
        WHERE   process_flag    = 1
            AND (g_all_org      = 1
             OR (g_all_org      = 2
            AND organization_id = g_org_id))
        ORDER BY parent_revised_item_name desc ;

    -- Get revised comps with the current Header ifce key

    CURSOR GetCompWithCurrECOifce
IS
        SELECT  supply_subinventory         ,
                operation_lead_time_percent ,
                revised_item_sequence_id    ,
                cost_factor                 ,
                required_for_revenue        ,
                high_quantity               ,
                component_sequence_id       ,
                program_application_id      ,
                wip_supply_type             ,
                supply_locator_id           ,
                bom_item_type               ,
                operation_seq_num           ,
                component_item_id           ,
                last_update_date            ,
                last_updated_by             ,
                creation_date               ,
                created_by                  ,
                last_update_login           ,
                item_num                    ,
                component_quantity          ,
                component_yield_factor      ,
                component_remarks           ,
                revised_item_number         ,
                effectivity_date            ,
                change_notice               ,
                implementation_date         ,
                disable_date                ,
                attribute_category          ,
                attribute1                  ,
                attribute2                  ,
                attribute3                  ,
                attribute4                  ,
                attribute5                  ,
                attribute6                  ,
                attribute7                  ,
                attribute8                  ,
                attribute9                  ,
                attribute10                 ,
                attribute11                 ,
                attribute12                 ,
                attribute13                 ,
                attribute14                 ,
                attribute15                 ,
                planning_factor             ,
                quantity_related            ,
                so_basis                    ,
                optional                    ,
                mutually_exclusive_options  ,
                include_in_cost_rollup      ,
                check_atp                   ,
                shipping_allowed            ,
                required_to_ship            ,
                include_on_ship_docs        ,
                include_on_bill_docs        ,
                low_quantity                ,
                acd_type                    ,
                old_component_sequence_id   ,
                bill_sequence_id            ,
                request_id                  ,
                program_id                  ,
                program_update_date         ,
                pick_components             ,
                assembly_type               ,
                interface_entity_type       ,
                reference_designator        ,
                new_effectivity_date        ,
                old_effectivity_date        ,
                substitute_comp_id          ,
                new_operation_seq_num       ,
                old_operation_seq_num       ,
                process_flag                ,
                transaction_id              ,
                SUBSTITUTE_COMP_NUMBER      ,
                ORGANIZATION_CODE           ,
                ASSEMBLY_ITEM_NUMBER        ,
                COMPONENT_ITEM_NUMBER       ,
                LOCATION_NAME               ,
                ORGANIZATION_ID             ,
                ASSEMBLY_ITEM_ID            ,
                ALTERNATE_BOM_DESIGNATOR    ,
                transaction_type            ,
                BOM_INVENTORY_COMPS_IFCE_KEY,
                eng_changes_ifce_key        ,
                eng_revised_items_ifce_key
                --Bug 3396529: Added New_revised_Item_Revision
                ,
                New_revised_Item_Revision,
                basis_type               ,
                from_end_item_unit_number, /*Bug 6377841*/
                to_end_item_unit_number
                /*Bug 6377841*/
                /*BUG 9374069 revert 8414408,old_from_end_item_unit_number 8414408*/
        FROM    bom_inventory_comps_interface
        WHERE   eng_changes_ifce_key  = g_ECO_ifce_key
            AND interface_entity_type = 'ECO'
            AND process_flag          = 1
            AND (g_all_org            = 1
             OR (g_all_org            = 2
            AND organization_id       = g_org_id));

    -- Called when there are no more ECO headers.
    -- Group revised comps by ECO Header ifce values

    CURSOR GetCompWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM bom_inventory_comps_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

   -- Get revised comps with the current revised item's ifce key

  CURSOR GetCompWithCurrItemifce
IS
        SELECT  supply_subinventory         ,
                operation_lead_time_percent ,
                revised_item_sequence_id    ,
                cost_factor                 ,
                required_for_revenue        ,
                high_quantity               ,
                component_sequence_id       ,
                program_application_id      ,
                wip_supply_type             ,
                supply_locator_id           ,
                bom_item_type               ,
                operation_seq_num           ,
                component_item_id           ,
                last_update_date            ,
                last_updated_by             ,
                creation_date               ,
                created_by                  ,
                last_update_login           ,
                item_num                    ,
                component_quantity          ,
                component_yield_factor      ,
                component_remarks           ,
                effectivity_date            ,
                change_notice               ,
                implementation_date         ,
                disable_date                ,
                attribute_category          ,
                attribute1                  ,
                attribute2                  ,
                attribute3                  ,
                attribute4                  ,
                attribute5                  ,
                attribute6                  ,
                attribute7                  ,
                attribute8                  ,
                attribute9                  ,
                attribute10                 ,
                attribute11                 ,
                attribute12                 ,
                attribute13                 ,
                attribute14                 ,
                attribute15                 ,
                planning_factor             ,
                quantity_related            ,
                so_basis                    ,
                optional                    ,
                mutually_exclusive_options  ,
                include_in_cost_rollup      ,
                check_atp                   ,
                shipping_allowed            ,
                required_to_ship            ,
                include_on_ship_docs        ,
                include_on_bill_docs        ,
                low_quantity                ,
                acd_type                    ,
                old_component_sequence_id   ,
                bill_sequence_id            ,
                request_id                  ,
                program_id                  ,
                program_update_date         ,
                pick_components             ,
                assembly_type               ,
                interface_entity_type       ,
                reference_designator        ,
                new_effectivity_date        ,
                old_effectivity_date        ,
                substitute_comp_id          ,
                new_operation_seq_num       ,
                old_operation_seq_num       ,
                process_flag                ,
                transaction_id              ,
                SUBSTITUTE_COMP_NUMBER      ,
                ORGANIZATION_CODE           ,
                ASSEMBLY_ITEM_NUMBER        ,
                COMPONENT_ITEM_NUMBER       ,
                LOCATION_NAME               ,
                ORGANIZATION_ID             ,
                ASSEMBLY_ITEM_ID            ,
                ALTERNATE_BOM_DESIGNATOR    ,
                transaction_type            ,
                BOM_INVENTORY_COMPS_IFCE_KEY,
                eng_changes_ifce_key        ,
                eng_revised_items_ifce_key
                --Bug 3396529: Added New_revised_Item_Revision
                ,
                New_revised_Item_Revision,
                basis_type               ,
                from_end_item_unit_number,
                /*Bug 6377841*/
                to_end_item_unit_number
                /*Bug 6377841*/
                /*BUG 9374069 revert 8414408,old_from_end_item_unit_number*/
        FROM    bom_inventory_comps_interface
        WHERE   eng_revised_items_ifce_key = g_revised_item_ifce_key
            AND interface_entity_type      = 'ECO'
            AND process_flag               = 1
            AND (g_all_org                 = 1
             OR (g_all_org                 = 2
            AND organization_id            = g_org_id));

    -- Called when there are no more revised items.
    -- Group revised comps by revised item ifce values

    CURSOR GetCompWithSameItemifce IS
      SELECT DISTINCT(ENG_REVISED_ITEMS_IFCE_KEY) item_ifce_key
        FROM bom_inventory_comps_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get all other revised comps

  CURSOR GetComp
IS
        SELECT  supply_subinventory         ,
                operation_lead_time_percent ,
                revised_item_sequence_id    ,
                revised_item_number         , --added for OM ER 9946990
                cost_factor                 ,
                required_for_revenue        ,
                high_quantity               ,
                component_sequence_id       ,
                program_application_id      ,
                wip_supply_type             ,
                supply_locator_id           ,
                bom_item_type               ,
                operation_seq_num           ,
                component_item_id           ,
                last_update_date            ,
                last_updated_by             ,
                creation_date               ,
                created_by                  ,
                last_update_login           ,
                item_num                    ,
                component_quantity          ,
                component_yield_factor      ,
                component_remarks           ,
                effectivity_date            ,
                change_notice               ,
                implementation_date         ,
                disable_date                ,
                attribute_category          ,
                attribute1                  ,
                attribute2                  ,
                attribute3                  ,
                attribute4                  ,
                attribute5                  ,
                attribute6                  ,
                attribute7                  ,
                attribute8                  ,
                attribute9                  ,
                attribute10                 ,
                attribute11                 ,
                attribute12                 ,
                attribute13                 ,
                attribute14                 ,
                attribute15                 ,
                planning_factor             ,
                quantity_related            ,
                so_basis                    ,
                optional                    ,
                mutually_exclusive_options  ,
                include_in_cost_rollup      ,
                check_atp                   ,
                shipping_allowed            ,
                required_to_ship            ,
                include_on_ship_docs        ,
                include_on_bill_docs        ,
                low_quantity                ,
                acd_type                    ,
                old_component_sequence_id   ,
                bill_sequence_id            ,
                request_id                  ,
                program_id                  ,
                program_update_date         ,
                pick_components             ,
                assembly_type               ,
                interface_entity_type       ,
                reference_designator        ,
                new_effectivity_date        ,
                old_effectivity_date        ,
                substitute_comp_id          ,
                new_operation_seq_num       ,
                old_operation_seq_num       ,
                process_flag                ,
                transaction_id              ,
                SUBSTITUTE_COMP_NUMBER      ,
                ORGANIZATION_CODE           ,
                ASSEMBLY_ITEM_NUMBER        ,
                COMPONENT_ITEM_NUMBER       ,
                LOCATION_NAME               ,
                ORGANIZATION_ID             ,
                ASSEMBLY_ITEM_ID            ,
                ALTERNATE_BOM_DESIGNATOR    ,
                transaction_type            ,
                BOM_INVENTORY_COMPS_IFCE_KEY,
                eng_changes_ifce_key        ,
                eng_revised_items_ifce_key
                --Bug 3396529: Added New_revised_Item_Revision
                ,
                New_revised_Item_Revision,
                basis_type               ,
                from_end_item_unit_number, /*Bug 6377841*/
                to_end_item_unit_number
                /*Bug 6377841*/
                /*BUG 9374069 revert 8414408,old_from_end_item_unit_number */
        FROM    bom_inventory_comps_interface
        WHERE   interface_entity_type = 'ECO'
            AND process_flag          = 1
            AND (g_all_org            = 1
             OR (g_all_org            = 2
            AND organization_id       = g_org_id));

    -- Get reference designators with the current ECO Header's ifce key

    CURSOR GetRfdWithCurrECOifce IS
      SELECT COMPONENT_REFERENCE_DESIGNATOR,last_update_date,last_update_login,
             ref_designator_comment, change_notice, component_sequence_id,acd_type,
             request_id, program_application_id, program_id, program_update_date,
             attribute_category, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15,
             new_designator, process_flag, transaction_id, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, ORGANIZATION_CODE, ORGANIZATION_ID,last_updated_by,
             creation_date, created_by, ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR,
             COMPONENT_ITEM_ID, BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_ref_desgs_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_ref_desgs_interface
       WHERE eng_changes_ifce_key = g_ECO_ifce_key
             and process_flag = 1
             AND (g_all_org = 1
                  OR
                 (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more ECO headers.
    -- Group reference desgs by ECO Header ifce values

    CURSOR GetRfdWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM bom_ref_desgs_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

   -- Get reference desgs with the current revised item's ifce key

   CURSOR GetRfdWithCurrItemifce IS
      SELECT COMPONENT_REFERENCE_DESIGNATOR,last_update_date,last_update_login,
             last_updated_by, creation_date,created_by, ref_designator_comment,
             change_notice, component_sequence_id,acd_type, request_id,
             program_application_id, program_id, program_update_date,
             attribute_category, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15,
             new_designator, process_flag, transaction_id, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, ORGANIZATION_CODE, ORGANIZATION_ID,
             ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR, COMPONENT_ITEM_ID,
             BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_ref_desgs_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_ref_desgs_interface
       WHERE eng_revised_items_ifce_key = g_revised_item_ifce_key
         AND interface_entity_type = 'ECO'
         AND process_flag = 1
         AND (g_all_org = 1
             OR
             (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more revised items.
    -- Group reference desgs by revised item ifce values

    CURSOR GetRfdWithSameItemifce IS
      SELECT DISTINCT(eng_revised_items_ifce_key) item_ifce_key
        FROM bom_ref_desgs_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get reference designators with the current revised component's ifce key

    CURSOR GetRfdWithCurrCompifce IS
      SELECT COMPONENT_REFERENCE_DESIGNATOR,last_update_date,last_update_login,
             last_updated_by, creation_date,created_by, ref_designator_comment,
             change_notice, component_sequence_id,acd_type, request_id,
             program_application_id, program_id, program_update_date,
             attribute_category, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15,
             new_designator, process_flag, transaction_id, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, ORGANIZATION_CODE, ORGANIZATION_ID,
             ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR, COMPONENT_ITEM_ID,
             BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_ref_desgs_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_ref_desgs_interface
       WHERE bom_inventory_comps_ifce_key = g_revised_comp_ifce_key
         AND interface_entity_type = 'ECO'
         AND process_flag = 1
         AND (g_all_org = 1
             OR
             (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more revised components.
    -- Group reference desgs by revised component ifce values

    CURSOR GetRfdWithSameCompifce IS
      SELECT DISTINCT(bom_inventory_comps_ifce_key) comp_ifce_key
        FROM bom_ref_desgs_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get all other reference designators

    CURSOR GetRfd IS
      SELECT COMPONENT_REFERENCE_DESIGNATOR,last_update_date,last_update_login,
             last_updated_by, creation_date,created_by, ref_designator_comment,
             change_notice, component_sequence_id,acd_type, request_id,
             program_application_id, program_id, program_update_date,
             attribute_category, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9, attribute10,
             attribute11, attribute12, attribute13, attribute14, attribute15,
             new_designator, process_flag, transaction_id, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, ORGANIZATION_CODE, ORGANIZATION_ID,
             ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR, COMPONENT_ITEM_ID,
             BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_ref_desgs_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_ref_desgs_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                 (g_all_org = 2 AND organization_id = g_org_id));

    -- Get substitute components with the current ECO Header's ifce key

    CURSOR GetSbcWithCurrECOifce IS
      SELECT substitute_component_id, last_update_date, last_updated_by, creation_date,
             created_by, last_update_login, substitute_item_quantity,
             component_sequence_id, acd_type, change_notice, request_id,
             program_application_id, program_update_date, attribute_category, attribute1,
             attribute2, attribute4, attribute5, attribute6, attribute8, attribute9,
             attribute10, attribute12, attribute13, attribute14, attribute15, program_id,
             attribute3, attribute7, attribute11, new_sub_comp_id, process_flag,
             transaction_id, NEW_SUB_COMP_NUMBER, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, SUBSTITUTE_COMP_NUMBER, ORGANIZATION_CODE,
             ORGANIZATION_ID, ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR,
             COMPONENT_ITEM_ID, BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_sub_comps_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_sub_comps_interface
       WHERE eng_changes_ifce_key = g_ECO_ifce_key
             and process_flag = 1
             AND (g_all_org = 1
                  OR
                 (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more ECO headers.
    -- Group substitute components by ECO Header ifce values

    CURSOR GetSbcWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM bom_sub_comps_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

   -- Get substitute components with the current revised item's ifce key

   CURSOR GetSbcWithCurrItemifce IS
      SELECT substitute_component_id, last_update_date, last_updated_by, creation_date,
             created_by, last_update_login, substitute_item_quantity,
             component_sequence_id, acd_type, change_notice, request_id,
             program_application_id, program_update_date, attribute_category, attribute1,
             attribute2, attribute4, attribute5, attribute6, attribute8, attribute9,
             attribute10, attribute12, attribute13, attribute14, attribute15, program_id,
             attribute3, attribute7, attribute11, new_sub_comp_id, process_flag,
             transaction_id, NEW_SUB_COMP_NUMBER, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, SUBSTITUTE_COMP_NUMBER, ORGANIZATION_CODE,
             ORGANIZATION_ID, ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR,
             COMPONENT_ITEM_ID, BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_sub_comps_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_sub_comps_interface
       WHERE eng_revised_items_ifce_key = g_revised_item_ifce_key
         AND interface_entity_type = 'ECO'
         AND process_flag = 1
         AND (g_all_org = 1
             OR
             (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more revised items.
    -- Group substitute components by revised item ifce values

    CURSOR GetSbcWithSameItemifce IS
      SELECT DISTINCT(eng_revised_items_ifce_key) item_ifce_key
        FROM bom_sub_comps_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get substitute components with the current revised component's ifce key

    CURSOR GetSbcWithCurrCompifce IS
      SELECT substitute_component_id, last_update_date, last_updated_by, creation_date,
             created_by, last_update_login, substitute_item_quantity,
             component_sequence_id, acd_type, change_notice, request_id,
             program_application_id, program_update_date, attribute_category, attribute1,
             attribute2, attribute4, attribute5, attribute6, attribute8, attribute9,
             attribute10, attribute12, attribute13, attribute14, attribute15, program_id,
             attribute3, attribute7, attribute11, new_sub_comp_id, process_flag,
             transaction_id, NEW_SUB_COMP_NUMBER, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, SUBSTITUTE_COMP_NUMBER, ORGANIZATION_CODE,
             ORGANIZATION_ID, ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR,
             COMPONENT_ITEM_ID, BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_sub_comps_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_sub_comps_interface
       WHERE bom_inventory_comps_ifce_key = g_revised_comp_ifce_key
         AND interface_entity_type = 'ECO'
         AND process_flag = 1
         AND (g_all_org = 1
             OR
             (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more revised components.
    -- Group substitute components by revised component ifce values

    CURSOR GetSbcWithSameCompifce IS
      SELECT DISTINCT(bom_inventory_comps_ifce_key) comp_ifce_key
        FROM bom_sub_comps_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                  (g_all_org = 2 AND organization_id = g_org_id));

    -- Get all other substitute components

    CURSOR GetSbc IS
      SELECT substitute_component_id, last_update_date, last_updated_by, creation_date,
             created_by, last_update_login, substitute_item_quantity,
             component_sequence_id, acd_type, change_notice, request_id,
             program_application_id, program_update_date, attribute_category, attribute1,
             attribute2, attribute4, attribute5, attribute6, attribute8, attribute9,
             attribute10, attribute12, attribute13, attribute14, attribute15, program_id,
             attribute3, attribute7, attribute11, new_sub_comp_id, process_flag,
             transaction_id, NEW_SUB_COMP_NUMBER, ASSEMBLY_ITEM_NUMBER,
             COMPONENT_ITEM_NUMBER, SUBSTITUTE_COMP_NUMBER, ORGANIZATION_CODE,
             ORGANIZATION_ID, ASSEMBLY_ITEM_ID, ALTERNATE_BOM_DESIGNATOR,
             COMPONENT_ITEM_ID, BILL_SEQUENCE_ID, OPERATION_SEQ_NUM, EFFECTIVITY_DATE,
             interface_entity_type, transaction_type, eng_changes_ifce_key,
             eng_revised_items_ifce_key, bom_inventory_comps_ifce_key,
             bom_sub_comps_ifce_key
             --Bug 3396529: Added New_revised_Item_Revision
             , New_revised_Item_Revision
        FROM bom_sub_comps_interface
       WHERE process_flag = 1
             AND (g_all_org = 1
                  OR
                 (g_all_org = 2 AND organization_id = g_org_id));


    -- Called when there are no more ECO headers.
    -- Group ECO Revised Resources by ECO Header ifce values

    CURSOR GetRevResWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM bom_op_resources_interface
       WHERE process_flag = 1
              AND (g_all_org = 1
                   OR
                   (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more ECO headers.
    -- Group ECO Revised Operations by ECO Header ifce values

    CURSOR GetRevOpWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key
        FROM bom_op_sequences_interface
       WHERE process_flag = 1
              AND (g_all_org = 1
                   OR
                   (g_all_org = 2 AND organization_id = g_org_id));

    -- Called when there are no more ECO headers.
    -- Group ECO revisions by ECO Header ifce values

    CURSOR GetLinesWithSameECOifce IS
      SELECT DISTINCT(eng_changes_ifce_key) eco_ifce_key -- Bug 4033384
        FROM eng_change_lines_interface
       WHERE process_flag = 1
              AND (g_all_org = 1
                   OR
                   (g_all_org = 2 AND organization_id = g_org_id));


PROCEDURE Update_Interface_Tables(p_return_status VARCHAR2)
IS
  l_process_flag  NUMBER;
BEGIN
  IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
    l_process_flag := G_PF_SUCCESS;
  ELSE
    l_process_flag := G_PF_ERROR;
  END IF;

  UPDATE eng_eng_changes_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE eng_eco_revisions_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE eng_change_lines_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE eng_revised_items_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE bom_inventory_comps_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE bom_sub_comps_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE bom_ref_desgs_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE bom_op_resources_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE bom_op_sequences_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  UPDATE bom_sub_op_resources_interface
  SET PROCESS_FLAG = l_process_flag
  WHERE ENG_CHANGES_IFCE_KEY = g_ECO_ifce_key;

  --Bug No: 3737881
  --Updating the Error interface tables and the concurrent log
  Error_Handler.Write_To_ConcurrentLog;
  Error_Handler.WRITE_TO_INTERFACETABLE;
END Update_Interface_Tables;


PROCEDURE Update_Eco_Interface (
    p_eco_rec           ENG_Eco_PUB.Eco_Rec_Type
) IS
BEGIN
         UPDATE eng_eng_changes_interface
            SET ATTRIBUTE7                 = p_eco_rec.attribute7
    ,       ATTRIBUTE8                     = p_eco_rec.attribute8
    ,       ATTRIBUTE9                     = p_eco_rec.attribute9
    ,       ATTRIBUTE10                    = p_eco_rec.attribute10
    ,       ATTRIBUTE11                    = p_eco_rec.attribute11
    ,       ATTRIBUTE12                    = p_eco_rec.attribute12
    ,       ATTRIBUTE13                    = p_eco_rec.attribute13
    ,       ATTRIBUTE14                    = p_eco_rec.attribute14
    ,       ATTRIBUTE15                    = p_eco_rec.attribute15
--    ,       REQUEST_ID                     = p_eco_rec.request_id
--    ,       PROGRAM_APPLICATION_ID         = p_eco_rec.program_application_id
--    ,       PROGRAM_ID                     = p_eco_rec.program_id
--    ,       PROGRAM_UPDATE_DATE            = p_eco_rec.program_update_date
--    ,       APPROVAL_STATUS_TYPE           = p_eco_rec.approval_status_type
    ,       APPROVAL_DATE                  = p_eco_rec.approval_date
--    ,       APPROVAL_LIST_ID               = p_eco_rec.approval_list_id
--    ,       CHANGE_ORDER_TYPE_ID           = p_eco_rec.change_order_type_id
--    ,       RESPONSIBLE_ORGANIZATION_ID    = p_eco_rec.responsible_org_id
    ,       APPROVAL_REQUEST_DATE          = p_eco_rec.approval_request_date
--    ,       CHANGE_NOTICE                  = p_eco_rec.change_notice
--    ,       ORGANIZATION_ID                = p_eco_rec.organization_id
--    ,       LAST_UPDATE_DATE               = p_eco_rec.last_update_date
--    ,       LAST_UPDATED_BY                = p_eco_rec.last_updated_by
--    ,       CREATION_DATE                  = p_eco_rec.creation_date
--    ,       CREATED_BY                     = p_eco_rec.created_by
--    ,       LAST_UPDATE_LOGIN              = p_eco_rec.last_update_login
    ,       DESCRIPTION                    = p_eco_rec.description
--    ,       STATUS_TYPE                    = p_eco_rec.status_type
--    ,       INITIATION_DATE                = p_eco_rec.initiation_date
--    ,       IMPLEMENTATION_DATE            = p_eco_rec.implementation_date
--    ,       CANCELLATION_DATE              = p_eco_rec.cancellation_date
    ,       CANCELLATION_COMMENTS          = p_eco_rec.cancellation_comments
    ,       PRIORITY_CODE                  = p_eco_rec.priority_code
    ,       REASON_CODE                    = p_eco_rec.reason_code
--    ,       ESTIMATED_ENG_COST             = p_eco_rec.estimated_eng_cost
--    ,       ESTIMATED_MFG_COST             = p_eco_rec.estimated_mfg_cost
--    ,       REQUESTOR_ID                   = p_eco_rec.requestor_id
    ,       ATTRIBUTE_CATEGORY             = p_eco_rec.attribute_category
    ,       ATTRIBUTE1                     = p_eco_rec.attribute1
    ,       ATTRIBUTE2                     = p_eco_rec.attribute2
    ,       ATTRIBUTE3                     = p_eco_rec.attribute3
    ,       ATTRIBUTE4                     = p_eco_rec.attribute4
    ,       ATTRIBUTE5                     = p_eco_rec.attribute5
    ,       ATTRIBUTE6                     = p_eco_rec.attribute6
    ,       process_flag                       = G_PF_SUCCESS   --, p_eco_rec.process_flag
    ,       APPROVAL_LIST_NAME             = p_eco_rec.approval_list_name
--    ,     CHANGE_ORDER_TYPE              = p_eco_rec.change_order_type
    ,       ORGANIZATION_CODE              = p_eco_rec.organization_code
--    ,     RESPONSIBLE_ORG_CODE           = p_eco_rec.responsible_org_code
    WHERE   transaction_id = p_eco_rec.transaction_id
    ;
END Update_Eco_Interface;


PROCEDURE Update_Eco_Revisions_Interface (
    p_rev_tbl           ENG_Eco_PUB.Eco_Revision_Tbl_Type
) IS
BEGIN
   FOR i IN 1..p_rev_tbl.COUNT LOOP
      UPDATE eng_eco_revisions_interface SET
        attribute11             = p_rev_tbl(i).attribute11,
        attribute12             = p_rev_tbl(i).attribute12,
        attribute13             = p_rev_tbl(i).attribute13,
        attribute14             = p_rev_tbl(i).attribute14,
        attribute15             = p_rev_tbl(i).attribute15,
--        revision_id           = p_rev_tbl(i).revision_id,
        comments                = p_rev_tbl(i).comments,
--      program_application_id  = p_rev_tbl(i).program_application_id,
--      program_id              = p_rev_tbl(i).program_id,
--      program_update_date     = p_rev_tbl(i).program_update_date,
--      request_id              = p_rev_tbl(i).request_id,
--      change_notice           = p_rev_tbl(i).change_notice,
--      organization_id         = p_rev_tbl(i).organization_id,
--      revision                = p_rev_tbl(i).rev,
--      last_update_date        = p_rev_tbl(i).last_update_date,
--      last_updated_by         = p_rev_tbl(i).last_updated_by,
--      creation_date           = p_rev_tbl(i).creation_date,
--      created_by              = p_rev_tbl(i).created_by,
--      last_update_login       = p_rev_tbl(i).last_update_login,
        attribute_category      = p_rev_tbl(i).attribute_category,
        attribute1              = p_rev_tbl(i).attribute1,
        attribute2              = p_rev_tbl(i).attribute2,
        attribute3              = p_rev_tbl(i).attribute3,
        attribute4              = p_rev_tbl(i).attribute4,
        attribute5              = p_rev_tbl(i).attribute5,
        attribute6              = p_rev_tbl(i).attribute6,
        attribute7              = p_rev_tbl(i).attribute7,
        attribute8              = p_rev_tbl(i).attribute8,
        attribute9              = p_rev_tbl(i).attribute9,
        attribute10             = p_rev_tbl(i).attribute10,
        new_revision            = p_rev_tbl(i).new_revision,
        organization_code       = p_rev_tbl(i).organization_code,
    process_flag                = G_PF_SUCCESS   --, p_rev_tbl(i).process_flag
      WHERE transaction_id      = p_rev_tbl(i).transaction_id;
   END LOOP;
END Update_Eco_Revisions_Interface;


PROCEDURE Update_Revised_Items_Interface (
    p_rev_item_tbl              ENG_Eco_PUB.Revised_Item_Tbl_Type
) IS
BEGIN
   FOR i IN 1..p_rev_item_tbl.COUNT LOOP
      UPDATE eng_revised_items_interface SET
--      change_notice           = p_rev_item_tbl(i).change_notice,
--      organization_id         = p_rev_item_tbl(i).organization_id,
--      revised_item_id         = p_rev_item_tbl(i).revised_item_id,
--      last_update_date        = p_rev_item_tbl(i).last_update_date,
--      last_updated_by         = p_rev_item_tbl(i).last_updated_by,
--      creation_date           = p_rev_item_tbl(i).creation_date,
--      created_by              = p_rev_item_tbl(i).created_by,
--      last_update_login       = p_rev_item_tbl(i).last_update_login,
--      implementation_date     = p_rev_item_tbl(i).implementation_date,
--      cancellation_date       = p_rev_item_tbl(i).cancellation_date,
        cancel_comments         = p_rev_item_tbl(i).cancel_comments,
        disposition_type        = p_rev_item_tbl(i).disposition_type,
--      new_item_revision       = p_rev_item_tbl(i).new_item_revision,
--      early_schedule_date     = p_rev_item_tbl(i).early_schedule_date,
        attribute_category      = p_rev_item_tbl(i).attribute_category,
        attribute1              = p_rev_item_tbl(i).attribute1,
        attribute2              = p_rev_item_tbl(i).attribute2,
        attribute3              = p_rev_item_tbl(i).attribute3,
        attribute4              = p_rev_item_tbl(i).attribute4,
        attribute5              = p_rev_item_tbl(i).attribute5,
        attribute6              = p_rev_item_tbl(i).attribute6,
        attribute7              = p_rev_item_tbl(i).attribute7,
        attribute8              = p_rev_item_tbl(i).attribute8,
        attribute9              = p_rev_item_tbl(i).attribute9,
        attribute10             = p_rev_item_tbl(i).attribute10,
        attribute11             = p_rev_item_tbl(i).attribute11,
        attribute12             = p_rev_item_tbl(i).attribute12,
        attribute13             = p_rev_item_tbl(i).attribute13,
        attribute14             = p_rev_item_tbl(i).attribute14,
        attribute15             = p_rev_item_tbl(i).attribute15,
        status_type             = p_rev_item_tbl(i).status_type,
--      scheduled_date          = p_rev_item_tbl(i).scheduled_date,
--      bill_sequence_id        = p_rev_item_tbl(i).bill_sequence_id,
        mrp_active              = p_rev_item_tbl(i).mrp_active,
--      request_id              = p_rev_item_tbl(i).request_id,
--      program_application_id  = p_rev_item_tbl(i).program_application_id,
--      program_id              = p_rev_item_tbl(i).program_id,
--      program_update_date     = p_rev_item_tbl(i).program_update_date,
        update_wip              = p_rev_item_tbl(i).update_wip,
--      use_up                  = p_rev_item_tbl(i).use_up,
--      use_up_item_id          = p_rev_item_tbl(i).use_up_item_id,
--      revised_item_sequence_id = p_rev_item_tbl(i).revised_item_sequence_id,
        use_up_plan_name        = p_rev_item_tbl(i).use_up_plan_name,
--      descriptive_text        = p_rev_item_tbl(i).descriptive_text,
--      auto_implement_date     = p_rev_item_tbl(i).auto_implement_date,
--      requestor_id            = p_rev_item_tbl(i).requestor_id,
--      comments                = p_rev_item_tbl(i).comments,
        process_flag            = G_PF_SUCCESS,     --p_rev_item_tbl(i).process_flag,
        organization_code       = p_rev_item_tbl(i).organization_code,
        revised_item_number     = p_rev_item_tbl(i).revised_item_name,
        use_up_item_number      = p_rev_item_tbl(i).use_up_item_name  --,
--      alternate_bom_designator = p_rev_item_tbl(i).alternate_bom_designator
      WHERE transaction_id      = p_rev_item_tbl(i).transaction_id;
   END LOOP;
END Update_Revised_Items_Interface;


PROCEDURE Update_Revised_Comps_Interface (
    p_rev_comp_tbl              BOM_Bo_PUB.Rev_Component_Tbl_Type
) IS
BEGIN
   FOR i IN 1..p_rev_comp_tbl.COUNT LOOP
      UPDATE bom_inventory_comps_interface SET
        supply_subinventory     = p_rev_comp_tbl(i).supply_subinventory,
--      operation_lead_time_percent    = p_rev_comp_tbl(i).op_lead_time_percent,
--      revised_item_sequence_id = p_rev_comp_tbl(i).revised_item_sequence_id,
--      cost_factor             = p_rev_comp_tbl(i).cost_factor,
        required_for_revenue    = p_rev_comp_tbl(i).required_for_revenue,
--      high_quantity           = p_rev_comp_tbl(i).high_quantity,
--      component_sequence_id   = p_rev_comp_tbl(i).component_sequence_id,
--      program_application_id  = p_rev_comp_tbl(i).program_application_id,
        wip_supply_type         = p_rev_comp_tbl(i).wip_supply_type,
--      supply_locator_id       = p_rev_comp_tbl(i).supply_locator_id,
--      bom_item_type           = p_rev_comp_tbl(i).bom_item_type,
--      operation_seq_num       = p_rev_comp_tbl(i).operation_seq_num,
--      component_item_id       = p_rev_comp_tbl(i).component_item_id,
--      last_update_date        = p_rev_comp_tbl(i).last_update_date,
--      last_updated_by         = p_rev_comp_tbl(i).last_updated_by,
--      creation_date           = p_rev_comp_tbl(i).creation_date,
--      created_by              = p_rev_comp_tbl(i).created_by,
--      last_update_login       = p_rev_comp_tbl(i).last_update_login,
--      item_num                = p_rev_comp_tbl(i).item_num,
--      component_quantity      = p_rev_comp_tbl(i).component_quantity,
--      component_yield_factor  = p_rev_comp_tbl(i).component_yield_factor,
--      component_remarks       = p_rev_comp_tbl(i).component_remarks,
--      effectivity_date        = p_rev_comp_tbl(i).effectivity_date,
--      change_notice           = p_rev_comp_tbl(i).change_notice,
--      implementation_date     = p_rev_comp_tbl(i).implementation_date,
        disable_date            = p_rev_comp_tbl(i).disable_date,
        attribute_category      = p_rev_comp_tbl(i).attribute_category,
        attribute1              = p_rev_comp_tbl(i).attribute1,
        attribute2              = p_rev_comp_tbl(i).attribute2,
        attribute3              = p_rev_comp_tbl(i).attribute3,
        attribute4              = p_rev_comp_tbl(i).attribute4,
        attribute5              = p_rev_comp_tbl(i).attribute5,
        attribute6              = p_rev_comp_tbl(i).attribute6,
        attribute7              = p_rev_comp_tbl(i).attribute7,
        attribute8              = p_rev_comp_tbl(i).attribute8,
        attribute9              = p_rev_comp_tbl(i).attribute9,
        attribute10             = p_rev_comp_tbl(i).attribute10,
        attribute11             = p_rev_comp_tbl(i).attribute11,
        attribute12             = p_rev_comp_tbl(i).attribute12,
        attribute13             = p_rev_comp_tbl(i).attribute13,
        attribute14             = p_rev_comp_tbl(i).attribute14,
        attribute15             = p_rev_comp_tbl(i).attribute15,
--      planning_factor         = p_rev_comp_tbl(i).planning_factor,
        quantity_related        = p_rev_comp_tbl(i).quantity_related,
        so_basis                = p_rev_comp_tbl(i).so_basis,
        optional                = p_rev_comp_tbl(i).optional,
--      mutually_exclusive_options  = p_rev_comp_tbl(i).mutually_exclusive_opt,
        include_in_cost_rollup  = p_rev_comp_tbl(i).include_in_cost_rollup,
        check_atp               = p_rev_comp_tbl(i).check_atp,
        shipping_allowed        = p_rev_comp_tbl(i).shipping_allowed,
        required_to_ship        = p_rev_comp_tbl(i).required_to_ship,
        include_on_ship_docs    = p_rev_comp_tbl(i).include_on_ship_docs,
--      include_on_bill_docs    = p_rev_comp_tbl(i).include_on_bill_docs,
--      low_quantity            = p_rev_comp_tbl(i).low_quantity,
        acd_type                = p_rev_comp_tbl(i).acd_type,
--      old_component_sequence_id = p_rev_comp_tbl(i).old_component_sequence_id,
--      bill_sequence_id        = p_rev_comp_tbl(i).bill_sequence_id,
--      request_id              = p_rev_comp_tbl(i).request_id,
--      program_id              = p_rev_comp_tbl(i).program_id,
--      program_update_date     = p_rev_comp_tbl(i).program_update_date,
--      pick_components         = p_rev_comp_tbl(i).pick_components,
--      assembly_type           = p_rev_comp_tbl(i).assembly_type,
--      interface_entity_type   = p_rev_comp_tbl(i).interface_entity_type,
--      reference_designator    = p_rev_comp_tbl(i).reference_designator,
        new_effectivity_date    = p_rev_comp_tbl(i).new_effectivity_date,
        old_effectivity_date    = p_rev_comp_tbl(i).old_effectivity_date,
--      substitute_comp_id      = p_rev_comp_tbl(i).substitute_comp_id,
--      new_operation_seq_num   = p_rev_comp_tbl(i).new_operation_seq_num,
--      old_operation_seq_num   = p_rev_comp_tbl(i).old_operation_seq_num,
--      substitute_comp_number  = p_rev_comp_tbl(i).substitute_comp_number,
        organization_code       = p_rev_comp_tbl(i).organization_code,
--      assembly_item_number    = p_rev_comp_tbl(i).assembly_item_number,
--      component_item_number   = p_rev_comp_tbl(i).component_item_number,
        location_name           = p_rev_comp_tbl(i).location_name   ,
--      organization_id         = p_rev_comp_tbl(i).organization_id,
--      assembly_item_id        = p_rev_comp_tbl(i).assembly_item_id,
--      alternate_bom_designator = p_rev_comp_tbl(i).alternate_bom_designator,
--      process_flag            = p_rev_comp_tbl(i).process_flag,
     basis_type                = p_rev_comp_tbl(i).basis_type
      WHERE transaction_id      = p_rev_comp_tbl(i).row_identifier;
   END LOOP;
END Update_Revised_Comps_Interface;


PROCEDURE Update_Sub_Comps_Interface (
    p_sub_comp_tbl              BOM_Bo_PUB.Sub_Component_Tbl_Type
) IS
BEGIN
   FOR i IN 1..p_sub_comp_tbl.COUNT LOOP
      UPDATE bom_sub_comps_interface SET
--      substitute_component_id = p_sub_comp_tbl(i).substitute_component_id,
--      last_update_date        = p_sub_comp_tbl(i).last_update_date,
--      last_updated_by         = p_sub_comp_tbl(i).last_updated_by,
--      creation_date           = p_sub_comp_tbl(i).creation_date,
--      created_by              = p_sub_comp_tbl(i).created_by,
--      last_update_login       = p_sub_comp_tbl(i).last_update_login,
        substitute_item_quantity = p_sub_comp_tbl(i).substitute_item_quantity,
--      component_sequence_id   = p_sub_comp_tbl(i).component_sequence_id,
        acd_type                = p_sub_comp_tbl(i).acd_type,
--      change_notice           = p_sub_comp_tbl(i).change_notice,
--      request_id              = p_sub_comp_tbl(i).request_id,
--      program_application_id  = p_sub_comp_tbl(i).program_application_id,
--      program_update_date     = p_sub_comp_tbl(i).program_update_date,
        attribute_category      = p_sub_comp_tbl(i).attribute_category,
        attribute1              = p_sub_comp_tbl(i).attribute1,
        attribute2              = p_sub_comp_tbl(i).attribute2,
        attribute3              = p_sub_comp_tbl(i).attribute3,
        attribute4              = p_sub_comp_tbl(i).attribute4,
        attribute5              = p_sub_comp_tbl(i).attribute5,
        attribute6              = p_sub_comp_tbl(i).attribute6,
        attribute7              = p_sub_comp_tbl(i).attribute7,
        attribute8              = p_sub_comp_tbl(i).attribute8,
        attribute9              = p_sub_comp_tbl(i).attribute9,
        attribute10             = p_sub_comp_tbl(i).attribute10,
        attribute11             = p_sub_comp_tbl(i).attribute11,
        attribute12             = p_sub_comp_tbl(i).attribute12,
        attribute13             = p_sub_comp_tbl(i).attribute13,
        attribute14             = p_sub_comp_tbl(i).attribute14,
        attribute15             = p_sub_comp_tbl(i).attribute15,
        program_id                  = p_sub_comp_tbl(i).program_id,
--      new_sub_comp_id         = p_sub_comp_tbl(i).new_sub_comp_id,
--      process_flag            = p_sub_comp_tbl(i).process_flag,
--      new_sub_comp_number     = p_sub_comp_tbl(i).new_sub_comp_number,
--      assembly_item_number    = p_sub_comp_tbl(i).assembly_item_number,
--      component_item_number   = p_sub_comp_tbl(i).component_item_number,
--      substitute_comp_number  = p_sub_comp_tbl(i).substitute_comp_number,
        organization_code       = p_sub_comp_tbl(i).organization_code  --,
--      organization_id         = p_sub_comp_tbl(i).organization_id,
--      assembly_item_id        = p_sub_comp_tbl(i).assembly_item_id,
--      alternate_bom_designator = p_sub_comp_tbl(i).alternate_bom_designator,
--      component_item_id       = p_sub_comp_tbl(i).component_item_id,
--      bill_sequence_id        = p_sub_comp_tbl(i).bill_sequence_id,
--      operation_seq_num       = p_sub_comp_tbl(i).operation_seq_num,
--      effectivity_date        = p_sub_comp_tbl(i).effectivity_date,
--      interface_entity_type   = p_sub_comp_tbl(i).interface_entity_type
      WHERE transaction_id      = p_sub_comp_tbl(i).row_identifier;
   END LOOP;
END Update_Sub_Comps_Interface;


PROCEDURE Update_Ref_Desig_Interface (
    p_ref_desg_tbl              BOM_Bo_PUB.Ref_Designator_Tbl_Type
) IS
BEGIN
   FOR i IN 1..p_ref_desg_tbl.COUNT LOOP
      UPDATE bom_ref_desgs_interface SET
--      component_reference_designator = p_ref_desg_tbl(i).ref_designator,
--      last_update_date        = p_ref_desg_tbl(i).last_update_date,
--      last_updated_by         = p_ref_desg_tbl(i).last_updated_by,
--      creation_date           = p_ref_desg_tbl(i).creation_date,
--      created_by              = p_ref_desg_tbl(i).created_by,
--      last_update_login       = p_ref_desg_tbl(i).last_update_login,
        ref_designator_comment  = p_ref_desg_tbl(i).ref_designator_comment,
--      change_notice           = p_ref_desg_tbl(i).change_notice,
--      component_sequence_id   = p_ref_desg_tbl(i).component_sequence_id,
        acd_type                = p_ref_desg_tbl(i).acd_type,
--      request_id              = p_ref_desg_tbl(i).request_id,
--      program_application_id  = p_ref_desg_tbl(i).program_application_id,
--      program_id              = p_ref_desg_tbl(i).program_id,
--      program_update_date     = p_ref_desg_tbl(i).program_update_date,
        attribute_category      = p_ref_desg_tbl(i).attribute_category,
        attribute1              = p_ref_desg_tbl(i).attribute1,
        attribute2              = p_ref_desg_tbl(i).attribute2,
        attribute3              = p_ref_desg_tbl(i).attribute3,
        attribute4              = p_ref_desg_tbl(i).attribute4,
        attribute5              = p_ref_desg_tbl(i).attribute5,
        attribute6              = p_ref_desg_tbl(i).attribute6,
        attribute7              = p_ref_desg_tbl(i).attribute7,
        attribute8              = p_ref_desg_tbl(i).attribute8,
        attribute9              = p_ref_desg_tbl(i).attribute9,
        attribute10             = p_ref_desg_tbl(i).attribute10,
        attribute11             = p_ref_desg_tbl(i).attribute11,
        attribute12             = p_ref_desg_tbl(i).attribute12,
        attribute13             = p_ref_desg_tbl(i).attribute13,
        attribute14             = p_ref_desg_tbl(i).attribute14,
        attribute15             = p_ref_desg_tbl(i).attribute15,
--      new_designator         = p_ref_desg_tbl(i).new_designator,
--      process_flag            = p_ref_desg_tbl(i).process_flag,
--      assembly_item_number    = p_ref_desg_tbl(i).assembly_item_number,
--      component_item_number   = p_ref_desg_tbl(i).component_item_number,
        organization_code       = p_ref_desg_tbl(i).organization_code --,
--      organization_id         = p_ref_desg_tbl(i).organization_id,
--      assembly_item_id        = p_ref_desg_tbl(i).assembly_item_id,
--      alternate_bom_designator = p_ref_desg_tbl(i).alternate_bom_designator,
--      component_item_id       = p_ref_desg_tbl(i).component_item_id,
--      bill_sequence_id        = p_ref_desg_tbl(i).bill_sequence_id,
--      operation_seq_num       = p_ref_desg_tbl(i).operation_seq_num,
--      effectivity_date        = p_ref_desg_tbl(i).effectivity_date,
--      interface_entity_type   = p_ref_desg_tbl(i).interface_entity_type
      WHERE transaction_id      = p_ref_desg_tbl(i).row_identifier;
   END LOOP;
END Update_Ref_Desig_Interface;

/*
PROCEDURE Update_Error_Table (
    p_error_tbl             ENG_Eco_PUB.Error_Tbl_Type,
    p_top_ifce_key          VARCHAR2 DEFAULT NULL,
    x_unexp_error       OUT NOCOPY VARCHAR2
) IS
BEGIN
   FOR i IN 1..p_error_tbl.COUNT LOOP
      IF (p_error_tbl(i).message_name is NOT NULL) THEN
         INSERT INTO mtl_interface_errors
         (ORGANIZATION_ID,
          UNIQUE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          TABLE_NAME,
          MESSAGE_NAME,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          ERROR_MESSAGE,
          TRANSACTION_ID)
          VALUES
         (p_error_tbl(i).organization_id,
          mtl_system_items_interface_s.nextval,
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID,
          p_error_tbl(i).table_name,
          p_error_tbl(i).message_name,
          FND_GLOBAL.CONC_REQUEST_ID,
          FND_GLOBAL.PROG_APPL_ID,
          FND_GLOBAL.CONC_PROGRAM_ID,
          sysdate,
          p_error_tbl(i).error_message,
          p_error_tbl(i).transaction_id);
      ELSE
           FND_MESSAGE.Set_Name('ENG', 'ENG_ECOOI_UNEXPECTED_ERROR');
           FND_MESSAGE.Set_Token('ERROR', p_error_tbl(i).error_message);
           FND_MESSAGE.Set_Token('TRANSACTION_ID',
                                to_char(p_error_tbl(i).transaction_id));
           FND_MESSAGE.Set_Token('IFCE_KEY', p_top_ifce_key);

           x_unexp_error := substr(FND_MESSAGE.Get, 1, 1000);
         EXIT;
      END IF;
   END LOOP;
END Update_Error_Table;
*/
-- Procedure Get_Revs_With_Curr_ECO_Ifce
-- Pick up all ECO revisions with the current ECO ifce key value

PROCEDURE Get_Revs_With_Curr_ECO_Ifce
IS
    q                           number;
    stmt_num                    number;
BEGIN
      q := 0;
      FOR c7rec IN GetRevWithCurrECOifce LOOP
         q := q + 1;
         g_public_rev_tbl(q).attribute11 := c7rec.attribute11;
         g_public_rev_tbl(q).attribute12 := c7rec.attribute12;
         g_public_rev_tbl(q).attribute13 := c7rec.attribute13;
         g_public_rev_tbl(q).attribute14 := c7rec.attribute14;
         g_public_rev_tbl(q).attribute15 := c7rec.attribute15;
--         g_public_rev_tbl(q).program_application_id := c7rec.program_application_id;
--         g_public_rev_tbl(q).program_id := c7rec.program_id;
--         g_public_rev_tbl(q).program_update_date := c7rec.program_update_date;
--         g_public_rev_tbl(q).request_id := c7rec.request_id;
--         g_public_rev_tbl(q).revision_id := c7rec.revision_id;
         g_public_rev_tbl(q).eco_name := c7rec.change_notice;
--         g_public_rev_tbl(q).organization_id := c7rec.organization_id;
         g_public_rev_tbl(q).revision := c7rec.revision;
--         g_public_rev_tbl(q).last_update_date := c7rec.last_update_date;
--         g_public_rev_tbl(q).last_updated_by := c7rec.last_updated_by;
--         g_public_rev_tbl(q).creation_date := c7rec.creation_date;
--         g_public_rev_tbl(q).created_by := c7rec.created_by;
--         g_public_rev_tbl(q).last_update_login := c7rec.last_update_login;
         g_public_rev_tbl(q).comments := c7rec.comments;
         g_public_rev_tbl(q).attribute_category := c7rec.attribute_category;
         g_public_rev_tbl(q).attribute1 := c7rec.attribute1;
         g_public_rev_tbl(q).attribute2 := c7rec.attribute2;
         g_public_rev_tbl(q).attribute3 := c7rec.attribute3;
         g_public_rev_tbl(q).attribute4 := c7rec.attribute4;
         g_public_rev_tbl(q).attribute5 := c7rec.attribute5;
         g_public_rev_tbl(q).attribute6 := c7rec.attribute6;
         g_public_rev_tbl(q).attribute7 := c7rec.attribute7;
         g_public_rev_tbl(q).attribute8 := c7rec.attribute8;
         g_public_rev_tbl(q).attribute9 := c7rec.attribute9;
         g_public_rev_tbl(q).attribute10 := c7rec.attribute10;
         g_public_rev_tbl(q).new_revision := c7rec.new_revision;
             g_public_rev_tbl(q).organization_code := c7rec.organization_code;
--         g_public_rev_tbl(q).process_flag := c7rec.process_flag;
         g_public_rev_tbl(q).transaction_id := c7rec.transaction_id;
         g_public_rev_tbl(q).transaction_type := c7rec.transaction_type;
      END LOOP; -- END ECO REV LOOP
END Get_Revs_With_Curr_ECO_Ifce;

-- Procedure Get_Items_With_Curr_ECO_Ifce
-- Pick up all revised items with ECO ifce key = g_ECO_ifce_key

PROCEDURE Get_Items_With_Curr_ECO_Ifce
IS
    k                           number;
BEGIN
         k := 0;
         FOR c3rec IN GetItemWithCurrECOifce LOOP
            k := k + 1;
            g_encoin_rev_item_tbl(k).change_notice := c3rec.change_notice;
            g_encoin_rev_item_tbl(k).organization_id := c3rec.organization_id;
            g_encoin_rev_item_tbl(k).revised_item_id := c3rec.revised_item_id;
            g_encoin_rev_item_tbl(k).last_update_date := c3rec.last_update_date;
            g_encoin_rev_item_tbl(k).last_updated_by := c3rec.last_updated_by;
            g_encoin_rev_item_tbl(k).creation_date := c3rec.creation_date;
            g_encoin_rev_item_tbl(k).created_by := c3rec.created_by;
            g_encoin_rev_item_tbl(k).last_update_login := c3rec.last_update_login;
            g_encoin_rev_item_tbl(k).implementation_date := c3rec.implementation_date;
            g_encoin_rev_item_tbl(k).cancellation_date := c3rec.cancellation_date;
            g_encoin_rev_item_tbl(k).cancel_comments := c3rec.cancel_comments;
            g_encoin_rev_item_tbl(k).disposition_type := c3rec.disposition_type;
            g_encoin_rev_item_tbl(k).new_item_revision := c3rec.new_item_revision;
            g_encoin_rev_item_tbl(k).early_schedule_date := c3rec.early_schedule_date;
            g_encoin_rev_item_tbl(k).attribute_category := c3rec.attribute_category;
            g_encoin_rev_item_tbl(k).attribute2 := c3rec.attribute2;
            g_encoin_rev_item_tbl(k).attribute3 := c3rec.attribute3;
            g_encoin_rev_item_tbl(k).attribute4 := c3rec.attribute4;
            g_encoin_rev_item_tbl(k).attribute5 := c3rec.attribute5;
            g_encoin_rev_item_tbl(k).attribute7 := c3rec.attribute7;
            g_encoin_rev_item_tbl(k).attribute8 := c3rec.attribute8;
            g_encoin_rev_item_tbl(k).attribute9 := c3rec.attribute9;
            g_encoin_rev_item_tbl(k).attribute11 := c3rec.attribute11;
            g_encoin_rev_item_tbl(k).attribute12 := c3rec.attribute12;
            g_encoin_rev_item_tbl(k).attribute13 := c3rec.attribute13;
            g_encoin_rev_item_tbl(k).attribute14 := c3rec.attribute14;
            g_encoin_rev_item_tbl(k).attribute15 := c3rec.attribute15;
            g_encoin_rev_item_tbl(k).status_type := c3rec.status_type;
            g_encoin_rev_item_tbl(k).scheduled_date := c3rec.scheduled_date;
            g_encoin_rev_item_tbl(k).bill_sequence_id := c3rec.bill_sequence_id;
            g_encoin_rev_item_tbl(k).mrp_active := c3rec.mrp_active;
            g_encoin_rev_item_tbl(k).request_id := c3rec.request_id;
            g_encoin_rev_item_tbl(k).program_application_id := c3rec.program_application_id;
            g_encoin_rev_item_tbl(k).program_id := c3rec.program_id;
            g_encoin_rev_item_tbl(k).program_update_date := c3rec.program_update_date;
            g_encoin_rev_item_tbl(k).update_wip := c3rec.update_wip;
            g_encoin_rev_item_tbl(k).use_up := c3rec.use_up;
            g_encoin_rev_item_tbl(k).use_up_item_id := c3rec.use_up_item_id;
            g_encoin_rev_item_tbl(k).revised_item_sequence_id := c3rec.revised_item_sequence_id;
            g_encoin_rev_item_tbl(k).use_up_plan_name := c3rec.use_up_plan_name;
            g_encoin_rev_item_tbl(k).descriptive_text := c3rec.descriptive_text;
            g_encoin_rev_item_tbl(k).auto_implement_date := c3rec.auto_implement_date;
            g_encoin_rev_item_tbl(k).attribute1 := c3rec.attribute1;
            g_encoin_rev_item_tbl(k).attribute6 := c3rec.attribute6;
            g_encoin_rev_item_tbl(k).attribute10 := c3rec.attribute10;
            g_encoin_rev_item_tbl(k).requestor_id := c3rec.requestor_id;
            g_encoin_rev_item_tbl(k).comments := c3rec.comments;
            g_encoin_rev_item_tbl(k).process_flag := c3rec.process_flag;
            g_encoin_rev_item_tbl(k).transaction_id := c3rec.transaction_id;
            g_encoin_rev_item_tbl(k).organization_code := c3rec.organization_code;
            g_encoin_rev_item_tbl(k).revised_item_number := c3rec.revised_item_number;
            g_encoin_rev_item_tbl(k).new_rtg_revision := c3rec.new_rtg_revision;
            g_encoin_rev_item_tbl(k).use_up_item_number := c3rec.use_up_item_number;
            g_encoin_rev_item_tbl(k).alternate_bom_designator := c3rec.alternate_bom_designator;
            g_encoin_rev_item_tbl(k).operation := c3rec.transaction_type;
            g_encoin_rev_item_tbl(k).eng_revised_items_ifce_key := c3rec.ENG_REVISED_ITEMS_IFCE_KEY;
            g_encoin_rev_item_tbl(k).parent_revised_item_name  :=c3rec.parent_revised_item_name;
            g_encoin_rev_item_tbl(k).parent_alternate_name  :=c3rec.parent_alternate_name;
            g_encoin_rev_item_tbl(k).updated_item_revision := c3rec.updated_item_revision; -- Bug 3432944
            g_encoin_rev_item_tbl(k).New_scheduled_date := c3rec.New_scheduled_date; -- Bug 3432944
            g_encoin_rev_item_tbl(k).from_item_revision := c3rec.from_item_revision; -- 11.5.10E
            g_encoin_rev_item_tbl(k).new_revision_label := c3rec.new_revision_label;
            g_encoin_rev_item_tbl(k).New_Revised_Item_Rev_Desc := c3rec.New_Revised_Item_Rev_Desc;
            g_encoin_rev_item_tbl(k).new_revision_reason := c3rec.new_revision_reason;
            g_encoin_rev_item_tbl(k).from_end_item_unit_number := c3rec.from_end_item_unit_number; /*Bug 6377841*/
         END LOOP; -- End Rev Items Loop
END Get_Items_With_Curr_ECO_Ifce;

-- Procedure Get_Comps_With_Curr_ECO_Ifce
-- Pick up all revised components with ECO ifce key = g_ECO_ifce_key

PROCEDURE Get_Comps_With_Curr_ECO_Ifce
IS
    v                           number;
    stmt_num                    number;
BEGIN
         v := 0;
         FOR c12rec IN GetCompWithCurrECOifce LOOP
           v := v + 1;
           g_encoin_rev_comp_tbl(v).supply_subinventory := c12rec.supply_subinventory;
           g_encoin_rev_comp_tbl(v).OP_LEAD_TIME_PERCENT := c12rec.OPERATION_LEAD_TIME_PERCENT;
           g_encoin_rev_comp_tbl(v).revised_item_sequence_id := c12rec.revised_item_sequence_id;
           g_encoin_rev_comp_tbl(v).cost_factor := c12rec.cost_factor;
           g_encoin_rev_comp_tbl(v).required_for_revenue := c12rec.required_for_revenue;
           g_encoin_rev_comp_tbl(v).high_quantity := c12rec.high_quantity;
           g_encoin_rev_comp_tbl(v).component_sequence_id := c12rec.component_sequence_id;
           g_encoin_rev_comp_tbl(v).program_application_id := c12rec.program_application_id;
           g_encoin_rev_comp_tbl(v).wip_supply_type := c12rec.wip_supply_type;
           g_encoin_rev_comp_tbl(v).supply_locator_id := c12rec.supply_locator_id;
           g_encoin_rev_comp_tbl(v).bom_item_type := c12rec.bom_item_type;
           g_encoin_rev_comp_tbl(v).operation_seq_num := c12rec.operation_seq_num;
           g_encoin_rev_comp_tbl(v).component_item_id := c12rec.component_item_id;
           g_encoin_rev_comp_tbl(v).last_update_date := c12rec.last_update_date;
           g_encoin_rev_comp_tbl(v).last_updated_by := c12rec.last_updated_by;
           g_encoin_rev_comp_tbl(v).creation_date := c12rec.creation_date;
           g_encoin_rev_comp_tbl(v).created_by := c12rec.created_by;
           g_encoin_rev_comp_tbl(v).last_update_login := c12rec.last_update_login;
           g_encoin_rev_comp_tbl(v).item_num := c12rec.item_num;
           g_encoin_rev_comp_tbl(v).component_quantity := c12rec.component_quantity;
           g_encoin_rev_comp_tbl(v).component_yield_factor := c12rec.component_yield_factor;
           g_encoin_rev_comp_tbl(v).component_remarks := c12rec.component_remarks;
           g_encoin_rev_comp_tbl(v).effectivity_date := c12rec.effectivity_date;
           g_encoin_rev_comp_tbl(v).revised_item_number := c12rec.revised_item_number;
           g_encoin_rev_comp_tbl(v).change_notice := c12rec.change_notice;
           g_encoin_rev_comp_tbl(v).implementation_date := c12rec.implementation_date;
           g_encoin_rev_comp_tbl(v).disable_date := c12rec.disable_date;
           g_encoin_rev_comp_tbl(v).attribute_category := c12rec.attribute_category;
           g_encoin_rev_comp_tbl(v).attribute1 := c12rec.attribute1;
           g_encoin_rev_comp_tbl(v).attribute2 := c12rec.attribute2;
           g_encoin_rev_comp_tbl(v).attribute3 := c12rec.attribute3;
           g_encoin_rev_comp_tbl(v).attribute4 := c12rec.attribute4;
           g_encoin_rev_comp_tbl(v).attribute5 := c12rec.attribute5;
           g_encoin_rev_comp_tbl(v).attribute6 := c12rec.attribute6;
           g_encoin_rev_comp_tbl(v).attribute7 := c12rec.attribute7;
           g_encoin_rev_comp_tbl(v).attribute8 := c12rec.attribute8;
           g_encoin_rev_comp_tbl(v).attribute9 := c12rec.attribute9;
           g_encoin_rev_comp_tbl(v).attribute10 := c12rec.attribute10;
           g_encoin_rev_comp_tbl(v).attribute11 := c12rec.attribute11;
           g_encoin_rev_comp_tbl(v).attribute12 := c12rec.attribute12;
           g_encoin_rev_comp_tbl(v).attribute13 := c12rec.attribute13;
           g_encoin_rev_comp_tbl(v).attribute14 := c12rec.attribute14;
           g_encoin_rev_comp_tbl(v).attribute15 := c12rec.attribute15;
           g_encoin_rev_comp_tbl(v).planning_factor := c12rec.planning_factor;
           g_encoin_rev_comp_tbl(v).quantity_related := c12rec.quantity_related;
           g_encoin_rev_comp_tbl(v).so_basis := c12rec.so_basis;
           g_encoin_rev_comp_tbl(v).optional := c12rec.optional;
           g_encoin_rev_comp_tbl(v).MUTUALLY_EXCLUSIVE_OPT := c12rec.MUTUALLY_EXCLUSIVE_OPTIONS;
           g_encoin_rev_comp_tbl(v).include_in_cost_rollup := c12rec.include_in_cost_rollup;
           g_encoin_rev_comp_tbl(v).check_atp := c12rec.check_atp;
           g_encoin_rev_comp_tbl(v).shipping_allowed := c12rec.shipping_allowed;
           g_encoin_rev_comp_tbl(v).required_to_ship := c12rec.required_to_ship;
           g_encoin_rev_comp_tbl(v).include_on_ship_docs := c12rec.include_on_ship_docs;
           g_encoin_rev_comp_tbl(v).include_on_bill_docs := c12rec.include_on_bill_docs;
           g_encoin_rev_comp_tbl(v).low_quantity := c12rec.low_quantity;
           g_encoin_rev_comp_tbl(v).acd_type := c12rec.acd_type;
           g_encoin_rev_comp_tbl(v).old_component_sequence_id := c12rec.old_component_sequence_id;
           g_encoin_rev_comp_tbl(v).bill_sequence_id := c12rec.bill_sequence_id;
           g_encoin_rev_comp_tbl(v).request_id := c12rec.request_id;
           g_encoin_rev_comp_tbl(v).program_id := c12rec.program_id;
           g_encoin_rev_comp_tbl(v).program_update_date := c12rec.program_update_date;
           g_encoin_rev_comp_tbl(v).pick_components := c12rec.pick_components;
           g_encoin_rev_comp_tbl(v).assembly_type := c12rec.assembly_type;
           g_encoin_rev_comp_tbl(v).interface_entity_type := c12rec.interface_entity_type;
           g_encoin_rev_comp_tbl(v).reference_designator := c12rec.reference_designator;
           g_encoin_rev_comp_tbl(v).new_effectivity_date := c12rec.new_effectivity_date;
           g_encoin_rev_comp_tbl(v).old_effectivity_date := c12rec.old_effectivity_date;
           g_encoin_rev_comp_tbl(v).substitute_comp_id := c12rec.substitute_comp_id;
           g_encoin_rev_comp_tbl(v).new_operation_seq_num := c12rec.new_operation_seq_num;
           g_encoin_rev_comp_tbl(v).old_operation_seq_num := c12rec.old_operation_seq_num;
           g_encoin_rev_comp_tbl(v).process_flag := c12rec.process_flag;
           g_encoin_rev_comp_tbl(v).transaction_id := c12rec.transaction_id;
           g_encoin_rev_comp_tbl(v).SUBSTITUTE_COMP_NUMBER := c12rec.SUBSTITUTE_COMP_NUMBER;
           g_encoin_rev_comp_tbl(v).ORGANIZATION_CODE := c12rec.ORGANIZATION_CODE;
           g_encoin_rev_comp_tbl(v).ASSEMBLY_ITEM_NUMBER := c12rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_rev_comp_tbl(v).COMPONENT_ITEM_NUMBER := c12rec.COMPONENT_ITEM_NUMBER;
           g_encoin_rev_comp_tbl(v).LOCATION_NAME := c12rec.LOCATION_NAME;
           g_encoin_rev_comp_tbl(v).ORGANIZATION_ID := c12rec.ORGANIZATION_ID;
           g_encoin_rev_comp_tbl(v).ASSEMBLY_ITEM_ID := c12rec.ASSEMBLY_ITEM_ID;
           g_encoin_rev_comp_tbl(v).ALTERNATE_BOM_DESIGNATOR := c12rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_rev_comp_tbl(v).operation := c12rec.transaction_type;
           g_encoin_rev_comp_tbl(v).eng_changes_ifce_key := c12rec.ENG_CHANGES_IFCE_KEY;
           g_encoin_rev_comp_tbl(v).eng_revised_items_ifce_key := c12rec.ENG_REVISED_ITEMS_IFCE_KEY;
           g_encoin_rev_comp_tbl(v).bom_inventory_comps_ifce_key := c12rec.BOM_INVENTORY_COMPS_IFCE_KEY;
           g_encoin_rev_comp_tbl(v).basis_type := c12rec.basis_type;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_rev_comp_tbl(v).New_revised_Item_Revision := c12rec.New_revised_Item_Revision;
           g_encoin_rev_comp_tbl(v).from_end_item_unit_number := c12rec.from_end_item_unit_number;  /*Bug 6377841*/
           g_encoin_rev_comp_tbl(v).to_end_item_unit_number := c12rec.to_end_item_unit_number;      /*Bug 6377841*/
/*           g_encoin_rev_comp_tbl(v).old_from_end_item_unit_number := c12rec.old_from_end_item_unit_number;  BUG 9374069 revert 8414408*/
         END LOOP; -- End Rev comps loop
END Get_Comps_With_Curr_ECO_Ifce;

-- Procedure Get_Comps_With_Curr_Item_Ifce
-- Pick up all revised components with item ifce key = g_revised_item_key

PROCEDURE Get_Comps_With_Curr_Item_Ifce
IS
    v                           number;
    stmt_num                    number;
BEGIN
         v := 0;
         FOR c12rec IN GetCompWithCurrItemifce LOOP
           v := v + 1;
           g_encoin_rev_comp_tbl(v).supply_subinventory := c12rec.supply_subinventory;
           g_encoin_rev_comp_tbl(v).OP_LEAD_TIME_PERCENT := c12rec.OPERATION_LEAD_TIME_PERCENT;
           g_encoin_rev_comp_tbl(v).revised_item_sequence_id := c12rec.revised_item_sequence_id;
           g_encoin_rev_comp_tbl(v).cost_factor := c12rec.cost_factor;
           g_encoin_rev_comp_tbl(v).required_for_revenue := c12rec.required_for_revenue;
           g_encoin_rev_comp_tbl(v).high_quantity := c12rec.high_quantity;
           g_encoin_rev_comp_tbl(v).component_sequence_id := c12rec.component_sequence_id;
           g_encoin_rev_comp_tbl(v).program_application_id := c12rec.program_application_id;
           g_encoin_rev_comp_tbl(v).wip_supply_type := c12rec.wip_supply_type;
           g_encoin_rev_comp_tbl(v).supply_locator_id := c12rec.supply_locator_id;
           g_encoin_rev_comp_tbl(v).bom_item_type := c12rec.bom_item_type;
           g_encoin_rev_comp_tbl(v).operation_seq_num := c12rec.operation_seq_num;
           g_encoin_rev_comp_tbl(v).component_item_id := c12rec.component_item_id;
           g_encoin_rev_comp_tbl(v).last_update_date := c12rec.last_update_date;
           g_encoin_rev_comp_tbl(v).last_updated_by := c12rec.last_updated_by;
           g_encoin_rev_comp_tbl(v).creation_date := c12rec.creation_date;
           g_encoin_rev_comp_tbl(v).created_by := c12rec.created_by;
           g_encoin_rev_comp_tbl(v).last_update_login := c12rec.last_update_login;
           g_encoin_rev_comp_tbl(v).item_num := c12rec.item_num;
           g_encoin_rev_comp_tbl(v).component_quantity := c12rec.component_quantity;
           g_encoin_rev_comp_tbl(v).component_yield_factor := c12rec.component_yield_factor;
           g_encoin_rev_comp_tbl(v).component_remarks := c12rec.component_remarks;
           g_encoin_rev_comp_tbl(v).effectivity_date := c12rec.effectivity_date;
           g_encoin_rev_comp_tbl(v).change_notice := c12rec.change_notice;
           g_encoin_rev_comp_tbl(v).implementation_date := c12rec.implementation_date;
           g_encoin_rev_comp_tbl(v).disable_date := c12rec.disable_date;
           g_encoin_rev_comp_tbl(v).attribute_category := c12rec.attribute_category;
           g_encoin_rev_comp_tbl(v).attribute1 := c12rec.attribute1;
           g_encoin_rev_comp_tbl(v).attribute2 := c12rec.attribute2;
           g_encoin_rev_comp_tbl(v).attribute3 := c12rec.attribute3;
           g_encoin_rev_comp_tbl(v).attribute4 := c12rec.attribute4;
           g_encoin_rev_comp_tbl(v).attribute5 := c12rec.attribute5;
           g_encoin_rev_comp_tbl(v).attribute6 := c12rec.attribute6;
           g_encoin_rev_comp_tbl(v).attribute7 := c12rec.attribute7;
           g_encoin_rev_comp_tbl(v).attribute8 := c12rec.attribute8;
           g_encoin_rev_comp_tbl(v).attribute9 := c12rec.attribute9;
           g_encoin_rev_comp_tbl(v).attribute10 := c12rec.attribute10;
           g_encoin_rev_comp_tbl(v).attribute11 := c12rec.attribute11;
           g_encoin_rev_comp_tbl(v).attribute12 := c12rec.attribute12;
           g_encoin_rev_comp_tbl(v).attribute13 := c12rec.attribute13;
           g_encoin_rev_comp_tbl(v).attribute14 := c12rec.attribute14;
           g_encoin_rev_comp_tbl(v).attribute15 := c12rec.attribute15;
           g_encoin_rev_comp_tbl(v).planning_factor := c12rec.planning_factor;
           g_encoin_rev_comp_tbl(v).quantity_related := c12rec.quantity_related;
           g_encoin_rev_comp_tbl(v).so_basis := c12rec.so_basis;
           g_encoin_rev_comp_tbl(v).optional := c12rec.optional;
           g_encoin_rev_comp_tbl(v).MUTUALLY_EXCLUSIVE_OPT := c12rec.MUTUALLY_EXCLUSIVE_OPTIONS;
           g_encoin_rev_comp_tbl(v).include_in_cost_rollup := c12rec.include_in_cost_rollup;
           g_encoin_rev_comp_tbl(v).check_atp := c12rec.check_atp;
           g_encoin_rev_comp_tbl(v).shipping_allowed := c12rec.shipping_allowed;
           g_encoin_rev_comp_tbl(v).required_to_ship := c12rec.required_to_ship;
           g_encoin_rev_comp_tbl(v).include_on_ship_docs := c12rec.include_on_ship_docs;
           g_encoin_rev_comp_tbl(v).include_on_bill_docs := c12rec.include_on_bill_docs;
           g_encoin_rev_comp_tbl(v).low_quantity := c12rec.low_quantity;
           g_encoin_rev_comp_tbl(v).acd_type := c12rec.acd_type;
           g_encoin_rev_comp_tbl(v).old_component_sequence_id := c12rec.old_component_sequence_id;
           g_encoin_rev_comp_tbl(v).bill_sequence_id := c12rec.bill_sequence_id;
           g_encoin_rev_comp_tbl(v).request_id := c12rec.request_id;
           g_encoin_rev_comp_tbl(v).program_id := c12rec.program_id;
           g_encoin_rev_comp_tbl(v).program_update_date := c12rec.program_update_date;
           g_encoin_rev_comp_tbl(v).pick_components := c12rec.pick_components;
           g_encoin_rev_comp_tbl(v).assembly_type := c12rec.assembly_type;
           g_encoin_rev_comp_tbl(v).interface_entity_type := c12rec.interface_entity_type;
           g_encoin_rev_comp_tbl(v).reference_designator := c12rec.reference_designator;
           g_encoin_rev_comp_tbl(v).new_effectivity_date := c12rec.new_effectivity_date;
           g_encoin_rev_comp_tbl(v).old_effectivity_date := c12rec.old_effectivity_date;
           g_encoin_rev_comp_tbl(v).substitute_comp_id := c12rec.substitute_comp_id;
           g_encoin_rev_comp_tbl(v).new_operation_seq_num := c12rec.new_operation_seq_num;
           g_encoin_rev_comp_tbl(v).old_operation_seq_num := c12rec.old_operation_seq_num;
           g_encoin_rev_comp_tbl(v).process_flag := c12rec.process_flag;
           g_encoin_rev_comp_tbl(v).transaction_id := c12rec.transaction_id;
           g_encoin_rev_comp_tbl(v).SUBSTITUTE_COMP_NUMBER := c12rec.SUBSTITUTE_COMP_NUMBER;
           g_encoin_rev_comp_tbl(v).ORGANIZATION_CODE := c12rec.ORGANIZATION_CODE;
           g_encoin_rev_comp_tbl(v).ASSEMBLY_ITEM_NUMBER := c12rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_rev_comp_tbl(v).COMPONENT_ITEM_NUMBER := c12rec.COMPONENT_ITEM_NUMBER;
           g_encoin_rev_comp_tbl(v).LOCATION_NAME := c12rec.LOCATION_NAME;
           g_encoin_rev_comp_tbl(v).ORGANIZATION_ID := c12rec.ORGANIZATION_ID;
           g_encoin_rev_comp_tbl(v).ASSEMBLY_ITEM_ID := c12rec.ASSEMBLY_ITEM_ID;
           g_encoin_rev_comp_tbl(v).ALTERNATE_BOM_DESIGNATOR := c12rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_rev_comp_tbl(v).operation := c12rec.transaction_type;
           g_encoin_rev_comp_tbl(v).eng_revised_items_ifce_key := c12rec.ENG_REVISED_ITEMS_IFCE_KEY;
           g_encoin_rev_comp_tbl(v).bom_inventory_comps_ifce_key := c12rec.BOM_INVENTORY_COMPS_IFCE_KEY;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_rev_comp_tbl(v).New_revised_Item_Revision := c12rec.New_revised_Item_Revision;
	   g_encoin_rev_comp_tbl(v).from_end_item_unit_number := c12rec.from_end_item_unit_number; /*Bug 6377841*/
           g_encoin_rev_comp_tbl(v).to_end_item_unit_number := c12rec.to_end_item_unit_number;     /*Bug 6377841*/
/*            g_encoin_rev_comp_tbl(v).old_from_end_item_unit_number := c12rec.old_from_end_item_unit_number;  BUG 9374069 revert 8414408*/
         END LOOP; -- End Rev comps loop
END Get_Comps_With_Curr_Item_Ifce;

-- Procedure Get_Rfds_With_Curr_ECO_Ifce
-- Pick up all reference designators with ECO ifce key = g_ECO_ifce_key

PROCEDURE Get_Rfds_With_Curr_ECO_Ifce
IS
    y                           number;
    stmt_num                    number;
BEGIN
         y := 0;
         FOR c15rec IN GetRfdWithCurrECOifce LOOP
           y := y + 1;
           g_encoin_ref_des_tbl(y).REF_DESIGNATOR := c15rec.COMPONENT_REFERENCE_DESIGNATOR;
           g_encoin_ref_des_tbl(y).last_update_date := c15rec.last_update_date;
           g_encoin_ref_des_tbl(y).last_updated_by := c15rec.last_updated_by;
           g_encoin_ref_des_tbl(y).creation_date := c15rec.creation_date;
           g_encoin_ref_des_tbl(y).created_by := c15rec.created_by;
           g_encoin_ref_des_tbl(y).last_update_login := c15rec.last_update_login;
           g_encoin_ref_des_tbl(y).ref_designator_comment := c15rec.ref_designator_comment;
           g_encoin_ref_des_tbl(y).change_notice := c15rec.change_notice;
           g_encoin_ref_des_tbl(y).component_sequence_id := c15rec.component_sequence_id;
           g_encoin_ref_des_tbl(y).acd_type := c15rec.acd_type;
           g_encoin_ref_des_tbl(y).request_id := c15rec.request_id;
           g_encoin_ref_des_tbl(y).program_application_id := c15rec.program_application_id;
           g_encoin_ref_des_tbl(y).program_id := c15rec.program_id;
           g_encoin_ref_des_tbl(y).program_update_date := c15rec.program_update_date;
           g_encoin_ref_des_tbl(y).attribute_category := c15rec.attribute_category;
           g_encoin_ref_des_tbl(y).attribute1 := c15rec.attribute1;
           g_encoin_ref_des_tbl(y).attribute2 := c15rec.attribute2;
           g_encoin_ref_des_tbl(y).attribute3 := c15rec.attribute3;
           g_encoin_ref_des_tbl(y).attribute4 := c15rec.attribute4;
           g_encoin_ref_des_tbl(y).attribute5 := c15rec.attribute5;
           g_encoin_ref_des_tbl(y).attribute6 := c15rec.attribute6;
           g_encoin_ref_des_tbl(y).attribute7 := c15rec.attribute7;
           g_encoin_ref_des_tbl(y).attribute8 := c15rec.attribute8;
           g_encoin_ref_des_tbl(y).attribute9 := c15rec.attribute9;
           g_encoin_ref_des_tbl(y).attribute10 := c15rec.attribute10;
           g_encoin_ref_des_tbl(y).attribute11 := c15rec.attribute11;
           g_encoin_ref_des_tbl(y).attribute12 := c15rec.attribute12;
           g_encoin_ref_des_tbl(y).attribute13 := c15rec.attribute13;
           g_encoin_ref_des_tbl(y).attribute14 := c15rec.attribute14;
           g_encoin_ref_des_tbl(y).attribute15 := c15rec.attribute15;
           g_encoin_ref_des_tbl(y).new_designator := c15rec.new_designator;
           g_encoin_ref_des_tbl(y).process_flag := c15rec.process_flag;
           g_encoin_ref_des_tbl(y).transaction_id := c15rec.transaction_id;
           g_encoin_ref_des_tbl(y).ASSEMBLY_ITEM_NUMBER := c15rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_ref_des_tbl(y).COMPONENT_ITEM_NUMBER := c15rec.COMPONENT_ITEM_NUMBER;
           g_encoin_ref_des_tbl(y).ORGANIZATION_CODE := c15rec.ORGANIZATION_CODE;
           g_encoin_ref_des_tbl(y).ORGANIZATION_ID := c15rec.ORGANIZATION_ID;
           g_encoin_ref_des_tbl(y).ASSEMBLY_ITEM_ID := c15rec.ASSEMBLY_ITEM_ID;
           g_encoin_ref_des_tbl(y).ALTERNATE_BOM_DESIGNATOR := c15rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_ref_des_tbl(y).COMPONENT_ITEM_ID := c15rec.COMPONENT_ITEM_ID;
           g_encoin_ref_des_tbl(y).BILL_SEQUENCE_ID := c15rec.BILL_SEQUENCE_ID;
           g_encoin_ref_des_tbl(y).OPERATION_SEQ_NUM := c15rec.OPERATION_SEQ_NUM;
           g_encoin_ref_des_tbl(y).EFFECTIVITY_DATE := c15rec.EFFECTIVITY_DATE;
           g_encoin_ref_des_tbl(y).interface_entity_type := c15rec.interface_entity_type;
           g_encoin_ref_des_tbl(y).operation := c15rec.transaction_type;
           g_encoin_ref_des_tbl(y).eng_changes_ifce_key := c15rec.eng_changes_ifce_key;
           g_encoin_ref_des_tbl(y).eng_revised_items_ifce_key := c15rec.eng_revised_items_ifce_key;
           g_encoin_ref_des_tbl(y).bom_inventory_comps_ifce_key := c15rec.bom_inventory_comps_ifce_key;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_ref_des_tbl(y).New_revised_Item_Revision := c15rec.New_revised_Item_Revision;

         END LOOP; -- END Ref Desgs loop
END Get_Rfds_With_Curr_ECO_Ifce;

-- Procedure Get_Rfds_With_Curr_Item_Ifce
-- Pick up all reference designators with item ifce key = g_revised_item_key

PROCEDURE Get_Rfds_With_Curr_Item_Ifce
IS
    y                           number;
    stmt_num                    number;
BEGIN
         y := 0;
         FOR c15rec IN GetRfdWithCurrItemifce LOOP
           y := y + 1;
           g_encoin_ref_des_tbl(y).REF_DESIGNATOR := c15rec.COMPONENT_REFERENCE_DESIGNATOR;
           g_encoin_ref_des_tbl(y).last_update_date := c15rec.last_update_date;
           g_encoin_ref_des_tbl(y).last_updated_by := c15rec.last_updated_by;
           g_encoin_ref_des_tbl(y).creation_date := c15rec.creation_date;
           g_encoin_ref_des_tbl(y).created_by := c15rec.created_by;
           g_encoin_ref_des_tbl(y).last_update_login := c15rec.last_update_login;
           g_encoin_ref_des_tbl(y).ref_designator_comment := c15rec.ref_designator_comment;
           g_encoin_ref_des_tbl(y).change_notice := c15rec.change_notice;
           g_encoin_ref_des_tbl(y).component_sequence_id := c15rec.component_sequence_id;
           g_encoin_ref_des_tbl(y).acd_type := c15rec.acd_type;
           g_encoin_ref_des_tbl(y).request_id := c15rec.request_id;
           g_encoin_ref_des_tbl(y).program_application_id := c15rec.program_application_id;
           g_encoin_ref_des_tbl(y).program_id := c15rec.program_id;
           g_encoin_ref_des_tbl(y).program_update_date := c15rec.program_update_date;
           g_encoin_ref_des_tbl(y).attribute_category := c15rec.attribute_category;
           g_encoin_ref_des_tbl(y).attribute1 := c15rec.attribute1;
           g_encoin_ref_des_tbl(y).attribute2 := c15rec.attribute2;
           g_encoin_ref_des_tbl(y).attribute3 := c15rec.attribute3;
           g_encoin_ref_des_tbl(y).attribute4 := c15rec.attribute4;
           g_encoin_ref_des_tbl(y).attribute5 := c15rec.attribute5;
           g_encoin_ref_des_tbl(y).attribute6 := c15rec.attribute6;
           g_encoin_ref_des_tbl(y).attribute7 := c15rec.attribute7;
           g_encoin_ref_des_tbl(y).attribute8 := c15rec.attribute8;
           g_encoin_ref_des_tbl(y).attribute9 := c15rec.attribute9;
           g_encoin_ref_des_tbl(y).attribute10 := c15rec.attribute10;
           g_encoin_ref_des_tbl(y).attribute11 := c15rec.attribute11;
           g_encoin_ref_des_tbl(y).attribute12 := c15rec.attribute12;
           g_encoin_ref_des_tbl(y).attribute13 := c15rec.attribute13;
           g_encoin_ref_des_tbl(y).attribute14 := c15rec.attribute14;
           g_encoin_ref_des_tbl(y).attribute15 := c15rec.attribute15;
           g_encoin_ref_des_tbl(y).new_designator := c15rec.new_designator;
           g_encoin_ref_des_tbl(y).process_flag := c15rec.process_flag;
           g_encoin_ref_des_tbl(y).transaction_id := c15rec.transaction_id;
           g_encoin_ref_des_tbl(y).ASSEMBLY_ITEM_NUMBER := c15rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_ref_des_tbl(y).COMPONENT_ITEM_NUMBER := c15rec.COMPONENT_ITEM_NUMBER;
           g_encoin_ref_des_tbl(y).ORGANIZATION_CODE := c15rec.ORGANIZATION_CODE;
           g_encoin_ref_des_tbl(y).ORGANIZATION_ID := c15rec.ORGANIZATION_ID;
           g_encoin_ref_des_tbl(y).ASSEMBLY_ITEM_ID := c15rec.ASSEMBLY_ITEM_ID;
           g_encoin_ref_des_tbl(y).ALTERNATE_BOM_DESIGNATOR := c15rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_ref_des_tbl(y).COMPONENT_ITEM_ID := c15rec.COMPONENT_ITEM_ID;
           g_encoin_ref_des_tbl(y).BILL_SEQUENCE_ID := c15rec.BILL_SEQUENCE_ID;
           g_encoin_ref_des_tbl(y).OPERATION_SEQ_NUM := c15rec.OPERATION_SEQ_NUM;
           g_encoin_ref_des_tbl(y).EFFECTIVITY_DATE := c15rec.EFFECTIVITY_DATE;
           g_encoin_ref_des_tbl(y).interface_entity_type := c15rec.interface_entity_type;
           g_encoin_ref_des_tbl(y).operation := c15rec.transaction_type;
           g_encoin_ref_des_tbl(y).eng_changes_ifce_key := c15rec.eng_changes_ifce_key;
           g_encoin_ref_des_tbl(y).eng_revised_items_ifce_key := c15rec.eng_revised_items_ifce_key;
           g_encoin_ref_des_tbl(y).bom_inventory_comps_ifce_key := c15rec.bom_inventory_comps_ifce_key;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_ref_des_tbl(y).New_revised_Item_Revision := c15rec.New_revised_Item_Revision;

         END LOOP; -- END Ref Desgs loop
END Get_Rfds_With_Curr_Item_Ifce;

-- Procedure Get_Rfds_With_Curr_Comp_Ifce
-- Pick up all reference designators with comp ifce key = g_revised_comp_ifce_key

PROCEDURE Get_Rfds_With_Curr_Comp_Ifce
IS
    y                           number;
    stmt_num                    number;
BEGIN
         y := 0;
         FOR c15rec IN GetRfdWithCurrCompifce LOOP
           y := y + 1;
           g_encoin_ref_des_tbl(y).REF_DESIGNATOR := c15rec.COMPONENT_REFERENCE_DESIGNATOR;
           g_encoin_ref_des_tbl(y).last_update_date := c15rec.last_update_date;
           g_encoin_ref_des_tbl(y).last_updated_by := c15rec.last_updated_by;
           g_encoin_ref_des_tbl(y).creation_date := c15rec.creation_date;
           g_encoin_ref_des_tbl(y).created_by := c15rec.created_by;
           g_encoin_ref_des_tbl(y).last_update_login := c15rec.last_update_login;
           g_encoin_ref_des_tbl(y).ref_designator_comment := c15rec.ref_designator_comment;
           g_encoin_ref_des_tbl(y).change_notice := c15rec.change_notice;
           g_encoin_ref_des_tbl(y).component_sequence_id := c15rec.component_sequence_id;
           g_encoin_ref_des_tbl(y).acd_type := c15rec.acd_type;
           g_encoin_ref_des_tbl(y).request_id := c15rec.request_id;
           g_encoin_ref_des_tbl(y).program_application_id := c15rec.program_application_id;
           g_encoin_ref_des_tbl(y).program_id := c15rec.program_id;
           g_encoin_ref_des_tbl(y).program_update_date := c15rec.program_update_date;
           g_encoin_ref_des_tbl(y).attribute_category := c15rec.attribute_category;
           g_encoin_ref_des_tbl(y).attribute1 := c15rec.attribute1;
           g_encoin_ref_des_tbl(y).attribute2 := c15rec.attribute2;
           g_encoin_ref_des_tbl(y).attribute3 := c15rec.attribute3;
           g_encoin_ref_des_tbl(y).attribute4 := c15rec.attribute4;
           g_encoin_ref_des_tbl(y).attribute5 := c15rec.attribute5;
           g_encoin_ref_des_tbl(y).attribute6 := c15rec.attribute6;
           g_encoin_ref_des_tbl(y).attribute7 := c15rec.attribute7;
           g_encoin_ref_des_tbl(y).attribute8 := c15rec.attribute8;
           g_encoin_ref_des_tbl(y).attribute9 := c15rec.attribute9;
           g_encoin_ref_des_tbl(y).attribute10 := c15rec.attribute10;
           g_encoin_ref_des_tbl(y).attribute11 := c15rec.attribute11;
           g_encoin_ref_des_tbl(y).attribute12 := c15rec.attribute12;
           g_encoin_ref_des_tbl(y).attribute13 := c15rec.attribute13;
           g_encoin_ref_des_tbl(y).attribute14 := c15rec.attribute14;
           g_encoin_ref_des_tbl(y).attribute15 := c15rec.attribute15;
           g_encoin_ref_des_tbl(y).new_designator := c15rec.new_designator;
           g_encoin_ref_des_tbl(y).process_flag := c15rec.process_flag;
           g_encoin_ref_des_tbl(y).transaction_id := c15rec.transaction_id;
           g_encoin_ref_des_tbl(y).ASSEMBLY_ITEM_NUMBER := c15rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_ref_des_tbl(y).COMPONENT_ITEM_NUMBER := c15rec.COMPONENT_ITEM_NUMBER;
           g_encoin_ref_des_tbl(y).ORGANIZATION_CODE := c15rec.ORGANIZATION_CODE;
           g_encoin_ref_des_tbl(y).ORGANIZATION_ID := c15rec.ORGANIZATION_ID;
           g_encoin_ref_des_tbl(y).ASSEMBLY_ITEM_ID := c15rec.ASSEMBLY_ITEM_ID;
           g_encoin_ref_des_tbl(y).ALTERNATE_BOM_DESIGNATOR := c15rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_ref_des_tbl(y).COMPONENT_ITEM_ID := c15rec.COMPONENT_ITEM_ID;
           g_encoin_ref_des_tbl(y).BILL_SEQUENCE_ID := c15rec.BILL_SEQUENCE_ID;
           g_encoin_ref_des_tbl(y).OPERATION_SEQ_NUM := c15rec.OPERATION_SEQ_NUM;
           g_encoin_ref_des_tbl(y).EFFECTIVITY_DATE := c15rec.EFFECTIVITY_DATE;
           g_encoin_ref_des_tbl(y).interface_entity_type := c15rec.interface_entity_type;
           g_encoin_ref_des_tbl(y).operation := c15rec.transaction_type;
           g_encoin_ref_des_tbl(y).eng_changes_ifce_key := c15rec.eng_changes_ifce_key;
           g_encoin_ref_des_tbl(y).eng_revised_items_ifce_key := c15rec.eng_revised_items_ifce_key;
           g_encoin_ref_des_tbl(y).bom_inventory_comps_ifce_key := c15rec.bom_inventory_comps_ifce_key;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_ref_des_tbl(y).New_revised_Item_Revision := c15rec.New_revised_Item_Revision;
         END LOOP; -- END Ref Desgs loop
END Get_Rfds_With_Curr_Comp_Ifce;

-- Procedure Get_Sbcs_With_Curr_ECO_Ifce
-- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

PROCEDURE Get_Sbcs_With_Curr_ECO_Ifce
IS
    z                           number;
    stmt_num                    number;
BEGIN
         z := 0;
         FOR c16rec IN GetSbcWithCurrECOifce LOOP
           z := z + 1;
           g_encoin_sub_comp_tbl(z).substitute_component_id := c16rec.substitute_component_id;
           g_encoin_sub_comp_tbl(z).last_update_date := c16rec.last_update_date;
           g_encoin_sub_comp_tbl(z).last_updated_by := c16rec.last_updated_by;
           g_encoin_sub_comp_tbl(z).creation_date := c16rec.creation_date;
           g_encoin_sub_comp_tbl(z).created_by := c16rec.created_by;
           g_encoin_sub_comp_tbl(z).last_update_login := c16rec.last_update_login;
           g_encoin_sub_comp_tbl(z).substitute_item_quantity := c16rec.substitute_item_quantity;
           g_encoin_sub_comp_tbl(z).component_sequence_id := c16rec.component_sequence_id;
           g_encoin_sub_comp_tbl(z).acd_type := c16rec.acd_type;
           g_encoin_sub_comp_tbl(z).change_notice := c16rec.change_notice;
           g_encoin_sub_comp_tbl(z).request_id := c16rec.request_id;
           g_encoin_sub_comp_tbl(z).program_application_id := c16rec.program_application_id;
           g_encoin_sub_comp_tbl(z).program_update_date := c16rec.program_update_date;
           g_encoin_sub_comp_tbl(z).attribute_category := c16rec.attribute_category;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute1;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute2;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute4;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute5;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute6;
           g_encoin_sub_comp_tbl(z).attribute8 := c16rec.attribute8;
           g_encoin_sub_comp_tbl(z).attribute9 := c16rec.attribute9;
           g_encoin_sub_comp_tbl(z).attribute10 := c16rec.attribute10;
           g_encoin_sub_comp_tbl(z).attribute12 := c16rec.attribute12;
           g_encoin_sub_comp_tbl(z).attribute13 := c16rec.attribute13;
           g_encoin_sub_comp_tbl(z).attribute14 := c16rec.attribute14;
           g_encoin_sub_comp_tbl(z).attribute15 := c16rec.attribute15;
           g_encoin_sub_comp_tbl(z).program_id := c16rec.program_id;
           g_encoin_sub_comp_tbl(z).attribute3 := c16rec.attribute3;
           g_encoin_sub_comp_tbl(z).attribute7 := c16rec.attribute7;
           g_encoin_sub_comp_tbl(z).attribute11 := c16rec.attribute11;
           g_encoin_sub_comp_tbl(z).new_sub_comp_id := c16rec.new_sub_comp_id;
           g_encoin_sub_comp_tbl(z).process_flag := c16rec.process_flag;
           g_encoin_sub_comp_tbl(z).transaction_id := c16rec.transaction_id;
           g_encoin_sub_comp_tbl(z).NEW_SUB_COMP_NUMBER := c16rec.NEW_SUB_COMP_NUMBER;
           g_encoin_sub_comp_tbl(z).ASSEMBLY_ITEM_NUMBER := c16rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_sub_comp_tbl(z).COMPONENT_ITEM_NUMBER := c16rec.COMPONENT_ITEM_NUMBER;
           g_encoin_sub_comp_tbl(z).SUBSTITUTE_COMP_NUMBER := c16rec.SUBSTITUTE_COMP_NUMBER;
           g_encoin_sub_comp_tbl(z).ORGANIZATION_CODE := c16rec.ORGANIZATION_CODE;
           g_encoin_sub_comp_tbl(z).ORGANIZATION_ID := c16rec.ORGANIZATION_ID;
           g_encoin_sub_comp_tbl(z).ASSEMBLY_ITEM_ID := c16rec.ASSEMBLY_ITEM_ID;
           g_encoin_sub_comp_tbl(z).ALTERNATE_BOM_DESIGNATOR := c16rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_sub_comp_tbl(z).COMPONENT_ITEM_ID := c16rec.COMPONENT_ITEM_ID;
           g_encoin_sub_comp_tbl(z).BILL_SEQUENCE_ID := c16rec.BILL_SEQUENCE_ID;
           g_encoin_sub_comp_tbl(z).OPERATION_SEQ_NUM := c16rec.OPERATION_SEQ_NUM;
           g_encoin_sub_comp_tbl(z).EFFECTIVITY_DATE := c16rec.EFFECTIVITY_DATE;
           g_encoin_sub_comp_tbl(z).interface_entity_type := c16rec.interface_entity_type;
           g_encoin_sub_comp_tbl(z).operation := c16rec.transaction_type;
           g_encoin_sub_comp_tbl(z).eng_changes_ifce_key := c16rec.eng_changes_ifce_key;
           g_encoin_sub_comp_tbl(z).eng_revised_items_ifce_key := c16rec.eng_revised_items_ifce_key;
           g_encoin_sub_comp_tbl(z).bom_inventory_comps_ifce_key := c16rec.bom_inventory_comps_ifce_key;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_sub_comp_tbl(z).New_revised_Item_Revision := c16rec.New_revised_Item_Revision;
         END LOOP; -- END Sub Comps Loop
END Get_Sbcs_With_Curr_ECO_Ifce;

-- Procedure Get_Sbcs_With_Curr_Item_Ifce
-- Pick up all substitute components with item ifce key = g_revised_item_ifce_key

PROCEDURE Get_Sbcs_With_Curr_Item_Ifce
IS
    z                           number;
    stmt_num                    number;
BEGIN
         z := 0;
         FOR c16rec IN GetSbcWithCurrItemifce LOOP
           z := z + 1;
           g_encoin_sub_comp_tbl(z).substitute_component_id := c16rec.substitute_component_id;
           g_encoin_sub_comp_tbl(z).last_update_date := c16rec.last_update_date;
           g_encoin_sub_comp_tbl(z).last_updated_by := c16rec.last_updated_by;
           g_encoin_sub_comp_tbl(z).creation_date := c16rec.creation_date;
           g_encoin_sub_comp_tbl(z).created_by := c16rec.created_by;
           g_encoin_sub_comp_tbl(z).last_update_login := c16rec.last_update_login;
           g_encoin_sub_comp_tbl(z).substitute_item_quantity := c16rec.substitute_item_quantity;
           g_encoin_sub_comp_tbl(z).component_sequence_id := c16rec.component_sequence_id;
           g_encoin_sub_comp_tbl(z).acd_type := c16rec.acd_type;
           g_encoin_sub_comp_tbl(z).change_notice := c16rec.change_notice;
           g_encoin_sub_comp_tbl(z).request_id := c16rec.request_id;
           g_encoin_sub_comp_tbl(z).program_application_id := c16rec.program_application_id;
           g_encoin_sub_comp_tbl(z).program_update_date := c16rec.program_update_date;
           g_encoin_sub_comp_tbl(z).attribute_category := c16rec.attribute_category;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute1;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute2;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute4;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute5;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute6;
           g_encoin_sub_comp_tbl(z).attribute8 := c16rec.attribute8;
           g_encoin_sub_comp_tbl(z).attribute9 := c16rec.attribute9;
           g_encoin_sub_comp_tbl(z).attribute10 := c16rec.attribute10;
           g_encoin_sub_comp_tbl(z).attribute12 := c16rec.attribute12;
           g_encoin_sub_comp_tbl(z).attribute13 := c16rec.attribute13;
           g_encoin_sub_comp_tbl(z).attribute14 := c16rec.attribute14;
           g_encoin_sub_comp_tbl(z).attribute15 := c16rec.attribute15;
           g_encoin_sub_comp_tbl(z).program_id := c16rec.program_id;
           g_encoin_sub_comp_tbl(z).attribute3 := c16rec.attribute3;
           g_encoin_sub_comp_tbl(z).attribute7 := c16rec.attribute7;
           g_encoin_sub_comp_tbl(z).attribute11 := c16rec.attribute11;
           g_encoin_sub_comp_tbl(z).new_sub_comp_id := c16rec.new_sub_comp_id;
           g_encoin_sub_comp_tbl(z).process_flag := c16rec.process_flag;
           g_encoin_sub_comp_tbl(z).transaction_id := c16rec.transaction_id;
           g_encoin_sub_comp_tbl(z).NEW_SUB_COMP_NUMBER := c16rec.NEW_SUB_COMP_NUMBER;
           g_encoin_sub_comp_tbl(z).ASSEMBLY_ITEM_NUMBER := c16rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_sub_comp_tbl(z).COMPONENT_ITEM_NUMBER := c16rec.COMPONENT_ITEM_NUMBER;
           g_encoin_sub_comp_tbl(z).SUBSTITUTE_COMP_NUMBER := c16rec.SUBSTITUTE_COMP_NUMBER;
           g_encoin_sub_comp_tbl(z).ORGANIZATION_CODE := c16rec.ORGANIZATION_CODE;
           g_encoin_sub_comp_tbl(z).ORGANIZATION_ID := c16rec.ORGANIZATION_ID;
           g_encoin_sub_comp_tbl(z).ASSEMBLY_ITEM_ID := c16rec.ASSEMBLY_ITEM_ID;
           g_encoin_sub_comp_tbl(z).ALTERNATE_BOM_DESIGNATOR := c16rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_sub_comp_tbl(z).COMPONENT_ITEM_ID := c16rec.COMPONENT_ITEM_ID;
           g_encoin_sub_comp_tbl(z).BILL_SEQUENCE_ID := c16rec.BILL_SEQUENCE_ID;
           g_encoin_sub_comp_tbl(z).OPERATION_SEQ_NUM := c16rec.OPERATION_SEQ_NUM;
           g_encoin_sub_comp_tbl(z).EFFECTIVITY_DATE := c16rec.EFFECTIVITY_DATE;
           g_encoin_sub_comp_tbl(z).interface_entity_type := c16rec.interface_entity_type;
           g_encoin_sub_comp_tbl(z).operation := c16rec.transaction_type;
           g_encoin_sub_comp_tbl(z).eng_changes_ifce_key := c16rec.eng_changes_ifce_key;
           g_encoin_sub_comp_tbl(z).eng_revised_items_ifce_key := c16rec.eng_revised_items_ifce_key;
           g_encoin_sub_comp_tbl(z).bom_inventory_comps_ifce_key := c16rec.bom_inventory_comps_ifce_key;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_sub_comp_tbl(z).New_revised_Item_Revision := c16rec.New_revised_Item_Revision;
         END LOOP; -- END Sub Comps Loop
END Get_Sbcs_With_Curr_Item_Ifce;

-- Procedure Get_Sbcs_With_Curr_Comp_Ifce
-- Pick up all substitute components with comp ifce key = g_revised_comp_ifce_key

PROCEDURE Get_Sbcs_With_Curr_Comp_Ifce
IS
    z                           number;
    stmt_num                    number;
BEGIN
         z := 0;
         FOR c16rec IN GetSbcWithCurrCompifce LOOP
           z := z + 1;
           g_encoin_sub_comp_tbl(z).substitute_component_id := c16rec.substitute_component_id;
           g_encoin_sub_comp_tbl(z).last_update_date := c16rec.last_update_date;
           g_encoin_sub_comp_tbl(z).last_updated_by := c16rec.last_updated_by;
           g_encoin_sub_comp_tbl(z).creation_date := c16rec.creation_date;
           g_encoin_sub_comp_tbl(z).created_by := c16rec.created_by;
           g_encoin_sub_comp_tbl(z).last_update_login := c16rec.last_update_login;
           g_encoin_sub_comp_tbl(z).substitute_item_quantity := c16rec.substitute_item_quantity;
           g_encoin_sub_comp_tbl(z).component_sequence_id := c16rec.component_sequence_id;
           g_encoin_sub_comp_tbl(z).acd_type := c16rec.acd_type;
           g_encoin_sub_comp_tbl(z).change_notice := c16rec.change_notice;
           g_encoin_sub_comp_tbl(z).request_id := c16rec.request_id;
           g_encoin_sub_comp_tbl(z).program_application_id := c16rec.program_application_id;
           g_encoin_sub_comp_tbl(z).program_update_date := c16rec.program_update_date;
           g_encoin_sub_comp_tbl(z).attribute_category := c16rec.attribute_category;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute1;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute2;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute4;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute5;
           g_encoin_sub_comp_tbl(z).attribute1 := c16rec.attribute6;
           g_encoin_sub_comp_tbl(z).attribute8 := c16rec.attribute8;
           g_encoin_sub_comp_tbl(z).attribute9 := c16rec.attribute9;
           g_encoin_sub_comp_tbl(z).attribute10 := c16rec.attribute10;
           g_encoin_sub_comp_tbl(z).attribute12 := c16rec.attribute12;
           g_encoin_sub_comp_tbl(z).attribute13 := c16rec.attribute13;
           g_encoin_sub_comp_tbl(z).attribute14 := c16rec.attribute14;
           g_encoin_sub_comp_tbl(z).attribute15 := c16rec.attribute15;
           g_encoin_sub_comp_tbl(z).program_id := c16rec.program_id;
           g_encoin_sub_comp_tbl(z).attribute3 := c16rec.attribute3;
           g_encoin_sub_comp_tbl(z).attribute7 := c16rec.attribute7;
           g_encoin_sub_comp_tbl(z).attribute11 := c16rec.attribute11;
           g_encoin_sub_comp_tbl(z).new_sub_comp_id := c16rec.new_sub_comp_id;
           g_encoin_sub_comp_tbl(z).process_flag := c16rec.process_flag;
           g_encoin_sub_comp_tbl(z).transaction_id := c16rec.transaction_id;
           g_encoin_sub_comp_tbl(z).NEW_SUB_COMP_NUMBER := c16rec.NEW_SUB_COMP_NUMBER;
           g_encoin_sub_comp_tbl(z).ASSEMBLY_ITEM_NUMBER := c16rec.ASSEMBLY_ITEM_NUMBER;
           g_encoin_sub_comp_tbl(z).COMPONENT_ITEM_NUMBER := c16rec.COMPONENT_ITEM_NUMBER;
           g_encoin_sub_comp_tbl(z).SUBSTITUTE_COMP_NUMBER := c16rec.SUBSTITUTE_COMP_NUMBER;
           g_encoin_sub_comp_tbl(z).ORGANIZATION_CODE := c16rec.ORGANIZATION_CODE;
           g_encoin_sub_comp_tbl(z).ORGANIZATION_ID := c16rec.ORGANIZATION_ID;
           g_encoin_sub_comp_tbl(z).ASSEMBLY_ITEM_ID := c16rec.ASSEMBLY_ITEM_ID;
           g_encoin_sub_comp_tbl(z).ALTERNATE_BOM_DESIGNATOR := c16rec.ALTERNATE_BOM_DESIGNATOR;
           g_encoin_sub_comp_tbl(z).COMPONENT_ITEM_ID := c16rec.COMPONENT_ITEM_ID;
           g_encoin_sub_comp_tbl(z).BILL_SEQUENCE_ID := c16rec.BILL_SEQUENCE_ID;
           g_encoin_sub_comp_tbl(z).OPERATION_SEQ_NUM := c16rec.OPERATION_SEQ_NUM;
           g_encoin_sub_comp_tbl(z).EFFECTIVITY_DATE := c16rec.EFFECTIVITY_DATE;
           g_encoin_sub_comp_tbl(z).interface_entity_type := c16rec.interface_entity_type;
           g_encoin_sub_comp_tbl(z).operation := c16rec.transaction_type;
           g_encoin_sub_comp_tbl(z).eng_changes_ifce_key := c16rec.eng_changes_ifce_key;
           g_encoin_sub_comp_tbl(z).eng_revised_items_ifce_key := c16rec.eng_revised_items_ifce_key;
           g_encoin_sub_comp_tbl(z).bom_inventory_comps_ifce_key := c16rec.bom_inventory_comps_ifce_key;
           --Bug 3396529: Added New_revised_Item_Revision
           g_encoin_sub_comp_tbl(z).New_revised_Item_Revision := c16rec.New_revised_Item_Revision;
         END LOOP; -- END Sub Comps Loop
END Get_Sbcs_With_Curr_Comp_Ifce;


PROCEDURE Get_Lines_With_Curr_ECO_Ifce
IS
    cursor GetLines IS
        SELECT eco_name, organization_code, change_type_code,
          change_mgmt_type_name, name, description, sequence_number,
          status_name, object_display_name, pk1_name, pk2_name, pk3_name,
          pk4_name, pk5_name, assignee_name, need_by_date, scheduled_date,
          implementation_date, cancelation_date, original_system_reference,
          return_status, transaction_type
        FROM eng_change_lines_interface
        WHERE eng_changes_ifce_key = g_ECO_ifce_key
          AND process_flag = 1
              AND (g_all_org = 1
                   OR
                   (g_all_org = 2 AND organization_id = g_org_id));

    i    NUMBER;
BEGIN
    i := 0;
    FOR c17rec IN GetLines LOOP
        i := i + 1;
        g_public_lines_tbl(i).eco_name := c17rec.eco_name;
        g_public_lines_tbl(i).organization_code := c17rec.organization_code;
        g_public_lines_tbl(i).change_type_code := c17rec.change_type_code;
        g_public_lines_tbl(i).change_management_type := c17rec.change_mgmt_type_name;
        g_public_lines_tbl(i).name := c17rec.name;
        g_public_lines_tbl(i).description := c17rec.description;
        g_public_lines_tbl(i).sequence_number := c17rec.sequence_number;
        --g_public_lines_tbl(i).item_name := c17rec.item_name;
        --g_public_lines_tbl(i).item_revision := c17rec.item_revision;
        g_public_lines_tbl(i).object_display_name := c17rec.object_display_name;
        g_public_lines_tbl(i).pk1_name := c17rec.pk1_name;
        g_public_lines_tbl(i).pk2_name := c17rec.pk2_name;
        g_public_lines_tbl(i).pk3_name := c17rec.pk3_name;
        g_public_lines_tbl(i).pk4_name := c17rec.pk4_name;
        g_public_lines_tbl(i).pk5_name := c17rec.pk5_name;
        g_public_lines_tbl(i).assignee_name := c17rec.assignee_name;
        g_public_lines_tbl(i).need_by_date := c17rec.need_by_date;
        g_public_lines_tbl(i).scheduled_date := c17rec.scheduled_date;
        g_public_lines_tbl(i).implementation_date := c17rec.implementation_date;
        g_public_lines_tbl(i).cancelation_date := c17rec.cancelation_date;
        g_public_lines_tbl(i).original_system_reference := c17rec.original_system_reference;
        g_public_lines_tbl(i).return_status := c17rec.return_status;
        g_public_lines_tbl(i).transaction_type := c17rec.transaction_type;
        --Bug 2908248
        g_public_lines_tbl(i).status_name := c17rec.status_name;
    END LOOP;
END Get_Lines_With_Curr_ECO_Ifce;


PROCEDURE Get_Rev_Op_With_Curr_ECO_Ifce
IS
    cursor GetOperations IS
        SELECT change_notice, organization_code, assembly_item_number,
          new_routing_revision, acd_type, alternate_routing_designator,
          operation_seq_num, operation_type, effectivity_date,
          new_operation_seq_num, old_start_effective_date, operation_code,
          department_code, operation_lead_time_percent,
          minimum_transfer_quantity, count_point_type, operation_description,
          disable_date, backflush_flag, option_dependent_flag, reference_flag,
          yield, cumulative_yield, cancel_comments, attribute_category,
          attribute1, attribute2, attribute3, attribute4, attribute5,
          attribute6, attribute7, attribute8, attribute9, attribute10,
          attribute11, attribute12, attribute13, attribute14, attribute15,
          original_system_reference, transaction_type
          -- Bug 3412268: Added New_Revised_Item_Revision
          , New_Revised_Item_Revision
        FROM bom_op_sequences_interface
        WHERE eng_changes_ifce_key = g_ECO_ifce_key;
    i    NUMBER;
BEGIN
    i := 0;
    FOR c18rec IN GetOperations LOOP
        i := i + 1;
        g_public_rev_operation_tbl(i).Eco_Name := c18rec.change_notice;
        g_public_rev_operation_tbl(i).Organization_Code := c18rec.organization_code;
        g_public_rev_operation_tbl(i).Revised_Item_Name := c18rec.assembly_item_number;
        g_public_rev_operation_tbl(i).New_Routing_Revision := c18rec.new_routing_revision;
        g_public_rev_operation_tbl(i).ACD_Type := c18rec.acd_type;
        g_public_rev_operation_tbl(i).Alternate_Routing_Code := c18rec.alternate_routing_designator;
        g_public_rev_operation_tbl(i).Operation_Sequence_Number := c18rec.operation_seq_num;
        g_public_rev_operation_tbl(i).Operation_Type := c18rec.operation_type;
        g_public_rev_operation_tbl(i).Start_Effective_Date := c18rec.effectivity_date;
        g_public_rev_operation_tbl(i).New_Operation_Sequence_Number := c18rec.new_operation_seq_num;
        g_public_rev_operation_tbl(i).Old_Start_Effective_Date := c18rec.old_start_effective_date;
        g_public_rev_operation_tbl(i).Standard_Operation_Code := c18rec.operation_code;
        g_public_rev_operation_tbl(i).Department_Code := c18rec.department_code;
        g_public_rev_operation_tbl(i).Op_Lead_Time_Percent := c18rec.operation_lead_time_percent;
        g_public_rev_operation_tbl(i).Minimum_Transfer_Quantity := c18rec.minimum_transfer_quantity;
        g_public_rev_operation_tbl(i).Count_Point_Type := c18rec.count_point_type;
        g_public_rev_operation_tbl(i).Operation_Description := c18rec.operation_description;
        g_public_rev_operation_tbl(i).Disable_Date := c18rec.disable_date;
        g_public_rev_operation_tbl(i).Backflush_Flag := c18rec.backflush_flag;
        g_public_rev_operation_tbl(i).Option_Dependent_Flag := c18rec.option_dependent_flag;
        g_public_rev_operation_tbl(i).Reference_Flag := c18rec.reference_flag;
        g_public_rev_operation_tbl(i).Yield := c18rec.yield;
        g_public_rev_operation_tbl(i).Cumulative_Yield := c18rec.cumulative_yield;
        g_public_rev_operation_tbl(i).Yield := c18rec.yield;
        g_public_rev_operation_tbl(i).Cancel_Comments := c18rec.cancel_comments;
        g_public_rev_operation_tbl(i).Attribute_Category := c18rec.attribute_category;
        g_public_rev_operation_tbl(i).Attribute1 := c18rec.attribute1;
        g_public_rev_operation_tbl(i).Attribute2 := c18rec.attribute2;
        g_public_rev_operation_tbl(i).Attribute3 := c18rec.attribute3;
        g_public_rev_operation_tbl(i).Attribute4 := c18rec.attribute4;
        g_public_rev_operation_tbl(i).Attribute5 := c18rec.attribute5;
        g_public_rev_operation_tbl(i).Attribute6 := c18rec.attribute6;
        g_public_rev_operation_tbl(i).Attribute7 := c18rec.attribute7;
        g_public_rev_operation_tbl(i).Attribute8 := c18rec.attribute8;
        g_public_rev_operation_tbl(i).Attribute9 := c18rec.attribute9;
        g_public_rev_operation_tbl(i).Attribute10 := c18rec.attribute10;
        g_public_rev_operation_tbl(i).Attribute11 := c18rec.attribute11;
        g_public_rev_operation_tbl(i).Attribute12 := c18rec.attribute12;
        g_public_rev_operation_tbl(i).Attribute13 := c18rec.attribute13;
        g_public_rev_operation_tbl(i).Attribute14 := c18rec.attribute14;
        g_public_rev_operation_tbl(i).Attribute15 := c18rec.attribute15;
        g_public_rev_operation_tbl(i).Original_System_Reference := c18rec.original_system_reference;
        g_public_rev_operation_tbl(i).Return_Status := null;
        g_public_rev_operation_tbl(i).Transaction_Type := c18rec.transaction_type;
        -- Bug 3412268: Added New_Revised_Item_Revision
        g_public_rev_operation_tbl(i).New_Revised_Item_Revision := c18rec.New_Revised_Item_Revision;
    END LOOP;
END Get_Rev_Op_With_Curr_ECO_Ifce;


PROCEDURE Get_Op_Res_With_Curr_ECO_Ifce
IS
    cursor GetResources IS
        SELECT eco_name, organization_code, assembly_item_number,
          new_routing_revision, acd_type, alternate_routing_designator,
          operation_seq_num, operation_type, effectivity_date, resource_seq_num,
          resource_code, activity, standard_rate_flag, assigned_units,
          usage_rate_or_amount, usage_rate_or_amount_inverse, basis_type,
          schedule_flag, resource_offset_percent, autocharge_type,
          schedule_seq_num, principle_flag, attribute_category, attribute1,
          attribute2, attribute3, attribute4, attribute5, attribute6,
          attribute7, attribute8, attribute9, attribute10, attribute11,
          attribute12, attribute13, attribute14, attribute15,
          original_system_reference, transaction_type, setup_code
          -- Bug 3412268: Added New_Revised_Item_Revision
          , New_Revised_Item_Revision
        FROM bom_op_resources_interface
        WHERE eng_changes_ifce_key = g_ECO_ifce_key;
    i    NUMBER;
BEGIN
    i := 0;
    FOR c19rec IN GetResources LOOP
        i := i + 1;
/*
     Eco_Name                   VARCHAR2(10)        -- eco_name
   , Organization_Code          VARCHAR2(3)         -- organization_code
   , Revised_Item_Name          VARCHAR2(81)        -- assembly_item_number
   , New_Revised_Item_Revision  VARCHAR2(3)
   , From_End_Item_Unit_Number  VARCHAR2(30)
   , New_Routing_Revision       VARCHAR2(3)         -- new_routing_revision
   , ACD_Type                   NUMBER              -- acd_type
   , Alternate_Routing_Code     VARCHAR2(10)        -- alternate_routing_designator
   , Operation_Sequence_Number  NUMBER              -- operation_seq_num
   , Operation_Type             NUMBER              -- operation_type
   , Op_Start_Effective_Date    DATE                -- effectivity_date
   , Resource_Sequence_Number   NUMBER              -- resource_seq_num
   , Resource_Code              VARCHAR2(10)        -- resource_code
   , Activity                   VARCHAR2(10)        -- activity
   , Standard_Rate_Flag         NUMBER              -- standard_rate_flag
   , Assigned_Units             NUMBER              -- assigned_units
   , Usage_Rate_Or_Amount       NUMBER              -- usage_rate_or_amount
   , Usage_Rate_Or_Amount_Inverse   NUMBER          -- usage_rate_or_amount_inverse
   , Basis_Type                 NUMBER              -- basis_type
   , Schedule_Flag              NUMBER              -- schedule_flag
   , Resource_Offset_Percent    NUMBER              -- resource_offset_percent
   , Autocharge_Type            NUMBER              -- autocharge_type
   , Schedule_Sequence_Number   NUMBER              -- schedule_seq_num
   , Principle_Flag             NUMBER              -- principle_flag
   , Attribute_category         VARCHAR2(30)        -- attribute_category
   , Attribute1                 VARCHAR2(150)       --
   , Attribute2                 VARCHAR2(150)       -- attribute2
   , Attribute3                 VARCHAR2(150)       -- attribute3
   , Attribute4                 VARCHAR2(150)       -- attribute4
   , Attribute5                 VARCHAR2(150)       -- attribute5
   , Attribute6                 VARCHAR2(150)       -- attribute6
   , Attribute7                 VARCHAR2(150)       -- attribute7
   , Attribute8                 VARCHAR2(150)       -- attribute8
   , Attribute9                 VARCHAR2(150)       -- attribute9
   , Attribute10                VARCHAR2(150)       -- attribute10
   , Attribute11                VARCHAR2(150)       -- attribute11
   , Attribute12                VARCHAR2(150)       -- attribute12
   , Attribute13                VARCHAR2(150)       -- attribute13
   , Attribute14                VARCHAR2(150)       -- attribute14
   , Attribute15                VARCHAR2(150)       -- attribute15
   , Original_System_Reference  VARCHAR2(50)        -- original_system_reference
   , Transaction_Type           VARCHAR2(30)        -- transaction_type
   , Return_Status              VARCHAR2(1)
   , Setup_Type                 VARCHAR2(30)        -- setup_code
*/
        g_public_rev_op_res_tbl(i).Eco_Name := c19rec.eco_name;
        g_public_rev_op_res_tbl(i).Organization_Code := c19rec.organization_code;
        g_public_rev_op_res_tbl(i).Revised_Item_Name := c19rec.assembly_item_number;
        g_public_rev_op_res_tbl(i).New_Routing_Revision := c19rec.new_routing_revision;
        g_public_rev_op_res_tbl(i).ACD_Type := c19rec.acd_type;
        g_public_rev_op_res_tbl(i).Alternate_Routing_Code := c19rec.alternate_routing_designator;
        g_public_rev_op_res_tbl(i).Operation_Sequence_Number := c19rec.operation_seq_num;
        g_public_rev_op_res_tbl(i).Operation_Type := c19rec.operation_type;
        g_public_rev_op_res_tbl(i).Op_Start_Effective_Date := c19rec.effectivity_date;
        g_public_rev_op_res_tbl(i).Resource_Sequence_Number := c19rec.resource_seq_num;
        g_public_rev_op_res_tbl(i).Resource_Code := c19rec.resource_code;
        g_public_rev_op_res_tbl(i).Activity := c19rec.activity;
        g_public_rev_op_res_tbl(i).Standard_Rate_Flag := c19rec.standard_rate_flag;
        g_public_rev_op_res_tbl(i).Assigned_Units := c19rec.assigned_units;
        g_public_rev_op_res_tbl(i).Usage_Rate_Or_Amount := c19rec.usage_rate_or_amount;
        g_public_rev_op_res_tbl(i).Usage_Rate_Or_Amount_Inverse := c19rec.usage_rate_or_amount_inverse;
        g_public_rev_op_res_tbl(i).Basis_Type := c19rec.basis_type;
        g_public_rev_op_res_tbl(i).Schedule_Flag := c19rec.schedule_flag;
        g_public_rev_op_res_tbl(i).Resource_Offset_Percent := c19rec.resource_offset_percent;
        g_public_rev_op_res_tbl(i).Autocharge_Type := c19rec.autocharge_type;
        g_public_rev_op_res_tbl(i).Schedule_Sequence_Number := c19rec.schedule_seq_num;
        g_public_rev_op_res_tbl(i).Principle_Flag := c19rec.principle_flag;
        g_public_rev_op_res_tbl(i).Attribute_category := c19rec.attribute_category;
        g_public_rev_op_res_tbl(i).Attribute1 := c19rec.attribute1;
        g_public_rev_op_res_tbl(i).Attribute2 := c19rec.attribute2;
        g_public_rev_op_res_tbl(i).Attribute3 := c19rec.attribute3;
        g_public_rev_op_res_tbl(i).Attribute4 := c19rec.attribute4;
        g_public_rev_op_res_tbl(i).Attribute5 := c19rec.attribute5;
        g_public_rev_op_res_tbl(i).Attribute6 := c19rec.attribute6;
        g_public_rev_op_res_tbl(i).Attribute7 := c19rec.attribute7;
        g_public_rev_op_res_tbl(i).Attribute8 := c19rec.attribute8;
        g_public_rev_op_res_tbl(i).Attribute9 := c19rec.attribute9;
        g_public_rev_op_res_tbl(i).Attribute10 := c19rec.attribute10;
        g_public_rev_op_res_tbl(i).Attribute11 := c19rec.attribute11;
        g_public_rev_op_res_tbl(i).Attribute12 := c19rec.attribute12;
        g_public_rev_op_res_tbl(i).Attribute13 := c19rec.attribute13;
        g_public_rev_op_res_tbl(i).Attribute14 := c19rec.attribute14;
        g_public_rev_op_res_tbl(i).Attribute15 := c19rec.attribute15;
        g_public_rev_op_res_tbl(i).Original_System_Reference := c19rec.original_system_reference;
        g_public_rev_op_res_tbl(i).Transaction_Type := c19rec.transaction_type;
        g_public_rev_op_res_tbl(i).Setup_Type := c19rec.setup_code;
        -- Bug 3412268: Added New_Revised_Item_Revision
        g_public_rev_op_res_tbl(i).New_Revised_Item_Revision := c19rec.New_Revised_Item_Revision;
    END LOOP;
END Get_Op_Res_With_Curr_ECO_Ifce;


PROCEDURE Get_Sub_Op_Res_With_ECO_Ifce
IS
    cursor GetSubResources IS
        SELECT eco_name, organization_code, assembly_item_number,
          new_revised_item_revision, new_routing_revision, acd_type,
          alternate_routing_designator, operation_seq_num, operation_type,
          effectivity_date, sub_resource_code, new_sub_resource_code,
          schedule_seq_num, replacement_group_num, activity, standard_rate_flag,
          assigned_units, usage_rate_or_amount, usage_rate_or_amount_inverse,
          basis_type, schedule_flag, resource_offset_percent, autocharge_type,
          principle_flag, attribute_category, attribute1, attribute2,
          attribute3, attribute4, attribute5, attribute6, attribute7,
          attribute8, attribute9, attribute10, attribute11, attribute12,
          attribute13, attribute14, attribute15, original_system_reference,
          transaction_type, setup_code
          , new_basis_type -- Bug: 5067990
        FROM bom_sub_op_resources_interface
        WHERE eng_changes_ifce_key = g_ECO_ifce_key;

    i    NUMBER;
BEGIN
    i := 0;
    FOR c20rec IN GetSubResources LOOP
        i := i + 1;
/*
     Eco_Name                   VARCHAR2(10)            -- TBA eco_name
   , Organization_Code          VARCHAR2(3)             -- organization_code
   , Revised_Item_Name          VARCHAR2(81)            -- assembly_item_number
   , New_Revised_Item_Revision  VARCHAR2(3)             -- TBA new_revised_item_revision
   , From_End_Item_Unit_Number  VARCHAR2(30)
   , New_Routing_Revision       VARCHAR2(3)             -- TBA new_routing_revision
   , ACD_Type                   NUMBER                  -- TBA acd_type
   , Alternate_Routing_Code     VARCHAR2(10)            -- alternate_routing_designator
   , Operation_Sequence_Number  NUMBER                  -- operation_seq_num
   , Operation_Type             NUMBER                  -- operation_type
   , Op_Start_Effective_Date    DATE                    -- effectivity_date
   , Sub_Resource_Code          VARCHAR2(10)            -- sub_resource_code
   , New_Sub_Resource_Code      VARCHAR2(10)            -- new_sub_resource_code
   , Schedule_Sequence_Number   NUMBER                  -- schedule_seq_num
   , Replacement_Group_Number   NUMBER                  -- replacement_group_num
   , Activity                   VARCHAR2(10)            -- activity
   , Standard_Rate_Flag         NUMBER                  -- standard_rate_flag
   , Assigned_Units             NUMBER                  -- assigned_units
   , Usage_Rate_Or_Amount       NUMBER                  -- usage_rate_or_amount
   , Usage_Rate_Or_Amount_Inverse   NUMBER              -- usage_rate_or_amount_inverse
   , Basis_Type                 NUMBER                  -- basis_type
   , Schedule_Flag              NUMBER                  -- schedule_flag
   , Resource_Offset_Percent    NUMBER                  -- resource_offset_percent
   , Autocharge_Type            NUMBER                  -- autocharge_type
   , Principle_Flag             NUMBER                  -- principle_flag
   , Attribute_category         VARCHAR2(30)            -- attribute_category
   , Attribute1                 VARCHAR2(150)           -- attribute1
   , Attribute2                 VARCHAR2(150)           -- attribute2
   , Attribute3                 VARCHAR2(150)           -- attribute3
   , Attribute4                 VARCHAR2(150)           -- attribute4
   , Attribute5                 VARCHAR2(150)           -- attribute5
   , Attribute6                 VARCHAR2(150)           -- attribute6
   , Attribute7                 VARCHAR2(150)           -- attribute7
   , Attribute8                 VARCHAR2(150)           -- attribute8
   , Attribute9                 VARCHAR2(150)           -- attribute9
   , Attribute10                VARCHAR2(150)           -- attribute10
   , Attribute11                VARCHAR2(150)           -- attribute11
   , Attribute12                VARCHAR2(150)           -- attribute12
   , Attribute13                VARCHAR2(150)           -- attribute13
   , Attribute14                VARCHAR2(150)           -- attribute14
   , Attribute15                VARCHAR2(150)           -- attribute15
   , Original_System_Reference  VARCHAR2(50)            -- original_system_reference
   , Transaction_Type           VARCHAR2(30)            -- transaction_type
   , Return_Status              VARCHAR2(1)
   , Setup_Type                 VARCHAR2(30)            -- setup_code
*/
        g_public_rev_sub_res_tbl(i).Eco_Name := c20rec.eco_name;
        g_public_rev_sub_res_tbl(i).Organization_Code := c20rec.organization_code;
        g_public_rev_sub_res_tbl(i).Revised_Item_Name := c20rec.assembly_item_number;
        g_public_rev_sub_res_tbl(i).New_Revised_Item_Revision := c20rec.new_revised_item_revision;
        g_public_rev_sub_res_tbl(i).New_Routing_Revision := c20rec.new_routing_revision;
        g_public_rev_sub_res_tbl(i).ACD_Type := c20rec.acd_type;
        g_public_rev_sub_res_tbl(i).Alternate_Routing_Code := c20rec.alternate_routing_designator;
        g_public_rev_sub_res_tbl(i).Operation_Sequence_Number := c20rec.operation_seq_num;
        g_public_rev_sub_res_tbl(i).Operation_Type := c20rec.operation_type;
        g_public_rev_sub_res_tbl(i).Op_Start_Effective_Date := c20rec.effectivity_date;
        g_public_rev_sub_res_tbl(i).Sub_Resource_Code := c20rec.sub_resource_code;
        g_public_rev_sub_res_tbl(i).New_Sub_Resource_Code := c20rec.new_sub_resource_code;
        g_public_rev_sub_res_tbl(i).Schedule_Sequence_Number := c20rec.schedule_seq_num;
        g_public_rev_sub_res_tbl(i).Replacement_Group_Number := c20rec.replacement_group_num;
        g_public_rev_sub_res_tbl(i).Activity := c20rec.activity;
        g_public_rev_sub_res_tbl(i).Standard_Rate_Flag := c20rec.standard_rate_flag;
        g_public_rev_sub_res_tbl(i).Assigned_Units := c20rec.assigned_units;
        g_public_rev_sub_res_tbl(i).Usage_Rate_Or_Amount := c20rec.usage_rate_or_amount;
        g_public_rev_sub_res_tbl(i).Usage_Rate_Or_Amount_Inverse := c20rec.usage_rate_or_amount_inverse;
        g_public_rev_sub_res_tbl(i).Basis_Type := c20rec.basis_type;
        g_public_rev_sub_res_tbl(i).Schedule_Flag := c20rec.schedule_flag;
        g_public_rev_sub_res_tbl(i).Resource_Offset_Percent := c20rec.resource_offset_percent;
        g_public_rev_sub_res_tbl(i).Autocharge_Type := c20rec.autocharge_type;
        g_public_rev_sub_res_tbl(i).Principle_Flag := c20rec.principle_flag;
        g_public_rev_sub_res_tbl(i).Attribute_category := c20rec.attribute_category;
        g_public_rev_sub_res_tbl(i).Attribute1 := c20rec.attribute1;
        g_public_rev_sub_res_tbl(i).Attribute2 := c20rec.attribute2;
        g_public_rev_sub_res_tbl(i).Attribute3 := c20rec.attribute3;
        g_public_rev_sub_res_tbl(i).Attribute4 := c20rec.attribute4;
        g_public_rev_sub_res_tbl(i).Attribute5 := c20rec.attribute5;
        g_public_rev_sub_res_tbl(i).Attribute6 := c20rec.attribute6;
        g_public_rev_sub_res_tbl(i).Attribute7 := c20rec.attribute7;
        g_public_rev_sub_res_tbl(i).Attribute8 := c20rec.attribute8;
        g_public_rev_sub_res_tbl(i).Attribute9 := c20rec.attribute9;
        g_public_rev_sub_res_tbl(i).Attribute10 := c20rec.attribute10;
        g_public_rev_sub_res_tbl(i).Attribute11 := c20rec.attribute11;
        g_public_rev_sub_res_tbl(i).Attribute12 := c20rec.attribute12;
        g_public_rev_sub_res_tbl(i).Attribute13 := c20rec.attribute13;
        g_public_rev_sub_res_tbl(i).Attribute14 := c20rec.attribute14;
        g_public_rev_sub_res_tbl(i).Attribute15 := c20rec.attribute15;
        g_public_rev_sub_res_tbl(i).Original_System_Reference := c20rec.original_system_reference;
        g_public_rev_sub_res_tbl(i).Transaction_Type := c20rec.transaction_type;
        g_public_rev_sub_res_tbl(i).Setup_Type := c20rec.setup_code;
        g_public_rev_sub_res_tbl(i).New_Basis_Type := c20rec.New_Basis_Type; -- Bug: 5067990
    END LOOP;

END Get_Sub_Op_Res_With_ECO_Ifce;



-- Procedure Move_Encoin_Struct_To_Public
-- Move all encoin data structures to public API parameter structures

PROCEDURE Move_Encoin_Struct_To_Public
IS
        k                       NUMBER;
        l                       NUMBER;
        j                       NUMBER;
        p                       NUMBER;
BEGIN

   -- Move Revised Items

   IF g_encoin_rev_item_tbl.COUNT <> 0
   THEN
      --dbms_output.put_line('Moving item encoin data structures to public data structures');

      FOR k in 1..g_encoin_rev_item_tbl.COUNT LOOP
            g_public_rev_item_tbl(k).eco_name := g_encoin_rev_item_tbl(k).change_notice;
--            g_public_rev_item_tbl(k).organization_id := g_encoin_rev_item_tbl(k).organization_id;
--            g_public_rev_item_tbl(k).revised_item_id := g_encoin_rev_item_tbl(k).revised_item_id;
--            g_public_rev_item_tbl(k).last_update_date := g_encoin_rev_item_tbl(k).last_update_date;
--            g_public_rev_item_tbl(k).last_updated_by := g_encoin_rev_item_tbl(k).last_updated_by;
--            g_public_rev_item_tbl(k).creation_date := g_encoin_rev_item_tbl(k).creation_date;
--            g_public_rev_item_tbl(k).created_by := g_encoin_rev_item_tbl(k).created_by;
--            g_public_rev_item_tbl(k).last_update_login := g_encoin_rev_item_tbl(k).last_update_login;
--            g_public_rev_item_tbl(k).implementation_date := g_encoin_rev_item_tbl(k).implementation_date;
--            g_public_rev_item_tbl(k).cancellation_date := g_encoin_rev_item_tbl(k).cancellation_date;
            g_public_rev_item_tbl(k).cancel_comments := g_encoin_rev_item_tbl(k).cancel_comments;
            g_public_rev_item_tbl(k).disposition_type := g_encoin_rev_item_tbl(k).disposition_type;
            g_public_rev_item_tbl(k).new_revised_item_revision := g_encoin_rev_item_tbl(k).new_item_revision;
            g_public_rev_item_tbl(k).Earliest_Effective_Date := g_encoin_rev_item_tbl(k).early_schedule_date;
            g_public_rev_item_tbl(k).attribute_category := g_encoin_rev_item_tbl(k).attribute_category;
            g_public_rev_item_tbl(k).attribute2 := g_encoin_rev_item_tbl(k).attribute2;
            g_public_rev_item_tbl(k).attribute3 := g_encoin_rev_item_tbl(k).attribute3;
            g_public_rev_item_tbl(k).attribute4 := g_encoin_rev_item_tbl(k).attribute4;
            g_public_rev_item_tbl(k).attribute5 := g_encoin_rev_item_tbl(k).attribute5;
            g_public_rev_item_tbl(k).attribute7 := g_encoin_rev_item_tbl(k).attribute7;
            g_public_rev_item_tbl(k).attribute8 := g_encoin_rev_item_tbl(k).attribute8;
            g_public_rev_item_tbl(k).attribute9 := g_encoin_rev_item_tbl(k).attribute9;
            g_public_rev_item_tbl(k).attribute11 := g_encoin_rev_item_tbl(k).attribute11;
            g_public_rev_item_tbl(k).attribute12 := g_encoin_rev_item_tbl(k).attribute12;
            g_public_rev_item_tbl(k).attribute13 := g_encoin_rev_item_tbl(k).attribute13;
            g_public_rev_item_tbl(k).attribute14 := g_encoin_rev_item_tbl(k).attribute14;
            g_public_rev_item_tbl(k).attribute15 := g_encoin_rev_item_tbl(k).attribute15;
            g_public_rev_item_tbl(k).status_type := g_encoin_rev_item_tbl(k).status_type;
            g_public_rev_item_tbl(k).start_effective_date := g_encoin_rev_item_tbl(k).scheduled_date;
--            g_public_rev_item_tbl(k).bill_sequence_id := g_encoin_rev_item_tbl(k).bill_sequence_id;
            g_public_rev_item_tbl(k).mrp_active := g_encoin_rev_item_tbl(k).mrp_active;
--            g_public_rev_item_tbl(k).request_id := g_encoin_rev_item_tbl(k).request_id;
--            g_public_rev_item_tbl(k).program_application_id := g_encoin_rev_item_tbl(k).program_application_id;
--            g_public_rev_item_tbl(k).program_id := g_encoin_rev_item_tbl(k).program_id;
--            g_public_rev_item_tbl(k).program_update_date := g_encoin_rev_item_tbl(k).program_update_date;
            g_public_rev_item_tbl(k).update_wip := g_encoin_rev_item_tbl(k).update_wip;
--            g_public_rev_item_tbl(k).use_up := g_encoin_rev_item_tbl(k).use_up;
--            g_public_rev_item_tbl(k).use_up_item_id := g_encoin_rev_item_tbl(k).use_up_item_id;
--            g_public_rev_item_tbl(k).revised_item_sequence_id := g_encoin_rev_item_tbl(k).revised_item_sequence_id;
            g_public_rev_item_tbl(k).use_up_plan_name := g_encoin_rev_item_tbl(k).use_up_plan_name;
	    /* Un-commented the below code for bug 22134406, this ensures that ECO Open Interface
	       populates the value for 'Change Description' of revised item. Prior to this fix, it
	       was populating NULL value although we provide value for 'Change Description' and run ENCOIN. */
            g_public_rev_item_tbl(k).change_description := g_encoin_rev_item_tbl(k).descriptive_text;
--            g_public_rev_item_tbl(k).auto_implement_date := g_encoin_rev_item_tbl(k).auto_implement_date;
            g_public_rev_item_tbl(k).attribute1 := g_encoin_rev_item_tbl(k).attribute1;
            g_public_rev_item_tbl(k).attribute6 := g_encoin_rev_item_tbl(k).attribute6;
            g_public_rev_item_tbl(k).attribute10 := g_encoin_rev_item_tbl(k).attribute10;
--            g_public_rev_item_tbl(k).requestor_id := g_encoin_rev_item_tbl(k).requestor_id;
--            g_public_rev_item_tbl(k).comments := g_encoin_rev_item_tbl(k).comments;
--            g_public_rev_item_tbl(k).process_flag := g_encoin_rev_item_tbl(k).process_flag;
            g_public_rev_item_tbl(k).transaction_id := g_encoin_rev_item_tbl(k).transaction_id;
            g_public_rev_item_tbl(k).organization_code := g_encoin_rev_item_tbl(k).organization_code;
            g_public_rev_item_tbl(k).revised_item_name := g_encoin_rev_item_tbl(k).revised_item_number;
            g_public_rev_item_tbl(k).new_routing_revision := g_encoin_rev_item_tbl(k).new_rtg_revision;
            g_public_rev_item_tbl(k).use_up_item_name := g_encoin_rev_item_tbl(k).use_up_item_number;
            g_public_rev_item_tbl(k).alternate_bom_code := g_encoin_rev_item_tbl(k).alternate_bom_designator; -- Added to Fix 2869146
            g_public_rev_item_tbl(k).transaction_type := g_encoin_rev_item_tbl(k).operation;
            --11.5.10 chnages
            g_public_rev_item_tbl(k).parent_revised_item_name  := g_encoin_rev_item_tbl(k).parent_revised_item_name ;
            g_public_rev_item_tbl(k).parent_alternate_name     := g_encoin_rev_item_tbl(k).parent_alternate_name    ;

            g_public_rev_item_tbl(k).New_Effective_Date := g_encoin_rev_item_tbl(k).new_scheduled_date; -- Bug 3432944
            g_public_rev_item_tbl(k).Updated_Revised_Item_Revision := g_encoin_rev_item_tbl(k).updated_item_revision;   -- Bug 3432944
            g_public_rev_item_tbl(k).from_item_revision := g_encoin_rev_item_tbl(k).from_item_revision; -- 11.5.10E
            g_public_rev_item_tbl(k).new_revision_label := g_encoin_rev_item_tbl(k).new_revision_label;
            g_public_rev_item_tbl(k).New_Revised_Item_Rev_Desc := g_encoin_rev_item_tbl(k).New_Revised_Item_Rev_Desc;
            g_public_rev_item_tbl(k).new_revision_reason := g_encoin_rev_item_tbl(k).new_revision_reason;
            g_public_rev_item_tbl(k).from_end_item_unit_number := g_encoin_rev_item_tbl(k).from_end_item_unit_number;  /*Bug 6377841*/
              --11.5.10 chnages
            g_encoin_rev_item_tbl.DELETE(k);
      END LOOP; -- End Rev Items Loop
   END IF;

   -- Move Revised Components

   IF g_encoin_rev_comp_tbl.COUNT <> 0
   THEN
      --dbms_output.put_line('Moving comp encoin data structures to public data structures');

      FOR l in 1..g_encoin_rev_comp_tbl.COUNT LOOP
           g_public_rev_comp_tbl(l).supply_subinventory := g_encoin_rev_comp_tbl(l).supply_subinventory;
--           g_public_rev_comp_tbl(l).OP_LEAD_TIME_PERCENT := g_encoin_rev_comp_tbl(l).OP_LEAD_TIME_PERCENT;
--           g_public_rev_comp_tbl(l).revised_item_sequence_id := g_encoin_rev_comp_tbl(l).revised_item_sequence_id;
--           g_public_rev_comp_tbl(l).cost_factor := g_encoin_rev_comp_tbl(l).cost_factor;
           g_public_rev_comp_tbl(l).required_for_revenue := g_encoin_rev_comp_tbl(l).required_for_revenue;
           g_public_rev_comp_tbl(l).maximum_allowed_quantity := g_encoin_rev_comp_tbl(l).high_quantity;
--           g_public_rev_comp_tbl(l).component_sequence_id := g_encoin_rev_comp_tbl(l).component_sequence_id;
--           g_public_rev_comp_tbl(l).program_application_id := g_encoin_rev_comp_tbl(l).program_application_id;
           g_public_rev_comp_tbl(l).wip_supply_type := g_encoin_rev_comp_tbl(l).wip_supply_type;
--           g_public_rev_comp_tbl(l).supply_locator_id := g_encoin_rev_comp_tbl(l).supply_locator_id;
--           g_public_rev_comp_tbl(l).bom_item_type := g_encoin_rev_comp_tbl(l).bom_item_type;
           g_public_rev_comp_tbl(l).operation_sequence_number := g_encoin_rev_comp_tbl(l).operation_seq_num;
--           g_public_rev_comp_tbl(l).component_item_id := g_encoin_rev_comp_tbl(l).component_item_id;
--           g_public_rev_comp_tbl(l).last_update_date := g_encoin_rev_comp_tbl(l).last_update_date;
--           g_public_rev_comp_tbl(l).last_updated_by := g_encoin_rev_comp_tbl(l).last_updated_by;
--           g_public_rev_comp_tbl(l).creation_date := g_encoin_rev_comp_tbl(l).creation_date;
--           g_public_rev_comp_tbl(l).created_by := g_encoin_rev_comp_tbl(l).created_by;
--           g_public_rev_comp_tbl(l).last_update_login := g_encoin_rev_comp_tbl(l).last_update_login;
           g_public_rev_comp_tbl(l).item_sequence_number := g_encoin_rev_comp_tbl(l).item_num;
           g_public_rev_comp_tbl(l).quantity_per_assembly := g_encoin_rev_comp_tbl(l).component_quantity;
           g_public_rev_comp_tbl(l).projected_yield := g_encoin_rev_comp_tbl(l).component_yield_factor;
           g_public_rev_comp_tbl(l).COMMENTS := g_encoin_rev_comp_tbl(l).component_remarks;
           g_public_rev_comp_tbl(l).revised_item_name := g_encoin_rev_comp_tbl(l).revised_item_number;
           g_public_rev_comp_tbl(l).start_effective_date := g_encoin_rev_comp_tbl(l).effectivity_date;
               g_public_rev_comp_tbl(l).eco_name := g_encoin_rev_comp_tbl(l).change_notice;
--           g_public_rev_comp_tbl(l).implementation_date := g_encoin_rev_comp_tbl(l).implementation_date;
           g_public_rev_comp_tbl(l).disable_date := g_encoin_rev_comp_tbl(l).disable_date;
           g_public_rev_comp_tbl(l).attribute_category := g_encoin_rev_comp_tbl(l).attribute_category;
           g_public_rev_comp_tbl(l).attribute1 := g_encoin_rev_comp_tbl(l).attribute1;
           g_public_rev_comp_tbl(l).attribute2 := g_encoin_rev_comp_tbl(l).attribute2;
           g_public_rev_comp_tbl(l).attribute3 := g_encoin_rev_comp_tbl(l).attribute3;
           g_public_rev_comp_tbl(l).attribute4 := g_encoin_rev_comp_tbl(l).attribute4;
           g_public_rev_comp_tbl(l).attribute5 := g_encoin_rev_comp_tbl(l).attribute5;
           g_public_rev_comp_tbl(l).attribute6 := g_encoin_rev_comp_tbl(l).attribute6;
           g_public_rev_comp_tbl(l).attribute7 := g_encoin_rev_comp_tbl(l).attribute7;
           g_public_rev_comp_tbl(l).attribute8 := g_encoin_rev_comp_tbl(l).attribute8;
           g_public_rev_comp_tbl(l).attribute9 := g_encoin_rev_comp_tbl(l).attribute9;
           g_public_rev_comp_tbl(l).attribute10 := g_encoin_rev_comp_tbl(l).attribute10;
           g_public_rev_comp_tbl(l).attribute11 := g_encoin_rev_comp_tbl(l).attribute11;
           g_public_rev_comp_tbl(l).attribute12 := g_encoin_rev_comp_tbl(l).attribute12;
           g_public_rev_comp_tbl(l).attribute13 := g_encoin_rev_comp_tbl(l).attribute13;
           g_public_rev_comp_tbl(l).attribute14 := g_encoin_rev_comp_tbl(l).attribute14;
           g_public_rev_comp_tbl(l).attribute15 := g_encoin_rev_comp_tbl(l).attribute15;
           g_public_rev_comp_tbl(l).planning_percent := g_encoin_rev_comp_tbl(l).planning_factor;
           g_public_rev_comp_tbl(l).quantity_related := g_encoin_rev_comp_tbl(l).quantity_related;
           g_public_rev_comp_tbl(l).so_basis := g_encoin_rev_comp_tbl(l).so_basis;
           g_public_rev_comp_tbl(l).optional := g_encoin_rev_comp_tbl(l).optional;
           g_public_rev_comp_tbl(l).mutually_exclusive := g_encoin_rev_comp_tbl(l).MUTUALLY_EXCLUSIVE_OPT;
           g_public_rev_comp_tbl(l).include_in_cost_rollup := g_encoin_rev_comp_tbl(l).include_in_cost_rollup;
           g_public_rev_comp_tbl(l).check_atp := g_encoin_rev_comp_tbl(l).check_atp;
           g_public_rev_comp_tbl(l).shipping_allowed := g_encoin_rev_comp_tbl(l).shipping_allowed;
           g_public_rev_comp_tbl(l).required_to_ship := g_encoin_rev_comp_tbl(l).required_to_ship;
           g_public_rev_comp_tbl(l).include_on_ship_docs := g_encoin_rev_comp_tbl(l).include_on_ship_docs;
--           g_public_rev_comp_tbl(l).include_on_bill_docs := g_encoin_rev_comp_tbl(l).include_on_bill_docs;
           g_public_rev_comp_tbl(l).minimum_allowed_quantity := g_encoin_rev_comp_tbl(l).low_quantity;
           g_public_rev_comp_tbl(l).acd_type := g_encoin_rev_comp_tbl(l).acd_type;
--           g_public_rev_comp_tbl(l).old_component_sequence_id := g_encoin_rev_comp_tbl(l).old_component_sequence_id;
--           g_public_rev_comp_tbl(l).bill_sequence_id := g_encoin_rev_comp_tbl(l).bill_sequence_id;
--           g_public_rev_comp_tbl(l).request_id := g_encoin_rev_comp_tbl(l).request_id;
--           g_public_rev_comp_tbl(l).program_id := g_encoin_rev_comp_tbl(l).program_id;
--           g_public_rev_comp_tbl(l).program_update_date := g_encoin_rev_comp_tbl(l).program_update_date;
--           g_public_rev_comp_tbl(l).pick_components := g_encoin_rev_comp_tbl(l).pick_components;
--           g_public_rev_comp_tbl(l).assembly_type := g_encoin_rev_comp_tbl(l).assembly_type;
--           g_public_rev_comp_tbl(l).interface_entity_type := g_encoin_rev_comp_tbl(l).interface_entity_type;
--           g_public_rev_comp_tbl(l).reference_designator := g_encoin_rev_comp_tbl(l).reference_designator;
           g_public_rev_comp_tbl(l).new_effectivity_date := g_encoin_rev_comp_tbl(l).new_effectivity_date;
           g_public_rev_comp_tbl(l).old_effectivity_date := g_encoin_rev_comp_tbl(l).old_effectivity_date;
--           g_public_rev_comp_tbl(l).substitute_comp_id := g_encoin_rev_comp_tbl(l).substitute_comp_id;
           g_public_rev_comp_tbl(l).new_operation_sequence_number := g_encoin_rev_comp_tbl(l).new_operation_seq_num;
           g_public_rev_comp_tbl(l).old_operation_sequence_number := g_encoin_rev_comp_tbl(l).old_operation_seq_num;
--           g_public_rev_comp_tbl(l).process_flag := g_encoin_rev_comp_tbl(l).process_flag;
           g_public_rev_comp_tbl(l).row_identifier := g_encoin_rev_comp_tbl(l).transaction_id;
--           g_public_rev_comp_tbl(l).SUBSTITUTE_COMP_NUMBER := g_encoin_rev_comp_tbl(l).SUBSTITUTE_COMP_NUMBER;
           g_public_rev_comp_tbl(l).ORGANIZATION_CODE := g_encoin_rev_comp_tbl(l).ORGANIZATION_CODE;
--           g_public_rev_comp_tbl(l).ASSEMBLY_ITEM_NUMBER := g_encoin_rev_comp_tbl(l).ASSEMBLY_ITEM_NUMBER;
           g_public_rev_comp_tbl(l).COMPONENT_ITEM_NAME := g_encoin_rev_comp_tbl(l).COMPONENT_ITEM_NUMBER;
           g_public_rev_comp_tbl(l).LOCATION_NAME := g_encoin_rev_comp_tbl(l).LOCATION_NAME;
--           g_public_rev_comp_tbl(l).ORGANIZATION_ID := g_encoin_rev_comp_tbl(l).ORGANIZATION_ID;
--           g_public_rev_comp_tbl(l).ASSEMBLY_ITEM_ID := g_encoin_rev_comp_tbl(l).ASSEMBLY_ITEM_ID;
           g_public_rev_comp_tbl(l).ALTERNATE_BOM_CODE := g_encoin_rev_comp_tbl(l).ALTERNATE_BOM_DESIGNATOR;
           g_public_rev_comp_tbl(l).transaction_type := g_encoin_rev_comp_tbl(l).operation;
--           g_public_rev_comp_tbl(l).revised_item_tbl_index := g_encoin_rev_comp_tbl(l).revised_item_tbl_index;
--Bug 3396529: Added New_revised_Item_Revision
           g_public_rev_comp_tbl(l).New_revised_Item_Revision := g_encoin_rev_comp_tbl(l).New_revised_Item_Revision;
           g_public_rev_comp_tbl(l).from_end_item_unit_number := g_encoin_rev_comp_tbl(l).from_end_item_unit_number;  /*Bug 6377841*/
           g_public_rev_comp_tbl(l).to_end_item_unit_number := g_encoin_rev_comp_tbl(l).to_end_item_unit_number;      /*Bug 6377841*/
/*           g_public_rev_comp_tbl(l).old_from_end_item_unit_number := g_encoin_rev_comp_tbl(l).old_from_end_item_unit_number;  BUG 9374069 revert 8414408*/

           g_encoin_rev_comp_tbl.DELETE(l);
      END LOOP; -- End Rev Comps Loop
   END IF;

   -- Move Reference Designators

   IF g_encoin_ref_des_tbl.COUNT <> 0
   THEN
      --dbms_output.put_line('Moving rfd encoin data structures to public data structures');

      FOR k in 1..g_encoin_ref_des_tbl.COUNT LOOP
           g_public_ref_des_tbl(k).reference_designator_name := g_encoin_ref_des_tbl(k).REF_DESIGNATOR;
--           g_public_ref_des_tbl(k).last_update_date := g_encoin_ref_des_tbl(k).last_update_date;
--           g_public_ref_des_tbl(k).last_updated_by := g_encoin_ref_des_tbl(k).last_updated_by;
--           g_public_ref_des_tbl(k).creation_date := g_encoin_ref_des_tbl(k).creation_date;
--           g_public_ref_des_tbl(k).created_by := g_encoin_ref_des_tbl(k).created_by;
--           g_public_ref_des_tbl(k).last_update_login := g_encoin_ref_des_tbl(k).last_update_login;
           g_public_ref_des_tbl(k).ref_designator_comment := g_encoin_ref_des_tbl(k).ref_designator_comment;
           g_public_ref_des_tbl(k).eco_name := g_encoin_ref_des_tbl(k).change_notice;
--           g_public_ref_des_tbl(k).component_sequence_id := g_encoin_ref_des_tbl(k).component_sequence_id;
           g_public_ref_des_tbl(k).acd_type := g_encoin_ref_des_tbl(k).acd_type;
--           g_public_ref_des_tbl(k).request_id := g_encoin_ref_des_tbl(k).request_id;
--           g_public_ref_des_tbl(k).program_application_id := g_encoin_ref_des_tbl(k).program_application_id;
--           g_public_ref_des_tbl(k).program_id := g_encoin_ref_des_tbl(k).program_id;
--           g_public_ref_des_tbl(k).program_update_date := g_encoin_ref_des_tbl(k).program_update_date;
           g_public_ref_des_tbl(k).attribute_category := g_encoin_ref_des_tbl(k).attribute_category;
           g_public_ref_des_tbl(k).attribute1 := g_encoin_ref_des_tbl(k).attribute1;
           g_public_ref_des_tbl(k).attribute2 := g_encoin_ref_des_tbl(k).attribute2;
           g_public_ref_des_tbl(k).attribute3 := g_encoin_ref_des_tbl(k).attribute3;
           g_public_ref_des_tbl(k).attribute4 := g_encoin_ref_des_tbl(k).attribute4;
           g_public_ref_des_tbl(k).attribute5 := g_encoin_ref_des_tbl(k).attribute5;
           g_public_ref_des_tbl(k).attribute6 := g_encoin_ref_des_tbl(k).attribute6;
           g_public_ref_des_tbl(k).attribute7 := g_encoin_ref_des_tbl(k).attribute7;
           g_public_ref_des_tbl(k).attribute8 := g_encoin_ref_des_tbl(k).attribute8;
           g_public_ref_des_tbl(k).attribute9 := g_encoin_ref_des_tbl(k).attribute9;
           g_public_ref_des_tbl(k).attribute10 := g_encoin_ref_des_tbl(k).attribute10;
           g_public_ref_des_tbl(k).attribute11 := g_encoin_ref_des_tbl(k).attribute11;
           g_public_ref_des_tbl(k).attribute12 := g_encoin_ref_des_tbl(k).attribute12;
           g_public_ref_des_tbl(k).attribute13 := g_encoin_ref_des_tbl(k).attribute13;
           g_public_ref_des_tbl(k).attribute14 := g_encoin_ref_des_tbl(k).attribute14;
           g_public_ref_des_tbl(k).attribute15 := g_encoin_ref_des_tbl(k).attribute15;
--           g_public_ref_des_tbl(k).new_designator := g_encoin_ref_des_tbl(k).new_designator;
--           g_public_ref_des_tbl(k).process_flag := g_encoin_ref_des_tbl(k).process_flag;
--           g_public_ref_des_tbl(k).transaction_id := g_encoin_ref_des_tbl(k).transaction_id;
           g_public_ref_des_tbl(k).revised_item_name := g_encoin_ref_des_tbl(k).ASSEMBLY_ITEM_NUMBER;
           g_public_ref_des_tbl(k).COMPONENT_ITEM_NAME := g_encoin_ref_des_tbl(k).COMPONENT_ITEM_NUMBER;
           g_public_ref_des_tbl(k).ORGANIZATION_CODE := g_encoin_ref_des_tbl(k).ORGANIZATION_CODE;
--           g_public_ref_des_tbl(k).ORGANIZATION_ID := g_encoin_ref_des_tbl(k).ORGANIZATION_ID;
--           g_public_ref_des_tbl(k).ASSEMBLY_ITEM_ID := g_encoin_ref_des_tbl(k).ASSEMBLY_ITEM_ID;
           g_public_ref_des_tbl(k).Alternate_Bom_Code := g_encoin_ref_des_tbl(k).ALTERNATE_BOM_DESIGNATOR;
--           g_public_ref_des_tbl(k).COMPONENT_ITEM_ID := g_encoin_ref_des_tbl(k).COMPONENT_ITEM_ID;
--           g_public_ref_des_tbl(k).BILL_SEQUENCE_ID := g_encoin_ref_des_tbl(k).BILL_SEQUENCE_ID;
           g_public_ref_des_tbl(k).OPERATION_SEQUENCE_NUMBER := g_encoin_ref_des_tbl(k).OPERATION_SEQ_NUM;
           g_public_ref_des_tbl(k).START_EFFECTIVE_DATE := g_encoin_ref_des_tbl(k).EFFECTIVITY_DATE;
        --   g_public_ref_des_tbl(k).interface_entity_type := g_encoin_ref_des_tbl(k).interface_entity_type;
           g_public_ref_des_tbl(k).transaction_type := g_encoin_ref_des_tbl(k).operation;
           --Bug 3396529: Added New_revised_Item_Revision
           g_public_ref_des_tbl(k).New_revised_Item_Revision := g_encoin_ref_des_tbl(k).New_revised_Item_Revision;

        --   g_public_ref_des_tbl(k).revised_comp_tbl_index := g_encoin_ref_des_tbl(k).revised_comp_tbl_index;
           g_encoin_ref_des_tbl.DELETE(k);
      END LOOP; -- END Ref Desgs loop
   END IF;

   -- Move Substitute Components

   IF g_encoin_sub_comp_tbl.COUNT <> 0
   THEN
      --dbms_output.put_line('Moving sbc encoin data structures to public data structures');

      FOR p in 1..g_encoin_sub_comp_tbl.COUNT LOOP
--           g_public_sub_comp_tbl(p).substitute_component_id := g_encoin_sub_comp_tbl(p).substitute_component_id;
--           g_public_sub_comp_tbl(p).last_update_date := g_encoin_sub_comp_tbl(p).last_update_date;
--           g_public_sub_comp_tbl(p).last_updated_by := g_encoin_sub_comp_tbl(p).last_updated_by;
--           g_public_sub_comp_tbl(p).creation_date := g_encoin_sub_comp_tbl(p).creation_date;
--           g_public_sub_comp_tbl(p).created_by := g_encoin_sub_comp_tbl(p).created_by;
--           g_public_sub_comp_tbl(p).last_update_login := g_encoin_sub_comp_tbl(p).last_update_login;
           g_public_sub_comp_tbl(p).substitute_item_quantity := g_encoin_sub_comp_tbl(p).substitute_item_quantity;
--           g_public_sub_comp_tbl(p).component_sequence_id := g_encoin_sub_comp_tbl(p).component_sequence_id;
           g_public_sub_comp_tbl(p).acd_type := g_encoin_sub_comp_tbl(p).acd_type;
           g_public_sub_comp_tbl(p).eco_name := g_encoin_sub_comp_tbl(p).change_notice;
--           g_public_sub_comp_tbl(p).request_id := g_encoin_sub_comp_tbl(p).request_id;
--           g_public_sub_comp_tbl(p).program_application_id := g_encoin_sub_comp_tbl(p).program_application_id;
--           g_public_sub_comp_tbl(p).program_update_date := g_encoin_sub_comp_tbl(p).program_update_date;
           g_public_sub_comp_tbl(p).attribute_category := g_encoin_sub_comp_tbl(p).attribute_category;
           g_public_sub_comp_tbl(p).attribute1 := g_encoin_sub_comp_tbl(p).attribute1;
           g_public_sub_comp_tbl(p).attribute1 := g_encoin_sub_comp_tbl(p).attribute2;
           g_public_sub_comp_tbl(p).attribute1 := g_encoin_sub_comp_tbl(p).attribute4;
           g_public_sub_comp_tbl(p).attribute1 := g_encoin_sub_comp_tbl(p).attribute5;
           g_public_sub_comp_tbl(p).attribute1 := g_encoin_sub_comp_tbl(p).attribute6;
           g_public_sub_comp_tbl(p).attribute8 := g_encoin_sub_comp_tbl(p).attribute8;
           g_public_sub_comp_tbl(p).attribute9 := g_encoin_sub_comp_tbl(p).attribute9;
           g_public_sub_comp_tbl(p).attribute10 := g_encoin_sub_comp_tbl(p).attribute10;
           g_public_sub_comp_tbl(p).attribute12 := g_encoin_sub_comp_tbl(p).attribute12;
           g_public_sub_comp_tbl(p).attribute13 := g_encoin_sub_comp_tbl(p).attribute13;
           g_public_sub_comp_tbl(p).attribute14 := g_encoin_sub_comp_tbl(p).attribute14;
           g_public_sub_comp_tbl(p).attribute15 := g_encoin_sub_comp_tbl(p).attribute15;
           g_public_sub_comp_tbl(p).program_id := g_encoin_sub_comp_tbl(p).program_id;
           g_public_sub_comp_tbl(p).attribute3 := g_encoin_sub_comp_tbl(p).attribute3;
           g_public_sub_comp_tbl(p).attribute7 := g_encoin_sub_comp_tbl(p).attribute7;
           g_public_sub_comp_tbl(p).attribute11 := g_encoin_sub_comp_tbl(p).attribute11;
--           g_public_sub_comp_tbl(p).new_sub_comp_id := g_encoin_sub_comp_tbl(p).new_sub_comp_id;
--           g_public_sub_comp_tbl(p).process_flag := g_encoin_sub_comp_tbl(p).process_flag;
           g_public_sub_comp_tbl(p).row_identifier := g_encoin_sub_comp_tbl(p).transaction_id;
--           g_public_sub_comp_tbl(p).NEW_SUB_COMP_NUMBER := g_encoin_sub_comp_tbl(p).NEW_SUB_COMP_NUMBER;
           g_public_sub_comp_tbl(p).revised_item_name := g_encoin_sub_comp_tbl(p).ASSEMBLY_ITEM_NUMBER;
           g_public_sub_comp_tbl(p).COMPONENT_ITEM_NAME := g_encoin_sub_comp_tbl(p).COMPONENT_ITEM_NUMBER;
           g_public_sub_comp_tbl(p).SUBSTITUTE_COMPONENT_NAME := g_encoin_sub_comp_tbl(p).SUBSTITUTE_COMP_NUMBER;
           g_public_sub_comp_tbl(p).ORGANIZATION_CODE := g_encoin_sub_comp_tbl(p).ORGANIZATION_CODE;
--           g_public_sub_comp_tbl(p).ORGANIZATION_ID := g_encoin_sub_comp_tbl(p).ORGANIZATION_ID;
--           g_public_sub_comp_tbl(p).ASSEMBLY_ITEM_ID := g_encoin_sub_comp_tbl(p).ASSEMBLY_ITEM_ID;
           g_public_sub_comp_tbl(p).Alternate_Bom_Code := g_encoin_sub_comp_tbl(p).ALTERNATE_BOM_DESIGNATOR;
--           g_public_sub_comp_tbl(p).COMPONENT_ITEM_ID := g_encoin_sub_comp_tbl(p).COMPONENT_ITEM_ID;
--           g_public_sub_comp_tbl(p).BILL_SEQUENCE_ID := g_encoin_sub_comp_tbl(p).BILL_SEQUENCE_ID;
           g_public_sub_comp_tbl(p).OPERATION_SEQUENCE_NUMBER := g_encoin_sub_comp_tbl(p).OPERATION_SEQ_NUM;
           g_public_sub_comp_tbl(p).START_EFFECTIVE_DATE := g_encoin_sub_comp_tbl(p).EFFECTIVITY_DATE;
--           g_public_sub_comp_tbl(p).interface_entity_type := g_encoin_sub_comp_tbl(p).interface_entity_type;
           g_public_sub_comp_tbl(p).transaction_type := g_encoin_sub_comp_tbl(p).operation;
           --Bug 3396529: Added New_revised_Item_Revision
           g_public_sub_comp_tbl(p).New_revised_Item_Revision := g_encoin_sub_comp_tbl(p).New_revised_Item_Revision;

--           g_public_sub_comp_tbl(p).revised_comp_tbl_index := g_encoin_sub_comp_tbl(p).revised_comp_tbl_index;
           g_encoin_sub_comp_tbl.DELETE(p);
      END LOOP; -- END Sub Comps Loop
   END IF;
END Move_Encoin_Struct_To_Public;

-- Procedure ResolveIndexKeys
-- Translate parent ifce keys into parent array indexes

PROCEDURE ResolveIndexKeys
IS
    i              NUMBER;
    j              NUMBER;
    k              NUMBER;
    rev_item_count NUMBER;
    rev_comp_count NUMBER;
BEGIN

  rev_item_count := g_encoin_rev_item_tbl.COUNT;
  rev_comp_count := g_encoin_rev_comp_tbl.COUNT;

  -- Resolve parent revised item ifce keys for all revised components

    FOR i IN 1..rev_item_count
    LOOP
        IF g_encoin_rev_item_tbl(i).eng_revised_items_ifce_key IS NOT NULL
        THEN
            FOR j IN 1..rev_comp_count
            LOOP
                IF g_encoin_rev_comp_tbl(j).eng_revised_items_ifce_key =
                        g_encoin_rev_item_tbl(i).eng_revised_items_ifce_key
                THEN
                    g_encoin_rev_comp_tbl(j).revised_item_tbl_index := i;
                    --dbms_output.put_line('rev tbl index : ' ||
                        --to_char(g_encoin_rev_comp_tbl(j).revised_item_tbl_index));
                END IF;
            END LOOP;
        END IF;
    END LOOP;

  -- Resolve parent revised component ifce keys for all ref desgs and sub comps

    FOR i IN 1..rev_comp_count
    LOOP
        IF g_encoin_rev_comp_tbl(i).bom_inventory_comps_ifce_key IS NOT NULL
        THEN
            FOR j IN 1..g_encoin_ref_des_tbl.COUNT
            LOOP
                IF g_encoin_ref_des_tbl(j).bom_inventory_comps_ifce_key =
                        g_encoin_rev_comp_tbl(i).bom_inventory_comps_ifce_key
                THEN
                    g_encoin_ref_des_tbl(j).revised_comp_tbl_index := i;
                END IF;
            END LOOP;

            FOR k IN 1..g_encoin_sub_comp_tbl.COUNT
            LOOP
                IF g_encoin_sub_comp_tbl(k).bom_inventory_comps_ifce_key =
                        g_encoin_rev_comp_tbl(i).bom_inventory_comps_ifce_key
                THEN
                    g_encoin_sub_comp_tbl(k).revised_comp_tbl_index := i;
                END IF;
            END LOOP;
        END IF;
    END LOOP;
END ResolveIndexKeys;

PROCEDURE Clear_Global_Data_Structures
IS
BEGIN
   g_ECO_ifce_key := null;
   g_encoin_rev_item_tbl.DELETE;
   g_encoin_rev_comp_tbl.DELETE;
   g_encoin_sub_comp_tbl.DELETE;
   g_encoin_ref_des_tbl.DELETE;
   g_public_out_eco_rec := null;
   g_public_out_rev_tbl.DELETE;
   g_public_out_lines_tbl.DELETE;
   g_public_out_rev_item_tbl.DELETE;
   g_public_out_rev_comp_tbl.DELETE;
   g_public_out_sub_comp_tbl.DELETE;
   g_public_out_ref_des_tbl.DELETE;
   g_public_out_rev_operation_tbl.DELETE;
   g_public_out_rev_op_res_tbl.DELETE;
   g_public_out_rev_sub_res_tbl.DELETE;
   g_public_eco_rec := null;
   g_public_rev_tbl.DELETE;
   g_public_lines_tbl.DELETE;
   g_public_rev_item_tbl.DELETE;
   g_public_rev_comp_tbl.DELETE;
   g_public_sub_comp_tbl.DELETE;
   g_public_ref_des_tbl.DELETE;
   g_public_rev_operation_tbl.DELETE;
   g_public_rev_op_res_tbl.DELETE;
   g_public_rev_sub_res_tbl.DELETE;
   g_ECO_exists := FALSE;
   g_revised_items_exist := FALSE;
   g_revised_comps_exist := FALSE;
   g_ECO_ifce_group_tbl.DELETE;
   g_item_ifce_group_tbl.DELETE;
   g_comp_ifce_group_tbl.DELETE;
END Clear_Global_Data_Structures;

PROCEDURE Eng_Launch_Import (
    ERRBUF          OUT NOCOPY VARCHAR2,
    RETCODE         OUT NOCOPY NUMBER,
    p_org_id            NUMBER,
    p_all_org           NUMBER          := 1,
    p_del_rec_flag      NUMBER          := 1
) IS
    stmt_num                    NUMBER;
    l_prog_appid                NUMBER;
    l_prog_id                   NUMBER;
    l_request_id                NUMBER;
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_unexp_error               VARCHAR2(1000);
--    l_error_tbl                       ENG_Eco_PUB.Error_Tbl_Type;
    l_log_msg                   VARCHAR2(2000);
    l_err_text                  VARCHAR2(2000);

    l_top_ifce_key              VARCHAR2(240);

    i                           NUMBER := 0;
    j                           NUMBER := 0;
    k                           NUMBER := 0;
    m                           NUMBER := 0;
    n                           NUMBER := 0;
    p                           NUMBER := 0;
    q                           NUMBER := 0;
    r                           NUMBER := 0;
    s                           NUMBER := 0;
    t                           NUMBER := 0;
    u                           NUMBER := 0;
    v                           NUMBER := 0;
    w                           NUMBER := 0;
    x                           NUMBER := 0;
    y                           NUMBER := 0;
    z                           NUMBER := 0;

    import_error                EXCEPTION;


BEGIN

-- INITIALIZE GLOBALS
    --dbms_output.put_line('Start Launch');
    stmt_num := 1;
    l_prog_appid := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id    := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    l_user_id    := FND_GLOBAL.USER_ID;
    l_login_id   := FND_GLOBAL.LOGIN_ID;

    g_all_org := p_all_org;
    g_org_id := p_org_id;

   --dbms_output.put_line('Who record initiation');
   stmt_num := 2;
   ENG_GLOBALS.Init_Who_Rec(p_org_id => p_org_id,
                            p_user_id => l_user_id,
                            p_login_id => l_login_id,
                            p_prog_appid => l_prog_appid,
                            p_prog_id => l_prog_id,
                            p_req_id => l_request_id);
   --Bug 2818039
   ENG_GLOBALS.G_ENG_LAUNCH_IMPORT  := 1;

   Clear_Global_Data_Structures;

-- SET ORG IDS

   --dbms_output.put_line('Set org ids');
   stmt_num := 3;
   UPDATE eng_eng_changes_interface eeci
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = eeci.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = eeci.organization_code);

   stmt_num := 4;
   UPDATE eng_eco_revisions_interface eeri
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = eeri.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = eeri.organization_code);

   stmt_num := 5;
   UPDATE eng_revised_items_interface erii
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = erii.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = erii.organization_code);


   stmt_num := 6;
   UPDATE bom_inventory_comps_interface bici
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = bici.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update, G_Cancel)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND interface_entity_type = 'ECO'
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = bici.organization_code);

   stmt_num := 7;
   UPDATE bom_sub_comps_interface bsci
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = bsci.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND interface_entity_type = 'ECO'
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = bsci.organization_code);

   stmt_num := 8;
   UPDATE bom_ref_desgs_interface brdi
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = brdi.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND interface_entity_type = 'ECO'
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = brdi.organization_code);

   stmt_num := 8.1;
   UPDATE bom_op_sequences_interface bosi
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = bosi.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = bosi.organization_code);

   stmt_num := 8.2;
   UPDATE bom_op_resources_interface bori
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = bori.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = bori.organization_code);

   stmt_num := 8.3;
   UPDATE bom_sub_op_resources_interface bsori
      SET organization_id = (SELECT organization_id
                               FROM mtl_parameters mp1
                          WHERE mp1.organization_code = bsori.organization_code)
    WHERE process_flag = 1
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND (organization_id is null OR organization_id = FND_API.G_MISS_NUM)
      AND organization_code is not null
      AND exists (SELECT organization_code
                    FROM mtl_parameters mp2
                   WHERE mp2.organization_code = bsori.organization_code);
   stmt_num := 9;
   COMMIT;


-- SET TRANSACTION IDS

   --dbms_output.put_line('Set transaction ids');
   stmt_num := 10.1;
   UPDATE eng_eng_changes_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.2;
   UPDATE eng_eco_revisions_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.3;
   UPDATE eng_revised_items_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.4;
   UPDATE bom_inventory_comps_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND interface_entity_type = 'ECO'
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.5;
   UPDATE bom_sub_comps_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND interface_entity_type = 'ECO'
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.6;
   UPDATE bom_ref_desgs_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
          OR transaction_id = FND_API.G_MISS_NUM)
      AND interface_entity_type = 'ECO'
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.7;
   UPDATE bom_op_sequences_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.8;
   UPDATE bom_op_resources_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.9;
   UPDATE bom_sub_op_resources_interface
      SET transaction_id = mtl_system_items_interface_s.nextval,
          transaction_type = UPPER(transaction_type)
    WHERE process_flag = 1
      AND (transaction_id is NULL
           OR transaction_id = FND_API.G_MISS_NUM)
      AND (p_all_org = 1
           OR
           (p_all_org = 2 AND organization_id = p_org_id));

   stmt_num := 10.11;
   /*Added below code to fix the bug 27611947.
   If user provides any wrong Supply_location_id we are not throwing any error.
   Because supply_locator_id is a un-exposed record item. If user provides correct id then we will insert/update it.*/
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
	SET  location_name  = (SELECT concatenated_segments
						  FROM MTL_ITEM_LOCATIONS_KFV MIL1
						  WHERE MIL1.inventory_location_id = BICI.supply_locator_id
		and MIL1.organization_id = BICI.organization_id)
	WHERE process_flag = 1
	  AND change_notice is NOT null
	  AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
	  AND supply_locator_id is not null
	  AND organization_id is not null
	  AND exists (SELECT 'x'
					FROM MTL_ITEM_LOCATIONS mil2
					WHERE mil2.INVENTORY_LOCATION_ID = BICI.supply_locator_id
	and mil2.organization_id = BICI.organization_id);
   COMMIT;

-- **************************** ECO BUSINESS OBJECT ******************

   --dbms_output.put_line('After updates');

   stmt_num := 11;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
--   l_error_tbl.DELETE;

   stmt_num := 11.5;
   Clear_Global_Data_Structures;

   stmt_num := 12;

   -- Pick up ECO Header record

   FOR c1rec IN GetEco LOOP
        g_public_eco_rec.ORGANIZATION_HIERARCHY := c1rec.ORGANIZATION_HIERARCHY;
        -- Added Above line as fix to 4967902
        g_public_eco_rec.employee_number :=  c1rec.employee_number; --4402842
        g_public_eco_rec.attribute7 := c1rec.attribute7;
        g_public_eco_rec.attribute8 := c1rec.attribute8;
        g_public_eco_rec.attribute9 := c1rec.attribute9;
        g_public_eco_rec.attribute10 := c1rec.attribute10;
        g_public_eco_rec.attribute11 := c1rec.attribute11;
        g_public_eco_rec.attribute12 := c1rec.attribute12;
        g_public_eco_rec.attribute13 := c1rec.attribute13;
        g_public_eco_rec.attribute14 := c1rec.attribute14;
        g_public_eco_rec.attribute15 := c1rec.attribute15;
--              g_public_eco_rec.request_id := c1rec.request_id;
--              g_public_eco_rec.program_application_id := c1rec.program_application_id;
--              g_public_eco_rec.program_id := c1rec.program_id;
--              g_public_eco_rec.program_update_date := c1rec.program_update_date;
--              g_public_eco_rec.approval_status_type := c1rec.approval_status_type;
        g_public_eco_rec.approval_date := c1rec.approval_date;
--              g_public_eco_rec.approval_list_id := c1rec.approval_list_id;
--              g_public_eco_rec.change_order_type_id := c1rec.change_order_type_id;
--              g_public_eco_rec.responsible_org_id := c1rec.responsible_organization_id;
        g_public_eco_rec.approval_request_date := c1rec.approval_request_date;
        g_public_eco_rec.eco_name := c1rec.change_notice;
--              g_public_eco_rec.organization_id := c1rec.organization_id;
--      g_public_eco_rec.last_update_date := c1rec.last_update_date;
--              g_public_eco_rec.last_updated_by := c1rec.last_updated_by;
--              g_public_eco_rec.creation_date := c1rec.creation_date;
--              g_public_eco_rec.created_by := c1rec.created_by;
--              g_public_eco_rec.last_update_login := c1rec.last_update_login;
        g_public_eco_rec.description := c1rec.description;
--              g_public_eco_rec.status_type := c1rec.status_type;
--              g_public_eco_rec.initiation_date := c1rec.initiation_date;
--              g_public_eco_rec.implementation_date := c1rec.implementation_date;
--              g_public_eco_rec.cancellation_date := c1rec.cancellation_date;
        g_public_eco_rec.cancellation_comments := c1rec.cancellation_comments;
        g_public_eco_rec.priority_code := c1rec.priority_code;
        g_public_eco_rec.reason_code := c1rec.reason_code;
--              g_public_eco_rec.estimated_eng_cost := c1rec.estimated_eng_cost;
--              g_public_eco_rec.estimated_mfg_cost := c1rec.estimated_mfg_cost;
--              g_public_eco_rec.requestor_id := c1rec.requestor_id;
        g_public_eco_rec.attribute_category := c1rec.attribute_category;
        g_public_eco_rec.attribute1 := c1rec.attribute1;
        g_public_eco_rec.attribute2 := c1rec.attribute2;
        g_public_eco_rec.attribute3 := c1rec.attribute3;
        g_public_eco_rec.attribute4 := c1rec.attribute4;
        g_public_eco_rec.attribute5 := c1rec.attribute5;
        g_public_eco_rec.attribute6 := c1rec.attribute6;
--              g_public_eco_rec.process_flag := c1rec.process_flag;
        g_public_eco_rec.requestor := c1rec.requestor_user_name;
        g_public_eco_rec.assignee := c1rec.assignee_name;
        g_public_eco_rec.transaction_id := c1rec.transaction_id;
        g_public_eco_rec.APPROVAL_LIST_NAME := c1rec.APPROVAL_LIST_NAME;
        g_public_eco_rec.CHANGE_TYPE_CODE := c1rec.CHANGE_ORDER_TYPE;
        g_public_eco_rec.CHANGE_MANAGEMENT_TYPE := c1rec.CHANGE_MGMT_TYPE_NAME;
        g_public_eco_rec.ORGANIZATION_CODE := c1rec.ORGANIZATION_CODE;
        g_public_eco_rec.project_name := c1rec.project_name;
        g_public_eco_rec.task_number := c1rec.task_number;
--              g_public_eco_rec.RESPONSIBLE_ORG_CODE := c1rec.RESPONSIBLE_ORG_CODE;
        g_public_eco_rec.transaction_type := c1rec.transaction_type;
        g_ECO_ifce_key := c1rec.eng_changes_ifce_key;
        --Bug 2908248
        g_public_eco_rec.status_name := c1rec.status_name;
        g_public_eco_rec.Approval_status_name := c1rec.Approval_status_name; --Bug 3587304
        -- Bug 2919076 // kamohan
        -- Start Changes

        g_public_eco_rec.change_name := c1rec.change_name;

        -- Bug 2919076 // kamohan
        -- End Changes

        --11.5.10 Changes

        g_public_eco_rec.pk1_name           :=c1rec.pk1_name      ;
        g_public_eco_rec.pk2_name           :=c1rec.pk2_name      ;
        g_public_eco_rec.pk3_name           :=c1rec.pk3_name      ;
        g_public_eco_rec.plm_or_erp_change :=c1rec.plm_or_erp_change;
        if c1rec.plm_or_erp_change is null or c1rec.plm_or_erp_change = FND_API.G_MISS_CHAR then
          g_public_eco_rec.plm_or_erp_change :='ERP';
        end if;
        --11.5.10 Changes
        --For PLM change_name is mandatory
        if c1rec.change_name IS NULL or c1rec.change_name = FND_API.G_MISS_CHAR
        then
           g_public_eco_rec.change_name := c1rec.change_notice;
        end if;

        g_public_eco_rec.Source_Type := c1rec.source_type_name;
        g_public_eco_rec.Source_Name := c1rec.source_name;
        g_public_eco_rec.Need_By_Date := c1rec.need_by_date;
        g_public_eco_rec.Eco_Department_Name := c1rec.eco_department_name;

      -------------
      --
      -- ECO Header exists, but it doesn't have an IFCE key entry
      --

      stmt_num := 13;

      IF g_ECO_ifce_key IS NULL
      THEN
         g_ECO_exists := TRUE;
         --dbms_output.put_line('No ifce key - Call Public API for ECO record');

		 /* Bug 29557563 changes - Removed hard code path reference for parameter p_output_dir since
		     we are passing 'N' for p_debug. Also modified p_debug_filename to pass NULL.
			 Modified these changes in all places where ever we are referring hard code path. */

         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => g_public_eco_rec,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                         --x_err_text           => l_err_text,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 14;

         Eng_Globals.Clear_Request_Table;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 15;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 16;
            ROLLBACK;
            RETCODE := G_ERROR;   /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 17;
            ROLLBACK;
            stmt_num := 18;
            RAISE import_error;
         END IF;

         stmt_num := 19;
         Update_Interface_Tables(l_return_status);
         stmt_num := 20;
         COMMIT;

       -------------
       --
       -- ECO Header exists and g_ECO_ifce_key is not null
       --

       ELSIF g_ECO_ifce_key IS NOT NULL
       THEN
         stmt_num := 24;
         g_ECO_exists := TRUE;
         l_top_ifce_key := g_ECO_ifce_key;
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;

         -- Pick up all ECO revisions with ECO ifce key = g_ECO_ifce_key

         stmt_num := 25;
         Get_Revs_With_Curr_ECO_ifce;

         -- Pick up all revised items with ECO ifce key = g_ECO_ifce_key

         stmt_num := 26;
         Get_Items_With_Curr_ECO_ifce;
         stmt_num := 26.5;
         IF g_encoin_rev_item_tbl.count <> 0
         THEN
            stmt_num := 27;
            g_revised_items_exist := TRUE;
         END IF;

         -- Pick up all revised components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 28;
         Get_Comps_With_Curr_ECO_Ifce;
         stmt_num := 28.5;
         IF g_encoin_rev_comp_tbl.count <> 0
         THEN
           stmt_num := 29;
           g_revised_comp_ifce_key := null;
           g_revised_comps_exist := TRUE;
         END IF;

         -- Pick up all reference designators with ECO ifce key = g_ECO_ifce_key

         stmt_num := 30;
         Get_Rfds_With_Curr_ECO_Ifce;

         -- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 31;
         Get_Sbcs_With_Curr_ECO_Ifce;

        -- load change lines from interface table
        Get_Lines_With_Curr_ECO_Ifce;

        -- load revised operations from interface table
        Get_Rev_Op_With_Curr_ECO_Ifce;
        -- load revised operation resources from interface table
        Get_Op_Res_With_Curr_ECO_Ifce;
        -- load revised operation substitute resources from interface table
        Get_Sub_Op_Res_With_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 32;
         ResolveIndexKeys;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 34;
         Move_Encoin_Struct_To_Public;

         -- Call Public API

         stmt_num := 35;
         --dbms_output.put_line('ifce key exists - Call Public API for ECO entity');

         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        p_ECO_rec               => g_public_eco_rec,
                        p_eco_revision_tbl      => g_public_rev_tbl,
            p_change_line_tbl   => g_public_lines_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        p_rev_operation_tbl        => g_public_rev_operation_tbl,
                        p_rev_op_resource_tbl      => g_public_rev_op_res_tbl,
                        p_rev_sub_resource_tbl     => g_public_rev_sub_res_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
            x_change_line_tbl   => g_public_out_lines_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl,
                        x_rev_operation_tbl        => g_public_out_rev_operation_tbl,
                        x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl,
                        x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl,
            p_debug                 => 'N',
            p_debug_filename        => '',
            p_output_dir            => ''
            );

         stmt_num := 36;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 37;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 38;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 46;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 55;
            ROLLBACK;
            stmt_num := 56;
            RAISE import_error;
         END IF;

         stmt_num := 57;
         Update_Interface_Tables(l_return_status);
         stmt_num := 58;
         COMMIT;

       END IF;

      stmt_num := 65;
      Clear_Global_Data_Structures;
      l_return_status := null;
      l_msg_count := null;
      l_msg_data := null;

   END LOOP; -- End ECO Header Object loop

   -------------
   --
   -- ECO Header does not exist, i.e., no more ECO Headers exist in interface table
   --

   IF NOT g_ECO_exists
   THEN

      -- Group revised item ECO ifce keys

      stmt_num := 66;
      k := 0;
      FOR c1rec IN GetItemWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      stmt_num := 67;
      g_ECO_ifce_key := null;

      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 68;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all items with ECO ifce key = g_ECO_ifce_key

         stmt_num := 69;
         Get_Items_With_Curr_ECO_ifce;
         stmt_num := 69.1;
         IF g_encoin_rev_item_tbl.count <> 0
         THEN
            stmt_num := 69.5;
            g_revised_items_exist := TRUE;
         END IF;

         -- Pick up all ECO revisions with ECO ifce key = g_ECO_ifce_key

         stmt_num := 70;
         Get_Revs_With_Curr_ECO_ifce;

         -- Pick up all revised components with ECO ifce key = g_ECO_ifce_key

        stmt_num := 71;
        Get_Comps_With_Curr_ECO_ifce;
        stmt_num := 71.5;
        IF g_encoin_rev_comp_tbl.count <> 0
        THEN
           stmt_num := 17;
           g_revised_comps_exist := TRUE;
         END IF;

         -- Pick up all reference designators with ECO ifce key = g_ECO_ifce_key

         stmt_num := 72;
         Get_Rfds_With_Curr_ECO_Ifce;

         -- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 73;
         Get_Sbcs_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 74;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 75;
         IF g_public_rev_tbl.count = 0 AND g_encoin_rev_item_tbl.count =0 AND g_encoin_rev_comp_tbl.count =0 AND
            g_encoin_ref_des_tbl.count = 0 AND g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 76;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 77;
         --dbms_output.put_line('No ECO Headers - Call Public API with items starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
            );

         stmt_num := 78;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 79;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 80;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 81;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 82;
            ROLLBACK;
            stmt_num := 83;
            RAISE import_error;
         END IF;

         stmt_num := 84;
         Update_Interface_Tables(l_return_status);
         stmt_num := 85;
         COMMIT;

      END LOOP;

      -- Group revisions ECO ifce keys

      stmt_num := 105;
      k := 0;
      FOR c1rec IN GetRevWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 106;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 107;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all ECO revisions with ECO ifce key = g_ECO_ifce_key

         stmt_num := 108;
         Get_Revs_With_Curr_ECO_ifce;

         -- Pick up all revised components with ECO ifce key = g_ECO_ifce_key

        stmt_num := 109;
        Get_Comps_With_Curr_ECO_ifce;
        stmt_num := 109.1;
        IF g_encoin_rev_comp_tbl.count <> 0
        THEN
           stmt_num := 109.5;
           g_revised_comps_exist := TRUE;
         END IF;

         -- Pick up all reference designators with ECO ifce key = g_ECO_ifce_key

         stmt_num := 110;
         Get_Rfds_With_Curr_ECO_Ifce;

         -- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 111;
         Get_Sbcs_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 112;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 113;
         IF g_public_rev_tbl.count = 0 AND g_encoin_rev_comp_tbl.count =0 AND
            g_encoin_ref_des_tbl.count = 0 AND g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 114;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 115;
         --dbms_output.put_line('No ECO Headers - Call Public API with revs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text --,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 116;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 117;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 118;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 119;
            ROLLBACK;
            RETCODE := G_ERROR; /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 120;
            ROLLBACK;
            stmt_num := 121;
            RAISE import_error;
         END IF;

         stmt_num := 122;
         Update_Interface_Tables(l_return_status);
         stmt_num := 123;
         COMMIT;
      END LOOP;

      -- Group component ECO ifce keys

      stmt_num := 140;
      k := 0;
      FOR c1rec IN GetCompWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
         --dbms_output.put_line('found same');
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 141;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 142;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all revised components with ECO ifce key = g_ECO_ifce_key

        stmt_num := 143;
        Get_Comps_With_Curr_ECO_ifce;
        stmt_num := 144;
        IF g_encoin_rev_comp_tbl.count <> 0
        THEN
           stmt_num := 145;
           g_revised_comps_exist := TRUE;
         END IF;

         -- Pick up all reference designators with ECO ifce key = g_ECO_ifce_key

         stmt_num := 146;
         Get_Rfds_With_Curr_ECO_Ifce;

         -- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 147;
         Get_Sbcs_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 148;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 149;
         IF g_encoin_rev_comp_tbl.count =0 AND g_encoin_ref_des_tbl.count = 0 AND
            g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 150;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 151;
         --dbms_output.put_line('No ECO Headers - Call Public API with comps starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text  --,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 152;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 153;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 154;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 155;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 156;
            ROLLBACK;
            stmt_num := 157;
            RAISE import_error;
         END IF;

         stmt_num := 158;
         Update_Interface_Tables(l_return_status);
         stmt_num := 159;
         COMMIT;
      END LOOP;

      -- Group ref des ECO ifce keys

      stmt_num := 173;
      k := 0;
      FOR c1rec IN GetRfdWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 174;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 175;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all reference designators with ECO ifce key = g_ECO_ifce_key

         stmt_num := 176;
         Get_Rfds_With_Curr_ECO_Ifce;

         -- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 177;
         Get_Sbcs_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 178;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 179;
         IF g_encoin_ref_des_tbl.count = 0 AND g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 180;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 181;
         --dbms_output.put_line('No ECO Headers - Call Public API with desgs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text --,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 182;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 183;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 184;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 185;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 186;
            ROLLBACK;
            stmt_num := 187;
            RAISE import_error;
         END IF;

         stmt_num := 188;
         Update_Interface_Tables(l_return_status);
         stmt_num := 189;
         COMMIT;

      END LOOP;

      -- Group sub comp ECO ifce keys

      stmt_num := 200;
      k := 0;
      FOR c1rec IN GetSbcWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 201;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 202;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all substitute components with ECO ifce key = g_ECO_ifce_key

         stmt_num := 203;
         Get_Sbcs_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 204;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 205;
         IF g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 206;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 207;
         --dbms_output.put_line('No ECO Headers - Call Public API with sbcs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text --,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 208;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 209;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 210;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 211;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 212;
            ROLLBACK;
            stmt_num := 213;
            RAISE import_error;
         END IF;

         stmt_num := 214;
         Update_Interface_Tables(l_return_status);
         stmt_num := 215;
         COMMIT;

      END LOOP;
   END IF;


-- ** revised operations **

      stmt_num := 173;
      k := 0;
      FOR c1rec IN GetRevOpWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 174;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 175;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all operation resources with ECO ifce key = g_ECO_ifce_key

         stmt_num := 176;
         Get_Rev_Op_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 178;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 179;
         IF g_public_rev_operation_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 181;
         --dbms_output.put_line('No ECO Headers - Call Public API with desgs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        p_ECO_rec               => g_public_eco_rec,
                        p_eco_revision_tbl      => g_public_rev_tbl,
            p_change_line_tbl   => g_public_lines_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        p_rev_operation_tbl        => g_public_rev_operation_tbl,
                        p_rev_op_resource_tbl      => g_public_rev_op_res_tbl,
                        p_rev_sub_resource_tbl     => g_public_rev_sub_res_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
            x_change_line_tbl   => g_public_out_lines_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl,
                        x_rev_operation_tbl        => g_public_out_rev_operation_tbl,
                        x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl,
                        x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl,
            p_debug                 => 'N',
            p_debug_filename        => '',
            p_output_dir            => ''
            );

         stmt_num := 182;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 183;

         stmt_num := 184;
         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 185;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 189;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 194;
            ROLLBACK;
            RAISE import_error;
         END IF;

         stmt_num := 195;
         Update_Interface_Tables(l_return_status);
         stmt_num := 196;
         COMMIT;

      END LOOP;

-- ** revised resources **

      -- Group ref des ECO ifce keys

      stmt_num := 173;
      k := 0;
      FOR c1rec IN GetRevResWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 174;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 175;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all operation resources with ECO ifce key = g_ECO_ifce_key

         stmt_num := 176;
         Get_Op_Res_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 178;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 179;
         IF g_public_rev_op_res_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 181;
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        p_ECO_rec               => g_public_eco_rec,
                        p_eco_revision_tbl      => g_public_rev_tbl,
            p_change_line_tbl   => g_public_lines_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        p_rev_operation_tbl        => g_public_rev_operation_tbl,
                        p_rev_op_resource_tbl      => g_public_rev_op_res_tbl,
                        p_rev_sub_resource_tbl     => g_public_rev_sub_res_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
            x_change_line_tbl   => g_public_out_lines_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl,
                        x_rev_operation_tbl        => g_public_out_rev_operation_tbl,
                        x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl,
                        x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl,
            p_debug                 => 'N',
            p_debug_filename        => '',
            p_output_dir            => ''
            );

         stmt_num := 182;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 183;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 185;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 189;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 194;
            ROLLBACK;
            RAISE import_error;
         END IF;

         stmt_num := 195;
         Update_Interface_Tables(l_return_status);
         stmt_num := 196;
         COMMIT;

      END LOOP;



-- ** change lines **

      -- change lines ECO ifce keys

      stmt_num := 173;
      k := 0;
      FOR c1rec IN GetLinesWithSameECOifce LOOP
         k := k + 1;
         g_ECO_ifce_group_tbl(k) := c1rec.eco_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;

      stmt_num := 174;
      FOR i IN 1..g_ECO_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 175;
         g_encoin_rev_item_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_ECO_ifce_key := g_ECO_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_item_ifce_key := null;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all operation resources with ECO ifce key = g_ECO_ifce_key

         stmt_num := 176;
         Get_Lines_With_Curr_ECO_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 178;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 179;
         IF g_public_lines_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         l_top_ifce_key := g_ECO_ifce_key;

         -- Call Public API

         stmt_num := 181;
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        p_ECO_rec               => g_public_eco_rec,
                        p_eco_revision_tbl      => g_public_rev_tbl,
            p_change_line_tbl   => g_public_lines_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        p_rev_operation_tbl        => g_public_rev_operation_tbl,
                        p_rev_op_resource_tbl      => g_public_rev_op_res_tbl,
                        p_rev_sub_resource_tbl     => g_public_rev_sub_res_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
            x_change_line_tbl   => g_public_out_lines_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl,
                        x_rev_operation_tbl        => g_public_out_rev_operation_tbl,
                        x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl,
                        x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl,
            p_debug                 => 'N',
            p_debug_filename        => '',
            p_output_dir            => ''
            );

         stmt_num := 182;
         Eng_Globals.Clear_Request_Table;

         stmt_num := 184;
         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 185;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 189;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 194;
            ROLLBACK;
            RAISE import_error;
         END IF;

         stmt_num := 195;
         Update_Interface_Tables(l_return_status);
         stmt_num := 196;
         COMMIT;

      END LOOP;


-- *************************** REVISION BUSINESS OBJECT **************************

   q := 0;

   stmt_num := 223;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
   --l_error_tbl.DELETE;

   stmt_num := 223.5;
   Clear_Global_Data_Structures;

   FOR c7rec IN GetRev LOOP
         stmt_num := 224;
         q := q + 1;
         g_public_rev_tbl(q).attribute11 := c7rec.attribute11;
         g_public_rev_tbl(q).attribute12 := c7rec.attribute12;
         g_public_rev_tbl(q).attribute13 := c7rec.attribute13;
         g_public_rev_tbl(q).attribute14 := c7rec.attribute14;
         g_public_rev_tbl(q).attribute15 := c7rec.attribute15;
--         g_public_rev_tbl(q).program_application_id := c7rec.program_application_id;
--         g_public_rev_tbl(q).program_id := c7rec.program_id;
--         g_public_rev_tbl(q).program_update_date := c7rec.program_update_date;
--         g_public_rev_tbl(q).request_id := c7rec.request_id;
--         g_public_rev_tbl(q).revision_id := c7rec.revision_id;
         g_public_rev_tbl(q).eco_name := c7rec.change_notice;
--         g_public_rev_tbl(q).organization_id := c7rec.organization_id;
         g_public_rev_tbl(q).revision := c7rec.revision;
--         g_public_rev_tbl(q).last_update_date := c7rec.last_update_date;
--         g_public_rev_tbl(q).last_updated_by := c7rec.last_updated_by;
--         g_public_rev_tbl(q).creation_date := c7rec.creation_date;
--         g_public_rev_tbl(q).created_by := c7rec.created_by;
--         g_public_rev_tbl(q).last_update_login := c7rec.last_update_login;
         g_public_rev_tbl(q).comments := c7rec.comments;
         g_public_rev_tbl(q).attribute_category := c7rec.attribute_category;
         g_public_rev_tbl(q).attribute1 := c7rec.attribute1;
         g_public_rev_tbl(q).attribute2 := c7rec.attribute2;
         g_public_rev_tbl(q).attribute3 := c7rec.attribute3;
         g_public_rev_tbl(q).attribute4 := c7rec.attribute4;
         g_public_rev_tbl(q).attribute5 := c7rec.attribute5;
         g_public_rev_tbl(q).attribute6 := c7rec.attribute6;
         g_public_rev_tbl(q).attribute7 := c7rec.attribute7;
         g_public_rev_tbl(q).attribute8 := c7rec.attribute8;
         g_public_rev_tbl(q).attribute9 := c7rec.attribute9;
         g_public_rev_tbl(q).attribute10 := c7rec.attribute10;
         g_public_rev_tbl(q).new_revision := c7rec.new_revision;
         g_public_rev_tbl(q).organization_code := c7rec.organization_code;
--         g_public_rev_tbl(q).process_flag := c7rec.process_flag;
         g_public_rev_tbl(q).transaction_id := c7rec.transaction_id;
         g_public_rev_tbl(q).transaction_type := c7rec.transaction_type;

         stmt_num := 226;
         --dbms_output.put_line('Call Public API for revision record');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

            Eng_Globals.Clear_Request_Table;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 230;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 231;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 232;
            ROLLBACK;
            stmt_num := 233;
            RAISE import_error;
         END IF;

         stmt_num := 234;
         Update_Interface_Tables(l_return_status);
         stmt_num := 235;
         COMMIT;

        stmt_num := 239;
        Clear_Global_Data_Structures;

   END LOOP;    -- END ECO REV LOOP


-- *************************** REVISED ITEM BUSINESS OBJECT **************************

   r := 0;

   stmt_num := 240;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
   --l_error_tbl.DELETE;

   stmt_num := 240.5;
   Clear_Global_Data_Structures;

  stmt_num := 241;
  FOR c8rec IN GetItem LOOP

      -- Pick up one revised item record

      stmt_num := 242;
      r := r + 1;
      g_encoin_rev_item_tbl(r).change_notice := c8rec.change_notice;
      g_encoin_rev_item_tbl(r).organization_id := c8rec.organization_id;
      g_encoin_rev_item_tbl(r).revised_item_id := c8rec.revised_item_id;
      g_encoin_rev_item_tbl(r).last_update_date := c8rec.last_update_date;
      g_encoin_rev_item_tbl(r).last_updated_by := c8rec.last_updated_by;
      g_encoin_rev_item_tbl(r).creation_date := c8rec.creation_date;
      g_encoin_rev_item_tbl(r).created_by := c8rec.created_by;
      g_encoin_rev_item_tbl(r).last_update_login := c8rec.last_update_login;
      g_encoin_rev_item_tbl(r).implementation_date := c8rec.implementation_date;
      g_encoin_rev_item_tbl(r).cancellation_date := c8rec.cancellation_date;
      g_encoin_rev_item_tbl(r).cancel_comments := c8rec.cancel_comments;
      g_encoin_rev_item_tbl(r).disposition_type := c8rec.disposition_type;
      g_encoin_rev_item_tbl(r).new_item_revision := c8rec.new_item_revision;
      g_encoin_rev_item_tbl(r).early_schedule_date := c8rec.early_schedule_date;
      g_encoin_rev_item_tbl(r).attribute_category := c8rec.attribute_category;
      g_encoin_rev_item_tbl(r).attribute2 := c8rec.attribute2;
      g_encoin_rev_item_tbl(r).attribute3 := c8rec.attribute3;
      g_encoin_rev_item_tbl(r).attribute4 := c8rec.attribute4;
      g_encoin_rev_item_tbl(r).attribute5 := c8rec.attribute5;
      g_encoin_rev_item_tbl(r).attribute7 := c8rec.attribute7;
      g_encoin_rev_item_tbl(r).attribute8 := c8rec.attribute8;
      g_encoin_rev_item_tbl(r).attribute9 := c8rec.attribute9;
      g_encoin_rev_item_tbl(r).attribute11 := c8rec.attribute11;
      g_encoin_rev_item_tbl(r).attribute12 := c8rec.attribute12;
      g_encoin_rev_item_tbl(r).attribute13 := c8rec.attribute13;
      g_encoin_rev_item_tbl(r).attribute14 := c8rec.attribute14;
      g_encoin_rev_item_tbl(r).attribute15 := c8rec.attribute15;
      g_encoin_rev_item_tbl(r).status_type := c8rec.status_type;
      g_encoin_rev_item_tbl(r).scheduled_date := c8rec.scheduled_date;
      g_encoin_rev_item_tbl(r).bill_sequence_id := c8rec.bill_sequence_id;
      g_encoin_rev_item_tbl(r).mrp_active := c8rec.mrp_active;
      g_encoin_rev_item_tbl(r).request_id := c8rec.request_id;
      g_encoin_rev_item_tbl(r).program_application_id := c8rec.program_application_id;
      g_encoin_rev_item_tbl(r).program_id := c8rec.program_id;
      g_encoin_rev_item_tbl(r).program_update_date := c8rec.program_update_date;
      g_encoin_rev_item_tbl(r).update_wip := c8rec.update_wip;
      g_encoin_rev_item_tbl(r).use_up := c8rec.use_up;
      g_encoin_rev_item_tbl(r).use_up_item_id := c8rec.use_up_item_id;
      g_encoin_rev_item_tbl(r).revised_item_sequence_id := c8rec.revised_item_sequence_id;
      g_encoin_rev_item_tbl(r).use_up_plan_name := c8rec.use_up_plan_name;
      g_encoin_rev_item_tbl(r).descriptive_text := c8rec.descriptive_text;
      g_encoin_rev_item_tbl(r).auto_implement_date := c8rec.auto_implement_date;
      g_encoin_rev_item_tbl(r).attribute1 := c8rec.attribute1;
      g_encoin_rev_item_tbl(r).attribute6 := c8rec.attribute6;
      g_encoin_rev_item_tbl(r).attribute10 := c8rec.attribute10;
      g_encoin_rev_item_tbl(r).requestor_id := c8rec.requestor_id;
      g_encoin_rev_item_tbl(r).comments := c8rec.comments;
      g_encoin_rev_item_tbl(r).process_flag := c8rec.process_flag;
      g_encoin_rev_item_tbl(r).transaction_id := c8rec.transaction_id;
      g_encoin_rev_item_tbl(r).organization_code := c8rec.organization_code;
      g_encoin_rev_item_tbl(r).revised_item_number := c8rec.revised_item_number;
      g_encoin_rev_item_tbl(r).new_rtg_revision := c8rec.new_rtg_revision;
      g_encoin_rev_item_tbl(r).use_up_item_number := c8rec.use_up_item_number;
      g_encoin_rev_item_tbl(r).alternate_bom_designator := c8rec.alternate_bom_designator;
      g_encoin_rev_item_tbl(r).operation := c8rec.transaction_type;
      g_encoin_rev_item_tbl(r).ENG_REVISED_ITEMS_IFCE_KEY := c8rec.ENG_REVISED_ITEMS_IFCE_KEY;
      g_revised_item_ifce_key := g_encoin_rev_item_tbl(r).ENG_REVISED_ITEMS_IFCE_KEY;
      g_encoin_rev_item_tbl(r).parent_revised_item_name := c8rec.parent_revised_item_name;
      g_encoin_rev_item_tbl(r).parent_alternate_name := c8rec.parent_alternate_name;
      g_encoin_rev_item_tbl(r).updated_item_revision := c8rec.updated_item_revision; -- Bug 3432944
      g_encoin_rev_item_tbl(r).New_scheduled_date := c8rec.New_scheduled_date; -- Bug 3432944
      g_encoin_rev_item_tbl(r).from_item_revision := c8rec.from_item_revision; -- 11.5.10E
      g_encoin_rev_item_tbl(r).new_revision_label := c8rec.new_revision_label;
      g_encoin_rev_item_tbl(r).New_Revised_Item_Rev_Desc := c8rec.New_Revised_Item_Rev_Desc;
      g_encoin_rev_item_tbl(r).new_revision_reason := c8rec.new_revision_reason;
      g_encoin_rev_item_tbl(r).from_end_item_unit_number := c8rec.from_end_item_unit_number; /*Bug 6377841*/
      -------------
      --
      -- Revised item exists, but it doesn't have an IFCE key entry
      --

      stmt_num := 243;
      IF g_revised_item_ifce_key IS NULL
      THEN
         g_revised_items_exist := TRUE;
         --dbms_output.put_line('No ifce key - Call Public API for item');

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 244;
         Move_Encoin_Struct_To_Public;

         stmt_num := 245;
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 245;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 246;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 250;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 251;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 252;
            ROLLBACK;
            stmt_num := 253;
            RAISE import_error;
         END IF;

         stmt_num := 254;
         Update_Interface_Tables(l_return_status);
         stmt_num := 255;
         COMMIT;

       -------------
       --
       -- Revised item exists and g_revised_item_ifce_key is not null
       --

       stmt_num := 258;
       ELSIF g_revised_item_ifce_key IS NOT NULL
       THEN
         stmt_num := 259;
         g_revised_items_exist := TRUE;
         l_top_ifce_key := g_revised_item_ifce_key;
         g_revised_comps_exist := FALSE;

         -- Pick up revised components with revised item ifce key = g_revised_item_ifce_key

         stmt_num := 260;
         Get_Comps_With_Curr_Item_Ifce;

         stmt_num := 261;
         IF g_encoin_rev_comp_tbl.count <> 0
         THEN
           stmt_num := 262;
           g_revised_comp_ifce_key := null;
           g_revised_comps_exist := TRUE;
         END IF;

         -- Pick up ref designators with revised item ifce key = g_revised_item_ifce_key

         stmt_num := 263;
         Get_Rfds_With_Curr_Item_Ifce;

         -- Pick up sub components with revised item ifce key = g_revised_item_ifce_key

         stmt_num := 264;
         Get_Sbcs_With_Curr_Item_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 265;
         ResolveIndexKeys;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 266;
         Move_Encoin_Struct_To_Public;

         -- Call Public API

         stmt_num := 267;
         --dbms_output.put_line('Ifce key exists - Call Public API for item');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 268;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 269;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 270;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 271;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 272;
            ROLLBACK;
            stmt_num := 273;
            RAISE import_error;
         END IF;

         stmt_num := 274;
         Update_Interface_Tables(l_return_status);
         stmt_num := 275;
         COMMIT;

       END IF;

      stmt_num := 291;
      l_return_status := null;
      l_msg_count := null;
      l_msg_data := null;
      --l_error_tbl.DELETE;

      stmt_num := 291.5;
      Clear_Global_Data_Structures;

      r := 0;

   END LOOP; -- End Revised Item Object loop

   -------------
   --
   -- Revised item does not exist, i.e., no more revised item exist in interface table
   --

   stmt_num := 292;
   IF NOT g_revised_items_exist
   THEN

      -- Group component rev item ifce keys

      stmt_num := 293;
      k := 0;
      FOR c1rec IN GetCompWithSameItemifce LOOP
         k := k + 1;
         g_item_ifce_group_tbl(k) := c1rec.item_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;
      g_revised_item_ifce_key := null;

      stmt_num := 294;
      FOR i IN 1..g_item_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 295;
         g_encoin_rev_item_tbl.delete;
         g_public_rev_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;

         g_revised_item_ifce_key := g_item_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all revised components with item ifce key = g_revised_item_ifce_key

        stmt_num := 296;
        Get_Comps_With_Curr_Item_ifce;
        stmt_num := 297;
        IF g_encoin_rev_comp_tbl.count <> 0
        THEN
           stmt_num := 298;
           g_revised_comps_exist := TRUE;
         END IF;

         -- Pick up all reference designators with item ifce key = g_revised_item_ifce_key

         stmt_num := 299;
         Get_Rfds_With_Curr_Item_Ifce;

         -- Pick up all substitute components with item ifce key = g_revised_item_ifce_key

         stmt_num := 300;
         Get_Sbcs_With_Curr_Item_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 301;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 302;
         IF g_encoin_rev_comp_tbl.count =0 AND g_encoin_ref_des_tbl.count = 0 AND
            g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         l_top_ifce_key := g_revised_item_ifce_key;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 303;
         Move_Encoin_Struct_To_Public;

         -- Call Public API

         stmt_num := 304;
         --dbms_output.put_line('No Items - Call Public API with comps starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 305;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 306;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 310;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 311;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 312;
            ROLLBACK;
            stmt_num := 313;
            RAISE import_error;
         END IF;

         stmt_num := 314;
         Update_Interface_Tables(l_return_status);
         stmt_num := 315;
         COMMIT;

      END LOOP;

      -- Group ref desgs rev item ifce keys

      stmt_num := 326;
      k := 0;
      FOR c1rec IN GetRfdWithSameItemifce LOOP
         k := k + 1;
         g_item_ifce_group_tbl(k) := c1rec.item_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;
      g_revised_item_ifce_key := null;

      stmt_num := 327;
      FOR i IN 1..g_item_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 328;
         g_encoin_rev_item_tbl.delete;
         g_public_rev_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_revised_item_ifce_key := g_item_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all reference designators with item ifce key = g_revised_item_ifce_key

         stmt_num := 329;
         Get_Rfds_With_Curr_Item_Ifce;

         -- Pick up all substitute components with item ifce key = g_revised_item_ifce_key

         stmt_num := 330;
         Get_Sbcs_With_Curr_Item_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 331;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 332;
         IF g_encoin_ref_des_tbl.count = 0 AND g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 333;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_revised_item_ifce_key;

         -- Call Public API

         stmt_num := 334;
         --dbms_output.put_line('No Items - Call Public API with desgs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 335;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 336;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 340;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 341;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 342;
            ROLLBACK;
            stmt_num := 343;
            RAISE import_error;
         END IF;

         stmt_num := 344;
         Update_Interface_Tables(l_return_status);
         stmt_num := 345;
         COMMIT;

      END LOOP;

      -- Group sub comps rev item ifce keys

      stmt_num := 353;
      k := 0;
      FOR c1rec IN GetSbcWithSameItemifce LOOP
         k := k + 1;
         g_item_ifce_group_tbl(k) := c1rec.item_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;
      g_revised_item_ifce_key := null;

      stmt_num := 354;
      FOR i IN 1..g_item_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 355;
         g_encoin_rev_item_tbl.delete;
         g_public_rev_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_revised_item_ifce_key := g_item_ifce_group_tbl(i);
         g_revised_items_exist := FALSE;
         g_revised_comps_exist := FALSE;
         g_revised_comp_ifce_key := null;

         -- Pick up all substitute components with item ifce key = g_revised_item_ifce_key

         stmt_num := 356;
         Get_Sbcs_With_Curr_Item_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 357;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 358;
         IF g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 359;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_revised_item_ifce_key;

         -- Call Public API

         stmt_num := 360;
         --dbms_output.put_line('No Items - Call Public API with sbcs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 361;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 362;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 370;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 371;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 372;
            ROLLBACK;
            stmt_num := 373;
            RAISE import_error;
         END IF;

         stmt_num := 374;
         Update_Interface_Tables(l_return_status);
         stmt_num := 375;
         COMMIT;

      END LOOP;
   END IF;

-- ********************* REVISED COMPONENT BUSINESS OBJECT ***********************

   v := 0;

   stmt_num := 376;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
   --l_error_tbl.DELETE;

   stmt_num := 376.5;
   Clear_Global_Data_Structures;

   FOR c12rec IN GetComp LOOP

      -- Pick up one revised component record

      stmt_num := 378;
      v := v + 1;
      g_encoin_rev_comp_tbl(v).supply_subinventory := c12rec.supply_subinventory;
      g_encoin_rev_comp_tbl(v).OP_LEAD_TIME_PERCENT := c12rec.OPERATION_LEAD_TIME_PERCENT;
      g_encoin_rev_comp_tbl(v).revised_item_number := c12rec.revised_item_number; --added for OM ER 9946990
      g_encoin_rev_comp_tbl(v).revised_item_sequence_id := c12rec.revised_item_sequence_id;
      g_encoin_rev_comp_tbl(v).cost_factor := c12rec.cost_factor;
      g_encoin_rev_comp_tbl(v).required_for_revenue := c12rec.required_for_revenue;
      g_encoin_rev_comp_tbl(v).high_quantity := c12rec.high_quantity;
      g_encoin_rev_comp_tbl(v).component_sequence_id := c12rec.component_sequence_id;
      g_encoin_rev_comp_tbl(v).program_application_id := c12rec.program_application_id;
      g_encoin_rev_comp_tbl(v).wip_supply_type := c12rec.wip_supply_type;
      g_encoin_rev_comp_tbl(v).supply_locator_id := c12rec.supply_locator_id;
      g_encoin_rev_comp_tbl(v).bom_item_type := c12rec.bom_item_type;
      g_encoin_rev_comp_tbl(v).operation_seq_num := c12rec.operation_seq_num;
      g_encoin_rev_comp_tbl(v).component_item_id := c12rec.component_item_id;
      g_encoin_rev_comp_tbl(v).last_update_date := c12rec.last_update_date;
      g_encoin_rev_comp_tbl(v).last_updated_by := c12rec.last_updated_by;
      g_encoin_rev_comp_tbl(v).creation_date := c12rec.creation_date;
      g_encoin_rev_comp_tbl(v).created_by := c12rec.created_by;
      g_encoin_rev_comp_tbl(v).last_update_login := c12rec.last_update_login;
      g_encoin_rev_comp_tbl(v).item_num := c12rec.item_num;
      g_encoin_rev_comp_tbl(v).component_quantity := c12rec.component_quantity;
      g_encoin_rev_comp_tbl(v).component_yield_factor := c12rec.component_yield_factor;
      g_encoin_rev_comp_tbl(v).component_remarks := c12rec.component_remarks;
      g_encoin_rev_comp_tbl(v).effectivity_date := c12rec.effectivity_date;
      g_encoin_rev_comp_tbl(v).change_notice := c12rec.change_notice;
      g_encoin_rev_comp_tbl(v).implementation_date := c12rec.implementation_date;
      g_encoin_rev_comp_tbl(v).disable_date := c12rec.disable_date;
      g_encoin_rev_comp_tbl(v).attribute_category := c12rec.attribute_category;
      g_encoin_rev_comp_tbl(v).attribute1 := c12rec.attribute1;
      g_encoin_rev_comp_tbl(v).attribute2 := c12rec.attribute2;
      g_encoin_rev_comp_tbl(v).attribute3 := c12rec.attribute3;
      g_encoin_rev_comp_tbl(v).attribute4 := c12rec.attribute4;
      g_encoin_rev_comp_tbl(v).attribute5 := c12rec.attribute5;
      g_encoin_rev_comp_tbl(v).attribute6 := c12rec.attribute6;
      g_encoin_rev_comp_tbl(v).attribute7 := c12rec.attribute7;
      g_encoin_rev_comp_tbl(v).attribute8 := c12rec.attribute8;
      g_encoin_rev_comp_tbl(v).attribute9 := c12rec.attribute9;
      g_encoin_rev_comp_tbl(v).attribute10 := c12rec.attribute10;
      g_encoin_rev_comp_tbl(v).attribute11 := c12rec.attribute11;
      g_encoin_rev_comp_tbl(v).attribute12 := c12rec.attribute12;
      g_encoin_rev_comp_tbl(v).attribute13 := c12rec.attribute13;
      g_encoin_rev_comp_tbl(v).attribute14 := c12rec.attribute14;
      g_encoin_rev_comp_tbl(v).attribute15 := c12rec.attribute15;
      g_encoin_rev_comp_tbl(v).planning_factor := c12rec.planning_factor;
      g_encoin_rev_comp_tbl(v).quantity_related := c12rec.quantity_related;
      g_encoin_rev_comp_tbl(v).so_basis := c12rec.so_basis;
      g_encoin_rev_comp_tbl(v).optional := c12rec.optional;
      g_encoin_rev_comp_tbl(v).MUTUALLY_EXCLUSIVE_OPT := c12rec.MUTUALLY_EXCLUSIVE_OPTIONS;
      g_encoin_rev_comp_tbl(v).include_in_cost_rollup := c12rec.include_in_cost_rollup;
      g_encoin_rev_comp_tbl(v).check_atp := c12rec.check_atp;
      g_encoin_rev_comp_tbl(v).shipping_allowed := c12rec.shipping_allowed;
      g_encoin_rev_comp_tbl(v).required_to_ship := c12rec.required_to_ship;
      g_encoin_rev_comp_tbl(v).include_on_ship_docs := c12rec.include_on_ship_docs;
      g_encoin_rev_comp_tbl(v).include_on_bill_docs := c12rec.include_on_bill_docs;
      g_encoin_rev_comp_tbl(v).low_quantity := c12rec.low_quantity;
      g_encoin_rev_comp_tbl(v).acd_type := c12rec.acd_type;
      g_encoin_rev_comp_tbl(v).old_component_sequence_id := c12rec.old_component_sequence_id;
      g_encoin_rev_comp_tbl(v).bill_sequence_id := c12rec.bill_sequence_id;
      g_encoin_rev_comp_tbl(v).request_id := c12rec.request_id;
      g_encoin_rev_comp_tbl(v).program_id := c12rec.program_id;
      g_encoin_rev_comp_tbl(v).program_update_date := c12rec.program_update_date;
      g_encoin_rev_comp_tbl(v).pick_components := c12rec.pick_components;
      g_encoin_rev_comp_tbl(v).assembly_type := c12rec.assembly_type;
      g_encoin_rev_comp_tbl(v).interface_entity_type := c12rec.interface_entity_type;
      g_encoin_rev_comp_tbl(v).reference_designator := c12rec.reference_designator;
      g_encoin_rev_comp_tbl(v).new_effectivity_date := c12rec.new_effectivity_date;
      g_encoin_rev_comp_tbl(v).old_effectivity_date := c12rec.old_effectivity_date;
      g_encoin_rev_comp_tbl(v).substitute_comp_id := c12rec.substitute_comp_id;
      g_encoin_rev_comp_tbl(v).new_operation_seq_num := c12rec.new_operation_seq_num;
      g_encoin_rev_comp_tbl(v).old_operation_seq_num := c12rec.old_operation_seq_num;
      g_encoin_rev_comp_tbl(v).process_flag := c12rec.process_flag;
      g_encoin_rev_comp_tbl(v).transaction_id := c12rec.transaction_id;
      g_encoin_rev_comp_tbl(v).SUBSTITUTE_COMP_NUMBER := c12rec.SUBSTITUTE_COMP_NUMBER;
      g_encoin_rev_comp_tbl(v).ORGANIZATION_CODE := c12rec.ORGANIZATION_CODE;
      g_encoin_rev_comp_tbl(v).ASSEMBLY_ITEM_NUMBER := c12rec.ASSEMBLY_ITEM_NUMBER;
      g_encoin_rev_comp_tbl(v).COMPONENT_ITEM_NUMBER := c12rec.COMPONENT_ITEM_NUMBER;
      g_encoin_rev_comp_tbl(v).LOCATION_NAME := c12rec.LOCATION_NAME;
      g_encoin_rev_comp_tbl(v).ORGANIZATION_ID := c12rec.ORGANIZATION_ID;
      g_encoin_rev_comp_tbl(v).ASSEMBLY_ITEM_ID := c12rec.ASSEMBLY_ITEM_ID;
      g_encoin_rev_comp_tbl(v).ALTERNATE_BOM_DESIGNATOR := c12rec.ALTERNATE_BOM_DESIGNATOR;
      g_encoin_rev_comp_tbl(v).operation := c12rec.transaction_type;
      g_encoin_rev_comp_tbl(v).BOM_INVENTORY_COMPS_IFCE_KEY := c12rec.BOM_INVENTORY_COMPS_IFCE_KEY;
      --Bug 3396529: Added New_revised_Item_Revision
      g_encoin_rev_comp_tbl(v).New_revised_Item_Revision := c12rec.New_revised_Item_Revision;
      g_revised_comp_ifce_key := g_encoin_rev_comp_tbl(v).BOM_INVENTORY_COMPS_IFCE_KEY;
      g_encoin_rev_comp_tbl(v).from_end_item_unit_number := c12rec.from_end_item_unit_number; /*Bug 6377841*/
      g_encoin_rev_comp_tbl(v).to_end_item_unit_number := c12rec.to_end_item_unit_number;   /*Bug 6377841*/
/*      g_encoin_rev_comp_tbl(v).old_from_end_item_unit_number := c12rec.old_from_end_item_unit_number;  BUG 9374069 revert 8414408*/

      -------------
      --
      -- Revised component exists, but it doesn't have an IFCE key entry
      --

      stmt_num := 381;
      IF g_revised_comp_ifce_key IS NULL
      THEN
         stmt_num := 382;
         g_revised_comps_exist := TRUE;
         --dbms_output.put_line('No ifce key - Call Public API for comp');
         Move_Encoin_Struct_To_Public;

         stmt_num := 382.5;
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 383;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 384;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 390;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 391;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 392;
            ROLLBACK;
            stmt_num := 393;
            RAISE import_error;
         END IF;

         stmt_num := 394;
         Update_Interface_Tables(l_return_status);
         stmt_num := 395;
         COMMIT;

       -------------
       --
       -- Revised component exists and g_revised_comp_ifce_key is not null
       --

       stmt_num := 396;
       ELSIF g_revised_comp_ifce_key IS NOT NULL
       THEN
         stmt_num := 397;
         g_revised_comps_exist := TRUE;
         l_top_ifce_key := g_revised_comp_ifce_key;

         -- Pick up ref designators with revised comp ifce key = g_revised_comp_ifce_key

         stmt_num := 398;
         Get_Rfds_With_Curr_Comp_Ifce;

         -- Pick up sub components with revised comp ifce key = g_revised_comp_ifce_key

         stmt_num := 399;
         Get_Sbcs_With_Curr_Comp_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 400;
         ResolveIndexKeys;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 401;
         Move_Encoin_Struct_To_Public;

         -- Call Public API

         stmt_num := 402;
         --dbms_output.put_line('Ifce key exists - Call Public API for comp');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 403;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 404;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 410;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 411;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 412;
            ROLLBACK;
            stmt_num := 413;
            RAISE import_error;
         END IF;

         stmt_num := 414;
         Update_Interface_Tables(l_return_status);
         stmt_num := 415;
         COMMIT;

       END IF;

       stmt_num := 422;
       l_return_status := null;
       l_msg_count := null;
       l_msg_data := null;
       --l_error_tbl.DELETE;

       stmt_num := 423;
       Clear_Global_Data_Structures;

       v := 0;

   END LOOP; -- End Revised Component Object loop

   -------------
   --
   -- Revised comp does not exist, i.e., no more revised comps exist in interface table
   --

   stmt_num := 424;
   IF NOT g_revised_comps_exist
   THEN

      -- Group ref desgs rev comp ifce keys

      stmt_num := 425;
      k := 0;
      FOR c1rec IN GetRfdWithSameCompifce LOOP
         k := k + 1;
         g_comp_ifce_group_tbl(k) := c1rec.comp_ifce_key;
      END LOOP;

      stmt_num := 426;
      g_ECO_ifce_key := null;
      g_revised_item_ifce_key := null;
      g_revised_comp_ifce_key := null;
      g_revised_items_exist := FALSE;

      stmt_num := 427;
      FOR i IN 1..g_comp_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 428;
         g_encoin_rev_item_tbl.delete;
         g_public_rev_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_revised_comp_ifce_key := g_comp_ifce_group_tbl(i);
         g_revised_comps_exist := FALSE;

         -- Pick up all reference designators with comp ifce key = g_revised_comp_ifce_key

         stmt_num := 429;
         Get_Rfds_With_Curr_Comp_Ifce;

         -- Pick up all substitute components with comp ifce key = g_revised_comp_ifce_key

         stmt_num := 430;
         Get_Sbcs_With_Curr_Comp_Ifce;

         -- Translate parent ifce keys into parent array indexes

         stmt_num := 431;
         ResolveIndexKeys;

         -- Exit loop if no records found

         stmt_num := 432;
         IF g_encoin_ref_des_tbl.count = 0 AND g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 433;
         Move_Encoin_Struct_To_Public;

         l_top_ifce_key := g_revised_comp_ifce_key;

         -- Call Public API

         stmt_num := 434;
         --dbms_output.put_line('No Comps - Call Public API with desgs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 435;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 436;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 440;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 441;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 442;
            ROLLBACK;
            stmt_num := 443;
            RAISE import_error;
         END IF;

         stmt_num := 444;
         Update_Interface_Tables(l_return_status);
         stmt_num := 445;
         COMMIT;

      END LOOP;

      -- Group sub comps rev item ifce keys

      stmt_num := 453;
      k := 0;
      FOR c1rec IN GetSbcWithSameCompifce LOOP
         k := k + 1;
         g_comp_ifce_group_tbl(k) := c1rec.comp_ifce_key;
      END LOOP;

      g_ECO_ifce_key := null;
      g_revised_item_ifce_key := null;
      g_revised_comp_ifce_key := null;
      g_revised_items_exist := FALSE;

      stmt_num := 454;
      FOR i IN 1..g_comp_ifce_group_tbl.COUNT
      LOOP
         stmt_num := 455;
         g_encoin_rev_item_tbl.delete;
         g_public_rev_tbl.delete;
         g_encoin_rev_comp_tbl.delete;
         g_encoin_ref_des_tbl.delete;
         g_encoin_sub_comp_tbl.delete;
         g_public_eco_rec := null;
         g_public_rev_tbl.DELETE;
         g_public_rev_item_tbl.DELETE;
         g_public_rev_comp_tbl.DELETE;
         g_public_sub_comp_tbl.DELETE;
         g_public_ref_des_tbl.DELETE;
         g_public_rev_op_res_tbl.DELETE;
         g_public_rev_operation_tbl.DELETE;
         g_public_lines_tbl.DELETE;

         g_revised_comp_ifce_key := g_comp_ifce_group_tbl(i);
         g_revised_comps_exist := FALSE;

         -- Pick up all substitute components with comp ifce key = g_revised_comp_ifce_key

         stmt_num := 456;
         Get_Sbcs_With_Curr_Comp_Ifce;

         -- Exit loop if no records found

         stmt_num := 457;
         IF g_encoin_sub_comp_tbl.count = 0
         THEN
                EXIT;
         END IF;

         l_top_ifce_key := g_revised_comp_ifce_key;

         -- Move all encoin data structures to public API parameter data structures

         stmt_num := 458;
         Move_Encoin_Struct_To_Public;

         -- Call Public API

         stmt_num := 459;
         --dbms_output.put_line('No Comps - Call Public API with sbcs starting hierarchy');
         Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 460;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 461;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 470;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 471;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 472;
            ROLLBACK;
            stmt_num := 473;
            RAISE import_error;
         END IF;

         stmt_num := 474;
         Update_Interface_Tables(l_return_status);
         stmt_num := 475;
         COMMIT;

      END LOOP;
   END IF;

-- ******************** REFERENCE DESIGNATOR BUSINESS OBJECT *****************

   stmt_num := 475;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
   --l_error_tbl.DELETE;

   stmt_num := 475.5;
   Clear_Global_Data_Structures;

   FOR c15rec IN GetRfd LOOP
         stmt_num := 476;
         y := 1;
         g_revised_comp_ifce_key := c15rec.bom_inventory_comps_ifce_key;
         g_public_ref_des_tbl.DELETE(y);
         g_public_ref_des_tbl(y).Reference_Designator_Name := c15rec.COMPONENT_REFERENCE_DESIGNATOR;
--         g_public_ref_des_tbl(y).last_update_date := c15rec.last_update_date;
--         g_public_ref_des_tbl(y).last_updated_by := c15rec.last_updated_by;
--         g_public_ref_des_tbl(y).creation_date := c15rec.creation_date;
--         g_public_ref_des_tbl(y).created_by := c15rec.created_by;
--         g_public_ref_des_tbl(y).last_update_login := c15rec.last_update_login;
         g_public_ref_des_tbl(y).ref_designator_comment := c15rec.ref_designator_comment;
         g_public_ref_des_tbl(y).Eco_Name := c15rec.change_notice;
--         g_public_ref_des_tbl(y).component_sequence_id := c15rec.component_sequence_id;
         g_public_ref_des_tbl(y).acd_type := c15rec.acd_type;
--         g_public_ref_des_tbl(y).request_id := c15rec.request_id;
--         g_public_ref_des_tbl(y).program_application_id := c15rec.program_application_id;
--         g_public_ref_des_tbl(y).program_id := c15rec.program_id;
--         g_public_ref_des_tbl(y).program_update_date := c15rec.program_update_date;
         g_public_ref_des_tbl(y).attribute_category := c15rec.attribute_category;
         g_public_ref_des_tbl(y).attribute1 := c15rec.attribute1;
         g_public_ref_des_tbl(y).attribute2 := c15rec.attribute2;
         g_public_ref_des_tbl(y).attribute3 := c15rec.attribute3;
         g_public_ref_des_tbl(y).attribute4 := c15rec.attribute4;
         g_public_ref_des_tbl(y).attribute5 := c15rec.attribute5;
         g_public_ref_des_tbl(y).attribute6 := c15rec.attribute6;
         g_public_ref_des_tbl(y).attribute7 := c15rec.attribute7;
         g_public_ref_des_tbl(y).attribute8 := c15rec.attribute8;
         g_public_ref_des_tbl(y).attribute9 := c15rec.attribute9;
         g_public_ref_des_tbl(y).attribute10 := c15rec.attribute10;
         g_public_ref_des_tbl(y).attribute11 := c15rec.attribute11;
         g_public_ref_des_tbl(y).attribute12 := c15rec.attribute12;
         g_public_ref_des_tbl(y).attribute13 := c15rec.attribute13;
         g_public_ref_des_tbl(y).attribute14 := c15rec.attribute14;
         g_public_ref_des_tbl(y).attribute15 := c15rec.attribute15;
         g_public_ref_des_tbl(y).New_Reference_Designator := c15rec.new_designator;
--         g_public_ref_des_tbl(y).process_flag := c15rec.process_flag;
         g_public_ref_des_tbl(y).Row_Identifier := c15rec.transaction_id;
         g_public_ref_des_tbl(y).revised_ITEM_name := c15rec.ASSEMBLY_ITEM_NUMBER;
         g_public_ref_des_tbl(y).Component_Item_Name := c15rec.COMPONENT_ITEM_NUMBER;
         g_public_ref_des_tbl(y).ORGANIZATION_CODE := c15rec.ORGANIZATION_CODE;
--         g_public_ref_des_tbl(y).ORGANIZATION_ID := c15rec.ORGANIZATION_ID;
--         g_public_ref_des_tbl(y).ASSEMBLY_ITEM_ID := c15rec.ASSEMBLY_ITEM_ID;
         g_public_ref_des_tbl(y).Alternate_Bom_Code := c15rec.ALTERNATE_BOM_DESIGNATOR;
--         g_public_ref_des_tbl(y).COMPONENT_ITEM_ID := c15rec.COMPONENT_ITEM_ID;
--         g_public_ref_des_tbl(y).BILL_SEQUENCE_ID := c15rec.BILL_SEQUENCE_ID;
         g_public_ref_des_tbl(y).Operation_Sequence_Number := c15rec.OPERATION_SEQ_NUM;
         g_public_ref_des_tbl(y).Start_Effective_Date := c15rec.EFFECTIVITY_DATE;
--         g_public_ref_des_tbl(y).interface_entity_type := c15rec.interface_entity_type;
         g_public_ref_des_tbl(y).Transaction_Type := c15rec.transaction_type;
         --Bug 3396529: Added New_revised_Item_Revision
         g_public_ref_des_tbl(y).New_revised_Item_Revision := c15rec.New_revised_Item_Revision;


        stmt_num := 478;
        --dbms_output.put_line('Call Public API for Reference Designator entity');
        Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 479;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 480;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 480;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 481;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 482;
            ROLLBACK;
            stmt_num := 483;
            RAISE import_error;
         END IF;

         stmt_num := 484;
         Update_Interface_Tables(l_return_status);
         stmt_num := 485;
         COMMIT;

        stmt_num := 486;
        l_return_status := null;
        l_msg_count := null;
        l_msg_data := null;
        --l_error_tbl.DELETE;

        stmt_num := 487;
        Clear_Global_Data_Structures;

   END LOOP; -- END REF DES LOOP

-- ****************** SUBSTITUTE COMPONENT BUSINESS OBJECT *****************

   stmt_num := 494;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
   --l_error_tbl.DELETE;

   stmt_num := 494.5;
   Clear_Global_Data_Structures;

   FOR c16rec IN GetSbc LOOP
        stmt_num := 495;
         z := 1;
         g_public_sub_comp_tbl.DELETE(z);
--         g_public_sub_comp_tbl(z).substitute_component_id := c16rec.substitute_component_id;
--         g_public_sub_comp_tbl(z).last_update_date := c16rec.last_update_date;
--         g_public_sub_comp_tbl(z).last_updated_by := c16rec.last_updated_by;
--         g_public_sub_comp_tbl(z).creation_date := c16rec.creation_date;
--         g_public_sub_comp_tbl(z).created_by := c16rec.created_by;
--         g_public_sub_comp_tbl(z).last_update_login := c16rec.last_update_login;
         g_public_sub_comp_tbl(z).substitute_item_quantity := c16rec.substitute_item_quantity;
--         g_public_sub_comp_tbl(z).component_sequence_id := c16rec.component_sequence_id;
         g_public_sub_comp_tbl(z).acd_type := c16rec.acd_type;
         g_public_sub_comp_tbl(z).eco_name := c16rec.change_notice;
--         g_public_sub_comp_tbl(z).request_id := c16rec.request_id;
--         g_public_sub_comp_tbl(z).program_application_id := c16rec.program_application_id;
--         g_public_sub_comp_tbl(z).program_update_date := c16rec.program_update_date;
         g_public_sub_comp_tbl(z).attribute_category := c16rec.attribute_category;
         g_public_sub_comp_tbl(z).attribute1 := c16rec.attribute1;
         g_public_sub_comp_tbl(z).attribute1 := c16rec.attribute2;
         g_public_sub_comp_tbl(z).attribute1 := c16rec.attribute4;
         g_public_sub_comp_tbl(z).attribute1 := c16rec.attribute5;
         g_public_sub_comp_tbl(z).attribute1 := c16rec.attribute6;
         g_public_sub_comp_tbl(z).attribute8 := c16rec.attribute8;
         g_public_sub_comp_tbl(z).attribute9 := c16rec.attribute9;
         g_public_sub_comp_tbl(z).attribute10 := c16rec.attribute10;
         g_public_sub_comp_tbl(z).attribute12 := c16rec.attribute12;
         g_public_sub_comp_tbl(z).attribute13 := c16rec.attribute13;
         g_public_sub_comp_tbl(z).attribute14 := c16rec.attribute14;
         g_public_sub_comp_tbl(z).attribute15 := c16rec.attribute15;
         g_public_sub_comp_tbl(z).program_id := c16rec.program_id;
         g_public_sub_comp_tbl(z).attribute3 := c16rec.attribute3;
         g_public_sub_comp_tbl(z).attribute7 := c16rec.attribute7;
         g_public_sub_comp_tbl(z).attribute11 := c16rec.attribute11;
--         g_public_sub_comp_tbl(z).new_sub_comp_id := c16rec.new_sub_comp_id;
--         g_public_sub_comp_tbl(z).process_flag := c16rec.process_flag;
         g_public_sub_comp_tbl(z).row_identifier := c16rec.transaction_id;
--         g_public_sub_comp_tbl(z).NEW_SUB_COMP_NUMBER := c16rec.NEW_SUB_COMP_NUMBER;
         g_public_sub_comp_tbl(z).revised_ITEM_name := c16rec.ASSEMBLY_ITEM_NUMBER;
         g_public_sub_comp_tbl(z).COMPONENT_ITEM_NAME := c16rec.COMPONENT_ITEM_NUMBER;
         g_public_sub_comp_tbl(z).Substitute_Component_Name := c16rec.SUBSTITUTE_COMP_NUMBER;
         g_public_sub_comp_tbl(z).ORGANIZATION_CODE := c16rec.ORGANIZATION_CODE;
--         g_public_sub_comp_tbl(z).ORGANIZATION_ID := c16rec.ORGANIZATION_ID;
--         g_public_sub_comp_tbl(z).ASSEMBLY_ITEM_ID := c16rec.ASSEMBLY_ITEM_ID;
         g_public_sub_comp_tbl(z).ALTERNATE_BOM_code := c16rec.ALTERNATE_BOM_DESIGNATOR;
--         g_public_sub_comp_tbl(z).COMPONENT_ITEM_ID := c16rec.COMPONENT_ITEM_ID;
--         g_public_sub_comp_tbl(z).BILL_SEQUENCE_ID := c16rec.BILL_SEQUENCE_ID;
         g_public_sub_comp_tbl(z).Operation_Sequence_Number := c16rec.OPERATION_SEQ_NUM;
         g_public_sub_comp_tbl(z).Start_Effective_Date := c16rec.EFFECTIVITY_DATE;
--         g_public_sub_comp_tbl(z).interface_entity_type := c16rec.interface_entity_type;
         g_public_sub_comp_tbl(z).transaction_type := c16rec.transaction_type;
         --Bug 3396529: Added New_revised_Item_Revision
         g_public_sub_comp_tbl(z).New_revised_Item_Revision := c16rec.New_revised_Item_Revision;

        stmt_num := 497;
        --dbms_output.put_line('Call Public API from Substitute Component entity');
        Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 498;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 499;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 500;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 501;
            ROLLBACK;
            RETCODE := G_ERROR;  /* Bug fix 9214078 */
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 502;
            ROLLBACK;
            stmt_num := 503;
            RAISE import_error;
         END IF;

         stmt_num := 504;
         Update_Interface_Tables(l_return_status);
         stmt_num := 505;
         COMMIT;

        stmt_num := 512.5;
        l_return_status := null;
        l_msg_count := null;
        l_msg_data := null;
        --l_error_tbl.DELETE;

        stmt_num := 512.7;
        Clear_Global_Data_Structures;

   END LOOP; -- END SUB COMP LOOP


-- ******************** DELETE PROCESSED ROWS ****************************

   stmt_num := 513;
   IF (p_del_rec_flag = 1) THEN
      LOOP
         DELETE from eng_eng_changes_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 514;
      LOOP
         DELETE from eng_eco_revisions_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 515;
      LOOP
         DELETE from eng_revised_items_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 516;
      LOOP
         DELETE from bom_inventory_comps_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 517;
      LOOP
         DELETE from bom_ref_desgs_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 518;
      LOOP
         DELETE from bom_sub_comps_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 519;
      LOOP
         DELETE from eng_change_lines_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 520;
      LOOP
         DELETE from bom_op_sequences_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

      stmt_num := 521;
      LOOP
         DELETE from bom_op_resources_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;
      stmt_num := 522;
      LOOP
         DELETE from bom_sub_op_resources_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

   END IF;

   -- sync intermedia index
   stmt_num := 523;
   BEGIN
        ENG_CHANGE_TEXT_UTIL.Sync_Index ( p_idx_name => 'ENG_CHANGE_IMTEXT_TL_CTX1' );
   EXCEPTION
        WHEN others THEN
                NULL;
   END;

/* Bug fix 9214078 */
   If RETCODE is NULL then
      RETCODE := G_SUCCESS;
      ERRBUF := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_SUCCEEDED');
   elsif RETCODE = G_ERROR then
      ERRBUF := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_FAILED');
   END IF;
   --Bug 2818039
   ENG_GLOBALS.G_ENG_LAUNCH_IMPORT           := 0;
EXCEPTION
   WHEN import_error THEN
      --Bug No: 3737881
      ENG_GLOBALS.G_ENG_LAUNCH_IMPORT := 0;
      --dbms_output.put_line('Import_Error exception handler');
      RETCODE := G_ERROR;
      ERRBUF := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_FAILED');

      MRP_UTIL.MRP_LOG('ENG_LAUNCH_ECO_OI_PK.Eng_Launch_Import('||
                        to_char(stmt_num)||') ');
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
      MRP_UTIL.MRP_LOG(l_unexp_error);
   WHEN others THEN
      --Bug No: 3737881
      ENG_GLOBALS.G_ENG_LAUNCH_IMPORT := 0;
      --dbms_output.put_line('Others exception handler - stmt num : ' || to_char(stmt_num));
      --dbms_output.put_line('SQL error is '||SQLERRM);
      RETCODE := G_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_FAILED');

      MRP_UTIL.Mrp_Log('ENG_LAUNCH_ECO_OI_PK.Eng_Launch_Import('||
                        to_char(stmt_num)||') ');
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
      MRP_UTIL.MRP_LOG(SQLERRM);
END Eng_Launch_Import;

--Added for PLM Changemanagement Bulkload RevisedItems.
PROCEDURE Eng_Launch_RevisedItems_Import (
    ERRBUF          OUT NOCOPY VARCHAR2,
    RETCODE         OUT NOCOPY NUMBER,
    p_org_id            NUMBER,
    p_all_org           NUMBER  ,
    p_del_rec_flag      NUMBER  )
IS
    stmt_num                    NUMBER;
    l_prog_appid                NUMBER;
    l_prog_id                   NUMBER;
    l_request_id                NUMBER;
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_unexp_error               VARCHAR2(1000);
    l_transaction_id            NUMBER;
--    l_error_tbl                       ENG_Eco_PUB.Error_Tbl_Type;
--    l_log_msg                 VARCHAR2(2000);
--    l_err_text                        VARCHAR2(2000);

    r                           NUMBER := 0;
    import_error                EXCEPTION;
    l_process_flag              NUMBER;

   --Process only the records which are inserted from PLM i.e -999.

  CURSOR GetItem
IS
        SELECT  change_notice             ,
                organization_id           ,
                revised_item_id           ,
                last_update_date          ,
                last_updated_by           ,
                creation_date             ,
                created_by                ,
                last_update_login         ,
                implementation_date       ,
                cancellation_date         ,
                cancel_comments           ,
                disposition_type          ,
                new_item_revision         ,
                early_schedule_date       ,
                attribute_category        ,
                attribute2                ,
                attribute3                ,
                attribute4                ,
                attribute5                ,
                attribute7                ,
                attribute8                ,
                attribute9                ,
                attribute11               ,
                attribute12               ,
                attribute13               ,
                attribute14               ,
                attribute15               ,
                status_type               ,
                scheduled_date            ,
                bill_sequence_id          ,
                mrp_active                ,
                request_id                ,
                program_application_id    ,
                program_id                ,
                program_update_date       ,
                update_wip                ,
                use_up                    ,
                use_up_item_id            ,
                revised_item_sequence_id  ,
                use_up_plan_name          ,
                descriptive_text          ,
                auto_implement_date       ,
                attribute1                ,
                attribute6                ,
                attribute10               ,
                requestor_id              ,
                comments                  ,
                1 process_flag            ,
                transaction_id            ,
                organization_code         ,
                revised_item_number       ,
                new_rtg_revision          ,
                use_up_item_number        ,
                alternate_bom_designator  ,
                transaction_type          ,
                ENG_REVISED_ITEMS_IFCE_KEY,
                eng_changes_ifce_key      ,
                parent_revised_item_name  ,
                parent_alternate_name     ,
                updated_item_revision     ,
                New_scheduled_date    -- Bug 3432944
                ,
                from_item_revision -- 11.5.10E
                ,
                new_revision_label        ,
                New_Revised_Item_Rev_Desc ,
                new_revision_reason       ,
                from_end_item_unit_number
        FROM    eng_revised_items_interface
        WHERE   process_flag    = -999
            AND (g_all_org      = 1
             OR (g_all_org      = 2
            AND organization_id = g_org_id))
        ORDER BY parent_revised_item_name desc ;

BEGIN
    -- *************************** REVISED ITEM BUSINESS OBJECT **************************
   r := 0;

    stmt_num := 1;
    l_prog_appid := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id    := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    l_user_id    := FND_GLOBAL.USER_ID;
    l_login_id   := FND_GLOBAL.LOGIN_ID;

    g_all_org := p_all_org;
    g_org_id := p_org_id;

   --dbms_output.put_line('Who record initiation');
   stmt_num := 2;
   ENG_GLOBALS.Init_Who_Rec(p_org_id => p_org_id,
                            p_user_id => l_user_id,
                            p_login_id => l_login_id,
                            p_prog_appid => l_prog_appid,
                            p_prog_id => l_prog_id,
                            p_req_id => l_request_id);

   ENG_GLOBALS.G_ENG_LAUNCH_IMPORT  := 1;

   stmt_num := 240;
   l_return_status := null;
   l_msg_count := null;
   l_msg_data := null;
   --l_error_tbl.DELETE;

   stmt_num := 240.5;
   Clear_Global_Data_Structures;

  stmt_num := 241;
  FOR c8rec IN GetItem LOOP

      -- Pick up one revised item record
      stmt_num := 242;
      r := r + 1;
      g_encoin_rev_item_tbl(r).change_notice := c8rec.change_notice;
      g_encoin_rev_item_tbl(r).organization_id := c8rec.organization_id;
      g_encoin_rev_item_tbl(r).revised_item_id := c8rec.revised_item_id;
      g_encoin_rev_item_tbl(r).last_update_date := c8rec.last_update_date;
      g_encoin_rev_item_tbl(r).last_updated_by := c8rec.last_updated_by;
      g_encoin_rev_item_tbl(r).creation_date := c8rec.creation_date;
      g_encoin_rev_item_tbl(r).created_by := c8rec.created_by;
      g_encoin_rev_item_tbl(r).last_update_login := c8rec.last_update_login;
      g_encoin_rev_item_tbl(r).implementation_date := c8rec.implementation_date;
      g_encoin_rev_item_tbl(r).cancellation_date := c8rec.cancellation_date;
      g_encoin_rev_item_tbl(r).cancel_comments := c8rec.cancel_comments;
      g_encoin_rev_item_tbl(r).disposition_type := c8rec.disposition_type;
      g_encoin_rev_item_tbl(r).new_item_revision := c8rec.new_item_revision;
      g_encoin_rev_item_tbl(r).early_schedule_date := c8rec.early_schedule_date;
      g_encoin_rev_item_tbl(r).attribute_category := c8rec.attribute_category;
      g_encoin_rev_item_tbl(r).attribute2 := c8rec.attribute2;
      g_encoin_rev_item_tbl(r).attribute3 := c8rec.attribute3;
      g_encoin_rev_item_tbl(r).attribute4 := c8rec.attribute4;
      g_encoin_rev_item_tbl(r).attribute5 := c8rec.attribute5;
      g_encoin_rev_item_tbl(r).attribute7 := c8rec.attribute7;
      g_encoin_rev_item_tbl(r).attribute8 := c8rec.attribute8;
      g_encoin_rev_item_tbl(r).attribute9 := c8rec.attribute9;
      g_encoin_rev_item_tbl(r).attribute11 := c8rec.attribute11;
      g_encoin_rev_item_tbl(r).attribute12 := c8rec.attribute12;
      g_encoin_rev_item_tbl(r).attribute13 := c8rec.attribute13;
      g_encoin_rev_item_tbl(r).attribute14 := c8rec.attribute14;
      g_encoin_rev_item_tbl(r).attribute15 := c8rec.attribute15;
      g_encoin_rev_item_tbl(r).status_type := c8rec.status_type;
      g_encoin_rev_item_tbl(r).scheduled_date := c8rec.scheduled_date;
      g_encoin_rev_item_tbl(r).bill_sequence_id := c8rec.bill_sequence_id;
      g_encoin_rev_item_tbl(r).mrp_active := c8rec.mrp_active;
      g_encoin_rev_item_tbl(r).request_id := c8rec.request_id;
      g_encoin_rev_item_tbl(r).program_application_id := c8rec.program_application_id;
      g_encoin_rev_item_tbl(r).program_id := c8rec.program_id;
      g_encoin_rev_item_tbl(r).program_update_date := c8rec.program_update_date;
      g_encoin_rev_item_tbl(r).update_wip := c8rec.update_wip;
      g_encoin_rev_item_tbl(r).use_up := c8rec.use_up;
      g_encoin_rev_item_tbl(r).use_up_item_id := c8rec.use_up_item_id;
      g_encoin_rev_item_tbl(r).revised_item_sequence_id := c8rec.revised_item_sequence_id;
      g_encoin_rev_item_tbl(r).use_up_plan_name := c8rec.use_up_plan_name;
      g_encoin_rev_item_tbl(r).descriptive_text := c8rec.descriptive_text;
      g_encoin_rev_item_tbl(r).auto_implement_date := c8rec.auto_implement_date;
      g_encoin_rev_item_tbl(r).attribute1 := c8rec.attribute1;
      g_encoin_rev_item_tbl(r).attribute6 := c8rec.attribute6;
      g_encoin_rev_item_tbl(r).attribute10 := c8rec.attribute10;
      g_encoin_rev_item_tbl(r).requestor_id := c8rec.requestor_id;
      g_encoin_rev_item_tbl(r).comments := c8rec.comments;
      g_encoin_rev_item_tbl(r).process_flag := c8rec.process_flag;
      g_encoin_rev_item_tbl(r).transaction_id := c8rec.transaction_id;
      l_transaction_id :=   g_encoin_rev_item_tbl(r).transaction_id;
      g_encoin_rev_item_tbl(r).organization_code := c8rec.organization_code;
      g_encoin_rev_item_tbl(r).revised_item_number := c8rec.revised_item_number;
      g_encoin_rev_item_tbl(r).new_rtg_revision := c8rec.new_rtg_revision;
      g_encoin_rev_item_tbl(r).use_up_item_number := c8rec.use_up_item_number;
      g_encoin_rev_item_tbl(r).alternate_bom_designator := c8rec.alternate_bom_designator;
      g_encoin_rev_item_tbl(r).operation := c8rec.transaction_type;
      g_encoin_rev_item_tbl(r).ENG_REVISED_ITEMS_IFCE_KEY := c8rec.ENG_REVISED_ITEMS_IFCE_KEY;
      g_revised_item_ifce_key := g_encoin_rev_item_tbl(r).ENG_REVISED_ITEMS_IFCE_KEY;
      g_encoin_rev_item_tbl(r).parent_revised_item_name := c8rec.parent_revised_item_name;
      g_encoin_rev_item_tbl(r).parent_alternate_name := c8rec.parent_alternate_name;
      g_encoin_rev_item_tbl(r).updated_item_revision := c8rec.updated_item_revision; -- Bug 3432944
      g_encoin_rev_item_tbl(r).New_scheduled_date := c8rec.New_scheduled_date; -- Bug 3432944
      g_encoin_rev_item_tbl(r).from_item_revision := c8rec.from_item_revision; -- 11.5.10E
      g_encoin_rev_item_tbl(r).new_revision_label := c8rec.new_revision_label;
      g_encoin_rev_item_tbl(r).New_Revised_Item_Rev_Desc := c8rec.New_Revised_Item_Rev_Desc;
      g_encoin_rev_item_tbl(r).new_revision_reason := c8rec.new_revision_reason;
      g_encoin_rev_item_tbl(r).from_end_item_unit_number := c8rec.from_end_item_unit_number; /*Bug 6377841*/
      -------------
      --
      -- Revised item exists, but it doesn't have an IFCE key entry
      --
      stmt_num := 243;
      g_revised_items_exist := TRUE;

         -- Move all encoin data structures to public API parameter data structures

      stmt_num := 244;
      Move_Encoin_Struct_To_Public;

      stmt_num := 245;
      Eng_Eco_Pub.Process_Eco (
                        p_api_version_number    => 1.0,
                        p_init_msg_list         => true,
                        --p_commit              => FND_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        --x_msg_data            => l_msg_data,
                        p_ECO_rec               => ENG_ECO_PUB.G_MISS_ECO_REC,
                        p_eco_revision_tbl      => g_public_rev_tbl,
                        p_revised_item_tbl      => g_public_rev_item_tbl,
                        p_rev_component_tbl     => g_public_rev_comp_tbl,
                        p_ref_designator_tbl    => g_public_ref_des_tbl,
                        p_sub_component_tbl     => g_public_sub_comp_tbl,
                        x_ECO_rec               => g_public_out_eco_rec,
                        x_eco_revision_tbl      => g_public_out_rev_tbl,
                        x_revised_item_tbl      => g_public_out_rev_item_tbl,
                        x_rev_component_tbl     => g_public_out_rev_comp_tbl,
                        x_ref_designator_tbl    => g_public_out_ref_des_tbl,
                        x_sub_component_tbl     => g_public_out_sub_comp_tbl--,
                        , x_rev_operation_tbl        => g_public_out_rev_operation_tbl
                        , x_rev_op_resource_tbl      => g_public_out_rev_op_res_tbl
                        , x_rev_sub_resource_tbl     => g_public_out_rev_sub_res_tbl
            ,p_debug                 => 'N'
            ,p_debug_filename        => ''
            ,p_output_dir            => ''
                        --x_err_text            => l_err_text--,
                        --x_err_tbl             => l_error_tbl
            );

         stmt_num := 245;
         Eng_Globals.Clear_Request_Table;
         stmt_num := 246;

         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            stmt_num := 250;
            COMMIT;
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            stmt_num := 251;
            ROLLBACK;
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            stmt_num := 252;
            ROLLBACK;
            stmt_num := 253;
            RAISE import_error;
         END IF;

         stmt_num := 254;
-- ******************** UPDATE PROCESSED ROWS **************************

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           l_process_flag := G_PF_SUCCESS;
        ELSE
           l_process_flag := G_PF_ERROR;
        END IF;

        UPDATE ENG_REVISED_ITEMS_INTERFACE
        SET PROCESS_FLAG = l_process_flag
        WHERE TRANSACTION_ID = l_transaction_id;

        stmt_num := 255;
        --Bug No:3902450 :Added as the error was not getting inserted when new rev was required in import.
        Error_Handler.WRITE_TO_INTERFACETABLE;
        stmt_num := 256;
         COMMIT;

      stmt_num := 291;
      l_return_status := null;
      l_msg_count := null;
      l_msg_data := null;
      --l_error_tbl.DELETE;

      stmt_num := 291.5;
      Clear_Global_Data_Structures;

      r := 0;

   END LOOP; -- End Revised Item Object loop

-- ******************** DELETE PROCESSED ROWS ****************************

   stmt_num := 513;
   IF (p_del_rec_flag = 1) THEN
      stmt_num := 515;
      LOOP
         DELETE from eng_revised_items_interface
          WHERE process_flag = 7
            AND rownum < G_ROWS_TO_COMMIT;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;

   END IF;

   ERRBUF := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_SUCCEEDED');
   RETCODE := G_SUCCESS;

   ENG_GLOBALS.G_ENG_LAUNCH_IMPORT           := 0;
EXCEPTION
   WHEN import_error THEN
      --dbms_output.put_line('Import_Error exception handler');
      RETCODE := G_ERROR;
      ERRBUF := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_FAILED');

      MRP_UTIL.MRP_LOG('ENG_LAUNCH_ECO_OI_PK.Eng_Launch_RevisedItems_Import('||
                        to_char(stmt_num)||') ');
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
      MRP_UTIL.MRP_LOG(l_unexp_error);
   WHEN others THEN
      --dbms_output.put_line('Others exception handler - stmt num : ' || to_char(stmt_num));
      --dbms_output.put_line('SQL error is '||SQLERRM);
      RETCODE := G_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('ENG', 'ENG_ECOOI_FAILED');

      MRP_UTIL.Mrp_Log('ENG_LAUNCH_ECO_OI_PK.Eng_Launch_RevisedItems_Import('||
                        to_char(stmt_num)||') ');
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
      MRP_UTIL.MRP_LOG(SQLERRM);


END Eng_Launch_RevisedItems_Import;


END ENG_LAUNCH_ECO_OI_PK;


/
