--------------------------------------------------------
--  DDL for Package Body AHL_PRD_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_OPERATIONS_PVT" AS
 /* $Header: AHLVPROB.pls 120.19.12010000.3 2009/11/05 17:08:52 viagrawa ship $ */

G_PKG_NAME   VARCHAR2(30) := 'AHL_PRD_OPERATIONS_PVT';
G_DEBUG      VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

FUNCTION get_date_and_time(p_date IN DATE,
                           p_date_hh24 IN VARCHAR2,
                           p_date_mi IN VARCHAR2,
                           p_date_ss IN VARCHAR2) RETURN DATE;

PROCEDURE default_attributes
(
  p_x_prd_workoper_rec       IN OUT NOCOPY AHL_PRD_OPERATIONS_PVT.prd_workoperation_rec
)
AS

  CURSOR get_workorder_rec(c_workorder_id  NUMBER)
  IS
  SELECT WO.route_id,
         WO.wip_entity_id,
         VST.organization_id,
         WDJ.scheduled_start_date,
         WDJ.scheduled_completion_date,
         WO.actual_start_date,
         WO.actual_end_date
  FROM   AHL_WORKORDERS WO,
         AHL_VISITS_B VST,
         WIP_DISCRETE_JOBS WDJ
  WHERE  WO.workorder_id         =c_workorder_id
  AND    WO.status_code          <> '22'
  AND    WO.visit_id             =VST.visit_id
  AND    WO.wip_entity_id        =WDJ.wip_entity_id (+);

  l_job_organization_id       NUMBER;
  l_job_wip_entity_id         NUMBER;
  l_job_route_id              NUMBER;
  l_job_scheduled_start_date  DATE;
  l_job_scheduled_end_date    DATE;
  l_job_actual_start_date     DATE;
  l_job_actual_end_date       DATE;

  CURSOR get_operation_details(c_operation_code VARCHAR2)
  IS
  SELECT OP.operation_id,
         OP.description,
         OP.qa_inspection_type
  FROM   AHL_OPERATIONS_VL OP
  WHERE  OP.concatenated_segments=c_operation_code
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(OP.start_date_active,SYSDATE))
  AND    TRUNC(NVL(OP.end_date_active,SYSDATE+1))
  AND    OP.revision_status_code='COMPLETE'
  AND    OP.revision_number IN
         ( SELECT MAX(revision_number)
           FROM   AHL_OPERATIONS_B_KFV
           --WHERE  concatenated_segments=OP.concatenated_segments
           WHERE  concatenated_segments=c_operation_code
           AND    revision_status_code='COMPLETE'
           AND    TRUNC(SYSDATE) BETWEEN TRUNC(start_date_active) AND
                  TRUNC(NVL(end_date_active,SYSDATE+1))
         );
  l_qa_inspection_type    VARCHAR2(150);
  l_description           VARCHAR2(500);

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);

BEGIN

  IF ( p_x_prd_workoper_rec.operation_code IS NOT NULL ) THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Job Operation is based on Route Management Operation' );
    END IF;

    OPEN  get_operation_details(p_x_prd_workoper_rec.operation_code);
    FETCH get_operation_details
    INTO  p_x_prd_workoper_rec.operation_id,
          l_description,
          l_qa_inspection_type;
    CLOSE get_operation_details;

    IF p_x_prd_workoper_rec.operation_description is NULL THEN
      p_x_prd_workoper_rec.operation_description:=l_description;
    END IF;
  END IF;

  SELECT ahl_workorder_operations_s.NEXTVAL
  INTO   p_x_prd_workoper_rec.workorder_operation_id
  FROM   DUAL;

  p_x_prd_workoper_rec.LAST_UPDATE_DATE     :=SYSDATE;
  p_x_prd_workoper_rec.LAST_UPDATED_BY      :=FND_GLOBAL.user_id;
  p_x_prd_workoper_rec.CREATION_DATE        :=SYSDATE;
  p_x_prd_workoper_rec.CREATED_BY           :=FND_GLOBAL.user_id;
  p_x_prd_workoper_rec.LAST_UPDATE_LOGIN    :=FND_GLOBAL.user_id;
  p_x_prd_workoper_rec.OBJECT_VERSION_NUMBER:=1;
  p_x_prd_workoper_rec.STATUS_CODE          :='2';

  OPEN  get_workorder_rec (p_x_prd_workoper_rec.workorder_id);
  FETCH get_workorder_rec
  INTO  l_job_route_id,
        l_job_wip_entity_id,
        l_job_organization_id,
        l_job_scheduled_start_date,
        l_job_scheduled_end_date,
        l_job_actual_start_date,
        l_job_actual_end_date;
  CLOSE get_workorder_rec;

  IF ( ( p_x_prd_workoper_rec.wip_entity_id IS NULL OR
         p_x_prd_workoper_rec.wip_entity_id = FND_API.G_MISS_NUM ) AND
       l_job_wip_entity_id IS NOT NULL ) THEN
    p_x_prd_workoper_rec.wip_entity_id := l_job_wip_entity_id;
  END IF;

  IF ( p_x_prd_workoper_rec.organization_id IS NULL OR
       p_x_prd_workoper_rec.organization_id = FND_API.G_MISS_NUM ) THEN
    p_x_prd_workoper_rec.organization_id := l_job_organization_id;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( 'Job Route ID :'||l_job_route_id );
    AHL_DEBUG_PUB.debug( 'Operation Code :'|| p_x_prd_workoper_rec.operation_code );
    AHL_DEBUG_PUB.debug( 'Operation ID :'|| p_x_prd_workoper_rec.operation_id );
  END IF;

  IF ( l_job_route_id IS NULL AND
       p_x_prd_workoper_rec.operation_id IS NULL ) THEN
    l_qa_inspection_type:=fnd_profile.value('AHL_NR_WO_OP_PLAN_TYPE');

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'Defaulting QA Inspection Type for Operation from Profile' );
    END IF;

  END IF;

  IF l_qa_inspection_type IS NOT NULL THEN
    AHL_QA_RESULTS_PVT.get_qa_plan
    (
      p_api_version           => 1.0,
      p_init_msg_list         => FND_API.G_FALSE,
      p_commit                => FND_API.G_FALSE,
      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
      p_default               => FND_API.G_FALSE,
      p_module_type           => NULL,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_organization_id       => p_x_prd_workoper_rec.organization_id,
      p_transaction_number    => 2002,
      p_col_trigger_value     => l_qa_inspection_type,
      x_plan_id               => p_x_prd_workoper_rec.plan_id
    );
  END IF;

  IF ( p_x_prd_workoper_rec.scheduled_start_date IS NOT NULL AND
       p_x_prd_workoper_rec.scheduled_start_date <> FND_API.G_MISS_DATE AND
       l_job_scheduled_start_date IS NOT NULL AND
       TRUNC( p_x_prd_workoper_rec.scheduled_start_date ) = TRUNC( l_job_scheduled_start_date ) ) THEN
    p_x_prd_workoper_rec.scheduled_start_date := l_job_scheduled_start_date;
    IF ( p_x_prd_workoper_rec.scheduled_start_hr IS NULL OR
         p_x_prd_workoper_rec.scheduled_start_hr = FND_API.G_MISS_NUM)
    THEN
    	p_x_prd_workoper_rec.scheduled_start_hr := TO_NUMBER( TO_CHAR( l_job_scheduled_start_date, 'HH24' ) );
    END IF;

    IF( p_x_prd_workoper_rec.scheduled_start_mi IS NULL OR
        p_x_prd_workoper_rec.scheduled_start_mi = FND_API.G_MISS_NUM)
    THEN
    	p_x_prd_workoper_rec.scheduled_start_mi := TO_NUMBER( TO_CHAR( l_job_scheduled_start_date, 'MI' ) );
    END IF;
  END IF;

  IF ( p_x_prd_workoper_rec.scheduled_end_date IS NOT NULL AND
       p_x_prd_workoper_rec.scheduled_end_date <> FND_API.G_MISS_DATE AND
       l_job_scheduled_end_date IS NOT NULL AND
       TRUNC( p_x_prd_workoper_rec.scheduled_end_date ) = TRUNC( l_job_scheduled_end_date ) ) THEN
    p_x_prd_workoper_rec.scheduled_end_date := l_job_scheduled_end_date;
    IF ( p_x_prd_workoper_rec.scheduled_end_hr IS NULL OR
         p_x_prd_workoper_rec.scheduled_end_hr = FND_API.G_MISS_NUM)
    THEN
    	p_x_prd_workoper_rec.scheduled_end_hr := TO_NUMBER( TO_CHAR( l_job_scheduled_end_date, 'HH24' ) );
    END IF;

    IF ( p_x_prd_workoper_rec.scheduled_end_mi IS NULL OR
         p_x_prd_workoper_rec.scheduled_end_mi = FND_API.G_MISS_NUM)
    THEN
    	p_x_prd_workoper_rec.scheduled_end_mi := TO_NUMBER( TO_CHAR( l_job_scheduled_end_date, 'MI' ) );
    END IF;
  ELSIF ( p_x_prd_workoper_rec.scheduled_end_date IS NOT NULL AND
          p_x_prd_workoper_rec.scheduled_end_date <> FND_API.G_MISS_DATE AND
          l_job_scheduled_start_date IS NOT NULL AND
          TRUNC( p_x_prd_workoper_rec.scheduled_end_date ) = TRUNC( l_job_scheduled_start_date ) ) THEN
    p_x_prd_workoper_rec.scheduled_end_date := l_job_scheduled_start_date;
    IF ( p_x_prd_workoper_rec.scheduled_end_hr IS NULL OR
         p_x_prd_workoper_rec.scheduled_end_hr = FND_API.G_MISS_NUM)
    THEN
    	p_x_prd_workoper_rec.scheduled_end_hr := TO_NUMBER( TO_CHAR( l_job_scheduled_start_date, 'HH24' ) );
    END IF;

    IF ( p_x_prd_workoper_rec.scheduled_end_mi IS NULL OR
         p_x_prd_workoper_rec.scheduled_end_mi = FND_API.G_MISS_NUM)
    THEN
    	p_x_prd_workoper_rec.scheduled_end_mi := TO_NUMBER( TO_CHAR( l_job_scheduled_start_date, 'MI' ) );
    END IF;
  END IF;

  IF ( p_x_prd_workoper_rec.actual_start_date IS NOT NULL AND
       p_x_prd_workoper_rec.actual_start_date <> FND_API.G_MISS_DATE AND
       l_job_actual_start_date IS NOT NULL AND
       TRUNC( p_x_prd_workoper_rec.actual_start_date ) = TRUNC( l_job_actual_start_date ) ) THEN
    p_x_prd_workoper_rec.actual_start_date := l_job_actual_start_date;
    p_x_prd_workoper_rec.actual_start_hr := TO_NUMBER( TO_CHAR( l_job_actual_start_date, 'HH24' ) );
    p_x_prd_workoper_rec.actual_start_mi := TO_NUMBER( TO_CHAR( l_job_actual_start_date, 'MI' ) );
  END IF;

  IF ( p_x_prd_workoper_rec.actual_end_date IS NOT NULL AND
       p_x_prd_workoper_rec.actual_end_date <> FND_API.G_MISS_DATE AND
       l_job_actual_end_date IS NOT NULL AND
       TRUNC( p_x_prd_workoper_rec.actual_end_date ) = TRUNC( l_job_actual_end_date ) ) THEN
    p_x_prd_workoper_rec.actual_end_date := l_job_actual_end_date;
    p_x_prd_workoper_rec.actual_end_hr := TO_NUMBER( TO_CHAR( l_job_actual_end_date, 'HH24' ) );
    p_x_prd_workoper_rec.actual_end_mi := TO_NUMBER( TO_CHAR( l_job_scheduled_end_date, 'MI' ) );
  ELSIF ( p_x_prd_workoper_rec.actual_end_date IS NOT NULL AND
          p_x_prd_workoper_rec.actual_end_date <> FND_API.G_MISS_DATE AND
          l_job_actual_start_date IS NOT NULL AND
          TRUNC( p_x_prd_workoper_rec.actual_end_date ) = TRUNC( l_job_actual_start_date ) ) THEN
    p_x_prd_workoper_rec.actual_end_date := l_job_actual_start_date;
    p_x_prd_workoper_rec.actual_end_hr := TO_NUMBER( TO_CHAR( l_job_actual_start_date, 'HH24' ) );
    p_x_prd_workoper_rec.actual_end_mi := TO_NUMBER( TO_CHAR( l_job_actual_start_date, 'MI' ) );
  END IF;

END default_attributes;

PROCEDURE default_missing_attributes
(
  p_x_prd_workoper_rec  IN OUT NOCOPY AHL_PRD_OPERATIONS_PVT.PRD_workoperation_rec,
  p_module_type                  IN      VARCHAR2
)
AS
cursor get_operation_rec(c_operation_id NUMBER)
is
SELECT *
FROM   AHL_WORKORDER_OPERATIONS_V
WHERE  workorder_operation_id=c_operation_id;

l_old_operation_rec       get_operation_rec%ROWTYPE;

BEGIN
  OPEN  get_operation_rec(p_x_prd_workoper_rec.WORKORDER_OPERATION_ID);
  FETCH get_operation_rec INTO l_old_operation_rec;
  CLOSE get_operation_rec;
  IF(p_module_type IS NULL OR p_module_type NOT IN ('OAF','JSP'))THEN
    IF p_x_prd_workoper_rec.SCHEDULED_START_DATE=FND_API.G_MISS_DATE THEN
      p_x_prd_workoper_rec.SCHEDULED_START_DATE:=NULL;
    ELSIF p_x_prd_workoper_rec.SCHEDULED_START_DATE IS NULL THEN
      p_x_prd_workoper_rec.SCHEDULED_START_DATE:=l_old_operation_rec.SCHEDULED_START_DATE;
    END IF;
    IF p_x_prd_workoper_rec.SCHEDULED_START_HR=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.SCHEDULED_START_HR:=NULL;
    ELSIF p_x_prd_workoper_rec.SCHEDULED_START_HR IS NULL THEN
      p_x_prd_workoper_rec.SCHEDULED_START_HR:=l_old_operation_rec.SCHEDULED_START_HR;
    END IF;

    IF p_x_prd_workoper_rec.SCHEDULED_START_MI=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.SCHEDULED_START_MI:=NULL;
    ELSIF p_x_prd_workoper_rec.SCHEDULED_START_MI IS NULL THEN
      p_x_prd_workoper_rec.SCHEDULED_START_MI:=l_old_operation_rec.SCHEDULED_START_MI;
    END IF;

    IF p_x_prd_workoper_rec.SCHEDULED_END_DATE=FND_API.G_MISS_DATE THEN
      p_x_prd_workoper_rec.SCHEDULED_END_DATE:=NULL;
    ELSIF p_x_prd_workoper_rec.SCHEDULED_END_DATE IS NULL THEN
      p_x_prd_workoper_rec.SCHEDULED_END_DATE:=l_old_operation_rec.SCHEDULED_END_DATE;
    END IF;

    IF p_x_prd_workoper_rec.SCHEDULED_END_HR=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.SCHEDULED_END_HR:=NULL;
    ELSIF p_x_prd_workoper_rec.SCHEDULED_END_HR IS NULL THEN
      p_x_prd_workoper_rec.SCHEDULED_END_HR:=l_old_operation_rec.SCHEDULED_END_HR;
    END IF;

    IF p_x_prd_workoper_rec.SCHEDULED_END_MI=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.SCHEDULED_END_MI:=NULL;
    ELSIF p_x_prd_workoper_rec.SCHEDULED_END_MI IS NULL THEN
      p_x_prd_workoper_rec.SCHEDULED_END_MI:=l_old_operation_rec.SCHEDULED_END_MI;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_START_DATE=FND_API.G_MISS_DATE THEN
      p_x_prd_workoper_rec.ACTUAL_START_DATE:=NULL;
    ELSIF p_x_prd_workoper_rec.ACTUAL_START_DATE IS NULL THEN
      p_x_prd_workoper_rec.ACTUAL_START_DATE:=l_old_operation_rec.ACTUAL_START_DATE;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_START_HR=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.ACTUAL_START_HR:=NULL;
    ELSIF p_x_prd_workoper_rec.ACTUAL_START_HR IS NULL THEN
      p_x_prd_workoper_rec.ACTUAL_START_HR:=l_old_operation_rec.ACTUAL_START_HR;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_START_MI=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.ACTUAL_START_MI:=NULL;
    ELSIF p_x_prd_workoper_rec.ACTUAL_START_MI IS NULL THEN
      p_x_prd_workoper_rec.ACTUAL_START_MI:=l_old_operation_rec.ACTUAL_START_MI;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_END_DATE=FND_API.G_MISS_DATE THEN
      p_x_prd_workoper_rec.ACTUAL_END_DATE:=NULL;
    ELSIF p_x_prd_workoper_rec.ACTUAL_END_DATE IS NULL THEN
      p_x_prd_workoper_rec.ACTUAL_END_DATE:=l_old_operation_rec.ACTUAL_END_DATE;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_END_HR=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.ACTUAL_END_HR:=NULL;
    ELSIF p_x_prd_workoper_rec.ACTUAL_END_HR IS NULL THEN
      p_x_prd_workoper_rec.ACTUAL_END_HR:=l_old_operation_rec.ACTUAL_END_HR;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_END_MI=FND_API.G_MISS_NUM THEN
      p_x_prd_workoper_rec.ACTUAL_END_MI:=NULL;
    ELSIF p_x_prd_workoper_rec.ACTUAL_END_MI IS NULL THEN
      p_x_prd_workoper_rec.ACTUAL_END_MI:=l_old_operation_rec.ACTUAL_END_MI;
    END IF;
  ELSIF p_module_type = 'JSP' THEN
    IF p_x_prd_workoper_rec.SCHEDULED_START_DATE IS NOT NULL THEN
      IF p_x_prd_workoper_rec.SCHEDULED_START_HR=FND_API.G_MISS_NUM THEN
        p_x_prd_workoper_rec.SCHEDULED_START_HR:=NULL;
      ELSIF p_x_prd_workoper_rec.SCHEDULED_START_HR IS NULL THEN
        p_x_prd_workoper_rec.SCHEDULED_START_HR:=l_old_operation_rec.SCHEDULED_START_HR;
      END IF;
      IF p_x_prd_workoper_rec.SCHEDULED_START_MI=FND_API.G_MISS_NUM THEN
         p_x_prd_workoper_rec.SCHEDULED_START_MI:=NULL;
      ELSIF p_x_prd_workoper_rec.SCHEDULED_START_MI IS NULL THEN
         p_x_prd_workoper_rec.SCHEDULED_START_MI:=l_old_operation_rec.SCHEDULED_START_MI;
      END IF;
    END IF;

    IF p_x_prd_workoper_rec.SCHEDULED_END_DATE IS NOT NULL THEN
      IF p_x_prd_workoper_rec.SCHEDULED_END_HR=FND_API.G_MISS_NUM THEN
        p_x_prd_workoper_rec.SCHEDULED_END_HR:=NULL;
      ELSIF p_x_prd_workoper_rec.SCHEDULED_END_HR IS NULL THEN
        p_x_prd_workoper_rec.SCHEDULED_END_HR:=l_old_operation_rec.SCHEDULED_END_HR;
      END IF;
      IF p_x_prd_workoper_rec.SCHEDULED_END_MI=FND_API.G_MISS_NUM THEN
        p_x_prd_workoper_rec.SCHEDULED_END_MI:=NULL;
      ELSIF p_x_prd_workoper_rec.SCHEDULED_END_MI IS NULL THEN
        p_x_prd_workoper_rec.SCHEDULED_END_MI:=l_old_operation_rec.SCHEDULED_END_MI;
      END IF;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_START_DATE IS NOT NULL THEN
      IF p_x_prd_workoper_rec.ACTUAL_START_HR=FND_API.G_MISS_NUM THEN
        p_x_prd_workoper_rec.ACTUAL_START_HR:=NULL;
      ELSIF p_x_prd_workoper_rec.ACTUAL_START_HR IS NULL THEN
        p_x_prd_workoper_rec.ACTUAL_START_HR:=l_old_operation_rec.ACTUAL_START_HR;
      END IF;

      IF p_x_prd_workoper_rec.ACTUAL_START_MI=FND_API.G_MISS_NUM THEN
         p_x_prd_workoper_rec.ACTUAL_START_MI:=NULL;
      ELSIF p_x_prd_workoper_rec.ACTUAL_START_MI IS NULL THEN
         p_x_prd_workoper_rec.ACTUAL_START_MI:=l_old_operation_rec.ACTUAL_START_MI;
      END IF;
    END IF;

    IF p_x_prd_workoper_rec.ACTUAL_END_DATE IS NOT NULL THEN
      IF p_x_prd_workoper_rec.ACTUAL_END_HR=FND_API.G_MISS_NUM THEN
        p_x_prd_workoper_rec.ACTUAL_END_HR:=NULL;
      ELSIF p_x_prd_workoper_rec.ACTUAL_END_HR IS NULL THEN
        p_x_prd_workoper_rec.ACTUAL_END_HR:=l_old_operation_rec.ACTUAL_END_HR;
      END IF;
      IF p_x_prd_workoper_rec.ACTUAL_END_MI=FND_API.G_MISS_NUM THEN
        p_x_prd_workoper_rec.ACTUAL_END_MI:=NULL;
      ELSIF p_x_prd_workoper_rec.ACTUAL_END_MI IS NULL THEN
        p_x_prd_workoper_rec.ACTUAL_END_MI:=l_old_operation_rec.ACTUAL_END_MI;
      END IF;
    END IF;
  END IF;

   IF p_x_prd_workoper_rec.DEPARTMENT_ID= FND_API.G_MISS_NUM THEN
     p_x_prd_workoper_rec.DEPARTMENT_ID:=NULL;
   ELSIF p_x_prd_workoper_rec.DEPARTMENT_ID IS NULL THEN
     p_x_prd_workoper_rec.DEPARTMENT_ID:=l_old_operation_rec.DEPARTMENT_ID;
   END IF;

   IF p_x_prd_workoper_rec.DEPARTMENT_NAME= FND_API.G_MISS_CHAR THEN
      p_x_prd_workoper_rec.DEPARTMENT_NAME:=NULL;
   ELSIF p_x_prd_workoper_rec.DEPARTMENT_NAME IS NULL THEN
      p_x_prd_workoper_rec.DEPARTMENT_NAME:=l_old_operation_rec.DEPARTMENT_NAME;
   END IF;

  IF p_x_prd_workoper_rec.STATUS_CODE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.STATUS_CODE:=NULL;
   ELSIF p_x_prd_workoper_rec.STATUS_CODE IS NULL THEN
    p_x_prd_workoper_rec.STATUS_CODE:=l_old_operation_rec.STATUS_CODE;
   END IF;

  IF p_x_prd_workoper_rec.STATUS_MEANING= FND_API.G_MISS_CHAR THEN
     p_x_prd_workoper_rec.STATUS_MEANING:=NULL;
  ELSIF p_x_prd_workoper_rec.STATUS_MEANING IS NULL THEN
    p_x_prd_workoper_rec.STATUS_MEANING:=l_old_operation_rec.STATUS;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.OPERATION_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.OPERATION_ID IS NULL THEN
    p_x_prd_workoper_rec.OPERATION_ID:=l_old_operation_rec.OPERATION_ID;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_CODE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.OPERATION_CODE:=NULL;
  ELSIF p_x_prd_workoper_rec.OPERATION_CODE IS NULL THEN
    p_x_prd_workoper_rec.OPERATION_CODE:=l_old_operation_rec.OPERATION_CODE;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_TYPE_CODE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.OPERATION_TYPE_CODE:=NULL;
  ELSIF p_x_prd_workoper_rec.OPERATION_TYPE_CODE IS NULL THEN
    p_x_prd_workoper_rec.OPERATION_TYPE_CODE:=l_old_operation_rec.OPERATION_TYPE_CODE;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_TYPE= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.OPERATION_TYPE:=NULL;
  ELSIF p_x_prd_workoper_rec.OPERATION_TYPE IS NULL THEN
    p_x_prd_workoper_rec.OPERATION_TYPE:=l_old_operation_rec.OPERATION_TYPE;
  END IF;

  IF p_x_prd_workoper_rec.PLAN_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.PLAN_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.PLAN_ID IS NULL THEN
    p_x_prd_workoper_rec.PLAN_ID:=l_old_operation_rec.PLAN_ID;
  END IF;

  IF p_x_prd_workoper_rec.COLLECTION_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.COLLECTION_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.COLLECTION_ID IS NULL THEN
    p_x_prd_workoper_rec.COLLECTION_ID:=l_old_operation_rec.COLLECTION_ID;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_DESCRIPTION= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.OPERATION_DESCRIPTION:=NULL;
  ELSIF p_x_prd_workoper_rec.OPERATION_DESCRIPTION IS NULL THEN
    p_x_prd_workoper_rec.OPERATION_DESCRIPTION:=l_old_operation_rec.DESCRIPTION;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE_CATEGORY:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE_CATEGORY IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE_CATEGORY:=l_old_operation_rec.ATTRIBUTE_CATEGORY;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE1= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE1:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE1 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE1:=l_old_operation_rec.ATTRIBUTE1;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE2= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE2:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE2 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE2:=l_old_operation_rec.ATTRIBUTE2;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE3= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE3:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE3 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE3:=l_old_operation_rec.ATTRIBUTE3;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE4= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE4:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE4 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE4:=l_old_operation_rec.ATTRIBUTE4;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE5= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE5:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE5 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE5:=l_old_operation_rec.ATTRIBUTE5;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE6= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE6:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE6 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE6:=l_old_operation_rec.ATTRIBUTE6;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE7= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE7:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE7 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE7:=l_old_operation_rec.ATTRIBUTE7;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE8= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE8:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE8 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE8:=l_old_operation_rec.ATTRIBUTE8;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE9= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE9:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE9 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE9:=l_old_operation_rec.ATTRIBUTE9;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE10= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE10:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE10 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE10:=l_old_operation_rec.ATTRIBUTE10;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE11= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE11:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE11 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE11:=l_old_operation_rec.ATTRIBUTE11;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE12= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE12:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE12 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE12:=l_old_operation_rec.ATTRIBUTE12;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE13= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE13:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE13 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE13:=l_old_operation_rec.ATTRIBUTE13;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE14= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE14:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE14 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE14:=l_old_operation_rec.ATTRIBUTE14;
  END IF;

  IF p_x_prd_workoper_rec.ATTRIBUTE15= FND_API.G_MISS_CHAR THEN
    p_x_prd_workoper_rec.ATTRIBUTE15:=NULL;
  ELSIF p_x_prd_workoper_rec.ATTRIBUTE15 IS NULL THEN
    p_x_prd_workoper_rec.ATTRIBUTE15:=l_old_operation_rec.ATTRIBUTE15;
  END IF;

  IF p_x_prd_workoper_rec.WORKORDER_OPERATION_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.WORKORDER_OPERATION_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.WORKORDER_OPERATION_ID IS NULL THEN
    p_x_prd_workoper_rec.WORKORDER_OPERATION_ID:=l_old_operation_rec.WORKORDER_OPERATION_ID;
  END IF;

  IF p_x_prd_workoper_rec.ORGANIZATION_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.ORGANIZATION_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.ORGANIZATION_ID IS NULL THEN
    p_x_prd_workoper_rec.ORGANIZATION_ID:=l_old_operation_rec.ORGANIZATION_ID;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_SEQUENCE_NUM= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.OPERATION_SEQUENCE_NUM:=NULL;
  ELSIF p_x_prd_workoper_rec.OPERATION_SEQUENCE_NUM IS NULL THEN
    p_x_prd_workoper_rec.OPERATION_SEQUENCE_NUM:=l_old_operation_rec.OPERATION_SEQUENCE_NUM;
  END IF;

  IF p_x_prd_workoper_rec.WORKORDER_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.WORKORDER_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.WORKORDER_ID IS NULL THEN
    p_x_prd_workoper_rec.WORKORDER_ID:=l_old_operation_rec.WORKORDER_ID;
  END IF;

  IF p_x_prd_workoper_rec.WIP_ENTITY_ID= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.WIP_ENTITY_ID:=NULL;
  ELSIF p_x_prd_workoper_rec.WIP_ENTITY_ID IS NULL THEN
    p_x_prd_workoper_rec.WIP_ENTITY_ID:=l_old_operation_rec.WIP_ENTITY_ID;
  END IF;

  IF p_x_prd_workoper_rec.OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.OBJECT_VERSION_NUMBER:=NULL;
  ELSIF p_x_prd_workoper_rec.OBJECT_VERSION_NUMBER IS NULL THEN
    p_x_prd_workoper_rec.OBJECT_VERSION_NUMBER:=l_old_operation_rec.OBJECT_VERSION_NUMBER;
  END IF;

  IF p_x_prd_workoper_rec.LAST_UPDATE_DATE=FND_API.G_MISS_DATE THEN
    p_x_prd_workoper_rec.LAST_UPDATE_DATE:=NULL;
  ELSIF p_x_prd_workoper_rec.LAST_UPDATE_DATE IS NULL THEN
    p_x_prd_workoper_rec.LAST_UPDATE_DATE:=l_old_operation_rec.LAST_UPDATE_DATE;
  END IF;

  IF p_x_prd_workoper_rec.LAST_UPDATED_BY= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.LAST_UPDATED_BY:=NULL;
  ELSIF p_x_prd_workoper_rec.LAST_UPDATED_BY IS NULL THEN
    p_x_prd_workoper_rec.LAST_UPDATED_BY:=l_old_operation_rec.LAST_UPDATED_BY;
  END IF;

  IF p_x_prd_workoper_rec.CREATION_DATE=FND_API.G_MISS_DATE THEN
    p_x_prd_workoper_rec.CREATION_DATE:=NULL;
  ELSIF p_x_prd_workoper_rec.CREATION_DATE IS NULL THEN
    p_x_prd_workoper_rec.CREATION_DATE:=l_old_operation_rec.CREATION_DATE;
  END IF;

  IF p_x_prd_workoper_rec.CREATED_BY= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.CREATED_BY:=NULL;
  ELSIF p_x_prd_workoper_rec.CREATED_BY IS NULL THEN
    p_x_prd_workoper_rec.CREATED_BY:=l_old_operation_rec.CREATED_BY;
  END IF;

  IF p_x_prd_workoper_rec.LAST_UPDATE_LOGIN= FND_API.G_MISS_NUM THEN
    p_x_prd_workoper_rec.LAST_UPDATE_LOGIN:=NULL;
  ELSIF p_x_prd_workoper_rec.LAST_UPDATE_LOGIN IS NULL THEN
    p_x_prd_workoper_rec.LAST_UPDATE_LOGIN:=l_old_operation_rec.LAST_UPDATE_LOGIN;
  END IF;


END default_missing_attributes;

FUNCTION is_valid_operation_update(
                      	p_operation_id   IN 	NUMBER,
                      	p_wo_op_id       IN     NUMBER,
                      	p_operation_code IN 	VARCHAR2,
                      	p_dml_operation  IN 	VARCHAR2
)
RETURN NUMBER
IS

---- declare cursors here----
-- cursor for getting operation code of existing work order operation
CURSOR c_get_wo_op(p_wo_op_id IN NUMBER)
IS
SELECT
   rop.concatenated_segments
FROM
   AHL_WORKORDER_OPERATIONS wop,
   AHL_OPERATIONS_B_KFV rop
WHERE
       rop.operation_id = wop.operation_id
   AND wop.workorder_operation_id = p_wo_op_id;

-- cursor for getting latest revision of the operation
CURSOR get_operation(c_operation_code VARCHAR2)
IS
SELECT OP.operation_id
FROM   AHL_OPERATIONS_B_KFV OP
WHERE  OP.concatenated_segments=c_operation_code
AND    OP.revision_number IN
         ( SELECT MAX(OP1.revision_number)
           FROM   AHL_OPERATIONS_B_KFV OP1
           WHERE  OP1.concatenated_segments=OP.concatenated_segments
           AND    TRUNC(SYSDATE) BETWEEN TRUNC(OP1.start_date_active) AND
                                         TRUNC(NVL(OP1.end_date_active,SYSDATE+1))
           AND    OP1.revision_status_code='COMPLETE'
         );

---- declare local variables here----
l_existing_op_code     VARCHAR2(154);
l_operation_id         NUMBER;

BEGIN

   -- dump all the inputs

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_OPERATIONS_PVT.is_valid_operation_update',
			'p_operation_id : ' || p_operation_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_OPERATIONS_PVT.is_valid_operation_update',
			'p_wo_op_id : ' || p_wo_op_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_OPERATIONS_PVT.is_valid_operation_update',
			'p_operation_code : ' || p_operation_code
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_OPERATIONS_PVT.is_valid_operation_update',
			'p_dml_operation : ' || p_dml_operation
		);
   END IF;


   l_operation_id := p_operation_id;

   -- create case
   IF (
        p_dml_operation = 'C'
        AND
        p_operation_code IS NOT NULL
      )
   THEN

      OPEN get_operation(p_operation_code);
      FETCH get_operation INTO l_operation_id;
      CLOSE get_operation;

   -- update case
   ELSIF (
          p_dml_operation = 'U'
          --AND p_operation_id IS NULL
          AND
          p_operation_code IS NOT NULL
          AND
          p_operation_code <> FND_API.G_MISS_CHAR
         )
   THEN
                OPEN c_get_wo_op(p_wo_op_id);
         	FETCH c_get_wo_op INTO l_existing_op_code;
         	CLOSE c_get_wo_op;

         	IF nvl(l_existing_op_code, '-1') <> p_operation_code
         	THEN

		      OPEN get_operation(p_operation_code);
		      FETCH get_operation INTO l_operation_id;
		      CLOSE get_operation;

         	END IF;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_OPERATIONS_PVT.is_valid_operation_update',
			'Operation id returned -> l_operation_id : ' || l_operation_id
		);
   END IF;

   RETURN l_operation_id;

END is_valid_operation_update;
PROCEDURE convert_values_to_ids
(
  p_x_prd_workoper_rec IN OUT NOCOPY AHL_PRD_OPERATIONS_PVT.prd_workoperation_rec,
  p_module_type IN VARCHAR2
)
As

CURSOR get_operation(c_operation_code VARCHAR2)
IS
SELECT operation_id
FROM   AHL_OPERATIONS_B_KFV
WHERE  concatenated_segments=c_operation_code
AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
                      AND  TRUNC(NVL(end_date_active,SYSDATE+1))
AND    revision_status_code='COMPLETE';

CURSOR get_department(c_department_name VARCHAR2,c_org_id NUMBER)
IS
SELECT A.Department_id,
       A.department_code,
       A.description
FROM   BOM_DEPARTMENTS A
WHERE  UPPER(A.description) LIKE UPPER(c_department_name)
AND    A.organization_id=c_org_id;

l_dept_rec              get_department%ROWTYPE;

CURSOR get_operation_type(c_operation_type VARCHAR2)
IS
SELECT lookup_code
FROM   FND_LOOKUP_VALUES_VL
WHERE  lookup_type='AHL_OPERATION_TYPE'
AND    UPPER(meaning)=UPPER(c_operation_type)
AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
                      AND TRUNC(NVL(end_date_active,SYSDATE+1));

CURSOR get_completion_sub_inv(c_com_subinv VARCHAR2,c_inventory_item_id NUMBER)
IS
SELECT a.Secondary_inventory
FROM   MTL_ITEM_SUB_INVENTORIES a,
       MTL_PARAMETERS b
WHERE  a.Secondary_inventory=c_com_subinv
AND    a.organization_id=b.organization_id
AND    a.inventory_item_id=c_inventory_item_id;

-- Balaji added for Release NR error
CURSOR get_op_sch_sec(c_wip_entity_id IN NUMBER, c_op_seq_no IN NUMBER)
IS
SELECT
   TO_CHAR(FIRST_UNIT_START_DATE, 'ss') schedule_start_sec,
   TO_CHAR(LAST_UNIT_COMPLETION_DATE, 'ss') schedule_end_sec
FROM
   WIP_OPERATIONS
WHERE
   WIP_ENTITY_ID = c_wip_entity_id AND
   OPERATION_SEQ_NUM = c_op_seq_no;

-- Balaji added for Release NR error
CURSOR get_op_act_sec(c_wo_op_id IN NUMBER)
IS
SELECT
   TO_CHAR(ACTUAL_START_DATE, 'ss') actual_start_sec,
   TO_CHAR(ACTUAL_END_DATE, 'ss') actual_end_sec
FROM
   AHL_WORKORDER_OPERATIONS
WHERE
   workorder_operation_id = c_wo_op_id;

l_compl_subinv_rec      get_completion_sub_inv%ROWTYPE;

l_ctr                   NUMBER:=0;
--l_hour                  VARCHAR2(30);
l_sec                   VARCHAR2(30);
--l_minutes               VARCHAR2(30);
--l_date_time             VARCHAR2(30);
l_sch_start_sec         VARCHAR2(30);
l_sch_end_sec           VARCHAR2(30);
l_act_start_sec         VARCHAR2(30);
l_act_end_sec           VARCHAR2(30);
l_operation_id          NUMBER;

BEGIN
  /*
  -- Bug # 6717357 -- start
  IF p_x_prd_workoper_rec.OPERATION_CODE IS NOT NULL AND
     p_x_prd_workoper_rec.OPERATION_CODE<>FND_API.G_MISS_CHAR THEN
    OPEN  get_operation(p_x_prd_workoper_rec.OPERATION_CODE);
    FETCH get_operation INTO p_x_prd_workoper_rec.OPERATION_ID;

    IF    get_operation%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPERATION_CODE_INVALID');
      FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_workoper_rec.operation_sequence_num,false);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE get_operation;
  END IF;
  -- Bug # 6717357 -- end
  */

  -- Added following code for Bug # 6717357 -- start
  -- Operation code need to be converted to id in following cases
  -- 1. DML operation is CREATE
  -- 2. DML operation is UPDATE and Operation code is updated.
  l_operation_id := is_valid_operation_update(
                      	p_operation_id 		=>	p_x_prd_workoper_rec.operation_id,
                      	p_wo_op_id		=>	p_x_prd_workoper_rec.workorder_operation_id,
                      	p_operation_code	=>	p_x_prd_workoper_rec.operation_code,
                      	p_dml_operation 	=>	p_x_prd_workoper_rec.dml_operation
  		      );

  IF p_x_prd_workoper_rec.operation_code IS NOT NULL AND
     l_operation_id IS NULL
  THEN
     FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPERATION_CODE_INVALID');
     FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_workoper_rec.operation_sequence_num,false);
     FND_MSG_PUB.ADD;
  ELSE
     p_x_prd_workoper_rec.OPERATION_ID := l_operation_id;
  END IF;
  -- Added following code for Bug # 6717357 -- End
  IF p_x_prd_workoper_rec.department_name IS NOT NULL AND
     p_x_prd_workoper_rec.department_name<>FND_API.G_MISS_CHAR THEN
    OPEN  get_department(p_x_prd_workoper_rec.department_name,p_x_prd_workoper_rec.organization_id);
    FETCH get_department  INTO l_dept_rec;

    IF    get_department%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPT_NAME_INVALID');
      FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_workoper_rec.department_name,false);
      FND_MESSAGE.SET_TOKEN('RECORD',p_x_prd_workoper_rec.operation_sequence_num,false);
      FND_MSG_PUB.ADD;
    ELSIF   get_department%FOUND THEN
      p_x_prd_workoper_rec.department_id:=l_dept_rec.department_id;
    END IF;
    CLOSE get_department;
  END IF;

  IF p_x_prd_workoper_rec.OPERATION_TYPE IS NOT NULL AND
     p_x_prd_workoper_rec.OPERATION_TYPE<>FND_API.G_MISS_CHAR THEN
    OPEN  get_operation_type(p_x_prd_workoper_rec.OPERATION_TYPE);
    FETCH get_operation_type  INTO p_x_prd_workoper_rec.OPERATION_TYPE_CODE;

    IF    get_operation_type%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPERATION_TYPE_INVALID');
      FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_workoper_rec.OPERATION_TYPE,false);
      FND_MESSAGE.SET_TOKEN('RECORD',p_x_prd_workoper_rec.operation_sequence_num,false);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE get_operation_type;
  END IF;

  OPEN get_op_sch_sec(p_x_prd_workoper_rec.wip_entity_id, p_x_prd_workoper_rec.operation_sequence_num);
  FETCH get_op_sch_sec INTO l_sch_start_sec, l_sch_end_sec;
  CLOSE get_op_sch_sec;

  IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workoper_rec.SCHEDULED_START_DATE : ' || to_char(p_x_prd_workoper_rec.SCHEDULED_START_DATE,'DD-MON-YY hh24:mi:ss') );
  END IF;

  IF p_x_prd_workoper_rec.SCHEDULED_START_DATE IS NOT NULL AND
     p_x_prd_workoper_rec.SCHEDULED_START_DATE <> FND_API.G_MISS_DATE THEN

    l_sec := TO_CHAR(p_x_prd_workoper_rec.SCHEDULED_START_DATE, 'ss');
    IF(l_sec = '00' AND p_module_type <> 'OAF' ) THEN
       l_sec := l_sch_start_sec;
    END IF;
    p_x_prd_workoper_rec.SCHEDULED_START_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workoper_rec.SCHEDULED_START_DATE,
                                   p_date_hh24 => p_x_prd_workoper_rec.SCHEDULED_START_HR,
                                   p_date_mi => p_x_prd_workoper_rec.SCHEDULED_START_MI,
                                   p_date_ss => l_sec);
     IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workoper_rec.SCHEDULED_START_DATE : ' || to_char(p_x_prd_workoper_rec.SCHEDULED_START_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;
  END IF;

  IF p_x_prd_workoper_rec.SCHEDULED_END_DATE IS NOT NULL AND
     p_x_prd_workoper_rec.SCHEDULED_END_DATE <> FND_API.G_MISS_DATE THEN

    l_sec := TO_CHAR(p_x_prd_workoper_rec.SCHEDULED_END_DATE, 'ss');
    IF(l_sec = '00' AND p_module_type <> 'OAF' ) THEN
       l_sec := l_sch_end_sec;
    END IF;
    p_x_prd_workoper_rec.SCHEDULED_END_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workoper_rec.SCHEDULED_END_DATE,
                                   p_date_hh24 => p_x_prd_workoper_rec.SCHEDULED_END_HR,
                                   p_date_mi => p_x_prd_workoper_rec.SCHEDULED_END_MI,
                                   p_date_ss => l_sec);
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workoper_rec.SCHEDULED_END_DATE : ' || to_char(p_x_prd_workoper_rec.SCHEDULED_END_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;
  END IF;

  -- Balaji added for Release NR error
  OPEN get_op_act_sec(p_x_prd_workoper_rec.workorder_operation_id);
  FETCH get_op_act_sec INTO l_act_start_sec, l_act_end_sec;
  CLOSE get_op_act_sec;

  IF p_x_prd_workoper_rec.ACTUAL_START_DATE IS NOT NULL AND
     p_x_prd_workoper_rec.ACTUAL_START_DATE <> FND_API.G_MISS_DATE THEN

    l_sec := TO_CHAR(p_x_prd_workoper_rec.ACTUAL_START_DATE, 'ss');
    IF(l_sec = '00' AND p_module_type <> 'OAF' ) THEN
       l_sec := l_act_start_sec;
    END IF;
    p_x_prd_workoper_rec.ACTUAL_START_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workoper_rec.ACTUAL_START_DATE,
                                   p_date_hh24 => p_x_prd_workoper_rec.ACTUAL_START_HR,
                                   p_date_mi => p_x_prd_workoper_rec.ACTUAL_START_MI,
                                   p_date_ss => l_sec);
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workoper_rec.ACTUAL_START_DATE : ' || to_char(p_x_prd_workoper_rec.ACTUAL_START_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;
  END IF;

  IF p_x_prd_workoper_rec.ACTUAL_END_DATE IS NOT NULL AND
     p_x_prd_workoper_rec.ACTUAL_END_DATE <> FND_API.G_MISS_DATE THEN

    l_sec := TO_CHAR(p_x_prd_workoper_rec.ACTUAL_END_DATE, 'ss');
    IF(l_sec = '00' AND p_module_type <> 'OAF' ) THEN
       l_sec := l_act_end_sec;
    END IF;
    p_x_prd_workoper_rec.ACTUAL_END_DATE :=
                  get_date_and_time
                                  (p_date => p_x_prd_workoper_rec.ACTUAL_END_DATE,
                                   p_date_hh24 => p_x_prd_workoper_rec.ACTUAL_END_HR,
                                   p_date_mi => p_x_prd_workoper_rec.ACTUAL_END_MI,
                                   p_date_ss => l_sec);
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( 'p_x_prd_workoper_rec.ACTUAL_END_DATE : ' || to_char(p_x_prd_workoper_rec.ACTUAL_END_DATE,'DD-MON-YY hh24:mi:ss') );
     END IF;
  END IF;

END convert_values_to_ids;

PROCEDURE validate_operation
(
  p_prd_workoper_rec    IN AHL_PRD_OPERATIONS_PVT.PRD_workoperation_rec
)
AS
CURSOR  validate_unique_operation(c_workorder_id NUMBER,c_operation_seq_num NUMBER)
IS
SELECT  'X'
FROM    AHL_WORKORDER_OPERATIONS
WHERE   workorder_id            =c_workorder_id
AND     operation_sequence_num  =c_operation_seq_num;

l_unique_rec VARCHAR2(1);

CURSOR validate_department(c_dept_id NUMBER,c_org_id NUMBER)
IS
SELECT B.eam_enabled_flag
FROM   BOM_DEPARTMENTS A,
       MTL_PARAMETERS B
WHERE  A.department_id=c_dept_id
AND    A.organization_id=B.organization_id
AND    A.organization_id=c_org_id;

CURSOR get_wo_status(c_wo_id NUMBER)
IS
SELECT AWOS.status_code,
							FNDL.meaning
FROM AHL_WORKORDERS AWOS,
					FND_LOOKUP_VALUES_VL FNDL
WHERE AWOS.workorder_id = c_wo_id
AND FNDL.LOOKUP_CODE(+) = AWOS.STATUS_CODE
AND FNDL.LOOKUP_TYPE(+) = 'AHL_JOB_STATUS';
-- Cursor added by Balaji for actual dates check issue with operation.
CURSOR get_wo_actual_dates(c_wo_id NUMBER)
IS
SELECT
  ACTUAL_START_DATE,
  ACTUAL_END_DATE
FROM
  AHL_WORKORDERS
WHERE
  WORKORDER_ID = c_wo_id;
l_eam_enabled_flag      VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_wo_status_code								VARCHAR2(80);
l_wo_status													VARCHAR2(30);
l_wo_actual_start_date  DATE;
l_wo_actual_end_date    DATE;

-- fix for bug# 7555681
CURSOR  get_curr_operation_status(c_workorder_id NUMBER,c_operation_seq_num NUMBER)
IS
SELECT  status_code
FROM    AHL_WORKORDER_OPERATIONS
WHERE   workorder_id            =c_workorder_id
AND     operation_sequence_num  =c_operation_seq_num;

l_curr_op_status VARCHAR2(1);

BEGIN
  IF p_prd_workoper_rec.dml_operation='U' THEN
				OPEN get_wo_status(p_prd_workoper_rec.workorder_id);
				FETCH get_wo_status INTO l_wo_status_code, l_wo_status;
				CLOSE get_wo_status;

				IF l_wo_status_code IN ('4', '5', '7', '12') THEN
				  FND_MESSAGE.SET_NAME('AHL','AHL_PRD_UPDOP_WOSTS');
						FND_MESSAGE.SET_TOKEN('WO_STS', l_wo_status);
      FND_MSG_PUB.ADD;
    END IF;

    -- fix for bug# 7555681
    /*IF p_prd_workoper_rec.status_code = '1' THEN
				-- Bug 4393092
				-- Cannot update an operation which is in status 'Complete'
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_UPDOP_STS_COMP');
						FND_MESSAGE.SET_TOKEN('OP_SEQ', p_prd_workoper_rec.OPERATION_SEQUENCE_NUM);
      FND_MSG_PUB.ADD;
    END IF;*/
    IF (l_wo_status_code = '1' AND p_prd_workoper_rec.status_code = '1') THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_PRD_UPDOP_WOSTS');
                FND_MESSAGE.SET_TOKEN('WO_STS', l_wo_status);
                FND_MSG_PUB.ADD;
    ELSE
                 OPEN get_curr_operation_status(p_prd_workoper_rec.workorder_id,p_prd_workoper_rec.operation_sequence_num);
                 FETCH get_curr_operation_status INTO l_curr_op_status;
                 IF(l_curr_op_status = '1')THEN

                   -- Bug 4393092
                   -- Cannot update an operation which is in status 'Complete'
                   FND_MESSAGE.SET_NAME('AHL','AHL_PRD_UPDOP_STS_COMP');
                   FND_MESSAGE.SET_TOKEN('OP_SEQ', p_prd_workoper_rec.OPERATION_SEQUENCE_NUM);
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_curr_operation_status;
    END IF;
  END IF;

		-- rroy
		-- ACL Changes
		/*l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_prd_workoper_rec.workorder_id,																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);
 	IF l_return_status = FND_API.G_TRUE THEN
				IF p_prd_workoper_rec.dml_operation='C' THEN
			 		FND_MESSAGE.Set_Name('AHL', 'AHL_PP_OP_CRT_UNTLCKD');
				ELSIF p_prd_workoper_rec.dml_operation='U' THEN
			 		FND_MESSAGE.Set_Name('AHL', 'AHL_PP_OP_UPD_UNTLCKD');
				END IF;
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
		END IF;
		*/
		-- rroy
		-- ACL Changes

  IF p_prd_workoper_rec.DEPARTMENT_ID IS NULL OR
     p_prd_workoper_rec.DEPARTMENT_ID=FND_API.G_MISS_NUM THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPT_ID_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_prd_workoper_rec.SCHEDULED_START_DATE IS NULL OR
     p_prd_workoper_rec.SCHEDULED_START_DATE=FND_API.G_MISS_DATE THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_SCHEDSTART_DT_NULL');
    FND_MSG_PUB.ADD;
  ELSIF p_prd_workoper_rec.SCHEDULED_END_DATE IS NULL OR
        p_prd_workoper_rec.SCHEDULED_END_DATE=FND_API.G_MISS_DATE THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_SCHEDEND_DT_NULL');
    FND_MSG_PUB.ADD;
  ELSIF NVL(p_prd_workoper_rec.SCHEDULED_START_DATE,SYSDATE) > NVL(p_prd_workoper_rec.SCHEDULED_END_DATE,SYSDATE) THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_SCHEDDTS_INVALID_DT');
    FND_MSG_PUB.ADD;
  END IF;

   IF p_prd_workoper_rec.ACTUAL_START_DATE IS NOT NULL AND
      p_prd_workoper_rec.ACTUAL_START_DATE <> FND_API.G_MISS_DATE AND
      p_prd_workoper_rec.ACTUAL_START_DATE  > SYSDATE THEN
     FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_ACT_STRT_DT_INVALID');
     FND_MSG_PUB.ADD;
   END IF;

  IF (p_prd_workoper_rec.ACTUAL_START_DATE  IS NULL OR
      p_prd_workoper_rec.ACTUAL_START_DATE=FND_API.G_MISS_DATE) AND
     (p_prd_workoper_rec.ACTUAL_END_DATE<>FND_API.G_MISS_DATE AND
      p_prd_workoper_rec.ACTUAL_END_DATE IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_ACT_START_DT_NULL');
    FND_MESSAGE.SET_TOKEN('RECORD',p_prd_workoper_rec.operation_sequence_num,false);
    FND_MSG_PUB.ADD;
  END IF;

  IF  p_prd_workoper_rec.ACTUAL_START_DATE IS NOT NULL AND
      p_prd_workoper_rec.ACTUAL_START_DATE<>FND_API.G_MISS_DATE AND
      p_prd_workoper_rec.ACTUAL_END_DATE<>FND_API.G_MISS_DATE AND
      p_prd_workoper_rec.ACTUAL_END_DATE IS NOT NULL AND
      p_prd_workoper_rec.ACTUAL_START_DATE > p_prd_workoper_rec.ACTUAL_END_DATE THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_ACT_SE_DT_INVALID');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_prd_workoper_rec.ACTUAL_END_DATE IS NOT NULL AND
     p_prd_workoper_rec.ACTUAL_END_DATE <> FND_API.G_MISS_DATE AND
     TRUNC( p_prd_workoper_rec.ACTUAL_END_DATE ) > TRUNC( SYSDATE ) THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OP_ACT_END_DT_INVALID');
    FND_MSG_PUB.ADD;
  END IF;

  -- Balaji added actual date validation against workorder actual dates.
  OPEN get_wo_actual_dates(p_prd_workoper_rec.workorder_id);
  FETCH get_wo_actual_dates INTO l_wo_actual_start_date, l_wo_actual_end_date;
  CLOSE get_wo_actual_dates;

  IF ( p_prd_workoper_rec.actual_start_date IS NOT NULL AND
       p_prd_workoper_rec.actual_start_date <> FND_API.G_MISS_DATE AND
       l_wo_actual_start_date IS NOT NULL AND
       p_prd_workoper_rec.actual_start_date < l_wo_actual_start_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_WO_ST_DT' );
    FND_MSG_PUB.add;
  END IF;

  IF ( p_prd_workoper_rec.actual_end_date IS NOT NULL AND
       p_prd_workoper_rec.actual_end_date <> FND_API.G_MISS_DATE AND
       l_wo_actual_end_date IS NOT NULL AND
       p_prd_workoper_rec.actual_end_date > l_wo_actual_end_date ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_OP_WO_END_DT' );
    FND_MSG_PUB.add;
  END IF;

  IF  p_prd_workoper_rec.OPERATION_SEQUENCE_NUM IS NULL OR
      p_prd_workoper_rec.OPERATION_SEQUENCE_NUM=FND_API.G_MISS_NUM THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPERATION_SEQ_NULL');
    FND_MSG_PUB.ADD;
  ELSIF p_prd_workoper_rec.OPERATION_SEQUENCE_NUM <=0 THEN
    FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPERATION_SEQ_NEGZERO');
    FND_MSG_PUB.ADD;
  ELSE
    IF  p_prd_workoper_rec.dml_operation='C' THEN
      OPEN  validate_unique_operation(p_prd_workoper_rec.workorder_id,p_prd_workoper_rec.operation_sequence_num);
      FETCH validate_unique_operation INTO l_unique_rec;
      IF validate_unique_operation%FOUND THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_PRD_OPER_SEQ_NOTUNIQ');
        FND_MESSAGE.SET_TOKEN('RECORD',p_prd_workoper_rec.operation_sequence_num,false);
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE validate_unique_operation;
    END IF;
  END IF;

  IF p_prd_workoper_rec.dml_operation='U' THEN
    IF p_prd_workoper_rec.WORKORDER_OPERATION_ID IS NULL OR
       p_prd_workoper_rec.WORKORDER_OPERATION_ID=FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_WO_OPERID_NULL');
      FND_MSG_PUB.ADD;
    END IF;
  END IF;

  IF p_prd_workoper_rec.ORGANIZATION_ID IS NOT NULL AND
     p_prd_workoper_rec.ORGANIZATION_ID<>FND_API.G_MISS_NUM AND
     p_prd_workoper_rec.DEPARTMENT_ID IS NOT NULL AND
     p_prd_workoper_rec.DEPARTMENT_ID<>FND_API.G_MISS_NUM THEN
    OPEN  validate_department(p_prd_workoper_rec.DEPARTMENT_ID,p_prd_workoper_rec.ORGANIZATION_ID);
    FETCH validate_department INTO l_eam_enabled_flag;

    IF    validate_department%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPT_NAME_INVALID');
      FND_MSG_PUB.ADD;
    ELSIF    validate_department%FOUND  AND l_eam_enabled_flag='N' THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_PRD_DEPT_NOT_EAM_ENABLED');
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE validate_department;
  END IF;

END validate_operation;

PROCEDURE process_operations
(
 p_api_version                  IN      NUMBER    := 1.0,
 p_init_msg_list                IN      VARCHAR2  := FND_API.G_TRUE,
 p_commit                       IN      VARCHAR2  := FND_API.G_FALSE,
 p_validation_level             IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN      VARCHAR2  := FND_API.G_FALSE,
 p_module_type                  IN      VARCHAR2,
 p_wip_mass_load_flag           IN      VARCHAR2,
 x_return_status                OUT NOCOPY      VARCHAR2,
 x_msg_count                    OUT NOCOPY      NUMBER,
 x_msg_data                     OUT NOCOPY      VARCHAR2,
 p_x_prd_operation_tbl          IN OUT NOCOPY   PRD_OPERATION_TBL
)
AS

  l_api_name     CONSTANT VARCHAR2(30) := 'process_operations';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);

  l_empty_workorder_rec   AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
  l_resource_tbl          AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type;
  l_material_tbl          AHL_PP_MATERIALS_PVT.req_material_tbl_type;
  l_op_status             VARCHAR2(30);
  l_prd_operation_tbl     PRD_OPERATION_TBL;
  idx                     NUMBER;

  --cursor to retrieve the Operation Status Code
  CURSOR get_op_status(x_workorder_operation_id NUMBER)
  IS
  SELECT STATUS_CODE
  FROM AHL_WORKORDER_OPERATIONS
  WHERE WORKORDER_OPERATION_ID = x_workorder_operation_id;

BEGIN
  SAVEPOINT process_operations_PVT;

  --   Initialize message list IF p_init_msg_list is set to TRUE.
  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Total number of Operations - ' || p_x_prd_operation_tbl.COUNT );
  END IF;

  IF FND_API.to_boolean(p_default) THEN
    IF p_x_prd_operation_tbl.COUNT >0 THEN
      FOR i in p_x_prd_operation_tbl.FIRST..p_x_prd_operation_tbl.LAST
      LOOP

        IF p_x_prd_operation_tbl(i).DML_OPERATION='C' THEN
          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( l_api_name || ' - Before default_attributes' );
          END IF;

          default_attributes
          (
            p_x_prd_workoper_rec       => p_x_prd_operation_tbl(i)
          );

        ELSIF p_x_prd_operation_tbl(i).DML_OPERATION='U' THEN
          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( l_api_name || ' - Before default_missing_attributes' );
          END IF;

          default_missing_attributes
          (
            p_x_prd_workoper_rec    => p_x_prd_operation_tbl(i),
            p_module_type           => p_module_type
          );
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF p_module_type='JSP' OR p_module_type = 'OAF' THEN
    IF p_x_prd_operation_tbl.COUNT >0 THEN
      FOR i in p_x_prd_operation_tbl.FIRST..p_x_prd_operation_tbl.LAST
      LOOP
        IF ( G_DEBUG = 'Y' ) THEN
          AHL_DEBUG_PUB.debug( l_api_name || ' - Before convert_values_to_ids' );
        END IF;

        convert_values_to_ids
        (
          p_x_prd_workoper_rec    =>p_x_prd_operation_tbl(i),
          p_module_type           => p_module_type
        );
      END LOOP;
    END IF;
  END IF;

  l_msg_count:=FND_MSG_PUB.count_msg;

  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_wip_mass_load_flag<>'Y' THEN
      RETURN;
    END IF;
  END IF;

  idx := 1;

  IF p_x_prd_operation_tbl.COUNT >0 THEN
    FOR i IN p_x_prd_operation_tbl.FIRST..p_x_prd_operation_tbl.LAST
    LOOP
      x_return_status:=FND_API.G_RET_STS_SUCCESS;

      IF ( G_DEBUG = 'Y' ) THEN
        AHL_DEBUG_PUB.debug( l_api_name || ' - Before validate_operation' );
      END IF;

      validate_operation
      (
        p_prd_workoper_rec    =>p_x_prd_operation_tbl(i)
      );

      l_msg_count:=FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF x_return_status=FND_API.G_RET_STS_SUCCESS THEN

        IF p_x_prd_operation_tbl(i).dml_operation='C' THEN

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( l_api_name || ' - Before Inserting into AHL_WORKORDER_OPERATIONS' );
          END IF;

          INSERT INTO AHL_WORKORDER_OPERATIONS
          (
            WORKORDER_OPERATION_ID,
            OBJECT_VERSION_NUMBER ,
            LAST_UPDATE_DATE      ,
            LAST_UPDATED_BY       ,
            CREATION_DATE         ,
            CREATED_BY            ,
            LAST_UPDATE_LOGIN     ,
            OPERATION_SEQUENCE_NUM,
            WORKORDER_ID          ,
            STATUS_CODE           ,
            OPERATION_ID          ,
            PLAN_ID               ,
            COLLECTION_ID         ,
            OPERATION_TYPE_CODE   ,
            ACTUAL_START_DATE     ,
            ACTUAL_END_DATE       ,
            ATTRIBUTE_CATEGORY    ,
            ATTRIBUTE1            ,
            ATTRIBUTE2            ,
            ATTRIBUTE3            ,
            ATTRIBUTE4            ,
            ATTRIBUTE5            ,
            ATTRIBUTE6            ,
            ATTRIBUTE7            ,
            ATTRIBUTE8            ,
            ATTRIBUTE9            ,
            ATTRIBUTE10           ,
            ATTRIBUTE11           ,
            ATTRIBUTE12           ,
            ATTRIBUTE13           ,
            ATTRIBUTE14           ,
            ATTRIBUTE15
          ) VALUES
          (
            p_x_prd_operation_tbl(I).WORKORDER_OPERATION_ID,
            p_x_prd_operation_tbl(I).OBJECT_VERSION_NUMBER ,
            p_x_prd_operation_tbl(I).LAST_UPDATE_DATE      ,
            p_x_prd_operation_tbl(I).LAST_UPDATED_BY       ,
            p_x_prd_operation_tbl(I).CREATION_DATE         ,
            p_x_prd_operation_tbl(I).CREATED_BY            ,
            p_x_prd_operation_tbl(I).LAST_UPDATE_LOGIN     ,
            p_x_prd_operation_tbl(I).OPERATION_SEQUENCE_NUM,
            p_x_prd_operation_tbl(I).WORKORDER_ID          ,
            NVL(p_x_prd_operation_tbl(I).STATUS_CODE,'2'),
            p_x_prd_operation_tbl(I).OPERATION_ID          ,
            p_x_prd_operation_tbl(I).PLAN_ID               ,
            p_x_prd_operation_tbl(I).COLLECTION_ID         ,
            p_x_prd_operation_tbl(I).OPERATION_TYPE_CODE   ,
            p_x_prd_operation_tbl(I).ACTUAL_START_DATE     ,
            p_x_prd_operation_tbl(I).ACTUAL_END_DATE       ,
            p_x_prd_operation_tbl(I).ATTRIBUTE_CATEGORY    ,
            p_x_prd_operation_tbl(I).ATTRIBUTE1            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE2            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE3            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE4            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE5            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE6            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE7            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE8            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE9            ,
            p_x_prd_operation_tbl(I).ATTRIBUTE10           ,
            p_x_prd_operation_tbl(I).ATTRIBUTE11           ,
            p_x_prd_operation_tbl(I).ATTRIBUTE12           ,
            p_x_prd_operation_tbl(I).ATTRIBUTE13           ,
            p_x_prd_operation_tbl(I).ATTRIBUTE14           ,
            p_x_prd_operation_tbl(I).ATTRIBUTE15
          );
        ELSIF p_x_prd_operation_tbl(I).DML_OPERATION='U' THEN

          IF ( G_DEBUG = 'Y' ) THEN
            AHL_DEBUG_PUB.debug( l_api_name || ' - Before Updating AHL_WORKORDER_OPERATIONS' );
          END IF;

	  -- R12
	  -- Tech UIs
          OPEN get_op_status(p_x_prd_operation_tbl(I).WORKORDER_OPERATION_ID);
          FETCH get_op_status INTO l_op_status;
          CLOSE get_op_status;

	  IF p_x_prd_operation_tbl(I).status_code = '1' AND l_op_status <> '1' THEN
            -- If this is an operation completion
            l_prd_operation_tbl(idx).workorder_operation_id := p_x_prd_operation_tbl(i).workorder_operation_id;
            l_prd_operation_tbl(idx).object_version_number := p_x_prd_operation_tbl(i).object_version_number + 1;
            p_x_prd_operation_tbl(i).status_code := l_op_status;
            idx  := idx + 1;
          END IF;

          UPDATE AHL_WORKORDER_OPERATIONS SET
            OBJECT_VERSION_NUMBER   =p_x_prd_operation_tbl(I).OBJECT_VERSION_NUMBER +1,
            LAST_UPDATE_DATE        =NVL(p_x_prd_operation_tbl(I).LAST_UPDATE_DATE,SYSDATE),
            LAST_UPDATED_BY         =NVL(p_x_prd_operation_tbl(I).LAST_UPDATED_BY,FND_GLOBAL.user_id),
            OPERATION_SEQUENCE_NUM  =p_x_prd_operation_tbl(I).OPERATION_SEQUENCE_NUM,
            WORKORDER_ID            =p_x_prd_operation_tbl(I).WORKORDER_ID          ,
            STATUS_CODE             =p_x_prd_operation_tbl(I).STATUS_CODE          ,
            OPERATION_ID            =p_x_prd_operation_tbl(I).OPERATION_ID          ,
            PLAN_ID                 =p_x_prd_operation_tbl(I).PLAN_ID               ,
            COLLECTION_ID           =p_x_prd_operation_tbl(I).COLLECTION_ID         ,
            OPERATION_TYPE_CODE     =p_x_prd_operation_tbl(I).OPERATION_TYPE_CODE   ,
            ACTUAL_START_DATE       =p_x_prd_operation_tbl(I).ACTUAL_START_DATE     ,
            ACTUAL_END_DATE         =p_x_prd_operation_tbl(I).ACTUAL_END_DATE       ,
            ATTRIBUTE_CATEGORY      =p_x_prd_operation_tbl(I).ATTRIBUTE_CATEGORY    ,
            ATTRIBUTE1              =p_x_prd_operation_tbl(I).ATTRIBUTE1            ,
            ATTRIBUTE2              =p_x_prd_operation_tbl(I).ATTRIBUTE2            ,
            ATTRIBUTE3              =p_x_prd_operation_tbl(I).ATTRIBUTE3            ,
            ATTRIBUTE4              =p_x_prd_operation_tbl(I).ATTRIBUTE4            ,
            ATTRIBUTE5              =p_x_prd_operation_tbl(I).ATTRIBUTE5            ,
            ATTRIBUTE6              =p_x_prd_operation_tbl(I).ATTRIBUTE6            ,
            ATTRIBUTE7              =p_x_prd_operation_tbl(I).ATTRIBUTE7            ,
            ATTRIBUTE8              =p_x_prd_operation_tbl(I).ATTRIBUTE8            ,
            ATTRIBUTE9              =p_x_prd_operation_tbl(I).ATTRIBUTE9            ,
            ATTRIBUTE10             =p_x_prd_operation_tbl(I).ATTRIBUTE10           ,
            ATTRIBUTE11             =p_x_prd_operation_tbl(I).ATTRIBUTE11           ,
            ATTRIBUTE12             =p_x_prd_operation_tbl(I).ATTRIBUTE12           ,
            ATTRIBUTE13             =p_x_prd_operation_tbl(I).ATTRIBUTE13           ,
            ATTRIBUTE14             =p_x_prd_operation_tbl(I).ATTRIBUTE14           ,
            ATTRIBUTE15             =p_x_prd_operation_tbl(I).ATTRIBUTE15
          WHERE  WORKORDER_OPERATION_ID=p_x_prd_operation_tbl(I).WORKORDER_OPERATION_ID
          AND    OBJECT_VERSION_NUMBER =p_x_prd_operation_tbl(I).OBJECT_VERSION_NUMBER;

          p_x_prd_operation_tbl(i).OBJECT_VERSION_NUMBER := p_x_prd_operation_tbl(i).OBJECT_VERSION_NUMBER + 1;

        END IF;
      END IF;
    END LOOP;
  END IF;

  l_msg_count:=FND_MSG_PUB.count_msg;

  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF p_wip_mass_load_flag='Y' THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RETURN;
    END IF;

  END IF;

  IF  p_wip_mass_load_flag='Y' THEN

    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.debug( l_api_name || ' - Before AHL_EAM_JOB_PVT.update_job_operations' );
    END IF;

    AHL_EAM_JOB_PVT.update_job_operations
    (
      p_api_version            => 1.0                        ,
      p_init_msg_list          => FND_API.G_TRUE             ,
      p_commit                 => FND_API.G_FALSE            ,
      p_validation_level       => FND_API.G_VALID_LEVEL_FULL ,
      p_default                => FND_API.G_TRUE             ,
      p_module_type            => NULL                       ,
      x_return_status          => l_return_status            ,
      x_msg_count              => l_msg_count                ,
      x_msg_data               => l_msg_data                 ,
      p_workorder_rec          => l_empty_workorder_rec      ,
      p_operation_tbl          => p_x_prd_operation_tbl      ,
      p_material_req_tbl       => l_material_tbl             ,
      p_resource_req_tbl       => l_resource_tbl
    );

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- IF  p_wip_mass_load_flag='Y' THEN

  -- R12
  -- Tech UIs
  -- Check if operations need to be completed.
  IF l_prd_operation_tbl.COUNT > 0 THEN
    FOR j in l_prd_operation_tbl.FIRST..l_prd_operation_tbl.LAST LOOP
      AHL_COMPLETIONS_PVT.complete_operation
      (p_api_version  => 1.0,
       p_init_msg_list => FND_API.G_TRUE,
       p_commit => FND_API.G_FALSE,
       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
       p_default => FND_API.G_FALSE,
       x_return_status => l_return_status,
       x_msg_count => l_msg_count,
       x_msg_data => l_msg_data,
       p_workorder_operation_id => l_prd_operation_tbl(j).workorder_operation_id,
       p_object_version_no => l_prd_operation_tbl(j).object_version_number
      );
      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF; -- IF l_prd_operation_tbl.COUNT > 0 THEN


  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT;
  END IF;

  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.debug( l_api_name || ' - Success' );
  END IF;

  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_operations_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_operations_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN OTHERS THEN
    ROLLBACK TO process_operations_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>g_pkg_name,
                              p_procedure_name  =>l_api_name,
                              p_error_text      => SUBSTR(SQLERRM,1,240));

    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

END;

FUNCTION get_date_and_time(p_date IN DATE,
                           p_date_hh24 IN VARCHAR2,
                           p_date_mi IN VARCHAR2,
                           p_date_ss IN VARCHAR2) RETURN DATE IS

l_hour                  VARCHAR2(30);
l_sec                   VARCHAR2(30);
l_minutes               VARCHAR2(30);
l_date_time             VARCHAR2(30);
l_date                  DATE;

BEGIN

    l_sec := TO_CHAR(p_date, 'ss');
    l_hour := TO_CHAR(p_date, 'hh24');
    l_minutes := TO_CHAR(p_date, 'mi');
    l_date := p_date;

    IF ( p_date_hh24 IS NOT NULL AND
         p_date_hh24 <> FND_API.G_MISS_NUM ) THEN
      l_hour := p_date_hh24;
    END IF;

    IF ( p_date_mi IS NOT NULL AND
         p_date_mi <> FND_API.G_MISS_NUM ) THEN
      l_minutes := p_date_mi;
    END IF;

    IF(p_date_ss IS NOT NULL AND
       p_date_ss <> FND_API.G_MISS_NUM) THEN
       l_sec := p_date_ss;
    END IF;

    IF ( l_hour <> '00' OR l_minutes <> '00' OR l_sec <> '00') THEN
      l_date_time := TO_CHAR(p_date, 'DD-MM-YYYY')||' :'|| l_hour ||':'|| l_minutes || ':'|| l_sec;
      l_date := TO_DATE(l_date_time , 'DD-MM-YYYY :HH24:MI:ss');
    END IF;
    RETURN l_date;
END get_date_and_time;

END  AHL_PRD_OPERATIONS_PVT;


/
