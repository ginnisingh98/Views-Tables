--------------------------------------------------------
--  DDL for Package Body PA_PERF_OBJECT_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_OBJECT_RULES_PUB" AS
/* $Header: PAPEORPB.pls 120.1 2005/08/19 16:39:00 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_perf_object_rules_pub';

/*==================================================================
  PROCEDURE
      create_rule_object
  PURPOSE
      This procedure inserts a row into the pa_perf_object_rules table.
 ==================================================================*/


PROCEDURE create_rule_object(
  P_OBJECT_RULE_ID        IN NUMBER,
  P_OBJECT_TYPE           IN VARCHAR2,
  P_OBJECT_ID             IN NUMBER,
  P_RULE_ID               IN NUMBER,
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
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN
     -- set the savepoint
        savepoint sp;
         FND_MSG_PUB.initialize;
     -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_OBJECT_RULES_PUB.create_rule_object');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_OBJECT_RULES_PUB.create_rule_object',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_OBJECT_RULES_PUB.create_rule_object';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;


     PA_PERF_OBJECT_RULES_PVT.create_rule_object(
      P_OBJECT_RULE_ID => P_OBJECT_RULE_ID,
      P_OBJECT_TYPE => P_OBJECT_TYPE,
      P_OBJECT_ID => P_OBJECT_ID,
      P_RULE_ID => P_RULE_ID,
      P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
      P_CREATION_DATE => P_CREATION_DATE,
      P_CREATED_BY   => P_CREATED_BY,
      P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN ,
      X_RETURN_STATUS => l_return_status,
      X_MSG_COUNT  => l_msg_count,
      X_MSG_DATA  => l_msg_data );

     if(l_return_status<>'S') then
        Raise Invalid_Ret_Status;
     else
        X_RETURN_STATUS :=l_return_status;
        X_MSG_COUNT := l_msg_count;
     end if;
/* The message count will be <> 0 when there is amother rule with the same measure and different calendar .
   But we should not raise error in that case .So checking for the return status instead . */
/*     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if; */


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_OBJECT_RULES_PUB.create_rule_object';
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
       p_pkg_name        => 'PA_PERF_OBJECT_RULES_PUB'
      ,p_procedure_name  => 'CREATE_RULE_OBJECT'
      ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error: '||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
      END IF;
      RAISE;
END create_rule_object;

/*==================================================================
  PROCEDURE
      update_rule_object
  PURPOSE
      This procedure updates a row in the pa_perf_object_rules table.
 ==================================================================*/


PROCEDURE update_rule_object(
  P_OBJECT_RULE_ID        IN NUMBER,
  P_OBJECT_TYPE           IN VARCHAR2,
  P_OBJECT_ID             IN NUMBER,
  P_RULE_ID               IN NUMBER,
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
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN
     -- set the savepoint
        savepoint sp;
         FND_MSG_PUB.initialize;
     -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_OBJECT_RULES_PUB.update_rule_object');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_OBJECT_RULES_PUB.update_rule_object',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_OBJECT_RULES_PUB.update_rule_object';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;


     PA_PERF_OBJECT_RULES_PVT.update_rule_object(
      P_OBJECT_RULE_ID => P_OBJECT_RULE_ID,
      P_OBJECT_TYPE => P_OBJECT_TYPE,
      P_OBJECT_ID => P_OBJECT_ID,
      P_RULE_ID => P_RULE_ID,
      P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
      P_CREATION_DATE => P_CREATION_DATE,
      P_CREATED_BY   => P_CREATED_BY,
      P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN ,
      X_RETURN_STATUS => l_return_status,
      X_MSG_COUNT  => l_msg_count,
      X_MSG_DATA  => l_msg_data );

     if(l_return_status<>'S') then
        Raise Invalid_Ret_Status;
     else
        X_RETURN_STATUS :=l_return_status;
        X_MSG_COUNT := l_msg_count;
     end if;
/* The message count will be <> 0 when there is amother rule with the same measure and different calendar .
   But we should not raise error in that case .So checking for the return status instead . */
/*     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if; */


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_OBJECT_RULES_PUB.update_rule_object';
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
       p_pkg_name        => 'PA_PERF_OBJECT_RULES_PUB'
      ,p_procedure_name  => 'UPDATE_RULE_OBJECT'
      ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error: '||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
      END IF;
      RAISE;
END update_rule_object;

/*==================================================================
  PROCEDURE
      delete_rule_object
  PURPOSE
      This procedure deletes a row from the pa_perf_object_rules table.
 ==================================================================*/

PROCEDURE delete_rule_object (
 P_OBJECT_RULE_ID         IN         NUMBER,
 P_RECORD_VERSION_NUMBER  IN         NUMBER,
 X_RETURN_STATUS          OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT              OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA               OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_RULE_NAME              OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
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


         FND_MSG_PUB.initialize;
  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_OBJECT_RULES_PUB.delete_rule_object');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_OBJECT_RULES_PUB.delete_rule_object',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_OBJECT_RULES_PUB.delete_rule_object';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
          pa_debug.g_err_stage:= 'P_OBJECT_RULE_ID = '|| P_OBJECT_RULE_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level5);
     END IF;


     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call PA_PERF_OBJECT_RULES_PVT.delete_rule_object';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

  -- Delete Role
     PA_PERF_OBJECT_RULES_PVT.delete_rule_object
     ( P_OBJECT_RULE_ID    =>  P_OBJECT_RULE_ID,
       P_RECORD_VERSION_NUMBER  => P_RECORD_VERSION_NUMBER,
       X_RETURN_STATUS => l_return_status,
       X_MSG_COUNT  => l_msg_count,
       X_MSG_DATA  => l_msg_data,
       X_RULE_NAME => X_RULE_NAME);

     if(l_msg_count<>0) then
	Raise Invalid_Ret_Status;
     end if;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_OBJECT_RULES_PUB.delete_rule_object';
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
         (  p_pkg_name => 'PA_PERF_OBJECT_RULES_PUB'
          , p_procedure_name => PA_DEBUG.G_Err_Stack
          , p_error_text => substr(SQLERRM,1,240));

	 rollback to sp;
         RAISE;

END delete_rule_object;

/*==================================================================
  PROCEDURE
      validate_rule_object
  PURPOSE
      This procedure Checks the rules associated with a project .
 ==================================================================*/

PROCEDURE validate_rule_object
                  (P_OBJECT_ID       IN         NUMBER,
                   P_OBJECT_TYPE     IN         VARCHAR2,
                   X_RETURN_STATUS   OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   X_MSG_COUNT       OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
                   X_MSG_DATA        OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

BEGIN

     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     PA_PERF_OBJECT_RULES_PVT.validate_rule_object
                  (P_OBJECT_ID      => P_OBJECT_ID ,
                   P_OBJECT_TYPE    => P_OBJECT_TYPE,
                   X_RETURN_STATUS  => X_RETURN_STATUS   ,
                   X_MSG_COUNT      => X_MSG_COUNT ,
                   X_MSG_DATA       => X_MSG_DATA   );

END VALIDATE_RULE_OBJECT;

END PA_PERF_OBJECT_RULES_PUB;

/
