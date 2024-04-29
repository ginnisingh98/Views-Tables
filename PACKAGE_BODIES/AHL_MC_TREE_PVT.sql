--------------------------------------------------------
--  DDL for Package Body AHL_MC_TREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_TREE_PVT" AS
/* $Header: AHLVMCTB.pls 120.2.12010000.2 2009/07/17 10:47:15 sathapli ship $ */

-------------------
-- Common variables
-------------------
l_dummy_varchar     VARCHAR2(1);
l_dummy_number      NUMBER;

-------------------
-- Private type --
-------------------
TYPE Nodes_for_parent_rec IS RECORD  (
    RELATIONSHIP_ID            NUMBER,
    OBJECT_VERSION_NUMBER      NUMBER,
    POSITION_KEY               NUMBER,
    PARENT_RELATIONSHIP_ID     NUMBER,
    ITEM_GROUP_ID              NUMBER,
    POSITION_REF_CODE          VARCHAR2(30),
    POSITION_REF_MEANING       VARCHAR2(80),
    --R12
    --priyan MEL-CDL
    ATA_CODE           VARCHAR2(30),
    ATA_MEANING        VARCHAR2(80),
    POSITION_NECESSITY_CODE    VARCHAR2(30),
    POSITION_NECESSITY_MEANING VARCHAR2(80),
    UOM_CODE                   VARCHAR2(3),
    QUANTITY                   NUMBER,
    DISPLAY_ORDER              NUMBER,
    ACTIVE_START_DATE          DATE,
    ACTIVE_END_DATE            DATE,
    MC_HEADER_ID               NUMBER,
    MC_ID                      NUMBER,
    VERSION_NUMBER             NUMBER,
    CONFIG_STATUS_CODE     VARCHAR2(30));

-- SATHAPLI::Bug 8363349, 16-Apr-2009, MC tree perf issue
-- TYPE Nodes_for_parent_ref_csr IS REF CURSOR RETURN Nodes_for_parent_rec;
TYPE Nodes_for_parent_tbl IS TABLE OF Nodes_for_parent_rec INDEX BY BINARY_INTEGER;

------------------------------
-- Declare local procedures --
------------------------------
FUNCTION Decode_Pos_Path
(
    p_encoded_path      IN      VARCHAR2
)
RETURN AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;

PROCEDURE Get_nodes_for_parent(
    -- p_end_date           IN DATE,
    p_relationship_id    IN NUMBER,
    p_is_sub_config_node IN VARCHAR2,
    p_is_top_config_node IN VARCHAR2,
    p_mc_header_id       IN NUMBER,
    p_parent_rel_id      IN NUMBER,
    -- SATHAPLI::Bug 8363349, 16-Apr-2009, MC tree perf issue
    -- p_Get_nodes_csr      IN OUT NOCOPY Nodes_for_parent_ref_csr
    x_Get_nodes_tbl      OUT NOCOPY Nodes_for_parent_tbl
    );



----------------------------
-- Get_MasterConfig_Nodes --
----------------------------
--  Key to call this API, input params to be passed
--  MC Root Node
--      p_mc_header_id = <header-id of the MC>
--      p_parent_rel_id = null
--      p_is_parent_subconfig = 'F'
--      p_parent_pos_path = null
--      p_is_top_config_node = 'T'
--      p_is_sub_config_node = 'F'
--
--  MC Node (except root node)
--      p_mc_header_id = <header-id of the MC>
--      p_parent_rel_id = <relationship-id of the MC Node>
--      p_is_parent_subconfig = 'F'
--      p_parent_pos_path = <position path of the parent-node>
--      p_is_top_config_node = 'F'
--      p_is_sub_config_node = 'F'
--
--  Subconfig Root Node (any level deep)
--      p_mc_header_id = <header-id of the subconfig>
--      p_parent_rel_id = <relationship-id of the MC node to which the subconfig is to be attached>
--      p_is_parent_subconfig = 'F' (if the MC node to which the subconfig is to be attached is not a subconfig itself, else 'T'>
--      p_parent_pos_path = <position path of the MC node to which the subconfig is to be attached>
--      p_is_top_config_node = 'T'
--      p_is_sub_config_node = 'T'
--
--  Subconfig Node (except root node, any level deep)
--      p_mc_header_id = <header-id of the subconfig>
--      p_parent_rel_id = <relationship-id of the subconfig node>
--      p_is_parent_subconfig = 'T'
--      p_parent_pos_path = <position path of the subconfig node>
--      p_is_top_config_node = 'F'
--      p_is_sub_config_node = 'T'
--



PROCEDURE Get_MasterConfig_Nodes
(
    p_api_version       IN      NUMBER,
    x_return_status         OUT     NOCOPY  VARCHAR2,
    x_msg_count             OUT     NOCOPY  NUMBER,
    x_msg_data              OUT     NOCOPY  VARCHAR2,
    p_mc_header_id      IN      NUMBER,
    p_parent_rel_id     IN      NUMBER,
    p_is_parent_subconfig   IN      VARCHAR2 := 'F',
    p_parent_pos_path   IN      VARCHAR2,
    p_is_top_config_node    IN      VARCHAR2 := 'F',
    p_is_sub_config_node    IN      VARCHAR2 := 'F',
    x_tree_node_tbl     OUT     NOCOPY  Tree_Node_Tbl_Type
)
IS



    -- Define cursor to get the number of children for a particular node
    CURSOR get_num_children
    (
        p_rel_id IN NUMBER
    )
    IS
        SELECT NVL(COUNT(*), 0) NUM_CHILDREN
        FROM AHL_MC_RELATIONSHIPS
        WHERE PARENT_RELATIONSHIP_ID = p_rel_id;

    -- Define cursor to check whether the particular node has any subconfig_association
    CURSOR check_subconfig_assos
    (
        p_relationship_id IN NUMBER
    )
    IS
        SELECT 'x'
        FROM AHL_MC_CONFIG_RELATIONS
        WHERE RELATIONSHIP_ID = p_relationship_id;

    -- Define cursor to get check whether MC exists, also retrieve relationship_id of the topnode
    CURSOR check_mc_exists
    (
        p_mc_header_id IN NUMBER
    )
    IS
        SELECT  RELATIONSHIP_ID,
                ACTIVE_END_DATE
        FROM    AHL_MC_RELATIONSHIPS
        WHERE   MC_HEADER_ID = p_mc_header_id AND
            PARENT_RELATIONSHIP_ID IS NULL;

    -- Define cursor to retrieve the position path id given a position path
    CURSOR get_pos_path_id
    (
        p_position_path IN VARCHAR2
    )
    IS
        SELECT NVL(path_position_id, 0)
        FROM ahl_mc_path_positions
        WHERE encoded_path_position = p_position_path;

    l_api_name  CONSTANT    VARCHAR2(30)    := 'Get_MasterConfig_Nodes';
    l_api_version   CONSTANT    NUMBER      := 1.0;

    l_tree_node_rec         AHL_MC_TREE_PVT.Tree_node_rec_type;
    l_topnode_rec           Nodes_for_parent_rec;
    l_tree_index            NUMBER := 0;

    l_pos_ref_code          VARCHAR2(30);
    l_pos_ref_meaning       VARCHAR2(80);
    l_ret_val           BOOLEAN;
    l_active_end_date               DATE;
    l_pos_path_tbl          AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;

    -- SATHAPLI::Bug 8363349, 16-Apr-2009, MC tree perf issue
    -- Nodes_list_for_parent           Nodes_for_parent_ref_csr;
    l_Nodes_for_parent_tbl   Nodes_for_parent_tbl;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Get_MasterConfig_Nodes_SP;

    -- Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    FND_MSG_PUB.Initialize;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body starts here
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- Log all input params
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path',
            'IN -- [p_mc_header_id = '||p_mc_header_id||'] [p_parent_rel_id = '||p_parent_rel_id||'] [p_is_parent_subconfig = '||p_is_parent_subconfig||']'
        );

        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path',
            'IN -- [p_parent_pos_path = '||p_parent_pos_path||'] [p_is_top_config_node = '||p_is_top_config_node||'] [p_is_sub_config_node = '||p_is_sub_config_node||']'
        );
    END IF;

    -- Verify MC exists, retrieve relationship_id of the topnode also
    OPEN check_mc_exists ( p_mc_header_id);
    FETCH check_mc_exists INTO l_dummy_number,l_active_end_date;
    IF (check_mc_exists%NOTFOUND)
    THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_MC_NOT_FOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_mc_exists;

    -- SATHAPLI : Time-specific debugs
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
            ' TSDL::About to call Get_nodes_for_parent ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss')
        );
    END IF;

        Get_nodes_for_parent (
    -- p_end_date           => l_active_end_date,
    p_relationship_id    => l_dummy_number,
    p_is_sub_config_node => p_is_sub_config_node,
    p_is_top_config_node => p_is_top_config_node,
    p_mc_header_id       => p_mc_header_id,
    p_parent_rel_id      => p_parent_rel_id,
    -- SATHAPLI::Bug 8363349, 16-Apr-2009, MC tree perf issue
    -- p_Get_nodes_csr      => Nodes_list_for_parent
    x_Get_nodes_tbl      => l_Nodes_for_parent_tbl
    );

    -- SATHAPLI : Time-specific debugs
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
            ' TSDL::Returned from Get_nodes_for_parent ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss')
        );
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
            ' TSDL::Loop start ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss')
        );
    END IF;

    -- Iterate through all retrieved nodes for the particular query
    -- SATHAPLI::Bug 8363349, 16-Apr-2009, MC tree perf issue
    /*
    LOOP
        FETCH Nodes_list_for_parent INTO l_topnode_rec;
        EXIT WHEN Nodes_list_for_parent%NOTFOUND;
    */
    FOR i IN l_Nodes_for_parent_tbl.FIRST..l_Nodes_for_parent_tbl.LAST
    LOOP
        l_topnode_rec := l_Nodes_for_parent_tbl(i);

        -- Populate all output params

        -- Populate MC node params
        l_tree_node_rec.RELATIONSHIP_ID         := l_topnode_rec.RELATIONSHIP_ID;
        l_tree_node_rec.OBJECT_VERSION_NUMBER           := l_topnode_rec.OBJECT_VERSION_NUMBER;
        l_tree_node_rec.POSITION_KEY                    := l_topnode_rec.POSITION_KEY;
        l_tree_node_rec.ITEM_GROUP_ID                   := l_topnode_rec.ITEM_GROUP_ID;
        l_tree_node_rec.POSITION_NECESSITY_CODE         := l_topnode_rec.POSITION_NECESSITY_CODE;
        l_tree_node_rec.POSITION_NECESSITY_MEANING  := l_topnode_rec.POSITION_NECESSITY_MEANING;
        --R12
        --priyan MEL-CDL
        l_tree_node_rec.ATA_CODE                := l_topnode_rec.ATA_CODE;
        l_tree_node_rec.ATA_MEANING         := l_topnode_rec.ATA_MEANING;

        l_tree_node_rec.UOM_CODE                        := l_topnode_rec.UOM_CODE;
        l_tree_node_rec.QUANTITY                    := l_topnode_rec.QUANTITY;
        l_tree_node_rec.DISPLAY_ORDER                   := l_topnode_rec.DISPLAY_ORDER;
        l_tree_node_rec.ACTIVE_START_DATE               := l_topnode_rec.ACTIVE_START_DATE;
        l_tree_node_rec.ACTIVE_END_DATE                 := l_topnode_rec.ACTIVE_END_DATE;

        -- Populate MC specific pars (for position path)
        l_tree_node_rec.MC_HEADER_ID                    := l_topnode_rec.MC_HEADER_ID;
        l_tree_node_rec.MC_ID                       := l_topnode_rec.MC_ID;
        l_tree_node_rec.VERSION_NUMBER              := l_topnode_rec.VERSION_NUMBER;

        -- Populate number of children
        OPEN get_num_children (l_topnode_rec.RELATIONSHIP_ID);
        FETCH get_num_children INTO l_tree_node_rec.NUM_CHILD_NODES;
        CLOSE get_num_children;

        -- Check whether node has any subconfiguration params, populate the same
        OPEN check_subconfig_assos (l_topnode_rec.RELATIONSHIP_ID);
        FETCH check_subconfig_assos INTO l_dummy_varchar;
        IF (check_subconfig_assos%FOUND)
        THEN
            l_tree_node_rec.HAS_SUBCONFIGS := 'T';
        ELSE
            l_tree_node_rec.HAS_SUBCONFIGS := 'F';
        END IF;
        CLOSE check_subconfig_assos;

        -- Populate output param flags

        IF (p_is_top_config_node = 'T')
        -- Implies that it is a rootnode, also for subconfig rootnode
        THEN
            l_tree_node_rec.IS_SUBCONFIG_NODE := 'F';
            l_tree_node_rec.IS_PARENT_SUBCONFIG :='F';

            -- If is is topnode, populate config_satus_code
            l_tree_node_rec.CONFIG_STATUS_CODE := l_topnode_rec.CONFIG_STATUS_CODE;
        END IF;

        IF (p_is_sub_config_node = 'T')
        -- Implies that it is a subconfig node, also for subconfig rootnode
        THEN
            l_tree_node_rec.IS_SUBCONFIG_NODE := 'T';
            l_tree_node_rec.IS_PARENT_SUBCONFIG := p_is_parent_subconfig;
        END IF ;

        IF (p_is_sub_config_node = 'T' AND p_is_top_config_node = 'T')
        -- Implies that it is the rootnode of a subconfig, will be true only in the case of a subconfig expand call
        THEN
            l_tree_node_rec.PARENT_RELATIONSHIP_ID          := p_parent_rel_id;
            -- l_tree_node_rec.IS_SUBCONFIG_TOPNODE     := 'T';
            l_tree_node_rec.IS_SUBCONFIG_TOPNODE        := 'F';

            -- Populate position path
            l_tree_node_rec.POSITION_PATH := AHL_MC_PATH_POSITION_PVT.get_encoded_path
                             (
                                p_parent_pos_path,
                                l_tree_node_rec.MC_ID,
                                l_tree_node_rec.VERSION_NUMBER,
                                l_tree_node_rec.POSITION_KEY,
                                'T'
                             );
        ELSE
            l_tree_node_rec.PARENT_RELATIONSHIP_ID          := l_topnode_rec.PARENT_RELATIONSHIP_ID;
            l_tree_node_rec.IS_SUBCONFIG_TOPNODE        := 'F';

            IF (p_is_top_config_node = 'T' AND p_is_sub_config_node = 'F')
            -- Implies that it is the rootnode of the MC, will be true only once, in the case of the first call to the API
            THEN
                -- Populate position path
                l_tree_node_rec.POSITION_PATH := to_char(l_tree_node_rec.MC_ID)||':'||to_char(l_tree_node_rec.VERSION_NUMBER)||':'||l_tree_node_rec.POSITION_KEY;
            ELSE
                -- Populate position path
                l_tree_node_rec.POSITION_PATH := AHL_MC_PATH_POSITION_PVT.get_encoded_path
                                 (
                                    p_parent_pos_path,
                                    l_tree_node_rec.MC_ID,
                                    l_tree_node_rec.VERSION_NUMBER,
                                    l_tree_node_rec.POSITION_KEY,
                                    'F'
                                 );
            END IF;

        END IF;

        -- Retrieve position path id
        OPEN get_pos_path_id(l_tree_node_rec.POSITION_PATH);
        FETCH get_pos_path_id INTO l_tree_node_rec.POSITION_PATH_ID;
        CLOSE get_pos_path_id;

        -- Reset flags to read position path specific position ref codes...
        l_pos_ref_code      := NULL;
        l_pos_ref_meaning   := NULL;
        l_ret_val       := FALSE;

        -- Only if it is a subconfig node, we should query for position path specific position reference code
        IF (p_is_sub_config_node = 'T')
        THEN
            IF (l_pos_path_tbl.COUNT > 0)
            THEN
                FOR i IN l_pos_path_tbl.FIRST..l_pos_path_tbl.LAST
                LOOP
                    l_pos_path_tbl(i).MC_ID := NULL;
                    l_pos_path_tbl(i).VERSION_NUMBER := NULL;
                    l_pos_path_tbl(i).POSITION_KEY  := NULL;
                END LOOP;
            END IF;

            -- Decode the retrieved position path to a position path table, since the input to get_posref_by_path is a position path table
            l_pos_path_tbl := Decode_Pos_Path(l_tree_node_rec.POSITION_PATH);

            -- Retrieve the position path specific position reference code, retrieves default position reference if no position path has already been created
            l_pos_ref_code := AHL_MC_PATH_POSITION_PVT.get_posref_by_path(l_pos_path_tbl, FND_API.G_TRUE);

            AHL_UTIL_MC_PKG.Convert_To_LookupMeaning
            (
                'AHL_POSITION_REFERENCE',
                l_pos_ref_code,
                l_pos_ref_meaning,
                l_ret_val
            );

            IF (l_ret_val = TRUE)
            THEN
                l_tree_node_rec.POSITION_REF_CODE   := l_pos_ref_code;
                l_tree_node_rec.POSITION_REF_MEANING    := l_pos_ref_meaning;
            ELSE
                l_tree_node_rec.POSITION_REF_CODE   := l_topnode_rec.POSITION_REF_CODE;
                l_tree_node_rec.POSITION_REF_MEANING    := l_topnode_rec.POSITION_REF_MEANING;
            END IF;
        ELSE
            l_tree_node_rec.POSITION_REF_CODE   := l_topnode_rec.POSITION_REF_CODE;
            l_tree_node_rec.POSITION_REF_MEANING    := l_topnode_rec.POSITION_REF_MEANING;
        END IF;

        -- Log some output params
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path',
                'OUT -- [num_chilren = '||l_tree_node_rec.NUM_CHILD_NODES||'] [has_subconfigs = '||l_tree_node_rec.HAS_SUBCONFIGS||'] [is_subconfig = '||l_tree_node_rec.IS_SUBCONFIG_NODE||']'
            );

            fnd_log.string
            (
                fnd_log.level_statement,
                'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path',
                'OUT -- [subconfig_top = '||l_tree_node_rec.IS_SUBCONFIG_TOPNODE||'] [parent_subconfig = '||l_tree_node_rec.IS_PARENT_SUBCONFIG||']'
            );

            fnd_log.string
            (
                fnd_log.level_statement,
                'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path',
                'OUT -- [position_path = '||l_tree_node_rec.POSITION_PATH||'] [position_path_id = '||l_tree_node_rec.POSITION_PATH_ID||']'
            );
        END IF;

        -- Add the tree node record to the output table
        l_tree_index := l_tree_index + 1;
        x_tree_node_tbl(l_tree_index) := l_tree_node_rec;

    END LOOP;
    -- CLOSE Nodes_list_for_parent;
    -- API body ends here

    -- SATHAPLI : Time-specific debugs
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
            ' TSDL::Loop end ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss')
        );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;
    -- API body ends here

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
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
        Rollback to Get_MasterConfig_Nodes_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Get_MasterConfig_Nodes_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Get_MasterConfig_Nodes_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Get_MasterConfig_Nodes',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

END Get_MasterConfig_Nodes;

---------------------
-- Decode_Pos_Path --
---------------------
FUNCTION Decode_Pos_Path
(
    p_encoded_path      IN      VARCHAR2
)
RETURN AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
IS

    G_NODE_SEP  VARCHAR2(1) := '/';
    G_ID_SEP    VARCHAR2(1) := ':';

    l_node_start    NUMBER := 0;
    l_node_end  NUMBER := 0;
    l_node_str  VARCHAR2(32);

    l_id_start  NUMBER := 0;
    l_id_end    NUMBER := 0;
    l_id_str    VARCHAR2(10);

    l_position_tbl  AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
    l_tbl_idx   NUMBER := 0;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    LOOP
        -- Tokenize input encoded position path string using node separator
        l_node_end := INSTR(p_encoded_path, G_NODE_SEP, l_node_start + 1);

        IF (l_node_end <= 0)
        THEN
            l_node_end := LENGTH(p_encoded_path) + 1;
        END IF;

        -- Retrieve the node tokens
        l_node_str := SUBSTR(p_encoded_path, l_node_start + 1, l_node_end - l_node_start - 1);
        l_node_start := l_node_end;

        -- Set the index for the output position path table
        l_tbl_idx := l_tbl_idx + 1;

        -- Retrieve the MC_ID from the node token
        l_id_end := INSTR(l_node_str, G_ID_SEP, 1);
        l_position_tbl(l_tbl_idx).MC_ID := TO_NUMBER(SUBSTR(l_node_str, 1, l_id_end - 1));
        l_id_start := l_id_end;

        -- Retrieve the VERSION_NUMBER from the node token
        l_id_end := INSTR(l_node_str, G_ID_SEP, l_id_start + 1);
        l_id_str := SUBSTR(l_node_str, l_id_start + 1, l_id_end - l_id_start - 1);
        IF (l_id_str <> '%')
        THEN
            l_position_tbl(l_tbl_idx).VERSION_NUMBER := TO_NUMBER(l_id_str);
        END IF;
        l_id_start := l_id_end;

        -- Retrieve the POSITION_KEY from the node token
        l_position_tbl(l_tbl_idx).POSITION_KEY := TO_NUMBER(SUBSTR(l_node_str, l_id_start + 1, l_node_end - l_id_start - 1));

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path',
                'l_position_tbl -- ['||l_tbl_idx||'] ['||l_position_tbl(l_tbl_idx).MC_ID||'] ['||l_position_tbl(l_tbl_idx).VERSION_NUMBER||'] ['||l_position_tbl(l_tbl_idx).POSITION_KEY||']'
            );
        END IF;

        EXIT WHEN l_node_end >= LENGTH(p_encoded_path);
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||G_PKG_NAME||'.Decode_Pos_Path.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    RETURN l_position_tbl;

END Decode_Pos_Path;

------------------------------------------------------------------
-- Precedure to get the cursor at runtime depending on the data --
------------------------------------------------------------------
-- SATHAPLI::Bug 8363349, 16-Apr-2009, MC tree perf issue
-- Modified Get_nodes_for_parent to return BULK COLLECTed table type.
-- Modified the cursor queries for performance tuning.
PROCEDURE Get_nodes_for_parent(
    -- p_end_date           IN DATE,
    p_relationship_id    IN NUMBER,
    p_is_sub_config_node IN VARCHAR2,
    p_is_top_config_node IN VARCHAR2,
    p_mc_header_id       IN NUMBER,
    p_parent_rel_id      IN NUMBER,
    -- p_Get_nodes_csr      IN OUT NOCOPY Nodes_for_parent_ref_csr
    x_Get_nodes_tbl      OUT NOCOPY Nodes_for_parent_tbl
    )
IS

CURSOR get_sub_config_root_details (p_relationship_id NUMBER,
                                    p_mc_header_id NUMBER) IS
    SELECT REL.RELATIONSHIP_ID,
           REL.OBJECT_VERSION_NUMBER,
           REL.POSITION_KEY,
           REL.PARENT_RELATIONSHIP_ID,
           REL.ITEM_GROUP_ID,
           REL.POSITION_REF_CODE,
           FPRC.MEANING POSITION_REF_MEANING,
           REL.ATA_CODE,
           FATA.MEANING ATA_MEANING,
           REL.POSITION_NECESSITY_CODE,
           FPNC.MEANING POSITION_NECESSITY_MEANING,
           REL.UOM_CODE,
           REL.QUANTITY,
           REL.DISPLAY_ORDER,
           REL.ACTIVE_START_DATE,
           REL.ACTIVE_END_DATE,
           REL.MC_HEADER_ID,
           HDR.MC_ID,
           HDR.VERSION_NUMBER,
           HDR.CONFIG_STATUS_CODE
      FROM AHL_MC_RELATIONSHIPS REL,
           (
            SELECT MCB.MC_HEADER_ID,
                   MCB.MC_ID,
                   MCB.VERSION_NUMBER,
                   DECODE (MCB.CONFIG_STATUS_CODE,
                           'CLOSED', MCB.CONFIG_STATUS_CODE,
                           DECODE (SIGN(TRUNC(NVL(MCR.ACTIVE_END_DATE, SYSDATE+1)) - TRUNC(SYSDATE)),
                                   1, MCB.CONFIG_STATUS_CODE, 'EXPIRED')) CONFIG_STATUS_CODE
              FROM AHL_MC_HEADERS_B MCB, AHL_MC_RELATIONSHIPS MCR
             WHERE MCB.MC_HEADER_ID            = MCR.MC_HEADER_ID
               AND MCR.PARENT_RELATIONSHIP_ID IS NULL
           ) HDR,
           FND_LOOKUP_VALUES FPRC,
           FND_LOOKUP_VALUES FPNC,
           FND_LOOKUP_VALUES FATA
     WHERE NVL(REL.PARENT_RELATIONSHIP_ID,0) = NVL(p_relationship_id,0)
       AND REL.MC_HEADER_ID = p_mc_header_id
       AND REL.MC_HEADER_ID = HDR.MC_HEADER_ID
       AND TRUNC(NVL(REL.ACTIVE_END_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
       AND FPRC.LOOKUP_CODE (+) = REL.POSITION_REF_CODE
       AND FPRC.LOOKUP_TYPE (+) = 'AHL_POSITION_REFERENCE'
       AND FPRC.LANGUAGE (+)    = USERENV('LANG')
       AND FPRC.VIEW_APPLICATION_ID (+) = 0
       AND FPNC.LOOKUP_CODE (+) = REL.POSITION_NECESSITY_CODE
       AND FPNC.LOOKUP_TYPE (+) = 'AHL_POSITION_NECESSITY'
       AND FPNC.LANGUAGE (+)    = USERENV('LANG')
       AND FPNC.VIEW_APPLICATION_ID (+) = 0
       AND FATA.LOOKUP_CODE (+) = REL.ATA_CODE
       AND FATA.LOOKUP_TYPE (+) = 'AHL_ATA_CODE'
       AND FATA.LANGUAGE (+)    = USERENV('LANG')
       AND FATA.VIEW_APPLICATION_ID (+) = 0
     ORDER BY DISPLAY_ORDER;

CURSOR get_root_details (p_mc_header_id NUMBER) IS
    SELECT REL.RELATIONSHIP_ID,
           REL.OBJECT_VERSION_NUMBER,
           REL.POSITION_KEY,
           REL.PARENT_RELATIONSHIP_ID,
           REL.ITEM_GROUP_ID,
           REL.POSITION_REF_CODE,
           FPRC.MEANING POSITION_REF_MEANING,
           REL.ATA_CODE,
           FATA.MEANING ATA_MEANING,
           REL.POSITION_NECESSITY_CODE,
           FPNC.MEANING POSITION_NECESSITY_MEANING,
           REL.UOM_CODE,
           REL.QUANTITY,
           REL.DISPLAY_ORDER,
           REL.ACTIVE_START_DATE,
           REL.ACTIVE_END_DATE,
           REL.MC_HEADER_ID,
           HDR.MC_ID,
           HDR.VERSION_NUMBER,
           DECODE (HDR.CONFIG_STATUS_CODE,
                   'CLOSED', HDR.CONFIG_STATUS_CODE,
                   DECODE (SIGN(TRUNC(NVL(REL.ACTIVE_END_DATE, SYSDATE+1)) - TRUNC(SYSDATE)),
                           1, HDR.CONFIG_STATUS_CODE, 'EXPIRED')) CONFIG_STATUS_CODE
      FROM AHL_MC_RELATIONSHIPS REL,
           AHL_MC_HEADERS_B HDR,
           FND_LOOKUP_VALUES FPRC,
           FND_LOOKUP_VALUES FPNC,
           FND_LOOKUP_VALUES FATA
     WHERE REL.PARENT_RELATIONSHIP_ID IS NULL
       AND REL.MC_HEADER_ID = p_mc_header_id
       AND REL.MC_HEADER_ID = HDR.MC_HEADER_ID
       AND FPRC.LOOKUP_CODE (+) = REL.POSITION_REF_CODE
       AND FPRC.LOOKUP_TYPE (+) = 'AHL_POSITION_REFERENCE'
       AND FPRC.LANGUAGE (+)    = USERENV('LANG')
       AND FPRC.VIEW_APPLICATION_ID (+) = 0
       AND FPNC.LOOKUP_CODE (+) = REL.POSITION_NECESSITY_CODE
       AND FPNC.LOOKUP_TYPE (+) = 'AHL_POSITION_NECESSITY'
       AND FPNC.LANGUAGE (+)    = USERENV('LANG')
       AND FPNC.VIEW_APPLICATION_ID (+) = 0
       AND FATA.LOOKUP_CODE (+) = REL.ATA_CODE
       AND FATA.LOOKUP_TYPE (+) = 'AHL_ATA_CODE'
       AND FATA.LANGUAGE (+)    = USERENV('LANG')
       AND FATA.VIEW_APPLICATION_ID (+) = 0
     ORDER BY DISPLAY_ORDER;

CURSOR get_children_details (p_parent_rel_id NUMBER,
                             p_mc_header_id NUMBER) IS
    SELECT REL.RELATIONSHIP_ID,
           REL.OBJECT_VERSION_NUMBER,
           REL.POSITION_KEY,
           REL.PARENT_RELATIONSHIP_ID,
           REL.ITEM_GROUP_ID,
           REL.POSITION_REF_CODE,
           FPRC.MEANING POSITION_REF_MEANING,
           REL.ATA_CODE,
           FATA.MEANING ATA_MEANING,
           REL.POSITION_NECESSITY_CODE,
           FPNC.MEANING POSITION_NECESSITY_MEANING,
           REL.UOM_CODE,
           REL.QUANTITY,
           REL.DISPLAY_ORDER,
           REL.ACTIVE_START_DATE,
           REL.ACTIVE_END_DATE,
           REL.MC_HEADER_ID,
           HDR.MC_ID,
           HDR.VERSION_NUMBER,
           HDR.CONFIG_STATUS_CODE
      FROM AHL_MC_RELATIONSHIPS REL,
           (
            SELECT MCB.MC_HEADER_ID,
                   MCB.MC_ID,
                   MCB.VERSION_NUMBER,
                   DECODE (MCB.CONFIG_STATUS_CODE,
                           'CLOSED', MCB.CONFIG_STATUS_CODE,
                           DECODE (SIGN(TRUNC(NVL(MCR.ACTIVE_END_DATE, SYSDATE+1)) - TRUNC(SYSDATE)),
                                   1, MCB.CONFIG_STATUS_CODE, 'EXPIRED')) CONFIG_STATUS_CODE
              FROM AHL_MC_HEADERS_B MCB, AHL_MC_RELATIONSHIPS MCR
             WHERE MCB.MC_HEADER_ID            = MCR.MC_HEADER_ID
               AND MCR.PARENT_RELATIONSHIP_ID IS NULL
           ) HDR,
           FND_LOOKUP_VALUES FPRC,
           FND_LOOKUP_VALUES FPNC,
           FND_LOOKUP_VALUES FATA
     WHERE NVL(REL.PARENT_RELATIONSHIP_ID,0) = NVL(p_parent_rel_id,0)
       AND REL.MC_HEADER_ID = p_mc_header_id
       AND REL.MC_HEADER_ID = HDR.MC_HEADER_ID
       AND TRUNC(NVL(REL.ACTIVE_END_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
       AND FPRC.LOOKUP_CODE (+) = REL.POSITION_REF_CODE
       AND FPRC.LOOKUP_TYPE (+) = 'AHL_POSITION_REFERENCE'
       AND FPRC.LANGUAGE (+)    = USERENV('LANG')
       AND FPRC.VIEW_APPLICATION_ID (+) = 0
       AND FPNC.LOOKUP_CODE (+) = REL.POSITION_NECESSITY_CODE
       AND FPNC.LOOKUP_TYPE (+) = 'AHL_POSITION_NECESSITY'
       AND FPNC.LANGUAGE (+)    = USERENV('LANG')
       AND FPNC.VIEW_APPLICATION_ID (+) = 0
       AND FATA.LOOKUP_CODE (+) = REL.ATA_CODE
       AND FATA.LOOKUP_TYPE (+) = 'AHL_ATA_CODE'
       AND FATA.LANGUAGE (+)    = USERENV('LANG')
       AND FATA.VIEW_APPLICATION_ID (+) = 0
     ORDER BY DISPLAY_ORDER;

BEGIN
/*
            IF (p_is_sub_config_node = 'T' and p_is_top_config_node = 'T')
        THEN
            OPEN p_Get_nodes_csr FOR

                -- Modified Query Below for Performance Issue 1 in Bug 4913944
                SELECT REL.RELATIONSHIP_ID,
                       REL.OBJECT_VERSION_NUMBER,
                       REL.POSITION_KEY,
                       REL.PARENT_RELATIONSHIP_ID,
                       REL.ITEM_GROUP_ID,
                       REL.POSITION_REF_CODE,
                       FPRC.MEANING POSITION_REF_MEANING,
                       --R12
                       --priyan MEL-CDL
                       REL.ATA_CODE,
                       FATA.MEANING ATA_MEANING,
                       REL.POSITION_NECESSITY_CODE,
                       FPNC.MEANING POSITION_NECESSITY_MEANING,
                       REL.UOM_CODE,
                       REL.QUANTITY,
                       REL.DISPLAY_ORDER,
                       REL.ACTIVE_START_DATE,
                       REL.ACTIVE_END_DATE,
                       REL.MC_HEADER_ID,
                       HDR.MC_ID,
                       HDR.VERSION_NUMBER,
                       HDR.CONFIG_STATUS_CODE
                  FROM AHL_MC_RELATIONSHIPS REL,
                       AHL_MC_HEADERS_V HDR,
                       FND_LOOKUP_VALUES_VL FPRC,
                       FND_LOOKUP_VALUES_VL FPNC,
                       FND_LOOKUP_VALUES_VL FATA
                 WHERE NVL(REL.PARENT_RELATIONSHIP_ID,0) = NVL(p_relationship_id,0)
                   AND REL.MC_HEADER_ID = p_mc_header_id
                   AND REL.MC_HEADER_ID = HDR.MC_HEADER_ID
                   AND TRUNC(NVL(REL.ACTIVE_END_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
                   AND FPRC.LOOKUP_CODE (+) = REL.POSITION_REF_CODE
                   AND FPRC.LOOKUP_TYPE (+) = 'AHL_POSITION_REFERENCE'
                   AND FPNC.LOOKUP_CODE (+) = REL.POSITION_NECESSITY_CODE
                   AND FPNC.LOOKUP_TYPE (+) = 'AHL_POSITION_NECESSITY'
                   AND FATA.LOOKUP_CODE (+) = REL.ATA_CODE
                   AND FATA.LOOKUP_TYPE (+) = 'AHL_ATA_CODE'
                 ORDER BY DISPLAY_ORDER;

        ELSIF p_parent_rel_id IS NULL
        THEN

        -- This query is only for the top node(Header) to fetch even the expired Master Configuration.

            OPEN p_Get_nodes_csr FOR

                -- Modified Query Below for Performance Issue 2 in Bug 4913944
                SELECT REL.RELATIONSHIP_ID,
                       REL.OBJECT_VERSION_NUMBER,
                       REL.POSITION_KEY,
                       REL.PARENT_RELATIONSHIP_ID,
                       REL.ITEM_GROUP_ID,
                       REL.POSITION_REF_CODE,
                       FPRC.MEANING POSITION_REF_MEANING,
                       --R12
                       --priyan MEL-CDL
                       REL.ATA_CODE,
                       FATA.MEANING ATA_MEANING,
                       REL.POSITION_NECESSITY_CODE,
                       FPNC.MEANING POSITION_NECESSITY_MEANING,
                       REL.UOM_CODE,
                       REL.QUANTITY,
                       REL.DISPLAY_ORDER,
                       REL.ACTIVE_START_DATE,
                       REL.ACTIVE_END_DATE,
                       REL.MC_HEADER_ID,
                       HDR.MC_ID,
                       HDR.VERSION_NUMBER,
                       HDR.CONFIG_STATUS_CODE
                  FROM AHL_MC_RELATIONSHIPS REL,
                       AHL_MC_HEADERS_V HDR,
                       FND_LOOKUP_VALUES_VL FPRC,
                       FND_LOOKUP_VALUES_VL FPNC,
                       FND_LOOKUP_VALUES_VL FATA
                 WHERE REL.PARENT_RELATIONSHIP_ID IS NULL
                   AND REL.MC_HEADER_ID = p_mc_header_id
                   AND REL.MC_HEADER_ID = HDR.MC_HEADER_ID
                   AND FPRC.LOOKUP_CODE (+) = REL.POSITION_REF_CODE
                   AND FPRC.LOOKUP_TYPE (+) = 'AHL_POSITION_REFERENCE'
                   AND FPNC.LOOKUP_CODE (+) = REL.POSITION_NECESSITY_CODE
                   AND FPNC.LOOKUP_TYPE (+) = 'AHL_POSITION_NECESSITY'
                   AND FATA.LOOKUP_CODE (+) = REL.ATA_CODE
                   AND FATA.LOOKUP_TYPE (+) = 'AHL_ATA_CODE'
                 ORDER BY DISPLAY_ORDER;

        ELSE
            OPEN p_Get_nodes_csr FOR

                -- Modified Query Below for Performance Issue 3 in Bug 4913944
                SELECT REL.RELATIONSHIP_ID,
                       REL.OBJECT_VERSION_NUMBER,
                       REL.POSITION_KEY,
                       REL.PARENT_RELATIONSHIP_ID,
                       REL.ITEM_GROUP_ID,
                       REL.POSITION_REF_CODE,
                       FPRC.MEANING POSITION_REF_MEANING,
                       --R12
                       --priyan MEL-CDL
                       REL.ATA_CODE,
                       FATA.MEANING ATA_MEANING,
                       REL.POSITION_NECESSITY_CODE,
                       FPNC.MEANING POSITION_NECESSITY_MEANING,
                       REL.UOM_CODE,
                       REL.QUANTITY,
                       REL.DISPLAY_ORDER,
                       REL.ACTIVE_START_DATE,
                       REL.ACTIVE_END_DATE,
                       REL.MC_HEADER_ID,
                       HDR.MC_ID,
                       HDR.VERSION_NUMBER,
                       HDR.CONFIG_STATUS_CODE
                  FROM AHL_MC_RELATIONSHIPS REL,
                       AHL_MC_HEADERS_V HDR,
                       FND_LOOKUP_VALUES_VL FPRC,
                       FND_LOOKUP_VALUES_VL FPNC,
                       FND_LOOKUP_VALUES_VL FATA
                 WHERE NVL(REL.PARENT_RELATIONSHIP_ID,0) = NVL(p_parent_rel_id,0)
                   AND REL.MC_HEADER_ID = p_mc_header_id
                   AND REL.MC_HEADER_ID = HDR.MC_HEADER_ID
                   AND TRUNC(NVL(REL.ACTIVE_END_DATE, SYSDATE + 1)) > TRUNC(SYSDATE)
                   AND FPRC.LOOKUP_CODE (+) = REL.POSITION_REF_CODE
                   AND FPRC.LOOKUP_TYPE (+) = 'AHL_POSITION_REFERENCE'
                   AND FPNC.LOOKUP_CODE (+) = REL.POSITION_NECESSITY_CODE
                   AND FPNC.LOOKUP_TYPE (+) = 'AHL_POSITION_NECESSITY'
                   AND FATA.LOOKUP_CODE (+) = REL.ATA_CODE
                   AND FATA.LOOKUP_TYPE (+) = 'AHL_ATA_CODE'
                 ORDER BY DISPLAY_ORDER;
        END IF;
*/

    IF (p_is_sub_config_node = 'T' and p_is_top_config_node = 'T') THEN
        OPEN get_sub_config_root_details(p_relationship_id, p_mc_header_id);
        FETCH get_sub_config_root_details BULK COLLECT INTO x_Get_nodes_tbl;
        CLOSE get_sub_config_root_details;
    ELSIF (p_parent_rel_id IS NULL) THEN
        -- This query is only for the top node (Header) to fetch even the expired Master Configuration.
        OPEN get_root_details(p_mc_header_id);
        FETCH get_root_details BULK COLLECT INTO x_Get_nodes_tbl;
        CLOSE get_root_details;
    ELSE
        OPEN get_children_details(p_parent_rel_id, p_mc_header_id);
        FETCH get_children_details BULK COLLECT INTO x_Get_nodes_tbl;
        CLOSE get_children_details;
    END IF;
END Get_nodes_for_parent;

End AHL_MC_TREE_PVT;

/
