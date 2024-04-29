--------------------------------------------------------
--  DDL for Package Body PA_STATUS_LISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_LISTS_PVT" AS
 /* $Header: PACISLVB.pls 120.1 2005/08/19 16:18:39 mwasowic noship $ */


-- --------------------------------------------------------------------------
--  FUNCTION
--      check_status_list_inuse
--  PURPOSE
--      This function checks whether the given status List is in use or not.
--      If in use it returns 'Y' otherwise it returns 'N'.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--
FUNCTION check_status_list_inuse( P_STATUS_LIST_ID NUMBER)
RETURN VARCHAR2
IS
 CURSOR ci_val_cur
 IS
   SELECT 1
   FROM pa_obj_status_lists
   WHERE object_type= 'PA_CI_TYPES'
   AND STATUS_TYPE = 'CONTROL_ITEM'
   AND STATUS_LIST_ID =P_STATUS_LIST_ID;

   l_number  NUMBER :=0;
   l_return  VARCHAR2(10) := NULL;
BEGIN
   OPEN ci_val_cur;
   FETCH ci_val_cur INTO l_number;
   IF ci_val_cur%NOTFOUND THEN
      l_return := 'N';
   ELSE
      l_return := 'Y';
   END IF;
   CLOSE ci_val_cur;  --Added for bug# 3867679
   RETURN l_return;
END check_status_list_inuse;


-- --------------------------------------------------------------------------
--  PROCEDURE
--      CreateStatusList
--  PURPOSE
--      This procedure inserts a row into the pa_status_lists table.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--

PROCEDURE CreateStatusList (
 P_RECORD_VERSION_NUMBER	IN         NUMBER,
 P_STATUS_LIST_ID               IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_NAME                         IN         VARCHAR2,
 P_START_DATE_ACTIVE            IN         DATE,
 P_END_DATE_ACTIVE              IN         DATE,
 P_DESCRIPTION                  IN         VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE  ,
 P_LAST_UPDATED_BY              IN         NUMBER ,
 P_CREATION_DATE                IN         DATE  ,
 P_CREATED_BY                   IN         NUMBER ,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

BEGIN

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LISTS_PVT.Insert_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_STATUS_LISTS_PKG.INSERT_ROW
        (
	 X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
         X_STATUS_LIST_ID => P_STATUS_LIST_ID,
         X_STATUS_TYPE => P_STATUS_TYPE,
         X_NAME => P_NAME,
         X_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
         X_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
         X_DESCRIPTION => P_DESCRIPTION,
         X_CREATION_DATE => P_CREATION_DATE,
         X_CREATED_BY => P_CREATED_BY,
         X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
         X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN
        );
  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STTUS_LISTS_PVT'
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
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 P_STATUS_LIST_ID               IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_NAME                         IN         VARCHAR2,
 P_START_DATE_ACTIVE            IN         DATE,
 P_END_DATE_ACTIVE              IN         DATE,
 P_DESCRIPTION                  IN         VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE    ,
 P_LAST_UPDATED_BY              IN         NUMBER ,
 P_LAST_UPDATE_LOGIN            IN         NUMBER  ,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
Invalid_Ret_Status EXCEPTION;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_data VARCHAR2(2000);
l_msg_index_out NUMBER;
l_debug_mode                    VARCHAR2(1);
g_module_name      VARCHAR2(100) := 'pa.plsql.PA_STATUS_LISTS';
l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN
    savepoint UpdateSL;
  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LISTS_PVT.Update_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
	  IF l_debug_mode = 'Y' THEN
	          pa_debug.g_err_stage:= 'Validating input parameters';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
	  END IF;

	   IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'P_STATUS_LIST_ID = '|| P_STATUS_LIST_ID;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'P_STATUS_TYPE = '|| P_STATUS_TYPE;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);

	   END IF;
           IF l_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'about to call lock row method';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
	   END IF;
           PA_STATUS_LISTS_PKG.LOCK_ROW
           (
	   X_STATUS_LIST_ID => P_STATUS_LIST_ID,
	   X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER
	   );
	   IF l_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'lock row method called';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
	   END IF;
	   l_msg_count := FND_MSG_PUB.count_msg;
           if(l_msg_count<>0) then
		Raise Invalid_Ret_Status;
	   end if;
	   IF l_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'about to call PA_STATUS_LISTS_PKG.UPDATE_ROW';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
	   END IF;
	   PA_STATUS_LISTS_PKG.UPDATE_ROW
           (X_STATUS_LIST_ID => P_STATUS_LIST_ID,
	    X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
            X_STATUS_TYPE => P_STATUS_TYPE,
            X_NAME => P_NAME,
            X_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
            X_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
            X_DESCRIPTION => P_DESCRIPTION,
            X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN
           );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
	WHEN Invalid_Ret_Status THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 l_msg_count := FND_MSG_PUB.count_msg;

	     IF l_msg_count = 1 and x_msg_data IS NULL THEN
		  PA_INTERFACE_UTILS_PUB.get_messages
	              (p_encoded        => FND_API.G_TRUE
		      ,p_msg_index      => 1
	              ,p_msg_count      => l_msg_count
		      ,p_msg_data       => l_msg_data
	              ,p_data           => l_data
		      ,p_msg_index_out  => l_msg_index_out);
	          x_msg_data := l_data;
		  x_msg_count := l_msg_count;
	     ELSE
		  x_msg_count := l_msg_count;
	     END IF;
             rollback to UpdateSL;
	     RETURN;
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LISTS_PVT'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           rollback to UpdateSL;
           RAISE;

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
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
Invalid_Ret_Status EXCEPTION;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_data VARCHAR2(2000);
l_msg_index_out NUMBER;
l_debug_mode                    VARCHAR2(1);

BEGIN
	savepoint DeleteSL;


  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LISTS_PVT.Delete_Row');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	PA_STATUS_LISTS_PKG.LOCK_ROW
           (
	   X_STATUS_LIST_ID => P_STATUS_LIST_ID,
	   X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER
	   );

	 l_msg_count := FND_MSG_PUB.count_msg;
	 if(l_msg_count<>0) then
		Raise Invalid_Ret_Status;
	 end if;

  -- Delete Role
        PA_STATUS_LISTS_PKG.DELETE_ROW
        ( X_STATUS_LIST_ID         =>  P_STATUS_LIST_ID,
	  X_RECORD_VERSION_NUMBER  =>  P_RECORD_VERSION_NUMBER
        );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
	WHEN Invalid_Ret_Status THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 l_msg_count := FND_MSG_PUB.count_msg;

	     IF l_msg_count = 1 and x_msg_data IS NULL THEN
		  PA_INTERFACE_UTILS_PUB.get_messages
	              (p_encoded        => FND_API.G_TRUE
		      ,p_msg_index      => 1
	              ,p_msg_count      => l_msg_count
		      ,p_msg_data       => l_msg_data
	              ,p_data           => l_data
		      ,p_msg_index_out  => l_msg_index_out);
	          x_msg_data := l_data;
		  x_msg_count := l_msg_count;
	     ELSE
		  x_msg_count := l_msg_count;
	     END IF;
             rollback to DeleteSL;
	     RETURN;
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LISTS_PVT'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
	   rollback to DeleteSL;
           RAISE;

END DeleteStatusList;


END pa_status_lists_pvt;

/
