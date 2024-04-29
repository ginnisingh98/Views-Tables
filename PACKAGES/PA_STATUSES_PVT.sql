--------------------------------------------------------
--  DDL for Package PA_STATUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUSES_PVT" AUTHID CURRENT_USER as
/* $Header: PARSTAVS.pls 120.1 2005/08/19 17:00:47 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_STATUSES_PVT
-- Purpose          : Private Package for table PA_PROJECT_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
-- NOTE             :
--                  : Subprogram Name          Type
--                  : ------------------       -----------------------
--                  : delete_status            PL/SQL procedure
-- End of Comments


ROW_ALREADY_LOCKED  EXCEPTION;
G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;


PROCEDURE delete_status_pvt
( p_api_version_number      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
 ,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
 ,p_validate_only           IN VARCHAR2 := FND_API.G_FALSE
 ,p_max_msg_count           IN NUMBER
 ,p_pa_project_status_code  IN VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_allow_deletion_flag    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

end PA_STATUSES_PVT;

 

/
