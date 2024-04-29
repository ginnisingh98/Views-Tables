--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_EFFECTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_EFFECTIVITY_PVT" AS
/* $Header: AHLVMREB.pls 120.3 2008/03/24 08:10:51 pdoki ship $ */

G_PKG_NAME      VARCHAR2(30)    :='AHL_FMP_MR_EFFECTIVITY_PVT';
G_API_NAME      VARCHAR2(30)    :='PROCESS_EFFECTIVITY';
G_DEBUG         VARCHAR2(30)     :=AHL_DEBUG_PUB.is_log_enabled;
G_APPLN_USAGE   VARCHAR2(30)    :=ltrim(rtrim(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_effectivity_rec       IN    effectivity_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN
  IF ( p_effectivity_rec.name IS NOT NULL AND
       p_effectivity_rec.name <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := p_effectivity_rec.name;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_rec.item_number IS NOT NULL AND
       p_effectivity_rec.item_number <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_rec.item_number;
  END IF;

  IF ( G_APPLN_USAGE = 'PM' ) THEN
    RETURN l_record_identifier;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_rec.position_ref_meaning IS NOT NULL AND
       p_effectivity_rec.position_ref_meaning <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_rec.position_ref_meaning;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_rec.position_item_number IS NOT NULL AND
       p_effectivity_rec.position_item_number <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_rec.position_item_number;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_rec.pc_node_name IS NOT NULL AND
       p_effectivity_rec.pc_node_name <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_rec.pc_node_name;
  END IF;

  RETURN l_record_identifier;

END get_record_identifier;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_effectivity_tbl         IN   effectivity_tbl_type,
  p_mr_header_id            IN   NUMBER,
  P_APPLN_USAGE             IN   VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_super_user              IN   VARCHAR2
)
IS
l_error_code                    VARCHAR2(30);
l_return_status                 VARCHAR2(30);
l_mr_status_code                VARCHAR2(30);
l_mr_type_code                  VARCHAR2(30);
l_pm_install_flag               VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a valid value is passed in p_mr_header_id

  IF ( p_mr_header_id = FND_API.G_MISS_NUM OR
       p_mr_header_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_MR_HEADER_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
      IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug('MR_HEADER_ID is null to validate_api_inputs' );
      END IF;
  END IF;
  -- Check Profile value

    IF  G_APPLN_USAGE IS NULL
    THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
        FND_MSG_PUB.ADD;
        IF G_DEBUG = 'Y' THEN
                AHL_DEBUG_PUB.debug('APPLN USAGE CODE  IS NULL IN VALIDATE_API_INPUTS' );
        END IF;
    END IF;

    IF ( G_APPLN_USAGE = 'PM' ) THEN
        l_pm_install_flag:= 'Y';
    ELSE
        l_pm_install_flag:= 'N';
    END IF;

    --check if mr is terminated and get the mr status.
    l_mr_status_code :=AHL_FMP_COMMON_PVT.check_mr_status(p_mr_header_id);
   IF l_mr_status_code IS NULL  THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVALID_MR' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
   END IF;

    --check if mr type.
   l_mr_type_code :=AHL_FMP_COMMON_PVT.check_mr_type(p_mr_header_id);

   -- Check if the Maintenance Requirement is in Updatable status
   IF ( l_pm_install_flag = 'Y' AND
        p_super_user ='Y' AND
        l_mr_status_code = 'COMPLETE') THEN
        AHL_FMP_COMMON_PVT.validate_mr_pm_status
          (
            x_return_status        => l_return_status,
            x_msg_data             => l_error_code,
            p_mr_header_id         => p_mr_header_id
           );
     ELSE
           AHL_FMP_COMMON_PVT.validate_mr_status
           (
            x_return_status        => l_return_status,
            x_msg_data             => l_error_code,
            p_mr_header_id         => p_mr_header_id
            );
     END IF;

    IF l_error_code is not null THEN
        AHL_DEBUG_PUB.debug('Error here.....'||L_ERROR_CODE);
        FND_MESSAGE.set_name( 'AHL', l_error_code );
        FND_MSG_PUB.add;
        RETURN;
    END IF;




  -- Check if atleast one record is passed in p_effectivity_tbl
  IF ( p_effectivity_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  FOR i IN 1..p_effectivity_tbl.count LOOP

    -- Validate DML Operation
    IF ( p_effectivity_tbl(i).dml_operation <> 'D' AND
         p_effectivity_tbl(i).dml_operation <> 'U' AND
         p_effectivity_tbl(i).dml_operation <> 'C' ) THEN
         FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
         FND_MESSAGE.set_token( 'FIELD', p_effectivity_tbl(i).dml_operation );
         FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_tbl(i) ) );
         FND_MSG_PUB.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF ( l_pm_install_flag = 'Y' AND
        p_effectivity_tbl(i).dml_operation = 'D' AND
        l_mr_status_code = 'COMPLETE' AND
        l_mr_type_code ='ACTIVITY')
    THEN
        AHL_FMP_COMMON_PVT.validate_mr_type_activity
        (
            x_return_status    => l_return_status,
            x_msg_data         => l_error_code,
            p_effectivity_id   => p_effectivity_tbl(i).MR_EFFECTIVITY_ID,
            p_eff_obj_version  => p_effectivity_tbl(i).OBJECT_VERSION_NUMBER
        );
        IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
            FND_MESSAGE.set_name( 'AHL', l_error_code );
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
        END IF;
    END IF;

    IF ( l_pm_install_flag = 'Y' AND
         p_effectivity_tbl(i).dml_operation = 'D'AND
         l_mr_status_code = 'COMPLETE' AND
         l_mr_type_code ='PROGRAM')
    THEN
        AHL_FMP_COMMON_PVT.validate_mr_type_program
        (
            x_return_status    => l_return_status,
            x_msg_data         => l_error_code,
            p_mr_header_id     => p_mr_header_id,
            p_effectivity_id   => p_effectivity_tbl(i).MR_EFFECTIVITY_ID,
            p_eff_obj_version  => p_effectivity_tbl(i).OBJECT_VERSION_NUMBER
        );

        IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
            FND_MESSAGE.set_name( 'AHL', l_error_code );
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
        END IF;
   END IF;


   IF ( l_pm_install_flag = 'Y' AND
         p_effectivity_tbl(i).dml_operation = 'U' AND
         p_super_user ='Y' AND
         l_mr_status_code = 'COMPLETE') THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVALID_UPDATE' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;


    -- Validate to ensure that MC Info and PC Info are not passed for PM
    IF ( P_APPLN_USAGE = 'PM' AND
         p_effectivity_tbl(i).dml_operation <> 'D' ) THEN

      IF ( ( p_effectivity_tbl(i).relationship_id IS NOT NULL AND
             p_effectivity_tbl(i).relationship_id <> FND_API.G_MISS_NUM ) OR
           ( p_effectivity_tbl(i).position_ref_meaning IS NOT NULL AND
             p_effectivity_tbl(i).position_ref_meaning <> FND_API.G_MISS_CHAR ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_INPUT_MC_POS' );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_tbl(i) ) );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( ( p_effectivity_tbl(i).position_inventory_item_id IS NOT NULL AND
             p_effectivity_tbl(i).position_inventory_item_id <> FND_API.G_MISS_NUM ) OR
           ( p_effectivity_tbl(i).position_item_number IS NOT NULL AND
             p_effectivity_tbl(i).position_item_number <> FND_API.G_MISS_CHAR ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_INPUT_MC_POS_ITEM' );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_tbl(i) ) );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( ( p_effectivity_tbl(i).pc_node_id IS NOT NULL AND
             p_effectivity_tbl(i).pc_node_id <> FND_API.G_MISS_NUM ) OR
           ( p_effectivity_tbl(i).pc_node_name IS NOT NULL AND
             p_effectivity_tbl(i).pc_node_name <> FND_API.G_MISS_CHAR ) ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_INPUT_PC_NODE' );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_tbl(i) ) );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

  END LOOP;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_effectivity_rec       IN OUT NOCOPY  effectivity_rec_type
)
IS

BEGIN
  /*
  IF ( p_x_effectivity_rec.item_number IS NULL ) THEN
    p_x_effectivity_rec.inventory_item_id := NULL;
  ELSIF ( p_x_effectivity_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.inventory_item_id := FND_API.G_MISS_NUM;
  END IF;
  */
  IF ( p_x_effectivity_rec.position_ref_meaning IS NULL ) THEN
    p_x_effectivity_rec.relationship_id := NULL;
  ELSIF ( p_x_effectivity_rec.position_ref_meaning = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.relationship_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_effectivity_rec.position_item_number IS NULL ) THEN
    p_x_effectivity_rec.position_inventory_item_id := NULL;
  ELSIF ( p_x_effectivity_rec.position_item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.position_inventory_item_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_effectivity_rec.pc_node_name IS NULL ) THEN
    p_x_effectivity_rec.pc_node_id := NULL;
  ELSIF ( p_x_effectivity_rec.pc_node_name = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.pc_node_id := FND_API.G_MISS_NUM;
  END IF;
END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_effectivity_rec       IN OUT NOCOPY  effectivity_rec_type,
  x_return_status           OUT NOCOPY     VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Item
  IF ( ( p_x_effectivity_rec.inventory_item_id IS NOT NULL AND
         p_x_effectivity_rec.inventory_item_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_effectivity_rec.item_number IS NOT NULL AND
         p_x_effectivity_rec.item_number <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_FMP_COMMON_PVT.validate_item
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_item_number          => p_x_effectivity_rec.item_number,
      p_x_inventory_item_id  => p_x_effectivity_rec.inventory_item_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_effectivity_rec.item_number IS NULL OR
           p_x_effectivity_rec.item_number = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effectivity_rec.inventory_item_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_rec.item_number );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Master Configuration Position
  IF ( ( p_x_effectivity_rec.relationship_id IS NOT NULL AND
         p_x_effectivity_rec.relationship_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_effectivity_rec.position_ref_meaning IS NOT NULL AND
         p_x_effectivity_rec.position_ref_meaning <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_FMP_COMMON_PVT.validate_position
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_position_ref_meaning => p_x_effectivity_rec.position_ref_meaning,
      p_x_relationship_id    => p_x_effectivity_rec.relationship_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_effectivity_rec.position_ref_meaning IS NULL OR
           p_x_effectivity_rec.position_ref_meaning = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effectivity_rec.relationship_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_rec.position_ref_meaning );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Master Configuration Item
  IF ( ( p_x_effectivity_rec.position_inventory_item_id IS NOT NULL AND
         p_x_effectivity_rec.position_inventory_item_id <> FND_API.G_MISS_NUM )
       OR
       ( p_x_effectivity_rec.position_item_number IS NOT NULL AND
         p_x_effectivity_rec.position_item_number <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_FMP_COMMON_PVT.validate_item
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_item_number          => p_x_effectivity_rec.position_item_number,
      p_x_inventory_item_id  => p_x_effectivity_rec.position_inventory_item_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_effectivity_rec.position_item_number IS NULL OR
           p_x_effectivity_rec.position_item_number = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effectivity_rec.position_inventory_item_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_rec.position_item_number );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Product Classification Node
  IF ( ( p_x_effectivity_rec.pc_node_id IS NOT NULL AND
         p_x_effectivity_rec.pc_node_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_effectivity_rec.pc_node_name IS NOT NULL AND
         p_x_effectivity_rec.pc_node_name <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_FMP_COMMON_PVT.validate_pc_node
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_pc_node_name         => p_x_effectivity_rec.pc_node_name,
      p_x_pc_node_id         => p_x_effectivity_rec.pc_node_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_effectivity_rec.pc_node_name IS NULL OR
           p_x_effectivity_rec.pc_node_name = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effectivity_rec.pc_node_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_rec.pc_node_name );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;

-- Procedure to add Default values for effectivity attributes
PROCEDURE default_attributes
(
  p_x_effectivity_rec       IN OUT NOCOPY   effectivity_rec_type
)
IS

BEGIN

  p_x_effectivity_rec.last_update_date := SYSDATE;
  p_x_effectivity_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_effectivity_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_effectivity_rec.dml_operation = 'C' ) THEN
    p_x_effectivity_rec.object_version_number := 1;
    p_x_effectivity_rec.creation_date := SYSDATE;
    p_x_effectivity_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_attributes;

 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_effectivity_rec       IN OUT NOCOPY   effectivity_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_effectivity_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.inventory_item_id := null;
  END IF;

  IF ( p_x_effectivity_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.item_number := null;
  END IF;

  IF ( p_x_effectivity_rec.relationship_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.relationship_id := null;
  END IF;

  IF ( p_x_effectivity_rec.position_ref_meaning = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.position_ref_meaning := null;
  END IF;

  IF ( p_x_effectivity_rec.position_inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.position_inventory_item_id := null;
  END IF;

  IF ( p_x_effectivity_rec.position_item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.position_item_number := null;
  END IF;

  IF ( p_x_effectivity_rec.pc_node_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.pc_node_id := null;
  END IF;

  IF ( p_x_effectivity_rec.pc_node_name = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.pc_node_name := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute_category := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute1 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute2 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute3 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute4 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute5 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute6 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute7 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute8 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute9 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute10 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute11 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute12 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute13 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute14 := null;
  END IF;

  IF ( p_x_effectivity_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute15 := null;
  END IF;

END default_missing_attributes;

 -- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_effectivity_rec       IN OUT NOCOPY   effectivity_rec_type
)
IS

l_old_effectivity_rec       effectivity_rec_type;

CURSOR get_old_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT  name,
        inventory_item_id,
        item_number,
        relationship_id,
        position_ref_meaning,
        position_inventory_item_id,
        position_item_number,
        pc_node_id,
        pc_node_name,
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
        attribute15
FROM    AHL_MR_EFFECTIVITIES_V
WHERE   mr_effectivity_id = c_mr_effectivity_id;

BEGIN

  -- Get the old record from AHL_MR_EFFECTIVITIES.
  OPEN  get_old_rec( p_x_effectivity_rec.mr_effectivity_id );

  FETCH get_old_rec INTO
        l_old_effectivity_rec.name,
        l_old_effectivity_rec.inventory_item_id,
        l_old_effectivity_rec.item_number,
        l_old_effectivity_rec.relationship_id,
        l_old_effectivity_rec.position_ref_meaning,
        l_old_effectivity_rec.position_inventory_item_id,
        l_old_effectivity_rec.position_item_number,
        l_old_effectivity_rec.pc_node_id,
        l_old_effectivity_rec.pc_node_name,
        l_old_effectivity_rec.attribute_category,
        l_old_effectivity_rec.attribute1,
        l_old_effectivity_rec.attribute2,
        l_old_effectivity_rec.attribute3,
        l_old_effectivity_rec.attribute4,
        l_old_effectivity_rec.attribute5,
        l_old_effectivity_rec.attribute6,
        l_old_effectivity_rec.attribute7,
        l_old_effectivity_rec.attribute8,
        l_old_effectivity_rec.attribute9,
        l_old_effectivity_rec.attribute10,
        l_old_effectivity_rec.attribute11,
        l_old_effectivity_rec.attribute12,
        l_old_effectivity_rec.attribute13,
        l_old_effectivity_rec.attribute14,
        l_old_effectivity_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVALID_MR_EFF_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_effectivity_rec.name IS NULL ) THEN
    p_x_effectivity_rec.name := l_old_effectivity_rec.name;
  END IF;

  IF ( p_x_effectivity_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.inventory_item_id := null;
  ELSIF ( p_x_effectivity_rec.inventory_item_id IS NULL ) THEN
    p_x_effectivity_rec.inventory_item_id := l_old_effectivity_rec.inventory_item_id;
  END IF;

  IF ( p_x_effectivity_rec.item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.item_number := null;
  ELSIF ( p_x_effectivity_rec.item_number IS NULL ) THEN
    p_x_effectivity_rec.item_number := l_old_effectivity_rec.item_number;
  END IF;

  IF ( p_x_effectivity_rec.relationship_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.relationship_id := null;
  ELSIF ( p_x_effectivity_rec.relationship_id IS NULL ) THEN
    p_x_effectivity_rec.relationship_id := l_old_effectivity_rec.relationship_id;
  END IF;

  IF ( p_x_effectivity_rec.position_ref_meaning = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.position_ref_meaning := null;
  ELSIF ( p_x_effectivity_rec.position_ref_meaning IS NULL ) THEN
    p_x_effectivity_rec.position_ref_meaning := l_old_effectivity_rec.position_ref_meaning;
  END IF;

  IF ( p_x_effectivity_rec.position_inventory_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.position_inventory_item_id := null;
  ELSIF ( p_x_effectivity_rec.position_inventory_item_id IS NULL ) THEN
    p_x_effectivity_rec.position_inventory_item_id := l_old_effectivity_rec.position_inventory_item_id;
  END IF;

  IF ( p_x_effectivity_rec.position_item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.position_item_number := null;
  ELSIF ( p_x_effectivity_rec.position_item_number IS NULL ) THEN
    p_x_effectivity_rec.position_item_number := l_old_effectivity_rec.position_item_number;
  END IF;

  IF ( p_x_effectivity_rec.pc_node_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_rec.pc_node_id := null;
  ELSIF ( p_x_effectivity_rec.pc_node_id IS NULL ) THEN
    p_x_effectivity_rec.pc_node_id := l_old_effectivity_rec.pc_node_id;
  END IF;

  IF ( p_x_effectivity_rec.pc_node_name = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.pc_node_name := null;
  ELSIF ( p_x_effectivity_rec.pc_node_name IS NULL ) THEN
    p_x_effectivity_rec.pc_node_name := l_old_effectivity_rec.pc_node_name;
  END IF;

  IF ( p_x_effectivity_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute_category := null;
  ELSIF ( p_x_effectivity_rec.attribute_category IS NULL ) THEN
    p_x_effectivity_rec.attribute_category := l_old_effectivity_rec.attribute_category;
  END IF;

  IF ( p_x_effectivity_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute1 := null;
  ELSIF ( p_x_effectivity_rec.attribute1 IS NULL ) THEN
    p_x_effectivity_rec.attribute1 := l_old_effectivity_rec.attribute1;
  END IF;

  IF ( p_x_effectivity_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute2 := null;
  ELSIF ( p_x_effectivity_rec.attribute2 IS NULL ) THEN
    p_x_effectivity_rec.attribute2 := l_old_effectivity_rec.attribute2;
  END IF;

  IF ( p_x_effectivity_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute3 := null;
  ELSIF ( p_x_effectivity_rec.attribute3 IS NULL ) THEN
    p_x_effectivity_rec.attribute3 := l_old_effectivity_rec.attribute3;
  END IF;

  IF ( p_x_effectivity_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute4 := null;
  ELSIF ( p_x_effectivity_rec.attribute4 IS NULL ) THEN
    p_x_effectivity_rec.attribute4 := l_old_effectivity_rec.attribute4;
  END IF;

  IF ( p_x_effectivity_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute5 := null;
  ELSIF ( p_x_effectivity_rec.attribute5 IS NULL ) THEN
    p_x_effectivity_rec.attribute5 := l_old_effectivity_rec.attribute5;
  END IF;

  IF ( p_x_effectivity_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute6 := null;
  ELSIF ( p_x_effectivity_rec.attribute6 IS NULL ) THEN
    p_x_effectivity_rec.attribute6 := l_old_effectivity_rec.attribute6;
  END IF;

  IF ( p_x_effectivity_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute7 := null;
  ELSIF ( p_x_effectivity_rec.attribute7 IS NULL ) THEN
    p_x_effectivity_rec.attribute7 := l_old_effectivity_rec.attribute7;
  END IF;

  IF ( p_x_effectivity_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute8 := null;
  ELSIF ( p_x_effectivity_rec.attribute8 IS NULL ) THEN
    p_x_effectivity_rec.attribute8 := l_old_effectivity_rec.attribute8;
  END IF;

  IF ( p_x_effectivity_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute9 := null;
  ELSIF ( p_x_effectivity_rec.attribute9 IS NULL ) THEN
    p_x_effectivity_rec.attribute9 := l_old_effectivity_rec.attribute9;
  END IF;

  IF ( p_x_effectivity_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute10 := null;
  ELSIF ( p_x_effectivity_rec.attribute10 IS NULL ) THEN
    p_x_effectivity_rec.attribute10 := l_old_effectivity_rec.attribute10;
  END IF;

  IF ( p_x_effectivity_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute11 := null;
  ELSIF ( p_x_effectivity_rec.attribute11 IS NULL ) THEN
    p_x_effectivity_rec.attribute11 := l_old_effectivity_rec.attribute11;
  END IF;

  IF ( p_x_effectivity_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute12 := null;
  ELSIF ( p_x_effectivity_rec.attribute12 IS NULL ) THEN
    p_x_effectivity_rec.attribute12 := l_old_effectivity_rec.attribute12;
  END IF;

  IF ( p_x_effectivity_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute13 := null;
  ELSIF ( p_x_effectivity_rec.attribute13 IS NULL ) THEN
    p_x_effectivity_rec.attribute13 := l_old_effectivity_rec.attribute13;
  END IF;

  IF ( p_x_effectivity_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute14 := null;
  ELSIF ( p_x_effectivity_rec.attribute14 IS NULL ) THEN
    p_x_effectivity_rec.attribute14 := l_old_effectivity_rec.attribute14;
  END IF;

  IF ( p_x_effectivity_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_rec.attribute15 := null;
  ELSIF ( p_x_effectivity_rec.attribute15 IS NULL ) THEN
    p_x_effectivity_rec.attribute15 := l_old_effectivity_rec.attribute15;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual effectivity attributes
PROCEDURE validate_attributes
(
  p_effectivity_rec       IN    effectivity_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_effectivity_rec.dml_operation = 'C' ) THEN
    -- Check if the Effectivity Name does not column contains a null value.
    IF ( p_effectivity_rec.name IS NULL OR
         p_effectivity_rec.name = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_EFFECTIVITY_NAME_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;
    RETURN;
  END IF;

  IF ( p_effectivity_rec.dml_operation = 'U' ) THEN
    -- Check if the Effectivity Name column does not contains a null value.
    IF ( p_effectivity_rec.name = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_EFFECTIVITY_NAME_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the mandatory Effectivity ID column contains a null value.
  IF ( p_effectivity_rec.mr_effectivity_id IS NULL OR
       p_effectivity_rec.mr_effectivity_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_EFFECTIVITY_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_effectivity_rec.object_version_number IS NULL OR
       p_effectivity_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MRE_OBJ_VERSION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_record
(
  p_effectivity_rec       IN    effectivity_rec_type,
  -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
  p_mr_header_id        IN  NUMBER,
  -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
  P_APPLN_USAGE       IN    VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);
l_manufacturer_id            NUMBER;
l_counter_id                 NUMBER;
l_dummy                      VARCHAR2(1); --pdoki added for Bug 6719371

--pdoki added for Bug 6719371
CURSOR check_alternate( c_relationship_id NUMBER, c_inventory_item_id NUMBER )
IS
SELECT  'X'
FROM     MTL_SYSTEM_ITEMS_KFV MTL,
         FND_LOOKUP_VALUES_VL IT,
         AHL_POSITION_ALTERNATES_V PA
WHERE    MTL.SERVICE_ITEM_FLAG = 'N'
         AND IT.LOOKUP_CODE (+)  = MTL.ITEM_TYPE
         AND IT.LOOKUP_TYPE (+)  = 'ITEM_TYPE'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(IT.START_DATE_ACTIVE,SYSDATE))
                                    AND TRUNC(NVL(IT.END_DATE_ACTIVE,SYSDATE + 1))
         AND MTL.INVENTORY_ITEM_ID = PA.INVENTORY_ITEM_ID
         AND PA.INVENTORY_ORG_ID = MTL.ORGANIZATION_ID
         AND PA.RELATIONSHIP_ID = c_relationship_id
         AND MTL.INVENTORY_ITEM_ID = c_inventory_item_id ;


CURSOR get_eff_dtls_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT DISTINCT EFD.manufacturer_id
FROM            AHL_MR_EFFECTIVITY_DTLS_APP_V EFD,
                AHL_MR_EFFECTIVITIES_APP_V EF
WHERE           EFD.manufacturer_id IS NOT NULL
AND             EFD.mr_effectivity_id = EF.mr_effectivity_id
AND             EF.mr_effectivity_id = c_mr_effectivity_id;

CURSOR get_intervals_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT DISTINCT INT.counter_id
FROM            AHL_MR_INTERVALS_APP_V INT,
                AHL_MR_EFFECTIVITIES_APP_V EF
WHERE           INT.mr_effectivity_id = EF.mr_effectivity_id
AND             EF.mr_effectivity_id = c_mr_effectivity_id;

-- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
CURSOR get_mr_details
IS
    SELECT program_type_code
    FROM ahl_mr_headers_b
    WHERE mr_header_id = p_mr_header_id;

l_prog_type VARCHAR2(30);
-- Tamal [MEL/CDL RM-FMP Enhancements] Ends here...

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( P_APPLN_USAGE = 'PM' ) THEN

    -- Check if Item is NULL
    IF ( p_effectivity_rec.inventory_item_id IS NULL AND
         p_effectivity_rec.item_number IS NULL ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_ITEM_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

  ELSE

    -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
    OPEN get_mr_details;
    FETCH get_mr_details INTO l_prog_type;
    CLOSE get_mr_details;
    -- Tamal [MEL/CDL RM-FMP Enhancements] Ends here...

    -- Check if both Item and Master Configuration Position are NULL
    IF ( p_effectivity_rec.relationship_id IS NULL AND
         p_effectivity_rec.position_ref_meaning IS NULL AND
         p_effectivity_rec.inventory_item_id IS NULL AND
         -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
         p_effectivity_rec.item_number IS NULL AND
         nvl(l_prog_type, 'X') <> 'MO_PROC') THEN
         -- Tamal [MEL/CDL RM-FMP Enhancements] Ends here...
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_ITEM_POS_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

    -- Check if Master Configuration Item contains a value but, the Position is NULL
    IF ( p_effectivity_rec.relationship_id IS NULL AND
         p_effectivity_rec.position_ref_meaning IS NULL AND
         ( p_effectivity_rec.position_inventory_item_id IS NOT NULL OR
           p_effectivity_rec.position_item_number IS NOT NULL ) ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_POS_NULL_ITEM_NOTNULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

    -- Check if both Item and Master Configuration Position contain values
    IF ( ( p_effectivity_rec.inventory_item_id IS NOT NULL OR
           p_effectivity_rec.item_number IS NOT NULL ) AND
         ( p_effectivity_rec.relationship_id IS NOT NULL OR
           p_effectivity_rec.position_ref_meaning IS NOT NULL ) ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_BOTH_ITEM_POS_NOTNULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

    -- Check if both Item and Master Configuration Item contain values
    IF ( ( p_effectivity_rec.inventory_item_id IS NOT NULL OR
           p_effectivity_rec.item_number IS NOT NULL ) AND
         ( p_effectivity_rec.position_inventory_item_id IS NOT NULL OR
           p_effectivity_rec.position_item_number IS NOT NULL ) ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_BOTH_ITEM_POS_ITEM' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
      FND_MSG_PUB.add;
    END IF;

    -- Check if the given Item can be installed in the given Master Configuration Position
    IF ( p_effectivity_rec.relationship_id IS NOT NULL AND
         p_effectivity_rec.position_inventory_item_id IS NOT NULL ) THEN

      -- Check if the given Item can be installed in the given Position.
   /*   AHL_FMP_COMMON_PVT.validate_position_item
      (
        x_return_status          => l_return_status,
        x_msg_data               => l_msg_data,
        p_inventory_item_id      => p_effectivity_rec.position_inventory_item_id,
        p_relationship_id        => p_effectivity_rec.relationship_id
      );

      IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
        IF ( p_effectivity_rec.position_item_number IS NULL OR
             p_effectivity_rec.position_item_number = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD1', TO_CHAR( p_effectivity_rec.position_inventory_item_id ) );
        ELSE
          FND_MESSAGE.set_token( 'FIELD1', p_effectivity_rec.position_item_number );
        END IF;

        IF ( p_effectivity_rec.position_ref_meaning IS NULL OR
             p_effectivity_rec.position_ref_meaning = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD2', TO_CHAR( p_effectivity_rec.relationship_id ) );
        ELSE
          FND_MESSAGE.set_token( 'FIELD2', p_effectivity_rec.position_ref_meaning );
        END IF;

        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
        FND_MSG_PUB.add;
      END IF; */

		--pdoki added for Bug 6719371
    OPEN check_alternate( p_effectivity_rec.relationship_id , p_effectivity_rec.position_inventory_item_id );

    FETCH check_alternate INTO
      l_dummy;

    IF check_alternate%NOTFOUND THEN
       l_msg_data := 'AHL_FMP_INVALID_POSITION_ITEM';

        FND_MESSAGE.set_name( 'AHL', l_msg_data );
        IF ( p_effectivity_rec.position_item_number IS NULL OR
             p_effectivity_rec.position_item_number = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD1', TO_CHAR( p_effectivity_rec.position_inventory_item_id ) );
        ELSE
          FND_MESSAGE.set_token( 'FIELD1', p_effectivity_rec.position_item_number );
        END IF;

        IF ( p_effectivity_rec.position_ref_meaning IS NULL OR
             p_effectivity_rec.position_ref_meaning = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD2', TO_CHAR( p_effectivity_rec.relationship_id ) );
        ELSE
          FND_MESSAGE.set_token( 'FIELD2', p_effectivity_rec.position_ref_meaning );
        END IF;

        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
        FND_MSG_PUB.add;
      END IF;
        CLOSE check_alternate;
    END IF;

    -- Check if there are Effectivity details defined based on the Position / Item for this Effectivity Record
    IF ( p_effectivity_rec.inventory_item_id IS NOT NULL OR
         p_effectivity_rec.relationship_id IS NOT NULL ) THEN
      OPEN  get_eff_dtls_rec( p_effectivity_rec.mr_effectivity_id );

      FETCH get_eff_dtls_rec INTO
        l_manufacturer_id;

      IF get_eff_dtls_rec%FOUND THEN

        IF ( p_effectivity_rec.inventory_item_id IS NOT NULL ) THEN
          AHL_FMP_COMMON_PVT.validate_manufacturer
          (
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            p_inventory_item_id   => p_effectivity_rec.inventory_item_id,
            p_x_manufacturer_id   => l_manufacturer_id
          );
        ELSIF ( p_effectivity_rec.position_inventory_item_id IS NOT NULL ) THEN
          AHL_FMP_COMMON_PVT.validate_manufacturer
          (
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            p_inventory_item_id   => p_effectivity_rec.position_inventory_item_id,
            p_x_manufacturer_id   => l_manufacturer_id
          );
        ELSIF ( p_effectivity_rec.relationship_id IS NOT NULL ) THEN
          AHL_FMP_COMMON_PVT.validate_manufacturer
          (
            x_return_status       => l_return_status,
            x_msg_data            => l_msg_data,
            p_relationship_id     => p_effectivity_rec.relationship_id,
            p_x_manufacturer_id   => l_manufacturer_id
          );
        END IF;

        IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_EFFECTIVITY_DTLS_EXIST' );
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
          FND_MSG_PUB.add;
        END IF;

      END IF;

      CLOSE get_eff_dtls_rec;

    END IF;

  END IF;

  -- Check if there are Intervals defined based on the Position / Item for this Effectivity Record
  IF ( p_effectivity_rec.inventory_item_id IS NOT NULL OR
       p_effectivity_rec.relationship_id IS NOT NULL ) THEN
    OPEN  get_intervals_rec( p_effectivity_rec.mr_effectivity_id );

    FETCH get_intervals_rec INTO
      l_counter_id;

    IF get_intervals_rec%FOUND THEN

      IF ( p_effectivity_rec.inventory_item_id IS NOT NULL ) THEN
        AHL_FMP_COMMON_PVT.validate_counter_template
        (
          x_return_status       => l_return_status,
          x_msg_data            => l_msg_data,
          p_inventory_item_id   => p_effectivity_rec.inventory_item_id,
          p_x_counter_id        => l_counter_id
        );
      ELSIF ( p_effectivity_rec.position_inventory_item_id IS NOT NULL ) THEN
        AHL_FMP_COMMON_PVT.validate_counter_template
        (
          x_return_status       => l_return_status,
          x_msg_data            => l_msg_data,
          p_inventory_item_id   => p_effectivity_rec.position_inventory_item_id,
          p_x_counter_id        => l_counter_id
        );
      ELSIF ( p_effectivity_rec.relationship_id IS NOT NULL ) THEN
        AHL_FMP_COMMON_PVT.validate_counter_template
        (
          x_return_status       => l_return_status,
          x_msg_data            => l_msg_data,
          p_relationship_id     => p_effectivity_rec.relationship_id,
          p_x_counter_id        => l_counter_id
        );
      END IF;

      IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INTERVALS_EXIST' );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_rec ) );
        FND_MSG_PUB.add;
      END IF;

    END IF;

    CLOSE get_intervals_rec;

  END IF;

END validate_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_mr_header_id          IN    NUMBER,
  P_APPLN_USAGE       IN    VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2
)
IS

l_effectivity_name      VARCHAR2(80) := NULL;
l_item_number           VARCHAR2(40) := NULL;
l_inventory_item_id     NUMBER := NULL;

CURSOR get_dup_name ( c_mr_header_id NUMBER )
IS
SELECT   name
FROM     AHL_MR_EFFECTIVITIES_APP_V
WHERE    mr_header_id = c_mr_header_id
GROUP BY name
HAVING   count(*) > 1;

CURSOR get_dup_item ( c_mr_header_id NUMBER )
IS
SELECT   inventory_item_id
FROM     AHL_MR_EFFECTIVITIES_APP_V
WHERE    mr_header_id = c_mr_header_id
GROUP BY inventory_item_id
HAVING   count(*) > 1;

/* The above query has to use the table instead of the view, because the view
contains more records than the table and if using view the above query doesn't
work. That is the reason why the following cursor is added. This bug is raised
 by Michael Payne. */

cursor get_item_number (c_inventory_item_id number) is
select item_number
from ahl_mr_effectivities_v
where inventory_item_id = c_inventory_item_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check whether any duplicate effectivity records (based on Name) for the given MR_HEADER_ID
  OPEN  get_dup_name( p_mr_header_id );

  LOOP

    FETCH get_dup_name INTO
      l_effectivity_name;

    EXIT WHEN get_dup_name%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_EFFECTIVITY_NAME_DUP' );
    FND_MESSAGE.set_token( 'RECORD', l_effectivity_name );
    FND_MSG_PUB.add;

  END LOOP;

  IF ( get_dup_name%ROWCOUNT > 0 ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_dup_name;

  -- Check whether any duplicate effectivity records (based on Item) for the given MR_HEADER_ID for PM
  IF ( P_APPLN_USAGE = 'PM' ) THEN

    OPEN  get_dup_item( p_mr_header_id );

    LOOP

      FETCH get_dup_item INTO
        l_inventory_item_id;

      EXIT WHEN get_dup_item%NOTFOUND;

      if (get_dup_item%FOUND and l_inventory_item_id is not null) then
        FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_ITEM_DUP' );
        open get_item_number(l_inventory_item_id);
        fetch get_item_number into l_item_number;
        if get_item_number%notfound then
          l_item_number := to_char(l_inventory_item_id);
        end if;
        close get_item_number;
        FND_MESSAGE.set_token( 'RECORD', l_item_number );
        FND_MSG_PUB.add;
      end if;

    END LOOP;

    IF ( get_dup_item%ROWCOUNT > 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE get_dup_item;

  END IF;

END validate_records;


PROCEDURE process_effectivity
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
 p_x_effectivity_tbl  IN OUT NOCOPY effectivity_tbl_type,
 p_mr_header_id       IN            NUMBER,
 p_super_user         IN            VARCHAR2
)
IS
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_mr_effectivity_id         NUMBER;
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_effectivity_PVT;

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

  -- Get the Application Code


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_appln_usage );
  END IF;

  -- Validate all the inputs of the API
   AHL_DEBUG_PUB.debug('Before Validate inputs '  );
  validate_api_inputs
  (
    p_x_effectivity_tbl, -- IN
    p_mr_header_id, -- IN
    RTRIM(LTRIM(g_appln_usage)), -- IN
    x_return_status, -- OUT
    p_super_user
  );
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    AHL_DEBUG_PUB.debug('After validate  with error '  );
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


   AHL_DEBUG_PUB.debug('After validate with no error '  );

  -- If any severe error occurs, then, abort API.

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_api_inputs' );
  END IF;

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_effectivity_tbl.count LOOP
      IF ( p_x_effectivity_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_effectivity_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_effectivity_tbl.count LOOP
      IF ( p_x_effectivity_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_effectivity_tbl(i) , -- IN OUT Record with Values and Ids
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
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after convert_values_to_ids' );
  END IF;

  -- Default effectivity attributes.
    FOR i IN 1..p_x_effectivity_tbl.count LOOP
      IF ( p_x_effectivity_tbl(i).dml_operation <> 'D' ) THEN
        default_attributes
        (
          p_x_effectivity_tbl(i) -- IN OUT
        );
      END IF;
    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_effectivity_tbl.count LOOP
      validate_attributes
      (
        p_x_effectivity_tbl(i), -- IN
        l_return_status -- OUT
      );

      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_effectivity_tbl.count LOOP
    IF ( p_x_effectivity_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_effectivity_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_effectivity_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_effectivity_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_effectivity_tbl.count LOOP
      IF ( p_x_effectivity_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_x_effectivity_tbl(i), -- IN
          -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
          p_mr_header_id, -- IN
          -- Tamal [MEL/CDL RM-FMP Enhancements] Begins here...
          g_appln_usage, -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_record' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_effectivity_tbl.count LOOP
    IF ( p_x_effectivity_tbl(i).dml_operation = 'C' ) THEN

      BEGIN
       -- Insert the record
        INSERT INTO AHL_MR_EFFECTIVITIES
        (
          MR_EFFECTIVITY_ID,
          OBJECT_VERSION_NUMBER,
          MR_HEADER_ID,
          NAME,
          INVENTORY_ITEM_ID,
          RELATIONSHIP_ID,
          PC_NODE_ID,
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
          LAST_UPDATE_LOGIN
        ) VALUES
        (
          AHL_MR_EFFECTIVITIES_S.NEXTVAL,
          p_x_effectivity_tbl(i).object_version_number,
          p_mr_header_id,
          p_x_effectivity_tbl(i).name,
          DECODE( p_x_effectivity_tbl(i).relationship_id, NULL,
                  p_x_effectivity_tbl(i).inventory_item_id,
                  p_x_effectivity_tbl(i).position_inventory_item_id ),
          p_x_effectivity_tbl(i).relationship_id,
          p_x_effectivity_tbl(i).pc_node_id,
          p_x_effectivity_tbl(i).attribute_category,
          p_x_effectivity_tbl(i).attribute1,
          p_x_effectivity_tbl(i).attribute2,
          p_x_effectivity_tbl(i).attribute3,
          p_x_effectivity_tbl(i).attribute4,
          p_x_effectivity_tbl(i).attribute5,
          p_x_effectivity_tbl(i).attribute6,
          p_x_effectivity_tbl(i).attribute7,
          p_x_effectivity_tbl(i).attribute8,
          p_x_effectivity_tbl(i).attribute9,
          p_x_effectivity_tbl(i).attribute10,
          p_x_effectivity_tbl(i).attribute11,
          p_x_effectivity_tbl(i).attribute12,
          p_x_effectivity_tbl(i).attribute13,
          p_x_effectivity_tbl(i).attribute14,
          p_x_effectivity_tbl(i).attribute15,
          p_x_effectivity_tbl(i).last_update_date,
          p_x_effectivity_tbl(i).last_updated_by,
          p_x_effectivity_tbl(i).creation_date,
          p_x_effectivity_tbl(i).created_by,
          p_x_effectivity_tbl(i).last_update_login
        ) RETURNING mr_effectivity_id INTO l_mr_effectivity_id;

        -- Set OUT values
        p_x_effectivity_tbl(i).mr_effectivity_id := l_mr_effectivity_id;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_EFFECTIVITY_NAME_DUP' );
            FND_MESSAGE.set_token( 'RECORD', p_x_effectivity_tbl(i).name );
            FND_MSG_PUB.add;
          END IF;
      END;

    ELSIF ( p_x_effectivity_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_MR_EFFECTIVITIES SET
          object_version_number   = object_version_number + 1,
          name                    = p_x_effectivity_tbl(i).name,
          inventory_item_id       = DECODE(
                                     p_x_effectivity_tbl(i).relationship_id,
                                     NULL,
                                     p_x_effectivity_tbl(i).inventory_item_id,
                                     p_x_effectivity_tbl(i).position_inventory_item_id ),
          relationship_id         = p_x_effectivity_tbl(i).relationship_id,
          pc_node_id              = p_x_effectivity_tbl(i).pc_node_id,
          attribute_category      = p_x_effectivity_tbl(i).attribute_category,
          attribute1              = p_x_effectivity_tbl(i).attribute1,
          attribute2              = p_x_effectivity_tbl(i).attribute2,
          attribute3              = p_x_effectivity_tbl(i).attribute3,
          attribute4              = p_x_effectivity_tbl(i).attribute4,
          attribute5              = p_x_effectivity_tbl(i).attribute5,
          attribute6              = p_x_effectivity_tbl(i).attribute6,
          attribute7              = p_x_effectivity_tbl(i).attribute7,
          attribute8              = p_x_effectivity_tbl(i).attribute8,
          attribute9              = p_x_effectivity_tbl(i).attribute9,
          attribute10             = p_x_effectivity_tbl(i).attribute10,
          attribute11             = p_x_effectivity_tbl(i).attribute11,
          attribute12             = p_x_effectivity_tbl(i).attribute12,
          attribute13             = p_x_effectivity_tbl(i).attribute13,
          attribute14             = p_x_effectivity_tbl(i).attribute14,
          attribute15             = p_x_effectivity_tbl(i).attribute15,
          last_update_date        = p_x_effectivity_tbl(i).last_update_date,
          last_updated_by         = p_x_effectivity_tbl(i).last_updated_by,
          last_update_login       = p_x_effectivity_tbl(i).last_update_login
        WHERE mr_effectivity_id   = p_x_effectivity_tbl(i).mr_effectivity_id
        AND object_version_number = p_x_effectivity_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_tbl(i) ) );
          FND_MSG_PUB.add;
        END IF;

        -- Set OUT values
        p_x_effectivity_tbl(i).object_version_number := p_x_effectivity_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_EFFECTIVITY_NAME_DUP' );
            FND_MESSAGE.set_token( 'RECORD', p_x_effectivity_tbl(i).name );
            FND_MSG_PUB.add;
          END IF;
      END;

    ELSIF ( p_x_effectivity_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE AHL_MR_EFFECTIVITIES
      WHERE mr_effectivity_id   = p_x_effectivity_tbl(i).mr_effectivity_id
      AND object_version_number = p_x_effectivity_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
      END IF;

      -- Delete the record in related Tables
      DELETE AHL_MR_EFFECTIVITY_DTLS
      WHERE mr_effectivity_id   = p_x_effectivity_tbl(i).mr_effectivity_id;

      -- If the record does not exist, then, Continue.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        -- Ignore the Exception
        NULL;
      END IF;

      -- Delete the record in related Tables
      DELETE AHL_MR_INTERVALS
      WHERE mr_effectivity_id   = p_x_effectivity_tbl(i).mr_effectivity_id;

      -- If the record does not exist, then, Continue.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        -- Ignore the Exception
        NULL;
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

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( 'Before  Validate Records ' );
  END IF;

  validate_records
  (
    p_mr_header_id, -- IN
    g_appln_usage, -- IN
    l_return_status -- OUT
  );


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( 'After  Validate Records ' );
  END IF;


  -- If any severe error occurs, then, abort API.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
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
    ROLLBACK TO process_effectivity_PVT;
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
    ROLLBACK TO process_effectivity_PVT;
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
    ROLLBACK TO process_effectivity_PVT;
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

END process_effectivity;

END AHL_FMP_MR_EFFECTIVITY_PVT;

/
