--------------------------------------------------------
--  DDL for Package Body FEM_MULTI_PROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_MULTI_PROC_PKG" AS
-- $Header: fem_mp_utl.plb 120.6.12010000.2 2008/10/06 23:37:31 huli ship $

--------------------
-- Package Constants
--------------------
c_mp_sub_prg   CONSTANT  VARCHAR2(30) := 'FEM_MPSUBREQ';
c_mp_app_id    CONSTANT  NUMBER := 274;  -- App ID for FEM

c_max_procs    CONSTANT  NUMBER := 8;

c_ctl_table    CONSTANT  VARCHAR2(30) := 'FEM_MP_PROCESS_CTL_T';
c_arg_table    CONSTANT  VARCHAR2(30) := 'FEM_MP_PROCESS_ARGS_T';

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

e_soft_kill         EXCEPTION;
e_bad_mp_settings   EXCEPTION;


/**************************************************************************
 **************************************************************************

                         ========================
                              Engine_Params
                         ========================

 **************************************************************************
 **************************************************************************/

PROCEDURE Engine_Params (
p_eng_prg         IN  VARCHAR2,
x_prms_in         OUT NOCOPY NUMBER
)
IS

t_overload        DBMS_DESCRIBE.NUMBER_TABLE;
t_position        DBMS_DESCRIBE.NUMBER_TABLE;
t_level           DBMS_DESCRIBE.NUMBER_TABLE;
t_arg_name        DBMS_DESCRIBE.VARCHAR2_TABLE;
t_datatype        DBMS_DESCRIBE.NUMBER_TABLE;
t_def_val         DBMS_DESCRIBE.NUMBER_TABLE;
t_io_mode         DBMS_DESCRIBE.NUMBER_TABLE;
t_length          DBMS_DESCRIBE.NUMBER_TABLE;
t_precision       DBMS_DESCRIBE.NUMBER_TABLE;
t_scale           DBMS_DESCRIBE.NUMBER_TABLE;
t_radix           DBMS_DESCRIBE.NUMBER_TABLE;
t_spare           DBMS_DESCRIBE.NUMBER_TABLE;
i_idx             NUMBER := 0;

BEGIN

/**************************************************************************

                  Get number of Engine IN parameters

 **************************************************************************/

   DBMS_DESCRIBE.DESCRIBE_PROCEDURE
   (
    p_eng_prg,
    null,
    null,
    t_overload,
    t_position,
    t_level,
    t_arg_name,
    t_datatype,
    t_def_val,
    t_io_mode,
    t_length,
    t_precision,
    t_scale,
    t_radix,
    t_spare
   );

   x_prms_in := 0;
   LOOP
      i_idx := i_idx + 1;
      IF t_io_mode(i_idx) = 0
      THEN
         x_prms_in := x_prms_in + 1;
      END IF;
   END LOOP;

EXCEPTION
   WHEN no_data_found THEN
      RETURN;

END Engine_Params;


/**************************************************************************
                      ==================================
                           Put_Distinct_Data_Slices
                      ==================================
-- This procedure does an INSERT/SELECT to insert all data slices for
-- one table partition (or for the entire table if not partitioned)
-- for the Distinct Values data slicing method only.  Note that for distinct
-- data slicing, any null values in the input data will be ignored (and
-- they will not be reported as errors).  The MP framework assumes that any
-- column selected as a data slicing column will not contain any null values.
-- (All rows are processed when data slicing is off, since there are no data
-- slicing columns defined for the "no slicing" method).
 **************************************************************************/

PROCEDURE Put_Distinct_Data_Slices (
   p_rownum       IN OUT  NOCOPY NUMBER,
   p_req_id       IN      NUMBER,
   p_rule_id      IN      NUMBER,
   p_data_table   IN      VARCHAR2,
   p_condition    IN      VARCHAR2,
   p_data_slc     IN      VARCHAR2 DEFAULT NULL,
   p_part_name    IN      VARCHAR2 DEFAULT NULL)
IS

   v_block             VARCHAR2(80) := 'fem.plsql.fem_mp.put_distinct_data_slices';
   v_condition         VARCHAR2(32767);
   v_part_clause       VARCHAR2(50);
   v_sql_cmd           VARCHAR2(32766);

BEGIN

   v_condition := NVL(REPLACE(p_condition,'WHERE',''),'1=1');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_part_name{580}',
     p_msg_text => p_part_name);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_data_slc{581}',
     p_msg_text => p_data_slc);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{582}',
     p_msg_text => TO_CHAR(p_rownum));

   IF (p_part_name IS NOT NULL)
   THEN
      v_part_clause := ' PARTITION (' || p_part_name || ')';
   ELSE
      v_part_clause := '';
   END if;

   v_sql_cmd :=
      'INSERT INTO fem_mp_process_ctl_t' ||
         '(req_id, rule_id, slice_id, partition, data_slice, process_num, '||
          'rows_processed, rows_loaded, rows_rejected, status, message)'||
       ' SELECT '||
           p_req_id || ',' || p_rule_id || ',rownum +' || p_rownum ||
           ', ''' || p_part_name || ''', data_slice, 0, null, null, null, null, null' ||
       ' FROM ' ||
          '(SELECT DISTINCT ' || p_data_slc || ' data_slice' ||
          ' FROM ' || p_data_table || v_part_clause ||
          ' WHERE ' || v_condition || ')';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.v_sql_cmd{583}',
     p_msg_text => v_sql_cmd);

   EXECUTE IMMEDIATE v_sql_cmd;
   COMMIT;

   SELECT NVL(MAX(slice_id), 0)
   INTO p_rownum
   FROM FEM_MP_PROCESS_CTL_T
   WHERE req_id = p_req_id;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{584}',
     p_msg_text => p_rownum);

END Put_Distinct_Data_Slices;


/**************************************************************************
                        ==================================
                             Put_Range_Slices_Unique
                        ==================================
-- This procedure does an INSERT/SELECT using the NTILE SQL function
-- against the input table to insert all data slices for one table
-- partition (or for the entire table if not partitioned) for the
-- Value Ranges data slicing method only, and only for columns known to
-- be distinct and non-null within the input data.
-- Currently, this only includes
--    ROWID (for all tables using ROWID for slicing) and
--    CREATION_ROW_SEQUENCE on FEM_BALANCES.
-- Future optimizations could include ACTIVITY_ID for the
-- CALC_ACT_RATE_FACTORS and CALC_ACT_RATE_VALUES steps of the ACTIVITY_RATE
-- object type, and SEQ_ID for the CALC_DRIVER_VALUES of the ACTIVITY_RATE
-- object type.  Currently multiprocessing is disabled for the Activity Rate
-- engine.
-- Further enhancements could include CUSTOMER_ID for the Value Index
-- calculation, and possibly other Customer Profit object types as well
-- when multiprocessing is enabled for those object types.
 **************************************************************************/

PROCEDURE Put_Range_Slices_Unique (
   p_rownum       IN OUT  NOCOPY NUMBER,
   p_req_id       IN      NUMBER,
   p_rule_id      IN      NUMBER,
   p_num_slices   IN      NUMBER,
   p_data_table   IN      VARCHAR2,
   p_slc_col      IN      VARCHAR2,
   p_condition    IN      VARCHAR2,
   p_part_name    IN      VARCHAR2 DEFAULT NULL)
IS

   v_block             VARCHAR2(80) := 'fem.plsql.fem_mp.put_range_slices_unique';
   v_condition         VARCHAR2(32766);
   v_part_clause       VARCHAR2(50);
   v_sql_cmd           VARCHAR2(32766);

BEGIN

   v_condition := NVL(REPLACE(p_condition,'WHERE',''),'1=1');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_part_name{580}',
     p_msg_text => p_part_name);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_slc_col{581}',
     p_msg_text => p_slc_col);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{582}',
     p_msg_text => TO_CHAR(p_rownum));

   IF (p_part_name IS NOT NULL)
   THEN
      v_part_clause := ' PARTITION (' || p_part_name || ')';
   ELSE
      v_part_clause := '';
   END if;

   v_sql_cmd :=
      'INSERT INTO fem_mp_process_ctl_t ' ||
        '(req_id,rule_id,' ||
         'slice_id,partition,' ||
         'data_slice,' ||
         'process_num,rows_processed,rows_loaded,' ||
         'rows_rejected,status,message) ' ||
        'SELECT ' ||
           p_req_id || ', ' || p_rule_id || ', ' ||
           'rownum + ' || p_rownum || ', ''' || p_part_name || ''', ' ||
           'minval||''{#}''||maxval' ||
           ', 0, null, null, ' ||
           'null, null, null ' ||
        'FROM ' ||
          '(SELECT ' ||
              'MIN(slice_column) minval, ' ||
              'MAX(slice_column) maxval ' ||
           'FROM ' ||
             '(SELECT ' ||
                 p_slc_col || ' slice_column, ' ||
                 'NTILE(' || p_num_slices || ') ' ||
                   'OVER (ORDER BY ' || p_slc_col || ') tile ' ||
              'FROM ' || p_data_table || v_part_clause ||
             ' WHERE ' || v_condition || ') ' ||
           'GROUP BY tile)';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.v_sql_cmd{583}',
     p_msg_text => v_sql_cmd);

   EXECUTE IMMEDIATE v_sql_cmd;
   COMMIT;

   SELECT NVL(MAX(slice_id), 0)
   INTO p_rownum
   FROM FEM_MP_PROCESS_CTL_T
   WHERE req_id = p_req_id;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{584}',
     p_msg_text => p_rownum);

END Put_Range_Slices_Unique;


/**************************************************************************
                          =========================
                               Put_Data_Slice
                          =========================
-- Inserts one data slice into the process control table.  Used by the
-- Put_Range_Slices_Non_Unique procedure to insert data slices one at a
-- time, and used by Build_Data_Slices to create a single dummy data
-- slice when slicing is disabled or when a data slice column is not
-- specified.
 **************************************************************************/

PROCEDURE Put_Data_Slice(
   p_rownum       IN OUT  NOCOPY NUMBER,
   p_req_id       IN      NUMBER,
   p_rule_id      IN      NUMBER,
   p_data_slc     IN      VARCHAR2,
   p_part_name    IN      VARCHAR2 DEFAULT NULL)
IS

   v_block        VARCHAR2(80) := 'fem.plsql.fem_mp.put_data_slice';

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{582}',
     p_msg_text => TO_CHAR(p_rownum));

   p_rownum := p_rownum + 1;

   INSERT INTO fem_mp_process_ctl_t
     (req_id, rule_id, slice_id, partition, data_slice, process_num,
      rows_processed, rows_loaded, rows_rejected, status, message)
   VALUES
     (p_req_id, p_rule_id, p_rownum, p_part_name, p_data_slc, 0,
      null, null, null, null, null);

   COMMIT;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{584}',
     p_msg_text => TO_CHAR(p_rownum));

END Put_Data_Slice;


/**************************************************************************
                    =====================================
                         Put_Range_Slices_Non_Unique
                    =====================================
-- For data slicing columns that are not guaranteed to be unique within the
-- input data, this procedure populates the process control table with data
-- slices for the current partition of the input table (or for the entire
-- table if not partitioned).  It loops through the rows returned by a
-- dynamic SELECT statement against the input table using the NTILE function,
-- and makes necessary adjustments to the endpoints, whenever the NTILE
-- function separates rows having the same value of the data slicing column
-- into more than one data slice, then inserts the adjusted data slice into
-- the process control table.  Note that value ranges data slicing on non-
-- unique columns, any null values in the input data will be ignored (and
-- they will not be reported as errors).  The MP framework assumes that any
-- column selected as a data slicing column will not contain any null values.
-- (All rows are processed when data slicing is off, since there are no data
-- slicing columns defined for the "no slicing" method).
 **************************************************************************/

PROCEDURE Put_Range_Slices_Non_Unique (
   p_rownum       IN OUT  NOCOPY NUMBER,
   p_req_id       IN      NUMBER,
   p_rule_id      IN      NUMBER,
   p_num_slices   IN      NUMBER,
   p_data_table   IN      VARCHAR2,
   p_slc_col      IN      VARCHAR2,
   p_col_type     IN      VARCHAR2,
   p_condition    IN      VARCHAR2,
   p_part_name    IN      VARCHAR2 DEFAULT NULL)
IS

   v_block        VARCHAR2(80) := 'fem.plsql.fem_mp.put_range_slices_non_unique';
   v_condition    VARCHAR2(32767);
   v_part_clause  VARCHAR2(50);
   v_sql_cmd1     VARCHAR2(32766);
   v_sql_cmd2     VARCHAR2(32766);
   v_last_hi      VARCHAR2(150);
   v_lo_val       VARCHAR2(150);
   v_hi_val       VARCHAR2(150);
   v_data_slc     VARCHAR2(4000);

   TYPE c_ref_curs    IS REF CURSOR;
   c_col_slc          c_ref_curs;

BEGIN

   v_condition := NVL(REPLACE(p_condition,'WHERE',''),'1=1');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_part_name{580}',
     p_msg_text => p_part_name);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_slc_col{581}',
     p_msg_text => p_slc_col);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.p_rownum{582}',
     p_msg_text => TO_CHAR(p_rownum));

   IF (p_part_name IS NOT NULL)
   THEN
      v_part_clause := ' PARTITION (' || p_part_name || ')';
   ELSE
      v_part_clause := '';
   END if;

   -- Bug 5365387.  Ordered results to ensure that slice range
   -- values are ascending.
   v_sql_cmd1 :=
      'SELECT ' ||
         'MIN(slice_column) minval, ' ||
         'MAX(slice_column) maxval ' ||
      'FROM ' ||
        '(SELECT ' ||
            p_slc_col || ' slice_column, ' ||
            'NTILE(' || p_num_slices || ') ' ||
              'OVER (ORDER BY ' || p_slc_col || ') tile ' ||
         'FROM ' || p_data_table || v_part_clause ||
        ' WHERE ' || v_condition || ') ' ||
      'GROUP BY tile ' ||
      'ORDER BY minval ASC';

   v_sql_cmd2 :=
      'SELECT MIN(' || p_slc_col || ') ' ||
      'FROM ' || p_data_table || v_part_clause ||
     ' WHERE ' || v_condition ||
       ' AND ' || p_slc_col || ' > :b_last_max';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.v_sql_cmd1{571}',
     p_msg_text => v_sql_cmd1);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.v_sql_cmd2{572}',
     p_msg_text => v_sql_cmd2);

   IF (p_col_type = 'NUMBER')
   THEN
      v_last_hi := -999;
   ELSE
      v_last_hi := '!#$';
   END IF;

   OPEN c_col_slc FOR
      v_sql_cmd1;
   LOOP
      FETCH c_col_slc INTO v_lo_val, v_hi_val;
      EXIT WHEN c_col_slc%NOTFOUND;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_3,
        p_module => v_block||'.ntile_min_max{574}',
        p_msg_text => v_lo_val||'{#}'||v_hi_val);

      IF (p_col_type = 'NUMBER')
      THEN
         IF (TO_NUMBER(v_lo_val) <= TO_NUMBER(v_last_hi))
         THEN
            EXECUTE IMMEDIATE v_sql_cmd2
            INTO v_lo_val
            USING v_last_hi;

            FEM_ENGINES_PKG.TECH_MESSAGE
             (p_severity => c_log_level_3,
              p_module => v_block||'.adjusted_min_max{574.1}',
              p_msg_text => v_lo_val||'{#}'||v_hi_val);
         END IF;

         IF (TO_NUMBER(v_lo_val) > TO_NUMBER(v_hi_val))
         THEN
            v_hi_val := v_lo_val;

            FEM_ENGINES_PKG.TECH_MESSAGE
             (p_severity => c_log_level_3,
              p_module => v_block||'.adjusted_min_max{574.2}',
              p_msg_text => v_lo_val||'{#}'||v_hi_val);
         END IF;

      ELSE

         IF (v_lo_val <= v_last_hi)
         THEN
            EXECUTE IMMEDIATE v_sql_cmd2
            INTO v_lo_val
            USING v_last_hi;

            FEM_ENGINES_PKG.TECH_MESSAGE
             (p_severity => c_log_level_3,
              p_module => v_block||'.adjusted_min_max{575.1}',
              p_msg_text => v_lo_val||'{#}'||v_hi_val);
         END IF;

         IF (v_lo_val > v_hi_val)
         THEN
            v_hi_val := v_lo_val;

            FEM_ENGINES_PKG.TECH_MESSAGE
             (p_severity => c_log_level_3,
              p_module => v_block||'.adjusted_min_max{575.2}',
              p_msg_text => v_lo_val||'{#}'||v_hi_val);
         END IF;
      END IF;

      IF (v_lo_val IS NULL)
      THEN
         EXIT;
      END IF;

      v_data_slc := v_lo_val||'{#}'||v_hi_val;

      Put_Data_Slice(
         p_rownum    => p_rownum,
         p_req_id    => p_req_id,
         p_rule_id   => p_rule_id,
         p_data_slc  => v_data_slc,
         p_part_name => p_part_name);

      v_last_hi := v_hi_val;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.v_last_hi{576}',
        p_msg_text => v_last_hi);

   END LOOP;
   CLOSE c_col_slc;

END Put_Range_Slices_Non_Unique;


/**************************************************************************
                         =============================
                              Build_Data_Slices
                         =============================
 **************************************************************************/

PROCEDURE Build_Data_Slices (
   x_slc_pred       OUT     NOCOPY VARCHAR2,
   x_part_code      IN OUT  NOCOPY NUMBER,
   p_req_id         IN      NUMBER,
   p_rule_id        IN      NUMBER,
   p_slc_code       IN      NUMBER,
   p_slc_type       IN      NUMBER,
   p_part_code      IN      NUMBER,
   p_data_table     IN      VARCHAR2,
   p_table_alias    IN      VARCHAR2,
   p_source_db_link IN      VARCHAR2 DEFAULT NULL,
   p_condition      IN      VARCHAR2 DEFAULT NULL)
IS

   i_counter      NUMBER;
   i_rownum       NUMBER;

   v_last_row     NUMBER;
   v_count        NUMBER;
   v_num_slices   NUMBER;
   v_num_slices_calc NUMBER;
   v_rows_slice   NUMBER;

   v_data_table   VARCHAR2(160);
   v_tab_name     VARCHAR2(30);
   v_tab_owner    VARCHAR2(30);
   v_return_status   VARCHAR2(1);
   v_msg_count       NUMBER;
   v_msg_data     VARCHAR2(4000);

   v_col_name     VARCHAR2(80);
   v_col_slc      VARCHAR2(240);
   v_data_slice   VARCHAR2(4000);
   v_col_type     VARCHAR2(30);
   v_part_name    VARCHAR2(30);
   v_slc_col      VARCHAR2(30);
   v_slc_method   VARCHAR2(30);
   v_condition    VARCHAR2(32767);

   v_block        VARCHAR2(80) := 'fem.plsql.fem_mp.bld_data_slices';

   v_sql_cmd      VARCHAR2(32766);

   TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   t_num_val    number_type;

   TYPE display_code_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
   t_chr_val   display_code_type;

   TYPE c_ref_curs        IS REF CURSOR;
   c_tab_part             c_ref_curs;

   CURSOR c_slc_col IS
      SELECT column_name
      FROM   fem_mp_data_slice_cols
      WHERE  process_data_slices_cd = p_slc_code
      ORDER BY process_data_slice_seq;

/**************************************************************************
                     Build Data Slices: Execution Block
 **************************************************************************/
BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{550}',
  p_msg_text => 'Begin FEM_MP.Build_Data_Slices');
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_req_id{552}',
  p_msg_text => p_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_slc_code{553}',
  p_msg_text => p_slc_code);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_slc_type{554}',
  p_msg_text => p_slc_type);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_part_code{555}',
  p_msg_text => p_part_code);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_data_table{556}',
  p_msg_text => p_data_table);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_table_alias{557}',
  p_msg_text => p_table_alias);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_condition{558}',
  p_msg_text => p_condition);

v_condition := NVL(REPLACE(p_condition,'WHERE',''),'1=1');

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_condition{559}',
  p_msg_text => v_condition);

---------------------------
-- Get Table Name and Owner
---------------------------

IF (p_source_db_link IS NULL)
THEN
   v_data_table := p_data_table;

   SELECT table_name,table_owner
   INTO v_tab_name,v_tab_owner
   FROM user_synonyms
   WHERE synonym_name = p_data_table;
ELSE
   v_data_table := p_data_table||'@'||p_source_db_link;

   v_sql_cmd :=
   'SELECT table_name,table_owner'||
   ' FROM user_synonyms@'||p_source_db_link||
   ' WHERE synonym_name = :b_data_table';

   EXECUTE IMMEDIATE v_sql_cmd
   INTO v_tab_name,v_tab_owner
   USING p_data_table;

END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_tab_name{556.1}',
  p_msg_text => v_tab_name);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_tab_owner{556.2}',
  p_msg_text => v_tab_owner);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_data_table{556.3}',
  p_msg_text => v_data_table);

----------------------------------------------------
-- Remove data slices in case Job has multiple steps
----------------------------------------------------
DELETE FROM FEM_MP_PROCESS_CTL_T
WHERE req_id = p_req_id;

COMMIT;

/**************************************************************************
                        Determine slicing method
             If slicing is disabled, then v_slc_col is set to NULL
 **************************************************************************/
BEGIN
   SELECT UPPER(column_name)
   INTO   v_slc_col
   FROM   fem_mp_data_slice_cols
   WHERE  process_data_slices_cd = p_slc_code
   AND    process_data_slice_seq = 1;
EXCEPTION
   WHEN no_data_found THEN
      v_slc_col := '';
      v_col_type := 'VARCHAR2';
END;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_col{560}',
  p_msg_text => v_slc_col);

IF (v_slc_col IS NOT NULL)
THEN
   IF (v_slc_col = 'ROWID') AND (p_slc_type <> 2)
   THEN
      RAISE e_bad_mp_settings;
   END IF;

   IF (p_slc_type = 1)
   THEN
      v_col_type := 'VARCHAR2';
   END IF;

   IF (p_slc_type = 2)
   THEN
      BEGIN
         SELECT  num_of_slices,rows_per_slice
         INTO    v_num_slices, v_rows_slice
         FROM    fem_mp_data_slices
         WHERE   process_data_slices_cd = p_slc_code;
      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_bad_mp_settings;
      END;

      IF (v_num_slices IS NOT NULL)
      THEN
         v_rows_slice := null;
      END IF;

      IF (v_num_slices > 0)
          OR (v_rows_slice > 0)
      THEN
         IF (v_slc_col = 'ROWID')
         THEN
            v_col_type := 'ROWID';
         ELSE
            IF (p_source_db_link IS NULL)
            THEN
               SELECT data_type
               INTO v_col_type
               FROM all_tab_columns
               WHERE owner = v_tab_owner
               AND table_name = v_tab_name
               AND column_name = v_slc_col;
            ELSE
            -- Shouldn't this be all_tab_columns?
               v_sql_cmd :=
               'SELECT data_type'||
               ' FROM dba_tab_columns@'||p_source_db_link||
               ' WHERE owner = :b_tab_owner'||
               ' AND table_name = :b_tab_name'||
               ' AND column_name = :b_slc_col';

               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_col_type
               USING v_tab_owner,v_tab_name,v_slc_col;
            END IF;

         END IF;
      ELSE
         RAISE e_bad_mp_settings;
      END IF;
   END IF;

   IF (p_slc_type = 3)
   THEN
      v_slc_col := null;
      v_num_slices := null;
      v_rows_slice := null;
   END IF;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.v_num_slices{561}',
 p_msg_text => v_num_slices);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.v_rows_slice{562}',
 p_msg_text => v_rows_slice);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_col{563}',
  p_msg_text => v_slc_col);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_col_type{564}',
  p_msg_text => v_col_type);

/**************************************************************************
   Determining data slicing method, and prepare data slice and data slice
   predicate values.
 **************************************************************************/
IF (v_slc_col IS NOT NULL) AND (p_slc_type = 1)
THEN
-- ------------------------------------------------------------------------
-- Prepare for slicing on distinct values
-- ------------------------------------------------------------------------
   v_slc_method := 'DISTINCT';

   FOR r_slc_col IN c_slc_col LOOP

      v_col_name := UPPER(r_slc_col.column_name);

      IF (p_table_alias IS NULL)
      THEN
         v_col_slc := v_col_name || ' = :b_val_' || c_slc_col%ROWCOUNT;
      ELSE
         v_col_slc := p_table_alias || '.' || v_col_name ||
                      ' = :b_val_' || c_slc_col%ROWCOUNT;
      END IF;

      IF (c_slc_col%ROWCOUNT = 1)
      THEN
         x_slc_pred := v_col_slc;
      ELSIF (c_slc_col%ROWCOUNT < 5)
      THEN
         x_slc_pred := x_slc_pred||' AND '||v_col_slc;
      ELSE
         EXIT;
      END IF;

      IF (v_data_slice IS NULL)
      THEN
        v_data_slice := v_col_name;
      ELSE
        v_data_slice := v_data_slice||'||''{#}''||'||v_col_name;
      END IF;

   END LOOP;

ELSIF (v_slc_col IS NOT NULL) AND (p_slc_type = 2)
THEN
-- ------------------------------------------------------------------------
-- Prepare for slicing on value ranges
-- ------------------------------------------------------------------------
   IF (p_table_alias IS NULL)
   THEN
      x_slc_pred := v_slc_col||' BETWEEN :b_val_1 AND :b_val_2 ';
   ELSE
      x_slc_pred := p_table_alias||'.'||v_slc_col||
                    ' BETWEEN :b_val_1 AND :b_val_2 ';
   END IF;

   IF (v_slc_col = 'ROWID')
         OR (    (v_slc_col = 'CREATION_ROW_SEQUENCE')
             AND (p_data_table = 'FEM_BALANCES'))
   THEN
   -- -----------------------------------------------------------------
   -- These columns are guaranteed to be unique within the input set
   -- so the data slices can be populated directly as an INSERT/SELECT
   -- statement.
   -- -----------------------------------------------------------------
      v_slc_method := 'RANGE_UNIQUE';
   ELSE
   -- -----------------------------------------------------------------
   -- For range slicing on all other columns, the NTILE function may
   -- divide the same column value into two different slices, so
   -- the range endpoints have to be adjusted.
   -- -----------------------------------------------------------------
      v_slc_method := 'RANGE_NON_UNIQUE';
   END IF;

ELSIF (v_slc_col IS NULL)
THEN
-- --------------------------------------------------------------------
-- Prepare for one single DUMMY data slice (1=1)
-- --------------------------------------------------------------------
   v_slc_method := 'NO_SLICING';
   x_slc_pred := '1 = :b_val_1';
   v_data_slice := 1;

END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_method{565}',
  p_msg_text => v_slc_method);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_data_slc{566}',
  p_msg_text => v_data_slice);

/**************************************************************************
                        Loop through table partitions
   The data on each partition is sliced per the specified slicing method
   If the table is not partitioned, or partition slicing is disabled,
   then the loop exits after just one pass
 **************************************************************************/

i_rownum := 0;

IF (p_source_db_link IS NULL)
THEN
   v_sql_cmd :=
   'SELECT partition_name'||
   ' FROM  all_tab_partitions'||
   ' WHERE table_owner = '''||v_tab_owner||''''||
   ' AND   table_name = '''||v_tab_name||''''||
   ' ORDER BY partition_position';
ELSE
   v_sql_cmd :=
   'SELECT partition_name'||
   ' FROM  all_tab_partitions@'||p_source_db_link||
   ' WHERE table_owner = '''||v_tab_owner||''''||
   ' AND   table_name = '''||v_tab_name||''''||
   ' ORDER BY partition_position';
END IF;

OPEN c_tab_part FOR v_sql_cmd;
LOOP
   FETCH c_tab_part INTO v_part_name;
   IF (c_tab_part%NOTFOUND)
   THEN
      CASE c_tab_part%ROWCOUNT
         WHEN 0 THEN x_part_code := 0;
         ELSE EXIT;
      END CASE;
   ELSE
      CASE p_part_code
         WHEN 0 THEN v_part_name := '';
         ELSE NULL;
      END CASE;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_part_name{580}',
     p_msg_text => v_part_name);

   IF v_slc_method = 'DISTINCT'
   THEN

      Put_Distinct_Data_Slices(
       p_rownum => i_rownum,
       p_req_id => p_req_id,
       p_rule_id => p_rule_id,
       p_data_table => v_data_table,
       p_condition => v_condition,
       p_data_slc => v_data_slice,
       p_part_name => v_part_name);

   ELSIF (v_slc_method = 'RANGE_UNIQUE'
          OR v_slc_method = 'RANGE_NON_UNIQUE')
   THEN

      v_num_slices_calc := v_num_slices;

      IF ((v_num_slices IS NULL or v_num_slices < 1) AND v_rows_slice > 0)
      THEN
         ----------------------------------------------
         -- Convert rows per slice to number of slices
         ----------------------------------------------
         IF (v_part_name IS NULL)
         THEN
            EXECUTE IMMEDIATE
               'SELECT COUNT(*)'||
               ' FROM '||v_data_table||
               ' WHERE '||v_condition
            INTO v_count;
         ELSE
            EXECUTE IMMEDIATE
               'SELECT COUNT(*)'||
               ' FROM '||v_data_table||' PARTITION('||v_part_name||')'||
               ' WHERE '||v_condition
            INTO v_count;
         END IF;

         v_num_slices_calc := CEIL(v_count/v_rows_slice);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_2,
           p_module => v_block||'.v_num_slices_calc{570}',
           p_msg_text => v_num_slices_calc);

      END IF;

      IF v_num_slices_calc > 0
      THEN

         IF (v_slc_method = 'RANGE_UNIQUE')
         THEN

            Put_Range_Slices_Unique (
               p_rownum     => i_rownum,
               p_req_id     => p_req_id,
               p_rule_id    => p_rule_id,
               p_num_slices => v_num_slices_calc,
               p_data_table => v_data_table,
               p_slc_col    => v_slc_col,
               p_condition  => v_condition,
               p_part_name  => v_part_name);

         ELSE

            Put_Range_Slices_Non_Unique (
               p_rownum     => i_rownum,
               p_req_id     => p_req_id,
               p_rule_id    => p_rule_id,
               p_num_slices => v_num_slices_calc,
               p_data_table => v_data_table,
               p_slc_col    => v_slc_col,
               p_col_type   => v_col_type,
               p_condition  => v_condition,
               p_part_name  => v_part_name);

         END IF;

      END IF;

   ELSIF (v_slc_col IS NULL)
   THEN
   -- --------------------------------------------------------------------
   -- Build DUMMY data slice (1=1)
   -- --------------------------------------------------------------------
      IF v_part_name IS NOT NULL
      THEN
      -- Only post a data slice for this partition if it has any data
      -- that matches the condition
         EXECUTE IMMEDIATE
            'SELECT COUNT(*)'||
            ' FROM '||v_data_table||' PARTITION('||v_part_name||')'||
            ' WHERE '||v_condition||
              ' AND ROWNUM = 1'
         INTO v_count;
      ELSE
      -- Partitioning is off; must post one dummy data slice for the table.
         v_count := 1;
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.v_count{570.1}',
        p_msg_text => v_count);

      IF v_count = 1 THEN

         Put_Data_Slice(
            p_rownum    => i_rownum,
            p_req_id    => p_req_id,
            p_rule_id   => p_rule_id,
            p_data_slc  => v_data_slice,
            p_part_name => v_part_name);

      END IF;

   END IF;

   -----------------------------------------------------------------
   -- If table is not partitioned, or partition slicing is disabled,
   -- then exit the partition loop after just one pass
   -----------------------------------------------------------------
   IF (v_part_name IS NULL)
   THEN
      EXIT;
   END IF;

END LOOP;
CLOSE c_tab_part;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.End{579}',
  p_msg_text => 'End FEM_MP.Build_Data_Slices');

END Build_Data_Slices;


/**************************************************************************
 **************************************************************************

                           =================
                                 Master
                           =================

 **************************************************************************
 **************************************************************************/

PROCEDURE Master (
x_prg_stat        OUT  NOCOPY VARCHAR2,
x_exception_code  OUT  NOCOPY VARCHAR2,
p_rule_id         IN   NUMBER,
p_eng_step        IN   VARCHAR2,
p_data_table      IN   VARCHAR2,
p_source_db_link  IN   VARCHAR2 DEFAULT NULL,
p_eng_sql         IN   VARCHAR2 DEFAULT NULL,
p_table_alias     IN   VARCHAR2 DEFAULT NULL,
p_run_name        IN   VARCHAR2 DEFAULT NULL,
p_eng_prg         IN   VARCHAR2 DEFAULT NULL,
p_condition       IN   VARCHAR2 DEFAULT NULL,
p_failed_req_id   IN   NUMBER   DEFAULT NULL,
p_reuse_slices    IN   VARCHAR2 DEFAULT 'N',
p_arg1            IN   VARCHAR2 DEFAULT NULL,
p_arg2            IN   VARCHAR2 DEFAULT NULL,
p_arg3            IN   VARCHAR2 DEFAULT NULL,
p_arg4            IN   VARCHAR2 DEFAULT NULL,
p_arg5            IN   VARCHAR2 DEFAULT NULL,
p_arg6            IN   VARCHAR2 DEFAULT NULL,
p_arg7            IN   VARCHAR2 DEFAULT NULL,
p_arg8            IN   VARCHAR2 DEFAULT NULL,
p_arg9            IN   VARCHAR2 DEFAULT NULL,
p_arg10           IN   VARCHAR2 DEFAULT NULL,
p_arg11           IN   VARCHAR2 DEFAULT NULL,
p_arg12           IN   VARCHAR2 DEFAULT NULL,
p_arg13           IN   VARCHAR2 DEFAULT NULL,
p_arg14           IN   VARCHAR2 DEFAULT NULL,
p_arg15           IN   VARCHAR2 DEFAULT NULL,
p_arg16           IN   VARCHAR2 DEFAULT NULL,
p_arg17           IN   VARCHAR2 DEFAULT NULL,
p_arg18           IN   VARCHAR2 DEFAULT NULL,
p_arg19           IN   VARCHAR2 DEFAULT NULL,
p_arg20           IN   VARCHAR2 DEFAULT NULL,
p_arg21           IN   VARCHAR2 DEFAULT NULL,
p_arg22           IN   VARCHAR2 DEFAULT NULL,
p_arg23           IN   VARCHAR2 DEFAULT NULL,
p_arg24           IN   VARCHAR2 DEFAULT NULL,
p_arg25           IN   VARCHAR2 DEFAULT NULL,
p_arg26           IN   VARCHAR2 DEFAULT NULL,
p_arg27           IN   VARCHAR2 DEFAULT NULL,
p_arg28           IN   VARCHAR2 DEFAULT NULL,
p_arg29           IN   VARCHAR2 DEFAULT NULL,
p_arg30           IN   VARCHAR2 DEFAULT NULL,
p_arg31           IN   VARCHAR2 DEFAULT NULL,
p_arg32           IN   VARCHAR2 DEFAULT NULL,
p_arg33           IN   VARCHAR2 DEFAULT NULL,
p_arg34           IN   VARCHAR2 DEFAULT NULL,
p_arg35           IN   VARCHAR2 DEFAULT NULL,
p_arg36           IN   VARCHAR2 DEFAULT NULL,
p_arg37           IN   VARCHAR2 DEFAULT NULL,
p_arg38           IN   VARCHAR2 DEFAULT NULL,
p_arg39           IN   VARCHAR2 DEFAULT NULL,
p_arg40           IN   VARCHAR2 DEFAULT NULL
)
IS

f_req_wait          BOOLEAN;
f_set_status        BOOLEAN;

v_args_count        NUMBER;
v_fetch_limit       NUMBER;
v_kill_signal       NUMBER;
v_mp_method         NUMBER;
v_num_procs         NUMBER;
v_num_slices        NUMBER;
v_part_code         NUMBER;
v_prms_count        NUMBER;
v_slc_code          NUMBER;
v_slc_id            NUMBER;
v_slc_type          NUMBER;

v_dev_phase         VARCHAR2(80);
v_dev_status        VARCHAR2(80);
v_prg_stat          VARCHAR2(160);
v_eng_prg           VARCHAR2(80);
v_eng_step          VARCHAR2(30);
v_max_slice         VARCHAR2(4000);
v_msg_text          VARCHAR2(32767);
v_obj_type          VARCHAR2(30);
v_prg_msg           VARCHAR2(2000);
v_req_message       VARCHAR2(4000);
v_req_phase         VARCHAR2(4000);
v_req_status        VARCHAR2(4000);
v_req_name          VARCHAR2(80);
v_slc_pred          VARCHAR2(32767);
v_sub_req_id        NUMBER;

v_stack             VARCHAR2(32767);
v_trace             VARCHAR2(255);

v_req_id            NUMBER := fnd_global.conc_request_id;

v_block             VARCHAR2(80) := 'fem.plsql.fem_mp.master';

v_sql_cmd           VARCHAR2(32766);

CURSOR c_sub_req_id IS
   SELECT request_id
   FROM   fnd_concurrent_requests R,
          fnd_concurrent_programs P
   WHERE  parent_request_id = v_req_id
   AND    R.concurrent_program_id = P.concurrent_program_id
   AND    P.concurrent_program_name = c_mp_sub_prg
   AND    P.application_id = c_mp_app_id
   ORDER BY request_id;

e_no_rule_id        EXCEPTION;
e_no_mp_method      EXCEPTION;
e_no_data_slices    EXCEPTION;
e_no_subreq         EXCEPTION;

/**************************************************************************

                           Master: Execution Block

 **************************************************************************/

BEGIN

DBMS_SESSION.SET_SQL_TRACE (sql_trace => FALSE);
v_trace := 'FEM_MP.Master:'||v_req_id;

FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_3,
 p_module => v_block||'.Begin{500}',
 p_msg_text => 'Begin FEM_MP.MASTER');
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.v_req_id{501}',
 p_msg_text => v_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_rule_id{502}',
 p_msg_text => p_rule_id);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_eng_step{503}',
 p_msg_text => p_eng_step);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_1,
 p_module => v_block||'.p_eng_sql{504}',
 p_msg_text => p_eng_sql);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_data_table{505}',
 p_msg_text => p_data_table);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_table_alias{506}',
 p_msg_text => p_table_alias);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_run_name{507}',
 p_msg_text => p_run_name);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_eng_prg{508}',
 p_msg_text => p_eng_prg);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_condition{509}',
 p_msg_text => p_condition);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.p_failed_req_id{510}',
 p_msg_text => p_failed_req_id);

IF (p_run_name IS NOT NULL)
THEN
   v_req_name := v_req_id||' ('||p_run_name||')';
ELSE
   v_req_name := v_req_id;
END IF;

------------------------
-- Check for Kill signal (this feature is not implemented yet)
------------------------
v_kill_signal := 0;

CASE v_kill_signal
   WHEN 1 THEN RAISE e_soft_kill;
   ELSE NULL;
END CASE;

/**************************************************************************

                          Get Processing Method

 **************************************************************************/
BEGIN
   SELECT object_type_code
   INTO v_obj_type
   FROM fem_object_catalog_b
   WHERE object_id = p_rule_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_no_rule_id;
END;

BEGIN
   SELECT step_name,
          TO_NUMBER(mp_method_code)
   INTO   v_eng_step,
          v_mp_method
   FROM   fem_mp_obj_step_methods
   WHERE  object_type_code = v_obj_type
   AND    step_name = p_eng_step;
EXCEPTION
   WHEN no_data_found THEN
   BEGIN
      SELECT 'ALL',
             TO_NUMBER(mp_method_code)
      INTO   v_eng_step,
             v_mp_method
      FROM   fem_mp_obj_step_methods
      WHERE  object_type_code = v_obj_type
      AND    step_name = 'ALL';
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_mp_method;
   END;
END;

CASE v_mp_method
   WHEN 1 THEN v_eng_prg := '';
   ELSE v_eng_prg := p_eng_prg;
END CASE;

/**************************************************************************

                          Get Processing Settings

 **************************************************************************/
BEGIN
   SELECT step_name,
          process_data_slices_cd,
          TO_NUMBER(data_slice_type_code),
          process_partition_cd,
          num_of_processes,
          array_size_rows
   INTO   v_eng_step,
          v_slc_code,
          v_slc_type,
          v_part_code,
          v_num_procs,
          v_fetch_limit
   FROM   fem_mp_process_options
   WHERE  object_type_code = v_obj_type
   AND    step_name = p_eng_step
   AND    object_id = p_rule_id;
EXCEPTION
   WHEN no_data_found THEN
   BEGIN
      SELECT 'ALL',
             process_data_slices_cd,
             TO_NUMBER(data_slice_type_code),
             process_partition_cd,
             num_of_processes,
             array_size_rows
      INTO   v_eng_step,
             v_slc_code,
             v_slc_type,
             v_part_code,
             v_num_procs,
             v_fetch_limit
      FROM   fem_mp_process_options
      WHERE  object_type_code = v_obj_type
      AND    step_name = 'ALL'
      AND    object_id = p_rule_id;
   EXCEPTION
      WHEN no_data_found THEN
      BEGIN
         SELECT step_name,
                process_data_slices_cd,
                TO_NUMBER(data_slice_type_code),
                process_partition_cd,
                num_of_processes,
                array_size_rows
         INTO   v_eng_step,
                v_slc_code,
                v_slc_type,
                v_part_code,
                v_num_procs,
                v_fetch_limit
         FROM   fem_mp_process_options
         WHERE  object_type_code = v_obj_type
         AND    step_name = p_eng_step
         AND    object_id IS NULL;
      EXCEPTION
         WHEN no_data_found THEN
         BEGIN
            SELECT 'ALL',
                   process_data_slices_cd,
                   TO_NUMBER(data_slice_type_code),
                   process_partition_cd,
                   num_of_processes,
                   array_size_rows
            INTO   v_eng_step,
                   v_slc_code,
                   v_slc_type,
                   v_part_code,
                   v_num_procs,
                   v_fetch_limit
            FROM   fem_mp_process_options P
            WHERE  object_type_code = v_obj_type
            AND    step_name = 'ALL'
            AND    object_id IS NULL;
         EXCEPTION
            WHEN no_data_found THEN
               FEM_ENGINES_PKG.PUT_MESSAGE
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_MP_NO_SETTINGS_WARN',
                 p_token1 => 'REQUEST',
                 p_value1 => v_req_name);
               v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

               FEM_ENGINES_PKG.TECH_MESSAGE
                (p_severity => c_log_level_5,
                 p_module => v_block||'.get_mp_settings{542}',
                 p_msg_text => v_prg_msg);
               FEM_ENGINES_PKG.USER_MESSAGE(
                p_msg_text => v_prg_msg);

--                f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS(
--                                'WARNING',null);
         END;
      END;
   END;
END;

IF (v_slc_type IS NULL)
THEN
   v_slc_type := 3;
END IF;

IF (v_part_code IS NULL)
THEN
   v_part_code := 0;
END IF;

IF (v_num_procs IS NULL)
THEN
   v_num_procs := 0;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.v_eng_prg{511}',
 p_msg_text => v_eng_prg);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.v_obj_type{512}',
 p_msg_text => v_obj_type);
FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.v_eng_step{513}',
 p_msg_text => v_eng_step);
CASE v_mp_method
   WHEN 0 THEN v_msg_text := v_mp_method||' (Predicate push)';
   WHEN 1 THEN v_msg_text := v_mp_method||' (Pull)';
   WHEN 2 THEN v_msg_text := v_mp_method||' (Bind values push)';
   ELSE v_msg_text := v_mp_method||' (Invalid MP Method Code)';
END CASE;
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_mp_method{514}',
  p_msg_text => v_msg_text);
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_code{515}',
  p_msg_text => v_slc_code);
CASE v_slc_type
   WHEN 0 THEN v_msg_text := v_slc_type||' (Engine specific)';
   WHEN 1 THEN v_msg_text := v_slc_type||' (Distinct values)';
   WHEN 2 THEN v_msg_text := v_slc_type||' (Value ranges)';
   WHEN 3 THEN v_msg_text := v_slc_type||' (No slicing)';
   ELSE v_msg_text := v_slc_type||' (Invalid Data Slice Type Code)';
END CASE;
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_type{516}',
  p_msg_text => v_msg_text);
CASE v_part_code
   WHEN 0 THEN v_msg_text := v_part_code||' (No partitioning)';
   WHEN 1 THEN v_msg_text := v_part_code||' (Shared partitioning)';
   WHEN 2 THEN v_msg_text := v_part_code||' (Dedicated partitioning)';
   ELSE v_msg_text := v_part_code||' (Invalid Process Partition Code)';
END CASE;
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_part_code{517}',
  p_msg_text => v_msg_text);
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_num_procs{518}',
  p_msg_text => v_num_procs);
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_fetch_limit{519}',
  p_msg_text => v_fetch_limit);

IF (p_reuse_slices = 'N')
THEN
   ----------------------------------
   -- Housekeep the MP process tables
   ----------------------------------
   DELETE FROM fem_mp_process_ctl_t T
   WHERE rule_id = p_rule_id
     AND (req_id IN (SELECT request_id
                     FROM fnd_concurrent_requests
                     WHERE phase_code = 'C')
          OR NOT EXISTS (SELECT 1 FROM fnd_concurrent_requests
                         WHERE request_id = T.req_id));

   DELETE FROM fem_mp_process_args_t T
   WHERE rule_id = p_rule_id
     AND (req_id IN (SELECT request_id
                     FROM fnd_concurrent_requests
                     WHERE phase_code = 'C')
          OR NOT EXISTS (SELECT 1 FROM fnd_concurrent_requests
                         WHERE request_id = T.req_id));
   COMMIT;

   IF (v_slc_type > 0)
   THEN
     /***********************************************************************

                            Build Data Slices

      ***********************************************************************/
      DELETE FROM fem_mp_process_ctl_t
      WHERE req_id = v_req_id;

      COMMIT;

      --------------------------------------
      -- Call procedure to Build Data Slices
      --------------------------------------
      Build_Data_Slices(
       x_slc_pred => v_slc_pred,
       x_part_code => v_part_code,
       p_req_id => v_req_id,
       p_rule_id => p_rule_id,
       p_slc_code => v_slc_code,
       p_slc_type => v_slc_type,
       p_part_code => v_part_code,
       p_data_table => p_data_table,
       p_table_alias => p_table_alias,
       p_source_db_link => p_source_db_link,
       p_condition => p_condition);
   END IF;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_pred{520.1}',
  p_msg_text => v_slc_pred);
FEM_ENGINES_PKG.TECH_MESSAGE(
  p_severity => c_log_level_2,
  p_module => v_block||'.v_part_code{520.2}',
  p_msg_text => v_part_code);

IF (p_reuse_slices = 'N')
THEN
  /***********************************************************************

                   Verify existence of data slices

   ***********************************************************************/
   SELECT MAX(REPLACE(data_slice,'{#}',''))
   INTO v_max_slice
   FROM fem_mp_process_ctl_t
   WHERE req_id = v_req_id;


   IF (v_max_slice IS NOT NULL)
   THEN
      SELECT COUNT(*)
      INTO v_num_slices
      FROM fem_mp_process_ctl_t
      WHERE req_id = v_req_id;
   ELSE
      RAISE e_no_data_slices;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_2,
    p_module => v_block||'.v_num_slices{521}',
    p_msg_text => v_num_slices);

   IF (v_num_procs = 0)
   THEN
      v_num_procs := v_num_slices;
   END IF;

   IF (v_num_procs > v_num_slices)
   THEN
      v_num_procs := v_num_slices;
   END IF;

   IF (v_num_procs > c_max_procs)
   THEN
      v_num_procs := c_max_procs;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_2,
    p_module => v_block||'.v_num_procs{522}',
    p_msg_text => v_num_procs);
   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_2,
    p_module => v_block||'.v_slc_pred{523}',
    p_msg_text => v_slc_pred);
END IF;

IF (p_reuse_slices = 'Y') AND (p_failed_req_id IS NOT NULL)
THEN
  /***********************************************************************

                        Process Error Rerun

   ***********************************************************************/
   UPDATE fem_mp_process_ctl_t
   SET req_id = v_req_id,
       process_num = 0
   WHERE req_id = p_failed_req_id
     AND status IS NULL;

END IF;

IF (p_reuse_slices = 'R')
THEN
  /***********************************************************************

                     Reset Data Slices to Initial State

   ***********************************************************************/
   UPDATE fem_mp_process_ctl_t
   SET process_num = 0,
       rows_processed = null,
       rows_loaded = null,
       rows_rejected = null,
       status = null,
       message = null
   WHERE req_id = v_req_id;

END IF;

IF (p_reuse_slices = 'Y') AND (p_failed_req_id IS NULL)
THEN
  /***********************************************************************

                 Running as a Restart -- Reuse arguments

   ***********************************************************************/
   NULL;

ELSE
  /***********************************************************************

             NOT running as a Restart -- Store new arguments

   ***********************************************************************/
   DELETE FROM fem_mp_process_args_t
   WHERE req_id = v_req_id;

   COMMIT;

   IF (v_mp_method = 1)
   THEN
      v_args_count := 0;
   ELSE
      Engine_Params(
         p_eng_prg => v_eng_prg,
         x_prms_in => v_prms_count);

      v_args_count := v_prms_count - 5;  -- There are 5 reqd IN parameters

      FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => c_log_level_2,
       p_module => v_block||'.v_prms_count{524.1}',
       p_msg_text => v_prms_count);
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_2,
    p_module => v_block||'.v_args_count{524.2}',
    p_msg_text => v_args_count);

   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_1,
    p_module => v_block||'.v_sql_cmd{525}',
    p_msg_text => 'Inserting into FEM_MP_PROCESS_ARGS_T...');

   INSERT INTO fem_mp_process_args_t
     (req_id,rule_id,eng_prg,eng_sql,slc_pred,arg_count,
      arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,
      arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,
      arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,
      arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32,
      arg33,arg34,arg35,arg36,arg37,arg38,arg39,arg40)
   VALUES
     (v_req_id,p_rule_id,v_eng_prg,
      p_eng_sql,v_slc_pred,v_args_count,
      p_arg1, p_arg2, p_arg3, p_arg4,
      p_arg5, p_arg6, p_arg7, p_arg8,
      p_arg9, p_arg10,p_arg11,p_arg12,
      p_arg13,p_arg14,p_arg15,p_arg16,
      p_arg17,p_arg18,p_arg19,p_arg20,
      p_arg21,p_arg22,p_arg23,p_arg24,
      p_arg25,p_arg26,p_arg27,p_arg28,
      p_arg29,p_arg30,p_arg31,p_arg32,
      p_arg33,p_arg34,p_arg35,p_arg36,
      p_arg37,p_arg38,p_arg39,p_arg40);

   COMMIT;
END IF;

-----------------------------------------------------
-- RETURN;  -- Build data slices only - no processing
-----------------------------------------------------

/*************************************************************************

                     Submit Concurrent Subrequests

 *************************************************************************/

FOR i_proc_num IN 1..v_num_procs LOOP

   v_sub_req_id :=  0;   -- Generate error for testing

   v_sub_req_id :=  FND_REQUEST.SUBMIT_REQUEST(
                     application => 'FEM',
                     program => c_mp_sub_prg,
                     sub_request => FALSE,
                     argument1 => v_req_id,
                     argument2 => v_mp_method,
                     argument3 => v_slc_type,
                     argument4 => i_proc_num,
                     argument5 => v_part_code,
                     argument6 => v_fetch_limit);

   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_2,
    p_module => v_block||'.sub_request{530}',
    p_msg_text => 'i_proc_num='||i_proc_num||':v_sub_req_id='||v_sub_req_id);

   IF (v_sub_req_id = 0)
   THEN
      EXIT;
   ELSE
      COMMIT;
   END IF;
END LOOP;

/*************************************************************************

                 Wait for Concurrent Subrequests to Complete

 *************************************************************************/

x_prg_stat := 'COMPLETE:NORMAL';
FOR r_sub_req_id IN c_sub_req_id
LOOP

   v_sub_req_id := r_sub_req_id.request_id;

   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => c_log_level_2,
    p_module => v_block||'.v_sub_req_id{531.1}',
    p_msg_text => v_sub_req_id);

   LOOP
      f_req_wait := FND_CONCURRENT.WAIT_FOR_REQUEST
                    (v_sub_req_id,5,0,v_req_phase,v_req_status,
                     v_dev_phase,v_dev_status,v_req_message);

      FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => c_log_level_2,
       p_module => v_block||'.req_status{531.2}',
       p_msg_text =>  'Sub-request='||v_sub_req_id||' : '||
                      'Phase='||v_dev_phase||' : '||
                      'Status='||v_dev_status);

      CASE v_dev_phase
         WHEN 'COMPLETE' THEN EXIT;
         WHEN 'INACTIVE' THEN EXIT;
         ELSE NULL;
      END CASE;
   END LOOP;

   v_prg_stat := v_dev_phase||':'||v_dev_status;

   IF (v_prg_stat = 'COMPLETE:NORMAL')
   THEN
      null;
   ELSIF (v_prg_stat = 'COMPLETE:WARNING')
   THEN
      CASE x_prg_stat
         WHEN 'COMPLETE:NORMAL' THEN x_prg_stat := 'COMPLETE:WARNING';
         ELSE null;
      END CASE;
   ELSE
      x_prg_stat := v_prg_stat;
   END IF;

END LOOP;

IF (v_sub_req_id = 0)
THEN
   RAISE e_no_subreq;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_2,
 p_module => v_block||'.x_prg_stat{532}',
 p_msg_text => x_prg_stat);

IF (x_prg_stat = 'COMPLETE:NORMAL')
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUBS_NORMAL_TXT',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');
ELSIF (x_prg_stat = 'COMPLETE:WARNING')
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUBS_WARN_TXT',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');
ELSE
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUBS_ERROR_TXT',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE(
 p_severity => c_log_level_3,
 p_module => v_block||'.End{533}',
 p_msg_text => 'End FEM_MP.MASTER. '||v_prg_msg);
-- FEM_ENGINES_PKG.USER_MESSAGE(
--  p_msg_text => v_prg_msg);

/*************************************************************************

                           Master: Exception Block

 *************************************************************************/

EXCEPTION

WHEN e_soft_kill THEN
   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SOFT_KILL_WARN',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE(
     p_severity => c_log_level_5,
     p_module => v_block||'.soft_kill_signal{540}',
     p_msg_text => v_prg_msg);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_prg_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',null);
   x_prg_stat := 'COMPLETE:WARNING';
   x_exception_code := 'FEM_MP_SOFT_KILL_WARN';

WHEN e_no_rule_id THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_BAD_OBJECT_ERR',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.get_object_type_code{541}',
     p_msg_text => v_prg_msg);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_prg_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
   x_prg_stat := 'COMPLETE:ERROR';
   x_exception_code := 'FEM_MP_BAD_OBJECT_ERR';

WHEN e_no_mp_method THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_NO_METHOD_ERR',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.get_mp_settings{542}',
     p_msg_text => v_prg_msg);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_prg_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
   x_prg_stat := 'COMPLETE:ERROR';
   x_exception_code := 'FEM_MP_NO_METHOD_ERR';

WHEN e_bad_mp_settings THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_BAD_SETTINGS_ERR',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.get_mp_settings{543}',
     p_msg_text => v_prg_msg);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_prg_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
   x_prg_stat := 'COMPLETE:ERROR';
   x_exception_code := 'FEM_MP_BAD_SETTINGS_ERR';

WHEN e_no_data_slices THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_NO_DATA_SLICES_ERR',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.Build_Data_Slices{544}',
     p_msg_text => v_prg_msg);

   --f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
   x_prg_stat := 'COMPLETE:ERROR';
   x_exception_code := 'FEM_MP_NO_DATA_SLICES_ERR';

WHEN e_no_subreq THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_NO_SUBREQ_ERR',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_5,
     p_module => v_block||'.submit_sub_request{545}',
     p_msg_text => v_prg_msg);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_prg_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
   x_prg_stat := 'COMPLETE:ERROR';
   x_exception_code := 'FEM_MP_NO_SUBREQ_ERR';

WHEN others THEN
   v_stack := dbms_utility.format_call_stack;

   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_UNEXP_ERR',
     p_token1 => 'REQUEST',
     p_value1 => v_req_name,
     p_token2 => 'SQLERRM',
     p_value2 => sqlerrm);
   v_prg_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_6,
     p_module => v_block||'.exception{546}',
     p_msg_text => v_prg_msg||'
'||v_stack);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_prg_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);
   x_prg_stat := 'COMPLETE:ERROR';
   x_exception_code := 'FEM_MP_UNEXP_ERR';

END Master;


/**************************************************************************
 **************************************************************************

                           =====================
                                Sub_Request
                           =====================

 **************************************************************************
 **************************************************************************/

PROCEDURE Sub_Request (
errbuf           OUT     NOCOPY VARCHAR2,
retcode          OUT     NOCOPY VARCHAR2,
p_req_id         IN      NUMBER,
p_mp_method      IN      NUMBER,
p_slc_type       IN      NUMBER,
p_proc_num       IN      NUMBER,
p_part_code      IN      NUMBER,
p_fetch_limit    IN      NUMBER
)
IS

f_set_status             BOOLEAN;

v_kill_signal            NUMBER;
v_part_count             NUMBER;
v_slc_id                 NUMBER;
v_slc_stat               NUMBER;
v_sub_stat               NUMBER;
v_rows_processed         NUMBER;
v_rows_loaded            NUMBER;
v_rows_rejected          NUMBER;
v_rule_id                NUMBER;
v_slc_beg                NUMBER;
v_num_vals               NUMBER;
v_slc_len                NUMBER;
v_slc_num                NUMBER;

v_arg                    VARCHAR2(32767);
v_arg_list               VARCHAR2(32767);
v_args_count             NUMBER;
v_data_slc               VARCHAR2(4000);
v_data_item              VARCHAR2(240);
v_slc_val1               VARCHAR2(240);
v_slc_val2               VARCHAR2(240);
v_slc_val3               VARCHAR2(240);
v_slc_val4               VARCHAR2(240);
v_eng_prg                VARCHAR2(80);
v_eng_prms               VARCHAR2(32767);
v_part_name              VARCHAR2(30);
v_part_next              VARCHAR2(30);
v_slc_msg                VARCHAR2(4000);
v_slc_pred               VARCHAR2(32767);
v_slc_pred1              VARCHAR2(32767);
v_slc_pred2              VARCHAR2(32767);
v_upd_stmt               VARCHAR2(255);

v_stack                  VARCHAR2(32767);
v_trace                  VARCHAR2(255);

v_sub_msg                VARCHAR2(4000);
v_sub_req_id             NUMBER := fnd_global.conc_request_id;

v_block                  VARCHAR2(80) := 'fem.plsql.fem_mp.subreq'||
                                         '{p'||p_proc_num||'}';
v_block2                 VARCHAR2(80);

v_eng_sql_param          VARCHAR2(32767);
v_eng_sql                VARCHAR2(32767);
v_eng_call               VARCHAR2(32767);

v_sql_cmd                VARCHAR2(32767);

v_data_num               NUMBER;
v_data_chr               VARCHAR2(150);

TYPE arg_type            IS TABLE OF VARCHAR2(32767)
                            INDEX BY BINARY_INTEGER;
t_arg                    arg_type;

/*=========================================================================

                     Sub-Request: Execution Block

 =========================================================================*/

BEGIN

DBMS_SESSION.SET_SQL_TRACE (sql_trace => FALSE);
v_trace := 'FEM_MP.Subrequest:'||v_sub_req_id;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Begin{600}',
  p_msg_text => 'Begin FEM_MP.SUBREQ');
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_sub_req_id{601}',
  p_msg_text => v_sub_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_mp_method{602}',
  p_msg_text => p_mp_method);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_slc_type{603}',
  p_msg_text => p_slc_type);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_proc_num{605}',
  p_msg_text => p_proc_num);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_part_code{606}',
  p_msg_text => p_part_code);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.p_fetch_limit{607}',
  p_msg_text => p_fetch_limit);

/*------------------------------------------------------------------------

                          Get stored arguments

 -------------------------------------------------------------------------*/

IF (p_mp_method = 1)
THEN
   SELECT rule_id,eng_prg,eng_sql,slc_pred,arg_count
   INTO v_rule_id,v_eng_prg,v_eng_sql_param,v_slc_pred,v_args_count
   FROM fem_mp_process_args_t
   WHERE req_id = p_req_id;
ELSE
   SELECT
      rule_id,eng_prg,eng_sql,slc_pred,arg_count,
      arg1, arg2, arg3, arg4,
      arg5, arg6, arg7, arg8,
      arg9, arg10,arg11,arg12,
      arg13,arg14,arg15,arg16,
      arg17,arg18,arg19,arg20,
      arg21,arg22,arg23,arg24,
      arg25,arg26,arg27,arg28,
      arg29,arg30,arg31,arg32,
      arg33,arg34,arg35,arg36,
      arg37,arg38,arg39,arg40
   INTO
      v_rule_id,v_eng_prg,v_eng_sql_param,v_slc_pred,v_args_count,
      t_arg(1), t_arg(2), t_arg(3), t_arg(4),
      t_arg(5), t_arg(6), t_arg(7), t_arg(8),
      t_arg(9), t_arg(10),t_arg(11),t_arg(12),
      t_arg(13),t_arg(14),t_arg(15),t_arg(16),
      t_arg(17),t_arg(18),t_arg(19),t_arg(20),
      t_arg(21),t_arg(22),t_arg(23),t_arg(24),
      t_arg(25),t_arg(26),t_arg(27),t_arg(28),
      t_arg(29),t_arg(30),t_arg(31),t_arg(32),
      t_arg(33),t_arg(34),t_arg(35),t_arg(36),
      t_arg(37),t_arg(38),t_arg(39),t_arg(40)
   FROM fem_mp_process_args_t
   WHERE req_id = p_req_id;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_rule_id{611}',
  p_msg_text => v_rule_id);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_eng_prg{612}',
  p_msg_text => v_eng_prg);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.v_eng_sql_param{613}',
  p_msg_text => v_eng_sql_param);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_slc_pred{614}',
  p_msg_text => v_slc_pred);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_args_count{615}',
  p_msg_text => v_args_count);

IF (p_mp_method <> 1)
THEN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.1}',
     p_msg_text => t_arg(1));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.2}',
     p_msg_text => t_arg(2));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.3}',
     p_msg_text => t_arg(3));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.4}',
     p_msg_text => t_arg(4));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.5}',
     p_msg_text => t_arg(5));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.6}',
     p_msg_text => t_arg(6));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.7}',
     p_msg_text => t_arg(7));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.8}',
     p_msg_text => t_arg(8));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.9}',
     p_msg_text => t_arg(9));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.10}',
     p_msg_text => t_arg(10));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.11}',
     p_msg_text => t_arg(11));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.12}',
     p_msg_text => t_arg(12));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.13}',
     p_msg_text => t_arg(13));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.14}',
     p_msg_text => t_arg(14));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.15}',
     p_msg_text => t_arg(15));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.16}',
     p_msg_text => t_arg(16));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.17}',
     p_msg_text => t_arg(17));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.18}',
     p_msg_text => t_arg(18));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.19}',
     p_msg_text => t_arg(19));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.20}',
     p_msg_text => t_arg(20));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.21}',
     p_msg_text => t_arg(21));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.22}',
     p_msg_text => t_arg(22));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.23}',
     p_msg_text => t_arg(23));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.24}',
     p_msg_text => t_arg(24));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.25}',
     p_msg_text => t_arg(25));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.26}',
     p_msg_text => t_arg(26));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.27}',
     p_msg_text => t_arg(27));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.28}',
     p_msg_text => t_arg(28));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.29}',
     p_msg_text => t_arg(29));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.30}',
     p_msg_text => t_arg(30));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.31}',
     p_msg_text => t_arg(31));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.32}',
     p_msg_text => t_arg(32));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.33}',
     p_msg_text => t_arg(33));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.34}',
     p_msg_text => t_arg(34));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.35}',
     p_msg_text => t_arg(35));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.36}',
     p_msg_text => t_arg(36));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.37}',
     p_msg_text => t_arg(37));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.38}',
     p_msg_text => t_arg(38));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.39}',
     p_msg_text => t_arg(39));
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.t_arg_1{616.40}',
     p_msg_text => t_arg(40));
END IF;

IF (p_mp_method = 2 AND p_slc_type > 0)
THEN
/*----------------------------------------------------------------------

                           Bind Processing

----------------------------------------------------------------------*/

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.Process Method{620}',
     p_msg_text => 'Preparing for Bind Processing');

   v_eng_sql := v_eng_sql_param;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_eng_sql{616}',
     p_msg_text => v_eng_sql);

   --------------------------------------------
   --    Build call to Engine Push program
   --
   -- The structure of the call is based on the
   --   number of Engine Push program arguments
   --------------------------------------------
   v_eng_call := 'BEGIN '||v_eng_prg||
      '(:b_eng_sql,:b_slc_pred,:b_proc_num,:b_part_code,:b_fetch_limit';

   IF (v_args_count = 0)
   THEN
      v_eng_call := v_eng_call||');'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.0}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit;

   ELSIF (v_args_count = 1)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.1}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1);

   ELSIF (v_args_count = 2)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.2}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1),t_arg(2);

   ELSIF (v_args_count = 3)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.3}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1),t_arg(2),t_arg(3);

   ELSIF (v_args_count = 4)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.4}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1),t_arg(2),t_arg(3),t_arg(4);

   ELSIF (v_args_count = 5)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.5}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5);

   ELSIF (v_args_count = 6)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.6}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6);

   ELSIF (v_args_count = 7)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.7}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7);

   ELSIF (v_args_count = 8)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.8}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8);

   ELSIF (v_args_count = 9)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.9}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9);

   ELSIF (v_args_count = 10)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.10}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10);

   ELSIF (v_args_count = 11)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.11}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11);

   ELSIF (v_args_count = 12)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.12}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12);

   ELSIF (v_args_count = 13)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.13}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13);

   ELSIF (v_args_count = 14)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.14}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14);

   ELSIF (v_args_count = 15)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.15}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15);

   ELSIF (v_args_count = 16)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.16}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16);

   ELSIF (v_args_count = 17)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.17}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17);

   ELSIF (v_args_count = 18)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.18}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18);

   ELSIF (v_args_count = 19)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.19}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19);

   ELSIF (v_args_count = 20)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.20}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20);

   ELSIF (v_args_count = 21)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.21}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21);

   ELSIF (v_args_count = 22)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.22}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22);

   ELSIF (v_args_count = 23)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.23}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23);

   ELSIF (v_args_count = 24)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.24}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24);

   ELSIF (v_args_count = 25)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.25}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25);

   ELSIF (v_args_count = 26)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.26}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26);

   ELSIF (v_args_count = 27)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.27}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27);

   ELSIF (v_args_count = 28)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.28}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28);

   ELSIF (v_args_count = 29)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.29}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29);

   ELSIF (v_args_count = 30)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.30}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30);

   ELSIF (v_args_count = 31)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.31}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31);

   ELSIF (v_args_count = 32)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.32}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32);

   ELSIF (v_args_count = 33)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.33}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33);

   ELSIF (v_args_count = 34)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.34}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34);

   ELSIF (v_args_count = 35)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34,:b_arg35);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.35}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34),t_arg(35);

   ELSIF (v_args_count = 36)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34,:b_arg35,:b_arg36);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.36}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34),t_arg(35),t_arg(36);

   ELSIF (v_args_count = 37)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
         ' :b_arg37);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.37}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34),t_arg(35),t_arg(36),
            t_arg(37);

   ELSIF (v_args_count = 38)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
         ' :b_arg37,:b_arg38);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.38}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34),t_arg(35),t_arg(36),
            t_arg(37),t_arg(38);

   ELSIF (v_args_count = 39)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
         ' :b_arg37,:b_arg38,:b_arg39);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.39}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34),t_arg(35),t_arg(36),
            t_arg(37),t_arg(38),t_arg(39);

   ELSIF (v_args_count = 40)
   THEN
      v_eng_call := v_eng_call||','||
         ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
         ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
         ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
         ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
         ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
         ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
         ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
         ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
         ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
         ' :b_arg37,:b_arg38,:b_arg39,:b_arg40);'||
         ' END;';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => v_block||'.v_eng_call{620.40}',
        p_msg_text => v_eng_call);

      EXECUTE IMMEDIATE v_eng_call
      USING v_eng_sql,v_slc_pred,p_proc_num,p_part_code,p_fetch_limit,
            t_arg(1), t_arg(2), t_arg(3), t_arg(4),
            t_arg(5), t_arg(6), t_arg(7), t_arg(8),
            t_arg(9), t_arg(10),t_arg(11),t_arg(12),
            t_arg(13),t_arg(14),t_arg(15),t_arg(16),
            t_arg(17),t_arg(18),t_arg(19),t_arg(20),
            t_arg(21),t_arg(22),t_arg(23),t_arg(24),
            t_arg(25),t_arg(26),t_arg(27),t_arg(28),
            t_arg(29),t_arg(30),t_arg(31),t_arg(32),
            t_arg(33),t_arg(34),t_arg(35),t_arg(36),
            t_arg(37),t_arg(38),t_arg(39),t_arg(40);

   END IF;

ELSIF (p_mp_method <> 2 AND p_slc_type > 0)
THEN
/*----------------------------------------------------------------------

                        Pull or Push Processing

----------------------------------------------------------------------*/

LOOP

   IF (p_mp_method = 0)
   THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.Process Method{630}',
        p_msg_text => 'Preparing for Push Processing');
   ELSE
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.Process Method{630}',
        p_msg_text => 'Preparing for Pull Processing');
   END IF;

   ---------------------------
   -- Get Data Slice Values --
   ---------------------------
   Get_Data_Slice
   (x_slc_id => v_slc_id,
    x_slc_val1 => v_slc_val1,
    x_slc_val2 => v_slc_val2,
    x_slc_val3 => v_slc_val3,
    x_slc_val4 => v_slc_val4,
    x_num_vals  => v_num_vals,
    x_part_name => v_part_name,
    p_req_id => p_req_id,
    p_proc_num => p_proc_num);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_slc_id{631}',
     p_msg_text => v_slc_id);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_num_vals{632}',
     p_msg_text => v_num_vals);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_slc_val1{632.1}',
     p_msg_text => v_slc_val1);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_slc_val2{632.2}',
     p_msg_text => v_slc_val2);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_slc_val3{632.3}',
     p_msg_text => v_slc_val3);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_slc_val4{632.4}',
     p_msg_text => v_slc_val4);

   EXIT WHEN (v_slc_id IS NULL);

   v_block2 := REPLACE(v_block,'}',':s'||v_slc_id||'}');

   IF (v_num_vals > 0)
   THEN

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block2||'.v_part_name{633}',
        p_msg_text => v_part_name);

      IF (v_part_name IS NULL)
      THEN
         v_eng_sql := REPLACE(v_eng_sql_param,'{{table_partition}}',' ');
      ELSE
         v_eng_sql := REPLACE(v_eng_sql_param,'{{table_partition}}',
                              ' PARTITION(' || v_part_name || ') ');
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.v_eng_sql{634}',
        p_msg_text => v_eng_sql);

   END IF;

   IF (v_num_vals > 0 AND p_mp_method = 0)
   THEN
   /*----------------------------------------------------------------------

                           Push Processing

   ---------------------------------------------------------------------*/

      v_slc_pred1 := v_slc_pred;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block2||'.v_slc_pred1{640}',
        p_msg_text => v_slc_pred1);

      -------------------------------
      -- Prepare data slice predicate
      -------------------------------
      IF (v_num_vals = 1)
      THEN
         v_slc_pred2 := REPLACE(v_slc_pred1,':b_val_1',
                                   ''''''||v_slc_val1||'''''');
         v_data_slc := v_slc_pred2;
      ELSIF (v_num_vals = 2)
      THEN
         v_slc_pred2 := REPLACE(v_slc_pred1,':b_val_1',
                                ''''''||v_slc_val1||'''''');
         v_slc_pred1 := REPLACE(v_slc_pred2,':b_val_2',
                                ''''''||v_slc_val2||'''''');
         v_data_slc := v_slc_pred1;
      ELSIF (v_num_vals = 3)
      THEN
         v_slc_pred2 := REPLACE(v_slc_pred1,':b_val_1',
                                ''''''||v_slc_val1||'''''');
         v_slc_pred1 := REPLACE(v_slc_pred2,':b_val_2',
                                ''''''||v_slc_val2||'''''');
         v_slc_pred2 := REPLACE(v_slc_pred1,':b_val_3',
                                ''''''||v_slc_val3||'''''');
         v_data_slc := v_slc_pred2;
      ELSIF (v_num_vals = 4)
      THEN
         v_slc_pred2 := REPLACE(v_slc_pred1,':b_val_1',
                                ''''''||v_slc_val1||'''''');
         v_slc_pred1 := REPLACE(v_slc_pred2,':b_val_2',
                                ''''''||v_slc_val2||'''''');
         v_slc_pred2 := REPLACE(v_slc_pred1,':b_val_3',
                                ''''''||v_slc_val3||'''''');
         v_slc_pred1 := REPLACE(v_slc_pred2,':b_val_4',
                                ''''''||v_slc_val4||'''''');
         v_data_slc := v_slc_pred1;
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block2||'.v_data_slc{641}',
        p_msg_text => v_data_slc);

      ------------------------------------
      -- Build call to Engine Push program
      ------------------------------------
      v_eng_call := 'DECLARE '||
         'x_slc_stat NUMBER; '||
         'x_slc_msg VARCHAR2(4000); '||
         'x_rows_processed NUMBER; '||
         'x_rows_loaded NUMBER; '||
         'x_rows_rejected NUMBER; '||
         'BEGIN '||v_eng_prg||
         '(x_slc_stat,x_slc_msg,'||
         ' x_rows_processed,x_rows_loaded,x_rows_rejected,'||
         ' :b_eng_sql,'''||v_data_slc||''','||
         ' :b_proc_num,:b_slc_id1,:b_fetch_limit';

      v_upd_stmt :=
         ' UPDATE fem_mp_process_ctl_t'||
         ' SET rows_processed = x_rows_processed,'||
         '     rows_loaded = x_rows_loaded,'||
         '     rows_rejected = x_rows_rejected,'||
         '     status = x_slc_stat,'||
         '     message = x_slc_msg'||
         ' WHERE req_id = :b_req_id'||
         ' AND slice_id = :b_slc_id2 ;'||
         ' COMMIT; '||
         'END;';

      ---------------------------------------------
      -- Add arguments and append Update statement
      -- to Engine Call statement
      --------------------------------------------
      IF (v_args_count = 0)
      THEN
         v_eng_call := v_eng_call||');'||
                       v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block2||'.v_eng_call{642.0}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 1)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.1}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 2)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.2}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1),t_arg(2),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 3)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.3}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1),t_arg(2),t_arg(3),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 4)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.4}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1),t_arg(2),t_arg(3),t_arg(4),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 5)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.5}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 6)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.6}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 7)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.7}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 8)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.8}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 9)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.9}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 10)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.10}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 11)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.11}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 12)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.12}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 13)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.13}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 14)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.14}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 15)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.15}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 16)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.16}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 17)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.17}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 18)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.18}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 19)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.19}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 20)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.20}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 21)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.21}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 22)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.22}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 23)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.23}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 24)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.24}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 25)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.25}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 26)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.26}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 27)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.27}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 28)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.28}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 29)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.29}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 30)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block2||'.v_eng_call{642.30}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 31)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.31}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 32)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.32}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 33)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.33}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 34)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.34}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 35)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34,:b_arg35);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.35}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),t_arg(35),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 36)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34,:b_arg35,:b_arg36);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.36}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),t_arg(35),t_arg(36),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 37)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
            ' :b_arg37);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.37}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),t_arg(35),t_arg(36),
               t_arg(37),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 38)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
            ' :b_arg37,:b_arg38);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.38}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),t_arg(35),t_arg(36),
               t_arg(37),t_arg(38),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 39)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
            ' :b_arg37,:b_arg38,:b_arg39);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.39}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),t_arg(35),t_arg(36),
               t_arg(37),t_arg(38),t_arg(39),
               p_req_id,v_slc_id;

      ELSIF (v_args_count = 40)
      THEN
         v_eng_call := v_eng_call||','||
            ' :b_arg1, :b_arg2, :b_arg3, :b_arg4,'||
            ' :b_arg5, :b_arg6, :b_arg7, :b_arg8,'||
            ' :b_arg9, :b_arg10,:b_arg11,:b_arg12,'||
            ' :b_arg13,:b_arg14,:b_arg15,:b_arg16,'||
            ' :b_arg17,:b_arg18,:b_arg19,:b_arg20,'||
            ' :b_arg21,:b_arg22,:b_arg23,:b_arg24,'||
            ' :b_arg25,:b_arg26,:b_arg27,:b_arg28,'||
            ' :b_arg29,:b_arg30,:b_arg31,:b_arg32,'||
            ' :b_arg33,:b_arg34,:b_arg35,:b_arg36,'||
            ' :b_arg37,:b_arg38,:b_arg39,:b_arg40);'||
         v_upd_stmt;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => v_block||'.v_eng_call{620.40}',
           p_msg_text => v_eng_call);

         EXECUTE IMMEDIATE v_eng_call
         USING v_eng_sql,p_proc_num,v_slc_id,p_fetch_limit,
               t_arg(1), t_arg(2), t_arg(3), t_arg(4),
               t_arg(5), t_arg(6), t_arg(7), t_arg(8),
               t_arg(9), t_arg(10),t_arg(11),t_arg(12),
               t_arg(13),t_arg(14),t_arg(15),t_arg(16),
               t_arg(17),t_arg(18),t_arg(19),t_arg(20),
               t_arg(21),t_arg(22),t_arg(23),t_arg(24),
               t_arg(25),t_arg(26),t_arg(27),t_arg(28),
               t_arg(29),t_arg(30),t_arg(31),t_arg(32),
               t_arg(33),t_arg(34),t_arg(35),t_arg(36),
               t_arg(37),t_arg(38),t_arg(39),t_arg(40),
               p_req_id,v_slc_id;

      END IF;

      SELECT status,message
      INTO v_slc_stat,v_slc_msg
      FROM fem_mp_process_ctl_t
      WHERE req_id = p_req_id
      AND slice_id = v_slc_id;

   END IF; -- Push Processing

   IF (v_num_vals > 0 AND p_mp_method = 1)
   THEN
   /*----------------------------------------------------------------------

                           Pull Processing

   ----------------------------------------------------------------------*/

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block2||'.Engine_Pull{650}',
        p_msg_text => 'Data slice pulled by MP Subrequest for processing');

      v_eng_sql := REPLACE(v_eng_sql,'{{data_slice}}',v_slc_pred);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block2||'.v_eng_sql{651}',
        p_msg_text => v_eng_sql);

      BEGIN
         v_slc_stat := 0;
         v_slc_msg := 'Data slice processed normally by MP Subrequest';

      IF (v_num_vals = 4)
      THEN
         EXECUTE IMMEDIATE v_eng_sql
         USING v_slc_val1,v_slc_val2,v_slc_val3,
               v_slc_val4;
         v_rows_processed := SQL%ROWCOUNT;
      ELSIF (v_num_vals = 3)
      THEN
         EXECUTE IMMEDIATE v_eng_sql
         USING v_slc_val1,v_slc_val2,v_slc_val3;
         v_rows_processed := SQL%ROWCOUNT;
      ELSIF (v_num_vals = 2)
      THEN
         EXECUTE IMMEDIATE v_eng_sql
         USING v_slc_val1,v_slc_val2;
         v_rows_processed := SQL%ROWCOUNT;
      ELSIF (v_num_vals = 1)
      THEN
         EXECUTE IMMEDIATE v_eng_sql
         USING v_slc_val1;
         v_rows_processed := SQL%ROWCOUNT;
      ELSE
         EXIT;
      END IF;

      EXCEPTION
         WHEN others THEN
            v_slc_stat := 2;
            v_slc_msg  := sqlerrm;
      END;

      UPDATE fem_mp_process_ctl_t
      SET status = v_slc_stat,
          message = v_slc_msg,
          rows_processed = v_rows_processed
      WHERE req_id = p_req_id
        AND slice_id = v_slc_id;

      COMMIT;

   END IF; -- Pull Processing

   ------------------------------
   -- Check for completion status
   ------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block2||'.slc_status{660}',
     p_msg_text => v_slc_stat||':'||v_slc_msg);

   CASE v_slc_stat
      WHEN 2 THEN EXIT;
      ELSE null;
   END CASE;

END LOOP;

END IF;

------------------------------------------
-- Post messages and set Concurrent status
------------------------------------------
SELECT MAX(status)
INTO v_sub_stat
FROM fem_mp_process_ctl_t
WHERE req_id = p_req_id
  AND process_num = p_proc_num;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_sub_stat{661}',
  p_msg_text => v_sub_stat);

IF (v_sub_stat IS NULL)
THEN
   v_sub_stat := 0;
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.v_sub_msg{662}',
     p_msg_text => 'Sub-request found no data slices to process');
END IF;

IF (v_sub_stat = 0)
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUB_NORMAL_TXT',
     p_token1 => 'PARENT_REQ',
     p_value1 => p_req_id,
     p_token2 => 'REQUEST',
     p_value2 => v_sub_req_id);

   v_sub_msg := FND_MSG_PUB.GET(p_encoded => 'F');

ELSIF (v_sub_stat = 1)
THEN
   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUB_WARN_TXT',
     p_token1 => 'PARENT_REQ',
     p_value1 => p_req_id,
     p_token2 => 'REQUEST',
     p_value2 => v_sub_req_id);

   v_sub_msg := FND_MSG_PUB.GET(p_encoded => 'F');
   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',null);

ELSE
   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUB_ENG_ERR',
     p_token1 => 'PARENT_REQ',
     p_value1 => p_req_id,
     p_token2 => 'REQUEST',
     p_value2 => v_sub_req_id);

   v_sub_msg := FND_MSG_PUB.GET(p_encoded => 'F');
   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_sub_msg{663}',
  p_msg_text => v_sub_msg);
FEM_ENGINES_PKG.USER_MESSAGE(
 p_msg_text => v_sub_msg);

/*=========================================================================

                     Sub-Request: Exception Block

 =========================================================================*/

EXCEPTION

WHEN e_soft_kill THEN
   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SOFT_KILL_WARN',
     p_token1 => 'REQUEST',
     p_value1 => v_sub_req_id);

   v_sub_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE(
     p_severity => c_log_level_5,
     p_module => v_block||'.soft_kill_signal{664}',
     p_msg_text => v_sub_msg);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_sub_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN others THEN
   v_stack := dbms_utility.format_call_stack;

   FEM_ENGINES_PKG.PUT_MESSAGE(
     p_app_name => 'FEM',
     p_msg_name => 'FEM_MP_SUB_UNEXP_ERR',
     p_token1 => 'PARENT_REQ',
     p_value1 => p_req_id,
     p_token2 => 'REQUEST',
     p_value2 => v_sub_req_id,
     p_token3 => 'SQLERRM',
     p_value3 => sqlerrm);

   v_sub_msg := FND_MSG_PUB.GET(p_encoded => 'F');

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_6,
     p_module => v_block||'.exception{665}',
     p_msg_text => v_sub_msg||'
'||v_stack);
   FEM_ENGINES_PKG.USER_MESSAGE(
    p_msg_text => v_sub_msg);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

END Sub_Request;


/**************************************************************************
 **************************************************************************

                         =============================
                                Get Data Slice
                         =============================

 **************************************************************************
 **************************************************************************/

PROCEDURE Get_Data_Slice

  (x_slc_id       OUT     NOCOPY NUMBER,
   x_slc_val1     OUT     NOCOPY VARCHAR2,
   x_slc_val2     OUT     NOCOPY VARCHAR2,
   x_slc_val3     OUT     NOCOPY VARCHAR2,
   x_slc_val4     OUT     NOCOPY VARCHAR2,
   x_num_vals     OUT     NOCOPY NUMBER,
   x_part_name    OUT     NOCOPY VARCHAR2,
   p_req_id       IN      NUMBER,
   p_proc_num     IN      NUMBER)

IS

   f_set_status             BOOLEAN;

   v_kill_signal            NUMBER;
   v_part_count             NUMBER;
   v_slc_id                 NUMBER;
   v_proc_num0              NUMBER;
   v_slc_stat               NUMBER;
   v_rows_processed         NUMBER;
   v_rows_loaded            NUMBER;
   v_rows_rejected          NUMBER;
   v_rule_id                NUMBER;
   v_slc_beg                NUMBER;
   v_slc_len                NUMBER;
   v_slc_num                NUMBER;

   v_args_count             NUMBER;
   v_data_slc               VARCHAR2(2000);
   v_eng_prg                VARCHAR2(80);
   v_eng_prms               VARCHAR2(32767);
   v_part_name              VARCHAR2(30);
   v_part_next              VARCHAR2(30);
   v_slc_msg                VARCHAR2(4000);
   v_slc_pred               VARCHAR2(32767);
   v_slc_pred1              VARCHAR2(32767);
   v_slc_pred2              VARCHAR2(32767);

   v_stack                  VARCHAR2(32767);
   v_trace                  VARCHAR2(255);

   v_sub_msg                VARCHAR2(4000);
   v_sub_req_id             NUMBER := fnd_global.conc_request_id;

   v_block                  VARCHAR2(80) := 'fem.plsql.fem_mp.get_data_slice'||
                                            '{p'||p_proc_num||'}';
   v_block2                 VARCHAR2(80);

   v_sql_cmd                VARCHAR2(32767);

   v_data_item              VARCHAR2(240);

BEGIN

/*------------------------------------------------------------------------

                          Get partition count

 -------------------------------------------------------------------------*/

SELECT COUNT(DISTINCT partition)
INTO v_part_count
FROM fem_mp_process_ctl_t
WHERE req_id = p_req_id;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.v_part_count{670}',
  p_msg_text => v_part_count);

IF v_part_count = 0
THEN
   v_part_name := null;
ELSE
   v_part_name := 'DUMMY';
END IF;

/*------------------------------------------------------------------------

  Get and process a data slice until all data slices have been processed

 -------------------------------------------------------------------------*/

------------------------
-- Check for Kill signal (this feature is not implemented yet)
------------------------
v_kill_signal := 0;

CASE v_kill_signal
   WHEN 1 THEN RAISE e_soft_kill;
   ELSE null;
END CASE;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.Get_Slice{671}',
  p_msg_text => 'Getting slice to process. '||
                   'Log entry will appear as (p'||p_proc_num||':sN)');

IF (v_part_count = 0)
THEN
/*---------------------------------------------------------------------

                 Partition slicing is DISabled

---------------------------------------------------------------------*/

   -- ------------------------------------------------------------------------------------------
   -- Identify next UNprocessed slice
   -- Bug# 5709246 (Greg Hall)
   -- Note that while it appears that process_num is selected into v_proc_num0 for now apparent
   -- use, it is in fact needed, as explained here:
   -- ------------------------------------------------------------------------------------------
   -- Suppose process P1 selects data slice 3 "for update", and then process P2 immediately
   -- executes its query before P1 can update it with its own process number and commit the
   -- change, so the optimizer identifies the same row that P1 has locked.  Since P1 has a lock
   -- on the row, and P2 also wants the row "for update" it is made to wait. After P1 updates
   -- the row and commits the change, the row lock is released.  When only SLICE_ID is
   -- selected, the optimizer, which has already identified the desired row, returns it as the
   -- result of P2's query. P1 proceeds to process slice 3, while P2 updates slice 3 with its
   -- process number, commits the change, an proceeds to also process slice 3.  Apparently
   -- since only SLICE_ID was selected, and that column has not changed since the row was
   -- originally requested, the optimizer returns that same row.  But when PROCESS_NUM is
   -- also selected, apparently the optimizer recognizes that the value of PROCESS_NUM has
   -- been changed since the row was originally requested, so it re-executes the query to
   -- retrieve the updated value of PROCESS_NUM, and the re-execution of the query now
   -- identifies and returns a different row (slice 4, the correct one).  With this behavior,
   -- no loop is actually needed, but as this behavior does not seem to be a documented feature,
   -- it is susceptible to change.  To be on the safe side, instead of relying on that behavior
   -- a loop is included anyway.  My unit tests showed that in every case, the loop exited on
   -- the first pass.
   -- Note that this code section is repeated below for the partition section of the procedure.
   -- ------------------------------------------------------------------------------------------
   BEGIN

      COMMIT;

      LOOP

         SELECT slice_id, process_num
         INTO v_slc_id, v_proc_num0
         FROM fem_mp_process_ctl_t
         WHERE req_id = p_req_id
           AND slice_id =
              (SELECT MIN(slice_id)
               FROM fem_mp_process_ctl_t
               WHERE req_id = p_req_id
                 AND process_num = 0)
         FOR UPDATE;

         IF v_proc_num0 = 0 THEN
            EXIT;
         ELSE
            ROLLBACK;
         END IF;

      END LOOP;

      UPDATE fem_mp_process_ctl_t
      SET process_num = p_proc_num
      WHERE req_id = p_req_id
        AND slice_id = v_slc_id;

      COMMIT;

   EXCEPTION
      WHEN no_data_found THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_3,
           p_module => v_block||'.End{699}',
           p_msg_text => 'End FEM_MP.SUBREQ. No more slices to process');
         RETURN;
   END;

END IF;

IF (v_part_count > 0)
THEN
/*---------------------------------------------------------------------

                 Partition slicing is enabled

   Select a partition using the following order of precedence:
    1. Previously used partition:
          If a partition has alredy been used, select it
          again if there are still unprocessed slices
    2. Next unprocessed partition
    3. Least processed partition
------------------------------------------------------------*/

   ----------------------------
   -- Previously used partition
   ----------------------------

   IF (p_proc_num <= v_part_count)
   THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.Get_Slice{680}',
        p_msg_text => 'Searching previously used partition');
      BEGIN
         SELECT MIN(partition)
         INTO v_part_next
         FROM fem_mp_process_ctl_t
         WHERE req_id = p_req_id
           AND process_num = p_proc_num
           AND partition IN
              (SELECT partition
               FROM fem_mp_process_ctl_t
               WHERE req_id = p_req_id
               AND process_num = 0);
      END;
   ELSE
      v_part_next := '';
   END IF;

   -----------------------------
   -- Next unprocessed partition
   -----------------------------

   IF (v_part_next IS NULL)
   THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.Get_Slice{681}',
        p_msg_text => 'Searching next unprocessed partition');
      BEGIN
         SELECT MIN(partition)
         INTO v_part_next
         FROM fem_mp_process_ctl_t
         WHERE req_id = p_req_id
           AND partition NOT IN
              (SELECT partition
               FROM fem_mp_process_ctl_t
               WHERE req_id = p_req_id
               AND process_num > 0);
      END;
   END IF;

   -----------------------------
   -- Least processed partition
   -----------------------------

   IF (v_part_next IS NULL)
   THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.Get_Slice{682}',
        p_msg_text => 'Searching least processed partition');
      BEGIN
         SELECT MIN(partition)
         INTO v_part_next
         FROM
           (SELECT partition, count(*) stat_0
            FROM fem_mp_process_ctl_t
            WHERE req_id = p_req_id
              AND process_num = 0
            GROUP BY partition)
         WHERE stat_0 =
           (SELECT max(stat_0) FROM
              (SELECT count(*) stat_0
               FROM fem_mp_process_ctl_t
               WHERE req_id = p_req_id
                 AND process_num = 0
               GROUP BY partition));
      END;
   END IF;

   --------------------------------------------------------
   -- Identify next unprocessed slice in selected partition
   -- See explanation above for bug# 5709246 re: why
   -- it is required to select process_num in this query.
   --------------------------------------------------------
   BEGIN

      COMMIT;

      LOOP

         SELECT slice_id, process_num
         INTO v_slc_id, v_proc_num0
         FROM fem_mp_process_ctl_t
         WHERE req_id = p_req_id
           AND slice_id =
              (SELECT MIN(slice_id)
               FROM fem_mp_process_ctl_t
               WHERE req_id = p_req_id
                 AND process_num = 0
                 AND partition = v_part_next)
         FOR UPDATE;

         IF v_proc_num0 = 0 THEN
            EXIT;
         ELSE
            ROLLBACK;
         END IF;

      END LOOP;

      UPDATE fem_mp_process_ctl_t
      SET process_num = p_proc_num
      WHERE req_id = p_req_id
        AND slice_id = v_slc_id;

      COMMIT;

   EXCEPTION
      WHEN no_data_found THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_3,
           p_module => v_block||'.End{699}',
           p_msg_text => 'End FEM_MP.SUBREQ. No more slices to process');
         RETURN;
   END;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,v_block||'.v_part_name{683}',v_part_name);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,v_block||'.v_part_next{684}',v_part_next);

   ------------------------------------
   -- Reset partition name if necessary
   ------------------------------------
   IF (v_part_next <> v_part_name)
   THEN

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.v_part_reset{685}',
        p_msg_text => 'Resetting v_part_name to '||v_part_next);

      v_part_name := v_part_next;

   END IF;

END IF;

/*----------------------------------------------------------------------

                       Get identified slice

---------------------------------------------------------------------*/

x_slc_id := v_slc_id;
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.x_slc_id{690}',
  p_msg_text => x_slc_id);

v_block2 := REPLACE(v_block,'}',':s'||v_slc_id||'}');

x_part_name := v_part_name;
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block2||'.x_part_name{691}',
  p_msg_text => x_part_name);

BEGIN
   SELECT data_slice
   INTO v_data_slc
   FROM fem_mp_process_ctl_t
   WHERE req_id = p_req_id
     AND slice_id = v_slc_id
     AND process_num = p_proc_num;
EXCEPTION
   WHEN no_data_found THEN
      v_data_slc := null;
END;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block2||'.v_data_slc{692}',
  p_msg_text => v_data_slc);

IF (v_data_slc IS NULL)
THEN
   x_num_vals := 0;
ELSE
   -------------------------
   -- Extract data slices --
   -------------------------

   v_slc_num := 1;
   v_slc_beg := 1;

   LOOP
      v_slc_len := INSTR(v_data_slc,'{#}',1,v_slc_num)-v_slc_beg;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block2||'.v_slc_len(slc#'||v_slc_num||'){693}',
        p_msg_text => v_slc_len);

      IF (v_slc_len > 0)
      THEN
         v_data_item := SUBSTR(v_data_slc,v_slc_beg,v_slc_len);
      ELSIF (v_slc_len = 0)
      THEN
         v_data_item := null;
      ELSE
         v_data_item := SUBSTR(v_data_slc,v_slc_beg);
      END IF;

      CASE v_slc_num
         WHEN 1 THEN x_slc_val1 := v_data_item;
         WHEN 2 THEN x_slc_val2 := v_data_item;
         WHEN 3 THEN x_slc_val3 := v_data_item;
         WHEN 4 THEN x_slc_val4 := v_data_item;
      END CASE;

      EXIT WHEN (v_slc_len < 0);
      EXIT WHEN (v_slc_num = 4);

      v_slc_beg := INSTR(v_data_slc,'{#}',1,v_slc_num)+3;
      v_slc_num := v_slc_num + 1;

   END LOOP;
   x_num_vals := v_slc_num;

END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block2||'.x_slc_val1{694.1}',
  p_msg_text => x_slc_val1);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block2||'.x_slc_val2{694.2}',
  p_msg_text => x_slc_val2);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block2||'.x_slc_val3{694.3}',
  p_msg_text => x_slc_val3);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block2||'.x_slc_val4{694.4}',
  p_msg_text => x_slc_val4);

END Get_Data_Slice;


/**************************************************************************
 **************************************************************************

                      =============================
                            Post Data Slice
                      =============================

 **************************************************************************
 **************************************************************************/

PROCEDURE Post_Data_Slice(
   p_req_id          IN  NUMBER,
   p_slc_id          IN  NUMBER,
   p_status          IN  NUMBER,
   p_message         IN  VARCHAR2 DEFAULT NULL,
   p_rows_processed  IN   NUMBER DEFAULT 0,
   p_rows_loaded     IN   NUMBER DEFAULT 0,
   p_rows_rejected   IN   NUMBER DEFAULT 0)
IS
   v_block             VARCHAR2(80) := 'fem.plsql.fem_mp.post_data_slice';
   v_sql_cmd           VARCHAR2(32766);
BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_req_id{700}',
 p_msg_text => p_req_id);
FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_slc_id{701}',
 p_msg_text => p_slc_id);
FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_status{702}',
 p_msg_text => p_status);
FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_message{703}',
 p_msg_text => p_message);
FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_rows_processed{704}',
 p_msg_text => p_rows_processed);
FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_rows_loaded{705}',
 p_msg_text => p_rows_loaded);
FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.p_rows_rejected{706}',
 p_msg_text => p_rows_rejected);

FEM_ENGINES_PKG.TECH_MESSAGE
(p_severity => c_log_level_2,
 p_module => v_block||'.v_sql_cmd{707}',
 p_msg_text => 'Updating FEM_MP_PROCESS_CTL_T.');

UPDATE fem_mp_process_ctl_t
SET rows_processed = p_rows_processed,
    rows_loaded = p_rows_loaded,
    rows_rejected = p_rows_rejected,
    status = p_status,
    message = p_message
WHERE req_id = p_req_id
  AND slice_id = p_slc_id;

COMMIT;

END Post_Data_Slice;

/**************************************************************************
 **************************************************************************

                      =============================
                            Post Subreq Messages
                      =============================

 **************************************************************************
 **************************************************************************/

PROCEDURE Post_Subreq_Messages(
   p_req_id          IN  NUMBER)
IS
   TYPE mp_message_type IS TABLE OF
      fem_mp_process_ctl_t.message%TYPE INDEX BY BINARY_INTEGER;
   v_msg_list   mp_message_type;
BEGIN
   SELECT DISTINCT(message)
   BULK COLLECT INTO v_msg_list
   FROM fem_mp_process_ctl_t
   WHERE req_id = p_req_id
   AND status IN (1,2);

   FEM_ENGINES_PKG.User_Message (
     p_app_name => 'FEM',
     p_msg_text => '
========== Warnings and Errors ==========');

   FOR i IN 1..v_msg_list.COUNT
   LOOP
      FEM_ENGINES_PKG.User_Message (
        p_app_name => 'FEM',
        p_msg_text => v_msg_list(i) );
   END LOOP;

   FEM_ENGINES_PKG.User_Message (
     p_app_name => 'FEM',
     p_msg_text => '=========================================
');

END Post_Subreq_Messages;

/**************************************************************************
 **************************************************************************

                      =============================
                           Delete Data Slices
                      =============================

 **************************************************************************
 **************************************************************************/

PROCEDURE Delete_Data_Slices(
   p_req_id          IN  NUMBER)
IS
BEGIN
   DELETE FROM fem_mp_process_ctl_t
    WHERE req_id = p_req_id;

   COMMIT;

   DELETE FROM fem_mp_process_args_t
   WHERE req_id = p_req_id;

   COMMIT;

END Delete_Data_Slices;

/***************************************************************************/

END FEM_Multi_Proc_Pkg;

/
