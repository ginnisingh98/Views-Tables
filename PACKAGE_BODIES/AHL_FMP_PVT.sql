--------------------------------------------------------
--  DDL for Package Body AHL_FMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_PVT" AS
/* $Header: AHLVFMPB.pls 120.9.12010000.8 2010/04/22 01:55:20 sracha ship $ */

G_PKG_NAME      CONSTANT  VARCHAR2(30):= 'AHL_FMP_PVT';
G_APPLN_USAGE             VARCHAR2(30):=FND_PROFILE.VALUE('AHL_APPLN_USAGE');
--Define Global Cursor: get item instance attributes from ahl_unit_installed_details_v.
--The last two attributes: manufacturer_id and counctry_code are not in the view definition.
CURSOR get_inst_attri(c_item_instance_id NUMBER) IS
  /* perf fix for bug# 9620276
  SELECT serial_number, item_number, inventory_item_id,
         location_description, status, owner_name, condition,
         mfg_date, 'm' manufacturer_id, 'c' country_code
    FROM ahl_unit_installed_details_v
   WHERE csi_item_instance_id = c_item_instance_id;
  */

  SELECT ii.serial_number,
         (select kfv.concatenated_segments from mtl_system_items_kfv kfv
          where kfv.inventory_item_id = ii.inventory_item_id
            AND kfv.organization_id = ii.inv_master_organization_id) item_number,
         ii.inventory_item_id,
         ahl_util_uc_pkg.getcsi_locationDesc(ii.location_id, ii.location_type_code,
                                             ii.inv_organization_id, ii.inv_subinventory_name,
                                             ii.inv_locator_id, ii.wip_job_id) Location_description,
         (select f.meaning from csi_lookups f where ii.instance_usage_code = f.lookup_code
                            AND f.lookup_type = 'CSI_INSTANCE_USAGE_CODE') Status,
         (select p.party_name from csi_inst_party_details_v p
          where p.instance_id = ii.instance_id and p.relationship_type_code = 'OWNER') owner_name,
         (select mat.description from mtl_material_statuses mat where ii.INSTANCE_CONDITION_ID = mat.status_id) condition,
         (select to_date(ciea.attribute_value, 'DD/MM/YYYY')
          from csi_inst_extend_attrib_v ciea
          where ciea.instance_id = ii.instance_id
            AND ciea.attribute_code    = 'AHL_MFG_DATE'
            AND ciea.attribute_level   = 'GLOBAL') mfg_date,
         'm' manufacturer_id, 'c' country_code
  FROM csi_item_instances ii
  WHERE ii.instance_id = c_item_instance_id;

--Check whether the given item instance exists
  CURSOR check_instance_exists(c_item_instance_id NUMBER) IS
    SELECT instance_id
     FROM csi_item_instances
     WHERE instance_id = c_item_instance_id
     AND SYSDATE between nvl(active_start_date,sysdate) and NVL(active_end_date,sysdate+1);


--Get Inventory Item ID for a given item instance
  CURSOR get_inventory_item(c_item_instance_id NUMBER) IS
    SELECT inventory_item_id
      FROM csi_item_instances
     WHERE instance_id = c_item_instance_id
     AND SYSDATE between nvl(active_start_date,sysdate) and NVL(active_end_date,sysdate+1);

-- Declare Local Function CHECK_SN_INSIDE --

FUNCTION CHECK_SN_INSIDE(
  p_sn                          IN    VARCHAR2,
  p_sn1                         IN    VARCHAR2,
  p_sn2                         IN    VARCHAR2
) RETURN BOOLEAN;

-- Declare Local Function CHECK_SN_OUTSIDE --
FUNCTION CHECK_SN_OUTSIDE(
  p_sn                          IN    VARCHAR2,
  p_sn1                         IN    VARCHAR2,
  p_sn2                         IN    VARCHAR2
) RETURN BOOLEAN;

-- Declare Local Function CHECK_EFFECTIVITY_DETAILS --
FUNCTION CHECK_EFFECTIVITY_DETAILS(
  p_item_instance_id      IN  NUMBER,
  p_mr_effectivity_id     IN  NUMBER
) RETURN BOOLEAN;

-- Declare Local Function CHECK_EFFECTIVITY_DETAILS --
FUNCTION CHECK_EFFECTIVITY_EXT_DETAILS(
  p_item_instance_id      IN  NUMBER,
  p_mr_effectivity_id     IN  NUMBER
) RETURN BOOLEAN;

-- Declare local procedure GET_UCHEADER --
PROCEDURE get_ucHeader(
  p_item_instance_id  IN  NUMBER,
  x_ucHeaderID        OUT NOCOPY NUMBER,
  x_unitName          OUT NOCOPY VARCHAR2);

FUNCTION get_topInstanceID(p_item_instance_id  IN  NUMBER) RETURN NUMBER;

-- Define Procedure GET_MR_AFFECTED_ITEMS --
PROCEDURE GET_MR_AFFECTED_ITEMS(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_mr_header_id          IN  NUMBER,
  p_mr_effectivity_id     IN  NUMBER    := NULL,
  p_top_node_flag         IN  VARCHAR2  := 'N',
  p_unique_inst_flag      IN  VARCHAR2  := 'N',
  p_sort_flag             IN  VARCHAR2  := 'N',
  x_mr_item_inst_tbl      OUT NOCOPY MR_ITEM_INSTANCE_TBL_TYPE
) IS
  l_api_name              CONSTANT VARCHAR2(30) := 'GET_MR_AFFECTED_ITEMS';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_data              VARCHAR2(30);
  l_mr_header_id          NUMBER;
  l_index                 NUMBER;
  i                       NUMBER;
  l_inst_attri            get_inst_attri%ROWTYPE;
  l_debug                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
  l_error_flag            VARCHAR2(1) :='N';
--check whether the given mr exists
  CURSOR check_mr_exists(c_mr_header_id number)
  IS
    SELECT mr_header_id
      FROM ahl_mr_headers_app_v
     WHERE mr_header_id = c_mr_header_id;
--check whether the given mr_effecitivity_id exists
  CURSOR check_mr_effect(c_mr_effectivity_id number ,c_mr_header_id number)
  IS
  SELECT mr_header_id, mr_effectivity_id, inventory_item_id,relationship_id, pc_node_id
     FROM ahl_mr_effectivities_app_v
     WHERE mr_effectivity_id = NVL(c_mr_effectivity_id,mr_effectivity_id)
     AND   mr_header_id = c_mr_header_id;
  l_mr_effect             check_mr_effect%ROWTYPE;

--get all the MR effectivity definitions for a given MR(Actually this cursor returns
--the only specified mr_effecitivity_id if it is not null, otherwise it returns
--all the mr_effectivity_id's for the given MR).
  CURSOR get_mr_effect(c_mr_header_id NUMBER, c_mr_effectivity_id NUMBER)
  IS
   SELECT mr_header_id, mr_effectivity_id, inventory_item_id,relationship_id, pc_node_id
   FROM ahl_mr_effectivities_app_v
   WHERE mr_header_id = c_mr_header_id
   AND mr_effectivity_id = NVL(c_mr_effectivity_id, mr_effectivity_id);
--get distinct item instances from the global temporary table
  CURSOR get_dist_inst
  IS
    SELECT DISTINCT item_instance_id, serial_number, item_number,
           inventory_item_id, location, status, owner, condition
      FROM ahl_mr_instances_temp;
--get all item instances from the global temporary table
  CURSOR get_all_inst
  IS
    SELECT mr_effectivity_id, item_instance_id, serial_number, item_number,
           inventory_item_id, location, status, owner, condition
      FROM ahl_mr_instances_temp;
--get distinct item instances from the global temporary table and sort them.
  CURSOR get_dist_sort_inst
  IS
    SELECT DISTINCT item_instance_id, serial_number, item_number,
           inventory_item_id, location, status, owner, condition
      FROM ahl_mr_instances_temp
      ORDER BY item_number, serial_number;
--get unit_name and uc_header_id for an item instance
/*
  CURSOR get_uc_header(c_instance_id NUMBER) IS
    SELECT unit_config_header_id, name
      FROM ahl_unit_config_headers A
     WHERE csi_item_instance_id = c_instance_id
        OR EXISTS (SELECT 'X'
                     FROM csi_ii_relationships B
                    WHERE B.object_id = A.csi_item_instance_id
               START WITH subject_id = c_instance_id
               CONNECT BY subject_id = PRIOR object_id);
  l_get_uc_header                 get_uc_header%ROWTYPE;
*/
--only inventory item defined in MR effectivity definition, just top node
  /*CURSOR get_top_inst1(c_inventory_item_id NUMBER)
  IS
  SELECT instance_id
  FROM csi_item_instances A
  WHERE inventory_item_id = c_inventory_item_id
  AND SYSDATE between trunc(nvl(A.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
  AND NOT EXISTS (SELECT 'X'
                  FROM csi_ii_relationships B
                  WHERE B.subject_id = A.instance_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(B.active_start_date,sysdate)) and trunc(NVL(b.active_end_date,sysdate+1))
                  );*/
--same as before, but include all nodes, not only top node

  CURSOR get_inst1(c_inventory_item_id NUMBER)
  IS
  SELECT instance_id
    FROM csi_item_instances
    WHERE inventory_item_id = c_inventory_item_id
    AND SYSDATE between trunc(nvl(active_start_date,sysdate)) and trunc(nvl(active_end_date,sysdate+1));

--only position in MC defined in MR effectivity definition, just UC top node

  /*CURSOR get_top_inst2(c_relationship_id NUMBER)
  IS
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers a,ahl_applicable_instances b
     WHERE  a.csi_item_instance_id=b.csi_item_instance_id
     and   a.master_config_id=b.position_id
     AND   b.position_id=c_relationship_id
     and SYSDATE between trunc(nvl(A.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
     and   not exists (SELECT 'X'
                          FROM csi_ii_relationships
                          WHERE subject_id=b.csi_item_instance_id
                          AND   relationship_type_code='COMPONENT_OF');*/


--same as before, but include all nodes, not only top node
  CURSOR get_inst2(c_relationship_id NUMBER)
  IS
  SELECT a.csi_item_instance_id instance_id
  FROM ahl_unit_config_headers a,ahl_applicable_instances b
  WHERE  a.csi_item_instance_id=b.csi_item_instance_id
  and   b.position_id= c_relationship_id
  AND SYSDATE between trunc(nvl(A.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
  UNION
  SELECT a.subject_id instance_id
  FROM csi_ii_relationships a,ahl_applicable_instances b
  WHERE  a.subject_id=b.csi_item_instance_id
  and    b.position_id=c_relationship_id
  AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
  AND a.relationship_type_code = 'COMPONENT-OF';


--position in MC and inventory item defined in MR effectivity definition, just
--top node
  /*CURSOR get_top_inst3(c_relationship_id NUMBER, c_inventory_item_id NUMBER)
  IS
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A,ahl_applicable_instances api
    --WHERE A.master_config_id=api.position_id
    --AND A.csi_item_instance_id=api.csi_item_instance_id
    WHERE A.csi_item_instance_id=api.csi_item_instance_id
    AND api.position_id= C_RELATIONSHIP_ID
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate))
    AND trunc(nvl(a.active_end_date,sysdate+1))
    AND EXISTS (SELECT 'X'
                    FROM csi_item_instances B
                    WHERE B.instance_id = api.csi_item_instance_id
                    AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                    AND inventory_item_id = c_inventory_item_id);*/

--same as before, but include all nodes, not only top node
  CURSOR get_inst3(c_relationship_id NUMBER, c_inventory_item_id NUMBER)
  IS
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A,ahl_applicable_instances api
    WHERE  A.csi_item_instance_id=api.csi_item_instance_id
    AND    api.position_id=c_relationship_id
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate))
    and trunc(nvl(a.active_end_date,sysdate+1))
    AND EXISTS (SELECT 'X'
                FROM csi_item_instances B
                WHERE B.instance_id = api.csi_item_instance_id
                AND SYSDATE between trunc(nvl(b.active_start_date,sysdate))
                and trunc(nvl(b.active_end_date,sysdate+1))
                AND inventory_item_id = c_inventory_item_id)
     UNION
     SELECT subject_id instance_id
     FROM   csi_ii_relationships A,ahl_applicable_instances api
     WHERE  api.position_id=c_relationship_id
     and    api.csi_item_instance_id=a.subject_id
     AND relationship_type_code = 'COMPONENT-OF'
     AND SYSDATE between trunc(nvl(a.active_start_date,sysdate))
     and trunc(nvl(a.active_end_date,sysdate+1))
     AND EXISTS (SELECT 'X'
                 FROM csi_item_instances B
                 WHERE B.instance_id = api.csi_item_instance_id
                 AND sysdate between trunc(nvl(b.active_start_date,sysdate))
                 and trunc(nvl(b.active_end_date,sysdate+1))
                 AND inventory_item_id = c_inventory_item_id);
--inventory item and PC node defined in MR effectivity definition, just top node
  /*CURSOR get_top_inst4(c_inventory_item_id NUMBER, c_pc_node_id NUMBER)
  IS
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A
    WHERE EXISTS (SELECT 'X'
                  FROM csi_item_instances B
                  WHERE B.instance_id = A.csi_item_instance_id
                  AND sysdate between trunc(nvl(b.active_start_date,sysdate))
                  and trunc(nvl(b.active_end_date,sysdate+1))
                  AND B.inventory_item_id = c_inventory_item_id)
    AND EXISTS (SELECT 'X'
                FROM ahl_pc_associations C
                WHERE C.unit_item_id = A.unit_config_header_id
                AND C.association_type_flag = 'U'
                AND EXISTS (SELECT 'X'
                            FROM ahl_pc_nodes_b D
                            WHERE D.pc_node_id = C.pc_node_id
                            START WITH D.pc_node_id = c_pc_node_id
                            CONNECT BY D.parent_node_id = PRIOR D.pc_node_id))
     UNION
     SELECT instance_id
     FROM csi_item_instances A
     WHERE A.inventory_item_id = c_inventory_item_id
     AND sysdate between trunc(nvl(a.active_start_date,sysdate))
     and trunc(nvl(a.active_end_date,sysdate+1))
     AND NOT EXISTS (SELECT 'X'
                     FROM csi_ii_relationships B
                     WHERE B.subject_id = A.instance_id
                     AND sysdate between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                     AND B.relationship_type_code = 'COMPONENT-OF')
    AND EXISTS (SELECT 'X'
                FROM ahl_pc_associations C
                WHERE C.unit_item_id = A.inventory_item_id
                      AND C.association_type_flag = 'I'
                      AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_nodes_b D
                                   WHERE D.pc_node_id = C.pc_node_id
                              START WITH D.pc_node_id = c_pc_node_id
                              CONNECT BY D.parent_node_id = PRIOR D.pc_node_id));*/
--  same as before, but include all nodes, not only top node

  /*CURSOR get_inst4(c_inventory_item_id NUMBER, c_pc_node_id NUMBER) IS
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A
    WHERE EXISTS (SELECT 'X'
                  FROM csi_item_instances B
                  WHERE B.instance_id = A.csi_item_instance_id
                  AND sysdate between trunc(nvl(b.active_start_date,sysdate))
                  and trunc(nvl(b.active_end_date,sysdate+1))
                  AND B.inventory_item_id = c_inventory_item_id)
    AND EXISTS (SELECT 'X'
                FROM ahl_pc_associations C
                WHERE C.unit_item_id = A.unit_config_header_id
                AND C.association_type_flag = 'U'
                AND EXISTS (SELECT 'X'
                            FROM ahl_pc_nodes_b D
                            WHERE D.pc_node_id = C.pc_node_id
                            START WITH D.pc_node_id = c_pc_node_id
                            CONNECT BY D.parent_node_id = PRIOR D.pc_node_id))
     UNION
     SELECT instance_id
     FROM csi_item_instances A
     WHERE A.inventory_item_id = c_inventory_item_id
     AND sysdate between trunc(nvl(a.active_start_date,sysdate))
     and trunc(nvl(a.active_end_date,sysdate+1))
     AND NOT EXISTS (SELECT 'X'
                     FROM csi_ii_relationships B
                     WHERE B.subject_id = A.instance_id
                     AND sysdate between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                     AND B.relationship_type_code = 'COMPONENT-OF')
    AND EXISTS (SELECT 'X'
                FROM ahl_pc_associations C
                WHERE C.unit_item_id = A.inventory_item_id
                      AND C.association_type_flag = 'I'
                      AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_nodes_b D
                                   WHERE D.pc_node_id = C.pc_node_id
                              START WITH D.pc_node_id = c_pc_node_id
                              CONNECT BY D.parent_node_id = PRIOR D.pc_node_id))
    UNION -- aobe query added to fix bug number 5448015
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A,ahl_applicable_instances api
    WHERE SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND   a.csi_item_instance_id=api.csi_item_instance_id
    AND EXISTS (SELECT 'X'
                FROM csi_item_instances B
                WHERE B.instance_id = Api.csi_item_instance_id
                AND sysdate between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                AND B.inventory_item_id = c_inventory_item_id)
    AND EXISTS  (SELECT 'X'
                  FROM ahl_pc_associations C
                    WHERE C.unit_item_id = A.unit_config_header_id
                      AND C.association_type_flag = 'U'
                      AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_nodes_b D
                                   WHERE D.pc_node_id = C.pc_node_id
                              START WITH D.pc_node_id = c_pc_node_id
                              CONNECT BY D.parent_node_id = PRIOR D.pc_node_id))
    UNION
    SELECT a.subject_id instance_id
    FROM csi_ii_relationships A
    WHERE relationship_type_code = 'COMPONENT-OF'
    AND sysdate between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND A.SUBJECT_id IN (SELECT csi_item_instance_id from ahl_applicable_instances
                         where csi_item_instance_id=a.subject_id )
    AND EXISTS (SELECT 'X'
                   FROM csi_item_instances B
                   WHERE B.instance_id = A.subject_id
                   AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                   AND B.inventory_item_id = c_inventory_item_id)
    START WITH object_id IN (SELECT csi_item_instance_id
                             FROM ahl_unit_config_headers C
                             WHERE EXISTS (SELECT 'X'
                                           FROM ahl_pc_associations D
                                           WHERE D.unit_item_id = C.unit_config_header_id
                                           AND D.association_type_flag = 'U'
                                           AND EXISTS (SELECT 'X'
                                                       FROM ahl_pc_nodes_b E
                                                       WHERE E.pc_node_id = D.pc_node_id
                                                       START WITH E.pc_node_id = c_pc_node_id
                                                       CONNECT BY E.parent_node_id= PRIOR E.pc_node_id)))
    CONNECT BY object_id = PRIOR subject_id
    -- sunil- fix for bug7411016
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND a.relationship_type_code = 'COMPONENT-OF'
    UNION
    SELECT a.instance_id
    FROM csi_item_instances A
    WHERE A.inventory_item_id = c_inventory_item_id
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND EXISTS (SELECT 'X'
                FROM ahl_pc_associations B
                WHERE B.unit_item_id = A.inventory_item_id
                      AND B.association_type_flag = 'I'
                      AND EXISTS (SELECT 'X'
                                  FROM ahl_pc_nodes_b C
                                  WHERE C.pc_node_id = B.pc_node_id
                              START WITH C.pc_node_id = c_pc_node_id
                              CONNECT BY C.parent_node_id= PRIOR C.pc_node_id))
     UNION
       SELECT A.subject_id instance_id
       FROM csi_ii_relationships A
       WHERE relationship_type_code = 'COMPONENT-OF'
       AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
       AND EXISTS (SELECT 'X'
                   FROM csi_item_instances B
                   WHERE B.instance_id = A.subject_id
                   AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                   AND B.inventory_item_id = c_inventory_item_id
                   )
       START WITH object_id IN (SELECT C.instance_id
                         FROM csi_item_instances C
                         WHERE EXISTS (SELECT 'X'
                                          FROM ahl_pc_associations D
                                         WHERE D.unit_item_id = C.inventory_item_id
                                           AND D.association_type_flag = 'I'
                                           AND EXISTS (SELECT 'X'
                                                         FROM ahl_pc_nodes_b E
                                                        WHERE E.pc_node_id = D.pc_node_id
                                                   START WITH E.pc_node_id = c_pc_node_id
                                                   CONNECT BY E.parent_node_id= PRIOR E.pc_node_id)))
        CONNECT BY object_id = PRIOR subject_id
        -- sunil- fix for bug7411016
        AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
        AND a.relationship_type_code = 'COMPONENT-OF';*/
--position in MC and PC node defined in MR effectivity definition, just top node
  /*CURSOR get_top_inst5(c_relationship_id NUMBER, c_pc_node_id NUMBER) IS
  SELECT a.csi_item_instance_id instance_id
  FROM ahl_unit_config_headers A,ahl_applicable_instances api
  WHERE api.position_id = c_relationship_id
  and   a.csi_item_instance_id=api.csi_item_instance_id
  --and  A.master_config_id=api.position_id
  AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
  AND EXISTS (SELECT 'X'
                     FROM ahl_pc_associations B
                    WHERE B.unit_item_id = A.unit_config_header_id
                      AND B.association_type_flag = 'U'
                      AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_nodes_b C
                                   WHERE C.pc_node_id = B.pc_node_id
                              START WITH C.pc_node_id = c_pc_node_id
                              CONNECT BY C.parent_node_id = PRIOR C.pc_node_id))
    UNION
    SELECT a.csi_item_instance_id instance_id
     FROM ahl_unit_config_headers A,ahl_applicable_instances api
     WHERE api.position_id = c_relationship_id
    --and  A.master_config_id=api.position_id
     and   api.csi_item_instance_id=a.csi_item_instance_id
     AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
       AND EXISTS (SELECT 'X'
                     FROM csi_item_instances B
                    WHERE B.instance_id = A.csi_item_instance_id
                      AND EXISTS (SELECT 'X'
                                   FROM ahl_pc_associations C
                                   WHERE C.unit_item_id = B.inventory_item_id

                                     AND C.association_type_flag = 'I'
                                     AND EXISTS (SELECT 'X'
                                                   FROM ahl_pc_nodes_b D
                                                  WHERE D.pc_node_id = C.pc_node_id
                                             START WITH D.pc_node_id = c_pc_node_id
                                             CONNECT BY D.parent_node_id= PRIOR D.pc_node_id)
                                   )
                     );*/
--same as before, but include all node, not only top node
  /*CURSOR get_inst5(c_relationship_id NUMBER, c_pc_node_id NUMBER) IS
  SELECT a.csi_item_instance_id instance_id
  FROM ahl_unit_config_headers A,ahl_applicable_instances api
  WHERE   api.csi_item_instance_id=a.csi_item_instance_id
  and  api.position_id=c_relationship_id
  AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
  AND EXISTS (SELECT 'X'
                FROM ahl_pc_associations B
                WHERE B.unit_item_id = A.unit_config_header_id
                      AND B.association_type_flag = 'U'
                      AND EXISTS (SELECT 'X'
                                  FROM ahl_pc_nodes_b C
                                  WHERE C.pc_node_id = B.pc_node_id
                              START WITH C.pc_node_id = c_pc_node_id
                              CONNECT BY C.parent_node_id= PRIOR C.pc_node_id))
   UNION
   SELECT a.subject_id instance_id
   FROM csi_ii_relationships a
   WHERE relationship_type_code = 'COMPONENT-OF'
   AND   subject_id in (Select csi_item_instance_id from ahl_applicable_instances)
   AND sysdate between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
   START WITH object_id IN (SELECT csi_item_instance_id
                             FROM ahl_unit_config_headers Ax
                             WHERE ax.csi_item_instance_id=a.subject_id AND
                             EXISTS (SELECT 'X'
                                           FROM ahl_pc_associations B
                                           WHERE B.unit_item_id = Ax.unit_config_header_id
                                           AND B.association_type_flag = 'U'
                                           AND EXISTS (SELECT 'X'
                                                       FROM ahl_pc_nodes_b C
                                                       WHERE C.pc_node_id = B.pc_node_id
                                                   START WITH C.pc_node_id = c_pc_node_id
                                                   CONNECT BY C.parent_node_id= PRIOR C.pc_node_id)
                                            )
                             )
    CONNECT BY object_id = PRIOR subject_id
    -- sunil- fix for bug7411016
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND a.relationship_type_code = 'COMPONENT-OF'
     UNION
     SELECT a.csi_item_instance_id instance_id
     FROM ahl_unit_config_headers A,ahl_applicable_instances api
     WHERE api.position_id = c_relationship_id
     and   api.csi_item_instance_id= a.csi_item_instance_id
     AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
     AND EXISTS (SELECT 'X'
                   FROM csi_item_instances B
                   WHERE B.instance_id = api.csi_item_instance_id
                   AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                      AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_associations C
                                   WHERE C.unit_item_id = B.inventory_item_id
                                     AND C.association_type_flag = 'I'
                                     AND EXISTS (SELECT 'X'
                                                   FROM ahl_pc_nodes_b D
                                                  WHERE D.pc_node_id = C.pc_node_id
                                             START WITH D.pc_node_id = c_pc_node_id
                                             CONNECT BY D.parent_node_id= PRIOR D.pc_node_id)))
     UNION
     SELECT a.subject_id instance_id
     FROM csi_ii_relationships a
     WHERE a.relationship_type_code = 'COMPONENT-OF'
     AND   subject_id in (Select csi_item_instance_id from ahl_applicable_instances)
     AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
     AND subject_id in (select csi_item_instance_id from ahl_applicable_instances)
     START WITH object_id IN (SELECT ax.instance_id
                              FROM csi_item_instances Ax
                              WHERE SYSDATE between trunc(nvl(ax.active_start_date,sysdate)) and trunc(nvl(ax.active_end_date,sysdate+1))
		                      AND instance_id=a.subject_id
                              AND  EXISTS (SELECT 'X'
                                           FROM ahl_pc_associations B
                                           WHERE B.unit_item_id = Ax.inventory_item_id
                                           AND B.association_type_flag = 'I'
                                           AND EXISTS (SELECT 'X'
                                                       FROM ahl_pc_nodes_b C
                                                       WHERE C.pc_node_id = B.pc_node_id
                                                       START WITH C.pc_node_id = c_pc_node_id
                                                       CONNECT BY C.parent_node_id= PRIOR C.pc_node_id)
                                            )
                           )
CONNECT BY object_id = PRIOR subject_id
-- sunil- fix for bug7411016
AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
AND a.relationship_type_code = 'COMPONENT-OF';*/
--all inventory item, position in MC and PC node defined in MR effectivity
--definition, just top node
  /*CURSOR get_top_inst6(c_inventory_item_id NUMBER, c_relationship_id NUMBER, c_pc_node_id NUMBER) IS
    SELECT a.csi_item_instance_id instance_id
     FROM ahl_unit_config_headers A,ahl_applicable_instances api
     WHERE api.position_id = c_relationship_id
     AND   api.csi_item_instance_id=A.csi_item_instance_id
     --and  A.master_config_id=api.position_id
     AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
     AND EXISTS (SELECT 'X'
                     FROM csi_item_instances B
                    WHERE B.instance_id = Api.csi_item_instance_id
                      AND B.inventory_item_id = c_inventory_item_id)
     AND EXISTS (SELECT 'X'
                  FROM ahl_pc_associations C
                   WHERE C.unit_item_id = A.unit_config_header_id
                    AND C.association_type_flag = 'U'
                     AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_nodes_b D
                                   WHERE D.pc_node_id = C.pc_node_id
                              START WITH D.pc_node_id = c_pc_node_id
                              CONNECT BY D.parent_node_id = PRIOR D.pc_node_id))
     UNION
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A,ahl_applicable_instances api
    WHERE Api.position_id = c_relationship_id
    AND   A.csi_item_instance_id=API.csi_item_instance_id
    --and  A.master_config_id=api.position_id
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND EXISTS (SELECT 'X'
                     FROM csi_item_instances B
                    WHERE B.instance_id = A.csi_item_instance_id
                    AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                      AND B.inventory_item_id = c_inventory_item_id
                      AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_associations C
                                   WHERE C.unit_item_id = B.inventory_item_id
                                     AND C.association_type_flag = 'I'
                                     AND EXISTS (SELECT 'X'
                                                   FROM ahl_pc_nodes_b D
                                                  WHERE D.pc_node_id = C.pc_node_id
                                             START WITH D.pc_node_id = c_pc_node_id
                                             CONNECT BY D.parent_node_id= PRIOR D.pc_node_id)));*/
--same as before, but include all nodes, not only top node
  /*CURSOR get_inst6(c_inventory_item_id NUMBER, c_relationship_id NUMBER, c_pc_node_id NUMBER) IS
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A,ahl_applicable_instances api
    WHERE api.position_id = c_relationship_id
    AND   api.csi_item_instance_id=A.csi_item_instance_id
--    AND   subject_id in (Select csi_item_instance_id from ahl_applicable_instances)
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND EXISTS (SELECT 'X'
                   FROM csi_item_instances B
                   WHERE B.instance_id = api.csi_item_instance_id
                   AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                   AND B.inventory_item_id = c_inventory_item_id)
    AND EXISTS (SELECT 'X'
                   FROM ahl_pc_associations C
                   WHERE C.unit_item_id = A.unit_config_header_id
                   AND C.association_type_flag = 'U'
                   AND EXISTS (SELECT 'X'
                               FROM ahl_pc_nodes_b D
                               WHERE D.pc_node_id = C.pc_node_id
                              START WITH D.pc_node_id = c_pc_node_id
                              CONNECT BY D.parent_node_id= PRIOR D.pc_node_id))
    UNION
    SELECT a.subject_id instance_id
    FROM csi_ii_relationships A
    WHERE relationship_type_code = 'COMPONENT-OF'
    AND a.relationship_id  in (Select position_id from AHL_APPLICABLE_INSTANCES)
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
       AND EXISTS (SELECT 'X'
                   FROM csi_item_instances B
                   WHERE B.instance_id = A.subject_id
                   AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                   AND B.inventory_item_id = c_inventory_item_id)
                   START WITH object_id IN (SELECT c.csi_item_instance_id
                           FROM ahl_unit_config_headers C,ahl_applicable_instances api
                          WHERE c.csi_item_instance_id=api.csi_item_instance_id
                          and   api.position_id=c_relationship_id and
                          EXISTS (SELECT 'X'
                                          FROM ahl_pc_associations D
                                         WHERE D.unit_item_id = C.unit_config_header_id
                                           AND D.association_type_flag = 'U'
                                           AND EXISTS (SELECT 'X'
                                                         FROM ahl_pc_nodes_b E
                                                        WHERE E.pc_node_id = D.pc_node_id
                                                   START WITH E.pc_node_id = c_pc_node_id
                                                   CONNECT BY E.parent_node_id= PRIOR E.pc_node_id)))
CONNECT BY object_id = PRIOR subject_id
-- sunil- fix for bug7411016
AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
AND a.relationship_type_code = 'COMPONENT-OF'
     UNION
    SELECT a.csi_item_instance_id instance_id
    FROM ahl_unit_config_headers A,ahl_applicable_instances api
    WHERE api.position_id = c_relationship_id
    AND   A.csi_item_instance_id=API.csi_item_instance_id
    AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
    AND EXISTS (SELECT 'X'
                    FROM csi_item_instances B
                    WHERE B.instance_id = api.csi_item_instance_id
                    AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                    AND B.inventory_item_id = c_inventory_item_id
                    AND EXISTS (SELECT 'X'
                                    FROM ahl_pc_associations C
                                   WHERE C.unit_item_id = B.inventory_item_id
                                     AND C.association_type_flag = 'I'
                                     AND EXISTS (SELECT 'X'
                                                 FROM ahl_pc_nodes_b D
                                                 WHERE D.pc_node_id = C.pc_node_id
                                             START WITH D.pc_node_id = c_pc_node_id
                                             CONNECT BY D.parent_node_id= PRIOR D.pc_node_id)))
     UNION
    SELECT subject_id instance_id
    FROM csi_ii_relationships A
    WHERE relationship_type_code = 'COMPONENT-OF'
    AND a.subject_id in (Select csi_item_instance_id from AHL_APPLICABLE_INSTANCES )
       AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
       AND EXISTS (SELECT 'X'
                    FROM csi_item_instances B
                    WHERE B.instance_id = A.subject_id
                    AND SYSDATE between trunc(nvl(b.active_start_date,sysdate)) and trunc(nvl(b.active_end_date,sysdate+1))
                    AND B.inventory_item_id = c_inventory_item_id)
                    START WITH object_id IN (SELECT instance_id
                                              FROM csi_item_instances C
                                              WHERE SYSDATE between trunc(nvl(c.active_start_date,sysdate)) and trunc(nvl(C.active_end_date,sysdate+1))
                                              AND EXISTS (SELECT 'X'
                                                          FROM ahl_pc_associations D
                                                          WHERE D.unit_item_id = C.inventory_item_id
                                                          AND D.association_type_flag = 'I'
                                                           AND EXISTS (SELECT 'X'
                                                                         FROM ahl_pc_nodes_b E
                                                                        WHERE E.pc_node_id = D.pc_node_id
                                                                       START WITH E.pc_node_id = c_pc_node_id
                                                                       CONNECT BY E.parent_node_id= PRIOR E.pc_node_id)
                                                           )
                                                )
CONNECT BY object_id = PRIOR subject_id
-- sunil- fix for bug7411016
AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(nvl(a.active_end_date,sysdate+1))
AND a.relationship_type_code = 'COMPONENT-OF';*/

CURSOR get_inst4(c_inventory_item_id NUMBER, c_pc_node_id NUMBER) IS
SELECT A.instance_id
         FROM csi_item_instances A
         WHERE A.inventory_item_id = c_inventory_item_id
         AND sysdate between trunc(nvl(A.active_start_date,sysdate))
     and trunc(nvl(A.active_end_date,sysdate+1))
     AND AHL_FMP_PVT.is_pc_assoc_valid(A.instance_id,c_pc_node_id) = FND_API.G_TRUE;

CURSOR get_inst5(c_relationship_id NUMBER, c_pc_node_id NUMBER) IS
SELECT A.instance_id
         FROM csi_item_instances A,ahl_applicable_instances api
         WHERE A.instance_id = api.csi_item_instance_id
         AND sysdate between trunc(nvl(a.active_start_date,sysdate))  and trunc(nvl(a.active_end_date,sysdate+1))
         AND  api.position_id=c_relationship_id
         AND AHL_FMP_PVT.is_pc_assoc_valid(A.instance_id,c_pc_node_id) = FND_API.G_TRUE;

CURSOR get_inst6(c_inventory_item_id NUMBER, c_relationship_id NUMBER, c_pc_node_id NUMBER) IS
SELECT A.instance_id
         FROM csi_item_instances A,ahl_applicable_instances api
         WHERE A.instance_id = api.csi_item_instance_id
         AND sysdate between trunc(nvl(a.active_start_date,sysdate))  and trunc(nvl(a.active_end_date,sysdate+1))
         AND  api.position_id=c_relationship_id
         AND A.inventory_item_id = c_inventory_item_id
         AND AHL_FMP_PVT.is_pc_assoc_valid(A.instance_id,c_pc_node_id) = FND_API.G_TRUE;

l_counter number;
BEGIN
  SAVEPOINT GET_MR_AFFECTED_ITEMS_PVT;
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS');
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := 'S';
  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- Check whether the mr_header_id exists --
  AHL_DEBUG_PUB.debug(' Phase 1');

  DELETE FROM ahl_mr_instances_temp;
  DELETE FROM ahl_applicable_instances;

  OPEN check_mr_exists(p_mr_header_id);
  FETCH check_mr_exists INTO l_mr_header_id;
  IF check_mr_exists%NOTFOUND THEN
    CLOSE check_mr_exists;
    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_MR');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mr_exists;
    AHL_DEBUG_PUB.debug(' Phase 2');

-- Check whether the mr_effectivity_id exists and if it does, check whether it
-- belongs to the mr_header_id
    OPEN check_mr_effect(p_mr_effectivity_id,p_mr_header_id);
    LOOP
    FETCH check_mr_effect INTO l_mr_effect;
    EXIT WHEN  check_mr_effect%NOTFOUND ;

    IF l_mr_effect.relationship_id IS NOT NULL
    THEN
       AHL_MC_PATH_POSITION_PVT.map_position_to_instances
      (
       p_api_version     =>p_api_version,
       p_init_msg_list   =>FND_API.G_FALSE,
       p_commit          =>FND_API.G_FALSE,
       p_validation_level=>p_validation_level,
       p_position_id     =>l_mr_effect.relationship_id,
       x_return_status   =>l_return_Status,
       x_msg_count       =>l_msg_count,
       x_msg_data        =>l_msg_data
       );

        IF l_debug = 'Y' THEN
           AHL_DEBUG_PUB.debug(' After Call to MC path positions');
           Select count(*)  into l_counter
           from ahl_applicable_instances;
           AHL_DEBUG_PUB.debug('Number of Recs found in ahl_applicable_instances are ...'||l_counter);
        END IF;
    END IF;
     l_mr_header_id := l_mr_effect.mr_header_id;

     IF (l_mr_header_id <> p_mr_header_id) THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_MR_EFFECTIVITY');
        FND_MSG_PUB.ADD;
        l_error_flag:='Y';
      END IF;
    --END IF;
    END LOOP;
    CLOSE check_mr_effect;
    IF L_ERROR_FLAG='Y'
    THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;
  AHL_DEBUG_PUB.debug(' Phase 3 relation...' ||l_mr_effect.relationship_id);

  -- To avoid being in the same database session when refreshing or table navigating
  -- the same page due to using the global temporary table.
    AHL_DEBUG_PUB.debug(' Phase 4');
  l_index :=1;

  FOR l_mr_effect IN get_mr_effect(p_mr_header_id, p_mr_effectivity_id)
  LOOP
    IF (l_mr_effect.inventory_item_id IS NOT NULL AND l_mr_effect.relationship_id IS NULL
        AND l_mr_effect.pc_node_id IS NULL) THEN
        AHL_DEBUG_PUB.debug(' Phase 8');
      --DBMS_OUTPUT.put_line('API1: Come here in case 1B and l_index is: '||l_index);
        FOR l_get_inst1 IN get_inst1(l_mr_effect.inventory_item_id)
        LOOP
          AHL_DEBUG_PUB.debug(' Phase 9');
          IF (check_effectivity_details(l_get_inst1.instance_id, l_mr_effect.mr_effectivity_id )
             AND check_effectivity_ext_details(l_get_inst1.instance_id, l_mr_effect.mr_effectivity_id )) THEN
            x_mr_item_inst_tbl(l_index).item_instance_id := l_get_inst1.instance_id;
            x_mr_item_inst_tbl(l_index).mr_effectivity_id := l_mr_effect.mr_effectivity_id;
            l_index := l_index+1;
          END IF;
          AHL_DEBUG_PUB.debug(' Phase 10');
        END LOOP;
    ELSIF (l_mr_effect.relationship_id IS NOT NULL
       AND l_mr_effect.inventory_item_id IS NULL
       AND l_mr_effect.pc_node_id IS NULL)
     THEN
      --DBMS_OUTPUT.put_line('API1: Come here in case 2A and l_index is: '||l_index);
      --DBMS_OUTPUT.put_line('API1: Come here in case 2B and l_index is: '||l_index);
        FOR l_get_inst2 IN get_inst2(l_mr_effect.relationship_id) LOOP
          IF (check_effectivity_details(l_get_inst2.instance_id, l_mr_effect.mr_effectivity_id )
              AND check_effectivity_ext_details(l_get_inst2.instance_id, l_mr_effect.mr_effectivity_id )) THEN
            x_mr_item_inst_tbl(l_index).item_instance_id  := l_get_inst2.instance_id;
            x_mr_item_inst_tbl(l_index).mr_effectivity_id := l_mr_effect.mr_effectivity_id;
            l_index := l_index+1;
          END IF;
        END LOOP;
    ELSIF (l_mr_effect.relationship_id IS NOT NULL AND l_mr_effect.inventory_item_id IS NOT NULL
           AND l_mr_effect.pc_node_id IS NULL) THEN
      --DBMS_OUTPUT.put_line('API1: Come here in case 3B and l_index is: '||l_index);
        FOR l_get_inst3 IN get_inst3(l_mr_effect.relationship_id, l_mr_effect.inventory_item_id) LOOP
          IF (check_effectivity_details(l_get_inst3.instance_id, l_mr_effect.mr_effectivity_id )
              AND check_effectivity_ext_details(l_get_inst3.instance_id, l_mr_effect.mr_effectivity_id )) THEN
            x_mr_item_inst_tbl(l_index).item_instance_id  := l_get_inst3.instance_id;
            x_mr_item_inst_tbl(l_index).mr_effectivity_id := l_mr_effect.mr_effectivity_id;
            l_index := l_index+1;
          END IF;
        END LOOP;
    ELSIF (l_mr_effect.inventory_item_id IS NOT NULL AND l_mr_effect.pc_node_id IS NOT NULL
           AND l_mr_effect.relationship_id IS NULL) THEN
        --DBMS_OUTPUT.put_line('API1: Come here in case 4B and l_index is: '||l_index);
        FOR l_get_inst4 IN get_inst4(l_mr_effect.inventory_item_id, l_mr_effect.pc_node_id) LOOP
        --DBMS_OUTPUT.put_line('API1: Come here in case 4B after open cursor and l_index is: '||l_index);
          IF (check_effectivity_details(l_get_inst4.instance_id, l_mr_effect.mr_effectivity_id )
              AND check_effectivity_ext_details(l_get_inst4.instance_id, l_mr_effect.mr_effectivity_id )) THEN
            x_mr_item_inst_tbl(l_index).item_instance_id      := l_get_inst4.instance_id;
            x_mr_item_inst_tbl(l_index).mr_effectivity_id     := l_mr_effect.mr_effectivity_id;
            l_index := l_index+1;
          END IF;
        END LOOP;
    ELSIF (l_mr_effect.relationship_id IS NOT NULL AND l_mr_effect.pc_node_id IS NOT NULL
           AND l_mr_effect.inventory_item_id IS NULL) THEN
      --DBMS_OUTPUT.put_line('API1: Come here in case 5B and l_index is: '||l_index);
        FOR l_get_inst5 IN get_inst5(l_mr_effect.relationship_id, l_mr_effect.pc_node_id) LOOP
          IF (check_effectivity_details(l_get_inst5.instance_id, l_mr_effect.mr_effectivity_id )
              AND check_effectivity_ext_details(l_get_inst5.instance_id, l_mr_effect.mr_effectivity_id )) THEN
            x_mr_item_inst_tbl(l_index).item_instance_id  := l_get_inst5.instance_id;
            x_mr_item_inst_tbl(l_index).mr_effectivity_id := l_mr_effect.mr_effectivity_id;
            l_index := l_index+1;
          END IF;
        END LOOP;

    ELSIF (l_mr_effect.inventory_item_id IS NOT NULL AND l_mr_effect.relationship_id IS NOT NULL
           AND l_mr_effect.pc_node_id IS NOT NULL) THEN

      --DBMS_OUTPUT.put_line('API1: Come here in case 6B and l_index is: '||l_index);
        FOR l_get_inst6 IN get_inst6(l_mr_effect.inventory_item_id, l_mr_effect.relationship_id, l_mr_effect.pc_node_id) LOOP
          IF (check_effectivity_details(l_get_inst6.instance_id, l_mr_effect.mr_effectivity_id )
              AND check_effectivity_ext_details(l_get_inst6.instance_id, l_mr_effect.mr_effectivity_id )) THEN
            x_mr_item_inst_tbl(l_index).item_instance_id  := l_get_inst6.instance_id;
            x_mr_item_inst_tbl(l_index).mr_effectivity_id := l_mr_effect.mr_effectivity_id;
            l_index := l_index+1;
          END IF;
        END LOOP;

    END IF;
  END LOOP;
--DBMS_OUTPUT.put_line('API1: Come here after six cases and l_index is: '||l_index);
  IF x_mr_item_inst_tbl.COUNT > 0 THEN
    FOR i IN x_mr_item_inst_tbl.FIRST..x_mr_item_inst_tbl.LAST LOOP
    --DBMS_OUTPUT.put_line('API1: Before checking details in for loop: i= '||i);
    --Also filter OUT all of the items which are not job items
      IF(p_top_node_flag = 'Y') THEN
        x_mr_item_inst_tbl(i).item_instance_id  := get_topInstanceID(x_mr_item_inst_tbl(i).item_instance_id);
      END IF;
      OPEN get_inst_attri(x_mr_item_inst_tbl(i).item_instance_id);
      FETCH get_inst_attri INTO l_inst_attri;
      x_mr_item_inst_tbl(i).serial_number := l_inst_attri.serial_number;
      x_mr_item_inst_tbl(i).item_number := l_inst_attri.item_number;
      x_mr_item_inst_tbl(i).inventory_item_id := l_inst_attri.inventory_item_id;
      x_mr_item_inst_tbl(i).location := l_inst_attri.location_description;
      x_mr_item_inst_tbl(i).status := l_inst_attri.status;
      x_mr_item_inst_tbl(i).owner := l_inst_attri.owner_name;
      x_mr_item_inst_tbl(i).condition := l_inst_attri.condition;
      CLOSE get_inst_attri;

      AHL_FMP_COMMON_PVT.validate_item(x_return_status => l_return_status,
                                       x_msg_data => l_msg_data,
                                       p_item_number => NULL,
                                       p_x_inventory_item_id => x_mr_item_inst_tbl(i).inventory_item_id);
    --DBMS_OUTPUT.put_line('PL/SQL table count= '||x_mr_item_inst_tbl.COUNT||' and last= '||x_mr_item_inst_tbl.LAST);
      IF (l_return_status <> 'S')
      THEN
      --DBMS_OUTPUT.put_line('Deleting recored i= '||i);
        x_mr_item_inst_tbl.DELETE(i);
      END IF;
    END LOOP;

  --DBMS_OUTPUT.put_line('PL/SQL table count= '||x_mr_item_inst_tbl.COUNT||' and last= '||x_mr_item_inst_tbl.LAST);
    IF x_mr_item_inst_tbl.COUNT > 0 THEN
      FOR i IN x_mr_item_inst_tbl.FIRST..x_mr_item_inst_tbl.LAST LOOP
        IF x_mr_item_inst_tbl.EXISTS(i) THEN
          INSERT INTO ahl_mr_instances_temp
                 (
                   MR_INSTANCE_TEMP_ID,
                   MR_EFFECTIVITY_ID,
                   ITEM_INSTANCE_ID,
                   SERIAL_NUMBER,
                   ITEM_NUMBER,
                   INVENTORY_ITEM_ID,
                   LOCATION,
                   STATUS,
                   OWNER,
                   CONDITION,
                   UNIT_NAME,
                   UC_HEADER_ID
                 )
                 VALUES
                 (
                   i,
                   x_mr_item_inst_tbl(i).mr_effectivity_id,
                   x_mr_item_inst_tbl(i).item_instance_id,
                   x_mr_item_inst_tbl(i).serial_number,
                   x_mr_item_inst_tbl(i).item_number,
                   x_mr_item_inst_tbl(i).inventory_item_id,
                   x_mr_item_inst_tbl(i).location,
                   x_mr_item_inst_tbl(i).status,
                   x_mr_item_inst_tbl(i).owner,
                   x_mr_item_inst_tbl(i).condition,
                   NULL,
                   NULL
                 );
        END IF;
      END LOOP;
      i := 1;
      IF p_unique_inst_flag = 'Y' THEN
        IF p_sort_flag = 'Y' THEN
          FOR l_get_dist_inst IN get_dist_sort_inst LOOP
             x_mr_item_inst_tbl(i).mr_effectivity_id   := NULL;
             x_mr_item_inst_tbl(i).item_instance_id    := l_get_dist_inst.item_instance_id;
             x_mr_item_inst_tbl(i).serial_number       := l_get_dist_inst.serial_number;
             x_mr_item_inst_tbl(i).item_number         := l_get_dist_inst.item_number;
             x_mr_item_inst_tbl(i).inventory_item_id   := l_get_dist_inst.inventory_item_id;
             x_mr_item_inst_tbl(i).location            := l_get_dist_inst.location;
             x_mr_item_inst_tbl(i).status              := l_get_dist_inst.status;
             x_mr_item_inst_tbl(i).owner               := l_get_dist_inst.owner;
             x_mr_item_inst_tbl(i).condition           := l_get_dist_inst.condition;

             get_ucHeader(p_item_instance_id => x_mr_item_inst_tbl(i).item_instance_id,
                          x_ucHeaderID       => x_mr_item_inst_tbl(i).uc_header_id,
                          x_unitName         => x_mr_item_inst_tbl(i).unit_name);
             i := i+1;

          END LOOP;
        ELSE

          FOR l_get_dist_inst IN get_dist_inst LOOP
            x_mr_item_inst_tbl(i).mr_effectivity_id   := NULL;
            x_mr_item_inst_tbl(i).item_instance_id    := l_get_dist_inst.item_instance_id;
            x_mr_item_inst_tbl(i).serial_number       := l_get_dist_inst.serial_number;
            x_mr_item_inst_tbl(i).item_number         := l_get_dist_inst.item_number;
            x_mr_item_inst_tbl(i).inventory_item_id   := l_get_dist_inst.inventory_item_id;
            x_mr_item_inst_tbl(i).location            := l_get_dist_inst.location;
            x_mr_item_inst_tbl(i).status              := l_get_dist_inst.status;
            x_mr_item_inst_tbl(i).owner               := l_get_dist_inst.owner;
            x_mr_item_inst_tbl(i).condition           := l_get_dist_inst.condition;
            /*
            OPEN get_uc_header(x_mr_item_inst_tbl(i).item_instance_id);
            FETCH get_uc_header INTO l_get_uc_header;
            IF get_uc_header%NOTFOUND THEN
              x_mr_item_inst_tbl(i).unit_name := NULL;
              x_mr_item_inst_tbl(i).uc_header_id := NULL;
              CLOSE get_uc_header;
            ELSE
              x_mr_item_inst_tbl(i).unit_name := l_get_uc_header.name;
              x_mr_item_inst_tbl(i).uc_header_id := l_get_uc_header.unit_config_header_id;
              CLOSE get_uc_header;
            END IF;
            */
            get_ucHeader(p_item_instance_id => x_mr_item_inst_tbl(i).item_instance_id,
                         x_ucHeaderID       => x_mr_item_inst_tbl(i).uc_header_id,
                         x_unitName         => x_mr_item_inst_tbl(i).unit_name);
            i := i+1;
          END LOOP;
        END IF; -- p_sort_flag
      ELSE
        FOR l_get_all_inst IN get_all_inst LOOP
          x_mr_item_inst_tbl(i).mr_effectivity_id   := l_get_all_inst.mr_effectivity_id;
          x_mr_item_inst_tbl(i).item_instance_id    := l_get_all_inst.item_instance_id;
          x_mr_item_inst_tbl(i).serial_number       := l_get_all_inst.serial_number;
          x_mr_item_inst_tbl(i).item_number         := l_get_all_inst.item_number;
          x_mr_item_inst_tbl(i).inventory_item_id   := l_get_all_inst.inventory_item_id;
          x_mr_item_inst_tbl(i).location            := l_get_all_inst.location;
          x_mr_item_inst_tbl(i).status              := l_get_all_inst.status;
          x_mr_item_inst_tbl(i).owner               := l_get_all_inst.owner;
          x_mr_item_inst_tbl(i).condition           := l_get_all_inst.condition;
          /*
          OPEN get_uc_header(x_mr_item_inst_tbl(i).item_instance_id);
          FETCH get_uc_header INTO l_get_uc_header;
          IF get_uc_header%NOTFOUND THEN
            x_mr_item_inst_tbl(i).unit_name := NULL;
            x_mr_item_inst_tbl(i).uc_header_id := NULL;
            CLOSE get_uc_header;
          ELSE
            x_mr_item_inst_tbl(i).unit_name := l_get_uc_header.name;
            x_mr_item_inst_tbl(i).uc_header_id := l_get_uc_header.unit_config_header_id;
            CLOSE get_uc_header;
          END IF;
          */
          get_ucHeader(p_item_instance_id => x_mr_item_inst_tbl(i).item_instance_id,
                       x_ucHeaderID       => x_mr_item_inst_tbl(i).uc_header_id,
                       x_unitName         => x_mr_item_inst_tbl(i).unit_name);
          i := i+1;
        END LOOP;
      END IF;
      IF x_mr_item_inst_tbl.COUNT > i-1 THEN
        FOR j IN i..x_mr_item_inst_tbl.LAST LOOP
          IF x_mr_item_inst_tbl.EXISTS(j) THEN
            x_mr_item_inst_tbl.DELETE(j);
          END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;

  --DBMS_OUTPUT.put_line('API1: Just before commit and l_index= '||l_index);
  --IF FND_API.TO_BOOLEAN(p_commit) THEN
  --  COMMIT;
  --END IF;
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('End private API: AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
  ROLLBACK TO GET_MR_AFFECTED_ITEMS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                    'UNEXPECTED ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO GET_MR_AFFECTED_ITEMS_PVT;
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                   'ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
WHEN OTHERS THEN
  ROLLBACK TO GET_MR_AFFECTED_ITEMS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_FMP_PVT',
                            p_procedure_name => 'GET_MR_AFFECTED_ITEMS',
                            p_error_text     => SUBSTR(SQLERRM,1,240));
  END IF;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data,
                                    'OTHER ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_MR_AFFECTED_ITEMS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
END GET_MR_AFFECTED_ITEMS;

-- This API is revamped to fix Bug 6266738
-- Define procedure GET_APPLICABLE_MRS --
PROCEDURE GET_APPLICABLE_MRS(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_item_instance_id      IN  NUMBER,
  p_mr_header_id          IN  NUMBER    := NULL,
  p_components_flag       IN  VARCHAR2  := 'Y',
  p_include_doNotImplmt   IN  VARCHAR2  := 'Y',
  p_visit_type_code       IN  VARCHAR2  :=NULL,
  x_applicable_mr_tbl     OUT NOCOPY APPLICABLE_MR_TBL_TYPE
) IS


  l_api_name              CONSTANT VARCHAR2(30) := 'GET_APPLICABLE_MRS';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);
  l_item_instance_id      NUMBER;
  l_debug                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;


--Get inst_relation_rec for top node of UC
  CURSOR uc_top_inst(c_item_instance_id NUMBER) IS
    SELECT --NULL parent_item_instance_id,
           --a.csi_item_instance_id,
           --a.master_config_id,
           a.unit_config_header_id
     FROM ahl_unit_config_headers a
     WHERE a.csi_item_instance_id = c_item_instance_id
     /* Fix for bug#4052646
     * AND  a.parent_uc_header_id is not null -- Line commented
     */
     AND  a.parent_uc_header_id is null
     AND SYSDATE between trunc(nvl(a.active_start_date,sysdate)) and trunc(NVL(a.active_end_date,sysdate+1))
     ;
  l_uc_top_inst          uc_top_inst%ROWTYPE;

/* rewrote query for performance
CURSOR validate_pc_node_csr (c_instance_id NUMBER) --amsriniv
IS
    SELECT pc_node_id --amsriniv
    FROM    ahl_pc_nodes_b B
    --WHERE   B.pc_node_id = c_pc_node_id
    START WITH B.pc_node_id  IN (select pc_node_id
                                 from ahl_pc_associations itm, csi_item_instances csi,
                                     (SELECT object_id
                                      FROM csi_ii_relationships E
                                      START WITH E.subject_id = c_instance_id
                                      AND E.relationship_type_code = 'COMPONENT-OF'
                                      CONNECT BY E.subject_id = PRIOR E.object_id
                                      AND E.relationship_type_code = 'COMPONENT-OF'
                                      union all
                                      select c_instance_id
                                      from dual) ii
                                 where itm.association_type_flag = 'I'
                                   and itm.unit_item_id = csi.inventory_item_id
                                   and csi.instance_id = ii.object_id
                                 UNION ALL
                                 select pc_node_id
                                 from ahl_pc_associations unit, ahl_unit_config_headers uc,
                                      (SELECT object_id
                                       FROM csi_ii_relationships E
                                       START WITH E.subject_id = c_instance_id
                                       AND E.relationship_type_code = 'COMPONENT-OF'
                                       CONNECT BY E.subject_id = PRIOR E.object_id
                                       AND E.relationship_type_code = 'COMPONENT-OF'
                                       union
                                       select c_instance_id
                                       from dual) ii
                                 where unit.association_type_flag = 'U'
                                   and unit.unit_item_id = uc.unit_config_header_id
                                   and uc.csi_item_instance_id = ii.object_id)
    CONNECT BY B.pc_node_id = PRIOR B.parent_node_id;
*/

-- Get valid pc nodes for an instance
CURSOR validate_pc_node_csr (c_instance_id NUMBER,
                             c_pc_node_id  NUMBER)
IS
  WITH ii AS (SELECT object_id
                FROM csi_ii_relationships E
                START WITH E.subject_id = c_instance_id
                  -- sunil- fix for bug7411016
                  AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                  AND E.relationship_type_code = 'COMPONENT-OF'


                CONNECT BY E.subject_id = PRIOR E.object_id
                 -- sunil- fix for bug7411016
                  AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                  AND E.relationship_type_code = 'COMPONENT-OF'
              UNION ALL
              SELECT c_instance_id
                FROM DUAL)
    SELECT  'x' --pc_node_id --amsriniv
    FROM    ahl_pc_nodes_b B
    WHERE   B.pc_node_id = c_pc_node_id
    START WITH B.pc_node_id  IN (select pc_node_id
                                 from ahl_pc_associations itm, csi_item_instances csi,ii
                                 where itm.association_type_flag = 'I'
                                   and itm.unit_item_id = csi.inventory_item_id
                                   and csi.instance_id = ii.object_id
                                 UNION ALL
                                 select pc_node_id
                                 from ahl_pc_associations unit, ahl_unit_config_headers uc, ii
                                 where unit.association_type_flag = 'U'
                                   and unit.unit_item_id = uc.unit_config_header_id
                                   and uc.csi_item_instance_id = ii.object_id)
    CONNECT BY B.pc_node_id = PRIOR B.parent_node_id;

--Get attributes of a given MR
CURSOR get_mr_attri(c_mr_header_id NUMBER) IS
  SELECT repetitive_flag,
           show_repetitive_code,
           preceding_mr_header_id,
           copy_accomplishment_flag,
           implement_status_code,
           count_mr_descendents(c_mr_header_id) descendent_count
  FROM ahl_mr_headers_b --perf bug 6266738. using base tables.
  WHERE mr_header_id = c_mr_header_id;

l_get_mr_attri             get_mr_attri%ROWTYPE;

/* not used
-- Added for performance bug - 6138653
CURSOR csi_root_instance_csr (p_instance_id IN NUMBER) IS
    SELECT root.object_id
    FROM csi_ii_relationships root
    WHERE NOT EXISTS (SELECT 'x'
                      FROM csi_ii_relationships
                      WHERE subject_id = root.object_id
                        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      )
    START WITH root.subject_id = p_instance_id
               AND root.relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(root.active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(root.active_end_date, sysdate+1))
    CONNECT BY PRIOR root.object_id = root.subject_id
                     AND root.relationship_type_code = 'COMPONENT-OF'
                     AND trunc(nvl(root.active_start_date,sysdate)) <= trunc(sysdate)
                     AND trunc(sysdate) < trunc(nvl(root.active_end_date, sysdate+1));
*/

/* 12 Jul 08: rewrote for performance
--- Performance Changes bug - 6138653
CURSOR get_mr_details_csr(c_instance_id NUMBER, c_mr_header_id NUMBER, c_components_flag VARCHAR2) IS
SELECT A.mr_header_id, A.mr_effectivity_id, A.relationship_id, A.pc_node_id, A.inventory_item_id,
    cir.object_id, cir.subject_id, cir.position_reference
    FROM ahl_mr_effectivities A,
         ahl_mr_headers_app_v MR,
         (select cir2.object_id,
                 cii2.instance_id subject_id,
                 nvl(uc.master_config_id, cir2.position_reference) position_reference,
                 0 depth
          from csi_item_instances cii2, csi_ii_relationships cir2, ahl_unit_config_headers uc
          where cii2.instance_id = c_instance_id
            and cii2.instance_id = cir2.subject_id(+)
            and cii2.instance_id = uc.csi_item_instance_id(+)
            and uc.parent_uc_header_id(+) is null
            and SYSDATE between trunc(nvl(uc.active_start_date,sysdate)) and trunc(NVL(uc.active_end_date,sysdate+1))
          UNION ALL
          SELECT   a.object_id,
                   a.subject_id,
             to_number(a.position_reference), level depth
          FROM csi_ii_relationships a
          WHERE c_components_flag = 'Y'
          START WITH object_id = c_instance_id
          AND relationship_type_code = 'COMPONENT-OF'
          AND SYSDATE between trunc(nvl(active_start_date,sysdate)) and trunc(NVL(active_end_date,sysdate+1))
          CONNECT BY object_id = PRIOR subject_id
          AND relationship_type_code = 'COMPONENT-OF'
          AND SYSDATE between trunc(nvl(active_start_date,sysdate)) and trunc(NVL(active_end_date,sysdate+1))) cir,
          csi_item_instances cii
     WHERE A.mr_header_id = NVL(c_mr_header_id, A.mr_header_id)
       AND MR.mr_header_id = A.mr_header_id
       AND cir.subject_id = cii.instance_id
       AND MR.mr_status_code = 'COMPLETE'
       AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
       AND SYSDATE between trunc(MR.effective_from) and trunc(nvl(MR.effective_to,SYSDATE+1))
       AND MR.version_number in (SELECT max(MRM.version_number) from ahl_mr_headers_app_v MRM  where SYSDATE between trunc(MR.effective_from) and trunc(nvl(MR.effective_to,SYSDATE+1)) and title=mr.title and mr_status_code='COMPLETE' group by MRM.title)
       AND (A.inventory_item_id = cii.inventory_item_id OR
       (A.inventory_item_id IS NULL AND A.relationship_id IS NOT NULL AND
        AHL_FMP_PVT.Instance_Matches_Path_Pos(cii.instance_id,A.relationship_id) = 'T'))
       ORDER BY cir.depth, cir.subject_id;  -- depth, subject_id
*/

/* 15-Sept 08: Modified logic to seperate processing based Inventory Items, MC positions
CURSOR get_mr_details_csr(c_instance_id NUMBER, c_mr_header_id NUMBER, c_components_flag VARCHAR2) IS
   WITH cir AS (select --cir2.object_id,
                       cii2.instance_id subject_id,
                       --nvl(uc.master_config_id, cir2.position_reference) position_reference,
                       0 depth,
                       cii2.inventory_item_id
                from csi_item_instances cii2 --, csi_ii_relationships cir2, ahl_unit_config_headers uc
                where cii2.instance_id = c_instance_id
                  --and cii2.instance_id = cir2.subject_id(+)
                  --and cii2.instance_id = uc.csi_item_instance_id(+)
                  --and uc.parent_uc_header_id(+) is null
                  --and SYSDATE between trunc(nvl(uc.active_start_date,sysdate))
                  --and trunc(NVL(uc.active_end_date,sysdate+1))
                UNION ALL
                SELECT --a.object_id,
                       a.subject_id,
                       --to_number(a.position_reference),
                       level depth,
                       (select inventory_item_id
                        from csi_item_instances
                        where instance_id = a.subject_id) inventory_item_id
                FROM csi_ii_relationships a
                WHERE c_components_flag = 'Y'
                START WITH object_id = c_instance_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(active_start_date,sysdate))
                  AND trunc(NVL(active_end_date,sysdate+1))
               CONNECT BY object_id = PRIOR subject_id
                 AND relationship_type_code = 'COMPONENT-OF'
                 AND SYSDATE between trunc(nvl(active_start_date,sysdate))
                 AND trunc(NVL(active_end_date,sysdate+1))
              )
   SELECT * FROM (-- first query will match based on inventory items
                  SELECT A.mr_header_id, A.mr_effectivity_id,
                         -- A.relationship_id,
                         A.pc_node_id,
                         -- A.inventory_item_id,
                         -- cir.object_id,
                         cir.subject_id,
                         --cir.position_reference ,
                         cir.depth
                    FROM ahl_mr_headers_app_v MR, cir,
                         ahl_mr_effectivities A
                   WHERE A.mr_header_id = NVL(c_mr_header_id, A.mr_header_id)
                     AND MR.mr_header_id = A.mr_header_id
                     AND MR.mr_status_code = 'COMPLETE'
                     AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                     AND SYSDATE between trunc(MR.effective_from) and trunc(nvl(MR.effective_to,SYSDATE+1))
                     AND MR.version_number in (SELECT max(MRM.version_number)
                                               from ahl_mr_headers_app_v MRM
                                               where SYSDATE between trunc(MR.effective_from)
                                                 and trunc(nvl(MR.effective_to,SYSDATE+1))
                                                 and title=mr.title and mr_status_code='COMPLETE'
                                               group by MRM.title)
                     AND A.inventory_item_id = cir.inventory_item_id

                   UNION ALL

                   -- query will match based on path position
                   SELECT A.mr_header_id, A.mr_effectivity_id, --A.relationship_id,
                          A.pc_node_id, --A.inventory_item_id,
                          --cir.object_id,
                          cir.subject_id,
                          --cir.position_reference,
                          cir.depth
                     FROM ahl_mr_headers_app_v MR, ahl_mc_path_positions mcp,
                          --ahl_mc_headers_b hdr, ahl_mc_relationships rel,
                          cir, ahl_mr_effectivities A
                    WHERE A.mr_header_id = NVL(c_mr_header_id, A.mr_header_id)
                      AND MR.mr_header_id = A.mr_header_id
                      AND MR.mr_status_code = 'COMPLETE'
                      AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                      AND SYSDATE between trunc(MR.effective_from)
                      AND trunc(nvl(MR.effective_to,SYSDATE+1))
                      AND MR.version_number in (SELECT max(MRM.version_number)
                                                from ahl_mr_headers_app_v MRM
                                                where SYSDATE between trunc(MR.effective_from)
                                                  and trunc(nvl(MR.effective_to,SYSDATE+1))
                                                  and title=mr.title and mr_status_code='COMPLETE'
                                                group by MRM.title)
                      AND a.relationship_id = mcp.path_position_id
                      AND (a.inventory_item_id IS NULL OR a.inventory_item_id = cir.inventory_item_id)
                      -- AND TO_NUMBER(cir.POSITION_REFERENCE) = rel.RELATIONSHIP_ID
                      -- AND REL.mc_header_id = HDR.mc_header_id
                      AND AHL_FMP_PVT.Instance_Matches_Path_Pos(cir.subject_id,A.relationship_id) = 'T'
                      -- AND AHL_FMP_PVT.Instance_Matches_Path_Pos(cir.subject_id,A.relationship_id,
                      --                                          mcp.ENCODED_PATH_POSITION, hdr.mc_id,
                      --                                          hdr.version_number, rel.position_key) = 'T'

       ) appl_mr
       ORDER BY appl_mr.depth, appl_mr.subject_id;  -- depth, subject_id
*/

-- for the configuration components, get valid mr effectivities based on inventory items.
CURSOR get_comp_mr_inv_csr(c_instance_id NUMBER, c_mr_header_id NUMBER) IS
  SELECT A.mr_header_id, A.mr_effectivity_id,
         A.pc_node_id,
         ii.instance_id subject_id,
         (SELECT to_date(ciea1.attribute_value, 'DD/MM/YYYY')  from csi_inst_extend_attrib_v ciea1
	  WHERE ciea1.instance_id = ii.instance_id AND ciea1.attribute_code  = 'AHL_MFG_DATE'
	    AND ciea1.attribute_level = 'GLOBAL') mfg_date,
	 ii.serial_number --,
	 --(SELECT 'Y' from ahl_mr_effectivity_dtls where mr_effectivity_id = a.mr_effectivity_id and ROWNUM < 2) eff_dtls_flag
    FROM ( SELECT a.subject_id
           FROM csi_ii_relationships a
           START WITH object_id = c_instance_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(active_start_date,sysdate))
                  AND trunc(NVL(active_end_date,sysdate+1))
           CONNECT BY object_id = PRIOR subject_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(active_start_date,sysdate))
                  AND trunc(NVL(active_end_date,sysdate+1))
         ) cir, csi_item_instances ii,
         ahl_mr_effectivities A
    WHERE A.mr_header_id = NVL(c_mr_header_id, A.mr_header_id)
      AND ii.instance_id = cir.subject_id
      AND A.inventory_item_id = ii.inventory_item_id
      AND A.relationship_id is null
      AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                  WHERE MR.mr_header_id = A.mr_header_id
                    AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                    AND MR.version_number in (SELECT max(MRM.version_number)
                                              FROM ahl_mr_headers_app_v MRM
                                              WHERE mrm.title = mr.title
                                                AND SYSDATE between trunc(MRM.effective_from)
                                                AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                AND mr_status_code='COMPLETE'
                                             )
                 )

    -- ORDER BY ii.instance_id;
    ORDER BY A.mr_effectivity_id, A.mr_header_id;

-- for input instance, get valid mr effectivities based on inventory items.
CURSOR get_inst_mr_inv_csr(c_instance_id NUMBER, c_mr_header_id NUMBER) IS
  SELECT A.mr_header_id, A.mr_effectivity_id,
         A.pc_node_id,
         ii.instance_id subject_id,
         (SELECT to_date(ciea1.attribute_value, 'DD/MM/YYYY')  from csi_inst_extend_attrib_v ciea1
	  WHERE ciea1.instance_id = ii.instance_id AND ciea1.attribute_code  = 'AHL_MFG_DATE'
	    AND ciea1.attribute_level = 'GLOBAL') mfg_date,
	 ii.serial_number --,
	 --(SELECT 'Y' from ahl_mr_effectivity_dtls where mr_effectivity_id = a.mr_effectivity_id and ROWNUM < 2) eff_dtls_flag
    FROM csi_item_instances ii,
         ahl_mr_effectivities A
    WHERE ii.instance_id = c_instance_id
      AND A.mr_header_id = NVL(c_mr_header_id, A.mr_header_id)
      AND A.inventory_item_id = ii.inventory_item_id
      AND A.relationship_id is null
      AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                  WHERE MR.mr_header_id = A.mr_header_id
                    AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                    AND MR.version_number in (SELECT max(MRM.version_number)
                                              FROM ahl_mr_headers_app_v MRM
                                              WHERE mrm.title = mr.title
                                                AND SYSDATE between trunc(MRM.effective_from)
                                                AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                AND mr_status_code='COMPLETE'
                                             )
                 )
    --ORDER BY ii.instance_id;
    ORDER BY A.mr_effectivity_id, A.mr_header_id;


-- get valid mr effectivities based on path position ID.
CURSOR get_posn_mr_csr(c_mr_header_id NUMBER) IS
  SELECT A.mr_header_id, A.mr_effectivity_id,
         A.pc_node_id,
         cii.instance_id subject_id,
         (SELECT to_date(ciea1.attribute_value, 'DD/MM/YYYY')  from csi_inst_extend_attrib_v ciea1
	  WHERE  ciea1.instance_id = cii.instance_id AND ciea1.attribute_code  = 'AHL_MFG_DATE'
	    AND ciea1.attribute_level = 'GLOBAL') mfg_date,
	 cii.serial_number --,
	 --(SELECT 'Y' from ahl_mr_effectivity_dtls where mr_effectivity_id = a.mr_effectivity_id and ROWNUM < 2) eff_dtls_flag
    FROM ahl_applicable_instances aai,csi_item_instances cii,
         ahl_mr_effectivities A
   WHERE A.mr_header_id = NVL(c_mr_header_id, A.mr_header_id)
     AND A.relationship_id IS NOT NULL
     AND aai.position_id = A.relationship_id
     AND aai.csi_item_instance_id = cii.instance_id
     AND nvl(A.inventory_item_id,cii.inventory_item_id) = cii.inventory_item_id
     AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                  WHERE MR.mr_header_id = A.mr_header_id
                    AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                    AND MR.version_number in (SELECT max(MRM.version_number)
                                                FROM ahl_mr_headers_app_v MRM
                                               WHERE mrm.title = mr.title
                                                 AND SYSDATE between trunc(MRM.effective_from)
                                                 AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                 AND mr_status_code='COMPLETE'
                                             )
                )
   --ORDER BY cii.instance_id;
   ORDER BY A.mr_effectivity_id, A.mr_header_id;


/* 12 Jul 08: Modified for performance.
CURSOR get_visit_mr_details_csr(c_instance_id NUMBER, c_visit_type_code VARCHAR2) IS
SELECT A.mr_header_id, A.mr_effectivity_id, A.relationship_id, A.pc_node_id, A.inventory_item_id,
    cir.object_id, cir.subject_id, cir.position_reference
    FROM ahl_mr_effectivities A, ahl_mr_headers_app_v MR, ahl_mr_visit_types vis,
         (select cir2.object_id,
                 cii2.instance_id subject_id,
                 nvl(uc.master_config_id, cir2.position_reference) position_reference,
                 0 depth
          from csi_item_instances cii2, csi_ii_relationships cir2, ahl_unit_config_headers uc
          where cii2.instance_id = c_instance_id
            and cii2.instance_id = cir2.subject_id(+)
            and cii2.instance_id = uc.csi_item_instance_id(+)
            and uc.parent_uc_header_id(+) is null
            and SYSDATE between trunc(nvl(uc.active_start_date,sysdate)) and trunc(NVL(uc.active_end_date,sysdate+1))
          ) cir,
          csi_item_instances cii
     WHERE MR.mr_header_id = A.mr_header_id
       AND A.mr_header_id = vis.mr_header_id
       AND vis.mr_visit_type_code = c_visit_type_code
       AND cir.subject_id = cii.instance_id
       AND MR.mr_status_code = 'COMPLETE'
       AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
       AND SYSDATE between trunc(MR.effective_from) and trunc(nvl(MR.effective_to,SYSDATE+1))
       AND MR.version_number in (SELECT max(MRM.version_number) from ahl_mr_headers_app_v MRM  where SYSDATE between trunc(MR.effective_from) and trunc(nvl(MR.effective_to,SYSDATE+1)) and title=mr.title and mr_status_code='COMPLETE' group by MRM.title)
       AND (A.inventory_item_id = cii.inventory_item_id OR
       (A.inventory_item_id IS NULL AND A.relationship_id IS NOT NULL AND
        AHL_FMP_PVT.Instance_Matches_Path_Pos(cii.instance_id,A.relationship_id) = 'T'))
       ORDER BY cir.depth, cir.subject_id;  -- depth, subject_id
*/

/* 15-Sept 08: Modified logic to seperate processing based Inventory Items, MC positions
CURSOR get_visit_mr_details_csr(c_instance_id NUMBER, c_visit_type_code VARCHAR2) IS
   WITH cir AS (select --cir2.object_id,
                       cii2.instance_id subject_id,
                       --nvl(uc.master_config_id, cir2.position_reference) position_reference,
                       0 depth,
                       cii2.inventory_item_id
                from csi_item_instances cii2 --, csi_ii_relationships cir2, ahl_unit_config_headers uc
                where cii2.instance_id = c_instance_id
                   --and cii2.instance_id = cir2.subject_id(+)
                   --and cii2.instance_id = uc.csi_item_instance_id(+)
                   --and uc.parent_uc_header_id(+) is null
                   --and SYSDATE between trunc(nvl(uc.active_start_date,sysdate))
                   --and trunc(NVL(uc.active_end_date,sysdate+1))
              )
   SELECT * FROM (-- first query will match based on inventory items
                  SELECT A.mr_header_id, A.mr_effectivity_id,
                         -- A.relationship_id,
                         A.pc_node_id,
                         -- A.inventory_item_id,
                         --cir.object_id,
                         cir.subject_id,
                         --cir.position_reference ,
                         cir.depth
                    FROM ahl_mr_headers_app_v MR, ahl_mr_visit_types vis, cir,
                         ahl_mr_effectivities A
                   WHERE MR.mr_header_id = A.mr_header_id
                     AND A.mr_header_id = vis.mr_header_id
                     AND vis.mr_visit_type_code = c_visit_type_code
                     AND MR.mr_status_code = 'COMPLETE'
                     AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                     AND SYSDATE between trunc(MR.effective_from) and trunc(nvl(MR.effective_to,SYSDATE+1))
                     AND MR.version_number in (SELECT max(MRM.version_number)
                                               from ahl_mr_headers_app_v MRM
                                               where SYSDATE between trunc(MR.effective_from)
                                                 and trunc(nvl(MR.effective_to,SYSDATE+1))
                                                 and title=mr.title and mr_status_code='COMPLETE'
                                               group by MRM.title)
                     AND A.inventory_item_id = cir.inventory_item_id

                   UNION ALL

                   -- query will match based on path position
                   SELECT A.mr_header_id, A.mr_effectivity_id, --A.relationship_id,
                          A.pc_node_id, --A.inventory_item_id,
                          --cir.object_id,
                          cir.subject_id,
                          --cir.position_reference,
                          cir.depth
                     FROM ahl_mr_headers_app_v MR, ahl_mr_visit_types vis, ahl_mc_path_positions mcp,
                          --ahl_mc_headers_b hdr, ahl_mc_relationships rel,
                          cir, ahl_mr_effectivities A
                    WHERE MR.mr_header_id = A.mr_header_id
                      AND A.mr_header_id = vis.mr_header_id
                      AND vis.mr_visit_type_code = c_visit_type_code
                      AND MR.mr_status_code = 'COMPLETE'
                      AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                      AND SYSDATE between trunc(MR.effective_from)
                      AND trunc(nvl(MR.effective_to,SYSDATE+1))
                      AND MR.version_number in (SELECT max(MRM.version_number)
                                                from ahl_mr_headers_app_v MRM
                                                where SYSDATE between trunc(MR.effective_from)
                                                  and trunc(nvl(MR.effective_to,SYSDATE+1))
                                                  and title=mr.title and mr_status_code='COMPLETE'
                                                group by MRM.title)
                      AND a.relationship_id = mcp.path_position_id
                      AND (a.inventory_item_id IS NULL OR a.inventory_item_id = cir.inventory_item_id)
                      -- AND TO_NUMBER(cir.POSITION_REFERENCE) = rel.RELATIONSHIP_ID
                      -- AND REL.mc_header_id = HDR.mc_header_id
                      AND AHL_FMP_PVT.Instance_Matches_Path_Pos(cir.subject_id,A.relationship_id) = 'T'
                      -- AND AHL_FMP_PVT.Instance_Matches_Path_Pos(cir.subject_id,A.relationship_id,
                      --                                          mcp.ENCODED_PATH_POSITION, hdr.mc_id,
                      --                                          hdr.version_number, rel.position_key) = 'T'

       ) appl_mr
       ORDER BY appl_mr.depth, appl_mr.subject_id;  -- depth, subject_id
*/

-- for the configuration components, get valid mr effectivities based on inventory items.
CURSOR get_comp_vst_inv_csr(c_instance_id NUMBER, c_visit_type_code VARCHAR2) IS
  SELECT A.mr_header_id, A.mr_effectivity_id,
         A.pc_node_id,
         cii.instance_id subject_id,
         (SELECT to_date(ciea1.attribute_value, 'DD/MM/YYYY')  from csi_inst_extend_attrib_v ciea1
	  WHERE  ciea1.instance_id = cii.instance_id AND ciea1.attribute_code  = 'AHL_MFG_DATE'
	    AND ciea1.attribute_level = 'GLOBAL') mfg_date,
	 cii.serial_number --,
	 --(SELECT 'Y' from ahl_mr_effectivity_dtls where mr_effectivity_id = a.mr_effectivity_id and ROWNUM < 2) eff_dtls_flag
    FROM ( SELECT a.subject_id
           FROM csi_ii_relationships a
           START WITH object_id = c_instance_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(active_start_date,sysdate))
                  AND trunc(NVL(active_end_date,sysdate+1))
           CONNECT BY object_id = PRIOR subject_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(active_start_date,sysdate))
                  AND trunc(NVL(active_end_date,sysdate+1))
         ) cir, csi_item_instances cii, ahl_mr_visit_types vis,
         ahl_mr_effectivities A
    WHERE A.mr_header_id = vis.mr_header_id
      AND vis.mr_visit_type_code = c_visit_type_code
      AND cir.subject_id = cii.instance_id
      AND A.inventory_item_id = cii.inventory_item_id
      AND A.relationship_id is null
      AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                  WHERE MR.mr_header_id = A.mr_header_id
                    AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                    AND MR.version_number in (SELECT max(MRM.version_number)
                                              FROM ahl_mr_headers_app_v MRM
                                              WHERE mrm.title = mr.title
                                                AND SYSDATE between trunc(MRM.effective_from)
                                                AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                AND mr_status_code='COMPLETE'
                                             )
                 )
    -- ORDER BY cii.instance_id;
    ORDER BY A.mr_effectivity_id,A.mr_header_id;


-- for input instance, get valid mr effectivities based on inventory items.
CURSOR get_inst_vst_inv_csr(c_instance_id NUMBER, c_visit_type_code VARCHAR2) IS
  SELECT A.mr_header_id, A.mr_effectivity_id,
         A.pc_node_id,
         cii.instance_id subject_id,
         (SELECT to_date(ciea1.attribute_value, 'DD/MM/YYYY')  from csi_inst_extend_attrib_v ciea1
	  WHERE  cii.instance_id = ciea1.instance_id(+) AND ciea1.attribute_code(+)  = 'AHL_MFG_DATE'
	    AND ciea1.attribute_level(+) = 'GLOBAL') mfg_date,
	 cii.serial_number --,
	 --(SELECT 'Y' from ahl_mr_effectivity_dtls where mr_effectivity_id = a.mr_effectivity_id and ROWNUM < 2) eff_dtls_flag
    FROM csi_item_instances cii,ahl_mr_visit_types vis,
         ahl_mr_effectivities A
    WHERE A.mr_header_id = vis.mr_header_id
      AND vis.mr_visit_type_code = c_visit_type_code
      AND cii.instance_id = c_instance_id
      AND A.inventory_item_id = cii.inventory_item_id
      AND A.relationship_id is null
      AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                  WHERE MR.mr_header_id = A.mr_header_id
                    AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                    AND MR.version_number in (SELECT max(MRM.version_number)
                                              FROM ahl_mr_headers_app_v MRM
                                              WHERE mrm.title = mr.title
                                                AND SYSDATE between trunc(MRM.effective_from)
                                                AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                AND mr_status_code='COMPLETE'
                                             )
                 )
    --ORDER BY cii.instance_id;
    ORDER BY A.mr_effectivity_id,A.mr_header_id;

-- get valid mr effectivities based on path position ID.
CURSOR get_posn_vst_csr(c_visit_type_code VARCHAR2) IS
  SELECT A.mr_header_id, A.mr_effectivity_id,
         A.pc_node_id,
         cii.instance_id subject_id,
         (SELECT to_date(ciea1.attribute_value, 'DD/MM/YYYY')  from csi_inst_extend_attrib_v ciea1
	  WHERE  ciea1.instance_id = cii.instance_id AND ciea1.attribute_code  = 'AHL_MFG_DATE'
	    AND ciea1.attribute_level = 'GLOBAL') mfg_date,
	 cii.serial_number --,
	 --(SELECT 'Y' from ahl_mr_effectivity_dtls where mr_effectivity_id = a.mr_effectivity_id and ROWNUM < 2) eff_dtls_flag
    FROM ahl_applicable_instances aai,csi_item_instances cii,ahl_mr_visit_types vis,
         ahl_mr_effectivities A
    WHERE A.mr_header_id = vis.mr_header_id
      AND vis.mr_visit_type_code = c_visit_type_code
      AND A.relationship_id IS NOT NULL
      AND aai.position_id = A.relationship_id
      AND nvl(A.inventory_item_id, cii.inventory_item_id) = cii.inventory_item_id
      AND exists (SELECT 'x' from ahl_mr_headers_app_v MR
                  WHERE MR.mr_header_id = A.mr_header_id
                    AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                    AND MR.version_number in (SELECT max(MRM.version_number)
                                                FROM ahl_mr_headers_app_v MRM
                                               WHERE mrm.title = mr.title
                                                 AND SYSDATE between trunc(MRM.effective_from)
                                                 AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                 AND mr_status_code='COMPLETE'
                                             )
                 )
    --ORDER BY cii.instance_id;
    ORDER BY A.mr_effectivity_id, A.mr_header_id;


 -- check for path position based effectivities.
 CURSOR relationship_csr IS
   SELECT 'x' from dual
   WHERE exists (select 'x'
                 from ahl_mr_effectivities mre
                 where mre.relationship_id is not null
                   and exists (SELECT 'x' from ahl_mr_headers_app_v MR
                               WHERE MR.mr_header_id = mre.mr_header_id
                                 AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                                 AND MR.version_number in (SELECT max(MRM.version_number)
                                                             FROM ahl_mr_headers_app_v MRM
                                                            WHERE mrm.title = mr.title
                                                              AND SYSDATE between trunc(MRM.effective_from)
                                                              AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                              AND mr_status_code='COMPLETE'
                                                          )
                              )
                );


 -- check for path position based effectivities for visit type
 CURSOR relationship_vtype_csr(p_visit_type_code IN VARCHAR2) IS
   SELECT 'x' from dual
   WHERE exists (select 'x'
                 from ahl_mr_effectivities mre, ahl_mr_visit_types vis
                 where vis.mr_visit_type_code = p_visit_type_code
                   and mre.mr_header_id = vis.mr_header_id
                   and mre.relationship_id is not null
                   and exists (SELECT 'x' from ahl_mr_headers_app_v MR
                               WHERE MR.mr_header_id = vis.mr_header_id
                                 AND MR.program_type_code NOT IN ('MO_PROC') -- added in R12
                                 AND MR.version_number in (SELECT max(MRM.version_number)
                                                             FROM ahl_mr_headers_app_v MRM
                                                            WHERE mrm.title = mr.title
                                                              AND SYSDATE between trunc(MRM.effective_from)
                                                              AND trunc(nvl(MRM.effective_to,SYSDATE+1))
                                                              AND mr_status_code='COMPLETE'
                                                          )
                              )
                );

 -- check for path position based effectivities for MR
 CURSOR relationship_mr_csr(p_mr_header_id IN NUMBER) IS
   SELECT 'x' from dual
   WHERE exists (select 'x'
                 from ahl_mr_effectivities
                 where mr_header_id = p_mr_header_id
                   and relationship_id is not null);


/* Not used
amsriniv Bug 6971165 : To improve performance, instead of calling the cursor for every combination of
c_instance_id and c_position_id, we call the below cursor only when instance changes. Then, to validate
position_id, we iterate through the output of the cursor for the corresponding instance.

 -- validate patch position Id.
 CURSOR relationship_csr(c_instance_id IN NUMBER) IS
   select position_id
   from ahl_applicable_instances
   where csi_item_instance_id = c_instance_id;
*/

/*
amsriniv Bug 6971165 : To improve performance, replicating the logic of CHECK_EFFECTIVITY_DETAILS in this
procedure so that the below two cursors are invoked only when required. Previously, the function
CHECK_EFFECTIVITY_DETAILS was being called for every combination of mr_effectivity and instance_id. Now, the
get_inst_att cursor is called once for an instance and get_effect_details is called only if the MR validity still
holds.
*/
CURSOR get_effect_details(c_mr_effectivity_id NUMBER) IS
    SELECT exclude_flag, serial_number_from, serial_number_to, manufacturer_id,
           manufacture_date_from, manufacture_date_to, country_code
      FROM ahl_mr_effectivity_dtls
     WHERE mr_effectivity_id = c_mr_effectivity_id
     ORDER BY exclude_flag ASC;

/* not used
-- get instance details.
CURSOR get_inst_att(c_item_instance_id NUMBER) IS
	SELECT  csi.serial_number serial_number                               ,
		to_date(ciea1.attribute_value, 'DD/MM/YYYY') mfg_date         ,
		'm' manufacturer_id                                           ,
		'c' country_code
	FROM    csi_item_instances csi,
		csi_inst_extend_attrib_v ciea1
	WHERE   csi.instance_id          = ciea1.instance_id(+)
		AND ciea1.attribute_code(+)  = 'AHL_MFG_DATE'
		AND ciea1.attribute_level(+) = 'GLOBAL'
		AND csi.instance_id     = c_item_instance_id;
*/

/* not used
CURSOR is_position_check_req(c_mr_effectivity_id NUMBER) IS
    SELECT 'X'
      FROM ahl_mr_effectivities
     WHERE mr_effectivity_id = c_mr_effectivity_id
     AND inventory_item_id IS NOT NULL;
*/


-- to get configuration nodes.
CURSOR get_config_tree_csr ( p_csi_instance_id IN NUMBER) IS
    SELECT subject_id
    FROM csi_ii_relationships
    START WITH object_id = p_csi_instance_id
               AND relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
                     AND relationship_type_code = 'COMPONENT-OF'
                     AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                     AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    ORDER BY level;


 TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE vchar_tbl_type IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
 TYPE date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

 l_mr_header_id_tbl        nbr_tbl_type;
 l_mr_effectivity_id_tbl   nbr_tbl_type;
 l_mr_pc_node_id_tbl       nbr_tbl_type;
 l_instance_id_tbl         nbr_tbl_type;
 l_position_id_tbl         nbr_tbl_type;
 l_pc_node_id_tbl          nbr_tbl_type; --amsriniv

 l_mfg_date_tbl            date_tbl_type;
 l_serial_num_tbl          vchar_tbl_type;
 --l_eff_exists_tbl          vchar_tbl_type;
 l_subj_id_tbl             nbr_tbl_type;

 l_index                   number;
 --l_pc_node_inst_id         number; --amsriniv
 l_valid_mr_flag           varchar2(1);
 l_junk                    varchar2(1);
 l_rows_count              number  := 0; --amsriniv Bug 6971165

 l_buffer_limit            number := 1000;

 -- dummy values as manufacturer and country code are not supported by
 -- the application.
 l_inst_manufacturer_id    VARCHAR2(1) := 'm';
 l_inst_country_code       VARCHAR2(1) := 'c';

 l_path_posn_flag          BOOLEAN;

 l_process_loop            NUMBER := 0;
 -- l_process_loop indicates the processing stage
 -- = 1: processing effectivities based on inventory items for input instance
 -- = 2: processing effectivities based on inventory items for config components.
 -- = 3: processing effectivities based on MC positions for input instance and
 --      components. Note component level details are populated in temp table
 --      only if the p_components_flag = 'Y'

 l_prev_effectivity_id     NUMBER;
 l_prev_mr_header_id       NUMBER;


 --define record type to hold effectivity details.
 TYPE eff_dtl_rectype IS RECORD (
   eflag_tbl       vchar_tbl_type,
   srl_from_tbl    vchar_tbl_type,
   srl_to_tbl      vchar_tbl_type,
   mID_tbl         nbr_tbl_type,
   mdate_from_tbl  date_tbl_type,
   mdate_to_tbl    date_tbl_type,
   c_code_tbl      vchar_tbl_type
   );

 eff_dtl_rec       eff_dtl_rectype;

BEGIN
  SAVEPOINT GET_APPLICABLE_MRS_PVT;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_FMP_PVT.GET_APPLICABLE_MRS');
    AHL_DEBUG_PUB.debug('Input p_item_instance_id:' || p_item_instance_id);
    AHL_DEBUG_PUB.debug('Input p_mr_header_id:' || p_mr_header_id);
    AHL_DEBUG_PUB.debug('Input p_components_flag:' || p_components_flag);
    AHL_DEBUG_PUB.debug('Input p_include_doNotImplmt:' || p_include_doNotImplmt);
    AHL_DEBUG_PUB.debug('Input p_visit_type_code:' || p_visit_type_code);
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := 'S';

  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version,
                                     l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL)
  THEN
      -- validate input instance.
      OPEN check_instance_exists(p_item_instance_id);
      FETCH check_instance_exists INTO l_item_instance_id;
      IF check_instance_exists%NOTFOUND THEN
        CLOSE check_instance_exists;
        FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_ITEM_INSTANCE');
        FND_MESSAGE.SET_TOKEN('INSTANCE',p_item_instance_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE check_instance_exists;
  END IF;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('After instance validation:' || p_item_instance_id);
  END IF;

  /* -- commenting as this is not required.
  -- get root instance.
  OPEN csi_root_instance_csr(p_item_instance_id);
  FETCH csi_root_instance_csr INTO l_root_instance_id;
  IF (csi_root_instance_csr%NOTFOUND) THEN
     l_root_instance_id := p_item_instance_id;
  END IF;
  CLOSE csi_root_instance_csr;

  -- get uc header ID.
  OPEN uc_top_inst(l_root_instance_id);
  FETCH uc_top_inst INTO l_uc_header_id;
  CLOSE uc_top_inst;
  */


  -- start processing. First populate temp table ahl_applicable_instances by calling
  -- MC api to map instance (and components) to path positions.

  IF l_debug = 'Y' THEN
      AHL_DEBUG_PUB.debug('Start Processing..');
  END IF;

  l_path_posn_flag := FALSE;

  IF (p_visit_type_code IS NOT NULL) THEN
    -- check if effectivities exist with path positions for visit type.
    OPEN relationship_vtype_csr(p_visit_type_code);
    FETCH relationship_vtype_csr INTO l_junk;
    IF (relationship_vtype_csr%FOUND) THEN
      l_path_posn_flag := TRUE;
    END IF;
    CLOSE relationship_vtype_csr;

  ELSIF (p_mr_header_id IS NOT NULL) THEN
    -- check if effectivities exist with path positions for mr_header_id.
    OPEN relationship_mr_csr(p_mr_header_id);
    FETCH relationship_mr_csr INTO l_junk;
    IF (relationship_mr_csr%FOUND) THEN
      l_path_posn_flag := TRUE;
    END IF;
    CLOSE relationship_mr_csr;

  ELSE
    --  check if any effectivites exist with path positions.
    OPEN relationship_csr;
    FETCH relationship_csr INTO l_junk;
    IF (relationship_csr%FOUND) THEN
        l_path_posn_flag := TRUE;
    END IF;
    CLOSE relationship_csr;
  END IF;


  IF (l_path_posn_flag) THEN

       IF l_debug = 'Y' THEN
         AHL_DEBUG_PUB.debug('Processing MC Relationships..');
       END IF;

       DELETE FROM ahl_applicable_instances;
       -- for input instance.
       AHL_MC_PATH_POSITION_PVT.map_instance_to_positions
          (
            p_api_version            => 1.0,
            p_init_msg_list          => fnd_api.g_false,
            p_commit                 => fnd_api.g_false,
            p_validation_level       => p_validation_level,
            p_csi_item_instance_id   => p_item_instance_id,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => x_msg_data
          );

       -- Raise errors if exceptions occur
       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (p_components_flag = 'Y') THEN
          IF l_debug = 'Y' THEN
            AHL_DEBUG_PUB.debug('Processing Component MC Relationships..');
          END IF;

          OPEN get_config_tree_csr(p_item_instance_id);
          LOOP
            FETCH get_config_tree_csr BULK COLLECT INTO l_subj_id_tbl LIMIT l_buffer_limit;
            EXIT WHEN l_subj_id_tbl.COUNT = 0;

            FOR j IN l_subj_id_tbl.FIRST..l_subj_id_tbl.LAST LOOP
                AHL_MC_PATH_POSITION_PVT.map_instance_to_positions
                    (
                     p_api_version            => 1.0,
                     p_init_msg_list          => fnd_api.g_false,
                     p_commit                 => fnd_api.g_false,
                     p_validation_level       => p_validation_level,
                     p_csi_item_instance_id   => l_subj_id_tbl(j),
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => x_msg_data
                     );
                -- Raise errors if exceptions occur
                IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

            END LOOP;
            l_subj_id_tbl.DELETE;
          END LOOP;
          CLOSE get_config_tree_csr;

       END IF; -- p_components_flag

  END IF; -- l_path_posn_flag

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('Processing Inventory Items..');
  END IF;

  l_index := 1;

  -- initialize. Tracks if MC api to get path position details has been called or not.
  -- l_pc_node_inst_id := NULL; --amsriniv

  -- indicates processing stage.
  l_process_loop := 1;  -- process inv items for input instance.

  -- Loop based on processing stage
  LOOP
    -- Get effectivities for the mr and instance.
    IF (l_process_loop = 1) THEN
      -- get eff for top node
      IF (p_visit_type_code IS NULL) THEN
        OPEN get_inst_mr_inv_csr(p_item_instance_id,p_mr_header_id);
      ELSE
        OPEN get_inst_vst_inv_csr(p_item_instance_id, p_visit_type_code);
      END IF;
    ELSIF (l_process_loop = 2) THEN
      -- get eff for components.
      IF (p_visit_type_code IS NULL) THEN
        OPEN get_comp_mr_inv_csr(p_item_instance_id,p_mr_header_id);
      ELSE
        OPEN get_comp_vst_inv_csr(p_item_instance_id, p_visit_type_code);
      END IF;
      IF l_debug = 'Y' THEN
        AHL_DEBUG_PUB.debug('Processing Component Effectivities based on Inventory Items..');
      END IF;

    ELSIF (l_process_loop = 3) THEN
      -- get eff based on positions
      IF (p_visit_type_code IS NULL) THEN
        OPEN get_posn_mr_csr(p_mr_header_id);
      ELSE
        OPEN get_posn_vst_csr(p_visit_type_code);
      END IF;

      IF l_debug = 'Y' THEN
        AHL_DEBUG_PUB.debug('Processing Effectivities based on MC Positions..');
      END IF;
    END IF;

    LOOP
      -- fetch effectivity data and process.
      IF (l_process_loop = 1) THEN
        IF (p_visit_type_code IS NULL) THEN
           FETCH get_inst_mr_inv_csr BULK COLLECT INTO l_mr_header_id_tbl, l_mr_effectivity_id_tbl, l_mr_pc_node_id_tbl,
                                                       l_instance_id_tbl, l_mfg_date_tbl, l_serial_num_tbl --,l_eff_exists_tbl
                                                       LIMIT l_buffer_limit;

        ELSE

           FETCH get_inst_vst_inv_csr BULK COLLECT INTO l_mr_header_id_tbl, l_mr_effectivity_id_tbl, l_mr_pc_node_id_tbl,
                                                        l_instance_id_tbl, l_mfg_date_tbl, l_serial_num_tbl --,l_eff_exists_tbl
                                                        LIMIT l_buffer_limit;
        END IF;
      ELSIF (l_process_loop = 2) THEN
        IF (p_visit_type_code IS NULL) THEN
           FETCH get_comp_mr_inv_csr BULK COLLECT INTO l_mr_header_id_tbl, l_mr_effectivity_id_tbl, l_mr_pc_node_id_tbl,
                                                       l_instance_id_tbl, l_mfg_date_tbl, l_serial_num_tbl --, l_eff_exists_tbl
                                                       LIMIT l_buffer_limit;

        ELSE

           FETCH get_comp_vst_inv_csr BULK COLLECT INTO l_mr_header_id_tbl, l_mr_effectivity_id_tbl, l_mr_pc_node_id_tbl,
                                                        l_instance_id_tbl, l_mfg_date_tbl, l_serial_num_tbl --, l_eff_exists_tbl
                                                        LIMIT l_buffer_limit;
        END IF;
      ELSIF (l_process_loop = 3) THEN
        IF (p_visit_type_code IS NULL) THEN
           FETCH get_posn_mr_csr BULK COLLECT INTO l_mr_header_id_tbl, l_mr_effectivity_id_tbl, l_mr_pc_node_id_tbl,
                                                   l_instance_id_tbl, l_mfg_date_tbl, l_serial_num_tbl --, l_eff_exists_tbl
                                                   LIMIT l_buffer_limit;

        ELSE

           FETCH get_posn_vst_csr BULK COLLECT INTO l_mr_header_id_tbl, l_mr_effectivity_id_tbl, l_mr_pc_node_id_tbl,
                                                    l_instance_id_tbl, l_mfg_date_tbl, l_serial_num_tbl --, l_eff_exists_tbl
                                                    LIMIT l_buffer_limit;
        END IF;

      END IF; -- l_process_loop

      EXIT WHEN (l_mr_header_id_tbl.count = 0);

      IF l_debug = 'Y' THEN
        AHL_DEBUG_PUB.debug('Count of l_mr_header_id_tbl:' || l_mr_header_id_tbl.count);
      END IF;

      -- process retrieved effectivity IDs.
      FOR i IN l_mr_effectivity_id_tbl.FIRST..l_mr_effectivity_id_tbl.LAST LOOP

          /*
          IF l_debug = 'Y' THEN
             AHL_DEBUG_PUB.debug('Now processing MR ID:EFF ID:INST ID:' || l_mr_header_id_tbl(i) || ':' || l_mr_effectivity_id_tbl(i) || ':' || l_instance_id_tbl(i));
          END IF;
          */

          -- to begin with, set effectivity as valid.
          l_valid_mr_flag := 'Y';

          --DBMS_OUTPUT.PUT_LINE('API2: The number of MR before checking effectivity details is: '||l_appli_mr_tbl.COUNT||' After loop '||i);

          -- 24 Oct 08: performance changes to reduce executions on effect details query.
          --IF (l_eff_exists_tbl(i) = 'Y') THEN
            IF(l_prev_effectivity_id IS NULL OR l_prev_effectivity_id <> l_mr_effectivity_id_tbl(i)) THEN
              -- read effectivity details
              OPEN get_effect_details(l_mr_effectivity_id_tbl(i));
              FETCH get_effect_details BULK COLLECT INTO eff_dtl_rec.eflag_tbl, eff_dtl_rec.srl_from_tbl, eff_dtl_rec.srl_to_tbl,
                                                         eff_dtl_rec.mID_tbl, eff_dtl_rec.mdate_from_tbl, eff_dtl_rec.mdate_to_tbl, eff_dtl_rec.c_code_tbl;
              CLOSE get_effect_details;
              l_prev_effectivity_id := l_mr_effectivity_id_tbl(i);
            END IF;
            IF (eff_dtl_rec.eflag_tbl.count > 0) THEN

		--FOR l_effect_dtl IN get_effect_details(l_mr_effectivity_id_tbl(i)) LOOP
		FOR j IN eff_dtl_rec.eflag_tbl.FIRST..eff_dtl_rec.eflag_tbl.LAST LOOP
  		        --l_rows_count := get_effect_details%ROWCOUNT;
			IF eff_dtl_rec.eflag_tbl(j) = 'N' THEN
				IF (check_sn_inside(l_serial_num_tbl(i), eff_dtl_rec.srl_from_tbl(j), eff_dtl_rec.srl_to_tbl(j)) AND
				  (eff_dtl_rec.mID_tbl(j) IS NULL OR eff_dtl_rec.mID_tbl(j) = l_inst_manufacturer_id) AND
				  (eff_dtl_rec.mdate_from_tbl(j) IS NULL OR eff_dtl_rec.mdate_from_tbl(j) <= l_mfg_date_tbl(i)) AND
				  (eff_dtl_rec.mdate_to_tbl(j) IS NULL OR eff_dtl_rec.mdate_to_tbl(j) >= l_mfg_date_tbl(i)) AND
				  (eff_dtl_rec.c_code_tbl(j) IS NULL OR eff_dtl_rec.c_code_tbl(j) = l_inst_country_code)) THEN
  				     l_valid_mr_flag := 'Y';
				     EXIT;
			        ELSE
			     	     l_valid_mr_flag := 'N';
				END IF;
			ELSE
				IF (check_sn_outside(l_serial_num_tbl(i), eff_dtl_rec.srl_from_tbl(j), eff_dtl_rec.srl_to_tbl(j)) AND
				  (eff_dtl_rec.mID_tbl(j) IS NULL OR eff_dtl_rec.mID_tbl(j) = l_inst_manufacturer_id) AND
				  (eff_dtl_rec.mdate_from_tbl(j) IS NULL OR eff_dtl_rec.mdate_from_tbl(j) <= l_mfg_date_tbl(i)) AND
				  (eff_dtl_rec.mdate_to_tbl(j) IS NULL OR eff_dtl_rec.mdate_to_tbl(j) >= l_mfg_date_tbl(i)) AND
				  (eff_dtl_rec.c_code_tbl(j) IS NULL OR eff_dtl_rec.c_code_tbl(j) = l_inst_country_code)) THEN
		    		     l_valid_mr_flag := 'Y';
				ELSE
				     l_valid_mr_flag := 'N';
				     EXIT;
				END IF;
			END IF;
		END LOOP;

	    END IF; -- eff_dtl_rec.eflag_tbl.count > 0
	  --END IF; -- l_eff_exists_tbl(i)

    IF(NOT CHECK_EFFECTIVITY_EXT_DETAILS(l_instance_id_tbl(i),l_mr_effectivity_id_tbl(i)))THEN
      l_valid_mr_flag := 'N';
    END IF;

          -- 24 Oct 08: reverted code changes to chk for all pairs of c_instance_id and c_pc_node_id due to sorting change.
          -- Eff rows are now processed by effectivity ID and mr header ID.
          /*amsriniv. Bug 6767803. Rather than executing the below query for all pairs of c_instance_id and c_pc_node_id, to
            save on performance, we execute validate_pc_node_csr only when instance changes. We BULK COLLECT the PC_NODE_IDs
            into a table and iterate throught it whehn instance is unchanged.
          */
          --amsriniv. Begin
          IF (l_valid_mr_flag = 'Y' AND l_mr_pc_node_id_tbl(i) IS NOT NULL) THEN
		--l_valid_mr_flag := 'N';
		/*
		IF (l_pc_node_inst_id IS NULL OR (l_pc_node_inst_id IS NOT NULL AND l_pc_node_inst_id <> l_instance_id_tbl(i))) THEN
			l_pc_node_id_tbl.delete;
		*/
		        OPEN validate_pc_node_csr(l_instance_id_tbl(i), l_mr_pc_node_id_tbl(i));
			FETCH validate_pc_node_csr INTO l_junk;
			IF (validate_pc_node_csr%NOTFOUND) THEN
			  l_valid_mr_flag := 'N';
			END IF;
			CLOSE validate_pc_node_csr;
			--l_pc_node_inst_id := l_instance_id_tbl(i);
		/*
		END IF;
		IF (l_pc_node_id_tbl.COUNT > 0) THEN
			FOR j IN l_pc_node_id_tbl.FIRST..l_pc_node_id_tbl.LAST LOOP
				IF (l_pc_node_id_tbl(j) = l_mr_pc_node_id_tbl(i)) THEN
					l_valid_mr_flag := 'Y';
					EXIT;
				END IF;
			END LOOP;
		END IF;
		*/
          END IF;
          --amsriniv End

          IF l_debug = 'Y' THEN
             AHL_DEBUG_PUB.debug('MR ID:EFF ID:INST ID:Valid Flag:' || l_mr_header_id_tbl(i) || ':' || l_mr_effectivity_id_tbl(i) || ':' || l_instance_id_tbl(i) || ':' || l_valid_mr_flag);
          END IF;

          -- add row to x_applicable_mr_tbl
          IF (l_valid_mr_flag = 'Y') THEN
              --DBMS_OUTPUT.put_line('API2: The number of MR in for loop and before openning cursor is: '||l_appli_mr_tbl.COUNT||' and mr_header_id= '||l_appli_mr_tbl(j).mr_header_id||';');
            -- read MR details only once.
            IF (l_prev_mr_header_id IS NULL OR l_prev_mr_header_id <> l_mr_header_id_tbl(i)) THEN
              OPEN get_mr_attri(l_mr_header_id_tbl(i));
              FETCH get_mr_attri INTO l_get_mr_attri;
              IF get_mr_attri%NOTFOUND THEN
	         CLOSE get_mr_attri;
	         FND_MESSAGE.set_name('AHL','AHL_FMP_INVALID_MR');
	         FND_MSG_PUB.add;
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      ELSE
                  l_prev_mr_header_id := l_mr_header_id_tbl(i);
     	          CLOSE get_mr_attri;
	      END IF; -- get_mr_attri%NOTFOUND
	    END IF; --  l_prev_mr_header_id

	    IF ((p_include_doNotImplmt <> 'N') OR
	        (l_get_mr_attri.implement_status_code <> 'OPTIONAL_DO_NOT_IMPLEMENT')) THEN
	               x_applicable_mr_tbl(l_index).mr_header_id := l_mr_header_id_tbl(i);
	               x_applicable_mr_tbl(l_index).mr_effectivity_id := l_mr_effectivity_id_tbl(i);
	               x_applicable_mr_tbl(l_index).item_instance_id := l_instance_id_tbl(i);
	               x_applicable_mr_tbl(l_index).repetitive_flag          := l_get_mr_attri.repetitive_flag;
	               x_applicable_mr_tbl(l_index).show_repetitive_code     := l_get_mr_attri.show_repetitive_code;
	               x_applicable_mr_tbl(l_index).preceding_mr_header_id   := l_get_mr_attri.preceding_mr_header_id;
	               x_applicable_mr_tbl(l_index).copy_accomplishment_flag := l_get_mr_attri.copy_accomplishment_flag;
	               x_applicable_mr_tbl(l_index).implement_status_code    := l_get_mr_attri.implement_status_code;
	               x_applicable_mr_tbl(l_index).descendent_count         := l_get_mr_attri.descendent_count;
		       IF l_debug = 'Y' THEN
			   AHL_DEBUG_PUB.debug('AHL_APPLICABLE_MRS Attributes : mr_header_id ' ||
			   x_applicable_mr_tbl(l_index).mr_header_id || ' mr_effectivity_id ' ||
			   x_applicable_mr_tbl(l_index).mr_effectivity_id || ' item_instance_id ' ||
			   x_applicable_mr_tbl(l_index).item_instance_id || ' repetitive_flag ' ||
			   x_applicable_mr_tbl(l_index).repetitive_flag || ' show_repetitive_code ' ||
			   x_applicable_mr_tbl(l_index).show_repetitive_code || ' preceding_mr_header_id ' ||
			   x_applicable_mr_tbl(l_index).preceding_mr_header_id || ' copy_accomplishment_flag ' ||
			   x_applicable_mr_tbl(l_index).copy_accomplishment_flag || ' implement_status_code ' ||
			   x_applicable_mr_tbl(l_index).implement_status_code || ' descendent_count ' ||
			   x_applicable_mr_tbl(l_index).descendent_count);
		       END IF;
	               l_index := l_index+1;
	    END IF;

          END IF;  -- l_valid_mr_flag

     END LOOP; -- l_mr_effectivity_id_tbl

      -- reset tables and get the next batch of mr effectivities.
      l_mr_header_id_tbl.delete;
      l_mr_effectivity_id_tbl.delete;
      l_mr_pc_node_id_tbl.delete;
      l_instance_id_tbl.delete;
      l_mfg_date_tbl.delete;
      l_serial_num_tbl.delete;
      --l_eff_exists_tbl.delete;

    END LOOP;
    -- set l_process_loop value to process next set of rows.
    IF (l_process_loop = 1) THEN
       IF (get_inst_mr_inv_csr%ISOPEN) THEN
          CLOSE get_inst_mr_inv_csr;
       ELSIF (get_inst_vst_inv_csr%ISOPEN) THEN
          CLOSE get_inst_vst_inv_csr;
       END IF;

       IF (p_components_flag = 'Y') THEN
             l_process_loop := 2;
       ELSE
             l_process_loop := 3;
       END IF;

    ELSIF (l_process_loop = 2) THEN
       IF (get_comp_mr_inv_csr%ISOPEN) THEN
         CLOSE get_comp_mr_inv_csr;
       ELSIF (get_comp_vst_inv_csr%ISOPEN) THEN
         CLOSE get_comp_vst_inv_csr;
       END IF;

       l_process_loop := 3;
    ELSIF (l_process_loop = 3) THEN
       IF (get_posn_mr_csr%ISOPEN) THEN
          CLOSE get_posn_mr_csr;
       ELSIF (get_posn_mr_csr%ISOPEN) THEN
          CLOSE get_posn_vst_csr;
       END IF;

       EXIT;

    END IF;

  END LOOP;

  DELETE FROM ahl_applicable_instances;

  --DBMS_OUTPUT.PUT_LINE('API2: Successfully executed API2!');
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('End private API: AHL_FMP_PVT.GET_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;


EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
  ROLLBACK TO GET_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                    'UNEXPECTED ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO GET_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                   'ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN OTHERS THEN
  ROLLBACK TO GET_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_FMP_PVT',
                            p_procedure_name => 'GET_APPLICABLE_MRS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  END IF;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data,
                                    'OTHER ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
END GET_APPLICABLE_MRS;

-- Define procedure get_ucHeader, get the unit_config_header_id and unit name for
-- a given item_instance_id
PROCEDURE get_ucHeader (p_item_instance_id  IN  NUMBER,
                        x_ucHeaderID        OUT NOCOPY NUMBER,
                        x_unitName          OUT NOCOPY VARCHAR2)
IS
  -- Get ucHeader for component
  CURSOR get_unit_name_com (p_item_instance_id IN NUMBER) IS
    SELECT unit_config_header_id, name
    FROM ahl_unit_config_headers
    WHERE csi_item_instance_id IN ( SELECT object_id
                                    FROM csi_ii_relationships
                                    START WITH subject_id = p_item_instance_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND sysdate between trunc(nvl(active_start_date,sysdate))
                                      AND trunc(nvl(active_end_date, SYSDATE+1))
                                    CONNECT BY subject_id = PRIOR object_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND sysdate between trunc(nvl(active_start_date,sysdate))
                                      AND trunc(nvl(active_end_date, SYSDATE+1))
                                  )
   AND sysdate between trunc(nvl(active_start_date,sysdate))
   AND trunc(nvl(active_end_date, SYSDATE+1));

  -- Get ucHeader for top node
  CURSOR get_unit_name_top (p_item_instance_id IN NUMBER) IS
    SELECT unit_config_header_id, name
    FROM ahl_unit_config_headers
    WHERE csi_item_instance_id = p_item_instance_id
    AND sysdate between trunc(nvl(active_start_date,sysdate))
    AND trunc(nvl(active_end_date, SYSDATE+1));

  l_get_unit_name_com   get_unit_name_com%ROWTYPE;
  l_get_unit_name_top   get_unit_name_top%ROWTYPE;
  l_debug                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
BEGIN
  --Check for top node.
  OPEN get_unit_name_top(p_item_instance_id);
  FETCH get_unit_name_top INTO l_get_unit_name_top;
  IF (get_unit_name_top%NOTFOUND) THEN
     -- Check for component.
     OPEN get_unit_name_com(p_item_instance_id);
     FETCH get_unit_name_com INTO l_get_unit_name_com;
     IF (get_unit_name_com%NOTFOUND) THEN
        x_ucHeaderID := NULL;
        x_unitName := NULL;
     ELSE
        x_ucHeaderID := l_get_unit_name_com.unit_config_header_id;
        x_unitName := l_get_unit_name_com.name;
     END IF;
     CLOSE get_unit_name_com;
  ELSE
    x_ucHeaderID := l_get_unit_name_top.unit_config_header_id;
    x_unitName := l_get_unit_name_top.name;
  END IF;
  CLOSE get_unit_name_top;

END get_ucHeader;

-- to get the top instance for a given item_instance_id
FUNCTION get_topInstanceID(p_item_instance_id  IN  NUMBER) RETURN NUMBER
IS
  -- Get top instance for top component
  CURSOR get_instance_top (p_item_instance_id IN NUMBER) IS
  SELECT A.instance_id
  FROM csi_item_instances A
    WHERE A.instance_id IN ( SELECT object_id
                                    FROM csi_ii_relationships
                                    START WITH subject_id = p_item_instance_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND sysdate between trunc(nvl(active_start_date,sysdate))
                                      AND trunc(nvl(active_end_date, SYSDATE+1))
                                    CONNECT BY subject_id = PRIOR object_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND sysdate between trunc(nvl(active_start_date,sysdate))
                                      AND trunc(nvl(active_end_date, SYSDATE+1))
                                  )
   AND sysdate between trunc(nvl(active_start_date,sysdate))
   AND trunc(nvl(active_end_date, SYSDATE+1))
   AND NOT EXISTS (SELECT 'X'
                  FROM csi_ii_relationships B
                  WHERE B.subject_id = A.instance_id
                  AND relationship_type_code = 'COMPONENT-OF'
                  AND SYSDATE between trunc(nvl(B.active_start_date,sysdate)) and trunc(NVL(b.active_end_date,sysdate+1))
                  );

  -- Get instance if it is a top component
  CURSOR get_instance_com (p_item_instance_id IN NUMBER) IS
    SELECT instance_id
    FROM csi_item_instances
    WHERE instance_id = p_item_instance_id
    AND sysdate between trunc(nvl(active_start_date,sysdate))
    AND trunc(nvl(active_end_date, SYSDATE+1));

  l_debug                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
  l_top_instance_id NUMBER;
BEGIN
  --Check for top node.
  OPEN get_instance_top(p_item_instance_id);
  FETCH get_instance_top INTO l_top_instance_id;
  IF (get_instance_top%NOTFOUND) THEN
     -- Check for component.
     OPEN get_instance_com(p_item_instance_id);
     FETCH get_instance_com INTO l_top_instance_id;
     IF (get_instance_com%NOTFOUND) THEN
        l_top_instance_id := NULL;
     END IF;
     CLOSE get_instance_com;
  END IF;
  CLOSE get_instance_top;

  RETURN l_top_instance_id;

END get_topInstanceID;

-- Define function COUNT_MR_DESCENDENTS --
FUNCTION COUNT_MR_DESCENDENTS(p_mr_header_id  IN  NUMBER)
RETURN NUMBER IS
  CURSOR get_mr_descendents(c_mr_header_id NUMBER) IS
    -- when two group MRs having common MRs are added into another group,
    -- common MRs are counted only once. This may cause the larger group
    -- MR to be processed later
    /*
    SELECT --count(distinct related_mr_header_id)
           count(related_mr_header_id)
      FROM ahl_mr_relationships
       WHERE EXISTS (SELECT mr_header_id
                     FROM ahl_mr_headers_b M -- perf bug 6266738
                    WHERE mr_header_id = related_mr_header_id
                      AND mr_status_code = 'COMPLETE'
                      AND SYSDATE between trunc(effective_from) and trunc(nvl(effective_to,SYSDATE+1))
                      AND (version_number) in (SELECT max(M1.version_number)
                                               from ahl_mr_headers_b M1
                                               where M1.title = m.title -- perf bug 6266738
                                                AND mr_status_code = 'COMPLETE'
                                                AND SYSDATE between trunc(effective_from) and trunc(nvl(effective_to,SYSDATE+1))
                                              )
                  )
      START WITH mr_header_id = c_mr_header_id
       AND relationship_code = 'PARENT'
      CONNECT BY mr_header_id = PRIOR related_mr_header_id
       AND relationship_code = 'PARENT';
    */

    SELECT count(amr.related_mr_header_id)
    FROM ahl_mr_relationships amr
    START WITH amr.mr_header_id = c_mr_header_id
       AND amr.relationship_code = 'PARENT'
       AND exists (select 'x' from ahl_mr_headers_b mr1
                   where mr1.mr_header_id = amr.related_mr_header_id
                   and mr1.version_number = (select max(mr2.version_number)
                                             from ahl_mr_headers_b mr2
                                             where mr2.title = mr1.title
                                               and mr2.mr_status_code = 'COMPLETE'
                                               and SYSDATE between trunc(mr2.effective_from)
                                               and trunc(nvl(mr2.effective_to,SYSDATE+1))
                                            )
                  )
    CONNECT BY amr.mr_header_id = PRIOR amr.related_mr_header_id
       AND amr.relationship_code = 'PARENT'
       AND exists (select 'x' from ahl_mr_headers_b mr1
                    where mr1.mr_header_id = amr.related_mr_header_id
                   and mr1.version_number = (select max(mr2.version_number)
                                             from ahl_mr_headers_b mr2
                                             where mr2.title = mr1.title
                                               and mr2.mr_status_code = 'COMPLETE'
                                               and SYSDATE between trunc(mr2.effective_from)
                                               and trunc(nvl(mr2.effective_to,SYSDATE+1))
                                            )
                  );

  l_count             NUMBER;
BEGIN
  OPEN get_mr_descendents(p_mr_header_id);
  FETCH get_mr_descendents INTO l_count;
  CLOSE get_mr_descendents;
  RETURN l_count;
END COUNT_MR_DESCENDENTS;

-- 10/27/08: This function is no longer used.
-- This function accepts an instance id and a path position id
-- and checks if the instance matches the path position.
-- The path position id may correspond to a version specific path or
-- a version neutral (various degrees) path. It may represent the entire
-- path or only some of the lower most levels of the path.
-- This returns 'T' if the instance matches the path position and 'F' if it does not.
FUNCTION Instance_Matches_Path_Pos(p_instance_id      IN NUMBER,
                                   p_path_position_id IN NUMBER) RETURN VARCHAR2 IS

  l_api_name   CONSTANT VARCHAR2(30) := 'Instance_Matches_Path_Pos';
  l_full_name  CONSTANT VARCHAR2(80) := 'ahl.plsql.' || g_pkg_name || '.' || l_api_name;
  l_return_value        VARCHAR2(1) := 'F';
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_inst_path_pos_id    NUMBER;
  l_inst_encoded_path   AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
  l_input_encoded_path  AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
  l_path_tbl            AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
  l_path_rec            AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
  l_unit_csi_id         NUMBER;
  l_index               NUMBER;

  --Fetches lowest level info
  CURSOR get_last_uc_rec_csr(c_csi_instance_id IN NUMBER) IS
    SELECT hdr.mc_id, hdr.version_number, rel.position_key
      FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel, csi_ii_relationships csi_ii
     WHERE csi_ii.subject_id = c_csi_instance_id
       AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
       AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
       AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
       AND TO_NUMBER(CSI_II.POSITION_REFERENCE) = REL.RELATIONSHIP_ID
       AND REL.mc_header_id = HDR.mc_header_id;

  --Traverse up and fetch all unit instance ids
  CURSOR get_unit_instance_csr(c_csi_instance_id IN NUMBER) IS
    SELECT csi.object_id
      FROM csi_ii_relationships csi
     WHERE csi.object_id IN
      (SELECT csi_item_instance_id
          FROM ahl_unit_config_headers
         WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
           AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
      )
    START WITH csi.subject_id = c_csi_instance_id
           AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
           AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
           AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    CONNECT BY csi.subject_id = PRIOR csi.object_id
           AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
           AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
           AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
           AND CSI.POSITION_REFERENCE IS NOT NULL;

  --Fetch the unit and unit header info for each instance
  CURSOR get_uc_headers_csr(c_csi_instance_id IN NUMBER) IS
    SELECT up.parent_mc_id, up.parent_version_number, up.parent_position_key
      FROM ahl_uc_header_paths_v up
     WHERE up.csi_instance_id = c_csi_instance_id;

  CURSOR get_top_unit_inst_csr (c_csi_instance_id IN NUMBER) IS
    SELECT hdr.mc_id, hdr.version_number, rel.position_key
      FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel, ahl_unit_config_headers uch
     WHERE uch.csi_item_instance_id = c_csi_instance_id
       AND TRUNC(nvl(uch.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
       AND TRUNC(nvl(uch.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
       AND hdr.mc_header_id = uch.master_config_id
       AND rel.mc_header_id = hdr.mc_header_id
       AND rel.parent_relationship_id IS NULL
       AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
                        WHERE CIR.SUBJECT_ID = uch.csi_item_instance_id
                          AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                          AND TRUNC(nvl(CIR.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
                          AND TRUNC(nvl(CIR.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate));

  CURSOR get_encoded_path_csr(c_path_position_id IN NUMBER) IS
    SELECT ENCODED_PATH_POSITION
      FROM AHL_MC_PATH_POSITIONS
     WHERE PATH_POSITION_ID = c_path_position_id;

BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name||'.begin',
                     'At the start of PLSQL function. p_instance_id = ' || p_instance_id ||
                     ', p_path_position_id = ' || p_path_position_id);
  END IF;

  IF (p_path_position_id IS NULL) THEN
    l_return_value := 'T';
    RETURN l_return_value;
  END IF;

  -- Get the version specific encoded path position for the instance
  -- NOTE: The following lines of code are reproduced from AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID
  -- However AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID itself cannot be used directly
  -- since it also updates the db by creating a path position if it does not exist and this is not
  -- acceptable if this function is to be called from a Select statement.
  --Fetch the position informations for the instance
  OPEN get_last_uc_rec_csr(p_instance_id);
  FETCH get_last_uc_rec_csr INTO l_path_rec.mc_id, l_path_rec.version_number, l_path_rec.position_key;
  IF (get_last_uc_rec_csr%FOUND) THEN
    l_path_tbl(1) := l_path_rec;
    --Now fetch the position paths which match at higher levels.
    l_index := 0;
    --Fetch the header rec info for the instance
    OPEN get_unit_instance_csr(p_instance_id);
    LOOP
      FETCH get_unit_instance_csr INTO l_unit_csi_id;
      EXIT WHEN get_unit_instance_csr%NOTFOUND;

      OPEN get_uc_headers_csr(l_unit_csi_id);
      FETCH get_uc_headers_csr INTO l_path_rec.mc_id, l_path_rec.version_number, l_path_rec.position_key;
      CLOSE get_uc_headers_csr;

      --Add the path up the tree, decrementing index for each node.
      IF (l_path_rec.mc_id is not null AND l_path_rec.position_key is not null) THEN
         l_path_tbl(l_index) := l_path_rec;
         l_index := l_index - 1;
      END IF;
   END LOOP;
   CLOSE get_unit_instance_csr;
  ELSE  --if not position node then check if instance is the top unit node
    --Fetch the position informations for the unit instance
    OPEN get_top_unit_inst_csr(p_instance_id);
    FETCH get_top_unit_inst_csr INTO l_path_rec.mc_id, l_path_rec.version_number, l_path_rec.position_key;
    IF (get_top_unit_inst_csr%FOUND) THEN
      l_path_tbl(1) := l_path_rec;
    END IF;
    CLOSE get_top_unit_inst_csr;
  END IF;
  CLOSE get_last_uc_rec_csr;

  -- End reproduction from AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement, l_full_name,
                   'l_path_tbl.COUNT = ' || l_path_tbl.COUNT);
  END IF;
  -- Now use the contents of l_path_tbl to create the encoded path
  IF (l_path_tbl.COUNT > 0) THEN
    l_inst_encoded_path := '';
    FOR i IN l_path_tbl.FIRST..l_path_tbl.LAST LOOP
      l_inst_encoded_path := l_inst_encoded_path || l_path_tbl(i).mc_id || ':' || l_path_tbl(i).version_number || ':' || l_path_tbl(i).position_key;
      IF (i < l_path_tbl.LAST) THEN
        l_inst_encoded_path := l_inst_encoded_path || '/';
      END IF;
    END LOOP;
  END IF;

  -- Get the encoded path for the input path position
  OPEN get_encoded_path_csr(c_path_position_id => p_path_position_id);
  FETCH get_encoded_path_csr INTO l_input_encoded_path;
  CLOSE get_encoded_path_csr;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, l_full_name,
                   'l_inst_encoded_path = ' || l_inst_encoded_path ||
                   ', l_input_encoded_path = ' || l_input_encoded_path);
  END IF;

  -- See if the path positions match
  IF (l_inst_encoded_path LIKE '%' || l_input_encoded_path) THEN
    l_return_value := 'T';
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name||'.end',
                     'At the end of PLSQL function. About to return ' || l_return_value);
  END IF;
  RETURN l_return_value;
END;


-- Define Local Function CHECK_EFFECTIVITY_DETAILS --
FUNCTION CHECK_EFFECTIVITY_DETAILS(
  p_item_instance_id      IN  NUMBER,
  p_mr_effectivity_id     IN  NUMBER
) RETURN BOOLEAN IS
  CURSOR get_effect_detail(c_mr_effectivity_id NUMBER) IS
    SELECT exclude_flag, serial_number_from, serial_number_to, manufacturer_id,
           manufacture_date_from, manufacture_date_to, country_code
      FROM ahl_mr_effectivity_dtls -- perf bug 6266738
     WHERE mr_effectivity_id = c_mr_effectivity_id
     ORDER BY exclude_flag ASC;

--amsriniv
  CURSOR get_inst_attributes(c_item_instance_id NUMBER) IS
        SELECT  csi.serial_number serial_number                               ,
                to_date(ciea1.attribute_value, 'DD/MM/YYYY') mfg_date         ,
                'm' manufacturer_id                                           ,
                'c' country_code
        FROM    csi_item_instances csi,
                csi_inst_extend_attrib_v ciea1
        WHERE   csi.instance_id          = ciea1.instance_id(+)
            AND ciea1.attribute_code(+)  = 'AHL_MFG_DATE'
            AND ciea1.attribute_level(+) = 'GLOBAL'
            AND csi.instance_id     = c_item_instance_id;

  l_inst_dtl            get_inst_attributes%ROWTYPE;
  match_dtl             BOOLEAN := FALSE;
  l_rows_count          NUMBER  := 0;
BEGIN
  OPEN get_inst_attributes(p_item_instance_id);
  FETCH get_inst_attributes INTO l_inst_dtl;
  IF get_inst_attributes%NOTFOUND THEN
    CLOSE get_inst_attributes;
    FND_MESSAGE.set_name('AHL','AHL_FMP_INVALID_ITEM_INSTANCE');
    FND_MESSAGE.set_token('INSTANCE',p_item_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    RETURN match_dtl;
  END IF;
  CLOSE get_inst_attributes;
--DBMS_OUTPUT.PUT_LINE('In check effectivity detail function and before the loop');
  FOR l_effect_dtl IN get_effect_detail(p_mr_effectivity_id) LOOP
      l_rows_count := get_effect_detail%ROWCOUNT;
    IF l_effect_dtl.exclude_flag = 'N' THEN
    --DBMS_OUTPUT.PUT_LINE('In check effectivity detail function, serial numbers are sn: '||l_inst_dtl.serial_number||' sn1: '||l_effect_dtl.serial_number_from||' sn2: '||
    --l_effect_dtl.serial_number_to);
      IF (check_sn_inside(l_inst_dtl.serial_number, l_effect_dtl.serial_number_from, l_effect_dtl.serial_number_to) AND
--        l_inst_dtl.serial_number >= NVL(l_effect_dtl.serial_number_from, l_inst_dtl.serial_number) AND
--          l_inst_dtl.serial_number <= NVL(l_effect_dtl.serial_number_to, l_inst_dtl.serial_number) AND
          (l_effect_dtl.manufacturer_id IS NULL OR l_effect_dtl.manufacturer_id = l_inst_dtl.manufacturer_id) AND
          (l_effect_dtl.manufacture_date_from IS NULL OR l_effect_dtl.manufacture_date_from <= l_inst_dtl.mfg_date) AND
          (l_effect_dtl.manufacture_date_to IS NULL OR l_effect_dtl.manufacture_date_to >= l_inst_dtl.mfg_date) AND
          (l_effect_dtl.country_code IS NULL OR l_effect_dtl.country_code = l_inst_dtl.country_code)) THEN
        match_dtl := TRUE;
        EXIT;
      END IF;
    ELSE
    --DBMS_OUTPUT.PUT_LINE('In check effectivity detail function, serial numbers are sn: '||l_inst_dtl.serial_number||' sn1: '||l_effect_dtl.serial_number_from||' sn2: '||
    --l_effect_dtl.serial_number_to);
      IF (check_sn_outside(l_inst_dtl.serial_number, l_effect_dtl.serial_number_from, l_effect_dtl.serial_number_to) AND
--        l_inst_dtl.serial_number < NVL(l_effect_dtl.serial_number_from, l_inst_dtl.serial_number||'A') AND
--          l_inst_dtl.serial_number > NVL(l_effect_dtl.serial_number_to,  SUBSTR(l_inst_dtl.serial_number,1,LENGTH(l_inst_dtl.serial_number)-1)) AND
          (l_effect_dtl.manufacturer_id IS NULL OR l_effect_dtl.manufacturer_id <> l_inst_dtl.manufacturer_id) AND
          (l_effect_dtl.manufacture_date_from IS NULL OR l_effect_dtl.manufacture_date_from > l_inst_dtl.mfg_date) AND
          (l_effect_dtl.manufacture_date_to IS NULL OR l_effect_dtl.manufacture_date_to < l_inst_dtl.mfg_date) AND
          (l_effect_dtl.country_code IS NULL OR l_effect_dtl.country_code <> l_inst_dtl.country_code)) THEN
        match_dtl := TRUE;
      ELSE
        match_dtl := FALSE;
        EXIT;
      END IF;
    END IF;

  END LOOP;
  IF l_rows_count = 0 THEN
    match_dtl := TRUE;
  END IF;
  RETURN match_dtl;
END CHECK_EFFECTIVITY_DETAILS;

-- Define Local Function CHECK_EFFECTIVITY_EXT_DETAILS --
FUNCTION CHECK_EFFECTIVITY_EXT_DETAILS(
  p_item_instance_id      IN  NUMBER,
  p_mr_effectivity_id     IN  NUMBER
) RETURN BOOLEAN IS

 TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE vchar_tbl_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
 --define record type to hold extended effectivity details.
 TYPE eff_ext_dtl_rectype IS RECORD (
   eflag_tbl       vchar_tbl_type,
   rectype_tbl     vchar_tbl_type,
   owner_id_tbl    nbr_tbl_type,
   loc_tbl       vchar_tbl_type,
   a_Code_tbl       vchar_tbl_type,
   a_Val_tbl       vchar_tbl_type
   );

 eff_ext_dtl_rec       eff_ext_dtl_rectype;

  CURSOR get_effect_ext_detail(c_mr_effectivity_id NUMBER) IS
    SELECT exclude_flag, EFFECT_EXT_DTL_REC_TYPE, OWNER_ID, LOCATION_TYPE_CODE,
           CSI_EXT_ATTRIBUTE_CODE, CSI_EXT_ATTRIBUTE_VALUE
      FROM AHL_MR_EFFECTIVITY_EXT_DTLS
     WHERE mr_effectivity_id = c_mr_effectivity_id
     AND EFFECT_EXT_DTL_REC_TYPE IN ('OWNER','LOCATION','CSIEXTATTR')
     ORDER BY EFFECT_EXT_DTL_REC_TYPE DESC,exclude_flag ASC; --exteremely improtant this --will break if changed

  match_dtl   BOOLEAN;
  fetch_inst_attr BOOLEAN;
  fetch_inst_ext_attr BOOLEAN;


  CURSOR get_inst_attributes(c_item_instance_id NUMBER) IS
        select CSI.OWNER_PARTY_ID,location_type_code from csi_item_instances CSI
        where CSI.instance_id = c_item_instance_id;
  l_inst_attr_rec get_inst_attributes%ROWTYPE;

  CURSOR get_inst_ext_attributes(c_item_instance_id NUMBER) IS
        SELECT  ciea1.attribute_code,ciea1.attribute_value
        FROM    csi_item_instances csi,
                csi_inst_extend_attrib_v ciea1
        WHERE   csi.instance_id          = ciea1.instance_id(+)
        AND csi.instance_id     = c_item_instance_id;

   --define record type to hold extended effectivity details.
 TYPE inst_ext_dtl_rectype IS RECORD (
   a_Code_tbl       vchar_tbl_type,
   a_Val_tbl       vchar_tbl_type
   );

 inst_ext_dtl_rec       eff_ext_dtl_rectype;

BEGIN

   match_dtl := TRUE;

   fetch_inst_attr := FALSE;
   fetch_inst_ext_attr := FALSE;
   -- read effectivity details
   OPEN get_effect_ext_detail(p_mr_effectivity_id);
   FETCH get_effect_ext_detail BULK COLLECT INTO eff_ext_dtl_rec.eflag_tbl,
                                              eff_ext_dtl_rec.rectype_tbl,
                                              eff_ext_dtl_rec.owner_id_tbl,
                                              eff_ext_dtl_rec.loc_tbl,
                                              eff_ext_dtl_rec.a_Code_tbl,
                                              eff_ext_dtl_rec.a_Val_tbl;
   CLOSE get_effect_ext_detail;
   IF(eff_ext_dtl_rec.eflag_tbl.COUNT = 0)THEN
     RETURN match_dtl;
   ELSE
     FOR i IN eff_ext_dtl_rec.eflag_tbl.FIRST..eff_ext_dtl_rec.eflag_tbl.LAST LOOP
       IF(eff_ext_dtl_rec.rectype_tbl(i) = 'OWNER' OR eff_ext_dtl_rec.rectype_tbl(i) = 'LOCATION')THEN
         fetch_inst_attr := TRUE;
       ELSIF(eff_ext_dtl_rec.rectype_tbl(i) = 'CSIEXTATTR')THEN
         fetch_inst_ext_attr := TRUE;
       END IF;
     END LOOP;
     IF(fetch_inst_attr) THEN
       OPEN get_inst_attributes(p_item_instance_id);
       FETCH get_inst_attributes INTO l_inst_attr_rec.owner_party_id,l_inst_attr_rec.location_type_code;
       CLOSE get_inst_attributes;
     END IF;

     FOR i IN eff_ext_dtl_rec.eflag_tbl.FIRST..eff_ext_dtl_rec.eflag_tbl.LAST LOOP
       IF(eff_ext_dtl_rec.rectype_tbl(i) = 'OWNER')THEN
         IF(eff_ext_dtl_rec.eflag_tbl(i) = 'N')THEN
           match_dtl := FALSE;
           IF(l_inst_attr_rec.owner_party_id = eff_ext_dtl_rec.owner_id_tbl(i))THEN
              match_dtl := TRUE;
              EXIT;
           END IF;
         ELSE
           IF(l_inst_attr_rec.owner_party_id = eff_ext_dtl_rec.owner_id_tbl(i))THEN
              match_dtl := FALSE;
              EXIT;
           END IF;
         END IF;
       END IF;
     END LOOP;
     IF (match_dtl = FALSE) THEN
       RETURN match_dtl;
     END IF;
     FOR i IN eff_ext_dtl_rec.eflag_tbl.FIRST..eff_ext_dtl_rec.eflag_tbl.LAST LOOP
       IF (eff_ext_dtl_rec.rectype_tbl(i) = 'LOCATION')THEN
         IF(eff_ext_dtl_rec.eflag_tbl(i) = 'N')THEN
           match_dtl := FALSE;
           IF(l_inst_attr_rec.location_type_code = eff_ext_dtl_rec.loc_tbl(i))THEN
              match_dtl := TRUE;
              EXIT;
           END IF;
         ELSE
           IF(l_inst_attr_rec.location_type_code = eff_ext_dtl_rec.loc_tbl(i))THEN
              match_dtl := FALSE;
              EXIT;
           END IF;
         END IF;
       END IF;
     END LOOP;
     IF (match_dtl = FALSE OR fetch_inst_ext_attr = FALSE)THEN
       RETURN match_dtl;
     END IF;

     OPEN get_inst_ext_attributes(p_item_instance_id);
     FETCH get_inst_ext_attributes BULK COLLECT INTO
                                              inst_ext_dtl_rec.a_Code_tbl,
                                              inst_ext_dtl_rec.a_Val_tbl;
     CLOSE get_inst_ext_attributes;

     FOR i IN eff_ext_dtl_rec.eflag_tbl.FIRST..eff_ext_dtl_rec.eflag_tbl.LAST LOOP
       IF(eff_ext_dtl_rec.rectype_tbl(i) = 'CSIEXTATTR')THEN

         IF(eff_ext_dtl_rec.eflag_tbl(i) = 'N')THEN
           match_dtl := FALSE;
           IF (inst_ext_dtl_rec.a_Code_tbl.COUNT = 0)THEN
             EXIT;
           END IF;
           FOR j IN inst_ext_dtl_rec.a_Code_tbl.FIRST..inst_ext_dtl_rec.a_Code_tbl.LAST LOOP

             IF(inst_ext_dtl_rec.a_Code_tbl(j) = eff_ext_dtl_rec.a_Code_tbl(i) AND
                inst_ext_dtl_rec.a_Val_tbl(j) = eff_ext_dtl_rec.a_Val_tbl(i))THEN
                -- AHL_DEBUG_PUB.debug('Matched exiting - for include');
                match_dtl := TRUE;
                EXIT;
             END IF;
           END LOOP;
           IF match_dtl = TRUE THEN
             EXIT;
           END IF;
         ELSE
           match_dtl := TRUE;
           IF (inst_ext_dtl_rec.a_Code_tbl.COUNT = 0)THEN
             EXIT;
           END IF;
           FOR j IN inst_ext_dtl_rec.a_Code_tbl.FIRST..inst_ext_dtl_rec.a_Code_tbl.LAST LOOP

             IF(inst_ext_dtl_rec.a_Code_tbl(j) = eff_ext_dtl_rec.a_Code_tbl(i) AND
                inst_ext_dtl_rec.a_Val_tbl(j) = eff_ext_dtl_rec.a_Val_tbl(i))THEN
                match_dtl := FALSE;
                -- AHL_DEBUG_PUB.debug('Matched exiting - for exclude');
                EXIT;
             END IF;
           END LOOP;
           IF match_dtl = FALSE THEN
             EXIT;
           END IF;
         END IF;
       END IF;
     END LOOP;

   END IF;

   RETURN match_dtl;
END CHECK_EFFECTIVITY_EXT_DETAILS;

-- Define Local Procedure strip_serial_number_prefix --
PROCEDURE strip_serial_number_prefix(
  p_serial_number                IN    VARCHAR2,
  x_serial_prefix                OUT NOCOPY   VARCHAR2,
  x_serial_suffix                OUT NOCOPY   NUMBER
) IS
  i                              NUMBER  := 0;
  l_debug                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
BEGIN
  LOOP
    i := i+1;
    EXIT WHEN SUBSTR(p_serial_number,-i,1) NOT IN ('0','1','2','3','4','5','6','7','8','9')
              OR i > LENGTH(p_serial_number);
  END LOOP;
  x_serial_prefix := SUBSTR(p_serial_number,1,LENGTH(p_serial_number)-i+1);
  x_serial_suffix := TO_NUMBER(NVL(SUBSTR(p_serial_number,-i+1,i-1),0));
END strip_serial_number_prefix;

-- Check to see whether a VARCHAR2 contains only numeric values
FUNCTION sn_num(
  p_serial_number                IN    VARCHAR2
) RETURN BOOLEAN IS
  i                              NUMBER  := 0;

BEGIN
  LOOP
    i := i+1;
    EXIT WHEN SUBSTR(p_serial_number,-i,1) NOT IN ('0','1','2','3','4','5','6','7','8','9')
              OR i > LENGTH(p_serial_number);
  END LOOP;
  IF i = LENGTH(p_serial_number) + 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END sn_num;

-- Check to see whether a given serial number is within the serial number range defined.
FUNCTION check_sn_inside(
  p_sn                          IN    VARCHAR2,
  p_sn1                         IN    VARCHAR2,
  p_sn2                         IN    VARCHAR2
) RETURN BOOLEAN IS
BEGIN
  IF (p_sn) IS NULL THEN
    RETURN FALSE;
  END IF;

  IF (p_sn1 IS NOT NULL AND sn_num(p_sn1) AND p_sn2 IS NOT NULL AND sn_num(p_sn2)) THEN
    IF (sn_num(p_sn)) THEN
      IF (TO_NUMBER(p_sn1)<=TO_NUMBER(p_sn) AND TO_NUMBER(p_sn)<=TO_NUMBER(p_sn2)) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    -- nonnumeric case.
    ELSE
      IF (p_sn1 <= p_sn AND p_sn<= p_sn2) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  ELSIF (p_sn1 IS NULL AND p_sn2 IS NOT NULL AND sn_num(p_sn2)) THEN
    IF (sn_num(p_sn)) THEN
      IF (TO_NUMBER(p_sn)<=TO_NUMBER(p_sn2)) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
      -- nonnumeric case.
    ELSE
      IF (p_sn <= p_sn2) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  ELSIF (p_sn2 IS NULL AND p_sn1 IS NOT NULL AND sn_num(p_sn1)) THEN
    IF (sn_num(p_sn)) THEN
      IF (TO_NUMBER(p_sn1)<=TO_NUMBER(p_sn)) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
      -- nonnumeric case.
    ELSE
      IF (p_sn1<p_sn) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  ELSIF (p_sn1 IS NOT NULL AND p_sn2 IS NOT NULL AND (NOT sn_num(p_sn1) OR NOT sn_num(p_sn2))) THEN
    IF (p_sn IS NOT NULL AND p_sn <= P_sn2 AND p_sn >= p_sn1) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn1 IS NOT NULL AND NOT sn_num(p_sn1) AND p_sn2 IS NULL) THEN
    IF (p_sn IS NOT NULL AND p_sn >= p_sn1) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn2 IS NOT NULL AND NOT sn_num(p_sn2) AND p_sn1 IS NULL) THEN
    IF (p_sn IS NOT NULL AND p_sn <= p_sn2) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSE
    RETURN TRUE;
  END IF;
END check_sn_inside;


-- Check to see whether a given serial number is outside of the serial number range defined.
FUNCTION check_sn_outside(
  p_sn                          IN    VARCHAR2,
  p_sn1                         IN    VARCHAR2,
  p_sn2                         IN    VARCHAR2
) RETURN BOOLEAN IS
BEGIN

  -- serial number is null.
  IF (p_sn IS NULL) THEN
    RETURN FALSE;
  END IF;

  IF (p_sn1 IS NOT NULL AND sn_num(p_sn1) AND p_sn2 IS NOT NULL AND sn_num(p_sn2)) THEN
    IF (sn_num(p_sn)) THEN
      IF (TO_NUMBER(p_sn1)>TO_NUMBER(p_sn) OR TO_NUMBER(p_sn)>TO_NUMBER(p_sn2)) THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
    -- fix for bug# 6449096 - non-numeric serials.
    ELSIF (p_sn > P_sn2 OR p_sn < p_sn1) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn1 IS NULL AND p_sn2 IS NOT NULL AND sn_num(p_sn2)) THEN
    IF (sn_num(p_sn)) THEN
      IF (TO_NUMBER(p_sn)>TO_NUMBER(p_sn2)) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    -- fix for bug# 6449096 - non-numeric serials.
    ELSIF (p_sn > P_sn2) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn2 IS NULL AND p_sn1 IS NOT NULL AND sn_num(p_sn1)) THEN
    IF (sn_num(p_sn)) THEN
      IF (TO_NUMBER(p_sn1)>TO_NUMBER(p_sn)) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    -- fix for bug# 6449096 - non-numeric serials.
    ELSIF (p_sn1 > p_sn) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn1 IS NOT NULL AND p_sn2 IS NOT NULL AND (NOT sn_num(p_sn1) OR NOT sn_num(p_sn2))) THEN
    IF (p_sn > P_sn2 OR p_sn < p_sn1) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn1 IS NOT NULL AND NOT sn_num(p_sn1) AND p_sn2 IS NULL) THEN
    IF (p_sn < p_sn1) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF (p_sn2 IS NOT NULL AND NOT sn_num(p_sn2) AND p_sn1 IS NULL) THEN
    IF (p_sn > p_sn2) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSE
    RETURN TRUE;
  END IF;

  -- if control reached here, then return status FALSE.
  RETURN FALSE;
END check_sn_outside;

PROCEDURE GET_PM_APPLICABLE_MRS (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_item_instance_id      IN  NUMBER,
  x_applicable_activities_tbl OUT NOCOPY applicable_activities_tbl_type,
  x_applicable_programs_tbl   OUT NOCOPY applicable_programs_tbl_type
) IS
  iap                     NUMBER;
  iap_u                   NUMBER;
  iaa                     NUMBER;
  l_api_name              CONSTANT VARCHAR2(30) := 'GET_PM_APPLICABLE_MRS';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_item_instance_id      NUMBER;
  l_inventory_item_id     NUMBER;
  l_pm_install            VARCHAR2(1);
  l_appln_code           VARCHAR2(30):=FND_PROFILE.VALUE('AHL_APPLN_USAGE');
  l_inp_rec               OKS_PM_ENTITLEMENTS_PUB.get_pmcontin_rec;
  l_ent_contracts         OKS_ENTITLEMENTS_PUB.get_contop_tbl;
  l_pm_activities         OKS_PM_ENTITLEMENTS_PUB.get_activityop_tbl;
  l_prior_mr_header_id    NUMBER;
/*
  TYPE unique_mr_headers_rec_type IS RECORD
  (
    mr_header_id          NUMBER,
    service_line_id       NUMBER
  );
  TYPE unique_mr_headers_tbl_type IS TABLE OF unique_mr_headers_rec_type
    INDEX BY BINARY_INTEGER;
  l_unique_mr_headers_tbl      unique_mr_headers_tbl_type;
*/
  CURSOR get_applicable_mrs(c_inventory_item_id NUMBER) IS
  SELECT mr_header_id, mr_effectivity_id
  FROM ahl_mr_effectivities_app_v
     WHERE inventory_item_id = c_inventory_item_id
  ORDER BY mr_header_id, mr_effectivity_id;

/*
  CURSOR get_activities(c_mr_header_id NUMBER) IS
    SELECT related_mr_header_id
      FROM ahl_mr_relationships_app_v
     WHERE mr_header_id = c_mr_header_id
       AND relationship_code = 'PARENT';
*/
  --Get attributes of a given MR
  CURSOR get_mr_attri(c_mr_header_id NUMBER) IS
    SELECT repetitive_flag,
           show_repetitive_code,
           whichever_first_code,
           implement_status_code
      FROM ahl_mr_headers_app_v
     WHERE mr_header_id = c_mr_header_id;
  l_get_mr_attri             get_mr_attri%ROWTYPE;
  l_debug                 VARCHAR2(1) :=AHL_DEBUG_PUB.is_log_enabled;
BEGIN
  SAVEPOINT GET_PM_APPLICABLE_MRS_PVT;
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Begin private API: AHL_FMP_PVT.GET_PM_APPLICABLE_MRS');
    AHL_DEBUG_PUB.debug('');
  END IF;
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := 'S';
  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version,
                                     l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_appln_code:=nvl(FND_PROFILE.VALUE('AHL_APPLN_USAGE'),'x');
  IF l_appln_code <> 'PM' THEN
    FND_MESSAGE.set_name('AHL', 'AHL_FMP_PM_NOT_INSTALLED');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN check_instance_exists(p_item_instance_id);
  FETCH check_instance_exists INTO l_item_instance_id;
  IF check_instance_exists%NOTFOUND THEN
    CLOSE check_instance_exists;
    FND_MESSAGE.SET_NAME('AHL','AHL_FMP_INVALID_ITEM_INSTANCE');
    FND_MESSAGE.SET_TOKEN('INSTANCE',p_item_instance_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE check_instance_exists;

  OPEN get_inventory_item(p_item_instance_id);
  FETCH get_inventory_item INTO l_inventory_item_id;
  IF get_inventory_item%NOTFOUND THEN
    CLOSE get_inventory_item;
    FND_MESSAGE.set_name('AHL', 'AHL_FMP_ITEM_NOT_EXISTS');
    FND_MESSAGE.set_token('INSTANCE',p_item_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE get_inventory_item;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('Item instance id:' || l_item_instance_id);
  END IF;

  -- Call OKS API to get program_ids
  l_inp_rec.contract_number := NULL;
  l_inp_rec.contract_number_modifier := NULL;
  l_inp_rec.service_line_id := NULL;
  l_inp_rec.party_id := NULL;
  l_inp_rec.item_id := NULL;
  l_inp_rec.product_id := l_item_instance_id;
  l_inp_rec.request_date := NULL;

  -- sracha[FP Bug #5509763] -- Changes begin
  -- l_inp_rec.request_date_start := NULL;
  -- l_inp_rec.request_date_end := NULL;
  l_inp_rec.request_date_start := sysdate;
  l_inp_rec.request_date_end := to_date('31-12-4712','DD-MM-YYYY');
  -- sracha [FP Bug #5509763] -- Changes end

  l_inp_rec.sort_key := NULL;

  OKS_PM_ENTITLEMENTS_PUB.get_pm_contracts
  (  p_api_version        => 1.0,
     p_init_msg_list      => FND_API.G_TRUE,
     p_inp_rec            => l_inp_rec,
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data           => l_msg_data,
     x_ent_contracts      => l_ent_contracts,
     x_pm_activities      => l_pm_activities );
  IF l_msg_count > 0 THEN
    FND_MESSAGE.set_name('AHL', 'AHL_FMP_CALLING_OKS_API_ERROR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('Count on ent_contracts:' || l_ent_contracts.count);
    AHL_DEBUG_PUB.debug('Count on pm_activities:' || l_pm_activities.count );
  END IF;

  iap := 1;
  iaa := 1;
--  iap_u := 1;
--  l_prior_mr_header_id := -1;
  FOR l_get_applicable_mrs IN get_applicable_mrs(l_inventory_item_id) LOOP
    IF l_debug = 'Y' THEN
       AHL_DEBUG_PUB.debug('Appl MR found:' || l_get_applicable_mrs.mr_header_id);
    END IF;

    IF l_ent_contracts.COUNT > 0 THEN
      FOR i IN l_ent_contracts.FIRST..l_ent_contracts.LAST LOOP
        IF l_ent_contracts(i).pm_program_id = l_get_applicable_mrs.mr_header_id THEN

          IF l_debug = 'Y' THEN
            AHL_DEBUG_PUB.debug('Contract Number found:' || l_ent_contracts(i).contract_number);
            AHL_DEBUG_PUB.debug('Service Line ID:' || l_ent_contracts(i).service_line_id);
            AHL_DEBUG_PUB.debug('---------------------------');
          END IF;

          x_applicable_programs_tbl(iap).contract_id := l_ent_contracts(i).contract_id;
          x_applicable_programs_tbl(iap).contract_number := l_ent_contracts(i).contract_number;
          x_applicable_programs_tbl(iap).contract_number_modifier := l_ent_contracts(i).contract_number_modifier;
          x_applicable_programs_tbl(iap).sts_code := l_ent_contracts(i).sts_code;
          x_applicable_programs_tbl(iap).service_line_id := l_ent_contracts(i).service_line_id;
          x_applicable_programs_tbl(iap).service_name := l_ent_contracts(i).service_name;
          x_applicable_programs_tbl(iap).service_description := l_ent_contracts(i).service_description;
          x_applicable_programs_tbl(iap).coverage_term_line_id := l_ent_contracts(i).coverage_term_line_id;
          x_applicable_programs_tbl(iap).coverage_term_name := l_ent_contracts(i).coverage_term_name;
          x_applicable_programs_tbl(iap).coverage_term_description := l_ent_contracts(i).coverage_term_description;
          x_applicable_programs_tbl(iap).coverage_type_code := l_ent_contracts(i).coverage_type_code;
          x_applicable_programs_tbl(iap).coverage_type_meaning := l_ent_contracts(i).coverage_type_meaning;
          x_applicable_programs_tbl(iap).coverage_type_imp_level := l_ent_contracts(i).coverage_type_imp_level;
          x_applicable_programs_tbl(iap).service_start_date := l_ent_contracts(i).service_start_date;
          x_applicable_programs_tbl(iap).service_end_date := l_ent_contracts(i).service_end_date;
          x_applicable_programs_tbl(iap).warranty_flag := l_ent_contracts(i).warranty_flag;
          x_applicable_programs_tbl(iap).eligible_for_entitlement := l_ent_contracts(i).eligible_for_entitlement;
          x_applicable_programs_tbl(iap).exp_reaction_time := l_ent_contracts(i).exp_reaction_time;
          x_applicable_programs_tbl(iap).exp_resolution_time := l_ent_contracts(i).exp_resolution_time;
          x_applicable_programs_tbl(iap).status_code := l_ent_contracts(i).status_code;
          x_applicable_programs_tbl(iap).status_text := l_ent_contracts(i).status_text;
          x_applicable_programs_tbl(iap).date_terminated := l_ent_contracts(i).date_terminated;
          x_applicable_programs_tbl(iap).pm_schedule_exists := l_ent_contracts(i).pm_schedule_exists;
          x_applicable_programs_tbl(iap).pm_program_id := l_ent_contracts(i).pm_program_id;
          x_applicable_programs_tbl(iap).mr_effectivity_id := l_get_applicable_mrs.mr_effectivity_id;
          iap := iap + 1;
        END IF;
      END LOOP;
    END IF;
/*        IF l_ent_contracts(i).pm_program_id <> l_prior_mr_header_id THEN
          l_unique_mr_headers_tbl(iap_u).mr_header_id := l_ent_contracts(i).pm_program_id;
          l_unique_mr_headers_tbl(iap_u).service_line_id := l_ent_contracts(i).service_line_id;
          iap_u := iap_u + 1;
        END IF;
        l_prior_mr_header_id := l_ent_contracts(i).pm_program_id;
*/
    IF l_pm_activities.COUNT > 0 THEN
      FOR i IN l_pm_activities.FIRST..l_pm_activities.LAST LOOP
        IF (l_pm_activities(i).activity_id = l_get_applicable_mrs.mr_header_id ) THEN
          x_applicable_activities_tbl(iaa).mr_header_id := l_pm_activities(i).activity_id;
          x_applicable_activities_tbl(iaa).item_instance_id := l_item_instance_id;
          x_applicable_activities_tbl(iaa).program_mr_header_id := l_pm_activities(i).pm_program_id;
          x_applicable_activities_tbl(iaa).service_line_id := l_pm_activities(i).service_line_id;
          x_applicable_activities_tbl(iaa).act_schedule_exists := l_pm_activities(i).act_schedule_exists;
          x_applicable_activities_tbl(iaa).mr_effectivity_id := l_get_applicable_mrs.mr_effectivity_id;
          iaa := iaa + 1;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
/*
  iaa := 1;
  IF x_applicable_programs_tbl.COUNT >= 1 THEN
    FOR i IN x_applicable_programs_tbl.FIRST..x_applicable_programs_tbl.LAST LOOP
      FOR l_get_activities IN get_activities(x_applicable_programs_tbl(i).pm_program_id) LOOP
        FOR l_get_applicable_mrs IN get_applicable_mrs(l_inventory_item_id) LOOP
          IF l_get_activities.related_mr_header_id = l_get_applicable_mrs.mr_header_id THEN
            x_applicable_activities_tbl(iaa).mr_header_id := l_get_applicable_mrs.mr_header_id;
            x_applicable_activities_tbl(iaa).mr_effectivity_id := l_get_applicable_mrs.mr_effectivity_id;
            x_applicable_activities_tbl(iaa).program_mr_header_id := x_applicable_programs_tbl(i).pm_program_id;
            x_applicable_activities_tbl(iaa).service_line_id := x_applicable_programs_tbl(i).service_line_id;
            iaa := iaa + 1;
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;
  END IF;
*/
  IF x_applicable_activities_tbl.COUNT >= 1 THEN
    FOR i IN x_applicable_activities_tbl.FIRST..x_applicable_activities_tbl.LAST LOOP
      OPEN get_mr_attri(x_applicable_activities_tbl(i).mr_header_id);
      FETCH get_mr_attri INTO l_get_mr_attri;
      IF get_mr_attri%NOTFOUND THEN
        CLOSE get_mr_attri;
        FND_MESSAGE.set_name('AHL','AHL_FMP_INVALID_MR');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        x_applicable_activities_tbl(i).repetitive_flag := l_get_mr_attri.repetitive_flag;
        x_applicable_activities_tbl(i).show_repetitive_code := l_get_mr_attri.show_repetitive_code;
        x_applicable_activities_tbl(i).whichever_first_code := l_get_mr_attri.whichever_first_code;
        x_applicable_activities_tbl(i).implement_status_code := l_get_mr_attri.implement_status_code;
        CLOSE get_mr_attri;
      END IF;
    END LOOP;
  END IF;

  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.debug('End private API: AHL_FMP_PVT.GET_PM_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
  ROLLBACK TO GET_PM_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                    'UNEXPECTED ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_PM_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO GET_PM_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  IF l_debug = 'Y' THEN
    AHL_DEBUG_PUB.log_app_messages(x_msg_count, x_msg_data,
                                   'ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_PM_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;
WHEN OTHERS THEN
  ROLLBACK TO GET_PM_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_FMP_PVT',
                            p_procedure_name => 'GET_PM_APPLICABLE_MRS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  END IF;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);
  IF l_debug = 'Y' THEN

    AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data,
                                    'OTHER ERROR IN PRIVATE:' );
    AHL_DEBUG_PUB.debug('AHL_FMP_PVT.GET_PM_APPLICABLE_MRS');
    AHL_DEBUG_PUB.disable_debug;
  END IF;

END GET_PM_APPLICABLE_MRS;


PROCEDURE get_visit_applicable_mrs (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_item_instance_id      IN  NUMBER,
  p_visit_type_code       IN  VARCHAR2
  )
AS
 l_api_version     CONSTANT NUMBER := 1.0;
 l_appl_mrs_tbl    AHL_FMP_PVT.applicable_mr_tbl_type;

BEGIN
  -- Initialize temporary table.
  SAVEPOINT GET_VISIT_APPLICABLE_MRS_PVT;
  DELETE FROM AHL_APPLICABLE_MRS;

  -- call api to fetch all applicable mrs for ASO installation.
  AHL_FMP_PVT.get_applicable_mrs(
                   p_api_version            => l_api_version,
         	   p_init_msg_list          => FND_API.G_FALSE,
	           p_commit                 => FND_API.G_FALSE,
        	   p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data,
         	   p_item_instance_id       => p_item_instance_id,
         	   p_components_flag        => 'N',
                   p_include_doNotImplmt    => 'Y',
                   p_visit_type_code        => p_visit_type_code,
	           x_applicable_mr_tbl      => l_appl_mrs_tbl);

  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;



  -- Populate temporary table ahl_applicable_mrs.
  IF (l_appl_mrs_tbl.COUNT > 0) THEN
     FOR i IN l_appl_mrs_tbl.FIRST..l_appl_mrs_tbl.LAST LOOP
     -- dbms_output.put_line( l_appl_mrs_tbl(i).item_instance_id||'  '||
     -- l_appl_mrs_tbl(i).mr_header_id);
           INSERT INTO AHL_APPLICABLE_MRS
           (
       	    CSI_ITEM_INSTANCE_ID,
 	        MR_HEADER_ID,
       	    MR_EFFECTIVITY_ID,
 	        REPETITIVE_FLAG   ,
      	    SHOW_REPETITIVE_CODE,
 	        COPY_ACCOMPLISHMENT_CODE,
 	        PRECEDING_MR_HEADER_ID,
  	        IMPLEMENT_STATUS_CODE,
 	        DESCENDENT_COUNT
           )
           Values
      	   (
           l_appl_mrs_tbl(i).item_instance_id,
	       l_appl_mrs_tbl(i).mr_header_id,
	       l_appl_mrs_tbl(i).mr_effectivity_id,
	       l_appl_mrs_tbl(i).repetitive_flag,
	       l_appl_mrs_tbl(i).show_repetitive_code,
	       l_appl_mrs_tbl(i).copy_accomplishment_flag,
	       l_appl_mrs_tbl(i).preceding_mr_header_id,
 	       l_appl_mrs_tbl(i).implement_status_code,
	       l_appl_mrs_tbl(i).descendent_count
	      );
     END LOOP;
  END IF;

  AHL_UMP_UTIL_PKG.process_group_mrs;

  -- Delete visit types that do not match..
  DELETE AHL_APPLICABLE_MRS A
  WHERE NOT EXISTS (SELECT 'x' FROM AHL_MR_VISIT_TYPES
                    WHERE MR_HEADER_ID=A.MR_HEADER_ID
                      AND MR_VISIT_TYPE_CODE  = P_VISIT_TYPE_CODE
                         );

  -- delete MRs from relationships table to remove duplicates.
  DELETE AHL_APPLICABLE_MRS A
  WHERE EXISTS ( select 'x' FROM
                 AHL_APPLICABLE_MR_RELNS REL
                 WHERE REL.related_mr_header_id  = A.mr_header_id
                    AND REL.RELATED_CSI_ITEM_INSTANCE_ID = A.CSI_ITEM_INSTANCE_ID);

  -- Delete corressponding records for the above deletes from relationships table.
  DELETE AHL_APPLICABLE_MR_RELNS A
  WHERE NOT EXISTS (SELECT 'x' FROM AHL_APPLICABLE_MRS B
                    WHERE B.MR_HEADER_ID = A.ORIG_MR_HEADER_ID
                      AND B.CSI_ITEM_INSTANCE_ID = A.ORIG_CSI_ITEM_INSTANCE_ID);



EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
  ROLLBACK TO GET_VISIT_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO GET_VISIT_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
WHEN OTHERS THEN
  ROLLBACK TO GET_VISIT_APPLICABLE_MRS_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'AHL_FMP_PVT',
                            p_procedure_name => 'GET_PM_APPLICABLE_MRS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  END IF;
  FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);
END GET_VISIT_APPLICABLE_MRS;

FUNCTION is_pc_assoc_valid(p_item_instance_id  IN  NUMBER,p_pc_node_id IN NUMBER) RETURN VARCHAR2 IS

/* modified to fix perf bug# 9620276. Split cursor into 2 queries.
CURSOR validate_pc_node_csr (c_instance_id NUMBER,
                             c_pc_node_id  NUMBER)
IS
  WITH ii AS (SELECT object_id
                FROM csi_ii_relationships E
                START WITH E.subject_id = c_instance_id
                  -- sunil- fix for bug7411016
                  AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                  AND E.relationship_type_code = 'COMPONENT-OF'


                CONNECT BY E.subject_id = PRIOR E.object_id
                 -- sunil- fix for bug7411016
                  AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                  AND E.relationship_type_code = 'COMPONENT-OF'
              UNION ALL
              SELECT c_instance_id
                FROM DUAL)
    SELECT  'x' --pc_node_id --amsriniv
    FROM    ahl_pc_nodes_b B
    WHERE   B.pc_node_id = c_pc_node_id
    START WITH B.pc_node_id  IN (select pc_node_id
                                 from ahl_pc_associations itm, csi_item_instances csi,ii
                                 where itm.association_type_flag = 'I'
                                   and itm.unit_item_id = csi.inventory_item_id
                                   and csi.instance_id = ii.object_id
                                 UNION ALL
                                 select pc_node_id
                                 from ahl_pc_associations unit, ahl_unit_config_headers uc, ii
                                 where unit.association_type_flag = 'U'
                                   and unit.unit_item_id = uc.unit_config_header_id
                                   and uc.csi_item_instance_id = ii.object_id)
    CONNECT BY B.pc_node_id = PRIOR B.parent_node_id;
*/

  -- Get valid pc nodes for an instance
  -- check pc_node against items.
  CURSOR validate_itm_node_csr (c_instance_id NUMBER,
                                c_pc_node_id  NUMBER)
  IS
    SELECT  'x'
    FROM    ahl_pc_nodes_b B
    WHERE   B.pc_node_id = c_pc_node_id
    START WITH B.pc_node_id  IN (select pc_node_id
                                 from ahl_pc_associations itm, csi_item_instances csi,
                                   (select object_id
                                    FROM csi_ii_relationships E
                                    START WITH E.subject_id = c_instance_id
                                    AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                                    CONNECT BY E.subject_id = PRIOR E.object_id
                                    AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                                    UNION ALL
                                    SELECT c_instance_id
                                    FROM DUAL) ii
                                 where itm.association_type_flag = 'I'
                                   and itm.unit_item_id = csi.inventory_item_id
                                   and csi.instance_id = ii.object_id)
    CONNECT BY B.pc_node_id = PRIOR B.parent_node_id;

  -- check pc_node against units.
  CURSOR validate_unit_node_csr (c_instance_id NUMBER,
                                 c_pc_node_id  NUMBER)
  IS
    SELECT  'x'
    FROM    ahl_pc_nodes_b B
    WHERE   B.pc_node_id = c_pc_node_id
    START WITH B.pc_node_id  IN (select pc_node_id
                                 from ahl_pc_associations unit, ahl_unit_config_headers uc,
                                   (select object_id
                                    FROM csi_ii_relationships E
                                    START WITH E.subject_id = c_instance_id
                                    AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                                    CONNECT BY E.subject_id = PRIOR E.object_id
                                    AND SYSDATE between trunc(nvl(E.active_start_date,sysdate)) and trunc(nvl(E.active_end_date,sysdate+1))
                                    UNION ALL
                                    SELECT c_instance_id
                                    FROM DUAL) ii
                                 where unit.association_type_flag = 'U'
                                   and unit.unit_item_id = uc.unit_config_header_id
                                   and uc.csi_item_instance_id = ii.object_id)
    CONNECT BY B.pc_node_id = PRIOR B.parent_node_id;

    l_junk VARCHAR2(1);

BEGIN
  /* modified for bug# 9620276
  OPEN validate_pc_node_csr(p_item_instance_id,p_pc_node_id);
  FETCH validate_pc_node_csr INTO l_junk;
  IF(validate_pc_node_csr%NOTFOUND)THEN
    CLOSE validate_pc_node_csr;
    RETURN FND_API.G_FALSE;
  END IF;
  CLOSE validate_pc_node_csr;
  RETURN FND_API.G_TRUE;
  */

  -- check for units first.
  OPEN validate_unit_node_csr(p_item_instance_id, p_pc_node_id);
  FETCH validate_unit_node_csr INTO l_junk;
  IF (validate_unit_node_csr%FOUND) THEN
    CLOSE validate_unit_node_csr;
    RETURN FND_API.G_TRUE;
  ELSE
    CLOSE validate_unit_node_csr;
    -- check for item PCs
    OPEN validate_itm_node_csr(p_item_instance_id, p_pc_node_id);
    FETCH validate_itm_node_csr INTO l_junk;
    IF (validate_itm_node_csr%FOUND) THEN
      CLOSE validate_itm_node_csr;
      RETURN FND_API.G_TRUE;
    END IF;
    CLOSE validate_itm_node_csr;
  END IF;
  RETURN FND_API.G_FALSE;

END is_pc_assoc_valid;

END AHL_FMP_PVT; -- Package Body

/
