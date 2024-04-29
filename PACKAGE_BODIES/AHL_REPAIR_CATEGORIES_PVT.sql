--------------------------------------------------------
--  DDL for Package Body AHL_REPAIR_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_REPAIR_CATEGORIES_PVT" AS
/* $Header: AHLVRCTB.pls 120.12 2006/08/22 07:45:38 priyan noship $ */

G_USER_ID   CONSTANT    NUMBER      := TO_NUMBER(FND_GLOBAL.USER_ID);
G_LOGIN_ID  CONSTANT    NUMBER      := TO_NUMBER(FND_GLOBAL.LOGIN_ID);
G_SYSDATE   CONSTANT    DATE        := SYSDATE;

l_dummy_varchar     VARCHAR2(1);
l_dummy_number      NUMBER;

-------------------------------------
-- Validation procedure signatures --
-------------------------------------
PROCEDURE VALIDATE_REP_CAT_EXISTS
(
    p_rep_cat_id in number,
    p_object_ver_num in number
);

PROCEDURE PROCESS_REPAIR_CATEGORIES
(
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    p_x_repair_category_tbl     IN OUT NOCOPY   Repair_Category_Tbl_Type
)
IS

    CURSOR check_srurg_exists
    (
        sru_id in number
    )
    IS
    SELECT  name
    FROM    cs_incident_urgencies_vl
    WHERE   incident_urgency_id = sru_id AND
            trunc(sysdate) >= trunc(nvl(start_date_active, sysdate)) AND
            trunc(sysdate) < trunc(nvl(end_date_active, sysdate + 1));

    CURSOR get_srurg_id_from_name
    (
        sr_name in varchar2
    )
    IS
    SELECT  incident_urgency_id
    FROM    cs_incident_urgencies_vl
    WHERE   name = sr_name AND
            trunc(sysdate) >= trunc(nvl(start_date_active, sysdate)) AND
            trunc(sysdate) < trunc(nvl(end_date_active, sysdate + 1));

    CURSOR check_repcat_exists
    (
        srurg_id in number
    )
    IS
    SELECT  'x'
    FROM    ahl_repair_categories
    WHERE   sr_urgency_id = srurg_id;

    CURSOR check_reptime_exists
    (
        reptime in number,
        repcat_id in number
    )
    IS
    SELECT  'x'
    FROM    ahl_repair_categories
    WHERE   nvl(repair_time, -1) = nvl(reptime, -1) AND
            (repcat_id is null or repcat_id <> repair_category_id);

    CURSOR check_repcat_assoc
    (
        rep_cat_id in number
    )
    IS
    SELECT  'x'
    FROM    ahl_mel_cdl_ata_sequences
    WHERE   repair_category_id = rep_cat_id;

    CURSOR check_srurg_chg_for_upd
    (
        rep_cat_id in number,
        sr_id in number
    )
    IS
    SELECT  'x'
    FROM    ahl_repair_categories
    WHERE   repair_category_id = rep_cat_id AND
            sr_urgency_id = sr_id;

    l_api_name      CONSTANT    VARCHAR2(30)    := 'PROCESS_REPAIR_CATEGORIES';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT process_repair_categories_sp;

     -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,p_api_version,l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_x_repair_category_tbl.count > 0
    THEN
        -- The first loop will perform all common validations + delete the records
        FOR i IN p_x_repair_category_tbl.FIRST..p_x_repair_category_tbl.LAST
        LOOP
            -- Verify DML operation flag is right...
            IF (p_x_repair_category_tbl(i).dml_operation NOT IN ( 'C', 'D', 'U'))
            THEN
                FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_INVALID_DML');
                FND_MESSAGE.SET_TOKEN('FIELD', p_x_repair_category_tbl(i).dml_operation);
                FND_MESSAGE.SET_TOKEN('RECORD', p_x_repair_category_tbl(i).incident_urgency_name||' - '||p_x_repair_category_tbl(i).repair_time);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (p_x_repair_category_tbl(i).DML_OPERATION = 'D')
            THEN
                -- Validate id + ovn combination...
                VALIDATE_REP_CAT_EXISTS
                (
                    p_x_repair_category_tbl(i).repair_category_id,
                    p_x_repair_category_tbl(i).object_version_number
                );

                OPEN check_repcat_assoc (p_x_repair_category_tbl(i).repair_category_id);
                FETCH check_repcat_assoc INTO l_dummy_varchar;
                IF (check_repcat_assoc%NOTFOUND)
                THEN
                    DELETE FROM ahl_repair_categories
                    WHERE repair_category_id = p_x_repair_category_tbl(i).repair_category_id;
                ELSE
                    SELECT  cssr.name
                    INTO    p_x_repair_category_tbl(i).incident_urgency_name
                    FROM    cs_incident_urgencies_vl cssr , ahl_repair_categories repcat
                    WHERE   repcat.sr_urgency_id = cssr.incident_urgency_id AND
                            repcat.repair_category_id = p_x_repair_category_tbl(i).repair_category_id;

                    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_REPCAT_ATASEQ_DEL');
                    FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE check_repcat_assoc;

                -- Check error message stack
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count > 0
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
        END LOOP;

        -- The second loop will update the records
        FOR i IN p_x_repair_category_tbl.FIRST..p_x_repair_category_tbl.LAST
        LOOP
            IF (p_x_repair_category_tbl(i).dml_operation = 'U')
            THEN
                -- Validate id + ovn combination...
                VALIDATE_REP_CAT_EXISTS
                (
                    p_x_repair_category_tbl(i).repair_category_id,
                    p_x_repair_category_tbl(i).object_version_number
                );

                -- Resolve sr urgency name and id, perform mandatory validations
                IF (p_x_repair_category_tbl(i).incident_urgency_name IS NOT NULL AND p_x_repair_category_tbl(i).incident_urgency_name <> FND_API.G_MISS_CHAR)
                THEN
                    OPEN get_srurg_id_from_name (p_x_repair_category_tbl(i).incident_urgency_name);
                    FETCH get_srurg_id_from_name INTO p_x_repair_category_tbl(i).incident_urgency_id;
                    IF (get_srurg_id_from_name%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_INV');
                        FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE get_srurg_id_from_name;
                ELSIF (p_x_repair_category_tbl(i).incident_urgency_id IS NOT NULL AND p_x_repair_category_tbl(i).incident_urgency_id <> FND_API.G_MISS_NUM)
                THEN
                    OPEN check_srurg_exists (p_x_repair_category_tbl(i).incident_urgency_id);
                    FETCH check_srurg_exists INTO p_x_repair_category_tbl(i).incident_urgency_name;
                    IF (check_srurg_exists%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_INV');
                        FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_id);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    CLOSE check_srurg_exists;
                ELSE
                    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_MAND');
                    FND_MSG_PUB.ADD;
                END IF;

		-- Trim the urgency name passed in
		   p_x_repair_category_tbl(i).incident_urgency_name := LTRIM(RTRIM(p_x_repair_category_tbl(i).incident_urgency_name));

                -- Validate sr urgency is not modified for update
                OPEN check_srurg_chg_for_upd (p_x_repair_category_tbl(i).repair_category_id, p_x_repair_category_tbl(i).incident_urgency_id);
                FETCH check_srurg_chg_for_upd INTO l_dummy_varchar;
                IF (check_srurg_chg_for_upd%NOTFOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_SRURG_UPD_NOCHG');
                    FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE check_srurg_chg_for_upd;

                -- Validate repair time is valid
                IF (p_x_repair_category_tbl(i).repair_time <= 0 )
                THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_TIME_INV');
                    FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                    FND_MSG_PUB.ADD;
                END IF;

                -- Validate repair time already does not exist for another record
                OPEN check_reptime_exists(p_x_repair_category_tbl(i).repair_time, p_x_repair_category_tbl(i).repair_category_id);
                FETCH check_reptime_exists INTO l_dummy_varchar;
                IF (check_reptime_exists%FOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_SRURG_TIME_EXISTS');
                    FND_MESSAGE.SET_TOKEN('TIME', p_x_repair_category_tbl(i).repair_time);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE check_reptime_exists;

                -- Check error message stack
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count > 0
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Default values for update
                p_x_repair_category_tbl(i).object_version_number := p_x_repair_category_tbl(i).object_version_number + 1;

                UPDATE  AHL_REPAIR_CATEGORIES
                SET     OBJECT_VERSION_NUMBER   = p_x_repair_category_tbl(i).object_version_number,
                        LAST_UPDATE_DATE        = G_SYSDATE,
                        LAST_UPDATED_BY         = G_USER_ID,
                        LAST_UPDATE_LOGIN       = G_LOGIN_ID,
                        REPAIR_TIME             = p_x_repair_category_tbl(i).repair_time,
                        SR_URGENCY_ID           = p_x_repair_category_tbl(i).incident_urgency_id,
                        ATTRIBUTE_CATEGORY      = p_x_repair_category_tbl(i).attribute_category,
                        ATTRIBUTE1              = p_x_repair_category_tbl(i).attribute1,
                        ATTRIBUTE2              = p_x_repair_category_tbl(i).attribute2,
                        ATTRIBUTE3              = p_x_repair_category_tbl(i).attribute3,
                        ATTRIBUTE4              = p_x_repair_category_tbl(i).attribute4,
                        ATTRIBUTE5              = p_x_repair_category_tbl(i).attribute5,
                        ATTRIBUTE6              = p_x_repair_category_tbl(i).attribute6,
                        ATTRIBUTE7              = p_x_repair_category_tbl(i).attribute7,
                        ATTRIBUTE8              = p_x_repair_category_tbl(i).attribute8,
                        ATTRIBUTE9              = p_x_repair_category_tbl(i).attribute9,
                        ATTRIBUTE10             = p_x_repair_category_tbl(i).attribute10,
                        ATTRIBUTE11             = p_x_repair_category_tbl(i).attribute11,
                        ATTRIBUTE12             = p_x_repair_category_tbl(i).attribute12,
                        ATTRIBUTE13             = p_x_repair_category_tbl(i).attribute13,
                        ATTRIBUTE14             = p_x_repair_category_tbl(i).attribute14,
                        ATTRIBUTE15             = p_x_repair_category_tbl(i).attribute15
                WHERE   REPAIR_CATEGORY_ID = p_x_repair_category_tbl(i).repair_category_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_statement,
                        l_debug_module,
                        'Update repair category ' ||p_x_repair_category_tbl(i).repair_category_id
                    );
                END IF;
            END IF;
        END LOOP;

        -- The second loop will create the records
        FOR i IN p_x_repair_category_tbl.FIRST..p_x_repair_category_tbl.LAST
        LOOP
            IF (p_x_repair_category_tbl(i).dml_operation = 'C')
            THEN

	        -- Resolve sr urgency name and id, perform mandatory validations
                IF (p_x_repair_category_tbl(i).incident_urgency_name IS NOT NULL AND p_x_repair_category_tbl(i).incident_urgency_name <> FND_API.G_MISS_CHAR)
                THEN
                    OPEN get_srurg_id_from_name (p_x_repair_category_tbl(i).incident_urgency_name);
                    FETCH get_srurg_id_from_name INTO p_x_repair_category_tbl(i).incident_urgency_id;
                    IF (get_srurg_id_from_name%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_INV');
                        FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                        FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE get_srurg_id_from_name;
                ELSIF (p_x_repair_category_tbl(i).incident_urgency_id IS NOT NULL AND p_x_repair_category_tbl(i).incident_urgency_id <> FND_API.G_MISS_NUM)
                THEN
                    OPEN check_srurg_exists (p_x_repair_category_tbl(i).incident_urgency_id);
                    FETCH check_srurg_exists INTO p_x_repair_category_tbl(i).incident_urgency_name;
                    IF (check_srurg_exists%NOTFOUND)
                    THEN
                        FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_INV');
                        FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_id);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    CLOSE check_srurg_exists;
                ELSE
                    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_MAND');
                    FND_MSG_PUB.ADD;
                END IF;

		-- Trim the urgency name passed in
		   p_x_repair_category_tbl(i).incident_urgency_name := LTRIM(RTRIM(p_x_repair_category_tbl(i).incident_urgency_name));

                -- Validate sr urgency already does not exist for another record
                OPEN check_repcat_exists(p_x_repair_category_tbl(i).incident_urgency_id);
                FETCH check_repcat_exists INTO l_dummy_varchar;
                IF (check_repcat_exists%FOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_SRURG_EXISTS');
                    FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE check_repcat_exists;

                -- Validate repair time is valid
                IF (p_x_repair_category_tbl(i).repair_time <= 0 )
                THEN
                    FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_MEL_CDL_SRURG_TIME_INV');
                    FND_MESSAGE.SET_TOKEN('SRNAME', p_x_repair_category_tbl(i).incident_urgency_name);
                    FND_MSG_PUB.ADD;
                END IF;

                -- Validate repair time already does not exist for another record
                OPEN check_reptime_exists(p_x_repair_category_tbl(i).repair_time, null);
                FETCH check_reptime_exists INTO l_dummy_varchar;
                IF (check_reptime_exists%FOUND)
                THEN
                    FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_SRURG_TIME_EXISTS');
                    FND_MESSAGE.SET_TOKEN('TIME', p_x_repair_category_tbl(i).repair_time);
                    FND_MSG_PUB.ADD;
                END IF;
                CLOSE check_reptime_exists;

                -- Check error message stack
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count > 0
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Default values for create
                IF (p_x_repair_category_tbl(i).repair_category_id IS NULL OR p_x_repair_category_tbl(i).repair_category_id = FND_API.G_MISS_NUM)
                THEN
                    select ahl_repair_categories_s.nextval into p_x_repair_category_tbl(i).repair_category_id from dual;
                END IF;
                p_x_repair_category_tbl(i).object_version_number := 1;

                INSERT INTO AHL_REPAIR_CATEGORIES
                (
                    REPAIR_CATEGORY_ID,
                    OBJECT_VERSION_NUMBER,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    REPAIR_TIME,
                    SR_URGENCY_ID,
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
                    p_x_repair_category_tbl(i).repair_category_id,
                    p_x_repair_category_tbl(i).object_version_number,
                    G_SYSDATE,
                    G_USER_ID,
                    G_SYSDATE,
                    G_USER_ID,
                    G_LOGIN_ID,
                    p_x_repair_category_tbl(i).repair_time,
                    p_x_repair_category_tbl(i).incident_urgency_id,
                    p_x_repair_category_tbl(i).attribute_category,
                    p_x_repair_category_tbl(i).attribute1,
                    p_x_repair_category_tbl(i).attribute2,
                    p_x_repair_category_tbl(i).attribute3,
                    p_x_repair_category_tbl(i).attribute4,
                    p_x_repair_category_tbl(i).attribute5,
                    p_x_repair_category_tbl(i).attribute6,
                    p_x_repair_category_tbl(i).attribute7,
                    p_x_repair_category_tbl(i).attribute8,
                    p_x_repair_category_tbl(i).attribute9,
                    p_x_repair_category_tbl(i).attribute10,
                    p_x_repair_category_tbl(i).attribute11,
                    p_x_repair_category_tbl(i).attribute12,
                    p_x_repair_category_tbl(i).attribute13,
                    p_x_repair_category_tbl(i).attribute14,
                    p_x_repair_category_tbl(i).attribute15
                );

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_statement,
                        l_debug_module,
                        'Create repair category ' ||p_x_repair_category_tbl(i).repair_category_id
                    );
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- Check error message stack at completing proc
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Commit if required to do so
    IF FND_API.TO_BOOLEAN (p_commit)
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
        Rollback to process_repair_categories_sp;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to process_repair_categories_sp;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to process_repair_categories_sp;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name          => G_PKG_NAME,
                p_procedure_name    => l_api_name,
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END PROCESS_REPAIR_CATEGORIES;

---------------------------
-- Validation procedures --
---------------------------
PROCEDURE VALIDATE_REP_CAT_EXISTS
(
    p_rep_cat_id in number,
    p_object_ver_num in number
)
IS

    CURSOR check_rep_cat_exists
    (
        p_rep_cat_id in number
    )
    IS
    SELECT  object_version_number
    FROM    ahl_repair_categories
    WHERE   repair_category_id = p_rep_cat_id;

BEGIN

    OPEN check_rep_cat_exists (p_rep_cat_id);
    FETCH check_rep_cat_exists INTO l_dummy_number;

    IF (check_rep_cat_exists%NOTFOUND)
    THEN
        CLOSE check_rep_cat_exists;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_MEL_CDL_REPCAT_NOTFOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_object_ver_num <> l_dummy_number)
    THEN
        CLOSE check_rep_cat_exists;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_rep_cat_exists;

END VALIDATE_REP_CAT_EXISTS;

End AHL_REPAIR_CATEGORIES_PVT;

/
