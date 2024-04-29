--------------------------------------------------------
--  DDL for Package PA_PROJECT_CTX_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CTX_SEARCH_PKG" 
-- $Header: PAXPCXTS.pls 120.1 2005/08/19 17:16:29 mwasowic noship $
AUTHID CURRENT_USER AS
PROCEDURE INSERT_ROW(p_project_id            IN  NUMBER,
                     p_ctx_description       IN  VARCHAR2,
                     x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_ROW(p_project_id            IN  NUMBER,
                     p_ctx_description       IN  VARCHAR2,
                     x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE DELETE_ROW(p_project_id            IN  NUMBER,
                     x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PROJECT_CTX_SEARCH_PKG;
 

/
