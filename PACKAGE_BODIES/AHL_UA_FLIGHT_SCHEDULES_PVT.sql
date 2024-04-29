--------------------------------------------------------
--  DDL for Package Body AHL_UA_FLIGHT_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UA_FLIGHT_SCHEDULES_PVT" AS
/* $Header: AHLVUFSB.pls 120.4.12010000.3 2009/11/24 14:29:33 bachandr ship $ */

G_USER_ID   CONSTANT    NUMBER      := TO_NUMBER(FND_GLOBAL.USER_ID);
G_LOGIN_ID  CONSTANT    NUMBER      := TO_NUMBER(FND_GLOBAL.LOGIN_ID);
G_SYSDATE   CONSTANT    DATE        := SYSDATE;
--Flag for determining wether to use Actual dates or Estimated dates.
G_USE_ACTUALS   CONSTANT    VARCHAR2(1) := FND_API.G_FALSE;

-- Internal record structure used to pass visit reschedule related details to
-- Visit sync procedure.
TYPE visit_sync_rec_type IS RECORD
(
 UNIT_SCHEDULE_ID   NUMBER,
 CHANGED_ARRIVAL_TIME   NUMBER,
 CHANGED_ORG_ID     NUMBER,
 CHANGED_DEPT_ID    NUMBER,
 VISIT_RESCHEDULE_MODE  VARCHAR2(30)
);

-- Record and table structure for storing Unit Schedule Records for finding out Preceeding US ID.
TYPE pre_us_rec_type IS RECORD
(
  unit_schedule_id  NUMBER,
  preceding_us_id   NUMBER,
  arrival_time      DATE
);
TYPE pre_us_tbl_type IS TABLE OF pre_us_rec_type INDEX BY BINARY_INTEGER;

G_PKG_NAME    VARCHAR2(30):='AHL_UA_FLIGHT_SCHEDULES_PVT';

l_visit_tbl AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
l_visit_count  NUMBER;

CURSOR get_flight_visit
(
    p_unit_schedule_id number
)
IS
SELECT *
FROM AHL_VISITS_B
WHERE unit_schedule_id = p_unit_schedule_id
AND STATUS_CODE NOT IN ('DELETED', 'CANCELLED' , 'CLOSED');


l_flight_visit get_flight_visit%ROWTYPE;




-----------------------------------------------------------------------------------------------------
-- Function for constructing record identifier for error messages.
-----------------------------------------------------------------------------------------------------

FUNCTION get_record_identifier(
    p_flight_schedule_rec   IN  FLIGHT_SCHEDULE_REC_TYPE
)
RETURN VARCHAR2
IS
l_record_identifier VARCHAR2(200);
BEGIN
    l_record_identifier := '';

    IF p_flight_schedule_rec.UNIT_CONFIG_NAME IS NOT NULL
    THEN
        l_record_identifier := l_record_identifier||p_flight_schedule_rec.UNIT_CONFIG_NAME;
    END IF;

    IF p_flight_schedule_rec.FLIGHT_NUMBER IS NOT NULL
    THEN
        l_record_identifier := l_record_identifier||','||p_flight_schedule_rec.FLIGHT_NUMBER;
    END IF;

    IF p_flight_schedule_rec.SEGMENT IS NOT NULL
    THEN
        l_record_identifier := l_record_identifier||','||p_flight_schedule_rec.SEGMENT;
    END IF;

    RETURN l_record_identifier;

END get_record_identifier;

-----------------------------------------------------------------------------------------------------
-- Perform item level validation on the attributes of Unit Flight Schedule.
-----------------------------------------------------------------------------------------------------
PROCEDURE validate_attributes
(
  p_flight_schedule_rec  IN     FLIGHT_SCHEDULE_REC_TYPE,
  x_return_status    OUT NOCOPY     VARCHAR2
)
IS

-- Cursor for checking for the validity of the flight schedule
CURSOR get_cur_us_csr(p_unit_schedule_id IN NUMBER, p_object_version_number IN NUMBER)
IS
SELECT 'X'
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_schedule_id
AND object_version_number = p_object_version_number;

-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'validate_attributes';
l_dummy VARCHAR2(1);
l_record_identifier VARCHAR2(300);


BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
        fnd_log.level_procedure,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
        'At the start of '||l_api_name
    );
  END IF;

  -- initialize return status to success at the begining
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_record_identifier := get_record_identifier(
                                    p_flight_schedule_rec   =>  p_flight_schedule_rec
                                  );

  --Validate DML flag
  IF (
      p_flight_schedule_rec.DML_OPERATION <> 'D'  AND
      p_flight_schedule_rec.DML_OPERATION <> 'U'  AND
      p_flight_schedule_rec.DML_OPERATION <> 'C'
     )
  THEN
        FND_MESSAGE.set_name( 'AHL','AHL_COM_INVALID_DML' );
        FND_MESSAGE.set_token( 'FIELD',  p_flight_schedule_rec.DML_OPERATION);
    FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
    FND_MSG_PUB.add;
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'DML Operation specified is invalid for '
            ||p_flight_schedule_rec.unit_schedule_id
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --Obj version number and Unit Schedule id check in case of update or delete.
  IF (
       p_flight_schedule_rec.DML_OPERATION = 'D' OR
       p_flight_schedule_rec.DML_OPERATION = 'U'
     )
  THEN
    --Unit Schedule id cannot be null
    IF p_flight_schedule_rec.UNIT_SCHEDULE_ID IS NULL OR
    p_flight_schedule_rec.UNIT_SCHEDULE_ID = FND_API.G_MISS_NUM
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_US_NOT_FOUND' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Unit Schedule ID is null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check for Object Version number.
    IF ( p_flight_schedule_rec.OBJECT_VERSION_NUMBER IS NULL OR
      p_flight_schedule_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM )
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_OBJ_VERNO_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Object Version Number is null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if unit schedule rec is valid.
    OPEN get_cur_us_csr(p_flight_schedule_rec.unit_schedule_id, p_flight_schedule_rec.object_version_number);
    FETCH get_cur_us_csr INTO l_dummy;
    IF get_cur_us_csr%NOTFOUND
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_REC_CHANGED' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Unit Schedule record is not valid ->'
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
        fnd_log.level_procedure,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
        'At the end of '||l_api_name
    );
  END IF;

END validate_attributes;

-----------------------------------------------------------------------------------------------------
-- Procedure for converting values to ids
-----------------------------------------------------------------------------------------------------
PROCEDURE convert_values_to_ids
(
  p_x_flight_schedule_rec   IN OUT NOCOPY  FLIGHT_SCHEDULE_REC_TYPE,
  x_return_status       OUT NOCOPY     VARCHAR2
)
IS

-- Cursor for getting unit config id from unit config name
CURSOR uc_name_to_id_csr(p_uc_name IN VARCHAR2)
IS
SELECT unit_config_header_id
FROM AHL_UNIT_CONFIG_HEADERS
WHERE name = p_uc_name
--priyan Bug # 5303188
-- AND ahl_util_uc_pkg.get_uc_status_code (unit_config_header_id) IN ('COMPLETE', 'INCOMPLETE');
--AND unit_config_status_code in ('COMPLETE','INCOMPLETE');
--AND TRUNC(NVL(active_end_date,sysdate+1)) > TRUNC(sysdate);
-- fix for bug number 5528416
AND ahl_util_uc_pkg.get_uc_status_code (unit_config_header_id) NOT IN ('DRAFT', 'EXPIRED');


-- Cursor for getting org id from org name
CURSOR org_name_to_id_csr(p_org_code IN VARCHAR2)
IS
SELECT mtlp.organization_id
FROM MTL_PARAMETERS mtlp
WHERE mtlp.eam_enabled_flag = 'Y'
AND mtlp.organization_code = p_org_code;

-- Cursor for getting org id from org name
CURSOR dept_name_to_id_csr(p_dept_code IN VARCHAR2, p_org_id IN NUMBER)
IS
SELECT DEPARTMENT_ID
FROM BOM_DEPARTMENTS BD
WHERE BD.DEPARTMENT_CODE = p_dept_code AND
      BD.ORGANIZATION_ID = p_org_id;

-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'convert_values_to_ids';
l_record_identifier VARCHAR2(150);
l_msg_data  VARCHAR2(30);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
        fnd_log.level_procedure,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
        'At the start of '||l_api_name
    );
  END IF;

  -- Initialize return status to success at the begining
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_record_identifier := get_record_identifier(
                                p_flight_schedule_rec   =>  p_x_flight_schedule_rec
                                  );

  -- convert unit name(UC Name) to UC header id
  IF /*(
      p_x_flight_schedule_rec.unit_config_header_id IS NULL OR
      p_x_flight_schedule_rec.unit_config_header_id = FND_API.G_MISS_NUM
     )
     AND*/
     (
      p_x_flight_schedule_rec.unit_config_name IS NOT NULL AND
      p_x_flight_schedule_rec.unit_config_name <> FND_API.G_MISS_CHAR
     )
  THEN

    OPEN uc_name_to_id_csr(p_x_flight_schedule_rec.unit_config_name);
    FETCH uc_name_to_id_csr INTO p_x_flight_schedule_rec.unit_config_header_id;
        IF uc_name_to_id_csr%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_UA_INV_UC_NAME');
             FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
             FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Unit Config name specified for '||p_x_flight_schedule_rec.unit_schedule_id
            ||' is invalid'
        );
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE uc_name_to_id_csr;

  END IF;

  -- convert arrival org
  IF/*(
      p_x_flight_schedule_rec.arrival_org_id IS NULL OR
      p_x_flight_schedule_rec.arrival_org_id = FND_API.G_MISS_NUM
     )
     AND*/
     (
      p_x_flight_schedule_rec.ARRIVAL_ORG_CODE IS NOT NULL AND
      p_x_flight_schedule_rec.ARRIVAL_ORG_CODE <> FND_API.G_MISS_CHAR
     )
  THEN
    OPEN org_name_to_id_csr(p_x_flight_schedule_rec.ARRIVAL_ORG_CODE);
    FETCH org_name_to_id_csr INTO p_x_flight_schedule_rec.arrival_org_id;
        IF org_name_to_id_csr%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_UA_INV_ARR_ORG');
             FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
             FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Arrival Org code specified for '||p_x_flight_schedule_rec.unit_schedule_id
            ||' is invalid'
        );
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE org_name_to_id_csr;
  END IF;

  -- convert arrival department
  IF /*(
      p_x_flight_schedule_rec.arrival_dept_id IS NULL OR
      p_x_flight_schedule_rec.arrival_dept_id = FND_API.G_MISS_NUM
     )
     AND*/
     (
      p_x_flight_schedule_rec.arrival_dept_code IS NOT NULL AND
      p_x_flight_schedule_rec.arrival_dept_code <> FND_API.G_MISS_CHAR
     )
     AND
     (
      p_x_flight_schedule_rec.arrival_org_id IS NOT NULL AND
      p_x_flight_schedule_rec.arrival_org_id <> FND_API.G_MISS_NUM
     )
  THEN
    OPEN dept_name_to_id_csr(p_x_flight_schedule_rec.arrival_dept_code,
                 p_x_flight_schedule_rec.ARRIVAL_ORG_ID);
    FETCH dept_name_to_id_csr INTO p_x_flight_schedule_rec.arrival_dept_id;
        IF dept_name_to_id_csr%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_UA_INV_ARR_DEPT');
             FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
             FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Arrival Department code specified for '||p_x_flight_schedule_rec.unit_schedule_id
            ||' is invalid'
        );
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    CLOSE dept_name_to_id_csr;
  END IF;


  -- convert departure org
  IF /*(
      p_x_flight_schedule_rec.departure_org_id IS NULL OR
      p_x_flight_schedule_rec.departure_org_id = FND_API.G_MISS_NUM
     )
     AND*/
     (
      p_x_flight_schedule_rec.departure_org_code IS NOT NULL AND
      p_x_flight_schedule_rec.departure_org_code <> FND_API.G_MISS_CHAR
     )
  THEN
    OPEN org_name_to_id_csr(p_x_flight_schedule_rec.departure_org_code);
    FETCH org_name_to_id_csr INTO p_x_flight_schedule_rec.departure_org_id;
        IF org_name_to_id_csr%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_UA_INV_DEP_ORG');
             FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
             FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Departure org code specified for '||p_x_flight_schedule_rec.unit_schedule_id
            ||' is invalid'
        );
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE org_name_to_id_csr;
  END IF;

  -- convert departure department
  IF /*(
      p_x_flight_schedule_rec.departure_dept_id IS NULL OR
      p_x_flight_schedule_rec.departure_dept_id = FND_API.G_MISS_NUM
     )
     AND*/
     (
      p_x_flight_schedule_rec.departure_dept_code IS NOT NULL AND
      p_x_flight_schedule_rec.departure_dept_code <> FND_API.G_MISS_CHAR
     )
     AND
     (
      p_x_flight_schedule_rec.departure_org_id IS NOT NULL AND
      p_x_flight_schedule_rec.departure_org_id <> FND_API.G_MISS_NUM
     )
  THEN
    OPEN dept_name_to_id_csr(p_x_flight_schedule_rec.departure_dept_code,
                 p_x_flight_schedule_rec.departure_org_id);
    FETCH dept_name_to_id_csr INTO p_x_flight_schedule_rec.departure_dept_id;
        IF dept_name_to_id_csr%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_UA_INV_DEP_DEPT');
             FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
             FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Departure department code specified for '||p_x_flight_schedule_rec.unit_schedule_id
            ||' is invalid'
        );
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    CLOSE dept_name_to_id_csr;
  END IF;

  -- validate visit synchronization rule lookup type.
  IF /*(
      p_x_flight_schedule_rec.VISIT_RESCHEDULE_MODE IS NOT NULL AND
      p_x_flight_schedule_rec.VISIT_RESCHEDULE_MODE <> FND_API.G_MISS_CHAR
     )
     OR*/
     (
      p_x_flight_schedule_rec.VISIT_RESCHEDULE_MEANING IS NOT NULL AND
      p_x_flight_schedule_rec.VISIT_RESCHEDULE_MEANING <> FND_API.G_MISS_CHAR
     )

  THEN
    AHL_RM_ROUTE_UTIL.validate_lookup(
        x_return_status =>  x_return_status,
        x_msg_data      =>  l_msg_data,
        p_lookup_type   =>  'AHL_UA_VISIT_SYNC_RULE',
        p_lookup_meaning    =>  p_x_flight_schedule_rec.VISIT_RESCHEDULE_MEANING,
        p_x_lookup_code =>  p_x_flight_schedule_rec.VISIT_RESCHEDULE_MODE
      );

      -- If any severe error occurs, then, abort API.
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_UA_INV_RESCH_MODE');
         FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'visit reschedule mode specified for '||p_x_flight_schedule_rec.unit_schedule_id
            ||' is invalid'
        );
         END IF;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
        fnd_log.level_procedure,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
        'At the end of '||l_api_name
    );
  END IF;


END convert_values_to_ids;

PROCEDURE default_unchanged_attributes
(
  p_x_flight_schedule_rec   IN OUT NOCOPY   FLIGHT_SCHEDULE_REC_TYPE
)
IS

-- Cursor for getting a Unit Schedule record.
CURSOR get_current_us_csr(p_unit_shcedule_id IN NUMBER) IS
SELECT *
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_shcedule_id;

l_current_us_rec get_current_us_csr%ROWTYPE;

-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'default_unchanged_attributes';
l_record_identifier VARCHAR2(150);

BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
      END IF;

      --get current unit_schedule record
      OPEN get_current_us_csr(p_x_flight_schedule_rec.unit_schedule_id);
      FETCH get_current_us_csr INTO l_current_us_rec;

      CLOSE get_current_us_csr;


      -- Default Unit Config Header id.
      IF (p_x_flight_schedule_rec.unit_config_header_id IS NULL )
      THEN
        p_x_flight_schedule_rec.unit_config_header_id := l_current_us_rec.unit_config_header_id;
      ELSIF p_x_flight_schedule_rec.unit_config_header_id = FND_API.G_MISS_NUM THEN
        p_x_flight_schedule_rec.unit_config_header_id := NULL;
      END IF;

      -- Default Flight Number
      IF ( p_x_flight_schedule_rec.flight_number IS NULL ) THEN
        p_x_flight_schedule_rec.flight_number := l_current_us_rec.flight_number;
      ELSIF p_x_flight_schedule_rec.flight_number = FND_API.G_MISS_CHAR THEN
        p_x_flight_schedule_rec.flight_number := NULL;
      END IF;

      -- Default segment
      IF ( p_x_flight_schedule_rec.segment IS NULL ) THEN
        p_x_flight_schedule_rec.segment := l_current_us_rec.segment;
      ELSIF p_x_flight_schedule_rec.segment = FND_API.G_MISS_CHAR THEN
        p_x_flight_schedule_rec.segment := NULL;
      END IF;

      -- Default departure dept id.
      IF ( p_x_flight_schedule_rec.departure_dept_id IS NULL ) THEN
        p_x_flight_schedule_rec.departure_dept_id := l_current_us_rec.departure_dept_id;
      ELSIF p_x_flight_schedule_rec.departure_dept_id = FND_API.G_MISS_NUM THEN
        p_x_flight_schedule_rec.departure_dept_id := NULL;
      END IF;

      -- Default departure org id.
      IF ( p_x_flight_schedule_rec.departure_org_id IS NULL ) THEN
        p_x_flight_schedule_rec.departure_org_id := l_current_us_rec.departure_org_id;
      ELSIF ( p_x_flight_schedule_rec.departure_org_id = FND_API.G_MISS_NUM ) THEN
        p_x_flight_schedule_rec.departure_org_id := NULL;
      END IF;

       -- Default arrival dept id.
      IF ( p_x_flight_schedule_rec.arrival_dept_id IS NULL ) THEN
        p_x_flight_schedule_rec.arrival_dept_id := l_current_us_rec.arrival_dept_id;
      ELSIF p_x_flight_schedule_rec.arrival_dept_id = FND_API.G_MISS_NUM THEN
        p_x_flight_schedule_rec.arrival_dept_id := NULL;
      END IF;

      -- Default arrival org is updated
      IF ( p_x_flight_schedule_rec.arrival_org_id IS NULL ) THEN
        p_x_flight_schedule_rec.arrival_org_id := l_current_us_rec.arrival_org_id;
      ELSIF p_x_flight_schedule_rec.arrival_org_id = FND_API.G_MISS_NUM THEN
        p_x_flight_schedule_rec.arrival_org_id := NULL;
      END IF;

      -- Default estimated departure time.
      IF ( p_x_flight_schedule_rec.est_departure_time IS NULL ) THEN
        p_x_flight_schedule_rec.est_departure_time := l_current_us_rec.est_departure_time;
      ELSIF p_x_flight_schedule_rec.est_departure_time = FND_API.G_MISS_DATE THEN
        p_x_flight_schedule_rec.est_departure_time := NULL;
      END IF;

      -- Default estimated Arrival time.
      IF ( p_x_flight_schedule_rec.est_arrival_time IS NULL ) THEN
        p_x_flight_schedule_rec.est_arrival_time := l_current_us_rec.est_arrival_time;
      ELSIF p_x_flight_schedule_rec.est_arrival_time = FND_API.G_MISS_DATE THEN
        p_x_flight_schedule_rec.est_arrival_time := NULL;
      END IF;

      -- default actual_departure_time
      IF ( p_x_flight_schedule_rec.actual_departure_time IS NULL ) THEN
        p_x_flight_schedule_rec.actual_departure_time := l_current_us_rec.actual_departure_time;
      ELSIF p_x_flight_schedule_rec.actual_departure_time = FND_API.G_MISS_DATE
      THEN
        p_x_flight_schedule_rec.actual_departure_time := NULL;
      END IF;

      -- default actual_arrival_time
      IF ( p_x_flight_schedule_rec.actual_arrival_time IS NULL ) THEN
        p_x_flight_schedule_rec.actual_arrival_time := l_current_us_rec.actual_arrival_time;
      ELSIF p_x_flight_schedule_rec.actual_arrival_time = FND_API.G_MISS_DATE
      THEN
        p_x_flight_schedule_rec.actual_arrival_time := NULL;
      END IF;

      -- default preceding_us_id
      IF ( p_x_flight_schedule_rec.preceding_us_id IS NULL ) THEN
        p_x_flight_schedule_rec.preceding_us_id := l_current_us_rec.preceding_us_id;
      ELSIF p_x_flight_schedule_rec.preceding_us_id = FND_API.G_MISS_NUM
      THEN
        p_x_flight_schedule_rec.preceding_us_id := NULL;
      END IF;

      -- default visit_reschedule_mode
      IF ( p_x_flight_schedule_rec.visit_reschedule_mode IS NULL ) THEN
        p_x_flight_schedule_rec.visit_reschedule_mode := l_current_us_rec.visit_reschedule_mode;
      ELSIF p_x_flight_schedule_rec.visit_reschedule_mode = FND_API.G_MISS_CHAR
      THEN
        p_x_flight_schedule_rec.visit_reschedule_mode := NULL;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of '||l_api_name
        );
          END IF;

END default_unchanged_attributes;

---------------------------------------------------------------------------------------------------------
-- Procedure which validates all mandatory input fields.
-- This needs to be done before any further validation.
-- Note: This cannot be done at the start of the procedure, since we are allowing defaulting of attributes
-- in case of update. So this can be performed only after default_missing_attributes.
----------------------------------------------------------------------------------------------------------
PROCEDURE validate_mandatory_fields
(
  p_flight_schedule_rec  IN         FLIGHT_SCHEDULE_REC_TYPE,
  x_return_status    OUT NOCOPY VARCHAR2
)
IS

-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'validate_mandatory_fields';
l_record_identifier VARCHAR2(150);

BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
      END IF;

      -- Initialize return status to success at the begining
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      l_record_identifier := get_record_identifier(
                                p_flight_schedule_rec   =>  p_flight_schedule_rec
                              );

      -- Unit Config Header is Mandatory input Field and cannot be null
      IF (
          p_flight_schedule_rec.unit_config_header_id IS NULL OR
          p_flight_schedule_rec.unit_config_header_id = FND_API.G_MISS_NUM
         )
      THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_INV_UC_NAME' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Unit Config Header id is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Flight Number is a mandatory input field and cannot be null
      IF (
          p_flight_schedule_rec.flight_number IS NULL OR
          p_flight_schedule_rec.flight_number = FND_API.G_MISS_CHAR
         )
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_FLG_NUMBER_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Flight Number cannot be null for '
            ||p_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Segment is a mandatory input field and cannot be null
      IF (
          p_flight_schedule_rec.segment IS NULL OR
          p_flight_schedule_rec.segment = FND_API.G_MISS_CHAR
         )
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_SEGMENT_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Segment cannot be null for '
            ||p_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Departure department is a mandatory input field and cannot be null
      IF (
          p_flight_schedule_rec.departure_dept_id IS NULL OR
          p_flight_schedule_rec.departure_dept_id = FND_API.G_MISS_NUM
         )
      THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_DEP_DEPT_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Departure_Dept_Id is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Departure Organization is a mandatory input field and cannot be null
     IF (
         p_flight_schedule_rec.departure_org_id IS NULL OR
         p_flight_schedule_rec.departure_org_id = FND_API.G_MISS_NUM
        )
     THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_DEP_ORG_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Departure_Org_Id is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Arrival Department is a mandatory input field and cannot be null
    IF (
        p_flight_schedule_rec.arrival_dept_id IS NULL OR
        p_flight_schedule_rec.arrival_dept_id = FND_API.G_MISS_NUM
       )
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_ARR_DEPT_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Arrival_Dept_Id is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Arrival Organization is a mandatory input field and cannot be null
    IF (
        p_flight_schedule_rec.arrival_org_id IS NULL OR
        p_flight_schedule_rec.arrival_org_id = FND_API.G_MISS_NUM
       )
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_ARR_ORG_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Arrival_Org_Id is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Estimated Departure Time is a mandatory input field and cannot be null
    IF (
        p_flight_schedule_rec.est_departure_time IS NULL OR
        p_flight_schedule_rec.est_departure_time = FND_API.G_MISS_DATE
       )
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_EST_DEP_TIME_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Est_Departure_Time is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Estimated Arrival Time is a mandatory input field and cannot be null
    IF (
        p_flight_schedule_rec.est_arrival_time IS NULL OR
        p_flight_schedule_rec.est_arrival_time = FND_API.G_MISS_DATE
       )
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_EST_ARR_TIME_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Est_Arrival_Time is a mandatory input field and cannot be null for '
                ||p_flight_schedule_rec.unit_schedule_id
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Visit Reschedule Mode is a mandatory input field and cannot be null
    IF (
        p_flight_schedule_rec.visit_reschedule_mode IS NULL OR
        p_flight_schedule_rec.visit_reschedule_mode = FND_API.G_MISS_CHAR
       )
    THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_VST_RES_MODE_NULL' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Visit_Reschedule_Mode is a mandatory input field and cannot be null for '
            ||p_flight_schedule_rec.unit_schedule_id
        );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of '||l_api_name
        );
    END IF;

END validate_mandatory_fields;

-----------------------------------------------------------------------------------------------------
-- Procedure which checks if update is allowed in Flight Schedule fields
-----------------------------------------------------------------------------------------------------
PROCEDURE validate_update(
  p_x_flight_schedule_rec   IN OUT NOCOPY   FLIGHT_SCHEDULE_REC_TYPE,
  x_return_status       OUT NOCOPY      VARCHAR2
)
IS
-- Cursor for getting a Unit Schedule record.
CURSOR get_current_us_csr(p_unit_shcedule_id IN NUMBER) IS
SELECT *
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_shcedule_id;

-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'validate_update';
l_current_us_rec get_current_us_csr%ROWTYPE;
l_update_allowed VARCHAR2(1);
l_record_identifier VARCHAR2(150);

BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of '||l_api_name
        );
      END IF;

      --Initialize x_return_status to success at the start of the procedure
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --Check if update is allowed for the record
      l_update_allowed := is_update_allowed(
                        p_x_flight_schedule_rec.unit_schedule_id,
                        is_super_user
                          );

          -- returns a string with Unit Name, Flight Number and Segment of current record.
          -- This is used as a token in error messages
          l_record_identifier := get_record_identifier(
                                        p_flight_schedule_rec   =>  p_x_flight_schedule_rec
                                  );

      --get current unit_schedule record
      OPEN get_current_us_csr(p_x_flight_schedule_rec.unit_schedule_id);
      FETCH get_current_us_csr INTO l_current_us_rec;
      IF get_current_us_csr%NOTFOUND
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_US_NOT_FOUND' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
           (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Flight schedule record not found for id '
            ||p_x_flight_schedule_rec.unit_schedule_id
           );
        END IF;
        CLOSE get_current_us_csr;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE get_current_us_csr;

      -- Unit cannot be updated irrespective of the whether the user is super user or not
      IF p_x_flight_schedule_rec.unit_config_header_id <> l_current_us_rec.unit_config_header_id
      THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_UNIT_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
              (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Unit config header id cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
              );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            --RAISE FND_API.G_EXC_ERROR;
      END IF;

      ----------------------------------------------------------------------------------------------------
      /* --Un comment the code if this is required
      -- Flight Number cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.flight_number <> l_current_us_rec.flight_number
      THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_FLIGHT_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
              (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Flight Number cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
              );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Flight Segment cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.segment <> l_current_us_rec.segment
      THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UA_SEGMENT_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier);
        FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
              (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Flight Segment cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
              );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            --RAISE FND_API.G_EXC_ERROR;
      END IF;
      ------------------------------------------------------------------------------------------------------
      --Un comment the code if this is required */

      -- Departure department cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.departure_dept_id <> l_current_us_rec.departure_dept_id AND
        l_update_allowed = FND_API.G_FALSE
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_DEP_DEPT_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Departure deparment cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Departure Organization cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.departure_org_id <> l_current_us_rec.departure_org_id AND
        l_update_allowed = FND_API.G_FALSE
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_DEP_ORG_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Departure org cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Arrival Department cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.arrival_dept_id <> l_current_us_rec.arrival_dept_id AND
        l_update_allowed = FND_API.G_FALSE
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ARR_DEP_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Arrival Department cannot be updated for'
            ||p_x_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Arrival Organization cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.arrival_org_id <> l_current_us_rec.arrival_org_id AND
        l_update_allowed = FND_API.G_FALSE
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ARR_ORG_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Arrival org cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Estimated Departure Time cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.est_departure_time <> l_current_us_rec.est_departure_time AND
        l_update_allowed = FND_API.G_FALSE
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_EST_DEP_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Estimated Departure time cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Estimated Arrival Time cannot be updated unless user is super user.
      IF p_x_flight_schedule_rec.est_arrival_time <> l_current_us_rec.est_arrival_time AND
        l_update_allowed = FND_API.G_FALSE
      THEN
        FND_MESSAGE.set_name( 'AHL', 'AHL_UA_EST_ARR_NO_UPDATE' );
        FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
          fnd_log.string
          (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Estimated Arrival time cannot be updated for '
            ||p_x_flight_schedule_rec.unit_schedule_id
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of '||l_api_name
        );
      END IF;
END validate_update;

-----------------------------------------------------------------------------------------------------
-- Procedure to Perform cross attribute validation and missing attribute checks and duplicate checks
-----------------------------------------------------------------------------------------------------
PROCEDURE validate_record
(
  p_x_flight_schedule_rec  IN OUT NOCOPY    FLIGHT_SCHEDULE_REC_TYPE,
  x_return_status    OUT NOCOPY VARCHAR2
)
IS

--Cursor for getting the preceeding event of an Unit Schedule.
CURSOR get_preceeding_us_csr(p_unit_schedule_id IN NUMBER) IS
/*SELECT unit_schedule_id, actual_departure_time, actual_arrival_time
FROM AHL_UNIT_SCHEDULES_V
WHERE unit_schedule_id = (
             SELECT preceding_us_id
             FROM AHL_UNIT_SCHEDULES_V
             WHERE unit_schedule_id = p_unit_schedule_id
            );*/
--Priyan changed the query due to performance issues
--Refer Bug # 4916339
SELECT
     UNIT_SCHEDULE_ID,
     ACTUAL_DEPARTURE_TIME,
     ACTUAL_ARRIVAL_TIME
FROM
     AHL_UNIT_SCHEDULES
WHERE
     UNIT_SCHEDULE_ID = (
         SELECT PRECEDING_US_ID
         FROM AHL_UNIT_SCHEDULES
         WHERE UNIT_SCHEDULE_ID = p_unit_schedule_id
                         );

l_preceeding_us_rec get_preceeding_us_csr%ROWTYPE;

--Cursor for getting the preceeding event of an Unit Schedule in create mode.
CURSOR get_pre_us_uc_csr(p_uc_header_id IN NUMBER, p_est_arrival_date IN DATE) IS
SELECT unit_schedule_id, actual_departure_time, actual_arrival_time
FROM AHL_UNIT_SCHEDULES
WHERE unit_config_header_id = p_uc_header_id AND
Est_arrival_time < p_est_arrival_date;

CURSOR get_curr_act_dates_csr(p_unit_schedule_id IN NUMBER) IS
SELECT actual_departure_time, actual_arrival_time
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_schedule_id;
l_curr_act_dates_rec get_curr_act_dates_csr%ROWTYPE;

-- Cursor for finding overlaps in flight schedules.If this is used then above cursor is not required
-- Using AHL_UNIT_SCHEDULES_V instead of AHL_UNIT_SCHEDULES because of restriction in access.
CURSOR get_cur_us_det_csr(p_unit_schedule_id IN NUMBER)
IS
SELECT unit_config_header_id,
       EST_DEPARTURE_TIME,
       EST_ARRIVAL_TIME,
       ACTUAL_DEPARTURE_TIME,
       ACTUAL_ARRIVAL_TIME
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_schedule_id;


-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'validate_record';
l_cur_us_rec get_cur_us_det_csr%ROWTYPE;
l_us_dup_count      NUMBER;
l_record_identifier VARCHAR2(150);
l_est_violation_count NUMBER;

BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
        END IF;

    -- Set return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_record_identifier := get_record_identifier(
                                    p_flight_schedule_rec   =>  p_x_flight_schedule_rec
                                        );

    --Check on delete if actual dates are not recorded.
    IF p_x_flight_schedule_rec.dml_operation = 'D'
    THEN
        OPEN get_curr_act_dates_csr(p_x_flight_schedule_rec.unit_schedule_id);
        FETCH get_curr_act_dates_csr
        INTO
              l_curr_act_dates_rec.actual_departure_time,
              l_curr_act_dates_rec.actual_arrival_time;

        CLOSE get_curr_act_dates_csr;
        IF ( l_curr_act_dates_rec.actual_departure_time IS NOT NULL OR
           l_curr_act_dates_rec.actual_arrival_time IS NOT NULL )
           AND is_delete_allowed(p_unit_schedule_id => p_x_flight_schedule_rec.unit_schedule_id,
                     p_is_super_user => is_super_user
                       ) = FND_API.G_FALSE
        THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ACT_NO_DEL' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Actual times are entered for '||p_x_flight_schedule_rec.unit_schedule_id
                ||'so delete not allowed'
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    ELSE
        --Check for duplicate records.
        SELECT count(unit_schedule_id) INTO l_us_dup_count
        FROM AHL_UNIT_SCHEDULES
        WHERE UNIT_CONFIG_HEADER_ID = p_x_flight_schedule_rec.UNIT_CONFIG_HEADER_ID
              AND FLIGHT_NUMBER = p_x_flight_schedule_rec.FLIGHT_NUMBER
              AND SEGMENT = p_x_flight_schedule_rec.SEGMENT
              AND EST_ARRIVAL_TIME = p_x_flight_schedule_rec.EST_ARRIVAL_TIME
              AND EST_DEPARTURE_TIME = p_x_flight_schedule_rec.EST_DEPARTURE_TIME
              AND unit_schedule_id <> nvl(p_x_flight_schedule_rec.unit_schedule_id,-100);

        IF l_us_dup_count > 0 THEN
        -- Duplicate found, so throw error.
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_DUP_FLG_SCH' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Duplicates flight schedules found for ,'
                ||p_x_flight_schedule_rec.unit_schedule_id
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Check if Actual Arrival is entered without departure.
        IF (
            p_x_flight_schedule_rec.ACTUAL_ARRIVAL_TIME IS NOT NULL AND
            p_x_flight_schedule_rec.ACTUAL_ARRIVAL_TIME <> FND_API.G_MISS_DATE
           )
           AND
           (
            p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME IS NULL OR
            p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME = FND_API.G_MISS_DATE
           )
        THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ARR_WO_DEP' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Actuals Arrival time cannot be entered until departure time is entered '||p_x_flight_schedule_rec.unit_schedule_id
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        --Check if actuals are greater than sysdate.
        IF (
            p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME IS NOT NULL AND
            p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME <> FND_API.G_MISS_DATE AND
            p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME > SYSDATE
           )
           OR
           (
            p_x_flight_schedule_rec.ACTUAL_ARRIVAL_TIME IS NOT NULL AND
            p_x_flight_schedule_rec.ACTUAL_ARRIVAL_TIME <> FND_API.G_MISS_DATE AND
            p_x_flight_schedule_rec.ACTUAL_ARRIVAL_TIME > SYSDATE
           )
        THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ACT_GT_SYSDATE' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Actuals cannot be greater than sysdate for '||p_x_flight_schedule_rec.unit_schedule_id
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        --Validate if arrival dates are greater than departure dates.
        IF (
            p_x_flight_schedule_rec.EST_DEPARTURE_TIME IS NOT NULL AND
            p_x_flight_schedule_rec.EST_DEPARTURE_TIME <> FND_API.G_MISS_DATE
           )
           AND
           p_x_flight_schedule_rec.EST_DEPARTURE_TIME >= p_x_flight_schedule_rec.EST_ARRIVAL_TIME
        THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ARR_LT_DEP' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Estimated Departure cannot be greater than arrival for '
                ||p_x_flight_schedule_rec.unit_schedule_id
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        --Validate if arrival dates are greater than departure dates.
        IF (
             p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME IS NOT NULL AND
             p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME <> FND_API.G_MISS_DATE
           )
           AND
           p_x_flight_schedule_rec.ACTUAL_DEPARTURE_TIME >= p_x_flight_schedule_rec.ACTUAL_ARRIVAL_TIME
        THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_ARR_LT_DEP' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Actual Departure cannot be greater than arrival for '
                ||p_x_flight_schedule_rec.unit_schedule_id
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        IF (
            p_x_flight_schedule_rec.actual_departure_time IS NOT NULL AND
            p_x_flight_schedule_rec.actual_departure_time <> FND_API.G_MISS_DATE
           )
           OR
           (
            p_x_flight_schedule_rec.actual_arrival_time IS NOT NULL AND
            p_x_flight_schedule_rec.actual_arrival_time <> FND_API.G_MISS_DATE
           )
        THEN
            --If create then use unit_config_header_id to fetch actual times
            -- Added for bug 4071579
            IF p_x_flight_schedule_rec.unit_schedule_id IS NULL
            THEN
                OPEN get_pre_us_uc_csr(
                    p_x_flight_schedule_rec.unit_config_header_id,
                    p_x_flight_schedule_rec.EST_ARRIVAL_TIME
                     );
                FETCH get_pre_us_uc_csr
                INTO
                      l_preceeding_us_rec.unit_schedule_id,
                      l_preceeding_us_rec.actual_departure_time,
                      l_preceeding_us_rec.actual_arrival_time;
                CLOSE get_pre_us_uc_csr;
            ELSE
                --Check if prior actuals are recorded.
                OPEN get_preceeding_us_csr(p_x_flight_schedule_rec.unit_schedule_id);
                FETCH get_preceeding_us_csr
                INTO
                      l_preceeding_us_rec.unit_schedule_id,
                      l_preceeding_us_rec.actual_departure_time,
                      l_preceeding_us_rec.actual_arrival_time;
                CLOSE get_preceeding_us_csr;
            END IF;

            IF l_preceeding_us_rec.unit_schedule_id IS NOT NULL AND
               (l_preceeding_us_rec.actual_departure_time IS NULL OR
                l_preceeding_us_rec.actual_arrival_time IS NULL )
            THEN
                FND_MESSAGE.set_name( 'AHL', 'AHL_UA_PRE_ACT_NOT_REC' );
                FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
                FND_MSG_PUB.add;
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                  fnd_log.string
                   (
                    fnd_log.level_error,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'previous actuals are not entered for '||p_x_flight_schedule_rec.unit_schedule_id
                   );
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        -- code to verify if estimated times are updated to a value less than
        -- some other flight's estimated arrival time of the same unit whose Actuals are already entered.
        SELECT count(unit_schedule_id) into l_est_violation_count
        FROM AHL_UNIT_SCHEDULES
        WHERE est_arrival_time > p_x_flight_schedule_rec.EST_ARRIVAL_TIME AND
              unit_config_header_id = p_x_flight_schedule_rec.unit_config_header_id
              AND (
                   actual_departure_time is not null OR actual_arrival_time is not null
                  )
              AND unit_schedule_id <> nvl(p_x_flight_schedule_rec.unit_schedule_id,-110);

        IF l_est_violation_count > 0 THEN
            FND_MESSAGE.set_name( 'AHL', 'AHL_UA_EST_ARR_VIO' );
            FND_MESSAGE.set_token( 'RECORD', l_record_identifier );
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'estimated arrival time violates another flight'||
                'schedules estimated arrival time for '||p_x_flight_schedule_rec.unit_schedule_id
               );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of '||l_api_name
        );
        END IF;

END validate_record;

-----------------------------------------------------------------------------------------------------
-- Procedure to calculate preceeding flight schedules information based on current record info.
-----------------------------------------------------------------------------------------------------
PROCEDURE Sequence_Flight_Schedules
(
  p_x_flight_schedules_tbl  IN OUT NOCOPY FLIGHT_SCHEDULES_TBL_TYPE
)
IS

--Cursor for finding previous unit schedule id.
CURSOR get_pre_us_id_act(p_unit_config_header_id IN NUMBER)
IS
SELECT  unit_schedule_id, nvl(actual_arrival_time, est_arrival_time) "ARRIVAL_TIME"
FROM AHL_UNIT_SCHEDULES
WHERE unit_config_header_id = p_unit_config_header_id
ORDER BY nvl(actual_arrival_time, est_arrival_time) DESC;

--Cursor for finding previous unit schedule id.
CURSOR get_pre_us_id_est(p_unit_config_header_id IN NUMBER)
IS
SELECT  unit_schedule_id, est_arrival_time "ARRIVAL_TIME"
FROM AHL_UNIT_SCHEDULES
WHERE unit_config_header_id = p_unit_config_header_id
ORDER BY est_arrival_time DESC;

-- Define all local variables here.
l_api_name  CONSTANT    VARCHAR2(30)    := 'Sequence_Flight_Schedules';
l_us_count  NUMBER;
l_pre_us_tbl    pre_us_tbl_type;
l_equal_arr_count NUMBER;
l_count     NUMBER;
j       NUMBER;

BEGIN

FOR i IN p_x_flight_schedules_tbl.FIRST..p_x_flight_schedules_tbl.LAST
LOOP
    --Get preceeding us id.
    l_equal_arr_count := 0;
    l_count := 1;
    IF G_USE_ACTUALS = FND_API.G_TRUE THEN
        OPEN get_pre_us_id_act(p_x_flight_schedules_tbl(i).unit_config_header_id);
        LOOP
            FETCH get_pre_us_id_act INTO l_pre_us_tbl(l_count).unit_schedule_id,
                         l_pre_us_tbl(l_count).arrival_time;
            EXIT WHEN  get_pre_us_id_act%NOTFOUND;
            IF l_count > 1 THEN
                IF l_pre_us_tbl(l_count-1).arrival_time = l_pre_us_tbl(l_count).arrival_time
                THEN
                    l_equal_arr_count := l_equal_arr_count + 1;
                ELSIF l_equal_arr_count > 0 THEN
                    LOOP
                      l_pre_us_tbl(l_count-l_equal_arr_count-1).preceding_us_id := l_pre_us_tbl(l_count).unit_schedule_id;
                      EXIT WHEN l_equal_arr_count = 0;
                      l_equal_arr_count := l_equal_arr_count -1;
                    END LOOP;
                ELSE
                    l_pre_us_tbl(l_count-1).preceding_us_id := l_pre_us_tbl(l_count).unit_schedule_id;
                END IF;
            END IF;
            l_count := l_count + 1;
        END LOOP;
        CLOSE get_pre_us_id_act;
    ELSE
        OPEN get_pre_us_id_est(p_x_flight_schedules_tbl(i).unit_config_header_id);
        LOOP
            FETCH get_pre_us_id_est INTO l_pre_us_tbl(l_count).unit_schedule_id,
                         l_pre_us_tbl(l_count).arrival_time;
            EXIT WHEN  get_pre_us_id_est%NOTFOUND;
            IF l_count > 1 THEN
                IF l_pre_us_tbl(l_count-1).arrival_time = l_pre_us_tbl(l_count).arrival_time
                THEN
                    l_equal_arr_count := l_equal_arr_count + 1;
                ELSIF l_equal_arr_count > 0 THEN
                    LOOP
                      l_pre_us_tbl(l_count-l_equal_arr_count-1).preceding_us_id := l_pre_us_tbl(l_count).unit_schedule_id;
                      EXIT WHEN l_equal_arr_count = 0;
                      l_equal_arr_count := l_equal_arr_count -1;
                    END LOOP;
                ELSE
                    l_pre_us_tbl(l_count-1).preceding_us_id := l_pre_us_tbl(l_count).unit_schedule_id;
                END IF;
            END IF;
            l_count := l_count + 1;
        END LOOP;
        CLOSE get_pre_us_id_est;
    END IF;

    --Update the table.
    FOR j IN 1..l_pre_us_tbl.COUNT
    LOOP
        UPDATE AHL_UNIT_SCHEDULES
        SET preceding_us_id = l_pre_us_tbl(j).preceding_us_id
        WHERE unit_schedule_id = l_pre_us_tbl(j).unit_schedule_id;
    END LOOP;

END LOOP;

END Sequence_Flight_Schedules;

-----------------------------------------------------------------------------------------------------
-- Procedure for synchronising a Transit Visit with a Flight Schedule if the Flight shcedule Estimated
-- dates  are changed.
-----------------------------------------------------------------------------------------------------

PROCEDURE Synchronize_Visit_Details (
x_return_status         OUT NOCOPY      VARCHAR2,
p_visit_sync_rec    IN OUT NOCOPY   VISIT_SYNC_REC_TYPE
)
IS

l_api_name  CONSTANT    VARCHAR2(30)    := 'Synchronize_Visit_Details';
l_msg_count NUMBER;
l_msg_data  VARCHAR2(150);
l_time_diff NUMBER;


BEGIN
    -- Initialize the return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
        END IF;

    -- If the time difference is null then take the time difference as 0
    l_time_diff := NVL(p_visit_sync_rec.CHANGED_ARRIVAL_TIME,0);

    IF( p_visit_sync_rec.VISIT_RESCHEDULE_MODE <> 'NEVER_RESCHEDULE')
    THEN

        OPEN get_flight_visit( p_visit_sync_rec.UNIT_SCHEDULE_ID );

        LOOP

        FETCH get_flight_visit into l_flight_visit;

        EXIT WHEN get_flight_visit%NOTFOUND;

        l_visit_count := get_flight_visit%ROWCOUNT;

        l_visit_tbl(l_visit_count).visit_id := l_flight_visit.visit_id;
        l_visit_tbl(l_visit_count).object_version_number := l_flight_visit.object_version_number;
        l_visit_tbl(l_visit_count).start_date := l_flight_visit.start_date_time + l_time_diff;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                ' changed arrival time ' || p_visit_sync_rec.CHANGED_ARRIVAL_TIME ||
                ' changed org id ' || TO_CHAR(p_visit_sync_rec.CHANGED_ORG_ID) ||
                ' changed dept id ' || TO_CHAR(p_visit_sync_rec.CHANGED_DEPT_ID )
            );
        END IF;

        IF( l_flight_visit.close_date_time IS NOT NULL)
        THEN
            l_visit_tbl(l_visit_count).PLAN_END_DATE  := l_flight_visit.close_date_time + l_time_diff;
        ELSE
              -- calculate the close date time.
                l_visit_tbl(l_visit_count).PLAN_END_DATE  := AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(l_flight_visit.visit_id , FND_API.G_FALSE)   + l_time_diff;
        END IF;

        l_visit_tbl(l_visit_count).item_instance_id := l_flight_visit.item_instance_id;
        l_visit_tbl(l_visit_count).unit_schedule_id := l_flight_visit.unit_schedule_id;

        IF( p_visit_sync_rec.CHANGED_ORG_ID IS NOT NULL AND p_visit_sync_rec.CHANGED_ORG_ID <> l_flight_visit.ORGANIZATION_ID )
        THEN
            l_visit_tbl(l_visit_count).ORGANIZATION_ID := p_visit_sync_rec.CHANGED_ORG_ID;
        ELSE
            l_visit_tbl(l_visit_count).ORGANIZATION_ID := l_flight_visit.ORGANIZATION_ID;
        END IF;

        IF( p_visit_sync_rec.CHANGED_DEPT_ID IS NOT NULL AND p_visit_sync_rec.CHANGED_DEPT_ID <> l_flight_visit.DEPARTMENT_ID )
        THEN
            l_visit_tbl(l_visit_count).DEPARTMENT_ID   := p_visit_sync_rec.CHANGED_DEPT_ID;
        ELSE
            l_visit_tbl(l_visit_count).DEPARTMENT_ID   := l_flight_visit.DEPARTMENT_ID ;
        END IF;

        IF( p_visit_sync_rec.VISIT_RESCHEDULE_MODE = 'ALWAYS_RESCHEDULE')
        THEN
            l_visit_tbl(l_visit_count).operation_flag := 'S';
        ELSIF ( p_visit_sync_rec.VISIT_RESCHEDULE_MODE = 'DELETE')

        THEN
            -- Bug # 9075539 -- start
	    -- delete all associations of the flight schedule to its own transit visits
	    AHL_VWP_VISITS_PVT.DELETE_FLIGHT_ASSOC(
	     p_visit_sync_rec.UNIT_SCHEDULE_ID,
	     x_return_status
    	    );
    	    -- Bug # 9075539 -- end
            l_visit_tbl(l_visit_count).operation_flag := 'X';
        END IF;

        END LOOP;

        CLOSE get_flight_visit;

        AHL_VWP_VISITS_PVT.Process_Visit (
        p_api_version       => 1.0,
        p_init_msg_list     => FND_API.g_false,
        p_commit            => FND_API.g_false,
        p_validation_level  => FND_API.g_valid_level_full,
        p_module_type       => 'JSP',
        p_x_Visit_tbl       => l_visit_tbl,
        x_return_status     => x_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data
            );

        -- Bug # 9075539 -- start
	-- If any severe error occurs, then, abort API.
	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			fnd_log.level_exception,
			'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
			'AHL_VWP_VISITS_PVT.Process_Visit returned with expected error..'
		    );
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			fnd_log.level_exception,
			'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
			'validate_record returned with un-expected error..'
		    );
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = 'V'  THEN
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			fnd_log.level_exception,
			'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
			'Visit could not be deleted or cancelled...Please refer error stack for more details..'
		    );
		END IF;
	END IF;
	-- Bug # 9075539 -- end

    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of '||l_api_name
        );
         END IF;
 EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => l_msg_count,
                       p_data  => l_msg_data);

     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => l_msg_count,
                       p_data  => l_msg_data);

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                    p_procedure_name  =>  l_api_name,
                    p_error_text      => SUBSTR(SQLERRM,1,240));

        END IF;
        FND_MSG_PUB.count_and_get
        (
        p_count     => l_msg_count,
        p_data      => l_msg_data,
        p_encoded   => FND_API.G_FALSE
        );

END Synchronize_Visit_Details;

PROCEDURE Create_Flight_Schedules(
 p_module_type               IN             VARCHAR2,
 x_return_status             OUT NOCOPY         VARCHAR2,
 p_x_flight_schedules_tbl    IN OUT NOCOPY      FLIGHT_SCHEDULES_TBL_TYPE
)
IS

l_api_name      CONSTANT    VARCHAR2(30)    := 'Create_Flight_Schedules';
l_api_version       CONSTANT    NUMBER      := 1;
l_msg_count NUMBER;
l_overlap_us_count  NUMBER;

BEGIN
    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    FOR i IN p_x_flight_schedules_tbl.FIRST..p_x_flight_schedules_tbl.LAST
    LOOP
        IF p_x_flight_schedules_tbl(i).DML_OPERATION = 'C'
        THEN
            -- Validate all attributes (Item level validation)
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Validate attributes before creating flight schedules...'
             );
            END IF;

            validate_attributes
            (
               p_x_flight_schedules_tbl(i),
               x_return_status
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'p_x_flight_schedules_tbl('||i||').DML_OPERATION : ' || p_x_flight_schedules_tbl(i).DML_OPERATION
             );
            END IF;

            -- Convert Values to Ids.
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Calling convert_values_to_ids..'
             );
            END IF;

            IF ( p_module_type = 'OAF' OR p_module_type = 'JSP' )
            THEN
                convert_values_to_ids
                (
                p_x_flight_schedules_tbl(i),
                x_return_status
                );

                -- If any severe error occurs, then, abort API.
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                            'convert_values_to_ids returned with expected error..'
                        );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                            'convert_values_to_ids returned with un-expected error..'
                        );
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;-- return status
            END IF;-- module type


            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'call validate_mandatory_inputs to check all missing mandatory fields'
             );
            END IF;

            validate_mandatory_fields
            (
              p_x_flight_schedules_tbl(i),
              x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_mandatory_fields returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_mandatory_fields returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Validate all records before DML '
             );
            END IF;

            validate_record
            (
              p_x_flight_schedules_tbl(i),
              x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Creating new Flight scehdule ..'
             );
            END IF;

            -- Insert the record
            INSERT INTO AHL_UNIT_SCHEDULES
            (
                UNIT_SCHEDULE_ID,
                FLIGHT_NUMBER,
                SEGMENT,
                DEPARTURE_DEPT_ID,
                DEPARTURE_ORG_ID,
                ARRIVAL_DEPT_ID,
                ARRIVAL_ORG_ID,
                EST_DEPARTURE_TIME,
                EST_ARRIVAL_TIME,
                ACTUAL_DEPARTURE_TIME,
                ACTUAL_ARRIVAL_TIME,
                PRECEDING_US_ID,
                UNIT_CONFIG_HEADER_ID,
                VISIT_RESCHEDULE_MODE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                OBJECT_VERSION_NUMBER,
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
                AHL_UNIT_SCHEDULES_S.NEXTVAL,
                p_x_flight_schedules_tbl(i).FLIGHT_NUMBER,
                p_x_flight_schedules_tbl(i).SEGMENT,
                p_x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID,
                p_x_flight_schedules_tbl(i).DEPARTURE_ORG_ID,
                p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID,
                p_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID,
                p_x_flight_schedules_tbl(i).EST_DEPARTURE_TIME,
                p_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME,
                p_x_flight_schedules_tbl(i).ACTUAL_DEPARTURE_TIME,
                p_x_flight_schedules_tbl(i).ACTUAL_ARRIVAL_TIME,
                p_x_flight_schedules_tbl(i).PRECEDING_US_ID,
                p_x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID,
                p_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE,
                G_SYSDATE,
                G_USER_ID,
                G_SYSDATE,
                G_USER_ID,
                G_LOGIN_ID,
                1,
                p_x_flight_schedules_tbl(i).ATTRIBUTE_CATEGORY,
                p_x_flight_schedules_tbl(i).ATTRIBUTE1,
                p_x_flight_schedules_tbl(i).ATTRIBUTE2,
                p_x_flight_schedules_tbl(i).ATTRIBUTE3,
                p_x_flight_schedules_tbl(i).ATTRIBUTE4,
                p_x_flight_schedules_tbl(i).ATTRIBUTE5,
                p_x_flight_schedules_tbl(i).ATTRIBUTE6,
                p_x_flight_schedules_tbl(i).ATTRIBUTE7,
                p_x_flight_schedules_tbl(i).ATTRIBUTE8,
                p_x_flight_schedules_tbl(i).ATTRIBUTE9,
                p_x_flight_schedules_tbl(i).ATTRIBUTE10,
                p_x_flight_schedules_tbl(i).ATTRIBUTE11,
                p_x_flight_schedules_tbl(i).ATTRIBUTE12,
                p_x_flight_schedules_tbl(i).ATTRIBUTE13,
                p_x_flight_schedules_tbl(i).ATTRIBUTE14,
                p_x_flight_schedules_tbl(i).ATTRIBUTE15
            );
            SELECT AHL_UNIT_SCHEDULES_S.CURRVAL INTO p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID FROM DUAL ;
        END IF;

        -- Check if overlaps are occurring. If there is any overlap, show warning.
        l_overlap_us_count := 0;
        IF p_x_flight_schedules_tbl(i).actual_departure_time IS NOT NULL AND p_x_flight_schedules_tbl(i).actual_arrival_time IS NOT NULL
        THEN
            SELECT count(unit_schedule_id) INTO l_overlap_us_count
            FROM AHL_UNIT_SCHEDULES
            WHERE unit_config_header_id = p_x_flight_schedules_tbl(i).unit_config_header_id
            AND (
                  (
                (p_x_flight_schedules_tbl(i).actual_departure_time between ACTUAL_DEPARTURE_TIME and ACTUAL_ARRIVAL_TIME)
                AND
                ( p_x_flight_schedules_tbl(i).actual_arrival_time between ACTUAL_DEPARTURE_TIME and ACTUAL_ARRIVAL_TIME)
                  )
                  OR (ACTUAL_DEPARTURE_TIME between p_x_flight_schedules_tbl(i).actual_departure_time and p_x_flight_schedules_tbl(i).actual_arrival_time)
                  OR (ACTUAL_ARRIVAL_TIME between p_x_flight_schedules_tbl(i).actual_departure_time and p_x_flight_schedules_tbl(i).actual_arrival_time)
                )
            AND unit_schedule_id <> p_x_flight_schedules_tbl(i).unit_schedule_id;
        ELSIF  p_x_flight_schedules_tbl(i).est_departure_time IS NOT NULL AND p_x_flight_schedules_tbl(i).est_arrival_time IS NOT NULL
        THEN
            SELECT count(unit_schedule_id) INTO l_overlap_us_count
            FROM AHL_UNIT_SCHEDULES
            WHERE unit_config_header_id = p_x_flight_schedules_tbl(i).unit_config_header_id
            /*AND (
                  (
                   (p_x_flight_schedules_tbl(i).est_departure_time  between EST_DEPARTURE_TIME and EST_ARRIVAL_TIME)
                   AND
                   ( p_x_flight_schedules_tbl(i).est_arrival_time between EST_DEPARTURE_TIME and EST_ARRIVAL_TIME)
                  )
                  OR (EST_DEPARTURE_TIME between p_x_flight_schedules_tbl(i).est_departure_time  and p_x_flight_schedules_tbl(i).est_arrival_time)
                  OR (EST_ARRIVAL_TIME between p_x_flight_schedules_tbl(i).est_departure_time  and p_x_flight_schedules_tbl(i).est_arrival_time)
                )*/
            AND (
                  (
                   ((p_x_flight_schedules_tbl(i).est_departure_time>EST_DEPARTURE_TIME  AND p_x_flight_schedules_tbl(i).est_departure_time<EST_ARRIVAL_TIME))
                   AND
                   ((p_x_flight_schedules_tbl(i).est_arrival_time>EST_DEPARTURE_TIME and p_x_flight_schedules_tbl(i).est_arrival_time<EST_ARRIVAL_TIME))
                  )
                  OR ((EST_DEPARTURE_TIME>p_x_flight_schedules_tbl(i).est_departure_time  and EST_DEPARTURE_TIME<p_x_flight_schedules_tbl(i).est_arrival_time))
                  OR ((EST_ARRIVAL_TIME>p_x_flight_schedules_tbl(i).est_departure_time  and EST_ARRIVAL_TIME<p_x_flight_schedules_tbl(i).est_arrival_time))
                )
            AND unit_schedule_id <> p_x_flight_schedules_tbl(i).unit_schedule_id;
        END IF;

        IF l_overlap_us_count > 0 THEN
        -- There is an overlap in times.
            FND_MESSAGE.set_name('AHL', 'AHL_UA_US_TIME_OVERLAP');
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(
                                    p_flight_schedule_rec   =>  p_x_flight_schedules_tbl(i)
                              ) );

            p_x_flight_schedules_tbl(i).conflict_message := FND_MESSAGE.GET;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Overlap in flight times specified,'||
                'this is a warning and not a error for '||p_x_flight_schedules_tbl(i).unit_schedule_id
               );
            END IF;
        END IF;
    END LOOP;
END Create_Flight_Schedules;


PROCEDURE Update_Flight_Schedules(
 p_module_type               IN             VARCHAR2,
 x_return_status             OUT NOCOPY         VARCHAR2,
 p_x_flight_schedules_tbl    IN OUT NOCOPY      FLIGHT_SCHEDULES_TBL_TYPE
)
IS

l_api_name      CONSTANT    VARCHAR2(30)    := 'Update_Flight_Schedules';
l_api_version       CONSTANT    NUMBER      := 1;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(150);
l_dummy         VARCHAR2(1);

-- Cursor for getting old flight schedule details.
CURSOR old_flight_rec_csr(p_unit_schedule_id IN NUMBER)
IS
SELECT est_arrival_time, arrival_org_id, arrival_dept_id
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_schedule_id;

l_old_flight_rec old_flight_rec_csr%ROWTYPE;
l_visit_sync_rec visit_sync_rec_type;

l_is_sync_needed VARCHAR2(1);
l_overlap_us_count  NUMBER;

BEGIN
    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    -- Validate all inputs to the API
    FOR i IN p_x_flight_schedules_tbl.FIRST..p_x_flight_schedules_tbl.LAST
    LOOP
        IF ( p_x_flight_schedules_tbl(i).DML_OPERATION = 'U' )
        THEN
            -- Validate all attributes (Item level validation)
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Validate attributes before creating flight schedules...'
             );
            END IF;

            validate_attributes
            (
               p_x_flight_schedules_tbl(i),
               x_return_status
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'p_x_flight_schedules_tbl('||i||').DML_OPERATION : ' || p_x_flight_schedules_tbl(i).DML_OPERATION
             );
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Calling convert_values_to_ids..'
             );
            END IF;

            IF ( p_module_type = 'OAF' OR p_module_type = 'JSP' )
            THEN
                convert_values_to_ids
                (
                p_x_flight_schedules_tbl(i),
                x_return_status
                );

                -- If any severe error occurs, then, abort API.
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                            'convert_values_to_ids returned with expected error..'
                        );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                            'convert_values_to_ids returned with un-expected error..'
                        );
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;-- return status
            END IF;-- module type

            -- Default missing and unchanged attributes.
            IF ( p_module_type <> 'OAF' )
            THEN
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'default_unchanged_attributes for update operation. Module type is '||p_module_type
                 );
                END IF;

                default_unchanged_attributes
                (
                   p_x_flight_schedule_rec  =>  p_x_flight_schedules_tbl(i)
                );

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'call validate_mandatory_inputs to check all missing mandatory fields'
                 );
                END IF;
            END IF;

            validate_mandatory_fields
            (
              p_x_flight_schedules_tbl(i),
              x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_mandatory_fields returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_mandatory_fields returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF; -- return status


            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'Validate all records before DML '
                 );
            END IF;

            validate_update
            (
              p_x_flight_schedules_tbl(i),
              x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_update returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_update returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Validate all records before DML '
             );
            END IF;

            validate_record
            (
              p_x_flight_schedules_tbl(i),
              x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Updating Flight scehdule ->'||p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID
             );
            END IF;

            OPEN old_flight_rec_csr(p_x_flight_schedules_tbl(i).unit_schedule_id);
            FETCH old_flight_rec_csr INTO l_old_flight_rec;

            -- Update the record
            UPDATE AHL_UNIT_SCHEDULES SET
                UNIT_SCHEDULE_ID    =   p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID,
                FLIGHT_NUMBER       =   p_x_flight_schedules_tbl(i).FLIGHT_NUMBER,
                SEGMENT         =   p_x_flight_schedules_tbl(i).SEGMENT,
                DEPARTURE_DEPT_ID   =   p_x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID,
                DEPARTURE_ORG_ID    =   p_x_flight_schedules_tbl(i).DEPARTURE_ORG_ID,
                ARRIVAL_DEPT_ID     =   p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID,
                ARRIVAL_ORG_ID      =   p_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID,
                EST_DEPARTURE_TIME  =   p_x_flight_schedules_tbl(i).EST_DEPARTURE_TIME,
                EST_ARRIVAL_TIME    =   p_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME,
                ACTUAL_DEPARTURE_TIME   =   p_x_flight_schedules_tbl(i).ACTUAL_DEPARTURE_TIME,
                ACTUAL_ARRIVAL_TIME =   p_x_flight_schedules_tbl(i).ACTUAL_ARRIVAL_TIME,
                PRECEDING_US_ID     =   p_x_flight_schedules_tbl(i).PRECEDING_US_ID,
                UNIT_CONFIG_HEADER_ID   =   p_x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID,
                VISIT_RESCHEDULE_MODE   =   p_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE,
                LAST_UPDATE_DATE    =   G_SYSDATE,
                LAST_UPDATED_BY     =   G_USER_ID,
                CREATION_DATE       =   G_SYSDATE,
                CREATED_BY      =   G_USER_ID,
                LAST_UPDATE_LOGIN   =   G_LOGIN_ID,
                OBJECT_VERSION_NUMBER   =   p_x_flight_schedules_tbl(i).OBJECT_VERSION_NUMBER + 1,
                ATTRIBUTE_CATEGORY  =   p_x_flight_schedules_tbl(i).ATTRIBUTE_CATEGORY,
                ATTRIBUTE1      =   p_x_flight_schedules_tbl(i).ATTRIBUTE1,
                ATTRIBUTE2      =   p_x_flight_schedules_tbl(i).ATTRIBUTE2,
                ATTRIBUTE3      =   p_x_flight_schedules_tbl(i).ATTRIBUTE3,
                ATTRIBUTE4      =   p_x_flight_schedules_tbl(i).ATTRIBUTE4,
                ATTRIBUTE5      =   p_x_flight_schedules_tbl(i).ATTRIBUTE5,
                ATTRIBUTE6      =   p_x_flight_schedules_tbl(i).ATTRIBUTE6,
                ATTRIBUTE7      =   p_x_flight_schedules_tbl(i).ATTRIBUTE7,
                ATTRIBUTE8      =   p_x_flight_schedules_tbl(i).ATTRIBUTE8,
                ATTRIBUTE9      =   p_x_flight_schedules_tbl(i).ATTRIBUTE9,
                ATTRIBUTE10     =   p_x_flight_schedules_tbl(i).ATTRIBUTE10,
                ATTRIBUTE11     =   p_x_flight_schedules_tbl(i).ATTRIBUTE11,
                ATTRIBUTE12     =   p_x_flight_schedules_tbl(i).ATTRIBUTE12,
                ATTRIBUTE13     =   p_x_flight_schedules_tbl(i).ATTRIBUTE13,
                ATTRIBUTE14     =   p_x_flight_schedules_tbl(i).ATTRIBUTE14,
                ATTRIBUTE15     =   p_x_flight_schedules_tbl(i).ATTRIBUTE15
            WHERE
                unit_schedule_id = p_x_flight_schedules_tbl(i).unit_schedule_id
                AND object_version_number= p_x_flight_schedules_tbl(i).object_version_number;

            -- If the record does not exist, then, abort API.
            IF ( SQL%ROWCOUNT = 0 ) THEN
              FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_CHANGED');
              FND_MESSAGE.set_token( 'RECORD', get_record_identifier(
                                    p_flight_schedule_rec   =>  p_x_flight_schedules_tbl(i)
                          ) );
              FND_MSG_PUB.add;
              IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
                 (
                    fnd_log.level_error,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'SQL Error, Update failed..'
                 );
              END IF;
            END IF;

            -- Set OUT values
            p_x_flight_schedules_tbl(i).object_version_number := p_x_flight_schedules_tbl(i).object_version_number + 1;
            --p_x_flight_schedule_rec.superuser_role := is_super_user;

            -- Calculate visit synchronization details.
            l_is_sync_needed := 'N';


            IF old_flight_rec_csr%FOUND THEN
                -- Check if Estimated arrival time has changed.
                IF l_old_flight_rec.EST_ARRIVAL_TIME <> p_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME
                THEN
                    l_visit_sync_rec.CHANGED_ARRIVAL_TIME := p_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME - l_old_flight_rec.EST_ARRIVAL_TIME;
                    l_is_sync_needed := 'Y';
                END IF;

                -- Check if Estimated arrival time has changed.
                IF l_old_flight_rec.ARRIVAL_ORG_ID <> p_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID
                THEN
                    -- Estimated arrival time has changed, so reschedule visit
                    l_visit_sync_rec.CHANGED_ORG_ID := p_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID;
                    l_is_sync_needed := 'Y';
                END IF;

                -- Check if Estimated arrival time has changed.
                IF l_old_flight_rec.ARRIVAL_DEPT_ID <> p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID
                THEN
                    -- Estimated arrival time has changed, so reschedule visit
                    l_visit_sync_rec.CHANGED_DEPT_ID := p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID;
                    l_is_sync_needed := 'Y';
                END IF;
            END IF;

            IF l_is_sync_needed = 'Y' THEN

                --populate visit reschedule mode.
                l_visit_sync_rec.visit_reschedule_mode :=  p_x_flight_schedules_tbl(i).visit_reschedule_mode;
                l_visit_sync_rec.unit_schedule_id := p_x_flight_schedules_tbl(i).unit_schedule_id;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'Synchronize visits affected if any for flight -> '||p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID
                 );
                END IF;

                --Call visit synchronization function to synchronize visit with updated flight schedule

                Synchronize_Visit_Details (
                x_return_status          =>     x_return_status,
                p_visit_sync_rec     => l_visit_sync_rec
                );

                -- If any severe error occurs, then, abort API.
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                            'Synchronize_Visit_Details returned with expected error..'
                        );
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                        fnd_log.string
                        (
                            fnd_log.level_exception,
                            'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                            'Synchronize_Visit_Details returned with un-expected error..'
                        );
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF; -- return status check
            END IF; -- l_sync_flag
        END IF; -- DML Operation check

        -- Check if overlaps are occurring. If there is any overlap, show warning.
        l_overlap_us_count := 0;
        IF p_x_flight_schedules_tbl(i).actual_departure_time IS NOT NULL AND p_x_flight_schedules_tbl(i).actual_arrival_time IS NOT NULL
        THEN
            SELECT count(unit_schedule_id) INTO l_overlap_us_count
            FROM AHL_UNIT_SCHEDULES
            WHERE unit_config_header_id = p_x_flight_schedules_tbl(i).unit_config_header_id
            AND (
                  (
                (p_x_flight_schedules_tbl(i).actual_departure_time between ACTUAL_DEPARTURE_TIME and ACTUAL_ARRIVAL_TIME)
                AND
                ( p_x_flight_schedules_tbl(i).actual_arrival_time between ACTUAL_DEPARTURE_TIME and ACTUAL_ARRIVAL_TIME)
                  )
                  OR (ACTUAL_DEPARTURE_TIME between p_x_flight_schedules_tbl(i).actual_departure_time and p_x_flight_schedules_tbl(i).actual_arrival_time)
                  OR (ACTUAL_ARRIVAL_TIME between p_x_flight_schedules_tbl(i).actual_departure_time and p_x_flight_schedules_tbl(i).actual_arrival_time)
                )
            AND unit_schedule_id <> p_x_flight_schedules_tbl(i).unit_schedule_id;
        ELSIF  p_x_flight_schedules_tbl(i).est_departure_time IS NOT NULL AND p_x_flight_schedules_tbl(i).est_arrival_time IS NOT NULL
        THEN
            SELECT count(unit_schedule_id) INTO l_overlap_us_count
            FROM AHL_UNIT_SCHEDULES
            WHERE unit_config_header_id = p_x_flight_schedules_tbl(i).unit_config_header_id
            /*AND (
                  (
                   (p_x_flight_schedules_tbl(i).est_departure_time  between EST_DEPARTURE_TIME and EST_ARRIVAL_TIME)
                   AND
                   ( p_x_flight_schedules_tbl(i).est_arrival_time between EST_DEPARTURE_TIME and EST_ARRIVAL_TIME)
                  )
                  OR (EST_DEPARTURE_TIME between p_x_flight_schedules_tbl(i).est_departure_time  and p_x_flight_schedules_tbl(i).est_arrival_time)
                  OR (EST_ARRIVAL_TIME between p_x_flight_schedules_tbl(i).est_departure_time  and p_x_flight_schedules_tbl(i).est_arrival_time)
                )*/
            AND (
                  (
                   ((p_x_flight_schedules_tbl(i).est_departure_time>EST_DEPARTURE_TIME  AND p_x_flight_schedules_tbl(i).est_departure_time<EST_ARRIVAL_TIME))
                   AND
                   ((p_x_flight_schedules_tbl(i).est_arrival_time>EST_DEPARTURE_TIME and p_x_flight_schedules_tbl(i).est_arrival_time<EST_ARRIVAL_TIME))
                  )
                  OR ((EST_DEPARTURE_TIME>p_x_flight_schedules_tbl(i).est_departure_time  and EST_DEPARTURE_TIME<p_x_flight_schedules_tbl(i).est_arrival_time))
                  OR ((EST_ARRIVAL_TIME>p_x_flight_schedules_tbl(i).est_departure_time  and EST_ARRIVAL_TIME<p_x_flight_schedules_tbl(i).est_arrival_time))
                )
            AND unit_schedule_id <> p_x_flight_schedules_tbl(i).unit_schedule_id;
        END IF;

        IF l_overlap_us_count > 0 THEN
        -- There is an overlap in times.
            FND_MESSAGE.set_name('AHL', 'AHL_UA_US_TIME_OVERLAP');
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(
                                    p_flight_schedule_rec   =>  p_x_flight_schedules_tbl(i)
                              ) );

            p_x_flight_schedules_tbl(i).conflict_message := FND_MESSAGE.GET;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
              fnd_log.string
               (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Overlap in flight times specified,'||
                'this is a warning and not a error for '||p_x_flight_schedules_tbl(i).unit_schedule_id
               );
            END IF;
        END IF;
    END LOOP;

END Update_Flight_Schedules;


PROCEDURE Delete_Flight_Schedules(
 x_return_status             OUT NOCOPY         VARCHAR2,
 x_msg_count                 OUT NOCOPY         NUMBER,
 x_msg_data                  OUT NOCOPY         VARCHAR2,
 p_x_flight_schedules_tbl    IN OUT NOCOPY      FLIGHT_SCHEDULES_TBL_TYPE
)
IS

-- Bug # 9075539 -- start
-- Cursor for fetching synchronization rule for a given flight.
CURSOR c_get_sync_rule(c_unit_sch_id IN NUMBER)
IS
SELECT visit_reschedule_mode
FROM   ahl_unit_schedules
WHERE  unit_schedule_id = c_unit_sch_id;

l_sync_rule VARCHAR2(30);
-- Bug # 9075539 -- end

l_api_name          CONSTANT    VARCHAR2(30)    := 'Delete_Flight_Schedules';
l_api_version           CONSTANT    NUMBER      := 1.0;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(150);

BEGIN

    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    -- Validate all inputs to the API
    FOR i IN p_x_flight_schedules_tbl.FIRST..p_x_flight_schedules_tbl.LAST
    LOOP

        IF ( p_x_flight_schedules_tbl(i).DML_OPERATION = 'D' )
        THEN
            -- Validate all attributes (Item level validation)
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Validate attributes before creating flight schedules...'
             );
            END IF;

            validate_attributes
            (
               p_x_flight_schedules_tbl(i),
               x_return_status
            );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Validate all records before DML '
             );
            END IF;

            validate_record
            (
              p_x_flight_schedules_tbl(i),
              x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Delete the record
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Deleting Flight scehdule -> '||p_x_flight_schedules_tbl(i).unit_schedule_id
             );
            END IF;

            -- find all transit visits for the particular flight schedule
            OPEN get_flight_visit( p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID );
            LOOP
                FETCH get_flight_visit into l_flight_visit;
                EXIT WHEN get_flight_visit%NOTFOUND;
                l_visit_count := get_flight_visit%ROWCOUNT;
                l_visit_tbl(l_visit_count).visit_id := l_flight_visit.visit_id;
                l_visit_tbl(l_visit_count).object_version_number := l_flight_visit.object_version_number;
                l_visit_tbl(l_visit_count).operation_flag := 'X';
            END LOOP;
            CLOSE get_flight_visit;

            -- delete all associations of the flight schedule to its own transit visits
            AHL_VWP_VISITS_PVT.DELETE_FLIGHT_ASSOC(
             p_x_flight_schedules_tbl(i).unit_schedule_id,
             x_return_status
            );

            -- If any severe error occurs, then, abort API.
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'AHL_VWP_VISITS_PVT.Process_Visit returned with expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string
                    (
                        fnd_log.level_exception,
                        'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
                        'validate_record returned with un-expected error..'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Bug # 9075539 -- start
            -- When a flight schedule is deleted, the associated Visits will be canceled
            -- or deleted only when the synchronization rule is setup as either
            -- 'ALWAYS_RESCHEDULE' or 'DELETE'.

            l_sync_rule := NULL;

	    OPEN c_get_sync_rule(p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
	    FETCH c_get_sync_rule INTO l_sync_rule;
	    CLOSE c_get_sync_rule;

	    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
		  fnd_log.level_exception,
		  'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
		  'VISIT_RESCHEDULE_MODE => '||l_sync_rule
		);
	    END IF;

            IF
              (
                  l_sync_rule = 'ALWAYS_RESCHEDULE'  OR l_sync_rule = 'DELETE'
              )
            THEN

		    -- delete the transit visits found
		    AHL_VWP_VISITS_PVT.Process_Visit (
		    p_api_version       => 1.0,
		    p_init_msg_list     => FND_API.g_false,
		    p_commit            => FND_API.g_false,
		    p_validation_level  => FND_API.g_valid_level_full,
		    p_module_type       => 'JSP',
		    p_x_Visit_tbl       => l_visit_tbl,
		    x_return_status     => x_return_status,
		    x_msg_count         => l_msg_count,
		    x_msg_data          => l_msg_data
		    );

		    -- If any severe error occurs, then, abort API.
		    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
			    fnd_log.string
			    (
				fnd_log.level_exception,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
				'AHL_VWP_VISITS_PVT.Process_Visit returned with expected error..'
			    );
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
			    fnd_log.string
			    (
				fnd_log.level_exception,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
				'validate_record returned with un-expected error..'
			    );
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    ELSIF x_return_status = 'V'  THEN
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)THEN
			    fnd_log.string
			    (
				fnd_log.level_exception,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name ,
				'Visit could not be deleted or cancelled...Please refer error stack for more details..'
			    );
			END IF;
		    END IF;

            END IF;
            -- Bug # 9075539 -- end

            DELETE FROM AHL_UNIT_SCHEDULES
            WHERE unit_schedule_id = p_x_flight_schedules_tbl(i).unit_schedule_id
                  AND object_version_number= p_x_flight_schedules_tbl(i).object_version_number;

            -- If the record does not exist, then, abort API.
            IF ( SQL%ROWCOUNT = 0 ) THEN
                FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_CHANGED');
                FND_MESSAGE.set_token( 'RECORD', get_record_identifier(
                                 p_flight_schedule_rec  =>  p_x_flight_schedules_tbl(i)
                              ) );
                FND_MSG_PUB.add;
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                  fnd_log.string
                   (
                       fnd_log.level_error,
                       'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                       'SQL Error, Delete failed..'
                   );
                END IF;
            END IF; -- error handling
        END IF; -- dml operation check
    END LOOP;
END Delete_Flight_Schedules;


-----------------------------------------------------------------------------------------------------
-- Procedure for creating/updating/deleting Flight Schedules.
-----------------------------------------------------------------------------------------------------
PROCEDURE Process_Flight_Schedules(
 p_api_version               IN             NUMBER      :=1.0,
 p_init_msg_list             IN             VARCHAR2    :=FND_API.G_FALSE,
 p_commit                    IN             VARCHAR2    :=FND_API.G_FALSE,
 p_validation_level          IN         NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN             VARCHAR2    :=FND_API.G_FALSE,
 p_module_type               IN             VARCHAR2    :=NULL,
 x_return_status             OUT NOCOPY         VARCHAR2,
 x_msg_count                 OUT NOCOPY         NUMBER,
 x_msg_data                  OUT NOCOPY         VARCHAR2,
 p_x_flight_schedules_tbl    IN OUT NOCOPY      FLIGHT_SCHEDULES_TBL_TYPE
)
IS
l_api_name          CONSTANT    VARCHAR2(30)    := 'Process_Flight_Schedules';
l_api_version           CONSTANT    NUMBER      := 1.0;
-- Bug # 9075539 - start
l_return_status         varchar2(1);
-- Bug # 9075539 - end
BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of Process_Flight_Schedules'
        );
        END IF;

    SAVEPOINT process_flight_schedules_pvt;

    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

    --Local procedure for Deleting Flight Schedules
    Delete_Flight_Schedules(
     x_return_status        =>  x_return_status,
     x_msg_count            =>  x_msg_count,
     x_msg_data         =>  x_msg_data,
     p_x_flight_schedules_tbl   =>  p_x_flight_schedules_tbl
    );

    -- Bug # 9075539 - start
    IF x_return_status = 'V'
    THEN
       l_return_status := x_return_status;
    END IF;
    -- Bug # 9075539 - end

    --Local procedure for Updating Flight Schedules
    Update_Flight_Schedules(
     p_module_type          =>  p_module_type,
     x_return_status        =>  x_return_status,
     p_x_flight_schedules_tbl   =>  p_x_flight_schedules_tbl
    );

    -- Bug # 9075539 - start
    IF x_return_status = 'V'
    THEN
       l_return_status := x_return_status;
    END IF;
    -- Bug # 9075539 - end

    --Local procedure for Creating Flight Schedules
    Create_Flight_Schedules(
     p_module_type          =>  p_module_type,
     x_return_status        =>  x_return_status,
     p_x_flight_schedules_tbl   =>  p_x_flight_schedules_tbl
    );


    -- Update Preceding Unit Flight Schedule Id after all DMLs.
    Sequence_Flight_Schedules(
        p_x_flight_schedules_tbl    =>  p_x_flight_schedules_tbl
    );


    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
     (
        fnd_log.level_statement,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'Done DML , committing the work'
     );
    END IF;

        IF FND_API.TO_BOOLEAN(p_commit) THEN
           COMMIT;
        END IF;

    -- Bug # 9075539 - start
    IF l_return_status = 'V'
    THEN
        x_return_status := 'V';
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => x_msg_count,
                       p_data  => X_msg_data);
    END IF;
    -- Bug # 9075539 - end

 IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the end of Process_Flight_Schedules'
        );
        END IF;
 EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO process_flight_schedules_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => x_msg_count,
                       p_data  => x_msg_data);

     WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO process_flight_schedules_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => x_msg_count,
                       p_data  => X_msg_data);

     WHEN OTHERS THEN
        ROLLBACK TO process_flight_schedules_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                    p_procedure_name  =>  l_api_name,
                    p_error_text      => SUBSTR(SQLERRM,1,240));

        END IF;
        FND_MSG_PUB.count_and_get
        (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
        );
END Process_Flight_Schedules;

-----------------------------------------------------------------------------------------------------
-- Procedure for Validating a Flight Schedule.
-----------------------------------------------------------------------------------------------------
PROCEDURE Validate_Flight_Schedule(
 p_api_version               IN             NUMBER      :=1.0,
 x_return_status             OUT NOCOPY         VARCHAR2,
 x_msg_count                 OUT NOCOPY         NUMBER,
 x_msg_data                  OUT NOCOPY         VARCHAR2,
 p_unit_config_id        IN         NUMBER,
 p_unit_schedule_id      IN         NUMBER
)
IS

l_api_name      CONSTANT    VARCHAR2(30)    := 'Validate_Flight_Schedule';
l_api_version       CONSTANT    NUMBER      := 1;
l_dummy         VARCHAR2(1);

CURSOR check_flight_exists_csr
(
    p_unit_schedule_id number,
    p_unit_config_id number
)
IS
SELECT 'X'
FROM AHL_UNIT_SCHEDULES
WHERE unit_schedule_id = p_unit_schedule_id
AND unit_config_header_id = nvl(p_unit_config_id, unit_config_header_id);

BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
        END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
     (
        fnd_log.level_statement,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'p_unit_schedule_id -> '||p_unit_schedule_id
        ||', p_unit_config_id -> '||p_unit_config_id
     );
    END IF;

    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    -- Throw error if p_unit_schedule_id is null

    IF p_unit_schedule_id IS NULL THEN
        FND_MESSAGE.set_name('AHL','AHL_UA_US_NOT_FOUND');
        FND_MSG_PUB.add;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string
            (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'unit schedule id is null..'
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        OPEN check_flight_exists_csr(p_unit_schedule_id, p_unit_config_id);
        FETCH check_flight_exists_csr INTO l_dummy;
        IF check_flight_exists_csr%NOTFOUND THEN
            FND_MESSAGE.set_name('AHL','AHL_UA_US_NOT_FOUND');
            FND_MSG_PUB.add;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string
                (
                    fnd_log.level_error,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'unit schedule Record is invalid..'
                );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE check_flight_exists_csr;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE check_flight_exists_csr;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
            'At the start of '||l_api_name
        );
         END IF;
 EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => x_msg_count,
                       p_data  => x_msg_data);

     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => x_msg_count,
                       p_data  => X_msg_data);

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                    p_procedure_name  =>  l_api_name,
                    p_error_text      => SUBSTR(SQLERRM,1,240));

        END IF;
        FND_MSG_PUB.count_and_get
        (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
        );

END Validate_Flight_Schedule;


   ------------------------------------------------------------------------------------------------
   -- Function which checks if current user is super user or not.
   ------------------------------------------------------------------------------------------------
   FUNCTION is_super_user

   RETURN VARCHAR2
   IS
   BEGIN

       IF (FND_FUNCTION.TEST('AHL_UA_SUPER_USER'))
       THEN
        RETURN FND_API.G_TRUE;
        --RETURN 'Y';
       ELSE
        RETURN FND_API.G_FALSE;
        --RETURN 'N';
       END IF;

   END is_super_user;

   ------------------------------------------------------------------------------------------------
   -- Function to check if delete is allowed for an unit schedule record
   ------------------------------------------------------------------------------------------------
   FUNCTION is_delete_allowed
   (
    p_unit_schedule_id  IN  NUMBER,
    p_is_super_user     IN  VARCHAR2
   )
   RETURN VARCHAR2
   IS
   --Cursor for checking if actuals are entered for the current unit schedule record.
   CURSOR get_curr_actuals_csr(p_unit_schedule_id IN NUMBER)
   IS
   SELECT actual_departure_time, actual_arrival_time
   FROM AHL_UNIT_SCHEDULES
   WHERE unit_schedule_id = p_unit_schedule_id;
   l_curr_acutals_rec get_curr_actuals_csr%ROWTYPE;

   --l_is_super_user VARCHAR2(1);
   l_api_name       CONSTANT    VARCHAR2(30)    := 'is_delete_allowed';

   BEGIN
    --l_is_super_user := p_is_super_user;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
        END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
     (
        fnd_log.level_statement,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'Flight Schedule id --> '|| p_unit_schedule_id ||' and is super user? '||p_is_super_user
     );
    END IF;

    --check current events actuals
    OPEN get_curr_actuals_csr(p_unit_schedule_id);
    FETCH get_curr_actuals_csr
            INTO
        l_curr_acutals_rec.actual_departure_time,
        l_curr_acutals_rec.actual_arrival_time;

    IF (l_curr_acutals_rec.actual_departure_time IS NULL
         AND l_curr_acutals_rec.actual_arrival_time IS NULL)
    THEN
        RETURN FND_API.G_TRUE;
    ELSIF (p_is_super_user = FND_API.G_TRUE
           AND l_curr_acutals_rec.actual_departure_time IS NOT NULL
           AND l_curr_acutals_rec.actual_arrival_time IS NOT NULL )
    THEN
        RETURN FND_API.G_TRUE;
    ELSE
        RETURN FND_API.G_FALSE;
    END IF;

   END is_delete_allowed;

   ------------------------------------------------------------------------------------------------
   -- Function to check if update is allowed for an unit schedule record
   ------------------------------------------------------------------------------------------------

   FUNCTION is_update_allowed
   (
    p_unit_schedule_id  IN  NUMBER,
    p_is_super_user     IN  VARCHAR2
   )
   RETURN VARCHAR2
   IS

   --Cursor for getting the succeeding event of an Unit Schedule.
   CURSOR get_succeeding_us_csr(p_unit_schedule_id IN NUMBER) IS
   SELECT actual_departure_time, actual_arrival_time
   FROM AHL_UNIT_SCHEDULES
   WHERE preceding_us_id = p_unit_schedule_id;

   l_api_name       CONSTANT    VARCHAR2(30)    := 'is_update_allowed';
   l_succeeding_us_rec get_succeeding_us_csr%ROWTYPE;
   l_actual_recorded VARCHAR2(1);

   BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of '||l_api_name
        );
        END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
     (
        fnd_log.level_statement,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'Flight Schedule id --> '|| p_unit_schedule_id ||' and is super user? '||p_is_super_user
     );
    END IF;

    OPEN get_succeeding_us_csr(p_unit_schedule_id);
    FETCH get_succeeding_us_csr INTO l_succeeding_us_rec;
    CLOSE get_succeeding_us_csr;

    l_actual_recorded := 'N';

    IF l_succeeding_us_rec.actual_departure_time IS NOT NULL OR
       l_succeeding_us_rec.actual_arrival_time IS NOT NULL
    THEN
        l_actual_recorded := 'Y';
    END IF;

    IF l_actual_recorded = 'N'
    THEN
        RETURN FND_API.G_TRUE;
    ELSIF l_actual_recorded = 'Y' AND p_is_super_user = FND_API.G_TRUE
    THEN
        RETURN FND_API.G_TRUE;
    ELSE
        RETURN FND_API.G_FALSE;
    END IF;

   END is_update_allowed;
END AHL_UA_FLIGHT_SCHEDULES_PVT;

/
