--------------------------------------------------------
--  DDL for Package Body PA_STATUS_LISTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_LISTS_PUB" AS
 /* $Header: PACISLPB.pls 120.1 2005/08/19 16:18:31 mwasowic noship $ */

-- --------------------------------------------------------------------------
--  PROCEDURE
--      CreateStatusList
--  PURPOSE
--      This procedure inserts a row into the pa_role_controls table.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--

PROCEDURE CreateStatusList (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 P_STATUS_LIST_ID               IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_NAME                         IN         VARCHAR2,
 P_START_DATE_ACTIVE            IN         DATE,
 P_END_DATE_ACTIVE              IN         DATE,
 P_DESCRIPTION                  IN         VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

BEGIN

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LISTS_PUB.Insert_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_STATUS_LISTS_PVT.CreateStatusList
        (
	 P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
         P_STATUS_LIST_ID => P_STATUS_LIST_ID,
         P_STATUS_TYPE => P_STATUS_TYPE,
         P_NAME => P_NAME,
         P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
         P_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
         P_DESCRIPTION => P_DESCRIPTION,
         P_CREATION_DATE => P_CREATION_DATE,
         P_CREATED_BY => P_CREATED_BY,
         P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
         P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
         P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
         X_RETURN_STATUS  => X_RETURN_STATUS,
         X_MSG_COUNT => X_MSG_COUNT,
         X_MSG_DATA => X_MSG_DATA
        );
  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LISTS_PUB'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END CreateStatusList;



-- -------------------------------------------------------------------------
--  PROCEDURE
--      UpdateStatusList
--  PURPOSE
--      This procedure updates a row in the pa_status_lists table.
--
--  HISTORY
--      16-JAN-04		rasinha		Created

PROCEDURE UpdateStatusList (
 P_RECORD_VERSION_NUMBER	IN         NUMBER,
 P_STATUS_LIST_ID               IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_NAME                         IN         VARCHAR2,
 P_START_DATE_ACTIVE            IN         DATE,
 P_END_DATE_ACTIVE              IN         DATE,
 P_DESCRIPTION                  IN         VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

BEGIN

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LISTS_PUB.Update_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_STATUS_LISTS_PVT.UpdateStatusList
        (
	 P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
         P_STATUS_LIST_ID => P_STATUS_LIST_ID,
         P_STATUS_TYPE => P_STATUS_TYPE,
         P_NAME => P_NAME,
         P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
         P_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
         P_DESCRIPTION => P_DESCRIPTION,
         P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
         P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
         P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
         X_RETURN_STATUS  => X_RETURN_STATUS,
         X_MSG_COUNT => X_MSG_COUNT,
         X_MSG_DATA => X_MSG_DATA
        );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LISTS_PUB'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END UpdateStatusList;


-- ---------------------------------------------------------------------
--  PROCEDURE
--      DeleteStatusList
--  PURPOSE
--      This procedure deletes a row in the pa_status_lists table.
--
--      If a row is deleted, this API returns (S)uccess for the
--      x_return_status.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--

PROCEDURE DeleteStatusList (
 P_STATUS_LIST_ID               IN         NUMBER,
 P_RECORD_VERSION_NUMBER	IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN


  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LISTS_PUB.Delete_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Delete Role
        PA_STATUS_LISTS_PVT.DeleteStatusList
        ( P_STATUS_LIST_ID =>  P_STATUS_LIST_ID,
	  P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
          X_RETURN_STATUS  => X_RETURN_STATUS,
          X_MSG_COUNT      => X_MSG_COUNT,
          X_MSG_DATA       => X_MSG_DATA
        );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LISTS_PUB'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END DeleteStatusList;


END pa_status_lists_pub;

/
