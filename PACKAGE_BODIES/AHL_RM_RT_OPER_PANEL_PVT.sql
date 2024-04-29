--------------------------------------------------------
--  DDL for Package Body AHL_RM_RT_OPER_PANEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_RT_OPER_PANEL_PVT" AS
/* $Header: AHLVRAPB.pls 120.0.12000000.1 2007/10/18 13:45:11 adivenka noship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_RT_OPER_PANEL_PVT';
G_API_NAME1 VARCHAR2(30) := 'process_rt_oper_panel';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

-- constants for WHO Columns
G_LAST_UPDATE_DATE 	DATE 		:= SYSDATE;
G_LAST_UPDATED_BY 	NUMBER(15) 	:= FND_GLOBAL.user_id;
G_LAST_UPDATE_LOGIN 	NUMBER(15) 	:= FND_GLOBAL.login_id;
G_CREATION_DATE 	DATE 		:= SYSDATE;
G_CREATED_BY 		NUMBER(15) 	:= FND_GLOBAL.user_id;

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_rt_oper_panel_rec       IN    rt_oper_panel_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN

    IF ( p_rt_oper_panel_rec.panel_type IS NOT NULL AND
         p_rt_oper_panel_rec.panel_type <> FND_API.G_MISS_CHAR ) THEN
      l_record_identifier := l_record_identifier || p_rt_oper_panel_rec.panel_type;
    END IF;

    l_record_identifier := l_record_identifier;

    RETURN l_record_identifier;

END get_record_identifier;

-- Procedure to validate the all the inputs except the table structure of the API
PROCEDURE validate_api_inputs
(
  p_rt_oper_panel_tbl    IN   rt_oper_panel_tbl_type,
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

  -- Check if at least one record is passed in p_rt_oper_panel_tbl
  IF ( p_rt_oper_panel_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME1 );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_rt_oper_panel_tbl.count LOOP
    IF ( p_rt_oper_panel_tbl(i).dml_operation IS NULL OR
    	 (
    	   p_rt_oper_panel_tbl(i).dml_operation <> 'C' AND
           p_rt_oper_panel_tbl(i).dml_operation <> 'U' AND
           p_rt_oper_panel_tbl(i).dml_operation <> 'D'
         )
       )
    THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML_REC' );
      FND_MESSAGE.set_token( 'FIELD', p_rt_oper_panel_tbl(i).dml_operation );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_rt_oper_panel_rec       IN OUT NOCOPY  rt_oper_panel_rec_type
)
IS

BEGIN
  IF ( p_x_rt_oper_panel_rec.panel_type IS NULL ) THEN
    p_x_rt_oper_panel_rec.panel_type_id := NULL;
  ELSIF ( p_x_rt_oper_panel_rec.panel_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.panel_type_id := FND_API.G_MISS_CHAR;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion and validation for LOV attributes
PROCEDURE convert_values_to_ids
(
  p_x_rt_oper_panel_rec  IN OUT NOCOPY  rt_oper_panel_rec_type,
  x_return_status           OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate panel_type_id
  IF ( ( p_x_rt_oper_panel_rec.panel_type_id IS NOT NULL AND
         p_x_rt_oper_panel_rec.panel_type_id <> FND_API.G_MISS_CHAR ) OR
       ( p_x_rt_oper_panel_rec.panel_type IS NOT NULL AND
         p_x_rt_oper_panel_rec.panel_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_lookup_type            => 'AHL_RM_ACCESS_PANELS',
      p_lookup_meaning         => p_x_rt_oper_panel_rec.panel_type,
      p_x_lookup_code          => p_x_rt_oper_panel_rec.panel_type_id
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PANEL_TYPE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_PANEL_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_rt_oper_panel_rec.panel_type IS NULL OR
           p_x_rt_oper_panel_rec.panel_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_rt_oper_panel_rec.panel_type_id ) );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_rt_oper_panel_rec.panel_type );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;

 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_rt_oper_panel_rec       IN OUT NOCOPY   rt_oper_panel_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_rt_oper_panel_rec.panel_type_id = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.panel_type_id := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.panel_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.panel_type := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute_category := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute1 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute2 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute3 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute4 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute5 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute6 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute7 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute8 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute9 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute10 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute11 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute12 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute13 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute14 := null;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute15 := null;
  END IF;

END default_missing_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_rt_oper_panel_rec       IN OUT NOCOPY   rt_oper_panel_rec_type
)
IS

l_old_rt_oper_panel_rec       rt_oper_panel_rec_type;

CURSOR get_old_rec ( c_rt_oper_panel_id NUMBER )
IS
SELECT  panel_type_id,
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
FROM    AHL_RT_OPER_ACCESS_PANELS
WHERE   rt_oper_panel_id = c_rt_oper_panel_id;

BEGIN

  -- Get the old record from AHL_RT_OPER_ACCESS_PANELS.
  OPEN  get_old_rec( p_x_rt_oper_panel_rec.rt_oper_panel_id );

  FETCH get_old_rec INTO
        l_old_rt_oper_panel_rec.panel_type_id,
        l_old_rt_oper_panel_rec.attribute_category,
        l_old_rt_oper_panel_rec.attribute1,
        l_old_rt_oper_panel_rec.attribute2,
        l_old_rt_oper_panel_rec.attribute3,
        l_old_rt_oper_panel_rec.attribute4,
        l_old_rt_oper_panel_rec.attribute5,
        l_old_rt_oper_panel_rec.attribute6,
        l_old_rt_oper_panel_rec.attribute7,
        l_old_rt_oper_panel_rec.attribute8,
        l_old_rt_oper_panel_rec.attribute9,
        l_old_rt_oper_panel_rec.attribute10,
        l_old_rt_oper_panel_rec.attribute11,
        l_old_rt_oper_panel_rec.attribute12,
        l_old_rt_oper_panel_rec.attribute13,
        l_old_rt_oper_panel_rec.attribute14,
        l_old_rt_oper_panel_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PANEL_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_panel_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_rt_oper_panel_rec.panel_type_id = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.panel_type_id := null;
  ELSIF ( p_x_rt_oper_panel_rec.panel_type_id IS NULL ) THEN
    p_x_rt_oper_panel_rec.panel_type_id := l_old_rt_oper_panel_rec.panel_type_id;
  END IF;

  IF ( p_x_rt_oper_panel_rec.panel_type = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.panel_type := null;
  ELSIF ( p_x_rt_oper_panel_rec.panel_type IS NULL ) THEN
    p_x_rt_oper_panel_rec.panel_type := l_old_rt_oper_panel_rec.panel_type;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute_category := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute_category IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute_category := l_old_rt_oper_panel_rec.attribute_category;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute1 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute1 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute1 := l_old_rt_oper_panel_rec.attribute1;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute2 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute2 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute2 := l_old_rt_oper_panel_rec.attribute2;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute3 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute3 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute3 := l_old_rt_oper_panel_rec.attribute3;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute4 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute4 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute4 := l_old_rt_oper_panel_rec.attribute4;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute5 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute5 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute5 := l_old_rt_oper_panel_rec.attribute5;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute6 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute6 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute6 := l_old_rt_oper_panel_rec.attribute6;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute7 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute7 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute7 := l_old_rt_oper_panel_rec.attribute7;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute8 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute8 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute8 := l_old_rt_oper_panel_rec.attribute8;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute9 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute9 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute9 := l_old_rt_oper_panel_rec.attribute9;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute10 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute10 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute10 := l_old_rt_oper_panel_rec.attribute10;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute11 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute11 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute11 := l_old_rt_oper_panel_rec.attribute11;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute12 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute12 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute12 := l_old_rt_oper_panel_rec.attribute12;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute13 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute13 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute13 := l_old_rt_oper_panel_rec.attribute13;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute14 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute14 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute14 := l_old_rt_oper_panel_rec.attribute14;
  END IF;

  IF ( p_x_rt_oper_panel_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_rt_oper_panel_rec.attribute15 := null;
  ELSIF ( p_x_rt_oper_panel_rec.attribute15 IS NULL ) THEN
    p_x_rt_oper_panel_rec.attribute15 := l_old_rt_oper_panel_rec.attribute15;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual rt_oper_panel attributes
PROCEDURE validate_attributes
(
  p_object_id             IN    NUMBER,
  p_association_type_code IN    VARCHAR2,
  p_rt_oper_panel_rec  IN    rt_oper_panel_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

  l_return_status        VARCHAR2(1);
  l_msg_count			 NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_max_rt_time_span     NUMBER;
  l_dummy                VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( p_rt_oper_panel_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_rt_oper_panel_rec.object_version_number IS NULL OR
       p_rt_oper_panel_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_PANEL_VERSION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_panel_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory rt_oper_panel ID column contains a null value.
  IF ( p_rt_oper_panel_rec.rt_oper_panel_id IS NULL OR
       p_rt_oper_panel_rec.rt_oper_panel_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RT_OPER_PANEL_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_rt_oper_panel_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


END validate_attributes;

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
SELECT   panel_type_id,
         panel_type
FROM     AHL_RT_OPER_ACCESS_PANELS_V
WHERE    object_id = c_object_id
AND      association_type_code = c_association_type_code
GROUP BY panel_type_id,
         panel_type
HAVING   count(*) > 1;

l_rt_oper_panel_rec      rt_oper_panel_rec_type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check whether any duplicate rt_oper_panel records for the given object_ID
  OPEN  get_dup_rec( p_object_id, p_association_type_code );

  LOOP
    FETCH get_dup_rec INTO
      l_rt_oper_panel_rec.panel_type_id,
      l_rt_oper_panel_rec.panel_type;

    EXIT WHEN get_dup_rec%NOTFOUND;
  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_PANEL_DUP' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_rt_oper_panel_rec ) );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

END validate_records;

PROCEDURE process_rt_oper_panel
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
  p_x_rt_oper_panel_tbl  IN OUT NOCOPY rt_oper_panel_tbl_type,
  p_association_type_code   IN       VARCHAR2,
  p_object_id          IN            NUMBER
)
IS

cursor get_route_status (p_route_id in number)
is
select revision_status_code
from ahl_routes_app_v
where route_id = p_route_id;

l_obj_status 			VARCHAR2(30);

cursor get_oper_status (p_operation_id in number)
is
select revision_status_code
from ahl_operations_b
where operation_id = p_operation_id;

l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data			VARCHAR2(2000);
l_rt_oper_panel_id       NUMBER;
l_x_operation_rec           AHL_RM_OPERATION_PVT.operation_rec_type ;
l_x_route_rec               AHL_RM_ROUTE_PVT.route_rec_type ;
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_rt_oper_panel_pvt;

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
    p_x_rt_oper_panel_tbl,
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
    FOR i IN 1..p_x_rt_oper_panel_tbl.count LOOP
      IF ( p_x_rt_oper_panel_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_rt_oper_panel_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_rt_oper_panel_tbl.count LOOP
      IF ( p_x_rt_oper_panel_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_rt_oper_panel_tbl(i) , -- IN OUT Record with Values and Ids
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

  -- Default rt_oper_panel attributes.
  /* Removed as a part of public API cleanup in 11510+.
  IF FND_API.to_boolean( p_default ) THEN
    FOR i IN 1..p_x_rt_oper_panel_tbl.count LOOP
      IF ( p_x_rt_oper_panel_tbl(i).dml_operation <> 'D' ) THEN
        default_attributes
        (
          p_x_rt_oper_panel_tbl(i) -- IN OUT
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
    FOR i IN 1..p_x_rt_oper_panel_tbl.count LOOP
      validate_attributes
      (
        p_object_id, -- IN
        p_association_type_code, -- IN
        p_x_rt_oper_panel_tbl(i), -- IN
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
  FOR i IN 1..p_x_rt_oper_panel_tbl.count LOOP
    IF ( p_x_rt_oper_panel_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_rt_oper_panel_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_rt_oper_panel_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_rt_oper_panel_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME1 || ' :  after default_unchanged_attributes / default_missing_attributes' );
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
  FOR i IN 1..p_x_rt_oper_panel_tbl.count LOOP
    IF ( p_x_rt_oper_panel_tbl(i).dml_operation = 'C' ) THEN

      BEGIN
        -- Insert the record
        INSERT INTO AHL_RT_OPER_ACCESS_PANELS
        (
          rt_oper_panel_id,
          OBJECT_VERSION_NUMBER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          association_type_code,
          object_ID,
          panel_type_id,
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
          AHL_RT_OPER_ACCESS_PANELS_S.NEXTVAL,
          1,
          G_LAST_UPDATE_DATE,
          G_LAST_UPDATED_BY,
          G_CREATION_DATE,
          G_CREATED_BY,
          G_LAST_UPDATE_LOGIN,
          p_association_type_code,
          p_object_id,
          p_x_rt_oper_panel_tbl(i).panel_type_id,
          p_x_rt_oper_panel_tbl(i).attribute_category,
          p_x_rt_oper_panel_tbl(i).attribute1,
          p_x_rt_oper_panel_tbl(i).attribute2,
          p_x_rt_oper_panel_tbl(i).attribute3,
          p_x_rt_oper_panel_tbl(i).attribute4,
          p_x_rt_oper_panel_tbl(i).attribute5,
          p_x_rt_oper_panel_tbl(i).attribute6,
          p_x_rt_oper_panel_tbl(i).attribute7,
          p_x_rt_oper_panel_tbl(i).attribute8,
          p_x_rt_oper_panel_tbl(i).attribute9,
          p_x_rt_oper_panel_tbl(i).attribute10,
          p_x_rt_oper_panel_tbl(i).attribute11,
          p_x_rt_oper_panel_tbl(i).attribute12,
          p_x_rt_oper_panel_tbl(i).attribute13,
          p_x_rt_oper_panel_tbl(i).attribute14,
          p_x_rt_oper_panel_tbl(i).attribute15
        ) RETURNING rt_oper_panel_id INTO l_rt_oper_panel_id;

        -- Set OUT values
        p_x_rt_oper_panel_tbl(i).rt_oper_panel_id := l_rt_oper_panel_id;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_PANEL_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_x_rt_oper_panel_tbl(i) ) );
            FND_MSG_PUB.add;
          ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_unexpected,
			'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME1,
			'AHL_RT_OPER_ACCESS_PANELS insert error = ['||SQLERRM||']'
		);
	      END IF;
          END IF;
      END;

    ELSIF ( p_x_rt_oper_panel_tbl(i).dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        UPDATE AHL_RT_OPER_ACCESS_PANELS SET
          object_version_number   = object_version_number + 1,
          last_update_date        = G_LAST_UPDATE_DATE,
          last_updated_by         = G_LAST_UPDATED_BY,
          last_update_login       = G_LAST_UPDATE_LOGIN,
          panel_type_id           = p_x_rt_oper_panel_tbl(i).panel_type_id,
          attribute_category      = p_x_rt_oper_panel_tbl(i).attribute_category,
          attribute1              = p_x_rt_oper_panel_tbl(i).attribute1,
          attribute2              = p_x_rt_oper_panel_tbl(i).attribute2,
          attribute3              = p_x_rt_oper_panel_tbl(i).attribute3,
          attribute4              = p_x_rt_oper_panel_tbl(i).attribute4,
          attribute5              = p_x_rt_oper_panel_tbl(i).attribute5,
          attribute6              = p_x_rt_oper_panel_tbl(i).attribute6,
          attribute7              = p_x_rt_oper_panel_tbl(i).attribute7,
          attribute8              = p_x_rt_oper_panel_tbl(i).attribute8,
          attribute9              = p_x_rt_oper_panel_tbl(i).attribute9,
          attribute10             = p_x_rt_oper_panel_tbl(i).attribute10,
          attribute11             = p_x_rt_oper_panel_tbl(i).attribute11,
          attribute12             = p_x_rt_oper_panel_tbl(i).attribute12,
          attribute13             = p_x_rt_oper_panel_tbl(i).attribute13,
          attribute14             = p_x_rt_oper_panel_tbl(i).attribute14,
          attribute15             = p_x_rt_oper_panel_tbl(i).attribute15
        WHERE rt_oper_panel_id = p_x_rt_oper_panel_tbl(i).rt_oper_panel_id
        AND object_version_number = p_x_rt_oper_panel_tbl(i).object_version_number;

        -- If the record does not exist, then, abort API.
        IF ( SQL%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.set_name('AHL','AHL_RM_RECORD_CHANGED');
          FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_panel_tbl(i) ) );
          FND_MSG_PUB.add;
        END IF;

        -- Set OUT values
        p_x_rt_oper_panel_tbl(i).object_version_number := p_x_rt_oper_panel_tbl(i).object_version_number + 1;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_OPER_PANEL_DUP' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_rt_oper_panel_tbl(i) ) );
            FND_MSG_PUB.add;
          ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_unexpected,
			'ahl.plsql.'||G_PKG_NAME||'.'||G_API_NAME1,
			'AHL_RT_OPER_ACCESS_PANELS update error = ['||SQLERRM||']'
		);
	      END IF;
          END IF;
      END;

    ELSIF ( p_x_rt_oper_panel_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE FROM AHL_RT_OPER_ACCESS_PANELS
      WHERE rt_oper_panel_id = p_x_rt_oper_panel_tbl(i).rt_oper_panel_id
      AND object_version_number = p_x_rt_oper_panel_tbl(i).object_version_number;

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
    ROLLBACK TO process_rt_oper_panel_PVT;
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
    ROLLBACK TO process_rt_oper_panel_PVT;
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
    ROLLBACK TO process_rt_oper_panel_PVT;
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

END process_rt_oper_panel;

END AHL_RM_RT_OPER_PANEL_PVT;

/
