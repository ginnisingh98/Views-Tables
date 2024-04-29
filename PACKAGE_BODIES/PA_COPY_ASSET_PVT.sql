--------------------------------------------------------
--  DDL for Package Body PA_COPY_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COPY_ASSET_PVT" AS
/* $Header: PACCPYAB.pls 120.0.12010000.2 2009/08/20 06:50:21 sgottimu ship $ */


PROCEDURE COPY_ASSET
	(p_cur_project_asset_id IN	    NUMBER,
    p_asset_name            IN	    VARCHAR2,
    p_asset_description     IN      VARCHAR2,
    p_project_asset_type    IN      VARCHAR2,
    p_asset_units           IN      NUMBER DEFAULT NULL,
    p_est_asset_units       IN      NUMBER DEFAULT NULL,
    p_asset_dpis            IN      DATE DEFAULT NULL,
    p_est_asset_dpis        IN      DATE DEFAULT NULL,
    p_asset_number          IN      VARCHAR2 DEFAULT NULL,
    p_copy_assignments      IN      VARCHAR2,
    x_new_project_asset_id     OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2) IS


    CURSOR  assignments_cur IS
    SELECT  *
    FROM    pa_project_asset_assignments
    WHERE   project_asset_id = p_cur_project_asset_id;

    assignments_rec      assignments_cur%ROWTYPE;

    current_asset_rec      pa_project_assets_all%ROWTYPE;

    v_user                      NUMBER := FND_GLOBAL.user_id;
    v_login                     NUMBER := FND_GLOBAL.login_id;



BEGIN
    x_return_status := 'S';



    --Get the current asset information
    SELECT  *
    INTO    current_asset_rec
    FROM    pa_project_assets_all
    WHERE   project_asset_id = p_cur_project_asset_id;


    --Get next project_asset_id sequence value
    SELECT  pa_project_assets_s.NEXTVAL
    INTO    x_new_project_asset_id
    FROM    SYS.DUAL;

    --Insert new project asset, since all validations have passed
    INSERT INTO pa_project_assets_all(
        project_asset_id,
        project_id,
        asset_number,
        asset_name,
        asset_description,
        location_id,
        assigned_to_person_id,
        date_placed_in_service,
        asset_category_id,
        book_type_code,
        asset_units,
        depreciate_flag,
        depreciation_expense_ccid,
        amortize_flag,
        capitalized_flag,
        reverse_flag,
        capital_hold_flag,
        estimated_in_service_date,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login,
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
        org_id,
        asset_key_ccid,
        project_asset_type,
        estimated_cost,
        estimated_asset_units,
        parent_asset_id,
        manufacturer_name,
        model_number,
        tag_number, --Don't copy Tag Number, since it must be unique
        serial_number,
        ret_target_asset_id,
        new_master_flag /* Bug# 8781769 */
        )
    VALUES (
        x_new_project_asset_id,
        current_asset_rec.project_id,
        p_asset_number,
        p_asset_name,
        p_asset_description,
        current_asset_rec.location_id,
        current_asset_rec.assigned_to_person_id,
        p_asset_dpis,
        current_asset_rec.asset_category_id,
        current_asset_rec.book_type_code,
        p_asset_units,
        current_asset_rec.depreciate_flag,
        current_asset_rec.depreciation_expense_ccid,
        current_asset_rec.amortize_flag,
        'N', --Capitalized Flag
        'N', --Reverse Flag
        'N', --Capital Hold Flag
        p_est_asset_dpis,
        SYSDATE, --last_update_date
        v_user, --last_updated_by
        v_user, --created_by
        SYSDATE, --creation_date
        v_login, --last_update_login
        current_asset_rec.attribute_category,
        current_asset_rec.attribute1,
        current_asset_rec.attribute2,
        current_asset_rec.attribute3,
        current_asset_rec.attribute4,
        current_asset_rec.attribute5,
        current_asset_rec.attribute6,
        current_asset_rec.attribute7,
        current_asset_rec.attribute8,
        current_asset_rec.attribute9,
        current_asset_rec.attribute10,
        current_asset_rec.attribute11,
        current_asset_rec.attribute12,
        current_asset_rec.attribute13,
        current_asset_rec.attribute14,
        current_asset_rec.attribute15,
        current_asset_rec.org_id,
        current_asset_rec.asset_key_ccid,
        p_project_asset_type,
        current_asset_rec.estimated_cost,
        p_est_asset_units,
        current_asset_rec.parent_asset_id,
        current_asset_rec.manufacturer_name,
        current_asset_rec.model_number,
        NULL, --current_asset_rec.tag_number, --Don't copy Tag Number, since it must be unique
        current_asset_rec.serial_number,
        current_asset_rec.ret_target_asset_id,
        nvl(current_asset_rec.new_master_flag,'N')
        );


        --Copy Asset Assignments if indicated
        IF SUBSTR(p_copy_assignments,1,1) = 'Y' THEN

            FOR assignments_rec IN assignments_cur LOOP

                --Insert new asset assignments
                INSERT INTO pa_project_asset_assignments(
                    project_asset_id,
                    task_id,
                    project_id,
                    last_update_date,
                    last_updated_by,
                    created_by,
                    creation_date,
                    last_update_login,
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
                    attribute15
                    )
                VALUES (
                    x_new_project_asset_id,
                    assignments_rec.task_id,
                    assignments_rec.project_id,
                    SYSDATE, --last_update_date
                    v_user, --last_updated_by
                    v_user, --created_by
                    SYSDATE, --creation_date
                    v_login, --last_update_login
                    current_asset_rec.attribute_category,
                    current_asset_rec.attribute1,
                    current_asset_rec.attribute2,
                    current_asset_rec.attribute3,
                    current_asset_rec.attribute4,
                    current_asset_rec.attribute5,
                    current_asset_rec.attribute6,
                    current_asset_rec.attribute7,
                    current_asset_rec.attribute8,
                    current_asset_rec.attribute9,
                    current_asset_rec.attribute10,
                    current_asset_rec.attribute11,
                    current_asset_rec.attribute12,
                    current_asset_rec.attribute13,
                    current_asset_rec.attribute14,
                    current_asset_rec.attribute15
                    );
            END LOOP; --Asset Assignments
        END IF; --Copy Assignments = 'Y'


EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_return_status := 'U';
        x_msg_data := 'Project asset id '||p_cur_project_asset_id||' not found. '||SQLCODE||' '||SQLERRM;
        RAISE;


    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_data := 'Unexpected error for project asset id '||p_cur_project_asset_id||': '||SQLCODE||' '||SQLERRM;
        RAISE;


END COPY_ASSET;


END PA_COPY_ASSET_PVT;

/
