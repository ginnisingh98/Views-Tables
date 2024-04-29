--------------------------------------------------------
--  DDL for Package PA_RESOURCE_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_SETUP_PVT" AUTHID CURRENT_USER AS
/* $Header: PARESTVS.pls 120.1 2005/08/19 16:51:09 mwasowic noship $ */


-- API name                      : update_addition_staff_info
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A

PROCEDURE UPDATE_ADDITIONAL_STAFF_INFO
(p_api_version                  IN NUMBER     := 1.0                   ,
 p_init_msg_list                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_commit                       IN VARCHAR2   := FND_API.G_FALSE       ,
 p_validate_only                IN VARCHAR2   := FND_API.G_TRUE        ,
 p_project_id                   IN NUMBER                              ,
 p_calendar_id                  IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_role_list_id                 IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_adv_action_set_id            IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_start_adv_action_set_flag    IN VARCHAR2   := FND_API.G_MISS_CHAR   ,
 p_record_version_number        IN NUMBER                              ,
 p_initial_team_template_id     IN NUMBER     := FND_API.G_MISS_NUM    , -- added for bug 2607631
 p_proj_req_res_format_id       IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_proj_asgmt_res_format_id     IN NUMBER     := FND_API.G_MISS_NUM    ,
 p_max_msg_count                IN NUMBER     := FND_API.G_MISS_NUM    ,
 x_return_status                OUT NOCOPY VARCHAR2                           , --File.Sql.39 bug 4440895
 x_msg_count                    OUT NOCOPY NUMBER                             , --File.Sql.39 bug 4440895
 x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_RESOURCE_SETUP_PVT;

 

/
