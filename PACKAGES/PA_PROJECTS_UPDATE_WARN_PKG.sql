--------------------------------------------------------
--  DDL for Package PA_PROJECTS_UPDATE_WARN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECTS_UPDATE_WARN_PKG" AUTHID CURRENT_USER as
/* $Header: PAYRPK3S.pls 120.1 2005/08/19 17:24:33 mwasowic noship $ */
--
-- Procedure     : insert_row
-- Purpose       : Create Row in PA_PROJ_UPD_WARN_TEMP.
--
--
PROCEDURE insert_row
      ( p_project_name                    IN PA_PROJ_UPD_WARN_TEMP.project_name%TYPE,
	      p_warning			                    IN PA_PROJ_UPD_WARN_TEMP.warning%TYPE,
        x_return_status                   OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                       OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                        OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895



END PA_PROJECTS_UPDATE_WARN_PKG;

 

/
