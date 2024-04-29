--------------------------------------------------------
--  DDL for Package Body AHL_RM_PROD_ZONE_AS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_PROD_ZONE_AS_PVT" AS
/* $Header: AHLVAPMB.pls 115.31 2004/05/19 16:16:50 bachandr noship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_PROD_ZONE_AS_PVT';
G_API_NAME VARCHAR2(30) := 'PROCESS_PROD_ZONE_AS';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_prod_zone_as_rec       IN    prod_zone_as_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN

    IF ( p_prod_zone_as_rec.product_type IS NOT NULL AND
         p_prod_zone_as_rec.product_type <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_prod_zone_as_rec.product_type;
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_prod_zone_as_rec.zone IS NOT NULL AND
         p_prod_zone_as_rec.zone <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_prod_zone_as_rec.zone;
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_prod_zone_as_rec.sub_zone IS NOT NULL AND
         p_prod_zone_as_rec.sub_zone <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_prod_zone_as_rec.sub_zone;
    END IF;

    RETURN l_record_identifier;

END get_record_identifier;

-- Procedure to validate the all the inputs except the table structure of the API
PROCEDURE validate_api_inputs
(
  p_prod_zone_as_tbl        IN   prod_zone_as_tbl_type,
  p_associate_flag          IN   VARCHAR2,
  x_return_status           OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check whether the associate type is 'M' or 'S'
  IF ( p_associate_flag <> 'M' AND p_associate_flag <> 'S') THEn
    FND_MESSAGE.set_name('AHL', 'AHL_RM_INVALID_ASSOCIATE_TYPE');
    FND_MESSAGE.set_token('FIELD', p_associate_flag );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if at least one record is passed in p_prod_zone_as_tbl
  IF ( p_prod_zone_as_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_prod_zone_as_tbl.count LOOP
    IF ( p_prod_zone_as_tbl(i).dml_operation <> 'C' AND
         p_prod_zone_as_tbl(i).dml_operation <> 'U' AND
         p_prod_zone_as_tbl(i).dml_operation <> 'D' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_prod_zone_as_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_prod_zone_as_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_prod_zone_as_rec       IN OUT NOCOPY  prod_zone_as_rec_type
)
IS

BEGIN
  IF ( p_x_prod_zone_as_rec.product_type IS NULL ) THEN
    p_x_prod_zone_as_rec.product_type_code := NULL;
  ELSIF ( p_x_prod_zone_as_rec.product_type = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.product_type_code := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_prod_zone_as_rec.zone IS NULL ) THEN
    p_x_prod_zone_as_rec.zone_code := NULL;
  ELSIF ( p_x_prod_zone_as_rec.zone = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.zone_code := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_prod_zone_as_rec.sub_zone IS NULL ) THEN
    p_x_prod_zone_as_rec.sub_zone_code := NULL;
  ELSIF ( p_x_prod_zone_as_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.sub_zone_code := FND_API.G_MISS_CHAR;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion and validation for LOV attributes
PROCEDURE convert_values_to_ids
(
  p_x_prod_zone_as_rec  IN OUT NOCOPY  prod_zone_as_rec_type,
  x_return_status       OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate product type
  IF ( ( p_x_prod_zone_as_rec.product_type_code IS NOT NULL AND
         p_x_prod_zone_as_rec.product_type_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_prod_zone_as_rec.product_type IS NOT NULL AND
         p_x_prod_zone_as_rec.product_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      p_lookup_type         => 'ITEM_TYPE',
      p_lookup_meaning      => p_x_prod_zone_as_rec.product_type,
      p_x_lookup_code       => p_x_prod_zone_as_rec.product_type_code,
      x_msg_data            => l_msg_data,
      x_return_status       => l_return_status
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PRODUCT_TYPE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_PRODUCT_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_prod_zone_as_rec.product_type IS NULL OR
           p_x_prod_zone_as_rec.product_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_prod_zone_as_rec.product_type_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_prod_zone_as_rec.product_type );
      END IF;

      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

  -- Convert / Validate zone
  IF ( ( p_x_prod_zone_as_rec.zone_code IS NOT NULL AND
         p_x_prod_zone_as_rec.zone_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_prod_zone_as_rec.zone IS NOT NULL AND
         p_x_prod_zone_as_rec.zone <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      p_lookup_type            =>'AHL_ZONE',
      p_lookup_meaning         => p_x_prod_zone_as_rec.zone,
      p_x_lookup_code          => p_x_prod_zone_as_rec.zone_code,
      x_msg_data               => l_msg_data,
      x_return_status          => l_return_status
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ZONE_REC' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_ZONES_REC' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_prod_zone_as_rec.zone IS NULL OR
           p_x_prod_zone_as_rec.zone = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_prod_zone_as_rec.zone_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_prod_zone_as_rec.zone );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_prod_zone_as_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

  -- Convert / Validate sub zone
  IF ( ( p_x_prod_zone_as_rec.sub_zone_code IS NOT NULL AND
         p_x_prod_zone_as_rec.sub_zone_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_prod_zone_as_rec.sub_zone IS NOT NULL AND
         p_x_prod_zone_as_rec.sub_zone <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      p_lookup_type             => 'AHL_SUB_ZONE',
      p_lookup_meaning          => p_x_prod_zone_as_rec.sub_zone,
      p_x_lookup_code           => p_x_prod_zone_as_rec.sub_zone_code,
      x_msg_data                => l_msg_data,
      x_return_status           => l_return_status
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_SUB_ZONE_REC' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_SUB_ZONES_REC' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_prod_zone_as_rec.sub_zone IS NULL OR
           p_x_prod_zone_as_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_prod_zone_as_rec.sub_zone_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_prod_zone_as_rec.sub_zone );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_prod_zone_as_rec ) );
      FND_MSG_PUB.add;
      x_return_status := l_return_status;
    END IF;

  END IF;

END convert_values_to_ids;

-- Procedure to add Default values for prod_zone_as attributes
PROCEDURE default_attributes
(
  p_x_prod_zone_as_rec       IN OUT NOCOPY   prod_zone_as_rec_type
)
IS

BEGIN

  p_x_prod_zone_as_rec.last_update_date := SYSDATE;
  p_x_prod_zone_as_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_prod_zone_as_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_prod_zone_as_rec.dml_operation = 'C' ) THEN
    p_x_prod_zone_as_rec.object_version_number := 1;
    p_x_prod_zone_as_rec.creation_date := SYSDATE;
    p_x_prod_zone_as_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_attributes;

 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_prod_zone_as_rec       IN OUT NOCOPY   prod_zone_as_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_prod_zone_as_rec.product_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.product_type_code := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.product_type = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.product_type := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.zone_code := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.zone = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.zone := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.sub_zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.sub_zone_code := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.sub_zone := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute_category := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute1 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute2 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute3 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute4 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute5 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute6 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute7 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute8 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute9 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute10 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute11 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute12 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute13 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute14 := null;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute15 := null;
  END IF;

END default_missing_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_prod_zone_as_rec       IN OUT NOCOPY   prod_zone_as_rec_type
)
IS

l_old_prod_zone_as_rec       prod_zone_as_rec_type;

CURSOR get_old_rec ( c_prodtype_zone_id NUMBER )
IS
SELECT  product_type_code,
        zone_code,
        sub_zone_code,
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
FROM    AHL_PRODTYPE_ZONES
WHERE   prodtype_zone_id = c_prodtype_zone_id;

BEGIN

  -- Get the old record from AHL_RT_OPER_RESOURCES.
  OPEN  get_old_rec( p_x_prod_zone_as_rec.prodtype_zone_id );

  FETCH get_old_rec INTO
        l_old_prod_zone_as_rec.product_type_code,
        l_old_prod_zone_as_rec.zone_code,
        l_old_prod_zone_as_rec.sub_zone_code,
        l_old_prod_zone_as_rec.attribute_category,
        l_old_prod_zone_as_rec.attribute1,
        l_old_prod_zone_as_rec.attribute2,
        l_old_prod_zone_as_rec.attribute3,
        l_old_prod_zone_as_rec.attribute4,
        l_old_prod_zone_as_rec.attribute5,
        l_old_prod_zone_as_rec.attribute6,
        l_old_prod_zone_as_rec.attribute7,
        l_old_prod_zone_as_rec.attribute8,
        l_old_prod_zone_as_rec.attribute9,
        l_old_prod_zone_as_rec.attribute10,
        l_old_prod_zone_as_rec.attribute11,
        l_old_prod_zone_as_rec.attribute12,
        l_old_prod_zone_as_rec.attribute13,
        l_old_prod_zone_as_rec.attribute14,
        l_old_prod_zone_as_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PROD_ZONE_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_prod_zone_as_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_prod_zone_as_rec.product_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.product_type_code := null;
  ELSIF ( p_x_prod_zone_as_rec.product_type_code IS NULL ) THEN
    p_x_prod_zone_as_rec.product_type_code := l_old_prod_zone_as_rec.product_type_code;
  END IF;

  IF ( p_x_prod_zone_as_rec.product_type = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.product_type := null;
  ELSIF ( p_x_prod_zone_as_rec.product_type IS NULL ) THEN
    p_x_prod_zone_as_rec.product_type := l_old_prod_zone_as_rec.product_type;
  END IF;

  IF ( p_x_prod_zone_as_rec.zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.zone_code := null;
  ELSIF ( p_x_prod_zone_as_rec.zone_code IS NULL ) THEN
    p_x_prod_zone_as_rec.zone_code := l_old_prod_zone_as_rec.zone_code;
  END IF;

  IF ( p_x_prod_zone_as_rec.zone = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.zone := null;
  ELSIF ( p_x_prod_zone_as_rec.zone IS NULL ) THEN
    p_x_prod_zone_as_rec.zone := l_old_prod_zone_as_rec.zone;
  END IF;

  IF ( p_x_prod_zone_as_rec.sub_zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.sub_zone_code := null;
  ELSIF ( p_x_prod_zone_as_rec.sub_zone_code IS NULL ) THEN
    p_x_prod_zone_as_rec.sub_zone_code := l_old_prod_zone_as_rec.sub_zone_code;
  END IF;

  IF ( p_x_prod_zone_as_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.sub_zone := null;
  ELSIF ( p_x_prod_zone_as_rec.sub_zone IS NULL ) THEN
    p_x_prod_zone_as_rec.sub_zone := l_old_prod_zone_as_rec.sub_zone;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute_category := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute_category IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute_category := l_old_prod_zone_as_rec.attribute_category;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute1 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute1 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute1 := l_old_prod_zone_as_rec.attribute1;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute2 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute2 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute2 := l_old_prod_zone_as_rec.attribute2;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute3 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute3 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute3 := l_old_prod_zone_as_rec.attribute3;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute4 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute4 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute4 := l_old_prod_zone_as_rec.attribute4;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute5 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute5 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute5 := l_old_prod_zone_as_rec.attribute5;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute6 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute6 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute6 := l_old_prod_zone_as_rec.attribute6;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute7 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute7 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute7 := l_old_prod_zone_as_rec.attribute7;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute8 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute8 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute8 := l_old_prod_zone_as_rec.attribute8;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute9 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute9 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute9 := l_old_prod_zone_as_rec.attribute9;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute10 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute10 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute10 := l_old_prod_zone_as_rec.attribute10;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute11 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute11 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute11 := l_old_prod_zone_as_rec.attribute11;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute12 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute12 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute12 := l_old_prod_zone_as_rec.attribute12;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute13 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute13 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute13 := l_old_prod_zone_as_rec.attribute13;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute14 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute14 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute14 := l_old_prod_zone_as_rec.attribute14;
  END IF;

  IF ( p_x_prod_zone_as_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_prod_zone_as_rec.attribute15 := null;
  ELSIF ( p_x_prod_zone_as_rec.attribute15 IS NULL ) THEN
    p_x_prod_zone_as_rec.attribute15 := l_old_prod_zone_as_rec.attribute15;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual prod_zone_as attributes
PROCEDURE validate_attributes
(
  p_prod_zone_as_rec      IN    prod_zone_as_rec_type,
  p_associate_flag        IN    VARCHAR2,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_prod_zone_as_rec.product_type_code IS NULL OR
    p_prod_zone_as_rec.product_type_code = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_PRODUCT_TYPE_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF ( p_prod_zone_as_rec.zone_code IS NULL OR
    p_prod_zone_as_rec.zone_code = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ZONE_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_prod_zone_as_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF ( p_associate_flag = 'S' AND ( p_prod_zone_as_rec.sub_zone_code IS NULL OR
       p_prod_zone_as_rec.sub_zone_code = FND_API.G_MISS_CHAR )) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_SUB_ZONE_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_prod_zone_as_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF ( p_prod_zone_as_rec.dml_operation = 'U') THEN
  -- Check if the mandatory Object Version Number column contains a null value.
    IF ( p_prod_zone_as_rec.object_version_number IS NULL OR
       p_prod_zone_as_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_PTZ_OBJ_VERSION_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_prod_zone_as_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

  -- Check if the mandatory prod_zone_as ID column contains a null value.
    IF ( p_prod_zone_as_rec.prodtype_zone_id IS NULL OR
       p_prod_zone_as_rec.prodtype_zone_id = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_PRODTYPE_ZONE_ID_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_prod_zone_as_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

  END IF;

END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_record
(
  p_prod_zone_as_rec  IN    prod_zone_as_rec_type,
  p_associate_flag    IN    VARCHAR2,
  x_return_status     OUT NOCOPY   VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);
CURSOR get_zone_assoc (c_product_type_code VARCHAR2, c_zone_code VARCHAR2) IS
  SELECT product_type_code, zone_code
    FROM ahl_prodtype_zones
   WHERE product_type_code = c_product_type_code
     AND zone_code = c_zone_code;
l_zone_assoc              get_zone_assoc%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_associate_flag = 'S') THEN
    OPEN get_zone_assoc(p_prod_zone_as_rec.product_type_code, p_prod_zone_as_rec.zone_code);
    FETCH get_zone_assoc INTO l_zone_assoc;
    IF get_zone_assoc%NOTFOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_NO_PRODTYPE_ZONE_AS' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_prod_zone_as_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE get_zone_assoc;
  END IF;

END validate_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_product_type_code     IN    VARCHAR2,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

CURSOR get_dup_rec ( c_product_type_code VARCHAR2 )
IS
SELECT   zone_code,
         zone,
         sub_zone_code,
         sub_zone
FROM     AHL_PRODTYPE_ZONES_V
WHERE    product_type_code = c_product_type_code
GROUP BY zone_code,
         zone,
         sub_zone_code,
         sub_zone
HAVING   count(*) > 1;

l_prod_zone_as_rec      prod_zone_as_rec_type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check whether any duplicate prod_zone_as records for the given object_ID
  OPEN  get_dup_rec( p_product_type_code );

  LOOP
    FETCH get_dup_rec INTO
      l_prod_zone_as_rec.zone_code,
      l_prod_zone_as_rec.zone,
      l_prod_zone_as_rec.sub_zone_code,
      l_prod_zone_as_rec.sub_zone;
    EXIT WHEN get_dup_rec%NOTFOUND;
  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_PRODTYPE_ZONE_DUP' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_prod_zone_as_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

END validate_records;

PROCEDURE process_prod_zone_as
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
  p_associate_flag     IN            VARCHAR2,
  p_x_prod_zone_as_tbl IN OUT NOCOPY prod_zone_as_tbl_type
)
IS
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_prodtype_zone_id          NUMBER;

CURSOR get_prod_zone_rec(c_prodtype_zone_id NUMBER) IS
  SELECT product_type_code, zone_code, sub_zone_code
    FROM ahl_prodtype_zones
   WHERE prodtype_zone_id = c_prodtype_zone_id;

CURSOR get_route_zone_rec(c_product_type_code VARCHAR2, c_zone_code VARCHAR2) IS
  SELECT route_id
    FROM ahl_routes_app_v
   WHERE product_type_code = c_product_type_code
     AND zone_code = c_zone_code;

CURSOR get_route_sub_rec(c_product_type_code VARCHAR2, c_zone_code VARCHAR2,
                            c_sub_zone_code VARCHAR2 ) IS
  SELECT route_id
    FROM ahl_routes_app_v
   WHERE product_type_code = c_product_type_code
     AND zone_code = c_zone_code
     AND sub_zone_code = c_sub_zone_code;

l_get_prod_zone_rec          get_prod_zone_rec%ROWTYPE;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_prod_zone_as_pvt;

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
    p_x_prod_zone_as_tbl,
    p_associate_flag,
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
    FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
      IF ( p_x_prod_zone_as_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_prod_zone_as_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
      IF ( p_x_prod_zone_as_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_prod_zone_as_tbl(i) , -- IN OUT Record with Values and Ids
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

  -- Default prod_zone_as attributes.
  IF FND_API.to_boolean( p_default ) THEN
    FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
      IF ( p_x_prod_zone_as_tbl(i).dml_operation <> 'D' ) THEN
        default_attributes
        (
          p_x_prod_zone_as_tbl(i) -- IN OUT
        );
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
      IF p_x_prod_zone_as_tbl(i).dml_operation <> 'D' THEN
        validate_attributes
        (
          p_x_prod_zone_as_tbl(i), -- IN
          p_associate_flag,
          l_return_status -- OUT
        );
      END IF;
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
  FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
    IF ( p_x_prod_zone_as_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_prod_zone_as_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_prod_zone_as_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_prod_zone_as_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)

  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
      IF ( p_x_prod_zone_as_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_x_prod_zone_as_tbl(i), -- IN
          p_associate_flag,        -- IN
          l_return_status          -- OUT
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
  FOR i IN 1..p_x_prod_zone_as_tbl.count LOOP
    IF ( p_x_prod_zone_as_tbl(i).dml_operation = 'C' ) THEN
      BEGIN
        -- Insert the record
        INSERT INTO AHL_PRODTYPE_ZONES
        (
          PRODTYPE_ZONE_ID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          PRODUCT_TYPE_CODE,
          ZONE_CODE,
          SUB_ZONE_CODE,
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
          AHL_PRODTYPE_ZONES_S.NEXTVAL,
          p_x_prod_zone_as_tbl(i).object_version_number,
          p_x_prod_zone_as_tbl(i).last_update_date,
          p_x_prod_zone_as_tbl(i).last_updated_by,
          p_x_prod_zone_as_tbl(i).creation_date,
          p_x_prod_zone_as_tbl(i).created_by,
          p_x_prod_zone_as_tbl(i).last_update_login,
          p_x_prod_zone_as_tbl(i).product_type_code,
          p_x_prod_zone_as_tbl(i).zone_code,
          p_x_prod_zone_as_tbl(i).sub_zone_code,
          p_x_prod_zone_as_tbl(i).attribute_category,
          p_x_prod_zone_as_tbl(i).attribute1,
          p_x_prod_zone_as_tbl(i).attribute2,
          p_x_prod_zone_as_tbl(i).attribute3,
          p_x_prod_zone_as_tbl(i).attribute4,
          p_x_prod_zone_as_tbl(i).attribute5,
          p_x_prod_zone_as_tbl(i).attribute6,
          p_x_prod_zone_as_tbl(i).attribute7,
          p_x_prod_zone_as_tbl(i).attribute8,
          p_x_prod_zone_as_tbl(i).attribute9,
          p_x_prod_zone_as_tbl(i).attribute10,
          p_x_prod_zone_as_tbl(i).attribute11,
          p_x_prod_zone_as_tbl(i).attribute12,
          p_x_prod_zone_as_tbl(i).attribute13,
          p_x_prod_zone_as_tbl(i).attribute14,
          p_x_prod_zone_as_tbl(i).attribute15
        ) RETURNING prodtype_zone_id INTO l_prodtype_zone_id;

        -- Set OUT values
        p_x_prod_zone_as_tbl(i).prodtype_zone_id := l_prodtype_zone_id;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_PRODTYPE_ZONE_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_x_prod_zone_as_tbl(i) ) );
            FND_MSG_PUB.add;
          END IF;
      END;

    ELSIF ( p_x_prod_zone_as_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_PRODTYPE_ZONES SET
          object_version_number   = object_version_number + 1,
          last_update_date        = p_x_prod_zone_as_tbl(i).last_update_date,
          last_updated_by         = p_x_prod_zone_as_tbl(i).last_updated_by,
          last_update_login       = p_x_prod_zone_as_tbl(i).last_update_login,
          product_type_code       = p_x_prod_zone_as_tbl(i).product_type_code,
          zone_code               = p_x_prod_zone_as_tbl(i).zone_code,
          sub_zone_code           = p_x_prod_zone_as_tbl(i).sub_zone_code,
          attribute_category      = p_x_prod_zone_as_tbl(i).attribute_category,
          attribute1              = p_x_prod_zone_as_tbl(i).attribute1,
          attribute2              = p_x_prod_zone_as_tbl(i).attribute2,
          attribute3              = p_x_prod_zone_as_tbl(i).attribute3,
          attribute4              = p_x_prod_zone_as_tbl(i).attribute4,
          attribute5              = p_x_prod_zone_as_tbl(i).attribute5,
          attribute6              = p_x_prod_zone_as_tbl(i).attribute6,
          attribute7              = p_x_prod_zone_as_tbl(i).attribute7,
          attribute8              = p_x_prod_zone_as_tbl(i).attribute8,
          attribute9              = p_x_prod_zone_as_tbl(i).attribute9,
          attribute10             = p_x_prod_zone_as_tbl(i).attribute10,
          attribute11             = p_x_prod_zone_as_tbl(i).attribute11,
          attribute12             = p_x_prod_zone_as_tbl(i).attribute12,
          attribute13             = p_x_prod_zone_as_tbl(i).attribute13,
          attribute14             = p_x_prod_zone_as_tbl(i).attribute14,
          attribute15             = p_x_prod_zone_as_tbl(i).attribute15
        WHERE prodtype_zone_id = p_x_prod_zone_as_tbl(i).prodtype_zone_id
        AND object_version_number = p_x_prod_zone_as_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_prod_zone_as_tbl(i) ) );
          FND_MSG_PUB.add;
        END IF;

        -- Set OUT values
        p_x_prod_zone_as_tbl(i).object_version_number := p_x_prod_zone_as_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_PRODTYPE_ZONE_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_prod_zone_as_tbl(i) ) );
            FND_MSG_PUB.add;
          END IF;
      END;

    ELSIF ( p_x_prod_zone_as_tbl(i).dml_operation = 'D' ) THEN

      OPEN get_prod_zone_rec(p_x_prod_zone_as_tbl(i).prodtype_zone_id);
      FETCH get_prod_zone_rec INTO l_get_prod_zone_rec;
      IF get_prod_zone_rec%NOTFOUND THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_INVALID_PROD_ZONE_REC');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
        CLOSE get_prod_zone_rec;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE get_prod_zone_rec;

      -- Delete the record
      DELETE FROM AHL_PRODTYPE_ZONES
      WHERE prodtype_zone_id = p_x_prod_zone_as_tbl(i).prodtype_zone_id
      AND object_version_number = p_x_prod_zone_as_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
      ELSE
        IF l_get_prod_zone_rec.sub_zone_code IS NULL THEN
          DELETE FROM AHL_PRODTYPE_ZONES
          WHERE product_type_code = l_get_prod_zone_rec.product_type_code
            AND zone_code = l_get_prod_zone_rec.zone_code;
          FOR I IN get_route_zone_rec(l_get_prod_zone_rec.product_type_code,
                                      l_get_prod_zone_rec.zone_code) LOOP
            UPDATE AHL_ROUTES_B
               SET zone_code = NULL,
                   sub_zone_code = NULL
             WHERE route_id = I.route_id;
          END LOOP;
        ELSE
          FOR I IN get_route_sub_rec(l_get_prod_zone_rec.product_type_code,
                   l_get_prod_zone_rec.zone_code, l_get_prod_zone_rec.sub_zone_code ) LOOP
            UPDATE AHL_ROUTES_B
               SET sub_zone_code = NULL
             WHERE route_id= I.route_id;
          END LOOP;
        END IF;
      END IF;

      -- Delete
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
    p_x_prod_zone_as_tbl(p_x_prod_zone_as_tbl.FIRST).product_type_code,
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
  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_prod_zone_as_pvt;
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
    ROLLBACK TO process_prod_zone_as_pvt;
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
    ROLLBACK TO process_prod_zone_as_pvt;
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

END process_prod_zone_as;

END AHL_RM_PROD_ZONE_AS_PVT;

/
