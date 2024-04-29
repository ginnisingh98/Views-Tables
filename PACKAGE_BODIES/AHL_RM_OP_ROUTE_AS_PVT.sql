--------------------------------------------------------
--  DDL for Package Body AHL_RM_OP_ROUTE_AS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_OP_ROUTE_AS_PVT" AS
/* $Header: AHLVORMB.pls 120.0 2005/05/26 02:20:14 appldev noship $ */
G_PKG_NAME VARCHAR2(30) := 'AHL_RM_OP_ROUTE_AS_PVT';
G_API_NAME VARCHAR2(30) := 'PROCESS_ROUTE_OPERATION_AS';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

-- constants for WHO Columns
-- Added by Prithwi as a part of Public API cleanup

G_LAST_UPDATE_DATE 	DATE 		:= SYSDATE;
G_LAST_UPDATED_BY 	NUMBER(15) 	:= FND_GLOBAL.user_id;
G_LAST_UPDATE_LOGIN 	NUMBER(15) 	:= FND_GLOBAL.login_id;
G_CREATION_DATE 	DATE 		:= SYSDATE;
G_CREATED_BY 		NUMBER(15) 	:= FND_GLOBAL.user_id;

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_route_operation_rec       IN    route_operation_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN

    IF ( p_route_operation_rec.step IS NOT NULL AND
         p_route_operation_rec.step <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || to_char(p_route_operation_rec.step);
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_route_operation_rec.concatenated_segments IS NOT NULL AND
         p_route_operation_rec.concatenated_segments <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_route_operation_rec.concatenated_segments;
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_route_operation_rec.revision_number IS NOT NULL AND
         p_route_operation_rec.revision_number <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_route_operation_rec.revision_number;
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_route_operation_rec.check_point_flag IS NOT NULL AND
         p_route_operation_rec.check_point_flag <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_route_operation_rec.check_point_flag;
    END IF;

    RETURN l_record_identifier;

END get_record_identifier;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_route_operation_tbl          IN   route_operation_tbl_type,
  p_route_id                     IN   NUMBER,
  x_return_status                OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a valid value is passed in p_route_id
  IF ( p_route_id = FND_API.G_MISS_NUM OR p_route_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Route is existing and in Draft status
  AHL_RM_ROUTE_UTIL.validate_route_status
  (
    p_route_id,
    l_msg_data,
    l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('AHL',l_msg_data);
    FND_MSG_PUB.ADD;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Check if at least one record is passed in p_route_operation_tbl
  IF ( p_route_operation_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_route_operation_tbl.count LOOP
    IF ( p_route_operation_tbl(i).dml_operation <> 'C' AND
         p_route_operation_tbl(i).dml_operation <> 'U' AND
         p_route_operation_tbl(i).dml_operation <> 'D' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML' );
      FND_MESSAGE.set_token( 'FIELD', p_route_operation_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_route_operation_rec       IN OUT NOCOPY  route_operation_rec_type
)
IS

BEGIN
  IF ( p_x_route_operation_rec.concatenated_segments IS NULL ) THEN
    p_x_route_operation_rec.operation_id := NULL;
  ELSIF ( p_x_route_operation_rec.concatenated_segments = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.operation_id := FND_API.G_MISS_NUM;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_route_operation_rec   IN OUT NOCOPY  route_operation_rec_type,
  x_return_status           OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Operation
  IF ( ( p_x_route_operation_rec.operation_id IS NOT NULL AND
         p_x_route_operation_rec.operation_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_route_operation_rec.concatenated_segments IS NOT NULL AND
         p_x_route_operation_rec.concatenated_segments <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_operation
    (
      x_return_status         => l_return_status,
      x_msg_data              => l_msg_data,
      p_concatenated_segments => p_x_route_operation_rec.concatenated_segments,
      p_x_operation_id        => p_x_route_operation_rec.operation_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_RM_INVALID_OPERATION' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RTO_INVALID_OPERATION' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_operation_rec.concatenated_segments IS NULL OR
           p_x_route_operation_rec.concatenated_segments = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_route_operation_rec.operation_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_route_operation_rec.concatenated_segments );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_route_operation_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;



 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_route_operation_rec       IN OUT NOCOPY   route_operation_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_route_operation_rec.concatenated_segments = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.concatenated_segments := null;
  END IF;

  IF ( p_x_route_operation_rec.operation_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_operation_rec.operation_id := null;
  END IF;

  IF ( p_x_route_operation_rec.step = FND_API.G_MISS_NUM ) THEN
    p_x_route_operation_rec.step := null;
  END IF;

  IF ( p_x_route_operation_rec.check_point_flag = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.check_point_flag := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute_category := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute1 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute2 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute3 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute4 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute5 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute6 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute7 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute8 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute9 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute10 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute11 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute12 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute13 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute14 := null;
  END IF;

  IF ( p_x_route_operation_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute15 := null;
  END IF;

END default_missing_attributes;

 -- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_route_operation_rec       IN OUT NOCOPY   route_operation_rec_type
)
IS

l_old_route_operation_rec       route_operation_rec_type;

CURSOR get_old_rec ( c_route_operation_id NUMBER )
IS
SELECT  operation_id,
        concatenated_segments,
        step,
        check_point_flag,
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
FROM    AHL_ROUTE_OPERATIONS_V
WHERE   route_operation_id = c_route_operation_id;

BEGIN

  -- Get the old record
  OPEN  get_old_rec( p_x_route_operation_rec.route_operation_id );

  FETCH get_old_rec INTO
        l_old_route_operation_rec.operation_id,
        l_old_route_operation_rec.concatenated_segments,
        l_old_route_operation_rec.step,
        l_old_route_operation_rec.check_point_flag,
        l_old_route_operation_rec.attribute_category,
        l_old_route_operation_rec.attribute1,
        l_old_route_operation_rec.attribute2,
        l_old_route_operation_rec.attribute3,
        l_old_route_operation_rec.attribute4,
        l_old_route_operation_rec.attribute5,
        l_old_route_operation_rec.attribute6,
        l_old_route_operation_rec.attribute7,
        l_old_route_operation_rec.attribute8,
        l_old_route_operation_rec.attribute9,
        l_old_route_operation_rec.attribute10,
        l_old_route_operation_rec.attribute11,
        l_old_route_operation_rec.attribute12,
        l_old_route_operation_rec.attribute13,
        l_old_route_operation_rec.attribute14,
        l_old_route_operation_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_RT_OPER_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_route_operation_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values

  IF ( p_x_route_operation_rec.concatenated_segments = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.concatenated_segments := null;
  ELSIF ( p_x_route_operation_rec.concatenated_segments IS NULL ) THEN
    p_x_route_operation_rec.concatenated_segments := l_old_route_operation_rec.concatenated_segments;
  END IF;

  IF ( p_x_route_operation_rec.operation_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_operation_rec.operation_id := null;
  ELSIF ( p_x_route_operation_rec.operation_id IS NULL ) THEN
    p_x_route_operation_rec.operation_id := l_old_route_operation_rec.operation_id;
  END IF;

  IF ( p_x_route_operation_rec.step = FND_API.G_MISS_NUM ) THEN
    p_x_route_operation_rec.step := null;
  ELSIF ( p_x_route_operation_rec.step IS NULL ) THEN
    p_x_route_operation_rec.step := l_old_route_operation_rec.step;
  END IF;

  IF ( p_x_route_operation_rec.check_point_flag = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.check_point_flag := null;
  ELSIF ( p_x_route_operation_rec.check_point_flag IS NULL ) THEN
    p_x_route_operation_rec.check_point_flag := l_old_route_operation_rec.check_point_flag;
  END IF;

  IF ( p_x_route_operation_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute_category := null;
  ELSIF ( p_x_route_operation_rec.attribute_category IS NULL ) THEN
    p_x_route_operation_rec.attribute_category := l_old_route_operation_rec.attribute_category;
  END IF;

  IF ( p_x_route_operation_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute1 := null;
  ELSIF ( p_x_route_operation_rec.attribute1 IS NULL ) THEN
    p_x_route_operation_rec.attribute1 := l_old_route_operation_rec.attribute1;
  END IF;

  IF ( p_x_route_operation_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute2 := null;
  ELSIF ( p_x_route_operation_rec.attribute2 IS NULL ) THEN
    p_x_route_operation_rec.attribute2 := l_old_route_operation_rec.attribute2;
  END IF;

  IF ( p_x_route_operation_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute3 := null;
  ELSIF ( p_x_route_operation_rec.attribute3 IS NULL ) THEN
    p_x_route_operation_rec.attribute3 := l_old_route_operation_rec.attribute3;
  END IF;

  IF ( p_x_route_operation_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute4 := null;
  ELSIF ( p_x_route_operation_rec.attribute4 IS NULL ) THEN
    p_x_route_operation_rec.attribute4 := l_old_route_operation_rec.attribute4;
  END IF;

  IF ( p_x_route_operation_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute5 := null;
  ELSIF ( p_x_route_operation_rec.attribute5 IS NULL ) THEN
    p_x_route_operation_rec.attribute5 := l_old_route_operation_rec.attribute5;
  END IF;

  IF ( p_x_route_operation_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute6 := null;
  ELSIF ( p_x_route_operation_rec.attribute6 IS NULL ) THEN
    p_x_route_operation_rec.attribute6 := l_old_route_operation_rec.attribute6;
  END IF;

  IF ( p_x_route_operation_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute7 := null;
  ELSIF ( p_x_route_operation_rec.attribute7 IS NULL ) THEN
    p_x_route_operation_rec.attribute7 := l_old_route_operation_rec.attribute7;
  END IF;

  IF ( p_x_route_operation_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute8 := null;
  ELSIF ( p_x_route_operation_rec.attribute8 IS NULL ) THEN
    p_x_route_operation_rec.attribute8 := l_old_route_operation_rec.attribute8;
  END IF;

  IF ( p_x_route_operation_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute9 := null;
  ELSIF ( p_x_route_operation_rec.attribute9 IS NULL ) THEN
    p_x_route_operation_rec.attribute9 := l_old_route_operation_rec.attribute9;
  END IF;

  IF ( p_x_route_operation_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute10 := null;
  ELSIF ( p_x_route_operation_rec.attribute10 IS NULL ) THEN
    p_x_route_operation_rec.attribute10 := l_old_route_operation_rec.attribute10;
  END IF;

  IF ( p_x_route_operation_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute11 := null;
  ELSIF ( p_x_route_operation_rec.attribute11 IS NULL ) THEN
    p_x_route_operation_rec.attribute11 := l_old_route_operation_rec.attribute11;
  END IF;

  IF ( p_x_route_operation_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute12 := null;
  ELSIF ( p_x_route_operation_rec.attribute12 IS NULL ) THEN
    p_x_route_operation_rec.attribute12 := l_old_route_operation_rec.attribute12;
  END IF;

  IF ( p_x_route_operation_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute13 := null;
  ELSIF ( p_x_route_operation_rec.attribute13 IS NULL ) THEN
    p_x_route_operation_rec.attribute13 := l_old_route_operation_rec.attribute13;
  END IF;

  IF ( p_x_route_operation_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute14 := null;
  ELSIF ( p_x_route_operation_rec.attribute14 IS NULL ) THEN
    p_x_route_operation_rec.attribute14 := l_old_route_operation_rec.attribute14;
  END IF;

  IF ( p_x_route_operation_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_operation_rec.attribute15 := null;
  ELSIF ( p_x_route_operation_rec.attribute15 IS NULL ) THEN
    p_x_route_operation_rec.attribute15 := l_old_route_operation_rec.attribute15;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual route_operations attributes
PROCEDURE validate_attributes
(
  p_route_operation_rec       IN    route_operation_rec_type,
  x_return_status             OUT NOCOPY   VARCHAR2
) IS

l_msg_data                    VARCHAR2(2000);
l_step                        NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the Operation is NULL
  IF ( ( p_route_operation_rec.dml_operation = 'C' AND
         p_route_operation_rec.operation_id IS NULL AND
         p_route_operation_rec.concatenated_segments IS NULL ) OR
       ( p_route_operation_rec.dml_operation <> 'D' AND
         p_route_operation_rec.operation_id = FND_API.G_MISS_NUM AND
         p_route_operation_rec.concatenated_segments = FND_API.G_MISS_CHAR ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_OPERATION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
    FND_MSG_PUB.add;
    --x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the Step is NULL
  -- Check if the Step Contains a positive value
  IF ( ( p_route_operation_rec.dml_operation = 'C' AND
         p_route_operation_rec.step IS NULL ) OR
       ( p_route_operation_rec.dml_operation <> 'D' AND
         p_route_operation_rec.step = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_STEP_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
    FND_MSG_PUB.add;
    --x_return_status := FND_API.G_RET_STS_ERROR;
  ELSIF ( p_route_operation_rec.dml_operation <> 'D' AND
          p_route_operation_rec.step <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_STEP_LESS_ZERO' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
    FND_MSG_PUB.add;
    --x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF ( p_route_operation_rec.step IS NOT NULL AND p_route_operation_rec.step <> FND_API.G_MISS_NUM ) THEN
    BEGIN
      SELECT TO_NUMBER( p_route_operation_rec.step, '999999999999999999999999999999' )
      INTO   l_step
      FROM   DUAL;
    EXCEPTION
      WHEN INVALID_NUMBER THEN
        FND_MESSAGE.set_name( 'AHL','AHL_RM_STEP_DECIMAL' );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
        FND_MSG_PUB.add;
       -- x_return_status := FND_API.G_RET_STS_ERROR;
    END;
  END IF;

  IF ( p_route_operation_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the mandatory route_operation_id column contains a null value.
  IF ( p_route_operation_rec.route_operation_id IS NULL OR
       p_route_operation_rec.route_operation_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RT_OPER_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
    FND_MSG_PUB.add;
    --x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_route_operation_rec.object_version_number IS NULL OR
       p_route_operation_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RTO_OBJ_VERSION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
    FND_MSG_PUB.add;
   -- x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_record
(
  p_route_id                  IN    NUMBER,
  p_route_operation_rec       IN    route_operation_rec_type,
  x_return_status             OUT NOCOPY   VARCHAR2
)
IS

l_dummy                VARCHAR2(1);
l_return_status        VARCHAR2(1);
l_msg_data             VARCHAR2(2000);
l_rt_time_span         NUMBER;
l_op_max_res_duration  NUMBER;

CURSOR get_active_operation ( c_operation_id NUMBER )
IS
SELECT          'X'
FROM            AHL_OPERATIONS_B
WHERE           operation_id = c_operation_id
AND             TRUNC( NVL( END_DATE_ACTIVE, SYSDATE + 1 ) ) > TRUNC( SYSDATE );

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_route_operation_rec.operation_id IS NOT NULL ) THEN

    -- Check if the Operation is Active
    OPEN get_active_operation( p_route_operation_rec.operation_id );

    FETCH get_active_operation INTO
      l_dummy;

    IF ( get_active_operation%NOTFOUND ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_OPERATION_INACTIVE' );

      IF ( p_route_operation_rec.concatenated_segments IS NULL ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_route_operation_rec.operation_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_route_operation_rec.concatenated_segments );
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
      FND_MSG_PUB.add;
      --x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE get_active_operation;

    -- Validate whether the longest Duration specified for the operation Resource is longer than associated Route Time Span.
    AHL_RM_ROUTE_UTIL.validate_rt_op_res_duration
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_route_id             => p_route_id,
      p_operation_id         => p_route_operation_rec.operation_id,
      x_rt_time_span         => l_rt_time_span,
      x_op_max_res_duration  => l_op_max_res_duration
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD1', l_op_max_res_duration );
      FND_MESSAGE.set_token( 'FIELD2', l_rt_time_span );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_route_operation_rec ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

END validate_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_route_id              IN    NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

CURSOR get_dup_rec ( c_route_id NUMBER )
IS
SELECT   step, concatenated_segments
FROM     AHL_ROUTE_OPERATIONS_V
WHERE    route_id = c_route_id
AND      NVL( end_date_active, SYSDATE + 1 ) > SYSDATE
ORDER BY step, concatenated_segments;

l_step                    NUMBER;
l_prev_step               NUMBER;
l_operation               AHL_ROUTE_OPERATIONS_V.concatenated_segments%TYPE;
l_prev_operation          AHL_ROUTE_OPERATIONS_V.concatenated_segments%TYPE;

BEGIN

  -- Check whether any duplicate route_operation records (based on step) for the given route_id
  OPEN  get_dup_rec( p_route_id );

  LOOP
    FETCH get_dup_rec INTO
      l_step,
      l_operation;

    EXIT WHEN get_dup_rec%NOTFOUND;

    IF ( l_prev_operation IS NOT NULL AND
         l_prev_step IS NOT NULL AND
         l_operation <> l_prev_operation AND
         l_step = l_prev_step ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STEP_DUP' );
      FND_MESSAGE.set_token( 'FIELD', to_char(l_step) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    l_prev_step := l_step;
    l_prev_operation := l_operation;

  END LOOP;

  CLOSE get_dup_rec;

END validate_records;

PROCEDURE process_route_operation_as
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2   := NULL,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 p_x_route_operation_tbl IN OUT NOCOPY route_operation_tbl_type,
 p_route_id              IN            NUMBER
)
IS

l_api_version    CONSTANT       NUMBER         := 1.0;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_route_operation_id            NUMBER;
l_x_route_rec               	AHL_RM_ROUTE_PVT.route_rec_type ;

cursor get_route_status (p_route_id in number)
is
select revision_status_code
from ahl_routes_app_v
where route_id = p_route_id;

l_route_status 			VARCHAR2(30);

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_route_operation_pvt;

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

-- This is to be added before calling   validate_api_inputs()
-- Validate Application Usage
  AHL_RM_ROUTE_UTIL.validate_ApplnUsage
  (
     p_object_id              => p_route_id,
     p_association_type       => 'ROUTE' ,
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
  validate_api_inputs
  (
    p_x_route_operation_tbl, -- IN
    p_route_id, -- IN
    l_return_status -- OUT
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Code added by Balaji to get operation_id if it is not provided from
  -- Operation_number and operation_revision.
  FOR i IN 1..p_x_route_operation_tbl.count LOOP
	  IF ( p_x_route_operation_tbl(i).operation_id IS NULL OR
	       p_x_route_operation_tbl(i).operation_id = FND_API.G_MISS_NUM )
	  THEN
		  -- Function to convert Operation number, operation revision to id
		  AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
		  (
		   p_operation_number		=>	p_x_route_operation_tbl(i).concatenated_segments,
		   p_operation_revision		=>	p_x_route_operation_tbl(i).revision_number,
		   x_operation_id		=>	p_x_route_operation_tbl(i).operation_id,
		   x_return_status		=>	x_return_status
		  );
		  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
			 fnd_log.string
			 (
			     fnd_log.level_statement,
			    'ahl.plsql.'||g_pkg_name||'.'||g_api_name||':',
			     'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
			 );
		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;
	  END IF;
  END LOOP;

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_route_operation_tbl.count LOOP
      IF ( p_x_route_operation_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_route_operation_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
    FOR i IN 1..p_x_route_operation_tbl.count LOOP
      IF ( p_x_route_operation_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_route_operation_tbl(i) , -- IN OUT Record with Values and Ids
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

    FOR i IN 1..p_x_route_operation_tbl.count LOOP
      IF ( p_x_route_operation_tbl(i).dml_operation = 'C' ) THEN
    p_x_route_operation_tbl(i).object_version_number := 1;
      END IF;
    END LOOP;
  -- Validate all attributes (Item level validation)

    FOR i IN 1..p_x_route_operation_tbl.count LOOP
      validate_attributes
      (
        p_x_route_operation_tbl(i), -- IN
        l_return_status -- OUT
      );

      /*
      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */
    END LOOP;
      	-- Check Error Message stack.
      	x_msg_count := FND_MSG_PUB.count_msg;
      	IF x_msg_count > 0
      	THEN
      		RAISE FND_API.G_EXC_ERROR;
      	END IF;


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_route_operation_tbl.count LOOP
    IF ( p_x_route_operation_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_route_operation_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_route_operation_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_route_operation_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)

    FOR i IN 1..p_x_route_operation_tbl.count LOOP
      IF ( p_x_route_operation_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_route_id, -- IN
          p_x_route_operation_tbl(i), -- IN
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


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_record' );
  END IF;

  -- Update route status from APPROVAL_REJECTED to DRAFT
  OPEN get_route_status (p_route_id);
  FETCH get_route_status INTO l_route_status;
  IF (get_route_status%FOUND AND l_route_status = 'APPROVAL_REJECTED')
  THEN
  	UPDATE ahl_routes_b
  	SET revision_status_code = 'DRAFT'
  	WHERE route_id = p_route_id;
  END IF;
  CLOSE get_route_status;

   -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_route_operation_tbl.count LOOP
    IF ( p_x_route_operation_tbl(i).dml_operation = 'C' ) THEN
      BEGIN
        -- Insert the record
        INSERT INTO AHL_ROUTE_OPERATIONS
        (
          ROUTE_OPERATION_ID,
          OBJECT_VERSION_NUMBER,
          ROUTE_ID,
          OPERATION_ID,
          STEP,
          CHECK_POINT_FLAG,
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
          AHL_ROUTE_OPERATIONS_S.NEXTVAL,
          p_x_route_operation_tbl(i).object_version_number,
          p_route_id,
          p_x_route_operation_tbl(i).operation_id,
          p_x_route_operation_tbl(i).step,
          p_x_route_operation_tbl(i).check_point_flag,
          p_x_route_operation_tbl(i).attribute_category,
          p_x_route_operation_tbl(i).attribute1,
          p_x_route_operation_tbl(i).attribute2,
          p_x_route_operation_tbl(i).attribute3,
          p_x_route_operation_tbl(i).attribute4,
          p_x_route_operation_tbl(i).attribute5,
          p_x_route_operation_tbl(i).attribute6,
          p_x_route_operation_tbl(i).attribute7,
          p_x_route_operation_tbl(i).attribute8,
          p_x_route_operation_tbl(i).attribute9,
          p_x_route_operation_tbl(i).attribute10,
          p_x_route_operation_tbl(i).attribute11,
          p_x_route_operation_tbl(i).attribute12,
          p_x_route_operation_tbl(i).attribute13,
          p_x_route_operation_tbl(i).attribute14,
          p_x_route_operation_tbl(i).attribute15,
          G_LAST_UPDATE_DATE,
	  G_LAST_UPDATED_BY,
	  G_CREATION_DATE,
	  G_CREATED_BY,
	  G_LAST_UPDATE_LOGIN
        ) RETURNING route_operation_id INTO l_route_operation_id;

        -- Set OUT values
        p_x_route_operation_tbl(i).route_operation_id := l_route_operation_id;
      EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STEP_DUP' );
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_token( 'FIELD', 'INSERT : ' || to_char(p_x_route_operation_tbl(i).step) );
          ELSE
            FND_MESSAGE.set_token( 'FIELD', 'OTHER : ' || to_char(p_x_route_operation_tbl(i).step) );
          	IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
	    	THEN
	    		fnd_log.string
	    	  	(
	    			fnd_log.level_unexpected,
	    			'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME,
	    			'AHL_OPERATIONS_B insert error = ['||SQLERRM||']'
	    		);
		END IF;
          END IF;
            FND_MSG_PUB.add;

         END;

    ELSIF ( p_x_route_operation_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_ROUTE_OPERATIONS SET
          object_version_number   = object_version_number + 1,
          operation_id            = p_x_route_operation_tbl(i).operation_id,
          step                    = p_x_route_operation_tbl(i).step,
          check_point_flag        = p_x_route_operation_tbl(i).check_point_flag,
          attribute_category      = p_x_route_operation_tbl(i).attribute_category,
          attribute1              = p_x_route_operation_tbl(i).attribute1,
          attribute2              = p_x_route_operation_tbl(i).attribute2,
          attribute3              = p_x_route_operation_tbl(i).attribute3,
          attribute4              = p_x_route_operation_tbl(i).attribute4,
          attribute5              = p_x_route_operation_tbl(i).attribute5,
          attribute6              = p_x_route_operation_tbl(i).attribute6,
          attribute7              = p_x_route_operation_tbl(i).attribute7,
          attribute8              = p_x_route_operation_tbl(i).attribute8,
          attribute9              = p_x_route_operation_tbl(i).attribute9,
          attribute10             = p_x_route_operation_tbl(i).attribute10,
          attribute11             = p_x_route_operation_tbl(i).attribute11,
          attribute12             = p_x_route_operation_tbl(i).attribute12,
          attribute13             = p_x_route_operation_tbl(i).attribute13,
          attribute14             = p_x_route_operation_tbl(i).attribute14,
          attribute15             = p_x_route_operation_tbl(i).attribute15,
          last_update_date        = G_LAST_UPDATE_DATE,
          last_updated_by         = G_LAST_UPDATED_BY,
          last_update_login       = G_LAST_UPDATE_LOGIN
        WHERE route_operation_id   = p_x_route_operation_tbl(i).route_operation_id
        AND object_version_number = p_x_route_operation_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_route_operation_tbl(i) ) );
          FND_MSG_PUB.add;
        --  x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Set OUT values
        p_x_route_operation_tbl(i).object_version_number := p_x_route_operation_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STEP_DUP' );
            FND_MESSAGE.set_token( 'FIELD', to_char(p_x_route_operation_tbl(i).step) );
            FND_MSG_PUB.add;
          --  x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END;

    ELSIF ( p_x_route_operation_tbl(i).dml_operation = 'D' ) THEN
      -- Delete the record
      DELETE FROM AHL_ROUTE_OPERATIONS
      WHERE route_operation_id   = p_x_route_operation_tbl(i).route_operation_id
      AND object_version_number = p_x_route_operation_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', to_char(i) );
        FND_MSG_PUB.add;
        --x_return_status := FND_API.G_RET_STS_ERROR;
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
/*
  validate_records
  (
    p_route_id, -- IN
    l_return_status -- OUT
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
*/

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_records ' || p_route_id );
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
    ROLLBACK TO process_route_operation_pvt;
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
    ROLLBACK TO process_route_operation_pvt;
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
    ROLLBACK TO process_route_operation_pvt;
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

END process_route_operation_as;

END AHL_RM_OP_ROUTE_AS_PVT;

/
