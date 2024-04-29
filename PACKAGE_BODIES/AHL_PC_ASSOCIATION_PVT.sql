--------------------------------------------------------
--  DDL for Package Body AHL_PC_ASSOCIATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_ASSOCIATION_PVT" AS
/* $Header: AHLVPCAB.pls 120.3.12010000.3 2010/01/11 07:22:18 snarkhed ship $ */

    G_DEBUG VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;

    --------------------------
    -- SET_PC_HEADER_STATUS --
    --------------------------
    PROCEDURE SET_PC_HEADER_STATUS (p_pc_node_id IN NUMBER);

    ---------------------------
    -- VALIDATION PROCEDURES --
    ---------------------------
    PROCEDURE VALIDATE_ASSOCIATION ( p_x_assos_rec IN AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC );

    -----------------
    -- ATTACH_UNIT --
    -----------------
    PROCEDURE ATTACH_UNIT (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
        x_return_status       OUT    NOCOPY       VARCHAR2,
        x_msg_count           OUT    NOCOPY       NUMBER,
            x_msg_data            OUT    NOCOPY       VARCHAR2
    ) IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'ATTACH_UNIT';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);

    l_assos_id          NUMBER;
    l_sysdate           DATE        := SYSDATE;
    l_link_id           NUMBER      := 0;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT ATTACH_UNIT_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.ENABLE_DEBUG;
                END IF;

        IF (p_x_assos_rec.operation_flag = G_DML_CREATE OR p_x_assos_rec.operation_flag = G_DML_ASSIGN)
        THEN
            VALIDATE_ASSOCIATION (p_x_assos_rec);
        END IF;

            -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_x_assos_rec.OPERATION_FLAG = G_DML_LINK
            THEN
           l_link_id := p_x_assos_rec.LINK_TO_ASSOCIATION_ID;
            END IF;

        SELECT AHL_PC_ASSOCIATIONS_S.NEXTVAL INTO l_assos_id FROM DUAL;

        INSERT INTO AHL_PC_ASSOCIATIONS (
            PC_ASSOCIATION_ID,
            PC_NODE_ID,
            UNIT_ITEM_ID,
            INVENTORY_ORG_ID,
            ASSOCIATION_TYPE_FLAG,
            LINK_TO_ASSOCIATION_ID,
            DRAFT_FLAG,
            Last_update_date,
            Last_updated_by,
            Creation_date,
            Created_by,
            Last_update_login,
            SECURITY_GROUP_ID,
            OBJECT_VERSION_NUMBER,
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
            l_assos_id,
            p_x_assos_rec.PC_NODE_ID,
            p_x_assos_rec.UNIT_ITEM_ID,
            0,
            G_UNIT,
            nvl(l_link_id,0),
            'N',
            l_sysdate,
            g_user_id,
            l_sysdate,
            g_user_id,
            g_user_id,
            null,
            1,
            p_x_assos_rec.ATTRIBUTE_CATEGORY,
            p_x_assos_rec.ATTRIBUTE1,
            p_x_assos_rec.ATTRIBUTE2,
            p_x_assos_rec.ATTRIBUTE3,
            p_x_assos_rec.ATTRIBUTE4,
            p_x_assos_rec.ATTRIBUTE5,
            p_x_assos_rec.ATTRIBUTE6,
            p_x_assos_rec.ATTRIBUTE7,
            p_x_assos_rec.ATTRIBUTE8,
            p_x_assos_rec.ATTRIBUTE9,
            p_x_assos_rec.ATTRIBUTE10,
            p_x_assos_rec.ATTRIBUTE11,
            p_x_assos_rec.ATTRIBUTE12,
            p_x_assos_rec.ATTRIBUTE13,
            p_x_assos_rec.ATTRIBUTE14,
            p_x_assos_rec.ATTRIBUTE15
        );

        p_x_assos_rec.PC_ASSOCIATION_ID := l_assos_id;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('PCA -- PVT -- ATTACH_UNIT for ID='||p_x_assos_rec.PC_ASSOCIATION_ID||' -- unit_id'||p_x_assos_rec.UNIT_ITEM_ID||' -- pc_node_id='||p_x_assos_rec.PC_NODE_ID);
                END IF;

        UPDATE ahl_pc_nodes_b
        SET child_count = NVL(child_count, 0) + 1
        WHERE pc_node_id = p_x_assos_rec.pc_node_id;

        SET_PC_HEADER_STATUS (p_x_assos_rec.pc_node_id);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Standard check for p_commit
            IF FND_API.To_Boolean (p_commit)
            THEN
                COMMIT WORK;
            END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to ATTACH_UNIT_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to ATTACH_UNIT_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Rollback to ATTACH_UNIT_PVT;
                IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                    fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'ATTACH_UNIT',
                                 p_error_text     => SUBSTR(SQLERRM,1,240) );
                END IF;
                FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false );

    END ATTACH_UNIT;

    -----------------
    -- DETACH_UNIT --
    -----------------
    PROCEDURE DETACH_UNIT (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
        x_return_status       OUT    NOCOPY       VARCHAR2,
        x_msg_count           OUT    NOCOPY       NUMBER,
        x_msg_data            OUT    NOCOPY       VARCHAR2
    ) IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'ATTACH_UNIT';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);

    l_ump_attached          VARCHAR2(1)     := FND_API.G_FALSE;
    l_exist                         VARCHAR2(1);
    l_is_pc_primary                 VARCHAR2(1)     := 'N';

    CURSOR is_pc_primary (p_pc_node_id IN NUMBER)
    IS
            SELECT HEAD.PRIMARY_FLAG
            FROM AHL_PC_HEADERS_B HEAD, AHL_PC_NODES_B NODE
            WHERE NODE.PC_HEADER_ID = HEAD.PC_HEADER_ID AND
                  NODE.PC_NODE_ID = p_pc_node_id;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT DETACH_UNIT_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.ENABLE_DEBUG;
                END IF;

        VALIDATE_ASSOCIATION (p_x_assos_rec);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- API BODY here...
        -- Commenting for ER - Bug 278630
        --OPEN is_pc_primary(p_x_assos_rec.pc_node_id);
               -- FETCH is_pc_primary INTO l_is_pc_primary;
            --CLOSE is_pc_primary;
               -- IF (l_is_pc_primary = 'Y')
               -- THEN
            --  BEGIN

            --  SELECT distinct 'X'
            --  INTO l_exist
            --  FROM ahl_utilization_forecast_v
            --  WHERE unit_config_header_id = nvl(p_x_assos_rec.UNIT_ITEM_ID,FND_PROFILE.VALUE('ORG_ID'));

            --  l_ump_attached := FND_API.G_TRUE;

            --  EXCEPTION
            --      WHEN NO_DATA_FOUND THEN
            --          l_ump_attached := FND_API.G_FALSE;
            --      WHEN OTHERS THEN
            --          l_ump_attached := FND_API.G_FALSE;

            --  END;
            --END IF;

        IF (l_ump_attached = FND_API.G_FALSE)
        THEN
            -- Knocking off units...
            DELETE FROM AHL_PC_ASSOCIATIONS
            WHERE PC_ASSOCIATION_ID = p_x_assos_rec.PC_ASSOCIATION_ID;

            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCA -- PVT -- DETACH_UNIT for ID='||p_x_assos_rec.PC_ASSOCIATION_ID);
                    END IF;

            UPDATE ahl_pc_nodes_b
            SET child_count = NVL(child_count, 1) - 1
            WHERE pc_node_id = p_x_assos_rec.pc_node_id;
        --ELSE
        --  FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_DEL_HAS_ASSOS');
        --      FND_MSG_PUB.ADD;
        END IF;

        SET_PC_HEADER_STATUS (p_x_assos_rec.pc_node_id);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                        p_data  => x_msg_data,
                        p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to DETACH_UNIT_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DETACH_UNIT_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DETACH_UNIT_PVT;
            IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'DETACH_UNIT',
                             p_error_text     => SUBSTR(SQLERRM,1,240) );
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

    END DETACH_UNIT;

    -----------------
    -- ATTACH_ITEM --
    -----------------
    PROCEDURE ATTACH_ITEM (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
        x_return_status       OUT    NOCOPY       VARCHAR2,
        x_msg_count           OUT    NOCOPY       NUMBER,
        x_msg_data            OUT    NOCOPY       VARCHAR2
    ) IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'ATTACH_ITEM';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);

    l_assos_id          NUMBER;
    l_sysdate           DATE        := SYSDATE;
    l_link_id           NUMBER      := 0;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT ATTACH_ITEM_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.ENABLE_DEBUG;
                END IF;

        IF (p_x_assos_rec.operation_flag = G_DML_CREATE OR p_x_assos_rec.operation_flag = G_DML_ASSIGN)
        THEN
            VALIDATE_ASSOCIATION (p_x_assos_rec);
        END IF;

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

            IF p_x_assos_rec.OPERATION_FLAG = G_DML_LINK
            THEN
           l_link_id := p_x_assos_rec.LINK_TO_ASSOCIATION_ID;
            END IF;

        -- API BODY here...
        SELECT AHL_PC_ASSOCIATIONS_S.NEXTVAL INTO l_assos_id FROM DUAL;

        INSERT INTO AHL_PC_ASSOCIATIONS (
            PC_ASSOCIATION_ID,
            PC_NODE_ID,
            UNIT_ITEM_ID,
            INVENTORY_ORG_ID,
            ASSOCIATION_TYPE_FLAG,
            LINK_TO_ASSOCIATION_ID,
            DRAFT_FLAG,
            Last_update_date,
            Last_updated_by,
            Creation_date,
            Created_by,
            Last_update_login,
            SECURITY_GROUP_ID,
            OBJECT_VERSION_NUMBER,
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
            l_assos_id,
            p_x_assos_rec.PC_NODE_ID,
            p_x_assos_rec.UNIT_ITEM_ID,
            p_x_assos_rec.INVENTORY_ORG_ID,
            G_PART,
            nvl(l_link_id,0),
            'N',
            l_sysdate,
            g_user_id,
            l_sysdate,
            g_user_id,
            g_user_id,
            null,
            1,
            p_x_assos_rec.ATTRIBUTE_CATEGORY,
            p_x_assos_rec.ATTRIBUTE1,
            p_x_assos_rec.ATTRIBUTE2,
            p_x_assos_rec.ATTRIBUTE3,
            p_x_assos_rec.ATTRIBUTE4,
            p_x_assos_rec.ATTRIBUTE5,
            p_x_assos_rec.ATTRIBUTE6,
            p_x_assos_rec.ATTRIBUTE7,
            p_x_assos_rec.ATTRIBUTE8,
            p_x_assos_rec.ATTRIBUTE9,
            p_x_assos_rec.ATTRIBUTE10,
            p_x_assos_rec.ATTRIBUTE11,
            p_x_assos_rec.ATTRIBUTE12,
            p_x_assos_rec.ATTRIBUTE13,
            p_x_assos_rec.ATTRIBUTE14,
            p_x_assos_rec.ATTRIBUTE15
        );

        p_x_assos_rec.PC_ASSOCIATION_ID := l_assos_id;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('PCA -- PVT -- ATTACH_PART for ID='||p_x_assos_rec.PC_ASSOCIATION_ID||' -- part_id'||p_x_assos_rec.UNIT_ITEM_ID||' -- pc_node_id='||p_x_assos_rec.PC_NODE_ID);
                END IF;

        UPDATE ahl_pc_nodes_b
        SET child_count = NVL(child_count, 0) + 1
        WHERE pc_node_id = p_x_assos_rec.pc_node_id;

        SET_PC_HEADER_STATUS (p_x_assos_rec.pc_node_id);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

            -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                        p_data  => x_msg_data,
                        p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to ATTACH_ITEM_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to ATTACH_ITEM_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to ATTACH_ITEM_PVT;
            IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'ATTACH_ITEM',
                             p_error_text     => SUBSTR(SQLERRM,1,240) );
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

    END ATTACH_ITEM;

    -----------------
    -- DETACH_ITEM --
    -----------------
    PROCEDURE DETACH_ITEM (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
        x_return_status       OUT    NOCOPY       VARCHAR2,
        x_msg_count           OUT    NOCOPY       NUMBER,
        x_msg_data            OUT    NOCOPY       VARCHAR2
    ) IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'ATTACH_ITEM';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);

    l_ump_attached          VARCHAR2(1)     := FND_API.G_FALSE;
    l_exist                         VARCHAR2(1);
    l_is_pc_primary                 VARCHAR2(1)     := 'N';

    CURSOR is_pc_primary (p_pc_node_id IN NUMBER)
    IS
            SELECT HEAD.PRIMARY_FLAG
            FROM AHL_PC_HEADERS_B HEAD, AHL_PC_NODES_B NODE
            WHERE NODE.PC_HEADER_ID = HEAD.PC_HEADER_ID AND
                  NODE.PC_NODE_ID = p_pc_node_id;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT DETACH_ITEM_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.ENABLE_DEBUG;
                END IF;

        VALIDATE_ASSOCIATION (p_x_assos_rec);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- API BODY here...
        -- Commented for ER - Bug 27786360
        --OPEN is_pc_primary(p_x_assos_rec.pc_node_id);
        --FETCH is_pc_primary INTO l_is_pc_primary;
        --CLOSE is_pc_primary;
        --IF (l_is_pc_primary = 'Y')
        --THEN
        --
        --  BEGIN
        --
        --  SELECT distinct 'X'
        --  INTO l_exist
        --  FROM ahl_utilization_forecast_v
        --  WHERE inventory_item_id = p_x_assos_rec.UNIT_ITEM_ID and
        --             nvl(inventory_org_id,FND_PROFILE.VALUE('ORG_ID')) = nvl(p_x_assos_rec.INVENTORY_ORG_ID,FND_PROFILE.VALUE('ORG_ID'));
        --
        --

        --  l_ump_attached := FND_API.G_TRUE;

        --  EXCEPTION
        --  WHEN NO_DATA_FOUND THEN
        --          l_ump_attached := FND_API.G_FALSE;
        --  WHEN OTHERS THEN
        --          l_ump_attached := FND_API.G_FALSE;

        --  END;
        --END IF;

        IF (l_ump_attached = FND_API.G_FALSE)
        THEN
            -- Knocking off items...

            DELETE FROM AHL_PC_ASSOCIATIONS
            WHERE PC_ASSOCIATION_ID = p_x_assos_rec.PC_ASSOCIATION_ID;

            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCA -- PVT -- DETACH_PART for ID='||p_x_assos_rec.PC_ASSOCIATION_ID);
                    END IF;

            UPDATE ahl_pc_nodes_b
            SET child_count = NVL(child_count, 1) - 1
            WHERE pc_node_id = p_x_assos_rec.pc_node_id;
        --ELSE
        --  FND_MESSAGE.Set_Name('AHL','AHL_PC_PART_DEL_HAS_ASSOS');
        --      FND_MSG_PUB.ADD;
        END IF;

        SET_PC_HEADER_STATUS (p_x_assos_rec.pc_node_id);

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                        p_data  => x_msg_data,
                        p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to DETACH_ITEM_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DETACH_ITEM_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DETACH_ITEM_PVT;
            IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'DETACH_ITEM',
                             p_error_text     => SUBSTR(SQLERRM,1,240) );
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

    END DETACH_ITEM;

    ----------------------
    -- PROCESS_DOCUMENT --
    ----------------------
    PROCEDURE PROCESS_DOCUMENT (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type         IN        VARCHAR2  := NULL,
        p_x_assos_tbl         IN OUT NOCOPY AHL_DI_ASSO_DOC_GEN_PUB.association_tbl,
        x_return_status       OUT    NOCOPY       VARCHAR2,
        x_msg_count           OUT    NOCOPY       NUMBER,
        x_msg_data            OUT    NOCOPY       VARCHAR2
    )
    IS

    l_api_name          CONSTANT    VARCHAR2(30)    := 'PROCESS_DOCUMENT';
    l_api_version           CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);
    l_dummy             VARCHAR2(1);
    l_status            VARCHAR2(30);

    CURSOR check_node_exists (p_pc_node_id IN NUMBER)
    IS
        SELECT 'X'
        FROM ahl_pc_nodes_b
        WHERE pc_node_id = p_pc_node_id;

    CURSOR get_pc_header_status (p_pc_node_id IN NUMBER)
    IS
        select header.status
        from ahl_pc_headers_b header, ahl_pc_nodes_b node
        where header.pc_header_id = node.pc_header_id and
              node.pc_node_id = p_pc_node_id;

    CURSOR check_draft_version_exists (p_pc_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_headers_b header, ahl_pc_nodes_b node
        where header.pc_header_id = node.pc_header_id and
              nvl(node.link_to_node_id,node.pc_node_id) = p_pc_node_id and
              header.status in ('DRAFT', 'APPROVAL_REJECTED');

    BEGIN

        -- Standard start of API savepoint
        SAVEPOINT PROCESS_DOCUMENT_PVT;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.Initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.ENABLE_DEBUG;
        END IF;

        -- API BODY here...
        IF (p_x_assos_tbl.COUNT > 0)
        THEN
            FOR i in p_x_assos_tbl.FIRST..p_x_assos_tbl.LAST
            LOOP
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT for Association ID=' || p_x_assos_tbl(i).DOC_TITLE_ASSO_ID);
                    AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT for Node ID=' || p_x_assos_tbl(i).ASO_OBJECT_ID);
                    AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT for Document No=' || p_x_assos_tbl(i).DOCUMENT_NO);
                    AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT for Revision No='||p_x_assos_tbl(i).REVISION_NO);
                    AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT for Object Type='||p_x_assos_tbl(i).ASO_OBJECT_TYPE_CODE);
                        END IF;

-- Hardcode object type to PC

                p_x_assos_tbl(i).ASO_OBJECT_TYPE_CODE := 'PC';

                -- If revision not chosen, throw error
                IF (p_x_assos_tbl(i).REVISION_NO IS NULL)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_DOC_NO_REV');
                    FND_MESSAGE.Set_Token('DOC',p_x_assos_tbl(i).DOCUMENT_NO);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Check PC status for document association
                OPEN get_pc_header_status (p_x_assos_tbl(i).ASO_OBJECT_ID);
                FETCH get_pc_header_status INTO l_status;
                CLOSE get_pc_header_status;
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT for Status='||l_status);
                END IF;

                -- If PC is pending for approval, throw error
                IF (l_status = 'APPROVAL_PENDING')
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_STATUS_COMPLETE');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                -- If PC is in complete status, there are 2 cases...
                -- 1. If it has a DRAFT version, allow document association
                -- 2. If it has no DRAFT version, throw error
		-- FP #8410484
                --ELSIF (l_status = 'COMPLETE')
                --THEN

                    --OPEN check_draft_version_exists (p_x_assos_tbl(i).ASO_OBJECT_ID);
                    --FETCH check_draft_version_exists INTO l_dummy;
                    -- If complete PC has no DRAFT version, throw error
                    --IF (check_draft_version_exists%NOTFOUND)
                    --THEN

                       -- CLOSE check_draft_version_exists;
                       -- FND_MESSAGE.Set_Name('AHL','AHL_PC_STATUS_COMPLETE');
                       -- FND_MSG_PUB.ADD;
                       -- RAISE FND_API.G_EXC_ERROR;
                   -- ELSE

                       -- CLOSE check_draft_version_exists;
                   -- END IF;
                END IF;

                -- Check whether PC node exists, if yes, force change status to DRAFT for APPROVAL_REJECTED status
                OPEN check_node_exists (p_x_assos_tbl(i).ASO_OBJECT_ID);
                FETCH check_node_exists INTO l_dummy;
                IF (check_node_exists%FOUND)
                THEN
                    CLOSE check_node_exists;
		    --FP #8410484
		    IF(l_status = 'APPROVAL_REJECTED') THEN
			SET_PC_HEADER_STATUS(p_x_assos_tbl(i).ASO_OBJECT_ID);
		    END IF;
                ELSE
                    CLOSE check_node_exists;
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_NOT_FOUND');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END LOOP;
        END IF;

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug('PCA -- PVT -- PROCESS_DOCUMENT Calling AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION');
        END IF;

        AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION
        (
            p_api_version           => l_api_version,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit        => FND_API.G_FALSE,
            p_validate_only     => FND_API.G_TRUE,
            p_validation_level  => p_validation_level,
            p_x_association_tbl => p_x_assos_tbl,
            p_module_type       => p_module_type,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                        p_data  => x_msg_data,
                            p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to PROCESS_DOCUMENT_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to PROCESS_DOCUMENT_PVT;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to PROCESS_DOCUMENT_PVT;
            IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'PROCESS_DOCUMENT',
                             p_error_text     => SUBSTR(SQLERRM,1,240) );
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                           p_data  => x_msg_data,
                           p_encoded => fnd_api.g_false );

    END PROCESS_DOCUMENT;

    --------------------------
    -- SET_PC_HEADER_STATUS --
    --------------------------
    PROCEDURE SET_PC_HEADER_STATUS (p_pc_node_id IN NUMBER)
    IS

    CURSOR get_pc_header_status (p_pc_node_id IN NUMBER)
    IS
        select head.status
        from ahl_pc_headers_b head, ahl_pc_nodes_b node
        where head.pc_header_id = node.pc_header_id and
              node.pc_node_id = p_pc_node_id;

    l_pc_status     VARCHAR2(30) := 'DRAFT';

    BEGIN

        OPEN get_pc_header_status (p_pc_node_id);
        FETCH get_pc_header_status INTO l_pc_status;
        CLOSE get_pc_header_status;

        IF (l_pc_status = 'APPROVAL_REJECTED')
        THEN
            -- Force updation of PC status; No check of header version number sanity
            update ahl_pc_headers_b
            set status = 'DRAFT'
            where pc_header_id = (
                select pc_header_id
                from ahl_pc_nodes_b
                where pc_node_id = p_pc_node_id );
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            NULL;

    END SET_PC_HEADER_STATUS;

    ---------------------------
    -- VALIDATION PROCEDURES --
    ---------------------------
    PROCEDURE VALIDATE_ASSOCIATION ( p_x_assos_rec IN AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC )
    IS

    l_status            VARCHAR2(30);
    l_unit_item_id          NUMBER;
    l_node_id           NUMBER;
    l_assos_id          NUMBER;
    l_object_version_number     NUMBER;
    l_is_pc_primary         VARCHAR2(1) :='N';
    l_dummy             VARCHAR2(1);

    CURSOR get_node_object_version (p_pc_assos_id IN NUMBER)
    IS
        select object_version_number
        from ahl_pc_associations
        where pc_association_id = p_pc_assos_id;

    CURSOR check_id_exists_in_PC (p_pc_assos_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_associations
        where pc_association_id = p_pc_assos_id;

    CURSOR is_pc_primary (p_pc_node_id IN NUMBER)
    IS
        select head.primary_flag
        from ahl_pc_headers_b head, ahl_pc_nodes_b node
        where node.pc_node_id = p_pc_node_id and
              node.pc_header_id = head.pc_header_id;

    CURSOR check_unit_item_exists (p_unit_item_id IN NUMBER, p_pc_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_associations ahass, ahl_pc_nodes_b node, ahl_pc_headers_b header
        where ahass.unit_item_id = p_unit_item_id and
              ahass.pc_node_id = node.pc_node_id and
              node.pc_header_id = header.pc_header_id and
              header.pc_header_id = (
            select pc_header_id
            from ahl_pc_nodes_b
            where pc_node_id = p_pc_node_id );

    CURSOR check_unit_item_at_same_level (p_unit_item_id IN NUMBER, p_pc_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_associations ahass, ahl_pc_nodes_b node
        where ahass.unit_item_id = p_unit_item_id and
              ahass.pc_node_id = node.pc_node_id and
              node.pc_node_id = p_pc_node_id;

    CURSOR check_unit_exists (p_unit_item_id IN NUMBER)
    IS
        select 'X'
        from ahl_unit_config_headers
        where unit_config_header_id = p_unit_item_id;

    CURSOR check_item_exists (p_unit_item_id IN NUMBER)
    IS
        select 'X'
        from mtl_system_items_b
        where inventory_item_id = p_unit_item_id;

    -- Bug 4913773
    -- Modified References to Base tables in Cursor get_pc_header_status below
    -- ahl_pc_headers_vl to ahl_pc_headers_b
    -- ahl_pc_nodes_vl to ahl_pc_nodes_b
    CURSOR get_pc_header_status (p_pc_node_id IN NUMBER)
    IS
        select header.status
        from ahl_pc_headers_b header, ahl_pc_nodes_b node
        where header.pc_header_id = node.pc_header_id and
              node.pc_node_id = p_pc_node_id;

    CURSOR check_child_node_exists (p_pc_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_nodes_b
        where parent_node_id = p_pc_node_id;

    CURSOR check_unit_valid (p_unit_item_id IN NUMBER)
    IS
        select 'X'
        from ahl_unit_config_headers
        where unit_config_header_id = p_unit_item_id and
              trunc(sysdate) between nvl(trunc(active_start_date), trunc(sysdate)) and nvl(trunc(active_end_date), trunc(sysdate)) AND
    	      AHL_UTIL_UC_PKG.get_uc_status_code(p_unit_item_id) in ('COMPLETE', 'INCOMPLETE');
     --  bug  8970548 fix     unit_config_status_code in ('COMPLETE', 'INCOMPLETE');

    CURSOR check_item_valid (p_unit_item_id IN NUMBER)
    IS
        select 'X'
        from mtl_system_items_b
        where inventory_item_id = p_unit_item_id and
              trunc(sysdate) between nvl(trunc(start_date_active), trunc(sysdate)) and nvl(trunc(end_date_active), trunc(sysdate)) and
              inventory_item_status_code not in ('Obsolete','Inactive');

    -- ACL :: R12 Changes
    CURSOR check_unit_quarantine (p_unit_item_id IN NUMBER)
    IS
        select 'X'
        from ahl_unit_config_headers
        where unit_config_header_id = p_unit_item_id AND
	AHL_UTIL_UC_PKG.get_uc_status_code(p_unit_item_id) IN  ('QUARANTINE', 'DEACTIVATE_QUARANTINE');
       --  bug 8970548 fix       unit_config_status_code in ('QUARANTINE', 'DEACTIVATE_QUARANTINE');

    BEGIN
        -- Check for object_version_number sanity
        IF (p_x_assos_rec.pc_association_id IS NOT NULL)
        THEN
            OPEN get_node_object_version (p_x_assos_rec.pc_association_id);
            FETCH get_node_object_version INTO l_object_version_number;
            CLOSE get_node_object_version;
            IF (l_object_version_number <> p_x_assos_rec.object_version_number)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- ACL :: R12 Changes
        -- Unit cannot be attached or detached from a PC if the Unit is in Quarantine or Deactivate Quarantine Status.
        IF (p_x_assos_rec.association_type_flag = G_UNIT)
        THEN
            OPEN check_unit_quarantine (p_x_assos_rec.unit_item_id);
            FETCH check_unit_quarantine INTO l_dummy;
            IF (check_unit_quarantine%FOUND)
            THEN
                FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
                FND_MSG_PUB.add;
                CLOSE check_unit_quarantine;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_unit_quarantine;
        END If;

        IF (p_x_assos_rec.operation_flag <> G_DML_ASSIGN)
        THEN
            OPEN get_pc_header_status (p_x_assos_rec.pc_node_id);
            FETCH get_pc_header_status INTO l_status;
            CLOSE get_pc_header_status;
            IF (l_status <> 'DRAFT' and l_status <> 'APPROVAL_REJECTED')
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_STATUS_COMPLETE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- Check if attached unit/item exists in the PC tree for detach operations
        -- Check if unit/item exists in UCs and Items for attach operations
        IF (p_x_assos_rec.operation_flag <> G_DML_CREATE AND p_x_assos_rec.operation_flag <> G_DML_ASSIGN)
        THEN
            OPEN check_id_exists_in_PC (p_x_assos_rec.pc_association_id);
            FETCH check_id_exists_in_PC INTO l_dummy;
            IF (check_id_exists_in_PC%NOTFOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_ASSOS_NOT_FOUND');
                FND_MSG_PUB.ADD;
                CLOSE check_id_exists_in_PC;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_id_exists_in_PC;
        ELSE
            OPEN is_pc_primary(p_x_assos_rec.pc_node_id);
            FETCH is_pc_primary INTO l_is_pc_primary;
            CLOSE is_pc_primary;
            IF (l_is_pc_primary = 'Y')
            THEN
                OPEN check_unit_item_exists (p_x_assos_rec.unit_item_id, p_x_assos_rec.pc_node_id);
                FETCH check_unit_item_exists INTO l_dummy;
                IF (check_unit_item_exists%FOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_ITEM_EXISTS');
                    FND_MESSAGE.Set_Token('UNIT_NAME',p_x_assos_rec.unit_item_name);
                    FND_MSG_PUB.ADD;
                    CLOSE check_unit_item_exists;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_unit_item_exists;
            ELSE
                OPEN check_unit_item_at_same_level (p_x_assos_rec.unit_item_id, p_x_assos_rec.pc_node_id);
                FETCH check_unit_item_at_same_level INTO l_dummy;
                IF (check_unit_item_at_same_level%FOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_PART_EXISTS_AT_LVL'); -- SATHAPLI BUG:5576835:Changed to correct message code
                    FND_MESSAGE.Set_Token('UNIT_NAME',p_x_assos_rec.unit_item_name);
                    FND_MSG_PUB.ADD;
                    CLOSE check_unit_item_at_same_level;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_unit_item_at_same_level;
            END IF;

            IF (p_x_assos_rec.association_type_flag = G_UNIT)
            THEN
                OPEN check_unit_exists (p_x_assos_rec.unit_item_id);
                FETCH check_unit_exists INTO l_dummy;
                IF (check_unit_exists%NOTFOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_NOT_FOUND');
                    FND_MSG_PUB.ADD;
                    CLOSE check_unit_exists;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_unit_exists;

                OPEN check_unit_valid (p_x_assos_rec.unit_item_id);
                FETCH check_unit_valid INTO l_dummy;
                IF (check_unit_valid%NOTFOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_NOT_VALID');
                    FND_MESSAGE.Set_Token('UNIT_NAME',p_x_assos_rec.unit_item_name);
                    FND_MSG_PUB.ADD;
                    CLOSE check_unit_valid;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_unit_valid;
            ELSIF (p_x_assos_rec.association_type_flag = G_PART)
            THEN
                OPEN check_item_exists (p_x_assos_rec.unit_item_id);
                FETCH check_item_exists INTO l_dummy;
                IF (check_item_exists%NOTFOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_ITEM_NOT_FOUND');
                    FND_MSG_PUB.ADD;
                    CLOSE check_item_exists;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_item_exists;

                OPEN check_item_valid (p_x_assos_rec.unit_item_id);
                FETCH check_item_valid INTO l_dummy;
                IF (check_item_valid%NOTFOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_ITEM_NOT_VALID');
                    FND_MESSAGE.Set_Token('ITEM_NAME',p_x_assos_rec.unit_item_name);
                    FND_MSG_PUB.ADD;
                    CLOSE check_item_valid;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_item_valid;
            END IF;
        END IF;

        -- Check for leaf node
        IF (p_x_assos_rec.operation_flag <> G_DML_DELETE)
        THEN
            OPEN check_child_node_exists (p_x_assos_rec.pc_node_id);
            FETCH check_child_node_exists INTO l_dummy;
            IF (check_child_node_exists%FOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_ATTACH_LEAF_ONLY');
                FND_MSG_PUB.ADD;
                CLOSE check_child_node_exists;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_child_node_exists;
        END IF;

    END VALIDATE_ASSOCIATION;

END AHL_PC_ASSOCIATION_PVT;

/
