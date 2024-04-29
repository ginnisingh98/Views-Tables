--------------------------------------------------------
--  DDL for Package PA_PROJECT_CTX_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CTX_SEARCH_PVT" 
-- $Header: PAXPCXVS.pls 120.1 2005/08/19 17:16:37 mwasowic noship $
AUTHID CURRENT_USER AS
PROCEDURE INSERT_ROW(p_project_id            IN  NUMBER,
                     p_template_flag         IN  VARCHAR2,
                     p_project_name          IN  VARCHAR2,
                     p_project_number        IN  VARCHAR2,
                     p_project_long_name     IN  VARCHAR2 default null,
                     p_project_description   IN  VARCHAR2 default null,
                     x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_ROW(p_project_id            IN  NUMBER,
                     p_template_flag         IN  VARCHAR2,
                     p_project_name          IN  VARCHAR2,
                     p_project_number        IN  VARCHAR2,
                     p_project_long_name     IN  VARCHAR2 default null,
                     p_project_description   IN  VARCHAR2 default null,
                     x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE DELETE_ROW(p_project_id            IN  VARCHAR2,
                     p_template_flag         IN  VARCHAR2,
                     x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PROJECT_CTX_SEARCH_PVT;
 

/
