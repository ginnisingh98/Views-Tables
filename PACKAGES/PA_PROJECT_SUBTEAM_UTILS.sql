--------------------------------------------------------
--  DDL for Package PA_PROJECT_SUBTEAM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SUBTEAM_UTILS" AUTHID CURRENT_USER AS
 /*$Header: PARTSTUS.pls 120.1 2005/08/19 17:02:04 mwasowic noship $*/

 /**************************************************************
  PROCEDURE
              Check_Subteam_Name_Or_Id
  PURPOSE
              This procedure does the following
              1. If the subteam_id and check_id_flag is passed as 'Y'
                 then it checks the passed subteam_id is a valid one.
              If object_type,object_id and subteam name is passed,
                returns the subteam_id if teher exists one
	      In both the cases the x_return_status will be
              success - FND_API.G_RET_STS_SUCCESS
              failure - FND_API.G_RET_STS_ERRORS
  **************************************************************/

procedure Check_Subteam_Name_Or_Id (
             		p_subteam_name          IN      VARCHAR2 :=FND_API.G_MISS_CHAR,
                        p_object_type           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
                        p_object_id             IN      NUMBER := FND_API.G_MISS_NUM,
                        p_check_id_flag         IN      VARCHAR2 := 'A',
                        x_subteam_id            IN OUT  NOCOPY NUMBER , --File.Sql.39 bug 4440895
                        x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_error_message_code    OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

procedure get_object_id(p_object_type IN varchar2
                       ,p_object_id   IN OUT NOCOPY number --File.Sql.39 bug 4440895
                       ,p_object_name IN varchar2
                       ,x_return_status         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       ,x_error_message_code    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_project_subteam_utils;
 

/
