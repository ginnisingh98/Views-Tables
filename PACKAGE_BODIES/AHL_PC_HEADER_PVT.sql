--------------------------------------------------------
--  DDL for Package Body AHL_PC_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_HEADER_PVT" AS
/* $Header: AHLVPCHB.pls 120.5.12010000.4 2010/04/15 08:41:30 pekambar ship $ */

G_DEBUG VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;

-----------------------------
-- GET_DUP_UNIT_ITEM_ASSOS --
-----------------------------
FUNCTION GET_DUP_UNIT_ITEM_ASSOS (p_pc_header_id IN NUMBER)
RETURN BOOLEAN;

---------------------------------
-- VALIDATE_UNIT_PART_ATTACHED --
---------------------------------
FUNCTION VALIDATE_UNIT_PART_ATTACHED
(
    p_pc_header_id IN NUMBER ,
    p_prod_type    IN VARCHAR2,
    p_assos_type   IN VARCHAR2
)
RETURN BOOLEAN;

------------------------
-- VALIDATE_PC_HEADER --
------------------------
PROCEDURE VALIDATE_PC_HEADER (p_x_pc_header_rec IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC);

-------------------------------
-- VALIDATE_PC_HEADER_UPDATE --
-------------------------------
PROCEDURE VALIDATE_PC_HEADER_UPDATE
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
);

-----------------
-- CREATE_LINK --
-----------------
PROCEDURE CREATE_LINK
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC ,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
);

-----------------------------
-- DELETE_NODES_REMOVE_LINK--
-----------------------------
PROCEDURE DELETE_NODES_REMOVE_LINK (p_x_node_rec IN AHL_PC_NODE_PUB.PC_NODE_REC);

-----------------------------
-- DETACH_UNIT_REMOVE_LINK --
-----------------------------
PROCEDURE DETACH_UNIT_REMOVE_LINK (p_x_assos_rec IN AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC);

-----------------------------
-- DETACH_ITEM_REMOVE_LINK --
-----------------------------
PROCEDURE DETACH_ITEM_REMOVE_LINK (p_x_assos_rec IN AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC);

-----------------
-- REMOVE_LINK --
-----------------
PROCEDURE REMOVE_LINK
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC ,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
);

------------------------
-- DELETE_PC_AND_TREE --
------------------------
PROCEDURE DELETE_PC_AND_TREE (p_pc_header_id IN NUMBER);

----------------------
-- CREATE_PC_HEADER --
----------------------
PROCEDURE CREATE_PC_HEADER
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

l_api_name  CONSTANT    VARCHAR2(30)    := 'CREATE_PC_HEADER';
l_api_version   CONSTANT    NUMBER      := 1.0;
l_return_status         VARCHAR2(1);

l_rowid             ROWID;
l_header_id             NUMBER;
l_link_id                   NUMBER      :=0 ;
l_debug             VARCHAR2(2000);
l_sysdate           DATE        := sysdate;



BEGIN
    -- Standard start of API savepoint
    SAVEPOINT CREATE_PC_HEADER_PVT;

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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    END IF;

    IF p_x_pc_header_rec.OPERATION_FLAG = AHL_PC_HEADER_PVT.G_DML_CREATE
    THEN
        p_x_pc_header_rec.PC_HEADER_ID :=0;
    END IF;

    VALIDATE_PC_HEADER(p_x_pc_header_rec);

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Insert Record into ahl_pc_header_headers,
    -- call table handler insert record
    SELECT AHL_PC_HEADERS_B_S.NEXTVAL INTO l_header_id FROM DUAL;

    IF p_x_pc_header_rec.OPERATION_FLAG = AHL_PC_HEADER_PVT.G_DML_LINK
    THEN
        l_link_id := p_x_pc_header_rec.LINK_TO_PC_ID;
    END IF;

    AHL_PC_HEADERS_PKG.INSERT_ROW
    (
        X_ROWID                         => l_rowid,
        X_PC_HEADER_ID                  => l_header_id,
        X_PRODUCT_TYPE_CODE             => p_x_pc_header_rec.PRODUCT_TYPE_CODE,
        X_STATUS                        => 'DRAFT',
        X_PRIMARY_FLAG              => p_x_pc_header_rec.PRIMARY_FLAG,
        X_ASSOCIATION_TYPE_FLAG         => p_x_pc_header_rec.ASSOCIATION_TYPE_FLAG,
        X_OBJECT_VERSION_NUMBER         => 1,
        X_ATTRIBUTE_CATEGORY            => p_x_pc_header_rec.ATTRIBUTE_CATEGORY,
        X_SECURITY_GROUP_ID     => null,
        X_ATTRIBUTE1                    => p_x_pc_header_rec.ATTRIBUTE1,
        X_ATTRIBUTE2                    => p_x_pc_header_rec.ATTRIBUTE2,
        X_ATTRIBUTE3                => p_x_pc_header_rec.ATTRIBUTE3,
        X_ATTRIBUTE4                    => p_x_pc_header_rec.ATTRIBUTE4,
        X_ATTRIBUTE5                    => p_x_pc_header_rec.ATTRIBUTE5,
        X_ATTRIBUTE6                    => p_x_pc_header_rec.ATTRIBUTE6,
        X_ATTRIBUTE7                => p_x_pc_header_rec.ATTRIBUTE7,
        X_ATTRIBUTE8                    => p_x_pc_header_rec.ATTRIBUTE8,
        X_ATTRIBUTE9                    => p_x_pc_header_rec.ATTRIBUTE9,
        X_ATTRIBUTE10                   => p_x_pc_header_rec.ATTRIBUTE10,
        X_ATTRIBUTE11                   => p_x_pc_header_rec.ATTRIBUTE11,
        X_ATTRIBUTE12                   => p_x_pc_header_rec.ATTRIBUTE12,
        X_ATTRIBUTE13                   => p_x_pc_header_rec.ATTRIBUTE13,
        X_ATTRIBUTE14                   => p_x_pc_header_rec.ATTRIBUTE14,
        X_ATTRIBUTE15                   => p_x_pc_header_rec.ATTRIBUTE15,
        X_NAME                      => p_x_pc_header_rec.NAME,
        X_DESCRIPTION               => p_x_pc_header_rec.DESCRIPTION,
        X_DRAFT_FLAG                => 'N',
        X_LINK_TO_PC_ID             => nvl(l_link_id,0),
        X_CREATION_DATE             => l_sysdate,
        X_CREATED_BY                    => G_USER_ID,
        X_LAST_UPDATE_DATE          => l_sysdate,
        X_LAST_UPDATED_BY           => G_USER_ID,
        X_LAST_UPDATE_LOGIN             => G_USER_ID
    );

    p_x_pc_header_rec.PC_HEADER_ID := l_header_id;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- Created Header for ID='||p_x_pc_header_rec.PC_HEADER_ID);
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
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
        Rollback to CREATE_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to CREATE_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to CREATE_PC_HEADER_PVT;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                        p_procedure_name => 'CREATE_PC_HEADER',
                        p_error_text     => SUBSTR(SQLERRM,1,240));
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false);

END CREATE_PC_HEADER;

----------------------
-- UPDATE_PC_HEADER --
----------------------
PROCEDURE UPDATE_PC_HEADER
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

l_api_name  CONSTANT    VARCHAR2(30)    := 'UPDATE_PC_HEADER';
l_api_version   CONSTANT    NUMBER      := 1.0;
l_return_status         VARCHAR2(1);

l_sysdate           DATE        := sysdate;
l_link_to_pc_id             NUMBER;
l_is_pc_primary         VARCHAR2(1)     := 'N';
l_is_dup_assos          BOOLEAN     := FALSE;

CURSOR is_pc_primary (p_pc_header_id IN NUMBER)
IS
    select  primary_flag
    from    ahl_pc_headers_b
    where   pc_header_id = p_pc_header_id;

BEGIN


    -- Standard start of API savepoint
    SAVEPOINT UPDATE_PC_HEADER_PVT;

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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    END IF;

    -- If the to be PC was not primary and now changed to primary, and if it has duplicate...
    -- unit/part associations, then abort Update...
    IF (p_x_pc_header_rec.primary_flag = 'Y')
    THEN

        OPEN is_pc_primary (p_x_pc_header_rec.pc_header_id);
        FETCH is_pc_primary INTO l_is_pc_primary;
        CLOSE is_pc_primary;

        IF (l_is_pc_primary = 'N')
        THEN
            l_is_dup_assos := GET_DUP_UNIT_ITEM_ASSOS (p_x_pc_header_rec.pc_header_id);
            IF (l_is_dup_assos)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_DUP_UNIT_PART_ASSOS');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END IF;
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- UPDATE_PC_HEADER -- Can update PC, No duplicate unit/part associations');
    END IF;

    SELECT LINK_TO_PC_ID
    INTO p_x_pc_header_rec.LINK_TO_PC_ID
    FROM AHL_PC_HEADERS_VL
    WHERE PC_HEADER_ID = p_x_pc_header_rec.PC_HEADER_ID;

    IF p_x_pc_header_rec.OPERATION_FLAG <> AHL_PC_HEADER_PVT.G_DML_LINK
    THEN
        VALIDATE_PC_HEADER (p_x_pc_header_rec   => p_x_pc_header_rec);

        VALIDATE_PC_HEADER_UPDATE
        (
            p_api_version       => p_api_version,
            p_init_msg_list     => p_init_msg_list,
            p_commit            => p_commit,
            p_validation_level  => p_validation_level,
            p_x_pc_header_rec   => p_x_pc_header_rec,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data
        );

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug('PCH -- PVT -- UPDATE_PC_HEADER -- Operation Flag after VALIDATE_PC_HEADER_UPDATE = '||p_x_pc_header_rec.OPERATION_FLAG);
        END IF;

        IF p_x_pc_header_rec.OPERATION_FLAG = AHL_PC_HEADER_PVT.G_DML_LINK
        THEN
            -- Check Error Message stack.
            x_msg_count := FND_MSG_PUB.count_msg;
            IF x_msg_count > 0
            THEN
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

            RETURN;
            -- If OPERATION_FLAG is G_DML_LINK then do not update the rec as the procedure will have updated
            -- hence merely return
        END IF;
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    AHL_PC_HEADERS_PKG.UPDATE_ROW
    (
        X_PC_HEADER_ID                  => p_x_pc_header_rec.PC_HEADER_ID,
        X_PRODUCT_TYPE_CODE             => p_x_pc_header_rec.PRODUCT_TYPE_CODE,
        X_STATUS                        => p_x_pc_header_rec.STATUS,
        X_PRIMARY_FLAG              => p_x_pc_header_rec.PRIMARY_FLAG,
        X_ASSOCIATION_TYPE_FLAG         => p_x_pc_header_rec.ASSOCIATION_TYPE_FLAG,
        X_OBJECT_VERSION_NUMBER         => p_x_pc_header_rec.OBJECT_VERSION_NUMBER + 1,
        X_SECURITY_GROUP_ID         => null,
        X_ATTRIBUTE_CATEGORY            => p_x_pc_header_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1                    => p_x_pc_header_rec.ATTRIBUTE1,
        X_ATTRIBUTE2                    => p_x_pc_header_rec.ATTRIBUTE2,
        X_ATTRIBUTE3                => p_x_pc_header_rec.ATTRIBUTE3,
        X_ATTRIBUTE4                    => p_x_pc_header_rec.ATTRIBUTE4,
        X_ATTRIBUTE5                    => p_x_pc_header_rec.ATTRIBUTE5,
        X_ATTRIBUTE6                    => p_x_pc_header_rec.ATTRIBUTE6,
        X_ATTRIBUTE7                => p_x_pc_header_rec.ATTRIBUTE7,
        X_ATTRIBUTE8                    => p_x_pc_header_rec.ATTRIBUTE8,
        X_ATTRIBUTE9                    => p_x_pc_header_rec.ATTRIBUTE9,
        X_ATTRIBUTE10                   => p_x_pc_header_rec.ATTRIBUTE10,
        X_ATTRIBUTE11                   => p_x_pc_header_rec.ATTRIBUTE11,
        X_ATTRIBUTE12                   => p_x_pc_header_rec.ATTRIBUTE12,
        X_ATTRIBUTE13                   => p_x_pc_header_rec.ATTRIBUTE13,
        X_ATTRIBUTE14                   => p_x_pc_header_rec.ATTRIBUTE14,
        X_ATTRIBUTE15                   => p_x_pc_header_rec.ATTRIBUTE15,
        X_NAME                      => p_x_pc_header_rec.NAME,
        X_DESCRIPTION               => p_x_pc_header_rec.DESCRIPTION,
        X_DRAFT_FLAG                => 'N',
        X_LINK_TO_PC_ID             => p_x_pc_header_rec.LINK_TO_PC_ID,
        X_LAST_UPDATE_DATE          => l_sysdate,
        X_LAST_UPDATED_BY           => G_USER_ID,
        X_LAST_UPDATE_LOGIN             => G_USER_ID
    );

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- UPDATE_PC_HEADER -- After DB Update');
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
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
        Rollback to UPDATE_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to UPDATE_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to UPDATE_PC_HEADER_PVT;
        IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                         p_procedure_name => 'UPDATE_PC_HEADER',
                         p_error_text     => SUBSTR(SQLERRM,1,240) );
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

END UPDATE_PC_HEADER;

----------------------
-- DELETE_PC_HEADER --
----------------------
PROCEDURE DELETE_PC_HEADER
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

CURSOR check_header_status (p_pc_header_id varchar2)
IS
    SELECT  STATUS
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = p_pc_header_id;

CURSOR delete_node (p_pc_header_id varchar2)
IS
    SELECT  PC_NODE_ID
    FROM    AHL_PC_NODES_B
    WHERE   PC_HEADER_ID = p_pc_header_id AND
        PARENT_NODE_ID = 0;

CURSOR delete_linked_header (p_pc_header_id varchar2)
IS
    SELECT  LINK_TO_PC_ID
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = p_pc_header_id;

l_api_name  CONSTANT    VARCHAR2(30)    := 'DELETE_PC_HEADER';
l_api_version   CONSTANT    NUMBER      := 1.0;
l_return_status         VARCHAR2(1);
l_dummy             VARCHAR2(30);
l_node_id           NUMBER      := 0;
l_link_to_header_id         NUMBER      := 0;
l_node_rec          AHL_PC_NODE_PUB.PC_NODE_REC;
l_status            VARCHAR2(30);
l_node_tbl          T_ID_TBL;
l_assos_tbl             T_ID_TBL;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT DELETE_PC_HEADER_PVT;

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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    END IF;

    OPEN check_header_status(p_x_pc_header_rec.PC_HEADER_ID);
    FETCH check_header_status INTO l_status;
    IF(check_header_status%NOTFOUND)
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PC_NOT_FOUND');
        FND_MSG_PUB.ADD;
        CLOSE check_header_status;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        CLOSE check_header_status;
        IF (l_status <> 'DRAFT' AND l_status <> 'APPROVAL_REJECTED')
        THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_PC_DRAFT_DELETE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE

            l_link_to_header_id := 0;
            OPEN delete_linked_header(p_x_pc_header_rec.PC_HEADER_ID);
            FETCH delete_linked_header INTO l_link_to_header_id;
            CLOSE delete_linked_header;
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Retrieving linked PC ID='||l_link_to_header_id);
            END IF;

            OPEN delete_node(p_x_pc_header_rec.PC_HEADER_ID);
            FETCH delete_node INTO l_node_id;
            IF(delete_node%FOUND)
            THEN
                l_node_rec.PC_HEADER_ID := p_x_pc_header_rec.PC_HEADER_ID;
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Deleting Node Tree from ID='||l_node_rec.PC_NODE_ID);
                END IF;
                AHL_PC_NODE_PVT.DELETE_NODES
                (
                    p_api_version           => p_api_version,
                    p_init_msg_list         => p_init_msg_list,
                    p_commit                => p_commit,
                    p_validation_level      => p_validation_level,
                    p_x_node_rec	    => l_node_rec,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data
                );
            END IF;
            CLOSE delete_node;

	    -- Priyan:
	    -- Added error handling after the Delete_Nodes API is called.
	    -- Check Error Message stack.
	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
	    THEN
	       x_msg_count := FND_MSG_PUB.count_msg;
	       IF x_msg_count > 0 THEN
		    RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    END IF;


            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Deleting PC with ID='||p_x_pc_header_rec.PC_HEADER_ID);
            END IF;
            AHL_PC_HEADERS_PKG.DELETE_ROW (p_x_pc_header_rec.PC_HEADER_ID);

            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Changing DRAFT_FLAG=Y for linked-to PC with ID='||l_link_to_header_id);
            END IF;

            IF (l_link_to_header_id <> 0)
            THEN
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Done for Header ID='||l_link_to_header_id);
                END IF;
                UPDATE AHL_PC_HEADERS_B
                SET DRAFT_FLAG='N'
                WHERE PC_HEADER_ID = l_link_to_header_id;

                l_node_id := 0;
                OPEN delete_node(l_link_to_header_id);
                FETCH delete_node INTO l_node_id;
                CLOSE delete_node;

                IF (l_node_id <> 0)
                THEN
                    SELECT pc_node_id
                    BULK COLLECT INTO l_node_tbl
                    FROM ahl_pc_nodes_b
                    WHERE pc_header_id = l_link_to_header_id
                    CONNECT BY parent_node_id = PRIOR pc_node_id
                    START WITH pc_node_id = l_node_id;

                    SELECT pc_association_id
                    BULK COLLECT INTO l_assos_tbl
                    FROM ahl_pc_associations ahass
                    WHERE pc_node_id IN (
                        SELECT pc_node_id
                        FROM ahl_pc_nodes_b
                        WHERE pc_header_id = l_link_to_header_id
                        CONNECT BY parent_node_id = PRIOR pc_node_id
                        START WITH pc_node_id = l_node_id
                    );

                    IF (l_node_tbl.COUNT > 0)
                    THEN
                        FOR i IN l_node_tbl.FIRST..l_node_tbl.LAST
                        LOOP
                            IF G_DEBUG='Y' THEN
                              AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Done for Node ID='||l_node_tbl(i));
                            END IF;
                            UPDATE AHL_PC_NODES_B
                            SET DRAFT_FLAG = 'N'
                            WHERE PC_NODE_ID = l_node_tbl(i);
                        END LOOP;
                    END IF;

                    IF (l_assos_tbl.COUNT > 0)
                    THEN
                    FOR j IN l_assos_tbl.FIRST..l_assos_tbl.LAST
                        LOOP
                            IF G_DEBUG='Y' THEN
                                AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- Done for Association ID='||l_assos_tbl(j));
                            END IF;
                            UPDATE AHL_PC_ASSOCIATIONS
                            SET DRAFT_FLAG = 'N'
                            WHERE PC_ASSOCIATION_ID = l_assos_tbl(j);
                        END LOOP;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_HEADER -- After DB Delete');
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
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
        Rollback to DELETE_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to DELETE_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to DELETE_PC_HEADER_PVT;
        IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                         p_procedure_name => 'DELETE_PC_HEADER',
                         p_error_text     => SUBSTR(SQLERRM,1,240) );
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );
END DELETE_PC_HEADER;

--------------------
-- COPY_PC_HEADER --
--------------------
PROCEDURE COPY_PC_HEADER
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

-- For Bug # 9486654 we split cursor  copy_nodes_data in to two cursors
-- Separately for nodes and units/parts as copy_nodes_data and copy_asso_data

CURSOR copy_nodes_data (p_header_id IN NUMBER)
IS
  -- Perf Fix - 4913818 Re-writing Cursor Query Below.
  /*
    SELECT  *
    FROM    AHL_PC_TREE_V
    WHERE   PC_HEADER_ID = p_header_id AND
        ( NODE_TYPE = G_NODE OR
          ( p_copy_assos_flag = 'Y' AND NODE_TYPE IN (G_PART, G_UNIT) )
        )
    ORDER BY PARENT_NODE_ID;
  */

  SELECT  AHNO.ROW_ID,
            AHNO.PC_NODE_ID,
            AHNO.OBJECT_VERSION_NUMBER,
            AHNO.LAST_UPDATE_DATE,
            AHNO.LAST_UPDATED_BY,
            AHNO.CREATION_DATE,
            AHNO.CREATED_BY,
            AHNO.LAST_UPDATE_LOGIN,
            AHNO.PC_HEADER_ID,
            AHNO.NAME,
            AHNO.PARENT_NODE_ID,
            AHNO.CHILD_COUNT,
            AHNO.LINK_TO_NODE_ID,
            AHNO.DRAFT_FLAG,
            AHNO.DESCRIPTION,
            'N' NODE_TYPE,
            0 UNIT_ITEM_ID,
            0 INVENTORY_ORG_ID,
            AHNO.OPERATION_STATUS_FLAG,
            AHNO.SECURITY_GROUP_ID,
            AHNO.ATTRIBUTE_CATEGORY,
            AHNO.ATTRIBUTE1,
            AHNO.ATTRIBUTE2,
            AHNO.ATTRIBUTE3,
            AHNO.ATTRIBUTE4,
            AHNO.ATTRIBUTE5,
            AHNO.ATTRIBUTE6,
            AHNO.ATTRIBUTE7,
            AHNO.ATTRIBUTE8,
            AHNO.ATTRIBUTE9,
            AHNO.ATTRIBUTE10,
            AHNO.ATTRIBUTE11,
            AHNO.ATTRIBUTE12,
            AHNO.ATTRIBUTE13,
            AHNO.ATTRIBUTE14,
            AHNO.ATTRIBUTE15
      FROM  AHL_PC_NODES_VL AHNO
     WHERE  AHNO.PC_HEADER_ID = p_header_id
     START WITH PARENT_NODE_ID = 0
     CONNECT BY PRIOR PC_NODE_ID =  PARENT_NODE_ID;

CURSOR copy_nodes_units_data (p_header_id IN NUMBER, p_copy_assos_flag IN VARCHAR2)
IS
    SELECT  DISTINCT AHS.ROWID ROW_ID,
            AHS.PC_ASSOCIATION_ID PC_NODE_ID,
            AHS.OBJECT_VERSION_NUMBER,
            AHS.LAST_UPDATE_DATE,
            AHS.LAST_UPDATED_BY,
            AHS.CREATION_DATE,
            AHS.CREATED_BY,
            AHS.LAST_UPDATE_LOGIN,
            NODE.PC_HEADER_ID,
            DECODE(AHS.ASSOCIATION_TYPE_FLAG,'U',UNIT.NAME,MTL.CONCATENATED_SEGMENTS) NAME,
            AHS.PC_NODE_ID PARENT_NODE_ID,
            0 CHILD_COUNT,
            AHS.LINK_TO_ASSOCIATION_ID LINK_TO_NODE_ID,
            AHS.DRAFT_FLAG,
            MTL.DESCRIPTION,
            AHS.ASSOCIATION_TYPE_FLAG NODE_TYPE,
            AHS.UNIT_ITEM_ID,
            AHS.INVENTORY_ORG_ID,
            AHS.OPERATION_STATUS_FLAG,
            AHS.SECURITY_GROUP_ID,
            AHS.ATTRIBUTE_CATEGORY,
            AHS.ATTRIBUTE1,
            AHS.ATTRIBUTE2,
            AHS.ATTRIBUTE3,
            AHS.ATTRIBUTE4,
            AHS.ATTRIBUTE5,
            AHS.ATTRIBUTE6,
            AHS.ATTRIBUTE7,
            AHS.ATTRIBUTE8,
            AHS.ATTRIBUTE9,
            AHS.ATTRIBUTE10,
            AHS.ATTRIBUTE11,
            AHS.ATTRIBUTE12,
            AHS.ATTRIBUTE13,
            AHS.ATTRIBUTE14,
            AHS.ATTRIBUTE15
      FROM  AHL_PC_ASSOCIATIONS AHS, AHL_UNIT_CONFIG_HEADERS UNIT,
            CSI_ITEM_INSTANCES CSI, MTL_SYSTEM_ITEMS_KFV MTL,
            AHL_PC_NODES_B NODE, AHL_PC_HEADERS_B HEADER
     WHERE  p_copy_assos_flag = 'Y'
       AND  NODE.PC_HEADER_ID = HEADER.PC_HEADER_ID
       AND  NODE.PC_NODE_ID = AHS.PC_NODE_ID
       AND  HEADER.PC_HEADER_ID = p_header_id
       AND  UNIT.UNIT_CONFIG_HEADER_ID(+) = AHS.UNIT_ITEM_ID
       AND  UNIT.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID(+)
       AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.UNIT_ITEM_ID,
                                             'U',CSI.INVENTORY_ITEM_ID) = MTL.INVENTORY_ITEM_ID
       -- SATHAPLI::Bug# 5576835, 20-Aug-2007
       /*
       AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',FND_PROFILE.VALUE('ORG_ID'),
                                             'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
       */
       AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.INVENTORY_ORG_ID,
                                             'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
       AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',MTL.ITEM_TYPE,
                                             'U',HEADER.PRODUCT_TYPE_CODE) = MTL.ITEM_TYPE;

  --ORDER BY PARENT_NODE_ID;

CURSOR copy_document (p_node_id IN VARCHAR2)
IS
    SELECT  *
    FROM    AHL_DOC_TITLE_ASSOS_VL
    WHERE   ASO_OBJECT_TYPE_CODE ='PC' AND
        ASO_OBJECT_ID = p_node_id;

l_api_name  CONSTANT    VARCHAR2(30)    := 'COPY_PC_HEADER';
l_api_version   CONSTANT    NUMBER      := 1.0;
l_return_status         VARCHAR2(1);

l_node_rec              AHL_PC_NODE_PUB.PC_NODE_REC;
l_assos_doc_tbl             AHL_DI_ASSO_DOC_ASO_PVT.ASSOCIATION_TBL;
l_assos_rec             AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC;
l_node_data_rec         copy_nodes_data%ROWTYPE;
l_node_units_data_rec         copy_nodes_units_data%ROWTYPE;

l_assos_data_rec        copy_document%ROWTYPE;
l_nodeId_tbl            PC_NODE_ID_TBL;
l_nodeCtr               NUMBER;
l_nc                    NUMBER;
l_old_header_id         NUMBER;
l_assosCtr          NUMBER;
l_is_pc_primary         VARCHAR2(1)     := 'N';
l_is_dup_assos          BOOLEAN     := FALSE;
l_dummy             BOOLEAN;
l_dummy_2           VARCHAR2(1);


CURSOR is_pc_primary (p_pc_header_id IN NUMBER)
IS
    select  primary_flag
    from    ahl_pc_headers_b
    where   pc_header_id = p_pc_header_id;

CURSOR node_test(p_node_id IN VARCHAR2)
IS
    SELECT  'x'
    FROM    AHL_PC_NODES_B
    WHERE   pc_node_id = p_node_id;

CURSOR check_name_unique(p_pc_name IN VARCHAR2)
IS
    SELECT  'x'
    FROM    AHL_PC_HEADERS_B
    WHERE   NAME = p_pc_name;


BEGIN

    -- Standard start of API savepoint
    SAVEPOINT COPY_PC_HEADER_PVT;

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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    END IF;

    l_old_header_id             := p_x_pc_header_rec.PC_HEADER_ID;
    p_x_pc_header_rec.OPERATION_FLAG    := AHL_PC_HEADER_PVT.G_DML_CREATE;

    -- Check whether another PC with the same name exists, throw error in that case
    OPEN check_name_unique( p_x_pc_header_rec.name );
    FETCH check_name_unique INTO l_dummy_2;
    IF (check_name_unique%FOUND)
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PC_NAME_EXISTS');
        FND_MSG_PUB.ADD;
        CLOSE check_name_unique;
        RAISE FND_API.G_EXC_ERROR;
            END IF;
    CLOSE check_name_unique;

    -- If the to be copied PC is not primary and the new PC is primary, and if the to be...
    -- copied PC has duplicate unit/part associations, then abort Copy...
    IF (p_x_pc_header_rec.primary_flag = 'Y' and p_x_pc_header_rec.copy_assos_flag = 'Y')
    THEN
        OPEN is_pc_primary (l_old_header_id);
        FETCH is_pc_primary INTO l_is_pc_primary;
        CLOSE is_pc_primary;

        IF (l_is_pc_primary = 'N')
        THEN
            l_is_dup_assos := GET_DUP_UNIT_ITEM_ASSOS (l_old_header_id);
            IF (l_is_dup_assos)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_DUP_UNIT_PART_ASSOS');
                FND_MSG_PUB.ADD;
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END IF;

    l_dummy := VALIDATE_UNIT_PART_ATTACHED (p_x_pc_header_rec.PC_HEADER_ID, p_x_pc_header_rec.PRODUCT_TYPE_CODE, p_x_pc_header_rec.ASSOCIATION_TYPE_FLAG);

    IF (l_dummy = FALSE AND p_x_pc_header_rec.COPY_ASSOS_FLAG = 'Y')
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_PART_ATTACHED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CREATE_PC_HEADER
    (
        p_api_version           => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        p_validation_level      => p_validation_level,
        p_x_pc_header_rec   => p_x_pc_header_rec,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
    );
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- Copied into new PC with ID='||p_x_pc_header_rec.PC_HEADER_ID);
    END IF;

    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_nodeCtr := 0;
   -- For Bug # 9486654 copy_nodes_data
    OPEN copy_nodes_data ( p_header_id => l_old_header_id);
    LOOP
        FETCH copy_nodes_data  INTO l_node_data_rec;
        EXIT WHEN copy_nodes_data%NOTFOUND;

        IF l_node_data_rec.node_type = G_NODE
        THEN
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- Creating node record for ID='||l_node_data_rec.PC_NODE_ID);
            END IF;
            l_node_rec.PC_HEADER_ID         := p_x_pc_header_rec.PC_HEADER_ID;
            l_node_rec.PC_NODE_ID           := l_node_data_rec.PC_NODE_ID;
            l_node_rec.PARENT_NODE_ID       := l_node_data_rec.PARENT_NODE_ID;
            l_node_rec.CHILD_COUNT          := l_node_data_rec.CHILD_COUNT;
            l_node_rec.NAME             := l_node_data_rec.NAME;
            l_node_rec.DESCRIPTION          := l_node_data_rec.DESCRIPTION;
            l_node_rec.DRAFT_FLAG           := 'N';
            l_node_rec.LINK_TO_NODE_ID          := 0;
            l_node_rec.OBJECT_VERSION_NUMBER    := 1;
            l_node_rec.OPERATION_FLAG       := AHL_PC_HEADER_PVT.G_DML_COPY;
            l_node_rec.ATTRIBUTE_CATEGORY       := l_node_data_rec.ATTRIBUTE_CATEGORY;
            l_node_rec.ATTRIBUTE1           := l_node_data_rec.ATTRIBUTE1;
            l_node_rec.ATTRIBUTE2           := l_node_data_rec.ATTRIBUTE2;
            l_node_rec.ATTRIBUTE3           := l_node_data_rec.ATTRIBUTE3;
            l_node_rec.ATTRIBUTE4           := l_node_data_rec.ATTRIBUTE4;
            l_node_rec.ATTRIBUTE5           := l_node_data_rec.ATTRIBUTE5;
            l_node_rec.ATTRIBUTE6           := l_node_data_rec.ATTRIBUTE6;
            l_node_rec.ATTRIBUTE7           := l_node_data_rec.ATTRIBUTE7;
            l_node_rec.ATTRIBUTE8           := l_node_data_rec.ATTRIBUTE8;
            l_node_rec.ATTRIBUTE9           := l_node_data_rec.ATTRIBUTE9;
            l_node_rec.ATTRIBUTE10          := l_node_data_rec.ATTRIBUTE10;
            l_node_rec.ATTRIBUTE11          := l_node_data_rec.ATTRIBUTE11;
            l_node_rec.ATTRIBUTE12          := l_node_data_rec.ATTRIBUTE12;
            l_node_rec.ATTRIBUTE13          := l_node_data_rec.ATTRIBUTE13;
            l_node_rec.ATTRIBUTE14          := l_node_data_rec.ATTRIBUTE14;
            l_node_rec.ATTRIBUTE15          := l_node_data_rec.ATTRIBUTE15;

        END IF;

        IF l_nodeCtr = 0
        THEN
            l_node_rec.PARENT_NODE_ID := 0;
        ELSE
            FOR l_nc IN 0..l_nodeCtr
            LOOP
                IF l_nodeId_tbl(l_nc).NODE_ID = l_node_data_rec.PARENT_NODE_ID
                THEN
                    IF l_node_data_rec.node_type = G_NODE
                    THEN
                        l_node_rec.PARENT_NODE_ID := l_nodeId_tbl(l_nc).NEW_NODE_ID;
                        EXIT;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF l_node_data_rec.node_type = G_NODE
        THEN
	    IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- Before AHL_PC_NODE_PVT.CREATE_NODE l_node_rec.PC_NODE_ID ='||l_node_rec.PC_NODE_ID);
            END IF;

            AHL_PC_NODE_PVT.CREATE_NODE
            (
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_node_rec        => l_node_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );

	    IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- After AHL_PC_NODE_PVT.CREATE_NODE l_node_rec.PC_NODE_ID ='||l_node_rec.PC_NODE_ID);
            END IF;

            l_nodeId_tbl(l_nodeCtr).NODE_ID         := l_node_data_rec.PC_NODE_ID;
            l_nodeId_tbl(l_nodeCtr).NEW_NODE_ID     := l_node_rec.PC_NODE_ID;
            l_nodeCtr                           := l_nodeCtr + 1;

	    IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- After AHL_PC_NODE_PVT.CREATE_NODE l_nodeCtr ='||l_nodeCtr);
            END IF;

        END IF;

        IF ( p_x_pc_header_rec.COPY_DOCS_FLAG = 'Y' AND l_node_data_rec.node_type = G_NODE )
        THEN
            l_assosCtr:=0;
            OPEN copy_document(l_node_data_rec.PC_NODE_ID);
            LOOP
                FETCH copy_document INTO l_assos_data_rec;
                EXIT WHEN copy_document%NOTFOUND;
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- Creating doc record for ID='||l_assos_data_rec.DOCUMENT_ID);
                END IF;
                l_assos_doc_tbl(l_assosCtr).DOC_TITLE_ASSO_ID       := null;
                l_assos_doc_tbl(l_assosCtr).DOCUMENT_ID             := l_assos_data_rec.DOCUMENT_ID         ;
                l_assos_doc_tbl(l_assosCtr).DOC_REVISION_ID         := l_assos_data_rec.DOC_REVISION_ID     ;
                l_assos_doc_tbl(l_assosCtr).USE_LATEST_REV_FLAG     := l_assos_data_rec.USE_LATEST_REV_FLAG ;
                l_assos_doc_tbl(l_assosCtr).ASO_OBJECT_TYPE_CODE    := l_assos_data_rec.ASO_OBJECT_TYPE_CODE;
                l_assos_doc_tbl(l_assosCtr).ASO_OBJECT_ID           := l_nodeId_tbl(l_nodeCtr-1).NEW_NODE_ID;
                l_assos_doc_tbl(l_assosCtr).SERIAL_NO               := l_assos_data_rec.SERIAL_NO           ;
                l_assos_doc_tbl(l_assosCtr).CHAPTER                 := l_assos_data_rec.CHAPTER             ;
                l_assos_doc_tbl(l_assosCtr).SECTION                 := l_assos_data_rec.SECTION             ;
                l_assos_doc_tbl(l_assosCtr).SUBJECT                 := l_assos_data_rec.SUBJECT             ;
                l_assos_doc_tbl(l_assosCtr).PAGE                    := l_assos_data_rec.PAGE                ;
                l_assos_doc_tbl(l_assosCtr).FIGURE                  := l_assos_data_rec.FIGURE              ;
                l_assos_doc_tbl(l_assosCtr).NOTE                    := l_assos_data_rec.NOTE                ;
                l_assos_doc_tbl(l_assosCtr).OBJECT_VERSION_NUMBER   := l_assos_data_rec.OBJECT_VERSION_NUMBER ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE_CATEGORY      := l_assos_data_rec.ATTRIBUTE_CATEGORY  ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE1              := l_assos_data_rec.ATTRIBUTE1          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE2              := l_assos_data_rec.ATTRIBUTE2          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE3              := l_assos_data_rec.ATTRIBUTE3          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE4              := l_assos_data_rec.ATTRIBUTE4          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE5              := l_assos_data_rec.ATTRIBUTE5          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE6              := l_assos_data_rec.ATTRIBUTE6          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE7              := l_assos_data_rec.ATTRIBUTE7          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE8              := l_assos_data_rec.ATTRIBUTE8          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE9              := l_assos_data_rec.ATTRIBUTE9          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE10             := l_assos_data_rec.ATTRIBUTE10         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE11             := l_assos_data_rec.ATTRIBUTE11         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE12             := l_assos_data_rec.ATTRIBUTE12         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE13             := l_assos_data_rec.ATTRIBUTE13         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE14             := l_assos_data_rec.ATTRIBUTE14         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE15             := l_assos_data_rec.ATTRIBUTE15         ;
                l_assosCtr := l_assosCtr + 1;
            END LOOP;
            CLOSE copy_document;

            IF l_assosCtr > 0
            THEN
                AHL_DI_ASSO_DOC_ASO_PVT.CREATE_ASSOCIATION
                (
                    p_api_version           => 1.0,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit        => FND_API.G_FALSE,
                    p_validation_level  => p_validation_level,
                    p_x_association_tbl => l_assos_doc_tbl,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data
                );
            END IF;

        END IF;

    END LOOP;

-- For Bug # 9486654 copy_nodes_units_data
    OPEN copy_nodes_units_data ( p_header_id => l_old_header_id,
                   p_copy_assos_flag => p_x_pc_header_rec.COPY_ASSOS_FLAG );
    LOOP
        FETCH copy_nodes_units_data  INTO l_node_units_data_rec;
        EXIT WHEN copy_nodes_units_data%NOTFOUND;

        IF p_x_pc_header_rec.COPY_ASSOS_FLAG = 'Y' AND l_node_units_data_rec.node_type IN (G_PART, G_UNIT)
        THEN
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- Creating unit/part record for ID='||l_node_units_data_rec.PC_NODE_ID);
            END IF;
            l_assos_rec.UNIT_ITEM_ID        := l_node_units_data_rec.UNIT_ITEM_ID;
            l_assos_rec.INVENTORY_ORG_ID        := l_node_units_data_rec.INVENTORY_ORG_ID;
            l_assos_rec.ASSOCIATION_TYPE_FLAG   := l_node_units_data_rec.node_type;
            l_assos_rec.DRAFT_FLAG          := 'N';
            l_assos_rec.LINK_TO_ASSOCIATION_ID      := 0;
            l_assos_rec.OPERATION_FLAG      := AHL_PC_HEADER_PVT.G_DML_COPY;
            l_assos_rec.OBJECT_VERSION_NUMBER   := 1;
            l_assos_rec.ATTRIBUTE_CATEGORY      := l_node_units_data_rec.ATTRIBUTE_CATEGORY;
            l_assos_rec.ATTRIBUTE1          := l_node_units_data_rec.ATTRIBUTE1;
            l_assos_rec.ATTRIBUTE2          := l_node_units_data_rec.ATTRIBUTE2;
            l_assos_rec.ATTRIBUTE3          := l_node_units_data_rec.ATTRIBUTE3;
            l_assos_rec.ATTRIBUTE4          := l_node_units_data_rec.ATTRIBUTE4;
            l_assos_rec.ATTRIBUTE5          := l_node_units_data_rec.ATTRIBUTE5;
            l_assos_rec.ATTRIBUTE6          := l_node_units_data_rec.ATTRIBUTE6;
            l_assos_rec.ATTRIBUTE7          := l_node_units_data_rec.ATTRIBUTE7;
            l_assos_rec.ATTRIBUTE8          := l_node_units_data_rec.ATTRIBUTE8;
            l_assos_rec.ATTRIBUTE9          := l_node_units_data_rec.ATTRIBUTE9;
            l_assos_rec.ATTRIBUTE10         := l_node_units_data_rec.ATTRIBUTE10;
            l_assos_rec.ATTRIBUTE11         := l_node_units_data_rec.ATTRIBUTE11;
            l_assos_rec.ATTRIBUTE12         := l_node_units_data_rec.ATTRIBUTE12;
            l_assos_rec.ATTRIBUTE13         := l_node_units_data_rec.ATTRIBUTE13;
            l_assos_rec.ATTRIBUTE14         := l_node_units_data_rec.ATTRIBUTE14;
            l_assos_rec.ATTRIBUTE15         := l_node_units_data_rec.ATTRIBUTE15;

        END IF;

            FOR l_nc IN 0..l_nodeCtr
            LOOP
                IF l_nodeId_tbl(l_nc).NODE_ID = l_node_units_data_rec.PARENT_NODE_ID
                THEN
		    IF p_x_pc_header_rec.COPY_ASSOS_FLAG = 'Y' AND l_node_units_data_rec.node_type IN (G_PART, G_UNIT)
                    THEN
                        l_assos_rec.PC_NODE_ID := l_nodeId_tbl(l_nc).NEW_NODE_ID;
                        EXIT;
                    END IF;
                END IF;
            END LOOP;


        IF p_x_pc_header_rec.COPY_ASSOS_FLAG = 'Y' AND l_node_units_data_rec.node_type ='U'
        THEN
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- Before AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT: l_assos_rec.PC_NODE_ID ='||l_assos_rec.PC_NODE_ID);
            END IF;

	    AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT
            (
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_assos_rec       => l_assos_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );

            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- After AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT: l_assos_rec.PC_NODE_ID ='||l_assos_rec.PC_NODE_ID);
            END IF;

        ELSIF p_x_pc_header_rec.COPY_ASSOS_FLAG = 'Y' AND l_node_units_data_rec.node_type ='I'
        THEN
            AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM
            (
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_assos_rec       => l_assos_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );
        END IF;

    END LOOP;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- COPY_PC_HEADER -- After Copy PC');
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
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
        Rollback to COPY_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to COPY_PC_HEADER_PVT;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to COPY_PC_HEADER_PVT;
        IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                         p_procedure_name => 'COPY_PC_HEADER',
                         p_error_text     => SUBSTR(SQLERRM,1,240) );
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

END COPY_PC_HEADER;

--------------------------
-- INITIATE_PC_APPROVAL --
--------------------------
PROCEDURE INITIATE_PC_APPROVAL
(
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN  VARCHAR2  := FND_API.G_FALSE,
    x_return_status         OUT     NOCOPY VARCHAR2,
    x_msg_count             OUT     NOCOPY NUMBER,
    x_msg_data              OUT     NOCOPY VARCHAR2,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC
)
AS

CURSOR get_pc_details(l_pc_header_id IN NUMBER, l_object_version_number IN NUMBER)
IS
    SELECT  STATUS, NAME
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = l_pc_header_id AND
        OBJECT_VERSION_NUMBER = l_object_version_number;


l_counter               NUMBER      := 0;
l_status                VARCHAR2(30);
l_object                VARCHAR2(30)    := 'PCWF';
l_approval_type         VARCHAR2(100)   := 'CONCEPT';
l_active                VARCHAR2(50);
l_process_name          VARCHAR2(50);
l_item_type             VARCHAR2(50);
l_return_status         VARCHAR2(50);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_activity_id           NUMBER      := p_x_pc_header_rec.PC_HEADER_ID;
l_object_version_number NUMBER;

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list)
    THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    --END IF;
    --IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- Starting to call INITIATE_PC_APPROVAL');
    END IF;

    -- Retrieve the workflow process name for object PCWF
    ahl_utility_pvt.get_wf_process_name
    (
        p_object       =>l_object,
        x_active       =>l_active,
        x_process_name =>l_process_name ,
        x_item_type    =>l_item_type,
        x_return_status=>l_return_status,
        x_msg_count    =>l_msg_count,
        x_msg_data     =>l_msg_data
    );
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- get_wf_process_name returns l_object='||l_object);
    --END IF;
    --IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- get_wf_process_name returns l_active='||l_active);
    --END IF;
    --IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- get_wf_process_name returns l_process_name='||l_process_name);
    --END IF;
    --IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- get_wf_process_name returns l_item_type='||l_item_type);
    --END IF;
    --IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- get_wf_process_name returns l_return_status='||l_return_status);
    END IF;

    -- If the workflow process is active...
    IF l_active = 'Y'
    THEN
        -- Update PC with new status, increase object_version_number
        l_object_version_number := p_x_pc_header_rec.OBJECT_VERSION_NUMBER + 1;
        UPDATE  AHL_PC_HEADERS_B
        SET     STATUS = 'APPROVAL_PENDING', OBJECT_VERSION_NUMBER = l_object_version_number
        WHERE   PC_HEADER_ID = p_x_pc_header_rec.PC_HEADER_ID AND
            OBJECT_VERSION_NUMBER = p_x_pc_header_rec.OBJECT_VERSION_NUMBER;

        -- If no updation happened, record must have already been modified by another user...
        IF (sql%rowcount) = 0
        THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        -- Else start PCWF workflow process for this PC
        ELSE
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- Before calling ahl_generic_aprv_pvt.start_wf_process');
            END IF;
            ahl_generic_aprv_pvt.start_wf_process
            (
                P_OBJECT                => l_object,
                P_ACTIVITY_ID           => l_activity_id,
                P_APPROVAL_TYPE         => l_approval_type,
                P_OBJECT_VERSION_NUMBER => l_object_version_number,
                P_ORIG_STATUS_CODE      => 'DRAFT',
                P_NEW_STATUS_CODE       => 'COMPLETE',
                P_REJECT_STATUS_CODE    => 'APPROVAL_REJECTED',
                P_REQUESTER_USERID      => FND_GLOBAL.USER_ID,
                P_NOTES_FROM_REQUESTER  => null,
                P_WORKFLOWPROCESS       => l_process_name,
                P_ITEM_TYPE             => l_item_type
            );
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- After calling ahl_generic_aprv_pvt.start_wf_process');
            END IF;
        END IF;
    ELSE
        -- If workflow process is inactive, then force complete the PC

        IF ( p_x_pc_header_rec.LINK_TO_PC_ID IS NULL OR p_x_pc_header_rec.LINK_TO_PC_ID = 0 )
        THEN
            IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug('PCH -- PVT -- INITIATE_PC_APPROVAL -- This is not linked PC');
            END IF;

            l_object_version_number := p_x_pc_header_rec.OBJECT_VERSION_NUMBER + 1;

            UPDATE  AHL_PC_HEADERS_B
            SET     STATUS = 'COMPLETE',
                OBJECT_VERSION_NUMBER = l_object_version_number,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
            WHERE   PC_HEADER_ID = p_x_pc_header_rec.PC_HEADER_ID AND
                OBJECT_VERSION_NUMBER = p_x_pc_header_rec.OBJECT_VERSION_NUMBER;

                ELSE

            IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug('PCH -- PVT -- INITIATE_PC_APPROVAL -- This is linked PC');
            END IF;

            p_x_pc_header_rec.STATUS := 'COMPLETE';

            REMOVE_LINK
            (
                p_api_version,
                p_init_msg_list,
                p_commit,
                p_validation_level,
                p_x_pc_header_rec,
                x_return_status,
                x_msg_count,
                x_msg_data
            );

        END IF;

    END IF;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- INITIATE_PC_APPROVAL -- After PC Approval');
    END IF;

END INITIATE_PC_APPROVAL;

------------------------
-- VALIDATE_PC_HEADER --
------------------------
PROCEDURE VALIDATE_PC_HEADER (p_x_pc_header_rec IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC)
IS

-- veena : added nvl :to check for duplicate name for approval pending and complete pc

CURSOR check_name (p_name IN VARCHAR2, p_status IN VARCHAR2, p_pc_header_id IN NUMBER)
IS
    SELECT  'X'
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID <> nvl(p_pc_header_id,0) AND
        -- UPPER(NAME) = UPPER(p_name) AND
        NAME = p_name AND
        --STATUS = p_status AND
        DRAFT_FLAG <> 'Y';

CURSOR check_prod_type (p_prod_type IN VARCHAR2, p_pc_header_id IN NUMBER)
IS
    SELECT  'X'
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID <> p_pc_header_id AND
        PRIMARY_FLAG = 'Y' AND
        PRODUCT_TYPE_CODE like p_prod_type AND
        DRAFT_FLAG = 'N';

CURSOR check_unit_part_attached (p_prod_type IN VARCHAR2, p_header_id IN NUMBER)
IS
    -- Perf Fix - 4913818. Modified Query below to use Base Tables.
    /*
    SELECT  'X'
    FROM    AHL_PC_TREE_V
    WHERE   PC_HEADER_ID = p_header_id AND
        NODE_TYPE IN (G_PART, G_UNIT);
    */
    SELECT 'X'
    FROM   AHL_PC_ASSOCIATIONS AHS,
           AHL_PC_NODES_B NODE
    WHERE  NODE.PC_NODE_ID = AHS.PC_NODE_ID
      AND  NODE.PC_HEADER_ID = p_header_id;

l_dummy   VARCHAR2(30);


BEGIN

        IF p_x_pc_header_rec.OPERATION_FLAG NOT IN (AHL_PC_HEADER_PVT.G_DML_DELETE) THEN

            -- CHECK NAME UNIQUE
            OPEN check_name(p_pc_header_id  => p_x_pc_header_rec.PC_HEADER_ID,
                    p_name          => p_x_pc_header_rec.NAME,
                    p_status        => p_x_pc_header_rec.STATUS );
            FETCH check_name into l_dummy;
            IF (check_name%FOUND)
            THEN
                FND_MESSAGE.Set_Name('AHL','AHL_PC_NAME_EXISTS');
                FND_MSG_PUB.ADD;
                CLOSE check_name;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE check_name;

            -- CHECK PROD TYPE AND ASSOS TYPE
            IF (p_x_pc_header_rec.PRIMARY_FLAG = 'Y')
            THEN

                OPEN check_prod_type(   p_prod_type     => p_x_pc_header_rec.PRODUCT_TYPE_CODE,
                            p_pc_header_id  => p_x_pc_header_rec.PC_HEADER_ID );
                FETCH check_prod_type into l_dummy;
                IF (check_prod_type%FOUND)
                THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_PC_PROD_PRIM_EXISTS');
                    FND_MSG_PUB.ADD;
                    CLOSE check_prod_type;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                CLOSE check_prod_type;
            END IF;
        END IF;

END VALIDATE_PC_HEADER;

-----------------------------
-- GET_DUP_UNIT_ITEM_ASSOS --
-----------------------------
FUNCTION GET_DUP_UNIT_ITEM_ASSOS (p_pc_header_id IN NUMBER)
RETURN BOOLEAN
IS

l_unit_item_id      NUMBER;
l_num_nodes     NUMBER;

CURSOR get_dup_assos (p_pc_header_id IN NUMBER)
IS
    select  ahass.unit_item_id, count(ahass.pc_node_id)
    from    ahl_pc_headers_b head, ahl_pc_nodes_b node, ahl_pc_associations ahass
    where   ahass.pc_node_id = node.pc_node_id and
        node.pc_header_id = head.pc_header_id and
        head.pc_header_id = p_pc_header_id
    group by ahass.unit_item_id
    having count(ahass.pc_node_id) > 1;

BEGIN
    OPEN get_dup_assos (p_pc_header_id);
    FETCH get_dup_assos INTO l_unit_item_id, l_num_nodes;
    IF (get_dup_assos%FOUND)
    THEN
        CLOSE get_dup_assos;
        RETURN TRUE;
    ELSE
        CLOSE get_dup_assos;
        RETURN FALSE;
    END IF;

END GET_DUP_UNIT_ITEM_ASSOS;

------------------------
-- DELETE_PC_AND_TREE --
------------------------
PROCEDURE DELETE_PC_AND_TREE (p_pc_header_id IN NUMBER)
IS

TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_node_tbl T_ID_TBL;

BEGIN
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    --END IF;
    --IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_AND_TREE -- Reading PC Tree (Nodes)');
    END IF;

    SELECT PC_NODE_ID
    BULK COLLECT INTO l_node_tbl
    FROM AHL_PC_NODES_B
    WHERE PC_HEADER_ID = p_pc_header_id
    ORDER BY PC_NODE_ID DESC;

    IF (l_node_tbl.COUNT > 0)
    THEN
        FOR i IN l_node_tbl.FIRST..l_node_tbl.LAST
        LOOP
            IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_AND_TREE -- Handling force delete for Node ID='||l_node_tbl(i));
            END IF;

            -- Knocking off Doc Associations
            DELETE FROM AHL_DOC_TITLE_ASSOS_TL
            WHERE   DOC_TITLE_ASSO_ID IN (
                SELECT DOC_TITLE_ASSO_ID
                FROM   AHL_DOC_TITLE_ASSOS_B
                WHERE   ASO_OBJECT_TYPE_CODE = 'PC' and
                    ASO_OBJECT_ID = l_node_tbl(i)
            );

            DELETE FROM AHL_DOC_TITLE_ASSOS_B
            WHERE   ASO_OBJECT_TYPE_CODE = 'PC' and
                ASO_OBJECT_ID = l_node_tbl(i);

            -- Knocking off the Units / Parts
            DELETE FROM AHL_PC_ASSOCIATIONS
            WHERE PC_NODE_ID = l_node_tbl(i);

            -- Knocking off the node
            AHL_PC_NODES_PKG.DELETE_ROW(l_node_tbl(i));

        END LOOP;
    END IF;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_PC_AND_TREE -- Handling force delete for PC');
    END IF;
    -- Knocking off the PC
    AHL_PC_HEADERS_PKG.DELETE_ROW(p_pc_header_id);

END DELETE_PC_AND_TREE;

-----------------
-- CREATE_LINK --
-----------------
PROCEDURE CREATE_LINK
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC ,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

CURSOR copy_header_data(p_header_id IN NUMBER)
IS
    SELECT  *
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = p_header_id;

-- For Bug # 9486654 we split cursor  copy_nodes_data in to two cursors
-- Separately for nodes and units/parts as copy_nodes_data and copy_asso_data
CURSOR copy_nodes_data(p_header_id IN VARCHAR2)
IS
    -- Perf Bug Fix - 4913818
    -- Re-wrting Sql Query Below

    /*
    SELECT  *
    FROM    AHL_PC_TREE_V
    WHERE   PC_HEADER_ID = p_header_id
    ORDER BY PARENT_NODE_ID;
    */
   SELECT  AHNO.ROW_ID,
                AHNO.PC_NODE_ID,
                AHNO.OBJECT_VERSION_NUMBER,
                AHNO.LAST_UPDATE_DATE,
                AHNO.LAST_UPDATED_BY,
                AHNO.CREATION_DATE,
                AHNO.CREATED_BY,
                AHNO.LAST_UPDATE_LOGIN,
                AHNO.PC_HEADER_ID,
                AHNO.NAME,
                AHNO.PARENT_NODE_ID,
                AHNO.CHILD_COUNT,
                AHNO.LINK_TO_NODE_ID,
                AHNO.DRAFT_FLAG,
                AHNO.DESCRIPTION,
                'N' NODE_TYPE,
                0 UNIT_ITEM_ID,
                0 INVENTORY_ORG_ID,
                AHNO.OPERATION_STATUS_FLAG,
                AHNO.SECURITY_GROUP_ID,
                AHNO.ATTRIBUTE_CATEGORY,
                AHNO.ATTRIBUTE1,
                AHNO.ATTRIBUTE2,
                AHNO.ATTRIBUTE3,
                AHNO.ATTRIBUTE4,
                AHNO.ATTRIBUTE5,
                AHNO.ATTRIBUTE6,
                AHNO.ATTRIBUTE7,
                AHNO.ATTRIBUTE8,
                AHNO.ATTRIBUTE9,
                AHNO.ATTRIBUTE10,
                AHNO.ATTRIBUTE11,
                AHNO.ATTRIBUTE12,
                AHNO.ATTRIBUTE13,
                AHNO.ATTRIBUTE14,
                AHNO.ATTRIBUTE15
         FROM  AHL_PC_NODES_VL AHNO
         WHERE  AHNO.PC_HEADER_ID = p_header_id
	 START WITH PARENT_NODE_ID = 0
         CONNECT BY PRIOR PC_NODE_ID =  PARENT_NODE_ID;


  CURSOR copy_asso_data(p_header_id IN VARCHAR2)
	IS
        SELECT  DISTINCT AHS.ROWID ROW_ID,
                AHS.PC_ASSOCIATION_ID PC_NODE_ID,
                AHS.OBJECT_VERSION_NUMBER,
                AHS.LAST_UPDATE_DATE,
                AHS.LAST_UPDATED_BY,
                AHS.CREATION_DATE,
                AHS.CREATED_BY,
                AHS.LAST_UPDATE_LOGIN,
                NODE.PC_HEADER_ID,
                DECODE(AHS.ASSOCIATION_TYPE_FLAG,'U',UNIT.NAME,MTL.CONCATENATED_SEGMENTS) NAME,
                AHS.PC_NODE_ID PARENT_NODE_ID,
                0 CHILD_COUNT,
                AHS.LINK_TO_ASSOCIATION_ID LINK_TO_NODE_ID,
                AHS.DRAFT_FLAG,
                MTL.DESCRIPTION,
                AHS.ASSOCIATION_TYPE_FLAG NODE_TYPE,
                AHS.UNIT_ITEM_ID,
                AHS.INVENTORY_ORG_ID,
                AHS.OPERATION_STATUS_FLAG,
                AHS.SECURITY_GROUP_ID,
                AHS.ATTRIBUTE_CATEGORY,
                AHS.ATTRIBUTE1,
                AHS.ATTRIBUTE2,
                AHS.ATTRIBUTE3,
                AHS.ATTRIBUTE4,
                AHS.ATTRIBUTE5,
                AHS.ATTRIBUTE6,
                AHS.ATTRIBUTE7,
                AHS.ATTRIBUTE8,
                AHS.ATTRIBUTE9,
                AHS.ATTRIBUTE10,
                AHS.ATTRIBUTE11,
                AHS.ATTRIBUTE12,
                AHS.ATTRIBUTE13,
                AHS.ATTRIBUTE14,
                AHS.ATTRIBUTE15
          FROM  AHL_PC_ASSOCIATIONS AHS, AHL_UNIT_CONFIG_HEADERS UNIT,
                CSI_ITEM_INSTANCES CSI, MTL_SYSTEM_ITEMS_KFV MTL,
                AHL_PC_NODES_B NODE, AHL_PC_HEADERS_B HEADER
         WHERE  NODE.PC_HEADER_ID = HEADER.PC_HEADER_ID
           AND  NODE.PC_NODE_ID = AHS.PC_NODE_ID
           AND  HEADER.PC_HEADER_ID = p_header_id
           AND  UNIT.UNIT_CONFIG_HEADER_ID(+) = AHS.UNIT_ITEM_ID
           AND  UNIT.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID(+)
           AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.UNIT_ITEM_ID,
                                                 'U',CSI.INVENTORY_ITEM_ID) = MTL.INVENTORY_ITEM_ID
           -- SATHAPLI::Bug# 5576835, 20-Aug-2007
           /*
           AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',FND_PROFILE.VALUE('ORG_ID'),
                                                 'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
           */
           AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.INVENTORY_ORG_ID,
                                                 'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
           AND  DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',MTL.ITEM_TYPE,
                                                 'U',HEADER.PRODUCT_TYPE_CODE) = MTL.ITEM_TYPE;

CURSOR copy_document (p_node_id IN VARCHAR2)
IS
    SELECT  *
    FROM    AHL_DOC_TITLE_ASSOS_VL
    WHERE   ASO_OBJECT_TYPE_CODE ='PC' AND
        ASO_OBJECT_ID = p_node_id;

l_node_rec              AHL_PC_NODE_PUB.PC_NODE_REC;
l_assos_rec             AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC;
l_assos_doc_tbl             AHL_DI_ASSO_DOC_ASO_PVT.ASSOCIATION_TBL;
l_node_data_rec         copy_nodes_data%ROWTYPE;
l_assos_data_rec        copy_document%ROWTYPE;
--Bug # 9486654
l_node_asso_rec         copy_asso_data%ROWTYPE;

l_nodeId_tbl            PC_NODE_ID_TBL;

l_nodeCtr               NUMBER;
l_nc                    NUMBER;
l_old_header_id         NUMBER;
l_assosCtr          NUMBER;
l_dummy             VARCHAR2(30);

BEGIN


    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list)
    THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    END IF;

    l_old_header_id := p_x_pc_header_rec.PC_HEADER_ID;
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- Old Header ID='||l_old_header_id);
    END IF;

    UPDATE AHL_PC_HEADERS_B
    SET DRAFT_FLAG = 'Y'
    WHERE PC_HEADER_ID = l_old_header_id;

    p_x_pc_header_rec.LINK_TO_PC_ID     := l_old_header_id;
    p_x_pc_header_rec.DRAFT_FLAG        := 'N';
    p_x_pc_header_rec.STATUS            := 'DRAFT';
    p_x_pc_header_rec.OPERATION_FLAG    := AHL_PC_HEADER_PVT.G_DML_LINK;

    CREATE_PC_HEADER
    (
        p_api_version           => p_api_version,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => p_validation_level,
        p_x_pc_header_rec       => p_x_pc_header_rec,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
    );

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- New Header ID='||p_x_pc_header_rec.PC_HEADER_ID);
    END IF;

    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    l_nodeCtr :=0;
-- For Bug # 9486654 copy_nodes_data
    OPEN copy_nodes_data(l_old_header_id );
    LOOP
        FETCH copy_nodes_data INTO l_node_data_rec;
        EXIT WHEN copy_nodes_data%NOTFOUND;
        IF l_node_data_rec.node_type = G_NODE
        THEN
           IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- Creating node record for PC_NODE_ID='||l_node_data_rec.PC_NODE_ID);
	      AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- Creating node record for PC_HEADER_ID ='||l_node_data_rec.PC_HEADER_ID);
	      AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- Creating node record for PARENT_NODE_ID ='||l_node_data_rec.PARENT_NODE_ID);
            END IF;
            l_node_rec.PC_NODE_ID           := l_node_data_rec.PC_NODE_ID;
            l_node_rec.PC_HEADER_ID         := p_x_pc_header_rec.PC_HEADER_ID;
            l_node_rec.PARENT_NODE_ID       := l_node_data_rec.PARENT_NODE_ID;
            l_node_rec.CHILD_COUNT          := l_node_data_rec.CHILD_COUNT;
            l_node_rec.NAME             := l_node_data_rec.NAME;
            l_node_rec.DESCRIPTION          := l_node_data_rec.DESCRIPTION;
            l_node_rec.OPERATION_STATUS_FLAG    := AHL_PC_HEADER_PVT.G_DML_CREATE;
            l_node_rec.OBJECT_VERSION_NUMBER    := l_node_data_rec.OBJECT_VERSION_NUMBER;
            l_node_rec.DRAFT_FLAG           := 'N';
            l_node_rec.LINK_TO_NODE_ID      := l_node_data_rec.PC_NODE_ID;
            l_node_rec.OPERATION_FLAG       := AHL_PC_HEADER_PVT.G_DML_LINK;
            l_node_rec.ATTRIBUTE_CATEGORY       := l_node_data_rec.ATTRIBUTE_CATEGORY;
            l_node_rec.ATTRIBUTE1           := l_node_data_rec.ATTRIBUTE1;
            l_node_rec.ATTRIBUTE2           := l_node_data_rec.ATTRIBUTE2;
            l_node_rec.ATTRIBUTE3           := l_node_data_rec.ATTRIBUTE3;
            l_node_rec.ATTRIBUTE4           := l_node_data_rec.ATTRIBUTE4;
            l_node_rec.ATTRIBUTE5           := l_node_data_rec.ATTRIBUTE5;
            l_node_rec.ATTRIBUTE6           := l_node_data_rec.ATTRIBUTE6;
            l_node_rec.ATTRIBUTE7           := l_node_data_rec.ATTRIBUTE7;
            l_node_rec.ATTRIBUTE8           := l_node_data_rec.ATTRIBUTE8;
            l_node_rec.ATTRIBUTE9           := l_node_data_rec.ATTRIBUTE9;
            l_node_rec.ATTRIBUTE10          := l_node_data_rec.ATTRIBUTE10;
            l_node_rec.ATTRIBUTE11          := l_node_data_rec.ATTRIBUTE11;
            l_node_rec.ATTRIBUTE12          := l_node_data_rec.ATTRIBUTE12;
            l_node_rec.ATTRIBUTE13          := l_node_data_rec.ATTRIBUTE13;
            l_node_rec.ATTRIBUTE14          := l_node_data_rec.ATTRIBUTE14;
            l_node_rec.ATTRIBUTE15          := l_node_data_rec.ATTRIBUTE15;

            UPDATE AHL_PC_NODES_B
            SET DRAFT_FLAG = 'Y'
            WHERE PC_NODE_ID = l_node_data_rec.PC_NODE_ID;

        END IF;
        IF l_nodeCtr = 0
        THEN
            l_node_rec.PARENT_NODE_ID := 0;
        ELSE
            FOR l_nc IN 0..l_nodeCtr
            LOOP
                IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- nodes:INDEXl_nc : '||l_nc);
 		AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK in the before first IF condition: l_nodeId_tbl(l_nc).NODE_ID '|| l_nodeId_tbl(l_nc).NODE_ID );
		END IF;
               IF l_nodeId_tbl(l_nc).NODE_ID = l_node_data_rec.PARENT_NODE_ID
                THEN
		    IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK in the first IF condition: l_nodeId_tbl(l_nc).NODE_ID ');
		    END IF;
                    IF l_node_data_rec.node_type = G_NODE
                    THEN
                        l_node_rec.PARENT_NODE_ID := l_nodeId_tbl(l_nc).NEW_NODE_ID;
		     IF G_DEBUG='Y' THEN
		     AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK in the Second IF condition:After copy l_nodeId_tbl(l_nc).NEW_NODE_ID '|| l_nodeId_tbl(l_nc).NEW_NODE_ID );
		     END IF;
                        EXIT;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF l_node_data_rec.node_type = G_NODE
        THEN
	   IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- before call to AHL_PC_NODE_PVT.CREATE_NODE : l_node_data_rec.PC_NODE_ID'|| l_node_rec.PC_NODE_ID);
           END IF;

            AHL_PC_NODE_PVT.CREATE_NODE
            (
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_node_rec        => l_node_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );

            l_nodeId_tbl(l_nodeCtr).NODE_ID         := l_node_data_rec.PC_NODE_ID;
            l_nodeId_tbl(l_nodeCtr).NEW_NODE_ID     := l_node_rec.PC_NODE_ID;
            l_nodeCtr                           := l_nodeCtr + 1;

	   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- After call to AHL_PC_NODE_PVT.CREATE_NODE : l_nodeCtr'||l_nodeCtr);
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- After call to AHL_PC_NODE_PVT.CREATE_NODE : l_node_data_rec.PC_NODE_ID'|| l_node_rec.PC_NODE_ID);
           END IF;

            x_msg_count := FND_MSG_PUB.count_msg;
            IF x_msg_count > 0
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- after raising exceptions: After Create Node');
	    END IF;

            l_assosCtr:=0;
            OPEN copy_document(l_node_data_rec.PC_NODE_ID);
            LOOP
                FETCH copy_document INTO l_assos_data_rec;
                EXIT WHEN copy_document%NOTFOUND;
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- Creating doc record for ID='||l_assos_data_rec.DOCUMENT_ID);
                END IF;
                l_assosCtr := l_assosCtr + 1;
                l_assos_doc_tbl(l_assosCtr).DOC_TITLE_ASSO_ID       := null;
                l_assos_doc_tbl(l_assosCtr).DOCUMENT_ID             := l_assos_data_rec.DOCUMENT_ID         ;
                l_assos_doc_tbl(l_assosCtr).DOC_REVISION_ID         := l_assos_data_rec.DOC_REVISION_ID     ;
                l_assos_doc_tbl(l_assosCtr).USE_LATEST_REV_FLAG     := l_assos_data_rec.USE_LATEST_REV_FLAG ;
                l_assos_doc_tbl(l_assosCtr).ASO_OBJECT_TYPE_CODE    := l_assos_data_rec.ASO_OBJECT_TYPE_CODE;
                l_assos_doc_tbl(l_assosCtr).ASO_OBJECT_ID           := l_node_rec.PC_NODE_ID;
                l_assos_doc_tbl(l_assosCtr).SERIAL_NO               := l_assos_data_rec.SERIAL_NO           ;
                l_assos_doc_tbl(l_assosCtr).CHAPTER                 := l_assos_data_rec.CHAPTER             ;
                l_assos_doc_tbl(l_assosCtr).SECTION                 := l_assos_data_rec.SECTION             ;
                l_assos_doc_tbl(l_assosCtr).SUBJECT                 := l_assos_data_rec.SUBJECT             ;
                l_assos_doc_tbl(l_assosCtr).PAGE                    := l_assos_data_rec.PAGE                ;
                l_assos_doc_tbl(l_assosCtr).FIGURE                  := l_assos_data_rec.FIGURE              ;
                l_assos_doc_tbl(l_assosCtr).NOTE                    := l_assos_data_rec.NOTE                ;
                l_assos_doc_tbl(l_assosCtr).OBJECT_VERSION_NUMBER   := l_assos_data_rec.OBJECT_VERSION_NUMBER ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE_CATEGORY      := l_assos_data_rec.ATTRIBUTE_CATEGORY  ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE1              := l_assos_data_rec.ATTRIBUTE1          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE2              := l_assos_data_rec.ATTRIBUTE2          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE3              := l_assos_data_rec.ATTRIBUTE3          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE4              := l_assos_data_rec.ATTRIBUTE4          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE5              := l_assos_data_rec.ATTRIBUTE5          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE6              := l_assos_data_rec.ATTRIBUTE6          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE7              := l_assos_data_rec.ATTRIBUTE7          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE8              := l_assos_data_rec.ATTRIBUTE8          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE9              := l_assos_data_rec.ATTRIBUTE9          ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE10             := l_assos_data_rec.ATTRIBUTE10         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE11             := l_assos_data_rec.ATTRIBUTE11         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE12             := l_assos_data_rec.ATTRIBUTE12         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE13             := l_assos_data_rec.ATTRIBUTE13         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE14             := l_assos_data_rec.ATTRIBUTE14         ;
                l_assos_doc_tbl(l_assosCtr).ATTRIBUTE15             := l_assos_data_rec.ATTRIBUTE15         ;

            END LOOP;
            CLOSE copy_document;

            IF l_assosCtr > 0
            THEN
                AHL_DI_ASSO_DOC_ASO_PVT.CREATE_ASSOCIATION
                (
                    p_api_version           => 1.0,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit        => FND_API.G_FALSE,
                    p_validation_level  => p_validation_level,
                    p_x_association_tbl => l_assos_doc_tbl,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data
                );
            END IF;
        END IF;

    END LOOP; --copy_nodes_data

-- For Bug # 9486654  copy_asso_data
    OPEN copy_asso_data(l_old_header_id );
    LOOP
        FETCH copy_asso_data INTO l_node_asso_rec;
        EXIT WHEN copy_asso_data%NOTFOUND;

        IF l_node_asso_rec.node_type IN (G_PART,G_UNIT)
        THEN
            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- Creating unit/part record for ID='||l_node_asso_rec.PC_NODE_ID);
            END IF;
            l_assos_rec.PC_ASSOCIATION_ID       := l_node_asso_rec.PC_NODE_ID;
            l_assos_rec.UNIT_ITEM_ID        := l_node_asso_rec.UNIT_ITEM_ID;
            l_assos_rec.INVENTORY_ORG_ID        := l_node_asso_rec.INVENTORY_ORG_ID;
            l_assos_rec.ASSOCIATION_TYPE_FLAG   := l_node_asso_rec.NODE_TYPE;
            l_assos_rec.OPERATION_STATUS_FLAG   := AHL_PC_HEADER_PVT.G_DML_CREATE;
            l_assos_rec.DRAFT_FLAG          := 'N';
            l_assos_rec.LINK_TO_ASSOCIATION_ID  := l_node_asso_rec.PC_NODE_ID;
            l_assos_rec.OPERATION_FLAG      := AHL_PC_HEADER_PVT.G_DML_LINK;
            l_assos_rec.ATTRIBUTE_CATEGORY      := l_node_asso_rec.ATTRIBUTE_CATEGORY;
            l_assos_rec.ATTRIBUTE1          := l_node_asso_rec.ATTRIBUTE1;
            l_assos_rec.ATTRIBUTE2          := l_node_asso_rec.ATTRIBUTE2;
            l_assos_rec.ATTRIBUTE3          := l_node_asso_rec.ATTRIBUTE3;
            l_assos_rec.ATTRIBUTE4          := l_node_asso_rec.ATTRIBUTE4;
            l_assos_rec.ATTRIBUTE5          := l_node_asso_rec.ATTRIBUTE5;
            l_assos_rec.ATTRIBUTE6          := l_node_asso_rec.ATTRIBUTE6;
            l_assos_rec.ATTRIBUTE7          := l_node_asso_rec.ATTRIBUTE7;
            l_assos_rec.ATTRIBUTE8          := l_node_asso_rec.ATTRIBUTE8;
            l_assos_rec.ATTRIBUTE9          := l_node_asso_rec.ATTRIBUTE9;
            l_assos_rec.ATTRIBUTE10         := l_node_asso_rec.ATTRIBUTE10;
            l_assos_rec.ATTRIBUTE11         := l_node_asso_rec.ATTRIBUTE11;
            l_assos_rec.ATTRIBUTE12         := l_node_asso_rec.ATTRIBUTE12;
            l_assos_rec.ATTRIBUTE13         := l_node_asso_rec.ATTRIBUTE13;
            l_assos_rec.ATTRIBUTE14         := l_node_asso_rec.ATTRIBUTE14;
            l_assos_rec.ATTRIBUTE15         := l_node_asso_rec.ATTRIBUTE15;

            UPDATE AHL_PC_ASSOCIATIONS
            SET DRAFT_FLAG = 'Y'
            WHERE PC_ASSOCIATION_ID = l_node_asso_rec.PC_NODE_ID;

        END IF;

	 FOR l_nc IN 0..l_nodeCtr
            LOOP
	        IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- units:INDEXl_nc : '||l_nc);
 		AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK in the before first IF condition: l_nodeId_tbl(l_nc).NODE_ID '|| l_nodeId_tbl(l_nc).NODE_ID );
		END IF;
               IF l_nodeId_tbl(l_nc).NODE_ID = l_node_asso_rec.PARENT_NODE_ID
                THEN
                   IF l_node_asso_rec.node_type IN (G_PART, G_UNIT)
                    THEN
                        l_assos_rec.PC_NODE_ID := l_nodeId_tbl(l_nc).NEW_NODE_ID;
			IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK in the  units case IF condition:After copy l_nodeId_tbl(l_nc).NEW_NODE_ID '|| l_nodeId_tbl(l_nc).NEW_NODE_ID );
			END IF;
                        EXIT;
                    END IF;
                END IF;
         END LOOP;

     IF l_node_asso_rec.node_type = G_UNIT
        THEN
 	   IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- before call to AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT : l_node_asso_rec.PC_NODE_ID'|| l_assos_rec.PC_NODE_ID);
           END IF;
           AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT(
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_assos_rec       => l_assos_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );
	   IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- After call to AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT : l_node_asso_rec.PC_NODE_ID'|| l_assos_rec.PC_NODE_ID);
		  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- After call to AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT : l_node_asso_rec.PC_ASSOCIATION_ID'|| l_assos_rec.PC_ASSOCIATION_ID);

           END IF;

	ELSIF l_node_asso_rec.node_type = G_PART
        THEN
 	   IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- before call to AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM : l_node_asso_rec.PC_NODE_ID'|| l_assos_rec.PC_NODE_ID);
           END IF;
            AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM(
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_assos_rec       => l_assos_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );
	   IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- After call to AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM: l_node_asso_rec.PC_NODE_ID'|| l_assos_rec.PC_NODE_ID);
		  AHL_DEBUG_PUB.debug('PCH -- PVT -- CREATE_LINK -- After call to AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM : l_node_asso_rec.PC_ASSOCIATION_ID'|| l_assos_rec.PC_ASSOCIATION_ID);

           END IF;

        END IF;

      END LOOP; --copy_units_data




END CREATE_LINK;


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

------------------------------
-- DELETE_NODES_REMOVE_LINK --
------------------------------
PROCEDURE DELETE_NODES_REMOVE_LINK (p_x_node_rec IN AHL_PC_NODE_PUB.PC_NODE_REC)
IS

TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_node_id           NUMBER;
l_linked_node_id        NUMBER;
l_exist                         VARCHAR2(1);
l_ump_node_attached     VARCHAR2(1)     := FND_API.G_FALSE;
l_ump_unit_attached     VARCHAR2(1)     := FND_API.G_FALSE;
l_ump_part_attached     VARCHAR2(1)     := FND_API.G_FALSE;
l_fmp_attached          VARCHAR2(1)     := FND_API.G_FALSE;
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

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_NODES_REMOVE_LINK reading child-node-tree');
    END IF;

    SELECT pc_node_id
    BULK COLLECT
    INTO l_node_tbl
    FROM ahl_pc_nodes_b
    WHERE pc_header_id = p_x_node_rec.pc_header_id
    CONNECT BY parent_node_id = PRIOR pc_node_id
    START WITH pc_node_id = l_node_id
    ORDER BY pc_node_id DESC;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_NODES_REMOVE_LINK reading association-tree');
    END IF;

    SELECT pc_association_id
    BULK COLLECT INTO l_assos_tbl
    FROM ahl_pc_associations ahass
    WHERE pc_node_id IN (
        SELECT pc_node_id
        FROM ahl_pc_nodes_b
        WHERE pc_header_id = p_x_node_rec.pc_header_id
        CONNECT BY parent_node_id = PRIOR pc_node_id
        START WITH pc_node_id = l_node_id
    );

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_NODES_REMOVE_LINK retrieving linked_node_id which will have FMP, UMP and Doc associations');
    END IF;

    If(l_assos_tbl.COUNT > 0)
    THEN
            FOR i IN l_assos_tbl.FIRST..l_assos_tbl.LAST
            LOOP
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCN -- PVT -- Knocking off unit/part associations for unit_item_id='||l_assos_tbl(i));
                END IF;

                -- Knocking off unit/part associations...
                DELETE
                FROM ahl_pc_associations
                WHERE pc_association_id = l_assos_tbl(i);
            END LOOP;
    END IF;

    IF (l_node_tbl.COUNT > 0)
    THEN
            FOR j IN l_node_tbl.FIRST..l_node_tbl.LAST
            LOOP
                IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('PCN -- PVT -- Knocking off doc associations from PC nodes for pc_node_id='||get_linked_node_id(l_node_tbl(j)));
                END IF;

                l_linked_node_id := GET_LINKED_NODE_ID(l_node_tbl(j));

                -- Knocking off doc associations from PC nodes...
                DELETE
                FROM AHL_DOC_TITLE_ASSOS_TL
                WHERE   DOC_TITLE_ASSO_ID IN (
                    SELECT DOC_TITLE_ASSO_ID
                    FROM   AHL_DOC_TITLE_ASSOS_B
                    WHERE   aso_object_type_code = 'PC' and
                        aso_object_id = l_linked_node_id
                );

                DELETE
                FROM AHL_DOC_TITLE_ASSOS_B
                WHERE   aso_object_type_code = 'PC' and
                    aso_object_id = l_linked_node_id;

                -- Knocking off nodes...
                AHL_PC_NODES_PKG.DELETE_ROW(l_node_tbl(j));
            END LOOP;
    END IF;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DELETE_NODES_REMOVE_LINK for pc_node_id='||p_x_node_rec.PC_NODE_ID);
    END IF;

    IF ((l_node_tbl.COUNT > 0) AND (p_x_node_rec.pc_node_id IS NOT NULL))
    THEN
            UPDATE ahl_pc_nodes_b
            SET child_count = NVL(child_count,1) - 1
            WHERE pc_node_id = p_x_node_rec.parent_node_id;
    END IF;

END DELETE_NODES_REMOVE_LINK;

-----------------------------
-- DETACH_UNIT_REMOVE_LINK --
-----------------------------
PROCEDURE DETACH_UNIT_REMOVE_LINK (p_x_assos_rec IN AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC)
IS



BEGIN
    -- Knocking off units...
    DELETE FROM AHL_PC_ASSOCIATIONS
    WHERE PC_ASSOCIATION_ID = p_x_assos_rec.PC_ASSOCIATION_ID;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DETACH_UNIT_REMOVE_LINK for ID='||p_x_assos_rec.PC_ASSOCIATION_ID);
    END IF;

    UPDATE ahl_pc_nodes_b
    SET child_count = NVL(child_count, 1) - 1
    WHERE pc_node_id = p_x_assos_rec.pc_node_id;

END DETACH_UNIT_REMOVE_LINK;

-----------------------------
-- DETACH_ITEM_REMOVE_LINK --
-----------------------------
PROCEDURE DETACH_ITEM_REMOVE_LINK (p_x_assos_rec IN AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC)
IS

BEGIN
    -- Knocking off items...
    DELETE FROM AHL_PC_ASSOCIATIONS
    WHERE PC_ASSOCIATION_ID = p_x_assos_rec.PC_ASSOCIATION_ID;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- DETACH_ITEM_REMOVE_LINK for ID='||p_x_assos_rec.PC_ASSOCIATION_ID);
    END IF;

    UPDATE ahl_pc_nodes_b
    SET child_count = NVL(child_count, 1) - 1
    WHERE pc_node_id = p_x_assos_rec.pc_node_id;

END DETACH_ITEM_REMOVE_LINK;

-----------------
-- REMOVE_LINK --
-----------------
PROCEDURE REMOVE_LINK
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC ,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

-- To address the Bug # 9486654 The following cursor attach_nodes split in to two
-- cursors attach_nodes and attach_nodes_units.

CURSOR attach_nodes(p_header_id in number)
IS
    -- SATHAPLI :: Bug#4913818 fix --
    /*
    SELECT  *
    FROM    AHL_PC_TREE_V TREE
    WHERE   TREE.PC_HEADER_ID = p_header_id AND
        (
            TREE.NODE_TYPE='N' OR
            (
                TREE.NODE_TYPE <> 'N' AND
                TREE.LINK_TO_NODE_ID = 0 AND
                -- PARENT NODE ID IS NOT IN THE LIST OF NEWLY ATTACHED NODES
                TREE.PARENT_NODE_ID NOT IN
                (
                    SELECT NODE.PC_NODE_ID
                    FROM AHL_PC_NODES_B NODE
                    WHERE NODE.PC_NODE_ID = TREE.PARENT_NODE_ID AND
                          NODE.LINK_TO_NODE_ID = 0
                )
            )
         )
    ORDER BY TREE.PARENT_NODE_ID ;
    */

	SELECT AHNO.PC_NODE_ID,
                   AHNO.PC_HEADER_ID,
                   AHNO.NAME,
                   AHNO.PARENT_NODE_ID,
                   AHNO.CHILD_COUNT,
                   AHNO.LINK_TO_NODE_ID,
                   AHNO.DESCRIPTION,
                   'N' NODE_TYPE,
                   0 UNIT_ITEM_ID,
                   0 INVENTORY_ORG_ID,
                   AHNO.ATTRIBUTE_CATEGORY,
                   AHNO.ATTRIBUTE1,
                   AHNO.ATTRIBUTE2,
                   AHNO.ATTRIBUTE3,
                   AHNO.ATTRIBUTE4,
                   AHNO.ATTRIBUTE5,
                   AHNO.ATTRIBUTE6,
                   AHNO.ATTRIBUTE7,
                   AHNO.ATTRIBUTE8,
                   AHNO.ATTRIBUTE9,
                   AHNO.ATTRIBUTE10,
                   AHNO.ATTRIBUTE11,
                   AHNO.ATTRIBUTE12,
                   AHNO.ATTRIBUTE13,
                   AHNO.ATTRIBUTE14,
                   AHNO.ATTRIBUTE15
            FROM   AHL_PC_NODES_VL AHNO
            WHERE  AHNO.PC_HEADER_ID = p_header_id
	  START WITH AHNO.PARENT_NODE_ID = 0
	  CONNECT BY PRIOR AHNO.PC_NODE_ID = AHNO.PARENT_NODE_ID;

CURSOR attach_nodes_units(p_header_id in number)
IS
 SELECT * FROM (SELECT AHS.PC_ASSOCIATION_ID PC_NODE_ID,
                   NODE.PC_HEADER_ID,
                   DECODE(AHS.ASSOCIATION_TYPE_FLAG,'U',UNIT.NAME,MTL.CONCATENATED_SEGMENTS) NAME,
                   AHS.PC_NODE_ID PARENT_NODE_ID,
                   0 CHILD_COUNT,
                   AHS.LINK_TO_ASSOCIATION_ID LINK_TO_NODE_ID,
                   MTL.DESCRIPTION,
                   AHS.ASSOCIATION_TYPE_FLAG NODE_TYPE,
                   AHS.UNIT_ITEM_ID,
                   AHS.INVENTORY_ORG_ID,
                   AHS.ATTRIBUTE_CATEGORY,
                   AHS.ATTRIBUTE1,
                   AHS.ATTRIBUTE2,
                   AHS.ATTRIBUTE3,
                   AHS.ATTRIBUTE4,
                   AHS.ATTRIBUTE5,
                   AHS.ATTRIBUTE6,
                   AHS.ATTRIBUTE7,
                   AHS.ATTRIBUTE8,
                   AHS.ATTRIBUTE9,
                   AHS.ATTRIBUTE10,
                   AHS.ATTRIBUTE11,
                   AHS.ATTRIBUTE12,
                   AHS.ATTRIBUTE13,
                   AHS.ATTRIBUTE14,
                   AHS.ATTRIBUTE15
            FROM   AHL_PC_ASSOCIATIONS AHS, AHL_UNIT_CONFIG_HEADERS UNIT,
                   CSI_ITEM_INSTANCES CSI, MTL_SYSTEM_ITEMS_KFV MTL,
                   AHL_PC_NODES_B NODE, AHL_PC_HEADERS_B HEADER
            WHERE  NODE.PC_NODE_ID = AHS.PC_NODE_ID
            AND    HEADER.PC_HEADER_ID = NODE.PC_HEADER_ID
            AND    NODE.PC_HEADER_ID = p_header_id
            AND    UNIT.UNIT_CONFIG_HEADER_ID(+) = AHS.UNIT_ITEM_ID
            AND    UNIT.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID(+)
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.UNIT_ITEM_ID,
                                                    'U',CSI.INVENTORY_ITEM_ID) = MTL.INVENTORY_ITEM_ID
            -- SATHAPLI::Bug# 5576835, 20-Aug-2007
            /*
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',FND_PROFILE.VALUE('ORG_ID'),
                                                    'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
            */
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.INVENTORY_ORG_ID,
                                                    'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',MTL.ITEM_TYPE,
                                                    'U',HEADER.PRODUCT_TYPE_CODE) = MTL.ITEM_TYPE
           ) TREE
    WHERE (
             TREE.NODE_TYPE <> 'N' AND
             TREE.LINK_TO_NODE_ID = 0 AND
             -- PARENT NODE ID IS NOT IN THE LIST OF NEWLY ATTACHED NODES
             NOT EXISTS
             (
              SELECT 'X'
              FROM   AHL_PC_NODES_B NODE
              WHERE  NODE.PC_NODE_ID = TREE.PARENT_NODE_ID AND
                     NODE.LINK_TO_NODE_ID = 0
             )
           );

CURSOR detach_nodes(p_header_id in number, p_link_header_id in number)
IS
    -- SATHAPLI :: Bug#4913818 fix --
    /*
    SELECT  *
    FROM  AHL_PC_TREE_V TREE
    WHERE TREE.PC_HEADER_ID = p_link_header_id AND
    -- NODE ID NOT FOUND IN LINKED PC - i.e. NODE HAS BEEN DELETED
          TREE.PC_NODE_ID NOT IN
          (
           SELECT TREE1.LINK_TO_NODE_ID
           FROM AHL_PC_TREE_V TREE1
           WHERE TREE1.PC_HEADER_ID = p_header_id
          )
          -- OR( TREE.PC_NODE_ID = p_link_header_id AND PARENT_NODE_ID <> 0) --
          --   ) --
          AND
          (
           -- NODE IS ROOT NODE
           TREE.PARENT_NODE_ID = 0 OR
           -- PARENT NODE ID IS NOT IN THE LIST OF DELETED NODES
           -- AS IF PARENT IS BEING DELETED THE CHILD WILL AUTOMATICALLY GETS DELETED
           TREE.PARENT_NODE_ID IN
           (
            SELECT TREE1.LINK_TO_NODE_ID
            FROM AHL_PC_TREE_V TREE1
            WHERE TREE1.PC_HEADER_ID = p_header_id
           )
          )
    ORDER BY TREE.PARENT_NODE_ID;
    */

    SELECT *
    FROM   (
            SELECT AHNO.PC_NODE_ID,
                   AHNO.OBJECT_VERSION_NUMBER,
                   AHNO.PC_HEADER_ID,
                   AHNO.NAME,
                   AHNO.PARENT_NODE_ID,
                   AHNO.CHILD_COUNT,
                   AHNO.DESCRIPTION,
                   'N' NODE_TYPE,
                   0 UNIT_ITEM_ID,
                   0 INVENTORY_ORG_ID
            FROM   AHL_PC_NODES_VL AHNO
            UNION
            SELECT AHS.PC_ASSOCIATION_ID PC_NODE_ID,
                   AHS.OBJECT_VERSION_NUMBER,
                   NODE.PC_HEADER_ID,
                   DECODE(AHS.ASSOCIATION_TYPE_FLAG,'U',UNIT.NAME,MTL.CONCATENATED_SEGMENTS) NAME,
                   AHS.PC_NODE_ID PARENT_NODE_ID,
                   0 CHILD_COUNT,
                   MTL.DESCRIPTION,
                   AHS.ASSOCIATION_TYPE_FLAG NODE_TYPE,
                   AHS.UNIT_ITEM_ID,
                   AHS.INVENTORY_ORG_ID
            FROM   AHL_PC_ASSOCIATIONS AHS, AHL_UNIT_CONFIG_HEADERS UNIT,
                   CSI_ITEM_INSTANCES CSI, MTL_SYSTEM_ITEMS_KFV MTL,
                   AHL_PC_NODES_B NODE, AHL_PC_HEADERS_B HEADER
            WHERE  NODE.PC_NODE_ID = AHS.PC_NODE_ID
            AND    HEADER.PC_HEADER_ID = NODE.PC_HEADER_ID
            AND    UNIT.UNIT_CONFIG_HEADER_ID(+) = AHS.UNIT_ITEM_ID
            AND    UNIT.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID(+)
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.UNIT_ITEM_ID,
                                                    'U',CSI.INVENTORY_ITEM_ID) = MTL.INVENTORY_ITEM_ID
            -- SATHAPLI::Bug# 5576835, 20-Aug-2007
            /*
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',FND_PROFILE.VALUE('ORG_ID'),
                                                    'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
            */
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',AHS.INVENTORY_ORG_ID,
                                                    'U',CSI.INV_MASTER_ORGANIZATION_ID) = MTL.ORGANIZATION_ID
            AND    DECODE(AHS.ASSOCIATION_TYPE_FLAG,'I',MTL.ITEM_TYPE,
                                                    'U',HEADER.PRODUCT_TYPE_CODE) = MTL.ITEM_TYPE
           ) TREE
    WHERE  TREE.PC_HEADER_ID = p_link_header_id AND
           -- NODE ID NOT FOUND IN LINKED PC - i.e. NODE HAS BEEN DELETED
           NOT EXISTS
           (
	   -- Changes by skpathak on 27-NOV-2008 for bug 7512088
            -- If the table AHL_PC_ASSOCIATIONS does not have any records,
            -- the following this sub query does not bring any rows even
            -- if all other conditions are met. Hence changing this into a union
            -- of two queries
            /*
            SELECT 'X'
            FROM   AHL_PC_ASSOCIATIONS ASSOC,AHL_PC_NODES_B NODE
            WHERE  NODE.PC_HEADER_ID = p_header_id
            AND    (
	            (TREE.NODE_TYPE = 'N' AND
	             TREE.PC_NODE_ID = NODE.LINK_TO_NODE_ID)
                    OR
		    (TREE.NODE_TYPE IN ('I', 'U') AND
		     ASSOC.PC_NODE_ID = NODE.PC_NODE_ID AND
	             TREE.PC_NODE_ID = ASSOC.LINK_TO_ASSOCIATION_ID)
		   )
*/
            SELECT 'X'
              FROM AHL_PC_NODES_B NODE
             WHERE NODE.PC_HEADER_ID = p_header_id
               AND TREE.NODE_TYPE = 'N'
	       AND TREE.PC_NODE_ID = NODE.LINK_TO_NODE_ID
	    UNION ALL
            SELECT 'X'
              FROM AHL_PC_NODES_B NODE, AHL_PC_ASSOCIATIONS ASSOC
             WHERE NODE.PC_HEADER_ID = p_header_id
               AND TREE.NODE_TYPE IN ('I', 'U')
	       AND ASSOC.PC_NODE_ID = NODE.PC_NODE_ID
	       AND TREE.PC_NODE_ID = ASSOC.LINK_TO_ASSOCIATION_ID
           )
           AND
           (
            -- NODE IS ROOT NODE
            TREE.PARENT_NODE_ID = 0 OR
            -- PARENT NODE ID IS NOT IN THE LIST OF DELETED NODES
            -- AS IF PARENT IS BEING DELETED THE CHILD WILL AUTOMATICALLY GETS DELETED
            EXISTS
            (
             SELECT 'X'
             FROM   AHL_PC_NODES_B NODE
             WHERE  NODE.PC_HEADER_ID = p_header_id
             AND    TREE.PARENT_NODE_ID = NODE.LINK_TO_NODE_ID
            )
           )
    ORDER BY TREE.PARENT_NODE_ID;

CURSOR detach_associations(p_header_id in number, p_link_header_id in number)
IS
    SELECT * FROM ahl_pc_associations
    WHERE pc_node_id in ( SELECT PC_NODE_ID
                       FROM ahl_pc_nodes_b
                       WHERE PC_HEADER_ID = p_link_header_id)
    AND pc_association_id NOT IN (
                        SELECT LINK_TO_ASSOCIATION_ID
                        FROM ahl_pc_associations
                        WHERE pc_node_id IN ( SELECT PC_NODE_ID
                                              FROM  ahl_pc_nodes_b
                                              WHERE PC_HEADER_ID = p_header_id));


CURSOR delete_header(p_link_header_id in number)
IS
    SELECT  'X'
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = p_link_header_id;


CURSOR get_mr_for_pc (c_pc_header_id number)
IS
    select  mrh.mr_header_id, mrh.title, mrh.version_number
    from    ahl_mr_headers_app_v mrh, ahl_mr_effectivities mre, ahl_pc_nodes_b pcn
    where   trunc(sysdate) < trunc(nvl(mrh.effective_to, sysdate+1)) and
        mrh.mr_header_id = mre.mr_header_id and
        mre.pc_node_id = pcn.pc_node_id and
        pcn.pc_header_id = c_pc_header_id;
    /* Commented following code to optimize
    select  fmp.mr_header_id, fmp.title, fmp.version_number
    from    ahl_mr_pc_nodes_v fmp, ahl_pc_nodes_b node
    where   fmp.pc_node_id = node.pc_node_id and
        node.pc_header_id = c_pc_header_id;
    */

-- SATHAPLI::Bug# 6504069, 26-Mar-2008
-- cursor to get all the applicable MRs for a given PC header id
CURSOR get_mr_for_pc_csr (p_pc_header_id NUMBER) IS
    SELECT mrh.mr_header_id, mre.mr_effectivity_id
    FROM   ahl_mr_headers_b mrh, ahl_mr_effectivities mre,
           ahl_pc_nodes_b pcn
    WHERE  mrh.mr_header_id = mre.mr_header_id
    AND    mre.pc_node_id   = pcn.pc_node_id
    AND    pcn.pc_header_id = p_pc_header_id
    AND    TRUNC(NVL(mrh.effective_to, SYSDATE+1)) > TRUNC(SYSDATE);

l_node_rec          AHL_PC_NODE_PUB.PC_NODE_REC;
l_assos_rec         AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC;
l_assos_doc_tbl         AHL_DI_ASSO_DOC_ASO_PVT.ASSOCIATION_TBL;

l_node_data_rec     attach_nodes%ROWTYPE;
l_node_units_data_rec     attach_nodes_units%ROWTYPE;
l_node_data_rec_det     detach_nodes%ROWTYPE;
l_asso_data_rec_det     detach_associations%ROWTYPE;

l_pc_header_rec     AHL_PC_HEADER_PUB.PC_HEADER_REC;
l_nodeId_tbl            PC_NODE_ID_TBL;

-- Senthil
TYPE l_num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_draft_nodeId_tbl  l_num_tbl;
l_comp_nodeId_tbl  l_num_tbl;

l_node_id       NUMBER;
l_old_node_id       NUMBER;
l_parent_node_id    NUMBER;
l_dummy         VARCHAR2(30);
l_nodeCtr           NUMBER;
l_pc_header_id      NUMBER;
l_link_to_pc_id     NUMBER;
l_nc                NUMBER;
l_header_obj_ver_num    NUMBER;

l_mr_id                 NUMBER;
l_mr_title          VARCHAR2(80);
l_mr_version            NUMBER;

-- SATHAPLI::Bug# 6504069, 26-Mar-2008
l_api_name     CONSTANT VARCHAR2(30) := 'Remove_Link';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

TYPE MR_ITM_INST_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_link_mr_item_inst_tbl MR_ITM_INST_TBL_TYPE;
l_new_mr_item_inst_tbl  MR_ITM_INST_TBL_TYPE;
l_diff_mr_item_inst_tbl MR_ITM_INST_TBL_TYPE;
l_get_mr_for_pc_rec     get_mr_for_pc_csr%ROWTYPE;
l_mr_item_inst_tbl      AHL_FMP_PVT.MR_ITEM_INSTANCE_TBL_TYPE;
indx                    NUMBER;
l_req_id                NUMBER;

BEGIN

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list)
    THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_full_name,'Start of the API');
    END IF;

    IF ( p_x_pc_header_rec.LINK_TO_PC_ID IS NULL OR p_x_pc_header_rec.LINK_TO_PC_ID = 0 )
    THEN

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('PCH -- PVT -- REMOVE_LINK -- Aborting because not linked PC');
        END IF;
      RETURN;
    END IF;


    OPEN delete_header(p_x_pc_header_rec.LINK_TO_PC_ID);
    FETCH delete_header INTO l_dummy;
    IF (delete_header%NOTFOUND)
    THEN
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('PCH -- PVT -- REMOVE_LINK -- Aborting because not found linked-to PC');
        END IF;
        CLOSE delete_header;
        RETURN;
    END IF;
    CLOSE delete_header;

    -- SATHAPLI::Bug# 6504069, 26-Mar-2008
    -- get all the applicable MRs for the linked (old) PC
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' p_x_pc_header_rec.LINK_TO_PC_ID => '||p_x_pc_header_rec.LINK_TO_PC_ID);
    END IF;

    OPEN get_mr_for_pc_csr(p_x_pc_header_rec.LINK_TO_PC_ID);
    LOOP
        FETCH get_mr_for_pc_csr INTO l_get_mr_for_pc_rec;
        EXIT WHEN get_mr_for_pc_csr%NOTFOUND;

        -- get the top level applicable instances for the MR
        AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS(
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_mr_header_id          => l_get_mr_for_pc_rec.mr_header_id,
            p_mr_effectivity_id     => l_get_mr_for_pc_rec.mr_effectivity_id,
            p_top_node_flag         => 'Y',
            p_unique_inst_flag      => 'Y',
            x_mr_item_inst_tbl      => l_mr_item_inst_tbl);

        -- check for the return status
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement,l_full_name,
                               'Raising exception with x_return_status => '||x_return_status);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- populate the associative array of instances for linked PC
        IF (l_mr_item_inst_tbl.COUNT > 0) THEN
            FOR i IN l_mr_item_inst_tbl.FIRST..l_mr_item_inst_tbl.LAST LOOP
                indx := l_mr_item_inst_tbl(i).item_instance_id;
                l_link_mr_item_inst_tbl(indx) := l_mr_item_inst_tbl(i).item_instance_id;
            END LOOP;
        END IF;
    END LOOP;
    CLOSE get_mr_for_pc_csr;

    -- put all the applicable instances for the linked PC in the debug logs
    indx := l_link_mr_item_inst_tbl.FIRST;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        WHILE indx IS NOT NULL LOOP
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' l_link_mr_item_inst_tbl indx, item_instance_id => '||indx||
                           ' ,'||l_link_mr_item_inst_tbl(indx));
            indx := l_link_mr_item_inst_tbl.NEXT(indx);
        END LOOP;
    END IF;

    l_pc_header_rec.PC_HEADER_ID            := p_x_pc_header_rec.PC_HEADER_ID;
    l_pc_header_rec.LINK_TO_PC_ID           := p_x_pc_header_rec.LINK_TO_PC_ID;
    l_pc_header_rec.OBJECT_VERSION_NUMBER   := p_x_pc_header_rec.OBJECT_VERSION_NUMBER;

    p_x_pc_header_rec.PC_HEADER_ID      := l_pc_header_rec.LINK_TO_PC_ID;
    p_x_pc_header_rec.LINK_TO_PC_ID     := 0;
    p_x_pc_header_rec.DRAFT_FLAG        := 'N';
    p_x_pc_header_rec.OPERATION_FLAG    := AHL_PC_HEADER_PVT.G_DML_LINK;

    SELECT OBJECT_VERSION_NUMBER INTO p_x_pc_header_rec.OBJECT_VERSION_NUMBER
    FROM AHL_PC_HEADERS_B
    WHERE PC_HEADER_ID = l_pc_header_rec.LINK_TO_PC_ID;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
              'About to call UPDATE_PC_HEADER with p_x_pc_header_rec.PC_HEADER_ID = ' || p_x_pc_header_rec.PC_HEADER_ID);
    END IF;

    UPDATE_PC_HEADER
    (
        p_api_version           => p_api_version,
        p_init_msg_list     => FND_API.G_FALSE,
        p_commit        => FND_API.G_FALSE,
        p_validation_level  => p_validation_level,
        p_x_pc_header_rec   => p_x_pc_header_rec,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data
    );


	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
		'Returned from UPDATE_PC_HEADER with x_return_status = ' || x_return_status);
	END IF;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' Updated linked-to PC');
    END IF;

    l_nodeCtr := 0;

    -- Begin -- DELETE
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' Starting DELETE-'||l_pc_header_rec.PC_HEADER_ID);
    END IF;

    --delink before attach as the attached nodes also appear in the detach query due to id and no link id

    OPEN detach_nodes (l_pc_header_rec.PC_HEADER_ID, l_pc_header_rec.LINK_TO_PC_ID );--adharia- 28-6-2002
    LOOP
        FETCH detach_nodes INTO l_node_data_rec_det;
        EXIT WHEN detach_nodes%NOTFOUND;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' Starting DELETEING record  -- '||l_node_data_rec_det.PC_NODE_ID);
        END IF;

        IF l_node_data_rec_det.node_type = G_NODE
        THEN
            l_node_rec.PC_HEADER_ID         := l_node_data_rec_det.PC_HEADER_ID; --adharia- 28-6-2002
            l_node_rec.PC_NODE_ID           := l_node_data_rec_det.PC_NODE_ID;
            l_node_rec.PARENT_NODE_ID       := l_node_data_rec_det.PARENT_NODE_ID;
            l_node_rec.CHILD_COUNT          := l_node_data_rec_det.CHILD_COUNT;
            l_node_rec.NAME                 := l_node_data_rec_det.NAME;
            l_node_rec.DESCRIPTION          := l_node_data_rec_det.DESCRIPTION;
            l_node_rec.DRAFT_FLAG           := 'N';
            l_node_rec.LINK_TO_NODE_ID      := 0;
            l_node_rec.OPERATION_FLAG       := AHL_PC_HEADER_PVT.G_DML_DELETE;
            l_node_rec.OBJECT_VERSION_NUMBER    := l_node_data_rec_det.OBJECT_VERSION_NUMBER;

        ELSIF l_node_data_rec_det.node_type IN (G_PART, G_UNIT)
        THEN

            l_assos_rec.PC_ASSOCIATION_ID       := l_node_data_rec_det.PC_NODE_ID;
            l_assos_rec.PC_NODE_ID          := l_node_data_rec_det.PARENT_NODE_ID;
            l_assos_rec.UNIT_ITEM_ID        := l_node_data_rec_det.UNIT_ITEM_ID;
            l_assos_rec.INVENTORY_ORG_ID        := l_node_data_rec_det.INVENTORY_ORG_ID;
            l_assos_rec.ASSOCIATION_TYPE_FLAG   := l_node_data_rec_det.node_type;
            l_assos_rec.DRAFT_FLAG          := 'N';
            l_assos_rec.LINK_TO_ASSOCIATION_ID      := 0;
            l_assos_rec.OPERATION_FLAG      := AHL_PC_HEADER_PVT.G_DML_DELETE;
            l_assos_rec.OBJECT_VERSION_NUMBER   := l_node_data_rec_det.OBJECT_VERSION_NUMBER;

        END IF;

        IF l_node_data_rec_det.node_type = G_NODE
        THEN
            DELETE_NODES_REMOVE_LINK (l_node_rec);

        ELSIF l_node_data_rec_det.node_type = G_UNIT
        THEN
            DETACH_UNIT_REMOVE_LINK (l_assos_rec);

        ELSIF l_node_data_rec_det.node_type =G_PART
        THEN
            DETACH_ITEM_REMOVE_LINK (l_assos_rec);

        END IF;
    END LOOP;
    CLOSE detach_nodes;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
              'Completed detach_nodes loop');
    END IF;

 -- Added to delete those associations which has association id, node id and header id the same
   OPEN detach_associations(l_pc_header_rec.PC_HEADER_ID, l_pc_header_rec.LINK_TO_PC_ID);
    LOOP
        FETCH detach_associations INTO l_asso_data_rec_det;
        EXIT WHEN detach_associations%NOTFOUND;

    IF l_asso_data_rec_det.ASSOCIATION_TYPE_FLAG IN (G_PART, G_UNIT)
        THEN

            l_assos_rec.PC_ASSOCIATION_ID          := l_asso_data_rec_det.PC_ASSOCIATION_ID;
            l_assos_rec.PC_NODE_ID                 := l_asso_data_rec_det.PC_NODE_ID;
            l_assos_rec.UNIT_ITEM_ID               := l_asso_data_rec_det.UNIT_ITEM_ID;
            l_assos_rec.INVENTORY_ORG_ID           := l_asso_data_rec_det.INVENTORY_ORG_ID;
            l_assos_rec.ASSOCIATION_TYPE_FLAG      := l_asso_data_rec_det.ASSOCIATION_TYPE_FLAG;
            l_assos_rec.DRAFT_FLAG                 := 'N';
            l_assos_rec.LINK_TO_ASSOCIATION_ID     := 0;
            l_assos_rec.OPERATION_FLAG             := AHL_PC_HEADER_PVT.G_DML_DELETE;
            l_assos_rec.OBJECT_VERSION_NUMBER      := l_asso_data_rec_det.OBJECT_VERSION_NUMBER;

    END IF;

        IF l_asso_data_rec_det.ASSOCIATION_TYPE_FLAG = G_UNIT
        THEN
              DETACH_UNIT_REMOVE_LINK (l_assos_rec);

        ELSIF l_asso_data_rec_det.ASSOCIATION_TYPE_FLAG =G_PART
        THEN
              DETACH_ITEM_REMOVE_LINK (l_assos_rec);
        END IF;

    END LOOP;
    CLOSE detach_associations;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
              'Completed detach_associations loop');
    END IF;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        -- End -- DELETE
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' Ending DELETE msg_count='||x_msg_count);

        -- Begin -- COPY
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' Starting COPY');
    END IF;

    --For bug # 9486654 Fetching Nodes
    OPEN attach_nodes (l_pc_header_rec.PC_HEADER_ID);
    LOOP
        FETCH attach_nodes INTO l_node_data_rec;
        EXIT WHEN attach_nodes%NOTFOUND;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
			'In attach_nodes loop. l_node_data_rec.node_type = ' || l_node_data_rec.node_type ||
			', l_node_data_rec.PC_NODE_ID = ' || l_node_data_rec.PC_NODE_ID ||
                        ', l_node_data_rec.LINK_TO_NODE_ID = ' || l_node_data_rec.LINK_TO_NODE_ID);
        END IF;

        IF l_node_data_rec.node_type = G_NODE
        THEN
            l_node_rec.PC_HEADER_ID := l_pc_header_rec.LINK_TO_PC_ID;
            l_old_node_id:= l_node_data_rec.PC_NODE_ID;
            IF l_node_data_rec.LINK_TO_NODE_ID = 0 or l_node_data_rec.LINK_TO_NODE_ID IS NULL
            THEN
                l_node_rec.PC_NODE_ID := l_node_data_rec.PC_NODE_ID;
            ELSE
                l_node_rec.PC_NODE_ID := l_node_data_rec.LINK_TO_NODE_ID;
            END IF;

            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- REMOVE_LINK -- Node record for ID='||l_node_rec.PC_NODE_ID);
            END IF;

            l_node_rec.PARENT_NODE_ID       := l_node_data_rec.PARENT_NODE_ID;
            l_node_rec.CHILD_COUNT          := l_node_data_rec.CHILD_COUNT;
            l_node_rec.NAME             := l_node_data_rec.NAME;
            l_node_rec.DESCRIPTION          := l_node_data_rec.DESCRIPTION;
            l_node_rec.DRAFT_FLAG           := 'N';
            l_node_rec.LINK_TO_NODE_ID      := 0;
            l_node_rec.OPERATION_FLAG       := AHL_PC_HEADER_PVT.G_DML_LINK;
            l_node_rec.ATTRIBUTE_CATEGORY   := l_node_data_rec.ATTRIBUTE_CATEGORY;
            l_node_rec.ATTRIBUTE1           := l_node_data_rec.ATTRIBUTE1;
            l_node_rec.ATTRIBUTE2           := l_node_data_rec.ATTRIBUTE2;
            l_node_rec.ATTRIBUTE3           := l_node_data_rec.ATTRIBUTE3;
            l_node_rec.ATTRIBUTE4           := l_node_data_rec.ATTRIBUTE4;
            l_node_rec.ATTRIBUTE5           := l_node_data_rec.ATTRIBUTE5;
            l_node_rec.ATTRIBUTE6           := l_node_data_rec.ATTRIBUTE6;
            l_node_rec.ATTRIBUTE7           := l_node_data_rec.ATTRIBUTE7;
            l_node_rec.ATTRIBUTE8           := l_node_data_rec.ATTRIBUTE8;
            l_node_rec.ATTRIBUTE9           := l_node_data_rec.ATTRIBUTE9;
            l_node_rec.ATTRIBUTE10          := l_node_data_rec.ATTRIBUTE10;
            l_node_rec.ATTRIBUTE11          := l_node_data_rec.ATTRIBUTE11;
            l_node_rec.ATTRIBUTE12          := l_node_data_rec.ATTRIBUTE12;
            l_node_rec.ATTRIBUTE13          := l_node_data_rec.ATTRIBUTE13;
            l_node_rec.ATTRIBUTE14          := l_node_data_rec.ATTRIBUTE14;
            l_node_rec.ATTRIBUTE15          := l_node_data_rec.ATTRIBUTE15;

            SELECT OBJECT_VERSION_NUMBER INTO l_node_rec.OBJECT_VERSION_NUMBER
            FROM AHL_PC_NODES_B
            WHERE PC_NODE_ID = l_node_rec.PC_NODE_ID;

	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'Got l_node_rec.OBJECT_VERSION_NUMBER as ' || l_node_rec.OBJECT_VERSION_NUMBER);
            END IF;

        END IF;

        IF l_nodeCtr = 0
        THEN
            l_node_rec.PARENT_NODE_ID := 0;
        ELSE
            FOR l_nc IN 0..l_nodeCtr
            LOOP
                IF l_nodeId_tbl(l_nc).NODE_ID = l_node_data_rec.PARENT_NODE_ID
                THEN
                    IF l_node_data_rec.node_type = G_NODE
                    THEN
                        l_node_rec.PARENT_NODE_ID := l_nodeId_tbl(l_nc).NEW_NODE_ID;
                        EXIT;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF l_node_data_rec.node_type = G_NODE
        THEN
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'Before AHL_PC_NODE_PVT.UPDATE_NODE :l_node_rec.PC_NODE_ID ' || l_node_rec.PC_NODE_ID);
            END IF;

            AHL_PC_NODE_PVT.UPDATE_NODE
            (
                p_api_version           => p_api_version,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit        => FND_API.G_FALSE,
                p_validation_level  => p_validation_level,
                p_x_node_rec        => l_node_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
            );

            l_nodeId_tbl(l_nodeCtr).NODE_ID         := l_node_data_rec.PC_NODE_ID;
            l_nodeId_tbl(l_nodeCtr).NEW_NODE_ID     := l_node_rec.PC_NODE_ID;
            l_nodeCtr                           := l_nodeCtr + 1;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'After AHL_PC_NODE_PVT.UPDATE_NODE :l_node_rec.PC_NODE_ID ' || l_node_rec.PC_NODE_ID);
            END IF;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'After AHL_PC_NODE_PVT.UPDATE_NODE :l_nodeCtr ' || l_nodeCtr);
            END IF;

        END IF;

    END LOOP;
    CLOSE attach_nodes;

    -- For bug # 9486654  Fetching Units
    OPEN attach_nodes_units(l_pc_header_rec.PC_HEADER_ID);
    LOOP
        FETCH attach_nodes_units INTO l_node_units_data_rec;
        EXIT WHEN attach_nodes_units%NOTFOUND;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
			'In attach_nodes_units loop. l_node_units_data_rec.node_type = ' || l_node_units_data_rec.node_type ||
			', l_node_units_data_rec.PC_NODE_ID = ' || l_node_units_data_rec.PC_NODE_ID ||
                        ', l_node_units_data_rec.LINK_TO_NODE_ID = ' || l_node_units_data_rec.LINK_TO_NODE_ID);
        END IF;

        IF l_node_units_data_rec.node_type IN (G_PART, G_UNIT)
        THEN
            IF l_node_units_data_rec.LINK_TO_NODE_ID = 0 or l_node_units_data_rec.LINK_TO_NODE_ID = NULL
            THEN
                l_assos_rec.PC_ASSOCIATION_ID := l_node_units_data_rec.PC_NODE_ID;
            ELSE
                l_assos_rec.PC_ASSOCIATION_ID := l_node_units_data_rec.LINK_TO_NODE_ID;
            END IF;

            IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('PCH -- PVT -- REMOVE_LINK -- Unit/Part record for ID='||l_assos_rec.PC_ASSOCIATION_ID);
            END IF;

            l_assos_rec.PC_NODE_ID          := l_node_units_data_rec.PARENT_NODE_ID;
            l_assos_rec.UNIT_ITEM_ID        := l_node_units_data_rec.UNIT_ITEM_ID;
            l_assos_rec.INVENTORY_ORG_ID        := l_node_units_data_rec.INVENTORY_ORG_ID;
            l_assos_rec.ASSOCIATION_TYPE_FLAG   := l_node_units_data_rec.NODE_TYPE;
            l_assos_rec.DRAFT_FLAG          := 'N';
            l_assos_rec.LINK_TO_ASSOCIATION_ID      := 0;
            l_assos_rec.OPERATION_FLAG      := AHL_PC_HEADER_PVT.G_DML_LINK;
            l_assos_rec.ATTRIBUTE_CATEGORY      := l_node_units_data_rec.ATTRIBUTE_CATEGORY;
            l_assos_rec.ATTRIBUTE1          := l_node_units_data_rec.ATTRIBUTE1;
            l_assos_rec.ATTRIBUTE2          := l_node_units_data_rec.ATTRIBUTE2;
            l_assos_rec.ATTRIBUTE3          := l_node_units_data_rec.ATTRIBUTE3;
            l_assos_rec.ATTRIBUTE4          := l_node_units_data_rec.ATTRIBUTE4;
            l_assos_rec.ATTRIBUTE5          := l_node_units_data_rec.ATTRIBUTE5;
            l_assos_rec.ATTRIBUTE6          := l_node_units_data_rec.ATTRIBUTE6;
            l_assos_rec.ATTRIBUTE7          := l_node_units_data_rec.ATTRIBUTE7;
            l_assos_rec.ATTRIBUTE8          := l_node_units_data_rec.ATTRIBUTE8;
            l_assos_rec.ATTRIBUTE9          := l_node_units_data_rec.ATTRIBUTE9;
            l_assos_rec.ATTRIBUTE10         := l_node_units_data_rec.ATTRIBUTE10;
            l_assos_rec.ATTRIBUTE11         := l_node_units_data_rec.ATTRIBUTE11;
            l_assos_rec.ATTRIBUTE12         := l_node_units_data_rec.ATTRIBUTE12;
            l_assos_rec.ATTRIBUTE13         := l_node_units_data_rec.ATTRIBUTE13;
            l_assos_rec.ATTRIBUTE14         := l_node_units_data_rec.ATTRIBUTE14;
            l_assos_rec.ATTRIBUTE15         := l_node_units_data_rec.ATTRIBUTE15;

            SELECT OBJECT_VERSION_NUMBER INTO l_assos_rec.OBJECT_VERSION_NUMBER
            FROM AHL_PC_ASSOCIATIONS
            WHERE PC_ASSOCIATION_ID = l_assos_rec.PC_ASSOCIATION_ID;
	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'Got l_node_rec.OBJECT_VERSION_NUMBER as ' || l_node_rec.OBJECT_VERSION_NUMBER);
            END IF;

        END IF;

            FOR l_nc IN 0..l_nodeCtr
            LOOP
                IF l_nodeId_tbl(l_nc).NODE_ID = l_node_units_data_rec.PARENT_NODE_ID
                THEN
		    IF l_node_units_data_rec.node_type IN (G_PART, G_UNIT)
                    THEN
                        l_assos_rec.PC_NODE_ID := l_nodeId_tbl(l_nc).NEW_NODE_ID;
                        EXIT;
                    END IF;
                END IF;
            END LOOP;

        IF l_node_units_data_rec.node_type ='U'
        THEN
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'Before AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT :l_assos_rec.PC_NODE_ID ' || l_node_rec.PC_NODE_ID);
            END IF;

                AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT
                (
                    p_api_version           => p_api_version,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit        => FND_API.G_FALSE,
                    p_validation_level  => p_validation_level,
                    p_x_assos_rec       => l_assos_rec,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data
                );

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'ahl.plsql.AHL_PC_HEADER_PVT.REMOVE_LINK',
                      'After AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT :l_assos_rec.PC_NODE_ID ' || l_node_rec.PC_NODE_ID);
            END IF;
        ELSIF l_node_units_data_rec.node_type ='I'
        THEN

                AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM
                (
                    p_api_version           => p_api_version,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit        => FND_API.G_FALSE,
                    p_validation_level  => p_validation_level,
                    p_x_assos_rec       => l_assos_rec,
                    x_return_status         => x_return_status,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data
                );

        END IF;

    END LOOP;
    CLOSE attach_nodes_units;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,' Ending COPY');
    END IF;
    -- End -- COPY

        -- To associate documents to the Complete version from draft version for new nodes.
        -- Fixed by Senthil for Bug # 3558557 and 3558601


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,' Start of merging Docs');
    END IF;


    SELECT pc_node_id,
           link_to_node_id
    BULK COLLECT INTO
           l_draft_nodeId_tbl,
           l_comp_nodeId_tbl
    FROM   ahl_pc_nodes_b
    WHERE PC_HEADER_ID = l_pc_header_rec.pc_header_id
    AND NVL(LINK_TO_NODE_ID,0) <> 0
    START WITH PARENT_NODE_ID =  0
    CONNECT BY PRIOR PC_NODE_ID = PARENT_NODE_ID;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,' Docs count'||l_draft_nodeId_tbl.count);
    END IF;


-- There is no need to associate documents for newly created nodes of Complete PC b'coz the same
-- node id of the draft version is used to create a new node in the Complete version hence the
-- relationship is maintatined.

    IF l_draft_nodeId_tbl.count > 0 THEN

        FORALL I IN 1..l_comp_nodeId_tbl.count
        DELETE
        FROM AHL_DOC_TITLE_ASSOS_TL
        WHERE   DOC_TITLE_ASSO_ID IN (
            SELECT DOC_TITLE_ASSO_ID
            FROM   AHL_DOC_TITLE_ASSOS_B
            WHERE   aso_object_type_code = 'PC' and
                aso_object_id = l_comp_nodeId_tbl(I)
        );

        FORALL I IN 1..l_comp_nodeId_tbl.count
        DELETE
        FROM AHL_DOC_TITLE_ASSOS_B
        WHERE   aso_object_type_code = 'PC' and
            aso_object_id = l_comp_nodeId_tbl(I);


        FORALL I IN 1..l_draft_nodeId_tbl.count
        UPDATE AHL_DOC_TITLE_ASSOS_B
           SET ASO_OBJECT_ID = l_comp_nodeId_tbl(I),
               OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER +1
         WHERE ASO_OBJECT_ID = l_draft_nodeId_tbl(I)
           AND ASO_OBJECT_TYPE_CODE = 'PC';

    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,' Docs Merge ends');
    END IF;


    l_pc_header_rec.OPERATION_FLAG := AHL_PC_HEADER_PVT.G_DML_DELETE;

    DELETE_PC_AND_TREE(l_pc_header_rec.pc_header_id);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,' Deleted Header Record');
    END IF;

    p_x_pc_header_rec.OPERATION_FLAG := AHL_PC_HEADER_PVT.G_DML_LINK;

    -- SATHAPLI::Bug# 6504069, 26-Mar-2008
    -- The call to API AHL_UMP_UNITMAINT_PVT.PROCESS_UNITEFFECTIVITY for building
    -- unit effectivities has been commented out for performance reasons.
    -- Instead, the following should be done: -
    -- 1. re-build unit effectivities for all the removed units from the linked PC by making
    --    a call to the concurrent program AHLUEFF
    -- 2. build unit effectivities for the new PC by making a call to the new concurrent
    --    program AHLPCUEFF

    /*
    -- Adding call to UMP procedure to recalculate utilization forecasts...
    OPEN get_mr_for_pc (p_x_pc_header_rec.pc_header_id);
    LOOP
        FETCH get_mr_for_pc INTO l_mr_id, l_mr_title, l_mr_version;
        EXIT WHEN get_mr_for_pc%NOTFOUND;
        AHL_UMP_UNITMAINT_PVT.PROCESS_UNITEFFECTIVITY
        (
            p_api_version                       => 1.0,
            p_init_msg_list                     => FND_API.G_FALSE,
            p_commit                            => FND_API.G_FALSE,
            p_validation_level                  => FND_API.G_VALID_LEVEL_FULL,
            p_default                           => null,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data,
            p_mr_header_id                      => l_mr_id,
            p_mr_title                          => l_mr_title,
            p_mr_version_number                 => l_mr_version,
            p_unit_config_header_id             => null,
            p_unit_name                         => null,
            p_csi_item_instance_id              => null,
            p_csi_instance_number               => null
        );
    END LOOP;
    CLOSE get_mr_for_pc;
    */

    -- get all the applicable MRs for the new PC
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' p_x_pc_header_rec.PC_HEADER_ID => '||p_x_pc_header_rec.PC_HEADER_ID);
    END IF;

    OPEN get_mr_for_pc_csr(p_x_pc_header_rec.PC_HEADER_ID);
    LOOP
        FETCH get_mr_for_pc_csr INTO l_get_mr_for_pc_rec;
        EXIT WHEN get_mr_for_pc_csr%NOTFOUND;

        -- get the top level applicable instances for the MR
        AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS(
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_mr_header_id          => l_get_mr_for_pc_rec.mr_header_id,
            p_mr_effectivity_id     => l_get_mr_for_pc_rec.mr_effectivity_id,
            p_top_node_flag         => 'Y',
            p_unique_inst_flag      => 'Y',
            x_mr_item_inst_tbl      => l_mr_item_inst_tbl);

        -- check for the return status
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement,l_full_name,
                               'Raising exception with x_return_status => '||x_return_status);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- populate the associative array of instances for new PC
        IF (l_mr_item_inst_tbl.COUNT > 0) THEN
            FOR i IN l_mr_item_inst_tbl.FIRST..l_mr_item_inst_tbl.LAST LOOP
                indx := l_mr_item_inst_tbl(i).item_instance_id;
                l_new_mr_item_inst_tbl(indx) := l_mr_item_inst_tbl(i).item_instance_id;
            END LOOP;
        END IF;
    END LOOP;
    CLOSE get_mr_for_pc_csr;

    -- put all the applicable instances for the new PC in the debug logs
    indx := l_new_mr_item_inst_tbl.FIRST;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        WHILE indx IS NOT NULL LOOP
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' l_new_mr_item_inst_tbl indx, item_instance_id => '||indx||
                           ' ,'||l_new_mr_item_inst_tbl(indx));
            indx := l_new_mr_item_inst_tbl.NEXT(indx);
        END LOOP;
    END IF;

    -- get all the top instances of the removed units from the linked (old) PC
    -- in the associative array l_diff_mr_item_inst_tbl
    -- i.e. l_diff_mr_item_inst_tbl = l_link_mr_item_inst_tbl - l_new_mr_item_inst_tbl
    indx := l_link_mr_item_inst_tbl.FIRST;
    WHILE indx IS NOT NULL LOOP
        IF NOT l_new_mr_item_inst_tbl.EXISTS(indx) THEN
            l_diff_mr_item_inst_tbl(indx) := l_link_mr_item_inst_tbl(indx);
        END IF;

        indx := l_link_mr_item_inst_tbl.NEXT(indx);
    END LOOP;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' l_diff_mr_item_inst_tbl.COUNT => '||l_diff_mr_item_inst_tbl.COUNT);
    END IF;

    -- put all the top instances of the removed units in the debug logs
    indx := l_diff_mr_item_inst_tbl.FIRST;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        WHILE indx IS NOT NULL LOOP
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' l_diff_mr_item_inst_tbl indx, item_instance_id => '||indx||
                           ' ,'||l_diff_mr_item_inst_tbl(indx));
            indx := l_diff_mr_item_inst_tbl.NEXT(indx);
        END LOOP;
    END IF;

    -- for each of the top instance of removed units make a call to
    -- concurrent program AHLUEFF for recalculating unit effectivities
    indx := l_diff_mr_item_inst_tbl.FIRST;
    WHILE indx IS NOT NULL LOOP
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' Submitting concurrent request to recalculate unit effectivities for instance => '||
                           l_diff_mr_item_inst_tbl(indx));
        END IF;

        l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                        application => 'AHL',
                        program     => 'AHLUEFF',
                        argument1   => NULL,
                        argument2   => NULL,
                        argument3   => l_diff_mr_item_inst_tbl(indx));

        IF (l_req_id = 0) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                               ' Concurrent request failed.');
            END IF;
        ELSE
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                               ' Concurrent request successful.');
            END IF;
        END IF;

        indx := l_diff_mr_item_inst_tbl.NEXT(indx);
    END LOOP;

    -- make a call to the concurrent program AHLPCUEFF to calculate unit
    -- effectivities for the new PC
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                       ' Submitting concurrent request to calculate unit effectivities for pc_header_id => '||
                       p_x_pc_header_rec.PC_HEADER_ID);
    END IF;

    l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    application => 'AHL',
                    program     => 'AHLPCUEFF',
                    argument1   => 1.0,
                    argument2   => p_x_pc_header_rec.PC_HEADER_ID);

    IF (l_req_id = 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' Concurrent request failed.');
        END IF;
    ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_full_name,
                           ' Concurrent request successful.');
        END IF;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_full_name,'End of the API');
    END IF;

END REMOVE_LINK;

---------------------------------
-- VALIDATE_UNIT_PART_ATTACHED --
---------------------------------
FUNCTION VALIDATE_UNIT_PART_ATTACHED
(
    p_pc_header_id IN NUMBER ,
    p_prod_type    IN VARCHAR2,
    p_assos_type   IN VARCHAR2
)
RETURN BOOLEAN
IS

CURSOR check_prod_type_changed (p_pc_header_id IN NUMBER, p_prod_type IN VARCHAR2, p_assos_type IN VARCHAR2)
IS
    SELECT  'X'
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = p_pc_header_id AND
        PRODUCT_TYPE_CODE = p_prod_type AND
        ASSOCIATION_TYPE_FLAG = p_assos_type;

CURSOR check_unit_part_attached (p_pc_header_id IN NUMBER)
IS
    -- Perf Fix - 4913818. Modified Query below to use Base Tables.
    /*
    SELECT  'X'
    FROM    AHL_PC_TREE_V
    WHERE   PC_HEADER_ID = p_pc_header_id AND
        NODE_TYPE IN (G_PART, G_UNIT);
    */
    SELECT 'X'
    FROM   AHL_PC_ASSOCIATIONS AHS,
           AHL_PC_NODES_B NODE
    WHERE  NODE.PC_NODE_ID = AHS.PC_NODE_ID
      AND  NODE.PC_HEADER_ID = p_pc_header_id;

l_dummy  VARCHAR2(30);
l_return VARCHAR2(80);

BEGIN
    OPEN check_unit_part_attached (p_pc_header_id);
    FETCH check_unit_part_attached into l_dummy;
    IF check_unit_part_attached%NOTFOUND
    THEN
        -- UNIT/PART NOT ATTACHED SO RETURN TRUE AS PROD TYPE CAN BE CHANGED
        CLOSE check_unit_part_attached;
        RETURN TRUE;
    END IF;
    CLOSE check_unit_part_attached;

    OPEN check_prod_type_changed (p_pc_header_id, p_prod_type, p_assos_type);
    FETCH check_prod_type_changed into l_dummy;
    IF check_prod_type_changed%FOUND
    THEN
        -- PROD_TYPE NOT CHANGED SO RETURN TRUE AS PROD TYPE CAN BE CHANGED
        CLOSE check_prod_type_changed;
        RETURN TRUE;
    END IF;

    CLOSE check_prod_type_changed;
    RETURN FALSE;

END VALIDATE_UNIT_PART_ATTACHED;

-------------------------------
-- VALIDATE_PC_HEADER_UPDATE --
-------------------------------
PROCEDURE VALIDATE_PC_HEADER_UPDATE
(
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
    x_return_status       OUT    NOCOPY       VARCHAR2,
    x_msg_count           OUT    NOCOPY       NUMBER,
    x_msg_data            OUT    NOCOPY       VARCHAR2
)
IS

CURSOR check_header_data (p_header_id IN NUMBER)
IS
    SELECT  OBJECT_VERSION_NUMBER,
        PRODUCT_TYPE_CODE,
        STATUS,
        PRIMARY_FLAG,
        ASSOCIATION_TYPE_FLAG,
        LINK_TO_PC_ID
    FROM    AHL_PC_HEADERS_B
    WHERE   PC_HEADER_ID = p_header_id;

l_old_obj_ver_no        NUMBER;
l_old_prod_type_code    VARCHAR2(30);
l_old_status            VARCHAR2(30);
l_old_primary_flag      VARCHAR2(1);
l_old_assos_type        VARCHAR2(1);

CURSOR unit_part_assos (p_header_id IN NUMBER)
IS
    -- Perf Fix - 4913818. Modified Query below to use Base Tables.
    /*
    SELECT  'X'
    FROM    AHL_PC_TREE_V
    WHERE   PC_HEADER_ID = p_header_id AND
        NODE_TYPE IN (G_PART, G_UNIT);
    */
    SELECT 'X'
    FROM   AHL_PC_ASSOCIATIONS AHS,
           AHL_PC_NODES_B NODE
    WHERE  NODE.PC_NODE_ID = AHS.PC_NODE_ID
      AND  NODE.PC_HEADER_ID = p_header_id;

l_dummy             BOOLEAN;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list)
    THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.ENABLE_DEBUG;
    END IF;

    OPEN check_header_data (p_x_pc_header_rec.PC_HEADER_ID);
    FETCH check_header_data INTO
        l_old_obj_ver_no,
        l_old_prod_type_code,
        l_old_status,
        l_old_primary_flag,
        l_old_assos_type,p_x_pc_header_rec.link_to_pc_id;
    IF (check_header_data%NOTFOUND)
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PC_NOT_FOUND');
        FND_MSG_PUB.ADD;
        CLOSE check_header_data;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_header_data;

    IF l_old_obj_ver_no <> p_x_pc_header_rec.OBJECT_VERSION_NUMBER
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_dummy := VALIDATE_UNIT_PART_ATTACHED (p_x_pc_header_rec.PC_HEADER_ID, p_x_pc_header_rec.PRODUCT_TYPE_CODE, p_x_pc_header_rec.ASSOCIATION_TYPE_FLAG);

    IF (l_dummy = FALSE)
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_PART_ATTACHED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug('PCH -- PVT -- VALIDATE_PC_HEADER_UPDATE -- Old Status = '||l_old_status||' -- New Status = '||p_x_pc_header_rec.STATUS);
    END IF;

    -- PC is COMPLETE -- User submits without changing to DRAFT -- ERROR
    IF p_x_pc_header_rec.STATUS = 'COMPLETE' AND l_old_status = 'COMPLETE'
    THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PC_STATUS_COMPLETE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

    -- PC is APPROVAL_REJECTED -- User submits after making any change -- Change status to DRAFT
    ELSIF p_x_pc_header_rec.STATUS = 'APPROVAL_REJECTED' AND  l_old_status = 'APPROVAL_REJECTED'
    THEN
        p_x_pc_header_rec.STATUS := 'DRAFT';

    -- PC is APPROVAL_PENDING -- Approver rejects PC -- Do Nothing, Approval package will take care of this
    ELSIF p_x_pc_header_rec.STATUS = 'APPROVAL_REJECTED' AND  l_old_status = 'APPROVAL_PENDING'
    THEN
        NULL;

    -- PC is DRAFT -- User submits for approval -- Call INITIATE_PC_APPROVAL
    ELSIF p_x_pc_header_rec.STATUS = 'APPROVAL_PENDING' AND  l_old_status = 'DRAFT'
    THEN
        INITIATE_PC_APPROVAL
        (
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => p_validation_level,
            p_default               => FND_API.G_FALSE,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_x_pc_header_rec       => p_x_pc_header_rec
        );

        p_x_pc_header_rec.OPERATION_FLAG := G_DML_LINK;

    -- PC is APPROVAL_PENDING -- Approver approves PC -- Remove any links and make 1 COMPLETE PC
    ELSIF p_x_pc_header_rec.STATUS = 'COMPLETE' AND  l_old_status = 'APPROVAL_PENDING'
    THEN
        REMOVE_LINK
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_validation_level,
            p_x_pc_header_rec,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

    -- PC is COMPLETE -- User changes status to DRAFT -- Create 1 linked DRAFT PC for this PC
    ELSIF p_x_pc_header_rec.STATUS = 'DRAFT' AND  l_old_status = 'COMPLETE'
    THEN

        CREATE_LINK
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_validation_level,
            p_x_pc_header_rec,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

    END IF;

END VALIDATE_PC_HEADER_UPDATE;

END AHL_PC_HEADER_PVT;

/
