--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ELEMENT_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ELEMENT_SCH_PKG" AS
/* $Header: PATSKT3B.pls 120.1 2005/08/19 17:06:05 mwasowic noship $ */

PROCEDURE Insert_Row(
X_ROW_ID                  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
X_PEV_SCHEDULE_ID 	  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
X_ELEMENT_VERSION_ID	      NUMBER,
X_PROJECT_ID	            NUMBER,
X_PROJ_ELEMENT_ID	            NUMBER,
X_SCHEDULED_START_DATE	      DATE,
X_SCHEDULED_FINISH_DATE	      DATE,
X_OBLIGATION_START_DATE	      DATE,
X_OBLIGATION_FINISH_DATE	DATE,
X_ACTUAL_START_DATE	      DATE,
X_ACTUAL_FINISH_DATE	      DATE,
X_ESTIMATED_START_DATE	      DATE,
X_ESTIMATED_FINISH_DATE	      DATE,
X_DURATION	                  NUMBER,
X_EARLY_START_DATE	      DATE,
X_EARLY_FINISH_DATE	      DATE,
X_LATE_START_DATE	            DATE,
X_LATE_FINISH_DATE	      DATE,
X_CALENDAR_ID	            NUMBER,
X_MILESTONE_FLAG	            VARCHAR2,
X_CRITICAL_FLAG	            VARCHAR2,
X_WQ_PLANNED_QUANTITY       NUMBER,
X_PLANNED_EFFORT            NUMBER,
X_ACTUAL_DURATION           NUMBER,
X_ESTIMATED_DURATION        NUMBER,
--bug 3305199 schedule options
X_def_sch_tool_tsk_type_code  IN VARCHAR2 := NULL,
X_constraint_type_code        IN VARCHAR2 := NULL,
X_constraint_date             IN DATE := NULL,
X_free_slack                  IN NUMBER := NULL,
X_total_slack                 IN NUMBER := NULL,
X_effort_driven_flag          IN VARCHAR2 := 'N',
X_level_assignments_flag      IN VARCHAR2 := 'N',
--end bug 3305199
X_ext_act_duration            IN NUMBER := NULL,
X_ext_remain_duration         IN NUMBER := NULL,
X_ext_sch_duration            IN NUMBER := NULL,
x_source_object_id       IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,       --Bug No 3594635 SMukka
x_source_object_type     IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,    --Bug No 3594635 SMukka
X_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE       := NULL,
X_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE               := NULL,
X_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE               := NULL,
X_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE               := NULL,
X_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE               := NULL,
X_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE               := NULL,
X_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE               := NULL,
X_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE               := NULL,
X_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE               := NULL,
X_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE               := NULL,
X_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE              := NULL,
X_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE              := NULL,
X_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE              := NULL,
X_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE              := NULL,
X_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE              := NULL,
X_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE              := NULL
) IS
   CURSOR cur_elem_ver_sch
   IS
     SELECT pa_proj_elem_ver_schedule_s.nextval
       FROM sys.dual;
BEGIN
     IF  X_PEV_SCHEDULE_ID IS NULL
     THEN
         OPEN cur_elem_ver_sch;
         FETCH cur_elem_ver_sch INTO X_PEV_SCHEDULE_ID;
         CLOSE cur_elem_ver_sch;
     END IF;
     INSERT INTO pa_proj_elem_ver_schedule(
                            PEV_SCHEDULE_ID
                           ,ELEMENT_VERSION_ID
                           ,PROJECT_ID
                           ,PROJ_ELEMENT_ID
                           ,SCHEDULED_START_DATE
                           ,SCHEDULED_FINISH_DATE
                           ,OBLIGATION_START_DATE
                           ,OBLIGATION_FINISH_DATE
                           ,ACTUAL_START_DATE
                           ,ACTUAL_FINISH_DATE
                           ,ESTIMATED_START_DATE
                           ,ESTIMATED_FINISH_DATE
                           ,DURATION
                           ,EARLY_START_DATE
                           ,EARLY_FINISH_DATE
                           ,LATE_START_DATE
                           ,LATE_FINISH_DATE
                           ,CALENDAR_ID
                           ,MILESTONE_FLAG
                           ,CRITICAL_FLAG
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,LAST_UPDATE_LOGIN
                           ,RECORD_VERSION_NUMBER
                           ,WQ_PLANNED_QUANTITY
                           ,PLANNED_EFFORT
                           ,ACTUAL_DURATION
                           ,ESTIMATED_DURATION
                           ,attribute_category
                           ,attribute1
                           ,attribute2
                           ,attribute3
                           ,attribute4
                           ,attribute5
                           ,attribute6
                           ,attribute7
                           ,attribute8
                           ,attribute9
                           ,attribute10
                           ,attribute11
                           ,attribute12
                           ,attribute13
                           ,attribute14
                           ,attribute15
                           ,DEF_SCH_TOOL_TSK_TYPE_CODE
                           ,CONSTRAINT_TYPE_CODE
                           ,CONSTRAINT_DATE
                           ,FREE_SLACK
                           ,TOTAL_SLACK
                           ,EFFORT_DRIVEN_FLAG
                           ,LEVEL_ASSIGNMENTS_FLAG
                           ,ext_act_duration
                           ,ext_remain_duration
                           ,ext_sch_duration
                           ,source_object_id              --Bug No 3594635 SMukka
                           ,source_object_type            --Bug No 3594635 SMukka
                       )
                VALUES (
                            X_PEV_SCHEDULE_ID
                           ,X_ELEMENT_VERSION_ID
                           ,X_PROJECT_ID
                           ,X_PROJ_ELEMENT_ID
                           ,X_SCHEDULED_START_DATE
                           ,X_SCHEDULED_FINISH_DATE
                           ,X_OBLIGATION_START_DATE
                           ,X_OBLIGATION_FINISH_DATE
                           ,X_ACTUAL_START_DATE
                           ,X_ACTUAL_FINISH_DATE
                           ,X_ESTIMATED_START_DATE
                           ,X_ESTIMATED_FINISH_DATE
                           ,X_DURATION
                           ,X_EARLY_START_DATE
                           ,X_EARLY_FINISH_DATE
                           ,X_LATE_START_DATE
                           ,X_LATE_FINISH_DATE
                           ,X_CALENDAR_ID
                           ,X_MILESTONE_FLAG
                           ,X_CRITICAL_FLAG
                           ,SYSDATE              --CREATION_DATE
                           ,FND_GLOBAL.USER_ID   --CREATED_BY
                           ,SYSDATE              --LAST_UPDATE_DATE
                           ,FND_GLOBAL.USER_ID   --LAST_UPDATED_BY
                           ,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN
                           ,1                    --RECORD_VERSION_NUMBER
                           ,X_WQ_PLANNED_QUANTITY
                           ,X_PLANNED_EFFORT
                           ,X_ACTUAL_DURATION
                           ,X_ESTIMATED_DURATION
                           ,X_attribute_category
                           ,X_attribute1
                           ,X_attribute2
                           ,X_attribute3
                           ,X_attribute4
                           ,X_attribute5
                           ,X_attribute6
                           ,X_attribute7
                           ,X_attribute8
                           ,X_attribute9
                           ,X_attribute10
                           ,X_attribute11
                           ,X_attribute12
                           ,X_attribute13
                           ,X_attribute14
                           ,X_attribute15
                           ,X_def_sch_tool_tsk_type_code
                           ,X_constraint_type_code
                           ,X_constraint_date
                           ,X_free_slack
                           ,X_total_slack
                           ,X_effort_driven_flag
                           ,X_level_assignments_flag
                           ,X_ext_act_duration
                           ,X_ext_remain_duration
                           ,X_ext_sch_duration
                           ,x_source_object_id        --Bug No 3594635 SMukka
                           ,x_source_object_type      --Bug No 3594635 SMukka
                      );

END INsert_Row;

PROCEDURE Update_Row(
X_ROW_ID                  IN  VARCHAR2,
X_PEV_SCHEDULE_ID 	      NUMBER,
X_ELEMENT_VERSION_ID	      NUMBER,
X_PROJECT_ID	            NUMBER,
X_PROJ_ELEMENT_ID	            NUMBER,
X_SCHEDULED_START_DATE	      DATE,
X_SCHEDULED_FINISH_DATE	      DATE,
X_OBLIGATION_START_DATE	      DATE,
X_OBLIGATION_FINISH_DATE	DATE,
X_ACTUAL_START_DATE	      DATE,
X_ACTUAL_FINISH_DATE	      DATE,
X_ESTIMATED_START_DATE	      DATE,
X_ESTIMATED_FINISH_DATE	      DATE,
X_DURATION	                  NUMBER,
X_EARLY_START_DATE	      DATE,
X_EARLY_FINISH_DATE	      DATE,
X_LATE_START_DATE	            DATE,
X_LATE_FINISH_DATE	      DATE,
X_CALENDAR_ID	            NUMBER,
X_MILESTONE_FLAG	            VARCHAR2,
X_CRITICAL_FLAG	            VARCHAR2,
X_WQ_PLANNED_QUANTITY       NUMBER,
X_PLANNED_EFFORT            NUMBER,
X_ACTUAL_DURATION           NUMBER,
X_ESTIMATED_DURATION        NUMBER,
--bug 3305199 schedule options
X_def_sch_tool_tsk_type_code  IN VARCHAR2 := NULL,
X_constraint_type_code        IN VARCHAR2 := NULL,
X_constraint_date             IN DATE := NULL,
X_free_slack                  IN NUMBER := NULL,
X_total_slack                 IN NUMBER := NULL,
X_effort_driven_flag          IN VARCHAR2 := 'N',
X_level_assignments_flag      IN VARCHAR2 := 'N',
--end bug 3305199
X_RECORD_VERSION_NUMBER	      NUMBER,
X_ext_act_duration            IN NUMBER := NULL,
X_ext_remain_duration         IN NUMBER := NULL,
X_ext_sch_duration            IN NUMBER := NULL,
X_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE       := NULL,
X_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE               := NULL,
X_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE               := NULL,
X_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE               := NULL,
X_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE               := NULL,
X_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE               := NULL,
X_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE               := NULL,
X_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE               := NULL,
X_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE               := NULL,
X_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE               := NULL,
X_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE              := NULL,
X_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE              := NULL,
X_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE              := NULL,
X_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE              := NULL,
X_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE              := NULL,
X_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE              := NULL
) IS
BEGIN
     UPDATE pa_proj_elem_ver_schedule
         SET                PEV_SCHEDULE_ID	             = X_PEV_SCHEDULE_ID
                           ,ELEMENT_VERSION_ID	             = X_ELEMENT_VERSION_ID
                           ,PROJECT_ID	                   = X_PROJECT_ID
                           ,PROJ_ELEMENT_ID		       = X_PROJ_ELEMENT_ID
                           ,SCHEDULED_START_DATE	       = X_SCHEDULED_START_DATE
                           ,SCHEDULED_FINISH_DATE	       = X_SCHEDULED_FINISH_DATE
                           ,OBLIGATION_START_DATE	       = X_OBLIGATION_START_DATE
                           ,OBLIGATION_FINISH_DATE	       = X_OBLIGATION_FINISH_DATE
                           ,ACTUAL_START_DATE	             = X_ACTUAL_START_DATE
                           ,ACTUAL_FINISH_DATE	             = X_ACTUAL_FINISH_DATE
                           ,ESTIMATED_START_DATE	       = X_ESTIMATED_START_DATE
                           ,ESTIMATED_FINISH_DATE	       = X_ESTIMATED_FINISH_DATE
                           ,DURATION	                   = X_DURATION
                           ,EARLY_START_DATE	             = X_EARLY_START_DATE
                           ,EARLY_FINISH_DATE	             = X_EARLY_FINISH_DATE
                           ,LATE_START_DATE	             = X_LATE_START_DATE
                           ,LATE_FINISH_DATE	             = X_LATE_FINISH_DATE
                           ,CALENDAR_ID		             = X_CALENDAR_ID
                           ,MILESTONE_FLAG	             = X_MILESTONE_FLAG
                           ,CRITICAL_FLAG		             = X_CRITICAL_FLAG
                           ,LAST_UPDATE_DATE	             = SYSDATE
                           ,LAST_UPDATED_BY	             = FND_GLOBAL.USER_ID
                           ,LAST_UPDATE_LOGIN	             = FND_GLOBAL.LOGIN_ID
                           ,WQ_PLANNED_QUANTITY              = X_WQ_PLANNED_QUANTITY
                           ,PLANNED_EFFORT                   = X_PLANNED_EFFORT
                           ,ACTUAL_DURATION                  = X_ACTUAL_DURATION
                           ,ESTIMATED_DURATION               = X_ESTIMATED_DURATION
                           ,RECORD_VERSION_NUMBER            = NVL( RECORD_VERSION_NUMBER, 0 ) + 1
                           ,attribute_category              = X_attribute_category
                           ,attribute1                      = X_attribute1
                           ,attribute2                      = X_attribute2
                           ,attribute3                      = X_attribute3
                           ,attribute4                      = X_attribute4
                           ,attribute5                      = X_attribute5
                           ,attribute6                      = X_attribute6
                           ,attribute7                      = X_attribute7
                           ,attribute8                      = X_attribute8
                           ,attribute9                      = X_attribute9
                           ,attribute10                     = X_attribute10
                           ,attribute11                     = X_attribute11
                           ,attribute12                     = X_attribute12
                           ,attribute13                     = X_attribute13
                           ,attribute14                     = X_attribute14
                           ,attribute15                     = X_attribute15
                           ,DEF_SCH_TOOL_TSK_TYPE_CODE      = x_def_sch_tool_tsk_type_code
                           ,CONSTRAINT_TYPE_CODE            = x_constraint_type_code
                           ,CONSTRAINT_DATE                 = x_constraint_date
                           ,FREE_SLACK                      = x_free_slack
                           ,TOTAL_SLACK                     = x_total_slack
                           ,EFFORT_DRIVEN_FLAG              = x_effort_driven_flag
                           ,LEVEL_ASSIGNMENTS_FLAG          = x_level_assignments_flag
                           ,ext_act_duration                = X_ext_act_duration
                           ,ext_remain_duration             = X_ext_remain_duration
                           ,ext_sch_duration                = X_ext_sch_duration
      WHERE rowid = X_ROW_ID;
END Update_Row;

PROCEDURE Delete_Row(
X_ROW_ID                   IN VARCHAR2
) IS
BEGIN
    DELETE FROM pa_proj_elem_ver_schedule
     WHERE rowid = X_ROW_ID;
END Delete_Row;

END PA_PROJ_ELEMENT_SCH_PKG;

/
