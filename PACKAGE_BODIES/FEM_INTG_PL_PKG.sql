--------------------------------------------------------
--  DDL for Package Body FEM_INTG_PL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_PL_PKG" AS
/* $Header: fem_intg_pl.plb 120.1 2005/09/09 15:22:33 appldev noship $ */

  pc_api_version          CONSTANT NUMBER := 1.0;

  pc_log_level_statement  CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure  CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event      CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception  CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error      CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected CONSTANT NUMBER := FND_LOG.level_unexpected;
  pc_module_name          CONSTANT VARCHAR2(100):= 'fem.plsql.fem_intg_pl_pkg';

--
-- PUBLIC FUNCTIONS
--

  FUNCTION Obj_Def_Data_Edit_Lock_Exists(p_object_definition_id NUMBER)
  RETURN VARCHAR2 IS
    edit_lock_exists	VARCHAR2(1);
  BEGIN
    FEM_PL_PKG.obj_def_data_edit_lock_exists(
	p_object_definition_id	=> p_object_definition_id,
	x_data_edit_lock_exists	=> edit_lock_exists);

    return edit_lock_exists;
  END Obj_Def_Data_Edit_Lock_Exists;


  FUNCTION Can_Delete_Object_Def(p_object_definition_id NUMBER)
  RETURN VARCHAR2 IS
    can_delete	VARCHAR2(1);
    msg_count	NUMBER;
    msg_data	VARCHAR2(4000);
  BEGIN
    FEM_PL_PKG.can_delete_object_def(
	p_object_definition_id	=> p_object_definition_id,
	x_can_delete_obj_def	=> can_delete,
	x_msg_count		=> msg_count,
	x_msg_data		=> msg_data,
	p_calling_program	=> 'can_delete_object');

    return can_delete;
  END Can_Delete_Object_Def;


  FUNCTION Dimension_Rules_Have_Been_Run(p_chart_of_accounts_id NUMBER)
  RETURN VARCHAR2 IS
    has_been_run	VARCHAR2(1);

    -- Used to get a list of all dimension rules that must have been run
    -- for this particular chart of accounts
    CURSOR coa_objects_cursor IS
    SELECT dim_rule_obj_id
    FROM   fem_intg_dim_rules
    WHERE  chart_of_accounts_id = p_chart_of_accounts_id;

    dim_rule_obj_id	NUMBER;

    -- Used to check the execution status of a dimension rule the last
    -- time it was executed
    CURSOR exec_cursor(c_object_id NUMBER) IS
    SELECT exec_status_code
    FROM   fem_pl_object_executions
    WHERE  object_id = c_object_id
    ORDER BY event_order desc;

    status		VARCHAR2(100);
  BEGIN
    OPEN coa_objects_cursor;
    FETCH coa_objects_cursor INTO dim_rule_obj_id;
    WHILE (coa_objects_cursor%FOUND) LOOP
      OPEN exec_cursor(dim_rule_obj_id);
      FETCH exec_cursor INTO status;
      IF (exec_cursor%NOTFOUND OR status <> 'SUCCESS') THEN
        CLOSE exec_cursor;
        CLOSE coa_objects_cursor;
        return 'F';
      END IF;
      CLOSE exec_cursor;

      FETCH coa_objects_cursor INTO dim_rule_obj_id;
    END LOOP;
    CLOSE coa_objects_cursor;

    -- If we got this far, it means none of the dimension rules had issues
    return 'T';
  END Dimension_Rules_Have_Been_Run;


  FUNCTION Effective_Date_Incl_Rslt_Data(
	p_object_definition_id		NUMBER,
	p_new_effective_start_date	DATE,
	p_new_effective_end_date	DATE)
  RETURN VARCHAR2 IS
    date_includes	VARCHAR2(1);
    msg_data		VARCHAR2(4000);
    msg_count		NUMBER;
  BEGIN
    FEM_PL_PKG.Effective_Date_Incl_Rslt_Data(
	p_object_definition_id		=> p_object_definition_id,
	p_new_effective_start_date	=> p_new_effective_start_date,
	p_new_effective_end_date	=> p_new_effective_end_date,
	x_msg_count			=> msg_count,
	x_msg_data			=> msg_data,
	x_date_incl_rslt_data		=> date_includes);

    return date_includes;
  END Effective_Date_Incl_Rslt_Data;


  PROCEDURE Register_Process_Execution (
    p_obj_id IN NUMBER,
    p_obj_def_id IN NUMBER,
    p_req_id IN NUMBER,
    p_user_id IN NUMBER,
    p_login_id IN NUMBER,
    p_pgm_id IN NUMBER,
    p_pgm_app_id IN NUMBER,
    p_module_name IN VARCHAR2,
    p_hierarchy_name IN VARCHAR2 DEFAULT NULL,
    x_completion_code OUT NOCOPY NUMBER
  ) IS
    v_func_name VARCHAR2(100);
    v_msg_count NUMBER;
    v_msg_data VARCHAR2(2000);
    v_return_status VARCHAR2(1);
    v_exec_state VARCHAR2(30);
    v_prev_request_id NUMBER;
    v_exec_lock_exists BOOLEAN := FALSE;

    FEM_INTG_fatal_err EXCEPTION;
  BEGIN

    v_func_name := pc_module_name || '.Register_Process_Execution';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => p_module_name || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    FND_MSG_PUB.Initialize;

    FEM_PL_PKG.Register_Request(
      p_api_version            => pc_api_version,
      p_commit                 => 'T',
      p_cal_period_id          => NULL,
      p_ledger_id              => NULL,
      p_dataset_io_obj_def_id  => NULL,
      p_output_dataset_code    => NULL,
      p_source_system_code     => NULL,
      p_effective_date         => NULL,
      p_rule_set_obj_def_id    => NULL,
      p_rule_set_name          => NULL,
      p_request_id             => p_req_id,
      p_user_id                => p_user_id,
      p_last_update_login      => p_login_id,
      p_program_id             => p_pgm_id,
      p_program_login_id       => p_login_id,
      p_program_application_id => p_pgm_app_id,
      p_exec_mode_code         => 'S',
      p_dimension_id           => NULL,
      p_table_name             => NULL,
      p_hierarchy_name         => p_hierarchy_name,
      x_msg_count              => v_msg_count,
      x_msg_data               => v_msg_data,
      x_return_status          => v_return_status
    );

    IF v_return_status <> 'S' THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.rrfe',
        p_msg_text => 'raising FEM_INTG_fatal_err'
      );

      RAISE FEM_INTG_fatal_err;

    END IF;

    FND_MSG_PUB.Initialize;

    FEM_PL_PKG.Register_Object_Execution(
      p_api_version               => pc_api_version,
      p_commit                    => 'T',
      p_request_id                => p_req_id,
      p_object_id                 => p_obj_id,
      p_exec_object_definition_id => p_obj_def_id,
      p_user_id                   => p_user_id,
      p_last_update_login         => p_login_id,
      p_exec_mode_code            => 'S',
      x_exec_state                => v_exec_state,
      x_prev_request_id           => v_prev_request_id,
      x_msg_count                 => v_msg_count,
      x_msg_data                  => v_msg_data,
      x_return_status             => v_return_status
    );

    IF v_return_status <> 'S' THEN

      IF v_return_status = 'E' THEN
        v_exec_lock_exists := TRUE;
      END IF;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.roefe',
        p_msg_text => 'raising FEM_INTG_fatal_err'
      );

      RAISE FEM_INTG_fatal_err;

    END IF;

    FND_MSG_PUB.Initialize;

    FEM_PL_PKG.Register_Object_Def(
      p_api_version          => pc_api_version,
      p_commit               => 'T',
      p_request_id           => p_req_id,
      p_object_id            => p_obj_id,
      p_object_definition_id => p_obj_def_id,
      p_user_id              => p_user_id,
      p_last_update_login    => p_login_id,
      x_msg_count            => v_msg_count,
      x_msg_data             => v_msg_data,
      x_return_status        => v_return_status
    );

    IF v_return_status <> 'S' THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.rodfe',
        p_msg_text => 'raising FEM_INTG_fatal_err'
      );
      RAISE FEM_INTG_fatal_err;

    END IF;

    COMMIT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => p_module_name || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    x_completion_code := 0;

  EXCEPTION

    WHEN FEM_INTG_fatal_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.v_msg_count',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'v_msg_count',
        p_token2   => 'VAR_VAL',
        p_value2   => TO_CHAR(v_msg_count)
      );

      IF v_msg_count = 1 THEN

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => p_module_name || '.v_msg_data1',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_msg_data',
          p_token2   => 'VAR_VAL',
          p_value2   => v_msg_data
        );

        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => v_msg_data
        );

      ELSIF v_msg_count > 1 THEN

        FOR i IN 1 .. v_msg_count LOOP

          v_msg_data := FND_MSG_PUB.Get(
                          p_msg_index => i,
                          p_encoded => 'F'
                        );

          FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_statement,
            p_module   => p_module_name || '.v_msg_data2',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_204',
            p_token1   => 'VAR_NAME',
            p_value1   => 'v_msg_data',
            p_token2   => 'VAR_VAL',
            p_value2   => v_msg_data
          );

          FEM_ENGINES_PKG.User_Message(
            p_app_name => 'FEM',
            p_msg_text => v_msg_data
          );

        END LOOP;

      END IF;

      IF v_exec_lock_exists THEN

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_exception,
          p_module   => p_module_name || '.v_exec_lock_exists',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_EXEC_LOCK_EXISTS'
        );

        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_EXEC_LOCK_EXISTS'
        );

        FEM_PL_PKG.Unregister_Request(
          p_api_version   => pc_api_version,
          p_commit        => 'T',
          p_request_id    => p_req_id,
          x_msg_count     => v_msg_count,
          x_msg_data      => v_msg_data,
          x_return_status => v_return_status
        );

      END IF;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => p_module_name || '.fatal_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_PROC_FAILURE'
      );

      x_completion_code := 2;

    WHEN OTHERS THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_unexpected,
        p_module   => p_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => p_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_PROC_FAILURE'
      );

      x_completion_code := 2;

  END Register_Process_Execution;


  PROCEDURE Final_Process_Logging(
    p_obj_id IN NUMBER,
    p_obj_def_id IN NUMBER,
    p_req_id IN NUMBER,
    p_user_id IN NUMBER,
    p_login_id IN NUMBER,
    p_exec_status IN VARCHAR2,
    p_row_num_loaded IN NUMBER,
    p_err_num_count IN NUMBER,
    p_final_msg_name IN VARCHAR2,
    p_module_name IN VARCHAR2,
    x_completion_code OUT NOCOPY NUMBER
  ) IS
    v_func_name VARCHAR2(100);
    v_msg_count NUMBER;
    v_msg_data VARCHAR2(2000);
    v_return_status VARCHAR2(1);

    FEM_INTG_warn EXCEPTION;

  BEGIN

    v_func_name := pc_module_name || '.Final_Process_Logging';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => p_module_name || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    FND_MSG_PUB.Initialize;

    FEM_PL_PKG.Update_Obj_Exec_Errors(
      p_api_version       => pc_api_version,
      p_commit            => 'T',
      p_request_id        => p_req_id,
      p_object_id         => p_obj_id,
      p_errors_reported	  => p_err_num_count,
      p_errors_reprocessed => 0,
      p_user_id           => p_user_id,
      p_last_update_login => p_login_id,
      x_msg_count         => v_msg_count,
      x_msg_data          => v_msg_data,
      x_return_status     => v_return_status
    );

    IF v_msg_count = 1 THEN
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.uoee',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'v_msg_data',
        p_token2   => 'VAR_VAL',
        p_value2   => v_msg_data
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_text => v_msg_data
      );

      RAISE FEM_INTG_warn;

    END IF;

    FEM_PL_PKG.Update_Obj_Exec_Status(
      p_api_version       => pc_api_version,
      p_commit            => 'T',
      p_request_id        => p_req_id,
      p_object_id         => p_obj_id,
      p_exec_status_code  => p_exec_status,
      p_user_id           => p_user_id,
      p_last_update_login => p_login_id,
      x_msg_count         => v_msg_count,
      x_msg_data          => v_msg_data,
      x_return_status     => v_return_status
    );

    IF v_msg_count = 1 THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.uoes',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'v_msg_data',
        p_token2   => 'VAR_VAL',
        p_value2   => v_msg_data
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_text => v_msg_data
      );

      RAISE FEM_INTG_warn;

    END IF;

    FEM_PL_PKG.Update_Request_Status(
      p_api_version       => pc_api_version,
      p_commit            => 'T',
      p_request_id        => p_req_id,
      p_exec_status_code  => p_exec_status,
      p_user_id           => p_user_id,
      p_last_update_login => p_login_id,
      x_msg_count         => v_msg_count,
      x_msg_data          => v_msg_data,
      x_return_status     => v_return_status
    );

    IF v_msg_count = 1 THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module_name || '.urs',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'v_msg_data',
        p_token2   => 'VAR_VAL',
        p_value2   => v_msg_data
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_text => v_msg_data
      );

      RAISE FEM_INTG_warn;

    END IF;

    COMMIT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module_name || '.p_exec_status',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_204',
      p_token1   => 'VAR_NAME',
      p_value1   => 'p_exec_status',
      p_token2   => 'VAR_VAL',
      p_value2   => p_exec_status
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module_name || '.p_final_msg_name',
      p_app_name => 'FEM',
      p_msg_name => p_final_msg_name
    );

    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_name => p_final_msg_name
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => p_module_name || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    x_completion_code := 0;

  EXCEPTION

    WHEN FEM_INTG_warn THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => p_module_name || '.warn_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_FAIL_FINAL_PROC_LOG'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_FAIL_FINAL_PROC_LOG'
      );

      x_completion_code := 1;

    WHEN OTHERS THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_unexpected,
        p_module   => p_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => p_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

  END Final_Process_Logging;

END FEM_INTG_PL_PKG;

/
