--------------------------------------------------------
--  DDL for Package Body PA_RES_AVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_AVL_PVT" 
-- $Header: PARRAVLB.pls 120.1 2005/08/19 16:59:49 mwasowic noship $
AS
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
)
IS
BEGIN

    PA_DEBUG.init_err_stack('PA_RES_AVL_PVT.Insert_Row');

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    insert into PA_RES_AVAILABILITY (
                RESOURCE_ID
               ,START_DATE
               ,END_DATE
               ,RECORD_TYPE
               ,PERCENT
               ,HOURS
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN )
     values (
                P_RESOURCE_ID
               ,P_START_DATE
               ,P_END_DATE
               ,P_RECORD_TYPE
               ,P_PERCENT
               ,P_HOURS
               ,sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,fnd_global.login_id
     )
     RETURNING rowid INTO X_ROW_ID;

EXCEPTION
    WHEN OTHERS THEN
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg
          (p_pkg_name       => 'PA_RES_AVL_PVT'
          ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;


PROCEDURE Update_Row (
          P_RESOURCE_ID         IN     pa_res_availability.resource_id%type
         ,P_START_DATE          IN     pa_res_availability.start_date%type
         ,P_END_DATE            IN     pa_res_availability.end_date%type       := FND_API.G_MISS_DATE
         ,P_RECORD_TYPE         IN     pa_res_availability.record_type%type
         ,P_PERCENT             IN     pa_res_availability.percent%type        := FND_API.G_MISS_NUM
         ,P_HOURS               IN     pa_res_availability.hours%type          := FND_API.G_MISS_NUM
         ,X_RETURN_STATUS       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN

    PA_DEBUG.init_err_stack('PA_RES_AVL_PVT.Update_Row');

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    update PA_RES_AVAILABILITY
    set END_DATE               = DECODE(p_end_date, FND_API.G_MISS_DATE, END_DATE, p_end_date)
       ,PERCENT                = DECODE(p_percent, FND_API.G_MISS_NUM, PERCENT, p_percent)
       ,HOURS                  = DECODE(p_hours, FND_API.G_MISS_NUM, HOURS, p_hours)
       ,LAST_UPDATE_DATE       = sysdate
       ,LAST_UPDATED_BY        = fnd_global.user_id
       ,LAST_UPDATE_LOGIN      = fnd_global.login_id
    where
         RESOURCE_ID = p_resource_id
     and START_DATE  = p_start_date
     and RECORD_TYPE = p_record_type;

EXCEPTION
    WHEN OTHERS THEN
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg
          (p_pkg_name       => 'PA_RES_AVL_PVT'
          ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

PROCEDURE Delete_Row (
          P_RESOURCE_ID            IN     pa_res_availability.resource_id%type
         ,P_START_DATE             IN     pa_res_availability.start_date%type
         ,P_RECORD_TYPE            IN     pa_res_availability.record_type%type
         ,X_RETURN_STATUS          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN

    PA_DEBUG.init_err_stack('PA_RES_AVL_PVT.Delete_Row');

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    delete from PA_RES_AVAILABILITY
    where
         RESOURCE_ID = p_resource_id
     and START_DATE  = p_start_date
     and RECORD_TYPE = p_record_type;

EXCEPTION
    WHEN OTHERS THEN
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg
          (p_pkg_name       => 'PA_RES_AVL_PVT'
          ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Row;


END PA_RES_AVL_PVT;

/
