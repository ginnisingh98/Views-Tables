--------------------------------------------------------
--  DDL for Package Body AHL_MEL_CDL_ATA_SEQS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MEL_CDL_ATA_SEQS_PVT" AS
/* $Header: AHLVATAB.pls 120.10 2007/12/06 13:55:31 amsriniv ship $ */

------------------------------------
-- Common constants and variables --
------------------------------------
l_dummy_varchar             VARCHAR2(1);
l_dummy_number      NUMBER;
-----------------------------------
-- Non-spec Procedure Signatures --
-----------------------------------
PROCEDURE Check_Ata_Seq_Exists
(
    p_ata_sequence_id           IN  NUMBER,
    p_ata_object_version        IN  NUMBER
);

PROCEDURE Convert_Value_To_Id
(
    p_x_ata_sequences_rec       IN OUT NOCOPY   Ata_Sequence_Rec_Type
);

PROCEDURE Check_Mel_Cdl_Status
(
    p_mel_cdl_header_id         IN  NUMBER,
    p_ata_sequence_id           IN  NUMBER
);

PROCEDURE Check_MO_Proc_Exists
(
    p_mo_procedure_id           IN  NUMBER,
    p_mo_proc_object_version        IN  NUMBER
);

PROCEDURE Check_Inter_Reln_Exists
(
    p_mel_cdl_relationship_id           IN  NUMBER,
    p_rel_object_version        IN  NUMBER
);

--These are the common checks used for both Process_Mo_Procedure and Process_Ata_Relations
--This cursor checks if Ata Sequence Exists in mel_cdl_ata_sequences table
CURSOR validate_ata_seq
(
    ata_seq_id number
)
IS
    SELECT 'X'
    FROM
        ahl_mel_cdl_ata_sequences
    WHERE
        mel_cdl_ata_sequence_id = ata_seq_id;

-- This cursor is used to check if the MEL/CDL status is not in Draft and Approve Rejected
CURSOR val_mel_cdl_status
(
    ata_seq_id number
)
IS
    SELECT
        hdr.status_code
    FROM
        ahl_mel_cdl_ata_sequences ata,
        ahl_mel_cdl_headers hdr
    WHERE
        mel_cdl_ata_sequence_id = ata_seq_id
        AND ata.mel_cdl_header_id = hdr. mel_cdl_header_id;

------------------------------------------
-- Spec Procedure Process_Ata_Sequences --
------------------------------------------
PROCEDURE Process_Ata_Sequences
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
    p_x_ata_sequences_tbl       IN OUT NOCOPY   Ata_Sequence_Tbl_Type
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Process_Ata_Sequences';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    -- Define cursors
    CURSOR get_ata_details
    (
        p_ata_sequence_id number
    )
    IS
    SELECT  ata_code
    FROM    ahl_mel_cdl_ata_sequences
    WHERE   mel_cdl_ata_sequence_id = p_ata_sequence_id;

    l_ata_code                  VARCHAR2(30);

    CURSOR check_ata_unique
    (
        p_mel_cdl_header_id number,
        p_ata_code varchar2
    )
    IS
    SELECT  'x'
    FROM    ahl_mel_cdl_ata_sequences
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id AND
            ata_code = p_ata_code;

    CURSOR get_ata_notes
    (
        p_ata_sequence_id number
    )
    IS
    SELECT  jtf_note_id, note_status
    FROM    jtf_notes_vl
    WHERE   source_object_id = p_ata_sequence_id AND
            source_object_code = 'AHL_MEL_CDL';

    l_rec_idx                   NUMBER;

    l_note_rec                  get_ata_notes%rowtype;
    l_jtf_note_id               NUMBER;
    l_note_contexts_tbl         JTF_NOTES_PUB.jtf_note_contexts_tbl_type;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Process_Ata_Sequences_SP;

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
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module,
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body starts here
    IF (p_x_ata_sequences_tbl.COUNT > 0)
    THEN
        -- Iterate all delete records
        FOR l_rec_idx IN p_x_ata_sequences_tbl.FIRST..p_x_ata_sequences_tbl.LAST
        LOOP
            -- All common validations can be pushed into the initial 1st loop, since anyway the entire loop will be iterated

            -- Verify DML operation flag is right...
            IF (p_x_ata_sequences_tbl(l_rec_idx).dml_operation NOT IN ('C', 'U', 'D'))
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_INVALID_DML_REC');
                -- Invalid DML operation FIELD specified
                FND_MESSAGE.SET_TOKEN('FIELD', p_x_ata_sequences_tbl(l_rec_idx).dml_operation);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        -- Verify MEL/CDL is in DRAFT status and  change to DRAFT if APPROVAL_REJECTED; Also verify whether MEL/CDL information is provided
            Check_Mel_Cdl_Status(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_header_id, p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id);

            -- Delete specific validations and processing
            IF (p_x_ata_sequences_tbl(l_rec_idx).dml_operation = 'D')
            THEN
                -- For U/D, verify ATA sequence id + ovn is correct
                Check_Ata_Seq_Exists(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id, p_x_ata_sequences_tbl(l_rec_idx).object_version_number);

                -- Delete JTF Note(s) associated with the ATA sequence
                /* Cannot use the PVT API directly, following up with CAC Notes team on this...
                FOR l_note_rec IN get_ata_notes(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id)
                LOOP
                    CAC_NOTES_PVT.delete_note
                    (
                        l_note_rec.jtf_note_id,
                        l_return_status,
                        l_msg_count,
                        l_msg_data
                    );

                    -- Check Error Message stack.
                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
                        THEN
                            fnd_log.string
                            (
                                fnd_log.level_error,
                                l_debug_module,
                                x_msg_data
                            );
                        END IF;

                        -- Throwing unexpected error since this delete should have happened without any hiccup
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END LOOP;
                */

                -- Delete inter-relationships with other ATA sequences
                DELETE FROM ahl_mel_cdl_relationships
                WHERE ata_sequence_id = p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id
                OR related_ata_sequence_id = p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id;

                -- Delete Inter-relationships associated with the ATA sequence
                DELETE FROM ahl_mel_cdl_mo_procedures
                WHERE ata_sequence_id = p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id;

                -- Delete the ATA sequence itself
                DELETE FROM ahl_mel_cdl_ata_sequences
                WHERE mel_cdl_ata_sequence_id = p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_statement,
                        l_debug_module,
                        'Deleted ATA sequence [ata_sequence_id='||p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id||'] and all its associations'
                    );
                END IF;
            END IF;
        END LOOP;

        -- Iterate all update records
        FOR l_rec_idx IN p_x_ata_sequences_tbl.FIRST..p_x_ata_sequences_tbl.LAST
        LOOP
            IF (p_x_ata_sequences_tbl(l_rec_idx).dml_operation = 'U')
            THEN
                -- For U/D, verify ATA sequence id + ovn is correct
                Check_Ata_Seq_Exists(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id, p_x_ata_sequences_tbl(l_rec_idx).object_version_number);

                -- For update, ata_code should not change
                IF (p_x_ata_sequences_tbl(l_rec_idx).dml_operation = 'U')
                THEN
                    OPEN get_ata_details(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id);
                    FETCH get_ata_details INTO l_ata_code;
                    CLOSE get_ata_details;

                    IF (l_ata_code <> p_x_ata_sequences_tbl(l_rec_idx).ata_code)
                    THEN
                        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_ATA_CHG_UPD');
                        -- Cannot modify System Sequence from "OLDATA" to "ATA" for existing record
                        FND_MESSAGE.SET_TOKEN('OLDATA', l_ata_code);
                        FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                -- For C/U, verify ATA code is not null and correct, Repair Category is not null and correct, Installed Number and  Dispatch Number are okay
                Convert_Value_To_Id(p_x_ata_sequences_tbl(l_rec_idx));
--amsriniv. Begin
--amsriniv. Bug 6659422
/*
                IF (p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NULL OR p_x_ata_sequences_tbl(l_rec_idx).installed_number = FND_API.G_MISS_NUM)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_INST_NUM_MAND');
                    -- Installed Number for System Sequence "ATA" is invalid
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MSG_PUB.ADD;
                END IF;

                IF (p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NULL OR p_x_ata_sequences_tbl(l_rec_idx).dispatch_number = FND_API.G_MISS_NUM)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DISP_NUM_MAND');
                    -- Dispatch Number for System Sequence "ATA" is invalid
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MSG_PUB.ADD;
                END IF;
*/
                IF ((p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NOT NULL
                AND p_x_ata_sequences_tbl(l_rec_idx).dispatch_number < 0)
                OR (p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NOT NULL
                AND p_x_ata_sequences_tbl(l_rec_idx).installed_number < 0))
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DISP_INST_LESS_0');
                    -- Both Dispatch Number "DISP" and Installed Number "INST" for System Sequence "ATA" should be positive integers
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MESSAGE.SET_TOKEN('DISP', p_x_ata_sequences_tbl(l_rec_idx).dispatch_number);
                    FND_MESSAGE.SET_TOKEN('INST', p_x_ata_sequences_tbl(l_rec_idx).installed_number);
                    FND_MSG_PUB.ADD;
                END IF;

                IF (p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NOT NULL AND
                 p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NOT NULL AND
                 p_x_ata_sequences_tbl(l_rec_idx).dispatch_number > p_x_ata_sequences_tbl(l_rec_idx).installed_number)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DISP_MORE_INST');
                    -- Dispatch Number "DISP" for System Sequence "ATA" should be less than Installed Number "INST"
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MESSAGE.SET_TOKEN('DISP', p_x_ata_sequences_tbl(l_rec_idx).dispatch_number);
                    FND_MESSAGE.SET_TOKEN('INST', p_x_ata_sequences_tbl(l_rec_idx).installed_number);
                    FND_MSG_PUB.ADD;
                END IF;

                IF (p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NOT NULL AND
                 p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NULL)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_INST_MISSING');
                    -- Installed Number should be entered when Required(Dispatch) Number is entered.
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MESSAGE.SET_TOKEN('DISP', p_x_ata_sequences_tbl(l_rec_idx).dispatch_number);
                    FND_MESSAGE.SET_TOKEN('INST', p_x_ata_sequences_tbl(l_rec_idx).installed_number);
                    FND_MSG_PUB.ADD;
                END IF;
--amsriniv. End
                -- Check Error Message stack.
                x_msg_count := FND_MSG_PUB.count_msg;
                IF (x_msg_count > 0)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Default attributes for update
                p_x_ata_sequences_tbl(l_rec_idx).object_version_number  := p_x_ata_sequences_tbl(l_rec_idx).object_version_number + 1;

                -- Update record in backend
                UPDATE  ahl_mel_cdl_ata_sequences
                SET     OBJECT_VERSION_NUMBER   = p_x_ata_sequences_tbl(l_rec_idx).object_version_number,
                        LAST_UPDATE_DATE        = sysdate,
                        LAST_UPDATED_BY         = fnd_global.user_id,
                        LAST_UPDATE_LOGIN       = fnd_global.login_id,
                        REPAIR_CATEGORY_ID      = p_x_ata_sequences_tbl(l_rec_idx).repair_category_id,
                        INSTALLED_NUMBER        = p_x_ata_sequences_tbl(l_rec_idx).installed_number,
                        DISPATCH_NUMBER         = p_x_ata_sequences_tbl(l_rec_idx).dispatch_number,
                        ATTRIBUTE_CATEGORY      = p_x_ata_sequences_tbl(l_rec_idx).attribute_category,
                        ATTRIBUTE1              = p_x_ata_sequences_tbl(l_rec_idx).attribute1,
                        ATTRIBUTE2              = p_x_ata_sequences_tbl(l_rec_idx).attribute2,
                        ATTRIBUTE3              = p_x_ata_sequences_tbl(l_rec_idx).attribute3,
                        ATTRIBUTE4              = p_x_ata_sequences_tbl(l_rec_idx).attribute4,
                        ATTRIBUTE5              = p_x_ata_sequences_tbl(l_rec_idx).attribute5,
                        ATTRIBUTE6              = p_x_ata_sequences_tbl(l_rec_idx).attribute6,
                        ATTRIBUTE7              = p_x_ata_sequences_tbl(l_rec_idx).attribute7,
                        ATTRIBUTE8              = p_x_ata_sequences_tbl(l_rec_idx).attribute8,
                        ATTRIBUTE9              = p_x_ata_sequences_tbl(l_rec_idx).attribute9,
                        ATTRIBUTE10             = p_x_ata_sequences_tbl(l_rec_idx).attribute10,
                        ATTRIBUTE11             = p_x_ata_sequences_tbl(l_rec_idx).attribute11,
                        ATTRIBUTE12             = p_x_ata_sequences_tbl(l_rec_idx).attribute12,
                        ATTRIBUTE13             = p_x_ata_sequences_tbl(l_rec_idx).attribute13,
                        ATTRIBUTE14             = p_x_ata_sequences_tbl(l_rec_idx).attribute14,
                        ATTRIBUTE15             = p_x_ata_sequences_tbl(l_rec_idx).attribute15
                WHERE   MEL_CDL_ATA_SEQUENCE_ID = p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_statement,
                        l_debug_module,
                        'Updated ATA sequence [ata_sequence_id='||p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id||']'
                    );
                END IF;

                -- Update the JTF note for Remarks...
                IF (p_x_ata_sequences_tbl(l_rec_idx).remarks_note IS NOT NULL AND p_x_ata_sequences_tbl(l_rec_idx).remarks_note <> FND_API.G_MISS_CHAR)
                THEN
                    OPEN get_ata_notes(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id);
                    FETCH get_ata_notes INTO l_note_rec;
                    -- If the JTF note for Remarks already exists, update the same or create a new one...
                    IF (get_ata_notes%FOUND)
                    THEN
                        CLOSE get_ata_notes;

                        JTF_NOTES_PUB.Update_Note
                        (
                            p_api_version               => 1.0,
                            p_init_msg_list             => FND_API.G_FALSE,
                            p_commit                    => FND_API.G_FALSE,
                            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status             => l_return_status,
                            x_msg_count                 => l_msg_count,
                            x_msg_data                  => l_msg_data,
                            p_jtf_note_id               => l_note_rec.jtf_note_id,
                            p_entered_by                => fnd_global.user_id,
                            p_last_updated_by           => fnd_global.user_id,
                            p_last_update_date          => sysdate,
                            p_last_update_login         => fnd_global.login_id,
                            p_notes                     => substr(p_x_ata_sequences_tbl(l_rec_idx).remarks_note, 1, 2000),
                            p_notes_detail              => p_x_ata_sequences_tbl(l_rec_idx).remarks_note,
                            p_append_flag               => 'N',
                            p_note_status               => l_note_rec.note_status,
                            p_note_type                 => 'AHL_MEL_CDL',
                            p_jtf_note_contexts_tab     => l_note_contexts_tbl
                        );

                        -- Check Error Message stack.
                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                        THEN
                            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
                            THEN
                                fnd_log.string
                                (
                                    fnd_log.level_error,
                                    l_debug_module,
                                    l_msg_data
                                );
                            END IF;

                            -- Throwing unexpected error since this delete should have happened without any hiccup
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                        THEN
                            fnd_log.string
                            (
                                fnd_log.level_statement,
                                l_debug_module,
                                'Updated Remarks Note [jtf_note_id='||l_note_rec.jtf_note_id||']'
                            );
                        END IF;
                    ELSE
                        CLOSE get_ata_notes;

                        JTF_NOTES_PUB.Create_Note
                        (
                            p_parent_note_id            => null,
                            p_jtf_note_id               => null,
                            p_api_version               => 1.0,
                            p_init_msg_list             => FND_API.G_FALSE,
                            p_commit                    => FND_API.G_FALSE,
                            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status             => l_return_status,
                            x_msg_count                 => l_msg_count,
                            x_msg_data                  => l_msg_data,
                            p_org_id                    => null,
                            p_source_object_id          => p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id,
                            p_source_object_code        => 'AHL_MEL_CDL',
                            p_notes                     => substr(p_x_ata_sequences_tbl(l_rec_idx).remarks_note, 1, 2000),
                            p_notes_detail              => p_x_ata_sequences_tbl(l_rec_idx).remarks_note,
                            p_note_status               => 'E',
                            p_entered_by                => fnd_global.user_id,
                            p_entered_date              => sysdate,
                            x_jtf_note_id               => l_jtf_note_id,
                            p_last_updated_by           => fnd_global.user_id,
                            p_last_update_date          => sysdate,
                            p_created_by                => fnd_global.user_id,
                            p_creation_date             => sysdate,
                            p_last_update_login         => fnd_global.login_id,
                            p_attribute1                => null,
                            p_attribute2                => null,
                            p_attribute3                => null,
                            p_attribute4                => null,
                            p_attribute5                => null,
                            p_attribute6                => null,
                            p_attribute7                => null,
                            p_attribute8                => null,
                            p_attribute9                => null,
                            p_attribute10               => null,
                            p_attribute11               => null,
                            p_attribute12               => null,
                            p_attribute13               => null,
                            p_attribute14               => null,
                            p_attribute15               => null,
                            p_context                   => null,
                            p_note_type                 => 'AHL_MEL_CDL',
                            p_jtf_note_contexts_tab     => l_note_contexts_tbl
                        );

                        -- Check Error Message stack.
                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                        THEN
                            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
                            THEN
                                fnd_log.string
                                (
                                    fnd_log.level_error,
                                    l_debug_module,
                                    l_msg_data
                                );
                            END IF;

                            -- Throwing unexpected error since this delete should have happened without any hiccup
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                        THEN
                            fnd_log.string
                            (
                                fnd_log.level_statement,
                                l_debug_module,
                                'Create new Remarks Note with [jtf_note_id='||l_jtf_note_id||']'
                            );
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        -- Iterate all create records
        FOR l_rec_idx IN p_x_ata_sequences_tbl.FIRST..p_x_ata_sequences_tbl.LAST
        LOOP
            IF (p_x_ata_sequences_tbl(l_rec_idx).dml_operation = 'C')
            THEN
                -- For C/U, verify ATA code is not null and  correct, Repair Category is not null and correct, Installed Number and Dispatch Number are okay
                Convert_Value_To_Id(p_x_ata_sequences_tbl(l_rec_idx));

--amsriniv. Begin
--amsriniv. Bug 6659422
/*
                IF (p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NULL OR p_x_ata_sequences_tbl(l_rec_idx).installed_number = FND_API.G_MISS_NUM)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_INST_NUM_MAND');
                    -- Installed Number for System Sequence "ATA" is invalid
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MSG_PUB.ADD;
                END IF;

                IF (p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NULL OR p_x_ata_sequences_tbl(l_rec_idx).dispatch_number = FND_API.G_MISS_NUM)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DISP_NUM_MAND');
                    -- Dispatch Number for System Sequence "ATA" is invalid
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MSG_PUB.ADD;
                END IF;
*/
                IF ((p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NOT NULL AND
                p_x_ata_sequences_tbl(l_rec_idx).dispatch_number < 0) OR
                (p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NOT NULL
                AND p_x_ata_sequences_tbl(l_rec_idx).installed_number < 0))
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DISP_INST_LESS_0');
                    -- Both Dispatch Number "DISP" and Installed Number "INST" for System Sequence "ATA" should be positive integers
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MESSAGE.SET_TOKEN('DISP', p_x_ata_sequences_tbl(l_rec_idx).dispatch_number);
                    FND_MESSAGE.SET_TOKEN('INST', p_x_ata_sequences_tbl(l_rec_idx).installed_number);
                    FND_MSG_PUB.ADD;
                END IF;

                IF (p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NOT NULL AND
                 p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NOT NULL AND
                 p_x_ata_sequences_tbl(l_rec_idx).dispatch_number > p_x_ata_sequences_tbl(l_rec_idx).installed_number)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DISP_MORE_INST');
                    -- Dispatch Number "DISP" for System Sequence "ATA" should be less than Installed Number "INST"
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MESSAGE.SET_TOKEN('DISP', p_x_ata_sequences_tbl(l_rec_idx).dispatch_number);
                    FND_MESSAGE.SET_TOKEN('INST', p_x_ata_sequences_tbl(l_rec_idx).installed_number);
                    FND_MSG_PUB.ADD;
                END IF;

                IF (p_x_ata_sequences_tbl(l_rec_idx).dispatch_number IS NOT NULL AND
                 p_x_ata_sequences_tbl(l_rec_idx).installed_number IS NULL)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_INST_MISSING');
                    -- Installed Number should be entered when Required(Dispatch) Number is entered.
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MESSAGE.SET_TOKEN('DISP', p_x_ata_sequences_tbl(l_rec_idx).dispatch_number);
                    FND_MESSAGE.SET_TOKEN('INST', p_x_ata_sequences_tbl(l_rec_idx).installed_number);
                    FND_MSG_PUB.ADD;
                END IF;
--amsriniv. End


                -- For create, validate whether ata_code is unique
                OPEN check_ata_unique(p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_header_id, p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                FETCH check_ata_unique INTO l_dummy_varchar;
                IF (check_ata_unique%FOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_ATA_EXISTS');
                    -- System Sequence "ATA" is already associated with the MEL/CDL
                    FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_tbl(l_rec_idx).ata_code);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE check_ata_unique;

                -- Check Error Message stack.
                x_msg_count := FND_MSG_PUB.count_msg;
                IF (x_msg_count > 0)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Default attributes for create
                p_x_ata_sequences_tbl(l_rec_idx).object_version_number  := 1;
                IF (p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id IS NULL)
                THEN
                    SELECT ahl_mel_cdl_ata_sequences_s.NEXTVAL INTO p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id FROM DUAL;
                END IF;

                -- Insert record into backend
                INSERT INTO ahl_mel_cdl_ata_sequences
                (
                    MEL_CDL_ATA_SEQUENCE_ID,
                    OBJECT_VERSION_NUMBER,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    MEL_CDL_HEADER_ID,
                    REPAIR_CATEGORY_ID,
                    ATA_CODE,
                    INSTALLED_NUMBER,
                    DISPATCH_NUMBER,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15
                )
                VALUES
                (
                    p_x_ata_sequences_tbl(l_rec_idx).MEL_CDL_ATA_SEQUENCE_ID,
                    p_x_ata_sequences_tbl(l_rec_idx).OBJECT_VERSION_NUMBER,
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    p_x_ata_sequences_tbl(l_rec_idx).MEL_CDL_HEADER_ID,
                    p_x_ata_sequences_tbl(l_rec_idx).REPAIR_CATEGORY_ID,
                    p_x_ata_sequences_tbl(l_rec_idx).ATA_CODE,
                    p_x_ata_sequences_tbl(l_rec_idx).INSTALLED_NUMBER,
                    p_x_ata_sequences_tbl(l_rec_idx).DISPATCH_NUMBER,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE_CATEGORY,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE1,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE2,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE3,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE4,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE5,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE6,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE7,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE8,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE9,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE10,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE11,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE12,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE13,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE14,
                    p_x_ata_sequences_tbl(l_rec_idx).ATTRIBUTE15
                )
                RETURNING MEL_CDL_ATA_SEQUENCE_ID INTO p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_statement,
                        l_debug_module,
                        'Created new ATA sequence [ata_sequence_id='||p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id||']'
                    );
                END IF;

                -- Enter the JTF note for Remarks...
                IF (p_x_ata_sequences_tbl(l_rec_idx).remarks_note IS NOT NULL AND p_x_ata_sequences_tbl(l_rec_idx).remarks_note <> FND_API.G_MISS_CHAR)
                THEN
                    -- Create a new JTF note for Remarks, ofcourse it cannot exist before the ATA sequence is created...
                    JTF_NOTES_PUB.Create_Note
                    (
                        p_parent_note_id            => null,
                        p_jtf_note_id               => null,
                        p_api_version               => 1.0,
                        p_init_msg_list             => FND_API.G_FALSE,
                        p_commit                    => FND_API.G_FALSE,
                        p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                        x_return_status             => l_return_status,
                        x_msg_count                 => l_msg_count,
                        x_msg_data                  => l_msg_data,
                        p_org_id                    => null,
                        p_source_object_id          => p_x_ata_sequences_tbl(l_rec_idx).mel_cdl_ata_sequence_id,
                        p_source_object_code        => 'AHL_MEL_CDL',
                        p_notes                     => substr(p_x_ata_sequences_tbl(l_rec_idx).remarks_note, 1, 2000),
                        p_notes_detail              => p_x_ata_sequences_tbl(l_rec_idx).remarks_note,
                        p_note_status               => 'E',
                        p_entered_by                => fnd_global.user_id,
                        p_entered_date              => sysdate,
                        x_jtf_note_id               => l_jtf_note_id,
                        p_last_updated_by           => fnd_global.user_id,
                        p_last_update_date          => sysdate,
                        p_created_by                => fnd_global.user_id,
                        p_creation_date             => sysdate,
                        p_last_update_login         => fnd_global.login_id,
                        p_attribute1                => null,
                        p_attribute2                => null,
                        p_attribute3                => null,
                        p_attribute4                => null,
                        p_attribute5                => null,
                        p_attribute6                => null,
                        p_attribute7                => null,
                        p_attribute8                => null,
                        p_attribute9                => null,
                        p_attribute10               => null,
                        p_attribute11               => null,
                        p_attribute12               => null,
                        p_attribute13               => null,
                        p_attribute14               => null,
                        p_attribute15               => null,
                        p_context                   => null,
                        p_note_type                 => 'AHL_MEL_CDL',
                        p_jtf_note_contexts_tab     => l_note_contexts_tbl
                    );

                    -- Check Error Message stack.
                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                    THEN
                        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
                        THEN
                            fnd_log.string
                            (
                                fnd_log.level_error,
                                l_debug_module,
                                l_msg_data
                            );
                        END IF;

                        -- Throwing unexpected error since this delete should have happened without any hiccup
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                    THEN
                        fnd_log.string
                        (
                            fnd_log.level_statement,
                            l_debug_module,
                            'Create new Remarks Note with [jtf_note_id='||l_jtf_note_id||']'
                        );
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END IF;
    -- API body ends here

    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module,
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
        Rollback to Process_Ata_Sequences_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Ata_Sequences_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Ata_Sequences_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Process_Ata_Sequences',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Process_Ata_Sequences;

------------------------------------------
-- Spec Procedure Process_Mo_Procedures --
------------------------------------------
PROCEDURE Process_Mo_Procedures
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_mo_procedures_tbl       IN OUT NOCOPY   Mo_Procedure_Tbl_Type
)
IS

    -- Define cursors
    -- This cursor is used to validate the mr_header_id .is of type MO_Proc
    CURSOR validate_mr_header_id
    (
        mr_header_id in number
    )
    IS
        SELECT 'x'
        FROM
            ahl_mr_headers_b
        WHERE
            mr_header_id  = mr_header_id
            and upper(program_type_code) = upper('MO_PROC');
            --and upper(mr_status_code) = upper('COMPLETE')
            --and TRUNC(SYSDATE) between TRUNC(NVL(EFFECTIVE_FROM, SYSDATE)) and TRUNC(NVL(EFFECTIVE_TO, SYSDATE));

	 -- Define cursors
    -- This cursor is used to validate the mr_header_id is complete and is not enddated
    CURSOR validate_mr_header_status
    (
        mr_header_id in number
    )
    IS
        SELECT mr_status_code
        FROM
            ahl_mr_headers_b
        WHERE
            mr_header_id  = mr_header_id
            --and upper(program_type_code) = upper('MO_PROC')
            and upper(mr_status_code) = upper('COMPLETE')
			and TRUNC(SYSDATE) between TRUNC(NVL(EFFECTIVE_FROM, SYSDATE)) and TRUNC(NVL(EFFECTIVE_TO, SYSDATE));


    -- This cursor is used to cross check if mr_header_exists when given the title and version number
    CURSOR get_mr_header_id
    (
        mr_title in varchar2,
        mr_version number
    )
    IS
        SELECT mr_header_id
        FROM
            ahl_mr_headers_b
        WHERE
            upper(TITLE) = upper(mr_title)
            and version_number = mr_version
            and TRUNC(SYSDATE) between TRUNC(NVL(EFFECTIVE_FROM, SYSDATE)) and TRUNC(NVL(EFFECTIVE_TO, SYSDATE));

    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Process_Mo_Procedures';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_status                    VARCHAR2(30);

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Process_Mo_Procedures_SP;

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
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module,
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body starts here
    IF (p_x_mo_procedures_tbl.COUNT > 0)
    THEN
        -- Iterate all delete records
        FOR l_rec_idx IN p_x_mo_procedures_tbl.FIRST..p_x_mo_procedures_tbl.LAST
        LOOP

           -- Verify DML operation flag is right...
            IF (p_x_mo_procedures_tbl(l_rec_idx).dml_operation NOT IN ( 'C', 'D'))
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_INVALID_DML_REC');
                -- Invalid DML operation FIELD specified
                FND_MESSAGE.SET_TOKEN('FIELD', p_x_mo_procedures_tbl(l_rec_idx).dml_operation);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Perform Deletion
            IF (p_x_mo_procedures_tbl(l_rec_idx).dml_operation = 'D')
            THEN

                -- For U/D, verify mel_cdl_mo_procedures_id + ovn is correct
                Check_MO_Proc_Exists(p_x_mo_procedures_tbl(l_rec_idx).mel_cdl_mo_procedure_id, p_x_mo_procedures_tbl(l_rec_idx).object_version_number);

                -- Delete MandO procedures from the MO Procedure Table
                DELETE FROM ahl_mel_cdl_mo_procedures
                WHERE mel_cdl_mo_procedure_id = p_x_mo_procedures_tbl(l_rec_idx).mel_cdl_mo_procedure_id;

            END IF;
        END LOOP;

        --Perform Create
        FOR l_rec_idx IN p_x_mo_procedures_tbl.FIRST..p_x_mo_procedures_tbl.LAST
        LOOP
            IF (p_x_mo_procedures_tbl(l_rec_idx).dml_operation = 'C')
            THEN
                --Check if mr_header_id is of program type MO Procedure
                IF (p_x_mo_procedures_tbl(l_rec_idx).mr_header_id IS NOT NULL or p_x_mo_procedures_tbl(l_rec_idx).mr_header_id <> FND_API.G_MISS_NUM)
                THEN
                    OPEN validate_mr_header_id( p_x_mo_procedures_tbl(l_rec_idx).mr_header_id);
                    FETCH validate_mr_header_id  INTO l_dummy_varchar;

                    IF (validate_mr_header_id%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_MO_MR_NOTMO_INV');
                        FND_MESSAGE.SET_TOKEN('MRTITLE',p_x_mo_procedures_tbl(l_rec_idx).mr_title);
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE validate_mr_header_id;

					-- Check if mr_header_id is in complete status
					OPEN validate_mr_header_status( p_x_mo_procedures_tbl(l_rec_idx).mr_header_id);
                    FETCH validate_mr_header_status  INTO l_status;

                    IF (validate_mr_header_status%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_MO_STATUS_INV');
                        FND_MESSAGE.SET_TOKEN('MRTITLE',p_x_mo_procedures_tbl(l_rec_idx).mr_title);
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE validate_mr_header_status;

                ELSIF (p_x_mo_procedures_tbl(l_rec_idx).mr_header_id IS  NULL or p_x_mo_procedures_tbl(l_rec_idx).mr_header_id =  FND_API.G_MISS_NUM)
                THEN
                    IF (p_x_mo_procedures_tbl(l_rec_idx).mr_title IS  NULL OR p_x_mo_procedures_tbl(l_rec_idx).mr_version_number IS NULL )
                    THEN
                        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_MO_MR_MAND');
                        FND_MSG_PUB.ADD;
                    ELSE
                        --Get Mr Header Id using the Title and Version Number
                        OPEN get_mr_header_id ( p_x_mo_procedures_tbl(l_rec_idx).mr_title, p_x_mo_procedures_tbl(l_rec_idx).mr_version_number );
                        FETCH get_mr_header_id INTO p_x_mo_procedures_tbl(l_rec_idx).mr_header_id;

                        IF (get_mr_header_id%NOTFOUND)
                        THEN
                            FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_MO_INV');
                            FND_MESSAGE.SET_TOKEN('MRTITLE',p_x_mo_procedures_tbl(l_rec_idx).mr_title);
                            FND_MSG_PUB.ADD;
                        END IF;
                        CLOSE get_mr_header_id;
                    END IF;
                END IF;

                --Check if the Ata Sequence Id is Valid
                IF (p_x_mo_procedures_tbl(l_rec_idx).ata_sequence_id IS NOT NULL )
                THEN

                    OPEN validate_ata_seq(p_x_mo_procedures_tbl(l_rec_idx).ata_sequence_id);
                    FETCH validate_ata_seq INTO l_dummy_varchar;

                    IF(validate_ata_seq%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_ATA_INV');
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE validate_ata_seq;

                    --Retrieve Mel Cdl Header Id for the Ata Sequence Id and validate id the MEL/CDL is  in Draft /Approval Rejected
                    OPEN val_mel_cdl_status (p_x_mo_procedures_tbl(l_rec_idx).ata_sequence_id);
                    FETCH val_mel_cdl_status INTO l_status;
                    CLOSE val_mel_cdl_status;

                    IF (l_status NOT IN ('DRAFT', 'APPROVAL_REJECTED'))
                    THEN
                        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_UPDATA_STS_INV');
                        -- Cannot process if MEL/CDL is not in draft or approval rejected status
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                -- Check if the MO Procedure is already associated to the Ata Sequence
                BEGIN
                    SELECT 'X'  INTO l_dummy_varchar FROM DUAL WHERE NOT EXISTS
                    (SELECT 'x'
                    FROM
                        ahl_mel_cdl_mo_procedures
                    WHERE
                        ata_sequence_id = p_x_mo_procedures_tbl(l_rec_idx).ata_sequence_id
                        AND mr_header_id = p_x_mo_procedures_tbl(l_rec_idx).mr_header_id);

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_MO_EXISTS');
                    -- MO Proc Assocaition Already Exists for the ATA Seq
                    FND_MESSAGE.SET_TOKEN('MRTitle', p_x_mo_procedures_tbl(l_rec_idx).mr_title);
                    FND_MSG_PUB.ADD;
                END;

                -- Check Error Message stack.
                x_msg_count := FND_MSG_PUB.count_msg;
                IF (x_msg_count > 0)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Default attributes for create
                p_x_mo_procedures_tbl(l_rec_idx).object_version_number  := 1;
                IF (p_x_mo_procedures_tbl(l_rec_idx).mel_cdl_mo_procedure_id IS NULL)
                THEN
                    SELECT ahl_mel_cdl_mo_procedures_s.NEXTVAL INTO p_x_mo_procedures_tbl(l_rec_idx).mel_cdl_mo_procedure_id FROM DUAL;
                END IF;


                -- Insert record into backend
                INSERT INTO ahl_mel_cdl_mo_procedures
                (
                    MEL_CDL_MO_PROCEDURE_ID,
                    OBJECT_VERSION_NUMBER,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    ATA_SEQUENCE_ID,
                    MR_HEADER_ID,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15
                )
                VALUES
                (
                    p_x_mo_procedures_tbl(l_rec_idx).MEL_CDL_MO_PROCEDURE_ID,
                    p_x_mo_procedures_tbl(l_rec_idx).OBJECT_VERSION_NUMBER,
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    p_x_mo_procedures_tbl(l_rec_idx).ATA_SEQUENCE_ID,
                    p_x_mo_procedures_tbl(l_rec_idx).MR_HEADER_ID,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE_CATEGORY,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE1,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE2,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE3,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE4,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE5,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE6,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE7,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE8,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE9,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE10,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE11,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE12,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE13,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE14,
                    p_x_mo_procedures_tbl(l_rec_idx).ATTRIBUTE15
                )
                RETURNING MEL_CDL_MO_PROCEDURE_ID INTO p_x_mo_procedures_tbl(l_rec_idx).mel_cdl_mo_procedure_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                    fnd_log.level_statement,
                    l_debug_module,
                    'Created new MO Procedure Association [mel_cdl_mo_procedure_id='||p_x_mo_procedures_tbl(l_rec_idx).mel_cdl_mo_procedure_id||']'
                    );
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- API body ends here

    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module,
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
        Rollback to Process_Mo_Procedures_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Mo_Procedures_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Mo_Procedures_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Process_Mo_Procedures',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Process_Mo_Procedures;

------------------------------------------
-- Spec Procedure Process_Ata_Relations --
------------------------------------------
PROCEDURE Process_Ata_Relations
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_ata_relations_tbl       IN OUT NOCOPY   Relationship_Tbl_Type
)
IS

    --This cursor is used to check if the Ata Sequence is already assocaited to the Context ATA Sequence
    CURSOR Check_Reln_Exists
    (
        p_ata_seq_id number,
        p_rel_ata_seq_id number
    )
    IS
        SELECT 'x'
        FROM
            ahl_mel_cdl_relationships
        WHERE
            (ata_sequence_id = p_ata_seq_id
            AND related_ata_sequence_id = p_rel_ata_seq_id) OR
            (ata_sequence_id = p_rel_ata_seq_id
            AND related_ata_sequence_id = p_ata_seq_id);


    --This cursor is to check if both ATA and related ATA belong to the same MEL/CDL
    CURSOR Validate_For_Same_Mel_Cdl
    (
        p_ata_seq_id number,
        p_rel_ata_seq_id number
    )
    IS
        SELECT  'x'
        FROM
            ahl_mel_cdl_ata_sequences_v a,
            ahl_mel_cdl_ata_sequences_v b
        WHERE
            a.mel_cdl_ata_sequence_id= p_ata_seq_id
            AND b.mel_cdl_ata_sequence_id = p_rel_ata_seq_id
            AND a.mel_cdl_header_id = b.mel_cdl_header_id;

 -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Process_Ata_Relations';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_status                    VARCHAR2(30);
    l_ata_mng     VARCHAR2(30);
    l_reln_ata_mng     VARCHAR2(30);

    -- Define cursors

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Process_Ata_Relations_SP;

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
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module,
            'At the start of PLSQL procedure'
        );
    END IF;

--API body Begins
    IF (p_x_ata_relations_tbl.COUNT > 0)
    THEN
        -- Iterate all delete records
        FOR l_rec_idx IN p_x_ata_relations_tbl.FIRST..p_x_ata_relations_tbl.LAST
        LOOP

           -- Verify DML operation flag is right...
            IF (p_x_ata_relations_tbl(l_rec_idx).dml_operation NOT IN ( 'C', 'D'))
            THEN

                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_INVALID_DML_REC');
                -- Invalid DML operation FIELD specified
                FND_MESSAGE.SET_TOKEN('FIELD', p_x_ata_relations_tbl(l_rec_idx).dml_operation);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Perform Deletion
            IF (p_x_ata_relations_tbl(l_rec_idx).dml_operation = 'D')
            THEN

                -- For U/D, verify mel_cdl_mo_procedures_id + ovn is correct
                Check_Inter_Reln_Exists(p_x_ata_relations_tbl(l_rec_idx).mel_cdl_relationship_id, p_x_ata_relations_tbl(l_rec_idx).object_version_number);

                -- Delete MandO procedures from the MO Procedure Table
                DELETE FROM ahl_mel_cdl_relationships
                WHERE mel_cdl_relationship_id = p_x_ata_relations_tbl(l_rec_idx).mel_cdl_relationship_id;

                IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                    fnd_log.level_procedure,
                    l_debug_module,
                    'Deleted Relationship'|| p_x_ata_relations_tbl(l_rec_idx).mel_cdl_relationship_id
                    );

                END IF;
            END IF;
        END LOOP;

        --Perform Create
        FOR l_rec_idx IN p_x_ata_relations_tbl.FIRST..p_x_ata_relations_tbl.LAST
        LOOP
            IF (p_x_ata_relations_tbl(l_rec_idx).dml_operation = 'C')
            THEN

                --Check if Ata Sequence Id  is null , as its a mandatory field
                IF (p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id IS NULL)
                THEN
                    FND_MESSAGE.Set_Name('AHL', 'AHL_MEL_CDL_ATA_MAND');
                    FND_MSG_PUB.ADD;
                END IF;

                --Check for the Related Ata Sequence Id, It is also a mandatory Field
                IF (p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id IS NULL)
                THEN
                    FND_MESSAGE.Set_Name('AHL', 'AHL_MEL_CDL_RELN_MAND');
                    FND_MSG_PUB.ADD;

                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
                    THEN
                        fnd_log.message
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                            false
                        );
                    END IF;
                END IF;

                --Check if the Context Ata Sequence Id is Valid and if so the MEL/CDL to which it is associated is also valid
                IF (p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id IS NOT NULL )
                THEN
                    OPEN validate_ata_seq(p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id);
                    FETCH validate_ata_seq INTO l_dummy_varchar;

                    IF(validate_ata_seq%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_ATA_INV');
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE validate_ata_seq;

                    --Retrieve Mel Cdl Header Id for the Ata Sequence Id and validate if the MEL/CDL is in Draft /Approval Rejected
                    OPEN val_mel_cdl_status (p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id);
                    FETCH val_mel_cdl_status INTO l_status;
                    CLOSE val_mel_cdl_status;

                    IF (l_status NOT IN ('DRAFT', 'APPROVAL_REJECTED'))
                    THEN
                        FND_MESSAGE.SET_NAME(G_APP_NAME, ' AHL_MEL_CDL_UPDATA_STS_INV');
                        -- Cannot process if MEL/CDL is not in draft or approval rejected status
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                --Validate the Related Ata Sequence Id
                IF (p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id IS NOT NULL )
                THEN
                    OPEN validate_ata_seq(p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id);
                    FETCH validate_ata_seq INTO l_dummy_varchar;

                    IF(validate_ata_seq%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_ATA_INV');
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE validate_ata_seq;
                END IF;


                --Get the ATA Meaning for ATA Sequence Id
                SELECT ata_meaning  INTO l_ata_mng
                FROM
                    ahl_mel_cdl_ata_sequences_v
                WHERE
                    mel_cdl_ata_sequence_id = p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id;

                --Get the ATA Meaning for Related ATA Sequence Id
                SELECT ata_meaning  INTO l_reln_ata_mng
                FROM
                    ahl_mel_cdl_ata_sequences_v
                WHERE
                    mel_cdl_ata_sequence_id = p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id;

                -- Check if the Relationship already Exists (ie, ata_sequence_id is associated to related_ata_sequence_id)
                OPEN Check_Reln_Exists(p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id, p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id);
                FETCH Check_Reln_Exists INTO l_dummy_varchar;

                IF (Check_Reln_Exists%FOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_RELN_EXISTS');
                    -- Interrelation alredy Exists for ATA Sequence
                    FND_MESSAGE.SET_TOKEN('ATA',l_ata_mng);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE Check_Reln_Exists;

                --Check if both the ATA's belong to the same MEL/CDL as inter assocaitions is not allowed.
                OPEN Validate_For_Same_Mel_Cdl(p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id, p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id);
                FETCH Validate_For_Same_Mel_Cdl INTO l_dummy_varchar;

                IF (Validate_For_Same_Mel_Cdl%NOTFOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_RELN_DIFF');
                    FND_MESSAGE.SET_TOKEN('ATA', l_ata_mng);
                    FND_MESSAGE.SET_TOKEN('RELATA', l_reln_ata_mng);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE Validate_For_Same_Mel_Cdl;

                -- Check for Cyclic Association (If the Ata Seq chosen for Association is same as the one to which it is getting associated
                -- In the above case, a cyclic relation existance.

                IF (p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id IS NOT NULL AND p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id IS NOT NULL AND
                p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id <> FND_API.G_MISS_NUM AND p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id <> FND_API.G_MISS_NUM )
                THEN
                    IF (p_x_ata_relations_tbl(l_rec_idx).ata_sequence_id = p_x_ata_relations_tbl(l_rec_idx).related_ata_sequence_id )
                    THEN
                        FND_MESSAGE.Set_Name('AHL','AHL_MEL_CDL_RELN_CYCLIC');
                        FND_MSG_PUB.ADD;
                    END IF;

                END IF;

                -- Check Error Message stack.
                x_msg_count := FND_MSG_PUB.count_msg;
                IF (x_msg_count > 0)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Default attributes for create
                p_x_ata_relations_tbl(l_rec_idx).object_version_number  := 1;
                IF (p_x_ata_relations_tbl(l_rec_idx).mel_cdl_relationship_id IS NULL)
                THEN
                    SELECT ahl_mel_cdl_relationships_s.NEXTVAL INTO p_x_ata_relations_tbl(l_rec_idx).mel_cdl_relationship_id FROM DUAL;
                END IF;

                -- Insert record into backend
                INSERT INTO ahl_mel_cdl_relationships
                (
                    MEL_CDL_RELATIONSHIP_ID,
                    OBJECT_VERSION_NUMBER,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    ATA_SEQUENCE_ID,
                    RELATED_ATA_SEQUENCE_ID,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15
                )
                VALUES
                (
                    p_x_ata_relations_tbl(l_rec_idx).MEL_CDL_RELATIONSHIP_ID,
                    p_x_ata_relations_tbl(l_rec_idx).OBJECT_VERSION_NUMBER,
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    p_x_ata_relations_tbl(l_rec_idx).ATA_SEQUENCE_ID,
                    p_x_ata_relations_tbl(l_rec_idx).RELATED_ATA_SEQUENCE_ID,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE_CATEGORY,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE1,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE2,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE3,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE4,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE5,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE6,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE7,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE8,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE9,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE10,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE11,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE12,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE13,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE14,
                    p_x_ata_relations_tbl(l_rec_idx).ATTRIBUTE15
                )
                RETURNING MEL_CDL_RELATIONSHIP_ID INTO p_x_ata_relations_tbl(l_rec_idx).mel_cdl_relationship_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                    fnd_log.level_statement,
                    l_debug_module,
                    'Created new MO Inter-Relationship'
                    );
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module,
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
        Rollback to Process_Ata_Relations_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Ata_Relations_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Ata_Relations_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Process_Ata_Relations',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Process_Ata_Relations;

------------------------------------------
-- Spec Procedure Process_Ata_Relations --
------------------------------------------
PROCEDURE Copy_MO_Proc_Revision
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_old_mr_header_id          IN          NUMBER,
    p_new_mr_header_id          IN          NUMBER
)
IS

    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Copy_MO_Proc_Revision';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    -- Define cursors
    CURSOR get_all_ata_for_mo_pro
    (
        p_mr_header_id  number
    )
    IS
        SELECT  ata_sequence_id
        FROM    ahl_mel_cdl_mo_procedures
        WHERE   mr_header_id = p_mr_header_id;

    l_ata_seq_id    number;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Copy_MO_Proc_Revision_SP;

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
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body Begins
    IF (p_old_mr_header_id IS NOT NULL AND p_old_mr_header_id <> FND_API.G_MISS_NUM
        AND
        p_new_mr_header_id IS NOT NULL AND p_new_mr_header_id <> FND_API.G_MISS_NUM)
    THEN
        -- Fetch all ATA sequences which are associated to the old revision of the M and O Procedure
        OPEN get_all_ata_for_mo_pro(p_old_mr_header_id);
        LOOP
            FETCH get_all_ata_for_mo_pro INTO l_ata_seq_id;
            EXIT WHEN get_all_ata_for_mo_pro%NOTFOUND;

            -- Create association of such ATA sequences with the new revision of the M and O Procedure
            INSERT INTO ahl_mel_cdl_mo_procedures
            (
                MEL_CDL_MO_PROCEDURE_ID,
                OBJECT_VERSION_NUMBER,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                ATA_SEQUENCE_ID,
                MR_HEADER_ID,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
            )
            VALUES
            (
                ahl_mel_cdl_mo_procedures_s.nextval,
                1,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_ata_seq_id,
                p_new_mr_header_id,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
            );
        END LOOP;
    END IF;
    -- API body ends

    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
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
        Rollback to Copy_MO_Proc_Revision_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Copy_MO_Proc_Revision_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Copy_MO_Proc_Revision_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Copy_MO_Proc_Revision',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Copy_MO_Proc_Revision;

---------------------------------------------
-- Non-spec Procedure Check_Ata_Seq_Exists --
---------------------------------------------
PROCEDURE Check_Ata_Seq_Exists
(
    p_ata_sequence_id           IN  NUMBER,
    p_ata_object_version        IN  NUMBER
)
IS

    CURSOR check_exists
    IS
    SELECT  object_version_number
    FROM    ahl_mel_cdl_ata_sequences
    WHERE   mel_cdl_ata_sequence_id = p_ata_sequence_id;

    l_ovn       NUMBER;

BEGIN

    OPEN check_exists;
    FETCH check_exists INTO l_ovn;
    IF (check_exists%NOTFOUND)
    THEN
        CLOSE check_exists;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_ATA_NOTFOUND');
        -- System Sequence is not found
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        CLOSE check_exists;
        IF (l_ovn <> p_ata_object_version)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_RECORD_CHANGED');
            -- Record has been modified by another user
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

END Check_Ata_Seq_Exists;

--------------------------------------------
-- Non-spec Procedure Convert_Value_To_Id --
--------------------------------------------
PROCEDURE Convert_Value_To_Id
(
    p_x_ata_sequences_rec       IN OUT NOCOPY   Ata_Sequence_Rec_Type
)
IS
    CURSOR validate_repcat
    (
        p_repcat_id number
    )
    IS
    SELECT  'x'
    FROM    ahl_repair_categories
    WHERE   repair_category_id = p_repcat_id;

    CURSOR convert_repcat
    (
        p_repcat_name varchar2
    )
    IS
    SELECT  repcat.repair_category_id
    FROM    cs_incident_urgencies_vl urg, ahl_repair_categories repcat
    WHERE   upper(urg.name) = upper(p_repcat_name) AND
            urg.incident_urgency_id = repcat.sr_urgency_id;

BEGIN

    -- Convert value-to-id for ata_code
    IF (p_x_ata_sequences_rec.ata_code IS NULL OR p_x_ata_sequences_rec.ata_code = FND_API.G_MISS_CHAR)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_ATA_MAND');
        -- System Sequence is mandatory
        FND_MSG_PUB.ADD;
    ELSIF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_ATA_CODE', p_x_ata_sequences_rec.ata_code))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_ATA_INV');
        -- System Sequence is invalid
        FND_MSG_PUB.ADD;
    END IF;

    -- Convert value-to-id for sr_urgency
    IF (p_x_ata_sequences_rec.repair_category_id IS NULL OR p_x_ata_sequences_rec.repair_category_id = FND_API.G_MISS_NUM)
    THEN
        IF (p_x_ata_sequences_rec.repair_category_name IS NULL OR p_x_ata_sequences_rec.repair_category_name = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REPCAT_MAND');
            -- Repair Category for System Sequence "ATA" is mandatory
            FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_rec.ata_code);
            FND_MSG_PUB.ADD;
        ELSE
            OPEN convert_repcat(p_x_ata_sequences_rec.repair_category_name);
            FETCH convert_repcat INTO p_x_ata_sequences_rec.repair_category_id;
            IF (convert_repcat%NOTFOUND)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REPCAT_INV');
                -- Repair Category for System Sequence "ATA" is invalid
                FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_rec.ata_code);
                FND_MSG_PUB.ADD;
            END IF;
            CLOSE convert_repcat;
        END IF;
    ELSE
        OPEN validate_repcat(p_x_ata_sequences_rec.repair_category_id);
        FETCH validate_repcat INTO l_dummy_varchar;
        IF (validate_repcat%NOTFOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REPCAT_INV');
            -- Repair Category for System Sequence "ATA" is invalid
            FND_MESSAGE.SET_TOKEN('ATA', p_x_ata_sequences_rec.ata_code);
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE validate_repcat;
    END IF;

END Convert_Value_To_Id;

---------------------------------------------
-- Non-spec Procedure Check_Mel_Cdl_Status --
---------------------------------------------
PROCEDURE Check_Mel_Cdl_Status
(
    p_mel_cdl_header_id         IN  NUMBER,
    p_ata_sequence_id           IN  NUMBER
)
IS

    CURSOR get_ata_mel_cdl_status
    IS
    SELECT  hdr.status_code, hdr.mel_cdl_header_id
    FROM    ahl_mel_cdl_headers hdr, ahl_mel_cdl_ata_sequences ata
    WHERE   hdr.mel_cdl_header_id = ata.mel_cdl_header_id AND
            ata.mel_cdl_ata_sequence_id = p_ata_sequence_id;

    CURSOR get_mel_cdl_status
    IS
    SELECT  status_code, mel_cdl_header_id
    FROM    ahl_mel_cdl_headers
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

    l_status                    VARCHAR2(30);
    l_mel_cdl_header_id         NUMBER;

BEGIN
    IF (p_mel_cdl_header_id IS NOT NULL)
    THEN
        OPEN get_mel_cdl_status;
        FETCH get_mel_cdl_status INTO l_status, l_mel_cdl_header_id;
        CLOSE get_mel_cdl_status;
    ELSIF (p_ata_sequence_id IS NOT NULL)
    THEN
        OPEN get_ata_mel_cdl_status;
        FETCH get_ata_mel_cdl_status INTO l_status, l_mel_cdl_header_id;
        CLOSE get_ata_mel_cdl_status;
    ELSE
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_HDR_MAND');
        -- MEL/CDL information is mandatory for processing System Sequence(s)
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_status NOT IN ('DRAFT', 'APPROVAL_REJECTED'))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NOT_DRAFT_ATA');
        -- Cannot process System Sequence(s) for MEL/CDL not in draft or approval rejected status
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_status = 'APPROVAL_REJECTED')
    THEN
        UPDATE  ahl_mel_cdl_headers
        SET     status_code = 'DRAFT'
        WHERE   mel_cdl_header_id = l_mel_cdl_header_id;
    END IF;
END Check_Mel_Cdl_Status;


---------------------------------------------
-- Non-spec Procedure Check_MO_Proc_Exists --
---------------------------------------------

PROCEDURE Check_MO_Proc_Exists
(
    p_mo_procedure_id           IN  NUMBER,
    p_mo_proc_object_version        IN  NUMBER
)
IS

    CURSOR check_exists
    IS
    SELECT  object_version_number
    FROM    ahl_mel_cdl_mo_procedures
    WHERE   mel_cdl_mo_procedure_id = p_mo_procedure_id;

    l_ovn       NUMBER;

BEGIN

    OPEN check_exists;
    FETCH check_exists INTO l_ovn;
    IF (check_exists%NOTFOUND)
    THEN
        CLOSE check_exists;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_MO_PROC_NOTFOUND');
        -- MO Procedure is not found
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        CLOSE check_exists;
        IF (l_ovn <> p_mo_proc_object_version)
        THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_RECORD_CHANGED');
            -- Record has been modified by another user
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

END Check_MO_Proc_Exists;

---------------------------------------------
-- Non-spec Procedure Check_Inter_Reln_Exists --
---------------------------------------------

PROCEDURE Check_Inter_Reln_Exists
(
    p_mel_cdl_relationship_id           IN  NUMBER,
    p_rel_object_version        IN  NUMBER
)
IS

    CURSOR check_exists
    IS
        SELECT  object_version_number
        FROM ahl_mel_cdl_relationships
        WHERE mel_cdl_relationship_id = p_mel_cdl_relationship_id;

    l_ovn       NUMBER;

BEGIN
    OPEN check_exists;
    FETCH check_exists INTO l_ovn;

    IF (check_exists%NOTFOUND)
    THEN
        CLOSE check_exists;

        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REL_NOTFOUND');
        -- MO Procedure is not found
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

    ELSE
        CLOSE check_exists;

        IF (l_ovn <> p_rel_object_version)
        THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_RECORD_CHANGED');
            -- Record has been modified by another user
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

END Check_Inter_Reln_Exists;

End AHL_MEL_CDL_ATA_SEQS_PVT;

/
