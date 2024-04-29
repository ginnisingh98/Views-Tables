--------------------------------------------------------
--  DDL for Package Body AHL_PC_NODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_NODE_PVT" AS
/* $Header: AHLVPCNB.pls 120.9 2006/09/14 12:43:00 priyan noship $ */

    TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


    -- FND Logging Constants
	G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
	G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
	G_DEBUG_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

    ------------------------
    -- GET_LINKED_NODE_ID --
    ------------------------
    FUNCTION GET_LINKED_NODE_ID (p_pc_node_id IN NUMBER)
    RETURN NUMBER;

    --------------------------
    -- SET_PC_HEADER_STATUS --
    --------------------------
    PROCEDURE SET_PC_HEADER_STATUS (p_pc_header_id IN NUMBER);


    ---------------------------
    -- VALIDATION PROCEDURES --
    ---------------------------
    PROCEDURE VALIDATE_NODE ( p_node_rec IN AHL_PC_NODE_PUB.PC_NODE_REC );

    -----------------
    -- CREATE_NODE --
    -----------------
    PROCEDURE CREATE_NODE (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_node_rec          IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_REC,
        X_return_status       OUT    NOCOPY       VARCHAR2,
        X_msg_count           OUT    NOCOPY       NUMBER,
        X_msg_data            OUT    NOCOPY       VARCHAR2
    )
    IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'CREATE_NODE';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);
    l_row_id            ROWID;
    l_node_id           NUMBER;
    l_pc_node_id            NUMBER;
    l_link_id                   NUMBER;
    l_sysdate           DATE        := SYSDATE;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT CREATE_NODE_PVT;

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
        X_return_status := FND_API.G_RET_STS_SUCCESS;


        IF (p_x_node_rec.operation_flag = G_DML_CREATE)
        THEN
            VALIDATE_NODE (p_x_node_rec);
        END IF;

        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF X_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

            IF p_x_node_rec.OPERATION_FLAG = G_DML_LINK
            THEN
            l_link_id := p_x_node_rec.LINK_TO_NODE_ID;
            END IF;

        SELECT AHL_PC_NODES_B_S.NEXTVAL INTO l_pc_node_id FROM DUAL;

        AHL_PC_NODES_PKG.INSERT_ROW
        (
              X_ROWID         =>    l_row_id,
              X_PC_NODE_ID        =>    l_pc_node_id,
              X_PC_HEADER_ID      =>    p_x_node_rec.pc_header_id,
              X_NAME          =>    p_x_node_rec.name,
              X_DESCRIPTION       =>    p_x_node_rec.description,
              X_PARENT_NODE_ID    =>    nvl(p_x_node_rec.parent_node_id, 0),
              X_CHILD_COUNT       =>    0,
              X_OPERATION_STATUS_FLAG =>    p_x_node_rec.operation_status_flag,
              X_DRAFT_FLAG        =>    p_x_node_rec.draft_flag,
              X_LINK_TO_NODE_ID       =>    nvl(l_link_id, 0),
              X_OBJECT_VERSION_NUMBER =>    1,
              X_SECURITY_GROUP_ID     =>    null,
              X_ATTRIBUTE_CATEGORY    =>    p_x_node_rec.attribute_category,
              X_ATTRIBUTE1        =>    p_x_node_rec.attribute1,
              X_ATTRIBUTE2        =>    p_x_node_rec.attribute2,
              X_ATTRIBUTE3        =>    p_x_node_rec.attribute3,
              X_ATTRIBUTE4        =>    p_x_node_rec.attribute4,
              X_ATTRIBUTE5        =>    p_x_node_rec.attribute5,
              X_ATTRIBUTE6        =>    p_x_node_rec.attribute6,
              X_ATTRIBUTE7        =>    p_x_node_rec.attribute7,
              X_ATTRIBUTE8        =>    p_x_node_rec.attribute8,
              X_ATTRIBUTE9        =>    p_x_node_rec.attribute9,
              X_ATTRIBUTE10       =>    p_x_node_rec.attribute10,
              X_ATTRIBUTE11       =>    p_x_node_rec.attribute11,
              X_ATTRIBUTE12       =>    p_x_node_rec.attribute12,
              X_ATTRIBUTE13       =>    p_x_node_rec.attribute13,
              X_ATTRIBUTE14       =>    p_x_node_rec.attribute14,
              X_ATTRIBUTE15       =>    p_x_node_rec.attribute15,
              X_CREATION_DATE     =>    l_sysdate,
              X_CREATED_BY        =>    g_user_id,
              X_LAST_UPDATE_DATE      =>    l_sysdate,
              X_LAST_UPDATED_BY       =>    g_user_id,
              X_LAST_UPDATE_LOGIN     =>    g_user_id
        );

        p_x_node_rec.PC_NODE_ID := l_pc_node_id ;


            IF  (p_x_node_rec.pc_node_id IS NOT NULL)
        THEN
            UPDATE ahl_pc_nodes_b
            SET child_count = NVL(child_count,0) + 1
            WHERE pc_node_id = p_x_node_rec.parent_node_id;
        END IF;

        SET_PC_HEADER_STATUS (p_x_node_rec.pc_header_id);

            -- Standard check for p_commit
            IF FND_API.To_Boolean (p_commit)
            THEN
                COMMIT WORK;
            END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                            p_data  => X_msg_data,
                            p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to CREATE_NODE_PVT;
            FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to CREATE_NODE_PVT;
            FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Rollback to CREATE_NODE_PVT;
                IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                    fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'CREATE_NODE',
                                 p_error_text     => SUBSTR(SQLERRM,1,240) );
                END IF;
                FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

    END CREATE_NODE;

    ------------------
    -- UPDATE_NODE --
    ------------------
    PROCEDURE UPDATE_NODE (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_node_rec          IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_REC,
        X_return_status       OUT    NOCOPY       VARCHAR2,
        X_msg_count           OUT    NOCOPY       NUMBER,
        X_msg_data            OUT    NOCOPY       VARCHAR2
    ) IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'UPDATE_NODE';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);
    l_pc_status         VARCHAR2(30);
    l_object_version_number     NUMBER;
    l_link_id           NUMBER;
    l_sysdate           DATE        := SYSDATE;

    CURSOR pc_node_csr(p_pc_node_id IN NUMBER)
    IS
        SELECT node.OBJECT_VERSION_NUMBER, head.STATUS
            FROM AHL_PC_NODES_B node, AHL_PC_HEADERS_B head
            WHERE   head.PC_HEADER_ID = node.PC_HEADER_ID and
                node.PC_NODE_ID = p_pc_node_id and
                node.DRAFT_FLAG = 'N';

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT UPDATE_NODE_PVT;

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
        X_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_x_node_rec.operation_flag = G_DML_UPDATE)
        THEN
            VALIDATE_NODE (p_x_node_rec);
        END IF;

        -- Check Error Message stack.
        X_msg_count := FND_MSG_PUB.count_msg;
        IF X_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_x_node_rec.OPERATION_FLAG <> G_DML_LINK
        THEN

            OPEN pc_node_csr(p_x_node_rec.pc_node_id );
            FETCH pc_node_csr INTO l_object_version_number, l_pc_status;

            IF (pc_node_csr%NOTFOUND)
            THEN
                CLOSE pc_node_csr;
                FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_NOT_FOUND');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE pc_node_csr;

                END IF;

        IF (l_object_version_number <> p_x_node_rec.object_version_number)
        THEN
            FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
        END IF;

        IF (l_pc_status <> 'DRAFT' and l_pc_status <> 'APPROVAL_REJECTED')
        THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_STATUS_COMPLETE');
                FND_MSG_PUB.ADD;
        END IF;

        IF  (p_x_node_rec.DRAFT_FLAG = 'Y')
        THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_DRAFT_PC_EXISTS');
                FND_MSG_PUB.ADD;
        END IF;

        -- Check Error Message stack.
        X_msg_count := FND_MSG_PUB.count_msg;
        IF X_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Retrieve link id for this node; this is non-updatable field for this package
        SELECT LINK_TO_NODE_ID
        INTO l_link_id
        FROM AHL_PC_NODES_B
        WHERE PC_NODE_ID = p_x_node_rec.pc_node_id;

        AHL_PC_NODES_PKG.UPDATE_ROW
        (
            X_PC_NODE_ID            => p_x_node_rec.pc_node_id,
            X_PC_HEADER_ID          => p_x_node_rec.pc_header_id,
            X_NAME              => p_x_node_rec.name,
            X_DESCRIPTION           => p_x_node_rec.description,
            X_PARENT_NODE_ID        => p_x_node_rec.parent_node_id,
            X_CHILD_COUNT           => p_x_node_rec.child_count,
            X_OPERATION_STATUS_FLAG     => p_x_node_rec.operation_status_flag,
            X_DRAFT_FLAG            => p_x_node_rec.draft_flag,
            X_LINK_TO_NODE_ID       => l_link_id,
            X_SECURITY_GROUP_ID     => null,
            X_OBJECT_VERSION_NUMBER     => p_x_node_rec.object_version_number + 1,
            X_ATTRIBUTE_CATEGORY        => p_x_node_rec.attribute_category,
            X_ATTRIBUTE1            => p_x_node_rec.attribute1,
            X_ATTRIBUTE2            => p_x_node_rec.attribute2,
            X_ATTRIBUTE3            => p_x_node_rec.attribute3,
            X_ATTRIBUTE4            => p_x_node_rec.attribute4,
            X_ATTRIBUTE5            => p_x_node_rec.attribute5,
            X_ATTRIBUTE6            => p_x_node_rec.attribute6,
            X_ATTRIBUTE7            => p_x_node_rec.attribute7,
            X_ATTRIBUTE8            => p_x_node_rec.attribute8,
            X_ATTRIBUTE9            => p_x_node_rec.attribute9,
            X_ATTRIBUTE10           => p_x_node_rec.attribute10,
            X_ATTRIBUTE11           => p_x_node_rec.attribute11,
            X_ATTRIBUTE12           => p_x_node_rec.attribute12,
            X_ATTRIBUTE13           => p_x_node_rec.attribute13,
            X_ATTRIBUTE14           => p_x_node_rec.attribute14,
            X_ATTRIBUTE15           => p_x_node_rec.attribute15,
            X_LAST_UPDATE_DATE      => l_sysdate,
            X_LAST_UPDATED_BY       => g_user_id,
            X_LAST_UPDATE_LOGIN     => g_user_id
        );


        SET_PC_HEADER_STATUS (p_x_node_rec.pc_header_id);

            -- Standard check for p_commit
            IF FND_API.To_Boolean (p_commit)
            THEN
                COMMIT WORK;
            END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                            p_data  => X_msg_data,
                            p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to UPDATE_NODE_PVT;
            FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to UPDATE_NODE_PVT;
            FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Rollback to UPDATE_NODE_PVT;
                IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                    fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'UPDATE_NODE',
                                 p_error_text     => SUBSTR(SQLERRM,1,240) );
                END IF;
                FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

    END UPDATE_NODE;

    ------------------
    -- DELETE_NODES --
    ------------------
    PROCEDURE DELETE_NODES (
        p_api_version         IN            NUMBER,
        p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
        p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
        p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_x_node_rec          IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_REC,
        X_return_status       OUT    NOCOPY       VARCHAR2,
        X_msg_count           OUT    NOCOPY       NUMBER,
        X_msg_data            OUT    NOCOPY       VARCHAR2
    ) IS

    l_api_name  CONSTANT    VARCHAR2(30)    := 'DELETE_NODES';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);
    l_node_id           NUMBER;
    l_linked_node_id        NUMBER;

    l_exist                         VARCHAR2(1);

    l_debug_module  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    -- Bug 5130623
    -- Added default values below.
    l_ump_node_attached     VARCHAR2(1) := FND_API.G_FALSE;
    l_ump_unit_attached     VARCHAR2(1) := FND_API.G_FALSE;
    l_ump_part_attached     VARCHAR2(1) := FND_API.G_FALSE;
    l_fmp_attached          VARCHAR2(1) := FND_API.G_FALSE;
    l_open_nr           VARCHAR2(1) := FND_API.G_FALSE;
    l_mel_cdl_attached  VARCHAR2(1) := FND_API.G_FALSE;

    l_node_tbl          T_ID_TBL;
    l_assos_tbl         T_ID_TBL;
    l_docs_tbl          T_ID_TBL;
    l_is_pc_primary         VARCHAR2(1) := 'N';
    l_assos_type            VARCHAR2(1) := G_UNIT;

    CURSOR get_pc_details (p_pc_node_id IN NUMBER)
    IS
        SELECT HEAD.PRIMARY_FLAG, HEAD.ASSOCIATION_TYPE_FLAG
        FROM AHL_PC_HEADERS_B HEAD, AHL_PC_NODES_B NODE
        WHERE NODE.PC_HEADER_ID = HEAD.PC_HEADER_ID AND
              NODE.PC_NODE_ID = p_pc_node_id;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT DELETE_NODES_PVT;

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
        X_return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_NODE (p_x_node_rec);

        -- Check Error Message stack.
        X_msg_count := FND_MSG_PUB.count_msg;
        IF X_msg_count > 0 THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- API Body here...
        IF (p_x_node_rec.pc_node_id IS NULL)
        THEN
            BEGIN

            SELECT pc_node_id INTO l_node_id
            FROM ahl_pc_nodes_b
            WHERE pc_header_id = p_x_node_rec.pc_header_id and
                  parent_node_id = 0;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_node_id := 0;
                WHEN OTHERS THEN
                    l_node_id := 0;
            END;

        ELSE
            l_node_id := p_x_node_rec.pc_node_id;
        END IF;

        -- Hook to check primary PC... If primary, then only check for UMP associations
        -- Also retrieve associations_type, to check UMP associations to PC unit/part associations
        OPEN get_pc_details (l_node_id);
        FETCH get_pc_details INTO l_is_pc_primary, l_assos_type;
        IF (get_pc_details%NOTFOUND)
        THEN
            l_is_pc_primary := 'N';
            l_assos_type := G_UNIT;
        END IF;
        CLOSE get_pc_details;

        SELECT pc_node_id
        BULK COLLECT
        INTO l_node_tbl
        FROM ahl_pc_nodes_b
        WHERE pc_header_id = p_x_node_rec.pc_header_id
        CONNECT BY parent_node_id = PRIOR pc_node_id
        START WITH pc_node_id = l_node_id
        ORDER BY pc_node_id DESC;

        SELECT pc_association_id
        BULK COLLECT INTO l_assos_tbl
        FROM ahl_pc_associations ahass
        WHERE pc_node_id IN
        (
            SELECT pc_node_id
            FROM ahl_pc_nodes_b
            WHERE pc_header_id = p_x_node_rec.pc_header_id
            CONNECT BY parent_node_id = PRIOR pc_node_id
            START WITH pc_node_id = l_node_id
        );

        l_linked_node_id := GET_LINKED_NODE_ID(l_node_id);


        IF (l_linked_node_id <> 0)
        THEN
            BEGIN


                -- Checking if the linked Node has any MR Effectivities defined
                SELECT distinct 'X'
                INTO l_exist
                FROM ahl_mr_headers_app_v mrh, ahl_mr_effectivities mre
                WHERE
                    -- R12 [priyan MEL/CDL]
                    -- to prevent foreign key violations checking for any MR effectivity associated (instead of just active ones)
                    -- trunc(sysdate) < trunc(nvl(mrh.effective_to, sysdate+1)) and
                    mrh.mr_header_id = mre.mr_header_id and
                    mre.pc_node_id IN
                    (
                        SELECT pc_node_id
                        FROM ahl_pc_nodes_b
                        CONNECT BY parent_node_id = PRIOR pc_node_id
                        START WITH pc_node_id = l_linked_node_id
                    );


                l_fmp_attached := FND_API.G_TRUE;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_fmp_attached := FND_API.G_FALSE;
                WHEN OTHERS THEN
                    l_fmp_attached := FND_API.G_FALSE;
            END;

            IF (l_is_pc_primary = 'Y')
            THEN
                -- R12 [priyan MEL/CDL]
                -- Checking if the linked node has any MEL/CDLs associated
                BEGIN

                    SELECT distinct 'X'
                    INTO l_exist
                    FROM ahl_mel_cdl_headers
                    WHERE pc_node_id IN
                    (
                        SELECT pc_node_id
                        FROM ahl_pc_nodes_b
                        CONNECT BY parent_node_id = PRIOR pc_node_id
                        START WITH pc_node_id = l_linked_node_id
                    );

                    l_mel_cdl_attached := FND_API.G_TRUE;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_mel_cdl_attached := FND_API.G_FALSE;
                    WHEN OTHERS THEN
                        l_mel_cdl_attached := FND_API.G_FALSE;
                END;

                -- Checking if the linked Node has any open NRs

		l_open_nr := FND_API.G_FALSE;

                AHL_UMP_NONROUTINES_PVT.Check_Open_NRs
                (
                    x_return_status => l_return_status,
                    p_pc_node_id => l_linked_node_id
                );
                -- Need to verify whether to pass all PC nodes within the tree, etc or not

	        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                    l_open_nr := FND_API.G_TRUE;
                END IF;
                -- R12 [priyan MEL/CDL]

                -- Checking if the linked node has any utilization forecasts, etc
                BEGIN

                    SELECT distinct 'X'
                    INTO l_exist
                    FROM ahl_utilization_forecast_v
                    WHERE pc_node_id IN
                    (
                        SELECT pc_node_id
                        FROM ahl_pc_nodes_b
                        CONNECT BY parent_node_id = PRIOR pc_node_id
                        START WITH pc_node_id = l_linked_node_id
                    );

                    l_ump_node_attached := FND_API.G_TRUE;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_ump_node_attached := FND_API.G_FALSE;
                    WHEN OTHERS THEN
                        l_ump_node_attached := FND_API.G_FALSE;
                END;

                -- Checking if the units/items attached within the tree of the linked node has any utilization forecasts, etc
                IF (l_assos_type = G_UNIT)
                THEN
                    BEGIN

                        SELECT distinct 'X'
                        INTO   l_exist
                        FROM ahl_utilization_forecast_v uf, ahl_pc_associations assos, ahl_pc_nodes_b node
                        WHERE   uf.unit_config_header_id = assos.unit_item_id and
                            assos.pc_node_id = node.pc_node_id and
                            node.pc_node_id IN (
                                SELECT pc_node_id
                                FROM ahl_pc_nodes_b
                                CONNECT BY parent_node_id = PRIOR pc_node_id
                                START WITH pc_node_id = l_linked_node_id
                                );

                        l_ump_unit_attached := FND_API.G_TRUE;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_ump_unit_attached := FND_API.G_FALSE;
                        WHEN OTHERS THEN
                            l_ump_unit_attached := FND_API.G_FALSE;
                    END;

                ELSE
                    BEGIN

                        SELECT distinct 'X'
                        INTO   l_exist
                        FROM ahl_utilization_forecast_v uf, ahl_pc_associations assos, ahl_pc_nodes_b node
                        WHERE   uf.inventory_item_id = assos.unit_item_id and
                            uf.inventory_org_id = assos.inventory_org_id and
                            assos.pc_node_id = node.pc_node_id and
                            node.pc_node_id IN (
                                SELECT pc_node_id
                                FROM ahl_pc_nodes_b
                                CONNECT BY parent_node_id = PRIOR pc_node_id
                                START WITH pc_node_id = l_linked_node_id
                                );

                        l_ump_part_attached := FND_API.G_TRUE;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_ump_part_attached := FND_API.G_FALSE;
                        WHEN OTHERS THEN
                            l_ump_part_attached := FND_API.G_FALSE;
                    END;

                END IF;

            END IF;

        END IF;

	IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
	THEN
		fnd_log.string
		(
		    G_DEBUG_STMT,
		    l_debug_module,
		    'l_fmp_attached ['||l_fmp_attached||'],l_ump_node_attached ['||l_ump_node_attached||']'
		);
	END IF;

	IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
	THEN
		fnd_log.string
		(
		    G_DEBUG_STMT,
		    l_debug_module,
		    'l_ump_unit_attached['||l_ump_unit_attached||'],l_ump_part_attached['||l_ump_part_attached||']'
		);
	END IF;

	IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)
	THEN
		fnd_log.string
		(
		    G_DEBUG_STMT,
		    l_debug_module,
		    'l_open_nr ['||l_open_nr||'],l_mel_cdl_attached['||l_mel_cdl_attached||']'
		);
	END IF;

        -- R12 [priyan MEL/CDL]
        IF (
            l_fmp_attached = FND_API.G_FALSE AND
            l_ump_node_attached = FND_API.G_FALSE AND
            l_ump_unit_attached = FND_API.G_FALSE AND
            l_ump_part_attached = FND_API.G_FALSE AND
            l_open_nr = FND_API.G_FALSE AND
            l_mel_cdl_attached = FND_API.G_FALSE
        )
        THEN

            If(l_assos_tbl.COUNT > 0)
            THEN

                FOR i IN l_assos_tbl.FIRST..l_assos_tbl.LAST
                LOOP
                    DELETE
                    FROM ahl_pc_associations
                    WHERE pc_association_id = l_assos_tbl(i);
                END LOOP;
            END IF;

            IF (l_node_tbl.COUNT > 0)
            THEN

                FOR j IN l_node_tbl.FIRST..l_node_tbl.LAST
                LOOP
                    -- Knocking off doc associations from PC nodes...
                    DELETE
                    FROM AHL_DOC_TITLE_ASSOS_TL
                    WHERE   DOC_TITLE_ASSO_ID IN (
                        SELECT DOC_TITLE_ASSO_ID
                            FROM   AHL_DOC_TITLE_ASSOS_B
                            WHERE   aso_object_type_code = 'PC' and
                                aso_object_id = l_node_tbl(j)
                    );

                    DELETE
                    FROM AHL_DOC_TITLE_ASSOS_B
                    WHERE   aso_object_type_code = 'PC' and
                        aso_object_id = l_node_tbl(j);

                    -- Knocking off nodes...
                    AHL_PC_NODES_PKG.DELETE_ROW(l_node_tbl(j));
                END LOOP;
            END IF;

            -- Check Error Message stack.
            X_msg_count := FND_MSG_PUB.count_msg;
            IF X_msg_count > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF ((l_node_tbl.COUNT > 0) AND (p_x_node_rec.pc_node_id IS NOT NULL))
            THEN
                UPDATE ahl_pc_nodes_b
                SET child_count = NVL(child_count,1) - 1
                WHERE pc_node_id = p_x_node_rec.parent_node_id;
            END IF;

            SET_PC_HEADER_STATUS (p_x_node_rec.pc_header_id);

        -- R12 [priyan MEL/CDL]
        ELSIF (l_open_nr <> FND_API.G_FALSE)
        THEN
	    -- Priyan :
	    -- Fix for Bug #5514157
	    -- When the PC header is being deleted and if open NRs exists,  add an error
	    -- to the message stack which will be later caught by the calling procedure (AHLVPCHB.pls-> Delete_pc_header)

            IF (p_x_node_rec.pc_node_id IS NOT NULL)
	    THEN

		    SELECT name
		    INTO p_x_node_rec.name
		    FROM ahl_pc_nodes_b
		    WHERE pc_node_id = p_x_node_rec.pc_node_id;

		    FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_DEL_OPEN_NR');
		    FND_MESSAGE.Set_Token('PCN',p_x_node_rec.name);
		    FND_MSG_PUB.ADD;
	    ELSE
		    --There exists open Non-routines for units associated to the corresponding complete PC,
		    -- hence cannot delete the draft version.
		    FND_MESSAGE.Set_Name('AHL','AHL_PC_HEADER_DEL_OPEN_NR');
		    FND_MSG_PUB.ADD;
		    RAISE FND_API.G_EXC_ERROR;
	    END IF;
        ELSIF (l_mel_cdl_attached <> FND_API.G_FALSE)
        THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_DEL_MELCDL_ASSOS');
            FND_MSG_PUB.ADD;
        -- R12 [priyan MEL/CDL]
        ELSIF (l_fmp_attached <> FND_API.G_FALSE)
        THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_DEL_FMP_ASSOS');
            FND_MSG_PUB.ADD;
        -- Bug 5130623
        -- TYPO - Added l_ump_unit_attached check below
        ELSIF (l_ump_node_attached <> FND_API.G_FALSE OR l_ump_part_attached <> FND_API.G_FALSE OR l_ump_unit_attached <> FND_API.G_FALSE)
        THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_DEL_UMP_ASSOS');
            FND_MSG_PUB.ADD;
        -- Bug 5130623
        -- Commented Unconditional Else Clause.
        /*
        ELSE
            FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_DEL_HAS_ASSOS');
            FND_MSG_PUB.ADD;
        */
        END IF;

        -- Check Error Message stack.
        X_msg_count := FND_MSG_PUB.count_msg;
        IF X_msg_count > 0 THEN
	    RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                            p_data  => X_msg_data,
                            p_encoded => fnd_api.g_false );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to DELETE_NODES_PVT;
            FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DELETE_NODES_PVT;
            FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

        WHEN OTHERS THEN
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Rollback to DELETE_NODES_PVT;
                IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                    fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => 'DELETE_NODES',
                                 p_error_text     => SUBSTR(SQLERRM,1,240) );
                END IF;
                FND_MSG_PUB.count_and_get( p_count => X_msg_count,
                               p_data  => X_msg_data,
                               p_encoded => fnd_api.g_false );

    END DELETE_NODES;

    ------------------------
    -- GET_LINKED_NODE_ID --
    ------------------------
    FUNCTION GET_LINKED_NODE_ID (p_pc_node_id IN NUMBER)
    RETURN NUMBER
    IS

    l_linked_node_id    NUMBER  := 0;

    CURSOR get_linked_node_id (p_pc_node_id IN NUMBER)
    IS
        select link_to_node_id
        from ahl_pc_nodes_b
        where pc_node_id = p_pc_node_id;

    BEGIN

        OPEN get_linked_node_id (p_pc_node_id);
        FETCH get_linked_node_id INTO l_linked_node_id;
        IF (get_linked_node_id%NOTFOUND)
        THEN
            CLOSE get_linked_node_id;
            RETURN 0;
        ELSE
            CLOSE get_linked_node_id;
            IF (l_linked_node_id IS NOT NULL)
            THEN
                RETURN l_linked_node_id;
            ELSE
                RETURN 0;
            END IF;
        END IF;

    END GET_LINKED_NODE_ID;

    ---------------------------
    -- VALIDATION PROCEDURES --
    ---------------------------
    PROCEDURE VALIDATE_NODE ( p_node_rec IN AHL_PC_NODE_PUB.PC_NODE_REC )
    IS

    l_status            VARCHAR2(30);
    l_pc_status         VARCHAR2(30);
    l_node_id           NUMBER;
    l_header_id         NUMBER;
    l_object_version_number     NUMBER;
        l_dummy                         VARCHAR2(1);

    CURSOR check_header_id_exists (p_pc_header_id IN NUMBER)
    IS
        select pc_header_id, status
        from ahl_pc_headers_b
        where pc_header_id = p_pc_header_id;

    CURSOR check_id_exists (p_pc_header_id IN NUMBER, p_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_nodes_b
        where pc_node_id = p_node_id and
              pc_header_id = p_pc_header_id;

    CURSOR check_parent_exists (p_pc_header_id IN NUMBER, p_parent_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_nodes_b
        where pc_node_id = p_parent_node_id and
              pc_header_id = p_pc_header_id;

    CURSOR check_root_node_exists (p_pc_header_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_nodes_b
        where pc_header_id = p_pc_header_id and
              NVL(parent_node_id,0) = 0;

    CURSOR check_name_exists ( p_node_parent_id IN NUMBER, p_pc_node_id IN NUMBER, p_name IN VARCHAR2)
    IS
        select 'X'
        from ahl_pc_nodes_b
        where name = p_name and
                      -- upper(name) = upper(p_name) and
              parent_node_id = p_node_parent_id and
                  pc_node_id <> NVL(p_pc_node_id, 0) and
                      NVL(p_node_parent_id,0) <> 0 and
              draft_flag ='N';

    CURSOR get_pc_header_status (p_pc_header_id IN NUMBER)
    IS
        select status
        from ahl_pc_headers_b
        where pc_header_id = p_pc_header_id;

    CURSOR get_node_object_version (p_pc_node_id IN NUMBER)
    IS
        select object_version_number
        from ahl_pc_nodes_b
        where pc_node_id = p_pc_node_id;

    CURSOR check_leaf_node (p_parent_node_id IN NUMBER)
    IS
        select 'X'
        from ahl_pc_nodes_b node, ahl_pc_associations ahass
        where node.pc_node_id = p_parent_node_id and
              ahass.pc_node_id = p_parent_node_id;

    BEGIN
        -- Assumption: All mandatory field validation has been already done in the public package...

        -- Check for object_version_number sanity
        IF (p_node_rec.operation_flag <> G_DML_COPY AND p_node_rec.pc_node_id IS NOT NULL)
        THEN
            OPEN get_node_object_version (p_node_rec.pc_node_id);
            FETCH get_node_object_version INTO l_object_version_number;
            CLOSE get_node_object_version;
            IF (l_object_version_number <> p_node_rec.object_version_number)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- Check if PC exists
        OPEN check_header_id_exists (p_node_rec.pc_header_id);
        FETCH check_header_id_exists INTO l_header_id, l_pc_status;
        IF (check_header_id_exists%NOTFOUND)
        THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PC_NOT_FOUND');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- If PC status is DRAFT/APPROVAL_REJECTED, allow node operations
        IF (l_pc_status <> 'DRAFT' and l_pc_status <> 'APPROVAL_REJECTED')
        THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_STATUS_COMPLETE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE check_header_id_exists;

        -- Check for parent node id in the PC - it should exist
        IF nvl(p_node_rec.parent_node_id, 0) > 0
        THEN
        OPEN check_parent_exists (p_node_rec.pc_header_id, p_node_rec.parent_node_id);
            FETCH check_parent_exists INTO l_dummy;
            IF (check_parent_exists%NOTFOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_PARENT_NODE_NOT_FOUND');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_parent_exists;
        END IF;

        -- If operation is create / update node -- node name is mandatory, and node name should not be same for
        -- another name at same level
        IF (p_node_rec.operation_flag <> G_DML_DELETE)
        THEN
            IF (p_node_rec.parent_node_id IS NOT NULL AND p_node_rec.parent_node_id <> 0)
            THEN
                OPEN check_name_exists ( p_node_rec.parent_node_id, p_node_rec.pc_node_id, p_node_rec.name);
                FETCH check_name_exists INTO l_dummy;
                IF (check_name_exists%FOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_NAME_EXISTS');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_name_exists;
            ELSE
             -- added the following 1 line code for Bug# 2561404
              IF (p_node_rec.operation_flag = G_DML_CREATE)
               THEN
                OPEN check_root_node_exists (p_node_rec.pc_header_id);
                FETCH check_root_node_exists INTO l_dummy;
                IF (check_root_node_exists%FOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_ROOT_NODE_EXISTS');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_root_node_exists;
              END IF;
            END IF;
        END IF;

        -- If operation is update / delete node (except Delete PC), check for node id in the PC - it should exist
        IF (p_node_rec.operation_flag = G_DML_UPDATE) OR ( (p_node_rec.operation_flag = G_DML_DELETE) AND (p_node_rec.pc_node_id IS NOT NULL) )
        THEN
            OPEN check_id_exists (p_node_rec.pc_header_id, p_node_rec.pc_node_id);
            FETCH check_id_exists INTO l_dummy;
            IF (check_id_exists%NOTFOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_NOT_FOUND');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_id_exists;
        END IF;

        -- If parent node is a leaf node for Create Node (check from association table), then display appropriate error...
        If (p_node_rec.operation_flag = G_DML_CREATE)
        THEN
            OPEN check_leaf_node (p_node_rec.parent_node_id);
            FETCH check_leaf_node INTO l_dummy;
            IF (check_leaf_node%FOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_LEAF_NODE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_leaf_node;
        END IF;


    END VALIDATE_NODE;

    --------------------------
    -- SET_PC_HEADER_STATUS --
    --------------------------
    PROCEDURE SET_PC_HEADER_STATUS (p_pc_header_id IN NUMBER)
    IS

    CURSOR get_pc_header_status (p_pc_header_id IN NUMBER)
    IS
        select status
        from ahl_pc_headers_b
        where pc_header_id = p_pc_header_id;

    l_pc_status VARCHAR2(30) := 'DRAFT';

    BEGIN

        OPEN get_pc_header_status (p_pc_header_id);
        FETCH get_pc_header_status INTO l_pc_status;
        CLOSE get_pc_header_status;

        IF (l_pc_status = 'APPROVAL_REJECTED')
        THEN
            -- Force updation of PC status; No check of header version number sanity
            update ahl_pc_headers_b
            set status = 'DRAFT'
            where pc_header_id = p_pc_header_id;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            NULL;

    END SET_PC_HEADER_STATUS;

END AHL_PC_NODE_PVT;

/
