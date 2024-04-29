--------------------------------------------------------
--  DDL for Package Body AHL_RM_ASO_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ASO_RESOURCE_PVT" AS
/* $Header: AHLVASRB.pls 120.0.12010000.2 2008/10/24 07:21:06 pdoki ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_ASO_RESOURCE_PVT';
G_API_NAME VARCHAR2(30) := 'PROCESS_ASO_RESOURCE';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

-- Procedure to validate the Inputs of the API

PROCEDURE validate_api_inputs
(
  p_aso_resource_rec        IN   aso_resource_rec_type,
  p_bom_resource_tbl        IN   bom_resource_tbl_type
)
IS

BEGIN

  -- Validate DML Operation
  IF ( p_aso_resource_rec.dml_operation <> 'D' AND
       p_aso_resource_rec.dml_operation <> 'U' AND
       p_aso_resource_rec.dml_operation <> 'C' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_aso_resource_rec.dml_operation );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF p_bom_resource_tbl.count > 0 THEN
  FOR i IN p_bom_resource_tbl.FIRST..p_bom_resource_tbl.LAST LOOP
    IF ( p_bom_resource_tbl(i).dml_operation <> 'D' AND
         p_bom_resource_tbl(i).dml_operation <> 'U' AND
         p_bom_resource_tbl(i).dml_operation <> 'C' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_bom_resource_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', p_bom_resource_tbl(i).bom_resource_code ) ;
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;
  END IF;
  IF ( p_aso_resource_rec.dml_operation = 'C' and p_bom_resource_tbl.count >0 ) THEN
    FOR i IN p_bom_resource_tbl.FIRST..p_bom_resource_tbl.LAST LOOP
      IF p_bom_resource_tbl(i).dml_operation <> 'C' THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
        FND_MESSAGE.set_token( 'FIELD', p_bom_resource_tbl(i).dml_operation );
        FND_MESSAGE.set_token( 'RECORD', p_bom_resource_tbl(i).bom_resource_code ) ;
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_aso_resource_rec       IN OUT NOCOPY  aso_resource_rec_type,
  p_x_bom_resource_tbl       IN OUT NOCOPY  bom_resource_tbl_type
)
IS
BEGIN
  IF (p_x_aso_resource_rec.dml_operation <> 'D') THEN
    IF ( p_x_aso_resource_rec.resource_type IS NULL ) THEN
      p_x_aso_resource_rec.resource_type_id := NULL;
    ELSIF ( p_x_aso_resource_rec.resource_type = FND_API.G_MISS_CHAR ) THEN
      p_x_aso_resource_rec.resource_type_id := FND_API.G_MISS_NUM;
    END IF;
  END IF;
  IF p_x_bom_resource_tbl.count > 0 THEN
  FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
    IF (p_x_bom_resource_tbl(i).dml_operation <> 'D') THEN
      IF ( p_x_bom_resource_tbl(i).bom_resource_code IS NULL ) THEN
        p_x_bom_resource_tbl(i).bom_resource_id := NULL;
      ELSIF ( p_x_bom_resource_tbl(i).bom_resource_code = FND_API.G_MISS_CHAR ) THEN
        p_x_bom_resource_tbl(i).bom_resource_id := FND_API.G_MISS_NUM;
      END IF;
    END IF;
  END LOOP;
  END IF;
END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_aso_resource_rec      IN OUT NOCOPY  aso_resource_rec_type,
  p_x_bom_resource_tbl      IN OUT NOCOPY  bom_resource_tbl_type
)
IS

l_return_status           VARCHAR2(1);
l_total_return_status     VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  l_total_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate ASO Resource Type
  IF ( p_x_aso_resource_rec.dml_operation <> 'D') THEN
    IF ( ( p_x_aso_resource_rec.resource_type_id IS NOT NULL AND
           p_x_aso_resource_rec.resource_type_id <> FND_API.G_MISS_NUM ) OR
         ( p_x_aso_resource_rec.resource_type IS NOT NULL AND
           p_x_aso_resource_rec.resource_type <> FND_API.G_MISS_CHAR ) ) THEN

      AHL_RM_ROUTE_UTIL.validate_mfg_lookup
      (
        x_return_status        => l_return_status,
        x_msg_data             => l_msg_data,
        p_lookup_type          => 'BOM_RESOURCE_TYPE',
        p_lookup_meaning       => p_x_aso_resource_rec.resource_type,
        p_x_lookup_code        => p_x_aso_resource_rec.resource_type_id
      );

      IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
        IF ( l_msg_data = 'AHL_COM_INVALID_MFG_LOOKUP' ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RES_TYPE' );
        ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_RES_TYPES' );
        ELSE
          FND_MESSAGE.set_name( 'AHL', l_msg_data );
        END IF;

        IF ( p_x_aso_resource_rec.resource_type IS NULL OR
           p_x_aso_resource_rec.resource_type = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD', p_x_aso_resource_rec.resource_type_id );
        ELSE
          FND_MESSAGE.set_token( 'FIELD', p_x_aso_resource_rec.resource_type );
        END IF;

        FND_MSG_PUB.add;
        l_total_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END IF;

  -- Convert / Validate BOM Resource Code
  IF p_x_bom_resource_tbl.count > 0 THEN
  FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
    IF (p_x_bom_resource_tbl(i).dml_operation <> 'D' ) THEN
      IF ( ( p_x_bom_resource_tbl(i).bom_resource_code IS NOT NULL AND
             p_x_bom_resource_tbl(i).bom_resource_code <> FND_API.G_MISS_CHAR ) OR
         ( p_x_bom_resource_tbl(i).bom_resource_id IS NOT NULL AND
           p_x_bom_resource_tbl(i).bom_resource_id <> FND_API.G_MISS_NUM ) ) THEN

         AHL_RM_ROUTE_UTIL.validate_bom_resource
         (
           x_return_status        => l_return_status,
           x_msg_data             => l_msg_data,
           p_bom_resource_code    => p_x_bom_resource_tbl(i).bom_resource_code,
           p_x_bom_resource_id    => p_x_bom_resource_tbl(i).bom_resource_id,
           p_x_bom_org_id         => p_x_bom_resource_tbl(i).bom_org_id
         );

         IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
           FND_MESSAGE.set_name( 'AHL', l_msg_data );
           IF ( p_x_bom_resource_tbl(i).bom_resource_code IS NULL OR
             p_x_bom_resource_tbl(i).bom_resource_code = FND_API.G_MISS_CHAR ) THEN
             FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_bom_resource_tbl(i).bom_resource_id ) );
             FND_MESSAGE.set_token( 'RECORD', TO_CHAR( p_x_bom_resource_tbl(i).bom_resource_id ) );
           ELSE
             FND_MESSAGE.set_token( 'FIELD', p_x_bom_resource_tbl(i).bom_resource_code );
             FND_MESSAGE.set_token( 'RECORD', p_x_bom_resource_tbl(i).bom_resource_code );
           END IF;
           FND_MSG_PUB.add;
           l_total_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

  -- pdoki ER 7436910 Begin.
  -- Convert / Validate BOM resource's department
      IF ( ( p_x_bom_resource_tbl(i).department_name IS NOT NULL AND
             p_x_bom_resource_tbl(i).department_name <> FND_API.G_MISS_CHAR ) OR
         ( p_x_bom_resource_tbl(i).department_id IS NOT NULL AND
           p_x_bom_resource_tbl(i).department_id <> FND_API.G_MISS_NUM ) ) THEN

         IF (p_x_bom_resource_tbl(i).bom_resource_id IS NULL OR p_x_bom_resource_tbl(i).bom_resource_id = FND_API.G_MISS_NUM)
         THEN
              FND_MESSAGE.set_name( 'AHL','AHL_RM_BOM_RES_ID_NULL' );
              FND_MESSAGE.set_token( 'RECORD',TO_CHAR(i));
              FND_MSG_PUB.add;
              l_total_return_status := FND_API.G_RET_STS_ERROR;
         ELSE
             AHL_RM_ROUTE_UTIL.validate_bom_res_dep
             (
               x_return_status        => l_return_status,
               x_msg_data             => l_msg_data,
               p_bom_resource_id      => p_x_bom_resource_tbl(i).bom_resource_id,
               p_bom_org_id           => p_x_bom_resource_tbl(i).bom_org_id,
               p_bom_department_name  => p_x_bom_resource_tbl(i).department_name,
               p_x_bom_department_id  => p_x_bom_resource_tbl(i).department_id
             );

             IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
               FND_MESSAGE.set_name( 'AHL', l_msg_data );
               IF ( p_x_bom_resource_tbl(i).department_name IS NULL OR
                 p_x_bom_resource_tbl(i).department_name = FND_API.G_MISS_CHAR ) THEN
                 FND_MESSAGE.set_token( 'RECORD', TO_CHAR( p_x_bom_resource_tbl(i).department_id ) );
               ELSE
                 FND_MESSAGE.set_token( 'RECORD', p_x_bom_resource_tbl(i).department_name );
               END IF;
               FND_MSG_PUB.add;
               l_total_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
          END IF;
      END IF;
-- pdoki ER 7436910 End.

    END IF;
  END LOOP;
  IF (l_total_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  END IF;
END convert_values_to_ids;

-- Procedure to add Default values for aso_resource attributes
PROCEDURE default_attributes
(
  p_x_aso_resource_rec       IN OUT NOCOPY   aso_resource_rec_type,
  p_x_bom_resource_tbl       IN OUT NOCOPY   bom_resource_tbl_type
)
IS

BEGIN
  IF p_x_aso_resource_rec.dml_operation <> 'D' THEN
    p_x_aso_resource_rec.last_update_date := SYSDATE;
    p_x_aso_resource_rec.last_updated_by := FND_GLOBAL.user_id;
    p_x_aso_resource_rec.last_update_login := FND_GLOBAL.login_id;
  END IF;

  IF ( p_x_aso_resource_rec.dml_operation = 'C' ) THEN
    p_x_aso_resource_rec.object_version_number := 1;
    p_x_aso_resource_rec.creation_date := SYSDATE;
    p_x_aso_resource_rec.created_by := FND_GLOBAL.user_id;
  END IF;
  IF p_x_bom_resource_tbl.count > 0 THEN
  FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
    IF ( p_x_bom_resource_tbl(i).dml_operation <> 'D' ) THEN
      p_x_bom_resource_tbl(i).last_update_date := SYSDATE;
      p_x_bom_resource_tbl(i).last_updated_by := FND_GLOBAL.user_id;
      p_x_bom_resource_tbl(i).last_update_login := FND_GLOBAL.login_id;
    END IF;

    IF ( p_x_bom_resource_tbl(i).dml_operation = 'C' ) THEN
      p_x_bom_resource_tbl(i).object_version_number := 1;
      p_x_bom_resource_tbl(i).creation_date := SYSDATE;
      p_x_bom_resource_tbl(i).created_by := FND_GLOBAL.user_id;
    END IF;
  END LOOP;
  END IF;
END default_attributes;

-- Procedure to validate individual aso_resource attributes
PROCEDURE validate_attributes
(
  p_aso_resource_rec  IN    aso_resource_rec_type,
  p_bom_resource_tbl  IN    bom_resource_tbl_type
)
IS

BEGIN

  IF ( p_aso_resource_rec.dml_operation = 'C' OR
       p_aso_resource_rec.dml_operation = 'U' ) THEN
    -- Check if the mandatory resource_type column contains a value.
    IF ( (p_aso_resource_rec.resource_type_id IS NULL OR
         p_aso_resource_rec.resource_type_id = FND_API.G_MISS_NUM) AND
         p_aso_resource_rec.dml_operation <> 'U' ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_ASO_RES_TYPE_NULL' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if the mandatory name column contains a value.
    IF ( p_aso_resource_rec.name IS NULL OR
         p_aso_resource_rec.name = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_ASO_RES_NAME_NULL' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if the mandatory description column contains a value.
    IF ( p_aso_resource_rec.description IS NULL OR
         p_aso_resource_rec.description = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_ASO_RES_DESC_NULL' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Check if the mandatory bom_resource_id column in details table contains a value.
  IF p_bom_resource_tbl.count > 0 THEN
  FOR i IN p_bom_resource_tbl.FIRST..p_bom_resource_tbl.LAST LOOP
    IF ( p_bom_resource_tbl(i).dml_operation = 'C' OR
         p_bom_resource_tbl(i).dml_operation = 'U' ) THEN

      IF (p_bom_resource_tbl(i).bom_resource_id IS NULL OR
          p_bom_resource_tbl(i).bom_resource_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_RM_BOM_RES_ID_NULL' );
        FND_MESSAGE.set_token( 'RECORD',TO_CHAR(i));
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_bom_resource_tbl(i).bom_org_id IS NULL OR
          p_bom_resource_tbl(i).bom_org_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_RM_BOM_ORG_ID_NULL' );
        FND_MESSAGE.set_token( 'RECORD',p_bom_resource_tbl(i).bom_resource_code);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;
  END IF;
END validate_attributes;

-- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_miss_aso_attributes
(
  p_x_aso_resource_rec       IN OUT NOCOPY   aso_resource_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF p_x_aso_resource_rec.dml_operation = 'C' THEN
  IF ( p_x_aso_resource_rec.resource_type_id = FND_API.G_MISS_NUM ) THEN
    p_x_aso_resource_rec.resource_type_id := null;
  END IF;

  IF ( p_x_aso_resource_rec.name = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.name := null;
  END IF;

  IF ( p_x_aso_resource_rec.description = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.description := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute_category := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute1 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute2 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute3 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute4 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute5 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute6 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute7 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute8 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute9 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute10 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute11 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute12 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute13 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute14 := null;
  END IF;

  IF ( p_x_aso_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute15 := null;
  END IF;
  END IF;
END default_miss_aso_attributes;

-- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_miss_bom_attributes
(
  p_x_bom_resource_rec       IN OUT NOCOPY   bom_resource_rec_type
)
IS

BEGIN
  IF ( p_x_bom_resource_rec.dml_operation = 'C') THEN
    IF ( p_x_bom_resource_rec.bom_resource_id = FND_API.G_MISS_NUM ) THEN
      p_x_bom_resource_rec.bom_resource_id := null;
    END IF;

    IF ( p_x_bom_resource_rec.bom_org_id = FND_API.G_MISS_NUM ) THEN
      p_x_bom_resource_rec.bom_org_id := null;
    END IF;

    --pdoki ER 7436910 Begin.
    IF ( p_x_bom_resource_rec.department_id = FND_API.G_MISS_NUM ) THEN
      p_x_bom_resource_rec.department_id := null;
    END IF;
    --pdoki ER 7436910 End.

    IF ( p_x_bom_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute_category := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute1 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute2 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute3 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute4 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute5 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute6 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute7 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute8 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute9 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute10 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute11 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute12 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute13 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute14 := null;
    END IF;

    IF ( p_x_bom_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
      p_x_bom_resource_rec.attribute15 := null;
    END IF;
  END IF;
END default_miss_bom_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unc_aso_attributes
(
  p_x_aso_resource_rec       IN OUT NOCOPY   aso_resource_rec_type
)
IS

l_old_aso_resource_rec       aso_resource_rec_type;

CURSOR get_old_aso_rec ( c_resource_id NUMBER )
IS
SELECT  resource_id,
        resource_type_id,
        name,
        description,
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
FROM    AHL_RESOURCES
WHERE   resource_id = c_resource_id;

BEGIN

  -- Get the old record from AHL_RESOURCES.
  OPEN  get_old_aso_rec( p_x_aso_resource_rec.resource_id );

  FETCH get_old_aso_rec INTO
        l_old_aso_resource_rec.resource_id,
        l_old_aso_resource_rec.resource_type_id,
        l_old_aso_resource_rec.name,
        l_old_aso_resource_rec.description,
        l_old_aso_resource_rec.attribute_category,
        l_old_aso_resource_rec.attribute1,
        l_old_aso_resource_rec.attribute2,
        l_old_aso_resource_rec.attribute3,
        l_old_aso_resource_rec.attribute4,
        l_old_aso_resource_rec.attribute5,
        l_old_aso_resource_rec.attribute6,
        l_old_aso_resource_rec.attribute7,
        l_old_aso_resource_rec.attribute8,
        l_old_aso_resource_rec.attribute9,
        l_old_aso_resource_rec.attribute10,
        l_old_aso_resource_rec.attribute11,
        l_old_aso_resource_rec.attribute12,
        l_old_aso_resource_rec.attribute13,
        l_old_aso_resource_rec.attribute14,
        l_old_aso_resource_rec.attribute15;

  IF get_old_aso_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ASO_REC' );
    FND_MSG_PUB.add;
    CLOSE get_old_aso_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_aso_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values

  IF ( p_x_aso_resource_rec.name = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.name := null;
  ELSIF ( p_x_aso_resource_rec.name IS NULL ) THEN
    p_x_aso_resource_rec.name := l_old_aso_resource_rec.name;
  END IF;

  IF ( p_x_aso_resource_rec.description = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.description := null;
  ELSIF ( p_x_aso_resource_rec.description IS NULL ) THEN
    p_x_aso_resource_rec.description := l_old_aso_resource_rec.description;
  END IF;

  IF ( p_x_aso_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute_category := null;
  ELSIF ( p_x_aso_resource_rec.attribute_category IS NULL ) THEN
    p_x_aso_resource_rec.attribute_category := l_old_aso_resource_rec.attribute_category;
  END IF;

  IF ( p_x_aso_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute1 := null;
  ELSIF ( p_x_aso_resource_rec.attribute1 IS NULL ) THEN
    p_x_aso_resource_rec.attribute1 := l_old_aso_resource_rec.attribute1;
  END IF;

  IF ( p_x_aso_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute2 := null;
  ELSIF ( p_x_aso_resource_rec.attribute2 IS NULL ) THEN
    p_x_aso_resource_rec.attribute2 := l_old_aso_resource_rec.attribute2;
  END IF;

  IF ( p_x_aso_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute3 := null;
  ELSIF ( p_x_aso_resource_rec.attribute3 IS NULL ) THEN
    p_x_aso_resource_rec.attribute3 := l_old_aso_resource_rec.attribute3;
  END IF;

  IF ( p_x_aso_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute4 := null;
  ELSIF ( p_x_aso_resource_rec.attribute4 IS NULL ) THEN
    p_x_aso_resource_rec.attribute4 := l_old_aso_resource_rec.attribute4;
  END IF;

  IF ( p_x_aso_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute5 := null;
  ELSIF ( p_x_aso_resource_rec.attribute5 IS NULL ) THEN
    p_x_aso_resource_rec.attribute5 := l_old_aso_resource_rec.attribute5;
  END IF;

  IF ( p_x_aso_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute6 := null;
  ELSIF ( p_x_aso_resource_rec.attribute6 IS NULL ) THEN
    p_x_aso_resource_rec.attribute6 := l_old_aso_resource_rec.attribute6;
  END IF;

  IF ( p_x_aso_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute7 := null;
  ELSIF ( p_x_aso_resource_rec.attribute7 IS NULL ) THEN
    p_x_aso_resource_rec.attribute7 := l_old_aso_resource_rec.attribute7;
  END IF;

  IF ( p_x_aso_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute8 := null;
  ELSIF ( p_x_aso_resource_rec.attribute8 IS NULL ) THEN
    p_x_aso_resource_rec.attribute8 := l_old_aso_resource_rec.attribute8;
  END IF;

  IF ( p_x_aso_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute9 := null;
  ELSIF ( p_x_aso_resource_rec.attribute9 IS NULL ) THEN
    p_x_aso_resource_rec.attribute9 := l_old_aso_resource_rec.attribute9;
  END IF;

  IF ( p_x_aso_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute10 := null;
  ELSIF ( p_x_aso_resource_rec.attribute10 IS NULL ) THEN
    p_x_aso_resource_rec.attribute10 := l_old_aso_resource_rec.attribute10;
  END IF;

  IF ( p_x_aso_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute11 := null;
  ELSIF ( p_x_aso_resource_rec.attribute11 IS NULL ) THEN
    p_x_aso_resource_rec.attribute11 := l_old_aso_resource_rec.attribute11;
  END IF;

  IF ( p_x_aso_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute12 := null;
  ELSIF ( p_x_aso_resource_rec.attribute12 IS NULL ) THEN
    p_x_aso_resource_rec.attribute12 := l_old_aso_resource_rec.attribute12;
  END IF;

  IF ( p_x_aso_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute13 := null;
  ELSIF ( p_x_aso_resource_rec.attribute13 IS NULL ) THEN
    p_x_aso_resource_rec.attribute13 := l_old_aso_resource_rec.attribute13;
  END IF;

  IF ( p_x_aso_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute14 := null;
  ELSIF ( p_x_aso_resource_rec.attribute14 IS NULL ) THEN
    p_x_aso_resource_rec.attribute14 := l_old_aso_resource_rec.attribute14;
  END IF;

  IF ( p_x_aso_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_aso_resource_rec.attribute15 := null;
  ELSIF ( p_x_aso_resource_rec.attribute15 IS NULL ) THEN
    p_x_aso_resource_rec.attribute15 := l_old_aso_resource_rec.attribute15;
  END IF;

END default_unc_aso_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unc_bom_attributes
(p_x_bom_resource_rec       IN OUT NOCOPY   bom_resource_rec_type)
IS
l_old_bom_resource_rec       bom_resource_rec_type;
CURSOR get_old_bom_rec ( c_resource_mapping_id NUMBER )
IS
SELECT  bom_resource_id,
        bom_org_id,
        department_id, --pdoki ER 7436910
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
FROM    AHL_RESOURCE_MAPPINGS
WHERE   resource_mapping_id = c_resource_mapping_id;

BEGIN

  -- Get the old record from AHL_RESOURCES.
  OPEN  get_old_bom_rec( p_x_bom_resource_rec.resource_mapping_id );

  FETCH get_old_bom_rec INTO
        l_old_bom_resource_rec.bom_resource_id,
        l_old_bom_resource_rec.bom_org_id,
        l_old_bom_resource_rec.department_id,--pdoki ER 7436910
        l_old_bom_resource_rec.attribute_category,
        l_old_bom_resource_rec.attribute1,
        l_old_bom_resource_rec.attribute2,
        l_old_bom_resource_rec.attribute3,
        l_old_bom_resource_rec.attribute4,
        l_old_bom_resource_rec.attribute5,
        l_old_bom_resource_rec.attribute6,
        l_old_bom_resource_rec.attribute7,
        l_old_bom_resource_rec.attribute8,
        l_old_bom_resource_rec.attribute9,
        l_old_bom_resource_rec.attribute10,
        l_old_bom_resource_rec.attribute11,
        l_old_bom_resource_rec.attribute12,
        l_old_bom_resource_rec.attribute13,
        l_old_bom_resource_rec.attribute14,
        l_old_bom_resource_rec.attribute15;

  IF get_old_bom_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_MAPPING_REC' );
    FND_MESSAGE.set_token( 'RECORD', p_x_bom_resource_rec.bom_resource_code);
    FND_MSG_PUB.add;
    CLOSE get_old_bom_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_bom_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_bom_resource_rec.bom_resource_id = FND_API.G_MISS_NUM ) THEN
    p_x_bom_resource_rec.bom_resource_id := null;
  ELSIF ( p_x_bom_resource_rec.bom_resource_id IS NULL ) THEN
    p_x_bom_resource_rec.bom_resource_id := l_old_bom_resource_rec.bom_resource_id;
  END IF;

  IF ( p_x_bom_resource_rec.bom_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_bom_resource_rec.bom_org_id := null;
  ELSIF ( p_x_bom_resource_rec.bom_org_id IS NULL ) THEN
    p_x_bom_resource_rec.bom_org_id := l_old_bom_resource_rec.bom_org_id;
  END IF;

  IF ( p_x_bom_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute_category := null;
  ELSIF ( p_x_bom_resource_rec.attribute_category IS NULL ) THEN
    p_x_bom_resource_rec.attribute_category := l_old_bom_resource_rec.attribute_category;
  END IF;

  IF ( p_x_bom_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute1 := null;
  ELSIF ( p_x_bom_resource_rec.attribute1 IS NULL ) THEN
    p_x_bom_resource_rec.attribute1 := l_old_bom_resource_rec.attribute1;
  END IF;

  IF ( p_x_bom_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute2 := null;
  ELSIF ( p_x_bom_resource_rec.attribute2 IS NULL ) THEN
    p_x_bom_resource_rec.attribute2 := l_old_bom_resource_rec.attribute2;
  END IF;

  IF ( p_x_bom_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute3 := null;
  ELSIF ( p_x_bom_resource_rec.attribute3 IS NULL ) THEN
    p_x_bom_resource_rec.attribute3 := l_old_bom_resource_rec.attribute3;
  END IF;

  IF ( p_x_bom_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute4 := null;
  ELSIF ( p_x_bom_resource_rec.attribute4 IS NULL ) THEN
    p_x_bom_resource_rec.attribute4 := l_old_bom_resource_rec.attribute4;
  END IF;

  IF ( p_x_bom_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute5 := null;
  ELSIF ( p_x_bom_resource_rec.attribute5 IS NULL ) THEN
    p_x_bom_resource_rec.attribute5 := l_old_bom_resource_rec.attribute5;
  END IF;

  IF ( p_x_bom_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute6 := null;
  ELSIF ( p_x_bom_resource_rec.attribute6 IS NULL ) THEN
    p_x_bom_resource_rec.attribute6 := l_old_bom_resource_rec.attribute6;
  END IF;

  IF ( p_x_bom_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute7 := null;
  ELSIF ( p_x_bom_resource_rec.attribute7 IS NULL ) THEN
    p_x_bom_resource_rec.attribute7 := l_old_bom_resource_rec.attribute7;
  END IF;

  IF ( p_x_bom_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute8 := null;
  ELSIF ( p_x_bom_resource_rec.attribute8 IS NULL ) THEN
    p_x_bom_resource_rec.attribute8 := l_old_bom_resource_rec.attribute8;
  END IF;

  IF ( p_x_bom_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute9 := null;
  ELSIF ( p_x_bom_resource_rec.attribute9 IS NULL ) THEN
    p_x_bom_resource_rec.attribute9 := l_old_bom_resource_rec.attribute9;
  END IF;

  IF ( p_x_bom_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute10 := null;
  ELSIF ( p_x_bom_resource_rec.attribute10 IS NULL ) THEN
    p_x_bom_resource_rec.attribute10 := l_old_bom_resource_rec.attribute10;
  END IF;

  IF ( p_x_bom_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute11 := null;
  ELSIF ( p_x_bom_resource_rec.attribute11 IS NULL ) THEN
    p_x_bom_resource_rec.attribute11 := l_old_bom_resource_rec.attribute11;
  END IF;

  IF ( p_x_bom_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute12 := null;
  ELSIF ( p_x_bom_resource_rec.attribute12 IS NULL ) THEN
    p_x_bom_resource_rec.attribute12 := l_old_bom_resource_rec.attribute12;
  END IF;

  IF ( p_x_bom_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute13 := null;
  ELSIF ( p_x_bom_resource_rec.attribute13 IS NULL ) THEN
    p_x_bom_resource_rec.attribute13 := l_old_bom_resource_rec.attribute13;
  END IF;

  IF ( p_x_bom_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute14 := null;
  ELSIF ( p_x_bom_resource_rec.attribute14 IS NULL ) THEN
    p_x_bom_resource_rec.attribute14 := l_old_bom_resource_rec.attribute14;
  END IF;

  IF ( p_x_bom_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_bom_resource_rec.attribute15 := null;
  ELSIF ( p_x_bom_resource_rec.attribute15 IS NULL ) THEN
    p_x_bom_resource_rec.attribute15 := l_old_bom_resource_rec.attribute15;
  END IF;

END default_unc_bom_attributes;

-- Procedure to cross fields record validation in details table
PROCEDURE validate_bom_record
(
  p_aso_resource_rec      IN    aso_resource_rec_type,
  p_bom_resource_tbl      IN    bom_resource_tbl_type
)
IS

CURSOR get_bom_rec ( c_bom_resource_id NUMBER)
IS
SELECT   resource_type, disable_date
FROM     BOM_RESOURCES
WHERE    resource_id = c_bom_resource_id;

l_get_bom_rec      get_bom_rec%ROWTYPE;
l_res_type         NUMBER;
l_return_status    VARCHAR2(1);

BEGIN
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_bom_resource_tbl.count > 0 THEN
    FOR i IN p_bom_resource_tbl.FIRST..p_bom_resource_tbl.LAST LOOP
    IF p_bom_resource_tbl(i).dml_operation <> 'D' THEN
      OPEN get_bom_rec(p_bom_resource_tbl(i).bom_resource_id);
      FETCH get_bom_rec INTO l_get_bom_rec;
      IF get_bom_rec%NOTFOUND THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_BOM_RES_REC' );
        FND_MESSAGE.set_token( 'RECORD', p_bom_resource_tbl(i).bom_resource_code);
        FND_MSG_PUB.add;
        l_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF trunc(nvl(l_get_bom_rec.disable_date,sysdate))<trunc(sysdate) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_BOM_RES_OUTDATED' );
        FND_MESSAGE.set_token( 'RECORD', p_bom_resource_tbl(i).bom_resource_code);
        FND_MSG_PUB.add;
        l_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF (l_get_bom_rec.resource_type <> p_aso_resource_rec.resource_type_id
             OR l_get_bom_rec.resource_type IS NULL) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_BOM_RES_TYPE_NOT_MATCH' );
        FND_MESSAGE.set_token( 'RECORD', p_bom_resource_tbl(i).bom_resource_code);
        FND_MSG_PUB.add;
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE get_bom_rec;
    END IF;
    END LOOP;
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
END validate_bom_record;

-- Procedure to perform cross records validation and duplicate checks in master table
PROCEDURE validate_aso_records
(
  p_aso_resource_rec      IN    aso_resource_rec_type
)
IS

CURSOR get_dup_rec ( c_resource_id NUMBER, c_name VARCHAR2)
IS
SELECT   name
FROM     AHL_RESOURCES
WHERE    UPPER(TRIM(NAME)) = UPPER(TRIM(c_name))
AND      (resource_id <> c_resource_id
OR        c_resource_id IS NULL);

l_name      get_dup_rec%ROWTYPE;

BEGIN

  -- Check whether any duplicate aso_resource records for the given object_ID
  OPEN  get_dup_rec( p_aso_resource_rec.resource_id, p_aso_resource_rec.NAME);
  FETCH get_dup_rec INTO l_name;
  IF ( get_dup_rec%FOUND ) THEN
    CLOSE get_dup_rec;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ASO_RESOURCE_DUP' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE get_dup_rec;
  END IF;

END validate_aso_records;

-- Procedure to perform cross records validation in details table
PROCEDURE validate_records
(
  p_aso_resource_rec      IN    aso_resource_rec_type,
  p_bom_resource_tbl      IN    bom_resource_tbl_type
)
IS

BEGIN
  IF (p_aso_resource_rec.dml_operation = 'C' AND
      p_bom_resource_tbl.COUNT = 0) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_BOM_RES_COUNT_ZERO' );
    FND_MSG_PUB.add;
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  Inside validate_records procedure');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
END validate_records;

-- Procedure to perform cross records validation in details table after DML Operations
PROCEDURE validate_bom_records
(
  p_aso_resource_id       IN    NUMBER
)
IS
CURSOR get_bom_res_num (c_aso_resource_id number) IS
  SELECT count(bom_resource_id)
    FROM ahl_resource_mappings
   WHERE aso_resource_id = c_aso_resource_id;
CURSOR get_bom_res_org (c_aso_resource_id number) IS
  SELECT count(bom_resource_id)
    FROM ahl_resource_mappings
   WHERE aso_resource_id = c_aso_resource_id
GROUP BY aso_resource_id, bom_org_id
  HAVING count(bom_resource_id) > 1;
CURSOR get_bom_res_dup (c_aso_resource_id number) IS
  SELECT bom_resource_id
    FROM ahl_resource_mappings
   WHERE aso_resource_id = c_aso_resource_id
GROUP BY aso_resource_id, bom_resource_id, bom_org_id
  HAVING count(resource_mapping_id) >1;

--pdoki ER 7436910 Begin.
CURSOR get_rt_oper_res_obj (c_aso_resource_id number) IS
  SELECT DISTINCT object_id, association_type_code
    FROM ahl_rt_oper_resources
   WHERE aso_resource_id = c_aso_resource_id;
--checking dept conflicts among primary resources
CURSOR get_dept_conflicts ( c_object_id NUMBER, c_association_type_code VARCHAR2 )
IS
    SELECT 'X'
    FROM    ahl_resource_mappings
    WHERE   DEPARTMENT_ID IS NOT NULL
            AND aso_resource_id in
            (SELECT ASO_RESOURCE_ID
            FROM    ahl_rt_oper_resources
            WHERE   object_id                 = c_object_id
                    AND ASSOCIATION_TYPE_CODE = c_association_type_code
            )
    GROUP BY bom_org_id
    HAVING count(DISTINCT DEPARTMENT_ID) > 1;

--checking dept conflicts b/w the primary resource and alt resources of OTHER primary resources.here the resource is a primary resource(in rt_oper_resources table)
CURSOR get_dept_conflicts_alt_res ( c_object_id NUMBER, c_association_type_code VARCHAR2, c_rt_oper_res_id NUMBER)
IS
SELECT 'X'
FROM    ahl_resource_mappings
WHERE   DEPARTMENT_ID IS NOT NULL
        AND aso_resource_id in
        (SELECT ALTR.ASO_RESOURCE_ID
        FROM    ahl_alternate_resources ALTR,
                (SELECT RT_OPER_RESOURCE_ID
                FROM    ahl_rt_oper_resources
                WHERE   RT_OPER_RESOURCE_ID      <> c_rt_oper_res_id
                        AND ASSOCIATION_TYPE_CODE = c_association_type_code
                        AND OBJECT_ID             = c_object_id
                )
                ROR
        WHERE   ROR.RT_OPER_RESOURCE_ID = ALTR.rt_oper_resource_id
        )
        OR aso_resource_id =
        (SELECT aso_resource_id
        FROM    ahl_rt_oper_resources
        WHERE   RT_OPER_RESOURCE_ID = c_rt_oper_res_id
        )
GROUP BY bom_org_id
HAVING count(DISTINCT DEPARTMENT_ID) > 1;

CURSOR get_rt_oper_res_ids ( c_object_id NUMBER, c_association_type_code VARCHAR2)
IS
SELECT  RT_OPER_RESOURCE_ID
FROM    AHL_RT_OPER_RESOURCES
WHERE   ASSOCIATION_TYPE_CODE = c_association_type_code
        AND OBJECT_ID         = c_object_id;

--checks for conflicts b/w the alternate resource and other primary resources. here the resource is an alternate resource(in alternate_resources table)
CURSOR get_dept_conflicts_alt_pri ( c_object_id NUMBER, c_association_type_code VARCHAR2, c_aso_res_id NUMBER, c_alt_res_id NUMBER)
IS
SELECT 'X'
FROM    ahl_resource_mappings
WHERE   DEPARTMENT_ID IS NOT NULL
        AND aso_resource_id in
        (
        SELECT ASO_RESOURCE_ID
        FROM    ahl_rt_oper_resources
        WHERE   object_id                 = c_object_id
                AND ASSOCIATION_TYPE_CODE = c_association_type_code
                AND ASO_RESOURCE_ID <> c_aso_res_id
        )
        OR aso_resource_id = c_alt_res_id
GROUP BY bom_org_id
HAVING count(DISTINCT DEPARTMENT_ID) > 1;

CURSOR get_rt_oper_res_det (c_rt_oper_resource_id number)
IS
SELECT OBJECT_ID,ASSOCIATION_TYPE_CODE, ASO_RESOURCE_ID
FROM AHL_RT_OPER_RESOURCES
WHERE RT_OPER_RESOURCE_ID= c_rt_oper_resource_id;

CURSOR get_alt_res_rt_oper_ids(c_aso_resource_id number)
IS
select RT_OPER_RESOURCE_ID
from ahl_alternate_resources
where ASO_RESOURCE_ID= c_aso_resource_id;

l_aso_res_id                NUMBER;
l_alt_res_rt_oper_id        NUMBER;
l_dummy                     VARCHAR2(1);
l_object_id                 NUMBER;
l_association_type_code     VARCHAR2(30);
l_rt_oper_res_id            NUMBER;

--pdoki ER 7436910 End.

l_dummy_num           NUMBER;

BEGIN

  OPEN get_bom_res_num (p_aso_resource_id);
  FETCH get_bom_res_num INTO l_dummy_num;
  IF l_dummy_num < 1 THEN
    CLOSE get_bom_res_num;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_BOM_RES_COUNT_ZERO' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_bom_res_num;

  OPEN get_bom_res_org (p_aso_resource_id);
  FETCH get_bom_res_org INTO l_dummy_num;
  IF get_bom_res_org%FOUND THEN
    CLOSE get_bom_res_org;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MUL_BOM_RES_PER_ORG' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_bom_res_org;

  OPEN get_bom_res_dup (p_aso_resource_id);
  FETCH get_bom_res_dup INTO l_dummy_num;
  IF get_bom_res_dup%FOUND THEN
    CLOSE get_bom_res_dup;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_BOM_RESOURCE_DUP' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_bom_res_dup;

  --pdoki ER 7436910 Begin.
  OPEN  get_rt_oper_res_obj( p_aso_resource_id );

  LOOP
    FETCH get_rt_oper_res_obj INTO
      l_object_id,
      l_association_type_code;

    EXIT WHEN get_rt_oper_res_obj%NOTFOUND;

    --checking dept conflicts among primary resources
    OPEN get_dept_conflicts( l_object_id, l_association_type_code );
    FETCH get_dept_conflicts INTO l_dummy;
    IF ( get_dept_conflicts%FOUND ) THEN
        CLOSE get_dept_conflicts;
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_UPD_RES_CONFLICT' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_dept_conflicts;

    --checking dept conflicts b/w the primary resource and alt resources of OTHER primary resources
    OPEN  get_rt_oper_res_ids( l_object_id, l_association_type_code );

    LOOP
        FETCH get_rt_oper_res_ids INTO l_rt_oper_res_id;
        EXIT WHEN get_rt_oper_res_ids%NOTFOUND;
        OPEN get_dept_conflicts_alt_res( l_object_id, l_association_type_code, l_rt_oper_res_id);
        FETCH get_dept_conflicts_alt_res INTO l_dummy;
        IF ( get_dept_conflicts_alt_res%FOUND ) THEN
            CLOSE get_dept_conflicts_alt_res;
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_UPD_RES_CONFLICT' );
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE get_dept_conflicts_alt_res;
    END LOOP;
    CLOSE get_rt_oper_res_ids;

  END LOOP;

  CLOSE get_rt_oper_res_obj;

--checks for conflicts b/w the alternate resource and other primary resources. here the resource is an alternate resource(in alternate_resources table)
OPEN get_alt_res_rt_oper_ids(p_aso_resource_id);
LOOP
    FETCH get_alt_res_rt_oper_ids INTO l_alt_res_rt_oper_id;
    EXIT WHEN get_alt_res_rt_oper_ids%NOTFOUND;

    OPEN  get_rt_oper_res_det( l_alt_res_rt_oper_id );
    FETCH get_rt_oper_res_det INTO
      l_object_id,
      l_association_type_code,
      l_aso_res_id;
    CLOSE get_rt_oper_res_det;

    OPEN get_dept_conflicts_alt_pri( l_object_id, l_association_type_code, l_aso_res_id, p_aso_resource_id);
    FETCH get_dept_conflicts_alt_pri INTO l_dummy;
    IF ( get_dept_conflicts_alt_pri%FOUND ) THEN
        CLOSE get_dept_conflicts_alt_pri;
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_UPD_RES_CONFLICT' );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_dept_conflicts_alt_pri;

END LOOP;
CLOSE get_alt_res_rt_oper_ids;
--pdoki ER 7436910 End.

END validate_bom_records;

PROCEDURE process_aso_resource
(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN            VARCHAR2   := NULL,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_aso_resource_rec IN OUT NOCOPY aso_resource_rec_type,
  p_x_bom_resource_tbl IN OUT NOCOPY bom_resource_tbl_type
)
IS
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_resource_id               NUMBER;
l_resource_mapping_id       NUMBER;

CURSOR check_aso_resource_used(c_resource_id NUMBER) IS
  SELECT aso_resource_id
    FROM ahl_rt_oper_resources
   WHERE aso_resource_id = c_resource_id;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_aso_resource_pvt;

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

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' : Begin API' );
  END IF;

    -- Validate all the inputs of the API
  validate_api_inputs
  (
    p_aso_resource_rec => p_x_aso_resource_rec,
    p_bom_resource_tbl => p_x_bom_resource_tbl
  );

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_api_inputs' );
  END IF;

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    clear_lov_attribute_ids
    (
      p_x_aso_resource_rec => p_x_aso_resource_rec,
      p_x_bom_resource_tbl => p_x_bom_resource_tbl
    );
  END IF;

  -- Convert Values into Ids.
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    convert_values_to_ids
    (
      p_x_aso_resource_rec => p_x_aso_resource_rec,
      p_x_bom_resource_tbl => p_x_bom_resource_tbl
    );
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after convert_values_to_ids' );
  END IF;

  -- Default aso_resource attributes.
  IF FND_API.to_boolean( p_default ) THEN
    IF ( p_x_aso_resource_rec.dml_operation <> 'D' ) THEN
      default_attributes
      (
        p_x_aso_resource_rec,
        p_x_bom_resource_tbl
      );
    END IF;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    validate_attributes
    (
      p_x_aso_resource_rec,
      p_x_bom_resource_tbl
    );
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  IF ( p_x_aso_resource_rec.dml_operation = 'C' ) THEN
    default_miss_aso_attributes( p_x_aso_resource_rec );
    IF p_x_bom_resource_tbl.count > 0 THEN
    FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
      default_miss_bom_attributes( p_x_bom_resource_tbl(i) );
    END LOOP;
    END IF;
  ELSIF ( p_x_aso_resource_rec.dml_operation = 'U' ) THEN
    default_unc_aso_attributes( p_x_aso_resource_rec);
    IF p_x_bom_resource_tbl.count > 0 THEN
    FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
      IF p_x_bom_resource_tbl(i).dml_operation = 'C' THEN
        default_miss_bom_attributes( p_x_bom_resource_tbl(i));
      ELSIF  p_x_bom_resource_tbl(i).dml_operation = 'U' THEN
        default_unc_bom_attributes( p_x_bom_resource_tbl(i));
      END IF;
    END LOOP;
    END IF;
  ELSIF ( p_x_aso_resource_rec.dml_operation IS NULL) THEN
    IF p_x_bom_resource_tbl.count > 0 THEN
    FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
      IF p_x_bom_resource_tbl(i).dml_operation = 'C' THEN
        default_miss_bom_attributes( p_x_bom_resource_tbl(i));
      ELSIF  p_x_bom_resource_tbl(i).dml_operation = 'U' THEN
        default_unc_bom_attributes( p_x_bom_resource_tbl(i));
      END IF;
    END LOOP;
    END IF;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Validate records (Across records validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    IF p_x_bom_resource_tbl.count > 0 THEN
      validate_bom_record
      (
        p_x_aso_resource_rec,
        p_x_bom_resource_tbl
      );
    END IF;
    validate_aso_records
    (
      p_x_aso_resource_rec
    );
    validate_records
    (
      p_x_aso_resource_rec,
      p_x_bom_resource_tbl
    );
   END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_records' );
  END IF;

  -- Perform the DML statement directly.
  IF ( p_x_aso_resource_rec.dml_operation = 'C' ) THEN
    -- Insert the record into the master table AHL_RESOURCES
    INSERT INTO AHL_RESOURCES
    (
          RESOURCE_ID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          RESOURCE_TYPE_ID,
          NAME,
          DESCRIPTION,
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
          ahl_resources_s.nextval,
          p_x_aso_resource_rec.object_version_number,
          p_x_aso_resource_rec.last_update_date,
          p_x_aso_resource_rec.last_updated_by,
          p_x_aso_resource_rec.creation_date,
          p_x_aso_resource_rec.created_by,
          p_x_aso_resource_rec.last_update_login,
          p_x_aso_resource_rec.resource_type_id,
          p_x_aso_resource_rec.name,
          p_x_aso_resource_rec.description,
          p_x_aso_resource_rec.attribute_category,
          p_x_aso_resource_rec.attribute1,
          p_x_aso_resource_rec.attribute2,
          p_x_aso_resource_rec.attribute3,
          p_x_aso_resource_rec.attribute4,
          p_x_aso_resource_rec.attribute5,
          p_x_aso_resource_rec.attribute6,
          p_x_aso_resource_rec.attribute7,
          p_x_aso_resource_rec.attribute8,
          p_x_aso_resource_rec.attribute9,
          p_x_aso_resource_rec.attribute10,
          p_x_aso_resource_rec.attribute11,
          p_x_aso_resource_rec.attribute12,
          p_x_aso_resource_rec.attribute13,
          p_x_aso_resource_rec.attribute14,
          p_x_aso_resource_rec.attribute15
    ) RETURNING resource_id INTO l_resource_id;

    -- Set OUT values
    p_x_aso_resource_rec.resource_id := l_resource_id;

    -- Insert the records into the details table AHL_RESOURCE_MAPPINGS
    FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
      INSERT INTO AHL_RESOURCE_MAPPINGS
      (
          RESOURCE_MAPPING_ID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ASO_RESOURCE_ID,
          BOM_RESOURCE_ID,
          BOM_ORG_ID,
          DEPARTMENT_ID,--pdoki ER 7436910
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
          AHL_RESOURCE_MAPPINGS_S.NEXTVAL,
          p_x_bom_resource_tbl(i).object_version_number,
          p_x_bom_resource_tbl(i).last_update_date,
          p_x_bom_resource_tbl(i).last_updated_by,
          p_x_bom_resource_tbl(i).creation_date,
          p_x_bom_resource_tbl(i).created_by,
          p_x_bom_resource_tbl(i).last_update_login,
          p_x_aso_resource_rec.resource_id,
          p_x_bom_resource_tbl(i).bom_resource_id,
          p_x_bom_resource_tbl(i).bom_org_id,
          p_x_bom_resource_tbl(i).department_id,--pdoki ER 7436910
          p_x_bom_resource_tbl(i).attribute_category,
          p_x_bom_resource_tbl(i).attribute1,
          p_x_bom_resource_tbl(i).attribute2,
          p_x_bom_resource_tbl(i).attribute3,
          p_x_bom_resource_tbl(i).attribute4,
          p_x_bom_resource_tbl(i).attribute5,
          p_x_bom_resource_tbl(i).attribute6,
          p_x_bom_resource_tbl(i).attribute7,
          p_x_bom_resource_tbl(i).attribute8,
          p_x_bom_resource_tbl(i).attribute9,
          p_x_bom_resource_tbl(i).attribute10,
          p_x_bom_resource_tbl(i).attribute11,
          p_x_bom_resource_tbl(i).attribute12,
          p_x_bom_resource_tbl(i).attribute13,
          p_x_bom_resource_tbl(i).attribute14,
          p_x_bom_resource_tbl(i).attribute15
      ) RETURNING resource_mapping_id INTO l_resource_mapping_id;
      p_x_bom_resource_tbl(i).resource_mapping_id := l_resource_mapping_id;
    END LOOP;

  ELSIF ( p_x_aso_resource_rec.dml_operation = 'U' OR p_x_aso_resource_rec.dml_operation IS NULL) THEN
      -- Update the record
    UPDATE AHL_RESOURCES SET
          object_version_number   = object_version_number + 1,
          last_update_date        = p_x_aso_resource_rec.last_update_date,
          last_updated_by         = p_x_aso_resource_rec.last_updated_by,
          last_update_login       = p_x_aso_resource_rec.last_update_login,
          name                    = p_x_aso_resource_rec.name,
          description             = p_x_aso_resource_rec.description,
          attribute_category      = p_x_aso_resource_rec.attribute_category,
          attribute1              = p_x_aso_resource_rec.attribute1,
          attribute2              = p_x_aso_resource_rec.attribute2,
          attribute3              = p_x_aso_resource_rec.attribute3,
          attribute4              = p_x_aso_resource_rec.attribute4,
          attribute5              = p_x_aso_resource_rec.attribute5,
          attribute6              = p_x_aso_resource_rec.attribute6,
          attribute7              = p_x_aso_resource_rec.attribute7,
          attribute8              = p_x_aso_resource_rec.attribute8,
          attribute9              = p_x_aso_resource_rec.attribute9,
          attribute10             = p_x_aso_resource_rec.attribute10,
          attribute11             = p_x_aso_resource_rec.attribute11,
          attribute12             = p_x_aso_resource_rec.attribute12,
          attribute13             = p_x_aso_resource_rec.attribute13,
          attribute14             = p_x_aso_resource_rec.attribute14,
          attribute15             = p_x_aso_resource_rec.attribute15
    WHERE resource_id = p_x_aso_resource_rec.resource_id
    AND object_version_number = p_x_aso_resource_rec.object_version_number;

      -- If the record does not exist, then, abort API.
    IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
        FND_MSG_PUB.add;
    ELSE
    -- Update(Insert or Delete) the records in details table
        IF p_x_bom_resource_tbl.count > 0 THEN
        FOR i IN p_x_bom_resource_tbl.FIRST..p_x_bom_resource_tbl.LAST LOOP
          IF p_x_bom_resource_tbl(i).dml_operation = 'C' THEN
            INSERT INTO AHL_RESOURCE_MAPPINGS(
            RESOURCE_MAPPING_ID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            ASO_RESOURCE_ID,
            BOM_RESOURCE_ID,
            BOM_ORG_ID,
            DEPARTMENT_ID,--pdoki ER 7436910
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
            ATTRIBUTE15)
            VALUES(
            AHL_RESOURCE_MAPPINGS_S.NEXTVAL,
            p_x_bom_resource_tbl(i).object_version_number,
            p_x_bom_resource_tbl(i).last_update_date,
            p_x_bom_resource_tbl(i).last_updated_by,
            p_x_bom_resource_tbl(i).creation_date,
            p_x_bom_resource_tbl(i).created_by,
            p_x_bom_resource_tbl(i).last_update_login,
            p_x_aso_resource_rec.resource_id,
            p_x_bom_resource_tbl(i).bom_resource_id,
            p_x_bom_resource_tbl(i).bom_org_id,
            p_x_bom_resource_tbl(i).department_id,--pdoki ER 7436910
            p_x_bom_resource_tbl(i).attribute_category,
            p_x_bom_resource_tbl(i).attribute1,
            p_x_bom_resource_tbl(i).attribute2,
            p_x_bom_resource_tbl(i).attribute3,
            p_x_bom_resource_tbl(i).attribute4,
            p_x_bom_resource_tbl(i).attribute5,
            p_x_bom_resource_tbl(i).attribute6,
            p_x_bom_resource_tbl(i).attribute7,
            p_x_bom_resource_tbl(i).attribute8,
            p_x_bom_resource_tbl(i).attribute9,
            p_x_bom_resource_tbl(i).attribute10,
            p_x_bom_resource_tbl(i).attribute11,
            p_x_bom_resource_tbl(i).attribute12,
            p_x_bom_resource_tbl(i).attribute13,
            p_x_bom_resource_tbl(i).attribute14,
            p_x_bom_resource_tbl(i).attribute15)
            RETURNING resource_mapping_id INTO l_resource_mapping_id;
            p_x_bom_resource_tbl(i).resource_mapping_id := l_resource_mapping_id;
          ELSIF p_x_bom_resource_tbl(i).dml_operation = 'U' THEN
            UPDATE AHL_RESOURCE_MAPPINGS SET
            object_version_number   = object_version_number + 1,
            last_update_date        = p_x_bom_resource_tbl(i).last_update_date,
            last_updated_by         = p_x_bom_resource_tbl(i).last_updated_by,
            last_update_login       = p_x_bom_resource_tbl(i).last_update_login,
            bom_resource_id         = p_x_bom_resource_tbl(i).bom_resource_id,
            bom_org_id              = p_x_bom_resource_tbl(i).bom_org_id,
            department_id           = p_x_bom_resource_tbl(i).department_id,--pdoki ER 7436910
            attribute_category      = p_x_bom_resource_tbl(i).attribute_category,
            attribute1              = p_x_bom_resource_tbl(i).attribute1,
            attribute2              = p_x_bom_resource_tbl(i).attribute2,
            attribute3              = p_x_bom_resource_tbl(i).attribute3,
            attribute4              = p_x_bom_resource_tbl(i).attribute4,
            attribute5              = p_x_bom_resource_tbl(i).attribute5,
            attribute6              = p_x_bom_resource_tbl(i).attribute6,
            attribute7              = p_x_bom_resource_tbl(i).attribute7,
            attribute8              = p_x_bom_resource_tbl(i).attribute8,
            attribute9              = p_x_bom_resource_tbl(i).attribute9,
            attribute10             = p_x_bom_resource_tbl(i).attribute10,
            attribute11             = p_x_bom_resource_tbl(i).attribute11,
            attribute12             = p_x_bom_resource_tbl(i).attribute12,
            attribute13             = p_x_bom_resource_tbl(i).attribute13,
            attribute14             = p_x_bom_resource_tbl(i).attribute14,
            attribute15             = p_x_bom_resource_tbl(i).attribute15
            WHERE resource_mapping_id = p_x_bom_resource_tbl(i).resource_mapping_id
            AND object_version_number = p_x_bom_resource_tbl(i).object_version_number;
            IF ( SQL%ROWCOUNT = 0 ) THEN
              FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
              FND_MSG_PUB.add;
            ELSE
              p_x_bom_resource_tbl(i).object_version_number := p_x_bom_resource_tbl(i).object_version_number+1;
            END IF;
          ELSIF p_x_bom_resource_tbl(i).dml_operation = 'D' THEN
            DELETE FROM AHL_RESOURCE_MAPPINGS
            WHERE resource_mapping_id = p_x_bom_resource_tbl(i).resource_mapping_id
            AND object_version_number = p_x_bom_resource_tbl(i).object_version_number;
            IF ( SQL%ROWCOUNT = 0 ) THEN
              FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
              FND_MSG_PUB.add;
            END IF;
          END IF;
        END LOOP;
      END IF;

      -- Set OUT values
      p_x_aso_resource_rec.object_version_number := p_x_aso_resource_rec.object_version_number + 1;
    END IF;

  ELSIF ( p_x_aso_resource_rec.dml_operation = 'D' ) THEN
    -- Before deleting the record, check whether it is used in the resources of
    -- a route or an operation
      OPEN check_aso_resource_used(p_x_aso_resource_rec.resource_id);
      FETCH check_aso_resource_used INTO l_resource_id;
      IF check_aso_resource_used%FOUND THEN
        CLOSE check_aso_resource_used;
        FND_MESSAGE.set_name('AHL','AHL_RM_ASO_RES_BEING_USED');
        FND_MSG_PUB.add;
      ELSE
        CLOSE check_aso_resource_used;
      /*
      DELETE FROM AHL_RESOURCE_SKILLS
      WHERE AHL_RESOURCE_ID = p_x_aso_resource_rec.resource_id;
      */
        DELETE FROM AHL_RESOURCES
        WHERE resource_id = p_x_aso_resource_rec.resource_id
        AND object_version_number = p_x_aso_resource_rec.object_version_number;

      -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MSG_PUB.add;
       -- Delete the detailed records in ahl_resource_skills
        ELSE
          DELETE FROM AHL_RESOURCE_MAPPINGS
          WHERE aso_resource_id = p_x_aso_resource_rec.resource_id;
        END IF;
      END IF;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after DML operation' );
  END IF;

  -- Perform the cross records validation after DML operation
  IF p_x_aso_resource_rec.DML_OPERATION <> 'D' THEN
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  just before validate_bom_records.' );
    END IF;
    validate_bom_records (p_x_aso_resource_rec.RESOURCE_ID);
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  The last cross records validation was processed after DML operation' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
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
    ROLLBACK TO PROCESS_ASO_RESOURCE_PVT;
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
    ROLLBACK TO process_aso_resource_PVT;
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
    ROLLBACK TO process_aso_resource_PVT;
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
    IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END process_aso_resource;

END AHL_RM_ASO_RESOURCE_PVT;

/
