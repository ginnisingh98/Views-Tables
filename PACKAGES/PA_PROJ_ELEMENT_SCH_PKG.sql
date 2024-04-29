--------------------------------------------------------
--  DDL for Package PA_PROJ_ELEMENT_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_ELEMENT_SCH_PKG" AUTHID CURRENT_USER AS
/* $Header: PATSKT3S.pls 120.1 2005/08/19 17:06:11 mwasowic noship $ */

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
);

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
);

PROCEDURE Delete_Row(
X_ROW_ID                   IN VARCHAR2
);

END PA_PROJ_ELEMENT_SCH_PKG;

 

/
