--------------------------------------------------------
--  DDL for Package Body AHL_RM_MATERIAL_AS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_MATERIAL_AS_PVT" AS
/* $Header: AHLVMTLB.pls 120.2 2008/01/30 05:37:54 pdoki ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_MATERIAL_AS_PVT';
G_API_NAME VARCHAR2(30) := 'PROCESS_MATERIAL_REQ';
G_API_NAME1 VARCHAR2(30) := 'PROCESS_ROUTE_EFCTS';
G_DEBUG    VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_material_req_rec       IN    material_req_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(5000) := '';

l_put_comma       VARCHAR2(5) :='N';

BEGIN


  IF ( p_material_req_rec.item_group_name IS NOT NULL AND
       p_material_req_rec.item_group_name <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_material_req_rec.item_group_name;
    l_put_comma := 'Y';
  ELSE
    l_put_comma := 'N';
  END IF;

  l_record_identifier := l_record_identifier || '  ';

  IF ( p_material_req_rec.item_number IS NOT NULL AND
       p_material_req_rec.item_number <> FND_API.G_MISS_CHAR ) THEN

    IF(l_put_comma = 'Y')
    THEN
      l_record_identifier := l_record_identifier || ',';
    END IF;
    l_record_identifier := l_record_identifier || p_material_req_rec.item_number;

    l_put_comma := 'Y';
  END IF;

  l_record_identifier := l_record_identifier || '  ';

  IF ( p_material_req_rec.POSITION_PATH IS NOT NULL AND
       p_material_req_rec.POSITION_PATH <> FND_API.G_MISS_CHAR ) THEN

    IF(l_put_comma = 'Y')
    THEN
      l_record_identifier := l_record_identifier || ',';
    END IF;
    l_record_identifier := l_record_identifier || p_material_req_rec.POSITION_PATH;
  END IF;

  RETURN l_record_identifier;

END get_record_identifier;



FUNCTION get_effct_identifier
(
  p_route_req_rec       IN    route_efct_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN
  IF ( p_route_req_rec.ITEM_NUMBER  IS NOT NULL AND
       p_route_req_rec.ITEM_NUMBER  <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_route_req_rec.ITEM_NUMBER ;
    l_record_identifier := l_record_identifier || '   ';
  END IF;




  IF ( p_route_req_rec.ORGANIZATION_CODE  IS NOT NULL AND
         p_route_req_rec.ORGANIZATION_CODE  <> FND_API.G_MISS_CHAR ) THEN

      l_record_identifier := l_record_identifier || p_route_req_rec.ORGANIZATION_CODE;
      l_record_identifier := l_record_identifier || '   ';
    END IF;



  IF ( p_route_req_rec.MC_NAME IS NOT NULL AND
       p_route_req_rec.MC_NAME <> FND_API.G_MISS_CHAR ) THEN

    l_record_identifier := l_record_identifier || p_route_req_rec.MC_NAME;
    l_record_identifier := l_record_identifier || '   ';
  END IF;



  IF ( p_route_req_rec.MC_REVISION IS NOT NULL AND
       p_route_req_rec.MC_REVISION <> FND_API.G_MISS_CHAR ) THEN

    l_record_identifier := l_record_identifier || p_route_req_rec.MC_REVISION;
  END IF;

  RETURN l_record_identifier;

END get_effct_identifier;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_material_req_tbl         IN   material_req_tbl_type,
  p_object_id                IN   NUMBER,
  p_association_type         IN   VARCHAR2,
  x_return_status            OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a value is passed in p_object_id
  IF ( p_object_id = FND_API.G_MISS_NUM OR
       p_object_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OBJECT_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if a value is passed in p_association_type
  IF ( p_association_type = FND_API.G_MISS_CHAR OR
       p_association_type IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ASSOC_TYPE_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if a valid value is passed in p_association_type
  IF ( p_association_type <> 'ROUTE' AND
       p_association_type <> 'OPERATION' AND
       p_association_type <> 'DISPOSITION' ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ASSOC_TYPE_INVALID' );
    FND_MESSAGE.set_token( 'FIELD', p_association_type );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Route / Operation is in Updatable status
  IF ( p_association_type = 'ROUTE' ) THEN
    AHL_RM_ROUTE_UTIL.validate_route_status
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_route_id             => p_object_id
    );
  ELSIF ( p_association_type = 'OPERATION' ) THEN
    AHL_RM_ROUTE_UTIL.validate_operation_status
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_operation_id         => p_object_id
    );
   ELSIF ( p_association_type = 'DISPOSITION' ) THEN
    AHL_RM_ROUTE_UTIL.validate_efct_status
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_efct_id              => p_object_id
    );
  END IF;

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Check if atleast one record is passed in p_material_req_tbl
  IF ( p_material_req_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_material_req_tbl.count LOOP
    IF ( p_material_req_tbl(i).dml_operation <> 'D' AND
         p_material_req_tbl(i).dml_operation <> 'U' AND
         p_material_req_tbl(i).dml_operation <> 'C' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_material_req_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

END validate_api_inputs;

-- Procedure to validate the all the inputs except the table structure of the API
PROCEDURE validate_efct_api_inputs
(
  p_route_efct_tbl IN   route_efct_tbl_type,
  p_object_id               IN   NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a valid value is passed in p_rt_oper_resource_id
  IF ( p_object_id = FND_API.G_MISS_NUM OR
       p_object_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_efct_OBJECT_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   AHL_RM_ROUTE_UTIL.validate_route_status
    (
       p_route_id          => p_object_id,
       x_return_status     => l_return_status,
       x_msg_data          => l_msg_data
    );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;


   -- Check if at least one record is passed in p_rt_oper_resource_tbl
  IF ( p_route_efct_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME1 );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_route_efct_tbl.count LOOP
    IF ( p_route_efct_tbl(i).dml_operation <> 'C' AND
         p_route_efct_tbl(i).dml_operation <> 'U' AND
         p_route_efct_tbl(i).dml_operation <> 'D' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_route_efct_tbl(i).dml_operation );
--      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_efct_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;


END validate_efct_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_material_req_rec       IN OUT NOCOPY  material_req_rec_type
)
IS

BEGIN


 IF ( p_x_material_req_rec.position_path IS NULL ) THEN
    p_x_material_req_rec.position_path_id := NULL;
  ELSIF ( p_x_material_req_rec.position_path = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.position_path_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_material_req_rec.item_group_name IS NULL ) THEN
    p_x_material_req_rec.item_group_id := NULL;
  ELSIF ( p_x_material_req_rec.item_group_name = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.item_group_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_material_req_rec.item_number IS NULL ) THEN
    p_x_material_req_rec.inventory_item_id := NULL;
    p_x_material_req_rec.inventory_org_id := NULL;
  ELSIF ( p_x_material_req_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.inventory_item_id := FND_API.G_MISS_NUM;
    p_x_material_req_rec.inventory_org_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_material_req_rec.uom IS NULL ) THEN
    p_x_material_req_rec.uom_code := NULL;
  ELSIF ( p_x_material_req_rec.uom = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.uom_code := FND_API.G_MISS_CHAR;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_efct_attribute_ids
(
  p_x_route_efct_rec       IN OUT NOCOPY  route_efct_rec_type
)
IS

BEGIN

  IF ( p_x_route_efct_rec.mc_name IS NULL ) THEN
    p_x_route_efct_rec.mc_id := NULL;
    p_x_route_efct_rec.mc_header_id := NULL;
  ELSIF ( p_x_route_efct_rec.mc_name = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.mc_header_id := FND_API.G_MISS_NUM;
    p_x_route_efct_rec.mc_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_route_efct_rec.MC_REVISION IS NULL ) THEN
       p_x_route_efct_rec.mc_header_id := NULL;
  ELSIF ( p_x_route_efct_rec.MC_REVISION = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.mc_header_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_route_efct_rec.item_number IS NULL OR p_x_route_efct_rec.ORGANIZATION_CODE IS NULL ) THEN
    p_x_route_efct_rec.inventory_item_id := NULL;
    p_x_route_efct_rec.inventory_master_org_id := NULL;
  ELSIF ( p_x_route_efct_rec.item_number = FND_API.G_MISS_CHAR OR p_x_route_efct_rec.ORGANIZATION_CODE = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.inventory_item_id := FND_API.G_MISS_NUM;
    p_x_route_efct_rec.inventory_master_org_id := FND_API.G_MISS_NUM;
  END IF;


END clear_efct_attribute_ids;


-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_material_req_rec      IN OUT NOCOPY  material_req_rec_type,
  p_object_id       IN NUMBER,
  p_association_type        IN   VARCHAR2,
  x_return_status           OUT NOCOPY            VARCHAR2
)
IS


-- Cursor for getting item_comp_detail_id when supplied with item_group_id and master_org_id

--AMSRINIV. Bug 4913141. Query for cursor below tuned.
CURSOR get_item_comp_detail_id( p_route_effecitivity_id IN NUMBER,
              p_item_group_id IN NUMBER ) IS
 SELECT ITEM_COMP_DETAIL_ID
 FROM AHL_ITEM_COMP_DETAILS
 WHERE ITEM_GROUP_ID = P_ITEM_GROUP_ID AND
        ITEM_COMPOSITION_ID = (
                        SELECT IC.ITEM_COMPOSITION_ID FROM
                        AHL_ROUTE_EFFECTIVITIES RE, AHL_ITEM_COMPOSITIONS IC
                        WHERE RE.INVENTORY_ITEM_ID=IC.INVENTORY_ITEM_ID(+) AND
                        RE.INVENTORY_MASTER_ORG_ID=IC.INVENTORY_MASTER_ORG_ID(+) AND
                        IC.APPROVAL_STATUS_CODE(+)='COMPLETE' AND
                        ROUTE_EFFECTIVITY_ID = P_ROUTE_EFFECITIVITY_ID ) AND
      EFFECTIVE_END_DATE IS NULL;

/*SELECT item_comp_detail_id
FROM AHL_ITEM_COMP_DETAILS
WHERE item_group_id = p_item_group_id AND
      item_composition_id = (
                 SELECT item_composition_id FROM AHL_ROUTE_EFFECTIVITIES_V
                 WHERE route_effectivity_id = p_route_effecitivity_id
                 ) AND
      effective_end_date IS NULL;*/




l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);
l_item_comp_detail_id   NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Convert / Validate Item Composition
  IF ( p_association_type = 'DISPOSITION' AND
         p_x_material_req_rec.item_comp_detail_id IS NOT NULL AND
         p_x_material_req_rec.item_comp_detail_id <> FND_API.G_MISS_NUM  ) THEN

    AHL_RM_ROUTE_UTIL.validate_item_comp
    (
      x_return_status           => l_return_status,
      x_msg_data                => l_msg_data,
      p_x_item_comp_detail_id   => p_x_material_req_rec.item_comp_detail_id
    );


  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_material_req_rec.item_comp_detail_id ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

  -- Convert / Validate Position path
  IF ( p_association_type = 'DISPOSITION' AND
       ( p_x_material_req_rec.position_path_id IS NOT NULL AND
         p_x_material_req_rec.position_path_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_material_req_rec.position_path IS NOT NULL AND
         p_x_material_req_rec.position_path <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_position_path
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_position_path        => p_x_material_req_rec.position_path,
      p_x_position_path_id   => p_x_material_req_rec.position_path_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_material_req_rec.position_path IS NULL OR
           p_x_material_req_rec.position_path = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_material_req_rec.position_path_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_material_req_rec.position_path );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

  -- Convert / Validate Item Group
  IF ( ( p_x_material_req_rec.item_group_id IS NOT NULL AND
         p_x_material_req_rec.item_group_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_material_req_rec.item_group_name IS NOT NULL AND
         p_x_material_req_rec.item_group_name <> FND_API.G_MISS_CHAR ) ) THEN


    AHL_RM_ROUTE_UTIL.validate_item_group
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_association_type     => p_association_type,
      p_item_group_name      => p_x_material_req_rec.item_group_name,
      p_x_item_group_id      => p_x_material_req_rec.item_group_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_material_req_rec.item_group_name IS NULL OR
           p_x_material_req_rec.item_group_name = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_material_req_rec.item_group_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_material_req_rec.item_group_name );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

    --Check if the item group is from composition and is a valid composition element if
    -- comp material flag is set.
    IF p_x_material_req_rec.COMP_MATERIAL_FLAG = 'Y' OR p_x_material_req_rec.COMP_MATERIAL_FLAG = 'y'
    THEN
       -- Find if it a MC-Route Association or Item-Route Association
         IF ( p_x_material_req_rec.position_path_id IS NULL OR
              p_x_material_req_rec.position_path_id = FND_API.G_MISS_NUM ) AND
            ( p_x_material_req_rec.item_comp_detail_id IS NULL OR
              p_x_material_req_rec.item_comp_detail_id = FND_API.G_MISS_NUM )
         THEN
    OPEN get_item_comp_detail_id(p_object_id,
               p_x_material_req_rec.item_group_id);
    FETCH get_item_comp_detail_id INTO l_item_comp_detail_id;
    CLOSE get_item_comp_detail_id;

    IF l_item_comp_detail_id IS NOT NULL
    THEN
       p_x_material_req_rec.item_comp_detail_id := l_item_comp_detail_id;
    ELSE
       FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INV_ITEM_COMP_MAT' );
       FND_MESSAGE.set_token( 'FIELD',p_x_material_req_rec.item_group_name);
       FND_MSG_PUB.add;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF; -- l_item_comp_detail_id is null
          END IF; -- which association if
    END IF;-- comp_material_flag check if

  END IF; -- Item group id check

  -- Convert / Validate Item

  IF ( ( p_x_material_req_rec.inventory_item_id IS NOT NULL AND
         p_x_material_req_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
         p_x_material_req_rec.inventory_org_id IS NOT NULL AND
         p_x_material_req_rec.inventory_org_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_material_req_rec.item_number IS NOT NULL AND
         p_x_material_req_rec.item_number <> FND_API.G_MISS_CHAR ) ) THEN
    IF ( p_association_type <> 'DISPOSITION' )
    THEN
    AHL_RM_ROUTE_UTIL.validate_item
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_item_number          => p_x_material_req_rec.item_number,
      p_x_inventory_item_id  => p_x_material_req_rec.inventory_item_id,
      p_x_inventory_org_id   => p_x_material_req_rec.inventory_org_id
    );
    ELSE
    AHL_RM_ROUTE_UTIL.validate_adt_item
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_item_number          => p_x_material_req_rec.item_number,
      p_x_inventory_item_id  => p_x_material_req_rec.inventory_item_id,
      p_x_inventory_org_id   => p_x_material_req_rec.inventory_org_id
    );
    END IF;

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_ITEM' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ITEM' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_ITEMS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_ITEMS' );
      ELSIF ( l_msg_data = 'AHL_COM_SERVICE_ITEM' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_SERVICE_ITEM' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_material_req_rec.item_number IS NULL OR
           p_x_material_req_rec.item_number = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_material_req_rec.inventory_item_id ) || '-' || TO_CHAR( p_x_material_req_rec.inventory_org_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_material_req_rec.item_number );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

  -- Convert / Validate UOM
  IF ( ( p_x_material_req_rec.uom_code IS NOT NULL AND
         p_x_material_req_rec.uom_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_material_req_rec.uom IS NOT NULL AND
         p_x_material_req_rec.uom <> FND_API.G_MISS_CHAR ) )
  THEN
    AHL_RM_ROUTE_UTIL.validate_uom
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_uom                  => p_x_material_req_rec.uom,
      p_x_uom_code           => p_x_material_req_rec.uom_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_material_req_rec.uom IS NULL OR
           p_x_material_req_rec.uom = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_material_req_rec.uom_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_material_req_rec.uom );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

END convert_values_to_ids;


-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_efct_values_to_ids
(
  p_x_route_efct_rec      IN OUT NOCOPY  route_efct_rec_type,
  x_return_status                  OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate MC
  IF ( ( p_x_route_efct_rec.MC_ID IS NOT NULL AND
         p_x_route_efct_rec.MC_ID <> FND_API.G_MISS_NUM ) OR
       ( p_x_route_efct_rec.MC_NAME IS NOT NULL AND
         p_x_route_efct_rec.MC_NAME <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_master_configuration
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_mc_name              => p_x_route_efct_rec.MC_NAME,
      p_x_mc_id                => p_x_route_efct_rec.MC_ID,
      p_mc_revision_number    => p_x_route_efct_rec.MC_REVISION,
      p_x_mc_header_id       => p_x_route_efct_rec.MC_HEADER_ID
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_route_efct_rec.MC_NAME IS NULL OR
           p_x_route_efct_rec.MC_NAME = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_route_efct_rec.MC_HEADER_ID ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_route_efct_rec.MC_NAME );
      END IF;

 --     FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec(i) ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

  -- Convert / Validate Item
  IF ( ( p_x_route_efct_rec.inventory_item_id IS NOT NULL AND
         p_x_route_efct_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
         p_x_route_efct_rec.inventory_master_org_id IS NOT NULL AND
         p_x_route_efct_rec.inventory_master_org_id <> FND_API.G_MISS_NUM ) OR
       (    (p_x_route_efct_rec.ORGANIZATION_CODE IS NOT NULL AND p_x_route_efct_rec.ORGANIZATION_CODE <> FND_API.G_MISS_CHAR )
         AND(p_x_route_efct_rec.item_number IS NOT NULL AND p_x_route_efct_rec.item_number <> FND_API.G_MISS_CHAR )
       )
      )THEN

    AHL_RM_ROUTE_UTIL.validate_effectivity_item
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_item_number          => p_x_route_efct_rec.item_number,
      p_org_code             => p_x_route_efct_rec.ORGANIZATION_CODE,
      p_x_inventory_item_id  => p_x_route_efct_rec.inventory_item_id,
      p_x_inventory_org_id   => p_x_route_efct_rec.inventory_master_org_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_ITEM' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ITEM' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_ITEMS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_ITEMS' );
      ELSIF ( l_msg_data = 'AHL_COM_effectivity_ITEM' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_effectivity_ITEM' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_efct_rec.item_number IS NULL OR
           p_x_route_efct_rec.item_number = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_route_efct_rec.inventory_item_id ) || '-' || TO_CHAR( p_x_route_efct_rec.inventory_master_org_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_route_efct_rec.item_number );
      END IF;

 --     FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;


END convert_efct_values_to_ids;

 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_material_req_rec       IN OUT NOCOPY   material_req_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL

 IF ( p_x_material_req_rec.item_comp_detail_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.item_comp_detail_id := null;
  END IF;

  IF ( p_x_material_req_rec.position_path_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.position_path_id := null;
  END IF;

  IF ( p_x_material_req_rec.position_path = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.position_path := null;
  END IF;

  IF ( p_x_material_req_rec.item_group_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.item_group_id := null;
  END IF;

  IF ( p_x_material_req_rec.item_group_name = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.item_group_name := null;
  END IF;

  IF ( p_x_material_req_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.inventory_item_id := null;
  END IF;

  IF ( p_x_material_req_rec.inventory_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.inventory_org_id := null;
  END IF;

  IF ( p_x_material_req_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.item_number := null;
  END IF;

  IF ( p_x_material_req_rec.uom_code = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.uom_code := null;
  END IF;

  IF ( p_x_material_req_rec.uom = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.uom := null;
  END IF;

  IF ( p_x_material_req_rec.quantity = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.quantity := null;
  END IF;

  IF ( p_x_material_req_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute_category := null;
  END IF;

  IF ( p_x_material_req_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute1 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute2 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute3 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute4 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute5 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute6 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute7 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute8 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute9 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute10 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute11 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute12 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute13 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute14 := null;
  END IF;

  IF ( p_x_material_req_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute15 := null;
  END IF;

  IF ( p_x_material_req_rec.replace_percent = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.replace_percent := null;
  END IF;

   IF ( p_x_material_req_rec.rework_percent = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.rework_percent := null;
  END IF;

   IF ( p_x_material_req_rec.exclude_flag = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.exclude_flag := null;
  END IF;

  --pdoki added for OGMA 105 issue
  IF ( p_x_material_req_rec.in_service = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.in_service := null;
  END IF;

END default_missing_attributes;


 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_efct_miss_attributes
(
  p_x_route_efct_rec       IN OUT NOCOPY   route_efct_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_route_efct_rec.mc_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.mc_id := null;
  END IF;

  IF ( p_x_route_efct_rec.mc_header_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.mc_header_id := null;
  END IF;

  IF ( p_x_route_efct_rec.mc_name = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.mc_name := null;
  END IF;

  IF ( p_x_route_efct_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.inventory_item_id := null;
  END IF;

  IF ( p_x_route_efct_rec.inventory_master_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.inventory_master_org_id := null;
  END IF;

  IF ( p_x_route_efct_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.item_number := null;
  END IF;

  IF ( p_x_route_efct_rec.ORGANIZATION_CODE = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.ORGANIZATION_CODE := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute_category := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute1 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute2 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute3 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute4 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute5 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute6 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute7 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute8 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute9 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute10 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute11 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute12 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute13 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute14 := null;
  END IF;

  IF ( p_x_route_efct_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute15 := null;
  END IF;

END default_efct_miss_attributes;


 -- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_material_req_rec       IN OUT NOCOPY   material_req_rec_type
)
IS

l_old_material_req_rec       material_req_rec_type;

CURSOR get_old_rec ( c_rt_oper_material_id NUMBER )
IS
SELECT  item_group_id,
        item_group_name,
        inventory_item_id,
        inventory_org_id,
        item_number,
        item_comp_detail_id,
        position_path_id,
        position_path,
        uom_code,
        uom,
        quantity,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        exclude_flag,
        rework_percent,
       replace_percent,
       in_service --pdoki added for OGMA 105 issue
FROM    AHL_RT_OPER_MATERIALS_V
WHERE   rt_oper_material_id = c_rt_oper_material_id;

BEGIN

  -- Get the old record from AHL_RT_OPER_MATERIALS.
  OPEN  get_old_rec( p_x_material_req_rec.rt_oper_material_id );

  FETCH get_old_rec INTO
        l_old_material_req_rec.item_group_id,
        l_old_material_req_rec.item_group_name,
        l_old_material_req_rec.inventory_item_id,
        l_old_material_req_rec.inventory_org_id,
        l_old_material_req_rec.item_number,
        l_old_material_req_rec.item_comp_detail_id,
        l_old_material_req_rec.position_path_id,
        l_old_material_req_rec.position_path,
        l_old_material_req_rec.uom_code,
        l_old_material_req_rec.uom,
        l_old_material_req_rec.quantity,
        l_old_material_req_rec.attribute_category,
        l_old_material_req_rec.attribute1,
        l_old_material_req_rec.attribute2,
        l_old_material_req_rec.attribute3,
        l_old_material_req_rec.attribute4,
        l_old_material_req_rec.attribute5,
        l_old_material_req_rec.attribute6,
        l_old_material_req_rec.attribute7,
        l_old_material_req_rec.attribute8,
        l_old_material_req_rec.attribute9,
        l_old_material_req_rec.attribute10,
        l_old_material_req_rec.attribute11,
        l_old_material_req_rec.attribute12,
        l_old_material_req_rec.attribute13,
        l_old_material_req_rec.attribute14,
        l_old_material_req_rec.attribute15,
        l_old_material_req_rec.exclude_flag,
        l_old_material_req_rec.rework_percent,
        l_old_material_req_rec.replace_percent,
        l_old_material_req_rec.in_service --pdoki added for OGMA 105 issue
        ;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_MTL_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values

  IF ( p_x_material_req_rec.item_comp_detail_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.item_comp_detail_id := null;
  ELSIF ( p_x_material_req_rec.item_comp_detail_id IS NULL ) THEN
    p_x_material_req_rec.item_comp_detail_id := l_old_material_req_rec.item_comp_detail_id;
  END IF;

  IF ( p_x_material_req_rec.position_path_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.position_path_id := null;
  ELSIF ( p_x_material_req_rec.position_path_id IS NULL ) THEN
    p_x_material_req_rec.position_path_id := l_old_material_req_rec.position_path_id;
  END IF;

  IF ( p_x_material_req_rec.position_path = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.position_path := null;
  ELSIF ( p_x_material_req_rec.position_path IS NULL ) THEN
    p_x_material_req_rec.position_path := l_old_material_req_rec.position_path;
  END IF;

  IF ( p_x_material_req_rec.item_group_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.item_group_id := null;
  ELSIF ( p_x_material_req_rec.item_group_id IS NULL ) THEN
    p_x_material_req_rec.item_group_id := l_old_material_req_rec.item_group_id;
  END IF;

  IF ( p_x_material_req_rec.item_group_name = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.item_group_name := null;
  ELSIF ( p_x_material_req_rec.item_group_name IS NULL ) THEN
    p_x_material_req_rec.item_group_name := l_old_material_req_rec.item_group_name;
  END IF;

  IF ( p_x_material_req_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.inventory_item_id := null;
  ELSIF ( p_x_material_req_rec.inventory_item_id IS NULL ) THEN
    p_x_material_req_rec.inventory_item_id := l_old_material_req_rec.inventory_item_id;
  END IF;

  IF ( p_x_material_req_rec.inventory_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.inventory_org_id := null;
  ELSIF ( p_x_material_req_rec.inventory_org_id IS NULL ) THEN
    p_x_material_req_rec.inventory_org_id := l_old_material_req_rec.inventory_org_id;
  END IF;

  IF ( p_x_material_req_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.item_number := null;
  ELSIF ( p_x_material_req_rec.item_number IS NULL ) THEN
    p_x_material_req_rec.item_number := l_old_material_req_rec.item_number;
  END IF;

  IF ( p_x_material_req_rec.uom_code = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.uom_code := null;
  ELSIF ( p_x_material_req_rec.uom_code IS NULL ) THEN
    p_x_material_req_rec.uom_code := l_old_material_req_rec.uom_code;
  END IF;

  IF ( p_x_material_req_rec.uom = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.uom := null;
  ELSIF ( p_x_material_req_rec.uom IS NULL ) THEN
    p_x_material_req_rec.uom := l_old_material_req_rec.uom;
  END IF;

  IF ( p_x_material_req_rec.quantity = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.quantity := null;
  ELSIF ( p_x_material_req_rec.quantity IS NULL ) THEN
    p_x_material_req_rec.quantity := l_old_material_req_rec.quantity;
  END IF;

  IF ( p_x_material_req_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute_category := null;
  ELSIF ( p_x_material_req_rec.attribute_category IS NULL ) THEN
    p_x_material_req_rec.attribute_category := l_old_material_req_rec.attribute_category;
  END IF;

  IF ( p_x_material_req_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute1 := null;
  ELSIF ( p_x_material_req_rec.attribute1 IS NULL ) THEN
    p_x_material_req_rec.attribute1 := l_old_material_req_rec.attribute1;
  END IF;

  IF ( p_x_material_req_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute2 := null;
  ELSIF ( p_x_material_req_rec.attribute2 IS NULL ) THEN
    p_x_material_req_rec.attribute2 := l_old_material_req_rec.attribute2;
  END IF;

  IF ( p_x_material_req_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute3 := null;
  ELSIF ( p_x_material_req_rec.attribute3 IS NULL ) THEN
    p_x_material_req_rec.attribute3 := l_old_material_req_rec.attribute3;
  END IF;

  IF ( p_x_material_req_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute4 := null;
  ELSIF ( p_x_material_req_rec.attribute4 IS NULL ) THEN
    p_x_material_req_rec.attribute4 := l_old_material_req_rec.attribute4;
  END IF;

  IF ( p_x_material_req_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute5 := null;
  ELSIF ( p_x_material_req_rec.attribute5 IS NULL ) THEN
    p_x_material_req_rec.attribute5 := l_old_material_req_rec.attribute5;
  END IF;

  IF ( p_x_material_req_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute6 := null;
  ELSIF ( p_x_material_req_rec.attribute6 IS NULL ) THEN
    p_x_material_req_rec.attribute6 := l_old_material_req_rec.attribute6;
  END IF;

  IF ( p_x_material_req_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute7 := null;
  ELSIF ( p_x_material_req_rec.attribute7 IS NULL ) THEN
    p_x_material_req_rec.attribute7 := l_old_material_req_rec.attribute7;
  END IF;

  IF ( p_x_material_req_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute8 := null;
  ELSIF ( p_x_material_req_rec.attribute8 IS NULL ) THEN
    p_x_material_req_rec.attribute8 := l_old_material_req_rec.attribute8;
  END IF;

  IF ( p_x_material_req_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute9 := null;
  ELSIF ( p_x_material_req_rec.attribute9 IS NULL ) THEN
    p_x_material_req_rec.attribute9 := l_old_material_req_rec.attribute9;
  END IF;

  IF ( p_x_material_req_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute10 := null;
  ELSIF ( p_x_material_req_rec.attribute10 IS NULL ) THEN
    p_x_material_req_rec.attribute10 := l_old_material_req_rec.attribute10;
  END IF;

  IF ( p_x_material_req_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute11 := null;
  ELSIF ( p_x_material_req_rec.attribute11 IS NULL ) THEN
    p_x_material_req_rec.attribute11 := l_old_material_req_rec.attribute11;
  END IF;

  IF ( p_x_material_req_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute12 := null;
  ELSIF ( p_x_material_req_rec.attribute12 IS NULL ) THEN
    p_x_material_req_rec.attribute12 := l_old_material_req_rec.attribute12;
  END IF;

  IF ( p_x_material_req_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute13 := null;
  ELSIF ( p_x_material_req_rec.attribute13 IS NULL ) THEN
    p_x_material_req_rec.attribute13 := l_old_material_req_rec.attribute13;
  END IF;

  IF ( p_x_material_req_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute14 := null;
  ELSIF ( p_x_material_req_rec.attribute14 IS NULL ) THEN
    p_x_material_req_rec.attribute14 := l_old_material_req_rec.attribute14;
  END IF;

  IF ( p_x_material_req_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.attribute15 := null;
  ELSIF ( p_x_material_req_rec.attribute15 IS NULL ) THEN
    p_x_material_req_rec.attribute15 := l_old_material_req_rec.attribute15;
  END IF;

   IF ( p_x_material_req_rec.exclude_flag = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.exclude_flag := null;
  ELSIF ( p_x_material_req_rec.exclude_flag IS NULL ) THEN
    p_x_material_req_rec.exclude_flag := l_old_material_req_rec.exclude_flag;
  END IF;

  --pdoki added for OGMA 105 issue
   IF ( p_x_material_req_rec.in_service = FND_API.G_MISS_CHAR ) THEN
    p_x_material_req_rec.in_service := null;
  ELSIF ( p_x_material_req_rec.in_service IS NULL ) THEN
    p_x_material_req_rec.in_service := l_old_material_req_rec.in_service;
  END IF;

  IF ( p_x_material_req_rec.rework_percent = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.rework_percent := null;
  ELSIF ( p_x_material_req_rec.rework_percent IS NULL ) THEN
    p_x_material_req_rec.rework_percent := l_old_material_req_rec.rework_percent;
  END IF;

  IF ( p_x_material_req_rec.replace_percent = FND_API.G_MISS_NUM ) THEN
    p_x_material_req_rec.replace_percent := null;
  ELSIF ( p_x_material_req_rec.replace_percent IS NULL ) THEN
    p_x_material_req_rec.replace_percent := l_old_material_req_rec.replace_percent;
  END IF;

END default_unchanged_attributes;

 -- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_efct_unchange_attribs
(
  p_x_route_efct_rec       IN OUT NOCOPY   route_efct_rec_type
)
IS

l_old_route_efct_rec       route_efct_rec_type;

CURSOR get_old_rec ( C_ROUTE_EFFECTIVITY_ID NUMBER )
IS
SELECT
inventory_item_id
, inventory_master_org_id
, concatenated_segments
, item_description
, organization_code
, mc_id
, mc_name
, mc_revision
, mc_header_id
, attribute_category
, attribute1
, attribute2
, attribute3
, attribute4
, attribute5
, attribute6
, attribute7
, attribute8
, attribute9
, attribute10
, attribute11
, attribute12
, attribute13
, attribute14
, attribute15
from ahl_route_effectivities_v
WHERE   ROUTE_EFFECTIVITY_ID = C_ROUTE_EFFECTIVITY_ID
;

BEGIN

  -- Get the old record from AHL_RT_OPER_MATERIALS.
  OPEN  get_old_rec( p_x_route_efct_rec.ROUTE_EFFECTIVITY_ID );

  FETCH get_old_rec INTO
        l_old_route_efct_rec.inventory_item_id
        ,l_old_route_efct_rec.inventory_master_org_id
        ,l_old_route_efct_rec.ITEM_NUMBER
        ,l_old_route_efct_rec.description
        ,l_old_route_efct_rec.organization_code
        ,l_old_route_efct_rec.mc_id
        ,l_old_route_efct_rec.MC_NAME
        ,l_old_route_efct_rec.mc_revision
        ,l_old_route_efct_rec.mc_header_id
        ,l_old_route_efct_rec.attribute_category
        ,l_old_route_efct_rec.attribute1
        ,l_old_route_efct_rec.attribute2
        ,l_old_route_efct_rec.attribute3
        ,l_old_route_efct_rec.attribute4
        ,l_old_route_efct_rec.attribute5
        ,l_old_route_efct_rec.attribute6
        ,l_old_route_efct_rec.attribute7
        ,l_old_route_efct_rec.attribute8
        ,l_old_route_efct_rec.attribute9
        ,l_old_route_efct_rec.attribute10
        ,l_old_route_efct_rec.attribute11
        ,l_old_route_efct_rec.attribute12
        ,l_old_route_efct_rec.attribute13
        ,l_old_route_efct_rec.attribute14
        ,l_old_route_efct_rec.attribute15 ;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_efct_REC' );
--    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_route_efct_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_route_efct_rec.mc_header_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.mc_header_id := null;
  ELSIF ( p_x_route_efct_rec.mc_header_id IS NULL ) THEN
    p_x_route_efct_rec.mc_header_id := l_old_route_efct_rec.mc_header_id;
  END IF;

  IF ( p_x_route_efct_rec.mc_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.mc_id := null;
  ELSIF ( p_x_route_efct_rec.mc_id IS NULL ) THEN
    p_x_route_efct_rec.mc_id := l_old_route_efct_rec.mc_id;
  END IF;

  IF ( p_x_route_efct_rec.mc_name = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.mc_name := null;
  ELSIF ( p_x_route_efct_rec.mc_name IS NULL ) THEN
    p_x_route_efct_rec.mc_name := l_old_route_efct_rec.mc_name;
  END IF;

  IF ( p_x_route_efct_rec.MC_REVISION = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.MC_REVISION := null;
  ELSIF ( p_x_route_efct_rec.MC_REVISION IS NULL ) THEN
    p_x_route_efct_rec.MC_REVISION := l_old_route_efct_rec.MC_REVISION;
  END IF;

  IF ( p_x_route_efct_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.inventory_item_id := null;
  ELSIF ( p_x_route_efct_rec.inventory_item_id IS NULL ) THEN
    p_x_route_efct_rec.inventory_item_id := l_old_route_efct_rec.inventory_item_id;
  END IF;

  IF ( p_x_route_efct_rec.inventory_master_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_efct_rec.inventory_master_org_id := null;
  ELSIF ( p_x_route_efct_rec.inventory_master_org_id IS NULL ) THEN
    p_x_route_efct_rec.inventory_master_org_id := l_old_route_efct_rec.inventory_master_org_id;
  END IF;

  IF ( p_x_route_efct_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.item_number := null;
  ELSIF ( p_x_route_efct_rec.item_number IS NULL ) THEN
    p_x_route_efct_rec.item_number := l_old_route_efct_rec.item_number;
  END IF;


  IF ( p_x_route_efct_rec.organization_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.organization_code := null;
  ELSIF ( p_x_route_efct_rec.organization_code IS NULL ) THEN
    p_x_route_efct_rec.organization_code := l_old_route_efct_rec.organization_code;
  END IF;

  IF ( p_x_route_efct_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute_category := null;
  ELSIF ( p_x_route_efct_rec.attribute_category IS NULL ) THEN
    p_x_route_efct_rec.attribute_category := l_old_route_efct_rec.attribute_category;
  END IF;

  IF ( p_x_route_efct_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute1 := null;
  ELSIF ( p_x_route_efct_rec.attribute1 IS NULL ) THEN
    p_x_route_efct_rec.attribute1 := l_old_route_efct_rec.attribute1;
  END IF;

  IF ( p_x_route_efct_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute2 := null;
  ELSIF ( p_x_route_efct_rec.attribute2 IS NULL ) THEN
    p_x_route_efct_rec.attribute2 := l_old_route_efct_rec.attribute2;
  END IF;

  IF ( p_x_route_efct_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute3 := null;
  ELSIF ( p_x_route_efct_rec.attribute3 IS NULL ) THEN
    p_x_route_efct_rec.attribute3 := l_old_route_efct_rec.attribute3;
  END IF;

  IF ( p_x_route_efct_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute4 := null;
  ELSIF ( p_x_route_efct_rec.attribute4 IS NULL ) THEN
    p_x_route_efct_rec.attribute4 := l_old_route_efct_rec.attribute4;
  END IF;

  IF ( p_x_route_efct_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute5 := null;
  ELSIF ( p_x_route_efct_rec.attribute5 IS NULL ) THEN
    p_x_route_efct_rec.attribute5 := l_old_route_efct_rec.attribute5;
  END IF;

  IF ( p_x_route_efct_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute6 := null;
  ELSIF ( p_x_route_efct_rec.attribute6 IS NULL ) THEN
    p_x_route_efct_rec.attribute6 := l_old_route_efct_rec.attribute6;
  END IF;

  IF ( p_x_route_efct_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute7 := null;
  ELSIF ( p_x_route_efct_rec.attribute7 IS NULL ) THEN
    p_x_route_efct_rec.attribute7 := l_old_route_efct_rec.attribute7;
  END IF;

  IF ( p_x_route_efct_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute8 := null;
  ELSIF ( p_x_route_efct_rec.attribute8 IS NULL ) THEN
    p_x_route_efct_rec.attribute8 := l_old_route_efct_rec.attribute8;
  END IF;

  IF ( p_x_route_efct_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute9 := null;
  ELSIF ( p_x_route_efct_rec.attribute9 IS NULL ) THEN
    p_x_route_efct_rec.attribute9 := l_old_route_efct_rec.attribute9;
  END IF;

  IF ( p_x_route_efct_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute10 := null;
  ELSIF ( p_x_route_efct_rec.attribute10 IS NULL ) THEN
    p_x_route_efct_rec.attribute10 := l_old_route_efct_rec.attribute10;
  END IF;

  IF ( p_x_route_efct_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute11 := null;
  ELSIF ( p_x_route_efct_rec.attribute11 IS NULL ) THEN
    p_x_route_efct_rec.attribute11 := l_old_route_efct_rec.attribute11;
  END IF;

  IF ( p_x_route_efct_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute12 := null;
  ELSIF ( p_x_route_efct_rec.attribute12 IS NULL ) THEN
    p_x_route_efct_rec.attribute12 := l_old_route_efct_rec.attribute12;
  END IF;

  IF ( p_x_route_efct_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute13 := null;
  ELSIF ( p_x_route_efct_rec.attribute13 IS NULL ) THEN
    p_x_route_efct_rec.attribute13 := l_old_route_efct_rec.attribute13;
  END IF;

  IF ( p_x_route_efct_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute14 := null;
  ELSIF ( p_x_route_efct_rec.attribute14 IS NULL ) THEN
    p_x_route_efct_rec.attribute14 := l_old_route_efct_rec.attribute14;
  END IF;

  IF ( p_x_route_efct_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_efct_rec.attribute15 := null;
  ELSIF ( p_x_route_efct_rec.attribute15 IS NULL ) THEN
    p_x_route_efct_rec.attribute15 := l_old_route_efct_rec.attribute15;
  END IF;

END default_efct_unchange_attribs;

-- Procedure to validate individual material_req attributes
PROCEDURE validate_attributes
(
  p_material_req_rec      IN    material_req_rec_type,
  p_association_type      IN   VARCHAR2,
  x_return_status         OUT NOCOPY    VARCHAR2
)
IS

CURSOR get_comms_nl_trackable_flag ( c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
                         c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE )
IS
SELECT DISTINCT MI.comms_nl_trackable_flag
FROM            MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE           MP.organization_id = MI.organization_id
AND             MI.inventory_item_id = c_inventory_item_id
AND             MI.organization_id = c_inventory_org_id
AND             MI.enabled_flag = 'Y'
AND             SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
                        AND     NVL( MI.end_date_active, SYSDATE );

l_comms_nl_trackable_flag  MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG%TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_material_req_rec.dml_operation <> 'D' ) THEN

    -- Check if the Quantity does not column contains a null value.
    -- Check if the Quantity does not column a value less than or equal to zero.
    IF ( p_material_req_rec.dml_operation = 'C' AND
--         p_association_type <> 'DISPOSITION' AND
         (p_material_req_rec.quantity IS NULL OR p_material_req_rec.quantity = FND_API.G_MISS_NUM)
        ) THEN
      IF (p_association_type = 'DISPOSITION')
      THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_ITEM_QTY_NULL' );
      ELSE
      FND_MESSAGE.set_name( 'AHL','AHL_RM_MTL_QTY_NULL' );
      END IF;
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF ( p_material_req_rec.dml_operation <> 'D' AND
            p_material_req_rec.quantity <= 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_MTL_QTY_LESS_ZERO' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF ( p_material_req_rec.dml_operation <> 'D' AND
         p_association_type = 'DISPOSITION'
    AND
  (p_material_req_rec.INVENTORY_ITEM_ID IS NOT NULL OR p_material_req_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM )
  AND
    (p_material_req_rec.quantity IS NULL OR p_material_req_rec.quantity = FND_API.G_MISS_NUM)     ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_ITEM_QTY_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Check if the UOM not column contains a null value.
    IF ( ( p_material_req_rec.dml_operation <> 'D' AND
--           p_association_type <> 'DISPOSITION' AND
           p_material_req_rec.uom IS NULL AND
           p_material_req_rec.uom_code IS NULL ) OR
         ( p_material_req_rec.uom = FND_API.G_MISS_CHAR AND
           p_material_req_rec.uom_code = FND_API.G_MISS_CHAR ) )
     THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_UOM_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      /*
    ELSIF
           p_material_req_rec.dml_operation <> 'D'
       AND p_association_type = 'DISPOSITION'
       AND (
               p_material_req_rec.quantity IS NOT NULL
            OR p_material_req_rec.quantity <> FND_API.G_MISS_NUM
            )
       AND  (
            (p_material_req_rec.uom IS NULL AND p_material_req_rec.uom_code IS NULL )
            OR
         (p_material_req_rec.uom = FND_API.G_MISS_CHAR AND p_material_req_rec.uom_code = FND_API.G_MISS_CHAR)
         )
     THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_UOM_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      */
     END IF;

  END IF;

   IF ( p_association_type = 'DISPOSITION' AND
        p_material_req_rec.dml_operation <> 'D' AND
      (
       (p_material_req_rec.REPLACE_PERCENT IS NOT NULL OR p_material_req_rec.REPLACE_PERCENT <> FND_API.G_MISS_NUM )
    OR (p_material_req_rec.REWORK_PERCENT IS NOT NULL OR p_material_req_rec.REWORK_PERCENT <> FND_API.G_MISS_NUM )
       )
    AND
     (
         (p_material_req_rec.POSITION_PATH_ID IS NULL OR p_material_req_rec.POSITION_PATH_ID = FND_API.G_MISS_NUM )
     AND (p_material_req_rec.ITEM_GROUP_ID  IS NULL OR p_material_req_rec.ITEM_GROUP_ID  = FND_API.G_MISS_NUM )
     AND (p_material_req_rec.INVENTORY_ITEM_ID IS NULL OR p_material_req_rec.INVENTORY_ITEM_ID  = FND_API.G_MISS_NUM )
     )
      )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REPLACE_INVALID' );
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REWORK_INVALID' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF ;

   -- Check if the mandatory Replace column contains a null value.
  IF ( p_association_type = 'DISPOSITION' AND
       p_material_req_rec.dml_operation <> 'D' AND
      ( p_material_req_rec.REPLACE_PERCENT IS NULL OR
       p_material_req_rec.REPLACE_PERCENT = FND_API.G_MISS_NUM )
     )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REPLACE_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF ( p_association_type = 'DISPOSITION' AND
  p_material_req_rec.dml_operation <> 'D' AND
      NOT ( p_material_req_rec.REPLACE_PERCENT BETWEEN 0 AND 100 )
     )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REPLACE_INVALID' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  -- Check if the  Rework column contains a null value.
  OPEN get_comms_nl_trackable_flag( p_material_req_rec.INVENTORY_ITEM_ID , p_material_req_rec.INVENTORY_ORG_ID );
  FETCH get_comms_nl_trackable_flag INTO  l_comms_nl_trackable_flag;
  l_comms_nl_trackable_flag := NVL(l_comms_nl_trackable_flag,'N');
  CLOSE get_comms_nl_trackable_flag;

  IF (
  p_association_type = 'DISPOSITION' AND p_material_req_rec.dml_operation <> 'D'
  AND
  (
    ( ( p_material_req_rec.POSITION_PATH_ID IS NOT NULL AND p_material_req_rec.POSITION_PATH_ID <> FND_API.G_MISS_NUM )
     AND (p_material_req_rec.ITEM_GROUP_ID  IS NULL OR p_material_req_rec.ITEM_GROUP_ID  = FND_API.G_MISS_NUM )
   AND (p_material_req_rec.INVENTORY_ITEM_ID IS NULL OR p_material_req_rec.INVENTORY_ITEM_ID  = FND_API.G_MISS_NUM )
       )
     OR
    ( (p_material_req_rec.INVENTORY_ITEM_ID IS NOT NULL AND p_material_req_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM)
      AND (nvl(p_material_req_rec.COMP_MATERIAL_FLAG, 'N') = 'N' AND ((l_comms_nl_trackable_flag IS NOT NULL) AND (l_comms_nl_trackable_flag = 'Y')))
    -- to throw this error , item has to be an Additional Material and also a trackable item.
    -- if the item is from Composition then we do not check whether its trackable or not as its possible to go to Inventory and change the trackable flag.
    -- and under any condition COMP_MATERIAL_FLAG = 'Y' this error will never be thrown
    )
  )
   AND
   ( p_material_req_rec.REWORK_PERCENT IS NULL OR p_material_req_rec.REWORK_PERCENT = FND_API.G_MISS_NUM )
    )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REWORK_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSIF ( p_association_type = 'DISPOSITION' AND
          p_material_req_rec.dml_operation <> 'D'
  AND
  (
   (p_material_req_rec.POSITION_PATH_ID IS NOT NULL AND p_material_req_rec.POSITION_PATH_ID <> FND_API.G_MISS_NUM )

  OR
  ( (p_material_req_rec.INVENTORY_ITEM_ID IS NOT NULL AND p_material_req_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM)
      AND ((l_comms_nl_trackable_flag IS NOT NULL) AND (l_comms_nl_trackable_flag = 'Y'))
   )
   )
  AND NOT ( p_material_req_rec.REWORK_PERCENT BETWEEN 0 AND 100 )
     )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REWORK_INVALID' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
-- if item group then rework percent should not be allowed to be entered.
  IF
  (
   (p_association_type = 'DISPOSITION' AND p_material_req_rec.dml_operation <> 'D')
   AND
   (
     (
      (
       (p_material_req_rec.ITEM_GROUP_ID  <> FND_API.G_MISS_NUM  AND p_material_req_rec.ITEM_GROUP_ID IS NOT NULL )
       OR
       (p_material_req_rec.ITEM_GROUP_NAME  <> FND_API.G_MISS_CHAR  AND p_material_req_rec.ITEM_GROUP_NAME IS NOT NULL )
      )
    OR
     (
       ( p_material_req_rec.INVENTORY_ITEM_ID <> FND_API.G_MISS_NUM AND p_material_req_rec.INVENTORY_ITEM_ID IS NOT NULL )
        AND
            (p_material_req_rec.COMP_MATERIAL_FLAG = 'Y' OR ( nvl(p_material_req_rec.COMP_MATERIAL_FLAG, 'N') <> 'Y' AND l_comms_nl_trackable_flag <> 'Y'))
     )
    )
      AND
      (p_material_req_rec.REWORK_PERCENT <> FND_API.G_MISS_NUM OR p_material_req_rec.REWORK_PERCENT IS NOT NULL )
     --if non trackable item then rework percent should not be allowed to be entered.

   )
  )
  THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_DISP_REWORK_NOT_REQ' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF ( p_material_req_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the mandatory Effectivity ID column contains a null value.
  IF ( p_material_req_rec.rt_oper_material_id IS NULL OR
       p_material_req_rec.rt_oper_material_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_MTL_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_material_req_rec.object_version_number IS NULL OR
       p_material_req_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_MTL_OBJ_VERSION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;



END validate_attributes;

-- Procedure to validate individual efct attributes
PROCEDURE validate_efct_attributes
(
  p_route_efct_rec      IN    route_efct_rec_type,
  x_return_status                OUT NOCOPY    VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF ( p_route_efct_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the mandatory  column contains a null value.
  IF ( p_route_efct_rec.ROUTE_EFFECTIVITY_ID IS NULL OR
       p_route_efct_rec.ROUTE_EFFECTIVITY_ID = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_efct_ID_NULL' );
--    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_route_efct_rec.object_version_number IS NULL OR
       p_route_efct_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_efct_OBJ_VERSION_NULL' );
--    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

END validate_efct_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_record
(
  p_material_req_rec       IN    material_req_rec_type,
  p_association_type       IN    VARCHAR2,
  x_return_status          OUT NOCOPY   VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if both Item Group and Item are NULL
  IF ( p_association_type <> 'DISPOSITION' AND
       p_material_req_rec.item_group_id IS NULL AND
       p_material_req_rec.item_group_name IS NULL AND
       p_material_req_rec.inventory_item_id IS NULL AND
       p_material_req_rec.inventory_org_id IS NULL AND
       p_material_req_rec.item_number IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ITEMGRP_ITEM_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if both Item Group and Item contain values
  IF (
  --p_association_type <> 'DISPOSITION' AND
       ( p_material_req_rec.inventory_item_id IS NOT NULL OR
         p_material_req_rec.inventory_org_id IS NOT NULL OR
         p_material_req_rec.item_number IS NOT NULL ) AND
       ( p_material_req_rec.item_group_id IS NOT NULL OR
         p_material_req_rec.item_group_name IS NOT NULL ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ITEMGRP_ITEM_NOTNULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the given UOM is valid for the given Item
  IF ( p_material_req_rec.uom_code IS NOT NULL AND
       ( p_material_req_rec.item_group_id IS NOT NULL OR
         ( p_material_req_rec.inventory_item_id IS NOT NULL AND
           p_material_req_rec.inventory_org_id IS NOT NULL ) ) ) THEN
    AHL_RM_ROUTE_UTIL.validate_item_uom
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_item_group_id          => p_material_req_rec.item_group_id,
      p_inventory_item_id      => p_material_req_rec.inventory_item_id,
      p_inventory_org_id       => p_material_req_rec.inventory_org_id,
      p_uom_code               => p_material_req_rec.uom_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      IF ( p_material_req_rec.uom IS NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD1', p_material_req_rec.uom_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD1', p_material_req_rec.uom );
      END IF;

      IF ( p_material_req_rec.item_number IS NOT NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD2', p_material_req_rec.item_number );
      ELSIF ( p_material_req_rec.inventory_item_id IS NOT NULL AND
              p_material_req_rec.inventory_org_id IS NOT NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD2', TO_CHAR( p_material_req_rec.inventory_item_id ) || '-' || TO_CHAR( p_material_req_rec.inventory_org_id ) );
      ELSIF ( p_material_req_rec.item_group_name IS NOT NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD2', p_material_req_rec.item_group_name );
      ELSIF ( p_material_req_rec.item_group_id IS NOT NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD2', TO_CHAR( p_material_req_rec.item_group_id ) );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_material_req_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

END validate_record;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_efct_record
(
  p_route_efct_rec       IN    route_efct_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if both MC and Item are NULL
  IF ( p_route_efct_rec.mc_id IS NULL AND
       p_route_efct_rec.mc_name IS NULL AND
       p_route_efct_rec.inventory_item_id IS NULL AND
       p_route_efct_rec.inventory_master_org_id IS NULL AND
       p_route_efct_rec.item_number IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_EFCT_ITEM_NULL' );
  --  FND_MESSAGE.set_token( 'RECORD', get_effct_identifier( p_route_efct_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if both MC and Item contain values
  IF ( ( p_route_efct_rec.inventory_item_id IS NOT NULL OR
         p_route_efct_rec.inventory_master_org_id IS NOT NULL OR
         p_route_efct_rec.item_number IS NOT NULL OR
         p_route_efct_rec.ORGANIZATION_CODE IS NOT NULL

         ) AND
       ( p_route_efct_rec.mc_id IS NOT NULL OR
         p_route_efct_rec.mc_name IS NOT NULL OR
          p_route_efct_rec.MC_REVISION IS NOT NULL OR
         p_route_efct_rec.MC_HEADER_ID  IS NOT NULL
         ) )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_efct_ITEM_NOTNULL' );
    FND_MESSAGE.set_token( 'RECORD', get_effct_identifier( p_route_efct_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if both Org and Item contain values
  IF ( ( p_route_efct_rec.inventory_item_id IS NOT NULL OR p_route_efct_rec.item_number IS NOT NULL )
    AND ( p_route_efct_rec.inventory_master_org_id IS NULL OR p_route_efct_rec.organization_code IS NULL)
     )
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_efct_ITEM_ORG_NOTNULL' );
   -- FND_MESSAGE.set_token( 'RECORD', get_effct_identifier( p_route_efct_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


END validate_efct_record;


-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_object_id             IN    NUMBER,
  p_association_type      IN    VARCHAR2,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

l_material_req_rec        material_req_rec_type;
l_association_type VARCHAR2(30);
l_description VARCHAR2(240);

CURSOR get_dup_rec ( c_object_id NUMBER , c_association_type VARCHAR )
IS
SELECT
         ROMV.ASSOCIATION_TYPE_CODE,
         ROMV.POSITION_PATH_ID,
         ROMV.item_group_id,
         ROMV.inventory_item_id,
         ROMV.inventory_org_id
FROM
   AHL_RT_OPER_MATERIALS ROMV
WHERE
  ROMV.object_id = c_object_id AND
  ROMV.association_type_code = c_association_type AND
  NOT EXISTS
   (SELECT item_comp_detail_id
    FROM ahl_item_comp_details
    WHERE item_comp_detail_id = ROMV.item_comp_detail_id
    AND
    effective_end_date is not null)
GROUP BY
         ROMV.ASSOCIATION_TYPE_CODE,
         ROMV.POSITION_PATH_ID,
         ROMV.item_group_id,
         ROMV.inventory_item_id,
         ROMV.inventory_org_id
HAVING   count(*) > 1;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
  IF ( p_association_type = 'DISPOSITION' ) THEN
  RETURN ;
  END IF;
*/
  -- Check whether any duplicate material_req records (based on Name) for the given OBJECT_ID and ASSOCIATION_TYPE
  OPEN  get_dup_rec( p_object_id , p_association_type );

  LOOP

    FETCH get_dup_rec INTO
      l_association_type,
      l_material_req_rec.POSITION_PATH_ID,
      l_material_req_rec.item_group_id,
      l_material_req_rec.inventory_item_id,
      l_material_req_rec.inventory_org_id;

      IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug( 'association_type : ' || l_association_type );
     AHL_DEBUG_PUB.debug( 'POSITION_PATH_ID : ' || l_material_req_rec.POSITION_PATH_ID);
     AHL_DEBUG_PUB.debug( 'item_group_id : ' || l_material_req_rec.item_group_id);
     AHL_DEBUG_PUB.debug( 'inventory_item_id : ' || l_material_req_rec.inventory_item_id);
       AHL_DEBUG_PUB.debug( 'inventory_org_id : ' || l_material_req_rec.inventory_org_id);
     END IF;
     EXIT WHEN get_dup_rec%NOTFOUND;

     FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MATERIAL_REQ_REC_DUP' );
     FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_material_req_rec ) );
     FND_MSG_PUB.add;

  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

END validate_records;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_efct_records
(
  p_object_id             IN    NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

l_route_efct_req_rec        route_efct_rec_type;

/*CURSOR get_dup_rec ( c_object_id NUMBER )
IS
SELECT
         mc_id,
         mc_name,
         MC_REVISION,
         mc_header_id,
         organization_code,
         inventory_item_id,
         inventory_master_org_id,
         CONCATENATED_SEGMENTS,
         item_description
FROM     AHL_ROUTE_EFFECTIVITIES_V
WHERE    ROUTE_ID = c_object_id
GROUP BY
         mc_id,
         mc_name,
         MC_REVISION,
         mc_header_id,
         organization_code,
         inventory_item_id,
         inventory_master_org_id,
         CONCATENATED_SEGMENTS,
         item_description
HAVING   count(*) > 1;*/

--Bug 4913141. AMSRINIV. Tuned the above commented query.Using base table directly instead of View.
CURSOR get_dup_rec ( c_object_id NUMBER )
IS
SELECT   mc_id,
         mc_header_id,
         inventory_item_id,
         inventory_master_org_id
FROM     AHL_ROUTE_EFFECTIVITIES
WHERE    ROUTE_ID = c_object_id
GROUP BY
         mc_id,
         mc_header_id,
         inventory_item_id,
         inventory_master_org_id
HAVING   count(*) > 1;
--AMSRINIV.Bug 4913141. Code added
--BEGIN
CURSOR get_org_code ( c_inv_mast_org_id NUMBER )
IS
    SELECT DISTINCT ORGANIZATION_CODE
    FROM
    mtl_parameters MP
    WHERE
    MP.MASTER_ORGANIZATION_ID = c_inv_mast_org_id AND
    MP.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID;

CURSOR get_item_number ( c_inventory_item_id NUMBER, c_inventory_master_org_id NUMBER )
IS
    SELECT mtl.concatenated_segments
    FROM MTL_SYSTEM_ITEMS_KFV MTL
    WHERE
    mtl.ORGANIZATION_ID(+) = c_inventory_item_id AND
    mtl.inventory_item_id(+) = c_inventory_master_org_id;

CURSOR get_mc_name_and_revision ( c_mc_id NUMBER, c_mc_header_id NUMBER )
IS
    SELECT
        mc.name,
        DECODE(c_mc_header_id, NULL, NULL, mc.revision)
    FROM ahl_mc_headers_b mc
    WHERE
    NVL(c_mc_header_id, c_mc_id)=mc.mc_header_id(+) AND
    mc.CONFIG_STATUS_CODE(+)='COMPLETE';
--END
BEGIN

       IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check whether any duplicate records for the given OBJECT_ID
  OPEN  get_dup_rec( p_object_id );

  LOOP

    FETCH get_dup_rec INTO
      l_route_efct_req_rec.mc_id,
      l_route_efct_req_rec.mc_header_id,
      l_route_efct_req_rec.inventory_item_id,
      l_route_efct_req_rec.inventory_master_org_id;





    EXIT WHEN get_dup_rec%NOTFOUND;
--AMSRINIV.Bug 4913141. Code added
--BEGIN
    OPEN get_org_code ( l_route_efct_req_rec.inventory_master_org_id );
    FETCH get_org_code INTO l_route_efct_req_rec.organization_code;
    CLOSE get_org_code;

    OPEN get_item_number ( l_route_efct_req_rec.inventory_item_id, l_route_efct_req_rec.inventory_master_org_id );
    FETCH get_item_number INTO l_route_efct_req_rec.organization_code;
    CLOSE get_item_number;

    OPEN get_mc_name_and_revision ( l_route_efct_req_rec.mc_id, l_route_efct_req_rec.mc_header_id );
    FETCH get_mc_name_and_revision INTO
        l_route_efct_req_rec.mc_name,
        l_route_efct_req_rec.MC_REVISION;
    CLOSE get_mc_name_and_revision;
--END
    IF ( get_dup_rec%FOUND ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_route_efct_REC_DUP' );
    FND_MESSAGE.set_token( 'RECORD', get_effct_identifier( l_route_efct_req_rec ) );
    FND_MSG_PUB.add;
    END IF ;
  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

END validate_efct_records;



PROCEDURE process_material_req
(
 p_api_version        IN            NUMBER     := '1.0',
 p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN            VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count          OUT NOCOPY    NUMBER,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_x_material_req_tbl IN OUT NOCOPY material_req_tbl_type,
 p_object_id          IN            NUMBER,
 p_association_type   IN            VARCHAR2
)
IS
cursor get_route_status (p_route_id in number)
is
select revision_status_code
from ahl_routes_app_v
where route_id = p_route_id;

l_obj_status      VARCHAR2(30);

cursor get_oper_status (p_operation_id in number)
is
select revision_status_code
from ahl_operations_b
where operation_id = p_operation_id;

CURSOR get_efct_rec ( C_ROUTE_EFFECTIVITY_ID NUMBER )
IS
SELECT  RM.ROUTE_ID
FROM  ahl_route_effectivities refct, AHL_ROUTES_APP_V RM
WHERE refct.ROUTE_EFFECTIVITY_ID = C_ROUTE_EFFECTIVITY_ID
  AND RM.ROUTE_ID = refct.ROUTE_ID;

l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data        VARCHAR2(30);
l_rt_oper_material_id       NUMBER;
l_x_operation_rec           AHL_RM_OPERATION_PVT.operation_rec_type ;
l_x_route_rec               AHL_RM_ROUTE_PVT.route_rec_type ;
l_dummy_varchar       VARCHAR2(1);
l_dummy_number        NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_material_req_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    G_API_NAME,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' : Begin API' );
  END IF;


--This is to be added before calling   validate_efct_api_inputs
-- Validate Application Usage
IF (p_association_type  = 'ROUTE')
THEN
  AHL_RM_ROUTE_UTIL.validate_ApplnUsage
  (
     p_object_id              => p_object_id,
     p_association_type       => p_association_type,
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF;


  -- Validate all the inputs of the API
  validate_api_inputs
  (
    p_x_material_req_tbl, -- IN
    p_object_id, -- IN
    p_association_type, -- IN
    l_return_status -- OUT
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_material_req_tbl.count LOOP
      IF ( p_x_material_req_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_material_req_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
    FOR i IN 1..p_x_material_req_tbl.count LOOP
      IF ( p_x_material_req_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_material_req_tbl(i) , -- IN OUT Record with Values and Ids
          p_object_id,
          p_association_type, -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after convert_values_to_ids' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_material_req_tbl.count LOOP
    IF ( p_x_material_req_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_material_req_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_material_req_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_material_req_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
    FOR i IN 1..p_x_material_req_tbl.count LOOP
      validate_attributes
      (
        p_x_material_req_tbl(i), -- IN
        p_association_type, -- IN
        l_return_status -- OUT
      );

      -- If any severe error occurs, then, abort API.
/*      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;*/

    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
    FOR i IN 1..p_x_material_req_tbl.count LOOP
      IF ( p_x_material_req_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_x_material_req_tbl(i), -- IN
          p_association_type, -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
/*        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;*/
      END IF;
    END LOOP;

    -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_record' );
  END IF;


IF ( p_association_type = 'OPERATION')
THEN
  -- Check if the Route is existing and in Draft status
  AHL_RM_ROUTE_UTIL.validate_operation_status
  (
    p_object_id,
    l_msg_data,
    l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('AHL',l_msg_data);
    FND_MSG_PUB.ADD;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Update route status from APPROVAL_REJECTED to DRAFT
  OPEN get_oper_status (p_object_id);
  FETCH get_oper_status INTO l_obj_status;
  IF (get_oper_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
  THEN
    UPDATE ahl_operations_b
    SET revision_status_code = 'DRAFT'
    WHERE operation_id = p_object_id;
  END IF;
  CLOSE get_oper_status;

ELSIF (p_association_type = 'DISPOSITION')
THEN
  OPEN get_efct_rec ( p_object_id ) ;
  FETCH get_efct_rec INTO l_dummy_number;
  IF get_efct_rec%NOTFOUND
  THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_efct_REC' );
    FND_MSG_PUB.add;
    CLOSE get_efct_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_efct_rec;

  -- Check if the Route is existing and in Draft status
  AHL_RM_ROUTE_UTIL.validate_route_status
  (
    l_dummy_number,
    l_msg_data,
    l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('AHL',l_msg_data);
    FND_MSG_PUB.ADD;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Update route status from APPROVAL_REJECTED to DRAFT
  OPEN get_route_status (l_dummy_number);
  FETCH get_route_status INTO l_obj_status;
  IF (get_route_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
  THEN
    UPDATE ahl_routes_b
    SET revision_status_code = 'DRAFT'
    WHERE route_id = l_dummy_number;
  END IF;
  CLOSE get_route_status;

ELSIF ( p_association_type = 'ROUTE' )
THEN
  -- Check if the Route is existing and in Draft status
  AHL_RM_ROUTE_UTIL.validate_route_status
  (
    p_object_id,
    l_msg_data,
    l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('AHL',l_msg_data);
    FND_MSG_PUB.ADD;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Update route status from APPROVAL_REJECTED to DRAFT
  OPEN get_route_status (p_object_id);
  FETCH get_route_status INTO l_obj_status;
  IF (get_route_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
  THEN
    UPDATE ahl_routes_b
    SET revision_status_code = 'DRAFT'
    WHERE route_id = p_object_id;
  END IF;
  CLOSE get_route_status;
END IF ;


  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_material_req_tbl.count LOOP
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  p_x_material_req_tbl(i).dml_operation ' || p_x_material_req_tbl(i).dml_operation ) ;
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before DML p_object_id ' || p_object_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before DML p_association_type ' || p_association_type );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before DML p_x_material_req_tbl(i).position_path_id ' || p_x_material_req_tbl(i).position_path_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_material_req_tbl(i).item_group_id ' || p_x_material_req_tbl(i).item_group_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_material_req_tbl(i).inventory_item_id ' || p_x_material_req_tbl(i).inventory_item_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_material_req_tbl(i).inventory_org_id ' || p_x_material_req_tbl(i).inventory_org_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_material_req_tbl(i).uom_code ' || p_x_material_req_tbl(i).uom_code);
    END IF;
    IF ( p_x_material_req_tbl(i).dml_operation = 'C' ) THEN

      BEGIN
        -- Insert the record
        p_x_material_req_tbl(i).object_version_number := 1;

        INSERT INTO AHL_RT_OPER_MATERIALS
        (
          RT_OPER_MATERIAL_ID,
          OBJECT_VERSION_NUMBER,
          OBJECT_ID,
          ASSOCIATION_TYPE_CODE,
          POSITION_PATH_ID,
          ITEM_GROUP_ID,
          INVENTORY_ITEM_ID,
          INVENTORY_ORG_ID,
          UOM_CODE,
          QUANTITY,
          ITEM_COMP_DETAIL_ID,
          EXCLUDE_FLAG,
          REWORK_PERCENT,
          REPLACE_PERCENT,
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
          ATTRIBUTE15,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          IN_SERVICE --pdoki added for OGMA 105 issue
        ) VALUES
        (
          AHL_RT_OPER_MATERIALS_S.NEXTVAL,
          p_x_material_req_tbl(i).object_version_number,
          p_object_id,
          p_association_type,
          p_x_material_req_tbl(i).position_path_id ,
          p_x_material_req_tbl(i).item_group_id,
          p_x_material_req_tbl(i).inventory_item_id,
          p_x_material_req_tbl(i).inventory_org_id,
          p_x_material_req_tbl(i).uom_code,
          p_x_material_req_tbl(i).quantity,
          p_x_material_req_tbl(i).item_comp_detail_id,
          p_x_material_req_tbl(i).exclude_flag,
          p_x_material_req_tbl(i).rework_percent,
          p_x_material_req_tbl(i).replace_percent,
          p_x_material_req_tbl(i).attribute_category,
          p_x_material_req_tbl(i).attribute1,
          p_x_material_req_tbl(i).attribute2,
          p_x_material_req_tbl(i).attribute3,
          p_x_material_req_tbl(i).attribute4,
          p_x_material_req_tbl(i).attribute5,
          p_x_material_req_tbl(i).attribute6,
          p_x_material_req_tbl(i).attribute7,
          p_x_material_req_tbl(i).attribute8,
          p_x_material_req_tbl(i).attribute9,
          p_x_material_req_tbl(i).attribute10,
          p_x_material_req_tbl(i).attribute11,
          p_x_material_req_tbl(i).attribute12,
          p_x_material_req_tbl(i).attribute13,
          p_x_material_req_tbl(i).attribute14,
          p_x_material_req_tbl(i).attribute15,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          FND_GLOBAL.login_id,
          p_x_material_req_tbl(i).in_service --pdoki added for OGMA 105 issue
        ) RETURNING rt_oper_material_id INTO l_rt_oper_material_id;

      IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_object_id ' || p_object_id );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_association_type ' || p_association_type );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).position_path_id ' || p_x_material_req_tbl(i).position_path_id );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).item_group_id ' || p_x_material_req_tbl(i).item_group_id );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).inventory_item_id ' || p_x_material_req_tbl(i).inventory_item_id );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).inventory_org_id ' || p_x_material_req_tbl(i).inventory_org_id );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).uom_code ' || p_x_material_req_tbl(i).uom_code);
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).quantity ' || p_x_material_req_tbl(i).quantity);
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).item_comp_detail_id ' || p_x_material_req_tbl(i).item_comp_detail_id);
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).exclude_flag ' || p_x_material_req_tbl(i).exclude_flag );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).rework_percent ' || p_x_material_req_tbl(i).rework_percent );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_material_req_tbl(i).replace_percent ' || p_x_material_req_tbl(i).replace_percent );
          AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert l_rt_oper_material_id' || l_rt_oper_material_id);
      END IF;

        -- Set OUT values
        p_x_material_req_tbl(i).rt_oper_material_id := l_rt_oper_material_id;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MATERIAL_REQ_REC_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_tbl(i) ) );
            FND_MSG_PUB.add;
          ELSE
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected,
        'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME,
        'AHL_RT_OPER_MATERIALS insert error = ['||SQLERRM||']'
      );
    END IF;
          END IF;
      END;

    ELSIF ( p_x_material_req_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_RT_OPER_MATERIALS SET
          object_version_number   = object_version_number + 1,
          item_comp_detail_id     = p_x_material_req_tbl(i).item_comp_detail_id ,
          position_path_id        = p_x_material_req_tbl(i).position_path_id ,
          item_group_id           = p_x_material_req_tbl(i).item_group_id,
          inventory_item_id       = p_x_material_req_tbl(i).inventory_item_id,
          inventory_org_id        = p_x_material_req_tbl(i).inventory_org_id,
          uom_code                = p_x_material_req_tbl(i).uom_code,
          quantity                = p_x_material_req_tbl(i).quantity,
          exclude_flag            = p_x_material_req_tbl(i).exclude_flag,
          in_service              = p_x_material_req_tbl(i).in_service, --pdoki added for OGMA 105 issue
          rework_percent          = p_x_material_req_tbl(i).rework_percent,
          replace_percent         = p_x_material_req_tbl(i).replace_percent,
          attribute_category      = p_x_material_req_tbl(i).attribute_category,
          attribute1              = p_x_material_req_tbl(i).attribute1,
          attribute2              = p_x_material_req_tbl(i).attribute2,
          attribute3              = p_x_material_req_tbl(i).attribute3,
          attribute4              = p_x_material_req_tbl(i).attribute4,
          attribute5              = p_x_material_req_tbl(i).attribute5,
          attribute6              = p_x_material_req_tbl(i).attribute6,
          attribute7              = p_x_material_req_tbl(i).attribute7,
          attribute8              = p_x_material_req_tbl(i).attribute8,
          attribute9              = p_x_material_req_tbl(i).attribute9,
          attribute10             = p_x_material_req_tbl(i).attribute10,
          attribute11             = p_x_material_req_tbl(i).attribute11,
          attribute12             = p_x_material_req_tbl(i).attribute12,
          attribute13             = p_x_material_req_tbl(i).attribute13,
          attribute14             = p_x_material_req_tbl(i).attribute14,
          attribute15             = p_x_material_req_tbl(i).attribute15,
          last_update_date        = SYSDATE,
          last_updated_by         = FND_GLOBAL.user_id,
          last_update_login       = FND_GLOBAL.login_id
        WHERE rt_oper_material_id = p_x_material_req_tbl(i).rt_oper_material_id
        AND object_version_number = p_x_material_req_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_tbl(i) ) );
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Set OUT values
        p_x_material_req_tbl(i).object_version_number := p_x_material_req_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MATERIAL_REQ_REC_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_material_req_tbl(i) ) );
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
    IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected,
        'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME,
        'AHL_RT_OPER_MATERIALS update error = ['||SQLERRM||']'
      );
    END IF;
          END IF;
      END;

    ELSIF ( p_x_material_req_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE AHL_RT_OPER_MATERIALS
      WHERE rt_oper_material_id = p_x_material_req_tbl(i).rt_oper_material_id
      AND object_version_number = p_x_material_req_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;
  END LOOP;


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after DML operation' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform cross records validations and duplicate records check
 validate_records
  (
    p_object_id, -- IN
    p_association_type, -- IN
    l_return_status -- OUT
  );
  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_records' );
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get
  (
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data
  );

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_material_req_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_material_req_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO process_material_req_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => G_API_NAME,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END process_material_req;

PROCEDURE process_route_efcts
(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN            VARCHAR2   := NULL,
  p_object_id                 IN      NUMBER,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_route_efct_tbl IN OUT NOCOPY route_efct_tbl_type
)
IS

cursor get_route_status (p_route_id in number)
is
select revision_status_code
from ahl_routes_app_v
where route_id = p_route_id;

l_obj_status      VARCHAR2(30);

l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data        VARCHAR2(30);
l_route_effectivitiy_id           NUMBER;
l_x_operation_rec           AHL_RM_OPERATION_PVT.operation_rec_type ;
l_x_route_rec               AHL_RM_ROUTE_PVT.route_rec_type ;
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_route_efcts;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    G_API_NAME1,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' : Begin API' );
  END IF;

--This is to be added before calling   validate_api_inputs
-- Validate Application Usage
  AHL_RM_ROUTE_UTIL.validate_ApplnUsage
  (
     p_object_id              => p_object_id,
     p_association_type       => 'ROUTE',
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate all the inputs of the API
  validate_efct_api_inputs
  (
    p_x_route_efct_tbl,
    p_object_id,
    l_return_status
  );

 -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_route_efct_tbl.count LOOP
      IF ( p_x_route_efct_tbl(i).dml_operation <> 'D' ) THEN
        clear_efct_attribute_ids
        (
          p_x_route_efct_tbl(i)
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
    FOR i IN 1..p_x_route_efct_tbl.count LOOP
      IF ( p_x_route_efct_tbl(i).dml_operation <> 'D' ) THEN
        convert_efct_values_to_ids
        (
          p_x_route_efct_tbl(i) ,
          l_return_status
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after convert_values_to_ids' );
  END IF;

  -- Validate all attributes (Item level validation)
    FOR i IN 1..p_x_route_efct_tbl.count LOOP
      validate_efct_attributes
      (
        p_x_route_efct_tbl(i),
        l_return_status
      );

      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_route_efct_tbl.count LOOP
    IF ( p_x_route_efct_tbl(i).dml_operation = 'U' ) THEN
      default_efct_unchange_attribs
      (
        p_x_route_efct_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_route_efct_tbl(i).dml_operation = 'C' ) THEN
      default_efct_miss_attributes
      (
        p_x_route_efct_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
    FOR i IN 1..p_x_route_efct_tbl.count LOOP
      IF ( p_x_route_efct_tbl(i).dml_operation <> 'D' ) THEN
        validate_efct_record
        (
          p_x_route_efct_tbl(i),
          l_return_status
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after validate_record' );
  END IF;
IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'Starting updating parent route/operation');
END IF;

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'p_association_type = ROUTE');
     END IF;

  -- Check if the Route is existing and in Draft status
  AHL_RM_ROUTE_UTIL.validate_route_status
  (
    p_object_id,
    l_msg_data,
    l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('AHL',l_msg_data);
    FND_MSG_PUB.ADD;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Update route status from APPROVAL_REJECTED to DRAFT
  OPEN get_route_status (p_object_id);
  FETCH get_route_status INTO l_obj_status;
  IF (get_route_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
  THEN
    UPDATE ahl_routes_b
    SET revision_status_code = 'DRAFT'
    WHERE route_id = p_object_id;
  END IF;
  CLOSE get_route_status;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_route_efct_tbl.count LOOP
    IF ( p_x_route_efct_tbl(i).dml_operation = 'C' ) THEN
      IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  p_x_route_efct_tbl(i).dml_operation ' || p_x_route_efct_tbl(i).dml_operation ) ;
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before DML p_object_id ' || p_object_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before DML p_x_route_efct_tbl(i).INVENTORY_ITEM_ID ' || p_x_route_efct_tbl(i).INVENTORY_ITEM_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_route_efct_tbl(i).INVENTORY_MASTER_ORG_ID ' || p_x_route_efct_tbl(i).INVENTORY_MASTER_ORG_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_route_efct_tbl(i).MC_ID ' || p_x_route_efct_tbl(i).MC_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_route_efct_tbl(i).MC_HEADER_ID ' || p_x_route_efct_tbl(i).MC_HEADER_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  before insert p_x_route_efct_tbl(i).object_version_number ' || p_x_route_efct_tbl(i).object_version_number);
    END IF;
        -- Insert the record
        p_x_route_efct_tbl(i).object_version_number := 1;

        INSERT INTO ahl_route_effectivities
        (
          route_effectivity_id
          , route_id
          , inventory_item_id
          , inventory_master_org_id
          , mc_id
          , mc_header_id ,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          security_group_id,
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
        ) VALUES
        (
          ahl_route_effectivities_s.nextval,
          p_object_id,
          p_x_route_efct_tbl(i).INVENTORY_ITEM_ID,
          p_x_route_efct_tbl(i).INVENTORY_MASTER_ORG_ID,
          p_x_route_efct_tbl(i).MC_ID,
          p_x_route_efct_tbl(i).MC_HEADER_ID,
          p_x_route_efct_tbl(i).object_version_number,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,
          NULL,
          p_x_route_efct_tbl(i).attribute_category,
          p_x_route_efct_tbl(i).attribute1,
          p_x_route_efct_tbl(i).attribute2,
          p_x_route_efct_tbl(i).attribute3,
          p_x_route_efct_tbl(i).attribute4,
          p_x_route_efct_tbl(i).attribute5,
          p_x_route_efct_tbl(i).attribute6,
          p_x_route_efct_tbl(i).attribute7,
          p_x_route_efct_tbl(i).attribute8,
          p_x_route_efct_tbl(i).attribute9,
          p_x_route_efct_tbl(i).attribute10,
          p_x_route_efct_tbl(i).attribute11,
          p_x_route_efct_tbl(i).attribute12,
          p_x_route_efct_tbl(i).attribute13,
          p_x_route_efct_tbl(i).attribute14,
          p_x_route_efct_tbl(i).attribute15
        ) RETURNING route_effectivity_id INTO l_route_effectivitiy_id ;

      IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after DML p_object_id ' || p_object_id );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_route_efct_tbl(i).INVENTORY_MASTER_ORG_ID ' || p_x_route_efct_tbl(i).INVENTORY_MASTER_ORG_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_route_efct_tbl(i).MC_ID ' || p_x_route_efct_tbl(i).MC_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_route_efct_tbl(i).MC_HEADER_ID ' || p_x_route_efct_tbl(i).MC_HEADER_ID );
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after insert p_x_route_efct_tbl(i).object_version_number ' || p_x_route_efct_tbl(i).object_version_number);
      END IF;

        -- Set OUT values
        p_x_route_efct_tbl(i).route_effectivity_id := l_route_effectivitiy_id;

    ELSIF ( p_x_route_efct_tbl(i).dml_operation = 'U' ) THEN

        -- Update the record
        UPDATE ahl_route_effectivities
        SET
          object_version_number   = object_version_number + 1,
          last_update_date        = SYSDATE,
          last_updated_by         = FND_GLOBAL.USER_ID,
          last_update_login       = FND_GLOBAL.LOGIN_ID,
          security_group_id       = p_x_route_efct_tbl(i).security_group_id,
          attribute_category      = p_x_route_efct_tbl(i).attribute_category,
          attribute1              = p_x_route_efct_tbl(i).attribute1,
          attribute2              = p_x_route_efct_tbl(i).attribute2,
          attribute3              = p_x_route_efct_tbl(i).attribute3,
          attribute4              = p_x_route_efct_tbl(i).attribute4,
          attribute5              = p_x_route_efct_tbl(i).attribute5,
          attribute6              = p_x_route_efct_tbl(i).attribute6,
          attribute7              = p_x_route_efct_tbl(i).attribute7,
          attribute8              = p_x_route_efct_tbl(i).attribute8,
          attribute9              = p_x_route_efct_tbl(i).attribute9,
          attribute10             = p_x_route_efct_tbl(i).attribute10,
          attribute11             = p_x_route_efct_tbl(i).attribute11,
          attribute12             = p_x_route_efct_tbl(i).attribute12,
          attribute13             = p_x_route_efct_tbl(i).attribute13,
          attribute14             = p_x_route_efct_tbl(i).attribute14,
          attribute15             = p_x_route_efct_tbl(i).attribute15
        WHERE route_effectivity_id = p_x_route_efct_tbl(i).route_effectivity_id
        AND object_version_number = p_x_route_efct_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
--          FND_MESSAGE.set_token( 'RECORD', p_x_route_efct_tbl(i).aso_resource_name );
          FND_MSG_PUB.add;
        END IF;

        -- Set OUT values
        p_x_route_efct_tbl(i).object_version_number := p_x_route_efct_tbl(i).object_version_number + 1;

    ELSIF ( p_x_route_efct_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE FROM AHL_RT_OPER_MATERIALS
      WHERE OBJECT_ID = p_x_route_efct_tbl(i).route_effectivity_id
      AND ASSOCIATION_TYPE_CODE = 'DISPOSITION';

      -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;


      DELETE FROM ahl_route_effectivities
      WHERE route_effectivity_id = p_x_route_efct_tbl(i).route_effectivity_id
      AND object_version_number = p_x_route_efct_tbl(i).object_version_number;



      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
      END IF;
    END IF;

  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after DML operation' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform cross records validations and duplicate records check

  validate_efct_records
  (
    p_object_id,
    l_return_status
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after validate_records' );
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get
  (
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data
  );

  -- Disable debug (if enabled)
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_route_efcts;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_route_efcts;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO process_route_efcts;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => G_API_NAME1,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END process_route_efcts;

END AHL_RM_MATERIAL_AS_PVT;

/
