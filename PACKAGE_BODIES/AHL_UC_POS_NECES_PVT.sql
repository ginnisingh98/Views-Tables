--------------------------------------------------------
--  DDL for Package Body AHL_UC_POS_NECES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_POS_NECES_PVT" AS
/* $Header: AHLVNECB.pls 120.2 2007/12/21 13:29:24 sathapli ship $ */

  G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_UC_POS_NECES_PVT';


----------------------------------------
-- Begin Local Procedures Declaration--
----------------------------------------
-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

------------------------
-- Define  Procedures --
------------------------
--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : List_Extra_Nodes
--  Type        	: Private
--  Function    	: List all the nodes in the unit configuration which are extra.
--                    i.e. with no corresponding position reference
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  List_Extra_Nodes parameters :
--  p_uc_header_id    	IN  NUMBER Required
--   			The header id of the unit configuration
--  p_csi_instance_id  IN NUMBER the starting intance id. It's the
--                    alternative to p_uc_header_id
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit has extra nodes or not.
-- p_x_error_table        IN OUT AHL_UC_POS_NECES_PVT.Error_Tbl_Type
--                      An output table with the list of all the extra nodes.
--
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE List_Extra_Nodes(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_csi_instance_id       IN  NUMBER,
  p_x_error_table         IN OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
  x_evaluation_status     OUT NOCOPY VARCHAR2
  )
  IS
----
 CURSOR get_uc_header_rec_csr(p_uc_header_id IN NUMBER) IS
  SELECT csi_item_instance_id
   FROM   ahl_unit_config_headers
  WHERE  unit_config_header_id = p_uc_header_id
  AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
  AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
---
  --To get extra nodes
  CURSOR get_extra_nodes_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT subject_id
    FROM   csi_ii_relationships
    WHERE position_reference is null
    START WITH object_id = p_csi_item_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  --To get extra node children nodes
  CURSOR get_extra_node_child_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT subject_id
    FROM   csi_ii_relationships
    START WITH object_id = p_csi_item_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
--
  CURSOR get_node_details_csr (p_csi_instance_id IN NUMBER) IS
    SELECT M.concatenated_segments, C.serial_number
      FROM csi_item_instances C,
           mtl_system_items_kfv M
     WHERE instance_id = p_csi_instance_id
       AND M.inventory_item_id = C.inventory_item_id
       AND M.organization_id = c.inv_master_organization_id;
--
--Extra nodes can not be top nodes, so no need to check that.
 CURSOR get_unit_instance_csr  (p_csi_instance_id IN NUMBER) IS
    SELECT object_id
     FROM csi_ii_relationships
     WHERE object_id IN
      ( SELECT csi_item_instance_id
	 FROM ahl_unit_config_headers
        WHERE trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
     START WITH subject_id = p_csi_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
     CONNECT BY subject_id = PRIOR object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
--
--With unit instance id, fetch the unit name.
CURSOR get_node_unit_csr  (p_csi_instance_id IN NUMBER) IS
 SELECT uch.name
    FROM   ahl_unit_config_headers uch
    WHERE uch.csi_item_instance_id=p_csi_instance_id;

--
    l_api_version      CONSTANT NUMBER := 1.0;
    l_api_name         CONSTANT VARCHAR2(30) := 'List_Extra_Nodes';
    l_top_instance_id    NUMBER;
    l_csi_id             NUMBER;
    l_unit_csi_id        NUMBER;
    l_unit_name          ahl_unit_config_headers.name%TYPE;
    l_item_number        mtl_system_items_kfv.concatenated_segments%TYPE;
    l_serial_number      csi_item_instances.serial_number%TYPE;
--
  BEGIN

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  x_evaluation_status := FND_API.G_TRUE;


  --Call procedure to validate the uc header id
  IF (p_csi_instance_id IS NOT NULL AND
      p_uc_header_id IS NULL) THEN
   l_top_instance_id := p_csi_instance_id;
  ELSE
   OPEN get_uc_header_rec_csr(p_uc_header_id);
   FETCH get_uc_header_rec_csr INTO l_top_instance_id;
   IF ( get_uc_header_rec_csr%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
      FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_header_rec_csr;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_uc_header_rec_csr;
  END IF;

  OPEN  get_extra_nodes_csr(l_top_instance_id);
  LOOP
     FETCH get_extra_nodes_csr into l_csi_id;
     EXIT WHEN get_extra_nodes_csr%NOTFOUND;


     --Fetch the instance details for the error message
     OPEN get_node_details_csr(l_csi_id);
     FETCH get_node_details_csr into l_item_number, l_serial_number;
     CLOSE get_node_details_csr;

     OPEN get_unit_instance_csr(l_csi_id);
     FETCH  get_unit_instance_csr into l_unit_csi_id;
     IF (get_unit_instance_csr%FOUND) THEN
        OPEN get_node_unit_csr(l_unit_csi_id);
        FETCH  get_node_unit_csr into l_unit_name;
        CLOSE get_node_unit_csr;
     END IF;
     CLOSE get_unit_instance_csr;

     --Build the error message
     FND_MESSAGE.Set_Name('AHL','AHL_UC_EXTRA_NODE');
     FND_MESSAGE.Set_Token('ITEM_NO', l_item_number);
     FND_MESSAGE.Set_Token('SERIAL_NO', l_serial_number);
     FND_MESSAGE.Set_Token('UNIT_NAME', l_unit_name);

     --Get the extra node childrens and list them.
     OPEN  get_extra_node_child_csr(l_csi_id);
     LOOP
       FETCH get_extra_node_child_csr into l_csi_id;
       EXIT WHEN get_extra_node_child_csr%NOTFOUND;

       --Fetch the instance details for the error message
       OPEN get_node_details_csr(l_csi_id);
       FETCH get_node_details_csr into l_item_number, l_serial_number;
       CLOSE get_node_details_csr;

       --Build the error message
       FND_MESSAGE.Set_Name('AHL','AHL_UC_EXTRA_NODE');
       FND_MESSAGE.Set_Token('ITEM_NO', l_item_number);
       FND_MESSAGE.Set_Token('SERIAL_NO', l_serial_number);
       FND_MESSAGE.Set_Token('UNIT_NAME', l_unit_name);

     END LOOP;
     CLOSE get_extra_node_child_csr;

     -- Write the error message to the error table.
     IF (p_x_error_table.COUNT >0) THEN
       p_x_error_table(p_x_error_table.LAST+1) := FND_MESSAGE.get;
     ELSE
       p_x_error_table(0) := FND_MESSAGE.get;
     END IF;
     x_evaluation_status := FND_API.G_FALSE;

  END LOOP;
  CLOSE get_extra_nodes_csr;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END List_Extra_Nodes;

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Check_Extra_Nodes
--  Type        	: Private
--  Function    	: Checks if there are any extra nodes in a unit configuration.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  check_extra_nodes parameters :
--  p_uc_header_id    	IN  Required
--   			The header id of the unit configuration
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit configuration
--                      has any extra nodes and returns FND_API.G_TRUE ot FND_API.G_FALSE accordingly.
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Extra_Nodes(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  x_evaluation_status     OUT NOCOPY VARCHAR2
  )
  IS
--
 CURSOR get_uc_header_rec_csr(p_uc_header_id IN NUMBER) IS
  SELECT csi_item_instance_id
   FROM   ahl_unit_config_headers
  WHERE  unit_config_header_id = p_uc_header_id
  AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
  AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
---
  --To get extra nodes
  CURSOR get_extra_nodes_csr(p_csi_item_instance_id IN NUMBER) IS
    SELECT 'X'
    FROM   csi_ii_relationships
    WHERE position_reference is null
    START WITH object_id = p_csi_item_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

--
   l_api_version      CONSTANT NUMBER := 1.0;
   l_api_name         CONSTANT VARCHAR2(30) := 'Check_Extra_Nodes';
   l_top_instance_id   NUMBER;
   l_dummy         VARCHAR2(1);
--
BEGIN


  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
 --Call procedure to validate the uc header id
  OPEN get_uc_header_rec_csr(p_uc_header_id);
  FETCH get_uc_header_rec_csr INTO l_top_instance_id;
  IF ( get_uc_header_rec_csr%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
      FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_header_rec_csr;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_uc_header_rec_csr;


  OPEN  get_extra_nodes_csr(l_top_instance_id);
  FETCH get_extra_nodes_csr INTO l_dummy;
  IF (get_extra_nodes_csr%FOUND) THEN
    x_evaluation_status := FND_API.G_FALSE;
  ELSE
    x_evaluation_status := FND_API.G_TRUE;
  END IF;
  CLOSE get_extra_nodes_csr;
  --Completed Processing

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
END Check_Extra_Nodes;

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : Check_Missing_Positions
--  Type        	: Private
--  Function    	: List all the checks if the unit config has any missing
--                    positions.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  list_missing_positions parameters :
--  p_uc_header_id    	IN  Required
--   			The header id of the unit configuration
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit configuration
--                      has any missing positions and returns FND_API.G_TRUE ot FND_API.G_FALSE accordingly.
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Missing_Positions(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  x_evaluation_status     OUT NOCOPY VARCHAR2
  )
  IS
--
 CURSOR get_uc_header_rec_csr(p_uc_header_id IN NUMBER) IS
  SELECT csi_item_instance_id
   FROM   ahl_unit_config_headers
  WHERE  unit_config_header_id = p_uc_header_id
  AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
  AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
--
--Get all of the unit's instances/positions that are NOT extra nodes
CURSOR get_unit_tree_csr(c_csi_instance_id IN NUMBER) IS
  SELECT c_csi_instance_id FROM dual
 UNION ALL
  SELECT subject_id
    FROM   csi_ii_relationships
    START WITH object_id = c_csi_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND position_reference is not null;


--Get the relationship id if instance is a uc header
CURSOR get_relnship_id_csr(c_csi_instance_id IN  NUMBER) IS
  SELECT  mc.relationship_id
    FROM  ahl_unit_config_headers uc, ahl_mc_relationships mc
    WHERE uc.master_config_id = mc.mc_header_id
       AND mc.parent_relationship_id is null
       AND uc.csi_item_instance_id = c_csi_instance_id
       AND trunc(nvl(uc.active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) < trunc(nvl(uc.active_end_date, sysdate+1));

--If instance is not uc header, then get it based on instance
CURSOR get_pos_ref_reln_csr (c_csi_instance_id IN NUMBER) IS
  SELECT TO_NUMBER(position_reference)
   FROM csi_ii_relationships csi
  WHERE position_reference is not null
    AND  subject_id = c_csi_instance_id
    AND relationship_type_code = 'COMPONENT-OF'
    AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
    AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

--
--Check mandatory children
 CURSOR check_mand_child_missing_csr(c_relationship_id IN NUMBER,
				    c_parent_instance_id IN NUMBER) IS
     SELECT 'X'
     FROM ahl_mc_relationships mc
     WHERE mc.parent_relationship_id = c_relationship_id
       AND mc.position_necessity_code = 'MANDATORY'
       AND trunc(nvl(mc.active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) < trunc(nvl(mc.active_end_date, sysdate+1))
       AND  NOT EXISTS (
       SELECT 'X'
         FROM   csi_ii_relationships csi
        WHERE  object_id = c_parent_instance_id
          AND TO_NUMBER(position_reference) = mc.relationship_id
          AND relationship_type_code = 'COMPONENT-OF'
          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)));
--
    l_api_version      CONSTANT NUMBER := 1.0;
    l_api_name         CONSTANT VARCHAR2(30) := 'Check_Missing_Positions';
    l_top_instance_id  NUMBER;
    l_csi_ii_id        NUMBER;
    l_rel_id           NUMBER;
    l_dummy                VARCHAR2(1);
--
BEGIN


  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_evaluation_status := FND_API.G_TRUE;

  -- Begin Processing
  --Call procedure to validate the uc header id
  OPEN get_uc_header_rec_csr(p_uc_header_id);
  FETCH get_uc_header_rec_csr INTO l_top_instance_id;
  IF ( get_uc_header_rec_csr%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
      FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_header_rec_csr;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_uc_header_rec_csr;

  OPEN  get_unit_tree_csr(l_top_instance_id);
  <<l_unit_tree_loop>>
  LOOP
   FETCH get_unit_tree_csr into l_csi_ii_id;
    EXIT WHEN get_unit_tree_csr%NOTFOUND;

    --Fetch instance position if it is subunit
    OPEN get_relnship_id_csr(l_csi_ii_id);
    FETCH get_relnship_id_csr INTO l_rel_id;

    --If not subunit, just fetch assuming instance.
    IF (get_relnship_id_csr%NOTFOUND) THEN
       OPEN get_pos_ref_reln_csr(l_csi_ii_id);
       FETCH get_pos_ref_reln_csr INTO l_rel_id;
       CLOSE get_pos_ref_reln_csr;
    END IF;
    CLOSE get_relnship_id_csr;

    -- Check if all the mandatory positions have item instances mapped.
    OPEN  check_mand_child_missing_csr( l_rel_id,l_csi_ii_id);
    FETCH check_mand_child_missing_csr INTO l_dummy;

    --If found, then there are missing positions
    IF (check_mand_child_missing_csr%FOUND) THEN
        x_evaluation_status := FND_API.G_FALSE;
        EXIT l_unit_tree_loop;
    END IF;
    CLOSE check_mand_child_missing_csr;

  END LOOP;
  CLOSE get_unit_tree_csr;

  --Completed Processing

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Check_Missing_Positions;

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name  : List_Missing_Positions
--  Type        	: Private
--  Function    	: List all the mandatory positions that dont have instances mapped to it.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  list_missing_positions parameters :
--  p_uc_header_id    	IN  Required
--   			The header id of the unit configuration
--  x_evaluation_status OUT VARCHAR2
--                      The flag which indicates whether the unit has any missing positions
--  History:
--      05/19/03       SBethi       CREATED
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE List_Missing_Positions(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_TRUE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_csi_instance_id       IN  NUMBER,
  p_x_error_table         IN  OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
  x_evaluation_status     OUT NOCOPY VARCHAR2
  )  IS
----
 CURSOR get_uc_header_rec_csr(p_uc_header_id IN NUMBER) IS
  SELECT csi_item_instance_id
   FROM   ahl_unit_config_headers
  WHERE  unit_config_header_id = p_uc_header_id
  AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
  AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));
--
--Get all of the unit's instances/positions. Get all non-extra nodes
CURSOR get_unit_tree_csr(c_csi_instance_id IN NUMBER) IS
  SELECT c_csi_instance_id FROM dual
 UNION ALL
  SELECT subject_id
    FROM   csi_ii_relationships
    START WITH object_id = c_csi_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
	AND position_reference is not null;

--Get the relationship id if instance is a uc header
CURSOR get_relnship_id_csr(c_csi_instance_id IN  NUMBER) IS
  SELECT  mc.relationship_id
    FROM  ahl_unit_config_headers uc, ahl_mc_relationships mc
    WHERE uc.master_config_id = mc.mc_header_id
       AND mc.parent_relationship_id is null
       AND uc.csi_item_instance_id = c_csi_instance_id
       AND trunc(nvl(uc.active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) < trunc(nvl(uc.active_end_date, sysdate+1));

--If instance is not uc header, then get it based on instance
CURSOR get_pos_ref_reln_csr (c_csi_instance_id IN NUMBER) IS
  SELECT TO_NUMBER(position_reference)
   FROM csi_ii_relationships csi
  WHERE position_reference is not null
    AND  subject_id = c_csi_instance_id
    AND relationship_type_code = 'COMPONENT-OF'
    AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
    AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

--
--Check mandatory children
 CURSOR check_mand_child_missing_csr(c_relationship_id IN NUMBER,
				    c_parent_instance_id IN NUMBER) IS
     SELECT mc.relationship_id, mc.position_ref_code
     FROM ahl_mc_relationships mc
     WHERE mc.parent_relationship_id = c_relationship_id
       AND mc.position_necessity_code = 'MANDATORY'
       AND trunc(nvl(mc.active_start_date,sysdate)) <= trunc(sysdate)
       AND trunc(sysdate) < trunc(nvl(mc.active_end_date, sysdate+1))
       AND  NOT EXISTS (
       SELECT 'X'
         FROM   csi_ii_relationships csi
        WHERE  object_id = c_parent_instance_id
          AND TO_NUMBER(position_reference) = mc.relationship_id
          AND relationship_type_code = 'COMPONENT-OF'
          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)));
--
   --Get mandatory children for missing position
   CURSOR get_mand_pos_desc_csr(c_relationship_id IN  NUMBER) IS
     SELECT  position_ref_code
     FROM ahl_mc_relationships
     START WITH parent_relationship_id = c_relationship_id
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
     CONNECT BY PRIOR relationship_id = parent_relationship_id
        AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND position_necessity_code = 'MANDATORY';
--
    l_api_version      CONSTANT NUMBER := 1.0;
    l_api_name         CONSTANT VARCHAR2(30) := 'List_Missing_Positions';
    l_top_instance_id  NUMBER;
    l_csi_ii_id        NUMBER;
    l_rel_id           NUMBER;
    l_miss_rel_id      NUMBER;
    l_return_val         BOOLEAN DEFAULT TRUE;
    l_pos_ref_code   fnd_lookups.lookup_code%TYPE;
    l_pos_ref_meaning   fnd_lookups.meaning%TYPE;

BEGIN

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Setting output parameters
  x_evaluation_status := FND_API.G_TRUE;

  -- Begin Processing
  IF (p_csi_instance_id IS NOT NULL AND
      p_uc_header_id IS NULL) THEN
   l_top_instance_id := p_csi_instance_id;
  ELSE
   --Call procedure to validate the uc header id
   OPEN get_uc_header_rec_csr(p_uc_header_id);
   FETCH get_uc_header_rec_csr INTO l_top_instance_id;
   IF ( get_uc_header_rec_csr%NOTFOUND ) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
      FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_header_rec_csr;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE get_uc_header_rec_csr;
  END IF;

  OPEN  get_unit_tree_csr(l_top_instance_id);
  LOOP
    FETCH get_unit_tree_csr into l_csi_ii_id;
    EXIT WHEN get_unit_tree_csr%NOTFOUND;

    --Fetch instance position if it is subunit
    OPEN get_relnship_id_csr(l_csi_ii_id);
    FETCH get_relnship_id_csr INTO l_rel_id;

    --If not subunit, just fetch assuming instance.
    IF (get_relnship_id_csr%NOTFOUND) THEN
       OPEN get_pos_ref_reln_csr(l_csi_ii_id);
       FETCH get_pos_ref_reln_csr INTO l_rel_id;
       CLOSE get_pos_ref_reln_csr;
    END IF;
    CLOSE get_relnship_id_csr;

    -- Check if all the mandatory positions have item instances mapped.
    OPEN  check_mand_child_missing_csr(l_rel_id, l_csi_ii_id);
    LOOP
       FETCH check_mand_child_missing_csr INTO l_miss_rel_id, l_pos_ref_code;
       EXIT WHEN check_mand_child_missing_csr%NOTFOUND;

       AHL_UTIL_MC_PKG.Convert_To_LookupMeaning('AHL_POSITION_REFERENCE',
                                                 l_pos_ref_code,
                                                 l_pos_ref_meaning,
                                                 l_return_val);
        IF NOT(l_return_val) THEN
            l_pos_ref_meaning := l_pos_ref_code;
        END IF;

        --Building the error message
        FND_MESSAGE.Set_Name('AHL','AHL_UC_NOTASSIGN_MANDATORY');
        FND_MESSAGE.Set_Token('POSN_REF',l_pos_ref_meaning);

        --Writing the message to the error table
        IF (p_x_error_table.COUNT >0) THEN
           p_x_error_table(p_x_error_table.LAST+1) := FND_MESSAGE.get;
        ELSE
           p_x_error_table(0) := FND_MESSAGE.get;
        END IF;

        x_evaluation_status := FND_API.G_FALSE;

        --Now fetch the mandatory descendents of the mandatory position
        OPEN get_mand_pos_desc_csr(l_miss_rel_id);
        LOOP
          FETCH get_mand_pos_desc_csr INTO l_pos_ref_code;
          EXIT WHEN get_mand_pos_desc_csr%NOTFOUND;

          AHL_UTIL_MC_PKG.Convert_To_LookupMeaning('AHL_POSITION_REFERENCE',
                                                  l_pos_ref_code,
                                                  l_pos_ref_meaning,
                                                  l_return_val);
          IF NOT(l_return_val) THEN
             l_pos_ref_meaning := l_pos_ref_code;
          END IF;

          --Building the error message
          FND_MESSAGE.Set_Name('AHL','AHL_UC_NOTASSIGN_MANDATORY');
          FND_MESSAGE.Set_Token('POSN_REF',l_pos_ref_meaning);

          --Writing the message to the error table
           IF (p_x_error_table.COUNT >0) THEN
            p_x_error_table(p_x_error_table.LAST+1) := FND_MESSAGE.get;
          ELSE
           p_x_error_table(0) := FND_MESSAGE.get;
          END IF;

        END LOOP;
	CLOSE get_mand_pos_desc_csr;

    END LOOP; -- End of missing mandatory nodes
    CLOSE check_mand_child_missing_csr;

 END LOOP;
 CLOSE get_unit_tree_csr;

  --Completed Processing

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => l_api_name,
                               p_error_text     => SQLERRM);

      FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);
END List_Missing_Positions;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
-- This procedure adds a Quantity specific message to the Error Table.
PROCEDURE Add_Qty_Message(p_position_ref_code IN     VARCHAR2,
                          p_inst_qty          IN     NUMBER,
                          p_qty_less_flag     IN     VARCHAR2,
                          p_x_error_table     IN OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type) IS

l_return_val      BOOLEAN DEFAULT TRUE;
l_pos_ref_code    fnd_lookups.lookup_code%TYPE;
l_pos_ref_meaning fnd_lookups.meaning%TYPE;

BEGIN
  AHL_UTIL_MC_PKG.Convert_To_LookupMeaning('AHL_POSITION_REFERENCE',
                                           p_position_ref_code,
                                           l_pos_ref_meaning,
                                           l_return_val);
  IF NOT(l_return_val) THEN
    l_pos_ref_meaning := p_position_ref_code;
  END IF;
  -- Build the error message
  IF (p_qty_less_flag = 'Y') THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_UC_POS_QTY_LESS');
  ELSE
    FND_MESSAGE.Set_Name('AHL', 'AHL_UC_POS_QTY_MORE');
  END IF;
  FND_MESSAGE.Set_Token('POSN_REF', l_pos_ref_meaning);
  --Writing the message to the error table
  IF (p_x_error_table.COUNT > 0) THEN
    p_x_error_table(p_x_error_table.LAST + 1) := FND_MESSAGE.get;
  ELSE
    p_x_error_table(0) := FND_MESSAGE.get;
  END IF;

END Add_Qty_Message;

-- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 05-Dec-2007
-- This function checks if a Quantity type rule exists for the given instance's position
-- p_instance_id is the Parent Instance and is used to derive the Position Path to Rule Existence Check.
-- It returns 'Y' if a rule exists and 'N' if not.
FUNCTION Quantity_Rule_Exists(p_instance_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR rule_exists_csr IS
  SELECT distinct rul.rule_id, rul.rule_name, rul.mc_header_id
  FROM AHL_MC_RULES_B rul, AHL_MC_RULE_STATEMENTS rst,
       AHL_APPLICABLE_INSTANCES ap
   WHERE  rst.rule_id = rul.rule_id
     AND rul.rule_type_code = 'MANDATORY'
     AND rst.subject_type = 'POSITION'
     AND rst.subject_id =  ap.position_id
     AND rst.object_type = 'TOT_CHILD_QUANTITY'
     AND rst.operator = 'MUST_HAVE'
     AND TRUNC(nvl(rul.ACTIVE_START_DATE, sysdate-1)) <= TRUNC(sysdate)
     AND TRUNC(nvl(rul.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

  --check that the instance is installed in a UC derived from the Rule's MC_HEADER_ID
  CURSOR check_inst_in_uc_ofmc_csr(c_csi_instance_id IN NUMBER, c_mc_header_id IN NUMBER) IS
  SELECT uch.csi_item_instance_id
   FROM ahl_unit_config_headers uch
   WHERE uch.master_config_id = c_mc_header_id
   AND uch.csi_item_instance_id = c_csi_instance_id
  UNION ALL
  SELECT csi_ii.object_id
    FROM csi_ii_relationships csi_ii
    WHERE csi_ii.object_id IN
    (SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
          WHERE trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
            AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
      AND  master_config_id = c_mc_header_id)
    START WITH csi_ii.subject_id = c_csi_instance_id
      AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
      AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
      AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    CONNECT BY csi_ii.subject_id = PRIOR csi_ii.object_id
      AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
      AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
      AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);

  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_path_position_id  NUMBER;
  l_rule_id           NUMBER;
  l_rule_name         AHL_MC_RULES_B.RULE_NAME%TYPE;
  l_rule_uc_top_inst_id NUMBER;
  l_ret_val           VARCHAR2(1) DEFAULT 'N';
  l_mc_header_id      NUMBER;
  L_DEBUG_KEY         VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.Quantity_Rule_Exists';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                   'At the start of the function, p_instance_id = ' || p_instance_id);
  END IF;
  EXECUTE IMMEDIATE 'DELETE FROM AHL_APPLICABLE_INSTANCES';
  -- Get all the Position Paths associated with the instance p_instance_id into AHL_APPLICABLE_INSTANCES.
  -- If there is a configuration like A.1-B.1-C.1 and path positions exist for C.1, B.1-C.1, A.1-B.1-C.1 all these
  -- will be picked up after the call below
  AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Positions(p_api_version => 1.0,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         p_csi_item_instance_id => p_instance_id);

  -- Check that a quantity rule exists at the installed poisition
  /*
    1. The rule_exists_csr returns all the rules for each of the path position applicable to the instance. Consider the case where
    a rule is defined for the position A.1-B.1-C.1 and it is NON-version specific for all the segments.
    For a case like A.2-B.2-C.2, the rule_exists_csr returns records. But this rule is actually applicable only to
    A.1-B.X-C.X. We check in the check_inst_in_uc_ofmc_csr that the instance under examination is derived from an UC got from an MC for which the rule is defined.

    2. Additionally, say we have a rule 'RULE1' defined at B.1-C.X and a rule RULE2 defined at C.1 (as NON version specific)
    RULE1 will be applicable for B.1-C.2, but RULE2 will not be applicable to B.1-C.2
    But rule_exists_csr, will return both of the above rules when looking at B.1-C.2. But check_inst_in_uc_ofmc_csr will filter out
    RULE2 as we want.
  */
  OPEN rule_exists_csr;
  LOOP
    FETCH rule_exists_csr INTO l_rule_id, l_rule_name, l_mc_header_id;
    EXIT WHEN rule_exists_csr%NOTFOUND;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                    'Quantity Type Rule Exists: l_rule_id: ' || l_rule_id ||
                    ', l_mc_header_id: ' || l_mc_header_id ||
                    ', l_rule_name: ' || l_rule_name);
    END IF;

    OPEN check_inst_in_uc_ofmc_csr(p_instance_id, l_mc_header_id);
    FETCH check_inst_in_uc_ofmc_csr INTO l_rule_uc_top_inst_id;

    --Verify that the rule is applicable to currently installed instance
    IF (check_inst_in_uc_ofmc_csr%FOUND) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                      'Rule is applicable to the UC top instance: l_rule_uc_top_inst_id: ' || l_rule_uc_top_inst_id);
      END IF;
      l_ret_val := 'Y';
      CLOSE check_inst_in_uc_ofmc_csr;
      --It is enough if there exists at least one quantity rule for the position.
      EXIT;
    END IF;
    CLOSE check_inst_in_uc_ofmc_csr;
  END LOOP;
  CLOSE rule_exists_csr;

  IF (l_ret_val = 'N') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Quantity Rule does not exist?');
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
                   'At the end of the function, About to return ' || l_ret_val);
  END IF;
  RETURN l_ret_val;
END Quantity_Rule_Exists;

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name      : Validate_Position_Quantities
--  Type                : Private
--  Function            : This procedure was added for the FP OGMA Issue 105 to support Non Serialized Items.
--                        It validates the instance quantity against the position/item group.
--                        If there is a Quantity type rule at the Parent position, the floor validation
--                        is not done (Only ceiling validation is done). Since in this case the Rule
--                        overrides and obviates any need for Quantity validation and validating quantity
--                        based on position may actually contradict the rule.
--
--  Pre-reqs
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Validate_Position_Quantities Parameters :
--  p_uc_header_id                      IN      NUMBER     Conditionally Required
--                   The header id of the unit configuration. Not required if p_csi_instance_id is given.
--  p_csi_instance_id                   IN      NUMBER     Conditionally Required
--                   The instance where the Quantity needs to be checked.  Not required if p_uc_header_id is given.
--  x_evaluation_status                 OUT     VARCHAR2   The flag which indicates whether the unit has any Quantity mismatch.
--  p_x_error_table                     IN OUT  AHL_UC_POS_NECES_PVT.Error_Tbl_Type
--                   The output table with the list of Quantity based validation failures
--
--  History:
--    05-Dec-2007       SATHAPLI       Created
--
--  Version:
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Validate_Position_Quantities(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_TRUE,
  p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_uc_header_id          IN            NUMBER,
  p_csi_instance_id       IN            NUMBER,
  p_x_error_table         IN OUT NOCOPY AHL_UC_VALIDATION_PUB.Error_Tbl_Type,
  x_evaluation_status     OUT NOCOPY    VARCHAR2) IS

-- Validate the UC and get the top instance
  CURSOR get_uc_header_rec_csr IS
   SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
    WHERE unit_config_header_id = p_uc_header_id
      AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
      AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

-- Get all leaf non-extra nodes and do not get sub-config root nodes, as these do not need the position quantity validation.
-- Also such instances are inflection points for which get_pos_dtls_csr will not return any records.
  CURSOR get_unit_tree_csr(c_csi_instance_id IN NUMBER) IS
   SELECT c_csi_instance_id FROM dual
    WHERE NOT EXISTS (SELECT 1
                        FROM csi_ii_relationships
                       WHERE object_id = c_csi_instance_id
                         AND relationship_type_code = 'COMPONENT-OF'
                         AND trunc(nvl(active_start_date, sysdate-1)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      UNION ALL
                      SELECT 1
                        FROM ahl_unit_config_headers
                       WHERE csi_item_instance_id = c_csi_instance_id
                         AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
   UNION ALL
   SELECT OUTER.subject_id
     FROM csi_ii_relationships OUTER
    WHERE NOT EXISTS (SELECT 1
                        FROM csi_ii_relationships
                       WHERE object_id = OUTER.subject_id
                         AND relationship_type_code = 'COMPONENT-OF'
                         AND trunc(nvl(active_start_date, sysdate-1)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      UNION ALL
                      SELECT 1
                        FROM ahl_unit_config_headers
                       WHERE csi_item_instance_id = OUTER.subject_id
                         AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
    START WITH object_id = c_csi_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND position_reference is not null
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND position_reference is not null;

-- Get the Relationship of the instance
  CURSOR get_pos_ref_reln_csr(c_csi_instance_id IN NUMBER) IS
   SELECT TO_NUMBER(position_reference)
    FROM csi_ii_relationships csi
   WHERE position_reference is not null
     AND subject_id = c_csi_instance_id
     AND relationship_type_code = 'COMPONENT-OF'
     AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
     AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

-- Get the Position Quantity Details
  CURSOR get_pos_dtls_csr(c_mc_relationship_id IN NUMBER,
                          c_instance_id        IN NUMBER) IS
   SELECT iasso.quantity Itm_qty,
          iasso.uom_code Itm_uom_code,
          iasso.revision Itm_revision,
          iasso.item_association_id,
          reln.quantity Posn_qty,
          reln.uom_code Posn_uom_code,
          reln.parent_relationship_id,
          reln.position_ref_code,
          csi.INVENTORY_ITEM_ID,
          csi.QUANTITY Inst_qty,
          csi.UNIT_OF_MEASURE Inst_uom_code,
          (select object_id from csi_ii_relationships
            where subject_id = c_instance_id
              and relationship_type_code = 'COMPONENT-OF'
              and trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
              and trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))) parent_instance_id
     FROM ahl_mc_relationships reln, ahl_item_associations_b iasso, csi_item_instances csi
    WHERE csi.INSTANCE_ID = c_instance_id
      AND reln.relationship_id = c_mc_relationship_id
      AND iasso.item_group_id = reln.item_group_id
      AND iasso.inventory_item_id = CSI.INVENTORY_ITEM_ID
      AND (iasso.revision IS NULL OR iasso.revision = CSI.INVENTORY_REVISION)
      AND iasso.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
      AND trunc(nvl(reln.active_start_date, sysdate)) <= trunc(sysdate)
      AND trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate);

  l_pos_dtls_rec      get_pos_dtls_csr%ROWTYPE;

  L_DEBUG_KEY         CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.Validate_Position_Quantities';
  L_API_VERSION       CONSTANT NUMBER := 1.0;
  L_API_NAME          CONSTANT VARCHAR2(30) := 'Validate_Position_Quantities';
  TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_parent_rule_tbl   T_ID_TBL;
  l_top_instance_id   NUMBER;
  l_csi_ii_id         NUMBER;
  l_rel_id            NUMBER;
  l_rule_exists_flag  VARCHAR2(1);
  l_quantity          NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                   'At the start of the procedure, p_csi_instance_id = ' || p_csi_instance_id ||
                   ', p_uc_header_id = ' || p_uc_header_id ||
                   ', p_x_error_table.COUNT = ' || p_x_error_table.COUNT);
  END IF;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION, p_api_version, L_API_NAME,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  x_evaluation_status := FND_API.G_TRUE;

  -- Call procedure to validate the uc header id
  IF (p_csi_instance_id IS NOT NULL AND p_uc_header_id IS NULL) THEN
    l_top_instance_id := p_csi_instance_id;
  ELSE
    OPEN get_uc_header_rec_csr;
    FETCH get_uc_header_rec_csr INTO l_top_instance_id;
    IF (get_uc_header_rec_csr%NOTFOUND) THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
      FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
      FND_MSG_PUB.add;
      CLOSE get_uc_header_rec_csr;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_uc_header_rec_csr;
  END IF;

  OPEN get_unit_tree_csr(l_top_instance_id);
  LOOP
    FETCH get_unit_tree_csr into l_csi_ii_id;
    EXIT WHEN get_unit_tree_csr%NOTFOUND;

    l_rel_id := NULL;
    OPEN get_pos_ref_reln_csr(l_csi_ii_id);
    FETCH get_pos_ref_reln_csr INTO l_rel_id;
    CLOSE get_pos_ref_reln_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                     'Checking Quantity for Instance ' || l_csi_ii_id ||
                     ', l_rel_id = ' || l_rel_id);
    END IF;
    IF (l_rel_id IS NOT NULL) THEN
      OPEN get_pos_dtls_csr(c_mc_relationship_id => l_rel_id,
                            c_instance_id        => l_csi_ii_id);
      FETCH get_pos_dtls_csr INTO l_pos_dtls_rec;
      CLOSE get_pos_dtls_csr;

      IF (l_pos_dtls_rec.Itm_qty IS NULL OR l_pos_dtls_rec.Itm_qty = 0) THEN
        -- Pick the Quantity and UOM from Position level.
        l_pos_dtls_rec.Itm_qty      := l_pos_dtls_rec.Posn_qty;
        l_pos_dtls_rec.Itm_uom_code := l_pos_dtls_rec.Posn_uom_code;
      END IF;

      IF (l_pos_dtls_rec.Itm_uom_code <> l_pos_dtls_rec.Inst_uom_code) THEN
        -- UOMs are different: Convert Item UOM Qty to Inst UOM Qty
        l_quantity := inv_convert.inv_um_convert(item_id       => l_pos_dtls_rec.INVENTORY_ITEM_ID,
                                                 precision     => 6,
                                                 from_quantity => l_pos_dtls_rec.Itm_qty,
                                                 from_unit     => l_pos_dtls_rec.Itm_uom_code,
                                                 to_unit       => l_pos_dtls_rec.Inst_uom_code,
                                                 from_name     => NULL,
                                                 to_name       => NULL);
        l_pos_dtls_rec.Itm_qty := l_quantity;
        l_pos_dtls_rec.Itm_uom_code := l_pos_dtls_rec.Inst_uom_code;
      END IF;

      -- Now Compare and Validate the Quantities
      IF (l_pos_dtls_rec.Inst_qty = l_pos_dtls_rec.Itm_qty) THEN
        -- Quantity matches: Don't raise error
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                        'Quantities Match: ' || l_pos_dtls_rec.Itm_qty);
        END IF;
      ELSIF (l_pos_dtls_rec.Inst_qty > l_pos_dtls_rec.Itm_qty) THEN
        -- Instance Quantity can never be greater the Position quantity: Throw error
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Instance Qty (' || l_pos_dtls_rec.Inst_qty || ') > Position Quantity (' || l_pos_dtls_rec.Itm_qty || ')');
        END IF;
        Add_Qty_Message(p_position_ref_code => l_pos_dtls_rec.position_ref_code,
                        p_inst_qty          => l_pos_dtls_rec.Inst_qty,
                        p_qty_less_flag     => 'N',  -- Quantity is more
                        p_x_error_table     => p_x_error_table);
        x_evaluation_status := FND_API.G_FALSE;

      ELSE
        -- Instance Quantity is less than Position Quantity
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Need to check for rules: Instance Qty (' || l_pos_dtls_rec.Inst_qty || ') < Position Quantity (' || l_pos_dtls_rec.Itm_qty || ')');
        END IF;

        -- Check l_parent_rule_tbl to see if an entry exists for the index l_pos_dtls_rec.parent_relationship_id
        IF (NOT (l_parent_rule_tbl.EXISTS(l_pos_dtls_rec.parent_instance_id))) THEN
          -- No entry exists in l_parent_rule_tbl
          l_rule_exists_flag := Quantity_Rule_Exists(p_instance_id => l_pos_dtls_rec.parent_instance_id);
          IF (l_rule_exists_flag = 'Y') THEN
            l_parent_rule_tbl(l_pos_dtls_rec.parent_instance_id) := 1;
            -- Ignore the quantity shortage.
          ELSE
            l_parent_rule_tbl(l_pos_dtls_rec.parent_instance_id) := -1;
          END IF;
        END IF;  -- NOT of l_parent_rule_tbl.EXISTS

        -- Raise error only if there is no Quantity Rule at Parent position
        IF (l_parent_rule_tbl(l_pos_dtls_rec.parent_instance_id) > 0) THEN
          -- A 'Quantity type' rule exists at the parent position: Ignore the quantity shortage.
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'Quantity Rule Exists. So not throwing error.');
          END IF;
        ELSE
          -- No 'Quantity type' rule exists at the parent position. So raise a validation error
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'Quantity Rule Does not Exist. So throwing error.');
          END IF;
          Add_Qty_Message(p_position_ref_code => l_pos_dtls_rec.position_ref_code,
                          p_inst_qty          => l_pos_dtls_rec.Inst_qty,
                          p_qty_less_flag     => 'Y',  -- Quantity is less
                          p_x_error_table     => p_x_error_table);
          x_evaluation_status := FND_API.G_FALSE;
        END IF;  -- l_parent_rule_tbl entry is +ve or -ve
      END IF; -- Inst_qty checks
    END IF;  -- l_rel_id IS NOT NULL
  END LOOP; -- All leaf non-extra nodes
  CLOSE get_unit_tree_csr;

  -- Completed Processing

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
                   'At the end of the procedure, About to return x_evaluation_status as ' || x_evaluation_status ||
                   ', p_x_error_table.COUNT = ' || p_x_error_table.COUNT);
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Validate_Position_Quantities;

--------------------------------------------------------------------------------------------
--  Start of Comments  --
--
--  Procedure name      : Check_Position_Quantities
--  Type                : Private
--  Function            : This procedure was added for the FP OGMA Issue 105 to support Non Serialized Items.
--                        It checks the instance quantity against the position/item group.
--                        If there is a Quantity type rule at the Parent position, the floor check
--                        is not done (Only ceiling check is done). Since in this case the Rule
--                        overrides and obviates any need for Quantity check and checking quantity
--                        based on position may actually contradict the rule.
--
--  Pre-reqs
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                      Required
--      p_init_msg_list                 IN      VARCHAR2                    Default  FND_API.G_TRUE
--      p_validation_level              IN      NUMBER                      Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2                    Required
--      x_msg_count                     OUT     NUMBER                      Required
--      x_msg_data                      OUT     VARCHAR2                    Required
--
--  Check_Position_Quantities Parameters :
--  p_uc_header_id                      IN      NUMBER                      Required
--                   The header id of the unit configuration.
--  x_evaluation_status                 OUT     VARCHAR2   The OUT flag which indicates whether the unit has any Quantity mismatch.
--
--  History:
--    05-Dec-2007       SATHAPLI       Created
--
--  Version:
--      Initial Version   1.0
--
--  End of Comments.
--------------------------------------------------------------------------------------------

PROCEDURE Check_Position_Quantities(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_TRUE,
  p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_uc_header_id          IN            NUMBER,
  x_evaluation_status     OUT NOCOPY    VARCHAR2) IS

-- Validate the UC and get the top instance
  CURSOR get_uc_header_rec_csr IS
   SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
    WHERE unit_config_header_id = p_uc_header_id
      AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
      AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

-- Get all leaf non-extra nodes and do not get sub-config root nodes, as these do not need the position quantity validation.
-- Also such instances are inflection points for which get_pos_dtls_csr will not return any records.
  CURSOR get_unit_tree_csr(c_csi_instance_id IN NUMBER) IS
   SELECT c_csi_instance_id FROM dual
    WHERE NOT EXISTS (SELECT 1
                        FROM csi_ii_relationships
                       WHERE object_id = c_csi_instance_id
                         AND relationship_type_code = 'COMPONENT-OF'
                         AND trunc(nvl(active_start_date, sysdate-1)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      UNION ALL
                      SELECT 1
                        FROM ahl_unit_config_headers
                       WHERE csi_item_instance_id = c_csi_instance_id
                         AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
   UNION ALL
   SELECT OUTER.subject_id
     FROM csi_ii_relationships OUTER
    WHERE NOT EXISTS (SELECT 1
                        FROM csi_ii_relationships
                       WHERE object_id = OUTER.subject_id
                         AND relationship_type_code = 'COMPONENT-OF'
                         AND trunc(nvl(active_start_date, sysdate-1)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      UNION ALL
                      SELECT 1
                        FROM ahl_unit_config_headers
                       WHERE csi_item_instance_id = OUTER.subject_id
                         AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
                         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
    START WITH object_id = c_csi_instance_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND position_reference is not null
    CONNECT BY PRIOR subject_id = object_id
        AND relationship_type_code = 'COMPONENT-OF'
        AND trunc(nvl(active_start_date,sysdate-1)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND position_reference is not null;

-- Get the Relationship of the instance
  CURSOR get_pos_ref_reln_csr(c_csi_instance_id IN NUMBER) IS
   SELECT TO_NUMBER(position_reference)
    FROM csi_ii_relationships csi
   WHERE position_reference is not null
     AND subject_id = c_csi_instance_id
     AND relationship_type_code = 'COMPONENT-OF'
     AND trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
     AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

-- Get the Position Quantity Details
  CURSOR get_pos_dtls_csr(c_mc_relationship_id IN NUMBER,
                          c_instance_id        IN NUMBER) IS
   SELECT iasso.quantity Itm_qty,
          iasso.uom_code Itm_uom_code,
          iasso.revision Itm_revision,
          iasso.item_association_id,
          reln.quantity Posn_qty,
          reln.uom_code Posn_uom_code,
          reln.parent_relationship_id,
          reln.position_ref_code,
          csi.INVENTORY_ITEM_ID,
          csi.QUANTITY Inst_qty,
          csi.UNIT_OF_MEASURE Inst_uom_code,
          (select object_id from csi_ii_relationships
            where subject_id = c_instance_id
              and relationship_type_code = 'COMPONENT-OF'
              and trunc(nvl(active_start_date, sysdate)) <= trunc(sysdate)
              and trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))) parent_instance_id
     FROM ahl_mc_relationships reln, ahl_item_associations_b iasso, csi_item_instances csi
    WHERE csi.INSTANCE_ID = c_instance_id
      AND reln.relationship_id = c_mc_relationship_id
      AND iasso.item_group_id = reln.item_group_id
      AND iasso.inventory_item_id = CSI.INVENTORY_ITEM_ID
      AND (iasso.revision IS NULL OR iasso.revision = CSI.INVENTORY_REVISION)
      AND iasso.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
      AND trunc(nvl(reln.active_start_date, sysdate)) <= trunc(sysdate)
      AND trunc(nvl(reln.active_end_date, sysdate+1)) > trunc(sysdate);

  l_pos_dtls_rec      get_pos_dtls_csr%ROWTYPE;

  L_DEBUG_KEY         CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.Check_Position_Quantities';
  L_API_VERSION       CONSTANT NUMBER := 1.0;
  L_API_NAME          CONSTANT VARCHAR2(30) := 'Check_Position_Quantities';
  TYPE T_ID_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_parent_rule_tbl   T_ID_TBL;
  l_top_instance_id   NUMBER;
  l_csi_ii_id         NUMBER;
  l_rel_id            NUMBER;
  l_rule_exists_flag  VARCHAR2(1);
  l_quantity          NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin',
                   'At the start of the procedure, p_uc_header_id = ' || p_uc_header_id);
  END IF;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION, p_api_version, L_API_NAME,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  x_evaluation_status := FND_API.G_TRUE;

  -- Call procedure to validate the uc header id
  OPEN get_uc_header_rec_csr;
  FETCH get_uc_header_rec_csr INTO l_top_instance_id;
  IF (get_uc_header_rec_csr%NOTFOUND) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
    FND_MESSAGE.set_token('UC_HEADER_ID', p_uc_header_id);
    FND_MSG_PUB.add;
    CLOSE get_uc_header_rec_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_uc_header_rec_csr;

  OPEN get_unit_tree_csr(l_top_instance_id);
  LOOP
    FETCH get_unit_tree_csr into l_csi_ii_id;
    EXIT WHEN get_unit_tree_csr%NOTFOUND;

    l_rel_id := NULL;
    OPEN get_pos_ref_reln_csr(l_csi_ii_id);
    FETCH get_pos_ref_reln_csr INTO l_rel_id;
    CLOSE get_pos_ref_reln_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                     'Checking Quantity for Instance ' || l_csi_ii_id ||
                     ', l_rel_id = ' || l_rel_id);
    END IF;
    IF (l_rel_id IS NOT NULL) THEN
      OPEN get_pos_dtls_csr(c_mc_relationship_id => l_rel_id,
                            c_instance_id        => l_csi_ii_id);
      FETCH get_pos_dtls_csr INTO l_pos_dtls_rec;
      CLOSE get_pos_dtls_csr;

      IF (l_pos_dtls_rec.Itm_qty IS NULL OR l_pos_dtls_rec.Itm_qty = 0) THEN
        -- Pick the Quantity and UOM from Position level.
        l_pos_dtls_rec.Itm_qty      := l_pos_dtls_rec.Posn_qty;
        l_pos_dtls_rec.Itm_uom_code := l_pos_dtls_rec.Posn_uom_code;
      END IF;

      IF (l_pos_dtls_rec.Itm_uom_code <> l_pos_dtls_rec.Inst_uom_code) THEN
        -- UOMs are different: Convert Item UOM Qty to Inst UOM Qty
        l_quantity := inv_convert.inv_um_convert(item_id       => l_pos_dtls_rec.INVENTORY_ITEM_ID,
                                                 precision     => 6,
                                                 from_quantity => l_pos_dtls_rec.Itm_qty,
                                                 from_unit     => l_pos_dtls_rec.Itm_uom_code,
                                                 to_unit       => l_pos_dtls_rec.Inst_uom_code,
                                                 from_name     => NULL,
                                                 to_name       => NULL);
        l_pos_dtls_rec.Itm_qty := l_quantity;
        l_pos_dtls_rec.Itm_uom_code := l_pos_dtls_rec.Inst_uom_code;
      END IF;

      -- Now Compare and Validate the Quantities
      IF (l_pos_dtls_rec.Inst_qty = l_pos_dtls_rec.Itm_qty) THEN
        -- Quantity matches: Don't raise error
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Quantities Match: ' || l_pos_dtls_rec.Itm_qty);
        END IF;
      ELSIF (l_pos_dtls_rec.Inst_qty > l_pos_dtls_rec.Itm_qty) THEN
        -- Instance Quantity can never be greater the Position quantity: Return error
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Exiting Early: Instance Qty (' || l_pos_dtls_rec.Inst_qty || ') > Position Quantity (' || l_pos_dtls_rec.Itm_qty || ')');
        END IF;
        x_evaluation_status := FND_API.G_FALSE;
        EXIT; -- No need to process remaining instances
      ELSE
        -- Instance Quantity is less than Position Quantity
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                         'Need to check for rules: Instance Qty (' || l_pos_dtls_rec.Inst_qty || ') < Position Quantity (' || l_pos_dtls_rec.Itm_qty || ')');
        END IF;
        -- Raise error only if there is no Quantity Rule at Parent position
        -- Check l_parent_rule_tbl to see if an entry exists for the index l_pos_dtls_rec.parent_relationship_id
        IF (NOT(l_parent_rule_tbl.EXISTS(l_pos_dtls_rec.parent_instance_id))) THEN
          -- No entry exists in l_parent_rule_tbl
          l_rule_exists_flag := Quantity_Rule_Exists(p_instance_id => l_pos_dtls_rec.parent_instance_id);
          IF (l_rule_exists_flag = 'Y') THEN
            l_parent_rule_tbl(l_pos_dtls_rec.parent_instance_id) := 1;
          ELSE
            l_parent_rule_tbl(l_pos_dtls_rec.parent_instance_id) := -1;
          END IF;
        END IF;  -- NOT of l_parent_rule_tbl entry exists

        IF (l_parent_rule_tbl(l_pos_dtls_rec.parent_instance_id) > 0) THEN
          -- A 'Quantity type' rule exists at the parent position: Ignore the quantity shortage.
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'Quantity Rule Exists. So not throwing error.');
          END IF;
        ELSE
          -- No 'Quantity type' rule exists at the parent position. So return a validation error
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,
                           'Early Exit: Quantity Rule Does not Exist. So throwing error.');
          END IF;
          x_evaluation_status := FND_API.G_FALSE;
          EXIT; -- No need to process remaining instances
        END IF;  -- l_parent_rule_tbl entry is +ve or -ve
      END IF; -- Inst_qty checks
    END IF;  -- l_rel_id IS NOT NULL
  END LOOP; -- All leaf non-extra nodes
  CLOSE get_unit_tree_csr;

  -- Completed Processing

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end',
                   'At the end of the procedure, About to return x_evaluation_status as ' || x_evaluation_status);
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                            p_procedure_name => l_api_name,
                            p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Check_Position_Quantities;

END AHL_UC_POS_NECES_PVT;

/
