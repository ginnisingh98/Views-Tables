--------------------------------------------------------
--  DDL for Package Body AHL_UC_TREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_TREE_PVT" AS
/* $Header: AHLVUCTB.pls 120.2.12010000.2 2008/11/06 10:55:52 sathapli ship $ */

-- Define global internal variables and cursors
G_PKG_NAME VARCHAR2(30) := 'AHL_UC_TREE_PVT';

-- Added by rbhavsar on July 25, 2007 to remap IB Tree Nodes to fix FP bug 6276991
TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE Remap_IB_Tree(p_instance_id     IN  NUMBER,
                        p_relationship_id IN  NUMBER);

PROCEDURE Process_instances(p_x_extra_instances_tbl IN OUT NOCOPY T_ID_TBL,
                            p_x_relations_tbl       IN OUT NOCOPY T_ID_TBL);

-- Define procedure get_immediate_children
-- This API is used to draw the UC tree. For a given node, it will list all of its
-- immediate children nodes.
/*
PROCEDURE get_immediate_children(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_parent_rec         IN  uc_child_rec_type,
  x_uc_child_tbl          OUT NOCOPY uc_child_tbl_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'get_immediate_children';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_relationship_id           NUMBER;
  l_children_no               NUMBER;
  l_dummy                     VARCHAR2(1);
  i                           NUMBER;
  CURSOR check_installed_instance IS
    SELECT 'x'
      FROM ahl_unit_config_headers U,
           ahl_mc_relationships R
     WHERE U.master_config_id = R.mc_header_id
       AND R.parent_relationship_id IS NULL
       AND U.csi_item_instance_id = p_uc_parent_rec.instance_id
       AND R.relationship_id = p_uc_parent_rec.relationship_id
       AND nvl(trunc(U.active_end_date), trunc(SYSDATE)+1) > trunc(SYSDATE)
     UNION
    SELECT 'x'
      FROM csi_ii_relationships
     WHERE subject_id =  p_uc_parent_rec.instance_id
       AND position_reference = to_char(p_uc_parent_rec.relationship_id)
       AND nvl(trunc(active_end_date), trunc(SYSDATE)+1) > trunc(SYSDATE);
  CURSOR check_relationship IS
    SELECT 'x'
      FROM ahl_mc_relationships
     WHERE relationship_id = p_uc_parent_rec.relationship_id;
  CURSOR check_instance IS
    SELECT 'x'
      FROM csi_item_instances
     WHERE instance_id = p_uc_parent_rec.instance_id;
  CURSOR get_top_position(c_instance_id number) IS
    SELECT B.relationship_id
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.master_config_id = B.mc_header_id
       AND B.parent_relationship_id IS NULL
       AND A.csi_item_instance_id = c_instance_id;
  -- get immediate children for installed node
  CURSOR get_child_nodes_i(c_instance_id number, c_relationship_id number) IS
    SELECT 'X' node_type, subject_id instance_id, NULL relationship_id
      FROM csi_ii_relationships
     WHERE object_id = c_instance_id
       AND position_reference IS NULL
     UNION
    SELECT 'I' node_type, subject_id instance_id, to_number(position_reference) relationship_id
      FROM csi_ii_relationships
     WHERE object_id = c_instance_id
       AND position_reference IS NOT NULL
       AND nvl(trunc(active_end_date), trunc(SYSDATE)+1) > trunc(SYSDATE)
     UNION
    SELECT 'E' node_type, NULL instance_id, relationship_id
      FROM ahl_mc_relationships
     WHERE parent_relationship_id = c_relationship_id
       AND relationship_id NOT IN (SELECT position_reference
                                     FROM csi_ii_relationships
                                    WHERE object_id = c_instance_id
                                      AND position_reference IS NOT NULL
                                      AND nvl(trunc(active_end_date), trunc(SYSDATE)+1) > trunc(SYSDATE));
  l_get_child_nodes_i         get_child_nodes_i%ROWTYPE;
  -- get immediate children for empty node
  CURSOR get_child_nodes_m(c_relationship_id number) IS
    SELECT 'E' node_type, NULL instance_id, relationship_id
      FROM ahl_mc_relationships
     WHERE parent_relationship_id = c_relationship_id;
  -- get immediate children for extra node
  CURSOR get_child_nodes_x(c_instance_id number) IS
    SELECT 'X' node_type, subject_id instance_id, to_number(position_reference) relationship_id
      FROM csi_ii_relationships
     WHERE object_id  = c_instance_id
       AND nvl(trunc(active_end_date), trunc(SYSDATE)+1) > trunc(SYSDATE);
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
  END IF;

  -- Validate the input parameter
  IF (p_uc_parent_rec.node_type IS NULL OR p_uc_parent_rec.node_type NOT IN ('I', 'E', 'X') OR
      (p_uc_parent_rec.instance_id IS NULL AND p_uc_parent_rec.relationship_id IS NULL))THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
    FND_MSG_PUB.add;
  END IF;
  IF p_uc_parent_rec.node_type = 'I' THEN
    IF p_uc_parent_rec.instance_id IS NULL OR p_uc_parent_rec.relationship_id IS NULL THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
      FND_MSG_PUB.add;
    ELSE
      OPEN check_installed_instance;
      FETCH check_installed_instance INTO l_dummy;
      IF check_installed_instance%NOTFOUND THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
        FND_MSG_PUB.add;
      END IF;
      CLOSE check_installed_instance;
    END IF;
  ELSIF p_uc_parent_rec.node_type = 'M' THEN
    IF p_uc_parent_rec.instance_id IS NOT NULL OR p_uc_parent_rec.relationship_id IS NULL THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
      FND_MSG_PUB.add;
    ELSE
      OPEN check_relationship;
      FETCH check_relationship INTO l_dummy;
      IF check_relationship%NOTFOUND THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
        FND_MSG_PUB.add;
      END IF;
      CLOSE check_relationship;
    END IF;
  ELSIF p_uc_parent_rec.node_type = 'X' THEN
    IF p_uc_parent_rec.instance_id IS NULL THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
      FND_MSG_PUB.add;
    ELSE
      OPEN check_instance;
      FETCH check_instance INTO l_dummy;
      IF check_instance%NOTFOUND THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_NODE_INVALID' );
        FND_MSG_PUB.add;
      END IF;
      CLOSE check_instance;
    END IF;
  END IF;
  -- If the node is a sub-UC's top node, then replace the relationship_id (leaf node
  -- of its parent UC) with its own relationship_id (sub-UC's top node)
  OPEN get_top_position(p_uc_parent_rec.instance_id);
  FETCH get_top_position INTO l_relationship_id;
  IF get_top_position%NOTFOUND THEN
    l_relationship_id := p_uc_parent_rec.relationship_id;
  END IF;
  CLOSE get_top_position;
  i := 1;
  IF p_uc_parent_rec.node_type = 'I' THEN
    FOR l_get_child_nodes IN get_child_nodes_i(p_uc_parent_rec.instance_id, l_relationship_id) LOOP
      x_uc_child_tbl(i).node_type := l_get_child_nodes.node_type;
      x_uc_child_tbl(i).instance_id := l_get_child_nodes.instance_id;
      x_uc_child_tbl(i).relationship_id := l_get_child_nodes.relationship_id;
      i := i+1;
    END LOOP;
  ELSIF p_uc_parent_rec.node_type = 'M' THEN
    FOR l_get_child_nodes IN get_child_nodes_m(l_relationship_id) LOOP
      x_uc_child_tbl(i).node_type := l_get_child_nodes.node_type;
      x_uc_child_tbl(i).instance_id := l_get_child_nodes.instance_id;
      x_uc_child_tbl(i).relationship_id := l_get_child_nodes.relationship_id;
      i := i+1;
    END LOOP;
  ELSIF p_uc_parent_rec.node_type = 'X' THEN
    FOR l_get_child_nodes IN get_child_nodes_x(p_uc_parent_rec.instance_id) LOOP
      x_uc_child_tbl(i).node_type := l_get_child_nodes.node_type;
      x_uc_child_tbl(i).instance_id := l_get_child_nodes.instance_id;
      x_uc_child_tbl(i).relationship_id := l_get_child_nodes.relationship_id;
      i := i+1;
    END LOOP;
  END IF;
  IF x_uc_child_tbl.COUNT >0 THEN
    FOR j IN x_uc_child_tbl.FIRST .. x_uc_child_tbl.LAST LOOP
      IF x_uc_child_tbl(j).node_type = 'I' THEN
        x_uc_child_tbl(j).has_subconfig_flag := 'N';
        OPEN get_top_position(x_uc_child_tbl(j).instance_id);
        FETCH get_top_position INTO l_relationship_id;
        IF get_top_position%NOTFOUND THEN
          l_relationship_id := x_uc_child_tbl(j).relationship_id;
        END IF;
        CLOSE get_top_position;
        OPEN get_child_nodes_i(x_uc_child_tbl(j).instance_id, l_relationship_id);
        FETCH get_child_nodes_i INTO l_get_child_nodes_i;
        IF get_child_nodes_i%FOUND THEN
          x_uc_child_tbl(j).leaf_node_flag := 'Y';
        ELSE
          x_uc_child_tbl(j).leaf_node_flag := 'N';
        END IF;
      ELSIF x_uc_child_tbl(j).node_type = 'M' THEN
        SELECT count(relationship_id) INTO l_children_no
          FROM ahl_mc_relationships
         WHERE parent_relationship_id = x_uc_child_tbl(j).relationship_id;
        IF l_children_no > 0 THEN
          x_uc_child_tbl(j).has_subconfig_flag := 'N';
          x_uc_child_tbl(j).leaf_node_flag := 'N';
        ELSE
          x_uc_child_tbl(j).leaf_node_flag := 'Y';
          SELECT count(mc_header_id) INTO l_children_no
            FROM ahl_mc_config_relations
           WHERE relationship_id = x_uc_child_tbl(j).relationship_id;
          IF l_children_no > 0 THEN
            x_uc_child_tbl(j).has_subconfig_flag := 'Y';
          ELSE
            x_uc_child_tbl(j).has_subconfig_flag := 'N';
          END IF;
        END IF;
      ELSIF x_uc_child_tbl(j).node_type = 'X' THEN
        x_uc_child_tbl(j).has_subconfig_flag := 'N';
        SELECT count(subject_id) INTO l_children_no
          FROM csi_ii_relationships
         WHERE object_id = x_uc_child_tbl(j).instance_id;
        IF l_children_no > 0 THEN
          x_uc_child_tbl(j).leaf_node_flag := 'Y';
        ELSE
          x_uc_child_tbl(j).leaf_node_flag := 'N';
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
			       'At the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

END get_immediate_children;
*/

PROCEDURE get_whole_uc_tree(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  x_uc_descendant_tbl     OUT NOCOPY uc_descendant_tbl_type)
IS
  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- use PL/SQL tables for BULK COLLECT instead of looping through the cursor records
  /*
  TYPE l_uc_children_rec_type IS RECORD (
    instance_id               NUMBER,
    relationship_id           NUMBER,
    matched_flag              VARCHAR2(1));
  TYPE l_uc_children_tbl_type IS TABLE OF l_uc_children_rec_type INDEX BY BINARY_INTEGER;*/

  TYPE t_id_tbl       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE t_flag_tbl     IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE t_partinfo_tbl IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

  l_api_name       CONSTANT   VARCHAR2(30)   := 'get_whole_uc_tree';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_relationship_id           NUMBER;
  l_mc_header_id              NUMBER;
  l_root_instance_id          NUMBER;
  l_root_relationship_id      NUMBER;
  l_dummy                     VARCHAR2(1);
  l_dummy_num                 NUMBER;
  i                           NUMBER;
  -- l_uc_children_tbl           l_uc_children_tbl_type;
  l_child_inst_tbl            t_id_tbl;
  l_child_rel_tbl             t_id_tbl;
  l_child_matchflag_tbl       t_flag_tbl;
  l_child_partinfo_tbl        t_partinfo_tbl;
  l_pos_ref                   FND_LOOKUPS.meaning%TYPE;
  l_root_mc_hdr_id            NUMBER;
  l_root_mc_part              BOOLEAN;
  l_root_ata_code             AHL_MC_RELATIONSHIPS.ATA_CODE%TYPE; -- SATHAPLI::Enigma code changes, 02-Sep-2008

  l_matched                   boolean;
  total_i                     NUMBER; --index of output table
  i_uc_child                  NUMBER; --index of MC siblings
  l_uc_header_id              NUMBER;

  --Check the given uc_heder_id is valid and if yes, get the UC top node's instance_id
  --and relationship_id
  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- fetch the root UC's mc_header_id too
  -- SATHAPLI::Enigma code changes, 02-Sep-2008 - fetch the ata_code as well
  CURSOR get_uc_header_attr(c_uc_header_id NUMBER) IS
    SELECT A.csi_item_instance_id instance_id,
           A.master_config_id,
           B.relationship_id,
           B.ata_code
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.unit_config_header_id = c_uc_header_id
       AND A.master_config_id = B.mc_header_id
       AND B.parent_relationship_id IS NULL;

  --Given an instance_id, get all of its immediate children from csi_ii_relationships
  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- Object_id is not used in the code, so removing it.
  -- Also, no need for ORDER BY for extra nodes.
  CURSOR get_csi_children(c_instance_id NUMBER) IS
    SELECT R.subject_id instance_id,
           to_number(R.position_reference) relationship_id,
           M.concatenated_segments||'-'||NVL(C.serial_number, C.instance_number) part_info,
           'N'
      FROM csi_ii_relationships R,
           csi_item_instances C,
           mtl_system_items_kfv M
     WHERE R.object_id                              = c_instance_id
       AND R.subject_id                             = C.instance_id
       AND C.inventory_item_id                      = M.inventory_item_id
       AND C.inv_master_organization_id             = M.organization_id
       AND R.relationship_type_code                 = 'COMPONENT-OF'
       AND trunc(nvl(R.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- cursor to check if the instance is leaf node or not
  CURSOR chk_csi_leaf_node_csr(c_instance_id NUMBER) IS
    SELECT 'X'
      FROM csi_ii_relationships
     WHERE object_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  --Given an relationship_id, get all of its immediate children from MC
  --display_order will determine the sequence of installed and empty sibling nodes
  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- Fetch the mc_header_id.
  -- Fetch the position reference meaning and necessity from fnd_lookups too.
  -- SATHAPLI::Enigma code changes, 02-Sep-2008 - fetch the ata_code as well
  CURSOR get_mc_children(c_relationship_id NUMBER) IS
    SELECT rel.mc_header_id,
           rel.parent_relationship_id parent_rel_id,
           rel.relationship_id,
           rel.display_order,
           rel.ata_code,
           (SELECT fnd.meaning
            FROM   fnd_lookups fnd
            WHERE  fnd.lookup_type                            = 'AHL_POSITION_REFERENCE'
              AND  fnd.lookup_code                            = rel.position_ref_code
              AND  trunc(nvl(fnd.start_date_active, SYSDATE)) <= trunc(SYSDATE)
              AND  trunc(nvl(fnd.end_date_active, SYSDATE+1))  > trunc(SYSDATE)
           ) pos_ref_meaning,
           (SELECT fnd.meaning
            FROM   fnd_lookups fnd
            WHERE  fnd.lookup_type                             = 'AHL_POSITION_NECESSITY'
              AND  fnd.lookup_code                             = rel.position_necessity_code
              AND  trunc(nvl(fnd.start_date_active, SYSDATE)) <= trunc(SYSDATE)
              AND  trunc(nvl(fnd.end_date_active, SYSDATE+1))  > trunc(SYSDATE)
           ) pos_necessity
      FROM ahl_mc_relationships rel
     WHERE rel.parent_relationship_id                  = c_relationship_id
       AND trunc(nvl(rel.active_start_date,SYSDATE))  <= trunc(SYSDATE)
       AND trunc(nvl(rel.active_end_date, SYSDATE+1))  > trunc(SYSDATE)
  ORDER BY display_order;

  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- cursor to check if the position is leaf node or not
  CURSOR chk_mc_leaf_node_csr(c_relationship_id NUMBER) IS
    SELECT 'X'
      FROM ahl_mc_relationships
     WHERE parent_relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  --Given an relationship_id, get all of its descendants from MC
  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- fetch the position reference meaning and necessity from fnd_lookups too
  -- SATHAPLI::Enigma code changes, 02-Sep-2008 - fetch the ata_code as well
  CURSOR get_mc_descendants(c_relationship_id NUMBER) IS
    SELECT rel.parent_relationship_id parent_rel_id,
           rel.relationship_id,
           rel.display_order,
           rel.ata_code,
           (SELECT fnd.meaning
            FROM   fnd_lookups fnd
            WHERE  fnd.lookup_type                            = 'AHL_POSITION_REFERENCE'
              AND  fnd.lookup_code                            = rel.position_ref_code
              AND  trunc(nvl(fnd.start_date_active, SYSDATE)) <= trunc(SYSDATE)
              AND  trunc(nvl(fnd.end_date_active, SYSDATE+1))  > trunc(SYSDATE)
           ) pos_ref_meaning,
           (SELECT fnd.meaning
            FROM   fnd_lookups fnd
            WHERE  fnd.lookup_type                             = 'AHL_POSITION_NECESSITY'
              AND  fnd.lookup_code                             = rel.position_necessity_code
              AND  trunc(nvl(fnd.start_date_active, SYSDATE)) <= trunc(SYSDATE)
              AND  trunc(nvl(fnd.end_date_active, SYSDATE+1))  > trunc(SYSDATE)
           ) pos_necessity
      FROM ahl_mc_relationships rel
START WITH rel.parent_relationship_id                  = c_relationship_id
       AND trunc(nvl(rel.active_start_date,SYSDATE))  <= trunc(SYSDATE)
       AND trunc(nvl(rel.active_end_date, SYSDATE+1))  > trunc(SYSDATE)
CONNECT BY rel.parent_relationship_id                  = PRIOR rel.relationship_id
       AND trunc(nvl(rel.active_start_date,SYSDATE))  <= trunc(SYSDATE)
       AND trunc(nvl(rel.active_end_date, SYSDATE+1))  > trunc(SYSDATE)
    ORDER BY LEVEL, display_order;
-- keyword SIBLINGS is not supported in 8i, so we replace it with level
--  ORDER SIBLINGS BY display_order;


  --Check whether an instance in UC is the top node of a sub UC, if yes, then get the
  --relationship of the sub UC's top node
  CURSOR check_sub_uc(c_instance_id NUMBER) IS
    SELECT A.unit_config_header_id,
           A.master_config_id,
           B.relationship_id
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.csi_item_instance_id = c_instance_id
       AND trunc(nvl(A.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND B.mc_header_id = A.master_config_id
       AND B.parent_relationship_id IS NULL
       AND trunc(nvl(B.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(B.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  -- rbhavsar:: FP Bug# 6268202, performance tuning
  -- check if the MC has sub MCs or not
  CURSOR has_sub_mc_csr(c_relationship_id NUMBER) IS
    SELECT 'X'
      FROM ahl_mc_config_relations
     WHERE relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND rownum = 1;

  -- rbhavsar:: FP Bug# 6268202, performance tuning
  -- Cursor to get the position reference for a given relationship id.
  CURSOR get_pos_ref_csr(c_relationship_id NUMBER) IS
    SELECT fnd.meaning
    FROM   ahl_mc_relationships rel, fnd_lookups fnd
    WHERE  rel.relationship_id                         = c_relationship_id AND
           fnd.lookup_code                             = rel.position_ref_code AND
           fnd.lookup_type                             = 'AHL_POSITION_REFERENCE' AND
           TRUNC(NVL(fnd.start_date_active, SYSDATE)) <= TRUNC(SYSDATE) AND
           TRUNC(NVL(fnd.end_date_active, SYSDATE+1))  > TRUNC(SYSDATE);

  --Based on the UC, list all of the non leaf nodes(including the root node) and the leaf nodes
  --in UC but are non-leaf nodes in MC
-- rbhavsar::FP Bug# 6268202, performance tuning
  CURSOR get_non_leaf_nodes(c_instance_id NUMBER) IS
SELECT  TO_NUMBER(NULL) PARENT_INSTANCE_ID,
        B.CSI_ITEM_INSTANCE_ID INSTANCE_ID,
        A.RELATIONSHIP_ID,
         'I' NODE_TYPE,
        0 OWN_LEVEL
FROM    AHL_UNIT_CONFIG_HEADERS B,
        AHL_MC_RELATIONSHIPS A
WHERE   B.UNIT_CONFIG_HEADER_ID = p_uc_header_id  /*UC header id*/
    AND B.CSI_ITEM_INSTANCE_ID  = c_instance_id  /*root instance id*/
    AND A.MC_HEADER_ID          = B.MASTER_CONFIG_ID
    AND A.PARENT_RELATIONSHIP_ID IS NULL
UNION ALL
SELECT  OBJECT_ID PARENT_INSTANCE_ID,
        SUBJECT_ID INSTANCE_ID,
        TO_NUMBER(POSITION_REFERENCE) RELATIONSHIP_ID,
        DECODE(POSITION_REFERENCE, NULL, 'X', 'I') NODE_TYPE,
        LEVEL OWN_LEVEL
FROM    CSI_II_RELATIONSHIPS A
WHERE   (
         EXISTS (SELECT 'x'
                 FROM    CSI_II_RELATIONSHIPS B
                 WHERE   B.OBJECT_ID                              = A.SUBJECT_ID
                   AND   B.RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
                   AND   TRUNC(NVL(B.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                   AND   TRUNC(NVL(B.ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
               )
        )
        OR
        (
         EXISTS (SELECT 'x'
                 FROM    AHL_MC_RELATIONSHIPS D
                 WHERE   D.PARENT_RELATIONSHIP_ID = TO_NUMBER(A.POSITION_REFERENCE)
                   AND   TRUNC(NVL(D.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                   AND   TRUNC(NVL(D.ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
                )
         OR
         EXISTS (SELECT 'x'
                 FROM    AHL_MC_RELATIONSHIPS D
                 WHERE   D.RELATIONSHIP_ID      = TO_NUMBER(A.POSITION_REFERENCE)
                   AND   EXISTS (SELECT 'x'
                                 FROM    AHL_UNIT_CONFIG_HEADERS E
                                 WHERE   CSI_ITEM_INSTANCE_ID                     = A.SUBJECT_ID
                                   AND   TRUNC(NVL(E.ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
                                )
                   AND   TRUNC(NVL(D.ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
                   AND   TRUNC(NVL(D.ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
                )
        )
START WITH OBJECT_ID                           = c_instance_id  /*root instance id*/
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID
    AND RELATIONSHIP_TYPE_CODE                 = 'COMPONENT-OF'
    AND TRUNC(NVL(ACTIVE_START_DATE,SYSDATE)) <= TRUNC(SYSDATE)
    AND TRUNC(NVL(ACTIVE_END_DATE, SYSDATE+1)) > TRUNC(SYSDATE)
ORDER BY OWN_LEVEL, NODE_TYPE;

  l_get_csi_child get_csi_children%ROWTYPE;
  l_get_mc_child get_mc_children%ROWTYPE;

  --Function to get position_necessity meaning for a given relationship_id
  FUNCTION position_necessity(p_relationship_id NUMBER) RETURN VARCHAR2 IS
    l_pos_necessity_meaning fnd_lookups.meaning%TYPE;
    CURSOR get_position_necessity(c_relationship_id NUMBER) IS
    SELECT F.meaning
      FROM ahl_mc_relationships A,
           fnd_lookup_values_vl F
     WHERE A.relationship_id = c_relationship_id
       AND A.position_necessity_code = F.lookup_code (+)
       AND F.lookup_type (+) = 'AHL_POSITION_NECESSITY';
  BEGIN
    IF p_relationship_id IS NULL THEN
      l_pos_necessity_meaning := NULL;
    ELSE
      OPEN get_position_necessity(p_relationship_id);
      FETCH get_position_necessity INTO l_pos_necessity_meaning;
      IF get_position_necessity%NOTFOUND THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_POSITION_INVALID' );
        FND_MESSAGE.set_token('POSITION', p_relationship_id);
        FND_MSG_PUB.add;
        CLOSE get_position_necessity;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        CLOSE get_position_necessity;
      END IF;
    END IF;
    RETURN l_pos_necessity_meaning;
  END;

  --Function to get instance information(part number plus serial number or
  --instance number for a given instance_id
  FUNCTION part_info(p_instance_id NUMBER) RETURN VARCHAR2 IS
    l_part_info        VARCHAR2(80);
    CURSOR get_part_info(c_instance_id NUMBER) IS
      SELECT M.concatenated_segments||'-'||NVL(C.serial_number, C.instance_number) part_info
        FROM mtl_system_items_kfv M,
             csi_item_instances C
       WHERE C.instance_id = c_instance_id
         AND C.inventory_item_id = M.inventory_item_id
         AND C.inv_master_organization_id = M.organization_id;
  BEGIN
    OPEN get_part_info(p_instance_id);
    FETCH get_part_info INTO l_part_info;
    IF get_part_info%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_INVALID' );
      FND_MESSAGE.set_token('INSTANCE', p_instance_id);
      FND_MSG_PUB.add;
      CLOSE get_part_info;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_part_info;
    END IF;
    RETURN l_part_info;
  END;


BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
  END IF;
  --Validate the input parameter and get the root instance_id and relationship_id
  -- SATHAPLI::Enigma code changes, 02-Sep-2008 - fetch the ata_code as well
  OPEN get_uc_header_attr(p_uc_header_id);
  FETCH get_uc_header_attr INTO l_root_instance_id, l_root_mc_hdr_id, l_root_relationship_id, l_root_ata_code;
  IF get_uc_header_attr%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_HEADER_ID_INVALID' );
    FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE get_uc_header_attr;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE get_uc_header_attr;
  END IF;

  --Initialize l_uc_header_id
  l_uc_header_id := p_uc_header_id;

  --add the root node to the output table
  total_i := 1; --index of the output table
  x_uc_descendant_tbl(total_i).instance_id := l_root_instance_id;
  x_uc_descendant_tbl(total_i).relationship_id := l_root_relationship_id;
  x_uc_descendant_tbl(total_i).parent_instance_id := NULL;
  x_uc_descendant_tbl(total_i).parent_rel_id := NULL;
  x_uc_descendant_tbl(total_i).node_type := 'I';
  x_uc_descendant_tbl(total_i).leaf_node_flag := 'N'; --might be 'Y' very seldomly?
  x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N'; --not applicable for root node

  -- SATHAPLI::Enigma code changes, 02-Sep-2008 - populate the ata_code for the root
  x_uc_descendant_tbl(total_i).ata_code := l_root_ata_code;

  -- rbhavsar::FP Bug# 6268202, performance tuning
  -- API ahl_mc_path_position_pvt.get_posref_for_uc need not be called for root
  -- x_uc_descendant_tbl(total_i).position_reference := ahl_mc_path_position_pvt.get_posref_for_uc(l_uc_header_id, l_root_relationship_id);
  OPEN get_pos_ref_csr(l_root_relationship_id);
  FETCH get_pos_ref_csr INTO l_pos_ref;
  CLOSE get_pos_ref_csr;
  x_uc_descendant_tbl(total_i).position_reference := l_pos_ref;

  --Even if p_uc_header_id is a subunit(installed or extra), when displaying its own tree, we pass its own
  --p_uc_header_id instead of its parent_uc_header_id
  x_uc_descendant_tbl(total_i).position_necessity := position_necessity(l_root_relationship_id);
  x_uc_descendant_tbl(total_i).part_info := part_info(l_root_instance_id);
  total_i := total_i + 1;

  --Loop through all of the non leaf nodes of the UC tree, including the root node and extra node
  FOR l_non_leaf_node IN get_non_leaf_nodes(l_root_instance_id) LOOP

    --dbms_output.put_line('rel_id='||l_non_leaf_node.relationship_id||' uc_instance='||l_root_instance_id);
    IF (l_non_leaf_node.relationship_id IS NOT NULL AND
        NOT ahl_util_uc_pkg.extra_node(l_non_leaf_node.instance_id, l_root_instance_id)) THEN

      --If the UC instance happens to be the top node of a sub UC, then when getting the
      --MC descendants, the sub UC top node's relationship_id(got from uc headers table)
      --instead of the relationship_id(got from position_reference in csi_ii_relationships)
      --should be used. For UC root instance, the following cursor is also applicable.
      OPEN check_sub_uc(l_non_leaf_node.instance_id);
      FETCH check_sub_uc INTO l_uc_header_id, l_mc_header_id, l_relationship_id;

      IF check_sub_uc%NOTFOUND THEN --not a sub UC's top node
        l_relationship_id := l_non_leaf_node.relationship_id;
        ahl_util_uc_pkg.get_parent_uc_header(l_non_leaf_node.instance_id, l_uc_header_id, l_dummy_num);

        IF l_uc_header_id IS NULL THEN
          l_uc_header_id := p_uc_header_id;
        END IF;
      END IF;
      CLOSE check_sub_uc;

      --Get all the immediate children of the corresponding UC node

      --This is used to reset the l_uc_children_tbl and it is required, otherwise the elements
      --left in the previous loop especially when the previous loop has more elements than the
      --current loop, then these elements belonging to the previous loop will be inherited to
      --the current loop.
      -- rbhavsar::FP Bug# 6268202, performance tuning
      -- use PL/SQL tables for BULK COLLECT instead of looping through the cursor records
      /*
      IF l_uc_children_tbl.COUNT > 0 THEN
        l_uc_children_tbl.DELETE;
      END IF;


      i_uc_child := 0;
      FOR l_get_csi_child IN get_csi_children(l_non_leaf_node.instance_id) LOOP
        i_uc_child := i_uc_child + 1;
        l_uc_children_tbl(i_uc_child).instance_id := l_get_csi_child.instance_id;
        l_uc_children_tbl(i_uc_child).relationship_id := l_get_csi_child.relationship_id;
        l_uc_children_tbl(i_uc_child).matched_flag := 'N'; -- default to 'N'
      END LOOP;
      */

      IF l_child_inst_tbl.COUNT > 0 THEN
        l_child_inst_tbl.DELETE;
        l_child_rel_tbl.DELETE;
        l_child_matchflag_tbl.DELETE;
        l_child_partinfo_tbl.DELETE;
      END IF;

      OPEN get_csi_children(l_non_leaf_node.instance_id);
      FETCH get_csi_children BULK COLLECT INTO l_child_inst_tbl,
                                               l_child_rel_tbl,
                                               l_child_partinfo_tbl,
                                               l_child_matchflag_tbl;
      CLOSE get_csi_children;

      --Loop through all the immediate children of the MC node
      FOR l_get_mc_child IN get_mc_children(l_relationship_id) LOOP
        l_matched := FALSE;
        IF l_child_inst_tbl.COUNT > 0 THEN
          FOR i IN l_child_inst_tbl.FIRST..l_child_inst_tbl.LAST LOOP
            IF (l_child_matchflag_tbl(i) = 'N' AND
                l_get_mc_child.relationship_id = l_child_rel_tbl(i)) THEN
              --Add these installed nodes to the output table
              x_uc_descendant_tbl(total_i).instance_id := l_child_inst_tbl(i);
              x_uc_descendant_tbl(total_i).relationship_id := l_child_rel_tbl(i);
              x_uc_descendant_tbl(total_i).parent_instance_id := l_non_leaf_node.instance_id;
              x_uc_descendant_tbl(total_i).parent_rel_id := l_non_leaf_node.relationship_id;
              x_uc_descendant_tbl(total_i).node_type := 'I';

              -- SATHAPLI::Enigma code changes, 02-Sep-2008 - populate the ata_code for the non-extra node
              x_uc_descendant_tbl(total_i).ata_code := l_get_mc_child.ata_code;

              -- rbhavsar::FP Bug# 6268202, performance tuning
              -- API ahl_mc_path_position_pvt.get_posref_for_uc need not be called if
              -- this relationship belongs to the root MC.
              IF (l_get_mc_child.mc_header_id = l_root_mc_hdr_id) THEN
                x_uc_descendant_tbl(total_i).position_reference := l_get_mc_child.pos_ref_meaning;
              ELSE
                x_uc_descendant_tbl(total_i).position_reference :=
                ahl_mc_path_position_pvt.get_posref_for_uc(l_uc_header_id, l_child_rel_tbl(i));
              END IF;

              x_uc_descendant_tbl(total_i).position_necessity := l_get_mc_child.pos_necessity;
              x_uc_descendant_tbl(total_i).part_info := l_child_partinfo_tbl(i);

              --Leaf_node_flag is for front end display purpose, so we have to
              --First check to see wether this installed node is a leaf node in CSI, if it is
              --then we need to check whether the corresponding relationship_id is a leaf node
              --in MC. Again we need to check whether this installed node happens to be a sub UC top node.
              OPEN check_sub_uc(x_uc_descendant_tbl(total_i).instance_id);
              FETCH check_sub_uc INTO l_dummy_num, l_mc_header_id, l_relationship_id;
              IF check_sub_uc%NOTFOUND THEN --not a sub UC's top node
                l_relationship_id := x_uc_descendant_tbl(total_i).relationship_id;
                x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N';
              ELSE
                x_uc_descendant_tbl(total_i).has_subconfig_flag := 'Y';
              END IF;
              CLOSE check_sub_uc;

              -- rbhavsar::FP Bug# 6268202, performance tuning
              OPEN chk_csi_leaf_node_csr(x_uc_descendant_tbl(total_i).instance_id);
              FETCH chk_csi_leaf_node_csr INTO l_dummy;
              IF chk_csi_leaf_node_csr%FOUND THEN
                x_uc_descendant_tbl(total_i).leaf_node_flag := 'N';
              ELSE
                -- check from the MC
                OPEN chk_mc_leaf_node_csr(l_relationship_id);
                FETCH chk_mc_leaf_node_csr INTO l_dummy;
                IF chk_mc_leaf_node_csr%FOUND THEN
                  x_uc_descendant_tbl(total_i).leaf_node_flag := 'N';
                ELSE
                  x_uc_descendant_tbl(total_i).leaf_node_flag := 'Y';
                END IF;
                CLOSE chk_mc_leaf_node_csr;
              END IF;
              CLOSE chk_csi_leaf_node_csr;

              total_i := total_i + 1;
              l_matched := TRUE;
              l_child_matchflag_tbl(i) := 'Y';
              EXIT;
            END IF; --whether relationship_id match condition
          END LOOP; --l_uc_children_tbl
        END IF; --whether table l_uc_children_tbl is empty

        --dbms_output.put_line('Not installed node...');
        IF NOT l_matched THEN -- empty node
        --Add this empty node and all of its descendants to the output table
        --dbms_output.put_line('i='||to_char(i)||':l_mc_children_table(i).installed_flag='||l_mc_children_tbl(i).installed_flag);
          x_uc_descendant_tbl(total_i).instance_id := NULL;
          x_uc_descendant_tbl(total_i).relationship_id := l_get_mc_child.relationship_id;
          x_uc_descendant_tbl(total_i).parent_instance_id := l_non_leaf_node.instance_id;
          x_uc_descendant_tbl(total_i).parent_rel_id := l_non_leaf_node.relationship_id;
          x_uc_descendant_tbl(total_i).node_type := 'E';

          -- SATHAPLI::Enigma code changes, 02-Sep-2008 - populate the ata_code for the non-extra node
          x_uc_descendant_tbl(total_i).ata_code := l_get_mc_child.ata_code;

          -- rbhavsar::FP Bug# 6268202, performance tuning
          -- API ahl_mc_path_position_pvt.get_posref_for_uc need not be called if
          -- this relationship belongs to the root MC.
          IF (l_get_mc_child.mc_header_id = l_root_mc_hdr_id) THEN
            l_root_mc_part := TRUE;
            x_uc_descendant_tbl(total_i).position_reference := l_get_mc_child.pos_ref_meaning;
          ELSE
            l_root_mc_part := FALSE;
            x_uc_descendant_tbl(total_i).position_reference :=
            ahl_mc_path_position_pvt.get_posref_for_uc(l_uc_header_id, l_get_mc_child.relationship_id);
          END IF;

          x_uc_descendant_tbl(total_i).position_necessity := l_get_mc_child.pos_necessity;
          x_uc_descendant_tbl(total_i).part_info := NULL;

          -- rbhavsar::FP Bug# 6268202, performance tuning
          OPEN chk_mc_leaf_node_csr(x_uc_descendant_tbl(total_i).relationship_id);
          FETCH chk_mc_leaf_node_csr INTO l_dummy;
          IF chk_mc_leaf_node_csr%FOUND THEN
            x_uc_descendant_tbl(total_i).leaf_node_flag := 'N';
          ELSE
            x_uc_descendant_tbl(total_i).leaf_node_flag := 'Y';
          END IF;
          CLOSE chk_mc_leaf_node_csr;

          OPEN has_sub_mc_csr(x_uc_descendant_tbl(total_i).relationship_id);
          FETCH has_sub_mc_csr INTO l_dummy;
          IF has_sub_mc_csr%FOUND THEN
            x_uc_descendant_tbl(total_i).has_subconfig_flag := 'Y';
          ELSE
            x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N';
          END IF;
          CLOSE has_sub_mc_csr;

          total_i := total_i + 1;
          FOR l_get_mc_descendant IN get_mc_descendants(l_get_mc_child.relationship_id) LOOP
            x_uc_descendant_tbl(total_i).instance_id := NULL;
            x_uc_descendant_tbl(total_i).relationship_id := l_get_mc_descendant.relationship_id;

            --Changed on 02/04/2004 per Cheng's requirement. Actually using parent_instance_id to
            --represent the lowest ancestor instance for the empty node
            x_uc_descendant_tbl(total_i).parent_instance_id := l_non_leaf_node.instance_id;
            --x_uc_descendant_tbl(total_i).parent_instance_id := NULL;

            x_uc_descendant_tbl(total_i).parent_rel_id := l_get_mc_descendant.parent_rel_id;
            x_uc_descendant_tbl(total_i).node_type := 'E';

            -- SATHAPLI::Enigma code changes, 02-Sep-2008 - populate the ata_code for the non-extra node
            x_uc_descendant_tbl(total_i).ata_code := l_get_mc_descendant.ata_code;

            -- rbhavsar::FP Bug# 6268202, performance tuning
            -- API ahl_mc_path_position_pvt.get_posref_for_uc need not be called if
            -- the ancestor relationship belongs to the root MC.
            IF (l_root_mc_part) THEN
              x_uc_descendant_tbl(total_i).position_reference := l_get_mc_descendant.pos_ref_meaning;
            ELSE
              x_uc_descendant_tbl(total_i).position_reference :=
              ahl_mc_path_position_pvt.get_posref_for_uc(l_uc_header_id, l_get_mc_descendant.relationship_id);
            END IF;

            x_uc_descendant_tbl(total_i).position_necessity := l_get_mc_descendant.pos_necessity;
            x_uc_descendant_tbl(total_i).part_info := NULL;

            -- rbhavsar::FP Bug# 6268202, performance tuning
            OPEN chk_mc_leaf_node_csr(x_uc_descendant_tbl(total_i).relationship_id);
            FETCH chk_mc_leaf_node_csr INTO l_dummy;
            IF chk_mc_leaf_node_csr%FOUND THEN
              x_uc_descendant_tbl(total_i).leaf_node_flag := 'N';
              x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N';
            ELSE
              x_uc_descendant_tbl(total_i).leaf_node_flag := 'Y';
              --Only if it is empty leaf node in MC then it is necessary to check whether there
              --are some sub MCs can be associated to this node
              OPEN has_sub_mc_csr(x_uc_descendant_tbl(total_i).relationship_id);
              FETCH has_sub_mc_csr INTO l_dummy;
              IF has_sub_mc_csr%FOUND THEN
                x_uc_descendant_tbl(total_i).has_subconfig_flag := 'Y';
              ELSE
                x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N';
              END IF;
              CLOSE has_sub_mc_csr;
            END IF;
            CLOSE chk_mc_leaf_node_csr;

            total_i := total_i + 1;
          END LOOP; --loop of get_mc_descendants
        END IF; --l_matched condition
      END LOOP; --loop of get_mc_children

      --dbms_output.put_line('After empty node...');
      --Check each instance in the temporary UC children table, if it is not matched,
      --then it is an extra node. Add this extra node's immediate children to the output table
      IF l_child_inst_tbl.COUNT > 0 THEN
        FOR i IN l_child_inst_tbl.FIRST..l_child_inst_tbl.LAST LOOP
          IF l_child_matchflag_tbl(i) = 'N' THEN
            x_uc_descendant_tbl(total_i).instance_id := l_child_inst_tbl(i);
            x_uc_descendant_tbl(total_i).relationship_id := l_child_rel_tbl(i);
            x_uc_descendant_tbl(total_i).parent_instance_id := l_non_leaf_node.instance_id;
            x_uc_descendant_tbl(total_i).parent_rel_id := l_non_leaf_node.relationship_id;
            x_uc_descendant_tbl(total_i).node_type := 'X';
            x_uc_descendant_tbl(total_i).position_reference := NULL;
            --  ahl_mc_path_position_pvt.get_posref_for_uc(l_uc_header_id, l_uc_children_tbl(i).relationship_id);
            x_uc_descendant_tbl(total_i).position_necessity := NULL;
            x_uc_descendant_tbl(total_i).part_info := l_child_partinfo_tbl(i);

            -- rbhavsar::FP Bug# 6268202, performance tuning
            OPEN chk_csi_leaf_node_csr(x_uc_descendant_tbl(total_i).instance_id);
            FETCH chk_csi_leaf_node_csr INTO l_dummy;
            IF chk_csi_leaf_node_csr%FOUND THEN
              x_uc_descendant_tbl(total_i).leaf_node_flag := 'N';
            ELSE
              x_uc_descendant_tbl(total_i).leaf_node_flag := 'Y';
            END IF;
            CLOSE chk_csi_leaf_node_csr;

            OPEN check_sub_uc(x_uc_descendant_tbl(total_i).instance_id);
            FETCH check_sub_uc INTO l_uc_header_id, l_mc_header_id, l_relationship_id;
            IF check_sub_uc%NOTFOUND THEN --not a sub UC's top node
              x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N';
            ELSE
              x_uc_descendant_tbl(total_i).has_subconfig_flag := 'Y';
            END IF;
            CLOSE check_sub_uc;

            total_i := total_i + 1;
          END IF; --matched_flag condition
        END LOOP; --loop of l_uc_children_tbl
      END IF; --whether table l_uc_children_tbl is empty

    ELSE --an extra node in all non leaf nodes
      --add this node's immediate children instead of itself into the output table,
      --because this node has already been added into the output table when processing its
      --parent node.
      FOR l_get_csi_child IN get_csi_children(l_non_leaf_node.instance_id) LOOP
        x_uc_descendant_tbl(total_i).node_type := 'X';
        x_uc_descendant_tbl(total_i).instance_id := l_get_csi_child.instance_id;
        x_uc_descendant_tbl(total_i).relationship_id := l_get_csi_child.relationship_id;
        x_uc_descendant_tbl(total_i).parent_instance_id := l_non_leaf_node.instance_id;
        x_uc_descendant_tbl(total_i).parent_rel_id := NULL;
        x_uc_descendant_tbl(total_i).position_reference := NULL;
        --  ahl_mc_path_position_pvt.get_posref_for_uc(l_uc_header_id, l_get_csi_child.relationship_id);
        x_uc_descendant_tbl(total_i).position_necessity := NULL;
        x_uc_descendant_tbl(total_i).part_info := l_get_csi_child.part_info;

        -- rbhavsar::FP Bug# 6268202, performance tuning
        OPEN chk_csi_leaf_node_csr(x_uc_descendant_tbl(total_i).instance_id);
        FETCH chk_csi_leaf_node_csr INTO l_dummy;
        IF chk_csi_leaf_node_csr%FOUND THEN
          x_uc_descendant_tbl(total_i).leaf_node_flag := 'N';
        ELSE
          x_uc_descendant_tbl(total_i).leaf_node_flag := 'Y';
        END IF;
        CLOSE chk_csi_leaf_node_csr;

        OPEN check_sub_uc(x_uc_descendant_tbl(total_i).instance_id);
        FETCH check_sub_uc INTO l_uc_header_id, l_mc_header_id, l_relationship_id;
        IF check_sub_uc%NOTFOUND THEN --not a sub UC's top node
          x_uc_descendant_tbl(total_i).has_subconfig_flag := 'N';
        ELSE
          x_uc_descendant_tbl(total_i).has_subconfig_flag := 'Y';
        END IF;
        CLOSE check_sub_uc;

        total_i := total_i + 1;
      END LOOP;
    END IF; --whether l_non_leaf_node is extra node
  END LOOP; --loop of get_non_leaf_nodes

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution',
			       'At the end of the procedure');
  END IF;
  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Define Procedure migrate_uc_tree --
-- This API is used to migrate a UC tree to a new MC revision or copy
PROCEDURE migrate_uc_tree(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_mc_header_id          IN  NUMBER)
IS
  TYPE l_mc_children_rec_type IS RECORD(
    relationship_id           NUMBER,
    position_key              NUMBER,
    position_ref_code         VARCHAR2(30),
    item_group_id             NUMBER,
    matched_flag              VARCHAR2(1));
  TYPE l_mc_children_tbl_type IS TABLE OF l_mc_children_rec_type INDEX BY BINARY_INTEGER;
  l_mc_children_tbl           l_mc_children_tbl_type;
  l_api_name       CONSTANT   VARCHAR2(30)   := 'migrate_uc_tree';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_evaluation_status         VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_relationship_id           NUMBER;
  l_mc_header_id              NUMBER;
  l_mc_name                   ahl_mc_headers_b.name%TYPE;
  l_mc_revision               ahl_mc_headers_b.revision%TYPE;
  l_mc_status_code            FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_instance_id          NUMBER;
  l_root_relationship_id      NUMBER;
  l_mc_top_rel_id             NUMBER;
  l_parent_uc_header_id       NUMBER;
  l_parent_instance_id        NUMBER;
  l_sub_top_rel_id            NUMBER;
  l_sub_mc_header_id          NUMBER;
  l_boolean_var               BOOLEAN;
  l_dummy                     NUMBER;
  i                           NUMBER;
  i_mc_child                  NUMBER;
  l_item_match                BOOLEAN;
  l_matched                   BOOLEAN;
  l_return_value              BOOLEAN;
  l_transaction_type_id       NUMBER;
  l_version_no                NUMBER;
  l_uc_header_all  ahl_unit_config_headers%ROWTYPE;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_root_uc_header_id         NUMBER;
  l_root_uc_status_code       FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_active_uc_status_code FND_LOOKUP_VALUES.lookup_code%TYPE;
  l_root_uc_ovn               NUMBER;
  l_new_relationship_id       NUMBER;
  --In order to check whether the instance belongs to a sub unit or an extra node branch
  CURSOR check_subuc_extra(c_instance_id NUMBER, c_top_instance_id NUMBER) IS
    SELECT object_id, subject_id, position_reference
      FROM csi_ii_relationships
     WHERE subject_id IN (SELECT csi_item_instance_id
                            FROM ahl_unit_config_headers
                           WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
        OR position_reference IS NULL
START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND subject_id <> c_top_instance_id;
  l_check_subuc_extra    check_subuc_extra%ROWTYPE;
  --Check the given uc_heder_id is existing and if yes, get its status and other information
  CURSOR check_uc_header IS
    SELECT U.unit_config_status_code uc_status_code,
           U.active_uc_status_code,
           U.csi_item_instance_id instance_id,
           U.master_config_id mc_header_id,
           U.object_version_number,
           C.inventory_item_id inventory_item_id,
           C.inv_master_organization_id inventory_org_id,
           C.inventory_revision,
           C.quantity,
           C.unit_of_measure
      FROM ahl_unit_config_headers U,
           csi_item_instances C
     WHERE U.unit_config_header_id = p_uc_header_id
       AND trunc(nvl(U.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND U.csi_item_instance_id = C.instance_id;
  l_uc_header_attr check_uc_header%ROWTYPE;
  CURSOR check_mc_header IS
    SELECT H.mc_header_id,
           H.config_status_code,
           R.relationship_id,
           H.name,
           H.revision
      FROM ahl_mc_headers_b H,
           ahl_mc_relationships R
     WHERE H.mc_header_id = p_mc_header_id
       AND R.mc_header_id = H.mc_header_id
       AND R.parent_relationship_id IS NULL
       AND trunc(nvl(R.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_mc_header_items(c_mc_header_id NUMBER) IS
    SELECT M.relationship_id,
           I.inventory_item_id,
           I.inventory_org_id
      FROM ahl_mc_relationships M,
           ahl_item_associations_b I
     WHERE M.mc_header_id = c_mc_header_id
       AND M.parent_relationship_id IS NULL
       AND M.item_group_id = I.item_group_id;
  /*
  CURSOR get_associated_items(c_item_group_id NUMBER) IS
    SELECT inventory_item_id,
           inventory_org_id
      FROM ahl_item_associations_b
     WHERE item_group_id = c_item_group_id;
  l_get_associated_item        get_associated_items%ROWTYPE;
  */

  --Given an instance_id, get all of its immediate children from csi_ii_relationships
  CURSOR get_csi_children(c_instance_id NUMBER) IS
    SELECT C.relationship_id csi_ii_relationship_id,
           C.object_version_number csi_ii_relationship_ovn,
           C.object_id parent_instance_id,
           C.subject_id instance_id,
           to_number(C.position_reference) relationship_id,
           M.position_key,
           M.position_ref_code,
           I.inventory_item_id,
           I.inv_master_organization_id inventory_org_id,
           I.inventory_revision,
           I.quantity,
           I.unit_of_measure
      FROM csi_ii_relationships C,
           ahl_mc_relationships M,
           csi_item_instances I
     WHERE to_number(C.position_reference) = M.relationship_id (+)
       AND C.subject_id = I.instance_id
       AND C.object_id = c_instance_id
       AND C.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(C.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Given an relationship_id, get all of its immediate children from MC
  CURSOR get_mc_children(c_relationship_id NUMBER) IS
    SELECT parent_relationship_id parent_rel_id,
           relationship_id,
           position_key,
           position_ref_code,
           item_group_id
      FROM ahl_mc_relationships
     WHERE parent_relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Check whether an instance in UC is the top node of a sub UC, if yes, then get the
  --relationship of the sub UC's top node
  CURSOR check_sub_uc(c_instance_id NUMBER) IS
    SELECT A.master_config_id mc_header_id,
           B.relationship_id
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.csi_item_instance_id = c_instance_id
       AND trunc(nvl(A.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND B.mc_header_id = A.master_config_id
       AND B.parent_relationship_id IS NULL
       AND trunc(nvl(B.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(B.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_sub_uc        check_sub_uc%ROWTYPE;
  --Given a position(leaf) in MC, get all the sub MCs which can be associated to this position
  CURSOR get_sub_mcs(c_relationship_id NUMBER) IS
    SELECT mc_header_id
      FROM ahl_mc_config_relations
     WHERE relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Based on the UC, list all of the non leaf nodes including the root node
  CURSOR get_non_leaf_nodes(c_instance_id NUMBER) IS
    SELECT TO_NUMBER(NULL) parent_instance_id, --just include the root uc node
           B.csi_item_instance_id instance_id,
           A.relationship_id
      FROM ahl_unit_config_headers B,
           ahl_mc_relationships A
     WHERE B.csi_item_instance_id = c_instance_id
       AND trunc(nvl(B.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND A.mc_header_id = B.master_config_id
       AND A.parent_relationship_id IS NULL
     UNION ALL
    SELECT object_id parent_instance_id,
           subject_id instance_id,
           to_number(position_reference) relationship_id
      FROM csi_ii_relationships A
      --remove all of the leaf node after finishing the hierarchical query
     WHERE EXISTS (SELECT 'x'
                     FROM csi_ii_relationships B
                    WHERE B.object_id = A.subject_id
                      AND relationship_type_code = 'COMPONENT-OF'
                      AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
                      AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH object_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_position_reference(c_object_id NUMBER, c_subject_id NUMBER) IS
    SELECT relationship_id csi_ii_relationship_id,
           object_version_number csi_ii_relationship_ovn,
           to_number(position_reference) relationship_id
      FROM csi_ii_relationships
     WHERE object_id = c_object_id
       AND subject_id = c_subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_position_info              get_position_reference%ROWTYPE;

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT migrate_uc_tree;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
  END IF;

  --Validate the input parameter p_uc_header_id and its status
  --Validate input parameter p_uc_header_id, its two status
  OPEN check_uc_header;
  FETCH check_uc_header INTO l_uc_header_attr;
  IF check_uc_header%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_uc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    -- ACL :: Changes for R12
    IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ahl_util_uc_pkg.get_root_uc_attr(p_uc_header_id,
                                     l_root_uc_header_id,
                                     l_root_instance_id,
                                     l_root_uc_status_code,
                                     l_root_active_uc_status_code,
                                     l_root_uc_ovn);
    IF (l_root_uc_status_code = 'APPROVAL_PENDING' OR
        l_root_active_uc_status_code = 'APPROVAL_PENDING') THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_STATUS_PENDING' );
      FND_MESSAGE.set_token('UC_HEADER_ID', l_root_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE check_uc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_uc_header;
    END IF;
  END IF;

  --Validate the input parameter p_mc_header_id and get its status
  OPEN check_mc_header;
  FETCH check_mc_header INTO l_mc_header_id,
                             l_mc_status_code,
                             l_mc_top_rel_id,
                             l_mc_name,
                             l_mc_revision;
  IF check_mc_header%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'mc_header_id');
    FND_MESSAGE.set_token('VALUE', p_mc_header_id);
    FND_MSG_PUB.add;
    CLOSE check_mc_header;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    IF l_mc_status_code <> 'COMPLETE' THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_MC_NOT_COMPLETE' );
      FND_MESSAGE.set_token('NAME', l_mc_name);
      FND_MESSAGE.set_token('REVISION', l_mc_revision);
      FND_MSG_PUB.add;
      CLOSE check_mc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_mc_header_id = l_uc_header_attr.mc_header_id THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_MC_MIGRATE_SAME' );
      FND_MESSAGE.set_token('NAME', l_mc_name);
      FND_MESSAGE.set_token('REVISION', l_mc_revision);
      FND_MSG_PUB.add;
      CLOSE check_mc_header;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE check_mc_header;
    END IF;
  END IF;

  --The following lines are used to update the position_reference column in csi_ii_relationships
  --First, get transaction_type_id .
  AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_value);
  IF NOT l_return_value THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --For UC root node, only need to ensure item matches, no need to check position key
  --and position_reference
  IF p_uc_header_id = l_root_uc_header_id THEN
    --Standalone UC or UC installed in a CSI instance, only need to check whether
    --item match for the top node
    l_item_match := AHL_UTIL_UC_PKG.item_match(l_mc_top_rel_id,
                             l_uc_header_attr.inventory_item_id,
                             l_uc_header_attr.inventory_org_id,
                             l_uc_header_attr.inventory_revision,
                             l_uc_header_attr.quantity,
                             l_uc_header_attr.unit_of_measure);
    IF NOT l_item_match THEN
      --dbms_output.put_line('l_root_uc_header_id='||l_root_uc_header_id||' l_mc_top_rel_id='||l_mc_top_rel_id);
      --dbms_output.put_line('inventory_item_id='||l_uc_header_attr.inventory_item_id||' inventory_org_id='||l_uc_header_attr.inventory_org_id);
      --dbms_output.put_line('revision='||l_uc_header_attr.inventory_revision||' quantity='||l_uc_header_attr.quantity);
      --dbms_output.put_line('uom='||l_uc_header_attr.unit_of_measure);
      FND_MESSAGE.set_name( 'AHL','AHL_UC_HEADER_NOT_MATCH' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
    --Item matches, can be migrated and thus change the mc_header_id of the UC header
      NULL;
    END IF;
  ELSIF (p_uc_header_id <> l_root_uc_header_id) THEN
    --Sub unit installed on another unit, either extra node or non extra node
    ahl_util_uc_pkg.get_parent_uc_header(l_uc_header_attr.instance_id,
                                         l_parent_uc_header_id,
                                         l_parent_instance_id);
    --Get its parent_instance_id in order to check whether it is an extra node within
    --the context of its parent UC
    IF NOT ahl_util_uc_pkg.extra_node(l_uc_header_attr.instance_id, l_parent_instance_id) THEN
    --Non extra sub unit within the context of its parent unit
    --Get its position_reference
      OPEN get_position_reference(l_parent_instance_id, l_uc_header_attr.instance_id);
      FETCH get_position_reference INTO l_position_info;
      IF get_position_reference%NOTFOUND THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_UNIT_UNINSTALLED' );
        FND_MESSAGE.set_token('CHILD',l_uc_header_attr.instance_id);
        FND_MESSAGE.set_token('PARENT',l_parent_instance_id);
        FND_MSG_PUB.add;
        CLOSE get_position_reference;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE get_position_reference;
      --Check whether the new mc_header_id to which to be migrated could be an alternate sub MC
      --in position
      l_boolean_var := FALSE;
      FOR l_get_sub_mcs IN get_sub_mcs(l_position_info.relationship_id) LOOP
        l_sub_mc_header_id := l_get_sub_mcs.mc_header_id;
        IF l_sub_mc_header_id = p_mc_header_id THEN
          l_boolean_var := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF NOT l_boolean_var THEN
      --Again check whether item match
        l_item_match := AHL_UTIL_UC_PKG.item_match(l_mc_top_rel_id,
                             l_uc_header_attr.inventory_item_id,
                             l_uc_header_attr.inventory_org_id,
                             l_uc_header_attr.inventory_revision,
                             l_uc_header_attr.quantity,
                             l_uc_header_attr.unit_of_measure);
        IF NOT l_item_match THEN
          FND_MESSAGE.set_name( 'AHL','AHL_UC_HEADER_NOT_MATCH' );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          --Make the sub unit an extra node in its parent unit context and
          --update its own mc_header_id to the new p_mc_header_id

          --Set the CSI transaction record
          l_csi_transaction_rec.source_transaction_date := SYSDATE;
          l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
          --Set CSI relationship record
          l_csi_relationship_rec.relationship_id := l_position_info.csi_ii_relationship_id;
          l_csi_relationship_rec.object_version_number := l_position_info.csi_ii_relationship_ovn;
          l_csi_relationship_rec.position_reference := NULL;
          l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
          l_csi_relationship_rec.object_id := l_parent_instance_id;
          l_csi_relationship_rec.subject_id := l_uc_header_attr.instance_id;
          l_csi_relationship_tbl(1) := l_csi_relationship_rec;
          CSI_II_RELATIONSHIPS_PUB.update_relationship(
                                   p_api_version      => 1.0,
                                   p_relationship_tbl => l_csi_relationship_tbl,
                                   p_txn_rec          => l_csi_transaction_rec,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data);
          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          --Could be migrated and thus change the mc_header_id of the UC header
          NULL;
        END IF;
      ELSE
        --The sub unit is still an alternate sub unit so only need to update
        --its own mc_header_id to the new p_mc_header_id
        NULL;
      END IF;
    ELSE
    --Extra node and check whether item match
      l_item_match := AHL_UTIL_UC_PKG.item_match(l_mc_top_rel_id,
                             l_uc_header_attr.inventory_item_id,
                             l_uc_header_attr.inventory_org_id,
                             l_uc_header_attr.inventory_revision,
                             l_uc_header_attr.quantity,
                             l_uc_header_attr.unit_of_measure);
      IF NOT l_item_match THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_HEADER_NOT_MATCH' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
      --Could be migrated but will be still extra node to its parent unit
      --Not necessary to update position_reference to NULL because it is already an
      --extra node to its parent unit
        NULL;
      END IF;
    END IF;
  END IF;
  --Update the master_config_id of p_uc_header_id to the new p_mc_header_id
  IF p_uc_header_id = l_root_uc_header_id THEN
  --For standalone no object_version_number change here because we have to update the
  --status for the same record after migration
    UPDATE ahl_unit_config_headers
       SET master_config_id = p_mc_header_id,
           last_updated_by = fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id
     WHERE unit_config_header_id = p_uc_header_id
       AND object_version_number = l_uc_header_attr.object_version_number;
  ELSE
    UPDATE ahl_unit_config_headers
       SET master_config_id = p_mc_header_id,
           object_version_number = object_version_number + 1,
           last_updated_by = fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id
     WHERE unit_config_header_id = p_uc_header_id
       AND object_version_number = l_uc_header_attr.object_version_number;
  END IF;
  IF SQL%ROWCOUNT = 0 THEN
    FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Copy the change to UC history table
  ahl_util_uc_pkg.copy_uc_header_to_history(p_uc_header_id, l_return_status);
  --IF history copy failed, then don't raise exception, just add the messageto the message stack
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
    FND_MSG_PUB.add;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||':Within API',
			       'After updating the master_config_id');
  END IF;

  --Loop through all the non leaf nodes including the root node
  FOR l_get_non_leaf_node IN get_non_leaf_nodes(l_uc_header_attr.instance_id) LOOP
    --Make sure the node doesn't belong to a sub unit or extra node branch, because for
    --all the nodes in the sub unit or extra node branch including the top most extra node
    --it is not necessary to process them and the sub unit top node is processed in the loop
    --of its parent node
    OPEN check_subuc_extra(l_get_non_leaf_node.instance_id, l_uc_header_attr.instance_id);
    FETCH check_subuc_extra INTO l_check_subuc_extra;
    IF check_subuc_extra%NOTFOUND THEN
      --Get all the immediate children of the corresponding MC node
      --First get the non leaf node's new relationship_id to which it has been migrated
      --This is a bug fix found by Barry on Nov 6, 2003
      IF l_uc_header_attr.instance_id = l_get_non_leaf_node.instance_id THEN
        l_new_relationship_id := l_get_non_leaf_node.relationship_id;
      ELSE
        SELECT to_number(position_reference) into l_new_relationship_id
          FROM csi_ii_relationships
         WHERE subject_id = l_get_non_leaf_node.instance_id
           AND relationship_type_code='COMPONENT-OF'
           AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
           AND trunc(nvl(active_end_date, sysdate+1)) > trunc(sysdate);
      END IF;

      i_mc_child := 1;
      FOR l_get_mc_child IN get_mc_children(l_new_relationship_id) LOOP
        l_mc_children_tbl(i_mc_child).relationship_id := l_get_mc_child.relationship_id;
        l_mc_children_tbl(i_mc_child).position_key := l_get_mc_child.position_key;
        l_mc_children_tbl(i_mc_child).position_ref_code := l_get_mc_child.position_ref_code;
        l_mc_children_tbl(i_mc_child).item_group_id := l_get_mc_child.item_group_id;
        l_mc_children_tbl(i_mc_child).matched_flag := 'N'; -- default to 'N'
        i_mc_child := i_mc_child + 1;
      END LOOP;
      FOR l_get_csi_child IN get_csi_children(l_get_non_leaf_node.instance_id) LOOP
        --No processing for the extra node
        IF l_get_csi_child.relationship_id IS NOT NULL THEN
          l_matched := FALSE;
          l_relationship_id := NULL;
          IF l_mc_children_tbl.COUNT > 0 THEN
          <<OUTER>>
          FOR i IN l_mc_children_tbl.FIRST..l_mc_children_tbl.LAST LOOP
            IF l_mc_children_tbl(i).matched_flag <> 'Y' THEN
              IF l_get_csi_child.position_key = l_mc_children_tbl(i).position_key OR
                 l_get_csi_child.position_ref_code = l_mc_children_tbl(i).position_ref_code THEN
                --Check whether this node is a sub unit top node, if YES compare the sub
                --mc_header_id, otherwise compare item
                OPEN check_sub_uc(l_get_csi_child.instance_id);
                FETCH check_sub_uc INTO l_check_sub_uc;
                IF check_sub_uc%FOUND THEN
                  FOR l_get_sub_mc IN get_sub_mcs(l_mc_children_tbl(i).relationship_id) LOOP
                    IF l_check_sub_uc.mc_header_id = l_get_sub_mc.mc_header_id THEN
                      l_matched := TRUE;
                      l_mc_children_tbl(i).matched_flag := 'Y';
                      l_relationship_id := l_mc_children_tbl(i).relationship_id;
                      CLOSE check_sub_uc;
                      EXIT OUTER;
                    END IF;
                  END LOOP;
                ELSE
                  l_matched := AHL_UTIL_UC_PKG.item_match(l_mc_children_tbl(i).relationship_id,
                                                l_get_csi_child.inventory_item_id,
                                                l_get_csi_child.inventory_org_id,
                                                l_get_csi_child.inventory_revision,
                                                l_get_csi_child.quantity,
                                                l_get_csi_child.unit_of_measure);
                  IF l_matched THEN
                    l_mc_children_tbl(i).matched_flag := 'Y';
                    l_relationship_id := l_mc_children_tbl(i).relationship_id;
                    CLOSE check_sub_uc;
                    EXIT OUTER;
                  END IF;
                  /*
                  FOR l_get_associated_item IN get_associated_items(l_mc_children_tbl(i).item_group_id) LOOP
                    IF l_get_csi_child.inventory_item_id = l_get_associated_item.inventory_item_id AND
                       l_get_csi_child.inventory_org_id = l_get_associated_item.inventory_org_id THEN
                      l_matched := TRUE;
                      l_relationship_id := l_mc_children_tbl(i).relationship_id;
                      EXIT OUTER;
                    END IF;
                  END LOOP;
                  */

                END IF;
                CLOSE check_sub_uc;
              END IF; --whether position_key or position_ref_code matches
            END IF; --whether the MC chilren node has already been matched
          END LOOP; --of all the MC children
          END IF;

          --Set the CSI transaction record
          l_csi_transaction_rec.source_transaction_date := SYSDATE;
          l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
          --Set CSI relationship record
          l_csi_relationship_rec.relationship_id := l_get_csi_child.csi_ii_relationship_id;
          l_csi_relationship_rec.object_version_number := l_get_csi_child.csi_ii_relationship_ovn;
          l_csi_relationship_rec.position_reference := to_char(l_relationship_id);
          l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
          l_csi_relationship_rec.object_id := l_get_csi_child.parent_instance_id;
          l_csi_relationship_rec.subject_id := l_get_csi_child.instance_id;
          l_csi_relationship_tbl(1) := l_csi_relationship_rec;
          CSI_II_RELATIONSHIPS_PUB.update_relationship(
                                   p_api_version      => 1.0,
                                   p_relationship_tbl => l_csi_relationship_tbl,
                                   p_txn_rec          => l_csi_transaction_rec,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data);
          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF; --whether the UC node is an extra node
      END LOOP; --of all the UC children
    END IF; --whether it is a node belonging to subuc or extra node branch
    CLOSE check_subuc_extra;
  END LOOP; --of all non leaf nodes

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||':Within API',
			       'After migration the whole UC tree');
  END IF;

  --Call check_completeness API to check the completeness of the root UC
  IF (l_root_uc_status_code IN ('COMPLETE', 'INCOMPLETE')) THEN
    AHL_UC_VALIDATION_PUB.check_completeness(
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.G_FALSE,
      p_commit            => FND_API.G_FALSE,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_unit_header_id	  => l_root_uc_header_id,
      x_evaluation_status => l_evaluation_status);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  --dbms_output.put_line('l_root_uc_ovn(a)='||l_root_uc_ovn);
  select object_version_number into l_root_uc_ovn
    from ahl_unit_config_headers
   where unit_config_header_id = l_root_uc_header_id;
  --dbms_output.put_line('l_root_uc_ovn(b)='||l_root_uc_ovn);

  --After migration, UC(root) status change should be made.
  IF (l_evaluation_status = 'T' AND l_root_uc_status_code = 'INCOMPLETE') THEN
    UPDATE ahl_unit_config_headers
       SET unit_config_status_code = 'COMPLETE',
           active_uc_status_code = 'UNAPPROVED',
           object_version_number = object_version_number + 1,
           last_updated_by = fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id
     WHERE unit_config_header_id = l_root_uc_header_id
       AND object_version_number = l_root_uc_ovn;
    IF SQL%ROWCOUNT = 0 THEN
      FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Copy the change to UC history table
    ahl_util_uc_pkg.copy_uc_header_to_history(l_root_uc_header_id, l_return_status);
    --IF history copy failed, then don't raise exception, just add the messageto the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;
  ELSIF (l_evaluation_status = 'F' AND l_root_uc_status_code = 'COMPLETE') THEN
    UPDATE ahl_unit_config_headers
       SET unit_config_status_code = 'INCOMPLETE',
           active_uc_status_code = 'UNAPPROVED',
           object_version_number = object_version_number + 1,
           last_updated_by = fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id
     WHERE unit_config_header_id = l_root_uc_header_id
       AND object_version_number = l_root_uc_ovn;
    IF SQL%ROWCOUNT = 0 THEN
      FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Copy the change to UC history table
    ahl_util_uc_pkg.copy_uc_header_to_history(l_root_uc_header_id, l_return_status);
    --IF history copy failed, then don't raise exception, just add the messageto the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;
  ELSIF (l_root_uc_status_code IN ('COMPLETE', 'INCOMPLETE') AND
         (l_root_active_uc_status_code IS NULL OR
          l_root_active_uc_status_code <> 'UNAPPROVED')) THEN
    UPDATE ahl_unit_config_headers
       SET active_uc_status_code = 'UNAPPROVED',
           object_version_number = object_version_number + 1,
           last_updated_by = fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id
     WHERE unit_config_header_id = l_root_uc_header_id
       AND object_version_number = l_root_uc_ovn;
    IF SQL%ROWCOUNT = 0 THEN
      FND_MESSAGE.set_name( 'AHL','AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Copy the change to UC history table
    ahl_util_uc_pkg.copy_uc_header_to_history(l_root_uc_header_id, l_return_status);
    --IF history copy failed, then don't raise exception, just add the messageto the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||':After normal execution',
			       'Status changed and at the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO migrate_uc_tree;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO migrate_uc_tree;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO migrate_uc_tree;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Define Procedure remap_uc_subtree --
-- This API is used to remap a UC subtree (not a sub-unit) to a MC branch. It is called
-- by ahl_uc_instnace_pvt.install_existing_instance.
PROCEDURE remap_uc_subtree (
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_instance_id           IN  NUMBER,
  p_relationship_id       IN  NUMBER)
IS
  TYPE l_mc_children_rec_type IS RECORD(
    relationship_id           NUMBER,
    position_key              NUMBER,
    position_ref_code         VARCHAR2(30),
    item_group_id             NUMBER,
    matched_flag              VARCHAR2(1));
  TYPE l_mc_children_tbl_type IS TABLE OF l_mc_children_rec_type INDEX BY BINARY_INTEGER;
  l_mc_children_tbl           l_mc_children_tbl_type;
  l_api_name       CONSTANT   VARCHAR2(30)   := 'remap_uc_subtree';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_relationship_id           NUMBER;
  l_mc_header_id              NUMBER;
  l_root_instance_id          NUMBER;
  l_root_relationship_id      NUMBER;
  l_dummy                     NUMBER;
  i                           NUMBER;
  i_mc_child                  NUMBER;
  l_item_match                BOOLEAN;
  l_matched                   BOOLEAN;
  l_return_value              BOOLEAN;
  l_transaction_type_id       NUMBER;
  l_version_no                NUMBER;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_new_relationship_id       NUMBER;
  --In order to check whether the instance belongs to a sub unit or an extra node branch
  CURSOR check_subuc_extra(c_instance_id NUMBER, c_top_instance_id NUMBER) IS
    SELECT object_id, subject_id, position_reference
      FROM csi_ii_relationships
     WHERE subject_id IN (SELECT csi_item_instance_id
                            FROM ahl_unit_config_headers
                           WHERE trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
        OR position_reference IS NULL
START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY subject_id = PRIOR object_id
       AND subject_id <> c_top_instance_id
       --This hierarchy query is from bottom up and the top node is not a UC root node, so we
       --have to discontinue the hierarchy query when it comes to the given node
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_subuc_extra    check_subuc_extra%ROWTYPE;
  --Check the given instance_id is existing, with children instances and not a unit's or sub-unit's top node. But doesn't check whether this instance is installed or not, which is checked in get_available_instances and install_existing_instance.
  CURSOR check_uc_instance IS
    SELECT R.object_id instance_id,
           to_number(R.position_reference) relationship_id,
           C.inventory_item_id inventory_item_id,
           C.inv_master_organization_id inventory_org_id,
           C.inventory_revision,
           C.quantity,
           C.unit_of_measure
      FROM csi_ii_relationships R,
           csi_item_instances C
     WHERE R.object_id = p_instance_id
       AND R.object_id = C.instance_id
       AND R.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(R.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND NOT EXISTS (SELECT 'X'
                         FROM ahl_unit_config_headers
                        WHERE csi_item_instance_id = R.object_id
                          AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE));
  l_check_uc_instance check_uc_instance%ROWTYPE;
  --Check the given relationship_id exists and also get its item
  CURSOR check_mc_relationship IS
    SELECT M.relationship_id,
           I.inventory_item_id,
           I.inventory_org_id
      FROM ahl_mc_relationships M,
           ahl_item_associations_b I
     WHERE M.relationship_id = p_relationship_id
       AND M.item_group_id = I.item_group_id
       AND trunc(nvl(M.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(M.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_mc_relationship check_mc_relationship%ROWTYPE;
  --Get the associated items for a given item_group_id
  /*
  CURSOR get_associated_items(c_item_group_id NUMBER) IS
    SELECT inventory_item_id,
           inventory_org_id
      FROM ahl_item_associations_b
     WHERE item_group_id = c_item_group_id;
  l_get_associated_item        get_associated_items%ROWTYPE;
  */
  --Given an instance_id, get all of its immediate children from csi_ii_relationships
  CURSOR get_csi_children(c_instance_id NUMBER) IS
    SELECT C.relationship_id csi_ii_relationship_id,
           C.object_version_number csi_ii_relationship_ovn,
           C.object_id parent_instance_id,
           C.subject_id instance_id,
           to_number(C.position_reference) relationship_id,
           M.position_key,
           M.position_ref_code,
           I.inventory_item_id,
           I.inv_master_organization_id inventory_org_id,
           I.inventory_revision,
           I.quantity,
           I.unit_of_measure
      FROM csi_ii_relationships C,
           ahl_mc_relationships M,
           csi_item_instances I
     WHERE to_number(C.position_reference) = M.relationship_id (+)
       AND C.subject_id = I.instance_id
       AND C.object_id = c_instance_id
       AND C.relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(C.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Given an relationship_id, get all of its immediate children from MC
  CURSOR get_mc_children(c_relationship_id NUMBER) IS
    SELECT parent_relationship_id parent_rel_id,
           relationship_id,
           position_key,
           position_ref_code,
           item_group_id
      FROM ahl_mc_relationships
     WHERE parent_relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Check whether an instance in UC is the top node of a sub UC, if yes, then get the
  --relationship of the sub UC's top node
  CURSOR check_sub_uc(c_instance_id NUMBER) IS
    SELECT A.master_config_id mc_header_id,
           B.relationship_id
      FROM ahl_unit_config_headers A,
           ahl_mc_relationships B
     WHERE A.csi_item_instance_id = c_instance_id
       AND trunc(nvl(A.active_end_date, SYSDATE+1)) > trunc(SYSDATE)
       AND B.mc_header_id = A.master_config_id
       AND B.parent_relationship_id IS NULL
       AND trunc(nvl(B.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(B.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  l_check_sub_uc        check_sub_uc%ROWTYPE;
  --Given a position(leaf) in MC, get all the sub MCs which can be associated to this position
  CURSOR get_sub_mcs(c_relationship_id NUMBER) IS
    SELECT mc_header_id
      FROM ahl_mc_config_relations
     WHERE relationship_id = c_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  --Based on the UC, list all of the non leaf nodes including the root node
  CURSOR get_non_leaf_nodes(c_instance_id NUMBER) IS
    SELECT object_id parent_instance_id,
           subject_id instance_id,
           to_number(position_reference) relationship_id
      FROM csi_ii_relationships A
      --remove all of the leaf node after finishing the hierarchical query
     WHERE EXISTS (SELECT 'X'
                     FROM csi_ii_relationships B
                    WHERE B.object_id = A.subject_id
                      AND relationship_type_code = 'COMPONENT-OF'
                      AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
                      AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE))
START WITH subject_id = c_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT remap_uc_subtree;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
                   'At the start of the procedure, p_instance_id = ' || p_instance_id || ', p_relationship_id = ' || p_relationship_id);
  END IF;
  --Validate the input parameter p_instance_id
  OPEN check_uc_instance;
  FETCH check_uc_instance INTO l_check_uc_instance;
  IF check_uc_instance%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'instance_id');
    FND_MESSAGE.set_token('VALUE', p_instance_id);
    FND_MSG_PUB.add;
   CLOSE check_uc_instance;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_uc_instance;
  END IF;

  --Validate the input parameter p_relationship_id
  OPEN check_mc_relationship;
  FETCH check_mc_relationship INTO l_check_mc_relationship;
  IF check_mc_relationship%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'relationship_id');
    FND_MESSAGE.set_token('VALUE', p_relationship_id);
    FND_MSG_PUB.add;
    CLOSE check_mc_relationship;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE check_mc_relationship;
  END IF;

  --For UC branch top node, only need to ensure item matches, no need to check position key
  --and position_reference
  l_item_match := AHL_UTIL_UC_PKG.item_match(p_relationship_id,
                                             l_check_uc_instance.inventory_item_id,
                                             l_check_uc_instance.inventory_org_id,
                                             l_check_uc_instance.inventory_revision,
                                             l_check_uc_instance.quantity,
                                             l_check_uc_instance.unit_of_measure);
  /*
  FOR l_check_mc_relationship IN check_mc_relationship LOOP
    IF l_check_uc_instance.inventory_item_id = l_check_mc_relationship.inventory_item_id AND
       l_check_uc_instance.inventory_org_id = l_check_mc_relationship.inventory_org_id THEN
      l_item_match := TRUE;
      EXIT;
    END IF;
  END LOOP;
  */
  IF NOT l_item_match THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_NOT_MATCH' );
    FND_MESSAGE.set_token('INSTANCE', p_instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Loop through all the non leaf nodes including the top node
  FOR l_get_non_leaf_node IN get_non_leaf_nodes(p_instance_id) LOOP
    --Make sure the node doesn't belong to a sub unit or extra node branch, because for
    --all the nodes in the sub unit or extra node branch including the top most extra node
    --it is not necessary to process them and the sub unit top node itself has been processed in the loop
    --of its parent node
    OPEN check_subuc_extra(l_get_non_leaf_node.instance_id, p_instance_id);
    FETCH check_subuc_extra INTO l_check_subuc_extra;
    IF check_subuc_extra%NOTFOUND THEN
      --Get all the immediate children of the corresponding MC node
      --First get the non leaf node's new relationship_id to which it has been migrated
      --This is a bug fix found by Barry on Nov 6, 2003
      IF p_instance_id = l_get_non_leaf_node.instance_id THEN
        l_new_relationship_id := p_relationship_id;
      ELSE
        SELECT to_number(position_reference) into l_new_relationship_id
          FROM csi_ii_relationships
         WHERE subject_id = l_get_non_leaf_node.instance_id
           AND relationship_type_code='COMPONENT-OF'
           AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
           AND trunc(nvl(active_end_date, sysdate+1)) > trunc(sysdate);
      END IF;

      i_mc_child := 1;
      FOR l_get_mc_child IN get_mc_children(l_new_relationship_id) LOOP
        l_mc_children_tbl(i_mc_child).relationship_id := l_get_mc_child.relationship_id;
        l_mc_children_tbl(i_mc_child).position_key := l_get_mc_child.position_key;
        l_mc_children_tbl(i_mc_child).position_ref_code := l_get_mc_child.position_ref_code;
        l_mc_children_tbl(i_mc_child).item_group_id := l_get_mc_child.item_group_id;
        l_mc_children_tbl(i_mc_child).matched_flag := 'N'; -- default to 'N'
        i_mc_child := i_mc_child + 1;
      END LOOP;
      FOR l_get_csi_child IN get_csi_children(l_get_non_leaf_node.instance_id) LOOP
        --No processing for the extra node
        IF l_get_csi_child.relationship_id IS NOT NULL THEN
          l_matched := FALSE;
          l_relationship_id := NULL;
          <<OUTER>>
          FOR i IN l_mc_children_tbl.FIRST..l_mc_children_tbl.LAST LOOP
            IF l_mc_children_tbl(i).matched_flag <> 'Y' THEN
              IF l_get_csi_child.position_key = l_mc_children_tbl(i).position_key OR
                 l_get_csi_child.position_ref_code = l_mc_children_tbl(i).position_ref_code THEN
                --Check whether this node is a sub unit top node, if YES compare the sub
                --mc_header_id(not necessary to compare the top node's item), otherwise compare item
                OPEN check_sub_uc(l_get_csi_child.instance_id);
                FETCH check_sub_uc INTO l_check_sub_uc;
                IF check_sub_uc%FOUND THEN
                  FOR l_get_sub_mc IN get_sub_mcs(l_mc_children_tbl(i).relationship_id) LOOP
                    IF l_check_sub_uc.mc_header_id = l_get_sub_mc.mc_header_id THEN
                      l_matched := TRUE;
                      l_mc_children_tbl(i).matched_flag := 'Y';
                      l_relationship_id := l_mc_children_tbl(i).relationship_id;
                      CLOSE check_sub_uc;
                      EXIT OUTER;
                    END IF;
                  END LOOP;
                ELSE
                  l_matched := AHL_UTIL_UC_PKG.item_match(l_mc_children_tbl(i).relationship_id,
                                                          l_get_csi_child.inventory_item_id,
                                                          l_get_csi_child.inventory_org_id,
                                                          l_get_csi_child.inventory_revision,
                                                          l_get_csi_child.quantity,
                                                          l_get_csi_child.unit_of_measure);
                  /*
                  FOR l_get_associated_item IN get_associated_items(l_mc_children_tbl(i).item_group_id) LOOP
                    IF l_get_csi_child.inventory_item_id = l_get_associated_item.inventory_item_id AND
                       l_get_csi_child.inventory_org_id = l_get_associated_item.inventory_org_id THEN
                      l_matched := TRUE;
                      l_relationship_id := l_mc_children_tbl(i).relationship_id;
                      EXIT OUTER;
                    END IF;
                  END LOOP;
                  */
                  IF l_matched THEN
                    l_mc_children_tbl(i).matched_flag := 'Y';
                    l_relationship_id := l_mc_children_tbl(i).relationship_id;
                    CLOSE check_sub_uc;
                    EXIT OUTER;
                  END IF;
                END IF;
                CLOSE check_sub_uc;
                --Positions match but items or sub-configs don't match, then we define it as a hard failure
                --in Part Change but still an extra node in migration. Both position_key and position_ref_code
                --are unique across siblings.
                IF NOT l_matched THEN
                  FND_MESSAGE.set_name( 'AHL','AHL_UC_INSTANCE_HARD_FAIL' );
                  FND_MESSAGE.set_token('INSTANCE', l_get_csi_child.instance_id);
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
              END IF; --whether position_key or position_ref_code matches
            END IF; --whether the MC chilren node has already been matched
          END LOOP; --of all the MC children
          --The following lines are used to update the position_reference column in csi_ii_relationships
          --First, get transaction_type_id .
          AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_value);
          IF NOT l_return_value THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          --Set the CSI transaction record
          l_csi_transaction_rec.source_transaction_date := SYSDATE;
          l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
          --Set CSI relationship record
          l_csi_relationship_rec.relationship_id := l_get_csi_child.csi_ii_relationship_id;
          l_csi_relationship_rec.object_version_number := l_get_csi_child.csi_ii_relationship_ovn;
          l_csi_relationship_rec.position_reference := to_char(l_relationship_id);
          l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
          l_csi_relationship_rec.object_id := l_get_csi_child.parent_instance_id;
          l_csi_relationship_rec.subject_id := l_get_csi_child.instance_id;
          l_csi_relationship_tbl(1) := l_csi_relationship_rec;
          CSI_II_RELATIONSHIPS_PUB.update_relationship(
                                   p_api_version      => 1.0,
                                   p_relationship_tbl => l_csi_relationship_tbl,
                                   p_txn_rec          => l_csi_transaction_rec,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data);
          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF; --whether the UC node is an extra node
      END LOOP; --of all the UC children
    END IF; --whether it is a node belonging to subuc or extra node branch
    CLOSE check_subuc_extra;
  END LOOP; --of all non leaf nodes

  -- Added by rbhavsar on July 25, 2007 to remap IB Tree Nodes to fix FP bug 6276991
  Remap_IB_Tree(p_instance_id, p_relationship_id);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
                   'At the end of the procedure');
  END IF;
  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO remap_uc_subtree;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO remap_uc_subtree;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO remap_uc_subtree;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END;

-- Following two procedures added by rbhavsar on July 25, 2007
-- to remap IB Tree Nodes to fix FP bug 6276991
PROCEDURE Remap_IB_Tree(p_instance_id     IN  NUMBER,
                        p_relationship_id IN  NUMBER)
IS

  -- Get all the children of the current instance that are extra nodes
  CURSOR get_extra_children_csr IS
   SELECT subject_id
     FROM csi_ii_relationships
    WHERE object_id = p_instance_id
      AND relationship_type_code = 'COMPONENT-OF'
      AND position_reference IS NULL
      AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
      AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
      AND NOT EXISTS (SELECT 'X'
                        FROM ahl_unit_config_headers
                       WHERE csi_item_instance_id = subject_id
                         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE));

  -- Get all the children of the current instance that are NOT extra nodes
  CURSOR get_premapped_instances_csr IS
   SELECT subject_id, position_reference
     FROM csi_ii_relationships
    WHERE object_id = p_instance_id
      AND relationship_type_code = 'COMPONENT-OF'
      AND position_reference IS NOT NULL
      AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
      AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
      AND NOT EXISTS (SELECT 'X'
                        FROM ahl_unit_config_headers
                       WHERE csi_item_instance_id = subject_id
                         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE));

  -- Validate that the child position is still valid under the parent position
  CURSOR validate_position_csr(c_child_relationship_id IN NUMBER) IS
   SELECT 1 from ahl_mc_relationships
   where relationship_id = c_child_relationship_id
     AND parent_relationship_id = p_relationship_id
     AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
     AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  -- Get all children of current position that are empty positions
  CURSOR get_all_empty_positions_csr IS
   SELECT relationship_id
     FROM ahl_mc_relationships
     WHERE parent_relationship_id = p_relationship_id
       AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
   MINUS
   SELECT to_number(position_reference) relationship_id
    FROM csi_ii_relationships relationship_id
    WHERE object_id = p_instance_id
     AND relationship_type_code = 'COMPONENT-OF'
     AND position_reference IS NOT NULL
     AND trunc(nvl(active_start_date,SYSDATE)) <= trunc(SYSDATE)
     AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_ii_rel_dtls_csr(c_instance_id NUMBER) IS
   SELECT C.relationship_id,
          C.object_version_number,
          C.object_id,
          C.subject_id
     FROM csi_ii_relationships C
    WHERE C.subject_id = c_instance_id
      AND C.relationship_type_code = 'COMPONENT-OF'
      AND trunc(nvl(C.active_start_date,SYSDATE)) <= trunc(SYSDATE)
      AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  L_DEBUG_KEY   CONSTANT VARCHAR2(150) := 'ahl.plsql.AHL_UC_TREE_PVT.Remap_IB_Tree';
  l_extra_instances_tbl T_ID_TBL;
  l_relations_tbl T_ID_TBL;
  l_premapped_instances_tbl T_ID_TBL;
  l_temp NUMBER;
  l_csi_relationship_rec csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl csi_datastructures_pub.ii_relationship_tbl;
  l_csi_transaction_rec  csi_datastructures_pub.transaction_rec;
  l_ii_rel_dtls          get_ii_rel_dtls_csr%ROWTYPE;
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_return_value         BOOLEAN;
  l_transaction_type_id  NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                   'At the start of the procedure, p_instance_id = ' || p_instance_id || ', p_relationship_id = ' || p_relationship_id);
  END IF;

  -- Get the transaction_type_id for use later by the CSI_II_RELATIONSHIPS_PUB.update_relationship API
  AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE', l_transaction_type_id, l_return_value);
  IF NOT l_return_value THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';

  -- Get all nodes that are non-extra nodes
  FOR l_nonextra_instances IN get_premapped_instances_csr LOOP
    -- Validate if the instance still matches the position
    -- Check if l_nonextra_instances.position_reference is under the position p_relationship_id
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                     'Non Extra Node: l_nonextra_instances.subject_id = ' || l_nonextra_instances.subject_id ||
                     ', l_nonextra_instances.position_reference = ' || l_nonextra_instances.position_reference);
    END IF;
    OPEN validate_position_csr(TO_NUMBER(l_nonextra_instances.position_reference));
    FETCH validate_position_csr INTO l_temp;
    IF (validate_position_csr%NOTFOUND) THEN
      -- Reset the position reference so that the instance becomes an extra node node
      OPEN get_ii_rel_dtls_csr( l_nonextra_instances.subject_id);
      FETCH get_ii_rel_dtls_csr INTO l_ii_rel_dtls;
      CLOSE get_ii_rel_dtls_csr;
      --Set CSI relationship record
      l_csi_relationship_rec.relationship_id := l_ii_rel_dtls.relationship_id;
      l_csi_relationship_rec.object_version_number := l_ii_rel_dtls.object_version_number;
      l_csi_relationship_rec.position_reference := null;  -- Nullify the relationship
      l_csi_relationship_rec.object_id := l_ii_rel_dtls.object_id;
      l_csi_relationship_rec.subject_id := l_ii_rel_dtls.subject_id;
      l_csi_relationship_tbl(1) := l_csi_relationship_rec;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                       'About to call CSI_II_RELATIONSHIPS_PUB.update_relationship to update CSI II relationship with id ' ||
                       l_ii_rel_dtls.relationship_id || ' between ' ||
                       l_ii_rel_dtls.object_id || ' (object) and ' ||
                       l_ii_rel_dtls.subject_id || '(subject) with NULL position_reference ');
      END IF;
      CSI_II_RELATIONSHIPS_PUB.update_relationship(
                               p_api_version      => 1.0,
                               p_relationship_tbl => l_csi_relationship_tbl,
                               p_txn_rec          => l_csi_transaction_rec,
                               x_return_status    => l_return_status,
                               x_msg_count        => l_msg_count,
                               x_msg_data         => l_msg_data);
      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
      -- Position Matches at current level: Drill down by calling Remap_IB_Tree recursively
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                       'About to recursively call Remap_IB_Tree with p_instance_id = ' || l_nonextra_instances.subject_id ||
                       ', p_relationship_id =' || l_nonextra_instances.position_reference);
      END IF;
      Remap_IB_Tree(p_instance_id     => l_nonextra_instances.subject_id,
                    p_relationship_id => TO_NUMBER(l_nonextra_instances.position_reference));
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                       'Returned from recursive call to Remap_IB_Tree.');
      END IF;
    END IF;
    CLOSE validate_position_csr;
  END LOOP;  -- All non-extra nodes

  -- Get all the children of the current instance that are extra nodes
  OPEN get_extra_children_csr;
  FETCH get_extra_children_csr BULK COLLECT INTO l_extra_instances_tbl;
  CLOSE get_extra_children_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                   'Number of extra nodes: ' || l_extra_instances_tbl.COUNT ||
                   ', Number of non-extra nodes: ' || l_premapped_instances_tbl.COUNT);
  END IF;
  IF (l_extra_instances_tbl.COUNT > 0) THEN
    -- There are child nodes present
    -- Get all children of current position that are empty positions
    OPEN get_all_empty_positions_csr;
    FETCH get_all_empty_positions_csr BULK COLLECT INTO l_relations_tbl;
    CLOSE get_all_empty_positions_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                     'Number of empty positions: ' || l_relations_tbl.COUNT);
    END IF;
    IF (l_relations_tbl.COUNT > 0) THEN
      -- Analyse and process instances with matching positions
      Process_Instances(p_x_extra_instances_tbl => l_extra_instances_tbl,
                        p_x_relations_tbl       => l_relations_tbl);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                       'Number of extra nodes after processing: ' || l_extra_instances_tbl.COUNT ||
                       ', Number of empty positions after processing: ' || l_relations_tbl.COUNT);
      END IF;
    END IF;
  END IF;  -- There are child nodes

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
                   'At the end of the procedure.');
  END IF;
END Remap_IB_Tree;

-------
-- This procedure is called by Remap_IB_Tree and checks if an instance matches an unique
-- relationship and if so, sets the position_reference. All relations are searched and
-- if multiple are matching, position_reference is not set.
-- This procedure also calls Remap_IB_Tree (mutual recursion) to process children.
PROCEDURE Process_instances(p_x_extra_instances_tbl IN OUT NOCOPY T_ID_TBL,
                            p_x_relations_tbl       IN OUT NOCOPY T_ID_TBL) IS

  CURSOR get_instance_dtls_csr(c_instance_id IN NUMBER) IS
   SELECT inventory_item_id,
          inv_master_organization_id,
          inventory_revision,
          quantity,
          unit_of_measure
     FROM csi_item_instances
     WHERE instance_id = c_instance_id;

  CURSOR get_ii_rel_dtls_csr(c_instance_id NUMBER) IS
   SELECT C.relationship_id,
          C.object_version_number,
          C.object_id,
          C.subject_id
     FROM csi_ii_relationships C
    WHERE C.subject_id = c_instance_id
      AND C.relationship_type_code = 'COMPONENT-OF'
      AND trunc(nvl(C.active_start_date,SYSDATE)) <= trunc(SYSDATE)
      AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  l_instance_dtls        get_instance_dtls_csr%ROWTYPE;
  l_ii_rel_dtls          get_ii_rel_dtls_csr%ROWTYPE;
  L_DEBUG_KEY            CONSTANT VARCHAR2(150) := 'ahl.plsql.AHL_UC_TREE_PVT.Process_instances';
  l_map_tbl              T_ID_TBL;
  l_item_match           BOOLEAN;
  l_csi_relationship_rec csi_datastructures_pub.ii_relationship_rec;
  l_csi_relationship_tbl csi_datastructures_pub.ii_relationship_tbl;
  l_csi_transaction_rec  csi_datastructures_pub.transaction_rec;
  l_return_value         BOOLEAN;
  l_transaction_type_id  NUMBER;
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  i                      NUMBER;
  j                      NUMBER;
  k                      NUMBER;
  l_matched_flag         BOOLEAN;
  l_current_position     NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                   'At the start of the procedure, p_x_extra_instances_tbl.count = ' || p_x_extra_instances_tbl.count || ',p_x_relations_tbl.count = ' ||p_x_relations_tbl.count);
  END IF;

  -- Get the transaction_type_id for use later by the CSI_II_RELATIONSHIPS_PUB.update_relationship API
  AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE', l_transaction_type_id, l_return_value);
  IF NOT l_return_value THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';

  -- There are extra nodes present
  i := p_x_extra_instances_tbl.FIRST;
  WHILE (i IS NOT NULL) LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                     'i = ' || i || ', p_x_extra_instances_tbl(i) = ' || p_x_extra_instances_tbl(i));
    END IF;
    -- Initialize associative array
    l_map_tbl(p_x_extra_instances_tbl(i)) := 0;
    OPEN get_instance_dtls_csr(p_x_extra_instances_tbl(i));
    FETCH get_instance_dtls_csr INTO l_instance_dtls;
    CLOSE get_instance_dtls_csr;
    j := p_x_relations_tbl.FIRST;
    WHILE (j IS NOT NULL) LOOP
      -- See if instance i matches position j
      l_item_match := AHL_UTIL_UC_PKG.item_match(p_x_relations_tbl(j),
                                                 l_instance_dtls.inventory_item_id,
                                                 l_instance_dtls.inv_master_organization_id,
                                                 l_instance_dtls.inventory_revision,
                                                 l_instance_dtls.quantity,
                                                 l_instance_dtls.unit_of_measure);
      IF (l_item_match) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Instance ' || p_x_extra_instances_tbl(i) || ' fits position ' || p_x_relations_tbl(j));
        END IF;
        IF (l_map_tbl(p_x_extra_instances_tbl(i))) <> 0 THEN
          -- More than one match
          l_map_tbl(p_x_extra_instances_tbl(i)) := -1;
          EXIT;  -- No need to check more positions: go to the next instance
        ELSE
          -- First Match
          l_map_tbl(p_x_extra_instances_tbl(i)) := p_x_relations_tbl(j);
        END IF;
      END IF;  -- l_item_match is true
      j := p_x_relations_tbl.NEXT(j);
    END LOOP;  -- For all Positions
    i := p_x_extra_instances_tbl.NEXT(i);
  END LOOP;  -- For all instances (Extra Nodes)

  -- Now that analysis is done, process the instances
  i := p_x_extra_instances_tbl.FIRST;
  WHILE (i IS NOT NULL) LOOP
    IF (l_map_tbl(p_x_extra_instances_tbl(i))) = 0 THEN
      -- No Matching position found: Delete and Ignore this instance
      -- Instance will continue to remain an extra node.
      p_x_extra_instances_tbl.DELETE(i);
    ELSIF (l_map_tbl(p_x_extra_instances_tbl(i))) > 0 THEN
      -- Exactly one matching position has been found: Check if this matched relationship
      -- is also a match for any other instance
      l_current_position := l_map_tbl(p_x_extra_instances_tbl(i));
      k := p_x_extra_instances_tbl.NEXT(i);
      l_matched_flag := FALSE;
      WHILE (k IS NOT NULL) LOOP
        IF (l_map_tbl(p_x_extra_instances_tbl(k)) = l_current_position) THEN
          -- Another instance also has been matched to this position: Ignore that instance
          l_map_tbl(p_x_extra_instances_tbl(k)) := -1;
          l_matched_flag := TRUE;
        END IF;
        k := p_x_extra_instances_tbl.NEXT(k);
      END LOOP;
      IF (l_matched_flag = TRUE) THEN
        -- One or more instance also has been matched to this instance's position:
        -- Ignore the current instance. Let the user associate manually.
        l_map_tbl(p_x_extra_instances_tbl(i)) := -1;
      ELSE
        -- Exactly one matching position has been found
        -- Set the Position reference for the csi_ii_relationship
        OPEN get_ii_rel_dtls_csr(p_x_extra_instances_tbl(i));
        FETCH get_ii_rel_dtls_csr INTO l_ii_rel_dtls;
        CLOSE get_ii_rel_dtls_csr;
        --Set CSI relationship record
        l_csi_relationship_rec.relationship_id := l_ii_rel_dtls.relationship_id;
        l_csi_relationship_rec.object_version_number := l_ii_rel_dtls.object_version_number;
        l_csi_relationship_rec.position_reference := to_char(l_current_position);
        l_csi_relationship_rec.object_id := l_ii_rel_dtls.object_id;
        l_csi_relationship_rec.subject_id := l_ii_rel_dtls.subject_id;
        l_csi_relationship_tbl(1) := l_csi_relationship_rec;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'About to call CSI_II_RELATIONSHIPS_PUB.update_relationship to update CSI II relationship with id ' ||
                         l_ii_rel_dtls.relationship_id || ' between ' ||
                         l_ii_rel_dtls.object_id || ' (object) and ' ||
                         l_ii_rel_dtls.subject_id || '(subject) with position_reference ' ||
                         to_char(l_current_position));
        END IF;
        CSI_II_RELATIONSHIPS_PUB.update_relationship(
                                 p_api_version      => 1.0,
                                 p_relationship_tbl => l_csi_relationship_tbl,
                                 p_txn_rec          => l_csi_transaction_rec,
                                 x_return_status    => l_return_status,
                                 x_msg_count        => l_msg_count,
                                 x_msg_data         => l_msg_data);
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Now recursively match all the children of the current instance/position
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'About to recursively call Remap_IB_Tree');
        END IF;
        Remap_IB_Tree(p_instance_id     => p_x_extra_instances_tbl(i),
                      p_relationship_id => l_current_position);
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Returned from recursive call to Remap_IB_Tree');
        END IF;
        -- Now delete the matched relationship
        j := p_x_relations_tbl.FIRST;
        WHILE (j IS NOT NULL) LOOP
          IF p_x_relations_tbl(j) = l_current_position THEN
            p_x_relations_tbl.DELETE(j);
            EXIT;
          END IF;
          j := p_x_relations_tbl.NEXT(j);
        END LOOP;
        -- Now delete the matched instance
        p_x_extra_instances_tbl.DELETE(i);
      END IF;  -- l_matched_flag is TRUE or FALSE
    ELSE
      -- Multiple matching positions found: Do nothing and let the user associate manually
      null;
    END IF;
    i := p_x_extra_instances_tbl.NEXT(i);
  END LOOP;
  l_map_tbl.DELETE;  -- Clear up the temporary Associative Array

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
                   'At the end of the procedure. Remaining Instances: ' ||  p_x_extra_instances_tbl.count);
  END IF;
END Process_instances;


END AHL_UC_TREE_PVT; -- Package body

/
