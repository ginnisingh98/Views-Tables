--------------------------------------------------------
--  DDL for Package Body PA_GEN_FORECAST_WRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GEN_FORECAST_WRP_PKG" AS
/* $Header: PACNGFCB.pls 120.2 2007/02/06 09:42:08 dthakker ship $ */
   PROCEDURE Rep_Heading IS
   BEGIN
    NULL; --Bug 5499922: Stubbed out the procedure
   END;
   PROCEDURE GENERATE_FORECAST_WRP( errbuff OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    retcode OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    p_from_project_no VARCHAR2 ,
                                    p_to_project_no   VARCHAR2 ,
                                    p_org_id          NUMBER ,
                                    p_debug_mode VARCHAR2 DEFAULT 'Y' ) AS
   BEGIN
       NULL; --Bug 5499922: Stubbed out the procedure
   END GENERATE_FORECAST_WRP;
   --
   -- Use the MIN and MAX values of the project number
   -- if the user did not specify the range when submitting the report
   --
   PROCEDURE Get_Project_Num_Range (
                 p_proj_num_from        IN      VARCHAR2,
                 p_proj_num_to          IN      VARCHAR2,
                 p_proj_num_from_out    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 p_proj_num_to_out      OUT     NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

  BEGIN
    NULL; --Bug 5499922: Stubbed out the procedure
  END Get_Project_Num_Range;
END PA_GEN_FORECAST_WRP_PKG;

/
