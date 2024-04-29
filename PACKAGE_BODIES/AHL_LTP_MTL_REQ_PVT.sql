--------------------------------------------------------
--  DDL for Package Body AHL_LTP_MTL_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_MTL_REQ_PVT" AS
/* $Header: AHLVLMRB.pls 120.1.12010000.4 2009/10/27 22:15:48 jaramana ship $ */

-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_LTP_MTL_REQ_PVT';

G_LOG_PREFIX        CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_LTP_MTL_REQ_PVT';

G_NO_FLAG           CONSTANT VARCHAR2(1)  := 'N';
G_YES_FLAG          CONSTANT VARCHAR2(1)  := 'Y';

G_APP_MODULE        CONSTANT VARCHAR2(30) := 'AHL';

-- Mtl Req Association Types
G_ASSOC_TYPE_DISPOSITION    CONSTANT VARCHAR2(30) := 'DISPOSITION';
G_ASSOC_TYPE_ROUTE          CONSTANT VARCHAR2(30) := 'ROUTE';
G_ASSOC_TYPE_OPERATION      CONSTANT VARCHAR2(30) := 'OPERATION';

-- Requirement Types
G_REQ_TYPE_FORECAST         CONSTANT VARCHAR2(30) := 'FORECAST';
G_REQ_TYPE_PLANNED          CONSTANT VARCHAR2(30) := 'PLANNED';

-- Mapping Status for Position
G_MAPPING_STATUS_MATCH      CONSTANT VARCHAR2(30) := 'MATCH';
G_MAPPING_STATUS_EMPTY      CONSTANT VARCHAR2(30) := 'EMPTY';
G_MAPPING_STATUS_NA         CONSTANT VARCHAR2(30) := 'NA';

-- Added by skpathak on 06-NOV-2008 for bug-7336824
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_ERROR           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_EVENT           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

-------------------------------------------
-- Declare Local Procedures and Function --
-------------------------------------------

  -- This Procedure validates the input for the Get_Route_Mtl_Req API
  PROCEDURE Validate_Mtl_Req_Input(
     p_route_id          IN         NUMBER,
     p_mr_route_id       IN         NUMBER,
     p_item_instance_id  IN         NUMBER,
     p_requirement_date  IN         DATE,
     p_request_type      IN         VARCHAR2,
     x_route_id          OUT NOCOPY NUMBER);

  -- This Procedure gets the requirements from the Disposition List
  PROCEDURE Get_Disp_List_Requirements(
     p_route_id          IN         NUMBER,
     p_item_instance_id  IN         NUMBER,
     p_requirement_date  IN         DATE,
     p_request_type      IN         VARCHAR2,
     p_unit_instance_id  IN         NUMBER,
     p_inst_item_id      IN         NUMBER,
     p_mc_header_id      IN         NUMBER,
     p_mc_id             IN         NUMBER,
     p_mc_version        IN         NUMBER,
     x_disp_req_list     OUT NOCOPY Route_Mtl_Req_Tbl_Type);

  -- This Procedure gets the Position Path Requirement
  PROCEDURE Get_Pos_Path_Requirement(
     p_position_path_id  IN         NUMBER,
     p_requirement_date  IN         DATE,
     p_unit_instance_id  IN         NUMBER,
     p_mc_header_id      IN         NUMBER,
     p_mc_id             IN         NUMBER,
     p_mc_version        IN         NUMBER,
     p_rt_oper_mtl_id    IN         NUMBER,
     p_quantity          IN         NUMBER,
     p_uom               IN         VARCHAR2,
     p_x_disp_req_list   IN OUT NOCOPY Route_Mtl_Req_Tbl_Type);

  -- This Procedure gets the requirements from the Route (or Operation)
  PROCEDURE Get_Route_Requirements(
     p_route_id          IN         NUMBER,
     p_request_type      IN         VARCHAR2,
     x_route_req_list    OUT NOCOPY Route_Mtl_Req_Tbl_Type);

  -- This Procedure validates a Position Path against a given unit and date.
  -- It returns a status flag and if valid, it get the details about the position.
  PROCEDURE Validate_Path_Position(
     p_path_position_id          IN  NUMBER,
     p_unit_instance_id          IN  NUMBER,
     p_requirement_date          IN  DATE,
     x_valid_flag                OUT NOCOPY VARCHAR2,
     x_relationship_id           OUT NOCOPY NUMBER,
     x_item_group_id             OUT NOCOPY NUMBER,
     x_pos_instance_id           OUT NOCOPY NUMBER);

  -- This Function gets the unit's instance id
  FUNCTION Get_Unit_Instance(
     p_item_instance_id IN NUMBER) RETURN NUMBER;


-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

-----------------------------------------
-- Public Procedure Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Get_Route_Mtl_Req
--  Type              : Private
--  Function          : Private API to get the Material requirements for a Route.
--                      For FORECAST request type, it aggregates requirements at the
--                      route level (across operations), and gets the highest priority item
--                      ignoring the inventory org. Also, a disposition list requirement is
--                      considered for FORECAST only if the REPLACE_PERCENT = 100%.
--                      For PLANNED, no aggregation is done, NO specific item is obtained
--                      within an item group and the REPLACE_PERCENT is not considered.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Route_Mtl_Req Parameters:
--      p_route_id                      IN      NUMBER       Not Required only if p_mr_route_id is not null
--         The Id of Route for which to determine the material requirements
--      p_mr_route_id                   IN      NUMBER       Not Required only if p_route_id is not null
--         The Id of MR Route for which to determine the material requirements
--      p_item_instance_id              IN      NUMBER       Required
--         The Id of Instance for which to plan the material requirements
--      p_requirement_date              IN      DATE         Not Required
--         The date when the materials are required. If provided, the positions of Master Configs
--         (for position path based disposition list requirement) are validated against this date.
--      p_request_type                  IN      VARCHAR2     Required
--         Should be either 'FORECAST' or 'PLANNED'
--      x_route_mtl_req_tbl             OUT     AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl  Required
--         The Table of records containing the material requirements for the route
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_Route_Mtl_Req
(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT  NOCOPY   VARCHAR2,
   x_msg_count             OUT  NOCOPY   NUMBER,
   x_msg_data              OUT  NOCOPY   VARCHAR2,
   p_route_id              IN            NUMBER,
   p_mr_route_id           IN            NUMBER,
   p_item_instance_id      IN            NUMBER,
   p_requirement_date      IN            DATE      := null,
   p_request_type          IN            VARCHAR2,
   x_route_mtl_req_tbl     OUT  NOCOPY   AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type) IS

  CURSOR get_mc_dtls_csr(c_instance_id IN NUMBER) IS
    select UC.MASTER_CONFIG_ID, MC.MC_ID, MC.VERSION_NUMBER
    from AHL_UNIT_CONFIG_HEADERS UC, AHL_MC_HEADERS_B MC
    where UC.CSI_ITEM_INSTANCE_ID = c_instance_id AND
          MC.MC_HEADER_ID = UC.MASTER_CONFIG_ID;

  CURSOR get_item_from_instance_csr(c_instance_id IN NUMBER) IS
    select INVENTORY_ITEM_ID from CSI_ITEM_INSTANCES
    where INSTANCE_ID = c_instance_id;

  CURSOR get_item_group_item_csr(c_item_group_id IN NUMBER) IS
    SELECT inventory_item_id, inventory_org_id
    FROM ahl_item_associations_b
    WHERE item_group_id = c_item_group_id
      AND interchange_type_code in ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
    ORDER BY priority;

   l_route_id              NUMBER;
   l_unit_instance_id      NUMBER;
   l_inst_item_id          NUMBER;
   l_mc_header_id          NUMBER;
   l_mc_id                 NUMBER;
   l_mc_version            NUMBER;
   l_disp_req_list         AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type;
   l_route_req_list        AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type;
   l_index                 NUMBER;
   l_temp_item_id          NUMBER;
   l_temp_ig_id            NUMBER;
   l_found                 BOOLEAN;
   l_api_version  CONSTANT NUMBER := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'Get_Route_Mtl_Req';
   L_DEBUG_KEY    CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Route_Mtl_Req';

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Input values for the Procedure: ' ||
                                                         'p_route_id = ' || p_route_id ||
                                                         ', p_mr_route_id = ' || p_mr_route_id ||
                                                         ', p_item_instance_id = ' || p_item_instance_id ||
                                                         ', p_requirement_date = ' || p_requirement_date ||
                                                         ', p_request_type = ' || p_request_type);
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Begin Processing
  -- First Validate the input parameters
  Validate_Mtl_Req_Input(p_route_id         => p_route_id,
                         p_mr_route_id      => p_mr_route_id,
                         p_item_instance_id => p_item_instance_id,
                         p_requirement_date => p_requirement_date,
                         p_request_type     => p_request_type,
                         x_route_id         => l_route_id);

  IF (FND_MSG_PUB.Count_Msg > 0) THEN
    -- There are validation errors: Raise error
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get the Unit Instance
  l_unit_instance_id := Get_Unit_Instance(p_item_instance_id);
  IF (l_unit_instance_id IS NOT NULL) THEN
    -- Instance is in a UC: Get the MC Details
    OPEN get_mc_dtls_csr(c_instance_id => l_unit_instance_id);
    FETCH get_mc_dtls_csr INTO l_mc_header_id, l_mc_id, l_mc_version;
    CLOSE get_mc_dtls_csr;
  END IF;

  -- Get item of instance
  OPEN get_item_from_instance_csr(c_instance_id => p_item_instance_id);
  FETCH get_item_from_instance_csr INTO l_inst_item_id;
  CLOSE get_item_from_instance_csr;

  -- Get the Requirements from the Disposition List
  Get_Disp_List_Requirements(p_route_id         => l_route_id,
                             p_item_instance_id => p_item_instance_id,
                             p_requirement_date => p_requirement_date,
                             p_request_type     => p_request_type,
                             p_unit_instance_id => l_unit_instance_id,
                             p_inst_item_id     => l_inst_item_id,
                             p_mc_header_id     => l_mc_header_id,
                             p_mc_id            => l_mc_id,
                             p_mc_version       => l_mc_version,
                             x_disp_req_list    => l_disp_req_list);

  -- Get the Requirements from the Route
  Get_Route_Requirements(p_route_id         => l_route_id,
                         p_request_type     => p_request_type,
                         x_route_req_list   => l_route_req_list);

  -- Merge the two list of requirements
  IF (l_disp_req_list.COUNT = 0) THEN
    x_route_mtl_req_tbl := l_route_req_list;
  ELSIF (l_route_req_list.COUNT = 0) THEN
    x_route_mtl_req_tbl := l_disp_req_list;
  ELSE
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'l_disp_req_list.COUNT = ' || l_disp_req_list.COUNT);
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'l_route_req_list.COUNT = ' || l_route_req_list.COUNT);
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Both lists are non-empty. Merging...');
    END IF;
    x_route_mtl_req_tbl := l_disp_req_list;
    l_index := x_route_mtl_req_tbl.COUNT;
    FOR i in l_route_req_list.FIRST .. l_route_req_list.LAST LOOP
      l_temp_item_id := NVL(l_route_req_list(i).INVENTORY_ITEM_ID, -1);
      l_temp_ig_id := NVL(l_route_req_list(i).ITEM_GROUP_ID, -1);
      l_found := FALSE;
      FOR j in l_disp_req_list.FIRST .. l_disp_req_list.LAST LOOP
        IF ((NVL(l_disp_req_list(j).INVENTORY_ITEM_ID, -2) = l_temp_item_id) OR
            (NVL(l_disp_req_list(j).ITEM_GROUP_ID, -2) = l_temp_ig_id)) THEN
          -- The route requirement exists in the Disposition list also
          l_found := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF(l_found = FALSE) THEN
        -- Add this Route requirement to the combined list
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Adding Route requirement with index ' || i ||
                                                               ' to the combined list.');
        END IF;
        l_index := l_index + 1;
        x_route_mtl_req_tbl(l_index) := l_route_req_list(i);
      ELSE
        -- Duplicate: Ignore
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Route requirement with index ' || i || ' is a duplicate. Ignoring.');
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Size of the merged list: ' || x_route_mtl_req_tbl.COUNT);
  END IF;

  -- Get the first item for item groups if forecasting
  IF(x_route_mtl_req_tbl.COUNT > 0 AND p_request_type = G_REQ_TYPE_FORECAST) THEN
    FOR i in x_route_mtl_req_tbl.FIRST .. x_route_mtl_req_tbl.LAST LOOP
      IF (x_route_mtl_req_tbl(i).INVENTORY_ITEM_ID IS NULL AND
          x_route_mtl_req_tbl(i).ITEM_GROUP_ID IS NOT NULL) THEN
        -- Get the highest prority item from the item group
        OPEN get_item_group_item_csr(c_item_group_id => x_route_mtl_req_tbl(i).ITEM_GROUP_ID);
        FETCH get_item_group_item_csr INTO x_route_mtl_req_tbl(i).INVENTORY_ITEM_ID,
                                           x_route_mtl_req_tbl(i).INV_MASTER_ORG_ID;
        CLOSE get_item_group_item_csr;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'For merged requirement ' || i ||
                                                               ', Got Item Id as ' || x_route_mtl_req_tbl(i).INVENTORY_ITEM_ID ||
                                                               ' for item group id ' || x_route_mtl_req_tbl(i).ITEM_GROUP_ID);
        END IF;
      END IF;
    END LOOP;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

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
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Route_Mtl_Req',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Get_Route_Mtl_Req;

--------------------------------------
-- End Public Procedure Definitions --
--------------------------------------

-----------------------------------------
-- Public Function Definitions follow --
-----------------------------------------
-- Start of Comments --
--  Function name     : Get_Primary_UOM_Qty
--  Type              : Private
--  Function          : Private helper function to convert a quantity of an item from one
--                      UOM to the Primary UOM. The inputs are the item id, the quantity
--                      and the source UOM. The output is the quantity in the primary uom.
--  Pre-reqs    :
--  Parameters  :
--
--
--  Get_Primary_UOM_Qty Parameters:
--      p_inventory_item_id             IN      NUMBER       Required
--         The Id of Inventory item. If this is null, this function returns null.
--      p_source_uom_code               IN      VARCHAR2     Required
--         The code of the UOM in which the quantity is currently mentioned.
--         If this is null, this function returns null.
--      p_quantity                      IN      NUMBER       Required
--         The quantity of the item in the indicated UOM.
--         If this is null, this function returns null.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

FUNCTION Get_Primary_UOM_Qty(p_inventory_item_id IN NUMBER,
                             p_source_uom_code IN VARCHAR2,
                             p_quantity IN NUMBER) RETURN NUMBER IS

  CURSOR get_primary_uom_csr IS
    select primary_uom_code from mtl_system_items
    where inventory_item_id = p_inventory_item_id;

  l_primary_uom VARCHAR2(10);
  l_converted_qty NUMBER;
  L_DEBUG_KEY    CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Primary_UOM_Qty';

BEGIN
  IF (p_inventory_item_id IS NULL OR p_source_uom_code IS NULL OR p_quantity IS NULL) THEN
    RETURN NULL;
  END IF;
  OPEN get_primary_uom_csr;
  FETCH get_primary_uom_csr INTO l_primary_uom;
  IF (get_primary_uom_csr%NOTFOUND) THEN
    CLOSE get_primary_uom_csr;
    RETURN null;
  END IF;
  CLOSE get_primary_uom_csr;
  IF(p_source_uom_code = l_primary_uom) THEN
    RETURN p_quantity;
  END IF;

  l_converted_qty := inv_convert.inv_um_convert(item_id => p_inventory_item_id,
                                                precision => 2,
                                                from_quantity => p_quantity,
                                                from_unit => p_source_uom_code,
                                                to_unit => l_primary_uom,
                                                from_name => null,
                                                to_name => null);
  IF (l_converted_qty < 0) THEN
    l_converted_qty := null;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Could not convert from ' || p_source_uom_code ||
                                                           ' to ' || l_primary_uom || '. Returning null quantity.');
    END IF;
  END IF;
  RETURN l_converted_qty;
END Get_Primary_UOM_Qty;

-- Start of Comments --
--  Function name     : Get_Primary_UOM
--  Type              : Private
--  Function          : Private helper function to get the Primary UOM of an item
--                      The inputs are the item id and the inventory org id.
--  Pre-reqs    :
--  Parameters  :
--
--
--  Get_Primary_UOM Parameters:
--      p_inventory_item_id             IN      NUMBER       Required
--         The Id of Inventory item. If this is null, this function returns null.
--      p_inventory_org_id              IN      NUMBER       Required
--         The inventory org id of the item. If this is null, this function returns null.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

FUNCTION Get_Primary_UOM
(
   p_inventory_item_id     IN  NUMBER,
   p_inventory_org_id      IN  NUMBER
) RETURN VARCHAR2 IS
  CURSOR get_primary_uom_csr IS
    select primary_uom_code from mtl_system_items
    where inventory_item_id = p_inventory_item_id and
          organization_id = p_inventory_org_id;

  l_primary_uom VARCHAR2(10);
  L_DEBUG_KEY    CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Primary_UOM';

BEGIN
  IF (p_inventory_item_id IS NULL OR p_inventory_org_id IS NULL) THEN
    RETURN NULL;
  END IF;
  OPEN get_primary_uom_csr;
  FETCH get_primary_uom_csr INTO l_primary_uom;
  IF (get_primary_uom_csr%NOTFOUND) THEN
    CLOSE get_primary_uom_csr;
    RETURN null;
  END IF;
  CLOSE get_primary_uom_csr;
  RETURN l_primary_uom;
END Get_Primary_UOM;

-------------------------------------
-- End Public Function Definitions --
-------------------------------------

----------------------------------------
-- Local Procedure Definitions follow --
----------------------------------------
----------------------------------------------------------------------
-- This Procedure validates the input for the Get_Route_Mtl_Req API --
----------------------------------------------------------------------
PROCEDURE Validate_Mtl_Req_Input
(
   p_route_id          IN         NUMBER,
   p_mr_route_id       IN         NUMBER,
   p_item_instance_id  IN         NUMBER,
   p_requirement_date  IN         DATE,
   p_request_type      IN         VARCHAR2,
   x_route_id          OUT NOCOPY NUMBER) IS

  CURSOR get_route_id_csr IS
    select route_id from ahl_mr_routes
    where mr_route_id = p_mr_route_id;

  CURSOR validate_route_id_csr(c_route_id IN NUMBER) IS
-- Changes by skpathak on 06-NOV-2008 for bug-7336824
--    select 'x' from AHL_ROUTES_APP_V
    select 'x' from AHL_ROUTES_B
    where route_id = c_route_id;

  CURSOR validate_instance_id_csr IS
    select 'x' from CSI_ITEM_INSTANCES
    where instance_id = p_item_instance_id
      and nvl(active_end_date, sysdate + 1) > sysdate;

   l_dummy                VARCHAR2(1);
   L_DEBUG_KEY   CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Validate_Mtl_Req_Input';

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the Route Id
  IF (p_route_id IS NULL AND p_mr_route_id IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_ROUTE_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSIF (p_route_id IS NULL) THEN
    OPEN get_route_id_csr;
    FETCH get_route_id_csr INTO x_route_id;
    CLOSE get_route_id_csr;
  ELSE
    x_route_id := p_route_id;
  END IF;

  -- Validate the Route Id
  OPEN validate_route_id_csr(c_route_id => x_route_id);
  FETCH validate_route_id_csr INTO l_dummy;
  IF (validate_route_id_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_ROUTE_ID_INVALID');
    FND_MESSAGE.Set_Token('ROUTE_ID', x_route_id);
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  END IF;
  CLOSE validate_route_id_csr;

  -- Validate the Instance Id
  IF (p_item_instance_id IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_INST_ID_NULL');
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSE
    OPEN validate_instance_id_csr;
    FETCH validate_instance_id_csr INTO l_dummy;
    IF (validate_instance_id_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_INST_ID_INVALID');
      FND_MESSAGE.Set_Token('INST_ID', p_item_instance_id);
      FND_MSG_PUB.ADD;
      IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE validate_instance_id_csr;
  END IF;

  -- Validate the Request Type
  IF (p_request_type IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_REQ_TYPE_NULL');
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  ELSIF (p_request_type NOT IN (G_REQ_TYPE_FORECAST, G_REQ_TYPE_PLANNED)) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_REQ_TYPE_INVALID');
    FND_MESSAGE.Set_Token('REQ_TYPE', p_request_type);
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
  END IF;

  -- Validate the Requirement Date
  IF (p_requirement_date IS NULL) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_REQ_DATE_NULL');
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    -- SKPATHAK :: Bug 8343599 :: 13-APR-2009
    -- Removing the check to allow creation of Material Requirements in the past.
    /**
  ELSIF (TRUNC(p_requirement_date) < TRUNC(SYSDATE)) THEN
    FND_MESSAGE.Set_Name('AHL', 'AHL_LTP_APS_REQ_DATE_PAST');
    FND_MESSAGE.Set_Token('REQ_DATE', p_requirement_date);
    FND_MSG_PUB.ADD;
    IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(G_LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    **/
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Validate_Mtl_Req_Input;

--------------------------------------------------------------------
-- This Procedure gets the requirements from the Disposition List --
--------------------------------------------------------------------
PROCEDURE Get_Disp_List_Requirements
(
   p_route_id          IN         NUMBER,
   p_item_instance_id  IN         NUMBER,
   p_requirement_date  IN         DATE,
   p_request_type      IN         VARCHAR2,
   p_unit_instance_id  IN         NUMBER,
   p_inst_item_id      IN         NUMBER,
   p_mc_header_id      IN         NUMBER,
   p_mc_id             IN         NUMBER,
   p_mc_version        IN         NUMBER,
   x_disp_req_list     OUT NOCOPY Route_Mtl_Req_Tbl_Type) IS

  CURSOR get_mc_route_eff_id_csr IS
    SELECT RE.route_effectivity_id
    FROM AHL_ROUTE_EFFECTIVITIES RE
    WHERE RE.route_id = p_route_id
     AND (RE.mc_header_id = NVL(p_mc_header_id, -1)  -- Match MC Header Id first
          OR (RE.mc_id = NVL(p_mc_id, -1)            -- Match MC Id next
              AND RE.mc_header_id IS NULL   -- Added on 10/28/03 since Version specific also has stores the MC Id
              AND NOT EXISTS (SELECT 'x' FROM AHL_ROUTE_EFFECTIVITIES RE1
                              WHERE RE1.route_id = p_route_id
                                AND RE1.mc_header_id = NVL(p_mc_header_id, -1))
             )
         );

  CURSOR get_item_route_eff_id_csr IS
    SELECT RE.route_effectivity_id
    FROM AHL_ROUTE_EFFECTIVITIES RE
    WHERE RE.route_id = p_route_id
      AND RE.inventory_item_id = p_inst_item_id;  -- Match the inventory item id

  CURSOR get_disp_req_dtls_csr(c_mc_route_eff_id   IN NUMBER,
                               c_item_route_eff_id IN NUMBER) IS
    SELECT ROM.RT_OPER_MATERIAL_ID,
           ROM.INVENTORY_ITEM_ID,
           ROM.INVENTORY_ORG_ID,
           ROM.UOM_CODE,
           ROM.QUANTITY,
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(INVENTORY_ITEM_ID, UOM_CODE, QUANTITY) AS PRIMARY_QUANTITY,
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(INVENTORY_ITEM_ID, INVENTORY_ORG_ID) AS PRIMARY_UOM_CODE,
           ITEM_GROUP_ID,
           ITEM_COMP_DETAIL_ID,
           POSITION_PATH_ID,
           PP.PATH_POS_COMMON_ID,
           PP.VER_SPEC_SCORE
    FROM AHL_RT_OPER_MATERIALS ROM, AHL_MC_PATH_POSITIONS PP
    WHERE OBJECT_ID in (NVL(c_mc_route_eff_id, -1), NVL(c_item_route_eff_id, -1)) AND
          ROM.POSITION_PATH_ID = PP.PATH_POSITION_ID (+) AND
          ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_DISPOSITION AND
          ((REPLACE_PERCENT = 100 AND p_request_type = G_REQ_TYPE_FORECAST) OR
           (p_request_type = G_REQ_TYPE_PLANNED)
          )
    ORDER BY PATH_POS_COMMON_ID, VER_SPEC_SCORE DESC;

  CURSOR get_item_comp_dtls_csr(c_item_comp_detail_id IN NUMBER,
                                c_quantity            IN NUMBER,
                                c_uom                 IN VARCHAR2) IS
    SELECT ICD.inventory_item_id, ICD.inventory_master_org_id, ICD.item_group_id,
           DECODE(ICD.inventory_item_id, null, c_quantity, AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(ICD.inventory_item_id, c_uom, c_quantity)) QUANTITY,
           DECODE(ICD.inventory_item_id, null, c_uom, AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(ICD.inventory_item_id, inventory_master_org_id)) UOM
    FROM AHL_ITEM_COMP_DETAILS ICD
    WHERE ITEM_COMP_DETAIL_ID = c_item_comp_detail_id;

   l_mc_route_effectivity_id    NUMBER;
   l_item_route_effectivity_id  NUMBER;
   l_index                      NUMBER;
   l_last_common_id             NUMBER := -1;
   l_prior_count                NUMBER;
   L_DEBUG_KEY   CONSTANT       VARCHAR2(150) := G_LOG_PREFIX || '.Get_Disp_List_Requirements';

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the Route Effectivity
  OPEN get_mc_route_eff_id_csr;
  FETCH get_mc_route_eff_id_csr INTO l_mc_route_effectivity_id;
  IF (get_mc_route_eff_id_csr%NOTFOUND) THEN
    l_mc_route_effectivity_id := -1;
  END IF;
  CLOSE get_mc_route_eff_id_csr;

  OPEN get_item_route_eff_id_csr;
  FETCH get_item_route_eff_id_csr INTO l_item_route_effectivity_id;
  IF (get_item_route_eff_id_csr%NOTFOUND) THEN
    l_item_route_effectivity_id := -1;
  END IF;
  CLOSE get_item_route_eff_id_csr;

  IF(l_item_route_effectivity_id = -1 AND l_mc_route_effectivity_id = -1) THEN
    -- No Disposition List available
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'No disposition list found for MC Header Id: ' || p_mc_header_id
                                                            || ', MC Id: ' || p_mc_id
                                                            || ', Item Id: ' || p_inst_item_id);
    END IF;
    RETURN;
  END IF;

  l_index := 0;
  FOR l_disp_req_rec IN get_disp_req_dtls_csr(c_mc_route_eff_id   => l_mc_route_effectivity_id,
                                              c_item_route_eff_id => l_item_route_effectivity_id) LOOP
    l_index := l_index + 1;
    IF ((l_disp_req_rec.INVENTORY_ITEM_ID IS NOT NULL) AND (l_disp_req_rec.ITEM_COMP_DETAIL_ID IS NULL)) THEN
      -- Simple Item requirement with no reference to any Item composition
      x_disp_req_list(l_index).RT_OPER_MATERIAL_ID := l_disp_req_rec.RT_OPER_MATERIAL_ID;
      x_disp_req_list(l_index).INVENTORY_ITEM_ID := l_disp_req_rec.INVENTORY_ITEM_ID;
      x_disp_req_list(l_index).INV_MASTER_ORG_ID := l_disp_req_rec.INVENTORY_ORG_ID;
      -- Quantity in Item's Primary UOM
      x_disp_req_list(l_index).QUANTITY := l_disp_req_rec.PRIMARY_QUANTITY;
      x_disp_req_list(l_index).UOM_CODE := l_disp_req_rec.PRIMARY_UOM_CODE;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || l_disp_req_rec.RT_OPER_MATERIAL_ID ||
                                                             ', INVENTORY_ITEM_ID = ' || l_disp_req_rec.INVENTORY_ITEM_ID ||
                                                             ', INV_MASTER_ORG_ID = ' || l_disp_req_rec.INVENTORY_ORG_ID ||
                                                             ', QUANTITY = ' || l_disp_req_rec.PRIMARY_QUANTITY ||
                                                             ', UOM_CODE = ' || l_disp_req_rec.PRIMARY_UOM_CODE);
      END IF;
    ELSIF ((l_disp_req_rec.ITEM_GROUP_ID IS NOT NULL) AND (l_disp_req_rec.ITEM_COMP_DETAIL_ID IS NULL)) THEN
      -- Simple Item Group requirement with no reference to any Item composition
      x_disp_req_list(l_index).RT_OPER_MATERIAL_ID := l_disp_req_rec.RT_OPER_MATERIAL_ID;
      x_disp_req_list(l_index).ITEM_GROUP_ID := l_disp_req_rec.ITEM_GROUP_ID;
      x_disp_req_list(l_index).QUANTITY := l_disp_req_rec.QUANTITY;
      x_disp_req_list(l_index).UOM_CODE := l_disp_req_rec.UOM_CODE;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || l_disp_req_rec.RT_OPER_MATERIAL_ID ||
                                                             ', ITEM_GROUP_ID = ' || l_disp_req_rec.ITEM_GROUP_ID ||
                                                             ', QUANTITY = ' || l_disp_req_rec.QUANTITY ||
                                                             ', UOM_CODE = ' || l_disp_req_rec.UOM_CODE);
      END IF;
    ELSIF (l_disp_req_rec.ITEM_COMP_DETAIL_ID IS NOT NULL) THEN
      -- Item Composition requirement
      x_disp_req_list(l_index).RT_OPER_MATERIAL_ID := l_disp_req_rec.RT_OPER_MATERIAL_ID;
      x_disp_req_list(l_index).ITEM_COMP_DETAIL_ID := l_disp_req_rec.ITEM_COMP_DETAIL_ID;
      -- Get the details from the Item Composition Details table
      OPEN get_item_comp_dtls_csr(c_item_comp_detail_id => l_disp_req_rec.ITEM_COMP_DETAIL_ID,
                                  c_quantity            => l_disp_req_rec.QUANTITY,
                                  c_uom                 => l_disp_req_rec.UOM_CODE);
      FETCH get_item_comp_dtls_csr INTO x_disp_req_list(l_index).INVENTORY_ITEM_ID,
                                        x_disp_req_list(l_index).INV_MASTER_ORG_ID,
                                        x_disp_req_list(l_index).ITEM_GROUP_ID,
                                        x_disp_req_list(l_index).QUANTITY,
                                        x_disp_req_list(l_index).UOM_CODE;
      CLOSE get_item_comp_dtls_csr;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || l_disp_req_rec.RT_OPER_MATERIAL_ID ||
                                                             ', ITEM_COMP_DETAIL_ID = ' || l_disp_req_rec.ITEM_COMP_DETAIL_ID ||
                                                             ', INVENTORY_ITEM_ID = ' || x_disp_req_list(l_index).INVENTORY_ITEM_ID ||
                                                             ', INV_MASTER_ORG_ID = ' || x_disp_req_list(l_index).INV_MASTER_ORG_ID ||
                                                             ', ITEM_GROUP_ID = ' || x_disp_req_list(l_index).ITEM_GROUP_ID ||
                                                             ', QUANTITY = ' || x_disp_req_list(l_index).QUANTITY ||
                                                             ', UOM_CODE = ' || x_disp_req_list(l_index).UOM_CODE);
      END IF;
    ELSE
      -- Requirement with only Position path reference
      IF (p_mc_header_id IS NULL) THEN
        -- Ignore this Position Path specific requirement since the current instance
        -- is not a UC unit (is not of any MC type)
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Ignoring Disp. List Requirement with Position Path Id ' || l_disp_req_rec.POSITION_PATH_ID);
        END IF;
      ELSE
        -- Get the Position Path requirement if applicable
        IF (l_disp_req_rec.PATH_POS_COMMON_ID <> l_last_common_id) THEN
          -- Consider this Position Path since it is has a new common id
          l_prior_count := x_disp_req_list.COUNT;
          Get_Pos_Path_Requirement(p_position_path_id => l_disp_req_rec.POSITION_PATH_ID,
                                   p_requirement_date => p_requirement_date,
                                   p_unit_instance_id => p_unit_instance_id,
                                   p_mc_header_id     => p_mc_header_id,
                                   p_mc_id            => p_mc_id,
                                   p_mc_version       => p_mc_version,
                                   p_rt_oper_mtl_id   => l_disp_req_rec.RT_OPER_MATERIAL_ID,
                                   p_quantity         => l_disp_req_rec.QUANTITY,
                                   p_uom              => l_disp_req_rec.UOM_CODE,
                                   p_x_disp_req_list  => x_disp_req_list);
          IF (x_disp_req_list.COUNT > l_prior_count) THEN
            -- The last Position Path requirement was valid and added.
            -- Set the l_last_common_id so that subsequent records
            -- with the same common id (but lower score) can be ignored.
            l_last_common_id := l_disp_req_rec.PATH_POS_COMMON_ID;
          ELSE
            -- Not applicable: Hence not added: Continue to the next lower score.
            null;
          END IF;  -- if count has increased
        ELSE
          -- Common id is same as last added, but lower score: ignore this record
          null;
        END IF;  -- Common Id is different
      END IF;
      l_index := x_disp_req_list.COUNT;  -- Set output table index to always point to the last added record.
    END IF;
  END LOOP;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Total number of disposition requirements: ' || x_disp_req_list.COUNT);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Get_Disp_List_Requirements;

-------------------------------------------------------
-- This Procedure gets the Position Path Requirement --
-------------------------------------------------------
PROCEDURE Get_Pos_Path_Requirement
(
   p_position_path_id  IN         NUMBER,
   p_requirement_date  IN         DATE,
   p_unit_instance_id  IN         NUMBER,
   p_mc_header_id      IN         NUMBER,
   p_mc_id             IN         NUMBER,
   p_mc_version        IN         NUMBER,
   p_rt_oper_mtl_id    IN         NUMBER,
   p_quantity          IN         NUMBER,
   p_uom               IN         VARCHAR2,
   p_x_disp_req_list   IN OUT NOCOPY Route_Mtl_Req_Tbl_Type) IS

  CURSOR get_sub_unit_mc_csr(c_pos_instance_id IN NUMBER) IS
    SELECT master_config_id
    FROM AHL_UNIT_CONFIG_HEADERS
    WHERE CSI_ITEM_INSTANCE_ID = c_pos_instance_id;

  CURSOR get_item_grp_for_mc_csr(c_mc_header_id IN NUMBER) IS
    SELECT item_group_id
    FROM AHL_MC_RELATIONSHIPS
    WHERE mc_header_id = c_mc_header_id
      AND parent_relationship_id is null;

  CURSOR get_sub_mc_for_pos_csr(c_position_id IN NUMBER) IS
    SELECT CR.mc_header_id
    FROM AHL_MC_CONFIG_RELATIONS CR, AHL_MC_HEADERS_B MC
    WHERE CR.relationship_id = c_position_id
      AND MC.mc_header_id = CR.mc_header_id
    ORDER BY MC.name;

   l_position_id           NUMBER;
   l_pos_item_group_id     NUMBER;
   l_pos_instance_id       NUMBER;
   l_sub_unit_mc           NUMBER;
   l_next_index            NUMBER := p_x_disp_req_list.COUNT + 1;
   l_valid_flag            VARCHAR2(1);
   L_DEBUG_KEY   CONSTANT  VARCHAR2(150) := G_LOG_PREFIX || '.Get_Pos_Path_Requirement';

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- First validate the Position Path and get the Position Details
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling Validate_Path_Position with ' ||
                                                         'p_position_path_id = ' || p_position_path_id ||
                                                         ', p_unit_instance_id = ' || p_unit_instance_id ||
                                                         ', p_requirement_date = ' || p_requirement_date);
  END IF;
  Validate_Path_Position(p_path_position_id => p_position_path_id,
                         p_unit_instance_id => p_unit_instance_id,
                         p_requirement_date => p_requirement_date,
                         x_valid_flag       => l_valid_flag,
                         x_relationship_id  => l_position_id,
                         x_item_group_id    => l_pos_item_group_id,
                         x_pos_instance_id  => l_pos_instance_id);

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Validate_Path_Position returned ' ||
                                                         'x_valid_flag = ' || l_valid_flag ||
                                                         ', x_relationship_id = ' || l_position_id ||
                                                         ', x_item_group_id = ' || l_pos_item_group_id ||
                                                         ', x_pos_instance_id = ' || l_pos_instance_id);
  END IF;

  IF (l_valid_flag = FND_API.G_FALSE) THEN
    -- Don't include the requirement if the position path is not valid
    RETURN;
  END IF;

  IF (l_pos_instance_id IS NULL) THEN
    -- The position is empty
    -- If the position has an item group associated, copy that as the requirement
    IF (l_pos_item_group_id IS NOT NULL) THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Position ' || l_position_id || ' is empty and has item group ' ||
                                                              l_pos_item_group_id || ' associated with it.');
      END IF;
      p_x_disp_req_list(l_next_index).ITEM_GROUP_ID := l_pos_item_group_id;
    ELSE
      -- No Item group for the empty position: Pick one Sub config for the position
      OPEN get_sub_mc_for_pos_csr(c_position_id => l_position_id);
      FETCH get_sub_mc_for_pos_csr INTO l_sub_unit_mc;
      CLOSE get_sub_mc_for_pos_csr;
      -- Get the Item group for the root node of the chosen Sub MC
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Chosen Sub MC Header Id ' || l_sub_unit_mc ||
                                                             ' for empty position with id ' || l_position_id);
      END IF;
      OPEN get_item_grp_for_mc_csr(c_mc_header_id => l_sub_unit_mc);
      FETCH get_item_grp_for_mc_csr INTO p_x_disp_req_list(l_next_index).ITEM_GROUP_ID;
      CLOSE get_item_grp_for_mc_csr;
    END IF;
  ELSE
    -- The position is not empty
    -- Check if the position corresponds to the root node
    IF (l_pos_instance_id <> p_unit_instance_id) THEN
      -- Not root node: Check if a sub-unit is installed in the position
      OPEN get_sub_unit_mc_csr(c_pos_instance_id => l_pos_instance_id);
      FETCH get_sub_unit_mc_csr INTO l_sub_unit_mc;
      IF(get_sub_unit_mc_csr%FOUND) THEN
        -- A sub unit (UC) is installed in the position
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Sub unit with Sub MC Header Id ' || l_sub_unit_mc ||
                                                               ' installed at position with id ' || l_position_id);
        END IF;
        -- Get the Item group for the root node of the Sub unit's MC
        OPEN get_item_grp_for_mc_csr(c_mc_header_id => l_sub_unit_mc);
        FETCH get_item_grp_for_mc_csr INTO p_x_disp_req_list(l_next_index).ITEM_GROUP_ID;
        CLOSE get_item_grp_for_mc_csr;
      ELSE
        -- An instance (not a sub unit) is installed in the position
        -- Add this position's item group as requirement to the list
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Simple instance with id ' || l_pos_instance_id ||
                                                                 ' installed at position with id ' || l_position_id);
        END IF;
        p_x_disp_req_list(l_next_index).ITEM_GROUP_ID := l_pos_item_group_id;
      END IF;  -- Sub unit or instance
      CLOSE get_sub_unit_mc_csr;
    ELSE
      -- Root Node
      -- Add the item group requirement to the list
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Position Id ' || l_position_id || ' corresponds to the root node.');
      END IF;
      p_x_disp_req_list(l_next_index).ITEM_GROUP_ID := l_pos_item_group_id;
    END IF;  -- Root node or not
  END IF;  -- Position is empty or not

  -- Copy the remaining attributes
  p_x_disp_req_list(l_next_index).RT_OPER_MATERIAL_ID := p_rt_oper_mtl_id;
  p_x_disp_req_list(l_next_index).POSITION_PATH_ID := p_position_path_id;
  p_x_disp_req_list(l_next_index).RELATIONSHIP_ID := l_position_id;
  p_x_disp_req_list(l_next_index).QUANTITY := p_quantity;
  p_x_disp_req_list(l_next_index).UOM_CODE := p_uom;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_next_index || ': RT_OPER_MATERIAL_ID = ' || p_rt_oper_mtl_id ||
                                                         ', ITEM_GROUP_ID = ' || p_x_disp_req_list(l_next_index).ITEM_GROUP_ID ||
                                                         ', POSITION_PATH_ID = ' || p_position_path_id ||
                                                         ', RELATIONSHIP_ID = ' || l_position_id ||
                                                         ', QUANTITY = ' || p_quantity ||
                                                         ', UOM_CODE = ' || p_uom);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Get_Pos_Path_Requirement;

------------------------------------------------------------------------
-- This Procedure gets the requirements from the Route (or Operation) --
------------------------------------------------------------------------
PROCEDURE Get_Route_Requirements
(
   p_route_id          IN         NUMBER,
   p_request_type      IN         VARCHAR2,
   x_route_req_list    OUT NOCOPY Route_Mtl_Req_Tbl_Type) IS

  CURSOR get_route_level_reqs_csr IS
    SELECT ROM.RT_OPER_MATERIAL_ID,
           NULL AS ROUTE_OPERATION_ID,
           ROM.INVENTORY_ITEM_ID,
           ROM.INVENTORY_ORG_ID,
           ROM.QUANTITY,
           ROM.UOM_CODE,
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(INVENTORY_ITEM_ID, UOM_CODE, QUANTITY) AS PRIMARY_QUANTITY,
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(INVENTORY_ITEM_ID, INVENTORY_ORG_ID) AS PRIMARY_UOM_CODE,
           ROM.ITEM_GROUP_ID
    FROM AHL_RT_OPER_MATERIALS ROM
    WHERE OBJECT_ID = p_route_id
    AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_ROUTE;

-- AnRaj : Start for fixing perf bug 4919527
/*
  CURSOR get_op_level_reqs_csr IS
    --SELECT NULL AS RT_OPER_MATERIAL_ID,
           --NULL AS ROUTE_OPERATION_ID,
    -- support for Oracle 8
    SELECT TO_NUMBER(NULL) AS RT_OPER_MATERIAL_ID,
           TO_NUMBER(NULL) AS ROUTE_OPERATION_ID,
           INVENTORY_ITEM_ID,
           INVENTORY_ORG_ID,
           -- Aggregate item quantities across operations when forecasting
           SUM(AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(INVENTORY_ITEM_ID, UOM_CODE, QUANTITY)) AS QUANTITY, --Total Primary Qty
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(INVENTORY_ITEM_ID, INVENTORY_ORG_ID) AS UOM_CODE,
           -- support for Oracle 8
           --NULL AS ITEM_GROUP_ID
           TO_NUMBER(NULL) AS ITEM_GROUP_ID
    FROM AHL_RT_OPER_MATERIALS ROM
    WHERE OBJECT_ID in (SELECT RO.operation_id
                        FROM ahl_operations_vl O, ahl_route_operations RO
                        WHERE O.operation_id = RO.operation_id and
                              RO.route_id = p_route_id and
                              O.revision_status_code = 'COMPLETE' and
                              O.revision_number in (SELECT max(revision_number)
                                                    FROM ahl_operations_b_kfv
                                                    WHERE concatenated_segments =
                                                      O.concatenated_segments and
                                                      trunc(sysdate) between
                                                      trunc(start_date_active) and
                                                      trunc(NVL(end_date_active,SYSDATE+1)))
                       )
      AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND INVENTORY_ITEM_ID IS NOT NULL
      AND p_request_type = G_REQ_TYPE_FORECAST
    GROUP BY INVENTORY_ITEM_ID, INVENTORY_ORG_ID
    UNION
    -- Don't aggregate for Operation items when Firm Planning
    SELECT RT_OPER_MATERIAL_ID,
           OBJECT_ID AS ROUTE_OPERATION_ID,
           INVENTORY_ITEM_ID,
           INVENTORY_ORG_ID,
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(INVENTORY_ITEM_ID, UOM_CODE, QUANTITY) AS QUANTITY, -- Primary Qty
           AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(INVENTORY_ITEM_ID, INVENTORY_ORG_ID) AS UOM_CODE,
           --NULL AS ITEM_GROUP_ID
           -- support for Oracle 8
           TO_NUMBER(NULL) AS ITEM_GROUP_ID
    FROM AHL_RT_OPER_MATERIALS ROM
    WHERE OBJECT_ID in (SELECT RO.operation_id
                        FROM ahl_operations_vl O, ahl_route_operations RO
                        WHERE O.operation_id = RO.operation_id and
                              RO.route_id = p_route_id and
                              O.revision_status_code = 'COMPLETE' and
                              O.revision_number in (SELECT max(revision_number)
                                                    FROM ahl_operations_b_kfv
                                                    WHERE concatenated_segments =
                                                      O.concatenated_segments and
                                                      trunc(sysdate) between
                                                      trunc(start_date_active) and
                                                      trunc(NVL(end_date_active,SYSDATE+1)))
                       )
      AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND INVENTORY_ITEM_ID IS NOT NULL
      AND p_request_type = G_REQ_TYPE_PLANNED
    UNION
    -- Item Group: No need to aggregate or convert to Primary UOM
    SELECT RT_OPER_MATERIAL_ID,
           OBJECT_ID AS ROUTE_OPERATION_ID,
           --NULL AS INVENTORY_ITEM_ID,
           --NULL AS INVENTORY_ORG_ID,
           -- support for Oracle 8
           TO_NUMBER(NULL) AS INVENTORY_ITEM_ID,
           TO_NUMBER(NULL) AS INVENTORY_ORG_ID,
           QUANTITY,
           UOM_CODE,
           ITEM_GROUP_ID
    FROM AHL_RT_OPER_MATERIALS ROM
    WHERE OBJECT_ID in (SELECT RO.operation_id
                        FROM ahl_operations_vl O, ahl_route_operations RO
                        WHERE O.operation_id = RO.operation_id and
                              RO.route_id = p_route_id and
                              O.revision_status_code = 'COMPLETE' and
                              O.revision_number in (SELECT max(revision_number)
                                                    FROM ahl_operations_b_kfv
                                                    WHERE concatenated_segments =
                                                      O.concatenated_segments and
                                                      trunc(sysdate) between
                                                      trunc(start_date_active) and
                                                      trunc(NVL(end_date_active,SYSDATE+1)))
                       )
      AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND INVENTORY_ITEM_ID IS NULL;*/

CURSOR get_op_level_reqs_forecast_csr IS
   SELECT   TO_NUMBER(NULL) AS RT_OPER_MATERIAL_ID,
            TO_NUMBER(NULL) AS ROUTE_OPERATION_ID,
            INVENTORY_ITEM_ID,
            INVENTORY_ORG_ID,
            -- Aggregate item quantities across operations when forecasting
            SUM(AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(INVENTORY_ITEM_ID, UOM_CODE, QUANTITY)) AS QUANTITY, /*Total Primary Qty */
            AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(INVENTORY_ITEM_ID, INVENTORY_ORG_ID) AS UOM_CODE,
            TO_NUMBER(NULL) AS ITEM_GROUP_ID
   FROM  AHL_RT_OPER_MATERIALS ROM
   WHERE OBJECT_ID in (    SELECT RO.operation_id
                           FROM AHL_OPERATIONS_B_KFV O, ahl_route_operations RO
                           WHERE O.operation_id = RO.operation_id and
                                 RO.route_id = p_route_id and
                                 O.revision_status_code = 'COMPLETE' and
                                 O.revision_number in (  SELECT max(revision_number)
                                                         FROM ahl_operations_b_kfv
                                                         WHERE concatenated_segments = O.concatenated_segments
                                                         and   trunc(sysdate) between
                                                               trunc(start_date_active) and
                                                               trunc(NVL(end_date_active,SYSDATE+1)))
                       )
   AND   ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
   AND   INVENTORY_ITEM_ID IS NOT NULL
   GROUP BY INVENTORY_ITEM_ID, INVENTORY_ORG_ID
   UNION
   SELECT RT_OPER_MATERIAL_ID,
           OBJECT_ID AS ROUTE_OPERATION_ID,
           TO_NUMBER(NULL) AS INVENTORY_ITEM_ID,
           TO_NUMBER(NULL) AS INVENTORY_ORG_ID,
           QUANTITY,
           UOM_CODE,
           ITEM_GROUP_ID
   FROM AHL_RT_OPER_MATERIALS ROM
   WHERE OBJECT_ID in ( SELECT RO.operation_id
                        FROM AHL_OPERATIONS_B_KFV O, ahl_route_operations RO
                        WHERE O.operation_id = RO.operation_id and
                              RO.route_id = p_route_id and
                              O.revision_status_code = 'COMPLETE' and
                              O.revision_number in (SELECT max(revision_number)
                                                    FROM ahl_operations_b_kfv
                                                    WHERE concatenated_segments = O.concatenated_segments
                                                    and
                                                      trunc(sysdate) between
                                                      trunc(start_date_active) and
                                                      trunc(NVL(end_date_active,SYSDATE+1)))
                       )
      AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND INVENTORY_ITEM_ID IS NULL;

CURSOR get_op_level_reqs_planned_csr IS
   SELECT   RT_OPER_MATERIAL_ID,
            OBJECT_ID AS ROUTE_OPERATION_ID,
            INVENTORY_ITEM_ID,
            INVENTORY_ORG_ID,
            AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM_Qty(INVENTORY_ITEM_ID, UOM_CODE, QUANTITY) AS QUANTITY, /* Primary Qty */
            AHL_LTP_MTL_REQ_PVT.Get_Primary_UOM(INVENTORY_ITEM_ID, INVENTORY_ORG_ID) AS UOM_CODE,
            TO_NUMBER(NULL) AS ITEM_GROUP_ID
   FROM     AHL_RT_OPER_MATERIALS ROM
   WHERE    OBJECT_ID in ( SELECT   RO.operation_id
                           FROM     AHL_OPERATIONS_B_KFV O, ahl_route_operations RO
                           WHERE    O.operation_id = RO.operation_id
                           and      RO.route_id = p_route_id
                           and      O.revision_status_code = 'COMPLETE'
                           and      O.revision_number in (  SELECT   max(revision_number)
                                                            FROM     ahl_operations_b_kfv
                                                            WHERE    concatenated_segments =O.concatenated_segments
                                                            and
                                                                     trunc(sysdate) between
                                                                     trunc(start_date_active) and
                                                                     trunc(NVL(end_date_active,SYSDATE+1)))
                        )
      AND   ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND   INVENTORY_ITEM_ID IS NOT NULL
   UNION
    -- Item Group: No need to aggregate or convert to Primary UOM
   SELECT   RT_OPER_MATERIAL_ID,
            OBJECT_ID AS ROUTE_OPERATION_ID,
            TO_NUMBER(NULL) AS INVENTORY_ITEM_ID,
            TO_NUMBER(NULL) AS INVENTORY_ORG_ID,
            QUANTITY,
            UOM_CODE,
            ITEM_GROUP_ID
   FROM     AHL_RT_OPER_MATERIALS ROM
   WHERE    OBJECT_ID in (SELECT RO.operation_id
                        FROM AHL_OPERATIONS_B_KFV O, ahl_route_operations RO
                        WHERE O.operation_id = RO.operation_id and
                              RO.route_id = p_route_id and
                              O.revision_status_code = 'COMPLETE' and
                              O.revision_number in (SELECT max(revision_number)
                                                    FROM ahl_operations_b_kfv
                                                    WHERE concatenated_segments = O.concatenated_segments
                                                    and
                                                      trunc(sysdate) between
                                                      trunc(start_date_active) and
                                                      trunc(NVL(end_date_active,SYSDATE+1)))
                       )
      AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND INVENTORY_ITEM_ID IS NULL;

CURSOR l_op_requirement_neither_csr IS
    SELECT RT_OPER_MATERIAL_ID,
           OBJECT_ID AS ROUTE_OPERATION_ID,
           TO_NUMBER(NULL) AS INVENTORY_ITEM_ID,
           TO_NUMBER(NULL) AS INVENTORY_ORG_ID,
           QUANTITY,
           UOM_CODE,
           ITEM_GROUP_ID
    FROM AHL_RT_OPER_MATERIALS ROM
    WHERE OBJECT_ID in (SELECT RO.operation_id
                        FROM AHL_OPERATIONS_B_KFV O, ahl_route_operations RO
                        WHERE O.operation_id = RO.operation_id and
                              RO.route_id = p_route_id and
                              O.revision_status_code = 'COMPLETE' and
                              O.revision_number in (SELECT max(revision_number)
                                                    FROM ahl_operations_b_kfv
                                                    WHERE concatenated_segments = O.concatenated_segments
                                                    and
                                                      trunc(sysdate) between
                                                      trunc(start_date_active) and
                                                      trunc(NVL(end_date_active,SYSDATE+1)))
                       )
      AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION
      AND INVENTORY_ITEM_ID IS NULL;
-- AnRaj : End for fixing perf bug 4919527

-- Added by jaramana on 22-OCT-2009 for bug 9037150
-- Use the following cursor to do a high level check for presence of operation level mtl requirements
CURSOR op_level_planned_reqs_exist IS
   SELECT ROM.RT_OPER_MATERIAL_ID
     FROM AHL_RT_OPER_MATERIALS ROM, AHL_ROUTE_OPERATIONS RO
    WHERE ROM.OBJECT_ID = RO.operation_id
      AND RO.route_id = p_route_id
      AND ROM.ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION;
   l_dummy                 op_level_planned_reqs_exist%ROWTYPE;

   l_rt_requirement_rec    get_route_level_reqs_csr%ROWTYPE;
   l_index                 NUMBER := 0;
   L_DEBUG_KEY   CONSTANT  VARCHAR2(150) := G_LOG_PREFIX || '.Get_Route_Requirements';

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Get the requirements defined at the route level (if any)
  OPEN get_route_level_reqs_csr;
  FETCH get_route_level_reqs_csr INTO l_rt_requirement_rec;
  IF(get_route_level_reqs_csr%FOUND) THEN
    -- Requirements defined at the Route level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirements for Route with Id ' || p_route_id || ' are defined at the Route level itself.');
    END IF;
    LOOP
      EXIT WHEN get_route_level_reqs_csr%NOTFOUND;
      -- Process this requirement
      l_index := l_index + 1;
      x_route_req_list(l_index).RT_OPER_MATERIAL_ID := l_rt_requirement_rec.RT_OPER_MATERIAL_ID;
      IF(l_rt_requirement_rec.INVENTORY_ITEM_ID IS NULL) THEN
        -- Item Group Requirement
        x_route_req_list(l_index).ITEM_GROUP_ID := l_rt_requirement_rec.ITEM_GROUP_ID;
        x_route_req_list(l_index).QUANTITY := l_rt_requirement_rec.QUANTITY;
        x_route_req_list(l_index).UOM_CODE := l_rt_requirement_rec.UOM_CODE;
      ELSE
        -- Specific Item Requirement
        x_route_req_list(l_index).INVENTORY_ITEM_ID := l_rt_requirement_rec.INVENTORY_ITEM_ID;
        x_route_req_list(l_index).INV_MASTER_ORG_ID := l_rt_requirement_rec.INVENTORY_ORG_ID;
        x_route_req_list(l_index).QUANTITY := l_rt_requirement_rec.PRIMARY_QUANTITY;
        x_route_req_list(l_index).UOM_CODE := l_rt_requirement_rec.PRIMARY_UOM_CODE;
      END IF;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || l_rt_requirement_rec.RT_OPER_MATERIAL_ID ||
                                                             ', ITEM_GROUP_ID = ' || x_route_req_list(l_index).ITEM_GROUP_ID ||
                                                             ', INVENTORY_ITEM_ID = ' || x_route_req_list(l_index).INVENTORY_ITEM_ID ||
                                                             ', INV_MASTER_ORG_ID = ' || x_route_req_list(l_index).INV_MASTER_ORG_ID ||
                                                             ', QUANTITY = ' || x_route_req_list(l_index).QUANTITY ||
                                                             ', UOM_CODE = ' || x_route_req_list(l_index).UOM_CODE);
      END IF;
      -- Get the next requirement
      FETCH get_route_level_reqs_csr INTO l_rt_requirement_rec;
    END LOOP;
    CLOSE get_route_level_reqs_csr;
  ELSE
    -- No requirement defined at route level
    CLOSE get_route_level_reqs_csr;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirements for Route with Id ' || p_route_id ||
                                                           ' are NOT defined at the Route level. Checking at the operation level.');
    END IF;
   -- AnRaj : Start for fixing perf bug 4919527
   -- AnRaj : Changed the code for fixing the performance bug# 4919527
   -- Split the query into 3 to avoid the  cursor get_op_level_reqs_csr
      IF p_request_type = G_REQ_TYPE_FORECAST THEN
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'p_request type is G_REQ_TYPE_FORECAST');
         END IF;

         FOR  l_op_requirement_rec  IN get_op_level_reqs_forecast_csr  LOOP
            l_index := l_index + 1;
            x_route_req_list(l_index).RT_OPER_MATERIAL_ID := l_op_requirement_rec.RT_OPER_MATERIAL_ID;
            x_route_req_list(l_index).ROUTE_OPERATION_ID := l_op_requirement_rec.ROUTE_OPERATION_ID;
            x_route_req_list(l_index).ITEM_GROUP_ID := l_op_requirement_rec.ITEM_GROUP_ID;
            x_route_req_list(l_index).INVENTORY_ITEM_ID := l_op_requirement_rec.INVENTORY_ITEM_ID;
            x_route_req_list(l_index).INV_MASTER_ORG_ID := l_op_requirement_rec.INVENTORY_ORG_ID;
            x_route_req_list(l_index).QUANTITY := l_op_requirement_rec.QUANTITY;
            x_route_req_list(l_index).UOM_CODE := l_op_requirement_rec.UOM_CODE;
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || x_route_req_list(l_index).RT_OPER_MATERIAL_ID ||
                                                                   ', ROUTE_OPERATION_ID = ' || x_route_req_list(l_index).ROUTE_OPERATION_ID ||
                                                                   ', ITEM_GROUP_ID = ' || x_route_req_list(l_index).ITEM_GROUP_ID ||
                                                                   ', INVENTORY_ITEM_ID = ' || x_route_req_list(l_index).INVENTORY_ITEM_ID ||
                                                                   ', INV_MASTER_ORG_ID = ' || x_route_req_list(l_index).INV_MASTER_ORG_ID ||
                                                                   ', QUANTITY = ' || x_route_req_list(l_index).QUANTITY ||
                                                                   ', UOM_CODE = ' || x_route_req_list(l_index).UOM_CODE);
            END IF;
         END LOOP;
      ELSIF p_request_type = G_REQ_TYPE_PLANNED THEN
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'p_request type is G_REQ_TYPE_PLANNED');
         END IF;

         -- Begin changes by jaramana on 22-OCT-2009 for bug 9037150
         -- Do a high level check for presence of operation level mtl requirements before
         -- attempting to get the details of the requirements to avoid performance hit
         OPEN op_level_planned_reqs_exist;
         FETCH op_level_planned_reqs_exist INTO l_dummy;
         IF (op_level_planned_reqs_exist%FOUND) THEN
           -- Operation Level Requirements seem to exist. Get these if they are effective
           -- and if they are applicable to the latest revision
           FOR l_op_requirement_rec IN  get_op_level_reqs_planned_csr   LOOP
              l_index := l_index + 1;
              x_route_req_list(l_index).RT_OPER_MATERIAL_ID := l_op_requirement_rec.RT_OPER_MATERIAL_ID;
              x_route_req_list(l_index).ROUTE_OPERATION_ID := l_op_requirement_rec.ROUTE_OPERATION_ID;
              x_route_req_list(l_index).ITEM_GROUP_ID := l_op_requirement_rec.ITEM_GROUP_ID;
              x_route_req_list(l_index).INVENTORY_ITEM_ID := l_op_requirement_rec.INVENTORY_ITEM_ID;
              x_route_req_list(l_index).INV_MASTER_ORG_ID := l_op_requirement_rec.INVENTORY_ORG_ID;
              x_route_req_list(l_index).QUANTITY := l_op_requirement_rec.QUANTITY;
              x_route_req_list(l_index).UOM_CODE := l_op_requirement_rec.UOM_CODE;
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || x_route_req_list(l_index).RT_OPER_MATERIAL_ID ||
                                                                     ', ROUTE_OPERATION_ID = ' || x_route_req_list(l_index).ROUTE_OPERATION_ID ||
                                                                     ', ITEM_GROUP_ID = ' || x_route_req_list(l_index).ITEM_GROUP_ID ||
                                                                     ', INVENTORY_ITEM_ID = ' || x_route_req_list(l_index).INVENTORY_ITEM_ID ||
                                                                     ', INV_MASTER_ORG_ID = ' || x_route_req_list(l_index).INV_MASTER_ORG_ID ||
                                                                     ', QUANTITY = ' || x_route_req_list(l_index).QUANTITY ||
                                                                     ', UOM_CODE = ' || x_route_req_list(l_index).UOM_CODE);
              END IF;

           END LOOP;
         END IF;
         CLOSE op_level_planned_reqs_exist;
         -- End changes by jaramana on 22-OCT-2009 for bug 9037150

      -- Not too sure whether the value of p_request_type can be anything other than G_REQ_TYPE_FORECAST and G_REQ_TYPE_PLANNED
      -- Adding this part for safety purpose, so that no records are missed out
      ELSE
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'p_request type is neither G_REQ_TYPE_PLANNED nor G_REQ_TYPE_FORECAST');
         END IF;

         FOR l_op_requirement_rec IN l_op_requirement_neither_csr LOOP
            l_index := l_index + 1;
            x_route_req_list(l_index).RT_OPER_MATERIAL_ID := l_op_requirement_rec.RT_OPER_MATERIAL_ID;
            x_route_req_list(l_index).ROUTE_OPERATION_ID := l_op_requirement_rec.ROUTE_OPERATION_ID;
            x_route_req_list(l_index).ITEM_GROUP_ID := l_op_requirement_rec.ITEM_GROUP_ID;
            x_route_req_list(l_index).INVENTORY_ITEM_ID := l_op_requirement_rec.INVENTORY_ITEM_ID;
            x_route_req_list(l_index).INV_MASTER_ORG_ID := l_op_requirement_rec.INVENTORY_ORG_ID;
            x_route_req_list(l_index).QUANTITY := l_op_requirement_rec.QUANTITY;
            x_route_req_list(l_index).UOM_CODE := l_op_requirement_rec.UOM_CODE;
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || x_route_req_list(l_index).RT_OPER_MATERIAL_ID ||
                                                                   ', ROUTE_OPERATION_ID = ' || x_route_req_list(l_index).ROUTE_OPERATION_ID ||
                                                                   ', ITEM_GROUP_ID = ' || x_route_req_list(l_index).ITEM_GROUP_ID ||
                                                                   ', INVENTORY_ITEM_ID = ' || x_route_req_list(l_index).INVENTORY_ITEM_ID ||
                                                                   ', INV_MASTER_ORG_ID = ' || x_route_req_list(l_index).INV_MASTER_ORG_ID ||
                                                                   ', QUANTITY = ' || x_route_req_list(l_index).QUANTITY ||
                                                                   ', UOM_CODE = ' || x_route_req_list(l_index).UOM_CODE);
            END IF;

         END LOOP;
      END IF;  -- request_type check

    -- Check operation level
   /*    FOR l_op_requirement_rec IN get_op_level_reqs_csr LOOP
      l_index := l_index + 1;
      x_route_req_list(l_index).RT_OPER_MATERIAL_ID := l_op_requirement_rec.RT_OPER_MATERIAL_ID;
      x_route_req_list(l_index).ROUTE_OPERATION_ID := l_op_requirement_rec.ROUTE_OPERATION_ID;
      x_route_req_list(l_index).ITEM_GROUP_ID := l_op_requirement_rec.ITEM_GROUP_ID;
      x_route_req_list(l_index).INVENTORY_ITEM_ID := l_op_requirement_rec.INVENTORY_ITEM_ID;
      x_route_req_list(l_index).INV_MASTER_ORG_ID := l_op_requirement_rec.INVENTORY_ORG_ID;
      x_route_req_list(l_index).QUANTITY := l_op_requirement_rec.QUANTITY;
      x_route_req_list(l_index).UOM_CODE := l_op_requirement_rec.UOM_CODE;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Requirement ' || l_index || ': RT_OPER_MATERIAL_ID = ' || x_route_req_list(l_index).RT_OPER_MATERIAL_ID ||
                                                             ', ROUTE_OPERATION_ID = ' || x_route_req_list(l_index).ROUTE_OPERATION_ID ||
                                                             ', ITEM_GROUP_ID = ' || x_route_req_list(l_index).ITEM_GROUP_ID ||
                                                             ', INVENTORY_ITEM_ID = ' || x_route_req_list(l_index).INVENTORY_ITEM_ID ||
                                                             ', INV_MASTER_ORG_ID = ' || x_route_req_list(l_index).INV_MASTER_ORG_ID ||
                                                             ', QUANTITY = ' || x_route_req_list(l_index).QUANTITY ||
                                                             ', UOM_CODE = ' || x_route_req_list(l_index).UOM_CODE);
      END IF;
    END LOOP;
    */
-- AnRaj : End for fixing perf bug 4919527
  END IF;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Total number of Route requirements: ' || l_index);
  END IF;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Get_Route_Requirements;

------------------------------------------------------------------------
-- This Procedure validates a Position Path against a given unit and date.
-- It returns a status flag and if valid, it get the details about the position.
------------------------------------------------------------------------
PROCEDURE Validate_Path_Position
(
   p_path_position_id          IN  NUMBER,
   p_unit_instance_id          IN  NUMBER,
   p_requirement_date          IN  DATE,
   x_valid_flag                OUT NOCOPY VARCHAR2,
   x_relationship_id           OUT NOCOPY NUMBER,
   x_item_group_id             OUT NOCOPY NUMBER,
   x_pos_instance_id           OUT NOCOPY NUMBER) IS

  CURSOR get_pos_path_dtls_csr IS
    SELECT position_key
    FROM AHL_MC_PATH_POSITION_NODES
    WHERE PATH_POSITION_ID = p_path_position_id AND
          SEQUENCE = (SELECT MAX(SEQUENCE) FROM AHL_MC_PATH_POSITION_NODES
                      WHERE PATH_POSITION_ID = p_path_position_id);

  CURSOR get_position_dtls_csr(c_pos_key      IN NUMBER,
                               c_mc_header_id IN NUMBER) IS
    SELECT relationship_id, item_group_id
    FROM AHL_MC_RELATIONSHIPS
    WHERE POSITION_KEY = c_pos_key AND
          MC_HEADER_ID = c_mc_header_id;

  CURSOR get_config_dtls_csr(c_unit_instance_id IN NUMBER) IS
    SELECT master_config_id
    FROM ahl_unit_config_headers
    WHERE CSI_ITEM_INSTANCE_ID = c_unit_instance_id AND
          NVL(ACTIVE_START_DATE, SYSDATE - 1) <= SYSDATE AND
          NVL(ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE;

  CURSOR get_all_position_dates_csr(c_start_pos_key IN NUMBER,
                                    c_mc_header_id  IN NUMBER) IS
    SELECT ACTIVE_START_DATE,
           ACTIVE_END_DATE
    FROM AHL_MC_RELATIONSHIPS
    START WITH POSITION_KEY = c_start_pos_key AND
               MC_HEADER_ID = c_mc_header_id
    CONNECT BY RELATIONSHIP_ID = PRIOR PARENT_RELATIONSHIP_ID;

  CURSOR get_ii_position_csr(c_start_instance_id IN NUMBER) IS
    SELECT II.OBJECT_ID,
           II.SUBJECT_ID,
           REL.RELATIONSHIP_ID,
           REL.ACTIVE_START_DATE,
           REL.ACTIVE_END_DATE
    FROM CSI_II_RELATIONSHIPS II, AHL_MC_RELATIONSHIPS REL
    WHERE NVL(II.ACTIVE_START_DATE, SYSDATE - 1) <= SYSDATE AND
          NVL(II.ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE AND
          II.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF' AND
          REL.RELATIONSHIP_ID =TO_NUMBER(II.POSITION_REFERENCE)
          AND II.RELATIONSHIP_ID IN
          (SELECT RELATIONSHIP_ID
          FROM CSI_II_RELATIONSHIPS
    START WITH SUBJECT_ID = c_start_instance_id AND
               NVL(ACTIVE_START_DATE, SYSDATE - 1) <= SYSDATE AND
               NVL(ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE AND
               RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
    CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID AND
               NVL(ACTIVE_START_DATE, SYSDATE - 1) <= SYSDATE AND
               NVL(ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE AND
               RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF');

   L_DEBUG_KEY   CONSTANT  VARCHAR2(150) := G_LOG_PREFIX || '.Validate_Path_Position';
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(1000);
   l_installed_inst_id     NUMBER;
   l_lowest_unit_inst_id   NUMBER;
   l_lowest_mc_header_id   NUMBER;
   l_mapping_status        VARCHAR2(30);
   l_position_key          AHL_MC_PATH_POSITION_NODES.POSITION_KEY%TYPE;
   l_last_instance_id      NUMBER;
   l_requirement_date      DATE := p_requirement_date;

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_EVENT, L_DEBUG_KEY, 'About to call AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance with ' ||
                                                     ' p_position_id = ' || p_path_position_id ||
                                                     ' p_csi_item_instance_id = ' || p_unit_instance_id);
  END IF;

  AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance(p_api_version          => 1.0,
                                            p_init_msg_list        => FND_API.G_FALSE,
                                            p_commit               => FND_API.G_FALSE,
                                            p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                            x_return_status        => l_return_status,
                                            x_msg_count            => l_msg_count,
                                            x_msg_data             => l_msg_data,
                                            p_position_id          => p_path_position_id,
                                            p_csi_item_instance_id => p_unit_instance_id,
                                            x_item_instance_id     => l_installed_inst_id,
                                            x_lowest_uc_csi_id     => l_lowest_unit_inst_id,
                                            x_mapping_status       => l_mapping_status);

  IF (G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to AHL_MC_PATH_POSITION_PVT.Get_Pos_Instance:' ||
                                                     ' x_return_status = ' || l_return_status ||
                                                     ', x_mapping_status = ' || l_mapping_status ||
                                                     ', x_item_instance_id = ' || l_installed_inst_id ||
                                                     ', x_lowest_uc_csi_id = ' || l_lowest_unit_inst_id);
  END IF;

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(l_mapping_status = G_MAPPING_STATUS_NA) THEN
    -- Position does not apply to current unit
    x_valid_flag := FND_API.G_FALSE;
    RETURN;
  END IF;

  OPEN get_pos_path_dtls_csr;
  FETCH get_pos_path_dtls_csr INTO l_position_key;
  CLOSE get_pos_path_dtls_csr;

  OPEN get_config_dtls_csr(c_unit_instance_id => l_lowest_unit_inst_id);
  FETCH get_config_dtls_csr INTO l_lowest_mc_header_id;
  CLOSE get_config_dtls_csr;

  IF l_requirement_date IS NULL THEN
    l_requirement_date := SYSDATE;
  END IF;

  -- Check if the Position is valid on the requirement date
  -- by traversing the tree from the position up to the unit's root node.
  IF (l_mapping_status = G_MAPPING_STATUS_EMPTY) THEN
    -- If the position is empty, do a separate traversal from
    -- the position up to l_lowest_unit_inst_id first.
    FOR position_dates_rec IN get_all_position_dates_csr(l_position_key, l_lowest_mc_header_id)  LOOP
      IF ((position_dates_rec.ACTIVE_START_DATE IS NOT NULL AND
           position_dates_rec.ACTIVE_START_DATE > l_requirement_date) OR
          (position_dates_rec.ACTIVE_END_DATE IS NOT NULL AND
           position_dates_rec.ACTIVE_END_DATE <= l_requirement_date)) THEN
        -- Position is not valid on the requirement date
        x_valid_flag := FND_API.G_FALSE;
        RETURN;
      END IF;
    END LOOP;
    l_last_instance_id := l_lowest_unit_inst_id;
  ELSE
    -- Position is not empty
    l_last_instance_id := l_installed_inst_id;
  END IF;

  IF (l_last_instance_id <> p_unit_instance_id) THEN
    -- Now traverse up the instance tree to validate positions.
    FOR position_rec IN get_ii_position_csr(l_last_instance_id) LOOP
      -- Check if the position is valid in the last mc
      IF ((position_rec.ACTIVE_START_DATE IS NOT NULL AND
           position_rec.ACTIVE_START_DATE > l_requirement_date) OR
          (position_rec.ACTIVE_END_DATE IS NOT NULL AND
           position_rec.ACTIVE_END_DATE <= l_requirement_date)) THEN
        -- Position is not valid on the requirement date
        x_valid_flag := FND_API.G_FALSE;
        RETURN;
      END IF;
    END LOOP;
  END IF;

  -- The Position hierarchy is valid on the requirement Date
  x_valid_flag := FND_API.G_TRUE;

  -- Information available: l_position_key, l_lowest_mc_header_id, l_mapping_status, l_installed_inst_id
  -- Get the relationship id and the item group id for the position
  OPEN get_position_dtls_csr(c_pos_key      => l_position_key,
                             c_mc_header_id => l_lowest_mc_header_id);
  FETCH get_position_dtls_csr INTO x_relationship_id, x_item_group_id;
  CLOSE get_position_dtls_csr;
  IF (l_mapping_status = G_MAPPING_STATUS_MATCH) THEN
    x_pos_instance_id := l_installed_inst_id;
  ELSE
    x_pos_instance_id := NULL;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Validate_Path_Position;


-------------------------------------
-- End Local Procedure Definitions --
-------------------------------------
---------------------------------------
-- Local Function Definitions follow --
---------------------------------------
-----------------------------------------------
-- This Function gets the unit's instance id --
-- If p_item_instance_id does not belong to an UC (stand-alone or IB Tree), it
-- returns null. If p_item_instance_id itself is a UC's top node, it returns itself.
-----------------------------------------------

FUNCTION Get_Unit_Instance(
   p_item_instance_id IN NUMBER) RETURN NUMBER IS

  CURSOR chk_inst_is_unit_csr IS
    SELECT 'x'
    FROM ahl_unit_config_headers
    WHERE csi_item_instance_id = p_item_instance_id
      AND nvl(active_end_date, SYSDATE+1) > SYSDATE
      AND nvl(active_start_date, SYSDATE) <= SYSDATE;

  CURSOR get_parent_instance_csr IS
    SELECT object_id
    FROM csi_ii_relationships
    WHERE object_id IN (SELECT csi_item_instance_id
                        FROM ahl_unit_config_headers
                        WHERE nvl(active_end_date, SYSDATE+1) > SYSDATE
                          AND nvl(active_start_date, SYSDATE) <= SYSDATE)
    START WITH subject_id = p_item_instance_id
           AND relationship_type_code = 'COMPONENT-OF'
           AND nvl(active_start_date, SYSDATE) <= SYSDATE
           AND nvl(active_end_date, SYSDATE+1) > SYSDATE
    CONNECT BY subject_id = PRIOR object_id
         AND relationship_type_code = 'COMPONENT-OF'
         AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
         AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
    ORDER BY LEVEL;

  l_instance_id  NUMBER := null;
  l_dummy        VARCHAR2(1);

  L_DEBUG_KEY CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Get_Unit_Instance';

BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Function');
  END IF;

  IF(p_item_instance_id IS NULL) THEN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'p_item_instance_id is null. So, returning null.');
    END IF;
    l_instance_id := null;
  ELSE
    OPEN chk_inst_is_unit_csr;
    FETCH chk_inst_is_unit_csr INTO l_dummy;
    IF (chk_inst_is_unit_csr%FOUND) THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'p_item_instance_id (' || p_item_instance_id || ') itself is a unit.');
      END IF;
      l_instance_id := p_item_instance_id;
    ELSE
      OPEN get_parent_instance_csr;
      FETCH get_parent_instance_csr INTO l_instance_id;
      CLOSE get_parent_instance_csr;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT, L_DEBUG_KEY, 'Unit Instance of ' || p_item_instance_id || ' is ' || l_instance_id);
      END IF;
    END IF;
    CLOSE chk_inst_is_unit_csr;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Function');
  END IF;
  RETURN l_instance_id;

END Get_Unit_Instance;


------------------------------------
-- End Local Function Definitions --
------------------------------------

END AHL_LTP_MTL_REQ_PVT;

/
