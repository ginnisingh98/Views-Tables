--------------------------------------------------------
--  DDL for Package Body PA_PERF_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_RULES_PUB" AS
/* $Header: PAPERLPB.pls 120.1 2005/08/19 16:39:26 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_perf_rules_pub';

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
Invalid_Ret_Status        EXCEPTION;
l_msg_count               NUMBER := 0;
l_data                    VARCHAR2(2000);
l_msg_data                VARCHAR2(2000);
l_msg_index_out           NUMBER;
l_return_status           VARCHAR2(1);
l_debug_mode              VARCHAR2(1);
l_rowid                   VARCHAR2(255);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN

     -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PUB.create_rule');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PUB.create_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_RULES_PUB.create_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;


     PA_PERF_RULES_PVT.create_rule(
      P_RULE_ID => P_RULE_ID,
      P_RULE_NAME => P_RULE_NAME,
      P_RULE_DESCRIPTION => P_RULE_DESCRIPTION,
      P_RULE_TYPE => P_RULE_TYPE,
      P_KPA_CODE => P_KPA_CODE,
      P_MEASURE_ID => P_MEASURE_ID,
      P_MEASURE_FORMAT => P_MEASURE_FORMAT,
      P_CURRENCY_TYPE => P_CURRENCY_TYPE,
      P_PERIOD_TYPE => P_PERIOD_TYPE,
      P_PRECISION => P_PRECISION,
      P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
      P_SCORE_METHOD => P_SCORE_METHOD,
      P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
      P_CREATION_DATE => P_CREATION_DATE,
      P_CREATED_BY   => P_CREATED_BY,
      P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN ,
      X_RETURN_STATUS => l_return_status,
      X_MSG_COUNT  => l_msg_count,
      X_MSG_DATA  => l_msg_data );


     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_RULES_PUB.create_rule';
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

   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg(
       p_pkg_name        => 'PA_PERF_RULES_PUB'
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
l_return_status           VARCHAR2(1);
l_debug_mode              VARCHAR2(1);
l_rowid                   VARCHAR2(255);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN

  savepoint sp;
  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PUB.Update_Rule');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PUB.update_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_RULES_PUB.update_rule';
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
	pa_debug.g_err_stage:= 'about to call PA_PER_RULES_PVT.UPDATE_RULE';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

     PA_PERF_RULES_PVT.UPDATE_RULE(
       P_RULE_ID => P_RULE_ID,
       P_RULE_NAME => P_RULE_NAME,
       P_RULE_DESCRIPTION => P_RULE_DESCRIPTION,
       P_RULE_TYPE => P_RULE_TYPE,
       P_KPA_CODE => P_KPA_CODE,
       P_MEASURE_ID => P_MEASURE_ID,
       P_MEASURE_FORMAT => P_MEASURE_FORMAT,
       P_CURRENCY_TYPE => P_CURRENCY_TYPE,
       P_PERIOD_TYPE => P_PERIOD_TYPE,
       P_PRECISION => P_PRECISION,
       P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
       P_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
       P_SCORE_METHOD => P_SCORE_METHOD,
       P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
       P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
       P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
       P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
       X_RETURN_STATUS => l_return_status,
       X_MSG_COUNT  => l_msg_count,
       X_MSG_DATA  => l_msg_data );

     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_RULES_PUB.update_rule';
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
	  p_pkg_name => 'PA_PERF_RULES_PUB'
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
l_msg_index_out NUMBER;
l_return_status           VARCHAR2(1);
l_debug_mode                    VARCHAR2(1);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN
  savepoint sp;


  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PUB.Delete_Rule');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PUB.delete_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_RULES_PUB.delete_rule';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
          pa_debug.g_err_stage:= 'P_RULE_ID = '|| P_RULE_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level5);
     END IF;


     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call PA_PERF_RULES_PVT.delete_rule';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

  -- Delete Role
     PA_PERF_RULES_PVT.DELETE_RULE
     ( P_RULE_ID         =>  P_RULE_ID,
       P_RECORD_VERSION_NUMBER  => P_RECORD_VERSION_NUMBER,
       X_RETURN_STATUS => l_return_status,
       X_MSG_COUNT  => l_msg_count,
       X_MSG_DATA  => l_msg_data );

     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_RULES_PUB.delete_rule';
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
         (  p_pkg_name => 'PA_PERF_RULES_PUB'
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
  X_MSG_DATA              OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
  P_WEIGHTING             IN     SYSTEM.PA_NUM_TBL_TYPE   )
  IS
  l_debug_mode VARCHAR2(1);
  l_RETURN_STATUS       VARCHAR2(1);
  l_MSG_COUNT           NUMBER;
  l_MSG_DATA            VARCHAR2(2000);

  BEGIN

  FND_MSG_PUB.initialize;

    -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_RULES_PUB.validate_rule');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_RULES_PUB.validate_rule',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call PA_PERF_RULES_PVT.validate_rule';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   3);
     END IF;

     PA_PERF_RULES_PVT.validate_rule(
      P_RULE_ID	            =>     P_RULE_ID	       ,
      P_RULE_NAME	            =>     P_RULE_NAME	 ,
      P_RULE_TYPE             =>     P_RULE_TYPE       ,
      P_PRECISION             =>     P_PRECISION       ,
      P_START_DATE_ACTIVE     =>     P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE       =>     P_END_DATE_ACTIVE  ,
      P_THRESHOLD_ID          =>     P_THRESHOLD_ID     ,
      P_THRES_OBJ_ID          =>     P_THRES_OBJ_ID     ,
      P_FROM_VALUE            =>     P_FROM_VALUE       ,
      P_TO_VALUE              =>     P_TO_VALUE         ,
      P_INDICATOR_CODE        =>     P_INDICATOR_CODE   ,
      X_RETURN_STATUS         =>     l_RETURN_STATUS    ,
      X_MSG_COUNT             =>     l_MSG_COUNT        ,
      X_MSG_DATA              =>     l_MSG_DATA        ,
      P_WEIGHTING             =>     P_WEIGHTING );

      X_RETURN_STATUS     :=   l_RETURN_STATUS  ;
      X_MSG_COUNT         :=   l_MSG_COUNT      ;
      X_MSG_DATA          :=   l_MSG_DATA       ;

END validate_rule;
END PA_PERF_RULES_PUB;

/
