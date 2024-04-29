--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENT_PROGRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENT_PROGRESS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPRASPS.pls 120.1 2005/08/19 16:44:08 mwasowic noship $ */

PROCEDURE UPDATE_ASSIGNMENT_PROGRESS(
 p_api_version	              IN	NUMBER	        := 1.0					,
 p_init_msg_list	      IN	VARCHAR2	:= FND_API.G_TRUE			,
 p_commit	              IN	VARCHAR2	:= FND_API.G_FALSE			,
 p_validate_only	      IN	VARCHAR2	:= FND_API.G_TRUE			,
 p_validation_level	      IN	NUMBER		:= FND_API.G_VALID_LEVEL_FULL		,
 p_calling_module	      IN	VARCHAR2	:= 'SELF_SERVICE'			,
 p_action		      IN        VARCHAR2	:= 'SAVE'				,
 p_bulk_load_flag	      IN 	VARCHAR2	:= 'N'					,
 p_progress_mode              IN        VARCHAR2	:= 'FUTURE'				,
 p_percent_complete_id        IN        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_project_id  	              IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_object_id	 	      IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_object_version_id	      IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_task_id 	              IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_as_of_date                 IN	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_progress_comment           IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_brief_overview             IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_actual_start_date          IN	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date         IN	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimated_start_date	      IN	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimated_finish_date      IN	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_record_version_number      IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_pm_product_code            IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_rate_based_flag            IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_class_code        IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_txn_currency_code          IN        VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_rbs_element_id             IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
-- p_resource_list_member_id  IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,  --bug# 3764224
 p_resource_assignment_id     IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_actual_cost                IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_actual_effort              IN        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_planned_cost               IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_planned_effort             IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_structure_type	      IN	VARCHAR2	:= 'WORKPLAN'				,
 p_structure_version_id       IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_actual_cost_this_period    IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_actual_effort_this_period  IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_etc_cost_this_period       IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_etc_effort_this_period     IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM	,
 p_scheduled_start_date       IN        DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_finish_date      IN        DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 x_return_status              OUT	NOCOPY VARCHAR2						, --File.Sql.39 bug 4440895
 x_msg_count                  OUT	NOCOPY NUMBER							, --File.Sql.39 bug 4440895
 x_msg_data                   OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_ASSIGNMENT_PROGRESS_PUB;

 

/
