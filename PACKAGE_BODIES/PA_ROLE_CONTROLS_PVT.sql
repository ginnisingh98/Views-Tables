--------------------------------------------------------
--  DDL for Package Body PA_ROLE_CONTROLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_CONTROLS_PVT" AS
 /* $Header: PARPRCVB.pls 120.1 2005/08/19 16:58:49 mwasowic noship $ */

-- --------------------------------------------------------------------------
--  PROCEDURE
--      Insert_Row
--  PURPOSE
--      This procedure inserts a row into the pa_role_controls table.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE INSERT_ROW (
 P_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 P_ROLE_CONTROL_CODE            IN         VARCHAR2,
 P_PROJECT_ROLE_ID              IN         NUMBER,
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
        PA_DEBUG.init_err_stack('PA_ROLE_CONTROLS_PVT.Insert_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

      PA_ROLE_CONTROLS_PKG.Insert_Row
      (X_ROWID                        =>  P_ROWID,
       X_ROLE_CONTROL_CODE            =>  P_ROLE_CONTROL_CODE,
       X_PROJECT_ROLE_ID              =>  P_PROJECT_ROLE_ID,
       X_LAST_UPDATE_DATE             =>  P_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY              =>  P_LAST_UPDATED_BY,
       X_CREATION_DATE                =>  P_CREATION_DATE,
       X_CREATED_BY                   =>  P_CREATED_BY,
       X_LAST_UPDATE_LOGIN            =>  P_LAST_UPDATE_LOGIN
      );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_ROLE_CONTROLS_PVT'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END INSERT_ROW;


-- --------------------------------------------------------------------------
--  PROCEDURE
--      Lock_Row
--  PURPOSE
--      This procedure determines if a row in the pa_role_controls table can
--      be locked. If a row can be locked, this API returns (S)uccess for
--      x_return_status.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE LOCK_ROW (
 P_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 P_RECORD_VERSION_NUMBER        IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


BEGIN

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_ROLE_CONTROLS_PVT.Lock_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_ROLE_CONTROLS_PKG.LOCK_ROW
        (X_ROWID                  => P_ROWID,
         X_RECORD_VERSION_NUMBER  => P_RECORD_VERSION_NUMBER
         );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_ROLE_CONTROLS_PVT'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END LOCK_ROW;

-- -------------------------------------------------------------------------
--  PROCEDURE
--      Update_Row
--  PURPOSE
--      This procedure updates a row in the pa_role_controls table.
--
--  HISTORY
--      08-AUG-00		jwhite		Created

PROCEDURE UPDATE_ROW (
 P_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 P_ROLE_CONTROL_CODE            IN         VARCHAR2,
 P_PROJECT_ROLE_ID              IN         NUMBER,
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
        PA_DEBUG.init_err_stack('PA_ROLE_CONTROLS_PVT.Update_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_ROLE_CONTROLS_PKG.UPDATE_ROW
        (X_ROWID                       => P_ROWID,
         X_ROLE_CONTROL_CODE           => P_ROLE_CONTROL_CODE,
         X_PROJECT_ROLE_ID             => P_PROJECT_ROLE_ID,
         X_LAST_UPDATE_DATE            => P_LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY             => P_LAST_UPDATED_BY,
         X_CREATION_DATE               => P_CREATION_DATE,
         X_CREATED_BY                  => P_CREATED_BY,
         X_LAST_UPDATE_LOGIN           => P_LAST_UPDATE_LOGIN
         );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_ROLE_CONTROLS_PVT'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END UPDATE_ROW;


-- ---------------------------------------------------------------------
--  PROCEDURE
--      Delete_Row
--  PURPOSE
--      This procedure deletes a row in the pa_role_controls table.
--
--      This procedure first calls the Check_Remove_Control_OK utils procedure.
--      If the role is OK to purge, then this procedure calls the
--      table handler Delete_Row procedure.
--
--      If a row is deleted, this API returns (S)uccess for the
--      x_return_status.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE DELETE_ROW (
 P_ROWID                        IN         VARCHAR2,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_rowid ROWID;
   l_project_role_id     pa_role_controls.project_role_id%TYPE :=NULL;
   l_role_control_code   pa_role_controls.role_control_code%TYPE :=NULL;
   l_return_status       VARCHAR2(1)  := NULL;
   l_error_message_code  VARCHAR2(30) := NULL;

BEGIN

        l_rowid := p_rowid;

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_ROLE_CONTROLS_PVT.Delete_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if OK to Delete the Project Role Id for the P_Rowid IN Parameter

                SELECT project_role_id, role_control_code
                INTO   l_project_role_id, l_role_control_code
                FROM   pa_role_controls
                WHERE  rowid = l_rowid;

                PA_ROLE_UTILS.Check_remove_control_ok
                (p_role_id             => l_project_role_id,
                 p_role_control_code   => l_role_control_code,
                 x_return_status       => l_return_status,
                 x_error_message_code  => l_error_message_code
                );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                	x_msg_count := 1;
                        x_msg_data  := l_error_message_code;
                        x_return_status := l_return_status;
                        FND_MSG_PUB.add_exc_msg
                        (p_pkg_name => 'PA_ROLE_CONTROLS_PVT'
                        , p_procedure_name => PA_DEBUG.G_Err_Stack
                        , p_error_text => l_error_message_code);
                        RETURN;
                END IF;


  -- Delete Role
        PA_ROLE_CONTROLS_PKG.DELETE_ROW
        ( X_ROWID         =>  P_ROWID
        );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_ROLE_CONTROLS_PVT'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END Delete_Row;


END pa_role_controls_pvt;

/
