--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_INTERVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_INTERVAL_PVT" AS
/* $Header: AHLVMITB.pls 120.4.12010000.3 2009/09/23 13:17:53 bachandr ship $ */

G_PKG_NAME      VARCHAR2(30) := 'AHL_FMP_MR_INTERVAL_PVT';
G_API_NAME      VARCHAR2(30) := 'PROCESS_INTERVAL';
G_DEBUG         VARCHAR2(1)     :=AHL_DEBUG_PUB.is_log_enabled;

G_APPLN_USAGE    VARCHAR2(30)  := FND_PROFILE.value( 'AHL_APPLN_USAGE' );


g_repetitive_flag           VARCHAR2(1) := NULL;
g_mr_type_code              VARCHAR2(30) := NULL;

-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_interval_rec       IN    interval_rec_type
) RETURN VARCHAR2
IS

l_record_identifier         VARCHAR2(2000) := '';

BEGIN

  -- For PM Programs
  IF ( G_APPLN_USAGE = 'PM' AND
       g_mr_type_code = 'PROGRAM' ) THEN

    IF ( p_interval_rec.earliest_due_value IS NOT NULL AND
         p_interval_rec.earliest_due_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.earliest_due_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.start_value IS NOT NULL AND
         p_interval_rec.start_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.start_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.stop_value IS NOT NULL AND
         p_interval_rec.stop_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.stop_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

  -- For One-Time Maintenencce Requirements
  ELSIF ( g_repetitive_flag = 'N' ) THEN
    IF ( p_interval_rec.interval_value IS NOT NULL AND
         p_interval_rec.interval_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.interval_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

  -- For All other Maintenance Requirements
  ELSE

    IF ( p_interval_rec.start_date IS NOT NULL AND
         p_interval_rec.start_date <> FND_API.G_MISS_DATE ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.start_date, 'DD-MON_YYYY' );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.stop_date IS NOT NULL AND
         p_interval_rec.stop_date <> FND_API.G_MISS_DATE ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.stop_date, 'DD-MON-YYYY' );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.earliest_due_value IS NOT NULL AND
         p_interval_rec.earliest_due_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.earliest_due_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.start_value IS NOT NULL AND
         p_interval_rec.start_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.start_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.interval_value IS NOT NULL AND
         p_interval_rec.interval_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.interval_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

    IF ( p_interval_rec.stop_value IS NOT NULL AND
         p_interval_rec.stop_value <> FND_API.G_MISS_NUM ) THEN
      l_record_identifier := l_record_identifier || TO_CHAR( p_interval_rec.stop_value );
    END IF;

    l_record_identifier := l_record_identifier || ' - ';

  END IF;

  -- Common Identifiers
  IF ( p_interval_rec.counter_name IS NOT NULL AND
       p_interval_rec.counter_name <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_interval_rec.counter_name;
  END IF;

  RETURN l_record_identifier;

END get_record_identifier;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_interval_tbl                   IN   interval_tbl_type,
  p_mr_header_id                   IN   NUMBER,
  p_threshold_rec                  IN   threshold_rec_type,
  x_return_status                  OUT  NOCOPY VARCHAR2,
  p_super_user                     IN   VARCHAR2
)
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);
l_mr_status_code            VARCHAR2(30);
l_mr_type_code              VARCHAR2(30);
l_pm_install_flag           VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if a valid value is passed in p_mr_header_id
  IF ( p_mr_header_id = FND_API.G_MISS_NUM OR
       p_mr_header_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_MR_HEADER_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

   -- Check Profile value

    IF  G_APPLN_USAGE IS NULL
    THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
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

   -- Check if the Maintenance Requirement is in Updatable status based on the pm,super user,mrstatus
    IF ( l_pm_install_flag = 'Y' AND
         p_super_user ='Y' AND
         l_mr_status_code = 'COMPLETE') THEN
         AHL_FMP_COMMON_PVT.validate_mr_pm_status
         (
                x_return_status        => l_return_status,
                x_msg_data             => l_msg_data,
                p_mr_header_id         => p_mr_header_id
         );
     ELSE
         AHL_FMP_COMMON_PVT.validate_mr_status
         (
                x_return_status        => l_return_status,
                x_msg_data             => l_msg_data,
                p_mr_header_id         => p_mr_header_id
         );
      END IF;

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    x_return_status := l_return_status;
    RETURN;
  END IF;


  -- Check if a valid value is passed in p_mr_effectivity_id
  IF ( p_threshold_rec.mr_effectivity_id = FND_API.G_MISS_NUM OR
       p_threshold_rec.mr_effectivity_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_MRE_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Maintenance Requirement Effectivity exists
  AHL_FMP_COMMON_PVT.validate_mr_effectivity
  (
    x_return_status          => l_return_status,
    x_msg_data               => l_msg_data,
    p_mr_effectivity_id      => p_threshold_rec.mr_effectivity_id,
    p_object_version_number  => p_threshold_rec.object_version_number
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    x_return_status := l_return_status;
    RETURN;
  END IF;

     l_mr_type_code :=AHL_FMP_COMMON_PVT.check_mr_type(p_mr_header_id);

  -- Check if atleast one record is passed in p_interval_tbl or p_threshold_rec is passed
  IF ( p_interval_tbl.count < 1 AND
       ( p_threshold_rec.threshold_date IS NULL OR
         p_threshold_rec.threshold_date = FND_API.G_MISS_DATE ) AND
       ( p_threshold_rec.program_duration IS NULL OR
         p_threshold_rec.program_duration = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_interval_tbl.count LOOP
    IF ( p_interval_tbl(i).dml_operation <> 'D' AND
         p_interval_tbl(i).dml_operation <> 'U' AND
         p_interval_tbl(i).dml_operation <> 'C' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_DML_INVALID' );
      FND_MESSAGE.set_token( 'FIELD', p_interval_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    --BASED on the discussion with sracha on Nov02 2004 to show the error msg.
      IF ( l_pm_install_flag = 'Y' AND
           p_interval_tbl(i).dml_operation = 'U' AND
           p_super_user ='Y' AND
           l_mr_status_code = 'COMPLETE') THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVALID_DML' );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;


       IF ( l_pm_install_flag = 'Y' AND
           p_super_user ='Y' AND
           p_interval_tbl(i).dml_operation = 'D' AND
           l_mr_status_code = 'COMPLETE' AND
           l_mr_type_code ='ACTIVITY')THEN
           AHL_FMP_COMMON_PVT.validate_mr_type_activity
           (
                x_return_status    => l_return_status,
                x_msg_data         => l_msg_data,
                p_effectivity_id   => p_threshold_rec.MR_EFFECTIVITY_ID,
                p_eff_obj_version  => p_threshold_rec.OBJECT_VERSION_NUMBER
           );
           IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
           FND_MESSAGE.set_name( 'AHL', l_msg_data );
           FND_MSG_PUB.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
           END IF;
       END IF;


    IF ( l_pm_install_flag = 'Y' AND
         p_super_user ='Y' AND
         p_interval_tbl(i).dml_operation = 'D' AND
         l_mr_status_code = 'COMPLETE' AND
         l_mr_type_code ='PROGRAM') THEN
         AHL_FMP_COMMON_PVT.validate_mr_type_program
         (
                x_return_status    => l_return_status,
                x_msg_data         => l_msg_data,
                p_mr_header_id     => p_mr_header_id,
                p_effectivity_id   => p_threshold_rec.MR_EFFECTIVITY_ID,
                p_eff_obj_version  => p_threshold_rec.OBJECT_VERSION_NUMBER
         );
         IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
         FND_MESSAGE.set_name( 'AHL', l_msg_data );
         FND_MSG_PUB.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
         END IF;
    END IF;
  END LOOP;


  -- Check if a valid value is passed in p_threshold_rec.object_version_number if any other threshold information is passed
  IF ( ( p_threshold_rec.threshold_date <> FND_API.G_MISS_DATE AND
         p_threshold_rec.program_duration <> FND_API.G_MISS_NUM AND
         p_threshold_rec.mr_effectivity_id IS NOT NULL ) AND
       ( p_threshold_rec.object_version_number IS NULL OR
         p_threshold_rec.object_version_number = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_MRE_OBJ_VERSION_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_interval_rec       IN OUT NOCOPY  interval_rec_type
)
IS

BEGIN

  IF ( p_x_interval_rec.counter_name IS NULL ) THEN
    p_x_interval_rec.counter_id := NULL;
  ELSIF ( p_x_interval_rec.counter_name = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.counter_id := FND_API.G_MISS_NUM;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_interval_rec             IN OUT NOCOPY  interval_rec_type,
  p_mr_effectivity_id          IN             NUMBER,
  x_return_status              OUT NOCOPY     VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);
l_inventory_item_id       NUMBER;
l_item_number             VARCHAR2(40);
l_relationship_id         NUMBER;
l_position_ref_meaning    VARCHAR2(80);

CURSOR get_item_effectivity ( c_mr_effectivity_id NUMBER )
IS
SELECT  DECODE( relationship_id, null,
                                 inventory_item_id,
                                 position_inventory_item_id ),
        DECODE( relationship_id, null,
                                 item_number,
                                 position_item_number ),
        relationship_id,
        position_ref_meaning
FROM    AHL_MR_EFFECTIVITIES_V
WHERE   mr_effectivity_id = c_mr_effectivity_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Counter
  IF ( ( p_x_interval_rec.counter_id IS NOT NULL AND
         p_x_interval_rec.counter_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_interval_rec.counter_name IS NOT NULL AND
         p_x_interval_rec.counter_name <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_item_effectivity( p_mr_effectivity_id );

    FETCH get_item_effectivity INTO
      l_inventory_item_id,
      l_item_number,
      l_relationship_id,
      l_position_ref_meaning;

    CLOSE get_item_effectivity;

    AHL_FMP_COMMON_PVT.validate_counter_template
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_inventory_item_id    => l_inventory_item_id,
      p_relationship_id      => l_relationship_id,
      p_counter_name         => p_x_interval_rec.counter_name,
      p_x_counter_id         => p_x_interval_rec.counter_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( l_msg_data = 'AHL_FMP_INVALID_COUNTER' OR
           l_msg_data = 'AHL_FMP_TOO_MANY_COUNTERS' ) THEN
        IF ( p_x_interval_rec.counter_name IS NULL OR
             p_x_interval_rec.counter_name = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_interval_rec.counter_id ));
        ELSE
          FND_MESSAGE.set_token( 'FIELD', p_x_interval_rec.counter_name );
        END IF;
      ELSE
        IF ( p_x_interval_rec.counter_name IS NULL OR
             p_x_interval_rec.counter_name = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD1', TO_CHAR( p_x_interval_rec.counter_id ) );
        ELSE
          FND_MESSAGE.set_token( 'FIELD1', p_x_interval_rec.counter_name );
        END IF;

        IF ( l_position_ref_meaning IS NOT NULL ) THEN
          FND_MESSAGE.set_token( 'FIELD2', l_position_ref_meaning );
        ELSE
          FND_MESSAGE.set_token( 'FIELD2', l_item_number );
        END IF;
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;

-- Procedure to add Default values for interval attributes
PROCEDURE default_attributes
(
  p_x_interval_rec       IN OUT NOCOPY   interval_rec_type,
  x_fractional_trunc_flag   OUT NOCOPY   BOOLEAN
)
IS

  l_value  NUMBER;

BEGIN

  x_fractional_trunc_flag := FALSE;

  p_x_interval_rec.last_update_date := SYSDATE;
  p_x_interval_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_interval_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_interval_rec.dml_operation = 'C' ) THEN
    p_x_interval_rec.object_version_number := 1;
    p_x_interval_rec.creation_date := SYSDATE;
    p_x_interval_rec.created_by := FND_GLOBAL.user_id;
  END IF;

  -- Fix for bug# 3482307.
  IF (p_x_interval_rec.earliest_due_value IS NOT NULL AND
      p_x_interval_rec.earliest_due_value <> FND_API.G_MISS_NUM) THEN
        l_value := p_x_interval_rec.earliest_due_value;
        p_x_interval_rec.earliest_due_value := trunc(p_x_interval_rec.earliest_due_value);
        IF (l_value <> p_x_interval_rec.earliest_due_value) THEN
           x_fractional_trunc_flag := TRUE;
        END IF;
  END IF;

  IF (p_x_interval_rec.start_value IS NOT NULL AND
      p_x_interval_rec.start_value <> FND_API.G_MISS_NUM) THEN
        l_value := p_x_interval_rec.start_value;
        p_x_interval_rec.start_value := trunc(p_x_interval_rec.start_value);
        IF (l_value <> p_x_interval_rec.start_value) THEN
           x_fractional_trunc_flag := TRUE;
        END IF;
  END IF;

  IF (p_x_interval_rec.stop_value IS NOT NULL AND
      p_x_interval_rec.stop_value <> FND_API.G_MISS_NUM) THEN
        l_value := p_x_interval_rec.stop_value;
        p_x_interval_rec.stop_value := trunc(p_x_interval_rec.stop_value);
        IF (l_value <> p_x_interval_rec.stop_value) THEN
           x_fractional_trunc_flag := TRUE;
        END IF;
  END IF;

  IF (p_x_interval_rec.interval_value IS NOT NULL AND
      p_x_interval_rec.interval_value <> FND_API.G_MISS_NUM) THEN
        l_value := p_x_interval_rec.interval_value;
        p_x_interval_rec.interval_value := trunc(p_x_interval_rec.interval_value);
        IF (l_value <> p_x_interval_rec.interval_value) THEN
           x_fractional_trunc_flag := TRUE;
        END IF;
  END IF;

  IF (p_x_interval_rec.tolerance_before IS NOT NULL AND
      p_x_interval_rec.tolerance_before <> FND_API.G_MISS_NUM) THEN
        l_value := p_x_interval_rec.tolerance_before;
        p_x_interval_rec.tolerance_before := trunc(p_x_interval_rec.tolerance_before);
          IF (l_value <> p_x_interval_rec.tolerance_before) THEN
           x_fractional_trunc_flag := TRUE;
        END IF;
  END IF;

  IF (p_x_interval_rec.tolerance_after IS NOT NULL AND
      p_x_interval_rec.tolerance_after <> FND_API.G_MISS_NUM) THEN
        l_value := p_x_interval_rec.tolerance_after;
        p_x_interval_rec.tolerance_after := trunc(p_x_interval_rec.tolerance_after);
        IF (l_value <> p_x_interval_rec.tolerance_after) THEN
           x_fractional_trunc_flag := TRUE;
        END IF;
  END IF;

  -- bachandr added following logic for ADAT ER # 7415856
  -- If start date or start value is present and user has not entered due date rule,
  -- then due date rule is defaulted to 'At Start'.
  -- ADAT ER # 7415856 -- start

  IF
     (
      p_x_interval_rec.duedate_rule_code IS NULL
      OR
      p_x_interval_rec.duedate_rule_code = FND_API.G_MISS_CHAR
     )
     AND
     (
      (
       p_x_interval_rec.start_value IS NOT NULL
       AND
       p_x_interval_rec.start_value <> FND_API.G_MISS_NUM
      )
      OR
      (
       p_x_interval_rec.start_date IS NOT NULL
       AND
       p_x_interval_rec.start_date <> FND_API.G_MISS_DATE
      )
     )
  THEN
      p_x_interval_rec.duedate_rule_code := 'START';
  END IF;
  -- ADAT ER # 7415856 -- end

END default_attributes;

 -- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_interval_rec       IN OUT NOCOPY   interval_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_interval_rec.earliest_due_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.earliest_due_value := null;
  END IF;

  IF ( p_x_interval_rec.start_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.start_value := null;
  END IF;

  IF ( p_x_interval_rec.stop_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.stop_value := null;
  END IF;

  IF ( p_x_interval_rec.tolerance_before = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.tolerance_before := null;
  END IF;

  IF ( p_x_interval_rec.tolerance_after = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.tolerance_after := null;
  END IF;

  IF ( p_x_interval_rec.reset_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.reset_value := null;
  END IF;

  IF ( p_x_interval_rec.start_date = FND_API.G_MISS_DATE ) THEN
    p_x_interval_rec.start_date := null;
  END IF;

  IF ( p_x_interval_rec.stop_date = FND_API.G_MISS_DATE ) THEN
    p_x_interval_rec.stop_date := null;
  END IF;

  IF ( p_x_interval_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute_category := null;
  END IF;

  IF ( p_x_interval_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute1 := null;
  END IF;

  IF ( p_x_interval_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute2 := null;
  END IF;

  IF ( p_x_interval_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute3 := null;
  END IF;

  IF ( p_x_interval_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute4 := null;
  END IF;

  IF ( p_x_interval_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute5 := null;
  END IF;

  IF ( p_x_interval_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute6 := null;
  END IF;

  IF ( p_x_interval_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute7 := null;
  END IF;

  IF ( p_x_interval_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute8 := null;
  END IF;

  IF ( p_x_interval_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute9 := null;
  END IF;

  IF ( p_x_interval_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute10 := null;
  END IF;

  IF ( p_x_interval_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute11 := null;
  END IF;

  IF ( p_x_interval_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute12 := null;
  END IF;

  IF ( p_x_interval_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute13 := null;
  END IF;

  IF ( p_x_interval_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute14 := null;
  END IF;

  IF ( p_x_interval_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute15 := null;
  END IF;

  --pdoki added for ADAT ER
  IF ( p_x_interval_rec.duedate_rule_code = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.duedate_rule_code := null;
  END IF;

END default_missing_attributes;

 -- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_interval_rec       IN OUT NOCOPY   interval_rec_type
)
IS

l_old_interval_rec       interval_rec_type;

CURSOR get_old_rec ( c_mr_interval_id NUMBER )
IS
SELECT  counter_id,
        interval_value,
        earliest_due_value,
        start_value,
        stop_value,
        tolerance_before,
        tolerance_after,
        reset_value,
        start_date,
        stop_date,
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
	calc_duedate_rule_code --pdoki added for ADAT ER
FROM    AHL_MR_INTERVALS_APP_V
WHERE   mr_interval_id = c_mr_interval_id;

BEGIN

  -- Get the old record from AHL_MR_INTERVALS.
  OPEN  get_old_rec( p_x_interval_rec.mr_interval_id );

  FETCH get_old_rec INTO
        l_old_interval_rec.counter_id,
        l_old_interval_rec.interval_value,
        l_old_interval_rec.earliest_due_value,
        l_old_interval_rec.start_value,
        l_old_interval_rec.stop_value,
        l_old_interval_rec.tolerance_before,
        l_old_interval_rec.tolerance_after,
        l_old_interval_rec.reset_value,
        l_old_interval_rec.start_date,
        l_old_interval_rec.stop_date,
        l_old_interval_rec.attribute_category,
        l_old_interval_rec.attribute1,
        l_old_interval_rec.attribute2,
        l_old_interval_rec.attribute3,
        l_old_interval_rec.attribute4,
        l_old_interval_rec.attribute5,
        l_old_interval_rec.attribute6,
        l_old_interval_rec.attribute7,
        l_old_interval_rec.attribute8,
        l_old_interval_rec.attribute9,
        l_old_interval_rec.attribute10,
        l_old_interval_rec.attribute11,
        l_old_interval_rec.attribute12,
        l_old_interval_rec.attribute13,
        l_old_interval_rec.attribute14,
        l_old_interval_rec.attribute15,
	l_old_interval_rec.duedate_rule_code; --pdoki added for ADAT ER

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVALID_INTERVAL_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_interval_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_interval_rec.counter_id IS NULL ) THEN
    p_x_interval_rec.counter_id := l_old_interval_rec.counter_id;
  END IF;

  IF ( p_x_interval_rec.interval_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.interval_value := null;
  ELSIF ( p_x_interval_rec.interval_value IS NULL ) THEN
    p_x_interval_rec.interval_value := l_old_interval_rec.interval_value;
  END IF;

  IF ( p_x_interval_rec.earliest_due_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.earliest_due_value := null;
  ELSIF ( p_x_interval_rec.earliest_due_value IS NULL ) THEN
    p_x_interval_rec.earliest_due_value := l_old_interval_rec.earliest_due_value;
  END IF;

  IF ( p_x_interval_rec.start_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.start_value := null;
  ELSIF ( p_x_interval_rec.start_value IS NULL ) THEN
    p_x_interval_rec.start_value := l_old_interval_rec.start_value;
  END IF;

  IF ( p_x_interval_rec.stop_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.stop_value := null;
  ELSIF ( p_x_interval_rec.stop_value IS NULL ) THEN
    p_x_interval_rec.stop_value := l_old_interval_rec.stop_value;
  END IF;

  IF ( p_x_interval_rec.tolerance_before = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.tolerance_before := null;
  ELSIF ( p_x_interval_rec.tolerance_before IS NULL ) THEN
    p_x_interval_rec.tolerance_before := l_old_interval_rec.tolerance_before;
  END IF;

  IF ( p_x_interval_rec.tolerance_after = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.tolerance_after := null;
  ELSIF ( p_x_interval_rec.tolerance_after IS NULL ) THEN
    p_x_interval_rec.tolerance_after := l_old_interval_rec.tolerance_after;
  END IF;

  IF ( p_x_interval_rec.reset_value = FND_API.G_MISS_NUM ) THEN
    p_x_interval_rec.reset_value := null;
  ELSIF ( p_x_interval_rec.reset_value IS NULL ) THEN
    p_x_interval_rec.reset_value := l_old_interval_rec.reset_value;
  END IF;


  IF ( p_x_interval_rec.start_date = FND_API.G_MISS_DATE ) THEN
    p_x_interval_rec.start_date := null;
  ELSIF ( p_x_interval_rec.start_date IS NULL ) THEN
    p_x_interval_rec.start_date := l_old_interval_rec.start_date;
  END IF;

  IF ( p_x_interval_rec.stop_date = FND_API.G_MISS_DATE ) THEN
    p_x_interval_rec.stop_date := null;
  ELSIF ( p_x_interval_rec.stop_date IS NULL ) THEN
    p_x_interval_rec.stop_date := l_old_interval_rec.stop_date;
  END IF;

  IF ( p_x_interval_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute_category := null;
  ELSIF ( p_x_interval_rec.attribute_category IS NULL ) THEN
    p_x_interval_rec.attribute_category := l_old_interval_rec.attribute_category;
  END IF;

  IF ( p_x_interval_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute1 := null;
  ELSIF ( p_x_interval_rec.attribute1 IS NULL ) THEN
    p_x_interval_rec.attribute1 := l_old_interval_rec.attribute1;
  END IF;

  IF ( p_x_interval_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute2 := null;
  ELSIF ( p_x_interval_rec.attribute2 IS NULL ) THEN
    p_x_interval_rec.attribute2 := l_old_interval_rec.attribute2;
  END IF;

  IF ( p_x_interval_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute3 := null;
  ELSIF ( p_x_interval_rec.attribute3 IS NULL ) THEN
    p_x_interval_rec.attribute3 := l_old_interval_rec.attribute3;
  END IF;

  IF ( p_x_interval_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute4 := null;
  ELSIF ( p_x_interval_rec.attribute4 IS NULL ) THEN
    p_x_interval_rec.attribute4 := l_old_interval_rec.attribute4;
  END IF;

  IF ( p_x_interval_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute5 := null;
  ELSIF ( p_x_interval_rec.attribute5 IS NULL ) THEN
    p_x_interval_rec.attribute5 := l_old_interval_rec.attribute5;
  END IF;

  IF ( p_x_interval_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute6 := null;
  ELSIF ( p_x_interval_rec.attribute6 IS NULL ) THEN
    p_x_interval_rec.attribute6 := l_old_interval_rec.attribute6;
  END IF;

  IF ( p_x_interval_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute7 := null;
  ELSIF ( p_x_interval_rec.attribute7 IS NULL ) THEN
    p_x_interval_rec.attribute7 := l_old_interval_rec.attribute7;
  END IF;

  IF ( p_x_interval_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute8 := null;
  ELSIF ( p_x_interval_rec.attribute8 IS NULL ) THEN
    p_x_interval_rec.attribute8 := l_old_interval_rec.attribute8;
  END IF;

  IF ( p_x_interval_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute9 := null;
  ELSIF ( p_x_interval_rec.attribute9 IS NULL ) THEN
    p_x_interval_rec.attribute9 := l_old_interval_rec.attribute9;
  END IF;

  IF ( p_x_interval_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute10 := null;
  ELSIF ( p_x_interval_rec.attribute10 IS NULL ) THEN
    p_x_interval_rec.attribute10 := l_old_interval_rec.attribute10;
  END IF;

  IF ( p_x_interval_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute11 := null;
  ELSIF ( p_x_interval_rec.attribute11 IS NULL ) THEN
    p_x_interval_rec.attribute11 := l_old_interval_rec.attribute11;
  END IF;

  IF ( p_x_interval_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute12 := null;
  ELSIF ( p_x_interval_rec.attribute12 IS NULL ) THEN
    p_x_interval_rec.attribute12 := l_old_interval_rec.attribute12;
  END IF;

  IF ( p_x_interval_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute13 := null;
  ELSIF ( p_x_interval_rec.attribute13 IS NULL ) THEN
    p_x_interval_rec.attribute13 := l_old_interval_rec.attribute13;
  END IF;

  IF ( p_x_interval_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute14 := null;
  ELSIF ( p_x_interval_rec.attribute14 IS NULL ) THEN
    p_x_interval_rec.attribute14 := l_old_interval_rec.attribute14;
  END IF;

  IF ( p_x_interval_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.attribute15 := null;
  ELSIF ( p_x_interval_rec.attribute15 IS NULL ) THEN
    p_x_interval_rec.attribute15 := l_old_interval_rec.attribute15;
  END IF;

  --pdoki added for ADAT ER
  IF ( p_x_interval_rec.duedate_rule_code = FND_API.G_MISS_CHAR ) THEN
    p_x_interval_rec.duedate_rule_code := null;
  ELSIF ( p_x_interval_rec.duedate_rule_code IS NULL ) THEN
    p_x_interval_rec.duedate_rule_code := l_old_interval_rec.duedate_rule_code;
  END IF;

END default_unchanged_attributes;

-- Procedure to validate individual interval attributes
PROCEDURE validate_attributes
(
  p_interval_rec                 IN    interval_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the Counter ID does not contain a null value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( ( p_interval_rec.dml_operation = 'C' AND
           p_interval_rec.counter_id IS NULL AND
           p_interval_rec.counter_name IS NULL ) OR
         ( p_interval_rec.counter_id = FND_API.G_MISS_NUM AND
           p_interval_rec.counter_name = FND_API.G_MISS_CHAR ) ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_COUNTER_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the Interval Value does not contain an invalid value
  IF ( p_interval_rec.interval_value IS NOT NULL AND
       p_interval_rec.interval_value <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_INTERVAL' );
    FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.interval_value ) );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the earliest due  Value does not contain an invalid value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( p_interval_rec.earliest_due_value IS NOT NULL AND
         p_interval_rec.earliest_due_value <> FND_API.G_MISS_NUM AND
         p_interval_rec.earliest_due_value < 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_EARL_DUE' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.earliest_due_value ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the Start Value does not contain an invalid value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( p_interval_rec.start_value IS NOT NULL AND
         p_interval_rec.start_value <> FND_API.G_MISS_NUM AND
         p_interval_rec.start_value < 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_START' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.start_value ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the Stop Value does not contain an invalid value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( p_interval_rec.stop_value IS NOT NULL AND
         p_interval_rec.stop_value <> FND_API.G_MISS_NUM AND
         p_interval_rec.stop_value <= 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_STOP' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.stop_value ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the Tolerance Before does not contain an invalid value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( p_interval_rec.tolerance_before IS NOT NULL AND
         p_interval_rec.tolerance_before <> FND_API.G_MISS_NUM AND
         p_interval_rec.tolerance_before < 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_TOLERANCE_BF' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.tolerance_before ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the Tolerance After does not contain an invalid value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( p_interval_rec.tolerance_after IS NOT NULL AND
         p_interval_rec.tolerance_after <> FND_API.G_MISS_NUM AND
         p_interval_rec.tolerance_after < 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_TOLERANCE_AF' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.tolerance_after ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the Reset After does not contain an invalid value.
  IF ( p_interval_rec.dml_operation <> 'D' ) THEN
    IF ( p_interval_rec.reset_value IS NOT NULL AND
         p_interval_rec.reset_value <> FND_API.G_MISS_NUM AND
         p_interval_rec.reset_value < 0 ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_RESET_VALUE' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_interval_rec.reset_value ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the mandatory Interval ID column contains a null value.
  IF ( p_interval_rec.dml_operation <> 'C' ) THEN
    IF ( p_interval_rec.mr_interval_id IS NULL OR
         p_interval_rec.mr_interval_id = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_MR_INTERVAL_ID_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_interval_rec.dml_operation <> 'C' ) THEN
    IF ( p_interval_rec.object_version_number IS NULL OR
         p_interval_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INT_OBJ_VERSION_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

END validate_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_record
(
  p_interval_rec                 IN    interval_rec_type,
  p_repetitive_flag              IN    VARCHAR2,
  p_appln_code                   IN    VARCHAR2,
  p_mr_type_code                 IN    VARCHAR2,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);
l_initial_reading            NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the appropriate attributes are passed for PM Programs
  IF ( p_mr_type_code = 'PROGRAM' AND
       ( p_interval_rec.tolerance_before IS NOT NULL OR
         p_interval_rec.tolerance_after IS NOT NULL OR
         p_interval_rec.reset_value IS NOT NULL OR
         p_interval_rec.interval_value IS NOT NULL OR
         p_interval_rec.start_date IS NOT NULL OR
         p_interval_rec.stop_date IS NOT NULL ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_PGM_INPUTS' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Interval Value is always passed for non-PM Programs
  IF ( ( p_mr_type_code IS NULL OR
         p_mr_type_code <> 'PROGRAM' ) AND
       ( p_interval_rec.dml_operation = 'C' AND
         p_interval_rec.interval_value IS NULL ) OR
       ( p_interval_rec.interval_value = FND_API.G_MISS_NUM ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INTERVAL_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if Start is passed for PM Programs
  IF ( p_mr_type_code = 'PROGRAM' AND
       p_interval_rec.start_value IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_PGM_START_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

  -- Check if Stop is passed for PM Programs
  IF ( p_mr_type_code = 'PROGRAM' AND
       p_interval_rec.stop_value IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_PGM_STOP_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

  -- Check if Range is not passed for One Time MRs.
  IF ( ( p_mr_type_code IS NULL OR
         p_mr_type_code <> 'PROGRAM' ) AND
       p_repetitive_flag = 'N' AND
       ( p_interval_rec.start_value IS NOT NULL OR
         p_interval_rec.stop_value IS NOT NULL OR
         p_interval_rec.start_date IS NOT NULL OR
         p_interval_rec.stop_date IS NOT NULL ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_RANGE_NOTNULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

  -- Check if the Tolerance Before is less than the Interval Value
  IF ( p_interval_rec.tolerance_before IS NOT NULL AND
       p_interval_rec.tolerance_before >=  p_interval_rec.interval_value ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_TOL_BF_INT' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Tolerance After is less than the Interval Value
  IF ( p_interval_rec.tolerance_after IS NOT NULL AND
       p_interval_rec.tolerance_after >=  p_interval_rec.interval_value ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_TOL_AF_INT' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_interval_rec.counter_id IS NOT NULL AND
       p_interval_rec.reset_value IS NOT NULL AND
       p_interval_rec.reset_value >= 0 ) THEN

    SELECT  NVL( initial_reading, 0 )
    INTO    l_initial_reading
    FROM    csi_counter_template_vl --amsriniv
    WHERE   counter_id = p_interval_rec.counter_id;

    -- Check if the Reset Value is less than the initial reading for the counter
    IF ( p_interval_rec.reset_value < l_initial_reading ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_RESET_LESS_INIT_VALUE' );
      FND_MESSAGE.set_token( 'FIELD', TO_CHAR( l_initial_reading ) );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Check if the Start Value is passed if Stop Value is passed
  IF ( p_interval_rec.start_value IS NULL AND
       p_interval_rec.stop_value IS NOT NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MISSING_VALUE_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Start Value is passed if Stop Value is passed
  IF ( p_interval_rec.start_value IS NULL AND
       p_interval_rec.start_date IS NULL AND
       p_interval_rec.earliest_due_value IS NOT NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_INTERVAL_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Start Date is passed if Stop Date is passed
  IF ( p_interval_rec.start_date IS NULL AND
       p_interval_rec.stop_date IS NOT NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MISSING_DATE_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Stop Value is not greater than Start Value
  IF ( p_interval_rec.start_value IS NOT NULL AND
       p_interval_rec.stop_value IS NOT NULL AND
       p_interval_rec.stop_value < p_interval_rec.start_value ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_VALUE_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Stop date is not greater than Start date
  IF ( p_interval_rec.start_date IS NOT NULL AND
       p_interval_rec.stop_date IS NOT NULL AND
       p_interval_rec.stop_date < p_interval_rec.start_date ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_DATE_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if both Date based and Value based interval ranges are not passed
  IF ( ( p_interval_rec.start_date IS NOT NULL OR
         p_interval_rec.stop_date IS NOT NULL ) AND
       ( p_interval_rec.start_value IS NOT NULL OR
         p_interval_rec.stop_value IS NOT NULL ) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_BOTH_DATE_VALUE_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the Interval Value is between Start Value and Stop Value
  IF ( p_interval_rec.start_value IS NOT NULL AND
       p_interval_rec.stop_value IS NOT NULL AND
       p_interval_rec.interval_value >
         --( p_interval_rec.stop_value - p_interval_rec.start_value ) ) THEN
         -- Fix for bug# 3482307.
         ( p_interval_rec.stop_value - p_interval_rec.start_value + 1) ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_INTERVAL_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the earliest due value is less than Start Value
  IF ( p_interval_rec.start_value IS NOT NULL AND
       p_interval_rec.earliest_due_value >  p_interval_rec.start_value ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_INTERVAL_RANGE' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_interval_rec ) );
    FND_MSG_PUB.add;
  END IF;

END validate_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_mr_effectivity_id       IN    NUMBER,
  p_repetitive_flag         IN    VARCHAR2,
  p_appln_code              IN    VARCHAR2,
  p_mr_type_code            IN    VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2
)
IS

l_interval_rec                    interval_rec_type;
l_prev_counter_id                 NUMBER := NULL;
l_prev_stop_date                  DATE := NULL;
l_prev_stop_value                 NUMBER := NULL;
l_counter_id                      NUMBER := NULL;
l_counter_name                    VARCHAR2(30) := NULL;
l_start_date                      DATE;
l_stop_date                       DATE;
l_start_value                     NUMBER;
l_stop_value                      NUMBER;
l_earliest_due_value              NUMBER;

CURSOR get_pm_pgm_dup_rec( c_mr_effectivity_id NUMBER )
IS
SELECT   counter_id,
         counter_name
FROM     AHL_MR_INTERVALS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id
GROUP BY counter_id,
         counter_name
HAVING   count(*) > 1;

CURSOR get_dup_rec( c_mr_effectivity_id NUMBER )
IS
SELECT   counter_id,
         counter_name,
         start_value,
         stop_value,
         start_date,
         stop_date
FROM     AHL_MR_INTERVALS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id
GROUP BY counter_id,
         counter_name,
         start_value,
         stop_value,
         start_date,
         stop_date
HAVING   count(*) > 1;

CURSOR get_recs_for_date_range( c_mr_effectivity_id NUMBER )
IS
SELECT   counter_id,
         counter_name,
         start_date,
         stop_date
FROM     AHL_MR_INTERVALS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id
ORDER BY counter_id,
         start_date,
         stop_date;

CURSOR get_recs_for_value_range( c_mr_effectivity_id NUMBER )
IS
SELECT   counter_id,
         counter_name,
         earliest_due_value,
         start_value,
         stop_value
FROM     AHL_MR_INTERVALS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id
ORDER BY counter_id,
         start_value,
         stop_value;

CURSOR   check_unique_reset_value( c_mr_effectivity_id NUMBER )
IS
SELECT   counter_name
FROM     AHL_MR_INTERVALS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id
AND      reset_value IS NOT NULL
GROUP BY counter_name
HAVING   count(*) > 1;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check whether any duplicate Interval record (based on Counter) exist
  -- For Preventive Maintenance Programs

  IF ( p_appln_code = 'PM' AND
       p_mr_type_code = 'PROGRAM' ) THEN

    OPEN  get_pm_pgm_dup_rec( p_mr_effectivity_id );

    LOOP
      FETCH get_pm_pgm_dup_rec INTO
        l_interval_rec.counter_id,
        l_interval_rec.counter_name;

      EXIT WHEN get_pm_pgm_dup_rec%NOTFOUND;

      FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_PGM_DUP_INT_REC' );
      FND_MESSAGE.set_token( 'FIELD', l_interval_rec.counter_name );
      FND_MSG_PUB.add;
    END LOOP;

    IF ( get_pm_pgm_dup_rec%ROWCOUNT > 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE get_pm_pgm_dup_rec;
    RETURN;

  END IF;

  -- Check whether any duplicate Interval record (based on Counter and Range) exist
  OPEN  get_dup_rec( p_mr_effectivity_id );

  LOOP
    FETCH get_dup_rec INTO
      l_interval_rec.counter_id,
      l_interval_rec.counter_name,
      l_interval_rec.start_value,
      l_interval_rec.stop_value,
      l_interval_rec.start_date,
      l_interval_rec.stop_date;

    EXIT WHEN get_dup_rec%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_DUPLICATE_INT_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_interval_rec ) );
    FND_MSG_PUB.add;
  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

  IF ( p_repetitive_flag = 'N' ) THEN
    RETURN;
  END IF;

  OPEN get_recs_for_date_range( p_mr_effectivity_id );

  LOOP
    FETCH get_recs_for_date_range INTO
      l_interval_rec.counter_id,
      l_interval_rec.counter_name,
      l_interval_rec.start_date,
      l_interval_rec.stop_date;

    EXIT WHEN get_recs_for_date_range%NOTFOUND;

    IF ( l_prev_counter_id IS NOT NULL AND
         l_prev_stop_date IS NOT NULL AND
         l_interval_rec.counter_id = l_prev_counter_id AND
         --l_interval_rec.start_date < l_prev_stop_date ) THEN
         -- Fix for bug# 3482307.
         l_interval_rec.start_date <= l_prev_stop_date ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_OVERLAP_DATE_RANGE' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_interval_rec ) );
      FND_MSG_PUB.add;
      CLOSE get_recs_for_date_range;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    l_prev_counter_id := l_interval_rec.counter_id;
    l_prev_stop_date := l_interval_rec.stop_date;

  END LOOP;

  CLOSE get_recs_for_date_range;
  l_prev_counter_id := null;

  OPEN get_recs_for_value_range( p_mr_effectivity_id );

  LOOP
    FETCH get_recs_for_value_range INTO
      l_interval_rec.counter_id,
      l_interval_rec.counter_name,
      l_interval_rec.earliest_due_value,
      l_interval_rec.start_value,
      l_interval_rec.stop_value;

    EXIT WHEN get_recs_for_value_range%NOTFOUND;

    IF ( l_prev_counter_id IS NOT NULL AND
         l_prev_stop_value IS NOT NULL AND
         l_interval_rec.counter_id = l_prev_counter_id AND
         --l_interval_rec.start_value < l_prev_stop_value ) THEN
         -- Fix for bug# 3482307.
         l_interval_rec.start_value <= l_prev_stop_value ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_OVERLAP_VALUE_RANGE' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_interval_rec ) );
      FND_MSG_PUB.add;
      CLOSE get_recs_for_value_range;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    IF ( l_prev_counter_id IS NOT NULL AND
         l_prev_stop_value IS NOT NULL AND
         l_interval_rec.counter_id = l_prev_counter_id AND
         l_interval_rec.earliest_due_value <= l_prev_stop_value ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_OVERLAP_VALUE_RANGE' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_interval_rec ) );
      FND_MSG_PUB.add;
      CLOSE get_recs_for_value_range;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    l_prev_counter_id := l_interval_rec.counter_id;
    l_prev_stop_value := l_interval_rec.stop_value;

  END LOOP;

  CLOSE get_recs_for_value_range;

  OPEN  check_unique_reset_value( p_mr_effectivity_id );
  LOOP
    FETCH check_unique_reset_value
    INTO  l_counter_name;

    EXIT WHEN check_unique_reset_value%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL','AHL_FMP_RESET_VALUE_NONUNIQUE' );
    FND_MESSAGE.set_token( 'FIELD', l_counter_name );
    FND_MSG_PUB.add;
  END LOOP;

  IF ( check_unique_reset_value%ROWCOUNT > 0 ) THEN
    CLOSE check_unique_reset_value;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE check_unique_reset_value;

END validate_records;

-- Procedure to get the Repetitive Flag and Type for a MR
PROCEDURE get_mr_header_details
(
  p_mr_header_id            IN    NUMBER,
  x_repetitive_flag         OUT NOCOPY VARCHAR2,
  x_mr_type_code            OUT NOCOPY VARCHAR2
)
IS

CURSOR get_mr_details( c_mr_header_id NUMBER )
IS
SELECT repetitive_flag,
       type_code
FROM   AHL_MR_HEADERS_APP_V
WHERE  mr_header_id = c_mr_header_id;

BEGIN

  -- Get the Repetitive Flag and Type of the MR.
  OPEN get_mr_details( p_mr_header_id );

  FETCH get_mr_details INTO
    x_repetitive_flag,
    x_mr_type_code;

  CLOSE get_mr_details;

END get_mr_header_details;

-- Procedure to default the old value of the Threshold Date
PROCEDURE default_threshold_attributes
(
  p_x_threshold_rec             IN OUT NOCOPY    threshold_rec_type
)
IS

CURSOR get_old_rec( c_mr_effectivity_id NUMBER )
IS
SELECT threshold_date,
       program_duration,
       program_duration_uom_code
FROM   AHL_MR_EFFECTIVITIES_APP_V
WHERE  mr_effectivity_id = c_mr_effectivity_id;

l_old_rec          threshold_rec_type;

BEGIN

  OPEN get_old_rec( p_x_threshold_rec.mr_effectivity_id );

  FETCH get_old_rec INTO
    l_old_rec.threshold_date,
    l_old_rec.program_duration,
    l_old_rec.program_duration_uom_code;

  CLOSE get_old_rec;

  IF ( p_x_threshold_rec.threshold_date = FND_API.G_MISS_DATE ) THEN
    p_x_threshold_rec.threshold_date := null;
  ELSIF ( p_x_threshold_rec.threshold_date IS NULL ) THEN
    p_x_threshold_rec.threshold_date := l_old_rec.threshold_date;
  END IF;

  IF ( p_x_threshold_rec.program_duration = FND_API.G_MISS_NUM ) THEN
    p_x_threshold_rec.program_duration := null;
  ELSIF ( p_x_threshold_rec.program_duration IS NULL ) THEN
    p_x_threshold_rec.program_duration := l_old_rec.program_duration;
  END IF;

  IF ( p_x_threshold_rec.program_duration_uom_code = FND_API.G_MISS_CHAR ) THEN
    p_x_threshold_rec.program_duration_uom_code := null;
  ELSIF ( p_x_threshold_rec.program_duration_uom_code IS NULL ) THEN
    p_x_threshold_rec.program_duration_uom_code := l_old_rec.program_duration_uom_code;
  END IF;

END default_threshold_attributes;

-- Procedure to validate and update the Threshold information
PROCEDURE update_threshold
(
  p_x_threshold_rec         IN OUT NOCOPY   threshold_rec_type,
  p_repetitive_flag         IN              VARCHAR2,
  p_appln_code              IN              VARCHAR2,
  p_mr_type_code            IN              VARCHAR2,
  x_return_status           OUT NOCOPY      VARCHAR2,
  p_super_user              IN            VARCHAR2,
  p_mr_header_id            IN             NUMBER
)
IS

l_return_status            VARCHAR2(1);
l_msg_data                 VARCHAR2(2000);
l_old_threshold_rec        threshold_rec_type;
l_mr_status_code            VARCHAR2(30);
l_pm_install_flag           VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Default unchanged value of Threshold attributes
  default_threshold_attributes
  (
    p_x_threshold_rec -- IN OUT
  );

  -- Check if the Threshold date is not set for repeating MRs.
  IF ( p_x_threshold_rec.threshold_date IS NOT NULL AND
       p_repetitive_flag = 'Y' ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_THRESHOLD' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Threshold date is not set for PM Programs
  IF ( p_x_threshold_rec.threshold_date IS NOT NULL AND
       p_appln_code= 'PM' AND
       p_mr_type_code = 'PROGRAM' ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_PGM_THRESHOLD' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Program Duration is not specified for PM Activities.
  IF ( p_x_threshold_rec.program_duration IS NOT NULL AND
       p_appln_code = 'PM' AND
       p_mr_type_code = 'ACTIVITY' ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_ACT_PGM_DURATION' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Program Duration is a positive number.
  IF ( p_x_threshold_rec.program_duration IS NOT NULL AND
       p_x_threshold_rec.program_duration <= 0 ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_PGM_DUR_INVALID' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Program Duration is specified then the UOM should be specified.
  IF ( p_x_threshold_rec.program_duration IS NOT NULL AND
       p_x_threshold_rec.program_duration_uom_code IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_PGM_DUR_UOM_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Program Duration UOM is a valid value.
  IF ( p_x_threshold_rec.program_duration_uom_code IS NOT NULL ) THEN

    AHL_FMP_COMMON_PVT.validate_lookup
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_lookup_type          => 'AHL_UMP_TIME_UOM',
      p_lookup_meaning       => NULL,
      p_x_lookup_code        => p_x_threshold_rec.program_duration_uom_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_PM_INV_PGM_DUR_UOM' );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;

     -- Check Profile value

    IF  G_APPLN_USAGE IS NULL
    THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
        IF G_DEBUG = 'Y' THEN
            AHL_DEBUG_PUB.debug('APPLN USAGE CODE  IS NULL IN VALIDATE_API_INPUTS' );
        END IF;
    END IF;


  IF ( G_APPLN_USAGE = 'PM' ) THEN
    l_pm_install_flag:= 'Y';
  ELSE
    l_pm_install_flag:= 'N';
  END IF;

 -- Update effectivity only if changed attributes.
  IF ((p_x_threshold_rec.program_duration IS NULL AND
      l_old_threshold_rec.program_duration IS NOT NULL) OR
     (p_x_threshold_rec.program_duration IS NOT NULL AND
      l_old_threshold_rec.program_duration IS NOT NULL AND
      l_old_threshold_rec.program_duration <> p_x_threshold_rec.program_duration) OR
      (p_x_threshold_rec.program_duration IS NOT NULL AND
       l_old_threshold_rec.program_duration IS NULL) OR

      (p_x_threshold_rec.program_duration_uom_code IS NULL AND
      l_old_threshold_rec.program_duration_uom_code IS NOT NULL) OR
     (p_x_threshold_rec.program_duration_uom_code IS NOT NULL AND
      l_old_threshold_rec.program_duration_uom_code IS NOT NULL AND
      l_old_threshold_rec.program_duration_uom_code <> p_x_threshold_rec.program_duration_uom_code) OR
      (p_x_threshold_rec.program_duration_uom_code IS NOT NULL AND
       l_old_threshold_rec.program_duration_uom_code IS NULL) OR

     (p_x_threshold_rec.threshold_date IS NULL AND
      l_old_threshold_rec.threshold_date IS NOT NULL) OR
     (p_x_threshold_rec.threshold_date IS NOT NULL AND
      l_old_threshold_rec.threshold_date IS NOT NULL AND
      l_old_threshold_rec.threshold_date <> p_x_threshold_rec.threshold_date) OR
      (p_x_threshold_rec.threshold_date IS NOT NULL AND
       l_old_threshold_rec.threshold_date IS NULL)  ) THEN

   l_mr_status_code :=AHL_FMP_COMMON_PVT.check_mr_status(p_mr_header_id);
   IF ( l_pm_install_flag = 'Y' AND
        p_super_user = 'Y'      AND
        l_mr_status_code = 'COMPLETE' AND
        p_mr_type_code ='PROGRAM' ) THEN
        AHL_FMP_COMMON_PVT.validate_mr_type_program
        (
            x_return_status    => l_return_status,
            x_msg_data         => l_msg_data,
            p_mr_header_id     => p_mr_header_id,
            p_effectivity_id   => p_x_threshold_rec.MR_EFFECTIVITY_ID,
            p_eff_obj_version  => p_x_threshold_rec.OBJECT_VERSION_NUMBER
        );
        IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
           FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PROGRAM_DURATION' );
           FND_MSG_PUB.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
        END IF;
   END IF;

   IF ( l_pm_install_flag = 'Y' AND
        p_super_user = 'Y'      AND
        l_mr_status_code = 'COMPLETE' AND
        p_mr_type_code ='ACTIVITY' ) THEN
        AHL_FMP_COMMON_PVT.validate_mr_type_activity
        (
            x_return_status    => l_return_status,
            x_msg_data         => l_msg_data,
            p_effectivity_id   => p_x_threshold_rec.MR_EFFECTIVITY_ID,
            p_eff_obj_version  => p_x_threshold_rec.OBJECT_VERSION_NUMBER
        );
        IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
           FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PROGRAM_DURATION' );
           FND_MSG_PUB.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
        END IF;
   END IF;


    -- Update the record
    UPDATE AHL_MR_EFFECTIVITIES SET
      object_version_number     = object_version_number + 1,
      threshold_date            = p_x_threshold_rec.threshold_date,
      program_duration          = p_x_threshold_rec.program_duration,
      program_duration_uom_code = p_x_threshold_rec.program_duration_uom_code,
      last_update_date          = SYSDATE,
      last_updated_by           = FND_GLOBAL.user_id,
      last_update_login         = FND_GLOBAL.login_id
    WHERE mr_effectivity_id     = p_x_threshold_rec.mr_effectivity_id
    AND   object_version_number = p_x_threshold_rec.object_version_number;

    -- If the record does not exist, then, abort API.
    IF ( SQL%ROWCOUNT = 0 ) THEN
      FND_MESSAGE.set_name('AHL','AHL_FMP_EFF_RECORD_CHANGED');
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

  END IF;

END update_threshold;

PROCEDURE process_interval
(
 p_api_version        IN             NUMBER     := '1.0',
 p_init_msg_list      IN             VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN             VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN             NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN             VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN             VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY     VARCHAR2,
 x_msg_count          OUT NOCOPY     NUMBER,
 x_msg_data           OUT NOCOPY     VARCHAR2,
 p_x_interval_tbl     IN OUT NOCOPY  interval_tbl_type,
 p_x_threshold_rec    IN OUT NOCOPY  threshold_rec_type,
 p_mr_header_id       IN             NUMBER,
 p_super_user         IN            VARCHAR2
)
IS
l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_mr_interval_id            NUMBER;

l_fractional_trunc_flag     BOOLEAN := FALSE;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_interval_PVT;

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

  -- Get the PM Installation Flag

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' : Application Installed : ' || G_APPLN_USAGE );
  END IF;

  -- Validate all the inputs of the API
  validate_api_inputs
  (
    p_x_interval_tbl, -- IN
    p_mr_header_id, -- IN
    p_x_threshold_rec, -- IN
    l_return_status, -- OUT
    p_super_user
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get the Details for the given MR
  get_mr_header_details
  (
    p_mr_header_id, -- IN
    g_repetitive_flag, -- OUT
    g_mr_type_code -- OUT
  );

  -- Validate and Update the Threshold information
  update_threshold
  (
    p_x_threshold_rec, -- IN
    g_repetitive_flag, -- IN
    G_APPLN_USAGE, -- IN
    g_mr_type_code,
    l_return_status, -- OUT
    p_super_user,
    p_mr_header_id

  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_interval_tbl.count LOOP
      IF ( p_x_interval_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_interval_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  -- Convert Values into Ids.
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_interval_tbl.count LOOP
      IF ( p_x_interval_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_interval_tbl(i), -- IN OUT Record with Values and Ids
          p_x_threshold_rec.mr_effectivity_id, -- IN
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

  -- Default interval attributes.
    FOR i IN 1..p_x_interval_tbl.count LOOP
      IF ( p_x_interval_tbl(i).dml_operation <> 'D' ) THEN
        default_attributes
        (
          p_x_interval_tbl(i), -- IN OUT
          l_fractional_trunc_flag  -- OUT
        );
      END IF;
    END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_interval_tbl.count LOOP
      validate_attributes
      (
        p_x_interval_tbl(i), -- IN
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
  FOR i IN 1..p_x_interval_tbl.count LOOP
    IF ( p_x_interval_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_interval_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_interval_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_interval_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_interval_tbl.count LOOP
      IF ( p_x_interval_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_x_interval_tbl(i), -- IN
          g_repetitive_flag, -- IN
          G_APPLN_USAGE, -- IN
          g_mr_type_code, -- IN
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

  --pdoki added for ADAT ER start.
  FOR i IN 1..p_x_interval_tbl.count LOOP
      IF ( p_x_interval_tbl(i).dml_operation <> 'D' ) THEN
        IF (p_x_interval_tbl(i).start_date IS NOT NULL OR p_x_interval_tbl(i).start_value IS NOT NULL) THEN
	     IF (p_x_interval_tbl(i).duedate_rule_code IS NOT NULL) THEN
	        AHL_RM_ROUTE_UTIL.validate_lookup(
			x_return_status 	=>	x_return_status,
			x_msg_data		=>	x_msg_data,
			p_lookup_type		=>	'AHL_DUEDATE_RULE',
			p_lookup_meaning	=>	p_x_interval_tbl(i).duedate_rule_meaning,
			p_x_lookup_code		=>	p_x_interval_tbl(i).duedate_rule_code
		   );
		  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;
	     END IF;
	ELSE
	  p_x_interval_tbl(i).duedate_rule_code := NULL;
	END IF;
      END IF;
    END LOOP;
   --pdoki added for ADAT ER end.

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_interval_tbl.count LOOP
    IF ( p_x_interval_tbl(i).dml_operation = 'C' ) THEN

      -- Insert the record
      INSERT INTO AHL_MR_INTERVALS
      (
        MR_INTERVAL_ID,
        OBJECT_VERSION_NUMBER,
        MR_EFFECTIVITY_ID,
        COUNTER_ID,
        INTERVAL_VALUE,
        EARLIEST_DUE_VALUE,
        START_VALUE,
        STOP_VALUE,
        START_DATE,
        STOP_DATE,
        TOLERANCE_BEFORE,
        TOLERANCE_AFTER,
        RESET_VALUE,
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
	CALC_DUEDATE_RULE_CODE  --pdoki added for ADAT ER
      ) VALUES
      (
        AHL_MR_INTERVALS_S.NEXTVAL,
        p_x_interval_tbl(i).object_version_number,
        p_x_threshold_rec.mr_effectivity_id,
        p_x_interval_tbl(i).counter_id,
        p_x_interval_tbl(i).interval_value,
        p_x_interval_tbl(i).earliest_due_value,
        p_x_interval_tbl(i).start_value,
        p_x_interval_tbl(i).stop_value,
        p_x_interval_tbl(i).start_date,
        p_x_interval_tbl(i).stop_date,
        p_x_interval_tbl(i).tolerance_before,
        p_x_interval_tbl(i).tolerance_after,
        p_x_interval_tbl(i).reset_value,
        p_x_interval_tbl(i).attribute_category,
        p_x_interval_tbl(i).attribute1,
        p_x_interval_tbl(i).attribute2,
        p_x_interval_tbl(i).attribute3,
        p_x_interval_tbl(i).attribute4,
        p_x_interval_tbl(i).attribute5,
        p_x_interval_tbl(i).attribute6,
        p_x_interval_tbl(i).attribute7,
        p_x_interval_tbl(i).attribute8,
        p_x_interval_tbl(i).attribute9,
        p_x_interval_tbl(i).attribute10,
        p_x_interval_tbl(i).attribute11,
        p_x_interval_tbl(i).attribute12,
        p_x_interval_tbl(i).attribute13,
        p_x_interval_tbl(i).attribute14,
        p_x_interval_tbl(i).attribute15,
        p_x_interval_tbl(i).last_update_date,
        p_x_interval_tbl(i).last_updated_by,
        p_x_interval_tbl(i).creation_date,
        p_x_interval_tbl(i).created_by,
        p_x_interval_tbl(i).last_update_login,
	p_x_interval_tbl(i).duedate_rule_code  --pdoki added for ADAT ER
      ) RETURNING mr_interval_id INTO l_mr_interval_id;

      -- Set OUT values
      p_x_interval_tbl(i).mr_interval_id := l_mr_interval_id;

    ELSIF ( p_x_interval_tbl(i).dml_operation = 'U' ) THEN

      -- Update the record
      UPDATE AHL_MR_INTERVALS SET
        object_version_number = object_version_number + 1,
        counter_id            = p_x_interval_tbl(i).counter_id,
        interval_value        = p_x_interval_tbl(i).interval_value,
        earliest_due_value    = p_x_interval_tbl(i).earliest_due_value,
        start_value           = p_x_interval_tbl(i).start_value,
        stop_value            = p_x_interval_tbl(i).stop_value,
        start_date            = p_x_interval_tbl(i).start_date,
        stop_date             = p_x_interval_tbl(i).stop_date,
        tolerance_before      = p_x_interval_tbl(i).tolerance_before,
        tolerance_after       = p_x_interval_tbl(i).tolerance_after,
        reset_value           = p_x_interval_tbl(i).reset_value,
        attribute_category    = p_x_interval_tbl(i).attribute_category,
        attribute1            = p_x_interval_tbl(i).attribute1,
        attribute2            = p_x_interval_tbl(i).attribute2,
        attribute3            = p_x_interval_tbl(i).attribute3,
        attribute4            = p_x_interval_tbl(i).attribute4,
        attribute5            = p_x_interval_tbl(i).attribute5,
        attribute6            = p_x_interval_tbl(i).attribute6,
        attribute7            = p_x_interval_tbl(i).attribute7,
        attribute8            = p_x_interval_tbl(i).attribute8,
        attribute9            = p_x_interval_tbl(i).attribute9,
        attribute10           = p_x_interval_tbl(i).attribute10,
        attribute11           = p_x_interval_tbl(i).attribute11,
        attribute12           = p_x_interval_tbl(i).attribute12,
        attribute13           = p_x_interval_tbl(i).attribute13,
        attribute14           = p_x_interval_tbl(i).attribute14,
        attribute15           = p_x_interval_tbl(i).attribute15,
        last_update_date      = p_x_interval_tbl(i).last_update_date,
        last_updated_by       = p_x_interval_tbl(i).last_updated_by,
        last_update_login     = p_x_interval_tbl(i).last_update_login,
	calc_duedate_rule_code= p_x_interval_tbl(i).duedate_rule_code --pdoki added for ADAT ER
      WHERE mr_interval_id  = p_x_interval_tbl(i).mr_interval_id
      AND   object_version_number     = p_x_interval_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_interval_tbl(i) ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Set OUT values
      p_x_interval_tbl(i).object_version_number := p_x_interval_tbl(i).object_version_number + 1;

    ELSIF ( p_x_interval_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE AHL_MR_INTERVALS
      WHERE mr_interval_id        = p_x_interval_tbl(i).mr_interval_id
      AND   object_version_number = p_x_interval_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after DML operation' );
  END IF;

  -- Perform cross records validations and duplicate records check
  validate_records
  (
    p_x_threshold_rec.mr_effectivity_id, -- IN
    g_repetitive_flag, -- IN
    G_APPLN_USAGE, -- IN
    g_mr_type_code, -- IN
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

  -- Add informational message if any truncation of interval values occured.
  -- Fix for bug#3482307
  IF (l_fractional_trunc_flag) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_FMP_FRACTION_TRUNC');
    FND_MSG_PUB.ADD;
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
    ROLLBACK TO process_interval_PVT;
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
    ROLLBACK TO process_interval_PVT;
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
    ROLLBACK TO process_interval_PVT;
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

END process_interval;

END AHL_FMP_MR_INTERVAL_PVT;

/
