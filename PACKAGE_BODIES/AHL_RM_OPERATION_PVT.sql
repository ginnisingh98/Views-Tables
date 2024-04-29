--------------------------------------------------------
--  DDL for Package Body AHL_RM_OPERATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_OPERATION_PVT" AS
/* $Header: AHLVOPEB.pls 120.4.12010000.5 2010/02/15 09:40:20 pekambar ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_OPERATION_PVT';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');
G_API_NAME VARCHAR2(30) := 'PROCESS_OPERATION';
-- constants for WHO Columns
-- Added by Prithwi as a part of Public API cleanup

G_LAST_UPDATE_DATE  DATE    := SYSDATE;
G_LAST_UPDATED_BY   NUMBER(15)  := FND_GLOBAL.user_id;
G_LAST_UPDATE_LOGIN   NUMBER(15)  := FND_GLOBAL.login_id;
G_CREATION_DATE   DATE    := SYSDATE;
G_CREATED_BY    NUMBER(15)  := FND_GLOBAL.user_id;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_operation_rec           IN   operation_rec_type,
  x_return_status           OUT NOCOPY  VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate DML Operation
  IF ( p_operation_rec.dml_operation <> 'C' AND
       p_operation_rec.dml_operation <> 'U' ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML_REC' );
    FND_MESSAGE.set_token( 'FIELD', p_operation_rec.dml_operation );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_operation_rec       IN OUT NOCOPY  operation_rec_type
)
IS

BEGIN

  IF ( p_x_operation_rec.process IS NULL ) THEN
    p_x_operation_rec.process_code := NULL;
  ELSIF ( p_x_operation_rec.process = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.process_code := FND_API.G_MISS_CHAR;
  END IF;
  --bachandr Enigma Phase I changes -- start
  IF ( p_x_operation_rec.model_meaning IS NULL ) THEN
    p_x_operation_rec.model_code := NULL;
  ELSIF ( p_x_operation_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.model_code := FND_API.G_MISS_CHAR;
  END IF;
  --bachandr Enigma Phase I changes -- end
  IF ( p_x_operation_rec.qa_inspection_type_desc IS NULL ) THEN
    p_x_operation_rec.qa_inspection_type := NULL;
  ELSIF ( p_x_operation_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.qa_inspection_type := FND_API.G_MISS_CHAR;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_operation_rec         IN OUT NOCOPY  operation_rec_type,
  x_return_status           OUT NOCOPY            VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Operation Type
  IF ( ( p_x_operation_rec.operation_type_code IS NOT NULL AND
         p_x_operation_rec.operation_type_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_operation_rec.operation_type IS NOT NULL AND
         p_x_operation_rec.operation_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_lookup_type          => 'AHL_OPERATION_TYPE',
      p_lookup_meaning       => p_x_operation_rec.operation_type,
      p_x_lookup_code        => p_x_operation_rec.operation_type_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_OPER_TYPE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_OPER_TYPES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_operation_rec.operation_type IS NULL OR
           p_x_operation_rec.operation_type = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.operation_type_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.operation_type );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Process
  IF ( ( p_x_operation_rec.process_code IS NOT NULL AND
         p_x_operation_rec.process_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_operation_rec.process IS NOT NULL AND
         p_x_operation_rec.process <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_lookup_type          => 'AHL_PROCESS_CODE',
      p_lookup_meaning       => p_x_operation_rec.process,
      p_x_lookup_code        => p_x_operation_rec.process_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PROCESS' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_PROCESSES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_operation_rec.process IS NULL OR
           p_x_operation_rec.process = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.process_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.process );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;
    --bachandr Enigma Phase I changes -- start
    -- Convert / Validate Model
  IF ( ( p_x_operation_rec.model_code IS NOT NULL AND
         p_x_operation_rec.model_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_operation_rec.model_meaning IS NOT NULL AND
         p_x_operation_rec.model_meaning <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_lookup_type          => 'AHL_ENIGMA_MODEL_CODE',
      p_lookup_meaning       => p_x_operation_rec.model_meaning,
      p_x_lookup_code        => p_x_operation_rec.model_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_CM_INVALID_MODEL' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_CM_TOO_MANY_MODELS' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_operation_rec.model_meaning IS NULL OR
           p_x_operation_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.model_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.model_meaning );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;
    --bachandr Enigma Phase I changes -- end
   -- Convert / Validate QA Plan
  IF ( ( p_x_operation_rec.qa_inspection_type_desc IS NOT NULL AND
         p_x_operation_rec.qa_inspection_type_desc <> FND_API.G_MISS_CHAR ) OR
       ( p_x_operation_rec.qa_inspection_type IS NOT NULL AND
         p_x_operation_rec.qa_inspection_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_qa_inspection_type
    (
      x_return_status           => l_return_status,
      x_msg_data                => l_msg_data,
      p_qa_inspection_type_desc => p_x_operation_rec.qa_inspection_type_desc,
      p_x_qa_inspection_type    => p_x_operation_rec.qa_inspection_type
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_operation_rec.qa_inspection_type_desc IS NULL OR
           p_x_operation_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.qa_inspection_type );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.qa_inspection_type_desc );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Revision Status
  IF ( ( p_x_operation_rec.revision_status_code IS NOT NULL AND
         p_x_operation_rec.revision_status_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_operation_rec.revision_status IS NOT NULL AND
         p_x_operation_rec.revision_status <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_lookup_type          => 'AHL_REVISION_STATUS',
      p_lookup_meaning       => p_x_operation_rec.revision_status,
      p_x_lookup_code        => p_x_operation_rec.revision_status_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_STATUS' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_STATUSES' );
      ELSE
        FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_operation_rec.revision_status IS NULL OR
           p_x_operation_rec.revision_status = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.revision_status_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_operation_rec.revision_status );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;


 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_operation_rec       IN OUT NOCOPY   operation_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_operation_rec.operation_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.operation_type_code := null;
  END IF;

  IF ( p_x_operation_rec.operation_type = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.operation_type := null;
  END IF;

  IF ( p_x_operation_rec.process_code = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.process_code := null;
  END IF;

  IF ( p_x_operation_rec.process = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.process := null;
  END IF;
  --bachandr Enigma Phase I changes -- start
  IF ( p_x_operation_rec.model_code = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.model_code := null;
  END IF;

  IF ( p_x_operation_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.model_meaning := null;
  END IF;

  IF ( p_x_operation_rec.enigma_op_id = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.enigma_op_id := null;
  END IF;
  --bachandr Enigma Phase I changes -- end
  IF ( p_x_operation_rec.qa_inspection_type = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.qa_inspection_type := null;
  END IF;

  IF ( p_x_operation_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.qa_inspection_type_desc := null;
  END IF;

  IF ( p_x_operation_rec.remarks = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.remarks := null;
  END IF;

  IF ( p_x_operation_rec.revision_notes = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.revision_notes := null;
  END IF;

  IF ( p_x_operation_rec.segment1 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment1 := null;
  END IF;

  IF ( p_x_operation_rec.segment2 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment2 := null;
  END IF;

  IF ( p_x_operation_rec.segment3 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment3 := null;
  END IF;

  IF ( p_x_operation_rec.segment4 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment4 := null;
  END IF;

  IF ( p_x_operation_rec.segment5 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment5 := null;
  END IF;

  IF ( p_x_operation_rec.segment6 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment6 := null;
  END IF;

  IF ( p_x_operation_rec.segment7 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment7 := null;
  END IF;

  IF ( p_x_operation_rec.segment8 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment8 := null;
  END IF;

  IF ( p_x_operation_rec.segment9 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment9 := null;
  END IF;

  IF ( p_x_operation_rec.segment10 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment10 := null;
  END IF;

  IF ( p_x_operation_rec.segment11 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment11 := null;
  END IF;

  IF ( p_x_operation_rec.segment12 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment12 := null;
  END IF;

  IF ( p_x_operation_rec.segment13 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment13 := null;
  END IF;

  IF ( p_x_operation_rec.segment14 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment14 := null;
  END IF;

  IF ( p_x_operation_rec.segment15 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment15 := null;
  END IF;

  IF ( p_x_operation_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute_category := null;
  END IF;

  IF ( p_x_operation_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute1 := null;
  END IF;

  IF ( p_x_operation_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute2 := null;
  END IF;

  IF ( p_x_operation_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute3 := null;
  END IF;

  IF ( p_x_operation_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute4 := null;
  END IF;

  IF ( p_x_operation_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute5 := null;
  END IF;

  IF ( p_x_operation_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute6 := null;
  END IF;

  IF ( p_x_operation_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute7 := null;
  END IF;

  IF ( p_x_operation_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute8 := null;
  END IF;

  IF ( p_x_operation_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute9 := null;
  END IF;

  IF ( p_x_operation_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute10 := null;
  END IF;

  IF ( p_x_operation_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute11 := null;
  END IF;

  IF ( p_x_operation_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute12 := null;
  END IF;

  IF ( p_x_operation_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute13 := null;
  END IF;

  IF ( p_x_operation_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute14 := null;
  END IF;

  IF ( p_x_operation_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute15 := null;
  END IF;

END default_missing_attributes;

-- Procedure to get the Operation Record for a given operation_id
PROCEDURE get_operation_record
(
  x_return_status         OUT NOCOPY      VARCHAR2,
  x_msg_data              OUT NOCOPY      VARCHAR2,
  p_operation_id          IN              NUMBER,
  p_object_version_number IN              NUMBER,
  x_operation_rec         OUT NOCOPY      operation_rec_type
)
IS

CURSOR get_old_rec ( c_operation_id NUMBER )
IS
SELECT  object_version_number,
        standard_operation_flag,
        revision_number,
        revision_status_code,
        revision_status,
        start_date_active,
        end_date_active,
        operation_type_code,
        operation_type,
        process_code,
        process,
        --bachandr Enigma Phase I changes -- start
        model_code,
        model_meaning,
        enigma_op_id,
        --bachandr Enigma Phase I changes -- end
        qa_inspection_type,
        qa_inspection_type_desc,
        description,
        remarks,
        revision_notes,
        segment1,
        segment2,
        segment3,
        segment4,
        segment5,
        segment6,
        segment7,
        segment8,
        segment9,
        segment10,
        segment11,
        segment12,
        segment13,
        segment14,
        segment15,
        concatenated_segments,
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
FROM    AHL_OPERATIONS_V
WHERE   operation_id = c_operation_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the old record from AHL_OPERATIONS_V.
  OPEN  get_old_rec( p_operation_id );

  FETCH get_old_rec INTO
        x_operation_rec.object_version_number,
        x_operation_rec.standard_operation_flag,
        x_operation_rec.revision_number,
        x_operation_rec.revision_status_code,
        x_operation_rec.revision_status,
        x_operation_rec.active_start_date,
        x_operation_rec.active_end_date,
        x_operation_rec.operation_type_code,
        x_operation_rec.operation_type,
        x_operation_rec.process_code,
        x_operation_rec.process,
        --bachandr Enigma Phase I changes -- start
        x_operation_rec.model_code,
        x_operation_rec.model_meaning,
        x_operation_rec.enigma_op_id,
        --bachandr Enigma Phase I changes -- end
        x_operation_rec.qa_inspection_type,
        x_operation_rec.qa_inspection_type_desc,
        x_operation_rec.description,
        x_operation_rec.remarks,
        x_operation_rec.revision_notes,
        x_operation_rec.segment1,
        x_operation_rec.segment2,
        x_operation_rec.segment3,
        x_operation_rec.segment4,
        x_operation_rec.segment5,
        x_operation_rec.segment6,
        x_operation_rec.segment7,
        x_operation_rec.segment8,
        x_operation_rec.segment9,
        x_operation_rec.segment10,
        x_operation_rec.segment11,
        x_operation_rec.segment12,
        x_operation_rec.segment13,
        x_operation_rec.segment14,
        x_operation_rec.segment15,
        x_operation_rec.concatenated_segments,
        x_operation_rec.attribute_category,
        x_operation_rec.attribute1,
        x_operation_rec.attribute2,
        x_operation_rec.attribute3,
        x_operation_rec.attribute4,
        x_operation_rec.attribute5,
        x_operation_rec.attribute6,
        x_operation_rec.attribute7,
        x_operation_rec.attribute8,
        x_operation_rec.attribute9,
        x_operation_rec.attribute10,
        x_operation_rec.attribute11,
        x_operation_rec.attribute12,
        x_operation_rec.attribute13,
        x_operation_rec.attribute14,
        x_operation_rec.attribute15;

  IF ( get_old_rec%NOTFOUND ) THEN
    x_msg_data := 'AHL_RM_INVALID_OPERATION';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( x_operation_rec.object_version_number <> p_object_version_number ) THEN
    x_msg_data := 'AHL_COM_RECORD_CHANGED';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_old_rec;

END get_operation_record;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_operation_rec       IN OUT NOCOPY   operation_rec_type
)
IS

l_old_operation_rec operation_rec_type;
l_read_only_flag    VARCHAR2(1);
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(1);

BEGIN

  get_operation_record
  (
    x_return_status         => l_return_status,
    x_msg_data              => l_msg_data,
    p_operation_id          => p_x_operation_rec.operation_id,
    p_object_version_number => p_x_operation_rec.object_version_number,
    x_operation_rec         => l_old_operation_rec
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Convert G_MISS values to NULL and NULL values to Old values



  IF ( p_x_operation_rec.revision_status_code IS NULL ) THEN
    IF ( l_old_operation_rec.revision_status_code = 'APPROVAL_REJECTED' ) THEN
      p_x_operation_rec.revision_status_code := 'DRAFT';
    ELSE
      p_x_operation_rec.revision_status_code := l_old_operation_rec.revision_status_code;
    END IF;
    -- Validation added during 11.5.10 public api changes
  ELSIF p_x_operation_rec.revision_status_code <> l_old_operation_rec.revision_status_code THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STATUS_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_operation_rec.revision_status IS NULL ) THEN
    p_x_operation_rec.revision_status := l_old_operation_rec.revision_status;
  ELSIF p_x_operation_rec.revision_status <> l_old_operation_rec.revision_status THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STATUS_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_operation_rec.revision_number IS NULL ) THEN
    p_x_operation_rec.revision_number := l_old_operation_rec.revision_number;
  ELSIF p_x_operation_rec.revision_number <> l_old_operation_rec.revision_number THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_REVISION_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_operation_rec.concatenated_segments IS NULL ) THEN
    p_x_operation_rec.concatenated_segments := l_old_operation_rec.concatenated_segments;
  ELSIF p_x_operation_rec.concatenated_segments <> l_old_operation_rec.concatenated_segments THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_SEGMENTS_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_operation_rec.revision_status_code = 'DRAFT' OR
       p_x_operation_rec.revision_status_code = 'APPROVAL_REJECTED' ) THEN
    l_read_only_flag := 'N';
  ELSE
    l_read_only_flag := 'Y';
  END IF;

  IF ( p_x_operation_rec.standard_operation_flag IS NULL ) THEN
    p_x_operation_rec.standard_operation_flag := l_old_operation_rec.standard_operation_flag;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STANDARD_OPER_RO' );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  IF ( p_x_operation_rec.description IS NULL ) THEN
    p_x_operation_rec.description := l_old_operation_rec.description;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OPERATION_DESC_RO' );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  IF ( p_x_operation_rec.active_start_date IS NULL ) THEN
    p_x_operation_rec.active_start_date := l_old_operation_rec.active_start_date;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ST_DATE_RO' );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  IF ( p_x_operation_rec.active_end_date IS NULL ) THEN
    p_x_operation_rec.active_end_date := l_old_operation_rec.active_end_date;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_END_DATE_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_operation_rec.active_end_date = FND_API.G_MISS_DATE ) THEN
        p_x_operation_rec.active_end_date := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_operation_rec.qa_inspection_type IS NULL ) THEN
    p_x_operation_rec.qa_inspection_type := l_old_operation_rec.qa_inspection_type;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_QA_INSP_TYPE_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_operation_rec.qa_inspection_type = FND_API.G_MISS_CHAR ) THEN
        p_x_operation_rec.qa_inspection_type := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_operation_rec.qa_inspection_type_desc IS NULL ) THEN
    p_x_operation_rec.qa_inspection_type_desc := l_old_operation_rec.qa_inspection_type_desc;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_QA_INSP_TYPE_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_operation_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
        p_x_operation_rec.qa_inspection_type_desc := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_operation_rec.operation_type_code IS NULL ) THEN
    p_x_operation_rec.operation_type_code := l_old_operation_rec.operation_type_code;
  ELSIF ( p_x_operation_rec.operation_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.operation_type_code := null;
  END IF;

  IF ( p_x_operation_rec.operation_type IS NULL ) THEN
    p_x_operation_rec.operation_type := l_old_operation_rec.operation_type;
  ELSIF ( p_x_operation_rec.operation_type = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.operation_type := null;
  END IF;

  IF ( p_x_operation_rec.process_code IS NULL ) THEN
    p_x_operation_rec.process_code := l_old_operation_rec.process_code;
  ELSIF ( p_x_operation_rec.process_code = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.process_code := null;
  END IF;

  IF ( p_x_operation_rec.process IS NULL ) THEN
    p_x_operation_rec.process := l_old_operation_rec.process;
  ELSIF ( p_x_operation_rec.process = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.process := null;
  END IF;

  --bachandr Enigma Phase I changes -- start
  IF ( p_x_operation_rec.model_code IS NULL) THEN
    p_x_operation_rec.model_code := l_old_operation_rec.model_code;
  ELSIF ( p_x_operation_rec.model_code = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.model_code := null;
  END IF;

  IF ( p_x_operation_rec.model_meaning IS NULL ) THEN
    p_x_operation_rec.model_meaning := l_old_operation_rec.model_meaning;
  ELSIF ( p_x_operation_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.model_meaning := null;
  END IF;

  IF ( p_x_operation_rec.enigma_op_id IS NULL ) THEN
    p_x_operation_rec.enigma_op_id := l_old_operation_rec.enigma_op_id;
  ELSIF ( p_x_operation_rec.enigma_op_id = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.enigma_op_id := null;
  END IF;

  --bachandr Enigma Phase I changes -- end
  IF ( p_x_operation_rec.remarks IS NULL ) THEN
    p_x_operation_rec.remarks := l_old_operation_rec.remarks;
  ELSIF ( p_x_operation_rec.remarks = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.remarks := null;
  END IF;

  IF ( p_x_operation_rec.revision_notes IS NULL ) THEN
    p_x_operation_rec.revision_notes := l_old_operation_rec.revision_notes;
  ELSIF ( p_x_operation_rec.revision_notes = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.revision_notes := null;
  END IF;

  IF ( p_x_operation_rec.segment1 IS NULL ) THEN
    p_x_operation_rec.segment1 := l_old_operation_rec.segment1;
  ELSIF ( p_x_operation_rec.segment1 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment1 := null;
  END IF;

  IF ( p_x_operation_rec.segment2 IS NULL ) THEN
    p_x_operation_rec.segment2 := l_old_operation_rec.segment2;
  ELSIF ( p_x_operation_rec.segment2 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment2 := null;
  END IF;

  IF ( p_x_operation_rec.segment3 IS NULL ) THEN
    p_x_operation_rec.segment3 := l_old_operation_rec.segment3;
  ELSIF ( p_x_operation_rec.segment3 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment3 := null;
  END IF;

  IF ( p_x_operation_rec.segment4 IS NULL ) THEN
    p_x_operation_rec.segment4 := l_old_operation_rec.segment4;
  ELSIF ( p_x_operation_rec.segment4 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment4 := null;
  END IF;

  IF ( p_x_operation_rec.segment5 IS NULL ) THEN
    p_x_operation_rec.segment5 := l_old_operation_rec.segment5;
  ELSIF ( p_x_operation_rec.segment5 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment5 := null;
  END IF;

  IF ( p_x_operation_rec.segment6 IS NULL ) THEN
    p_x_operation_rec.segment6 := l_old_operation_rec.segment6;
  ELSIF ( p_x_operation_rec.segment6 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment6 := null;
  END IF;

  IF ( p_x_operation_rec.segment7 IS NULL ) THEN
    p_x_operation_rec.segment7 := l_old_operation_rec.segment7;
  ELSIF ( p_x_operation_rec.segment7 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment7 := null;
  END IF;

  IF ( p_x_operation_rec.segment8 IS NULL ) THEN
    p_x_operation_rec.segment8 := l_old_operation_rec.segment8;
  ELSIF ( p_x_operation_rec.segment8 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment8 := null;
  END IF;

  IF ( p_x_operation_rec.segment9 IS NULL ) THEN
    p_x_operation_rec.segment9 := l_old_operation_rec.segment9;
  ELSIF ( p_x_operation_rec.segment9 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment9 := null;
  END IF;

  IF ( p_x_operation_rec.segment10 IS NULL ) THEN
    p_x_operation_rec.segment10 := l_old_operation_rec.segment10;
  ELSIF ( p_x_operation_rec.segment10 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment10 := null;
  END IF;

  IF ( p_x_operation_rec.segment11 IS NULL ) THEN
    p_x_operation_rec.segment11 := l_old_operation_rec.segment11;
  ELSIF ( p_x_operation_rec.segment11 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment11 := null;
  END IF;

  IF ( p_x_operation_rec.segment12 IS NULL ) THEN
    p_x_operation_rec.segment12 := l_old_operation_rec.segment12;
  ELSIF ( p_x_operation_rec.segment12 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment12 := null;
  END IF;

  IF ( p_x_operation_rec.segment13 IS NULL ) THEN
    p_x_operation_rec.segment13 := l_old_operation_rec.segment13;
  ELSIF ( p_x_operation_rec.segment13 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment13 := null;
  END IF;

  IF ( p_x_operation_rec.segment14 IS NULL ) THEN
    p_x_operation_rec.segment14 := l_old_operation_rec.segment14;
  ELSIF ( p_x_operation_rec.segment14 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment14 := null;
  END IF;

  IF ( p_x_operation_rec.segment15 IS NULL ) THEN
    p_x_operation_rec.segment15 := l_old_operation_rec.segment15;
  ELSIF ( p_x_operation_rec.segment15 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.segment15 := null;
  END IF;

  IF ( p_x_operation_rec.attribute_category IS NULL ) THEN
    p_x_operation_rec.attribute_category := l_old_operation_rec.attribute_category;
  ELSIF ( p_x_operation_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute_category := null;
  END IF;

  IF ( p_x_operation_rec.attribute1 IS NULL ) THEN
    p_x_operation_rec.attribute1 := l_old_operation_rec.attribute1;
  ELSIF ( p_x_operation_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute1 := null;
  END IF;

  IF ( p_x_operation_rec.attribute2 IS NULL ) THEN
    p_x_operation_rec.attribute2 := l_old_operation_rec.attribute2;
  ELSIF ( p_x_operation_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute2 := null;
  END IF;

  IF ( p_x_operation_rec.attribute3 IS NULL ) THEN
    p_x_operation_rec.attribute3 := l_old_operation_rec.attribute3;
  ELSIF ( p_x_operation_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute3 := null;
  END IF;

  IF ( p_x_operation_rec.attribute4 IS NULL ) THEN
    p_x_operation_rec.attribute4 := l_old_operation_rec.attribute4;
  ELSIF ( p_x_operation_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute4 := null;
  END IF;

  IF ( p_x_operation_rec.attribute5 IS NULL ) THEN
    p_x_operation_rec.attribute5 := l_old_operation_rec.attribute5;
  ELSIF ( p_x_operation_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute5 := null;
  END IF;

  IF ( p_x_operation_rec.attribute6 IS NULL ) THEN
    p_x_operation_rec.attribute6 := l_old_operation_rec.attribute6;
  ELSIF ( p_x_operation_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute6 := null;
  END IF;

  IF ( p_x_operation_rec.attribute7 IS NULL ) THEN
    p_x_operation_rec.attribute7 := l_old_operation_rec.attribute7;
  ELSIF ( p_x_operation_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute7 := null;
  END IF;

  IF ( p_x_operation_rec.attribute8 IS NULL ) THEN
    p_x_operation_rec.attribute8 := l_old_operation_rec.attribute8;
  ELSIF ( p_x_operation_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute8 := null;
  END IF;

  IF ( p_x_operation_rec.attribute9 IS NULL ) THEN
    p_x_operation_rec.attribute9 := l_old_operation_rec.attribute9;
  ELSIF ( p_x_operation_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute9 := null;
  END IF;

  IF ( p_x_operation_rec.attribute10 IS NULL ) THEN
    p_x_operation_rec.attribute10 := l_old_operation_rec.attribute10;
  ELSIF ( p_x_operation_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute10 := null;
  END IF;

  IF ( p_x_operation_rec.attribute11 IS NULL ) THEN
    p_x_operation_rec.attribute11 := l_old_operation_rec.attribute11;
  ELSIF ( p_x_operation_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute11 := null;
  END IF;

  IF ( p_x_operation_rec.attribute12 IS NULL ) THEN
    p_x_operation_rec.attribute12 := l_old_operation_rec.attribute12;
  ELSIF ( p_x_operation_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute12 := null;
  END IF;

  IF ( p_x_operation_rec.attribute13 IS NULL ) THEN
    p_x_operation_rec.attribute13 := l_old_operation_rec.attribute13;
  ELSIF ( p_x_operation_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute13 := null;
  END IF;

  IF ( p_x_operation_rec.attribute14 IS NULL ) THEN
    p_x_operation_rec.attribute14 := l_old_operation_rec.attribute14;
  ELSIF ( p_x_operation_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute14 := null;
  END IF;

  IF ( p_x_operation_rec.attribute15 IS NULL ) THEN
    p_x_operation_rec.attribute15 := l_old_operation_rec.attribute15;
  ELSIF ( p_x_operation_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_operation_rec.attribute15 := null;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual operation attributes
PROCEDURE validate_attributes
(
  p_operation_rec         IN    operation_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS
CURSOR check_segments(c_segment1 varchar2, c_segment2 varchar2, c_segment3 varchar2,
                      c_segment4 varchar2, c_segment5 varchar2, c_segment6 varchar2,
                      c_segment7 varchar2, c_segment8 varchar2, c_segment9 varchar2,
                      c_segment10 varchar2, c_segment11 varchar2, c_segment12 varchar2,
                      c_segment13 varchar2, c_segment14 varchar2, c_segment15 varchar2) IS
  SELECT 'X'
    FROM ahl_operations_b
   WHERE ((segment1 is null and c_segment1 is null) or segment1 = c_segment1) AND
         ((segment2 is null and c_segment2 is null) or segment2 = c_segment2) AND
         ((segment3 is null and c_segment3 is null) or segment3 = c_segment3) AND
         ((segment4 is null and c_segment4 is null) or segment4 = c_segment4) AND
         ((segment5 is null and c_segment5 is null) or segment5 = c_segment5) AND
         ((segment6 is null and c_segment6 is null) or segment6 = c_segment6) AND
         ((segment7 is null and c_segment7 is null) or segment7 = c_segment7) AND
         ((segment8 is null and c_segment8 is null) or segment8 = c_segment8) AND
         ((segment9 is null and c_segment9 is null) or segment9 = c_segment9) AND
         ((segment10 is null and c_segment10 is null) or segment10 = c_segment10) AND
         ((segment11 is null and c_segment11 is null) or segment11 = c_segment11) AND
         ((segment12 is null and c_segment12 is null) or segment11 = c_segment12) AND
         ((segment13 is null and c_segment13 is null) or segment13 = c_segment13) AND
         ((segment14 is null and c_segment14 is null) or segment14 = c_segment14) AND
         ((segment15 is null and c_segment15 is null) or segment15 = c_segment15);
  l_dummy             varchar2(1);
  l_model_code        varchar2(30);

cursor validate_oper_ovn
is
select 'x'
from ahl_operations_b
where operation_id = p_operation_rec.operation_id and
object_version_number = p_operation_rec.object_version_number;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if concatenated_segments is null
  IF (p_operation_rec.dml_operation = 'C' AND
     (p_operation_rec.segment1 IS NULL OR p_operation_rec.segment1 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment2 IS NULL OR p_operation_rec.segment2 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment3 IS NULL OR p_operation_rec.segment3 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment4 IS NULL OR p_operation_rec.segment4 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment5 IS NULL OR p_operation_rec.segment5 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment6 IS NULL OR p_operation_rec.segment6 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment7 IS NULL OR p_operation_rec.segment7 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment8 IS NULL OR p_operation_rec.segment8 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment9 IS NULL OR p_operation_rec.segment9 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment10 IS NULL OR p_operation_rec.segment10 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment11 IS NULL OR p_operation_rec.segment11 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment12 IS NULL OR p_operation_rec.segment12 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment13 IS NULL OR p_operation_rec.segment13 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment14 IS NULL OR p_operation_rec.segment14 = FND_API.G_MISS_CHAR) AND
      (p_operation_rec.segment15 IS NULL OR p_operation_rec.segment15 = FND_API.G_MISS_CHAR)) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_SEGMENTS_ALL_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if concatenated_segments is unique when creating an operation record
  IF (p_operation_rec.dml_operation = 'C') THEN
    OPEN check_segments(p_operation_rec.segment1, p_operation_rec.segment2,
      p_operation_rec.segment3, p_operation_rec.segment4, p_operation_rec.segment5,
      p_operation_rec.segment6, p_operation_rec.segment7, p_operation_rec.segment8,
      p_operation_rec.segment9, p_operation_rec.segment10, p_operation_rec.segment11,
      p_operation_rec.segment12, p_operation_rec.segment13, p_operation_rec.segment14,
      p_operation_rec.segment15);
    FETCH check_segments INTO l_dummy;
    IF check_segments%FOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_OPERATION_DUP' );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE check_segments;
  END IF;

  -- Check if the Revision Status code column contains a null value.
  IF ( ( p_operation_rec.dml_operation = 'C' AND
         p_operation_rec.revision_status_code IS NULL ) OR
       p_operation_rec.revision_status_code = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_STATUS_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the Operation Description column contains a null value.
  IF ( ( p_operation_rec.dml_operation = 'C' AND
         p_operation_rec.description IS NULL ) OR
       p_operation_rec.description = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_OPERATION_DESC_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the Opeartion Start Date does not column contains a null value.
  IF ( ( p_operation_rec.dml_operation = 'C' AND
         p_operation_rec.active_start_date IS NULL ) OR
       p_operation_rec.active_start_date = FND_API.G_MISS_DATE ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ST_DATE_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the Standard Operation Flag column contains a null value.
  IF ( ( p_operation_rec.dml_operation = 'C' AND
         p_operation_rec.standard_operation_flag IS NULL ) OR
       p_operation_rec.standard_operation_flag = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_STANDARD_OPER_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --bachandr Enigma Phase I changes -- start
  IF ( p_operation_rec.dml_operation = 'C' AND p_operation_rec.enigma_op_id IS NOT NULL AND p_operation_rec.model_code IS NULL)
  THEN
  --throw error if model is null for enigma operations during creation.
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MODEL_CODE_NULL_OP' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_operation_rec.dml_operation = 'U' AND p_operation_rec.enigma_op_id IS NOT NULL)
  THEN
    Select model_code into l_model_code
    From   ahl_operations_b
    Where  operation_id = p_operation_rec.operation_id;

    IF ( p_operation_rec.model_code is null or (l_model_code <> p_operation_rec.model_code))
    THEN
    --throw error disallowing modification of model
    FND_MESSAGE.SET_NAME('AHL','AHL_RM_MODEL_OP');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
  --bachandr Enigma Phase I changes -- end
  -- Check if the mandatory Operation ID column contains a null value.
  IF ( p_operation_rec.dml_operation = 'U' AND (p_operation_rec.operation_id IS NULL OR
       p_operation_rec.operation_id = FND_API.G_MISS_NUM )) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_OPERATION_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_operation_rec.dml_operation = 'U' AND (p_operation_rec.object_version_number IS NULL OR
       p_operation_rec.object_version_number = FND_API.G_MISS_NUM )) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_OBJ_VERSION_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Added by Tamal for Bug #3854052
  IF (p_operation_rec.dml_operation = 'U' AND p_operation_rec.revision_status_code IN ('COMPLETE', 'APPROVAL_PENDING', 'TERMINATION_PENDING', 'TERMINATED'))
  THEN
  FND_MESSAGE.set_name( 'AHL','AHL_RM_OP_STS_NO_UPD' );
  FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  -- Added by Tamal for Bug #3854052

  IF (p_operation_rec.dml_operation IN ('U','D'))
  THEN
    OPEN validate_oper_ovn;
    FETCH validate_oper_ovn INTO l_dummy;
    IF (validate_oper_ovn%NOTFOUND)
    THEN
    FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
          FND_MSG_PUB.add;
    END IF;
  END IF;

END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks and duplicate checks
PROCEDURE validate_record
(
  p_operation_rec         IN    operation_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2
)
IS

l_start_date                 DATE;

CURSOR check_previous_start_date(c_concatenated_segments VARCHAR2, c_revision_number NUMBER) IS
  SELECT start_date_active
    FROM ahl_operations_v
   WHERE concatenated_segments = c_concatenated_segments
     AND revision_number = c_revision_number - 1;
/*
CURSOR get_dup_rec( c_segment1 VARCHAR2, c_segment2 VARCHAR2, c_segment3 VARCHAR2,
                    c_segment4 VARCHAR2, c_segment5 VARCHAR2, c_segment6 VARCHAR2,
                    c_segment7 VARCHAR2, c_segment8 VARCHAR2, c_segment9 VARCHAR2,
                    c_segment10 VARCHAR2, c_segment11 VARCHAR2, c_segment12 VARCHAR2,
                    c_segment13 VARCHAR2, c_segment14 VARCHAR2, c_segment15 VARCHAR2,
                    c_revision_number NUMBER )
IS
SELECT operation_id
FROM   AHL_OPERATIONS_B
WHERE  (c_segment1 is null or nvl(segment1, c_segment1) = c_segment1) AND
       (c_segment2 is null or nvl(segment2, c_segment2) = c_segment2) AND
       (c_segment3 is null or nvl(segment3, c_segment3) = c_segment3) AND
       (c_segment4 is null or nvl(segment4, c_segment4) = c_segment4) AND
       (c_segment5 is null or nvl(segment5, c_segment5) = c_segment5) AND
       (c_segment6 is null or nvl(segment6, c_segment6) = c_segment6) AND
       (c_segment7 is null or nvl(segment7, c_segment7) = c_segment7) AND
       (c_segment8 is null or nvl(segment8, c_segment8) = c_segment8) AND
       (c_segment9 is null or nvl(segment9, c_segment9) = c_segment9) AND
       (c_segment10 is null or nvl(segment10, c_segment10) = c_segment10) AND
       (c_segment11 is null or nvl(segment11, c_segment11) = c_segment11) AND
       (c_segment12 is null or nvl(segment11, c_segment12) = c_segment12) AND
       (c_segment13 is null or nvl(segment13, c_segment13) = c_segment13) AND
       (c_segment14 is null or nvl(segment14, c_segment14) = c_segment14) AND
       (c_segment15 is null or nvl(segment15, c_segment15) = c_segment15) AND
       revision_number = c_revision_number;
*/

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if Active start date is less than today's date for
  -- DRAFT and APPROVAL_REJECTED Operations

  IF ( p_operation_rec.revision_status_code = 'DRAFT' OR
       p_operation_rec.revision_status_code = 'APPROVAL_REJECTED' ) THEN
/*
    IF trunc(p_operation_rec.active_start_date) < trunc(SYSDATE) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_ST_DATE' );
      FND_MESSAGE.set_token('FIELD',trunc(SYSDATE));
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      */
    -- Check if Active start date is less than the active start date of the operation's
    -- previous version (if it is existing) when updating the operation
--    ELSIF ( p_operation_rec.dml_operation = 'U' ) THEN
      IF ( p_operation_rec.dml_operation = 'U' ) THEN
      OPEN check_previous_start_date(p_operation_rec.concatenated_segments,
                                     p_operation_rec.revision_number);
      FETCH check_previous_start_date INTO l_start_date;
      IF check_previous_start_date%FOUND THEN
        CLOSE check_previous_start_date;
        IF trunc(p_operation_rec.active_start_date) < trunc(l_start_date) THEN
          FND_MESSAGE.set_name( 'AHL','AHL_RM_ST_DATE_LESSER' );
          FND_MESSAGE.set_token('FIELD',trunc(l_start_date));
          FND_MSG_PUB.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
    END IF;
  END IF;
  /*
  OPEN get_dup_rec(p_operation_rec.segment1, p_operation_rec.segment2, p_operation_rec.segment3,
       p_operation_rec.segment4, p_operation_rec.segment5, p_operation_rec.segment6,
       p_operation_rec.segment7, p_operation_rec.segment8, p_operation_rec.segment9,
       p_operation_rec.segment10, p_operation_rec.segment11, p_operation_rec.segment12,
       p_operation_rec.segment13, p_operation_rec.segment14, p_operation_rec.segment15,
       p_operation_rec.revision_number );

  FETCH get_dup_rec INTO
    l_operation_id;

  IF ( get_dup_rec%FOUND ) THEN
    IF ( l_operation_id <> p_operation_rec.operation_id ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OPERATION_DUP' );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  CLOSE get_dup_rec;
*/

END validate_record;

PROCEDURE process_operation
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
 p_x_operation_rec    IN OUT NOCOPY operation_rec_type
)
IS
l_api_name       CONSTANT   VARCHAR2(30)   := 'process_operation';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_rowid                     VARCHAR2(30)   := NULL;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_operation_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin API' );
  END IF;

  -- If Id is null derive Operation id from Operation Number and revision
  IF  (p_x_operation_rec.dml_operation <> 'C' AND p_x_operation_rec.dml_operation <> 'c') AND
       p_x_operation_rec.operation_id IS NULL
  THEN
    -- Function to convert Operation number, operation revision to id
     AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
      (
       p_operation_number   =>  p_x_operation_rec.concatenated_segments,
       p_operation_revision   =>  p_x_operation_rec.revision_number,
       x_operation_id   =>  p_x_operation_rec.operation_id,
       x_return_status    =>  x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
           fnd_log.level_error,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
           'Error in AHL_RM_ROUTE_UTIL.Operation_Number_To_Id API'
       );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;


  -- Validate all the inputs of the API
  validate_api_inputs
  (
    p_x_operation_rec, -- IN
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
    clear_lov_attribute_ids
    (
      p_x_operation_rec -- IN OUT Record with Values and Ids
    );
  END IF;

  -- Convert Values into Ids.


    convert_values_to_ids
    (
      p_x_operation_rec , -- IN OUT Record with Values and Ids
      l_return_status -- OUT
    );

    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after convert_values_to_ids' );
  END IF;
  IF ( p_x_operation_rec.dml_operation = 'C' ) THEN

    p_x_operation_rec.object_version_number := 1;
    p_x_operation_rec.revision_number := 1;
    p_x_operation_rec.revision_status_code := 'DRAFT';
END IF;


  -- Default missing and unchanged attributes.
  IF ( p_x_operation_rec.dml_operation = 'U' ) THEN
    default_unchanged_attributes
    (
      p_x_operation_rec -- IN OUT
    );
  ELSIF ( p_x_operation_rec.dml_operation = 'C' ) THEN
    default_missing_attributes
    (
      p_x_operation_rec -- IN OUT
    );
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)

    validate_attributes
    (
      p_x_operation_rec, -- IN
      l_return_status -- OUT
    );

    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after validate_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)

    validate_record
    (
      p_x_operation_rec, -- IN
      l_return_status -- OUT
    );

    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after validate_record' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Perform the DML by invoking the Table Handler.
  IF ( p_x_operation_rec.dml_operation = 'C' ) THEN

      BEGIN

        -- Get the Operation ID from the Sequence
        SELECT AHL_OPERATIONS_B_S.NEXTVAL
        INTO   p_x_operation_rec.operation_id
        FROM   DUAL;
        -- Insert the record
        AHL_OPERATIONS_PKG.insert_row
        (
          X_ROWID =>  l_rowid ,
          X_OPERATION_ID =>  p_x_operation_rec.operation_id ,
          X_OBJECT_VERSION_NUMBER =>  p_x_operation_rec.object_version_number ,
          X_STANDARD_OPERATION_FLAG =>  p_x_operation_rec.standard_operation_flag ,
          X_REVISION_NUMBER =>  p_x_operation_rec.revision_number ,
          X_REVISION_STATUS_CODE =>  p_x_operation_rec.revision_status_code ,
          X_START_DATE_ACTIVE =>  p_x_operation_rec.active_start_date ,
          X_END_DATE_ACTIVE =>  p_x_operation_rec.active_end_date ,
          X_SUMMARY_FLAG => 'N' ,
          X_ENABLED_FLAG => 'Y' ,
          X_QA_INSPECTION_TYPE =>  p_x_operation_rec.qa_inspection_type ,
          X_OPERATION_TYPE_CODE =>  p_x_operation_rec.operation_type_code ,
          X_PROCESS_CODE =>  p_x_operation_rec.process_code ,
          --bachandr Enigma Phase I changes -- start
          X_MODEL_CODE => p_x_operation_rec.model_code,
          X_ENIGMA_OP_ID => p_x_operation_rec.enigma_op_id,
          --bachandr Enigma Phase I changes -- end
          X_SEGMENT1 =>  p_x_operation_rec.segment1 ,
          X_SEGMENT2 =>  p_x_operation_rec.segment2 ,
          X_SEGMENT3 =>  p_x_operation_rec.segment3 ,
          X_SEGMENT4 =>  p_x_operation_rec.segment4 ,
          X_SEGMENT5 =>  p_x_operation_rec.segment5 ,
          X_SEGMENT6 =>  p_x_operation_rec.segment6 ,
          X_SEGMENT7 =>  p_x_operation_rec.segment7 ,
          X_SEGMENT8 =>  p_x_operation_rec.segment8 ,
          X_SEGMENT9 =>  p_x_operation_rec.segment9 ,
          X_SEGMENT10 =>  p_x_operation_rec.segment10 ,
          X_SEGMENT11 =>  p_x_operation_rec.segment11 ,
          X_SEGMENT12 =>  p_x_operation_rec.segment12 ,
          X_SEGMENT13 =>  p_x_operation_rec.segment13 ,
          X_SEGMENT14 =>  p_x_operation_rec.segment14 ,
          X_SEGMENT15 =>  p_x_operation_rec.segment15 ,
          X_ATTRIBUTE_CATEGORY =>  p_x_operation_rec.attribute_category ,
          X_ATTRIBUTE1 =>  p_x_operation_rec.attribute1 ,
          X_ATTRIBUTE2 =>  p_x_operation_rec.attribute2 ,
          X_ATTRIBUTE3 =>  p_x_operation_rec.attribute3 ,
          X_ATTRIBUTE4 =>  p_x_operation_rec.attribute4 ,
          X_ATTRIBUTE5 =>  p_x_operation_rec.attribute5 ,
          X_ATTRIBUTE6 =>  p_x_operation_rec.attribute6 ,
          X_ATTRIBUTE7 =>  p_x_operation_rec.attribute7 ,
          X_ATTRIBUTE8 =>  p_x_operation_rec.attribute8 ,
          X_ATTRIBUTE9 =>  p_x_operation_rec.attribute9 ,
          X_ATTRIBUTE10 =>  p_x_operation_rec.attribute10 ,
          X_ATTRIBUTE11 =>  p_x_operation_rec.attribute11 ,
          X_ATTRIBUTE12 =>  p_x_operation_rec.attribute12 ,
          X_ATTRIBUTE13 =>  p_x_operation_rec.attribute13 ,
          X_ATTRIBUTE14 =>  p_x_operation_rec.attribute14 ,
          X_ATTRIBUTE15 =>  p_x_operation_rec.attribute15 ,
          X_DESCRIPTION =>  SUBSTR(p_x_operation_rec.description, 1, 500) ,
          X_REMARKS =>  p_x_operation_rec.remarks ,
          X_REVISION_NOTES =>  p_x_operation_rec.revision_notes ,
          X_CREATION_DATE =>  G_CREATION_DATE ,
          X_CREATED_BY =>  G_CREATED_BY ,
          X_LAST_UPDATE_DATE =>  G_LAST_UPDATE_DATE ,
          X_LAST_UPDATED_BY =>   G_LAST_UPDATED_BY  ,
          X_LAST_UPDATE_LOGIN =>  G_LAST_UPDATE_LOGIN
        );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
          FND_MSG_PUB.add;
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OPERATION_DUP' );
            FND_MSG_PUB.add;
          ELSE
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
      END;

  ELSIF ( p_x_operation_rec.dml_operation = 'U' ) THEN

      BEGIN
        -- Update the record
        p_x_operation_rec.object_version_number := p_x_operation_rec.object_version_number + 1;

        AHL_OPERATIONS_PKG.update_row
        (
          X_OPERATION_ID =>  p_x_operation_rec.operation_id ,
          X_OBJECT_VERSION_NUMBER =>  p_x_operation_rec.object_version_number ,
          X_STANDARD_OPERATION_FLAG =>  p_x_operation_rec.standard_operation_flag ,
          X_REVISION_NUMBER =>  p_x_operation_rec.revision_number ,
          X_REVISION_STATUS_CODE =>  p_x_operation_rec.revision_status_code ,
          X_START_DATE_ACTIVE =>  p_x_operation_rec.active_start_date ,
          X_END_DATE_ACTIVE =>  p_x_operation_rec.active_end_date ,
          X_SUMMARY_FLAG =>  'N' ,
          X_ENABLED_FLAG =>  'Y' ,
          X_QA_INSPECTION_TYPE =>  p_x_operation_rec.qa_inspection_type ,
          X_OPERATION_TYPE_CODE =>  p_x_operation_rec.operation_type_code ,
          X_PROCESS_CODE =>  p_x_operation_rec.process_code ,
          --bachandr Enigma Phase I changes -- start
          X_MODEL_CODE => p_x_operation_rec.model_code,
          X_ENIGMA_OP_ID => p_x_operation_rec.enigma_op_id,
          --bachandr Enigma Phase I changes -- end
          X_SEGMENT1 =>  p_x_operation_rec.segment1 ,
          X_SEGMENT2 =>  p_x_operation_rec.segment2 ,
          X_SEGMENT3 =>  p_x_operation_rec.segment3 ,
          X_SEGMENT4 =>  p_x_operation_rec.segment4 ,
          X_SEGMENT5 =>  p_x_operation_rec.segment5 ,
          X_SEGMENT6 =>  p_x_operation_rec.segment6 ,
          X_SEGMENT7 =>  p_x_operation_rec.segment7 ,
          X_SEGMENT8 =>  p_x_operation_rec.segment8 ,
          X_SEGMENT9 =>  p_x_operation_rec.segment9 ,
          X_SEGMENT10 =>  p_x_operation_rec.segment10 ,
          X_SEGMENT11 =>  p_x_operation_rec.segment11 ,
          X_SEGMENT12 =>  p_x_operation_rec.segment12 ,
          X_SEGMENT13 =>  p_x_operation_rec.segment13 ,
          X_SEGMENT14 =>  p_x_operation_rec.segment14 ,
          X_SEGMENT15 =>  p_x_operation_rec.segment15 ,
          X_ATTRIBUTE_CATEGORY =>  p_x_operation_rec.attribute_category ,
          X_ATTRIBUTE1 =>  p_x_operation_rec.attribute1 ,
          X_ATTRIBUTE2 =>  p_x_operation_rec.attribute2 ,
          X_ATTRIBUTE3 =>  p_x_operation_rec.attribute3 ,
          X_ATTRIBUTE4 =>  p_x_operation_rec.attribute4 ,
          X_ATTRIBUTE5 =>  p_x_operation_rec.attribute5 ,
          X_ATTRIBUTE6 =>  p_x_operation_rec.attribute6 ,
          X_ATTRIBUTE7 =>  p_x_operation_rec.attribute7 ,
          X_ATTRIBUTE8 =>  p_x_operation_rec.attribute8 ,
          X_ATTRIBUTE9 =>  p_x_operation_rec.attribute9 ,
          X_ATTRIBUTE10 =>  p_x_operation_rec.attribute10 ,
          X_ATTRIBUTE11 =>  p_x_operation_rec.attribute11 ,
          X_ATTRIBUTE12 =>  p_x_operation_rec.attribute12 ,
          X_ATTRIBUTE13 =>  p_x_operation_rec.attribute13 ,
          X_ATTRIBUTE14 =>  p_x_operation_rec.attribute14 ,
          X_ATTRIBUTE15 =>  p_x_operation_rec.attribute15 ,
          X_DESCRIPTION =>  SUBSTR(p_x_operation_rec.description, 1, 500) ,
          X_REMARKS =>  p_x_operation_rec.remarks ,
          X_REVISION_NOTES =>  p_x_operation_rec.revision_notes ,
          X_LAST_UPDATE_DATE => G_LAST_UPDATE_DATE  ,
          X_LAST_UPDATED_BY =>   G_LAST_UPDATED_BY ,
          X_LAST_UPDATE_LOGIN =>  G_LAST_UPDATE_LOGIN
        );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
          FND_MSG_PUB.add;
        WHEN OTHERS THEN
          IF ( SQLCODE = -1 ) THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OPERATION_DUP' );
            FND_MSG_PUB.add;
          ELSE
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
      END;

  END IF;

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
    ROLLBACK TO process_OPERATION_PVT;
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
    ROLLBACK TO process_OPERATION_PVT;
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
    ROLLBACK TO process_OPERATION_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
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
END process_operation;

PROCEDURE delete_operation
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
 p_operation_id          IN            NUMBER,
 p_object_version_number IN            NUMBER
)
IS

l_api_name       CONSTANT   VARCHAR2(30)   := 'delete_operation';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);
--bachandr Enigma Phase I changes -- start
l_enig_op_id    VARCHAR2(80);
--bachandr Enigma Phase I changes -- end

CURSOR get_doc_associations( c_OPERATION_id NUMBER )
IS
SELECT doc_title_asso_id
FROM   ahl_doc_title_assos_b
WHERE  aso_object_id = c_OPERATION_id
AND    aso_object_type_code = 'OPERATION';

cursor validate_oper_ovn
is
select 'x'
from ahl_operations_b
where operation_id = p_operation_id and
object_version_number = p_object_version_number;

l_dummy   VARCHAR2(1);

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT delete_operation_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin API' );
  END IF;

  IF ( p_operation_id IS NULL OR
       p_operation_id = FND_API.G_MISS_NUM OR
       p_object_version_number IS NULL OR
       p_object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN validate_oper_ovn;
  FETCH validate_oper_ovn INTO l_dummy;
  IF (validate_oper_ovn%NOTFOUND)
  THEN
  FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.add;
  END IF;
  --bachandr Enigma Phase I changes -- start
  -- Fire the validation only if the call is from the CMRO end.
  IF (p_module_type <> 'ENIGMA' ) THEN
    Select ENIGMA_OP_ID into l_enig_op_id
    From   ahl_operations_b
    Where  operation_id = p_operation_id;

    IF ( l_enig_op_id is not null and l_enig_op_id <> FND_API.G_MISS_CHAR)
    THEN
    --if the operation is from enigma do not allow deletion.
    FND_MESSAGE.SET_NAME('AHL','AHL_RM_OPER_ENIG_DELT');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  --bachandr Enigma Phase I changes -- end

  AHL_RM_ROUTE_UTIL.validate_operation_status
  (
    p_operation_id  => p_operation_id,
    x_msg_data      => l_msg_data,
    x_return_status => l_return_status
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( l_msg_data = 'AHL_RM_INVALID_OPER_STATUS' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OP_STATUS_NOT_DRAFT' );
    ELSE
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
    END IF;

    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN
    -- Delete the record in AHL_OPERATIONS_B and AHL_OPERATIONS_TL
    AHL_OPERATIONS_PKG.delete_row
    (
      X_OPERATION_ID          => p_operation_id
    );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      RAISE;
  END;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting AHL_OPERATIONS_B and AHL_OPERATIONS_TL' );
  END IF;

  -- Delete all the associations

  -- 1.Delete Material Requirements
  DELETE AHL_RT_OPER_MATERIALS
  WHERE  OBJECT_ID = p_operation_id
  AND    ASSOCIATION_TYPE_CODE = 'OPERATION';

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Material Requirements' );
  END IF;

  -- 2.Delete Resource Requirements
  DELETE AHL_RT_OPER_RESOURCES
  WHERE  OBJECT_ID = p_operation_id
  AND    ASSOCIATION_TYPE_CODE = 'OPERATION';

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Resource Requirements' );
  END IF;

  -- 3.Delete Reference Documents
  FOR I in get_doc_associations( p_operation_id ) LOOP
    ahl_doc_title_assos_pkg.delete_row
    (
      X_DOC_TITLE_ASSO_ID => I.doc_title_asso_id
    );
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Reference Documents' );
  END IF;

  -- 4.Delete Associated Operations
  DELETE AHL_ROUTE_OPERATIONS
  WHERE  OPERATION_ID = p_operation_id;

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Associated Operations' );
  END IF;

  -- 5.Delete Access Panels associated
  DELETE AHL_RT_OPER_ACCESS_PANELS
  WHERE  OBJECT_ID = p_operation_id
  AND    ASSOCIATION_TYPE_CODE = 'OPERATION';

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Access Panels' );
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
    ROLLBACK TO delete_OPERATION_PVT;
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
    ROLLBACK TO delete_OPERATION_PVT;
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
    ROLLBACK TO delete_OPERATION_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
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
END delete_operation;

PROCEDURE create_oper_revision
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
 p_operation_id          IN            NUMBER,
 p_object_version_number IN            NUMBER,
 x_operation_id          OUT NOCOPY    NUMBER
)
IS

l_api_name       CONSTANT   VARCHAR2(30)   := 'create_oper_revision';
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);
l_old_operation_rec         operation_rec_type;
l_dummy                     VARCHAR2(1);
l_revision_number           NUMBER;
l_operation_id              NUMBER;
l_rowid                     VARCHAR2(30)   := NULL;
l_doc_title_assos_id        NUMBER;
l_rt_oper_resource_id       NUMBER;

CURSOR  get_latest_revision( c_concatenated_segments VARCHAR2 )
IS
SELECT  MAX( revision_number )
FROM    AHL_OPERATIONS_V
WHERE   concatenated_segments = c_concatenated_segments;

CURSOR  get_doc_associations( c_operation_id NUMBER )
IS
SELECT  doc_title_asso_id,
        doc_revision_id,
        document_id,
        use_latest_rev_flag,
        serial_no,
        source_ref_code,
        chapter,
        section,
        subject,
        page,
        figure,
        note,
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
FROM    AHL_DOC_TITLE_ASSOS_VL
WHERE   aso_object_id = c_operation_id
AND     aso_object_type_code = 'OPERATION';

CURSOR get_rt_oper_resources (c_operation_id NUMBER) IS
  SELECT
      RT_OPER_RESOURCE_ID,
      OBJECT_ID,
      ASSOCIATION_TYPE_CODE,
      ASO_RESOURCE_ID,
      QUANTITY,
      DURATION,
      ACTIVITY_ID,
      COST_BASIS_ID,
      SCHEDULED_TYPE_ID,
      AUTOCHARGE_TYPE_ID,
      STANDARD_RATE_FLAG,
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
      -- Bug # 7644260 (FP for ER # 6998882) -- start
      SCHEDULE_SEQ
      -- Bug # 7644260 (FP for ER # 6998882) -- end
  FROM ahl_rt_oper_resources
  WHERE object_id = c_operation_id
  AND association_type_code = 'OPERATION';

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_oper_revision_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    l_api_name,
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin API' );
  END IF;

  IF ( p_operation_id IS NULL OR
       p_operation_id = FND_API.G_MISS_NUM OR
       p_object_version_number IS NULL OR
       p_object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  get_operation_record
  (
    x_return_status         => l_return_status,
    x_msg_data              => l_msg_data,
    p_operation_id          => p_operation_id,
    p_object_version_number => p_object_version_number,
    x_operation_rec         => l_old_operation_rec
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if the Status is COMPLETE
  IF ( l_old_operation_rec.revision_status_code <> 'COMPLETE' ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OP_STATUS_NOT_COMPLETE' );
    FND_MESSAGE.set_token( 'RECORD', l_old_operation_rec.concatenated_segments );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if active end date is set
  IF l_old_operation_rec.active_end_date is not null  THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_END_DATE_NOT_NULL' );
    FND_MESSAGE.set_token( 'RECORD', l_old_operation_rec.concatenated_segments )
;
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if this revision is the latest complete revision of this Operation
  OPEN get_latest_revision(l_old_operation_rec.concatenated_segments);
  FETCH get_latest_revision INTO
    l_revision_number;

  IF ( l_revision_number <> l_old_operation_rec.revision_number ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OP_REVISION_NOT_LATEST' );
    FND_MESSAGE.set_token( 'RECORD', l_old_operation_rec.concatenated_segments );
    FND_MSG_PUB.add;
    CLOSE get_latest_revision;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_latest_revision;

  -- Default the Active Start Date
  IF ( TRUNC( l_old_operation_rec.active_start_date ) < TRUNC( SYSDATE ) ) THEN
    l_old_operation_rec.active_start_date := SYSDATE;
  END IF;

  -- Create copy of the route in AHL_OPERATIONS_B and AHL_OPERATIONS_TL
  BEGIN

    l_revision_number := l_revision_number + 1;

    -- Get the Operation ID from the Sequence
    SELECT AHL_OPERATIONS_B_S.NEXTVAL
    INTO   l_operation_id
    FROM   DUAL;

    -- Insert the record
    AHL_OPERATIONS_PKG.insert_row
    (
      X_ROWID                   =>  l_rowid ,
      X_OPERATION_ID            =>  l_operation_id ,
      X_OBJECT_VERSION_NUMBER   =>  1 ,
      X_STANDARD_OPERATION_FLAG =>  l_old_operation_rec.standard_operation_flag ,
      X_REVISION_NUMBER         =>  l_revision_number ,
      X_REVISION_STATUS_CODE    =>  'DRAFT' ,
      X_START_DATE_ACTIVE       =>  l_old_operation_rec.active_start_date ,
      X_END_DATE_ACTIVE         =>  NULL ,
      X_SUMMARY_FLAG            =>  'N',
      X_ENABLED_FLAG            =>  'Y',
      X_QA_INSPECTION_TYPE      =>  l_old_operation_rec.qa_inspection_type ,
      X_OPERATION_TYPE_CODE     =>  l_old_operation_rec.operation_type_code ,
      X_PROCESS_CODE            =>  l_old_operation_rec.process_code ,
      --bachandr Enigma Phase I changes -- start
      X_MODEL_CODE              =>  l_old_operation_rec.model_code,
      X_ENIGMA_OP_ID            =>  l_old_operation_rec.enigma_op_id,
      --bachandr Enigma Phase I changes -- end
      X_SEGMENT1                =>  l_old_operation_rec.segment1 ,
      X_SEGMENT2                =>  l_old_operation_rec.segment2 ,
      X_SEGMENT3                =>  l_old_operation_rec.segment3 ,
      X_SEGMENT4                =>  l_old_operation_rec.segment4 ,
      X_SEGMENT5                =>  l_old_operation_rec.segment5 ,
      X_SEGMENT6                =>  l_old_operation_rec.segment6 ,
      X_SEGMENT7                =>  l_old_operation_rec.segment7 ,
      X_SEGMENT8                =>  l_old_operation_rec.segment8 ,
      X_SEGMENT9                =>  l_old_operation_rec.segment9 ,
      X_SEGMENT10               =>  l_old_operation_rec.segment10 ,
      X_SEGMENT11               =>  l_old_operation_rec.segment11 ,
      X_SEGMENT12               =>  l_old_operation_rec.segment12 ,
      X_SEGMENT13               =>  l_old_operation_rec.segment13 ,
      X_SEGMENT14               =>  l_old_operation_rec.segment14 ,
      X_SEGMENT15               =>  l_old_operation_rec.segment15 ,
      X_ATTRIBUTE_CATEGORY      =>  l_old_operation_rec.attribute_category ,
      X_ATTRIBUTE1              =>  l_old_operation_rec.attribute1 ,
      X_ATTRIBUTE2              =>  l_old_operation_rec.attribute2 ,
      X_ATTRIBUTE3              =>  l_old_operation_rec.attribute3 ,
      X_ATTRIBUTE4              =>  l_old_operation_rec.attribute4 ,
      X_ATTRIBUTE5              =>  l_old_operation_rec.attribute5 ,
      X_ATTRIBUTE6              =>  l_old_operation_rec.attribute6 ,
      X_ATTRIBUTE7              =>  l_old_operation_rec.attribute7 ,
      X_ATTRIBUTE8              =>  l_old_operation_rec.attribute8 ,
      X_ATTRIBUTE9              =>  l_old_operation_rec.attribute9 ,
      X_ATTRIBUTE10             =>  l_old_operation_rec.attribute10 ,
      X_ATTRIBUTE11             =>  l_old_operation_rec.attribute11 ,
      X_ATTRIBUTE12             =>  l_old_operation_rec.attribute12 ,
      X_ATTRIBUTE13             =>  l_old_operation_rec.attribute13 ,
      X_ATTRIBUTE14             =>  l_old_operation_rec.attribute14 ,
      X_ATTRIBUTE15             =>  l_old_operation_rec.attribute15 ,
      X_DESCRIPTION             =>  l_old_operation_rec.description ,
      X_REMARKS                 =>  l_old_operation_rec.remarks ,
      X_REVISION_NOTES          =>  l_old_operation_rec.revision_notes ,
      X_CREATION_DATE           =>  G_CREATION_DATE ,
      X_CREATED_BY              =>  G_CREATED_BY ,
      X_LAST_UPDATE_DATE        =>  G_LAST_UPDATE_DATE ,
      X_LAST_UPDATED_BY         =>  G_LAST_UPDATED_BY ,
      X_LAST_UPDATE_LOGIN       =>  G_LAST_UPDATE_LOGIN
    );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
    WHEN OTHERS THEN
      IF ( SQLCODE = -1 ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_OPERATION_DUP' );
        FND_MSG_PUB.add;
      ELSE
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
  END;

  -- Create copies of the operation associations

  -- 1.Copy Material Requirements
  INSERT INTO AHL_RT_OPER_MATERIALS
  (
    RT_OPER_MATERIAL_ID,
    OBJECT_VERSION_NUMBER,
    OBJECT_ID,
    ASSOCIATION_TYPE_CODE,
    ITEM_GROUP_ID,
    INVENTORY_ITEM_ID,
    INVENTORY_ORG_ID,
    UOM_CODE,
    QUANTITY,
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
    EXCLUDE_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    IN_SERVICE --pdoki added for OGMA 105 issue
  )
  SELECT
    AHL_RT_OPER_MATERIALS_S.NEXTVAL,
    1,
    l_operation_id,
    ASSOCIATION_TYPE_CODE,
    ITEM_GROUP_ID,
    INVENTORY_ITEM_ID,
    INVENTORY_ORG_ID,
    UOM_CODE,
    QUANTITY,
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
    EXCLUDE_FLAG,
    G_LAST_UPDATE_DATE,
    G_LAST_UPDATED_BY,
    G_CREATION_DATE,
    G_CREATED_BY,
    G_LAST_UPDATE_LOGIN,
    IN_SERVICE --pdoki added for OGMA 105 issue
  FROM  AHL_RT_OPER_MATERIALS
  WHERE object_id = p_operation_id
  AND   association_type_code = 'OPERATION';

  -- 2.Copy Resource Requirements and Alternate Resources
  FOR l_get_rt_oper_resources IN get_rt_oper_resources(p_operation_id) LOOP
    SELECT ahl_rt_oper_resources_s.nextval into l_rt_oper_resource_id
    FROM dual;
    INSERT INTO AHL_RT_OPER_RESOURCES
    (
      RT_OPER_RESOURCE_ID,
      OBJECT_VERSION_NUMBER,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_ID,
      ASSOCIATION_TYPE_CODE,
      ASO_RESOURCE_ID,
      QUANTITY,
      DURATION,
      ACTIVITY_ID,
      COST_BASIS_ID,
      SCHEDULED_TYPE_ID,
      AUTOCHARGE_TYPE_ID,
      STANDARD_RATE_FLAG,
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
      -- Bug # 7644260 (FP for ER # 6998882) -- start
      SCHEDULE_SEQ
      -- Bug # 7644260 (FP for ER # 6998882) -- end
    )
    VALUES
    (
      l_rt_oper_resource_id,
      1,
      G_LAST_UPDATE_DATE,
      G_LAST_UPDATED_BY,
      G_CREATION_DATE,
      G_CREATED_BY,
      G_LAST_UPDATE_LOGIN,
      l_operation_id,
      l_get_rt_oper_resources.ASSOCIATION_TYPE_CODE,
      l_get_rt_oper_resources.ASO_RESOURCE_ID,
      l_get_rt_oper_resources.QUANTITY,
      l_get_rt_oper_resources.DURATION,
      l_get_rt_oper_resources.ACTIVITY_ID,
      l_get_rt_oper_resources.COST_BASIS_ID,
      l_get_rt_oper_resources.SCHEDULED_TYPE_ID,
      l_get_rt_oper_resources.AUTOCHARGE_TYPE_ID,
      l_get_rt_oper_resources.STANDARD_RATE_FLAG,
      l_get_rt_oper_resources.ATTRIBUTE_CATEGORY,
      l_get_rt_oper_resources.ATTRIBUTE1,
      l_get_rt_oper_resources.ATTRIBUTE2,
      l_get_rt_oper_resources.ATTRIBUTE3,
      l_get_rt_oper_resources.ATTRIBUTE4,
      l_get_rt_oper_resources.ATTRIBUTE5,
      l_get_rt_oper_resources.ATTRIBUTE6,
      l_get_rt_oper_resources.ATTRIBUTE7,
      l_get_rt_oper_resources.ATTRIBUTE8,
      l_get_rt_oper_resources.ATTRIBUTE9,
      l_get_rt_oper_resources.ATTRIBUTE10,
      l_get_rt_oper_resources.ATTRIBUTE11,
      l_get_rt_oper_resources.ATTRIBUTE12,
      l_get_rt_oper_resources.ATTRIBUTE13,
      l_get_rt_oper_resources.ATTRIBUTE14,
      l_get_rt_oper_resources.ATTRIBUTE15,
      -- Bug # 7644260 (FP for ER # 6998882) -- start
      l_get_rt_oper_resources.SCHEDULE_SEQ
      -- Bug # 7644260 (FP for ER # 6998882) -- end
      );

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
      )
      SELECT
        AHL_ALTERNATE_RESOURCES_S.NEXTVAL,
        1,
        G_LAST_UPDATE_DATE,
        G_LAST_UPDATED_BY,
        G_CREATION_DATE,
        G_CREATED_BY,
        G_LAST_UPDATE_LOGIN,
        l_rt_oper_resource_id,
        aso_resource_id,
        priority,
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
      FROM  AHL_ALTERNATE_RESOURCES
      WHERE rt_oper_resource_id = l_get_rt_oper_resources.rt_oper_resource_id;
   END LOOP;

  -- 3.Copy Reference Documents
  FOR I in get_doc_associations( p_operation_id ) LOOP
    SELECT AHL_DOC_TITLE_ASSOS_B_S.NEXTVAL
    INTO   l_doc_title_assos_id
    FROM   DUAL;
    -- pekambar  changes for bug # 9342005  -- start
    -- Passing wrong values to attribute1 to attribute15 are corrected
    AHL_DOC_TITLE_ASSOS_PKG.insert_row
    (
      X_ROWID                        => l_rowid,
      X_DOC_TITLE_ASSO_ID            => l_doc_title_assos_id,
      X_SERIAL_NO                    => I.serial_no,
      X_ATTRIBUTE_CATEGORY           => I.attribute_category,
      X_ATTRIBUTE1                   => I.attribute1,
      X_ATTRIBUTE2                   => I.attribute2,
      X_ATTRIBUTE3                   => I.attribute3,
      X_ATTRIBUTE4                   => I.attribute4,
      X_ATTRIBUTE5                   => I.attribute5,
      X_ATTRIBUTE6                   => I.attribute6,
      X_ATTRIBUTE7                   => I.attribute7,
      X_ATTRIBUTE8                   => I.attribute8,
      X_ATTRIBUTE9                   => I.attribute9,
      X_ATTRIBUTE10                  => I.attribute10,
      X_ATTRIBUTE11                  => I.attribute11,
      X_ATTRIBUTE12                  => I.attribute12,
      X_ATTRIBUTE13                  => I.attribute13,
      X_ATTRIBUTE14                  => I.attribute14,
      X_ATTRIBUTE15                  => I.attribute15,
      X_ASO_OBJECT_TYPE_CODE         => 'OPERATION',
      X_SOURCE_REF_CODE              => I.source_ref_code,
      X_ASO_OBJECT_ID                => l_operation_id,
      X_DOCUMENT_ID                  => I.document_id,
      X_USE_LATEST_REV_FLAG          => I.use_latest_rev_flag,
      X_DOC_REVISION_ID              => I.doc_revision_id,
      X_OBJECT_VERSION_NUMBER        => 1,
      X_CHAPTER                      => I.chapter,
      X_SECTION                      => I.section,
      X_SUBJECT                      => I.subject,
      X_FIGURE                       => I.figure,
      X_PAGE                         => I.page,
      X_NOTE                         => I.note,
      X_CREATION_DATE                => G_CREATION_DATE,
      X_CREATED_BY                   => G_CREATED_BY ,
      X_LAST_UPDATE_DATE             => G_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY              => G_LAST_UPDATED_BY ,
      X_LAST_UPDATE_LOGIN            => G_LAST_UPDATE_LOGIN
    );
    -- pekambar  changes for bug # 9342005  -- end
  END LOOP;

  -- 4.Copy Associated Routes
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
  )
  SELECT
    AHL_ROUTE_OPERATIONS_S.NEXTVAL,
    1,
    ROUTE_ID,
    l_operation_id,
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
    G_LAST_UPDATE_DATE,
    G_LAST_UPDATED_BY,
    G_CREATION_DATE,
    G_CREATED_BY,
    G_LAST_UPDATE_LOGIN
  FROM  AHL_ROUTE_OPERATIONS
  WHERE operation_id = p_operation_id;

  -- Adithya added to fix bug# 6525763
  -- 5.Copy Access Panels
  INSERT INTO AHL_RT_OPER_ACCESS_PANELS
  (
    RT_OPER_PANEL_ID,
    OBJECT_VERSION_NUMBER,
    OBJECT_ID,
    ASSOCIATION_TYPE_CODE,
    PANEL_TYPE_ID,
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
  )
  SELECT
    AHL_RT_OPER_ACCESS_PANELS_S.NEXTVAL,
    1,
    l_operation_id,
    ASSOCIATION_TYPE_CODE,
    PANEL_TYPE_ID,
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
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id
  FROM  AHL_RT_OPER_ACCESS_PANELS
  WHERE object_id = p_operation_id
  AND association_type_code = 'OPERATION';

  -- Set the Out values.
  x_operation_id := l_operation_id;

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
    ROLLBACK TO create_oper_revision_PVT;
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
    ROLLBACK TO create_oper_revision_PVT;
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
    ROLLBACK TO create_oper_revision_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
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
END create_oper_revision;

END AHL_RM_OPERATION_PVT;

/
