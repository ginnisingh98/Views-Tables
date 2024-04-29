--------------------------------------------------------
--  DDL for Package PA_GEN_FORECAST_WRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GEN_FORECAST_WRP_PKG" AUTHID CURRENT_USER AS
/* $Header: PACNGFCS.pls 120.3 2007/02/06 09:42:38 dthakker noship $ */
    PROCEDURE GENERATE_FORECAST_WRP( errbuff OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     retcode OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     p_from_project_no VARCHAR2 ,
                                     p_to_project_no   VARCHAR2 ,
                                     p_org_id          NUMBER ,
                                     p_debug_mode  VARCHAR2 DEFAULT 'Y' );

   PROCEDURE Get_Project_Num_Range (
                 p_proj_num_from        IN      VARCHAR2,
                 p_proj_num_to          IN      VARCHAR2,
                 p_proj_num_from_out    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 p_proj_num_to_out      OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

END PA_GEN_FORECAST_WRP_PKG;

/
