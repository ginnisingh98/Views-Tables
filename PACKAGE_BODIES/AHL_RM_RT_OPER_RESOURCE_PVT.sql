--------------------------------------------------------
--  DDL for Package Body AHL_RM_RT_OPER_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_RT_OPER_RESOURCE_PVT" AS
/* $Header: AHLVRORB.pls 120.2.12010000.3 2008/12/29 14:21:25 bachandr ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_RT_OPER_RESOURCE_PVT';
G_API_NAME1 VARCHAR2(30) := 'PROCESS_RT_OPER_RESOURCE';
G_API_NAME2 VARCHAR2(30) := 'DEFINE_COST_PARAMETER';
G_API_NAME3 VARCHAR2(30) := 'PROCESS_ALTERNATE_RESOURCE';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

-- constants for WHO Columns
-- Added by balaji as a part of Public API cleanup
G_LAST_UPDATE_DATE  DATE    := SYSDATE;
G_LAST_UPDATED_BY   NUMBER(15)  := FND_GLOBAL.user_id;
G_LAST_UPDATE_LOGIN   NUMBER(15)  := FND_GLOBAL.login_id;
G_CREATION_DATE   DATE    := SYSDATE;
G_CREATED_BY    NUMBER(15)  := FND_GLOBAL.user_id;

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_rt_oper_resource_rec       IN    rt_oper_resource_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN

    IF ( p_rt_oper_resource_rec.resource_type IS NOT NULL AND
         p_rt_oper_resource_rec.resource_type <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_rt_oper_resource_rec.resource_type;
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_rt_oper_resource_rec.aso_resource_name IS NOT NULL AND
         p_rt_oper_resource_rec.asO_resource_name <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_rt_oper_resource_rec.aso_resource_name;
    END IF;

    RETURN l_record_identifier;

END get_record_identifier;

-- Procedure to validate the all the inputs except the table structure of the API
PROCEDURE validate_api_inputs
(
  p_rt_oper_resource_tbl    IN   rt_oper_resource_tbl_type,
  p_association_type_code   IN   VARCHAR2,
  p_object_id               IN   NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a valid value is passed in p_association_type_code
  IF ( p_association_type_code = FND_API.G_MISS_CHAR OR
       p_association_type_code IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ASSOC_TYPE_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  ELSIF ( p_association_type_code <> 'OPERATION' AND
          p_association_type_code <> 'ROUTE' ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ASSOC_TYPE_INVALID' );
    FND_MESSAGE.set_token( 'FIELD', p_association_type_code );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if a valid value is passed in p_object_id
  IF (p_association_type_code = 'OPERATION') THEN
    AHL_RM_ROUTE_UTIL.validate_operation_status
    (
       p_operation_id      => p_object_id,
       x_return_status     => l_return_status,
       x_msg_data          => l_msg_data
    );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  ELSIF (p_association_type_code = 'ROUTE') THEN
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
  END IF;

  -- Check if at least one record is passed in p_rt_oper_resource_tbl
  IF ( p_rt_oper_resource_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME1 );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_rt_oper_resource_tbl.count LOOP
    IF ( p_rt_oper_resource_tbl(i).dml_operation IS NULL OR
       (
         p_rt_oper_resource_tbl(i).dml_operation <> 'C' AND
           p_rt_oper_resource_tbl(i).dml_operation <> 'U' AND
           p_rt_oper_resource_tbl(i).dml_operation <> 'D'
         )
       )
    THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_rt_oper_resource_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_rt_oper_resource_rec       IN OUT NOCOPY  rt_oper_resource_rec_type
)
IS

BEGIN
  IF ( p_x_rt_oper_resource_rec.resource_type IS NULL ) THEN
    p_x_rt_oper_resource_rec.resource_type_id := NULL;
  ELSIF ( p_x_rt_oper_resource_rec.resource_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.resource_type_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_rt_oper_resource_rec.aso_resource_name IS NULL ) THEN
    p_x_rt_oper_resource_rec.aso_resource_id := NULL;
  ELSIF ( p_x_rt_oper_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.aso_resource_id := FND_API.G_MISS_NUM;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion and validation for LOV attributes
PROCEDURE convert_values_to_ids
(
  p_x_rt_oper_resource_rec  IN OUT NOCOPY  rt_oper_resource_rec_type,
  x_return_status           OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate resource_type_id
  IF ( ( p_x_rt_oper_resource_rec.resource_type_id IS NOT NULL AND
         p_x_rt_oper_resource_rec.resource_type_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_resource_rec.resource_type IS NOT NULL AND
         p_x_rt_oper_resource_rec.resource_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_mfg_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'BOM_RESOURCE_TYPE',
      p_lookup_meaning         => p_x_rt_oper_resource_rec.resource_type,
      p_x_lookup_code          => p_x_rt_oper_resource_rec.resource_type_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_MFG_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RESOURCE_TYPE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_MFG_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_RESOURCE_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_resource_rec.resource_type IS NULL OR
           p_x_rt_oper_resource_rec.resource_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_resource_rec.resource_type_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_resource_rec.resource_type );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_resource_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate ASO_resource_id
  IF ( ( p_x_rt_oper_resource_rec.aso_resource_id IS NOT NULL AND
         p_x_rt_oper_resource_rec.aso_resource_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_resource_rec.aso_resource_name IS NOT NULL AND
         p_x_rt_oper_resource_rec.aso_resource_name <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_aso_resource
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_aso_resource_name      => p_x_rt_oper_resource_rec.aso_resource_name,
      p_x_aso_resource_id      => p_x_rt_oper_resource_rec.aso_resource_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_rt_oper_resource_rec.aso_resource_name IS NULL OR
           p_x_rt_oper_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_resource_rec.aso_resource_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_resource_rec.aso_resource_name );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_resource_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Added for bug fix 6512803. Honor input scheduled_type_id if passed.
  -- Convert / Validate scheduled_type_id
  IF ( ( p_x_rt_oper_resource_rec.scheduled_type_id IS NOT NULL AND
         p_x_rt_oper_resource_rec.scheduled_type_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_resource_rec.scheduled_type IS NOT NULL AND
         p_x_rt_oper_resource_rec.scheduled_type <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_mfg_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'BOM_RESOURCE_SCHEDULE_TYPE',
      p_lookup_meaning         => p_x_rt_oper_resource_rec.scheduled_type,
      p_x_lookup_code          => p_x_rt_oper_resource_rec.scheduled_type_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_RM_INVALID_MFG_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_SCHEDULE_TYPE' );
      ELSIF ( l_msg_data = 'AHL_RM_TOO_MANY_MFG_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_SCHEDULE_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_resource_rec.scheduled_type IS NULL OR
           p_x_rt_oper_resource_rec.scheduled_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_resource_rec.scheduled_type_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_resource_rec.scheduled_type);
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;
/* Removed as a part of public API cleanup in 11510+.
-- Procedure to add Default values for rt_oper_resource attributes
PROCEDURE default_attributes
(
  p_x_rt_oper_resource_rec       IN OUT NOCOPY   rt_oper_resource_rec_type
)
IS

BEGIN

  p_x_rt_oper_resource_rec.last_update_date := SYSDATE;
  p_x_rt_oper_resource_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_rt_oper_resource_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_rt_oper_resource_rec.dml_operation = 'C' ) THEN
    p_x_rt_oper_resource_rec.object_version_number := 1;
    p_x_rt_oper_resource_rec.creation_date := SYSDATE;
    p_x_rt_oper_resource_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_attributes;
*/
 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_rt_oper_resource_rec       IN OUT NOCOPY   rt_oper_resource_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_rt_oper_resource_rec.resource_type_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.resource_type_id := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.resource_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.resource_type := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.aso_resource_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.aso_resource_id := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.aso_resource_name := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.quantity = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.quantity := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.duration = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.duration := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute_category := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute1 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute2 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute3 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute4 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute5 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute6 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute7 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute8 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute9 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute10 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute11 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute12 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute13 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute14 := null;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute15 := null;
  END IF;

  -- Added for bug fix# 6512803.
  -- honor the input value if passed (from public api).
  IF (p_x_rt_oper_resource_rec.scheduled_type_id IS NULL OR
      p_x_rt_oper_resource_rec.scheduled_type_id = FND_API.G_MISS_NUM) THEN
     IF (p_x_rt_oper_resource_rec.resource_type_id IN (1,2)) THEN
       p_x_rt_oper_resource_rec.scheduled_type_id := 1;
     ELSE
       p_x_rt_oper_resource_rec.scheduled_type_id := 2;
     END IF;
  END IF;

  -- Bug # 7644260 (FP for ER # 6998882) -- start
  IF ( p_x_rt_oper_resource_rec.schedule_seq = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.schedule_seq := null;
  END IF;
  -- Bug # 7644260 (FP for ER # 6998882) -- end

END default_missing_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_rt_oper_resource_rec       IN OUT NOCOPY   rt_oper_resource_rec_type
)
IS

l_old_rt_oper_resource_rec       rt_oper_resource_rec_type;

CURSOR get_old_rec ( c_rt_oper_resource_id NUMBER )
IS
SELECT  aso_resource_id,
        quantity,
        duration,
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
        scheduled_type_id,  -- added for bug fix 6512803.
        -- Bug # 7644260 (FP for ER # 6998882) -- start
        schedule_seq
        -- Bug # 7644260 (FP for ER # 6998882) -- end
FROM    AHL_RT_OPER_RESOURCES
WHERE   rt_oper_resource_id = c_rt_oper_resource_id;

-- Added for bug# 6512803.
CURSOR get_res_type_id( c_resource_id In NUMBER)
IS
SELECT resource_type_id
FROM AHL_RESOURCES
WHERE resource_id = c_resource_id;

l_resource_type_id  NUMBER;


BEGIN

  -- Get the old record from AHL_RT_OPER_RESOURCES.
  OPEN  get_old_rec( p_x_rt_oper_resource_rec.rt_oper_resource_id );

  FETCH get_old_rec INTO
        l_old_rt_oper_resource_rec.aso_resource_id,
        l_old_rt_oper_resource_rec.quantity,
        l_old_rt_oper_resource_rec.duration,
        l_old_rt_oper_resource_rec.attribute_category,
        l_old_rt_oper_resource_rec.attribute1,
        l_old_rt_oper_resource_rec.attribute2,
        l_old_rt_oper_resource_rec.attribute3,
        l_old_rt_oper_resource_rec.attribute4,
        l_old_rt_oper_resource_rec.attribute5,
        l_old_rt_oper_resource_rec.attribute6,
        l_old_rt_oper_resource_rec.attribute7,
        l_old_rt_oper_resource_rec.attribute8,
        l_old_rt_oper_resource_rec.attribute9,
        l_old_rt_oper_resource_rec.attribute10,
        l_old_rt_oper_resource_rec.attribute11,
        l_old_rt_oper_resource_rec.attribute12,
        l_old_rt_oper_resource_rec.attribute13,
        l_old_rt_oper_resource_rec.attribute14,
        l_old_rt_oper_resource_rec.attribute15,
        l_old_rt_oper_resource_rec.scheduled_type_id,
        -- Bug # 7644260 (FP for ER # 6998882) -- start
        l_old_rt_oper_resource_rec.schedule_seq ;
        -- Bug # 7644260 (FP for ER # 6998882) -- end

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RES_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_rt_oper_resource_rec.resource_type_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.resource_type_id := null;
  ELSIF ( p_x_rt_oper_resource_rec.resource_type_id IS NULL ) THEN
    p_x_rt_oper_resource_rec.resource_type_id := l_old_rt_oper_resource_rec.resource_type_id;
  END IF;

  IF ( p_x_rt_oper_resource_rec.resource_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.resource_type := null;
  ELSIF ( p_x_rt_oper_resource_rec.resource_type IS NULL ) THEN
    p_x_rt_oper_resource_rec.resource_type := l_old_rt_oper_resource_rec.resource_type;
  END IF;

  IF ( p_x_rt_oper_resource_rec.aso_resource_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.aso_resource_id := null;
  ELSIF ( p_x_rt_oper_resource_rec.aso_resource_id IS NULL ) THEN
    p_x_rt_oper_resource_rec.aso_resource_id := l_old_rt_oper_resource_rec.aso_resource_id;
  END IF;

  IF ( p_x_rt_oper_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.aso_resource_name := null;
  ELSIF ( p_x_rt_oper_resource_rec.aso_resource_name IS NULL ) THEN
    p_x_rt_oper_resource_rec.aso_resource_name := l_old_rt_oper_resource_rec.aso_resource_name;
  END IF;

  IF ( p_x_rt_oper_resource_rec.quantity = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.quantity := null;
  ELSIF ( p_x_rt_oper_resource_rec.quantity IS NULL ) THEN
    p_x_rt_oper_resource_rec.quantity := l_old_rt_oper_resource_rec.quantity;
  END IF;

  IF ( p_x_rt_oper_resource_rec.duration = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_resource_rec.duration := null;
  ELSIF ( p_x_rt_oper_resource_rec.duration IS NULL ) THEN
    p_x_rt_oper_resource_rec.duration := l_old_rt_oper_resource_rec.duration;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute_category := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute_category IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute_category := l_old_rt_oper_resource_rec.attribute_category;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute1 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute1 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute1 := l_old_rt_oper_resource_rec.attribute1;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute2 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute2 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute2 := l_old_rt_oper_resource_rec.attribute2;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute3 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute3 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute3 := l_old_rt_oper_resource_rec.attribute3;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute4 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute4 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute4 := l_old_rt_oper_resource_rec.attribute4;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute5 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute5 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute5 := l_old_rt_oper_resource_rec.attribute5;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute6 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute6 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute6 := l_old_rt_oper_resource_rec.attribute6;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute7 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute7 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute7 := l_old_rt_oper_resource_rec.attribute7;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute8 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute8 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute8 := l_old_rt_oper_resource_rec.attribute8;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute9 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute9 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute9 := l_old_rt_oper_resource_rec.attribute9;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute10 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute10 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute10 := l_old_rt_oper_resource_rec.attribute10;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute11 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute11 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute11 := l_old_rt_oper_resource_rec.attribute11;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute12 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute12 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute12 := l_old_rt_oper_resource_rec.attribute12;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute13 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute13 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute13 := l_old_rt_oper_resource_rec.attribute13;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute14 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute14 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute14 := l_old_rt_oper_resource_rec.attribute14;
  END IF;

  IF ( p_x_rt_oper_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_resource_rec.attribute15 := null;
  ELSIF ( p_x_rt_oper_resource_rec.attribute15 IS NULL ) THEN
    p_x_rt_oper_resource_rec.attribute15 := l_old_rt_oper_resource_rec.attribute15;
  END IF;

  -- Fix bug# 6512803. Default schedule_type_id based on resource_type_id.
  IF (p_x_rt_oper_resource_rec.scheduled_type_id = FND_API.G_MISS_NUM OR
      p_x_rt_oper_resource_rec.scheduled_type_id IS NULL) THEN
    IF (p_x_rt_oper_resource_rec.aso_resource_id <> l_old_rt_oper_resource_rec.aso_resource_id) THEN
      OPEN get_res_type_id(p_x_rt_oper_resource_rec.aso_resource_id);
      FETCH get_res_type_id INTO l_resource_type_id;
      CLOSE get_res_type_id;

      IF (l_resource_type_id IN (1,2)) THEN
        p_x_rt_oper_resource_rec.scheduled_type_id := 1;
      ELSE
        p_x_rt_oper_resource_rec.scheduled_type_id := 2;
      END IF;

    ELSE
      p_x_rt_oper_resource_rec.scheduled_type_id := l_old_rt_oper_resource_rec.scheduled_type_id;
    END IF;
  END IF;

   -- Bug # 7644260 (FP for ER # 6998882) -- start
   IF ( p_x_rt_oper_resource_rec.schedule_seq = FND_API.G_MISS_NUM ) THEN
     p_x_rt_oper_resource_rec.schedule_seq := null;
   ELSIF ( p_x_rt_oper_resource_rec.schedule_seq IS NULL ) THEN
     p_x_rt_oper_resource_rec.schedule_seq := l_old_rt_oper_resource_rec.schedule_seq;
   END IF;
   -- Bug # 7644260 (FP for ER # 6998882) -- end

END default_unchanged_attributes;

-- Procedure to validate individual rt_oper_resource attributes
PROCEDURE validate_attributes
(
  p_object_id             IN    NUMBER,
  p_association_type_code IN    VARCHAR2,
  p_rt_oper_resource_rec  IN    rt_oper_resource_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

  l_return_status        VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_max_rt_time_span     NUMBER;
  l_dummy                VARCHAR2(1);

  CURSOR check_alternate_resource (c_rt_oper_resource_id number, c_aso_resource_id number) IS
    SELECT 'X'
      FROM ahl_alternate_resources
     WHERE rt_oper_resource_id = c_rt_oper_resource_id
       AND aso_resource_id = c_aso_resource_id;

  -- Cursor added for the bug 3354746(Resource type is not editable when alternate resources are defined)
  CURSOR get_old_rec ( c_rt_oper_resource_id NUMBER )
  IS
  SELECT  resource_type_id,
      resource_type,
      aso_resource_name
  FROM    AHL_RT_OPER_RESOURCES_V
  WHERE   rt_oper_resource_id = c_rt_oper_resource_id;
  l_old_rt_oper_resource_rec       rt_oper_resource_rec_type;

  CURSOR alternate_resource_csr( c_rt_oper_resource_id NUMBER)
  IS
  SELECT alternate_resource_id FROM AHL_ALTERNATE_RESOURCES
  WHERE rt_oper_resource_id = c_rt_oper_resource_id;
  l_alternate_resource_id NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check if the mandatory column aso_resource_id contains a value.
  IF ( ( p_rt_oper_resource_rec.dml_operation = 'C' AND
         p_rt_oper_resource_rec.aso_resource_id IS NULL ) OR
       ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
         p_rt_oper_resource_rec.aso_resource_id = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ASO_RES_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory quantity column contains a positive value.
  IF ( ( p_rt_oper_resource_rec.dml_operation = 'C' AND
         p_rt_oper_resource_rec.quantity IS NULL ) OR
       ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
         p_rt_oper_resource_rec.quantity = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_QTY_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  ELSIF ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
          p_rt_oper_resource_rec.quantity <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_QTY_LESS_ZERO' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory duration column contains a positive value.
  IF ( ( p_rt_oper_resource_rec.dml_operation = 'C' AND
         p_rt_oper_resource_rec.duration IS NULL ) OR
       ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
         p_rt_oper_resource_rec.duration = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DURATION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  ELSIF ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
          p_rt_oper_resource_rec.duration <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_DURATION_LESS_ZERO' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Bug # 7644260 (FP for ER # 6998882) -- start
  --Check if the schedule sequence column contains a positive value.
  IF ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
       p_rt_oper_resource_rec.schedule_seq IS NOT NULL AND
       p_rt_oper_resource_rec.schedule_seq <> FND_API.G_MISS_NUM AND
       p_rt_oper_resource_rec.schedule_seq <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_SEQ_LESS_ZERO' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  --Check if the schedule sequence column contains a whole number.
  ELSIF ( p_rt_oper_resource_rec.dml_operation <> 'D' AND
           p_rt_oper_resource_rec.schedule_seq IS NOT NULL AND
           p_rt_oper_resource_rec.schedule_seq <> FND_API.G_MISS_NUM AND
           TRUNC(p_rt_oper_resource_rec.schedule_seq) <> p_rt_oper_resource_rec.schedule_seq ) THEN
           FND_MESSAGE.set_name( 'AHL','AHL_COM_SCHED_SEQ_INV' );
           FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
           FND_MSG_PUB.add;
  END IF;
  -- Bug # 7644260 (FP for ER # 6998882) -- end

  -- Check if the mandatory Resource Type column does not contain a NULL value.
  IF ( p_rt_oper_resource_rec.dml_operation = 'C' AND
       ( p_rt_oper_resource_rec.resource_type IS NULL OR
         p_rt_oper_resource_rec.resource_type = FND_API.G_MISS_CHAR ) AND
       ( p_rt_oper_resource_rec.resource_type_id IS NULL OR
         p_rt_oper_resource_rec.resource_type_id = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_TYPE_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  ELSIF ( p_rt_oper_resource_rec.dml_operation = 'U' AND
          p_rt_oper_resource_rec.resource_type = FND_API.G_MISS_CHAR AND
          p_rt_oper_resource_rec.resource_type_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_TYPE_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;
  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* as part of fix 6512803 moving this validation to validate_record procedure
   * due to dependency validation between resource_type_id and
   * scheduled_type_id.
  -- Validate whether the Duration specified for the Route / Operation Resource is longer than The Route Time Span.
  IF ( p_rt_oper_resource_rec.duration IS NOT NULL AND
       p_rt_oper_resource_rec.duration <> FND_API.G_MISS_NUM AND
       p_rt_oper_resource_rec.duration > 0 ) THEN

    AHL_RM_ROUTE_UTIL.validate_resource_duration
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_object_id            => p_object_id,
      p_association_type_code=> p_association_type_code,
      p_duration             => p_rt_oper_resource_rec.duration,
      x_max_rt_time_span     => l_max_rt_time_span
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD1', p_rt_oper_resource_rec.duration );
      FND_MESSAGE.set_token( 'FIELD2', l_max_rt_time_span );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;
  -- end changes for fix 6512803. */

  IF ( p_rt_oper_resource_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the ASO resource already existing as an alternate resource when updating the primary ASO resource.
  OPEN check_alternate_resource(p_rt_oper_resource_rec.rt_oper_resource_id, p_rt_oper_resource_rec.aso_resource_id);
  FETCH check_alternate_resource into l_dummy;
  IF check_alternate_resource%FOUND THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ALTERNATE_RES_EXISTS' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;
  CLOSE check_alternate_resource;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_rt_oper_resource_rec.object_version_number IS NULL OR
       p_rt_oper_resource_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_OBJ_VERSION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory rt_oper_resource ID column contains a null value.
  IF ( p_rt_oper_resource_rec.rt_oper_resource_id IS NULL OR
       p_rt_oper_resource_rec.rt_oper_resource_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RT_OPER_RES_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Get the old record from AHL_RT_OPER_RESOURCES.
  OPEN  get_old_rec( p_rt_oper_resource_rec.rt_oper_resource_id );

  FETCH get_old_rec INTO
    l_old_rt_oper_resource_rec.resource_type_id,
    l_old_rt_oper_resource_rec.resource_type,
    l_old_rt_oper_resource_rec.aso_resource_name;

  -- Check added by balaji for the bug 3354746
  IF l_old_rt_oper_resource_rec.resource_type_id <> p_rt_oper_resource_rec.resource_type_id
     OR l_old_rt_oper_resource_rec.resource_type <> p_rt_oper_resource_rec.resource_type
  THEN
     OPEN alternate_resource_csr(p_rt_oper_resource_rec.rt_oper_resource_id);
     FETCH alternate_resource_csr INTO l_alternate_resource_id;
     -- Check if alternate resources are defined for the primary resource, if so throw error that
     -- "Resource type cannot be changed if alternate resources are defined".
     IF alternate_resource_csr%FOUND THEN
       FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RES_TYPE_NO_CHG' );
       -- get_record_identifier can't be used here as it takes old record as parameter.
         FND_MESSAGE.set_token( 'RECORD', l_old_rt_oper_resource_rec.resource_type
                      || ' - '
                      || l_old_rt_oper_resource_rec.aso_resource_name);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE alternate_resource_csr;
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
-- Added p_object_id and p_association_type_code to fix bug# 6512803.
PROCEDURE validate_record
(
  p_rt_oper_resource_rec  IN    rt_oper_resource_rec_type,
  p_object_id             IN    NUMBER,
  p_association_type_code IN    VARCHAR2,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

l_dummy              VARCHAR2(1);

CURSOR check_resource_type( c_aso_resource_id NUMBER, c_resource_type_id NUMBER )
IS
SELECT 'X'
FROM   AHL_RESOURCES
WHERE  resource_id = c_aso_resource_id
 AND  resource_type_id = c_resource_type_id;

-- Added to fix bug# 6512803.
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_max_rt_time_span     NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Ensure that ASO Resource and it's Resource Type Match
  IF ( p_rt_oper_resource_rec.resource_type_id IS NOT NULL AND
       p_rt_oper_resource_rec.aso_resource_id IS NOT NULL ) THEN

    OPEN check_resource_type( p_rt_oper_resource_rec.aso_resource_id,
                              p_rt_oper_resource_rec.resource_type_id );

    FETCH check_resource_type INTO
      l_dummy;

    IF ( check_resource_type%NOTFOUND ) THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_TYPE_ASO_RES' );

      IF ( p_rt_oper_resource_rec.aso_resource_name IS NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD1', TO_CHAR( p_rt_oper_resource_rec.aso_resource_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD1', p_rt_oper_resource_rec.aso_resource_name );
      END IF;

      IF ( p_rt_oper_resource_rec.resource_type IS NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD2', TO_CHAR( p_rt_oper_resource_rec.resource_type_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD2', p_rt_oper_resource_rec.resource_type );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Validate whether the Duration specified for the Route / Operation Resource is longer than The Route Time Span.
  IF ( p_rt_oper_resource_rec.duration IS NOT NULL AND
       p_rt_oper_resource_rec.duration <> FND_API.G_MISS_NUM AND
       p_rt_oper_resource_rec.duration > 0 ) AND
       -- Added to fix bug# 6512803. Validate only for scheduled person and machine type resources.
     ( p_rt_oper_resource_rec.resource_type_id IS NOT NULL AND
       p_rt_oper_resource_rec.resource_type_id <> FND_API.G_MISS_NUM AND
       p_rt_oper_resource_rec.resource_type_id IN (1,2) ) AND
     ( p_rt_oper_resource_rec.scheduled_type_id = 1 )
  THEN

    AHL_RM_ROUTE_UTIL.validate_resource_duration
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_object_id            => p_object_id,
      p_association_type_code=> p_association_type_code,
      p_duration             => p_rt_oper_resource_rec.duration,
      x_max_rt_time_span     => l_max_rt_time_span
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD1', p_rt_oper_resource_rec.duration );
      FND_MESSAGE.set_token( 'FIELD2', l_max_rt_time_span );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_resource_rec ) );
      FND_MSG_PUB.add;
      --dbms_output.put_line('validate_resource_duration error');
    END IF;
  END IF;

END validate_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_object_id             IN    NUMBER,
  p_association_type_code IN    VARCHAR2,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

CURSOR get_dup_rec ( c_object_id NUMBER, c_association_type_code VARCHAR2 )
IS
SELECT   resource_type_id,
         resource_type,
         aso_resource_id,
         aso_resource_name
FROM     AHL_RT_OPER_RESOURCES_V
WHERE    object_id = c_object_id
AND      association_type_code = c_association_type_code
GROUP BY resource_type_id,
         resource_type,
         aso_resource_id,
         aso_resource_name
HAVING   count(*) > 1;

--pdoki ER 7436910 Begin.
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

--checking dept conflicts b/w the primary resource and alt resources of OTHER primary resources
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
--pdoki ER 7436910 End.

l_rt_oper_resource_rec      rt_oper_resource_rec_type;
l_dummy                     VARCHAR(1);
l_rt_oper_res_id            NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check whether any duplicate rt_oper_resource records for the given object_ID
  OPEN  get_dup_rec( p_object_id, p_association_type_code );

  LOOP
    FETCH get_dup_rec INTO
      l_rt_oper_resource_rec.resource_type_id,
      l_rt_oper_resource_rec.resource_type,
      l_rt_oper_resource_rec.aso_resource_id,
      l_rt_oper_resource_rec.aso_resource_name;

    EXIT WHEN get_dup_rec%NOTFOUND;
  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_RESOURCE_DUP' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_rt_oper_resource_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

--pdoki ER 7436910 Begin.
--checking dept conflicts among primary resources
    OPEN get_dept_conflicts( p_object_id, p_association_type_code );

    FETCH get_dept_conflicts INTO l_dummy;

    IF ( get_dept_conflicts%FOUND ) THEN
        CLOSE get_dept_conflicts;
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_DEP_CONFLICT_RES' );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    END IF;

    CLOSE get_dept_conflicts;

--checking dept conflicts b/w the primary resource and alt resources of OTHER primary resources
OPEN  get_rt_oper_res_ids( p_object_id, p_association_type_code );

LOOP
    FETCH get_rt_oper_res_ids INTO l_rt_oper_res_id;

    EXIT WHEN get_rt_oper_res_ids%NOTFOUND;

    OPEN get_dept_conflicts_alt_res( p_object_id, p_association_type_code, l_rt_oper_res_id);

    FETCH get_dept_conflicts_alt_res INTO l_dummy;

    IF ( get_dept_conflicts_alt_res%FOUND ) THEN
        CLOSE get_dept_conflicts_alt_res;
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_DEP_CONFLICT_RES' );
        FND_MSG_PUB.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE get_dept_conflicts_alt_res;

END LOOP;

CLOSE get_rt_oper_res_ids;
--pdoki ER 7436910 End.

END validate_records;

PROCEDURE process_rt_oper_resource
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
  p_x_rt_oper_resource_tbl  IN OUT NOCOPY rt_oper_resource_tbl_type,
  p_association_type_code   IN       VARCHAR2,
  p_object_id          IN            NUMBER
)
IS

cursor get_route_status (p_route_id in number)
is
select revision_status_code
from ahl_routes_app_v
where route_id = p_route_id;

l_obj_status      VARCHAR2(30);
-- Bug # 7644260 (FP for ER # 6998882) -- start
l_min_sch_seq     NUMBER ;
-- Bug # 7644260 (FP for ER # 6998882) -- end

cursor get_oper_status (p_operation_id in number)
is
select revision_status_code
from ahl_operations_b
where operation_id = p_operation_id;

-- Bug # 7644260 (FP for ER # 6998882) -- start
cursor get_min_sch_seq ( c_object_id NUMBER, c_association_type_code VARCHAR2 )
is
select min(schedule_seq)
from   ahl_rt_oper_resources
where  object_id = c_object_id
and    association_type_code = c_association_type_code
and    schedule_seq IS NOT NULL ;
-- Bug # 7644260 (FP for ER # 6998882) -- end

l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data      VARCHAR2(2000);
l_rt_oper_resource_id       NUMBER;
l_x_operation_rec           AHL_RM_OPERATION_PVT.operation_rec_type ;
l_x_route_rec               AHL_RM_ROUTE_PVT.route_rec_type ;
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_rt_oper_resource_pvt;

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
    AHL_DEBUG_PUB.debug( G_PKG_NAME  || '.' || G_API_NAME1 || ' : Begin API' );
  END IF;


  --This is to be added before calling   validate_api_inputs()
-- Validate Application Usage
IF (p_association_type_code  = 'ROUTE')
THEN
AHL_RM_ROUTE_UTIL.validate_ApplnUsage
  (
     p_object_id              => p_object_id,
     p_association_type       => p_association_type_code ,
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
END IF ;


  -- Validate all the inputs of the API
  validate_api_inputs
  (
    p_x_rt_oper_resource_tbl,
    p_association_type_code,
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
    FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
      IF ( p_x_rt_oper_resource_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_rt_oper_resource_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
      IF ( p_x_rt_oper_resource_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_rt_oper_resource_tbl(i) , -- IN OUT Record with Values and Ids
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
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after convert_values_to_ids' );
  END IF;

  -- Default rt_oper_resource attributes.
  /* Removed as a part of public API cleanup in 11510+.
  IF FND_API.to_boolean( p_default ) THEN
    FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
      IF ( p_x_rt_oper_resource_tbl(i).dml_operation <> 'D' ) THEN
        default_attributes
        (
          p_x_rt_oper_resource_tbl(i) -- IN OUT
        );
      END IF;
    END LOOP;
  END IF;
  */

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
      validate_attributes
      (
        p_object_id, -- IN
        p_association_type_code, -- IN
        p_x_rt_oper_resource_tbl(i), -- IN
        l_return_status -- OUT
      );

      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
    IF ( p_x_rt_oper_resource_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_rt_oper_resource_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_rt_oper_resource_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_rt_oper_resource_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
      IF ( p_x_rt_oper_resource_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_x_rt_oper_resource_tbl(i), -- IN
          p_object_id,
          p_association_type_code,
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
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after validate_record' );
  END IF;

IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'Starting updating parent route/operation');
END IF;

IF ( p_association_type_code = 'OPERATION')
THEN
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'p_association_type_code = OPERATION');
     END IF;

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

ELSIF ( p_association_type_code = 'ROUTE')
THEN
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'p_association_type_code = ROUTE');
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

END IF ;


  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_rt_oper_resource_tbl.count LOOP
    IF ( p_x_rt_oper_resource_tbl(i).dml_operation = 'C' ) THEN

      BEGIN
        -- Insert the record
        INSERT INTO AHL_RT_OPER_RESOURCES
        (
          rt_oper_resource_ID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          association_type_code,
          object_ID,
          aso_resource_id,
          quantity,
          duration,
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
          scheduled_type_id,  -- added for bug fix 6512803.
          -- Bug # 7644260 (FP for ER # 6998882) -- start
          schedule_seq
          -- Bug # 7644260 (FP for ER # 6998882) -- end
        ) VALUES
        (
          AHL_RT_OPER_RESOURCES_S.NEXTVAL,
          1,
          G_LAST_UPDATE_DATE,
          G_LAST_UPDATED_BY,
          G_CREATION_DATE,
          G_CREATED_BY,
          G_LAST_UPDATE_LOGIN,
          p_association_type_code,
          p_object_id,
          p_x_rt_oper_resource_tbl(i).aso_resource_id,
          p_x_rt_oper_resource_tbl(i).quantity,
          p_x_rt_oper_resource_tbl(i).duration,
          p_x_rt_oper_resource_tbl(i).attribute_category,
          p_x_rt_oper_resource_tbl(i).attribute1,
          p_x_rt_oper_resource_tbl(i).attribute2,
          p_x_rt_oper_resource_tbl(i).attribute3,
          p_x_rt_oper_resource_tbl(i).attribute4,
          p_x_rt_oper_resource_tbl(i).attribute5,
          p_x_rt_oper_resource_tbl(i).attribute6,
          p_x_rt_oper_resource_tbl(i).attribute7,
          p_x_rt_oper_resource_tbl(i).attribute8,
          p_x_rt_oper_resource_tbl(i).attribute9,
          p_x_rt_oper_resource_tbl(i).attribute10,
          p_x_rt_oper_resource_tbl(i).attribute11,
          p_x_rt_oper_resource_tbl(i).attribute12,
          p_x_rt_oper_resource_tbl(i).attribute13,
          p_x_rt_oper_resource_tbl(i).attribute14,
          p_x_rt_oper_resource_tbl(i).attribute15,
          p_x_rt_oper_resource_tbl(i).scheduled_type_id,
          -- Bug # 7644260 (FP for ER # 6998882) -- start
          p_x_rt_oper_resource_tbl(i).schedule_seq
          -- Bug # 7644260 (FP for ER # 6998882) -- end
        ) RETURNING rt_oper_resource_id INTO l_rt_oper_resource_id;

        -- Set OUT values
        p_x_rt_oper_resource_tbl(i).rt_oper_resource_id := l_rt_oper_resource_id;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_RESOURCE_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_x_rt_oper_resource_tbl(i) ) );
            FND_MSG_PUB.add;
          ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME1,
      'AHL_RT_OPER_RESOURCES insert error = ['||SQLERRM||']'
    );
        END IF;
          END IF;
      END;

    ELSIF ( p_x_rt_oper_resource_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_RT_OPER_RESOURCES SET
          object_version_number   = object_version_number + 1,
          last_update_date        = G_LAST_UPDATE_DATE,
          last_updated_by         = G_LAST_UPDATED_BY,
          last_update_login       = G_LAST_UPDATE_LOGIN,
          aso_resource_id         = p_x_rt_oper_resource_tbl(i).aso_resource_id,
          quantity                = p_x_rt_oper_resource_tbl(i).quantity,
          duration                = p_x_rt_oper_resource_tbl(i).duration,
          attribute_category      = p_x_rt_oper_resource_tbl(i).attribute_category,
          attribute1              = p_x_rt_oper_resource_tbl(i).attribute1,
          attribute2              = p_x_rt_oper_resource_tbl(i).attribute2,
          attribute3              = p_x_rt_oper_resource_tbl(i).attribute3,
          attribute4              = p_x_rt_oper_resource_tbl(i).attribute4,
          attribute5              = p_x_rt_oper_resource_tbl(i).attribute5,
          attribute6              = p_x_rt_oper_resource_tbl(i).attribute6,
          attribute7              = p_x_rt_oper_resource_tbl(i).attribute7,
          attribute8              = p_x_rt_oper_resource_tbl(i).attribute8,
          attribute9              = p_x_rt_oper_resource_tbl(i).attribute9,
          attribute10             = p_x_rt_oper_resource_tbl(i).attribute10,
          attribute11             = p_x_rt_oper_resource_tbl(i).attribute11,
          attribute12             = p_x_rt_oper_resource_tbl(i).attribute12,
          attribute13             = p_x_rt_oper_resource_tbl(i).attribute13,
          attribute14             = p_x_rt_oper_resource_tbl(i).attribute14,
          attribute15             = p_x_rt_oper_resource_tbl(i).attribute15,
          -- added for bug fix# 6512803.
          scheduled_type_id       = p_x_rt_oper_resource_tbl(i).scheduled_type_id,
          -- Bug # 7644260 (FP for ER # 6998882) -- start
          schedule_seq            = p_x_rt_oper_resource_tbl(i).schedule_seq
          -- Bug # 7644260 (FP for ER # 6998882) -- end
        WHERE rt_oper_resource_id = p_x_rt_oper_resource_tbl(i).rt_oper_resource_id
        AND object_version_number = p_x_rt_oper_resource_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_resource_tbl(i) ) );
          FND_MSG_PUB.add;
        END IF;

        -- Set OUT values
        p_x_rt_oper_resource_tbl(i).object_version_number := p_x_rt_oper_resource_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_RESOURCE_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_resource_tbl(i) ) );
            FND_MSG_PUB.add;
          ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME1,
      'AHL_RT_OPER_RESOURCES update error = ['||SQLERRM||']'
    );
        END IF;
          END IF;
      END;

    ELSIF ( p_x_rt_oper_resource_tbl(i).dml_operation = 'D' ) THEN
      --pdoki ER 7436910
      --Deleting alternate_resource mappings for deleted resource.
      DELETE FROM ahl_alternate_resources
      WHERE rt_oper_resource_id = p_x_rt_oper_resource_tbl(i).rt_oper_resource_id;
      --pdoki ER 7436910

      -- Delete the record
      DELETE FROM AHL_RT_OPER_RESOURCES
      WHERE rt_oper_resource_id = p_x_rt_oper_resource_tbl(i).rt_oper_resource_id
      AND object_version_number = p_x_rt_oper_resource_tbl(i).object_version_number;

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
  validate_records
  (
    p_object_id, -- IN
    p_association_type_code,
    l_return_status -- OUT
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

  -- Bug # 7644260 (FP for ER # 6998882) -- start
  OPEN  get_min_sch_seq( p_object_id, p_association_type_code );
  FETCH get_min_sch_seq INTO l_min_sch_seq ;
        IF get_min_sch_seq%FOUND THEN
            UPDATE ahl_rt_oper_resources
            SET    schedule_seq = l_min_sch_seq
            WHERE  object_id = p_object_id
            AND    association_type_code = p_association_type_code
            AND    schedule_seq IS NULL ;
        END IF;
  CLOSE get_min_sch_seq;
  -- Bug # 7644260 (FP for ER # 6998882) -- end

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
    ROLLBACK TO process_rt_oper_resource_PVT;
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
    ROLLBACK TO process_rt_oper_resource_PVT;
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
    ROLLBACK TO process_rt_oper_resource_PVT;
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

END process_rt_oper_resource;

-- The following local procedures are for another publiced API define_cost_parameter
-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_costing_values_to_ids
(
  p_x_rt_oper_cost_rec  IN OUT NOCOPY  rt_oper_cost_rec_type,
  x_return_status       OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate cost_basis_id
  IF ( ( p_x_rt_oper_cost_rec.cost_basis_id IS NOT NULL AND
         p_x_rt_oper_cost_rec.cost_basis_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_cost_rec.cost_basis IS NOT NULL AND
         p_x_rt_oper_cost_rec.cost_basis <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_mfg_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'CST_BASIS',
      p_lookup_meaning         => p_x_rt_oper_cost_rec.cost_basis,
      p_x_lookup_code          => p_x_rt_oper_cost_rec.cost_basis_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_RM_INVALID_MFG_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_COST_BASIS' );
      ELSIF ( l_msg_data = 'AHL_RM_TOO_MANY_MFG_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_COST_BASIS' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_cost_rec.cost_basis IS NULL OR
           p_x_rt_oper_cost_rec.cost_basis = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_cost_rec.cost_basis_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_cost_rec.cost_basis );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;
/* activity look up obsoleted
  -- Convert / Validate activity_id
  IF ( ( p_x_rt_oper_cost_rec.activity_id IS NOT NULL AND
         p_x_rt_oper_cost_rec.activity_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_cost_rec.activity IS NOT NULL AND
         p_x_rt_oper_cost_rec.activity <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_activity
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_activity               => p_x_rt_oper_cost_rec.activity,
      p_x_activity_id          => p_x_rt_oper_cost_rec.activity_id
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_rt_oper_cost_rec.activity IS NULL OR
           p_x_rt_oper_cost_rec.activity = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_cost_rec.activity_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_cost_rec.activity );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;
*/
  -- Convert / Validate scheduled_type_id
  IF ( ( p_x_rt_oper_cost_rec.scheduled_type_id IS NOT NULL AND
         p_x_rt_oper_cost_rec.scheduled_type_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_cost_rec.scheduled_type IS NOT NULL AND
         p_x_rt_oper_cost_rec.scheduled_type <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_mfg_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'BOM_RESOURCE_SCHEDULE_TYPE',
      p_lookup_meaning         => p_x_rt_oper_cost_rec.scheduled_type,
      p_x_lookup_code          => p_x_rt_oper_cost_rec.scheduled_type_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_RM_INVALID_MFG_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_SCHEDULE_TYPE' );
      ELSIF ( l_msg_data = 'AHL_RM_TOO_MANY_MFG_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_SCHEDULE_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_cost_rec.scheduled_type IS NULL OR
           p_x_rt_oper_cost_rec.scheduled_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_cost_rec.scheduled_type_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_cost_rec.scheduled_type );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate autocharge_type_id
  IF ( ( p_x_rt_oper_cost_rec.autocharge_type_id IS NOT NULL AND
         p_x_rt_oper_cost_rec.autocharge_type_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_cost_rec.autocharge_type IS NOT NULL AND
         p_x_rt_oper_cost_rec.autocharge_type <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_mfg_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'BOM_AUTOCHARGE_TYPE',
      p_lookup_meaning         => p_x_rt_oper_cost_rec.autocharge_type,
      p_x_lookup_code          => p_x_rt_oper_cost_rec.autocharge_type_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_RM_INVALID_MFG_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ACHARGE_TYPE' );
      ELSIF ( l_msg_data = 'AHL_RM_TOO_MANY_MFG_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_ACHARGE_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_cost_rec.autocharge_type IS NULL OR
           p_x_rt_oper_cost_rec.autocharge_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_cost_rec.autocharge_type_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_cost_rec.autocharge_type );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate standard_rate_flag
  IF ( ( p_x_rt_oper_cost_rec.standard_rate_flag IS NOT NULL AND
         p_x_rt_oper_cost_rec.standard_rate_flag <> FND_API.G_MISS_NUM ) OR
       ( p_x_rt_oper_cost_rec.standard_rate IS NOT NULL AND
         p_x_rt_oper_cost_rec.standard_rate <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_mfg_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'SYS_YES_NO',
      p_lookup_meaning         => p_x_rt_oper_cost_rec.standard_rate,
      p_x_lookup_code          => p_x_rt_oper_cost_rec.standard_rate_flag
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_RM_INVALID_MFG_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_STD_RATE' );
      ELSIF ( l_msg_data = 'AHL_RM_TOO_MANY_MFG_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_STD_RATES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_cost_rec.standard_rate IS NULL OR
           p_x_rt_oper_cost_rec.standard_rate = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_cost_rec.standard_rate_flag ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_cost_rec.standard_rate );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;
END convert_costing_values_to_ids;

 -- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_costing_unchanged
(
  p_x_rt_oper_cost_rec       IN OUT NOCOPY   rt_oper_cost_rec_type
)
IS

l_old_rt_oper_cost_rec       rt_oper_cost_rec_type;

CURSOR get_old_rec ( c_rt_oper_resource_id NUMBER )
IS
SELECT  activity_id,
        activity,
        cost_basis_id,
        cost_basis,
        scheduled_type_id,
        scheduled_type,
        autocharge_type_id,
        autocharge_type,
        standard_rate_flag,
        standard_rate
FROM    AHL_RT_OPER_RESOURCES_V
WHERE   rt_oper_resource_id = c_rt_oper_resource_id;

BEGIN

  -- Get the old record from AHL_MR_EFFECTIVITIES.
  OPEN  get_old_rec( p_x_rt_oper_cost_rec.rt_oper_resource_id );

  FETCH get_old_rec INTO
        l_old_rt_oper_cost_rec.activity_id,
        l_old_rt_oper_cost_rec.activity,
        l_old_rt_oper_cost_rec.cost_basis_id,
        l_old_rt_oper_cost_rec.cost_basis,
        l_old_rt_oper_cost_rec.scheduled_type_id,
        l_old_rt_oper_cost_rec.scheduled_type,
        l_old_rt_oper_cost_rec.autocharge_type_id,
        l_old_rt_oper_cost_rec.autocharge_type,
        l_old_rt_oper_cost_rec.standard_rate_flag,
        l_old_rt_oper_cost_rec.standard_rate;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RES' );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_rt_oper_cost_rec.activity_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_cost_rec.activity_id := null;
  ELSIF ( p_x_rt_oper_cost_rec.activity_id IS NULL ) THEN
    p_x_rt_oper_cost_rec.activity_id := l_old_rt_oper_cost_rec.activity_id;
  END IF;

  IF ( p_x_rt_oper_cost_rec.activity = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_cost_rec.activity := null;
  ELSIF ( p_x_rt_oper_cost_rec.activity IS NULL ) THEN
    p_x_rt_oper_cost_rec.activity := l_old_rt_oper_cost_rec.activity;
  END IF;

  IF ( p_x_rt_oper_cost_rec.cost_basis_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_cost_rec.cost_basis_id := null;
  ELSIF ( p_x_rt_oper_cost_rec.cost_basis_id IS NULL ) THEN
    p_x_rt_oper_cost_rec.cost_basis_id := l_old_rt_oper_cost_rec.cost_basis_id;
  END IF;

  IF ( p_x_rt_oper_cost_rec.cost_basis = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_cost_rec.cost_basis := null;
  ELSIF ( p_x_rt_oper_cost_rec.cost_basis IS NULL ) THEN
    p_x_rt_oper_cost_rec.cost_basis := l_old_rt_oper_cost_rec.cost_basis;
  END IF;

  IF ( p_x_rt_oper_cost_rec.scheduled_type_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_cost_rec.scheduled_type_id := null;
  ELSIF ( p_x_rt_oper_cost_rec.scheduled_type_id IS NULL ) THEN
    p_x_rt_oper_cost_rec.scheduled_type_id := l_old_rt_oper_cost_rec.scheduled_type_id;
  END IF;

  IF ( p_x_rt_oper_cost_rec.scheduled_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_cost_rec.scheduled_type := null;
  ELSIF ( p_x_rt_oper_cost_rec.scheduled_type IS NULL ) THEN
    p_x_rt_oper_cost_rec.scheduled_type := l_old_rt_oper_cost_rec.scheduled_type;
  END IF;

  IF ( p_x_rt_oper_cost_rec.autocharge_type_id = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_cost_rec.autocharge_type_id := null;
  ELSIF ( p_x_rt_oper_cost_rec.autocharge_type_id IS NULL ) THEN
    p_x_rt_oper_cost_rec.autocharge_type_id := l_old_rt_oper_cost_rec.autocharge_type_id;
  END IF;

  IF ( p_x_rt_oper_cost_rec.autocharge_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_cost_rec.autocharge_type := null;
  ELSIF ( p_x_rt_oper_cost_rec.autocharge_type IS NULL ) THEN
    p_x_rt_oper_cost_rec.autocharge_type := l_old_rt_oper_cost_rec.autocharge_type;
  END IF;

  IF ( p_x_rt_oper_cost_rec.standard_rate_flag = FND_API.G_MISS_NUM ) THEN
    p_x_rt_oper_cost_rec.standard_rate_flag := null;
  ELSIF ( p_x_rt_oper_cost_rec.standard_rate_flag IS NULL ) THEN
    p_x_rt_oper_cost_rec.standard_rate_flag := l_old_rt_oper_cost_rec.standard_rate_flag;
  END IF;

  IF ( p_x_rt_oper_cost_rec.standard_rate = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_cost_rec.standard_rate := null;
  ELSIF ( p_x_rt_oper_cost_rec.standard_rate IS NULL ) THEN
    p_x_rt_oper_cost_rec.standard_rate := l_old_rt_oper_cost_rec.standard_rate;
  END IF;

END default_costing_unchanged;

PROCEDURE define_cost_parameter
(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_default            IN            VARCHAR2   := FND_API.G_FALSE,
  p_module_type        IN            VARCHAR2   := NULL,
  x_return_status      OUT NOCOPY           VARCHAR2,
  x_msg_count          OUT NOCOPY           NUMBER,
  x_msg_data           OUT NOCOPY           VARCHAR2,
  p_x_rt_oper_cost_rec IN OUT NOCOPY rt_oper_cost_rec_type
) IS



-- added AR.resource_type_id and duration to fix bug# 6512803.
CURSOR get_object_rec(C_RT_OPER_RESOURCE_ID NUMBER)
IS
SELECT --DISTINCT
RES.OBJECT_ID,
RES.ASSOCIATION_TYPE_CODE,
AR.resource_type_id,
RES.duration,
AR.NAME
FROM AHL_RT_OPER_RESOURCES RES, AHL_RESOURCES AR
WHERE RES.aso_resource_id = AR.resource_id
AND RES.RT_OPER_RESOURCE_ID = C_RT_OPER_RESOURCE_ID;

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

l_api_version    CONSTANT   NUMBER         := 1.0;
l_api_name       CONSTANT   VARCHAR2(30)   := 'DEFINE_COST_PARAMETER';
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data      VARCHAR2(2000);
l_object_id         NUMBER;
l_association_type_code     VARCHAR2(30);
l_x_operation_rec           AHL_RM_OPERATION_PVT.operation_rec_type ;
l_x_route_rec               AHL_RM_ROUTE_PVT.route_rec_type ;

-- Added for bug fix# 6512803.
l_resource_type_id          NUMBER;
l_max_rt_time_span          NUMBER;
l_duration                  NUMBER;
l_name                      ahl_resources.name%TYPE;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT define_cost_parameter_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    G_API_NAME2,
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.'||l_api_name||': Begin API' );
  END IF;


  -- Convert Values into Ids.
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    convert_costing_values_to_ids
    (
      p_x_rt_oper_cost_rec , -- IN OUT Record with Values and Ids
      l_return_status -- OUT
    );

    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after convert_costing_values_to_ids' );
  END IF;

OPEN  get_object_rec ( p_x_rt_oper_cost_rec.RT_OPER_RESOURCE_ID ) ;
FETCH get_object_rec INTO
        l_object_id         ,
  l_association_type_code     ,
        l_resource_type_id          , -- added for 6512803.
        l_duration                  ,
        l_name                      ;
IF get_object_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_OBJECT' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE get_object_rec;

-- Fix for bug# 6512803. Schedule flag can be set to Yes(1) only for person and
-- machine resources.

--Bug 6625880. AMSRINIV. Doing away with below validation as misc resources can be scheduled.

IF (p_x_rt_oper_cost_rec.scheduled_type_id IS NOT NULL) AND
   (p_x_rt_oper_cost_rec.scheduled_type_id <> FND_API.G_MISS_NUM) THEN
/*
   IF (p_x_rt_oper_cost_rec.scheduled_type_id = 1) AND (l_resource_type_id NOT IN (1,2)) THEN
     FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RES_SCHEDULE_TY' );
     IF ( p_x_rt_oper_cost_rec.scheduled_type IS NULL OR
          p_x_rt_oper_cost_rec.scheduled_type = FND_API.G_MISS_CHAR ) THEN
              SELECT meaning
              INTO p_x_rt_oper_cost_rec.scheduled_type
              FROM fnd_lookup_values_vl
              WHERE lookup_type = 'BOM_RESOURCE_SCHEDULE_TYPE'
                AND lookup_code = p_x_rt_oper_cost_rec.scheduled_type_id;

     END IF;
     FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_cost_rec.scheduled_type );
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF; -- p_x_rt_oper_cost_rec.scheduled_type_id = 1
*/
   -- validate time span based on scheduled_type_id.
   IF (p_x_rt_oper_cost_rec.scheduled_type_id = 1 AND l_resource_type_id IN (1,2)) THEN
       AHL_RM_ROUTE_UTIL.validate_resource_duration
       (
         x_return_status        => l_return_status,
         x_msg_data             => l_msg_data,
         p_object_id            => l_object_id,
         p_association_type_code=> l_association_type_code,
         p_duration             => l_duration,
         x_max_rt_time_span     => l_max_rt_time_span
       );

       IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
         FND_MESSAGE.set_name( 'AHL', l_msg_data );
         FND_MESSAGE.set_token( 'FIELD1', l_duration );
         FND_MESSAGE.set_token( 'FIELD2', l_max_rt_time_span );
         FND_MESSAGE.set_token( 'RECORD', l_name);
         FND_MSG_PUB.add;
         --dbms_output.put_line('Cost: validate_resource_duration error');
       END IF;
  END IF;

ELSIF (p_x_rt_oper_cost_rec.scheduled_type_id = FND_API.G_MISS_NUM) THEN
   -- default here to avoid query on ahl_resources.
   IF (l_resource_type_id IN (1,2)) THEN
      p_x_rt_oper_cost_rec.scheduled_type_id := 1;
   ELSE
      p_x_rt_oper_cost_rec.scheduled_type_id := 2;
   END IF;

END IF; -- p_x_rt_oper_cost_rec.scheduled_type_id IS NOT NULL

  -- moved this procedure after validation on Schedule flag.
  -- Default missing and unchanged attributes.
  default_costing_unchanged
  (
    p_x_rt_oper_cost_rec -- IN OUT
  );

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after default_costing_unchanged' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*
-- to get the association object type code and the object id
OPEN  get_object_rec ( p_x_rt_oper_cost_rec.RT_OPER_RESOURCE_ID ) ;
FETCH get_object_rec INTO
        l_object_id         ,
  l_association_type_code     ;
IF get_object_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_OBJECT' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE get_object_rec;
*/


--to change the status of Approval rejected Routes/perations to Draft if costing parameters are updated.
IF ( l_association_type_code = 'OPERATION')
THEN
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'l_association_type_code = OPERATION');
     END IF;

-- Check if the Route is existing and in Draft status
AHL_RM_ROUTE_UTIL.validate_operation_status
(
  l_object_id,
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
OPEN get_oper_status (l_object_id);
FETCH get_oper_status INTO l_obj_status;
IF (get_oper_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
THEN
  UPDATE ahl_operations_b
  SET revision_status_code = 'DRAFT'
  WHERE operation_id = l_object_id;
END IF;
CLOSE get_oper_status;


ELSIF ( l_association_type_code = 'ROUTE')
THEN
     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'l_association_type_code = ROUTE');
     END IF;

  AHL_RM_ROUTE_UTIL.validate_ApplnUsage
  (
     p_object_id              => l_object_id,
     p_association_type       => l_association_type_code ,
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

-- Check if the Route is existing and in Draft status
AHL_RM_ROUTE_UTIL.validate_route_status
(
  l_object_id,
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
OPEN get_route_status (l_object_id);
FETCH get_route_status INTO l_obj_status;
IF (get_route_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
THEN
  UPDATE ahl_routes_b
  SET revision_status_code = 'DRAFT'
  WHERE route_id = l_object_id;
END IF;
CLOSE get_route_status;

END IF ;

   -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Update the cost parameters
  UPDATE AHL_RT_OPER_RESOURCES SET
          object_version_number   = object_version_number + 1,
          activity_id             = p_x_rt_oper_cost_rec.activity_id,
          cost_basis_id           = p_x_rt_oper_cost_rec.cost_basis_id,
          scheduled_type_id       = p_x_rt_oper_cost_rec.scheduled_type_id,
          autocharge_type_id      = p_x_rt_oper_cost_rec.autocharge_type_id,
          standard_rate_flag      = p_x_rt_oper_cost_rec.standard_rate_flag,
          last_update_date        = SYSDATE,
          last_updated_by         = FND_GLOBAL.user_id,
          last_update_login       = FND_GLOBAL.login_id
  WHERE rt_oper_resource_id = p_x_rt_oper_cost_rec.rt_oper_resource_id
  AND object_version_number = p_x_rt_oper_cost_rec.object_version_number;

  -- If the record does not exist, then, abort API.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.add;
  END IF;

  -- Set OUT values
  p_x_rt_oper_cost_rec.object_version_number := p_x_rt_oper_cost_rec.object_version_number + 1;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after DML operation' );
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
    ROLLBACK TO define_cost_parameter_pvt;
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
    ROLLBACK TO define_cost_parameter_pvt;
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
    ROLLBACK TO define_cost_parameter_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => G_API_NAME2,
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

END define_cost_parameter;

-- Procedure to validate the all the inputs except the table structure of the API
PROCEDURE validate_alt_api_inputs
(
  p_rt_oper_resource_id     IN   NUMBER,
  p_alt_resource_tbl        IN   alt_resource_tbl_type,
  x_return_status           OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a valid value is passed in p_rt_oper_resource_id
  IF ( p_rt_oper_resource_id = FND_API.G_MISS_NUM OR
       p_rt_oper_resource_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_RES_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if at least one record is passed in p_rt_oper_resource_tbl
  IF ( p_alt_resource_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME3 );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_alt_resource_tbl.count LOOP
    IF ( p_alt_resource_tbl(i).dml_operation IS NULL OR
         (
     p_alt_resource_tbl(i).dml_operation <> 'C' AND
     p_alt_resource_tbl(i).dml_operation <> 'U' AND
     p_alt_resource_tbl(i).dml_operation <> 'D'
   )
       )
    THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_alt_resource_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', p_alt_resource_tbl(i).aso_resource_name );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;

END validate_alt_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_alt_lov_attribute_ids
(
  p_x_alt_resource_rec       IN OUT NOCOPY  alt_resource_rec_type
)
IS

BEGIN
  IF ( p_x_alt_resource_rec.aso_resource_name IS NULL ) THEN
    p_x_alt_resource_rec.aso_resource_id := NULL;
  ELSIF ( p_x_alt_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.aso_resource_id := FND_API.G_MISS_NUM;
  END IF;
END clear_alt_lov_attribute_ids;

-- Procedure to perform Value to ID conversion and validation for LOV attributes
PROCEDURE convert_alt_values_to_ids
(
  p_x_alt_resource_rec      IN OUT NOCOPY  alt_resource_rec_type,
  x_return_status           OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate ASO_resource_id
  IF ( ( p_x_alt_resource_rec.aso_resource_id IS NOT NULL AND
         p_x_alt_resource_rec.aso_resource_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_alt_resource_rec.aso_resource_name IS NOT NULL AND
         p_x_alt_resource_rec.aso_resource_name <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_RM_ROUTE_UTIL.validate_aso_resource
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_aso_resource_name      => p_x_alt_resource_rec.aso_resource_name,
      p_x_aso_resource_id      => p_x_alt_resource_rec.aso_resource_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_alt_resource_rec.aso_resource_name IS NULL OR
           p_x_alt_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_alt_resource_rec.aso_resource_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_alt_resource_rec.aso_resource_name );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', p_x_alt_resource_rec.aso_resource_name );
      FND_MSG_PUB.add;
    END IF;
    x_return_status := l_return_status;
  END IF;

END convert_alt_values_to_ids;

/* Removing as a part of Public API cleanup in 11510+.
-- Procedure to add Default values for rt_oper_resource attributes
PROCEDURE default_alt_attributes
(
  p_x_alt_resource_rec       IN OUT NOCOPY   alt_resource_rec_type
)
IS

BEGIN

  p_x_alt_resource_rec.last_update_date := SYSDATE;
  p_x_alt_resource_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_alt_resource_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_alt_resource_rec.dml_operation = 'C' ) THEN
    p_x_alt_resource_rec.object_version_number := 1;
    p_x_alt_resource_rec.creation_date := SYSDATE;
    p_x_alt_resource_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_alt_attributes;
*/
 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_alt_miss_attributes
(
  p_x_alt_resource_rec       IN OUT NOCOPY   alt_resource_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL

  IF ( p_x_alt_resource_rec.aso_resource_id = FND_API.G_MISS_NUM ) THEN
    p_x_alt_resource_rec.aso_resource_id := null;
  END IF;

  IF ( p_x_alt_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.aso_resource_name := null;
  END IF;

  IF ( p_x_alt_resource_rec.priority = FND_API.G_MISS_NUM ) THEN
    p_x_alt_resource_rec.priority := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute_category := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute1 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute2 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute3 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute4 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute5 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute6 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute7 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute8 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute9 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute10 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute11 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute12 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute13 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute14 := null;
  END IF;

  IF ( p_x_alt_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute15 := null;
  END IF;

END default_alt_miss_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_alt_unchang_attributes
(
  p_x_alt_resource_rec       IN OUT NOCOPY   alt_resource_rec_type
)
IS

l_old_alt_resource_rec       alt_resource_rec_type;

CURSOR get_old_rec ( c_alt_resource_id NUMBER )
IS
SELECT  alternate_resource_id,
        aso_resource_id,
        priority,
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
FROM    AHL_ALTERNATE_RESOURCES
WHERE   alternate_resource_id = c_alt_resource_id;

BEGIN

  -- Get the old record from AHL_alt_RESOURCES.
  OPEN  get_old_rec( p_x_alt_resource_rec.alternate_resource_id );

  FETCH get_old_rec INTO
        l_old_alt_resource_rec.alternate_resource_id,
        l_old_alt_resource_rec.aso_resource_id,
        l_old_alt_resource_rec.priority,
        l_old_alt_resource_rec.attribute_category,
        l_old_alt_resource_rec.attribute1,
        l_old_alt_resource_rec.attribute2,
        l_old_alt_resource_rec.attribute3,
        l_old_alt_resource_rec.attribute4,
        l_old_alt_resource_rec.attribute5,
        l_old_alt_resource_rec.attribute6,
        l_old_alt_resource_rec.attribute7,
        l_old_alt_resource_rec.attribute8,
        l_old_alt_resource_rec.attribute9,
        l_old_alt_resource_rec.attribute10,
        l_old_alt_resource_rec.attribute11,
        l_old_alt_resource_rec.attribute12,
        l_old_alt_resource_rec.attribute13,
        l_old_alt_resource_rec.attribute14,
        l_old_alt_resource_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ALT_RES_REC' );
    FND_MESSAGE.set_token( 'RECORD', p_x_alt_resource_rec.aso_resource_name );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values

  IF ( p_x_alt_resource_rec.aso_resource_id = FND_API.G_MISS_NUM ) THEN
    p_x_alt_resource_rec.aso_resource_id := null;
  ELSIF ( p_x_alt_resource_rec.aso_resource_id IS NULL ) THEN
    p_x_alt_resource_rec.aso_resource_id := l_old_alt_resource_rec.aso_resource_id;
  END IF;

  IF ( p_x_alt_resource_rec.aso_resource_name = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.aso_resource_name := null;
  ELSIF ( p_x_alt_resource_rec.aso_resource_name IS NULL ) THEN
    p_x_alt_resource_rec.aso_resource_name := l_old_alt_resource_rec.aso_resource_name;
  END IF;

  IF ( p_x_alt_resource_rec.priority = FND_API.G_MISS_NUM ) THEN
    p_x_alt_resource_rec.priority := null;
  ELSIF ( p_x_alt_resource_rec.priority IS NULL ) THEN
    p_x_alt_resource_rec.priority := l_old_alt_resource_rec.priority;
  END IF;

  IF ( p_x_alt_resource_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute_category := null;
  ELSIF ( p_x_alt_resource_rec.attribute_category IS NULL ) THEN
    p_x_alt_resource_rec.attribute_category := l_old_alt_resource_rec.attribute_category;
  END IF;

  IF ( p_x_alt_resource_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute1 := null;
  ELSIF ( p_x_alt_resource_rec.attribute1 IS NULL ) THEN
    p_x_alt_resource_rec.attribute1 := l_old_alt_resource_rec.attribute1;
  END IF;

  IF ( p_x_alt_resource_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute2 := null;
  ELSIF ( p_x_alt_resource_rec.attribute2 IS NULL ) THEN
    p_x_alt_resource_rec.attribute2 := l_old_alt_resource_rec.attribute2;
  END IF;

  IF ( p_x_alt_resource_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute3 := null;
  ELSIF ( p_x_alt_resource_rec.attribute3 IS NULL ) THEN
    p_x_alt_resource_rec.attribute3 := l_old_alt_resource_rec.attribute3;
  END IF;

  IF ( p_x_alt_resource_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute4 := null;
  ELSIF ( p_x_alt_resource_rec.attribute4 IS NULL ) THEN
    p_x_alt_resource_rec.attribute4 := l_old_alt_resource_rec.attribute4;
  END IF;

  IF ( p_x_alt_resource_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute5 := null;
  ELSIF ( p_x_alt_resource_rec.attribute5 IS NULL ) THEN
    p_x_alt_resource_rec.attribute5 := l_old_alt_resource_rec.attribute5;
  END IF;

  IF ( p_x_alt_resource_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute6 := null;
  ELSIF ( p_x_alt_resource_rec.attribute6 IS NULL ) THEN
    p_x_alt_resource_rec.attribute6 := l_old_alt_resource_rec.attribute6;
  END IF;

  IF ( p_x_alt_resource_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute7 := null;
  ELSIF ( p_x_alt_resource_rec.attribute7 IS NULL ) THEN
    p_x_alt_resource_rec.attribute7 := l_old_alt_resource_rec.attribute7;
  END IF;

  IF ( p_x_alt_resource_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute8 := null;
  ELSIF ( p_x_alt_resource_rec.attribute8 IS NULL ) THEN
    p_x_alt_resource_rec.attribute8 := l_old_alt_resource_rec.attribute8;
  END IF;

  IF ( p_x_alt_resource_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute9 := null;
  ELSIF ( p_x_alt_resource_rec.attribute9 IS NULL ) THEN
    p_x_alt_resource_rec.attribute9 := l_old_alt_resource_rec.attribute9;
  END IF;

  IF ( p_x_alt_resource_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute10 := null;
  ELSIF ( p_x_alt_resource_rec.attribute10 IS NULL ) THEN
    p_x_alt_resource_rec.attribute10 := l_old_alt_resource_rec.attribute10;
  END IF;

  IF ( p_x_alt_resource_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute11 := null;
  ELSIF ( p_x_alt_resource_rec.attribute11 IS NULL ) THEN
    p_x_alt_resource_rec.attribute11 := l_old_alt_resource_rec.attribute11;
  END IF;

  IF ( p_x_alt_resource_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute12 := null;
  ELSIF ( p_x_alt_resource_rec.attribute12 IS NULL ) THEN
    p_x_alt_resource_rec.attribute12 := l_old_alt_resource_rec.attribute12;
  END IF;

  IF ( p_x_alt_resource_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute13 := null;
  ELSIF ( p_x_alt_resource_rec.attribute13 IS NULL ) THEN
    p_x_alt_resource_rec.attribute13 := l_old_alt_resource_rec.attribute13;
  END IF;

  IF ( p_x_alt_resource_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute14 := null;
  ELSIF ( p_x_alt_resource_rec.attribute14 IS NULL ) THEN
    p_x_alt_resource_rec.attribute14 := l_old_alt_resource_rec.attribute14;
  END IF;

  IF ( p_x_alt_resource_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_alt_resource_rec.attribute15 := null;
  ELSIF ( p_x_alt_resource_rec.attribute15 IS NULL ) THEN
    p_x_alt_resource_rec.attribute15 := l_old_alt_resource_rec.attribute15;
  END IF;

END default_alt_unchang_attributes;

-- Procedure to validate individual rt_oper_resource attributes
PROCEDURE validate_alt_attributes
(
  p_alt_resource_rec      IN    alt_resource_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_max_rt_time_span     NUMBER;
  l_dummy                NUMBER;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the mandatory quantity column contains a positive value.
  IF ( ( p_alt_resource_rec.dml_operation = 'C' AND
         p_alt_resource_rec.priority IS NULL ) OR
       ( p_alt_resource_rec.dml_operation <> 'D' AND
         p_alt_resource_rec.priority = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_PRIORITY_NULL' );
    FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
    FND_MSG_PUB.add;
  ELSIF ( p_alt_resource_rec.dml_operation <> 'D' AND
          p_alt_resource_rec.priority <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_PRIORITY_LESS_ZERO' );
    FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
    FND_MSG_PUB.add;
  ELSIF ( p_alt_resource_rec.dml_operation <> 'D' AND
          p_alt_resource_rec.priority > 0 ) THEN
    BEGIN
      l_dummy := TO_NUMBER(TO_CHAR(p_alt_resource_rec.priority), '999999');
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.set_name( 'AHL','AHL_RM_PRIORITY_NOT_INTEGER' );
        FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
        FND_MSG_PUB.add;
    END;
  END IF;

  IF ( p_alt_resource_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_alt_resource_rec.dml_operation <> 'D' AND (p_alt_resource_rec.object_version_number IS NULL OR
       p_alt_resource_rec.object_version_number = FND_API.G_MISS_NUM) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ALT_OBJ_VER_NUM_NULL' );
    FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory rt_oper_resource ID column contains a null value.
  IF ( p_alt_resource_rec.dml_operation <> 'D' AND (p_alt_resource_rec.alternate_resource_id IS NULL OR
       p_alt_resource_rec.alternate_resource_id = FND_API.G_MISS_NUM) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ALT_RES_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
    FND_MSG_PUB.add;
  END IF;

END validate_alt_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_alt_record
(
  p_rt_oper_resource_id   IN    NUMBER,
  p_alt_resource_rec      IN    alt_resource_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

l_res_type1              NUMBER;
l_res_type2              NUMBER;

CURSOR check_resource_type1( c_rt_oper_resource_id NUMBER)
IS
SELECT resource_type_id
FROM   AHL_RT_OPER_RESOURCES_V
WHERE  rt_oper_resource_id = c_rt_oper_resource_id;

CURSOR check_resource_type2( c_aso_resource_id NUMBER)
IS
SELECT resource_type_id
FROM   AHL_RESOURCES
WHERE  resource_id = c_aso_resource_id;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN check_resource_type1( p_rt_oper_resource_id);
  FETCH check_resource_type1 INTO l_res_type1;
  IF ( check_resource_type1%NOTFOUND ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_RT_OPER_RES_ID' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    OPEN check_resource_type2( p_alt_resource_rec.aso_resource_id);
    FETCH check_resource_type2 INTO l_res_type2;
    IF ( check_resource_type2%NOTFOUND ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_ASO_RES_ID' );
      FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF l_res_type1 <> l_res_type2 THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_RES_TYPE_DIFF' );
      FND_MESSAGE.set_token( 'RECORD', p_alt_resource_rec.aso_resource_name );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE check_resource_type2;
  END IF;
  CLOSE check_resource_type1;
END validate_alt_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_alt_records
(
  p_rt_oper_resource_id   IN    NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

CURSOR get_dup_rec1 (c_rt_oper_resource_id number)
IS
SELECT   name
FROM     AHL_ALTERNATE_RESOURCES_V
WHERE    rt_oper_resource_id = c_rt_oper_resource_id
GROUP BY NAME
HAVING   count(*) > 1;

l_res_name          VARCHAR2(30);
l_primary_name      varchar2(30);

CURSOR get_dup_rec2 (c_rt_oper_resource_id number)
IS
SELECT   priority
FROM     AHL_ALTERNATE_RESOURCES
WHERE    rt_oper_resource_id = c_rt_oper_resource_id
GROUP BY priority
HAVING   count(*) > 1;

l_priority         NUMBER;

CURSOR get_primary_res_name (c_rt_oper_resource_id number)
IS
SELECT aso_resource_name
from   ahl_rt_oper_resources_v
where  rt_oper_resource_id = c_rt_oper_resource_id;

CURSOR get_alt_res_name (c_rt_oper_resource_id number, c_aso_resource_name varchar2)
IS
select name
from   AHL_alternate_resources_v
where  rt_oper_resource_id = c_rt_oper_resource_id
and    name = c_aso_resource_name;

--pdoki ER 7436910 Begin.
CURSOR get_dept_conflicts ( c_object_id NUMBER, c_association_type_code VARCHAR2, c_aso_res_id NUMBER, c_alt_res_id NUMBER)
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

CURSOR get_aso_res_ids(c_rt_oper_resource_id number)
IS
SELECT ASO_RESOURCE_ID
FROM AHL_ALTERNATE_RESOURCES
WHERE RT_OPER_RESOURCE_ID= c_rt_oper_resource_id;

l_dummy                     VARCHAR2(1);
l_object_id                 NUMBER;
l_association_type_code     VARCHAR2(30);
l_aso_res_id                NUMBER;
l_alt_res_id                NUMBER;
--pdoki ER 7436910 End.

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check whether any duplicate rt_oper_resource records for the given object_ID
  OPEN get_primary_res_name (p_rt_oper_resource_id);
  FETCH get_primary_res_name INTO l_primary_name;
  IF get_primary_res_name%NOTFOUND THEN
    CLOSE get_primary_res_name;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RT_OPER_RES_ID' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE get_primary_res_name;
    OPEN get_alt_res_name (p_rt_oper_resource_id, l_primary_name);
    FETCH get_alt_res_name INTO l_res_name;
    IF get_alt_res_name%FOUND THEN
      CLOSE get_alt_res_name;
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_PRIMARY_RESOURCE_NAME' );
      FND_MESSAGE.set_token( 'RECORD', l_primary_name);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE get_alt_res_name;
    END IF;
  END IF;

  OPEN  get_dup_rec1(p_rt_oper_resource_id);
  LOOP
    FETCH get_dup_rec1 INTO l_res_name;
    EXIT WHEN get_dup_rec1%NOTFOUND;
  END LOOP;
  IF ( get_dup_rec1%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec1;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ALT_RESOURCE_DUP' );
    FND_MESSAGE.set_token( 'RECORD', l_res_name );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_dup_rec1;

  OPEN  get_dup_rec2(p_rt_oper_resource_id);
  LOOP
    FETCH get_dup_rec2 INTO l_priority;
    EXIT WHEN get_dup_rec2%NOTFOUND;
  END LOOP;
  IF ( get_dup_rec2%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec2;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ALT_RES_PRIORITY_DUP' );
    FND_MESSAGE.set_token( 'RECORD', l_priority );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_dup_rec2;

--pdoki ER 7436910 Begin.
OPEN  get_rt_oper_res_det( p_rt_oper_resource_id );
FETCH get_rt_oper_res_det INTO
  l_object_id,
  l_association_type_code,
  l_aso_res_id;
CLOSE get_rt_oper_res_det;

OPEN  get_aso_res_ids( p_rt_oper_resource_id );
LOOP
    FETCH get_aso_res_ids INTO l_alt_res_id;
    EXIT WHEN get_aso_res_ids%NOTFOUND;
    OPEN get_dept_conflicts( l_object_id, l_association_type_code, l_aso_res_id, l_alt_res_id);
    FETCH get_dept_conflicts INTO l_dummy;
    IF ( get_dept_conflicts%FOUND ) THEN
        CLOSE get_dept_conflicts;
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_DEP_CONFLICT_RES' );
        FND_MSG_PUB.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_dept_conflicts;
END LOOP;
CLOSE get_aso_res_ids;
--pdoki ER 7436910 End.

END validate_alt_records;

PROCEDURE process_alternate_resource
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
  p_rt_oper_resource_id IN           NUMBER,
  p_x_alt_resource_tbl  IN OUT NOCOPY alt_resource_tbl_type
) IS

l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_alt_resource_id           NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_alternate_resource_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    G_API_NAME3,
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' : Begin API' );
  END IF;

  -- Validate all the inputs of the API
  validate_alt_api_inputs
  (
    p_rt_oper_resource_id,
    p_x_alt_resource_tbl,
    l_return_status
  );

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_alt_resource_tbl.count LOOP
      IF ( p_x_alt_resource_tbl(i).dml_operation <> 'D' ) THEN
        clear_alt_lov_attribute_ids
        (
          p_x_alt_resource_tbl(i)
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_alt_resource_tbl.count LOOP
      IF ( p_x_alt_resource_tbl(i).dml_operation <> 'D' ) THEN
        convert_alt_values_to_ids
        (
          p_x_alt_resource_tbl(i) ,
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
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after convert_values_to_ids' );
  END IF;

  /* Removing the procedure call as a part of public API cleanup in 11510+
  -- Default rt_oper_resource attributes.
  IF FND_API.to_boolean( p_default ) THEN
    FOR i IN 1..p_x_alt_resource_tbl.count LOOP
      IF ( p_x_alt_resource_tbl(i).dml_operation <> 'D' ) THEN
        default_alt_attributes
        (
          p_x_alt_resource_tbl(i) -- IN OUT
        );
      END IF;
    END LOOP;
  END IF;
  */

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_alt_resource_tbl.count LOOP
      validate_alt_attributes
      (
        p_x_alt_resource_tbl(i),
        l_return_status
      );

      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_alt_resource_tbl.count LOOP
    IF ( p_x_alt_resource_tbl(i).dml_operation = 'U' ) THEN
      default_alt_unchang_attributes
      (
        p_x_alt_resource_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_alt_resource_tbl(i).dml_operation = 'C' ) THEN
      default_alt_miss_attributes
      (
        p_x_alt_resource_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_alt_resource_tbl.count LOOP
      IF ( p_x_alt_resource_tbl(i).dml_operation <> 'D' ) THEN
        validate_alt_record
        (
          p_rt_oper_resource_id,
          p_x_alt_resource_tbl(i),
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
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after validate_record' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_alt_resource_tbl.count LOOP
    IF ( p_x_alt_resource_tbl(i).dml_operation = 'C' ) THEN

      BEGIN
        -- Insert the record
        INSERT INTO AHL_ALTERNATE_RESOURCES
        (
          ALTERNATE_RESOURCE_ID,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          RT_OPER_RESOURCE_ID,
          ASO_RESOURCE_ID,
          PRIORITY,
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
          AHL_ALTERNATE_RESOURCES_S.NEXTVAL,
          1,
          G_LAST_UPDATE_DATE,
          G_LAST_UPDATED_BY,
          G_CREATION_DATE,
          G_CREATED_BY,
          G_LAST_UPDATE_LOGIN,
          p_rt_oper_resource_id,
          p_x_alt_resource_tbl(i).aso_resource_id,
          p_x_alt_resource_tbl(i).priority,
          p_x_alt_resource_tbl(i).attribute_category,
          p_x_alt_resource_tbl(i).attribute1,
          p_x_alt_resource_tbl(i).attribute2,
          p_x_alt_resource_tbl(i).attribute3,
          p_x_alt_resource_tbl(i).attribute4,
          p_x_alt_resource_tbl(i).attribute5,
          p_x_alt_resource_tbl(i).attribute6,
          p_x_alt_resource_tbl(i).attribute7,
          p_x_alt_resource_tbl(i).attribute8,
          p_x_alt_resource_tbl(i).attribute9,
          p_x_alt_resource_tbl(i).attribute10,
          p_x_alt_resource_tbl(i).attribute11,
          p_x_alt_resource_tbl(i).attribute12,
          p_x_alt_resource_tbl(i).attribute13,
          p_x_alt_resource_tbl(i).attribute14,
          p_x_alt_resource_tbl(i).attribute15
        ) RETURNING alternate_resource_id INTO l_alt_resource_id ;

        -- Set OUT values
        p_x_alt_resource_tbl(i).alternate_resource_id := l_alt_resource_id;


      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ALT_RESOURCE_DUP' );
            FND_MESSAGE.set_token( 'RECORD', p_x_alt_resource_tbl(i).aso_resource_name );
            FND_MSG_PUB.add;
          ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME3,
      'AHL_ALTERNATE_RESOURCES insert error = ['||SQLERRM||']'
    );
        END IF;
          END IF;
      END;

    ELSIF ( p_x_alt_resource_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_ALTERNATE_RESOURCES SET
          object_version_number   = object_version_number + 1,
          last_update_date        = G_LAST_UPDATE_DATE,
          last_updated_by         = G_LAST_UPDATED_BY,
          last_update_login       = G_LAST_UPDATE_LOGIN,
          aso_resource_id         = p_x_alt_resource_tbl(i).aso_resource_id,
          priority                = p_x_alt_resource_tbl(i).priority,
          attribute_category      = p_x_alt_resource_tbl(i).attribute_category,
          attribute1              = p_x_alt_resource_tbl(i).attribute1,
          attribute2              = p_x_alt_resource_tbl(i).attribute2,
          attribute3              = p_x_alt_resource_tbl(i).attribute3,
          attribute4              = p_x_alt_resource_tbl(i).attribute4,
          attribute5              = p_x_alt_resource_tbl(i).attribute5,
          attribute6              = p_x_alt_resource_tbl(i).attribute6,
          attribute7              = p_x_alt_resource_tbl(i).attribute7,
          attribute8              = p_x_alt_resource_tbl(i).attribute8,
          attribute9              = p_x_alt_resource_tbl(i).attribute9,
          attribute10             = p_x_alt_resource_tbl(i).attribute10,
          attribute11             = p_x_alt_resource_tbl(i).attribute11,
          attribute12             = p_x_alt_resource_tbl(i).attribute12,
          attribute13             = p_x_alt_resource_tbl(i).attribute13,
          attribute14             = p_x_alt_resource_tbl(i).attribute14,
          attribute15             = p_x_alt_resource_tbl(i).attribute15
        WHERE alternate_resource_id = p_x_alt_resource_tbl(i).alternate_resource_id
        AND object_version_number = p_x_alt_resource_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', p_x_alt_resource_tbl(i).aso_resource_name );
          FND_MSG_PUB.add;
        END IF;

        -- Set OUT values
        p_x_alt_resource_tbl(i).object_version_number := p_x_alt_resource_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ALT_RESOURCE_DUP' );
            FND_MESSAGE.set_token( 'RECORD', p_x_alt_resource_tbl(i).aso_resource_name );
            FND_MSG_PUB.add;
          ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME3,
      'AHL_ALTERNATE_RESOURCES update error = ['||SQLERRM||']'
    );
        END IF;
          END IF;
      END;

    ELSIF ( p_x_alt_resource_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE FROM AHL_ALTERNATE_RESOURCES
      WHERE alternate_resource_id = p_x_alt_resource_tbl(i).alternate_resource_id
      AND object_version_number = p_x_alt_resource_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
      END IF;
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after DML operation' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform cross records validations and duplicate records check
  validate_alt_records
  (
    p_rt_oper_resource_id,
    l_return_status
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME3 || ' :  after validate_records' );
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
    ROLLBACK TO PROCESS_ALTERNATE_RESOURCE_PVT;
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
    ROLLBACK TO PROCESS_ALTERNATE_RESOURCE_PVT;
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
    ROLLBACK TO PROCESS_ALTERNATE_RESOURCE_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => G_API_NAME3,
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

END PROCESS_ALTERNATE_RESOURCE;

END AHL_RM_RT_OPER_RESOURCE_PVT;

/
