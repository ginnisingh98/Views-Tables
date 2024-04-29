--------------------------------------------------------
--  DDL for Package Body PA_PERF_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_RULES_PVT" AS
/* $Header: PAPERLVB.pls 120.1 2005/08/19 16:39:43 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_perf_rules_pvt';

/*==================================================================
  PROCEDURE
      create_rule
  PURPOSE
      This procedure inserts a row into the pa_perf_rules table.
 ==================================================================*/


PROCEDURE create_rule(
  P_RULE_ID	          IN NUMBER,
  P_RULE_NAME	          IN VARCHAR2,
  P_RULE_DESCRIPTION      IN VARCHAR2,
  P_RULE_TYPE             IN VARCHAR2,
  P_KPA_CODE              IN VARCHAR2,
  P_MEASURE_ID            IN NUMBER,
  P_MEASURE_FORMAT        IN VARCHAR2,
  P_CURRENCY_TYPE         IN VARCHAR2,
  P_PERIOD_TYPE           IN VARCHAR2,
  P_PRECISION             IN NUMBER,
  P_START_DATE_ACTIVE     IN DATE,
  P_END_DATE_ACTIVE       IN DATE,
  P_SCORE_METHOD          IN VARCHAR2,
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
dummy                     NUMBER;
duplicate_name EXCEPTION;

 CURSOR CHECK_RULE_NAME IS
  SELECT 1
    FROM PA_PERF_RULES     --Changed to PA_PERF_RULES from PA_PERF_RULES_V for Bug# 3639469
  WHERE RULE_NAME=P_RULE_NAME
  AND RULE_TYPE = P_RULE_TYPE;    -- Added for Bug 4199228

BEGIN

  savepoint sp;
     -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PVT.create_rule');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PVT.create_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_RULES_PVT.create_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'about to check if the name is duplicate';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                          l_debug_level3);
     END IF;

     OPEN CHECK_RULE_NAME;
    FETCH CHECK_RULE_NAME INTO dummy;
       IF CHECK_RULE_NAME % FOUND THEN
          RAISE duplicate_name;
       END IF;
    CLOSE CHECK_RULE_NAME;

     PA_PERF_RULES_PKG.insert_row(
        X_ROWID => l_rowid,
        X_RULE_ID => P_RULE_ID,
        X_RULE_NAME => P_RULE_NAME,
        X_RULE_DESCRIPTION => P_RULE_DESCRIPTION,
        X_RULE_TYPE => P_RULE_TYPE,
        X_KPA_CODE => P_KPA_CODE,
        X_MEASURE_ID => P_MEASURE_ID,
        X_MEASURE_FORMAT => P_MEASURE_FORMAT,
        X_CURRENCY_TYPE => P_CURRENCY_TYPE,
        X_PERIOD_TYPE => P_PERIOD_TYPE,
        X_PRECISION => P_PRECISION,
        X_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
        X_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
        X_SCORE_METHOD => P_SCORE_METHOD,
        X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
        X_CREATION_DATE => P_CREATION_DATE,
        X_CREATED_BY => P_CREATED_BY,
        X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN
     );

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_RULES_PVT.create_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;

     -- Reset the Error Stack
     PA_DEBUG.reset_err_stack;


EXCEPTION
   WHEN duplicate_name THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

	 PA_UTILS.ADD_MESSAGE
	         ( p_app_short_name => 'PA',
		  p_msg_name       => 'PA_NAME_UNIQUE');


        x_msg_count := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
        END IF;

        rollback to sp;
        RETURN;

   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg(
       p_pkg_name        => 'PA_PERF_RULES_PVT'
      ,p_procedure_name  => 'CREATE_RULE'
      ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error: '||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
      END IF;
      RAISE;
END CREATE_RULE;

/*==================================================================
  PROCEDURE
      update_rule
  PURPOSE
      This procedure updates a row into the pa_perf_rules table.
 ==================================================================*/

PROCEDURE update_rule(
  P_RULE_ID	          IN NUMBER,
  P_RULE_NAME	          IN VARCHAR2,
  P_RULE_DESCRIPTION      IN VARCHAR2,
  P_RULE_TYPE             IN VARCHAR2,
  P_KPA_CODE              IN VARCHAR2,
  P_MEASURE_ID            IN NUMBER,
  P_MEASURE_FORMAT        IN VARCHAR2,
  P_CURRENCY_TYPE         IN VARCHAR2,
  P_PERIOD_TYPE           IN VARCHAR2,
  P_PRECISION             IN NUMBER,
  P_START_DATE_ACTIVE     IN DATE,
  P_END_DATE_ACTIVE       IN DATE,
  P_SCORE_METHOD          IN VARCHAR2,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_LAST_UPDATE_DATE      IN DATE,
  P_LAST_UPDATED_BY       IN NUMBER,
  P_LAST_UPDATE_LOGIN     IN NUMBER,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
Invalid_Ret_Status EXCEPTION;
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
dummy                     NUMBER;
duplicate_name EXCEPTION;

 CURSOR CHECK_RULE_NAME IS
  SELECT 1
    FROM PA_PERF_RULES    --Changed to PA_PERF_RULES from PA_PERF_RULES_V for Bug# 3639469
  WHERE RULE_NAME=P_RULE_NAME
    AND RULE_ID <> P_RULE_ID
    AND RULE_TYPE = P_RULE_TYPE;    -- Added for Bug 4199228

BEGIN

  savepoint sp;
  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PVT.Update_Rule');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PVT.update_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_RULES_PVT.update_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

	  pa_debug.g_err_stage:= 'P_RULE_ID = '|| P_RULE_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level5);

	  pa_debug.g_err_stage:= 'P_RULE_TYPE = '|| P_RULE_TYPE;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
	  pa_debug.g_err_stage:= 'P_RULE_NAME = '|| P_RULE_NAME;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to check if the name is duplicate';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                          l_debug_level3);
     END IF;

     OPEN CHECK_RULE_NAME;
    FETCH CHECK_RULE_NAME INTO dummy;
       IF CHECK_RULE_NAME % FOUND THEN
          RAISE duplicate_name;
       END IF;
    CLOSE CHECK_RULE_NAME;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call lock row method';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                          l_debug_level3);
     END IF;

     PA_PERF_RULES_PKG.LOCK_ROW (
	X_RULE_ID => P_RULE_ID,
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
	pa_debug.g_err_stage:= 'about to call PA_PERF_RULES_PKG.UPDATE_ROW';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

     PA_PERF_RULES_PKG.UPDATE_ROW(
       X_RULE_ID => P_RULE_ID,
       X_RULE_NAME => P_RULE_NAME,
       X_RULE_DESCRIPTION => P_RULE_DESCRIPTION,
       X_RULE_TYPE => P_RULE_TYPE,
       X_KPA_CODE => P_KPA_CODE,
       X_MEASURE_ID => P_MEASURE_ID,
       X_MEASURE_FORMAT => P_MEASURE_FORMAT,
       X_CURRENCY_TYPE => P_CURRENCY_TYPE,
       X_PERIOD_TYPE => P_PERIOD_TYPE,
       X_PRECISION => P_PRECISION,
       X_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
       X_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
       X_SCORE_METHOD => P_SCORE_METHOD,
       X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
       X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN );

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_RULES_PVT.update_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;

     -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

EXCEPTION

   WHEN duplicate_name THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

         PA_UTILS.ADD_MESSAGE
                 ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_NAME_UNIQUE');

        x_msg_count := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
        END IF;

        rollback to sp;
        RETURN;

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
	  p_pkg_name => 'PA_PERF_RULES_PVT'
        , p_procedure_name => PA_DEBUG.G_Err_Stack
        , p_error_text => substr(SQLERRM,1,240));

	rollback to sp;
        RAISE;

END update_rule;

/*==================================================================
  PROCEDURE
      delete_rule
  PURPOSE
      This procedure deletes a row from the pa_perf_rules table.
 ==================================================================*/

PROCEDURE delete_rule (
 P_RULE_ID                IN         NUMBER,
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
l_return_status VARCHAR2(1);
l_msg_index_out NUMBER;
l_debug_mode                    VARCHAR2(1);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;
l_rule_name     VARCHAR2(2000);

CURSOR cur_threshold( rule_id_par NUMBER)
IS
  SELECT threshold_id, record_version_number
  FROM pa_perf_thresholds
  WHERE thres_obj_id= rule_id_par;

CURSOR cur_obj_rule( rule_id_par NUMBER)
IS
  SELECT object_rule_id ,record_version_number
  FROM pa_perf_object_rules
  WHERE rule_id = rule_id_par;

BEGIN
  savepoint sp;


  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PVT.Delete_Row');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PVT.delete_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_RULES_PVT.delete_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
          pa_debug.g_err_stage:= 'P_RULE_ID = '|| P_RULE_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level5);

	  pa_debug.g_err_stage:= 'about to call lock row method';
	  pa_debug.write(g_module_name,pa_debug.g_err_stage,
                            l_debug_level3);
     END IF;

     PA_PERF_RULES_PKG.LOCK_ROW
     (
	X_RULE_ID => P_RULE_ID,
	X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER
     );

     l_msg_count := FND_MSG_PUB.count_msg;
     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call PA_PERF_RULES_PKG.delete_row';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;


  FOR cur_var IN cur_threshold( p_rule_id )
  LOOP
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_count := 0;
    l_msg_data :=  NULL;
    PA_PERF_THRESHOLDS_PVT.delete_rule_det (
        P_THRESHOLD_ID          => cur_var.threshold_id,
        P_RECORD_VERSION_NUMBER => cur_var.record_version_number,
        X_RETURN_STATUS         => l_return_status,
        X_MSG_COUNT             => l_msg_count,
        X_MSG_DATA              => l_msg_data );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to delete the Rule Threshold, Threshold_id : '|| cur_var.threshold_id;
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;
     Raise Invalid_Ret_Status;
   end if;

  END LOOP;

  FOR cur_var IN cur_obj_rule( p_rule_id )
  LOOP
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_count := 0;
    l_msg_data :=  NULL;
    PA_PERF_OBJECT_RULES_PVT.delete_rule_object (
        P_OBJECT_RULE_ID        => cur_var.object_rule_id,
        P_RECORD_VERSION_NUMBER => cur_var.record_version_number,
        X_RETURN_STATUS         => l_return_status,
        X_MSG_COUNT             => l_msg_count,
        X_MSG_DATA              => l_msg_data,
        X_RULE_NAME             => l_rule_name );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to delete the Rule Object Association, object_rule_id : '|| cur_var.object_rule_id;
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;
     Raise Invalid_Ret_Status;
   end if;

  END LOOP;

  -- Delete Rule
     PA_PERF_RULES_PKG.DELETE_ROW
     ( X_RULE_ID         =>  P_RULE_ID);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_RULES_PVT.delete_rule';
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
         (  p_pkg_name => 'PA_PERF_RULES_PVT'
          , p_procedure_name => PA_DEBUG.G_Err_Stack
          , p_error_text => substr(SQLERRM,1,240));

	 rollback to sp;
         RAISE;

END delete_rule;

 /*==================================================================
  PROCEDURE
      validate_rule
  PURPOSE
      This procedure validates the performance rule to be inserted .
 ==================================================================*/
PROCEDURE validate_rule(
  P_RULE_ID	              IN     NUMBER,
  P_RULE_NAME	        IN     VARCHAR2,
  P_RULE_TYPE             IN     VARCHAR2,
  P_PRECISION             IN     NUMBER,
  P_START_DATE_ACTIVE     IN     DATE,
  P_END_DATE_ACTIVE       IN     DATE,
  P_THRESHOLD_ID          IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_THRES_OBJ_ID          IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_FROM_VALUE            IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_TO_VALUE              IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_INDICATOR_CODE        IN     SYSTEM.pa_varchar2_30_tbl_type,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_WEIGHTING             IN     SYSTEM.PA_NUM_TBL_TYPE   )
  IS
  j  NUMBER;
  k  NUMBER;
  l_check_precission  VARCHAR2(1) := 'N' ;
  l_check_from_to_value VARCHAR2(1) := 'N' ;
  l_indicator_code   VARCHAR2(1) := 'N' ;
  l_check_range      VARCHAR2(1) := 'N' ;
  l_check_weighting  VARCHAR2(1) := 'N';
  l_check_threshold  VARCHAR2(1) := 'N';
  l_debug_mode VARCHAR2(1);
  BEGIN

    -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PVT.validate_rule');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PVT.validate_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

  k :=  P_THRESHOLD_ID.count; /* Get the number of lines */

  IF (P_END_DATE_ACTIVE IS NOT NULL) THEN
      IF (trunc(P_START_DATE_ACTIVE) >= trunc(P_END_DATE_ACTIVE))   THEN
           PA_UTILS.ADD_MESSAGE
	        ( p_app_short_name => 'PA',
		  p_msg_name       => 'PA_SETUP_CHK_ST_EN_DATE');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
       END IF;
   END IF;

   FOR i in  P_FROM_VALUE.FIRST..P_FROM_VALUE.LAST
   LOOP

     /*  Checking the precision of the thresholds defined for this rule */

       IF ((length(abs(P_FROM_VALUE(i)-trunc(P_FROM_VALUE(i)))) - length(abs(P_PRECISION-trunc(P_PRECISION)))) > 0
            OR (length(abs(P_TO_VALUE(i)-trunc(P_TO_VALUE(i)))) - length(abs(P_PRECISION-trunc(P_PRECISION)))) > 0) then

                l_check_precission := 'Y' ;

        END IF;

  /*  Checking the FROM TO values of the thresholds defined for this rule */

        IF (P_FROM_VALUE(i)>=P_TO_VALUE(i)) THEN
               l_check_from_to_value := 'Y';
        END IF;

  /*  Checking the Indicator codes of the thresholds defined for this rule */
         IF (P_RULE_TYPE = 'SCORE_RULE' ) THEN
             j :=i+1;
                while(j <= k)  LOOP
                  IF ( P_INDICATOR_CODE(i) = P_INDICATOR_CODE(j)) THEN
                           l_indicator_code := 'Y';
                  END IF;
                  j := j+1;
              END LOOP;
          END IF;
  /*  Checking that the range of the thresholds do not overlap */
            j := i+1;
            while (j<=k) LOOP
              IF NOT (((P_FROM_VALUE(i) <P_FROM_VALUE(j)) AND(P_TO_VALUE(i) <P_FROM_VALUE(j)))OR ((P_FROM_VALUE(i) >P_TO_VALUE(j)) AND(P_TO_VALUE(i) >P_TO_VALUE(j)))) THEN
                l_check_range := 'Y';
              END IF;
               j := j+1;
             END LOOP;

	  IF (P_RULE_TYPE = 'PERF_RULE' ) THEN
            IF (P_WEIGHTING(i) <0) THEN
                  l_check_weighting := 'Y' ;
            END IF;
          END IF;

	  IF (P_RULE_TYPE = 'SCORE_RULE' ) THEN
            IF ((P_FROM_VALUE(i) <0) OR (P_TO_VALUE(i) <0)) THEN
                  l_check_threshold := 'Y' ;
            END IF;
          END IF;
   END LOOP;

   IF (l_check_precission = 'Y') THEN
         PA_UTILS.ADD_MESSAGE
	     ( p_app_short_name => 'PA',
		 p_msg_name       => 'PA_THRES_PRECISION_CHECK');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
    END IF ;

   IF (l_check_from_to_value = 'Y') THEN
         PA_UTILS.ADD_MESSAGE
	     ( p_app_short_name => 'PA',
		 p_msg_name       => 'PA_THRESH_FROM_TO_VALUE');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
    END IF ;

    IF (l_indicator_code = 'Y') THEN
         PA_UTILS.ADD_MESSAGE
	     ( p_app_short_name => 'PA',
		 p_msg_name       => 'PA_INDICATOR_UNIQUE');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
     END IF ;

    IF (l_check_range = 'Y') THEN
         PA_UTILS.ADD_MESSAGE
	     ( p_app_short_name => 'PA',
		 p_msg_name       => 'PA_THRES_RANGE_CHECK');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
    END IF ;


    IF (l_check_weighting = 'Y') THEN
         PA_UTILS.ADD_MESSAGE
	     ( p_app_short_name => 'PA',
	       p_msg_name       => 'PA_NEGATIVE_WEIGHTING');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
     END IF ;


    IF (l_check_threshold = 'Y') THEN
         PA_UTILS.ADD_MESSAGE
	     ( p_app_short_name => 'PA',
	       p_msg_name       => 'PA_THRESHOLD_NEGATIVE');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := FND_MSG_PUB.count_msg;
     END IF ;

 END validate_rule;

END PA_PERF_RULES_PVT;

/
