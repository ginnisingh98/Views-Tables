--------------------------------------------------------
--  DDL for Package Body GL_ACCOUNTS_MAP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ACCOUNTS_MAP_GRP" as
/* $Header: glgcmapb.pls 120.10.12010000.4 2009/07/22 16:31:20 akhanapu ship $ */


--
-- Private Global Variables
--

  -- whether or not debug messages should be printed
  g_debug_flag		BOOLEAN;

  -- information on the flexfield. This is the same for the source and target
  -- charts of accounts.
  g_flexfield		fnd_flex_key_api.flexfield_type;

  -- information on the target chart of accounts structure
  g_target_structure	fnd_flex_key_api.structure_type;

  -- list of segments for the target chart of accounts
  g_target_segments	fnd_flex_key_api.segment_list;

  -- number of segments for the target chart of accounts
  g_target_nSegments	NUMBER;

  -- number of segment mapping rules defined
  g_num_segment_rules	NUMBER;

  -- number of account mapping rules defined
  g_num_account_rules	NUMBER;

  -- the following are constants used throughout the package body
  g_application_id		CONSTANT NUMBER		:= 101;
  g_id_flex_code		CONSTANT VARCHAR2(10)	:= 'GL#';
  g_application_short_name	CONSTANT VARCHAR2(10)	:= 'SQLGL';


--
-- Private Functions and Procedures
--


  --
  -- Procedure
  --   writeToLog
  -- Purpose
  -- 	Writes a debug message to the log file.
  --    Copied from GCS_UTILITIES_PKG.
  -- History
  --   17-FEB-03  M. Ward 	Created
  -- Arguments
  --   buf			debug message to write
  procedure writeToLog (buf IN Varchar2 := NULL) is
    errBuf Varchar2(2000);
  begin

    -- May be a message on the stack or
    -- a string passed in via the arg
    if buf IS NULL then
      errBuf := substr( FND_MESSAGE.get, 1, 2000 );
    else
      errBuf := substr( buf, 1, 2000 );
    end if;

    -- Do nothing if there is no message waiting
    if errBuf IS NOT NULL then
      FND_FILE.new_line( FND_FILE.log, 1 );
      FND_FILE.put_line( FND_FILE.log, errBuf );
    end if;

  end writeToLog;


  --
  -- Procedure
  --   writeDebug
  -- Purpose
  -- 	Writes a debug message to the log file if the debug flag is true
  --    Copied from GCS_UTILITIES_PKG.
  -- History
  --   17-FEB-03  M. Ward 	Created
  -- Arguments
  --   buf			debug message to write
  PROCEDURE writeDebug (buf IN Varchar2) is
  begin
    if buf IS NOT NULL then
      if g_debug_flag then
        writeToLog(buf);
      end if;
    end if;
  end writeDebug;

  --
  -- Procedure
  --   set_stats
  -- Purpose
  --   Set table and index stats in an autonomous transaction so that a
  --   commit does not take place.
  -- History
  --   13-NOV-03	M. Ward		Created
  -- Arguments
  --   table_name	Name of the table
  --   index_name	Name of the index
  --   num_rows		Number of rows in the table and index
  --
  PROCEDURE set_stats(	table_name	VARCHAR2,
			index_name	VARCHAR2,
			num_rows	NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    FND_STATS.set_table_stats('GL', table_name, num_rows, NULL, NULL);
    FND_STATS.set_index_stats('GL', index_name, num_rows,
                              NULL, NULL, NULL, NULL, NULL, NULL);
  END set_stats;

  --
  -- Procedure
  --   init_map
  -- Purpose
  -- 	Retrieves, validates, and stores the chart of accounts mapping
  --    information for the given mapping name
  -- History
  --   09-MAY-02  M. Ward 	Created
  -- Arguments
  --   mapping_name		Name of the chart of accounts mapping to use
  --   mapping_id		ID of the chart of accounts mapping to use
  --   to_coa_id		To Chart of Accounts ID
  --   from_coa_id		From Chart of Accounts ID
  --
  PROCEDURE init_map(mapping_name		IN VARCHAR2,
		     mapping_id			OUT NOCOPY NUMBER,
		     to_coa_id			OUT NOCOPY NUMBER,
		     from_coa_id		OUT NOCOPY NUMBER
		    ) IS

    -- these are used for simple validation tests on the mapping
    start_date_active	DATE;
    end_date_active	DATE;
    flex_rule_total	NUMBER;
    seg_rule_total	NUMBER;

    -- cursor to gather information on the mapping with the given name
    CURSOR c_mapping_info IS
    SELECT	coa_mapping_id,
		from_coa_id,
		to_coa_id,
		start_date_active,
		end_date_active
    FROM	gl_coa_mappings
    WHERE	name = mapping_name;

    -- used to store the number of rows in the interface table
    nRows	NUMBER;

  BEGIN
    OPEN c_mapping_info;
    FETCH c_mapping_info INTO mapping_id, from_coa_id, to_coa_id,
                              start_date_active, end_date_active;
    IF c_mapping_info%NOTFOUND THEN
      CLOSE c_mapping_info;
      raise GL_INVALID_MAPPING_NAME;
    END IF;
    CLOSE c_mapping_info;

    -- This compares SYSDATE to start/end_date_active to see if the mapping
    -- is active. If not, this raises an exception.
    IF (start_date_active IS NOT NULL AND start_date_active > SYSDATE) OR
       (end_date_active IS NOT NULL AND end_date_active < SYSDATE) THEN
      raise GL_DISABLED_MAPPING;
    END IF;

    -- Get the number of account rules
    SELECT	COUNT(*)
    INTO	g_num_account_rules
    FROM	gl_cons_flexfield_map
    WHERE	coa_mapping_id = mapping_id;

    -- Get the number of segments taken care of in all the segment rules
    SELECT	COUNT(DISTINCT to_application_column_name)
    INTO	g_num_segment_rules
    FROM	gl_cons_segment_map
    WHERE	coa_mapping_id = mapping_id;

    -- This statement is necessary to use the fnd_flex_key_api package's
    -- subroutines.
    fnd_flex_key_api.set_session_mode('customer_data');

    -- gets information on the target flexfield
    g_flexfield := fnd_flex_key_api.find_flexfield
      (appl_short_name	=>	g_application_short_name,
       flex_code	=>	g_id_flex_code
      );

    -- gets information on the structure of the target chart of accounts
    g_target_structure := fnd_flex_key_api.find_structure
      (flexfield	=>	g_flexfield,
       structure_number	=>	to_coa_id
      );

    -- gets the list of segments for the chart of accounts
    fnd_flex_key_api.get_segments(flexfield	=>	g_flexfield,
                                  structure	=>	g_target_structure,
                                  nsegments	=>	g_target_nSegments,
                                  segments 	=>	g_target_segments
                                 );


    -- if there are no account rules and no segment rules, or if the
    -- segment rules do not span the entire set of segments, this must
    -- be an invalid mapping.
    IF (g_num_account_rules=0 AND g_num_segment_rules=0) OR
       (g_num_segment_rules>0 AND g_num_segment_rules<g_target_nSegments) THEN
      raise GL_INVALID_MAPPING_RULES;
    END IF;

    SELECT COUNT(*)
    INTO nRows
    FROM GL_ACCTS_MAP_INT_GT;

    -- set statistics on the interface table for the CBO
    set_stats('GL_ACCTS_MAP_INT_GT',
              'GL_ACCTS_MAP_INT_GT_U1',
              nRows);
  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      raise GL_INVALID_MAPPING_NAME;
    WHEN GL_DISABLED_MAPPING THEN
      raise GL_DISABLED_MAPPING;
    WHEN GL_INVALID_MAPPING_RULES THEN
      raise GL_INVALID_MAPPING_RULES;
    WHEN OTHERS THEN
      raise GL_MAP_UNEXPECTED_ERROR;
  END init_map;


  --
  -- Procedure
  --   interim_rollup_map
  -- Purpose
  --   Creates interim information in the global temporary table,
  --   GL_ACCTS_MAP_SEG<x>_GT tables used by the rollup
  --   segment rules. The interim information is a mapping between
  --   the source flex segment values and the target flex segment
  --   values. It also contains a summary flag to indicate if it is a
  --   summary accounts mapping or a regular accounts mapping. The
  --   interim information is used to improve performance with the
  --   rollup segment rules.
  --
  -- Examples of the insert statment that inputs all the data to the interim
  -- table follow. The first is for a segment that is not table validated. The
  -- second is for a table validated segment.
  --
  -- Segments that are not table validated --
  --
  -- INSERT INTO GL_ACCTS_MAP_SEG<x>_GT(
  --
  --    SELECT -- Detail Rollup Via Parent --
  --           GL_FV.flex_value    source_flex_value,
  --           GL_CSM.single_value target_flex_value,
  --  	       'N'	           summary_flag
  --    FROM   fnd_flex_values GL_FV,
  --           fnd_flex_value_hierarchies FVH,
  --           gl_cons_segment_map GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.parent_rollup_value = FVH.parent_flex_value
  --    AND    GL_CSM.segment_map_type = 'P'
  --    AND    FVH.flex_value_set_id = GL_CSM.from_value_set_id
  --    AND    GL_FV.flex_value_set_id = GL_CSM.from_value_set_id
  --    AND    GL_FV.summary_flag = 'N'
  --    AND    GL_FV.flex_value BETWEEN FVH.child_flex_value_low
  --           AND FVH.child_flex_value_high
  --
  --       UNION  -- Detail Rollup Ranges --
  --
  --    SELECT GL_FV.flex_value    source_flex_value,
  --           GL_CSM.single_value target_flex_value,
  --            'N'             summary_flag
  --    FROM   fnd_flex_values GL_FV,
  --           gl_cons_flex_hierarchies CFH,
  --           gl_cons_segment_map GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.segment_map_id = CFH.segment_map_id
  --    AND    GL_CSM.single_value = CFH.parent_flex_value
  --    AND    GL_CSM.segment_map_type = 'R'
  --    AND    GL_FV.flex_value_set_id = GL_CSM.from_value_set_id
  --    AND    GL_FV.summary_flag = 'N'
  --    AND    GL_FV.flex_value BETWEEN CFH.child_flex_value_low
  --           AND CFH.child_flex_value_high
  --
  --       UNION  -- Parent Value --
  --
  --    SELECT GL_CSM.parent_rollup_value source_flex_value,
  --           GL_CSM.single_value        target_flex_value,
  --           'Y'                     summary_flag
  --    FROM   gl_cons_segment_map GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.segment_map_type = 'V'
  --
  --       UNION  -- Parent Rollup Ranges --
  --
  --    SELECT GL_FV.flex_value 	source_flex_value,
  --           GL_CSM.single_value target_flex_value,
  --  	       'Y'	        summary_flag
  --    FROM   fnd_flex_values          GL_FV,
  --           gl_cons_flex_hierarchies CFH,
  --           gl_cons_segment_map      GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.segment_map_id = CFH.segment_map_id
  --    AND    GL_CSM.single_value = CFH.parent_flex_value
  --    AND    GL_CSM.segment_map_type = 'U'
  --    AND    GL_FV.flex_value_set_id = GL_CSM.from_value_set_id
  --    AND    GL_FV.summary_flag = 'Y'
  --    AND    GL_FV.flex_value BETWEEN CFH.child_flex_value_low
  --            		 AND     CFH.child_flex_value_high)
  --
  -- Segments that are table validated --
  --
  -- INSERT INTO GL_ACCTS_MAP_SEG<x>_GT(
  --
  --    SELECT DISTINCT -- Detail Rollup Via Parent --
  --           GL_FV.:val_column_name  source_flex_value,
  --           GL_CSM.single_value target_flex_value,
  --  	       'N'		summary_flag
  --    FROM   :val_tab_name GL_FV,
  --           fnd_flex_value_hierarchies FVH,
  --           gl_cons_segment_map GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.parent_rollup_value = FVH.parent_flex_value
  --    AND    GL_CSM.segment_map_type = 'P'
  --    AND    FVH.flex_value_set_id = GL_CSM.from_value_set_id
  --    AND    GL_FV.:val_col_name
  --           BETWEEN FVH.child_flex_value_low
  --           AND FVH.child_flex_value_high
  --
  --       UNION  -- Detail Rollup Ranges --
  --
  --    SELECT DISTINCT GL_FV.:val_col_name source_flex_value,
  --           GL_CSM.single_value target_flex_value,
  --  	       'N'		summary_flag
  --    FROM   :val_tab_name GL_FV,
  --           gl_cons_flex_hierarchies CFH,
  --           gl_cons_segment_map GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.segment_map_id = CFH.segment_map_id
  --    AND    GL_CSM.single_value = CFH.parent_flex_value
  --    AND    GL_CSM.segment_map_type = 'R'
  --    AND    GL_FV.:val_col_name
  --           BETWEEN CFH.child_flex_value_low
  --           AND CFH.child_flex_value_high
  --
  --       UNION  -- Parent Value --
  --
  --    SELECT GL_CSM.parent_rollup_value source_flex_value,
  --           GL_CSM.single_value        target_flex_value,
  -- 	       'Y'                     summary_flag
  --    FROM   gl_cons_segment_map GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.segment_map_type = 'V'
  --
  --       UNION  -- Parent Rollup Ranges --
  --
  --    SELECT GL_FV.flex_value 	source_flex_value,
  --  	       GL_CSM.single_value target_flex_value,
  -- 	       'Y'  	        summary_flag
  --    FROM   fnd_flex_values          GL_FV,
  --           gl_cons_flex_hierarchies CFH,
  --           gl_cons_segment_map      GL_CSM
  --    WHERE  GL_CSM.coa_mapping_id = v_mapping_id
  --    AND    GL_CSM.to_application_column_name =
  --           v_to_application_column_name
  --    AND    GL_CSM.segment_map_id = CFH.segment_map_id
  --    AND    GL_CSM.single_value = CFH.parent_flex_value
  --    AND    GL_CSM.segment_map_type = 'U'
  --    AND    GL_FV.flex_value_set_id = GL_CSM.from_value_set_id
  --    AND    GL_FV.summary_flag = 'Y'
  --    AND    GL_FV.flex_value BETWEEN CFH.child_flex_value_low
  --             		 AND     CFH.child_flex_value_high)
  --
  --
  -- History
  --   15-MAY-02  M. Ward 	Created
  -- Arguments
  --   mapping_id		ID of the chart of accounts mapping to use
  --   to_application_column_name	application column name for the target
  --   from_value_set_id	value set id for the source
  --
  PROCEDURE interim_rollup_map(mapping_id			IN NUMBER,
                               to_application_column_name	IN VARCHAR2,
                               from_value_set_id		IN NUMBER
                              ) IS
    val_table_name	fnd_flex_validation_tables.application_table_name%TYPE;
    val_column_name	fnd_flex_validation_tables.value_column_name%TYPE;

    detail_parent_flag	VARCHAR2(1);
    detail_ranges_flag	VARCHAR2(1);
    summary_ranges_flag	VARCHAR2(1);
    summary_parent_flag	VARCHAR2(1);

    insert_1		VARCHAR2(3000);

    insert_1_col	fnd_flex_validation_tables.application_table_name%TYPE;
    insert_1_table	fnd_flex_validation_tables.value_column_name%TYPE;
    insert_1_join	VARCHAR2(100);
    insert_1_select_type	VARCHAR2(40);

    -- selects the table and column name used for table validation for the
    -- source chart of accounts, if applicable.
    CURSOR c_check_table_validated IS
    SELECT	fvt.application_table_name,
		fvt.value_column_name
    FROM	fnd_flex_validation_tables fvt,
		fnd_flex_value_sets fvs
    WHERE	fvs.flex_value_set_id = from_value_set_id
    AND		fvs.validation_type = 'F'
    AND		fvs.flex_value_set_id = fvt.flex_value_set_id;

    -- number of source segment values that are duplicates of values already in
    -- the interim table
    num_duplicates	NUMBER;

    -- used to store the number of rows in the interface table
    nRows	NUMBER;

  BEGIN
    -- get information on the validation table and column, if applicable.
    -- Otherwise, they will be null.
    OPEN c_check_table_validated;
    FETCH c_check_table_validated INTO val_table_name, val_column_name;
    CLOSE c_check_table_validated;

    -- get information for the flags specified below. These specify the types
    -- of rollup rules used in this mapping
    SELECT	decode(max(decode(map.segment_map_type, 'P', 1, 0)),
		1, 'Y', 'N'),
		decode(max(decode(map.segment_map_type, 'R', 1, 0)),
		1, 'Y', 'N'),
		decode(max(decode(map.segment_map_type, 'U', 1, 0)),
		1, 'Y', 'N'),
		decode(max(decode(map.segment_map_type, 'V', 1, 0)),
		1, 'Y', 'N')
    INTO	detail_parent_flag,
		detail_ranges_flag,
		summary_ranges_flag,
		summary_parent_flag
    FROM	GL_CONS_SEGMENT_MAP map
    WHERE	map.coa_mapping_id = mapping_id
    AND		map.to_application_column_name =
		interim_rollup_map.to_application_column_name;

    -- clear out the interim global temporary table in case it had data in it
    -- before.
    EXECUTE IMMEDIATE 'DELETE FROM GL_ACCTS_MAP_SEG' ||
                      substr(to_application_column_name,8,2) || '_GT';

    insert_1 := 'INSERT INTO GL_ACCTS_MAP_SEG' ||
                substr(to_application_column_name,8,2) || '_GT (';

    -- These specify the column name and table name to be used in the select
    -- statements for populating data in the insert statement. Since the column
    -- and table are dependent on whether the segment is table-validated, I
    -- specify it here. These fields are used in both the select for the
    -- detail parent and detail ranges.
    IF val_table_name IS NOT NULL THEN
      insert_1_col := val_column_name;
      insert_1_table := val_table_name;
      insert_1_join := '';
      insert_1_select_type := 'SELECT DISTINCT';
    ELSE
      insert_1_col := 'flex_value';
      insert_1_table := 'fnd_flex_values';
      insert_1_join := 'AND GL_FV.flex_value_set_id = GL_CSM.from_value_set_id ' ||
                       'AND GL_FV.summary_flag = ''N'' ';
      insert_1_select_type := 'SELECT DISTINCT';
    END IF;

    -- below, build the insert statement based on the types of rollup rules that
    -- are used for this particular segment
    IF detail_parent_flag = 'Y' THEN
      insert_1 := insert_1 || insert_1_select_type || ' GL_FV.' || insert_1_col ||
                  ' source_flex_value, ' ||
                  'GL_CSM.single_value target_flex_value, ''N'' summary_flag ' ||
                  'FROM '|| insert_1_table || ' GL_FV, ' ||
                  'fnd_flex_value_hierarchies FVH, gl_cons_segment_map GL_CSM ' ||
                  'WHERE GL_CSM.coa_mapping_id = ' || TO_CHAR(mapping_id) ||
                  ' AND GL_CSM.to_application_column_name = ''' ||
                  to_application_column_name || ''' ' ||
                  'AND GL_CSM.parent_rollup_value = FVH.parent_flex_value ' ||
                  'AND GL_CSM.segment_map_type = ''P'' ' ||
                  'AND FVH.flex_value_set_id = GL_CSM.from_value_set_id ' ||
                  insert_1_join ||
                  'AND GL_FV.' || insert_1_col || ' BETWEEN ' ||
                  'FVH.child_flex_value_low AND FVH.child_flex_value_high';
    END IF;

    IF detail_ranges_flag = 'Y' THEN
      IF detail_parent_flag = 'Y' THEN
        insert_1 := insert_1 || ' UNION ';
      END IF;
      insert_1 := insert_1 || insert_1_select_type || ' GL_FV.' || insert_1_col ||
                  ' source_flex_value, ' ||
                  'GL_CSM.single_value target_flex_value, ''N'' summary_flag ' ||
                  'FROM ' || insert_1_table || ' GL_FV, ' ||
                  'gl_cons_flex_hierarchies CFH, gl_cons_segment_map GL_CSM ' ||
                  'WHERE GL_CSM.coa_mapping_id = ' || TO_CHAR(mapping_id) ||
                  ' AND GL_CSM.to_application_column_name = ''' ||
                  to_application_column_name || ''' ' ||
                  'AND GL_CSM.segment_map_id = CFH.segment_map_id ' ||
                  'AND GL_CSM.single_value = CFH.parent_flex_value ' ||
                  'AND GL_CSM.segment_map_type = ''R'' ' ||
                  insert_1_join ||
                  'AND GL_FV.' || insert_1_col || ' BETWEEN ' ||
                  'CFH.child_flex_value_low AND CFH.child_flex_value_high';



    END IF;

    IF summary_parent_flag = 'Y' THEN
      IF detail_parent_flag = 'Y' OR detail_ranges_flag = 'Y' THEN
        insert_1 := insert_1 || ' UNION ';
      END IF;
      insert_1 := insert_1 ||
                  'SELECT GL_CSM.parent_rollup_value source_flex_value, ' ||
                  'GL_CSM.single_value target_flex_value, ''Y'' summary_flag ' ||
                  'FROM gl_cons_segment_map GL_CSM ' ||
                  'WHERE GL_CSM.coa_mapping_id = ' || TO_CHAR(mapping_id) ||
                  ' AND GL_CSM.to_application_column_name = ''' ||
                  to_application_column_name || ''' ' ||
                  'AND GL_CSM.segment_map_type = ''V''';


    END IF;

    IF summary_ranges_flag = 'Y' THEN
      IF detail_parent_flag = 'Y' OR detail_ranges_flag = 'Y' OR
         summary_parent_flag = 'Y' THEN
        insert_1 := insert_1 || ' UNION ';
      END IF;
      insert_1 := insert_1 || 'SELECT GL_FV.flex_value source_flex_value, ' ||
                  'GL_CSM.single_value target_flex_value, ''Y'' summary_flag ' ||
                  'FROM fnd_flex_values GL_FV, gl_cons_flex_hierarchies CFH, ' ||
                  'gl_cons_segment_map GL_CSM ' ||
                  'WHERE GL_CSM.coa_mapping_id = ' || TO_CHAR(mapping_id) ||
                  ' AND GL_CSM.to_application_column_name = ''' ||
                  to_application_column_name || ''' ' ||
                  'AND GL_CSM.segment_map_id = CFH.segment_map_id ' ||
                  'AND GL_CSM.single_value = CFH.parent_flex_value ' ||
                  'AND GL_CSM.segment_map_type = ''U'' ' ||
                  'AND GL_FV.flex_value_set_id = GL_CSM.from_value_set_id ' ||
                  'AND GL_FV.summary_flag = ''Y'' ' ||
                  'AND GL_FV.flex_value BETWEEN CFH.child_flex_value_low ' ||
                                     'AND CFH.child_flex_value_high';
    END IF;


    insert_1 := insert_1 || ')';

    -- DEBUG print the contents of the insert statement to the screen.
    writedebug('insert statement for rollup rules is: ');
    FOR i IN 0..(lengthb(insert_1)-1)/2000 LOOP
      writedebug(SUBSTRB(insert_1, i*2000+1, 2000));
    END LOOP;
    writedebug(' ');

    EXECUTE IMMEDIATE insert_1;

    -- retrieves the total number of rows in the table (since the table was
    -- empty before the insert statement)
    nRows := SQL%ROWCOUNT;

    -- set statistics on this interim table for the CBO
    set_stats('GL_ACCTS_MAP_SEG' || substr(to_application_column_name,8,2) || '_GT',
              'GL_ACCTS_MAP_SEG' ||
              SUBSTR(to_application_column_name,8,2) || '_GT_U1',
              nRows);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1 THEN
        raise GL_INVALID_MAPPING_RULES;
      END IF;
      raise GL_MAP_UNEXPECTED_ERROR;
  END interim_rollup_map;


  --
  -- Procedure
  --   segment_map
  -- Purpose
  --   Maps the accounts in the GL_ACCTS_MAP_INT_GT using the
  --   segment rules. It creates and runs one dynamic SQL statement that
  --   applies the mapping rules and populates the to_segment<x> columns.
  --
  --   An example of what the SQL statement might look like is given below:
  --
  -- UPDATE GL_ACCTS_MAP_INT_GT map
  -- SET (from_summary_flag, to_ccid, to_segment1, to_segment2, to_segment3,
  --      to_segment4, to_segment5, to_segment6, to_segment7, to_segment8,
  --      to_segment9, to_segment10) =
  -- (SELECT from_cc.summary_flag, null,
  --    '01', from_cc.segment1,
  --    int_segment3.target_flex_value, int_segment4.target_flex_value,
  --    from_cc.segment3, int_segment6.target_flex_value,
  --    '0000','0000', '000','000'
  -- FROM gl_code_combinations from_cc,
  --      GL_ACCTS_MAP_SEG3_GT int_segment3,
  --      GL_ACCTS_MAP_SEG4_GT int_segment4,
  --      GL_ACCTS_MAP_SEG6_GT int_segment6
  -- WHERE map.from_ccid = from_cc.code_combination_id
  -- AND from_cc.chart_of_accounts_id = v_from_coa_id
  -- AND from_cc.segment2 = int_segment3.source_flex_value
  -- AND from_cc.segment2 = int_segment4.source_flex_value
  -- AND from_cc.segment3 = int_segment6.source_flex_value
  -- AND from_cc.SEGMENT4 = DECODE (NVL(from_cc.template_id,-1),
  --                                -1, from_cc.SEGMENT4, 'T')
  -- AND from_cc.SEGMENT5 = DECODE (NVL(from_cc.template_id,-1),
  --                                -1,from_cc.SEGMENT5, 'T')
  -- AND NVL(from_cc.template_id, -1) =
  --       DECODE (int_segment3.summary_flag, 'Y', from_cc.template_id,
  --         DECODE (int_segment4.summary_flag, 'Y', from_cc.template_id,
  --           DECODE (int_segment6.summary_flag, 'Y', from_cc.template_id,-1)))
  -- AND (from_cc.template_id IS NULL OR
  --   (EXISTS (SELECT 'X'
  --            FROM GL_SUMMARY_TEMPLATES st
  --            WHERE  st.template_id = from_cc.template_id
  --              AND ST.SEGMENT1_TYPE = 'D'
  --              AND ST.SEGMENT3_TYPE = 'D')))
  -- )
  -- WHERE map.coa_mapping_id = v_mapping_id
  -- AND   map.from_summary_flag IS NULL
  --
  -- History
  --   14-MAY-02  M. Ward 	Created
  -- Arguments
  --   mapping_id		ID of the chart of accounts mapping to use
  --   to_coa_id		To Chart of Accounts ID
  --   from_coa_id		From Chart of Accounts ID
  --
  PROCEDURE segment_map(mapping_id			IN NUMBER,
                        to_coa_id			IN NUMBER,
                        from_coa_id			IN NUMBER
                       ) IS

    -- variable that is used because it must hold the return from a FETCH,
    -- but is otherwise unused
    dummy		VARCHAR2(1);

    -- buffers for keeping parts of the final update statement while it is
    -- being built
    update_1		VARCHAR2(600);
    select_1		VARCHAR2(1500);
    from_1		VARCHAR2(2000);
    where_1		VARCHAR2(10000);
    where_2		VARCHAR2(100);

    -- bits and pieces of the where statement. All are appended to the where_1
    -- variable after the loop.
    where_template_buf	VARCHAR2(1500) := null;
    where_rollup_buf_1	VARCHAR2(2500) := null;
    where_rollup_buf_2	VARCHAR2(50) := null;

    parent_rule_exist	VARCHAR2(1) := null;

    to_app_col_name	fnd_id_flex_segments.application_column_name%TYPE;
    from_app_col_name	fnd_id_flex_segments.application_column_name%TYPE;

    -- this query will return a single row with 'Y' in it if there is segment
    -- mapping that involves summary accounts
    CURSOR rule_exist IS
    SELECT	'Y'
    FROM	gl_cons_segment_map
    WHERE	coa_mapping_id = mapping_id
    AND		segment_map_type IN ('V','U');

    -- this query returns information concerning the segment rules, including
    -- the source and target segments, and mapping type
    CURSOR   c_to_segment_rules IS
    SELECT   max(map.segment_map_id)		SEGMENT_MAP_ID,
	     decode(max(map.segment_map_type),	'',  'N',
						'C', 'C',
						'S', 'S',
						'P', 'R',
						'R', 'R',
						'V', 'R',
						'U', 'R',
						'N')
						SEGMENT_MAP_TYPE,
             max(ffs1.application_column_name)	TO_APPLICATION_COLUMN_NAME,
             ffs1.segment_num			TO_SEGMENT_NUM,
	     ffs1.flex_value_set_id		TO_VALUE_SET_ID,
	     ffs2.application_column_name	FROM_APPLICATION_COLUMN_NAME,
	     ffs2.segment_num			FROM_SEGMENT_NUM,
	     ffs2.flex_value_set_id		FROM_VALUE_SET_ID,
	     decode(max(map.segment_map_type),	'S', max(map.single_value),
						NULL)
						SINGLE_VALUE

    FROM     FND_ID_FLEX_SEGMENTS	ffs2,
	     GL_CONS_SEGMENT_MAP	map,
	     FND_ID_FLEX_SEGMENTS	ffs1

    WHERE    ffs1.application_id = g_application_id
    AND      ffs1.id_flex_code = g_id_flex_code
    AND      ffs1.enabled_flag = 'Y'
    AND      ffs1.id_flex_num = to_coa_id
    AND      map.to_value_set_id (+)= ffs1.flex_value_set_id
    AND      map.to_application_column_name (+)= ffs1.application_column_name
    AND      map.coa_mapping_id (+)= mapping_id
    AND      ffs2.application_id (+)= g_application_id
    AND      ffs2.id_flex_code (+)= g_id_flex_code
    AND      ffs2.enabled_flag (+)= 'Y'
    AND      ffs2.id_flex_num (+)= from_coa_id
    AND      ffs2.application_column_name (+)=
                            nvl(map.from_application_column_name, -1)
    AND      ffs2.flex_value_set_id (+)= nvl(map.from_value_set_id, -1)

    GROUP BY map.coa_mapping_id,
             ffs1.segment_num,
             ffs1.flex_value_set_id,
             ffs2.application_column_name,
             ffs2.segment_num,
             ffs2.flex_value_set_id
    ORDER BY ffs1.segment_num;

    -- This gets all the source segments that were not involved in the segment
    -- mappings
    CURSOR c_unmapped_from_segments IS
    SELECT	ffs.application_column_name UNMAPPED_FROM_SEGMENT
    FROM	FND_ID_FLEX_SEGMENTS ffs
    WHERE	ffs.application_id = g_application_id
    AND		ffs.id_flex_code = g_id_flex_code
    AND		ffs.enabled_flag = 'Y'
    AND		ffs.id_flex_num = from_coa_id
    AND		ffs.application_column_name NOT IN (
			SELECT	map.from_application_column_name
			FROM	GL_CONS_SEGMENT_MAP map
			WHERE	map.coa_mapping_id = mapping_id
			AND	map.from_application_column_name IS NOT NULL
		);

    no_rollup_rules	BOOLEAN := true;

  BEGIN
    update_1 := 'UPDATE GL_ACCTS_MAP_INT_GT map ' ||
                'SET (from_summary_flag, to_ccid';

    select_1 := 'SELECT from_cc.summary_flag, null';
    from_1 := ' FROM gl_code_combinations from_cc';
    where_1 := ' WHERE map.from_ccid = from_cc.code_combination_id' ||
               ' AND from_cc.chart_of_accounts_id = ' || TO_CHAR(from_coa_id);

    where_2 := 'WHERE map.coa_mapping_id = ' || TO_CHAR(mapping_id) ||
               ' AND   map.from_summary_flag IS NULL';

    -- Loops through each of the target segment rules. There are as many
    -- target segment rules as there are target segments.
    FOR seg_rule IN c_to_segment_rules LOOP
      to_app_col_name := seg_rule.to_application_column_name;
      from_app_col_name := seg_rule.from_application_column_name;

      update_1 := update_1 || ', to_' || to_app_col_name;

      -- This handles the copy value case
      IF seg_rule.segment_map_type = 'C' THEN
        select_1 := select_1 || ', from_cc.' || from_app_col_name;

        -- see if the mapping has rollup rules using summary accounts
        IF parent_rule_exist IS NULL THEN
          OPEN rule_exist;
          -- we fetch into a dummy variable because we are interested in whether
          -- a value was returned at all, rather than the value that was returned
          FETCH rule_exist INTO dummy;
          IF (rule_exist%FOUND) THEN
            parent_rule_exist := 'Y';
            where_template_buf := ' AND (from_cc.template_id IS NULL OR ' ||
              '(EXISTS (SELECT ''X'' FROM GL_SUMMARY_TEMPLATES st ' ||
              'WHERE st.template_id = from_cc.template_id';
          ELSE
            parent_rule_exist := 'N';
          END IF;
          CLOSE rule_exist;
        END IF;

        -- if a rollup rule with summary accounts is used and copy value is
        -- used on one or more segments, accounts with parent values on those
        -- segments must be excluded
        IF parent_rule_exist = 'Y' THEN
          where_template_buf := where_template_buf || ' AND st.' ||
                            from_app_col_name || '_TYPE = ''D''';

        END IF;

      -- This handles the single value case
      ELSIF seg_rule.segment_map_type = 'S' THEN
        select_1 := select_1 || ', ''' || seg_rule.single_value || '''';

      -- This handles the case in which there are rollup rules
      ELSIF seg_rule.segment_map_type = 'R' THEN
        no_rollup_rules := false;

        interim_rollup_map(mapping_id, to_app_col_name,
                           seg_rule.from_value_set_id);

        select_1 := select_1 || ', int_' || to_app_col_name ||
                    '.target_flex_value';
        from_1 := from_1 || ', GL_ACCTS_MAP_SEG' || substr(to_app_col_name,8,2) ||
                  '_GT int_' || to_app_col_name;
        where_1 := where_1 || ' AND from_cc.' || from_app_col_name ||
                   ' = int_' || to_app_col_name || '.source_flex_value';

        -- If this is the first rollup rule processed, initialize the appropriate
        -- variables
        IF where_rollup_buf_1 IS NULL THEN
          where_rollup_buf_1 := ' AND NVL(from_cc.template_id, -1) = ';
          where_rollup_buf_2 := '-1';
        END IF;
        where_rollup_buf_1 := where_rollup_buf_1 || 'DECODE(int_' ||
                              to_app_col_name ||
                              '.summary_flag, ''Y'', from_cc.template_id, ';
        where_rollup_buf_2 := where_rollup_buf_2 || ')';

      -- Otherwise, the mapping type is 'N', which is an error
      ELSE
        raise GL_INVALID_MAPPING_RULES;
      END IF;

    END LOOP;

    -- all unmapped source segments must either have 'T' in any template. The
    -- following test added to the where clause checks for that.
    FOR unmapped_seg IN c_unmapped_from_segments LOOP
      where_1 := where_1 || ' AND from_cc.' ||
                 unmapped_seg.unmapped_from_segment ||
                 ' = DECODE(NVL(from_cc.template_id, -1), -1, from_cc.' ||
                 unmapped_seg.unmapped_from_segment || ', ''T'')';

    END LOOP;

    update_1 := update_1 || ') ';

    -- if rollup rules were used, add the appropriate part of the where
    -- section of the query
    IF where_rollup_buf_1 IS NOT NULL THEN
      where_1 := where_1 || where_rollup_buf_1 || where_rollup_buf_2;
    END IF;

    -- if summary accounts were used, add the appropriate text to the query.
    IF parent_rule_exist = 'Y' THEN
      where_template_buf := where_template_buf || ')))';
      where_1 := where_1 || where_template_buf;
    END IF;

    IF no_rollup_rules THEN
      where_1 := where_1 || ' AND from_cc.template_id IS NULL';
    END IF;

    -- DEBUG prints the contents of the update statement to the screen
    writedebug('This is the update statement for segment map: ');
    FOR i IN 0..(lengthb(update_1 || '= ('|| select_1 || from_1 || where_1 || ') ' || where_2)-1)/2000 LOOP
      writedebug(SUBSTRB(update_1 || '= ('|| select_1 || from_1 || where_1 || ') ' || where_2, i*2000+1, 2000));
    END LOOP;
    writedebug(' ');

    -- execute the update statement that applies the segment mapping rules to
    -- the source code combinations
    EXECUTE IMMEDIATE
      update_1 || '= ('|| select_1 || from_1 || where_1 || ') ' || where_2;

  EXCEPTION
    WHEN GL_INVALID_MAPPING_RULES THEN
      raise GL_INVALID_MAPPING_RULES;
    WHEN OTHERS THEN
      raise GL_MAP_UNEXPECTED_ERROR;
  END segment_map;


  --
  -- Procedure
  --   account_map
  -- Purpose
  --   Maps the accounts in the GL_ACCTS_MAP_INT_GT using the
  --   account rules. It creates and runs one dynamic SQL statement that
  --   applies the mapping rules.
  --
  -- An example of what the SQL statement may look like is given below
  --
  -- UPDATE GL_ACCTS_MAP_INT_GT map
  -- SET (from_summary_flag, to_ccid, to_segment1, to_segment2, to_segment3,
  -- to_segment4, to_segment5, to_segment6, to_segment7, to_segment8,
  -- to_segment9, to_segment10) =
  -- (SELECT from_cc.summary_flag, to_cc.code_combination_id,
  --         to_cc.SEGMENT1, to_cc.SEGMENT2, to_cc.SEGMENT3, to_cc.SEGMENT4,
  --         to_cc.SEGMENT5, to_cc.SEGMENT6, to_cc.SEGMENT7, to_cc.SEGMENT8,
  --         to_cc.SEGMENT9, to_cc.SEGMENT10
  -- FROM gl_cons_flexfield_map f,
  --      gl_code_combinations from_cc,
  --      gl_code_combinations to_cc
  -- WHERE map.from_ccid = from_cc.code_combination_id
  -- and f.coa_mapping_id = v_mapping_id
  -- and from_cc.SEGMENT1 between f.SEGMENT1_low and f.SEGMENT1_high
  -- and from_cc.SEGMENT2 between f.SEGMENT2_low and f.SEGMENT2_high
  -- and from_cc.SEGMENT3 between f.SEGMENT3_low and f.SEGMENT3_high
  -- and from_cc.SEGMENT4 between f.SEGMENT4_low and f.SEGMENT4_high
  -- and from_cc.SEGMENT5 between f.SEGMENT5_low and f.SEGMENT5_high
  -- and f.to_code_combination_id = to_cc.code_combination_id
  -- and from_cc.chart_of_accounts_id = v_from_coa_id
  -- and from_cc.template_id IS NULL
  -- and to_cc.chart_of_accounts_id = v_to_coa_id)
  -- WHERE map.coa_mapping_id = v_mapping_id
  -- AND   EXISTS (SELECT 'X'
  -- FROM gl_cons_flexfield_map cons_flex, gl_code_combinations cc1
  -- WHERE cc1.SEGMENT1 between cons_flex.SEGMENT1_low and cons_flex.SEGMENT1_high
  -- AND cc1.SEGMENT2 between cons_flex.SEGMENT2_low and cons_flex.SEGMENT2_high
  -- AND cc1.SEGMENT3 between cons_flex.SEGMENT3_low and cons_flex.SEGMENT3_high
  -- AND cc1.SEGMENT4 between cons_flex.SEGMENT4_low and cons_flex.SEGMENT4_high
  -- AND cc1.SEGMENT5 between cons_flex.SEGMENT5_low and cons_flex.SEGMENT5_high
  -- AND cons_flex.coa_mapping_id = v_mapping_id
  -- AND cc1.chart_of_accounts_id = v_from_coa_id
  -- AND map.from_ccid = cc1.code_combination_id
  -- AND cc1.template_id IS NULL)
  --
  -- History
  --   16-MAY-02  M. Ward 	Created
  -- Arguments
  --   mapping_id		ID of the chart of accounts mapping to use
  --   to_coa_id		To Chart of Accounts ID
  --   from_coa_id		From Chart of Accounts ID
  --
  PROCEDURE account_map(mapping_id			IN NUMBER,
                        to_coa_id			IN NUMBER,
                        from_coa_id			IN NUMBER
                       ) IS

    -- buffers for keeping parts of the final update statement while it is
    -- being built
    update_1	VARCHAR2(500);
    select_1	VARCHAR2(1000);
    where_1	VARCHAR2(4000);
    where_2	VARCHAR2(4000);

    -- information on the source chart of accounts structure
    source_structure	fnd_flex_key_api.structure_type;

    -- list of segments for the source chart of accounts
    source_segments	fnd_flex_key_api.segment_list;

    -- number of segments for the source chart of accounts
    source_nSegments	NUMBER;

    -- for holding the application column name
    app_col_name	fnd_id_flex_segments.application_column_name%TYPE;

    -- segments in the target chart of accounts
    CURSOR c_to_segments IS
    SELECT	ffs1.application_column_name TO_APPLICATION_COLUMN_NAME
    FROM	FND_ID_FLEX_SEGMENTS ffs1
    WHERE	ffs1.application_id = g_application_id
    AND		ffs1.id_flex_code = g_id_flex_code
    AND		ffs1.enabled_flag = 'Y'
    AND		ffs1.id_flex_num = to_coa_id
    ORDER BY	ffs1.segment_num;

    -- segments in the source chart of accounts
    CURSOR c_from_segments IS
    SELECT	ffs1.application_column_name FROM_APPLICATION_COLUMN_NAME
    FROM	FND_ID_FLEX_SEGMENTS ffs1
    WHERE	ffs1.application_id = g_application_id
    AND		ffs1.id_flex_code = g_id_flex_code
    AND		ffs1.enabled_flag = 'Y'
    AND		ffs1.id_flex_num = from_coa_id
    ORDER BY	ffs1.segment_num;

  BEGIN
    -- gets information on the structure of the source chart of accounts
    source_structure := fnd_flex_key_api.find_structure
      (flexfield	=>	g_flexfield,
       structure_number	=>	from_coa_id
      );

    -- gets the list of segments for the source chart of accounts
    fnd_flex_key_api.get_segments(flexfield	=>	g_flexfield,
                                  structure	=>	source_structure,
                                  nsegments	=>	source_nSegments,
                                  segments 	=>	source_segments
                                 );

    update_1 := 'UPDATE /*+ cardinality(map 1) */ GL_ACCTS_MAP_INT_GT map ' ||
                'SET(from_summary_flag, to_ccid';

    select_1 := 'SELECT from_cc.summary_flag, to_cc.code_combination_id';

    where_1 := 'WHERE map.from_ccid = from_cc.code_combination_id ' ||
               'AND f.coa_mapping_id = ' || TO_CHAR(mapping_id);

    where_2 := 'WHERE map.coa_mapping_id = ' || TO_CHAR(mapping_id) ||
               ' AND EXISTS (SELECT ''X'' ' ||
               'FROM gl_cons_flexfield_map cons_flex, ' ||
               'gl_code_combinations cc1 WHERE ';

    -- Loop through each of the target segments to populate the update and
    -- select clauses
    FOR col_name IN c_to_segments LOOP
      app_col_name := col_name.TO_APPLICATION_COLUMN_NAME;

      update_1 := update_1 || ', to_' || app_col_name;
      select_1 := select_1 || ', to_cc.' || app_col_name;
    END LOOP;

    -- Loop through each of the source segments to populate the where clauses
    FOR col_name IN c_from_segments LOOP
      app_col_name := col_name.FROM_APPLICATION_COLUMN_NAME;

      where_1 := where_1 || ' AND from_cc.' || app_col_name || ' BETWEEN f.' ||
              app_col_name || '_low AND f.' || app_col_name || '_high';
      where_2 := where_2||'cc1.'||app_col_name||' BETWEEN cons_flex.'||
              app_col_name||'_low AND cons_flex.'||app_col_name||'_high AND ';
    END LOOP;


    update_1 := update_1 || ') = ';

    select_1 := select_1 || ' FROM gl_cons_flexfield_map f, ' ||
                'gl_code_combinations from_cc, ' ||
                'gl_code_combinations to_cc ';

    where_1 := where_1 || ' AND f.to_code_combination_id = ' ||
               'to_cc.code_combination_id ' ||
               'AND from_cc.chart_of_accounts_id = ' || TO_CHAR(from_coa_id) ||
               ' AND from_cc.template_id IS NULL ' ||
               'AND to_cc.chart_of_accounts_id = ' || TO_CHAR(to_coa_id);

    where_2 := where_2 || 'cons_flex.coa_mapping_id = ' ||
               TO_CHAR(mapping_id) ||
               ' AND cc1.chart_of_accounts_id = ' || TO_CHAR(from_coa_id) ||
               ' AND map.from_ccid = cc1.code_combination_id' ||
               ' AND cc1.template_id IS NULL)';

    -- DEBUG prints the contents of the update statement to the screen
    writedebug('This is the update statement for account map: ');
    FOR i IN 0..(lengthb(update_1 || '(' || select_1 || where_1 || ') ' || where_2)-1)/2000 LOOP
      writedebug(SUBSTRB(update_1 || '(' || select_1 || where_1 || ') ' || where_2, i*2000+1, 2000));
    END LOOP;
    writedebug(' ');

    -- execute the update statement that performs the account mappings
    EXECUTE IMMEDIATE update_1 || '(' || select_1 || where_1 || ') ' || where_2;

  EXCEPTION
    WHEN OTHERS THEN
      raise GL_MAP_UNEXPECTED_ERROR;
  END account_map;


  --
  -- Procedure
  --   end_map
  -- Purpose
  --   Handles creating the new code combination IDs where required, and
  --   populating error codes
  --
  --   The first update statement, which populates to_ccid for code combinations
  --   that already exist in gl_code_combinations, and the error_codes
  --   'NO_MAPPING' and 'INVALID_FROM_CCID' is as follows
  --
  -- UPDATE GL_ACCTS_MAP_INT_GT map
  -- SET to_ccid =
  -- (SELECT to_cc.code_combination_id
  -- FROM GL_CODE_COMBINATIONS to_cc
  --
  -- WHERE to_cc.chart_of_accounts_id = v_to_coa_id
  -- AND to_cc.SEGMENT1 (+) = map.TO_SEGMENT1
  -- AND to_cc.SEGMENT2 (+) = map.TO_SEGMENT2
  -- AND to_cc.SEGMENT3 (+) = map.TO_SEGMENT3
  -- AND to_cc.SEGMENT4 (+) = map.TO_SEGMENT4
  -- AND to_cc.SEGMENT5 (+) = map.TO_SEGMENT5
  -- AND to_cc.SEGMENT6 (+) = map.TO_SEGMENT6
  -- AND to_cc.SEGMENT7 (+) = map.TO_SEGMENT7
  -- AND to_cc.SEGMENT8 (+) = map.TO_SEGMENT8
  -- AND to_cc.SEGMENT9 (+) = map.TO_SEGMENT9
  -- AND to_cc.SEGMENT10 (+) = map.TO_SEGMENT10),
  -- error_code =
  -- (SELECT decode(NVL(map.from_summary_flag, 'X'),
  --               'X', decode(COUNT(*), 0, 'INVALID_FROM_CCID',
  --                                     'NO_MAPPING'))
  -- FROM GL_CODE_COMBINATIONS from_cc
  -- WHERE from_cc.code_combination_id = map.from_ccid
  --   AND from_cc.chart_of_accounts_id = v_from_coa_id)
  -- WHERE map.coa_mapping_id = v_mapping_id
  -- AND   map.to_ccid IS NULL
  -- AND   map.from_summary_flag IS NULL
  --
  --   The second update statement, run only if create_ccid is true, populates
  --   to_ccid for all code combinations that had ccids created in this procedure.
  --
  -- UPDATE GL_ACCTS_MAP_INT_GT map
  -- SET to_ccid =
  -- (SELECT cc.code_combination_id
  -- FROM GL_CODE_COMBINATIONS cc
  -- WHERE cc.chart_of_accounts_id = v_to_coa_id
  -- AND cc.SEGMENT1 = map.TO_SEGMENT1
  -- AND cc.SEGMENT2 = map.TO_SEGMENT2
  -- AND cc.SEGMENT3 = map.TO_SEGMENT3
  -- AND cc.SEGMENT4 = map.TO_SEGMENT4
  -- AND cc.SEGMENT5 = map.TO_SEGMENT5
  -- AND cc.SEGMENT6 = map.TO_SEGMENT6
  -- AND cc.SEGMENT7 = map.TO_SEGMENT7
  -- AND cc.SEGMENT8 = map.TO_SEGMENT8
  -- AND cc.SEGMENT9 = map.TO_SEGMENT9
  -- AND cc.SEGMENT10 = map.TO_SEGMENT10)
  -- WHERE map.coa_mapping_id = v_mapping_id
  -- AND   map.to_ccid IS NULL
  --
  -- History
  --   23-MAY-02  M. Ward 	Created
  -- Arguments
  --   mapping_id		The mapping ID for this run
  --   create_ccid		Whether or not to create new ccids if necessary
  --   to_coa_id		To Chart of Accounts ID
  --   from_coa_id		From Chart of Accounts ID
  --
  PROCEDURE end_map(mapping_id			IN NUMBER,
                    create_ccid			IN BOOLEAN,
                    to_coa_id			IN NUMBER,
                    from_coa_id			IN NUMBER
                   ) IS

    -- this will hold the update statement for setting the code combination ids
    -- for those code combinations which are already defined in the
    -- gl_code_combinations table, and for setting the error codes for those
    -- source accounts that were invalid or had no mapping defined for them.
    update_1	VARCHAR2(8000);

    -- this will hold the update statement for setting the code combination ids
    -- for those code combinations which had ids created for them in this
    -- procedure.
    update_2	VARCHAR2(4000);

    -- used for holding the application column name 'SEGMENT<X>'
    app_col_name	fnd_id_flex_segments.application_column_name%TYPE;

    -- returns the list of segments in the target chart of accounts
    CURSOR c_to_segments IS
    SELECT	ffs1.application_column_name TO_APPLICATION_COLUMN_NAME
    FROM	FND_ID_FLEX_SEGMENTS ffs1
    WHERE	ffs1.application_id = g_application_id
    AND		ffs1.id_flex_code = g_id_flex_code
    AND		ffs1.enabled_flag = 'Y'
    AND		ffs1.id_flex_num = to_coa_id
    ORDER BY	ffs1.segment_num;

    -- returns the list of source code combinations for which a target code
    -- combination existed (from_summary_flag not null) but no target code
    -- combination could be created
    CURSOR c_missing_ccid IS
    SELECT	from_ccid
    FROM	GL_ACCTS_MAP_INT_GT map
    WHERE	map.coa_mapping_id = mapping_id
    AND		map.to_ccid IS NULL
    AND		map.from_summary_flag IS NOT NULL;

    -- app_col_name_list will keep a list of the application column names
    -- sorted by the segment number for the target segment
    app_col_name_list		fnd_flex_ext.SegmentArray;

    -- will keep the segment values for the new code combination
    new_flex_combination	fnd_flex_ext.SegmentArray;

    -- used for keeping information from the validate_segs function. It is not
    -- used otherwise because the case of invalid target code combinations is
    -- handled in a single update statement after all validate_segs function
    -- calls have been made.
    dummy	BOOLEAN;

  BEGIN
    update_1 := 'UPDATE GL_ACCTS_MAP_INT_GT map SET to_ccid = ' ||
                '(SELECT to_cc.code_combination_id ' ||
                'FROM gl_code_combinations to_cc ' ||
                'WHERE to_cc.chart_of_accounts_id = ' || TO_CHAR(to_coa_id);

    update_2 := 'UPDATE GL_ACCTS_MAP_INT_GT map SET to_ccid = ' ||
                '(SELECT cc.code_combination_id ' ||
                'FROM GL_CODE_COMBINATIONS cc ' ||
                'WHERE cc.chart_of_accounts_id = ' || TO_CHAR(to_coa_id);

    FOR seg_rule IN c_to_segments LOOP
      app_col_name := seg_rule.TO_APPLICATION_COLUMN_NAME;
      update_1 := update_1 || ' AND to_cc.' || app_col_name ||
                  ' (+) = map.TO_' || app_col_name;
      update_2 := update_2 || ' AND cc.' || app_col_name ||
                  ' = map.TO_' || app_col_name;

      -- append the application column name to the list
      app_col_name_list(NVL(app_col_name_list.last,0) + 1) := app_col_name;
    END LOOP;

    update_1 := update_1 || '), error_code = ' ||
                '(SELECT decode(NVL(map.from_summary_flag, ''X''), ''X'', ' ||
                'decode(COUNT(*), 0, ''INVALID_FROM_CCID'', ' ||
                '''NO_MAPPING'')) ' ||
                'FROM GL_CODE_COMBINATIONS from_cc ' ||
                'WHERE from_cc.code_combination_id = map.from_ccid ' ||
                'AND from_cc.chart_of_accounts_id = ' ||
                TO_CHAR(from_coa_id) || ') ' ||
                'WHERE map.coa_mapping_id = ' || to_char(mapping_id) ||
                ' AND map.to_ccid IS NULL ' ||
                'AND map.from_summary_flag IS NULL';

    update_2 := update_2 || ') ' ||
                'WHERE map.coa_mapping_id = ' || to_char(mapping_id) ||
                ' AND map.to_ccid IS NULL';

    -- DEBUG prints the contents of the update statement to screen
    writedebug('This updates the error codes as necessary: ');
    FOR i IN 0..(lengthb(update_1)-1)/2000 LOOP
      writedebug(SUBSTRB(update_1, i*2000+1, 2000));
    END LOOP;
    writedebug(' ');

    -- populate the error code column for accounts that had no mapping or were
    -- invalid code combinations. This also sets the code combination ids for
    -- those code combinations that are already defined in gl_code_combinations.
    EXECUTE IMMEDIATE update_1;

    -- if create_ccid is false, there is no need to do any more, so we can skip
    -- the steps to creating code combinations, etc.
    IF create_ccid THEN

      -- For each of the code combinations without a corresponding id, we will
      -- attempt to create a code combination id, and then populate the
      -- GL_ACCTS_MAP_INT_GT table accordingly with those ids, and
      -- the appropriate error code for those code combinations for which a
      -- code combination id could not be created.
      FOR missing_account IN c_missing_ccid LOOP

        -- this loop goes through each of the segments in the target code
        -- combination and puts the segment values into the new_flex_combination
        -- array.
        FOR i IN 1..g_target_nSegments LOOP
     EXECUTE IMMEDIATE
       'SELECT TO_' || app_col_name_list(i) ||
       ' FROM GL_ACCTS_MAP_INT_GT ' ||
       'WHERE coa_mapping_id = :1 ' ||
       ' AND from_ccid = :2 '
     INTO      new_flex_combination(i)
     USING     IN mapping_id, IN missing_account.from_ccid;

   END LOOP;


        -- create ccid for the missing account code combination specified. The
        -- handling of invalid segments is done in one update statement outside
        -- this loop, so the return value is not needed, and therefore is placed
        -- in the dummy variable.
        -- In the validate_segs function, I do not specify a responsibility or
        -- user id. These are defaulted by the function using FND_GLOBAL, so it
        -- is not necessary for me to fill them in.
        dummy := FND_FLEX_KEYVAL.validate_segs(
                   operation		=> 'CREATE_COMBINATION',
                   appl_short_name 	=> g_application_short_name,
                   key_flex_code	=> g_id_flex_code,
                   structure_number	=> to_coa_id,
                   concat_segments	=> FND_FLEX_EXT.concatenate_segments(
                                               g_target_nSegments,
                                               new_flex_combination,
                                               FND_FLEX_EXT.get_delimiter(
                                                 g_application_short_name,
                                                 g_id_flex_code,
                                                 to_coa_id
                                               )
                                             )
                 );
      END LOOP;

      -- DEBUG prints the contents of the update statement to screen
      writedebug('This update statement populates the target ccids: ');
      FOR i IN 0..(lengthb(update_2)-1)/2000 LOOP
        writedebug(SUBSTRB(update_2, i*2000+1, 2000));
      END LOOP;
      writedebug(' ');

      -- insert the created ccids
      EXECUTE IMMEDIATE update_2;

      -- populate the error code column for account code combinations for which
      -- a code combination could not be created
      UPDATE GL_ACCTS_MAP_INT_GT map
      SET error_code = 'UNABLE_TO_CREATE_NEW_CCID'
      WHERE coa_mapping_id = mapping_id
      AND to_ccid IS NULL
      AND error_code IS NULL;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      raise GL_MAP_UNEXPECTED_ERROR;
  END end_map;

--
-- Public Methods
--
  PROCEDURE map(mapping_name 			IN VARCHAR2,
		create_ccid			IN BOOLEAN DEFAULT TRUE,
		debug				IN BOOLEAN DEFAULT FALSE
               ) IS
    mapping_id		NUMBER;
    to_coa_id		NUMBER;
    from_coa_id		NUMBER;
  BEGIN
    g_debug_flag := debug;

    -- this will find the relevent mapping information from the name, and run
    -- simple validation tests.
    init_map(mapping_name, mapping_id, to_coa_id, from_coa_id);

    -- if there are not account rules, don't need to go through the map procedure
    IF g_num_account_rules > 0 THEN
      -- account mapping is performed before segment mapping for performance
      -- reasons. account mapping will always override segment mapping.
      account_map(mapping_id, to_coa_id, from_coa_id);
    END IF;

    -- if there are any segment rules at all, go through segment mapping
    IF g_num_segment_rules > 0 THEN
      -- this performs the segment mappings. It will not overwrite any target
      -- accounts handled by the account mappings, since the account mappings
      -- take precedence over segment mappings
      segment_map(mapping_id, to_coa_id, from_coa_id);
    END IF;

    -- this gets the code combination ids for those code combinations that are
    -- already in the gl_code_combinations table, and populates the
    -- gl_accts_map_int_gt table. It also creates new ccids if
    -- appropriate and uses those to populate the table as well. This also
    -- populates the error codes.
    end_map(mapping_id, create_ccid, to_coa_id, from_coa_id);
  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      raise GL_INVALID_MAPPING_NAME;
    WHEN GL_DISABLED_MAPPING THEN
      raise GL_DISABLED_MAPPING;
    WHEN GL_INVALID_MAPPING_RULES THEN
      raise GL_INVALID_MAPPING_RULES;
    WHEN OTHERS THEN
      raise GL_MAP_UNEXPECTED_ERROR;
  END map;



  PROCEDURE Map_Account(p_api_version	IN NUMBER,
                        p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        x_return_status	OUT NOCOPY VARCHAR2,
                        x_msg_count	OUT NOCOPY NUMBER,
                        x_msg_data	OUT NOCOPY VARCHAR2,
                        p_mapping_name	IN VARCHAR2,
                        p_create_ccid	IN VARCHAR2 DEFAULT FND_API.G_TRUE,
			p_debug		IN VARCHAR2 DEFAULT FND_API.G_FALSE
                       ) IS
    l_api_name		CONSTANT VARCHAR2(30)	:= 'Map_Account';
    l_api_version	CONSTANT NUMBER		:= 1.0;
  BEGIN
    -- create my own savepoint here in case of error
    SAVEPOINT Map_Account_GRP;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, 'GL_ACCOUNTS_MAP_GRP') THEN
      raise GL_MAP_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize the API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- this procedure does the work. Map_Account is simply a wrapper
    map(p_mapping_name, FND_API.to_Boolean(p_create_ccid),
        FND_API.to_Boolean(p_debug));

    -- never commit changes

    -- get message count, and also message if there is only one
    FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                              p_data	=> x_msg_data);

  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_DISABLED_MAPPING THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_INVALID_MAPPING_RULES THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
  END Map_Account;


  --
  -- BSV Mapping Private Methods
  --

  PROCEDURE Get_Segment_Mapping_Info(	p_mapping_name	IN VARCHAR2,
					p_qualifier	IN VARCHAR2,
					p_debug		IN BOOLEAN,
					x_mapping_rule	OUT NOCOPY VARCHAR2,
					x_to_segment	OUT NOCOPY VARCHAR2,
					x_single_value	OUT NOCOPY VARCHAR2) IS
    -- these are used for simple validation tests on the mapping
    start_date_active	DATE;
    end_date_active	DATE;

    from_coa_id		NUMBER;
    to_coa_id		NUMBER;
    mapping_id		NUMBER;

    from_segment		VARCHAR2(30);
    from_balancing_segment	VARCHAR2(30);


    -- cursor to gather information on the mapping with the given name
    CURSOR	c_mapping_info IS
    SELECT	coa_mapping_id,
		from_coa_id,
		to_coa_id,
		start_date_active,
		end_date_active
    FROM	gl_coa_mappings
    WHERE	name = p_mapping_name;

    -- cursor to figure out the balancing segment for a chart of accounts
    CURSOR	c_balancing_segment(c_coa_id NUMBER) IS
    SELECT	application_column_name
    FROM	fnd_segment_attribute_values
    WHERE	application_id = 101
    AND		id_flex_code = 'GL#'
    AND		id_flex_num = c_coa_id
    AND		segment_attribute_type = p_qualifier
    AND		attribute_value = 'Y';

    -- cursor to gather information on the segment mapping for the target
    -- balancing segment
    CURSOR	c_segment_map_info(	c_mapping_id	NUMBER,
					c_to_segment	VARCHAR2) IS
    SELECT	csm.segment_map_type,
		csm.from_application_column_name,
		csm.single_value
    FROM	gl_cons_segment_map csm
    WHERE	csm.coa_mapping_id = c_mapping_id
    AND		csm.to_application_column_name = c_to_segment;

  BEGIN
    OPEN c_mapping_info;
    FETCH c_mapping_info INTO mapping_id, from_coa_id, to_coa_id,
                              start_date_active, end_date_active;
    IF c_mapping_info%NOTFOUND THEN
      CLOSE c_mapping_info;
      raise GL_INVALID_MAPPING_NAME;
    END IF;
    CLOSE c_mapping_info;

    -- This compares SYSDATE to start/end_date_active to see if the mapping
    -- is active. If not, this raises an exception.
    IF (start_date_active IS NOT NULL AND start_date_active > SYSDATE) OR
       (end_date_active IS NOT NULL AND end_date_active < SYSDATE) THEN
      raise GL_DISABLED_MAPPING;
    END IF;

    -- Get the balancing segments for the target and source charts of accounts
    OPEN c_balancing_segment(from_coa_id);
    FETCH c_balancing_segment INTO from_balancing_segment;
    IF c_balancing_segment%NOTFOUND THEN
      CLOSE c_balancing_segment;
      raise GL_BSV_MAP_NO_SOURCE_BAL_SEG;
    END IF;
    CLOSE c_balancing_segment;

    OPEN c_balancing_segment(to_coa_id);
    FETCH c_balancing_segment INTO x_to_segment;
    IF c_balancing_segment%NOTFOUND THEN
      CLOSE c_balancing_segment;
      raise GL_BSV_MAP_NO_TARGET_BAL_SEG;
    END IF;
    CLOSE c_balancing_segment;

    -- Get the segment mapping information for the target balancing segment
    OPEN c_segment_map_info(mapping_id, x_to_segment);
    FETCH c_segment_map_info INTO x_mapping_rule, from_segment, x_single_value;
    IF c_segment_map_info%NOTFOUND THEN
      CLOSE c_segment_map_info;
      raise GL_BSV_MAP_NO_SEGMENT_MAP;
    END IF;
    CLOSE c_segment_map_info;

    -- Now perform some checks on the segment mapping:
    -- 1. If Single Value is selected, a single value must be specified
    -- 2. If Copy or Rollup is selected, a source segment must be specified
    -- 3. If Copy or Rollup is selected, the source segment must be the
    --    balancing segment for the source chart of accounts
    IF x_mapping_rule = 'S' THEN
      IF x_single_value IS NULL THEN
        raise GL_BSV_MAP_NO_SINGLE_VALUE;
      END IF;
    ELSIF from_segment IS NULL THEN
      raise GL_BSV_MAP_NO_FROM_SEGMENT;
    ELSIF from_segment <> from_balancing_segment THEN
      raise GL_BSV_MAP_NOT_BSV_DERIVED;
    END IF;

  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      raise GL_INVALID_MAPPING_NAME;
    WHEN GL_DISABLED_MAPPING THEN
      raise GL_DISABLED_MAPPING;
    WHEN GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
      raise GL_BSV_MAP_NO_SOURCE_BAL_SEG;
    WHEN GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
      raise GL_BSV_MAP_NO_TARGET_BAL_SEG;
    WHEN GL_BSV_MAP_NO_SEGMENT_MAP THEN
      raise GL_BSV_MAP_NO_SEGMENT_MAP;
    WHEN GL_BSV_MAP_NO_SINGLE_VALUE THEN
      raise GL_BSV_MAP_NO_SINGLE_VALUE;
    WHEN GL_BSV_MAP_NO_FROM_SEGMENT THEN
      raise GL_BSV_MAP_NO_FROM_SEGMENT;
    WHEN GL_BSV_MAP_NOT_BSV_DERIVED THEN
      raise GL_BSV_MAP_NOT_BSV_DERIVED;
    WHEN OTHERS THEN
      raise GL_BSV_MAP_SETUP_ERROR;
  END Get_Segment_Mapping_Info;


  PROCEDURE Perform_Segment_Mapping(	p_mapping_rule	IN VARCHAR2,
					p_to_segment	IN VARCHAR2,
					p_single_value	IN VARCHAR2,
					p_debug		IN BOOLEAN) IS
    l_rollup_stmt	VARCHAR2(2000);
  BEGIN
    IF p_mapping_rule = 'S' THEN
      UPDATE	GL_ACCTS_MAP_BSV_GT
      SET	target_bsv = p_single_value;
    ELSIF p_mapping_rule = 'C' THEN
      UPDATE	GL_ACCTS_MAP_BSV_GT
      SET	target_bsv = source_bsv;
    ELSE -- mapping rule is a rollup
      EXECUTE IMMEDIATE
        'UPDATE GL_ACCTS_MAP_BSV_GT bm ' ||
        'SET target_bsv = ' ||
        '(SELECT ami.target_flex_value ' ||
        'FROM GL_ACCTS_MAP_SEG' || substr(p_to_segment,8,2) || '_GT ami ' ||
        'WHERE ami.source_flex_value = bm.source_bsv)';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise GL_BSV_MAP_MAPPING_ERROR;
  END Perform_Segment_Mapping;

  --
  -- BSV Mapping Public Methods
  --

  PROCEDURE map_bsvs(	p_mapping_name	IN VARCHAR2,
			p_debug		IN BOOLEAN) IS
    l_mapping_rule	VARCHAR2(1);
    l_to_segment	VARCHAR2(30);
    l_single_value	VARCHAR2(25);
  BEGIN
    -- get the information required for this chart of accounts mapping
    get_segment_mapping_info(	p_mapping_name	=> p_mapping_name,
				p_qualifier	=> 'GL_BALANCING',
				p_debug		=> p_debug,
				x_mapping_rule	=> l_mapping_rule,
				x_to_segment	=> l_to_segment,
				x_single_value	=> l_single_value);

    -- perform the required mapping
    perform_segment_mapping(	p_mapping_rule	=> l_mapping_rule,
				p_to_segment	=> l_to_segment,
				p_single_value	=> l_single_value,
				p_debug		=> p_debug);
  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      raise GL_INVALID_MAPPING_NAME;
    WHEN GL_DISABLED_MAPPING THEN
      raise GL_DISABLED_MAPPING;
    WHEN GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
      raise GL_BSV_MAP_NO_SOURCE_BAL_SEG;
    WHEN GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
      raise GL_BSV_MAP_NO_TARGET_BAL_SEG;
    WHEN GL_BSV_MAP_NO_SEGMENT_MAP THEN
      raise GL_BSV_MAP_NO_SEGMENT_MAP;
    WHEN GL_BSV_MAP_NO_SINGLE_VALUE THEN
      raise GL_BSV_MAP_NO_SINGLE_VALUE;
    WHEN GL_BSV_MAP_NO_FROM_SEGMENT THEN
      raise GL_BSV_MAP_NO_FROM_SEGMENT;
    WHEN GL_BSV_MAP_NOT_BSV_DERIVED THEN
      raise GL_BSV_MAP_NOT_BSV_DERIVED;
    WHEN GL_BSV_MAP_SETUP_ERROR THEN
      raise GL_BSV_MAP_SETUP_ERROR;
    WHEN GL_BSV_MAP_MAPPING_ERROR THEN
      raise GL_BSV_MAP_MAPPING_ERROR;
    WHEN OTHERS THEN
      raise GL_BSV_MAP_UNEXPECTED_ERROR;
  END;


  PROCEDURE Populate_BSV_Targets
	(p_api_version		IN NUMBER,
	 p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	 x_return_status	OUT NOCOPY VARCHAR2,
	 x_msg_count		OUT NOCOPY NUMBER,
	 x_msg_data		OUT NOCOPY VARCHAR2,
	 p_mapping_name		IN VARCHAR2,
	 p_debug		IN VARCHAR2 DEFAULT FND_API.G_FALSE
	) IS
    l_api_name		CONSTANT VARCHAR2(30)	:= 'Populate_BSV_Targets';
    l_api_version	CONSTANT NUMBER		:= 1.0;
  BEGIN
    -- create my own savepoint here in case of error
    SAVEPOINT Populate_BSV_Targets_Start;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, 'GL_ACCOUNTS_MAP_GRP') THEN
      raise GL_BSV_MAP_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize the API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Now go to the mapping procedure
    map_bsvs(	p_mapping_name => p_mapping_name,
		p_debug	=> FND_API.to_boolean(p_debug));

    -- never commit changes

    -- get message count, and also message if there is only one
    FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                              p_data	=> x_msg_data);

  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_DISABLED_MAPPING THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_SEGMENT_MAP THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_SINGLE_VALUE THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_FROM_SEGMENT THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NOT_BSV_DERIVED THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_SETUP_ERROR THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_MAPPING_ERROR THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Populate_BSV_Targets_Start;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
  END Populate_BSV_Targets;


  --
  -- BSV Mapping Public Methods
  --

  PROCEDURE map_qualified_segment(	p_mapping_name	IN VARCHAR2,
					p_qualifier	IN VARCHAR2,
					p_debug		IN BOOLEAN) IS
    l_mapping_rule	VARCHAR2(1);
    l_to_segment	VARCHAR2(30);
    l_single_value	VARCHAR2(25);
  BEGIN
    -- get the information required for this chart of accounts mapping
    get_segment_mapping_info(	p_mapping_name	=> p_mapping_name,
				p_qualifier	=> p_qualifier,
				p_debug		=> p_debug,
				x_mapping_rule	=> l_mapping_rule,
				x_to_segment	=> l_to_segment,
				x_single_value	=> l_single_value);

    -- perform the required mapping
    perform_segment_mapping(	p_mapping_rule	=> l_mapping_rule,
				p_to_segment	=> l_to_segment,
				p_single_value	=> l_single_value,
				p_debug		=> p_debug);
  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      raise GL_INVALID_MAPPING_NAME;
    WHEN GL_DISABLED_MAPPING THEN
      raise GL_DISABLED_MAPPING;
    WHEN GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
      raise GL_BSV_MAP_NO_SOURCE_BAL_SEG;
    WHEN GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
      raise GL_BSV_MAP_NO_TARGET_BAL_SEG;
    WHEN GL_BSV_MAP_NO_SEGMENT_MAP THEN
      raise GL_BSV_MAP_NO_SEGMENT_MAP;
    WHEN GL_BSV_MAP_NO_SINGLE_VALUE THEN
      raise GL_BSV_MAP_NO_SINGLE_VALUE;
    WHEN GL_BSV_MAP_NO_FROM_SEGMENT THEN
      raise GL_BSV_MAP_NO_FROM_SEGMENT;
    WHEN GL_BSV_MAP_NOT_BSV_DERIVED THEN
      raise GL_BSV_MAP_NOT_BSV_DERIVED;
    WHEN GL_BSV_MAP_SETUP_ERROR THEN
      raise GL_BSV_MAP_SETUP_ERROR;
    WHEN GL_BSV_MAP_MAPPING_ERROR THEN
      raise GL_BSV_MAP_MAPPING_ERROR;
    WHEN OTHERS THEN
      raise GL_BSV_MAP_UNEXPECTED_ERROR;
  END;


  PROCEDURE Populate_Qual_Segment_Targets
	(p_api_version		IN NUMBER,
	 p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	 x_return_status	OUT NOCOPY VARCHAR2,
	 x_msg_count		OUT NOCOPY NUMBER,
	 x_msg_data		OUT NOCOPY VARCHAR2,
	 p_mapping_name		IN VARCHAR2,
	 p_qualifier		IN VARCHAR2,
	 p_debug		IN VARCHAR2 DEFAULT FND_API.G_FALSE
	) IS
    l_api_name		CONSTANT VARCHAR2(30)	:= 'Populate_Qual_Segment_Targets';
    l_api_version	CONSTANT NUMBER		:= 1.0;
  BEGIN
    -- create my own savepoint here in case of error
    SAVEPOINT Populate_QS_Targets_Start;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, 'GL_ACCOUNTS_MAP_GRP') THEN
      raise GL_BSV_MAP_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize the API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Now go to the mapping procedure
    map_qualified_segment(	p_mapping_name	=> p_mapping_name,
				p_qualifier	=> p_qualifier,
				p_debug	=> FND_API.to_boolean(p_debug));

    -- never commit changes

    -- get message count, and also message if there is only one
    FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                              p_data	=> x_msg_data);

  EXCEPTION
    WHEN GL_INVALID_MAPPING_NAME THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_DISABLED_MAPPING THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_SOURCE_BAL_SEG THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_TARGET_BAL_SEG THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_SEGMENT_MAP THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_SINGLE_VALUE THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NO_FROM_SEGMENT THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_NOT_BSV_DERIVED THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_SETUP_ERROR THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN GL_BSV_MAP_MAPPING_ERROR THEN
      ROLLBACK TO Map_Account_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Populate_QS_Targets_Start;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count	=> x_msg_count,
                                p_data	=> x_msg_data);
  END Populate_Qual_Segment_Targets;

END GL_ACCOUNTS_MAP_GRP;

/
