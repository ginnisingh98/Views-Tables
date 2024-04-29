--------------------------------------------------------
--  DDL for Package Body GCS_LEX_MAP_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_LEX_MAP_API_PKG" as
/* $Header: gcslmapb.pls 120.1 2005/10/30 05:19:00 appldev noship $ */

--
-- PRIVATE GLOBAL VARIABLES
--

  -- Used to store the constant 'gcs_rv_' which is used as the return value
  -- variable in functions that are dynamically created in here.
  g_ret_val	CONSTANT VARCHAR2(10) := 'gcs_rv_';

  -- Used to store the constant 'gcs_drv_' which is used as a local variable
  -- to hold the derivation number in the materialized function.
  g_deriv_num	CONSTANT VARCHAR2(10) := 'gcs_drv_';

  -- Name of this API package.
  g_api		CONSTANT VARCHAR2(30) := 'gcs.plsql.GCS_LEX_MAP_API_PKG';

  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter	CONSTANT VARCHAR2(1) := 'E';
  g_module_success	CONSTANT VARCHAR2(1) := 'S';
  g_module_failure	CONSTANT VARCHAR2(1) := 'F';

  -- various error codes
  -- Error Descriptions:
  --   EX01 - Lookup table derivation returned more than one row
  --   EX02 - Lookup table derivation returned no rows
  --   EX03 - Type mismatch occurred (type conversion error)
  --   EX04 - Value set validation failed
  --   EX05 - Lookup table validation failed

  --   EX99 - Unexpected error occurred.

  g_error_lookup_tmr	CONSTANT VARCHAR2(4) := 'EX01';
  g_error_lookup_ndf	CONSTANT VARCHAR2(4) := 'EX02';
  g_error_type_mismatch	CONSTANT VARCHAR2(4) := 'EX03';
  g_error_vsv_failed	CONSTANT VARCHAR2(4) := 'EX04';
  g_error_lutv_failed	CONSTANT VARCHAR2(4) := 'EX05';

  g_error_unexpected	CONSTANT VARCHAR2(4) := 'EX99';


--
-- PRIVATE EXCEPTIONS
--

  GCS_LEX_INVALID_RULE_SET	EXCEPTION;
  GCS_LEX_FILTER_ERROR		EXCEPTION;
  GCS_LEX_FILTER_COLUMN_NOT_RO	EXCEPTION;
  GCS_LEX_SET_NO_STAGE		EXCEPTION;
  GCS_LEX_STAGE_NO_RULE		EXCEPTION;
  GCS_LEX_INVALID_LIST_CODE	EXCEPTION;
  GCS_LEX_PARAM_LIST_FAILED	EXCEPTION;
  GCS_LEX_CREATE_COND_FAILED	EXCEPTION;
  GCS_LEX_DERIVATION_FAILED	EXCEPTION;
  GCS_LEX_DEF_COND_NOT_LAST	EXCEPTION;
  GCS_LEX_RULE_NO_DERIVATION	EXCEPTION;
  GCS_LEX_READ_ONLY_COLUMN_RULE	EXCEPTION;
  GCS_LEX_DISABLED		EXCEPTION;
  GCS_LEX_UNEXPECTED_ERROR	EXCEPTION;
  GCS_LEX_INIT_FAILED		EXCEPTION;
  GCS_LEX_FUNC_FAILURE		EXCEPTION;
  GCS_LEX_INVALID_VALID_CODE	EXCEPTION;
  GCS_LEX_INVALID_VALUE_SET	EXCEPTION;
  GCS_LEX_INVALID_VALUE_SET_ID	EXCEPTION;
  GCS_LEX_INVALID_TV_VALUE_SET	EXCEPTION;
  GCS_LEX_FAIL_VS_VALIDATION	EXCEPTION;
  GCS_LEX_FAIL_LUT_VALIDATION	EXCEPTION;
  GCS_LEX_NO_FILTER_COLUMN_NAME	EXCEPTION;
  GCS_LEX_NO_FILTER_VALUE	EXCEPTION;
  GCS_LEX_STAGE_FAILED		EXCEPTION;
  GCS_LEX_VALIDATION_FAILED	EXCEPTION;
  GCS_LEX_NO_ERROR_COLUMN	EXCEPTION;
  GCS_LEX_MULT_ERROR_COLUMNS	EXCEPTION;
  GCS_LEX_INVALID_FILTER_COLUMN	EXCEPTION;
  GCS_LEX_TABLE_CHECK_FAILED	EXCEPTION;
  GCS_LEX_VALID_CHECK_FAILED	EXCEPTION;
  GCS_LEX_LUT_NO_LOOKUP_CODE	EXCEPTION;
  GCS_LEX_VDATION_LUT_NOT_META	EXCEPTION;
  GCS_LEX_ERROR_COLUMN_NOT_SET	EXCEPTION;
  GCS_LEX_ERROR_COL_WRITE	EXCEPTION;
  GCS_LEX_NUM_ROWS_CHANGED	EXCEPTION;
  GCS_LEX_NO_VALIDATION_LUT	EXCEPTION;
  GCS_LEX_RULE_NO_FUNC		EXCEPTION;
  GCS_LEX_APPLSYS_NOT_FOUND	EXCEPTION;
  GCS_LEX_FUNC_FAILED		EXCEPTION;
  GCS_LEX_FUNC_NOT_REGISTERED	EXCEPTION;

  GCS_LEX_VRS_NO_ROWS		EXCEPTION;
  GCS_LEX_VRS_RULE_FAILED	EXCEPTION;

--
-- PRIVATE PROCEDURES/FUNCTIONS
--

  --
  -- Procedure
  --   QSort_Error_Table
  -- Purpose
  --   Quick sorts the error table
  -- Arguments
  --   Low	Bottom index
  --   High	Top index
  -- Example
  --   GCS_LEX_MAP_PKG.QSort_Error_Table(1, 5);
  -- Notes
  --
  PROCEDURE QSort_Error_Table(	Low	NUMBER,
				High	NUMBER) IS
    low_counter		NUMBER;
    high_counter	NUMBER;

    -- for swapping
    temp_row	error_record_type;

    -- for storing pivot information
    pivot_row	error_record_type;
  BEGIN
    low_counter := low;
    high_counter := high;
    IF low >= high THEN
      return;
    END IF;

    pivot_row := error_table(trunc((low+high)/2));

    -- Get the pivot from the center of the array to the front
    error_table(trunc((low+high)/2)) := error_table(low);
    error_table(low) := pivot_row;

    LOOP
      WHILE low_counter < high AND
            ((error_table(low_counter).rule_id < pivot_row.rule_id) OR
             (error_table(low_counter).rule_id = pivot_row.rule_id AND
              error_table(low_counter).deriv_num < pivot_row.deriv_num) OR
             (error_table(low_counter).rule_id = pivot_row.rule_id AND
              error_table(low_counter).deriv_num = pivot_row.deriv_num AND
              error_table(low_counter).error_code < pivot_row.error_code) OR
             (error_table(low_counter).rule_id = pivot_row.rule_id AND
              error_table(low_counter).deriv_num = pivot_row.deriv_num AND
              error_table(low_counter).error_code = pivot_row.error_code AND
              error_table(low_counter).row_id <= pivot_row.row_id)) LOOP
        low_counter := low_counter + 1;
      END LOOP;
      WHILE high_counter > low AND
            ((error_table(high_counter).rule_id > pivot_row.rule_id) OR
             (error_table(high_counter).rule_id = pivot_row.rule_id AND
              error_table(high_counter).deriv_num > pivot_row.deriv_num) OR
             (error_table(high_counter).rule_id = pivot_row.rule_id AND
              error_table(high_counter).deriv_num = pivot_row.deriv_num AND
              error_table(high_counter).error_code > pivot_row.error_code) OR
             (error_table(high_counter).rule_id = pivot_row.rule_id AND
              error_table(high_counter).deriv_num = pivot_row.deriv_num AND
              error_table(high_counter).error_code = pivot_row.error_code AND
              error_table(high_counter).row_id > pivot_row.row_id)) LOOP
        high_counter := high_counter - 1;
      END LOOP;
      EXIT WHEN low_counter >= high_counter;

      -- swap the high and low.
      temp_row := error_table(low_counter);
      error_table(low_counter) := error_table(high_counter);
      error_table(high_counter) := temp_row;
    END LOOP;

    -- Put the pivot row into the correct place.
    error_table(low) := error_table(high_counter);
    error_table(high_counter) := pivot_row;

    -- Quick Sort the two sub-arrays
    qsort_error_table(low, high_counter-1);
    qsort_error_table(high_counter+1, high);
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END QSort_Error_Table;

  --
  -- Procedure
  --   Write_Header_Output
  -- Purpose
  --   Writes header information for the output execution report.
  -- Arguments
  --   Idt_Name		The transformer to use in this API call.
  --   Staging_Table	Staging table where the data is stored.
  --   Filter_Text	The filter criteria.
  -- Example
  --   GCS_LEX_MAP_PKG.Write_Header_Output;
  -- Notes
  --
  PROCEDURE Write_Header_Output(	Idt_Name	VARCHAR2,
					Staging_Table	VARCHAR2,
					Filter_Text	VARCHAR2) IS
  BEGIN
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_HEADER');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_IDT');
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_STG_TBL');
    FND_MESSAGE.set_token('STG_TBL', staging_table);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_FILTER');
    FND_MESSAGE.set_token('FILTER_TEXT', filter_text);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_REQ_ID');
    FND_MESSAGE.set_token('REQ_ID', fnd_global.conc_request_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_SEPARATOR');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
  END Write_Header_Output;


  --
  -- Procedure
  --   Write_Tail_Output
  -- Purpose
  --   Writes tail information for the output execution report.
  -- Arguments
  --
  -- Example
  --   GCS_LEX_MAP_PKG.Write_Tail_Output;
  -- Notes
  --
  PROCEDURE Write_Tail_Output IS
  BEGIN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_TAIL');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_TAIL_SEPARATOR');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_EX01_LEGEND');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_EX02_LEGEND');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_EX03_LEGEND');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_EX04_LEGEND');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_EX05_LEGEND');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_EX99_LEGEND');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
  END Write_Tail_Output;


  --
  -- Procedure
  --   Write_Header_Log
  -- Purpose
  --   Writes header information for the log file.
  -- Arguments
  --   Idt_Name		The transformer to use in this API call.
  --   Staging_Table	Staging table where the data is stored.
  --   Filter_Text	The filter criteria.
  -- Example
  --   GCS_LEX_MAP_PKG.Write_Header_Log(idt,'GL_INTERFACE','group_id=''11''');
  -- Notes
  --
  PROCEDURE Write_Header_Log(	Idt_Name	VARCHAR2,
				Staging_Table	VARCHAR2,
				Filter_Text	VARCHAR2) IS
  BEGIN
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XL_IDT');
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XL_STG_TBL');
    FND_MESSAGE.set_token('STG_TBL', staging_table);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);

    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XL_FILTER');
    FND_MESSAGE.set_token('FILTER_TEXT', filter_text);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);
  END Write_Header_Log;

  --
  -- Procedure
  --   Log_File_Module_Write
  -- Purpose
  --   Adds a line to the log file saying that we have entered, exited with
  --   success, or exited with failure from a module of our API. However, it
  --   strips out the API name that always comes at the front, since that is
  --   implied by the log file you are reading.
  -- Arguments
  --   Module		Name of the Module.
  --   Action_Type	Entered, Exited Successfully, or Exited with Failure.
  -- Example
  --   GCS_LEX_MAP_PKG.Log_File_Module_Write('GCS_LEX_MAP_PKG.apply_map', 'E');
  -- Notes
  --
  PROCEDURE Log_File_Module_Write(	Module		VARCHAR2,
					Action_Type	VARCHAR2)
  IS
    enter_exit_text	VARCHAR2(10);
  BEGIN
    IF action_type = g_module_enter THEN
      FND_FILE.NEW_LINE(FND_FILE.LOG);
      enter_exit_text := '>>';
    ELSIF action_type = g_module_success THEN
      enter_exit_text := '<<';
    ELSE
      enter_exit_text := '<x';
    END IF;

    FND_FILE.PUT_LINE(
      FND_FILE.LOG,
      enter_exit_text || ' ' ||
      SUBSTR(module, LENGTH(g_api)+2, LENGTH(module)-LENGTH(g_api)-1) ||
      '() ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));

    IF action_type <> g_module_enter THEN
      FND_FILE.NEW_LINE(FND_FILE.LOG);
    END IF;

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT, module,
      enter_exit_text || ' ' ||
      SUBSTR(module, LENGTH(g_api)+2, LENGTH(module)-LENGTH(g_api)-1) ||
      '() ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
  END Log_File_Module_Write;

  --
  -- Procedure
  --   Write_To_Log
  -- Purpose
  --   Adds a message to both the log file and log repository, if appropriate.
  --   It uses the module passed in for the log repository. It will write to
  --   the log file if the File_Write parameter is set to 'Y'. The assumption
  --   is that the message has already been built by the fnd_message API.
  -- Arguments
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Write_To_Log('GCS_LEX_DERIV_FAIL');
  -- Notes
  --
  PROCEDURE Write_To_Log(	Module		VARCHAR2,
				File_Write	VARCHAR2)
  IS
    encoded_message	VARCHAR2(32767);
  BEGIN
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED THEN
      FND_LOG.message(FND_LOG.LEVEL_UNEXPECTED, module);
    END IF;
    IF File_Write = 'Y' THEN
      encoded_message := FND_MESSAGE.get_encoded;
      FND_MESSAGE.set_encoded(encoded_message);
      FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);
      FND_MESSAGE.set_encoded(encoded_message);
    END IF;
    FND_MSG_PUB.add;
  END Write_To_Log;

  --
  -- Procedure
  --   Add_Deriv_Proc_Failed_Msg
  -- Purpose
  --   Adds a message that the derivation given has failed during processing.
  --   The exact message to show is given by the message name. The message must
  --   have four tokens: IDT_NAME for transformer name, STAGE_NUM for stage
  --   number, COL_NAME for column of the rule, and DERIV_NUM for derivation
  --   sequence number. There is one exception, and that is when the deriv_num
  --   passed into this procedure is -1. In that case, there should not be a
  --   DERIV_NUM token.
  -- Arguments
  --   Rule_Id		ID of the rule that failed.
  --   Deriv_Num	Sequence number of the derivation that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Deriv_Proc_Failed_Msg(123, 3, 'GCS_IDT_DERIV_FAIL');
  -- Notes
  --
  PROCEDURE Add_Deriv_Proc_Failed_Msg(	Rule_Id		NUMBER,
					Deriv_Num	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name
    INTO	idt_name,
		stage_num,
		col_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_columns	mc
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.target_column_id = mc.column_id
    AND		r.rule_id = add_deriv_proc_failed_msg.rule_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    IF deriv_num <> -1 THEN
      FND_MESSAGE.set_token('DERIV_NUM', deriv_num);
    END IF;
    Write_To_Log(module, file_write);
  END Add_Deriv_Proc_Failed_Msg;

  --
  -- Procedure
  --   Add_Deriv_Failed_Msg
  -- Purpose
  --   Adds a message that the derivation given has failed during processing.
  --   The exact message to show is given by the message name. The message must
  --   have four tokens: IDT_NAME for transformer name, STAGE_NUM for stage
  --   number, COL_NAME for column of the rule, and DERIV_NUM for derivation
  --   sequence number.
  -- Arguments
  --   Derivation_Id	ID of the derivation that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Deriv_Failed_Msg(12345, 'GCS_IDT_ERROR', 'ABC_PKG');
  -- Notes
  --
  PROCEDURE Add_Deriv_Failed_Msg(	Derivation_Id	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
    deriv_num	NUMBER;
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name,
		d.derivation_sequence
    INTO	idt_name,
		stage_num,
		col_name,
		deriv_num
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_derivations	d,
		gcs_lex_map_columns	mc
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.rule_id = d.rule_id
    AND		r.target_column_id = mc.column_id
    AND		d.derivation_id = add_deriv_failed_msg.derivation_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    FND_MESSAGE.set_token('DERIV_NUM', deriv_num);
    Write_To_Log(module, file_write);
  END Add_Deriv_Failed_Msg;

  --
  -- Procedure
  --   Add_PLSQL_Deriv_Failed_Msg
  -- Purpose
  --   Adds a message that the derivation given has failed during processing.
  --   The exact message to show is given by the message name. The message must
  --   have five tokens: IDT_NAME for transformer name, STAGE_NUM for stage
  --   number, COL_NAME for column of the rule, DERIV_NUM for derivation
  --   sequence number, and FUNC_NAME for the PL/SQL function name.
  -- Arguments
  --   Derivation_Id	ID of the derivation that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_PLSQL_Deriv_Failed_Msg(1, 'GCS_IDT_ERR', 'ABC_PKG');
  -- Notes
  --
  PROCEDURE Add_PLSQL_Deriv_Failed_Msg(	Derivation_Id	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
    deriv_num	NUMBER;
    func_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name,
		d.derivation_sequence,
		d.function_name
    INTO	idt_name,
		stage_num,
		col_name,
		deriv_num,
		func_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_derivations	d,
		gcs_lex_map_columns	mc
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.rule_id = d.rule_id
    AND		r.target_column_id = mc.column_id
    AND		d.derivation_id = add_plsql_deriv_failed_msg.derivation_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    FND_MESSAGE.set_token('DERIV_NUM', deriv_num);
    FND_MESSAGE.set_token('FUNC_NAME', func_name);
    Write_To_Log(module, file_write);
  END Add_PLSQL_Deriv_Failed_Msg;

  --
  -- Procedure
  --   Add_Rule_Failed_Msg
  -- Purpose
  --   Adds a message that the rule given failed during processing. The message
  --   itself is determined by the message name passed in. It must be a message
  --   for 'GCS', and must have three tokens: IDT_NAME for the transformer
  --   name, STAGE_NUM for the stage number within that transformer, and
  --   COL_NAME for the column of that rule.
  -- Arguments
  --   Rule_Id		ID of the rule that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Rule_Failed_Msg(11111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Rule_Failed_Msg(Rule_Id		NUMBER,
				Message_Name	VARCHAR2,
				Module		VARCHAR2,
				File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name
    INTO	idt_name,
		stage_num,
		col_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_columns	mc
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.target_column_id = mc.column_id
    AND		r.rule_id = add_rule_failed_msg.rule_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    Write_To_Log(module, file_write);
  END Add_Rule_Failed_Msg;

  --
  -- Procedure
  --   Add_VRS_Rule_Failed_Msg
  -- Purpose
  --   Adds a message that the rule given failed during validation. The message
  --   itself is determined by the message name passed in. It must be a message
  --   for 'GCS', and must have one token: RULE_NAME for the rule name.
  -- Arguments
  --   Rule_Name	Name of the rule that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_VRS_Rule_Failed_Msg('name', 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_VRS_Rule_Failed_Msg(	Rule_Name	VARCHAR2,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
  BEGIN
    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('RULE_NAME', rule_name);
    Write_To_Log(module, file_write);
  END Add_VRS_Rule_Failed_Msg;

  --
  -- Procedure
  --   Add_Stage_Failed_Msg
  -- Purpose
  --   Adds a message that the stage failed during processing. The message
  --   itself is determined by the message name passed in. It must be a message
  --   for 'GCS', and must have two tokens: IDT_NAME for the transformer name
  --   and STAGE_NUM for the stage number within that transformer.
  -- Arguments
  --   Rule_Stage_Id	ID of the stage that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Stage_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Stage_Failed_Msg(	Rule_Stage_Id	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
  BEGIN
    SELECT	rst.name,
		rstg.stage_number
    INTO	idt_name,
		stage_num
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = add_stage_failed_msg.rule_stage_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    Write_To_Log(module, file_write);
  END Add_Stage_Failed_Msg;

  --
  -- Procedure
  --   Add_Rows_Changed_Msg
  -- Purpose
  --   Adds a message that the stage given processed a different number of rows
  --   than the previous stage. The message itself is determined by the message
  --   message name passed in. It must be a message for 'GCS', and must have
  --   four tokens: IDT_NAME for the transformer name, STAGE_NUM for the stage
  --   number, PREV_ROWS for the previous number of rows, and CURR_ROWS for the
  --   rows affected by the current stage.
  -- Arguments
  --   Rule_Stage_Id	ID of the stage that failed.
  --   Current_Rows	Number of rows just processed.
  --   Previous_Rows	Number of rows previously processed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Rows_Changed_Msg(...);
  -- Notes
  --
  PROCEDURE Add_Rows_Changed_Msg(	Rule_Stage_Id	NUMBER,
					Current_Rows	NUMBER,
					Previous_Rows	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
  BEGIN
    SELECT	rst.name,
		rstg.stage_number
    INTO	idt_name,
		stage_num
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = add_rows_changed_msg.rule_stage_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('CURR_ROWS', current_rows);
    FND_MESSAGE.set_token('PREV_ROWS', previous_rows);
    Write_To_Log(module, file_write);
  END Add_Rows_Changed_Msg;

  --
  -- Procedure
  --   Add_IDT_Failed_Msg
  -- Purpose
  --   Adds a message that the IDT given failed during processing. The message
  --   itself is determined by the message name passed in. It must be a message
  --   for 'GCS', and must have one token: IDT_NAME for the transformer name.
  -- Arguments
  --   Rule_Set_Id	ID of the IDT that failed
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Stage_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_IDT_Failed_Msg(	Rule_Set_Id	NUMBER,
				Message_Name	VARCHAR2,
				Module		VARCHAR2,
				File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name
    INTO	idt_name
    FROM	gcs_lex_map_rule_sets	rst
    WHERE	rst.rule_set_id = add_idt_failed_msg.rule_set_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    Write_To_Log(module, file_write);
  END Add_IDT_Failed_Msg;

  --
  -- Procedure
  --   Add_Structure_Failed_Msg
  -- Purpose
  --   Adds a message that the structure for the IDT given failed during
  --   processing. The message itself is determined by the message name passed
  --   in. It must be a message for 'GCS', and must have one token: STRUCT_NAME
  --   for the structure name.
  -- Arguments
  --   Rule_Set_Id	ID of the IDT for which the structure failed
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Stage_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Structure_Failed_Msg(	Rule_Set_Id	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    struct_name	VARCHAR2(100);
  BEGIN
    SELECT	ms.structure_name
    INTO	struct_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_structs	ms
    WHERE	rst.structure_id = ms.structure_id
    AND		rst.rule_set_id = add_structure_failed_msg.rule_set_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('STRUCT_NAME', struct_name);
    Write_To_Log(module, file_write);
  END Add_Structure_Failed_Msg;

  --
  -- Procedure
  --   Add_Value_Set_Failed_Msg
  -- Purpose
  --   Adds a message that the value set for the given rule failed. The message
  --   itself is determined by the message name passed in. It must be a message
  --   for 'GCS', and must have four tokens: VS_NAME for the value set name,
  --   COL_NAME for the rule column, STAGE_NUM for the stage number, and
  --   IDT_NAME for the transformer name.
  -- Arguments
  --   Rule_Id		ID of the rule for which the value set failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Value_Set_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Value_Set_Failed_Msg(	Rule_Id		NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
    vs_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name,
		ffvs.flex_value_set_name
    INTO	idt_name,
		stage_num,
		col_name,
		vs_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_columns	mc,
		fnd_flex_value_sets	ffvs
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.target_column_id = mc.column_id
    AND		r.value_set_id = ffvs.flex_value_set_id
    AND		r.rule_id = add_value_set_failed_msg.rule_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    FND_MESSAGE.set_token('VS_NAME', vs_name);
    Write_To_Log(module, file_write);
  END Add_Value_Set_Failed_Msg;

  --
  -- Procedure
  --   Add_Rule_LUT_Failed_Msg
  -- Purpose
  --   Adds a message that the lookup table for the given rule failed. The
  --   message itself is determined by the message name passed in. It must be a
  --   message for 'GCS', and must have five tokens: LUT_NAME for the lookup
  --   table name, COL_NAME for the rule column, STAGE_NUM for the stage
  --   number, and IDT_NAME for the transformer name.
  -- Arguments
  --   Rule_Id		ID of the rule for which the lookup table failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Rule_LUT_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Rule_LUT_Failed_Msg(	Rule_Id		NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
    lut_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name,
		lutms.structure_name
    INTO	idt_name,
		stage_num,
		col_name,
		lut_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_columns	mc,
		gcs_lex_map_structs	lutms
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.target_column_id = mc.column_id
    AND		r.lookup_table_id = lutms.structure_id
    AND		r.rule_id = add_rule_lut_failed_msg.rule_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    FND_MESSAGE.set_token('LUT_NAME', lut_name);
    Write_To_Log(module, file_write);
  END Add_Rule_LUT_Failed_Msg;

  --
  -- Procedure
  --   Add_Deriv_LUT_Failed_Msg
  -- Purpose
  --   Adds a message that the lookup table for the given derivation failed.
  --   The message itself is determined by the message name passed in. It must
  --   be a message for 'GCS', and must have five tokens: LUT_NAME for the
  --   lookup table name, DERIV_NUM for the derivation number, COL_NAME for the
  --   rule column, STAGE_NUM for the stage number, and IDT_NAME for the
  --   transformer name.
  -- Arguments
  --   Derivation_Id	ID of the rule for which the lookup table failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Deriv_LUT_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Deriv_LUT_Failed_Msg(	Derivation_Id	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    idt_name	VARCHAR2(100);
    stage_num	NUMBER;
    col_name	VARCHAR2(100);
    deriv_num	NUMBER;
    lut_name	VARCHAR2(100);
  BEGIN
    SELECT	rst.name,
		rstg.stage_number,
		mc.column_name,
		d.derivation_sequence,
		lutms.structure_name
    INTO	idt_name,
		stage_num,
		col_name,
		deriv_num,
		lut_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_rule_stages	rstg,
		gcs_lex_map_rules	r,
		gcs_lex_map_derivations	d,
		gcs_lex_map_columns	mc,
		gcs_lex_map_columns	lutmc,
		gcs_lex_map_structs	lutms
    WHERE	rst.rule_set_id = rstg.rule_set_id
    AND		rstg.rule_stage_id = r.rule_stage_id
    AND		r.rule_id = d.rule_id
    AND		r.target_column_id = mc.column_id
    AND		d.lookup_result_column_id = lutmc.column_id
    AND		lutmc.structure_id = lutms.structure_id
    AND		d.derivation_id = add_deriv_lut_failed_msg.derivation_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_MESSAGE.set_token('COL_NAME', col_name);
    FND_MESSAGE.set_token('DERIV_NUM', deriv_num);
    FND_MESSAGE.set_token('LUT_NAME', lut_name);
    Write_To_Log(module, file_write);
  END Add_Deriv_LUT_Failed_Msg;

  --
  -- Procedure
  --   Add_ID_Value_Failed_Msg
  -- Purpose
  --   Adds a message that something failed during processing. The message
  --   itself is determined by the message name passed in. It must be a
  --   message for 'GCS', and must have one token: IDNUM for the id.
  -- Arguments
  --   Id_Value		ID value that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_ID_Value_Failed_Msg(111, 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_ID_Value_Failed_Msg(	Id_Value	NUMBER,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
  BEGIN
    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('IDNUM', id_value);
    Write_To_Log(module, file_write);
  END Add_ID_Value_Failed_Msg;

  --
  -- Procedure
  --   Add_Code_Value_Failed_Msg
  -- Purpose
  --   Adds a message that a code value is invalid. The message iself is
  --   determined by the message name passed in. It must be a message for
  --   'GCS', and must have one token: CODE_VAL for the code value.
  -- Arguments
  --   Code_Value	Code value that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Code_Value_Failed_Msg('Z', 'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Code_Value_Failed_Msg(	Code_Value	VARCHAR2,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
  BEGIN
    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('CODE_VAL', code_value);
    Write_To_Log(module, file_write);
  END Add_Code_Value_Failed_Msg;

  --
  -- Procedure
  --   Add_Column_Failed_Msg
  -- Purpose
  --   Adds a message that a column is invalid. The message iself is determined
  --   by the message name passed in. It must be a message for 'GCS', and must
  --   have one token: COL_NAME for the column name.
  -- Arguments
  --   Column_Name	Name of the column that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Column_Failed_Msg('SEGMENT1','GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Column_Failed_Msg(	Column_Name	VARCHAR2,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
  BEGIN
    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('COL_NAME', column_name);
    Write_To_Log(module, file_write);
  END Add_Column_Failed_Msg;

  --
  -- Procedure
  --   Add_Simple_Failed_Msg
  -- Purpose
  --   Adds a message that something failed during processing. The message
  --   itself is determined by the message name passed in. It must be a
  --   message for 'GCS', and must have no tokens.
  -- Arguments
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Simple_Failed_Msg('GCS_IDT_RULE_FAILED', mymodule);
  -- Notes
  --
  PROCEDURE Add_Simple_Failed_Msg(	Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
  BEGIN
    FND_MESSAGE.set_name('GCS', message_name);
    Write_To_Log(module, file_write);
  END Add_Simple_Failed_Msg;

  --
  -- Procedure
  --   Add_Staging_Table_Failed_Msg
  -- Purpose
  --   Adds a message that something failed for the staging table. The message
  --   itself is determined by the message name passed in. It must be a message
  --   for 'GCS', and must have one token: STG_TBL for the table name.
  -- Arguments
  --   Table_Name	Name of the table that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Staging_Table_Failed_Msg('gl_interface',
  --                                                'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Staging_Table_Failed_Msg(	Table_Name	VARCHAR2,
						Message_Name	VARCHAR2,
						Module		VARCHAR2,
						File_Write	VARCHAR2)
  IS
  BEGIN
    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('STG_TBL', table_name);
    Write_To_Log(module, file_write);
  END Add_Staging_Table_Failed_Msg;

  --
  -- Procedure
  --   Add_Error_Code_Failed_Msg
  -- Purpose
  --   Adds a message that something failed while working with the error code
  --   column of the staging table. The message itself is determined by the
  --   message name passed in. It must be a message for 'GCS', and must have
  --   two tokens: STG_TBL for the table name and COL_NAME for the error code
  --   column name.
  -- Arguments
  --   Rule_Set_Id	ID of the IDT for which the failure occurred.
  --   Staging_Table	Name of the table that failed.
  --   Message_Name	Name of the message to be added.
  --   Module		Name of the Module that failed.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Add_Error_Code_Failed_Msg(111, 'gl_interface',
  --                                             'GCS_IDT_RULE_FAILED');
  -- Notes
  --
  PROCEDURE Add_Error_Code_Failed_Msg(	Rule_Set_Id	NUMBER,
					Staging_Table	VARCHAR2,
					Message_Name	VARCHAR2,
					Module		VARCHAR2,
					File_Write	VARCHAR2)
  IS
    error_code_col_name	VARCHAR2(100);
  BEGIN
    SELECT	mc.column_name
    INTO	error_code_col_name
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_columns	mc
    WHERE	rst.structure_id = mc.structure_id
    AND		mc.error_code_column_flag = 'Y'
    AND		rst.rule_set_id = add_error_code_failed_msg.rule_set_id;

    FND_MESSAGE.set_name('GCS', message_name);
    FND_MESSAGE.set_token('STG_TBL', staging_table);
    FND_MESSAGE.set_token('COL_NAME', error_code_col_name);
    Write_To_Log(module, file_write);
  END Add_Error_Code_Failed_Msg;

  --
  -- Function
  --   Create_AD
  -- Purpose
  --   Creates a function using ad_ddl. Returns 'TRUE' if there was an error.
  --   Returns 'FALSE' if there was no error.
  -- Arguments
  --   Func_Body	Body of the function.
  --   Func_Name	Name of the function.
  --   My_Appl		APPLSYS schema, required for ad_ddl.
  -- Example
  --   GCS_LEX_MAP_PKG.Create_AD('create ...', 'foo', 'APPLSYS');
  -- Notes
  --
  FUNCTION Create_AD(	Func_Body	VARCHAR2,
			Func_Name	VARCHAR2,
			My_Appl		VARCHAR2)
  RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    err		VARCHAR2(2000);
    curr_index	NUMBER;
    lines	NUMBER;
    body_len	NUMBER;
  BEGIN
    curr_index := 1;
    lines := 0;
    body_len := LENGTH(func_body);
    WHILE curr_index <= body_len LOOP
      lines := lines + 1;
      ad_ddl.build_statement(substr(func_body, curr_index, 200), lines);
      curr_index := curr_index + 200;
    END LOOP;

    ad_ddl.create_plsql_object(my_appl, 'FND', func_name, 1,lines,'FALSE',err);
    return err;
  END;

  --
  -- Function
  --   Initial_Rule_Set_Check
  -- Purpose
  --   Checks that the rule set exists, is enabled, has 1 or more stages,
  --   and each stage has one or more rules. If one of these checks does
  --   not pass, raises the appropriate exception. Returns the IDT name.
  -- Arguments
  --   Rule_Set_Id	ID of the Rule Set that should be checked.
  --   Usage		Transformation or Validation
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   rsname := GCS_LEX_MAP_PKG.Initial_Rule_Set_Check(111);
  -- Notes
  --
  FUNCTION Initial_Rule_Set_Check(	Rule_Set_Id	NUMBER,
					Usage		VARCHAR2,
					File_Write	VARCHAR2)
  RETURN VARCHAR2 IS
    CURSOR	stage_check IS
    SELECT	stg.rule_stage_id
    FROM	gcs_lex_map_rule_stages stg
    WHERE	stg.rule_set_id = initial_rule_set_check.rule_set_id;

    CURSOR	rule_set_check IS
    SELECT	name, enabled_flag
    FROM	gcs_lex_map_rule_sets rsts
    WHERE	rsts.rule_set_id = initial_rule_set_check.rule_set_id;

    CURSOR	rule_check(p_stage_id NUMBER) IS
    SELECT	r.rule_id
    FROM	gcs_lex_map_rules r
    WHERE	r.rule_stage_id = p_stage_id;

    CURSOR	error_column_check IS
    SELECT	mc.column_name, mc.write_flag
    FROM	gcs_lex_map_rule_sets	rst,
		gcs_lex_map_columns	mc
    WHERE	rst.structure_id = mc.structure_id
    AND		mc.error_code_column_flag = 'Y'
    AND		rst.rule_set_id = initial_rule_set_check.rule_set_id;

    CURSOR	func_reg_check_c IS
    SELECT	d.derivation_id
    FROM	gcs_lex_map_derivations d,
		gcs_lex_map_rules r,
		gcs_lex_map_rule_stages stg
    WHERE	d.rule_id = r.rule_id
    AND		r.rule_stage_id = stg.rule_stage_id
    AND		stg.rule_set_id = initial_rule_set_check.rule_set_id
    AND		d.derivation_type_code = 'PLS'
    AND		NOT EXISTS
		(SELECT	1
		 FROM	gcs_lex_map_plsql_funcs f
		 WHERE	UPPER(d.function_name) = f.function_name);

    idt_name		VARCHAR2(30);
    rule_set_enabled	VARCHAR2(1);
    num_stages		NUMBER := 0;
    stage_id		NUMBER;
    derivation_id	NUMBER;
    dummy		NUMBER;

    col_name		VARCHAR2(30);
    error_column_write	VARCHAR2(1);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Initial_Rule_Set_Check';
    IF file_write = 'Y' THEN
      log_file_module_write(module, g_module_enter);
    END IF;

    -- Check the rule set to make sure it exists and is enabled
    OPEN rule_set_check;
    FETCH rule_set_check INTO idt_name, rule_set_enabled;

    -- Check that the rule set ID exists in the table
    IF (rule_set_check%NOTFOUND) THEN
      CLOSE rule_set_check;
      raise gcs_lex_invalid_rule_set;
    END IF;
    CLOSE rule_set_check;

    -- Check that the rule set is enabled
    IF (rule_set_enabled <> 'Y') THEN
      raise gcs_lex_disabled;
    END IF;

    -- Check that there are one or more stages in this rule set, and that
    -- each stage has one or more rules associated with it.
    FOR stage IN stage_check LOOP
      stage_id := stage.rule_stage_id;
      OPEN rule_check(stage_id);
      FETCH rule_check INTO dummy;
      IF (rule_check%NOTFOUND) THEN
        CLOSE rule_check;
        raise gcs_lex_stage_no_rule;
      END IF;
      CLOSE rule_check;
      num_stages := num_stages + 1;
    END LOOP;

    -- now check that there were one or more stages
    IF num_stages = 0 THEN
      raise gcs_lex_set_no_stage;
    END IF;

    -- now check that there is one and only one error code column
    OPEN error_column_check;
    FETCH error_column_check INTO col_name, error_column_write;
    IF error_column_check%NOTFOUND THEN
      CLOSE error_column_check;
      raise gcs_lex_no_error_column;
    END IF;
    IF error_column_write = 'Y' THEN
      CLOSE error_column_check;
      raise gcs_lex_error_col_write;
    END IF;
    FETCH error_column_check INTO col_name, error_column_write;
    IF error_column_check%FOUND THEN
      CLOSE error_column_check;
      raise gcs_lex_mult_error_columns;
    END IF;
    CLOSE error_column_check;

    OPEN func_reg_check_c;
    FETCH func_reg_check_c INTO derivation_id;
    IF func_reg_check_c%FOUND THEN
      CLOSE func_reg_check_c;
      raise gcs_lex_func_not_registered;
    END IF;
    CLOSE func_reg_check_c;

    IF file_write = 'Y' THEN
      log_file_module_write(module, g_module_success);
    END IF;

    return idt_name;
  EXCEPTION
    WHEN gcs_lex_func_not_registered THEN
      add_plsql_deriv_failed_msg(derivation_id, 'GCS_IDT_FUNC_NOT_REGISTERED',
                                 module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN gcs_lex_invalid_rule_set THEN
      add_id_value_failed_msg(rule_set_id, 'GCS_IDT_INVALID_RULE_SET',
                              module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN gcs_lex_disabled THEN
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise;
    WHEN gcs_lex_set_no_stage THEN
      IF usage = 'TRANSFORMATION' THEN
        add_idt_failed_msg(rule_set_id, 'GCS_IDT_SET_NO_STAGE',
                           module, file_write);
      ELSE
        add_idt_failed_msg(rule_set_id, 'GCS_IDT_VRS_SET_NO_RULE',
                           module, file_write);
      END IF;
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN gcs_lex_stage_no_rule THEN
      add_stage_failed_msg(stage_id, 'GCS_IDT_STAGE_NO_RULE',
                           module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN gcs_lex_no_error_column THEN
      add_structure_failed_msg(rule_set_id, 'GCS_IDT_NO_ERROR_COLUMN',
                               module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN gcs_lex_mult_error_columns THEN
      add_structure_failed_msg(rule_set_id, 'GCS_IDT_MULT_ERROR_COLUMNS',
                               module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN gcs_lex_error_col_write THEN
      add_column_failed_msg(col_name, 'GCS_IDT_ERROR_COL_WRITE',
                            module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
    WHEN OTHERS THEN
      add_id_value_failed_msg(rule_set_id, 'GCS_IDT_UNEXPECTED_INIT_ERROR',
                              module, file_write);
      IF file_write = 'Y' THEN
        log_file_module_write(module, g_module_failure);
      END IF;
      raise gcs_lex_init_failed;
  END Initial_Rule_Set_Check;

  --
  -- Procedure
  --   Staging_Table_Check
  -- Purpose
  --   Checks that the table has all the columns specified in the meta data
  --   repository.
  -- Arguments
  --   Table_Name	Table to check.
  --   Rule_Set_Id	ID of the rule set to check against.
  -- Example
  --   GCS_LEX_MAP_PKG.Table_Check('gl_interface', 111);
  -- Notes
  --
  PROCEDURE Staging_Table_Check(Table_Name	VARCHAR2,
				Rule_Set_Id	NUMBER)
  IS
    CURSOR	all_columns IS
    SELECT	mc.column_name
    FROM	gcs_lex_map_columns	mc,
		gcs_lex_map_rule_sets	rst
    WHERE	rst.structure_id = mc.structure_id
    AND		rst.rule_set_id = staging_table_check.rule_set_id;

    check_text	VARCHAR2(32767);

    TYPE check_cursor IS REF CURSOR;
    check_cv	check_cursor;

    num_cols	NUMBER := 0;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Staging_Table_Check';
    log_file_module_write(module, g_module_enter);

    check_text := 'SELECT ';
    FOR column IN all_columns LOOP
      IF num_cols > 0 THEN
        check_text := check_text || ',';
      END IF;
      check_text := check_text || column.column_name;
      num_cols := num_cols + 1;
    END LOOP;
    check_text := check_text || ' FROM ' || table_name;

    OPEN check_cv FOR check_text;
    CLOSE check_cv;

    log_file_module_write(module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      add_staging_table_failed_msg(table_name, 'GCS_IDT_STG_TABLE_NOT_META',
                                   module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_table_check_failed;
  END Staging_Table_Check;

  --
  -- Procedure
  --   Get_Filter_Text
  -- Purpose
  --   Puts all the query criteria together to create filter text.
  -- Arguments
  --   Rule_Set_Id		The IDT being used for the transformation.
  --   Usage			Transformation or Validation.
  --   Filter_Column_Name1	First filter column name.
  --   Filter_Column_Value1	Value to match the filter column against.
  --   ...
  --   ...
  -- Example
  --   GCS_LEX_MAP_PKG.Table_Check('GROUP_ID', '123', null, null, ...);
  -- Notes
  --
  FUNCTION Get_Filter_Text(	rule_set_id		NUMBER,
				usage			VARCHAR2,
				filter_column_name1	VARCHAR2,
				filter_column_value1	VARCHAR2,
				filter_column_name2	VARCHAR2,
				filter_column_value2	VARCHAR2,
				filter_column_name3	VARCHAR2,
				filter_column_value3	VARCHAR2,
				filter_column_name4	VARCHAR2,
				filter_column_value4	VARCHAR2,
				filter_column_name5	VARCHAR2,
				filter_column_value5	VARCHAR2,
				filter_column_name6	VARCHAR2,
				filter_column_value6	VARCHAR2,
				filter_column_name7	VARCHAR2,
				filter_column_value7	VARCHAR2,
				filter_column_name8	VARCHAR2,
				filter_column_value8	VARCHAR2,
				filter_column_name9	VARCHAR2,
				filter_column_value9	VARCHAR2,
				filter_column_name10	VARCHAR2,
				filter_column_value10	VARCHAR2)
  RETURN VARCHAR2 IS
    TYPE	FilterColumns IS VARRAY(10) OF VARCHAR2(30);
    TYPE	FilterValues  IS VARRAY(10) OF VARCHAR2(500);

    filtercols	FilterColumns;
    filtervals	FilterValues;

    filter_text	VARCHAR2(5000);

    CURSOR	filter_check(col_name VARCHAR2) IS
    SELECT	decode(	usage,
			'TRANSFORMATION', write_flag,
			error_code_column_flag)
    FROM	gcs_lex_map_rule_sets rst,
		gcs_lex_map_columns mc
    WHERE	mc.structure_id = rst.structure_id
    AND		rst.rule_set_id = get_filter_text.rule_set_id
    AND		UPPER(mc.column_name) = UPPER(col_name);

    filter_write_flag	VARCHAR2(10);

    num_conditions	NUMBER := 0;
    filter_num		NUMBER;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Get_Filter_Text';

    filtercols := FilterColumns(filter_column_name1,
				filter_column_name2,
				filter_column_name3,
				filter_column_name4,
				filter_column_name5,
				filter_column_name6,
				filter_column_name7,
				filter_column_name8,
				filter_column_name9,
				filter_column_name10);

    filtervals := FilterValues(	filter_column_value1,
				filter_column_value2,
				filter_column_value3,
				filter_column_value4,
				filter_column_value5,
				filter_column_value6,
				filter_column_value7,
				filter_column_value8,
				filter_column_value9,
				filter_column_value10);

    filter_text := '';

    log_file_module_write(module, g_module_enter);

    FOR i IN 1..10 LOOP
      filter_num := i;
      IF filtercols(i) IS NOT NULL AND
         filtervals(i) IS NOT NULL THEN
        OPEN filter_check(filtercols(i));
        FETCH filter_check INTO filter_write_flag;
        IF filter_check%NOTFOUND THEN
          CLOSE filter_check;
          raise gcs_lex_invalid_filter_column;
        END IF;
        CLOSE filter_check;

        IF filter_write_flag = 'Y' THEN
          raise gcs_lex_filter_column_not_ro;
        END IF;
        IF num_conditions > 0 THEN
          filter_text := filter_text || ' AND ';
        END IF;
        filter_text := filter_text || filtercols(i) || '=''' ||
                       REPLACE(filtervals(i), '''', '''''') || '''';
        num_conditions := num_conditions + 1;
      ELSIF filtercols(i) IS NOT NULL THEN
        raise gcs_lex_no_filter_value;
      ELSIF filtervals(i) IS NOT NULL THEN
        raise gcs_lex_no_filter_column_name;
      END IF;
    END LOOP;

    log_file_module_write(module, g_module_success);

    return filter_text;
  EXCEPTION
    WHEN gcs_lex_no_filter_column_name THEN
      add_simple_failed_msg('GCS_IDT_NO_FILTER_COLUMN_NAME', module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_filter_error;
    WHEN gcs_lex_no_filter_value THEN
      add_simple_failed_msg('GCS_IDT_NO_FILTER_VALUE', module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_filter_error;
    WHEN gcs_lex_filter_column_not_ro THEN
      add_column_failed_msg(filtercols(filter_num),
                            'GCS_IDT_FILTER_COLUMN_NOT_RO', module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_filter_error;
    WHEN gcs_lex_invalid_filter_column THEN
      add_column_failed_msg(filtercols(filter_num),
                            'GCS_IDT_INVALID_FILTER_COLUMN', module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_filter_error;
    WHEN OTHERS THEN
      add_simple_failed_msg('GCS_IDT_UNEXP_FILTER_ERROR', module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_filter_error;
  END Get_Filter_Text;

  --
  -- Procedure
  --   Validation_Check
  -- Purpose
  --   Checks that the validation for the rule given will work.
  -- Arguments
  --   Rule_Id		Rule for which the validation should be checked.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Validation_Check(123);
  -- Notes
  --
  PROCEDURE Validation_Check(	Rule_Id		NUMBER,
				File_Write	VARCHAR2)
  IS
    CURSOR	all_columns IS
    SELECT	mc.column_name
    FROM	gcs_lex_map_columns	mc,
		gcs_lex_map_rules	r
    WHERE	r.lookup_table_id = mc.structure_id
    AND		r.rule_id = validation_check.rule_id;

    check_text	VARCHAR2(32767);

    TYPE check_cursor IS REF CURSOR;
    check_cv	check_cursor;

    num_cols	NUMBER := 0;

    lookup_code_column_found	VARCHAR2(1);

    -- validation type is 'I' for independent, and 'F' for table-validated.
    CURSOR	value_set_info(val_set_id NUMBER) IS
    SELECT	ffvs.validation_type
    FROM	fnd_flex_value_sets ffvs
    WHERE	ffvs.flex_value_set_id = val_set_id;

    vs_validation_type	VARCHAR2(50);

    tv_vs_check_table	NUMBER;

    valid_type_code	VARCHAR2(30);

    CURSOR	structure_info IS
    SELECT	ms.structure_name
    FROM	gcs_lex_map_rules	r,
		gcs_lex_map_structs	ms
    WHERE	r.lookup_table_id = ms.structure_id
    AND		r.rule_id = validation_check.rule_id;

    table_name		VARCHAR2(100);
    value_set_id	NUMBER;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Validation_Check';
    lookup_code_column_found := 'N';

    SELECT	r.validation_type_code,
		r.value_set_id
    INTO	valid_type_code,
		value_set_id
    FROM	gcs_lex_map_rules r
    WHERE	r.rule_id = validation_check.rule_id;

    IF valid_type_code = 'V' THEN
      OPEN value_set_info(value_set_id);
      FETCH value_set_info INTO vs_validation_type;
      IF value_set_info%NOTFOUND THEN
        CLOSE value_set_info;
        raise gcs_lex_invalid_value_set_id;
      END IF;
      CLOSE value_set_info;

      IF vs_validation_type = 'F' THEN
        -- there should be exactly one row for a table-validated value set
        -- in the validation_tables table.
        SELECT	COUNT(*)
        INTO	tv_vs_check_table
        FROM	fnd_flex_validation_tables	ffvt,
		gcs_lex_map_rules		r
        WHERE	ffvt.flex_value_set_id = r.value_set_id
        AND	r.rule_id = validation_check.rule_id;

        IF tv_vs_check_table <> 1 THEN
          raise gcs_lex_invalid_tv_value_set;
        END IF;
      ELSIF vs_validation_type <> 'I' THEN
        raise gcs_lex_invalid_value_set;
      END IF;
    ELSIF valid_type_code = 'L' THEN
      OPEN structure_info;
      FETCH structure_info INTO table_name;
      IF structure_info%NOTFOUND THEN
        CLOSE structure_info;
        raise gcs_lex_no_validation_lut;
      END IF;
      CLOSE structure_info;

      check_text := 'SELECT ';

      FOR column IN all_columns LOOP
        IF num_cols > 0 THEN
          check_text := check_text || ',';
        END IF;
        check_text := check_text || column.column_name;
        num_cols := num_cols + 1;
        IF UPPER(column.column_name) = 'LOOKUP_CODE' THEN
          lookup_code_column_found := 'Y';
        END IF;
      END LOOP;
      check_text := check_text || ' FROM ' || table_name;

      IF lookup_code_column_found <> 'Y' THEN
        raise gcs_lex_lut_no_lookup_code;
      END IF;

      begin
        OPEN check_cv FOR check_text;
        CLOSE check_cv;
      exception
        when others then
          raise gcs_lex_vdation_lut_not_meta;
      end;
    ELSIF valid_type_code <> 'N' THEN
      raise gcs_lex_invalid_valid_code;
    END IF;
  EXCEPTION
    WHEN gcs_lex_invalid_value_set_id THEN
      add_id_value_failed_msg(value_set_id, 'GCS_IDT_INVALID_VALUE_SET_ID',
                              module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN gcs_lex_invalid_value_set THEN
      add_value_set_failed_msg(rule_id, 'GCS_IDT_INVALID_VALUE_SET',
                               module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN gcs_lex_invalid_tv_value_set THEN
      add_value_set_failed_msg(rule_id, 'GCS_IDT_INVALID_TV_VALUE_SET',
                               module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN gcs_lex_lut_no_lookup_code THEN
      add_rule_lut_failed_msg(rule_id, 'GCS_IDT_LUT_NO_LOOKUP_CODE',
                              module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN gcs_lex_vdation_lut_not_meta THEN
      add_rule_lut_failed_msg(rule_id, 'GCS_IDT_VDATION_LUT_NOT_META',
                              module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN gcs_lex_invalid_valid_code THEN
      add_code_value_failed_msg(valid_type_code, 'GCS_IDT_INVALID_VALID_CODE',
                                module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN gcs_lex_no_validation_lut THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_NO_VALIDATION_LUT',
                          module, file_write);
      raise gcs_lex_valid_check_failed;
    WHEN OTHERS THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_UNEXP_VLD_CHECK_ERROR',
                          module, file_write);
      raise gcs_lex_valid_check_failed;
  END Validation_Check;

  --
  -- Function
  --   Create_Param_List
  -- Purpose
  --   Creates a text list of parameters, whose structure depends on the
  --   list_type_code variable passed in. This will create a function header
  --   style list, or a argument-passing (comma-delimited) style list.
  -- Arguments
  --   Rule_Id		Rule for which the parameter list should be created.
  --   List_Type_Code	'F' for function header, or 'C' for a comma-delimited.
  --                    'H' for error header, 'Q' for error query.
  --   File_Write	'Y' if writing to a log file.
  -- Example
  --   str := GCS_LEX_MAP_PKG.Create_Param_List(123, 'F')
  -- Notes
  --
  FUNCTION Create_Param_List(	Rule_Id		NUMBER,
				List_Type_Code	VARCHAR2,
				File_Write	VARCHAR2)
  RETURN VARCHAR2 IS
    param_list	VARCHAR2(32767);
    my_lang	VARCHAR2(5);
    my_security	NUMBER;

    -- Cursor listing all parameters necessary to run this function
    CURSOR	all_params IS
    (SELECT	mc.column_name column_name,
		decode(mc.column_type_code,	'N', 'NUMBER',
						'D', 'DATE',
						'V', 'VARCHAR2',
						'') column_type_code
     FROM	gcs_lex_map_columns mc,
		gcs_lex_map_rules r
     WHERE	mc.column_id = r.target_column_id
     AND	r.rule_id = create_param_list.rule_id)
    UNION
    (SELECT	mc.column_name column_name,
		decode(mc.column_type_code,	'N', 'NUMBER',
						'D', 'DATE',
						'V', 'VARCHAR2',
						'') column_type_code
     FROM	gcs_lex_map_columns mc,
		gcs_lex_map_drv_details dvd,
		gcs_lex_map_derivations d
     WHERE	d.rule_id = create_param_list.rule_id
     AND	dvd.derivation_id = d.derivation_id
     AND	dvd.detail_column_id = mc.column_id)
    UNION
    (SELECT	mc.column_name column_name,
		decode(mc.column_type_code,	'N', 'NUMBER',
						'D', 'DATE',
						'V', 'VARCHAR2',
						'') column_type_code
     FROM	gcs_lex_map_columns mc,
		gcs_lex_map_conditions c,
		gcs_lex_map_derivations d
     WHERE	d.rule_id = create_param_list.rule_id
     AND	c.derivation_id = d.derivation_id
     AND	c.source_column_id = mc.column_id)
    ORDER BY column_name;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_Param_List';
    param_list := '';
    my_lang := userenv('LANG');
    my_security := fnd_global.lookup_security_group('COLUMN_TYPE', 0);

    -- First, pass in the row ID to the function (error checking purposes)
    -- if this is not error checking. Then, loop through the params.
    IF list_type_code = 'F' THEN
      param_list := 'row_id rowid';
      FOR param IN all_params LOOP
        param_list := param_list || ',' ||
                      param.column_name || ' ' || param.column_type_code;
      END LOOP;
    ELSIF list_type_code = 'C' THEN
      param_list := 'rowid';
      FOR param IN all_params LOOP
        param_list := param_list || ',' || param.column_name;
      END LOOP;
    ELSIF list_type_code = 'H' THEN
      FOR param IN all_params LOOP
        param_list := param_list ||RPAD(SUBSTR(param.column_name,1,19),20,' ');
      END LOOP;
    ELSIF list_type_code = 'Q' THEN
      FOR param IN all_params LOOP
        IF param_list IS NOT NULL THEN
          param_list := param_list || ' || ';
        END IF;
        param_list := param_list || 'RPAD(nvl(SUBSTR(' || param.column_name ||
                                    ',1,19), '' ''),20,'' '')';
      END LOOP;
    ELSE
      raise gcs_lex_invalid_list_code;
    END IF;

    return param_list;
  EXCEPTION
    WHEN gcs_lex_invalid_list_code THEN
      add_code_value_failed_msg(list_type_code, 'GCS_IDT_INVALID_LIST_CODE',
                                module, file_write);
      raise gcs_lex_param_list_failed;
    WHEN OTHERS THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_PARAM_LIST_FAILED',
                          module, file_write);
      raise gcs_lex_param_list_failed;
  END Create_Param_List;

  --
  -- Function
  --   Create_Condition
  -- Purpose
  --   Creates the text for the condition that is associated with the
  --   derivation given.
  -- Arguments
  --   Derivation_Id		ID of the Derivation for which the
  --				condition text should be created.
  -- Example
  --   str := GCS_LEX_MAP_PKG.Create_Condition(12345)
  -- Notes
  --
  FUNCTION Create_Condition(		Derivation_Id	NUMBER)
  RETURN VARCHAR2 IS
    cond_text VARCHAR2(8000);

    CURSOR	all_conds IS
    SELECT	mc.column_name || ' ' || c.comparison_operator_code ||
		decode(c.comparison_value,
                    '', '',
                    ' ''' || REPLACE(c.comparison_value, '''', '''''') || '''')
                  simple_cond
    FROM	gcs_lex_map_columns mc,
		gcs_lex_map_conditions c
    WHERE	c.derivation_id = create_condition.derivation_id
    AND		c.source_column_id = mc.column_id;

    -- for the first condition, do not add ' AND '
    num_conditions    NUMBER := 0;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_Condition';
    cond_text := '';

    FOR cond IN all_conds LOOP
      IF num_conditions > 0 THEN
        cond_text := cond_text || ' AND ';
      END IF;
      cond_text := cond_text || cond.simple_cond;
      num_conditions := num_conditions + 1;
    END LOOP;

    return cond_text;
  EXCEPTION
    WHEN OTHERS THEN
      add_deriv_failed_msg(derivation_id, 'GCS_IDT_CREATE_COND_FAILED',
                           module, 'N');
      raise gcs_lex_create_cond_failed;
  END Create_Condition;

  --
  -- Function
  --   Create_Lookup_Derivation
  -- Purpose
  --   Creates the text for the lookup derivation specified.
  -- Arguments
  --   Func_Name	Wrapper function name for which this lookup derivation
  --			is being created.
  --   Derivation_Id	ID of the Derivation for which the lookup derivation
  --			text should be created.
  --   Usage		'TRANSFORMATION' or 'VALIDATION' based ont he calling
  --			function.
  -- Example
  --   str := GCS_LEX_MAP_PKG.Create_Lookup_Derivation(101, 123, 12345)
  -- Notes
  --
  FUNCTION Create_Lookup_Derivation(	Func_Name	VARCHAR2,
					Derivation_Id	NUMBER,
					Usage		VARCHAR2)
  RETURN VARCHAR2 IS
    deriv_text VARCHAR2(16000);

    CURSOR	all_lookup_details IS
    SELECT	lutmc.column_name	lut_col_name,
		stgmc.column_name	stg_col_name,
		dvd.detail_constant	detail_constant
    FROM	gcs_lex_map_drv_details	dvd,
		gcs_lex_map_columns	lutmc,
		gcs_lex_map_columns	stgmc
    WHERE	dvd.derivation_id = create_lookup_derivation.derivation_id
    AND		dvd.lookup_column_id = lutmc.column_id
    AND		dvd.detail_column_id = stgmc.column_id (+);

    -- For the first join, a 'WHERE' should be added, while for subsequent
    -- joins an 'AND' should be added
    num_joins	NUMBER := 0;

    -- result column name and lookup table name
    lookup_table_name	VARCHAR2(50);
    result_col_name	VARCHAR2(30);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_Lookup_Derivation';
    IF usage = 'TRANSFORMATION' THEN
      SELECT	ms.structure_name,
		mc.column_name
      INTO	lookup_table_name,
		result_col_name
      FROM	gcs_lex_map_derivations d,
		gcs_lex_map_columns mc,
		gcs_lex_map_structs ms
      WHERE	d.lookup_result_column_id = mc.column_id
      AND	mc.structure_id = ms.structure_id
      AND	d.derivation_id = create_lookup_derivation.derivation_id;

      deriv_text := 'SELECT lut.' || result_col_name || ' INTO ' || g_ret_val;
    ELSE
      SELECT	ms.structure_name
      INTO	lookup_table_name
      FROM	gcs_lex_map_structs ms,
		gcs_lex_map_derivations d
      WHERE	d.lookup_table_id = ms.structure_id
      AND	d.derivation_id = create_lookup_derivation.derivation_id;

      deriv_text := 'SELECT DISTINCT 1 INTO dummy';
    END IF;

    deriv_text := deriv_text || ' FROM ' || lookup_table_name || ' lut WHERE ';

    FOR lookup_detail IN all_lookup_details LOOP
      IF num_joins > 0 THEN
        deriv_text := deriv_text || ' AND ';
      END IF;

      -- When a column is specified, match to that. Otherwise, match to the
      -- constant given.
      deriv_text := deriv_text ||'lut.'|| lookup_detail.lut_col_name || '=';
      IF lookup_detail.stg_col_name IS NOT NULL THEN
        deriv_text := deriv_text || func_name || '.' ||
                      lookup_detail.stg_col_name;
      ELSE
        deriv_text := deriv_text || '''' ||
                      REPLACE(lookup_detail.detail_constant, '''', '''''') ||
                      '''';
      END IF;

      num_joins := num_joins + 1;
    END LOOP;

    deriv_text := deriv_text || ';';

    return deriv_text;
  EXCEPTION
    WHEN OTHERS THEN
      add_deriv_failed_msg(derivation_id, 'GCS_IDT_DERIVATION_FAILED',
                           module, 'N');
      raise gcs_lex_derivation_failed;
  END Create_Lookup_Derivation;

  --
  -- Function
  --   Create_String_Derivation
  -- Purpose
  --   Creates the text for the string derivation specified.
  -- Arguments
  --   Derivation_Id		ID of the Derivation for which the
  --				string derivation text should be created.
  -- Example
  --   str := GCS_LEX_MAP_PKG.Create_String_Derivation(12345)
  -- Notes
  --
  FUNCTION Create_String_Derivation(	Derivation_Id	NUMBER)
  RETURN VARCHAR2 IS
    deriv_text VARCHAR2(16000);

    -- get the list of strings to concatenate here, in the correct order
    CURSOR	all_string_details IS
    SELECT	decode(string_action_type_code,
			'S', 'SUBSTR('||mc.column_name || ',' ||
			     dvd.substring_start_index || ',' ||
			     dvd.substring_length || ')',
			'C', mc.column_name,
			'F', '''' ||
                             REPLACE(dvd.detail_constant, '''', '''''') ||
                             '''',
			'') string_action
    FROM	gcs_lex_map_drv_details dvd,
		gcs_lex_map_columns mc
    WHERE	dvd.derivation_id = create_string_derivation.derivation_id
    AND		dvd.detail_column_id = mc.column_id (+)
    ORDER BY	dvd.string_merge_order;

    -- For the first string, you do not add a '||' for concatentation
    num_strings NUMBER := 0;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_String_Derivation';
    deriv_text := g_ret_val || ':=';

    FOR string_detail IN all_string_details LOOP
      IF num_strings > 0 THEN
        deriv_text := deriv_text || '||';
      END IF;
      deriv_text := deriv_text || string_detail.string_action;
      num_strings := num_strings + 1;
    END LOOP;

    -- if there were no strings to concatenate, just put in the empty string.
    IF num_strings = 0 THEN
      deriv_text := deriv_text || '''''';
    END IF;

    deriv_text := deriv_text || ';';

    return deriv_text;
  EXCEPTION
    WHEN OTHERS THEN
      add_deriv_failed_msg(derivation_id, 'GCS_IDT_DERIVATION_FAILED',
                           module, 'N');
      raise gcs_lex_derivation_failed;
  END Create_String_Derivation;

  --
  -- Function
  --   Create_PLSQL_Derivation
  -- Purpose
  --   Creates the text for the PL/SQL function derivation specified.
  -- Arguments
  --   Derivation_Id	ID of the Derivation for which the PL/SQL function
  --			derivation text should be created.
  --   Usage		'TRANSFORMATION' or 'VALIDATION' based ont he calling
  --			function.
  -- Example
  --   str := GCS_LEX_MAP_PKG.Create_PLSQL_Derivation(12345)
  -- Notes
  --
  FUNCTION Create_PLSQL_Derivation(	Derivation_Id	NUMBER,
					Usage		VARCHAR2)
  RETURN VARCHAR2 IS
    deriv_text VARCHAR2(16000);

    CURSOR	all_params IS
    SELECT	plsql_param_name || '=>' ||
		decode(plsql_param_source_code,
                  'C', mc.column_name,
                  'S',''''||REPLACE(dvd.detail_constant, '''', '''''')||'''',
                  'N',dvd.detail_constant,
                  '') plsql_parameter
    FROM	gcs_lex_map_drv_details dvd,
		gcs_lex_map_columns mc
    WHERE	dvd.derivation_id = create_plsql_derivation.derivation_id
    AND		dvd.detail_column_id = mc.column_id (+);

    -- Don't add a ',' to the beginning for the first parameter passed in
    num_params NUMBER := 0;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_PLSQL_Derivation';

    SELECT	function_name
    INTO	deriv_text
    FROM	gcs_lex_map_derivations d
    WHERE	d.derivation_id = create_plsql_derivation.derivation_id;

    -- With the validation case, we only pass in the rowid
    IF usage = 'VALIDATION' THEN
      return deriv_text || '(row_id)';
    END IF;

    deriv_text := g_ret_val || ':=' || deriv_text;

    FOR param IN all_params LOOP
      IF num_params > 0 THEN
        deriv_text := deriv_text || ',' || param.plsql_parameter;
      ELSE
        deriv_text := deriv_text || '(' || param.plsql_parameter;
      END IF;
      num_params := num_params + 1;
    END LOOP;

    IF num_params > 0 THEN
      deriv_text := deriv_text || ')';
    END IF;

    deriv_text := deriv_text || ';';

    return deriv_text;
  EXCEPTION
    WHEN OTHERS THEN
      add_deriv_failed_msg(derivation_id, 'GCS_IDT_DERIVATION_FAILED',
                           module, 'N');
      raise gcs_lex_derivation_failed;
  END Create_PLSQL_Derivation;

  --
  -- Procedure
  --   Remove_Function
  -- Purpose
  --   Drops the given function if it exists. Passes through quietly if it
  --   doesn't exist.
  -- Arguments
  --   Func_Name		Name of the function to remove.
  -- Example
  --   GCS_LEX_MAP_PKG.Remove_Function('GCS_LEX_GET_111_123');
  -- Notes
  --
  PROCEDURE Remove_Function(func_name VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE 'drop function ' || func_name;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END Remove_Function;

  --
  -- Procedure
  --   Remove_All_Functions
  -- Purpose
  --   Drops all functions for the given rule set that are not used.
  -- Arguments
  --   Rule_Set_Id	Rule set for which the functions should be removed.
  -- Example
  --   GCS_LEX_MAP_PKG.Remove_All_Functions(101);
  -- Notes
  --
  PROCEDURE Remove_All_Functions(p_rule_set_id NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR	all_funcs IS
    SELECT	object_name
    FROM	user_objects
    WHERE	object_name LIKE
                  'GCS\_LEX\_GET\_' || p_rule_set_id || '\__%' ESCAPE '\'
    AND		object_name NOT IN
		(SELECT	'GCS_LEX_GET_' || p_rule_set_id || '_' || r.rule_id
		 FROM	gcs_lex_map_rules r,
			gcs_lex_map_rule_stages stg
		 WHERE	stg.rule_set_id = p_rule_set_id
		 AND	stg.rule_stage_id = r.rule_stage_id)
    AND		object_type = 'FUNCTION';
  BEGIN
    FOR map_func IN all_funcs LOOP
      execute immediate 'drop function ' || map_func.object_name;
    END LOOP;
  END Remove_All_Functions;

  --
  -- Procedure
  --   Test_Deriv
  -- Purpose
  --   Creates the text for a PL/SQL function which will take a number of
  --   inputs and return the appropriate target value for the given rule.
  --   Then applies it to the database using dynamic SQL.
  -- Arguments
  --   Test_Func_Name		Name of the testing function.
  --   Param_List		Minimal list of parameters necessary for the
  --				rule this derivation is part of.
  --   Target_Column_Type	Specifies the type of the column.
  --   Derivation_Text		Text of the derivation to test.
  --   Derivation_Id		ID of derivation being tested.
  --   My_Appl			APPLSYS schema, which is needed for ad_ddl.
  -- Example
  --   GCS_LEX_MAP_PKG.Test_Deriv
  --     ('gcs_lex_get_111_123',
  --      'segment1 varchar2, acct_date date',
  --      'V',
  --      'gcs_rv_ := ''ABC'' || segment1; ');
  -- Notes
  --
  PROCEDURE Test_Deriv(	Test_Func_Name		VARCHAR2,
			Param_List		VARCHAR2,
			Target_Column_Type	VARCHAR2,
			Derivation_Text		VARCHAR2,
			Derivation_Id		NUMBER,
			My_Appl			VARCHAR2)
  IS
    module	VARCHAR2(60);

    rv_declaration	VARCHAR2(50);
  BEGIN
    module := g_api || '.Test_Deriv';

    IF target_column_type = 'N' THEN
      rv_declaration := 'NUMBER IS ' || g_ret_val || ' NUMBER;';
    ELSIF target_column_type = 'D' THEN
      rv_declaration := 'DATE IS ' || g_ret_val || ' DATE;';
    ELSE
      rv_declaration := 'VARCHAR2 IS ' || g_ret_val || ' VARCHAR2(32767);';
    END IF;

    IF create_ad('CREATE OR REPLACE FUNCTION ' || test_func_name ||
                 '(' || param_list || ') RETURN ' || rv_declaration ||
                 'BEGIN ' || derivation_text ||
                 'return ' || g_ret_val || ';' ||
                 'END ' || test_func_name || ';',
                 test_func_name, my_appl) <> 'FALSE' THEN
      raise gcs_lex_func_failed;
    END IF;

    remove_function(test_func_name);
  EXCEPTION
    WHEN OTHERS THEN
      add_deriv_failed_msg(derivation_id, 'GCS_IDT_DERIVATION_FAILED',
                           module, 'N');
      remove_function(test_func_name);
  END Test_Deriv;

  --
  -- Function
  --   Create_Get_Function
  -- Purpose
  --   Creates the text for a PL/SQL function which will take a number of
  --   inputs and return the appropriate target value for the given rule.
  --   Then applies it to the database using dynamic SQL. Returns 'Y' or 'N'
  --   depending on the success of creating the function.
  -- Arguments
  --   Rule_Set_Id	Rule Set for which the function should be created.
  --   Rule_Id		Rule for which the function should be created.
  --   My_Appl		APPLSYS schema, which is needed for ad_ddl.
  -- Example
  --   GCS_LEX_MAP_PKG.Create_Get_Function(111, 123, 'APPLSYS')
  -- Notes
  --
  FUNCTION Create_Get_Function(	Rule_Set_Id	NUMBER,
				Rule_Id		NUMBER,
				My_Appl		VARCHAR2) RETURN VARCHAR2 IS
    func_body	VARCHAR2(32767);

    CURSOR	all_derivs IS
    SELECT	d.derivation_id, d.derivation_type_code
    FROM	gcs_lex_map_derivations d
    WHERE	d.rule_id = create_get_function.rule_id
    ORDER BY	d.derivation_sequence;

    CURSOR	check_condition_c(c_deriv_id NUMBER) IS
    SELECT	1
    FROM	gcs_lex_map_conditions c
    WHERE	c.derivation_id = c_deriv_id;

    dummy	NUMBER;

    num_derivs		NUMBER := 0;
    cond_exists		BOOLEAN;

    target_col_name	VARCHAR2(30);
    target_column_type	VARCHAR2(30);
    target_write_flag	VARCHAR2(1);

    -- wrapper function name for this rule, and parameter list
    func_name	VARCHAR2(30);
    param_list	VARCHAR2(8000);

    default_condition_made	VARCHAR2(1);

    exc_txt1	VARCHAR2(500);
    exc_txt2	VARCHAR2(250);

    -- If an exception occurs, pass back some meaningless value, since it
    -- will be rolled back anyway.
    default_return	VARCHAR2(20);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_Get_Function';
    func_name :='gcs_lex_get_' || rule_set_id || '_' || rule_id;
    default_condition_made := 'N';

    exc_txt1 :=
      'declare error_info GCS_LEX_MAP_API_PKG.error_record_type;' ||
      'begin error_info.rule_id := ' || rule_id || ';' ||
      'error_info.deriv_num := ' || g_deriv_num || ';' ||
      'error_info.row_id := ' || func_name || '.row_id;' ||
      'error_info.error_code := ''';

    exc_txt2 :=
      ''';' ||
      'GCS_LEX_MAP_API_PKG.error_table(GCS_LEX_MAP_API_PKG' ||
      '.error_table.COUNT+1):=error_info;' ||
      'end;';

    validation_check(rule_id, 'N');

    param_list := create_param_list(rule_id, 'F', 'N');

    SELECT	mc.column_name, mc.column_type_code, mc.write_flag
    INTO	target_col_name, target_column_type, target_write_flag
    FROM	gcs_lex_map_rules r,
		gcs_lex_map_columns mc
    WHERE	r.target_column_id = mc.column_id
    AND		r.rule_id = create_get_function.rule_id;

    IF target_write_flag <> 'Y' THEN
      raise gcs_lex_read_only_column_rule;
    END IF;

    -- first get the function header information
    func_body := 'CREATE OR REPLACE FUNCTION ' || func_name || '(' ||
                 param_list || ') RETURN ';
    IF target_column_type = 'N' THEN
      default_return := 'return 0;';
      func_body := func_body || 'NUMBER IS ' || g_ret_val || ' NUMBER;';
    ELSIF target_column_type = 'D' THEN
      default_return := 'return sysdate;';
      func_body := func_body || 'DATE IS ' || g_ret_val || ' DATE;';
    ELSE
      default_return := 'return ''a'';';
      func_body := func_body || 'VARCHAR2 IS '||g_ret_val||' VARCHAR2(32767);';
    END IF;

    func_body := func_body || g_deriv_num || ' NUMBER := -1;BEGIN ';

    FOR cond_deriv IN all_derivs LOOP
      IF default_condition_made = 'Y' THEN
        raise gcs_lex_def_cond_not_last;
      END IF;

      -- Find if any conditions exist for the derivation
      OPEN check_condition_c(cond_deriv.derivation_id);
      FETCH check_condition_c INTO dummy;
      cond_exists := check_condition_c%FOUND;
      CLOSE check_condition_c;

      IF num_derivs = 0 THEN
        IF cond_exists THEN
          func_body :=
            func_body || g_ret_val || ':=' || target_col_name || ';' ||
            'IF ' || create_condition(cond_deriv.derivation_id) || ' THEN ';
        ELSE
          default_condition_made := 'Y';
        END IF;
      ELSIF NOT cond_exists THEN
        func_body := func_body || 'ELSE ';
        default_condition_made := 'Y';
      ELSE
        func_body := func_body || 'ELSIF ' ||
                     create_condition(cond_deriv.derivation_id) || ' THEN ';
      END IF;

      -- register that we are entering this derivation number in case an
      -- exception is raised. Then, perform the derivation.
      func_body := func_body || g_deriv_num || ':=' ||
                   to_char(num_derivs+1) || ';';

      IF cond_deriv.derivation_type_code = 'LUT' THEN
        func_body := func_body || create_lookup_derivation
                                  (func_name, cond_deriv.derivation_id,
                                   'TRANSFORMATION');
      ELSIF cond_deriv.derivation_type_code = 'STR' THEN
        func_body := func_body || create_string_derivation
                                  (cond_deriv.derivation_id);
      ELSE
        func_body := func_body || create_plsql_derivation
                                  (cond_deriv.derivation_id, 'TRANSFORMATION');
      END IF;

      num_derivs := num_derivs + 1;
    END LOOP;

    IF num_derivs = 0 THEN
      raise gcs_lex_rule_no_derivation;
    -- if there was an 'IF' statement, then finish that 'IF' statement
    ELSIF num_derivs > 1 OR cond_exists THEN
      func_body := func_body || 'END IF;';
    END IF;

    func_body := func_body || 'return ' || g_ret_val ||
                 ';EXCEPTION ' ||
                 'WHEN TOO_MANY_ROWS THEN ' ||
                 exc_txt1 || g_error_lookup_tmr || exc_txt2 || default_return||
                 'WHEN NO_DATA_FOUND THEN ' ||
                 exc_txt1 || g_error_lookup_ndf || exc_txt2 || default_return||
                 'WHEN VALUE_ERROR THEN ' ||
                 exc_txt1 || g_error_type_mismatch ||exc_txt2||default_return||
                 'WHEN OTHERS THEN ' ||
                 exc_txt1 || g_error_unexpected || exc_txt2 || default_return||
                 'END ' || func_name || ';';

    -- Print out the function body to the log repository if appropriate.
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT, module, func_body);
    END IF;

    IF create_ad(func_body, func_name, my_appl) <> 'FALSE' THEN
      raise gcs_lex_func_failed;
    END IF;

    return 'Y';
  EXCEPTION
    WHEN gcs_lex_read_only_column_rule THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_READ_ONLY_COLUMN_RULE',
                          module, 'N');
      return 'N';
    WHEN gcs_lex_def_cond_not_last THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_DEF_COND_NOT_LAST', module, 'N');
      return 'N';
    WHEN gcs_lex_rule_no_derivation THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_RULE_NO_DERIVATION', module, 'N');
      return 'N';
    WHEN gcs_lex_param_list_failed OR
         gcs_lex_create_cond_failed OR
         gcs_lex_derivation_failed OR
         gcs_lex_valid_check_failed THEN
      return 'N';
    WHEN gcs_lex_func_failed THEN
      FOR cond_deriv IN all_derivs LOOP
        -- Check for errors in each derivation
        IF cond_deriv.derivation_type_code = 'LUT' THEN
          test_deriv
          (func_name, param_list, target_column_type,
           create_lookup_derivation(func_name, cond_deriv.derivation_id,
                                    'TRANSFORMATION'),
           cond_deriv.derivation_id, my_appl);
        ELSIF cond_deriv.derivation_type_code = 'STR' THEN
          test_deriv(func_name, param_list, target_column_type,
                     create_string_derivation(cond_deriv.derivation_id),
                     cond_deriv.derivation_id, my_appl);
        ELSIF cond_deriv.derivation_type_code = 'PLS' THEN
          test_deriv(func_name, param_list, target_column_type,
                     create_plsql_derivation(cond_deriv.derivation_id,
                                             'TRANSFORMATION'),
                     cond_deriv.derivation_id, my_appl);
        END IF;
      END LOOP;
      return 'N';
    WHEN OTHERS THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_RULE_UNEXPECTED', module, 'N');
      return 'N';
  END Create_Get_Function;

  --
  -- Function
  --   Validate_Column
  -- Purpose
  --   Validates the values in a column after a rule stage has been applied.
  --   Returns 'Y' if the validation succeeded, and 'N' if it failed.
  -- Arguments
  --   Rule_Id			Rule ID for the validation.
  --   Target_Col_Name		Column to validate.
  --   Validation_Type_Code	'L' for lookup validation, 'V' for value set
  --				validation.
  --   Lookup_Table_Name	Name of the lookup table if this is a lookup
  --				validation.
  --   Value_Set_Id		ID for the value set if this is a value set
  --				validation.
  --   Staging_Table_Name	Staging table to validate.
  --   Filter_Text		Text of the filter criteria
  -- Example
  --   str := GCS_LEX_MAP_PKG.Validate_Column(12345, 'segment1', 'L',
  --                                          'my_lookup_tbl', null,
  --                                          'gl_interface', 'group_id',
  --                                          '1000')
  -- Notes
  --
  FUNCTION Validate_Column(	Rule_Id			NUMBER,
				Target_Col_Name		VARCHAR2,
				Validation_Type_Code	VARCHAR2,
				Lookup_Table_Name	VARCHAR2,
				Value_Set_Id		NUMBER,
				Staging_Table_Name	VARCHAR2,
				Filter_Text		VARCHAR2)
  RETURN VARCHAR2
  IS
    TYPE error_cursor_type IS REF CURSOR;
    error_cv		error_cursor_type;
    error_rec		error_record_type;

    validation_text	VARCHAR2(32767);
    filter_clause	VARCHAR2(200);

    vs_validation_type	VARCHAR2(50);

    tv_table_name	VARCHAR2(250);
    tv_column_name	VARCHAR2(250);
    tv_enabled_column	VARCHAR2(250);
    tv_summary_flag	VARCHAR2(1);
    tv_summary_column	VARCHAR2(250);
    tv_where_clause	LONG;

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Validate_Column';
    filter_clause := '';

    validation_check(rule_id, 'Y');

    validation_text := 'SELECT rowid FROM ' || staging_table_name ||
                       ' stg WHERE ';

    IF filter_text IS NOT NULL THEN
      filter_clause := ' AND ' || filter_text;
    END IF;

    IF validation_type_code = 'V' THEN
      -- validation type is 'I' for independent, and 'F' for table-validated.
      SELECT	ffvs.validation_type
      INTO	vs_validation_type
      FROM	fnd_flex_value_sets ffvs
      WHERE	ffvs.flex_value_set_id = validate_column.value_set_id;

      IF vs_validation_type = 'I' THEN
        validation_text := validation_text || 'NOT EXISTS ' ||
                           '(SELECT 1 FROM fnd_flex_values ffv ' ||
                           'WHERE ffv.flex_value_set_id=' || value_set_id ||
                           ' AND ffv.flex_value = stg.' || target_col_name ||
                           ' AND ffv.summary_flag = ''N'' ' ||
                           'AND ffv.enabled_flag = ''Y'')' || filter_clause;
      ELSE -- table-validated value set
        -- extra info for table-validated value sets.
        SELECT	ffvt.application_table_name,
		ffvt.value_column_name,
		ffvt.enabled_column_name,
		ffvt.summary_allowed_flag,
		ffvt.summary_column_name,
		ffvt.additional_where_clause
        INTO	tv_table_name,
		tv_column_name,
		tv_enabled_column,
		tv_summary_flag,
		tv_summary_column,
		tv_where_clause
        FROM	fnd_flex_validation_tables ffvt
        WHERE	ffvt.flex_value_set_id = validate_column.value_set_id;

        validation_text := validation_text || 'NOT EXISTS ' ||
                           '(SELECT 1 FROM (SELECT * FROM ' || tv_table_name ||
                           ' ' || tv_where_clause || ') ffv WHERE ffv.' ||
                           tv_column_name || '=stg.' || target_col_name ||
                           ' AND ' || tv_enabled_column || '=''Y''';

        -- add the summary flag information if applicable
        IF tv_summary_flag = 'Y' THEN
          validation_text := validation_text || ' AND ' || tv_summary_column ||
                             '=''N''';
        END IF;

        validation_text := validation_text || ')' || filter_clause;
      END IF;

      OPEN error_cv FOR validation_text;
      LOOP
        FETCH error_cv INTO error_rec.row_id;
        EXIT WHEN error_cv%NOTFOUND;
        error_rec.rule_id := rule_id;
        error_rec.deriv_num := null;
        error_rec.error_code := g_error_vsv_failed;
        error_table(error_table.COUNT + 1) := error_rec;
      END LOOP;
      CLOSE error_cv;

      IF error_table.COUNT > 0 THEN
        raise gcs_lex_fail_vs_validation;
      END IF;
    ELSE -- validation_type_code = 'L'
      validation_text := validation_text ||
                         'NOT EXISTS (SELECT 1 FROM ' || lookup_table_name ||
                         ' lut WHERE stg.' || target_col_name ||
                         '=lut.lookup_code)' || filter_clause;
      OPEN error_cv FOR validation_text;
      LOOP
        FETCH error_cv INTO error_rec.row_id;
        EXIT WHEN error_cv%NOTFOUND;
        error_rec.rule_id := rule_id;
        error_rec.deriv_num := null;
        error_rec.error_code := g_error_lutv_failed;
        error_table(error_table.COUNT + 1) := error_rec;
      END LOOP;
      CLOSE error_cv;

      IF error_table.COUNT > 0 THEN
        raise gcs_lex_fail_lut_validation;
      END IF;
    END IF;

    return 'Y';
  EXCEPTION
    WHEN gcs_lex_valid_check_failed THEN
      return 'N';
    WHEN gcs_lex_fail_vs_validation THEN
      add_value_set_failed_msg(rule_id, 'GCS_IDT_FAIL_VS_VALIDATION',
                               module, 'Y');
      return 'N';
    WHEN gcs_lex_fail_lut_validation THEN
      add_rule_lut_failed_msg(rule_id, 'GCS_IDT_FAIL_LUT_VALIDATION',
                              module, 'Y');
      return 'N';
    WHEN OTHERS THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_UNEXP_VALID_ERROR', module, 'Y');
      return 'N';
  END Validate_Column;

  --
  -- Procedure
  --   Validate_Results
  -- Purpose
  --   Validates the results for a rule stage.
  -- Arguments
  --   Rule_Stage_Id		ID of the Rule Stage whose results should
  --				be validated.
  --   Staging_Table_Name	Staging table on which the rule stage
  --				was applied.
  --   Filter_Text		Text of the filter criteria.
  -- Example
  --   GCS_LEX_MAP_PKG.Validate_Results(134,'gl_interface','group_id=''1000''')
  -- Notes
  --
  PROCEDURE Validate_Results(	Rule_Stage_Id		NUMBER,
				Staging_Table_Name	VARCHAR2,
				Filter_Text		VARCHAR2)
  IS
    CURSOR	all_validations IS
    SELECT	r.rule_id		rule_id,
		tgtmc.column_name	target_col_name,
		r.validation_type_code	validation_type_code,
		lutms.structure_name	lookup_table_name,
		r.value_set_id		value_set_id
    FROM	gcs_lex_map_rules r,
		gcs_lex_map_columns tgtmc,
		gcs_lex_map_structs lutms
    WHERE	r.rule_stage_id = validate_results.rule_stage_id
    AND		r.target_column_id = tgtmc.column_id
    AND		r.lookup_table_id = lutms.structure_id (+)
    AND		r.validation_type_code <> 'N';

    valid_failed	VARCHAR2(1);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Validate_Results';
    valid_failed := 'N';

    log_file_module_write(module, g_module_enter);

    FOR validation IN all_validations LOOP
      IF validate_column(	validation.rule_id,
				validation.target_col_name,
				validation.validation_type_code,
				validation.lookup_table_name,
				validation.value_set_id,
				staging_table_name,
				filter_text) <> 'Y' THEN
        valid_failed := 'Y';
      END IF;
    END LOOP;

    IF valid_failed = 'Y' THEN
      raise gcs_lex_validation_failed;
    END IF;

    log_file_module_write(module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      log_file_module_write(module, g_module_failure);
      raise;
  END Validate_Results;

  --
  -- Procedure
  --   Apply_Stage
  -- Purpose
  --   Applies the rules for a stage to the staging table
  -- Arguments
  --   Rule_Set_Id		ID of the Rule Set that contains this stage.
  --   Rule_Stage_Id		ID of the stage that is to be applied.
  --   Stage_Num		Sequence value of the stage.
  --   Staging_Table_Name	Staging table to which the IDT will be applied.
  --   Filter_Text		Text of the filter criteria.
  --   Num_Rows_Affected	Number of rows affected in previous stage
  --				passed in, or -1 if this is the first stage. It
  --				will pass back the number of rows affected in
  --				this stage. If there is a discrepancy, an
  --				exception is raised.
  --   Debug_Mode		Whether or not debug information should be
  --				written to the log file.
  -- Example
  --   GCS_LEX_MAP_PKG.Apply_Stage(111, 123, 1, 'gl_interface',
  --                               'group_id=''1000''', nrows)
  -- Notes
  --
  PROCEDURE Apply_Stage(	Rule_Set_Id		NUMBER,
				Rule_Stage_Id		NUMBER,
				Stage_Num		NUMBER,
				Staging_Table_Name	VARCHAR2,
				Filter_Text		VARCHAR2,
				Num_Rows_Affected IN OUT NOCOPY	NUMBER,
				Debug_Mode		VARCHAR2)
  IS
    CURSOR	all_stage_rules IS
    SELECT	r.rule_id	rule_id,
		mc.column_name	column_name,
		mc.write_flag	write_flag
    FROM	gcs_lex_map_rules r,
		gcs_lex_map_columns mc
    WHERE	r.rule_stage_id = apply_stage.rule_stage_id
    AND		r.target_column_id = mc.column_id;

    CURSOR	check_func_c(c_func_name	VARCHAR2) IS
    SELECT	1
    FROM	user_objects
    WHERE	object_name = c_func_name;

    func_name	VARCHAR2(50);
    dummy	NUMBER;

    stage_text	VARCHAR2(32767);
    num_rules	NUMBER := 0;

    module	VARCHAR2(60);

    curr_num_rows_affected	NUMBER;
  BEGIN
    module := g_api || '.Apply_Stage';

    log_file_module_write(module, g_module_enter);

    -- Put down in the log file which stage we are in.
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XL_CURRENT_STAGE');
    FND_MESSAGE.set_token('STAGE_NUM', stage_num);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);


    -- This savepoint is used to roll back to just before the last stage, so
    -- that information on the source values that led to some error can be
    -- retrieved.
    SAVEPOINT gcs_lex_before_stage;

    stage_text := 'UPDATE ' || staging_table_name || ' stg';

    FOR stage_rule IN all_stage_rules LOOP
      IF num_rules = 0 THEN
        stage_text := stage_text || ' SET ';
      ELSE
        stage_text := stage_text || ',';
      END IF;
      func_name := 'GCS_LEX_GET_' || rule_set_id || '_' || stage_rule.rule_id;
      OPEN check_func_c(func_name);
      FETCH check_func_c INTO dummy;
      IF check_func_c%NOTFOUND THEN
        CLOSE check_func_c;
        raise GCS_LEX_RULE_NO_FUNC;
      END IF;
      CLOSE check_func_c;

      stage_text := stage_text || stage_rule.column_name || '=' || func_name ||
                    '(' ||create_param_list(stage_rule.rule_id,'C','Y')|| ')';
      num_rules := num_rules + 1;
    END LOOP;

    IF num_rules = 0 THEN
      raise gcs_lex_stage_no_rule;
    END IF;

    IF filter_text IS NOT NULL THEN
      stage_text := stage_text || ' WHERE ' || filter_text;
    END IF;

    -- Print the stage dynamic SQL text if appropriate.
    IF debug_mode = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, stage_text);
    END IF;

    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT, module, stage_text);
    END IF;

    EXECUTE IMMEDIATE stage_text;

    curr_num_rows_affected := SQL%ROWCOUNT;

    IF num_rows_affected = -1 THEN
      num_rows_affected := curr_num_rows_affected;
    ELSIF num_rows_affected <> curr_num_rows_affected THEN
      raise gcs_lex_num_rows_changed;
    END IF;

    IF error_table.COUNT > 0 THEN
      raise gcs_lex_stage_failed;
    END IF;

    validate_results(rule_stage_id, staging_table_name, filter_text);

    log_file_module_write(module, g_module_success);
  EXCEPTION
    WHEN gcs_lex_rule_no_func THEN
      add_simple_failed_msg('GCS_IDT_NO_RULE_FUNCTION', module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_stage_failed;
    WHEN gcs_lex_num_rows_changed THEN
      add_rows_changed_msg(rule_stage_id, curr_num_rows_affected,
                           num_rows_affected, 'GCS_IDT_NUM_ROWS_CHANGED',
                           module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_stage_failed;
    WHEN gcs_lex_stage_no_rule THEN
      add_stage_failed_msg(rule_stage_id, 'GCS_IDT_STAGE_NO_RULE',
                           module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_stage_failed;
    WHEN gcs_lex_validation_failed THEN
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_validation_failed;
    WHEN gcs_lex_stage_failed OR
         gcs_lex_param_list_failed THEN
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_stage_failed;
    WHEN OTHERS THEN
      add_stage_failed_msg(rule_stage_id, 'GCS_IDT_UNEXP_STAGE_ERROR',
                           module, 'Y');
      log_file_module_write(module, g_module_failure);
      raise gcs_lex_stage_failed;
  END Apply_Stage;

  --
  -- Procedure
  --   Init_Error_Column
  -- Purpose
  --   Initializes the error column in the staging table by inserting 'NEW'.
  -- Arguments
  --   Rule_Set_Id		ID of the Rule Set.
  --   Staging_Table_Name	Name of the staging table.
  --   Filter_Text		Text of the filter criteria.
  -- Example
  --   GCS_LEX_MAP_PKG.Init_Error_Column(111,'gl_interface','group_id=''100''')
  -- Notes
  --
  PROCEDURE Init_Error_Column(	Rule_Set_Id		NUMBER,
				Staging_Table_Name	VARCHAR2,
				Filter_Text		VARCHAR2)
  IS
    filter_where_clause	VARCHAR2(200);
    error_col_name	VARCHAR2(50);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Init_Error_Column';
    filter_where_clause := '';

    IF filter_text IS NOT NULL THEN
      filter_where_clause := ' WHERE ' || filter_text;
    END IF;

    SELECT	mc.column_name
    INTO	error_col_name
    FROM	gcs_lex_map_columns	mc,
		gcs_lex_map_rule_sets	rsts
    WHERE	mc.structure_id = rsts.structure_id
    AND		rsts.rule_set_id = init_error_column.rule_set_id
    AND		mc.error_code_column_flag = 'Y';

    EXECUTE IMMEDIATE 'UPDATE ' || staging_table_name ||
                      ' SET ' || error_col_name || '=''NEW''' ||
                      filter_where_clause;
  EXCEPTION
    WHEN OTHERS THEN
      add_error_code_failed_msg(rule_set_id, staging_table_name,
                                'GCS_IDT_ERROR_COLUMN_NOT_SET', module, 'Y');
      raise gcs_lex_error_column_not_set;
  END Init_Error_Column;

  --
  -- Procedure
  --   Fill_Error_Column
  -- Purpose
  --   Fills out the error column in the staging table
  -- Arguments
  --   Rule_Set_Id		ID of the Rule Set.
  --   Staging_Table_Name	Name of the staging table.
  --   Filter_Text		Text of the filter criteria.
  -- Example
  --   GCS_LEX_MAP_PKG.Fill_Error_Column(111,'gl_interface','group_id=''100''')
  -- Notes
  --
  PROCEDURE Fill_Error_Column(	Rule_Set_Id		NUMBER,
				Staging_Table_Name	VARCHAR2,
				Filter_Text		VARCHAR2)
  IS
    error_col	VARCHAR2(50);

    sql_text	VARCHAR2(32767);

    temp_rule_id	NUMBER;
    temp_deriv_num	NUMBER;
    temp_error_code	VARCHAR2(10);

    counter1	NUMBER;

    module	VARCHAR2(60);

    error_message_name	VARCHAR2(100);
  BEGIN
    module := g_api || '.Fill_Error_Column';

    init_error_column(rule_set_id, staging_table_name, filter_text);

    SELECT	mc.column_name
    INTO	error_col
    FROM	gcs_lex_map_columns mc,
		gcs_lex_map_rule_sets rsts
    WHERE	mc.structure_id = rsts.structure_id
    AND		mc.error_code_column_flag = 'Y'
    AND		rsts.rule_set_id = fill_error_column.rule_set_id;

    sql_text := 'UPDATE ' || staging_table_name || ' SET ' || error_col ||
                '= decode(to_char(' || error_col || '), ''NEW'', '''', ' ||
                error_col || '||'','') || :error_code WHERE rowid=:myrow';

    -- Here, we populate the error column, and remove all validation related
    -- messages (this is because the error_table is used next to write messages
    -- onto the message stack, and the validation messages would have already
    -- been written in validate_column().
    FOR i IN error_table.FIRST..error_table.LAST LOOP
      begin
        EXECUTE IMMEDIATE sql_text USING error_table(i).error_code,
                                         error_table(i).row_id;
      exception
        when others then
          null;
      end;
      IF error_table(i).ERROR_CODE IN (g_error_vsv_failed,
                                       g_error_lutv_failed) THEN
        error_table.delete(i);
      END IF;
    END LOOP;

    -- In addition to filling the error column, we here create and add messages
    -- to the message stack for errors that occurred during processing of
    -- a transformation. The errors for validation failures are not written,
    -- since they would already have been written in the validate_column()
    -- procedure.
    counter1 := error_table.FIRST;
    WHILE counter1 IS NOT NULL LOOP
      IF error_table(counter1).error_code = g_error_lookup_tmr THEN
        error_message_name := 'GCS_IDT_LOOKUP_TOO_MANY_ROWS';
      ELSIF error_table(counter1).error_code = g_error_lookup_ndf THEN
        error_message_name := 'GCS_IDT_LOOKUP_NO_ROWS';
      ELSIF error_table(counter1).error_code = g_error_type_mismatch THEN
        error_message_name := 'GCS_IDT_TYPE_MISMATCH';
      ELSIF error_table(counter1).error_code = g_error_unexpected THEN
        error_message_name := 'GCS_IDT_UNEXP_PROC_ERROR';
      END IF;

      add_deriv_proc_failed_msg(error_table(counter1).rule_id,
                                error_table(counter1).deriv_num,
                                error_message_name, module, 'Y');

      -- Now we get rid of all errors listed that would create a duplicate
      -- of this error message. This is done to keep the number of messages
      -- listed to a sane number.
      temp_rule_id := error_table(counter1).rule_id;
      temp_deriv_num := error_table(counter1).deriv_num;
      temp_error_code := error_table(counter1).error_code;

      counter1 := error_table.NEXT(counter1);
      WHILE counter1 IS NOT NULL AND
            temp_rule_id = error_table(counter1).rule_id AND
            temp_deriv_num = error_table(counter1).deriv_num AND
            temp_error_code = error_table(counter1).error_code LOOP
        counter1 := error_table.NEXT(counter1);
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN gcs_lex_error_column_not_set THEN
      null;
    WHEN OTHERS THEN
      add_error_code_failed_msg(rule_set_id, staging_table_name,
                                'GCS_IDT_ERROR_COL_NOT_FILLED', module, 'Y');
  END Fill_Error_Column;



--
-- PRIVATE PROCEDURES for Validation Rule Sets
--

  --
  -- Function
  --   Create_VRS_Get_Function
  -- Purpose
  --   Creates the text for a PL/SQL function which will take a number of
  --   inputs and return the validation status for a given rule. Then this
  --   will apply the text to the database using dynamic SQL. Returns 'Y' or
  --   'N' depending on the success of creating the function.
  -- Arguments
  --   Rule_Set_Id	Rule Set for which the function should be created.
  --   Rule_Id		Rule for which the function should be created.
  --   My_Appl		APPLSYS schema, which is needed for ad_ddl.
  -- Example
  --   GCS_LEX_MAP_PKG.Create_VRS_Get_Function(111, 123, 'APPLSYS')
  -- Notes
  --
  FUNCTION Create_VRS_Get_Function(	Rule_Set_Id	NUMBER,
					Rule_Id		NUMBER,
					Rule_Name	VARCHAR2,
					My_Appl	VARCHAR2) RETURN VARCHAR2 IS
    func_body	VARCHAR2(32767);

    dummy	NUMBER;

    target_col_name	VARCHAR2(30);
    validation_type	VARCHAR2(30);
    deriv_id		NUMBER;
    error_message	CLOB;

    -- wrapper function name for this rule, and parameter list
    func_name	VARCHAR2(30);
    param_list	VARCHAR2(8000);

    log_error_text	VARCHAR2(8000);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_VRS_Get_Function';
    func_name :='gcs_lex_get_' || rule_set_id || '_' || rule_id;

    param_list := create_param_list(rule_id, 'F', 'N');

    SELECT	r.validation_type_code, d.derivation_id, r.error_message
    INTO	validation_type, deriv_id, error_message
    FROM	gcs_lex_map_rules r,
		gcs_lex_map_derivations d
    WHERE	r.rule_id = create_vrs_get_function.rule_id
    AND		d.rule_id = r.rule_id;

    log_error_text :=
'IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN ' ||
'FND_LOG.string(FND_LOG.LEVEL_ERROR, ''GCS_LEX_MAP_API_PKG.' || func_name ||
''', ''' || REPLACE(error_message, '''', '''''') || '''); END IF; ';

    -- first get the function header information
    func_body := 'CREATE OR REPLACE FUNCTION ' || func_name || '(' ||
                 param_list || ') RETURN VARCHAR2 IS ';

    IF validation_type = 'LOOKUP' THEN
      func_body := func_body || 'dummy NUMBER; ';
    END IF;

    func_body := func_body || 'BEGIN ';


    -- Write the function body based on the validation type
    IF validation_type = 'CONDITION' THEN
      func_body := func_body || 'IF ' || create_condition(deriv_id) ||
                   ' THEN ' || log_error_text || 'return ''EX51''; END IF; ';
    ELSIF validation_type = 'LOOKUP' THEN
      func_body := func_body || create_lookup_derivation(func_name, deriv_id, 'VALIDATION');
    ELSE -- PL/SQL validation
      func_body := func_body || 'IF nvl(' ||
                   create_plsql_derivation(deriv_id, 'VALIDATION') ||
                   ', ''F'') <> ''SUCCESS'' THEN ' || log_error_text ||
                   'return ''EX53''; END IF; ';
    END IF;

    func_body := func_body || 'return ''NEW''; EXCEPTION ';

    IF validation_type = 'LOOKUP' THEN
      func_body := func_body || 'WHEN NO_DATA_FOUND THEN ' || log_error_text ||
                   'return ''EX52''; ';
    END IF;

    func_body := func_body || 'WHEN OTHERS THEN ' || log_error_text;
    IF validation_type = 'CONDITION' THEN
      func_body := func_body || 'return ''EX54''; ';
    ELSIF validation_type = 'LOOKUP' THEN
      func_body := func_body || 'return ''EX55''; ';
    ELSE -- PL/SQL validation
      func_body := func_body || 'return ''EX56''; ';
    END IF;

    func_body := func_body || 'END ' || func_name || ';';


    -- Print out the function body to the log repository if appropriate.
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT, module, func_body);
    END IF;

    IF create_ad(func_body, func_name, my_appl) <> 'FALSE' THEN
      raise gcs_lex_func_failed;
    END IF;

    return 'Y';
  EXCEPTION
    WHEN gcs_lex_param_list_failed OR
         gcs_lex_create_cond_failed OR
         gcs_lex_derivation_failed THEN
      return 'N';
    WHEN gcs_lex_func_failed THEN
      add_vrs_rule_failed_msg(rule_name,'GCS_IDT_VRS_RULE_CREATE_ERR',module,'Y');
      return 'N';
    WHEN OTHERS THEN
      add_rule_failed_msg(rule_id, 'GCS_IDT_RULE_UNEXPECTED', module, 'N');
      return 'N';
  END Create_VRS_Get_Function;




--
-- PUBLIC PROCEDURES
--

  PROCEDURE Create_Map_Functions(
	p_init_msg_list			VARCHAR2 DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id			NUMBER) IS
    CURSOR	all_rules IS
    SELECT	r.rule_id
    FROM	gcs_lex_map_rule_stages rstg,
		gcs_lex_map_rules r
    WHERE	rstg.rule_set_id = p_rule_set_id
    AND		r.rule_stage_id = rstg.rule_stage_id;

    idt_name	VARCHAR2(30);

    status	VARCHAR2(1);
    industry	VARCHAR2(1);
    my_appl	VARCHAR2(30);
    app_flag	BOOLEAN;

    create_func_failure	VARCHAR2(1);

    v_init_msg_list	VARCHAR2(100);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_Map_Functions';
    create_func_failure := 'N';

    v_init_msg_list := nvl(p_init_msg_list, FND_API.G_FALSE);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_API.to_boolean(v_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    idt_name := initial_rule_set_check(p_rule_set_id, 'TRANSFORMATION', 'N');

    -- Get APPLSYS information. Needed for ad_ddl
    app_flag := fnd_installation.get_app_info('FND', status, industry,my_appl);
    IF NOT app_flag THEN
      raise gcs_lex_applsys_not_found;
    END IF;

    -- Clear all functions previously associated with this rule set
    remove_all_functions(p_rule_set_id);

    -- create a function for each of the rules in the rule set.
    FOR rule IN all_rules LOOP
      IF (create_get_function(p_rule_set_id, rule.rule_id,my_appl) <> 'Y') THEN
        create_func_failure := 'Y';
      END IF;
    END LOOP;

    IF create_func_failure = 'Y' THEN
      raise gcs_lex_func_failure;
    END IF;

    FND_MSG_PUB.count_and_get(	p_encoded	=> FND_API.g_false,
				p_count		=> x_msg_count,
				p_data		=> x_msg_data);
  EXCEPTION
    WHEN gcs_lex_init_failed THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN gcs_lex_disabled THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);

      -- It is fine to run this for a disabled mapping. It will simply
      -- remove the unnecessary rule functions.
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN gcs_lex_func_failure THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN gcs_lex_applsys_not_found THEN
      add_simple_failed_msg('GCS_APPLSYS_NOT_FOUND', module, 'N');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      add_id_value_failed_msg(p_rule_set_id, 'GCS_IDT_UNEXPECTED_ERROR',
                              module, 'N');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END Create_Map_Functions;


  PROCEDURE Apply_Map(
	p_api_version		NUMBER,
	p_init_msg_list		VARCHAR2 DEFAULT NULL,
	p_commit		VARCHAR2 DEFAULT NULL,
	p_validation_level	NUMBER   DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id		NUMBER,
	p_staging_table_name	VARCHAR2,
	p_debug_mode		VARCHAR2 DEFAULT NULL,
	p_filter_column_name1	VARCHAR2 DEFAULT NULL,
	p_filter_column_value1	VARCHAR2 DEFAULT NULL,
	p_filter_column_name2	VARCHAR2 DEFAULT NULL,
	p_filter_column_value2	VARCHAR2 DEFAULT NULL,
	p_filter_column_name3	VARCHAR2 DEFAULT NULL,
	p_filter_column_value3	VARCHAR2 DEFAULT NULL,
	p_filter_column_name4	VARCHAR2 DEFAULT NULL,
	p_filter_column_value4	VARCHAR2 DEFAULT NULL,
	p_filter_column_name5	VARCHAR2 DEFAULT NULL,
	p_filter_column_value5	VARCHAR2 DEFAULT NULL,
	p_filter_column_name6	VARCHAR2 DEFAULT NULL,
	p_filter_column_value6	VARCHAR2 DEFAULT NULL,
	p_filter_column_name7	VARCHAR2 DEFAULT NULL,
	p_filter_column_value7	VARCHAR2 DEFAULT NULL,
	p_filter_column_name8	VARCHAR2 DEFAULT NULL,
	p_filter_column_value8	VARCHAR2 DEFAULT NULL,
	p_filter_column_name9	VARCHAR2 DEFAULT NULL,
	p_filter_column_value9	VARCHAR2 DEFAULT NULL,
	p_filter_column_name10	VARCHAR2 DEFAULT NULL,
	p_filter_column_value10	VARCHAR2 DEFAULT NULL)
  IS
    -- Current version number of the lexical mapping API
    l_api_version	NUMBER:= 1.0;
    l_api_name		VARCHAR2(20);

    CURSOR	all_stages IS
    SELECT	rule_stage_id, stage_number
    FROM	gcs_lex_map_rule_stages rstg
    WHERE	rstg.rule_set_id = p_rule_set_id
    ORDER BY	stage_number;

    idt_name	VARCHAR2(30);
    filter_text	VARCHAR2(5000);

    num_rows_affected	NUMBER := -1;

    module	VARCHAR2(60);

    col_name	VARCHAR2(30);
    stage_num	NUMBER;
    vs_name	VARCHAR2(60);
    lut_name	VARCHAR2(50);
    error_value	VARCHAR2(16000);
    param_list	VARCHAR2(16000);

    v_init_msg_list	VARCHAR2(100);
    v_commit		VARCHAR2(100);
    v_validation_level	NUMBER;
    v_debug_mode	VARCHAR2(100);
  BEGIN
    module := g_api || '.Apply_Map';
    l_api_name := 'Apply_Map';

    v_init_msg_list := nvl(p_init_msg_list, FND_API.G_FALSE);
    v_commit := nvl(p_commit, FND_API.G_FALSE);
    v_validation_level := nvl(p_validation_level, FND_API.G_VALID_LEVEL_FULL);
    v_debug_mode := nvl(p_debug_mode, 'N');

    log_file_module_write(module, g_module_enter);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- This savepoint is used to roll all the way back if an error occurs
    -- during processing of the IDT.
    SAVEPOINT gcs_lex_before_mapping;

    IF NOT FND_API.compatible_api_call(	l_api_version, p_api_version,
					l_api_name, g_api) THEN
      raise FND_API.g_exc_unexpected_error;
    END IF;

    IF FND_API.to_boolean(v_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    idt_name := initial_rule_set_check(p_rule_set_id, 'TRANSFORMATION', 'Y');
    staging_table_check(p_staging_table_name, p_rule_set_id);

    filter_text := get_filter_text(
	p_rule_set_id,
	'TRANSFORMATION',
	p_filter_column_name1,	p_filter_column_value1,
	p_filter_column_name2,	p_filter_column_value2,
	p_filter_column_name3,	p_filter_column_value3,
	p_filter_column_name4,	p_filter_column_value4,
	p_filter_column_name5,	p_filter_column_value5,
	p_filter_column_name6,	p_filter_column_value6,
	p_filter_column_name7,	p_filter_column_value7,
	p_filter_column_name8,	p_filter_column_value8,
	p_filter_column_name9,	p_filter_column_value9,
	p_filter_column_name10,	p_filter_column_value10);

    write_header_log(idt_name, p_staging_table_name, filter_text);

    init_error_column(p_rule_set_id, p_staging_table_name, filter_text);

    -- apply each of the rule stages in the rule set
    FOR rule_stage IN all_stages LOOP
      apply_stage(p_rule_set_id,
                  rule_stage.rule_stage_id,
                  rule_stage.stage_number,
                  p_staging_table_name,
                  filter_text,
                  num_rows_affected,
                  v_debug_mode);
    END LOOP;

    -- Put down in the log file how many rows were affected.
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XL_NUM_ROWS_AFFECTED');
    FND_MESSAGE.set_token('NUM_ROWS', num_rows_affected);
    FND_MESSAGE.set_token('STG_TBL', p_staging_table_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);

    IF FND_API.to_boolean(v_commit) THEN
      COMMIT;
    END IF;

    FND_MSG_PUB.count_and_get(	p_encoded	=> FND_API.g_false,
				p_count		=> x_msg_count,
				p_data		=> x_msg_data);

    gcs_lex_map_api_pkg.error_table.delete;

    log_file_module_write(module, g_module_success);

    write_header_output(idt_name, p_staging_table_name, filter_text);
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_COMPLETED_SUCCESS');
    FND_MESSAGE.set_token('IDT_NAME', idt_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_NUM_ROWS_AFFECTED');
    FND_MESSAGE.set_token('NUM_ROWS', num_rows_affected);
    FND_MESSAGE.set_token('STG_TBL', p_staging_table_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

    write_tail_output;
  EXCEPTION
    WHEN gcs_lex_error_column_not_set OR
         gcs_lex_init_failed OR
         gcs_lex_table_check_failed OR
         gcs_lex_filter_error THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      gcs_lex_map_api_pkg.error_table.delete;
      log_file_module_write(module, g_module_failure);
      ROLLBACK TO gcs_lex_before_mapping;
    WHEN gcs_lex_disabled THEN
      add_idt_failed_msg(p_rule_set_id, 'GCS_IDT_DISABLED',
                         'GCS_LEX_MAP_API_PKG.Initial_Rule_Set_Check', 'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      gcs_lex_map_api_pkg.error_table.delete;
      log_file_module_write(module, g_module_failure);
      ROLLBACK TO gcs_lex_before_mapping;
    WHEN gcs_lex_validation_failed THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      IF error_table.COUNT > 0 THEN
        write_header_output(idt_name, p_staging_table_name, filter_text);
        FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_COMPLETED_FAILURE');
        FND_MESSAGE.set_token('IDT_NAME', idt_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

        -- List all validation errors. No need to sort the error table since
        -- the entries would already be sorted.
        FOR i IN error_table.FIRST..error_table.LAST LOOP
          IF i = error_table.FIRST OR
             error_table(i).rule_id <> error_table(i-1).rule_id THEN

            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

            IF error_table(i).error_code = g_error_vsv_failed THEN
              SELECT	mc.column_name,
			rstg.stage_number,
			ffv.flex_value_set_name
              INTO	col_name,
			stage_num,
			vs_name
              FROM	gcs_lex_map_rules r,
			gcs_lex_map_columns mc,
			gcs_lex_map_rule_stages rstg,
			fnd_flex_value_sets ffv
              WHERE	r.rule_stage_id = rstg.rule_stage_id
              AND	r.value_set_id = ffv.flex_value_set_id
              AND	r.target_column_id = mc.column_id
              AND	r.rule_id = error_table(i).rule_id;

              FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_VSV_HEADER');
              FND_MESSAGE.set_token('STAGE_NUM', stage_num);
              FND_MESSAGE.set_token('COL_NAME', col_name);
              FND_MESSAGE.set_token('VS_NAME', vs_name);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
            ELSIF error_table(i).error_code = g_error_lutv_failed THEN
              SELECT	mc.column_name,
			rstg.stage_number,
			lutms.structure_name
              INTO	col_name,
			stage_num,
			lut_name
              FROM	gcs_lex_map_rules r,
			gcs_lex_map_columns mc,
			gcs_lex_map_rule_stages rstg,
			gcs_lex_map_structs lutms
              WHERE	r.rule_stage_id = rstg.rule_stage_id
              AND	r.lookup_table_id = lutms.structure_id
              AND	r.target_column_id = mc.column_id
              AND	r.rule_id = error_table(i).rule_id;

              FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_LUTV_HEADER');
              FND_MESSAGE.set_token('STAGE_NUM', stage_num);
              FND_MESSAGE.set_token('COL_NAME', col_name);
              FND_MESSAGE.set_token('LUT_NAME', lut_name);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
            END IF;

            FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_SHORT_SEPARATOR');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
          END IF;

          EXECUTE IMMEDIATE 'SELECT ' || col_name || ' FROM ' ||
                            p_staging_table_name || ' WHERE rowid = :row_id'
          INTO error_value
          USING error_table(i).row_id;

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, error_value);
        END LOOP;

        write_tail_output;

        ROLLBACK TO gcs_lex_before_mapping;
        fill_error_column(p_rule_set_id, p_staging_table_name, filter_text);
      ELSE
        ROLLBACK TO gcs_lex_before_mapping;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      gcs_lex_map_api_pkg.error_table.delete;
      log_file_module_write(module, g_module_failure);
    WHEN gcs_lex_stage_failed THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      IF error_table.COUNT > 0 THEN
        write_header_output(idt_name, p_staging_table_name, filter_text);
        FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_COMPLETED_FAILURE');
        FND_MESSAGE.set_token('IDT_NAME', idt_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

        -- Sort out the error table by rule_id, deriv_num, and error_code. This
        -- allows us to group the errors together and show them in a more
        -- organized manner.
        qsort_error_table(error_table.FIRST, error_table.LAST);

        ROLLBACK TO gcs_lex_before_stage;

        -- List all transformation related errors. These should be listed after
        -- the rollback to before the stage took place, since we want the
        -- source values that caused these errors.
        FOR i IN error_table.FIRST..error_table.LAST LOOP
          IF i = error_table.FIRST OR
             error_table(i).rule_id <> error_table(i-1).rule_id OR
             error_table(i).deriv_num <> error_table(i-1).deriv_num OR
             error_table(i).error_code <> error_table(i-1).error_code THEN

            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

            SELECT	mc.column_name,
			rstg.stage_number
            INTO	col_name,
			stage_num
            FROM	gcs_lex_map_rules r,
			gcs_lex_map_rule_stages rstg,
			gcs_lex_map_columns mc
            WHERE	r.rule_stage_id = rstg.rule_stage_id
            AND		r.target_column_id = mc.column_id
            AND		r.rule_id = error_table(i).rule_id;

            IF error_table(i).error_code = g_error_lookup_tmr THEN
              FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_TMR_HEADER');
              FND_MESSAGE.set_token('STAGE_NUM', stage_num);
              FND_MESSAGE.set_token('COL_NAME', col_name);
              FND_MESSAGE.set_token('DERIV_NUM', error_table(i).deriv_num);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
            ELSIF error_table(i).error_code = g_error_lookup_ndf THEN
              FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_NR_HEADER');
              FND_MESSAGE.set_token('STAGE_NUM', stage_num);
              FND_MESSAGE.set_token('COL_NAME', col_name);
              FND_MESSAGE.set_token('DERIV_NUM', error_table(i).deriv_num);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
            ELSIF error_table(i).error_code = g_error_type_mismatch THEN
              FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_TYPE_HEADER');
              FND_MESSAGE.set_token('STAGE_NUM', stage_num);
              FND_MESSAGE.set_token('COL_NAME', col_name);
              FND_MESSAGE.set_token('DERIV_NUM', error_table(i).deriv_num);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
            ELSIF error_table(i).error_code = g_error_unexpected THEN
              IF error_table(i).deriv_num = -1 THEN
                FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_UNEXP_HEADER_NODRV');
              ELSE
                FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_UNEXP_HEADER');
              END IF;
              FND_MESSAGE.set_token('STAGE_NUM', stage_num);
              FND_MESSAGE.set_token('COL_NAME', col_name);
              IF error_table(i).deriv_num <> -1 THEN
                FND_MESSAGE.set_token('DERIV_NUM', error_table(i).deriv_num);
              END IF;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);
            END IF;

            FND_MESSAGE.set_name('GCS', 'GCS_IDT_XR_SHORT_SEPARATOR');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.get);

            -- Get the header parameter list
            param_list := create_param_list(error_table(i).rule_id, 'H', 'Y');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, param_list);
            FOR j IN 1..LENGTH(param_list)/20 LOOP
              FND_FILE.PUT(FND_FILE.OUTPUT, '------------------- ');
            END LOOP;
            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

            -- Get the query parameter list
            param_list := create_param_list(error_table(i).rule_id, 'Q', 'Y');
          END IF;

          EXECUTE IMMEDIATE 'SELECT ' || param_list || ' FROM ' ||
                            p_staging_table_name || ' WHERE rowid = :row_id'
          INTO error_value
          USING error_table(i).row_id;

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, error_value);
        END LOOP;

        write_tail_output;

        ROLLBACK TO gcs_lex_before_mapping;
        fill_error_column(p_rule_set_id, p_staging_table_name, filter_text);
      ELSE
        ROLLBACK TO gcs_lex_before_mapping;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      gcs_lex_map_api_pkg.error_table.delete;
      log_file_module_write(module, g_module_failure);
    WHEN OTHERS THEN
      add_id_value_failed_msg(p_rule_set_id, 'GCS_IDT_UNEXPECTED_ERROR',
                              module, 'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      gcs_lex_map_api_pkg.error_table.delete;
      log_file_module_write(module, g_module_failure);
      ROLLBACK TO gcs_lex_before_mapping;
  END Apply_Map;


  PROCEDURE Create_Validation_Functions(
	p_init_msg_list			VARCHAR2 DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id			NUMBER) IS
    CURSOR	all_rules IS
    SELECT	r.rule_id,
		r.rule_name
    FROM	gcs_lex_map_rule_stages rstg,
		gcs_lex_map_rules r
    WHERE	rstg.rule_set_id = p_rule_set_id
    AND		r.rule_stage_id = rstg.rule_stage_id;

    idt_name	VARCHAR2(30);

    status	VARCHAR2(1);
    industry	VARCHAR2(1);
    my_appl	VARCHAR2(30);
    app_flag	BOOLEAN;

    create_func_failure	VARCHAR2(1);

    v_init_msg_list	VARCHAR2(100);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Create_Validation_Functions';
    create_func_failure := 'N';

    v_init_msg_list := nvl(p_init_msg_list, FND_API.G_FALSE);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_API.to_boolean(v_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    idt_name := initial_rule_set_check(p_rule_set_id, 'VALIDATION', 'N');

    -- Get APPLSYS information. Needed for ad_ddl
    app_flag := fnd_installation.get_app_info('FND', status, industry,my_appl);
    IF NOT app_flag THEN
      raise gcs_lex_applsys_not_found;
    END IF;

    -- Clear all functions previously associated with this rule set
    remove_all_functions(p_rule_set_id);

    -- create a function for each of the rules in the rule set.
    FOR rule IN all_rules LOOP
      IF (create_vrs_get_function(p_rule_set_id, rule.rule_id, rule.rule_name, my_appl) <> 'Y') THEN
        create_func_failure := 'Y';
      END IF;
    END LOOP;

    IF create_func_failure = 'Y' THEN
      raise gcs_lex_func_failure;
    END IF;

    FND_MSG_PUB.count_and_get(	p_encoded	=> FND_API.g_false,
				p_count		=> x_msg_count,
				p_data		=> x_msg_data);
  EXCEPTION
    WHEN gcs_lex_init_failed THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN gcs_lex_disabled THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);

      -- It is fine to run this for a disabled mapping. It will simply
      -- remove the unnecessary rule functions.
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN gcs_lex_func_failure THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN gcs_lex_applsys_not_found THEN
      add_simple_failed_msg('GCS_APPLSYS_NOT_FOUND', module, 'N');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      add_id_value_failed_msg(p_rule_set_id, 'GCS_IDT_UNEXPECTED_ERROR',
                              module, 'N');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END Create_Validation_Functions;



  PROCEDURE Apply_Validation(
	p_api_version		NUMBER,
	p_init_msg_list		VARCHAR2 DEFAULT NULL,
	p_commit		VARCHAR2 DEFAULT NULL,
	p_validation_level	NUMBER   DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_rule_set_id		NUMBER,
	p_staging_table_name	VARCHAR2,
	p_debug_mode		VARCHAR2 DEFAULT NULL,
	p_filter_column_name1	VARCHAR2 DEFAULT NULL,
	p_filter_column_value1	VARCHAR2 DEFAULT NULL,
	p_filter_column_name2	VARCHAR2 DEFAULT NULL,
	p_filter_column_value2	VARCHAR2 DEFAULT NULL,
	p_filter_column_name3	VARCHAR2 DEFAULT NULL,
	p_filter_column_value3	VARCHAR2 DEFAULT NULL,
	p_filter_column_name4	VARCHAR2 DEFAULT NULL,
	p_filter_column_value4	VARCHAR2 DEFAULT NULL,
	p_filter_column_name5	VARCHAR2 DEFAULT NULL,
	p_filter_column_value5	VARCHAR2 DEFAULT NULL,
	p_filter_column_name6	VARCHAR2 DEFAULT NULL,
	p_filter_column_value6	VARCHAR2 DEFAULT NULL,
	p_filter_column_name7	VARCHAR2 DEFAULT NULL,
	p_filter_column_value7	VARCHAR2 DEFAULT NULL,
	p_filter_column_name8	VARCHAR2 DEFAULT NULL,
	p_filter_column_value8	VARCHAR2 DEFAULT NULL,
	p_filter_column_name9	VARCHAR2 DEFAULT NULL,
	p_filter_column_value9	VARCHAR2 DEFAULT NULL,
	p_filter_column_name10	VARCHAR2 DEFAULT NULL,
	p_filter_column_value10	VARCHAR2 DEFAULT NULL) IS

    -- Current version number of the lexical mapping API
    l_api_version	NUMBER:= 1.0;
    l_api_name		VARCHAR2(20);

    CURSOR	all_rules IS
    SELECT	r.rule_id, r.rule_name, r.validation_type_code
    FROM	gcs_lex_map_rule_stages rstg,
		gcs_lex_map_rules r
    WHERE	rstg.rule_set_id = p_rule_set_id
    AND		r.rule_stage_id = rstg.rule_stage_id
    ORDER BY	rstg.stage_number;

    CURSOR	check_func_c(c_func_name	VARCHAR2) IS
    SELECT	1
    FROM	user_objects
    WHERE	object_name = c_func_name;

    dummy		NUMBER;

    idt_name		VARCHAR2(30);
    filter_text		VARCHAR2(5000);
    error_col_name	VARCHAR2(50);

    val_text		VARCHAR2(8000);
    rule_name		VARCHAR2(100);
    func_name		VARCHAR2(100);

    num_rows_total	NUMBER := -1;

    v_init_msg_list	VARCHAR2(100);
    v_commit		VARCHAR2(100);
    v_validation_level	NUMBER;
    v_debug_mode	VARCHAR2(100);

    module	VARCHAR2(60);
  BEGIN
    module := g_api || '.Apply_Validation';
    l_api_name := 'Apply_Validation';

    v_init_msg_list := nvl(p_init_msg_list, FND_API.G_FALSE);
    v_commit := nvl(p_commit, FND_API.G_FALSE);
    v_validation_level := nvl(p_validation_level, FND_API.G_VALID_LEVEL_FULL);
    v_debug_mode := nvl(p_debug_mode, 'N');

    log_file_module_write(module, g_module_enter);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.compatible_api_call(	l_api_version, p_api_version,
					l_api_name, g_api) THEN
      raise FND_API.g_exc_unexpected_error;
    END IF;

    IF FND_API.to_boolean(v_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    idt_name := initial_rule_set_check(p_rule_set_id, 'VALIDATION', 'Y');
    staging_table_check(p_staging_table_name, p_rule_set_id);

    filter_text := get_filter_text(
	p_rule_set_id,
	'VALIDATION',
	p_filter_column_name1,	p_filter_column_value1,
	p_filter_column_name2,	p_filter_column_value2,
	p_filter_column_name3,	p_filter_column_value3,
	p_filter_column_name4,	p_filter_column_value4,
	p_filter_column_name5,	p_filter_column_value5,
	p_filter_column_name6,	p_filter_column_value6,
	p_filter_column_name7,	p_filter_column_value7,
	p_filter_column_name8,	p_filter_column_value8,
	p_filter_column_name9,	p_filter_column_value9,
	p_filter_column_name10,	p_filter_column_value10);

--
--    write_header_log(idt_name, p_staging_table_name, filter_text);
--

    init_error_column(p_rule_set_id, p_staging_table_name, filter_text);

    -- Now get the error column name and add to the filter text
    SELECT	mc.column_name
    INTO	error_col_name
    FROM	gcs_lex_map_rule_sets rs,
		gcs_lex_map_columns mc
    WHERE	rs.rule_set_id = p_rule_set_id
    AND		mc.structure_id = rs.structure_id
    AND		mc.error_code_column_flag = 'Y';

    IF filter_text IS NOT NULL THEN
      filter_text := filter_text || ' AND to_char(' || error_col_name || ') = ''NEW''';
    ELSE
      filter_text := 'to_char(' || error_col_name || ') = ''NEW''';
    END IF;


    -- apply each of the validation rules in the rule set
    FOR val_rule IN all_rules LOOP
      func_name := 'GCS_LEX_GET_' || p_rule_set_id || '_' || val_rule.rule_id;

      OPEN check_func_c(func_name);
      FETCH check_func_c INTO dummy;
      IF check_func_c%NOTFOUND THEN
        CLOSE check_func_c;
        raise GCS_LEX_RULE_NO_FUNC;
      END IF;
      CLOSE check_func_c;

      -- Depending on the validation type, perform an action
      IF val_rule.validation_type_code = 'PLSQL' THEN
        DELETE FROM gcs_lex_vrs_plsql_gt;

        val_text :=
          'INSERT INTO gcs_lex_vrs_plsql_gt(associated_rowid, error_code) ' ||
          'SELECT rowid, ' || func_name || '(' ||
          create_param_list(val_rule.rule_id, 'C', 'Y') ||
          ') FROM ' || p_staging_table_name || ' WHERE ' || filter_text;
      ELSE
        val_text := 'UPDATE ' || p_staging_table_name || ' stg SET ' ||
                    error_col_name || '=' || func_name ||
                    '(' ||create_param_list(val_rule.rule_id,'C','Y')|| ') ' ||
                    'WHERE ' || filter_text;
      END IF;

      IF v_debug_mode = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, val_text);
      END IF;

      IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT, module, val_text);
      END IF;

      begin
        EXECUTE IMMEDIATE val_text;
      exception
        when others then
          rule_name := val_rule.rule_name;
          raise GCS_LEX_VRS_RULE_FAILED;
      end;

      IF num_rows_total = -1 THEN
        num_rows_total := SQL%ROWCOUNT;
        IF num_rows_total = 0 THEN
          raise GCS_LEX_VRS_NO_ROWS;
        END IF;
      END IF;

      IF val_rule.validation_type_code = 'PLSQL' THEN
        val_text :=
          'UPDATE ' || p_staging_table_name || ' stg SET ' || error_col_name ||
          '=(SELECT error_code FROM gcs_lex_vrs_plsql_gt plsgt ' ||
          'WHERE plsgt.associated_rowid = stg.rowid) ' ||
          'WHERE ' || filter_text;

        IF v_debug_mode = 'Y' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, val_text);
        END IF;

        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
          FND_LOG.string(FND_LOG.LEVEL_EVENT, module, val_text);
        END IF;

        EXECUTE IMMEDIATE val_text;
      END IF;
    END LOOP;

    EXECUTE IMMEDIATE
      'SELECT decode(COUNT(*), ' || num_rows_total || ', ''' ||
      FND_API.G_RET_STS_SUCCESS || ''', ''' || FND_API.G_RET_STS_ERROR ||
      ''') FROM ' || p_staging_table_name || ' WHERE ' || filter_text
    INTO x_return_status;


    -- Put down in the log file how many rows were validated
    FND_MESSAGE.set_name('GCS', 'GCS_IDT_VRS_NUM_ROWS_AFFECTED');
    FND_MESSAGE.set_token('NUM_ROWS', num_rows_total);
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT THEN
      FND_LOG.message(FND_LOG.LEVEL_EVENT, module);
    END IF;

    IF v_debug_mode = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get);
    END IF;

    IF FND_API.to_boolean(v_commit) THEN
      COMMIT;
    END IF;

    FND_MSG_PUB.count_and_get(	p_encoded	=> FND_API.g_false,
				p_count		=> x_msg_count,
				p_data		=> x_msg_data);

    log_file_module_write(module, g_module_success);
  EXCEPTION
    WHEN gcs_lex_vrs_no_rows THEN
      add_simple_failed_msg('GCS_IDT_VRS_NO_ROWS', module, 'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      log_file_module_write(module, g_module_failure);
    WHEN gcs_lex_vrs_rule_failed THEN
      add_vrs_rule_failed_msg(rule_name,'GCS_IDT_VRS_RULE_FAILED',module,'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      log_file_module_write(module, g_module_failure);
    WHEN gcs_lex_rule_no_func THEN
      add_simple_failed_msg('GCS_IDT_NO_RULE_FUNCTION', module, 'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      log_file_module_write(module, g_module_failure);
    WHEN gcs_lex_error_column_not_set OR
         gcs_lex_init_failed OR
         gcs_lex_table_check_failed OR
         gcs_lex_filter_error THEN
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      log_file_module_write(module, g_module_failure);
    WHEN gcs_lex_disabled THEN
      add_idt_failed_msg(p_rule_set_id, 'GCS_IDT_DISABLED',
                         'GCS_LEX_MAP_API_PKG.Initial_Rule_Set_Check', 'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;
      log_file_module_write(module, g_module_failure);
    WHEN OTHERS THEN
      add_id_value_failed_msg(p_rule_set_id, 'GCS_IDT_UNEXPECTED_ERROR',
                              module, 'Y');
      FND_MSG_PUB.count_and_get(p_encoded	=> FND_API.g_false,
				p_count	=> x_msg_count,
				p_data	=> x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      log_file_module_write(module, g_module_failure);
  END Apply_Validation;


  PROCEDURE After_FEM_Refresh IS

  BEGIN
    UPDATE gcs_lex_map_rule_sets
    SET    associated_object_id = fem_object_id_seq.nextval;

    INSERT INTO fem_object_catalog_b(
      object_id, folder_id, object_type_code, object_access_code,
      object_origin_code, object_version_number, creation_date, created_by,
      last_update_date, last_updated_by, last_update_login)
    SELECT associated_object_id, 1300, 'CONSOLIDATION_DATA', 'R', 'USER', 1,
           sysdate, created_by, sysdate, last_updated_by, last_update_login
    FROM   gcs_lex_map_rule_sets rst;

    INSERT INTO fem_object_catalog_tl(
      object_id, object_name, language, source_lang, description, creation_date,
      created_by, last_update_date, last_updated_by, last_update_login)
    SELECT associated_object_id, rst.name, userenv('LANG'), userenv('LANG'),
           description, sysdate, created_by, sysdate, last_updated_by,
           last_update_login
    FROM   gcs_lex_map_rule_sets rst;

    INSERT INTO fem_object_definition_b(
      object_definition_id, object_id, effective_start_date, effective_end_date,
      object_origin_code, approval_status_code, old_approved_copy_flag,
      object_version_number, creation_date, created_by, last_update_date,
      last_updated_by, last_update_login)
    SELECT fem_object_definition_id_seq.nextval, associated_object_id,
           to_date('01-01-1000', 'DD-MM-YYYY'),
           to_date('31-12-9999', 'DD-MM-YYYY'), 'USER', 'NOT_APPLICABLE', 'N', 1,
           sysdate, created_by, sysdate, last_updated_by, last_update_login
    FROM   gcs_lex_map_rule_sets rst;

    INSERT INTO fem_object_definition_tl(
      object_definition_id, object_id, language, source_lang,
      old_approved_copy_flag, display_name, description, creation_date,
      created_by, last_update_date, last_updated_by, last_update_login)
    SELECT odb.object_definition_id, odb.object_id, userenv('LANG'),
           userenv('LANG'), 'N', rst.name, rst.description, sysdate,
           rst.created_by, sysdate, rst.last_updated_by, rst.last_update_login
    FROM   gcs_lex_map_rule_sets rst,
           fem_object_definition_b odb
    WHERE  odb.object_id = rst.associated_object_id;

  END After_FEM_Refresh;


END GCS_LEX_MAP_API_PKG;

/
