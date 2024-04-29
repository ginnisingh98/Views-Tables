--------------------------------------------------------
--  DDL for Package Body AHL_UTIL_PC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UTIL_PC_PKG" as
/* $Header: AHLUPCXB.pls 120.4.12010000.2 2009/10/01 16:32:34 viagrawa ship $ */

    FUNCTION get_fmp_pc_node
    (
        p_pc_node_id        IN          NUMBER:= NULL,
        p_inventory_id      IN          NUMBER:= NULL
    )
    RETURN BOOLEAN
    IS

    CURSOR get_pc_asso
    IS
        SELECT  'X'
        FROM  ahl_pc_associations
        WHERE  pc_node_id IN (
            SELECT pc_node_id
            FROM ahl_pc_nodes_b
            START WITH pc_node_id = p_pc_node_id
            CONNECT BY parent_node_id = PRIOR pc_node_id )
        AND  unit_item_id = p_inventory_id;

    l_dummy VARCHAR2(100);

    BEGIN

        OPEN get_pc_asso;
        FETCH get_pc_asso INTO l_dummy;
        IF get_pc_asso%FOUND THEN
            CLOSE  get_pc_asso;
            RETURN TRUE;
        ELSE
            CLOSE  get_pc_asso;
            RETURN FALSE;
        END IF;

    END get_fmp_pc_node;


    FUNCTION get_uc_node
    (
        p_pc_node_id        IN          NUMBER := NULL,
        p_Item_Instance_ID  IN          NUMBER := NULL
    )
    RETURN BOOLEAN
    IS

    CURSOR get_uc_asso
    IS
        -- SAGARWAL::Bug# 5246104 SQL Id: 17237425
        /*
        SELECT 'X'
        FROM ahl_pc_associations
        WHERE pc_node_id IN (
            SELECT pc_node_id
            FROM ahl_pc_nodes_b
            CONNECT BY parent_node_id = PRIOR pc_node_id
            START WITH pc_node_id = p_pc_node_id)
        AND unit_item_id IN (
            SELECT Unit_config_header_ID
            FROM ahl_unit_header_details_v
            WHERE Csi_Item_Instance_ID = p_Item_Instance_ID)
            AND  association_type_flag='U';
        */
        SELECT 'X'
        FROM ahl_pc_associations
        WHERE pc_node_id IN (
              SELECT pc_node_id
              FROM ahl_pc_nodes_b
              CONNECT BY parent_node_id = PRIOR pc_node_id
              START WITH pc_node_id = p_pc_node_id)
          AND unit_item_id IN (
              SELECT Unit_config_header_ID
              FROM ahl_unit_config_headers
              WHERE Csi_Item_Instance_ID = p_Item_Instance_ID
                AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
          AND association_type_flag='U';

    CURSOR get_pc_asso
    IS
        -- SAGARWAL::Bug# 5246104 SQL Id: 17237441
        /*
        SELECT 'X'
        FROM ahl_pc_associations
        WHERE pc_node_id IN (
            SELECT pc_node_id
            FROM ahl_pc_nodes_b
            CONNECT BY parent_node_id = PRIOR pc_node_id
            START WITH pc_node_id = p_pc_node_id)
        AND unit_item_id in (
            SELECT inventory_item_id
            FROM csi_instance_details_v
            WHERE Instance_ID = p_Item_Instance_ID)
            AND association_type_flag='P';
        */
        SELECT 'X'
        FROM ahl_pc_associations
        WHERE pc_node_id IN (
            SELECT pc_node_id
            FROM ahl_pc_nodes_b
            CONNECT BY parent_node_id = PRIOR pc_node_id
            START WITH pc_node_id = p_pc_node_id)
        AND unit_item_id in (
            SELECT inventory_item_id
            FROM csi_item_instances
            WHERE Instance_ID = p_Item_Instance_ID)
        AND association_type_flag='P';

    l_dummy VARCHAR2(100);

    BEGIN

        OPEN get_uc_asso;
        FETCH get_uc_asso INTO l_dummy;
        IF get_uc_asso%FOUND THEN
            CLOSE  get_uc_asso;
            RETURN TRUE;
        ELSE
            CLOSE  get_pc_asso;
            OPEN get_pc_asso;
            FETCH get_pc_asso INTO l_dummy;
            IF get_pc_asso%FOUND THEN
                CLOSE get_pc_asso;
                RETURN TRUE;
            ELSE
                CLOSE get_pc_asso;
                RETURN FALSE;
            END IF;
        END IF;

    END get_uc_node;

    FUNCTION is_pc_complete
    (
        p_pc_header_id IN NUMBER
    )
    RETURN NUMBER
    IS

    CURSOR get_pc_details
    IS
        select primary_flag, status, association_type_flag
        from ahl_pc_headers_b
        where pc_header_id = p_pc_header_id;

    CURSOR check_unassigned_parts
    IS
        -- SATHAPLI::Bug# 5246104 SQL Id: 17237465
        /*
        SELECT DISTINCT
            MTL.INVENTORY_ITEM_ID
        FROM
            MTL_SYSTEM_ITEMS_KFV MTL,
            MTL_ITEM_STATUS STAT,
            AHL_PC_HEADERS_VL HEADER
        WHERE
            STAT.INVENTORY_ITEM_STATUS_CODE = MTL.INVENTORY_ITEM_STATUS_CODE AND
            MTL.ITEM_TYPE = HEADER.PRODUCT_TYPE_CODE AND
            MTL.ORGANIZATION_ID = FND_PROFILE.VALUE('ORG_ID') AND
            HEADER.PC_HEADER_ID = p_pc_header_id AND
            MTL.INVENTORY_ITEM_STATUS_CODE NOT IN ('Obsolete','Inactive') AND
            TRUNC(SYSDATE) BETWEEN NVL(TRUNC(MTL.START_DATE_ACTIVE), TRUNC(SYSDATE)) AND
            NVL(TRUNC(MTL.END_DATE_ACTIVE), TRUNC(SYSDATE))
        MINUS
        SELECT DISTINCT
            AHASS.UNIT_ITEM_ID
        FROM
            AHL_PC_ASSOCIATIONS_V AHASS,
            AHL_PC_NODES_B NODE
        WHERE
            AHASS.ASSOCIATION_TYPE_FLAG = 'I' AND
            AHASS.PC_NODE_ID = NODE.PC_NODE_ID AND
            NODE.PC_HEADER_ID = p_pc_header_id;
        */
        SELECT DISTINCT
            MTL.INVENTORY_ITEM_ID
        FROM
            MTL_SYSTEM_ITEMS_KFV MTL,
            MTL_ITEM_STATUS STAT,
            AHL_PC_HEADERS_B HEADER
        WHERE
            STAT.INVENTORY_ITEM_STATUS_CODE = MTL.INVENTORY_ITEM_STATUS_CODE AND
            MTL.ITEM_TYPE = HEADER.PRODUCT_TYPE_CODE AND
            -- SATHAPLI::Bug# 5576835, 17-Aug-2007
            /*
            MTL.ORGANIZATION_ID = FND_PROFILE.VALUE('ORG_ID') AND
            */
            MTL.ORGANIZATION_ID IN (SELECT DISTINCT MASTER_ORGANIZATION_ID FROM MTL_PARAMETERS) AND
            HEADER.PC_HEADER_ID = p_pc_header_id AND
            MTL.INVENTORY_ITEM_STATUS_CODE NOT IN ('Obsolete','Inactive') AND
            TRUNC(SYSDATE) BETWEEN NVL(TRUNC(MTL.START_DATE_ACTIVE), TRUNC(SYSDATE)) AND
            NVL(TRUNC(MTL.END_DATE_ACTIVE), TRUNC(SYSDATE))
        MINUS
        SELECT DISTINCT
            AHS.UNIT_ITEM_ID
        FROM
            AHL_PC_ASSOCIATIONS AHS,
            AHL_PC_NODES_B NODE
        WHERE
            AHS.ASSOCIATION_TYPE_FLAG = 'I' AND
            AHS.PC_NODE_ID = NODE.PC_NODE_ID AND
            NODE.PC_HEADER_ID = p_pc_header_id;

    -- ACL - PC Changes :: Bug 4684690
    -- Modified cursor check_unassigned_units to Include Quarantine and Deactivate Quarantine Status
    CURSOR check_unassigned_units
        IS
        -- SATHAPLI::Bug# 5246104 SQL Id: 17237482
        /*
            SELECT DISTINCT
                UNIT.UNIT_CONFIG_HEADER_ID
            FROM
                AHL_UNIT_CONFIG_HEADERS UNIT,
                CSI_ITEM_INSTANCES CSI,
                MTL_SYSTEM_ITEMS_KFV MTL,
                AHL_PC_HEADERS_B HEADER
            WHERE
                UNIT.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID AND
                CSI.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID AND
                CSI.LAST_VLD_ORGANIZATION_ID = MTL.ORGANIZATION_ID AND
                MTL.ITEM_TYPE = HEADER.PRODUCT_TYPE_CODE AND
                UNIT.UNIT_CONFIG_STATUS_CODE IN ('COMPLETE', 'INCOMPLETE','QUARANTINE','DEACTIVATE_QUARANTINE') AND
                HEADER.PC_HEADER_ID = p_pc_header_id AND
                TRUNC(SYSDATE) BETWEEN NVL(TRUNC(UNIT.ACTIVE_START_DATE), TRUNC(SYSDATE)) AND
                NVL(TRUNC(UNIT.ACTIVE_END_DATE), TRUNC(SYSDATE))

                -- SATHAPLI::Bug#5140968 fix --
                AND TRUNC(SYSDATE) < NVL(TRUNC(CSI.ACTIVE_END_DATE), TRUNC(SYSDATE + 1))

            MINUS
            SELECT
                AHASS.UNIT_ITEM_ID
            FROM
                AHL_PC_ASSOCIATIONS_V AHASS,
                AHL_PC_NODES_B NODE
            WHERE
                AHASS.ASSOCIATION_TYPE_FLAG = 'U' AND
                AHASS.PC_NODE_ID = NODE.PC_NODE_ID AND
            NODE.PC_HEADER_ID = p_pc_header_id;
        */
        SELECT DISTINCT
            UNIT.UNIT_CONFIG_HEADER_ID
        FROM
            AHL_UNIT_CONFIG_HEADERS UNIT,
            CSI_ITEM_INSTANCES CSI,
            MTL_SYSTEM_ITEMS_KFV MTL,
            AHL_PC_HEADERS_B HEADER
        WHERE
            UNIT.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID AND
            CSI.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID AND
            CSI.LAST_VLD_ORGANIZATION_ID = MTL.ORGANIZATION_ID AND
            MTL.ITEM_TYPE = HEADER.PRODUCT_TYPE_CODE AND
           -- bug  8970548 fix  UNIT.UNIT_CONFIG_STATUS_CODE
	    AHL_UTIL_UC_PKG.get_uc_status_code(unit.unit_config_header_id)
	    IN ('COMPLETE','INCOMPLETE','QUARANTINE','DEACTIVATE_QUARANTINE') AND
            HEADER.PC_HEADER_ID = p_pc_header_id AND
            TRUNC(SYSDATE) BETWEEN NVL(TRUNC(UNIT.ACTIVE_START_DATE), TRUNC(SYSDATE))
        AND
            NVL(TRUNC(UNIT.ACTIVE_END_DATE), TRUNC(SYSDATE))

            -- SATHAPLI::Bug#5140968 fix --
            AND TRUNC(SYSDATE) < NVL(TRUNC(CSI.ACTIVE_END_DATE), TRUNC(SYSDATE + 1))
        MINUS
        SELECT
            AHS.UNIT_ITEM_ID
        FROM
            AHL_PC_ASSOCIATIONS AHS,
            AHL_PC_NODES_B NODE
        WHERE
            AHS.ASSOCIATION_TYPE_FLAG = 'U' AND
            AHS.PC_NODE_ID = NODE.PC_NODE_ID AND
            NODE.PC_HEADER_ID = p_pc_header_id;


    l_pc_status     VARCHAR2(30) := 'DRAFT';
    l_pc_primary        VARCHAR2(1)  := 'N';
    l_pc_assos_type     VARCHAR2(1)  := null;
    l_dummy_id      NUMBER;

    BEGIN

        OPEN get_pc_details;
        FETCH get_pc_details INTO l_pc_primary, l_pc_status, l_pc_assos_type;
        CLOSE get_pc_details;

        IF l_pc_primary = 'Y' --and l_pc_status = 'COMPLETE'
        THEN
            IF (l_pc_assos_type = 'U')
            THEN
                OPEN check_unassigned_units;
                FETCH check_unassigned_units INTO l_dummy_id;
                IF (check_unassigned_units%FOUND)
                THEN
                    CLOSE check_unassigned_units;
                    RETURN -1;
                ELSE
                    CLOSE check_unassigned_units;
                    RETURN 0;
                END IF;
            ELSIF (l_pc_assos_type = 'I')
            THEN
                OPEN check_unassigned_parts;
                FETCH check_unassigned_parts INTO l_dummy_id;
                IF (check_unassigned_parts%FOUND)
                THEN
                    CLOSE check_unassigned_parts;
                    RETURN -1;
                ELSE
                    CLOSE check_unassigned_parts;
                    RETURN 0;
                END IF;
            ELSE
                RETURN 0;
            END IF;
        ELSE
            RETURN 0;
        END IF;

    END is_pc_complete;

END ahl_util_pc_pkg;

/
