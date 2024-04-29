--------------------------------------------------------
--  DDL for Package Body WSMPDJOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPDJOB" as
/* $Header: WSMDJTHB.pls 115.14 2003/12/04 22:53:05 zchen ship $ */

PROCEDURE Insert_Row(
        X_Rowid                             IN OUT NOCOPY VARCHAR2,
            X_wip_entity_id                 IN OUT NOCOPY NUMBER,
            X_organization_id               NUMBER,
            X_last_update_date              DATE,
            X_last_updated_by               NUMBER,
            X_creation_date                 DATE,
            X_created_by                    NUMBER,
            X_last_update_login             NUMBER,
            X_description                   VARCHAR2,
            X_status_type                   NUMBER,
            X_primary_item_id               NUMBER,
            X_firm_planned_flag             NUMBER,
            X_job_type                      NUMBER,
            X_wip_supply_type               NUMBER,
            X_class_code                    VARCHAR2,
            X_material_account              NUMBER,
            X_material_overhead_account     NUMBER,
            X_resource_account              NUMBER,
            X_outside_processing_account    NUMBER,
            X_material_variance_account     NUMBER,
            X_resource_variance_account     NUMBER,
            X_outside_proc_var_account      NUMBER,
            X_std_cost_adjustment_account   NUMBER,
            X_overhead_account              NUMBER,
            X_overhead_variance_account     NUMBER,
            X_scheduled_start_date          DATE,
            X_date_released                 DATE,
            X_scheduled_completion_date     DATE,
            X_date_completed                DATE,
            X_date_closed                   DATE,
            X_start_quantity                NUMBER,
            X_overcompletion_toleran_type   NUMBER,
            X_overcompletion_toleran_value  NUMBER,
            X_quantity_completed            NUMBER,
            X_quantity_scrapped             NUMBER,
            X_net_quantity                  NUMBER,
            X_bom_reference_id              NUMBER,
            X_routing_reference_id          NUMBER,
            X_common_bom_sequence_id        NUMBER,
            X_common_routing_sequence_id    NUMBER,
            X_bom_revision                  VARCHAR2,
            X_routing_revision              VARCHAR2,
            X_bom_revision_date             DATE,
            X_routing_revision_date         DATE,
            X_lot_number                    VARCHAR2,
            X_alternate_bom_designator      VARCHAR2,
            X_alternate_routing_designator  VARCHAR2,
            X_completion_subinventory       VARCHAR2,
            X_completion_locator_id         NUMBER,
            X_demand_class                  VARCHAR2,
            X_attribute_category            VARCHAR2,
            X_attribute1                    VARCHAR2,
            X_attribute2                    VARCHAR2,
            X_attribute3                    VARCHAR2,
            X_attribute4                    VARCHAR2,
            X_attribute5                    VARCHAR2,
            X_attribute6                    VARCHAR2,
            X_attribute7                    VARCHAR2,
            X_attribute8                    VARCHAR2,
            X_attribute9                    VARCHAR2,
            X_attribute10                   VARCHAR2,
            X_attribute11                   VARCHAR2,
            X_attribute12                   VARCHAR2,
            X_attribute13                   VARCHAR2,
            X_attribute14                   VARCHAR2,
            X_attribute15                   VARCHAR2,
            X_We_Rowid                      IN OUT NOCOPY  VARCHAR2,
            X_Entity_Type                   NUMBER,
            X_Wip_Entity_Name               VARCHAR2,
            X_Schedule_Group_Id             NUMBER,
            X_Build_Sequence                NUMBER,
            X_Line_Id                       NUMBER,
            X_Project_Id                    NUMBER,
            X_Task_Id                       NUMBER,
            X_end_item_unit_number          VARCHAR2,
            X_po_creation_time              NUMBER,
            X_priority                      NUMBER,
            X_due_date                      DATE,
            x_coproducts_supply             NUMBER,
            x_error_code                    OUT NOCOPY     NUMBER,
            x_error_msg                     OUT NOCOPY     VARCHAR2
        ) IS

CURSOR C(we_id NUMBER) IS
        SELECT  rowid
        FROM    WIP_DISCRETE_JOBS
        WHERE   wip_entity_id = we_id
        AND     organization_id = X_Organization_Id;

-- CURSOR C2 IS SELECT wip_entities_s.nextval FROM DUAL; perf. tuning, abb

CURSOR C3(we_id NUMBER) IS
        SELECT  rowid
        FROM    WIP_ENTITIES
        WHERE   wip_entity_id = we_id
        AND     organization_id = X_Organization_Id;

-- Begin WSM Customization
x_est_scrap_account     NUMBER;
x_est_scrap_var_account NUMBER;
l_stat_num              NUMBER;
-- End WSM Customization

BEGIN
null;
/* --commented out by abedajna since this is no longer used
l_stat_num := 10;

-- Begin WSM Customization
l_stat_num := 20;
-- abb H: removed the clause class_type = 5, since we are providing the class_code, it's not necessary.
        BEGIN
            SELECT   EST_SCRAP_ACCOUNT,
                    EST_SCRAP_VAR_ACCOUNT
            INTO     x_est_scrap_account,
                    x_est_scrap_var_account
            FROM     WIP_ACCOUNTING_CLASSES
            where    organization_id = X_organization_id
            AND      class_code = X_class_code;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
-- End WSM Customization
l_stat_num := 30;

    INSERT INTO WIP_DISCRETE_JOBS(
        wip_entity_id,
        organization_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        description,
        status_type,
        primary_item_id,
        firm_planned_flag,
        job_type,
        wip_supply_type,
        class_code,
        material_account,
        material_overhead_account,
        resource_account,
        outside_processing_account,
        material_variance_account,
        resource_variance_account,
        outside_proc_variance_account,
        std_cost_adjustment_account,
        overhead_account,
        overhead_variance_account,
        scheduled_start_date,
        date_released,
        scheduled_completion_date,
        date_completed,
        date_closed,
        start_quantity,
        overcompletion_tolerance_type,
        overcompletion_tolerance_value,
        quantity_completed,
        quantity_scrapped,
        net_quantity,
        bom_reference_id,
        routing_reference_id,
        common_bom_sequence_id,
        common_routing_sequence_id,
        bom_revision,
        routing_revision,
        bom_revision_date,
        routing_revision_date,
        lot_number,
        alternate_bom_designator,
        alternate_routing_designator,
        completion_subinventory,
        completion_locator_id,
        demand_class,
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
        schedule_group_id,
        build_sequence,
        line_id,
        project_id,
        task_id,
        end_item_unit_number,
        po_creation_time,
        priority,
        due_date,
-- Begin WSM Customization
        est_scrap_account,
        est_scrap_var_account,
        coproducts_supply
-- End WSM Customization
         ) VALUES (
--      X_wip_entity_id,  abedajna, perf.tuning
                decode(X_wip_entity_id, NULL, wip_entities_s.nextval, X_wip_entity_id),
        X_organization_id,
        X_last_update_date,
        X_last_updated_by,
        X_creation_date,
        X_created_by,
        X_last_update_login,
        X_description,
        X_status_type,
        X_primary_item_id,
        X_firm_planned_flag,
        X_job_type,
        X_wip_supply_type,
        X_class_code,
        X_material_account,
        X_material_overhead_account,
        X_resource_account,
        X_outside_processing_account,
        X_material_variance_account,
        X_resource_variance_account,
        X_outside_proc_var_account,
        X_std_cost_adjustment_account,
        X_overhead_account,
        X_overhead_variance_account,
        X_scheduled_start_date,
        X_date_released,
        X_scheduled_completion_date,
        X_date_completed,
        X_date_closed,
        X_start_quantity,
        X_overcompletion_toleran_type,
        X_overcompletion_toleran_value,
        X_quantity_completed,
        X_quantity_scrapped,
        X_net_quantity,
        X_bom_reference_id,
        X_routing_reference_id,
        X_common_bom_sequence_id,
        X_common_routing_sequence_id,
        X_bom_revision,
        X_routing_revision,
        X_bom_revision_date,
        X_routing_revision_date,
        X_lot_number,
        X_alternate_bom_designator,
        X_alternate_routing_designator,
        X_completion_subinventory,
        X_completion_locator_id,
        X_demand_class,
        X_attribute_category,
        X_attribute1,
        X_attribute2,
        X_attribute3,
        X_attribute4,
        X_attribute5,
        X_attribute6,
        X_attribute7,
        X_attribute8,
        X_attribute9,
        X_attribute10,
        X_attribute11,
        X_attribute12,
        X_attribute13,
        X_attribute14,
        X_attribute15,
        X_Schedule_Group_Id,
        X_Build_Sequence,
        X_Line_Id,
        X_Project_Id,
        X_Task_ID,
        X_end_item_unit_number,
        X_po_creation_time,
        X_priority,
        X_due_date,
-- Begin WSM Customization
        x_est_scrap_account,
        x_est_scrap_var_account,
        x_coproducts_supply)
        RETURNING wip_entity_id into X_wip_entity_id;
--abedajna, perf.tuning

-- End WSM Customization
l_stat_num := 40;

    OPEN C(X_Wip_Entity_Id);
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
        CLOSE C;
        Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
l_stat_num := 50;

    INSERT INTO WIP_ENTITIES(
        wip_entity_id,
        organization_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        wip_entity_name,
        entity_type,
        description,
        primary_item_id,
        gen_object_id
    ) VALUES (
        X_Wip_Entity_Id,
        X_Organization_Id,
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Creation_Date,
        X_Created_By,
        X_Last_Update_Login,
        X_Wip_Entity_Name,
        X_Entity_Type,
        X_Description,
        X_Primary_Item_Id,
        MTL_GEN_OBJECT_ID_S.nextval);
l_stat_num := 60;

    OPEN C3(X_Wip_Entity_Id);
    FETCH C3 INTO X_We_Rowid;
    if (C3%NOTFOUND) then
        CLOSE C3;
        Raise NO_DATA_FOUND;
    end if;
    CLOSE C3;

EXCEPTION
    WHEN others THEN
                x_error_code := SQLCODE;
                x_error_msg := 'WSMDJTHB.INSERT_ROW('||l_stat_num||')'|| substr(SQLERRM,1,200);
*/
END INSERT_ROW;

PROCEDURE Update_Row(
        X_Rowid                         VARCHAR2,
        X_wip_entity_id                 NUMBER,
        X_organization_id               NUMBER,
        X_last_update_date              DATE,
        X_last_updated_by               NUMBER,
        X_creation_date                 DATE,
        X_created_by                    NUMBER,
        X_last_update_login             NUMBER,
        X_description                   VARCHAR2,
        X_status_type                   NUMBER,
        X_primary_item_id               NUMBER,
        X_firm_planned_flag             NUMBER,
        X_job_type                      NUMBER,
        X_wip_supply_type               NUMBER,
        X_class_code                    VARCHAR2,
        X_material_account              NUMBER,
        X_material_overhead_account     NUMBER,
        X_resource_account              NUMBER,
        X_outside_processing_account    NUMBER,
        X_material_variance_account     NUMBER,
        X_resource_variance_account     NUMBER,
        X_outside_proc_var_account      NUMBER,
        X_std_cost_adjustment_account   NUMBER,
        X_overhead_account              NUMBER,
        X_overhead_variance_account     NUMBER,
        X_scheduled_start_date          DATE,
        X_date_released                 DATE,
        X_scheduled_completion_date     DATE,
        X_date_completed                DATE,
        X_date_closed                   DATE,
        X_start_quantity                NUMBER,
        X_overcompletion_toleran_type   NUMBER,
        X_overcompletion_toleran_value  NUMBER,
        X_quantity_completed            NUMBER,
        X_quantity_scrapped             NUMBER,
        X_net_quantity                  NUMBER,
        X_bom_reference_id              NUMBER,
        X_routing_reference_id          NUMBER,
        X_common_bom_sequence_id        NUMBER,
        X_common_routing_sequence_id    NUMBER,
        X_bom_revision                  VARCHAR2,
        X_routing_revision              VARCHAR2,
        X_bom_revision_date             DATE,
        X_routing_revision_date         DATE,
        X_lot_number                    VARCHAR2,
        X_alternate_bom_designator      VARCHAR2,
        X_alternate_routing_designator  VARCHAR2,
        X_completion_subinventory       VARCHAR2,
        X_completion_locator_id         NUMBER,
        X_demand_class                  VARCHAR2,
        X_attribute_category            VARCHAR2,
        X_attribute1                    VARCHAR2,
        X_attribute2                    VARCHAR2,
        X_attribute3                    VARCHAR2,
        X_attribute4                    VARCHAR2,
        X_attribute5                    VARCHAR2,
        X_attribute6                    VARCHAR2,
        X_attribute7                    VARCHAR2,
        X_attribute8                    VARCHAR2,
        X_attribute9                    VARCHAR2,
        X_attribute10                   VARCHAR2,
        X_attribute11                   VARCHAR2,
        X_attribute12                   VARCHAR2,
        X_attribute13                   VARCHAR2,
        X_attribute14                   VARCHAR2,
        X_attribute15                   VARCHAR2,
        X_We_Rowid                      IN OUT NOCOPY VARCHAR2,
        X_end_item_unit_number          VARCHAR2,
        X_Entity_Type                   NUMBER,
        X_Wip_Entity_Name               VARCHAR2,
        X_Update_Wip_Entities           VARCHAR2,
        X_Schedule_Group_Id             NUMBER,
        X_Build_Sequence                NUMBER,
        X_Line_Id                       NUMBER,
        X_Project_Id                    NUMBER,
        X_Task_Id                       NUMBER,
        X_priority                      NUMBER,
        X_due_date                      DATE,
        x_coproducts_supply             NUMBER,
        x_error_code                    OUT NOCOPY     NUMBER,
        x_error_msg                     OUT NOCOPY     VARCHAR2
) IS

CURSOR C3(we_id NUMBER) IS
        SELECT  rowid
        FROM    WIP_ENTITIES
        WHERE   wip_entity_id = we_id
        AND     organization_id = X_Organization_Id;

dummy       NUMBER;
l_stat_num  NUMBER;

BEGIN

l_stat_num := 10;

    UPDATE  WIP_DISCRETE_JOBS SET
            wip_entity_id                   = X_Wip_Entity_Id,
            organization_id                 = X_Organization_Id,
            last_update_date                = X_Last_Update_Date,
            last_updated_by                 = X_Last_Updated_By,
            last_update_login               = X_Last_Update_Login,
            description                     = X_Description,
            status_type                     = X_Status_Type,
            primary_item_id                 = X_Primary_Item_Id,
            firm_planned_flag               = X_Firm_Planned_Flag,
            job_type                        = X_Job_Type,
            wip_supply_type                 = X_Wip_Supply_Type,
            class_code                      = X_Class_Code,
            material_account                = X_Material_Account,
            material_overhead_account       = X_Material_Overhead_Account,
            resource_account                = X_Resource_Account,
            outside_processing_account      = X_Outside_Processing_Account,
            material_variance_account       = X_Material_Variance_Account,
            resource_variance_account       = X_Resource_Variance_Account,
            outside_proc_variance_account   = X_Outside_Proc_Var_Account,
            std_cost_adjustment_account     = X_Std_Cost_Adjustment_Account,
            overhead_account                = X_Overhead_Account,
            overhead_variance_account       = X_Overhead_Variance_Account,
            scheduled_start_date            = X_Scheduled_Start_Date,
            date_released                   = X_Date_Released,
            scheduled_completion_date       = X_Scheduled_Completion_Date,
            date_completed                  = X_Date_Completed,
            date_closed                     = X_Date_Closed,
            start_quantity                  = X_Start_Quantity,
            overcompletion_tolerance_type   = X_overcompletion_toleran_type,
            overcompletion_tolerance_value  = X_overcompletion_toleran_value,
            quantity_completed              = X_Quantity_Completed,
            quantity_scrapped               = X_Quantity_Scrapped,
            net_quantity                    = X_Net_Quantity,
            bom_reference_id                = X_Bom_Reference_Id,
            routing_reference_id            = X_Routing_Reference_Id,
            common_bom_sequence_id          = X_Common_Bom_Sequence_Id,
            common_routing_sequence_id      = X_Common_Routing_Sequence_Id,
            bom_revision                    = X_Bom_Revision,
            routing_revision                = X_Routing_Revision,
            bom_revision_date               = X_Bom_Revision_Date,
            routing_revision_date           = X_Routing_Revision_Date,
            lot_number                      = X_Lot_Number,
            alternate_bom_designator        = X_Alternate_Bom_Designator,
            alternate_routing_designator    = X_Alternate_Routing_Designator,
            completion_subinventory         = X_Completion_Subinventory,
            completion_locator_id           = X_Completion_Locator_Id,
            demand_class                    = X_Demand_Class,
            attribute_category              = X_Attribute_Category,
            attribute1                      = X_Attribute1,
            attribute2                      = X_Attribute2,
            attribute3                      = X_Attribute3,
            attribute4                      = X_Attribute4,
            attribute5                      = X_Attribute5,
            attribute6                      = X_Attribute6,
            attribute7                      = X_Attribute7,
            attribute8                      = X_Attribute8,
            attribute9                      = X_Attribute9,
            attribute10                     = X_Attribute10,
            attribute11                     = X_Attribute11,
            attribute12                     = X_Attribute12,
            attribute13                     = X_Attribute13,
            attribute14                     = X_Attribute14,
            attribute15                     = X_Attribute15,
            end_item_unit_number            = X_end_item_unit_number,
            schedule_group_id               = X_Schedule_Group_Id,
            build_sequence                  = X_Build_Sequence,
            line_id                         = X_Line_Id,
            project_id                      = X_Project_Id,
            task_id                         = X_Task_Id,
            priority                        = X_priority,
            due_date                        = X_due_date,
            coproducts_supply               = x_coproducts_supply
    WHERE   rowid = X_Rowid;
l_stat_num := 20;
    if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
    end if;

l_stat_num := 30;
    SELECT  count(*) into dummy
    FROM    wip_entities
    WHERE   wip_entity_id = X_Wip_Entity_id;

l_stat_num := 40;
    if dummy = 0 then
        INSERT INTO WIP_ENTITIES(
            wip_entity_id,
            organization_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            wip_entity_name,
            entity_type,
            description,
            primary_item_id,
            gen_object_id
        ) VALUES (
            X_Wip_Entity_Id,
            X_Organization_Id,
            X_Last_Update_Date,
            X_Last_Updated_By,
            X_Creation_Date,
            X_Created_By,
            X_Last_Update_Login,
            X_Wip_Entity_Name,
            X_Entity_Type,
            X_Description,
            X_Primary_Item_Id,
            MTL_GEN_OBJECT_ID_S.nextval);
    else
        IF X_Update_Wip_Entities = 'Y' THEN
l_stat_num := 50;
            OPEN C3(X_Wip_Entity_Id);
            FETCH C3 INTO X_We_Rowid;
            if (C3%NOTFOUND) then
                CLOSE C3;
                Raise NO_DATA_FOUND;
            end if;
            CLOSE C3;

l_stat_num := 60;
            UPDATE  WIP_ENTITIES
            SET
                    wip_entity_id       =   X_Wip_Entity_Id,
                    organization_id     =   X_Organization_Id,
                    last_update_date    =   X_Last_Update_Date,
                    last_updated_by     =   X_Last_Updated_By,
                    last_update_login   =   X_Last_Update_Login,
                    wip_entity_name     =   X_Wip_Entity_Name,
                    entity_type         =   X_Entity_Type,
                    description         =   X_Description,
                    primary_item_id     =   X_Primary_Item_Id
            WHERE   rowid = X_We_Rowid;
l_stat_num := 70;
            if (SQL%NOTFOUND) then
                Raise NO_DATA_FOUND;
            end if;
        END IF;
    end if;
EXCEPTION
    WHEN others THEN
    X_We_Rowid := '';
        x_error_code := SQLCODE;
        x_error_msg := 'WSMDJTHB.Update_Row('||l_stat_num||')'|| substr(SQLERRM,1,200);
END Update_Row;

END WSMPDJOB;

/
