--------------------------------------------------------
--  DDL for Package Body AHL_RM_ROUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ROUTE_PVT" AS
/* $Header: AHLVROMB.pls 120.4.12010000.7 2010/02/15 09:44:32 pekambar ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_ROUTE_PVT';
G_DEBUG    VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

-- constants for WHO Columns
-- Added by balaji as a part of Public API cleanup
G_LAST_UPDATE_DATE  DATE    := SYSDATE;
G_LAST_UPDATED_BY   NUMBER(15)  := FND_GLOBAL.user_id;
G_LAST_UPDATE_LOGIN   NUMBER(15)  := FND_GLOBAL.login_id;
G_CREATION_DATE   DATE    := SYSDATE;
G_CREATED_BY    NUMBER(15)  := FND_GLOBAL.user_id;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_route_rec       IN   route_rec_type,
  x_return_status     OUT NOCOPY  VARCHAR2
)
IS

l_return_status       VARCHAR2(1);
l_msg_data        VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate DML Operation
  IF (  p_route_rec.dml_operation IS NULL OR
    (
      p_route_rec.dml_operation <> 'U' AND
      p_route_rec.dml_operation <> 'C'
    )
     )
  THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_DML_REC' );
    FND_MESSAGE.set_token( 'FIELD', p_route_rec.dml_operation );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_route_rec       IN OUT NOCOPY  route_rec_type
)
IS

BEGIN
  IF ( p_x_route_rec.route_type IS NULL ) THEN
    p_x_route_rec.route_type_code := NULL;
  ELSIF ( p_x_route_rec.route_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.route_type_code := FND_API.G_MISS_CHAR;
  END IF;

  --bachandr Enigma Phase I changes -- start
  IF ( p_x_route_rec.model_meaning IS NULL ) THEN
      p_x_route_rec.model_code := NULL;
  ELSIF ( p_x_route_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
      p_x_route_rec.model_code := FND_API.G_MISS_CHAR;
  END IF;
  --bachandr Enigma Phase I changes -- end

  IF ( p_x_route_rec.process IS NULL ) THEN
    p_x_route_rec.process_code := NULL;
  ELSIF ( p_x_route_rec.process = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.process_code := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_route_rec.product_type IS NULL ) THEN
    p_x_route_rec.product_type_code := NULL;
  ELSIF ( p_x_route_rec.product_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.product_type_code := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_route_rec.operator_name IS NULL ) THEN
    p_x_route_rec.operator_party_id := NULL;
  ELSIF ( p_x_route_rec.operator_name = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.operator_party_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_route_rec.zone IS NULL ) THEN
    p_x_route_rec.zone_code := NULL;
  ELSIF ( p_x_route_rec.zone = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.zone_code := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_route_rec.sub_zone IS NULL ) THEN
    p_x_route_rec.sub_zone_code := NULL;
  ELSIF ( p_x_route_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.sub_zone_code := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_route_rec.service_item_number IS NULL ) THEN
    p_x_route_rec.service_item_id := NULL;
    p_x_route_rec.service_item_org_id := NULL;
  ELSIF ( p_x_route_rec.service_item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.service_item_id := FND_API.G_MISS_NUM;
    p_x_route_rec.service_item_org_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_route_rec.accounting_class IS NULL ) THEN
    p_x_route_rec.accounting_class_code := NULL;
    p_x_route_rec.accounting_class_org_id := NULL;
  ELSIF ( p_x_route_rec.accounting_class = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.accounting_class_code := FND_API.G_MISS_CHAR;
    p_x_route_rec.accounting_class_org_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_route_rec.task_template_group IS NULL ) THEN
    p_x_route_rec.task_template_group_id := NULL;
  ELSIF ( p_x_route_rec.task_template_group = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.task_template_group_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_route_rec.qa_inspection_type_desc IS NULL ) THEN
    p_x_route_rec.qa_inspection_type := NULL;
  ELSIF ( p_x_route_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.qa_inspection_type := FND_API.G_MISS_CHAR;
  END IF;

  IF ( p_x_route_rec.revision_status IS NULL ) THEN
    p_x_route_rec.revision_status_code := NULL;
  ELSIF ( p_x_route_rec.revision_status = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.revision_status_code := FND_API.G_MISS_CHAR;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_route_rec       IN OUT NOCOPY  route_rec_type,
  x_return_status     OUT NOCOPY      VARCHAR2
)
IS

l_return_status     VARCHAR2(1);
l_msg_data      VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Route Type
  IF ( ( p_x_route_rec.route_type_code IS NOT NULL AND
   p_x_route_rec.route_type_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.route_type IS NOT NULL AND
   p_x_route_rec.route_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'AHL_ROUTE_TYPE',
      p_lookup_meaning       => p_x_route_rec.route_type,
      p_x_lookup_code      => p_x_route_rec.route_type_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ROUTE_TYPE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_ROUTE_TYPES' );
      ELSE
  FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.route_type IS NULL OR
     p_x_route_rec.route_type = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.route_type_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.route_type );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  --bachandr Enigma Phase I changes -- start
  -- Convert / Validate Model
  IF ( ( p_x_route_rec.model_code IS NOT NULL AND
	 p_x_route_rec.model_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.model_meaning IS NOT NULL AND
	 p_x_route_rec.model_meaning <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status	     => l_return_status,
      x_msg_data	     => l_msg_data,
      p_lookup_type	     => 'AHL_ENIGMA_MODEL_CODE',
      p_lookup_meaning	     => p_x_route_rec.model_meaning,
      p_x_lookup_code	     => p_x_route_rec.model_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
	FND_MESSAGE.set_name( 'AHL', 'AHL_CM_INVALID_MODEL' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
	FND_MESSAGE.set_name( 'AHL', 'AHL_CM_TOO_MANY_MODELS' );
      ELSE
	FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.model_meaning IS NULL OR
	   p_x_route_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
	FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.model_code );
      ELSE
	FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.model_meaning );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;
  --bachandr Enigma Phase I changes -- end

  -- Convert / Validate Process
  IF ( ( p_x_route_rec.process_code IS NOT NULL AND
   p_x_route_rec.process_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.process IS NOT NULL AND
   p_x_route_rec.process <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'AHL_PROCESS_CODE',
      p_lookup_meaning       => p_x_route_rec.process,
      p_x_lookup_code      => p_x_route_rec.process_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PROCESS' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_PROCESSES' );
      ELSE
  FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.process IS NULL OR
     p_x_route_rec.process = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.process_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.process );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Product Type
  IF ( ( p_x_route_rec.product_type_code IS NOT NULL AND
   p_x_route_rec.product_type_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.product_type IS NOT NULL AND
   p_x_route_rec.product_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'ITEM_TYPE',
      p_lookup_meaning       => p_x_route_rec.product_type,
      p_x_lookup_code      => p_x_route_rec.product_type_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_PRODUCT_TYPE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_PRODUCT_TYPES' );
      ELSE
  FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.product_type IS NULL OR
     p_x_route_rec.product_type = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.product_type_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.product_type );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Operator
  IF ( ( p_x_route_rec.operator_name IS NOT NULL AND
   p_x_route_rec.operator_name <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.operator_party_id IS NOT NULL AND
   p_x_route_rec.operator_party_id <> FND_API.G_MISS_NUM ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_operator
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_operator_name      => p_x_route_rec.operator_name,
      p_x_operator_party_id  => p_x_route_rec.operator_party_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_route_rec.operator_name IS NULL OR
     p_x_route_rec.operator_name = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_route_rec.operator_party_id ) );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.operator_name );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Zone
  IF ( ( p_x_route_rec.zone_code IS NOT NULL AND
   p_x_route_rec.zone_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.zone IS NOT NULL AND
   p_x_route_rec.zone <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'AHL_ZONE',
      p_lookup_meaning       => p_x_route_rec.zone,
      p_x_lookup_code      => p_x_route_rec.zone_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ZONE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_ZONES' );
      ELSE
  FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.zone IS NULL OR
     p_x_route_rec.zone = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.zone_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.zone );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Sub Zone
  IF ( ( p_x_route_rec.sub_zone_code IS NOT NULL AND
   p_x_route_rec.sub_zone_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.sub_zone IS NOT NULL AND
   p_x_route_rec.sub_zone <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'AHL_SUB_ZONE',
      p_lookup_meaning       => p_x_route_rec.sub_zone,
      p_x_lookup_code      => p_x_route_rec.sub_zone_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_SUB_ZONE' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_SUB_ZONES' );
      ELSE
  FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.sub_zone IS NULL OR
     p_x_route_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.sub_zone_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.sub_zone );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Service Item
  IF ( ( p_x_route_rec.service_item_number IS NOT NULL AND
   p_x_route_rec.service_item_number <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.service_item_id IS NOT NULL AND
   p_x_route_rec.service_item_id <> FND_API.G_MISS_NUM AND
   p_x_route_rec.service_item_org_id IS NOT NULL AND
   p_x_route_rec.service_item_org_id <> FND_API.G_MISS_NUM ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_service_item
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_item_number      => p_x_route_rec.service_item_number,
      p_x_inventory_item_id  => p_x_route_rec.service_item_id,
      p_x_inventory_org_id   => p_x_route_rec.service_item_org_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_route_rec.service_item_number IS NULL OR
     p_x_route_rec.service_item_number = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_route_rec.service_item_id ) || TO_CHAR( p_x_route_rec.service_item_org_id ) );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.service_item_number );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Accounting Class
  IF ( ( p_x_route_rec.accounting_class_code IS NOT NULL AND
   p_x_route_rec.accounting_class_code <> FND_API.G_MISS_CHAR AND
   p_x_route_rec.accounting_class_org_id IS NOT NULL AND
   p_x_route_rec.accounting_class_org_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_route_rec.accounting_class IS NOT NULL AND
   p_x_route_rec.accounting_class <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_accounting_class
    (
      x_return_status     => l_return_status,
      x_msg_data      => l_msg_data,
      p_accounting_class    => p_x_route_rec.accounting_class,
      p_x_accounting_class_code   => p_x_route_rec.accounting_class_code,
      p_x_accounting_class_org_id => p_x_route_rec.accounting_class_org_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_route_rec.accounting_class IS NULL OR
     p_x_route_rec.accounting_class = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.accounting_class_code || '-' || TO_CHAR( p_x_route_rec.accounting_class_org_id ) );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.accounting_class );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Task Template Group
  IF ( ( p_x_route_rec.task_template_group IS NOT NULL AND
   p_x_route_rec.task_template_group <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.task_template_group_id IS NOT NULL AND
   p_x_route_rec.task_template_group_id <> FND_API.G_MISS_NUM ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_task_template_group
    (
      x_return_status     => l_return_status,
      x_msg_data      => l_msg_data,
      p_task_template_group   => p_x_route_rec.task_template_group,
      p_x_task_template_group_id  => p_x_route_rec.task_template_group_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_route_rec.task_template_group IS NULL OR
     p_x_route_rec.task_template_group = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_route_rec.task_template_group_id ) );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.task_template_group );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate QA Plan
  IF ( ( p_x_route_rec.qa_inspection_type_desc IS NOT NULL AND
   p_x_route_rec.qa_inspection_type_desc <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.qa_inspection_type IS NOT NULL AND
   p_x_route_rec.qa_inspection_type <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_qa_inspection_type
    (
      x_return_status   => l_return_status,
      x_msg_data    => l_msg_data,
      p_qa_inspection_type_desc => p_x_route_rec.qa_inspection_type_desc,
      p_x_qa_inspection_type  => p_x_route_rec.qa_inspection_type
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( p_x_route_rec.qa_inspection_type_desc IS NULL OR
     p_x_route_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.qa_inspection_type );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.qa_inspection_type_desc );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Revision Status
  IF ( ( p_x_route_rec.revision_status_code IS NOT NULL AND
   p_x_route_rec.revision_status_code <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.revision_status IS NOT NULL AND
   p_x_route_rec.revision_status <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'AHL_REVISION_STATUS',
      p_lookup_meaning       => p_x_route_rec.revision_status,
      p_x_lookup_code      => p_x_route_rec.revision_status_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_STATUS' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_STATUSES' );
      ELSE
  FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.revision_status IS NULL OR
     p_x_route_rec.revision_status = FND_API.G_MISS_CHAR ) THEN
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.revision_status_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.revision_status );
      END IF;

      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- pdoki added for Bug 6504159
  -- Convert / Validate unit receipt update
  IF ( ( p_x_route_rec.unit_receipt_update_flag IS NOT NULL AND
   p_x_route_rec.unit_receipt_update_flag <> FND_API.G_MISS_CHAR ) OR
       ( p_x_route_rec.unit_receipt_update IS NOT NULL AND
   p_x_route_rec.unit_receipt_update <> FND_API.G_MISS_CHAR ) ) THEN

    AHL_RM_ROUTE_UTIL.validate_lookup
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_lookup_type      => 'AHL_YES_NO_TYPE',
      p_lookup_meaning       => p_x_route_rec.unit_receipt_update,
      p_x_lookup_code      => p_x_route_rec.unit_receipt_update_flag
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF ( l_msg_data = 'AHL_COM_INVALID_LOOKUP' ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_UNIT_RECEIPT' );
      ELSIF ( l_msg_data = 'AHL_COM_TOO_MANY_LOOKUPS' ) THEN
          FND_MESSAGE.set_name( 'AHL', 'AHL_RM_TOO_MANY_UNIT_RECEIPTS' );
      ELSE
          FND_MESSAGE.set_name( 'AHL', l_msg_data );
      END IF;

      IF ( p_x_route_rec.unit_receipt_update IS NULL OR
     p_x_route_rec.unit_receipt_update = FND_API.G_MISS_CHAR ) THEN
           FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.unit_receipt_update_flag );
      ELSE
           FND_MESSAGE.set_token( 'FIELD', p_x_route_rec.unit_receipt_update );
      END IF;
      FND_MSG_PUB.add;
    END IF;

  END IF;
END convert_values_to_ids;

-- Procedure to add Default values for route attributes
-- Balaji removed it as a part of public API cleanup as this defaulting logic should not be bound by p_default value. Instead the logic is moved to DML.
/*
PROCEDURE default_attributes
(
  p_x_route_rec       IN OUT NOCOPY   route_rec_type
)
IS

BEGIN

  p_x_route_rec.last_update_date := SYSDATE;
  p_x_route_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_route_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_route_rec.dml_operation = 'C' ) THEN
    p_x_route_rec.revision_status_code := 'DRAFT';
    p_x_route_rec.object_version_number := 1;
    p_x_route_rec.revision_number := 1;
    p_x_route_rec.creation_date := SYSDATE;
    p_x_route_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_attributes;
*/
 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_route_rec       IN OUT NOCOPY   route_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_route_rec.route_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.route_type_code := null;
  END IF;

  IF ( p_x_route_rec.route_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.route_type := null;
  END IF;

  IF ( p_x_route_rec.process_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.process_code := null;
  END IF;

  IF ( p_x_route_rec.process = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.process := null;
  END IF;

  IF ( p_x_route_rec.product_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.product_type_code := null;
  END IF;

  IF ( p_x_route_rec.product_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.product_type := null;
  END IF;

  --bachandr Enigma Phase I changes -- start
  -- Default the model code and meaning to null only
  -- when the route in a non-Enigma route.

  IF ( p_x_route_rec.enigma_doc_id IS NULL OR p_x_route_rec.enigma_doc_id = FND_API.G_MISS_CHAR ) THEN
	  IF ( p_x_route_rec.model_code = FND_API.G_MISS_CHAR ) THEN
	    p_x_route_rec.model_code := null;
	  END IF;

	  IF ( p_x_route_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
	    p_x_route_rec.model_meaning := null;
	  END IF;
  END IF;

  IF ( p_x_route_rec.time_span = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.time_span := null;
  END IF;

  --bachandr Enigma Phase I changes -- end

  IF ( p_x_route_rec.operator_party_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.operator_party_id := null;
  END IF;

  IF ( p_x_route_rec.operator_name = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.operator_name := null;
  END IF;

  IF ( p_x_route_rec.zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.zone_code := null;
  END IF;

  IF ( p_x_route_rec.zone = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.zone := null;
  END IF;

  IF ( p_x_route_rec.sub_zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.sub_zone_code := null;
  END IF;

  IF ( p_x_route_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.sub_zone := null;
  END IF;

  IF ( p_x_route_rec.service_item_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.service_item_id := null;
  END IF;

  IF ( p_x_route_rec.service_item_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.service_item_org_id := null;
  END IF;

  IF ( p_x_route_rec.service_item_number = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.service_item_number := null;
  END IF;

  IF ( p_x_route_rec.accounting_class_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.accounting_class_code := null;
  END IF;

  IF ( p_x_route_rec.accounting_class_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.accounting_class_org_id := null;
  END IF;

  IF ( p_x_route_rec.accounting_class = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.accounting_class := null;
  END IF;

  IF ( p_x_route_rec.task_template_group_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.task_template_group_id := null;
  END IF;

  IF ( p_x_route_rec.task_template_group = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.task_template_group := null;
  END IF;

  IF ( p_x_route_rec.qa_inspection_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.qa_inspection_type := null;
  END IF;

  IF ( p_x_route_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.qa_inspection_type_desc := null;
  END IF;

  IF ( p_x_route_rec.remarks = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.remarks := null;
  END IF;

  IF ( p_x_route_rec.revision_notes = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.revision_notes := null;
  END IF;

  IF ( p_x_route_rec.segment1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment1 := null;
  END IF;

  IF ( p_x_route_rec.segment2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment2 := null;
  END IF;

  IF ( p_x_route_rec.segment3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment3 := null;
  END IF;

  IF ( p_x_route_rec.segment4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment4 := null;
  END IF;

  IF ( p_x_route_rec.segment5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment5 := null;
  END IF;

  IF ( p_x_route_rec.segment6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment6 := null;
  END IF;

  IF ( p_x_route_rec.segment7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment7 := null;
  END IF;

  IF ( p_x_route_rec.segment8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment8 := null;
  END IF;

  IF ( p_x_route_rec.segment9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment9 := null;
  END IF;

  IF ( p_x_route_rec.segment10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment10 := null;
  END IF;

  IF ( p_x_route_rec.segment11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment11 := null;
  END IF;

  IF ( p_x_route_rec.segment12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment12 := null;
  END IF;

  IF ( p_x_route_rec.segment13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment13 := null;
  END IF;

  IF ( p_x_route_rec.segment14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment14 := null;
  END IF;

  IF ( p_x_route_rec.segment15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment15 := null;
  END IF;

  IF ( p_x_route_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute_category := null;
  END IF;

  IF ( p_x_route_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute1 := null;
  END IF;

  IF ( p_x_route_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute2 := null;
  END IF;

  IF ( p_x_route_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute3 := null;
  END IF;

  IF ( p_x_route_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute4 := null;
  END IF;

  IF ( p_x_route_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute5 := null;
  END IF;

  IF ( p_x_route_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute6 := null;
  END IF;

  IF ( p_x_route_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute7 := null;
  END IF;

  IF ( p_x_route_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute8 := null;
  END IF;

  IF ( p_x_route_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute9 := null;
  END IF;

  IF ( p_x_route_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute10 := null;
  END IF;

  IF ( p_x_route_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute11 := null;
  END IF;

  IF ( p_x_route_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute12 := null;
  END IF;

  IF ( p_x_route_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute13 := null;
  END IF;

  IF ( p_x_route_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute14 := null;
  END IF;

  IF ( p_x_route_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute15 := null;
  END IF;

  --pdoki added for Bug 6504159
  IF ( p_x_route_rec.unit_receipt_update_flag = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.unit_receipt_update_flag := 'N';
  END IF;
END default_missing_attributes;

-- Procedure to get the Route Record for a given route_id
PROCEDURE get_route_record
(
  x_return_status   OUT NOCOPY    VARCHAR2,
  x_msg_data      OUT NOCOPY    VARCHAR2,
  p_route_id      IN      NUMBER,
  p_object_version_number IN      NUMBER,
  p_x_route_rec     IN OUT NOCOPY   route_rec_type
)
IS

CURSOR get_old_rec ( c_route_id NUMBER )
IS
SELECT  route_no,
  title,
  route_type_code,
  route_type,
  process_code,
  process,
  product_type_code,
  product_type,
  --bachandr Enigma Phase I changes -- start
  model_code,
  model_meaning,
  enigma_doc_id,
  enigma_route_id,
  enigma_publish_date,
  file_id,
  --bachandr Enigma Phase I changes -- end
  operator_party_id,
  operator_name,
  zone_code,
  zone,
  sub_zone_code,
  sub_zone,
  service_item_id,
  service_item_org_id,
  service_item_number,
  accounting_class_code,
  accounting_class_org_id,
  accounting_class,
  task_template_group_id,
  task_template_group,
  qa_inspection_type,
  qa_inspection_type_desc,
  time_span,
  start_date_active,
  end_date_active,
  revision_number,
  revision_status_code,
  revision_status,
  unit_receipt_update_flag, --pdoki Bug 6504159.
  unit_receipt_update, --pdoki Bug 6504159.
  remarks,
  REVISION_NOTES, -- JKJain Bug No 8212847, Fp for bug 8206660
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
FROM  AHL_ROUTES_V
WHERE route_id = c_route_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the old record from AHL_ROUTES_V.
  OPEN  get_old_rec( p_route_id );

  FETCH get_old_rec INTO
  p_x_route_rec.route_no,
  p_x_route_rec.title,
  p_x_route_rec.route_type_code,
  p_x_route_rec.route_type,
  p_x_route_rec.process_code,
  p_x_route_rec.process,
  p_x_route_rec.product_type_code,
  p_x_route_rec.product_type,
  --bachandr Enigma Phase I changes -- start
  p_x_route_rec.model_code,
  p_x_route_rec.model_meaning,
  p_x_route_rec.enigma_doc_id,
  p_x_route_rec.enigma_route_id,
  p_x_route_rec.enigma_publish_date,
  p_x_route_rec.file_id,
  --bachandr Enigma Phase I changes -- end
  p_x_route_rec.operator_party_id,
  p_x_route_rec.operator_name,
  p_x_route_rec.zone_code,
  p_x_route_rec.zone,
  p_x_route_rec.sub_zone_code,
  p_x_route_rec.sub_zone,
  p_x_route_rec.service_item_id,
  p_x_route_rec.service_item_org_id,
  p_x_route_rec.service_item_number,
  p_x_route_rec.accounting_class_code,
  p_x_route_rec.accounting_class_org_id,
  p_x_route_rec.accounting_class,
  p_x_route_rec.task_template_group_id,
  p_x_route_rec.task_template_group,
  p_x_route_rec.qa_inspection_type,
  p_x_route_rec.qa_inspection_type_desc,
  p_x_route_rec.time_span,
  p_x_route_rec.active_start_date,
  p_x_route_rec.active_end_date,
  p_x_route_rec.revision_number,
  p_x_route_rec.revision_status_code,
  p_x_route_rec.revision_status,
  p_x_route_rec.unit_receipt_update_flag, --pdoki Bug 6504159.
  p_x_route_rec.unit_receipt_update, --pdoki Bug 6504159.
  p_x_route_rec.remarks,
  p_x_route_rec.REVISION_NOTES, -- JKJain Bug No 8212847, Fp for bug 8206660
  p_x_route_rec.segment1,
  p_x_route_rec.segment2,
  p_x_route_rec.segment3,
  p_x_route_rec.segment4,
  p_x_route_rec.segment5,
  p_x_route_rec.segment6,
  p_x_route_rec.segment7,
  p_x_route_rec.segment8,
  p_x_route_rec.segment9,
  p_x_route_rec.segment10,
  p_x_route_rec.segment11,
  p_x_route_rec.segment12,
  p_x_route_rec.segment13,
  p_x_route_rec.segment14,
  p_x_route_rec.segment15,
  p_x_route_rec.attribute_category,
  p_x_route_rec.attribute1,
  p_x_route_rec.attribute2,
  p_x_route_rec.attribute3,
  p_x_route_rec.attribute4,
  p_x_route_rec.attribute5,
  p_x_route_rec.attribute6,
  p_x_route_rec.attribute7,
  p_x_route_rec.attribute8,
  p_x_route_rec.attribute9,
  p_x_route_rec.attribute10,
  p_x_route_rec.attribute11,
  p_x_route_rec.attribute12,
  p_x_route_rec.attribute13,
  p_x_route_rec.attribute14,
  p_x_route_rec.attribute15;

  IF ( get_old_rec%NOTFOUND ) THEN
    x_msg_data := 'AHL_RM_INVALID_ROUTE';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( p_x_route_rec.object_version_number <> p_object_version_number ) THEN
    x_msg_data := 'AHL_COM_RECORD_CHANGED';
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_old_rec;

END get_route_record;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_route_rec       IN OUT NOCOPY   route_rec_type
)
IS

l_old_route_rec     route_rec_type;
l_read_only_flag    VARCHAR2(1);
l_msg_data      VARCHAR2(2000);
l_return_status     VARCHAR2(1);

BEGIN

  get_route_record
  (
    x_return_status     => l_return_status,
    x_msg_data        => l_msg_data,
    p_route_id        => p_x_route_rec.route_id,
    p_object_version_number => p_x_route_rec.object_version_number,
    p_x_route_rec     => l_old_route_rec
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_route_rec.revision_status_code IS NULL ) THEN
    p_x_route_rec.revision_status_code := l_old_route_rec.revision_status_code;

    IF ( p_x_route_rec.revision_status_code = 'APPROVAL_REJECTED' ) THEN
      p_x_route_rec.revision_status_code := 'DRAFT';
    END IF;
    -- Condition added in 11.5.10.
  ELSIF p_x_route_rec.revision_status_code <> l_old_route_rec.revision_status_code THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STATUS_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_route_rec.revision_status IS NULL ) THEN
    p_x_route_rec.revision_status := l_old_route_rec.revision_status;
  ELSIF p_x_route_rec.revision_status <> l_old_route_rec.revision_status THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_STATUS_RO' );
    FND_MSG_PUB.add;
  END IF;

  --bachandr Enigma Phase I changes -- start
  -- Do the following only when the route is created from Enigma
  -- Check if the model code is null and if it is then default it to the DB value
  -- If it is not null  and it does not match with the value in the DB then throw an error
  IF ( l_old_route_rec.enigma_doc_id IS NOT NULL AND p_x_route_rec.model_code IS NULL ) THEN
    p_x_route_rec.model_code := l_old_route_rec.model_code;
  ELSIF  ( l_old_route_rec.enigma_doc_id IS NOT NULL AND p_x_route_rec.model_code <> l_old_route_rec.model_code ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MODEL_RO' );
    FND_MSG_PUB.add;
  END IF;

  -- Do the following only when the route is created from Enigma
  -- Check if the model meaning  is null and if it is then default it to the DB value
  -- If it is not null / Enigma Route it does not match with the value in the DB then throw an error
  IF ( l_old_route_rec.enigma_doc_id IS NOT NULL AND p_x_route_rec.model_meaning IS NULL ) THEN
    p_x_route_rec.model_meaning := l_old_route_rec.model_meaning;
  ELSIF  ( l_old_route_rec.enigma_doc_id IS NOT NULL AND p_x_route_rec.model_meaning <> l_old_route_rec.model_meaning ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_MODEL_RO' );
    FND_MSG_PUB.add;
  END IF;


  IF ( l_old_route_rec.enigma_doc_id IS NOT NULL AND p_x_route_rec.file_id IS NULL ) THEN
    p_x_route_rec.file_id := l_old_route_rec.file_id;
  ELSIF ( p_x_route_rec.file_id = FND_API.G_MISS_NUM) THEN
    p_x_route_rec.file_id := null;
  END IF;
  --bachandr Enigma Phase I changes -- end

  IF ( p_x_route_rec.revision_number IS NULL ) THEN
    p_x_route_rec.revision_number := l_old_route_rec.revision_number;
  ELSIF p_x_route_rec.revision_number <> l_old_route_rec.revision_number THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_REVISION_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_route_rec.route_no IS NULL ) THEN
    p_x_route_rec.route_no := l_old_route_rec.route_no;
  ELSIF p_x_route_rec.route_no <> l_old_route_rec.route_no THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_NO_RO' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_x_route_rec.revision_status_code = 'DRAFT' ) THEN
    l_read_only_flag := 'N';
  ELSE
    l_read_only_flag := 'Y';
  END IF;

  IF ( p_x_route_rec.title IS NULL ) THEN
    p_x_route_rec.title := l_old_route_rec.title;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_TITLE_RO' );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  IF ( p_x_route_rec.active_start_date IS NULL ) THEN
    p_x_route_rec.active_start_date := l_old_route_rec.active_start_date;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ST_DATE_RO' );
      FND_MSG_PUB.add;
    ELSIF ( p_x_route_rec.active_start_date = FND_API.G_MISS_DATE ) THEN
      p_x_route_rec.active_start_date := NULL;
    END IF;
  END IF;

  IF ( p_x_route_rec.active_end_date IS NULL ) THEN
    p_x_route_rec.active_end_date := l_old_route_rec.active_end_date;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_END_DATE_RO' );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  IF ( p_x_route_rec.route_type_code IS NULL ) THEN
    p_x_route_rec.route_type_code := l_old_route_rec.route_type_code;
  ELSIF ( p_x_route_rec.route_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.route_type_code := null;
  END IF;

  IF ( p_x_route_rec.route_type IS NULL ) THEN
    p_x_route_rec.route_type := l_old_route_rec.route_type;
  ELSIF ( p_x_route_rec.route_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.route_type := null;
  END IF;
  --pdoki added for Bug 6504159
  IF ( p_x_route_rec.unit_receipt_update_flag IS NULL ) THEN
    p_x_route_rec.unit_receipt_update_flag := l_old_route_rec.unit_receipt_update_flag;
  ELSIF ( p_x_route_rec.unit_receipt_update_flag = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.unit_receipt_update_flag := 'N';
  END IF;

  --bachandr Enigma Phase I changes -- start
  -- default the missing attributes only when  it is a non-Enigma Route

  IF ( l_old_route_rec.enigma_doc_id IS NULL )  THEN
	  IF ( p_x_route_rec.model_code IS NULL ) THEN
	    p_x_route_rec.model_code := l_old_route_rec.model_code;
	  ELSIF ( p_x_route_rec.model_code = FND_API.G_MISS_CHAR ) THEN
	    p_x_route_rec.model_code := null;
	  END IF;

	  IF ( p_x_route_rec.model_meaning IS NULL ) THEN
	    p_x_route_rec.model_meaning := l_old_route_rec.model_meaning;
	  ELSIF ( p_x_route_rec.model_meaning = FND_API.G_MISS_CHAR ) THEN
	    p_x_route_rec.model_meaning := null;
	  END IF;
  END IF;
  --bachandr Enigma Phase I changes -- end

  IF ( p_x_route_rec.process_code IS NULL ) THEN
    p_x_route_rec.process_code := l_old_route_rec.process_code;
  ELSIF ( p_x_route_rec.process_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.process_code := null;
  END IF;

  IF ( p_x_route_rec.process IS NULL ) THEN
    p_x_route_rec.process := l_old_route_rec.process;
  ELSIF ( p_x_route_rec.process = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.process := null;
  END IF;

  IF ( p_x_route_rec.product_type_code IS NULL ) THEN
    p_x_route_rec.product_type_code := l_old_route_rec.product_type_code;
  ELSIF ( p_x_route_rec.product_type_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.product_type_code := null;
  END IF;

  IF ( p_x_route_rec.product_type IS NULL ) THEN
    p_x_route_rec.product_type := l_old_route_rec.product_type;
  ELSIF ( p_x_route_rec.product_type = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.product_type := null;
  END IF;

  IF ( p_x_route_rec.operator_party_id IS NULL ) THEN
    p_x_route_rec.operator_party_id := l_old_route_rec.operator_party_id;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_OPERATOR_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.operator_party_id = FND_API.G_MISS_NUM ) THEN
  p_x_route_rec.operator_party_id := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.operator_name IS NULL ) THEN
    p_x_route_rec.operator_name := l_old_route_rec.operator_name;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_OPERATOR_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.operator_name = FND_API.G_MISS_CHAR ) THEN
  p_x_route_rec.operator_name := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.zone_code IS NULL ) THEN
    p_x_route_rec.zone_code := l_old_route_rec.zone_code;
  ELSIF ( p_x_route_rec.zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.zone_code := null;
  END IF;

  IF ( p_x_route_rec.zone IS NULL ) THEN
    p_x_route_rec.zone := l_old_route_rec.zone;
  ELSIF ( p_x_route_rec.zone = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.zone := null;
  END IF;

  IF ( p_x_route_rec.sub_zone_code IS NULL ) THEN
    p_x_route_rec.sub_zone_code := l_old_route_rec.sub_zone_code;
  ELSIF ( p_x_route_rec.sub_zone_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.sub_zone_code := null;
  END IF;

  IF ( p_x_route_rec.sub_zone IS NULL ) THEN
    p_x_route_rec.sub_zone := l_old_route_rec.sub_zone;
  ELSIF ( p_x_route_rec.sub_zone = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.sub_zone := null;
  END IF;

  IF ( p_x_route_rec.service_item_id IS NULL ) THEN
    p_x_route_rec.service_item_id := l_old_route_rec.service_item_id;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_SVC_ITEM_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.service_item_id = FND_API.G_MISS_NUM ) THEN
  p_x_route_rec.service_item_id := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.service_item_org_id IS NULL ) THEN
    p_x_route_rec.service_item_org_id := l_old_route_rec.service_item_org_id;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_SVC_ITEM_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.service_item_org_id = FND_API.G_MISS_NUM ) THEN
  p_x_route_rec.service_item_org_id := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.service_item_number IS NULL ) THEN
    p_x_route_rec.service_item_number := l_old_route_rec.service_item_number;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_SVC_ITEM_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.service_item_number = FND_API.G_MISS_CHAR ) THEN
  p_x_route_rec.service_item_number := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.accounting_class_code IS NULL ) THEN
    p_x_route_rec.accounting_class_code := l_old_route_rec.accounting_class_code;
  ELSIF ( p_x_route_rec.accounting_class_code = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.accounting_class_code := null;
  END IF;

  IF ( p_x_route_rec.accounting_class_org_id IS NULL ) THEN
    p_x_route_rec.accounting_class_org_id := l_old_route_rec.accounting_class_org_id;
  ELSIF ( p_x_route_rec.accounting_class_org_id = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.accounting_class_org_id := null;
  END IF;

  IF ( p_x_route_rec.accounting_class IS NULL ) THEN
    p_x_route_rec.accounting_class := l_old_route_rec.accounting_class;
  ELSIF ( p_x_route_rec.accounting_class = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.accounting_class := null;
  END IF;

  IF ( p_x_route_rec.task_template_group_id IS NULL ) THEN
    p_x_route_rec.task_template_group_id := l_old_route_rec.task_template_group_id;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_TASK_TEMP_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.task_template_group_id = FND_API.G_MISS_NUM ) THEN
  p_x_route_rec.task_template_group_id := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.task_template_group IS NULL ) THEN
    p_x_route_rec.task_template_group := l_old_route_rec.task_template_group;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_TASK_TEMP_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.task_template_group = FND_API.G_MISS_CHAR ) THEN
  p_x_route_rec.task_template_group := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.qa_inspection_type IS NULL ) THEN
    p_x_route_rec.qa_inspection_type := l_old_route_rec.qa_inspection_type;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_QA_INSP_TYPE_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.qa_inspection_type = FND_API.G_MISS_CHAR ) THEN
  p_x_route_rec.qa_inspection_type := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.qa_inspection_type_desc IS NULL ) THEN
    p_x_route_rec.qa_inspection_type_desc := l_old_route_rec.qa_inspection_type_desc;
  ELSE
    IF ( l_read_only_flag = 'Y' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_QA_INSP_TYPE_RO' );
      FND_MSG_PUB.add;
    ELSE
      IF ( p_x_route_rec.qa_inspection_type_desc = FND_API.G_MISS_CHAR ) THEN
  p_x_route_rec.qa_inspection_type_desc := null;
      END IF;
    END IF;
  END IF;

  IF ( p_x_route_rec.time_span IS NULL ) THEN
    p_x_route_rec.time_span := l_old_route_rec.time_span;
  ELSIF ( p_x_route_rec.time_span = FND_API.G_MISS_NUM ) THEN
    p_x_route_rec.time_span := null;
  END IF;

  IF ( p_x_route_rec.remarks IS NULL ) THEN
    p_x_route_rec.remarks := l_old_route_rec.remarks;
  ELSIF ( p_x_route_rec.remarks = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.remarks := null;
  END IF;

  IF ( p_x_route_rec.revision_notes IS NULL ) THEN
    p_x_route_rec.revision_notes := l_old_route_rec.revision_notes;
  ELSIF ( p_x_route_rec.revision_notes = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.revision_notes := null;
  END IF;

  IF ( p_x_route_rec.segment1 IS NULL ) THEN
    p_x_route_rec.segment1 := l_old_route_rec.segment1;
  ELSIF ( p_x_route_rec.segment1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment1 := null;
  END IF;

  IF ( p_x_route_rec.segment2 IS NULL ) THEN
    p_x_route_rec.segment2 := l_old_route_rec.segment2;
  ELSIF ( p_x_route_rec.segment2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment2 := null;
  END IF;

  IF ( p_x_route_rec.segment3 IS NULL ) THEN
    p_x_route_rec.segment3 := l_old_route_rec.segment3;
  ELSIF ( p_x_route_rec.segment3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment3 := null;
  END IF;

  IF ( p_x_route_rec.segment4 IS NULL ) THEN
    p_x_route_rec.segment4 := l_old_route_rec.segment4;
  ELSIF ( p_x_route_rec.segment4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment4 := null;
  END IF;

  IF ( p_x_route_rec.segment5 IS NULL ) THEN
    p_x_route_rec.segment5 := l_old_route_rec.segment5;
  ELSIF ( p_x_route_rec.segment5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment5 := null;
  END IF;

  IF ( p_x_route_rec.segment6 IS NULL ) THEN
    p_x_route_rec.segment6 := l_old_route_rec.segment6;
  ELSIF ( p_x_route_rec.segment6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment6 := null;
  END IF;

  IF ( p_x_route_rec.segment7 IS NULL ) THEN
    p_x_route_rec.segment7 := l_old_route_rec.segment7;
  ELSIF ( p_x_route_rec.segment7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment7 := null;
  END IF;

  IF ( p_x_route_rec.segment8 IS NULL ) THEN
    p_x_route_rec.segment8 := l_old_route_rec.segment8;
  ELSIF ( p_x_route_rec.segment8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment8 := null;
  END IF;

  IF ( p_x_route_rec.segment9 IS NULL ) THEN
    p_x_route_rec.segment9 := l_old_route_rec.segment9;
  ELSIF ( p_x_route_rec.segment9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment9 := null;
  END IF;

  IF ( p_x_route_rec.segment10 IS NULL ) THEN
    p_x_route_rec.segment10 := l_old_route_rec.segment10;
  ELSIF ( p_x_route_rec.segment10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment10 := null;
  END IF;

  IF ( p_x_route_rec.segment11 IS NULL ) THEN
    p_x_route_rec.segment11 := l_old_route_rec.segment11;
  ELSIF ( p_x_route_rec.segment11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment11 := null;
  END IF;

  IF ( p_x_route_rec.segment12 IS NULL ) THEN
    p_x_route_rec.segment12 := l_old_route_rec.segment12;
  ELSIF ( p_x_route_rec.segment12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment12 := null;
  END IF;

  IF ( p_x_route_rec.segment13 IS NULL ) THEN
    p_x_route_rec.segment13 := l_old_route_rec.segment13;
  ELSIF ( p_x_route_rec.segment13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment13 := null;
  END IF;

  IF ( p_x_route_rec.segment14 IS NULL ) THEN
    p_x_route_rec.segment14 := l_old_route_rec.segment14;
  ELSIF ( p_x_route_rec.segment14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment14 := null;
  END IF;

  IF ( p_x_route_rec.segment15 IS NULL ) THEN
    p_x_route_rec.segment15 := l_old_route_rec.segment15;
  ELSIF ( p_x_route_rec.segment15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.segment15 := null;
  END IF;

  IF ( p_x_route_rec.attribute_category IS NULL ) THEN
    p_x_route_rec.attribute_category := l_old_route_rec.attribute_category;
  ELSIF ( p_x_route_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute_category := null;
  END IF;

  IF ( p_x_route_rec.attribute1 IS NULL ) THEN
    p_x_route_rec.attribute1 := l_old_route_rec.attribute1;
  ELSIF ( p_x_route_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute1 := null;
  END IF;

  IF ( p_x_route_rec.attribute2 IS NULL ) THEN
    p_x_route_rec.attribute2 := l_old_route_rec.attribute2;
  ELSIF ( p_x_route_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute2 := null;
  END IF;

  IF ( p_x_route_rec.attribute3 IS NULL ) THEN
    p_x_route_rec.attribute3 := l_old_route_rec.attribute3;
  ELSIF ( p_x_route_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute3 := null;
  END IF;

  IF ( p_x_route_rec.attribute4 IS NULL ) THEN
    p_x_route_rec.attribute4 := l_old_route_rec.attribute4;
  ELSIF ( p_x_route_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute4 := null;
  END IF;

  IF ( p_x_route_rec.attribute5 IS NULL ) THEN
    p_x_route_rec.attribute5 := l_old_route_rec.attribute5;
  ELSIF ( p_x_route_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute5 := null;
  END IF;

  IF ( p_x_route_rec.attribute6 IS NULL ) THEN
    p_x_route_rec.attribute6 := l_old_route_rec.attribute6;
  ELSIF ( p_x_route_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute6 := null;
  END IF;

  IF ( p_x_route_rec.attribute7 IS NULL ) THEN
    p_x_route_rec.attribute7 := l_old_route_rec.attribute7;
  ELSIF ( p_x_route_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute7 := null;
  END IF;

  IF ( p_x_route_rec.attribute8 IS NULL ) THEN
    p_x_route_rec.attribute8 := l_old_route_rec.attribute8;
  ELSIF ( p_x_route_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute8 := null;
  END IF;

  IF ( p_x_route_rec.attribute9 IS NULL ) THEN
    p_x_route_rec.attribute9 := l_old_route_rec.attribute9;
  ELSIF ( p_x_route_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute9 := null;
  END IF;

  IF ( p_x_route_rec.attribute10 IS NULL ) THEN
    p_x_route_rec.attribute10 := l_old_route_rec.attribute10;
  ELSIF ( p_x_route_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute10 := null;
  END IF;

  IF ( p_x_route_rec.attribute11 IS NULL ) THEN
    p_x_route_rec.attribute11 := l_old_route_rec.attribute11;
  ELSIF ( p_x_route_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute11 := null;
  END IF;

  IF ( p_x_route_rec.attribute12 IS NULL ) THEN
    p_x_route_rec.attribute12 := l_old_route_rec.attribute12;
  ELSIF ( p_x_route_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute12 := null;
  END IF;

  IF ( p_x_route_rec.attribute13 IS NULL ) THEN
    p_x_route_rec.attribute13 := l_old_route_rec.attribute13;
  ELSIF ( p_x_route_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute13 := null;
  END IF;

  IF ( p_x_route_rec.attribute14 IS NULL ) THEN
    p_x_route_rec.attribute14 := l_old_route_rec.attribute14;
  ELSIF ( p_x_route_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute14 := null;
  END IF;

  IF ( p_x_route_rec.attribute15 IS NULL ) THEN
    p_x_route_rec.attribute15 := l_old_route_rec.attribute15;
  ELSIF ( p_x_route_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_route_rec.attribute15 := null;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual route attributes
PROCEDURE validate_attributes
(
  p_route_rec     IN  route_rec_type,
  x_return_status   OUT NOCOPY   VARCHAR2
)
IS

l_return_status    VARCHAR2(1);
l_msg_data     VARCHAR2(2000);
l_res_max_duration NUMBER;

cursor validate_route_ovn
is
select 'x'
from ahl_routes_app_v
where route_id = p_route_rec.route_id and
object_version_number = p_route_rec.object_version_number;

l_dummy   VARCHAR2(1);
--bachandr Enigma Phase I changes -- start
l_enigma_avail  varchar2(80);
--bachandr Enigma Phase I changes -- end

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the Revision Status code does not column contains a null value.
  /*
   *  Removing this as revision status for a newly created route is always DRAFT and need not be passed from
   *  by the caller.
   *  Changes made by balaji as a part of public API cleanup in 11510+
   */
  /*
  IF ( ( p_route_rec.dml_operation = 'C' AND
   p_route_rec.revision_status_code IS NULL ) OR
       p_route_rec.revision_status_code = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_STATUS_NULL' );
    FND_MSG_PUB.add;
  END IF;
  */

  -- Check if the Route Number does not column contains a null value.
  IF ( ( p_route_rec.dml_operation = 'C' AND
   p_route_rec.route_no IS NULL ) OR
   p_route_rec.route_no = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ROUTE_NO_NULL' );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Route Title does not column contains a null value.
  IF ( ( p_route_rec.dml_operation = 'C' AND
   p_route_rec.title IS NULL ) OR
       p_route_rec.title = FND_API.G_MISS_CHAR ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ROUTE_TITLE_NULL' );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Route Start Date does not column contains a null value.
  IF ( ( p_route_rec.dml_operation = 'C' AND
   p_route_rec.active_start_date IS NULL ) OR
       p_route_rec.active_start_date = FND_API.G_MISS_DATE ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ST_DATE_NULL' );
    FND_MSG_PUB.add;
  END IF;

  --bachandr Enigma Phase I changes -- start
  -- Time Span is no longer a mandatory field during creat/update of Routes from Enigma
  -- Moving the validation to approval flow when it is a Enigma Route
  -- Check if the Time Span does not column contains a null value.
  SELECT trim(fnd_profile.value('AHL_ENIGMA_3C_URL')) INTO l_enigma_avail FROM dual;
  IF l_enigma_avail = 'N' THEN
	  IF ( ( p_route_rec.dml_operation = 'C' AND
		 p_route_rec.time_span IS NULL ) OR
		 p_route_rec.time_span = FND_API.G_MISS_NUM ) THEN
	    FND_MESSAGE.set_name( 'AHL','AHL_RM_TIME_SPAN_NULL' );
	    FND_MSG_PUB.add;
	  END IF;
  END IF;

  -- Check if the model code or meaning is not null for create
  -- when the route is created from Enigma
  IF ( p_route_rec.dml_operation = 'C' AND p_route_rec.enigma_doc_id IS NOT NULL
	AND p_route_rec.enigma_doc_id <> FND_API.G_MISS_CHAR)  THEN
	IF (( p_route_rec.model_code IS NULL  OR p_route_rec.model_code = FND_API.G_MISS_CHAR ) AND
	  ( p_route_rec.model_meaning IS NULL OR p_route_rec.model_meaning = FND_API.G_MISS_CHAR ) )THEN
		 FND_MESSAGE.set_name( 'AHL','AHL_RM_MODEL_CODE_NULL' );
		 FND_MSG_PUB.add;
	END IF;
  END IF;
  --bachandr Enigma Phase I changes -- end

  -- Check if Time Span is not less than or equal to zero
  IF ( p_route_rec.time_span IS NOT NULL AND
       p_route_rec.time_span <> FND_API.G_MISS_NUM AND
       p_route_rec.time_span <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_TIME_SPAN' );
    FND_MESSAGE.set_token( 'FIELD', p_route_rec.time_span );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_route_rec.dml_operation = 'C' ) THEN
    RETURN;
  END IF;

  -- Check if the mandatory Route ID column contains a null value.
  IF ( p_route_rec.route_id IS NULL OR
       p_route_rec.route_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_ROUTE_ID_NULL' );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_route_rec.object_version_number IS NULL OR
       p_route_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_OBJ_VERSION_NULL' );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

  -- Validate whether the Time Span of the Route is Greater than the Longest Resource Duration for the Same Route and all the Associated Operations
  IF ( p_route_rec.time_span IS NOT NULL AND
       p_route_rec.time_span <> FND_API.G_MISS_NUM AND
       p_route_rec.time_span > 0 ) THEN

    -- Bug # 8639648 - start
    AHL_RM_ROUTE_UTIL.validate_route_time_span
    (
      x_return_status      => l_return_status,
      x_msg_data       => l_msg_data,
      p_route_id       => p_route_rec.route_id,
      p_time_span      => p_route_rec.time_span,
      p_rou_start_date => p_route_rec.active_start_date,
      x_res_max_duration     => l_res_max_duration
    );

    -- Bug # 8639648 - end

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD1', l_res_max_duration );
      FND_MESSAGE.set_token( 'FIELD2', p_route_rec.time_span );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Added by Tamal for Bug #3854052
  IF (p_route_rec.dml_operation = 'U' AND p_route_rec.revision_status_code IN ('COMPLETE', 'APPROVAL_PENDING', 'TERMINATION_PENDING', 'TERMINATED'))
  THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_RT_STS_NO_UPD' );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  -- Added by Tamal for Bug #3854052

  IF (p_route_rec.dml_operation IN ('U','D'))
  THEN
    OPEN validate_route_ovn;
    FETCH validate_route_ovn INTO l_dummy;
    IF (validate_route_ovn%NOTFOUND)
    THEN
    FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
          FND_MSG_PUB.add;
    END IF;
  END IF;

END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks and duplicate checks
PROCEDURE validate_record
(
  p_route_rec     IN  route_rec_type,
  x_return_status   OUT NOCOPY   VARCHAR2
)
IS

l_return_status        VARCHAR2(1);
l_msg_data         VARCHAR2(2000);
l_route_id                   NUMBER;
l_start_date         DATE;


CURSOR get_dup_rec( c_route_no VARCHAR2 , c_revision_number NUMBER )
IS
SELECT route_id
FROM   AHL_ROUTES_APP_V
WHERE  UPPER(TRIM(route_no)) = UPPER(TRIM(c_route_no))
AND    revision_number = nvl(c_revision_number,1);

BEGIN
  --x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if Duplicate Route Number exists
  OPEN get_dup_rec( p_route_rec.route_no , p_route_rec.revision_number );

  FETCH get_dup_rec INTO l_route_id;

  IF ( p_route_rec.dml_operation = 'C' )
  THEN
  -- if its create then p_route_rec.route_id = null and any duplicate record should make you throw an err.
    IF ( get_dup_rec%FOUND ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_NO_DUP' );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  ELSIF  ( p_route_rec.dml_operation = 'U' )
  THEN
    IF ( l_route_id <> p_route_rec.route_id ) THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_NO_DUP' );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  CLOSE get_dup_rec;

  -- Check if the Route Start Date is not less than today's date
  /*
  IF ( ( p_route_rec.revision_status_code = 'DRAFT' OR
   p_route_rec.revision_status_code = 'APPROVAL_REJECTED' ) AND
       p_route_rec.active_start_date IS NOT NULL AND
       p_route_rec.active_start_date <> FND_API.G_MISS_DATE AND
       TRUNC( p_route_rec.active_start_date ) < TRUNC( SYSDATE ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_INVALID_ST_DATE' );
    FND_MESSAGE.set_token( 'FIELD', SYSDATE );
    FND_MSG_PUB.add;
  END IF;
*/
  -- Check if Active start date is less than today's date and the start
  -- date of the latest revision for DRAFT and APPROVAL_REJECTED Routes
  IF ( ( p_route_rec.revision_status_code = 'DRAFT' OR
   p_route_rec.revision_status_code = 'APPROVAL_REJECTED' ) AND
       p_route_rec.route_id IS NOT NULL AND
       p_route_rec.active_start_date IS NOT NULL ) THEN

    AHL_RM_ROUTE_UTIL.validate_rt_oper_start_date
    (
      x_return_status        => l_return_status,
      x_msg_data         => l_msg_data,
      p_association_type       => 'ROUTE',
      p_object_id        => p_route_rec.route_id,
      p_start_date         => p_route_rec.active_start_date,
      x_start_date         => l_start_date
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD', l_start_date );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  -- Check if Zone contains a value but, the Product Type is NULL
  IF ( ( p_route_rec.zone IS NOT NULL OR
   p_route_rec.zone_code IS NOT NULL ) AND
       ( p_route_rec.product_type IS NULL AND
   p_route_rec.product_type_code IS NULL ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_PT_NULL_ZONE_NOTNULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if Sub Zone contains a value but, the Product Type or Zone are NULL
  IF ( ( p_route_rec.sub_zone IS NOT NULL OR
   p_route_rec.sub_zone_code IS NOT NULL ) AND
       ( ( p_route_rec.product_type IS NULL AND
     p_route_rec.product_type_code IS NULL ) OR
   ( p_route_rec.zone IS NULL AND
     p_route_rec.zone_code IS NULL ) ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_RM_PT_NULL_SUBZONE_NOTNULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Check if the Zone is valid for the Product Type
  IF ( p_route_rec.product_type_code IS NOT NULL AND
       p_route_rec.zone_code IS NOT NULL ) THEN

    AHL_RM_ROUTE_UTIL.validate_pt_zone
    (
      x_return_status        => l_return_status,
      x_msg_data         => l_msg_data,
      p_product_type_code      => p_route_rec.product_type_code,
      p_zone_code        => p_route_rec.zone_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      IF ( p_route_rec.zone IS NULL ) THEN
  FND_MESSAGE.set_token( 'FIELD1', p_route_rec.zone_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD1', p_route_rec.zone );
      END IF;

      IF ( p_route_rec.product_type IS NULL ) THEN
  FND_MESSAGE.set_token( 'FIELD2', p_route_rec.product_type_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD2', p_route_rec.product_type );
      END IF;

      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  -- Check if the Sub Zone is valid for the Product Type and Zone
  IF ( p_route_rec.product_type_code IS NOT NULL AND
       p_route_rec.zone_code IS NOT NULL AND
       p_route_rec.sub_zone_code IS NOT NULL ) THEN

    AHL_RM_ROUTE_UTIL.validate_pt_zone_subzone
    (
      x_return_status        => l_return_status,
      x_msg_data         => l_msg_data,
      p_product_type_code      => p_route_rec.product_type_code,
      p_zone_code        => p_route_rec.zone_code,
      p_sub_zone_code        => p_route_rec.sub_zone_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      IF ( p_route_rec.sub_zone IS NULL ) THEN
  FND_MESSAGE.set_token( 'FIELD1', p_route_rec.sub_zone_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD1', p_route_rec.sub_zone );
      END IF;

      IF ( p_route_rec.zone IS NULL ) THEN
  FND_MESSAGE.set_token( 'FIELD2', p_route_rec.zone_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD2', p_route_rec.zone );
      END IF;

      IF ( p_route_rec.product_type IS NULL ) THEN
  FND_MESSAGE.set_token( 'FIELD3', p_route_rec.product_type_code );
      ELSE
  FND_MESSAGE.set_token( 'FIELD3', p_route_rec.product_type );
      END IF;

      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END validate_record;

PROCEDURE process_route
(
 p_api_version        IN      NUMBER     := '1.0',
 p_init_msg_list      IN      VARCHAR2   := FND_API.G_TRUE,
 p_commit       IN      VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default        IN      VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN      VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count        OUT NOCOPY    NUMBER,
 x_msg_data       OUT NOCOPY    VARCHAR2,
 p_x_route_rec        IN OUT NOCOPY route_rec_type
)
IS
l_api_name   CONSTANT   VARCHAR2(30)   := 'process_route';
l_api_version  CONSTANT   NUMBER     := 1.0;
l_return_status       VARCHAR2(1);
l_msg_count       NUMBER;
l_rowid         VARCHAR2(30)   := NULL;
l_kfv_flag           VARCHAR2(1)    := NULL; --amsriniv. Bug 6695219
l_concat_segs       VARCHAR2(500)  := NULL; --amsriniv. Bug 6695219
--bachandr Enigma Phase I changes -- start
concat			    VARCHAR2(1)	   := ':';
--bachandr Enigma Phase I changes -- end
--amsriniv. Bug 6695219 Begin.

CURSOR get_concat_segs(c_route_id NUMBER)
IS
    SELECT CONCATENATED_SEGMENTS
    FROM AHL_ROUTES_B_KFV
    WHERE ROUTE_ID = p_x_route_rec.route_id
    AND REPLACE(CONCATENATED_SEGMENTS, FND_FLEX_EXT.GET_DELIMITER('AHL', 'AHLR', 101), NULL) IS NOT NULL;


--validate system KFV to ensure that no two routes share the same System KFV.
CURSOR validate_system_kfv(c_route_no VARCHAR2, c_concat_segs VARCHAR2)
IS
    SELECT 'X'
    FROM AHL_ROUTES_B_KFV
    WHERE REPLACE(CONCATENATED_SEGMENTS, FND_FLEX_EXT.GET_DELIMITER('AHL', 'AHLR', 101), NULL) IS NOT NULL
    AND CONCATENATED_SEGMENTS = c_concat_segs
    AND ROUTE_NO <> c_route_no;
--amsriniv. End

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_route_PVT;

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

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin API' );
  END IF;

  -- Generate route_id from route_number and revision_number if it is not provided.
  IF (p_x_route_rec.dml_operation <> 'C' AND p_x_route_rec.dml_operation <> 'c') AND
     (p_x_route_rec.route_id IS NULL OR p_x_route_rec.route_id = FND_API.G_MISS_NUM)
  THEN
  -- Function to convert route_number, route_revision to id
  AHL_RM_ROUTE_UTIL.Route_Number_To_Id(
    p_route_number    =>  p_x_route_rec.route_no,
    p_route_revision  =>  p_x_route_rec.revision_number,
    x_route_id    =>  p_x_route_rec.route_id,
    x_return_status   =>  x_return_status
    );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
     (
         fnd_log.level_statement,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
         'Error in converting Route Number, Route Revision to ID'
     );
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  END IF;

  --This is to be added before calling   validate_api_inputs
  IF ( p_x_route_rec.dml_operation = 'U' )
  THEN
  -- Validate Application Usage
  AHL_RM_ROUTE_UTIL.validate_ApplnUsage
  (
     p_object_id        => p_x_route_rec.route_id,
     p_association_type       => 'ROUTE',
     x_return_status        => x_return_status,
     x_msg_data         => x_msg_data
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
    p_x_route_rec, -- IN
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
      p_x_route_rec -- IN OUT Record with Values and Ids
    );
  END IF;

  -- Convert Values into Ids.
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    convert_values_to_ids
    (
      p_x_route_rec , -- IN OUT Record with Values and Ids
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after convert_values_to_ids' );
  END IF;

  /* Balaji removed it as a part of public API cleanup as this defaulting logic should not be bound by p_default value. Instead the logic is moved to DML.
  -- Default route attributes.
  IF FND_API.to_boolean( p_default ) THEN
    default_attributes
    (
      p_x_route_rec -- IN OUT
    );
  END IF;
  */

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after default_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  IF ( p_x_route_rec.dml_operation = 'U' ) THEN
    default_unchanged_attributes
    (
      p_x_route_rec -- IN OUT
    );
  ELSIF ( p_x_route_rec.dml_operation = 'C' ) THEN
    default_missing_attributes
    (
      p_x_route_rec -- IN OUT
    );
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    validate_attributes
    (
      p_x_route_rec, -- IN
      l_return_status -- OUT
    );

    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after validate_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
  -- Balaji removed p_validation_level check in 11510+ as a part of public api cleanup.
  --IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    validate_record
    (
      p_x_route_rec, -- IN
      l_return_status -- OUT
    );

    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --END IF;

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
  IF ( p_x_route_rec.dml_operation = 'C' ) THEN

      BEGIN

  -- Get the Route ID from the Sequence
  SELECT AHL_ROUTES_B_S.NEXTVAL
  INTO   p_x_route_rec.route_id
  FROM   DUAL;

  --bachandr Enigma Phase I changes -- start
  -- Append the model code if any to the route No
     IF ( (p_x_route_rec.model_code IS NOT NULL  ) AND  (p_x_route_rec.model_code <> FND_API.G_MISS_CHAR  ) ) THEN
     --AND (p_x_route_rec.model_meaning IS NOT NULL  ) AND (p_x_route_rec.model_meaning <> FND_API.G_MISS_CHAR  )) THEN
  	 p_x_route_rec.route_no := p_x_route_rec.model_code  || concat || p_x_route_rec.route_no ;

  	 --dbms_output.put_line('Inside If');
     END IF;

  --dbms_output.put_line('p_x_route_rec.route_no is '||p_x_route_rec.route_no);
  --bachandr Enigma Phase I changes -- end

  -- Insert the record
  AHL_ROUTES_PKG.insert_row
  (
    X_ROWID        =>  l_rowid ,
    X_ROUTE_ID         =>  p_x_route_rec.route_id ,
    X_OBJECT_VERSION_NUMBER    =>  1 ,
    X_ROUTE_NO         =>  p_x_route_rec.route_no ,
    X_APPLICATION_USG_CODE     =>  rtrim(ltrim(FND_PROFILE.value( 'AHL_APPLN_USAGE' ))),
    X_REVISION_NUMBER      =>  1 ,
    X_REVISION_STATUS_CODE     =>  'DRAFT' ,
    X_UNIT_RECEIPT_UPDATE_FLAG =>  p_x_route_rec.unit_receipt_update_flag , --pdoki Bug 6504159.
    X_START_DATE_ACTIVE      =>  p_x_route_rec.active_start_date ,
    X_END_DATE_ACTIVE      =>  p_x_route_rec.active_end_date ,
    X_OPERATOR_PARTY_ID      =>  p_x_route_rec.operator_party_id ,
    X_QA_INSPECTION_TYPE       =>  p_x_route_rec.qa_inspection_type ,
    X_SERVICE_ITEM_ID      =>  p_x_route_rec.service_item_id ,
    X_SERVICE_ITEM_ORG_ID      =>  p_x_route_rec.service_item_org_id ,
    X_TASK_TEMPLATE_GROUP_ID   =>  p_x_route_rec.task_template_group_id ,
    X_ACCOUNTING_CLASS_CODE    =>  p_x_route_rec.accounting_class_code ,
    X_ACCOUNTING_CLASS_ORG_ID  =>  p_x_route_rec.accounting_class_org_id ,
    X_ROUTE_TYPE_CODE      =>  p_x_route_rec.route_type_code ,
    X_PRODUCT_TYPE_CODE      =>  p_x_route_rec.product_type_code ,
    --bachandr Enigma Phase I changes -- start
    X_MODEL_CODE		     =>	 p_x_route_rec.model_code ,
    X_ENIGMA_PUBLISH_DATE	     =>  p_x_route_rec.enigma_publish_date,
    X_ENIGMA_DOC_ID	     =>  p_x_route_rec.enigma_doc_id,
    X_ENIGMA_ROUTE_ID	     =>  p_x_route_rec.enigma_route_id,
    X_FILE_ID	     	     =>  p_x_route_rec.file_id,
    --bachandr Enigma Phase I changes -- end
    X_ZONE_CODE        =>  p_x_route_rec.zone_code ,
    X_SUB_ZONE_CODE      =>  p_x_route_rec.sub_zone_code ,
    X_PROCESS_CODE       =>  p_x_route_rec.process_code ,
    X_TIME_SPAN        =>  p_x_route_rec.time_span ,
    X_SEGMENT1         =>  p_x_route_rec.segment1 ,
    X_SEGMENT2         =>  p_x_route_rec.segment2 ,
    X_SEGMENT3         =>  p_x_route_rec.segment3 ,
    X_SEGMENT4         =>  p_x_route_rec.segment4 ,
    X_SEGMENT5         =>  p_x_route_rec.segment5 ,
    X_SEGMENT6         =>  p_x_route_rec.segment6 ,
    X_SEGMENT7         =>  p_x_route_rec.segment7 ,
    X_SEGMENT8         =>  p_x_route_rec.segment8 ,
    X_SEGMENT9         =>  p_x_route_rec.segment9 ,
    X_SEGMENT10        =>  p_x_route_rec.segment10 ,
    X_SEGMENT11        =>  p_x_route_rec.segment11 ,
    X_SEGMENT12        =>  p_x_route_rec.segment12 ,
    X_SEGMENT13        =>  p_x_route_rec.segment13 ,
    X_SEGMENT14        =>  p_x_route_rec.segment14 ,
    X_SEGMENT15        =>  p_x_route_rec.segment15 ,
    X_ATTRIBUTE_CATEGORY       =>  p_x_route_rec.attribute_category ,
    X_ATTRIBUTE1         =>  p_x_route_rec.attribute1 ,
    X_ATTRIBUTE2         =>  p_x_route_rec.attribute2 ,
    X_ATTRIBUTE3         =>  p_x_route_rec.attribute3 ,
    X_ATTRIBUTE4         =>  p_x_route_rec.attribute4 ,
    X_ATTRIBUTE5         =>  p_x_route_rec.attribute5 ,
    X_ATTRIBUTE6         =>  p_x_route_rec.attribute6 ,
    X_ATTRIBUTE7         =>  p_x_route_rec.attribute7 ,
    X_ATTRIBUTE8         =>  p_x_route_rec.attribute8 ,
    X_ATTRIBUTE9         =>  p_x_route_rec.attribute9 ,
    X_ATTRIBUTE10        =>  p_x_route_rec.attribute10 ,
    X_ATTRIBUTE11        =>  p_x_route_rec.attribute11 ,
    X_ATTRIBUTE12        =>  p_x_route_rec.attribute12 ,
    X_ATTRIBUTE13        =>  p_x_route_rec.attribute13 ,
    X_ATTRIBUTE14        =>  p_x_route_rec.attribute14 ,
    X_ATTRIBUTE15        =>  p_x_route_rec.attribute15 ,
    X_TITLE        =>  p_x_route_rec.title ,
    X_REMARKS        =>  p_x_route_rec.remarks ,
    X_REVISION_NOTES       =>  p_x_route_rec.revision_notes ,
    X_CREATION_DATE      =>  G_CREATION_DATE ,
    X_CREATED_BY         =>  G_CREATED_BY ,
    X_LAST_UPDATE_DATE       =>  G_LAST_UPDATE_DATE ,
    X_LAST_UPDATED_BY      =>  G_LAST_UPDATED_BY ,
    X_LAST_UPDATE_LOGIN      =>  G_LAST_UPDATE_LOGIN,
    X_ENABLED_FLAG       =>  'Y',
    X_SUMMARY_FLAG       =>  'N'
  );
      EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
  WHEN OTHERS THEN
    IF ( SQLCODE = -1 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_NO_DUP' );
      FND_MSG_PUB.add;
    ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
      'AHL_ROUTES_PKG.insert_row error = ['||SQLERRM||']'
    );
        END IF;
          END IF;
      END;

  ELSIF ( p_x_route_rec.dml_operation = 'U' ) THEN

      BEGIN
  -- Update the record

  p_x_route_rec.object_version_number := p_x_route_rec.object_version_number + 1;

  AHL_ROUTES_PKG.update_row
  (
    X_ROUTE_ID          =>  p_x_route_rec.route_id ,
    X_OBJECT_VERSION_NUMBER     =>  p_x_route_rec.object_version_number ,
    X_ROUTE_NO          =>  p_x_route_rec.route_no ,
    X_REVISION_NUMBER       =>  p_x_route_rec.revision_number ,
    X_REVISION_STATUS_CODE      =>  p_x_route_rec.revision_status_code ,
    X_UNIT_RECEIPT_UPDATE_FLAG  =>  p_x_route_rec.unit_receipt_update_flag ,--pdoki Bug 6504159.
    X_START_DATE_ACTIVE       =>  p_x_route_rec.active_start_date ,
    X_END_DATE_ACTIVE       =>  p_x_route_rec.active_end_date ,
    X_OPERATOR_PARTY_ID       =>  p_x_route_rec.operator_party_id ,
    X_QA_INSPECTION_TYPE        =>  p_x_route_rec.qa_inspection_type ,
    X_SERVICE_ITEM_ID       =>  p_x_route_rec.service_item_id ,
    X_SERVICE_ITEM_ORG_ID       =>  p_x_route_rec.service_item_org_id ,
    X_TASK_TEMPLATE_GROUP_ID    =>  p_x_route_rec.task_template_group_id ,
    X_ACCOUNTING_CLASS_CODE     =>  p_x_route_rec.accounting_class_code ,
    X_ACCOUNTING_CLASS_ORG_ID   =>  p_x_route_rec.accounting_class_org_id,
    X_ROUTE_TYPE_CODE       =>  p_x_route_rec.route_type_code ,
    X_PRODUCT_TYPE_CODE       =>  p_x_route_rec.product_type_code ,
    --bachandr Enigma Phase I changes -- start
    X_MODEL_CODE		      =>  p_x_route_rec.model_code ,
    X_FILE_ID                   =>  p_x_route_rec.file_id,
    --bachandr Enigma Phase I changes -- end
    X_ZONE_CODE         =>  p_x_route_rec.zone_code ,
    X_SUB_ZONE_CODE       =>  p_x_route_rec.sub_zone_code ,
    X_PROCESS_CODE        =>  p_x_route_rec.process_code ,
    X_TIME_SPAN         =>  p_x_route_rec.time_span ,
    X_SEGMENT1          =>  p_x_route_rec.segment1 ,
    X_SEGMENT2          =>  p_x_route_rec.segment2 ,
    X_SEGMENT3          =>  p_x_route_rec.segment3 ,
    X_SEGMENT4          =>  p_x_route_rec.segment4 ,
    X_SEGMENT5          =>  p_x_route_rec.segment5 ,
    X_SEGMENT6          =>  p_x_route_rec.segment6 ,
    X_SEGMENT7          =>  p_x_route_rec.segment7 ,
    X_SEGMENT8          =>  p_x_route_rec.segment8 ,
    X_SEGMENT9          =>  p_x_route_rec.segment9 ,
    X_SEGMENT10         =>  p_x_route_rec.segment10 ,
    X_SEGMENT11         =>  p_x_route_rec.segment11 ,
    X_SEGMENT12         =>  p_x_route_rec.segment12 ,
    X_SEGMENT13         =>  p_x_route_rec.segment13 ,
    X_SEGMENT14         =>  p_x_route_rec.segment14 ,
    X_SEGMENT15         =>  p_x_route_rec.segment15 ,
    X_ATTRIBUTE_CATEGORY        =>  p_x_route_rec.attribute_category ,
    X_ATTRIBUTE1          =>  p_x_route_rec.attribute1 ,
    X_ATTRIBUTE2          =>  p_x_route_rec.attribute2 ,
    X_ATTRIBUTE3          =>  p_x_route_rec.attribute3 ,
    X_ATTRIBUTE4          =>  p_x_route_rec.attribute4 ,
    X_ATTRIBUTE5          =>  p_x_route_rec.attribute5 ,
    X_ATTRIBUTE6          =>  p_x_route_rec.attribute6 ,
    X_ATTRIBUTE7          =>  p_x_route_rec.attribute7 ,
    X_ATTRIBUTE8          =>  p_x_route_rec.attribute8 ,
    X_ATTRIBUTE9          =>  p_x_route_rec.attribute9 ,
    X_ATTRIBUTE10         =>  p_x_route_rec.attribute10 ,
    X_ATTRIBUTE11         =>  p_x_route_rec.attribute11 ,
    X_ATTRIBUTE12         =>  p_x_route_rec.attribute12 ,
    X_ATTRIBUTE13         =>  p_x_route_rec.attribute13 ,
    X_ATTRIBUTE14         =>  p_x_route_rec.attribute14 ,
    X_ATTRIBUTE15         =>  p_x_route_rec.attribute15 ,
    X_TITLE         =>  p_x_route_rec.title ,
    X_REMARKS         =>  p_x_route_rec.remarks ,
    X_REVISION_NOTES        =>  p_x_route_rec.revision_notes ,
    X_LAST_UPDATE_DATE        =>  G_LAST_UPDATE_DATE ,
    X_LAST_UPDATED_BY       =>  G_LAST_UPDATED_BY ,
    X_LAST_UPDATE_LOGIN       =>  G_LAST_UPDATE_LOGIN,
    X_ENABLED_FLAG        =>  'Y',
    X_SUMMARY_FLAG        =>  'N'
  );

      EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
    FND_MSG_PUB.add;
  WHEN OTHERS THEN
    IF ( SQLCODE = -1 ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_NO_DUP' );
      FND_MSG_PUB.add;
    ELSE
              IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
      'AHL_ROUTES_PKG.update_row error = ['||SQLERRM||']'
    );
        END IF;
          END IF;
      END;

  END IF;

--amsriniv. Begin. Bug 6695219
OPEN get_concat_segs(p_x_route_rec.route_id);
FETCH get_concat_segs into l_concat_segs;
IF(get_concat_segs%FOUND)
THEN
    OPEN validate_system_kfv(p_x_route_rec.route_no, l_concat_segs);
    FETCH validate_system_kfv INTO l_kfv_flag;
    IF (validate_system_kfv%FOUND)
    THEN
        FND_MESSAGE.set_name('AHL', 'AHL_RM_INV_SYS_KFV');
        FND_MSG_PUB.add;
    END IF;
    CLOSE validate_system_kfv;
END IF;
CLOSE get_concat_segs;
--amsriniv. End

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
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_route_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_route_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO process_route_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
  p_pkg_name     => G_PKG_NAME,
  p_procedure_name   => l_api_name,
  p_error_text     => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END process_route;

PROCEDURE delete_route
(
 p_api_version     IN        NUMBER   := '1.0',
 p_init_msg_list   IN        VARCHAR2   := FND_API.G_TRUE,
 p_commit    IN        VARCHAR2   := FND_API.G_FALSE,
 p_validation_level  IN        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_default     IN        VARCHAR2   := FND_API.G_FALSE,
 p_module_type     IN        VARCHAR2   := NULL,
 x_return_status   OUT NOCOPY    VARCHAR2,
 x_msg_count     OUT NOCOPY    NUMBER,
 x_msg_data    OUT NOCOPY    VARCHAR2,
 p_route_id    IN        NUMBER,
 p_object_version_number IN        NUMBER
)
IS

l_api_name   CONSTANT   VARCHAR2(30)   := 'delete_route';
l_api_version  CONSTANT   NUMBER     := 1.0;
l_return_status       VARCHAR2(1);
l_msg_data        VARCHAR2(2000);
--bachandr Enigma Phase I changes -- start
l_doc_id		    VARCHAR2(80);
--bachandr Enigma Phase I changes -- end

CURSOR get_doc_associations( c_route_id NUMBER )
IS
SELECT doc_title_asso_id
FROM   ahl_doc_title_assos_b
WHERE  aso_object_id = c_route_id
AND    aso_object_type_code = 'ROUTE';

cursor validate_route_ovn
is
select 'x'
from ahl_routes_app_v
where route_id = p_route_id and
object_version_number = p_object_version_number;

--bachandr Enigma Phase I changes -- start
-- Cursor to get the document_id
cursor get_doc_id
is
select enigma_doc_id
from ahl_routes_b
where route_id = p_route_id;
--bachandr Enigma Phase I changes -- end

l_dummy   VARCHAR2(1);

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT delete_route_PVT;

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

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin API' );
  END IF;

  --This is to be added before calling   AHL_RM_ROUTE_UTIL.validate_route_status
  -- Validate Application Usage
  AHL_RM_ROUTE_UTIL .validate_ApplnUsage
  (
     p_object_id        => p_route_id,
     p_association_type       => 'ROUTE',
     x_return_status        => x_return_status,
     x_msg_data         => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( p_route_id IS NULL OR
       p_route_id = FND_API.G_MISS_NUM OR
       p_object_version_number IS NULL OR
       p_object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', l_api_name );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN validate_route_ovn;
  FETCH validate_route_ovn INTO l_dummy;
  IF (validate_route_ovn%NOTFOUND)
  THEN
  FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
  FND_MSG_PUB.add;
  x_return_status := FND_API.G_RET_STS_ERROR;
  RAISE FND_API.G_EXC_ERROR;
  END IF;

  --bachandr Enigma Phase I changes -- start
  -- Fetch the doc_id and if the doc_id is not null( ie an Enigma Route) then
  -- deletion is not allowed
  -- Kick the validation only if the call is from the CMRO end.
  IF (p_module_type <> 'ENIGMA' ) THEN
	  OPEN get_doc_id;
	  FETCH get_doc_id INTO l_doc_id;
	  IF (get_doc_id%FOUND AND l_doc_id IS NOT NULL)
	  THEN
		FND_MESSAGE.set_name('AHL', 'AHL_RM_ROUTE_ENIG_DEL');
		FND_MSG_PUB.add;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	  END IF;
  END IF;
  --bachandr Enigma Phase I changes -- end

  AHL_RM_ROUTE_UTIL.validate_route_status
  (
    p_route_id      => p_route_id,
    x_msg_data      => l_msg_data,
    x_return_status => l_return_status
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF ( l_msg_data = 'AHL_RM_INVALID_ROUTE_STATUS' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_STATUS_NOT_DRAFT' );
    ELSE
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
    END IF;

    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting AHL_ROUTES_B and AHL_ROUTES_TL' );
  END IF;

  -- Delete all the associations

  -- 0.Delete Effectivities
  DELETE ahl_route_effectivities
  WHERE  ROUTE_ID = p_route_id;

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Effectivities' );
  END IF;

  -- 1.Delete Material Requirements
  DELETE AHL_RT_OPER_MATERIALS
  WHERE  OBJECT_ID = p_route_id
  AND  ASSOCIATION_TYPE_CODE = 'ROUTE';

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
  WHERE  OBJECT_ID = p_route_id
  AND  ASSOCIATION_TYPE_CODE = 'ROUTE';

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Resource Requirements' );
  END IF;

  -- 3.Delete Reference Documents
  FOR I in get_doc_associations( p_route_id ) LOOP
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
  WHERE  ROUTE_ID = p_route_id;

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  -- 5.Delete Access Panel associations
  DELETE AHL_RT_OPER_ACCESS_PANELS
  WHERE  OBJECT_ID = p_route_id
  AND  ASSOCIATION_TYPE_CODE = 'ROUTE';

  -- If no records exist, then, Continue.
  IF ( SQL%ROWCOUNT = 0 ) THEN
    -- Ignore the Exception
    NULL;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Access Panels' );
  END IF;

  BEGIN
    -- Delete the record in AHL_ROUTES_B and AHL_ROUTES_TL
    AHL_ROUTES_PKG.delete_row
    (
      X_ROUTE_ID        => p_route_id
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
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' :  after Deleting Associated Operations' );
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
    ROLLBACK TO delete_route_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_route_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO delete_route_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
  p_pkg_name     => G_PKG_NAME,
  p_procedure_name   => l_api_name,
  p_error_text     => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END delete_route;

PROCEDURE create_route_revision
(
 p_api_version     IN        NUMBER   := '1.0',
 p_init_msg_list   IN        VARCHAR2   := FND_API.G_TRUE,
 p_commit    IN        VARCHAR2   := FND_API.G_FALSE,
 p_validation_level  IN        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_default     IN        VARCHAR2   := FND_API.G_FALSE,
 p_module_type     IN        VARCHAR2   := NULL,
 x_return_status   OUT NOCOPY    VARCHAR2,
 x_msg_count     OUT NOCOPY    NUMBER,
 x_msg_data    OUT NOCOPY    VARCHAR2,
 p_route_id    IN        NUMBER,
 p_object_version_number IN        NUMBER,
 x_route_id    OUT NOCOPY    NUMBER
)
IS

l_api_name   CONSTANT   VARCHAR2(30)   := 'create_route_revision';
l_api_version  CONSTANT   NUMBER     := 1.0;
l_return_status       VARCHAR2(1);
l_msg_data        VARCHAR2(2000);
l_old_route_rec       route_rec_type;
l_dummy         VARCHAR2(1);
l_revision_number     NUMBER;
l_route_id        NUMBER;
l_doc_title_assos_id      NUMBER;
l_rowid         VARCHAR2(30)   := NULL;
l_rt_oper_resource_id     NUMBER;
l_route_effectivity_id      NUMBER;

CURSOR  get_latest_revision( c_route_no VARCHAR2 )
IS
SELECT  MAX( revision_number )
FROM  AHL_ROUTES_APP_V
WHERE UPPER(TRIM(route_no)) = UPPER(TRIM(c_route_no));

CURSOR  get_doc_associations( c_route_id NUMBER )
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
FROM  AHL_DOC_TITLE_ASSOS_VL
WHERE aso_object_id = c_route_id
AND aso_object_type_code = 'ROUTE';

CURSOR get_rt_oper_resources (c_route_id NUMBER) IS
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
  WHERE object_id = c_route_id
  AND association_type_code = 'ROUTE';

CURSOR get_route_efcts (c_route_id NUMBER) IS
  SELECT
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
  FROM ahl_route_effectivities
  WHERE route_id = c_route_id
  ;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_route_revision_PVT;

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

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || l_api_name || ' : Begin API' );
  END IF;

  --This is to be added before calling   get_route_record()
  -- Validate Application Usage
  AHL_RM_ROUTE_UTIL .validate_ApplnUsage
  (
     p_object_id        => p_route_id,
     p_association_type       => 'ROUTE',
     x_return_status        => x_return_status,
     x_msg_data         => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF ( p_route_id IS NULL OR
       p_route_id = FND_API.G_MISS_NUM OR
       p_object_version_number IS NULL OR
       p_object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  get_route_record
  (
    x_return_status     => l_return_status,
    x_msg_data        => l_msg_data,
    p_route_id        => p_route_id,
    p_object_version_number => p_object_version_number,
    p_x_route_rec     => l_old_route_rec
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if the Status is COMPLETE
  IF ( l_old_route_rec.revision_status_code <> 'COMPLETE' ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_STATUS_NOT_COMPLETE' );
    FND_MESSAGE.set_token( 'RECORD', l_old_route_rec.route_no );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if this revision is not Terminated
  IF ( l_old_route_rec.active_end_date IS NOT NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_END_DATE_NOT_NULL' );
    FND_MESSAGE.set_token( 'RECORD', l_old_route_rec.route_no );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check if this revision is the latest complete revision of this Route
  OPEN get_latest_revision( l_old_route_rec.route_no );

  FETCH get_latest_revision INTO
    l_revision_number;

  IF ( l_revision_number <> l_old_route_rec.revision_number ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_RM_RT_REVISION_NOT_LATEST' );
    FND_MESSAGE.set_token( 'RECORD', l_old_route_rec.route_no );
    FND_MSG_PUB.add;
    CLOSE get_latest_revision;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_latest_revision;

  -- Default the Active Start Date
  IF ( TRUNC( l_old_route_rec.active_start_date ) < TRUNC( SYSDATE ) ) THEN
    l_old_route_rec.active_start_date := SYSDATE;
  END IF;

  -- Create copy of the route in AHL_ROUTES_B and AHL_ROUTES_TL
  BEGIN

    l_revision_number := l_revision_number + 1;

    -- Get the Route ID from the Sequence
    SELECT AHL_ROUTES_B_S.NEXTVAL
    INTO   l_route_id
    FROM   DUAL;

    -- Insert the record
    AHL_ROUTES_PKG.insert_row
    (
      X_ROWID      =>  l_rowid ,
      X_ROUTE_ID     =>  l_route_id ,
      X_OBJECT_VERSION_NUMBER  =>  1 ,
      X_ROUTE_NO     =>  l_old_route_rec.route_no ,
      X_APPLICATION_USG_CODE   =>  rtrim(ltrim(FND_PROFILE.value( 'AHL_APPLN_USAGE' ))),
      X_REVISION_NUMBER    =>  l_revision_number ,
      X_REVISION_STATUS_CODE   =>  'DRAFT' ,
      X_UNIT_RECEIPT_UPDATE_FLAG =>  l_old_route_rec.unit_receipt_update_flag , --pdoki Bug 6504159.
      X_START_DATE_ACTIVE  =>  l_old_route_rec.active_start_date ,
      X_END_DATE_ACTIVE    =>  NULL ,
      X_OPERATOR_PARTY_ID  =>  l_old_route_rec.operator_party_id ,
      X_QA_INSPECTION_TYPE   =>  l_old_route_rec.qa_inspection_type ,
      X_SERVICE_ITEM_ID    =>  l_old_route_rec.service_item_id ,
      X_SERVICE_ITEM_ORG_ID  =>  l_old_route_rec.service_item_org_id ,
      X_TASK_TEMPLATE_GROUP_ID   =>  l_old_route_rec.task_template_group_id ,
      X_ACCOUNTING_CLASS_CODE  =>  l_old_route_rec.accounting_class_code ,
      X_ACCOUNTING_CLASS_ORG_ID  =>  l_old_route_rec.accounting_class_org_id ,
      X_ROUTE_TYPE_CODE    =>  l_old_route_rec.route_type_code ,
      X_PRODUCT_TYPE_CODE  =>  l_old_route_rec.product_type_code ,
      --bachandr Enigma Phase I changes -- start
      X_MODEL_CODE		 =>  l_old_route_rec.model_code ,
      X_ENIGMA_PUBLISH_DATE	 =>  l_old_route_rec.enigma_publish_date,
      X_ENIGMA_DOC_ID		 =>  l_old_route_rec.enigma_doc_id ,
      X_ENIGMA_ROUTE_ID		 =>  l_old_route_rec.enigma_route_id ,
      X_FILE_ID	     		 =>  l_old_route_rec.file_id,
      --bachandr Enigma Phase I changes -- end
      X_ZONE_CODE    =>  l_old_route_rec.zone_code ,
      X_SUB_ZONE_CODE    =>  l_old_route_rec.sub_zone_code ,
      X_PROCESS_CODE     =>  l_old_route_rec.process_code ,
      X_TIME_SPAN    =>  l_old_route_rec.time_span ,
      X_SEGMENT1     =>  l_old_route_rec.segment1 ,
      X_SEGMENT2     =>  l_old_route_rec.segment2 ,
      X_SEGMENT3     =>  l_old_route_rec.segment3 ,
      X_SEGMENT4     =>  l_old_route_rec.segment4 ,
      X_SEGMENT5     =>  l_old_route_rec.segment5 ,
      X_SEGMENT6     =>  l_old_route_rec.segment6 ,
      X_SEGMENT7     =>  l_old_route_rec.segment7 ,
      X_SEGMENT8     =>  l_old_route_rec.segment8 ,
      X_SEGMENT9     =>  l_old_route_rec.segment9 ,
      X_SEGMENT10    =>  l_old_route_rec.segment10 ,
      X_SEGMENT11    =>  l_old_route_rec.segment11 ,
      X_SEGMENT12    =>  l_old_route_rec.segment12 ,
      X_SEGMENT13    =>  l_old_route_rec.segment13 ,
      X_SEGMENT14    =>  l_old_route_rec.segment14 ,
      X_SEGMENT15    =>  l_old_route_rec.segment15 ,
      X_ATTRIBUTE_CATEGORY   =>  l_old_route_rec.attribute_category ,
      X_ATTRIBUTE1     =>  l_old_route_rec.attribute1 ,
      X_ATTRIBUTE2     =>  l_old_route_rec.attribute2 ,
      X_ATTRIBUTE3     =>  l_old_route_rec.attribute3 ,
      X_ATTRIBUTE4     =>  l_old_route_rec.attribute4 ,
      X_ATTRIBUTE5     =>  l_old_route_rec.attribute5 ,
      X_ATTRIBUTE6     =>  l_old_route_rec.attribute6 ,
      X_ATTRIBUTE7     =>  l_old_route_rec.attribute7 ,
      X_ATTRIBUTE8     =>  l_old_route_rec.attribute8 ,
      X_ATTRIBUTE9     =>  l_old_route_rec.attribute9 ,
      X_ATTRIBUTE10    =>  l_old_route_rec.attribute10 ,
      X_ATTRIBUTE11    =>  l_old_route_rec.attribute11 ,
      X_ATTRIBUTE12    =>  l_old_route_rec.attribute12 ,
      X_ATTRIBUTE13    =>  l_old_route_rec.attribute13 ,
      X_ATTRIBUTE14    =>  l_old_route_rec.attribute14 ,
      X_ATTRIBUTE15    =>  l_old_route_rec.attribute15 ,
      X_TITLE      =>  l_old_route_rec.title ,
      X_REMARKS      =>  l_old_route_rec.remarks ,
      X_REVISION_NOTES     =>  l_old_route_rec.REVISION_NOTES ,
      X_CREATION_DATE    =>  SYSDATE ,
      X_CREATED_BY     =>  FND_GLOBAL.user_id ,
      X_LAST_UPDATE_DATE   =>  SYSDATE ,
      X_LAST_UPDATED_BY    =>  FND_GLOBAL.user_id ,
      X_LAST_UPDATE_LOGIN  =>  FND_GLOBAL.login_id,
      X_ENABLED_FLAG     =>  'Y',
      X_SUMMARY_FLAG     =>  'N'
    );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_RECORD_CHANGED' );
      FND_MSG_PUB.add;
    WHEN OTHERS THEN
      IF ( SQLCODE = -1 ) THEN
  FND_MESSAGE.set_name( 'AHL', 'AHL_RM_ROUTE_NO_DUP' );
  FND_MSG_PUB.add;
      ELSE
        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
      fnd_log.level_unexpected,
      'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
      'AHL_ROUTES_PKG.insert_row error = ['||SQLERRM||']'
    );
         END IF;
      END IF;
  END;

  -- Create copies of the route associations
  -- 0.Copy Route Effectivities
  FOR l_get_route_efcts IN get_route_efcts(p_route_id) LOOP
    SELECT ahl_route_effectivities_s.nextval into l_route_effectivity_id
    FROM dual;
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
    )
    VALUES
    (
      l_route_effectivity_id,
      l_route_id,
      l_get_route_efcts.inventory_item_id,
      l_get_route_efcts.inventory_master_org_id,
      l_get_route_efcts.mc_id,
      l_get_route_efcts.mc_header_id,
      1,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.user_id,
      l_get_route_efcts.security_group_id,
      l_get_route_efcts.ATTRIBUTE_CATEGORY,
      l_get_route_efcts.ATTRIBUTE1,
      l_get_route_efcts.ATTRIBUTE2,
      l_get_route_efcts.ATTRIBUTE3,
      l_get_route_efcts.ATTRIBUTE4,
      l_get_route_efcts.ATTRIBUTE5,
      l_get_route_efcts.ATTRIBUTE6,
      l_get_route_efcts.ATTRIBUTE7,
      l_get_route_efcts.ATTRIBUTE8,
      l_get_route_efcts.ATTRIBUTE9,
      l_get_route_efcts.ATTRIBUTE10,
      l_get_route_efcts.ATTRIBUTE11,
      l_get_route_efcts.ATTRIBUTE12,
      l_get_route_efcts.ATTRIBUTE13,
      l_get_route_efcts.ATTRIBUTE14,
      l_get_route_efcts.ATTRIBUTE15
    );

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
  ) SELECT
    AHL_RT_OPER_MATERIALS_S.NEXTVAL,
    1,
    l_route_effectivity_id,
    'DISPOSITION',
    position_path_id ,
    item_group_id,
    inventory_item_id,
    inventory_org_id,
    uom_code,
    quantity,
    item_comp_detail_id,
    exclude_flag,
    rework_percent,
    replace_percent,
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
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    in_service --pdoki added for OGMA 105 issue
    FROM  AHL_RT_OPER_MATERIALS
    WHERE OBJECT_ID = l_get_route_efcts.route_effectivity_id
    ;

   END LOOP;

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
    l_route_id,
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
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id,
    IN_SERVICE --pdoki added for OGMA 105 issue
  FROM  AHL_RT_OPER_MATERIALS
  WHERE object_id = p_route_id
  AND association_type_code = 'ROUTE';

  -- 2.Copy Resource Requirements and Alternate Resources
  FOR l_get_rt_oper_resources IN get_rt_oper_resources(p_route_id) LOOP
    SELECT ahl_rt_oper_resources_s.nextval into l_rt_oper_resource_id
    FROM dual;
    INSERT INTO AHL_RT_OPER_RESOURCES
    (
      RT_OPER_RESOURCE_ID,
      OBJECT_VERSION_NUMBER,
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
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      -- Bug # 7644260 (FP for ER # 6998882) -- start
      SCHEDULE_SEQ
      -- Bug # 7644260 (FP for ER # 6998882) -- end
    )
    VALUES
    (
      l_rt_oper_resource_id,
      1,
      l_route_id,
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
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id,
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
  SYSDATE,
  FND_GLOBAL.user_id,
  SYSDATE,
  FND_GLOBAL.user_id,
  FND_GLOBAL.login_id,
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
  FOR I in get_doc_associations( p_route_id ) LOOP
    SELECT AHL_DOC_TITLE_ASSOS_B_S.NEXTVAL
    INTO   l_doc_title_assos_id
    FROM   DUAL;
    -- pekambar  changes for bug # 9342005  -- start
    -- Passing wrong values to attribute1 to attribute15 are corrected
    AHL_DOC_TITLE_ASSOS_PKG.insert_row
    (
      X_ROWID          => l_rowid,
      X_DOC_TITLE_ASSO_ID      => l_doc_title_assos_id,
      X_SERIAL_NO        => I.serial_no,
      X_ATTRIBUTE_CATEGORY       => I.attribute_category,
      X_ATTRIBUTE1         => I.attribute1,
      X_ATTRIBUTE2         => I.attribute2,
      X_ATTRIBUTE3         => I.attribute3,
      X_ATTRIBUTE4         => I.attribute4,
      X_ATTRIBUTE5         => I.attribute5,
      X_ATTRIBUTE6         => I.attribute6,
      X_ATTRIBUTE7         => I.attribute7,
      X_ATTRIBUTE8         => I.attribute8,
      X_ATTRIBUTE9         => I.attribute9,
      X_ATTRIBUTE10        => I.attribute10,
      X_ATTRIBUTE11        => I.attribute11,
      X_ATTRIBUTE12        => I.attribute12,
      X_ATTRIBUTE13        => I.attribute13,
      X_ATTRIBUTE14        => I.attribute14,
      X_ATTRIBUTE15        => I.attribute15,
      X_ASO_OBJECT_TYPE_CODE       => 'ROUTE',
      X_SOURCE_REF_CODE        => I.source_ref_code,
      X_ASO_OBJECT_ID        => l_route_id,
      X_DOCUMENT_ID        => I.document_id,
      X_USE_LATEST_REV_FLAG      => I.use_latest_rev_flag,
      X_DOC_REVISION_ID        => I.doc_revision_id,
      X_OBJECT_VERSION_NUMBER      => 1,
      X_CHAPTER          => I.chapter,
      X_SECTION          => I.section,
      X_SUBJECT          => I.subject,
      X_FIGURE           => I.figure,
      X_PAGE           => I.page,
      X_NOTE           => I.note,
      X_CREATION_DATE        => SYSDATE,
      X_CREATED_BY         => fnd_global.user_id ,
      X_LAST_UPDATE_DATE       => SYSDATE,
      X_LAST_UPDATED_BY        => fnd_global.user_id ,
      X_LAST_UPDATE_LOGIN      => fnd_global.login_id
    );
    -- pekambar  changes for bug # 9342005  -- End
  END LOOP;
  -- 4.Copy Associated Operations
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
    l_route_id,
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
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id
  FROM  AHL_ROUTE_OPERATIONS
  WHERE route_id = p_route_id;

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
    l_route_id,
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
  WHERE object_id = p_route_id
  AND association_type_code = 'ROUTE';

  -- Set the OUT values.
  x_route_id := l_route_id;

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
    ROLLBACK TO create_route_revision_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_route_revision_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO create_route_revision_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
  p_pkg_name     => G_PKG_NAME,
  p_procedure_name   => l_api_name,
  p_error_text     => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END create_route_revision;
END AHL_RM_ROUTE_PVT;

/
