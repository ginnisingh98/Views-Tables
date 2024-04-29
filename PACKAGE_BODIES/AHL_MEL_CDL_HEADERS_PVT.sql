--------------------------------------------------------
--  DDL for Package Body AHL_MEL_CDL_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MEL_CDL_HEADERS_PVT" AS
/* $Header: AHLVMEHB.pls 120.5 2006/08/17 12:11:51 priyan noship $ */

------------------------------------
-- Common constants and variables --
------------------------------------
l_dummy_varchar             VARCHAR2(1);

-----------------------------------
-- Non-spec Procedure Signatures --
-----------------------------------
PROCEDURE Check_Mel_Cdl_Exists
(
    p_mel_cdl_header_id         IN  NUMBER,
    p_mel_cdl_object_version    IN  NUMBER
);

PROCEDURE Convert_Value_To_Id
(
    p_x_mel_cdl_header_rec      IN OUT NOCOPY   Header_Rec_Type
);

PROCEDURE Check_Duplicate_Revision
(
    p_x_mel_cdl_header_rec      IN  Header_Rec_Type
);

-----------------------------------
-- Spec Procedure Create_Mel_Cdl --
-----------------------------------
PROCEDURE Create_Mel_Cdl
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_mel_cdl_header_rec      IN OUT NOCOPY   Header_Rec_Type
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Create_Mel_Cdl';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    -- Define cursors
    CURSOR check_pc_right
    IS
    SELECT  'x'
    FROM    ahl_pc_headers_b pch, ahl_pc_nodes_b pcn
    WHERE   pcn.pc_node_id = p_x_mel_cdl_header_rec.pc_node_id AND
            pch.pc_header_id = pcn.pc_header_id AND
            pch.primary_flag = 'Y' AND
            pch.association_type_flag = 'U' AND
            pch.status = 'COMPLETE';

    CURSOR check_can_create
    IS
    SELECT  'x'
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_x_mel_cdl_header_rec.pc_node_id AND
            mel_cdl_type_code = p_x_mel_cdl_header_rec.mel_cdl_type_code;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Create_Mel_Cdl_SP;

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

    -- API body starts here
    -- Verify PC is primary, complete and unit association type
    OPEN check_pc_right;
    FETCH check_pc_right INTO l_dummy_varchar;
    IF (check_pc_right%NOTFOUND)
    THEN
        CLOSE check_pc_right;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_PC_INVALID');
        -- MEL/CDL can only be associated to nodes of primary complete Product Classifications of unit association type.
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_pc_right;

    -- Verify MEL/CDL type is not null and exists as lookup
    Convert_Value_To_Id(p_x_mel_cdl_header_rec);

    OPEN check_can_create;
    FETCH check_can_create INTO l_dummy_varchar;
    IF (check_can_create%FOUND)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_EXISTS');
        -- TYPE is already associated with the Product Classification Node
        FND_MESSAGE.SET_TOKEN('TYPE', p_x_mel_cdl_header_rec.mel_cdl_type_code);
        FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_can_create;

    -- Verify revision is unique across all revisions of MEL/CDL
    Check_Duplicate_Revision(p_x_mel_cdl_header_rec);

    -- Verify revision date is not null, it is a mandatory field
    IF (p_x_mel_cdl_header_rec.revision_date IS NULL OR p_x_mel_cdl_header_rec.revision_date = FND_API.G_MISS_DATE)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REV_DATE_MAND');
        -- MEL/CDL revision date is mandatory
        FND_MSG_PUB.ADD;
    END IF;

    -- Verify expiration date is greater than revision date
    IF (nvl(p_x_mel_cdl_header_rec.expired_date, p_x_mel_cdl_header_rec.revision_date) < p_x_mel_cdl_header_rec.revision_date)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_EXP_DATE_LESS');
        -- MEL/CDL expiration date should be greater than revision date
        FND_MSG_PUB.ADD;
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Basic validations done'
        );
    END IF;

    -- Default record attributes for create
    p_x_mel_cdl_header_rec.object_version_number    := 1;
    p_x_mel_cdl_header_rec.status_code              := 'DRAFT';
    p_x_mel_cdl_header_rec.version_number           := 1;
    IF (p_x_mel_cdl_header_rec.mel_cdl_header_id IS NULL)
    THEN
        SELECT ahl_mel_cdl_headers_s.NEXTVAL INTO p_x_mel_cdl_header_rec.mel_cdl_header_id FROM DUAL;
    END IF;

    -- Insert record into backend
    INSERT INTO ahl_mel_cdl_headers
    (
        MEL_CDL_HEADER_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PC_NODE_ID,
        MEL_CDL_TYPE_CODE,
        STATUS_CODE,
        REVISION,
        VERSION_NUMBER,
        REVISION_DATE,
        EXPIRED_DATE,
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
        p_x_mel_cdl_header_rec.mel_cdl_header_id,
        p_x_mel_cdl_header_rec.OBJECT_VERSION_NUMBER,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        p_x_mel_cdl_header_rec.PC_NODE_ID,
        p_x_mel_cdl_header_rec.MEL_CDL_TYPE_CODE,
        p_x_mel_cdl_header_rec.STATUS_CODE,
        p_x_mel_cdl_header_rec.REVISION,
        p_x_mel_cdl_header_rec.VERSION_NUMBER,
        p_x_mel_cdl_header_rec.REVISION_DATE,
        p_x_mel_cdl_header_rec.EXPIRED_DATE,
        p_x_mel_cdl_header_rec.ATTRIBUTE_CATEGORY,
        p_x_mel_cdl_header_rec.ATTRIBUTE1,
        p_x_mel_cdl_header_rec.ATTRIBUTE2,
        p_x_mel_cdl_header_rec.ATTRIBUTE3,
        p_x_mel_cdl_header_rec.ATTRIBUTE4,
        p_x_mel_cdl_header_rec.ATTRIBUTE5,
        p_x_mel_cdl_header_rec.ATTRIBUTE6,
        p_x_mel_cdl_header_rec.ATTRIBUTE7,
        p_x_mel_cdl_header_rec.ATTRIBUTE8,
        p_x_mel_cdl_header_rec.ATTRIBUTE9,
        p_x_mel_cdl_header_rec.ATTRIBUTE10,
        p_x_mel_cdl_header_rec.ATTRIBUTE11,
        p_x_mel_cdl_header_rec.ATTRIBUTE12,
        p_x_mel_cdl_header_rec.ATTRIBUTE13,
        p_x_mel_cdl_header_rec.ATTRIBUTE14,
        p_x_mel_cdl_header_rec.ATTRIBUTE15
    )
    RETURNING MEL_CDL_HEADER_ID INTO p_x_mel_cdl_header_rec.mel_cdl_header_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Created new MEL/CDL [mel_cdl_header_id='||p_x_mel_cdl_header_rec.MEL_CDL_HEADER_ID||'][pc_node_id='||p_x_mel_cdl_header_rec.PC_NODE_ID||'][mel_cdl_type_code='||p_x_mel_cdl_header_rec.MEL_CDL_TYPE_CODE||']'
        );
    END IF;
    -- API body ends here

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
        Rollback to Create_Mel_Cdl_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Create_Mel_Cdl_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Create_Mel_Cdl_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Create_Mel_Cdl',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Create_Mel_Cdl;

-----------------------------------
-- Spec Procedure Update_Mel_Cdl --
-----------------------------------
PROCEDURE Update_Mel_Cdl
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_mel_cdl_header_rec      IN OUT NOCOPY   Header_Rec_Type
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Update_Mel_Cdl';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    -- Define cursors
    CURSOR get_mel_cdl_details
    IS
    SELECT  object_version_number,
            mel_cdl_type_code,
            pc_node_id,
            version_number,
            status_code,
            revision_date
    FROM    ahl_mel_cdl_headers
    WHERE   mel_cdl_header_id = p_x_mel_cdl_header_rec.mel_cdl_header_id
    FOR UPDATE OF object_version_number NOWAIT;

    l_ovn               NUMBER;
    l_mel_cdl_type      VARCHAR2(30);
    l_pc_node_id        NUMBER;
    l_status            VARCHAR2(30);
    l_rev_date          DATE;

    CURSOR check_other_type_exists
    IS
    SELECT  'x'
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_x_mel_cdl_header_rec.pc_node_id AND
            mel_cdl_type_code = p_x_mel_cdl_header_rec.mel_cdl_type_code;

    CURSOR get_prev_mel_cdl_details
    IS
    SELECT  revision_date
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_x_mel_cdl_header_rec.pc_node_id AND
            mel_cdl_type_code = p_x_mel_cdl_header_rec.mel_cdl_type_code AND
            version_number = p_x_mel_cdl_header_rec.version_number - 1;

    l_prev_rev_date     DATE;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Update_Mel_Cdl_SP;

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

    -- API body starts here
    -- Verify MEL/CDL id + ovn information is correct
    Check_Mel_Cdl_Exists(p_x_mel_cdl_header_rec.mel_cdl_header_id, p_x_mel_cdl_header_rec.object_version_number);

    -- Retrieve details of the record in the database
    OPEN get_mel_cdl_details;
    FETCH get_mel_cdl_details INTO l_ovn, l_mel_cdl_type, l_pc_node_id, p_x_mel_cdl_header_rec.version_number, l_status, l_rev_date;
    CLOSE get_mel_cdl_details;

    -- Get previous MEL/CDL revision details
    OPEN get_prev_mel_cdl_details;
    FETCH get_prev_mel_cdl_details INTO l_prev_rev_date;
    CLOSE get_prev_mel_cdl_details;

    -- Verify PC association is not changed
    IF (p_x_mel_cdl_header_rec.pc_node_id IS NULL OR p_x_mel_cdl_header_rec.pc_node_id = FND_API.G_MISS_NUM)
    THEN
        p_x_mel_cdl_header_rec.pc_node_id := l_pc_node_id;
    ELSIF (l_pc_node_id <> p_x_mel_cdl_header_rec.pc_node_id)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_PC_ASSOC_NOTCHG');
        -- Cannot modify MEL/CDL association to Product Classification node
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Verify only DRAFT/APPROVAL_PENDING MEL/CDL is being modified
    IF (l_status NOT IN ('DRAFT','APPROVAL_REJECTED'))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NOT_DRAFT_UPD');
        -- Cannot update MEL/CDL not in draft or approval rejected status
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Verify MEL/CDL type is not null and exists as lookup
    Convert_Value_To_Id(p_x_mel_cdl_header_rec);

    -- If mel_cdl_type is being changed, confirm that there are no existing revisions of the type being changed to
    IF (p_x_mel_cdl_header_rec.mel_cdl_type_code <> l_mel_cdl_type)
    THEN
        OPEN check_other_type_exists;
        FETCH check_other_type_exists INTO l_dummy_varchar;
        IF (check_other_type_exists%FOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_OTH_EXISTS');
            -- A TYPE is already associated with the Product Classification Node, hence cannot modify MEL/CDL type
            FND_MESSAGE.SET_TOKEN('TYPE', p_x_mel_cdl_header_rec.mel_cdl_type_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- This means that the changed MEL/CDL is the 1st revision of the changed type, hence default version number
            p_x_mel_cdl_header_rec.version_number := 1;
        END IF;
        CLOSE check_other_type_exists;
    END IF;

    -- Verify revision is unique across all revisions of MEL/CDL
    Check_Duplicate_Revision(p_x_mel_cdl_header_rec);

    -- Verify revision date is not null, it is a mandatory field
    IF (p_x_mel_cdl_header_rec.revision_date IS NULL OR p_x_mel_cdl_header_rec.revision_date = FND_API.G_MISS_DATE)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REV_DATE_MAND');
        -- MEL/CDL revision date is mandatory
        FND_MSG_PUB.ADD;
    ELSIF (p_x_mel_cdl_header_rec.revision_date <= nvl(l_prev_rev_date, p_x_mel_cdl_header_rec.revision_date - 1))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REV_DATE_LESS');
        -- MEL/CDL revision date cannot be less than that of the prior revision
        FND_MSG_PUB.ADD;
    END IF;

    -- Verify expiration date is greater than revision date
    IF (nvl(p_x_mel_cdl_header_rec.expired_date, p_x_mel_cdl_header_rec.revision_date) < p_x_mel_cdl_header_rec.revision_date)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_EXP_DATE_LESS');
        -- MEL/CDL expiration date should be greater than revision date
        FND_MSG_PUB.ADD;
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Basic validations done'
        );
    END IF;

    -- Default record attributes for modify
    p_x_mel_cdl_header_rec.object_version_number    := p_x_mel_cdl_header_rec.object_version_number + 1;
    p_x_mel_cdl_header_rec.status_code              := 'DRAFT';

    -- Update record in backend
    UPDATE  ahl_mel_cdl_headers
    SET     OBJECT_VERSION_NUMBER   = p_x_mel_cdl_header_rec.object_version_number,
            LAST_UPDATE_DATE        = sysdate,
            LAST_UPDATED_BY         = fnd_global.user_id,
            LAST_UPDATE_LOGIN       = fnd_global.login_id,
            MEL_CDL_TYPE_CODE       = p_x_mel_cdl_header_rec.mel_cdl_type_code,
            STATUS_CODE             = p_x_mel_cdl_header_rec.status_code,
            REVISION                = p_x_mel_cdl_header_rec.revision,
            REVISION_DATE           = p_x_mel_cdl_header_rec.revision_date,
            EXPIRED_DATE            = p_x_mel_cdl_header_rec.expired_date,
            ATTRIBUTE_CATEGORY      = p_x_mel_cdl_header_rec.attribute_category,
            ATTRIBUTE1              = p_x_mel_cdl_header_rec.attribute1,
            ATTRIBUTE2              = p_x_mel_cdl_header_rec.attribute2,
            ATTRIBUTE3              = p_x_mel_cdl_header_rec.attribute3,
            ATTRIBUTE4              = p_x_mel_cdl_header_rec.attribute4,
            ATTRIBUTE5              = p_x_mel_cdl_header_rec.attribute5,
            ATTRIBUTE6              = p_x_mel_cdl_header_rec.attribute6,
            ATTRIBUTE7              = p_x_mel_cdl_header_rec.attribute7,
            ATTRIBUTE8              = p_x_mel_cdl_header_rec.attribute8,
            ATTRIBUTE9              = p_x_mel_cdl_header_rec.attribute9,
            ATTRIBUTE10             = p_x_mel_cdl_header_rec.attribute10,
            ATTRIBUTE11             = p_x_mel_cdl_header_rec.attribute11,
            ATTRIBUTE12             = p_x_mel_cdl_header_rec.attribute12,
            ATTRIBUTE13             = p_x_mel_cdl_header_rec.attribute13,
            ATTRIBUTE14             = p_x_mel_cdl_header_rec.attribute14,
            ATTRIBUTE15             = p_x_mel_cdl_header_rec.attribute15
    WHERE   MEL_CDL_HEADER_ID = p_x_mel_cdl_header_rec.mel_cdl_header_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Updated MEL/CDL [mel_cdl_header_id='||p_x_mel_cdl_header_rec.MEL_CDL_HEADER_ID||'][pc_node_id='||p_x_mel_cdl_header_rec.PC_NODE_ID||'][mel_cdl_type_code='||p_x_mel_cdl_header_rec.MEL_CDL_TYPE_CODE||']'
        );
    END IF;
    -- API body ends here

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
        Rollback to Update_Mel_Cdl_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Update_Mel_Cdl_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Update_Mel_Cdl_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Update_Mel_Cdl',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Update_Mel_Cdl;

-----------------------------------
-- Spec Procedure Delete_Mel_Cdl --
-----------------------------------
PROCEDURE Delete_Mel_Cdl
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id         IN              NUMBER,
    p_mel_cdl_object_version    IN              NUMBER
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Delete_Mel_Cdl';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    -- Define cursors
    CURSOR get_mel_cdl_details
    IS
    SELECT  status_code
    FROM    ahl_mel_cdl_headers
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

    l_status        VARCHAR2(30);

    CURSOR get_all_ata_notes
    IS
    SELECT  note.jtf_note_id
    FROM    ahl_mel_cdl_ata_sequences ata, jtf_notes_b note
    WHERE   ata.mel_cdl_header_id = p_mel_cdl_header_id AND
            ata.mel_cdl_ata_sequence_id = note.source_object_id AND
            note.source_object_code = 'AHL_MEL_CDL';

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Delete_Mel_Cdl_SP;

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

    -- API body starts here
    -- Verify MEL/CDL id + ovn information is correct
    Check_Mel_Cdl_Exists(p_mel_cdl_header_id, p_mel_cdl_object_version);

    -- Retrieve details of the record in the database
    OPEN get_mel_cdl_details;
    FETCH get_mel_cdl_details INTO l_status;
    CLOSE get_mel_cdl_details;

    -- Verify only DRAFT/APPROVAL_PENDING MEL/CDL is being deleted
    IF (l_status NOT IN ('DRAFT','APPROVAL_REJECTED'))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NOT_DRAFT_DEL');
        -- Cannot delete MEL/CDL not in draft or approval rejected status
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Basic validations done'
        );
    END IF;

    -- Delete MEL/CDL and all its associations

    --  1. For all associated ATA sequences
    --      1a. Delete all JTF notes associated
    FOR note_rec IN get_all_ata_notes
    LOOP
        CAC_NOTES_PVT.delete_note
        (
            note_rec.jtf_note_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF (x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS)
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

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'All JTF notes associated with ATA sequences deleted'
        );
    END IF;

    --  1. For all associated ATA sequences
    --      1b. Delete all inter-relationships with other ATA sequences
    DELETE FROM ahl_mel_cdl_relationships
    WHERE ata_sequence_id IN
    (
        SELECT mel_cdl_ata_sequence_id
        FROM ahl_mel_cdl_ata_sequences
        WHERE mel_cdl_header_id = p_mel_cdl_header_id
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'All ATA relationships associated with ATA sequences deleted'
        );
    END IF;

    --  1. For all associated ATA sequences
    --      1c. Delete all MO procedures associated
    DELETE FROM ahl_mel_cdl_mo_procedures
    WHERE ata_sequence_id IN
    (
        SELECT mel_cdl_ata_sequence_id
        FROM ahl_mel_cdl_ata_sequences
        WHERE mel_cdl_header_id = p_mel_cdl_header_id
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'All MO procedures associated with ATA sequences deleted'
        );
    END IF;

    --  2. Delete all ATA sequences
    DELETE FROM ahl_mel_cdl_ata_sequences
    WHERE mel_cdl_header_id = p_mel_cdl_header_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'All ATA sequences deleted'
        );
    END IF;

    --  3. Delete MEL/CDL itself
    DELETE FROM ahl_mel_cdl_headers
    WHERE mel_cdl_header_id = p_mel_cdl_header_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Deleted MEL/CDL [mel_cdl_header_id='||p_mel_cdl_header_id||'] and all its associations'
        );
    END IF;
    -- API body ends here

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
        Rollback to Delete_Mel_Cdl_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Delete_Mel_Cdl_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Delete_Mel_Cdl_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Delete_Mel_Cdl',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Delete_Mel_Cdl;

--------------------------------------------
-- Spec Procedure Create_Mel_Cdl_Revision --
--------------------------------------------
PROCEDURE Create_Mel_Cdl_Revision
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id         IN              NUMBER,
    p_mel_cdl_object_version    IN              NUMBER,
    x_new_mel_cdl_header_id     OUT NOCOPY      NUMBER
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Create_Mel_Cdl_Revision';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_mel_cdl_header_id         NUMBER := p_mel_cdl_header_id;
    -- Priyan
    -- Fix for Bug #5468974
    l_rel_ata_seq_id		NUMBER;

    -- Define cursors
    CURSOR get_mel_cdl_details
    IS
    SELECT  pc_node_id,
            mel_cdl_type_code,
            status_code,
            version_number,
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
    FROM    ahl_mel_cdl_headers
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

    l_mel_cdl_rec               get_mel_cdl_details%rowtype;
    l_max_rev                   NUMBER;

    CURSOR get_ata_seq_details
    IS
    SELECT  mel_cdl_ata_sequence_id,
            repair_category_id,
            ata_code,
            installed_number,
            dispatch_number,
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
    FROM    ahl_mel_cdl_ata_sequences
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

    l_ata_rec_idx               NUMBER := 0;

    TYPE old_new_rec_type IS RECORD
    (
        old_object_id           NUMBER,
        new_object_id           NUMBER
    );

    TYPE old_new_tbl_type IS TABLE OF old_new_rec_type INDEX BY BINARY_INTEGER;

    l_old_new_ata_tbl           old_new_tbl_type;

    CURSOR get_jtf_note_details
    (
        p_ata_sequence_id   NUMBER
    )
    IS
    SELECT  jtf_note_id,
            parent_note_id,
            notes,
            notes_detail,           -- the CLOB field
            note_status,
            note_type,
            entered_by,
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
    FROM    jtf_notes_vl
    WHERE   source_object_id = p_ata_sequence_id AND
            source_object_code = 'AHL_MEL_CDL';

    l_old_note_id               NUMBER := NULL;
    l_new_note_id               NUMBER := NULL;

    CURSOR get_mo_proc_details
    (
        p_ata_sequence_id   NUMBER
    )
    IS
    SELECT  mo.mel_cdl_mo_procedure_id,
            mo.mr_header_id,
            mo.attribute_category,
            mo.attribute1,
            mo.attribute2,
            mo.attribute3,
            mo.attribute4,
            mo.attribute5,
            mo.attribute6,
            mo.attribute7,
            mo.attribute8,
            mo.attribute9,
            mo.attribute10,
            mo.attribute11,
            mo.attribute12,
            mo.attribute13,
            mo.attribute14,
            mo.attribute15
    FROM    ahl_mel_cdl_mo_procedures mo, ahl_mr_headers_app_v mrh
    WHERE   mo.mr_header_id = mrh.mr_header_id and
            mrh.mr_status_code = 'COMPLETE' and
            trunc(sysdate) between trunc(mrh.effective_from) and trunc(nvl(effective_to, sysdate + 1)) and
            mo.ata_sequence_id = p_ata_sequence_id;

    CURSOR get_ata_rel_details
    (
        p_ata_sequence_id   NUMBER
    )
    IS
    SELECT  mel_cdl_relationship_id,
            related_ata_sequence_id,
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
    FROM    ahl_mel_cdl_relationships
    WHERE   ata_sequence_id = p_ata_sequence_id;

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Create_Mel_Cdl_Revision_SP;

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
            'Inside Create Revision'
        );
    END IF;

    -- API body starts here
    -- Verify MEL/CDL id + ovn information is correct
    Check_Mel_Cdl_Exists(p_mel_cdl_header_id, p_mel_cdl_object_version);

    -- Retrieve details of the record in the database
    OPEN get_mel_cdl_details;
    FETCH get_mel_cdl_details INTO l_mel_cdl_rec;
    CLOSE get_mel_cdl_details;

    -- Verify only COMPLETE MEL/CDL is being revised
    IF (l_mel_cdl_rec.status_code <> 'COMPLETE')
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REV_NOT_COMP');
        -- MEL/CDL is not complete, hence cannot create a new revision
        FND_MSG_PUB.ADD;
    END IF;

    -- Retrieve the max version of the MEL/CDL line for the particular PC Node
    SELECT  nvl(max(version_number), 1)
    INTO    l_max_rev
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = l_mel_cdl_rec.pc_node_id AND
            mel_cdl_type_code = l_mel_cdl_rec.mel_cdl_type_code;

    -- Verify whether the latest revision of the MEL/CDL line is being revised
    IF (l_max_rev <> l_mel_cdl_rec.version_number)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REV_NOT_LATEST');
        -- MEL/CDL is not the latest revision, hence cannot create a new revision
        FND_MSG_PUB.ADD;
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Basic validations done'
        );
    END IF;

    -- Insert record into backend, using values from the current record being revised
    INSERT INTO ahl_mel_cdl_headers
    (
        MEL_CDL_HEADER_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PC_NODE_ID,
        MEL_CDL_TYPE_CODE,
        STATUS_CODE,
        REVISION,
        VERSION_NUMBER,
        REVISION_DATE,
        EXPIRED_DATE,
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
        ahl_mel_cdl_headers_s.NEXTVAL,
        1,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        l_mel_cdl_rec.PC_NODE_ID,
        l_mel_cdl_rec.MEL_CDL_TYPE_CODE,
        'DRAFT',
        to_char(l_mel_cdl_rec.version_number + 1),
        l_mel_cdl_rec.version_number + 1,
        sysdate,
        null,
        l_mel_cdl_rec.ATTRIBUTE_CATEGORY,
        l_mel_cdl_rec.ATTRIBUTE1,
        l_mel_cdl_rec.ATTRIBUTE2,
        l_mel_cdl_rec.ATTRIBUTE3,
        l_mel_cdl_rec.ATTRIBUTE4,
        l_mel_cdl_rec.ATTRIBUTE5,
        l_mel_cdl_rec.ATTRIBUTE6,
        l_mel_cdl_rec.ATTRIBUTE7,
        l_mel_cdl_rec.ATTRIBUTE8,
        l_mel_cdl_rec.ATTRIBUTE9,
        l_mel_cdl_rec.ATTRIBUTE10,
        l_mel_cdl_rec.ATTRIBUTE11,
        l_mel_cdl_rec.ATTRIBUTE12,
        l_mel_cdl_rec.ATTRIBUTE13,
        l_mel_cdl_rec.ATTRIBUTE14,
        l_mel_cdl_rec.ATTRIBUTE15
    )
    RETURNING mel_cdl_header_id INTO x_new_mel_cdl_header_id;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Created new revised MEL/CDL [mel_cdl_header_id='||x_new_mel_cdl_header_id||'] from earler MEL/CDL ['||p_mel_cdl_header_id||']'
        );
    END IF;

    -- Create revisions of all ATA sequences for the MEL/CDL
    FOR l_ata_rec IN get_ata_seq_details
    LOOP
        l_ata_rec_idx := l_ata_rec_idx + 1;
        l_old_new_ata_tbl(l_ata_rec_idx).old_object_id := l_ata_rec.mel_cdl_ata_sequence_id;

        -- Create new ATA sequence record into the database
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
            ahl_mel_cdl_ata_sequences_s.nextval,
            1,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id,
            x_new_mel_cdl_header_id,
            l_ata_rec.REPAIR_CATEGORY_ID,
            l_ata_rec.ATA_CODE,
            l_ata_rec.INSTALLED_NUMBER,
            l_ata_rec.DISPATCH_NUMBER,
            l_ata_rec.ATTRIBUTE_CATEGORY,
            l_ata_rec.ATTRIBUTE1,
            l_ata_rec.ATTRIBUTE2,
            l_ata_rec.ATTRIBUTE3,
            l_ata_rec.ATTRIBUTE4,
            l_ata_rec.ATTRIBUTE5,
            l_ata_rec.ATTRIBUTE6,
            l_ata_rec.ATTRIBUTE7,
            l_ata_rec.ATTRIBUTE8,
            l_ata_rec.ATTRIBUTE9,
            l_ata_rec.ATTRIBUTE10,
            l_ata_rec.ATTRIBUTE11,
            l_ata_rec.ATTRIBUTE12,
            l_ata_rec.ATTRIBUTE13,
            l_ata_rec.ATTRIBUTE14,
            l_ata_rec.ATTRIBUTE15
        )
        RETURNING mel_cdl_ata_sequence_id INTO l_old_new_ata_tbl(l_ata_rec_idx).new_object_id;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
	fnd_log.string
	(
	    fnd_log.level_statement,
	    l_debug_module,
	    'Created new revised ATA Sequences[ata_id ='||l_old_new_ata_tbl(l_ata_rec_idx).new_object_id||'] from  ['||l_old_new_ata_tbl(l_ata_rec_idx).old_object_id||']'
	);
	END IF;

    END LOOP;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Created new revisions of all associated ATA sequences'
        );
    END IF;


    IF (l_old_new_ata_tbl.COUNT > 0)
    THEN
        FOR l_ata_rec_idx IN l_old_new_ata_tbl.FIRST..l_old_new_ata_tbl.LAST
        LOOP
            -- Create revisions of all JTF Notes associated to ATA sequences
            FOR l_note_rec IN get_jtf_note_details(l_old_new_ata_tbl(l_ata_rec_idx).old_object_id)
            LOOP
                CAC_NOTES_PVT.create_note
                (
                    p_jtf_note_id           => l_old_note_id,
                    p_source_object_id      => l_old_new_ata_tbl(l_ata_rec_idx).new_object_id,
                    p_source_object_code    => 'AHL_MEL_CDL',
                    p_notes                 => l_note_rec.notes,
                    p_notes_detail          => l_note_rec.notes_detail,
                    p_note_status           => l_note_rec.note_status,
                    p_note_type             => l_note_rec.note_type,
                    p_attribute1            => l_note_rec.attribute1,
                    p_attribute2            => l_note_rec.attribute2,
                    p_attribute3            => l_note_rec.attribute3,
                    p_attribute4            => l_note_rec.attribute4,
                    p_attribute5            => l_note_rec.attribute5,
                    p_attribute6            => l_note_rec.attribute6,
                    p_attribute7            => l_note_rec.attribute7,
                    p_attribute8            => l_note_rec.attribute8,
                    p_attribute9            => l_note_rec.attribute9,
                    p_attribute10           => l_note_rec.attribute10,
                    p_attribute11           => l_note_rec.attribute11,
                    p_attribute12           => l_note_rec.attribute12,
                    p_attribute13           => l_note_rec.attribute13,
                    p_attribute14           => l_note_rec.attribute14,
                    p_attribute15           => l_note_rec.attribute15,
                    p_parent_note_id        => l_note_rec.parent_note_id,
                    p_entered_date          => sysdate,
                    p_entered_by            => l_note_rec.entered_by,
                    p_creation_date         => sysdate,
                    p_created_by            => fnd_global.user_id,
                    p_last_update_date      => sysdate,
                    p_last_updated_by       => fnd_global.user_id,
                    p_last_update_login     => fnd_global.login_id,
                    x_jtf_note_id           => l_new_note_id,
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data
                );

                -- Check Error Message stack.
                x_msg_count := FND_MSG_PUB.count_msg;
                IF (x_msg_count > 0 OR l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
                    THEN
                        fnd_log.string
                        (
                            fnd_log.level_unexpected,
                            l_debug_module,
                            'Call to CAC_NOTES_PVT.create_note failed...'
                        );
                    END IF;

                    -- Raise unexpected error since this is supposed to go through without any hiccups
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'Created new revisions of all associated JTF notes for ATA sequence ['||l_old_new_ata_tbl(l_ata_rec_idx).old_object_id||']'
                );
            END IF;

            -- Create revisions of all MO procedure associations to ATA sequences
            FOR l_mo_proc_rec IN get_mo_proc_details(l_old_new_ata_tbl(l_ata_rec_idx).old_object_id)
            LOOP
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
                    l_old_new_ata_tbl(l_ata_rec_idx).new_object_id,
                    l_mo_proc_rec.MR_HEADER_ID,
                    l_mo_proc_rec.ATTRIBUTE_CATEGORY,
                    l_mo_proc_rec.ATTRIBUTE1,
                    l_mo_proc_rec.ATTRIBUTE2,
                    l_mo_proc_rec.ATTRIBUTE3,
                    l_mo_proc_rec.ATTRIBUTE4,
                    l_mo_proc_rec.ATTRIBUTE5,
                    l_mo_proc_rec.ATTRIBUTE6,
                    l_mo_proc_rec.ATTRIBUTE7,
                    l_mo_proc_rec.ATTRIBUTE8,
                    l_mo_proc_rec.ATTRIBUTE9,
                    l_mo_proc_rec.ATTRIBUTE10,
                    l_mo_proc_rec.ATTRIBUTE11,
                    l_mo_proc_rec.ATTRIBUTE12,
                    l_mo_proc_rec.ATTRIBUTE13,
                    l_mo_proc_rec.ATTRIBUTE14,
                    l_mo_proc_rec.ATTRIBUTE15
                );
            END LOOP;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'Created new revisions of all associated M and O procedures for ATA sequence ['||l_old_new_ata_tbl(l_ata_rec_idx).old_object_id||']'
                );
            END IF;

            -- Create revisions of all inter-relationships of ATA sequences
            FOR l_ata_rel_rec IN get_ata_rel_details(l_old_new_ata_tbl(l_ata_rec_idx).old_object_id)
            LOOP

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
		fnd_log.string
		(
		    fnd_log.level_statement,
		    l_debug_module,
		    'Inside Inter relationships'
		);
		END IF;

		-- Priyan
		-- Fix for Bug #5468974
		-- The following loops through the l_old_new_ata_tbl and finds revised ata_sequence_id for the
		-- old ata sequence id that was associated as intre-realtionship rule to the ata that is being revised .

		FOR l_rel_ata_seq IN l_old_new_ata_tbl.FIRST..l_old_new_ata_tbl.LAST
		LOOP
			-- Find the new object id for the related ata sequence id
			IF (l_old_new_ata_tbl(l_rel_ata_seq).old_object_id = l_ata_rel_rec.related_ata_sequence_id)
			THEN
				l_rel_ata_seq_id := l_old_new_ata_tbl(l_rel_ata_seq).new_object_id;

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
				    ahl_mel_cdl_relationships_s.nextval,
				    1,
				    sysdate,
				    fnd_global.user_id,
				    sysdate,
				    fnd_global.user_id,
				    fnd_global.login_id,
				    l_old_new_ata_tbl(l_ata_rec_idx).new_object_id,
				    --priyan
				    --Fix for Bug #5468974
				    --l_ata_rel_rec.RELATED_ATA_SEQUENCE_ID,
				    l_rel_ata_seq_id,
				    l_ata_rel_rec.ATTRIBUTE_CATEGORY,
				    l_ata_rel_rec.ATTRIBUTE1,
				    l_ata_rel_rec.ATTRIBUTE2,
				    l_ata_rel_rec.ATTRIBUTE3,
				    l_ata_rel_rec.ATTRIBUTE4,
				    l_ata_rel_rec.ATTRIBUTE5,
				    l_ata_rel_rec.ATTRIBUTE6,
				    l_ata_rel_rec.ATTRIBUTE7,
				    l_ata_rel_rec.ATTRIBUTE8,
				    l_ata_rel_rec.ATTRIBUTE9,
				    l_ata_rel_rec.ATTRIBUTE10,
				    l_ata_rel_rec.ATTRIBUTE11,
				    l_ata_rel_rec.ATTRIBUTE12,
				    l_ata_rel_rec.ATTRIBUTE13,
				    l_ata_rel_rec.ATTRIBUTE14,
				    l_ata_rel_rec.ATTRIBUTE15
				);

			END IF ;
		END LOOP;
	END LOOP;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    l_debug_module,
                    'Created new revisions of all associated inter-relationships for ATA sequence ['||l_old_new_ata_tbl(l_ata_rec_idx).old_object_id||']'
                );
            END IF;

        END LOOP;
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If there exists open NRs for the MEL/CDL, need to throw a warning...
    AHL_UMP_NONROUTINES_PVT.Check_Open_NRs
    (
        x_return_status => l_return_status,
        p_mel_cdl_header_id => l_mel_cdl_header_id
    );
    -- Need to verify whether to pass all PC nodes within the tree, etc or not

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_OPEN_NRS_EXIST');
        -- There exist(s) open Non-routines for the MEL/CDL
        FND_MSG_PUB.ADD;
    END IF;
    -- API body ends here

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
        Rollback to Create_Mel_Cdl_Revision_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Create_Mel_Cdl_Revision_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Create_Mel_Cdl_Revision_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Create_Mel_Cdl_Revision',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Create_Mel_Cdl_Revision;

----------------------------------------------
-- Spec Procedure Initiate_Mel_Cdl_Approval --
----------------------------------------------
PROCEDURE Initiate_Mel_Cdl_Approval
(
    -- Standard IN params
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN              VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN              NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN              VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN              VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_mel_cdl_header_id         IN              NUMBER,
    p_mel_cdl_object_version    IN              NUMBER
)
IS
    -- Declare local variables
    l_api_name      CONSTANT    VARCHAR2(30)    := 'Initiate_Mel_Cdl_Approval';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_active                    VARCHAR2(1);
    l_process_name              VARCHAR2(30);
    l_item_type                 VARCHAR2(8);

    -- Define cursors
    CURSOR get_mel_cdl_details
    IS
    SELECT  object_version_number,
            pc_node_id,
            mel_cdl_type_code,
            status_code,
            version_number,
            revision,
            revision_date
    FROM    ahl_mel_cdl_headers
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id
    FOR UPDATE OF object_version_number NOWAIT;

    l_ovn               NUMBER;
    l_pc_node_id        NUMBER;
    l_mel_cdl_type      VARCHAR2(30);
    l_status            VARCHAR2(30);
    l_version           NUMBER;
    l_revision          VARCHAR2(30);
    l_revision_date     DATE;

    CURSOR check_dup_rev
    (
        p_pc_node_id        number,
        p_mel_cdl_type_code varchar2,
        p_revision          varchar2,
        p_mel_cdl_header_id number
    )
    IS
    SELECT  'x'
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_pc_node_id AND
            mel_cdl_type_code = p_mel_cdl_type_code AND
            revision = p_revision AND
            mel_cdl_header_id <> p_mel_cdl_header_id;

    CURSOR get_prev_rev_details
    (
        p_pc_node_id        number,
        p_mel_cdl_type      varchar2,
        p_version_number    number
    )
    IS
    SELECT  mel_cdl_header_id,
            revision_date
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_pc_node_id AND
            mel_cdl_type_code = p_mel_cdl_type AND
            version_number = p_version_number - 1;

    l_prev_mel_cdl_header_id    NUMBER;
    l_prev_revision_date        DATE;
    l_prev_expired_date         DATE;

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
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            l_debug_module||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body starts here
    -- Verify MEL/CDL id + ovn information is correct
    Check_Mel_Cdl_Exists(p_mel_cdl_header_id, p_mel_cdl_object_version);

    -- Retrieve details of the record in the database
    OPEN get_mel_cdl_details;
    FETCH get_mel_cdl_details INTO l_ovn, l_pc_node_id, l_mel_cdl_type, l_status, l_version, l_revision, l_revision_date;
    CLOSE get_mel_cdl_details;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'l_ovn='||l_ovn||' - l_pc_node_id='||l_pc_node_id||' - l_mel_cdl_type='||l_mel_cdl_type||' - l_status='||l_status||' - l_version='||l_version||' - l_revision='||l_revision
        );
    END IF;

    -- Verify only DRAFT/APPROVAL_PENDING MEL/CDL is being submitted for approval
    IF (l_status NOT IN ('DRAFT','APPROVAL_REJECTED'))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NOT_DRAFT_APPR');
        -- MEL/CDL is not in draft or approval rejected status, hence cannot submit for approval
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Verify that revision of the MEL/CDL being submitted for approval is unique
    OPEN check_dup_rev(l_pc_node_id, l_mel_cdl_type, l_revision, p_mel_cdl_header_id);
    FETCH check_dup_rev INTO l_dummy_varchar;
    IF (check_dup_rev%FOUND)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DUP_REVISION');
        FND_MESSAGE.SET_TOKEN('REV', l_revision);
        -- An MEL/CDL with revision 'REV' is already associated with the Product Classification node
        FND_MSG_PUB.ADD;
    END IF;
    CLOSE check_dup_rev;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'Basic validations done'
        );
    END IF;

    -- Retrieve the workflow process name for object 'MEL_CDL'
    ahl_utility_pvt.get_wf_process_name
    (
        p_object        => 'MEL_CDL',
        x_active        => l_active,
        x_process_name  => l_process_name ,
        x_item_type     => l_item_type,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            l_debug_module,
            'ahl_utility_pvt.get_wf_process_name returns [l_active='||l_active||'][l_process_name='||l_process_name||'][l_item_type='||l_item_type||']'
        );
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0 OR l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_active = 'Y')
    THEN
        -- If workflow is active
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'MEL_CDL approval process is active'
            );
        END IF;

        UPDATE  ahl_mel_cdl_headers
        SET     status_code = 'APPROVAL_PENDING',
                object_version_number = p_mel_cdl_object_version + 1,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

        -- Start the 'MEL_CDL' approval process for this MEL/CDL
        ahl_generic_aprv_pvt.start_wf_process
        (
            p_object                => 'MEL_CDL',
            p_activity_id           => p_mel_cdl_header_id,
            p_approval_type         => 'CONCEPT',
            p_object_version_number => p_mel_cdl_object_version + 1,
            p_orig_status_code      => 'DRAFT',
            p_new_status_code       => 'COMPLETE',
            p_reject_status_code    => 'APPROVAL_REJECTED',
            p_requester_userid      => fnd_global.user_id,
            p_notes_from_requester  => null,
            p_workflowprocess       => l_process_name,
            p_item_type             => null
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'Approval process for MEL/CDL ['||p_mel_cdl_header_id||']['||to_char(p_mel_cdl_object_version + 1)||'] has been initiated'
            );
        END IF;
    ELSE
        -- If wortkflow process is not active, then force complete the MEL/CDL
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                l_debug_module,
                'MEL_CDL approval process is not active, hence force complete MEL/CDL'
            );
        END IF;

        UPDATE  ahl_mel_cdl_headers
        SET     status_code = 'COMPLETE',
                object_version_number = p_mel_cdl_object_version + 1,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

        IF (l_version > 1)
        THEN
            -- Retrieve previous revision details
            OPEN get_prev_rev_details(l_pc_node_id, l_mel_cdl_type, l_version);
            FETCH get_prev_rev_details INTO l_prev_mel_cdl_header_id, l_prev_revision_date;
            CLOSE get_prev_rev_details;

            -- Calculate previous revision's expired_date
            l_prev_expired_date := l_revision_date - 1;
            IF (trunc(l_prev_expired_date) < trunc(l_prev_revision_date))
            THEN
                l_prev_expired_date := l_prev_revision_date;
            END IF;

            -- Once the current revision of the MEL/CDL is complete, need to expire the earlier revision
            UPDATE  ahl_mel_cdl_headers
            SET     expired_date = l_prev_expired_date,
                    object_version_number = object_version_number + 1,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
            WHERE   mel_cdl_header_id = l_prev_mel_cdl_header_id;
        END IF;
    END IF;
    -- API body ends here

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

---------------------------------------------
-- Non-spec Procedure Check_Mel_Cdl_Exists --
---------------------------------------------
PROCEDURE Check_Mel_Cdl_Exists
(
    p_mel_cdl_header_id         IN  NUMBER,
    p_mel_cdl_object_version    IN  NUMBER
)
IS

    CURSOR check_exists
    IS
    SELECT  object_version_number
    FROM    ahl_mel_cdl_headers
    WHERE   mel_cdl_header_id = p_mel_cdl_header_id;

    l_ovn       NUMBER;

BEGIN

    OPEN check_exists;
    FETCH check_exists INTO l_ovn;
    IF (check_exists%NOTFOUND)
    THEN
        CLOSE check_exists;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_NOTFOUND');
        -- MEL/CDL is not found
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        CLOSE check_exists;
        IF (l_ovn <> p_mel_cdl_object_version)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_RECORD_CHANGED');
            -- Record has been modified by another user
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

END Check_Mel_Cdl_Exists;

--------------------------------------------
-- Non-spec Procedure Convert_Value_To_Id --
--------------------------------------------
PROCEDURE Convert_Value_To_Id
(
    p_x_mel_cdl_header_rec      IN OUT NOCOPY   Header_Rec_Type
)
IS
    l_ret_val                   BOOLEAN;
BEGIN

    -- Convert value-to-id for mel_cdl_type
    IF (p_x_mel_cdl_header_rec.mel_cdl_type_code IS NULL OR p_x_mel_cdl_header_rec.mel_cdl_type_code = FND_API.G_MISS_CHAR)
    THEN
        IF (p_x_mel_cdl_header_rec.mel_cdl_type_meaning IS NULL OR p_x_mel_cdl_header_rec.mel_cdl_type_meaning = FND_API.G_MISS_CHAR)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_TYPE_MAND');
            -- MEL/CDL type is mandatory
            FND_MSG_PUB.ADD;
        ELSE
            AHL_UTIL_MC_PKG.Convert_To_LookupCode
            (
                p_lookup_type       => 'AHL_MEL_CDL_TYPE',
                p_lookup_meaning    => p_x_mel_cdl_header_rec.mel_cdl_type_meaning,
                x_lookup_code       => p_x_mel_cdl_header_rec.mel_cdl_type_code,
                x_return_val        => l_ret_val
            );
            IF NOT (l_ret_val)
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_TYPE_INV');
                -- MEL/CDL type is invalid
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    ELSE
        IF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_MEL_CDL_TYPE', p_x_mel_cdl_header_rec.mel_cdl_type_code))
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_TYPE_INV');
            -- MEL/CDL type is invalid
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

END Convert_Value_To_Id;

-------------------------------------------------
-- Non-spec Procedure Check_Duplicate_Revision --
-------------------------------------------------
PROCEDURE Check_Duplicate_Revision
(
    p_x_mel_cdl_header_rec      IN  Header_Rec_Type
)
IS
    CURSOR check_dup_rev
    IS
    SELECT  'x'
    FROM    ahl_mel_cdl_headers
    WHERE   pc_node_id = p_x_mel_cdl_header_rec.pc_node_id AND
            mel_cdl_type_code = p_x_mel_cdl_header_rec.mel_cdl_type_code AND
            revision = p_x_mel_cdl_header_rec.revision AND
            mel_cdl_header_id <> nvl(p_x_mel_cdl_header_rec.mel_cdl_header_id, -1);
BEGIN
    IF (p_x_mel_cdl_header_rec.revision IS NULL OR p_x_mel_cdl_header_rec.revision = FND_API.G_MISS_CHAR)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REV_MAND');
        -- MEL/CDL revision is mandatory
        FND_MSG_PUB.ADD;
    ELSE
        OPEN check_dup_rev;
        FETCH check_dup_rev INTO l_dummy_varchar;
        IF (check_dup_rev%FOUND)
        THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_DUP_REVISION');
            FND_MESSAGE.SET_TOKEN('REV', p_x_mel_cdl_header_rec.revision);
            -- An MEL/CDL with revision 'REV' is already associated with the Product Classification node
            FND_MSG_PUB.ADD;
        END IF;
        CLOSE check_dup_rev;
    END IF;

END Check_Duplicate_Revision;

End AHL_MEL_CDL_HEADERS_PVT;

/
