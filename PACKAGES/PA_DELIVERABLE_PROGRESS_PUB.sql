--------------------------------------------------------
--  DDL for Package PA_DELIVERABLE_PROGRESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DELIVERABLE_PROGRESS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPRDLPS.pls 120.1 2005/08/19 16:44:17 mwasowic noship $ */


PROCEDURE UPDATE_DELIVERABLE_PROGRESS(
 p_api_version	                         IN	   NUMBER	         := 1.0                                  ,
 p_init_msg_list	                    IN	   VARCHAR2	    := FND_API.G_TRUE                       ,
 p_commit	                              IN	   VARCHAR2	    := FND_API.G_FALSE                      ,
 p_validate_only	                    IN	   VARCHAR2	    := FND_API.G_TRUE                       ,
 p_validation_level	                    IN	   NUMBER	         := FND_API.G_VALID_LEVEL_FULL           ,
 p_calling_module	                    IN	   VARCHAR2	    := 'SELF_SERVICE'                       ,
 p_action		                         IN      VARCHAR2        := 'SAVE'                               ,
 p_bulk_load_flag        	          IN 	   VARCHAR2        := 'N'                                  ,
 p_progress_mode                        IN      VARCHAR2        := 'FUTURE'                             ,
 p_percent_complete_id                  IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_project_id  	                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_id 	                         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_object_type                          IN      VARCHAR2        := 'PA_DELIVERABLES'                    ,
 p_object_version_id 	               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_del_status                           IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_id 	                         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_as_of_date                           IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_percent_complete                     IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ,
 p_progress_status_code                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_progress_comment                     IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_brief_overview                       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_actual_finish_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_deliverable_due_date                 IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_record_version_number                IN      NUMBER                                                  ,
 p_pm_product_code                      IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_structure_type                       IN      VARCHAR2        := 'WORKPLAN'                           ,
 x_return_status                        OUT     NOCOPY VARCHAR2                                                , --File.Sql.39 bug 4440895
 x_msg_count                            OUT     NOCOPY NUMBER                                                  , --File.Sql.39 bug 4440895
 x_msg_data                             OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


end PA_DELIVERABLE_PROGRESS_PUB;

 

/
