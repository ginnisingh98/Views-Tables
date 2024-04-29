--------------------------------------------------------
--  DDL for Package Body PA_PERF_THRESHOLDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_THRESHOLDS_PVT" AS
/* $Header: PAPETHVB.pls 120.1 2005/08/19 16:40:05 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_perf_thresholds_pvt';

/*==================================================================
  PROCEDURE
      create_rule_det
  PURPOSE
      This procedure inserts a row into the pa_perf_thersholds table.
 ==================================================================*/


PROCEDURE create_rule_det(
  P_THRESHOLD_ID          IN NUMBER,
  P_RULE_TYPE             IN VARCHAR2,
  P_THRES_OBJ_ID          IN NUMBER,
  P_FROM_VALUE            IN NUMBER,
  P_TO_VALUE              IN NUMBER,
  P_INDICATOR_CODE        IN VARCHAR2,
  P_EXCEPTION_FLAG        IN VARCHAR2,
  P_WEIGHTING             IN NUMBER,
  P_ACCESS_LIST_ID        IN NUMBER,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_CREATION_DATE         IN DATE,
  P_CREATED_BY            IN NUMBER,
  P_LAST_UPDATE_DATE      IN DATE,
  P_LAST_UPDATED_BY       IN NUMBER,
  P_LAST_UPDATE_LOGIN     IN NUMBER,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_msg_count               NUMBER := 0;
l_data                    VARCHAR2(2000);
l_msg_data                VARCHAR2(2000);
l_msg_index_out           NUMBER;
l_debug_mode              VARCHAR2(1);
l_rowid                   VARCHAR2(255);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN

     -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_THRESHOLDS_PVT.create_rule_det');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_THRESHOLDS_PVT.create_rule_det',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_THRESHOLDS_PVT.create_rule_det';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;


     PA_PERF_THRESHOLDS_PKG.insert_row(
        X_ROWID => l_rowid,
        X_THRESHOLD_ID => P_THRESHOLD_ID,
        X_RULE_TYPE => P_RULE_TYPE,
        X_THRES_OBJ_ID => P_THRES_OBJ_ID,
        X_FROM_VALUE => P_FROM_VALUE,
        X_TO_VALUE => P_TO_VALUE,
        X_INDICATOR_CODE => P_INDICATOR_CODE,
        X_EXCEPTION_FLAG => P_EXCEPTION_FLAG,
        X_WEIGHTING => P_WEIGHTING,
        X_ACCESS_LIST_ID => P_ACCESS_LIST_ID,
        X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
        X_CREATION_DATE => P_CREATION_DATE,
        X_CREATED_BY => P_CREATED_BY,
        X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN
     );

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_THRESHOLDS_PVT.create_rule_det';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;

     -- Reset the Error Stack
     PA_DEBUG.reset_err_stack;


EXCEPTION
   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg(
       p_pkg_name        => 'PA_PERF_THRESHOLDS_PVT'
      ,p_procedure_name  => 'CREATE_RULE_DET'
      ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error: '||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
      END IF;
      RAISE;
END create_rule_det;

/*==================================================================
  PROCEDURE
      update_rule
  PURPOSE
      This procedure updates a row into the pa_perf_thersholds table.
 ==================================================================*/

PROCEDURE update_rule_det(
  P_THRESHOLD_ID          IN NUMBER,
  P_RULE_TYPE             IN VARCHAR2,
  P_THRES_OBJ_ID          IN NUMBER,
  P_FROM_VALUE            IN NUMBER,
  P_TO_VALUE              IN NUMBER,
  P_INDICATOR_CODE        IN VARCHAR2,
  P_EXCEPTION_FLAG        IN VARCHAR2,
  P_WEIGHTING             IN NUMBER,
  P_ACCESS_LIST_ID        IN NUMBER,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_LAST_UPDATE_DATE      IN DATE,
  P_LAST_UPDATED_BY       IN NUMBER,
  P_LAST_UPDATE_LOGIN     IN NUMBER,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
Invalid_Ret_Status        EXCEPTION;
l_msg_count               NUMBER := 0;
l_data                    VARCHAR2(2000);
l_msg_data                VARCHAR2(2000);
l_msg_index_out           NUMBER;
l_debug_mode              VARCHAR2(1);
l_rowid                   VARCHAR2(255);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN

  savepoint sp;
  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_THRESHOLDS_PVT.Update_Rule_Det');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_THRESHOLDS_PVT.update_rule_det',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_THRESHOLDS_PVT.update_rule_det';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

	  pa_debug.g_err_stage:= 'P_THRESHOLD_ID = '|| P_THRESHOLD_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level5);

	  pa_debug.g_err_stage:= 'P_RULE_TYPE = '|| P_RULE_TYPE;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call lock row method';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                          l_debug_level3);
     END IF;

     PA_PERF_THRESHOLDS_PKG.LOCK_ROW (
	X_THRESHOLD_ID => P_THRESHOLD_ID,
	X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER );

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
	pa_debug.g_err_stage:= 'about to call PA_PERF_THRESHOLDS_PKG.UPDATE_ROW';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

     PA_PERF_THRESHOLDS_PKG.UPDATE_ROW(
       X_THRESHOLD_ID => P_THRESHOLD_ID,
       X_RULE_TYPE => P_RULE_TYPE,
       X_THRES_OBJ_ID => P_THRES_OBJ_ID,
       X_FROM_VALUE => P_FROM_VALUE,
       X_TO_VALUE => P_TO_VALUE,
       X_INDICATOR_CODE => P_INDICATOR_CODE,
       X_EXCEPTION_FLAG => P_EXCEPTION_FLAG,
       X_WEIGHTING => P_WEIGHTING,
       X_ACCESS_LIST_ID => P_ACCESS_LIST_ID,
       X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
       X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN );

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_THRESHOLDS_PVT.update_rule_det';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;

     -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
     WHEN Invalid_Ret_Status THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	l_msg_count := FND_MSG_PUB.count_msg;

	IF l_msg_count = 1 and x_msg_data IS NULL THEN
	   PA_INTERFACE_UTILS_PUB.get_messages(
	    p_encoded        => FND_API.G_TRUE
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

	IF l_debug_mode = 'Y' THEN
   	   pa_debug.reset_curr_function;
	END IF;

	rollback to sp;
        RETURN;

     WHEN OTHERS THEN
        x_msg_count := 1;
        x_msg_data  := substr(SQLERRM,1,240);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg (
	  p_pkg_name => 'PA_PERF_THRESHOLDS_PVT'
        , p_procedure_name => PA_DEBUG.G_Err_Stack
        , p_error_text => substr(SQLERRM,1,240));

	rollback to sp;
        RAISE;

END update_rule_det;

/*==================================================================
  PROCEDURE
      delete_rule_det
  PURPOSE
      This procedure deletes a row from the pa_perf_thersholds table.
 ==================================================================*/

PROCEDURE delete_rule_det (
 P_THRESHOLD_ID           IN         NUMBER,
 P_RECORD_VERSION_NUMBER  IN         NUMBER,
 X_RETURN_STATUS          OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT              OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA               OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
Invalid_Ret_Status EXCEPTION;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_data VARCHAR2(2000);
l_msg_index_out NUMBER;
l_debug_mode                    VARCHAR2(1);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN
  savepoint sp;


  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_THRESHOLDS_PVT.Delete_Rule_Det');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_THRESHOLDS_PVT.delete_rule_det',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_THRESHOLDS_PVT.delete_rule_det';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
          pa_debug.g_err_stage:= 'P_THRESHOLD_ID = '|| P_THRESHOLD_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level5);

	  pa_debug.g_err_stage:= 'about to call lock row method';
	  pa_debug.write(g_module_name,pa_debug.g_err_stage,
                            l_debug_level3);
     END IF;

     PA_PERF_THRESHOLDS_PKG.LOCK_ROW
     (
	X_THRESHOLD_ID => P_THRESHOLD_ID,
	X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER
     );

     l_msg_count := FND_MSG_PUB.count_msg;
     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call PA_PERF_THRESHOLDS_PKG.delete_row';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

  -- Delete Role
     PA_PERF_THRESHOLDS_PKG.DELETE_ROW
     (X_THRESHOLD_ID => P_THRESHOLD_ID);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_THRESHOLDS_PVT.delete_rule_det';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;

  -- Reset the Error Stack
     PA_DEBUG.reset_err_stack;

EXCEPTION
     WHEN Invalid_Ret_Status THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 l_msg_count := FND_MSG_PUB.count_msg;

	 IF l_msg_count = 1 and x_msg_data IS NULL THEN
	    PA_INTERFACE_UTILS_PUB.get_messages
	    ( p_encoded        => FND_API.G_TRUE
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

	 IF l_debug_mode = 'Y' THEN
	    pa_debug.reset_curr_function;
	 END IF;

	 rollback to sp;
	 RETURN;

     WHEN OTHERS THEN
         x_msg_count := 1;
         x_msg_data  := substr(SQLERRM,1,240);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.add_exc_msg
         (  p_pkg_name => 'PA_PERF_THRESHOLDS_PVT'
          , p_procedure_name => PA_DEBUG.G_Err_Stack
          , p_error_text => substr(SQLERRM,1,240));

	 rollback to sp;
         RAISE;

END delete_rule_det;



END PA_PERF_THRESHOLDS_PVT;

/
