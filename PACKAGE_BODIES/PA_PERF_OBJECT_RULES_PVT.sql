--------------------------------------------------------
--  DDL for Package Body PA_PERF_OBJECT_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_OBJECT_RULES_PVT" AS
/* $Header: PAPEORVB.pls 120.1 2005/08/19 16:39:14 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_perf_object_rules_pvt';

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
     PA_DEBUG.init_err_stack('PA_PERF_OBJECT_RULES_PVT.create_rule_object');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_OBJECT_RULES_PVT.create_rule_object',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_OBJECT_RULES_PVT.create_rule_object';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Going to check if the rule has already been associated to this project';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     DECLARE
           dummy number;
     BEGIN
           SELECT object_rule_id
             INTO dummy
             FROM pa_perf_object_rules
            WHERE object_id = P_OBJECT_ID
              AND rule_id = P_RULE_ID;

            RETURN;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
       END;
     -- See if there is a record with the same measure format and period type

       -- See if there is a record with the same measure but different period type
/*
         DECLARE
           dummy number ;
         BEGIN
              SELECT 1
                INTO dummy
                FROM PA_PERF_RULES_V perfrule
               WHERE perfrule.rule_id = P_RULE_ID
                 AND (perfrule.measure_name,perfrule.period_type) in (
                                                   SELECT objrule.measure_name,objrule.period_type
                                                     FROM PA_PERF_OBJECT_RULES_V objrule
                                                    WHERE objrule.object_id = P_OBJECT_ID ) ;
              PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_EXCP_PROJ_DUP_MEASURE_CAL');
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_msg_count     := 1;
              return;
          EXCEPTION
            WHEN OTHERS  THEN
                   NULL;
          END;

         DECLARE
           dummy number ;
         BEGIN
              SELECT 1
                INTO dummy
                FROM PA_PERF_RULES_v perfrule
               WHERE perfrule.rule_id = P_RULE_ID
                 AND perfrule.measure_name in (
                                                   SELECT objrule.measure_name
                                                     FROM PA_PERF_OBJECT_RULES_V objrule
                                                    WHERE objrule.object_id = P_OBJECT_ID ) ;
              PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_EXCP_PROJ_RULE_DUP_MEASURE');

              x_msg_count     := 1;
          EXCEPTION
            WHEN OTHERS  THEN
                   NULL;
          END;
*/

     PA_PERF_OBJECT_RULES_PKG.insert_row(
        X_ROWID => l_rowid,
        X_OBJECT_RULE_ID => P_OBJECT_RULE_ID,
        X_OBJECT_TYPE => P_OBJECT_TYPE,
        X_OBJECT_ID => P_OBJECT_ID,
        X_RULE_ID => P_RULE_ID,
        X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
        X_CREATION_DATE => P_CREATION_DATE,
        X_CREATED_BY => P_CREATED_BY,
        X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN
     );

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_OBJECT_RULES_PVT.create_rule_object';
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
       p_pkg_name        => 'PA_PERF_OBJECT_RULES_PVT'
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

BEGIN

  savepoint sp;
  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_OBJECT_RULES_PVT.update_rule_object');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_OBJECT_RULES_PVT.update_rule_object',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_OBJECT_RULES_PVT.update_rule_object';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

	  pa_debug.g_err_stage:= 'P_OBJECT_RULE_ID = '|| P_OBJECT_RULE_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level5);

	  pa_debug.g_err_stage:= 'P_OBJECT_TYPE = '|| P_OBJECT_TYPE;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
	  pa_debug.g_err_stage:= 'P_OBJECT_ID  = '|| P_OBJECT_ID ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
	  pa_debug.g_err_stage:= 'P_RULE_ID   = '|| P_RULE_ID  ;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;

     IF l_debug_mode = 'Y' THEN
	pa_debug.g_err_stage:= 'about to call lock row method';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                          l_debug_level3);
     END IF;

     PA_PERF_OBJECT_RULES_PKG.LOCK_ROW
     (X_OBJECT_RULE_ID => P_OBJECT_RULE_ID,
      X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER ) ;

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
	pa_debug.g_err_stage:= 'about to call PA_PERF_RULES_PKG.update_rule_object';
	pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

     PA_PERF_OBJECT_RULES_PKG.UPDATE_ROW(
     X_OBJECT_RULE_ID => P_OBJECT_RULE_ID,
     X_OBJECT_TYPE => P_OBJECT_TYPE,
     X_OBJECT_ID => P_OBJECT_ID,
     X_RULE_ID => P_RULE_ID,
     X_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
     X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN );

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_OBJECT_RULES_PVT.update_rule_object';
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
	  p_pkg_name => 'PA_PERF_OBJECT_RULES_PVT'
        , p_procedure_name => PA_DEBUG.G_Err_Stack
        , p_error_text => substr(SQLERRM,1,240));

	rollback to sp;
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
l_debug_mode                    VARCHAR2(1);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN
  savepoint sp;


  -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_OBJECT_RULES_PVT.Delete_Rule_object');
     x_msg_count := 0;
     x_msg_data  := NULL;

  -- Initialize the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_OBJECT_RULES_PVT.Delete_Rule_object',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_OBJECT_RULES_PVT.Delete_Rule_object';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
          pa_debug.g_err_stage:= 'P_OBJECT_RULE_ID = '|| P_OBJECT_RULE_ID;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level5);

	  pa_debug.g_err_stage:= 'about to call lock row method';
	  pa_debug.write(g_module_name,pa_debug.g_err_stage,
                            l_debug_level3);
     END IF;

     BEGIN
      SELECT RULE_NAME
        INTO X_RULE_NAME
        FROM PA_PERF_RULES
       WHERE RULE_ID=(SELECT RULE_ID
                        FROM PA_PERF_OBJECT_RULES
                       WHERE OBJECT_RULE_ID=P_OBJECT_RULE_ID);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
	        NULL;
      END;

     PA_PERF_OBJECT_RULES_PKG.LOCK_ROW
     (
	X_OBJECT_RULE_ID => P_OBJECT_RULE_ID,
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
     PA_PERF_OBJECT_RULES_PKG.DELETE_ROW
     (X_OBJECT_RULE_ID => P_OBJECT_RULE_ID);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_OBJECT_RULES_PVT.Delete_Rule_object';
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
         (  p_pkg_name => 'PA_PERF_OBJECT_RULES_PVT'
          , p_procedure_name => PA_DEBUG.G_Err_Stack
          , p_error_text => substr(SQLERRM,1,240));

	 rollback to sp;
         RAISE;

END Delete_Rule_object;

PROCEDURE validate_rule_object
                  (P_OBJECT_ID       IN         NUMBER,
                   P_OBJECT_TYPE     IN         VARCHAR2,
                   X_RETURN_STATUS   OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   X_MSG_COUNT       OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
                   X_MSG_DATA        OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
	CURSOR RULES_IN_ERROR IS
	SELECT objrule.measure_name,objrule.period_type,count(*),
	       objrule.measure_id  --Added for the bug# 3639474
	   FROM PA_PERF_OBJECT_RULES_V objrule
	  WHERE objrule.object_id = P_OBJECT_ID
            AND objrule.rule_type='PERF_RULE'
	  GROUP BY objrule.measure_name,objrule.period_type, objrule.measure_id
	  HAVING count(*) >1;

        CURSOR RULE_NAMES_IN_ERROR (l_measure_id IN NUMBER ,l_period_type IN VARCHAR2 ) IS --Changed the parameter l_measure_name VARCHAR2 to l_measure_id NUMBER for bug# 3639474
        SELECT objrule.RULE_NAME
          FROM PA_PERF_OBJECT_RULES_V objrule
         WHERE objrule.object_id = P_OBJECT_ID
           --AND objrule.measure_name = l_measure_name --commented for the bug# 3639474
	   AND objrule.measure_id = l_measure_id --Added for the bug# 3639474
           AND objrule.period_type =l_period_type;

        CURSOR RULES_IN_WARNING IS
        SELECT objrule.measure_name,count(*),
	       objrule.measure_id ----Added for the bug# 3639474
           FROM PA_PERF_OBJECT_RULES_V objrule
          WHERE objrule.object_id = P_OBJECT_ID
            AND objrule.rule_type='PERF_RULE'
            AND EXISTS (select 1 from PA_PERF_OBJECT_RULES rule
                         where rule.record_version_number = 1      -- Changed hardcoded value from 2 to 1
                           and rule.rule_id in (select rule_id from PA_PERF_OBJECT_RULES_V objrule1
                                                 where objrule1.rule_id = rule.rule_id
                                                   and objrule1.measure_name=objrule.measure_name)
                           and rule.object_id=P_OBJECT_ID)
          GROUP BY objrule.measure_name, objrule.measure_id
          HAVING count(*) >1;

        CURSOR RULE_NAMES_IN_WARNING (l_measure_id IN NUMBER ) IS --Changed the parameter l_measure_name VARCHAR2 to l_measure_id NUMBER for bug# 3639474
        SELECT objrule.RULE_NAME
          FROM PA_PERF_OBJECT_RULES_V objrule
         WHERE objrule.object_id = P_OBJECT_ID
           --AND objrule.measure_name = l_measure_name; --commented for the bug# 3639474
	   AND objrule.measure_id = l_measure_id; --Added for the bug# 3639474

         l_rules_in_error RULES_IN_ERROR%ROWTYPE;
         l_rules_in_warning RULES_IN_WARNING%ROWTYPE;

l_message_code VARCHAR2(2000);
l_rule_name VARCHAR2(80);
l_rule_count NUMBER;

BEGIN

     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

              l_message_code := '';

         FOR l_rules_in_error IN RULES_IN_ERROR LOOP

	    l_message_code := l_message_code||'<br>';

            IF (x_msg_count = 0 ) THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := x_msg_count+1;
            END IF ;

                OPEN RULE_NAMES_IN_ERROR (l_rules_in_error.measure_id,l_rules_in_error.period_type) ; --Changed the parameter from l_rules_in_error.measure_name to l_rules_in_error.measure_id for the bug# 3639474

                       l_rule_count := 0;

		       LOOP
			   FETCH RULE_NAMES_IN_ERROR
			    INTO l_rule_name ;

		       EXIT WHEN RULE_NAMES_IN_ERROR%NOTFOUND;

                           IF l_rule_count<>0 THEN
				l_message_code := l_message_code||',  ';
			   END IF;

			   l_message_code := l_message_code||l_rule_name;
                         l_rule_count := 1;

		       END LOOP;

		CLOSE RULE_NAMES_IN_ERROR;

			   l_message_code := l_message_code||'</br>';

          END LOOP;

          IF (x_msg_count <>0) THEN
               ROLLBACK;
          END IF;

              PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_EXCP_PROJ_DUP_MEASURE_CAL',
                  p_token1         =>'PERF_RULE',
                  p_value1         =>l_message_code);

/*  We should check for rules in warning only when there are no rules in error */

      IF (x_msg_count = 0 ) THEN
              l_message_code := '';

         FOR l_rules_in_warning IN RULES_IN_WARNING LOOP

            l_message_code := l_message_code||'<br>';

            IF (x_msg_count = 0 ) THEN
              x_msg_count := x_msg_count+1;
            END IF ;

                OPEN RULE_NAMES_IN_WARNING (l_rules_in_warning.measure_id); --Changed the parameter from l_rules_in_warning.measure_name to l_rules_in_warning.measure_id for the bug# 3639474

                       l_rule_count := 0;

                       LOOP
                           FETCH RULE_NAMES_IN_WARNING
                            INTO l_rule_name ;

                       EXIT WHEN RULE_NAMES_IN_WARNING%NOTFOUND;

                           IF l_rule_count<>0 THEN
                                l_message_code := l_message_code||',  ';
                           END IF;

                           l_message_code := l_message_code||l_rule_name;
                         l_rule_count := 1;

                       END LOOP;

                CLOSE RULE_NAMES_IN_WARNING;

                           l_message_code := l_message_code||'</br>';

          END LOOP;

                X_MSG_DATA := l_message_code ;
              PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_EXCP_PROJ_RULE_DUP_MEASURE',
                  p_token1         =>'RULE_NAME',
                  p_value1         =>l_message_code);
       END IF ;
  /* New rows are created with record_version_number=2 .Update them back to 1 */

             UPDATE PA_PERF_OBJECT_RULES
                SET RECORD_VERSION_NUMBER = 1
               WHERE RECORD_VERSION_NUMBER =2;

END VALIDATE_RULE_OBJECT;

END PA_PERF_OBJECT_RULES_PVT;

/
