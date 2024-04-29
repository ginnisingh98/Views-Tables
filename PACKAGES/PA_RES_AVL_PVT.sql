--------------------------------------------------------
--  DDL for Package PA_RES_AVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_AVL_PVT" 
-- $Header: PARRAVLS.pls 120.1 2005/08/19 16:59:52 mwasowic noship $
AUTHID CURRENT_USER AS
-- Standard Table Handler procedures for PA_RES_AVAILABILITY table

PROCEDURE Insert_Row (
          P_RESOURCE_ID            IN     pa_res_availability.resource_id%type
         ,P_START_DATE             IN     pa_res_availability.start_date%type
         ,P_END_DATE               IN     pa_res_availability.end_date%type
         ,P_RECORD_TYPE            IN     pa_res_availability.record_type%type
         ,P_PERCENT                IN     pa_res_availability.percent%type
         ,P_HOURS                  IN     pa_res_availability.hours%type
         ,X_ROW_ID                 OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
         ,X_RETURN_STATUS          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Update_Row (
          P_RESOURCE_ID         IN     pa_res_availability.resource_id%type
         ,P_START_DATE          IN     pa_res_availability.start_date%type
         ,P_END_DATE            IN     pa_res_availability.end_date%type       := FND_API.G_MISS_DATE
         ,P_RECORD_TYPE         IN     pa_res_availability.record_type%type
         ,P_PERCENT             IN     pa_res_availability.percent%type        := FND_API.G_MISS_NUM
         ,P_HOURS               IN     pa_res_availability.hours%type          := FND_API.G_MISS_NUM
         ,X_RETURN_STATUS       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Delete_Row (
          P_RESOURCE_ID            IN     pa_res_availability.resource_id%type
         ,P_START_DATE             IN     pa_res_availability.start_date%type
         ,P_RECORD_TYPE            IN     pa_res_availability.record_type%type
         ,X_RETURN_STATUS          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_RES_AVL_PVT;
 

/
