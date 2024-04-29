--------------------------------------------------------
--  DDL for Package Body AHL_UMP_NONROUTINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_NONROUTINES_PVT" AS
/* $Header: AHLVNRTB.pls 120.51.12010000.7 2010/04/26 10:37:48 apattark ship $ */

------------------------------------
-- Common constants and variables --
------------------------------------
l_dummy_varchar                 VARCHAR2(1);
l_dummy_number                  NUMBER;
G_SR_OPEN_STATUS_ID CONSTANT    NUMBER      := 1;

-- Yes/no flags
G_YES_FLAG         CONSTANT  VARCHAR2(1) := 'Y';
G_NO_FLAG          CONSTANT  VARCHAR2(1) := 'N';

-- FND Logging Constants
G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_DEBUG_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

----------------------------------
-- Non-spec Function Signatures --
----------------------------------
FUNCTION Is_MEL_CDL_Approved
(
    p_unit_effectivity_id   NUMBER
)
RETURN BOOLEAN;

-----------------------------------
-- Non-spec Procedure Signatures --
-----------------------------------
PROCEDURE Validate_SR_Details
(
    p_x_nonroutine_rec IN OUT NOCOPY NonRoutine_Rec_Type,
    p_dml_operation IN VARCHAR2
);

PROCEDURE Validate_UE_Details
(
    p_x_nonroutine_rec      IN OUT NOCOPY NonRoutine_Rec_Type,
    p_unit_effectivity_id   IN NUMBER,
    p_dml_operation         IN VARCHAR2
);

PROCEDURE Get_Ata_Sequence
(
    p_unit_effectivity_id   IN          NUMBER,
    p_ata_code              IN          VARCHAR2,
    x_ata_sequence_id       OUT NOCOPY  NUMBER
);

/* Moved to specification
PROCEDURE Process_MO_procedures
(
    p_unit_effectivity_id   IN          NUMBER,
    p_unit_deferral_id      IN          NUMBER,
    p_unit_deferral_ovn     IN          NUMBER,
    p_ata_sequence_id       IN          NUMBER,
    p_cs_incident_id        IN          NUMBER,
    p_csi_item_instance_id  IN          NUMBER);
*/

------------------------------
-- Spec Procedure Create_SR --
------------------------------
PROCEDURE Create_SR
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_nonroutine_rec          IN OUT NOCOPY   NonRoutine_Rec_Type
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Create_SR';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    -- Define cursors
    l_unit_effectivity_id       NUMBER;
    l_ata_sequence_id           NUMBER;
    l_deferral_id               NUMBER;
    l_row_id                    VARCHAR2(2000);

    l_service_request_rec       CS_SERVICEREQUEST_PUB.service_request_rec_type;
    l_notes_table               CS_ServiceRequest_PUB.notes_table;
    l_contacts_table            CS_ServiceRequest_PUB.contacts_table;

    l_inventory_item_id         NUMBER;
    l_serial_number             VARCHAR2(30);
    l_inv_master_org_id         NUMBER;

    l_individual_owner          NUMBER;
    l_group_owner               NUMBER;
    l_individual_type           VARCHAR2(30);

    l_workflow_process_id       NUMBER;
    l_interaction_id            NUMBER;

    l_cs_incident_id            NUMBER;
    l_ata_rep_time              NUMBER;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Create_SR_SP;

    -- Initialize return status to success before any code logic/validation
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
        FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Log API entry point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;
    -- API body starts here

    Validate_SR_Details
    (
        p_x_nonroutine_rec  => p_x_nonroutine_rec,
        p_dml_operation     => 'C'
    );

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Initialize the SR record.
    CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

    -- Assign the SR rec values
    l_service_request_rec.request_date          := sysdate;
    IF (p_x_nonroutine_rec.incident_date IS NULL OR p_x_nonroutine_rec.incident_date = FND_API.G_MISS_DATE)
    THEN
        l_service_request_rec.incident_occurred_date := l_service_request_rec.request_date;
    ELSE
        l_service_request_rec.incident_occurred_date := p_x_nonroutine_rec.incident_date;
        -- set request_date to be incident_date when incident_date is not null
        -- to fix issue raised in bug# 7697685
        l_service_request_rec.request_date           := p_x_nonroutine_rec.incident_date;

    END IF;
    l_service_request_rec.type_id               := p_x_nonroutine_rec.type_id;
    l_service_request_rec.status_id             := p_x_nonroutine_rec.status_id;
    l_service_request_rec.caller_type           := p_x_nonroutine_rec.customer_type;
    l_service_request_rec.customer_id           := p_x_nonroutine_rec.customer_id;
    l_service_request_rec.severity_id           := p_x_nonroutine_rec.severity_id;
    l_service_request_rec.urgency_id            := p_x_nonroutine_rec.urgency_id;
    l_service_request_rec.problem_code          := p_x_nonroutine_rec.problem_code;
    l_service_request_rec.summary               := p_x_nonroutine_rec.problem_summary;

    --AJPRASAN::DFF Project, 18-Feb-2010, added DFF attributes to local record for Creating Service Request
    l_service_request_rec.request_context       := p_x_nonroutine_rec.request_context;
    l_service_request_rec.request_attribute_1    := p_x_nonroutine_rec.request_attribute1;
    l_service_request_rec.request_attribute_2    := p_x_nonroutine_rec.request_attribute2;
    l_service_request_rec.request_attribute_3    := p_x_nonroutine_rec.request_attribute3;
    l_service_request_rec.request_attribute_4    := p_x_nonroutine_rec.request_attribute4;
    l_service_request_rec.request_attribute_5    := p_x_nonroutine_rec.request_attribute5;
    l_service_request_rec.request_attribute_6    := p_x_nonroutine_rec.request_attribute6;
    l_service_request_rec.request_attribute_7    := p_x_nonroutine_rec.request_attribute7;
    l_service_request_rec.request_attribute_8    := p_x_nonroutine_rec.request_attribute8;
    l_service_request_rec.request_attribute_9    := p_x_nonroutine_rec.request_attribute9;
    l_service_request_rec.request_attribute_10    := p_x_nonroutine_rec.request_attribute10;
    l_service_request_rec.request_attribute_11   := p_x_nonroutine_rec.request_attribute11;
    l_service_request_rec.request_attribute_12   := p_x_nonroutine_rec.request_attribute12;
    l_service_request_rec.request_attribute_13   := p_x_nonroutine_rec.request_attribute13;
    l_service_request_rec.request_attribute_14   := p_x_nonroutine_rec.request_attribute14;
    l_service_request_rec.request_attribute_15   := p_x_nonroutine_rec.request_attribute15;

    SELECT  inventory_item_id,
            inventory_item_id,
            inv_master_organization_id
    INTO    p_x_nonroutine_rec.inventory_item_id,
            l_service_request_rec.inventory_item_id,
            l_service_request_rec.inventory_org_id
    FROM    csi_item_instances
    WHERE   instance_id = p_x_nonroutine_rec.instance_id;

    l_service_request_rec.customer_product_id   := p_x_nonroutine_rec.instance_id;
    l_service_request_rec.creation_program_code := 'AHL_NONROUTINE';

    -- Handle the contact if any
    IF
    (
        p_x_nonroutine_rec.contact_type IS NOT NULL AND p_x_nonroutine_rec.contact_type <> FND_API.G_MISS_CHAR
        AND
        p_x_nonroutine_rec.contact_id IS NOT NULL AND p_x_nonroutine_rec.contact_id <> FND_API.G_MISS_NUM
    )
    THEN
        l_contacts_table(1).contact_type            := p_x_nonroutine_rec.contact_type;
        l_contacts_table(1).party_id                := p_x_nonroutine_rec.contact_id;
        l_contacts_table(1).primary_flag            := 'Y';
    END IF;

    l_service_request_rec.resolution_code       := p_x_nonroutine_rec.resolution_code;
    l_service_request_rec.exp_resolution_date   := p_x_nonroutine_rec.expected_resolution_date;
    l_service_request_rec.act_resolution_date   := p_x_nonroutine_rec.actual_resolution_date;

    -- Call to Service Request API
    CS_SERVICEREQUEST_PUB.Create_ServiceRequest
    (
        p_api_version           => 3.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_resp_appl_id          => fnd_global.resp_appl_id,
        p_resp_id               => fnd_global.resp_id,
        p_user_id               => fnd_global.user_id,
        p_login_id              => fnd_global.login_id,
        p_org_id                => NULL,
        p_request_id            => p_x_nonroutine_rec.incident_id,
        p_request_number        => NULL,
        p_service_request_rec   => l_service_request_rec,
        p_notes                 => l_notes_table,
        p_contacts              => l_contacts_table,
        p_auto_assign           => 'N',
        x_request_id            => l_cs_incident_id,
        x_request_number        => p_x_nonroutine_rec.incident_number,
        x_interaction_id        => l_interaction_id,
        x_workflow_process_id   => l_workflow_process_id,
        x_individual_owner      => l_individual_owner,
        x_group_owner           => l_group_owner,
        x_individual_type       => l_individual_type
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        IF (G_DEBUG_UEXP >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_UEXP,
                l_debug_module,
                'Call to CS_SERVICEREQUEST_PUB.Create_ServiceRequest failed...'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- l_cs_incident_id is anyway expected to be the same as p_x_nonroutine_rec.incident_id, still to be extra sure...
    p_x_nonroutine_rec.incident_id  := l_cs_incident_id;
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'New non-routine created ['||p_x_nonroutine_rec.incident_id||']'
        );
    END IF;

    -- Retrieve the UE created by the SR, and update the necessary information...
    SELECT  unit_effectivity_id, unit_effectivity_id, object_version_number
    INTO    l_unit_effectivity_id, p_x_nonroutine_rec.unit_effectivity_id, p_x_nonroutine_rec.ue_object_version_number
    FROM    ahl_unit_effectivities_b
    WHERE   object_type = 'SR' and
            cs_incident_id = p_x_nonroutine_rec.incident_id;

    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'UE ['||l_unit_effectivity_id||'] is created for non-routine ['||p_x_nonroutine_rec.incident_id||']'
        );
    END IF;

    -- Validate NR specific UE information passed from the frontend...
    Validate_UE_Details(p_x_nonroutine_rec, l_unit_effectivity_id, 'C');

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'UE validations for non-routines done'
        );
    END IF;

    -- Update the UE record with the NR specific information
    UPDATE  ahl_unit_effectivities_b
    SET     log_series_code         = p_x_nonroutine_rec.log_series_code,
            log_series_number       = p_x_nonroutine_rec.log_series_number,
            flight_number           = p_x_nonroutine_rec.flight_number,
            -- clear_station_org_id    = p_x_nonroutine_rec.clear_station_org_id,
            -- clear_station_dept_id   = p_x_nonroutine_rec.clear_station_dept_id,
            mel_cdl_type_code       = p_x_nonroutine_rec.mel_cdl_type_code,
            position_path_id        = p_x_nonroutine_rec.position_path_id,
            ata_code                = p_x_nonroutine_rec.ata_code,
            unit_config_header_id   = p_x_nonroutine_rec.unit_config_header_id
    WHERE   unit_effectivity_id     = l_unit_effectivity_id;

    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'UE details updated for MEL/CDL qualification'
        );
    END IF;

    IF (p_x_nonroutine_rec.mel_cdl_qual_flag ='C')
    THEN
        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_STMT,
                l_debug_module,
                'Attach MEL/CDL instructions for non-routines'
            );
        END IF;

        /* Behavior of Unit, Item, Serial and Instance LOVs in "Unit / Component Details" sub-header
         * validate unit is availale and active
         * Behavior of Log Series and Number in "Unit / Component Details" sub-header
         * validate log_series is not null
         */
        IF (p_x_nonroutine_rec.unit_config_header_id is null or p_x_nonroutine_rec.unit_config_header_id = FND_API.G_MISS_NUM)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_UNIT_MAND');
            -- Unit is mandatory for associating MEL/CDL instructions
            FND_MSG_PUB.ADD;
        END IF;

        IF (
            p_x_nonroutine_rec.log_series_code IS NULL OR p_x_nonroutine_rec.log_series_code = FND_API.G_MISS_CHAR
            AND
            p_x_nonroutine_rec.log_series_number IS NULL OR p_x_nonroutine_rec.log_series_number = FND_API.G_MISS_NUM
           )
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_MAND');
            -- Log Series and Number are mandatory for associating MEL/CDL instructions
            FND_MSG_PUB.ADD;
        END IF;

        -- Retrieve relevant MEL/CDL ata sequence
        Get_Ata_Sequence(l_unit_effectivity_id,p_x_nonroutine_rec.ata_code, l_ata_sequence_id);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF (x_msg_count > 0)
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_ata_sequence_id IS NOT NULL)
        THEN
            -- Bug #5230869 - validate inc_occ_date + rep_time >= inc_date
            SELECT repcat.repair_time
            INTO l_ata_rep_time
            FROM ahl_mel_cdl_ata_sequences ata, ahl_repair_categories repcat
            WHERE ata.repair_category_id = repcat.repair_category_id and ata.mel_cdl_ata_sequence_id = l_ata_sequence_id;

            IF (NVL(l_ata_rep_time, 0) <> 0 AND trunc(l_service_request_rec.incident_occurred_date) + trunc(l_ata_rep_time/24) < trunc(l_service_request_rec.request_date))
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_NO_ACCOM');
                -- Repair Time of the associated MEL/CDL Instructions cannot accomodate resolution of the Non-routine before Log Date
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
            THEN
                fnd_log.string
                (
                    G_DEBUG_STMT,
                    l_debug_module,
                    'Qualification [ata_sequence_id='||l_ata_sequence_id||'] computed from [unit_config_header_id='||
                    p_x_nonroutine_rec.unit_config_header_id||'][mel_cdl_type_code='||p_x_nonroutine_rec.mel_cdl_type_code||
                    '][position_path_id='||p_x_nonroutine_rec.position_path_id||'][ata_code='||p_x_nonroutine_rec.ata_code||']'
                );
            END IF;

            AHL_UNIT_DEFERRALS_PKG.INSERT_ROW
            (
                X_ROWID                 => l_row_id,
                X_UNIT_DEFERRAL_ID      => l_deferral_id,
                X_ATTRIBUTE14           => null,
                X_ATTRIBUTE15           => null,
                X_ATTRIBUTE_CATEGORY    => null,
                X_ATTRIBUTE1            => null,
                X_ATTRIBUTE2            => null,
                X_ATTRIBUTE3            => null,
                X_ATTRIBUTE4            => null,
                X_ATTRIBUTE5            => null,
                X_ATTRIBUTE6            => null,
                X_ATTRIBUTE7            => null,
                X_ATTRIBUTE8            => null,
                X_ATTRIBUTE9            => null,
                X_ATTRIBUTE10           => null,
                X_ATTRIBUTE11           => null,
                X_ATTRIBUTE12           => null,
                X_ATTRIBUTE13           => null,
                X_AFFECT_DUE_CALC_FLAG  => 'N',
                X_DEFER_REASON_CODE     => null,
                X_USER_DEFERRAL_TYPE    => null,
                X_DEFERRAL_EFFECTIVE_ON => l_service_request_rec.incident_occurred_date,
                X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_id,
                X_UNIT_DEFERRAL_TYPE    => p_x_nonroutine_rec.mel_cdl_type_code,
                X_SET_DUE_DATE          => null,
                X_APPROVAL_STATUS_CODE  => 'DRAFT',
                X_SKIP_MR_FLAG          => null,
                X_OBJECT_VERSION_NUMBER => 1,
                X_ATA_SEQUENCE_ID       => l_ata_sequence_id,
                X_REMARKS               => null,
                X_APPROVER_NOTES        => null,
                X_CREATION_DATE         => sysdate,
                X_CREATED_BY            => fnd_global.user_id,
                X_LAST_UPDATE_DATE      => sysdate,
                X_LAST_UPDATED_BY       => fnd_global.user_id,
                X_LAST_UPDATE_LOGIN     => fnd_global.login_id
            );

            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
            THEN
                fnd_log.string
                (
                    G_DEBUG_STMT,
                    l_debug_module,
                    'Insert unit_deferral ['||l_deferral_id||'] with relevant MEL/CDL qualification information'
                );
            END IF;
        END IF;
    END IF;

    -- API body ends here
    -- Log API exit point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Commit if p_commit = FND_API.G_TRUE
    IF FND_API.TO_BOOLEAN(p_commit)
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get
    (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Create_SR_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Create_SR_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Create_SR_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Create_SR',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Create_SR;

------------------------------
-- Spec Procedure Update_SR --
------------------------------
PROCEDURE Update_SR
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_nonroutine_rec          IN OUT NOCOPY   NonRoutine_Rec_Type
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Update_SR';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    -- Define cursors
    l_unit_effectivity_id       NUMBER;
    l_ata_sequence_id           NUMBER;

    CURSOR get_ue_details
    (
        c_incident_id number
    )
    IS
    SELECT  unit_effectivity_id, object_version_number
    FROM    ahl_unit_effectivities_b
    WHERE   object_type = 'SR' and
            cs_incident_id = c_incident_id and
            nvl(status_code, 'X') <> 'DEFERRED';

    CURSOR get_deferral_rec
    (
        c_unit_effectivity_id number
    )
    IS
    SELECT  *
    FROM    ahl_unit_deferrals_vl
    WHERE   unit_effectivity_id = c_unit_effectivity_id AND
            unit_deferral_type IN ('MEL','CDL');
    -- may need to add more validations here to get the right deferral record...

    l_deferral_rec              get_deferral_rec%rowtype;
    l_deferral_id               NUMBER;
    l_row_id                    VARCHAR2(2000);

    l_service_request_rec       CS_SERVICEREQUEST_PUB.service_request_rec_type;
    l_notes_table               CS_ServiceRequest_PUB.notes_table;
    l_contacts_table            CS_ServiceRequest_PUB.contacts_table;

    l_contact_primary_flag      CONSTANT VARCHAR2(1) := 'Y';

    l_workflow_process_id       NUMBER ;
    l_interaction_id            NUMBER ;
    l_unit_instance             NUMBER;
    l_ue_ovn                    NUMBER;
    l_ata_rep_time              NUMBER;

    CURSOR get_contact_details
    (
        c_incident_id number
    )
    IS
    SELECT  contact_type, party_id
    FROM    CS_HZ_SR_CONTACT_POINTS
    WHERE   incident_id = c_incident_id
    AND     primary_flag = 'Y';

    l_contact_rec               get_contact_details%rowtype;

    -- Balaji added for the bug that SR ovn is not correctly returned from the call
    -- to CS_SERVICEREQUEST_PUB.Update_ServiceRequest.
    -- Begin change
    CURSOR c_get_sr_ovn(c_incident_id NUMBER)
    IS
    SELECT object_version_number
    FROM CS_INCIDENTS
    WHERE incident_id = c_incident_id;
    -- End change
BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Update_SR_SP;

    -- Initialize return status to success before any code logic/validation
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
        FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Log API entry point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;
    -- API body starts here

    Validate_SR_Details
    (
        p_x_nonroutine_rec  => p_x_nonroutine_rec,
        p_dml_operation     => 'U'
    );

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Initialize the SR record.
    CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

    l_service_request_rec.type_id               := p_x_nonroutine_rec.type_id;
    l_service_request_rec.status_id             := p_x_nonroutine_rec.status_id;
    -- l_service_request_rec.caller_type           := p_x_nonroutine_rec.customer_type;
    l_service_request_rec.customer_id           := p_x_nonroutine_rec.customer_id;
    l_service_request_rec.severity_id           := p_x_nonroutine_rec.severity_id;
    l_service_request_rec.urgency_id            := p_x_nonroutine_rec.urgency_id;
    l_service_request_rec.problem_code          := p_x_nonroutine_rec.problem_code;
    l_service_request_rec.summary               := p_x_nonroutine_rec.problem_summary;

    --AJPRASAN::DFF Project, 18-Feb-2010, added DFF attributes to local record for Updating Service Request
    l_service_request_rec.request_context       := p_x_nonroutine_rec.request_context;
    l_service_request_rec.request_attribute_1   := p_x_nonroutine_rec.request_attribute1;
    l_service_request_rec.request_attribute_2   := p_x_nonroutine_rec.request_attribute2;
    l_service_request_rec.request_attribute_3   := p_x_nonroutine_rec.request_attribute3;
    l_service_request_rec.request_attribute_4   := p_x_nonroutine_rec.request_attribute4;
    l_service_request_rec.request_attribute_5   := p_x_nonroutine_rec.request_attribute5;
    l_service_request_rec.request_attribute_6   := p_x_nonroutine_rec.request_attribute6;
    l_service_request_rec.request_attribute_7   := p_x_nonroutine_rec.request_attribute7;
    l_service_request_rec.request_attribute_8   := p_x_nonroutine_rec.request_attribute8;
    l_service_request_rec.request_attribute_9   := p_x_nonroutine_rec.request_attribute9;
    l_service_request_rec.request_attribute_10  := p_x_nonroutine_rec.request_attribute10;
    l_service_request_rec.request_attribute_11  := p_x_nonroutine_rec.request_attribute11;
    l_service_request_rec.request_attribute_12  := p_x_nonroutine_rec.request_attribute12;
    l_service_request_rec.request_attribute_13  := p_x_nonroutine_rec.request_attribute13;
    l_service_request_rec.request_attribute_14  := p_x_nonroutine_rec.request_attribute14;
    l_service_request_rec.request_attribute_15  := p_x_nonroutine_rec.request_attribute15;

    SELECT  incident_date, incident_occurred_date, incident_occurred_date
    INTO    l_service_request_rec.request_date, l_service_request_rec.incident_occurred_date, p_x_nonroutine_rec.incident_date
    FROM    cs_incidents_all_b
    WHERE   incident_id = p_x_nonroutine_rec.incident_id;

    --apattark start for fp bug #9557752
    /*
    SELECT  p_x_nonroutine_rec.inventory_item_id,
            inv_master_organization_id
    INTO    l_service_request_rec.inventory_item_id,
            l_service_request_rec.inventory_org_id
    FROM    csi_item_instances
    WHERE   instance_id = p_x_nonroutine_rec.instance_id;
    */
   --apattark end for fp bug #9557752

    l_service_request_rec.customer_product_id   := p_x_nonroutine_rec.instance_id;
    l_service_request_rec.creation_program_code := 'AHL_NONROUTINE';

    -- Handle the contact if any (code below changed per new R12 CS package's CS_SRCONTACT_PKG.check_duplicates() method)
    IF
    (
        p_x_nonroutine_rec.contact_type IS NOT NULL AND p_x_nonroutine_rec.contact_type <> FND_API.G_MISS_CHAR
        AND
        p_x_nonroutine_rec.contact_id IS NOT NULL AND p_x_nonroutine_rec.contact_id <> FND_API.G_MISS_NUM
    )
    THEN
        OPEN get_contact_details(p_x_nonroutine_rec.incident_id);
        FETCH get_contact_details INTO l_contact_rec;
        IF (get_contact_details%NOTFOUND OR (get_contact_details%FOUND AND (l_contact_rec.contact_type <> p_x_nonroutine_rec.contact_type OR l_contact_rec.party_id <> p_x_nonroutine_rec.contact_id)))
        THEN
            l_contacts_table(1).contact_type            := p_x_nonroutine_rec.contact_type;
            l_contacts_table(1).party_id                := p_x_nonroutine_rec.contact_id;
            l_contacts_table(1).primary_flag            := 'Y';
        END IF;
        CLOSE get_contact_details;
    END IF;

    l_service_request_rec.resolution_code       := p_x_nonroutine_rec.resolution_code;
    l_service_request_rec.exp_resolution_date   := p_x_nonroutine_rec.expected_resolution_date;
    l_service_request_rec.act_resolution_date   := p_x_nonroutine_rec.actual_resolution_date;

    -- Call to Service Request API
    CS_SERVICEREQUEST_PUB.Update_ServiceRequest
    (
        p_api_version            => 3.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        p_request_id             => p_x_nonroutine_rec.incident_id,
        p_request_number         => NULL,
        p_audit_comments         => NULL,
        p_object_version_number  => p_x_nonroutine_rec.incident_object_version_number,
        p_resp_appl_id           => fnd_global.resp_appl_id,
        p_resp_id                => fnd_global.resp_id,
        p_last_updated_by        => fnd_global.user_id,
        p_last_update_login      => fnd_global.login_id,
        p_last_update_date       => sysdate,
        p_service_request_rec    => l_service_request_rec,
        p_notes                  => l_notes_table,
        p_contacts               => l_contacts_table,
        p_called_by_workflow     => NULL,
        p_workflow_process_id    => NULL,
        x_workflow_process_id    => l_workflow_process_id,
        x_interaction_id         => l_interaction_id
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        IF (G_DEBUG_UEXP >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_UEXP,
                l_debug_module,
                'Call to CS_SERVICEREQUEST_PUB.Update_ServiceRequest failed...'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE

        IF (G_DEBUG_UEXP >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_UEXP,
                l_debug_module,
                'l_msg_count->'||l_msg_count||' , '||'l_msg_data->'||l_msg_data
            );
            fnd_log.string
            (
                G_DEBUG_UEXP,
                l_debug_module,
                'l_return_status->'||l_return_status
            );
        END IF;
      -- re-initialize stack to get rid of warnings.
      FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Retrieve ue_id and ovn accordingly...
    IF (p_x_nonroutine_rec.unit_effectivity_id IS NOT NULL AND p_x_nonroutine_rec.unit_effectivity_id <> FND_API.G_MISS_NUM)
    THEN
        SELECT  object_version_number
        INTO    p_x_nonroutine_rec.ue_object_version_number
        FROM    ahl_unit_effectivities_b
        WHERE   unit_effectivity_id = p_x_nonroutine_rec.unit_effectivity_id;
    ELSE
        OPEN get_ue_details (p_x_nonroutine_rec.incident_id);
        FETCH get_ue_details INTO p_x_nonroutine_rec.unit_effectivity_id, p_x_nonroutine_rec.ue_object_version_number;
        CLOSE get_ue_details;
    END IF;

    l_unit_effectivity_id := p_x_nonroutine_rec.unit_effectivity_id;

    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'UE ['||l_unit_effectivity_id||'] is updated for non-routine ['||p_x_nonroutine_rec.incident_id||']'
        );
    END IF;

    -- Validate NR specific UE information passed from the frontend...
    Validate_UE_Details(p_x_nonroutine_rec, l_unit_effectivity_id, 'U');

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_STMT,
            l_debug_module,
            'UE validations for MEL/CDL non-routines done'
        );
    END IF;

    -- Update the UE record with the NR specific information
    -- Note: Log Series, Number cannot be modified once created...
    UPDATE  ahl_unit_effectivities_b
    SET     log_series_code         = p_x_nonroutine_rec.log_series_code,
            log_series_number       = p_x_nonroutine_rec.log_series_number,
            flight_number           = p_x_nonroutine_rec.flight_number,
            -- clear_station_org_id    = p_x_nonroutine_rec.clear_station_org_id,
            -- clear_station_dept_id   = p_x_nonroutine_rec.clear_station_dept_id,
            unit_config_header_id   = p_x_nonroutine_rec.unit_config_header_id
    WHERE   unit_effectivity_id     = l_unit_effectivity_id;

    IF NOT Is_MEL_CDL_Approved(l_unit_effectivity_id)
    THEN
        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_STMT,
                l_debug_module,
                'UE ['||l_unit_effectivity_id||'] is not MEL/CDL approved / pending approval'
            );
        END IF;

        -- Update the UE record with the MEL/CDL Qualification specific information
        UPDATE  ahl_unit_effectivities_b
        SET     mel_cdl_type_code       = p_x_nonroutine_rec.mel_cdl_type_code,
                position_path_id        = p_x_nonroutine_rec.position_path_id,
                ata_code                = p_x_nonroutine_rec.ata_code
        WHERE   unit_effectivity_id     = l_unit_effectivity_id;

        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_STMT,
                l_debug_module,
                'UE details updated for MEL/CDL qualification'
            );
        END IF;

        IF (p_x_nonroutine_rec.mel_cdl_qual_flag ='C')
        THEN
            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
            THEN
                fnd_log.string
                (
                    G_DEBUG_STMT,
                    l_debug_module,
                    'Attach/Change MEL/CDL instructions for non-routines'
                );
            END IF;

            /* Behavior of Unit, Item, Serial and Instance LOVs in "Unit / Component Details" sub-header
             * validate unit is availale and active
             * Behavior of Log Series and Number in "Unit / Component Details" sub-header
             * validate log_series is not null
             */
            IF (p_x_nonroutine_rec.unit_config_header_id is null or p_x_nonroutine_rec.unit_config_header_id = FND_API.G_MISS_NUM)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_UNIT_MAND');
                -- Unit is mandatory for associating MEL/CDL instructions
                FND_MSG_PUB.ADD;
            END IF;

            IF (
                p_x_nonroutine_rec.log_series_code IS NULL OR p_x_nonroutine_rec.log_series_code = FND_API.G_MISS_CHAR
                AND
                p_x_nonroutine_rec.log_series_number IS NULL OR p_x_nonroutine_rec.log_series_number = FND_API.G_MISS_NUM
               )
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_MAND');
                -- Log Series and Number are mandatory for associating MEL/CDL instructions
                FND_MSG_PUB.ADD;
            END IF;

            -- Retrieve relevant MEL/CDL ata sequence
            Get_Ata_Sequence(l_unit_effectivity_id,p_x_nonroutine_rec.ata_code, l_ata_sequence_id);

            -- Check Error Message stack.
            x_msg_count := FND_MSG_PUB.count_msg;
            IF (x_msg_count > 0)
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (l_ata_sequence_id IS NOT NULL)
            THEN
                -- Bug #5230869 - validate inc_occ_date + rep_time >= inc_date
                SELECT repcat.repair_time
                INTO l_ata_rep_time
                FROM ahl_mel_cdl_ata_sequences ata, ahl_repair_categories repcat
                WHERE ata.repair_category_id = repcat.repair_category_id and ata.mel_cdl_ata_sequence_id = l_ata_sequence_id;

                IF (NVL(l_ata_rep_time, 0) <> 0 AND trunc(l_service_request_rec.incident_occurred_date) + trunc(l_ata_rep_time/24) < trunc(l_service_request_rec.request_date))
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_NO_ACCOM');
                    -- Repair Time of the associated MEL/CDL Instructions cannot accomodate resolution of the Non-routine before Log Date
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                THEN
                    fnd_log.string
                    (
                        G_DEBUG_STMT,
                        l_debug_module,
                        'Qualification ata_sequence_id ['||l_ata_sequence_id||'] computed from unit_config_header_id ['||p_x_nonroutine_rec.unit_config_header_id||'],
                        mel_cdl_type_code ['||p_x_nonroutine_rec.mel_cdl_type_code||'],position_path_id ['||p_x_nonroutine_rec.position_path_id||']
                        ,ata_code ['||p_x_nonroutine_rec.ata_code||']'
                    );
                END IF;

                OPEN get_deferral_rec(l_unit_effectivity_id);
                FETCH get_deferral_rec INTO l_deferral_rec;
                IF (get_deferral_rec%FOUND)
                THEN
                    AHL_UNIT_DEFERRALS_PKG.UPDATE_ROW
                    (
                        X_UNIT_DEFERRAL_ID      => l_deferral_rec.unit_deferral_id,
                        X_ATTRIBUTE14           => l_deferral_rec.attribute14,
                        X_ATTRIBUTE15           => l_deferral_rec.attribute15,
                        X_ATTRIBUTE_CATEGORY    => l_deferral_rec.attribute_category,
                        X_ATTRIBUTE1            => l_deferral_rec.attribute1,
                        X_ATTRIBUTE2            => l_deferral_rec.attribute2,
                        X_ATTRIBUTE3            => l_deferral_rec.attribute3,
                        X_ATTRIBUTE4            => l_deferral_rec.attribute4,
                        X_ATTRIBUTE5            => l_deferral_rec.attribute5,
                        X_ATTRIBUTE6            => l_deferral_rec.attribute6,
                        X_ATTRIBUTE7            => l_deferral_rec.attribute7,
                        X_ATTRIBUTE8            => l_deferral_rec.attribute8,
                        X_ATTRIBUTE9            => l_deferral_rec.attribute9,
                        X_ATTRIBUTE10           => l_deferral_rec.attribute10,
                        X_ATTRIBUTE11           => l_deferral_rec.attribute11,
                        X_ATTRIBUTE12           => l_deferral_rec.attribute12,
                        X_ATTRIBUTE13           => l_deferral_rec.attribute13,
                        X_AFFECT_DUE_CALC_FLAG  => 'N',
                        X_DEFER_REASON_CODE     => l_deferral_rec.defer_reason_code,
                        X_DEFERRAL_EFFECTIVE_ON => l_deferral_rec.deferral_effective_on,
                        X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_id,
                        X_UNIT_DEFERRAL_TYPE    => p_x_nonroutine_rec.mel_cdl_type_code,
                        X_SET_DUE_DATE          => l_deferral_rec.set_due_date,
                        X_APPROVAL_STATUS_CODE  => 'DRAFT',
                        X_SKIP_MR_FLAG          => l_deferral_rec.skip_mr_flag,
                        X_OBJECT_VERSION_NUMBER => l_deferral_rec.object_version_number + 1,
                        X_ATA_SEQUENCE_ID       => l_ata_sequence_id,
                        X_REMARKS               => l_deferral_rec.remarks,
                        X_APPROVER_NOTES        => l_deferral_rec.approver_notes,
                        X_USER_DEFERRAL_TYPE    => null,
                        X_LAST_UPDATE_DATE      => sysdate,
                        X_LAST_UPDATED_BY       => fnd_global.user_id,
                        X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                    );

                    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                    THEN
                        fnd_log.string
                        (
                            G_DEBUG_STMT,
                            l_debug_module,
                            'Updated unit_deferral ['||l_deferral_rec.unit_deferral_id||'] with relevant MEL/CDL qualification information'
                        );
                    END IF;
                ELSE
                    AHL_UNIT_DEFERRALS_PKG.INSERT_ROW
                    (
                        X_ROWID                 => l_row_id,
                        X_UNIT_DEFERRAL_ID      => l_deferral_id,
                        X_ATTRIBUTE14           => null,
                        X_ATTRIBUTE15           => null,
                        X_ATTRIBUTE_CATEGORY    => null,
                        X_ATTRIBUTE1            => null,
                        X_ATTRIBUTE2            => null,
                        X_ATTRIBUTE3            => null,
                        X_ATTRIBUTE4            => null,
                        X_ATTRIBUTE5            => null,
                        X_ATTRIBUTE6            => null,
                        X_ATTRIBUTE7            => null,
                        X_ATTRIBUTE8            => null,
                        X_ATTRIBUTE9            => null,
                        X_ATTRIBUTE10           => null,
                        X_ATTRIBUTE11           => null,
                        X_ATTRIBUTE12           => null,
                        X_ATTRIBUTE13           => null,
                        X_AFFECT_DUE_CALC_FLAG  => 'N',
                        X_DEFER_REASON_CODE     => null,
                        X_DEFERRAL_EFFECTIVE_ON => l_service_request_rec.incident_occurred_date,
                        X_UNIT_EFFECTIVITY_ID   => l_unit_effectivity_id,
                        X_UNIT_DEFERRAL_TYPE    => p_x_nonroutine_rec.mel_cdl_type_code,
                        X_SET_DUE_DATE          => null,
                        X_APPROVAL_STATUS_CODE  => 'DRAFT',
                        X_SKIP_MR_FLAG          => null,
                        X_OBJECT_VERSION_NUMBER => 1,
                        X_ATA_SEQUENCE_ID       => l_ata_sequence_id,
                        X_REMARKS               => null,
                        X_APPROVER_NOTES        => null,
                        X_USER_DEFERRAL_TYPE    => null,
                        X_CREATION_DATE         => sysdate,
                        X_CREATED_BY            => fnd_global.user_id,
                        X_LAST_UPDATE_DATE      => sysdate,
                        X_LAST_UPDATED_BY       => fnd_global.user_id,
                        X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                    );

                    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                    THEN
                        fnd_log.string
                        (
                            G_DEBUG_STMT,
                            l_debug_module,
                            'Insert unit_deferral ['||l_deferral_id||'] with relevant MEL/CDL qualification information'
                        );
                    END IF;
                END IF;
                CLOSE get_deferral_rec;
            END IF;

        ELSIF (p_x_nonroutine_rec.mel_cdl_qual_flag ='D')
        THEN

            DELETE FROM ahl_unit_deferrals_tl
            WHERE unit_deferral_id IN
            (
                SELECT unit_deferral_id
                FROM ahl_unit_deferrals_b
                WHERE unit_effectivity_id = l_unit_effectivity_id
            );

            DELETE FROM ahl_unit_deferrals_b
            WHERE unit_effectivity_id = l_unit_effectivity_id;

            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
            THEN
                fnd_log.string
                (
                    G_DEBUG_STMT,
                    l_debug_module,
                    'Deleted unit_deferral ['||l_deferral_rec.unit_deferral_id||']'
                );
            END IF;

        END IF;
    /*
    ELSE
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_QUAL_APPR');
        -- Cannot modify MEL/CDL Instructions for Non-routine pending for MEL/CDL approval or already approved
        FND_MSG_PUB.ADD;
    */
    END IF;

    -- Balaji added for the bug that SR ovn is not correctly returned from the call
    -- to CS_SERVICEREQUEST_PUB.Update_ServiceRequest.
    -- Begin change
    OPEN c_get_sr_ovn(p_x_nonroutine_rec.incident_id);
    FETCH c_get_sr_ovn INTO p_x_nonroutine_rec.incident_object_version_number;
    CLOSE c_get_sr_ovn;
    -- End change

    -- API body ends here
    -- Log API exit point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Commit if p_commit = FND_API.G_TRUE
    IF FND_API.TO_BOOLEAN(p_commit)
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get
    (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Update_SR_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Update_SR_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Update_SR_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Update_SR',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Update_SR;

----------------------------------------------
-- Spec Procedure Initiate_Mel_Cdl_Approval --
----------------------------------------------
PROCEDURE Initiate_Mel_Cdl_Approval
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_ue_id                     IN          NUMBER,
    p_ue_object_version         IN          NUMBER
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Initiate_Mel_Cdl_Approval';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_junk                      VARCHAR2(1);
    l_NR_count                  NUMBER;
    l_count                     NUMBER;
    l_new_status_code           VARCHAR2(30);

    -- Define cursors

    -- get deferral details.
    cursor ue_deferral_csr(p_ue_id  IN NUMBER)
    is
        select  unit_deferral_id, object_version_number, unit_deferral_type,
                approval_status_code, ata_sequence_id, deferral_effective_on
        from    ahl_unit_deferrals_b
        where   unit_effectivity_id = p_ue_id and
                unit_deferral_type in ('MEL', 'CDL')
        for update of object_version_number;

    -- get ue details.
    cursor unit_effect_csr (p_ue_id IN NUMBER)
    is
       select   unit_effectivity_id, object_version_number, status_code,
                cs_incident_id, mel_cdl_type_code, csi_item_instance_id,
                unit_config_header_id, log_series_code, log_series_number
       from     ahl_unit_effectivities_b
       where    unit_effectivity_id = p_ue_id
         and    object_type = 'SR'
         and    (status_code IS NULL or status_code = 'INIT_DUE')
       for update of object_version_number;

    -- get visit details.
    cursor visit_det_csr(p_ue_id  IN NUMBER)
    is
       select   'x'
       from     ahl_visit_tasks_b vts, ahl_visits_b vst
       where    vst.visit_id = vts.visit_id
         and    NVL(vst.status_code,'x') IN ('PARTIALLY RELEASED','RELEASED')
     and    NVL(vts.status_code,'x')  = 'RELEASED'
         and    vts.unit_effectivity_id = p_ue_id ;

    -- query for defer details.
    cursor ue_defer_csr (p_ue_id  IN NUMBER)
    is
       select  'x'
       from    ahl_unit_deferrals_b
       where   unit_effectivity_id = p_ue_id
         and   unit_deferral_type = 'DEFERRAL'
         and   approval_status_code = 'DEFERRAL_PENDING';

    -- query for defer details for child UEs.
    cursor ue_defer_child_csr (p_ue_id  IN NUMBER)
    is
       select  'x'
       from    ahl_unit_deferrals_b
       where   unit_effectivity_id IN (select related_ue_id
                                       from   ahl_ue_relationships
                                       start with ue_id = p_ue_id
                                       connect by PRIOR related_ue_id  = ue_id)
         and   unit_deferral_type = 'DEFERRAL'
         and   approval_status_code = 'DEFERRAL_PENDING';

    -- get mel/cdl details.
    cursor mel_cdl_header_csr (p_ata_sequence_id IN NUMBER)
    is
       select  seq.INSTALLED_NUMBER, seq.DISPATCH_NUMBER, nvl(rc.repair_time,0)
       from   ahl_mel_cdl_ata_sequences seq, ahl_mel_cdl_headers hdr,
              ahl_repair_categories rc
       where  seq.mel_cdl_header_id = hdr.mel_cdl_header_id
         and  seq.mel_cdl_ata_sequence_id = p_ata_sequence_id
         and  nvl(hdr.expired_date, sysdate+1) > sysdate
         and  seq.repair_category_id = rc.repair_category_id;

    -- get open NRs for the ata sequence.
    cursor get_open_NRs_csr (p_ata_sequence_id IN NUMBER,
                             p_unit_config_header_id IN NUMBER)
                             --p_cs_incident_id        IN NUMBER)
    is
       select count(ue.cs_incident_id)
       from   AHL_UNIT_EFFECTIVITIES_B UE, CS_INCIDENTS_ALL_B CS,
              CS_INCIDENT_STATUSES_B STATUS, AHL_UNIT_DEFERRALS_B UDF,
              AHL_MEL_CDL_ATA_SEQUENCES SEQ
       where SEQ.MEL_CDL_ATA_SEQUENCE_ID = UDF.ATA_SEQUENCE_ID
       AND UDF.UNIT_EFFECTIVITY_ID = UE.UNIT_EFFECTIVITY_ID
       AND UE.CS_INCIDENT_ID = CS.INCIDENT_ID
       AND CS.INCIDENT_STATUS_ID = STATUS.INCIDENT_STATUS_ID
       AND NVL(STATUS.CLOSE_FLAG, 'N') = 'N'
       AND SEQ.mel_cdl_ata_sequence_id = p_ata_sequence_id
       AND UE.unit_config_header_id = p_unit_config_header_id
       AND (UE.status_code IS NULL OR UE.status_code = 'INIT_DUE')
       AND UDF.approval_status_code IN ('DEFERRED','DEFERRAL_PENDING');
       --AND UE.cs_incident_id <> p_cs_incident_id;

    -- validate interrelationships.
    cursor get_ata_relationship_csr (p_ata_sequence_id IN NUMBER)
    is
       select related_ata_sequence_id  ata_sequence_id
       from   ahl_mel_cdl_relationships
       where  ata_sequence_id = p_ata_sequence_id
       UNION ALL
       select ata_sequence_id
       from   ahl_mel_cdl_relationships
       where  related_ata_sequence_id = p_ata_sequence_id;

    -- check repair category for time limit.
    cursor get_exp_resolution_csr(p_cs_incident_id IN NUMBER)
    is
       select EXPECTED_RESOLUTION_DATE
       from cs_incidents_all_b cs
       where cs.incident_id = p_cs_incident_id;

    l_deferral_id               NUMBER;
    l_deferral_ovn              NUMBER;
    l_deferral_type             VARCHAR2(30);
    l_ue_rec                    unit_effect_csr%ROWTYPE;
    l_deferral_rec              ue_deferral_csr%ROWTYPE;
    l_installed_number          NUMBER;
    l_dispatch_number           NUMBER;
    l_repair_time               NUMBER;
    l_expected_resolu_date      DATE;

    l_object                VARCHAR2(30):= 'NR_MEL_CDL';
    l_approval_type         VARCHAR2(100):='CONCEPT';
    l_active                VARCHAR2(50):= 'N';
    l_process_name          VARCHAR2(50);
    l_item_type             VARCHAR2(50);

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Initiate_Mel_Cdl_Approval_SP;

    -- Initialize return status to success before any code logic/validation
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
        FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Log API entry point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module ||'.begin', 'At the start of PLSQL procedure'
        );
    END IF;
    -- API body starts here

    -- MOAC initialization.
    MO_GLOBAL.init('AHL');

    -- Validate UE id + ovn exist and corresponding NR is planned in PRD
    OPEN unit_effect_csr (p_ue_id);
    FETCH unit_effect_csr INTO l_ue_rec;
    IF (unit_effect_csr%NOTFOUND) THEN
      CLOSE unit_effect_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_UE_INVALID');
      FND_MESSAGE.Set_Token('UE_ID',p_ue_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_ue_rec.object_version_number <> p_ue_object_version) THEN
      CLOSE unit_effect_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_COM_CHANGED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE unit_effect_csr;

    -- Check Unit locked.
    IF AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => null,
                                       p_ue_id        => p_ue_id,
                                       p_visit_id     => null,
                                       p_item_instance_id  => null) = FND_API.g_true THEN
      -- Unit is locked, therefore cannot proceed for approval.
      -- and cannot login to the workorder
      FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_UNITLCKED');
      FND_MESSAGE.set_token('UE_ID', p_ue_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check UE status.
    OPEN visit_det_csr(p_ue_id);
    FETCH visit_det_csr INTO l_junk;
    IF (visit_det_csr%NOTFOUND) THEN
      CLOSE visit_det_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_NOT_PRD');
      FND_MESSAGE.Set_Token('UE_ID',p_ue_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE visit_det_csr;

    -- Validate UE is already not pending for MEL/CDL approval / already not approved
    OPEN ue_deferral_csr(p_ue_id);
    FETCH ue_deferral_csr INTO l_deferral_rec;
    IF (ue_deferral_csr%NOTFOUND) THEN
      CLOSE ue_deferral_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_NOT_DEFER');
      FND_MESSAGE.Set_Token('UE_ID',p_ue_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE ue_deferral_csr;

    IF (l_deferral_rec.approval_status_code IN ('DEFERRED','DEFERRAL_PENDING')) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_APPR_STATUS_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_deferral_rec.ata_sequence_id IS NULL) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_NO_SYS_SEQ_ASSOC');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- validate ue is not being deferred.
    OPEN ue_defer_csr(p_ue_id);
    FETCH ue_defer_csr INTO l_junk;
    IF (ue_defer_csr%FOUND) THEN
       CLOSE ue_defer_csr;
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_IN_DEFER');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE ue_defer_csr;

    -- validate there are no child UEs being deferred.
    OPEN ue_defer_child_csr(p_ue_id);
    FETCH ue_defer_child_csr INTO l_junk;
    IF (ue_defer_child_csr%FOUND) THEN
       CLOSE ue_defer_child_csr;
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_CHILD_UE_DEFER');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE ue_defer_child_csr;

    -- Perform pre-MEL/CDL approval validations
    -- validate mel/cdl header id.
    OPEN mel_cdl_header_csr(l_deferral_rec.ata_sequence_id);
    FETCH mel_cdl_header_csr INTO l_installed_number, l_dispatch_number, l_repair_time;
    IF (mel_cdl_header_csr%NOTFOUND) THEN
      CLOSE mel_cdl_header_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_MEL_CDL_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- validate repair category.
    OPEN get_exp_resolution_csr(l_ue_rec.cs_incident_id);
    FETCH get_exp_resolution_csr INTO l_expected_resolu_date;
    IF (get_exp_resolution_csr%NOTFOUND) THEN
      CLOSE get_exp_resolution_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_CS_INC_MISSING');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (nvl(l_repair_time, 0) = 0) AND (l_expected_resolu_date IS NULL) THEN
      CLOSE get_exp_resolution_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_RESOLUTION_MAND');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_exp_resolution_csr;

    /* Commented this validation to fix second issue reported in bug#7697685
    -- Bug #5230869 - validate inc_occ_date + rep_time >= inc_date
    IF (NVL(l_repair_time, 0) <> 0 AND trunc(l_deferral_rec.deferral_effective_on) + trunc(l_repair_time/24) < trunc(sysdate))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_NO_ACCOM');
        -- Repair Time of the associated MEL/CDL Instructions cannot accomodate resolution of the Non-routine before Log Date
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    -- Validate log_series, number + unit_config are not null for NR that is being submitted for MEL/CDL deferral
    IF (l_ue_rec.unit_config_header_id is null or l_ue_rec.log_series_code is null or l_ue_rec.log_series_number is null)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_APPR_MAND_INV');
        -- Unit, Log Series and Number are mandatory for submitting for MEL/CDL approval
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --amsriniv. Bug 6659422. Adding condition below only when dispatch_number and installed_number
    --are both NOT NULL and dispatch_number is > 0.
    IF (l_installed_number IS NOT NULL and l_dispatch_number IS NOT NULL) AND
       (l_installed_number <> l_dispatch_number) AND  -- ignore check when equal.
       (l_dispatch_number > 0)  -- ignore check if none are required.
    THEN
        -- validate openNRs with installed and dispatch rules.
        OPEN get_open_NRs_csr(l_deferral_rec.ata_sequence_id,
                              l_ue_rec.unit_config_header_id);
                              --l_ue_rec.cs_incident_id);
        FETCH get_open_NRs_csr INTO l_NR_count;
        CLOSE get_open_NRs_csr;

        IF ((l_installed_number - l_NR_count) <= l_dispatch_number) THEN
          FND_MESSAGE.Set_Name('AHL','AHL_UMP_OPEN_NR_EXCEEDS');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- validate workorder dependency.
    AHL_PRD_WORKORDER_PVT.validate_dependencies
    (
        p_api_version         => 1.0,
        p_init_msg_list       => FND_API.G_TRUE,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        p_default             => FND_API.G_FALSE,
        p_module_type         => NULL,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data,
        p_visit_id            => NULL,
        p_unit_effectivity_id => p_ue_id,
        p_workorder_id        => NULL
    );

    -- if workorders under UE has external dependencies, dont submit for approval, raise error.
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= G_DEBUG_LEVEL)THEN
           fnd_log.string
              (
                fnd_log.level_error,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'Can not go ahead with submission of approval because Workorder dependencies exists'
              );
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Kick off approval process if active, else complete approval process (post-MEL/CDL approval updations)
    ahl_utility_pvt.get_wf_process_name(
                                    p_object       =>l_object,
                                    x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
           fnd_log.string
           (
                G_DEBUG_STMT,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'Workflow active flag : ' || l_active
           );
           fnd_log.string
           (
                G_DEBUG_STMT,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'l_process_name : ' || l_process_name
           );
           fnd_log.string
           (
                G_DEBUG_STMT,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'l_item_type : ' || l_item_type
           );

    END IF;

    IF((l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
       ( l_active <> G_YES_FLAG))THEN
       IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
           fnd_log.string
              (
                G_DEBUG_STMT,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'Workflow is not active so going for automatic approval'
              );
       END IF;
       l_active := G_NO_FLAG;
    END IF;

    -- make a call to update job status to pending deferral approval and update approval status
    AHL_PRD_DF_PVT.process_approval_initiated(
                         p_unit_deferral_id      => l_deferral_rec.unit_deferral_id,
                         p_object_version_number => l_deferral_rec.object_version_number,
                         p_new_status            => 'DEFERRAL_PENDING',
                         x_return_status         => l_return_status);

    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= G_DEBUG_LEVEL)THEN
           fnd_log.string
              (
                fnd_log.level_error,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.submit_for_approval',
                'Can not go ahead with approval because AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval threw error'
              );
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
           fnd_log.string
           (
                G_DEBUG_STMT,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'Workflow active flag : ' || l_active
           );
    END IF;

    l_new_status_code := 'DEFERRED';

    IF(l_active <> G_NO_FLAG)THEN
       Ahl_generic_aprv_pvt.Start_Wf_Process(
                         P_OBJECT                => l_object,
                         P_APPROVAL_TYPE         => 'CONCEPT',
                         P_ACTIVITY_ID           => l_deferral_rec.unit_deferral_id,
                         P_OBJECT_VERSION_NUMBER => l_deferral_rec.object_version_number,
                         P_ORIG_STATUS_CODE      => l_deferral_rec.approval_status_code,
                         P_NEW_STATUS_CODE       => l_new_status_code ,
                         P_REJECT_STATUS_CODE    => 'DEFERRAL_REJECTED',
                         P_REQUESTER_USERID      => fnd_global.user_id,
                         P_NOTES_FROM_REQUESTER  => '',
                         P_WORKFLOWPROCESS       => 'AHL_GEN_APPROVAL',
                         P_ITEM_TYPE             => 'AHLGAPP');
    ELSE

      -- process for M and O procedures.
      Process_MO_procedures (p_ue_id,
                             l_deferral_rec.unit_deferral_id,
                             l_deferral_rec.object_version_number,
                             l_deferral_rec.ata_sequence_id,
                             l_ue_rec.cs_incident_id,
                             l_ue_rec.csi_item_instance_id);


    END IF;

    /*
    -- validate interrelationships and set return status to warning.
    FOR ata_seq_rec IN get_ata_relationship_csr(l_deferral_rec.ata_sequence_id)
    LOOP
       OPEN get_open_NRs_csr(ata_seq_rec.ata_sequence_id,
                             l_ue_rec.unit_config_header_id);
       FETCH get_open_NRs_csr INTO l_count;
       CLOSE get_open_NRs_csr;
       IF (l_count > 0) THEN
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_NR_INTERRELATION_ERROR');
           FND_MESSAGE.Set_token('SEQ1',l_deferral_rec.ata_sequence_id);
           FND_MESSAGE.Set_token('SEQ2',ata_seq_rec.ata_sequence_id);
           FND_MSG_PUB.ADD;
       END IF;

    END LOOP;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
       x_return_status := 'W';  -- warning.
    END IF;
    */

    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- API body ends here
    -- Log API exit point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- Commit if p_commit = FND_API.G_TRUE
    IF FND_API.TO_BOOLEAN(p_commit)
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get
    (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Initiate_Mel_Cdl_Approval_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Initiate_Mel_Cdl_Approval_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Initiate_Mel_Cdl_Approval_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Initiate_Mel_Cdl_Approval',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Initiate_Mel_Cdl_Approval;

----------------------------------------------
-- Spec Procedure Check_Open_NRs --
----------------------------------------------
PROCEDURE Check_Open_NRs
(
    -- Standard OUT params
    x_return_status     OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id IN          NUMBER  DEFAULT NULL,
    p_pc_node_id        IN          NUMBER  DEFAULT NULL
)
IS
    -- Declare local variables
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.Check_Open_NRs';
    l_junk                      NUMBER;
    l_return_status             VARCHAR2(1);

    -- Define cursors
    -- query to check existence of open NRs for a mel_cdl_header_id.
    -- modified for perf fix bug# 7442102
    CURSOR nr_mel_cdl_csr(p_mel_cdl_header_id IN NUMBER) IS
    SELECT UE.unit_effectivity_id
    FROM
        AHL_UNIT_EFFECTIVITIES_APP_V UE, CS_INCIDENTS_ALL_B CS,
        CS_INCIDENT_STATUSES_B STATUS, AHL_UNIT_DEFERRALS_B UDF--,
        --AHL_MEL_CDL_ATA_SEQUENCES SEQ
    WHERE
        --SEQ.MEL_CDL_ATA_SEQUENCE_ID = UDF.ATA_SEQUENCE_ID
        --AND
        UDF.UNIT_EFFECTIVITY_ID = UE.UNIT_EFFECTIVITY_ID
        AND UDF.ATA_SEQUENCE_ID = p_mel_cdl_header_id
        AND UE.CS_INCIDENT_ID = CS.INCIDENT_ID
        AND CS.INCIDENT_STATUS_ID = STATUS.INCIDENT_STATUS_ID
        AND NVL(STATUS.CLOSE_FLAG, 'N') = 'N'
        --AND SEQ.MEL_CDL_HEADER_ID = p_mel_cdl_header_id
        AND (UE.STATUS_CODE IS NULL OR UE.STATUS_CODE = 'INIT_DUE')
        AND UDF.APPROVAL_STATUS_CODE IN ('DRAFT','DEFERRAL_PENDING','DEFERRAL_REJECTED')
        AND ROWNUM = 1;

    -- query to check existence of open NRs for a pc_node_id.
    CURSOR nr_pc_node_csr(p_pc_node_id IN NUMBER) IS
    SELECT UE.unit_effectivity_id
    FROM
        AHL_UNIT_EFFECTIVITIES_APP_V UE, CS_INCIDENTS_ALL_B CS,
        CS_INCIDENT_STATUSES_B STATUS, AHL_UNIT_DEFERRALS_B UDF,
        AHL_MEL_CDL_ATA_SEQUENCES SEQ, AHL_MEL_CDL_HEADERS HDR
    WHERE
        SEQ.MEL_CDL_ATA_SEQUENCE_ID = UDF.ATA_SEQUENCE_ID
        AND UDF.UNIT_EFFECTIVITY_ID = UE.UNIT_EFFECTIVITY_ID
        AND UE.CS_INCIDENT_ID = CS.INCIDENT_ID
        AND CS.INCIDENT_STATUS_ID = STATUS.INCIDENT_STATUS_ID
        AND NVL(STATUS.CLOSE_FLAG, 'N') = 'N'
        AND (UE.STATUS_CODE IS NULL OR UE.STATUS_CODE = 'INIT_DUE')
        AND UDF.APPROVAL_STATUS_CODE IN ('DRAFT','DEFERRAL_PENDING','DEFERRAL_REJECTED')
        AND SEQ.MEL_CDL_HEADER_ID = HDR.MEL_CDL_HEADER_ID
        AND HDR.PC_NODE_ID IN
        -- priyan : bug #5302804
        (
            -- traverse up the branch, for MEL/CDL, from the PC node being deleted
            SELECT PC_NODE_ID
            FROM AHL_PC_NODES_B
            CONNECT BY PRIOR PARENT_NODE_ID= PC_NODE_ID
            START WITH PC_NODE_ID = p_pc_node_id
            UNION
            -- traverse down the tree, for MEL/CDL, from the PC node being deleted
            SELECT PC_NODE_ID
            FROM AHL_PC_NODES_B
            CONNECT BY PRIOR PC_NODE_ID = PARENT_NODE_ID
            START WITH PC_NODE_ID = p_pc_node_id
        )
        AND ROWNUM = 1;
BEGIN
    -- Initialize return status to success before any code logic/validation
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log API entry point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body starts here
    -- Check for multiple inputs.
    IF (p_mel_cdl_header_id IS NOT NULL AND p_pc_node_id IS NOT NULL)
    THEN
        -- return error.
        FND_MESSAGE.Set_Name('AHL', 'AHL_UMP_NR_MULTI_PARAM');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -- if p_mel_cdl_header_id is not null
    IF (p_mel_cdl_header_id IS NOT NULL)
    THEN
        OPEN nr_mel_cdl_csr(p_mel_cdl_header_id);
        FETCH nr_mel_cdl_csr INTO l_junk;
        IF (nr_mel_cdl_csr%FOUND)
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE nr_mel_cdl_csr;
    END IF; -- p_mel_cdl_header_id IS NOT NULL

    -- if p_pc_node_id is not null
    IF (p_pc_node_id IS NOT NULL)
    THEN
        OPEN nr_pc_node_csr(p_pc_node_id);
        FETCH nr_pc_node_csr INTO l_junk;
        IF (nr_pc_node_csr%FOUND)
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE nr_pc_node_csr;
    END IF; -- p_pc_node_id IS NOT NULL

    -- API body ends here
    -- Log API exit point
    IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
    THEN
        fnd_log.string
        (
            G_DEBUG_PROC,
            l_debug_module||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Check_Open_NRs;

-----------------------------------------
-- Spec Function Get_Mel_Cdl_Header_Id --
-----------------------------------------
FUNCTION Get_Mel_Cdl_Header_Id
(
    p_unit_effectivity_id   NUMBER,
    p_csi_instance_id       NUMBER,
    p_mel_cdl_type_code     VARCHAR2
)
RETURN NUMBER
IS
    CURSOR get_ue_details
    IS
    SELECT  ahl_util_uc_pkg.get_uc_header_id(csi_item_instance_id),
            mel_cdl_type_code
    FROM    ahl_unit_effectivities_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id;

    l_unit_config_id        number;
    l_mel_cdl_type_code     varchar2(30);

    CURSOR get_mel_cdl
    (
        l_unit_config_id    number,
        l_mel_cdl_type_code varchar2
    )
    IS
    select  mel.mel_cdl_header_id, mel.version_number, pcn.pc_node_id
    from    ahl_pc_nodes_b pcn,
            ahl_mel_cdl_headers mel
    --where   pcn.pc_node_id = mel.pc_node_id (+) and  -- perf fix for bug# 7442102
      where   pcn.pc_node_id = mel.pc_node_id and
            mel.mel_cdl_type_code = l_mel_cdl_type_code and
            mel.status_code = 'COMPLETE' and
            trunc(sysdate) between trunc(revision_date) and trunc(nvl(expired_date, sysdate + 1))
            connect by pcn.pc_node_id = prior pcn.parent_node_id
            start with pcn.pc_node_id in
            (
                select  node.pc_node_id
                from    ahl_pc_associations assos,
                        ahl_pc_nodes_b node,
                        ahl_pc_headers_b hdr
                where   assos.unit_item_id = l_unit_config_id and
                        assos.pc_node_id = node.pc_node_id and
                        node.pc_header_id = hdr.pc_header_id and
                        hdr.status = 'COMPLETE' and
                        hdr.primary_flag = 'Y' and
                        hdr.association_type_flag = 'U'
            )
    --order by pcn.pc_node_id desc, mel.version_number desc;
    order by pcn.pc_node_id desc, mel.mel_cdl_type_code, mel.version_number desc;

    l_mel_cdl_header_id     NUMBER;
    l_pc_node_id            NUMBER;
    l_mel_version_number    NUMBER;

BEGIN

    IF (p_unit_effectivity_id IS NOT NULL AND p_unit_effectivity_id <> FND_API.G_MISS_NUM)
    THEN
        OPEN get_ue_details;
        FETCH get_ue_details INTO l_unit_config_id, l_mel_cdl_type_code;
        CLOSE get_ue_details;
    ELSIF (
            p_csi_instance_id IS NOT NULL AND p_csi_instance_id <> FND_API.G_MISS_NUM AND
            p_mel_cdl_type_code IS NOT NULL AND p_mel_cdl_type_code <> FND_API.G_MISS_CHAR
           )
    THEN
        --SELECT ahl_util_uc_pkg.get_uc_header_id(p_csi_instance_id) INTO l_unit_config_id FROM DUAL;
        l_unit_config_id := ahl_util_uc_pkg.get_uc_header_id(p_csi_instance_id);
        l_mel_cdl_type_code := p_mel_cdl_type_code;
    END IF;

    IF (l_unit_config_id IS NOT NULL AND l_mel_cdl_type_code IS NOT NULL AND ahl_util_uc_pkg.get_uc_status_code(l_unit_config_id) IN ('COMPLETE', 'INCOMPLETE'))
    THEN
        OPEN get_mel_cdl(l_unit_config_id, l_mel_cdl_type_code);
        FETCH get_mel_cdl INTO l_mel_cdl_header_id, l_mel_version_number, l_pc_node_id;
        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_STMT,
                'ahl.plsql.'||G_PKG_NAME||'.Get_Mel_Cdl_Header_Id.end',
                'Retrieved mel_cdl_header_id ['||l_mel_cdl_header_id||'] with version ['||l_mel_version_number||'] for pc_node_id ['||l_pc_node_id||'] given uc_id ['||l_unit_config_id||'] and type ['||l_mel_cdl_type_code||']'
            );
        END IF;
        CLOSE get_mel_cdl;
    END IF;

    RETURN l_mel_cdl_header_id;

END Get_Mel_Cdl_Header_Id;

--------------------------------------
-- Spec Function Get_Mel_Cdl_Status --
--------------------------------------
FUNCTION Get_Mel_Cdl_Status
(
    p_unit_effectivity_id   NUMBER,
    p_get_code              VARCHAR2    := FND_API.G_FALSE
)
RETURN VARCHAR2
IS
    l_mel_cdl_status        VARCHAR2(30) := 'OPEN';
    l_mel_cdl_status_mean   VARCHAR2(80);

    CURSOR get_ue_details
    IS
    SELECT  unit_deferral_type, approval_status_code
    FROM    ahl_unit_deferrals_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id AND
            unit_deferral_type IN ('MEL', 'CDL');

    l_deferral_type         VARCHAR2(30);
    l_approval_code         VARCHAR2(30);

    l_ret_val               BOOLEAN;

BEGIN

    IF (p_unit_effectivity_id IS NOT NULL AND p_unit_effectivity_id <> FND_API.G_MISS_NUM)
    THEN
        OPEN get_ue_details;
        FETCH get_ue_details INTO l_deferral_type, l_approval_code;
        IF (get_ue_details%FOUND)
        THEN
            l_mel_cdl_status := l_deferral_type||':'||l_approval_code;

            IF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_NR_MELCDL_STATUS_CODE', l_mel_cdl_status))
            THEN
                l_mel_cdl_status := 'OPEN';
            END IF;
        END IF;
    END IF;

    IF (p_get_code = FND_API.G_TRUE)
    THEN
        RETURN l_mel_cdl_status;
    ELSE
        AHL_UTIL_MC_PKG.Convert_To_LookupMeaning
        (
            p_lookup_type       => 'AHL_NR_MELCDL_STATUS_CODE',
            p_lookup_code       => l_mel_cdl_status,
            x_lookup_meaning    => l_mel_cdl_status_mean,
            x_return_val        => l_ret_val
        );
        RETURN l_mel_cdl_status_mean;
    END IF;

END Get_Mel_Cdl_Status;

-------------------------------------------
-- Non-spec Function Is_MEL_CDL_Approved --
-------------------------------------------
FUNCTION Is_MEL_CDL_Approved
(
    p_unit_effectivity_id   NUMBER
)
RETURN BOOLEAN
IS

    l_is_approved       BOOLEAN := false;

    CURSOR get_mel_cdl_status
    IS
    SELECT  approval_status_code, unit_deferral_type
    FROM    ahl_unit_deferrals_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id;

    l_deferral_type     VARCHAR2(30);
    l_approval_code     VARCHAR2(30);

BEGIN

    OPEN get_mel_cdl_status;
    FETCH get_mel_cdl_status INTO l_approval_code, l_deferral_type;
    IF (
        get_mel_cdl_status%FOUND AND
        l_approval_code IN ('DEFERRAL_PENDING', 'DEFERRED') AND
        l_deferral_type IN ('MEL', 'CDL')
    )
    THEN
        l_is_approved := true;
    END IF;
    CLOSE get_mel_cdl_status;

    RETURN l_is_approved;

END Is_MEL_CDL_Approved;

--------------------------------------------
-- Non-spec Procedure Validate_UE_Details --
--------------------------------------------
PROCEDURE Validate_UE_Details
(
    p_x_nonroutine_rec      IN OUT NOCOPY NonRoutine_Rec_Type,
    p_unit_effectivity_id   IN NUMBER,
    p_dml_operation         IN VARCHAR2
)
IS
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.Validate_UE_Details';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_ret_val                   BOOLEAN;
    l_uc_header_id              NUMBER;
    l_uc_status_code            VARCHAR2(30);

    CURSOR check_pos_path_exists
    IS
    SELECT  'x'
    FROM    ahl_applicable_instances appl,
            csi_ii_relationships cii,
            ahl_mc_relationships mch,
            ahl_unit_config_headers uch
    WHERE   appl.position_id = p_x_nonroutine_rec.position_path_id and
            (appl.csi_item_instance_id = cii.subject_id or appl.csi_item_instance_id = cii.object_id) and
            to_number(cii.position_reference) = mch.relationship_id and
            mch.mc_header_id = uch.master_config_id and
            uch.unit_config_header_id = p_x_nonroutine_rec.unit_config_header_id
    UNION ALL
    SELECT 'x'
    FROM    ahl_applicable_instances appl,
            ahl_unit_config_headers uch
    WHERE   appl.position_id = p_x_nonroutine_rec.position_path_id and
            appl.csi_item_instance_id = uch.csi_item_instance_id and
            uch.unit_config_header_id = p_x_nonroutine_rec.unit_config_header_id;

    CURSOR get_ue_details
    (
        p_unit_effectivity_id number
    )
    IS
    SELECT  log_series_code, log_series_number, position_path_id, mel_cdl_type_code, ata_code
    FROM    ahl_unit_effectivities_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id;

    l_ue_detail_rec             get_ue_details%rowtype;

    /* Behavior of Log Series and Number in "Unit / Component Details" sub-header
     * log_series and log_number are non-mandatory (except for MEL/CDL qualification)
     * log_series and log_number exist in combination
     * log_series and log_number are always user-editable, but the combination is unique
     */
    CURSOR check_lognum_unique
    IS
    SELECT  'x'
    FROM    ahl_unit_effectivities_b
    WHERE   log_series_number = p_x_nonroutine_rec.log_series_number and
            log_series_code = p_x_nonroutine_rec.log_series_code and
            unit_effectivity_id <> nvl(p_unit_effectivity_id, unit_effectivity_id) and
            unit_config_header_id = nvl(p_x_nonroutine_rec.unit_config_header_id, unit_config_header_id ) and --pdoki added for ER 9204858
            nvl(status_code, 'X') <> 'DEFERRED';

    CURSOR get_org_id_from_name
    (
        p_org_code      varchar2
    )
    IS
    -- Bug #5208033 Replacing view "org_organization_definitions" with "inv_organization_name_v"
    select  ORG.organization_id
    from    inv_organization_name_v ORG,
            mtl_parameters MP
    where   MP.organization_id = ORG.organization_id AND
            MP.EAM_enabled_flag = 'Y' AND
            ORG.organization_code = p_org_code;

    CURSOR check_org_id
    (
        p_org_id        varchar2
    )
    IS
    -- Bug #5208033 Replacing view "org_organization_definitions" with "inv_organization_name_v"
    select  'x'
    from    inv_organization_name_v ORG,
            mtl_parameters MP
    where   MP.organization_id = ORG.organization_id AND
            MP.EAM_enabled_flag = 'Y' AND
            ORG.organization_id = p_org_id;

    CURSOR get_dept_id_from_name
    (
        p_dept_code     varchar2,
        p_org_id        number
    )
    IS
    select  department_id
    from    bom_departments
    where   organization_id = p_org_id and
            department_code = p_dept_code;

    CURSOR check_dept_id
    (
        p_dept_id       varchar2,
        p_org_id        number
    )
    IS
    select  'x'
    from    bom_departments
    where   organization_id = p_org_id and
            department_id = p_dept_id;

    CURSOR check_ue_mel_cdl_approved
    IS
    SELECT  'x'
    FROM    ahl_unit_deferrals_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id AND
            unit_deferral_type IN ('MEL', 'CDL') AND
            approval_status_code IN ('DEFERRAL_PENDING', 'DEFERRED');

    --priyan
    --Fix for Bug# 5350385
    CURSOR is_ue_mel_cdl_qual
    IS
    SELECT  'x'
    FROM    ahl_unit_deferrals_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id AND
            unit_deferral_type IN ('MEL', 'CDL');

BEGIN
    -- Retrieve details of the non-routine unit effectivity, if record is being updated
    -- During create the information would not already have been committed, so no point opening this cursor
    IF (p_dml_operation = 'U')
    THEN
        OPEN get_ue_details(p_unit_effectivity_id);
        FETCH get_ue_details INTO l_ue_detail_rec;
        CLOSE get_ue_details;
    END IF;

    /*
    -- Validate unit_config_header_id NOT NULL
    IF (p_x_nonroutine_rec.unit_config_header_id is null or p_x_nonroutine_rec.unit_config_header_id = FND_API.G_MISS_NUM)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_UNIT_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    */

    /* Behavior of Unit, Item, Serial and Instance LOVs in "Unit / Component Details" sub-header
     * if unit_config_header_id is not null, then it needs to be an active unit and instance should exist on the unit
     * if unit_config_header_id is null, try to derive an active unit from the instance
     * if unit_config_header_id is still not null, consider this a case of logging NR for IB component only
     * if either UI unit/derived unit is in quarantine/deactive_quarantine, throw error
     */
    IF (p_x_nonroutine_rec.unit_config_header_id is null or p_x_nonroutine_rec.unit_config_header_id = FND_API.G_MISS_NUM)
    THEN
        l_uc_header_id := ahl_util_uc_pkg.get_uc_header_id(p_x_nonroutine_rec.instance_id);
        l_uc_status_code := ahl_util_uc_pkg.get_uc_status_code(l_uc_header_id);
        IF (l_uc_status_code IN ('COMPLETE', 'INCOMPLETE'))
        THEN
            p_x_nonroutine_rec.unit_config_header_id := l_uc_header_id;
        ELSIF (l_uc_status_code IN ('QUARANTINE', 'DEACTIVATE_QUARANTINE'))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_UNIT_QUAR_INV');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        l_uc_status_code := ahl_util_uc_pkg.get_uc_status_code(p_x_nonroutine_rec.unit_config_header_id);
        -- Check for not active and/or quarantined unit
        IF (l_uc_status_code IN ('QUARANTINE', 'DEACTIVATE_QUARANTINE'))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_UNIT_QUAR_INV');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_uc_status_code IN ('COMPLETE', 'INCOMPLETE'))
        THEN
            -- Validate instance exists on the unit specified... Assume instance is validated before this is called...
            l_uc_header_id := ahl_util_uc_pkg.get_uc_header_id(p_x_nonroutine_rec.instance_id);
            IF (NVL(l_uc_header_id, -1 ) <> p_x_nonroutine_rec.unit_config_header_id)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_UNIT_NOMATCH');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_UNIT_ACTV_INV');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    /* Behavior of Log Series and Number in "Unit / Component Details" sub-header
     * log_series and log_number are non-mandatory (except for MEL/CDL qualification)
     * log_series and log_number exist in combination
     * log_series and log_number are always user-editable, but the combination is unique
     * post association of MEL/CDL instr, log_series and log_number cannot be NULL
     */
    IF (p_x_nonroutine_rec.log_series_code IS NULL OR p_x_nonroutine_rec.log_series_code = FND_API.G_MISS_CHAR)
    THEN
        IF (p_x_nonroutine_rec.log_series_meaning IS NOT NULL AND p_x_nonroutine_rec.log_series_meaning <> FND_API.G_MISS_CHAR)
        THEN
            AHL_UTIL_MC_PKG.Convert_To_LookupCode
            (
                p_lookup_type       => 'AHL_LOG_SERIES_CODE',
                p_lookup_meaning    => p_x_nonroutine_rec.log_series_meaning,
                x_lookup_code       => p_x_nonroutine_rec.log_series_code,
                x_return_val        => l_ret_val
            );
            IF NOT (l_ret_val)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_INV');
                -- Log Series is invalid
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    ELSE
        IF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_LOG_SERIES_CODE', p_x_nonroutine_rec.log_series_code))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_INV');
            -- Log Series is invalid
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    IF (p_x_nonroutine_rec.log_series_number IS NOT NULL AND p_x_nonroutine_rec.log_series_number <> FND_API.G_MISS_NUM AND p_x_nonroutine_rec.log_series_number < 0)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_LOGNUM_INV');
        -- Non-routine Log Number must be a positive integer
        FND_MSG_PUB.ADD;
    END IF;

    IF (
        (p_x_nonroutine_rec.log_series_code IS NULL OR p_x_nonroutine_rec.log_series_code = FND_API.G_MISS_CHAR)
        AND
        (p_x_nonroutine_rec.log_series_number IS NOT NULL AND p_x_nonroutine_rec.log_series_number <> FND_API.G_MISS_NUM)
       )
       OR
       (
        (p_x_nonroutine_rec.log_series_code IS NOT NULL AND p_x_nonroutine_rec.log_series_code <> FND_API.G_MISS_CHAR)
        AND
        (p_x_nonroutine_rec.log_series_number IS NULL OR p_x_nonroutine_rec.log_series_number = FND_API.G_MISS_NUM)
       )
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_COMB');
        -- If Log Series is selected, Log Number is mandatory and vice-versa.
        FND_MSG_PUB.ADD;
    END IF;

    IF (
        p_x_nonroutine_rec.log_series_code IS NOT NULL AND p_x_nonroutine_rec.log_series_code <> FND_API.G_MISS_CHAR
        AND
        p_x_nonroutine_rec.log_series_number IS NOT NULL AND p_x_nonroutine_rec.log_series_number <> FND_API.G_MISS_NUM
       )
    THEN
        OPEN check_lognum_unique;
        FETCH check_lognum_unique INTO l_dummy_varchar;
        IF (check_lognum_unique%FOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGNUM_INV');
            FND_MESSAGE.SET_TOKEN('LOGNUM', p_x_nonroutine_rec.log_series_code||'-'||p_x_nonroutine_rec.log_series_number);
            -- Log Number already exists for another non-routine
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE check_lognum_unique;
    END IF;

    --priyan
    --Fix for Bug# 5350385
    IF (p_dml_operation = 'U')
    THEN
        OPEN is_ue_mel_cdl_qual;
        FETCH is_ue_mel_cdl_qual INTO l_dummy_varchar;
        IF (is_ue_mel_cdl_qual%FOUND
            AND
            (
                p_x_nonroutine_rec.log_series_code IS NULL OR p_x_nonroutine_rec.log_series_code = FND_API.G_MISS_CHAR
                OR
                p_x_nonroutine_rec.log_series_number IS NULL OR p_x_nonroutine_rec.log_series_number = FND_API.G_MISS_NUM
            )
           )
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_NOCHG');
            -- Log Series is mandatory for Non-Routines that have MEL/CDL Instruction associated.
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE is_ue_mel_cdl_qual;
    END IF;

    /*
    -- Validate log series code
    IF (p_dml_operation = 'C')
    THEN
        IF (p_x_nonroutine_rec.log_series_code IS NULL OR p_x_nonroutine_rec.log_series_code = FND_API.G_MISS_CHAR)
        THEN
            IF (p_x_nonroutine_rec.log_series_meaning IS NULL OR p_x_nonroutine_rec.log_series_meaning = FND_API.G_MISS_CHAR)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_MAND');
                -- Log Series is mandatory
                FND_MSG_PUB.ADD;
            ELSE
                AHL_UTIL_MC_PKG.Convert_To_LookupCode
                (
                    p_lookup_type       => 'AHL_LOG_SERIES_CODE',
                    p_lookup_meaning    => p_x_nonroutine_rec.log_series_meaning,
                    x_lookup_code       => p_x_nonroutine_rec.log_series_code,
                    x_return_val        => l_ret_val
                );
                IF NOT (l_ret_val)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_INV');
                    -- Log Series is invalid
                    FND_MSG_PUB.ADD;
                END IF;
            END IF;
        ELSE
            IF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_LOG_SERIES_CODE', p_x_nonroutine_rec.log_series_code))
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_INV');
                -- Log Series is invalid
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    ELSIF (p_dml_operation = 'U' AND l_ue_detail_rec.log_series_code IS NOT NULL)
    THEN
        IF (l_ue_detail_rec.log_series_code <> p_x_nonroutine_rec.log_series_code)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGSER_NOCHG');
            -- Log Series cannot be modified after non-routine is created
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    -- Validate log series number
    IF (p_dml_operation = 'C')
    THEN
        IF (p_x_nonroutine_rec.log_series_number IS NULL OR p_x_nonroutine_rec.log_series_number = FND_API.G_MISS_NUM)
        THEN
            SELECT ahl_log_series_s.NEXTVAL INTO p_x_nonroutine_rec.log_series_number FROM DUAL;
        ELSE
            OPEN check_lognum_unique;
            FETCH check_lognum_unique INTO l_dummy_varchar;
            IF (check_lognum_unique%FOUND)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGNUM_INV');
                -- Log Number already exists for another non-routine
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE check_lognum_unique;
        END IF;
    ELSIF (p_dml_operation = 'U' AND l_ue_detail_rec.log_series_number IS NOT NULL)
    THEN
        IF (l_ue_detail_rec.log_series_number <> p_x_nonroutine_rec.log_series_number)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_LOGNUM_NOCHG');
            -- Log Number cannot be modified after non-routine is created
            FND_MSG_PUB.ADD;
        END IF;
    END IF;
    */

    -- Validate MEL/CDL type
    IF (p_x_nonroutine_rec.mel_cdl_type_code IS NULL OR p_x_nonroutine_rec.mel_cdl_type_code = FND_API.G_MISS_CHAR)
    THEN
        IF (p_x_nonroutine_rec.mel_cdl_type_meaning IS NOT NULL AND p_x_nonroutine_rec.mel_cdl_type_meaning <> FND_API.G_MISS_CHAR)
        THEN
            AHL_UTIL_MC_PKG.Convert_To_LookupCode
            (
                p_lookup_type       => 'AHL_MEL_CDL_TYPE',
                p_lookup_meaning    => p_x_nonroutine_rec.mel_cdl_type_meaning,
                x_lookup_code       => p_x_nonroutine_rec.mel_cdl_type_code,
                x_return_val        => l_ret_val
            );
            IF NOT (l_ret_val)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_TYPE_INV');
                -- Position ATA is invalid
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    ELSE
        IF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_MEL_CDL_TYPE', p_x_nonroutine_rec.mel_cdl_type_code))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_TYPE_INV');
            -- Position ATA is invalid
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    -- Validate ata code
    IF (p_x_nonroutine_rec.ata_code IS NULL OR p_x_nonroutine_rec.ata_code = FND_API.G_MISS_CHAR)
    THEN
        IF (p_x_nonroutine_rec.ata_meaning IS NOT NULL AND p_x_nonroutine_rec.ata_meaning <> FND_API.G_MISS_CHAR)
        THEN
            AHL_UTIL_MC_PKG.Convert_To_LookupCode
            (
                p_lookup_type       => 'AHL_ATA_CODE',
                p_lookup_meaning    => p_x_nonroutine_rec.ata_meaning,
                x_lookup_code       => p_x_nonroutine_rec.ata_code,
                x_return_val        => l_ret_val
            );
            IF NOT (l_ret_val)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_ATA_INV');
                -- Position ATA is invalid
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    ELSE
        IF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_ATA_CODE', p_x_nonroutine_rec.ata_code))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_ATA_INV');
            -- Position ATA is invalid
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    -- Validate position path exists on the unit
    IF (p_x_nonroutine_rec.position_path_id IS NOT NULL AND p_x_nonroutine_rec.position_path_id <> FND_API.G_MISS_NUM)
    THEN
        AHL_MC_PATH_POSITION_PVT.Map_Position_To_Instances
        (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            p_position_id       => p_x_nonroutine_rec.position_path_id
        );

        IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
        THEN
            OPEN check_pos_path_exists;
            FETCH check_pos_path_exists INTO l_dummy_varchar;
            IF (check_pos_path_exists%NOTFOUND)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_POSPATH_INV');
                -- Position path does not exist on the unit
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE check_pos_path_exists;
        ELSE
            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
            THEN
                fnd_log.string
                (
                    G_DEBUG_STMT,
                    l_debug_module,
                    'Call to AHL_MC_PATH_POSITION_PVT.Map_Position_To_Instances failed with error ['||l_msg_data||']'
                );
            END IF;
        END IF;
    END IF;

    -- Verify MEL/CDL qualification information cannot be modified if NR is pending approval / approved
    OPEN check_ue_mel_cdl_approved;
    FETCH check_ue_mel_cdl_approved INTO l_dummy_varchar;
    IF (p_dml_operation = 'U' AND check_ue_mel_cdl_approved%FOUND)
    THEN
        IF
        (
            l_ue_detail_rec.mel_cdl_type_code <> p_x_nonroutine_rec.mel_cdl_type_code
            AND
            l_ue_detail_rec.ata_code <> p_x_nonroutine_rec.ata_code
            AND
            l_ue_detail_rec.position_path_id <> p_x_nonroutine_rec.position_path_id
        )
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_QUAL_APPR');
            -- Cannot modify either of MEL/CDL Type, Position and Position ATA since Non-routine is either pending for MEL/CDL approval or already approved.
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    /*
    -- Validate clear station org
    IF (p_x_nonroutine_rec.clear_station_org_id IS NULL OR p_x_nonroutine_rec.clear_station_org_id = FND_API.G_MISS_NUM)
    THEN
        IF (p_x_nonroutine_rec.clear_station_org IS NOT NULL AND p_x_nonroutine_rec.clear_station_org <> FND_API.G_MISS_CHAR)
        THEN
            OPEN get_org_id_from_name(p_x_nonroutine_rec.clear_station_org);
            FETCH get_org_id_from_name INTO p_x_nonroutine_rec.clear_station_org_id;
            IF (get_org_id_from_name%NOTFOUND)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_ORG_INV');
                -- Clear station organization is invalid
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE get_org_id_from_name;
        END IF;
    ELSE
        OPEN check_org_id(p_x_nonroutine_rec.clear_station_org_id);
        FETCH check_org_id INTO l_dummy_varchar;
        IF (check_org_id%NOTFOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_ORG_INV');
            -- Clear station organization is invalid
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE check_org_id;
    END IF;

    -- Validate clear station dept
    IF (p_x_nonroutine_rec.clear_station_dept_id IS NULL OR p_x_nonroutine_rec.clear_station_dept_id = FND_API.G_MISS_NUM)
    THEN
        IF (p_x_nonroutine_rec.clear_station_dept IS NOT NULL AND p_x_nonroutine_rec.clear_station_dept <> FND_API.G_MISS_CHAR)
        THEN
            OPEN get_dept_id_from_name(p_x_nonroutine_rec.clear_station_dept, p_x_nonroutine_rec.clear_station_org_id);
            FETCH get_dept_id_from_name INTO p_x_nonroutine_rec.clear_station_dept_id;
            IF (get_dept_id_from_name%NOTFOUND)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_DEPT_INV');
                -- Clear station department is invalid
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE get_dept_id_from_name;
        END IF;
    ELSE
        OPEN check_dept_id(p_x_nonroutine_rec.clear_station_dept_id, p_x_nonroutine_rec.clear_station_org_id);
        FETCH check_dept_id INTO l_dummy_varchar;
        IF (check_dept_id%NOTFOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NR_DEPT_INV');
            -- Clear station department is invalid
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE check_dept_id;
    END IF;
    */

END Validate_UE_Details;

-----------------------------------------
-- Non-spec Procedure Get_Ata_Sequence --
-----------------------------------------
PROCEDURE Get_Ata_Sequence
(
    p_unit_effectivity_id   IN          NUMBER,
    p_ata_code              IN          VARCHAR2,
    x_ata_sequence_id       OUT NOCOPY  NUMBER
)
IS
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.Get_Ata_Sequence';

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_mel_cdl_header_id         NUMBER;

    CURSOR get_ue_details
    IS
    SELECT  ahl_util_uc_pkg.get_uc_header_id(csi_item_instance_id) unit_config_id,
            ahl_util_uc_pkg.get_unit_name(csi_item_instance_id) unit_config_name,
            mel_cdl_type_code,
            position_path_id,
            ata_code
    FROM    ahl_unit_effectivities_b
    WHERE   unit_effectivity_id = p_unit_effectivity_id;

    l_ue_details_rec            get_ue_details%rowtype;

    CURSOR check_ata_exists
    (
        p_mel_cdl_header_id     number,
        p_ata_code              varchar2
    )
    IS
    SELECT  mel_cdl_ata_sequence_id
    FROM    ahl_mel_cdl_ata_sequences
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id and
            ata_code = p_ata_code;

    CURSOR get_ata_for_position
    (
        p_position_path_id      number,
        p_unit_config_id        number
    )
    IS
    SELECT  mch.ata_code
    FROM    ahl_applicable_instances appl,
            csi_ii_relationships cii,
            ahl_mc_relationships mch,
            ahl_unit_config_headers uch
    WHERE   appl.position_id = p_position_path_id and
            appl.csi_item_instance_id = cii.subject_id and
            cii.position_reference = mch.relationship_id and
            mch.mc_header_id = uch.master_config_id and
            uch.unit_config_header_id = p_unit_config_id
    UNION ALL
    SELECT  mch.ata_code
    FROM    ahl_applicable_instances appl,
            ahl_mc_relationships mch,
            ahl_unit_config_headers uch
    WHERE   appl.position_id = p_position_path_id and
            appl.csi_item_instance_id = uch.csi_item_instance_id and
            mch.mc_header_id = uch.master_config_id and
            uch.unit_config_header_id = p_unit_config_id;

   l_ata_for_position          varchar2(30);

BEGIN

    IF (p_unit_effectivity_id IS NOT NULL AND p_unit_effectivity_id <> FND_API.G_MISS_NUM)
    THEN
        OPEN get_ue_details;
        FETCH get_ue_details INTO l_ue_details_rec;
        CLOSE get_ue_details;

        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_STMT,
                l_debug_module,
                'l_ue_details_rec [unit_config_id='||l_ue_details_rec.unit_config_id||'][unit_config_name='
                    ||l_ue_details_rec.unit_config_name||']
                    [mel_cdl_type_code='||l_ue_details_rec.mel_cdl_type_code||'][position_path_id='||l_ue_details_rec.position_path_id||']
                    [ata_code='||l_ue_details_rec.ata_code||']'
            );
        END IF;

        IF (l_ue_details_rec.mel_cdl_type_code IS NULL OR l_ue_details_rec.mel_cdl_type_code = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_QUAL_TYPE_MAND');
            -- MEL/CDL Type is mandatory, hence cannot qualify for MEL/CDL
            FND_MSG_PUB.ADD;
        END IF;

        l_mel_cdl_header_id := Get_Mel_Cdl_Header_Id(p_unit_effectivity_id, null, null);
        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
        THEN
            fnd_log.string
            (
                G_DEBUG_STMT,
                l_debug_module,
                'l_mel_cdl_header_id='||l_mel_cdl_header_id||']'
            );
        END IF;

        IF (l_mel_cdl_header_id IS NULL)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_QUAL_SETUP_MAND');
            FND_MESSAGE.SET_TOKEN('UCNAME', l_ue_details_rec.unit_config_name);
            -- No MEL/CDL has been setup for the unit "UCNAME", hence cannot qualify for MEL/CDL
            FND_MSG_PUB.ADD;
        ELSE
            IF (
                (l_ue_details_rec.ata_code IS NULL OR l_ue_details_rec.ata_code = FND_API.G_MISS_CHAR)
                AND
                (l_ue_details_rec.position_path_id IS NULL OR l_ue_details_rec.position_path_id = FND_API.G_MISS_NUM)
            )
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_QUAL_ALL_NULL');
                -- One of Position ATA and Position is mandatory, hence cannot qualify for MEL/CDL
                FND_MSG_PUB.ADD;
            END IF;

            IF (l_ue_details_rec.position_path_id IS NOT NULL AND l_ue_details_rec.position_path_id <> FND_API.G_MISS_NUM)
            THEN
                AHL_MC_PATH_POSITION_PVT.Map_Position_To_Instances
                (
                    p_api_version       => 1.0,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit            => FND_API.G_FALSE,
                    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data,
                    p_position_id       => l_ue_details_rec.position_path_id
                );


                IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
                THEN
                    OPEN get_ata_for_position(l_ue_details_rec.position_path_id, l_ue_details_rec.unit_config_id);
                    FETCH get_ata_for_position INTO l_ata_for_position;
                    CLOSE get_ata_for_position;

                    IF (l_ata_for_position IS NOT NULL)
                    THEN

                        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                        THEN
                            fnd_log.string
                            (
                                G_DEBUG_STMT,
                                l_debug_module,
                                'ATA Code of Position ATA is ='||p_ata_code||']'
                            );
                        END IF;

                        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                        THEN
                            fnd_log.string
                            (
                                G_DEBUG_STMT,
                                l_debug_module,
                                'ATA Code of Position  ='||l_ata_for_position||']'
                            );
                        END IF;

                        --Priyan Fix for Bug # 5359840
                        -- Check made to validate whether the ATA Code of the MC Position (if any)
                        -- matches with the Position ATA Code entered.
                        -- If it does not match , throw an error .
                        IF (l_ata_for_position <> p_ata_code)
                        THEN
                                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_POS_ATA_NO_MATCH');
                                -- ATA code of the Position ATA and MC Position does not match .
                                FND_MSG_PUB.ADD;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        --End of changes by Priyan

                        OPEN check_ata_exists(l_mel_cdl_header_id, l_ata_for_position);
                        FETCH check_ata_exists INTO x_ata_sequence_id;
                        CLOSE check_ata_exists;

                        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                        THEN
                            fnd_log.string
                            (
                                G_DEBUG_STMT,
                                l_debug_module,
                                'From position_path_id -- x_ata_sequence_id='||x_ata_sequence_id||']'
                            );
                        END IF;

                        IF x_ata_sequence_id IS NOT NULL
                        THEN
                            UPDATE  ahl_unit_effectivities_b
                            SET     ata_code = l_ata_for_position
                            WHERE   unit_effectivity_id = p_unit_effectivity_id;
                        END IF;
                    END IF;
                ELSE
                    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                    THEN
                        fnd_log.string
                        (
                            G_DEBUG_STMT,
                            l_debug_module,
                            'Call to AHL_MC_PATH_POSITION_PVT.Map_Position_To_Instances failed with error ['||l_msg_data||']'
                        );
                    END IF;
                END IF;
            END IF;

            IF (x_ata_sequence_id IS NULL AND l_ue_details_rec.ata_code IS NOT NULL AND l_ue_details_rec.ata_code <> FND_API.G_MISS_CHAR)
            THEN
                OPEN check_ata_exists(l_mel_cdl_header_id, l_ue_details_rec.ata_code);
                FETCH check_ata_exists INTO x_ata_sequence_id;
                CLOSE check_ata_exists;

                IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
                THEN
                    fnd_log.string
                    (
                        G_DEBUG_STMT,
                        l_debug_module,
                        'From ata_code -- x_ata_sequence_id='||x_ata_sequence_id||']'
                    );
                END IF;
            END IF;

            IF (x_ata_sequence_id IS NULL)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_QUAL_SEQ_FAIL');
                -- Cannot retrieve any System Sequence information for non-routine, hence cannot qualify for MEL/CDL
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    END IF;

END Get_Ata_Sequence;

PROCEDURE Validate_SR_Details
(
    p_x_nonroutine_rec IN OUT NOCOPY NonRoutine_Rec_Type,
    p_dml_operation IN VARCHAR2
)
IS

    CURSOR cs_incident_exists
    IS
    SELECT  incident_number, incident_date
    FROM    cs_incidents_all_b
    WHERE   incident_id = p_x_nonroutine_rec.incident_id AND
            object_version_number = p_x_nonroutine_rec.incident_object_version_number;

    l_incident_number       VARCHAR2(64);
    l_incident_date         DATE;
    l_instance_owner_id     NUMBER;

    CURSOR cs_severity_in_eam_priority
    IS
    SELECT  'x'
    FROM    cs_incident_severities_vl csv,
            mfg_lookups mfl
    WHERE   mfl.lookup_code = csv.incident_severity_id AND
            csv.incident_severity_id = p_x_nonroutine_rec.severity_id AND
            csv.incident_subtype = 'INC' AND
            mfl.lookup_type = 'WIP_EAM_ACTIVITY_PRIORITY' AND
            trunc(sysdate) between trunc(nvl(csv.start_date_active,sysdate)) AND trunc(nvl(csv.end_date_active,sysdate));

    l_incident_urgency      NUMBER;

    -- Note: Need to perform all SR invalid validations, since it looks like the CS APIs do not give good messages

BEGIN

    -- Validate instance_number and instance_id
    IF (p_x_nonroutine_rec.instance_number IS NULL OR p_x_nonroutine_rec.instance_number = FND_API.G_MISS_CHAR)
    THEN
        IF (p_x_nonroutine_rec.instance_id is null or p_x_nonroutine_rec.instance_id = FND_API.G_MISS_NUM)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_INSTANCE_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        BEGIN
            -- Bug #4918818: APPSPERF fix
            -- There is no need to join with MTL/HOU since this is just a instance_number to instance_id validation,
            -- the check for whether the instance exists on an active unit is being done in Validate_UE_Details
            SELECT  csi.instance_id
            INTO    p_x_nonroutine_rec.instance_id
            FROM    csi_item_instances csi
            WHERE   trunc(nvl(csi.active_start_date, sysdate)) <= trunc(sysdate) and
                    trunc(nvl(csi.active_end_date, sysdate+1)) > trunc(sysdate) and
                    csi.instance_number = p_x_nonroutine_rec.instance_number;
        EXCEPTION
            WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_INSTANCE_INV');
                FND_MESSAGE.SET_TOKEN('INSTANCE', p_x_nonroutine_rec.instance_number);
                FND_MSG_PUB.ADD;
        END;
    END IF;

    IF (p_dml_operation = 'C')
    THEN
        -- Changes made for Bug # 5183032
        -- Commenting as the incident date can be any date prior to sysdate.
        -- p_x_nonroutine_rec.incident_date := sysdate;

        -- Validate and default SR type
        IF (p_x_nonroutine_rec.type_name is not null and p_x_nonroutine_rec.type_name <> FND_API.G_MISS_CHAR)
        THEN
            BEGIN
                SELECT  incident_type_id
                INTO    p_x_nonroutine_rec.type_id
                FROM    cs_incident_types_vl
                WHERE   name = p_x_nonroutine_rec.type_name and
                        cmro_flag = 'Y' and
                        incident_subtype = 'INC' and
                        trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and trunc(nvl(end_date_active, sysdate));
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_TYPE_INV');
                    FND_MESSAGE.SET_TOKEN('TYPE', p_x_nonroutine_rec.type_name);
                    FND_MSG_PUB.ADD;
            END;
        ELSIF (p_x_nonroutine_rec.type_id is null or p_x_nonroutine_rec.type_id = FND_API.G_MISS_NUM)
        THEN
            p_x_nonroutine_rec.type_id := fnd_profile.value('AHL_PRD_SR_TYPE');

            IF (p_x_nonroutine_rec.type_id is null or p_x_nonroutine_rec.type_id = FND_API.G_MISS_NUM)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_TYPE_NULL');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;

        -- Validate and default SR status
        IF (p_x_nonroutine_rec.status_name is not null and p_x_nonroutine_rec.status_name <> FND_API.G_MISS_CHAR)
        THEN
            BEGIN
                SELECT  incident_status_id
                INTO    p_x_nonroutine_rec.status_id
                FROM    cs_incident_statuses_vl
                WHERE   name = p_x_nonroutine_rec.status_name and
                        trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and trunc(nvl(end_date_active, sysdate));
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_STATUS_INV');
                    FND_MESSAGE.SET_TOKEN('STATUS', p_x_nonroutine_rec.status_name);
                    FND_MSG_PUB.ADD;
            END;
        ELSIF (p_x_nonroutine_rec.status_id is null or p_x_nonroutine_rec.status_id = FND_API.G_MISS_NUM)
        THEN
            p_x_nonroutine_rec.status_id := nvl(fnd_profile.value('AHL_PRD_SR_STATUS'), G_SR_OPEN_STATUS_ID);
        END IF;

        -- Validate and default SR severity
        IF (p_x_nonroutine_rec.severity_name is not null and p_x_nonroutine_rec.severity_name <> FND_API.G_MISS_CHAR)
        THEN
            BEGIN
                SELECT  incident_severity_id
                INTO    p_x_nonroutine_rec.severity_id
                FROM    cs_incident_severities_vl
                WHERE   name = p_x_nonroutine_rec.severity_name and
                        trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and trunc(nvl(end_date_active, sysdate));
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_SEVERITY_INV');
                    FND_MESSAGE.SET_TOKEN('SEVERITY', p_x_nonroutine_rec.severity_name);
                    FND_MSG_PUB.ADD;
            END;
        ELSIF (p_x_nonroutine_rec.severity_id is null or p_x_nonroutine_rec.severity_id = FND_API.G_MISS_NUM)
        THEN
            p_x_nonroutine_rec.severity_id := fnd_profile.value('AHL_PRD_SR_SEVERITY');

            IF (p_x_nonroutine_rec.severity_id is null or p_x_nonroutine_rec.severity_id = FND_API.G_MISS_NUM)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_SEVERITY_NULL');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;

        -- Validate severity against WIP_EAM_ACTIVITY_PRIORITY
        /*IF (p_x_nonroutine_rec.severity_id is not null and p_x_nonroutine_rec.severity_id <> FND_API.G_MISS_NUM)
        THEN
            OPEN cs_severity_in_eam_priority;
            FETCH cs_severity_in_eam_priority INTO l_dummy_varchar;
            IF (cs_severity_in_eam_priority%NOTFOUND) THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_SEV_EAM_INV');
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE cs_severity_in_eam_priority;
        END IF;*/

        -- Retrieve instance customer id
        SELECT  NVL(OWNER_PARTY_ID, -1)
        INTO    l_instance_owner_id
        FROM    csi_item_instances
        WHERE   instance_id = p_x_nonroutine_rec.instance_id;

        -- Validate and default customer...
        IF (p_x_nonroutine_rec.customer_name IS NOT NULL AND p_x_nonroutine_rec.customer_name <> FND_API.G_MISS_CHAR)
        THEN
            BEGIN
                SELECT  party_id, party_type
                INTO    p_x_nonroutine_rec.customer_id, p_x_nonroutine_rec.customer_type
                FROM    hz_parties
                WHERE   status = 'A' AND
                        party_type IN ('PERSON', 'ORGANIZATION') AND
                        party_name = p_x_nonroutine_rec.customer_name AND
                        party_id = NVL(p_x_nonroutine_rec.customer_id, party_id);
                        --AMSRINIV. Bug 5199456. Added last AND condition to the above query.
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_CUST_NAME_INVALID');
                    FND_MESSAGE.SET_TOKEN('CUST_NAME', p_x_nonroutine_rec.customer_name);
                    FND_MSG_PUB.ADD;
                WHEN TOO_MANY_ROWS THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_CUST_NAME_NOT_UNIQUE');
                    FND_MESSAGE.SET_TOKEN('CUST_NAME', p_x_nonroutine_rec.customer_name);
                    FND_MSG_PUB.ADD;
            END;

            -- Validate user-input customer against instance owner...
            IF (nvl(p_x_nonroutine_rec.customer_id, -1) <> l_instance_owner_id)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_CUSTOMER_NOMATCH');
                FND_MSG_PUB.ADD;
            END IF;
        ELSIF (p_x_nonroutine_rec.customer_id IS NULL or p_x_nonroutine_rec.customer_id = FND_API.G_MISS_NUM)
        THEN
            p_x_nonroutine_rec.customer_id := l_instance_owner_id;

            -- Default customer_type if customer_id is read from profile
            IF (p_x_nonroutine_rec.customer_id IS NOT NULL AND p_x_nonroutine_rec.customer_id <> FND_API.G_MISS_NUM)
            THEN
                SELECT  party_name, party_type
                INTO    p_x_nonroutine_rec.customer_name, p_x_nonroutine_rec.customer_type
                FROM    hz_parties
                WHERE   status = 'A' AND
                        party_type IN ('PERSON', 'ORGANIZATION') AND
                        party_id = p_x_nonroutine_rec.customer_id;
            END IF;
        END IF;

        -- Error if customer_type is NULL and customer_id NOT NULL
        IF
        (
            p_x_nonroutine_rec.customer_id is not null AND p_x_nonroutine_rec.customer_id <> FND_API.G_MISS_NUM
            AND
            (p_x_nonroutine_rec.customer_type is null or p_x_nonroutine_rec.customer_type = FND_API.G_MISS_CHAR)
        )
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME,'AHL_UMP_NR_CUST_TYPE_NULL');
            FND_MSG_PUB.ADD;
        END IF;

        -- Validate and contact name and type... Error if contact_type is NULL and contact_id NOT NULL
        IF (p_x_nonroutine_rec.contact_name IS NOT NULL AND p_x_nonroutine_rec.contact_name <> FND_API.G_MISS_CHAR)
        THEN
            BEGIN
                IF (p_x_nonroutine_rec.contact_type in ('PARTY_RELATIONSHIP', 'PERSON'))
                THEN
                    SELECT  party_id
                    INTO    p_x_nonroutine_rec.contact_id
                    FROM    hz_parties
                    WHERE   status = 'A' AND
                            party_name = p_x_nonroutine_rec.contact_name;
                ELSIF (p_x_nonroutine_rec.contact_type = 'EMPLOYEE')
                THEN
                    -- Bug #4918818: APPSPERF fix
                    -- Using per_people_x here, since it already has the inactive person check on per_people_f
                    SELECT  person_id
                    INTO    p_x_nonroutine_rec.contact_id
                    FROM    per_people_x
                    WHERE   full_name = p_x_nonroutine_rec.contact_name;
                ELSE
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_CONT_TYPE_INV');
                    FND_MESSAGE.SET_TOKEN('CONT_TYPE', p_x_nonroutine_rec.contact_type);
                    FND_MSG_PUB.ADD;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_CONT_NAME_INVALID');
                    FND_MESSAGE.SET_TOKEN('CONT_NAME', p_x_nonroutine_rec.contact_name);
                    FND_MSG_PUB.ADD;
                WHEN TOO_MANY_ROWS THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_CONT_NAME_NOT_UNIQUE');
                    FND_MESSAGE.SET_TOKEN('CONT_NAME', p_x_nonroutine_rec.contact_name);
                    FND_MSG_PUB.ADD;
            END;
        END IF;

        -- Error if problem_summary NULL
        IF (p_x_nonroutine_rec.problem_summary is null or p_x_nonroutine_rec.problem_summary = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_SUMMARY_NULL');
            FND_MSG_PUB.ADD;
        END IF;

        -- bachandr added following validation for Bug # 6447467 (Base ER # 5571440)
        -- Bug # 6447467 -- start
        -- Check if resolution_code is not null. If resolution_code
        -- is null then return error message.

        IF ( nvl(fnd_profile.value('AHL_SR_RESL_CODE_COMP'), 'N') = 'Y') THEN

          IF ( p_x_nonroutine_rec.resolution_code IS NULL OR
               p_x_nonroutine_rec.resolution_code = FND_API.G_MISS_CHAR) THEN

                       Fnd_Message.SET_NAME(G_APP_NAME,'AHL_PRD_RESL_CODE_REQ');
                       Fnd_Msg_Pub.ADD;
          END IF;

        END IF;

        -- Validate if expected resolution date is passed, it is greater than the incident date
        IF (p_x_nonroutine_rec.expected_resolution_date is not null and p_x_nonroutine_rec.expected_resolution_date <> FND_API.G_MISS_DATE and trunc(p_x_nonroutine_rec.expected_resolution_date) < trunc(sysdate))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_EXP_RES_DATE_INV');
            FND_MSG_PUB.ADD;
        END IF;

        -- Validate if the incident date is greater than the sysdate
        -- Changes made for Bug # 5183032
        IF (p_x_nonroutine_rec.incident_date is not null and p_x_nonroutine_rec.incident_date <> FND_API.G_MISS_DATE and trunc(p_x_nonroutine_rec.incident_date) > trunc(sysdate))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_INC_DATE_INV');
            FND_MSG_PUB.ADD;
        END IF;

    ELSIF(p_dml_operation = 'U')
    THEN
        -- Incident exists, number is not changed, date is not changed
        OPEN cs_incident_exists;
        FETCH cs_incident_exists INTO l_incident_number, l_incident_date;
        IF (cs_incident_exists%NOTFOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME,'AHL_UMP_NR_INC_INV');
            FND_MSG_PUB.ADD;
            CLOSE cs_incident_exists;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_incident_number <> p_x_nonroutine_rec.incident_number)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME,'AHL_UMP_NR_NUM_INV');
            FND_MSG_PUB.ADD;
            CLOSE cs_incident_exists;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE cs_incident_exists;

        -- Validate status_id is not null
        IF (p_x_nonroutine_rec.status_id is null or p_x_nonroutine_rec.status_id = FND_API.G_MISS_NUM)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME,'AHL_UMP_NR_STATUS_NULL');
            FND_MSG_PUB.ADD;
        END IF;

        -- Validate type_id is not null
        IF (p_x_nonroutine_rec.type_id is null or p_x_nonroutine_rec.type_id = FND_API.G_MISS_NUM)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME,'AHL_UMP_NR_TYPE_NULL');
            FND_MSG_PUB.ADD;
        END IF;

        -- Error if problem_summary NULL
        IF (p_x_nonroutine_rec.problem_summary is null or p_x_nonroutine_rec.problem_summary = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_SUMMARY_NULL');
            FND_MSG_PUB.ADD;
        END IF;

        -- bachandr added following validation for Bug # 6447467 (Base ER # 5571440)
        -- Bug # 6447467 -- start
        -- Check if resolution_code is not null. If resolution_code
        -- is null then return error message.

        IF ( nvl(fnd_profile.value('AHL_SR_RESL_CODE_COMP'), 'N') = 'Y') THEN

          IF ( p_x_nonroutine_rec.resolution_code IS NULL OR
               p_x_nonroutine_rec.resolution_code = FND_API.G_MISS_CHAR) THEN

                       Fnd_Message.SET_NAME(G_APP_NAME,'AHL_PRD_RESL_CODE_REQ');
                       Fnd_Msg_Pub.ADD;
          END IF;

        END IF;

        -- Validate if the expected resolution date is not null and that it is not lesser than the Incident Request Date
        -- Changes made for Bug # 5183032
        IF (p_x_nonroutine_rec.expected_resolution_date is not null and p_x_nonroutine_rec.expected_resolution_date <> FND_API.G_MISS_DATE and trunc(p_x_nonroutine_rec.expected_resolution_date) < trunc(l_incident_date))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UMP_NR_EXP_RES_DATE_INV');
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    -- Validate resolution_code and problem_code...

END Validate_SR_Details;

PROCEDURE Process_MO_procedures
(
    p_unit_effectivity_id   IN          NUMBER,
    p_unit_deferral_id      IN          NUMBER,
    p_unit_deferral_ovn     IN          NUMBER,
    p_ata_sequence_id       IN          NUMBER,
    p_cs_incident_id        IN          NUMBER,
    p_csi_item_instance_id  IN          NUMBER)
IS

  -- get service request details.
  cursor cs_inc_csr (p_cs_incident_id IN NUMBER)
  is
      select incident_severity_id, customer_id, caller_type,
             nvl(incident_occurred_date,incident_date) incident_occurred_date,
             expected_resolution_date , object_version_number, incident_number
      from   cs_incidents_all_b
      where  incident_id = p_cs_incident_id;

  -- added vst.close_date_time, wdj.scheduled_start_date as required by bug# 7701304
  CURSOR GetWoName(p_ue_id IN NUMBER)
  Is
    Select wo.workorder_name, tsk.visit_id,
           wdj.scheduled_start_date, vst.close_date_time
    from ahl_workorders wo, ahl_visit_tasks_b tsk, wip_discrete_jobs wdj,
         ahl_visits_b vst
    where wo.visit_task_id = tsk.visit_task_id
    and   tsk.visit_id = vst.visit_id
    and   wdj.wip_entity_id = wo.wip_entity_id
    and   tsk.unit_effectivity_id = p_ue_id
    and   tsk.task_type_code IN ('SUMMARY','UNASSOCIATED');

  -- get primary contact if exists.
  cursor prim_contact_csr (p_cs_incident_id IN NUMBER)
  is
     select party_id, contact_type
     from   cs_sr_contact_points_v
     where  incident_id = p_cs_incident_id
       and primary_flag = 'Y';

  -- get ue details for SR created.
  cursor get_ue_detls(p_cs_incident_id IN NUMBER)
  is
     select cs.object_version_number, ue.unit_effectivity_id
     from   ahl_unit_effectivities_b UE, cs_incidents_all_b cs
     where  ue.cs_incident_id = cs.incident_id
       and  cs.incident_id = p_cs_incident_id;

  -- get default incident type.
  cursor default_incident_type_csr
  is
      SELECT INCIDENT_TYPE_ID
      FROM cs_incident_types_vl
      where INCIDENT_SUBTYPE = 'INC'
      AND CMRO_FLAG = 'Y'
      AND incident_type_id=fnd_profile.value('AHL_MCL_M_AND_O_SR_TYPE')
      AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
      AND trunc(nvl(end_date_active,sysdate));

  -- query m and o procedures.
  cursor mo_procedures_csr (p_ata_sequence_id IN NUMBER)
  is
       select mr_header_id
       from ahl_mel_cdl_mo_procedures
       where ata_sequence_id = p_ata_sequence_id;

  -- get inventory item and organization id.
  CURSOR default_item_org_id(p_ue_id IN NUMBER) IS
   SELECT A.inventory_item_id,
            vst.organization_id
     FROM   AHL_VISIT_TASKS_B A, ahl_visits_b vst
     WHERE  a.visit_id = vst.visit_id
     and   A.unit_effectivity_id = p_ue_id
     AND  A.task_type_code IN ('SUMMARY','UNASSOCIATED')
     AND  rownum = 1;

  -- get urgency for the ata sequence.
  CURSOR get_urgency_details_csr (p_ata_sequence_id IN NUMBER)
  is
     select repair_time, sr_urgency_id
     from   ahl_mel_cdl_ata_sequences seq, ahl_repair_categories rep
     where  mel_cdl_ata_sequence_id = p_ata_sequence_id
       and  seq.repair_category_id = rep.repair_category_id;

  -- get deferral details.
  CURSOR deferral_ue_csr (p_deferral_id  IN NUMBER) IS
     SELECT unit_deferral_id,
            ata_sequence_id,
            unit_deferral_type,
            defer_reason_code,
            skip_mr_flag,
            affect_due_calc_flag,
            set_due_date,
            deferral_effective_on,
            remarks,approver_notes, user_deferral_type,
            attribute_category, attribute1,
            attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
            attribute8, attribute9, attribute10, attribute11, attribute12,
            attribute13, attribute14, attribute15
    FROM ahl_unit_deferrals_vl
    WHERE unit_deferral_id = p_deferral_id;

  -- get new UE for the incident ID deferred.
  CURSOR get_new_ue_csr (p_cs_incident_id IN NUMBER) IS
    SELECT unit_effectivity_id
    FROM   ahl_unit_effectivities_b
    WHERE  cs_incident_id = p_cs_incident_id
      AND  status_code IS NULL;

  l_service_request_rec   CS_SERVICEREQUEST_PUB.service_request_rec_type;
  l_notes_table           CS_ServiceRequest_PUB.notes_table;
  l_contacts_table        CS_ServiceRequest_PUB.contacts_table;
  l_contact_primary_flag  CONSTANT VARCHAR2(1) := 'Y';
  l_auto_assign           CONSTANT VARCHAR2(1) := 'N';

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_summary               VARCHAR2(2000); --cs_incidents_all_b.summary%TYPE;

  l_wo_name               ahl_workorders.workorder_name%TYPE;
  l_individual_owner      NUMBER;
  l_group_owner           NUMBER;
  l_individual_type       VARCHAR2(30);

  l_prim_contact_rec     prim_contact_csr%ROWTYPE;
  l_inc_rec              cs_inc_csr%ROWTYPE;
  l_incident_type_id     NUMBER;
  l_mr_sr_assoc_tbl      AHL_UMP_SR_PVT.SR_MR_Association_Tbl_Type;
  l_visit_id             NUMBER;
  l_new_incident_id      NUMBER;
  l_new_incident_number  cs_incidents_all_b.incident_number%TYPE;
  l_new_interaction_id   NUMBER;
  l_new_workflow_process_id  NUMBER;
  l_cs_object_version    NUMBER;
  l_new_ue_id            NUMBER;

  l_vwp_task_rec         AHL_VWP_RULES_PVT.Task_Rec_Type;
  l_deferral_rec         deferral_ue_csr%ROWTYPE;

  i                      NUMBER;
  l_wo_id                NUMBER;
  l_sr_urgency_id        NUMBER;
  l_repair_time          NUMBER;
  l_rowid                VARCHAR2(30);
  l_unit_deferral_id     NUMBER;
  l_workflow_process_id  NUMBER;
  l_interaction_id       NUMBER;
  l_new_cs_ue_id         NUMBER;

  -- added as required by bug# 7701304
  l_scheduled_start_date DATE;
  l_close_date_time      DATE;

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'At Start of procedure AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures');
  END IF;

  -- read sr attributes.
  OPEN cs_inc_csr(p_cs_incident_id);
  FETCH cs_inc_csr INTO l_inc_rec;
  IF (cs_inc_csr%NOTFOUND) THEN
    CLOSE cs_inc_csr;
    FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_INC_ERROR');
    FND_MESSAGE.set_token('INC_ID', p_cs_incident_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Debug Checkpoint.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
        fnd_log.string(G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                       'Starting SR Update');
  END IF;

  -- Update urgency and expected resolution date.
  OPEN get_urgency_details_csr (p_ata_sequence_id);
  FETCH get_urgency_details_csr INTO l_repair_time, l_sr_urgency_id;
  IF (get_urgency_details_csr%NOTFOUND) THEN
    CLOSE get_urgency_details_csr;
    FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_ATA_ERROR');
   FND_MESSAGE.set_token('ATA_ID', p_ata_sequence_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE get_urgency_details_csr;

  -- Update SR for the urgency and exp. resolution date.
  CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

  --l_service_request_rec.incident_id := p_cs_incident_id;
  --l_service_request_rec.object_version_number := l_inc_rec.object_version_number;
  l_service_request_rec.urgency_id := l_sr_urgency_id;
  IF (l_repair_time <> 0) THEN
     l_service_request_rec.exp_resolution_date := l_inc_rec.incident_occurred_date + trunc(l_repair_time/24);
  END IF;

  -- Call SR API.
  CS_SERVICEREQUEST_PUB.Update_ServiceRequest
    (
        p_api_version            => 3.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        p_request_id             => p_cs_incident_id,
        p_request_number         => NULL,
        p_audit_comments         => NULL,
        p_object_version_number  => l_inc_rec.object_version_number,
        p_resp_appl_id           => fnd_global.resp_appl_id,
        p_resp_id                => fnd_global.resp_id,
        p_last_updated_by        => fnd_global.user_id,
        p_last_update_login      => fnd_global.login_id,
        p_last_update_date       => sysdate,
        p_service_request_rec    => l_service_request_rec,
        p_notes                  => l_notes_table,
        p_contacts               => l_contacts_table,
        p_called_by_workflow     => NULL,
        p_workflow_process_id    => NULL,
        x_workflow_process_id    => l_workflow_process_id,
        x_interaction_id         => l_interaction_id
    );

   -- log debug message.
   IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                 'After call to Update Service Request :return_status:' || l_return_status);
   END IF;

   -- Raise errors if exceptions occur
   IF (upper(l_return_status) = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      FND_MSG_PUB.INITIALIZE;
   END IF;

  --apattark start for bug #9253024

  -- Get M and O procedures.
 	   -- Check existence of M and O procedures here to fix bug# 9253024
 	   i := 1;

 	   FOR mo_proc_rec IN mo_procedures_csr(p_ata_sequence_id) LOOP
 	      l_mr_sr_assoc_tbl(i).mr_header_id :=    mo_proc_rec.mr_header_id;
 	      l_mr_sr_assoc_tbl(i).OPERATION_FLAG  := 'C';
 	      l_mr_sr_assoc_tbl(i).RELATIONSHIP_CODE := 'PARENT';
 	      l_mr_sr_assoc_tbl(i).CSI_INSTANCE_ID   := p_csi_item_instance_id;

 	      i := i + 1;

 	   END LOOP;

 	   -- if M and O procedures exist then create SR and workorders; else proceed for
 	   -- deferral approval. Fix bug# 8511923
 	   IF (l_mr_sr_assoc_tbl.count <= 0) THEN
 	     GOTO skip_MO_SR;
 	   END IF;
  --apattark end for bug #9253024

  -- form summary.
  -- modified for bug# 7701304
  Open  GetWoName(p_unit_effectivity_id);
  Fetch GetWoName into l_wo_name, l_visit_id, l_scheduled_start_date, l_close_date_time;
  Close GetWoName;

  fnd_message.set_name('AHL','AHL_PRD_SR_SUMMARY');
  fnd_message.set_token('WORKORDER_NUM',rtrim(l_wo_name));
  fnd_message.set_token('INC_NUM', rtrim(l_inc_rec.incident_number));
  l_summary := fnd_message.get;

  -- log debug message.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                 'New Sr Summary is:' || l_summary);
  END IF;

  -- get incident type.
  Open default_incident_type_csr;
  Fetch default_incident_type_csr  INTO l_incident_type_id;
  IF ( default_incident_type_csr%NOTFOUND) THEN
     CLOSE default_incident_type_csr;
     FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_INCIDENT_ERROR');
     Fnd_Msg_Pub.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE default_incident_type_csr;

  --Initialize the SR record.
  CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

  -- Assign the SR rec values
  l_service_request_rec.type_id               := l_incident_type_id;
  -- initialized later below based on incident_occurred_date to fix bug# 7697685
  --l_service_request_rec.request_date          := sysdate;
  l_service_request_rec.status_id             := G_SR_OPEN_STATUS_ID;
  l_service_request_rec.severity_id           := l_inc_rec.incident_severity_id;
  l_service_request_rec.urgency_id            := l_sr_urgency_id;
  l_service_request_rec.summary               := substr(l_summary,1,240);
  l_service_request_rec.caller_type           := l_inc_rec.caller_type;
  l_service_request_rec.customer_id           := l_inc_rec.customer_id;
  l_service_request_rec.creation_program_code := 'AHL_ROUTINE';
  l_service_request_rec.customer_product_id    := p_csi_item_instance_id;
  -- added for bug fix - 5330932
  -- 01-19-09:modified to consider past dated NR to fix bug# 7697685
  IF (l_close_date_time < sysdate) THEN
    -- when logging a MEL/CDL in the past, use deferred SR's incident_occurred_date
    l_service_request_rec.incident_occurred_date := l_inc_rec.incident_occurred_date;
    l_service_request_rec.request_date           := l_service_request_rec.incident_occurred_date;
  ELSE
    l_service_request_rec.incident_occurred_date := sysdate;
    l_service_request_rec.request_date           := l_service_request_rec.incident_occurred_date;
  END IF;

  OPEN prim_contact_csr(p_cs_incident_id);
  FETCH prim_contact_csr INTO l_prim_contact_rec;
  IF (prim_contact_csr%FOUND) THEN
     l_contacts_table(1).party_id                := l_prim_contact_rec.party_id;
     l_contacts_table(1).contact_type            := l_prim_contact_rec.contact_type;
     l_contacts_table(1).primary_flag            := 'Y';
  END IF;
  CLOSE prim_contact_csr;

  -- item/org.
  open default_item_org_id(p_unit_effectivity_id);
  Fetch default_item_org_id  INTO l_service_request_rec.inventory_item_id,
                                  l_service_request_rec.inventory_org_id;
  IF (default_item_org_id%NOTFOUND  ) THEN
     FND_MESSAGE.SET_NAME ('AHL','AHL_PRD_DEFAULT_ORG_ERROR');
     Fnd_Msg_Pub.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Call to Service Request API

  CS_SERVICEREQUEST_PUB.Create_ServiceRequest(
    p_api_version           => 3.0,
    p_init_msg_list         => FND_API.G_TRUE,
    p_commit                => FND_API.G_FALSE,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_resp_appl_id          => NULL,
    p_resp_id               => NULL,
    p_user_id               => fnd_global.user_id,
    p_login_id              => fnd_global.conc_login_id,
    p_org_id                => NULL,
    p_request_id            => NULL,
    p_request_number        => NULL,
    p_service_request_rec   => l_service_request_rec,
    p_notes                 => l_notes_table,
    p_contacts              => l_contacts_table,
    p_auto_assign           => l_auto_assign,
    x_request_id            => l_new_incident_id,
    x_request_number        => l_new_incident_number,
    x_interaction_id        => l_new_interaction_id,
    x_workflow_process_id   => l_new_workflow_process_id,
    x_individual_owner      => l_individual_owner,
    x_group_owner           => l_individual_owner,
    x_individual_type       => l_individual_type
   );


   -- log debug message.
   IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
      fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                 'After call to Create Service Request :return_status:' || l_return_status);
   END IF;

   -- Raise errors if exceptions occur
   IF (upper(l_return_status) = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      FND_MSG_PUB.INITIALIZE;
   END IF;

  -- get object version number for the service request and the new ue id.
  OPEN get_ue_detls (l_new_incident_id);
  FETCH get_ue_detls INTO l_cs_object_version, l_new_ue_id;
  IF (get_ue_detls%NOTFOUND) THEN
    CLOSE get_ue_detls;
    FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_UE_ERROR');
    FND_MESSAGE.set_token('INC_ID', p_cs_incident_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  --apattark start for bug #9253024
  /*
  i := 1;

  FOR mo_proc_rec IN mo_procedures_csr(p_ata_sequence_id) LOOP
     l_mr_sr_assoc_tbl(i).mr_header_id :=    mo_proc_rec.mr_header_id;
     l_mr_sr_assoc_tbl(i).OPERATION_FLAG  := 'C';
     l_mr_sr_assoc_tbl(i).RELATIONSHIP_CODE := 'PARENT';
     l_mr_sr_assoc_tbl(i).CSI_INSTANCE_ID   := p_csi_item_instance_id;

     i := i + 1;

  END LOOP;
  */
 --apattark end for bug #9253024
 -- Add M and O procedures to the SR.

  IF (l_mr_sr_assoc_tbl.count > 0) THEN
     AHL_UMP_SR_PVT.Process_SR_MR_Associations
     (
      p_api_version           => 1.0,
      p_init_msg_list         => FND_API.G_FALSE,
      p_commit                => FND_API.G_FALSE,
      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
      --p_module_type           => 'MEL_CDL',
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_user_id               => fnd_global.user_id,
      p_login_id              => fnd_global.login_id,
      p_request_id            => l_new_incident_id,
      p_object_version_number => l_cs_object_version,
      p_request_number        => null,
      p_x_sr_mr_association_tbl  => l_mr_sr_assoc_tbl
     );

     -- log debug message.
     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
        fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'After call to Process_SR_MR_Associations :return_status:' || l_return_status);
        fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'systime:Visit Close Date:scheduled_start_date:' || to_char(sysdate, 'DD-MM-YYYY HH24:MI:SS')
                                                                    || to_char(l_close_date_time, 'DD-MM-YYYY HH24:MI:SS')
                                                                    || to_char(l_scheduled_start_date, 'DD-MM-YYYY HH24:MI:SS'));
     END IF;

     -- Raise errors if exceptions occur
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  -- Call VWP api to add the SR into the visit.
  l_vwp_task_rec.visit_id := l_visit_id;
  l_vwp_task_rec.unit_effectivity_id := l_new_ue_id;
  l_vwp_task_rec.service_request_id := l_new_incident_id;
  l_vwp_task_rec.task_type_code := 'PLANNED';
  -- added to fix bug# 7697685 when recording MEL/CDL in the past.
  IF (l_close_date_time < sysdate) THEN
    l_vwp_task_rec.task_start_date := l_scheduled_start_date;
  END IF;


  AHL_VWP_TASKS_PVT.Create_Task (
     p_api_version         => 1.0,
     p_init_msg_list       => Fnd_Api.g_false,
     p_commit              => Fnd_Api.g_false,
     p_validation_level    => Fnd_Api.g_valid_level_full,
     p_module_type         => 'SR',
     p_x_task_rec          => l_vwp_task_rec,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data);

  -- log debug message.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'After call to Create Task API:return_status:' || l_return_status);
  END IF;

  -- Raise errors if exceptions occur
  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF (l_close_date_time < sysdate) THEN
    -- Release MR.
    AHL_VWP_PROJ_PROD_PVT.Release_MR(
      p_api_version         => 1.0,
      p_init_msg_list       => Fnd_Api.G_FALSE,
      p_commit              => Fnd_Api.G_FALSE,
      p_validation_level    => Fnd_Api.G_VALID_LEVEL_FULL,
      p_module_type         => 'PROD',
      p_visit_id            => l_visit_id,
      p_unit_effectivity_id => l_new_ue_id,
      -- added p_recalculate_dates as required by bug# 7701304
      p_recalculate_dates   => 'N',
      -- fix for bug# 5498884. Created work orders should be in released status.
      p_release_flag       => 'Y',
      x_workorder_id       =>  l_wo_id,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);

  ELSE
    -- Release MR.
    AHL_VWP_PROJ_PROD_PVT.Release_MR(
      p_api_version         => 1.0,
      p_init_msg_list       => Fnd_Api.G_FALSE,
      p_commit              => Fnd_Api.G_FALSE,
      p_validation_level    => Fnd_Api.G_VALID_LEVEL_FULL,
      p_module_type         => 'PROD',
      p_visit_id            => l_visit_id,
      p_unit_effectivity_id => l_new_ue_id,
      -- fix for bug# 5498884. Created work orders should be in released status.
      p_release_flag       => 'Y',
      x_workorder_id       =>  l_wo_id,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);

  END IF;

  -- log debug message.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'After call to release workorders:return_status:' || l_return_status);
  END IF;

   -- Raise errors if exceptions occur
   IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

  IF (fnd_msg_pub.count_msg > 0) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

 --apattark start for bug #9253024
   <<skip_MO_SR>>
 --apattark end for bug #9253024

  -- make a call for automatic approval
  AHL_PRD_DF_PVT.process_approval_approved(
                         p_unit_deferral_id      => p_unit_deferral_id,
                         p_object_version_number => p_unit_deferral_ovn,
                                                    --l_deferral_rec.object_version_number,
                         p_new_status            => 'DEFERRED',
                         x_return_status         => l_return_status);

  IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     IF (fnd_log.level_error >= G_DEBUG_LEVEL)THEN
         fnd_log.string
              (
               fnd_log.level_error,
                'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval',
                'Can not go ahead with automatic approval because AHL_UMP_NONROUTINES_PVT.Initiate_Mel_Cdl_Approval threw error');
     END IF;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- create a new deferral row for the new ue ID. Copy the attributes from the old deferral record.
  OPEN deferral_ue_csr(p_unit_deferral_id);
  FETCH deferral_ue_csr INTO l_deferral_rec;
  IF (deferral_ue_csr%NOTFOUND) THEN
    CLOSE deferral_ue_csr;
    FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_UE_DEF_MISSING');
    FND_MESSAGE.set_token('UE_DEF', p_unit_deferral_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE deferral_ue_csr;

  -- find the new ue ID.
  OPEN get_new_ue_csr(p_cs_incident_id);
  FETCH get_new_ue_csr INTO l_new_cs_ue_id;
  IF (get_new_ue_csr%NOTFOUND) THEN
    CLOSE get_new_ue_csr;
    FND_MESSAGE.set_name('AHL', 'AHL_UMP_NR_NEW_UE_MISSING');
    FND_MESSAGE.set_token('INC_ID', p_cs_incident_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE get_new_ue_csr;

  -- Insert row.
  AHL_UNIT_DEFERRALS_PKG.insert_row(
            x_rowid => l_rowid,
            x_unit_deferral_id => l_unit_deferral_id,
            x_ata_sequence_id => l_deferral_rec.ata_sequence_id,
            x_object_version_number => 1,
            x_created_by => fnd_global.user_id,
            x_creation_date => sysdate,
            x_last_updated_by => fnd_global.user_id,
            x_last_update_date => sysdate,
            x_last_update_login => fnd_global.login_id,
            x_unit_effectivity_id => l_new_cs_ue_id,
            x_unit_deferral_type => l_deferral_rec.unit_deferral_type,
            x_set_due_date => l_deferral_rec.set_due_date,
            x_deferral_effective_on => l_deferral_rec.deferral_effective_on,
            x_approval_status_code => 'DEFERRED',
            x_defer_reason_code => l_deferral_rec.defer_reason_code,
            x_affect_due_calc_flag => l_deferral_rec.affect_due_calc_flag,
            x_skip_mr_flag => l_deferral_rec.skip_mr_flag,
            x_remarks => l_deferral_rec.remarks,
            x_approver_notes => l_deferral_rec.approver_notes,
            x_user_deferral_type => l_deferral_rec.user_deferral_type,
            x_attribute_category => null,
            x_attribute1 => null,
            x_attribute2 => null,
            x_attribute3 => null,
            x_attribute4 => null,
            x_attribute5 => null,
            x_attribute6 => null,
            x_attribute7 => null,
            x_attribute8 => null,
            x_attribute9 => null,
            x_attribute10 => null,
            x_attribute11 => null,
            x_attribute12 => null,
            x_attribute13 => null,
            x_attribute14 => null,
            x_attribute15 => null
            );

  -- log debug message.
  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_STMT,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'After insert into ahl_unit_deferrals table: deferral ID:' || l_unit_deferral_id);
  END IF;

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string(G_DEBUG_PROC,'ahl.plsql.AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures',
                   'At End of procedure AHL_UMP_NONROUTINES_PVT.Process_MO_Procedures');
  END IF;

END Process_MO_procedures;

End AHL_UMP_NONROUTINES_PVT;

/
