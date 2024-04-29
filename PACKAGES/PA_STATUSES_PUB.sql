--------------------------------------------------------
--  DDL for Package PA_STATUSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUSES_PUB" AUTHID CURRENT_USER as
/* $Header: PARSTAPS.pls 120.1 2005/08/19 17:00:39 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_STATUSES_PUB
-- Purpose          : Public Package for table PA_PROJECT_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
-- NOTE             :
--                  : Subprogram Name          Type
--                  : ------------------       -----------------------
--                  : delete_status            PL/SQL procedure
-- End of Comments

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

--Locking exception
ROW_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);


PROCEDURE delete_status
( p_api_version_number      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
 ,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
 ,p_validate_only           IN VARCHAR2 := FND_API.G_FALSE
 ,p_max_msg_count           IN NUMBER
 ,p_pa_project_status_code  IN VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_allow_deletion_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

end PA_STATUSES_PUB;

 

/
